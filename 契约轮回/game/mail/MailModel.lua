--
-- @Author: chk
-- @Date:   2018-09-08 19:47:55
--

MailModel = MailModel or class("MailModel", BaseBagModel)
local MailModel = MailModel

function MailModel:ctor()
    MailModel.Instance = self
    self:Reset()


end

function MailModel:Reset()
    self.viewContainer = nil
    self.lastItemSettor = nil
    self.crntIndex = 1
    self.fstNotReadMail = nil
    self.newMail = nil            -- 新邮件
    self.mailInfo = nil
    self.readingMail = nil        --正在读的邮件
    self.readedMailIds = {}       --以读邮件id
    self.mailItemSettors = {}
    self.mailList = {}            --[mailid]=mail
    self.sort_list = {}           --排序邮件
    self.fetchMailIds = {}        --提取附件的邮件id
    self.readedMailList = {}      --  p_mail
    self.cur_ser_title = ""
    self.last_ser_title=""
    self.cur_ser_id = 1            --1：游戏问题 2：充值问题  3：意见反馈

    self.service_url = AppConfig.Url .. "api/role/feedback"
    --self.service_url = "http://192.168.31.195/api/role/feedback"
    self.service_key = "5G5x9DXXZ0FC1Q1G9udlk10UBfoIZWZ9"
    self.is_startting_send_cd = false
    self.res_time = 0
end

function MailModel.GetInstance()
    if MailModel.Instance == nil then
        MailModel()
    end
    return MailModel.Instance
end

function MailModel:AddMails(mails)
    for i=1, #mails do
        local mail = mails[i]
        self.mailList[mail.id] = mail
    end
    self:SortMail()
end

function MailModel:AddMail(mail)
    self.mailList[mail.id] = mail
    table.insert(self.sort_list,1, mail)
end

function MailModel:DelMailsById(mail_ids)
    for i, v in pairs(mail_ids) do
        self:DelMailByID(v)
    end
end

function MailModel:DelMailByID(mail_id)
    self.mailList[mail_id] = nil
    for i=1, #self.sort_list do
        if self.sort_list[i].id == mail_id then
            table.remove(self.sort_list, i)
            break
        end
    end
end

function MailModel:GetMailById(mail_id)
    return self.mailList[mail_id]
end

--获取可以删除的邮件
function MailModel:GetCanDelMailIds()
    local mail_ids = {}
    for i, v in pairs(self.mailList) do
        if v.attach and v.fetch then
            table.insert(mail_ids, v.id)
        elseif v.read and not v.attach then
            table.insert(mail_ids, v.id)
        end
    end

    return mail_ids
end

function MailModel:GetReadedMailIds()
    local mail_ids = {}
    for i, v in pairs(self.mailList) do
        if v.read then
            table.insert(mail_ids, v.id)
        end
    end

    return mail_ids
end

--获取有附件的邮件
function MailModel:GetHasEnclosureMailIds()
    local mail_ids = {}
    for i, v in pairs(self.mailList) do
        if v.attach and not v.fetch then
            table.insert(mail_ids, v.id)
        end
    end

    return mail_ids
end


--获取是否有未读的邮件
function MailModel:GetHasNotReadMail()
    local has = false
    for i, v in pairs(self.mailList) do
        if not v.read then
            has = true
            break
        end
    end

    return has
end

function MailModel:GetItemSettorById(mail_id)
    local itemSettor = nil
    for i, v in pairs(self.mailItemSettors) do
        if v.mail ~= nil and v.mail.id == mail_id then
            itemSettor = v
            break
        end
    end

    return itemSettor
end

--置空一键提取附件邮件id
function MailModel:EmptyFetchMailIds()
    self.fetchMailIds = {}
end
--设置有附件的邮件id
function MailModel:SetHasEnclosureMails()
    self:EmptyFetchMailIds()
    for i, v in pairs(self.mailList) do
        if v.attach then
            table.insert(self.fetchMailIds, v.id)
        end
    end
end

function MailModel:DeItemSettor(settor)
    table.removebyvalue(self.mailItemSettors, settor)
end

--设置第一封未读的邮件
function MailModel:SetFstNotReadMail()
    --self.fstNotReadMail = nil
    --for i, v in pairs(self.mailList) do
    --	if not v.read then
    --		self.fstNotReadMail = v
    --		break
    --	end
    --end

    --if self.fstNotReadMail == nil then
    self.fstNotReadMail = table.getbyindex(self.mailList, 1)
    --end
end

function MailModel:GetMailDifTime(send_time, server_time)
    local difDay = TimeManager.Instance:GetDifDay(send_time, server_time)
    if difDay <= 0 then
        local difTime = server_time - send_time
        difTime = math.abs(difTime)
        if difTime < 59 then
            return ConfigLanguage.Mix.Just
        elseif difTime >= 60 and difTime < 3600 then
            return math.floor(difTime / 60) .. ConfigLanguage.Mix.Minute .. ConfigLanguage.Mix.Before
        else
            return math.floor(difTime / 3600) .. ConfigLanguage.Mix.Hour .. ConfigLanguage.Mix.Before
        end
    else
        return difDay .. ConfigLanguage.Mix.Day .. ConfigLanguage.Mix.Before
    end
end

function MailModel:SetMailRead(mail_ids)
    for i, v in pairs(mail_ids) do
        local mail = self:GetMailById(v)
        if mail ~= nil then
            mail.read = true
        end
    end
end

function MailModel:SetMailFetch(mail_ids)
    for i, v in pairs(mail_ids) do
        local mail = self:GetMailById(v)
        if mail ~= nil then
            mail.fetch = true
        end
    end
end

function MailModel:SortMail()
    local function call_back(mail1, mail2)
        local sortMail1 = 0
        local sortMail2 = 0

        if not mail1.read then
            sortMail1 = sortMail1 + 100
        end

        if mail1.attach and not mail1.fetch then
            sortMail1 = sortMail1 + 50
        end

        if not mail2.read then
            sortMail2 = sortMail2 + 100
        end

        if mail2.attach and not mail2.fetch then
            sortMail2 = sortMail2 + 50
        end

        if mail1.send > mail2.send then
            sortMail1 = sortMail1 + 10
        elseif mail1.send < mail2.send then
            sortMail2 = sortMail2 + 10
        end

        return sortMail1 > sortMail2

    end
    self.sort_list = table.values(self.mailList)
    table.sort(self.sort_list, call_back)
end


