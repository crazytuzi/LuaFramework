require("scripts/game/mail/mail_data")
require("scripts/game/mail/mail_view")
MailCtrl = MailCtrl or BaseClass(BaseController)

function MailCtrl:__init()
	if MailCtrl.Instance then
		ErrorLog("[MailCtrl]:Attempt to create singleton twice!")
	end
	MailCtrl.Instance = self

	self.data = MailData.New()
	self.view = MailView.New(ViewDef.Mail)
	self:RegisterAllProtocols()
	-- GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecieveMail, self))

	self:RegisterAllRemind()
end

function MailCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

    MailCtrl.Instance = nil
end

function MailCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMailInfo, "OnMailInfo")
	self:RegisterProtocol(SCMailDelAck, "OnMailDelAck")
	self:RegisterProtocol(SCMailReadAck, "OnMailReadAck")
	self:RegisterProtocol(SCMailGetRewardAck, "OnMailGetRewardAck")
	self:RegisterProtocol(SCMailLoading, "OnMailLoading")
	self:RegisterProtocol(SCGetALLMailReward, "OnGetALLMailReward")
end

function MailCtrl:RegisterAllRemind()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.Mail)
end

-- 接收 添加邮件结果(64, 1)
function MailCtrl:OnMailInfo(protocol)
	self.data:AddMail(protocol)
	self.view:Flush()
	self:MailDataChangeCallBack()
end

function MailCtrl:OnMailDelAck(protocol)
	self.data:DeleteMail(protocol)
	self.view:Flush()
	self:MailDataChangeCallBack()
end

function MailCtrl:OnMailReadAck(protocol)
	self.data:ReadMail(protocol)
	self.view:Flush()
	self:MailDataChangeCallBack()
end

function MailCtrl:OnMailGetRewardAck(protocol)
	if protocol.mail_id == nil then return end
	self.data:GetRewardMail(protocol)
	self.view:Flush()
	self:MailDataChangeCallBack()
end

function MailCtrl:OnGetALLMailReward(protocol)
	self.data:GetAllRewardMail(protocol)
	self.view:Flush()
	self:MailDataChangeCallBack()
end

--加载邮件
function MailCtrl:OnMailLoading(protocol)
	self.data:GetAllMail(protocol)
	self.view:Flush()
	self:MailDataChangeCallBack()
end

--读取邮件内容请求
function MailCtrl:SendReadMailReq(mail_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReadMailReq)
	protocol.mail_id = mail_id
	protocol:EncodeAndSend()
end

--删除邮件请求
function MailCtrl:SendDeleteMailReq(mail_id_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMailDelReq)
	protocol.mail_id_list = mail_id_list
	protocol:EncodeAndSend()
end

--提取奖励请求
function MailCtrl:SendMailGetRewardReq(mail_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMailGetRewardReq)
	protocol.mail_id = mail_id
	protocol:EncodeAndSend()
end

--加载邮件请求
function MailCtrl:SendAllMailAddReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSAllMailAddReq)
	protocol:EncodeAndSend()
end

--提取所有邮件请求
function MailCtrl:SendAllMailAcceptReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSAllMailAcceptReq)
	protocol:EncodeAndSend()
end

-- function MailCtrl:OnRecieveMail()
-- 	self:SendAllMailAddReq()
-- end

function MailCtrl:MailDataChangeCallBack()
	if not self.data:GetMailRemindNum() or self.data:GetMailRemindNum() <= 0 then
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.MAIL, 0)
	else
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.MAIL, self.data:GetMailRemindNum(), function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Mail)
		end)
	end

	RemindManager.Instance:DoRemindDelayTime(RemindName.Mail)
end

function MailCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.Mail then
		return self.data:GetMailRemindNum() or 0
	end
end