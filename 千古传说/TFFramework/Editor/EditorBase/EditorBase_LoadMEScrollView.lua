local tMEScrollView = {}
tMEScrollView.__index = tMEScrollView
setmetatable(tMEScrollView, require("TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel"))

function EditLua:createScrollView(szId, tParams)
	print("create scrollView")
	if targets[szId] ~= nil then
		return
	end
	local scrollView = TFScrollView:create()
	scrollView:setPosition(VisibleRect:center())
	scrollView:setSize(CCSizeMake(350, 300))
	scrollView:setInnerContainerSize(CCSizeMake(350, 300))
	-- scrollView:getInnerContainer():setClippingEnabled(false)
	-- scrollView:setClippingEnabled(false)
	scrollView:setBackGroundColorOpacity(50)

	-- scrollView:setBounceEnabled(true)
	-- scrollView:getInnerContainer():setBackGroundColorType(1)
	-- scrollView:getInnerContainer():setBackGroundColor(ccc3(0, 255, 255))

	-- tTouchEventManager:registerEvents(scrollView)
	targets[szId] = scrollView
	-- targets[szId].szId = szId
	-- targets[szId].children = TFArray:new()

	EditLua:addToParent(szId, tParams)

	print("create success")
end

function tMEScrollView:setInnerContainerSize(szId, tParams)
	print("setInnerContainerSize")
	if tParams.nWidth ~= nil and tParams.nHeight ~= nil and targets[szId] ~= nil and targets[szId].setInnerContainerSize then 
		targets[szId]:setInnerContainerSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
		-- targets[szId]:setSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
		print("setInnerContainerSize run success", targets[szId]:getInnerContainer():getPosition().x, targets[szId]:getInnerContainer():getPosition().y)
	end
end

function tMEScrollView:setBounceEnabled(szId, tParams)
	print("setBounceEnabled")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setBounceEnabled then
		targets[szId]:setBounceEnabled(tParams.bRet)
		print("setBounceEnabled run success")
	end
end

function tMEScrollView:setAutoMoveDuration(szId, tParams)
	print("setAutoMoveDuration")
	if tParams.nDuration ~= nil and targets[szId] ~= nil and targets[szId].setAutoMoveDuration then
		targets[szId]:setAutoMoveDuration(tParams.nDuration)
		print("setAutoMoveDuration run success")
	end
end

function tMEScrollView:setAutoMoveEaseRate(szId, tParams)
	print("setAutoMoveEaseRate")
	if tParams.nEaseRate ~= nil and targets[szId] ~= nil and targets[szId].setAutoMoveEaseRate then
		targets[szId]:setAutoMoveEaseRate(tParams.nEaseRate)
		print("setAutoMoveEaseRate run success")
	end
end

function tMEScrollView:setScrollBarTexture(szId, tParams)
	print("setScrollBarTexture")
	-- if tParams.nEaseRate ~= nil and targets[szId] ~= nil and targets[szId].setScrollBarTexture then
	-- 	targets[szId]:setScrollBarTexture(tParams.nEaseRate)
	-- 	print("setScrollBarTexture run success")
	-- end
end

function tMEScrollView:setDirection(szId, tParams)
	print("setDirection")
	if tParams.nDirection ~= nil and targets[szId] ~= nil and targets[szId].setDirection then
		targets[szId]:setDirection(tParams.nDirection)
		print("setDirection run success")
	end
end

return tMEScrollView