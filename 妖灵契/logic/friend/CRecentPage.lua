local CRecentPage = class("CRecentPage", CPageBase)

function CRecentPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
	self.m_MaxItem = 30
end

function CRecentPage.OnInitPage(self)
	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CRecentItem)
	self.m_ItemClone:SetActive(false)
	
	self.m_AddFriendBtn = self:NewUI(3, CButton)
	self.m_TeamerBtn = self:NewUI(4, CButton)
	self.m_BlackFriendBtn = self:NewUI(5, CButton)
	
	self.m_AddFriendBtn:AddUIEvent("click", callback(self, "AddFriend"))
	self.m_TeamerBtn:AddUIEvent("click", callback(self, "GetTeamer"))
	self.m_BlackFriendBtn:AddUIEvent("click", callback(self, "GetBalckFriend"))
	
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	self:InitContent()
end

function CRecentPage.InitContent(self)
	self.m_RecentList = table.slice(g_FriendCtrl.m_Friend["recent"], 1, 20)
	for i = 1, 20 do
		local pid = self.m_RecentList[i]
		if pid then
			local oItem = self:CreateItem(pid)
			if oItem then
				self.m_ItemGrid:AddChild(oItem)
			end
		end
	end
	self.m_ItemGrid:Reposition()
end

function CRecentPage.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Update then
		self:UpdateFrdItem(oCtrl.m_EventData)
	end
end

function CRecentPage.Sort(a, b)
	return a.m_ID < b.m_ID
end

function CRecentPage.RefreshNotify(self, pid)
	if not self:IsInit() then
		return
	end
	local iAmount = g_TalkCtrl:GetNotify(pid)
	if iAmount then
		self:TopItem(pid)
	else
		self:DelNotify(pid)
	end
end

function CRecentPage.UpdateFrdItem(self, frdList)
	if not frdList then
		return
	end
	local itemList = self.m_ItemGrid:GetChildList()
	for k, oItem in pairs(itemList) do
		if oItem and table.index(frdList, oItem.m_ID) then
			oItem:SetPlayer(oItem.m_ID)
		end
	end
end

function CRecentPage.TopItem(self, pid)
	local list = self.m_ItemGrid:GetChildList()
	local removeItem = nil
	for k, oItem in pairs(list) do
		if oItem.m_ID == pid then
			removeItem = oItem
		end
	end
	
	if removeItem then
		self.m_ItemGrid:RemoveChild(removeItem)
	end
	self:AddItem(pid)
end

function CRecentPage.AddItem(self, pid)
	local list = self.m_ItemGrid:GetChildList()
	if #list > self.m_MaxItem then
		local delItem = self.m_ItemGrid:GetChild(#list)
		self.m_ItemGrid:RemoveChild(delItem)
	end

	local oItem = self:CreateItem(pid)
	self.m_ItemGrid:AddChild(oItem)
	oItem:SetAsFirstSibling()
end

function CRecentPage.CreateItem(self, pid)
	local oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem:SetPlayer(pid)
	oItem:SetMsgAmount(g_TalkCtrl:GetNotify(pid))
	oItem.m_ID = pid
	oItem.m_Button:AddUIEvent("click", callback(self, "ShowTalk", pid))
	return oItem
end

function  CRecentPage.DelNotify(self, pid)
	local list = self.m_ItemGrid:GetChildList()
	for k, oItem in pairs(list) do
		if oItem.m_ID == pid then
			oItem:SetMsgAmount(0)
		end
	end
end

function CRecentPage.ShowTalk(self, v)
	self.m_ParentView:ShowTalk(v)
end

function CRecentPage.AddFriend(self)
	CFindFrdView:ShowView()
end

function CRecentPage.GetTeamer(self)
end

function CRecentPage.GetBalckFriend(self)
end

return CRecentPage