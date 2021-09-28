module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_tournament_week_reward = i3k_class("wnd_tournament_week_reward", ui.wnd_base)

function wnd_tournament_week_reward:ctor()

end
function wnd_tournament_week_reward:configure()
	local widgets = self._layout.vars
	widgets.close2:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onReward)
end


function wnd_tournament_week_reward:refresh()
	self:setWeedReward()
end 

function wnd_tournament_week_reward:setWeedReward()
	local scroll = self._layout.vars.scroll
	local infoCur = g_i3k_game_context:getTournamentWeekRewardInfo()
	scroll:removeAllChildren()
	local info = g_i3k_db.i3k_db_get_tournament_week_reward_list(true)
	for k , v in ipairs(info) do
		local node = require("ui/widgets/huiwu1")()
		local weights = node.vars
		--weights.bg:hide()
		weights.bg:setImage(g_i3k_db.i3k_db_get_icon_path(6204))
		if v.isReward then
			weights.bg:setImage(g_i3k_db.i3k_db_get_icon_path(8023))
			weights.state:setText(i3k_get_string(1752))
			weights.state:setTextColor(g_i3k_get_green_color())-- 绿色
		else
			weights.state:setTextColor(g_i3k_get_red_color())--红色
			weights.state:setText(i3k_get_string(1753))
		end
		weights.desc:setText(string.format(v.desc, v.needTimes, infoCur.weekTimes, v.needTimes))
		weights.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemId))
		weights.itemCount:setText(v.itemCount)
		weights.title:setText(v.title)
		scroll:addItem(node)
	end
	local items = g_i3k_db.i3k_db_get_tournament_week_reward_list()
	if table.nums(items) == 0 then
		self._layout.vars.ok:disableWithChildren()
	else
		self._layout.vars.ok:enableWithChildren()
	end
	self._layout.vars.tips:setText(i3k_get_string(1754))
end

function wnd_tournament_week_reward:onReward(sender)
	local items = g_i3k_db.i3k_db_get_tournament_week_reward_list()
	i3k_sbean.super_arena_week_reward_take(items)
end

function wnd_tournament_week_reward:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TournamentWeekReward)
end


function wnd_create(layout)
	local wnd = wnd_tournament_week_reward.new();
	wnd:create(layout);
	return wnd;
end
