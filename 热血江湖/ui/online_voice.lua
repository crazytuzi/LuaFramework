
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_online_Voice = i3k_class("wnd_online_Voice",ui.wnd_base)

function wnd_online_Voice:ctor()
	self._isOpenSpeak = false
	self._isOpenListen = false
	self._canStopSpeak = false
	self._longPressed_func = nil
end

function wnd_online_Voice:configure()

end

function wnd_online_Voice:refresh()
	local vars = self._layout.vars
	self._isOpenSpeak = false
	vars.listen:stateToPressed()
	local mapType = i3k_game_get_map_type()
	if g_FORCE_WAR == mapType or g_DESERT_BATTLE == mapType then
		vars.speak:onTouchEvent(self, self.onPressSpeak)
		self._isOpenListen = true
		vars.listen:onClick(self, self.onListenVoice)
	elseif g_TOURNAMENT == mapType then
	 	self._isOpenListen = true
	 	vars.speak:onClick(self, self.onOpenSpeak)
	 	vars.listen:onClick(self, self.onListenVoice)
	end
end

function wnd_online_Voice:onPressSpeak(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self._longPressed_func = function( )
			g_i3k_ui_mgr:OpenUI(eUIID_Volume)
		end
		self:startSpeak()
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self._longPressed_func = function( )
			g_i3k_ui_mgr:CloseUI(eUIID_Volume)
		end
		self:stopSpeak()
	end
end

function wnd_online_Voice:startSpeak( )
	if self._isOpenSpeak == false then
		-- g_i3k_game_handler:YayaStartSpeak()
	end
end

function wnd_online_Voice:stopSpeak( )
	if self._isOpenSpeak == true then
		-- g_i3k_game_handler:YayaStopSpeak()
	else
		self._canStopSpeak = true
	end
end

function wnd_online_Voice:onOpenSpeak(sender)
	if self._isOpenSpeak == true then
		-- g_i3k_game_handler:YayaStopSpeak()
		return
	end
	-- g_i3k_game_handler:YayaStartSpeak()
end

function wnd_online_Voice:onListenVoice(sender)
	if self._isOpenListen == true then
		self:Stop()
		return
	end
	self:Start()
end

function wnd_online_Voice:openOrCloseVolume()
	if self._longPressed_func then
		self._longPressed_func()
	end
end

function wnd_online_Voice:stopSpeakCallback()
	self._isOpenSpeak = false
	self._canStopSpeak = false
	self._layout.vars.speak:stateToNormal()
	self:openOrCloseVolume()
end

function wnd_online_Voice:startSpeakCallback()
	self._isOpenSpeak = true
	if self._canStopSpeak then
		self:stopSpeak()
		self._canStopSpeak = false
		return
	end
	self:openOrCloseVolume()
	self._layout.vars.speak:stateToPressed()
end

function wnd_online_Voice:Start()
	-- g_i3k_game_handler:YayaResumeLesten()
	self:startSpeak()
	self._isOpenListen = true
	self._layout.vars.speak:enable()
	self._layout.vars.listen:stateToPressed()
end

function wnd_online_Voice:Stop( )
	-- g_i3k_game_handler:YayaPauseLesten()
	self:stopSpeak()
	self._isOpenListen = false
	self._layout.vars.speak:disable()
	self._layout.vars.listen:stateToNormal()
end

function wnd_create(layout, ...)
	local wnd = wnd_online_Voice.new()
	wnd:create(layout, ...)
	return wnd;
end

