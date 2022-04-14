--
-- @Author: chk
-- @Date:   2018-09-08 20:25:36
--
require("game.mail.RequireMail")
MailController = MailController or class("MailController", BaseController)
local MailController = MailController

function MailController:ctor()
    MailController.Instance = self
    self.model = MailModel.GetInstance()
    self.mailList = {}
    self:AddEvents()
    self:RegisterAllProtocal()
end

function MailController:dctor()
    self:StopMySchedule()
end

function MailController:GetInstance()
    if not MailController.Instance then
        MailController.new()
    end
    return MailController.Instance
end

function MailController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1104_mail_pb"
    self:RegisterProtocal(proto.MAIL_LIST, self.HandleMailList)
    self:RegisterProtocal(proto.MAIL_DELETE, self.HandleDelMail)
    self:RegisterProtocal(proto.MAIL_FETCH, self.HandleFetchMail)
    self:RegisterProtocal(proto.MAIL_RECV, self.HandleMailRecive)
    self:RegisterProtocal(proto.MAIL_READ, self.HandleReadMail)
    self:RegisterProtocal(proto.MAIL_INFO, self.HandleMailInfo)
end

function MailController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(MailModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)

    GlobalEvent:AddListener(MailEvent.OpenOrRequest, handler(self, self.OpenOrRequest))
    GlobalEvent:AddListener(MailEvent.OpenMailPanel, handler(self, self.DelOpenPanelEvent))

    local function callback(cd)
        self:StopMySchedule()
        self.model.res_time = cd
        self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
    end
    self.model:AddListener(MailEvent.StartSendCD, callback)
end

function MailController:BeginningCD()
    if self.model.res_time > 1 then
        self.model.res_time = self.model.res_time - 1
    else
        self:StopMySchedule()
        self.model.is_startting_send_cd = false
    end
end

-- overwrite
function MailController:GameStart()

end

function MailController:DelOpenPanelEvent(index, sub_index)
    lua_panelMgr:GetPanelOrCreate(MailPanel):Open(index, sub_index)
end

function MailController:OpenOrRequest()
    self.model.crntIndex = 2
    lua_panelMgr:GetPanelOrCreate(MailPanel):Open()
end

function MailController:NeedShowMailIcon()
    if self.model:GetHasNotReadMail() then
        GlobalEvent:Brocast(MailEvent.ShowMailIcon, true)
    else
        GlobalEvent:Brocast(MailEvent.ShowMailIcon, false)
    end
end

--请求邮件信息
function MailController:RequestMailInfo()
    local pb = self:GetPbObject("m_mail_info_tos")
    self:WriteMsg(proto.MAIL_INFO, pb)
end

function MailController:HandleMailInfo()
    local data = self:ReadMsg("m_mail_info_toc")
    self.model.mailInfo = data
    GlobalEvent:Brocast(MailEvent.MailInfo)
end

--请求邮件列表
function MailController:RequestMailList()
    local pb = self:GetPbObject("m_mail_list_tos")
    self:WriteMsg(proto.MAIL_LIST, pb)
end

function MailController:HandleMailList()

    local data = self:ReadMsg("m_mail_list_toc")
    self.model:AddMails(data.mails)
    self.model.crntIndex = 2

    self.model:Brocast(MailEvent.LoadMailItem)
    --lua_panelMgr:GetPanelOrCreate(MailPanel):Open(2)
end

--收到新邮件
function MailController:HandleMailRecive()
    local data = self:ReadMsg("m_mail_recv_toc")
    self.model.newMail = data.mail
    self.model:AddMail(data.mail)
    Notify.ShowText(ConfigLanguage.Mail.HasNewMail)
    GlobalEvent:Brocast(MailEvent.ShowMailIcon, true)
end

--请求读取最新的邮件
function MailController:RequestNewestMail()
    local mail = self.model.fstNotReadMail
    if mail ~= nil then
        self:RequestReadMail(mail.id)
    elseif self.model.mailList[1] ~= nil then
        self:RequestReadMail(self.model.mailList[1].id)
    end
end

--请求读取邮件
function MailController:RequestReadMail(mail_id)
    local pb = self:GetPbObject("m_mail_read_tos")
    pb.mail_id = mail_id
    self:WriteMsg(proto.MAIL_READ, pb)

end

function MailController:HandleReadMail()
    local data = self:ReadMsg("m_mail_read_toc")
    local mail_ids = {}
    table.insert(mail_ids, data.mail_id)
    self.model:SetMailRead(mail_ids)
    self.model.readingMail = data
    self.model.readedMailList[data.mail_id] = data
    self.model:Brocast(MailEvent.ReadMail, data.mail_id)
    self.model:Brocast(MailEvent.ShowMailContent)

    self:NeedShowMailIcon()
end

--请求删除邮件
function MailController:RequestDelMail(mail_ids)
    local pb = self:GetPbObject("m_mail_delete_tos")

    for k, v in pairs(mail_ids) do
        pb.mail_ids:append(v)
    end

    self:WriteMsg(proto.MAIL_DELETE, pb)
end

function MailController:HandleDelMail()
    local data = self:ReadMsg("m_mail_delete_toc")
    local mails = data.mail_ids
    self.model:DelMailsById(mails)
    self.model:Brocast(MailEvent.DelMails, data.mail_ids)
    self:NeedShowMailIcon()
end

--请求提取附件
function MailController:RequestFetchMail(mail_id)
    if mail_id ~= 0 then
        self.model:EmptyFetchMailIds()
        self:RequestFetchMail2(mail_id)
    else
        self.model:SetHasEnclosureMails()
        local mail_ids = self.model:GetHasEnclosureMailIds()
        for i, v in pairs(mail_ids) do
            self:RequestFetchMail2(v)
        end
    end

end

function MailController:RequestFetchMail2(mail_id)
    local pb = self:GetPbObject("m_mail_fetch_tos")
    pb.mail_id = mail_id
    self:WriteMsg(proto.MAIL_FETCH, pb)
end

function MailController:HandleFetchMail()
    local data = self:ReadMsg("m_mail_fetch_toc")
    local mail_ids = {}
    if data.mail_id == 0 then
        self.model:SetMailRead(self.model.fetchMailIds)
        self.model:SetMailFetch(self.model.fetchMailIds)

        for i, v in pairs(self.model.fetchMailIds) do
            table.insert(mail_ids, v)
        end
    else
        for i, v in pairs(data.mail_id) do
            table.insert(mail_ids, v)
        end

        self.model:SetMailRead(mail_ids)
        self.model:SetMailFetch(mail_ids)
    end

    for i, v in pairs(mail_ids) do
        self.model:Brocast(MailEvent.FetchMail, v)
    end

    self:NeedShowMailIcon()
end

function MailController:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

----请求基本信息
--function LoginController:RequestLoginVerify()
-- local pb = self:GetPbObject("m_login_verify_tos")
-- self:WriteMsg(proto.LOGIN_VERIFY,pb)
--end

----服务的返回信息
--function MailController:HandleLoginVerify(  )
-- local data = self:ReadMsg("m_login_verify_toc")
--end


