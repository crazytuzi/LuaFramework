EmailModel = BaseClass(LuaModel)
function  EmailModel:__init()
	self:ReSet()
end
function EmailModel:ReSet()
	self.emailList = {} -- 邮件列表
	self.emailNum = 0 -- 当前总数
	self.totalMail = 0 -- 后端总邮件量
	self.newMailNum = 0 -- 未读邮件数
	self.lastMailId = 0 -- 最近一封新邮件id
	self:SetEnter(false)
end

-- 新邮件通知
function EmailModel:NoticeNewMail()
	local tips =0
	local fujian = false
	for i,v in ipairs(self.emailList) do
		if v.haveAttachment == 1 and v.haveReceiveAttachment == 0 then
			fujian = true
			break
		end
	end
	if self.newMailNum > 0 or fujian then
		tips = 1 
	else
		tips = 0
	end
	GlobalDispatcher:Fire(EventName.NEWMAIL_NOTICE, tips)
end
-- 最近新邮件id
function EmailModel:SetLastMailId( id )
	self.lastMailId = id
	print("new id ==>> ", id)
	self.newMailNum = self.newMailNum + 1
	self:SetNum(self:GetNum() + 1)
	self:NoticeNewMail()
end
--读邮件 返回
function EmailModel:ReadMail(mailInbox)
	for i,v in ipairs(self.emailList) do
		if v.mailInboxID == mailInbox.mailInboxID and v.state ~= 1 then
			v.state = 1
			self.newMailNum = self.newMailNum - 1 -- 本地自减1
			self:Fire(EmailConst.GetEmailData, mailInbox.mailInboxID)
			if self.lastMailId == mailInbox.mailInboxID then
				self.lastMailId = 0
			end
		end
	end
	self:NoticeNewMail()
end
-- 获取邮件列表 分页
function EmailModel:UpdateMailList(msg)
	if msg then
		self.totalMail = msg.inboxMailNum or 0
		print("self.totalMail ==>> ", self.totalMail)
		self.totalMail = math.min(self.totalMail, 30)
		self.newMailNum = msg.newMailNum or 0
		SerialiseProtobufList( msg.inboxPageList, function ( item )
			local vo = {}
			vo.mailInboxID = item.mailInboxID
			vo.senderName = item.senderName
			vo.receiverID = item.receiverID
			vo.theme = item.theme
			vo.content = item.content
			vo.haveAttachment = item.haveAttachment
			vo.haveReceiveAttachment = item.haveReceiveAttachment
			vo.attachment = item.attachment
			vo.state = item.state
			vo.receiveTime = item.receiveTime
			vo.remainDays = item.remainDays
			table.insert(self.emailList, vo)
			-- print("总", #self.emailList, vo.theme)
		end)
		SortTableByKey( self.emailList, "mailInboxID", false ) -- 降序
		self.emailNum = #self.emailList
		self:Fire(EmailConst.UpdateEmailList)
		self:NoticeNewMail()
	end
end
--提取 附件
function EmailModel:ReceiveAttachment(id)
	for i,v in ipairs(self.emailList) do
		if v.mailInboxID == id then
			v.haveReceiveAttachment = 1
			if v.state ~= 1 then
				v.state = 1
				self.newMailNum = self.newMailNum - 1
			end
			self:Fire(EmailConst.GetEmailData, id)
			if self.lastMailId == id then
				self.lastMailId = 0
			end
		end
	end
	self:NoticeNewMail()
end

--删除邮件返回
function EmailModel:DeleteMail(id)
	--print("===ddddddeeeelll ==>> ", id)
	for i,v in ipairs(self.emailList) do
		if v.mailInboxID == id then
			table.remove(self.emailList,i)
			self.emailNum = self.emailNum - 1
			self.totalMail = self.totalMail - 1
			if v.state ~= 1 then
				self.newMailNum = self.newMailNum - 1
			end
			self:Fire(EmailConst.DelEmail, id)
			if self.lastMailId == id then
				self.lastMailId = 0
			end
			break
		end
	end
	self:NoticeNewMail()
	self:DispatchEvent(EmailConst.GetAfterDel)
end

function EmailModel:__delete()
	self.newMailNum = 0
	self.lastMailId = 0
	EmailModel.inst = nil
end
function EmailModel:GetInstance()
	if EmailModel.inst == nil then
		EmailModel.inst = EmailModel.New()		
	end
	return EmailModel.inst
end
--获取登录时总数量
function EmailModel:GetNum()
	return LoginModel:GetInstance():GetMailTotalNum()
end
function EmailModel:SetNum(num)
	LoginModel:GetInstance():SetMailTotalNum(num)
end
--获取当前数量
function EmailModel:GetCurNum()
	return self.totalMail or 0
end
function EmailModel:SetEnter(isEnter)
	self.isEnter = isEnter
end
function EmailModel:IsEnter()
	return self.isEnter
end
function EmailModel:ResetQuitPanel()
	self:SetEnter(false)
	self:SetNum(self:GetCurNum())
	self.emailList = {} -- 邮件列表
	self.emailNum = 0 -- 当前总数
end