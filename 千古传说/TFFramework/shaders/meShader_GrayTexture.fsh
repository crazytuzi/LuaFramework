#ifdef GL_ES
precision lowp float;
#endif

varying vec2 v_texCoord;
uniform vec3 u_grayRate;
uniform sampler2D CC_Texture0;

void main() {
	vec4 color = texture2D(CC_Texture0, v_texCoord);
	float alpha = color.a;
	float gray = dot(color.rgb, u_grayRate);
	gl_FragColor = vec4(gray, gray, gray, alpha);
}
