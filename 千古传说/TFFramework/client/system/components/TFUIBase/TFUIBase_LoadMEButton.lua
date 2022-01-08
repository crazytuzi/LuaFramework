local TFUIBase 					= TFUIBase
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR
local TFUI_VERSION_ALPHA 		= TFUI_VERSION_ALPHA
local TF_TEX_TYPE_LOCAL 		= TF_TEX_TYPE_LOCAL
local TF_TEX_TYPE_PLIST 		= TF_TEX_TYPE_PLIST
local CCRectMake 				= CCRectMake
local string 					= string

function TFUIBase:initMEButton(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEButton_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEButton_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEButton_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEButton_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEButton_MEEDITOR(pval, parent)
	local val = pval
	if val['normal'] and val['normal'] ~= "" and self.setTextureNormal then
		local textureType = TF_TEX_TYPE_LOCAL
		if val['normal_plist'] and val['normal_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['normal_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTextureNormal(val['normal'], textureType)
	end

	if val['pressed'] and val['pressed'] ~= "" and self.setTexturePressed then
		local textureType = TF_TEX_TYPE_LOCAL
		if val['pressed_plist'] and val['pressed_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['pressed_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTexturePressed(val['pressed'], textureType)
	end

	if val['disabled'] and val['disabled'] ~= "" and self.setTextureDisabled then
		local textureType = TF_TEX_TYPE_LOCAL
		if val['disabled_plist'] and val['disabled_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['disabled_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTextureDisabled(val['disabled'], textureType)
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
			local rect = CCRectMake(cx, cy, cw, ch)
			self:setCapInsets(rect)
			-- self:setCapInsetsNormalRenderer(rect)
			-- self:setCapInsetsPressedRenderer(rect)
			-- self:setCapInsetsDisabledRenderer(rect)
		end
	end

	if val['ClickHighLightEnabled'] and self.setClickHighLightEnabled then
		self:setClickHighLightEnabled(val['ClickHighLightEnabled'] == "True")
	end


	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEButton_NEWMEEDITOR(pval, parent)
	local val = pval.tButtonProperty
	if val.szNormalTexture and val.szNormalTexture ~= "" and self.setTextureNormal then
		self:setTextureNormal(val.szNormalTexture)
	end

	if val.szPressedTexture and val.szPressedTexture ~= "" and self.setTexturePressed then
		self:setTexturePressed(val.szPressedTexture)
	end

	if val.szDisabledTexture and val.szDisabledTexture ~= "" and self.setTextureDisabled then
		self:setTextureDisabled(val.szDisabledTexture)
	end

	if val.bIsClickHightLight == false and self.setClickHighLightEnabled then
		self:setClickHighLightEnabled(false)
	end


	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEButton_COCOSTUDIO(pval, parent)
	local val = pval.options
	if val['scale9Enable'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enable'])
	end	
	if val['scale9Enabled'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enabled'])
	end	

	local normalDic = val['normalData']	
	if normalDic and normalDic.path then
		local normalType = normalDic.resourceType
		if normalType == 0 then
			local path = normalDic.path
			self:setTextureNormal(path)
		else
			me.FrameCache:addSpriteFramesWithFile(normalDic.plistFile)
			self:setTextureNormal(normalDic.path, TF_TEX_TYPE_PLIST)
		end
	end

	local pressedDic = val['pressedData']	
	if pressedDic and pressedDic.path then
		local pressedType = pressedDic.resourceType
		if pressedType == 0 then
			local path = pressedDic.path
			self:setTexturePressed(path)
		else
			me.FrameCache:addSpriteFramesWithFile(pressedDic.plistFile)
			self:setTexturePressed(pressedDic.path, TF_TEX_TYPE_PLIST)
		end
	end

	local disabledDic = val['disabledData']	
	if disabledDic and disabledDic.path then
		local disabledType = disabledDic.resourceType
		if disabledType == 0 then
			local path = disabledDic.path
			self:setTextureDisabled(path)
		else
			me.FrameCache:addSpriteFramesWithFile(disabledDic.plistFile)
			self:setTextureDisabled(disabledDic.path, TF_TEX_TYPE_PLIST)
		end
	end

	-- generate by cocostudio
	if (val['scale9Enable'] or val['scale9Enabled']) and val['capInsetsX'] then
		local cx = val['capInsetsX']
		local cy = val['capInsetsY']
		local cw = val['capInsetsWidth']
		local ch = val['capInsetsHeight']
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

function TFUIBase:initMEButton_ALPHA(pval, parent)
	local val = pval
	if val['texture'] then 
		self:setTextureNormal(val['texture'])
	end
	if val['scale9Enable'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enable'])
	end	
	if val['scale9Enabled'] and self.setScale9Enabled then 
		self:setScale9Enabled(val['scale9Enabled'])
	end	
	if val['scale9Enabled'] or val['scale9Enable'] then 
		local cs = self:getSize()
		local width = val['width'] or cs.width
		local height = val['height'] or cs.height
		self:setSize(CCSizeMake(width, height))
	end	
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end