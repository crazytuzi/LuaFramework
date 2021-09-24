CCShader.ccPositionTextureColor_vert = "\n\
attribute vec4 a_position;\n\
attribute vec2 a_texCoord;\n\
attribute vec4 a_color;\n\
#ifdef GL_ES\n\
	varying lowp vec4 v_fragmentColor;\n\
	varying mediump vec2 v_texCoord;\n\
#else\n\
	varying vec4 v_fragmentColor;\n\
	varying vec2 v_texCoord;\n\
#endif\n\
void main()\n\
{\n\
	gl_Position = CC_MVPMatrix * a_position;\n\
	v_fragmentColor = a_color;\n\
	v_texCoord = a_texCoord;\n\
}\n\
"


--[[
    自定义shader
    命名格式：
        - 顶点shader：CCShader.VSH_xxx
        - 片段shader：CCShader.FSH_xxx
--]]



-- 置灰效果的片段shader
CCShader.FSH_Gray = "\n\
#ifdef GL_ES\n\
	precision mediump float;\n\
#endif\n\
uniform sampler2D u_texture;\n\
varying vec2 v_texCoord;\n\
varying vec4 v_fragmentColor;\n\
void main(void)\n\
{\n\
	vec4 col = v_fragmentColor * texture2D(u_texture, v_texCoord);\n\
	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));\n\
	gl_FragColor = vec4(gray, gray, gray, col.a);\n\
}\n\
"

-- 提审包版本的片段shader
CCShader.FSH_ApplyVersionUIColor = "\n\
#ifdef GL_ES\n\
	precision mediump float;\n\
#endif\n\
varying vec4 v_fragmentColor;\n\
varying vec2 v_texCoord;\n\
uniform sampler2D u_texture;\n\
void main()\n\
{\n\
	vec4 color1 = texture2D(u_texture, v_texCoord) * v_fragmentColor;\n\
	float brightness = (color1.r + color1.g + color1.b) * (1. / 3.);\n\
	float gray = (0.5) * brightness;\n\
	color1 = vec4(gray, gray, gray, color1.a) * vec4(0.8, 2.5, 2.8, 1);\n\
	gl_FragColor = color1;\n\
}\n\
"

-- HSL片段shader
CCShader.FSH_HSL = "\n\
#ifdef GL_ES\n\
    precision mediump float;\n\
#endif\n\
varying vec2 v_texCoord;\n\
uniform sampler2D CC_Texture0;\n\
void main()\n\
{\n\
	float u_dH = %f;    //色调H\n\
	float u_dS = %f;    //饱和度S\n\
	float u_dL = %f;    //亮度L\n\
    vec4 texColor = texture2D(CC_Texture0, v_texCoord);\n\
    float r = texColor.r; float g = texColor.g; float b = texColor.b; float a = texColor.a;\n\
    //rgb 转换到 hsl\n\
    float h; float s; float l;\n\
    {\n\
        float max = max(max(r, g), b);\n\
        float min = min(min(r, g), b);\n\
        //----h\n\
        if(max == min){\n\
            h = 0.0;\n\
        }else if(max == r && g >= b){\n\
            h = 60.0 * (g - b) / (max - min) + 0.0;\n\
        }else if(max == r && g < b){\n\
            h = 60.0 * (g -b) / (max - min) + 360.0;\n\
        }else if(max == g){\n\
            h = 60.0 * (b - r) / (max-min) + 120.0;\n\
        }else if(max==b){\n\
            h = 60.0 * (r - g) / (max-min) + 240.0;\n\
        }\n\
        //----l\n\
        l = 0.5 * (max + min);\n\
        //----s\n\
        if(l == 0.0 || max == min){\n\
            s = 0.0;\n\
        }else if(0.0 <= l && l <= 0.5){\n\
            s = (max - min) / (2.0 * l);\n\
        }else if(l > 0.5){\n\
            s= (max - min) / (2.0 - 2.0 * l);\n\
        }\n\
    }\n\
    //(h,s,l)+(dH,dS,dL) -> (h,s,l)\n\
    h = h + u_dH;\n\
    s = min(1.0, max(0.0, s + u_dS));\n\
    l = l + u_dL;\n\
    //转换 (h,s,l) 到 rgb\n\
    vec4 finalColor;\n\
    {\n\
        float q;\n\
        if(l < 0.5){\n\
            q = l * (1.0 + s);\n\
        }else if(l >= 0.5){\n\
            q= l + s - l * s;\n\
        }\n\
        float p = 2.0 * l - q;\n\
        float hk = h / 360.0;\n\
        float t[3];\n\
        t[0] = hk + 1.0 / 3.0; t[1] = hk; t[2] = hk - 1.0 / 3.0;\n\
        for(int i=0; i<3; i++){\n\
            if(t[i] < 0.0) t[i] += 1.0;\n\
            if(t[i] > 1.0) t[i] -= 1.0;\n\
        }\n\
        float c[3];\n\
        for(int i=0; i<3; i++){\n\
            if(t[i] < 1.0 / 6.0){\n\
                c[i] = p + ((q - p) * 6.0 * t[i]);\n\
            }else if(1.0 / 6.0 <= t[i] && t[i] < 0.5){\n\
                c[i] = q;\n\
            }else if(0.5 <= t[i] && t[i] < 2.0 / 3.0){\n\
                c[i] = p + ((q - p) * 6.0 * (2.0 / 3.0 - t[i]));\n\
            }else{\n\
                c[i] = p;\n\
            }\n\
        }\n\
        finalColor=vec4(c[0], c[1], c[2], a);\n\
    }\n\
    finalColor += vec4(u_dL, u_dL, u_dL, 0.0);\n\
    gl_FragColor = finalColor;\n\
}\n\
"

-- 冰冻效果的顶点shader
CCShader.VSH_EffectFrozen = "\n\
attribute vec4 a_position;\n\
attribute vec2 a_texCoord;\n\
attribute vec4 a_color;\n\
#ifdef GL_ES\n\
    varying lowp vec4 v_fragmentColor;\n\
    varying mediump vec2 v_texCoord;\n\
#else\n\
    varying vec4 v_fragmentColor;\n\
    varying vec2 v_texCoord;\n\
#endif\n\
void main()\n\
{\n\
    gl_Position = CC_MVPMatrix * a_position;\n\
    v_fragmentColor = a_color;\n\
    v_texCoord = a_texCoord;\n\
}\n\
"

-- 冰冻效果的片段shader
CCShader.FSH_EffectFrozen = "\n\
#ifdef GL_ES\n\
    precision mediump float;\n\
#endif\n\
varying vec4 v_fragmentColor;\n\
varying vec2 v_texCoord;\n\
uniform sampler2D u_texture;\n\
void main()\n\
{\n\
    vec4 textureColor = texture2D(u_texture, v_texCoord) * v_fragmentColor;\n\
    float brightness = (textureColor.r + textureColor.g + textureColor.b) * (1. / 3.);\n\
    float gray = 1.5 * brightness;\n\
    textureColor = vec4(gray, gray, gray, textureColor.a) * vec4(0.8, 1.2, 1.5, 1);\n\
    gl_FragColor = textureColor;\n\
}\n\
"

-- 老照片效果的片段shader
CCShader.FSH_EffectReminiscence = "\n\
#ifdef GL_ES\n\
    precision mediump float;\n\
#endif\n\
uniform sampler2D u_texture;\n\
varying vec2 v_texCoord;\n\
varying vec4 v_fragmentColor;\n\
void main(void)\n\
{\n\
    vec3 col = texture2D(u_texture, v_texCoord).rgb;\n\
    float r = 0.393 * col.r + 0.769 * col.g + 0.189 * col.b;\n\
    float g = 0.349 * col.r + 0.686 * col.g + 0.168 * col.b;\n\
    float b = 0.272 * col.r + 0.534 * col.g + 0.131 * col.b;\n\
    gl_FragColor = vec4(r, g, b, 1.0);\n\
}\n\
"

-- 熔铸效果的片段shader
CCShader.FSH_EffectCasting = "\n\
#ifdef GL_ES\n\
    precision mediump float;\n\
#endif\n\
uniform sampler2D u_texture;\n\
varying vec2 v_texCoord;\n\
varying vec4 v_fragmentColor;\n\
void main(void)\n\
{\n\
    vec3 col = texture2D(u_texture, v_texCoord).rgb;\n\
    float r = col.r * 0.5 / (col.g + col.b);\n\
    float g = col.g * 0.5 / (col.r + col.b);\n\
    float b = col.b * 0.5 / (col.r + col.g);\n\
    gl_FragColor = vec4(r, g, b, 1.0);\n\
}\n\
"