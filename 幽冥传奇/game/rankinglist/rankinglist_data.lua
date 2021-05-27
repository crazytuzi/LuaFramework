RankingListData = RankingListData or BaseClass()

RankingListData.RankingList_TYPE = {
	battle_power = 0,		--// 战力榜(值会降低)
	warriorlv = 1,			--// 战士等级榜
	magelv = 2,				--// 法师等级榜
	wizardlv = 3,			--// 道士等级榜
	office = 4,				--// 官职榜
	wing = 5,				--// 翅膀榜
	hero = 6,				--// 战将榜
	yongzhe = 7, 			--// 勇者闯关
}

RankingListData.PRESTIGE_LIST_CHANGE = "prestige_list_change"
RankingListData.SHILIAN_LIST_CHANGE = "shilian_list_change"
function RankingListData:__init()
	if RankingListData.Instance then
		ErrorLog("[RankingListData]:Attempt to create singleton twice!")
	end
	RankingListData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.rankinglist_type = nil
	self.myself_ranking = nil
	self.rankinglist_list = {}
	self.rankinglist_page = nil
	self.prestige_name_list = {} -- 威望前三名的名称
end

function RankingListData:__delete()
end

--得到要发送的排行榜类型
function RankingListData.GetSendRankingListType(index)
	if index == 1 then
		return RankingListData.RankingList_TYPE.battle_power
	elseif index == 2 then
		return RankingListData.RankingList_TYPE.warriorlv
	elseif index == 3 then
		return RankingListData.RankingList_TYPE.magelv
	--elseif index == 4 then
	--	return RankingListData.RankingList_TYPE.wizardlv
	elseif index == 4 then
		return RankingListData.RankingList_TYPE.office
	elseif index == 5 then
		return RankingListData.RankingList_TYPE.wing
	elseif index == 6 then
		return RankingListData.RankingList_TYPE.hero
	elseif index == 7 then
		return RankingListData.RankingList_TYPE.yongzhe
	end	
	return RankingListData.RankingList_TYPE.battle_power
end

function RankingListData:SetMyData(protocol)
	self.myself_ranking = protocol.myself_ranking
	self.rankinglist_type = protocol.rankinglist_type
end

function RankingListData:SetRankingList(protocol)
	self.rankinglist_type = protocol.rankinglist_type
	if nil == self.rankinglist_list[self.rankinglist_type] then
		self.rankinglist_list[self.rankinglist_type] = {}
	end
	for k, v in pairs(protocol.rankinglist_list) do
		self.rankinglist_list[self.rankinglist_type] [k] = v
	end
	if #self.rankinglist_list[self.rankinglist_type] < 10 then -- 未满10个
		for i = #self.rankinglist_list[self.rankinglist_type] + 1, 10 do
			self.rankinglist_list[self.rankinglist_type] [i] = {no_data = 1}
		end
	end

	-- 威望前三名
	if protocol.rankinglist_type == 4 then
		for i = 1, 3 do
			if  nil ~= protocol.rankinglist_list[i] then
				self.prestige_name_list[i] = protocol.rankinglist_list[i].role_name
			end
		end

		self:DispatchEvent(RankingListData.PRESTIGE_LIST_CHANGE)
	elseif protocol.rankinglist_type == 3 then
		self:DispatchEvent(RankingListData.SHILIAN_LIST_CHANGE)
	end
end
-- 获取威望前三名
function RankingListData:GetPrestigeName()
	return self.prestige_name_list
end

--得到我的排名
function RankingListData:GetMyData()
	return self.myself_ranking
end

--得到排行榜数据
function RankingListData:GetRankingListData(type)
	return self.rankinglist_list[type] or {}
end

--得到排行榜前三数据
function RankingListData:GetTopThreeName(_type)
	local top_three_name = {}
	local cur_ranking_list = self.rankinglist_list[_type]
	if cur_ranking_list then
		for i = 1, 3 do
			if type(cur_ranking_list[i]) == "table" and 0 ~= cur_ranking_list[i].ranking_value  then
				top_three_name[i] = cur_ranking_list[i].role_name
			end
		end
	end

	return top_three_name
end

--得到排行榜类型
function RankingListData:GetRankingListType()
	return self.rankinglist_type
end

--得到官职
function RankingListData.GetOfficename(office_level, prof)
	for i, v in ipairs(office_cfg.level_list) do
		if i == office_level then
			return v.jobs[prof].name
		end	
	end
	return nil
end

--得到战将ID
function RankingListData.GetZhanJiangId(zhangjiang_level)
	for k, v in pairs(HeroListConfig.upgradecfg) do
		if k == zhangjiang_level then
			return v.currid
		end	
	end
end

--从stdmonster中由ID得到战将的名字
function RankingListData.GetZhanJiangName(id)
	for k, v in pairs(StdMonster) do
		if v.entityid == id then
			return v.name
		end
	end
end

--获取本服最高等级
function RankingListData:GetServerHighestLevel()
	local highest_level = 0
	if self.rankinglist_list[RankingListData.RankingList_TYPE.warriorlv] then
		if self.rankinglist_list[RankingListData.RankingList_TYPE.warriorlv] [1] then
			if highest_level <(self.rankinglist_list[RankingListData.RankingList_TYPE.warriorlv] [1].ranking_value or 0) then
				highest_level = self.rankinglist_list[RankingListData.RankingList_TYPE.warriorlv] [1].ranking_value
			end
		end
	end
	if self.rankinglist_list[RankingListData.RankingList_TYPE.magelv] then
		if self.rankinglist_list[RankingListData.RankingList_TYPE.magelv] [1] then
			if highest_level <(self.rankinglist_list[RankingListData.RankingList_TYPE.magelv] [1].ranking_value or 0) then
				highest_level = self.rankinglist_list[RankingListData.RankingList_TYPE.magelv] [1].ranking_value
			end
		end
	end
	if self.rankinglist_list[RankingListData.RankingList_TYPE.wizardlv] then
		if self.rankinglist_list[RankingListData.RankingList_TYPE.wizardlv] [1] then
			if highest_level <(self.rankinglist_list[RankingListData.RankingList_TYPE.wizardlv] [1].ranking_value or 0) then
				highest_level = self.rankinglist_list[RankingListData.RankingList_TYPE.wizardlv] [1].ranking_value
			end
		end
	end
	return highest_level
end


