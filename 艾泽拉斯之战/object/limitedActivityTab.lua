limitedActivityTab = class("limitedActivityTab");

function limitedActivityTab:ctor()
	
	self.config = nil;
	
	self.childActivity = {};
	
end

function limitedActivityTab:destroy()

end

function limitedActivityTab:shouldShow()

	for k,v in ipairs(self.childActivity) do
		local isArrived, notOpen, expire = v:isTimeArrived();
		
		if isArrived then
			return true;
		end
		
	end
	
	return false;	
end

function limitedActivityTab:hasNotifyPoint()

	for k,v in ipairs(self.childActivity) do
		if v:isCanGained() then
			return true;
		end
	end
	
	return false;
end

function limitedActivityTab:getChildActivity()
	return self.childActivity;
end

function limitedActivityTab:setConfigInfo(config)
	self.config = config;
end

function limitedActivityTab:getDrawOrder()
	
	return self.config.drawOrder;
	
end

function limitedActivityTab:initChildActivity()
	
	for k,v in pairs(self.config.activityID) do
		
		local activityConfig = dataConfig.configs.limitActivityConfig[v];
		
		local activityInstance = nil;
		
		if activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_NOCONDITION then
			
			activityInstance = limitedActivityBase.new();
		
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_INVALID then
			
			activityInstance = limitedActivityNull.new();
			
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_LEVEL then
			
			activityInstance = limitedActivityKingLevel.new();
			
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_GOLDMINE then
			
			activityInstance = limitedActivityGoldLevel.new();
			
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_ALLUNITS then
			
			activityInstance = limitedActivityUnitCount.new();
			
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_CHAPTER then
			
			activityInstance = limitedActivityChapter.new();
			
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_EQUIPENHANCE then
			
			activityInstance = limitedActivityEquipEnhance.new();
			
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_PVP_ONLINE then
			
			activityInstance = limitedActivityPvpOnline.new();
			
		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_PVP_OFFLINE then
			
			activityInstance = limitedActivityPvpOffline.new();

		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_ALL_RECHARGE then
			
			activityInstance = limitedActivityAllRecharge.new();

		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_LIMIT_RECHARGE then

			activityInstance = limitedActivityLimitRecharge.new();

		elseif activityConfig.limitActivityCondition == enum.LIMIT_ACTIVITY_CONDITION.LIMIT_ACTIVITY_CONDITION_COST_DIAMOND then
		
			activityInstance = limitedActivityDiamondCost.new();
	
		end
		
		activityInstance:setConfigInfo(activityConfig);
		
		table.insert(self.childActivity, activityInstance);
		
	end
	
	-- ≈≈–Ú
	-- sort
	function limitedActivityCompare(a, b)
		
		return a:getDrawOrder() < b:getDrawOrder();
	end
	
	table.sort(self.childActivity, limitedActivityCompare);
	
end

function limitedActivityTab:getName()
	return self.config.name;
end

function limitedActivityTab:getDesc()
	--return self.config.description;
	
	return global.parseDayText(self.config.description);
end

function limitedActivityTab:getIcon()
	return self.config.icon;
end

function limitedActivityTab:getActivityByID(id)

	for k,v in ipairs(self.childActivity) do
		if v:getID() == id then
			return v;
		end
	end
	
	return nil;
end
