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

function TFUIBase:initMEPageView(pval, parent)
	if TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEPageView_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEPageView_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEPageView_MEEDITOR(pval, parent)
	self:initMEPanel(pval, parent)
	
	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMEPageView_NEWMEEDITOR(pval, parent)
	self:initMEPanel(pval, parent)
	local val = pval.tPageViewProperty
	if val.bBounceEnabel ~= nil and self.setBounceEnabled then
		self:setBounceEnabled(val.bBounceEnabel)
	end
	
	self:initMEColorProps(pval, parent)
end
