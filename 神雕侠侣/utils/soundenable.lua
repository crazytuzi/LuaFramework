SoundEnable = {}

function SoundEnable.Handle()
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ydjd" then
		require "luaj"
		local a, enable = luaj.callStaticMethod("com.wanmei.mini.condor.mobile.Platformmobile", "IsSoundEnable", nil, "()I")
		if enable == 0 then
			GetGameConfigManager():SetConfigValue("sound", 0)
			GetGameConfigManager():SetConfigValue("soundvalue", 0)
			GetGameConfigManager():SetConfigValue("soundeffect", 0)
			GetGameConfigManager():SetConfigValue("soundeffectvalue", 0)
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
		end
	
	end
end

return SoundEnable
