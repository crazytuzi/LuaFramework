tLuaDataManager = {}

function EditLua:clone(szId, tParams)
	print("clone")
	szId, tParams.szBeClonedID = tParams.szBeClonedID, szId
	if tParams.szBeClonedID and tParams.szCloneParent then
		if targets[tParams.szBeClonedID] == nil then
			TFLOGERROR(string.format("!!!!!!!!!!!!!!!!!!!! BeCloned target is not exist !!!!!!!!!!!!!!!!!!!! %s", tParams.szBeClonedID))
			return
		end		
		print("beCloned Type:", tolua.type(targets[tParams.szBeClonedID]), targets[tParams.szBeClonedID]:getName())
		targets[szId] = targets[tParams.szBeClonedID]:clone(false)
		tLuaDataManager:addObjLuaData(szId, tParams.szCloneParent)

		targets[tParams.szCloneParent].children:push(szId)

		EditVirtualBase:addChild(tParams.szCloneParent, szId)
		EditLua:reorderChild(tParams.szCloneParent, szId)
		
		-- targets[szId]:setVisible(true)
		tLuaDataManager:cloneLuaObject(szId, tParams.szBeClonedID)
		
		print("clone success")
	end
end

function tLuaDataManager:cloneLuaObject(szId, szBeClonedID)
	-- for base
	targets[szId]._bUseCustomSize	 	= targets[szBeClonedID]._bUseCustomSize
	targets[szId]._tCustomSize 		= targets[szBeClonedID]._tCustomSize

	-- for layout
	targets[szId]._RelativeVertical 		= targets[szBeClonedID]._RelativeVertical
	targets[szId]._RelativeHorizontal 	= targets[szBeClonedID]._RelativeHorizontal
	targets[szId]._RelativePadding 		= targets[szBeClonedID]._RelativePadding
	targets[szId]._LinearHorizontal 		= targets[szBeClonedID]._LinearHorizontal
	targets[szId]._LinearVertical 		= targets[szBeClonedID]._LinearVertical

	-- movieClip
	if targets[szBeClonedID]._szMCPath then
		if TFFileUtil:existFile(targets[szBeClonedID]._szMCPath) then
			local target = targets[szBeClonedID]
			local name = target:getPlayMovieName()
			local nRepeat, nStart, nEnd, nDelay = target:getRepeatCount(), target:getStartFrame(), target:getEndFrame(), target:getDelayTime()
			local tParam = {szPath = targets[szBeClonedID]._szMCPath}
			EditLua:setMovieClipPath(szId, tParam)
			targets[szId]:play(name, nRepeat, nDelay, nStart, nEnd)
		end
	end

	-- for label
	targets[szId]._LabelStrokeSize 		= targets[szBeClonedID]._LabelStrokeSize
	targets[szId]._LabelStrokeColor 	= targets[szBeClonedID]._LabelStrokeColor
	targets[szId]._LabelFontFillColor 	= targets[szBeClonedID]._LabelFontFillColor
	targets[szId]._LabelMixColor		= targets[szBeClonedID]._LabelMixColor
	targets[szId]._LabelShadowOffset 	= targets[szBeClonedID]._LabelShadowOffset
	targets[szId]._LabelShadowColor	= targets[szBeClonedID]._LabelShadowColor
	targets[szId]._LabelShadowOpacity	= targets[szBeClonedID]._LabelShadowOpacity
	
	-- for buttonGroup
	targets[szId]._SelectedGroupButtonID 	= targets[szBeClonedID]._SelectedGroupButtonID

	-- for root panel
	targets[szId]._tDesignSize 		= targets[szBeClonedID]._tDesignSize
	targets[szId]._bIsSetPercentage	= targets[szBeClonedID]._bIsSetPercentage
	targets[szId]._bIsRoot 			= targets[szBeClonedID]._bIsRoot
end

function tLuaDataManager:copyLayoutMsg(myWidget, BeCloneWidget)
	local param
	param = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
	if (param ~= nil) then
		local LinearParam = TFLinearLayoutParameter:create()
		local widgetLinear = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
		LinearParam:setMargin(widgetLinear:getMargin())
		LinearParam:setGravity(widgetLinear:getGravity())
		myWidget:setLayoutParameter(LinearParam)
		param = nil
	end
	param = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
	if (param ~= nil) then
		local RelativeParam = TFRelativeLayoutParameter:create()
		local widgetRelative = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
		-- name special
		RelativeParam:setRelativeName(BeCloneWidget:getName())
		RelativeParam:setRelativeToWidgetName(widgetRelative:getRelativeToWidgetName())
		RelativeParam:setMargin(widgetRelative:getMargin())
		RelativeParam:setAlign(widgetRelative:getAlign())
		myWidget:setLayoutParameter(RelativeParam)
		param = nil
	end
	param = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_GRID)
	if (param ~= nil) then
		local RelativeParam = TFGridLayoutParameter:create()
		local widgetRelative = BeCloneWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_GRID)
		-- name special
		myWidget:setLayoutParameter(RelativeParam)
	end
end

function tLuaDataManager:addObjLuaData(szId, szParentID)
	targets[szId].szId = szId
	targets[szId].children = TFArray:new()
	targets[szId].szParentID = szParentID
	
	local nAnchorImgTag = 10
	-- init new selected img
	local rect = TFImage:create()
	rect:setTexture("test/rect.png")
	rect:setScale9Enabled(true)
	rect:setColor(ccc3(255, 255, 255))
	rect:setVisible(false)
	rect:setZOrder(1010000)
	rect:setCascadeColorEnabled(false)

	-- init anchorPoint img
	local anchorImg = TFImage:create()
	anchorImg:setTexture("test/anchor_circle.png")
	anchorImg:setTag(nAnchorImgTag)
	rect:addChild(anchorImg)
	targets["UILayer"]:addChild(rect)

	targets[szId].rect = rect

	local function initFourCorner( rect )
		local leftBottom = TFImage:create("test/gridPoint.png")
		leftBottom:setTouchEnabled(true)
		leftBottom:addMEListener(TFWIDGET_TOUCHBEGAN, tTouchEventManager.touchBegan_TargetCornerToScale)
		leftBottom:addMEListener(TFWIDGET_TOUCHMOVED, tTouchEventManager.touchMove_TargetCornerToScale)
		leftBottom:addMEListener(TFWIDGET_TOUCHENDED, tTouchEventManager.touchEnd_TargetCornerToScale)
		leftBottom:setTag(0)
		leftBottom:setColor(ccc3(250,250,250))
		leftBottom:setSize(CCSize(4, 4))
		leftBottom:setHitRect(CCSizeMake(12, 12), ccp(-4, -4))
		leftBottom:setHitType(TFTYPE_CCRECT)
		rect:addChild(leftBottom)
		
		local leftTop = TFImage:create("test/gridPoint.png")
		leftTop:setTouchEnabled(true)
		leftTop:addMEListener(TFWIDGET_TOUCHBEGAN, tTouchEventManager.touchBegan_TargetCornerToScale)
		leftTop:addMEListener(TFWIDGET_TOUCHMOVED, tTouchEventManager.touchMove_TargetCornerToScale)
		leftTop:addMEListener(TFWIDGET_TOUCHENDED, tTouchEventManager.touchEnd_TargetCornerToScale)
		leftTop:setTag(1)
		leftTop:setColor(ccc3(250,250,250))
		leftTop:setSize(CCSize(4, 4))
		leftTop:setHitRect(CCSizeMake(12, 12), ccp(-4, -4))
		leftTop:setHitType(TFTYPE_CCRECT)
		rect:addChild(leftTop)
		
		local rightTop = TFImage:create("test/gridPoint.png")
		rightTop:setTouchEnabled(true)
		rightTop:addMEListener(TFWIDGET_TOUCHBEGAN, tTouchEventManager.touchBegan_TargetCornerToScale)
		rightTop:addMEListener(TFWIDGET_TOUCHMOVED, tTouchEventManager.touchMove_TargetCornerToScale)
		rightTop:addMEListener(TFWIDGET_TOUCHENDED, tTouchEventManager.touchEnd_TargetCornerToScale)
		rightTop:setTag(2)
		rightTop:setColor(ccc3(250,250,250))
		rightTop:setSize(CCSize(4, 4))
		rightTop:setHitRect(CCSizeMake(12, 12), ccp(-4, -4))
		rightTop:setHitType(TFTYPE_CCRECT)
		rect:addChild(rightTop)
		
		local rightBottom = TFImage:create("test/gridPoint.png")
		rightBottom:setTouchEnabled(true)
		rightBottom:addMEListener(TFWIDGET_TOUCHBEGAN, tTouchEventManager.touchBegan_TargetCornerToScale)
		rightBottom:addMEListener(TFWIDGET_TOUCHMOVED, tTouchEventManager.touchMove_TargetCornerToScale)
		rightBottom:addMEListener(TFWIDGET_TOUCHENDED, tTouchEventManager.touchEnd_TargetCornerToScale)
		rightBottom:setTag(3)
		rightBottom:setColor(ccc3(250,250,250))
		rightBottom:setSize(CCSize(4, 4))
		rightBottom:setHitRect(CCSizeMake(12, 12), ccp(-4, -4))
		rightBottom:setHitType(TFTYPE_CCRECT)
		rect:addChild(rightBottom)
	end
	local function setFourCorner(rect)
		local point = rect:getAnchorPoint()
		rect:setAnchorPoint(ccp(0, 0))
		local leftBottom = rect:getChildByTag(0)
		local leftTop = rect:getChildByTag(1)
		local rightTop = rect:getChildByTag(2)
		local rightBottom = rect:getChildByTag(3)
		local size = rect:getSize()
		leftBottom:setPosition(ccp(0, 0))
		leftTop:setPosition(ccp(0, size.height))
		rightTop:setPosition(ccp(size.width, size.height))
		rightBottom:setPosition(ccp(size.width, 0))
		rect:setAnchorPoint(point)
	end
	targets[szId].rect.setFourCorner = setFourCorner
	initFourCorner(targets[szId].rect)

	targets[szId]._bUseCustomSize = false
	targets[szId]._tCustomSize = targets[szId]:getSize()

	if targets[szId]:getDescription() == "TFScrollView" then
		-- init scrollView dragPanel scroll Rect
		local controlRectImg = TFImage:create()
		controlRectImg:setTexture("test/rect.png")
		controlRectImg:setScale9Enabled(true)
		controlRectImg:setColor(ccc3(255, 255, 255))
		controlRectImg:setZOrder(1001000)
		controlRectImg:setVisible(false)
		targets[szId].scrollRect = controlRectImg
		targets["UILayer"]:addChild(controlRectImg)
	end

	if targets[szParentID]:getNodeType() == TFWIDGET_TYPE_CONTAINER and tTouchEventManager.bIsCreate then
		local layoutType = targets[szParentID]:getLayoutType()
		if layoutType == TF_LAYOUT_LINEAR_HORIZONTAL or layoutType == TF_LAYOUT_LINEAR_VERTICAL then
			-- this layout type associate with children order
			local pos0 = targets[szId]:getPosition()
			targets[szId]:setZOrder(1)
			targets[szId]:getParent():doLayout()
			targets[szId]:setPosition(pos0)
		end
		tRetureMsgTarget:push(szId)
		bIsNeedToSetCmdGet = true
	end
	tTouchEventManager.bIsCreate = false
end

function tLuaDataManager:removeLuaData(szId, szParentID)
	targets[szId].rect:removeFromParent()
	if targets[szId].scrollRect then
		targets[szId].scrollRect:removeFromParent()
	end
	if tSelectedIDs:indexOf(szId) ~= -1 then
		tSelectedIDs:removeObject(szId)
	end
	if tLockTargets:indexOf(szId) ~= -1 then
		tLockTargets:removeObject(szId)
	end
	if tRootPanel:indexOf(szId) ~= -1 then
		tRootPanel:removeObject(szId)
	end
	targets[szParentID].children:removeObject(szId)
end

return tLuaDataManager