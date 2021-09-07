require("game/serveractivity/activite_hongbao/activite_hongbao_data")
require("game/serveractivity/activite_hongbao/activite_hongbao_view")

ActiviteHongBaoCtrl = ActiviteHongBaoCtrl or BaseClass(BaseController)

function ActiviteHongBaoCtrl:__init()
	if ActiviteHongBaoCtrl.Instance then
		print_error("[ActiviteHongBaoCtrl]:Attempt to create singleton twice!")
	end
	ActiviteHongBaoCtrl.Instance = self

	self.view = ActiviteHongBaoView.New(ViewName.ActiviteHongBao)
	self.data = ActiviteHongBaoData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE,
		function()
			self:CheckIsActivite()
		end)
end

function ActiviteHongBaoCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	ActiviteHongBaoCtrl.Instance = nil
end

function ActiviteHongBaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRARedEnvelopeGiftInfo, "OnRARedEnvelopeGiftInfo")
end

function ActiviteHongBaoCtrl:CheckIsActivite()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local recharge_num = DailyChargeData.Instance:GetHistoryRecharge()
	local reward_flag = ActiviteHongBaoData.Instance:GetFlag()
	-- local get_diamon = math.floor(ActiviteHongBaoData.Instance:GetDiamondNum())

	-- if IS_ON_CROSSSERVER then MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {false}) return end

	-- if recharge_num > 0 and reward_flag == ActHongBaoFlag.CanGet then
	-- 	MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {true})
	-- else
	-- 	MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {false})
	-- end
	-- if open_day > GameEnum.NEW_SERVER_DAYS and get_diamon <= 0 then
	-- 	MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {false})
	-- elseif open_day > GameEnum.NEW_SERVER_DAYS then
	-- 	MainUICtrl.Instance:FlushView("activity_hongbao_ani", {true})
	-- 	RemindManager.Instance:Fire(RemindName.ActHongBao)
	-- end
end

function ActiviteHongBaoCtrl:OnRARedEnvelopeGiftInfo(protocol)
	-- local old_diamon = ActiviteHongBaoData.Instance:GetDiamondNum()
	-- local diff_num = protocol.consume_gold_num - old_diamon
	-- if diff_num > 0 then
	-- 	MainUICtrl.Instance:FlushView("show_diamondown")
	-- 	MainUICtrl.Instance:FlushView("activity_hongbao_ani", {true, true})
	-- end
	KaiFuChargeData.Instance:SetRARedEnvelopeGiftInfo(protocol)
	self.data:SetRARedEnvelopeGiftInfo(protocol)
	-- self:CheckIsActivite()
	-- self.view:Flush()
	KaifuActivityCtrl.Instance:GetView():Flush()
	KaiFuChargeCtrl.Instance:Flush("kaifu_day_red_packets")
	RemindManager.Instance:Fire(RemindName.RewardSeven)
end

function ActiviteHongBaoCtrl:ActivityCallBack(activity_type, status, next_time, open_type)

	-- 屏蔽开服红包活动
	-- if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO then
	-- 	self:OpenBtn()
	-- end
end

function ActiviteHongBaoCtrl:OpenBtn()
	local is_show = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO) and OpenFunData.Instance:CheckIsHide("kaifuactivityview")
	MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {is_show})
end