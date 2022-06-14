local resource = class( "resource", layout );

global_event.RESOURCE_SHOW = "RESOURCE_SHOW";
global_event.RESOURCE_HIDE = "RESOURCE_HIDE";
global_event.RESOURCE_UPDATE = "RESOURCE_UPDATE";
global_event.RESOURCE_MONEY_CHANGE = "RESOURCE_MONEY_CHANGE";

function resource:ctor( id )
	resource.super.ctor( self, id );
	self:addEvent({ name = global_event.RESOURCE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.RESOURCE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.RESOURCE_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.RESOURCE_MONEY_CHANGE, eventHandler = self.onMoneyChange});	
	self:addEvent({ name = global_event.RESOURCE_SCALE_ICON, eventHandler = self.onScaleMoneyIcon});	
end

function resource:onShow(event)
	
	if self._show then
		self:checkVigorVisible(event.ownerView, true);
		self:updateLevel(event.level);
		return;
	end
	eventManager.dispatchEvent({name = global_event.INSTANCERESOURCE_SHOWHIDE,Visible = false})
	self:Show();

	self:updateLevel(event.level);
	
	function onResourceBuyDiamond()
		eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
	end
	
	function onResourceDiamondBuy(args)
		local window = LORD.toWindowEventArgs(args).window;
		local moneyType = window:GetUserData();
		
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = moneyType, copyType = -1, copyID = -1, });	
	end
	
	self.resource_jinbi_num = self:Child( "resource-jinbi-num" );
	self.resource_jinbi_image = LORD.toStaticImage(self:Child( "resource-jinbi-image" ));
	self.resource_jinbi_jiahao = self:Child( "resource-jinbi-jiahao" );
	
	function onResourceGoldTipsShow(args)
	
		local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", windowRect = rect, dir = "free", text = "金币: "..dataManager.playerData:getGold()});
	end

	function onResourceWoodTipsShow(args)
	
		local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", windowRect = rect, dir = "free", text = "木材: "..dataManager.playerData:getWood()});
	end

	function onResourceDiamondTipsShow(args)
	
		local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", windowRect = rect, dir = "free", text = "钻石: "..dataManager.playerData:getGem()});
	end
			
	function onResourceTipsHide()
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	self.resource_jinbi_num:subscribeEvent("WindowTouchDown", "onResourceGoldTipsShow");
	self.resource_jinbi_num:subscribeEvent("WindowTouchUp", "onResourceTipsHide");
	self.resource_jinbi_num:subscribeEvent("MotionRelease", "onResourceTipsHide");
	
	self.resource_mucai_num = self:Child( "resource-mucai-num" );
	self.resource_mucai_image = LORD.toStaticImage(self:Child( "resource-mucai-image" ));
	self.resource_mucai_jiahao = self:Child( "resource-mucai-jiahao" );
	
	self.resource_mucai_num:subscribeEvent("WindowTouchDown", "onResourceWoodTipsShow");
	self.resource_mucai_num:subscribeEvent("WindowTouchUp", "onResourceTipsHide");
	self.resource_mucai_num:subscribeEvent("MotionRelease", "onResourceTipsHide");
		
	self.resource_zuanshi_num = self:Child( "resource-zuanshi-num" );
	self.resource_zuanshi_image = LORD.toStaticImage(self:Child( "resource-zuanshi-image" ));
	self.resource_zuanshi_jiahao = self:Child( "resource-zuanshi-jiahao" );

	self.resource_zuanshi_num:subscribeEvent("WindowTouchDown", "onResourceDiamondTipsShow");
	self.resource_zuanshi_num:subscribeEvent("WindowTouchUp", "onResourceTipsHide");
	self.resource_zuanshi_num:subscribeEvent("MotionRelease", "onResourceTipsHide");
		
	self.resource_zuanshi_jiahao:subscribeEvent("ButtonClick", "onResourceBuyDiamond");
	self.resource_zuanshi_image:subscribeEvent("WindowTouchUp", "onResourceBuyDiamond");
	
	self.resource_jinbi_jiahao:subscribeEvent("ButtonClick", "onResourceDiamondBuy");
	self.resource_jinbi_jiahao:SetUserData(enum.BUY_RESOURCE_TYPE.GOLD);
	
	self.resource_mucai_jiahao:subscribeEvent("ButtonClick", "onResourceDiamondBuy");
	self.resource_mucai_jiahao:SetUserData(enum.BUY_RESOURCE_TYPE.WOOD);

	self.resource_jinbi_image:subscribeEvent("WindowTouchUp", "onResourceDiamondBuy");
	self.resource_jinbi_image:SetUserData(enum.BUY_RESOURCE_TYPE.GOLD);
	
	self.resource_mucai_image:subscribeEvent("WindowTouchUp", "onResourceDiamondBuy");
	self.resource_mucai_image:SetUserData(enum.BUY_RESOURCE_TYPE.WOOD);
	
	
	self.resource_jinbi_delta = self:Child("resource-jinbi-delta");
	self.resource_mucai_delta = self:Child("resource-mucai-delta");
	self.resource_zuanshi_delta = self:Child("resource-zuanshi-delta");
	self.resource_magic_delta = self:Child("resource-magic-delta");
	
	self.resource_tili = self:Child("resource-tili");
	self.resource_tili_num = self:Child("resource-tili-num");
	self.resource_tili_image = self:Child("resource-tili-image");
	self.resource_tili_jiahao = self:Child("resource-tili-jiahao");
	self.resource_tili_delta = self:Child("resource-tili-delta");

	self.resource_tili_jiahao:subscribeEvent("ButtonClick", "onResourceDiamondBuy");
	self.resource_tili_jiahao:SetUserData(enum.BUY_RESOURCE_TYPE.VIGOR);
		
	self:checkVigorVisible(event.ownerView, true);
	
	function _onResourceVigorTips(args)
	  local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "time", 
				windowRect = rect, dir = "right", offsetX = 0, offsetY = 0, });

	end
	
	self.resource_tili:removeEvent("WindowTouchDown");
	self.resource_tili:subscribeEvent("WindowTouchDown", "_onResourceVigorTips");
	global.onTipsHide(self.resource_tili);

	function vigorRefreshTickFunction()
		self:refreshVigor();
	end
		
	self.vigorRefreshTick = scheduler.scheduleGlobal(vigorRefreshTickFunction, 1);
		
	self:onUpdate();
end

function resource:refreshVigor()
	local isOverflow = dataManager.playerData:getVitality() >= dataManager.playerData:getVigorMax();
	if isOverflow then
		self.resource_tili_num:SetText( "^FFC124"..dataManager.playerData:getVitality().."^FFFFFF/"..dataManager.playerData:getVigorMax() )	
	else
		self.resource_tili_num:SetText( dataManager.playerData:getVitality().."/"..dataManager.playerData:getVigorMax() )	
	end
end

function resource:checkVigorVisible(ownerView, show)
	
	-- 策划说了，这个控件的在购买资源界面打开的时候才显示
	if self.resource_tili and ownerView and 
		(ownerView._config.name == "buyresource" or 
			ownerView._config.name == "task" or 
			ownerView._config.name == "pack")then
		self.resource_tili:SetVisible(show);
	end
	
	-- 已经不是简单的check 体力的显示了，魔法也要
	local resource_magic = self:Child("resource-magic");
	
	if resource_magic and ownerView then
		
		if ownerView._config.name == "buyresource" and ownerView.resType == enum.BUY_RESOURCE_TYPE.MAGIC then
			resource_magic:SetVisible(true);
			self.resource_tili:SetVisible(false);
		else
			resource_magic:SetVisible(false);
		end
		
	end
	
end

function resource:onUpdate(event)
	if self._show then
		self.resource_jinbi_num:SetText( formatMoney(dataManager.playerData:getGold()) )
		self.resource_mucai_num:SetText( formatMoney(dataManager.playerData:getWood()) )
		self.resource_zuanshi_num:SetText( formatMoney(dataManager.playerData:getGem()) )
		
		self:refreshVigor();
		
		-- magic
		local resource_magic = self:Child("resource-magic-num");
		resource_magic:SetText(dataManager.kingMagic:getExtraExp());
		
	end
end

function resource:calcMoney(oldMoney, newMoney)
	
	if newMoney > oldMoney then
		local result = oldMoney + math.ceil((newMoney - oldMoney)*0.1);
		if result >= newMoney then
			return -1;
		else
			return result;
		end
	elseif newMoney < oldMoney then
		local result = oldMoney + math.floor((newMoney - oldMoney)*0.1);
		if result <= newMoney then
			return -1;
		else
			return result;
		end
	else
		return -1;
	end
	
end

function resource:onMoneyChange(event)
	
	--dump(event);
	--print("onMoneyChange");
	
	function goldChangeFun(dt)
		local result = self:calcMoney(self.oldGold, self.newGold);
				
		if result == -1 then
			if self.goldTimerHandle then
				scheduler.unscheduleGlobal(self.goldTimerHandle);
				self.goldTimerHandle = nil;
			end
			
			self.resource_jinbi_num:SetText(formatMoney(dataManager.playerData:getGold()));   --formatMoney(self.newGold)
		else
			self.oldGold = result; 
			self.resource_jinbi_num:SetText(formatMoney(result));
		end
	end
	
	function woodChangeFun(dt)
		local result = self:calcMoney(self.oldWood, self.newWood);
		if result == -1 then
			if self.woodTimerHandle then
				scheduler.unscheduleGlobal(self.woodTimerHandle);
				self.woodTimerHandle = nil;
			end			
			self.resource_mucai_num:SetText(formatMoney(dataManager.playerData:getWood()));--self.newWood
		else
			self.oldWood = result; 
			self.resource_mucai_num:SetText(formatMoney(result));
		end	
	end
	
	function gemChangeFun(dt)
		local result = self:calcMoney(self.oldGem, self.newGem);
				
		if result == -1 then
			if self.gemTimerHandle then
				scheduler.unscheduleGlobal(self.gemTimerHandle);
				self.gemTimerHandle = nil;
			end
			
			self.resource_zuanshi_num:SetText(formatMoney(dataManager.playerData:getGem()));---self.newGem     
		else
			self.oldGem = result; 
			self.resource_zuanshi_num:SetText(formatMoney(result));
		end	
	end

	function magicExpChangeFun(dt)
	
		local result = self:calcMoney(self.oldMagicExp, self.newMagicExp);
				
		if result == -1 then
			if self.magicExpTimerHandle then
				scheduler.unscheduleGlobal(self.magicExpTimerHandle);
				self.magicExpTimerHandle = nil;
			end
			
			local resource_magic_num = self:Child("resource-magic-num");
			if resource_magic_num then
				resource_magic_num:SetText(formatMoney(self.newMagicExp));
			end
			
		else
			self.oldMagicExp = result; 
			local resource_magic_num = self:Child("resource-magic-num");
			if resource_magic_num then
				resource_magic_num:SetText(formatMoney(result));
			end
		end	
	end
		
	local deltaUI = nil;
	
	local updateTime = 0;
	if self._show then
	
		local flyMoneyCount = math.sqrt(event.newMoney-event.oldMoney);
		
		if flyMoneyCount > 20 then
			flyMoneyCount = 20;
		end
		
		if event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_GOLD then
		
			local delayTime = 0;
			
			if event.newMoney > event.oldMoney then
				local rect = self:Child("resource-jinbi-image"):GetUnclippedOuterRect();
				dataManager.moneyFlyManager:createMoneyFly(enum.MONEY_TYPE.MONEY_TYPE_GOLD, flyMoneyCount, LORD.Vector2(640, 360), LORD.Vector2(rect.left, rect.top));
				
				delayTime = 1.8;
			end

			scheduler.performWithDelayGlobal(function() 
				if self._show then
				
					if self.goldTimerHandle and self.goldTimerHandle > 0 then
						self.newGold = event.newMoney;
					else
						self.goldTimerHandle = scheduler.scheduleGlobal(goldChangeFun, updateTime);
						self.oldGold = event.oldMoney;
						self.newGold = event.newMoney;	
					end				
				
				end
			end, delayTime);
			
			if event.newMoney > event.oldMoney then
				self.resource_jinbi_delta:SetText("+"..(event.newMoney-event.oldMoney));
				self.resource_jinbi_delta:SetVisible(false);
			elseif event.newMoney < event.oldMoney then
				self.resource_jinbi_delta:SetText("-"..(event.oldMoney-event.newMoney));
				self.resource_jinbi_delta:SetVisible(true);
			else
				self.resource_jinbi_delta:SetVisible(false);
			end
			
			scheduler.performWithDelayGlobal(function() 
				if self._show then
					self.resource_jinbi_delta:SetVisible(false);
				end
			end, 2);	
						
		elseif event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_LUMBER then
			
			local delayTime = 0;
			
			if event.newMoney > event.oldMoney then
				local rect = self:Child("resource-mucai-image"):GetUnclippedOuterRect();
				dataManager.moneyFlyManager:createMoneyFly(enum.MONEY_TYPE.MONEY_TYPE_LUMBER, flyMoneyCount, LORD.Vector2(640, 360), LORD.Vector2(rect.left, rect.top));
				delayTime = 1.8;
			end

			scheduler.performWithDelayGlobal(function() 
				if self._show then
							
					if self.woodTimerHandle and self.woodTimerHandle > 0 then
						self.newWood = event.newMoney;
					else
						self.woodTimerHandle = scheduler.scheduleGlobal(woodChangeFun, updateTime);
						self.oldWood = event.oldMoney;
						self.newWood = event.newMoney;	
					end
							
				end
			end, delayTime);

			if event.newMoney > event.oldMoney then
				self.resource_mucai_delta:SetText("+"..(event.newMoney-event.oldMoney));
				self.resource_mucai_delta:SetVisible(false);
			elseif event.newMoney < event.oldMoney then
				self.resource_mucai_delta:SetText("-"..(event.oldMoney-event.newMoney));
				self.resource_mucai_delta:SetVisible(true);
			else
				self.resource_mucai_delta:SetVisible(false);
			end
			
			scheduler.performWithDelayGlobal(function() 
				if self._show then
					self.resource_mucai_delta:SetVisible(false);
				end
			end, 2);	
														
		elseif event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_DIAMOND then

			local delayTime = 0;
			
			if event.newMoney > event.oldMoney then
				local rect = self:Child("resource-zuanshi-image"):GetUnclippedOuterRect();
				dataManager.moneyFlyManager:createMoneyFly(enum.MONEY_TYPE.MONEY_TYPE_DIAMOND, flyMoneyCount, LORD.Vector2(640, 360), LORD.Vector2(rect.left, rect.top));
				
				delayTime = 1.8;
			end

			scheduler.performWithDelayGlobal(function() 
				if self._show then
				
					if self.gemTimerHandle and self.gemTimerHandle > 0 then
						self.newGem = event.newMoney;
					else
						self.gemTimerHandle = scheduler.scheduleGlobal(gemChangeFun, updateTime);
						self.oldGem = event.oldMoney;
						self.newGem = event.newMoney;	
					end		
				
				end
			end, delayTime);				
		
			
			if event.newMoney > event.oldMoney then
				self.resource_zuanshi_delta:SetText("+"..(event.newMoney-event.oldMoney));
				self.resource_zuanshi_delta:SetVisible(false);
			elseif event.newMoney < event.oldMoney then
				self.resource_zuanshi_delta:SetText("-"..(event.oldMoney-event.newMoney));
				self.resource_zuanshi_delta:SetVisible(true);
			else
				self.resource_zuanshi_delta:SetVisible(false);
			end
			
			scheduler.performWithDelayGlobal(function() 
				if self._show then
					self.resource_zuanshi_delta:SetVisible(false);
				end
			end, 2);		

		elseif event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_MAGICEXP then
		
				local delayTime = 0;
				
				if event.newMoney > event.oldMoney then
					local rect = self:Child("resource-magic-image"):GetUnclippedOuterRect();
					dataManager.moneyFlyManager:createMoneyFly(enum.MONEY_TYPE.MONEY_TYPE_MAGICEXP, flyMoneyCount, LORD.Vector2(640, 360), LORD.Vector2(rect.left, rect.top));
					
					delayTime = 1.8;
				end
	
				scheduler.performWithDelayGlobal(function() 
					if self._show then
					
						if self.magicExpTimerHandle and self.magicExpTimerHandle > 0 then
							self.newMagicExp = event.newMoney;
						else
							self.magicExpTimerHandle = scheduler.scheduleGlobal(magicExpChangeFun, updateTime);
							self.oldMagicExp = event.oldMoney;
							self.newMagicExp = event.newMoney;	
						end		
					
					end
				end, delayTime);				
			
				
				if event.newMoney > event.oldMoney then
					self.resource_magic_delta:SetText("+"..(event.newMoney-event.oldMoney));
					self.resource_magic_delta:SetVisible(false);
				elseif event.newMoney < event.oldMoney then
					self.resource_magic_delta:SetText("-"..(event.oldMoney-event.newMoney));
					self.resource_magic_delta:SetVisible(true);
				else
					self.resource_magic_delta:SetVisible(false);
				end
				
				scheduler.performWithDelayGlobal(function() 
					if self._show then
						self.resource_magic_delta:SetVisible(false);
					end
				end, 2);
					
		elseif event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_VIGOR then
			
			if event.newMoney > event.oldMoney then
				self.resource_tili_delta:SetText("+"..(event.newMoney-event.oldMoney));
				self.resource_tili_delta:SetVisible(false);
			elseif event.newMoney < event.oldMoney then
				self.resource_tili_delta:SetText("-"..(event.oldMoney-event.newMoney));
				self.resource_tili_delta:SetVisible(true);
			else
				self.resource_tili_delta:SetVisible(false);
			end
			
			scheduler.performWithDelayGlobal(function() 
				if self._show then
					self.resource_tili_delta:SetVisible(false);
				end
			end, 2);
						
		end
					
	end
end

function resource:onHide(event)
	
	self:checkVigorVisible(event.ownerView, false);
		
	eventManager.dispatchEvent({name = global_event.INSTANCERESOURCE_SHOWHIDE,Visible = true})
	if event.level == nil then
		
		if self.goldTimerHandle then
			scheduler.unscheduleGlobal(self.goldTimerHandle);
			self.goldTimerHandle = nil;
		end
			
		if self.woodTimerHandle then
			scheduler.unscheduleGlobal(self.woodTimerHandle);
			self.woodTimerHandle = nil;
		end

		if self.gemTimerHandle then
			scheduler.unscheduleGlobal(self.gemTimerHandle);
			self.gemTimerHandle = nil;
		end

		if self.magicExpTimerHandle then
			scheduler.unscheduleGlobal(self.magicExpTimerHandle);
			self.magicExpTimerHandle = nil;
		end
		
		if self.vigorRefreshTick and self.vigorRefreshTick > 0 then
			scheduler.unscheduleGlobal(self.vigorRefreshTick);
			self.vigorRefreshTick = -1;
		end
		
		self.resource_tili_delta = nil;
			
		self:Close();
	else
		self:updateLevel(event.level);
	end
end

function resource:updateLevel(level)
	
	if self._view then
		self._view:SetLevel(level);
	end
	
end

function resource:onScaleMoneyIcon(event)
	
	if not self._show then
		return;
	end
	
	--dump(event);
	
	if event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_GOLD then
		uiaction.scale(self.resource_jinbi_image);	
	elseif event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_LUMBER then
		uiaction.scale(self.resource_mucai_image);
	elseif event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_DIAMOND then
		uiaction.scale(self.resource_zuanshi_image);
	elseif event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_MAGICEXP then
	
		local resource_magic_image = self:Child("resource-magic-image");
		uiaction.scale(resource_magic_image);	
	end

end

return resource;
