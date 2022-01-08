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

function TFUIBase:initMEListView(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEListView_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEListView_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEListView_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEListView_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEListView_MEEDITOR(pval, parent)
	self:initMEScrollView(pval, parent)
end

function TFUIBase:initMEListView_NEWMEEDITOR(pval, parent)
	self:initMEScrollView(pval, parent)
end

function TFUIBase:initMEListView_COCOSTUDIO(pval, parent)
	self:initMEScrollView(pval, parent)
end

function TFUIBase:initMEListView_ALPHA(pval, parent)
	self:initMEScrollView(pval, parent)
end