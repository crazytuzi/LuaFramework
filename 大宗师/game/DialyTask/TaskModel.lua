
TaskModel = {
	_data = nil,
	_instance = nil
}
TaskModel.__index = TaskModel

function TaskModel:init(data)
	self._data = data
	return self
end

local data_missiondefine_missiondefine = require "data.data_missiondefine_missiondefine"
local data_jifenjiangli_jifenjiangli = require "data.data_jifenjiangli_jifenjiangli"
local data_item_item = require "data.data_item_item"

---
-- 获取单例
function TaskModel:getInstance()
	if not self._instance then
		self._instance = self:new()
	end
	return self._instance
end

function TaskModel:new(o)
	o = o or {}
	setmetatable(o,self)
	return o
end

---
-- 获取任务列表
-- type 任务类型
function TaskModel:_getTaskList(type)
	local result = {}
	for k,v in pairs(self._data.rtnObj.missions) do
		if v.missionCategory == type then
			table.insert(result,v)
		end
	end
	return result
end


---
-- 获取已领取奖励列表
function TaskModel:getRewordedList()
	return self._data.rtnObj.dailyMission.reawrds
end

---
-- 移除任务
function TaskModel:removeTaskById(id)
	for k,v in pairs(self._data.rtnObj.missions) do
		if v.missionDefineId == id then 
			table.remove(self._data.rtnObj.missions,k)
		end
	end
end

---
-- 获取任务状态
function TaskModel:getTaskStateById(id)
	for k,v in pairs(self._data.rtnObj.missions) do
		if v.missionDefineId == id then 
			return v.status
		end
	end
end

---
-- 获取最大积分
function TaskModel:getMaxJIfen()
	local taskList = self:getTaskList(1)
	local max = 0
	for k,v in pairs(taskList) do
		max = max + v.jifen
	end
	return max
end

---
-- 获取积分列表
function TaskModel:getRewordList()
	local data = {}
	for k,v in pairs(data_jifenjiangli_jifenjiangli) do
        local dataTemp = {}
        dataTemp.id = v.id or 0
        dataTemp.jifen = v.jifen or 0
        dataTemp.rewardIds = v.rewardIds or 0
        dataTemp.rewardTypes = v.rewardTypes or 0
        dataTemp.rewardNums = v.rewardNums or 0
        data[k] = dataTemp
    end
	return data
end

---
-- 更新任务状态
function TaskModel:upDateTaskStateById(id,state)
	for k,v in pairs(self._data.rtnObj.missions) do
		if v.missionDefineId == id then 
			v.status = state
		end
	end
	
end

---
-- 插入奖励
function TaskModel:insertReword(id)
	table.insert(self._data.rtnObj.dailyMission.reawrds,id) 
end

---
-- 插入新任务
function TaskModel:insertNewTask(data)
	for k,v in pairs(data) do
		table.insert(self._data.rtnObj.missions,v)
	end 
end

---
-- 获取积分
function TaskModel:getJifen()
	return self._data.rtnObj.dailyMission.jifen
end

---
-- 获取任务完整信息
function TaskModel:getTaskList(type)
	local data = {}
	local dataOk = {}
	local dataReady = {}
    for k,v in pairs(self:_getTaskList(type)) do
        local dataTemp = {}
        local dataBase = data_missiondefine_missiondefine[v.missionDefineId]
        if dataBase then
			dataTemp.name = dataBase.name or "没有Name"
	        dataTemp.dis  = dataBase.description or "没有描述"
	        dataTemp.jifen = dataBase.jifen or "没有积分"
	        dataTemp.missionDetail = v.missionDetail or "没有进度"
	        dataTemp.id = v.missionDefineId
	        local Temp = string.split(dataBase.prams,",")
	        local ret = Temp[#Temp]
	        local bigan = #Temp == 1 and 2 or 1
	        dataTemp.totalStep = string.sub(ret ,bigan,string.len(ret) - 1) or "没有总进度"
	        dataTemp.order = dataBase.renwupaixu
	        dataTemp.missionCategory = v.missionCategory or "没有分类"
	        dataTemp.status = v.status or "没有状态"
	        dataTemp.quality = dataBase.quality or 0

	        dataTemp.icon = dataBase.icon or "jinridenglu"
	        dataTemp.goto = dataBase.navigation or print("没有填写导航")
	        dataTemp.finishTime = v.finishTime
	        if dataTemp.status == 1 then
	        	table.insert(data,dataTemp)
	        elseif  dataTemp.status == 2 then
	        	table.insert(dataReady,dataTemp)
	        elseif dataTemp.status == 3 then 
	        	table.insert(dataOk,dataTemp)
	        end
		else 

		end 
    end
	table.sort( data,function ( a,b)
			if a.order and b.order then
				return  a.order < b.order 
	        end
		end)

	table.sort( dataOk,function ( a,b)
    	if a.finishTime and b.finishTime then
	    	return a.finishTime < b.finishTime 
		end
	end)

	
	table.sort(dataReady,function (a,b)
		if a.finishTime and b.finishTime then 
			return a.finishTime < b.finishTime 
		end
	end)

	for k,v in pairs(data) do
		table.insert(dataReady,v)
	end

    --成长之路不显示完成的
	if type == 2 then
		dataOk = {}
	end

    for k,v in pairs(dataOk) do
    	table.insert(dataReady,v)
    end

    return dataReady
end

---
-- 检查是否有达到积分上限的可领取奖励
function TaskModel:checkHasReword()
	local ret = false
	for k,v in pairs(data_jifenjiangli_jifenjiangli) do
		if v.jifen <= self:getJifen() and not self:getJifenState(v.id) then
			ret = true
		end
	end
	return ret
end

---
-- 获取活动列表
function TaskModel:getActivityList()
	local tempData = {}
	self._data.rtnObj.extendMissionDefines = self._data.rtnObj.extendMissionDefines or {}
	for k,v in pairs(self._data.rtnObj.extendMissionDefines) do
		local data = {}
		data.title = v.name
		data.dis = v.description
		data.startTime = v.startTime
		data.endTime = v.endTime
		data.id = v.id
		data.state = self:getTaskStateById(v.id)
		local rewords = {}
		for key,var in pairs(v.rewardIds) do
			local rewordsItem = {}
			rewordsItem.id = var
			rewordsItem.num = v.rewardNums[key]
			rewordsItem.iconType = ResMgr.getResType(v.rewardTypes[key])
			rewordsItem.type = v.rewardTypes[key]
			rewordsItem.name = data_item_item[var].name
			table.insert(rewords,rewordsItem)
		end
		data.rewords = rewords
		--检查是否接受此活动
		if data.state then
			table.insert(tempData,data)
		end
	end
	
	return tempData
end

---
-- 检查是否可以领取
function TaskModel:checkRewordable(id)
	local ret = false
	if data_jifenjiangli_jifenjiangli[id] then
		local minJinfen = data_jifenjiangli_jifenjiangli[id].jifen
			if self:getJifen() >= minJinfen and not self:getJifenState(id) then
			ret = true
		end
	end
	return ret
end

---
-- 获取积分奖励的领取状态
function TaskModel:getJifenState(id)
	local ret = false
	for k,v in pairs(self:getRewordedList()) do
		if id == v then
			ret = true
		end
	end
	return ret
end

---
-- 获取对应积分下奖励列表
function TaskModel:getGiftList(id)
	local result = {}
	local dataBase = data_jifenjiangli_jifenjiangli[id]
	if type(dataBase.rewardIds) == "table" then
		for k,v in pairs(dataBase.rewardIds) do
			local dataTemp = {}
			dataTemp.id = v
			dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes[k])
			dataTemp.type = dataBase.rewardTypes[k]
			dataTemp.num = dataBase.rewardNums[k]
			dataTemp.name = data_item_item[dataTemp.id].name
			table.insert(result,dataTemp)
		end
	else
		local dataTemp = {}
		dataTemp.id = dataBase.rewardIds
		dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes)
		dataTemp.type = dataBase.rewardTypes
		dataTemp.num = dataBase.rewardNums
		dataTemp.name = data_item_item[dataTemp.id].name
		table.insert(result,dataTemp)
	end
	
	return result
end

---
-- 获取任务奖励列表
function TaskModel:getTaskGiftList(id)
	local result = {}
	local dataBase = data_missiondefine_missiondefine[id]
	if type(dataBase.rewardIds) == "table" then
		for k,v in pairs(dataBase.rewardIds) do
			local dataTemp = {}
			dataTemp.id = v
			dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes[k])
			dataTemp.num = dataBase.rewardNums[k]
			dataTemp.name = data_item_item[dataTemp.id].name
			table.insert(result,dataTemp)
		end
	else
		local dataTemp = {}
		dataTemp.id = dataBase.rewardIds
		dataTemp.iconType = ResMgr.getResType(dataBase.rewardTypes)
		dataTemp.num = dataBase.rewardNums
		if not data_item_item[dataTemp.id] then
		end
		dataTemp.name = data_item_item[dataTemp.id].name
		
		table.insert(result,dataTemp)
	end
	
	return result
end

---
-- 标签页小红点检测
function TaskModel:checkStateByType(type)
	local ret = false
	if type == 1 then 
		if self:checkHasReword() then
			ret = true
		end
	elseif type == 2 then 
		for k,v in pairs(self:getTaskList(type)) do
			if v.status == 2 then
				ret = true
				break
			end
		end
	elseif type == 3 then 

	elseif type == 4 then 
		for k,v in pairs(self:getActivityList(type)) do
			if v.state == 2 then 
				ret = true
				break
			end
		end
	end
	return ret
end


