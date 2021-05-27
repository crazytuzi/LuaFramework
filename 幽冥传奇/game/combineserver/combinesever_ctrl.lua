require("scripts/game/combineserver/combinesever_data")
require("scripts/game/combineserver/combinesever_view")
require("scripts/game/combineserver/combineserver_arena_success_page")
require("scripts/game/combineserver/combineserver_arena_lose_page")
require("scripts/game/combineserver/combineserver_arena_battle_rank")
require("scripts/game/combineserver/combineserver_reward_tips")

------------------------------------------------------------
-- 合服活动
------------------------------------------------------------
CombineServerCtrl = CombineServerCtrl or BaseClass(BaseController)

function CombineServerCtrl:__init()
	if CombineServerCtrl.Instance then
		ErrorLog("[CombineServerCtrl]:Attempt to create singleton twice!")
	end
	CombineServerCtrl.Instance = self

	self.data = CombineServerData.New()
	self.view = CombineServerView.New(ViewName.CombineServerActivity)
	self.succes_title = CombindeServerArenaSucessPage.New(ViewName.CombineServerArenaSuccessPage)
	self.lose_title = CombindeServerArenaLosePage.New(ViewName.CombineServerArenaLosePage)
	self.integral_rank = CombineServerArenaBattleRank.New(ViewName.CombineserverArenaRank)
	self:RegisterAllProtocls()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.ComBineServerCharge, true, 2)
	self.time_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.FlushMainui, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.ReqGiftInfo, self, true))
end

function CombineServerCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	self.succes_title:DeleteMe()
	self.succes_title = nil

	self.lose_title:DeleteMe()
	self.lose_title = nil

	self.integral_rank:DeleteMe()
	self.integral_rank = nil

	if self.reward_tip ~= nil then
		self.reward_tip:DeleteMe()
		self.reward_tip = nil 
	end

	if self.time_event then
		GlobalEventSystem:UnBind(self.time_event)
		self.time_event = nil
	end
	CombineServerCtrl.Instance = nil
end

function CombineServerCtrl:RegisterAllProtocls()
	self:RegisterProtocol(SCGetLimitTimeGift, "OnGetLimitTimeGift")
	self:RegisterProtocol(SCChargeGiftData, "OnChargeGiftDatat")
	self:RegisterProtocol(SCGongChengZhanWinGuild, "OnGongChengZhanWinGuild")
	self:RegisterProtocol(SCChargeGoldNumDay, "OnChargeGoldNumDay")
	self:RegisterProtocol(SCExtractItemData, "OnExtractItemData")
	self:RegisterProtocol(SCBossRefreshState, "OnBossRefreshState")
	self:RegisterProtocol(SCReqCombineServerCharConsume, "OnReqCombineServerCharConsume")
	self:RegisterProtocol(SCGetCombineServerGiftInfo, "OnGetCombineServerGiftInfo")
	self:RegisterProtocol(SCGetCombineServerArenaEnrollState, "OnGetCombineServerArenaEnrollState")
end

function CombineServerCtrl:OnGetLimitTimeGift(protocol)
	self.data:SetGetLimitGiftDataState(protocol)
	self.view:Flush(TabIndex.combine_activity_limittime_shop)
end

function CombineServerCtrl:OnChargeGiftDatat(protocol)
	self.data:SetGetGiftDataState(protocol)
	self.view:Flush(TabIndex.combine_activity_charge_everyDay)
	RemindManager.Instance:DoRemind(RemindName.CombineServer)
end

function CombineServerCtrl:OnGongChengZhanWinGuild(protocol)
	self.data:SetGongChengZhanWinGuildName(protocol)
	self.view:Flush(TabIndex.combine_activity_lc_zb)
end

function CombineServerCtrl:OnBossRefreshState(protocol)
	self.data:SetBossRreshTime(protocol)
	self.view:Flush(TabIndex.combine_activity_super_boss)
end

function CombineServerCtrl:OnReqCombineServerCharConsume(protocol)
	--PrintTable(protocol)
	self.data:SetChargeConsumeRank(protocol)
	self.view:Flush(TabIndex.combine_activity_charge_rank,TabIndex.combine_activity_consume_rank)
end

--请求合服活动数据
function CombineServerCtrl:ReqCombineServerActivityData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCombineServer)
	protocol:EncodeAndSend()
end

--领取礼包
function CombineServerCtrl:ReqLimitTimeGiftData(pos)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqGetLimitTimeGift)
	protocol.gift_pos = pos
	protocol:EncodeAndSend()
end

function CombineServerCtrl:GetChargEveryDayGift()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetChargeGift)
	protocol:EncodeAndSend()
end

function CombineServerCtrl:ReqFirstGCWinGuildName()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqFirstGuildReward)
	protocol:EncodeAndSend()
end

function CombineServerCtrl:OnChargeGoldNumDay(protocol)
	self.data:SetChargeMoneyData(protocol)
	RemindManager.Instance:DoRemind(RemindName.CombineServer)
	self.view:Flush(TabIndex.combine_activity_charge_everyDay)
end

function CombineServerCtrl:ReqTransmitToBoss()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTransmitToBoss)
	protocol:EncodeAndSend()
end

--神秘商店
--==========请求
function CombineServerCtrl:ExtractItemData(activity_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExtractItemData)
	protocol.activity_id = activity_id
	protocol:EncodeAndSend()
end

--手动或自动刷新
function CombineServerCtrl:RefreshItem(activity_id, refresh_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqRefreshItemData)
	protocol.activity_id = activity_id
	protocol.refresh_type = refresh_type
	protocol:EncodeAndSend()
end

--购买抽中的物品
function CombineServerCtrl:BuyExtractItem(activity_id, pos)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyExtractItem)
	protocol.activity_id = activity_id
	protocol.item_pos = pos 
	protocol:EncodeAndSend()
end

function CombineServerCtrl:OnExtractItemData(protocol)
	self.data:SetCombineServerData(protocol)
	self.view:Flush(TabIndex.combine_activity_mysterious_shop)
end

function CombineServerCtrl:GetRemindSign(remind_name)
	if remind_name == RemindName.ComBineServerCharge then
		return self.data:GetBoolShowFlag()
	end
end


function CombineServerCtrl:FlushMainui()
	ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	self.view:Flush()
end

--合服充值或者消费
function CombineServerCtrl:ChargeConsumeRankReq(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCombineServerCharConsume)
	protocol.type = type
	protocol:EncodeAndSend()
end

function CombineServerCtrl:ReqCombinserGiftInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCombineServerGiftInfo)
	protocol:EncodeAndSend()
end

function CombineServerCtrl:ReqBuyGift(gift_pos, gift_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqBuyGift)
	protocol.gift_pos = gift_pos
	protocol.gift_level = gift_level
	protocol:EncodeAndSend()
end

function CombineServerCtrl:OnGetCombineServerGiftInfo(protocol)
	self.data:SetGiftInfoData(protocol)
	self.view:Flush(0, "gift_change")
	GlobalEventSystem:Fire(CombineServerActiviType.GIFT_CHANGE)
end

function CombineServerCtrl:ReqGiftInfo()
	self.data:SetCombineServerGiftConfigData()
	self:ReqCombinserGiftInfo()
end

-- 合服擂台申请报名
function CombineServerCtrl:ReqCombineServerArenaIsEnroll(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCombineServerArenaReq)
	protocol.enroll_type = type
	protocol:EncodeAndSend()
end
-- 下发报名状态
function CombineServerCtrl:OnGetCombineServerArenaEnrollState(protocol)
	self.data:GetCombineServerArenaType(protocol)
end

function CombineServerCtrl:ReqBattleSupport(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBattleSupportReq)
	protocol.num_player = index
	protocol:EncodeAndSend()
end

function CombineServerCtrl:ReqEnterBattle(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterBarrleReq)
	protocol.enter_type = index
	protocol:EncodeAndSend()
end

function CombineServerCtrl:ReqGetArenaInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSArenaReq)
	protocol:EncodeAndSend()
end

function CombineServerCtrl:CloseTip()
	if self.reward_tip then
		if self.reward_tip:IsOpen() then
			self.reward_tip:Close()
		end
	end
end

function CombineServerCtrl:OpenShowRewardView(activedegree)
	if self.reward_tip == nil then 
		self.reward_tip = CombineServerRewardTips.New()
	end
	self.reward_tip:SetData(activedegree)
	self.reward_tip:Open()
end