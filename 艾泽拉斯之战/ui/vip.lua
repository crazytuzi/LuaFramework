local vip = class( "vip", layout );

global_event.VIP_SHOW = "VIP_SHOW";
global_event.VIP_HIDE = "VIP_HIDE";

function vip:ctor( id )
	vip.super.ctor( self, id );
	self:addEvent({ name = global_event.VIP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.VIP_HIDE, eventHandler = self.onHide});
end

function vip:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onClickVipClose()
		self:onHide();
	end
	
	self.vip_close = self:Child( "vip-close" );
	self.vip_text = self:Child( "vip-text" );
	
	self.vip_close:subscribeEvent("ButtonClick", "onClickVipClose");
end

function vip:onHide(event)
	self:Close();
end

return vip;
