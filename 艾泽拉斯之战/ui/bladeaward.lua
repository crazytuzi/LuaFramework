local bladeaward = class( "bladeaward", layout );

global_event.BLADEAWARD_SHOW = "BLADEAWARD_SHOW";
global_event.BLADEAWARD_HIDE = "BLADEAWARD_HIDE";

function bladeaward:ctor( id )
	bladeaward.super.ctor( self, id );
	self:addEvent({ name = global_event.BLADEAWARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BLADEAWARD_HIDE, eventHandler = self.onHide});
end

function bladeaward:onShow(event)
	if self._show then
		return;
	end

	self:Show();

end

function bladeaward:onHide(event)
	self:Close();
end

return bladeaward;
