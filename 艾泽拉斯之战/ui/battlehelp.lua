local battlehelp = class( "battlehelp", layout );

global_event.BATTLEHELP_SHOW = "BATTLEHELP_SHOW";
global_event.BATTLEHELP_HIDE = "BATTLEHELP_HIDE";

function battlehelp:ctor( id )
	battlehelp.super.ctor( self, id );
	self:addEvent({ name = global_event.BATTLEHELP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BATTLEHELP_HIDE, eventHandler = self.onHide});
end

function battlehelp:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.battlehelp_close = self:Child( "battlehelp-close" );
	
	self._view:subscribeEvent("WindowTouchUp", "onBattleHelpClose");
	
	function onBattleHelpClose()
		self:onHide();
	end
	
	self.battlehelp_close:subscribeEvent("ButtonClick", "onBattleHelpClose");
	
end

function battlehelp:onHide(event)
	self:Close();
	
	sceneManager.battlePlayer():pauseGame(false);
end

return battlehelp;
