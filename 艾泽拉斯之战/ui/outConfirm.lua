local outConfirm = class( "outConfirm", layout );

global_event.OUTCONFIRM_SHOW = "OUTCONFIRM_SHOW";
global_event.OUTCONFIRM_HIDE = "OUTCONFIRM_HIDE";

function outConfirm:ctor( id )
	outConfirm.super.ctor( self, id );
	self:addEvent({ name = global_event.OUTCONFIRM_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.OUTCONFIRM_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.INSTANCEJIESUAN_UI_SHOW, eventHandler = self.onHide});
	self:addEvent({ name = global_event.BATTLELOSE_SHOW, eventHandler = self.onHide});
end

function outConfirm:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.outConfirm_yes = self:Child( "outConfirm-yes" );
	self.outConfirm_no = self:Child( "outConfirm-no" );
	
	
	function outConfirmClickOk()	
		sceneManager.battlePlayer():CancelBattle();
		self:onHide()
	end

	self.outConfirm_yes:subscribeEvent("ButtonClick", "outConfirmClickOk");
	
	function outConfirmClickNo()	
		self:onHide()
	end

	self.outConfirm_no:subscribeEvent("ButtonClick", "outConfirmClickNo");
	sceneManager.battlePlayer():pauseGame(true);

end

function outConfirm:onHide(event)
	self:Close();
	sceneManager.battlePlayer():pauseGame(false);
end

return outConfirm;
