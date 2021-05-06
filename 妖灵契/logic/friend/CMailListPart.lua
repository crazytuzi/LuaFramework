local CMailListPart = class("CMailListPart", CBox)

function CMailListPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_OneClickRetrieve = self:NewUI(1, CButton)
	self.m_OneClickDelete = self:NewUI(2, CButton)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_ItemClone = self:NewUI(4, CMailItem)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_CurMailId = nil
	self.m_MaxAmount = 10
	self.m_ItemTable = {}
	self:InitContent()
end

function CMailListPart.InitContent(self)
	self.m_ItemClone:SetActive(false)
	self:RebuildMailList()
	self.m_OneClickRetrieve:AddUIEvent("click", callback(self, "OnOneClickRetrieve"))
	self.m_OneClickDelete:AddUIEvent("click", callback(self, "OnOneClickDelete"))
	g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailCtrlEvent"))
	self.m_ScrollView:AddMoveCheck("down", self.m_Grid, callback(self, "ShowNewMail"))
end

function CMailListPart.SetParentObj(self, parentobj)
	self.m_ParentView = parentobj
end

function CMailListPart.RebuildMailList(self)
	self.m_Grid:Clear()
	self.m_ItemTable = {}
	self:InitItem()
end

function CMailListPart.OnMailCtrlEvent(self, oCtrl)
	local eventID = oCtrl.m_EventID
	if eventID == define.Mail.Single_Event.Del then
		self:OnDelMailEvent(oCtrl)
	
	elseif eventID == define.Mail.Single_Event.Add then
		self:OnAddMailEvent(oCtrl)
	
	elseif eventID == define.Mail.Single_Event.GetDetail then
		self:OnUpdateMailsEvent(oCtrl)

	elseif eventID == define.Mail.Batch_Event.OpenMails then
		self:OnUpdateMailsEvent(oCtrl)

	elseif eventID == define.Mail.Single_Event.RetrieveAttach then
		self:OnUpdateMailsEvent(oCtrl)
	end
end

function CMailListPart.OnAddMailEvent(self, oCtrl)
	local simpleInfo = oCtrl.m_EventData
	self:AddMailItem(simpleInfo)
end

function CMailListPart.AddMailItem(self, simpleInfo)
	if simpleInfo == nil then
		return
	end
	
	local oItem = nil
	oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem:SetBoxInfo(simpleInfo)
	oItem:SetCallBack(callback(self, "OnOpenMail", simpleInfo))
	oItem:SetGroup(self.m_Grid:GetInstanceID())
	
	self.m_Grid:AddChild(oItem)
	oItem:SetAsFirstSibling()
	self.m_ItemTable[simpleInfo.mailid] = oItem
	self.m_Grid:Reposition()
	local frdview = CFriendMainView:GetView()
	if self.m_Grid:GetCount() == 1 and frdview and frdview:GetActive() then
		self:DefaultSelect()
	end
end

function CMailListPart.OnDelMailEvent(self, oCtrl)
	local mailid = oCtrl.m_EventData
	self:ForceDelMailItem(mailid)
end

function CMailListPart.OnUpdateMailsEvent(self, oCtrl)
	if type(oCtrl.m_EventData) == "table" then
		for _, mailid in ipairs(oCtrl.m_EventData) do
			local oMail = self.m_ItemTable[mailid]
			if oMail then
				oMail:UpdateInfo()
			end
		end
	else
		local mailid = oCtrl.m_EventData
		local oMail = self.m_ItemTable[mailid]
		if oMail then
			oMail:UpdateInfo()
		end
	end
end

function CMailListPart.DefaultSelect(self, mailid)
	local oMail = self.m_Grid:GetChild(1)
	if oMail then
		oMail:ChooseItem()
	else
		self.m_ParentView:ShowNoEmail()
	end
end

function CMailListPart.ForceDelMailItem(self, mailid)
	if mailid == nil then
		return
	end
	local oMail = self.m_ItemTable[mailid]
	if oMail then
		local index = self.m_Grid:GetChildIdx(oMail.m_Transform)
		self.m_Grid:RemoveChild(oMail)
		self.m_ItemTable[mailid] = nil
		if self.m_CurMailId == mailid then
			self:ChooseNextMail(index)
		end
	end
end

function CMailListPart.ChooseNextMail(self, index)
	if index then
		local nextMail = self.m_Grid:GetChild(index)
		if nextMail then
			nextMail:ChooseItem()
			return
		end
		if index-1 > 0 then
			local nextMail = self.m_Grid:GetChild(index-1)
			if nextMail then
				nextMail:ChooseItem()
				return
			end
		end
		local nextMail = self.m_Grid:GetChild(1)
		if nextMail then
			nextMail:ChooseItem()
		else
			self.m_ParentView:ShowNoEmail()
		end
	end
end

function CMailListPart.OnOneClickRetrieve(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAcceptAllAttach"], 5) then
		netmail.C2GSAcceptAllAttach()
	end
end

function CMailListPart.OnOneClickDelete(self)
	local windowConfirmInfo = {
		title = "一键删除",
		msg = "一键删除将清空所有无附件的邮件，是否继续？",
		okStr = "确定",
		cancelStr = "取消",
		okCallback = function()
			netmail.C2GSDeleteAllMail()
		end
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CMailListPart.InitItem(self)
	local mailList = g_MailCtrl:GetMailList()
	self.m_MailList = mailList
	self.m_CurInitIndex = 0
	for i, mail in ipairs(mailList) do
		if i > self.m_MaxAmount then
			break
		end
		self:InitSingleItem(mail)
		self.m_CurInitIndex = i
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CMailListPart.InitSingleItem(self, mail)
	if mail == nil then
		return
	end

	local oItem = nil
	oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem:SetBoxInfo(mail)
	oItem:SetCallBack(callback(self, "OnOpenMail", mail))
	oItem:SetGroup(self.m_Grid:GetInstanceID())
	self.m_Grid:AddChild(oItem)
	self.m_ItemTable[mail.mailid] = oItem
end

function CMailListPart.ShowNewMail(self)
	for i = self.m_CurInitIndex + 1, self.m_CurInitIndex + self.m_MaxAmount do
		local mail = self.m_MailList[i]
		if mail then
			self:InitSingleItem(mail)
			self.m_CurInitIndex = i
		else
			break
		end
	end
end

function CMailListPart.OnOpenMail(self, mail)
	if mail.mailid == self.m_CurMailId and self.m_ParentView:GetActiveMail() == mail.mailid then  -- 点击自身
		return
	end
	self.m_CurMailId = mail.mailid
	self.m_ParentView:ShowEmail(mail)
end

function CMailListPart.SetItemSelected(self, mailid, bSelected)
	-- 把 mail 对应的 MailItem 设为选中状态，并且 ScrollView 滚动到该 item
	if mailid == nil then
		return
	end

	local mailItem = self.m_ItemTable[mailid]
	if mailItem == nil then
		return
	end
	mailItem.m_ItemBG:ForceSelected(bSelected)
end

return CMailListPart