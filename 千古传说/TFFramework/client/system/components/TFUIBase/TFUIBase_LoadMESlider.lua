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

function TFUIBase:initMESlider(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEMESlider_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEMESlider_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEMESlider_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEMESlider_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEMESlider_MEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local size = self:getSize()
	local val = pval
	if val['texture'] and val['texture'] ~= "" and self.setBarTexture then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['texture_plist'] and val['texture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['texture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setBarTexture(val['texture'], textureType)
	end	

	if val['progressbartexture'] and val['progressbartexture'] ~= "" and self.setProgressBarTexture then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['progressbartexture_plist'] and val['progressbartexture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['progressbartexture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setProgressBarTexture(val['progressbartexture'], textureType)
	end	

	if val['texturenormal'] and val['texturenormal'] ~= "" and self.setSlidBallTextureNormal then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['texturenormal_plist'] and val['texturenormal_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['texturenormal_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setSlidBallTextureNormal(val['texturenormal'], textureType)
	end	

	if val['texturepressed'] and val['texturepressed'] ~= "" and self.setSlidBallTexturePressed then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['texturepressed_plist'] and val['texturepressed_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['texturepressed_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setSlidBallTexturePressed(val['texturepressed'], textureType)
	end	

	if val['texturedisable'] and val['texturedisable'] ~= "" and self.setSlidBallTextureDisabled then 
		local textureType = TF_TEX_TYPE_LOCAL
		if val['texturedisable_plist'] and val['texturedisable_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['texturedisable_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setSlidBallTextureDisabled(val['texturedisable'], textureType)
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
	self:setSize(size)
	if val['percent'] and self.setPercent then 
		self:setPercent(val['percent']+0)
	end	

	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEMESlider_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val = pval.tSliderProperty
	if val.szBarTexture and val.szBarTexture ~= "" and self.setBarTexture then 
		self:setBarTexture(val.szBarTexture)
	end	

	if val.szProgressTexture and val.szProgressTexture ~= "" and self.setProgressBarTexture then 
		self:setProgressBarTexture(val.szProgressTexture)
	end	

	if val.szTexturenormal and val.szTexturenormal ~= "" and self.setSlidBallTextureNormal then 
		self:setSlidBallTextureNormal(val.szTexturenormal)
	end	

	if val.szTexturepressed and val.szTexturepressed ~= "" and self.setSlidBallTexturePressed then 
		self:setSlidBallTexturePressed(val.szTexturepressed)
	end	

	if val.szTexturedisable and val.szTexturedisable ~= "" and self.setSlidBallTextureDisabled then 
		self:setSlidBallTextureDisabled(val.szTexturedisable)
	end	

	if val.nPercent and self.setPercent then 
		self:setPercent(val.nPercent)
	end	

	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEMESlider_COCOSTUDIO(pval, parent)
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEMESlider_ALPHA(pval, parent)
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end
