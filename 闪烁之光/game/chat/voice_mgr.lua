--聊天语音数据管理
--author:cloud
--date:2017.1.5

VoiceMgr = VoiceMgr or BaseClass()
VoiceMgr.NewMsg = "VoiceMgr.NewMsg"
VoiceMgr.Played = "VoiceMgr.Played" 

function VoiceMgr:__init()
	if VoiceMgr.Instance then
		error("[VoiceMgr] accempt to create singleton twice!")
		return
	end
    local path = string.format("%svoice", cc.FileUtils:getInstance():getWritablePath())
    if not cc.FileUtils:getInstance():isDirectoryExist(path) then
        cc.FileUtils:getInstance():createDirectory(path)
    end
	VoiceMgr.Instance = self
	self:initMsg()
end

function VoiceMgr:getInstance()
	if VoiceMgr.Instance == nil then
		VoiceMgr.New()
	end
	return VoiceMgr.Instance
end

-- 初始化
function VoiceMgr:initMsg()
	self.auto_list = {} --语音自动播放列表
	self.voice_msg = {} --语音翻译文字内容
	self.record = {}    --语音播放记录
	self.once_sec = 1   --语音播放等待时间
	self.once_gap = 5   --语音播放间隔时间
    self.cache_voice_file = FixArray.New(50, function(voice) 
        local url = voice.key .. "@".. voice.time
        self.record[url] = nil
        self.voice_msg[url] = nil
        cc.FileUtils:getInstance():removeFile(PathTool.getVoicePath(voice.file))
    end)
end

-- 记录语音缓存文件
function VoiceMgr:addCacheVoiceFile(key, file, time)
    local voice = {key = key, file = file, time = time}
    self.cache_voice_file:PushBack(voice)
    return voice
end

-- 获取翻译文字
function VoiceMgr:getMsg(voice_name)
	if self.voice_msg[voice_name] then
		return true, self.voice_msg[voice_name]
	else
		return false, ""
	end
end

-- 缓存翻译文字
function VoiceMgr:setMsg(voice_name, voice_msg)
	self.voice_msg[voice_name] = voice_msg
	GlobalEvent:getInstance():Fire(VoiceMgr.NewMsg, voice_name, voice_msg)
end

-- 解析语音字符串
function VoiceMgr:splitVoice(str)
	local name = ""
	local sec = 0
	if str then
		local list = Split(str, "@")
		name = list[1] or ""
		sec = list[2] or 0
	end
	return name, sec
end

-- 播放语音操作
function VoiceMgr:playVoice(url)
	if self.playing then
		message("语音播放中")
		return
	end
	local name, sec = self:splitVoice(url)
	if name=="" or sec==0 then
		return
	end
	self:loadFileNew(name, sec)
end

-- 下载语音播放语音
function VoiceMgr:loadFileNew(key, time)
    local voice = keyfind('key', key, self.cache_voice_file.items)
    if not voice then
        local name = ChatHelp.formatFileName(key)
        if PathTool.checkSound(name) then
            self:startPlay(self:addCacheVoiceFile(key, name, time))
        else
            local list = Split(key, '-')
            ChatController:getInstance():sender12726(list[1], tonumber(list[2]))
        end
    else
        if not PathTool.checkSound(voice.file) then
            message("查找不到语音文件啦")
        else
            self:startPlay(voice)
        end
    end
end

-- 开始播放语音
function VoiceMgr:startPlay(voice)
    if self.playing then return end
	local delaySec = 0
	if not PathTool.checkSound(voice.file) then
		delaySec = self.once_sec
	end
	self:removeDelayTimer()
	--记录播放过的语音
    local url = voice.key .. "@" .. voice.time
	self.record[url] = 0
	local count = voice.time + delaySec
	self.playUrl = url
	self:setPlaying(true)
	self:removeTimer()
    local vol = callAudioGetVolume()
	self.timer = GlobalTimeTicket:getInstance():add(function()
    	count = count - 1
    	if count <= 0 then
            callAudioSetVolume(vol)
    		self:stopVoice()
    		self:delayCheck()--自动播放检测
    	end
    end,1)
    delayOnce(function()
        callAudioSetVolume(math.max(vol, 85))
        AudioManager:getInstance():playSound(voice.file) 
    end, 0.2)
end

-- 下载语音播放语音
function VoiceMgr:loadFile(voice_url)
	local file_name = ChatHelp.formatFileName(voice_url)
    if not PathTool.checkSound(file_name) then
        -- ChatHelp.setDownloadAddress2(voice_url)
        -- cc.FmodexManager:downloadFile(file_name)
        local path = ChatHelp.getDownloadAddress2(voice_url)..file_name
	    cc.FmodexManager:downloadOtherFile(path, "../../voice/"..file_name)
        -- print("path", path, file_name)
        setWillPlaySound(file_name)
    else
        AudioManager:getInstance():playSound(file_name) 
    end
end

-- 结束播放语音
function VoiceMgr:stopVoice()
	self:removeTimer()
	self:setPlaying(false)
end

-- 移除定时器
function VoiceMgr:removeTimer()
	if self.timer then
		GlobalTimeTicket:getInstance():remove(self.timer)
		self.timer = nil
		self.playUrl = nil
	end
end

-- 判断语音是否播放过
function VoiceMgr:isPlayed(url)
	return self.record[url]~=nil
end

-- 播放状态
function VoiceMgr:isPlaying(url)
	if self.playing and url and self.playUrl==url then
		return true
	end
	return false
end

-- 语音播放状态
function VoiceMgr:setPlaying(bool)
	if self.playing ~= bool then
		self.playing = bool
		GlobalEvent:getInstance():Fire(VoiceMgr.Played, bool)
		if bool then
			AudioManager:getInstance():pauseMusic()
		else
            delayOnce(function()
                if self.playing then return end
                AudioManager:getInstance():resumeMusic()
            end, 1)
		end
	end
end

function VoiceMgr:getPlaying()
	return self.playing
end

-- 聊天播放语音效果
function VoiceMgr:showVoiceEffect(root, bool, x, y)
	if tolua.isnull(root) then return end
	if bool then
		x = x or 0
		y = y or 0
		local effect = SoundEffect.new()
	    effect:setPosition(cc.p(root:getPositionX()+x, root:getPositionY()+y))
	    effect:play()
	    root:setVisible(false)
	    root:getParent():addChild(effect)
	    root.__effect = effect
	else
		root:setVisible(true)
		if root.__effect and not tolua.isnull(root.__effect) then
			root.__effect:stop()
			root.__effect:removeFromParent()
		end
		root.__effect = nil
	end
end

-- 自动播放间隔时间
function VoiceMgr:delayCheck()
	if not self.delayTimer then
		self.delayTimer = GlobalTimeTicket:getInstance():add(function()
			self:checkAutoPlay()
        end, self.once_gap, 1)
	end
end

-- 移除检测定时器
function VoiceMgr:removeDelayTimer()
	if self.delayTimer then
		GlobalTimeTicket:getInstance():remove(self.delayTimer)
		self.delayTimer = nil
	end
end

-- 存储自动播放的语音列表
function VoiceMgr:insertVoice(url, channnel)
	if #self.auto_list > 12 then
		table.remove(self.auto_list, 1)
	end
	table.insert(self.auto_list, {url, channnel})
	self:checkAutoPlay()
end

-- 检测自动播放语音
function VoiceMgr:checkAutoPlay()
	-- if IS_IOS_PLATFORM then return end 	 	-- ios 不要自动播放了，语音那块有点问题
	-- if not self.playing then
	-- 	local is_set = SysEnv:getInstance():get(SysEnv.keys.voice_volume)
	-- 	local data
	-- 	for i=1, #self.auto_list do
	-- 		data = self.auto_list[i]
	-- 		if tonumber(is_set) == 100 then
	-- 			self:playVoice(data[1])
	-- 			table.remove(self.auto_list, i)
	-- 			return
	-- 		end 
	-- 	end
	-- end


	if not self.playing then
		local data
		for i=1, #self.auto_list do
			data = self.auto_list[i]
			if (data[2]==ChatConst.Channel.Gang and  SysEnv:getInstance():get(SysEnv.keys.auto_guild_voice)) or (data[2]==ChatConst.Channel.World and  SysEnv:getInstance():get(SysEnv.keys.auto_world_voice)) then
				self:playVoice(data[1])
				table.remove(self.auto_list, i)
				return
			end 
		end
	end
end

function VoiceMgr:__delete()
	VoiceMgr.Instance = nil
	self.voice_msg = nil
end
