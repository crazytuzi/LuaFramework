#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying float v_time;

uniform sampler2D CC_Texture0;
uniform vec4 textureRect;

void main()
{
	vec4 color = texture2D(CC_Texture0, v_texCoord);
  	if(v_texCoord[0] < 0.0 || v_texCoord[1] < 0.0)
	{
		color = vec4(1.0, 1.0, 1.0, 1.0);
	}
	gl_FragColor = color * v_fragmentColor;
}
