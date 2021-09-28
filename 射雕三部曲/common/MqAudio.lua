--[[
    文件名：MqAudio.lua
    描述：对 framework.audio.lua 中对函数进行再封装，实现游戏中对特殊需求，
    创建人：heguanghui
    创建时间：2017.3.30
-- ]]

MqAudio = {}

-- 当前播放的背景音乐ID
MqAudio.musicId = -1
-- 当前播放的音效ID列表
MqAudio.effectIds = {}
-- 背景音乐音量
MqAudio.musicVolume = 1
-- 音效音量
MqAudio.effectVolume = 1

-- 判断是否正在播放背景音乐
function MqAudio.isMusicPlaying()
    return MqAudio.musicId > -1
end

-- 播放游戏背景音乐
function MqAudio.playMusic(file, loop)
    -- 音乐异步加载，无法暂停播放，所以关闭音乐时不再调用播放方法
    if MqAudio.isFileValid(file) and LocalData:getMusicEnabled() then
        -- 如正在播放音乐，则停止
        if MqAudio.isMusicPlaying() then
            MqAudio.stopMusic(MqAudio.musicId)
        end
        MqAudio.musicId = ccexp.AudioEngine:play2d(file, loop ~= false, MqAudio.musicVolume)
        -- 设置回调
        ccexp.AudioEngine:setFinishCallback(MqAudio.musicId, function (id, file)
            -- 背景音乐播放完成
            MqAudio.musicId = -1
        end)
    end
end

-- 停止播放游戏背景音乐
function MqAudio.stopMusic()
    if MqAudio.musicId > -1 then
        ccexp.AudioEngine:stop(MqAudio.musicId)
        MqAudio.musicId = -1
    end
end

-- 停止播放的所有音效
function MqAudio.stopAllEffect()
    for k,v in pairs(MqAudio.effectIds) do
        MqAudio.stopEffect(k)
    end
    MqAudio.effectIds = {}
end

-- 停止播放所有音乐和音效(更新重启时需要)
function MqAudio.stopMusicEffects()
    ccexp.AudioEngine:stopAll()
    MqAudio.effectIds = {}
end

-- 暂停背景音乐
function MqAudio.pauseMusic()
    if MqAudio.musicId > -1 then
        ccexp.AudioEngine:pause(MqAudio.musicId)
    end
end

-- 恢复背景音乐
function MqAudio.resumeMusic()
    -- 如未播放音乐，在LayerManager循环里会自动播放
    if MqAudio.musicId > -1 then
        ccexp.AudioEngine:resume(MqAudio.musicId)
    end
end

-- 设置音乐音量
-- volume: 0-1
function MqAudio.setMusicVolume(volume)
    MqAudio.musicVolume = volume
    if MqAudio.musicId > -1 then
        -- 同时设置背景音乐音量
        ccexp.AudioEngine:setVolume(MqAudio.musicId, volume)
    end
end

-- 返回音乐的音量
function MqAudio.getMusicVolume()
    return MqAudio.musicVolume
end

-- 设置音效音量
-- volume: 0-1
function MqAudio.setEffectVolume(volume)
    MqAudio.effectVolume = volume
end

-- 返回音效的音量
function MqAudio.getEffectVolume()
    return MqAudio.effectVolume
end

-- 播放游戏音效
function MqAudio.playEffect(file, loop)
    if MqAudio.isFileValid(file) and LocalData:getEffectEnabled() then
        local effectId = ccexp.AudioEngine:play2d(file, loop or false, MqAudio.effectVolume)
        -- 添加到当前播放的音效列表
        MqAudio.effectIds[effectId] = true
        -- 设置音效播放完成回调
        ccexp.AudioEngine:setFinishCallback(effectId, function (id, file)
            if id == effectId then
                MqAudio.effectIds[effectId] = nil
            end
        end)
        return effectId
    end
end

-- 停止指定的音效播放
function MqAudio.stopEffect(id)
    if id and id > -1 then
        ccexp.AudioEngine:stop(id)
        MqAudio.effectIds[id] = nil
    end
end

-- 判断播放的文件名是否合法
function MqAudio.isFileValid(file)
    local isExist = cc.FileUtils:getInstance():isFileExist(file)
    return isExist and file:match "[%w+.-]%.[%w+]"
end
