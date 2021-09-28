-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_applyWareHouseItemSecond = i3k_class("wnd_applyWareHouseItemSecond", ui.wnd_base)

function wnd_applyWareHouseItemSecond:ctor()
	
end

function wnd_applyWareHouseItemSecond:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_applyWareHouseItemSecond:refresh(id, info)
	self._nowPrice = i3k_db_new_item[id].needweekScore
	self:showItemInfo(id)
end

function wnd_applyWareHouseItemSecond:showItemInfo(id)
	local widgets = self._layout.vars
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.item_count:setText(i3k_db_new_item[id].applyNum)
	widgets.need_score:setText(self._nowPrice)	
	local factiondate = g_i3k_game_context:GetFactionBaseData()
	self._weekActivity = factiondate == nil and 0 or factiondate.stats.weekVitality
	widgets.left_score:setText(self._weekActivity)
	widgets.desc:setText(i3k_get_string(1350, i3k_db_crossRealmPVE_shareCfg.allotTime))
	widgets.ok:onClick(self, self.sendApply, id)
end

function wnd_applyWareHouseItemSecond:sendApply(sender, id)
	local level = g_i3k_game_context:GetLevel()
	
	if self._weekActivity < self._nowPrice then
		g_i3k_ui_mgr:PopupTipMessage("所需周活跃度不足，无法兑换")
	elseif level < i3k_db_crossRealmPVE_shareCfg.needLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1354, i3k_db_crossRealmPVE_shareCfg.needLevel))
	else
		i3k_sbean.globalpve_applyItems(id, 0)
		self:onCloseUI()
	end 
end

function wnd_create(layout)
	local wnd = wnd_applyWareHouseItemSecond.new()
	wnd:create(layout)
	return wnd
end
