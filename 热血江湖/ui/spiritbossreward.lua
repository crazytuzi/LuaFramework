------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_spirit_boss_reward = i3k_class("wnd_spirit_boss_reward",ui.wnd_base)

local T1_WIDGETS = "ui/widgets/julinggongchengjlt"

function wnd_spirit_boss_reward:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_spirit_boss_reward:refresh()
	local widgets = self._layout.vars
	widgets.des:setText(i3k_get_string(17342))
	local cfg = i3k_db_spirit_boss.common.showAwards
	for i, v in ipairs(cfg) do
		local widget = require(T1_WIDGETS)()
		widget.vars.img:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v, g_i3k_game_context:IsFemaleRole()))
		widget.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		widget.vars.btn:onClick(self, function()
			g_i3k_ui_mgr:ShowCommonItemInfo(v)
			end)
		widgets.content:addItem(widget)
	end
end
-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_spirit_boss_reward.new()
	wnd:create(layout,...)
	return wnd
end