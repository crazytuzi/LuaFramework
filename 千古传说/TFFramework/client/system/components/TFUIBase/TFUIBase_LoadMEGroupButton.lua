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

function TFUIBase:initMEGroupButton(pval, parent)
	if TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEGroupButton_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEGroupButton_NEWMEEDITOR(pval, parent)
	self:initMETextButton(pval, parent)
	local val = pval.tGroupButtonProperty

	if val.bIsSelected and self.setSelect then
		self:setSelect(true)
	end

	if val.tSelectedColor and self.setSelectedColor then
		self:setSelectedColor(val.tSelectedColor)
	end

	if val.tNormalColor and self.setNormalColor then
		self:setNormalColor(val.tNormalColor)
	end

	if val.szNormalTexture and self.setNormalTexture then
		self:setNormalTexture(val.szNormalTexture)
	end

	if val.szPressedTexture and self.setPressedTexture then
		self:setPressedTexture(val.szPressedTexture)
	end
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
end