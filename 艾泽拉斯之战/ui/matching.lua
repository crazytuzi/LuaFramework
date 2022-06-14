local matching = class( "matching", layout );

global_event.MATCHING_SHOW = "MATCHING_SHOW";
global_event.MATCHING_HIDE = "MATCHING_HIDE";

function matching:ctor( id )
	matching.super.ctor( self, id );
	self:addEvent({ name = global_event.MATCHING_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MATCHING_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onBattleBeginHide});
  
	self.matchingHandle = nil
end

function matching:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.matching_countdown = self:Child( "matching-countdown" );
	self.matching_button1_1 = self:Child( "matching-button1_1" );
	
	
		
	function onClickCancelMatching()
		self:onHide();		
	end
	self.matching_countdown:SetText("")
	self.matching_button1_1:subscribeEvent("ButtonClick", "onClickCancelMatching");
	
	function matchingTimeTick(dt)
		self.tick = self.tick  or 0
		self.tick  = self.tick  + dt
		self.matching_countdown:SetText(formatTime(self.tick))
	end	
	
	if(self.matchingHandle == nil)then
		self.matchingHandle = scheduler.scheduleGlobal(matchingTimeTick,1)--global.goldMineInterval
	end	
	
end

function matching:onBattleBeginHide(event)
	if not self._show then
		return;
	end
	
	self:Close();
	if(self.matchingHandle ~= nil)then
		scheduler.unscheduleGlobal(self.matchingHandle)
		self.matchingHandle = nil
	end
	self.tick  = nil
end

function matching:onHide(event)
	
	if not self._show then
		return;
	end
	
	self:Close();
	if(self.matchingHandle ~= nil)then
		scheduler.unscheduleGlobal(self.matchingHandle)
		self.matchingHandle = nil
	end
	self.tick  = nil
	sendCancelWaitline(enum.WAITLINE_TYPE.WAITLINE_TYPE_PVP_ONLINE )
end

return matching;
