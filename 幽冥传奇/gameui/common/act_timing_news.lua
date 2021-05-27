-- 开服传闻多次播报
ActTimingNews = ActTimingNews or BaseClass()
function ActTimingNews:__init()
	self.show_time = 0
	self.loading_event = GlobalEventSystem:Bind(LoginEventType.LOADING_COMPLETED, BindTool.Bind1(self.OnLoadingComplete, self))
end

function ActTimingNews:__delete()
	Runner.Instance:RemoveRunObj(self)
	GlobalEventSystem:UnBind(self.loading_event)
end

function ActTimingNews:OnLoadingComplete()
	Runner.Instance:AddRunObj(self, 8)
end

function ActTimingNews:Update(now_time, elapse_time)
	if (self.show_time > 0 and math.abs(now_time - self.show_time) < 30) or
		(nil ~= self.prve_time and math.abs(now_time - self.prve_time) < 1) then return end

	self.prve_time = now_time

	local sever_time = TimeCtrl.Instance:GetServerTime()
	local format_time = os.date("*t", sever_time) 			--获取年月日时分秒的表
	local end_zero_time = os.time{year=format_time.year, month=format_time.month, day=format_time.day, hour=0, min = 0, sec=0}
	end_zero_time = end_zero_time or 0

	local sever_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local week_number = tonumber(os.date("%w", sever_time)) 		--获取星期几

	local cur_sever_open_cfg = self:GetCfgBySeverOpenday(sever_open_day) or {}
	local cur_weeks_cfg = self:GetCfgByWeeks(week_number) or {}

	for _, cfg in pairs({cur_sever_open_cfg, cur_weeks_cfg}) do
		for k,v in pairs(cfg) do
			local i = 1
			while true do
				if v["time" .. i] == nil then return end
				
				local time_tab = Split(v["time" .. i], ":")
				local h,m = tonumber(time_tab[1] or 0), tonumber(time_tab[2] or 0)
				if h and m then
					if math.abs(sever_time - end_zero_time - h * 60 * 60 - m * 60) < 1 then
						SysMsgCtrl.Instance:RollingEffect(v.content, GUNDONGYOUXIAN.CFG_TYPE)
						self.show_time = now_time
						return
					end
				end
				i = i + 1
			end
		end
	end

end

-- 根据开服时间获取配置
function ActTimingNews:GetCfgBySeverOpenday(day)
	local open_news_cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("show_news_auto").show_cfg) do
		if v and v.open_day <= day and v.close_day >= day then
			table.insert(open_news_cfg, v)
		end
	end
	return open_news_cfg
end

-- 根据周数获取配置
function ActTimingNews:GetCfgByWeeks(day)
	local weeks_news_cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("show_news_auto").show_cfg) do
		if v and 0 == v.open_day and v.week_day == day then
			table.insert(weeks_news_cfg, v)
		end
	end
	return weeks_news_cfg
end
