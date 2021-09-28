FestivalActivityQiQiuData = FestivalActivityQiQiuData or BaseClass(BaseEvent)

function FestivalActivityQiQiuData:__init()
	if nil ~= FestivalActivityQiQiuData.Instance then
		return
	end

	FestivalActivityQiQiuData.Instance = self

	self.plant_cfg = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().planting_tree

	self.plant_cfg = ListToMap(cfg, "rank")

	self.plant_rank_list = {}
	self.fangfei_rank_list = {}
	self.plant_info_list = {}
	self.plant_minimap_list = {}

	self.my_da_qiqiu_inof = {rank = 0, times = 0}
	self.my_chui_qiqiu_inof = {rank = 0, times = 0}

	self.da_qiqiu_rank_num = 0
	self.cui_qiqiu_rank_num = 0
end

function FestivalActivityQiQiuData:__delete()
	FestivalActivityQiQiuData.Instance = nil
end

function FestivalActivityQiQiuData:SetPlantingTreeRankInfo(protocol)
	local rank_type = protocol.rank_type
	if RA_PLANTING_TREE_RANK_TYPE.PERSON_RANK_TYPE_PLANTING_TREE_PLANTING == rank_type then
		self.plant_rank_list = protocol.rank_list
		self.da_qiqiu_rank_num = protocol.rank_list_count

		self.my_da_qiqiu_inof.times = protocol.opera_times
		self.my_da_qiqiu_inof.rank = self:GetMyRank(self.plant_rank_list)
	elseif RA_PLANTING_TREE_RANK_TYPE.PERSON_RANK_TYPE_PLANTING_TREE_WATERING == rank_type then
		self.fangfei_rank_list = protocol.rank_list
		self.cui_qiqiu_rank_num = protocol.rank_list_count

		self.my_chui_qiqiu_inof.times = protocol.opera_times
		self.my_chui_qiqiu_inof.rank = self:GetMyRank(self.fangfei_rank_list)
	end
end

function FestivalActivityQiQiuData:SetPlantingTreeInfo(protocol)
	local rank_type = protocol.rank_type
	self.plant_rank_list[rank_type] = protocol.rank_list
end

function FestivalActivityQiQiuData:SetPlantingTreeMiniMapInfo(protocol)
	self.plant_minimap_list = protocol.tree_info_list
end

function FestivalActivityQiQiuData:GetRankRewardByIndex(index)	
	return self.plant_cfg[index]
end

function FestivalActivityQiQiuData:GetPlantTitle()
	if nil == self.plant_cfg[1] then
		return 0
	end
	return self.plant_cfg[1].title_plant
end

function FestivalActivityQiQiuData:GetItemId()
	if nil == self.plant_cfg[1] then
		return 0
	end
	return self.plant_cfg[1].item_id
end

function FestivalActivityQiQiuData:GetWaterTitle()
	if nil == self.plant_cfg[1] then
		return 0
	end	
	return self.plant_cfg[1].title_water
end

function FestivalActivityQiQiuData:GetPlantRankList()
	return self.plant_rank_list
end

function FestivalActivityQiQiuData:GetPlantRankListCount()
	return self.da_qiqiu_rank_num
end

function FestivalActivityQiQiuData:GetFangFeiRankList()
	return self.fangfei_rank_list
end

function FestivalActivityQiQiuData:GetFangFeiRankListCount()
	return self.cui_qiqiu_rank_num
end

function FestivalActivityQiQiuData:GetMyDaQiQiuInfo()
	return self.my_da_qiqiu_inof
end

function FestivalActivityQiQiuData:GetMyChuiQiQiuInfo()
	return self.my_chui_qiqiu_inof
end

function FestivalActivityQiQiuData:GetMyRank(list)
	if nil == list then
		return 0
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(list) do
		if v.uid == main_role_vo.role_id then
			return k
		end
	end

	return 0
end