local MapModel = class("MapModel", function()
	return {}
end)
MapModel.mapData = {}
MapModel.worldRedTipAry = nil
MapModel.curBigMapID = 0
MapModel.bigMap = 0
MapModel.subMap = 0
MapModel.level = 0
MapModel.smallMapData = {}
local data_battle_battle = require("data.data_battle_battle")
local data_field_field = require("data.data_field_field")
local data_world_world = require("data.data_world_world")

function MapModel:getWorldRedTipAry()
	return self.worldRedTipAry
end

function MapModel:init()
	self.mapData = {}
	self.worldRedTipAry = nil
	self.curBigMapID = 0
	self.bigMap = 0
	self.subMap = 0
	self.level = 0
	self.curMaxBigMapId = nil
	self.smallMapData = {}
end
function MapModel:setCurrentBigMapID(id)
	self.curBigMapID = id
end
function MapModel:getBigMap(id)
	if id == nil then
		return self.mapData[self.bigMap]
	end
	return self.mapData[id]
end

function MapModel:getCurrentBigMapID()
	return self.curBigMapID
end

function MapModel:getCurrentSubMap()
	return self.subMap
end

function MapModel:initData(data, mapId)
	if mapId == nil then
		mapId = data["1"]
		if self.curBigMapID == 0 then
			self.curBigMapID = data["1"]
		end
	end
	self.bigMap = data["1"]
	self.subMap = data["2"]
	self.level = data["3"]
	self.worldRedTipAry = data["6"]
	local bigMapData = {}
	bigMapData.subMapStar = data["4"]
	bigMapData.itemFlag = data["5"]
	bigMapData.fieldRedTipAry = data["7"]
	self.mapData[mapId] = bigMapData
	game.player.bigmapData = data
	if self.curBigMapID == 0 then
		self.curBigMapID = self.bigMap
	end
end

--[[请求地图数据]]
function MapModel:requestMapData(bigMapId, _callback, refresh)
	if refresh ~= true and bigMapId and self.mapData[bigMapId] then
		if _callback then
			_callback("", self.mapData[bigMapId])
		end
	else
		RequestHelper.getLevelList({
		id = bigMapId,
		callback = function(data)
			dump(data)
			self:initData(data, bigMapId)
			if _callback then
				if bigMapId == nil then
					bigMapId = self.bigMap
				end
				_callback(data["0"], self.mapData[bigMapId])
			end
		end
		})
	end
end

function MapModel:setBigMapData()
end
local checkPackageTbl = {
HeroCardModel,
EquipmentModel,
SkillModel,
PackageModel
}

local nextDayTime
function MapModel:checkGoNextDay()
	local getNextDayTime = function()
		local time = os.date("*t")
		time.hour = 0
		time.min = 0
		time.sec = 0
		return os.time(time) + 86400
	end
	if not nextDayTime then
		nextDayTime = getNextDayTime()
		return false
	end
	local nowTime = os.time()
	if nowTime > nextDayTime then
		nextDayTime = getNextDayTime()
		return true
	else
		return false
	end
end

function MapModel:getSmallMapData(smallMapId, _callback, refresh)
	if self:checkGoNextDay() then
		self.smallMapData = {}
		self.curSmallMapId = nil
	end
	if refresh ~= true and self.smallMapData[smallMapId] then
		self.curSmallMapId = smallMapId
		_callback(self.smallMapData[smallMapId], false)
		RequestHelper.getSubLevelList({
		callback = function(data)
			for key, value in pairs(data) do
				self.smallMapData[smallMapId][key] = value
			end
			_callback(nil, true)
		end,
		id = smallMapId
		})
	else
		RequestHelper.getSubLevelList({
		callback = function(data)
			self.smallMapData[smallMapId] = data
			self.curSmallMapId = smallMapId
			_callback(data, true)
		end,
		id = smallMapId
		})
	end
end

function MapModel:setCurSmallMapData(id, gradeID, times)
	if not data_battle_battle[id] then
		return
	end
	local curSmallMapId = data_battle_battle[id].field
	local curSmallMap = self.smallMapData[curSmallMapId]
	if not curSmallMap then
		return
	end
	times = times or 1
	local smallMap2 = curSmallMap["1"][tostring(id + 1)]
	if smallMap2 and smallMap2.cnt == 0 and smallMap2.star == 0 then
		smallMap2.cnt = data_battle_battle[id + 1].number
		--smallMap2.max = data_battle_battle[id + 1].lianzhan
		smallMap2.max = data_battle_battle[id + 1].number
		smallMap2.star = 0
	end
	local smallMap = curSmallMap["1"][tostring(id)]
	local newStar = false
	if smallMap then
		if gradeID > smallMap.star then
			smallMap.star = gradeID
			curSmallMap["2"].stars = curSmallMap["2"].stars + 1
			local newReward = false
			for key, status in ipairs(curSmallMap["2"].box) do
				if status == 1 then
					local needStars = data_field_field[curSmallMapId]["star" .. key]
					if needStars and needStars <= curSmallMap["2"].stars then
						curSmallMap["2"].box[key] = 2
						newReward = true
					end
					break
				end
			end
			local getIndexFunc = function(tbl, value)
				for key, id in ipairs(tbl) do
					if id == value then
						return key
					end
				end
			end
			local worldId = data_field_field[curSmallMapId].world
			local bigMapData = self.mapData[worldId]
			if bigMapData then
				if id >= self.level then
					local newLevel, newSubMap, newBigMap
					local battleIndex = getIndexFunc(data_field_field[curSmallMapId].arr_battle, id)
					if battleIndex then
						if battleIndex >= #data_field_field[curSmallMapId].arr_battle then
							local fieldIndex = getIndexFunc(data_world_world[worldId].arr_field, self.subMap)
							if fieldIndex >= #data_world_world[worldId].arr_field then
								local newWorldId = self.bigMap + 1
								if data_world_world[newWorldId] then
									self.bigMap = newWorldId
									self.subMap = data_world_world[self.bigMap].arr_field[1]
									self.level = data_field_field[self.subMap].arr_battle[1]
									MapModel:requestMapData()
								end
							else
								self.subMap = data_world_world[worldId].arr_field[fieldIndex + 1]
								self.level = data_field_field[self.subMap].arr_battle[1]
							end
						else
							self.level = data_field_field[curSmallMapId].arr_battle[battleIndex + 1]
						end
					end
				end
				bigMapData.subMapStar[tostring(curSmallMapId)] = curSmallMap["2"].stars
				if newReward then
					bigMapData.fieldRedTipAry[tostring(curSmallMapId)] = 1
					self.worldRedTipAry[tostring(data_field_field[curSmallMapId].world)] = 1
				end
			end
		end
		smallMap.cnt = smallMap.cnt - times
		smallMap.max = 10
		if smallMap.max > smallMap.cnt then
			smallMap.max = smallMap.cnt
		end
		self.curMaxBigMapId = self.subMap
	end
end

return MapModel