-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_fight_push_result = i3k_class("wnd_faction_fight_push_result", ui.wnd_base)

local push_result = {
	[g_FACTION_FIGHT_PUSH_DRAW] = {title = "帮派战结束", msg = "您所在分堂战斗已结束,您在本次战斗中获得失败,目前处于宝箱采集阶段", desc1 = "帮战结束后将无法再次进入帮派战场",
			 desc3 = "", btnname = "进入战场",},-- 平局
	
	[g_FACTION_FIGHT_PUSH_WIN] = {title = "帮派战结束", msg = "您所在分堂战斗已结束,恭喜您在本次战斗中获得胜利,目前处于宝箱采集阶段", desc1 = "帮战结束后将无法再次进入帮派战场",
			 desc3 = "", btnname = "进入战场",},-- 胜利

	[g_FACTION_FIGHT_PUSH_FAILED] = {title = "帮派战结束", msg = "您所在分堂战斗已结束,您在本次战斗中获得失败,目前处于宝箱采集阶段", desc1 = "帮战结束后将无法再次进入帮派战场",
			 desc3 = "", btnname = "进入战场",},-- 失败
}

function wnd_faction_fight_push_result:ctor()
	self._timeCounter = 0
	self._state = g_FACTION_FIGHT_PUSH_DRAW
end

function wnd_faction_fight_push_result:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.close)
	widgets.ok:onClick(self, self.enter)
end

function wnd_faction_fight_push_result:refresh(data)
	self:set_msg(data)
end


function wnd_faction_fight_push_result:set_msg(data)
	local widgets = self._layout.vars
	widgets.fg_name:setText(data.status.matchGroup.overview.groupName)
	if data.status then
		self._state = data.status.curStatus
	end
	local i = push_result[self._state].title
	widgets.title:setText(push_result[self._state].title)
	widgets.msg:setText(push_result[self._state].msg)
	widgets.desc1:setText(push_result[self._state].desc1)
	widgets.btnName:setText(push_result[self._state].btnname)
	if self._state == g_FACTION_FIGHT_PUSH_WIN then
		widgets.result:setImage(g_i3k_db.i3k_db_get_icon_path(4102))
	else
		widgets.result:setImage(g_i3k_db.i3k_db_get_icon_path(4103))
	end
end

function wnd_faction_fight_push_result:enter(sender)
	local groupId = g_i3k_game_context:getFightGroupId()
	local fun = function()
		i3k_sbean.enter_sectwar(groupId)
	end
	g_i3k_game_context:CheckMulHorse(fun)
end

function wnd_faction_fight_push_result:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 1 then
		self:countTime()
		self._timeCounter = 0
	end
end

function wnd_faction_fight_push_result:countTime()
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
			if i ~= #i3k_db_faction_fight_cfg.timebucket then
				i3k_sbean.sect_fight_group_cur_status(function(data)
					g_i3k_ui_mgr:OpenUI(eUIID_FactionFightPush)
					g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush, data)
					g_i3k_ui_mgr:CloseUI(eUIID_FactionFightPushResult)
				end)
			else
				g_i3k_ui_mgr:CloseUI(eUIID_FactionFightPushResult)
			end
		elseif timeStamp > opentime and timeStamp < closetime then
			self._layout.vars.desc3:setText(string.format("战场倒计时:%s", i3k_get_time_show_text(closetime - timeStamp)))
			break
		end
	end
end

function wnd_faction_fight_push_result:close(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightPushResult)
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_fight_push_result.new()
	wnd:create(layout, ...)
	return wnd;
end
