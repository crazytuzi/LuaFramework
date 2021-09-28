local SoundManager = 
{
    backgroundMusic = nil,
    lastBackGroundMusic = nil,
    soundList = {},
    sceneSoundList = {},

    battleSounds = {},
    isBattling = false
}

function SoundManager:initSoundManager( ... )
    local battlerLayer = require("app.scenes.battle.BattleLayer")
    uf_eventManager:addEventListener(battlerLayer.BATTLE_START, function ( ... )
        self.isBattling = true
    end, G_SoundManager)
    uf_eventManager:addEventListener(battlerLayer.BATTLE_FINISH, function ( ... )
        self.isBattling = false
        for key, value in pairs(self.battleSounds) do 
            audio.unloadSound(value)
        end
        self.battleSounds = {}
    end, G_SoundManager)
end

-- @desc 设置音效音量
function SoundManager:setSoundsVolume(value)
    audio.setSoundsVolume(value)
end

-- @desc 获取音效音量
function SoundManager:getSoundsVolume()
    return audio.getSoundsVolume()
end

-- @desc 设置背景音乐音量
function SoundManager:setMusicVolume(value)
    audio.setMusicVolume(value)
end

-- @desc 获取背景音乐音量
function SoundManager:getMusicVolume()
    audio.getMusicVolume()
end

-- @desc 预加载 背景音乐
function SoundManager:preloadBackgroundMusic(musicName)
    audio.preloadBackgroundMusic(musicName)
end

-- @desc播放背景音乐
function SoundManager:playBackgroundMusic(musicName)

    -- 如果播放的背景音乐已经在播放在不需要重新播放
    if self.backgroundMusic ~= musicName then
        if self.backgroundMusic then
            self:stopBackgroundMusic()
        end
        audio.playBackgroundMusic(musicName)
        self.lastBackGroundMusic = self.backgroundMusic
        self.backgroundMusic = musicName
    end

end

-- @desc 是否在播放背景音乐
function SoundManager:isMusicPlaying()
    return audio.isMusicPlaying()
end

-- @desc 停止播放背景音乐
function SoundManager:stopBackgroundMusic()
    audio.stopMusic(true)
end

-- @desc 暂停播放背景音乐
function SoundManager:pauseBackgroundMusic()
     audio.pauseMusic()
end

-- @desc 恢复播放背景音乐
function SoundManager:resumeBackgroundMusic()
     audio.resumeMusic()
end

-- @desc 恢复播放背景音乐
function SoundManager:resumeBackgroundMusic()
     audio.resumeMusic()
end

-- @desc 从头开始播放背景音乐
function SoundManager:rewindMusic()
    audio.rewindMusic()
end

-- @desc 播放音效
function SoundManager:playSound(soundName,isLoop)
    if isLoop == nil or not soundName then
        isLoop = false
    end
    local handler = audio.playSound(soundName,isLoop)
    self.soundList[soundName] = handler

    if self.isBattling then 
        table.insert(self.battleSounds, #self.battleSounds + 1, soundName)
    end
end

-- @desc 暂停播放音效
function SoundManager:pauseSound(soundName)
    audio.pauseSound(self.soundList[soundName])
end

-- @desc 恢复播放音效
function SoundManager:resumeSound(soundName)
    audio.resumeSound(self.soundList[soundName])
end

-- @desc 停止播放音效
function SoundManager:stopSound(soundName)
    audio.stopSound(self.soundList[soundName])
end

-- @desc 停止播放所有音效
function SoundManager:stopAllSounds()
    audio.stopAllSounds()
end

-- @desc 暂停播放所有音效
function SoundManager:pauseAllSounds()
    audio.pauseAllSounds()
end

-- @desc 恢复播放所有音效
function SoundManager:resumeAllSounds()
    audio.resumeAllSounds()
end

-- @desc 预载入一个音效文件。
function SoundManager:preloadSound(soundName)
    audio.preloadSound(soundName)
end

-- @desc 卸载某个音效
function SoundManager:unloadSound(soundName)
    audio.unloadSound(soundName)
end

-- @desc 预加载整个场景需要的音效列表
function SoundManager:preloadSceneSoundList(_list)
    for k,v in pairs(_list) do
        table.insert(self.sceneSoundList,v)
        self:preloadSound(v)
    end
end

-- @desc 预加载整个场景需要的音效列表
function SoundManager:unloadSceneSoundList()
    for k,v in pairs(self.sceneSoundList) do
        self:unloadSound(v)
    end
    self.sceneSoundList = {}
end

return SoundManager
