BossXuanShangData = BossXuanShangData or BaseClass()

function BossXuanShangData:__init()
	if BossXuanShangData.Instance then
		ErrorLog("[BossXuanShangData]:Attempt to create singleton twice!")
	end
	BossXuanShangData.Instance = self


	self.xunashang_boss_data = {}
	self.boss_kill_num = 0

end

function BossXuanShangData:__delete()
	BossXuanShangData.Instance = nil
end

function BossXuanShangData:SetXuanShangBossInfo(protocol)
	self.xunashang_boss_data = protocol.xuanshang_data
end

function BossXuanShangData:GetBossData()
	return self.xunashang_boss_data
end

-- 获取boss击杀次数
function BossXuanShangData:GetBossKillNum(index)
	local data = self.xunashang_boss_data[index].kill_info
	self.boss_kill_num = 0
	for k, v in pairs(data) do
		if v.player_id > 0 then
			self.boss_kill_num = self.boss_kill_num + 1
		end
	end
	return self.boss_kill_num, #data
end

-- 获取boss展示奖励
function BossXuanShangData:GetBosskillReward(num, max_num, boss_id)
	local data = BossWantedConfig.bossWanted
	local open_day = OtherData.Instance:GetOpenServerDays()
	local rew_cfg = {}
	for k, v in pairs(data) do
		if open_day <= v.openServerDay[2] and open_day >= v.openServerDay[1] then
			if num == max_num then
				rew_cfg = v.miniAwards
			else
				rew_cfg = v.killAwards
			end
		end
	end

	return rew_cfg[boss_id] or {}
end