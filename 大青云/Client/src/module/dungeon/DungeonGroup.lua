--[[
副本组
2015年6月1日15:58:25
haohu
]]

_G.DungeonGroup = {}

DungeonGroup.group          = nil
DungeonGroup.cfg            = nil
DungeonGroup.usedTimes      = 0
DungeonGroup.usedPayTimes   = 0
DungeonGroup.curDiff        = 0
DungeonGroup.difficultyList = {}

function DungeonGroup:new()
	local obj = setmetatable( {}, { __index = self } )
	obj:Init()
	return obj
end

function DungeonGroup:Init()
	self.group        = 0
	self.usedTimes    = 0
	self.usedPayTimes = 0
	self.curDiff      = 0
	self.difficultyList = {}
	for i = 1, #DungeonConsts.AllDiff do
		self:SetMyTimeOfDifficulty( i, 0 )
	end
end

function DungeonGroup:GetGroup()
	return self.group
end

function DungeonGroup:SetGroup( value )
	self.group = value
end

function DungeonGroup:GetGroupCfg()
	if not self.cfg then
--	WriteLog(LogType.Normal,true,'-------------houxudongcfg',self.group)
		self.cfg = DungeonUtils:GetGroupCfgInfo( self.group );
	end
	return self.cfg
end

function DungeonGroup:GetUsedTimes()
	return self.usedTimes
end

function DungeonGroup:SetUsedTimes( value )
	self.usedTimes = value
end

function DungeonGroup:GetUsedPayTimes()
	return self.usedPayTimes
end

function DungeonGroup:SetUsedPayTimes( value )
	self.usedPayTimes = value
end

function DungeonGroup:GetRestFreeTimes()
	local cfg = self:GetGroupCfg()
	if not cfg then return end;
	local free_times = cfg.free_times
	return math.max( free_times - self.usedTimes, 0 ), free_times
end

function DungeonGroup:GetRestPayTimes()
	local cfg = self:GetGroupCfg()
	local pay_times = cfg.pay_times
	return pay_times - self.usedPayTimes, pay_times
end

function DungeonGroup:HasRestTimes()
	local restFreeTimes = self:GetRestFreeTimes()
	local restPayTimes = self:GetRestPayTimes()
	return restFreeTimes + restPayTimes > 0
end

-- 剩余次数描述
function DungeonGroup:GetRestTimeDes()
	local restFreeTimes, cfgFreeTimes = self:GetRestFreeTimes()
	local restPayTimes, cfgPayTimes = self:GetRestPayTimes()
	if restFreeTimes > 0 then
		return string.format( StrConfig['dungeon215'], "#2FE00D", restFreeTimes, cfgFreeTimes );
	-- elseif restPayTimes > 0 then
		-- return string.format( StrConfig['dungeon216'], "#2FE00D", restPayTimes, cfgPayTimes );
	else
		-- return StrConfig['dungeon205'];
		return string.format( StrConfig['dungeon215'], "#780000", 0, cfgFreeTimes or 0 );
	end
end

--解锁等级
function DungeonGroup:IsUnlocked()
	local cfg = self:GetGroupCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	if not cfg then return nil; end;
	return myLevel >= cfg.unlock_level
end

function DungeonGroup:IsAvailable()
	local cfg = self:GetGroupCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	return myLevel >= cfg.min_level
end

function DungeonGroup:GetNameImgURL()
	local cfg = self:GetGroupCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local isGray = myLevel < cfg.min_level
	return ResUtil:GetDungeonNameImg( self.group, isGray )
end

function DungeonGroup:GetBgURL()
	local cfg = self:GetGroupCfg()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local isGray = myLevel < cfg.min_level
	return ResUtil:GetDungeonImg( self.group, isGray )
end

-- 服务器发的当前难度 --取消使用，使用计算 GetCurrentDifficulty
function DungeonGroup:GetCurrentDiff()
	return self.curDiff
end

-- 服务器发的当前难度 --取消使用，使用计算 GetCurrentDifficulty
function DungeonGroup:SetCurrentDiff( value )
	self.curDiff = value
end

-- 计算当前可进入最高难度
function DungeonGroup:GetCurrentCanEnterDifficulty()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local currentPassDiff = self:GetCurrentDifficulty()
	if currentPassDiff < DungeonConsts.Myth then
		local nextDiff = currentPassDiff + 1
		local nextDungeonId = DungeonUtils:GetDungeonId( self.group, nextDiff )
		local nextCfg = t_dungeons[nextDungeonId]
		if nextCfg == nil then
			return 1;
		end
		if myLevel >= nextCfg.min_level then
			return nextDiff
		end
	end
	return currentPassDiff
end

-- 计算当前已通难度
function DungeonGroup:GetCurrentDifficulty()
	local currentPassDiff = 0
	for diff, time in pairs(self.difficultyList) do
		if time > 0 then
			currentPassDiff = math.max( currentPassDiff, diff )
		end
	end
	return currentPassDiff
end

function DungeonGroup:GetDifficultyList()
	return self.difficultyList
end

function DungeonGroup:SetMyTimeOfDifficulty( diff, time )
    --print("困难度和时间:",diff,time)
	self.difficultyList[diff] = time
end

function DungeonGroup:GetMyTimeOfDifficulty( diff )
	return self.difficultyList[diff]
end

-- 显示类型，决定副本显示的UI是哪一个
function DungeonGroup:GetShowType()
	for id, cfg in pairs(t_dungeons) do
		if cfg.group == self.group then
			return cfg.show_type
		end
	end
end