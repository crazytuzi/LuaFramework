-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_moodDiaryEffectRocket = i3k_class("wnd_moodDiaryEffectRocket", ui.wnd_base)

function wnd_moodDiaryEffectRocket:ctor()

end

function wnd_moodDiaryEffectRocket:configure()
	local widgets = self._layout.vars
	widgets.btn:onClick(self, self.onBtn)
	self._count = 0
end

function wnd_moodDiaryEffectRocket:refresh(msg)
	local widgets = self._layout.vars
	widgets.tipWord:setText(msg)
end

function wnd_moodDiaryEffectRocket:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai2
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_MoodDiaryEffectRocket)
		end)
	end
end

function wnd_moodDiaryEffectRocket:onBtn(sender)
	self._count = self._count + 1
	if self._count >= 2 then
		g_i3k_ui_mgr:CloseUI(eUIID_MoodDiaryEffectRocket)
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_moodDiaryEffectRocket.new()
	wnd:create(layout, ...)
	return wnd;
end
