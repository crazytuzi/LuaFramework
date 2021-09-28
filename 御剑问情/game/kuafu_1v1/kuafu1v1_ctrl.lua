require("game/kuafu_1v1/kuafu1v1_view")
require("game/kuafu_1v1/kuafu1v1_fight_view")
require("game/kuafu_1v1/kuafu1v1_data")
require("game/kuafu_1v1/kuafu1v1_view_loser")
require("game/kuafu_1v1/kuafu1v1_view_vector")
require("game/kuafu_1v1/kuafu1v1_view_levelup")

KuaFu1v1Ctrl = KuaFu1v1Ctrl or BaseClass(BaseController)

function KuaFu1v1Ctrl:__init()
	if KuaFu1v1Ctrl.Instance ~= nil then
		print_error("[KuaFu1v1Ctrl] attempt to create singleton twice!")
		return
	end
	KuaFu1v1Ctrl.Instance = self

	self:RegisterAllProtocols()

	self.view = KuaFu1v1View.New(ViewName.KuaFu1v1)
	self.fight_view = KuaFu1v1FightView.New()
	self.data = KuaFu1v1Data.New()
	self.vector_view = KuaFu1v1ViewVector.New()
	self.loser_view = KuaFu1v1ViewLoser.New()
	self.levelup_view = KuaFu1v1LevelUpView.New(ViewName.KuaFu1v1RankLevelUp)
end

function KuaFu1v1Ctrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.vector_view ~= nil then
		self.vector_view:DeleteMe()
		self.vector_view = nil
	end

	if self.loser_view ~= nil then
		self.loser_view:DeleteMe()
		self.loser_view = nil
	end

	if nil ~= self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	if nil ~= self.levelup_view then
		self.levelup_view:DeleteMe()
		self.levelup_view = nil
	end

	KuaFu1v1Ctrl.Instance = nil
end

function KuaFu1v1Ctrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossActivity1V1SelfInfo, "OnCrossActivity1V1SelfInfo")
	self:RegisterProtocol(SCCross1v1FightStart, "OnCross1v1FightStart")
	self:RegisterProtocol(SCCross1v1MatchAck, "OnCross1v1MatchAck")
	self:RegisterProtocol(SCCross1v1WeekRecord, "OnCross1v1WeekRecord")
	self:RegisterProtocol(SCCross1V1RankList, "OnCross1V1RankList")
	self:RegisterProtocol(SCGetCrossPersonRankListAck, "OnGetCrossPersonRankListAck")
	self:RegisterProtocol(SCCross1v1MatchResult, "OnCross1v1MatchResult")
	self:RegisterProtocol(SCCross1v1FightResult, "OnCross1v1FightResult")
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoadingQuite, self))
end

function KuaFu1v1Ctrl:OpenView()
	if self.view then
		ViewManager.Instance:Open(ViewName.KuaFu1v1)
	end
end

-- 进入战斗时调用
function KuaFu1v1Ctrl:InitFight()
	self.fight_view:Open()
end

-- 得到跨服1v1的个人信息
function KuaFu1v1Ctrl:OnCrossActivity1V1SelfInfo(protocol)
	KuaFu1v1Data.Instance:SetRoleData(protocol.info)
	if self.view then
		self.view:Flush()
	end

	local flag = self.data:IsKuaFuRankLevelUp()
	if self.data:IsKuaFuRankLevelUp() then
		ViewManager.Instance:Open(ViewName.KuaFu1v1RankLevelUp)
	end
end

-- 跨服1V1战斗开始
function KuaFu1v1Ctrl:OnCross1v1FightStart(protocol)
	if self.fight_view then
		self.fight_view:StartFight()
	end
end

--跨服1v1匹配确认
function KuaFu1v1Ctrl:OnCross1v1MatchAck(protocol)
	KuaFu1v1Data.Instance:SetMatchAck(protocol)
	if self.view and protocol.result == 1 then
		self.view:OpenCountView()
	end
end

--跨服1v1战斗记录
function KuaFu1v1Ctrl:OnCross1v1WeekRecord(protocol)
	KuaFu1v1Data.Instance:SetRecord(protocol)
end

--跨服1v1展示排行
function KuaFu1v1Ctrl:OnCross1V1RankList(protocol)
	local kf_1v1_show_rank = protocol.kf_1v1_show_rank
    table.sort(kf_1v1_show_rank, function(a, b)
    	if a.score > b.score then
    		return true
    	elseif a.score == b.score and a.max_dur_win_count > b.max_dur_win_count then
    		return true
    	elseif a.score == b.score and a.max_dur_win_count == b.max_dur_win_count then
    		return a.role_id > b.role_id
    	else
    		return false
    	end
    end)

    KuaFu1v1Data.Instance:SetRankList(kf_1v1_show_rank)
	if self.view then
		self.view:Flush()
	end
end

--跨服排行榜列表   
function KuaFu1v1Ctrl:OnGetCrossPersonRankListAck(protocol)
	local rank_list = protocol.rank_list
	--table.sort(rank_list, function(a, b) return a.rank_value > a.rank_value end)
	KuaFu1v1Data.Instance:SetRankList(rank_list)
	if self.view then
		self.view:Flush()
	end
end

--跨服

--跨服1v1匹配结果
function KuaFu1v1Ctrl:OnCross1v1MatchResult(protocol)
	KuaFu1v1Data.Instance:SetMatchResult(protocol.info)
	if self.view then
		self.view:OpenAndFlush()
	end
end

--跨服1v1挑战结果
function KuaFu1v1Ctrl:OnCross1v1FightResult(protocol)
	KuaFu1v1Data.Instance:SetFightResult(protocol.info)
	if self.fight_view then
		self.fight_view:OpenRewardPanel(protocol.info.result)
	end
	if protocol.info.result == 1 then
		if self.vector_view then
			self.vector_view:Open()
		end
	else
		if self.loser_view then
			self.loser_view:Open()
		end
	end
end

-- 跨服1v1匹配请求
function KuaFu1v1Ctrl:SendCrossMatch1V1Req()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMatch1V1Req)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1取消匹配请求
function KuaFu1v1Ctrl:SendQuXiaoCrossMatch1V1Req()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossCancelMatch1V1Req)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1战斗准备
function KuaFu1v1Ctrl:SendCross1v1FightReadyReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1FightReady)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1下注
function KuaFu1v1Ctrl:SendCross1v1XiazhuReq(seq, gold)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1XiazhuReq)
	send_protocol.seq = seq or 0
	send_protocol.gold = gold or 0
	send_protocol:EncodeAndSend()
end

-- 跨服1v1匹配查询
function KuaFu1v1Ctrl:SendCross1v1MatchQueryReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1MatchQuery)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1战斗记录查询
function KuaFu1v1Ctrl:SendCross1v1WeekRecordQueryReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1WeekRecordQuery)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1展示排行查询
function KuaFu1v1Ctrl:SendGetCross1V1RankListReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetCross1V1RankList)
	send_protocol:EncodeAndSend()
end

--跨服排行榜
function KuaFu1v1Ctrl:SendCrossGetPersonRankList()
   local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossGetPersonRankList)	
   send_protocol:EncodeAndSend()
end

-- 跨服1v1领取奖励
function KuaFu1v1Ctrl:SendGetCross1V1RankRewardReq(seq)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1FetchRewardReq)
	send_protocol.seq = seq
	send_protocol:EncodeAndSend()
end

function KuaFu1v1Ctrl:OnSceneLoadingQuite()
	if Scene.Instance:GetSceneType() == SceneType.Kf_OneVOne then
		self.view:Close()
		self.fight_view:Open()
	end
end

function KuaFu1v1Ctrl:CloseFightView()
	self.fight_view:Close()
	if self.vector_view then
		self.vector_view:Close()
	end
	if self.loser_view then
		self.loser_view:Close()
	end
end