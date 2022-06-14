local buyresource = class( "buyresource", layout );

global_event.BUYRESOURCE_SHOW = "BUYRESOURCE_SHOW";
global_event.BUYRESOURCE_HIDE = "BUYRESOURCE_HIDE";
global_event.BUYRESOURCE_UPDATE = "BUYRESOURCE_UPDATE";

function buyresource:ctor( id )
	buyresource.super.ctor( self, id );
	self:addEvent({ name = global_event.BUYRESOURCE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BUYRESOURCE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.BUYRESOURCE_UPDATE, eventHandler = self.updateBuyInfo});
end

function buyresource:onShow(event)
	if self._show then
		return;
	end
 
	if(event.resType == enum.BUY_RESOURCE_TYPE.VIGOR and  event.source ==  "lackofresource" )then
		local num = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG,530)
		
		function _useItemWithVigor() 
			local item = dataManager.bagData:getItemWithTableId(enum.BAG_TYPE.BAG_TYPE_BAG,530)
			if(item)then
				sendUseItem(enum.USE_ITEM_OPCODE.USE_ITEM_OPCODE_USE, item:getPos())
			end
		end
		if(num > 0)then
				local item = dataManager.bagData:getItemWithTableId(enum.BAG_TYPE.BAG_TYPE_BAG,530)
				local text = "当前体力不足，是否使用【"..item:getName().."】？#n#n剩余【"..num.."】个";
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW,textInfo = text ,callBack = _useItemWithVigor})
			return 
		end	
	end

	-- 来源是主动点，还是不足的时候弹出userclick, lackofresource
	self.source = event.source;
	-- 资源类型 enum.BUY_RESOURCE_TYPE 这个枚举的定义
	self.resType = event.resType;
	-- 副本类型
	self.copyType = event.copyType;
	-- 副本id
	self.copyID = event.copyID;
	
	self:Show();
	
	function onClickBuyResClose()
		self:onHide();
	end
	
	function onClickBuyResVipInfo()
		eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW,showcharge = false});
	end
	
	function onClickBuyResPurchase()
		eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
	end

	function onClickBuyResBuy()
		
		local buyResPriceData  = dataManager.buyResPriceData;
		local isEnoughDiamond = buyResPriceData:isDiamondEnough(self.resType, self.copyType, self.copyID);
		
		if isEnoughDiamond then
			
			if self.resType == enum.BUY_RESOURCE_TYPE.GOLD then
				sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_GOLD, -1);
			elseif self.resType == enum.BUY_RESOURCE_TYPE.WOOD then
				sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_LUMBER, -1);
			elseif self.resType == enum.BUY_RESOURCE_TYPE.VIGOR then
				sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_VIGOR, -1);
				
			elseif self.resType == enum.BUY_RESOURCE_TYPE.MAGIC then
				
				sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_MAGIC_EXP, -1);
								
			elseif self.resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
				
				if self.copyType == enum.ADVENTURE.ADVENTURE_NORMAL then
					sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_ADVENTURE_NORMAL, self.copyID);
				elseif self.copyType == enum.ADVENTURE.ADVENTURE_ELITE then
					sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_ADVENTURE_ELITE, self.copyID);
				end
				self:onHide();
			
			elseif self.resType == enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES then
				
				sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_PLUNDER_TIMES, -1);
				self:onHide();
			
			elseif self.resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE then
			
				sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_GUILDWAR_COUNT, -1);
				self:onHide();
				
			elseif self.resType == enum.BUY_RESOURCE_TYPE.PROTECT_TIME then
				
				sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_PROTECT_TIME, -1);
				self:onHide();
					
			end
					
		else
		
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
					
			--eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
		end
	end
			
	self.buyresource_close = self:Child( "buyresource-close" );
	self.buyresource_close:subscribeEvent("ButtonClick", "onClickBuyResClose");
	
	self.buyresource_text = self:Child( "buyresource-text" );
	
	self.buyresource_button1 = self:Child( "buyresource-button1" );
	self.buyresource_button1:subscribeEvent("ButtonClick", "onClickBuyResBuy");
	
	self.buyresource_button2 = self:Child( "buyresource-button2" );
	self.buyresource_button2:subscribeEvent("ButtonClick", "onClickBuyResVipInfo");
	
	self.buyresource_button3 = self:Child( "buyresource-button3" );
	self.buyresource_button3:subscribeEvent("ButtonClick", "onClickBuyResPurchase");
	
	self.buyresource_buynum = self:Child( "buyresource-buynum" );
	--self.buyresource_buynum_num = self:Child( "buyresource-buynum-num" );
	self.buyresource_resource = self:Child( "buyresource-resource" );
	self.buyresource_diamond_num = self:Child( "buyresource-diamond-num" );
	self.buyresource_money = LORD.toStaticImage(self:Child( "buyresource-money" ));
	self.buyresource_money_num = self:Child( "buyresource-money-num" );
	self.buyresource_viptext = self:Child( "buyresource-viptext" );
	self.buyresource_viptext2 = self:Child( "buyresource-viptext2" );
	self.buyresource_tips = self:Child("buyresource-tips");
	self.buyresource_diamond_copy = self:Child("buyresource-diamond-copy");
	self.buyresource_diamond_copy_num = self:Child("buyresource-diamond-copy-num");
	
	self:updateBuyInfo(event);
	
	-- test action
	uiaction.popup(self._view);
	
end

function buyresource:onHide(event)
	--self:Close();
	
	uiaction.goback(self._view, self);
end

function buyresource:updateBuyInfo(event)

	if not self._show then
		return;
	end
		
	local source = self.source;
	local resType = self.resType;
	local copyType = self.copyType;
	local copyID = self.copyID;
	
	local resText = "";
	local buyTimesText = "";
	-- 玩家数据
	local buyResPriceData  = dataManager.buyResPriceData;
	local maxTimes = buyResPriceData:getMaxBuyResourceTimes(resType);
	local canBuyTimes = buyResPriceData:getCanBuyResourceTimes(resType, copyType, copyID);
	if canBuyTimes == 0 then
		buyTimesText = "^FF0000"..canBuyTimes.."^FFFFFF/"..maxTimes;
	else
		buyTimesText = canBuyTimes.."/"..maxTimes;
	end

	-- 购买的数量
	local canBuyNumber = buyResPriceData:getCanBuyResourceNumber(resType, copyType, copyID);
	
	print("canBuyNumber   "..canBuyNumber)
		
	local canBuyResNum = "";
	-- tips 信息
	local tipsInfo = "";
	
	if resType == enum.BUY_RESOURCE_TYPE.GOLD then
		resText = "金币";
		self.buyresource_money:SetImage("set:common.xml image:wuzi2");
		tipsInfo = "（升级金矿后每次可购买到更多的金币）";
		self.buyresource_viptext:SetText("本日可购买金币次数不足,");
		self.buyresource_viptext2:SetText("提升VIP等级可获得更多的购买次数");
	elseif resType == enum.BUY_RESOURCE_TYPE.WOOD then
		resText = "木材";
		tipsInfo = "（升级伐木场后每次可购买到更多的木材）";
		self.buyresource_money:SetImage("set:common.xml image:wuzi3");
		self.buyresource_viptext:SetText("本日可购买木材次数不足,");
		self.buyresource_viptext2:SetText("提升VIP等级可获得更多的购买次数");
	elseif resType == enum.BUY_RESOURCE_TYPE.VIGOR then
		resText = "体力";
		self.buyresource_money:SetImage("set:common.xml image:wuzi4");
		self.buyresource_viptext:SetText("本日可购买体力次数不足,");
		self.buyresource_viptext2:SetText("提升VIP等级可获得更多的购买次数");
	elseif resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
		resText = "副本次数";
		self.buyresource_money:SetImage("set:common.xml image:wuzi4");
		self.buyresource_viptext:SetText("本日可重置副本次数不足,");
		self.buyresource_viptext2:SetText("提升VIP等级可获得更多的重置次数");
	elseif resType == enum.BUY_RESOURCE_TYPE.MAGIC then
	
		resText = "魔法精华";
		self.buyresource_money:SetImage("set:jianzhu5.xml image:magic");
		tipsInfo = "";
		self.buyresource_viptext:SetText("本日可购买魔法精华次数不足,");
		self.buyresource_viptext2:SetText("提升VIP等级可获得更多的购买次数");
	
	elseif resType == enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES then
		
		resText = "掠夺次数";
		tipsInfo = "";
		self.buyresource_money:SetImage("");
		self.buyresource_viptext:SetText("");
		self.buyresource_viptext2:SetText("");
		
		local buyresource_robnum = self:Child("buyresource-robnum");
		buyresource_robnum:SetText("掠夺次数+1");
		buyresource_robnum:SetVisible(true);

	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE then
		
		resText = "进攻次数";
		tipsInfo = "";
		self.buyresource_money:SetImage("");
		self.buyresource_viptext:SetText("");
		self.buyresource_viptext2:SetText("");
		
		local buyresource_robnum = self:Child("buyresource-robnum");
		buyresource_robnum:SetText("进攻次数+1");
		buyresource_robnum:SetVisible(true);
			
	elseif resType == enum.BUY_RESOURCE_TYPE.PROTECT_TIME then
	
		resText = "神像保护时间";
		tipsInfo = "";
		self.buyresource_money:SetImage("");
		self.buyresource_viptext:SetText("");
		self.buyresource_viptext2:SetText("");

		local buyresource_robnum = self:Child("buyresource-robnum");
		buyresource_robnum:SetText(canBuyNumber);
		buyresource_robnum:SetVisible(true);
		self.buyresource_money_num:SetVisible(false);
	end
	
	local pretext = "";
	if source == "lackofresource" then
		pretext = resText.."不足, ";
	end
	
	local buyInfoText = "";
	if resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then		
		if source == "lackofresource" then
			buyInfoText = "挑战次数不足，是否使用钻石重置次数?";
		else
			buyInfoText = "使用钻石重置可挑战次数到最大值";
		end
		
		buyTimesText = "（该关卡今日可重置 "..buyTimesText.."）";
	
	elseif resType == enum.BUY_RESOURCE_TYPE.PLUNDER_TIMES then
		
		buyInfoText = "掠夺次数不足，是否使用钻石购买次数？";
		buyTimesText = "（当前掠夺次数："..dataManager.idolBuildData:getReminePlunderTimes().."/"..dataManager.idolBuildData:getMaxPlunderTimes().."）";

	elseif resType == enum.BUY_RESOURCE_TYPE.GUILD_WAR_BATTLE then
		
		buyInfoText = "进攻次数不足，是否使用钻石购买次数？";
		buyTimesText = "（当前进攻次数："..dataManager.guildWarData:getRemainBattleTimes().."/"..dataManager.guildWarData:getMaxBattleTimes().."）";
			
	elseif resType == enum.BUY_RESOURCE_TYPE.PROTECT_TIME then
	
		buyInfoText = "是否使用钻石增加神像保护时间？";
		buyTimesText = "（保护时间内将不会遭到玩家掠夺）";
		tipsInfo = "（掠夺其他玩家将清空保护时间）";
	else
		buyInfoText = pretext.."使用钻石购买"..resText;
		buyTimesText = "（今日可购买 "..buyTimesText.."）";
	end
	
	self.buyresource_text:SetText(buyInfoText);
	--self.buyresource_buynum_num:SetText(buyTimesText);
	self.buyresource_buynum:SetText(buyTimesText);
	
	-- 钻石信息
	local costDiamond = buyResPriceData:getBuyResourceNeedDiamond(resType, copyType, copyID);
	local isEnoughDiamond = buyResPriceData:isDiamondEnough(resType, copyType, copyID);
	if isEnoughDiamond then
		self.buyresource_diamond_num:SetText(costDiamond);
		self.buyresource_diamond_copy_num:SetText(costDiamond);
	else
		self.buyresource_diamond_num:SetText("^FF0000"..costDiamond);
		self.buyresource_diamond_copy_num:SetText("^FF0000"..costDiamond);
	end
	
	self.buyresource_money_num:SetText(canBuyNumber);
	
	self.buyresource_tips:SetText(tipsInfo);
	
	-- 根据还能不能购买显示不同的信息
	if canBuyTimes > 0 then
		
		self.buyresource_viptext:SetVisible(false);
		self.buyresource_button1:SetVisible(true);
		self.buyresource_button2:SetVisible(false);
		self.buyresource_button3:SetVisible(false);
		-- 购买副本次数只显示钻石
		if resType == enum.BUY_RESOURCE_TYPE.RESET_COPY then
			self.buyresource_diamond_copy:SetVisible(true);
			self.buyresource_resource:SetVisible(false);
			self.buyresource_button1:SetText("重  置");
		else
			self.buyresource_diamond_copy:SetVisible(false);
			self.buyresource_resource:SetVisible(true);
			self.buyresource_button1:SetText("购  买");
		end
		
	else
		self.buyresource_resource:SetVisible(false);
		self.buyresource_viptext:SetVisible(true);
		self.buyresource_button1:SetVisible(false);
		self.buyresource_button2:SetVisible(true);
		self.buyresource_button3:SetVisible(true);
		self.buyresource_diamond_copy:SetVisible(false);
	end
	
end

return buyresource;
