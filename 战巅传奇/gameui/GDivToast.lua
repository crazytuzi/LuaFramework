
GDivToast = {}

local var  = {}

local function hideGDivToast()
	if var.propsTips then var.propsTips:hide() end
	if var.equipTips then var.equipTips:hide() end
	var.layerTips:hide()
end

local function clickGDivToast(pSender)
	hideGDivToast()
	if var.hideCallBack and type(var.hideCallBack) == "function" then
		var.hideCallBack()
	end
	var.hideCallBack = nil
end

local function handleTips(event)
	if event.visible and (event.pos or event.typeId) then
		local param = {
			itemPos = event.itemPos, 
			typeId = event.typeId,
			tipsType = event.tipsType,
			mLevel = event.mLevel,
			mZLevel = event.mZLevel,
			customCallFunc = event.customCallFunc,
			compare = event.compare,
			enmuPos = event.enmuPos,
			destoryCallFunc = event.destoryCallFunc,
			enmuItemType = event.enmuItemType,
		}
		local xmlTips
		local itemPos = event.itemPos
		local typeId = event.typeId
		local netItem = GameSocket:getNetItem(itemPos)
		if netItem then typeId = netItem.mTypeID end
		local key = "propsTips"
		if GameBaseLogic.IsEquipment(typeId) then
			key = "equipTips"
		end

		if not var[key] then
			var[key] = GUIFloatTips.showTips(param)
			if var[key] then
				var[key]:addTo(var.layerTips)
			end
		else
			param.tips = var[key]
			var[key] = GUIFloatTips.showTips(param)
		end
		xmlTips = var[key]

		if xmlTips then
			if event.tipsAnchor then
				if type(event.tipsAnchor) == "table" then
					xmlTips:setAnchorPoint(event.tipsAnchor)
				elseif type(event.tipsAnchor) == "number" then
					xmlTips:align(event.tipsAnchor)
				end
			else
				xmlTips:align(display.CENTER)
			end

			if event.tipsPos then
				xmlTips:pos(event.tipsPos.x, event.tipsPos.y)
			else
				xmlTips:pos(display.cx, display.cy)
			end

			if xmlTips:getChildByName("selfEquiptip") then
				local width = xmlTips:getContentSize().width
				local anchor = xmlTips:getAnchorPoint()
				xmlTips:setPositionX(width + anchor.x * width)
			end

			var.hideCallBack = event.hideCallBack
			var.layerTips:show()
			xmlTips:show()
		end
	else
		hideGDivToast()
	end
end

function GDivToast.init()
	var = {
		layerTips,
		xmlTips,
		propsTips,
		equipTips
	}

	var.layerTips = ccui.Widget:create()
		:setContentSize(cc.size(display.width, display.height))
		:align(display.CENTER, display.cx, display.cy)
		:setTouchEnabled(true)
		:setSwallowTouches(true)
		:hide()
		:setName("layerTips")
	var.layerTips:addClickEventListener(clickGDivToast)
	
	cc.EventProxy.new(GameSocket, var.layerTips)
			:addEventListener(GameMessageCode.EVENT_HANDLE_TIPS, handleTips)

	return var.layerTips
end

return GDivToast