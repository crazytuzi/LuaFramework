CCShader = CCShader or {}

require "luascript/script/shader/shader"

-- Cocos提供的内置shader，从ShaderCache中读取
CCShader.kCCShader_PositionTextureColor          = "ShaderPositionTextureColor"
CCShader.kCCShader_PositionTextureColorAlphaTest = "ShaderPositionTextureColorAlphaTest"
CCShader.kCCShader_PositionColor                 = "ShaderPositionColor"
CCShader.kCCShader_PositionTexture               = "ShaderPositionTexture"
CCShader.kCCShader_PositionTexture_uColor        = "ShaderPositionTexture_uColor"
CCShader.kCCShader_PositionTextureA8Color        = "ShaderPositionTextureA8Color"
CCShader.kCCShader_Position_uColor               = "ShaderPosition_uColor"
CCShader.kCCShader_PositionLengthTexureColor     = "ShaderPositionLengthTextureColor"

-- Attribute names
CCShader.kCCAttributeNamePosition = "a_position"
CCShader.kCCAttributeNameColor 	  = "a_color"
CCShader.kCCAttributeNameTexCoord = "a_texCoord"

--[[ 
	自定义的shader并加入到shader缓存中
		- key的命名格式：kShader_xxx
		- value[1]：顶点shader或.vsh路径
		- value[2]：片段shader或.fsh路径
		- value[3]：（*暂时不用，保留字段）加入到缓存中的判断条件方法，默认为nil(加入缓存)
--]]
CCShader.shaderCache = {
	-- 这两个shader用于提审包版本，非该版本就请注释掉这个两个shader
	["kShader_ApplyVersion"] = { CCShader.ccPositionTextureColor_vert, CCShader.FSH_ApplyVersionUIColor },
	["kShader_ApplyVersion_HSL"] = { CCShader.ccPositionTextureColor_vert, string.format(CCShader.FSH_HSL, 50, 0, 0) },
}

function CCShader:loadShaderCache()
	if CCShaderCache == nil or CCShaderCache.sharedShaderCache == nil then
		return
	end
	for key, value in pairs(CCShader.shaderCache) do
		-- if value[3] == nil or (type(value[3]) == "function" and value[3]() == true) then
		local program = CCShader:createShaderProgram(value[1], value[2])
		if program then
			CCShaderCache:sharedShaderCache():addProgram(program, key)
		end
		-- end
	end
end

function CCShader:setGray(ccNode)
	if tolua.cast(ccNode, "CCNode") and ccNode.setShaderProgram then
		local program = CCShader:createShaderWithByteArray(CCShader.ccPositionTextureColor_vert, CCShader.FSH_Gray)
		ccNode:setShaderProgram(program)
	end
end

--h:色相[0~360], s:饱和度[0~1], l:亮度[0~1]
function CCShader:setHSL(ccNode, h, s, l)
	if tolua.cast(ccNode, "CCNode") and ccNode.setShaderProgram then
		if type(h) ~= "number" or type(s) ~= "number" or type(l) ~= "number" then
			return
		end
		h = (h < 0) and 0 or h
		h = (h > 360) and 360 or h
		s = (s < 0) and 0 or s
		s = (s > 1) and 1 or s
		l = (l < 0) and 0 or l
		l = (l > 1) and 1 or l
		local program = CCShader:createShaderWithByteArray(CCShader.ccPositionTextureColor_vert, string.format(CCShader.FSH_HSL, h, s, l))
		if program then
			ccNode:setShaderProgram(program)
		end
	end
end

function CCShader:resetShaderProgram(ccNode)
	if tolua.cast(ccNode, "CCNode") and ccNode.setShaderProgram and CCShaderCache then
		ccNode:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey(CCShader.kCCShader_PositionTextureColor))
	end
end

function CCShader:setShaderProgram(ccNode, vertShader, fragShader)
	if tolua.cast(ccNode, "CCNode") and ccNode.setShaderProgram then
		local program = CCShader:createShaderProgram(vertShader, fragShader)
		if program then
			ccNode:setShaderProgram(program)
		end
	end
end

function CCShader:createShaderProgram(vertShader, fragShader)
	if type(vertShader) == "string" and fragShader == nil then
		if CCShaderCache == nil or CCShaderCache.sharedShaderCache == nil then
			return
		end
		return CCShaderCache:sharedShaderCache():programForKey(vertShader)
	end
	if type(vertShader) ~= "string" or type(fragShader) ~= "string" then
		return
	end
	local program
	if string.find(vertShader, ".vsh") and string.find(fragShader, ".fsh") then
		program = CCShader:createShaderWithFilename(vertShader, fragShader)
	else
		program = CCShader:createShaderWithByteArray(vertShader, fragShader)
	end
	return program
end

function CCShader:createShaderWithByteArray(vertShaderByteArray, fragShaderByteArray)
	if CCGLProgram == nil then
		return
	end
	if type(vertShaderByteArray) ~= "string" or type(fragShaderByteArray) ~= "string" then
		return
	end
	local program = CCGLProgram:createWithVertexShaderByteArray(vertShaderByteArray, fragShaderByteArray)
    program:addAttribute(CCShader.kCCAttributeNamePosition, kCCVertexAttrib_Position)
    program:addAttribute(CCShader.kCCAttributeNameColor, kCCVertexAttrib_Color)
    program:addAttribute(CCShader.kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords)
    program:link()
    program:updateUniforms()
    return program
end

function CCShader:createShaderWithFilename(vertShaderFilename, fragShaderFilename)
	if CCGLProgram == nil then
		return
	end
	if type(vertShaderFilename) ~= "string" or type(fragShaderFilename) ~= "string" then
		return
	end
	if string.find(vertShaderFilename, ".vsh") and string.find(fragShaderFilename, ".fsh") then
		local program = CCGLProgram:createWithVertexShaderFilename(vertShaderFilename, fragShaderFilename)
		program:addAttribute(CCShader.kCCAttributeNamePosition, kCCVertexAttrib_Position)
	    program:addAttribute(CCShader.kCCAttributeNameColor, kCCVertexAttrib_Color)
	    program:addAttribute(CCShader.kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords)
	    program:link()
	    program:updateUniforms()
	    return program
	end
end