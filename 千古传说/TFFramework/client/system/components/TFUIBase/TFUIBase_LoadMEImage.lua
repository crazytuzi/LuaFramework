local TFUIBase 					= TFUIBase
local TFUIBase_setFuncs 		= TFUIBase_setFuncs
local TFUIBase_setFuncs_new 	= TFUIBase_setFuncs_new
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR
local TFUI_VERSION_ALPHA 		= TFUI_VERSION_ALPHA
local TF_TEX_TYPE_LOCAL 		= TF_TEX_TYPE_LOCAL
local TF_TEX_TYPE_PLIST 		= TF_TEX_TYPE_PLIST
local ccc3 						= ccc3
local ccp 						= ccp
local bit_and 					= bit_and
local bit_rshift				= bit_rshift
local CCSizeMake 				= CCSizeMake
local CCRectMake 				= CCRectMake
local string 					= string


function TFUIBase:initMEImage(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEImage_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEImage_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEImage_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEImage_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEImage_MEEDITOR(pval, parent)
	local val = pval
	local tex = val['texturePath'] or val['url']

	if tex and tex ~= "" and  self.setTexture then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['texturePath_plist'] and val['texturePath_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['texturePath_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTexture(tex, textureType)
	end	

	if val['bIsCorrds'] == "True" then
		self:setImageSizeType(2)
	end

	if val['backGroundScale9Enable'] and self.setScale9Enabled then
		local bIsNotScale9Enable = val['backGroundScale9Enable'] == "False"
		if not bIsNotScale9Enable then 
			self:setScale9Enabled(true)
			local t9Param = {}
			string.gsub(val['backGroundScale9Enable'], '(%w*):([#A-Za-z0-9]*)', function(szKey, szVal)
				if szKey then 
					t9Param[szKey] = szVal
				end
			end)
			local cx = t9Param['capInsetsX'] + 0
			local cy = t9Param['capInsetsY'] + 0
			local cw = t9Param['capInsetsWidth'] + 0
			local ch = t9Param['capInsetsHeight'] + 0
			self:setCapInsets(CCRectMake(cx, cy, cw, ch))
		end
	end
	
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEImage_NEWMEEDITOR(pval, parent)
	local val = pval.tImageProperty
	if val.szTexturePath ~= "" and  self.setTexture then 
		self:setTexture(val.szTexturePath)
	end	

	-- if val['bIsCorrds'] == "True" then
	-- 	self:setImageSizeType(2)
	-- end

	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEImage_COCOSTUDIO(pval, parent)
	local val = pval.options
	local fileNameDic = val['fileNameData']	
	if fileNameDic and fileNameDic.path then
		local fileNameType = fileNameDic.resourceType
		if fileNameType == 0 then
			local path = fileNameDic.path
			self:setTexture(path)
		else
			me.FrameCache:addSpriteFramesWithFile(fileNameDic.plistFile)
			self:setTexture(fileNameDic.path, TF_TEX_TYPE_PLIST)
		end
	end

	if val['scale9Enable'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enable'])
	end	
	if val['scale9Enabled'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enabled'])
	end		

	if (val['scale9Enable'] or val['scale9Enabled']) and val['capInsetsX'] then
		local cx = val['capInsetsX'] or 0
		local cy = val['capInsetsY'] or 0
		local cw = val['capInsetsWidth'] or 0
		local ch = val['capInsetsHeight'] or 0
		self:setCapInsets(CCRectMake(cx, cy, cw, ch))

		if val['scale9Width'] or val['scale9Height'] then 
			local cs = self:getSize()
			local width = val['scale9Width'] or cs.width
			local height = val['scale9Height'] or cs.height
			self:setSize(CCSizeMake(width, height))
		end	
	end
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEImage_ALPHA(pval, parent)
	local val = pval
	if val['texture'] then 
		self:setTexture(val['texture'])
	end

	if val['scale9Enable'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enable'])
	end	
	if val['scale9Enabled'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enabled'])
	end		
	if val.scale9Enable or val.scale9Enabled then
		self:setScale9Enabled(true)
		local isSetRect = false

		if val.left 	then isSetRect = true end
		if val.right 	then isSetRect = true end
		if val.top 	then isSetRect = true end
		if val.bottom 	then isSetRect = true end
		if isSetRect then
			local size = self:getTextureRect().size
			val.left 	= val.left 		or size.width / 3.0
			val.right 	= val.right 	or size.width / 3.0
			val.top 	= val.top 		or size.height / 3.0
			val.bottom 	= val.bottom 	or size.height / 3.0
			self:setCapInsets(CCRectMake(val.left, 
										val.top, 
										size.width - val.left - val.right, 
										size.height - val.top - val.bottom))
		end
		
	end
	
	if val.coordEnable and self.setCoordsSize then
		local cs = self:getSize()
		local width = val['width'] or cs.width
		local height = val['height'] or cs.height
		self:setCoordsSize(width, height, 0, 0)
	end
	
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end