// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
 precision lowp float;
#endif


varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;

uniform vec2 textureSize;
uniform vec4 effectColor;
uniform float effectWidth;

vec4 getColor(vec2 texCoord)
{
	vec4 color = texture2D(CC_Texture0, texCoord);
	if(color.a <= 0.0)
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	return color;
}

void main() {
	vec4 sum = vec4(0.0);
	vec2 blurSize = vec2(1.0 / textureSize[0], 1.0 / textureSize[1]);
	float sumVal = 0.0;
	float num = effectWidth;
	float radius = 2.0 * (num + 1.0) * (num + 1.0);
	float temp = radius * acos(-1.0);
	float val;

	for(float i = 0.0; i <= num; i = i + 1.0)
	{
		for(float j = 0.0; j <= num; j = j + 1.0)
		{
			val = exp(-(i*i + j*j)/radius) / temp;
			if(i == 0.0 && j == 0.0)
			{
				sumVal = sumVal + val;
			}
			else if(i == 0.0)
			{
				sumVal = sumVal + 2.0 * val;
			}
			else if(j == 0.0)
			{
				sumVal = sumVal + 2.0 * val;
			}
			else
			{
				sumVal = sumVal + 4.0 * val;
			}
		}
	}

	temp = radius * acos(-1.0) * sumVal;

	for(float i = 0.0; i <= num; i = i + 1.0)
	{
		for(float j = 0.0; j <= num; j = j + 1.0)
		{
			val = exp(-(i*i + j*j)/radius) / temp;
			if(i == 0.0 && j == 0.0)
			{
				sum += getColor(v_texCoord) * val;
			}
			else if(i == 0.0)
			{
				sum += getColor(v_texCoord + vec2(i*blurSize[0], j*blurSize[1])) * val;
				sum += getColor(v_texCoord + vec2(i*blurSize[0], -j*blurSize[1])) * val;
			}
			else if(j == 0.0)
			{
				sum += getColor(v_texCoord + vec2(i*blurSize[0], j*blurSize[1])) * val;
				sum += getColor(v_texCoord + vec2(-i*blurSize[0], j*blurSize[1])) * val;
			}
			else
			{
				sum += getColor(v_texCoord + vec2(i*blurSize[0], j*blurSize[1])) * val;
				sum += getColor(v_texCoord + vec2(-i*blurSize[0], -j*blurSize[1])) * val;
				sum += getColor(v_texCoord + vec2(i*blurSize[0], -j*blurSize[1])) * val;
				sum += getColor(v_texCoord + vec2(-i*blurSize[0], j*blurSize[1])) * val;
			}
		}
	}
	sum.r = 1.0;
	sum.g = 0.0;
	sum.b = 0.0;
	if(sum.a <= 0.0)
		discard;
	vec4 vColor = texture2D(CC_Texture0, v_texCoord);
	gl_FragColor = vec4(sum.rgb * sum.a * (1.0-vColor.a), sum.a) + vColor * vColor.a;
}
