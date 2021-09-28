require("game/open_fun/open_fun_data")
OpenFunCtrl = OpenFunCtrl or BaseClass(BaseController)

function OpenFunCtrl:__init()
	if OpenFunCtrl.Instance then
		print_error("[OpenFunCtrl] Attemp to create a singleton twice !")
	end
	OpenFunCtrl.Instance = self
	self.data = OpenFunData.New()
	self:RegisterAllProtocols()
end

function OpenFunCtrl:__delete()
	self.data:DeleteMe()
	OpenFunCtrl.Instance = nil
end

function OpenFunCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAdvanceNoticeInfo, "OnAdvanceNoticeInfo")
end

function OpenFunCtrl:OnAdvanceNoticeInfo(protocol)
	if protocol.notice_type == ADVANCE_NOTICE_TYPE.ADVANCE_NOTICE_TYPE_LEVEL then
		self.data:SetTrailerLastRewardId(protocol.last_fecth_id)
		ViewManager.Instance:FlushView(ViewName.Main, "trailerview")
	else
		self.data:SetDayTrailerLastRewardId(protocol.last_fecth_id)

		--刷新一下主界面图标（功能开启相关）
		GlobalEventSystem:Fire(MainUIEventType.INIT_ICON_LIST)

		ViewManager.Instance:FlushView(ViewName.Main, "flush_open_trailer")

		if self.data:GetIsWaitDayRewardChange() then
			self.data:SetIsWaitDayRewardChange(false)
			ViewManager.Instance:Close(ViewName.TipsDayOpenTrailerView)
			--开始功能开启
			ViewManager.Instance:FlushView(ViewName.Main, "on_open_trigger", {OPEN_FUN_TRIGGER_TYPE.SERVER_DAY, TimeCtrl.Instance:GetCurOpenServerDay()})
			--开始功能引导
			GlobalTimerQuest:AddDelayTimer(function()
				FunctionGuide.Instance:OpenSeverDayFunChange()
			end, 0.1)
		else
			if ViewManager.Instance:IsOpen(ViewName.TipsDayOpenTrailerView) then
				ViewManager.Instance:Flush(ViewName.TipsDayOpenTrailerView)
			end
		end
	end
end

function OpenFunCtrl:SendAdvanceNoitceOperate(operate_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAdvanceNoitceOperate)
	protocol.operate_type = operate_type
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end