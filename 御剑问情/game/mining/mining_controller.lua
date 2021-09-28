require("game/mining/mining_view")
require("game/mining/mining_record_list_view")
require("game/mining/mining_selected_view")
require("game/mining/sea_selected_view")
require("game/mining/mining_target_view")
require("game/mining/mining_rank_list_view")
require("game/mining/sea_reward_view")
require("game/mining/mining_reward_view")
require("game/mining/mining_data")
require("game/mining/mining_fight")

-- 运镖
MiningController = MiningController or BaseClass(BaseController)

function MiningController:__init()
	if MiningController.Instance ~= nil then
		print_error("[MiningController] attempt to create singleton twice!")
		return
	end
	MiningController.Instance = self

	self.view = MiningView.New(ViewName.MiningView)
	self.data = MiningData.New()
	self.fight_view = MiningFight.New()
	self.mining_record_list_view = MiningRecordListView.New(ViewName.MiningRecordListView)
	self.mining_target_view = MiningTargetView.New(ViewName.MiningTargetView)

	self.mining_selected_view = MiningSelectedView.New(ViewName.MiningSelectedView)
	self.mining_reward_view = MiningRewardView.New(ViewName.MiningRewardView)

	self.sea_selected_view = SeaSelectedView.New(ViewName.SeaSelectedView)
	self.sea_reward_view = SeaRewardView.New(ViewName.SeaRewardView)

	self.mining_rank_list_view = MiningRankListView.New()
	self:RegisterAllProtocols()

	self.can_move = false
end

function MiningController:__delete()
	self:RemoveCountDown()
	MiningController.Instance = nil

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.mining_record_list_view then
		self.mining_record_list_view:DeleteMe()
		self.mining_record_list_view = nil
	end

	if nil ~= self.mining_selected_view then
		self.mining_selected_view:DeleteMe()
		self.mining_selected_view = nil
	end

	if nil ~= self.mining_target_view then
		self.mining_target_view:DeleteMe()
		self.mining_target_view = nil
	end

	if nil ~= self.mining_rank_list_view then
		self.mining_rank_list_view:DeleteMe()
		self.mining_rank_list_view = nil
	end

	if nil ~= self.sea_reward_view then
		self.sea_reward_view:DeleteMe()
		self.sea_reward_view = nil
	end

	if nil ~= self.mining_reward_view then
		self.mining_reward_view:DeleteMe()
		self.mining_reward_view = nil
	end

	if nil ~= self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	if nil ~= self.sea_selected_view then
		self.sea_selected_view:DeleteMe()
		self.sea_selected_view = nil
	end

	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function MiningController:RegisterAllProtocols()
	self:RegisterProtocol(SCFightingMiningBaseInfo, "OnSCFightingMiningBaseInfo")
	self:RegisterProtocol(SCFightingMiningList, "OnSCFightingMiningList")
	self:RegisterProtocol(SCFightingMiningBeenRobList, "OnFetchFightingMiningBeenRobList")

	self:RegisterProtocol(SCFightingSailingBaseInfo, "OnSCFightingSailingBaseInfo")
	self:RegisterProtocol(SCFightingSailingList, "OnSCFightingSailingList")
	self:RegisterProtocol(SCFightingSailingBeenRobList, "OnSCFightingSailingBeenRobList")

	self:RegisterProtocol(SCFightingResultNotify, "OnSCFightingResultNotify")
	self:RegisterProtocol(SCFightingBeenRobNotify, "OnSCFightingBeenRobNotify")
	self:RegisterProtocol(SCFightingRobingNotify, "OnSCFightingRobingNotify")

	self:RegisterProtocol(CSFightingMiningReq)
	self:RegisterProtocol(SCFightingChallengeBaseInfo, "OnSCFightingChallengeBaseInfo")
	self:RegisterProtocol(SCFightingChallengeList, "OnSCFightingChallengeList")
	self:RegisterProtocol(SCFightingCountDownNotify, "OnSCFightingCountDownNotify")
end


function MiningController:Open(tab_index, param_t)
	self.view:Open(tab_index)
	-- RemindManager.Instance:Fire(RemindName.MiningMine)
	-- RemindManager.Instance:Fire(RemindName.MiningSea)
end

function MiningController:Close()
	self.view:Close()
end

-- 进入战斗时调用
function MiningController:InitFight()
	self.fight_view:Open()
end

-- 进入战斗时调用
function MiningController:StartFight()
	if self.fight_view:IsOpen() then
		self.fight_view:StartFight()
	end
end

function MiningController:CloseFightView()
	if self.fight_view then
		self.fight_view:CloseAllView()
		self.fight_view:Close()
	end
end

function MiningController:SetCanMove(is_move)
	self.can_move = is_move
end

function MiningController:GetCanMove()
	return self.can_move
end

function MiningController:OnSCFightingCountDownNotify(protocol)
	self.data:SetMiningFightStartTime(protocol)
	self.view:Flush()
end

function MiningController:OpenMiningRecordListView(index)
	if index == MINING_VIEW_TYPE.MINE then
		MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_M_BEEN_ROB_INFO)
	elseif index == MINING_VIEW_TYPE.SEA then
		MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_SEA_BEEN_ROB_INFO)
	end

	self.mining_record_list_view:SetViewType(index)
	self.mining_record_list_view:Open()
end

function MiningController:OpenMiningSelectedView()
	self.mining_selected_view:Open()
end

function MiningController:OpenSeaSelectedView()
	self.sea_selected_view:Open()
end

function MiningController:OnSCFightingChallengeBaseInfo(protocol)
	self.data:SetFightingChallengeBaseInfo(protocol)
	self.view:Flush()

	RemindManager.Instance:Fire(RemindName.MiningChallenge)
end

function MiningController:OnSCFightingChallengeList(protocol)
	self.data:SetChallengeRoleInfo(protocol.opponent_list)
	self.view:Flush()

	-- RemindManager.Instance:Fire(RemindName.MiningChallenge)
end

-- -- 购买次数
-- function MiningController:SendHusongBuyTimes()
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSHusongBuyTimes)
-- 	protocol:EncodeAndSend()
-- end
function MiningController:OpenMiningTargetView(view_type, index, data)
	if view_type == nil or index == nil then return end
	self.mining_target_view:SetIndexAndType(view_type, index)
	self.mining_target_view:SetViewData(data)
	self.mining_target_view:Open()
end

function MiningController:OpenMiningRewardView()
	self.mining_reward_view:Open()
end

function MiningController:CloseMiningRewardView()
	if self.mining_reward_view:IsOpen() then
		self.mining_reward_view:Close()
	end
end

function MiningController:OpenSeaRewardView()
	self.sea_reward_view:Open()
end

function MiningController:CloseSeaRewardView()
	if self.sea_reward_view:IsOpen() then
		self.sea_reward_view:Close()
	end
end

-- 挖矿请求
function MiningController:SendCSFightingMiningReq(req_type, param1, param2)
	if req_type == nil then
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSFightingMiningReq)
	protocol.req_type = req_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

-- 挖矿基础信息
function MiningController:OnSCFightingMiningBaseInfo(protocol)
	self.data:SetMiningMineInfo(protocol)
	self.data:CheckRedPoint()
	self.data:UpdateMiningMineRobCan()
	self.data:CheckRedRecordPoint(MINING_VIEW_TYPE.MINE)

	if self.view:IsOpen() then
		self.view:Flush()
	end
	if self.mining_selected_view:IsOpen() then
		self.mining_selected_view:Flush()
	end

	if protocol.mining_end_time > 0 then
		if self.mining_reward_view:IsOpen() then
			self.mining_reward_view:Flush()
		end
		if self.mining_selected_view:IsOpen() then
			self.mining_selected_view:Close()
		end
	else
		self:CloseMiningRewardView()
	end
end

-- 挖矿基础信息
function MiningController:OnSCFightingSailingBaseInfo(protocol)
	self.data:SetMiningSeaInfo(protocol)
	self.data:CheckRedPoint()
	self.data:UpdateMiningSeaRobCan()
	self.data:CheckRedRecordPoint(MINING_VIEW_TYPE.SEA)

	if self.view:IsOpen() then
		self.view:Flush()
	end
	if self.sea_selected_view:IsOpen() then
		self.sea_selected_view:Flush()
	end

	if protocol.mining_end_time > 0 then
		if self.sea_reward_view:IsOpen() then
			self.sea_reward_view:Flush()
		end
		if self.sea_selected_view:IsOpen() then
			self.sea_selected_view:Close()
		end
	else
		self:CloseSeaRewardView()
	end
end

-- 矿列表
function MiningController:OnSCFightingMiningList(protocol)
	self.data:SetMiningMineList(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 航行列表
function MiningController:OnSCFightingSailingList(protocol)
	self.data:SetMiningSeaList(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 矿记录列表
function MiningController:OnFetchFightingMiningBeenRobList(protocol)
	self.data:SetMiningBeenRobList(protocol)
	self.data:SetFightingBeenRobNo(MINING_VIEW_TYPE.MINE)
	if self.mining_record_list_view:IsOpen() then
		self.mining_record_list_view:Flush()
	end
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 航行记录列表
function MiningController:OnSCFightingSailingBeenRobList(protocol)
	self.data:SetMiningSeaBeenRobList(protocol)
	self.data:SetFightingBeenRobNo(MINING_VIEW_TYPE.SEA)
	if self.mining_record_list_view:IsOpen() then
		self.mining_record_list_view:Flush()
	end
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function MiningController:OpenChallengeRankView()
	self.mining_rank_list_view:Open()
end

function MiningController:FlsuhChallengeRankView()
	if self.mining_rank_list_view:IsOpen() then
		self.mining_rank_list_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 战斗结果通知
function MiningController:OnSCFightingResultNotify(protocol)
	self.data:SetFightingResultNotify(protocol)
	if protocol.is_win == 1 then
		if not self.win_timer_quest then
			local call_back = function ()
				self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
					local info_data = self.data:GetFightingResultNotify()
					local exp = CommonDataManager.ConverNum(info_data.show_item_list[1].num)
					local data_list= {string.format(Language.FB.GetExp, exp), {item_id = ResPath.CurrencyToIconId.exp or 0,num = 0,is_bind = 0}}
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "expfinish", {data = data_list})
				end, 2)
			end
			TimeScaleService.StartTimeScale(call_back)
		end
	else
		GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.FBFailFinishView)
		end, 2)
	end
end

function MiningController:RemoveCountDown()
	if self.win_timer_quest then
		GlobalTimerQuest:CancelQuest(self.win_timer_quest)
		self.win_timer_quest = nil
	end
end

-- 挖矿，航海-有新的抢夺记录（发送给被掠夺玩家本人，没查看之前一直有提示，重新登录也一样）
function MiningController:OnSCFightingBeenRobNotify(protocol)
	self.data:SetFightingBeenRobNotify(protocol)
	if self.view:IsOpen() then
		self.view:Flush("record_red")
	end
end

-- 挖矿，航海-有新的抢夺记录（广播给所有人，只在抢夺时发一次）
function MiningController:OnSCFightingRobingNotify(protocol)
	self.data:SetSCFightingRobingNotify(protocol)
	if self.view:IsOpen() then
		self.view:Flush("record_list")
	end
end

function MiningController:CloseAllView()
	if self.view:IsOpen() then
		self.view:Close()
	end
	-- if self.mining_record_list_view:IsOpen() then
	-- 	self.mining_record_list_view:Close()
	-- end
	if self.mining_target_view:IsOpen() then
		self.mining_target_view:Close()
	end
	-- if self.mining_selected_view:IsOpen() then
	-- 	self.mining_selected_view:Close()
	-- end
	-- if self.mining_reward_view:IsOpen() then
	-- 	self.mining_reward_view:Close()
	-- end
	-- if self.sea_selected_view:IsOpen() then
	-- 	self.sea_selected_view:Close()
	-- end
	-- if self.sea_reward_view:IsOpen() then
	-- 	self.sea_reward_view:Close()
	-- end
	-- if self.mining_rank_list_view:IsOpen() then
	-- 	self.mining_rank_list_view:Close()
	-- end
end