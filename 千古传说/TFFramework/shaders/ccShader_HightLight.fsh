// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;

void main() {
	vec4 tex = texture2D(CC_Texture0, v_texCoord);
	if (tex.r == 0.0 && tex.g == 0.0 && tex.b == 0.0 && tex.a > 0.8)
	{
		tex.r = tex.g = tex.b = 0.1;
	}
	tex *= 1.5;
	gl_FragColor = tex;
}

