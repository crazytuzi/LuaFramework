local ContainerTask = {}
local var = {}

local awardSpace = 9;
local awardWith = 76;

local function pushTaskChange(pSender)
	if var.m_eventParam then
		GameSocket:NpcTalk(GameSocket.m_nNpcTalkId, var.m_eventParam)
		var.m_eventParam = nil
	end
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_mainTask"})
end

local function updateTaskAward(awards)
	-- print("updateTaskAward", GameUtilSenior.encode(awards))
	local subItem
	local totalWidth = var.xmlPanel:getWidgetByName("box_task_award"):getContentSize().width
	local num = #awards
	local posX = 0
	if num > 0 then
		posX = 0.5 * (totalWidth - (awardWith + awardSpace) * num + awardSpace)
	end

	for i = 1, 4 do
		subItem = var.xmlPanel:getWidgetByName("item_icon_"..i)
		if subItem then
			if awards[i] then
				subItem:setVisible(true)
				local param = {
					parent = subItem,
					typeId = awards[i].itemId,
					num = awards[i].num,
					bind = awards[i].bind,
				}
				GUIItem.getItem(param)
				subItem:setPositionX(posX + (awardSpace + awardWith) * (i - 1))
			else
				subItem:setVisible(false)
			end
		end
	end
end

function ContainerTask.initView(event)
	var = {
		xmlPanel,
		m_eventParam,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerNpcTalk.uif")
	if var.xmlPanel then

		--var.xmlPanel:getWidgetByName("talk_bg"):loadTexture("ui/image/img_npc_talk_bg.jpg")
		
		local path = "ui/image/img_npc_talk_bg.jpg"
		asyncload_callback(path, var.xmlPanel:getWidgetByName("talk_bg"), function(path, texture)
			var.xmlPanel:getWidgetByName("talk_bg"):loadTexture(path)
		end)

		var.xmlPanel:getWidgetByName("talk_bg"):setTouchEnabled(true)

		local pTask = GameUtilSenior.decode(GameSocket.m_strNpcTalkMsg)
		local talkMsg = pTask.desc

		updateTaskAward(pTask.award)

		var.m_eventParam = pTask.event
		-- 显示任务名称
		if pTask.task_name and pTask.task_name ~= "" then
			var.xmlPanel:getWidgetByName("lbl_task_name"):setString(pTask.task_name)
		end
		
		-- 显示任务描述(富文本)
		local scroll = var.xmlPanel:getWidgetByName("lblList1")
		scroll:setContentSize(cc.size(370, 130))
		scroll:setInnerContainerSize(cc.size(370, 130))
		scroll:setClippingEnabled(true)
		local innerSize = scroll:getInnerContainerSize()
		local contentSize = scroll:getContentSize()

		local btnTaskChange = var.xmlPanel:getWidgetByName("btn_task_change")
		btnTaskChange:setPressedActionEnabled(true)
		btnTaskChange:setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(btnTaskChange, pushTaskChange)

		btnTaskChange:runAction(cca.seq({
			cca.delay(30),
			cca.cb(function()
				pushTaskChange(btnTaskChange)
			end)
		}))

		local labelTalk = GUIRichLabel.new({size=cc.size(contentSize.width-10, 0), space=10,})
			:align(display.LEFT_BOTTOM,0,0)
			:addTo(scroll)
			
		local msgSize = labelTalk:setRichLabel("     <font color=#dfcdaa>"..talkMsg.."</font>", "panel_chat", 20)
		-- if msgSize.height < contentSize.height then
		-- 	labelTalk:setPosition(cc.p(0,contentSize.height-msgSize.height))
		-- end
		-- scroll:setInnerContainerSize(cc.size(innerSize.width,msgSize.height))
		scroll:setBounceEnabled(true)
		scroll:jumpToPercentVertical(0)

		local btnArrowClose = var.xmlPanel:getWidgetByName("arrow_close")
		if btnArrowClose then
			GUIFocusPoint.addUIPoint(btnArrowClose,	function(pSender)
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_mainTask", anima = true, dir = 0});
			end) 
		end

		return var.xmlPanel
	end
end

function ContainerTask.onPanelOpen()
	var.xmlPanel:getWidgetByName("lbl_task_count"):hide()
	if var.m_eventParam then
		GameSocket:PushLuaTable("gui.moduleGuide.checkGuide",GameUtilSenior.encode({actionid = "mainTaskOpen"}))
	end
end

function ContainerTask.onPanelClose()
	-- print("ContainerTask.onPanelClose", var.m_eventParam)
	-- if var.m_eventParam then
		GameSocket:PushLuaTable("gui.moduleGuide.checkGuide",GameUtilSenior.encode({actionid = "mainTaskClose", param = var.m_eventParam}))
	-- end
	var.m_eventParam = nil
end

return ContainerTask