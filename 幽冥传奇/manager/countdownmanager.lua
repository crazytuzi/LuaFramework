CountDownManager = CountDownManager or BaseClass()

-- 各自带上模块名组合出一个Key，不要再在这边定义
COWNDOWN_TYPE = {
	MOUNT_LEVELUP = "mount_levelup",
	MENTALITY_LEVELUP = "mentality_levelup",
	CHAT_CD = "chat_cd",
	TRANSMIT_CD = "transmit_cd",
	XIANJIAN_BAJIAN = "xianjian_bajian",
	XIANJIAN_GRADE = "xianjian_grade",
	BOSS_UPDATE = "boss_update",
	MONSTER_UPDATE = "monster_update",
	DAILY_BOSS_UPDATE = "daily_boss_update",
	DAILY_BOSS_WINOW = "daily_boss_window",
	DAILY_BOSS_GUAJI = "daily_boss_guaji",
	LEAVE_SCENE = "leave_scene",
	WELFARE_QIFU = "welfare_qifu",
	GUILD_FB_NEXT_WAVE = "guild_fb_next_wave",
}

function CountDownManager:__init()
	if nil ~= CountDownManager.Instance then
		ErrorLog("[CountDownManager]:Attempt to create singleton twice!")
	end

	CountDownManager.Instance = self

	self.countdown_list = {}

	Runner.Instance:AddRunObj(self, 4)
end

function CountDownManager:__delete()
	CountDownManager.Instance = nil

	self.countdown_list = {}

	Runner.Instance:RemoveRunObj(self)
end

--[[
	key：倒计时唯一标识，可用模块名组合出一个字符串，例："mainui_skill_1"
	timer_func：执行方法(参数：elapse_time, total_time)
	complete_func：完成回调
	complete_time：完成时间
	total_time：总时间
	interval：回调间隔
]]
function CountDownManager:AddCountDown(key, timer_func, complete_func, complete_time, total_time, interval)
	if nil == complete_time and nil == total_time and nil == timer_func and nil == complete_func then
		return
	end

	interval = interval or 1

	if complete_time then
		total_time = complete_time - TimeCtrl.Instance:GetServerTime()
	end

	local cd_info = self.countdown_list[key] or {}
	
	cd_info.is_total = total_time ~= nil --find debug by bzw. 

	cd_info.key = key
	cd_info.timer_func = timer_func
	cd_info.complete_func = complete_func
	cd_info.start_time = Status.NowTime
	cd_info.total_time = total_time
	cd_info.remain_time = total_time
	cd_info.complete_time = complete_time or (TimeCtrl.Instance:GetServerTime() + total_time)
	cd_info.last_callback_time = cd_info.start_time
	cd_info.interval = interval

	self.countdown_list[key] = cd_info
end

function CountDownManager:Update(now_time, elapse_time)
	local update_list = {}
	local complete_list = {}

	for k, v in pairs(self.countdown_list) do
		v.remain_time = v.remain_time - elapse_time
		if v.remain_time < 0 then v.remain_time = 0 end

		if now_time - v.last_callback_time >= v.interval then
			v.last_callback_time = now_time
			if v.timer_func then
				update_list[#update_list + 1] = v
			end
		end

		if v.is_total then
			if now_time >= v.start_time + v.total_time then  --如果是设置completetime也走这里，服务端改时间会造成。这边倒计时不会随着服务端改时间而变化
				complete_list[#complete_list + 1] = v
			end
		else
			if self:GetRemainTime(k) == 0 then
			    complete_list[#complete_list + 1] = v
			end
		end

	end

	for _, v in pairs(update_list) do
		if v.timer_func then
			v.timer_func(v.total_time - v.remain_time, v.total_time)
		end
	end

	for _, v in pairs(complete_list) do
		if v.complete_func ~= nil then
			v.complete_func()
		end
		self.countdown_list[v.key] = nil
	end
end

function CountDownManager:RemoveCountDown(key)
	if key then
		self.countdown_list[key] = nil
	end
end

function CountDownManager:GetRemainTime(key)
	if nil ~= self.countdown_list[key] then
		local remain_time = math.floor(self.countdown_list[key].complete_time - TimeCtrl.Instance:GetServerTime())
		if remain_time < 0 then
			remain_time = 0
		end 
		return remain_time
	end
	return 0
end

function CountDownManager:GetRemainSecond2HMS(key)
	local time = self:GetRemainTime(key)
	return TimeUtil.FormatSecond2HMS(time)
end

function CountDownManager:GetRemainSecond2MS(key)
	local time = self:GetRemainTime(key)
	return TimeUtil.FormatSecond2MS(time)
end

function CountDownManager:HasCountDown(key)
	return nil ~= self.countdown_list[key]
end
