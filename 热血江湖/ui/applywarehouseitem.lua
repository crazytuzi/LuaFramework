-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_applyWareHouseItem = i3k_class("wnd_applyWareHouseItem",ui.wnd_base)

function wnd_applyWareHouseItem:ctor()
	
end

function wnd_applyWareHouseItem:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_applyWareHouseItem:refresh(id, info)
	self._nowPrice = i3k_db_new_item[id].defaultScore
	self._info = info
	self:showItemInfo(id)
end

function wnd_applyWareHouseItem:showItemInfo(id)
	local widgets = self._layout.vars
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.item_count:setText(i3k_db_new_item[id].applyNum)
	if self._info.itemsPrice[id] then
		widgets.need_score:setText(self._info.itemsPrice[id])
		self._nowPrice = self._info.itemsPrice[id]
	else
		widgets.need_score:setText(i3k_db_new_item[id].defaultScore)
	end
	widgets.left_score:setText(self._info.selfScore)
	widgets.desc:setText(i3k_get_string(1350, i3k_db_crossRealmPVE_shareCfg.allotTime))
	widgets.ok:onClick(self, self.sendApply, id)
end

function wnd_applyWareHouseItem:sendApply(sender, id)
	local level = g_i3k_game_context:GetLevel()
	if self._info.selfScore < self._nowPrice then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1352))
	elseif level < i3k_db_crossRealmPVE_shareCfg.needLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1354, i3k_db_crossRealmPVE_shareCfg.needLevel))
	else
		i3k_sbean.globalpve_applyItems(id, self._nowPrice)
	end 
end

function wnd_create(layout)
	local wnd = wnd_applyWareHouseItem.new()
		wnd:create(layout)
	return wnd
end