GDivDialog = {}

local var = {}

local alertHandle = {
	["Welcome"] = function (event)
		local onClickStart
		local function pushStartButton(pSender)
			local btnName = pSender:getName()
			if btnName == "btnStart" then
				if onClickStart then onClickStart() end
			end
			GDivDialog.handleAlertClose()
		end

		if event.startCallBack then onClickStart = event.startCallBack end

		var.alertWelcome = var.layerColor:getWidgetByName("AlertWelcome")
		if not var.alertWelcome then
			var.alertWelcome = GUIAnalysis.load("ui/layout/AlertWelcome.uif")
			:align(display.CENTER, display.cx, display.cy)
			:addTo(var.layerColor)
			:setName("AlertWelcome")
		end
		local btnStart = var.alertWelcome:getWidgetByName("btnStart")
		-- btnStart:setTitleText(event.alertTitle or GameConst.str_titletext_alert)
		GUIFocusPoint.addUIPoint(btnStart, pushStartButton)
		local welcome_bg = var.alertWelcome:getWidgetByName("welcome_bg")
		asyncload_callback("ui/image/img_welcome_bg.png", welcome_bg, function(filepath, texture)
			welcome_bg:loadTexture(filepath)
		end)
		var.alertWelcome:setTouchEnabled(true)

		var.alertWelcome:setVisible(event.visible)
		var.layerColor:setVisible(event.visible)

		var.alertWelcome:runAction(cca.seq({
			cca.delay(3),
			cca.cb(function ()
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_GUIDE, lv = 1})
			end)
		}))
	end,
	["Editbox"] = function (event)
		local onClickConfirm, onClickCancel
		local function pushConfirmButtons( pSender )
			GDivDialog.handleAlertClose()
			local btnName = pSender:getName()
			if btnName == "btnConfirm" then
				if onClickConfirm then onClickConfirm(var.editbox:getText()) end
			elseif btnName == "btnCancel" then
				if onClickCancel then onClickCancel() end
			end
		end

		onClickConfirm = event.confirmCallBack
		onClickCancel = event.cancelCallBack
		if not var.alertEditbox then
			var.alertEditbox = GUIAnalysis.load("ui/layout/AlertEditbox.uif")
				:addTo(var.layerColor)
				:align(display.CENTER, display.cx, display.cy)
			
			var.alertEditbox:setTouchEnabled(true)
			var.editbox = GameUtilSenior.newEditBox({
				image = "image/icon/img_dialogBg.png",
				size = cc.size(240,32),
				color = cc.c4b(200, 200, 200,255),
				placeHolder = event.placehold,
			}):addTo(var.alertEditbox,1)
			:align(display.BOTTOM_LEFT,60,120)
		end
		var.editbox:setString("")

		local btnConfirm = var.alertEditbox:getWidgetByName("btnConfirm")
		btnConfirm:setTitleText(event.confirmTitle or GameConst.str_titletext_confirm)
		GUIFocusPoint.addUIPoint(btnConfirm, pushConfirmButtons)
		local btnCancel = var.alertEditbox:getWidgetByName("btnCancel")
		btnCancel:setTitleText(event.cancelTitle or GameConst.str_titletext_cancel)
		GUIFocusPoint.addUIPoint(btnCancel, pushConfirmButtons)

		var.alertEditbox:setVisible(event.visible)
		var.layerColor:setVisible(event.visible)

		if event.visible then
			var.alertEditbox:getWidgetByName("lblConfirm"):setString(event.lblConfirm)
		end
	end,
	["Hint"] = function (event)
		local onClickStart
		local function pushStartButton(pSender)
			local btnName = pSender:getName()
			if btnName == "btnStart" then
				if onClickStart then onClickStart() end
			end
			GDivDialog.handleAlertClose()
		end

		if event.startCallBack then onClickStart = event.startCallBack end

		var.alertHint =  var.layerColor:getWidgetByName("AlertHint")
		if not var.alertHint then
			var.alertHint = GUIAnalysis.load("ui/layout/GDivDialogHint.uif")
				:align(display.CENTER, display.cx, display.cy)
				:addTo(var.layerColor)
				:setName("AlertHint")
		end
		local btnAlert = var.alertHint:getWidgetByName("btnAlert")
		btnAlert:setTitleText(event.alertTitle or GameConst.str_titletext_alert)
		GUIFocusPoint.addUIPoint(btnAlert, pushStartButton)
		local lblAlert1 = var.alertHint:getWidgetByName("lblAlert1")
		lblAlert1:setString(event.lblAlert1)
		local listAlert2 = var.alertHint:getWidgetByName("listAlert2")
		listAlert2:removeAllItems()
		if event.lblAlert2 then
			local strs = {}
			if type(event.lblAlert2) == "string" then
				strs = {event.lblAlert2}
			elseif type(event.lblAlert2) == "table" then
				strs = event.lblAlert2
			end
			for i,v in ipairs(strs) do
				local richLabel = GUIRichLabel.new({size = cc.size(listAlert2:getContentSize().width, 30), space=3,name = "hintMsg"..i})
				richLabel:setRichLabel(v)
				listAlert2:pushBackCustomItem(richLabel)
			end
		end
		var.alertHint:setTouchEnabled(true)

		var.alertHint:setVisible(event.visible)
		var.layerColor:setVisible(event.visible)

	end,
	["Tips"] = function (event)
		var.alertTips = var.layerAlert:getWidgetByName("AlertTips")
		if not var.alertTips then
			var.alertTips = GUIAnalysis.load("ui/layout/GDivDialog.uif")
				:align(display.CENTER, display.cx, display.cy)
				:addTo(var.layerAlert)
				:setName("AlertTips")
		end
		local tipsInfoBg = var.alertTips:getWidgetByName("tipsInfoBg")
		local tipsList = var.alertTips:getWidgetByName("tipsList")
		tipsList:removeAllItems()
		if event.infoTable then
			local strs = {}
			if type(event.infoTable) == "string" then
				strs = {event.infoTable}
			elseif type(event.infoTable) == "table" then
				strs = event.infoTable
			end
			local totalHeight,defaultHeight = 0,190
			for i,v in ipairs(strs) do
				local richLabel = GUIRichLabel.new({size = cc.size(tipsList:getContentSize().width, 30), space=3,name = "hintMsg"..i})
				richLabel:setRichLabel("<font color=#f1e8d0>"..v.."</font>","",16)
				tipsList:pushBackCustomItem(richLabel)

				totalHeight = totalHeight + richLabel:getContentSize().height + tipsList:getItemsMargin()
			end
			-- if totalHeight>defaultHeight then
				local contentsize = tipsList:getContentSize()
				local containersize = tipsList:getInnerContainerSize()
				tipsList:setContentSize(containersize.width, totalHeight + 10)
				tipsInfoBg:setContentSize(tipsInfoBg:getContentSize().width, totalHeight+50)
				-- var.alertTips:setPositionY(var.alertTips:getPositionY()+(totalHeight-defaultHeight)/2)
			-- end
		end
		var.alertTips:setTouchEnabled(true)
		var.alertTips:setVisible(event.visible)
		var.layerColor:setVisible(event.bgVisible or false)

	end,
}

function GDivDialog.init()
	var = {
		layerAlert,
		layerColor,
		layerServerMsg,

		----以下是6种类型的提示面板
		alertWelcome,
		alertEditbox,
		alertHint,
		alertTips,
		---------
		-- schedule = nil,
		-- count = 0,
		alertQueue,--消息队列
		hasSended = false, --卡牌
	}

	-- 提示层
	var.layerAlert = ccui.Widget:create()
		:size(display.width, display.height)
		:align(display.CENTER, display.cx, display.cy)
	-- 提示层背景
	var.layerColor = ccui.ImageView:create("bg_4", ccui.TextureResType.plistType)
		:setScale9Enabled(true)
		:setContentSize(cc.size(display.width, display.height))
		:setTouchEnabled(true)
		:align(display.CENTER, display.cx, display.cy)
		:addTo(var.layerAlert)
		:hide()

	var.layerServerMsg = cc.Layer:create()
		:addTo(var.layerAlert)

	var.layerColor:addClickEventListener(GDivDialog.handleAlertClose)

	cc.EventProxy.new(GameSocket,var.layerAlert)
		:addEventListener(GameMessageCode.EVENT_PANEL_ON_ALERT, GDivDialog.handlePanelOnAlert)
		:addEventListener(GameMessageCode.EVENT_MAIN_ATTR_PLUS, GDivDialog.handleAttrPlus)

	return var.layerAlert
end

function GDivDialog.exit()
	-- if var.schedule then
	-- 	Scheduler.unscheduleGlobal(var.schedule)
	-- 	var.schedule = nil
	-- end
end

function GDivDialog.handleAttrPlus(event)
	GUINumToast.handleValueChange(var.layerServerMsg, event)
end


function GDivDialog.handlePanelOnAlert(event)
	if event then
		if event.panel == "all" then 
			if not event.visible then -- 隐藏所有alert面板
				print("close all")
				GDivDialog.handleAlertClose()
			end
		elseif event.panel == "buy" then
			GDivDialog.handleAlertInput(event, string.ucfirst(event.panel))
		else
			local key = string.ucfirst(event.panel)
			if alertHandle[key] then
				alertHandle[key](event,key)
			end
			-- GDivDialog["handleAlert"..string.ucfirst(event.panel)](event,string.ucfirst(event.panel))
		end

		if event.visible and event.panel~="tips" then
			GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_HANDLE_ALL_TRANSLUCENTBG, visible = false})
		end
	end
end

-- 隐藏所有提示框
function GDivDialog.handleAlertClose()
	for k,v in pairs(alertHandle) do
		if var["alert"..k] then 
			local checkbox = var["alert"..k]:getWidgetByName("GUIConfirm")
			if checkbox then checkbox:removeFromParent() end
			var["alert"..k]:hide():stopAllActions()
		end
	end
	var.layerColor:hide()
	GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_HANDLE_ALL_TRANSLUCENTBG, visible = true})
end

-----------------提示面板-------------
-- local param = {
-- 	name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "hint", visible = true, lblAlert1 = "抬头", lblAlert2 = "你就是一个臭煞笔，不服来战！",
-- 	alertTitle = "朕知道了",
-- 	alertCallBack = function ()
-- 		print("你这个丑傻逼")
-- 	end
-- }
-- GameSocket:dispatchEvent(param)
-----------------输入框面板-------------
-- local param = {
-- 	name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "input", visible = true, lblConfirm = "请输入购买坐骑丹数量！",
-- confirmTitle = "确定",
-- 	confirmCallBack = function ()
-- 		print("你不是傻逼？？？")
-- 	end
-- }
-- GameSocket:dispatchEvent(param)

--[[
	--通用提示框
		if eventType == ccui.TouchEventType.began then
			GameSocket:dispatchEvent({
				name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true,bgVisible =false, infoTable = lblhint[var.tp],
			})
		elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false }) end
--]]