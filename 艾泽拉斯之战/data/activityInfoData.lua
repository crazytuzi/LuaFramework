activityInfoData = class("activityInfoData")

activityInfoData.ACTIVITY_TYPE = {};
activityInfoData.ACTIVITY_TYPE.COPY_CHALLENGE = 1;
activityInfoData.ACTIVITY_TYPE.TOP_DAMAGE = 2;
activityInfoData.ACTIVITY_TYPE.SPEED_CHALLENGE = 3;
activityInfoData.ACTIVITY_TYPE.CRUSADE = 4;

function activityInfoData:ctor()
	
end

function activityInfoData:destroy()
	
end

function activityInfoData:init()
	
end

-- 
function activityInfoData:getConfigInfo(activityType)
	
	return dataConfig.configs.activityInfoConfig[activityType];
	
end

function activityInfoData:getActivityLevelLimit(activityType)
	
	-- different info
	if activityInfoData.ACTIVITY_TYPE.COPY_CHALLENGE == activityType then
		
		return dataConfig.configs.challengeStageConfig[1].levelLimit;
		
	elseif activityInfoData.ACTIVITY_TYPE.TOP_DAMAGE == activityType then
		
		return dataConfig.configs.ConfigConfig[0].challengeDamageLevelLimit;
		
	elseif activityInfoData.ACTIVITY_TYPE.SPEED_CHALLENGE == activityType then
		
		return dataConfig.configs.ConfigConfig[0].challengeSpeedLevelLimit;
		
	elseif activityInfoData.ACTIVITY_TYPE.CRUSADE == activityType then
		
		return dataConfig.configs.ConfigConfig[0].crusadeLevelLimit;
		
	end
			
end

-- 获取开放时间的显示字符串
function activityInfoData:getActivityOpenTimeText(activityType)
	
	local startTime = dataConfig.configs.ConfigConfig[0].playerRefleshTime;
	
	if activityInfoData.ACTIVITY_TYPE.COPY_CHALLENGE == activityType then
		
		return "全天开放";
		
	elseif activityInfoData.ACTIVITY_TYPE.TOP_DAMAGE == activityType then
		
		return "每日"..startTime.."-"..dataConfig.configs.ConfigConfig[0].challengeDamageCloseTime.."开放";
		
	elseif activityInfoData.ACTIVITY_TYPE.SPEED_CHALLENGE == activityType then
		
		return "每日"..startTime.."-"..dataConfig.configs.ConfigConfig[0].challengeSpeedCloseTime.."开放";
		
	elseif activityInfoData.ACTIVITY_TYPE.CRUSADE == activityType then
		
		if dataManager.getServerOpenDay()+1 < dataConfig.configs.ConfigConfig[0].crusadeDayLimit then
			return "开服第"..dataConfig.configs.ConfigConfig[0].crusadeDayLimit.."天开放";
		else
			return "每日"..dataConfig.configs.ConfigConfig[0].playerRefleshTime.."-次日"..dataConfig.configs.ConfigConfig[0].crusadeCloseTime.."开放";
		end
		
	end
	
end

-- 
function activityInfoData:isActivityOpen(activityType)
	
	local startTime = dataConfig.configs.ConfigConfig[0].playerRefleshTime;
	
	if activityInfoData.ACTIVITY_TYPE.COPY_CHALLENGE == activityType then
		
		return true;
		
	elseif activityInfoData.ACTIVITY_TYPE.TOP_DAMAGE == activityType then
		
		return global.isInTimeLimit(startTime, dataConfig.configs.ConfigConfig[0].challengeDamageCloseTime);
		
	elseif activityInfoData.ACTIVITY_TYPE.SPEED_CHALLENGE == activityType then
		
		return global.isInTimeLimit(startTime, dataConfig.configs.ConfigConfig[0].challengeSpeedCloseTime);
		
	elseif activityInfoData.ACTIVITY_TYPE.CRUSADE == activityType then
		
		return global.isInTimeLimit(dataConfig.configs.ConfigConfig[0].playerRefleshTime, dataConfig.configs.ConfigConfig[0].crusadeCloseTime);
		
	end
	
end

-- 等级限制显示字符串
function activityInfoData:getLevelLimitText(activityType)
	
	local levellimit = self:getActivityLevelLimit(activityType);
	
	if dataManager.playerData:getLevel() >= levellimit then
		
		if self:isActivityOpen(activityType) then
			return "";
		else
			return "活动已关闭";
		end
		
	else
		
		return levellimit.."级开放";
		
	end
	
end

-- 开服时间限制
function activityInfoData:isServerOpenDayLimit(activityType)
	
	if activityInfoData.ACTIVITY_TYPE.COPY_CHALLENGE == activityType then
		
		return false;
		
	elseif activityInfoData.ACTIVITY_TYPE.TOP_DAMAGE == activityType then
		
		return false;
		
	elseif activityInfoData.ACTIVITY_TYPE.SPEED_CHALLENGE == activityType then
		
		return false;
		
	elseif activityInfoData.ACTIVITY_TYPE.CRUSADE == activityType then
		
		return dataManager.getServerOpenDay()+1 < dataConfig.configs.ConfigConfig[0].crusadeDayLimit, 
						"开服第"..dataConfig.configs.ConfigConfig[0].crusadeDayLimit.."天";
		
	end
		
end


-- 进入活动的处理
function activityInfoData:enterActivityHandle(activityType)
	
	if global.tipBagFull() then
		return;
	end
	
	-- 等级限制
	local levellimit = self:getActivityLevelLimit(activityType);
	if dataManager.playerData:getLevel() < levellimit then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, 
				textInfo = "等级不足，"..self:getConfigInfo(activityType).name..levellimit.."级开放" });
				
				return;
	end
	
	-- 开服天数限制
	local serverOpenDayLimit, dayText = self:isServerOpenDayLimit(activityType);
	if serverOpenDayLimit and dayText then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, 
				textInfo = self:getConfigInfo(activityType).name.."将于"..dayText.."开启" });
				
			return;
	end
	
	-- 开启时间限制
	if not self:isActivityOpen(activityType) then
		
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, 
				textInfo = "目前不在活动时间，请等待活动开启" });
						
		return;
	end
	
	-- 进入活动的处理
	if activityInfoData.ACTIVITY_TYPE.COPY_CHALLENGE == activityType then		
	
		local playerData = dataManager.playerData;
		local times = playerData:getChallegeStageTimesLeft();
	 
		eventManager.dispatchEvent({name = global_event.ACTIVITYCOPY_SHOW});
	
		
	elseif activityInfoData.ACTIVITY_TYPE.TOP_DAMAGE == activityType then
		
		eventManager.dispatchEvent({name = global_event.ACTIVITYDAMAGE_SHOW});
		
	elseif activityInfoData.ACTIVITY_TYPE.SPEED_CHALLENGE == activityType then
		
		eventManager.dispatchEvent({name = global_event.ACTIVITYSPEED_SHOW});
		
	elseif activityInfoData.ACTIVITY_TYPE.CRUSADE == activityType then
		
		eventManager.dispatchEvent({name = global_event.CRUSADE_SHOW});
		
	end
		
end
