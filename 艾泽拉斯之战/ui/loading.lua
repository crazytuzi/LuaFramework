local loading = class( "loading", layout );

global_event.LOADING_SHOW = "LOADING_SHOW";
global_event.LOADING_HIDE = "LOADING_HIDE";

function loading:ctor( id )
	loading.super.ctor( self, id );
	self:addEvent({ name = global_event.LOADING_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.LOADING_HIDE, eventHandler = self.onHide});
end

function loading:onShow(event)
	if self._show then
		return;
	end
	self.userdate = self.userdate or  event.userdate
	self:Show();
	
	--if event.notAutoHide ~= true then
	--	scheduler.performWithDelayGlobal(handler(self,self.onHide),5)
	--end
	
end

function loading:onHide(event)
	
	if(self.userdate ~= event.userdate )then
		return 
	end	
	self.userdate = nil
	self:Close();
end

return loading;
