local confirm = class( "confirm", layout );

global_event.CONFIRM_SHOW = "CONFIRM_SHOW";
global_event.CONFIRM_HIDE = "CONFIRM_HIDE";

function confirm:ctor( id )
	confirm.super.ctor( self, id );
	self:addEvent({ name = global_event.CONFIRM_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CONFIRM_HIDE, eventHandler = self.onHide});
end

function confirm:onShow(event)
	if self._show then
		return;
	end
	self.call = event.callBack
	self.callOnCancel = event.callOnCancel
	event.text = event.text or ""
	self:Show();

	self.confirm_text = self:Child( "confirm-text" );
	self.confirm_yes = self:Child( "confirm-yes" );
	self.confirm_no = self:Child( "confirm-no" );
	
	function onconfirmClickNo()	
		self:onHide()
	 
	end

	self.confirm_no:subscribeEvent("ButtonClick", "onconfirmClickNo");
	
	function onconfirmClickSure()	
		self:Close()
		if(self.call)then
			self.call()
		end
		
		
		if self.messageType == enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND then
			-- ×êÊ¯²»×ã
			eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW, showcharge  = true});		
		end
	end
	
	
	
	self.messageType = event.messageType
	self.confirm_yes:subscribeEvent("ButtonClick", "onconfirmClickSure");
	self.confirm_text:SetText(event.text)
end

function confirm:onHide(event)
	self:Close();
		if(self.callOnCancel)then
			self.callOnCancel()
		end
end

return confirm;
