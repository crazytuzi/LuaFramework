-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_modify_name = i3k_class("wnd_modify_name", ui.wnd_base)

local conmmencfg = g_i3k_db.i3k_db_get_common_cfg()

local modifyCardId = conmmencfg.changeName.itemID--道具Id
local modifyCardIconPath = g_i3k_db.i3k_db_get_other_item_cfg(modifyCardId).icon--道具Icon

function wnd_modify_name:ctor()
	self.have_card = false
end

function wnd_modify_name:configure(...)
	local cancel_btn = self._layout.vars.cancel_btn
	cancel_btn:onClick(self,self.cnacelBtn)
	local changge_btn = self._layout.vars.changge_btn
	changge_btn:onClick(self,self.ensureBtn)
	local random_btn = self._layout.vars.random_btn
	random_btn:onClick(self,self.randomBtn)

	self.item_icon = self._layout.vars.item_icon

	self.ingot_count = self._layout.vars.ingot_count
	self.input_label = self._layout.vars.input_label
	self.input_label:setMaxLength(i3k_db_common.inputlen.namelen)
end

function wnd_modify_name:onShow()

end

function wnd_modify_name:refresh()
	self:updateBaseData()
end

function wnd_modify_name:updateBaseData()
	local cardNum = g_i3k_game_context:GetCommonItemCanUseCount(modifyCardId)
	if cardNum > 0 then
		self.have_card = true
	else
		self.have_card = false
	end

	local tmp_str = ""
	local tmp_icon_path = ""
	if self.have_card then
		tmp_str = string.format("×%s",1)--固定消耗改名卡一张
		tmp_icon_path = g_i3k_db.i3k_db_get_icon_path(modifyCardIconPath)
	else
		tmp_str = string.format("×%s",conmmencfg.changeName.moneyCount)
	end
	
	self.item_icon:setImage(tmp_icon_path)
	self.ingot_count:setText(tmp_str)
end

function wnd_modify_name:cnacelBtn(sender)

	g_i3k_ui_mgr:CloseUI(eUIID_ModifyName)
end

function wnd_modify_name:ensureBtn(sender)
	local modifyName = self.input_label:getText()

	local tmp_str = ""
	local have_count = 0
	if self.have_card then
		tmp_str = string.format("是否确定花费%s张改名卡修改您的名字",1)
	else
		tmp_str = string.format("是否确定花费%s元宝修改您的名字",conmmencfg.changeName.moneyCount)
		have_count = g_i3k_game_context:GetDiamond(true)
		if have_count < conmmencfg.changeName.moneyCount then
			g_i3k_ui_mgr:PopupTipMessage("元宝不足")
			return
		end
	end
	
	local namecount = i3k_get_utf8_len(modifyName)
	if namecount > i3k_db_common.inputlen.namelen or namecount < i3k_db_common.inputlen.nameminlen  then
		g_i3k_ui_mgr:PopupTipMessage("名字长度错误")
		return
	end
	if  modifyName == "" then
		g_i3k_ui_mgr:PopupTipMessage("名字不可为空")
		return
	end
	if g_i3k_game_context:GetRoleName() == modifyName then
		g_i3k_ui_mgr:PopupTipMessage("名字未做修改")
		return
	end

	modifyName = string.trim(modifyName)
	modifyName = string.lower(modifyName)

	local fun = (function(ok)
		if ok then
			if self.have_card then
				i3k_sbean.role_modify_name(modifyName,2)--道具(改名卡)
			else
				i3k_sbean.role_modify_name(modifyName,g_BASE_ITEM_DIAMOND)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_ModifyName)
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(tmp_str,fun)



end

function wnd_modify_name:randomBtn(sender)
	local ret, name = g_i3k_db.i3k_db_get_random_name(g_i3k_game_context:GetRoleGender())
	if ret then
		self.input_label:setText(name)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_modify_name.new();
		wnd:create(layout, ...);

	return wnd;
end
