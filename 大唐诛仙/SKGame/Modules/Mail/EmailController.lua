RegistModules("Mail/EmailConst")
RegistModules("Mail/EmailModel")
RegistModules("Mail/View/MailItem")
RegistModules("Mail/View/MailPanel")
RegistModules("Mail/EmailMainPanel")

EmailController = BaseClass(LuaController)
-- 邮件控制器
function EmailController:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()	-- 协议注册
end

-- 配置
function EmailController:Config()
	self.model = EmailModel:GetInstance()
end

-- 事件
function EmailController:InitEvent()
	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
			self.model:ReSet()
		end)
	end
end

-- 协议
function EmailController:RegistProto()
	self:RegistProtocal("S_NewMail")
	self:RegistProtocal("S_ReadMail")
	self:RegistProtocal("S_GetMailPageList")
	self:RegistProtocal("S_ReceiveAttachment")
	self:RegistProtocal("S_DeleteMail")
end

-- 通知有新邮件
function EmailController:S_NewMail(buff)
	local msg = self:ParseMsg(mail_pb.S_NewMail(),buff)
	self.model:SetLastMailId(msg.mailInboxID)
end
-- 读邮件 返回
function EmailController:S_ReadMail(buff)
	local msg = self:ParseMsg(mail_pb.S_ReadMail(),buff)
	self.model:ReadMail(msg.mailInbox)
end
-- 获取邮件列表 分页
function EmailController:S_GetMailPageList( buff )
	local msg = self:ParseMsg(mail_pb.S_GetMailPageList(),buff)
	self.model:UpdateMailList(msg)
end
-- 领取邮件附件后返回
function EmailController:S_ReceiveAttachment( buff )
	local msg = self:ParseMsg(mail_pb.S_ReceiveAttachment(),buff)
	self.model:ReceiveAttachment(msg.mailInboxID)
end
--删除后更新返回
function EmailController:S_DeleteMail( buff )
	local msg = self:ParseMsg(mail_pb.S_DeleteMail(),buff)
	self.model:DeleteMail(msg.mailInboxID)
end

-- 根据收件编号 显示已读
function EmailController:C_ReadMail( id )
	local msg = mail_pb.C_ReadMail()
	msg.mailInboxID = id
	self:SendMsg("C_ReadMail",msg)
end
-- 请求得到邮件列表 分页
function EmailController:C_GetMailPageList()
	local msg = mail_pb.C_GetMailPageList()
	-- print(self.model:GetCurNum())
	-- print(self.model.emailNum)
	local num = self.model:GetCurNum() - self.model.emailNum - EmailConst.Offset + 1
	if not self.model:IsEnter() then
		self.model:SetEnter(true)
		num = self.model:GetNum() - EmailConst.Offset + 1
	end
	num = math.min(21, num)
	msg.start = math.max(0, num)
	--print("start ==>> ", msg.start)
	local offset = math.min(math.max(0, num + EmailConst.Offset - 1), EmailConst.Offset)
	--print("offset ==>> ", offset)
	msg.offset = offset -- 每次请求数量
	self:SendMsg("C_GetMailPageList", msg)
end
-- 根据收件箱编号提取物品
function EmailController:C_ReceiveAttachment( id )
	local msg = mail_pb.C_ReceiveAttachment()
	msg.mailInboxID = id
	self:SendMsg("C_ReceiveAttachment",msg)
end
-- 根据收件箱编号删除邮件
function EmailController:C_DeleteMail( id )
	local msg = mail_pb.C_DeleteMail()
	msg.mailInboxID = id
	self:SendMsg("C_DeleteMail",msg)
end

-- 面板
function EmailController:Open()
	self:GetMainPanel():Open()
	-- if self.model.emailNum < EmailConst.Offset  then
		self:C_GetMailPageList()
	-- end
end
function EmailController:Close()
	self:GetMainPanel():Close()
end
-- 获取主面板
function EmailController:GetMainPanel()
	if not self:IsExistView() then
		self.view = EmailMainPanel.New()
	end
	return self.view
end
-- 判断主面板是否存在
function EmailController:IsExistView()
	return self.view and self.view.isInited
end
function EmailController:GetInstance()
	if EmailController.inst == nil then
		EmailController.inst = EmailController.New()
	end
	return EmailController.inst
end
function EmailController:__delete()
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	EmailController.inst = nil
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
end

--弹邮件过多窗口
function EmailController:ShowTooMuchTips()
	if not SceneModel:GetInstance():IsMain() then return end
	if self.model and self.model:GetNum() >= 25 then
		UIMgr.Win_Alter("温馨提示", "邮件太多,请尽快清理\n超过25封将自动删除最早的邮件", "确定", nil)
	end
end