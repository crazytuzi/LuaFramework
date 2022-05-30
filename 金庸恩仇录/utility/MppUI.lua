local MppUI = {}
function MppUI.newMppLabel(params)
	local mppLabel = display.ui.newTTFLabelWithShadow(params)
	mppLabel:setContentSize(mppLabel:getContentSize())
	return mppLabel
end
function MppUI.refreshShadowLabel(params)
	local curLabel = params.label
	local mppParams = {}
	mppParams.color = params.color or display.COLOR_WHITE
	mppParams.shadowColor = params.shadowColor or display.COLOR_BLACK
	mppParams.x = curLabel:getPositionX()
	mppParams.y = curLabel:getPositionY()
	mppParams.size = curLabel:getFontSize()
	local mppShadow = ui.newTTFLabelWithShadow(mppParams)
	mppShadow:setContentSize(curLabel:getContentSize())
	mppShadow:setAnchorPoint(curLabel:getAnchorPoint())
	mppShadow:setZOrder(curLabel:getZOrder())
	curLabel:getParent():addChild(mppShadow)
	curLabel:removeSelf()
	curLabel = mppShadow
end
return MppUI