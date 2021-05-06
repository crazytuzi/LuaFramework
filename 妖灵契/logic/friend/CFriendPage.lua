local CFriendPage = class("CFriendPage", CPageBase)

function CFriendPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CFriendPage.OnInitPage(self)
	self.m_Table = self:NewUI(1, CTable)
	self.m_FrdItem = self:NewUI(2, CFriendItem)
	self.m_ApplyAmount = self:NewUI(4, CLabel)
	self.m_GroupItem = self:NewUI(7, CFrdGroupItem)
	self.m_TalkPart = self:NewUI(8, CTalkPart)
	self.m_DefaultBox = self:NewUI(9, CBox)
	self.m_TalkPart:SetActive(false)
	self.m_DefaultBox:SetActive(true)
	self.m_AddFrdBtn = self:NewUI(10, CButton)
	self.m_ApplyFrdBtn = self:NewUI(11, CButton)
	self.m_EditInfoBtn = self:NewUI(12, CButton)
	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTalkEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	self:InitContent()
end

function CFriendPage.InitContent(self)
	self:InitTable()
	self.m_GroupItem:SetActive(false)
	self.m_FrdItem:SetActive(false)
	self.m_ApplyFrdBtn:AddUIEvent("click", callback(self, "ShowApplyView"))
	self.m_EditInfoBtn:AddUIEvent("click", callback(self, "OnEditInfo"))
	self.m_AddFrdBtn:AddUIEvent("click", callback(self, "OnFindFriend"))
	self:UpadteApplyAmount()
end

CFriendPage.GroupData = {
	{key = "friend", name = "我的好友"},
	{key = "recent", name = "最近联系人"},
	{key = "teamer", name = "最近队友"},
	{key = "black", name = "黑名单"},
}

function CFriendPage.InitTable(self)
	local t = CFriendPage.GroupData
	self.m_GroupDict = {}
	for _, groupdata in pairs(t) do
		local groupitem = self:CreateFrdGroupItem(groupdata)
		self.m_GroupDict[groupdata["key"]] = groupitem
		self.m_Table:AddChild(groupitem)
	end
	if g_TalkCtrl:GetTotalNotify() > 0 then
		self.m_GroupDict["recent"]:SetMsgAmount(1)
	end
	self.m_Table:Reposition()
end

function CFriendPage.OnTalkEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Talk.Event.AddNotify then
		self:RefreshNotify(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Talk.Event.DelNotify then
		self:RefreshNotify(oCtrl.m_EventData)
	end
end

function CFriendPage.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateApply then
		self:UpadteApplyAmount()
	
	elseif oCtrl.m_EventID == define.Friend.Event.Update then
		self:UpdateFriend(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.Add then
		self:OnAddFriend(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.Del then
		self:OnAddFriend(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.AddRecent then
		self:OnAddRecent(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.DelRecent then
		self:OnAddRecent(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.AddBlack then
		self:OnAddBlack(oCtrl.m_EventData)
		
	elseif oCtrl.m_EventID == define.Friend.Event.DelBlack then
		self:OnAddBlack(oCtrl.m_EventData)
	end
end

function CFriendPage.GetFrdData(self, key)
	if key == "friend" then
		return self:GetMyFriend()
	elseif key == "teamer" then
		return g_FriendCtrl:GetTeamerFriend()
	elseif key == "recent" then
		return self:GetMyRecent()
	elseif key == "black" then
		return g_FriendCtrl:GetBlackList()
	end
	return {}
end

function CFriendPage.GetMyFriend(self)
	local pidList = {}
	for _, pid in ipairs(g_FriendCtrl:GetMyFriend()) do
		table.insert(pidList, pid)
	end
	table.sort(pidList, g_FriendCtrl.Sort)
	return pidList
end

function CFriendPage.GetMyRecent(self)
	local pidList = {}
	local offlineList = {}
	for _, pid in ipairs(g_FriendCtrl:GetRecentFriend()) do
		if g_FriendCtrl:GetOnlineState(pid) then
			table.insert(pidList, pid)
		else
			table.insert(offlineList, pid)
		end
	end
	table.extend(pidList, offlineList)
	return pidList
end

function CFriendPage.OnExpand(self, item)
	item:SwitchExpand()
	if item.m_IsExpand then
		self:ExpandItem(item)
	else
		self:PullItem(item)
	end
end

function CFriendPage.ExpandItem(self, item)
	item.m_IsExpand = true
	item:SetMsgAmount(0)
	local index = item:GetSiblingIndex()
	local data = self:GetFrdData(item.m_Key)
	for i, pid in pairs(data) do
		local itemobj = self:CreateFrdItem(pid)
		itemobj:SetGroup(self.m_Table:GetInstanceID())
		itemobj.m_GroupName = item.m_Key
		self.m_Table:AddChild(itemobj, index+i)
	end
end

function CFriendPage.PullItem(self, item)
	item.m_IsExpand = false
	local removelist = {}
	for _, itemobj in pairs(self.m_Table:GetChildList()) do
		if itemobj.m_GroupName == item.m_Key then
			table.insert(removelist, itemobj)
		end
	end
	for _, obj in pairs(removelist) do
		self.m_Table:RemoveChild(obj)
	end
end

function CFriendPage.CreateFrdGroupItem(self, groupdata)
	local groupitem = self.m_GroupItem:Clone()
	groupitem:SetName(groupdata["name"])
	local amount = #self:GetFrdData(groupdata["key"])
	groupitem:AddUIEvent("click", callback(self, "OnExpand"))
	groupitem.m_Key = groupdata["key"]
	self:UpdateOnlineAmount(groupitem)
	return groupitem
end

function CFriendPage.CreateFrdItem(self, pid)
	local itemobj = self.m_FrdItem:Clone()
	itemobj:SetActive(true)
	itemobj:SetPlayer(pid)
	itemobj.m_Button:AddUIEvent("click", callback(self, "OnOpenTalk", pid))
	return itemobj
end

function CFriendPage.OnAddFriend(self, pidList)
	local groupitem = self.m_GroupDict["friend"]
	local amount = #self:GetFrdData("friend")
	self:UpdateOnlineAmount(groupitem)
	if groupitem.m_IsExpand then
		self:PullItem(groupitem)
		self:ExpandItem(groupitem)
	end
end

function CFriendPage.OnAddRecent(self, pidList)
	local groupitem = self.m_GroupDict["recent"]
	local amount = #self:GetFrdData("recent")
	self:UpdateOnlineAmount(groupitem)
	if groupitem.m_IsExpand then
		self:PullItem(groupitem)
		self:ExpandItem(groupitem)
	end
end

function CFriendPage.OnAddBlack(self, pidList)
	local groupitem = self.m_GroupDict["black"]
	local amount = #self:GetFrdData("black")
	self:UpdateOnlineAmount(groupitem)
	if groupitem.m_IsExpand then
		self:PullItem(groupitem)
		self:ExpandItem(groupitem)
	end
end

function CFriendPage.UpdateFriend(self, frdList)
	local groupList = {}
	for _, itemobj in ipairs(self.m_Table:GetChildList()) do
		if table.index(frdList, itemobj.m_ID) then
			itemobj:SetPlayer(itemobj.m_ID)
			local groupitem = self.m_GroupDict[itemobj.m_GroupName]
			if not table.index(groupList, groupitem) then
				table.insert(groupList, groupitem)
			end
		end
	end
	self:ResortGroupItem(groupList)
end

--重新排序分组, 不新增itemobj，重新绑定itemobj的pid
function CFriendPage.ResortGroupItem(self, groupList)
	for _, groupitem in ipairs(groupList) do
		local list = self:GetFrdData(groupitem.m_Key)
		local total = 0
		local online = 0
		local index = self.m_Table:GetChildIdx(groupitem.m_Transform)
		for i, pid in ipairs(list) do
			local frdobj = g_FriendCtrl:GetFriend(pid)
			if frdobj then
				total = total + 1
				if g_FriendCtrl:GetOnlineState(pid) then
					online = online + 1
				end
			end
			local itemobj = self.m_Table:GetChild(index+i)
			itemobj:SetPlayer(pid)
			itemobj.m_Button:AddUIEvent("click", callback(self, "OnOpenTalk", pid))
		end
		groupitem:SetAmount(online, total)
	end
end

function CFriendPage.UpdateOnlineAmount(self, itemobj)
	if not itemobj then
		return
	end
	local list = self:GetFrdData(itemobj.m_Key)
	local total = 0
	local online = 0
	for _, pid in ipairs(list) do
		local frdobj = g_FriendCtrl:GetFriend(pid)
		if frdobj then
			total = total + 1
			if g_FriendCtrl:GetOnlineState(pid) then
				online = online + 1
			end
		end
	end
	itemobj:SetAmount(online, total)
end

function CFriendPage.RefreshNotify(self, pid)
	local recentitem = self.m_GroupDict["recent"]
	if recentitem.m_IsExpand then
		for _, itemobj in ipairs(self.m_Table:GetChildList()) do
			if itemobj.m_GroupName == "recent" and itemobj.m_ID == pid then
				itemobj:SetMsgAmount(g_TalkCtrl:GetNotify(pid))
				return
			end
		end
	else
		if g_TalkCtrl:GetTotalNotify() > 0 then
			recentitem:SetMsgAmount(1)
		else
			recentitem:SetMsgAmount(0)
		end
	end
end

function CFriendPage.SetOpenTalkMsg(self, sMsg)
	self.m_OpenTalkMsg = sMsg
end

function CFriendPage.OnOpenTalk(self, pid)
	self.m_DefaultBox:SetActive(false)
	self.m_TalkPart:SetActive(true)
	self.m_TalkPart:SetPlayer(pid)
	self.m_DefaultBox:SetActive(false)
	if self.m_OpenTalkMsg ~= nil then
		g_TalkCtrl:SendChat(pid, self.m_OpenTalkMsg)
		self.m_TalkPart:AddSelfMsg(self.m_OpenTalkMsg)
		self.m_OpenTalkMsg = nil
	end
end

function CFriendPage.ChooseItem(self, pid)
	local groupitem = self.m_GroupDict["recent"]

	if not groupitem.m_IsExpand then
		self:ExpandItem(groupitem)
	end
	for _, itemobj in ipairs(self.m_Table:GetChildList()) do
		printc(itemobj.m_ID)
		if itemobj.m_GroupName == "recent" and itemobj.m_ID == pid then
			itemobj.m_Button:SetSelected(true)
			return
		end
	end
end

function CFriendPage.UpadteApplyAmount(self)
	local iAmount = g_FriendCtrl:GetApplyAmount()
	if iAmount > 0 then
		self.m_ApplyAmount:SetActive(true)
		self.m_ApplyAmount:SetText(iAmount)
	else
		self.m_ApplyAmount:SetActive(false)
	end
end

function CFriendPage.OnEditInfo(self)
	netfriend.C2GSTakeDocunment(g_AttrCtrl.pid)
end

function CFriendPage.ShowApplyView(self)
	CFriendApplyView:ShowView()	
end

function CFriendPage.OnFindFriend(self)
	CFindFrdView:ShowView()
end

function CFriendPage.SaveMsgRecord(self)
	self.m_TalkPart:DefaultSave()
end

function CFriendPage.ClearOpenTalkMsg(self)
	self.m_OpenTalkMsg = nil
end

return CFriendPage