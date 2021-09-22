-- 主界面右侧快捷物品按钮
local GUIFastMenu = {}
local var = {}

local propKey = {"Medicine1", "Medicine2", "Medicine3", "Medicine4"}
local function updatePropIcon()
	local propId, num, hasItem, pos, shortCut
	for i = 1, 4 do
		hasItem = false
		propId = nil
		-- propId = GameSetting.getConf(propKey[i])
		shortCut = GameSocket.mShortCut[GameConst.SHORT_SKILL_END + i]
		if shortCut and shortCut.param ~= 0 then
			propId = shortCut.param
		end
		if propId then
			num = GameSocket:getTypeItemNum(propId)
			if num > 0 then
				var.btnProps[i].lblPropsNum:setString(num);
				local itemdef = GameSocket:getItemDefByID(propId)
				if itemdef then
					if itemdef.mDC > 0 and itemdef.mDC < 8 then
						var.btnProps[i].cdtime = itemdef.mDC
					else
						var.btnProps[i].cdtime = 1
					end
					if not (var.btnProps[i].mIconID == itemdef.mIconID) then
						var.btnProps[i].mIconID = itemdef.mIconID
						if not cc.FileUtils:getInstance():isFileExist("image/icon/prop_"..itemdef.mIconID..".png") then
							--var.btnProps[i].imgIcon:loadTexture("image/icon/"..itemdef.mIconID..".png", ccui.TextureResType.localType)
							
							asyncload_callback("image/icon/"..itemdef.mIconID..".png", var.btnProps[i].imgIcon, function(filepath, texture)
								var.btnProps[i].imgIcon:loadTexture(filepath)
							end)
						else
							var.btnProps[i].imgIcon:loadTexture("image/icon/prop_"..itemdef.mIconID..".png", ccui.TextureResType.localType)
							--var.btnProps[i].loadTexturePressed("null", ccui.TextureResType.plistType)
						end
							var.btnProps[i]:setOpacity(255 * 0)
						var.btnProps[i].imgIcon:setPositionX(var.btnProps[i]:getContentSize().width/2)
					end
				end
				pos = GameSocket:getNetItemById(propId)
				if pos then
					var.btnProps[i].netItem = GameSocket.mItems[pos];
					hasItem = true
				end
			end
		end
		if not hasItem then
			var.btnProps[i]:setOpacity(255 * 1)
			var.btnProps[i].lblPropsNum:setString("");
			var.btnProps[i].imgIcon:loadTexture("null", ccui.TextureResType.plistType)
			var.btnProps[i].netItem = nil
			var.btnProps[i].mIconID = nil
		end
	end
end

local function handlePropsVisible(visible)
	if var.btnControlProps then
		var.btnControlProps:stopAllActions()
		for i=1,3 do
			var.propModel:getWidgetByName("btn_props"..i):setVisible(visible)
		end
		var.btnControlProps.showProps =	visible
		if visible then
			var.btnControlProps:setPositionX(0):setScaleX(1)
		else
			var.btnControlProps:setPositionX(205):setScaleX(-1)
		end
	end
end

local function doDelayHideBasicFunc()
	var.btnControlProps:stopAllActions()
	var.btnControlProps:runAction(cca.seq({
		cca.delay(5),
		cca.cb(function ()
			handlePropsVisible(false)
		end)
	}))
end

local function showCoolDown(sender, cdTime, callBack)
	-- print("showCoolDown", cdTime)
	if cdTime==nil or cdTime=="" then
		cdTime = 0
	end
	sender.mark:show()
	sender:setPressedActionEnabled(false)
	sender.isCD = true

	sender.mark:runAction(cc.Sequence:create(
		cc.ProgressFromTo:create(cdTime + 0.5, 100, 0),
		cc.CallFunc:create(function ()
			sender.isCD = false
			sender.mark:hide()
			sender:setPressedActionEnabled(true)
			if callBack then callBack() end
		end)
	))
end

local function pushPropButtons (sender)
	if sender.isCD then return end
	local netItem = sender.netItem
	if netItem then
		-- print("coolDown callBack",netItem.position, netItem.mTypeID)
		GameSocket:BagUseItem(netItem.position, netItem.mTypeID, 1);
		showCoolDown(sender, sender.cdtime, function ()
			-- print("coolDown callBack")
		end)
	else
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_quickset",mParam={type=2}})
	end
end

local function addProgressTimer(sender)
	if not sender.mark then
		local size = sender:getContentSize();
		sender.mark = cc.ProgressTimer:create(cc.Sprite:create("image/icon/mark_circle_60.png"))
			:setReverseDirection(true)
			--:setScale(0.8)
			:align(display.CENTER, 0.5 * size.width, 0.5 * size.height)
			:addTo(sender, 100)
			:hide()
		sender.mark:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	end
end

local function pushQuickButton(sender)
	local btnName = sender:getName()
	-- print("pushQuickButton", btnName)
	if btnName == "main_autofight" then -- 又捡又打架
		if GameCharacter._autoFight then
			GameCharacter.stopAutoFight()
		else
			GameCharacter.startAutoFight()
		end
	elseif btnName == "main_autopick" then --光捡不打架
		if GameCharacter._autoPick then
			GameCharacter.stopAutoPick()
		else
			GameCharacter.startAutoPick()
		end
	end
end

local function initBoxProps()
	var.btnControlProps = var.propModel:getWidgetByName("btn_control_props"):setPressedActionEnabled(true)
	-- print("initBoxProps", var.btnControlProps)
	var.btnControlProps.showProps = true
	GUIFocusPoint.addUIPoint(var.btnControlProps, function (sender)
		-- print("pushControlProps")
		handlePropsVisible(not sender.showProps)
		if var.btnControlProps.showProps then
			doDelayHideBasicFunc()
		end
	end)
	handlePropsVisible(not var.btnControlProps.showProps)
	
	for i=1,4 do
		var.btnProps[i] = var.propModel:getWidgetByName("btn_props"..i)
		var.btnProps[i]:setPressedActionEnabled(true)
		var.btnProps[i].imgIcon = var.btnProps[i]:getWidgetByName("img_icon")
		var.btnProps[i].lblPropsNum = var.btnProps[i]:getWidgetByName("lbl_props_num")
		GUIFocusPoint.addUIPoint(var.btnProps[i], pushPropButtons)
		addProgressTimer(var.btnProps[i])
	end
	var.btnAutoFight = var.propModel:getWidgetByName("main_autofight")
	GUIFocusPoint.addUIPoint(var.btnAutoFight, pushQuickButton)

	-- var.btnAutoPick = var.propModel:getWidgetByName("main_autopick"):hide()

	-- local posX,posY = var.btnAutoPick:getPosition()
	-- var.btnAutoFight:setPosition(var.btnAutoPick:getPosition())
	-- GUIFocusPoint.addUIPoint(var.btnAutoPick, pushQuickButton)
end

local function handleQuickButtonState(event)
	-- print("handleQuickButtonState", event.key)
	if event.key == "fight" then
		if event.state then
			if event.state == "start" then
				var.propModel:getWidgetByName("imageFigthState"):loadTexture("main_auto_stop",ccui.TextureResType.plistType)
			else
				var.propModel:getWidgetByName("imageFigthState"):loadTexture("main_auto_fight",ccui.TextureResType.plistType)
			end
		end
		-- var.btnAutoFight:loadTextureNormal(GameCharacter._autoFight and "btn_auto_fight_on" or "btn_auto_fight", ccui.TextureResType.plistType)
	elseif event.key == "pick" then
		-- var.btnAutoPick:loadTextureNormal(GameCharacter._autoPick and "btn_auto_pick_on" or "btn_auto_pick", ccui.TextureResType.plistType)
	end
end


function GUIFastMenu.init(propModel)
	var = {
		propModel,
		btnProps = {},
		btnAutoFight,
		-- btnAutoPick,
	}
	var.propModel = propModel

	if var.propModel then
		initBoxProps()
		updatePropIcon()
		cc.EventProxy.new(GameSocket, propModel)
			:addEventListener(GameMessageCode.EVENT_SET_SHORTCUT, updatePropIcon)
			:addEventListener(GameMessageCode.EVENT_QUICKBUTTON_STATE, handleQuickButtonState)
			:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, function (event)
				updatePropIcon()
			end)
	end
end

function GUIFastMenu.update()
	if not var.propModel then return end
	-- if GameCharacter._autoFight ~= var.btnAutoFight._selected then
	-- 	var.btnAutoFight:loadTextureNormal(GameCharacter._autoFight and "btn_auto_on" or "btn_auto", ccui.TextureResType.plistType)
	-- 	var.btnAutoFight._selected = GameCharacter._autoFight
	-- end
end

return GUIFastMenu