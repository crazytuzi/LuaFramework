-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
--家园改名
wnd_homeLandChangeName = i3k_class("wnd_homeLandChangeName", ui.wnd_base)

function wnd_homeLandChangeName:ctor()
	self._nameLenLimit = i3k_db_common.inputlen.homelandNameLen
end

function wnd_homeLandChangeName:configure()
	local widgets = self._layout.vars

	self.itemIcon = widgets.itemIcon
	self.countLabel = widgets.countLabel
	self.input_label = widgets.input_label
	self.suo		= widgets.suo
	widgets.input_label:setPlaceHolder(i3k_get_string(5150, 2, self._nameLenLimit))
	widgets.input_label:setMaxLength(self._nameLenLimit * 2)
	widgets.cancel_btn:onClick(self, self.onCloseUI)
	widgets.change_btn:onClick(self, self.onChangeName)
end

function wnd_homeLandChangeName:refresh()
	local itemID = i3k_db_home_land_base.baseCfg.changeNameItemID
	self.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	self.countLabel:setText(i3k_db_home_land_base.baseCfg.changeNameItemCnt)
	self.suo:setVisible(itemID > 0)
end

function wnd_homeLandChangeName:onChangeName(sender)
	local name = self.input_label:getText()
	local error_code, desc = g_i3k_name_rule(name, self._nameLenLimit)
	if error_code ~= 1 then	
		return g_i3k_ui_mgr:PopupTipMessage(desc)
	end
	local itemID = i3k_db_home_land_base.baseCfg.changeNameItemID
	local itemCount = i3k_db_home_land_base.baseCfg.changeNameItemCnt
	if g_i3k_game_context:GetCommonItemCanUseCount(itemID) < itemCount then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5074))
	end

	local have = g_i3k_game_context:GetCommonItemCount(g_BASE_ITEM_DIAMOND)
	local fun = (function(ok)
		if ok then
			i3k_sbean.homeland_rename(name)
		end
	end)

	local msg = ""
	if have >= itemCount then
		msg = i3k_get_string(5075)
	elseif have == 0 then
		msg = string.format("绑定元宝不足，确定消耗<c=FF029133>%s非绑元宝</c>改名？（绑定元宝不足则会消耗元宝）",  itemCount)
	elseif have < itemCount then
		msg = string.format("绑定元宝不足，确定消耗<c=FF029133>%s绑定元宝</c>、<c=FF029133>%s非绑元宝</c>改名？（绑定元宝不足则会消耗元宝）", have, itemCount - have)
	end
	g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
end

function wnd_create(layout, ...)
	local wnd = wnd_homeLandChangeName.new();
		wnd:create(layout, ...);
	return wnd;
end
