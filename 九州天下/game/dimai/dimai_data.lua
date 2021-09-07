DiMaiData = DiMaiData or BaseClass()

-- 地脉类型的地脉数
DiMaiData.SceneCount = {
	RenMai = 9,
	LingMai = 6,
	DiMai = 6,
	TianMai = 5,
	ShengMai = 3,
	ShenMai = 1,
}
-- 地脉buff类型
DiMaiData.DiMai_Buff_Type = {
	Role = 0,
	Camp = 1,
}

function DiMaiData:__init()
	if DiMaiData.Instance then
		return print_error("[DiMaiData] attempt to create singleton twice!")
	end
	DiMaiData.Instance = self

	--地脉配置
	self.dimai_cfg = nil
	self.dimai_other_cfg = self:GetDiMaiCfg().other[1]
	self.dimai_reward_cfg = self:GetDiMaiCfg().challenge_reward										-- 地脉挑战奖励
	self.dimai_info_cfg = ListToMap(self:GetDiMaiCfg().dimai, "layer", "point")						-- 地脉副本信息
	self.dimai_role_buff_cfg = ListToMap(self:GetDiMaiCfg().role_buff_reward, "layer", "point")		-- 地脉个人Buff信息
	self.dimai_camp_buff_cfg = ListToMap(self:GetDiMaiCfg().camp_buff_reward, "layer", "point")		-- 地脉国家Buff信息
	self.dimai_buy_times_cfg = ListToMap(self:GetDiMaiCfg().buy_times, "seq")						-- 地脉购买挑战信息

		-- 地脉副本信息
	self.fb_dimai_info = {
		layer = 0,
		point = 0,
		is_win = 0,
		is_finish = 0,
	}

	-- 玩家地脉信息
	self.role_dimai_info = {
		dimai_info = {},
		dimai_buy_times = 0,
		dimai_challenge_reward_fetch_flag = 0,
		camp_dimai_list = {},
	}

	-- 一层地脉信息
	self.layer_dimai_info = {
		layer = 0,
		item_list = {},
	}

	-- 单个地脉信息
	self.single_dimai_info = {
		is_challenging = 0,
		dimai_info = {},
	}


	RemindManager.Instance:Register(RemindName.DiMaiTask, BindTool.Bind(self.GetIsHasChallengeTimes, self))
end

function DiMaiData:__delete()
	DiMaiData.Instance = nil

	RemindManager.Instance:UnRegister(RemindName.DiMaiTask)
end

--------------------------配置------------------------------

function DiMaiData:GetDiMaiCfg()
	if not self.dimai_cfg then
		self.dimai_cfg = ConfigManager.Instance:GetAutoConfig("qiangdimai_auto")
	end
	return self.dimai_cfg
end

function DiMaiData:GetDiMaiOtherCfg()
	return self.dimai_other_cfg
end

-- 地脉任务奖励信息
function DiMaiData:GetDiMaiRewardCfg()
	return self.dimai_reward_cfg
end

-- 地脉详细信息
function DiMaiData:GetDiMaiInfoCfg(layer, point)
	if layer ~= nil and point ~= nil then
		if self.dimai_info_cfg[layer] ~= nil then
			return self.dimai_info_cfg[layer][point]
		end
	end
	return nil
end

-- 个人buff信息
function DiMaiData:GetDiMaiRoleBuffCfg(layer, point)
	if layer ~= nil and point ~= nil then
		if self.dimai_role_buff_cfg[layer] ~= nil then
			return self.dimai_role_buff_cfg[layer][point]
		end
	end
	return nil
end

-- 国家buff信息
function DiMaiData:GetDiMaiCampBuffCfg(layer, point)
	if layer ~= nil and point ~= nil then
		if self.dimai_camp_buff_cfg[layer] ~= nil then
			return self.dimai_camp_buff_cfg[layer][point]
		end
	end
	return nil
end

-- 购买挑战次数信息
function DiMaiData:GetDiMaiBuyTimesCfg(seq)
	if seq ~= nil then
		if self.dimai_buy_times_cfg[seq] ~= nil then
			return self.dimai_buy_times_cfg[seq]
		end
	end
	return nil
end

-------------------------------协议-------------------------------------

-- 地脉副本信息
function DiMaiData:SetFBDimaiInfo(protocol)
	self.fb_dimai_info.layer = protocol.layer
	self.fb_dimai_info.point = protocol.point
	self.fb_dimai_info.is_win = protocol.is_win
	self.fb_dimai_info.is_finish = protocol.is_finish
end

function DiMaiData:GetFBDimaiInfo()
	return self.fb_dimai_info
end

-- 玩家地脉信息
function DiMaiData:SetRoleDimaiInfo(protocol)
	self.role_dimai_info.dimai_info = protocol.dimai_info
	self.role_dimai_info.dimai_buy_times = protocol.dimai_buy_times
	self.role_dimai_info.dimai_challenge_reward_fetch_flag = protocol.dimai_challenge_reward_fetch_flag
	self.role_dimai_info.camp_dimai_list = protocol.camp_dimai_list
end

function DiMaiData:GetRoleDimaiInfo()
	return self.role_dimai_info
end

-- 一层地脉信息
function DiMaiData:SetLayerDimaiInfo(protocol)
	self.layer_dimai_info.layer = protocol.layer
	self.layer_dimai_info.item_list = protocol.item_list
end

function DiMaiData:GetLayerDimaiInfo()
	return self.layer_dimai_info
end

-- 单个地脉信息
function DiMaiData:SetSingleDimaiInfo(protocol)
	self.single_dimai_info.is_challenging = protocol.is_challenging
	self.single_dimai_info.dimai_info = protocol.dimai_info
end

function DiMaiData:GetSingleDimaiInfo()
	return self.single_dimai_info
end

-- 通过角色ID查找所占的地脉所在层 -1为未占地脉
function DiMaiData:GetRoleLayerByRoleID(role_id)
	local camp_dimai_list = self:GetRoleDimaiInfo().camp_dimai_list
	for k, v in pairs(camp_dimai_list) do
		if v.uid == role_id then
			return v.layer
		end
	end
	return -1
end

-------------------------------------其他------------------------------------

-- 地脉每日挑战次数
function DiMaiData:SetDiMaiChallengeCount(count)
	self.dimai_challenge_count = count or 0
end

function DiMaiData:GetDiMaiChallengeCount()
	return self.dimai_challenge_count or 0
end

-- 判断标记是否得到了奖励
function DiMaiData:IsGetRewardByIndex(index)
	if self:GetRoleDimaiInfo().dimai_challenge_reward_fetch_flag then
    	local bit_list = bit:d2b(self:GetRoleDimaiInfo().dimai_challenge_reward_fetch_flag)
    	for k, v in pairs(bit_list) do
        	if v == 1 and (32 - k) == index then
            	return true
        	end
    	end
    end
    return false
end

-- 得到排序奖励信息
function DiMaiData:SortRewardList()
	local reward_cfg = self:GetDiMaiRewardCfg()
	if reward_cfg then
		local new_list = {}
		local list = TableCopy(reward_cfg)
		for k, v in pairs(list) do
			if v.seq then
				v.flag = self:IsGetRewardByIndex(v.seq) and 1 or 0
				table.insert(new_list, v)
			end
		end
		if next(new_list) then
			SortTools.SortAsc(new_list, "flag", "seq")
		end
		return new_list
	end
	return nil
end

-- 有可以领取的奖励
function DiMaiData:GetIsHasReward()
	local reward_cfg = self:GetDiMaiRewardCfg()
	local day_count = self:GetDiMaiChallengeCount()
	if reward_cfg and day_count then
		for k, v in pairs(reward_cfg) do
			if day_count >= v.challenge_times then
				if not self:IsGetRewardByIndex(v.seq) then
					return true
				end
			end
		end
	end
	return false
end

-- 是否得到所有奖励
function DiMaiData:GetIsAllReward()
	local reward_cfg = self:GetDiMaiRewardCfg()
	if reward_cfg then
		for k, v in pairs(reward_cfg) do
			if not self:IsGetRewardByIndex(v.seq) then
				return false
			end
		end
	end
	return true
end

-- 有挑战次数
function DiMaiData:GetIsHasChallengeTimes()
	if not OpenFunData.Instance:CheckIsHide("dimai") then
		return 0
	end

	if self:GetIsAllReward() then
		return 0
	end
	if self:GetIsHasReward() then
		return 1
	end
	
	if ClickOnceRemindList[RemindName.DiMaiTask] and ClickOnceRemindList[RemindName.DiMaiTask] == 1 then
		local other_cfg = self:GetDiMaiOtherCfg()
		local day_count = self:GetDiMaiChallengeCount()
		local role_dimai_info = self:GetRoleDimaiInfo()
		if other_cfg and day_count and role_dimai_info then
			local challenge_times = other_cfg.challenge_times_limit + role_dimai_info.dimai_buy_times - day_count
			if challenge_times and challenge_times > 0 then
				return 1
			end
		end
	end
	return 0
end

function DiMaiData:SetDiMaiLayer(index)
	self.cur_index = index or 0
end

function DiMaiData:GetDiMaiLayer()
	return self.cur_index or 0
end