-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_taoistShowReward = i3k_class("wnd_taoistShowReward", ui.wnd_base)

function wnd_taoistShowReward:ctor()
	
end

function wnd_taoistShowReward:configure()
	local widget = self._layout.vars
	widget.bg:onClick(self, self.onCloseUI)
	widget.ok:onClick(self, self.onCloseUI)
end

function wnd_taoistShowReward:refresh()
	local widget = self._layout.vars
	widget.des:setText(i3k_get_string(17905))
	widget.fromName:setText(i3k_get_string(17906))
	widget.itemScroll:removeAllChildren()	
	local items = i3k_db_taoist.showRedwards
	
	for _, id in pairs(items) do
		node = require("ui/widgets/zhengxiedaochangkqt")()
		widget.itemScroll:addItem(node)
		local weight = node.vars
		weight.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, i3k_game_context:IsFemaleRole()))
		weight.root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		weight.count:setVisible(false)
		weight.lock:setVisible(id > 0)
		weight.btn:onClick(self, self.onClickItem, id)
	end
end

function wnd_taoistShowReward:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_taoistShowReward.new()
	wnd:create(layout, ...)
	return wnd;
end