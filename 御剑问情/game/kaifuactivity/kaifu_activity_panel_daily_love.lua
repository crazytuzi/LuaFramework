OpenActDailyLove =  OpenActDailyLove or BaseClass(BaseRender)

function OpenActDailyLove:__init()
	self:ListenEvent("ClickToRechage", BindTool.Bind(self.ClickToRechage, self))
	self.return_percent = self:FindVariable("return_percent")
end

function OpenActDailyLove:__delete()
end

function OpenActDailyLove:OpenCallBack()
	--活动倒计时
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_LOVE)
	self.rest_time = self:FindVariable("rest_time")
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
    local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
    if cfg then
    	self.return_percent:SetValue(cfg.daily_love_reward_precent) 
    end
    KaifuActivityData.Instance.daily_love_is_open = true
	ViewManager.Instance:FlushView(ViewName.Main, "daily_love")
end

function OpenActDailyLove:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
end

--点击前往充值按钮
function OpenActDailyLove:ClickToRechage()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end
--设置倒计时
function OpenActDailyLove:SetTime(rest_time)
	-- local time_str = ""
	-- local left_day = math.floor(rest_time / 86400)
	-- if left_day > 0 then
	-- 	time_str = TimeUtil.FormatSecond(rest_time, 8)
	-- else
	-- 	time_str = TimeUtil.FormatSecond(rest_time)
	-- end
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
