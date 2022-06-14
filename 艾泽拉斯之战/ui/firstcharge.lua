local firstcharge = class( "firstcharge", layout );

global_event.FIRSTCHARGE_SHOW = "FIRSTCHARGE_SHOW";
global_event.FIRSTCHARGE_HIDE = "FIRSTCHARGE_HIDE";

function firstcharge:ctor( id )
	firstcharge.super.ctor( self, id );
	self:addEvent({ name = global_event.FIRSTCHARGE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.FIRSTCHARGE_HIDE, eventHandler = self.onHide});
end

function firstcharge:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onClickFirstChargeClose()
		self:onHide();
	end
	
	function onClickFirstChargeOK()
		local playerData = dataManager.playerData;
		if playerData:hasFinishedFirstCharge() then
			if global.tipBagFull() then
				return;
			end
			--领取,关闭,更新主界面
			sendSystemReward(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_FIRST_RECHARGE, -1);
			self:onHide();
		else
			eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
		end	
	end
	
	self.firstcharge_award_item = {};
	self.firstcharge_award_item_image = {};
	self.firstcharge_award_item_num = {};
	
	for i=1, 6 do
		self.firstcharge_award_item[i] = LORD.toStaticImage(self:Child( "firstcharge-award-item"..i ));
		self.firstcharge_award_item_image[i] = LORD.toStaticImage(self:Child( "firstcharge-award-item"..i.."-image" ));
		self.firstcharge_award_item[i]:SetVisible(false);
		self.firstcharge_award_item_num[i] = self:Child("firstcharge-award-item"..i.."-num");
		self.firstcharge_award_item_num[i]:SetText("");
	end
	
	self.firstcharge_award_money = {};
	self.firstcharge_award_money_num = {};
	
	for i=1, 3 do
		self.firstcharge_award_money[i] = LORD.toStaticImage(self:Child( "firstcharge-award-money"..i ));
		self.firstcharge_award_money_num[i] = self:Child( "firstcharge-award-money"..i.."-num" );
		self.firstcharge_award_money[i]:SetVisible(false);
	end
	
	self.firstcharge_close = self:Child( "firstcharge-close" );
	self.firstcharge_button = self:Child( "firstcharge-button" );
	
	self.firstcharge_close:subscribeEvent("ButtonClick", "onClickFirstChargeClose");
	self.firstcharge_button:subscribeEvent("ButtonClick", "onClickFirstChargeOK");
	
	self:updateButtonState();
	self:updateRewardInfo();
	

	local firstcharge_model_shadow = self:Child("firstcharge-model-shadow");
	if firstcharge_model_shadow then
		firstcharge_model_shadow:SetVisible(false);
	end
			
	local firstcharge_xiannvlong = LORD.toActorWindow(self:Child( "firstcharge-sexygirl" ));
	firstcharge_xiannvlong:SetActor("xiannvlongS_yanshi.actor", "idle");
	local timedelay = 0.001 * firstcharge_xiannvlong:SetSkillName("skill");
	
	
	firstcharge_xiannvlong:SetLevel(70);
	
	self.timer2 = scheduler.scheduleGlobal(function()
	
		local firstcharge_xiannvlong = LORD.toActorWindow(self:Child( "firstcharge-sexygirl" ));
		if firstcharge_xiannvlong then
			firstcharge_xiannvlong:SetLevel(30);
		end
		
		if self.timer2 and self.timer2 > 0 then
			scheduler.unscheduleGlobal(self.timer2)
			self.timer2 = nil;
		end
		
	end, 0.1);
	
	self.timer1 = scheduler.scheduleGlobal(function()
		
		local firstcharge_xiannvlong = LORD.toActorWindow(self:Child( "firstcharge-sexygirl" ));
		if firstcharge_xiannvlong then
			firstcharge_xiannvlong:SetSkillName("idle");
		end
		
		
		local firstcharge_model_shadow = self:Child("firstcharge-model-shadow");
		if firstcharge_model_shadow then
			firstcharge_model_shadow:SetVisible(true);
		end
		
		if self.timer1 and self.timer1 > 0 then
			scheduler.unscheduleGlobal(self.timer1)
			self.timer1 = nil;
		end
			
	end, timedelay);

	self.timer3 = scheduler.scheduleGlobal(function()
		
		local firstcharge_model_shadow = self:Child("firstcharge-model-shadow");
		if firstcharge_model_shadow then
			firstcharge_model_shadow:SetVisible(true);
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 0, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 1000);	
			firstcharge_model_shadow:playAction(action);	
		    
		end
		
		if self.timer3 and self.timer3 > 0 then
			scheduler.unscheduleGlobal(self.timer3)
			self.timer3 = nil;
		end
		LORD.SoundSystem:Instance():playEffect("_xiannvlong.mp3");	
	end, timedelay-4.5);
	
	self.timer4 = scheduler.scheduleGlobal(function() 
      
      local firstcharge_baobaoimage_effect = self:Child("firstcharge-baobaoimage-effect");
			firstcharge_baobaoimage_effect:SetEffectName("uitexiao_shouchong02.effect");
		
			if self.timer4 and self.timer4 > 0 then
				scheduler.unscheduleGlobal(self.timer4)
				self.timer4 = nil;
			end
		
  end, 4.5);
		
end

function firstcharge:onHide(event)
	
	if self.timer1 and self.timer1 > 0 then
		scheduler.unscheduleGlobal(self.timer1)
		self.timer1 = nil;
	end

	if self.timer2 and self.timer2 > 0 then
		scheduler.unscheduleGlobal(self.timer2)
		self.timer2 = nil;
	end

	if self.timer3 and self.timer3 > 0 then
		scheduler.unscheduleGlobal(self.timer3)
		self.timer3 = nil;
	end
	
	if self.timer4 and self.timer4 > 0 then
		scheduler.unscheduleGlobal(self.timer4)
		self.timer4 = nil;
	end
					
	self:Close();
end

function firstcharge:updateButtonState()
	local playerData = dataManager.playerData;
	if playerData:hasFinishedFirstCharge() then
		self.firstcharge_button:SetText("领  取");
	else
		self.firstcharge_button:SetText("充  值");
	end
end

function firstcharge:updateRewardInfo()
	local playerData = dataManager.playerData;
	local rewardTypes = dataConfig.configs.ConfigConfig[0].firstChargeRewardType;
	local rewardIDs = dataConfig.configs.ConfigConfig[0].firstChargeRewardID;
	local rewardCounts = dataConfig.configs.ConfigConfig[0].firstChargeRewardCount;
	
	local moneyRewardIndex = 1;
	local itemRewardIndex = 1;
	
	for k,v in ipairs(rewardTypes) do
		local rewardInfo = playerData:getRewardInfo(v, rewardIDs[k], rewardCounts[k]);
		if rewardInfo then
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY and self.firstcharge_award_money[moneyRewardIndex] then
				self.firstcharge_award_money[moneyRewardIndex]:SetVisible(true);
				self.firstcharge_award_money[moneyRewardIndex]:SetImage(rewardInfo.icon);
				self.firstcharge_award_money_num[moneyRewardIndex]:SetText(rewardInfo.count);
				
				moneyRewardIndex = moneyRewardIndex + 1;
			elseif self.firstcharge_award_item[itemRewardIndex] then
				self.firstcharge_award_item[itemRewardIndex]:SetVisible(true);
				self.firstcharge_award_item_image[itemRewardIndex]:SetImage(rewardInfo.icon);
				self.firstcharge_award_item[itemRewardIndex]:SetImage(itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris));
				
				global.setMaskIcon(self.firstcharge_award_item_image[itemRewardIndex], rewardInfo.maskicon);
				if rewardInfo.count > 1 then
					self.firstcharge_award_item_num[itemRewardIndex]:SetText(rewardInfo.count);
				else
					self.firstcharge_award_item_num[itemRewardIndex]:SetText("");
				end
				
				-- 绑定tips事件
				self.firstcharge_award_item_image[itemRewardIndex]:SetUserData(rewardIDs[k]);
				
				--dump(rewardInfo);
				--print("enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP "..enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP);
				--print("v "..v);
				
				if v == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
					--dump(rewardInfo);
					self.firstcharge_award_item_image[itemRewardIndex]:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
				end
												
				global.onItemTipsShow(self.firstcharge_award_item_image[itemRewardIndex], v, "top");
				global.onItemTipsHide(self.firstcharge_award_item_image[itemRewardIndex]);
		
				itemRewardIndex = itemRewardIndex + 1;
			end
		end

	end
	
end

return firstcharge;
