
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
attribute vec4 a_colorOffset;
attribute vec4 a_colorMutiple;
#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying lowp vec4 v_colorOffset;
varying lowp vec4 v_colorMutiple;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_colorOffset;
varying vec4 v_colorMutiple;
#endif

void main()
{
    gl_Position = CC_MVPMatrix * a_position;
	v_fragmentColor = a_color;
	v_texCoord = a_texCoord;
	v_colorOffset = v_fragmentColor * a_colorOffset;
	v_colorMutiple = v_fragmentColor * a_colorMutiple;
    
}

