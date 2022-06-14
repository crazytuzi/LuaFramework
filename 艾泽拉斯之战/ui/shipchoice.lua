local shipchoice = class( "shipchoice", layout );

global_event.SHIPCHOICE_SHOW = "SHIPCHOICE_SHOW";
global_event.SHIPCHOICE_HIDE = "SHIPCHOICE_HIDE";

function shipchoice:ctor( id )
	shipchoice.super.ctor( self, id );
	self:addEvent({ name = global_event.SHIPCHOICE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SHIPCHOICE_HIDE, eventHandler = self.onHide});
end

function shipchoice:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	self.shipchoice_close = self:Child( "shipchoice-close" );
	self.shipchoice_close:subscribeEvent( "ButtonClick", "onClickClose" );


	function onClickClose()
		self:Quit();
	end
	
end

function shipchoice:onHide(event)
	self:Close();
end

function shipchoice:Quit()
	shiplogic.sceneDestory();
	game.EnterProcess( game.GAME_STATE_MAIN);
	self:onHide();
end

return shipchoice;
