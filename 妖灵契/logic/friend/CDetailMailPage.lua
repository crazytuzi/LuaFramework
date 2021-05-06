local CDetailMailPage = class("CDetailMailPage", CBox)

function CDetailMailPage.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_RetrieveAttachesBtn = self:NewUI(1, CButton)
    self.m_MailTextLabel       = self:NewUI(2, CLabel)
    self.m_ReceiveTimeLabel     = self:NewUI(3, CLabel)
    self.m_SenderLabel         = self:NewUI(4, CLabel)
    self.m_Grid                = self:NewUI(5, CGrid)
    self.m_ItemClone           = self:NewUI(6, CAttachItem)
    self.m_TitleLabel          = self:NewUI(7, CLabel)
    self.m_DelBtn              = self:NewUI(8, CButton)
    self.m_AttachTitleLabel    = self:NewUI(9, CLabel)
    self.m_AttachScrollView    = self:NewUI(10, CScrollView)
    self.m_MailId              = nil
    self:InitContent()
end

function CDetailMailPage.InitContent(self)
    self.m_RetrieveAttachesBtn:AddUIEvent("click", callback(self, "OnRetrieveAttaches"))
    self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
end

function CDetailMailPage.InitAttachItem(self, tAttach)
    self.m_Grid:Clear()
    for _, attach in pairs(tAttach) do
        local oItem = self.m_ItemClone:Clone(
            function()
                self:ItemCallBack(attach)
            end
        )
        oItem:SetActive(true)
        oItem:SetBoxInfo(attach)
        self.m_Grid:AddChild(oItem)
        oItem:SetGroup(self.m_Grid:GetInstanceID())
    end
    self.m_Grid:Reposition()
end

function CDetailMailPage.OnRetrieveAttaches(self)
    printc("领取邮件附件, mailid = " .. self.m_MailId)
    netmail.C2GSAcceptAttach(self.m_MailId)
end

function CDetailMailPage.OnDel(self)
    printc("删除邮件, mailid = " .. self.m_MailId)
    g_MailCtrl.m_DontCloseDetailView = true
    g_MailCtrl.m_ShowNextMail = true
    netmail.C2GSDeleteMail(self.m_MailId)  -- 对于读后即删的邮件，self.m_MailId 已不存在，服务器会返回 mailid，这样能触发 CMailPage 的相关处理（删除 CMailItem，关闭本界面）
end

function CDetailMailPage.SetDetailInfo(self, mail)
    if self.m_MailId ~= nil
        and g_MailCtrl.m_MailidNotExistInServer ~= nil
        and self.m_MailId == g_MailCtrl.m_MailidNotExistInServer then
        printc("CDetailMailPage.SetDetailInfo，上一个 mailid 不存在于服务器，删除 MailItem")
        netmail.C2GSDeleteMail(self.m_MailId)  -- 对于读后即删的邮件，self.m_MailId 已不存在，服务器会返回 mailid，这样能触发 CMailPage 的相关处理（删除 CMailItem，关闭本界面）
    end

    -- listener
    self.m_MailId = mail.mailid  -- 更新 mailid
    g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "UpdateUI"))

    -- 标题
    self.m_TitleLabel:SetText(mail.title)

    -- 附件
    if mail.hasattach == CMailCtrl.HAS_ATTACH then
        self:ShowHasAttach()
    elseif mail.hasattach == CMailCtrl.HAS_NO_ATTACH then
        self:ShowHasNoAttach()
    elseif mail.hasattach == CMailCtrl.ATTACH_RETRIEVED then
        self:ShowAttachRetrieved()
    end

    g_MailCtrl:SetCurOpenedMailIndex(mail.mailid)
    netmail.C2GSOpenMail(mail.mailid)
end

function CDetailMailPage.UpdateUI(self, callbackBase)
    local eventID = callbackBase.m_EventID
    if eventID == define.Mail.Single_Event.GetDetail then
        self:OnMailInfoEvent(callbackBase)
    elseif eventID == define.Mail.Single_Event.RetrieveAttach then
        self:OnRetrieveMailAttachesEvent(callbackBase)
    end
end

function CDetailMailPage.OnMailInfoEvent(self, callbackBase)
    local mailid = callbackBase.m_EventData
    printc("CDetailMailPage 更新邮件详细信息, mailid = " .. mailid)
    if mailid == self.m_MailId then
        local mail = g_MailCtrl:GetMailInfo(mailid)
        if mail ~= nil then
            self.m_MailTextLabel:SetText(mail.context)
            self.m_SenderLabel:SetText(mail.senderName)
            self.m_ReceiveTimeLabel:SetText(g_MailCtrl:GetTime(mail.createtime))  -- 接收时间 == 创建时间
            self:InitAttachItem(mail.attachs)
        end
    end
end

function CDetailMailPage.OnRetrieveMailAttachesEvent(self, callbackBase)
    local mailid = callbackBase.m_EventData
    printc("CDetailMailPage 领取附件, mailid = " .. mailid .. ", 当前 Detail mailid = " .. self.m_MailId)
    if mailid == self.m_MailId then
        self:ShowAttachRetrieved()
    end
end

function CDetailMailPage.ShowHasAttach(self)
    self.m_AttachTitleLabel:SetActive(true)
    self.m_AttachTitleLabel:SetText("奖励附件")
    self.m_AttachScrollView:SetActive(true)
    self.m_RetrieveAttachesBtn:SetActive(true)
    self.m_DelBtn:SetActive(false)
end

function CDetailMailPage.ShowHasNoAttach(self)
    self.m_AttachTitleLabel:SetActive(false)
    self.m_AttachScrollView:SetActive(false)
    self.m_RetrieveAttachesBtn:SetActive(false)
    self.m_DelBtn:SetActive(true)
end

function CDetailMailPage.ShowAttachRetrieved(self)
    self.m_AttachTitleLabel:SetActive(true)
    self.m_AttachTitleLabel:SetText("附件：已领取")
    self.m_AttachScrollView:SetActive(false)
    self.m_RetrieveAttachesBtn:SetActive(false)
    self.m_DelBtn:SetActive(true)
end

return CDetailMailPage