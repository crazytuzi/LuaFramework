// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_colorOffset;
varying vec4 v_colorMutiple;

uniform sampler2D CC_Texture0;

void main() {
	vec4 tex = texture2D(CC_Texture0, v_texCoord);
   	float a = max(tex.a, 0.001);
    tex.rgb /= a;
	gl_FragColor = tex * v_colorMutiple + v_colorOffset;
}

