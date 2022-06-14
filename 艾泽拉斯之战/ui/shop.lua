local shop = class( "shop", layout );

global_event.SHOP_SHOW = "SHOP_SHOW";
global_event.SHOP_HIDE = "SHOP_HIDE";
global_event.SHOP_UPDATE = "SHOP_UPDATE";
global_event.SHOP_ON_ASK_REFRESH = "SHOP_ON_ASK_REFRESH";

function shop:ctor( id )
	shop.super.ctor( self, id );
	self:addEvent({ name = global_event.SHOP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SHOP_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.SHOP_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.SHOP_ON_ASK_REFRESH, eventHandler = self.onAskRefresh});
	
	self.shopRefreshHandle = nil
end

function shop:onShow(event)
	if self._show then
		return;
	end
	
	self:Show();

	self.shop_zuanshi = LORD.toRadioButton(self:Child( "shop-zuanshi" ));
	self.shop_zuanshi_tishi = LORD.toStaticImage(self:Child( "shop-zuanshi-tishi" ));
	self.shop_secret = LORD.toRadioButton(self:Child( "shop-secret" ));
	self.shop_secret_tishi = LORD.toStaticImage(self:Child( "shop-secret-tishi" ));
	self.shop_shuaxin_time = self:Child( "shop-shuaxin-time" );
	self.shop_shuaxin_button = self:Child( "shop-shuaxin-button" );
	self.shop_close = self:Child( "shop-close" );
	
	self.shop_arena = LORD.toRadioButton(self:Child( "shop-arena" ));
	self.shop_activity = LORD.toRadioButton(self:Child( "shop-activity" ));
	self.shop_money = self:Child( "shop-money" );

	self.shop_money_num = self:Child( "shop-money-num" );
	self.shop_money_num:SetText("") 
	self.shop_money_image = LORD.toStaticImage(self:Child( "shop-money-image" ));
	
	function onShopMoneyTipsShow(args)
		
		local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		
		local shopType = clickImage:GetUserData();
		
		if shopType == enum.SHOP_TYPE.SHOP_TYPE_CONQUEST then
			eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", windowRect = rect, dir = "free", text = "勋章: "..dataManager.playerData:getConquest()});
		elseif shopType == enum.SHOP_TYPE.SHOP_TYPE_HONOR then
			eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", windowRect = rect, dir = "free", text = "荣誉: "..dataManager.playerData:getHonor()});
		end
			
	end
	
	function onShopMoneyTipsHide()
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
		
	self.shop_money_num:subscribeEvent("WindowTouchDown", "onShopMoneyTipsShow");
	self.shop_money_num:subscribeEvent("WindowTouchUp", "onShopMoneyTipsHide");
	self.shop_money_num:subscribeEvent("MotionRelease", "onShopMoneyTipsHide");
			
	self.choos = {}
	self.choos[enum.SHOP_TYPE.SHOP_TYPE_GOLD]  = self:Child( "shop-secret-chose" );
	self.choos[enum.SHOP_TYPE.SHOP_TYPE_DIAMOND]  = self:Child( "shop-zuanshi-chose" );
	self.choos[enum.SHOP_TYPE.SHOP_TYPE_CONQUEST]  = self:Child( "shop-activity-chose" );
	self.choos[enum.SHOP_TYPE.SHOP_TYPE_HONOR]  = self:Child( "shop-arena-chose" );
	
 
	
	
	
	
	
	
	self.shop_secretshop_wupin = {}
	self.shop_wupin_itemtu = {}
	self.shop_wupin_item = {}
	self.shop_secret_wupin_name = {}
	self.shop_secretshop_wupin_shouwan = {}
	self.shop_secretshop_wupin_zuanshi = {} 
	self.shop_secretshop_wupin_jiage = {}
	self.shop_wupin_goumai = {}
	self.shop_wupin_itemNum = {}
	self.shop_wupin_stars = {}
	function onClickBuyShopItem(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);		
		local userdata = window:GetUserData()
		if(userdata == -1)then
			return
		end
		local item = itemManager.getItemAndSpecial(userdata)	
		local mtype = item:getSaleMoney()
		
		
		if(dataManager.playerData:moneyIsEnough(mtype,item:getSalePrice()) == false)then
		
			if(mtype == enum.MONEY_TYPE.MONEY_TYPE_DIAMOND )then
				 			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
						messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = {count = item:getSalePrice()}, 
						text = "当前钻石不足，是否充值？" });	
			
			else
				local resType = nil
				
					if(mtype == enum.MONEY_TYPE.MONEY_TYPE_GOLD)then
						resType = enum.BUY_RESOURCE_TYPE.GOLD
					elseif(mtype == enum.MONEY_TYPE.MONEY_TYPE_LUMBER)then
						resType = enum.BUY_RESOURCE_TYPE.WOOD	
					elseif(mtype == enum.MONEY_TYPE.MONEY_TYPE_DIAMOND)then
							
					elseif(mtype == enum.MONEY_TYPE.MONEY_TYPE_VIGOR)then
						resType = enum.BUY_RESOURCE_TYPE.VIGOR
					end									
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = resType, copyType = -1, copyID = -1});				
			end		
			
			return
		end
		
		if(item:getSaleFinish() == false)then
			if(item:isSpecial() == false and global.tipBagFull())then
				return
			end	
			sendShopBuyItem(item:getPos(), item:getVec())	
		end								
	end
	
	
	for i = 1, 8 do
		self.shop_secretshop_wupin[i] = LORD.toStaticImage(self:Child( "shop-secretshop-wupin"..i ));
		
		self.shop_wupin_item[i] = LORD.toStaticImage(self:Child( "shop-secret-wupin"..i.."-item" ));
		self.shop_wupin_itemtu[i] = LORD.toStaticImage(self:Child( "shop-wupin"..i.."-itemtu" ));		
		
		self.shop_wupin_itemNum[i] = LORD.toStaticImage(self:Child( "shop-secret-wupin"..i.."-num" ));			
		
		self.shop_wupin_stars[i]  = {}
		for j =1 , 3 do
			self.shop_wupin_stars[i][j] = LORD.toStaticImage(self:Child( "shop-wupin"..i.."-star"..j ));		
			self.shop_wupin_stars[i][j]:SetVisible(false)
		end

		
		self.shop_secret_wupin_name[i] = self:Child( "shop-secret-wupin"..i.."-name" );
		self.shop_secretshop_wupin_shouwan[i] = LORD.toStaticImage(self:Child( "shop-secretshop-wupin"..i.."-shouwan" ));		
		self.shop_secretshop_wupin_zuanshi[i] = LORD.toStaticImage(self:Child( "shop-secretshop-wupin"..i.."-zuanshi" ));		
		self.shop_secretshop_wupin_jiage[i] = self:Child( "shop-secretshop-wupin"..i.."-jiage" );
		self.shop_wupin_goumai[i] = self:Child( "shop-wupin"..i.."-goumai" );	
		self.shop_wupin_goumai[i]:subscribeEvent("ButtonClick", "onClickBuyShopItem");	
	end	
	
	function onClickshop_refresh()
		local cost = global.getShopRefreshCost()
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
				messageType = enum.MESSAGE_DIAMOND_TYPE.REFRESH_SHOP, data = {count = cost,reFreshType = enum.SHOP_REFRESH.SHOP_REFRESH_DIAMOND,shopType = self.shopType}, 
				textInfo = "" });
	end	

	self.shop_shuaxin_button:subscribeEvent("ButtonClick", "onClickshop_refresh");
	function onClickshop_close()
		self:onHide()
	end
	self.shop_close:subscribeEvent("ButtonClick", "onClickshop_close");
	self.shop_shuaxin_time:SetText("") 
	
	
	function selectShop(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local shopType = window:GetUserData();	
		self.shopType  = 	shopType
		sendShopRefresh(enum.SHOP_REFRESH.SHOP_REFRESH_OPEN_WINDOWS, self.shopType )
		self:upDate();				
		
		for i,v in pairs(self.choos) do
		  if(v)then
			v:SetVisible(i == self.shopType )
		  end
			
		end
	end
	
	self.shop_zuanshi:subscribeEvent("RadioStateChanged", "selectShop");
	self.shop_zuanshi:SetUserData(enum.SHOP_TYPE.SHOP_TYPE_DIAMOND);
	self.shop_secret:subscribeEvent("RadioStateChanged", "selectShop");
	self.shop_secret:SetUserData(enum.SHOP_TYPE.SHOP_TYPE_GOLD);
	
	
	
	self.shop_arena:subscribeEvent("RadioStateChanged", "selectShop");
	self.shop_arena:SetUserData(enum.SHOP_TYPE.SHOP_TYPE_HONOR);
	self.shop_activity:subscribeEvent("RadioStateChanged", "selectShop");
	self.shop_activity:SetUserData(enum.SHOP_TYPE.SHOP_TYPE_CONQUEST);
	
	self.shopType = event.shopType or enum.SHOP_TYPE.SHOP_TYPE_GOLD;
	self.event = event;
	
	sendShopRefresh(enum.SHOP_REFRESH.SHOP_REFRESH_OPEN_WINDOWS, self.shopType )
	self:upDate()
	
	self.shop_secret:SetSelected(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_GOLD)
	self.shop_zuanshi:SetSelected(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_DIAMOND)
	
	self.shop_activity:SetSelected(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_CONQUEST)
	self.shop_arena:SetSelected(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_HONOR)
	
	self.shop_anniu = self:Child("shop-anniu");
	self.shop_anniu:SetVisible(event.shopType == nil);
	self.shop_wupinkuang = self:Child("shop-wupinkuang");
	self.shop_back = self:Child("shop-back");
	self.shop_back:SetVisible(event.shopType ~= nil);
	
	if event.shopType == nil then
		self.shop_wupinkuang:SetProperty("HorizontalAlignment", "Left");
	else
		self.shop_wupinkuang:SetProperty("HorizontalAlignment", "Centre");
	end
	
	function shopRefreshTimeTick(dt)
		local str = global.getShopRefreshTime()
		if(str ~= self.shop_shuaxin_time:GetText())then
			self.shop_shuaxin_time:SetText(str ) 
			sendShopRefresh(enum.SHOP_REFRESH.SHOP_REFRESH_OPEN_WINDOWS, self.shopType )
		end
	end
	if(self.shopRefreshHandle == nil)then
		self.shopRefreshHandle = scheduler.scheduleGlobal(shopRefreshTimeTick,5)
	end		
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_SHOP })
end

function shop:upDate()
	
	
	self.shop_money_num:SetText(str ) 
	local money = ""
	local mt = enum.MONEY_TYPE.MONEY_TYPE_GOLD
	 if(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_GOLD) then
		money = dataManager.playerData:getGold()
		mt = enum.MONEY_TYPE.MONEY_TYPE_GOLD
	 elseif(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_DIAMOND)then
		money = dataManager.playerData:getGem()
		 mt = enum.MONEY_TYPE.MONEY_TYPE_DIAMOND
	 elseif(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_CONQUEST)then
		money = dataManager.playerData:getConquest()
		mt = enum.MONEY_TYPE.MONEY_TYPE_CONQUEST
		
	 elseif(self.shopType ==  enum.SHOP_TYPE.SHOP_TYPE_HONOR)then
		money = dataManager.playerData:getHonor()
		mt = enum.MONEY_TYPE.MONEY_TYPE_HONOR	
	 end
	 
	 self.shop_money_num:SetUserData(self.shopType);
	 		
	 self.shop_money_num:SetText(formatMoney(money)); 
	 self.shop_money_image:SetImage(enum.MONEY_ICON_STRING[mt])
	 self.shop_money:SetVisible(mt ~= enum.MONEY_TYPE.MONEY_TYPE_GOLD and mt ~= enum.MONEY_TYPE.MONEY_TYPE_DIAMOND ) 	 
	
	local shopData = dataManager.shopData
	local shopnum = shopData:getItemNums(self.shopType)
	
	for i = 1, 	8 do
		local item = shopData:getItem(i-1,self.shopType) -- dataManager.bagData:getItem(i,enum.BAG_TYPE.BAG_TYPE_BAG)	
		self.shop_secretshop_wupin[i]:SetVisible(item ~= nil)	
		if(item)then
			self.shop_wupin_item[i]:SetImage(item:getImageWithStar())
			self.shop_wupin_itemtu[i]:SetImage(item:getIcon())
			
			local backImage = LORD.toStaticImage(self:Child("shop-secret-wupin"..i.."-back"));
			if backImage then
				backImage:SetImage(item:getBackImage());
			end
			
			local __star = item:getShowStar()
			for j =1 , 3 do
				self.shop_wupin_stars[i][j]:SetVisible(   j<= __star   )	
			end
			local count = item:getCount()	
			if(count > 1)then
				self.shop_wupin_itemNum[i]:SetText(count)
			else
				self.shop_wupin_itemNum[i]:SetText("")
			end
			-- 碎片的处理		
			global.setMaskIcon(self.shop_wupin_itemtu[i], item:getMaskIcon());
			
			self.shop_secret_wupin_name[i]:SetText(item:getName())
			self.shop_secretshop_wupin_shouwan[i]:SetVisible(item:getSaleFinish() == true)	
			self.shop_secretshop_wupin_zuanshi[i]:SetImage(item:getSaleMoneyIcon())
			self.shop_wupin_goumai[i]:SetUserData(item:getIndex())
			self.shop_secretshop_wupin_jiage[i]:SetText(item:getSalePrice())
			self.shop_wupin_goumai[i]:SetEnabled(item:getSaleFinish() ==false )
			
			local tipsType = nil;
			
			if item:isSpecial() then

				local userdata = item:getSubId();
				if item:isCardExp() then
					tipsType = enum.REWARD_TYPE.REWARD_TYPE_CARD_EXP;
				elseif item:isMagicExp() then
					tipsType = enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP;
					
					userdata = dataManager.kingMagic:mergeIDLevel(item:getSubId(), item:getStar());	
				end
				
				self.shop_wupin_itemtu[i]:SetUserData(userdata);		
				
				if(item:isDebris())then
					for j =1 , 3 do
							self.shop_wupin_stars[i][j]:SetVisible(false )	
					end
				else
					self.shop_wupin_itemNum[i]:SetText("")
				
				end
				
				
				
				
						
			else
				self.shop_wupin_itemtu[i]:SetUserData(item:getId());
				tipsType = enum.REWARD_TYPE.REWARD_TYPE_ITEM;
			end
			
			if tipsType then
				global.onItemTipsShow(self.shop_wupin_itemtu[i], tipsType, "top");
				global.onItemTipsHide(self.shop_wupin_itemtu[i]);
			end
			
		else
			self.shop_wupin_goumai[i]:SetUserData(-1)
		end	
	end	
		
	self.shop_shuaxin_time:SetText( global.getShopRefreshTime()) 
	
end


function shop:onUpdate(event)
	if self._show == false then
		return;
	end
	self:upDate()
end

function shop:onHide(event)
	self:Close();
	if(self.shopRefreshHandle ~= nil)then
		scheduler.unscheduleGlobal(self.shopRefreshHandle)
		self.shopRefreshHandle = nil
	end

	if self.event.shopType == nil then	
		homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.SHOP);
	end
end

function shop:onAskRefresh()
	
	if self._show and self.shopType and self.shopType >=0 then
		sendShopRefresh(enum.SHOP_REFRESH.SHOP_REFRESH_OPEN_WINDOWS, self.shopType );		
	end
	
end

return shop;
