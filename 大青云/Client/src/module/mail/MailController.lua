--[[
邮件管理
liyuan
2014年9月28日10:33:06
]]
_G.MailController = setmetatable({},{__index=IController})

MailController.name = "MailController";

function MailController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_GetMailResult,self,self.OnMailListResult);
	MsgManager:RegisterCallBack(MsgType.WC_OpenMailResult,self,self.OnOpenMailResult);
	MsgManager:RegisterCallBack(MsgType.WC_GetMailItemResult,self,self.OnGetMailItemResult);
	MsgManager:RegisterCallBack(MsgType.WC_DelMail,self,self.OnDelMailResult);
	MsgManager:RegisterCallBack(MsgType.WC_NotifyMail,self,self.OnNotifyMail);
end

---------------------------以下为客户端发送消息-----------------------------
-- 客户端请求：请求所有邮件列表
function MailController:GetMailList()
	--SpiritsUtil:Print('客户端请求：请求所有邮件列表');
	local msg = ReqGetMailList:new();
	MsgManager:Send(msg)
end

-- 客户端请求：请求打开邮件
function MailController:GetMialById(mailid)
	--SpiritsUtil:Print('客户端请求：请求打开邮件'..mailid);
	local msg = ReqOpenMail:new();
	msg.mailid = mailid
	MsgManager:Send(msg)
end

-- 客户端请求：请求领取附件
function MailController:GetItem(mlist)
	--SpiritsUtil:Print('客户端请求：请求领取附件');
	--SpiritsUtil:Trace(mlist);
	local msg = ReqMailItem:new();
	local sendList = {}
	for i, mailid in pairs(mlist) do 
		local mail = {}
		mail.mailid = mailid
		table.push(sendList, mail)
	end
	--SpiritsUtil:Trace(sendList);
	msg.MailList = sendList
	MsgManager:Send(msg)
end

-- 客户端请求：请求删除邮件
function MailController:ReqDelMail(mlist)
	--SpiritsUtil:Print('客户端请求：请求删除邮件');
	local msg = ReqDelMail:new();
	local sendList = {}
	for i, mailid in pairs(mlist) do 
		local mail = {}
		mail.mailid = mailid
		table.push(sendList, mail)
	end
	--SpiritsUtil:Trace(sendList);
	msg.MailList = sendList
	MsgManager:Send(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------

--服务器返回: 所有邮件列表
function MailController:OnMailListResult(msg)
	--SpiritsUtil:Print('服务器返回: 所有邮件列表');
	--SpiritsUtil:Trace(msg);
	MailModel:UpdateMailList(msg.MailList)
end

--服务器返回: 返回打开邮件
function MailController:OnOpenMailResult(msg)
	--SpiritsUtil:Print('服务器返回: 返回打开邮件');
	--SpiritsUtil:Trace(msg);
	MailModel:OpenMail(msg)
end

--服务器返回: 返回领取附件
function MailController:OnGetMailItemResult(msg)
	--SpiritsUtil:Print('服务器返回: 返回领取附件');
	--SpiritsUtil:Trace(msg);
	
	MailModel:GetMailItem(msg.MailList)
end

--服务器返回: 返回删除邮件
function MailController:OnDelMailResult(msg)
	--SpiritsUtil:Print('服务器返回: 返回删除邮件');
	--SpiritsUtil:Trace(msg);
	MailModel:DelMail(msg.MailList)
end

--服务器返回: 邮件提醒
function MailController:OnNotifyMail(msg)
	--SpiritsUtil:Print('服务器返回: 邮件提醒');
	--SpiritsUtil:Trace(msg);
	
	MailModel.MailInitNum = msg.mailcount
	Notifier:sendNotification(NotifyConsts.MailNumChanged,{num=msg.mailcount});
	
	local vo = {}
	vo.mailcount = msg.mailcount
	RemindController:AddRemind(RemindConsts.Type_NewMail, vo )
end


























