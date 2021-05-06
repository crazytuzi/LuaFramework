module(..., package.seeall)

--GS2C--

function GS2CLoginMail(pbdata)
	local simpleinfo = pbdata.simpleinfo
	--todo
	g_MailCtrl:InitLoginMail(simpleinfo)
end

function GS2CMailInfo(pbdata)
	local mailid = pbdata.mailid --邮件id
	local title = pbdata.title --邮件标题
	local context = pbdata.context --邮件内容
	local keeptime = pbdata.keeptime --保存时间
	local validtime = pbdata.validtime --到期时间
	local pid = pbdata.pid --发件人id
	local name = pbdata.name --发件人名字
	local opened = pbdata.opened --是否打开过，1.打开过，0.没有
	local hasattach = pbdata.hasattach --是否有附件，1.有，0.没有，2.领取过
	local attachs = pbdata.attachs --附件
	local subject = pbdata.subject
	--todo
	g_MailCtrl:UpdateMailInfo(pbdata)
end

function GS2CDelMail(pbdata)
	local mailid = pbdata.mailid --邮件id
	--todo
	g_MailCtrl:DelMail(mailid)
end

function GS2CAddMail(pbdata)
	local simpleinfo = pbdata.simpleinfo
	--todo
	g_MailCtrl:AddMail(simpleinfo)
end

function GS2CDelAttach(pbdata)
	local mailid = pbdata.mailid --邮件id
	--todo
	g_MailCtrl:RetrieveAttach(mailid)
end

function GS2CMailOpened(pbdata)
	local mailids = pbdata.mailids --邮件id
	--todo
	g_MailCtrl:OpenMails(mailids)
end


--C2GS--

function C2GSOpenMail(mailid)
	local t = {
		mailid = mailid,
	}
	g_NetCtrl:Send("mail", "C2GSOpenMail", t)
end

function C2GSAcceptAttach(mailid)
	local t = {
		mailid = mailid,
	}
	g_NetCtrl:Send("mail", "C2GSAcceptAttach", t)
end

function C2GSAcceptAllAttach()
	local t = {
	}
	g_NetCtrl:Send("mail", "C2GSAcceptAllAttach", t)
end

function C2GSDeleteMail(mailids)
	local t = {
		mailids = mailids,
	}
	g_NetCtrl:Send("mail", "C2GSDeleteMail", t)
end

function C2GSDeleteAllMail()
	local t = {
	}
	g_NetCtrl:Send("mail", "C2GSDeleteAllMail", t)
end

