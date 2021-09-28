KuaFuXiuLuoTowerData = KuaFuXiuLuoTowerData or BaseClass()

function KuaFuXiuLuoTowerData:__init()
	self.rank_list = {}
	if KuaFuXiuLuoTowerData.Instance ~= nil then
		print_error("[KuaFuXiuLuoTowerData] attempt to create singleton twice!")
		return
	end
	KuaFuXiuLuoTowerData.Instance = self
	self:SetXiuLuoTowerCfg()

	self.luabit = require"bit"

	self.attr_info = {
		buy_realive_count = 0,
		add_gongji_per = 0,
		add_hp_per = 0
	}
	self.immediate_realive_count = 0
	self.max_layer = 0
	self.boss_num = 0
	self.refresh_boss_time = 0
	self.cur_layer = 0
	self.gather_buff_end_timestamp = 0
	self.gather_info_list = {}
	self.gather_id_list = {}
	self.xiuluo_log = nil
	local config = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	if config then
		self.gather_id_list[config.goldbox_id] = 1
		self.gather_id_list[config.Agbox_id] = 2
		self.gather_id_list[config.woodbox_id] = 3
	end
end

function KuaFuXiuLuoTowerData:__delete()
	KuaFuXiuLuoTowerData.Instance = nil

	if self.xiuluo_count_down then
		CountDown.Instance:RemoveCountDown(self.xiuluo_count_down)
		self.xiuluo_count_down = nil
	end
end


function KuaFuXiuLuoTowerData:GetXiuLuoTowerOpenTimeCfg()
	local time_cfg = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.KF_XIULUO_TOWER)
	return time_cfg
end

function KuaFuXiuLuoTowerData:SetBuffInfo(protocol)
	local role = Scene.Instance:GetObj(protocol.id)
	role:ReloadSpecialImage()
end

function KuaFuXiuLuoTowerData:SetXiuLuoTowerCfg()
	self.xiuluo_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto")
end

--获取最高层数
function KuaFuXiuLuoTowerData:GetMaxLayer()
	local count = 0
	for k,v in pairs(self.xiuluo_cfg.show_cfg) do
		count = count + 1
	end
	return count
end

--获取当前是否会掉层数
function KuaFuXiuLuoTowerData:GetIsDropLayer(layer)
	return layer == 1 or layer == 4 or layer == 7 or layer == 8
end

-- 设置属性加成信息
function KuaFuXiuLuoTowerData:SetAttrInfo(info)
	self.attr_info.buy_realive_count = info.buy_realive_count
	self.attr_info.add_gongji_per = info.add_gongji_per
	self.attr_info.add_hp_per = info.add_hp_per
end


-- 获取属性加成信息
function KuaFuXiuLuoTowerData:GetAttrInfo()
	return self.attr_info
end

--获取当前可领取的奖励
function KuaFuXiuLuoTowerData:GetCanGetReward()
	for k,v in pairs(self.xiuluo_cfg.score) do
		if self.score >= v.score then
			if self.luabit.band(self.score_reward_flag, self.luabit.lshift(1, v.index)) == 0 then
				return true, v.index
			end
		else
			return false, 0
		end
	end
	return false, 1
end

--获取当前可领取的奖励(UI显示)
function KuaFuXiuLuoTowerData:GetCanGetRewardUI()
	for k,v in ipairs(self.xiuluo_cfg.score) do
		if self.score < v.score then
			return v, k
		end
	end
	return nil
end

function KuaFuXiuLuoTowerData:GetReward()
	local total_reward = nil
	local index = 0
	for k,v in ipairs(self.xiuluo_cfg.score) do
		if self.score >= v.score then
			if total_reward then
				for i = 1, 3 do
					local item = v["reward_item" .. i]
					local flag = true
					for k2,v2 in pairs(total_reward.reward_item) do
						if item.item_id == v2.item_id then
							v2.num = v2.num + item.num
							flag = false
							break
						end
					end
					if flag then
						total_reward.reward_item["reward_item" .. index + 1] = TableCopy(item)
						index = index + 1
					end
				end
			else
				total_reward = {}
				total_reward.reward_item = {}
				for i = 1, 3 do
					local item = v["reward_item" .. i]
					total_reward.reward_item["reward_item" .. i] = {}
					for k2,v2 in pairs(item) do
						total_reward.reward_item["reward_item" .. i][k2] = v2
					end
					index = index + 1
				end
			end
		else
			break
		end
	end
	local kill_role_count = KuaFuXiuLuoTowerData.Instance:GetAllKillRoleCount()
	local kill_one_honor = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1].Kill_rongyao
	local all_honor = kill_role_count * kill_one_honor
	all_honor = all_honor > 2000 and 2000 or all_honor
	if total_reward then
		local find = false
		for k,v in pairs(total_reward.reward_item) do
			if v.item_id == ResPath.CurrencyToIconId["weiwang"] then
				v.num = v.num + all_honor
				find = true
				break
			end
		end
		if not find then
			table.insert(total_reward.reward_item, {item_id = ResPath.CurrencyToIconId["weiwang"], num = all_honor})
		end
	else
		total_reward = {}
		total_reward.reward_item = {}
		table.insert(total_reward.reward_item, {item_id = ResPath.CurrencyToIconId["weiwang"], num = all_honor})
	end
	return total_reward
end

--根据层数获取层数Cfg
function KuaFuXiuLuoTowerData:GetLayerCfgByLayer(layer)
	for k,v in pairs(self.xiuluo_cfg.show_cfg) do
		if layer == v.show_id then
			return v
		end
	end
end

--设置排行榜信息
function KuaFuXiuLuoTowerData:SetRankList(protocol)
	for k,v in pairs(self.rank_list) do
		self.rank_list[k] = nil
	end
	for k,v in pairs(protocol.rank) do
		self.rank_list[k] = v
	end
	print(ToColorStr("设置排行榜信息", TEXT_COLOR.PURPLE))
end

--获取排行榜信息
function KuaFuXiuLuoTowerData:GetRankList()
	return self.rank_list
end

--获取当前层数
function KuaFuXiuLuoTowerData:GetCurrentLayer()
	return self.cur_layer + 1
end

--获取当前层数
function KuaFuXiuLuoTowerData:GetHistoryMaxLayer()
	return self.max_layer + 1
end

--获取boss数量
function KuaFuXiuLuoTowerData:GetBossNum()
	return self.boss_num
end

--获取boss刷新时间
function KuaFuXiuLuoTowerData:GetBossRefreshTime()
	return self.refresh_boss_time
end

--获取无敌采集结束时间
function KuaFuXiuLuoTowerData:GetBossGatherEndTime()
	return self.gather_buff_end_timestamp
end
--获取击杀数
function KuaFuXiuLuoTowerData:GetCurrentLayerKillCount()
	return self.cur_layer_kill_count
end

--获取击杀数
function KuaFuXiuLuoTowerData:GetAllKillRoleCount()
	return self.kill_role_count
end

--获取积分数
function KuaFuXiuLuoTowerData:GetScoreValue()
	return self.score
end

function KuaFuXiuLuoTowerData:OnXiuLuoSelfInfo(protocol)
	self.cur_layer = protocol.cur_layer
	self.max_layer = protocol.max_layer
	self.immediate_realive_count = protocol.immediate_realive_count
	self.boss_num = protocol.boss_num
	self.total_kill_count = protocol.total_kill_count
	self.kill_role_count = protocol.kill_role_count
	self.cur_layer_kill_count = protocol.cur_layer_kill_count
	self.reward_cross_honor = protocol.reward_cross_honor
	self.score = protocol.score
	self.score_reward_flag = protocol.score_reward_flag
	self.refresh_boss_time = protocol.refresh_boss_time
	self.gather_buff_end_timestamp = protocol.gather_buff_end_timestamp

	local now_time = TimeCtrl.Instance:GetServerTime()
	local seconds = math.floor(self.gather_buff_end_timestamp - now_time)
	if seconds >= 0 then
		local main_role = Scene.Instance:GetMainRole()
		main_role:ChangeXiuLuoWuDiGather(1)
	end
end

-- 获取原地复活次数
function KuaFuXiuLuoTowerData:GetKuaFuXiuLuoTaNum()
	local fuhuo_count = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1].fuhuo_count
	return fuhuo_count + self.attr_info.buy_realive_count - self.immediate_realive_count
end


function KuaFuXiuLuoTowerData:GetReviveTxt()
	local fuhuo_count = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1].fuhuo_count
	local has_count = fuhuo_count + self.attr_info.buy_realive_count - self.immediate_realive_count
	if has_count > 0 then
		return string.format(Language.Honorhalls.FuhuoTips8, has_count, fuhuo_count + self.attr_info.buy_realive_count)
	end
	return nil
end

function KuaFuXiuLuoTowerData:GetGuajiXY()
	local config = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	return config.guaji_x, config.guaji_y
end

function KuaFuXiuLuoTowerData:GetMonsterID()
	local config = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	return config.boss_id or 0
end

function KuaFuXiuLuoTowerData:GetItemID()
	local config = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	return config or {}
end

function KuaFuXiuLuoTowerData:GetBossReward()
	local config = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	local reward_list = config and config.boss_diao or {}
	return reward_list
end

function KuaFuXiuLuoTowerData:GetGatherBoxReward()
	local config = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	local gather_reward_list = config and config.box_diao or {}
	return gather_reward_list
end

function KuaFuXiuLuoTowerData:SetGatherInfo(protocol)
	self.gather_info_list = protocol.info_list
end

function KuaFuXiuLuoTowerData:GetGatherInfo()
	return self.gather_info_list
end

function KuaFuXiuLuoTowerData:GetGatherIndex(gather_id)
	return self.gather_id_list[gather_id] or 1
end

function KuaFuXiuLuoTowerData:GetCurLayerDes()
	local cur_layer = self:GetCurrentLayer()
	if cur_layer and cur_layer > 0 then
		for k,v in pairs(self.xiuluo_cfg.show_cfg) do
			if cur_layer == v.show_id then
				return v.if_drop == 0
			end
		end
	end
	return nil
end

function KuaFuXiuLuoTowerData:SendXiuLuoTowerLog(protocol)
	self.xiuluo_log = protocol
end

function KuaFuXiuLuoTowerData:GetXiuLuoTowerLog()
	return self.xiuluo_log
end

function KuaFuXiuLuoTowerData:IsShowTitle(time)
	if nil == time then
		time = 0
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local seconds = math.floor(time - now_time)
	if self.xiuluo_count_down then
		CountDown.Instance:RemoveCountDown(self.xiuluo_count_down)
		self.xiuluo_count_down = nil
	end
	self.xiuluo_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.TitleBuffTimeCountDown, self))
end

function KuaFuXiuLuoTowerData:TitleBuffTimeCountDown(elapse_time, total_time)
	local diff_timer = total_time - elapse_time
	if diff_timer <= 0 then
		local main_role = Scene.Instance:GetMainRole()
		main_role:ChangeXiuLuoWuDiGather(0)
		if self.xiuluo_count_down then
			CountDown.Instance:RemoveCountDown(self.xiuluo_count_down)
			self.xiuluo_count_down = nil
		end
	end
end