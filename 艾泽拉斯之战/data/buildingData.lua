
local attCollectionClass  = include("attCollection")

local buildingData = class("buildingData")
include("GoldMineConfig")
include("lumberMillConfig")


function buildingData:ctor()
	self.att = attCollectionClass.new()
	self:init()
end 	

local BUILD_LEVEL  = "BUILD_LEVEL"
local BUILD_GATHER_TIME  = "BUILD_GATHER_TIME"
local LEVEL_UP_STATUS  = "LEVEL_UP_STATUS"
local LEVEL_UP_TIME  = "LEVEL_UP_TIME"

local BUILD_RESERVES   = "BUILD_RESERVES"


enum_LEVELUP_STATUS =
{
	 LEVELUP_NORMALE = 0,
	 LEVELUP_ING = 1,
}

function buildingData:init()
	self:setLevel(1)	
	self:setGatherTime(GameClient.UINT64("10"))	
	self:setLevelUpTime(GameClient.UINT64("0"))
	self:setReserves(0)
end	

function buildingData:getLevel()
	return self.att:getAttr(BUILD_LEVEL)		
end 	

function buildingData:setLevel(level)
	self.att:setAttr(BUILD_LEVEL,level)			
end

function buildingData:getGatherTime()
	return self.att:getAttr(BUILD_GATHER_TIME)	
end 	

function buildingData:setGatherTime(t)
	if(type(t) == "userdata")then
		self.att:setAttr(BUILD_GATHER_TIME,t:GetUInt())			
	else
		self.att:setAttr(BUILD_GATHER_TIME,t)		
	end	
	
end

function buildingData:getLevelUpStatus()
	return self.att:getAttr(LEVEL_UP_STATUS)		
end 	

function buildingData:setLevelUpStatus(s)
	self.att:setAttr(LEVEL_UP_STATUS,s)			
end


function buildingData:getLevelUpTime()
	return self.att:getAttr(LEVEL_UP_TIME)
end

-- 升级剩余时间
function buildingData:getLevelUpRemainTime()
	local t = self:getConfig().timeCost - (dataManager.getServerTime() - self:getLevelUpTime());
	return t;
end

function buildingData:setLevelUpTime(t)

	if(type(t) == "userdata")then
		self.att:setAttr(LEVEL_UP_TIME,t:GetUInt())			
	else
		self.att:setAttr(LEVEL_UP_TIME,t)		
	end		
	
	if(self:getLevelUpTime()<=0)then	 
		self:setLevelUpStatus(enum_LEVELUP_STATUS.LEVELUP_NORMALE)
	else
	 
		self:setLevelUpStatus(enum_LEVELUP_STATUS.LEVELUP_ING)
	end
end

function buildingData:getReserves()
	return self.att:getAttr(BUILD_RESERVES)		
end 	

function buildingData:setReserves(s)
	self.att:setAttr(BUILD_RESERVES,s)	
	print("setReserves",s)		
end




function buildingData:logic_tick(dt)

		
end	

function buildingData:getLevelUpStatusDesc()
	local s = tonumber(self:getLevelUpStatus())
	local des = ""
	if(s == enum_LEVELUP_STATUS.LEVELUP_ING)then
		return "升级中"	
	elseif(s == enum_LEVELUP_STATUS.LEVELUP_NORMALE)then	
		return ""	
	end
    return des	
end 	

return buildingData