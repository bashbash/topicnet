#include "CShader.h"

bool InitGLSL()
{
	glewInit();

	if (!GLEW_ARB_shader_objects || !GLEW_ARB_shading_language_100)
		return false;

	// Return a success!
	return true;
}

/// check if the previously loaded program had an error
bool CShader::checkProgramError()
{
	int infologLength = 0;
	int charsWritten = 0;
	char *infoLog;

//	checkError();

//	GLuint id = isVertexProgram ? vertexShaderID : fragmentShaderID;
	GLuint target = GL_OBJECT_LINK_STATUS_ARB;
	GLuint id = m_hProgramObject;

	GLint compiled;
	glGetObjectParameterivARB(id, target, &compiled);

	if (compiled)
		return true;

	glGetObjectParameterivARB(id, GL_OBJECT_INFO_LOG_LENGTH_ARB, &infologLength);
//	checkError();
	if (infologLength>0)
	{
		infoLog = (char*)malloc(infologLength);
		if (infoLog == NULL)
			return false;
		glGetInfoLogARB(id, infologLength, &charsWritten, infoLog);
		printf("%s\n", infoLog);
		free(infoLog);
	}
	return false;
}

string CShader::LoadTextFile(string strFile)
{
	// Open the file passed in
	ifstream fin(strFile.c_str());

	// Make sure we opened the file correctly
	if(!fin)
		return "";

	string strLine = "";
	string strText = "";

	// Go through and store each line in the text file within a "string" object
	while(getline(fin, strLine))
	{
		strText = strText + "\n" + strLine;
	}

	// Close our file
	fin.close();

	// Return the text file's data
	return strText;
}

void CShader::InitShaders(string strVertex, string strFragment)
{
	// These will hold the shader's text file data
	string strVShader, strFShader;

	// Make sure the user passed in a vertex and fragment shader file
	if(!strVertex.length() || !strFragment.length())
		return;

	// If any of our shader pointers are set, let's free them first.
	if(m_hVertexShader || m_hFragmentShader || m_hProgramObject)
		Release();

	// Here we get a pointer to our vertex and fragment shaders
	m_hVertexShader = glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB);
	m_hFragmentShader = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);

	// Now we load the shaders from the respective files and store it in a string.
	strVShader = LoadTextFile(strVertex.c_str());
	strFShader = LoadTextFile(strFragment.c_str());

	// Do a quick switch so we can do a double pointer below
	const char *szVShader = strVShader.c_str();
	const char *szFShader = strFShader.c_str();

	// Now this assigns the shader text file to each shader pointer
	glShaderSourceARB(m_hVertexShader, 1, &szVShader, NULL);
	glShaderSourceARB(m_hFragmentShader, 1, &szFShader, NULL);

	// Now we actually compile the shader's code
	glCompileShaderARB(m_hVertexShader);
	glCompileShaderARB(m_hFragmentShader);

	// Next we create a program object to represent our shaders
	m_hProgramObject = glCreateProgramObjectARB();

	// We attach each shader we just loaded to our program object
	glAttachObjectARB(m_hProgramObject, m_hVertexShader);
	glAttachObjectARB(m_hProgramObject, m_hFragmentShader);

	// Our last init function is to link our program object with OpenGL
	glLinkProgramARB(m_hProgramObject);

	checkProgramError();

	// Now, let's turn on our current shader.  Passing 0 will turn OFF a shader.
	glUseProgramObjectARB(m_hProgramObject);
}

GLint CShader::GetVariable(string strVariable)
{
	// If we don't have an active program object, let's return -1
	if(!m_hProgramObject)
		return -1;

	// This returns the variable ID for a variable that is used to find
	// the address of that variable in memory.
	return glGetUniformLocationARB(m_hProgramObject, strVariable.c_str());
}

void CShader::Release()
{
	// To free a shader we need to detach the vertex and fragment
	// shader pointers from the program object, then free each one.
	// Once that is done we can finally delete the program object.

	// If our vertex shader pointer is valid, free it
	if(m_hVertexShader)
	{
		glDetachObjectARB(m_hProgramObject, m_hVertexShader);
		glDeleteObjectARB(m_hVertexShader);
		m_hVertexShader = NULL;
	}

	// If our fragment shader pointer is valid, free it
	if(m_hFragmentShader)
	{
		glDetachObjectARB(m_hProgramObject, m_hFragmentShader);
		glDeleteObjectARB(m_hFragmentShader);
		m_hFragmentShader = NULL;
	}

	// If our program object pointer is valid, free it
	if(m_hProgramObject)
	{
		glDeleteObjectARB(m_hProgramObject);
		m_hProgramObject = NULL;
	}
}
