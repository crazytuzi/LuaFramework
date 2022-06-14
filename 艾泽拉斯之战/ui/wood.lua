local wood = class( "wood", layout );

global_event.WOOD_SHOW = "WOOD_SHOW";
global_event.WOOD_HIDE = "WOOD_HIDE";
global_event.WOOD_GATHER_EFFECT = "WOOD_GATHER_EFFECT";

function wood:ctor( id )
	wood.super.ctor( self, id );
	self:addEvent({ name = global_event.WOOD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.WOOD_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.BUILD_ATTR_SYNC, eventHandler = self.onUpDate});
	self:addEvent({ name = global_event.GOLDMINE_CLOSE_LEVEL_UP, eventHandler = self.onCloseLevelup});
	self:addEvent({ name = global_event.WOOD_GATHER_EFFECT, eventHandler = self.onGatherEffect});
	
	self.levelUpHandle = nil
	self.goldProduceHandle = nil
end

function wood:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	

	
	self.wood_close = self:Child( "wood-close" );
	self.wood_level = self:Child( "wood-level" );
	self.wood_level_like = self:Child( "wood-level-like" );
	self.wood_jiagong = self:Child( "wood-jiagong" );
	self.wood_goumai = self:Child( "wood-goumai" );	
	self.wood_quxiao = self:Child( "wood-quxiao" );	
	
	
	self.wood_num = self:Child( "wood-num" ); -- 锤子数量	
	self.wood_jinbinum = self:Child( "wood-jinbinum" ); -- 金币数量
	
	self.wood_dangqian_num = self:Child( "wood-dangqian-num" ); -- level
	self.wood_shengjizhong = self:Child( "wood-shengjizhong" ); -- 升级状态
	self.wood_after_num = self:Child( "wood-after-num" );
	self.wood_container = self:Child("wood-container");
	
	self.wood_shengjizhong_time = self:Child( "wood-shengjizhong-time" ); -- 时间
	
	self.wood_cooling_time = self:Child( "wood-cooling-time" );  
	
	self.wood_woodget_nume = self:Child( "wood-woodget-num" ); 
	self.wood_cooling = self:Child( "wood-cooling" ); 
 

	self.wood_caikuang = self:Child("wood-caikuang");
	self.wood_anniu = self:Child("wood-anniu");
	self.wood_title = self:Child("wood-title");
	self.wood_effect	= self:Child("wood-effect");
	
	function onClickCloseWood()
		self:onHide();
	end
	self.wood_close:subscribeEvent("ButtonClick", "onClickCloseWood");	
	
		
	function onClickLevelUpWood()
		self:onClickLevelUp() 		
	end				
	self.wood_level:subscribeEvent("ButtonClick", "onClickLevelUpWood");	
	
	function onClickLevlUpWoodNow()
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
			messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
			textInfo = "" });	
	end
	
	self.wood_level_like:subscribeEvent("ButtonClick", "onClickLevlUpWoodNow");	
	
	function onClickCollectionWood()
		self:onClickCollection() 		
	end		
		
	self.wood_jiagong:subscribeEvent("ButtonClick", "onClickCollectionWood");
	
	function onClickBuyWood()
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
	end		
	
	self.wood_goumai:subscribeEvent("ButtonClick", "onClickBuyWood");
	
	function onClickCancelWood()
		self:onClickCancel() 		
	end	
	self.wood_quxiao:subscribeEvent("ButtonClick", "onClickCancelWood");
	
	self:upDate()
	eventManager.dispatchEvent( { name  = global_event.GUIDE_ON_ENTER_WOOD})
end
 
function wood:onClickCancel()
	local woodData = dataManager.lumberMillData
	if(woodData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING)then
	
		eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = function() 
			sendUpgradeBuild(1, BUILD.BUILD_LUMBER_MILL);
		end,text = "正在升级中，是否取消升级？" });
							
	end	
end	

function wood:onClickBuyGold()
	
	
end	

function wood:onClickLevelUp()
	
	if not dataManager.build.isWorkerFree() then
		eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
			messageType = enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE, data = -1, 
			textInfo = "" });	
		return;
	end
	
	if dataManager.build[BUILD.BUILD_LUMBER_MILL]:isMaxLevel() then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
			textInfo = "你的伐木场已升至最高等级" });
		return;		
	end
		
	local woodData = dataManager.lumberMillData
	local gtime = woodData:getGatherTime()
	local spaceTime = (dataManager.getServerTime()  - gtime) 	

	local woodData = dataManager.lumberMillData
	if(woodData:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING)then
		--sendUpgradeBuild(0, BUILD.BUILD_LUMBER_MILL)
		eventManager.dispatchEvent({name = global_event.COUNTRYLEVLE_SHOW, sourceType = "wood"});
		
		self:playLevelUpAction(false);
								
		function onWoodLevelupShowEnd()
			
			self.wood_caikuang:SetVisible(false);
			self.wood_anniu:SetVisible(false);
			self.wood_title:SetVisible(false);
			
		end
				
		self.wood_caikuang:subscribeEvent("UIActionEnd", "onWoodLevelupShowEnd");
					
	end	
end	

function wood:onClickCollection()
	local woodData = dataManager.lumberMillData
	local gtime = woodData:getGatherTime()
	local spaceTime = (dataManager.getServerTime()  - gtime) 
	-- 超过1分钟 同时产量大于0
	if(spaceTime >= 0 and    math.floor(woodData:getReserves() + 1 * spaceTime/global.lumberMillInterval) > 0 )  then	
		sendGather(BUILD.BUILD_LUMBER_MILL)	
		eventManager.dispatchEvent( { name  = global_event.GUIDE_ON_ENTER_WOOD_FINISH})
		
		--homeland.handleBuildSkill01Effect(enum.HOMELAND_BUILD_TYPE.WOOD);
	end		
end	
 

function wood:upDate()
	if self._show == false then
		return;
	end
	local woodData = dataManager.lumberMillData		    
	self.wood_num:SetText(woodData:getConfig().hammer) -- 锤子数量	
	
	local capacity =  global.getMaxLumberRatio()
	
 
	self.wood_dangqian_num:SetText(woodData:getLevel()) -- level
	local wood_title_lv_num = self:Child("wood-title-lv-num");
	if wood_title_lv_num then
		wood_title_lv_num:SetText(woodData:getLevel())
	end
	
	self.wood_shengjizhong:SetText(woodData:getLevelUpStatusDesc())

	if woodData:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING then
		self:Child("wood-after"):SetVisible(false);
		self:Child("wood-levelup-sarrow"):SetVisible(false);
	else
		self:Child("wood-after"):SetVisible(true);
		self:Child("wood-levelup-sarrow"):SetVisible(true);	
		self.wood_after_num:SetText(woodData:getLevel()+1);
	end
		
	self.wood_shengjizhong_time:SetText("")
	self.wood_cooling_time:SetText("")
	self.wood_woodget_nume:SetText(woodData:getConfig().criticalBase)      
	self.wood_cooling:SetVisible(false);
	
	
	
	if(woodData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING)then
		local sysTime = dataManager.getServerTime()		
		local  t  =   woodData:getConfig().timeCost - (sysTime - woodData:getLevelUpTime())
		if(t <=0 )then
			sendAskSyncBuild(BUILD.BUILD_LUMBER_MILL)
		end
		self.wood_shengjizhong_time:SetText(formatTime(t, true))
	end


	
	--[[ 移到建筑lumberMillDataClass里了
	function calcReserves()
		local woodData = dataManager.lumberMillData
		local gtime = woodData:getGatherTime()
		local spaceTime = (dataManager.getServerTime()  - gtime) 
		if(spaceTime < 0)then
			spaceTime = 0
		end
		print("woodData:getReserves()"..(woodData:getReserves()))
	    local capacity =  global.getMaxLumberRatio()
		local data =  math.floor(woodData:getReserves() + 1 * spaceTime/global.lumberMillInterval)
		if(data > capacity)then
			data = capacity 		
		end					
		return data,capacity		
	end		
	--]]
	
	local capacity = 0
	local data = 0
	data,capacity = dataManager.lumberMillData:calcReserves()
	
	local c = ""		
	if(data == 0 )then
		c = "^EC203D";		
	end
	self.wood_jinbinum:SetText( c..data.."".."/"..capacity)  

	 	
	self.wood_jiagong:SetEnabled( data > 0)
	function levelUpTimeTick(dt)
		if(woodData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING)then
			 	local sysTime = dataManager.getServerTime()		
				local  t  =   woodData:getConfig().timeCost - (sysTime - woodData:getLevelUpTime())
				if(t <=0 )then
					sendAskSyncBuild(BUILD.BUILD_LUMBER_MILL)
				end
				self.wood_shengjizhong_time:SetText(formatTime(t, true))
		end
	end		
 

	local wood_level_infor = self:Child("wood-level-infor");
	if wood_level_infor then
		wood_level_infor:SetVisible(woodData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING);
	end
		 	
	if(woodData:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING)then
		 if(self.levelUpHandle == nil)then
			self.levelUpHandle = scheduler.scheduleGlobal(levelUpTimeTick,1)
		 end
		 
		 self.wood_quxiao:SetVisible(true);
		 self.wood_level_like:SetVisible(true);
		 self.wood_level:SetVisible(false);
		 
		 self.wood_shengjizhong:SetVisible(true);
		 --self.wood_container:SetYPosition(LORD.UDim(0, 178)); 
		 		 
	else
		self.wood_quxiao:SetVisible(false);
		self.wood_level_like:SetVisible(false);
		self.wood_level:SetVisible(true);
		
		 self.wood_shengjizhong:SetVisible(false);
		 --self.wood_container:SetYPosition(LORD.UDim(0, 104));		
	end
 
	function woodProduceTimeTick(dt)
 
	    local capacity = 0
		local data = 0
		data,capacity = dataManager.lumberMillData:calcReserves()
		
		local c = ""		
		if(data == 0 )then
			c = "^EC203D";		
		end
		self.wood_jinbinum:SetText( c..data.."".."/"..capacity)  
	 		
		local gtime = woodData:getGatherTime()
		local spaceTime = (dataManager.getServerTime()  - gtime) 	
		
		local round = math.floor(spaceTime/global.lumberMillInterval)
		spaceTime = global.lumberMillInterval - (spaceTime - round * global.lumberMillInterval)
						
		self.__passTime = spaceTime - spaceTime/global.lumberMillInterval
		if(spaceTime <= 0 )then
			spaceTime = 0
		end			
 
		self.wood_cooling_time:SetText(formatTime(spaceTime, true))
		
		
		if(data >= capacity)then	
			self.wood_cooling:SetVisible(false);	
			self.wood_cooling_time:SetVisible(false);	
		else
			self.wood_cooling:SetVisible(true);	
			self.wood_cooling_time:SetVisible(true);
			
		end	
		
			
		self.wood_jiagong:SetEnabled( data > 0)
	end	
	
	if(self.woodProduceHandle == nil)then
		self.woodProduceHandle = scheduler.scheduleGlobal(woodProduceTimeTick,1)
	end
	
	
	
	
end	

function wood:onUpDate(event)
	
	if(event.buildType == BUILD.BUILD_LUMBER_MILL)then
		self:upDate()
		
	end
 
end
function wood:onHide(event)
	if(self.levelUpHandle ~= nil)then
		scheduler.unscheduleGlobal(self.levelUpHandle)
		self.levelUpHandle = nil
	end
	if(self.woodProduceHandle ~= nil)then
		scheduler.unscheduleGlobal(self.woodProduceHandle)
		self.woodProduceHandle = nil
	end		
	self:Close();
	
	homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.WOOD);
end

--  
function wood:onCloseLevelup()
	
	if self._show then
	
		self:playLevelUpAction(true);
		self.wood_caikuang:SetVisible(true);
		self.wood_anniu:SetVisible(true);
		self.wood_title:SetVisible(true);	
	end
end

function wood:playLevelUpAction(showflag)
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
		self.wood_caikuang:playAction(action);
		
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
		self.wood_title:playAction(action);

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
		self.wood_anniu:playAction(action);
		self.wood_caikuang:removeEvent("UIActionEnd");
				
end

function wood:onGatherEffect(event)
	if self._show then
		
		event.rate  = event.rate * 100;
		
		if event.rate == dataConfig.configs.ConfigConfig[0].woodToLumber_output[1] then
			self.wood_effect:SetEffectName("jiagong0.effect");
		elseif event.rate == dataConfig.configs.ConfigConfig[0].woodToLumber_output[2]  then
			self.wood_effect:SetEffectName("jiagong1.effect");
		elseif event.rate == dataConfig.configs.ConfigConfig[0].woodToLumber_output[3]  then
			self.wood_effect:SetEffectName("jiagong2.effect");
		elseif event.rate == dataConfig.configs.ConfigConfig[0].woodToLumber_output[4]  then
			self.wood_effect:SetEffectName("jiagong3.effect");
		elseif event.rate == dataConfig.configs.ConfigConfig[0].woodToLumber_output[5]  then
			self.wood_effect:SetEffectName("jiagong4.effect");
		end
		
	end
end

return wood;
