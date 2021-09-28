GodTempleShenQiData = GodTempleShenQiData or BaseClass(BaseEvent)

function GodTempleShenQiData:__init()
	if GodTempleShenQiData.Instance then
		print_error("[GodTempleShenQiData] Attempt to create singleton twice!")
		return
	end
	GodTempleShenQiData.Instance = self

	self.shenqi_level = -1
	self.old_shenqi_level = -1
	self.next_flush_exp_timestamp = 0
	self.exp = 0

	RemindManager.Instance:Register(RemindName.GodTemple_ShenQi, BindTool.Bind(self.CalcRemind, self))
end

function GodTempleShenQiData:__delete()
	RemindManager.Instance:UnRegister(RemindName.GodTemple_ShenQi)

	GodTempleShenQiData.Instance = nil
end

function GodTempleShenQiData:SetInfo(protocol, is_first)
	self.old_shenqi_level = is_first and protocol.shenqi_level or self.shenqi_level
	self.shenqi_level = protocol.shenqi_level
	self.next_flush_exp_timestamp = protocol.next_flush_exp_timestamp
	self.exp = protocol.exp
end

function GodTempleShenQiData:GetShenQiLevel()
	return self.shenqi_level
end

function GodTempleShenQiData:GetNextFlushExpTimestamp()
	return self.next_flush_exp_timestamp
end

--判断是否已升级
function GodTempleShenQiData:IsLevelUp()
	if self.shenqi_level - self.old_shenqi_level == 1 then
		self.old_shenqi_level = self.shenqi_level
		return true
	end

	return false
end

function GodTempleShenQiData:GetShenQiExp()
	return self.exp
end

function GodTempleShenQiData:CalcRemind()
	local shenqi_info = self:GetShenQiCfgInfoByLevel()
	if shenqi_info == nil then
		return 0
	end

	--经验值满提醒红点
	if self.exp >= shenqi_info.exp_max then
		return 1
	end

	return 0
end

function GodTempleShenQiData:GetShenQiCfgInfoByLevel(level)
	level = level or self.shenqi_level
	local shenqi_cfg = GodTempleData.Instance:GetShenQiCfg()
	return shenqi_cfg[level]
end