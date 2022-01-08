local TFUIBase 					= TFUIBase
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR
local TFUI_VERSION_ALPHA 		= TFUI_VERSION_ALPHA
local TF_TEX_TYPE_LOCAL 		= TF_TEX_TYPE_LOCAL
local TF_TEX_TYPE_PLIST 		= TF_TEX_TYPE_PLIST
local ccc3 						= ccc3
local CCSizeMake 				= CCSizeMake
local CCRectMake 				= CCRectMake
local string 					= string

function TFUIBase:initMECheckBox(pval, parent)
	local val = pval
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMECheckBox_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMECheckBox_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMECheckBox_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMECheckBox_NEWMEEDITOR(pval, parent)
	end
end


function TFUIBase:initMECheckBox_MEEDITOR(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)
	
	if val['backGroundTexture'] and val["backGroundTexture"] ~= "" and self.setTextureBackGround then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['backGroundTexture_plist'] and val['backGroundTexture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['backGroundTexture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTextureBackGround(val['backGroundTexture'], textureType)
	end	
	if val['backGroundSelectedTexture'] and val["backGroundSelectedTexture"] ~= "" and self.setTextureBackGroundSelected then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['backGroundSelectedTexture_plist'] and val['backGroundSelectedTexture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['backGroundSelectedTexture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTextureBackGroundSelected(val['backGroundSelectedTexture'], textureType)
	end	
	if val['backGroundDisabledTexture'] and val["backGroundDisabledTexture"] ~= "" and self.setTextureBackGroundDisabled then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['backGroundDisabledTexture_plist'] and val['backGroundDisabledTexture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['backGroundDisabledTexture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTextureBackGroundDisabled(val['backGroundDisabledTexture'], textureType)
	end	
	if val['frontCrossTexture'] and val["frontCrossTexture"] ~= "" and self.setTextureFrontCross then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['frontCrossTexture_plist'] and val['frontCrossTexture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['frontCrossTexture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTextureFrontCross(val['frontCrossTexture'], textureType)
	end	
	if val['frontCrossDisabledTexture'] and val["frontCrossDisabledTexture"] ~= "" and self.setTextureFrontCrossDisabled then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['frontCrossDisabledTexture_plist'] and val['frontCrossDisabledTexture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['frontCrossDisabledTexture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTextureFrontCrossDisabled(val['frontCrossDisabledTexture'], textureType)
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
		end
	end

	if val['ignoreSize'] == 'False' and (val['width'] or val['height']) then 
		local cs = self:getSize()
		local width = val['width'] + 0 or cs.width
		local height = val['height'] + 0 or cs.height
		self:setSize(CCSizeMake(width, height))
	end	
	
	if val['selectedState'] and self.setSelectedState then 
		local bIsSelected = val['selectedState'] == "True"
		self:setSelectedState(bIsSelected)
	end

	if val['clickType'] and self.setClickType then
		local eType = val['clickType'] + 0
		self:setClickType(eType)
	end
	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMECheckBox_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val = pval.tCheckBoxProperty
	
	if val.szBackGroundTexture ~= "" and self.setTextureBackGround then 
		self:setTextureBackGround(val.szBackGroundTexture)
	end	
	if val.szBackGroundSelectedTexture ~= "" and self.setTextureBackGroundSelected then 
		self:setTextureBackGroundSelected(val.szBackGroundSelectedTexture)
	end	
	if val.szBackGroundDisabledTexture ~= "" and self.setTextureBackGroundDisabled then 
		self:setTextureBackGroundDisabled(val.szBackGroundDisabledTexture)
	end	
	if val.szFrontCrossTexture ~= "" and self.setTextureFrontCross then 
		self:setTextureFrontCross(val.szFrontCrossTexture)
	end	
	if val.szFrontCrossDisabledTexture ~= "" and self.setTextureFrontCrossDisabled then 
		self:setTextureFrontCrossDisabled(val.szFrontCrossDisabledTexture)
	end	

	if val.nSelectedState and self.setSelectedState then 
		self:setSelectedState(val.nSelectedState)
	end

	if val.nClickType and self.setClickType then
		self:setClickType(val.nClickType)
	end
	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMECheckBox_COCOSTUDIO(pval, parent)
	local val = pval.options
	self:initMEWidget(pval, parent)
	local backGroundDic = val['backGroundBoxData']	
	if backGroundDic and backGroundDic.path then
		local backGroundType = backGroundDic.resourceType
		if backGroundType == 0 then
			local path = backGroundDic.path
			self:loadBackGroundTexture(path)
		else
			me.FrameCache:addSpriteFramesWithFile(backGroundDic.plistFile)
			self:loadBackGroundTexture(backGroundDic.path, TF_TEX_TYPE_PLIST)
		end
	end
	
	local backGroundBoxSelectedDic = val['backGroundBoxSelectedData']	
	if backGroundBoxSelectedDic and backGroundBoxSelectedDic.path then
		local backGroundBoxSelectedType = backGroundBoxSelectedDic.resourceType
		if backGroundBoxSelectedType == 0 then
			local path = backGroundBoxSelectedDic.path
			self:loadBackGroundSelectedTexture(path)
		else
			me.FrameCache:addSpriteFramesWithFile(backGroundBoxSelectedDic.plistFile)
			self:loadBackGroundSelectedTexture(backGroundBoxSelectedDic.path, TF_TEX_TYPE_PLIST)
		end
	end
	
	local frontCrossDic = val['frontCrossData']	
	if frontCrossDic and frontCrossDic.path then
		local frontCrossType = frontCrossDic.resourceType
		if frontCrossType == 0 then
			local path = frontCrossDic.path
			self:loadFrontCrossTexture(path)
		else
			me.FrameCache:addSpriteFramesWithFile(frontCrossDic.plistFile)
			self:loadFrontCrossTexture(frontCrossDic.path, TF_TEX_TYPE_PLIST)
		end
	end
	
	local backGroundBoxDisabledDic = val['backGroundBoxDisabledData']	
	if backGroundBoxDisabledDic and backGroundBoxDisabledDic.path then
		local backGroundBoxDisabledType = backGroundBoxDisabledDic.resourceType
		if backGroundBoxDisabledType == 0 then
			local path = backGroundBoxDisabledDic.path
			self:loadBackGroundDisabledTexture(path)
		else
			me.FrameCache:addSpriteFramesWithFile(backGroundBoxDisabledDic.plistFile)
			self:loadBackGroundDisabledTexture(backGroundBoxDisabledDic.path, TF_TEX_TYPE_PLIST)
		end
	end
	
	local frontCrossDisabledDic = val['frontCrossDisabledData']	
	if frontCrossDisabledDic and frontCrossDisabledDic.path then
		local frontCrossDisabledType = frontCrossDisabledDic.resourceType
		if frontCrossDisabledType == 0 then
			local path = frontCrossDisabledDic.path
			self:loadFrontCrossDisabledTexture(path)
		else
			me.FrameCache:addSpriteFramesWithFile(frontCrossDisabledDic.plistFile)
			self:loadFrontCrossDisabledTexture(frontCrossDisabledDic.path, TF_TEX_TYPE_PLIST)
		end
	end

	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMECheckBox_ALPHA(pval, parent)
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end