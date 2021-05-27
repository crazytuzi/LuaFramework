
-- 声音相关接口

AudioAdapter = AudioAdapter or {}
AudioAdapter.engine_instance = cc.SimpleAudioEngine:getInstance()

-- 播放背景音乐 
function AudioAdapter.PlayMusic(path, is_loop)
	is_loop = is_loop or false
	AudioAdapter.engine_instance:playMusic(path, is_loop)
end

-- 获取背景音乐音量 0.0~1.0
function AudioAdapter.GetMusicVolume()
	return AudioAdapter.engine_instance:getMusicVolume()
end

-- 设置背景音乐音量
function AudioAdapter.SetMusicVolume(volume)
	AudioAdapter.engine_instance:setMusicVolume(volume)
end

-- 背景音乐是否播放中
function AudioAdapter.IsMusicPlaying()
	return AudioAdapter.engine_instance:isMusicPlaying()
end

-- 停止背景音乐 @is_release_data 是否释放资源
function AudioAdapter.StopMusic(is_release_data)
	is_release_data = is_release_data or false
	AudioAdapter.engine_instance:stopMusic(is_release_data)
end

-- 继续播放背景音乐
function AudioAdapter.ResumeMusic()
	AudioAdapter.engine_instance:resumeMusic()
end

-- 暂停播放背景音乐
function AudioAdapter.PauseMusic()
	AudioAdapter.engine_instance:pauseMusic()
end

-- 重新播放背景音乐
function AudioAdapter.RewindMusic()
	AudioAdapter.engine_instance:rewindMusic()
end

function AudioAdapter.WillPlayMusic()
	return AudioAdapter.engine_instance:willPlayMusic()
end

-- 预加载背景音乐
function AudioAdapter.PreloadMusic(path)
	AudioAdapter.engine_instance:preloadMusic(path)
end

-- 播放音效
function AudioAdapter.PlayEffect(path, is_loop, pitch, pan, gain)
	is_loop = is_loop or false
	pitch = pitch or 1.0
	pan = pan or 0.0
	gain = gain or 1.0
	return AudioAdapter.engine_instance:playEffect(path, is_loop, pitch, pan, gain)
end

-- 获取音效音量
function AudioAdapter.GetEffectsVolume()
	return AudioAdapter.engine_instance:getEffectsVolume()
end

-- 设置音效音量
function AudioAdapter.SetEffectsVolume(volume)
	AudioAdapter.engine_instance:setEffectsVolume(volume)
end

-- 暂停播放音效
function AudioAdapter.PauseEffect(handle)
	AudioAdapter.engine_instance:pauseEffect(handle)
end

-- 暂停播放所有音效
function AudioAdapter.PauseAllEffects()
	AudioAdapter.engine_instance:pauseAllEffects()
end

-- 继续播放音效
function AudioAdapter.ResumeEffect(handle)
	AudioAdapter.engine_instance:resumeEffect(handle)
end

-- 继续播放所有音效
function AudioAdapter.ResumeAllEffects()
	AudioAdapter.engine_instance:resumeAllEffects()
end

-- 停止音效 @handle 音效id
function AudioAdapter.StopEffect(handle)
	AudioAdapter.engine_instance:stopEffect(handle)
end

-- 停止所有音效
function AudioAdapter.StopAllEffects()
	AudioAdapter.engine_instance:stopAllEffects()
end

-- 预加载音效
function AudioAdapter.PreloadEffect(path)
	AudioAdapter.engine_instance:preloadEffect(path)
end

-- 卸载音效
function AudioAdapter.UnloadEffect(path)
	AudioAdapter.engine_instance:unloadEffect(path)
end
