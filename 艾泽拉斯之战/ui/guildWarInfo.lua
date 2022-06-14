local guildWarInfo = class( "guildWarInfo", layout );

global_event.GUILDWARINFO_SHOW = "GUILDWARINFO_SHOW";
global_event.GUILDWARINFO_HIDE = "GUILDWARINFO_HIDE";
global_event.GUILDWARINFO_UPDATE = "GUILDWARINFO_UPDATE";

function guildWarInfo:ctor( id )
	guildWarInfo.super.ctor( self, id );
	self:addEvent({ name = global_event.GUILDWARINFO_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GUILDWARINFO_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.GUILDWARINFO_UPDATE, eventHandler = self.update});
end

function guildWarInfo:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	self.spotIndex = event.spotIndex;
	
	local guildWarInfo_close = self:Child("guildWarInfo-close");
	local guildWarInfo_enter = self:Child("guildWarInfo-enter");
	local guildWarInfo_editdef = self:Child("guildWarInfo-editdef");
	
	function onGuildWarInfoClose()
		
		self:onHide();
		
	end
	
	guildWarInfo_close:subscribeEvent("ButtonClick", "onGuildWarInfoClose");
	
	function onGuildWarInfoEnter()
		
		local spot = dataManager.guildWarData:getSpot(self.spotIndex);
		
		if spot:isMy() then
			
			dataManager.guildWarData:onHandleClickCheckDefence(self.spotIndex);
			
		else
		
			dataManager.guildWarData:onHandleClickAttackAskDefenceInfo(self.spotIndex);
		
		end
		
	end
	
	function onGuildWarInfoEditdef()
		
		dataManager.guildWarData:onHandleClickEditDefence(self.spotIndex);
		
	end
	
	function onGuildWarInfoInspire()
		
		dataManager.guildWarData:onHandleClickInspire(self.spotIndex);
		
	end
	
	guildWarInfo_enter:subscribeEvent("ButtonClick", "onGuildWarInfoEnter");
	guildWarInfo_editdef:subscribeEvent("ButtonClick", "onGuildWarInfoEditdef");
	
	local guwuButton = self:Child("guildWarInfo-else-guwu");
	guwuButton:subscribeEvent("ButtonClick", "onGuildWarInfoInspire");
	
	self:update();
	
end

function guildWarInfo:onHide(event)
	self:Close();
end

function guildWarInfo:update()

	if not self._show then
		return;
	end
	
	local spot = dataManager.guildWarData:getSpot(self.spotIndex);
	
	local guildWarInfo_enter = self:Child("guildWarInfo-enter");
	local guildWarInfo_editdef = self:Child("guildWarInfo-editdef");
	
	if dataManager.guildWarData:isOpen() then
		
		guildWarInfo_editdef:SetVisible(false);
		
		if spot:isMy() then
			
			guildWarInfo_enter:SetText("查看守军");
			guildWarInfo_enter:SetVisible(false);
		else
			
			guildWarInfo_enter:SetText("开始进攻");
			guildWarInfo_enter:SetVisible(true);
		end
		
	else
		
		if spot:isMy() then
			
			if dataManager.guildData:isCanEditDefencePlan() then
				
				guildWarInfo_editdef:SetVisible(true);
				guildWarInfo_enter:SetVisible(false);
			
			else
				
				guildWarInfo_editdef:SetVisible(false);
				guildWarInfo_enter:SetVisible(true);
				guildWarInfo_enter:SetText("查看守军");
				
			end
			
		else
		
			guildWarInfo_editdef:SetVisible(false);
			guildWarInfo_enter:SetVisible(false);
			
		end
		
	end
	
	local baseguildname = self:Child("guildWarInfo-defgroup-baseguildname");
	baseguildname:SetText("占领公会: "..spot:getSpotOwnerName());
	
	local basename = self:Child("guildWarInfo-defgroup-basename");
	basename:SetText("战区: "..spot:getSpotName());
	
	local gift_scoreg = self:Child("guildWarInfo-gift-scoreg");
	gift_scoreg:SetText("公会积分 + "..spot:getGuildWinReward().."/"..spot:getGuildLoseReward());
	
	local gift_scorep = self:Child("guildWarInfo-gift-scorep");
	gift_scorep:SetText("个人积分 + "..spot:getGuildWinReward().."/"..spot:getGuildLoseReward());
	
	local giftguild_score = self:Child("guildWarInfo-giftguild-score");
	giftguild_score:SetText("公会积分 + "..spot:getGuildBreakReward());
	
	-- item reward
	
	local giftthing_item = self:Child("guildWarInfo-giftthing-item");
	giftthing_item:CleanupChildren();
	
	local xPosition = LORD.UDim(0, 5);
	local yPosition = LORD.UDim(0, 5);
	
	for k,v in ipairs(spot:getConfig().rewardType) do
		
		local rewardInfo = dataManager.playerData:getRewardInfo(v, spot:getConfig().rewardID[k], spot:getConfig().rewardCount[k]);
		
		if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY then
		
		else
			
			local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guildWarInfo-"..k, "instanceawarditem.dlg");
            global_scalewnd(item, 1.2, 1.2);
			item:SetXPosition(xPosition);
			item:SetYPosition(yPosition);				
			giftthing_item:AddChildWindow(item);
			
			local itemFrame = LORD.toStaticImage(self:Child("guildWarInfo-"..k.."_instanceawarditem-item"));
			local itemIcon = LORD.toStaticImage(self:Child("guildWarInfo-"..k.."_instanceawarditem-item-image"));
			local itemequity = LORD.toStaticImage(self:Child("guildWarInfo-"..k.."_instanceawarditem-equity"));
			
			local rare = self:Child("guildWarInfo-"..k.."_instanceawarditem-rare");
			rare:SetVisible(false);
			
			if itemIcon then
				itemIcon:SetImage(rewardInfo.icon);
				global.setMaskIcon(itemIcon, rewardInfo.maskicon);
			end
			
			if itemFrame then
				itemFrame:SetImage(rewardInfo.backImage);
			end
			
			itemequity:SetImage(rewardInfo.qualityImage);
			
			-- 绑定tips事件
			item:SetUserData(spot:getConfig().rewardID[k]);
			
			if v == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
				item:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
			end
			
			global.onItemTipsShow(item, v, "top");
			global.onItemTipsHide(item);
			
			for i=1, 5 do
				local star = self:Child("guildWarInfo-"..k.."_instanceawarditem-star"..i);
				
				star:SetVisible(i <= rewardInfo.showstar);
			end
			
			local instanceawarditem_num = self:Child("guildWarInfo-"..k.."_instanceawarditem-num");
			instanceawarditem_num:SetText(rewardInfo.count);
			instanceawarditem_num:SetVisible(rewardInfo.count > 1);
			local countPosition= instanceawarditem_num:GetPosition();
			instanceawarditem_num:SetPosition(LORD.UVector2(countPosition.x+LORD.UDim(0, 0),countPosition.y+LORD.UDim(0, 4)))
			
			xPosition = xPosition + item:GetWidth();

		end
		
	end
		
	local guwutext = self:Child("guildWarInfo-else-guwutext");
	local guwunum = self:Child("guildWarInfo-else-guwunum");

	local guwu_costimg = LORD.toStaticImage(self:Child("guildWarInfo-guwu-costimg"));
	local guwu_costnum = self:Child("guildWarInfo-guwu-costnum");
	
	local guwuicon = LORD.toStaticImage(self:Child("guildWarInfo-else-guwuicon"));
	local guwu_num = self:Child("guildWarInfo-guwu-num");
	local guwuButton = self:Child("guildWarInfo-else-guwu");
	local guwuarrow = self:Child("guildWarInfo-else-guwuarrow");
	local guwutotal = self:Child("guildWarInfo-else-guwutotal");
	
	if spot:isMy() then
		
		guwutext:SetText("守军军团数量");
		guwunum:SetText((dataManager.guildWarData:getAttackBuffBuyUnitCountPercent()+spot:getNowDefenceAddUnitCount()).."%");
		guwuicon:SetImage("s1025.jpg");
		guwu_num:SetText(spot:getNowDefenceBuffCount().."/"..dataManager.guildWarData:getMaxInspireTime());
		guwuButton:SetText("集结呐喊");
		
		guwutotal:SetText(spot:getNowDefenceAddUnitCount().."%");

		if dataManager.guildWarData:getMaxInspireTime() == spot:getNowDefenceBuffCount() then
			
			-- 调位置
			
			guwunum:SetText("");
			guwuarrow:SetVisible(false);
			--guwutotal:SetXPosition(LORD.UDim(0, 20));
			
		end
		
				
		-- 写死了？
		guwu_costimg:SetImage(enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_DIAMOND]);
		guwu_costnum:SetText(dataManager.buyResPriceData:getBuyResourceNeedDiamond(enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_DEFENCE, -1, -1, self.spotIndex));
		
	else
		
		guwutext:SetText("军团数量");
		guwunum:SetText((dataManager.guildWarData:getNowAttackUnitPercent() + dataManager.guildWarData:getDenfenceBuffBuyUnitCountPercent()).."%");
		guwuicon:SetImage("s1110.jpg");
		guwu_num:SetText(dataManager.guildWarData:getNowAttackBuffCount().."/"..dataManager.guildWarData:getMaxInspireTime());
		guwuButton:SetText("王者祝福");
		
		guwutotal:SetText(dataManager.guildWarData:getNowAttackUnitPercent().."%");
		
		guwu_costimg:SetImage(enum.MONEY_ICON_STRING[enum.MONEY_TYPE.MONEY_TYPE_LUMBER]);
		guwu_costnum:SetText(dataManager.buyResPriceData:getBuyResourceNeedDiamond(enum.BUY_RESOURCE_TYPE.GUILD_WAR_INSPIRE_ATTACK, -1, -1, self.spotIndex));
		
		
		if dataManager.guildWarData:getMaxInspireTime() == dataManager.guildWarData:getNowAttackBuffCount() then
			
			-- 调位置
			
			guwunum:SetText("");
			guwuarrow:SetVisible(false);
			--guwutotal:SetXPosition(LORD.UDim(0, 20));
			
		end
		
	end
	
	
end

return guildWarInfo;
