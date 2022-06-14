local baselevelup = class( "baselevelup", layout );

global_event.BASELEVELUP_SHOW = "BASELEVELUP_SHOW";
global_event.BASELEVELUP_HIDE = "BASELEVELUP_HIDE";

function baselevelup:ctor( id )
	baselevelup.super.ctor( self, id );
	self:addEvent({ name = global_event.BASELEVELUP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BASELEVELUP_HIDE, eventHandler = self.onHide});
end

function baselevelup:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onClickBaseLevelUp()
		
		local baseData = dataManager.mainBase;
		if not baseData:isEnoughWood() then
			eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
			return;
		end
				
		if not baseData:isEnoughHammer() then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "锤子不足，无法升级！" });
				return;
		elseif not baseData:isEnoughPlayerLevel() then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "国王等级不足，无法升级！" });
				return;			
		end
		
		-- 升级
		sendUpgradeBuild(0, BUILD.BUILD_MAIN_BASE);
		LORD.SoundSystem:Instance():playEffect("chouka02.mp3");
		self:onHide();
	end
	
	function onClickBaseLevelUpCancel()
		self:onHide();
	end
	
	self.baselevelup_herolv_num = self:Child( "baselevelup-herolv-num" );
	self.baselevelup_chuizi_num = self:Child( "baselevelup-chuizi-num" );
	self.baselevelup_jinbi_num = self:Child( "baselevelup-jinbi-num" );
	self.baselevelup_shengjiqian_lv_num = self:Child( "baselevelup-shengjiqian-lv-num" );
	self.baselevelup_shengjiqian_lingdi = self:Child( "baselevelup-shengjiqian-lingdi" );
	self.baselevelup_shengjihou = LORD.toStaticImage(self:Child( "baselevelup-shengjihou" ));
	self.baselevelup_shengjihou_lv_num = self:Child( "baselevelup-shengjihou-lv-num" );
	self.baselevelup_shengjihou_lingdi = self:Child( "baselevelup-shengjihou-lingdi" );
	self.baselevelup_jianzao = self:Child( "baselevelup-jianzao" );
	self.baselevelup_quxiao = self:Child( "baselevelup-quxiao" );
	self.baselevelup_num = self:Child("baselevelup-num");
	
	self.baselevelup_jianzao:subscribeEvent("ButtonClick", "onClickBaseLevelUp");
	self.baselevelup_quxiao:subscribeEvent("ButtonClick", "onClickBaseLevelUpCancel");
	self._view:subscribeEvent("WindowTouchUp", "onClickBaseLevelUpCancel");
	
	self.baselevelup_back = self:Child("baselevelup-back");
	
	self.baselevelup_quxiao:SetVisible(false);
	local startPos = LORD.Vector3(-500, 0, 0);
	local endPos = LORD.Vector3(0, 0, 0);
	local time = 300;
	
	local action = LORD.GUIAction:new();
	action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
	self.baselevelup_back:playAction(action);
	
	function onBaseLevelupShowEnd()
		if self.baselevelup_quxiao then
			self.baselevelup_quxiao:SetVisible(true);
		end
	end
	
	self.baselevelup_back:subscribeEvent("UIActionEnd", "onBaseLevelupShowEnd");

	self:onUpdateBaseLevelUpInfo(event);
	
end

function baselevelup:onHide(event)
	self:Close();
	
	self.baselevelup_quxiao = nil;
	
	eventManager.dispatchEvent({name = global_event.GOLDMINE_CLOSE_LEVEL_UP, });
	
end

function baselevelup:onUpdateBaseLevelUpInfo(event)
	local player = dataManager.playerData;
	local baseData = dataManager.mainBase;
	local baseConfigInfo = baseData:getConfig();
	
	-- 玩家等级
	local needLevel = baseConfigInfo.heroLevel;
	
	local requireHammer = baseConfigInfo.hammerRequire;
	local requireWood = baseConfigInfo.lumberCost;
	
	local beforeLevel = baseConfigInfo.id;
	local beforeLingDiCount = baseData:getLingDiCount();
	
	if baseData:isEnoughPlayerLevel() then
		self.baselevelup_herolv_num:SetText(needLevel);
	else
		self.baselevelup_herolv_num:SetText("^FF0000"..needLevel);
	end
	
	if baseData:isEnoughHammer() then
		self.baselevelup_chuizi_num:SetText(requireHammer);
	else
		self.baselevelup_chuizi_num:SetText("^FF0000"..requireHammer);
	end

	if baseData:isEnoughWood() then
		self.baselevelup_jinbi_num:SetText(requireWood);
	else
		self.baselevelup_jinbi_num:SetText("^FF0000"..requireWood);
	end
	
	self.baselevelup_shengjiqian_lv_num:SetText(beforeLevel);
	self.baselevelup_shengjiqian_lingdi:SetText("事件数量: "..beforeLingDiCount);
	
	if baseData:isMaxLevel() then
		self.baselevelup_shengjihou:SetVisible(false);
		self.baselevelup_jianzao:SetEnabled(false);
		self.baselevelup_num:SetText("");
	else
		self.baselevelup_jianzao:SetEnabled(true);
		self.baselevelup_shengjihou:SetVisible(true);
		
		local nextBaseConfigInfo = baseData:getConfig(baseConfigInfo.id+1);
		self.baselevelup_shengjihou_lv_num:SetText(nextBaseConfigInfo.id);
		self.baselevelup_shengjihou_lingdi:SetText("→   "..baseData:getLingDiCount(nextBaseConfigInfo.id));
		
		local lvlupTime = formatTime(baseConfigInfo.timeCost, true);
		self.baselevelup_num:SetText(lvlupTime);
	end
	
end

return baselevelup;
