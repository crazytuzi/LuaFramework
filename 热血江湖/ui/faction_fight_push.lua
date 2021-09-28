-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_fight_push = i3k_class("wnd_faction_fight_push", ui.wnd_base)


local pushmap =
{
	[g_FACTION_FIGHT_PUSH_MATCHING] = {title = "帮派战报名", msg = "您所在的分堂已报名帮派战,请做好战斗准备", desc1 = "",
			desc2 = "对战信息:匹配中", desc3 = "", btnname = "确定", btnState = 0},-- 排队中

	[g_FACTION_FIGHT_PUSH_WAITING] = {title = "帮派战报名", msg = "您所在的分堂已报名帮派战,请做好战斗准备", desc1 = "",
			desc2 = "对战信息:%s分堂", desc3 = "", btnname = "确定", btnState = 0},-- 匹配成功

	[g_FACTION_FIGHT_PUSH_FIGHTING] = {title = "帮战进行中", msg = "您所在的分堂正在战斗中,请立刻进入战场", desc1 = "",
			desc2 = "对战信息:%s分堂", desc3 = "", btnname = "进入战场", btnState = 1},-- 进行中

	[g_FACTION_FIGHT_PUSH_DRAW] = {title = "帮派战结束", msg = "您所在分堂战斗已结束,您在本次战斗中获得平局,目前处于宝箱采集阶段", desc1 = "帮战结束后将无法再次进入帮派战场",
			desc2 = "对战信息:%s\n对战结果:平局", desc3 = "", btnname = "进入战场", btnState = 1},-- 平局

	[g_FACTION_FIGHT_PUSH_WIN] = {title = "帮派战结束", msg = "您所在分堂战斗已结束,恭喜您在本次战斗中获得胜利,目前处于宝箱采集阶段", desc1 = "帮战结束后将无法再次进入帮派战场",
			desc2 = "对战信息:%s\n对战结果:胜利", desc3 = "", btnname = "进入战场", btnState = 1},-- 胜利

	[g_FACTION_FIGHT_PUSH_FAILED] = {title = "帮派战结束", msg = "您所在分堂战斗已结束,您在本次战斗中获得失败,目前处于宝箱采集阶段", desc1 = "帮战结束后将无法再次进入帮派战场",
			desc2 = "对战信息:%s\n对战结果:失败", desc3 = "", btnname = "进入战场", btnState = 1},-- 失败

	[g_FACTION_FIGHT_PUSH_BYE] = {title = "帮战进行中", msg = "您所在的分堂本轮匹配轮空", desc1 = "",
			desc2 = "匹配轮空可获得轮空奖励,请注意查收邮件", desc3 = "", btnname = "确定", btnState = 0},-- 轮空

	[g_FACTION_FIGHT_PUSH_END] = {title = "帮派战结束", msg = "您所在分堂战斗已结束", desc1 = "帮战结束后将无法再次进入帮派战场",
			desc2 = "对战信息:%s", desc3 = "", btnname = "进入战场", btnState = 1},-- 结束

	[g_FACTION_FIGHT_PUSH_GET_READY] = {title = "帮派战预推送", msg = "帮派战将在%s正式开启报名,请做好战斗准备", desc1 = "加入分堂方可参与帮派战",
			desc2 = "加入帮派%s小时方可加入分堂", desc3 = "", btnname = "确定", btnState = 0},-- 预推送

	[g_FACTION_FIGHT_PUSH_NO_FENTANG] = {title = "帮派战预推送", msg = "您未加入【分堂/帮派】,无法参与帮派战!", desc1 = "加入分堂方可参与帮派战",
			desc2 = "加入帮派%s小时方可加入分堂", desc3 = "", btnname = "确定", btnState = 0},-- 未报名,无分堂或帮派

	[g_FACTION_FIGHT_PUSH_NO_MATCH] = {title = "帮派战报名", msg = "您所在的分堂尚未报名,请联系堂主报名!", desc1 = "",
			desc2 = "对战信息:尚无对手", desc3 = "", btnname = "确定", btnState = 0},-- 未报名,有分堂
}

local refreshTable =
{
	[g_FACTION_FIGHT_PUSH_MATCHING] 	= {func = "CountMatch"},
	[g_FACTION_FIGHT_PUSH_WAITING] 		= {func = "CountMatch"},
	[g_FACTION_FIGHT_PUSH_FIGHTING] 	= {func = "CountBattle"},
	[g_FACTION_FIGHT_PUSH_BYE] 			= {func = "CountLunkong"},
	[g_FACTION_FIGHT_PUSH_END] 			= {func = "CountEndPush"},
	[g_FACTION_FIGHT_PUSH_GET_READY] 	= {func = "CountPrePush"},
	[g_FACTION_FIGHT_PUSH_NO_MATCH] 	= {func = "CountMatch"},
	[g_FACTION_FIGHT_PUSH_DRAW]			= {func = "CountBattle"},
	[g_FACTION_FIGHT_PUSH_WIN]			= {func = "CountBattle"},
	[g_FACTION_FIGHT_PUSH_FAILED]		= {func = "CountBattle"},
}

function wnd_faction_fight_push:ctor()
	--self._data = {}
	self._state = g_FACTION_FIGHT_PUSH_NO_MATCH -- default state
	self._matchGroup = {}
	self._timeCounter = 0
end

function wnd_faction_fight_push:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.close)
end

function wnd_faction_fight_push:refresh(data)
	--local widgets = self._layout.vars
	self:set_msg(data)
end

------------------------------
-- check state functions



function wnd_faction_fight_push:set_msg(data)
	local widgets = self._layout.vars
	self._push_widgets = self._layout.vars
	if data.status then
		self._state = data.status.curStatus
		self._matchGroup = data.status.matchGroup
	else
		local roleId = g_i3k_game_context:GetRoleId()
		if g_i3k_game_context:isInFactionFightGroup(roleId) then
			self._state = g_FACTION_FIGHT_PUSH_NO_MATCH
		else
			self._state = 9
		end
	end

	if self._state == g_FACTION_FIGHT_PUSH_GET_READY then
		widgets.msg:setText(string.format(pushmap[self._state].msg, i3k_db_faction_fight_cfg.timebucket[1].applytime))
	else
		widgets.msg:setText(pushmap[self._state].msg)
	end

	if self._state == g_FACTION_FIGHT_PUSH_GET_READY or self._state == 9 then
		widgets.desc2:setText(string.format(pushmap[self._state].desc2, math.floor(i3k_db_faction_fightgroup.common.time/3600)))
	elseif self._state == 0 or self._state == 6 or self._state == g_FACTION_FIGHT_PUSH_NO_MATCH then
		widgets.desc2:setText(pushmap[self._state].desc2)
	else
		widgets.desc2:setText(string.format(pushmap[self._state].desc2, self._matchGroup.overview.groupName))
	end
	widgets.desc1:setText(pushmap[self._state].desc1)
	widgets.title:setText(pushmap[self._state].title)
	widgets.desc3:setText(pushmap[self._state].desc3)
	widgets.btnName:setText(pushmap[self._state].btnname)
	local btnState = pushmap[self._state].btnState
	widgets.ok:onClick(self, self.enter, btnState)-- 按钮状态,0表示确定,1表示进入战场
end

function wnd_faction_fight_push:enter(sender, btn_state)
	if btn_state == 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionFightPush)
	else
		local groupId = g_i3k_game_context:getFightGroupId()
		local fun = function()
			i3k_sbean.enter_sectwar(groupId)
		end
		g_i3k_game_context:CheckMulHorse(fun)
	end
end

function wnd_faction_fight_push:close(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightPush)
end

function wnd_faction_fight_push:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 1 then
		self:checkStates(dTime)
		self._timeCounter = 0
	end
end

function wnd_faction_fight_push:checkStates(dTime)
	if self:checkNeedRefreshTime(self._state)then
		local func = refreshTable[self._state].func
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionFightPush, func)
	end
end

-- 检查满足开启的日期(满足星期) 暂时这个方法没有用到
function wnd_faction_fight_push:checkWeek()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	for _,t in ipairs(i3k_db_faction_fight_cfg.commonrule.openday) do
		if t == week then
			return true
		end
	end
	return false
end

------------------------------------------

-- 检查需要刷新时间的状态
function wnd_faction_fight_push:checkNeedRefreshTime(state)
	return refreshTable[state]
end

function wnd_faction_fight_push:CountMatch()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	for i = 1, #i3k_db_faction_fight_cfg.timebucket do
		local starttime = string.split(i3k_db_faction_fight_cfg.timebucket[i].applytime, ":")
		local overtime = string.split(i3k_db_faction_fight_cfg.timebucket[i].beginfight, ":")
		local overfight = string.split(i3k_db_faction_fight_cfg.timebucket[i].endfight, ":")
		local opentime = os.time({year = year, month = month, day = day, hour = starttime[1], min = starttime[2], sec = starttime[3]})
		local closetime = os.time({year = year, month = month, day = day, hour = overtime[1], min = overtime[2], sec = overtime[3]})
		local closefight = os.time({year = year, month = month, day = day, hour = overfight[1], min = overfight[2], sec = overfight[3]})
		if timeStamp == math.modf(closetime) or timeStamp == math.modf(closefight) then
			i3k_sbean.sect_fight_group_cur_status(function(data)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush, data)
			end)
		elseif timeStamp > opentime and timeStamp < closetime then
			self._push_widgets.desc3:setText(string.format("报名倒计时:%s", i3k_get_time_show_text(closetime - timeStamp)))
			break
		elseif	timeStamp > closetime and timeStamp < closefight then
			if i ~= #i3k_db_faction_fight_cfg.timebucket then
				self._push_widgets.desc3:setText(string.format("下一轮开启:%s", i3k_get_time_show_text(closefight - timeStamp)))
				break
			else
				self._push_widgets.desc3:setText(string.format("最后一轮结束:%s", i3k_get_time_show_text(closefight - timeStamp)))
				break
			end
		end
	end
	local endTime = string.split(i3k_db_faction_fight_cfg.timebucket[3].endfight, ":")
	local allEnd = os.time({year = year, month = month, day = day, hour = endTime[1], min = endTime[2], sec = endTime[3]})
	if timeStamp > allEnd + i3k_db_faction_fight_cfg.commonrule.pushEnd then
		self._push_widgets.desc2:setText("")
		self._push_widgets.desc3:setText(string.format("推送结束倒计时:%s", i3k_get_time_show_text(allEnd + i3k_db_faction_fight_cfg.commonrule.pushEnd - timeStamp)))
		g_i3k_ui_mgr:CloseUI(eUIID_FactionFightPush)
	end
end
function wnd_faction_fight_push:CountLunkong()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	for i = 2 ,#i3k_db_faction_fight_cfg.timebucket do
		local starttime = string.split(i3k_db_faction_fight_cfg.timebucket[i].applytime, ":")
		local opentime = os.time({year = year, month = month, day = day, hour = starttime[1], min = starttime[2], sec = starttime[3]})
		if timeStamp == math.modf(opentime) then
			i3k_sbean.sect_fight_group_cur_status(function(data)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush, data)
			end)
		elseif timeStamp < opentime then
			self._push_widgets.desc3:setText(string.format("下一轮开启:%s", i3k_get_time_show_text(opentime - timeStamp)))
			break
		end
	end
end
function wnd_faction_fight_push:CountPrePush()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local starttime = string.split(i3k_db_faction_fight_cfg.timebucket[1].applytime, ":")
	local opentime = os.time({year = year, month = month, day = day, hour = starttime[1], min = starttime[2], sec = starttime[3]})
	if timeStamp == math.modf(opentime) then
		i3k_sbean.sect_fight_group_cur_status(function(data)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush, data)
		end)
	elseif timeStamp < opentime then
		self._push_widgets.desc3:setText(string.format("开启倒计时:%s", i3k_get_time_show_text(opentime - timeStamp)))
	end
end
function wnd_faction_fight_push:CountEndPush()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local overtime = string.split(i3k_db_faction_fight_cfg.timebucket[3].endfight, ":")
	local closetime = os.time({year = year, month = month, day = day, hour = overtime[1], min = overtime[2], sec = overtime[3]})
	if timeStamp < closetime + i3k_db_faction_fight_cfg.commonrule.pushEnd then
		self._push_widgets.desc3:setText(string.format("推送结束倒计时:%s", i3k_get_time_show_text(closetime + i3k_db_faction_fight_cfg.commonrule.pushEnd - timeStamp)))
		g_i3k_ui_mgr:CloseUI(eUIID_FactionFightPush)
	end
end
function wnd_faction_fight_push:CountBattle()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	for i = 1, #i3k_db_faction_fight_cfg.timebucket do
		local starttime = string.split(i3k_db_faction_fight_cfg.timebucket[i].beginfight, ":")
		local overtime = string.split(i3k_db_faction_fight_cfg.timebucket[i].endfight, ":")
		local opentime = os.time({year = year, month = month, day = day, hour = starttime[1], min = starttime[2], sec = starttime[3]})
		local closetime = os.time({year = year, month = month, day = day, hour = overtime[1], min = overtime[2], sec = overtime[3]})
		if timeStamp == math.modf(closetime) then
			i3k_sbean.sect_fight_group_cur_status(function(data)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush, data)
			end)
		elseif timeStamp > opentime and timeStamp < closetime then
			self._push_widgets.desc3:setText(string.format("战场倒计时:%s", i3k_get_time_show_text(closetime - timeStamp)))
			break
		end
	end
end
-------------------------------------------------


function wnd_create(layout, ...)
	local wnd = wnd_faction_fight_push.new()
	wnd:create(layout, ...)
	return wnd;
end
