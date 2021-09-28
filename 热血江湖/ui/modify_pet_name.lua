-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_modify_pet_name = i3k_class("wnd_modify_pet_name", ui.wnd_base)

function wnd_modify_pet_name:ctor()

end

function wnd_modify_pet_name:configure(...)
	self.cancel_btn = self._layout.vars.cancel_btn
	self.cancel_btn:onClick(self,self.onCancleBtn)

	self.change_btn = self._layout.vars.change_btn
	self.change_btn:onClick(self,self.onChangeBtn)

	self.item_img = self._layout.vars.item_img
	self.item_bg = self._layout.vars.item_bg
	self.item_count = self._layout.vars.item_count
	self.item_btn = self._layout.vars.item_btn

	self.input_label = self._layout.vars.input_label
	self.input_label:setMaxLength(i3k_db_mercenariea_waken_cfg.nameMaxLen)
	self.input_label:setPlaceHolder(string.format("%s~%s个汉字", i3k_db_mercenariea_waken_cfg.nameMinLen, i3k_db_mercenariea_waken_cfg.nameMaxLen))

	self.icon = self._layout.vars.icon
	self.iconBg = self._layout.vars.iconBg
end

function wnd_modify_pet_name:refresh(petID)
	self._petID = petID
	self._itemID = i3k_db_mercenariea_waken_cfg.itemId
	self:updateBaseData(petID)
end

function wnd_modify_pet_name:updateBaseData(id)
	local itemID = self._itemID

	local cfg = i3k_db_mercenaries[id]
	local iconId = cfg.icon
	if g_i3k_game_context:getPetWakenUse(id) then
		iconId = i3k_db_mercenariea_waken_property[id].headIcon
	end
	self.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
	self.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(cfg.rank))

	self.item_count:setText(string.format("×%s",1))  --固定消耗改名卡一张
	self.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(itemID) > 0))
	self.item_bg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemID)))
	self.item_img:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID), g_i3k_game_context:IsFemaleRole())

	self.item_btn:onClick(self, self.onTips, itemID)
end

function wnd_modify_pet_name:onCancleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ModifyPetName)
end

function wnd_modify_pet_name:onChangeBtn(sender)
	if g_i3k_game_context:GetCommonItemCanUseCount(self._itemID) <= 0 then
		g_i3k_ui_mgr:PopupTipMessage("道具不足，请前往商城购买")
		return
	end

	local modifyName = self.input_label:getText()
	
	local namecount = i3k_get_utf8_len(modifyName)
	if namecount > i3k_db_mercenariea_waken_cfg.nameMaxLen or namecount < i3k_db_mercenariea_waken_cfg.nameMinLen then
		g_i3k_ui_mgr:PopupTipMessage("名字长度错误")
		return
	end
	if modifyName == "" then
		g_i3k_ui_mgr:PopupTipMessage("名字不可为空")
		return
	end
	if g_i3k_game_context:getPetName(self._petID) == modifyName then
		g_i3k_ui_mgr:PopupTipMessage("名字未做修改")
		return
	end

	modifyName = string.trim(modifyName)
	modifyName = string.lower(modifyName)

	local tmp_str = string.format("是否确定花费%s张%s修改宠物的名字", 1, g_i3k_db.i3k_db_get_common_item_name(self._itemID))
	local fun = (function(ok)
		if ok then
			i3k_sbean.pet_modify_name(self._petID, modifyName)
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(tmp_str, fun)
end

function wnd_modify_pet_name:onTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_modify_pet_name:updateNeedItem()
	self.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(self._itemID) > 0))
end

function wnd_create(layout, ...)
	local wnd = wnd_modify_pet_name.new();
		wnd:create(layout, ...);

	return wnd;
end
