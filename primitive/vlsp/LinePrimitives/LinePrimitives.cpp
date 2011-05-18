#include "glew.h"
#include "glut.h"
#include "CShader.h"

int oX, oY;
float angleX=0.0f;
float angleY=0.0f;
int ush = 0;
int utx = 0;

// vertex definition
typedef struct 
{
	GLfloat pos[3];
	GLfloat col[3];
	GLfloat norm[3];
	GLfloat radius;
	GLfloat rot;
	GLfloat zdiff;
} vertex;

// texture
GLuint shape[3];
GLuint dtex[3];

GLuint profile, texture, haloColor;

#define RADIUS 0.02f
#define WRADIUS 0.01f
#define HALOSIZE 0.1f

#define SIZE 64

#define TSIZE 512

#define HSIZE (SIZE/2)
#define DSIZE (SIZE*(SIZE+1))

#define OBJECT_DISPLAYLIST 1

vertex data[DSIZE];

CShader* lineShader;

void changeSize(int w, int h)
{
	// Prevent a divide by zero, when window is too short
	// (you cant make a window of zero width).
	if(h == 0)
		h = 1;

	float ratio = 1.0* w / h;

	// Reset the coordinate system before modifying
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	// Set the viewport to be the entire window
    glViewport(0, 0, w, h);

	// Set the correct perspective.
	gluPerspective(45,ratio,1,1000);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(0.0,0.0,5.0, 
		      0.0,0.0,-1.0,
			  0.0f,1.0f,0.0f);


	GLfloat LightAmbient[] = { 0.5, 0.5, 0.5, 1.0 };
	GLfloat LightDiffuse[] = { 1.0, 1.0, 1.0, 1.0 };
	GLfloat LightPosition[] = { 0.0, 0.0, 1.0, 0.0 };

	glLightfv(GL_LIGHT0, GL_AMBIENT, LightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, LightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION,LightPosition);

	glEnable(GL_LIGHT0);  

	GLfloat MaterialAmbient[] = { 0.0, 0.0, 0.0, 1.0 };
	GLfloat MaterialDiffuse[] = { 1.0, 0.0, 0.0, 1.0 };
	GLfloat MaterialSpecular[] = { 1.0, 1.0, 1.0, 1.0 };

	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 64.0f);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, MaterialAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialDiffuse);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, MaterialSpecular);

	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

/// render a single streamline part
void renderStreamline(vertex a, vertex b)
{
	// halofactor is the value by which we have to scale the width of the streamline to accomodate for the added halo
	float halofactor = (1.0f + 2.0f * HALOSIZE);

	// simple rendering	

	// set color of lower side
	glColor3fv(&a.col[0]);

	// transfer tangent of lower side
	glNormal3fv(&a.norm[0]);

	// set rendering values for bottom left vertex :
	//   float 1 : horizontal extrusion amount, modified by halofactor and user determined scale factor
	//   float 2 : radius of the streamline, needed for depth correction and similar things
	//   float 3 : vertical texture coordinate, used for rotation effects and the like
	//   float 4 : vertical extrusion amount
	glTexCoord4f(-a.radius * halofactor, a.radius, a.rot, 0.0f);

	// render vertex
	glVertex3fv(&a.pos[0]);

	// set rendering values for bottom right vertex
	glTexCoord4f(a.radius * halofactor, a.radius, a.rot, 0.0f);

	// render vertex
	glVertex3fv(&a.pos[0]);

	// set color of upper side
	glColor3fv(&b.col[0]);

	// set tangent of upper side
	glNormal3fv(&b.norm[0]);

	// set rendering values for top right vertex
	glTexCoord4f(b.radius * halofactor, b.radius, b.rot, 0.0f);

	// render vertex
	glVertex3fv(&b.pos[0]);

	// set rendering values for top left vertex
	glTexCoord4f(-b.radius * halofactor, b.radius, b.rot, 0.0f);

	// render vertex
	glVertex3fv(&b.pos[0]);
}

void renderStreamlineStrip(vertex v)
{
	/// render a single part of a streamline strip
	float halofactor = (1.0f + 2.0f * HALOSIZE);

	// simple rendering	

	glColor3fv(&v.col[0]);
	glNormal3fv(&v.norm[0]);

	glTexCoord4f(-v.radius * halofactor, v.radius, v.rot, v.zdiff);
	glVertex3fv(&v.pos[0]);

	glTexCoord4f(v.radius * halofactor, v.radius, v.rot, v.zdiff);
	glVertex3fv(&v.pos[0]);
}

void renderScene(void)
{
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_LIGHTING);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPushMatrix();
	glRotatef(angleX,0.0,1.0,0.0);
	glRotatef(angleY,1.0,0.0,0.0);

	for(int i = 0; i<SIZE; i++)
	{
		glBegin(GL_LINE_STRIP);
		for(int j = 0; j<SIZE+1; j++)
		{
			float aj = (float)j / (float)HSIZE * 3.14159265f * 32;
			int a = i*(SIZE+1)+j;
			glVertex3fv(&(data[a].pos[0]));
		}
		glEnd();
	}

	// rendering with shader
	glActiveTextureARB(GL_TEXTURE0_ARB);
	glEnable(GL_TEXTURE_2D);
	glBindTexture( GL_TEXTURE_2D, shape[ush] );

	glActiveTextureARB(GL_TEXTURE1_ARB);
	glEnable(GL_TEXTURE_2D);
	glBindTexture( GL_TEXTURE_2D, dtex[utx] );

	lineShader->TurnOn();

	float p[4];
	glGetLightfv(GL_LIGHT0, GL_POSITION, &p[0]);

	lineShader->SetInt(profile, 0);
	lineShader->SetInt(texture, 1);
	lineShader->SetFloat4(haloColor, 0.0, 0.0, 0.0, 1.0);

//	glCallList(OBJECT_DISPLAYLIST);
	for(int i = 0; i<SIZE; i++)
	{
		glBegin(GL_QUAD_STRIP);
		for(int j = 0; j<SIZE+1; j++)
		{
			float aj = (float)j / (float)HSIZE * 3.14159265f * 32;
			int a = i*(SIZE+1)+j;
			renderStreamlineStrip(data[a]);
		}
		glEnd();
	}

	lineShader->TurnOff();

	glActiveTextureARB(GL_TEXTURE1_ARB);
	glDisable(GL_TEXTURE_2D);

	glActiveTextureARB(GL_TEXTURE0_ARB);
	glDisable(GL_TEXTURE_2D);

	glPopMatrix();

	glutSwapBuffers();
}

void processNormalKeys(unsigned char key, int x, int y)
{
	switch (key)
	{
	case '1':
		ush = 0;
		break;
	case '2':
		ush = 1;
		break;
	case '3':
		ush = 2;
		break;
	case '4':
		utx = 0;
		break;
	case '5':
		utx = 1;
		break;
	case '6':
		utx = 2;
		break;
	case 27: // escape key
		exit(0);
		break;
	}
}

void processMouse(int button, int state, int x, int y)
{
	oX = x;
	oY = y;
}

void processMouseActiveMotion(int x, int y)
{
	int dX = x - oX;
	int dY = y - oY;
	angleX += (float)dX / 2.0f;
	angleY += (float)dY / 2.0f;

	oX = x;
	oY = y;
}

void initStructure()
{
	int i,j;

	// initialize example streamfield position
	for(i = 0; i<SIZE; i++)
	{
		for(j = 0; j<SIZE+1; j++)
		{
			int a = i*(SIZE+1)+j;

			float ai = (float)i / (float)HSIZE * 3.14159265f;
			float aj = (float)j / (float)HSIZE * 3.14159265f;

			float d[3];

			d[0] = sin(ai);
			d[1] = cos(ai);
			d[2] = 0.0f;

			data[a].pos[0] = (d[0] * 2.0f + d[0] * cos(aj)) * 0.6f;
			data[a].pos[1] = (d[1] * 2.0f + d[1] * cos(aj)) * 0.6f;
			data[a].pos[2] = (d[2] * 2.0f + d[2] * cos(aj)) * 0.6f + sin(aj) * (0.75f + sin(ai) * 0.25f);

			data[a].col[0] = (sin(aj*8 + ai));
			data[a].col[1] = (1.0f-sin(aj*8 + ai)) * 0.5f;
			data[a].col[2] = 0;
//			data[a].col[0] = data[a].col[1] = data[a].col[2] = 1.0;

			data[a].radius = RADIUS + WRADIUS * sin(aj*8 + ai);
			//			data[a].radius = RADIUS;

			data[a].rot = ((float)j / (float)HSIZE) * 4 + (float)i / (float)HSIZE;
			//			data[a].rot = 0;
		}
	}

	// create vertex normals
	for(i = 0; i<SIZE; i++)
	{
		for(j = 0; j<SIZE+1; j++)
		{
			int a = i*(SIZE+1)+j;

			GLfloat n[3];
			GLfloat r;

			if (j == SIZE)
			{
				n[0] = data[i*(SIZE+1)].norm[0];
				n[1] = data[i*(SIZE+1)].norm[1];
				n[2] = data[i*(SIZE+1)].norm[2];
				r = data[i*(SIZE+1)].zdiff;
			} else {
				n[0] = data[a].pos[0] - data[a+1].pos[0];
				n[1] = data[a].pos[1] - data[a+1].pos[1];
				n[2] = data[a].pos[2] - data[a+1].pos[2];
				r = data[a].radius - data[a+1].radius;
			}

			float l = 1.0f / sqrt(n[0]*n[0] + n[1]*n[1] + n[2]*n[2]);

			data[a].norm[0] = n[0]*l;
			data[a].norm[1] = n[1]*l;
			data[a].norm[2] = n[2]*l;
			data[a].zdiff = r*l;
		}
	}

	// create display list
	glNewList(OBJECT_DISPLAYLIST ,GL_COMPILE);

	for(int i = 0; i<SIZE; i++)
	{
		glBegin(GL_QUAD_STRIP);
		for(int j = 0; j<SIZE+1; j++)
		{
			float aj = (float)j / (float)HSIZE * 3.14159265f * 32;
			int a = i*(SIZE+1)+j;
			renderStreamlineStrip(data[a]);
		}
		glEnd();
	}

	glEndList();
}

void initTextures()
{
	int res = 256;

	// compute 1D shape map
	float* shape0 = (float*)(new float[res*res*4]);
	float* shape1 = (float*)(new float[res*res*4]);
	float* shape2 = (float*)(new float[res*res*4]);

	for (int i=0;i<res;i++)
	{
		for (int j=0;j<res;j++)
		{
			// textures for normal coefficient lookup. x is across profile, y is rotation index.
			// all profile lookups are stored as if they were in an orthogonal projection, making things easier.
			// red coefficient is stored packed, meaning 0 to 1 really maps to -1 to 1
			int os = ((i*res)+j)*4;

			float x = ((float)j/(float)res) * 2.0f - 1.0f;
			float y = (float)i/(float)res;

			// r channel contains side vector coefficient
			// g channel contains up vector coefficient
			// b channel contains depth correction factor

			// first profile = cylinder, all rotation indices are equal, easy

			shape0[os+0] = x * 0.5f + 0.5f;
			shape0[os+1] = sqrt(1.0f - x*x);
			shape0[os+2] = sqrt(1.0f - x*x);

			// second profile

			float angle = y * 3.14159265f ;
			float center = -cos(angle);

			if (x < center)
			{
				shape1[os+0] = -cos(angle*0.5f) * 0.5f + 0.5f;
				shape1[os+1] = sin(angle*0.5f);
			} else
			{
				shape1[os+0] = sin(angle*0.5f) * 0.5f + 0.5f;
				shape1[os+1] = cos(angle*0.5f);
			}
			shape1[os+2] = sqrt(1.0f - x*x); 

			// third profile = rectangle stuff
			if (x < center)
			{
				shape2[os+0] = -cos(angle*0.5f) * 0.5f + 0.5f;
				shape2[os+1] = sin(angle*0.5f);
			} else
			{
				shape2[os+0] = sin(angle*0.5f) * 0.5f + 0.5f;
				shape2[os+1] = cos(angle*0.5f);
			}
			shape2[os+2] = sqrt(1.0f - x*x); 

		}
	}

	// create shape textures
	glGenTextures(3, shape);

	glBindTexture( GL_TEXTURE_2D, shape[0]);
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA_FLOAT32_ATI, res, res, 0, GL_RGBA, GL_FLOAT, shape0 );

	glBindTexture( GL_TEXTURE_2D, shape[1]);
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA_FLOAT32_ATI, res, res, 0, GL_RGBA, GL_FLOAT, shape1 );

	glBindTexture( GL_TEXTURE_2D, shape[2]);
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA_FLOAT32_ATI, res, res, 0, GL_RGBA, GL_FLOAT, shape2 );

	// diffuse texture stuff
	unsigned char *texdata = new unsigned char[3];
	texdata[0] = texdata[1] = texdata[2] = 255;

	float *mtex1 = new float[res*res*4];
	float *mtex2 = new float[res*res*4];

	for (int i=0;i<res;i++)
	{
		for (int j=0;j<res;j++)
		{
			// textures simple diffuse texturing
			int os = ((i*res)+j)*4;

			float x = ((float)j/(float)res);
			float y = (float)i/(float)res;

			if ( abs((res/2) - j) > (i % (res/4))  )
			{
				mtex1[os+0] = 1.0f;
				mtex1[os+1] = 1.0f;
				mtex1[os+2] = 1.0f;
			}
			else
			{
				mtex1[os+0] = 0.5f;
				mtex1[os+1] = 0.5f;
				mtex1[os+2] = 0.5f;
			}
			mtex1[os+3] = 1.0f;

			mtex2[os+0] = (y * 4.0f) - (float)(int)(y*4.0f);
			mtex2[os+1] = (y * 4.0f) - (float)(int)(y*4.0f);
			mtex2[os+2] = (y * 4.0f) - (float)(int)(y*4.0f);
			mtex2[os+3] = 1.0f;
		}
	}

	// create textures
	glGenTextures(3, dtex);

	glBindTexture( GL_TEXTURE_2D, dtex[0]);
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexImage2D( GL_TEXTURE_2D, 0, 3, 1, 1, 0, GL_RGB, GL_UNSIGNED_BYTE, texdata );

	glBindTexture( GL_TEXTURE_2D, dtex[1]);
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexImage2D( GL_TEXTURE_2D, 0, 4, res, res, 0, GL_RGBA, GL_FLOAT, mtex1 );

	glBindTexture( GL_TEXTURE_2D, dtex[2]);
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexImage2D( GL_TEXTURE_2D, 0, 4, res, res, 0, GL_RGBA, GL_FLOAT, mtex2 );
}

void main(int argc, char **argv)
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
	glutInitWindowPosition(10,10);
	glutInitWindowSize(512,512);

	glutCreateWindow("LinePrimitives Demo");
	glutDisplayFunc(renderScene);
	glutIdleFunc(renderScene);

	glutReshapeFunc(changeSize);

	glutKeyboardFunc(processNormalKeys);
	glutMouseFunc(processMouse);
	glutMotionFunc(processMouseActiveMotion);

	glEnable(GL_DEPTH_FUNC);

	if (glewInit() == GLEW_OK)
	{
		if (!GLEW_ARB_multitexture)
			return;

		// load shader
		lineShader = new CShader();
		lineShader->InitShaders("VertexShader.glsl", "FragmentShader.glsl");

		lineShader->TurnOn();
		profile = lineShader->GetVariable("profile");
		texture = lineShader->GetVariable("texture");
		haloColor = lineShader->GetVariable("haloColor");

		lineShader->TurnOff();

		initStructure();
		initTextures();

		glutMainLoop();

		lineShader->Release();
		delete lineShader;
	}
	else
	{
		printf("This sucks.");
	}
}
