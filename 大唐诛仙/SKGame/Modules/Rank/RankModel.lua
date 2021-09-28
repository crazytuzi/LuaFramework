
RankModel =BaseClass(LuaModel)

RankModel.Type = {
	Battle = 1,   --战斗
	Equip = 2,  --神兵
	Gold = 3, --财富
}

function RankModel:GetInstance()
	if RankModel.inst == nil then
		RankModel.inst = RankModel.New()
	end
	return RankModel.inst
end

function RankModel:__init()
	self.tabData = nil
	self.pageSize = 5
	self.rankCols = {}
	self.colMapping = nil
end

function RankModel:GetColName(colId)
	return self.colMapping[colId][1]
end

function RankModel:GetColComponent(colId)
	return self.colMapping[colId][2]
end

function RankModel:GetMappingProperty(colId)
	return self.colMapping[colId][3]
end

function RankModel:GetRankCols(rankType)
	return self.rankCols[tostring(rankType)]
end

function RankModel:GetTabCfgData()
	if self.colMapping == nil then
		self.colMapping = {}
		local cfgData = GetCfgData("system"):Get(4)
		if cfgData then
			cfgData = cfgData.data
			for i = 1, #cfgData do
				local cfgInfo = StringSplit(cfgData[i], "_")
				local colId = tonumber(cfgInfo[1])
				local colName = cfgInfo[2]
				local colCompent = cfgInfo[3]
				local mappingProperty = cfgInfo[4]
				self.colMapping[colId] = {colName, colCompent, mappingProperty}
			end
		end
	end

	if self.tabData == nil then
		self.tabData = {}
		local cfgData = GetCfgData("system"):Get(2)
		if cfgData then
			cfgData = cfgData.data
			local result = {}
			for i = 1, #cfgData do
				local cfgInfo = StringSplit(cfgData[i], "_")
				local data = {{0,"综合"},{1,"战士"},{2,"法师"},{3,"暗巫"}}
				table.insert(result, {cfgInfo[1], cfgInfo[2], data})
				local tabType = tostring(cfgInfo[1])
				self.rankCols[tabType] = {}
				local colIndex = 3
				for i = colIndex, #cfgInfo do
					table.insert(self.rankCols[tabType], tonumber(cfgInfo[i]))
				end
			end
			self.tabData = result
		end
	end
	return self.tabData
end

--解析战力榜数据
function RankModel:ParseBattleRankData(data)
	local battleRankData = {} 
	battleRankData.myRank = data.myRank
	battleRankData.myValue = data.myValue
	battleRankData.rankList = {}
	SerialiseProtobufList(data.rankList, function(info)
			local vo = BattleRankVo.New()
			vo.rank = info.rank
			vo.playerId = info.playerId
			vo.playerName = info.playerName
			vo.career = info.career
			vo.level = info.level
			vo.guildName = info.guildName
			vo.value = info.value
			table.insert(battleRankData.rankList, vo)
	end)
	SortTableByKey(battleRankData.rankList, "rank", true)
	self:DispatchEvent(RankConst.UpdateRankData, {RankModel.Type.Battle, battleRankData})
end

--解析神兵榜数据
function RankModel:ParseEquipRankData(data)
	local equipRankData = {}
	equipRankData.myRank = data.myRank
	equipRankData.myValue = data.myValue
	equipRankData.rankList = {}
	SerialiseProtobufList(data.rankList, function(info)
			local vo = EquipRankVo.New()
			vo.rank = info.rank
			vo.playerId = info.playerId
			vo.playerName = info.playerName
			vo.career = info.career
			vo.level = info.level
			vo.guildName = info.guildName
			vo.value = info.value
			table.insert(equipRankData.rankList, vo)
	end)
	SortTableByKey(equipRankData.rankList, "rank", true)
	self:DispatchEvent(RankConst.UpdateRankData, {RankModel.Type.Equip, equipRankData})
end

--解析财富榜数据
function RankModel:ParseGoldRankData(data)
	local goldRankData = {}
	goldRankData.myRank = data.myRank
	goldRankData.myValue = data.myValue
	goldRankData.rankList = {}
	SerialiseProtobufList(data.rankList, function(info)
			local vo = GoldRankVo.New()
			vo.rank = info.rank
			vo.playerId = toLong(info.playerId)
			vo.playerName = info.playerName
			vo.career = info.career
			vo.level = info.level
			vo.guildName = info.guildName
			vo.value = info.value
			table.insert(goldRankData.rankList, vo)
	end)
	SortTableByKey(goldRankData.rankList, "rank", true)
	self:DispatchEvent(RankConst.UpdateRankData, {RankModel.Type.Gold, goldRankData})
end

function RankModel:__delete()
	self.tabData = nil
	self.rankCols = nil
	self.colMapping = nil

	RankModel.inst = nil
end