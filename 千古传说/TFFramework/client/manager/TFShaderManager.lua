--[[--
	shader管理器:

	--By: yuqing
	--2013/10/30
]]
TFShaderManager = class("TFShaderManager", TFShaderManager)
local ccshader_defualtVert = nil

function TFShaderManager:init()
	-- self:addShaderWithFilename("TFFramework/shaders/meShader_OutLine2.fsh", "TFFramework/shaders/ccShader_TexturePositionColor.vsh", "OutLine2")
	-- self:addShaderWithFilename("TFFramework/shaders/ccShader_Label_df_glow.fsh", "TFFramework/shaders/ccShader_TexturePositionColor.vsh", "GLOW")
end

function TFShaderManager:setUniform1i(shadeName, uniformName, value)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith1i(location, value)
	end
end

function TFShaderManager:setUniform2i(shadeName, uniformName, ...)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith2i(location, ...)
	end
end

function TFShaderManager:setUniform3i(shadeName, uniformName, ...)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith3i(location, ...)
	end
end

function TFShaderManager:setUniform4i(shadeName, uniformName, ...)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith4i(location, ...)
	end
end

function TFShaderManager:setUniform1f(shadeName, uniformName, value)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith1f(location, value)
	end
end

function TFShaderManager:setUniform2f(shadeName, uniformName, ...)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith2f(location, ...)
	end
end

function TFShaderManager:setUniform3f(shadeName, uniformName, ...)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith3f(location, ...)
	end
end

function TFShaderManager:setUniform4f(shadeName, uniformName, ...)
	local shader = me.ShaderCache:programForKey(shadeName)
	if shader then 
		shader:use()
		local location = shader:getUniformLocationForName(uniformName)
		shader:setUniformLocationWith4f(location, ...)
	end
end

function TFShaderManager:addShaderWithFilename(szFFilename, szVFilename, szShaderName)
	if szVFilename == nil then
		szVFilename = "TFFramework/shaders/ccShader_TexturePositionColor.vsh"
	end
	return me.ShaderCache:addProgramWithFilename(szVFilename, szFFilename, szShaderName)
end

function TFShaderManager:addShaderWithShader(szFContent, szVContent, szShaderName)
	if szVContent == nil then
		ccshader_defualtVert = ccshader_defualtVert or CCString:createWithContentsOfFile(me.FileUtils:fullPathForFilename("TFFramework/shaders/ccShader_TexturePositionColor.vsh")):getCString()
		szVContent = ccshader_defualtVert
	end
	return me.ShaderCache:addProgramWithShaderContent(szVContent,szFContent,szShaderName)
end

function TFShaderManager:removeAllShader()
	me.ShaderCache:purge()
end

return TFShaderManager:new()