------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
local BASE = require("logic/network/channel/i3k_channel");

	
	
function i3k_sbean.request_mail_syncsys_req(page)
	local mail =i3k_sbean.mail_syncsys_req.new()
	mail.page = page
	i3k_game_send_str_cmd(mail,i3k_sbean.mail_syncsys_res.getName())
end

-- 同步系统邮件	
--Packet:mail_syncsys_res
function i3k_sbean.mail_syncsys_res.handler(bean, res)
	g_i3k_ui_mgr:OpenUI(eUIID_Email)
	
	g_i3k_game_context:MailSaveSysMailData(bean.info.mails)
	g_i3k_game_context:MailSyncPageInfo(bean.info.pageNo, bean.info.pageCount, bean.info.unreadMailCount, bean.info.mailCount)
	if res.callback then
		res.callback(bean.info.unreadMailCount, res.sectUnreadCount)
	end
end


	
function i3k_sbean.request_mail_synctmp_req(pageNO)
	local syncTemp = i3k_sbean.mail_synctmp_req.new()
	syncTemp.pageNO = pageNO
	i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
end

-- 同步临时邮件	
--Packet:mail_synctmp_res
function i3k_sbean.mail_synctmp_res.handler(bean, res)
	if res.notSetData then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "setUnreadRedPoint", res.sysUnreadCount, bean.info.unreadMailCount, res.sectUnreadCount)
	else
		g_i3k_game_context:MailSaveTempMailData(bean.info.mails)
		g_i3k_game_context:MailSyncPageInfo(bean.info.pageNo, bean.info.pageCount, bean.info.unreadMailCount, bean.info.mailCount)
		if res.callback then
			res.callback()
		end
	end
	
	
end
--[[
function i3k_sbean.mail_read_res.handler(bean, res)
	local mail = bean.mail
	if mail then
		if res.state==1 then
			g_i3k_game_context:SyncMailState(mail, true)
		else
			g_i3k_game_context:SyncMailState(mail, false)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "setMailDetail", mail, res.oldState)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(145))
		if res.state==1 then
			local syncSys = i3k_sbean.mail_syncsys_req.new()
			syncSys.pageNO = res.page
			i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")
		else
			local syncTemp = i3k_sbean.mail_synctmp_req.new()
			syncTemp.pageNO = res.page
			i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
		end
	end
end
]]

-- 读系统邮件
--Packet:mail_readsys_res
function i3k_sbean.mail_readsys_res.handler(bean, res)
	local mail = bean.mail
	if mail then
		g_i3k_game_context:SyncMailState(mail, true)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "setMailDetail", mail, res.oldState)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(145))
		local syncSys = i3k_sbean.mail_syncsys_req.new()
		syncSys.pageNO = res.page
		i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")
	end
end

-- 读临时邮件
--Packet:mail_readtmp_res
function i3k_sbean.mail_readtmp_res.handler(bean, res)
	local mail = bean.mail
	if mail then
		g_i3k_game_context:SyncMailState(mail, false)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "setMailDetail", mail, res.oldState)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(145))
		local syncTemp = i3k_sbean.mail_synctmp_req.new()
		syncTemp.pageNO = res.page
		i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
	end
end

--[[
function i3k_sbean.mail_take_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "getAnnexCB", res.id)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end
]]

-- 取系统邮件附件
--Packet:mail_takesys_res
function i3k_sbean.mail_takesys_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "getAnnexCB", res.id)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end

-- 取临时邮件附件
--Packet:mail_taketmp_res
function i3k_sbean.mail_taketmp_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "getAnnexCB", res.id)
		g_i3k_game_context:setIsTempMailFull(false)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end

-- 取全部系统邮件附件
--Packet:mail_takeallsys_res
function i3k_sbean.mail_takeallsys_res.handler(bean, res)
	
	local leftMailCount = bean.leftMails
	if leftMailCount==0 then
		local tips = string.format("%s", "附件已经全部收入背包")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
	if res.callback then
		res.callback(res.page)
	end
	--[[g_i3k_game_context:MailGetAllAnnex()
	if leftMailCount==0 then
		
		local sysEmail = g_i3k_game_context:GetSysEmail()
		for i,v in pairs(sysEmail) do
			--if v[3] == 1 then
				sysEmail[i][3]=3
			--elseif v[3] == 0 then
				--sysEmail[i][3]=3
			--end
		end
		g_i3k_game_context:SetSysEmail(sysEmail)
		local emailUI = g_i3k_ui_mgr:GetUI(eUIID_Email)
		local emailScroll = emailUI:GetChildByVarName("emailScroll")
		local childCount = emailScroll:getChildrenCount()
		
		for i=1,childCount do
			local child = emailScroll:getChildAtIndex(i)
			local haveAnnex = child.vars.haveAnnex
			local state = child.vars.state
			local icon = child.vars.emailIcon
			icon:setImage("w#w_xin1.png")
			state:setImage("g#g_s1")
			--haveAnnex:hide()
			haveAnnex:disable()
		end
		local getAdditional = emailUI:GetChildByVarName("getAdditional")
		local getAdditionalWord = emailUI:GetChildByVarName("getWord")
		getAdditionalWord:disable()
		getAdditional:disable()--setTouchEnabled(false)
		local db = g_i3k_ui_mgr:GetUI(eUIID_DB)
		if db then
			db:updateMoney()
		end
		
		local unread = emailUI:GetChildByVarName("unread")
		unread:setText("未读信件:"..0)
		local haveUnread = emailUI:GetChildByVarName("haveUnread")
		if haveUnread then haveUnread:hide() end
		local fade = emailUI:GetChildByVarName("fade")
		if fade then fade:hide() end
	else
		local emailUI = g_i3k_ui_mgr:GetUI(eUIID_Email)
		local emailScroll = emailUI:GetChildByVarName("emailScroll")
		local getAdditional = emailUI:GetChildByVarName("getAdditional")
		local getAdditionalWord = emailUI:GetChildByVarName("getWord")
		local childCount = emailScroll:getChildrenCount()
		local sysEmail = g_i3k_game_context:GetSysEmail()
		local nowPage = emailUI._currentPageSys
		local nowMailId
		if emailUI._emailNow then
			nowMailId= emailUI._emailNow[1]
		end
		if leftMailCount>(nowPage-1)*5 then--如果当前为第三页，判断比两页总数多不多，
			if leftMailCount>nowPage*5 then--判断比三页总数多不多
				--如果还多，当前页不用管
			else--如果分割点就在当前页，判断第几个
				local count = leftMailCount%5--判断这页有几个没取的
				for i,v in pairs(sysEmail) do
					if i>count then
						if nowMailId and v[1]==nowMailId then
							getAdditionalWord:disable()
							getAdditional:disable()
						end
						sysEmail[i][3]=3
					end
				end
			end
		else
			getAdditionalWord:disable()
			getAdditional:disable()
			for i,v in pairs(sysEmail) do
				sysEmail[i][3]=3
			end
		end
		g_i3k_game_context:SetSysEmail(sysEmail)
		
		for i=1,childCount do
			if i>leftMailCount then
				local child = emailScroll:getChildAtIndex(i)
				local haveAnnex = child.vars.haveAnnex
				local state = child.vars.state
				local icon = child.vars.emailIcon
				icon:setImage("w#w_xin1.png")
				state:setImage("g#g_s1")
				--haveAnnex:hide()
				haveAnnex:disable()
			end
		end
		
		local db = g_i3k_ui_mgr:GetUI(eUIID_DB)
		if db then
			db:updateMoney()
		end
		
		local unread = emailUI:GetChildByVarName("unread")
		unread:setText("未读信件:"..leftMailCount)
		local haveUnread = emailUI:GetChildByVarName("haveUnread")
		if haveUnread then haveUnread:show() end
		if leftMailCount<=childCount then
			local fade = emailUI:GetChildByVarName("fade")
			if fade then fade:hide() end
		end
		
		
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end--]]
end



-- 取全部临时邮件附件
--Packet:mail_takealltmp_res
function i3k_sbean.mail_takealltmp_res.handler(bean, res)
	local leftMailCount = bean.leftMails
	if leftMailCount < TEMP_EMAIL_COUNT then
		g_i3k_game_context:setIsTempMailFull(false)
	end
	if leftMailCount==0 then
		local tips = string.format("%s", "附件已经全部收入背包")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
	if res.callback then
		res.callback(res.page)
	end
end

function i3k_sbean.role_tempmail_full.handler(bean)
	g_i3k_game_context:setIsTempMailFull(true)
end
--同步帮派邮件
function i3k_sbean.mail_syncsect(pageNO, callback)
	local data = i3k_sbean.mail_syncsect_req.new()
	data.pageNO = pageNO
	data.callback = callback
	i3k_game_send_str_cmd(data, "mail_syncsect_res")
end
function i3k_sbean.mail_syncsect_res.handler(res, req)
	if res.info then
		if req.callback then
			req.callback(res.info.unreadMailCount)
		else
			g_i3k_game_context:MailSaveSectMailData(res.info.mails)
			g_i3k_game_context:MailSyncPageInfo(res.info.pageNo, res.info.pageCount, res.info.unreadMailCount, res.info.mailCount)
		end
	end
end
--读帮派邮件
function i3k_sbean.mail_readsect(mailId, state, page)
	local data = i3k_sbean.mail_readsect_req.new()
	data.mailId = mailId
	data.oldState = state
	data.page = page
	i3k_game_send_str_cmd(data, "mail_readsect_res")
end
function i3k_sbean.mail_readsect_res.handler(res, req)
	local mail = res.mail
	if mail then
		g_i3k_game_context:SyncSectState(mail, false)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Email, "setMailDetail", mail, req.oldState)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(145))
		i3k_sbean.mail_syncsect(req.page)
	end
end
--帮派邮件删除--暂无删除功能，此协议没用到
function i3k_sbean.mail_delsect(mailId)
	local data = i3k_sbean.mail_delsect_req.new()
	data.mailId = mailId
	i3k_game_send_str_cmd(data, "mail_delsect_res")
end
function i3k_sbean.mail_delsect_res.handler(res, req)
	if res.mailId then
	end
end
