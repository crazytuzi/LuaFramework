local GUIRightTop={}

local var = {}

local extendPos = cc.p(350, 35)

local short_button = {
	"btn_short_rank", "btn_short_activity", "btn_short_mail","btn_main_boss"
}

local function pushShortButton(sender)
	local btnName = sender:getName()
	-- local params = string.split(btnName,"_")
	if btnName == "btn_short_rank" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "btn_main_rank"})
	elseif btnName == "btn_short_activity" then
		
	elseif btnName == "btn_short_mail" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_mail"})
	elseif btnName == "btn_main_boss" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "btn_main_boss"})
		--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V9_ContainerBossList"})
	end
end

local function handleExtendVisible(visible)
	var.btnControlExtend.showFlag = visible
	var.righttop:getWidgetByName("box_extend").showFlag = visible
	
	if visible then
		var.btnControlExtend:setScale(1)
		var.btnControlExtend:setPositionX(531)
		var.btnControlExtend:setPositionY(385)
	else
		var.btnControlExtend:setScale(-1)
		var.btnControlExtend:setPositionX(522)
		var.btnControlExtend:setPositionY(358)
	end
	var.righttop:getWidgetByName("box_extend"):setVisible(visible)
	local btnMainBoss = var.righttop:getWidgetByName("btn_main_boss"):setScale(0.9)
	if btnMainBoss.canShow then
		btnMainBoss:setVisible(visible)
	else
		btnMainBoss:hide()
	end
end

local function handleGuiButtons()
	local btnMainBoss = var.righttop:getWidgetByName("btn_main_boss")
	local boxExtend = var.righttop:getWidgetByName("box_extend")
	if GameSocket:checkGuiButton("btn_main_boss") then
		btnMainBoss.canShow = true
		boxExtend:setPositionX(380)
		if var.btnControlExtend.showFlag then
			btnMainBoss:show()
		end
	else
		btnMainBoss.canShow = false
		boxExtend:setPositionX(500)
	end
end

local slideWidget = {
	{name = "btn_control_extend", inY = 319, outY = 481},
	{name = "box_extend", inY = 325, outY = 575},
	{name = "btn_main_boss", inY = 328, outY = 472},
	{name = "extend_breakup", inX = 599, outX = 770},
	{name = "extend_mars", inX = 679, outX = 850},
}

local function moveWidget(parent, config, moveIn)
	local mWidget = parent:getWidgetByName(config.name)
	if not mWidget then return end
	local posX, posY = mWidget:getPosition()
	local actionX, actionY
	if config.inX and config.outX then
		if moveIn and ((config.outX > config.inX and posX > config.inX) or (config.outX < config.inX and posX < config.inX)) then
			actionX = config.inX
			actionY = posY
		elseif (not moveIn) and ((config.inX < config.outX and posX < config.outX) or (config.inX > config.outX and posX > config.outX)) then
			actionX = config.outX
			actionY = posY
		end
	elseif config.inY and config.outY then
		if moveIn and (config.outY > config.inY and posY > config.inY) or (config.outY < config.inY and posY < config.inY) then
			actionX = posX
			actionY = config.inY
		elseif (not moveIn) and ((config.inY < config.outY and posY < config.outY) or (config.inY > config.outY and posY > config.outY)) then
			actionX = posX
			actionY = config.outY
		end
	end
	if actionX and actionY then
		-- print("/////moveWidget///////", config.name, actionX, actionY)
		mWidget:stopActionByTag(5)
		local action = cca.moveTo(0.5, actionX, actionY)
		action:setTag(5)
		mWidget:runAction(action)
	end
end

-- boss复活刷新提示
local function showRefreshTips(sender)
	-- print("showRefreshTips", sender:getName(), #var.refreshBoss)
	if var.refreshBoss[1] then
		local msgSize = sender:setRichLabel(var.refreshBoss[1].tips, "richRefreshBoss", 18)
		local btnFly = sender:getChildByName("btn_fly_mon")
		btnFly.monId = var.refreshBoss[1].monId

		btnFly:align(display.CENTER, msgSize.width + 20, msgSize.height * 0.5)
	end
end

local function handleRefreshTips(sender, manul)
	-- print("//////////handleRefreshTips//////////", manul, #var.refreshBoss)
	sender:stopAllActions()
	if not manul then table.remove(var.refreshBoss, 1) end

	if #var.refreshBoss > 0 then
		local btnFly = sender:getChildByName("btn_fly_mon")
		sender:runAction(cca.seq({
			cca.cb(showRefreshTips),
			cca.show(),
			cca.moveTo(0.3, var.rtWidth - 40, 220),
			cca.delay(5),
			cca.moveTo(0.3, var.rtWidth + 260, 220),
			cca.hide(),
			cca.cb(handleRefreshTips)
		}))
	end
end

local function actionTakeBackTips(sender)
	sender:stopAllActions()
	sender:runAction(cca.seq({
		cca.moveTo(0.3, var.rtWidth + 260, 220),
		cca.hide(),
		cca.cb(handleRefreshTips)
	}))
end

local function onRefreshBoss(event)
	table.insert(var.refreshBoss, event.info)
	if #var.refreshBoss > 1 then return end

	local richRefreshBoss = var.righttop:getChildByName("rich_refresh_boss")
	if not richRefreshBoss then
		richRefreshBoss = GUIRichLabel.new({name = "richRefreshBoss", outline = {0, 0, 0,255, 1}, ignoreSize = true})
			:align(display.RIGHT_CENTER, var.rtWidth + 260, 220)
			:addTo(var.righttop)
			:setName("rich_fefresh_boss")
		local btnFly = ccui.Button:create("btn_fly_small", "btn_fly_small", "", ccui.TextureResType.plistType)
			:setPressedActionEnabled(true)
			:align(display.CENTER, 100, 50)
			:addTo(richRefreshBoss)
			:setName("btn_fly_mon"):setVisible(false)

		GUIFocusPoint.addUIPoint(btnFly, function (pSender)
			if pSender.monId then
				actionTakeBackTips(richRefreshBoss)
				GameSocket:PushLuaTable("mon.bossRefresh.onPanelData",GameUtilSenior.encode({actionid = "flyToMon", monId = pSender.monId}))
			end
		end)
	end
	handleRefreshTips(richRefreshBoss, true)
end

--界面模式（战斗/简单）
local function handleSwitchUIMode(event)
	-- print("///////////handleSwitchUIMode//////////", event.gesture, GameConst.GESTURE_SLIDE_IN, GameConst.GESTURE_SLIDE_OUT)
	if not var.righttop then return end
	for _,v in ipairs(slideWidget) do
		if event.mode == GameConst.UI_COMPLETE then
			moveWidget(var.righttop, v, true)
		elseif event.mode == GameConst.UI_SIMPLIFIED then
			moveWidget(var.righttop, v, false)
		end
	end
end

function GUIRightTop.init_ui(righttop)

	if not righttop then return end

	var = {
		righttop,
		lblMapName,
		lblMapPos,
		usableExtends = {},
		addGhostPoint,
		-- mainGhost,
		miniPos,
		btnControlExtend,
		lock,
		extVisible = false, -- 记录点击按钮修改的可见性

		refreshBoss = {},

		rtWidth = nil,

	}

	GameSocket:PushLuaTable("gui.PanelGem.handlePanelData",GameUtilSenior.encode({actionid = "getServerDay",params = {}}))

	var.righttop = righttop
	righttop:align(display.RIGHT_TOP, display.right, display.top )
	var.btnControlExtend = righttop:getWidgetByName("btn_control_extend"):setScale(0.9):setPressedActionEnabled(true)

	local pSize = var.righttop:getContentSize()
	var.rtWidth = pSize.width

	-- righttop:getWidgetByName("btn_main_boss")

	-- GameSocket:checkGuiButton(v)

	var.btnControlExtend.showFlag = false
	var.righttop:getWidgetByName("box_extend").showFlag = var.btnControlExtend.showFlag
	GUIFocusPoint.addUIPoint(var.btnControlExtend, GUIRightTop.pushControlButton)
	GUIRightTop.pushControlButton(var.btnControlExtend)

	local btnShort
	for i,v in ipairs(short_button) do
		btnShort = righttop:getWidgetByName(v)
		btnShort:setPressedActionEnabled(true)
		GUIFocusPoint.addUIPoint(btnShort, pushShortButton)
	end
	handleGuiButtons()
	-- initExtendButtons()
	-- local boxExtend = var.righttop:getWidgetByName("box_extend")
	GUIFunctionExtra.init(righttop)

	cc.EventProxy.new(GameSocket,righttop)
		:addEventListener(GameMessageCode.EVENT_ONEKEY_SHOW, GUIRightTop.onekeyShow)
		:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUIRightTop.handlePanelData)
		:addEventListener(GameMessageCode.EVENT_GUI_BUTTON, handleGuiButtons)
		:addEventListener(GameMessageCode.EVENT_EXTEND_VISIBLE, function (event)
			if event.lock =="unlock" then
				var.lock = false
			end
			if not var.lock then
				if not event.visible then
					handleExtendVisible(false)
				else
					handleExtendVisible(var.extVisible)
				end
			else
				if not event.visible then
					handleExtendVisible(false)
				end
			end
			if event.lock =="lock" then
				var.lock = true
			end
		end)
		:addEventListener(GameMessageCode.EVENT_SWITCH_UI_MODE, handleSwitchUIMode)
		:addEventListener(GameMessageCode.EVENT_REFRESH_BOSS, onRefreshBoss)

	-- local boxMiniMap = righttop:getWidgetByName("box_mini_map")
	local boxMiniMap = righttop:getWidgetByName("main_map_bg")
	GUIMapMin.init(boxMiniMap)
end

function GUIRightTop.setDownLoadBtnVisible(vis,arrowVis)
	-- var.righttop:getWidgetByName("main_download"):setVisible(vis)
	-- var.righttop:getWidgetByName("img_download_arrow"):setVisible(arrowVis)
end

function GUIRightTop.setBtnVisible(vis)
	-- var.righttop:getWidgetByName("main_buff"):setVisible(vis)
	-- var.righttop:getWidgetByName("main_download"):setVisible(vis)
end

function GUIRightTop.setDownLoadBtnAnim(anim)
	-- var.righttop:getWidgetByName("img_download_arrow"):stopAllActions()
	-- if anim then
	-- 	var.righttop:getWidgetByName("img_download_arrow"):runAction(cca.repeatForever(cca.seq({
	-- 		cca.fadeTo(1.6, 0),
	-- 		cca.fadeTo(1, 1)
	-- 	})))
	-- end
end

function GUIRightTop.pushControlButton(pSender)--点击隐藏按钮执行的动作
	var.extVisible = not pSender.showFlag
	handleExtendVisible(not pSender.showFlag)
end

function GUIRightTop.onekeyShow(event)
	-- local btnControl = var.righttop:getWidgetByName("btn_control_extend")
	if not var.btnControlExtend.showFlag then
		GUIRightTop.pushControlButton(var.btnControlExtend)
	end
end

function GUIRightTop.update()
	if not var.righttop then return end
	GUIMapMin.update()
end

function GUIRightTop.handlePanelData(event)
	local data = GameUtilSenior.decode(event.data)
	if event.type=="changeQiangHuaLev" then
		GameBaseLogic.setQiangHuaTable(data)
	elseif event.type=="server_start_day" then
		GameSocket.severDay = data.dayNum
	end
end

function GUIRightTop.set_box_func_preview_visible( vis )
	--var.righttop:getWidgetByName("box_func_preview"):setVisible(vis)
	--var.righttop:getWidgetByName("box_func_preview"):runAction(cca.seq({
	--	cca.moveTo(0.2, var.righttop:getWidgetByName("box_func_preview"):getPositionX()+248*(vis and -1 or 1), var.righttop:getWidgetByName("box_func_preview"):getPositionY())
	--}))
end

return GUIRightTop