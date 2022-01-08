local TFUIBase 					= TFUIBase
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR

function TFUIBase:initMEArmature(pval, parent)
	if TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEArmature_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEArmature_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEArmature_MEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val
	if pval['armatureModel'] then
		val = pval['armatureModel']
	else
		return
	end

	if val['ArmaruteName'] then
		self:setArmature(val['ArmaruteName'])
	end

	if val['IsPlaying'] and val['animationName'] ~= '' then
		self:play(val['animationName'], val['duration'], val['tween'], val['loopTimes'])
	end

	if val['rate'] then
		self:setAnimationScale(val['rate'])
	end
	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEArmature_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)

	local val = pval.tArmatureProperty
	
	if val.szArmatureName then
		self:setArmature(val.szArmatureName)
	end

	if val.bIsPlay and val.szAnimationName ~= '' then
		val.nDuration = val.nDuration or 0
		val.nTween = val.nTween or 0
		val.nLoopType = val.nLoopType or -1
		self:play(val.szAnimationName, val.nDuration, val.nTween)
	end

	if val.nRate then
		self:setAnimationScale(val.nRate)
	end
	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end
