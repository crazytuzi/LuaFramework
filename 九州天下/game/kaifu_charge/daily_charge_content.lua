 DailyChargeContent =  DailyChargeContent or BaseClass(BaseRender)

function DailyChargeContent:__init()
	self.ui_config = {"uis/views/kaifuchargeview", "DailyChargeContent"}
end

function DailyChargeContent:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function DailyChargeContent:LoadCallBack()
	self:ListenEvent("OnClickCharge", BindTool.Bind(function () 
			ViewManager.Instance:Open(ViewName.RechargeView)
	end, self))
	self.gray_use_button = self:FindObj("GrayButton")
	self.rest_time = self:FindVariable("Time")
	self.num = self:FindVariable("num")
	self.text = self:FindVariable("text")
	self.btn_state = self:FindVariable("btn_state")
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_DAILY_LOVE)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
		self:SetTime(rest_time)
		end)
	self.num:SetValue(KaiFuChargeData.Instance:DailyLovePrecent())
	self:Flush()
end

function DailyChargeContent:OnFlush()
	local state = KaiFuChargeData.Instance:IsOpenDailyCharge()
	local str = state and Language.AdventureShop.DailyCharge or Language.AdventureShop.DrawLater
	self.text:SetValue(str)
	self.btn_state:SetValue(state)
	self.gray_use_button.button.interactable = state
end

function DailyChargeContent:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(str)
end
