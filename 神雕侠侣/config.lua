-----===========================================------
-- lua配置文件
-----===========================================------
Config = {}



-----===========================================------
--是否接入第三方
Config.TRD_PLATFORM = SDXL.ChannelManager:IsTrdPlatform()
--第三方平台名称
Config.CUR_3RD_PLATFORM = SDXL.ChannelManager:GetCur3rdPlatform()
--第三方帐号后缀
Config.CUR_3RD_LOGIN_SUFFIX = SDXL.ChannelManager:GetPlatformLoginSuffix()
-----===========================================------
--是否为Android
Config.MOBILE_ANDROID = SDXL.ChannelManager:IsAndroid()

Config.androidNotifyAll = false
function Config.isKoreanAndroid()
    if Config.CUR_3RD_LOGIN_SUFFIX == "krgp" or Config.CUR_3RD_LOGIN_SUFFIX == "krts" or Config.CUR_3RD_LOGIN_SUFFIX == "krnv" or Config.CUR_3RD_LOGIN_SUFFIX == "krlg" then
        return true
    else
        return false
    end
end

function Config.isTaiWan()
    if Config.CUR_3RD_LOGIN_SUFFIX == "efis" 
    	or Config.CUR_3RD_LOGIN_SUFFIX == "efad" 
    	or Config.CUR_3RD_LOGIN_SUFFIX == "lngz" 
    	or Config.CUR_3RD_LOGIN_SUFFIX == "tw36"
    	or Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
        return true
    else
        return false
    end
end

return Config
