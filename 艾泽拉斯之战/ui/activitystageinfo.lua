local activitystageinfo = class( "activitystageinfo", layout );

global_event.ACTIVITYSTAGEINFO_SHOW = "ACTIVITYSTAGEINFO_SHOW";
global_event.ACTIVITYSTAGEINFO_HIDE = "ACTIVITYSTAGEINFO_HIDE";

function activitystageinfo:ctor( id )
	activitystageinfo.super.ctor( self, id );
	self:addEvent({ name = global_event.ACTIVITYSTAGEINFO_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ACTIVITYSTAGEINFO_HIDE, eventHandler = self.onHide});
end

function activitystageinfo:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onClickActivitySpeedStart()
		
		if(global.tipBagFull())then
			return;
		end
			
		local playerData = dataManager.playerData;
		
		if not playerData:isSpeedChallegeCanStart() then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, textInfo = "今日已挑战结束，明日再来！" });
			self:onHide();
			return;
		end
				
		if  playerData:isSpeedChallegeStageCanStart(self.stageIndex) then
		
			global.changeGameState(function() 		
				sceneManager.closeScene();
				eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
				eventManager.dispatchEvent({name = global_event.ACTIVITY_HIDE});
				eventManager.dispatchEvent({name = global_event.ACTIVITYSPEED_HIDE});
				game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED, 
						planType = enum.PLAN_TYPE.PLAN_TYPE_CHALLENGE_SPEED });			
			
				self:onHide();
			end);
		end
	end
	
	function onClickActivityStageInfoClose()
		self:onHide();
	end
	
	function onClickActivityStageCopyStart()
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
				eventManager.dispatchEvent({name = global_event.ACTIVITYCOPY_HIDE});
				eventManager.dispatchEvent({name = global_event.ACTIVITY_HIDE});
						
				dataManager.playerData:setChallegeStageIndex(self.stageIndex);
				game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = self.challengeBattleType, planType = enum.PLAN_TYPE.PLAN_TYPE_CHALLENGE_SPEED});
				self:onHide();
			end)				
	end
	
	self.stageIndex = event.stageIndex;
	self.challengeBattleType = event.challengeBattleType;
	
	self.activitystageinfo_close = self:Child( "activitystageinfo-close" );
	self.activitystageinfo_title_text = self:Child( "activitystageinfo-title-text" );
	
	self.activitystageinfo_money = {};
	self.activitystageinfo_money_num = {};
	
	self.activitystageinfo_money[1] = LORD.toStaticImage(self:Child( "activitystageinfo-money1" ));
	self.activitystageinfo_money_num[1] = self:Child( "activitystageinfo-money1-num" );
	self.activitystageinfo_money[2] = LORD.toStaticImage(self:Child( "activitystageinfo-money2" ));
	self.activitystageinfo_money_num[2] = self:Child( "activitystageinfo-money2-num" );
	self.activitystageinfo_money[3] = LORD.toStaticImage(self:Child( "activitystageinfo-money3" ));
	self.activitystageinfo_money_num[3] = self:Child( "activitystageinfo-money3-num" );
	self.activitystageinfo_start = self:Child( "activitystageinfo-start" );
	self.activitystageinfo_scroll = LORD.toScrollPane(self:Child( "activitystageinfo-scroll" ));
	self.activitystageinfo_scroll:init();
	
	if self.challengeBattleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then
		self.activitystageinfo_start:subscribeEvent("ButtonClick", "onClickActivitySpeedStart");
		
		self:updateSpeedStageInfo();
	elseif self.challengeBattleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
				self.challengeBattleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or 
				self.challengeBattleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
				
		self.activitystageinfo_start:subscribeEvent("ButtonClick", "onClickActivityStageCopyStart");
		
		self:updateCopyStageInfo();
	end
	
	self.activitystageinfo_close:subscribeEvent("ButtonClick", "onClickActivityStageInfoClose");
	

	 
	
end

function activitystageinfo:onHide(event)
	self:Close();
end

--极速挑战的信息
function activitystageinfo:updateSpeedStageInfo()
	

	local playerData = dataManager.playerData;
	-- 标题栏
	local stageCount = self.stageIndex + 1;
	self.activitystageinfo_title_text:SetText("极速挑战第"..stageCount.."关");
	local stageInfo = playerData:getSpeedChallegeStageInfo(self.stageIndex);
	
	-- 开始按钮
	if playerData:isSpeedChallegeStageCanStart(self.stageIndex) then
		self.activitystageinfo_start:SetEnabled(true);
	else
		self.activitystageinfo_start:SetEnabled(false);
	end
	
	self:updateStageRewardInfo(stageInfo);
	
end

-- 副本挑战的信息
function activitystageinfo:updateCopyStageInfo()

	local playerData = dataManager.playerData;
		
	local stageInfo = playerData:getChallegeStageInfo(self.challengeBattleType, self.stageIndex);
	if not stageInfo then
		return;
	end
	-- 标题栏
	self.activitystageinfo_title_text:SetText(stageInfo.name);
	
	self:updateStageRewardInfo(stageInfo);
end

function activitystageinfo:updateStageRewardInfo(stageInfo)
	self.activitystageinfo_scroll:ClearAllItem();
	
	local playerData = dataManager.playerData;
	
	if not stageInfo then
		return;
	end

	for i=1, 3 do
		self.activitystageinfo_money[i]:SetImage("");
		self.activitystageinfo_money_num[i]:SetText("");
	end
	
	-- moneyIndex
	local moneyIndex = 1;
	local scrollPanelSize = self.activitystageinfo_scroll:GetPixelSize();
	local xPosition = LORD.UDim(0, 5);
	local yPosition = LORD.UDim(0, 5);
	
	local rewardRatio = 1;
						
	if stageInfo then
		for k,v in ipairs(stageInfo.rewardType) do
			local rewardInfo = playerData:getRewardInfo(v, stageInfo.rewardID[k], stageInfo.rewardCount[k]);
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY and self.activitystageinfo_money[moneyIndex] then
				self.activitystageinfo_money[moneyIndex]:SetImage(rewardInfo.icon);
				
				if global.needAdjustReward(stageInfo.needAdjust, v, rewardInfo.id) then
					rewardRatio = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel()).rewardRatio;
				end
				
				self.activitystageinfo_money_num[moneyIndex]:SetText(math.floor(rewardInfo.count*rewardRatio));
				moneyIndex = moneyIndex + 1;
			else
				
				local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("activitystageinfo-"..k, "itemini.dlg");

				item:SetXPosition(xPosition);
				item:SetYPosition(yPosition);				
				self.activitystageinfo_scroll:additem(item);
				
				local itemFrame = LORD.toStaticImage(self:Child("activitystageinfo-"..k.."_itemini"));
				local itemIcon = LORD.toStaticImage(self:Child("activitystageinfo-"..k.."_itemini-image"));
				
				if itemIcon then
					itemIcon:SetImage(rewardInfo.icon);
					global.setMaskIcon(itemIcon, rewardInfo.maskicon);
				end
				
				if itemFrame then
					itemFrame:SetImage(itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris));
				end

				-- 绑定tips事件
				itemIcon:SetUserData(stageInfo.rewardID[k]);
				
				if v == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
					itemIcon:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
				end
				
				global.onItemTipsShow(itemIcon, v, "top");
				global.onItemTipsHide(itemIcon);
								
				xPosition = xPosition + item:GetWidth() + LORD.UDim(0, 5);
				local xRightPosition = xPosition + item:GetWidth();
				if xRightPosition.offset > scrollPanelSize.x then
					xPosition = LORD.UDim(0,5);
					yPosition = yPosition + item:GetHeight() + LORD.UDim(0, 5);
				end
							
			end
		end
	end	
end

return activitystageinfo;
 