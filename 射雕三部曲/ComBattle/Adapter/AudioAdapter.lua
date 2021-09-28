--[[
    文件名：ComBattle.Adapter.AudioAdapter
	描述：audio-api 适配器
	创建人：luoyibo
	创建时间：2016.08.12
-- ]]

local audioAdapter = {
    playMusic     = MqAudio.playMusic,
    stopMusic     = MqAudio.stopMusic,

    playSound     = MqAudio.playEffect,
    stopSound     = MqAudio.stopEffect,
    stopAllSounds = MqAudio.stopAllEffect,

    preloadMusic  = function (filename)
    end,
    preloadSound  = function (filename)
    end,
    unloadSound   = function (filename)
    end,
}


return audioAdapter
