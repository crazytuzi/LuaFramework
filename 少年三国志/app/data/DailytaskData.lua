-- 每日任务
require("app.cfg.daily_mission_info")
require("app.cfg.daily_box_info")

local DailytaskData = class("DailytaskData")

local scoreList = {30,60,90,120}

function DailytaskData:ctor()
	self._score = 0
	self._level = 0
	self._taskData = {}
	self._award = {}
	self._box = {}
end

function DailytaskData:setData(data)
	self._taskData = data.fixed_mission
	self._score = data.score
	self._level = data.level
	-- self._box = data.score_awards
	local boxarr = {}
	for k,v in pairs(data.score_awards) do 
		boxarr[v.id] = v.is_finished
	end
	self._box = boxarr
	self:_initAward()
end

function DailytaskData:getTask()
	return self._taskData
end

function DailytaskData:getSgTask(id)
	for k,v in pairs(self._taskData) do 
		if v.id == id then
			return v
		end
	end
	return nil
end

function DailytaskData:getScore()
	return self._score
end

function DailytaskData:getScoreList()
	return scoreList
end

-- 2为不满足，3为满足未领取，1为已领取
function DailytaskData:getTaskStatus(id)
	local task = self:getSgTask(id)
	if not task then 
		return 0 
	end
	local status = 0
	local info = daily_mission_info.get(id)
	if task.progress >= info.require_times then
		if task.is_finished then
			status = 1
		else
			status = 3
		end
	else
		status = 2
	end
	return status
end

-- 1为不满足，2为满足未领取，3为已领取
function DailytaskData:getBoxStatus()
	local status = {}
	local boxId = self:getBoxId()
	for i = 1,4 do 
		local id = boxId[i]
		if self._box[id] == true then
			status[i] = 3
		else
			if self._score>=scoreList[i] then
				status[i] = 2
			else
				status[i] = 1
			end
		end
	end
	return status
end

function DailytaskData:getBoxImg()
	local status = self:getBoxStatus()
	local img = {}
	img[1] = {"baoxiangtong_guan","baoxiangtong_kai","baoxiangtong_kong"}
	img[2] = {"baoxiangyin_guan","baoxiangyin_kai","baoxiangyin_kong"}
	img[3] = {"baoxiangjin_guan","baoxiangjin_kai","baoxiangjin_kong"}
	img[4] = {"baoxiangjinlong_guan","baoxiangjinlong_kai","baoxiangjinlong_kong"}
	local dst = {}
	for i = 1,4 do 
		dst[i] = "ui/dailytask/"..img[i][status[i]]..".png"
	end
	return dst
end

function DailytaskData:_initAward()
	local award = {}
	for i = 1,daily_box_info.getLength() do 
		local data = daily_box_info.indexOf(i)
		if data and self._level >= data.level_min and self._level <= data.level_max then
			for j = 1,4 do 
				if scoreList[j] == data.require_points then
					award[j] = data.id
				end
			end
		end
	end
	self._award = award
end

function DailytaskData:getAward()
	return self._award
end

function DailytaskData:getBoxId()
	local box = {}
	for i = 1,daily_box_info.getLength() do 
		-- local data = daily_box_info.get(i)
		local data = daily_box_info.indexOf(i)
		if self._level >= data.level_min and self._level <= data.level_max then
			for j = 1,4 do 
				if scoreList[j] == data.require_points then
					box[j] = data.id
				end
			end
		end
	end
	return box
end

function DailytaskData:flushData(mission)
	for k,v in pairs(self._taskData) do
		if v.id == mission.id then
			self._taskData[k] = mission
		end
	end
end

function DailytaskData:flushBox(boxId)
	-- for k,v in pairs(self._box) do 
	-- 	if v.id == boxId then
	-- 		v.is_finished = true
	-- 	end
	-- end 
	self._box[boxId] = true
end

function DailytaskData:hasNew()
	for k,v in pairs(self._taskData) do
		local info = daily_mission_info.get(v.id)
		if info and v.progress >= info.require_times and v.is_finished == false then
			return true
		end
	end
	local boxList = self:getBoxStatus()
	for i = 1,4 do 
		if boxList[i] == 2 then
			return true
		end
	end
	return false
end

function DailytaskData:setScore(score)
	self._score = score
end

return DailytaskData
