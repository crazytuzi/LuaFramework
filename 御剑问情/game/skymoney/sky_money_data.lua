SkyMoneyData = SkyMoneyData or BaseClass()

SkyMoneyDataId = {
	Id = 20
}

function SkyMoneyData:__init()
	if SkyMoneyData.Instance ~= nil then
		print_error("[SkyMoneyData] Attemp to create a singleton twice !")
		return
	end
	SkyMoneyData.Instance = self

	self.sky_money_info = {
		big_money_flush_time = 0,
		small_money_flush_time = 0,
		cur_qianduoduo_num = 0,
		cur_bigqianduoduo_num = 0,
		get_total_shengwang = 0,
		is_finish = 0,
		curr_task_id = 0,
		curr_task_param = 0,
		has_finish_task_num = 0,
		item_info_list = {},
	}
	self.sky_money_reward_list = {}
end

function SkyMoneyData:__delete()
	self.sky_money_info = {}
	self.sky_money_reward_list = {}
	SkyMoneyData.Instance = nil
end

-- 通过seq获取阶段任务奖励
function SkyMoneyData:GetTaskRewardByCurTaskNum(cur_task_num)
	local cfg = ConfigManager.Instance:GetAutoConfig("activitytianjiangcaibao_auto")
	for k, v in pairs(cfg.task_reward) do
		if cur_task_num >= GameEnum.TIANJIANGCAIBAO_TASK_MAX and v.complete_task_num == cur_task_num then
			return v
		end
		if cur_task_num < v.complete_task_num then
			return v
		end
	end

	return {}
end

function SkyMoneyData:SetSkyMoneyInfo(protocol)
	self.sky_money_info = protocol
end

function SkyMoneyData:GetSkyMoneyInfo()
	return self.sky_money_info
end

function SkyMoneyData:GetSkyMoneyCfg()
	return ConfigManager.Instance:GetAutoConfig("activitytianjiangcaibao_auto")
end

function SkyMoneyData:GetSkyMoneyTaskCfgById(id)
	return ConfigManager.Instance:GetAutoConfig("activitytianjiangcaibao_auto").task_list[id]
end

function SkyMoneyData:SetSkyMoneyItemList()
	for k, v in pairs(self.sky_money_info.item_info_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			self.sky_money_reward_list[k + 1] = v
		end
	end
end

function SkyMoneyData:GetSkyMoneyItemList()
	return self.sky_money_reward_list
end

function SkyMoneyData:GetSkyMoneyGoldNum()
	return self.sky_money_info.get_total_shengwang
end

function SkyMoneyData:CloseCallBack()
	self.sky_money_info.get_total_shengwang = 0
	self.sky_money_reward_list = {}
end

function SkyMoneyData:GetQianDuoDuoId(is_big)
	local cfg = self:GetSkyMoneyCfg()
	if not cfg then return 0 end

	if not is_big then
		return cfg.qianduoduo[1].qingduoduo_id
	else
		return cfg.big_qianduoduo[1].bigqian_id
	end
end

function SkyMoneyData:GetQianDuoDuoMaxNum()
	local cfg = self:GetSkyMoneyCfg()
	if not cfg then return 0 end

	return cfg.qianduoduo[1].count
end

function SkyMoneyData:GetSceneGatherCanGath(gather_id, x, y)
	if not gather_id or not x or not y then return false end

	for k, v in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id then
			local pos_x, pos_y = v:GetLogicPos()
			if x == pos_y and y == pos_y then
				return true
			end
		end
	end
	return false
end

function SkyMoneyData:GetSceneGatherListById(gather_id)
	local gather_list = {}
	if not gather_id then return gather_list end

	for k, v in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id then
			local pos_x, pos_y = v:GetLogicPos()
			gather_list[#gather_list + 1] = {x = pos_x, y = pos_y, id = v:GetGatherId(), obj_id = v:GetObjKey()}
		end
	end
	return gather_list
end

function SkyMoneyData:GetRewardExp()
	local level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local data = {item_id = ResPath.CurrencyToIconId.exp, num = 0}
	for k, v in pairs(self:GetSkyMoneyCfg().task_exp_reward) do
		if v.level == level then
			data.num = v.exp_reward
			break
		end
	end
	return data
end