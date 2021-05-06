local CMailCtrl = class("CMailCtrl", CCtrlBase)

CMailCtrl.UNOPENED = 0
CMailCtrl.OPENED = 1
CMailCtrl.HAS_NO_ATTACH = 0
CMailCtrl.HAS_ATTACH = 1
CMailCtrl.ATTACH_RETRIEVED = 2
CMailCtrl.NOT_READ_TO_DEL = 0
CMailCtrl.READ_TO_DEL = 1
	
function CMailCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_Mails = {}
	self.m_CurOpenedMailIndex = nil	  -- 记录当前打开的邮件 index
end

function CMailCtrl.InitLoginMail(self, mailList)
	self.m_Mails = {}
	self.m_CurOpenedMailIndex = nil
	for _, mailobj in ipairs(mailList) do
		table.insert(self.m_Mails, self:CreateMail(mailobj))
	end
end

function CMailCtrl.CreateMail(self, data)
	local mailobj = {
		mailid = data.mailid,
		title = data.title,
		subject = data.subject,
		keeptime = data.keeptime,
		hasattach = data.hasattach,
		opened = data.opened,
		readtodel = data.readtodel,
		createtime = data.createtime,
	}
	return mailobj
end

function CMailCtrl.GetDate(self, timestamp)
	local year = os.date("%Y", timestamp)
	local month = os.date("%m", timestamp)
	local day = os.date("%d", timestamp)
	return year .. "-" .. month .. "-" .. day
end

function CMailCtrl.GetTime(self, timestamp)
	local sDate = self:GetDate(timestamp)
	local hour = os.date("%H", timestamp)
	local minute = os.date("%M", timestamp)
	return sDate .. " " .. hour .. ":" .. minute
end

function CMailCtrl.GetLeftTime(self, iSec)
	iSec = iSec - g_TimeCtrl:GetTimeS()
	iSec = math.floor(iSec)
	iSec = math.max(iSec, 0)
	
	local day = math.floor(iSec / (3600*24))
	local hour = math.floor(iSec / 3600)
	local min = math.floor((iSec % 3600) / 60)
	local sec = iSec % 60
	if day > 0 then
		return string.format("%d天", day)
	elseif hour > 0 then
		return string.format("%d小时%d分钟", hour, min)
	else
		return string.format("%d分钟", min)
	end
end

function CMailCtrl.GetUnOpenMailAmount(self)
	local amount = 0
	for _, mail in pairs(self.m_Mails) do
		if mail.opened == self.UNOPENED then
			amount = amount + 1
		end
	end
	return amount
end

function CMailCtrl.UpdateMailInfo(self, pbdata)
	printc("CMailCtrl.UpdateMailInfo, mailid = " .. pbdata.mailid)
	for _, mail in pairs(self.m_Mails) do
		if mail.mailid == pbdata.mailid then
			mail.title = pbdata.title
			mail.context = pbdata.context
			mail.keeptime = pbdata.keeptime
			mail.validtime = pbdata.validtime
			mail.senderId = pbdata.pid
			mail.senderName = pbdata.name
			mail.opened = pbdata.opened
			mail.attachs = pbdata.attachs
			mail.subject = pbdata.subject
			self:OnEvent(define.Mail.Single_Event.GetDetail, pbdata.mailid)
			return
		end
	end
end

function CMailCtrl.GetMailList(self)
	local mailList = {}
	for _, mail in ipairs(self.m_Mails) do
		table.insert(mailList, mail)
	end
	local function cmp(a, b)
		if a.opened ~= b.opened then
			if a.opened == 0 then
				return true
			elseif b.opened == 0 then
				return false
			end
		end
		if a.hasattach ~= b.hasattach then
			if a.hasattach == CMailCtrl.HAS_ATTACH then
				return true
			elseif b.hasattach == CMailCtrl.HAS_ATTACH then
				return false
			end
		end
		if a.createtime ~= b.createtime then
			if a.createtime > b.createtime then
				return true
			else
				return false
			end
		end
		if a.mailid ~= b.mailid then
			return a.mailid > b.mailid 
		end
		return false
	end
	table.sort(mailList, cmp)
	return mailList
end

function CMailCtrl.GetMailInfo(self, mailid)
	for _, mail in ipairs(self.m_Mails) do
		if mail.mailid == mailid then
			return mail
		end
	end
	return nil
end

function CMailCtrl.RetrieveAttach(self, mailid)
	for _, mail in pairs(self.m_Mails) do
		if mail.mailid == mailid then
			--mail.attachs = {}
			mail.hasattach = self.ATTACH_RETRIEVED
		end
	end
	self:OnEvent(define.Mail.Single_Event.RetrieveAttach, mailid)
end

function CMailCtrl.DelMail(self, mailid)
	local readtodel = self.NOT_READ_TO_DEL
	for index, mail in pairs(self.m_Mails) do
		if mail.mailid == mailid then
			readtodel = mail.readtodel
			table.remove(self.m_Mails, index)
			break
		end
	end
	self:OnEvent(define.Mail.Single_Event.Del, mailid)
end

function CMailCtrl.OpenMails(self, mailids)
	for _, mailid in pairs(mailids) do
		local mail = self:GetMailInfo(mailid)
		if mail ~= nil then
			mail.opened = self.OPENED
		end
	end
	self:OnEvent(define.Mail.Batch_Event.OpenMails, mailids)
end

function CMailCtrl.AddMail(self, simpleInfo)
	local mailobj = self:CreateMail(simpleInfo)
	table.insert(self.m_Mails, mailobj)
	self:OnEvent(define.Mail.Single_Event.Add, mailobj)
end

function CMailCtrl.GetMailIndex(self, mailid)
	for i, mail in pairs(self.m_Mails) do
		if mail.mailid == mailid then
			return i
		end
	end
	return nil
end

function CMailCtrl.SetCurOpenedMailIndex(self, mailid)
	self.m_CurOpenedMailIndex = nil
	for i, mail in pairs(self.m_Mails) do
		if mail.mailid == mailid then
			self.m_CurOpenedMailIndex = i
			return
		end
	end
end

function CMailCtrl.GetNextMail(self)
	local nextMailIndex = self:GetNextMailIndex()
	return self.m_Mails[nextMailIndex]
end

function CMailCtrl.GetNextMailIndex(self)  -- 因为 m_Mails 顺序跟显示顺序相反，所以这里的逻辑也相反
	if self.m_CurOpenedMailIndex == nil then
		return nil
	end

	local nextMailIndex = nil
	if self.m_CurOpenedMailIndex == 1 then  -- UI 删除最底的邮件
		nextMailIndex = 1  -- 显示上一封（即仍是最底的邮件）
	else
		nextMailIndex = self.m_CurOpenedMailIndex - 1
	end
	return nextMailIndex
end

return CMailCtrl