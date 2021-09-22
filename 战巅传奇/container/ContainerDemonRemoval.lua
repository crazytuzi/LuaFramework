local ContainerDemonRemoval

 = {}
local var = {}

local chuMoButtons = {
	"btn_accept_task", 
	"btn_refresh_star",
	"btn_get_award",
	"btn_double_award", 
	"btn_treble_award", 
}

local function pushChuMoButton(pSender)
	local btnName = pSender:getName()
	if btnName == "btn_accept_task" then
		if pSender.accepted then
			GameSocket:PushLuaTable("npc.chumo.onPanelData", GameUtilSenior.encode({cmd = "continueTask"}))
		else
			GameSocket:PushLuaTable("npc.chumo.onPanelData", GameUtilSenior.encode({cmd = "acceptTask"}))
		end
	elseif btnName == "btn_refresh_star" then
		GameSocket:PushLuaTable("npc.chumo.onPanelData", GameUtilSenior.encode({cmd = "freshTask"}))
	elseif btnName == "btn_get_award" then
		GameSocket:PushLuaTable("npc.chumo.onPanelData", GameUtilSenior.encode({cmd = "getAward1"}))
	elseif btnName == "btn_double_award" then
		GameSocket:PushLuaTable("npc.chumo.onPanelData", GameUtilSenior.encode({cmd = "getAward2"}))
	elseif btnName == "btn_treble_award" then
		GameSocket:PushLuaTable("npc.chumo.onPanelData", GameUtilSenior.encode({cmd = "getAward3"}))
	end
end

local function updateTaskDesp(taskDesp)
	-- 富文本
	local scroll = var.xmlPanel:getWidgetByName("npc_scroll")
	scroll:setContentSize(cc.size(380, 130))
	scroll:setInnerContainerSize(cc.size(380, 130))
	scroll:setClippingEnabled(true)
	scroll:removeAllChildren()
	local innerSize = scroll:getInnerContainerSize()
	local contentSize = scroll:getContentSize()
	local labelTalk = GUIRichLabel.new({size=cc.size(contentSize.width-20, 0), space=20,})
		:align(display.LEFT_BOTTOM,0,0)
		:addTo(scroll)
		
	local msgSize = labelTalk:setRichLabel(taskDesp, "panel_chumo", 20)
	if msgSize.height < contentSize.height then
		labelTalk:setPosition(cc.p(0,contentSize.height-msgSize.height))
	end

	scroll:setInnerContainerSize(cc.size(innerSize.width,msgSize.height))
	scroll:setBounceEnabled(true)
	scroll:jumpToPercentVertical(0)
end

local function updateTaskLevel(level)
	level = level or 1
	local imgStar
	for i=1,10 do
		imgStar = var.xmlPanel:getWidgetByName("img_star_"..i)
		if imgStar then
			if level >= i then
				imgStar:loadTexture("img_task_star", ccui.TextureResType.plistType)
			else
				imgStar:loadTexture("img_task_star_circle", ccui.TextureResType.plistType)
			end
		end
	end
end

local function updateTaskState(serverData)
	local taskState = serverData.taskState
	var.boxGetAward:hide()
	var.boxAcceptTask:hide()
	if taskState < GameConst.TSCOMP then
		var.boxAcceptTask:show()
		local btnAcceptTask = var.xmlPanel:getWidgetByName("btn_accept_task")
		if taskState == GameConst.TSACCE then
			if serverData.acceptCost and serverData.acceptCost > 0 then
				btnAcceptTask:loadTextures("btn_buy_task", "btn_buy_task", "", ccui.TextureResType.plistType)
			else
				btnAcceptTask:loadTextures("btn_accept_task", "btn_accept_task", "", ccui.TextureResType.plistType)
			end
			btnAcceptTask.accepted = false
		elseif taskState == GameConst.TSACED then
			btnAcceptTask.accepted = true
			btnAcceptTask:loadTextures("btn_continue_task", "btn_continue_task", "", ccui.TextureResType.plistType)
		end
	elseif taskState == GameConst.TSCOMP then
		var.boxGetAward:show()
		local imgTrebleAwardHalo = var.boxGetAward:getWidgetByName("img_treble_award_halo")
		imgTrebleAwardHalo:stopAllActions()
		imgTrebleAwardHalo:runAction(cca.repeatForever(cca.seq({
				cca.fadeOut(0.5),
				cca.fadeIn(0.5),
			})
		))
	end
end

local function handlePanelData(event)
	if event.type ~= "ContainerDemonRemoval

" then return end
	local serverData = GameUtilSenior.decode(event.data)

	var.xmlPanel:getWidgetByName("lbl_npc_name"):setString(serverData.npcName)
	var.xmlPanel:getWidgetByName("lbl_times_remain"):setString("今日剩余次数："..serverData.timesRemain)
	local lblAcceptCost = var.xmlPanel:getWidgetByName("lbl_accept_cost")
	if serverData.acceptCost and serverData.acceptCost > 0 then
		lblAcceptCost:setString("花费"..serverData.acceptCost.."元宝")
	else
		lblAcceptCost:setString(""):hide()
	end

	local taskAward = serverData.taskAward
	if taskAward then
		if taskAward.exp then
			var.xmlPanel:getWidgetByName("lbl_award_exp"):setString(taskAward.exp)
		end
		if taskAward.reputation then
			var.xmlPanel:getWidgetByName("lbl_award_reputation"):setString(taskAward.reputation)
		end
	end

	local btnRefreshStar = var.xmlPanel:getWidgetByName("btn_refresh_star")
	btnRefreshStar:setBright(serverData.canRefresh)
	btnRefreshStar:setTouchEnabled(serverData.canRefresh)

	

	updateTaskDesp(serverData.taskDesp)
	updateTaskState(serverData)
	updateTaskLevel(serverData.taskLevel)
end

----------------------------------以上为内部函数----------------------------------
function ContainerDemonRemoval

.initView(event)
	var = {
		xmlPanel,
		m_eventParam,
		boxGetAward,
		boxAcceptTask,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerDemonRemoval

.uif")
	if var.xmlPanel then
		var.boxGetAward = var.xmlPanel:getWidgetByName("box_get_award"):hide()
		var.boxAcceptTask = var.xmlPanel:getWidgetByName("box_accept_task"):hide()
		
		--var.xmlPanel:getWidgetByName("talk_bg"):loadTexture("ui/image/img_npc_talk_bg.jpg")
		local path = "ui/image/img_npc_talk_bg.jpg"
		asyncload_callback(path, var.xmlPanel:getWidgetByName("talk_bg"), function(path, texture)
			var.xmlPanel:getWidgetByName("talk_bg"):loadTexture(path)
		end)
		var.xmlPanel:getWidgetByName("lbl_npc_name"):setString("除魔使者")
		var.xmlPanel:getWidgetByName("talk_bg"):setTouchEnabled(true)

		local btnArrowClose = var.xmlPanel:getWidgetByName("arrow_close")
		if btnArrowClose then
			GUIFocusPoint.addUIPoint(btnArrowClose,function(pSender)
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_chumo", anima = true, dir = 0});
			end) 
		end

		local btnChuMo
		for _,v in ipairs(chuMoButtons) do
			btnChuMo = var.xmlPanel:getWidgetByName(v)
			if btnChuMo then
				GUIFocusPoint.addUIPoint(btnChuMo, pushChuMoButton) 
			end
		end

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, handlePanelData)
		--数据请求
		GameSocket:PushLuaTable("npc.chumo.onPanelData",	GameUtilSenior.encode({cmd = "panel"}))
		return var.xmlPanel
	end
end

function ContainerDemonRemoval

.onPanelOpen()
	-- body
end

function ContainerDemonRemoval

.onPanelClose()
	
end

return ContainerDemonRemoval

