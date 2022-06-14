local expbuyback = class( "expbuyback", layout );

global_event.EXPBUYBACK_SHOW = "EXPBUYBACK_SHOW";
global_event.EXPBUYBACK_HIDE = "EXPBUYBACK_HIDE";
global_event.EXPBUYBACK_UPDATE = "EXPBUYBACK_UPDATE";

function expbuyback:ctor( id )
	expbuyback.super.ctor( self, id );
	self:addEvent({ name = global_event.EXPBUYBACK_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.EXPBUYBACK_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.EXPBUYBACK_UPDATE, eventHandler = self.updateInfo});
end

function expbuyback:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onExpBuyBackClose()
		self:onHide(event);
	end
	
	local expbuyback_close = self:Child( "expbuyback-close" );		
	expbuyback_close:subscribeEvent("ButtonClick", "onExpBuyBackClose");
	
	self:updateInfo();
	
end

function expbuyback:onHide(event)
	self:Close();
end

-- 更新信息
function expbuyback:updateInfo()

	if not self._show then
		return;
	end

	local expbuyback_npc_textquest = self:Child( "expbuyback-npc-textquest" );
	local expbuyback_npc_textquest2 = self:Child( "expbuyback-npc-textquest2" );
	local expbuyback_npc_text = self:Child( "expbuyback-npc-text" );
	local expbuyback_buyone = self:Child( "expbuyback-buyone" );

	local expbuyback_diamond1_num = self:Child( "expbuyback-diamond1-num" );
	local expbuyback_npc_exp_num = self:Child( "expbuyback-npc-exp-num" );
	local expbuyback_npc_warning1 = self:Child( "expbuyback-npc-warning1" );
	local expbuyback_npc_explittle_num = self:Child( "expbuyback-npc-explittle-num" );
	
	local expbuyback_checkvip	= self:Child("expbuyback-checkvip");
	local expbuyback_diamond1 = self:Child("expbuyback-diamond1");
	
	-- 所有的回购经验
	local lostExp = dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LOST_EXP);
	-- 每次回购最大值
	local maxExpBuyOnce = dataConfig.configs.ConfigConfig[0].redeemExpCount;
	-- 最大回购次数
	local canBuyTimes = dataManager.playerData:getVipConfig().buyLostExpTimes;
	-- vip Level
	local vipLevel = dataManager.playerData:getVipLevel();
	
	
	expbuyback_npc_exp_num:SetText(lostExp);
	
	local buyExp = dataManager.buyResPriceData:getCanBuyResourceNumber(enum.BUY_RESOURCE_TYPE.EXP);
	expbuyback_npc_explittle_num:SetText(""..buyExp);
	
	-- check if active vip buy back
	local active = dataManager.playerData:getBuyExpVipLevel() <= dataManager.playerData:getVipLevel();
	local activelv = dataManager.playerData:getBuyExpVipLevel();
	
	expbuyback_npc_textquest:SetVisible(lostExp > 0 and active);
	expbuyback_npc_textquest2:SetVisible(not active or (lostExp == 0));
	expbuyback_buyone:SetVisible(lostExp > 0 and active);
	expbuyback_diamond1:SetVisible(lostExp > 0 and active);
	expbuyback_npc_warning1:SetVisible(not active);
	expbuyback_npc_warning1:SetText("达到VIP"..activelv.."国王特权");
	
	expbuyback_npc_text:SetVisible(active);
	expbuyback_checkvip:SetVisible(not active);
	
	function onExpBuyBackClickBuy()
	
		
		local isEnoughDiamond = dataManager.buyResPriceData:isDiamondEnough(enum.BUY_RESOURCE_TYPE.EXP, -1, -1);
		
		if not isEnoughDiamond then	
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
				return	
		end
		
		sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_LOST_EXP, -1);
	end
	
	expbuyback_buyone:removeEvent("ButtonClick");
	expbuyback_buyone:subscribeEvent("ButtonClick", "onExpBuyBackClickBuy");
	
	local isEnoughDiamond = dataManager.buyResPriceData:isDiamondEnough(enum.BUY_RESOURCE_TYPE.EXP, -1, -1);
	
	if isEnoughDiamond then
		expbuyback_diamond1_num:SetText(dataManager.buyResPriceData:getBuyResourceNeedDiamond(enum.BUY_RESOURCE_TYPE.EXP));
	else
		expbuyback_diamond1_num:SetText("^FF0000"..dataManager.buyResPriceData:getBuyResourceNeedDiamond(enum.BUY_RESOURCE_TYPE.EXP));
	end
	
	if not active then
		
		function onExpBuyBackClickCheckVip()
			eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW,showcharge = false});
		end
		
		expbuyback_checkvip:removeEvent("ButtonClick");
		expbuyback_checkvip:subscribeEvent("ButtonClick", "onExpBuyBackClickCheckVip");
		
		expbuyback_npc_textquest2:SetText("目前我还不能为您提供任何帮助……当您的国王特权达到了我的要求，再来找我吧");
		
	else
		
		if lostExp == 0 then
			expbuyback_npc_textquest2:SetText("目前没有任何经验遗落在时空裂缝之中，这都要归功于您勤勉，年轻的国王……");
		end
	end
	
end

return expbuyback;
 