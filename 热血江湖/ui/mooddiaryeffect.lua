-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_moodDiaryEffect = i3k_class("wnd_moodDiaryEffect", ui.wnd_base)

function wnd_moodDiaryEffect:ctor()

end

function wnd_moodDiaryEffect:configure()
	local widgets = self._layout.vars
	widgets.btn:onClick(self, self.onBtn)
	self._count = 0
end

function wnd_moodDiaryEffect:refresh(msg)
	local widgets = self._layout.vars
	widgets.tipWord:setText(msg)
end

function wnd_moodDiaryEffect:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_MoodDiaryEffect)
		end)
	end
end

function wnd_moodDiaryEffect:onBtn(sender)
	self._count = self._count + 1
	if self._count >= 2 then
		g_i3k_ui_mgr:CloseUI(eUIID_MoodDiaryEffect)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_moodDiaryEffect.new()
	wnd:create(layout, ...)
	return wnd;
end
