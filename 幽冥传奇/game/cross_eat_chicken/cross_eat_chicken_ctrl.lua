require("scripts/game/cross_eat_chicken/crosss_eat_chicken_data")
require("scripts/game/cross_eat_chicken/crosss_eat_chicken_view")
require("scripts/game/cross_eat_chicken/cross_eat_chicken_result_view")
require("scripts/game/cross_eat_chicken/cross_eat_chicken_progress_view")

CrossEatChickenCtrl = CrossEatChickenCtrl or BaseClass(BaseController)

function CrossEatChickenCtrl:__init()
	if CrossEatChickenCtrl.Instance then
		ErrorLog("[CrossEatChickenCtrl]:Attempt to create singleton twice!")
	end
	CrossEatChickenCtrl.Instance = self
	self.view = CrossEatChickenView.New(ViewName.CrossEatChicken)
	self.data = CrossEatChickenData.New()
	self.crosss_eat_chicken_result = CrossEatChickenResult.New(ViewName.CrossEatChickenResult)
	self.cross_eat_chicken_progress = CrossEatChickenProgress.New(ViewName.CrossEatChickenProgress)
	self:RegisterAllProtocols()
end

function CrossEatChickenCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.crosss_eat_chicken_result then
		self.crosss_eat_chicken_result:DeleteMe()
		self.crosss_eat_chicken_result = nil
	end

	if self.cross_eat_chicken_progress then
		self.cross_eat_chicken_progress:DeleteMe()
		self.cross_eat_chicken_progress = nil
	end


	CrossEatChickenCtrl.Instance = nil
end

function CrossEatChickenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossEatChickenRankInfoIss, "OnCrossEatChickenRankInfoIss")
	self:RegisterProtocol(SCCrossEatChickenEnrollStateIss, "OnCrossEatChickenEnrollStateIss")
	self:RegisterProtocol(SCCrossEatChickenDropRangeIss, "OnCrossEatChickenDropRangeIss")
	self:RegisterProtocol(SCCrossEatChickenFetchAwarIss, "OnCrossEatChickenFetchAwarIss")
	self:RegisterProtocol(SCCrossEatChickenMatchCntIss, "OnCrossEatChickenMatchCntIss")
	self:RegisterProtocol(SCEatChickenResultIss, "OnEatChickenResultIss")
	self:RegisterProtocol(SCEatChickenProgressIss, "OnEatChickenProgressIss")
end

-----------------------请求-----------------------
--请求信息
function CrossEatChickenCtrl.CrossEatChickenInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossEatChickenRankInfoReq)
	protocol:EncodeAndSend()
end

-- 报名
function CrossEatChickenCtrl.CrossEatChickeEnrollReq(join_operate)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossEatChickenJoinOperReq)
	protocol.join_operate = join_operate
	protocol:EncodeAndSend()
end

-- 设置降落点
function CrossEatChickenCtrl.CrossEatChickenSetDropRangeReq(drop_range_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossEatChickenSetDropRangeReq)
	protocol.drop_range_id = drop_range_id
	protocol:EncodeAndSend()
end

-- 领取奖励
function CrossEatChickenCtrl.CrossEatChickenGetAwardReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossEatChickenGetAwarReq)
	protocol:EncodeAndSend()
end

-----------------------下发-----------------------
-- 下发玩家吃鸡及排行榜信息
function CrossEatChickenCtrl:OnCrossEatChickenRankInfoIss(protocol)
	self.data:SetCrossEatChickenRankInfo(protocol)
	self.view:Flush(0, "all_info")
end

-- 下发报名信息
function CrossEatChickenCtrl:OnCrossEatChickenEnrollStateIss(protocol)
	self.data:SetEnrollInfo(protocol)
	self.view:Flush(0, "enroll", {key = "my_enroll_state"})
end

--  设置降落点
function CrossEatChickenCtrl:OnCrossEatChickenDropRangeIss(protocol)
	self.data:SetDropRange(protocol)
	self.view:Flush(0, "drop_range", {key = "my_drop_range"})
end

-- 下发领取信息
function CrossEatChickenCtrl:OnCrossEatChickenFetchAwarIss(protocol)
	self.data:SetRewardInfo(protocol)
	self.view:Flush(0, "award_fetch", {keys = {"my_rank", "my_score", "my_awar_state"}})
end

-- 匹配人数更新
function CrossEatChickenCtrl:OnCrossEatChickenMatchCntIss(protocol)
	self.data:SetMatchPlayerCnt(protocol)
	self.view:Flush(0, "match_player", {key = "cur_match_player_cnt"})
end

-- 下发战斗结果
function CrossEatChickenCtrl:OnEatChickenResultIss(protocol)
	self.crosss_eat_chicken_result:Open()
	self.crosss_eat_chicken_result:Flush(0, "result", {protocol.my_rank, protocol.kill_cnt, protocol.my_score,})
end

-- 通知过程
function CrossEatChickenCtrl:OnEatChickenProgressIss(protocol)
	if self.cross_eat_chicken_progress:IsOpen() == false then
		self.cross_eat_chicken_progress:Open()
	end
	self.cross_eat_chicken_progress:Flush(0, "progress", {protocol.kill_cnt, protocol.alive_cnt, protocol.range_id, protocol.rest_time, protocol.boss_refresh_time})
end

