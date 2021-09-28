FriendPanel = BaseClass(LuaUI)
function FriendPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Gay","FriendPanel");

	self.tabListCtrl = self.ui:GetController("tabListCtrl")
	self.tabIsNull = self.ui:GetController("tabIsNull")
	self.friendList = self.ui:GetChild("friendList")
	self.tab1_mosheng = self.ui:GetChild("tab1_mosheng")
	self.tab0_friend = self.ui:GetChild("tab0_friend")
	self.tab2_black = self.ui:GetChild("tab2_black")
	self.icon_headIcon = self.ui:GetChild("icon_headIcon")
	self.txt_playerName = self.ui:GetChild("txt_playerName")
	self.txt_qianmimg = self.ui:GetChild("txt_qianmimg")
	self.icon_haogandu = self.ui:GetChild("icon_haogandu")
	self.num_haogandu = self.ui:GetChild("num_haogandu")
	self.txt_teamExe = self.ui:GetChild("txt_teamExe")
	self.bg_noFri = self.ui:GetChild("bg_noFri")
	self.bg_nofriendTxt = self.ui:GetChild("bg_nofriendTxt")
	self.nullText = self.ui:GetChild("nullText")
	self.listNum = self.ui:GetChild("listNum")
	self.btnAddFri = self.ui:GetChild("btnAddFri")
	self.btnBiaoqing = self.ui:GetChild("btnBiaoqing")
	self.btnYuyin = self.ui:GetChild("btnYuyin")
	self.btnSend = self.ui:GetChild("btnSend")
	self.textInput = self.ui:GetChild("textInput")
	self.privateContent = self.ui:GetChild("privateContent")
	self.playerKind1 = self.ui:GetChild("playerKind1")
	self.zhiyeName1 = self.ui:GetChild("zhiyeName1")
	self.addRedIcon = self.ui:GetChild("addRedIcon")
	self.redMosheng = self.ui:GetChild("redMosheng")
	self.redFriend = self.ui:GetChild("redFriend")

	self.inputTxt = self.textInput:GetChild("input")
	self.leftPoolMax = 50          --左聊天框对象池
	self.leftPoolItemList = {}

	self.rightPoolMax = 50         --右聊天框对象池
	self.rightPoolItemList = {}

	self.btnYuyin.visible = false
	self.redMosheng.visible = false
	self.redFriend.visible = false

	self.index = 1
	self.locationY = 0
	self.curListData = nil
	self.channelId = 0
	self.isOnline = true

	self.includeEquip = false
	self.replaceEuipStr = {}
	self.equipParams = {}
	self.tab1_mosheng.title = "[color=#2e3314]最近联系[/color]"
	self.tab0_friend.title = "[color=#ffffff]好友列表[/color]"
	self.tab2_black.title = "[color=#2e3314]黑名单[/color]"

	self.model = FriendModel:GetInstance()

	FriendController:GetInstance():C_ApplyMsgList()
	self:InitEvent()
	self:AddEvent()
	self.friendItems = {}
	self.recentItems = {}

	if self.model.isFriend then
		FriendController:GetInstance():C_FriendList(1)
		self:BtnTextColor(0)
	else
		self:BtnTextColor(1)
	end
	self.typeSelectPanel = nil

	self.addFriPanel = nil

	if not self.addFriPanel then
		self.addFriPanel = AddFriPanel.New()
		self.addFriPanel:SetXY(-147, -108)
		self.addFriPanel.ui.visible = false
		self.ui:AddChild(self.addFriPanel.ui)
	end
	self:RefreshRedTab()
end

function FriendPanel:InitEvent()
	self.btnAddFri.onClick:Add(function ()
		--local addFriPanel = AddFriPanel.New()
		--UIMgr.ShowCenterPopup(addFriPanel, function()  end)                 
		--GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.social , state = false})  --关闭红点
		if self.addFriPanel then self.addFriPanel.ui.visible = true end
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end)
	self.tabListCtrl.onChanged:Add(function ()        --切换好友列表、黑名单、最近联系人列表
		for i,v in ipairs(self.friendItems) do
			v:Destroy()
		end
		self.friendItems = {}
		for i,v in ipairs(self.recentItems) do
			v:Destroy()
		end
		self.channelId = 0
		self.recentItems = {}
		self:ClearContent()
		self:RefreshRedTab()
		--[[if not self.friendList then
			self.tabIsNull.selectedIndex = 1
		else
			self.tabIsNull.selectedIndex = 0
		end]]--
	end)
	self.tab0_friend.onChanged:Add(function()         --好友列表分页按钮
		self.model.selectInd = 1
		self:BtnTextColor(0)
		FriendController:GetInstance():C_FriendList(1)
		self:LoadFriendList()
	end)
	self.tab1_mosheng.onChanged:Add(function()         --陌生人分页按钮
		self.model.selectInd = 1
		self:BtnTextColor(1)
		self:LoadContactList()
	end)
	self.tab2_black.onChanged:Add(function()         --黑名单分页按钮
		self.model.selectInd = 1
		self:BtnTextColor(2)
	end)
	self.friendList.onClickItem:Add(function()      --glist点击选中事件********
		self:OnClickFriListItem()
		self:GetPrivateChatData()
		self:LoadChatList()
		self.model:DispatchEvent(FriendConst.CloseRedItem, self.channelId)
		for i,v in ipairs(self.model.redList) do
			if self.channelId == v then
				table.remove(self.model.redList, i)
				break
			end
		end
		for i,v in ipairs(self.model.redListMo) do
			if self.channelId == v then
				table.remove(self.model.redListMo, i)
				break
			end
		end
		self:RefreshRedTab()
	end)
-------------------------------------------私聊-----------------------
	self.btnBiaoqing.onClick:Add(function ()                   --聊天表情按钮
		self:SelectPanelToggle()
	end)
	self.btnYuyin.onClick:Add(function ()                   --聊天语音按钮
		
	end)
	self.btnSend.onClick:Add(function ()                   --聊天发送按钮-
		self:SendMsg(self.channelId)
	end)
end

function FriendPanel:AddEvent()
	self.handler0 = self.model:AddEventListener(FriendConst.FRIENDLIST_LOAD, function()
		for i,v in ipairs(self.recentItems) do
			v:Destroy()
		end
		self.recentItems = {}
		self:LoadFriendList()
	end)
	self.handler1 = self.model:AddEventListener(FriendConst.ADDFRIEND_TRUE, function()
		if self.tabListCtrl.selectedIndex == 0 then                          ----------------------------------------LSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
			self:LoadFriendList()
		elseif self.tabListCtrl.selectedIndex == 1 then
			self.channelId = 0
			self:ClearContent()
			self.model.selectInd = 1
			self:LoadContactList()
			if self.friendList.numChildren > 0 then
				self.tabIsNull.selectedIndex = 1
			else
				self.tabIsNull.selectedIndex = 0
				self.nullText.text = StringFormat("暂无聊天对象！")
			end
		end
		self:RefreshRedTab()
	end)
	self.handler2 = self.model:AddEventListener(FriendConst.DELETEFRIEND_TRUE, function()
		if self.tabListCtrl.selectedIndex == 0 then
			self.channelId = 0
			self:ClearContent()
			self:LoadFriendList()
		end
		self:RefreshRedTab()
	end)
	self.handler3 = self.model:AddEventListener(FriendConst.CURFRIITEM_INFO, function(curFriInfo)
		self:LoadCurInfo(curFriInfo)
	end)

	self.handler4 = self.model:AddEventListener(FriendConst.RECENTCHAT, function()
		self:LoadContactList()
	end)
----------------------------聊天事件---------------------
	self.receiveHandler = self.model:AddEventListener(FriendConst.ReceivePriMsg, function (data)
		
		if self.tabListCtrl.selectedIndex == 1 then
			local mainPlayerId = SceneModel:GetInstance():GetMainPlayer().playerId
			if mainPlayerId then
				if data.sendPlayerId == self.channelId or data.sendPlayerId == mainPlayerId then
					self:GetPrivateChatData()
					self:LoadChatList()
				else
					self:ClearContent()
					self:LoadContactList()
				end
			end
		else
			self:OnReceiveMsg(data)
		end
	end)
	self.selectFaceHandler = self.model:AddEventListener(FriendConst.SelectFace, function (data) self:OnSelectFace(data) end)
	self.selectEquipHandler = self.model:AddEventListener(FriendConst.SelectEquip, function (data) self:OnSelectEquip(data) end)
	--self.selectHistoryHandler = self.model:AddEventListener(FriendConst.SelectHistory, function (data) self:OnSelectHistory(data) end)
	--red
	self.applyRedHandler = self.model:AddEventListener(FriendConst.ApplyRed, function()
		self.addRedIcon.visible = true
	end)
	self.closeRedHandler = self.model:AddEventListener(FriendConst.CloseApplyRed, function() --关闭红点
		self.addRedIcon.visible = false
	end)
	self.chatRedHandler = self.model:AddEventListener(FriendConst.PrivateChatRed, function(data)       --私聊红点
		
		--self:PriChatRed(data)
		self:RefreshRedTab()
	end)
end

function FriendPanel:UpdateList()                     --切换好友、黑名单、最近联系列表选项对应刷新列表内容  
	local idx = self.tabListCtrl.selectedIndex        --0 好友列表  1 最近联系  2 黑名单

end

function FriendPanel:RefreshRedTab()
	if #self.model.redList > 0 then
		self.redFriend.visible = true
	else
		self.redFriend.visible = false
	end
	if #self.model.redListMo > 0 then
		self.redMosheng.visible = true
	else
		self.redMosheng.visible = false
	end
end

function FriendPanel:PriChatRed(data)
	if (not self.redMosheng) or (not self.redFriend) then return end
	local isFriends = false
	for i,v in ipairs(self.model.recentChatList) do
		if data.sendPlayerId == v.sendPlayerId then
			isFriends = true
		end
	end
	if data.sendPlayerId ~= SceneModel:GetInstance():GetMainPlayer().playerId then
		if isFriends then
			self.redMosheng.visible = true
			self.redFriend.visible = false
		else
			self.redMosheng.visible = false
			self.redFriend.visible = true
		end
	end
end

function FriendPanel:BtnTextColor(i)
	if i == 0 then
		self.tab1_mosheng.title = "[color=#2e3341]陌生人[/color]"
		self.tab0_friend.title = "[color=#ffffff]好友列表[/color]"
		self.tab2_black.title = "[color=#2e3341]黑名单[/color]"
	elseif i == 1 then
		self.tab1_mosheng.title = "[color=#ffffff]陌生人[/color]"
		self.tab0_friend.title = "[color=#2e3341]好友列表[/color]"
		self.tab2_black.title = "[color=#2e3341]黑名单[/color]"
	elseif i == 2 then
		self.tab1_mosheng.title = "[color=#2e3341]陌生人[/color]"
		self.tab0_friend.title = "[color=#2e3341]好友列表[/color]"
		self.tab2_black.title = "[color=#ffffff]黑名单[/color]"
	end
end

function FriendPanel:LoadFriendList()            --加载好友列表
	for i,v in ipairs(self.friendItems) do
		v:Destroy()
	end
	self.friendItems = {}
	local friendTab = self.model.friendList
	if #friendTab > 50 then
		self.listNum.text = "50/50"
	else
		self.listNum.text = StringFormat("{0}/50", #friendTab)      
	end
	for i,v in ipairs(friendTab) do
		local itemObj = FriendItem.New()
		table.insert(self.friendItems, itemObj)
		self.friendList:AddChild(itemObj.ui)
		itemObj.playerId = v.playerId
		itemObj.headIcon.icon = "Icon/Head/r1"..v.career            --玩家头像
		itemObj.headIcon.title = v.level
		itemObj.playerName.text = v.playerName	
		
		local isRedFri = false
		for i,v in ipairs(self.model.redList) do
			if itemObj.playerId == v then
				itemObj.redIcon.visible = true
				isRedFri = true
			end
		end

		if toLong(v.exitTime) == 0 then
			itemObj.offlineTime.text = "在线"
			itemObj.offlineTime.color = newColorByString("00620e")        --改变文本颜色
		else
			itemObj.offlineTime.text = self:GetOfflineTime(toLong(v.exitTime))
			itemObj.offlineTime.color = newColorByString("54595e")        --改变文本颜色
		end
		itemObj.playerKind.url = "Icon/Head/career_0"..v.career           --职业图标
		itemObj.zhiyeName.text = GetCfgData("newroleDefaultvalue"):Get(v.career).careerName
		
		--查看更多操作按钮=====================
		itemObj.btn_lookInfo.onClick:Add(function ()        
			local lookInfoPanel = LookInfoPanel.New()
			UIMgr.ShowCenterPopup(lookInfoPanel, function()  end)     --UIMGR弹窗方法
			lookInfoPanel.headIcon.icon = "Icon/Head/r1"..v.career
			lookInfoPanel.headIcon.title = v.level
			lookInfoPanel.txt_playerName.text = v.playerName
			if v.familyName and string.len(v.familyName) > 0 then
				lookInfoPanel.txt_family.text = StringFormat("家族：{0}",v.familyName)
			else
				lookInfoPanel.txt_family.text = "家族：暂无"
			end
			lookInfoPanel.btn_info.onClick:Add(function()             --查看他人信息按钮
				GlobalDispatcher:DispatchEvent(EventName.CheckOtherPlayerInfo, v.playerId)
			end)
			lookInfoPanel.btn_Pk.onClick:Add(function()               --PK按钮

			end)
			lookInfoPanel.btn_team.onClick:Add(function()             --组队邀请按钮
				if SceneModel:GetInstance():IsInNewBeeScene() then
					UIMgr.Win_FloatTip("通关彼岸村后可使用")
					return
				end
				ZDCtrl:GetInstance():C_Invite(v.playerId)
				UIMgr.HidePopup(lookInfoPanel.ui)
			end)
			lookInfoPanel.btn_family.onClick:Add(function()           --家族邀请按钮
				FamilyCtrl:GetInstance():C_InviteJoinFamily(v.playerId)
				UIMgr.HidePopup(lookInfoPanel.ui)
			end)
			lookInfoPanel.btn_black.onClick:Add(function()            --拉黑按钮
				UIMgr.HidePopup(lookInfoPanel.ui)
			end)
			lookInfoPanel.btn_delete.onClick:Add(function()           --删除好友按钮
				FriendController:GetInstance():C_DeleteFriend(v.playerId)
				UIMgr.HidePopup(lookInfoPanel.ui)
				self:ClearContent()
			end)
		end)
	end
	if #friendTab > 0 then
		self.tabIsNull.selectedIndex = 1
		self:InitFriListSelect(0, self.model.selectInd)  
		if self.friendList.numChildren >= self.model.selectInd then
			self.friendList:ScrollToView(self.model.selectInd-1) 
		end
	else
		self.tabIsNull.selectedIndex = 0
		self.nullText.text = StringFormat("你的好友列表空空如也，赶紧去结交几个好友吧！")
	end
	self:RefreshRedTab()
end

function FriendPanel:LoadContactList()          --加载陌生人
	for i,v in ipairs(self.recentItems) do
		v:Destroy()
	end
	self.recentItems = {}
 	local recentChatTab = self.model.recentChatList
 	for i,v in ipairs(recentChatTab) do
 		if v.sendPlayerCareer then --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			local itemObj = FriendItem.New()
			table.insert(self.recentItems, itemObj)
			self.friendList:AddChild(itemObj.ui)
			self.listNum.text = StringFormat("{0}/50", #recentChatTab)
			itemObj.playerId = v.sendPlayerId
			itemObj.headIcon.icon = "Icon/Head/r1"..v.sendPlayerCareer
			itemObj.headIcon.title = v.sendPlayerLevel
			itemObj.playerName.text = v.sendPlayerName
			itemObj.offlineTime.text = " "
			itemObj.playerKind.url = "Icon/Head/career_0"..v.sendPlayerCareer
			itemObj.zhiyeName.text = GetCfgData("newroleDefaultvalue"):Get(v.sendPlayerCareer).careerName

			local isRedMo = false
			for i,v in ipairs(self.model.redListMo) do
				if itemObj.playerId == v then
					itemObj.redIcon.visible = true
					isRedMo = true
				end
			end

			--查看更多操作按钮=====================
			itemObj.btn_lookInfo.onClick:Add(function ()        
				local lookInfoPanel = LookInfoPanel.New()
				UIMgr.ShowCenterPopup(lookInfoPanel, function()  end)
				lookInfoPanel.headIcon.icon = "Icon/Head/r1"..v.sendPlayerCareer
				lookInfoPanel.headIcon.title = v.sendPlayerLevel
				lookInfoPanel.txt_playerName.text = v.sendPlayerName
				if v.familyName and string.len(v.familyName) > 0 then
					lookInfoPanel.txt_family.text = StringFormat("家族：{0}",v.familyName)
				else
					lookInfoPanel.txt_family.text = "家族：暂无"
				end
				lookInfoPanel.btn_delete.title = "添加好友"
				lookInfoPanel.btn_info.onClick:Add(function()             --查看他人信息按钮
					GlobalDispatcher:DispatchEvent(EventName.CheckOtherPlayerInfo, v.sendPlayerId)
				end)
				lookInfoPanel.btn_Pk.onClick:Add(function()               --PK按钮
				    lsb("切磋邀请")

				end)
				lookInfoPanel.btn_team.onClick:Add(function()             --组队邀请按钮
					if SceneModel:GetInstance():IsInNewBeeScene() then
						UIMgr.Win_FloatTip("通关彼岸村后可使用")
						return
					end
					ZDCtrl:GetInstance():C_Invite(v.sendPlayerId)
					UIMgr.HidePopup(lookInfoPanel.ui)
				end)

				lookInfoPanel.btn_family.visible = false

				lookInfoPanel.btn_black.onClick:Add(function()            --拉黑按钮
					lsb("发送拉黑好友请求")
					UIMgr.HidePopup(lookInfoPanel.ui)
				end)
				lookInfoPanel.btn_delete.onClick:Add(function()           --删除好友按钮改为添加好友功能++=
					FriendController:GetInstance():C_ApplyAddFriend(v.sendPlayerId)
					UIMgr.HidePopup(lookInfoPanel.ui)
					local str = self.model:GetTips()
					Message:GetInstance():TipsMsg(str)
				end)
			end)
		end
	end                             --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	if #recentChatTab > 0 then
		self.tabIsNull.selectedIndex = 1
		self:InitFriListSelect(1, self.model.selectInd)
		if self.friendList.numChildren >= self.model.selectInd then
			self.friendList:ScrollToView(self.model.selectInd-1)  
		end
	else
		self.tabIsNull.selectedIndex = 0
		self.nullText.text = StringFormat("暂无聊天对象！")
	end
	self:RefreshRedTab()
end 

--[[function FriendPanel:OnFriItemClickHandler()
	local data = {}
	data.playerId = self.data.playerId
	data.funcIds = {PlayerFunBtn.Type.AddFriend, PlayerFunBtn.Type.Chat, PlayerFunBtn.Type.InviteTeam, PlayerFunBtn.Type.CheckPlayerInfo}
	GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
end]]--

function FriendPanel:GetPrivateChatData()
	self.curListData = self.model:GetChatList(SceneModel:GetInstance():GetMainPlayer().playerId ,self.channelId)
end

function FriendPanel:OnClickFriListItem()             --点击每个好友列表的好友item触发
	local curFriInfo = self.friendItems[self.friendList.selectedIndex+1] or self.recentItems[self.friendList.selectedIndex+1]
	if not curFriInfo then return end
	self.model:DispatchEvent(FriendConst.CURFRIITEM_INFO , curFriInfo)
	self:ClearContent()
	self.channelId = curFriInfo.playerId             --当前玩家对应的私聊频道ID
	if curFriInfo.offlineTime.text ~= "在线" then
		self.isOnline = false
	else
		self.isOnline = true
	end
	self.index = 1
	self.locationY = 0

end

function FriendPanel:InitFriListSelect(idx, selectInd)              --初始选中好友列表第一个好友item信息
	self.friendList.selectedIndex = selectInd-1
	local curFriInfo = self.friendItems[selectInd] or self.recentItems[selectInd]
	if not curFriInfo then return end
	self.model:DispatchEvent(FriendConst.CURFRIITEM_INFO , curFriInfo)
	self.channelId = curFriInfo.playerId             --当前玩家对应的私聊频道ID
	if curFriInfo.offlineTime.text ~= "在线" then
		self.isOnline = false
	else
		self.isOnline = true
	end
	self:GetPrivateChatData()
	self.index = 1
	self.locationY = 0

	self:LoadChatList()
	local initFriInfo = nil
	if idx == 0 then
		initFriInfo = self.friendItems[selectInd]
	else
		initFriInfo = self.recentItems[selectInd]
	end
	if not initFriInfo then return end       --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	self.icon_headIcon.icon = initFriInfo.headIcon.icon
	self.icon_headIcon.title = initFriInfo.headIcon.title
	self.txt_playerName.text = initFriInfo.playerName.text
	self.txt_qianmimg.text = " "--------------------------------------签名需要添加++++++++++
	self.num_haogandu.text = " "         --------------------------------------好感度添加++++++++++++
	self.txt_teamExe.text = " "   --StringFormat("组队经验加成：{0}%", 20) --------------组队经验加成++++++++++
end

function FriendPanel:LoadCurInfo(v)
	if not v then return end
	self.icon_headIcon.icon = v.headIcon.icon
	self.icon_headIcon.title = v.headIcon.title
	self.txt_playerName.text = v.playerName.text
	self.playerKind1.url = v.playerKind.url
	self.zhiyeName1.text = v.zhiyeName.text
	self.txt_qianmimg.text = " "--------------------------------------签名需要添加++++++++++
	self.num_haogandu.text = " "         --------------------------------------好感度添加++++++++++++
	self.txt_teamExe.text = " "   --StringFormat("组队经验加成：{0}%", 20) --------------组队经验加成++++++++++
end

function FriendPanel:SendMsg(toplayerId)                               --发送消息
	if SceneModel:GetInstance():GetMainPlayer().level < 10 then
		Message:GetInstance():TipsMsg("达到10级就可以发言啦")
		return
	end

	if not self.isOnline and self.tabListCtrl.selectedIndex == 0 then
		Message:GetInstance():TipsMsg("好友不在线，离线消息最多保留十条")
	end

	if self.includeEquip then
		if self.inputTxt.text ~= "" then
			if string.utf8len(self.inputTxt.text) <= 48 then
				ChatNewController:GetInstance():C_Chat(4, self.inputTxt.text, toplayerId, self.equipParams)
			else
				Message:GetInstance():TipsMsg("超过96个字符限制")
			end
		else
			Message:GetInstance():TipsMsg("不能发送空消息")
		end
	else
		if self.inputTxt.text ~= "" then
			if string.utf8len(self.inputTxt.text) <= 48 then
				ChatNewController:GetInstance():C_Chat(4, self.inputTxt.text, toplayerId, nil)
				--self.model:AddHistoryInput(self.inputTxt.text)
			else
				Message:GetInstance():TipsMsg("超过96个字符限制")
			end
		else
			Message:GetInstance():TipsMsg("不能发送空消息")
		end
	end
	self.inputTxt.text = ""
	self.includeEquip = false
	self.equipParams = {}
	self.replaceEuipStr = {}
end

function FriendPanel:OnReceiveMsg(data)          --收到对方发送消息
	local chatVo = data
	self:AddMsg(chatVo.sendPlayerId, chatVo)                   

end

function FriendPanel:AddMsg(channelId, chatVo)
	local item = self:GetItem(chatVo)
	item.ui.y = self.locationY
	if item.type == 1 then
		item.ui.x = 46
	else
		item.ui.x = 0
	end
	if self.channelId == channelId or channelId == SceneModel:GetInstance():GetMainPlayer().playerId then
		self.privateContent:AddChild(item.ui)
		self.locationY = self.locationY + item:GetHeight()
		self.privateContent.scrollPane:ScrollBottom(true)
	end
end

function FriendPanel:LoadChatList()
	self:ClearContent()
	self.tabIsNull.selectedIndex = 1
	if self.curListData then
		for i,v in ipairs(self.curListData) do
			local item = self:GetItem(self.curListData[i])
			if item.type == 1 then
				item.ui.x = 46
			else
				item.ui.x = 0
			end
			item.ui.y = self.locationY
			self.privateContent:AddChild(item.ui)
			self.locationY = self.locationY + item:GetHeight()
			self.index = self.index + 1
			self.privateContent.scrollPane:ScrollBottom(false)
		end
	else
		self.locationY = 0
		self.curListData = nil
	end
end

function FriendPanel:ClearContent()               --清除聊天列表
	while self.privateContent.numChildren > 0 do
		self.privateContent:RemoveChildAt(0)
	end
	self.locationY = 0
end

function FriendPanel:GetItem(chatVo)
	local item = nil
	--lsb("-==========FriendPanel:GetItem(==========", chatVo)
	if self.model:IsMainPlayerSay(chatVo) then
		item = self:GetRightItemFromPool()
	else
		item = self:GetLeftItemFromPool()
	end
	item:SetData(chatVo)
	return item
end

function FriendPanel:GetLeftItemFromPool()
	for i = 1, #self.leftPoolItemList do
		if self.leftPoolItemList[i].ui.parent == nil then
			return self.leftPoolItemList[i]
		end
	end
	if #self.leftPoolItemList < self.leftPoolMax then
		local item = ContentLeftPrivate.New()
		table.insert(self.leftPoolItemList, item)
		return item
	end
	--self.privateContent:RemoveChildAt(0)
	return self:GetLeftItemFromPool()
end

function FriendPanel:DestoryLeftPool()
	for i = 1, #self.leftPoolItemList do
		self.leftPoolItemList[i]:Destroy()
	end
	self.poolItemList = nil
end

function FriendPanel:GetRightItemFromPool()
	for i = 1, #self.rightPoolItemList do
		if self.rightPoolItemList[i].ui.parent == nil then
			return self.rightPoolItemList[i]
		end
	end
	if #self.rightPoolItemList < self.rightPoolMax then
		local item = ContentRightPrivate.New()
		table.insert(self.rightPoolItemList, item)
		return item
	end
	--self.privateContent:RemoveChildAt(0)
	return self:GetRightItemFromPool()
end

function FriendPanel:DestoryRightPool()
	for i = 1, #self.rightPoolItemList do
		self.rightPoolItemList[i]:Destroy()
	end
	self.poolItemList = nil
end

function FriendPanel:SelectPanelToggle(forceHide)
	local closeFunc = function()
		UIMgr.HidePopup()
		self.typeSelectPanel = nil
	end
	if self.typeSelectPanel then
		closeFunc()
		return
	end
	self.typeSelectPanel = TypeSelectPanelPrivate.New()
	self.typeSelectPanel:ToShow()
	UIMgr.ShowPopup(self.typeSelectPanel, false, 0, -40, function()
		closeFunc()
	end)
end

function FriendPanel:OnSelectFace(data)         --选中 表情==================
	self:AppendTxt(data)
end

function FriendPanel:AppendTxt(str)
	self.inputTxt.text = self.inputTxt.text..str
end

function FriendPanel:OnSelectEquip(data)
	self.includeEquip = true
	self.inputTxt.text = self.inputTxt.text.."{"..#self.replaceEuipStr.."}"
	table.insert(self.replaceEuipStr, "["..data.name.."]")
	table.insert(self.equipParams, {ChatVo.ParamType.Equipment, SceneModel:GetInstance():GetMainPlayer().playerId, data.id, data.equipId})
end

function FriendPanel:OnSelectHistory(data)
	self.inputTxt.text = self.inputTxt.text..data
end

-- 布局UI
function FriendPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局	
end

function FriendPanel:GetOfflineTime(exitTime)
	local serverTime = TimeTool.GetCurTime()
	local offlineTime = (serverTime - exitTime)/1000
	local str = "";
	if offlineTime < 3600 then -- 小于1小时
		str = "离线";
	elseif offlineTime < 86400 then
		offlineTime = math.modf(offlineTime/3600);
		str = StringFormat("离线{0}小时",offlineTime)
	else
		offlineTime = math.modf(offlineTime/86400);
		str = StringFormat("离线{0}天",offlineTime)
	end
	return str
end

-- Dispose use FriendPanel obj:Destroy()
function FriendPanel:__delete()
	self.model.selectInd = 1
	if self.model then
		self.model:RemoveEventListener(self.handler0)
		self.model:RemoveEventListener(self.handler1)
		self.model:RemoveEventListener(self.handler2)
		self.model:RemoveEventListener(self.handler3)
		self.model:RemoveEventListener(self.handler4)
		self.model:RemoveEventListener(self.receiveHandler)
		self.model:RemoveEventListener(self.selectFaceHandler)
		self.model:RemoveEventListener(self.selectEquipHandler)
		self.model:RemoveEventListener(self.applyRedHandler)
		self.model:RemoveEventListener(self.closeRedHandler)
		self.model:RemoveEventListener(self.chatRedHandler)
		GlobalDispatcher:RemoveEventListener(self.gayChatHandler)
	end
	if self.friendItems then
		for i,v in ipairs(self.friendItems) do
			v:Destroy()
		end
		self.friendItems = nil
	end
	if self.recentItems then
		for i,v in ipairs(self.recentItems) do
			v:Destroy()
		end
		self.recentItems = nil
	end
	self:DestoryLeftPool()
	self:DestoryRightPool()

	self.equipParams = nil
	self.typeSelectPanel = nil

	if self.addFriPanel then
		self.addFriPanel:Destroy()
		self.addFriPanel = nil
	end
end