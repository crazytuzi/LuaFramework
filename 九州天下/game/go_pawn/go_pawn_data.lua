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
	self.chess_info.move_chess_shake_point = 0
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
	self.chess_info.move_chess_shake_point = protocol.move_chess_shake_point
end

function GoPawnData:GetMoveChessOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("movechess_auto").other
end

--同步每次摇骰得到的物品
function GoPawnData:OnMoveChessRewarInfo(protocol)
	self.item_list = protocol.item_list
end

function GoPawnData:GetItemList()
	return self.item_list
end

function GoPawnData:GetChessInfo()
	return self.chess_info
end

--获得通过需要显示的物品信息集合
function GoPawnData:GetMissionCompeleteList()
	item_info_list = {}
	local cfg = self:GetMoveChessOtherCfg()[1]
	item_info_list[1] = cfg.item2
	item_info_list[2] = cfg.item3
	item_info_list[3] = cfg.item4
	item_info_list[4] = cfg.item5
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


