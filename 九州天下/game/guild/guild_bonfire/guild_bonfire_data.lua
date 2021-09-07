GuildBonfireData = GuildBonfireData or BaseClass()

function GuildBonfireData:__init()
	if GuildBonfireData.Instance then
		ErrorLog("[GuildBonfireData] attempt to create singleton twice!")
		return
	end
	GuildBonfireData.Instance =self
end

function GuildBonfireData:__delete()
	GuildBonfireData.Instance = nil
end

function GuildBonfireData:GetBonfireOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("guildbonfire_auto").other_cfg[1]
end
