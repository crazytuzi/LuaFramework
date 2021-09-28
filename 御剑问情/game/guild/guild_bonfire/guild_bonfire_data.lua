GuildBonfireData = GuildBonfireData or BaseClass()

function GuildBonfireData:__init()
	if GuildBonfireData.Instance then
		ErrorLog("[GuildBonfireData] attempt to create singleton twice!")
		return
	end
	GuildBonfireData.Instance = self
	self.hejiu_time = 0
	self.jiacai_time = 0
	self.guild_bonfire_mucai_times = {}
end

function GuildBonfireData:__delete()
	GuildBonfireData.Instance = nil
end

function GuildBonfireData:GetBonfireOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("guildbonfire_auto").other_cfg[1]
end

function GuildBonfireData:SendSkillTimeInfo(protocol)
	self.hejiu_time = protocol.next_gather_time or 0
	self.jiacai_time = protocol.next_add_mucai_time or 0
end

function GuildBonfireData:GetSkillTimeInfo()
	return self.hejiu_time, self.jiacai_time
end

function GuildBonfireData:SetGuildBonfireMucaiTimes(obj_id, add_mucai_times)
	self.guild_bonfire_mucai_times[obj_id] = add_mucai_times
end

function GuildBonfireData:GetGuildBonfireMucaiTimes(obj_id)
	return self.guild_bonfire_mucai_times[obj_id] or 0
end