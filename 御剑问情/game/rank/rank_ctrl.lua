require("game/rank/rank_data")
require("game/rank/rank_view")
RankCtrl = RankCtrl or BaseClass(BaseController)

function RankCtrl:__init()
	if RankCtrl.Instance then
		print_error("[RankCtrl] Attemp to create a singleton twice !")
	end
	RankCtrl.Instance = self

	self.data = RankData.New()
	self.view = RankView.New(ViewName.Ranking)
	self:RegisterAllProtocols()
	self.is_show = true
end

function RankCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	RankCtrl.Instance = nil
end

function RankCtrl:GetRankView()
	return self.view
end

function RankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetPersonRankListAck, "OnGetPersonRankListAck")
	self:RegisterProtocol(SCGetGuildRankListAck, "OnGetGuildRankListAck")
	self:RegisterProtocol(SCGetTeamRankListAck, "OnGetTeamRankListAck")
	self:RegisterProtocol(SCGetPersonRankTopUserAck, "OnGetPersonRankTopUserAck")
	self:RegisterProtocol(SCGetWorldLevelAck, "OnGetWorldLevelAck")
	self:RegisterProtocol(SCSendFamousManInfo, "OnSCSendFamousManInfo")
	self:RegisterProtocol(SCGetCoupleRankListAck, "OnSCGetCoupleRankListAck")
end

function RankCtrl:OnSCGetCoupleRankListAck(protocol)
	-- 服务端没有按预想的发送枚举
	if protocol.rank_type == COUPLE_RANK_TYPE.COUPLE_RANK_TYPE_QINGYUAN_CAP then
		protocol.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_QingYuan
	elseif protocol.rank_type == COUPLE_RANK_TYPE.COUPLE_RANK_TYPE_BABY_CAP then
		protocol.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_BAOBAO
	elseif protocol.rank_type == COUPLE_RANK_TYPE.COUPLE_RANL_TYPE_LITTLE_PET then
		protocol.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LITTLEPET
	end

	self.data:OnGetCoupleRankListAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush("flush_rank")
	end
	if KaifuActivityCtrl.Instance.view:IsOpen() then
		KaifuActivityCtrl.Instance:FlushKaifuView()
	end

	GlobalEventSystem:Fire(OtherEventType.RANK_CHANGE, protocol.rank_type)

	local role_level = PlayerData.Instance:GetRoleVo().level
	if self.is_show and role_level >= 180 then
		self.is_show = false
		TipsCtrl.Instance:FlushMyRankInfo()
	end
end

-- 个人排行返回
function RankCtrl:OnGetPersonRankListAck(protocol)
	self.data:OnGetPersonRankListAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush("flush_rank")
	end
	if KaifuActivityCtrl.Instance.view:IsOpen() then
		KaifuActivityCtrl.Instance:FlushKaifuView()
	end

	if protocol.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHTING_CHALLENGE then
		MiningController.Instance:FlsuhChallengeRankView()
	elseif protocol.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CHONGZHI_RANK_2 then
		FestivalActivityData.Instance:SendChongZhiRank(protocol.rank_list)
		FestivalActivityCtrl.Instance:FlushView("chongzhirank")
	elseif protocol.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_CONSUME_GOLD_RANK_2 then
		FestivalActivityData.Instance:SendXiaoFeiRank(protocol.rank_list)
		FestivalActivityCtrl.Instance:FlushView("xiaofeirank")
	end

	GlobalEventSystem:Fire(OtherEventType.RANK_CHANGE, protocol.rank_type)

	local role_level = PlayerData.Instance:GetRoleVo().level
	if self.is_show and role_level >= 180 then
		self.is_show = false
		TipsCtrl.Instance:FlushMyRankInfo()
	end
end

-- 仙盟排行返回
function RankCtrl:OnGetGuildRankListAck(protocol)
	-- self.data:OnGetGuildRankListAck(protocol)
	self.data:OnGetGuildWarRankListAck(protocol)
	GuildCtrl.Instance:FlushGuildWarView()
end

--队伍排行返回
function RankCtrl:OnGetTeamRankListAck(protocol)
	self.data:OnGetTeamRankListAck(protocol)
end

--顶级玩家信息返回
function RankCtrl:OnGetPersonRankTopUserAck(protocol)
	self.data:OnGetPersonRankTopUserAck(protocol)

	GlobalEventSystem:Fire(OtherEventType.BEST_RANK_CHANGE, protocol.rank_type)
end

--世界等级信息返回
function RankCtrl:OnGetWorldLevelAck(protocol)
	self.data:OnGetWorldLevelAck(protocol)
end

--名人堂信息返回
function RankCtrl:OnSCSendFamousManInfo(protocol)
	RankData.Instance:SetFamousList(protocol.famous_list)
	RankData.Instance:ClearMingrenData()
	RankData.Instance:SetMingrenIdList(protocol.famous_list)
end

--请求个人排行
function RankCtrl:SendGetPersonRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetPersonRankListReq)
	send_protocol.rank_type = rank_type or 0
	send_protocol:EncodeAndSend()
end

--请求军团排行
function RankCtrl:SendGetGuildRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildRankListReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

--请求队伍排行
function RankCtrl:SendGetTeamRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetTeamRankListReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

--请求顶级玩家信息
function RankCtrl:SendGetPersonRankTopUserReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetPersonRankTopUserReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

--请求名人堂信息
function RankCtrl:SendFamousManOpera(opera_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFamousManOpera)
	send_protocol.opera_type = opera_type
	send_protocol:EncodeAndSend()
end

--请求所有模块的战力值
function RankCtrl:SendRoleCapabilityOpera()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetRoleCapability)
	protocol:EncodeAndSend()
end

function RankCtrl:SendGetCoupleRankList(rank_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetCoupleRankList)
	protocol.rank_type = rank_type
	protocol:EncodeAndSend()
end
