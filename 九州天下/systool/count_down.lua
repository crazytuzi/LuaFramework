-- 倒计时

CountDown = CountDown or BaseClass()

function CountDown:__init()
	if nil ~= CountDown.Instance then
		print_error("[CountDown]:Attempt to create singleton twice!")
	end
	CountDown.Instance = self

	self.countdown_list = {}
	Runner.Instance:AddRunObj(self, 4)
end

function CountDown:__delete()
	CountDown.Instance = nil
	self.countdown_list = {}
	Runner.Instance:RemoveRunObj(self)
end

-- total_time：总时间
-- interval：回调间隔
-- timer_func：执行方法(参数:elapse_time, total_time)
-- return key
function CountDown:AddCountDown(total_time, interval, timer_func)
	if nil == timer_func then
		return
	end

	local cd_info = {
		total_time = total_time or 0,
		interval = interval or 0,
		elapse_time = 0,
		timer_func = timer_func,
		last_callback_time = Status.NowTime,
	}

	self.countdown_list[cd_info] = cd_info
	return cd_info
end

function CountDown:Update(now_time, elapse_time)
	local update_list = {}

	for k, v in pairs(self.countdown_list) do
		v.elapse_time = v.elapse_time + elapse_time
		if v.elapse_time >= v.total_time then
			v.elapse_time = v.total_time
			self.countdown_list[k] = nil
			table.insert(update_list, v)
		elseif now_time - v.last_callback_time >= v.interval then
			v.last_callback_time = now_time
			table.insert(update_list, v)
		end
	end

	for _, v in pairs(update_list) do
		v.timer_func(v.elapse_time, v.total_time)
	end
end

function CountDown:RemoveCountDown(key)
	if key == nil then return end
	self.countdown_list[key] = nil
end

function CountDown:SetElapseTime(key, elapse_time)
	if nil ~= self.countdown_list[key] then
		self.countdown_list[key].elapse_time = elapse_time
	end
end

function CountDown:GetRemainTime(key)
	if nil ~= self.countdown_list[key] then
		return self.countdown_list[key].total_time - self.countdown_list[key].elapse_time
	end
	return 0
end

function CountDown:HasCountDown(key)
	return nil ~= self.countdown_list[key]
end

function CountDown:IsExistCallback(callback)
	for _, v in pairs(self.countdown_list) do
		if v.timer_func == callback then
			return true
		end
	end

	return false
end
