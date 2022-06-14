local activitycopy = class( "activitycopy", layout );

global_event.ACTIVITYCOPY_SHOW = "ACTIVITYCOPY_SHOW";
global_event.ACTIVITYCOPY_HIDE = "ACTIVITYCOPY_HIDE";

function activitycopy:ctor( id )
	activitycopy.super.ctor( self, id );
	self:addEvent({ name = global_event.ACTIVITYCOPY_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ACTIVITYCOPY_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
end

function activitycopy:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onClickActivityCopyClose()
		self:onHide();
	end
	
	-- 切换tab页
	function onClickActivityCopyTab(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local battleType = window:GetUserData();
		
		if window:IsSelected() then
			self:onClickTabBattleType(battleType);
			self.activitycopy_type_chose1[battleType]:SetVisible(true);
			self.activitycopy_type_chose2[battleType]:SetVisible(true);
		else
			self.activitycopy_type_chose1[battleType]:SetVisible(false);
			self.activitycopy_type_chose2[battleType]:SetVisible(false);
		end
	end

	function onClickActivityCopyStart()
			if(global.tipBagFull())then
				return;
			end
			
			local  cd = dataManager.playerData:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_STAGE_CHALLENGE_COOLDOWN) 
			if(cd ~= nil )then	
				if(type(cd) == "userdata")then
					cd    = cd:GetUInt() 			
				end					
			end	
			cd = cd or 0
			local detal = cd  - dataManager.getServerTime()
			if(detal > 0 )then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, textInfo = "本挑战冷却中,请等待"..formatTime(detal, true).."时间后再来!" });	
				
				return 	
			end		
 			
			global.changeGameState(function() 
				eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
				eventManager.dispatchEvent({name = global_event.ACTIVITY_HIDE});
						
				dataManager.playerData:setChallegeStageIndex(self.stageIndex);
				game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = self.challengeBattleType, planType = enum.PLAN_TYPE.PLAN_TYPE_PVE});
				self:onHide();
			end)				
	end
			
	self.activitycopy_time_num = self:Child( "activitycopy-time-num" );
	self.activitycopy_cool_num = self:Child( "activitycopy-cool-num" );
	self.activitycopy_close = self:Child( "activitycopy-close" );
	self.activitycopy_Scroll = LORD.toScrollPane(self:Child("activitycopy-Scroll"));
	self.activitycopy_Scroll:init();
	--self.activitycopy_copy_image = LORD.toStaticImage(self:Child("activitycopy-copy-image"));
	--self.activitycopy_container = LORD.toStaticImage(self:Child("activitycopy-container"));
	self.activitycopy_start = self:Child("activitycopy-start");
	self.activitycopy_start:subscribeEvent("ButtonClick", "onClickActivityCopyStart");
	
	function onActivityCopyRule()
			 eventManager.dispatchEvent({name = global_event.RULE_SHOW,battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL })
	end
	self.activitycopy_rule = self:Child("activitycopy-rule");
	self.activitycopy_rule:subscribeEvent("ButtonClick", "onActivityCopyRule");
 
 
	self.activitycopy_type = {};
	self.activitycopy_type_chose1 = {};
	self.activitycopy_type_chose2 = {};
	
	for i=1, 3 do
		self.activitycopy_type[i] = LORD.toRadioButton(self:Child("activitycopy-type"..i));
		self.activitycopy_type[i]:subscribeEvent("RadioStateChanged", "onClickActivityCopyTab");		
	end
	
	self.activitycopy_type_chose1[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL] = self:Child("activitycopy-type1-chose1");
	self.activitycopy_type_chose2[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL] = self:Child("activitycopy-type1-chose2");
	
	self.activitycopy_type_chose1[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL]:SetVisible(true);
	self.activitycopy_type_chose2[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL]:SetVisible(true);
	
	self.activitycopy_type_chose1[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE] = self:Child("activitycopy-type2-chose1");
	self.activitycopy_type_chose2[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE] = self:Child("activitycopy-type2-chose2");
	
	self.activitycopy_type_chose1[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE]:SetVisible(false);
	self.activitycopy_type_chose2[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE]:SetVisible(false);
	
	self.activitycopy_type_chose1[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL] = self:Child("activitycopy-type3-chose1");
	self.activitycopy_type_chose2[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL] = self:Child("activitycopy-type3-chose2");
	self.activitycopy_type_chose1[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL]:SetVisible(false);
	self.activitycopy_type_chose2[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL]:SetVisible(false);
	
				
	self.activitycopy_type[1]:SetUserData(enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL);
	self.activitycopy_type[2]:SetUserData(enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE);
	self.activitycopy_type[3]:SetUserData(enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL);
	
	self.activitycopy_close:subscribeEvent("ButtonClick", "onClickActivityCopyClose");
	
	
	function onactivityCopy_shop()
		 	---商店
		global.openShop(enum.SHOP_TYPE.SHOP_TYPE_CONQUEST)
	end
	self.activitycopy_shop = self:Child( "activitycopy-shop" );
	self.activitycopy_shop:subscribeEvent("ButtonClick", "onactivityCopy_shop"); 
	
	
	--local level = dataManager.playerData:getLevel()
	--self.activitycopy_shop:SetVisible(level >= dataConfig.configs.ConfigConfig[0].shopLevelLimit)
	

	-- award
	self.activitycopy_award_money = {};
	self.activitycopy_award_money_num = {};
	
	for i=1, 3 do
		self.activitycopy_award_money[i] = LORD.toStaticImage(self:Child( "activitycopy-money"..i ));
		self.activitycopy_award_money_num[i] = self:Child( "activitycopy-money"..i.."-text" );	
	end
	
	self.activitycopy_item = {};
	self.activitycopy_item_image = {};
	self.activitycopy_item_equity = {};
	self.activitycopy_item_num = {};
	
	
	-- item award
	for i=1, 4 do
		self.activitycopy_item[i] = LORD.toStaticImage(self:Child("activitycopy-item"..i));
		self.activitycopy_item_image[i] = LORD.toStaticImage(self:Child("activitycopy-item"..i.."-image"));
		self.activitycopy_item_equity[i] = LORD.toStaticImage(self:Child("activitycopy-item"..i.."-equity"));
		self.activitycopy_item_num[i] = self:Child("activitycopy-item"..i.."-num")
	end
	
	function remainTimeTimerFun(dt)
		self:updateActivityInfo();
	end
	
	self.remainTimeTimer = scheduler.scheduleGlobal(remainTimeTimerFun, 1);
	self.stageIndex = 1;
	self.challengeBattleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL;
	
	self:initActivityInfo();
		
	-- 默认选中第一页
	self.activitycopy_type[1]:SetSelected(true);
	
	self:updateActivityInfo();
	
	--触发引导
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ACTIVITYCOPY_OPEN}) 
	--
	
end

function activitycopy:onHide(event)
	
	if self.remainTimeTimer and self.remainTimeTimer > 0 then
		scheduler.unscheduleGlobal(self.remainTimeTimer);
	end
	
	self:Close();
end

-- 更新活动信息
function activitycopy:updateActivityInfo()	
	local playerData = dataManager.playerData;
	local remineTime = playerData:getNextChallegeStageTime();
	local leftTime = playerData:getChallegeStageTimesLeft();
	self.activitycopy_cool_num:SetText(formatTime(remineTime, true));
	self.activitycopy_time_num:SetText(leftTime);
end

function activitycopy:onClickTabBattleType(battleType)
	self.challengeBattleType = battleType;
	
	self:onSelectStage(self.stageIndex);	
end

function activitycopy:initActivityInfo()

	self.activitycopy_Scroll:ClearAllItem();
	
	local playerData = dataManager.playerData;
	
	local stageCount = playerData:getChallegeStageCount(self.challengeBattleType);
	
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, 0);
	
	local selectYPos = 0;
	
	function onClickActivityCopyStage(args)
		local window = LORD.toWindowEventArgs(args).window;
		local stageIndex = window:GetUserData();
		
		self:onSelectStage(stageIndex);
	end
	
	local select = 1;
	
	for i=1, stageCount do
		local activitycopyitem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("-"..i, "activitycopyitem.dlg");		
		activitycopyitem:SetXPosition(xpos);
		activitycopyitem:SetYPosition(ypos);
		activitycopyitem:SetUserData(i);
		
		local lv = self:Child("-"..i.."_activitycopyitem-lv");
		local lv_text = self:Child("-"..i.."_activitycopyitem-lv-text");
		local name = self:Child("-"..i.."_activitycopyitem-name");
		local lock = self:Child("-"..i.."_activitycopyitem-lock");
		
		local lockBack = self:Child("-"..i.."_activitycopyitem-back-lock");
		local normalBack = self:Child("-"..i.."_activitycopyitem-back-narmal");
		local choseBack = self:Child("-"..i.."_activitycopyitem-back-chose");
		
		-- update info
		local stageInfo = playerData:getChallegeStageInfo(self.challengeBattleType, i);
		local levelLimit = playerData:getChallegeStageLevelLimit(self.challengeBattleType, i);
		local isLevelEnough = playerData:isChallegeStageLevelEnough(self.challengeBattleType, i);
		local isCanStart = playerData:isChallengeStageCanStart(self.challengeBattleType, i);		
		
		if stageInfo then

			name:SetText(stageInfo.name);
			lv_text:SetText(levelLimit);

			if isCanStart then
				lock:SetVisible(false);
				--lockBack:SetVisible(false);
				--normalBack:SetVisible(true);
				--choseBack:SetVisible(false);
				
				select = i;
				
				selectYPos = ypos.offset;

				activitycopyitem:subscribeEvent("WindowTouchUp", "onClickActivityCopyStage");
								
			else
				lock:SetVisible(true);
				--lockBack:SetVisible(true);
				--normalBack:SetVisible(false);
				--choseBack:SetVisible(false);
				
			end
			
			if isLevelEnough then
			
			else
				name:SetText("未开放");
			end
		end
				
		self.activitycopy_Scroll:additem(activitycopyitem);
		
		ypos = ypos + LORD.UDim(0, 115);
	end
	
	self.activitycopy_Scroll:SetVertScrollOffset(-selectYPos);
	self:onSelectStage(select);
end

function activitycopy:onSelectStage(stageIndex)
	
	self.stageIndex = stageIndex;
	
	local playerData = dataManager.playerData;
	local stageCount = playerData:getChallegeStageCount(self.challengeBattleType);
	
	for i=1, stageCount do
		
		local item = self:Child("-"..i.."_activitycopyitem");
		local chose = self:Child("-"..i.."_activitycopyitem-back-chose");
		local normal = self:Child("-"..i.."_activitycopyitem-back-narmal");
		local lock = self:Child("-"..i.."_activitycopyitem-back-lock");
		
		local isCanStart = playerData:isChallengeStageCanStart(self.challengeBattleType, i);
		local levelLimit = playerData:getChallegeStageLevelLimit(self.challengeBattleType, i);
		local stageInfoNew = playerData:getChallegeStageInfo(self.challengeBattleType, i);
						
		if item and chose and normal then
			
			chose:SetVisible(i == stageIndex );			
			lock:SetVisible(not isCanStart);
			
			normal:SetVisible(i ~= stageIndex and isCanStart );
						
		end
		
		local name = self:Child("-"..i.."_activitycopyitem-name");
		local lv = self:Child("-"..i.."_activitycopyitem-lv");
		local lv_text = self:Child("-"..i.."_activitycopyitem-lv-text");
		
		local textColor = "";
		if i == stageIndex and isCanStart then
			textColor = "^FFFFFF";
		elseif i ~= stageIndex and isCanStart then
			textColor = "^FFA200"
		elseif not isCanStart then
			textColor = "^5D5D5D"
		end
					
		name:SetText(textColor..stageInfoNew.name);
		lv:SetText(textColor.."Lv");
		lv_text:SetText(textColor..levelLimit);
		
	end
	
	local isCanStart = playerData:isChallengeStageCanStart(self.challengeBattleType, stageIndex);	
	
	self.activitycopy_start:SetEnabled(isCanStart);
	
	local stageInfo = playerData:getChallegeStageInfo(self.challengeBattleType, stageIndex);
	if stageInfo then
		local sceneInfo = dataConfig.configs.sceneConfig[stageInfo.sceneID];
		
		if sceneInfo then
			--self.activitycopy_copy_image:SetImage(sceneInfo.sceneImage);
			--self.activitycopy_container:SetImage(sceneInfo.sceneImage);
		end
		
		-- award
		for i=1, 3 do
			self.activitycopy_award_money[i]:SetImage("");
			self.activitycopy_award_money_num[i]:SetText("");
		end
				
		-- item award
		for i=1, 4 do
			self.activitycopy_item[i]:SetVisible(false);
		end
		
		-- moneyIndex
		local moneyIndex = 1;
		local itemIndex = 1;
		
		local rewardRatio = 1

		for k,v in ipairs(stageInfo.rewardType) do
			
			local rewardInfo = playerData:getRewardInfo(v, stageInfo.rewardID[k], stageInfo.rewardCount[k]);
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY and self.activitycopy_award_money[moneyIndex] then
				self.activitycopy_award_money[moneyIndex]:SetImage(rewardInfo.icon);
				
				if global.needAdjustReward(stageInfo.needAdjust, v, rewardInfo.id) then
					rewardRatio = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel()).rewardRatio;
				end
				
				self.activitycopy_award_money_num[moneyIndex]:SetText(math.floor(rewardInfo.count*rewardRatio));
				moneyIndex = moneyIndex + 1;
			else
				
				if self.activitycopy_item[itemIndex] then
					self.activitycopy_item[itemIndex]:SetVisible(true);
					
					self.activitycopy_item_image[itemIndex]:SetImage(rewardInfo.icon);
					global.setMaskIcon(self.activitycopy_item_image[itemIndex], rewardInfo.maskicon);
					self.activitycopy_item_equity[itemIndex]:SetImage(itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris));
					self.activitycopy_item[itemIndex]:SetImage(itemManager.getBackImage(rewardInfo.isDebris));
					
					if rewardInfo.count > 1 then
						self.activitycopy_item_num[itemIndex]:SetText(rewardInfo.count);
					else
						self.activitycopy_item_num[itemIndex]:SetText("");
					end
					
					-- 绑定tips事件
					self.activitycopy_item_image[itemIndex]:SetUserData(stageInfo.rewardID[k]);
					
					if v == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
						self.activitycopy_item_image[itemIndex]:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
					end
					
					global.onItemTipsShow(self.activitycopy_item_image[itemIndex], v, "top");
					global.onItemTipsHide(self.activitycopy_item_image[itemIndex]);
					
					itemIndex = itemIndex + 1;	
									
				end
						
			end
			
		end
	
	end
	
	
end

return activitycopy;
