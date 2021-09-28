-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_writeDiyHobby = i3k_class("wnd_writeDiyHobby", ui.wnd_base)

local labelText = "在此输入您想设置的爱好，最多可输入4个字"

function wnd_writeDiyHobby:ctor()
	self.isWrite = false
end

function wnd_writeDiyHobby:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.sure_btn:onClick(self, self.onPublish)
	widgets.input_label:setMaxLength(i3k_db_mood_diary_cfg.diyHobbyWordLimit)
	widgets.input_label:addEventListener(function(eventType)
		if eventType == "began" then
			local curText = widgets.label:getText()
			if curText ~= labelText then
				widgets.input_label:setText(curText)
			end
		elseif eventType == "ended" then
		    local text = widgets.input_label:getText()
			if text ~= "" then
				widgets.label:setText(text)
				widgets.input_label:setText("")
				self.isWrite = true
			else
				widgets.label:setText(labelText)
				self.isWrite = false
			end
	    end
	end)
end

function wnd_writeDiyHobby:refresh()
	self._layout.vars.label:setText(labelText)
end

function wnd_writeDiyHobby:onPublish(sender)
	if not self.isWrite then
		g_i3k_ui_mgr:PopupTipMessage("输入内容不能为空")
		return
	end
	local text = self._layout.vars.label:getText()
	local length = i3k_get_utf8_len(text)
	local withoutSpaceString = string.trim(text)
	local withoutSpaceLength = i3k_get_utf8_len(withoutSpaceString)
	if withoutSpaceLength == 0 then
		g_i3k_ui_mgr:PopupTipMessage("输入内容不能全为空格")
		return
	end
	if length > i3k_db_mood_diary_cfg.diyHobbyWordLimit then
		g_i3k_ui_mgr:PopupTipMessage("字数超过限制")
		return
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetHobby, "showHobbies", text)
	self:onCloseUI()
end


function wnd_create(layout)
	local wnd = wnd_writeDiyHobby.new()
	wnd:create(layout)
	return wnd
end
