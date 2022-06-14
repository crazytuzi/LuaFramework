local rankingaward = class( "rankingaward", layout );

global_event.RANKINGAWARD_SHOW = "RANKINGAWARD_SHOW";
global_event.RANKINGAWARD_HIDE = "RANKINGAWARD_HIDE";

function rankingaward:ctor( id )
	rankingaward.super.ctor( self, id );
	self:addEvent({ name = global_event.RANKINGAWARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.RANKINGAWARD_HIDE, eventHandler = self.onHide});
end

function rankingaward:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.rankingaward_ranking_most_num = self:Child( "rankingaward-ranking-most-num" );
	self.rankingaward_ranking_now_num = self:Child( "rankingaward-ranking-now-num" );
	self.rankingaward_ranking_now_raise_num = self:Child( "rankingaward-ranking-now-raise-num" );
	self.rankingaward_award_num = self:Child( "rankingaward-award-num" );
	self.rankingaward_button = self:Child( "rankingaward-button" );
	
	
	local old = event.oldBestRank
	if(old== nil or old <= 0)then
		old =  dataConfig.configs.ConfigConfig[0].pvpOfflineMaxRank
		self.rankingaward_ranking_most_num:SetText(old.."+")	
	else
		self.rankingaward_ranking_most_num:SetText(old)		
	end

		
	self.rankingaward_ranking_now_num:SetText(event.newBestRank)	
	self.rankingaward_ranking_now_raise_num:SetText(  math.abs( event.newBestRank - old))		
	self.rankingaward_award_num:SetText(event.reward)	 
	
	function onClickCloseRankingaward()
		self:onHide()		
	end
		
	self.rankingaward_button:subscribeEvent("ButtonClick", "onClickCloseRankingaward")	  
	
end

function rankingaward:onHide(event)
	self:Close();
end

return rankingaward;
