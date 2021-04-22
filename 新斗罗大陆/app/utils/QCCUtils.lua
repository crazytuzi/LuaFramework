
qShader = qShader or {}
--[[
	由于ETC1和flash变色改变了默认的shader，所有这里使用一个map来保存以便于ETC1等灰化后再变正常时，shader不正确。
--]]
local previousShaderDict = {}

qShader.kCCVertexAttrib_Position    = 0
qShader.kCCVertexAttrib_Color       = 1
qShader.kCCVertexAttrib_TexCoords   = 2
qShader.kCCVertexAttrib_Color2		= 3
qShader.kCCVertexAttrib_MAX         = 4

qShader.kCCUniformPMatrix           = 0
qShader.kCCUniformMVMatrix          = 1
qShader.kCCUniformMVPMatrix         = 2
qShader.kCCUniformTime              = 3
qShader.kCCUniformSinTime           = 4
qShader.kCCUniformCosTime           = 5
qShader.kCCUniformRandom01          = 6
qShader.kCCUniformSampler           = 7
qShader.kCCUniform_MAX              = 8

-- default shader key
qShader.kCCShader_ETC1ASPositionTextureColorEffect 		="#ShaderETC1ASPositionTextureColorEffect"
qShader.kCCShader_ETC1ASPositionTextureColor       		="#ShaderETC1ASPositionTextureColor"
qShader.kCCShader_PositionTextureColorEffect       		="ShaderPositionTextureColorEffect"
qShader.kCCShader_PositionTextureColor             		="ShaderPositionTextureColor"
qShader.kCCShader_PositionTextureGray              		="ShaderPositionTextureGray"
qShader.kCCShader_PositionTextureColorAlphaTest    		="ShaderPositionTextureColorAlphaTest"
qShader.kCCShader_ETC1ASPositionTextureColorAlphaTest   	="ShaderETC1ASPositionTextureColorAlphaTest"
qShader.kCCShader_PositionColor                    		="ShaderPositionColor"
qShader.kCCShader_PositionTexture                  		="ShaderPositionTexture"
qShader.kCCShader_PositionTexture_uColor           		="ShaderPositionTexture_uColor"
qShader.kCCShader_PositionTextureA8Color           		="ShaderPositionTextureA8Color"
qShader.kCCShader_Position_uColor                  		="ShaderPosition_uColor"
qShader.kCCShader_PositionLengthTexureColor        		="ShaderPositionLengthTextureColor"
qShader.kCCShader_ControlSwitch                    		="Shader_ControlSwitch"
qShader.kCCShader_PositionTextureGrayETC1               ="#ShaderETC1ASPositionTextureGray"
-- custom shader key
qShader.kQShader_PositionTextureGray               		="QShader_PositionTextureGray"
qShader.kQShader_PositionTextureGrayStone          		="QShader_PositionTextureGrayStone"
qShader.kQShader_PositionTextureGrayStoneETC          		="QShader_PositionTextureGrayStoneETC"
qShader.kQShader_PositionTextureGrayLuminance      		="QShader_PositionTextureGrayLuminance"
qShader.kQShader_PositionTextureGrayLuminanceAlpha 		="kQShader_PositionTextureGrayLuminanceAlpha"
qShader.kQShader_PositionTextureColorOutline	   		="kQShader_PositionTextureColorOutline"
qShader.kQShader_PositionTextureColorOutlineWeak   		="kQShader_PositionTextureColorOutlineWeak"
qShader.kQShader_PositionTextureColorOutlineWeakETC   		="kQShader_PositionTextureColorOutlineWeakETC"
qShader.kQShader_PositionTextureColorInsideLight   		="kQShader_PositionTextureColorOutlineWeakGreen"
qShader.kQShader_PositionTextureHSI		   		="kQShader_PositionTextureHSI"
qShader.kQShader_PositionTextureColorHSI		   	="kQShader_PositionTextureColorHSI"
qShader.kQShader_PositionTextureColorHSIETC		   	="kQShader_PositionTextureColorHSIETC"
qShader.kQShader_PositionTextureColorHead		   	="kQShader_PositionTextureColorHead"
qShader.kQShader_PositionTextureColorRectangle		   	="kQShader_PositionTextureColorRectangle"
qShader.kQShader_PositionTextureColorRectangleETC		   	="kQShader_PositionTextureColorRectangleETC"
qShader.kQShader_PositionTextureColorHeadETC		   	="kQShader_PositionTextureColorHeadETC"
qShader.kQShader_PositionTextureColorCircle		   	="kQShader_PositionTextureColorCircle"
qShader.kQShader_PositionTextureColorCircleETC		   	="kQShader_PositionTextureColorCircleETC"
qShader.kQShader_PositionTextureColorBar		   	="kQShader_PositionTextureColorBar"
qShader.kQShader_PositionTextureColorBarETC		   	="kQShader_PositionTextureColorBarETC"
qShader.kQShader_PositionTextureColorBarRevers		   	="kQShader_PositionTextureColorBarRevers"
qShader.kQShader_PositionTextureColorBarReversETC		   	="kQShader_PositionTextureColorBarReversETC"
qShader.kQShader_TTFOutline					="kQShader_TTFOutline"
qShader.kQShader_ColorLayer					="kQShader_ColorLayer"	
qShader.kQShader_CircleOuterStencil				="kQShader_CircleOuterStencil"	
qShader.kQShader_Glow						="kQShader_Glow"						
qShader.kQShader_PositionTextureColorAlphaTestEffect    	="kQShader_PositionTextureColorAlphaTestEffect"	
qShader.kQShader_PositionTextureOldPhoto    	="kQShader_PositionTextureOldPhoto"		
qShader.kQShader_PositionTextureShadowBlur 		="kQShader_PositionTextureShadowBlur"		
qShader.kQShader_PositionTextureShadow			="kQShader_PositionTextureShadow"		
qShader.kQShader_PositionTextureScanning		="kQShader_PositionTextureScanning"		
qShader.kQShader_PositionTextureScanningETC		="kQShader_PositionTextureScanningETC"		
qShader.kQShader_PositionTextureColorHeadGray		="kQShader_PositionTextureColorHeadGray"		
qShader.kQShader_PositionTextureColorHeadGrayETC		="kQShader_PositionTextureColorHeadGrayETC"		
qShader.kQShader_PositionTextureColorCircleGray		="kQShader_PositionTextureColorCircleGray"		
qShader.kQShader_PositionTextureColorCircleGrayETC		="kQShader_PositionTextureColorCircleGrayETC"		

-- uniform names
qShader.kCCUniformPMatrix_s            				="CC_PMatrix"
qShader.kCCUniformMVMatrix_s           				="CC_MVMatrix"
qShader.kCCUniformMVPMatrix_s          				="CC_MVPMatrix"
qShader.kCCUniformTime_s               				="CC_Time"
qShader.kCCUniformSinTime_s            				="CC_SinTime"
qShader.kCCUniformCosTime_s            				="CC_CosTime"
qShader.kCCUniformRandom01_s           				="CC_Random01"
qShader.kCCUniformSampler_s            				="CC_Texture0"
qShader.kCCUniformSampler1_s            			="CC_Texture1"
qShader.kCCUniformAlphaTestValue       				="CC_alpha_value"

-- Attribute names
qShader.kCCAttributeNameColor          				="a_color"
qShader.kCCAttributeNamePosition       				="a_position"
qShader.kCCAttributeNameTexCoord       				="a_texCoord"
qShader.kCCAttribuetNameColor2		   				="a_color2"

-- ETC1扩展
qShader.CC_ProgramETC1ASPositionTextureColorEffect = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_ETC1ASPositionTextureColorEffect);
qShader.CC_ProgramETC1ASPositionTextureColor = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_ETC1ASPositionTextureColor);
-- flash变色支持
qShader.CC_ProgramPositionTextureColorEffect = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_PositionTextureColorEffect);

qShader.CC_ProgramPositionTextureColor = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_PositionTextureColor);
qShader.CC_ProgramPositionTextureGray = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_PositionTextureGray);
qShader.Q_ProgramPositionTextureGray = nil
qShader.Q_ProgramPositionTextureGrayETC1 = CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_PositionTextureGrayETC1);
qShader.Q_ProgramPositionTextureGrayStone = nil
qShader.Q_ProgramPositionTextureGrayStoneETC = nil
qShader.Q_ProgramPositionTextureGrayLuminance = nil
qShader.Q_ProgramPositionTextureGrayLuminanceAlpha = nil
qShader.Q_ProgramPositionTextureColorOutline = nil
qShader.Q_ProgramPositionTextureColorOutlineWeak = nil
qShader.Q_ProgramPositionTextureColorOutlineWeakETC = nil
qShader.Q_ProgramPositionTextureColorInsideLight = nil
qShader.Q_ProgramPositionTextureHSI = nil
qShader.Q_ProgramPositionTextureColorHSI = nil
qShader.Q_ProgramPositionTextureColorHSIETC = nil
qShader.Q_ProgramPositionTextureColorHead = nil
qShader.Q_ProgramPositionTextureColorHeadETC = nil
qShader.Q_ProgramPositionTextureColorRectangle = nil
qShader.Q_ProgramPositionTextureColorRectangleETC = nil
qShader.Q_ProgramPositionTextureColorCircle = nil
qShader.Q_ProgramPositionTextureColorCircleETC = nil
qShader.Q_ProgramPositionTextureColorBar = nil
qShader.Q_ProgramPositionTextureColorBarETC = nil
qShader.Q_ProgramPositionTextureColorBarRevers = nil
qShader.Q_ProgramPositionTextureColorBarReversETC = nil
qShader.Q_ProgramTTFOutline = nil
qShader.Q_ProgramColorLayer = nil
qShader.Q_ProgramCircleOuterStencil = nil
qShader.Q_ProgramGlow = nil
qShader.Q_ProgramPositionTextureAlphaTestEffect = nil
qShader.Q_ProgramPositionTextureAlphaTestETC1 = nil
qShader.Q_ProgramPositionTextureOldPhoto = nil
qShader.Q_ProgramPositionTextureShadowBlur = nil
qShader.Q_ProgramPositionTextureShadow = nil
qShader.Q_ProgramPositionTextureScanning = nil
qShader.Q_ProgramPositionTextureScanningETC = nil
qShader.Q_ProgramPositionTextureColorHeadGray = nil
qShader.Q_ProgramPositionTextureColorHeadGrayETC = nil
qShader.Q_ProgramPositionTextureColorCircleGray = nil
qShader.Q_ProgramPositionTextureColorCircleGrayETC = nil

qShader.QPositionTextureColor_vert = "				\n\
attribute vec4 a_position;							\n\
attribute vec2 a_texCoord;							\n\
attribute vec4 a_color;								\n\
													\n\
#ifdef GL_ES										\n\
varying lowp vec4 v_fragmentColor;					\n\
varying mediump vec2 v_texCoord;					\n\
#else												\n\
varying vec4 v_fragmentColor;						\n\
varying vec2 v_texCoord;							\n\
#endif												\n\
													\n\
void main()											\n\
{													\n\
    gl_Position = CC_MVPMatrix * a_position;		\n\
	v_fragmentColor = a_color;						\n\
	v_texCoord = a_texCoord;						\n\
}													\n\
"

qShader.QPositionTextureGray_frag = "                 				\n\
#ifdef GL_ES                                						\n\
precision mediump float;                    						\n\
#endif                                      						\n\
																	\n\
uniform sampler2D u_texture;                						\n\
varying vec2 v_texCoord;                    						\n\
varying vec4 v_fragmentColor;               						\n\
																	\n\
void main(void)                             						\n\
{                                           						\n\
	// Convert to greyscale using NTSC weightings               	\n\
	vec4 col = texture2D(u_texture, v_texCoord);                	\n\
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));       	\n\
	gl_FragColor = vec4(grey, grey, grey, col.a) * v_fragmentColor;	\n\
}                                           						\n\
"

qShader.QPositionTextureGrayETC1_frag = "                 				\n\
#ifdef GL_ES                                						\n\
precision mediump float;                    						\n\
#endif                                      						\n\
																	\n\
uniform sampler2D CC_Texture0;                						\n\
uniform sampler2D CC_Texture1;										\n\
varying vec2 v_texCoord;                    						\n\
varying vec4 v_fragmentColor;               						\n\
																	\n\
void main(void)                             						\n\
{                                           						\n\
    vec4 texColor = vec4(texture2D(CC_Texture0, v_texCoord).rgb, texture2D(CC_Texture1, v_texCoord).r);			\n\
    																\n\
    texColor.rgb *= texColor.a; // Premultiply with Alpha channel	\n\
	float grey = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));      \n\
    gl_FragColor = vec4(grey, grey, grey, texColor.a) * v_fragmentColor;	\n\
}                                           						\n\
"

qShader.QPositionTextureGrayStone_frag = "                 			\n\
#ifdef GL_ES                                						\n\
precision mediump float;                    						\n\
#endif                                      						\n\
																	\n\
uniform sampler2D u_texture;                						\n\
varying vec2 v_texCoord;                    						\n\
varying vec4 v_fragmentColor;               						\n\
																	\n\
void main(void)                             						\n\
{                                           						\n\
	// Convert to greyscale using NTSC weightings               	\n\
	vec4 col = texture2D(u_texture, v_texCoord);                	\n\
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));       	\n\
	gl_FragColor = vec4(grey * 0.333, grey * 0.333, grey * 0.333, col.a) * v_fragmentColor;	\n\
}                                           						\n\
"

qShader.QPositionTextureGrayStoneETC_frag = "						\n\
#ifdef GL_ES														\n\
    precision mediump float;										\n\
#endif																\n\
                                                                    \n\
uniform sampler2D CC_Texture0;                                      \n\
uniform sampler2D CC_Texture1;                                      \n\
    																\n\
varying vec4 v_fragmentColor;										\n\
varying vec2 v_texCoord;											\n\
																	\n\
void main(void)															\n\
{																	\n\
    vec4 texColor = texture2D(CC_Texture0, v_texCoord);				\n\
    texColor.a = texture2D(CC_Texture1, v_texCoord).r;				\n\
    texColor.rgb *= texColor.a; // premultiply alpha channel		\n\
    																\n\
    float grey = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));           \n\
    																\n\
    gl_FragColor = vec4(grey * 0.333, grey * 0.333, grey * 0.333, texColor.a) * v_fragmentColor;	\n\
}																	\n\
"

qShader.QPositionTextureGrayLuminance_frag = "                 					\n\
#ifdef GL_ES                                									\n\
precision mediump float;                    									\n\
#endif                                      									\n\
																				\n\
uniform sampler2D u_texture;                									\n\
varying vec2 v_texCoord;                    									\n\
varying vec4 v_fragmentColor;               									\n\
																				\n\
void main(void)                             									\n\
{                                           									\n\
	// Convert to greyscale using NTSC weightings               				\n\
	vec4 col = texture2D(u_texture, v_texCoord);                				\n\
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));       				\n\
	vec3 displayColor = v_fragmentColor.rgb * v_fragmentColor.aaa;  			\n\
	gl_FragColor = vec4(grey, grey, grey, col.a) * vec4(displayColor.rgb, 1.0);	\n\
}                                           									\n\
"

qShader.QPositionTextureColorOutline_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform sampler2D CC_Texture0;				\n\
const float step1 = 0.003;					\n\
const float step2 = 0.006;					\n\
const float step3 = 0.009;					\n\
const float step4 = 0.012;					\n\
											\n\
void main()									\n\
{											\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
	if (normal.a < 0.5) \n\
	{ \n\
		vec4 ot = vec4(0.0, 0.0, 0.0, 0.0); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step1, v_texCoord.t - step1)); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step1, v_texCoord.t + step1)); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step1, v_texCoord.t - step1)); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step1, v_texCoord.t + step1)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step2, v_texCoord.t - step2)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step2, v_texCoord.t + step2)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step2, v_texCoord.t - step2)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step2, v_texCoord.t + step2)); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step3, v_texCoord.t - step3)); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step3, v_texCoord.t + step3)); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step3, v_texCoord.t - step3)); \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step3, v_texCoord.t + step3)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step4, v_texCoord.t - step4)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step4, v_texCoord.t + step4)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step4, v_texCoord.t - step4)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step4, v_texCoord.t + step4)); \n\
		ot = ot / 10.0; \n\
		if (ot.a > 0.01) \n\
		{  \n\
			gl_FragColor = vec4(0.937255, 0.843137, 0.0, 5.0 * ot.a); \n\
		}  \n\
		else \n\
			gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); \n\
	} \n\
	else \n\
		gl_FragColor = v_fragmentColor * normal; \n\
}											\n\
"

qShader.QPositionTextureColorOutlineWeak_frag = " \n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform sampler2D CC_Texture0;				\n\
//const float _step1 = 0.002;					\n\
//const float _step2 = 0.004;					\n\
//const float _step3 = 0.006;					\n\
//const float _step4 = 0.008;					\n\
											\n\
void main()									\n\
{											\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
	if (normal.a < 0.05) \n\
	{ \n\
		float ot = 0.0; \n\
		float wstep1 = v_fragmentColor.a * 0.025; \n\
		float wstep2 = v_fragmentColor.a * 0.050; \n\
		float wstep3 = v_fragmentColor.a * 0.075; \n\
		float wstep4 = v_fragmentColor.a * 0.100; \n\
		float hstep1 = v_fragmentColor.a * 0.025; \n\
		float hstep2 = v_fragmentColor.a * 0.050; \n\
		float hstep3 = v_fragmentColor.a * 0.075; \n\
		float hstep4 = v_fragmentColor.a * 0.100; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep1 * 0.7, v_texCoord.t - hstep1 * 0.7)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep1 * 0.7, v_texCoord.t + hstep1 * 0.7)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep1 * 0.7, v_texCoord.t - hstep1 * 0.7)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep1 * 0.7, v_texCoord.t + hstep1 * 0.7)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep1, v_texCoord.t)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep1, v_texCoord.t)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t - hstep1)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t + hstep1)).a * 0.5; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep2 * 0.7, v_texCoord.t - hstep2 * 0.7)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep2 * 0.7, v_texCoord.t + hstep2 * 0.7)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep2 * 0.7, v_texCoord.t - hstep2 * 0.7)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep2 * 0.7, v_texCoord.t + hstep2 * 0.7)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep2, v_texCoord.t)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep2, v_texCoord.t)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t - hstep2)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t + hstep2)).a * 0.25; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep3 * 0.7, v_texCoord.t - hstep3 * 0.7)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep3 * 0.7, v_texCoord.t + hstep3 * 0.7)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep3 * 0.7, v_texCoord.t - hstep3 * 0.7)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep3 * 0.7, v_texCoord.t + hstep3 * 0.7)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep3, v_texCoord.t)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep3, v_texCoord.t)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t - hstep3)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t + hstep3)).a * 0.125; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep4 * 0.7, v_texCoord.t - hstep4 * 0.7)).a * 0.0625; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep4 * 0.7, v_texCoord.t + hstep4 * 0.7)).a * 0.0625; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep4 * 0.7, v_texCoord.t - hstep4 * 0.7)).a * 0.0625; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep4 * 0.7, v_texCoord.t + hstep4 * 0.7)).a * 0.0625; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - wstep4, v_texCoord.t)).a * 0.0625; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + wstep4, v_texCoord.t)).a * 0.0625; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t - hstep4)).a * 0.0625; \n\
		ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s, v_texCoord.t + hstep4)).a * 0.0625; \n\
		gl_FragColor = vec4(0.996078, 1.0, 0.741176, ot); \n\
	} \n\
	else \n\
	{\n\
		gl_FragColor = vec4(v_fragmentColor.rgb * normal.rgb, normal.a) + vec4(0.996078, 1.0, 0.741176, 1.0) * (1.0 - normal.a);\n\
	}\n\
}											\n\
" 
qShader.QPositionTextureColorOutlineWeakETC_frag = " \n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform sampler2D CC_Texture0;				\n\
uniform sampler2D CC_Texture1;              \n\
											\n\
void main()									\n\
{											\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
    normal.a = texture2D(CC_Texture1, v_texCoord).r;				\n\
    normal.rgb *= normal.a; // premultiply alpha channel		\n\
	if (normal.a < 0.05) \n\
	{ \n\
		float ot = 0.0; \n\
		float wstep1 = v_fragmentColor.a * 0.025; \n\
		float wstep2 = v_fragmentColor.a * 0.050; \n\
		float wstep3 = v_fragmentColor.a * 0.075; \n\
		float wstep4 = v_fragmentColor.a * 0.100; \n\
		float hstep1 = v_fragmentColor.a * 0.025; \n\
		float hstep2 = v_fragmentColor.a * 0.050; \n\
		float hstep3 = v_fragmentColor.a * 0.075; \n\
		float hstep4 = v_fragmentColor.a * 0.100; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep1 * 0.7, v_texCoord.t - hstep1 * 0.7)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep1 * 0.7, v_texCoord.t + hstep1 * 0.7)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep1 * 0.7, v_texCoord.t - hstep1 * 0.7)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep1 * 0.7, v_texCoord.t + hstep1 * 0.7)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep1, v_texCoord.t)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep1, v_texCoord.t)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t - hstep1)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t + hstep1)).r * 0.5; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep2 * 0.7, v_texCoord.t - hstep2 * 0.7)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep2 * 0.7, v_texCoord.t + hstep2 * 0.7)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep2 * 0.7, v_texCoord.t - hstep2 * 0.7)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep2 * 0.7, v_texCoord.t + hstep2 * 0.7)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep2, v_texCoord.t)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep2, v_texCoord.t)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t - hstep2)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t + hstep2)).r * 0.25; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep3 * 0.7, v_texCoord.t - hstep3 * 0.7)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep3 * 0.7, v_texCoord.t + hstep3 * 0.7)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep3 * 0.7, v_texCoord.t - hstep3 * 0.7)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep3 * 0.7, v_texCoord.t + hstep3 * 0.7)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep3, v_texCoord.t)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep3, v_texCoord.t)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t - hstep3)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t + hstep3)).r * 0.125; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep4 * 0.7, v_texCoord.t - hstep4 * 0.7)).r * 0.0625; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep4 * 0.7, v_texCoord.t + hstep4 * 0.7)).r * 0.0625; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep4 * 0.7, v_texCoord.t - hstep4 * 0.7)).r * 0.0625; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep4 * 0.7, v_texCoord.t + hstep4 * 0.7)).r * 0.0625; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s - wstep4, v_texCoord.t)).r * 0.0625; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s + wstep4, v_texCoord.t)).r * 0.0625; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t - hstep4)).r * 0.0625; \n\
		ot = ot + texture2D(CC_Texture1, vec2(v_texCoord.s, v_texCoord.t + hstep4)).r * 0.0625; \n\
		gl_FragColor = vec4(0.996078, 1.0, 0.741176, ot); \n\
	} \n\
	else \n\
	{\n\
		gl_FragColor = vec4(v_fragmentColor.rgb * normal.rgb, normal.a) + vec4(0.996078, 1.0, 0.741176, 1.0) * (1.0 - normal.a);\n\
	}\n\
}											\n\
"

qShader.QPositionTextureColorInsideLight = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform sampler2D CC_Texture0;				\n\
const float step1 = 0.0;					\n\
const float step2 = 0.0;					\n\
const float step3 = 0.0;					\n\
const float step4 = 0.0;					\n\
											\n\
void main()									\n\
{											\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
	if (normal.a < 0.8) \n\
	{ \n\
		vec4 ot = vec4(0.0, 0.0, 0.0, 0.0); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step1, v_texCoord.t - step1)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step1, v_texCoord.t + step1)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step1, v_texCoord.t - step1)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step1, v_texCoord.t + step1)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step2, v_texCoord.t - step2)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step2, v_texCoord.t + step2)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step2, v_texCoord.t - step2)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step2, v_texCoord.t + step2)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step3, v_texCoord.t - step3)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step3, v_texCoord.t + step3)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step3, v_texCoord.t - step3)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step3, v_texCoord.t + step3)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step4, v_texCoord.t - step4)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s - step4, v_texCoord.t + step4)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step4, v_texCoord.t - step4)); \n\
	//	ot = ot + texture2D(CC_Texture0, vec2(v_texCoord.s + step4, v_texCoord.t + step4)); \n\
	//	ot = ot / 20.0; \n\
		if (ot.a > 0.2) \n\
		{  \n\
	//		gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0 * ot.a); \n\
			gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); \n\
		}  \n\
		else \n\
			gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); \n\
	} \n\
	else \n\
	{\n\
		gl_FragColor = v_fragmentColor * normal; \n\
		gl_FragColor = gl_FragColor + vec4(0.5, 0.5, 0.5, 0.0); \n\
	}\n\
}											\n\
"

qShader.QPositionTextureColorHSI_vert = "				\n\
attribute vec4 a_position;							\n\
attribute vec2 a_texCoord;							\n\
attribute vec4 a_color;								\n\
attribute vec4 a_color2;							\n\
													\n\
#ifdef GL_ES										\n\
varying lowp vec4 v_fragmentColor;					\n\
varying lowp vec4 v_fragmentColor2;					\n\
varying mediump vec2 v_texCoord;					\n\
#else												\n\
varying vec4 v_fragmentColor;						\n\
varying vec4 v_fragmentColor2;						\n\
varying vec2 v_texCoord;							\n\
#endif												\n\
													\n\
void main()											\n\
{													\n\
    gl_Position = CC_MVPMatrix * a_position;		\n\
	v_fragmentColor = a_color;						\n\
	v_fragmentColor2 = a_color2;					\n\
	v_texCoord = a_texCoord;						\n\
}													\n\
"

qShader.QPositionTextureColorHSI_frag = "																					\n\
#ifdef GL_ES																												\n\
precision lowp float;																										\n\
#endif																														\n\
																															\n\
varying vec4 v_fragmentColor;																								\n\
varying vec4 v_fragmentColor2;// r for hue, g for saturation ratio, b for intensity ratio									\n\
varying vec2 v_texCoord;																									\n\
uniform	sampler2D CC_Texture0;																								\n\
const mat3 rgb2yiq = mat3(0.299, 0.587, 0.114, 0.595716, -0.274453, -0.321263, 0.211456, -0.522591, 0.311135);				\n\
const mat3 yiq2rgb = mat3(1.0, 0.9563, 0.6210, 1.0, -0.2721, -0.6474, 1.0, -1.1070, 1.7046);								\n\
const float PI = 3.14159;																									\n\
																															\n\
void main() 																												\n\
{																															\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord);																		\n\
	vec3 yColor = rgb2yiq * normal.rgb;																						\n\
	float originalHue = atan(yColor.b, yColor.g);																			\n\
	float chroma = sqrt(yColor.b * yColor.b + yColor.g * yColor.g);															\n\
																															\n\
	float finalHue = PI * (2.0 * v_fragmentColor2.r - 1.0);																	\n\
	chroma = chroma * pow(2.0, (v_fragmentColor2.g - 0.5) * 4.0); 															\n\
	yColor.r = yColor.r * pow(2.0, (v_fragmentColor2.b - 0.5) * 4.0);														\n\
	vec3 yFinalColor = vec3(yColor.r, chroma * cos(finalHue), chroma * sin(finalHue));										\n\
	yFinalColor = yiq2rgb * yFinalColor;																					\n\
	gl_FragColor.rgb = yFinalColor * v_fragmentColor.rgb;																	\n\
	gl_FragColor.a = normal.a * v_fragmentColor.a;																			\n\
}																															\n\
"

qShader.QPositionTextureColorHSIETC_frag = [[
#ifdef GL_ES
precision lowp float;
#endif
varying vec4 v_fragmentColor;																								
varying vec4 v_fragmentColor2;// r for hue, g for saturation ratio, b for intensity ratio									
varying vec2 v_texCoord;																									
uniform	sampler2D CC_Texture0;																								
uniform sampler2D CC_Texture1;																							
const mat3 rgb2yiq = mat3(0.299, 0.587, 0.114, 0.595716, -0.274453, -0.321263, 0.211456, -0.522591, 0.311135);				
const mat3 yiq2rgb = mat3(1.0, 0.9563, 0.6210, 1.0, -0.2721, -0.6474, 1.0, -1.1070, 1.7046);								
const float PI = 3.14159;																									
																															
void main() 																												
{																															
	vec4 normal = texture2D(CC_Texture0, v_texCoord);																		
	normal.a = texture2D(CC_Texture1, v_texCoord).r;
	vec3 yColor = rgb2yiq * normal.rgb;																						
	float originalHue = atan(yColor.b, yColor.g);																			
	float chroma = sqrt(yColor.b * yColor.b + yColor.g * yColor.g);															
																															
	float finalHue = PI * (2.0 * v_fragmentColor2.r - 1.0);																	
	chroma = chroma * pow(2.0, (v_fragmentColor2.g - 0.5) * 4.0); 															
	yColor.r = yColor.r * pow(2.0, (v_fragmentColor2.b - 0.5) * 4.0);														
	vec3 yFinalColor = vec3(yColor.r, chroma * cos(finalHue), chroma * sin(finalHue));										
	yFinalColor = yiq2rgb * yFinalColor;																					
	gl_FragColor.rgb = yFinalColor * v_fragmentColor.rgb;																	
	gl_FragColor.a = normal.a * v_fragmentColor.a;																			
}																		
]]

qShader.QPositionTextureHSI_frag = "																					\n\
#ifdef GL_ES																												\n\
precision lowp float;																										\n\
#endif																														\n\
																															\n\
varying vec4 v_fragmentColor;//r for hue, g for saturation ratio, b for intensity ratio										\n\
varying vec2 v_texCoord;																									\n\
uniform	sampler2D CC_Texture0;																								\n\
const mat3 rgb2yiq = mat3(0.299, 0.587, 0.114, 0.595716, -0.274453, -0.321263, 0.211456, -0.522591, 0.311135);				\n\
const mat3 yiq2rgb = mat3(1.0, 0.9563, 0.6210, 1.0, -0.2721, -0.6474, 1.0, -1.1070, 1.7046);								\n\
const float PI = 3.14159;																									\n\
																															\n\
void main() 																												\n\
{																															\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord);																		\n\
	vec3 yColor = rgb2yiq * normal.rgb;																						\n\
	float originalHue = atan(yColor.b, yColor.g);																			\n\
	float chroma = sqrt(yColor.b * yColor.b + yColor.g * yColor.g);															\n\
																															\n\
	float finalHue = PI * (2.0 * v_fragmentColor.r - 1.0);																	\n\
	chroma = chroma * pow(2.0, (v_fragmentColor.g - 0.5) * 4.0); 															\n\
	yColor.r = yColor.r * pow(2.0, (v_fragmentColor.b - 0.5) * 4.0);														\n\
	vec3 yFinalColor = vec3(yColor.r, chroma * cos(finalHue), chroma * sin(finalHue));										\n\
	gl_FragColor.rgb = yiq2rgb * yFinalColor;																				\n\
	gl_FragColor.a = normal.a * v_fragmentColor.a;																			\n\
}																															\n\
"

-- qShader.QPositionTextureHueShift_frag = "																					\n\
-- #ifdef GL_ES																												\n\
-- precision lowp float;																										\n\
-- #endif																														\n\
-- 																															\n\
-- varying vec4 v_fragmentColor;																								\n\
-- varying vec2 v_texCoord;																									\n\
-- uniform	vec4 u_color; // u_color.r is hue shift 																			\n\
-- uniform	sampler2D CC_Texture0;																								\n\
-- const mat3 rgb2yiq = mat3(0.299, 0.587, 0.114, 0.595716, -0.274453, -0.321263, 0.211456, -0.522591, 0.311135);				\n\
-- const mat3 yiq2rgb = mat3(1.0, 0.9563, 0.6210, 1.0, -0.2721, -0.6474, 1.0, -1.1070, 1.7046);								\n\
-- const float PI = 3.14159;																									\n\
-- const float PI2 = 3.14159 * 2.0;																							\n\
-- 																															\n\
-- void main() 																												\n\
-- {																															\n\
-- 	vec4 normal = texture2D(CC_Texture0, v_texCoord);																		\n\
-- 	vec3 yColor = rgb2yiq * normal.rgb;																						\n\
-- 																															\n\
-- 	float hueshift = PI2 * v_fragmentColor.r - PI;																			\n\
-- 	float coshue = cos(hueshift);																							\n\
-- 	float sinhue = sin(hueshift);																							\n\
-- 																															\n\
-- 	gl_FragColor.rgb = yiq2rgb * vec3(yColor.r, mat2(coshue, -sinhue, sinhue, coshue) * yColor.gb);							\n\
-- 	gl_FragColor.a = normal.a;																								\n\
-- }																															\n\
-- "

qShader.QPositionTextureColorHead_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
void main()									\n\
{											\n\
	float f = ceil(v_fragmentColor.a - abs(v_texCoord.x - v_texCoord.y)); \n\
	gl_FragColor = texture2D(CC_Texture0, v_texCoord) * vec4(f, f, f, f);			\n\
}											\n\
";

qShader.QPositionTextureColorHeadETC_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
uniform sampler2D CC_Texture1;				\n\
											\n\
void main()									\n\
{											\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
    normal.a = texture2D(CC_Texture1, v_texCoord).r;				\n\
    normal.rgb *= normal.a; // premultiply alpha channel		\n\
	float f = ceil(v_fragmentColor.a - abs(v_texCoord.x - v_texCoord.y)); \n\
	gl_FragColor = normal * vec4(f, f, f, f);			\n\
}											\n\
";

qShader.QPositionTextureColorRectangle_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
void main()									\n\
{											\n\
	float fx = ceil(v_fragmentColor.r - v_texCoord.x); \n\
	float fy = ceil(v_fragmentColor.g - v_texCoord.y); \n\
	float f = min(fx, fy);   \n\
	gl_FragColor = texture2D(CC_Texture0, v_texCoord) * vec4(f, f, f, f);			\n\
}											\n\
";

qShader.QPositionTextureColorRectangleETC_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
uniform sampler2D CC_Texture1;				\n\
											\n\
void main()									\n\
{											\n\
	float fx = ceil(v_fragmentColor.r - v_texCoord.x); \n\
	float fy = ceil(v_fragmentColor.g - v_texCoord.y); \n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); 	\n\
    normal.a = texture2D(CC_Texture1, v_texCoord).r;				\n\
    normal.rgb *= normal.a; // premultiply alpha channel		\n\
	float f = min(fx, fy);   \n\
	gl_FragColor = normal * vec4(f, f, f, f);			\n\
}											\n\
";

qShader.QPositionTextureColorCircle_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
void main()									\n\
{											\n\
	float f = ceil(0.5 - distance(v_texCoord, vec2(0.5, 0.5))); 					\n\
	gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord) * vec4(f, f, f, f);			\n\
}											\n\
";

qShader.QPositionTextureColorCircleETC_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
uniform sampler2D CC_Texture1;				\n\
											\n\
void main()									\n\
{											\n\
	float f = ceil(0.5 - distance(v_texCoord, vec2(0.5, 0.5))); 					\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
    normal.a = texture2D(CC_Texture1, v_texCoord).r;				\n\
    normal.rgb *= normal.a; // premultiply alpha channel		\n\
	gl_FragColor = v_fragmentColor * normal * vec4(f, f, f, f);			\n\
}											\n\
";

qShader.QPositionTextureColorBar_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
void main()									\n\
{											\n\
	float x1 = 1.0 - v_fragmentColor.g;		\n\
	float x2 = v_fragmentColor.b; 			\n\
	float f = min(1.0, ceil(v_fragmentColor.r - (v_texCoord.x - x1) / (x2 - x1))); \n\
	gl_FragColor = texture2D(CC_Texture0, v_texCoord) * (vec4(f, f, f, f) * v_fragmentColor.a);			\n\
}											\n\
";

qShader.QPositionTextureColorBarETC_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
uniform sampler2D CC_Texture1;				\n\
											\n\
void main()									\n\
{											\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
    normal.a = texture2D(CC_Texture1, v_texCoord).r;				\n\
    normal.rgb *= normal.a; // premultiply alpha channel		\n\
	float x1 = 1.0 - v_fragmentColor.g;		\n\
	float x2 = v_fragmentColor.b; 			\n\
	float f = min(1.0, ceil(v_fragmentColor.r - (v_texCoord.x - x1) / (x2 - x1))); \n\
	gl_FragColor = normal * (vec4(f, f, f, f) * v_fragmentColor.a);			\n\
}											\n\
";

qShader.QPositionTextureColorBarRevers_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
void main()									\n\
{											\n\
	float x1 = 1.0 - v_fragmentColor.g;		\n\
	float x2 = v_fragmentColor.b; 			\n\
	float f = min(1.0, ceil((v_texCoord.x - x1) / (x2 - x1) - v_fragmentColor.r)); \n\
	gl_FragColor = texture2D(CC_Texture0, v_texCoord) * (vec4(f, f, f, f) * v_fragmentColor.a);			\n\
}											\n\
";

qShader.QPositionTextureColorBarReversETC_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
uniform sampler2D CC_Texture1;				\n\
											\n\
void main()									\n\
{											\n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
    normal.a = texture2D(CC_Texture1, v_texCoord).r;				\n\
    normal.rgb *= normal.a; // premultiply alpha channel		\n\
	float x1 = 1.0 - v_fragmentColor.g;		\n\
	float x2 = v_fragmentColor.b; 			\n\
	float f = min(1.0, ceil((v_texCoord.x - x1) / (x2 - x1) - v_fragmentColor.r)); \n\
	gl_FragColor = normal * (vec4(f, f, f, f) * v_fragmentColor.a);			\n\
}											\n\
";
-- ttf outline frag
qShader.QTTFOutline_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform sampler2D CC_Texture0;				\n\
const float step1 = 0.003 * 3.5;					\n\
const float step2 = 0.006 * 3.5;					\n\
const float step3 = 0.009 * 3.5;					\n\
const float step4 = 0.012 * 3.5;					\n\
\n\
vec4 _texture2D(sampler2D s, vec2 coord) \n\
{ \n\
	vec4 ret = texture2D(CC_Texture0, coord); \n\
	if (coord.s < 0.0 || coord.s > 1.0 || coord.t < 0.0 || coord.t > 1.0) \n\
		return vec4(0.0, 0.0, 0.0, 0.0); \n\
	else \n\
		return ret; \n\
} \n\
											\n\
void main()									\n\
{											\n\
	vec2 _texCoord; \n\
	_texCoord = (v_texCoord - vec2(0.5, 0.5)) * vec2(1.1, 1.1) + vec2(0.5, 0.5); \n\
	float step_division = 1.0 / v_fragmentColor.a; \n\
	vec4 normal = _texture2D(CC_Texture0, _texCoord); \n\
	vec4 ot = vec4(0.0, 0.0, 0.0, 0.0); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step1 / step_division, _texCoord.t - step1)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step1 / step_division, _texCoord.t + step1)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step1 / step_division, _texCoord.t - step1)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step1 / step_division, _texCoord.t + step1)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step1 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t + step1)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step1 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t - step1)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step2 / step_division, _texCoord.t - step2)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step2 / step_division, _texCoord.t + step2)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step2 / step_division, _texCoord.t - step2)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step2 / step_division, _texCoord.t + step2)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step2 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t + step2)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step2 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t - step2)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step3 / step_division, _texCoord.t - step3)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step3 / step_division, _texCoord.t + step3)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step3 / step_division, _texCoord.t - step3)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step3 / step_division, _texCoord.t + step3)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step3 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t + step3)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step3 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t - step3)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step4 / step_division, _texCoord.t - step4)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step4 / step_division, _texCoord.t + step4)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step4 / step_division, _texCoord.t - step4)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step4 / step_division, _texCoord.t + step4)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s - step4 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t + step4)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s + step4 / step_division, _texCoord.t)); \n\
	ot = ot + _texture2D(CC_Texture0, vec2(_texCoord.s, _texCoord.t - step4)); \n\
	ot = ot / 32.0; \n\
	float shade_alpha; \n\
	float threshold = 0.40; \n\
	float threshold2 = 0.75; \n\
	float threshold3 = 0.33; \n\
	if (ot.a > threshold) \n\
	{ \n\
		shade_alpha = pow(1.0 - (ot.a - threshold) / (1.0 - threshold), 1.0); \n\
		if (shade_alpha > threshold3) \n\
			shade_alpha = (shade_alpha - threshold3) / (1.0 - threshold3); \n\
		else \n\
			shade_alpha = 0.0; \n\
	} \n\
	else \n\
	{ \n\
		shade_alpha = ot.a / threshold; \n\
		if (shade_alpha > threshold2) \n\
			shade_alpha = 1.0; \n\
		else \n\
			shade_alpha = shade_alpha / threshold2; \n\
	} \n\
	shade_alpha = shade_alpha / 1.5; \n\
	gl_FragColor = normal * (1.0 - shade_alpha) + vec4(0.0, 0.0, 0.0, shade_alpha); \n\
	gl_FragColor.rgb = gl_FragColor.rgb * (v_fragmentColor.rgb / v_fragmentColor.aaa); \n\
}											\n\
"

qShader.QColorLayer_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
void main()									\n\
{											\n\
	float a = texture2D(CC_Texture0, v_texCoord).a; \n\
	a = ceil(a - 0.5); \n\
	gl_FragColor = v_fragmentColor * vec4(a, a, a, a); \n\
}											\n\
";

qShader.QCircleOuterStencil_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform vec2 v_Clip;						\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
void main()									\n\
{											\n\
	gl_FragColor = vec4(1.0, 1.0, 1.0, ceil(distance(v_texCoord, vec2(0.5, 0.5)) - 0.499)); \n\
}											\n\
";

qShader.QGlow_frag = " \n\
#ifdef GL_ES \n\
precision lowp float; \n\
#endif \n\
 \n\
varying vec4 v_fragmentColor; \n\
varying vec2 v_texCoord; \n\
uniform sampler2D CC_Texture0; \n\
 \n\
void main() \n\
{ \n\
	vec4 normal = texture2D(CC_Texture0, v_texCoord); \n\
	gl_FragColor = normal * normal.a + v_fragmentColor * normal.a; \n\
} \n\
";

qShader.QPositionTextureColorEffect_vert = " \n\
attribute vec4 a_position;							\n\
attribute vec2 a_texCoord;							\n\
attribute vec4 a_color;								\n\
attribute vec4 a_color2;							\n\
													\n\
#ifdef GL_ES										\n\
varying lowp vec4 v_fragmentColor;					\n\
varying lowp vec4 v_fragmentColor2;					\n\
varying mediump vec2 v_texCoord;					\n\
#else												\n\
varying vec4 v_fragmentColor;						\n\
varying vec4 v_fragmentColor2;						\n\
varying vec2 v_texCoord;							\n\
#endif												\n\
													\n\
void main()											\n\
{													\n\
    gl_Position = CC_MVPMatrix * a_position;		\n\
	v_fragmentColor = a_color;						\n\
	v_fragmentColor2 = a_color2;					\n\
	v_texCoord = a_texCoord;						\n\
}													\n\
";

qShader.QPositionTextureColorAlphaTestEffect_frag = " \n\
#ifdef GL_ES												\n\
precision lowp float;										\n\
#endif														\n\
															\n\
varying vec4 v_fragmentColor;								\n\
varying vec4 v_fragmentColor2;				                \n\
varying vec2 v_texCoord;									\n\
uniform sampler2D CC_Texture0;								\n\
															\n\
void main()													\n\
{															\n\
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);		\n\
	vec4 fc = vec4(v_fragmentColor2.rgb * texColor.a, v_fragmentColor2.a)*v_fragmentColor; 		\n\
    vec4 tintColor = texColor * v_fragmentColor + fc;       \n\
															\n\
	// mimic: glAlphaFunc(GL_GREATER)						\n\
	// pass if ( incoming_pixel >= CC_alpha_value ) => fail if incoming_pixel < CC_alpha_value		\n\
															\n\
	if ( tintColor.a < 0.5 )								\n\
		discard;											\n\
	else												    \n\
	gl_FragColor = tintColor;				                \n\
}															\n\
";

qShader.QPositionTextureOldPhoto_frag = "                 				\n\
#ifdef GL_ES                                						\n\
precision mediump float;                    						\n\
#endif                                      						\n\
																	\n\
uniform sampler2D u_texture;                						\n\
varying vec2 v_texCoord;                    						\n\
varying vec4 v_fragmentColor;               						\n\
																	\n\
void main(void)                             						\n\
{                                           						\n\
	// Convert to greyscale using NTSC weightings               	\n\
	vec4 col = texture2D(u_texture, v_texCoord);                	\n\
	float r = 0.393 * col.r + 0.769 * col.g + 0.189 * col.b; \n\
	float g = 0.349 * col.r + 0.686 * col.g + 0.168 * col.b; \n\
	float b = 0.272 * col.r + 0.534 * col.g + 0.131 * col.b; \n\
	gl_FragColor = vec4(r, g, b, col.a) * v_fragmentColor;	\n\
}                                           						\n\
";

qShader.QPositionTextureShadowBlur_frag = "	\n\
#ifdef GL_ES 								\n\
precision mediump float;					\n\
#endif										\n\
											\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
											\n\
uniform sampler2D CC_Texture0;				\n\
											\n\
											\n\
void main() {								\n\
	vec4 sum = vec4(0.0);					\n\
	float blurSize = 0.001;					\n\
	sum += texture2D(CC_Texture0, v_texCoord - 4.0 * blurSize) * 0.05;		\n\
	sum += texture2D(CC_Texture0, v_texCoord - 3.0 * blurSize) * 0.09;		\n\
	sum += texture2D(CC_Texture0, v_texCoord - 2.0 * blurSize) * 0.12;		\n\
	sum += texture2D(CC_Texture0, v_texCoord - 1.0 * blurSize) * 0.15;		\n\
	sum += texture2D(CC_Texture0, v_texCoord                 ) * 0.16;		\n\
	sum += texture2D(CC_Texture0, v_texCoord + 1.0 * blurSize) * 0.15;		\n\
	sum += texture2D(CC_Texture0, v_texCoord + 2.0 * blurSize) * 0.12;		\n\
	sum += texture2D(CC_Texture0, v_texCoord + 3.0 * blurSize) * 0.09;		\n\
	sum += texture2D(CC_Texture0, v_texCoord + 4.0 * blurSize) * 0.05;		\n\
	gl_FragColor = sum * v_fragmentColor;						\n\
}											\n\
";

qShader.QPositionTextureColorShadow_vert = "		\n\
attribute vec4 a_position;							\n\
attribute vec2 a_texCoord;							\n\
 													\n\
varying vec2 v_texCoord;							\n\
void main()											\n\
{													\n\
	gl_Position = CC_PMatrix * a_position;			\n\
	v_texCoord = a_texCoord;						\n\
}													\n\
"


qShader.QPositionTextureShadow_frag = "	\n\
varying vec2 v_texCoord;				\n\
uniform sampler2D CC_Texture0;			\n\
 										\n\
vec4 composite(vec4 over, vec4 under)	\n\
{										\n\
	return over + (1.0 - over.a)*under;	\n\
}										\n\
void main(){							\n\
	vec2 shadowOffset = vec2(0.0, 0.02);									\n\
	vec4 textureColor = texture2D(CC_Texture0, v_texCoord + shadowOffset);	\n\
	float shadowMask = texture2D(CC_Texture0, v_texCoord).a;				\n\
	const float shadowOpacity = 0.5;										\n\
	vec4 shadowColor = vec4(0, 0, 0, shadowMask * shadowOpacity);			\n\
	gl_FragColor = composite(textureColor, shadowColor);					\n\
}										\n\
";

-- 扫光效果
qShader.QPositionTextureScanning_frag = [[
#ifdef GL_ES 								
precision mediump float;					
#endif										
											
uniform sampler2D CC_Texture0;				
uniform vec2 u_resolution;				
varying vec2 v_texCoord;					
varying vec4 v_fragmentColor;
varying vec4 v_fragmentColor2;

vec3 colorW = vec3(0.50, 0.45, 0.40);	//刷光颜色	

//刷光条
vec4 getLightColor(vec2 offset, float opacity, float padding, float rotate)
{
	//当前位置
	vec2 st = v_texCoord + offset;
	//倾斜
	float stxy = st.x;
	if(rotate <= 45.0)
	{
		stxy = st.x + st.y * rotate/45.0;
	}
	else
	{
		rotate = 90.0 - rotate; 
		stxy = st.y + st.x * rotate/45.0;
	}
	//左边界渐变
	float leftpacity = smoothstep(padding, 0.5, stxy);
	//右边界渐变
	float rightOpacity = smoothstep(1.0-padding, 0.5, stxy);
	//透明叠加
	opacity = opacity * leftpacity * rightOpacity;

	return vec4(colorW, opacity);
}

//叠加
vec4 composite(vec4 over, vec4 under)
{
	return under + over.a * over;
}

void main() {	
	float speed = v_fragmentColor2.r;	//位置变化系数	
	float padding = v_fragmentColor2.g;	//宽度左边界
	float rotate = v_fragmentColor2.b;	//角度
	float distance = v_fragmentColor2.a; //移动距离

	//当前偏移
	float offset = distance - speed * distance * 2.0;

	vec2 offsetVec = vec2(offset, offset);
	vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
	vec4 lightColor = getLightColor(offsetVec, textureColor.a, padding, rotate);	

	gl_FragColor = composite(lightColor, textureColor) * v_fragmentColor;
}											
]];

-- 扫光效果
qShader.QPositionTextureScanningETC_frag = [[
#ifdef GL_ES 								
precision mediump float;					
#endif										
											
uniform sampler2D CC_Texture0;	
uniform sampler2D CC_Texture1;				
uniform vec2 u_resolution;				
varying vec2 v_texCoord;					
varying vec4 v_fragmentColor;
varying vec4 v_fragmentColor2;

vec3 colorW = vec3(0.50, 0.45, 0.40);	//刷光颜色				
const float distance = 1.5;				//移动距离

//刷光条
vec4 getLightColor(vec2 offset, float opacity, float padding, float rotate)
{
	//当前位置
	vec2 st = v_texCoord + offset;
	//倾斜
	float stxy = st.x;
	if(rotate <= 45.0)
	{
		stxy = st.x + st.y * rotate/45.0;
	}
	else
	{
		rotate = 90.0 - rotate; 
		stxy = st.y + st.x * rotate/45.0;
	}
	//左边界渐变
	float leftpacity = smoothstep(padding, 0.5, stxy);
	//右边界渐变
	float rightOpacity = smoothstep(1.0-padding, 0.5, stxy);
	//透明叠加
	opacity = opacity * leftpacity * rightOpacity;

	return vec4(colorW, opacity);
}

//叠加
vec4 composite(vec4 over, vec4 under)
{
	return under + over.a * over;
}

void main() {	
	float speed = v_fragmentColor2.r;	//移动速度
	float padding = v_fragmentColor2.g;	//宽度左边界
	float rotate = v_fragmentColor2.b;	//角度
	float distance = v_fragmentColor2.a; //移动距离

	//当前偏移
	float offset = distance - speed * distance * 2.0;

	vec2 offsetVec = vec2(offset, offset);
	vec4 textureColor1 = texture2D(CC_Texture1, v_texCoord);
	vec4 lightColor = getLightColor(offsetVec, textureColor1.r, padding, rotate);	

	vec4 textureColor0 = texture2D(CC_Texture0, v_texCoord);
	textureColor0.rgb *= textureColor1.r;
    textureColor0.a = textureColor1.r;
	gl_FragColor = composite(lightColor, textureColor0) * v_fragmentColor;
}											
]];

-- 碎片变灰
qShader.QPositionTextureColorHeadGray_frag = [[
#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;
	
void main()
{
	float f = ceil(v_fragmentColor.a - abs(v_texCoord.x - v_texCoord.y));
	vec4 col = texture2D(CC_Texture0, v_texCoord) * vec4(f, f, f, f);
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	gl_FragColor = vec4(grey, grey, grey, col.a) * v_fragmentColor;
}
]];

-- 碎片变灰
qShader.QPositionTextureColorHeadGrayETC_frag = [[
#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;
uniform sampler2D CC_Texture1;
	
void main()
{
	float f = ceil(v_fragmentColor.a - abs(v_texCoord.x - v_texCoord.y));
	vec4 normal = texture2D(CC_Texture0, v_texCoord);
    normal.a = texture2D(CC_Texture1, v_texCoord).r;
    normal.rgb *= normal.a;
	vec4 col = normal * vec4(f, f, f, f);
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	gl_FragColor = vec4(grey, grey, grey, col.a) * v_fragmentColor;
}
]];

-- 切圆变灰
qShader.QPositionTextureColorCircleGray_frag = [[
#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;
	
void main()
{
	float f = ceil(0.5 - distance(v_texCoord, vec2(0.5, 0.5)));
	vec4 col = texture2D(CC_Texture0, v_texCoord) * vec4(f, f, f, f);
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	gl_FragColor = vec4(grey, grey, grey, col.a) * v_fragmentColor;
}
]];

-- 切圆变灰
qShader.QPositionTextureColorCircleGrayETC_frag = [[
#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;
uniform sampler2D CC_Texture1;
	
void main()
{
	float f = ceil(0.5 - distance(v_texCoord, vec2(0.5, 0.5)));
	vec4 normal = texture2D(CC_Texture0, v_texCoord);
    normal.a = texture2D(CC_Texture1, v_texCoord).r;
    normal.rgb *= normal.a;
	vec4 col = normal * vec4(f, f, f, f);
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	gl_FragColor = vec4(grey, grey, grey, col.a) * v_fragmentColor;
}
]];

function addAttributeToProgram(p, key)
	if p == nil then
		return
	end

	if key == qShader.kQShader_PositionTextureGray then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);

	elseif key == qShader.kQShader_PositionTextureGrayStone then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);

	elseif key == qShader.kQShader_PositionTextureGrayStoneETC then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);

    elseif key == qShader.kQShader_PositionTextureGrayLuminance then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);

    elseif key == qShader.kQShader_PositionTextureGrayLuminanceAlpha then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorOutline then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorOutlineWeak then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorOutlineWeakETC then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorInsideLight then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureHSI then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorHSI or key == qShader.kQShader_PositionTextureColorHSIETC then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
        p:addAttribute(qShader.kCCAttribuetNameColor2, qShader.kCCVertexAttrib_Color2);
    elseif key == qShader.kQShader_PositionTextureColorHead or key == qShader.kQShader_PositionTextureColorHeadETC or
    	key == qShader.kQShader_PositionTextureColorHeadGray or key == qShader.kQShader_PositionTextureColorHeadGrayETC then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorRectangle or key == qShader.kQShader_PositionTextureColorRectangleETC then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorCircle or key == qShader.kQShader_PositionTextureColorCircleETC or
    	key == qShader.kQShader_PositionTextureColorCircleGray or key == qShader.kQShader_PositionTextureColorCircleGrayETC then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorBar or key == qShader.kQShader_PositionTextureColorBarETC
    	or key == qShader.kQShader_PositionTextureColorBarRevers or key == qShader.kQShader_PositionTextureColorBarReversETC then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_TTFOutline then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_ColorLayer then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_CircleOuterStencil then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_Glow then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureColorAlphaTestEffect then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
        p:addAttribute(qShader.kCCAttribuetNameColor2, qShader.kCCVertexAttrib_Color2);
    elseif key == qShader.kQShader_PositionTextureOldPhoto then
    	p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
        p:addAttribute(qShader.kCCAttribuetNameColor2, qShader.kCCVertexAttrib_Color2);
    elseif key == qShader.kQShader_PositionTextureShadowBlur then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
        p:addAttribute(qShader.kCCAttribuetNameColor2, qShader.kCCVertexAttrib_Color2);
    elseif key == qShader.kQShader_PositionTextureShadow then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    elseif key == qShader.kQShader_PositionTextureScanning or key == qShader.kQShader_PositionTextureScanningETC then
		p:addAttribute(qShader.kCCAttributeNamePosition, qShader.kCCVertexAttrib_Position);
        p:addAttribute(qShader.kCCAttributeNameColor, qShader.kCCVertexAttrib_Color);
        p:addAttribute(qShader.kCCAttributeNameTexCoord, qShader.kCCVertexAttrib_TexCoords);
    else
    	return
	end
end

-- vert: vertex shader
-- frag: fragment shader
function loadCustomShader(vert, frag, key)
	if vert == nil or frag == nil then
		return nil
	end

	local p = QGLProgram:create(vert, frag)
	assert(p ~= nil, "create custom shader " .. key .. " faild.")

	addAttributeToProgram(p, key)

	p:link();
	p:updateUniforms();
	QUtility:checkGLError()
	CCShaderCache:sharedShaderCache():addProgram(p, key)

	return p
end

function loadAllCustomShaders()
	if qShader.Q_ProgramPositionTextureGray == nil then
		qShader.Q_ProgramPositionTextureGray = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureGray_frag, qShader.kQShader_PositionTextureGray)
	end
	-- if qShader.Q_ProgramPositionTextureGrayETC1 == nil then
	-- 	qShader.Q_ProgramPositionTextureGrayETC1 = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureGrayETC1_frag, qShader.kQShader_PositionTextureGrayETC1)
	-- end

	if qShader.Q_ProgramPositionTextureGrayStone == nil then
		qShader.Q_ProgramPositionTextureGrayStone = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureGrayStone_frag, qShader.kQShader_PositionTextureGrayStone)
	end

	if qShader.Q_ProgramPositionTextureGrayStoneETC == nil then
		qShader.Q_ProgramPositionTextureGrayStoneETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureGrayStoneETC_frag, qShader.kQShader_PositionTextureGrayStoneETC)
	end

	if qShader.Q_ProgramPositionTextureGrayLuminance == nil then
		qShader.Q_ProgramPositionTextureGrayLuminance = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureGrayLuminance_frag, qShader.kQShader_PositionTextureGrayLuminance)
	end

	if qShader.Q_ProgramPositionTextureGrayLuminanceAlpha == nil then
		qShader.Q_ProgramPositionTextureGrayLuminanceAlpha = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureGray_frag, qShader.kQShader_PositionTextureGrayLuminanceAlpha)
	end

	if qShader.Q_ProgramPositionTextureColorOutline == nil then
		qShader.Q_ProgramPositionTextureColorOutline = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorOutline_frag, qShader.kQShader_PositionTextureColorOutline)
	end

	if qShader.Q_ProgramPositionTextureColorOutlineWeak == nil then
		qShader.Q_ProgramPositionTextureColorOutlineWeak = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorOutlineWeak_frag, qShader.kQShader_PositionTextureColorOutlineWeak)
	end

	if qShader.Q_ProgramPositionTextureColorOutlineWeakETC == nil then
		qShader.Q_ProgramPositionTextureColorOutlineWeakETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorOutlineWeakETC_frag, qShader.kQShader_PositionTextureColorOutlineWeakETC)
	end

	if qShader.Q_ProgramPositionTextureColorInsideLight == nil then
		qShader.Q_ProgramPositionTextureColorInsideLight = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorInsideLight, qShader.kQShader_PositionTextureColorInsideLight)
	end

	if qShader.Q_ProgramPositionTextureHSI == nil then
		qShader.Q_ProgramPositionTextureHSI = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureHSI_frag, qShader.kQShader_PositionTextureHSI)
	end

	if qShader.Q_ProgramPositionTextureColorHSI == nil then
		qShader.Q_ProgramPositionTextureColorHSI = loadCustomShader(qShader.QPositionTextureColorHSI_vert, qShader.QPositionTextureColorHSI_frag, qShader.kQShader_PositionTextureColorHSI)
	end

	if qShader.Q_ProgramPositionTextureColorHSIETC == nil then
		qShader.Q_ProgramPositionTextureColorHSIETC = loadCustomShader(qShader.QPositionTextureColorHSI_vert, qShader.QPositionTextureColorHSIETC_frag, qShader.kQShader_PositionTextureColorHSIETC)
	end

	if qShader.Q_ProgramPositionTextureColorHead == nil then
		qShader.Q_ProgramPositionTextureColorHead = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorHead_frag, qShader.kQShader_PositionTextureColorHead)
	end

	if qShader.Q_ProgramPositionTextureColorHeadETC == nil then
		qShader.Q_ProgramPositionTextureColorHeadETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorHeadETC_frag, qShader.kQShader_PositionTextureColorHeadETC)
	end

	if qShader.Q_ProgramPositionTextureColorRectangle == nil then
		qShader.Q_ProgramPositionTextureColorRectangle = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorRectangle_frag, qShader.kQShader_PositionTextureColorRectangle)
	end

	if qShader.Q_ProgramPositionTextureColorRectangleETC == nil then
		qShader.Q_ProgramPositionTextureColorRectangleETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorRectangleETC_frag, qShader.kQShader_PositionTextureColorRectangleETC)
	end

	if qShader.Q_ProgramPositionTextureColorCircle == nil then
		qShader.Q_ProgramPositionTextureColorCircle = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorCircle_frag, qShader.kQShader_PositionTextureColorCircle)
	end

	if qShader.Q_ProgramPositionTextureColorCircleETC == nil then
		qShader.Q_ProgramPositionTextureColorCircleETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorCircleETC_frag, qShader.kQShader_PositionTextureColorCircleETC)
	end

	if qShader.Q_ProgramPositionTextureColorBar == nil then
		qShader.Q_ProgramPositionTextureColorBar = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorBar_frag, qShader.kQShader_PositionTextureColorBar)
	end

	if qShader.Q_ProgramPositionTextureColorBarETC == nil then
		qShader.Q_ProgramPositionTextureColorBarETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorBarETC_frag, qShader.kQShader_PositionTextureColorBarETC)
	end

	if qShader.Q_ProgramPositionTextureColorBarRevers == nil then
		qShader.Q_ProgramPositionTextureColorBarRevers = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorBarRevers_frag, qShader.kQShader_PositionTextureColorBarRevers)
	end

	if qShader.Q_ProgramPositionTextureColorBarReversETC == nil then
		qShader.Q_ProgramPositionTextureColorBarReversETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorBarReversETC_frag, qShader.kQShader_PositionTextureColorBarReversETC)
	end
	-- if qShader.Q_ProgramTTFOutline == nil then
	-- 	qShader.Q_ProgramTTFOutline = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QTTFOutline_frag, qShader.kQShader_TTFOutline)
	-- end

	if qShader.Q_ProgramColorLayer == nil then
		qShader.Q_ProgramColorLayer = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QColorLayer_frag, qShader.kQShader_ColorLayer)
	end

	if qShader.Q_ProgramCircleOuterStencil == nil then
		qShader.Q_ProgramCircleOuterStencil = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QCircleOuterStencil_frag, qShader.kQShader_CircleOuterStencil)
	end

	if qShader.Q_ProgramGlow == nil then
		qShader.Q_ProgramGlow = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QGlow_frag, qShader.kQShader_Glow)
	end

	if qShader.Q_ProgramPositionTextureAlphaTestEffect == nil then
		qShader.Q_ProgramPositionTextureAlphaTestEffect = loadCustomShader(qShader.QPositionTextureColorEffect_vert, qShader.QPositionTextureColorAlphaTestEffect_frag, qShader.kQShader_PositionTextureColorAlphaTestEffect)
	end

	if qShader.Q_ProgramPositionTextureOldPhoto == nil then
		qShader.Q_ProgramPositionTextureOldPhoto = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureOldPhoto_frag, qShader.kQShader_PositionTextureOldPhoto)
	end
	
	if qShader.Q_ProgramPositionTextureShadowBlur == nil then
		qShader.Q_ProgramPositionTextureShadowBlur = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureShadowBlur_frag, qShader.kQShader_PositionTextureShadowBlur)
	end

	if qShader.Q_ProgramPositionTextureShadow == nil then
		qShader.Q_ProgramPositionTextureShadow = loadCustomShader(qShader.QPositionTextureColorShadow_vert, qShader.QPositionTextureShadow_frag, qShader.kQShader_PositionTextureShadow)
	end

	if qShader.Q_ProgramPositionTextureScanning == nil then
		qShader.Q_ProgramPositionTextureScanning = loadCustomShader(qShader.QPositionTextureColorHSI_vert, qShader.QPositionTextureScanning_frag, qShader.kQShader_PositionTextureScanning)
	end

	if qShader.Q_ProgramPositionTextureScanningETC == nil then
		qShader.Q_ProgramPositionTextureScanningETC = loadCustomShader(qShader.QPositionTextureColorHSI_vert, qShader.QPositionTextureScanningETC_frag, qShader.kQShader_PositionTextureScanningETC)
	end

	if qShader.Q_ProgramPositionTextureColorHeadGray == nil then
		qShader.Q_ProgramPositionTextureColorHeadGray = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorHeadGray_frag, qShader.kQShader_PositionTextureColorHeadGray)
	end

	if qShader.Q_ProgramPositionTextureColorHeadGrayETC == nil then
		qShader.Q_ProgramPositionTextureColorHeadGrayETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorHeadGrayETC_frag, qShader.kQShader_PositionTextureColorHeadGrayETC)
	end

	if qShader.Q_ProgramPositionTextureColorCircleGray == nil then
		qShader.Q_ProgramPositionTextureColorCircleGray = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorCircleGray_frag, qShader.kQShader_PositionTextureColorCircleGray)
	end

	if qShader.Q_ProgramPositionTextureColorCircleGrayETC == nil then
		qShader.Q_ProgramPositionTextureColorCircleGrayETC = loadCustomShader(qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorCircleGrayETC_frag, qShader.kQShader_PositionTextureColorCircleGrayETC)
	end
end

function reloadCustomShader(p, vert, frag, key)
	if p == nil or vert == nil or frag == nil then
		return 
	end

	p:reset()
	p:initWithVertexShaderByteArray(vert, frag)

	addAttributeToProgram(p, key)

	p:link();
	p:updateUniforms();
	QUtility:checkGLError()
end

function reloadAllCustomShaders()
	local p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureGray)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureGray_frag, qShader.kQShader_PositionTextureGray)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureGrayStone)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureGrayStone_frag, qShader.kQShader_PositionTextureGrayStone)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureGrayStoneETC)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureGrayStoneETC_frag, qShader.kQShader_PositionTextureGrayStoneETC)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureGrayLuminance)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureGrayLuminance_frag, qShader.kQShader_PositionTextureGrayLuminance)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureGrayLuminanceAlpha)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureGray_frag, qShader.kQShader_PositionTextureGrayLuminanceAlpha)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorOutline)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorOutline_frag, qShader.kQShader_PositionTextureColorOutline)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorOutlineWeak)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorOutlineWeak_frag, qShader.kQShader_PositionTextureColorOutlineWeak)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorOutlineWeakETC)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorOutlineWeakETC_frag, qShader.kQShader_PositionTextureColorOutlineWeakETC)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorInsideLight)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorInsideLight, qShader.kQShader_PositionTextureColorInsideLight)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureHSI)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureHSI_frag, qShader.kQShader_PositionTextureHSI)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorHSI)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColorHSI_vert, qShader.QPositionTextureColorHSI_frag, qShader.kQShader_PositionTextureColorHSI)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorHSIETC)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColorHSI_vert, qShader.QPositionTextureColorHSIETC_frag, qShader.kQShader_PositionTextureColorHSIETC)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorHead)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorHead_frag, qShader.kQShader_PositionTextureColorHead)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorHeadETC)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorHeadETC_frag, qShader.kQShader_PositionTextureColorHeadETC)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorRectangle)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorRectangle_frag, qShader.kQShader_PositionTextureColorRectangle)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorRectangleETC)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorRectangleETC_frag, qShader.kQShader_PositionTextureColorRectangleETC)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorCircle)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorCircle_frag, qShader.kQShader_PositionTextureColorCircle)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorCircleETC)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorCircleETC_frag, qShader.kQShader_PositionTextureColorCircleETC)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorBar)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorBar_frag, qShader.kQShader_PositionTextureColorBar)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorBarETC)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureColorBarETC_frag, qShader.kQShader_PositionTextureColorBarETC)
	end

	-- p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_TTFOutline)
	-- if p then
	-- 	reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QTTFOutline_frag, qShader.kQShader_TTFOutline)
	-- end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_ColorLayer)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QColorLayer_frag, qShader.kQShader_ColorLayer)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_CircleOuterStencil)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QCircleOuterStencil_frag, qShader.kQShader_CircleOuterStencil)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_Glow)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QGlow_frag, qShader.kQShader_Glow)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureColorAlphaTestEffect)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColorEffect_vert, qShader.QPositionTextureColorAlphaTestEffect_frag, qShader.kQShader_PositionTextureColorAlphaTestEffect)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureOldPhoto)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureOldPhoto_frag, qShader.kQShader_PositionTextureOldPhoto)
	end
	
	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureShadowBlur)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureShadowBlur_frag, qShader.kQShader_PositionTextureShadowBlur)
	end

	p = CCShaderCache:sharedShaderCache():programForKey(qShader.kQShader_PositionTextureShadow)
	if p then
		reloadCustomShader(p, qShader.QPositionTextureColor_vert, qShader.QPositionTextureShadow_frag, qShader.kQShader_PositionTextureShadow)
	end
end

function makeNodeFromNormalToGray(node)
	if node == nil  or qShader.Q_ProgramPositionTextureGray == nil then
		return
	end

	local program = node:getShaderProgram()
	if program == qShader.CC_ProgramPositionTextureColor or
    	program == qShader.CC_ProgramETC1ASPositionTextureColorEffect or
    	program == qShader.CC_ProgramETC1ASPositionTextureColor or
    	program == qShader.CC_ProgramPositionTextureColorEffect then
    	if node.isETC1 and node:isETC1() then
    		node:setShaderProgram(qShader.Q_ProgramPositionTextureGrayETC1)
    	else
			node:setShaderProgram(qShader.Q_ProgramPositionTextureGray)
		end
		q.setNodePreviousShader(node, program)
	elseif program == qShader.Q_ProgramPositionTextureColorHead then
		if node.isETC1 and node:isETC1() then
    		node:setShaderProgram(qShader.Q_ProgramPositionTextureColorHeadGrayETC1)
    	else
			node:setShaderProgram(qShader.Q_ProgramPositionTextureColorHeadGray)
		end	
		q.setNodePreviousShader(node, program)
	elseif program == qShader.Q_ProgramPositionTextureColorCircle then
		if node.isETC1 and node:isETC1() then
    		node:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircleGrayETC1)
    	else
			node:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircleGray)
		end	
		q.setNodePreviousShader(node, program)
	end

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeFromNormalToGray(tolua.cast(children:objectAtIndex(i), "CCNode"))
    	local subNode = tolua.cast(children:objectAtIndex(i), "CCNode")
    	if tolua.type(subNode) == "CCLabelTTF" then
 			local program = subNode:getShaderProgram()
 			if program and program ~= qShader.Q_ProgramPositionTextureGrayETC1 and program ~= qShader.Q_ProgramPositionTextureGray then
				q.setNodePreviousShader(subNode, program)
		    	if subNode.isETC1 and subNode:isETC1() then
		    		subNode:setShaderProgram(qShader.Q_ProgramPositionTextureGrayETC1)
		    	else
					subNode:setShaderProgram(qShader.Q_ProgramPositionTextureGray)
				end
			end
    	end     	
    end
end

function makeNodeFromNormalToGrayStone(node)
	if node == nil  or qShader.Q_ProgramPositionTextureGrayStone == nil then
		return
	end

	local program = node:getShaderProgram()
	if program == qShader.CC_ProgramPositionTextureColor or
    program == qShader.CC_ProgramETC1ASPositionTextureColorEffect or
    program == qShader.CC_ProgramETC1ASPositionTextureColor or
    program == qShader.CC_ProgramPositionTextureColorEffect then
    	if node.isETC1 and node:isETC1() then
    		node:setShaderProgram(qShader.Q_ProgramPositionTextureGrayStoneETC)
    	else
			node:setShaderProgram(qShader.Q_ProgramPositionTextureGrayStone)
		end
		q.setNodePreviousShader(node, program)
	end

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeFromNormalToGrayStone(tolua.cast(children:objectAtIndex(i), "CCNode"))
    end
end

function makeNodeFromNormalToGrayLuminance(node)
	if node == nil or qShader.Q_ProgramPositionTextureGrayLuminance == nil then
		return
	end

	local program = node:getShaderProgram()
	if program == qShader.CC_ProgramPositionTextureColor or
    program == qShader.CC_ProgramETC1ASPositionTextureColorEffect or
    program == qShader.CC_ProgramETC1ASPositionTextureColor or
    program == qShader.CC_ProgramPositionTextureColorEffect then
    	if node.isETC1 and node:isETC1() then
    		node:setShaderProgram(qShader.Q_ProgramPositionTextureGrayStoneETC)
    	else
			node:setShaderProgram(qShader.Q_ProgramPositionTextureGrayLuminance)
		end
		q.setNodePreviousShader(node, program)
	end

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeFromNormalToGrayLuminance(tolua.cast(children:objectAtIndex(i), "CCNode"))
    end
end

function makeNodeRefreshCCBPos(node)
	if node == nil or node.refreshCCBPos == nil then
		return
	end

	node:refreshCCBPos(CCSize(display.width, display.height))
	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeRefreshCCBPos(tolua.cast(children:objectAtIndex(i), "CCNode"))
    end
end


function makeNodeCascadeOpacityEnabled(node, state)
  if node == nil then
    return
  end

  node:setCascadeOpacityEnabled(state)

  local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
      makeNodeCascadeOpacityEnabled(tolua.cast(children:objectAtIndex(i), "CCNode"), state)
    end
end

-- function makeNodeFromNormalToGrayLuminanceAlpha(node)
-- 	if node == nil or qShader.Q_ProgramPositionTextureGrayLuminanceAlpha == nil then
-- 		return
-- 	end

-- 	local program = node:getShaderProgram()
-- 	if program == qShader.CC_ProgramPositionTextureColor or
--     program == qShader.CC_ProgramETC1ASPositionTextureColorEffect or
--     program == qShader.CC_ProgramETC1ASPositionTextureColor or
--     program == qShader.CC_ProgramPositionTextureColorEffect then
-- 		node:setShaderProgram(qShader.Q_ProgramPositionTextureGrayLuminanceAlpha)
-- 		q.setNodePreviousShader(node, program)
-- 	end
-- 	node:setOpacityModifyRGB(true)

-- 	local children = node:getChildren()
--     if children == nil then
--         return
--     end

--     local i = 0
--     local len = children:count()
--     for i = 0, len - 1, 1 do
--     	makeNodeFromNormalToGrayLuminanceAlpha(tolua.cast(children:objectAtIndex(i), "CCNode"))
--     end
-- end

-- function makeNodeFromNormalToLight(node)
-- 	if node == nil or qShader.Q_ProgramPositionTextureColorInsideLight == nil then
-- 		return
-- 	end

-- 	local program = node:getShaderProgram()
-- 	if program == qShader.CC_ProgramPositionTextureColor then
-- 		node:setShaderProgram(qShader.Q_ProgramPositionTextureColorInsideLight)
-- 	end

-- 	local children = node:getChildren()
--     if children == nil then
--         return
--     end

--     local i = 0
--     local len = children:count()
--     for i = 0, len - 1, 1 do
--     	makeNodeFromNormalToGray(tolua.cast(children:objectAtIndex(i), "CCNode"))
--     end
-- end

-- function makeNodeFromLightToNormal(node)
-- 	if node == nil then
-- 		return
-- 	end

-- 	local program = node:getShaderProgram()
-- 	if program == qShader.Q_ProgramPositionTextureColorInsideLight then
-- 		node:setShaderProgram(qShader.CC_ProgramPositionTextureColor)
-- 	end

-- 	local children = node:getChildren()
-- 	if children == nil then
-- 	    return
-- 	end

-- 	local i = 0
-- 	local len = children:count()
-- 	for i = 0, len - 1, 1 do
-- 		makeNodeFromLightToNormal(tolua.cast(children:objectAtIndex(i), "CCNode"))
-- 	end
-- end

function makeNodeFromGrayToNormal(node)
	if node == nil then
		return
	end

	local program = node:getShaderProgram()
	if program == qShader.Q_ProgramPositionTextureGray or program == qShader.Q_ProgramPositionTextureGrayStone or program == qShader.Q_ProgramPositionTextureGrayStoneETC or 
		program == qShader.Q_ProgramPositionTextureGrayLuminance or program == qShader.Q_ProgramPositionTextureGrayLuminanceAlpha or 
		program == qShader.Q_ProgramPositionTextureColorInsideLight or program == qShader.Q_ProgramPositionTextureGrayETC1 then
		
		local proGram = q.getNodePreviousShader(node)
		if nil ~= proGram then
			node:setShaderProgram(proGram)
		else
			node:setShaderProgram(qShader.CC_ProgramPositionTextureColor)
		end
		if program == qShader.Q_ProgramPositionTextureGrayLuminanceAlpha then
			node:setOpacityModifyRGB(false)
		end
		previousShaderDict[node] = nil
	elseif program == qShader.Q_ProgramPositionTextureColorHeadGrayETC1 then
    	node:setShaderProgram(qShader.Q_ProgramPositionTextureColorHeadETC)
	elseif program == qShader.Q_ProgramPositionTextureColorHeadGray then
    	node:setShaderProgram(qShader.Q_ProgramPositionTextureColorHead)
	elseif program == qShader.Q_ProgramPositionTextureColorCircleGrayETC1 then
    	node:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircleETC)
	elseif program == qShader.Q_ProgramPositionTextureColorCircleGray then
    	node:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
	end

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeFromGrayToNormal(tolua.cast(children:objectAtIndex(i), "CCNode")) 	
    	local subNode = tolua.cast(children:objectAtIndex(i), "CCNode")
    	if tolua.type(subNode) == "CCLabelTTF" then
			local proGram = q.getNodePreviousShader(subNode)
			if nil ~= proGram then
				node:setShaderProgram(proGram)		
			end
    	end    	
    end
end

function makeNodeOpacity(node, opacity)
	if node == nil then
		return
	end

	node:setOpacity(opacity)

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0 
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeOpacity(tolua.cast(children:objectAtIndex(i), "CCNode"), opacity)
    end
end

function makeNodeFadeToOpacity(node, time)
	if node == nil then
		return
	end

	local originalOpacity = node:getOpacity()
	node:setOpacity(0)
	node:runAction(CCFadeTo:create(time, originalOpacity))

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeFadeToOpacity(tolua.cast(children:objectAtIndex(i), "CCNode"), time)
    end
end

function makeNodeFadeToByTimeAndOpacity(node, time, opacity)
	if node == nil then
		return
	end

	node:runAction(CCFadeTo:create(time, opacity))

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeFadeToByTimeAndOpacity(tolua.cast(children:objectAtIndex(i), "CCNode"), time, opacity)
    end
end

function makeNodeColor(node, color)
	if node == nil then
		return
	end
	
	node:setColor(color)

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	makeNodeColor(tolua.cast(children:objectAtIndex(i), "CCNode"), color)
    end
end

function traverseNode(node, func)
	if node == nil or func == nil then
		return
	end
	
	func(node)

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	traverseNode(tolua.cast(children:objectAtIndex(i), "CCNode"), func)
    end
end

function setNodeShaderProgram(node, program)
	if node == nil then
		return
	end
	local _program = program
	if node.isETC1 and node:isETC1() then
		if program == qShader.Q_ProgramPositionTextureColorOutlineWeak then
			_program = qShader.Q_ProgramPositionTextureColorOutlineWeakETC
		elseif program == qShader.CC_ProgramPositionTextureColor then
			_program = qShader.CC_ProgramETC1ASPositionTextureColor
		elseif program == qShader.Q_ProgramPositionTextureColorHead then
			_program = qShader.Q_ProgramPositionTextureColorHeadETC
		elseif program == qShader.Q_ProgramPositionTextureColorCircle then
			_program = qShader.Q_ProgramPositionTextureColorCircleETC
		elseif program == qShader.Q_ProgramPositionTextureColorBar then
			_program = qShader.Q_ProgramPositionTextureColorBarETC
		elseif program == qShader.Q_ProgramPositionTextureColorBarRevers then
			_program = qShader.Q_ProgramPositionTextureColorBarReversETC
		elseif program == qShader.Q_ProgramPositionTextureScanning then
			_program = qShader.Q_ProgramPositionTextureScanningETC
		elseif program == qShader.Q_ProgramPositionTextureColorHSI then
			_program = qShader.Q_ProgramPositionTextureColorHSIETC
		end
	end

	node:setShaderProgram(_program)

	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	setNodeShaderProgram(tolua.cast(children:objectAtIndex(i), "CCNode"), program)
    end
end

function setNodeScanningProgram(node, color)
	if node == nil then
		return
	end
	local _program = qShader.Q_ProgramPositionTextureScanning
	if node.isETC1 and node:isETC1() then
		_program = qShader.Q_ProgramPositionTextureScanningETC
	end
	node:setShaderProgram(_program)
	-- r速度 距离为1.5倍宽度
	-- g宽度 0.5中介线，(g-0.5)*2倍宽度
	-- b角度 0.0为水平 90.0为垂直，只支持左到右，上到下
	if color then
		node:setColorOffset(color)
	end
	local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
    	setNodeScanningProgram(tolua.cast(children:objectAtIndex(i), "CCNode"), color)
    end
end

function createSpriteWithSpriteFrame(spriteFrameName)
	if spriteFrameName == nil then
		return
	end

	local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameName)
	if spriteFrame == nil then
		assert(false, "can not find sprite frame named: " .. spriteFrameName)
		return
	end

	local sprite = CCSprite:createWithSpriteFrame(spriteFrame)
	return sprite
end

function replaceSpriteWithSpriteFrame(sprite, spriteFrameName)
	if sprite == nil or spriteFrameName == nil then
		return
	end

	local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameName)
	if spriteFrame == nil then
		assert(false, "can not find sprite frame named: " .. spriteFrameName)
		return
	end

	sprite:setDisplayFrame(spriteFrame)
end

function replaceSpriteWithImage(sprite, imageName)
	if sprite == nil or imageName == nil then
		return
	end

	local texture = CCTextureCache:sharedTextureCache():addImage(imageName)
	if texture == nil then
		assert(false, "can not load image named: " .. imageName)
		return
	end

	sprite:setTexture(texture)
    local size = texture:getContentSize()
    local rect = CCRectMake(0, 0, size.width, size.height)
    sprite:setTextureRect(rect)
end

--[[
--@param tf, 要设置阴影的节点
--@param offset, 阴影偏移量
--@param shadowColor, 阴影的颜色
]]--
function setShadow(tf, offset, shadowColor)
	local prop = tf:getTextDefinition()
	local anchorPos = tf:getAnchorPoint()
	if anchorPos.x == 0 then
		prop.m_alignment = ui.TEXT_ALIGN_LEFT
	elseif anchorPos.x == 0.5 then
		prop.m_alignment = ui.TEXT_ALIGN_CENTER 
	elseif anchorPos.x == 1 then
		prop.m_alignment = ui.TEXT_ALIGN_RIGHT 
	end

	if anchorPos.y == 0 then
		prop.m_vertAlignment = ui.TEXT_VALIGN_TOP 
	elseif anchorPos.y == 0.5 then
		prop.m_vertAlignment = ui.TEXT_VALIGN_CENTER  
	elseif anchorPos.y == 1 then
		prop.m_vertAlignment = ui.TEXT_VALIGN_BOTTOM 
	end

	local str = tf:getString()
	local color = tf:getDisplayedColor()
	local newTF = ui.newTTFLabelWithShadow({
		text = str,
		font = prop.m_fontName,
		size = prop.m_fontSize,
		color = color,
		align = prop.m_alignment,
		valign = prop.m_vertAlignment,
		dimensions = prop.m_dimensions,
		shadowColor = shadowColor or ccc3(0, 0, 0),
		offset = offset
		})
	newTF:setPosition(tf:getPosition())
	tf:setString("")
	local parent = tf:getParent()
	if parent then
		parent:addChild(newTF)
	end
	return newTF
end

function setShadow2(tf, offset)
	if QDummyNode == nil then
		return setShadow(tf, offset)
	end

	local newTF = display.newNode()
	newTF:setPosition(tf:getPositionX(), tf:getPositionY())
	tf:setPosition(0, 0)
	local dummy = QDummyNode:create(tf)
	dummy:setPosition(offset, -offset)
	dummy:setColor(ccc3(0, 0, 0))
	local parent = tf:getParent()
	tf:removeFromParent()
	newTF:addChild(dummy)
	newTF:addChild(tf)
	parent:addChild(newTF)
	newTF.dummy = dummy
	newTF.tf = tf

	local g = newTF
    function g:setString(text)
    	tf:setString(text)
    end

    function g:getString()
        return tf:getString()
    end

    function g:realign(x, y)
        tf:setPosition(x, y)
    end

    function g:getContentSize()
        return tf:getContentSize()
    end

    function g:setColor(...)
        tf:setColor(...)
    end

    function g:setShadowColor(...)
        dummy:setColor(...)
    end

    function g:setOpacity(opacity)
        tf:setOpacity(opacity)
        dummy:setOpacity(opacity)
    end

	return newTF
end

function unShadow2(newTF)
	if QDummyNode == nil or newTF.tf == nil then
		return newTF
	end

	local parent = newTF:getParent()
	local tf = newTF.tf
	tf:setPosition(newTF:getPositionX(), newTF:getPositionY())
	tf:retain()
	tf:removeFromParent()
	parent:addChild(tf)
	newTF:cleanup()
	newTF:removeFromParent()
	tf:release()

	return tf
end

-- function setShadow3(tf)
-- 	tf:setShaderProgram(qShader.Q_ProgramTTFOutline)
-- 	tf:setOpacity(tf:getContentSize().height / tf:getContentSize().width * 255)
-- 	local _setString = tf.setString
-- 	function tf:setString(str)
-- 		_setString(self, str)
-- 		tf:setOpacity(tf:getContentSize().height / tf:getContentSize().width * 255)
-- 	end
-- end

function setShadow4(tf, offset, color)
	if tf == nil then
		return
	end
	if tf.enableOutlineWithSize then 
		if color == nil then
			color = ccc3(45, 19, 0)
		end
		tf:setOutlineColor(color, true)
		tf:enableOutlineWithSize(2)
		return tf
	end
	if QDummyNode == nil then
		return setShadow(tf, offset)
	end

	local count = offset or 2
	local dummies = {}

	color = color or ccc3(45, 19, 0)

	local newTF = display.newNode()
	newTF:setPosition(tf:getPositionX(), tf:getPositionY())
	tf:setPosition(0, 0)

	for i = 1, count do
		offset = i
		local opacity = (count - i + 1) / count * 255
		if i > 1 then
			opacity = 0
		end
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(0, -offset)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(offset / 1.414, -offset / 1.414)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(offset, 0)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(offset / 1.414, offset / 1.414)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(0, offset)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(-offset / 1.414, offset / 1.414)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(-offset, 0)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
		local dummy = QDummyNode:create(tf)
		dummy:setPosition(-offset / 1.414, -offset / 1.414)
		dummy:setColor(color)
		dummy:setOpacity(opacity)
		newTF:addChild(dummy)
		dummies[#dummies + 1] = dummy
	end

	local parent = tf:getParent()
	if parent then
		tf:removeFromParent()
		parent:addChild(newTF)
	end
	
	newTF:addChild(tf)
	newTF:setCascadeOpacityEnabled(true)
	newTF.dummy = dummies
	newTF.tf = tf

	newTF:setCascadeOpacityEnabled(true)

	local g = newTF
    function g:setString(text)
    	tf:setString(text)
    end

    function g:getString()
        return tf:getString()
    end

    function g:realign(x, y)
        tf:setPosition(x, y)
    end

    function g:getContentSize()
        return tf:getContentSize()
    end

    function g:setColor(...)
        tf:setColor(...)
    end

    function g:setShadowColor(...)
    	for _, dummy in ipairs(dummies) do
        	dummy:setColor(...)
        end
    end

    function g:setVisible(...)
    	tf:setVisible(...)
    end

    -- function g:setOpacity(opacity)
    --     tf:setOpacity(opacity)
    --     for _, dummy in ipairs(dummies) do
    --     	dummy:setOpacity(opacity)
    --     end
    -- end

	return newTF
end

function setShadow6(tf, color)
	tf:enableOutline(true)
end

function setShadow5(tf, color)
	return setShadow4(tf, nil, color)
end

-- 根据字体的颜色色值，匹配描边颜色 by Kumo
-- 
function setShadowByFontColor(tf, fontColor, offsetColor)
	if not tf then return end
	local shadowColor = getShadowColorByFontColor(fontColor, offsetColor)
	if tf.dummy == nil then
		return setShadow4(tf, nil, shadowColor)
	else
		tf:setShadowColor(shadowColor)
		return tf
	end
end

function getShadowColorByFontColor(fontColor, offsetColor)
	local offsetColor = offsetColor or 10
	local shadowColor = QIDEA_STROKE_COLOR
	if fontColor then
		for _, value in ipairs(FONTCOLOR_TO_OUTLINECOLOR) do
			if (value.fontColor.r - offsetColor <= fontColor.r and fontColor.r <= value.fontColor.r + offsetColor) 
				and (value.fontColor.g - offsetColor <= fontColor.g and fontColor.g <= value.fontColor.g + offsetColor) 
				and (value.fontColor.b - offsetColor <= fontColor.b and fontColor.b <= value.fontColor.b + offsetColor) then
				shadowColor = value.outlineColor
			end
		end
	end 

	return shadowColor
end


--[[--

example:
	    local table_ = {}
		for i= 1,5 do
			table_[i] = self._ccbOwner["tf_"..i]
		end
		local heightss = setDimensionsAndFit(table_ ,CCSize(480, 0),10 ,-28,ccp(0,1))

@nodes_table 传入文本对象表table_
@dimensions 传入文本对象设定宽高 CCSize(480, 0)
@offside 传入文本对象行间距
@start_posY 传入起始位置 左上锚点
@ccp_anchor 传入文本对象锚点ccp（0，0）

@return 适配对象总高度

]]
function setDimensionsAndFit(nodes_table,dimensions,offside,start_posY,ccp_anchor)

	if nodes_table == nil then return nil end
	if #nodes_table < 1 then return nil end

	for i,node in ipairs(nodes_table) do
		if node then
			node:setDimensions(dimensions)
		end
	end
	local height = setLabelAutoVerticalFit(nodes_table,offside,start_posY,ccp_anchor)
	return height
end


--[[--
example:
	    local table_ = {}
		for i= 1,5 do
			table_[i] = self._ccbOwner["tf_"..i]
		end
		local heightss = setDimensionsAndFit(table_ ,10 ,-28,ccp(0,1))
@nodes_table 传入文本对象表table_
@offside 传入文本对象行间距
@start_posY 传入起始位置 左上锚点
@ccp_anchor 传入文本对象锚点ccp（0，0）


@return 适配对象总高度

]]
function setLabelAutoVerticalFit(nodes_table,offside,start_posY,ccp_anchor)
	if nodes_table == nil then return nil end
	if #nodes_table < 1 then return nil end
	if offside == nil then offside = 10 end
	if start_posY == nil then start_posY = 0 end
	if ccp_anchor == nil then ccp_anchor = ccp(0,0.5) end
	local height1_y = start_posY
	for i,node in ipairs(nodes_table) do
		if node then
			local length = node:getContentSize().height
			local min_ = 1 - ccp_anchor.y
			height1_y = height1_y - length * min_
			node:setAnchorPoint(ccp_anchor)
			print("my_height_y   "..height1_y)
			min_ = 1 - min_
			node:setPositionY(height1_y)
			height1_y = height1_y - length * min_ - offside
		end
	end
	height1_y = height1_y + offside - start_posY
	local total_height = height1_y * -1 
	return total_height
end

--[[--

创建带阴影的 TTF 文字显示对象，并返回 CCLabelTTF 对象。

相比 ui.newTTFLabel() 增加一个参数：

-   shadowColor: 阴影颜色（可选），用 ccc3() 指定，默认为黑色

@param table params 参数表格对象

@return CCLabelTTF CCLabelTTF对象

]]
function ui.newTTFLabelWithShadow(params)
    assert(type(params) == "table",
           "[framework.ui] newTTFLabelWithShadow() invalid params")

    local color       = params.color or display.COLOR_WHITE
    local shadowColor = params.shadowColor or display.COLOR_BLACK
    local x, y        = params.x, params.y

    local g = display.newNode()
    params.size = params.size
    params.color = shadowColor
    params.x, params.y = 0, 0
    g.shadow1 = ui.newTTFLabel(params)
    local offset = params.offset or 1 / (display.widthInPixels / display.width)
    g.shadow1:realign(offset, -offset)
    g:addChild(g.shadow1)

    params.color = color
    g.label = ui.newTTFLabel(params)
    g.label:realign(0, 0)
    g:addChild(g.label)

    function g:setString(text)
        g.shadow1:setString(text)
    	local offset = params.offset or 1 / (display.widthInPixels / display.width)
    	g.shadow1:realign(offset, -offset)
        g.label:setString(text)
   	 	g.label:realign(0, 0)
    end

    function g:getString()
        return g.label:getString()
    end

    function g:realign(x, y)
        g:setPosition(x, y)
    end

    function g:getContentSize()
        return g.label:getContentSize()
    end

    function g:setColor(...)
        g.label:setColor(...)
    end

    function g:setShadowColor(...)
        g.shadow1:setColor(...)
    end

    function g:setOpacity(opacity)
        g.label:setOpacity(opacity)
        g.shadow1:setOpacity(opacity)
    end

    -- function g:setAnchorPoint(ap)
    -- 	g.label:setAnchorPoint(ap)
    -- 	g.shadow1:setAnchorPoint(ap)
    -- end

    if x and y then
        g:setPosition(x, y)
    end

    return g
end

local fetchPoints = CCPointArray.fetchPoints
function CCPointArray:fetchPoints()
	local fetchedPoints = fetchPoints(self)
	scheduler.performWithDelayGlobal(function()
			QUtility:deleteCCPointArray(fetchedPoints)
		end, 0)
	return fetchedPoints
end

function cc.DrawNode:drawCircle(radius, params)
	local fillColor = cc.c4f(1,1,1,1)
	local borderColor = cc.c4f(1,1,1,1)
	local segments = 32
	local startRadian = 0
	local endRadian = math.pi*2
	local borderWidth = 0
	local posX = 0
	local posY = 0
	if params then
		if params.segments then segments = params.segments end
		if params.startAngle then
			startRadian = math.angle2Radian(params.startAngle)
		end
		if params.endAngle then
			endRadian = startRadian+math.angle2Radian(params.endAngle)
		end
		if params.fillColor then fillColor = params.fillColor end
		if params.borderColor then borderColor = params.borderColor end
		if params.borderWidth then borderWidth = params.borderWidth end
		if params.pos then
			posX =  params.pos[1]
			posY =  params.pos[2]
		end
	end
	local radianPerSegm = 2 * math.pi/segments
	local points = {}
	for i=1,segments do
		local radii = startRadian+i*radianPerSegm
		if radii > endRadian then break end
		table.insert(points, {posX + radius * math.cos(radii), posY + radius * math.sin(radii)})
	end
	self:drawPolygon(points, params)
	return self
end

function createRandomGenerator(seed)
	local seed = seed or q.OSTime()
	local _g = QRandomGenerator:create(seed)
	_g:retain()
    local g = {}
	function g.random(v1, v2)
		if v1 then
			v1 = math.floor(v1)
		end
		if v2 then
			v2 = math.floor(v2)
		end
		if not v1 and not v2 then
			return _g:genrand_real2()
		elseif not v2 then
			assert(math.floor(v1) == v1, "g.random(u), u is not an integer.")
			assert(v1 >= 1, "g.random(u), u is smaller than 1.")
			return math.floor(_g:genrand_real2() * v1) + 1
		else
			assert(math.floor(v1) == v1, "g.random(l, u), l is not an integer.")
			assert(math.floor(v2) == v2, "g.random(l, u), u is not an integer.")
			assert(v2 >= v1, "g.random(l, u), u is smaller than l.")
			return math.floor(_g:genrand_real2() * (v2 - v1 + 1)) + v1
		end
	end
	function g.getOriginalSeed()
		return seed
	end
	function g.setSeed(_seed)
		assert(_seed, "g:setSeed(seed), seed is not a number.")
		seed = _seed
		_g:init_genrand(seed)
	end
	function g.reset()
		_g:init_genrand(seed)
	end
	function g.release()
		_g:release()
		_g = nil
	end

	setmetatable(g, {__call = function(_, v1, v2) return g.random(v1, v2)  end})

	return g
end

-- 用于中心对齐Battle_Dialog_Victory中的魂师头像以及物品框
function centerAlignBattleDialogVictory2(ccbOwner, heroBox, teamCount, itemsBox, awardsNum)
	-- nzhang: hero heads center-align
	if heroBox then
		if teamCount > 0 and teamCount <= 4 then
			local gap = ccbOwner["hero_node2"]:getPositionX() - ccbOwner["hero_node1"]:getPositionX()
			for i = 1, teamCount do
				local parentNode = ccbOwner["hero_node"..i]
				local innerNode = heroBox[i]
				local globalPos = ccp(display.cx - (teamCount - 1) * gap * 0.5 + (i - 1) * gap, display.cy)
				innerNode:setPositionX(parentNode:getParent():convertToNodeSpace(globalPos).x - parentNode:getPositionX())
				-- timeline amendment
				if i == 1 then
					innerNode:setPositionX(innerNode:getPositionX() + 60)
				elseif i == 2 then
					innerNode:setPositionX(innerNode:getPositionX() + 40)
				elseif i == 3 then
					innerNode:setPositionX(innerNode:getPositionX() + 42)
				elseif i == 4 then
					innerNode:setPositionX(innerNode:getPositionX() + 40)
				end
				globalPos = nil
			end
		end
	end
	if itemsBox then
		-- nzhang: rewards center-align
		if awardsNum > 0 and awardsNum <= 5  then
			ccbOwner.node_item:setScale(1.0)
			local gap = ccbOwner["item2"]:getPositionX() - ccbOwner["item1"]:getPositionX()
			for i = 1, awardsNum do
				local parentNode = ccbOwner["item"..i]
				local innerNode = itemsBox[i]
				local globalPos = ccp(display.cx - (awardsNum - 1) * gap * 0.5 + (i - 1) * gap, display.cy)
				innerNode:setPositionX(parentNode:getParent():convertToNodeSpace(globalPos).x - parentNode:getPositionX())
				-- timeline amendment
				if i == 1 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (-43)))
				elseif i == 2 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (69)))
				elseif i == 3 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (179)))
				elseif i == 4 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (293)))
				elseif i == 5 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (404)))
				end
				globalPos = nil
			end
			ccbOwner.node_item:setScale(0.0)
		end
	end
end

-- 用于中心对齐Dialog_Panjun_zhandoushengli中的魂师头像以及物品框
function centerAlignDialogPanjunZhandoushengli(ccbOwner, heroBox, teamCount, itemsBox, awardsNum)
	-- nzhang: hero heads center-align
	-- if heroBox then
	-- 	if teamCount > 0 and teamCount <= 4 then
	-- 		local gap = ccbOwner["hero_node2"]:getPositionX() - ccbOwner["hero_node1"]:getPositionX()
	-- 		for i = 1, teamCount do
	-- 			local parentNode = ccbOwner["hero_node"..i]
	-- 			local innerNode = heroBox[i]
	-- 			local globalPos = ccp(display.cx - (teamCount - 1) * gap * 0.5 + (i - 1) * gap, display.cy)
	-- 			innerNode:setPositionX(parentNode:getParent():convertToNodeSpace(globalPos).x - parentNode:getPositionX())
	-- 			-- timeline amendment
	-- 			if i == 1 then
	-- 				innerNode:setPositionX(innerNode:getPositionX() + 60)
	-- 			elseif i == 2 then
	-- 				innerNode:setPositionX(innerNode:getPositionX() + 40)
	-- 			elseif i == 3 then
	-- 				innerNode:setPositionX(innerNode:getPositionX() + 42)
	-- 			elseif i == 4 then
	-- 				innerNode:setPositionX(innerNode:getPositionX() + 40)
	-- 			end
	-- 			globalPos = nil
	-- 		end
	-- 	end
	-- end
	if itemsBox then
		-- nzhang: rewards center-align
		if awardsNum > 0 and awardsNum <= 5  then
			ccbOwner.node_item:setScale(1.0)
			local gap = ccbOwner["item2"]:getPositionX() - ccbOwner["item1"]:getPositionX()
			for i = 1, awardsNum do
				local parentNode = ccbOwner["item"..i]
				local innerNode = itemsBox[i]
				local globalPos = ccp(display.cx - (awardsNum - 1) * gap * 0.5 + (i - 1) * gap, display.cy)
				innerNode:setPositionX(parentNode:getParent():convertToNodeSpace(globalPos).x - parentNode:getPositionX())
				-- timeline amendment
				if i == 1 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (-16)))
				elseif i == 2 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (84)))
				elseif i == 3 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (184)))
				elseif i == 4 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (284)))
				elseif i == 5 then
					innerNode:setPositionX(innerNode:getPositionX() + (parentNode:getPositionX() - (384)))
				end
				globalPos = nil
			end
			ccbOwner.node_item:setScale(0.0)
		end
	end
end

function q.makeButtonLight(node)
	setNodeShaderProgram(node, qShader.Q_ProgramPositionTextureColorOutlineWeak)
	traverseNode(node, function(subNode)
		local func = ccBlendFunc()
		func.src = GL_SRC_ALPHA
		func.dst = GL_ONE_MINUS_SRC_ALPHA
		if subNode.setBlendFunc then
			subNode:setBlendFunc(func)
			if subNode.getTexture then
				local size = subNode:getTexture():getContentSize()
    			subNode:setOpacityModifyRGB(false)
	    		local step = 80.0 / size.width * 255
	    		step = (step + (80.0 / size.height * 255)) / 2
	    		subNode:setOpacity(step)
	    	end
		end
	end)
end

function q.makeButtonNormal(node)
	setNodeShaderProgram(node, qShader.CC_ProgramPositionTextureColor)
	traverseNode(node, function(subNode)
		local func = ccBlendFunc()
		func.src = GL_ONE
		func.dst = GL_ONE_MINUS_SRC_ALPHA
		if subNode.setBlendFunc then
			subNode:setBlendFunc(func)
			if subNode.getTexture then
    			subNode:setOpacityModifyRGB(true)
    			subNode:setOpacity(255)
    		end
		end
	end)
end

function q.buttonEvent(event, node, node2)
	if event == nil then
		return true
	end
	if tonumber(event) == CCControlEventTouchDown then
		-- makeNodeFromNormalToGray(node)
		q.makeButtonLight(node)
		q.makeButtonLight(node2)
	else
		-- makeNodeFromGrayToNormal(node)
		q.makeButtonNormal(node)
		q.makeButtonNormal(node2)
	end
	if tonumber(event) ~= CCControlEventTouchUpInside then return false end
	return true
end

function q.setNodeShadow(node, isShadow)
	traverseNode(node, function(subNode)
		if tolua.type(subNode) == "CCSprite" then
			if isShadow then
				subNode:setColor(ccc3(168, 168, 168))
			else
				subNode:setColor(ccc3(255, 255, 255))
			end
		end
	end)
end

function q.buttonEventShadow(event, node)
	if event == nil or not tonumber(event) or tonumber(event) == 0 then
		return true
	end
	if tonumber(event) == CCControlEventTouchDown then
		node:setColor(ccc3(210, 210, 210))
	else
		node:setColor(ccc3(255, 255, 255))
	end
	if tonumber(event) ~= CCControlEventTouchUpInside then return false end
	return true
end

function q.setNodePreviousShader(node, program)
	previousShaderDict[node] = program
end

function q.getNodePreviousShader(node)
	local program = previousShaderDict[node]
	-- if proGram == nil then
	-- 	return CCShaderCache:sharedShaderCache():programForKey(qShader.kCCShader_PositionTextureColor)
	-- end

	previousShaderDict[node] = nil

	return program
end

function q.nodeAddGLLayer(node, layerIndex)
	local nextLayerIndex = 0
	if node and node.setGLLayer then
    	node:setGLLayer(layerIndex)
    	if node.getGLLayer then
    		nextLayerIndex = node:getGLLayer() + 1
    	else
    		nextLayerIndex = layerIndex + 1
    	end

    	return nextLayerIndex
    end
    
    return layerIndex
end

function q.setButtonEnableShadow(button)
	if button == nil then return end
	
	local sp = button:getBackgroundSpriteForState(CCControlStateHighlighted)
	sp:setColor(ccc3(210, 210, 210))
end

function q.converFun(time)
	local str = ""
	local day = math.floor(time/DAY)
	time = time%DAY
	local hour = math.floor(time/HOUR)
	hour = hour < 10 and "0"..hour or hour
	time = time%HOUR
	local min = math.floor(time/MIN)
	min = min < 10 and "0"..min or min
	time = time%MIN
	local sec = math.floor(time)
	sec = sec < 10 and "0"..sec or sec
	if day > 0 then
		str = day.."天 "..hour..":"..min..":"..sec
	else
		str = hour..":"..min..":"..sec
	end
	return str
end


function q.flashFrameTransferDur(flashFrame)
	return flashFrame/30
end
