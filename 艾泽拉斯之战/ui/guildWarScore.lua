local guildWarScore = class( "guildWarScore", layout );

global_event.GUILDWARSCORE_SHOW = "GUILDWARSCORE_SHOW";
global_event.GUILDWARSCORE_HIDE = "GUILDWARSCORE_HIDE";

function guildWarScore:ctor( id )
	guildWarScore.super.ctor( self, id );
	self:addEvent({ name = global_event.GUILDWARSCORE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GUILDWARSCORE_HIDE, eventHandler = self.onHide});
end

function guildWarScore:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onGuildWarScoreClose()
		
		self:onHide();
		
	end
	
	local guildWarScore_close = self:Child("guildWarScore-close");
	guildWarScore_close:subscribeEvent("ButtonClick", "onGuildWarScoreClose");
	
	local guildWarScore_win = self:Child("guildWarScore-win");
	local guildWarScore_lose = self:Child("guildWarScore-lose");
	
	local guildWarScore_guildscore = self:Child("guildWarScore-guildscore");
	local guildWarScore_guildscore_num = self:Child("guildWarScore-guildscore-num");
	local guildWarScore_guildscore_arrow = self:Child("guildWarScore-guildscore-arrow");
	
	local guildWarScore_personalscore = self:Child("guildWarScore-personalscore");
	local guildWarScore_peisonalscore_num = self:Child("guildWarScore-peisonalscore-num");
	local guildWarScore_personalscore_arrow = self:Child("guildWarScore-personalscore-arrow");
	
	self.event = event;
	
	if event.isResult == true then
		-- 战斗结算
		guildWarScore_win:SetVisible(event.win);
		guildWarScore_lose:SetVisible(not event.win);
		
		local spot = dataManager.guildWarData:getSelectSpot();
		local oldGuildScore = 0;
		local oldPersonalScore = 0;
		local guildAddScore = 0;
		local personalAddScore = 0;
		
		if not event.win then
			-- 失败了，就是战败的积分变化
			oldGuildScore = dataManager.guildData:getGuildScore() - spot:getGuildLoseReward();
			oldPersonalScore = dataManager.guildData:getMyScore() - spot:getGuildLoseReward();
			
			guildAddScore = spot:getGuildLoseReward();
			personalAddScore = spot:getGuildLoseReward();
			
		else
			
			if dataManager.guildWarData:getBattleResultType() == enum.GUILD_WAR_BATTLE_RESULT.GUILD_WAR_BATTLE_RESULT_FINISH then

				oldGuildScore = dataManager.guildData:getGuildScore() - spot:getGuildBreakReward() - spot:getGuildWinReward();
				oldPersonalScore = dataManager.guildData:getMyScore() - spot:getGuildWinReward();
				
				guildAddScore = spot:getGuildBreakReward() + spot:getGuildWinReward();
				personalAddScore = spot:getGuildWinReward();				
				
			else
				
				oldGuildScore = dataManager.guildData:getGuildScore() - spot:getGuildWinReward();
				oldPersonalScore = dataManager.guildData:getMyScore() - spot:getGuildWinReward();
				
				guildAddScore = spot:getGuildWinReward();
				personalAddScore = spot:getGuildWinReward();
			
			end
		end
		
		guildWarScore_guildscore:SetText("公会积分:"..oldGuildScore);
		guildWarScore_personalscore:SetText("个人积分:"..oldPersonalScore);
		guildWarScore_guildscore_num:SetText(guildAddScore);
		guildWarScore_peisonalscore_num:SetText(personalAddScore);
		
	else
	
		-- 查看战绩
		guildWarScore_win:SetVisible(false);
		guildWarScore_lose:SetVisible(false);
		guildWarScore_guildscore_arrow:SetVisible(false);
		guildWarScore_personalscore_arrow:SetVisible(false);
		guildWarScore_guildscore_num:SetVisible(false);
		guildWarScore_peisonalscore_num:SetVisible(false);
		
		guildWarScore_guildscore:SetText("公会积分:"..dataManager.guildData:getGuildScore());
		guildWarScore_personalscore:SetText("个人积分:"..dataManager.guildData:getMyScore());
		
	end
	
	
	local rate = dataManager.guildData:getMyGuildRewardRate();
	local guildWarScore_bar = self:Child("guildWarScore-bar");
	guildWarScore_bar:SetProperty("Progress", rate/2);
	
end

function guildWarScore:onHide(event)

	if self.event.isResult == true then
		dataManager.guildWarData:onBattleOverBackToMain();
	end
		
	self:Close();
end

return guildWarScore;
