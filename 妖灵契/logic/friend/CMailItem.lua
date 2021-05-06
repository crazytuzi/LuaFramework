local CMailItem = class("CMailItem", CBox)

function CMailItem.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_ItemBG = self:NewUI(1, CBox)
	self.m_HeadSprite = self:NewUI(2, CSprite)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_ExpireDateLabel = self:NewUI(4, CLabel)
	self.m_HasAttachSprite = self:NewUI(5, CSprite)
	self.m_HasAttachSprite.m_TweenRotation = self.m_HasAttachSprite:GetComponent(classtype.TweenRotation)
	self.m_ItemBG:AddUIEvent("click", callback(self, "OnClickItem"))
end

function CMailItem.SetGroup(self, groupId)
	self.m_ItemBG:SetGroup(groupId)
end

function CMailItem.SetCallBack(self, cb)
	if cb then
		self.m_CallBack = cb
	else
		self.m_CallBack = nil
	end
end

function CMailItem.SetBoxInfo(self, mail)
	if mail == nil then
		return
	end
	self.m_ID = mail.mailid
	local title = mail.title
	local expireDate = g_MailCtrl:GetDate(mail.createtime)
	local opened = mail.opened or CMailCtrl.UNOPENED
	local hasattach = mail.hasattach
	
	self.m_TitleLabel:SetText(title)
	self.m_ExpireDateLabel:SetText(expireDate)
	self:SetOpened(opened, hasattach)
	--self:SetAttch()
end

function CMailItem.UpdateInfo(self)
	local mail = g_MailCtrl:GetMailInfo(self.m_ID)
	self:SetBoxInfo(mail)
end

function CMailItem.SetOpened(self, bopen, hasattach)
	if bopen == CMailCtrl.OPENED then
		self.m_HeadSprite:SetSpriteName("pic_youjian_dakai")
		self.m_HeadSprite:SetSize(73, 70)
		
	else
		self.m_HeadSprite:SetSpriteName("pic_youjian")
		self.m_HeadSprite:SetSize(72, 54)
	end
	if hasattach == CMailCtrl.HAS_ATTACH then
		self.m_HasAttachSprite:SetActive(true)
		self.m_HasAttachSprite.m_TweenRotation.enabled = true
	elseif hasattach == CMailCtrl.ATTACH_RETRIEVED then
		self.m_HasAttachSprite:SetActive(false)
	else
		self.m_HasAttachSprite:SetActive(false)
	end
end

function CMailItem.SetAttch(self, hasattach)
	
end

function CMailItem.OnClickItem(self)
	if self.m_CallBack then
		self.m_CallBack()
	end
end

function CMailItem.SetSelected(self, bselect)
	self.m_ItemBG:ForceSelected(bselect)
end

function CMailItem.ChooseItem(self)
	self:SetSelected(true)
	self:OnClickItem()
end

return CMailItem