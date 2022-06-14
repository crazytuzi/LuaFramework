local baseaward = class( "baseaward", layout );

global_event.BASEAWARD_SHOW = "BASEAWARD_SHOW";
global_event.BASEAWARD_HIDE = "BASEAWARD_HIDE";

function baseaward:ctor( id )
	baseaward.super.ctor( self, id );
	self:addEvent({ name = global_event.BASEAWARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BASEAWARD_HIDE, eventHandler = self.onHide});
end

function baseaward:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onClickBaseAwardClaim()
		self:onHide();
	end
	
	self.baseaward_item_item = {};
	self.baseaward_item_item_image = {};
	self.baseaward_item_item_num = {};
	
	for i=1, 2 do
		self:Child("baseaward-item"..i.."-back"):SetVisible(false);
		
		self.baseaward_item_item[i] = LORD.toStaticImage(self:Child( "baseaward-item-item"..i ));
		self.baseaward_item_item_image[i] = LORD.toStaticImage(self:Child( "baseaward-item-item"..i.."-image" ));
		self.baseaward_item_item_num[i] = self:Child( "baseaward-item-item"..i.."-num" );
		self.baseaward_item_item_image[i]:SetImage("");
		self.baseaward_item_item_num[i]:SetText("");
		
		self.baseaward_item_item[i]:SetVisible(false);
	end
	
	self.baseaward_res_money = {};
	self.baseaward_res_money_num = {};
	
	for i=1, 2 do
		self.baseaward_res_money[i] = LORD.toStaticImage(self:Child( "baseaward-res-money"..i ));
		self.baseaward_res_money_num[i] = self:Child( "baseaward-res-money"..i.."-num" );
		self.baseaward_res_money_num[i]:SetText("");	
	end
	
	self.baseaward_button = self:Child( "baseaward-button" );
	self.baseaward_button:subscribeEvent("ButtonClick", "onClickBaseAwardClaim");
	
	self:updateAwardData(event);
	
end

function baseaward:onHide(event)
	self:Close();
end

function baseaward:updateAwardData(event)
	
	--[[
	if event.gold then
		self.baseaward_res_money1_num:SetText(event.gold);
	else
		self.baseaward_res_money1_num:SetText(0);
	end
	
	if event.wood then
		self.baseaward_res_money2_num:SetText(event.wood);
	else
		self.baseaward_res_money2_num:SetText(0);
	end
	
	if event.items[1] and event.items[1].icon and event.items[1].count then
		self.baseaward_item_item1_image:SetImage(event.items[1].icon);
		self.baseaward_item_item1_num:SetText(event.items[1].count);
	else
		self.baseaward_item_item1_image:SetImage("");
		self.baseaward_item_item1_num:SetText("");
	end

	if event.items[2] and event.items[2].icon and event.items[2].count then
		self.baseaward_item_item2_image:SetImage(event.items[2].icon);
		self.baseaward_item_item2_num:SetText(event.items[2].count);
	else
		self.baseaward_item_item2_image:SetImage("");
		self.baseaward_item_item2_num:SetText("");
	end
	--]]
	
	local incidentConfig = event.incidentConfig;
	moneyIndex = 1;
	itemIndex = 1;
	if incidentConfig then
		
		local rewardIDs = incidentConfig.rewardID;
		local rewardCounts = incidentConfig.rewardCount;
		
		for k,v in ipairs(incidentConfig.rewardType) do
			
			local rewardInfo = dataManager.playerData:getRewardInfo(v, rewardIDs[k], rewardCounts[k]);
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY and self.baseaward_res_money[moneyIndex] then
				self.baseaward_res_money[moneyIndex]:SetImage(rewardInfo.icon);
				self.baseaward_res_money_num[moneyIndex]:SetText(rewardInfo.count);
				moneyIndex = moneyIndex + 1;
			elseif self.baseaward_item_item[itemIndex] then
				
				self:Child("baseaward-item"..itemIndex.."-back"):SetVisible(true);
				self.baseaward_item_item[itemIndex]:SetVisible(true);
				
				self.baseaward_item_item_image[itemIndex]:SetImage(rewardInfo.icon);
				global.setMaskIcon(self.baseaward_item_item_image[itemIndex], rewardInfo.maskicon);
				
				self.baseaward_item_item[itemIndex]:SetImage(itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris));
				self.baseaward_item_item_num[itemIndex]:SetText(rewardInfo.count);
				
					-- °ó¶¨tipsÊÂ¼þ
				self.baseaward_item_item_image[itemIndex]:SetUserData(rewardIDs[k]);
				
				if v == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
					self.baseaward_item_item_image[itemIndex]:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
				end
								
				global.onItemTipsShow(self.baseaward_item_item_image[itemIndex], v, "top");
				global.onItemTipsHide(self.baseaward_item_item_image[itemIndex]);
									
				if rewardInfo.count == 1 then
					self.baseaward_item_item_num[itemIndex]:SetText("");
				end
				itemIndex = itemIndex + 1;			
			end
			
		end
		
	end
			
end

return baseaward;
