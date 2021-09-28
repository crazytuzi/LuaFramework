-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_showLoveWish = i3k_class("wnd_showLoveWish", ui.wnd_base)

function wnd_showLoveWish:ctor()

end

function wnd_showLoveWish:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_showLoveWish:onShow()

end

function wnd_showLoveWish:refresh(info)
	self:setUI(info)
end

function wnd_showLoveWish:setUI(info)
	local widgets = self._layout.vars
	local fromName = info.fromName
	local toName = info.toName
	local msg = info.msg
	local refFestivalBless = info.refFestivalBless

	widgets.label:setText(msg)
	widgets.toRoleName:setText(toName)
	widgets.sure_btn:onClick(self, self.onWish, info)
end

function wnd_showLoveWish:onWish(sender, info)
	local cfg = g_i3k_game_context:getRoleFestivalBless(g_activity_show_world)
	local times = 0
	if cfg and cfg.dayBlessTimes then
		times = cfg.dayBlessTimes
	end
	local maxTimes = i3k_db_activity_world[g_activity_show_world].dayBlessTimes
	if maxTimes <= times then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17247, maxTimes)) -- 到达最大次数
		return
	end

	-- 检查是否在当天的活动时间内
	local checkTime = g_i3k_db.i3k_db_get_is_activity_world_can_get_reward(g_activity_show_world)
	if not checkTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17245))
		return
	end

	local checkDate = g_i3k_db.i3k_db_get_is_activity_world_open(g_activity_show_world)
	if not checkDate then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17246)) -- 不在日期范围内
		return
	end

	local refFestivalBless = info.refFestivalBless
	i3k_sbean.getMarriageBlessGift(refFestivalBless.id, refFestivalBless.guid)
end

function wnd_create(layout, ...)
	local wnd = wnd_showLoveWish.new()
	wnd:create(layout, ...)
	return wnd;
end
