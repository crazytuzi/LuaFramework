-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_taoist_lose = i3k_class("wnd_taoist_lose", ui.wnd_base)

function wnd_taoist_lose:ctor()
	
end

function wnd_taoist_lose:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		local hero = i3k_game_get_player_hero()
		if hero then
			hero._AutoFight = false
		end
		i3k_sbean.mapcopy_leave()
	end)
	self._timeTick = 0
end

function wnd_taoist_lose:onShow()
	
end

function wnd_taoist_lose:refresh(addExp, addScore)
	self._layout.vars.expLabel:setText("+"..addExp)
	self._layout.vars.interalLabel:setText(string.format("积分+%d", addScore))
	local function callbackfun()
		g_i3k_logic:OpenTaoistUI()
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
end

--[[function wnd_taoist_lose:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TaoistLose)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero._AutoFight = false
	end
	i3k_sbean.mapcopy_leave()
end--]]

function wnd_taoist_lose:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	local timeLabel = self._layout.vars.coolTimeLabel
	if timeLabel then
		timeLabel:setText(math.ceil(i3k_db_taoist.autoCloseTime - self._timeTick))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_taoist_lose.new()
	wnd:create(layout, ...)
	return wnd;
end
