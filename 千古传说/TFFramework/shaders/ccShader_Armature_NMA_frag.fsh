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
	gl_FragColor = tex * v_colorMutiple + v_colorOffset;
}
