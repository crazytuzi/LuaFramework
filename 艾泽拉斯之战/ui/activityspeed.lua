local activityspeed = class( "activityspeed", layout );

global_event.ACTIVITYSPEED_SHOW = "ACTIVITYSPEED_SHOW";
global_event.ACTIVITYSPEED_HIDE = "ACTIVITYSPEED_HIDE";
global_event.ACTIVITYSPEED_UPDATE = "ACTIVITYSPEED_UPDATE";

function activityspeed:ctor( id )
	activityspeed.super.ctor( self, id );
	self:addEvent({ name = global_event.ACTIVITYSPEED_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ACTIVITYSPEED_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ACTIVITYSPEED_UPDATE, eventHandler = self.updateInfo});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
end

function activityspeed:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	sendAskTopRank(enum.TOP_TYPE.TOP_TYPE_SPEED);
	function onClickActivitySpeedClose()
		self:onHide();
	end
	
	function onClickActivitySpeedRules()
		 eventManager.dispatchEvent({name = global_event.RULE_SHOW,battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED })
	end
	
	function onClickActivitySpeedStage(args)
		
		if global.tipBagFull() then
			return;
		end
			
		--local window = LORD.toWindowEventArgs(args).window;
		local stageIndex = dataManager.playerData:getSpeedChallengeStage();
				
		eventManager.dispatchEvent({name = global_event.ACTIVITYSTAGEINFO_SHOW, challengeBattleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED, stageIndex = stageIndex, });			
	end

	local activityspeed_go = self:Child("activityspeed-go");
	activityspeed_go:removeEvent("ButtonClick");
	activityspeed_go:subscribeEvent("ButtonClick", "onClickActivitySpeedStage");
		
	function onShowActivitySpeedMagicTips(args)
		local window = LORD.toWindowEventArgs(args).window;
		local userdata =  window:GetUserData();
		local rect = window:GetUnclippedOuterRect();
 		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "magic", id = userdata, tipXPosition = rect.left, tipYBottom = rect.top});
	end
	
	function onHideActivitySpeedMagicTips()
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	self.activityspeed_close = self:Child( "activityspeed-close" );
	self.activityspeed_close:subscribeEvent("ButtonClick", "onClickActivitySpeedClose");
	
	
	function onactivityspeed_shop()
		 	---商店
		global.openShop(enum.SHOP_TYPE.SHOP_TYPE_CONQUEST)
	end
	self.activityspeed_shop = self:Child( "activityspeed-shop" );
	self.activityspeed_shop:subscribeEvent("ButtonClick", "onactivityspeed_shop"); 
	
	
	
	local level = dataManager.playerData:getLevel()
	self.activityspeed_shop:SetVisible(level >= dataConfig.configs.ConfigConfig[0].shopLevelLimit)
	
	
	self.activityspeed_skill = {};
	self.activityspeed_skill_item = {};
	self.activityspeed_skill_used = {};
	
	for i=1, 4 do
		self.activityspeed_skill[i] = LORD.toStaticImage(self:Child( "activityspeed-skill"..i ));
		self.activityspeed_skill_used[i] = LORD.toStaticImage(self:Child( "activityspeed-skill"..i.."-used" ));
		self.activityspeed_skill_item[i] = LORD.toStaticImage(self:Child( "activityspeed-skill"..i.."-item" ));	
		global.onSkillTipsShow(self.activityspeed_skill_item[i], "magic", "top");
		global.onTipsHide(self.activityspeed_skill_item[i]);
	end
	
	self.activityspeed_round_num = self:Child( "activityspeed-round-num" );
	self.activityspeed_time_num = self:Child( "activityspeed-time-num" );
	self.activityspeed_rules = self:Child( "activityspeed-rules" );
	self.activityspeed_rules:subscribeEvent("ButtonClick", "onClickActivitySpeedRules");
	
	self.activityspeed_infor = self:Child( "activityspeed-infor" );

	function onClickActivitySpeedRank()
		eventManager.dispatchEvent({name = global_event.RANKINGLIST_SHOW, rankType = enum.RANK_LIST_TYPE.SPEED_RANK})
	end
	
	local activityspeed_rank = self:Child("activityspeed-rank");
	activityspeed_rank:subscribeEvent("ButtonClick", "onClickActivitySpeedRank");
	
	self:updateInfo();
end

function activityspeed:onHide(event)
	self:Close();
end

function activityspeed:updateInfo()
	
	if not self._show then
		return;
	end
	
	-- 更新魔法
	local magicData = dataManager.kingMagic;
	local greatMagic = magicData:getGreatMagic();
	for i=1, 4 do
		local magicInstance = magicData:getMagic(greatMagic[i]);
		if magicInstance and magicInstance:getConfig() then
			self.activityspeed_skill_item[i]:SetImage(magicInstance:getConfig().icon);
			self.activityspeed_skill_item[i]:SetUserData(greatMagic[i]);
			
			local userdata2 = dataManager.kingMagic:mergeLevelIntelligence(magicInstance:getStar(), dataManager.playerData:getIntelligence());
			self.activityspeed_skill_item[i]:SetUserData2(userdata2);
			
			if magicInstance:getExp() > 0 then
				-- 如果经验大于零就是没用过的
				self.activityspeed_skill_used[i]:SetVisible(false);
			else
				self.activityspeed_skill_used[i]:SetVisible(true);
			end
		else
			self.activityspeed_skill_item[i]:SetImage("");
		end
		
	end
	
	-- 更新关卡
	local playerData = dataManager.playerData;
	local currentStage = playerData:getSpeedChallengeStage();
	
	local activityspeed_totalnum = self:Child("activityspeed-totalnum");
	local bar = self:Child("activityspeed-bar");
	local barheight = bar:GetHeight().offset;
	local activityspeed_go = self:Child("activityspeed-go");
	
	activityspeed_totalnum:SetText("挑战进度："..(currentStage).."/8");
	bar:SetHeight(LORD.UDim(0, 86.14*(currentStage - 1)));
	bar:SetYPosition(LORD.UDim(0, 608-86.14*(currentStage - 1)));
	
	if currentStage == 8 then
		activityspeed_go:SetText("已完成");
		activityspeed_go:SetProperty("Touchable" , "false");
	end
	
	
	
	local activityspeed_chose_icon = LORD.toStaticImage(self:Child("activityspeed-chose-icon"));
	
	for i=1, 8 do
		
		local activityspeed_dis = self:Child("activityspeed-0"..i.."-dis");
		local activityspeed_chose = self:Child("activityspeed-0"..i.."-chose");
		local activityspeed_over = self:Child("activityspeed-0"..i.."-over")
		local icon = self:Child("activityspeed-0"..i.."-icon");
				
		if currentStage == (i-1) then
			
			activityspeed_dis:SetVisible(false);
			activityspeed_chose:SetVisible(true);
			activityspeed_over:SetVisible(false);
			
			local flag, propertyName, valueName = icon:GetProperty("ImageName", "");
			activityspeed_chose_icon:SetImage(valueName);
			
		elseif currentStage > (i-1) then

			activityspeed_dis:SetVisible(false);
			activityspeed_chose:SetVisible(false);
			activityspeed_over:SetVisible(true);
					
		elseif currentStage < (i-1) then

			activityspeed_dis:SetVisible(true);
			activityspeed_chose:SetVisible(false);
			activityspeed_over:SetVisible(false);
					
		end
		
	end
	
	if currentStage == 8 then
	
		local icon = self:Child("activityspeed-08-icon");
		local flag, propertyName, valueName = icon:GetProperty("ImageName", "");
		activityspeed_chose_icon:SetImage(valueName);
		
	end
	
	-- 信息
	local round = playerData:getSpeedChallegeRound()
	local failedTimes = playerData:getSpeedChallegeFailedCount();
	local maxTimes = playerData:getSpeedChallegeMaxFailedCount();

	self.activityspeed_round_num:SetText(round);
	self.activityspeed_time_num:SetText(failedTimes.."/"..maxTimes);
		
end

return activityspeed;
