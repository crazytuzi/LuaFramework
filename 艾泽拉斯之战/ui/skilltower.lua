local skilltower = class( "skilltower", layout );

global_event.SKILLTOWER_SHOW = "SKILLTOWER_SHOW";
global_event.SKILLTOWER_HIDE = "SKILLTOWER_HIDE";
global_event.SKILLTOWER_UPDATE = "SKILLTOWER_UPDATE";

function skilltower:ctor( id )
	skilltower.super.ctor( self, id );
	self:addEvent({ name = global_event.SKILLTOWER_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SKILLTOWER_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.BUILD_ATTR_SYNC, eventHandler = self.updateUIInfo});
	self:addEvent({ name = global_event.SKILLTOWER_UPDATE, eventHandler = self.updateUIInfo});
	
	self:addEvent({ name = global_event.GOLDMINE_CLOSE_LEVEL_UP, eventHandler = self.onCloseLevelup});
	
end

function skilltower:onShow(event)
	if self._show then
		return;
	end
	
	self:Show();
	
	function onSkillTowerBuyMagic()
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = enum.BUY_RESOURCE_TYPE.MAGIC, copyType = -1, copyID = -1, });
	end
	
	local skilltower_suipinabiaozhi_add = self:Child("skilltower-suipinabiaozhi-add");
	skilltower_suipinabiaozhi_add:subscribeEvent("ButtonClick", "onSkillTowerBuyMagic");
	
	self.skilltower_close = self:Child( "skilltower-close" );
	
	self.skilltower_close:subscribeEvent("ButtonClick", "onClickClose");
	
	self.skilltower_level = self:Child( "skilltower-level" );
	self.skilltower_level:subscribeEvent("ButtonClick", "onClickMagicTowerLevelUP");
	
	self.skilltower_level_like = self:Child( "skilltower-level-like" );
	self.skilltower_level_like:subscribeEvent("ButtonClick", "onClickMagicTowerLevelUpNow");
		
	self.skilltower_ronghe = self:Child( "skilltower-ronghe" );
	self.skilltower_ronghe:subscribeEvent("ButtonClick", "onClickMagicTowerRongHe");
	
	self.skilltower_mingxiang = self:Child( "skilltower-mingxiang" );
	self.skilltower_mingxiang:subscribeEvent("ButtonClick", "onClickMagicTowerMingXiang");
	
	self.skilltower_quxiao = self:Child( "skilltower-quxiao" );
	self.skilltower_quxiao:subscribeEvent("ButtonClick", "onClickMagicTowerCancelLevelUp");
	
	self.skilltower_skill_list_button = self:Child( "skilltower-skill_list_button" );
	self.skilltower_skill_list_button:subscribeEvent("ButtonClick", "onClickMagicTowerMagicBook");
	
	self.skilltower_dangqian_num = self:Child( "skilltower-dangqian-num" );
	
	self.skilltower_shengjizhong_time = self:Child( "skilltower-shengjizhong-time" );
	self.skilltower_shengjizhong = self:Child( "skilltower-shengjizhong" );
	
	self.skilltower_cooling = self:Child( "skilltower-cooling" );
	
	self.skilltower_suipiannum = self:Child( "skilltower-suipiannum" );
	self.skilltower_num = self:Child( "skilltower-num" );

	function onSkillTowerMoneyTipsShow(args)
		
		local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", windowRect = rect, dir = "free", text = "魔法精华: "..dataManager.kingMagic:getExtraExp()});
			
	end
	
	function onSkillTowerMoneyTipsHide()
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
		
	self.skilltower_suipiannum:subscribeEvent("WindowTouchDown", "onSkillTowerMoneyTipsShow");
	self.skilltower_suipiannum:subscribeEvent("WindowTouchUp", "onSkillTowerMoneyTipsHide");
	self.skilltower_suipiannum:subscribeEvent("MotionRelease", "onSkillTowerMoneyTipsHide");
		
	self.skilltower_cooling_time = self:Child( "skilltower-cooling-time" );
	self.skilltower_cooling_time_text = self:Child( "skilltower-cooling-time-text" );
	
	self.skilltower_cooling_bar_num = self:Child( "skilltower-skillnum-num" );
	self.skilltower_skillnum_full = self:Child("skilltower-skillnum-full");
	
	self.skilltower_container = self:Child("skilltower-caikuang");
	
	self.skilltower_anniu = self:Child("skilltower-anniu");
	self.skilltower_title = self:Child("skilltower-title");
	self.skilltower_caikuang = self:Child("skilltower-caikuang");
	self.skilltower_shengjizhong = self:Child("skilltower-shengjizhong");
		
	self.levelUpHandle = nil;
	self.mingXiangHandle = nil;
		
	function mingXiangTimeTick(dt)
		self:updateMingXiangData();
	end
	
	self.mingXiangHandle = scheduler.scheduleGlobal(mingXiangTimeTick, 1);
		
	function onClickMagicTowerLevelUP()
		self:levelUpTower();
	end

	function onClickMagicTowerRongHe()
		self:rongHe();
	end
	
	function onClickMagicTowerMingXiang()
		self:mingXiang();
		eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_MAGICTOWER_FINISH})
	end
	
	function onClickMagicTowerLevelUpNow()
		self:levelUpNow();
	end
	
	function onClickMagicTowerCancelLevelUp()
		self:cancelLevelUp();
	end
	
	function onClickClose()
		self:onHide();
	end
	
	function onClickMagicTowerMagicBook()
		eventManager.dispatchEvent({name = global_event.SKILLBAG_SHOW});
	end
	
	-- 刷新界面
	self:updateUIInfo({buildType = BUILD.BUILD_MAGIC_TOWER});
	

	eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_MAGICTOWER})
end

function skilltower:onHide(event)
	
	if(self.mingXiangHandle ~= nil)then
		scheduler.unscheduleGlobal(self.mingXiangHandle)
		self.mingXiangHandle = nil
	end
	
	self:releaseTimer();
	self:Close();
	
	homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.MAGIC);
end

function skilltower:updateUIInfo(event)

	if not self._show then
		return;
	end
	
	function skillTowerLevelUpTimeTick(dt)
		
		local magicTowerData = dataManager.magicTower;
		if(magicTowerData:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING)then
			return;
		end
 		
		self:updateTime();
		
	end
	
	if dataManager.magicTower:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING then
		self:Child("skilltower-after"):SetVisible(false);
		self:Child("skilltower-sarrow"):SetVisible(false);
	else
		self:Child("skilltower-after"):SetVisible(true);
		self:Child("skilltower-sarrow"):SetVisible(true);	
		self:Child("skilltower-after-num"):SetText(dataManager.magicTower:getLevel()+1);
	end
	
	local wood_level_infor = self:Child("skilltower-levelup-infor");
	if wood_level_infor then
		wood_level_infor:SetVisible(dataManager.magicTower:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING);
	end
	
	local skilltower_title_lv_num = self:Child("skilltower-title-lv-num");
	if skilltower_title_lv_num then
		skilltower_title_lv_num:SetText(dataManager.magicTower:getLevel());
	end
	
	if(event.buildType == BUILD.BUILD_MAGIC_TOWER) then
		
		local magicTowerData = dataManager.magicTower;
		local magicTowerInfo = dataConfig.configs.MagicTowerConfig[magicTowerData:getLevel()];
		-- ui信息
		if magicTowerInfo then
			self.skilltower_dangqian_num:SetText(magicTowerData:getLevel());
			self.skilltower_num:SetText(magicTowerInfo.hammer);
		end
		
		local playerMagicData = dataManager.kingMagic;
		local extraExp = playerMagicData:getExtraExp();
		self.skilltower_suipiannum:SetText(formatMoney(extraExp));
		
		-- 升级状态
		local status = magicTowerData:getLevelUpStatus();
		if status ==  enum_LEVELUP_STATUS.LEVELUP_NORMALE then
			-- 正常状态
			self.skilltower_level:SetVisible(true);
			self.skilltower_level_like:SetVisible(false);
			self.skilltower_quxiao:SetVisible(false);
			
			self.skilltower_shengjizhong_time:SetText("");
			
			self.skilltower_shengjizhong:SetVisible(false);
			
		 	--self.skilltower_container:SetYPosition(LORD.UDim(0, 104));	
		 		 
		else
		
		 	--self.skilltower_container:SetYPosition(LORD.UDim(0, 178));
		 			
			-- 升级状态
			self.skilltower_level:SetVisible(false);
			self.skilltower_level_like:SetVisible(true);
			self.skilltower_quxiao:SetVisible(true);
			self.skilltower_shengjizhong:SetVisible(true);
			
			self:updateTime();
				
			if(self.levelUpHandle == nil)then
				self.levelUpHandle = scheduler.scheduleGlobal(skillTowerLevelUpTimeTick, 1);
			end
				
		end
		
		--self.skilltower_level:SetEnabled(canLevelUp);
		
		-- 更新冥想点数
		self:updateMingXiangData();
	end

end

function skilltower:updateTime()

	local magicTowerData = dataManager.magicTower;
	local level = magicTowerData:getLevel();
	local magicTowerInfo = dataConfig.configs.MagicTowerConfig[level];
			
	local sysTime = dataManager.getServerTime();
 	local t = magicTowerInfo.timeCost - (sysTime - magicTowerData:getLevelUpTime())
	if(t <=0 )then
		t = 0;
		sendAskSyncBuild(BUILD.BUILD_MAGIC_TOWER)
		self:releaseTimer();
	end
	
	self.skilltower_shengjizhong_time:SetText(formatTime(t, true));
	
end

function skilltower:releaseTimer()
	if(self.levelUpHandle ~= nil)then
		scheduler.unscheduleGlobal(self.levelUpHandle)
		self.levelUpHandle = nil
	end
end

function skilltower:levelUpTower()
	--sendUpgradeBuild(0, BUILD.BUILD_MAGIC_TOWER);
	
	if not dataManager.build.isWorkerFree() then
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
			messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
			textInfo = "" });	
		return;
	end

	if dataManager.build[BUILD.BUILD_MAGIC_TOWER]:isMaxLevel() then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "你的法师塔已升至最高等级" });
		return;		
	end
		
	local magicTowerData = dataManager.magicTower;
	--if magicTowerData:isEnoughBaseLevel() then
		eventManager.dispatchEvent({name = global_event.SKILLLEVELUP_SHOW});
	--else
	--end
	
	self:playLevelUpAction(false);
							
	function onSkillTowerLevelupShowEnd()
		
		self.skilltower_caikuang:SetVisible(false);
		self.skilltower_anniu:SetVisible(false);
		self.skilltower_title:SetVisible(false);
		self.skilltower_skill_list_button:SetVisible(false);
		self.skilltower_shengjizhong:SetVisible(false);
		self.skilltower_ronghe:SetVisible(false);
	end
			
	self.skilltower_caikuang:subscribeEvent("UIActionEnd", "onSkillTowerLevelupShowEnd");
			
end

function skilltower:cancelLevelUp()
		
	eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = function() 
		sendUpgradeBuild(1, BUILD.BUILD_MAGIC_TOWER);
	end,text = "正在升级中，是否取消升级？" });
				
end

function skilltower:levelUpNow()
	eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
		messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
		textInfo = "" });	
end

function skilltower:mingXiang()	
	sendGather(BUILD.BUILD_MAGIC_TOWER);
	
	homeland.handleBuildSkill01Effect(enum.HOMELAND_BUILD_TYPE.MAGIC);		
end

function skilltower:rongHe()
	eventManager.dispatchEvent({name = global_event.SKILLFUSE_SHOW});
end

function skilltower:updateMingXiangData()
	
	local magicTowerData = dataManager.magicTower;
	-- 上次冥想时的点数
	local nowPoint = magicTowerData:getNowMedicatePoint();
		
	local totalPoint = magicTowerData:getTotalMedicatePoint();
	
	local percent = nowPoint / totalPoint;
	
	local times = magicTowerData:getNowMedicateTimes();
	
	self.skilltower_cooling_bar_num:SetText(times);
	
	if percent < 0 then
		percent = 0;
	end
	
	self.skilltower_skillnum_full:SetVisible(percent >= 1);

	--self.skilltower_coolingbar:SetProperty("Progress",  percent);
	
	local magicTowerData = dataManager.magicTower;
	local waitTime = magicTowerData:getWaitMedicateTime();
	
	-- 冥想点数大于零就可以冥想
	if waitTime < 0 then
		self.skilltower_mingxiang:SetEnabled(true);
		self.skilltower_cooling_time_text:SetVisible(false);
	else
		self.skilltower_mingxiang:SetEnabled(false);
		self.skilltower_cooling_time_text:SetVisible(true);
		self.skilltower_cooling_time:SetText(formatTime(waitTime, true));	
	end
	
end

function skilltower:playLevelUpAction(showflag)
		-- left ui
		local startPos = LORD.Vector3(0, 0, 0);
		local endPos = LORD.Vector3(-500, 0, 0);
		local time = 300;
		
		if showflag == true then
			startPos, endPos = endPos, startPos;
		end
		
		local action = LORD.GUIAction:new();
		action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
		self.skilltower_caikuang:playAction(action);

				
		--action = LORD.GUIAction:new();
		--action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		--action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
		--self.skilltower_ronghe:playAction(action);

		action = LORD.GUIAction:new();
		action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
		self.skilltower_shengjizhong:playAction(action);
				
		-- title				
		action = LORD.GUIAction:new();
		action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
		self.skilltower_title:playAction(action);

		-- right ui
		startPos = LORD.Vector3(0, 0, 0);
		endPos = LORD.Vector3(500, 0, 0);
		time = 300;

		if showflag == true then
			startPos, endPos = endPos, startPos;
		end
				
		action = LORD.GUIAction:new();
		action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
		self.skilltower_anniu:playAction(action);
		self.skilltower_caikuang:removeEvent("UIActionEnd");
				
end

function skilltower:onCloseLevelup()
	
	if self._show then
	
		self:playLevelUpAction(true);
		self.skilltower_caikuang:SetVisible(true);
		self.skilltower_anniu:SetVisible(true);
		self.skilltower_title:SetVisible(true);
		self.skilltower_skill_list_button:SetVisible(true);	
		self.skilltower_shengjizhong:SetVisible(true);
		self.skilltower_ronghe:SetVisible(true);	
	end
end

return skilltower;
