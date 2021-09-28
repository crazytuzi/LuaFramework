-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_l_func = i3k_class("wnd_l_func", ui.wnd_base)

function wnd_l_func:ctor()

end

function wnd_l_func:configure()
	self.haveNewMail = self._layout.vars.haveNewMail

	--self.email = self._layout.vars.email
	self.task = self._layout.vars.task_btn

	self.checkin = self._layout.vars.sign_btn

	self.dailyActivity = self._layout.vars.daily_activity

	--self.email:onClick(self, self.ToEmail)		--主界面邮件移除
	self.task:onClick(self,self.onTask)

	self.checkin:onClick(self,self.onSignIn)

	self._layout.vars.auction:onClick(self, self.toAuction)

	self.dailyActivity:onClick(self,self.onDailyActivity)
end

--[[
function wnd_l_func:ToEmail(sender)
	local syncSys = i3k_sbean.mail_syncsys_req.new()
	syncSys.pageNO = 1
	syncSys.callback = function (sysUnreadCount)
		local syncTemp = i3k_sbean.mail_synctmp_req.new()
		syncTemp.pageNO = 1
		syncTemp.notSetData = true
		syncTemp.sysUnreadCount = sysUnreadCount
		i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
	end
	i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")
	g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CAN_RECEIVE_NEW_MAIL)
end
]]
function wnd_l_func:onTask(sender)
	g_i3k_logic:OpenTaskUI()
end

function wnd_l_func:onSignIn(sender)
	i3k_sbean.checkin_sync()
end

----[[馈赠
function wnd_l_func:onDailyActivity(sender)
	local cur_level = g_i3k_game_context:GetLevel()
	if cur_level >= i3k_db_lucky_wheel.needLvl then
		g_i3k_logic:OpenDailyActivityUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(358,i3k_db_lucky_wheel.needLvl))
	end

end

function wnd_l_func:toAuction(sender)
	local openDay = i3k_game_get_server_open_day()
	local nowDay = g_i3k_get_day(i3k_game_get_time())
	local needLevel = i3k_db_common.aboutAuction.needLevel
	local hero = i3k_game_get_player_hero()
	if hero._lvl<needLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(242, needLevel))
	--elseif nowDay-openDay<i3k_db_common.aboutAuction.coolDay then
		--local str = string.format("%s", "服务器开服3天内不允许进入寄售行")
		--g_i3k_ui_mgr:PopupTipMessage(str)
	else
		local callback = function (itemType)
			g_i3k_ui_mgr:RefreshUI(eUIID_Auction, itemType)
		end
		i3k_sbean.sync_auction(1, "", 1, 2, 0, 0, 0, callback)
	end
end

function wnd_l_func:updateServerNotices()
	self:updateNewMailNotice()
	self:updateFuliNotice()
	self:updateLuckyWheelNotice()
end

function wnd_l_func:updateNewMailNotice()
	--self.haveNewMail:setVisible(g_i3k_game_context:testNotice(g_NOTICE_TYPE_CAN_RECEIVE_NEW_MAIL))
end

function wnd_l_func:updateFuliNotice()
	--[[
	if g_i3k_game_context:SetDynamicActivityRedPoint(g_NOTICE_TYPE_CAN_REWARD_Dynamic_Activity ) then
		self._layout.anis.c_fuli.play()
	else
		self._layout.anis.c_fuli.stop()
	end
	--]]
end

function wnd_l_func:updateSignRedPoint()
	--[[
	if g_i3k_game_context:SetSignRedPoint(g_NOTICE_TYPE_CAN_REWARD_SING_IN) then
		self._layout.anis.c_qiandao.play()
	else
		self._layout.anis.c_qiandao.stop()
	end
	--]]
end

function wnd_l_func:updateTaskRedPoint()
	local is_have = g_i3k_game_context:petTaskRedPoint()
	local redPoint = self._layout.vars.taskRedPoint
	if is_have then
		redPoint:show()
	else
		redPoint:hide()
	end
end
--幸运转盘红点
function wnd_l_func:updateLuckyWheelNotice()
	if g_i3k_game_context:SetLuckyWheelRedPoint(g_NOTICE_TYPE_CAN_REWARD_LUCKY_WHEEL) then

		self._layout.anis.c_zhuanpan.play()
	else
		self._layout.anis.c_zhuanpan.stop()

	end
end

function wnd_l_func:refresh()
	self:updateNewMailNotice()
	self:updateFuliNotice()
	self:updateSignRedPoint()
	self:updateTaskRedPoint()
	self:updateLuckyWheelNotice()
end

function wnd_create(layout)
	local wnd = wnd_l_func.new()
	wnd:create(layout)
	return wnd;
end
