local redEnvelopeAsk = class( "redEnvelopeAsk", layout );

global_event.REDENVELOPEASK_SHOW = "REDENVELOPEASK_SHOW";
global_event.REDENVELOPEASK_HIDE = "REDENVELOPEASK_HIDE";

function redEnvelopeAsk:ctor( id )
	redEnvelopeAsk.super.ctor( self, id );
	self:addEvent({ name = global_event.REDENVELOPEASK_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.REDENVELOPEASK_HIDE, eventHandler = self.onHide});
end

function redEnvelopeAsk:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.redEnvelopeAsk_answer1 = self:Child( "redEnvelopeAsk-answer1" );
	self.redEnvelopeAsk_answer2 = self:Child( "redEnvelopeAsk-answer2" );
	self.redEnvelopeAsk_answer3 = self:Child( "redEnvelopeAsk-answer3" );
	self.redEnvelopeAsk_answer4 = self:Child( "redEnvelopeAsk-answer4" );
end

function redEnvelopeAsk:onHide(event)
	self:Close();
end

return redEnvelopeAsk;
