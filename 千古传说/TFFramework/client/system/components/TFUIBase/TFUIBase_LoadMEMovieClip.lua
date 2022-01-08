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

function TFUIBase:initMEMovieClip(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEMovieClip_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEMovieClip_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEMovieClip_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEMovieClip_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEMovieClip_MEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val = pval['movieClipModel']
	if val == nil then
		return
	end

	if val['animationName'] ~= '' then
		self:play(val['animationName'], val['loopTimes'], val['fDelay'], val['nStart'], val['nEnd'])
	else
		--todo
		self:play()
	end

	local size = self:getMovieSize()
	self:setSize(size)


	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEMovieClip_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val = pval.tMovieClipProperty
	if val == nil then
		return
	end

	if val.szAnimationName and val.szAnimationName ~= '' then
		self:play(val.szAnimationName, val.nLoop, val.nDelay)
	else
		--todo
		self:play()
	end

	local size = self:getMovieSize()
	self:setSize(size)


	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEMovieClip_COCOSTUDIO(pval, parent)
	local val = pval.options
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	if val['play'] and self.play then
		self:play(val['play'])
	end
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEMovieClip_ALPHA(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	if val['play'] and self.play then
		self:play(val['play'])
	end
	self:initBaseControl(pval, parent)
end