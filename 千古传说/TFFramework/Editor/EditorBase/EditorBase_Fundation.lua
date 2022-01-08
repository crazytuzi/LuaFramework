
function EditLua:setVisibleRectPercent(szId, tParams)
	print("setVisibleRectPercent")
	if targets[szId] and tParams.nPer then
		targets[szId].visibleRectPercent = tParams.nPer
		if targets[szId]._bIsSetPercentage then
			targets[szId]:setSize(CCSizeMake(targets["root"]:getSize().width * tParams.nPer/100, targets["root"]:getSize().height * tParams.nPer/100))
			if targets[targets[szId].szParentID]:getNodeType() == TFWIDGET_TYPE_CONTAINER then
				targets[targets[szId].szParentID]:doLayout()
			end
		end
		print("setVisibleRectPercent success")
	end
end

function EditLua:setPercentVisibleEnabled(szId, tParams)
	print("setPercentVisibleEnabled")
	if targets[szId] and tParams.bRet ~= nil then
		if tParams.bRet then
			targets[szId]:setSizeType(TF_SIZE_FRAMESIZE)
		end
		targets[szId]._bIsSetPercentage = tParams.bRet
		print("_bIsSetPercentage success", tParams.bRet)
	end
end

function EditLua:init()
	TFLOGINFO("\n\n\n\n------------------------------------------------------- project begin ------------------------------------------")
	local size = CCEGLView:sharedOpenGLView():getFrameSize()

	local scene = TFScene:create()
	scene.uiLayer = TFPanel:create()
	scene:addChild(scene.uiLayer)
	TFDirector:changeScene(scene)

	targets["UILayer"] = scene.uiLayer
	targets["UILayer"]:setSize(size)

	-- create backGround
	local bgImg = TFImage:create('test/panelBg.png')
	bgImg:setImageSizeType(TF_SIZE_CORRDS)
	bgImg:setSize(size)
	bgImg:setAnchorPoint(ccp(0, 0))
	targets["UILayer"]:addChild(bgImg)

	local designPanel = TFPanel:create()
	designPanel:setZOrder(2)
	designPanel:setSize(size)
	targets["UILayer"]:addChild(designPanel)

	targets["root"] = designPanel
	targets["root"].children = TFArray:new()
	targets["root"].bgImg0 = bgImg
	targets["root"].szId = "root"

	-- touch panel
	local touchPanel = TFPanel:create()
	touchPanel:setZOrder(100)
	touchPanel:setTouchEnabled(true)
	touchPanel:setSize(size)
	targets["UILayer"]:addChild(touchPanel)
	targets["touchPanel"] = touchPanel

	touchPanel:addMEListener(TFWIDGET_TOUCHBEGAN, tTouchEventManager.onTouchPanelBegan)
	touchPanel:addMEListener(TFWIDGET_TOUCHMOVED, tTouchEventManager.onTouchPanelMoved)
	touchPanel:addMEListener(TFWIDGET_TOUCHENDED, tTouchEventManager.onTouchPanelEnded)
	touchPanel:addMEListener(TFWIDGET_TOUCHCANCELLED, tTouchEventManager.onTouchPanelEnded)

	--init multi selectRect
	local controlRectImg = TFDrawNode:create()
	controlRectImg:setZOrder(1001000)
	controlRectImg:setVisible(false)
	targets["root"].objMultiSelectRect = controlRectImg
	targets["UILayer"]:addChild(controlRectImg)

	-- init panel grid background
	local curSize = CCSize(480, 320)
	local bg = TFImage:create()
	bg:setTexture("test/grid.png")
	bg:setImageSizeType(TF_SIZE_CORRDS)
	bg:setSize(CCSizeMake(480, 320))
	bg:setAnchorPoint(ccp(0, 0))
	bg:setTag(1)
	bg:setPosition(ccp(0, 0))

	targets["root"].bgImg = bg
	targets["root"].bgSize = curSize;
	targets["root"]:setPosition(ccp((size.width-curSize.width)/2, (size.height-curSize.height)/2))
	targets["root"]:addChild(bg)

	--x
	tRootPanel:clear()
	tRootPanel = TFArray:new()
	tLockTargets = TFArray:new()
	tSelectedIDs = TFArray:new()
	tLastSelectedIDs = TFArray:new()

	EditorKeyManager:registerKeyBoardEvent()
end

return EditLua
