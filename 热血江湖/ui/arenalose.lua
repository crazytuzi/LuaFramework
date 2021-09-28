-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arenaLose = i3k_class("wnd_arenaLose", ui.wnd_base)

function wnd_arenaLose:ctor()
	self._timeTick = 0
end

function wnd_arenaLose:configure(...)
	local exitBtn = self._layout.vars.exitBtn
	if exitBtn then exitBtn:onClick(self, self.onQuit) end
end

function wnd_arenaLose:onShow()
	self:setData()
	local callbackfun = function()
		g_i3k_logic:OpenArenaUI()
	end
	local mId,value = g_i3k_game_context:getMainTaskIdAndVlaue()
	local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
	if main_task_cfg.type == g_TASK_PERSONAL_ARENA then
		callbackfun = function()
			g_i3k_logic:OpenBattleUI()
		end
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
end

function wnd_arenaLose:setData()
	local scroll = self._layout.vars.img_scroll
	scroll:removeAllChildren()
	local missionsID = g_i3k_get_commend_mission()
	for i = 1,4 do
		local widget = require("ui/widgets/jjsbt")()
		widget.vars.img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_want_improve_strongChild[missionsID[i]].iconID))
		widget.vars.name:setText(i3k_db_want_improve_strongChild[missionsID[i]].name)
		scroll:addItem(widget)
	end
end

function wnd_arenaLose:onQuit(sender, eventType)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaLose)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero._AutoFight = false
	end
	i3k_sbean.mapcopy_leave()
end

function wnd_arenaLose:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	local str = string.format("%s", "秒后退出")
	local time = math.ceil(i3k_db_arena.arenaCfg.autoCloseTime - self._timeTick)
	time = time>0 and time or 0
	self._layout.vars.daojishi:setText(time..str)
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaLose.new();
		wnd:create(layout, ...);

	return wnd;
end
