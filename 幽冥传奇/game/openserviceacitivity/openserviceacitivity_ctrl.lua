require("scripts/game/openserviceacitivity/openserviceacitivity_data")
require("scripts/game/openserviceacitivity/openserviceacitivity_view")
require("scripts/game/openserviceacitivity/draw_record_view")
require("scripts/game/openserviceacitivity/sports_list_view")

--子视图
require("scripts/game/openserviceacitivity/act_datas/gold_turnble_data")

-- 开服活动
OpenServiceAcitivityCtrl = OpenServiceAcitivityCtrl or BaseClass(BaseController)

function OpenServiceAcitivityCtrl:__init()
	if	OpenServiceAcitivityCtrl.Instance then
		ErrorLog("[OpenServiceAcitivityCtrl]:Attempt to create singleton twice!")
	end
	require("scripts/game/openserviceacitivity/openserviceacitivitylevelgift_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityLeveGift)
	require("scripts/game/openserviceacitivity/openserviceacitivitysports_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityMoldingSoulSports)
	require("scripts/game/openserviceacitivity/openserviceacitivitysportslist_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityMoldingSoulList)
	require("scripts/game/openserviceacitivity/openserviceacitivitysports_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityGemStoneSports)
	require("scripts/game/openserviceacitivity/openserviceacitivitysportslist_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityGemStoneList)
	require("scripts/game/openserviceacitivity/openserviceacitivitysports_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityDragonSpiritSports)
	require("scripts/game/openserviceacitivity/openserviceacitivitysportslist_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityDragonSpiritList)
	require("scripts/game/openserviceacitivity/openserviceacitivitysports_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityWingSports)
	require("scripts/game/openserviceacitivity/openserviceacitivitysportslist_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityWingList)
	require("scripts/game/openserviceacitivity/openserviceacitivitysports_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCardHandlebookSports)
	require("scripts/game/openserviceacitivity/openserviceacitivitysportslist_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCardHandlebookList)
	require("scripts/game/openserviceacitivity/openserviceacitivitysports_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCircleSports)
	require("scripts/game/openserviceacitivity/openserviceacitivitysportslist_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCircleList)
	require("scripts/game/openserviceacitivity/openserviceacitivitycharge_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCharge)
	require("scripts/game/openserviceacitivity/openserviceacitivityluckydraw_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityLuckyDraw)
	require("scripts/game/openserviceacitivity/openserviceacitivityboss_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityBoss)
	require("scripts/game/openserviceacitivity/openserviceacitivitywangchengbaye_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityWangChengBaYe)
	require("scripts/game/openserviceacitivity/openserviceacitivityxunbao_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityXunBao)
	require("scripts/game/openserviceacitivity/openserviceacitivityfinancial_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityFinancial)
	require("scripts/game/openserviceacitivity/openserviceacitivityconsume_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityConsume)
	require("scripts/game/openserviceacitivity/act_views/gold_turnble_view").New(ViewDef.OpenServiceAcitivity.GoldDraw)
	require("scripts/game/openserviceacitivity/openserviceacitivityexplorerank_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityExploreRank)
	require("scripts/game/openserviceacitivity/openserviceacitivityrecharge_view").New(ViewDef.OpenServiceAcitivity.OpenServiceAcitivityRecharge)
	OpenServiceAcitivityCtrl.Instance = self

	self.data = OpenServiceAcitivityData.New()
	self.view = OpenServiceAcitivityView.New(ViewDef.OpenServiceAcitivity)
	self.draw_record_view = DrawRecordView.New(ViewDef.OpenServiceAcitivityDrawRecord)
	self.sports_list_view = SportsListView.New(ViewDef.OpenServiceAcitivitySportsList)
	self.remind_group = {
		RemindName.OpenServiceLevelGift,
		RemindName.OpenServiceMoldingSoulSports,
		RemindName.OpenServiceGemStoneSports,
		RemindName.OpenServiceDragonSpiritSports,
		RemindName.OpenServiceWingSports,
		RemindName.OpenServiceCardHandlebookSports,
		RemindName.OpenServiceCircleSports,
		RemindName.OpenServiceCharge,
		RemindName.OpenServiceLuckyDraw,
		RemindName.OpenServiceBoss,
		RemindName.OpenServiceXunBao,
		RemindName.OpenServiceExploreRank,
	}

	self:RegisterAllProtocols()
	self:RegisterAllRemind()
	GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, BindTool.Bind(self.OnOpenServerDayChange, self))

	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, function ()
		OpenServiceAcitivityData.Instance:SetGoldDrawTabbarVisible()
	end)
end

function OpenServiceAcitivityCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.draw_record_view:DeleteMe()
	self.draw_record_view = nil

	self.data:DeleteMe()
	self.data = nil

	self.remind_group = {}

	OpenServiceAcitivityCtrl.Instance = nil
end

function OpenServiceAcitivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOpenServerAcitivityLevelGiftInfo, "OnLevelGiftInfo")
	self:RegisterProtocol(SCOpenServerAcitivityAllSportsInfo, "OnAllSportInfo")
	self:RegisterProtocol(SCOpenServerAcitivitySportsInfo, "OnSportInfo")
	self:RegisterProtocol(SCOpenServerAcitivitySportsListInfo, "OnSportListInfo")
	self:RegisterProtocol(SCOpenServerAcitivityChargeInfo, "OnChargeInfo")
	self:RegisterProtocol(SCOpenServerAcitivityBossInfo, "OnBossInfo")
	self:RegisterProtocol(SCOpenServerAcitivityXunBaoInfo, "OnXunBaoInfo")
	self:RegisterProtocol(SCOpenServerAcitivityDrawResult, "OnDrawInfo")
	self:RegisterProtocol(SCOpenServerAcitivityDrawInfo, "OnDrawInfo")
	self:RegisterProtocol(SCOpenServerAcitivityDrawServerRecording, "OnDrawServerRecording")
	self:RegisterProtocol(SCOpenServeActGoldDrawInfo, "OnOpenServeActGoldDrawInfo")
	self:RegisterProtocol(SCOpenServeActGoldDrawCZResult, "OnOpenServeActGoldDrawCZResult")
	self:RegisterProtocol(SCExploreRankInfo, "OnExploreRankInfo")
	self:RegisterProtocol(SCExploreTimes, "OnExploreTimes")
end

function OpenServiceAcitivityCtrl:RegisterAllRemind()
	for k, v in pairs(self.remind_group) do
		RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), v)
	end
end

function OpenServiceAcitivityCtrl:GetRemindNum(remind_name)
	for k, v in pairs(self.remind_group) do
		if remind_name == v then
			return OpenServiceAcitivityData.Instance:GetRemindNumByType(v)
		end
	end
end

function OpenServiceAcitivityCtrl:OnOpenServerDayChange()
	-- OpenServiceAcitivityCtrl.SendExploreRankInfo(0)
	self.data:UpdateTabbarMarkList()
end

-- 下发等级礼包信息
function OpenServiceAcitivityCtrl:OnLevelGiftInfo(protocol)
	self.data:SetLevelGiftInfo(protocol)
end

-- 请求领取等级礼包
function OpenServiceAcitivityCtrl.SendGetLevelGift(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivityReceiveLevelGiftReq)
	protocol.gift_index = index
	protocol:EncodeAndSend()
end

-- 请求等级礼包信息
function OpenServiceAcitivityCtrl.SendGetLevelGiftInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivityLevelGiftInfoReq)
	protocol:EncodeAndSend()
end

-- 下发所有进行中竞技信息
function OpenServiceAcitivityCtrl:OnAllSportInfo(protocol)
	for k, v in pairs(protocol.sports_data_list) do
		self:OnSportInfo(v)
	end
end

-- 下发单个竞技信息
function OpenServiceAcitivityCtrl:OnSportInfo(protocol)
	self.data:SetSportsInfo(protocol)
end

-- 请求领取竞技奖励
function OpenServiceAcitivityCtrl.SendGetSportGift(sports_type, gift_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivitySportGiftReq)
	protocol.sports_type = sports_type
	protocol.gift_index = gift_index
	protocol:EncodeAndSend()
end

-- 设置竞技榜信息
function OpenServiceAcitivityCtrl:OnSportListInfo(protocol)
	self.data:SetSportsListInfo(protocol)
end

-- 请求竞技榜信息
function OpenServiceAcitivityCtrl:SendSportsListInfo(sports_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivitySportListInfoReq)
	protocol.sports_type = sports_type
	protocol:EncodeAndSend()
end

-- 下发累充信息
function OpenServiceAcitivityCtrl:OnChargeInfo(protocol)
	self.data:SetChargeInfo(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceCharge)
end

-- 请求领取累充礼包
function OpenServiceAcitivityCtrl.SendGetChargeGift(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivityChargeGiftReq)
	protocol.receive_index = index
	protocol:EncodeAndSend()
end

-- 下发全民BOSS信息
function OpenServiceAcitivityCtrl:OnBossInfo(protocol)
	self.data:SetBossInfo(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceBoss)
end

-- 请求领取全民BOSS礼包
function OpenServiceAcitivityCtrl.SendGetBossGift(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivityBossGiftReq)
	protocol.receive_index = index
	protocol:EncodeAndSend()
end

-- 下发寻宝信息
function OpenServiceAcitivityCtrl:OnXunBaoInfo(protocol)
	self.data:SetXunBaoInfo(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceXunBao)
end

-- 请求领取寻宝礼包
function OpenServiceAcitivityCtrl.SendGetXunBaoGift(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivityXunBaoReq)
	protocol.receive_index = index
	protocol:EncodeAndSend()
end

-- 下发幸运抽奖信息/抽奖结果
function OpenServiceAcitivityCtrl:OnDrawInfo(protocol)
	self.data:SetDrawInfo(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceLuckyDraw)
end

-- 下发幸运抽奖全服记录
function OpenServiceAcitivityCtrl:OnDrawServerRecording(protocol)
	self.data:SetDrawServerRecording(protocol)
end

-- 请求抽奖
function OpenServiceAcitivityCtrl.SendDraw(req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivityDrawReq)
	protocol.req_type = req_type
	protocol:EncodeAndSend()
end

-- 请求抽奖全服记录
function OpenServiceAcitivityCtrl.SendDrawServerRecording()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAcitivityDrawServerRecordingReq)
	protocol:EncodeAndSend()
end


----元宝转盘
-- 请求抽奖全服记录
function OpenServiceAcitivityCtrl:OnOpenServeActGoldDrawInfo(protocol)
	self.data:OnOpenServeActGoldDrawInfo(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceGoldDraw)
end

-- 请求抽奖全服记录
function OpenServiceAcitivityCtrl:OnOpenServeActGoldDrawCZResult(protocol)
	self.data:OnOpenServeActGoldDrawCZResult(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceGoldDraw)
end

--请求寻宝榜数据或者领取奖励
function OpenServiceAcitivityCtrl.SendExploreRankInfo(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExploreRankReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

--下发寻宝榜数据
function OpenServiceAcitivityCtrl:OnExploreRankInfo(protocol)
	self.data:SetExploreRankInfo(protocol)
	RemindManager.Instance:DoRemind(RemindName.OpenServiceExploreRank)
end

function OpenServiceAcitivityCtrl:OnExploreTimes(protocol)
	self.data:SetExploreTimes(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceExploreRank)
end