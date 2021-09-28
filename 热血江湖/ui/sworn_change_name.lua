module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sworn_change_name = i3k_class("wnd_sworn_change_name", ui.wnd_base)

function wnd_sworn_change_name:ctor()
	self._isPrefix = false
	self._needDiamond = 0
	self._data = {}
end

function wnd_sworn_change_name:configure()
	self._layout.vars.cancel_btn:onClick(self, self.onCloseUI)
	self._layout.vars.ok_btn:onClick(self, self.onChangeBtn)
end

function wnd_sworn_change_name:refresh(isPrefix, data)
	self._isPrefix = isPrefix
	self._data = data
	if isPrefix then
		self:setPrefixInfo()
		self._layout.vars.desc:setText(i3k_get_string(5414))
	else
		self:setSuffixInfo()
		self._layout.vars.desc:setText(i3k_get_string(5415))
	end
end

function wnd_sworn_change_name:setPrefixInfo()
	self._layout.vars.suffixNode:hide()
	self._layout.vars.prefixNode:show()
	self._layout.vars.needLock:hide()
	self._layout.vars.haveLock:hide()
	self._layout.vars.needCount:setText(i3k_db_sworn_system.costPrefix)
	self._layout.vars.suffixName:setText(self._data.roles[g_i3k_game_context:GetRoleId()].suffix)
	self._layout.vars.haveCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(-g_BASE_ITEM_DIAMOND))
	self._needDiamond = i3k_db_sworn_system.costPrefix
end

function wnd_sworn_change_name:setSuffixInfo()
	self._layout.vars.prefixNode:hide()
	self._layout.vars.suffixNode:show()
	self._layout.vars.needLock:show()
	self._layout.vars.haveLock:show()
	local roleId = g_i3k_game_context:GetRoleId()
	local needDiamond = 0
	if self._data.roles[roleId].suffixChangeTimes + 1 > #i3k_db_sworn_system.costPostfix then
		needDiamond = i3k_db_sworn_system.costPostfix[#i3k_db_sworn_system.costPostfix]
	else
		needDiamond = i3k_db_sworn_system.costPostfix[self._data.roles[roleId].suffixChangeTimes + 1]
	end
	self._layout.vars.needCount:setText(needDiamond)
	self._layout.vars.prefixName:setText(self._data.prefix)
	self._layout.vars.haveCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_DIAMOND))
	self._needDiamond = needDiamond
end

function wnd_sworn_change_name:onChangeBtn(sender)
	if self._isPrefix then
		if self._needDiamond > g_i3k_game_context:GetCommonItemCanUseCount(-g_BASE_ITEM_DIAMOND) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5403))
		else
			local text = self._layout.vars.prefixEditBox:getText()
			if i3k_get_utf8_len(text) > i3k_db_sworn_system.numLimitPrefix then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5393, i3k_db_sworn_system.numLimitPrefix))
			elseif i3k_get_utf8_len(text) == 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5394))
			else
				i3k_sbean.sworn_change_prefix(text, self._needDiamond)
			end
		end
	else
		if self._needDiamond > g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_DIAMOND) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5402))
		else
			local text = self._layout.vars.suffixEditBox:getText()
			if i3k_get_utf8_len(text) > i3k_db_sworn_system.numLimitPostfix then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5393, i3k_db_sworn_system.numLimitPostfix))
			elseif i3k_get_utf8_len(text) == 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5394))
			else
				i3k_sbean.sworn_change_suffix(text, self._needDiamond)
			end
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_sworn_change_name.new()
	wnd:create(layout)
	return wnd
end
