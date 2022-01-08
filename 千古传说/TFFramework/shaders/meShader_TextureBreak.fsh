#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying float v_time;
varying float v_visible;

uniform sampler2D CC_Texture0;
uniform vec4 textureRect;

void main()
{
	if(v_time < 1.0)
	{
		vec4 color = texture2D(CC_Texture0, v_texCoord);
	  	float grey = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	  	float v_Y = (v_texCoord.y - textureRect[1]) / (textureRect[3] - textureRect[1]);
	  	if(v_Y < v_time)
	    	gl_FragColor  =  vec4(grey,grey,grey,color.a);
	  	else
	  		gl_FragColor = color;
	}
	else
	{
		vec4 color = texture2D(CC_Texture0, v_texCoord);
		float grey = dot(color.rgb, vec3(0.299, 0.587, 0.114));
		gl_FragColor = vec4(grey, grey, grey, color.a) * v_visible;
	}
}
