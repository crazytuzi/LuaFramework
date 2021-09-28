LongXingData = LongXingData or BaseClass()

function LongXingData:__init()
	if LongXingData.Instance then
		print_error("[LongXingData] Attempt to create singleton twice!")
		return
	end
	LongXingData.Instance = self


	-- 配置表数据
	-- local molong_cfg = ConfigManager.Instance:GetAutoConfig("molong_auto")
	-- self.molong_reward_cfg = ListToMap(molong_cfg.reward,"grid")
	-- self.molong_move_cfg = ListToMap(molong_cfg.move,"step")
	-- self.molong_rank_cfg = ListToMap(molong_cfg.rank,"grade")

	self.protocol_info = {}

	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind(self.SceneLoadComplete, self))

	RemindManager.Instance:Register(RemindName.LongXingRemind, BindTool.Bind(self.GetLongXingRemind, self))
end

function LongXingData:__delete()
	LongXingData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.LongXingRemind)
	if self.scene_load_complete then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	self.protocol_info = {}

end

function LongXingData:SceneLoadComplete()
	self:SetMoLongRank(self.protocol_info.rank_grade or 0)
end

function LongXingData:SetSCMolongInfo(protocol)
	self.protocol_info.accumulate_consume_gold  = protocol.info.accumulate_consume_gold
	self.protocol_info.today_consume_gold  = protocol.info.today_consume_gold
	self.protocol_info.today_move_step = protocol.info.today_move_step
	self.protocol_info.total_move_step = protocol.info.total_move_step
	self.protocol_info.curr_loop = protocol.info.curr_loop

	self.protocol_info.rank_grade = protocol.info.rank_grade
	self.protocol_info.rank_cumulate_gold = protocol.info.rank_cumulate_gold

	-- print_log(">>>>>>>>>>>",self.protocol_info)
end

function LongXingData:GetSCMolongInfo()
	return self.protocol_info
end

function LongXingData:GetRewardListByGrid(grid)
	local molong_cfg = ConfigManager.Instance:GetAutoConfig("molong_auto")
	for k,v in pairs(molong_cfg.reward) do
		if v.grid == grid then
			return v
		end
	end
	-- return self.molong_reward_cfg[grid]
end

function LongXingData:GetMoveByStep(step)
	local molong_cfg = ConfigManager.Instance:GetAutoConfig("molong_auto")
	for k,v in pairs(molong_cfg.move) do
		if v.step == step then
			return v
		end
	end
	-- return self.molong_move_cfg[step]
end

function LongXingData:GetMoveMaxStep()
	local molong_cfg = ConfigManager.Instance:GetAutoConfig("molong_auto")
	return #molong_cfg.reward
end

function LongXingData:GetRankByGrade(grade)
	local molong_cfg = ConfigManager.Instance:GetAutoConfig("molong_auto")
	for k,v in pairs(molong_cfg.rank) do
		if v.grade == grade then
			return v
		end
	end
	-- return self.molong_rank_cfg[grade]
end

function LongXingData:GetTodayMoveStep()
	return self.protocol_info.today_move_step
end

function LongXingData:GetTotalMoveStep()
	return self.protocol_info.total_move_step
end

function LongXingData:GetCurrloop()
	return self.protocol_info.curr_loop or 0
end

function LongXingData:IsFinishLongXing()
	return self:GetCurrloop() > 1
end

function LongXingData:GetRankMaxGrade()
	local molong_cfg = ConfigManager.Instance:GetAutoConfig("molong_auto")
	-- return self:GetRankByGrade(molong_cfg.rank[#molong_cfg.rank-1]).grade
	return molong_cfg.rank[#molong_cfg.rank].grade
end

function LongXingData:GetMaxReward()
	local molong_cfg = ConfigManager.Instance:GetAutoConfig("molong_auto")
	return self:GetRewardListByGrid(#molong_cfg.reward)
end

function LongXingData:SetMoLongRank(rank)
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:SetAttr("molong_rank", rank)
	end
end

--红点提示
function LongXingData:GetLongXingRemind()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local remind_day = UnityEngine.PlayerPrefs.GetInt(main_role_id .. "longxing_remind_day") or cur_day
	if cur_day ~= -1 and cur_day ~= remind_day then
		self.flag = 1
		return 1
	end
	-- return self.flag

	-- local rank_cfg = self:GetRankByGrade(self.protocol_info.rank_grade)
	-- if rank_cfg == nil then return end
	-- if self.protocol_info.rank_cumulate_gold >= rank_cfg.cumulate_gold and self.protocol_info.rank_grade < self:GetRankMaxGrade() then
	-- 	return 1
	-- else
	-- 	return 0
	-- end
end

--主界面红点刷新
function LongXingData:FlushHallRedPoindRemind()
	local remind_num = self:GetLongXingRemind() or 0
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.FUNC_TYPE_LONGXING, remind_num > 0)
end