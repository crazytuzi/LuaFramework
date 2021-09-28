-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_rewardTips = i3k_class("wnd_rewardTips", ui.wnd_base)


function wnd_rewardTips:ctor()
	self.inCDtime = false
end

function wnd_rewardTips:configure( )
	local widgets = self._layout.vars
	widgets.globel_bt:onClick(self, self.onCloseUI)
	self.condition = widgets.condition
end

function wnd_rewardTips:refresh(gift, score)
	for k,v in pairs(gift) do
		local item= require("ui/widgets/dlsltipst")()
		self._layout.vars.listView:addItem(item)
		item.vars.item_bg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.ItemID)))
		item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.ItemID,i3k_game_context:IsFemaleRole()))
		item.vars.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(v.ItemID))
		item.vars.count:setText("X"..i3k_get_num_to_show(v.count))
		local ItemRank = g_i3k_db.i3k_db_get_common_item_rank(v.ItemID)
		item.vars.itemName_label:setTextColor(g_i3k_get_color_by_rank(ItemRank))
		item.vars.btn:onClick(self,self.onProItemdetail, v.ItemID)
		item.vars.lockImg:setVisible(v.ItemID > 0)
	end

	self.condition:setVisible(score ~= nil)
	if score then
		if score == -1 then
			self.condition:setText(i3k_get_string(18535))
		else
		self.condition:setText(i3k_get_string(16388, score))
		end
	end
end

function wnd_rewardTips:onProItemdetail(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout)
	local wnd = wnd_rewardTips.new()
	wnd:create(layout)
	return wnd
end
