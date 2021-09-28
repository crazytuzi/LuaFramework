WaBaoData = WaBaoData or BaseClass()

WA_BAO_OPERA_TYPE =
{
	OPERA_TYPE_START = 0,
	OPERA_TYPE_DIG = 1,
	OPERA_TYPE_QUICK_COMPLETE = 2,
	OPERA_TYPE_GET_INFO = 3,
	OPERA_TYPE_SHOUHUZHE_TIME = 4,
}

WABAO_REWARD_TYPE =
{
	DAOJU = 1,
	BOSS = 2,
}

function WaBaoData:__init()
	if WaBaoData.Instance then
		print_error("[WaBaoData] Attemp to create a singleton twice !")
	end
	WaBaoData.Instance = self
	self.wabao_info = {}
	self.wabao_cfg = ConfigManager.Instance:GetAutoConfig("wabaoconfig_auto")
	self.now_total_degree = -1
	self.FastWaBaoFlag = false
end

function WaBaoData:__delete()
	WaBaoData.Instance = nil
end

function WaBaoData:OnSCWabaoInfo(protocol)
	self.wabao_info.baozang_scene_id = protocol.baozang_scene_id
	self.wabao_info.baozang_pos_x = protocol.baozang_pos_x
	self.wabao_info.baozang_pos_y = protocol.baozang_pos_y
	self.wabao_info.baotu_count = protocol.baotu_count	 				--宝图数量
	self.wabao_info.wabao_reward_type =	protocol.wabao_reward_type		--奖励类型
	self.wabao_info.wabao_reward_list = protocol.wabao_reward_list
	self.wabao_info.shouhuzhe_time = protocol.shouhuzhe_time
end

function WaBaoData:GetWaBaoInfo()
	return self.wabao_info
end

function WaBaoData:GetVirtualWaBaoTask()
	if nil == self.virtual_wabao_task_cfg then
		self.virtual_wabao_task_cfg = {
			task_id = 999993,
			task_type = TASK_TYPE.LINK,
			open_panel_name = ViewName.WaBao,
			decs_index = 3,
		}
	end
	return self.virtual_wabao_task_cfg
end

function WaBaoData:GetCurRewardCfg()
	local index = 1
	if next(self.wabao_info) and self.wabao_info then
		index = self.wabao_info.wabao_reward_type + 1
	end
	return self.wabao_cfg.baozang_reward[index]
end

function WaBaoData:GetOtherCfg()
	return self.wabao_cfg.other[1]
end

function WaBaoData:GetPosCfg(scene_id)
	local pos_cfg = {}
	pos_cfg.x = 107
	pos_cfg.y = 108
	return pos_cfg
end

function WaBaoData:GetRewardResId()
	local reward_type = self.wabao_info.wabao_reward_type or 1
	local res_id = 0
	if reward_type == 1 then
		res_id = 603901
	elseif reward_type == 2 then
		res_id = 603902
	elseif reward_type == 3 then
		res_id = 603903
	end
	return res_id
end

function WaBaoData:GetShowItems()
	local other_cfg = self.wabao_cfg.other[1]
	local data_list = {}
	for i=1,3 do
		local data = {}
		data.item_id = other_cfg["reward_item"..i].item_id
		data.is_bind = other_cfg["reward_item"..i].is_bind
		data.num = other_cfg["reward_item"..i].num
		table.insert(data_list, data)
	end
	return data_list
end

--合并相同的奖励
local function MergeRewardList(data)
	local item_id_list = {}
	for k, v in ipairs(data) do
		if nil == item_id_list[v.item_id] then
			item_id_list[v.item_id] = k
		end
	end
	for i = #data, 1, -1 do
		local item_id = data[i].item_id
		local key = item_id_list[item_id]
		if key and key ~= i then
			data[key].num = data[key].num + 1
			table.remove(data, i)
		end
	end
end

function WaBaoData:GetRewardItems()
	local data_list = {}
	for k,v in pairs(self.wabao_info.wabao_reward_list) do
		if v ~= 0 then
			for m,n in pairs(self.wabao_cfg.baozang_pool) do
				if v == n.index then
					local data = {}
					data.item_id = n.reward_item[0].item_id
					data.is_bind = n.reward_item[0].is_bind
					data.num = n.reward_item[0].num
					table.insert(data_list, data)
				end
			end
		end
	end

	MergeRewardList(data_list)
	return data_list
end

function WaBaoData:GetActiveDegree()
	self.now_total_degree = ZhiBaoData.Instance:GetActiveDegreeValue()
	return self.now_total_degree
end

function WaBaoData:GetNextActiveDegree()
	local bao_tu = self.wabao_cfg.baotu
	for k,v in ipairs(bao_tu) do
		if bao_tu[k] and bao_tu[k].total_degree > self.now_total_degree then
			return bao_tu[k].total_degree
		end
	end
	return false
end

function WaBaoData:GetMaxActiveDegree()
	return self.wabao_cfg.baotu[#self.wabao_cfg.baotu].total_degree
end

function WaBaoData:GetIsShowWaBao()
	if not OpenFunData.Instance:CheckIsHide("wabao") then return false end

	local cur_degree = ZhiBaoData.Instance:GetActiveDegreeValue()
	local max_degree = self.wabao_cfg.baotu[#self.wabao_cfg.baotu].total_degree
	if next(self.wabao_info) and self.wabao_info.baotu_count <= 0 and cur_degree >= max_degree then return false end

	return true
end

function WaBaoData:SetFastWaBaoFlag(flag)
	self.fast_wabao_flag = flag
end

function WaBaoData:GetFastWaBaoFlag()
	return self.fast_wabao_flag
end

function WaBaoData:SetWaBaoFlag(flag)
	self.wabao_flag = flag
end

function WaBaoData:GetWaBaoFlag()
	return self.wabao_flag
end