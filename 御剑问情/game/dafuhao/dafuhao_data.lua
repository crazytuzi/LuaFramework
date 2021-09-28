DaFuHaoData = DaFuHaoData or BaseClass()

DaFuHaoDataActivityId = {
	ID = 25
}

function DaFuHaoData:__init()
	if DaFuHaoData.Instance then
		print_error("[DaFuHaoData] Attempt to create singleton twice!")
		return
	end
	DaFuHaoData.Instance = self

	self.table_info = {}			--转盘信息
	self.reward_info = {}
	self.boss_flush_data = {}
	self.dafuhao_info = {}
	self.flush_time = 0
	self.gather_box_id_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("millionaire_auto").gather_box_cfg, "gather_id")
end

function DaFuHaoData:__delete()
	DaFuHaoData.Instance = nil
end

-- 幸运转盘活动信息
function DaFuHaoData:SetTurnTableInfo(protocol)
	self.table_info = protocol
end

function DaFuHaoData:GetRollerInfo()
	return self.table_info or {}
end

function DaFuHaoData:SetTurnTableRewardInfo(protocol)
	self.reward_info = protocol
end

function DaFuHaoData:GetTurnTableRewardInfo()
	return self.reward_info or {}
end

function DaFuHaoData:SetDaFuHaoInfo(protocol)
	self.dafuhao_info = protocol
end

function DaFuHaoData:GetDaFuHaoInfo()
	return self.dafuhao_info
end

function DaFuHaoData:SetFlushTime(flush_time)
	self.flush_time = flush_time
end

function DaFuHaoData:GetFlushDiffTime()
	return self.flush_time - TimeCtrl.Instance:GetServerTime()
end

function DaFuHaoData:SetBossFlushData(protocol)
	self.boss_flush_data = protocol
end

function DaFuHaoData:GetBossFlushData()
	return self.boss_flush_data
end


-- 获取摇奖配置信息
function DaFuHaoData:GetTurnTableCfg()
	return ConfigManager.Instance:GetAutoConfig("turntable_auto").reward_cfg
end

function DaFuHaoData:GetDaFuHaoCfg()
	if not self.dafuhao_config then
		self.dafuhao_config = ConfigManager.Instance:GetAutoConfig("millionaire_auto")
	end
	return self.dafuhao_config
end

function DaFuHaoData:IsDaFuHaoBox(gather_id)
	return self.gather_box_id_cfg[gather_id] ~= nil
end

function DaFuHaoData:GetDaFuHaoSpecialRewardCfg()
	if self.dafuhao_info == nil or next(self.dafuhao_info) == nil then return nil end
	local dafuhao_cfg = self:GetDaFuHaoCfg()
	for k, v in pairs(dafuhao_cfg.extra_reaward) do
		if v.extra_index >= dafuhao_cfg.other[1].role_gather_max_time then
			return v
		end
		if v.extra_index > self.dafuhao_info.gather_total_times then
			return v
		end
	end
	return nil
end

function DaFuHaoData:ClearInfo()
	self.dafuhao_info = {}
	self.reward_info = {}
	self.table_info = {}
end

function DaFuHaoData:GetLimitLevel()
	local level = 0
	local config = self:GetDaFuHaoCfg()
	if config then
		level = config.other[1].level_limit
	end
	return level
end

function DaFuHaoData:GetDaFuHaoOtherCfg()
	if nil ~= self:GetDaFuHaoCfg() then
		return self:GetDaFuHaoCfg().other[1]
	end
	return nil
end

-- 冰冻技能总次数
function DaFuHaoData:GetSkillTotalTimes()
	local cfg = self:GetDaFuHaoOtherCfg()
	if nil == cfg then return 0 end

	return cfg.frozen_time
end

function DaFuHaoData:GetSkillRestTimes()
	if nil == self.dafuhao_info.millionaire_use_skill_times then
		return 0
	end
	return self:GetSkillTotalTimes() - self.dafuhao_info.millionaire_use_skill_times
end

-- 冰冻技能CD
function DaFuHaoData:GetSkillCD()
	local cfg = self:GetDaFuHaoOtherCfg()
	if nil == cfg then return 0 end

	return cfg.frozen_cloddown_time
end

function DaFuHaoData:GetBossID()
	local cfg = self:GetDaFuHaoOtherCfg()
	if nil == cfg then return 0 end

	return cfg.boss_id
end

function DaFuHaoData:GetSkillDistance()
	local cfg = self:GetDaFuHaoOtherCfg()
	if nil == cfg then return 0 end

	return cfg.frozen_distance
end

-- 是否是大富豪场景
function DaFuHaoData:IsDaFuHaoScene()
	if not self:GetDaFuHaoCfg() then
		return false
	end

	local scene_id = Scene.Instance:GetSceneId()
	return self:GetDaFuHaoOtherCfg().scene_id == scene_id
end

-- 是否可以参加大富豪
function DaFuHaoData:IsCanJoinDaFuHao()
	local activity_cfg = ActivityData.Instance:GetActivityConfig(DaFuHaoDataActivityId.ID)
	if not activity_cfg then
		return false
	end

	local level_limit = activity_cfg.min_level
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.level >= level_limit then
		return true
	end

	return false
end

-- 是否达到采集次数上限
function DaFuHaoData:IsGatherTimesLimit()
	if not self.dafuhao_info or nil == next(self.dafuhao_info) then
		return true
	end

	if not self:GetDaFuHaoCfg() then
		return true
	end

	if self.dafuhao_info.gather_total_times >= self:GetDaFuHaoOtherCfg().role_gather_max_time then
		return true
	end

	return false
end

function DaFuHaoData:IsDaFuHaoOpen()
	return ActivityData.Instance:GetActivityIsOpen(DaFuHaoDataActivityId.ID)
end

function DaFuHaoData:IsShowDaFuHao()
	if self:IsDaFuHaoScene() and self:IsCanJoinDaFuHao() and self:IsDaFuHaoOpen() and not self:IsGatherTimesLimit() then
		return true
	end
	return false
end

function DaFuHaoData:IsDaFuHaoGather(obj)
	local cfg = self:GetDaFuHaoCfg().gather_box_cfg or {}
	for k, v in pairs(cfg) do
		if obj:IsGather() and obj:GetGatherId() and v.gather_id == obj:GetGatherId() then
			return true
		end
	end

	return false
end