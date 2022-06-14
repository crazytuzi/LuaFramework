local changescene = class( "changescene", layout );

global_event.CHANGESCENE_SHOW = "CHANGESCENE_SHOW";
global_event.CHANGESCENE_HIDE = "CHANGESCENE_HIDE";
global_event.CHANGESCENE_OVER = "CHANGESCENE_OVER";

function changescene:ctor( id )
	changescene.super.ctor( self, id );
	self:addEvent({ name = global_event.CHANGESCENE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CHANGESCENE_HIDE, eventHandler = self.onHide});
	self.tick = false
	
end

function changescene:onShow(event)
	if self._show then
		if event.func then
			event.func(event.params);
		end
		return;
	end
	self:Show();
 
	
	
	------------------------------------------------------
	self.flyTime = 1000
	self.dragon = self:Child("changescene-dragon");
	self.ship = self:Child("changescene-flyship");
	self.dragon:SetVisible(true);
	self.ship:SetVisible(true);
	
	
	--[[
			-- 设置最终位置
	self.dragon:SetXPosition(LORD.UDim(0, 675));
	self.ship:SetXPosition(LORD.UDim(0, 1100));
			
	local dragonaction = LORD.GUIAction:new();
	dragonaction:addKeyFrame(LORD.Vector3(-675, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	dragonaction:addKeyFrame(LORD.Vector3(-675*0.2, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, self.flyTime);
	self.dragon:playAction(dragonaction);
			
	local shipaction = LORD.GUIAction:new();
	shipaction:addKeyFrame(LORD.Vector3(-900, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	shipaction:addKeyFrame(LORD.Vector3(-900*0.2, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, self.flyTime);
	self.ship:playAction(shipaction);		
	]]--
	
	
	self.changescene_tips = self:Child("changescene-tips");
	
	-- init tips
	local tipsPool = {};
	local playerLevel = dataManager.playerData:getLevel();
	for k,v in ipairs(dataConfig.configs.tipsConfig) do
		if playerLevel >= v.minLevel and playerLevel <= v.maxLevel then
			table.insert(tipsPool, v);
		end
	end
	
	if #tipsPool > 0 then
		local rand = math.random(1, #tipsPool);
		self.changescene_tips:SetText(tipsPool[rand].text);
	else
		self.changescene_tips:SetText("");
	end
	
	--[[
	self._view:removeEvent("UIActionEnd");
	self._view:subscribeEvent("UIActionEnd", "onChangeSceneEnterUIActionEnd");
	]]--
	
		function onChangeSceneEnterUIActionEnd()
			self.flyTime = 2000
			function delayChangeSceneEnterHandler()
				self.dragon:SetVisible(true);
				self.ship:SetVisible(true);
		
				-- 设置最终位置
				self.dragon:SetXPosition(LORD.UDim(0, 675));
				self.ship:SetXPosition(LORD.UDim(0, 1100));
				
				local dragonaction = LORD.GUIAction:new();
				dragonaction:addKeyFrame(LORD.Vector3(-675*0.2, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
				dragonaction:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, self.flyTime);
				self.dragon:playAction(dragonaction);
				
				local shipaction = LORD.GUIAction:new();
				shipaction:addKeyFrame(LORD.Vector3(-900*0.2, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
				shipaction:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, self.flyTime);
				self.ship:playAction(shipaction);	
			end
		
		-- 当前是在framemove里，不能做删除场景的操作
		scheduler.performWithDelayGlobal(delayChangeSceneEnterHandler, 0);
	end
	
	self.tickNum = 0
			
	-- 延迟一帧处理，否则ui不显示出来
	scheduler.performWithDelayGlobal(function()
		
		if event.func then
			event.func(event.params);
		end
			
		function changescene_tick(dt)
			self.tickNum = self.tickNum + 1
			if(self.tickNum <=1)then
				return 
			end
	
			if(LORD.Root:Instance():getThreadThread():HasTask() == false)then
				eventManager.dispatchEvent({name = global_event.CHANGESCENE_OVER });
				self:onHide()
			end
		end	
		
		if(self.tick)then
			scheduler.unscheduleGlobal(self.tick)
			self.tick = nil
		end
		self.tick = scheduler.scheduleUpdateGlobal(changescene_tick)
	end, 0);
	-------------------------------------------------------------	

end

function changescene:onHide(event)
	
	if(self.tick)then
		scheduler.unscheduleGlobal(self.tick)
		self.tick = nil
	end	
	
	if not self._show then
		return;
	end
	
	self:Close();
		  		
end

return changescene;
