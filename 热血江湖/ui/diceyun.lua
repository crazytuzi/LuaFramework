-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_diceYun = i3k_class("wnd_diceYun", ui.wnd_base)

function wnd_diceYun:ctor()

end

function wnd_diceYun:configure()

end

function wnd_diceYun:onShow()
end

function wnd_diceYun:refresh(data)
	self:setData(data)
end


function wnd_diceYun:setData(data)
	local scroll = self._layout.vars.yun_scroll
	local ui = require("ui/widgets/yunt")()
	scroll:addItem(ui)
	self._anisIn = ui.anis.c_yun2
	self._anisOut = ui.anis.c_yun_san
	self:playAnis(data)
end

function wnd_diceYun:playAnis(data)
	local anis = self._anisIn
	if anis then
		local callback1 = function()
			local anisOut = self._anisOut
			local callback2 = function()
				g_i3k_ui_mgr:CloseUI(eUIID_DiceYun)
			end
			if anisOut then
				anisOut.stop()
				anisOut.play(callback2)
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "jumpUI", data.page, data.steps)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "moveNextSteps", data.page, data.steps)
		end
		anis.stop()
		anis.play(callback1)
	end
end

function wnd_diceYun:refresh()

end


function wnd_create(layout, ...)
	local wnd = wnd_diceYun.new()
	wnd:create(layout, ...)
	return wnd;
end
