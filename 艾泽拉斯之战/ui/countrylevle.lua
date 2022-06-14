local countrylevle = class( "countrylevle", layout );

global_event.COUNTRYLEVLE_SHOW = "COUNTRYLEVLE_SHOW";
global_event.COUNTRYLEVLE_HIDE = "COUNTRYLEVLE_HIDE";

function countrylevle:ctor( id )
	countrylevle.super.ctor( self, id );
	self:addEvent({ name = global_event.COUNTRYLEVLE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.COUNTRYLEVLE_HIDE, eventHandler = self.onHide});
end

function countrylevle:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onCountryLevelGotoBase()
		
		self:onHide();
		--local cameraData = homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.BASE];
		--local camera = LORD.SceneManager:Instance():getMainCamera();
		--camera:setPosition(cameraData.pos);
		--camera:setDirection(cameraData.dir);
			
		--eventManager.dispatchEvent({name = global_event.BASE_SHOW});
		eventManager.dispatchEvent({name = global_event.GOLDMINE_HIDE });
		eventManager.dispatchEvent({name = global_event.WOOD_HIDE });
		
		homeland.gotobase = true;
	end
	
	function onClickCountryLevelBuild()
		
		if self.sourceType == "gold" then
			
			local localGoldMineData = dataManager.goldMineData;
			
			if not localGoldMineData:isEnoughBaseLevel() then
				eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					text = "城堡等级不足，无法升级，是否前往城堡提升城堡等级？" , callBack = onCountryLevelGotoBase});				

				return;
			end
		
			if not localGoldMineData:isEnoughWood() then
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
				return;
			end
			
			if not dataManager.build.isWorkerFree() then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "没有空闲工人，无法升级！" });						
				return;
			end
			
			sendUpgradeBuild(0, BUILD.BUILD_GOLD_MINE);
			--触发指引
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_COUNTRY_LEVELUP})
			
		elseif self.sourceType == "wood" then
			
			local localLumberMillData = dataManager.lumberMillData;
			
			if not localLumberMillData:isEnoughBaseLevel() then
				eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					text = "城堡等级不足，无法升级，是否前往城堡提升城堡等级？", callBack = onCountryLevelGotoBase });				

				return;
			end
		
			if not localLumberMillData:isEnoughWood() then
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
				return;
			end
			
			if not dataManager.build.isWorkerFree() then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "没有空闲工人，无法升级！" });						
				return;
			end
			
			sendUpgradeBuild(0, BUILD.BUILD_LUMBER_MILL);	
			
		
		end
		LORD.SoundSystem:Instance():playEffect("chouka02.mp3");
		self:onHide();
	end
	
	function onClickCountryLevelCancel()
		self:onHide();
	end
	
	self.countrylevle_close = self:Child( "countrylevle-close" );
	self.countrylevle_close:subscribeEvent("ButtonClick","onClickCountryLevelCancel");
	self._view:subscribeEvent("WindowTouchUp","onClickCountryLevelCancel");
	
	self.countrylevle_zhucheng_num = self:Child( "countrylevle-zhucheng-num" );
	self.countrylevle_mucai_num = self:Child( "countrylevle-mucai-num" );
	self.countrylevle_gongren_num = self:Child( "countrylevle-gongren-num" );
	self.countrylevle_shengjiqian_lv_num = self:Child( "countrylevle-shengjiqian-lv-num" );
	self.countrylevle_shengjiqian_shuxing1_num = self:Child( "countrylevle-shengjiqian-shuxing1-num" );
	self.countrylevle_shengjiqian_shuxing2_num = self:Child( "countrylevle-shengjiqian-shuxing2-num" );
	self.countrylevle_shengjiqian_shuxing2 = self:Child("countrylevle-shengjiqian-shuxing2");
	self.countrylevle_shengjiqian_shuxing3_num = self:Child( "countrylevle-shengjiqian-shuxing3-num" );
	self.countrylevle_shengjihou = LORD.toStaticImage(self:Child( "countrylevle-shengjihou" ));
	self.countrylevle_shengjihou_lv_num = self:Child( "countrylevle-shengjihou-lv-num" );
	self.countrylevle_shengjihou_shuxing1_num = self:Child( "countrylevle-shengjihou-shuxing1-num" );
	self.countrylevle_shengjihou_shuxing2_num = self:Child( "countrylevle-shengjihou-shuxing2-num" );
	self.countrylevle_shengjihou_shuxing2 = self:Child("countrylevle-shengjihou-shuxing2");
	self.countrylevle_shengjihou_shuxing3_num = self:Child( "countrylevle-shengjihou-shuxing3-num" );
	self.countrylevle_jianzao = self:Child( "countrylevle-jianzao" );
	self.countrylevle_quxiao = self:Child( "countrylevle-quxiao" );
	self.countrylevle_mucai = LORD.toStaticImage(self:Child("countrylevle-mucai"));
	self.countrylevle_jianzao:subscribeEvent("ButtonClick","onClickCountryLevelBuild");
	self.countrylevle_quxiao:subscribeEvent("ButtonClick","onClickCountryLevelCancel");
	self.countrylevle_num = self:Child("countrylevle-num");
	
	self.sourceType = event.sourceType;
	self:onUpdateCountryLevel(event);

	self.countrylevle_close:SetVisible(false);
	local startPos = LORD.Vector3(-500, 0, 0);
	local endPos = LORD.Vector3(0, 0, 0);
	local time = 300;
	
	local action = LORD.GUIAction:new();
	action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
	self._view:playAction(action);
	
	function onCountryLevelupShowEnd()
		if self.countrylevle_close then
			self.countrylevle_close:SetVisible(true);
		end
	end
	
	self._view:subscribeEvent("UIActionEnd", "onCountryLevelupShowEnd");
		
		
	--触发指引
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_OPEN_COUNTRYLEVEL,arg1 = event.sourceType})	
end

function countrylevle:onHide(event)
	
	self:Close();
	eventManager.dispatchEvent({name = global_event.GOLDMINE_CLOSE_LEVEL_UP })
	
end

function countrylevle:onUpdateCountryLevel(event)
	if event.sourceType == "gold" then
		self:updateGoldLevelup(event);
	elseif event.sourceType == "wood" then
		self:updateWoodLevelup(event);
	end
end

function countrylevle:updateGoldLevelup(event)

	local localGoldMineData = dataManager.goldMineData;
	local playerData = dataManager.playerData;
	local goldConfig = localGoldMineData:getConfig();
	
	local requireBaseLevel = goldConfig.levelLimit;
	local requireWood = goldConfig.lumberCost;
	
	if localGoldMineData:isEnoughBaseLevel() then
		self.countrylevle_zhucheng_num:SetText(requireBaseLevel);
	else
		self.countrylevle_zhucheng_num:SetText("^FF0000"..requireBaseLevel);
	end

	if localGoldMineData:isEnoughWood() then
		self.countrylevle_mucai_num:SetText(requireWood);
	else
		self.countrylevle_mucai_num:SetText("^FF0000"..requireWood);
	end
	
	
	if dataManager.build.isWorkerFree() then
		self.countrylevle_gongren_num:SetText("1");
	else
		self.countrylevle_gongren_num:SetText("^FF00001");
	end
	
	local beforeLevel = goldConfig.id;
	local beforeOutput = dataManager.goldMineData:getOutputPerHour(beforeLevel);
	local beforeMaxOutput = beforeOutput * localGoldMineData:getMaxOutputRadio();
	local beforeHammer = goldConfig.hammer;

	self.countrylevle_shengjiqian_lv_num:SetText(beforeLevel);
	self.countrylevle_shengjiqian_shuxing1_num:SetText(beforeOutput);
	self.countrylevle_shengjiqian_shuxing2:SetVisible(true);
	self.countrylevle_shengjiqian_shuxing2_num:SetText(beforeMaxOutput);
	self.countrylevle_shengjiqian_shuxing3_num:SetText(beforeHammer);
		
	if localGoldMineData:isMaxLevel() then
		self.countrylevle_shengjihou:SetVisible(false);
		self.countrylevle_jianzao:SetEnabled(false);
		self.countrylevle_num:SetText("");
	else
		self.countrylevle_jianzao:SetEnabled(true);
		self.countrylevle_shengjihou:SetVisible(true);

		local nextGoldConfig = localGoldMineData:getConfig(beforeLevel+1);
		local afterLevel = nextGoldConfig.id;
		local afterOutput = dataManager.goldMineData:getOutputPerHour(beforeLevel+1);
		local afterMaxOutput = afterOutput * localGoldMineData:getMaxOutputRadio();
		local afterHammer = nextGoldConfig.hammer;

		self.countrylevle_shengjihou_lv_num:SetText(afterLevel);
		self.countrylevle_shengjihou_shuxing1_num:SetText(afterOutput);
		self.countrylevle_shengjihou_shuxing2_num:SetText(afterMaxOutput);
		self.countrylevle_shengjihou_shuxing2:SetVisible(true);
		self.countrylevle_shengjihou_shuxing3_num:SetText(afterHammer);
		
		local lvlupTime = formatTime(goldConfig.timeCost, true);
		self.countrylevle_num:SetText(lvlupTime);
	end
	
end

function countrylevle:updateWoodLevelup(event)
	
	local localLumberMillData = dataManager.lumberMillData;
	local playerData = dataManager.playerData;
	local woodConfig = localLumberMillData:getConfig();
	
	local requireBaseLevel = woodConfig.levelLimit;
	local requireWood = woodConfig.lumberCost;
	
	if localLumberMillData:isEnoughBaseLevel() then
		self.countrylevle_zhucheng_num:SetText(requireBaseLevel);
	else
		self.countrylevle_zhucheng_num:SetText("^FF0000"..requireBaseLevel);
	end

	if localLumberMillData:isEnoughWood() then
		self.countrylevle_mucai_num:SetText(requireWood);
	else
		self.countrylevle_mucai_num:SetText("^FF0000"..requireWood);
	end
	
	
	if dataManager.build.isWorkerFree() then
		self.countrylevle_gongren_num:SetText("1");
	else
		self.countrylevle_gongren_num:SetText("^FF00001");
	end
	
	local beforeLevel = woodConfig.id;
	local beforeOutput = woodConfig.criticalBase;
	local beforeMaxOutput = localLumberMillData:getMaxOutputRadio();
	local beforeHammer = woodConfig.hammer;

	self.countrylevle_shengjiqian_lv_num:SetText(beforeLevel);
	self.countrylevle_shengjiqian_shuxing1_num:SetText(beforeOutput);
	--self.countrylevle_shengjiqian_shuxing2_num:SetText(beforeMaxOutput);
	self.countrylevle_shengjiqian_shuxing3_num:SetText(beforeHammer);
	self.countrylevle_shengjiqian_shuxing2:SetVisible(false);
		
	if localLumberMillData:isMaxLevel() then
		self.countrylevle_shengjihou:SetVisible(false);
		self.countrylevle_jianzao:SetEnabled(false);
		self.countrylevle_num:SetText("");
	else
		self.countrylevle_jianzao:SetEnabled(true);
		self.countrylevle_shengjihou:SetVisible(true);

		local nextWoodConfig = localLumberMillData:getConfig(beforeLevel+1);
		local afterLevel = nextWoodConfig.id;
		local afterOutput = nextWoodConfig.criticalBase;
		local afterMaxOutput = localLumberMillData:getMaxOutputRadio();
		local afterHammer = nextWoodConfig.hammer;

		self.countrylevle_shengjihou_lv_num:SetText(afterLevel);
		self.countrylevle_shengjihou_shuxing1_num:SetText(afterOutput);
		--self.countrylevle_shengjihou_shuxing2_num:SetText(afterMaxOutput);
		self.countrylevle_shengjihou_shuxing2:SetVisible(false);
		self.countrylevle_shengjihou_shuxing3_num:SetText(afterHammer);

		local lvlupTime = formatTime(woodConfig.timeCost, true);
		self.countrylevle_num:SetText(lvlupTime);
		
	end
		
end

return countrylevle;
