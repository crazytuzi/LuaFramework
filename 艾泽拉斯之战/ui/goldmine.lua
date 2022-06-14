local goldmine = class( "goldmine", layout );

global_event.GOLDMINE_SHOW = "GOLDMINE_SHOW";
global_event.GOLDMINE_HIDE = "GOLDMINE_HIDE";

function goldmine:ctor( id )
	goldmine.super.ctor( self, id );
	self:addEvent({ name = global_event.GOLDMINE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GOLDMINE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.BUILD_ATTR_SYNC, eventHandler = self.onUpDate});
	self:addEvent({ name = global_event.GOLDMINE_CLOSE_LEVEL_UP, eventHandler = self.onCloseLevelup});
 
	self.levelUpHandle = nil
	self.goldProduceHandle = nil
end

function goldmine:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.goldmine_close = self:Child( "goldmine-close" );
	self.goldmine_level = self:Child( "goldmine-level" );
	self.goldmine_level_like = self:Child( "goldmine-level-like" );
	self.goldmine_shouji = self:Child( "goldmine-shouji" );
	self.goldmine_goumai = self:Child( "goldmine-goumai" );	
	self.goldmine_quxiao = self:Child( "goldmine-quxiao" );	
	
	
	self.goldmine_num = self:Child( "goldmine-num" ); -- 锤子数量	
	self.goldmine_jinbinum = self:Child( "goldmine-jinbinum" ); -- 金币数量
	
	self.goldmine_dangqian_num = self:Child( "goldmine-dangqian-num" ); -- level
	self.goldmine_after_num = self:Child("goldmine-after-num");
	self.goldmine_shengjizhong = self:Child( "goldmine-shengjizhong" ); -- 升级状态
	self.goldmine_shengjizhong_time = self:Child( "goldmine-shengjizhong-time" ); -- 时间
	
	self.goldmine_chanliang_num = self:Child( "goldmine-chanliang-num" );

	self.goldmine_container = self:Child("goldmine-container");
	
	self.goldmine_caikuang = self:Child("goldmine-caikuang");
	self.goldmine_anniu = self:Child("goldmine-anniu");
	self.goldmine_title = self:Child("goldmine-title");
	
	
	function onClickQuitGoldmine()
		self:onHide();		
	end
	
	self.goldmine_close:subscribeEvent("ButtonClick", "onClickQuitGoldmine");
	
	function onClickLevelUpGold()
		self:onClickLevelUp() 		
	end				
	self.goldmine_level:subscribeEvent("ButtonClick", "onClickLevelUpGold");
	
	function onClickIMLevelUpGold()
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
			messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
			textInfo = "" });			
	end
	
	self.goldmine_level_like:subscribeEvent("ButtonClick", "onClickIMLevelUpGold");
	
	function onClickCollection()
		self:onClickCollection() 		
	end		
	
	
	self.goldmine_shouji:subscribeEvent("ButtonClick", "onClickCollection");
	
	function onClickBuyGold()
		self:onClickBuyGold() 		
	end		
	
	self.goldmine_goumai:subscribeEvent("ButtonClick", "onClickBuyGold");
	
	function onClickCancel()
		self:onClickCancel() 		
	end	
	self.goldmine_quxiao:subscribeEvent("ButtonClick", "onClickCancel");
	
	self:upDate()
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_GOLD })
end

function goldmine:onClickCancel()
	local goldmine = dataManager.goldMineData
	if(goldmine:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING)then
			
		eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = function() 
			sendUpgradeBuild(1, BUILD.BUILD_GOLD_MINE);
		end,text = "正在升级中，是否取消升级？" });
			
	end	
end	

function goldmine:onClickBuyGold()
	
	eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = enum.BUY_RESOURCE_TYPE.GOLD, copyType = -1, copyID = -1, });
end	

function goldmine:onClickCollection()

	local goldmine = dataManager.goldMineData
	local gtime = goldmine:getGatherTime()
	local spaceTime = (dataManager.getServerTime()  - gtime) 
	-- 超过1分钟 同时产量大于0
	
	local num = math.floor(goldmine:getReserves() + goldmine:getOutputPerHour() * spaceTime/3600) 
	
	if(spaceTime >= 1 and num > 0 )  then
 
		sendGather(BUILD.BUILD_GOLD_MINE)	
 		homeland.handleBuildSkill01Effect(enum.HOMELAND_BUILD_TYPE.GOLD);	
	end		
end	

function goldmine:onClickLevelUp()
	
	if not dataManager.build.isWorkerFree() then
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
			messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
			textInfo = "" });	
		return;
	end	

	if dataManager.build[BUILD.BUILD_GOLD_MINE]:isMaxLevel() then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "你的金矿已升至最高等级" });
		return;		
	end
		
	local goldmine = dataManager.goldMineData
	if(goldmine:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING)then
		
		self:playLevelUpAction(false);
								
		function onGoldLevelupShowEnd()
			
			self.goldmine_caikuang:SetVisible(false);
			self.goldmine_anniu:SetVisible(false);
			self.goldmine_title:SetVisible(false);
			
		end
				
		self.goldmine_caikuang:subscribeEvent("UIActionEnd", "onGoldLevelupShowEnd");
			
		
		eventManager.dispatchEvent({name = global_event.COUNTRYLEVLE_SHOW, sourceType = "gold"});
		
		
	end	
end	

function goldmine:upDate()
	if self._show == false then
		return;
	end
	local goldmine = dataManager.goldMineData		    
	self.goldmine_num:SetText(goldmine:getConfig().hammer) -- 锤子数量	
	
	local capacity = goldmine:getConfig().output * global.getMaxGoldRatio()
	
	self.goldmine_dangqian_num:SetText(goldmine:getLevel()) -- level
	
	local goldmine_title_lv_num = self:Child("goldmine-title-lv-num");
	if goldmine_title_lv_num then
		goldmine_title_lv_num:SetText(goldmine:getLevel());
	end
	
	if goldmine:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING then
		self:Child("goldmine-after"):SetVisible(false);
		self:Child("goldmine-levelup-sarrow"):SetVisible(false);
	else
		self:Child("goldmine-after"):SetVisible(true);
		self:Child("goldmine-levelup-sarrow"):SetVisible(true);	
		self.goldmine_after_num:SetText(goldmine:getLevel()+1);
	end
	
	self.goldmine_shengjizhong:SetText(goldmine:getLevelUpStatusDesc())
	
	self.goldmine_shengjizhong_time:SetText("")
	self.goldmine_chanliang_num:SetText(goldmine:getOutputPerHour())

	local capacity = 0
	local data = 0
	data,capacity = dataManager.goldMineData:calcReserves();
	self.goldmine_jinbinum:SetText( data.."/"..capacity)    -- 金币数量 	
	local goldmine = dataManager.goldMineData
	local gtime = goldmine:getGatherTime()
	local spaceTime = (dataManager.getServerTime()  - gtime) 	
	
	--print("gtime"..gtime.."dataManager.getServerTime() "..dataManager.getServerTime() )	
	self.goldmine_shouji:SetEnabled( spaceTime >= 1 and data > 0)	
	
	function levelUpTimeTick(dt)
		if(goldmine:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING)then
			return 
		end
 
		local sysTime = dataManager.getServerTime()		
	 	local  t  =   goldmine:getConfig().timeCost - (sysTime - goldmine:getLevelUpTime())
		if(t <=0 )then
			sendAskSyncBuild(BUILD.BUILD_GOLD_MINE)
		end
		self.goldmine_shengjizhong_time:SetText(formatTime(t, true))
	end		
 
	
	if(goldmine:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING)then
		 if(self.levelUpHandle == nil)then
			self.levelUpHandle = scheduler.scheduleGlobal(levelUpTimeTick,1)
		 end
		 
		 self.goldmine_quxiao:SetVisible(true);
		 self.goldmine_level:SetVisible(false);
		 self.goldmine_level_like:SetVisible(true);
		 
		 self.goldmine_shengjizhong:SetVisible(true);
		 --self.goldmine_container:SetYPosition(LORD.UDim(0, 178));
			local goldmine_levelup_infor = self:Child("goldmine-levelup-infor");
			if goldmine_levelup_infor then
				goldmine_levelup_infor:SetVisible(true);
			end
			
		local sysTime = dataManager.getServerTime()		
	 	local  t  =   goldmine:getConfig().timeCost - (sysTime - goldmine:getLevelUpTime())
		self.goldmine_shengjizhong_time:SetText(formatTime(t, true))
			
	else
		self.goldmine_quxiao:SetVisible(false);
		self.goldmine_level:SetVisible(true);
		self.goldmine_level_like:SetVisible(false);

			local goldmine_levelup_infor = self:Child("goldmine-levelup-infor");
			if goldmine_levelup_infor then
				goldmine_levelup_infor:SetVisible(false);
			end
					
		 self.goldmine_shengjizhong:SetVisible(false);
		 --self.goldmine_container:SetYPosition(LORD.UDim(0, 104));		
	end
 
	function goldProduceTimeTick(dt)
 
	    local capacity = 0
		local data = 0
		data,capacity = dataManager.goldMineData:calcReserves();
		self.goldmine_jinbinum:SetText( data.."/"..capacity)    -- 金币数量 	
				
			local goldmine = dataManager.goldMineData
			local gtime = goldmine:getGatherTime()
			local spaceTime = (dataManager.getServerTime()  - gtime) 
			-- 超过1s 同时产量大于0			
			
			---print("------------!!"..spaceTime)
			self.goldmine_shouji:SetEnabled( spaceTime >= 1 and data > 0)					
	end	
	
	if(self.goldProduceHandle == nil)then
		self.goldProduceHandle = scheduler.scheduleGlobal(goldProduceTimeTick,global.goldMineInterval)--global.goldMineInterval
	end	
	
	 
end	
function goldmine:onUpDate(event)
	
	if(event.buildType == BUILD.BUILD_GOLD_MINE)then
		
		self:upDate()
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_GOLD_FINISH })
	end
 
end
function goldmine:onHide(event)
	if(self.levelUpHandle ~= nil)then
		scheduler.unscheduleGlobal(self.levelUpHandle)
		self.levelUpHandle = nil
	end
	if(self.goldProduceHandle ~= nil)then
		scheduler.unscheduleGlobal(self.goldProduceHandle)
		self.goldProduceHandle = nil
	end
 
	
	self:Close();
	
	homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.GOLD);
end

function goldmine:onCloseLevelup()
	
	if self._show then
	
		self:playLevelUpAction(true);
		self.goldmine_caikuang:SetVisible(true);
		self.goldmine_anniu:SetVisible(true);
		self.goldmine_title:SetVisible(true);	
	end
end

function goldmine:playLevelUpAction(showflag)
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
		self.goldmine_caikuang:playAction(action);
		
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
		self.goldmine_title:playAction(action);

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
		self.goldmine_anniu:playAction(action);
		self.goldmine_caikuang:removeEvent("UIActionEnd");
				
end

return goldmine;
