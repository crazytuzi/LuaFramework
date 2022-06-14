local guidedialogue = class( "guidedialogue", layout );

global_event.GUIDEDIALOGUE_SHOW = "GUIDEDIALOGUE_SHOW";
global_event.GUIDEDIALOGUE_HIDE = "GUIDEDIALOGUE_HIDE";

function guidedialogue:ctor( id )
	guidedialogue.super.ctor( self, id );
	self:addEvent({ name = global_event.GUIDEDIALOGUE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GUIDEDIALOGUE_HIDE, eventHandler = self.onHide});
end

function guidedialogue:onShow(event)
	
	
	--eventManager.dispatchEvent({name = global_event.REWARDGUIDE_SHOW,unitID = 1,text = "通关--------",func = func })
		 
	

	if self._show then
		self:Close();
	end
	local buttonShow = event.showButton or false
	
	self.callFun = event.func
	local text = event.text or ""
	self:Show();

	self.guidedialogue = LORD.toStaticImage(self:Child( "guidedialogue" ));
	self.guidedialogue_chacter = LORD.toStaticImage(self:Child( "guidedialogue-chacter" ));
	
	self.guidedialogue_container = LORD.toLayout (LORD.toStaticImage(self:Child( "guidedialogue-container" )));
	 
	
	self.guidedialogue_text = self:Child( "guidedialogue-text" );
	self.guidedialogue_text:SetText(text)

	self._view:SetLevel(100)
	if(event.pos)then
		self.guidedialogue:SetPosition(event.pos)
	end
	
	function onguidedialogueClick()
			self:onHide()
			if(	self.callFun)then
				self.callFun()
			end
	end
	self.guidedialogueButton = LORD.toStaticImage(self:Child( "guidedialogue-button" ));
	if(self.guidedialogueButton)then
		self.guidedialogueButton:subscribeEvent("ButtonClick", "onguidedialogueClick");	
		self.guidedialogueButton:SetVisible(buttonShow)
	end
	
	if(	self.guidedialogue_container)then
		self.guidedialogue_container:LayoutChild() 
	end
end

function guidedialogue:onHide(event)
	eventManager.dispatchEvent({name = global_event.REWARDGUIDE_HIDE})
	self:Close();
end

return guidedialogue;
