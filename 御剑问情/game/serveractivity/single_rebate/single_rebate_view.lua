SingleRebateView =  SingleRebateView or BaseClass(BaseView)

function SingleRebateView:__init()
	self.ui_config = {"uis/views/randomact/singlerebate_prefab", "SingleRebateView"}
	self.play_audio = true
end

function SingleRebateView:__delete()
end

function SingleRebateView:LoadCallBack()
	self:ListenEvent("ClickToRechage", BindTool.Bind(self.ClickToRechage, self))
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self.return_percent = self:FindVariable("return_percent")
	self.rest_time = self:FindVariable("rest_time")
end

function SingleRebateView:OpenCallBack()
	--活动倒计时
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_REBATE)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
        self:SetTime(rest_time)
    end)

    --设置返还百分比
	self.return_percent:SetValue(SingleRebateData.Instance:GetRewardPrecent()) 
    SingleRebateData.Instance.single_rebate_is_open = true
	ViewManager.Instance:FlushView(ViewName.Main, "single_rebate")
end

function SingleRebateView:ReleaseCallBack()
	self.return_percent = nil
	self.rest_time = nil
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
end

--点击前往充值按钮
function SingleRebateView:ClickToRechage()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--设置倒计时
function SingleRebateView:SetTime(rest_time)
	local time_str = ""
	local day_second = 24 * 60 * 60         -- 一天有多少秒
	local left_day = math.floor(rest_time / day_second)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 7)
	elseif rest_time < day_second then
		if math.floor(rest_time / 3600) > 0 then
			time_str = TimeUtil.FormatSecond(rest_time, 1)
		else
			time_str = TimeUtil.FormatSecond(rest_time, 2)
		end
	end
	self.rest_time:SetValue(time_str)
end