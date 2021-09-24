_G.ShaderUtil={}

function ShaderUtil.__getDefaultVert(self,_isSpine)
    local szMatrix=_isSpine and "(CC_PMatrix * CC_MVMatrix)" or "CC_PMatrix"
    local szFile="attribute vec4 a_position; \n" ..
        "attribute vec2 a_texCoord; \n" ..
        "attribute vec4 a_color; \n"..                                                    
        "#ifdef GL_ES  \n"..
        "varying lowp vec4 v_fragmentColor;\n"..
        "varying mediump vec2 v_texCoord;\n"..
        "#else                      \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord;  \n"..
        "#endif    \n"..
        "void main() \n"..
        "{\n" ..
        "gl_Position = "..szMatrix.." * a_position; \n"..
        "v_fragmentColor = a_color;\n"..
        "v_texCoord = a_texCoord;\n"..
        "}"
    return szFile
end

function ShaderUtil.__getFlagFile(self,_isSpine,_rgb,_r,_g,_b)
    _rgb=_rgb or {r=1,g=1,b=1,a=1}
    _r=_r or "0.0"
    _g=_g or "0.0"
    _b=_b or "0.0"

    local szTexture=_isSpine and "u_texture" or "CC_Texture0"
    local szFile="#ifdef GL_ES \n" ..
        "precision mediump float; \n" ..
        "#endif \n" ..
        "uniform sampler2D u_texture; \n" ..
        "varying vec2 v_texCoord; \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "void main(void) \n" ..
        "{ \n" ..
            "vec4 normalColor = v_fragmentColor * texture2D("..szTexture..", v_texCoord); \n" ..
            "normalColor *= "..string.format("vec4(%s,%s,%s,%s)",tostring(_rgb.r),tostring(_rgb.g),tostring(_rgb.b),"1").."; \n" ..
            "normalColor.r += normalColor.a*".._r.." ; \n" ..
            "normalColor.g += normalColor.a*".._g.." ; \n" ..
            "normalColor.b += normalColor.a*".._b.." ; \n" ..
            "gl_FragColor = normalColor; \n" ..
        "}"
    return szFile
end

local keyFlag_normal=0
local keyFlag_poisoning=1
local keyFlag_burn=2
local keyFlag_freeze=3
local keyFlag_Invincible=4
local keyFlag_InvincibleHurt=6
local keyFlag_Petrifaction=7
local keyFlag_white_hight=11
local keyFlag_white_hight1=13
local keyFlag_black=12
local keyFlag_mirror=14

local VERT_SPINE=_G.ShaderUtil:__getDefaultVert(true)
local VERT_NORMAL=_G.ShaderUtil:__getDefaultVert(false)

-- Buff颜色调节
local FLAG_SPINE_ARRAY={
    [keyFlag_normal]=_G.ShaderUtil:__getFlagFile(true,{r=1,g=1,b=1}),
    [keyFlag_poisoning]=_G.ShaderUtil:__getFlagFile(true,{r=0.8,g=0.8,b=0.8},0.08,0.2,nil),
    [keyFlag_burn]=_G.ShaderUtil:__getFlagFile(true,{r=0.99,g=0.37,b=0},nil,nil,nil),
    [keyFlag_freeze]=_G.ShaderUtil:__getFlagFile(true,{r=0.72,g=0.8,b=0.96},nil,nil,0.2),
    -- [keyFlag_Invincible]=_G.ShaderUtil:__getFlagFile(true,{r=1,g=1,b=0.4},nil,nil,0.2),
    [keyFlag_Invincible]=_G.ShaderUtil:__getFlagFile(true,{r=2,g=1.8,b=0},nil,nil,nil),
    [keyFlag_InvincibleHurt]=_G.ShaderUtil:__getFlagFile(true,{r=5,g=4.5,b=0},nil,nil,nil),
    [keyFlag_Petrifaction]=_G.ShaderUtil:__getFlagFile(true,{r=0.2,g=0.2,b=0.2},0.1,0.1,0.1),
    [keyFlag_mirror]=_G.ShaderUtil:__getFlagFile(true,{r=0.2,g=0.2,b=0.2},0.1,0.1,0.1),
}
local FLAG_NORMAL_ARRAY={
    [keyFlag_normal]=_G.ShaderUtil:__getFlagFile(false,{r=1,g=1,b=1}),
    [keyFlag_white_hight]=_G.ShaderUtil:__getFlagFile(false,{r=5,g=5,b=5},nil,nil,nil),
    [keyFlag_white_hight1]=_G.ShaderUtil:__getFlagFile(false,{r=5,g=5,b=5},0.7,0.7,0.7),
    [keyFlag_black]=_G.ShaderUtil:__getFlagFile(false,{r=0.2,g=0.2,b=0.2},nil,nil,nil),
}

-- "#ifdef GL_ES \n" ..
--     "precision mediump float; \n" ..
--     "#endif \n" ..
--     "varying vec2 v_texCoord; \n" ..
--     "uniform mat3 u_hue; \n" ..
--     "uniform float u_alpha; \n" ..
--     "void main(void) \n" ..
--     "{ \n" ..
--     "vec4 pixColor = texture2D(CC_Texture0, v_texCoord); \n" ..
--     "vec3 rgbColor = u_hue * pixColor.rgb; \n" ..
--     "gl_FragColor = vec4(rgbColor, pixColor.a * u_alpha); \n" ..
--     "}"

local Shader_name_spine="lua_shader_program_spine"
local Shader_name_normal="lua_shader_program_normal_"



function ShaderUtil.getShader(self,_vertFile,_flagFile,_szKey)
	if _vertFile==nil or _flagFile==nil then return end

    local pProgram=nil
    if _szKey~=nil then
        pProgram=cc.GLProgramCache:getInstance():getGLProgram(_szKey)
    end
    --pProgram=nil
	if pProgram==nil then
		pProgram=cc.GLProgram:createWithByteArrays(_vertFile,_flagFile)
	    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
	    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
	    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
	    pProgram:link()
	    pProgram:updateUniforms()

        if _szKey~=nil then
	       cc.GLProgramCache:getInstance():addGLProgram(pProgram,_szKey)
       end
	end
	
    return pProgram
end

function ShaderUtil.shaderNormalById(self,_node,_idx)
    local myShader=self:getShader(VERT_NORMAL,FLAG_NORMAL_ARRAY[_idx],string.format("%s%d",Shader_name_normal,_idx))
    if myShader~=nil then
        _node:setGLProgram(myShader)
    else
        print("[ShaderUtil] shaderNormalById error! not found shader by idx",_idx)
    end
end

function ShaderUtil.shaderSpineById(self,_node,_idx)
	local myShader=self:getShader(VERT_SPINE,FLAG_SPINE_ARRAY[_idx],string.format("%s%d",Shader_name_spine,_idx))
	if myShader~=nil then
		_node:setGLProgram(myShader)
    else
        print("[ShaderUtil] shaderSpineById error! not found shader by idx",_idx)
	end
end

function ShaderUtil.resetNormalShader(self,_node)
    self:shaderNormalById(_node,keyFlag_normal)
end
function ShaderUtil.resetSpineShader(self,_node)
	self:shaderSpineById(_node,keyFlag_normal)
end
-- 中毒
function ShaderUtil.setPoisoningShader(self,_node)
	self:shaderSpineById(_node,keyFlag_poisoning)
end
-- 烧伤
function ShaderUtil.setBurnShader(self,_node)
	self:shaderSpineById(_node,keyFlag_burn)
end
-- 冰冻
function ShaderUtil.setFreezeShader(self,_node)
	self:shaderSpineById(_node,keyFlag_freeze)
end
-- 霸体
function ShaderUtil.setInvincibleShader(self,_node)
    self:shaderSpineById(_node,keyFlag_Invincible)
end
-- 霸体受伤
function ShaderUtil.setInvincibleHurtShader(self,_node)
    self:shaderSpineById(_node,keyFlag_InvincibleHurt)
end
-- 石化
function ShaderUtil.setPetrifaction(self,_node)
    self:shaderSpineById(_node,keyFlag_Petrifaction)
end
