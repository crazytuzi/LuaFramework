local CFriendApplyView = class("CFriendApplyView", CViewBase)

function CFriendApplyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/ApplyFrdView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CFriendApplyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_AddAllBtn = self:NewUI(2, CButton)
	self.m_RejectAllBtn = self:NewUI(3, CButton)
	self.m_Grid = self:NewUI(4, CGrid)
	self.m_ApplyItem = self:NewUI(5, CBox)
	self.m_ApplyLabel = self:NewUI(6, CLabel)
	self:InitContent()
end

function CFriendApplyView.InitContent(self)
	self.m_ApplyItem:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddAllBtn:AddUIEvent("click", callback(self, "OnAcceptAll"))
	self.m_RejectAllBtn:AddUIEvent("click", callback(self, "OnRejectAll"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	self:RefreshGrid()
end

function CFriendApplyView.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateApply then
		self:RefreshGrid()
	end 
end

function CFriendApplyView.RefreshGrid(self)
	self.m_Grid:Clear()
	local list = g_FriendCtrl:GetApplyList()
	for _, pid in ipairs(list) do
		local info = g_FriendCtrl:GetApplyInfo(pid)
		if info then
			local itemobj = self:CreateItem()
			itemobj.m_NameLabel:SetText(info["name"])
			itemobj.m_GradeLabel:SetText(string.format("%d", info["grade"]))
			itemobj.m_AddrLabel:SetText(info["addr"])
			self:UpdateLabal(itemobj, info["labal"])
			itemobj.m_IconSpr:SpriteAvatar(info["shape"])
			itemobj.m_RejectBtn:AddUIEvent("click", callback(self, "OnReject", pid))
			itemobj.m_AcceptBtn:AddUIEvent("click", callback(self, "OnAccept", pid))
			self.m_Grid:AddChild(itemobj)
		end
	end
	self.m_Grid:Reposition()
	if #list > 0 then
		self.m_ApplyLabel:SetActive(true)
		self.m_ApplyLabel:SetText(string.format("你有%d条好友请求未处理", #list))
	else
		self.m_ApplyLabel:SetActive(false)
	end
end

function CFriendApplyView.CreateItem(self)
	local itemobj = self.m_ApplyItem:Clone()
	itemobj:SetActive(true)
	itemobj.m_IconSpr = itemobj:NewUI(1, CSprite)
	itemobj.m_GradeLabel = itemobj:NewUI(2, CLabel)
	itemobj.m_NameLabel = itemobj:NewUI(3, CLabel)
	itemobj.m_AddrLabel = itemobj:NewUI(4, CLabel)
	itemobj.m_LabalLabel = itemobj:NewUI(5, CLabel)
	itemobj.m_RejectBtn = itemobj:NewUI(6, CButton)
	itemobj.m_AcceptBtn = itemobj:NewUI(7, CButton)
	itemobj.m_LabalGrid = itemobj:NewUI(8, CGrid)
	itemobj.m_NoLabalLabel = itemobj:NewUI(9, CLabel)
	itemobj.m_LabalLabel:SetActive(false)
	return itemobj
end

function CFriendApplyView.UpdateLabal(self, box, list)
	box.m_LabalLabel:SetActive(false)
	box.m_LabalGrid:Clear()
	if #list == 0 then
		box.m_NoLabalLabel:SetActive(true)
	else
		box.m_NoLabalLabel:SetActive(false)
		for _, text in ipairs(list) do
			local label = box.m_LabalLabel:Clone()
			label:SetActive(true)
			label:SetText(text)
			box.m_LabalGrid:AddChild(label)
		end
		box.m_LabalGrid:Reposition()
	end
end

function CFriendApplyView.OnReject(self, pid)
	netfriend.C2GSDelApply({pid})
end

function CFriendApplyView.OnAccept(self, pid)
	netfriend.C2GSAgreeApply({pid})
end

function CFriendApplyView.OnAcceptAll(self)
	local list = g_FriendCtrl:GetApplyList()
	netfriend.C2GSAgreeApply(list)
end

function CFriendApplyView.OnRejectAll(self)
	local list = g_FriendCtrl:GetApplyList()
	netfriend.C2GSDelApply(list)
end

return CFriendApplyView