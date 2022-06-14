local speedreward = class( "speedreward", layout );

global_event.SPEEDREWARD_SHOW = "SPEEDREWARD_SHOW";
global_event.SPEEDREWARD_HIDE = "SPEEDREWARD_HIDE";

function speedreward:ctor( id )
	speedreward.super.ctor( self, id );
	self:addEvent({ name = global_event.SPEEDREWARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SPEEDREWARD_HIDE, eventHandler = self.onHide});
end

function speedreward:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onClickSpeedRewardClose()
		self:onHide();
	end
	
	self.speedreward_start = self:Child( "speedreward-start" );
	self.speedreward_start:subscribeEvent("ButtonClick", "onClickSpeedRewardClose");

	self:updateInfo();
	
end

function speedreward:onHide(event)
	self:Close();
end

function speedreward:updateInfo()
	
	if not self._show then
		return;
	end
	
	local round_text = self:Child("speedreward-round-text");
	local rank_text = self:Child("speedreward-rank-text");
	
	round_text:SetText(dataManager.speedChallegeRankData:getMyBattleRound());
	rank_text:SetText(dataManager.speedChallegeRankData:getMyRank());
	
end

return speedreward;
