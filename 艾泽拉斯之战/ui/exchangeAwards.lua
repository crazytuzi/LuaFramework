local exchangeAwards = class( "exchangeAwards", layout );

global_event.EXCHANGEAWARDS_SHOW = "EXCHANGEAWARDS_SHOW";
global_event.EXCHANGEAWARDS_HIDE = "EXCHANGEAWARDS_HIDE";

function exchangeAwards:ctor( id )
	exchangeAwards.super.ctor( self, id );
	self:addEvent({ name = global_event.EXCHANGEAWARDS_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.EXCHANGEAWARDS_HIDE, eventHandler = self.onHide});
end

function exchangeAwards:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.exchangeAwards_confirm = self:Child( "exchangeAwards-confirm" );
	self.exchangeAwards_cancel = self:Child( "exchangeAwards-cancel" );
	
	function onExchangeAwardConfirm()
		
		local exchangeAwards_input_account = self:Child( "exchangeAwards-input-account" );
		if exchangeAwards_input_account then
			
			local exchangeCode = exchangeAwards_input_account:GetText();
			-- check ok
			
			if exchangeCode == string.match(exchangeCode, "%w%w%w%w%w%w%w%w") then
			
				local exchangeAwards_confirm = self:Child( "exchangeAwards-confirm" );
				if exchangeAwards_confirm then
				
					local realCode = string.upper(exchangeCode);
					-- send
					print("exchangeCode "..realCode);
					
					sendAskGift(realCode);
					
					exchangeAwards_confirm:SetEnabled(false);
					
					self.timer = scheduler.scheduleGlobal(function() 
						local confirmButton = self:Child( "exchangeAwards-confirm" );
						if confirmButton then
							confirmButton:SetEnabled(true);
						end
						
						if self.timer and self.timer > 0 then
							scheduler.unscheduleGlobal(self.timer);
							self.timer = nil;
						end
						
					end, 5);
				end
							
			else
				eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "您输入的兑换码有误，请重新输入！"});
			end
		end
		
	end
	
	function onExchangeAwardCancel()
		self:onHide();
	end
	
	self.exchangeAwards_confirm:subscribeEvent("ButtonClick", "onExchangeAwardConfirm");
	self.exchangeAwards_cancel:subscribeEvent("ButtonClick", "onExchangeAwardCancel");
	
end

function exchangeAwards:onHide(event)
	
	if self.timer and self.timer > 0 then
		scheduler.unscheduleGlobal(self.timer);
		self.timer = nil;
	end
							
	self:Close();
end

return exchangeAwards;
