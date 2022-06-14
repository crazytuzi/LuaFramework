local transitionscene = class( "transitionscene", layout );

global_event.TRANSITIONSCENE_SHOW = "TRANSITIONSCENE_SHOW";
global_event.TRANSITIONSCENE_HIDE = "TRANSITIONSCENE_HIDE";

global_event.TRANSITIONSCENE_FADEOUT = "TRANSITIONSCENE_FADEOUT";

function transitionscene:ctor( id )
	transitionscene.super.ctor( self, id );
	self:addEvent({ name = global_event.TRANSITIONSCENE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.TRANSITIONSCENE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.TRANSITIONSCENE_FADEOUT, eventHandler = self.onBeginFadeOut});
	
	
	self.transitionsceneHandle = nil
end

function transitionscene:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	self.transitionscene = LORD.toStaticImage(self:Child( "transitionscene" ));
	local Alpha = event.Alpha or 0
	self.transitionscene:SetAlpha(Alpha)
	self.time = 0
	
end

function transitionscene:onBeginFadeOut(event)
	

	function transitionscene_transitionsceneTimeTick(dt)
		local alpha = self.transitionscene:GetAlpha()
		alpha  = alpha + dt*2
		self.time = self.time + dt 
		self.transitionscene:SetAlpha(alpha)
	    if(alpha >= 1 and self.time >= 1)	then
			eventManager.dispatchEvent({name = global_event.TRANSITIONSCENE_HIDE})
		end			
	end	
	
	if(self.transitionsceneHandle ~= nil)then
		scheduler.unscheduleGlobal(self.transitionsceneHandle)
		self.transitionsceneHandle = nil
	end
	
	if(self.transitionsceneHandle == nil)then
		self.transitionsceneHandle = scheduler.scheduleGlobal(transitionscene_transitionsceneTimeTick,0)
	end	
end

function transitionscene:onHide(event)
	self:Close();
	if(self.transitionsceneHandle ~= nil)then
		scheduler.unscheduleGlobal(self.transitionsceneHandle)
		self.transitionsceneHandle = nil
	end
 
end

return transitionscene;
