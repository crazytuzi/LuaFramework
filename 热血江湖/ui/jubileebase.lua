module(..., package.seeall)

local require = require;
local ui = require("ui/base")
---------------------------------------------------------------
local WIDGET_ZHONGNIANQINGJL = "ui/widgets/zhounianqingjl1t"

jubileeBase = i3k_class("jubileeBase", ui.wnd_base)

function jubileeBase:loadAwardScroll(awardsCfg)
	self._layout.vars.awardScroll:removeAllChildren()
	for _, e in ipairs(awardsCfg) do
		local node = require(WIDGET_ZHONGNIANQINGJL)()
		node.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID))--, g_i3k_game_context:IsFemaleRole()))
		node.vars.count:setText(e.itemCount)
		node.vars.btn:onClick(self, self.onItemTips, e.itemID)
		node.vars.lockImg:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		self._layout.vars.awardScroll:addItem(node)
	end
end

function jubileeBase:onItemTips(sender, itemID)
    g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end
