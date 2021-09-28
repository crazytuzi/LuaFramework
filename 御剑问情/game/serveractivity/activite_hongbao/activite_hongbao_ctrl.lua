require("game/serveractivity/activite_hongbao/activite_hongbao_data")
-- require("game/serveractivity/activite_hongbao/activite_hongbao_view")

ActiviteHongBaoCtrl = ActiviteHongBaoCtrl or BaseClass(BaseController)

function ActiviteHongBaoCtrl:__init()
	if ActiviteHongBaoCtrl.Instance then
		print_error("[ActiviteHongBaoCtrl]:Attempt to create singleton twice!")
	end
	ActiviteHongBaoCtrl.Instance = self

	self.data = ActiviteHongBaoData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE,
		function()
			self:CheckIsActivite()
		end)
end

function ActiviteHongBaoCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	ActiviteHongBaoCtrl.Instance = nil
end

function ActiviteHongBaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRARedEnvelopeGiftInfo, "OnRARedEnvelopeGiftInfo")
end

function ActiviteHongBaoCtrl:CheckIsActivite()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local recharge_num = DailyChargeData.Instance:GetHistoryRecharge()
	local reward_flag = ActiviteHongBaoData.Instance:GetFlag(open_day)
	-- local get_diamon = math.floor(ActiviteHongBaoData.Instance:GetDiamondNum())
	if IS_ON_CROSSSERVER then MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {false}) return end

	if recharge_num > 0 and reward_flag == ActHongBaoFlag.CanGet then
		MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {true})
	else
		MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {false})
	end
	if open_day > GameEnum.NEW_SERVER_DAYS then
		MainUICtrl.Instance:FlushView("change_act_hongbao_btn", {false})
	elseif open_day > GameEnum.NEW_SERVER_DAYS then
		MainUICtrl.Instance:FlushView("activity_hongbao_ani", {true})
		RemindManager.Instance:Fire(RemindName.ActHongBao)
	end
end

function ActiviteHongBaoCtrl:OnRARedEnvelopeGiftInfo(protocol)
	-- local old_diamon = ActiviteHongBaoData.Instance:GetDiamondNum()
	-- local diff_num = protocol.consume_gold_num - old_diamon
	-- if diff_num > 0 then
	-- MainUICtrl.Instance:FlushView("show_diamondown")
	-- MainUICtrl.Instance:FlushView("activity_hongbao_ani", {true, true})
	-- end
	self.data:SetRARedEnvelopeGiftInfo(protocol)

	-- self:CheckIsActivite()
	KaifuActivityCtrl.Instance:GetView():Flush()
end