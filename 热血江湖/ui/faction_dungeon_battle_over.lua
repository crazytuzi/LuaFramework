-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_battle_over = i3k_class("wnd_faction_dungeon_battle_over", ui.wnd_base)

--帮贡id
local contributionID = 3
local LAYER_SDWC4 = "ui/widgets/bfjgt"

local _time_label = nil
local max_value = 0
function wnd_faction_dungeon_battle_over:ctor()

end



function wnd_faction_dungeon_battle_over:configure(...)
	self.boss_loading = self._layout.vars.boss_loading
	self.boss_label = self._layout.vars.boss_label
	self.damage_value = self._layout.vars.damage_value
	self.damage_rank = self._layout.vars.damage_rank
	self.all_rank = self._layout.vars.all_rank
	local exit_btn = self._layout.vars.exit_btn
	exit_btn:onTouchEvent(self,self.onExit)
	local doubel_label = self._layout.vars.doubel_label
	doubel_label:hide()
	local item_icon2 = self._layout.vars.item_icon2
	item_icon2:hide()
	local item_count2 = self._layout.vars.item_count2
	item_count2:hide()
	local item_icon1 = self._layout.vars.item_icon1
	item_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_SECT_MONEY,i3k_game_context:IsFemaleRole()))
	self.item_count1 = self._layout.vars.item_count1
	local time_label = self._layout.vars.time_label
	_time_label = time_label
	time_label:setText(i3k_db_common.faction.dungeonCloseTime)
	self.item_scroll = self._layout.vars.item_scroll

	self.award_money = self._layout.vars.award_money
end

function wnd_faction_dungeon_battle_over:onShow()
	self._timer = i3k_game_timer_fd_battle_over.new()
	self._timer:onTest()
end

function wnd_faction_dungeon_battle_over:refresh(data)
	self:setData(data)
end

function wnd_faction_dungeon_battle_over:setData(data)
	if not data then
		return
	end
	local tmp_value = data.progress/10000
	tmp_value = math.modf(tmp_value * 100)
	self.boss_loading:setPercent(tmp_value)
	local tmp_str = string.format("%s%%",tmp_value)
	self.boss_label:setText(tmp_str)
	self.damage_value:setText(data.damage)
	self.damage_rank:setText(data.maxDamageRank)
	self.all_rank:setText(data.accDamageRank)
	self.item_count1:setText(data.extraReward)
	self.award_money:setText(data.goldReward)
	max_value = i3k_db_common.faction.dungeonCloseTime
	for k,v in pairs(data.items) do
		local _layer = require(LAYER_SDWC4)()
		local item_count = _layer.vars.item_count
		local item_bg = _layer.vars.item_bg
		local item_icon = _layer.vars.item_icon
		local btn = _layer.vars.btn
		item_count:setText(v)
		btn:onClick(self,self.onItemTips,k)
		item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(k))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k,i3k_game_context:IsFemaleRole()))
		self.item_scroll:addItem(_layer)
	end
end

function wnd_faction_dungeon_battle_over:onItemTips(sender,id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_faction_dungeon_battle_over:onHide()
	self:cancelTime()
end

function wnd_faction_dungeon_battle_over:onExit(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		i3k_sbean.mapcopy_leave()
	end
end

function wnd_faction_dungeon_battle_over:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonBattleOver)
	end
end

function wnd_faction_dungeon_battle_over:cancelTime()
	if self._timer then
		self._timer:CancelTimer()
	end
end

function wnd_faction_dungeon_battle_over:setTime()
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
	local wnd = wnd_faction_dungeon_battle_over.new()
	wnd:create(layout, ...)
	return wnd
end

local TIMER = require("i3k_timer")
i3k_game_timer_fd_battle_over = i3k_class("i3k_game_timer_fd_battle_over", TIMER.i3k_timer)

function i3k_game_timer_fd_battle_over:Do(args)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonBattleOver,"setTime")

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
