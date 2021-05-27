require("scripts/game/crossserver/crossserver_match_data")
require("scripts/game/crossserver/crossserver_match_view")
require("scripts/game/crossserver/crossserver_match_result_page")

CrossServerMatchCtrl = CrossServerMatchCtrl or BaseClass(BaseController)

function CrossServerMatchCtrl:__init()
	if CrossServerMatchCtrl.Instance then
		ErrorLog("[CrossServerMatchCtrl]:Attempt to create singleton twice!")
	end
	CrossServerMatchCtrl.Instance = self
	self.view = CrossServerMatchView.New(ViewName.CrossServerMatch)
	self.data = CrossServerMatchData.New()
	self.crossserver_result = CrossServerMatchResultPage.New(ViewName.CrossServerMatchResult)
	self:RegisterAllProtocols()
end

function CrossServerMatchCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil


	self.data:DeleteMe()
	self.data = nil

	if self.crossserver_result then
		self.crossserver_result:DeleteMe()
		self.crossserver_result = nil
	end

	CrossServerMatchCtrl.Instance = nil
end

function CrossServerMatchCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossServerMatchInfo, "OnCrossServerMatchInfo")
	self:RegisterProtocol(SCCrossServerEnrollState, "OnCrossServerEnrollState")
	self:RegisterProtocol(SCCrossServerRewardInfo, "OnCrossServerRewardInfo")
	self:RegisterProtocol(SCCrossServerBattleResult, "OnCrossServerBattleResult")

end

-----------------------请求-----------------------
--请求信息
function CrossServerMatchCtrl:CrossServerInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerMatchInfoReq)
	protocol:EncodeAndSend()
end

-- 报名
function CrossServerMatchCtrl:CrossServerEnrollReq(state)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerEnrollReq)
	protocol.is_enroll = state
	protocol:EncodeAndSend()
end

-- 领取奖励
function CrossServerMatchCtrl:CrossServerAwardReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerGetRewardReq)
	protocol:EncodeAndSend()
end

-----------------------下发-----------------------
-- 下发信息
function CrossServerMatchCtrl:OnCrossServerMatchInfo(protocol)
	self.data:OnCrossServerMatchInfo(protocol)
	self.view:Flush()
end

-- 下发报名信息
function CrossServerMatchCtrl:OnCrossServerEnrollState(protocol)
	self.data:OnEnrollInfo(protocol)
end

-- 下发领取信息
function CrossServerMatchCtrl:OnCrossServerRewardInfo(protocol)
	self.data:OnRewardInfo(protocol)
	self.view:Flush()
end

-- 下发战斗结果
function CrossServerMatchCtrl:OnCrossServerBattleResult(protocol)
	if protocol.battle_result == 1 then
		ViewManager.Instance:Open(ViewName.CrossServerMatchResult)
		ViewManager.Instance:FlushView(ViewName.CrossServerMatchResult, 0, "success", {key_1 = protocol.get_score, match_1 = protocol.match_score})
	elseif protocol.battle_result == 2 then
		ViewManager.Instance:Open(ViewName.CrossServerMatchResult)
		ViewManager.Instance:FlushView(ViewName.CrossServerMatchResult, 0, "lose", {key_2 = protocol.get_score, match_2 = protocol.match_score})
	else 
		ViewManager.Instance:Open(ViewName.CrossServerMatchResult)
		ViewManager.Instance:FlushView(ViewName.CrossServerMatchResult, 0, "tie", {key_3 = protocol.get_score, match_3 = protocol.match_score})
	end
end



