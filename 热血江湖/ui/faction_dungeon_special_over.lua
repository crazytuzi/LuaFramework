-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_special_over = i3k_class("wnd_faction_dungeon_special_over", ui.wnd_base)

--帮贡id
local contributionID = 3
local LAYER_SDWC4 = "ui/widgets/bfjgt"

local _time_label = nil
local max_value = 0
function wnd_faction_dungeon_special_over:ctor()

end



function wnd_faction_dungeon_special_over:configure(...)
	self.damage_value = self._layout.vars.damage_value
	self.award_money = self._layout.vars.award_money 
	self.label = self._layout.vars.label 
	local exit_btn = self._layout.vars.exit_btn
	exit_btn:onTouchEvent(self,self.onExit)
	local time_label = self._layout.vars.time_label
	_time_label = time_label
	time_label:setText(i3k_db_common.faction.dungeonCloseTime)
end

function wnd_faction_dungeon_special_over:onShow()
	self._timer = i3k_game_timer_fd_battle_over.new()
	self._timer:onTest()
end

function wnd_faction_dungeon_special_over:refresh(data)
	self:setData(data)
end

function wnd_faction_dungeon_special_over:setData(data)
	if not data then
		return
	end
	self.label:setText(i3k_get_string(17108))
	self.damage_value:setText(data.damage)
	self.award_money:setText(data.goldReward)
	max_value = i3k_db_common.faction.dungeonCloseTime
end

function wnd_faction_dungeon_special_over:onItemTips(sender,id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_faction_dungeon_special_over:onHide()
	self:cancelTime()
end

function wnd_faction_dungeon_special_over:onExit(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		i3k_sbean.mapcopy_leave()
	end
end

function wnd_faction_dungeon_special_over:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonBattleOver)
	end
end

function wnd_faction_dungeon_special_over:cancelTime()
	if self._timer then
		self._timer:CancelTimer()
	end
end

function wnd_faction_dungeon_special_over:setTime()
	if _time_label then
		max_value = max_value -1
		if max_value <= 0 then
			max_value = 0
			_time_label:setText(max_value)
			return true
		else
			_time_label:setText(max_value)
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_dungeon_special_over.new()
	wnd:create(layout, ...)
	return wnd
end

local TIMER = require("i3k_timer")
i3k_game_timer_fd_battle_over = i3k_class("i3k_game_timer_fd_battle_over", TIMER.i3k_timer)

function i3k_game_timer_fd_battle_over:Do(args)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonSpecialOver,"setTime")
end

function i3k_game_timer_fd_battle_over:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_fd_battle_over.new(1000))
	end
end

function i3k_game_timer_fd_battle_over:CancelTimer()
	local logic = i3k_game_get_logic()
	if logic and self._timer then
		logic:UnregisterTimer(self._timer)
	end
end
