local crusadeinfo = class( "crusadeinfo", layout );

global_event.CRUSADEINFO_SHOW = "CRUSADEINFO_SHOW";
global_event.CRUSADEINFO_HIDE = "CRUSADEINFO_HIDE";
global_event.CRUSADEINFO_UPDATE_REWARD_INFO = "CRUSADEINFO_UPDATE_REWARD_INFO";

function crusadeinfo:ctor( id )
	crusadeinfo.super.ctor( self, id );
	self:addEvent({ name = global_event.CRUSADEINFO_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CRUSADEINFO_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.CRUSADEINFO_UPDATE_REWARD_INFO, eventHandler = self.onUpdateRewardInfo});
end

function crusadeinfo:onShow(event)
	if self._show then
		return;
	end
	
	-- 打开的时候请求数据
	sendAskCrusader(dataManager.crusadeActivityData:getCurrentStageIndex()-1);
	
	self:Show();
	
	function onCrusadeInfoClose()
		self:onHide();
	end
	
	function onCrusadeInfoRunBattle()
			
		global.changeGameState(function() 		
			
			sceneManager.closeScene();
			
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			eventManager.dispatchEvent({name = global_event.ACTIVITY_HIDE});
			eventManager.dispatchEvent({name = global_event.CRUSADE_HIDE});
			eventManager.dispatchEvent({name = global_event.CRUSADEINFO_HIDE});
			
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE, 
					planType = enum.PLAN_TYPE.PLAN_TYPE_PVE });
					
		end);
								
	end
	
	self.crusadeinfo_close = self:Child( "crusadeinfo-close" );
	self.crusadeinfo_close:subscribeEvent("ButtonClick", "onCrusadeInfoClose");

	self.crusadeinfo_gofight = self:Child( "crusadeinfo-gofight" );
	self.crusadeinfo_gofight:subscribeEvent("ButtonClick", "onCrusadeInfoRunBattle");
	self.crusadeinfo_gofight:SetEnabled(false);
		
	-- reward	
	self.crusadeinfo_extragift_item = LORD.toScrollPane(self:Child( "crusadeinfo-extragift-item" ));
	self.crusadeinfo_extragift_item:init();
	
	self.crusadeinfo_npc = LORD.toStaticImage(self:Child( "crusadeinfo-npc" ));
	self.crusadeinfo_npc_name = self:Child( "crusadeinfo-npc-name" );		
	self.crusadeinfo_title_text = self:Child( "crusadeinfo-title-text" );
	
	self:updateInfo();
	
end

function crusadeinfo:onHide(event)
	self:Close();
end

function crusadeinfo:updateInfo()
	
	if not self._show then
		return;	
	end
	
	local stageIndex = dataManager.crusadeActivityData:getCurrentStageIndex();
	self.crusadeinfo_npc:SetImage(dataManager.crusadeActivityData:getStageKingFigureImage(stageIndex));
	self.crusadeinfo_npc_name:SetText(dataManager.crusadeActivityData:getStageNPCName(stageIndex));
	self.crusadeinfo_title_text:SetText(dataManager.crusadeActivityData:getStageName(stageIndex));
	
	-- reward info
	self.crusadeinfo_extragift_item:ClearAllItem();
	
	local playerData = dataManager.playerData;
	
	for i=1, 3 do
		local crusadeinfo_money_image = LORD.toStaticImage(self:Child( "crusadeinfo-money"..i.."-image" ));
		local crusadeinfo_money_num = self:Child( "crusadeinfo-money"..i.."-num" );
		local crusadeinfo_money_dw = self:Child("crusadeinfo-money"..i.."-dw");
		
		crusadeinfo_money_image:SetImage("");
		crusadeinfo_money_num:SetText("");
		crusadeinfo_money_dw:SetVisible(false);
		
	end
	
	-- moneyIndex
	local moneyIndex = 1;
	
	local scrollPanelSize = self.crusadeinfo_extragift_item:GetPixelSize();
	local xPosition = LORD.UDim(0, 5);
	local yPosition = LORD.UDim(0, 5);
	
	
	local stageInfo = dataManager.crusadeActivityData:getStageInfo(dataManager.crusadeActivityData:getCurrentStageIndex());
	
	if stageInfo then
	
		for k,v in ipairs(stageInfo.rewardType) do
			
			local rewardInfo = playerData:getRewardInfo(v, stageInfo.rewardID[k], stageInfo.rewardCount[k]);
			
			--dump(rewardInfo);
			
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY then
			
				local crusadeinfo_money_image = LORD.toStaticImage(self:Child( "crusadeinfo-money"..moneyIndex.."-image" ));
				local crusadeinfo_money_num = self:Child( "crusadeinfo-money"..moneyIndex.."-num" );
				
				if crusadeinfo_money_image then
					crusadeinfo_money_image:SetImage(rewardInfo.icon);
				end
				
				if crusadeinfo_money_num then
					crusadeinfo_money_num:SetText(rewardInfo.count);
				end
				
				local crusadeinfo_money_dw = self:Child("crusadeinfo-money"..moneyIndex.."-dw");
				crusadeinfo_money_dw:SetVisible(true);
				
				moneyIndex = moneyIndex + 1;
			else
				
				local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("crusadeinfo-"..k, "instanceawarditem.dlg");

				item:SetXPosition(xPosition);
				item:SetYPosition(yPosition);				
				self.crusadeinfo_extragift_item:additem(item);
				
				local itemFrame = LORD.toStaticImage(self:Child("crusadeinfo-"..k.."_instanceawarditem-item"));
				local itemIcon = LORD.toStaticImage(self:Child("crusadeinfo-"..k.."_instanceawarditem-item-image"));
				local itemequity = LORD.toStaticImage(self:Child("crusadeinfo-"..k.."_instanceawarditem-equity"));
				
				local rare = self:Child("crusadeinfo-"..k.."_instanceawarditem-rare");
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
				item:SetUserData(stageInfo.rewardID[k]);
				
				if v == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
					item:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
				end
				
				global.onItemTipsShow(item, v, "top");
				global.onItemTipsHide(item);
				
				for i=1, 5 do
					local star = self:Child("crusadeinfo-"..k.."_instanceawarditem-star"..i);
					
					star:SetVisible(i <= rewardInfo.showstar);
				end
				
				local instanceawarditem_num = self:Child("crusadeinfo-"..k.."_instanceawarditem-num");
				instanceawarditem_num:SetText(rewardInfo.count);
				instanceawarditem_num:SetVisible(rewardInfo.count > 1);
				
				xPosition = xPosition + item:GetWidth();

			end
			
		end
		
	end	
		
	
end

-- 服务器返回的奖励信息
function crusadeinfo:onUpdateRewardInfo()
	
	if not self._show then
		return;
	end
	
	self:updateInfo();
	
	local crusadeinfo_gofight = self:Child( "crusadeinfo-gofight" );
	crusadeinfo_gofight:SetEnabled(true);
	
end

return crusadeinfo;
