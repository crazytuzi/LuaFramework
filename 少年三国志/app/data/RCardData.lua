
require("app.cfg.shop_price_info")
require("app.cfg.recharge_card_info")

local FuCommon = require("app.scenes.dafuweng.FuCommon")
local storage = require("app.storage.storage")

local RCardData = class("RCardData")

RCardData.MAX_RESET = 5

function RCardData:ctor()
	self._score = 0
	self._totalScore = 0
	self._timeStart = 0
	self._timeEnd = 0
	self._resetTimes = {0,0}
	self._ids = {{},{}}
	self._firstTime = {true,true}
end

function RCardData:updateInfo(data)
	self._score = data.score
	self._totalScore = data.score_total
	self._timeStart = data.start
	self._timeEnd = data["end"]
	self._resetTimes = {data.reset1,data.reset2}
	if rawget(data,"ids1") then
		for k , v in pairs(data.ids1) do
			self._ids[1][data.pos1[k]+1] = v+1
		end
	end
	if rawget(data,"ids2") then
		for k , v in pairs(data.ids2) do
			self._ids[2][data.pos2[k]+1] = v+1
		end
	end
	self._playTimes = {data.play1,data.play2}
end

-- @desc 是否重新需要拉数据
function RCardData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function RCardData:getCurScore()
	return self._score
end

function RCardData:getTotalScore()
	return self._totalScore
end

function RCardData:getTimeLeft()
	local time = G_ServerTime:getTime()
	local state = self:isOpen()
	if state then
		return self._timeEnd - time
	end
	return -1
end

function RCardData:isOpen()
	local time = G_ServerTime:getTime()
	if time >= self._timeStart and time <= self._timeEnd then
		return true
	else
		return false
	end
end

function RCardData:play(data)
	self._ids[data.id][data.pos+1] = data.cid+1
	self._score = self._score - self:costScore(data.id)
	self._playTimes[data.id] = self._playTimes[data.id] + 1
end

function RCardData:resetRCard(id)
	self._resetTimes[id] = self._resetTimes[id] + 1
	self._ids[id] = {}
	self:storeFirst(id)
end

function RCardData:curResetCost(id)
	-- local info = shop_price_info.get(32+id,self._resetTimes[id]+1)
	-- if info then
	-- 	return info.price
	-- end
	-- return -1
	return recharge_card_info.get(id).cost_num
end

function RCardData:canReset(id)
	return not GlobalFunc.table_is_empty(self._ids[id])
end

function RCardData:canFlip(id)
	for i = 1 , 8 do 
		if not self._ids[id][i] then
			return true
		end
	end
	return false
end

function RCardData:getCurAward(id,index)
	return self._ids[id][index]
end

function RCardData:getLeftCostTimes(id)
	return recharge_card_info.get(id).time - self._playTimes[id]
end

function RCardData:costScore(id)
	return recharge_card_info.get(id).cost
end

function RCardData:isFirst(id)
	if self._timeStart == 0 then
		return false
	end
	if not GlobalFunc.table_is_empty(self._ids[id]) then
		return false
	end
	local info = storage.load(storage.rolePath("rCard.data"))
	if info and info.time == self._timeStart then
		if rawget(info,tostring(id)) then
			return false
		end
	end
	return true
	-- return self._firstTime[id]
end

function RCardData:storeFirst(id)
	local info = storage.load(storage.rolePath("rCard.data"))
	if info and info.time == self._timeStart then
		info[tostring(id)] = 1
		storage.save(storage.rolePath("rCard.data"),info)
	else
		storage.save(storage.rolePath("rCard.data"),{time=self._timeStart,[tostring(id)]=1})
	end
	-- self._firstTime[id] = false
end

return RCardData
