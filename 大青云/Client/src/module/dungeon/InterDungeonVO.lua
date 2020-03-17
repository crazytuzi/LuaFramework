--[[
跨服副本
]]

_G.InterDungeonVO = {}

InterDungeonVO.Id			  = nil
InterDungeonVO.cfg            = nil
InterDungeonVO.usedTimes      = 0
InterDungeonVO.usedPayTimes   = 0
InterDungeonVO.curDiff        = 0

function InterDungeonVO:new()
	local obj = setmetatable( {}, { __index = self } )
	obj:Init()
	return obj
end

function InterDungeonVO:GetId()
	return self.Id
end

function InterDungeonVO:SetId( value )
	FPrint('valuevaluevaluevalue'..value)
	self.Id = value
end

function InterDungeonVO:Init()
	self.usedTimes    = 0
	self.usedPayTimes = 0
end

function InterDungeonVO:GetCfg()
	if not self.cfg then
		self.cfg = t_worlddungeons[self.Id]
	end
	return self.cfg
end

function InterDungeonVO:GetUsedTimes()
	return self.usedTimes
end

function InterDungeonVO:SetUsedTimes( value )
	self.usedTimes = value
end

function InterDungeonVO:GetUsedPayTimes()
	return self.usedPayTimes
end

function InterDungeonVO:SetUsedPayTimes( value )
	self.usedPayTimes = value
end

function InterDungeonVO:GetRestFreeTimes()
	local cfg = self:GetCfg()
	local free_times = cfg.free_times
	return math.max( free_times - self.usedTimes, 0 ), free_times
end

function InterDungeonVO:GetRestPayTimes()
	local cfg = self:GetCfg()
	local pay_times = cfg.pay_times
	return 0--pay_times - self.usedPayTimes, pay_times
end

function InterDungeonVO:HasRestTimes()
	local restFreeTimes = self:GetRestFreeTimes()
	local restPayTimes = self:GetRestPayTimes()
	return restFreeTimes + restPayTimes > 0
end

-- 剩余次数描述
function InterDungeonVO:GetRestTimeDes()
	local restFreeTimes, cfgFreeTimes = self:GetRestFreeTimes()
	local restPayTimes, cfgPayTimes = self:GetRestPayTimes()
	if restFreeTimes > 0 then
		return string.format( StrConfig['dungeon215'], "#236017", restFreeTimes, cfgFreeTimes );
	elseif restPayTimes > 0 then
		return string.format( StrConfig['dungeon216'], "#236017", restPayTimes, cfgPayTimes );
	else
		return StrConfig['dungeon205'];
	end
end

function InterDungeonVO:IsUnlocked()
	local cfg = self:GetCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	return myLevel >= cfg.unlock_level
end

function InterDungeonVO:IsAvailable()
	local cfg = self:GetCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	return myLevel >= cfg.min_level
end

function InterDungeonVO:GetNameImgURL()
	local cfg = self:GetCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local isGray = myLevel < cfg.min_level
	return ResUtil:GetInterDungeonNameImg( self.Id, isGray )
end

function InterDungeonVO:GetBgURL()
	local cfg = self:GetCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local isGray = myLevel < cfg.min_level
	return ResUtil:GetInterDungeonImg( self.Id, isGray )
end


