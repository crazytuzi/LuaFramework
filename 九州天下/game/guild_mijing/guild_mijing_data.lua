GuildMijingData = GuildMijingData or BaseClass()
GuildFbNotifyReason = {
	ENTER = 0,
	WAIT = 1,
	UPDATE = 2,
	FINISH = 3,
	MAX = 4,
}
function GuildMijingData:__init()
	if GuildMijingData.Instance then
		ErrorLog("[GuildMijingData] attempt to create singleton twice!")
		return
	end
	GuildMijingData.Instance =self
	self.guild_fb_data ={}
	self.guild_fb_data.notify_reason =0
	self.guild_fb_data.curr_wave =  0
	self.guild_fb_data.next_wave_time =  0
	self.guild_fb_data.wave_enemy_count =  0
	self.guild_fb_data.wave_enemy_max =  0
	self.guild_fb_data.is_pass =  0
	self.guild_fb_data.is_finish =  0
	self.guild_fb_data.hp = 0
	self.guild_fb_data.max_hp = 0
	self.guild_fb_data.kick_role_time = 0
end

function GuildMijingData:__delete()
	GuildMijingData.Instance = nil
end

function GuildMijingData:SetGuildMiJingSceneInfo(data)
	self.guild_fb_data = data
end

function GuildMijingData:GetGuildMiJingSceneInfo()
	return self.guild_fb_data
end