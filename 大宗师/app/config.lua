
local rootpath = CCFileUtils:sharedFileUtils():getWritablePath() .. "updateres/"

local path = {
--    rootpath,
    "res/",
    "res/ui/",
    "res/ccbi/",
    "res/fonts/",
}
SearchPath = {}
for k, v in ipairs(path) do
    table.insert(SearchPath, k, rootpath .. v)
    table.insert(SearchPath, #SearchPath + 1, v)

--    table.insert(SearchPath, k, v)
--    table.insert(SearchPath, #SearchPath + 1, rootpath .. v)

end

dump(SearchPath)

-- SETTING
GAME_SETTING = {
    HAS_SAVE = "saved",
    ENABLE_MUSIC = "enable_music",
    ENABLE_SFX = "enable_sfx",
}

GAME_SOUND = {
    title_day = "sound/title_day.mp3",
    title_night = "sound/title_night.mp3",
}

if device.platform == "android" or ANDROID_DEBUG then
    if(GAME_DEBUG == true) then
        CSDKShell = require("sdk.CSDKShell")
    else
        CSDKShell = require("sdk.SDKHelper")
    end
else
    CSDKShell = require("sdk.CSDKShell")
end

GameAudio = require("utility.GameAudio")

SDKGameWorks = require("sdk.SDKGameWorks")
SDKTKData = require("sdk.SDKTkData")
