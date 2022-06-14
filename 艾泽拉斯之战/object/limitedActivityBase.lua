limitedActivityBase = class("limitedActivityBase");

function limitedActivityBase:ctor()
	
	self.config = nil;
	
end

function limitedActivityBase:destroy()

end

function limitedActivityBase:shouldShow()
	return true;
end

function limitedActivityBase:setConfigInfo(config)
	self.config = config;
end

function limitedActivityBase:getID()
	return self.config.id;
end

function limitedActivityBase:getName()
	return global.parseDayText(self.config.description);
end

function limitedActivityBase:getDrawOrder()
	return self.config.drawOrder;
end

function limitedActivityBase:isTimeArrived()
	
	local createRoleTime = dataManager.playerData:getCreateRoleTime();
	local serverBeginTime = dataManager.getServerBeginTime();
	local serverTime = dataManager.getServerTime();
	
	local configBeginTime = self.config.beginTime;
	local configEndTime = self.config.endTime;
	
	local beginTime = 0;
	local endTime = 0;
		
	-- 计算角色创建那天时间的0点时间
	--local timeTable = os.date("*t", createRoleTime);
	--local hour = timeTable.hour;
	--local minute = timeTable.min;
	--local second = timeTable.sec;
	
	--print("id "..self.config.id.."  hour "..hour.." minute "..minute.." second "..second);
	
	--local createRoleZeroClock = createRoleTime - hour*60*60 - minute*60 - second;
	
	-- 前一段是计算出零时区0点的秒数，然后做时区的偏移
	local createRoleZeroClock = 24 * 60 * 60 * math.floor((createRoleTime-dataManager.timezone*3600) / (24 * 60 * 60)) + dataManager.timezone*3600;
	
	print("createRoleTime  "..createRoleTime.." createRoleZeroClock "..createRoleZeroClock);
	
	if self.config then
		
		if self.config.limitActivityTime == enum.LIMIT_ACTIVITY_TIME.LIMIT_ACTIVITY_TIME_SERVER then
			
			beginTime = serverBeginTime + (configBeginTime[1]-1) * 24 * 60 * 60 + configBeginTime[2] * 60 * 60 + configBeginTime[3] * 60;
			endTime = serverBeginTime + (configEndTime[1]-1) * 24 * 60 * 60 + configEndTime[2] * 60 * 60 + configEndTime[3] * 60;
			
		elseif self.config.limitActivityTime == enum.LIMIT_ACTIVITY_TIME.LIMIT_ACTIVITY_TIME_USER then
			
			beginTime = createRoleZeroClock + (configBeginTime[1]-1) * 24 * 60 * 60 + configBeginTime[2] * 60 * 60 + configBeginTime[3] * 60;
			endTime = createRoleZeroClock + (configEndTime[1]-1) * 24 * 60 * 60 + configEndTime[2] * 60 * 60 + configEndTime[3] * 60;
			
		elseif self.config.limitActivityTime == enum.LIMIT_ACTIVITY_TIME.LIMIT_ACTIVITY_TIME_NOW then
		
			beginTime = os.time({year = configBeginTime[1], month = configBeginTime[2], day = configBeginTime[3], hour = configBeginTime[4], min = configBeginTime[5], sec = configBeginTime[6]});
			endTime = os.time({year = configBeginTime[1], month = configBeginTime[2], day = configBeginTime[3], hour = configBeginTime[4], min = configBeginTime[5], sec = configBeginTime[6]});
			
		end
		
		return serverTime >= beginTime and serverTime <= endTime, serverTime < beginTime, serverTime > endTime;
	else
		return false;
	end
	
end

function limitedActivityBase:isTaskComplete()
	-- 基类无条件领取
	return true;
end

-- 是否已经领取奖励
function limitedActivityBase:isRewardHasGained()
	
	--print("isRewardHasGained id "..self.config.id.."  status "..dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_LIMIT_ACTIVITY, self.config.id));
	return dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_LIMIT_ACTIVITY, self.config.id) > 0;
	
end

-- 是否可以领取
function limitedActivityBase:isCanGained()
	return (not self:isRewardHasGained()) and self:isTaskComplete() and self:isTimeArrived();
end

-- 是否显示前往按钮
function limitedActivityBase:isShowGotoButton()
	return (not self:isRewardHasGained()) and self:isTimeArrived() and (not self:isTaskComplete());
end

-- 是否是发放类
function limitedActivityBase:isGainedByMail()
	return false;
end

-- 获得前往上的文本
function limitedActivityBase:getGotoButtonText()
	return "前  往";
end

-- 获取任务进度相关的文本信息
function limitedActivityBase:getProgressText()
	return "";
end


-- 得到任务相关状态的文本显示信息
function limitedActivityBase:getStateText()
	local isArrived, notOpen, expire = self:isTimeArrived();
	
	--print("id "..self.config.id);
	--print("isArrived "..tostring(isArrived));
	--print("notOpen "..tostring(notOpen));
	--print("expire "..tostring(expire));
	
	local tips = "";
	local tipImage = "";
	if self:isRewardHasGained() then
		
		if self:isGainedByMail() then
			tips = "已发放"
			tipImage = "set:chargeactivity.xml image:provide-already"		
		else
			tips = "已领取"
			tipImage = "set:chargeactivity.xml image:get-already"
		end
	else
		
		if expire then
			tips = "已过期"
			tipImage = "set:chargeactivity.xml image:overdue"
		else
			
			if not isArrived then
				tips = "未开启";
				tipImage = "set:chargeactivity.xml image:close"
			else
				
				if self:isCanGained() then
					tips = "可领取";
					tipImage = ""
				else
					tips = "未领取";
					
					if self:isShowGotoButton() then
						tipImage = "";
					else
						tipImage = "set:chargeactivity.xml image:un-receive"
					end
				end
			end
			
		end
		
	end 
	
	return tips,tipImage;
end

-- 获取奖励 -- ui使用
function limitedActivityBase:getRewards()
	
	local rewards = {};
	
	for k,v in pairs(self.config.rewardType) do
		
		local rewardInfo = dataManager.playerData:getRewardInfo(v, self.config.rewardID[k], self.config.rewardCount[k]);
		
		if v ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY and rewardInfo then
			table.insert(rewards, rewardInfo);
		end
		
	end
	
	-- 每一个reward 包含的是
	--[[
	local rewardInfo = {
		['id'] = rewardID,
		['count'] = rewardCount,
		['icon'] = "",
		['star'] = 1,
		['maskicon'] = nil;
		['isDebris'] = false;
		['backImage'] = nil;
		['selectImage'] = nil;
		['qualityImage'] = nil;
		['userdata'] = rewardID;
	};
	--]]
	
	return rewards;
	
end

-- 
function limitedActivityBase:getLimitAmount()
	return self.config.amount;
end

-- 点击前往的处理，默认是空
function limitedActivityBase:onClickGoto()

end
