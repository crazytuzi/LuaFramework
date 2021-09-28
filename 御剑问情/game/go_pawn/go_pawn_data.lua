GoPawnData = GoPawnData or BaseClass()

GO_PAWN_MAX_STEP = 24
function GoPawnData:__init()
	if GoPawnData.Instance then
		print_error("[GoPawnData] Attemp to create a singleton twice !")
	end
	GoPawnData.Instance = self
	self.item_list = {}
	self.chess_info = {}
	self.chess_info.move_chess_free_times = 0
	self.chess_info.move_chess_reset_times = 0
	self.chess_info.move_chess_cur_step = 0
	self.chess_info.move_chess_next_free_time = 0
	-- self.chess_info.move_chess_shake_point = 0
	-- 摇骰子摇到点数
	self.shake_point = 0
	RemindManager.Instance:Register(RemindName.HuanJing_XunBao, BindTool.Bind(self.GetHuanJingXunBaoRemind, self))
end

function GoPawnData:__delete()
	RemindManager.Instance:UnRegister(RemindName.HuanJing_XunBao)
	
	GoPawnData.Instance = nil
end

--同步走棋子信息
function GoPawnData:OnMoveChessInfo(protocol)
	self.chess_info.move_chess_free_times = protocol.move_chess_free_times				--每日免费次数
	self.chess_info.move_chess_reset_times = protocol.move_chess_reset_times			--每日重置次数
	self.chess_info.move_chess_cur_step = protocol.move_chess_cur_step					--当前所处步数
	self.chess_info.move_chess_next_free_time = protocol.move_chess_next_free_time		--下一免费时间戳
	-- self.chess_info.move_chess_shake_point = protocol.move_chess_shake_point
end

function GoPawnData:GetMoveChessOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("movechess_auto").other
end

--同步每次摇骰得到的物品
function GoPawnData:OnMoveChessRewarInfo(protocol)
	self.item_list = protocol.item_list
end

function GoPawnData:GetGoPanwaaFlag()
	return self.go_pawn_flag
end

function GoPawnData:SetGoPanwaaFlag(go_pawn_flag)
	self.go_pawn_flag = go_pawn_flag
end

function GoPawnData:GetItemList()
	return self.item_list
end

function GoPawnData:GetChessInfo()
	return self.chess_info
end

-- 保存投到的骰子数
function GoPawnData:OnSaveShakePoint(protocol)
	self.shake_point = protocol.shake_point
end

function GoPawnData:GetShakePoint()
	return self.shake_point
end


--获得通过需要显示的物品信息集合
function GoPawnData:GetMissionCompeleteList()
	item_info_list = {}
	local cfg = self:GetMoveChessOtherCfg()[1]
	for k,v in pairs(cfg.end_step_reward) do 
		item_info_list[k + 1] = v
	end

	item_info_list[4] = cfg.item2
	return item_info_list
end

function GoPawnData:GetFreeCountCfg()
	return self:GetMoveChessOtherCfg()[1].free_times_per_day
end

function GoPawnData:GetOtherCfg()
	return self:GetMoveChessOtherCfg()[1]
end

function GoPawnData:GetHuanJingXunBaoRemind()
	return self:CheckRedPoint() and 1 or 0
end

function GoPawnData:CheckRedPoint()
	local cfg_free_count = self:GetOtherCfg().free_times_per_day
	if cfg_free_count - self.chess_info.move_chess_free_times > 0 then
		return true
	else
		return false
	end
end

function GoPawnData:GetHuoYueCfg()
	return ConfigManager.Instance:GetAutoConfig("activedegree_auto").reward[1].item
end

-- 获取特殊奖励物品
function GoPawnData:GetTeshuJiangliCfg(gird_index)
	local g_cfg = ConfigManager.Instance:GetAutoConfig("movechess_auto").special_reward_grid 
	if g_cfg then
		for k,v in pairs(g_cfg) do
			if gird_index == v.special_reward_grid then
				return v.reward[0]
			end
		end
	end
	return {}
end

-- 每一步奖励物品
function GoPawnData:SetStepReward(protocol)
	self.step_reward = protocol.reward_list
end

-- 获取每一步奖励物品
function GoPawnData:GetStepReward()
	return self.step_reward or {}
end

function GoPawnData:GetRewardListByStep(step)
	local reward_cfg = ConfigManager.Instance:GetAutoConfig("movechess_auto").other[1]
	local reward_list = {}
	if step == 24 then 
		for k,v in pairs(reward_cfg.end_step_reward) do
			table.insert(reward_list, v)
		end
    elseif step < 24 then
	    for k,v in pairs(reward_cfg.item3) do
	    	table.insert(reward_list, v)
	    end
	end
    return reward_list
end