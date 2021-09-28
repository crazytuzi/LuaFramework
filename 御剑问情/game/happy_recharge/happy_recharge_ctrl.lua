require("game/happy_recharge/happy_recharge_data")
require("game/happy_recharge/happy_recharge_view")
require("game/happy_recharge/happy_record_list_view")
HappyRechargeCtrl = HappyRechargeCtrl or BaseClass(BaseController)

function HappyRechargeCtrl:__init()
	if HappyRechargeCtrl.Instance then
		print_error("[HappyRechargeCtrl] Attemp to create a singleton twice !")
	end
	HappyRechargeCtrl.Instance = self
	self.data = HappyRechargeData.New()
	self.view = HappyRechargeView.New(ViewName.HappyRechargeView)
	self.record_list_view = HappyRecordListView.New(ViewName.HappyRecordListView)
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function HappyRechargeCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	 if self.record_list_view ~= nil then
        self.record_list_view:DeleteMe()
        self.record_list_view = nil
    end

	HappyRechargeCtrl.Instance = nil

	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	
end

function HappyRechargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRANiuEggInfo, "OnSCRANiuEggInfo")
	self:RegisterProtocol(SCRANiuEggChouResultInfo, "OnSCRANiuEggChouResultInfo")
end

function HappyRechargeCtrl:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(rand_activity_type, opera_type, param_1, param_2)
end

function HappyRechargeCtrl:OnSCRANiuEggInfo(protocol)
	self.data:SetNiuEggInfo(protocol)
	self.view:Flush()
end

function HappyRechargeCtrl:OnSCRANiuEggChouResultInfo(protocol)
	self.data:SetRewardListInfo(protocol.reward_req_list)
	if protocol.reward_req_list_count > 1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.HAPPY_RECHARGE_10)
	elseif protocol.reward_req_list_count == 1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.HAPPY_RECHARGE_1)
	end
end

function HappyRechargeCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)
	if is_open then
		-- 请求记录信息
	 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE, 0)
	end
end