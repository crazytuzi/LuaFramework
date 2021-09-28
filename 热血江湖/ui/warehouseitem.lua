-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_wareHouseItem = i3k_class("wnd_wareHouseItem",ui.wnd_base)

function wnd_wareHouseItem:ctor()
	
end

function wnd_wareHouseItem:configure()
	local widgets = self._layout.vars
	self.globel_bt = widgets.globel_bt

	self.itemName_label = widgets.itemName_label
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.itemGrade_lable = widgets.itemGrade_lable
	self.itemDesc_label = widgets.itemDesc_label
	self.get_label = widgets.get_label

	self.btn1 = widgets.sale
	self.btn2 = widgets.combineBtn
	self.btn3 = widgets.inset
	self.label1 = widgets.label1
	self.label2	= widgets.label2
	self.label3 = widgets.label3
	
	self.btn3:hide()
	self.label1:setText("兑换")
	self.label2:setText("设置")

	self.globel_bt:onClick(self, self.onCloseUI)
end

function wnd_wareHouseItem:refresh(id, info)
	self._id = id
	self._info = info
	local position = g_i3k_game_context:GetSectPosition()
	if i3k_db_faction_power[position].shareRight == 0 or i3k_db_new_item[id].defaultScore == 0 then
		self.btn2:hide()
	end
	
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)

	self.itemName_label:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self.itemDesc_label:setText(g_i3k_db.i3k_db_get_common_item_desc(id))
	self.get_label:setText(g_i3k_db.i3k_db_get_common_item_source(id))
	self.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))

	local lvlReq = g_i3k_db.i3k_db_get_common_item_level_require(id)
	self.itemGrade_lable:setText(i3k_get_string(g_UseItem_Need_Level, lvlReq))
	self.itemGrade_lable:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= lvlReq))
	self.itemGrade_lable:setVisible(lvlReq > 1)
	
	local limitTimes = g_i3k_db.i3k_db_get_bag_item_limitable(id)
	if g_i3k_db.i3k_db_get_bag_item_limitable(id) and (lvlReq <= 1 or g_i3k_game_context:GetLevel() >= lvlReq) then
		self.use_times = g_i3k_db.i3k_db_get_day_use_item_day_use_times(id)
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
		local times = self.use_times
		local str = i3k_get_string(283, self.use_times)
		self.itemGrade_lable:setText(i3k_get_string(283, self.use_times))
		self.itemGrade_lable:setVisible(g_i3k_db.i3k_db_get_day_use_item_times(id) ~= 999)
		self.itemGrade_lable:setTextColor(g_i3k_get_cond_color(self.use_times > 0))
	end
	self.btn2:onClick(self, self.setPrice, self._id)
	self.btn1:onClick(self,self.applyItem, self._id)
end

function wnd_wareHouseItem:setPrice(sender, id)
	local position = g_i3k_game_context:GetSectPosition()
	if i3k_db_faction_power[position].shareRight == 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_SetWareHouseItemPrice)
		g_i3k_ui_mgr:RefreshUI(eUIID_SetWareHouseItemPrice, id, self._info)
		self:onCloseUI()
	end
end

function wnd_wareHouseItem:applyItem(sender, id)
	if self._info.sharItems[id] < i3k_db_new_item[id].applyNum then
		g_i3k_ui_mgr:PopupTipMessage("数量不足")
	else
		if i3k_db_new_item[id].defaultScore == 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_ApplyWareHouseItemSecond)
			g_i3k_ui_mgr:RefreshUI(eUIID_ApplyWareHouseItemSecond, id, self._info)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_ApplyWareHouseItem)
			g_i3k_ui_mgr:RefreshUI(eUIID_ApplyWareHouseItem, id, self._info)
		end		
		self:onCloseUI()
	end
end

function wnd_create(layout)
	local wnd = wnd_wareHouseItem.new()
		wnd:create(layout)
	return wnd
end
