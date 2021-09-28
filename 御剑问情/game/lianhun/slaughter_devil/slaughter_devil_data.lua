SlaughterDevilData = SlaughterDevilData or BaseClass()

function SlaughterDevilData:__init()
	SlaughterDevilData.Instance = self
	self.map_list = {}
	self.view_data = {}
	local list = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").fb_info
	local reward_list = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").star_reward
	self.info_list = ListToMap(list, "chapter", "level")
	self.reward_list = ListToMap(reward_list, "chapter", "seq")
	self.other = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").other[1]
	self.init_red = true
	RemindManager.Instance:Register(RemindName.SlaughterDevil, BindTool.Bind(self.GetRedPoint, self))

	self:InitViewData()
	self:InitDataList()
end

function SlaughterDevilData:__delete()
	RemindManager.Instance:UnRegister(RemindName.SlaughterDevil)
	SlaughterDevilData.Instance = nil
end

function SlaughterDevilData:InitDataList()
	self.max_chapter = 0
	for k,v in pairs(self.info_list) do
		self.map_list[k] = {}
		if k > self.max_chapter then
			self.max_chapter = k
		end
		for k1,v1 in pairs(v) do
			local data = self:InitData(v1)
			self.map_list[k][k1] = data
		end
	end
end

function SlaughterDevilData:CloseInitRed()
	self.init_red = false
end

function SlaughterDevilData:InitData(value)
	local data = {}
	-- data.fb_name = value.fb_name
	-- -- data.image = value.image
	-- data.first_pass_reward = value.first_pass_reward
	-- data.normal_reward_item = value.normal_reward_item
	-- data.chapter = value.chapter
	-- data.level = value.level

	data = TableCopy(value)

	data.star = 0
	data.is_open = false
	data.reward_flag = 0
	return data
end

function SlaughterDevilData:InitViewData()
	local data = self.view_data
	data.total_num = self.other.normal_free_join_times
	data.card_id = self.other.item_id
	data.cur_num = 0
	data.pass_level = 0
	data.reward_list = self.reward_list
	local title_cfg = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").title_cfg
	for i=0, 49 do
		data[i] = {}
		data[i].is_pass_chapter = 0
		data[i].total_star = 30
		data[i].cur_star = 0
		data[i].star_reward_flag = 0
		data[i].title_name = Language.Competition.NoRank
		if title_cfg[i + 1] then
			data[i].title_id = title_cfg[i + 1].title_id
		end
	end
	self.view_data = data
end

function SlaughterDevilData:GetMapList()
	return self.map_list
end

function SlaughterDevilData:GetMapListNum()
	if self.view_data.pass_chapter == self:GetMaxChapter() then
		return self.view_data.pass_chapter + 1
	end
	return self.view_data.pass_chapter + 2
end

function SlaughterDevilData:GetRewardListNum(index)
	return #self.view_data.reward_list[index] + 1
end

function SlaughterDevilData:GetRewardList(index)
	return self.view_data.reward_list[index]
end

function SlaughterDevilData:GetData(index)
	return self.map_list[index]
end

function SlaughterDevilData:GetViewData()
	return self.view_data
end

function SlaughterDevilData:SetFbInfo(protocol)
	self.get_info = true
	local protocol = protocol.fb_info_list[1]
	local data = self.view_data
	data.pass_chapter = protocol.pass_chapter
	data.pass_level = protocol.pass_level
	data.card_time = protocol.card_add_times
	data.cur_num = self.other.normal_free_join_times - protocol.today_join_times + protocol.buy_join_times + data.card_time
	data.buy_times = protocol.buy_join_times
	for k,v in pairs(protocol.chapter_info_list) do
		data[k].is_pass_chapter = v.is_pass_chapter
		data[k].cur_star = v.total_star
		data[k].star_reward_flag = bit:d2b(v.star_reward_flag)
		data[k].red = false
		if data.reward_list[k] then
			for k1,v1 in pairs(data.reward_list[k]) do
				if data[k].cur_star >= v1.star_num and data[k].star_reward_flag[32 - k1] == 0 then
					data[k].red = true
				end
			end
		end

		for k1, v1 in pairs(v.level_info_list) do
			if self.map_list[k] and self.map_list[k][k1] then
				if v1.pass_star ~= 0 and self.map_list[k][k1].star == 0 then
					self.map_list[k][k1].reward_flag = true
				else
					self.map_list[k][k1].reward_flag = false
				end
				if data.pass_chapter == k - 1 and data.pass_level == k1 - 1 then
					self.map_list[k][k1].is_cur_level = true
				else
					self.map_list[k][k1].is_cur_level = false
				end
				self.map_list[k][k1].star = v1.pass_star
				-- data[k].cur_star = data[k].cur_star + v1.pass_star
				local pass_num = (protocol.pass_chapter + 1) * 10 + protocol.pass_level + 1

				self.map_list[k][k1].is_open = k * 10 + k1 <= pass_num
			end
		end
	end
end

function SlaughterDevilData:GetInfo()
	return self.get_info
end

function SlaughterDevilData:SetResultInfo(protocol)
	
end

function SlaughterDevilData:SetSingleInfo(protocol)
	local data = self.view_data
	data.cur_num = self.other.normal_free_join_times - protocol.today_join_times + protocol.buy_join_times
	data.pass_chapter = protocol.chatper
	data.pass_level = protocol.level
	data.buy_times = protocol.buy_join_times
	data[protocol.chatper].cur_star = protocol.total_star
	data[protocol.chatper].star_reward_flag = bit:d2b(protocol.star_reward_flag)

	data[protocol.chatper].is_pass_chapter = protocol.cur_chapter >= protocol.chatper
	if protocol.layer_info.pass_star ~= 0 and self.map_list[protocol.chatper][protocol.level].star == 0 then
		self.map_list[protocol.chatper][protocol.level].reward_flag = true
	else
		self.map_list[protocol.chatper][protocol.level].reward_flag = false
	end
	self.map_list[protocol.chatper][protocol.level].star = protocol.layer_info.pass_star

end

function SlaughterDevilData:ShowStarReward(protocol)
	self.push_fb_fecth_star_reward_info = protocol
end

function SlaughterDevilData:GetPushFbFetchShowStarReward()
	local chapter = self.push_fb_fecth_star_reward_info.chapter
	local seq = self.push_fb_fecth_star_reward_info.seq

	local fecth_reward_list = {}
	local reward_cfg_list = self.view_data.reward_list

	for k,v in pairs(reward_cfg_list[chapter][seq].reward) do
		table.insert(fecth_reward_list, v)
	end

	return fecth_reward_list
end

function SlaughterDevilData:SetFBSceneLogicInfo(protocol)
	self.fb_scene_logic_info = protocol
end

function SlaughterDevilData:GetFBSceneLogicInfo()
	return self.fb_scene_logic_info
end

function SlaughterDevilData:StarCfgInfo(chapter, level)
	local cur_level_cfg = self.map_list[chapter][level]
	local star_info_cfg = {}
	for i = 1 , 3 do
		if cur_level_cfg["time_limit_" .. i .."_star"] then
			table.insert(star_info_cfg, cur_level_cfg["time_limit_" .. i .."_star"])
		end
	end
	return star_info_cfg
end

function SlaughterDevilData:GetRewardData(chapter,level)
	if self.map_list[chapter][level].reward_flag then
		return self.map_list[chapter][level].first_pass_reward
	else
		return self.map_list[chapter][level].normal_reward_item
	end
end

function SlaughterDevilData:GetMaxLevel()
	return 9
end

function SlaughterDevilData:GetMaxChapter()
	return self.max_chapter
end

function SlaughterDevilData:GetBuyCost()
	local buy_cost_cfg = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").times_buy
	local cost = buy_cost_cfg[1].cost_gold
	for i,v in ipairs(buy_cost_cfg) do
		cost = v.cost_gold
		if self.view_data.buy_times + 1 <= v.buy_times_min then
			return cost
		end
	end
	return cost
end

function SlaughterDevilData:SetTitleData(protocol)
	for k,v in pairs(protocol.names) do
		if self.view_data[k] then
			self.view_data[k].title_name = v
		end
	end
end

function SlaughterDevilData:CheckAdd(vip_level)
	local vip_cfg = VipData.Instance:GetVipLevelCfg()
	if vip_cfg then
		local auth_config = vip_cfg[VIPPOWER.PUSH_COMMON]
		if auth_config then
			if self.view_data.buy_times >= auth_config["param_" .. vip_level] then
				return false
			else
				return true
			end
		end
	end
	return true
end

function SlaughterDevilData:GetRedPoint()
	local flag = OpenFunData.Instance:CheckIsHide("lianhunview")
	if flag == false then
		return 0
	end
	if self.view_data.cur_num > 0 then
		if self.init_red then
			return 1
		end
	end
	for i = 0, 49 do
		if self.view_data[i].red then
			return 1
		end
	end
	return 0
end

function SlaughterDevilData:GetMaxCount()
	local vip_cfg = VipData.Instance:GetVipLevelCfg()
	if vip_cfg then
		local auth_config = vip_cfg[VIPPOWER.PUSH_COMMON]
		return auth_config["param_15"]
	end
	return 999
end

function SlaughterDevilData:GetBuyCount()
	return self.view_data.buy_times
end

function SlaughterDevilData:SetResultInfo(protocol)
	self.result_data = protocol
end

function SlaughterDevilData:GetResultData()
	return self.result_data
end