-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_talent_reset = i3k_class("wnd_shen_bing_talent_reset", ui.wnd_base)


function wnd_shen_bing_talent_reset:ctor( )
	self.shenbingId = 1

end

function wnd_shen_bing_talent_reset:configure( )
	local widgets = self._layout.vars
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.item_name = widgets.item_name
	self.item_count = widgets.item_count
	self.item_btn = widgets.item_btn
	self.item_suo = widgets.item_suo
	self.reset_btn = widgets.reset_btn
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)

end

function wnd_shen_bing_talent_reset:refresh(shenbingId)
	self.shenbingId = shenbingId
	self:SetShenBingTalenResetData()
end

function wnd_shen_bing_talent_reset:SetShenBingTalenResetData()
	local itemId = i3k_db_shen_bing_talent_init.reset_talent_useId[1]
	local itemCount = i3k_db_shen_bing_talent_init.reset_talent_useCount[1]
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemId)
	self.item_suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemId))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(itemId).."/"..itemCount)
	self.item_count:setTextColor(g_i3k_get_cond_color(itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(itemId)))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	self.item_btn:onClick(self, self.itemTips,itemId)
	self.reset_btn:onClick(self,self.onResetBtn,{itemId = itemId,itemCount = itemCount})
end

function wnd_shen_bing_talent_reset:onResetBtn(sender,item)
	local itemId = item.itemId 
	local itemCount = item.itemCount 
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
	if itemCount > haveCount then
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法重置")
	else
		i3k_sbean.shen_bing_resetTalent(self.shenbingId)
	end
end

function wnd_shen_bing_talent_reset:itemTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout)
	local wnd = wnd_shen_bing_talent_reset.new()
	wnd:create(layout)
	return wnd
end
 
