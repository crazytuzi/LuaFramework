local redEnvelopeResult = class( "redEnvelopeResult", layout );

global_event.REDENVELOPERESULT_SHOW = "REDENVELOPERESULT_SHOW";
global_event.REDENVELOPERESULT_HIDE = "REDENVELOPERESULT_HIDE";

global_event.REDENVELOPERESULT_UPDATE = "REDENVELOPERESULT_UPDATE";

function redEnvelopeResult:ctor( id )
	redEnvelopeResult.super.ctor( self, id );
	self:addEvent({ name = global_event.REDENVELOPERESULT_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.REDENVELOPERESULT_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.REDENVELOPERESULT_UPDATE, eventHandler = self.onUpdate});
end

function redEnvelopeResult:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	 
	self.redEnvelopeResult_effectopened = self:Child( "redEnvelopeResult-effectopened" );
	self.redEnvelopeResult_openbg = LORD.toStaticImage(self:Child( "redEnvelopeResult-openbg" ));
	self.redEnvelopeResult_effectclosed = self:Child( "redEnvelopeResult-effectclosed" );
	self.redEnvelopeResult_closed = LORD.toStaticImage(self:Child( "redEnvelopeResult-closed" ));
	self.redEnvelopeResult_open = self:Child( "redEnvelopeResult-open" );
	self.redEnvelopeResult_money = self:Child( "redEnvelopeResult-money" );
	self.money = 0
	
	function redEnvelopeResult_onClickCloseWindow()
	 		self:onHide();
	 end
	self._view:subscribeEvent("WindowTouchUp", "redEnvelopeResult_onClickCloseWindow");
	if(event and event.money)then
		self.money = event.money
	end
	self:Update()
end

function redEnvelopeResult:onHide(event)
	self:Close();
end

function redEnvelopeResult:Update()
	self:onUpdate()
end

function redEnvelopeResult:onUpdate(event)
	if not self._show then
		return;
	end
	self.redEnvelopeResult_money:SetText("гд"..self.money )
 
end




return redEnvelopeResult;
