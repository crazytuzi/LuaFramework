-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require('ui/base')

-------------------------------------------------------
wnd_newFestivalScoreBoxTips = i3k_class('wnd_newFestivalScoreBoxTips', ui.wnd_base)


function wnd_newFestivalScoreBoxTips:ctor()

end

function wnd_newFestivalScoreBoxTips:configure()
    
    self._layout.vars.globel_bt:onClick(self, self.onCloseUI)
end

function wnd_newFestivalScoreBoxTips:refresh(rewards)

    self:localScroll(rewards)
end


function wnd_newFestivalScoreBoxTips:localScroll(rewards)
	for k, v in ipairs(rewards) do
		local node = require("ui/widgets/jieribxtipst")()
        local itemID = v.itemID
		local name = g_i3k_db.i3k_db_get_common_item_name(itemID)
        local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemID)
		local name_colour = g_i3k_get_color_by_rank(item_rank)
		node.vars.itemName_label:setText(name)
		node.vars.itemName_label:setTextColor(name_colour)
		node.vars.count:setText("x"..v.itemCount)
		node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		node.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		node.vars.suo:setVisible(itemID > 0)
		node.vars.btn:onClick(self, self.onItemTip, itemID)
        self._layout.vars.listView:addItem(node)
	end
end


function wnd_newFestivalScoreBoxTips:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end


function wnd_create(layout, ...)
    local wnd = wnd_newFestivalScoreBoxTips.new()
    wnd:create(layout)
    return wnd
end
