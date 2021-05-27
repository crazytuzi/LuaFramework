require("scripts/game/magic_city/magic_city_data")
require("scripts/game/magic_city/magic_city_view")
require("scripts/game/magic_city/magic_city_tips")
require("scripts/game/magic_city/magic_city_ranking")
require("scripts/game/magic_city/common_sucess_view")
require("scripts/game/magic_city/cross_union_fight_award_view")
require("scripts/game/magic_city/cross_union_score_rank")
require("scripts/game/magic_city/mineral_contention_view")
require("scripts/game/magic_city/all_ser_fight_ranking_view")

MagicCityCtrl = MagicCityCtrl or BaseClass(BaseController)

function MagicCityCtrl:__init()
	if MagicCityCtrl.Instance then
		ErrorLog("[MagicCityCtrl]:Attempt to create singleton twice!")
	end
	MagicCityCtrl.Instance = self

	self.data = MagicCityData.New()
	self.view = MagicCityView.New(ViewName.MagicCity)
	self.sucess_view = MagicCityCommonSucessView.New(ViewName.CommonSuceessPanel)
	self.magiccity_enter_tips = MagicCityTips.New(ViewName.MagicCityTip)
	self.rankinglist_magiccity_view =  MagicCityRankingView.New(ViewName.MagicCityRankingList)
	self.cross_union_fight_awar_view = CrossUnionFightAwarView.New(ViewName.CrossUnionAwarView)
	self.cross_union_score_rank_view = CrossUnionScoreRankView.New(ViewName.CrossUnionScoreRank)
	self.mineral_contention_view = MineralContentionView.New(ViewName.MineralContention)
	self.all_ser_fight_rank_view = AllSerFightMatchRankView.New(ViewName.AllSerFightRankInfoView)
	self:RegisterAllProtocols()
end

function MagicCityCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	self.rankinglist_magiccity_view:DeleteMe()
	self.rankinglist_magiccity_view = nil

	self.sucess_view:DeleteMe()
	self.sucess_view = nil 

	-- self.failed_view:DeleteMe()
	-- self.failed_view = nil 

	if self.magiccity_enter_tips ~= nil then
		self.magiccity_enter_tips:DeleteMe()
		self.magiccity_enter_tips = nil 
	end
	if self.cross_union_fight_awar_view then
		self.cross_union_fight_awar_view:DeleteMe()
		self.cross_union_fight_awar_view = nil
	end
	if self.cross_union_score_rank_view then
		self.cross_union_score_rank_view:DeleteMe()
		self.cross_union_score_rank_view = nil
	end

	if self.mineral_contention_view then
		self.mineral_contention_view:DeleteMe()
		self.mineral_contention_view = nil 
	end
	
	if self.all_ser_fight_rank_view then
		self.all_ser_fight_rank_view:DeleteMe()
		self.all_ser_fight_rank_view = nil
	end

    MagicCityCtrl.Instance = nil
end

function MagicCityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOpenCommonTongGuanData, "OnOpenCommonTongGuanData")
	self:RegisterProtocol(SCReqAllOwnerData, "OnReqAllOwnerData")
	self:RegisterProtocol(SCMyCheperData, "OnMyCheperData")
	self:RegisterProtocol(SCMyEnterChaperNum, "OnMyEnterChaperNum")
	self:RegisterProtocol(SCCommonRankingListData, "OnCommonRankingListData")
	self:RegisterProtocol(SCMyDataAtRankingList, "OnMyDataAtRankingList")
	self:RegisterProtocol(SCCloseWindowViewByRankingType, "OnCloseWindowViewByRankingType")
	self:RegisterProtocol(SCHeroesFightRankIss, "OnHeroesFightRankIss")
	self:RegisterProtocol(SCHeroesFightAwarInfoIss, "OnSCHeroesFightAwarInfoIss")
	self:RegisterProtocol(SCGetAllSerFightRankInfo, "OnGetAllSerFightRankInfo") -- 全服争霸
	--GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.GetInfo, self, true))

	--水晶争夺
	self:RegisterProtocol(SCRankingDataContention, "OnRankingDataContention")
	self:RegisterProtocol(SCMyRankingDataContention, "OnMyRankingDataContention")
end

function MagicCityCtrl:OpenTips(data)
	if self.magiccity_enter_tips == nil then
		self.magiccity_enter_tips = MagicCityTips.New()
	end
	self.magiccity_enter_tips:SetData(data)
	self.magiccity_enter_tips:Open()
end

function MagicCityCtrl:OnOpenCommonTongGuanData(protocol)
	local data = { 
			pannel_type = protocol.pannel_type,
			activity_id = protocol.activity_id,
			activity_id_child = protocol.activity_id_child,
			tongguang_time = protocol.tongguang_time,
			tongguang_star = protocol.tongguang_star,
			reward_data = protocol.reward_data,
			boss_hp_bar = protocol.canshu_one,
			state = protocol.state,
		}
	if protocol.state == 1 or protocol.state == 2 then
		if protocol.activity_id == ActiveFbID.CombineServerArena then
			ViewManager.Instance:Open(ViewName.CombineServerArenaSuccessPage)
			ViewManager.Instance:FlushView(ViewName.CombineServerArenaSuccessPage, 0, "Arena", {key = data})
		elseif protocol.activity_id == ActiveFbID.BabelFight then
			BabelCtrl.Instance:OpenSuccessData(data)
		else
			ViewManager.Instance:Open(ViewName.CommonSuceessPanel)
			ViewManager.Instance:FlushView(ViewName.CommonSuceessPanel, 0, "Success", {key = data})
		end
	elseif protocol.state == 0 then
		if protocol.activity_id == ActiveFbID.CombineServerArena then
			ViewManager.Instance:Open(ViewName.CombineServerArenaLosePage)
			ViewManager.Instance:FlushView(ViewName.CombineServerArenaLosePage, 0, "Lose", {key = data})
		elseif protocol.activity_id == ActiveFbID.GuildShouWeiBoss or
			protocol.activity_id == ActiveFbID.Trainer then
			ViewManager.Instance:Open(ViewName.StrenfthFbFailedTip)
			ViewManager.Instance:FlushView(ViewName.StrenfthFbFailedTip, 0, "CommonLose", {key = data})
		elseif protocol.activity_id == ActiveFbID.BabelFight then
			BabelCtrl.Instance:OpenFailedData()
		else	
			ViewManager.Instance:Open(ViewName.StrenfthFbFailedTip)
		end
	end
end

--请求所有楼主数据
function MagicCityCtrl:SendReqAllOwnerData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqAllOwnerData)
	protocol:EncodeAndSend()
end

-- 请求单个数据
function MagicCityCtrl:SendSingleCheaperData(chapter_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqSingleCheaperData)
	protocol.chapter_id = chapter_id
	protocol:EncodeAndSend()
end

-- 操作副本
function MagicCityCtrl:SendOperateCheaterReq(pos, oprate_type, times)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOperateCheater)
	protocol.chapter_pos = pos
	protocol.operate_type = oprate_type
	protocol.times = times
	protocol:EncodeAndSend()
end

function MagicCityCtrl:OnReqAllOwnerData(protocol)
	self.data:SetOwnerData(protocol)
	self.view:Flush()
end

function MagicCityCtrl:OnMyCheperData(protocol)
	self.data:SetMyCheaperData(protocol)
	self.view:Flush()
	self.magiccity_enter_tips:Flush()
end

function MagicCityCtrl:OnMyEnterChaperNum(protocol)
	self.data:SetMyCheaperEnterData(protocol)
	self.view:Flush()
	self.magiccity_enter_tips:Flush()
end

function MagicCityCtrl:ReqRankinglistData(ranking_type)
	--print("333333333333333333333", ranking_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqRankingListCommonData)
	protocol.rankinglist_type = ranking_type
	protocol:EncodeAndSend()
end

function MagicCityCtrl:OnCommonRankingListData(protocol) -- 留待整理
	self.data:SetRankingData(protocol)
	local bool = false
	if protocol.rankinglist_type == MagicCityRankingListData_TYPE.Magic_city_type then
		self.rankinglist_magiccity_view:Flush()
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.XuKong_type then
		bool = true 
		-- ViewManager.Instance:Open(ViewName.XukongShiLianRanking)
		-- ViewManager.Instance:FlushView(ViewName.XukongShiLianRanking, 0, "data", {rankinglist_type = MagicCityRankingListData_TYPE.XuKong_typ })
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.Battle_Boss then
		if ViewManager.Instance:IsOpen(ViewName.BossBattleInjureRank) == true then
			ViewManager.Instance:FlushView(ViewName.BossBattleInjureRank)
		end
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.CombineServerArena then
		GlobalEventSystem:Fire(CombineServerActiviType.LEITAI, MagicCityRankingListData_TYPE.CombineServerArena)
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.CombineServerBattle then
		GlobalEventSystem:Fire(CombineServerActiviType.LEITAI, MagicCityRankingListData_TYPE.CombineServerBattle)
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.AnswerQuestionTadayRanking or protocol.rankinglist_type == MagicCityRankingListData_TYPE.AnswerQuestionYesturadayRanking then
		bool = true 
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.JIZhanBossRanking then
		bool = true 
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.BabelRanking then
		if ViewManager.Instance:IsOpen(ViewName.RankingList) == true then
			ViewManager.Instance:FlushView(ViewName.RankingList)
		end
	end
	if bool then
		ViewManager.Instance:Open(ViewName.XukongShiLianRanking)
		ViewManager.Instance:FlushView(ViewName.XukongShiLianRanking, 0, "data", {rankinglist_type = protocol.rankinglist_type})
	end
end

function MagicCityCtrl:OnMyDataAtRankingList(protocol) -- 留待整理
	if protocol.rankinglist_type == MagicCityRankingListData_TYPE.Magic_city_type then
		self.data:SetMyRankingData(protocol)
		self.rankinglist_magiccity_view:Flush()
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.XuKong_type then
		self.data:SetMyRankingData(protocol)
		ViewManager.Instance:Open(ViewName.XukongShiLianRanking)
		ViewManager.Instance:FlushView(ViewName.XukongShiLianRanking, 0, "xukong", {rankinglist_type = MagicCityRankingListData_TYPE.XuKong_type })
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.CombineServerArena then
		self.data:SetMyArenaRankingData(protocol)
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.CombineServerBattle then
		self.data:SetMyRankingData(protocol)
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.AnswerQuestionTadayRanking then
		self.data:SetMyRankingData(protocol)
		GlobalEventSystem:Fire(AllDayActivityEvent.ANSWER_RANKING_My_DATA, protocol.my_rank)
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.AnswerQuestionYesturadayRanking then
		self.data:SetMyRankingData(protocol)
		GlobalEventSystem:Fire(AllDayActivityEvent.ANSWER_RANKING_My_DATA, protocol.my_rank)
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.JIZhanBossRanking then
		self.data:SetMyRankingData(protocol)
	elseif protocol.rankinglist_type == MagicCityRankingListData_TYPE.BabelRanking then
		self.data:SetMyRankingData(protocol)
	end
end

function MagicCityCtrl:OnCloseWindowViewByRankingType(protocol)
	if protocol.rankinglist_type == MagicCityRankingListData_TYPE.Battle_Boss then
		ViewManager.Instance:Close(ViewName.BossBattleInjureRank)
	end
end

function MagicCityCtrl:OnGetAllSerFightRankInfo(protocol)
	self.data:SetAllSerFightInfo(protocol)
	self.all_ser_fight_rank_view:Flush()
end

function MagicCityCtrl:OnHeroesFightRankIss(protocol)
	self.data:SetHeroesFightRankData(protocol)
	self.cross_union_score_rank_view:Flush()
end

function MagicCityCtrl:OnSCHeroesFightAwarInfoIss(protocol)
	self.data:SetHeroesFightAwarData(protocol)
	self.cross_union_fight_awar_view:Flush()
end

--请求跨服联盟奖励信息
function MagicCityCtrl:HeroesFightAwarDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroesFightRewardReq)
	protocol:EncodeAndSend()
end

--请求跨服联盟排行榜
function MagicCityCtrl:HeroesFightRankDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroesFightingRankInfoReq)
	protocol:EncodeAndSend()
end

--领取跨服联盟奖励
function MagicCityCtrl:HeroesFightGetAwarReq(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroesFightGetRewardReq)
	protocol.type = type
	protocol:EncodeAndSend()
end
--=========跨服联盟===========-----------
function MagicCityCtrl:ReqContentionRankinglistData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqRankingDataByType)
	protocol:EncodeAndSend()
end

function MagicCityCtrl:ReqHandInShuiJIng()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHandInShuiJing)
	protocol:EncodeAndSend()
end

function MagicCityCtrl:ReqGetMyContentionReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetMyRewardReq)
	protocol:EncodeAndSend()
end

function MagicCityCtrl:OnRankingDataContention(protocol)
	self.data:SetMineralContentionData(protocol)
	self.mineral_contention_view:Flush()
end

function MagicCityCtrl:OnMyRankingDataContention(protocol)
	self.data:SetMyMineralContentionData(protocol)
	self.mineral_contention_view:Flush()
end

--请求全服争霸排行信息
function MagicCityCtrl.AllSerFightRankInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSAllSerFightRankInfoReq)
	protocol:EncodeAndSend()
end