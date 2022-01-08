attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
attribute vec3 a_velocity;
attribute float a_breakTime;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump float v_time;
varying lowp float v_visible;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying float v_time;
varying float v_visible;
#endif

uniform float beginTime;
uniform float crushTime;
uniform vec4 boundaryVel;
uniform vec2 acceleration;
uniform vec2 totalScale;
uniform float pointSize;

void main()
{
	vec4 vert = a_position;
	float t = CC_Time[1] - beginTime;
	v_visible = 1.0;
	if( t > crushTime)
	{
		float ft = t - crushTime;
		float sft = ft * ft * 0.5;
		vert[0] = a_position[0] + a_velocity[0] * ft + acceleration[0] * sft;
		vert[1] = a_position[1] + a_velocity[1] * ft + acceleration[1] * sft;

        vert[0] /= totalScale[0];
        vert[1] /= totalScale[1];
        if(ft >= 0.55)
            v_visible = 0.0;
        else
            v_visible = 1.35;
        gl_PointSize = pointSize;
	}
    else
    {
        v_fragmentColor = a_color;
    }
	v_time = t / crushTime;
	vec4 temp = CC_MVPMatrix * vert;
    //temp[3] = temp[3] + 5.0;
	gl_Position = temp;
	v_texCoord = a_texCoord;
}