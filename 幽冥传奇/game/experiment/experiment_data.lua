ExperimentData = ExperimentData or BaseClass()

ExperimentData.INFO_CHANGE = "info_change"
ExperimentData.INTO_PK = "into_pk" --获得pk对象数据 进入pk

ExperimentData.TRIAL_DATA_CHANGE = "trial_data_change"

function ExperimentData:__init()
	if ExperimentData.Instance then
		ErrorLog("[ExperimentData] attempt to create singleton twice!")
		return
	end

    --数据派发组件
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	ExperimentData.Instance = self

	self.dig_infos = {}
	self.base_info = {}

	self.trial_data = {}
end

function ExperimentData:__delete()
	self.dig_infos = {}
	self.base_info = {}
end

function ExperimentData:SetDigSlotData(data)
	self.dig_infos = data
	for i,v in pairs(self.dig_infos) do
		if Scene.Instance:GetSceneLogic().GetDigShowByIdx then
			for k1,v1 in pairs(v) do
				Scene.Instance:GetSceneLogic():GetDigShowByIdx(v.slot):GetVo()[k1] = v1
			end
			Scene.Instance:GetSceneLogic():GetDigShowByIdx(v.slot):UpdateShow()
		end
	end
end

function ExperimentData:AddDigSlotData(data)
	self.dig_infos[data.slot] = data
	if Scene.Instance:GetSceneLogic().GetDigShowByIdx then
		for k1,v1 in pairs(data) do
			Scene.Instance:GetSceneLogic():GetDigShowByIdx(data.slot):GetVo()[k1] = v1
		end
		Scene.Instance:GetSceneLogic():GetDigShowByIdx(data.slot):UpdateShow()
	end
end

function ExperimentData:DelDigSlotData(slot)
	self.dig_infos[slot] = nil
	if Scene.Instance:GetSceneLogic().GetDigShowByIdx then
		Scene.Instance:GetSceneLogic():GetDigShowByIdx(slot):InitVo()
	end
end

function ExperimentData:SetFireData(pro)
end

function ExperimentData:SetFireSuccesData(pro)
end

function ExperimentData:IsDiging()
	return self.base_info.start_dig_time and self.base_info.start_dig_time > COMMON_CONSTS.SERVER_TIME_OFFSET and TimeCtrl.Instance:GetServerTime() < self.base_info.end_dig_time
end

function ExperimentData:IsResuming()
	return self.base_info.resum_dig_num_time and self.base_info.resum_dig_num_time + COMMON_CONSTS.SERVER_TIME_OFFSET - TimeCtrl.Instance:GetServerTime()
end

function ExperimentData:CanDig()
	return self.base_info.dig_num and MiningActConfig.initTimes - self.base_info.dig_num > 0
end

function ExperimentData:CheckCanLingquDigAward()
	return self.base_info.start_dig_time and self.base_info.start_dig_time > COMMON_CONSTS.SERVER_TIME_OFFSET and TimeCtrl.Instance:GetServerTime() >= self.base_info.end_dig_time
end

function ExperimentData:SetViewData(pro)
	self.base_info = {
		dig_num = pro.dig_num,											--已挖矿次数
		plunder_num = pro.plunder_num,									--已掠夺次数
		start_dig_time = pro.start_dig_time,								--开始挖矿时间
		end_dig_time = pro.start_dig_time + MiningActConfig.finTimes,	--结束挖矿时间
		resum_dig_num_time = pro.resum_dig_num_time,						--次数恢复结束时间
		quality = pro.quality,											--品质
	}
end

-- 根据槽位索引获得数据
function ExperimentData:GetDigSlotInfoByIndex(idx)
	return self.dig_infos[idx]
end

function ExperimentData:GetBaseInfo()
	return self.base_info
end

function ExperimentData:GetDigSlotInfo()
	return self.dig_infos
end

function ExperimentData:GetRewardRemind()
	return 0
end

-- 接收试炼关卡信息
function ExperimentData:SetTrialData(protocol)
	self.trial_data.guan_num = protocol.guan_num
	self.trial_data.add_awards_tag = protocol.add_awards_tag
	self.trial_data.initial_hang_up_time = protocol.initial_hang_up_time
	self.trial_data.all_hang_up_times = protocol.all_hang_up_times
	self.trial_data.awards = protocol.awards

    self:DispatchEvent(ExperimentData.TRIAL_DATA_CHANGE, self.trial_data)
end

function ExperimentData:GetTrialData()
	return self.trial_data
end

-- 获取章节显示
function ExperimentData.GetSectionAndFloor(guan_index)
	guan_index = guan_index or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)

	if type(guan_index) ~= "number" then return 0, 0 end

	local floor_count = TrialConfig and TrialConfig.floor_count or 1
	local floor = guan_index % floor_count
	floor = floor == 0 and floor_count or floor
	local section_count = math.floor((guan_index - 1) / floor_count + 1)
	section_count = section_count == 0 and 1 or section_count
	
	return section_count, floor
end

-- 获取章节和难度
function ExperimentData.GetSectionAndDifficult(section_count)
	if section_count == nil then
		section_count = ExperimentData.GetSectionAndFloor()
	end
	if type(section_count) ~= "number" then return 0, 0 end

	local cfg_section_count = TrialConfig and TrialConfig.section_count or 1
	local section = (section_count - 1) % cfg_section_count + 1
	local difficult = math.floor((section_count - 1) / cfg_section_count) + 1
	difficult = difficult == 0 and 1 or difficult

	return section, difficult
end

-- 获取当前试炼章节数据列表
function ExperimentData:GetCurTrialFloorList()
	local cfg = TrialConfig and TrialConfig.chapters or {}
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local floor_count = TrialConfig and TrialConfig.floor_count or 1

	if cur_trial_floor >= #cfg then
		cur_trial_floor = #cfg - floor_count
	end
	
	local section_count = math.floor(cur_trial_floor / floor_count)

	local data_list = {}
	for i = 1, floor_count do
		local guan_index = section_count * floor_count + i
		data_list[i] = {}
		data_list[i].guan_index = guan_index
		data_list[i].cfg = cfg[guan_index]
	end

	return data_list
end