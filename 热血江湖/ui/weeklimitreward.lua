
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_weekLimitReward = i3k_class("wnd_weekLimitReward",ui.wnd_base)

function wnd_weekLimitReward:ctor()

end

function wnd_weekLimitReward:configure()
	local widgets = self._layout.vars
	widgets.globel_bt:onClick(self, self.onCloseUI)
end

function wnd_weekLimitReward:refresh(items, randItems)
	local widgets = self._layout.vars
	self:setItemScroll(items, widgets.listView)
	self:setItemScroll(randItems, widgets.listView2)
end

function wnd_weekLimitReward:setItemScroll(items, scroll)
	scroll:removeAllChildren()
	for i, v in ipairs(items) do
		local ui = require("ui/widgets/dlsltipst")()
		ui.vars.item_bg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		ui.vars.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
		ui.vars.count:setText("X"..i3k_get_num_to_show(v.count))
		local ItemRank = g_i3k_db.i3k_db_get_common_item_rank(v.id)
		ui.vars.itemName_label:setTextColor(g_i3k_get_color_by_rank(ItemRank))
		ui.vars.btn:onClick(self,self.onShowItemInfo, v.id)
		ui.vars.lockImg:setVisible(v.id > 0)
		scroll:addItem(ui)
	end
end

function wnd_weekLimitReward:onShowItemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout, ...)
	local wnd = wnd_weekLimitReward.new()
	wnd:create(layout, ...)
	return wnd;
end

