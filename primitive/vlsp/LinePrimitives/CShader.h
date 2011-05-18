#ifndef _CSHADER_H
#define _CSHADER_H

#include "glew.h"
//#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
//#include <gl\gl.h>										// Header File For The OpenGL32 Library
//#include <gl\glu.h>										// Header File For The GLu32 Library
#include <string>										// Used for our STL string objects
#include <fstream>										// Used for our ifstream object to load text files
#include <time.h>
#include <math.h>
using namespace std;

// This is our very basic shader class that we will use
class CShader
{
public:

	// Create an empty constructor and have the deconstructor release our memory.
	CShader()	{				}
	~CShader()	{ Release();	}

	// This loads our text file for each shader and returns it in a string
	string LoadTextFile(string strFile);

	// This loads a vertex and fragment shader
	void InitShaders(string strVertex, string strFragment);
	
	// This returns an ID for a variable in our shader
	GLint GetVariable(string strVariable);

	// Below are functions to set an integer or a set of floats
	void SetInt(GLint variable, int newValue)								{ glUniform1iARB(variable, newValue);		}
	void SetFloat(GLint variable, float newValue)							{ glUniform1fARB(variable, newValue);		}
	void SetFloat2(GLint variable, float v0, float v1)						{ glUniform2fARB(variable, v0, v1);			}
	void SetFloat3(GLint variable, float v0, float v1, float v2)			{ glUniform3fARB(variable, v0, v1, v2);		}
	void SetFloat4(GLint variable, float v0, float v1, float v2, float v3)	{ glUniform4fARB(variable, v0, v1, v2, v3);	}

	// These 2 functions turn on and off our shader
	void TurnOn()		{	glUseProgramObjectARB(m_hProgramObject); }
	void TurnOff()		{	glUseProgramObjectARB(0);				 }
	
	// This releases our memory for our shader
	void Release();

	// check for errors
	bool checkProgramError();

private:

	// This handle stores our vertex shader information
	GLhandleARB m_hVertexShader;

	// This handle stores our fragment shader information
	GLhandleARB m_hFragmentShader;

	// This handle stores our program information which encompasses our shader
	GLhandleARB m_hProgramObject;
};

// This is used to load all of the extensions and checks compatibility.
bool InitGLSL();

#endif

