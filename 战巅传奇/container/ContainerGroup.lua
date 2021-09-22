local ContainerGroup={}
local var = {}
local jobNames = {GameConst.str_zs, GameConst.str_fs, GameConst.str_ds}
local headName = {{"new_main_ui_head.png","head_mfs","head_mds"},{"head_fzs","head_ffs","head_fds"}}

function ContainerGroup.initView()
	var = {
		xmlPanel,
		curSelectIndex=1,
		curTab=nil,
		curGroup=nil,--附近队伍选中的队长
		curPlayer=nil,
		curPlayerIndex=nil,
		curFriend=nil,
		curFriendIndex=nil,
		curMyGroup=nil,
		xmlOperate=nil,
		curGroupId=nil,--当前选中的队伍的id
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerGroup.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_GROUP_LIST_CHANGED,ContainerGroup.myGroupChange)
			:addEventListener(GameMessageCode.EVENT_FRIEND_FRESH, ContainerGroup.myFriendChange)
		var.xmlPanel:getWidgetByName("Panel_12"):hide()
		--GameUtilSenior.asyncload(var.xmlPanel, "img_load_bg", "ui/image/img_group_bg.jpg")
		ContainerGroup.initMyGroup()
		ContainerGroup.initTab()

		ContainerGroup.initBtns()

	end
	return var.xmlPanel
end

function ContainerGroup.onPanelData(event)

end

function ContainerGroup.onPanelClose()
	
end

function ContainerGroup.tabChangeShow(tabIndex)
	if tabIndex<=2 then
		var.xmlPanel:getWidgetByName("content_mygroup"):setVisible(true)
		var.xmlPanel:getWidgetByName("content34"):setVisible(false)
		if tabIndex==1 then
			ContainerGroup.setBtnShow()
		elseif tabIndex==2 then
			var.xmlPanel:getWidgetByName("btnFresh"):setVisible(true)
			var.xmlPanel:getWidgetByName("btnCreat"):setVisible(true)
			var.xmlPanel:getWidgetByName("btnReq"):setVisible(true)
			var.xmlPanel:getWidgetByName("btnJieSan"):setVisible(false)
			var.xmlPanel:getWidgetByName("btnLeave"):setVisible(false)
		end
		var.xmlPanel:getWidgetByName("Panel_12"):hide()
		--GameUtilSenior.asyncload(var.xmlPanel, "img_load_bg", "ui/image/img_group_bg.jpg")
	else
		var.xmlPanel:getWidgetByName("content_mygroup"):setVisible(false)
		var.xmlPanel:getWidgetByName("content34"):setVisible(true)
		if tabIndex==3 then
			var.xmlPanel:getWidgetByName("btnFreshFriend"):setVisible(false)
			var.xmlPanel:getWidgetByName("btnFreshPlayer"):setVisible(true)
		elseif tabIndex==4 then
			var.xmlPanel:getWidgetByName("btnFreshFriend"):setVisible(true)
			var.xmlPanel:getWidgetByName("btnFreshPlayer"):setVisible(false)
		end
		var.xmlPanel:getWidgetByName("Panel_12"):show()
		--GameUtilSenior.asyncload(var.xmlPanel, "img_load_bg", "ui/image/img_group_bg2.jpg")
	end
	var.curMyGroup=nil
	var.curGroup=nil
end

function ContainerGroup.initTab()
	local tabArr = {"我的队伍","附近队伍","附近玩家","我的好友"}
	local function prsTabClick(sender)
		if var.curTab then
			var.curTab:setBrightStyle(0)
			--var.curTab:getWidgetByName("btn_light"):hide()
		end
		sender:setBrightStyle(1)
		--sender:getWidgetByName("btn_light"):show()
		var.curTab=sender
		-- print(sender.index)
		if sender.index==1 then--我的队伍
			ContainerGroup.initMyGroup()
		elseif sender.index==2 then--附近队伍
			ContainerGroup.initNearbyGroup()
		elseif sender.index==3 then--附近玩家
			ContainerGroup.initNearbyPlayer()
		elseif sender.index==4 then--我的好友
			ContainerGroup.initMyFriend()
		end
		ContainerGroup.tabChangeShow(sender.index)
	end
	local function updateTabList(item)
		local tab = item:getWidgetByName("btnMode")
		tab:setTitleText(tabArr[item.tag])
		tab.index=item.tag
		GUIFocusPoint.addUIPoint(tab,prsTabClick)
		if item.tag==1 then
			prsTabClick(tab)
		end
	end
	--local tabList = var.xmlPanel:getWidgetByName("tabList")
	--tabList:reloadData(#tabArr,updateTabList):setSliderVisible(false)
	
	ContainerGroup.updateGameMoney()
	var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerGroup.pushTabButtons)
	var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
	
end

function ContainerGroup.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag==1 then--我的队伍
		ContainerGroup.initMyGroup()
		var.xmlPanel:getWidgetByName("img_bg"):setVisible(true)
	elseif tag==2 then--附近队伍
		ContainerGroup.initNearbyGroup()
		var.xmlPanel:getWidgetByName("img_bg"):setVisible(true)
	elseif tag==3 then--附近玩家
		ContainerGroup.initNearbyPlayer()
		var.xmlPanel:getWidgetByName("img_bg"):setVisible(false)
	elseif tag==4 then--我的好友
		ContainerGroup.initMyFriend()
		var.xmlPanel:getWidgetByName("img_bg"):setVisible(false)
	end
	ContainerGroup.tabChangeShow(tag)
end

--金币刷新函数
function ContainerGroup:updateGameMoney()
	local panel = var.xmlPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end

-----------------------------------------按钮操作-----------------------------------------------
local btnArrs = {"btnAuto","btnHand","btnRefuse","btnFresh","btnCreat","btnReq","btnJieSan","btnLeave","btnFreshPlayer","btnFreshFriend"}
function ContainerGroup.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- print(sender:getName())
		if senderName=="btnAuto" then
			ContainerGroup.groupPatternChange(1)
		elseif senderName=="btnHand" then
			ContainerGroup.groupPatternChange(2)
		elseif senderName=="btnRefuse" then
			ContainerGroup.groupPatternChange(3)
		-------------------------------------
		elseif senderName=="btnFresh" then
			ContainerGroup.initNearbyGroup()
		elseif senderName=="btnCreat" then
			GameSocket:CreateGroup(0)
		elseif senderName=="btnReq" then
			if var.curGroupId then
				GameSocket:JoinGroup(var.curGroupId)
			end
		elseif senderName=="btnJieSan" then
			GameSocket:PushLuaTable("gui.ContainerGroup.handlePanelData",GameUtilSenior.encode({actionid = "dissolveGroup",params={}}))
		elseif senderName=="btnLeave" then
			GameSocket:LeaveGroup()
		elseif senderName=="btnFreshPlayer" then
			ContainerGroup.initNearbyPlayer()
		elseif senderName=="btnFreshFriend" then
			ContainerGroup.initMyFriend()
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
	ContainerGroup.groupPatternChange(nil)
end

function ContainerGroup.groupPatternChange(type)
	if type then GameSetting.setConf("GroupType",type) end
	local btnAuto = var.xmlPanel:getWidgetByName("btnAuto"):setBrightStyle(0)
	local btnHand = var.xmlPanel:getWidgetByName("btnHand"):setBrightStyle(0)
	local btnRefuse = var.xmlPanel:getWidgetByName("btnRefuse"):setBrightStyle(0)
	local groupType = GameSetting.getConf("GroupType")
	if groupType==1 then
		btnAuto:setBrightStyle(1)
	elseif groupType==2 then
		btnHand:setBrightStyle(1)
	elseif groupType==3 then
		btnRefuse:setBrightStyle(1)
	end
end

-----------------------------------------我的队伍-----------------------------------------------
function ContainerGroup.initMyGroup()
	local myGroupData=clone(GameSocket.mGroupMembers)
	local function prsItemClick(sender)
		if var.curMyGroup then
			var.curMyGroup:getWidgetByName("imgSelected"):setVisible(false)
		end
		sender:getWidgetByName("imgSelected"):setVisible(true)
		var.curMyGroup = sender
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = sender.data})
	end
	local function updateGroupList(item)
		if var.curMyGroup and var.curMyGroup.tag==item.tag then
			item:getWidgetByName("imgSelected"):setVisible(true)
		else
			item:getWidgetByName("imgSelected"):setVisible(false)
		end
		local power = item:getWidgetByName("power")
		if not power then
			power = ccui.TextAtlas:create("0123456789", "image/typeface/num_10.png", 16, 22, "0")
			:addTo(item)
			:align(display.CENTER, 76,180)
			:setName("power")
		end
		power:setString(0)
		item:setTouchEnabled(true)

		local itemData = myGroupData[item.tag]
		if itemData.gender then
			item:getWidgetByName("imgHead"):loadTexture(headName[itemData.gender-199][itemData.job-99], ccui.TextureResType.plistType)
		end
		power:setString(itemData.power)
		item:getWidgetByName("labName"):setString(itemData.name)
		if itemData.job then
			item:getWidgetByName("labJob"):setString(jobNames[itemData.job-99])
		end
		if itemData.level then
			item:getWidgetByName("labLevel"):setString("Lv."..itemData.level)
		end
		if GameSocket.mCharacter.mGroupLeader==itemData.name then
			item:getWidgetByName("labZw"):setString("队长")
		else
			item:getWidgetByName("labZw"):setString("队员")
		end

		item.name=itemData.name
		item.data = itemData
		GUIFocusPoint.addUIPoint(item,prsItemClick)
	end
	
	local groupList = var.xmlPanel:getWidgetByName("listGroup")
	groupList:reloadData(#myGroupData,updateGroupList):setSliderVisible(false)
end


--组队信息改变
function ContainerGroup.myGroupChange(event)
	if var.curTab and var.curTab.index==1 then
		ContainerGroup.initMyGroup()
		ContainerGroup.setBtnShow()
	end
end

--根基当前有无队伍显示不同按钮
function ContainerGroup.setBtnShow()
	var.xmlPanel:getWidgetByName("btnFresh"):setVisible(false)
	var.xmlPanel:getWidgetByName("btnReq"):setVisible(false)
	local myGroupData=clone(GameSocket.mGroupMembers)
	local myName = GameCharacter._mainAvatar:NetAttr(GameConst.net_name)
	if #myGroupData<=0 then--没有队伍显示创建队伍
		var.xmlPanel:getWidgetByName("btnLeave"):setVisible(false)
		var.xmlPanel:getWidgetByName("btnCreat"):setVisible(true)
	else
		var.xmlPanel:getWidgetByName("btnCreat"):setVisible(false)
		var.xmlPanel:getWidgetByName("btnLeave"):setVisible(true)
	end
	if GameSocket.mCharacter.mGroupLeader==myName then--是队长显示解散队伍
		var.xmlPanel:getWidgetByName("btnJieSan"):setVisible(true)
	else
		var.xmlPanel:getWidgetByName("btnJieSan"):setVisible(false)
	end
end


-----------------------------------------附近队伍-----------------------------------------------
function ContainerGroup.initNearbyGroup()
	local nearGroups=ContainerGroup.getNearGroups()
	local function prsItemClick(sender)
		if var.curGroup then
			var.curGroup:getWidgetByName("imgSelected"):setVisible(false)
		end
		sender:getWidgetByName("imgSelected"):setVisible(true)
		var.curGroup = sender
		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = sender.name})
		var.curGroupId=sender.group_id
		-- print(sender.group_id)
	end

	local function updateNearbyGroupList(item)
		if var.curGroup and var.curGroup.tag==item.tag then
			item:getWidgetByName("imgSelected"):setVisible(true)
		else
			item:getWidgetByName("imgSelected"):setVisible(false)
		end
		local power = item:getWidgetByName("power")
		if not power then
			power = ccui.TextAtlas:create("0123456789", "image/typeface/num_10.png", 16, 22, "0")
			:addTo(item)
			:align(display.CENTER, 76,180)
			:setName("power")
		end
		power:setString(0)
		item:setTouchEnabled(true)
		local itemData = nearGroups[item.tag]
		item:getWidgetByName("imgHead"):loadTexture(headName[itemData.gender-199][itemData.job-99], ccui.TextureResType.plistType)
		power:setString(itemData.power)
		item:getWidgetByName("labName"):setString(itemData.name)
		item:getWidgetByName("labJob"):setString(jobNames[itemData.job-99])
		item:getWidgetByName("labLevel"):setString("Lv."..itemData.level)
		item:getWidgetByName("labZw"):setString("队长")
		item.name=itemData.name
		item.group_id=itemData.group_id
		GUIFocusPoint.addUIPoint(item,prsItemClick)
	end

	local groupList = var.xmlPanel:getWidgetByName("listGroup")
	groupList:reloadData(#nearGroups,updateNearbyGroupList)
end

--获取附近队伍
function ContainerGroup.getNearGroups()
	local result = {}
	for i, v in ipairs(NetCC:getNearGhost(GameConst.GHOST_PLAYER)) do
		local player = CCGhostManager:getPixesGhostByID(v)
		if player then
			local pName = player:NetAttr(GameConst.net_name)
			local pID = player:NetAttr(GameConst.net_id)
			local nearByGroupInfo = GameSocket.nearByGroupInfo[pID]
			if nearByGroupInfo then
				if nearByGroupInfo.group_leader == pName and pName ~= GameSocket.mCharacter.mGroupLeader then
					local param = {
						name = pName,
						group_id = nearByGroupInfo.group_id,
					}
					ContainerGroup.setParam(player, param)
					table.insert(result, param)
				end
			end
		end
	end
	return result
end

-----------------------------------------附近玩家-----------------------------------------------
function ContainerGroup.initNearbyPlayer()
	local nearPlayers = ContainerGroup.getNearPlayers()

	local function prsItemClick(sender)
		if var.curPlayer then
			var.curPlayer:getWidgetByName("imgSelected"):setVisible(false)	
		end
		sender:getWidgetByName("imgSelected"):setVisible(true)
		var.curPlayer = sender
		var.curPlayerIndex=sender.tag
		-- var.xmlOperate= GUIFloatTips.showOperateTips(var.xmlOperate,var.xmlPanel,nil)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = sender.name})
	end
	local function updateNearbyPlayerList(item)
		local itemData = nearPlayers[item.tag]
		item:getWidgetByName("imgSelected"):setVisible(false)
		if var.curPlayer and var.curPlayerIndex and var.curPlayerIndex==item.tag then
			item:getWidgetByName("imgSelected"):setVisible(true)
			var.curPlayer=item
		end
		item:setTouchEnabled(true)
		item:getWidgetByName("labName"):setString(itemData.name)
		item:getWidgetByName("labLevel"):setString(itemData.level)
		item:getWidgetByName("labJob"):setString(jobNames[itemData.job-99])
		item:getWidgetByName("labGuild"):setString(itemData.guild)
		item.name=itemData.name
		GUIFocusPoint.addUIPoint(item,prsItemClick)
	end

	local playerList = var.xmlPanel:getWidgetByName("playerList")
	playerList:reloadData(#nearPlayers,updateNearbyPlayerList):setSliderVisible(false)
end

--获取附近玩家
function ContainerGroup.getNearPlayers()
	local result={}
	local nearbyP = NetCC:getNearGhost(GameConst.GHOST_PLAYER)
	for i = 1,#nearbyP do
		local player = CCGhostManager:getPixesGhostByID(nearbyP[i])
		if player then
			local pName = player:NetAttr(GameConst.net_name)
			local pID = player:NetAttr(GameConst.net_id)
			local nearByGroupInfo = GameSocket.nearByGroupInfo[pID]
			if not nearByGroupInfo then
				local param = {	name = pName,}
				ContainerGroup.setParam(player, param)
				table.insert(result, param)
			end
		end
	end
	return result
end

--取每个附近玩家的属性
function ContainerGroup.setParam(player, param)
	param.job = player:NetAttr(GameConst.net_job)
	param.level=player:NetAttr(GameConst.net_level)
	param.power = player:NetAttr(GameConst.net_fight_point)
	param.gender = player:NetAttr(GameConst.net_gender)
	param.state = player:NetAttr(GameConst.net_state)
	param.guild = player:NetAttr(GameConst.net_guild_name) or "暂无公会"
end

-----------------------------------------我的好友-----------------------------------------------
function ContainerGroup.initMyFriend()
	local friendData = ContainerGroup.getMyFriends()

	local function prsItemClick(sender)
		if var.curFriend then
			var.curFriend:getWidgetByName("imgSelected"):setVisible(false)	
		end
		sender:getWidgetByName("imgSelected"):setVisible(true)
		var.curFriend = sender
		var.curFriendIndex=sender.tag
		-- var.xmlOperate= GUIFloatTips.showOperateTips(var.xmlOperate,var.xmlPanel,nil)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = sender.name})
	end
	local function updateFriendList(item)
		local itemData = friendData[item.tag]
		item:getWidgetByName("imgSelected"):setVisible(false)
		if var.curFriend and var.curFriendIndex and var.curFriendIndex==item.tag then
			item:getWidgetByName("imgSelected"):setVisible(true)
			var.curFriend=item
		end
		item:setTouchEnabled(true)
		item:getWidgetByName("labName"):setString(itemData.name)
		item:getWidgetByName("labLevel"):setString(itemData.level)
		item:getWidgetByName("labJob"):setString(jobNames[itemData.job-99])
		if itemData.guild=="" then
			item:getWidgetByName("labGuild"):setString("暂无公会")
		else
			item:getWidgetByName("labGuild"):setString(itemData.guild)
		end
		item.name=itemData.name
		GUIFocusPoint.addUIPoint(item,prsItemClick)
	end
	
	local friendList = var.xmlPanel:getWidgetByName("playerList")
	friendList:reloadData(#friendData,updateFriendList):setSliderVisible(false)
end

--获得好友数据
function ContainerGroup.getMyFriends()
	local result = {}
	for _,v in pairs(GameSocket.mFriends) do
		table.insert(result,v)
	end
	return result
end

--好友信息改变
function ContainerGroup.myFriendChange(event)
	if var.curTab and var.curTab.index==4 then
		ContainerGroup.initMyFriend()
	end
end

return ContainerGroup