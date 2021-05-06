local CTeamerPage = class("CTeamerPage", CPageBase)

function CTeamerPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CTeamerPage.OnInitPage(self)
	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CTeamerItem)
	self.m_ItemClone:SetActive(false)
	
	self.m_AddFriendBtn = self:NewUI(3, CButton)
	self.m_TeamerBtn = self:NewUI(4, CButton)
	self.m_BlackFriendBtn = self:NewUI(5, CButton)
	
	self.m_AddFriendBtn:AddUIEvent("click", callback(self, "AddFriend"))
	self.m_TeamerBtn:SetGroup(self.m_ParentView:GetInstanceID())
	self.m_TeamerBtn:SetSelected(true)
	self.m_BlackFriendBtn:AddUIEvent("click", callback(self, "GetBalckFriend"))
	
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	
	self:InitContent()
end

function CTeamerPage.InitContent(self)
	self.m_TeamerList = g_FriendCtrl.m_Friend["teamer"]
	table.print(self.m_TeamerList)
	self.m_ItemGrid:Clear()
	for k, pid in pairs(self.m_TeamerList) do
		local frdobj =  g_FriendCtrl:GetFriend(pid)
		if frdobj then
			self:CreateItem(pid)
		end
	end
	self.m_ItemGrid:Reposition()
end

function CTeamerPage.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateTeam then
		self:ResortGrid()
	end
end

function CTeamerPage.CreateItem(self, pid)
	local oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem:SetPlayer(pid)
	self.m_ItemGrid:AddChild(oItem)
end

function CTeamerPage.ResortGrid(self)
	self.m_TeamerList = g_FriendCtrl.m_Friend["teamer"]
	local list = self.m_ItemGrid:GetChildList()
	local amount = #self.m_TeamerList - #list
	for i = 1, amount do
		local oItem = self.m_ItemClone:Clone()
		oItem:SetActive(true)
		self.m_ItemGrid:AddChild()
	end
	
	for k, pid in self.m_TeamerList do
		local oItem = list:GetChild(k)
		oItem:SetPlayer(pid)
	end
	self.m_ItemGrid:Reposition()
end

function CTeamerPage.AddFriend(self)
	CFindFrdView:ShowView()
end


function CTeamerPage.ShowTalk(self)
	
end

function CTeamerPage.GetBalckFriend(self)
end

return CTeamerPage