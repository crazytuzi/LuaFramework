local purchase = class( "purchase", layout );

global_event.PURCHASE_SHOW = "PURCHASE_SHOW";
global_event.PURCHASE_HIDE = "PURCHASE_HIDE";
global_event.PURCHASE_UPDATE = "PURCHASE_UPDATE";

function purchase:ctor( id )
	purchase.super.ctor( self, id );
	self:addEvent({ name = global_event.PURCHASE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.PURCHASE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.PURCHASE_UPDATE, eventHandler = self.Update});
	
end

VIP_TIP_MSG ={}

 
	


function purchase:onShow(event)
	if self._show then
		--return;
		self:onHide()
	end

	self:Show();
	
	local size = table.nums(dataConfig.configs.vipConfig)
	
	local funlvl = dataManager.playerData:getResetTimesVipLevel();
	local funlvl2 = dataManager.playerData:getBuyExpVipLevel();
	local redeemVigorLimit = dataConfig.configs.ConfigConfig[0].redeemVigorLimit;
	local redeemChallengeSpeedLimit = dataConfig.configs.ConfigConfig[0].redeemChallengeSpeedLimit;
	local redeemCrusadeLimit = dataConfig.configs.ConfigConfig[0].redeemCrusadeLimit;
		
	local funlimit = math.min(funlvl, funlvl2, redeemVigorLimit, redeemChallengeSpeedLimit, redeemCrusadeLimit);
	print(funlvl.." "..funlvl2.." "..redeemVigorLimit.." "..redeemChallengeSpeedLimit.." "..redeemCrusadeLimit);
	print("funlimit "..funlimit);
	
	for  i = 0 , size-1  do
		 
		local v = dataConfig.configs.vipConfig[i]
		local frontInfo = dataConfig.configs.vipConfig[i-1];
		local _rmb = global.getRmbTextFromPrice(v.rmb)
		local t = "^FFE6A9"
		if( tonumber(_rmb) > 0)then
			t =t.."累计充值^FFFFFF【"..global.getRmbTextFromPrice(v.rmb).."】^FFE6A9元即可享受该级特权".."#n"
		end		
		if(   i >   dataManager.playerData:getVipLevel() )then
			local needrmb  = dataManager.playerData:getNeedMoneyWithVipLevel(i )
			t = t.."您再充值^FFFFFF【"..global.getRmbTextFromPrice(needrmb).."】^FFE6A9元即可享受该级特权".."#n"
		end
		
		if(i > 0)then
		--if(i > funlimit)then
			t = t.."包含VIP  ^FFFFFF【"..(i-1).."】^FFE6A9所有特权。".."#n" 
		end
		
		if i == funlvl2 then
			t = t.."^0BE000解锁经验回购功能。".."^FFE6A9#n";
		end
		
		if i == redeemVigorLimit then
			t = t.."^0BE000忘记领取免费体力时，会收到补偿邮件。".."^FFE6A9#n";
		end
		
		if i == redeemChallengeSpeedLimit then
			t = t.."^0BE000忘记参加极速挑战时，会收到补偿邮件。".."^FFE6A9#n";
		end
		
		if i == redeemCrusadeLimit then
			t = t.."^0BE000忘记参加远征时，会收到金币补偿邮件。".."^FFE6A9#n";
		end
		
		if i == dataConfig.configs.ConfigConfig[0].skipBattleVip  then
			t = t.."^0BE000开战即可跳过战斗。".."^FFE6A9#n";
		end
		
		--[[
		if(i == funlvl)then
			t = t.."^0BE000每天可重置关卡^FFFFFF【"..v.resetTimes.."】^0BE000次。^FFE6A9".."#n"
		end
		if(v.resetTimes ~=0 and i ~= funlvl)then
			t = t.."每天可重置关卡^FFFFFF【"..v.resetTimes.."】^FFE6A9次。".."#n"
		end
		]]--
		if frontInfo and frontInfo.resetTimes ~= v.resetTimes then
			t = t.."^0BE000每天可重置冒险关卡^FFFFFF【"..v.resetTimes.."】^0BE000次。^FFE6A9".."#n"
		else
			--t = t.."每天可进行副本挑战^FFFFFF【"..v.challengeStageTimes.."】^FFE6A9次。".."#n";
		end
		if frontInfo and frontInfo.challengeStageTimes ~= v.challengeStageTimes then
			--t = t.."^FFC026每天可进行副本挑战^FF0000【"..v.challengeStageTimes.."】^FFC026次。".."^FFE6A9#n" 
			t = t.."^0BE000每天可进行副本挑战^FFFFFF【"..v.challengeStageTimes.."】^0BE000次。".."^FFE6A9#n"
		else
			--t = t.."每天可进行副本挑战^FFFFFF【"..v.challengeStageTimes.."】^FFE6A9次。".."#n";
		end
		
		if v.goldRatio~=1 and frontInfo and frontInfo.goldRatio ~= v.goldRatio then
			temp = v.goldRatio*100-100
			t = t.."^0BE000金矿产量增加^FFFFFF【"..temp.."%】^0BE000。".."^FFE6A9#n"
		end
		
		t = t.."每天可购买体力^FFFFFF【"..v.buyVigorTimes.."】^FFE6A9次。".."#n" 
		t = t.."每天可购买金币^FFFFFF【"..v.buyGoldTimes.."】^FFE6A9次。".."#n" 
		t = t.."每天可购买木材^FFFFFF【"..v.buyLumberTimes.."】^FFE6A9次。".."#n" 
		t = t.."每天可购买魔法精华^FFFFFF【"..v.buyMagicExpTimes.."】^FFE6A9次。".."#n" 
		t = t.."每天可免费领取扫荡券^FFFFFF【"..v.sweepScrollCount.."】^FFE6A9张。".."#n" 
		t = t.."每天极速挑战可失败^FFFFFF【"..v.challengeSpeedFailLimit.."】^FFE6A9次。#n"
		t = t.."玩家体力上限^FFFFFF【"..v.maxVigor.."】^FFE6A9。".."#n" 
		t = t.."金矿最多可存储^FFFFFF【"..v.maxGoldRatio.."】^FFE6A9小时产量。".."#n" 
		t = t.."伐木场最多可存储^FFFFFF【"..v.maxLumberRatio.."】^FFE6A9根原木。#n"
		
		
		VIP_TIP_MSG[i] = t
	end
 

	function onClickPurchaseClose()
		self:onHide();
		self.tmp = nil
	end
	
	self.purchase_close = self:Child( "purchase-close" );
	self.purchase_close:subscribeEvent("ButtonClick", "onClickPurchaseClose");
	
	self.purchase_now_vip_num = self:Child( "purchase-now-vip-num" );
	
	function purchase_onClickcharge_button()
		eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW,showcharge = false});
	end
	self.purchase_charge_button = self:Child( "purchase-charge-button" );
	self.purchase_charge_button:subscribeEvent("ButtonClick", "purchase_onClickcharge_button");
	
	function purchase_onClickpay_button()
		eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW,showcharge = true});
	end
	self.purchase_pay_button = self:Child( "purchase-pay-button" );
	self.purchase_pay_button:subscribeEvent("ButtonClick", "purchase_onClickpay_button");
	
	self.showcharge  =   event.showcharge 
	if(	self.showcharge  == nil)then
		self.showcharge  = true
	end
	
	if self.showcharge and self.showVipGift then
		self:onHideVipGift();
	end
	
	self.purchase_charge_button:SetVisible(self.showcharge )
	self.purchase_pay_button:SetVisible(not self.showcharge )
	
	self.purchase_bar = self:Child( "purchase-bar" );
	
	self.purchase_charge_diamond_num = self:Child( "purchase-charge-diamond-num" );
	self.purchase_charge_vip_num = self:Child( "purchase-charge-vip-num" );
	self.purchase_item =  LORD.toScrollPane(self:Child( "purchase-item" ))
	
	self.purchase_bar_num = self:Child( "purchase-bar-num" );
	
	self.purchase_item:init()
	
	local purchase_vipgift = self:Child("purchase-vipgift");
	local purchase_vipgift_close = self:Child("purchase-vipgift-close");
	
	function onClickPurchaseVipGift()
		self:onShowVipGift();
	end
	
	function onClickPurchaseVipGiftClose()
		self:onHideVipGift();
	end
	
	purchase_vipgift:subscribeEvent("ButtonClick", "onClickPurchaseVipGift");
	purchase_vipgift_close:subscribeEvent("ButtonClick", "onClickPurchaseVipGiftClose");
	
	self:Update()
	
end




function purchase:Update()
	if not self._show then
		return;
	end
	
	if self.showVipGift then
		
		self:onUpdateGift();
		return;
		
	end
	
	local culVip = dataManager.playerData:getVipLevel()
	self.purchase_now_vip_num:SetText(culVip )
	
	self.ShowVip = self.ShowVip  or culVip
	local num,nextVip,percent = dataManager.playerData:getNextVipNeedInfo()
	local needMoney , nextMoney ,curmoney = dataManager.playerData:getVipMoneyInfo()
	self.purchase_bar_num:SetText(global.getRmbTextFromPrice(needMoney).."/"..global.getRmbTextFromPrice(nextMoney) )
	self.purchase_bar:SetProperty("Progress", percent);
	self.purchase_charge_vip_num:SetText(nextVip )
	self.purchase_charge_diamond_num:SetText(global.getRmbTextFromPrice(num) )
	
	self.purchase_item:ClearAllItem() 
	
	--dataManager.purchaseData 
		local xpos = LORD.UDim(0, 80)
		local ypos = LORD.UDim(0, 10)
	if(self.showcharge == true)then
			function purchase_onTouchDownEquip(args)	
			local clickImage = LORD.toWindowEventArgs(args).window		
			local userdata = clickImage:GetUserData()	

			if(userdata ~= -1)then
					local item = itemManager.getItem(userdata)		
					self.curSelItem = 	userdata
			end				
		end	 
		function purchase_onTouchReleaseEquip(args)
			local clickImage = LORD.toWindowEventArgs(args).window;
			local userdata = clickImage:GetUserData()			
			if(userdata ~= -1)then
				local item = itemManager.getItem(userdata)		
			end
		end	 		
		function purchase_onTouchUpEquip(args)
			local clickImage = LORD.toWindowEventArgs(args).window;
			local userdata = clickImage:GetUserData()
			if(userdata == -1)then
				return
			end
		end	 
		
		function onPurchaseClickBuy(args)
			
			local clickImage = LORD.toWindowEventArgs(args).window;
			uiaction.scale(clickImage, 0.8);
			scheduler.performWithDelayGlobal(function()
			local userdata = clickImage:GetUserData()
			if(userdata == -1)then
				return
			end
			
			local config = dataManager.purchaseData:getItemConfig(userdata);
			if config then
				
				self:buySomething(config);
			end
			end, 0.2)
					
		end
		
	
		local nums =  #dataManager.purchaseData:getItems()  
		local vec = dataManager.purchaseData:getItems()  
		 
		local itemIndex = 0
		self.tmp ={}
		for i = 1,nums do	
			self.tmp[i] = self.tmp[i] or {}
			local item =   dataConfig.configs.rechargeConfig[vec[i].id]			
			if item then		
				self.tmp[i].itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("purchase"..i, "chargeitem.dlg");
				self.tmp[i].itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("purchase"..i.."_chargeitem-item-image"));	
				self.tmp[i].itemName=  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase"..i.."_chargeitem-name"));				
				self.tmp[i].itemDes =  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase"..i.."_chargeitem-detail"));
				self.tmp[i].itemPrice=  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase"..i.."_chargeitem-price"));		
				self.tmp[i].itemSign = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("purchase"..i.."_chargeitem-item-signimg"));		
				 
				 
				self.tmp[i].itemWind:SetPosition(LORD.UVector2(xpos, ypos));
				self.purchase_item:additem( self.tmp[i].itemWind);
				
				local width = self.tmp[i].itemWind:GetWidth()
				xpos = xpos + width
				itemIndex = itemIndex + 1
				if(itemIndex >= 2)then
					itemIndex = 0
					xpos = LORD.UDim(0, 80)
					ypos = ypos +  self.tmp[i].itemWind:GetHeight() + LORD.UDim(0, 5)
				end						
				 
					 self.tmp[i].itemIcon:SetImage(item.icon) 		 
					 self.tmp[i].itemIcon:subscribeEvent("WindowTouchDown", "purchase_onTouchDownEquip")
					 self.tmp[i].itemIcon:subscribeEvent("WindowTouchUp", "purchase_onTouchUpEquip")
					 self.tmp[i].itemIcon:subscribeEvent("MotionRelease", "purchase_onTouchReleaseEquip")
					 
					 self.tmp[i].itemWind:subscribeEvent("WindowTouchUp", "onPurchaseClickBuy")
					 self.tmp[i].itemWind:SetUserData(vec[i].id);
					 
					 self.tmp[i].itemIcon:SetUserData(vec[i].id)
					 self.tmp[i].itemName:SetText(item.name)
					 self.tmp[i].itemDes:SetText(item.description) 
					 self.tmp[i].itemPrice:SetText(global.getRmbTextFromPrice(item.rmb).."^B4DB1E元") 
					 self.tmp[i].itemSign:SetVisible(item.tag == 1)
			end		
		end		
	else
	
		local vip  = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("purchase", "vip.dlg");
		local vip_num =  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase".."_vip-num"));				
		local vip_num_next =  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase".."_vip-num-next"));
		local vip_num_last =  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase".."_vip-num-last"));		
		local viplast =  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase".."_vip-last"));
		local vipnext=  (LORD.GUIWindowManager:Instance():GetGUIWindow("purchase".."_vip-next"));		
			 viplast:SetVisible(true)
		 vipnext:SetVisible(true)
		
		local vip_words = LORD.toScrollPane ((LORD.GUIWindowManager:Instance():GetGUIWindow("purchase".."_vip-words"))); 
		vip_words:init()				
		vip_words:ClearAllItem() 	 
		vip:SetPosition(LORD.UVector2(xpos, ypos));
		self.purchase_item:additem(vip);
		self.purchase_item:SetProperty("VertScrollEnable", "false");
		local maxVip = dataManager.playerData:getVipMax()
		vip_num:SetText(self.ShowVip )
		local preVip = self.ShowVip - 1
		local nextVip = self.ShowVip + 1
		if(preVip < 0)then
			preVip = 0
		end
		vip_num_last:SetText(preVip )
		if(nextVip > maxVip)then
			nextVip = maxVip
		end
		vip_num_next:SetText(nextVip )
		function purchase_onClickpay_button()
			eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW,showcharge = true});
		end
		function purchase_onClickpay_vipnext()
			self.ShowVip = self.ShowVip + 1
			if(self.ShowVip > maxVip)then
				self.ShowVip = maxVip
					
				vipnext:SetVisible(false)
		
			end
			self:Update()
		end	
		function purchase_onClickpay_viplast()
			self.ShowVip = self.ShowVip - 1
			if(self.ShowVip < 0)then
				self.ShowVip = 0
				
			end
			self:Update()
		end	
		 
		viplast:SetVisible( self.ShowVip > 0 )
		vipnext:SetVisible( self.ShowVip < maxVip )
 
		
		local notice = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("purchase_", "vipNoticeText.dlg");
		notice:SetText(VIP_TIP_MSG[self.ShowVip] )	
	
		local xpos = LORD.UDim(0, 10)
		local ypos = LORD.UDim(0, 10)
		notice:SetPosition(LORD.UVector2(xpos, ypos));		
		vip_words:additem(notice);
		 viplast:subscribeEvent("ButtonClick", "purchase_onClickpay_viplast");
		 vipnext:subscribeEvent("ButtonClick", "purchase_onClickpay_vipnext");
	end
	
	
	
end

function purchase:buySomething(config)
	
	print("buySomething "..config.id);
	
	--sendAskOrder(config.id);
    --zhouyou
    --测试新的协议askVerifyReceipt. 
    --当前点什么就买什么，服务器拿着一个有效凭证走一遍。
    --local transaction = "1000000179226373";
  
    --local base64_receipt1 = "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";
    --local base64_receipt2 = "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";
    --local base64_receipt3 = "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";
    --sendAskVerifyReceipt(2, base64_receipt1);
    --sendAskVerifyReceipt(1, base64_receipt2);
    --sendAskVerifyReceipt(2, base64_receipt3);

	local payInfo = "";
		
	local config = dataConfig.configs.rechargeConfig[config.id];
	
	local serverlist, alllist = dataManager.loginData:getServerlist();
	
	local data = alllist[dataManager.loginData:getServerId()];
	
	if config and data then
		payInfo = {
			['productPrice'] = config.rmb, -- ·Ö
			['productName'] = config.name,
			['gameServerId'] = data.serverid,
			['extInfo'] = config.id,
			['roleId'] = 1,
			['productCount'] = 1,
			['orderID'] = "",
			['exchangeRate'] = 100,
			['iosid'] = config.iosid,
		};
		
		payInfo = json.encode(payInfo);
		
	end
	
	print(payInfo);
	
	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		shellInterface:payWithInfo(payInfo);
	end

end

function purchase:onUpdate(event)
	self:Update();
end

function purchase:onHide(event)
	self:Close();
	self.showcharge = nil
	self.ShowVip = nil
end

function purchase:onShowVipGift()
	
	if not self._show then
		return;
	end
	
	self.showVipGift = true;
	
	function onClickPurchaseBuyVipGift(args)
		
		local clickImage = LORD.toWindowEventArgs(args).window		
		local userdata = clickImage:GetUserData();
		
		dataManager.vipGiftData:onClickGift(userdata);
			
	end
	
	local purchase_daizi = self:Child("purchase-daizi");
	purchase_daizi:SetVisible(true);
	
	local vipgift_npc = self:Child("purchase-vipgift-npc");
	vipgift_npc:SetVisible(true);
	
	local charge_button = self:Child("purchase-charge-button");
	charge_button:SetVisible(false);

	local pay_button = self:Child("purchase-pay-button");
	pay_button:SetVisible(false);

	local purchase_vipgift = self:Child("purchase-vipgift");
	purchase_vipgift:SetVisible(false);
	local purchase_vipgift_close = self:Child("purchase-vipgift-close");
	purchase_vipgift_close:SetVisible(true);
	
	self.purchase_item:ClearAllItem();
	self.purchase_item:SetProperty("VertScrollEnable", "true");
	-- update gift info 
	
	
	local allGift = dataManager.vipGiftData:getAllGift();
	
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, -17);
	self.purchase_item:SetHeight(LORD.UDim(0, 404));
	local x = self.purchase_item:GetPosition().x
	self.purchase_item:SetPosition(LORD.UVector2(x, LORD.UDim(0, 142)));
	
	for k, v in ipairs(allGift) do
		
		local vipGiftItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("purchase_"..k, "vipGiftItem.dlg");
		local itemSize = vipGiftItem:GetPixelSize();
		local backSize = self.purchase_item:GetPixelSize();
		
		xpos = LORD.UDim(0, 0.5 * (backSize.x - itemSize.x));
		
		vipGiftItem:SetXPosition(xpos);
		vipGiftItem:SetYPosition(ypos);
		
		self.purchase_item:additem( vipGiftItem );
		ypos = ypos + vipGiftItem:GetHeight()+ LORD.UDim(0, -10);
	
		local vipGiftItem_name = self:Child("purchase_"..k.."_vipGiftItem-name");
		local vipGiftItem_vipnum = self:Child("purchase_"..k.."_vipGiftItem-vipnum");
		vipGiftItem_name:SetText("VIP^FFDE00【"..v.viplevel.."】^FFFFFF特权礼包");
		vipGiftItem_vipnum:SetText(v.viplevel);
		
		local vipGiftItem_price = self:Child("purchase_"..k.."_vipGiftItem-price_33");
		vipGiftItem_price:SetText(v.giftPrimeCost);
		
		local vipGiftItem_price_buy = self:Child("purchase_"..k.."_vipGiftItem-price_33_35");
		vipGiftItem_price_buy:SetText(v.giftPrice);
		
		local vipGiftItem_buy = self:Child("purchase_"..k.."_vipGiftItem-buy");
		local vipGiftItem_buyed = self:Child("purchase_"..k.."_vipGiftItem-buyed");
		vipGiftItem_buy:removeEvent("ButtonClick");
		vipGiftItem_buy:subscribeEvent("ButtonClick", "onClickPurchaseBuyVipGift");
		vipGiftItem_buy:SetUserData(v.viplevel);
		
		vipGiftItem_buy:SetVisible(not vipGiftData:isGiftAlreadyBuyed(v.viplevel));
		vipGiftItem_buyed:SetVisible(vipGiftData:isGiftAlreadyBuyed(v.viplevel));
		
		-- gift items
		local vipGiftItem_gift = self:Child("purchase_"..k.."_vipGiftItem-gift");
		
		
		local itemXPos = LORD.UDim(0, -10);
		local itemYPos = LORD.UDim(0, 0);
	
		for itemKey, item in ipairs(v.items) do
			
			local vipGiftItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("purchase_"..k.."_"..itemKey, "instanceawarditem.dlg");
			global_scalewnd(vipGiftItem, 1.2, 1.2);
			
			vipGiftItem:SetXPosition(itemXPos);
			vipGiftItem:SetYPosition(itemYPos);
			vipGiftItem_gift:AddChildWindow(vipGiftItem);
			
			itemXPos = itemXPos + vipGiftItem:GetWidth();
			
			local rewardInfo = dataManager.playerData:getRewardInfo(item.giftType, item.giftID, item.giftCount);
			
			local rare = self:Child("purchase_"..k.."_"..itemKey.."_instanceawarditem-rare");
			rare:SetVisible(false);
			
			local icon = LORD.toStaticImage(self:Child("purchase_"..k.."_"..itemKey.."_instanceawarditem-item-image"));
			icon:SetImage(rewardInfo.icon);
			global.setMaskIcon(icon, rewardInfo.maskicon);
						
			local equity = LORD.toStaticImage(self:Child("purchase_"..k.."_"..itemKey.."_instanceawarditem-equity"));
			equity:SetImage(rewardInfo.qualityImage);
			
			local back = LORD.toStaticImage(self:Child("purchase_"..k.."_"..itemKey.."_instanceawarditem-item")); 
			back:SetImage(rewardInfo.backImage);
			
			local count = self:Child("purchase_"..k.."_"..itemKey.."_instanceawarditem-num");
			count:SetVisible(rewardInfo.count > 1);
			count:SetText(rewardInfo.count);
			count:GetPosition();
			local countPosition= count:GetPosition();
			count:SetPosition(LORD.UVector2(countPosition.x+LORD.UDim(0, 0),countPosition.y+LORD.UDim(0, 4)))
			
			for starIndex=1, 5 do
			
				local star = self:Child("purchase_"..k.."_"..itemKey.."_instanceawarditem-star"..starIndex);
				star:SetVisible(starIndex<=rewardInfo.showstar);
				
			end
			
			vipGiftItem:SetUserData(rewardInfo.userdata);
			global.onItemTipsShow(vipGiftItem, item.giftType, "top");
			global.onItemTipsHide(vipGiftItem);
					
		end
		
	end
	
end


function purchase:onUpdateGift()
	
	if not self._show then
		return;
	end

	local allGift = dataManager.vipGiftData:getAllGift();

	for k, v in ipairs(allGift) do

		local vipGiftItem_buy = self:Child("purchase_"..k.."_vipGiftItem-buy");
		local vipGiftItem_buyed = self:Child("purchase_"..k.."_vipGiftItem-buyed");
		
		vipGiftItem_buy:SetVisible(not vipGiftData:isGiftAlreadyBuyed(v.viplevel));
		vipGiftItem_buyed:SetVisible(vipGiftData:isGiftAlreadyBuyed(v.viplevel));

	end
		
end

function purchase:onHideVipGift()
	
	if not self._show then
		return;
	end
	
	self.showVipGift = nil;
	
	local purchase_vipgift = self:Child("purchase-vipgift");
	purchase_vipgift:SetVisible(true);
	local purchase_vipgift_close = self:Child("purchase-vipgift-close");
	purchase_vipgift_close:SetVisible(false);
	
	local purchase_daizi = self:Child("purchase-daizi");
	purchase_daizi:SetVisible(false);
	
	local vipgift_npc = self:Child("purchase-vipgift-npc");
	vipgift_npc:SetVisible(false);
	
	eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW, showcharge = self.showcharge});
		
end

return purchase;
