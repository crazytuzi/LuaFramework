require("game/fanfanzhuan/fanfanzhuan_data")
require("game/fanfanzhuan/fanfanzhuan_view")
FanFanZhuanCtrl = FanFanZhuanCtrl or BaseClass(BaseController)

function FanFanZhuanCtrl:__init()
	if FanFanZhuanCtrl.Instance then
		print_error("[FanFanZhuanCtrl] Attemp to create a singleton twice !")
	end
	FanFanZhuanCtrl.Instance = self
	self.data = FanFanZhuanData.New()
	self.view = FanFanZhuanView.New(ViewName.FanFanZhuanView)
	self:RegisterAllProtocols()

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function FanFanZhuanCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	FanFanZhuanCtrl.Instance = nil
end

function FanFanZhuanCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAKingDrawInfo, "OnSCRAKingDrawInfo")			 --翻翻转
	self:RegisterProtocol(SCRAKingDrawMultiReward, "OnSCRAKingDrawMultiReward")			 
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

-- 主界面创建
function FanFanZhuanCtrl:MainuiOpenCreate()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO)
	end
end

function FanFanZhuanCtrl:OnSCRAKingDrawInfo(protocol)
	self.data:SetKingDrawInfoInfo(protocol)
	self.view:Flush()
	--self.data:FlushHallRedPoindRemind()
	RemindManager.Instance:Fire(RemindName.RemindFanFanZhuan)
end

function FanFanZhuanCtrl:OnSCRAKingDrawMultiReward(protocol)
	-- FanFanZhuanData.Instance:SetTreasureItemList(protocol.chest_item_info)
	-- TipsCtrl.Instance:ShowTreasureView(TreasureData.Instance:GetChestShopMode())
end

function FanFanZhuanCtrl:IsOpen()
	return self.view:IsOpen()
end

function FanFanZhuanCtrl:Flush()
	self.view:Flush()
end

function FanFanZhuanCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO)
	end 
end

