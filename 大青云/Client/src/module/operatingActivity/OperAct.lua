--[[
运营活动 基类
2015年3月23日11:59:00
haohu
]]

_G.OperAct = {};

OperAct.id      	= nil; -- 运营活动id
OperAct.active      = false; -- 是否激活状态
OperAct.obtainState = false; -- 是否已领取状态
OperAct.usedTime    = 0; -- 已用时
OperAct.rewardNum   = 0; -- 返还数量
OperAct.cfg         = nil; -- 配置信息

OperAct.AllOperAct = {};

function OperAct:new(id)
	local obj = {};
	for k, v in pairs(self) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.id          = id;
	obj.active      = false;
	obj.obtainState = false;
	obj.usedTime    = 0;
	obj.rewardNum   = 0;
	table.push( self.AllOperAct, obj );
	return obj;
end

function OperAct:Update(interval)
	if self:GetLimitTime() == OperActConsts.LimitTime_NoLimit then
		return
	end
	if self.active and not self.reachState then
		self:SetUsedTime( self.usedTime + interval/ONE_SECOND_MSEC );
	end
end

function OperAct:GetId()
	return self.id;
end

----------------------------------------------from cfg------------------------------------

-- 获取配表配置
function OperAct:GetCfg()
	if not self.cfg then
		local cfg = t_yunying[self.id];
		if not cfg then
			Error("cannot find config of YunyingHuodong in t_yunying, ID:"..self.id);
		end
		self.cfg = cfg;
	end
	return self.cfg;
end

-- 组
function OperAct:GetGroup()
	local cfg = self:GetCfg();
	return cfg.group_id;
end

-- 在同一个组内的次序
function OperAct:GetIndex()
	local cfg = self:GetCfg();
	return cfg.order;
end

function OperAct:GetCondition()
	local cfg = self:GetCfg();
	return cfg.type, cfg.value;
end

-- 时限
function OperAct:GetLimitTime()
	local limitTimeType = self:GetLimitTimeType();
	if limitTimeType == OperActConsts.LimitTime_FirstDay then

	elseif limitTimeType == OperActConsts.LimitTime_NoLimit then

	elseif limitTimeType == OperActConsts.LimitTime_Limit then

	end
end

function OperAct:GetLimitTimeSec()
	return 3600 * self:GetLimitTime();
end

-- 活动时间限制类型
function OperAct:GetLimitTimeType()
	local cfg = self:GetCfg();
	if cfg.limit_time == 0 then -- 0 首日
		return OperActConsts.LimitTime_FirstDay;
	elseif cfg.limit_time == -1 then -- -1 不限时 
		return OperActConsts.LimitTime_NoLimit;
	else -- 限制固定时间
		return OperActConsts.LimitTime_Limit;
	end
end

-- 获取返还类型
function OperAct:GetRewardNumType()
	local cfg = self:GetCfg();
	 -- reward_num 为0的需服务器发。其他的读配表常数
	if cfg.reward_num == 0 then
		return OperActConsts.NumRewardType_Variable;
	else
		return OperActConsts.NumRewardType_Constant;
	end
end


----------------------------------------------from server------------------------------------


-- 是否激活状态
function OperAct:GetActive()
	return self.active;
end

-- 设置激活状态
function OperAct:SetActive(active)
	self.active = active;
	self:sendNotification( NotifyConsts.OperActActiveState, self.id );
end

-- 是否已领取
function OperAct:GetObtainState()
	return self.obtainState;
end

-- 设置领取状态
function OperAct:SetObtainState(obtain)
	if self.obtainState ~= obtain then
		self.obtainState = obtain;
		self:sendNotification( NotifyConsts.OperActObtainState, self.id );
	end
end

-- 已用时间 秒
function OperAct:GetUsedTime()
	return self.usedTime;
end

function OperAct:SetUsedTime(usedTime)
	local limitTimeType = self:GetLimitTimeType();
	local time;
	if limitTimeType == OperActConsts.LimitTime_Limit then
		time = usedTime;
	elseif limitTimeType == OperActConsts.LimitTime_FirstDay then
		time = (GetCurTime() % ONE_DAY_MSEC) / ONE_SECOND_MSEC;
	end
	if time ~= self.usedTime then
		self.usedTime = time;
		self:sendNotification( NotifyConsts.OperActTime, self.id );
	end
end

function OperAct:GetRewardNum()
	local cfg = self:GetCfg();
	if cfg.reward_num == 0 then
		return self.rewardNum;
	end
	return cfg.reward_num;
end

function OperAct:SetRewardNum( num )
	if self:GetRewardNumType() == OperActConsts.NumRewardType_Variable then
		if self.rewardNum ~= num then
			self.rewardNum = num;
			self:sendNotification( NotifyConsts.OperActRewardNum, self.id );
		end
	end
end

---------------------------------------------- subclass override-----------------------------

-- 是否已达成
function OperAct:GetReachState()
	-- override in subclasses
end

----------------------------------------------------------------------------------------------
function OperAct:sendNotification(name, body)
	Notifier:sendNotification(name, body);
end

-- 剩余时间
function OperAct:GetRestTime()
	local limitTimeType = self:GetLimitTimeType();
	local restTime;
	if limitTimeType == OperActConsts.LimitTime_FirstDay then
		restTime = ONE_DAY_MSEC / ONE_SECOND_MSEC - self.usedTime;
	elseif limitTimeType == OperActConsts.LimitTime_Limit then
		restTime = self:GetLimitTimeSec() - self:GetUsedTime();
	elseif limitTimeType == OperActConsts.LimitTime_NoLimit then
		restTime = -1;--不限时
	end
	return math.max( 0, restTime );
end