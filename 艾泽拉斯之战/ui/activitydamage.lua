local activitydamage = class( "activitydamage", layout );

global_event.ACTIVITYDAMAGE_SHOW = "ACTIVITYDAMAGE_SHOW";
global_event.ACTIVITYDAMAGE_HIDE = "ACTIVITYDAMAGE_HIDE";
global_event.ACTIVITYDAMAGE_UPDATE = "ACTIVITYDAMAGE_UPDATE";


function activitydamage:ctor( id )
	activitydamage.super.ctor( self, id );
	self:addEvent({ name = global_event.ACTIVITYDAMAGE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ACTIVITYDAMAGE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ACTIVITYDAMAGE_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
end

function activitydamage:onShow(event)
	if self._show then
		return;
	end
	sendAskTopRank(enum.TOP_TYPE.TOP_TYPE_DAMAGE);
	self:Show();

	self.activitydamage_close = self:Child( "activitydamage-close" );
	self.activitydamage_boss_name = self:Child( "activitydamage-boss-name" );
	self.activitydamage_boss_skill = {}
	
	for i=1, 4 do
		self.activitydamage_boss_skill[i] = LORD.toStaticImage(self:Child( "activitydamage-boss-skill"..i.."-image" ));
		global.onSkillTipsShow(self.activitydamage_boss_skill[i], "skill", "top");
		global.onTipsHide(self.activitydamage_boss_skill[i]);
	end	

	self.activitydamage_rulebutton = self:Child( "activitydamage-rulebutton" );
	self.activitydamage_rankingbutton = self:Child( "activitydamage-rankingbutton" );
	self.activitydamage_start = self:Child( "activitydamage-start" );
	self.activitydamage_damage_num = self:Child( "activitydamage-damage-num" );
	self.activitydamage_rank_num = self:Child( "activitydamage-rank-num" );
	self.activitydamage_time_num = self:Child( "activitydamage-time-num" );
	
	function onActivitydamageClose()
		self:onHide();
	end
	self.activitydamage_close:subscribeEvent("ButtonClick", "onActivitydamageClose");
	
	function onActivitydamageRule()
			 eventManager.dispatchEvent({name = global_event.RULE_SHOW,battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE })
	end
	self.activitydamage_rulebutton:subscribeEvent("ButtonClick", "onActivitydamageRule"); 
	
	function onActivitydamageRanking()
		 eventManager.dispatchEvent({name = global_event.RANKINGLIST_SHOW, rankType = enum.RANK_LIST_TYPE.DAMAGE_RANK})
	end
	
	self.activitydamage_rankingbutton:subscribeEvent("ButtonClick", "onActivitydamageRanking"); 
	
	
	function onactivitydamage_shop()
		 	---…ÃµÍ
		global.openShop(enum.SHOP_TYPE.SHOP_TYPE_CONQUEST)
	end
	self.activitydamage_shop = self:Child( "activitydamage-shop" );
	self.activitydamage_shop:subscribeEvent("ButtonClick", "onactivitydamage_shop"); 
	
 
	local level = dataManager.playerData:getLevel()
	self.activitydamage_shop:SetVisible(level >= dataConfig.configs.ConfigConfig[0].shopLevelLimit)
	
	function onActivitydamageStar()
		
		if not dataManager.hurtRankData:isBattleNumEnough() then
			 eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, textInfo =  dataManager.hurtRankData:getNoBattleNumTipDes() });
			return 
		end		
		
		if not dataManager.hurtRankData:isOpenTime() then
			 eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, textInfo =  dataManager.hurtRankData:getCloseTipDes() });
			return
		end	
		
		global.changeGameState(function() 
			local btype =  enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE
			sceneManager.closeScene();
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			eventManager.dispatchEvent({name = global_event.ACTIVITY_HIDE});			
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = btype, 
						planType = enum.PLAN_TYPE.PLAN_TYPE_CHALLENGE_DAMAGE });--PLAN_TYPE_CHALLENGE		
			self:onHide();
		end);	
	end
	self.activitydamage_start:subscribeEvent("ButtonClick", "onActivitydamageStar"); 
  
	self:update()
end


function activitydamage:onUpdate()
	self:update()
end	
function activitydamage:update()
	if not self._show then
		return;
	end
	
	local figureBackMap = {
		[369] = "set:activity4.xml image:rolelight2",
		[370] = "set:activity4.xml image:rolelight1",
		[371] = "set:activity4.xml image:rolelight2",
		[372] = "set:activity4.xml image:rolelight1",
		[373] = "set:activity4.xml image:rolelight2",
		[374] = "set:activity4.xml image:rolelight1",
		[375] = "set:activity4.xml image:rolelight2",
		[376] = "set:activity4.xml image:rolelight1",
	};

	local figureMap = {
		[369] = "rolebig9.png",
		[370] = "rolebig9.png",
		[371] = "avtivityrole4.png",
		[372] = "avtivityrole4.png",
		[373] = "avtivityrole1.png",
		[374] = "avtivityrole1.png",
		[375] = "avtivityrole2.png",
		[376] = "avtivityrole2.png",
	};
		
	
	local unitId = dataManager.hurtRankData:getBossId()

	local activitydamage_role = LORD.toStaticImage(self:Child("activitydamage-role"));
	local activitydamage_role_image = LORD.toStaticImage(self:Child("activitydamage-role-image"));
	activitydamage_role:SetImage(figureMap[unitId]);
	activitydamage_role_image:SetImage(figureBackMap[unitId]);
		
	local unitInfo = dataConfig.configs.unitConfig[unitId];
	
	-- ≤•∑≈“Ù–ß
	cardData.playVoiceByUnitID(unitId);
	
	if unitInfo then
		self.activitydamage_boss_name:SetText(unitInfo.name)
		for i=1, 4 do
			self.activitydamage_boss_skill[i]:SetImage("")
		end	
		for i=1, 4 do
			if unitInfo.skill[i] then
				local skillInfo = dataConfig.configs.skillConfig[unitInfo.skill[i]]
				if skillInfo then
					self.activitydamage_boss_skill[i]:SetImage(skillInfo.icon)
					self.activitydamage_boss_skill[i]:SetUserData(skillInfo.id);
					self.activitydamage_boss_skill[i]:SetVisible(true);
					--skillInfo.name 
				end
			else
				self.activitydamage_boss_skill[i]:SetImage("");
				self.activitydamage_boss_skill[i]:SetVisible(false);
			end
		end		
	end	
	
	
	local sa ,sb = dataManager.hurtRankData:getScore()
	self.activitydamage_damage_num:SetText(sb)

	local rank,_rank = dataManager.hurtRankData:getRanking()
	self.activitydamage_rank_num:SetText(rank)
	local num = dataManager.hurtRankData:getBattleNum()
	local maxNum = dataManager.hurtRankData:getMaxBattleNum()
	
	self.activitydamage_time_num:SetText(  (maxNum - num ).."/"..maxNum)
	
end

function activitydamage:onHide(event)
	self:Close();
end

return activitydamage;
