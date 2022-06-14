local robResult = class( "robResult", layout );

global_event.ROBRESULT_SHOW = "ROBRESULT_SHOW";
global_event.ROBRESULT_HIDE = "ROBRESULT_HIDE";

function robResult:ctor( id )
	robResult.super.ctor( self, id );
	self:addEvent({ name = global_event.ROBRESULT_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ROBRESULT_HIDE, eventHandler = self.onHide});
end

function robResult:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	local result = battlePlayer.win;
	
	local robResult_success = self:Child("robResult-success");
	local robResult_fail = self:Child("robResult-fail");
	robResult_success:SetVisible(result);
	robResult_fail:SetVisible(not result);
	
		if result then
			
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(200, -100, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(2, 2, 2), 1, 0);
            action:addKeyFrame(LORD.Vector3(200, -100, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(2, 2, 2), 1, 1800);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 1850);
			robResult_success:playAction(action);
			
			
			
		end
		if not result then
			
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(200, -100, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(2, 2, 2), 1, 0);
            action:addKeyFrame(LORD.Vector3(200, -100, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(2, 2, 2), 1, 1800);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 1850);
			robResult_fail:playAction(action);
			
		    
		end
		
	    scheduler.performWithDelayGlobal(function() 
        local ui = self:Child("robResult");
        if ui then
           uiaction.shake(ui);
        end
        end, 1.8);
		
		
		--uiaction.shake(robResult_window);
		
			
	
	function onRobResultClose()
		
		self:onHide();
		
	end
	
	local robResult_close = self:Child("robResult-close");
	robResult_close:subscribeEvent("ButtonClick", "onRobResultClose");
		
	local robItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("robResult", "idolStatusRobItem.dlg");

	local robResult_dw = self:Child("robResult-dw");
	robResult_dw:AddChildWindow(robItem);
			
	-- update info 
	local head = LORD.toStaticImage(self:Child("robResult_idolStatusRobItem-playerhead"));
	local lv = self:Child("robResult_idolStatusRobItem-lv");
	local name = self:Child("robResult_idolStatusRobItem-name");
	local power_num = self:Child("robResult_idolStatusRobItem-power-num");
	local giftname = self:Child("robResult_idolStatusRobItem-giftname");
	local idolStatusRobItem_fight = self:Child("robResult_idolStatusRobItem-fight");
	
	local targetInfo = dataManager.idolBuildData:getCurrentSelectTargetInfo();
	
	name:SetText(targetInfo.name);
	power_num:SetText("战斗力："..targetInfo.playerPower);
	lv:SetText("Lv "..targetInfo.kingInfo.level);
	head:SetImage(global.getHeadIcon(targetInfo.icon));
 	
 	
 	local giftname = self:Child("robResult_idolStatusRobItem-giftname");
 	local none = self:Child("robResult_idolStatusRobItem-none");
 	local gift_rongyu_dw = self:Child("robResult_idolStatusRobItem-rongyu-dw");
 	local gift_money_dw = self:Child("robResult_idolStatusRobItem-money-dw");
 	local gift_container = self:Child("robResult_idolStatusRobItem-gift-container");
 	local gift_image = LORD.toStaticImage(self:Child("robResult_idolStatusRobItem-gift-image"));
 	local gift_money_num = self:Child("robResult_idolStatusRobItem-gift-money-num");
 	local gift_rongyu_num = self:Child("robResult_idolStatusRobItem-gift-rongyu-num");
 	local idolStatusRobItem_fight = self:Child("robResult_idolStatusRobItem-fight");
 	idolStatusRobItem_fight:SetVisible(false);
 	
 	local itemname = "";
 	local itemicon = "";
 	
 	local itemInfo = dataManager.idolBuildData:getRewardPrimalItem();
 	
 	dump(itemInfo);
 	
 	if itemInfo then
 		itemname = itemInfo.name;
 		itemicon = itemInfo.icon;
 	end
 	
	local robResult_text = self:Child("robResult-text");
	
	local gold = dataManager.idolBuildData:getRewardGold();
	local honor = dataManager.idolBuildData:getRewardHonor();
	
	gift_money_num:SetText(gold);
	gift_rongyu_num:SetText(honor);
	
	if not result then
		
		robResult_text:SetText("本次战斗失败不消耗抢夺次数，变强后再来吧！");
		
		giftname:SetVisible(false);
		none:SetVisible(true);
		gift_rongyu_dw:SetVisible(false);
		gift_money_dw:SetVisible(false);
		gift_container:SetVisible(false);
		
	else
		
		if dataManager.idolBuildData:isRobItemSuccess() then
		
			robResult_text:SetText("恭喜您成功抢到了【"..itemname.."】！");

			local primalType = itemInfo.id-1;							
			gift_image:SetImage(itemicon);
			-- tips
			gift_image:SetUserData(primalType);
			global.onItemTipsShow(gift_image, enum.REWARD_TYPE.REWARD_TYPE_PRIMAL, "top");
			global.onItemTipsHide(gift_image);
					
			giftname:SetVisible(false);
			none:SetVisible(false);
			gift_rongyu_dw:SetVisible(true);
			gift_money_dw:SetVisible(false);
			gift_container:SetVisible(true);
					
		else
			
			local gold = dataManager.idolBuildData:getRewardGold();
			
			local primalType = dataManager.idolBuildData:getPlunderType();
			
			local itemname = dataManager.idolBuildData:getPrimalItemInfo(primalType).name;
			
			robResult_text:SetText("虽然没有抢到【"..itemname.."】，但是顺手搞到了【"..gold.."】金币！");
			
			giftname:SetVisible(false);
			none:SetVisible(false);
			gift_rongyu_dw:SetVisible(true);
			gift_money_dw:SetVisible(true);
			gift_container:SetVisible(false);
					
		end
	end
	
end

function robResult:onHide(event)
	
	self:Close();
	
	dataManager.idolBuildData:clearRewardInfo();
	
end

return robResult;
