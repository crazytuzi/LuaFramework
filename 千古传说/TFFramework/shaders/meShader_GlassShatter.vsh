attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
attribute vec3 a_beginDis;
attribute vec3 a_velocity;
#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump float v_time;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying float v_time;
#endif

void main()
{
	vec4 vert = a_position;

	vert[0] = a_position[0] + a_beginDis[0];
	vert[1] = a_position[1] + a_beginDis[1];
	//vert[2] = a_position[1];// + a_beginDis[2];
    gl_Position = CC_MVPMatrix * vert;
	v_fragmentColor = a_color;
	v_texCoord = a_texCoord;
}