local pvpreward = class( "pvpreward", layout );

global_event.PVPREWARD_SHOW = "PVPREWARD_SHOW";
global_event.PVPREWARD_HIDE = "PVPREWARD_HIDE";

function pvpreward:ctor( id )
	pvpreward.super.ctor( self, id );
	self:addEvent({ name = global_event.PVPREWARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.PVPREWARD_HIDE, eventHandler = self.onHide});
  
end

function pvpreward:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	self.pvpreward_money = {} 
	self.pvpreward_money[1] = {}
	self.pvpreward_money[2] = {}
	self.pvpreward_money[3] = {} 
	self.pvpreward_money1 = LORD.toStaticImage(self:Child( "pvpreward-money1" ));
	self.pvpreward_money[1].icon = self.pvpreward_money1	
	self.pvpreward_money1_num = self:Child( "pvpreward-money1-num" );
	self.pvpreward_money[1].num = self.pvpreward_money1_num 
	
	
	
	self.pvpreward_money2 = LORD.toStaticImage(self:Child( "pvpreward-money2" ));
	self.pvpreward_money[2].icon =self.pvpreward_money2 
	
	self.pvpreward_money2_num = self:Child( "pvpreward-money2-num" );
	self.pvpreward_money[2].num = self.pvpreward_money2_num
	
	self.pvpreward_money3 = LORD.toStaticImage(self:Child( "pvpreward-money3" ));
	self.pvpreward_money[3].icon =self.pvpreward_money3	
	
	
	self.pvpreward_money3_num = self:Child( "pvpreward-money3-num" );	
	self.pvpreward_money[3].num = self.pvpreward_money3_num 
	
	
	self.pvpreward_item = LORD.toStaticImage(self:Child( "pvpreward-item" ));
	self.pvpreward_item_image = LORD.toStaticImage(self:Child( "pvpreward-item-image" ));
	self.pvpreward_item_num = self:Child( "pvpreward-item-num" );
	self.pvpreward_button = self:Child( "pvpreward-button" );
	
	self.pvpreward_item_equity = LORD.toStaticImage(self:Child("pvpreward-item-equity"));
	
	self.pvpreward_win_num = self:Child( "pvpreward-win-num" )
	self.pvpreward_fail_num = self:Child( "pvpreward-fail-num" )
	
	function onClickpvpreward_button()	
		self:onHide();		
	end
 
	self.pvpreward_button:subscribeEvent("ButtonClick", "onClickpvpreward_button");	
	
	self:update()
end

function pvpreward:update()
		 self.pvpreward_money1_num:SetText("0")
		 self.pvpreward_money2_num:SetText("0")
		 self.pvpreward_money3_num:SetText("0")
		
		for i, v in pairs (self.pvpreward_money) do
			v.icon:SetImage("")
			v.num:SetText("")
		end
		
		 self.pvpreward_item:SetVisible(false); 		
		 local winNum = 	dataManager.pvpData:getOnlineWinNum()		
		 self.pvpreward_win_num:SetText(winNum)
		 self.pvpreward_fail_num:SetText( dataManager.pvpData:getOnlineLoseNum())		
				
		 local findIndex = nil
		 for i ,v in pairs (dataConfig.configs.PvpOnlineConfig)do
				if(v.wins == winNum)then
					findIndex = i
				end					
		 end
	 	
		
		local t = dataConfig.configs.PvpOnlineConfig[findIndex]	
		
		local moneyIndex = 0
		for i,v in ipairs (t.rewardType) do 
			local subId =  t.rewardID[i]
			local c = t.rewardCount[i]
			local rewardInfo = dataManager.playerData:getRewardInfo(v,subId, c)	
			
			if(rewardInfo)then
				 if(v == enum.REWARD_TYPE.REWARD_TYPE_ITEM)	then
					self.pvpreward_item:SetVisible(true); 	
					self.pvpreward_item_image:SetImage(rewardInfo['icon'])  	
					self.pvpreward_item_num:SetText(rewardInfo['count'])  	
					self.pvpreward_item_equity:SetImage( itemManager.getImageWithStar(rewardInfo['star']))
					
					-- °ó¶¨tipsÊÂ¼þ
					self.pvpreward_item_image:SetUserData(subId);
					
					if v == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
						self.pvpreward_item_image:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
					end
										
					global.onItemTipsShow(self.pvpreward_item_image, v, "top");
					global.onItemTipsHide(self.pvpreward_item_image);
								
				 elseif(v == enum.REWARD_TYPE.REWARD_TYPE_MONEY)	then
					if(c > 0)then
						moneyIndex = moneyIndex + 1
						self.pvpreward_money[moneyIndex].num:SetText(c)	
						self.pvpreward_money[moneyIndex].icon:SetImage(enum.MONEY_ICON_STRING[subId])	
					end
					--[[
					 if(subId== enum.MONEY_TYPE.MONEY_TYPE_GOLD)then
						 self.pvpreward_money1_num:SetText(c)					
					 elseif(subId == enum.MONEY_TYPE.MONEY_TYPE_LUMBER)then						
						self.pvpreward_money2_num:SetText(c)					
					 elseif(subId == enum.MONEY_TYPE.MONEY_TYPE_VIGOR)then	
						self.pvpreward_money3_num:SetText(c)
					 end
					]]--
					
					
			     end				
			end	

		end			
end
	
function pvpreward:onHide(event)
	self:Close();
end

return pvpreward;
