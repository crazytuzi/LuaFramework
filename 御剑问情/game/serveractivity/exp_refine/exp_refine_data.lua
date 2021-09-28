ExpRefineData = ExpRefineData or BaseClass()

function ExpRefineData:__init()
	if ExpRefineData.Instance ~= nil then
		ErrorLog("[ExpRefineData] Attemp to create a singleton twice !")
	end
	ExpRefineData.Instance = self

	-- 经验炼制信息
	self.exp_refine_info = {
		refine_today_buy_time = 0,				-- 每日炼制次数
		refine_reward_gold = 0,					-- 总奖励金额
	}
	RemindManager.Instance:Register(RemindName.ExpRefine, BindTool.Bind(self.GetExpRefineRemind, self))
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig() or {}
	self.exp_refine_cfg = config.exp_refine or {}
end

function ExpRefineData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ExpRefine)

	ExpRefineData.Instance = nil
end

function ExpRefineData:SetRAExpRefineInfo(protocol)
	self.exp_refine_info.refine_today_buy_time = protocol.refine_today_buy_time
	self.exp_refine_info.refine_reward_gold = protocol.refine_reward_gold
end

function ExpRefineData:GetRAExpRefineInfo()
	return self.exp_refine_info
end

-- 该活动由开服第几天开就觉得在对应档位从第一天开始计算
function ExpRefineData:GetRAExpRefineCfg()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE)
	if nil == activity_info then
		return nil
	end

	--开服时间
	local real_start_time = TimeCtrl.Instance:GetServerRealStartTime()
	--活动开启时间
	local activity_open_time = activity_info.start_time

	local real_activity_open_time_tbl = TimeUtil.Format2TableDHM(activity_open_time - real_start_time)
	local activity_open_day_tbl = TimeUtil.Format2TableDHM(TimeCtrl.Instance:GetServerTime() - activity_open_time)

	--活动开启的天数相对于开服天数
	local real_activity_day_by_open_severday = real_activity_open_time_tbl.day + 1
	--活动开了几天
	local activity_start_day = activity_open_day_tbl.day				--由0开始算

	local temp_tbl = nil
	local next_vip = -1
	local next_count = 0
	for k, v in ipairs(self.exp_refine_cfg) do
		if temp_tbl and activity_start_day ~= v.activity_day then
			--表示表已构建完毕
			break
		end

		if v.openserver_day >= real_activity_day_by_open_severday and activity_start_day == v.activity_day then
			if v.vip_level_limit <= GameVoManager.Instance:GetMainRoleVo().vip_level then
				if temp_tbl == nil then
					temp_tbl = {}
				end
				table.insert(temp_tbl, v)
			elseif next_vip == -1 or next_vip == v.vip_level_limit then
				next_vip = v.vip_level_limit
				next_count = next_count + 1
			end
		end
	end
	return temp_tbl, next_vip, next_count
end

function ExpRefineData:GetRAExpRefineCfgMaxNum()
	local num = 0

	local exp_refine_cfg, next_vip, next_count = self:GetRAExpRefineCfg()
	if exp_refine_cfg then
		num = #exp_refine_cfg
	end
	return num, next_vip, next_count
end

function ExpRefineData:GetRAExpRefineCfgBySeq(seq)
	local exp_refine_cfg = self:GetRAExpRefineCfg()
	if exp_refine_cfg then
		for k,v in ipairs(exp_refine_cfg) do
			if v.seq == seq then
				return v
			end
		end
	end
end

-- 获取经验炼制活动是否还在开启中
function ExpRefineData:GetExpRefineIsOpen()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN then
		local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE)
		local level = PlayerData.Instance.role_vo.level
		if act_cfg and act_cfg.min_level <= level then
			return true
		end
	end
	return false
end

function ExpRefineData:GetExpRefineIsSoldOut()
	local exp_refine_info = self:GetRAExpRefineInfo()
	local buy_num = exp_refine_info.refine_today_buy_time
	local max_buy_num, next_vip, next_count = self:GetRAExpRefineCfgMaxNum()
	return buy_num < max_buy_num or next_vip > -1
end

function ExpRefineData:GetExpRefineBtnIsShow()
	return self:GetExpRefineIsOpen() and self:GetExpRefineIsSoldOut()
end

function ExpRefineData:GetExpRefineRemind()
	return self:GetExpRefineRedPoint() and 1 or 0
end

function ExpRefineData:GetExpRefineRedPoint()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status ~= ACTIVITY_STATUS.OPEN and self.exp_refine_info.refine_reward_gold > 0 then
		return true
	end
	return false
end