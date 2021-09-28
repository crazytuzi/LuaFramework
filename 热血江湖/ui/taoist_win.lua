-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_taoist_win = i3k_class("wnd_taoist_win", ui.wnd_base)

function wnd_taoist_win:ctor()
	
end

function wnd_taoist_win:configure()
	self._timeTick = 0
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		local hero = i3k_game_get_player_hero()
		if hero then
			hero._AutoFight = false
		end
		i3k_sbean.mapcopy_leave()
	end)
end

function wnd_taoist_win:onShow()
	
end

function wnd_taoist_win:refresh(addExp, addScore)
	self._layout.vars.expLabel:setText("+"..addExp)
	self._layout.vars.interalLabel:setText(string.format("积分+%d", addScore))
	local function callbackfun()
		g_i3k_logic:OpenTaoistUI()
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
end

--[[function wnd_taoist_win:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TaoistWin)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero._AutoFight = false
	end
	i3k_sbean.mapcopy_leave()
end--]]

function wnd_taoist_win:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	local timeLabel = self._layout.vars.coolTimeLabel
	if timeLabel then
		timeLabel:setText(math.ceil(i3k_db_taoist.autoCloseTime - self._timeTick))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_taoist_win.new()
	wnd:create(layout, ...)
	return wnd;
end
