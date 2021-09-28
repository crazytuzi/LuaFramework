module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_countdownFenLei = i3k_class("wnd_countdownFenLei", ui.wnd_base)

function wnd_countdownFenLei:ctor()

end

function wnd_countdownFenLei:configure()
	self._flag = false
	local widgets = self._layout.vars
	widgets.tip_btn:onClick(self, self.noMovement)
	
	self._inteText = 
	{	
		[e_TYPE_LOVECLASSPART] = function()
			widgets.memoryCardTips:hide()
		end
	}
end

function wnd_countdownFenLei:onUpdate(dTime)	
end

function wnd_countdownFenLei:refresh(gameType)
	if gameType ~= nil and self._inteText[gameType] ~= nil then
		self._inteText[gameType]()
	end
end

function wnd_countdownFenLei:noMovement()
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16500))
end

function wnd_countdownFenLei:onHide()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_LoveClassPart, "startCountTime")
end

function wnd_create(layout)
	local wnd = wnd_countdownFenLei.new();
		wnd:create(layout);
	return wnd;
end
