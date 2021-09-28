
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_baguaSplitSure = i3k_class("wnd_baguaSplitSure",ui.wnd_base)

local splitSureText = i3k_db_bagua_cfg.splitSureText

function wnd_baguaSplitSure:ctor()
	self._equips = nil
	self._getItems = nil
end

function wnd_baguaSplitSure:configure()
	local widgets = self._layout.vars
	widgets.cancel_btn:onClick(self, self.onCloseUI)
	widgets.inputHint:setText(string.format("请输入%s确认分解", splitSureText))
	widgets.input_label:setText(string.format("请输入%s", splitSureText))

	widgets.ok_btn:onClick(self, self.onSure)

	self.input_label = widgets.input_label
	self.editBox = widgets.editBox
	self.editBox:setMaxLength(string.len(splitSureText))
	self.editBox:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = self.editBox:getText()
			if str ~= "" then
				self.input_label:setText(str)
				self.editBox:setText("")
			else
				self.input_label:setText(string.format("请输入%s", splitSureText))
			end
		end
	end)
end

function wnd_baguaSplitSure:refresh(equips, getItems)
	self._equips = equips
	self._getItems = getItems
end

function wnd_baguaSplitSure:onSure(sender)
	local content =	self.input_label:getText()
	if content then
		if content ~= splitSureText then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17248, splitSureText))
		else
			i3k_sbean.request_eightdiagram_splite_req(self._equips, self._getItems)
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_baguaSplitSure.new()
	wnd:create(layout, ...)
	return wnd;
end

