require("game/daily_charge/daily_charge_content_view")
DailyChargeView = DailyChargeView or BaseClass(BaseView)

function DailyChargeView:__init()
	self.ui_config = {"uis/views/dailychargeview_prefab","DailyChargeView"}
	self.full_screen = false
end

function DailyChargeView:__delete()
	if self.daily_charge_content_view then
		self.daily_charge_content_view:DeleteMe()
		self.daily_charge_content_view = nil
	end
end

function DailyChargeView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseClick, self))
	self.daily_charge_content_view = DailyChargeContentView.New(self:FindObj("daily_charge_content_view"))
end

function DailyChargeView:ReleaseCallBack()
	if self.daily_charge_content_view then
		self.daily_charge_content_view:DeleteMe()
		self.daily_charge_content_view = nil
	end
end

function DailyChargeView:OnFlush(param_list)
	if self.daily_charge_content_view then
		self.daily_charge_content_view:Flush()
	end
end

function DailyChargeView:OnCloseClick()
	self:Close()
end

function DailyChargeView:OpenCallBack()
	self.daily_charge_content_view:OpenCallBack()
	-- local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- if cur_day > -1 then
	-- 	UnityEngine.PlayerPrefs.SetInt("daily_charge_remind_day", cur_day)
	-- 	RemindManager.Instance:Fire(RemindName.DailyCharge)
	-- end
	if not DailyChargeData.hasOpenDailyRecharge then
		DailyChargeData.hasOpenDailyRecharge = true
		RemindManager.Instance:Fire(RemindName.DailyCharge)
	end
end