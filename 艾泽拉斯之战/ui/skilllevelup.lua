local skilllevelup = class( "skilllevelup", layout );

global_event.SKILLLEVELUP_SHOW = "SKILLLEVELUP_SHOW";
global_event.SKILLLEVELUP_HIDE = "SKILLLEVELUP_HIDE";
global_event.SKILLLEVELUP_UPDATE = "SKILLLEVELUP_UPDATE";

function skilllevelup:ctor( id )
	skilllevelup.super.ctor( self, id );
	self:addEvent({ name = global_event.SKILLLEVELUP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SKILLLEVELUP_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.SKILLLEVELUP_UPDATE, eventHandler = self.updateMagicTowerLevelUpInfo});
end

function skilllevelup:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onClickMagicTowerLevelup()
		self:magicTowerLevelup();
	end
	
	function onClickMagicTowerCancel()
		self:onHide();
	end
		
	self.skilllevgelup_baselv_num = self:Child( "skilllevgelup-baselv-num" );
	self.skilllevgelup_chuizi_num = self:Child( "skilllevgelup-chuizi-num" );
	self.skilllevgelup_jinbi_num = self:Child( "skilllevgelup-jinbi-num" );
	self.skilllevelup_beforelv_num = self:Child( "skilllevelup-beforelv-num" );
	self.skilllevelup_before_hammer_num = self:Child( "skilllevelup-before-hammer-num" );
	self.skilllevelup_afterlv_num = self:Child( "skilllevelup-afterlv-num" );
	self.skilllevelup_after_hammer_num = self:Child( "skilllevelup-after-hammer-num" );
	self.skilllevelup_jianzao = self:Child( "skilllevelup-jianzao" );
	self.skilllevelup_quxiao = self:Child( "skilllevelup-quxiao" );
	
	self.skilllevelup_quxiao:subscribeEvent("ButtonClick", "onClickMagicTowerCancel");
	self._view:subscribeEvent("WindowTouchUp", "onClickMagicTowerCancel");
	
	self.skilllevelup_jianzao:subscribeEvent("ButtonClick", "onClickMagicTowerLevelup");
	
	self.skilllevelup_time_num = self:Child( "skilllevelup-time-num" );

	self:updateMagicTowerLevelUpInfo(event);
	
	self.skilllevelup_quxiao:SetVisible(false);
	local startPos = LORD.Vector3(-500, 0, 0);
	local endPos = LORD.Vector3(0, 0, 0);
	local time = 300;
	
	local action = LORD.GUIAction:new();
	action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
	self._view:playAction(action);
	
	function onSkillLevelupShowEnd()
		if self.skilllevelup_quxiao then
			self.skilllevelup_quxiao:SetVisible(true);
		end
	end
	
	self._view:subscribeEvent("UIActionEnd", "onSkillLevelupShowEnd");
		
end

function skilllevelup:onHide(event)
	self:Close();
	
	eventManager.dispatchEvent({name = global_event.GOLDMINE_CLOSE_LEVEL_UP });
	
end

function skilllevelup:updateMagicTowerLevelUpInfo(event)
	
	if not self._show then
		return;
	end
	
	local magicTowerData = dataManager.magicTower;
	local magicTowerConfig = magicTowerData:getMagicTowerConfig();
	
	if magicTowerConfig then
	
		local magicTowerData = dataManager.magicTower;
		if magicTowerData:isEnoughBaseLevel() then
			self.skilllevgelup_baselv_num:SetText(magicTowerConfig.levelLimit);
		else
			self.skilllevgelup_baselv_num:SetText("^FF0000"..magicTowerConfig.levelLimit);
		end
		
		if magicTowerData:isEnoughWood() then
			self.skilllevgelup_jinbi_num:SetText(magicTowerConfig.lumberCost);
		else
			self.skilllevgelup_jinbi_num:SetText("^FF0000"..magicTowerConfig.lumberCost);
		end
		
		self.skilllevelup_time_num:SetText(formatTime(magicTowerConfig.timeCost, true));
		
		self.skilllevelup_beforelv_num:SetText(magicTowerConfig.id);
		self.skilllevelup_before_hammer_num:SetText(magicTowerConfig.hammer);

		if dataManager.build.isWorkerFree() then
			self.skilllevgelup_chuizi_num:SetText("1");
		else
			self.skilllevgelup_chuizi_num:SetText("^FF00001");
		end
			
		if magicTowerData:isMaxLevel() then
			self.skilllevelup_afterlv_num:SetText("");
			self.skilllevelup_after_hammer_num:SetText("");
			self.skilllevelup_jianzao:SetEnabled(false);
		else
			self.skilllevelup_jianzao:SetEnabled(true);
			local nextLevelInfo = magicTowerData:getNextMagicTowerConfig();
			self.skilllevelup_afterlv_num:SetText(nextLevelInfo.id);
			self.skilllevelup_after_hammer_num:SetText(nextLevelInfo.hammer);		
		end		
	end
	
end

function skilllevelup:magicTowerLevelup()
	local magicTowerData = dataManager.magicTower;
	
	if not dataManager.build.isWorkerFree() then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "没有空闲工人，无法升级！" });						
		return;
	end

	function onSkillLevelupGotoBase()
		
		self:onHide();
		eventManager.dispatchEvent({name = global_event.SKILLTOWER_HIDE });
		homeland.gotobase = true;
		
	end
		
	if not magicTowerData:isEnoughBaseLevel() then
	
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
	
			textInfo = "城堡等级不足，无法升级，是否前往城堡提升城堡等级？", callBack = onSkillLevelupGotoBase });				
		return;
		
	end
	
	if magicTowerData:isEnoughWood() then
		sendUpgradeBuild(0, BUILD.BUILD_MAGIC_TOWER);
		self:onHide();
	else
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
	end
	
end

return skilllevelup;
