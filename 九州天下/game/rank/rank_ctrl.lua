require("game/rank/rank_data")
require("game/rank/rank_view")
require("game/rank/rank_marry_tip")

RankCtrl = RankCtrl or BaseClass(BaseController)

function RankCtrl:__init()
	if RankCtrl.Instance then
		print_error("[RankCtrl] Attemp to create a singleton twice !")
	end
	RankCtrl.Instance = self

	self.data = RankData.New()
	self.view = RankView.New(ViewName.Ranking)
	self.rank_marry_tip = RankMarryTip.New()
	self:RegisterAllProtocols()
end

function RankCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	if self.rank_marry_tip ~= nil then
		self.rank_marry_tip:DeleteMe()
		self.rank_marry_tip = nil
	end

	RankCtrl.Instance = nil
end

function RankCtrl:GetRankView()
	return self.view
end

function RankCtrl:SetCurIndex(index)
	self.view:SetCurIndex(index)
end

function RankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetPersonRankListAck, "OnGetPersonRankListAck")
	self:RegisterProtocol(SCGetGuildRankListAck, "OnGetGuildRankListAck")
	self:RegisterProtocol(SCGetTeamRankListAck, "OnGetTeamRankListAck")
	self:RegisterProtocol(SCGetPersonRankTopUserAck, "OnGetPersonRankTopUserAck")
	self:RegisterProtocol(SCGetWorldLevelAck, "OnGetWorldLevelAck")
	self:RegisterProtocol(SCSendFamousManInfo, "OnSCSendFamousManInfo")
	self:RegisterProtocol(SCGetCoupleRankListAck, "OnSCGetCoupleRankListAck")
	self:RegisterProtocol(SCGetCrossPersonRankListAck, "OnSCGetCrossPersonRankListAck")
end

-- 个人排行返回
function RankCtrl:OnGetPersonRankListAck(protocol)
	self.data:OnGetPersonRankListAck(protocol)
	KuaFu1v1Data.Instance:SetRankList(protocol.rank_list)
	KuaFu1v1Ctrl.Instance:FlushView()

	if self.view:IsOpen() then
		self.view:Flush()
	end
	if KaifuActivityCtrl.Instance.view:IsOpen() then
		KaifuActivityCtrl.Instance:FlushKaifuView()
	end

	-- if CompetitionActivityCtrl.Instance.view:IsOpen() then
	-- 	CompetitionActivityCtrl.Instance.view:FlushRankInfo()
	-- end
	WarReportCtrl.Instance:Flush("all")
   	GlobalEventSystem:Fire(OtherEventType.RANK_CHANGE, protocol.rank_type)
end

-- 仙盟排行返回
function RankCtrl:OnGetGuildRankListAck(protocol)
	self.data:OnGetGuildRankListAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	-- self.view:SetTuanZhangMameValue()
end

--队伍排行返回
function RankCtrl:OnGetTeamRankListAck(protocol)
	self.data:OnGetTeamRankListAck(protocol)
end

--顶级玩家信息返回
function RankCtrl:OnGetPersonRankTopUserAck(protocol)
	self.data:OnGetPersonRankTopUserAck(protocol)
end

--世界等级信息返回
function RankCtrl:OnGetWorldLevelAck(protocol)
	self.data:OnGetWorldLevelAck(protocol)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	-- local sever_level, role_num, last_days = PlayerData.Instance:GetServerLevelInfo()
	-- local sever_level_cfg = PlayerData.Instance:GetSeverLevelCfg(sever_level)
	MainUICtrl.Instance:FlushView("world_level", {role_level >= RankData.Instance:GetServerLevel()})
end

--名人堂信息返回
function RankCtrl:OnSCSendFamousManInfo(protocol)
	RankData.Instance:SetFamousList(protocol.famous_man_uid_list)
	RankData.Instance:ClearMingrenData()
	RankData.Instance:SetMingrenIdList(protocol.famous_man_uid_list)
end

-- 婚宴排行榜信息返回
function RankCtrl:OnSCGetCoupleRankListAck(protocol)
	self.data:SetMarryRankInfo(protocol)
	-- self.view:Flush()
	self.view:FlushMarryMyRank()
	-- MarryRankScroller
end

-- 跨服排行榜列表返回
function RankCtrl:OnSCGetCrossPersonRankListAck(protocol)
	self.data:SetCrossPersonRankList(protocol)
   	GlobalEventSystem:Fire(OtherEventType.CROSS_RANK_CHANGE, protocol.rank_type)
end

--请求个人排行
function RankCtrl:SendGetPersonRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetPersonRankListReq)
	send_protocol.rank_type = rank_type
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

--请求婚宴人气排行
function RankCtrl:SendGetMarryRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetCoupleRankList)
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

-- 请求跨服排行榜列表
function RankCtrl:SendCrossGetPersonRankList(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossGetPersonRankList)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

function RankCtrl:RankMarryTipOpen()
	self.rank_marry_tip:Open()
end

function RankCtrl:SetOtherHead(data)
	if self.rank_marry_tip:IsOpen() then
		self.rank_marry_tip:SetHeadData(data)
	end
end

function RankCtrl:ChangePanelHeightMin()
	self.view:ChangePanelHeightMin()
end

function RankCtrl:ChangePanelHeightMax()
	self.view:ChangePanelHeightMax()
end