
AchievementManager = {};
AchievementManager.State = {}
local achievemenConfig = nil
local achievemenData = nil
local achievemenTypeConfig = nil
local achievemenCount = 0
local insert = table.insert
local _sortfunc = table.sort
function AchievementManager.Init()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AchievementChange, AchievementManager.AchievementChangeCallBack);
	
	achievemenConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ACHIEVEMENT)
	achievemenCount = table.getCount(achievemenConfig)
	achievemenTypeConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ACHIEVEMENT_TYPE)
	achievemenData = {}
	for k, v in pairs(achievemenConfig) do
		if achievemenData[v.type] == nil then
			achievemenData[v.type] = {}
			achievemenData[v.type].t = v.type
			achievemenData[v.type].name = AchievementManager.GetAchievementDesById(v.type).type
			achievemenData[v.type].datas = {}
		end
		local item = {}
		setmetatable(item, {__index = ConfigManager.TransformConfig(v)})
		item.state = 0
		item.rewards = {}
		item.curNum = 0
		local index = 1
		for k1, v1 in ipairs(v.reward) do
			item.rewards[index] = {}
			local temp = ConfigSplit(v1)
			item.rewards[index].id = tonumber(temp[1])
			item.rewards[index].num = tonumber(temp[2])
			index = index + 1
		end
		
		insert(achievemenData[v.type].datas, item)
	end
end

function AchievementManager.GetAllAchievementCount()
	return achievemenCount
end

function AchievementManager.GetAllFinishAchievementCount()
	local count = 0
	for k, v in pairs(achievemenData) do
		for k1, v1 in pairs(v.datas) do
			if(v1.state == 2) then
				count = count + 1
			end
		end
	end
	return count
end

function AchievementManager.AchievementSort(a, b)
	local priority = 0
	priority =(a.id - b.id)
	if(a.state == b.state) then
		return priority < 0
	else
		if(a.state == 1) then
			return true
		end
		
		if(b.state == 1) then
			return false
		end
		
		if(a.state == 0) then
			return true
		end
		
		if(b.state == 0) then
			return false
		end
	end
	
end

function AchievementManager.AchievementChangeCallBack(cmd, data)
	if(data and data.errCode == nil) then
		AchievementManager.SetAchievementData(data.achieve)
		
		if(table.getCount(data.achieve) > 1) then
			_sortfunc(data.achieve, function(a, b) return(a.id - b.id) < 0 end)
		end
		
		for k, v in ipairs(data.achieve) do
			if(v.st == 1) then
				local temp = nil
				local config = achievemenConfig[v.id]
				if(config) then
					temp = {}
					setmetatable(temp, {__index = ConfigManager.TransformConfig(config)})
					temp.state = 1
					temp.rewards = {}
					for k1, v1 in ipairs(config.reward) do
						local t = {}
						local tempReward = ConfigSplit(v1)
						t.id = tonumber(tempReward[1])
						t.num = tonumber(tempReward[2])
						insert(temp.rewards, t)
					end
					ModuleManager.SendNotification(MainUINotes.OPEN_ACHIEVEMENTREWARD, temp)
				else
					log("找不到相应成就配置" .. v.id)
				end
				break
			end
		end
	end
end

function AchievementManager.SetAchievementData(data)
	if(data) then
		for k, v in pairs(data) do
			local config = achievemenConfig[v.id]
			local datas = achievemenData[config.type].datas
			for k1, v1 in pairs(datas) do
				if(v1.id == v.id) then
					v1.curNum = v.num
					v1.state = v.st
				end
			end
		end
	end
	ModuleManager.SendNotification(MainUINotes.UPDATE_MYROLEPANEL)
end

function AchievementManager.GetAchievementData()
	return achievemenData
end

function AchievementManager.SortAchievementData(data)
	_sortfunc(data, AchievementManager.AchievementSort)
end

function AchievementManager.GetAchievementDesById(id)
	if achievemenTypeConfig then
		local des = achievemenTypeConfig[id] or ""
		return des
	end
end

function AchievementManager.GetAchievementDataByCondition(onlyShowFinish, data)
	local tempData = {}
	local ignoreList = {}
	if(onlyShowFinish) then
		for k, v in pairs(data) do
			if(v.state == 2) then
				tempData[v.id] = v
			end
		end
		
		for k, v in pairs(tempData) do
			if(tempData[v.next] ~= nil) then
				insert(ignoreList, v.id)
			end
		end
		
		for k, v in pairs(tempData) do
			for k1, v1 in pairs(ignoreList) do
				if(v.id == v1) then
					tempData[k] = nil
				end
			end
		end
		local temp = ConfigManager.Clone(tempData)
		tempData = {}
		for k, v in pairs(temp) do
			insert(tempData, v)
		end
	else
		local temp = {}
		for k, v in pairs(data) do
			if(temp[v.kind] == nil) then
				temp[v.kind] = {}
			end
			insert(temp[v.kind], v)
		end
		
		for k, v in pairs(temp) do
			if(table.getCount(v) == 1) then
				insert(tempData, v[1])
			else
				_sortfunc(v, function(a, b) return a.id < b.id end)
				local tempItem = nil
				local tempState = 0
				for k1, v1 in ipairs(v) do
					if(tempItem == nil) then
						tempItem = {}
						setmetatable(tempItem, {__index = v1})
						tempState = v1.state
						if((tempState == 1) or(tempState == 0)) then
							break
						end
					else
						if(tempState == 2) then
							tempItem = {}
							setmetatable(tempItem, {__index = v1})
							tempState = v1.state
							if((v1.state == 1) or(tempState == 0)) then
								break
							end
						end
					end
				end
				insert(tempData, tempItem)
			end
		end
	end
	AchievementManager.SortAchievementData(tempData)
	return tempData
end

function AchievementManager.GetIsAchievementFinish()
	for k, v in pairs(achievemenData) do
		for k1, v1 in pairs(v.datas) do
			if(v1.state == 1) then
				return true
			end
		end
	end
	return false
end 