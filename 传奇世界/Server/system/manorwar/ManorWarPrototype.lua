--ManorWarPrototype.lua

ManorWarPrototype = class()

function ManorWarPrototype:__init(data)
	assert(type(data) == "table", "Invalid ManorWarPrototype data")
	self.data = data
end

function ManorWarPrototype:__release()
	self.data = nil
end

function ManorWarPrototype:tostring()
	return string.format("ManorWarPrototype: {data: %s}", toString(self.data))
end

function ManorWarPrototype:__getValue(name, item, default)
	if not item then
		return default
	end

	local value = self.data[name]
	if value == nil then
		value = default
	end

	return value
end

function ManorWarPrototype:getData()
	return self.data
end

--原型ID
function ManorWarPrototype:getManorID()
	return tonumber(self.data.manorID) or 0
end

--旗帜坐标
function ManorWarPrototype:getBannerPos()
	return self.data.bannerPos
end

--领地名称
function ManorWarPrototype:getName()
	return self.data.name
end

--领地地图ID
function ManorWarPrototype:getMapID()
	return tonumber(self.data.mapID)
end

--等级限制
function ManorWarPrototype:getLevel()
	return tonumber(self.data.level)
end

--胜方奖励
function ManorWarPrototype:getWinDrop()
	return tonumber(self.data.winDrop) or 0
end

--败方奖励
function ManorWarPrototype:getLoseDrop()
	return tonumber(self.data.loseDrop) or 0
end

--拔旗所需财富
function ManorWarPrototype:getBannerMoney()
	return tonumber(self.data.bannerMoney) or 0
end

--夺旗所需持旗时间
function ManorWarPrototype:getWinPeriod()
	return tonumber(self.data.winPeriod) or 0
end

--帮主武器
function ManorWarPrototype:getLeaderWeapon()
	return tonumber(self.data.leaderWeapon) or 0
end

--经验奖励距离中直
function ManorWarPrototype:getStandardRange()
	return tonumber(self.data.standardRange)
end

--开启时间
function ManorWarPrototype:getOpenTime()
	return self.data.openTime
end

--开启前三十分钟提示时间
function ManorWarPrototype:getOpenNotice1()
	return self.data.openNotice1
end

--开启前十分钟提示时间
function ManorWarPrototype:getOpenNotice2()
	return self.data.openNotice2
end

--领取每日奖励
function ManorWarPrototype:getdailyReward()
	return unserialize(self.data.dailyReward)
end

--胜利会长奖励
function ManorWarPrototype:getLeaderReward()
	return tonumber(self.data.leaderReward) or 0
end

--回主城的坐标
function ManorWarPrototype:getDiePos()
	return unserialize(self.data.diePos)
end

--强制开启时间
function ManorWarPrototype:getForceOpen()
	local openTime = tostring(self.data.openTime)
	local data = StrSplit(openTime, ",")
	return tonumber(data[6]) or 0
end

--开服多少天才能开启领地战
function ManorWarPrototype:getOpenDayLimit()
	return tonumber(self.data.openDayLimit) or 0
end

--获取开启的星期日
function ManorWarPrototype:getWeekDay()
	local openTime = tostring(self.data.openTime)
	local data = StrSplit(openTime, ",")
	local weekDayTB = StrSplit(tostring(data[4]), " ")
	local numTb = {}
	for _,day in ipairs(weekDayTB) do
		table.insert(numTb, tonumber(day))
	end 
	return numTb
end

