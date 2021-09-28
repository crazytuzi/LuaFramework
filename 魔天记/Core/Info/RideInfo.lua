require "Core.Info.RideBaseInfo";

RideInfo = class("RideInfo", RideBaseInfo);

function RideInfo:New(data)
	self = {};
	setmetatable(self, {__index = RideInfo});
	ConfigManager.copyTo(data, self)
	self._isActivate = false
	self._isUsed = false
	self:_InitProperty()
	self:Init(data);
	self:InitOtherData()
	
	return self;
end

function RideInfo:SetServerInfo(isUsed, rt)
	self._isUsed =(isUsed == 1)
	self._timeLimit = rt
	if(rt == 0 or rt - GetTimeMillisecond() > 0) then
		self._isActivate = true
	else
		self._isActivate = false 
	end
	
end

function RideInfo:GetIsUse()
	return self._isUsed
end

function RideInfo:SetIsUse(isUse)
	self._isUsed = isUse
end

function RideInfo:GetIsActivate()	 
	return self._isActivate
end

function RideInfo:SetIsActivate(activate)
	self._isActivate = activate
	if(self._isActivate == false) then
		self._isUsed = false
	end
end

function RideInfo:GetTimeLimit()
	if(self._timeLimit == 0) then
		return self._timeLimit
	else
		local time = GetTimeMillisecond()
		return self._timeLimit - time
	end
end

function RideInfo:InitOtherData()
	self.synthetic = {}
	local temp = string.split(self.synthetic_condition, "_")
	self.synthetic.itemId = tonumber(temp[1])
	self.synthetic.itemCount = tonumber(temp[2])
	self._power = CalculatePower(self)
end

-- 获取兑换要求
function RideInfo:GetSynthetic()
	return self.synthetic
end

-- 是否能激活
function RideInfo:GetCanActive()
	if(self._isActivate) then
		return false
	end
	
	local count = BackpackDataManager.GetProductTotalNumBySpid(self.synthetic.itemId)
	if(count >= self.synthetic.itemCount) then
		return true
	else
		return false
	end
end 

function RideInfo:GetPower()
	return self._power
end