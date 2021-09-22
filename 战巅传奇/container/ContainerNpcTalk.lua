local ContainerNpcTalk = {}
local var = {}

function ContainerNpcTalk.initView(event)
	var = {
		xmlPanel,
		m_eventParam,
		panelType = "npc",
		talk_str,
		btncall,
		npcName,

		title=nil,
		btnEnter=nil,
		func=nil,--记录监听的类型
		funcs=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerNpcTalk.uif")
	if var.xmlPanel then
		var.xmlPanel:getWidgetByName("lbl_task_name"):setString("")

		--var.xmlPanel:getWidgetByName("talk_bg"):loadTexture("ui/image/img_npc_talk_bg.jpg")
		
		local path = "ui/image/img_npc_talk_bg.jpg"
		asyncload_callback(path, var.xmlPanel:getWidgetByName("talk_bg"), function(path, texture)
			var.xmlPanel:getWidgetByName("talk_bg"):loadTexture(path)
		end)
		
		ContainerNpcTalk.clickBind()
		
		return var.xmlPanel
	end
end

function ContainerNpcTalk.clickBind()

	var.xmlPanel:getWidgetByName("talk_bg"):setTouchEnabled(true)
		
	local btnTaskChange = var.xmlPanel:getWidgetByName("btn_task_change")
	btnTaskChange:setPressedActionEnabled(true)
	btnTaskChange:setTouchEnabled(true)
	btnTaskChange:addClickEventListener(ContainerNpcTalk.pushTaskChange)

	local btnGetAwardTripple = var.xmlPanel:getWidgetByName("btn_tripple_award")
	btnGetAwardTripple:setTag(3)
	btnGetAwardTripple:setPressedActionEnabled(true)
	btnGetAwardTripple:setTouchEnabled(true)
	btnGetAwardTripple:addClickEventListener(ContainerNpcTalk.pushGetAward)

	local btnGetAwardDouble = var.xmlPanel:getWidgetByName("btn_double_award")
	btnGetAwardDouble:setTag(2)
	btnGetAwardDouble:setPressedActionEnabled(true)
	btnGetAwardDouble:setTouchEnabled(true)
	btnGetAwardDouble:addClickEventListener(ContainerNpcTalk.pushGetAward)

	local btnGetAward = var.xmlPanel:getWidgetByName("btn_get_award")
	btnGetAward:setTag(1)
	btnGetAward:setPressedActionEnabled(true)
	btnGetAward:setTouchEnabled(true)
	btnGetAward:addClickEventListener(ContainerNpcTalk.pushGetAward)


	local btnArrowClose = var.xmlPanel:getWidgetByName("arrow_close")
	if btnArrowClose then
		GUIFocusPoint.addUIPoint(btnArrowClose,	function(pSender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_playertalk", anima = true, dir = 0});
		end) 
	end
end

function ContainerNpcTalk.updatePanelType(paneltype)
	var.xmlPanel:getWidgetByName("img_npc_talk_line1"):show()
	var.xmlPanel:getWidgetByName("img_npc_talk_line2"):hide()
	var.xmlPanel:getWidgetByName("lbl_task_count"):hide()
	local talks = {
		["npc"] = function()
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(360,130))
			var.xmlPanel:getWidgetByName("lblList2"):hide()
			-- var.xmlPanel:getWidgetByName("btn_task_change"):hide():loadTextures("btn_npc_talk", "btn_npc_talk","",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("talk_title"):setString("对话")
			var.xmlPanel:getWidgetByName("box_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_name"):setString(var.npcName and var.npcName or "")

			var.xmlPanel:getWidgetByName("btn_task_change"):setTitleText("关闭")
			var.xmlPanel:getWidgetByName("img_npc_talk_line1"):hide()
			var.xmlPanel:getWidgetByName("img_npc_talk_line2"):show()
			ContainerNpcTalk.updateList(var.xmlPanel:getWidgetByName("lblList1"), "     <font color=#dfcdaa>"..var.talk_str.."</font>")
		end,
		["city"] = function()
			--皇城战
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(360,160))
			var.xmlPanel:getWidgetByName("lblList2"):show()
			var.xmlPanel:getWidgetByName("btn_task_change"):setTitleText("申请皇城战")
			var.xmlPanel:getWidgetByName("talk_title"):setString("皇城战")
			var.xmlPanel:getWidgetByName("box_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_name"):hide()
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList1"),var.talk_str.strs1 )
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList2"),var.talk_str.strs2 )
		end,
		["huanggong"] = function()
			--皇城战
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(360,160))
			var.xmlPanel:getWidgetByName("lblList2"):show()
			var.xmlPanel:getWidgetByName("btn_task_change"):setTitleText("进入皇宫")
			var.xmlPanel:getWidgetByName("talk_title"):setString("皇宫")
			var.xmlPanel:getWidgetByName("box_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_name"):hide()
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList1"),var.talk_str.strs1 )
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList2"),var.talk_str.strs2 )
		end,
		["common"]=function()
			--纯文本同时面板
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(360,160))
			var.xmlPanel:getWidgetByName("lblList2"):show()
			if var.talk_str.resData.btnName~=nil and var.talk_str.resData.btnName~="" then
				var.xmlPanel:getWidgetByName("lblList2"):size(320,260):setPositionY(140)
			else
				var.xmlPanel:getWidgetByName("lblList2"):size(320,360):setPositionY(40)
				var.xmlPanel:getWidgetByName("btn_task_change"):hide()
			end
			var.xmlPanel:getWidgetByName("box_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_name"):hide()
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList1"),var.talk_str.strs1 )
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList2"),var.talk_str.strs2 )
		end,
		["bigpanel"]=function()
			--大面板
			--var.xmlPanel:getWidgetByName("talk_bg"):loadTexture("ui/image/img_npc_talk_big_bg.png")
			
			local path = "ui/image/img_npc_talk_big_bg.jpg"
			asyncload_callback(path, var.xmlPanel:getWidgetByName("talk_bg"), function(path, texture)
				var.xmlPanel:getWidgetByName("talk_bg"):loadTexture(path)
			end)
				
			var.xmlPanel:getWidgetByName("ContainerNpcTalk"):size(700,640)
			var.xmlPanel:getWidgetByName("talk_title"):setPositionX(350)
			var.xmlPanel:getWidgetByName("talk_bg"):size(700,640)
			var.xmlPanel:getWidgetByName("box_common"):size(700,640)
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(641,450))
			if var.talk_str.resData.btnName~=nil and var.talk_str.resData.btnName~="" then
				var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(641,450))
			else
				var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(641,550))
				var.xmlPanel:getWidgetByName("btn_task_change"):hide()
			end
			var.xmlPanel:getWidgetByName("arrow_close"):align(display.BOTTOM_LEFT, 641, 223)
			var.xmlPanel:getWidgetByName("btn_task_change"):align(display.BOTTOM_LEFT, 232, 30)
			var.xmlPanel:getWidgetByName("lblList2"):hide()
			var.xmlPanel:getWidgetByName("box_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_name"):hide()
			var.xmlPanel:getWidgetByName("img_npc_talk_line1"):hide()
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList1"),var.talk_str.str )
			ContainerNpcTalk.clickBind()
		end,
		["dartaward"]=function()
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(360,160))
			var.xmlPanel:getWidgetByName("lblList2"):hide()
			var.xmlPanel:getWidgetByName("box_task_award"):show()
			var.xmlPanel:getWidgetByName("lbl_task_award"):show()
			var.xmlPanel:getWidgetByName("img_npc_talk_line2"):show()
			var.xmlPanel:getWidgetByName("lbl_task_name"):hide()
			local x1 = var.xmlPanel:getWidgetByName("box_task_award"):getContentSize().width / 2
			local x2 = var.xmlPanel:getWidgetByName("item_icon_1"):getContentSize().width
			var.xmlPanel:getWidgetByName("item_icon_1"):setPositionX(x1 - x2 - 15)
			var.xmlPanel:getWidgetByName("item_icon_2"):setPositionX(x1 + 15)
			var.xmlPanel:getWidgetByName("item_icon_3"):hide()
			var.xmlPanel:getWidgetByName("item_icon_4"):hide()
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList1"),var.talk_str.strs1 )

			if var.talk_str.awards then
				for i=1,2 do
					local itemIcon = var.xmlPanel:getWidgetByName("item_icon_"..i)
					if var.talk_str.awards[i] then
						itemIcon:setVisible(true)
						local param={parent=itemIcon , typeId=var.talk_str.awards[i].id , num = var.talk_str.awards[i].num}
						GUIItem.getItem(param)
					else
						itemIcon:setVisible(false)
					end
				end	
			end
		end,
		["shaozhu"]=function()
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(360,160))
			var.xmlPanel:getWidgetByName("lblList2"):show()
			var.xmlPanel:getWidgetByName("box_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_award"):hide()
			var.xmlPanel:getWidgetByName("lbl_task_name"):hide()
			var.xmlPanel:getWidgetByName("img_npc_talk_line2"):show()
			var.xmlPanel:getWidgetByName("lbl_task_count"):show():setString(var.talk_str.countstr..tostring(var.talk_str.count))
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList1"),var.talk_str.strs1 )
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList2"),var.talk_str.strs2 )
		end,
		["kuangzhu"] = function()
			var.xmlPanel:getWidgetByName("lblList1"):setContentSize(cc.size(360,160))
			var.xmlPanel:getWidgetByName("lblList2"):hide()
			var.xmlPanel:getWidgetByName("box_task_award"):show()
			var.xmlPanel:getWidgetByName("lbl_task_award"):show()
			var.xmlPanel:getWidgetByName("lbl_task_count"):show():setString(var.talk_str.strs2..var.talk_str.count)
			var.xmlPanel:getWidgetByName("img_npc_talk_line2"):show()
			var.xmlPanel:getWidgetByName("lbl_task_name"):hide()
			local x1 = var.xmlPanel:getWidgetByName("box_task_award"):getContentSize().width / 3
			local x2 = var.xmlPanel:getWidgetByName("item_icon_1"):getContentSize().width
			var.xmlPanel:getWidgetByName("item_icon_1"):setPositionX(x1 - x2 - 10)
			var.xmlPanel:getWidgetByName("item_icon_2"):setPositionX(x1 + 10)
			var.xmlPanel:getWidgetByName("item_icon_3"):setPositionX(x1 +x2+30)
			var.xmlPanel:getWidgetByName("item_icon_4"):hide()
			ContainerNpcTalk.updateList( var.xmlPanel:getWidgetByName("lblList1"),var.talk_str.strs1 )

			if var.talk_str.awards then
				for i=1,3 do
					local itemIcon = var.xmlPanel:getWidgetByName("item_icon_"..i)
					if var.talk_str.awards[i] then
						itemIcon:setVisible(true)
						local param={parent=itemIcon , typeId=var.talk_str.awards[i].id , num = var.talk_str.awards[i].num}
						GUIItem.getItem(param)
					else
						itemIcon:setVisible(false)
					end
				end	
			end
			if var.talk_str.resData.btnRes == "" then
				var.xmlPanel:getWidgetByName("btn_task_change"):hide()
			end
		end,
	}
	if talks[paneltype] then
		talks[paneltype]()
	end
end

function ContainerNpcTalk.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=10,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end

function ContainerNpcTalk.pushTaskChange(pSender)
	-- if pSender:getTitleText() == GameConst.str_accept_task then
	-- 	GameMusic.play("music/accept_task.mp3")
	-- elseif pSender:getTitleText() == GameConst.str_finish_task then
	-- 	GameMusic.play("music/complete_task.mp3")
	-- end
	if var.panelType == "npc" then

	elseif var.panelType == "city" then
		if var.btncall then 
			-- print("npc."..var.btncall..".onPanelData")
			GameSocket:PushLuaTable("npc."..var.btncall..".onPanelData",GameUtilSenior.encode({cmd = var.btncall}))
		else
			GameSocket:PushLuaTable("npc.huangcheng.onPanelData",GameUtilSenior.encode({cmd = "openKingCity"}))
		end
	elseif var.panelType == "huanggong" then
		GameSocket:PushLuaTable("npc.huangcheng.onPanelData",GameUtilSenior.encode({cmd = "enterKingCity"}))
	elseif var.panelType == "kingguard" then
		GameSocket:PushLuaTable("npc.huangcheng.onPanelData",GameUtilSenior.encode({cmd = "openKingCity"}))
	elseif var.panelType == "common" and var.func then
		GameSocket:PushLuaTable(var.func,GameUtilSenior.encode({cmd = "enter"}))
	elseif var.panelType == "bigpanel" and var.func then
		GameSocket:PushLuaTable(var.func,GameUtilSenior.encode({cmd = "enter"}))
	elseif var.panelType == "kuangzhu" and var.func then
		GameSocket:PushLuaTable(var.func,GameUtilSenior.encode({cmd = "enter"}))
	elseif var.panelType == "shaozhu" and var.func then
		GameSocket:PushLuaTable(var.func,GameUtilSenior.encode({cmd = "enter"}))
	elseif var.panelType == "dartaward" and var.func then
		GameSocket:PushLuaTable(var.func,GameUtilSenior.encode({cmd = "enter"}))
	end
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_playertalk"})

	GameMusic.play("music/25.mp3")
end

function ContainerNpcTalk.pushGetAward(pSender)
	-- if var.panelType == "dartaward" then
	-- 	if var.funcs ~= nil then
	-- 		print("pSender:getTag() == "..pSender:getTag())
	-- 		if pSender:getTag() > 0 and pSender:getTag() <= #var.funcs then
	-- 			GameSocket:PushLuaTable(var.funcs[pSender:getTag()],GameUtilSenior.encode({cmd = "enter"})) 
	-- 		end
	-- 	end
	-- end
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_playertalk"})
end

--根据不同NPC面板设置标题和按钮资源
function ContainerNpcTalk.setPanelResource(resData)
	--if not var.title then
	--	var.title = var.xmlPanel:getWidgetByName("talk_title")
	--end
	--var.title:loadTexture(resData.titleRes,ccui.TextureResType.plistType)
	if not var.title then
		var.title = var.xmlPanel:getWidgetByName("talk_title")
	end
	var.title:setString(resData.talkTitle)
	
	--if not var.btnEnter then
	--	var.btnEnter = var.xmlPanel:getWidgetByName("btn_task_change")
	--end
	--var.btnEnter:loadTextures(resData.btnRes,resData.btnRes,"",ccui.TextureResType.plistType)

	if not var.btnEnter then
		var.btnEnter = var.xmlPanel:getWidgetByName("btn_task_change")
	end
	var.btnEnter:setTitleText(resData.btnName)
end

function ContainerNpcTalk.onPanelOpen(event)
	var.talk_str = {}
	local result = event.result
	if result and result.panelType then
		var.panelType = result.panelType
	end
	if result.talk_str then
		var.talk_str = result.talk_str
	end
	
	if result.npcName then
		var.npcName = result.npcName
	end

	if result.btn then
		var.btncall = result.btn
	end
	ContainerNpcTalk.updatePanelType(var.panelType)
	
	if result and result.talk_str  then
		if result.talk_str.resData then
			ContainerNpcTalk.setPanelResource(result.talk_str.resData)
		end
		if result.talk_str.func then
			var.func=result.talk_str.func
		end
		if result.talk_str.funcs then
			var.funcs=result.talk_str.funcs
		end
	end
end

function ContainerNpcTalk.onPanelClose()
	if var.m_eventParam then
		GameSocket:NpcTalk(GameSocket.m_nNpcTalkId,var.m_eventParam)
	end
end

return ContainerNpcTalk