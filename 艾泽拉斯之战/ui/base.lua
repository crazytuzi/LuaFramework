local base = class( "base", layout );

global_event.BASE_SHOW = "BASE_SHOW";
global_event.BASE_HIDE = "BASE_HIDE";

function base:ctor( id )
	base.super.ctor( self, id );
	self:addEvent({ name = global_event.BASE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BASE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.BUILD_ATTR_SYNC, eventHandler = self.updateUIInfo});
	self:addEvent({ name = global_event.GOLDMINE_CLOSE_LEVEL_UP, eventHandler = self.onCloseLevelup});
	
end

function base:onShow(event)
	if self._show then
		return;
	end
	
	--sendIncident(-1);
	
	self:Show();

	self.base_close = self:Child( "base-close" );
	self.base_name = self:Child( "base-name" );
	self.base_dangqian_num = self:Child( "base-dangqian-num" );
	self.base_shengjizhong_time = self:Child( "base-shengjizhong-time" );
	self.base_quxiao = self:Child( "base-quxiao" );
	--self.base_bingliang_num = self:Child( "base-bingliang-num" );
	--self.base_bingliang_anniu = self:Child( "base-bingliang-anniu" );
	self.base_level = self:Child( "base-level" );
	self.base_level_like = self:Child( "base-level-like" );
	self.base_levle_dis = self:Child( "base-levle-dis" );
	self.base_shengjizhong = self:Child( "base-shengjizhong" );
	self.base_lingdimap = {
		[1] = self:Child("base-lingdimap1");
	};
	
	self.base_infor_level_num = self:Child("base-infor-level-num");
	
	self.base_num = self:Child("base-num");
	
	self.base_close:subscribeEvent("ButtonClick", "onClickClose");
	self.base_level:subscribeEvent("ButtonClick", "onClickbase_level");
	self.base_level_like:subscribeEvent("ButtonClick", "onClickBaseIMLevelUp");
	self.base_quxiao:subscribeEvent("ButtonClick", "onClickbase_quxiao");
	self.base_playprogram = self:Child("base-playprogram");
	
	self.base_infor = self:Child("base-infor");
	
	self.base_lv_sarrow = self:Child("base-lv-sarrow");
	self.base_dangqian_0 = self:Child("base-dangqian_0");
	self.base_dangqian_num_1 = self:Child("base-dangqian-num_1");
	
	self.base_corps = self:Child("base-corps");
	
	-- cai 新需求
	self.base_instance_normal_num = self:Child("base-instance-normal-num");
	self.base_instance_hard_num = self:Child("base-instance-hard-num");
	self.base_instance_hard = self:Child("base-instance-hard");
	self.base_activity1_num = self:Child("base-activity1-num");
	self.base_activity2_num = self:Child("base-activity2-num");
	
	self.base_pvp1_num = self:Child("base-pvp1-num");
	self.base_pvp2_num = self:Child("base-pvp2-num");
	self.base_pvp3_num = self:Child("base-pvp3-num");
	
	self.base_corps_container = {};
	self.base_corps_head = {};
	self.base_corps_star = {};
	self.base_corps_equity = {};
	
	for i=1, 6 do
		self.base_corps_container[i] = LORD.toStaticImage(self:Child("base-corps"..i.."-container"));
		self.base_corps_head[i] = LORD.toStaticImage(self:Child("base-corps"..i.."-head"));
		self.base_corps_star[i] = {};
		
		for j=1, 5 do
			self.base_corps_star[i][j] = self:Child("base-corps"..i.."-star"..j);
		end
		
		self.base_corps_equity[i] = LORD.toStaticImage(self:Child("base-corps"..i.."-equity"));
	end
	
	self:updatePlayerInfo();
	
	function onClickClose(args)
		homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.BASE);
		self:onHide();
	end
	
	function onClickbase_level(args)
		self:onClickUpgrade(args);
	end
	
	function onClickBaseIMLevelUp()
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
			messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
			textInfo = "" });	
	end
	
	function onClickbase_quxiao(args)
		self:onClickCancelUpgrade(args);
	end
	
	--[[
	function incidentTimerFunction()
		self:onUpdateIncidentTimer();
	end
	--]]
	
	self.levelUpHandle = nil;
	self.incidentTimerHandle = nil;
	
	--self.incidentTimerHandle = scheduler.scheduleGlobal(incidentTimerFunction,1);
	
	-- init logic data
	self.playerData = dataManager.playerData;
	self.mainBaseData = dataManager.build[BUILD.BUILD_MAIN_BASE];
	
	self:updateUIInfo({buildType = BUILD.BUILD_MAIN_BASE});
	
end

function base:onHide(event)
	
	if self.incidentTimerHandle then
		scheduler.unscheduleGlobal(self.incidentTimerHandle)
		self.incidentTimerHandle = nil;
	end
	
	self:releaseTimer();
	self:Close();

end

function base:releaseTimer()
	if(self.levelUpHandle ~= nil)then
		scheduler.unscheduleGlobal(self.levelUpHandle)
		self.levelUpHandle = nil
	end
end

-- 点击领地事件
function base:onClickBaseLingDi(index)
	
	if global.tipBagFull() then
		return;
	end
		
	--sendIncident(index-1);

end

-- 更新领地事件
function base:onUpdateIncidentTimer()
	--self.lingdiTimeText = {};
	--self.linddiButton = {};
	local baseData = dataManager.mainBase;
	local incidentCount = baseData:getLingDiMaxCount();
	for i=1, incidentCount do
		if baseData:isLingDiActive(i) then
			local remainTime = baseData:getRemineIncidentTime(i);
			--print("remainTime"..remainTime);
			local incidentIndex = baseData:getPlayerIncidentIndex(i);
			--print("incidentIndex "..incidentIndex);
			if remainTime > 0 and incidentIndex <= 0 then
				-- 倒计时
				self.linddiButton[i]:SetVisible(false);
				self.lingdiTimeText[i]:SetText(formatTime(remainTime));
			else
				self.linddiButton[i]:SetVisible(true);
				self.lingdiTimeText[i]:SetText("");
			end
		end
	end
	
end

function base:updateUIInfo(event)
		
	if not self._show then
		return;
	end
	
	function onClickLingDi(args)
		local window = LORD.toWindowEventArgs(args).window;
		local userdata = window:GetUserData();
		self:onClickBaseLingDi(userdata);
	end
	
	function levelUpTimeTick(dt)
		
		if(self.mainBaseData:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING)then
			return;
		end
 		
		self:updateTime();
		
	end
			
	if(event.buildType == BUILD.BUILD_MAIN_BASE)then
			
			self.base_level_like:SetVisible(false);
			self.base_levle_dis:SetVisible(false);

			local name = self.playerData:getName().."的"..self.playerData:getCastleName();
			local level = self.mainBaseData:getLevel();
			local baseInfo = dataConfig.configs.MainBaseConfig[level];
			local food = self.mainBaseData:getFood();
			self.base_name:SetText(name);
			self.base_dangqian_num:SetText(level);
			self.base_infor_level_num:SetText(level);
			
			self.base_num:SetText(self.mainBaseData:getTotalHammer());
			
			-- todo 检查是否可以升级
			local status = self.mainBaseData:getLevelUpStatus();
			if status == enum_LEVELUP_STATUS.LEVELUP_NORMALE then
				
				self.base_quxiao:SetVisible(false);
				self.base_level:SetVisible(true);
				self.base_level_like:SetVisible(false);
				self.base_levle_dis:SetVisible(false);
				self.base_shengjizhong_time:SetVisible(false);
				self.base_shengjizhong:SetVisible(false);

				self.base_lv_sarrow:SetVisible(false);
				self.base_dangqian_0:SetVisible(false);
		 		
		 		local base_levelup_infor = self:Child("base-levelup-infor");
		 		if base_levelup_infor then
		 			base_levelup_infor:SetVisible(false);
		 		end
		 		
		 		--self.base_playprogram:SetYPosition(LORD.UDim(0, 104)); 
		 				
			elseif status == enum_LEVELUP_STATUS.LEVELUP_ING then
			
				self.base_quxiao:SetVisible(true);
				self.base_level:SetVisible(false);
				self.base_level_like:SetVisible(true);
				self.base_levle_dis:SetVisible(false);
				self.base_shengjizhong_time:SetVisible(true);
				self.base_shengjizhong:SetVisible(true);
				--self.base_playprogram:SetYPosition(LORD.UDim(0, 178));

		 		local base_levelup_infor = self:Child("base-levelup-infor");
		 		if base_levelup_infor then
		 			base_levelup_infor:SetVisible(true);
		 		end
		 		
				self.base_lv_sarrow:SetVisible(true);
				self.base_dangqian_0:SetVisible(true);
				self.base_dangqian_num_1:SetText(level+1);
								
				self:updateTime();
				
				if(self.levelUpHandle == nil)then
				self.levelUpHandle = scheduler.scheduleGlobal(levelUpTimeTick,1)
				end				

			end	
	end

end

function base:onClickUpgrade(args)
	--sendUpgradeBuild(0, BUILD.BUILD_MAIN_BASE);
	if not dataManager.build.isWorkerFree() then
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
			messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
			textInfo = "" });	
		return;
	end

	if dataManager.build[BUILD.BUILD_MAIN_BASE]:isMaxLevel() then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "你的城堡已升至最高等级" });
		return;		
	end
	
	self:playLevelUpAction(false);
							
	function onBaseShowEnd()
		
		print("onBaseLevelupShowEnd");
		self.base_playprogram:SetVisible(false);
		self.base_shengjizhong:SetVisible(false);
		self.base_corps:SetVisible(false);
		self.base_infor:SetVisible(false);
	end
			
	self.base_playprogram:subscribeEvent("UIActionEnd", "onBaseShowEnd");
				
	eventManager.dispatchEvent({name = global_event.BASELEVELUP_SHOW});
end

function base:updateTime()

	local level = self.mainBaseData:getLevel();
	local baseInfo = dataConfig.configs.MainBaseConfig[level];
			
	local sysTime = dataManager.getServerTime();
 	local t = baseInfo.timeCost - (sysTime - self.mainBaseData:getLevelUpTime())
	if(t <=0 )then
		t = 0;
		sendAskSyncBuild(BUILD.BUILD_MAIN_BASE)
		self:releaseTimer();
	end

	--print("server time "..sysTime);
	--print("self.mainBaseData:getLevelUpTime() "..self.mainBaseData:getLevelUpTime());
	--print(" t "..t);
	
	self.base_shengjizhong_time:SetText(formatTime(t, true));
end

function base:onClickCancelUpgrade(args)
	
	eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = function() 
		sendUpgradeBuild(1, BUILD.BUILD_MAIN_BASE);
	end,text = "正在升级中，是否取消升级？" });
end

function base:onCloseLevelup()
	
	if self._show then
	
		self:playLevelUpAction(true);
		self.base_playprogram:SetVisible(true);
		self.base_shengjizhong:SetVisible(true);
		self.base_corps:SetVisible(true);
		self.base_infor:SetVisible(true);	
	end
end

function base:playLevelUpAction(showflag)

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
		self.base_playprogram:playAction(action);
		
		startPos = LORD.Vector3(0, 0, 0);
		endPos = LORD.Vector3(-500, 0, 0);
		time = 300;

		if showflag == true then
			startPos, endPos = endPos, startPos;
		end
				
		action = LORD.GUIAction:new();
		action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
		self.base_infor:playAction(action);
				
		-- tile
		startPos = LORD.Vector3(0, 0, 0);
		endPos = LORD.Vector3(-500, 0, 0);
		time = 300;

		if showflag == true then
			startPos, endPos = endPos, startPos;
		end
				
		action = LORD.GUIAction:new();
		action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
		self.base_shengjizhong:playAction(action);

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
		
		self.base_corps:playAction(action);
		self.base_playprogram:removeEvent("UIActionEnd");
				
end

function base:updatePlayerInfo()
	
	local normal = dataManager.playerData:getCurrentNormalStage();
	local elite = dataManager.playerData:getCurrentEliteStage();
	
	local a1, b1 = dataManager.playerData:getAdventureAandB(normal);
	local a2, b2 = dataManager.playerData:getAdventureAandB(elite);
		
	self.base_instance_normal_num:SetText(a1.."-"..b1);
	self.base_instance_hard_num:SetText(a2.."-"..b2);
	
	self.base_instance_hard:SetVisible(elite > 1);
	
	-- 伤害排行榜
	if dataManager.hurtRankData:isLevelEnough() then
		local num = dataManager.hurtRankData:getBattleNum();
		if dataManager.hurtRankData:isOpenTime()  then  --  dataManager.hurtRankData:isOpenTime()
			local sa ,sb = dataManager.hurtRankData:getScore();
			if num > 0 then
				self.base_activity1_num:SetText(sb);
			else
				self.base_activity1_num:SetText("未参加");
			end

		else
			self.base_activity1_num:SetText("活动未开启");
		end
		
	else
		self.base_activity1_num:SetText("活动未开启");
	end
	
	-- 极速挑战
	if dataManager.playerData:isSpeedChallegeCanStart() then
		
		if dataManager.playerData:getSpeedChanllegeTimes() > 0 then
			self.base_activity2_num:SetText(dataManager.playerData:getSpeedChallegeRound());
		else
			self.base_activity2_num:SetText("未参加");
		end
		
	else
		self.base_activity2_num:SetText("活动未开启");
	end
	
	-- 竞技场数据
	local OfflineOpenLevel = dataManager.pvpData:getOfflineOpenLevel()
	if(OfflineOpenLevel > dataManager.playerData:getLevel())then
		self.base_pvp1_num:SetText("竞技场未开放");
		self.base_pvp2_num:SetText("竞技场未开放");			
		self.base_pvp3_num:SetText("竞技场未开放");	
	else
		local r = dataManager.pvpData:getOfflineRanking();
		self.base_pvp1_num:SetText(r);
		self.base_pvp3_num:SetText("竞技场未开放");	
		self.base_pvp2_num:SetText(dataManager.pvpData:getOfflinePlayerMaxRank());	
	end
	
	local list = cardData.getMaxStartedCard();
	
	for i=1, 6 do
		if list[i] then
			self.base_corps_container[i]:SetVisible(true);
			
			local cardInstance = cardData.getCardInstance(list[i].cardType);
			self.base_corps_head[i]:SetImage(cardInstance:getConfig().icon);
			
			for j=1, 5 do
				self.base_corps_star[i][j]:SetVisible(j <= list[i].star);
			end
			
			self.base_corps_equity[i]:SetImage(itemManager.getImageWithStar(list[i].star));
			
		else
			self.base_corps_container[i]:SetVisible(false);
		end
	end
	
end

return base;
 