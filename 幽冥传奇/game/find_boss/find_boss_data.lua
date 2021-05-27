--------------------------------------------------------
-- 发现BOSS数据
--------------------------------------------------------

FindBossData = FindBossData or BaseClass()

FindBossData.FINDBOSS_DATA_CHANGE = "findboss_data_change"

FindBossData.FINDBOSS_SECOND_KILL_CHANGE = "findboss_second_kill_change"

function FindBossData:__init()
	if FindBossData.Instance then
		ErrorLog("[FindBossData]:Attempt to create singleton twice!")
	end
	FindBossData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		type = 0, -- 事件类型
		times = 0, -- 当天剩余次数
		boss_index = 0, -- 上次抽取的fbid, 0为跨天清除, 可抽取
		extract_time = 0, -- 下次可抽取的倒计时
		enter_time = 0, -- 进入boss场景倒计时
		last_time_lv = 0, -- 上次抽取时的等级
		last_time_zs = 0, -- 上次抽取时的转生
		client_time = 0,
	}
	self.scene_id = 0
	self.can_cast_second_kill = false
end

function FindBossData:__delete()
	FindBossData.Instance = nil
end

----------设置----------

--设置发现boss数据
function FindBossData:SetData(protocol)
	self.data.type = protocol.type
	self.data.times = protocol.times
	self.data.boss_index = protocol.boss_index
	self.data.extract_time = protocol.extract_time
	self.data.enter_time = protocol.enter_time
	self.data.last_time_lv = protocol.last_time_lv
	self.data.last_time_zs = protocol.last_time_zs
	self.data.client_time = protocol.client_time
	if self.data.enter_time > 0 or self.data.extract_time > 0 then
		self:DelayGetInfo()
	end
	self:DispatchEvent(FindBossData.FINDBOSS_DATA_CHANGE)
end

-- 自动请求信息
function FindBossData:DelayGetInfo()
	local time = self:GetEnterTime() + self:GetExtractTime()
	if self.get_info_timer then
		GlobalTimerQuest:CancelQuest(self.get_info_timer)
	end
	self.get_info_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ClearTimerAndGetInfo, self), time + 0.5)
end

-- 清除倒计时并请求信息
function FindBossData:ClearTimerAndGetInfo()
	if self.get_info_timer then
		GlobalTimerQuest:CancelQuest(self.get_info_timer)
		self.get_info_timer = nil
	end
	-- FindBossCtrl.Instance:SendDiamondsCreateReq(1)
end

--获取打造结果
function FindBossData:GetData()
	return self.data
end

-- 下次可抽取的倒计时
function FindBossData:GetExtractTime()
	local now_left_time = self.data.extract_time - (Status.NowTime - self.data.client_time)
	return math.max(now_left_time, 0)
end

-- 进入boss场景倒计时
function FindBossData:GetEnterTime()
	local now_left_time = self.data.enter_time - (Status.NowTime - self.data.client_time)
	return math.max(now_left_time, 0)
end

-- 获取秒杀BOSS按钮状态
function FindBossData:GetSecondKillBtnState()
	local cur_scene_id = Scene.Instance:GetSceneId()
	if cur_scene_id ~= self.scene_id then
		self.scene_id = cur_scene_id
		self.can_cast_second_kill = true
	end
	if Scene.Instance:GetSceneLogic():CanShowSecondKillIcon() then
		if self.can_cast_second_kill then
			return 1
		else
			return 2
		end
	else
		return 3
	end
end

function FindBossData:GetSecondKillConsume()
	if 0 == self.data.boss_index then return 0 end
	local boss_list_index
	if self.data.last_time_zs > 0 then
		boss_list_index = self.data.last_time_zs
	else
		boss_list_index = self.data.last_time_lv > 79 and 80 or 70
	end
	local boss_cfg = RandomBossCfg and RandomBossCfg.bossInfo
	if nil == boss_cfg then return 0 end
	return boss_cfg[boss_list_index][self.data.boss_index].secondKillYb
end

-- 设置是否可以施放秒杀
function FindBossData:SetCanCastSecondKill(state)
	self.can_cast_second_kill = state
	self:DispatchEvent(FindBossData.FINDBOSS_SECOND_KILL_CHANGE)
end
--------------------
