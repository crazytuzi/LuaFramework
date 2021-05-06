local CMailDetailPart = class("CMailDetailPart", CBox)

function CMailDetailPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_RetrieveAttachesBtn = self:NewUI(1, CButton)
	self.m_MailTextLabel = self:NewUI(2, CLabel)
	self.m_ReceiveTimeLabel = self:NewUI(3, CLabel)
	--self.m_SenderLabel = self:NewUI(4, CLabel)
	self.m_NoMailTexture = self:NewUI(4, CTexture)

	self.m_Grid = self:NewUI(5, CGrid)
	self.m_ItemClone = self:NewUI(6, CItemTipsBox)
	self.m_TitleLabel = self:NewUI(7, CLabel)
	self.m_DelBtn = self:NewUI(8, CButton)
	
	
	self.m_AttachTitleLabel = self:NewUI(9, CLabel)
	self.m_AttachScrollView = self:NewUI(10, CScrollView)
	self.m_ShowWidget = self:NewUI(11, CWidget)
	self.m_PartnerClone = self:NewUI(12, CBox)
	self.m_GetAttachSpr = self:NewUI(13, CSprite)
	self.m_AttachPart = self:NewUI(14, CObject)
	self.m_TextScrollView = self:NewUI(15, CScrollView)

	self.m_ItemClone:SetActive(false)
	self.m_PartnerClone:SetActive(false)
	self.m_MailId = nil
	self:InitContent()
end

function CMailDetailPart.InitContent(self)
	self.m_MailTextLabel:SetText("")
	self.m_ReceiveTimeLabel:SetText("")
	self:ShowHasNoAttach()
	self.m_RetrieveAttachesBtn:AddUIEvent("click", callback(self, "OnRetrieveAttaches"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "UpdateUI"))
end

function CMailDetailPart.SetParentObj(self, parentobj)
	self.m_ParentView = parentobj
end

function CMailDetailPart.OnRetrieveAttaches(self)
	printc("领取邮件附件, mailid = " .. self.m_MailId)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAcceptAttach"], 3) then
		netmail.C2GSAcceptAttach(self.m_MailId)
	end
end

function CMailDetailPart.OnDel(self)
	printc("删除邮件, mailid = " .. self.m_MailId)
	g_MailCtrl.m_DontCloseDetailView = true
	g_MailCtrl.m_ShowNextMail = true
	netmail.C2GSDeleteMail({self.m_MailId})  -- 对于读后即删的邮件，self.m_MailId 已不存在，服务器会返回 mailid，这样能触发 CMailPage 的相关处理（删除 CMailItem，关闭本界面）
end

function CMailDetailPart.SetDetailInfo(self, mail)
	self:ShowUI(true)
	self.m_MailId = mail.mailid  -- 更新 mailid
	-- 标题
	self.m_TitleLabel:SetText(mail.subject)
	-- 附件
	if mail.hasattach == CMailCtrl.HAS_ATTACH then
		self:ShowHasAttach()
	elseif mail.hasattach == CMailCtrl.HAS_NO_ATTACH then
		self:ShowHasNoAttach()
	elseif mail.hasattach == CMailCtrl.ATTACH_RETRIEVED then
		self:ShowAttachRetrieved()
	end

	g_MailCtrl:SetCurOpenedMailIndex(mail.mailid)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSOpenMail"], 3) then
		netmail.C2GSOpenMail(mail.mailid)
	end
end

function CMailDetailPart.UpdateUI(self, callbackBase)
	local eventID = callbackBase.m_EventID
	if eventID == define.Mail.Single_Event.GetDetail then
		self:OnMailInfoEvent(callbackBase)
	
	elseif eventID == define.Mail.Single_Event.RetrieveAttach then
		self:OnRetrieveMailAttachesEvent(callbackBase)
	end
end

function CMailDetailPart.OnMailInfoEvent(self, callbackBase)
	local mailid = callbackBase.m_EventData
	if mailid == self.m_MailId then
		local mail = g_MailCtrl:GetMailInfo(mailid)
		if mail ~= nil then
			self.m_MailTextLabel:SetRichText(mail.context)
			self.m_TitleLabel:SetText(mail.subject)
			self.m_ReceiveTimeLabel:SetText("有效期："..g_MailCtrl:GetLeftTime(mail.validtime))  -- 接收时间 == 创建时间
			self:CreateAttachs(mail.attachs)
		end
	end
end

function CMailDetailPart.OnRetrieveMailAttachesEvent(self, callbackBase)
	local mailid = callbackBase.m_EventData
	if mailid == self.m_MailId then
		self:ShowAttachRetrieved()
	end
end

function CMailDetailPart.ShowHasAttach(self)
	self.m_AttachTitleLabel:SetActive(true)
	self:SetScroll(true)
	self.m_AttachTitleLabel:SetText("奖励附件")
	self.m_AttachScrollView:SetActive(true)
	self.m_RetrieveAttachesBtn:SetActive(true)
	self.m_GetAttachSpr:SetActive(false)
	self.m_DelBtn:SetActive(false)

end

function CMailDetailPart.ShowHasNoAttach(self)
	self:SetScroll(false)
	self.m_AttachTitleLabel:SetActive(false)
	self.m_AttachScrollView:SetActive(false)
	self.m_RetrieveAttachesBtn:SetActive(false)
	self.m_GetAttachSpr:SetActive(false)
	self.m_DelBtn:SetActive(true)
end

function CMailDetailPart.ShowAttachRetrieved(self)
	local mail = g_MailCtrl:GetMailInfo(self.m_MailId)
	if mail.attachs and #mail.attachs > 0 then
		self:SetScroll(true)
		self.m_AttachTitleLabel:SetActive(true)
		self.m_AttachScrollView:SetActive(true)
		self.m_GetAttachSpr:SetActive(true)
	else
		self.m_AttachTitleLabel:SetActive(false)
		self:SetScroll(false)
		self.m_AttachScrollView:SetActive(false)
		self.m_GetAttachSpr:SetActive(false)
	end
	
	self.m_RetrieveAttachesBtn:SetActive(false)
	self.m_DelBtn:SetActive(true)
end

function CMailDetailPart.SetScroll(self, hasattach)
	if hasattach then
		self.m_TextScrollView:SetBaseClipRegion( Vector4.New(0, 0, 550, 320) )
		self.m_AttachPart:SetActive(true)
	else
		self.m_TextScrollView:SetBaseClipRegion( Vector4.New(0, -65, 550, 450) )
		self.m_AttachPart:SetActive(false)
	end
	self.m_TextScrollView:ResetPosition()
end

function CMailDetailPart.CreateAttachs(self, tAttach)
	self.m_Grid:Clear()
	local mail = g_MailCtrl:GetMailInfo(self.m_MailId)
	if mail.hasattach == CMailCtrl.HAS_ATTACH then
		self:ShowHasAttach()
	elseif mail.hasattach == CMailCtrl.HAS_NO_ATTACH then
		self:ShowHasNoAttach()
	elseif mail.hasattach == CMailCtrl.ATTACH_RETRIEVED then
		self:ShowAttachRetrieved()
	end
	for _, attach in pairs(tAttach) do
		local oItem = self:CreateAttachItem(attach)
		self.m_Grid:AddChild(oItem)
	end
	self.m_Grid:Reposition()
end

function CMailDetailPart.CreateAttachItem(self, attach)
	if attach.type == 1 then
		return self:CreateItem(attach)
	elseif attach.type == 4 then
		return self:CreatePartner(attach)
	elseif attach.type == 2 then
		return self:CreateCoin(attach)
	end
end

function CMailDetailPart.CreateItem(self, attach)
	local oItem = self.m_ItemClone:Clone()
	oItem:SetItemData(attach["sid"], attach["val"])
	oItem:SetActive(true)
	return oItem
end

function CMailDetailPart.CreateCoin(self, attach)
	local shape = nil
	local vitualdata = data.npcstoredata.Currency
	if vitualdata[attach["sid"]] then
		shape = vitualdata[attach["sid"]].virtual_id
	else
		shape = 1002
	end
	local oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem.m_BG = oItem:NewUI(2, CSprite)
	oItem.m_Icon = oItem:NewUI(1, CSprite)
	oItem.m_AmountLabel = oItem:NewUI(4, CLabel)
	local d = DataTools.GetItemData(shape)
	oItem.m_BG:SetItemQuality(d["quality"])
	
	oItem.m_Icon:SpriteItemShape(d["icon"])
	if attach["val"] > 1 then
		oItem.m_AmountLabel:SetText(string.numberConvert(attach["val"]))
	else
		oItem.m_AmountLabel:SetActive(false)
	end
	oItem:AddUIEvent("click", callback(self, "OnShowItemTip", shape))
	return oItem
end

function CMailDetailPart.CreatePartner(self, attach)
	local oItem = self.m_PartnerClone:Clone()
	oItem:SetActive(true)
	oItem.m_BG = oItem:NewUI(1, CSprite)
	oItem.m_Icon = oItem:NewUI(2, CSprite)
	
	local shape = attach.sid
	local d = data.partnerdata.DATA[shape]
	if d then
		g_PartnerCtrl:ChangeRareBorder(oItem.m_BG, d["rare"])
		oItem.m_Icon:SpriteAvatar(d["icon"])
	end
	
	oItem:AddUIEvent("click", callback(self, "OnShowPartnerTip", attach["sid"]))
	return oItem
end

function CMailDetailPart.ShowUI(self, bshow)
	self.m_NoMailTexture:SetActive(not bshow)
	self.m_ShowWidget:SetActive(bshow)
end

function CMailDetailPart.OnShowItemTip(self, shape, oItem)
	local args = {
		widget = oItem,
		side = enum.UIAnchor.Side.TopRight,
		offset = Vector2.New(-110, 10)
	}
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(shape, args)
end

function CMailDetailPart.OnShowPartnerTip(self, shape, oItem)
	local args = {
		widget = oItem,
		side = enum.UIAnchor.Side.TopRight,
		offset = Vector2.New(-110, 10)
	}
	g_WindowTipCtrl:SetWindowPartnerInfo(shape, args)
end

return CMailDetailPart
