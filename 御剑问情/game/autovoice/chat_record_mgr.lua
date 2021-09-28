ChatRecordMgr = ChatRecordMgr or BaseClass()

local AVATAR_URL
if nil ~= AVATAR_URL then
	AVATAR_URL = AVATAR_URL .. "/avatar/"
else
	AVATAR_URL = "http://upload.mg23.youyannet.com/dev/"  --"http://127.0.0.1/avatar/"
end

function ChatRecordMgr:__init()
	if ChatRecordMgr.Instance then
		ErrorLog("[ChatRecordMgr]:Attempt to create singleton twice!")
	end
	ChatRecordMgr.Instance = self

	self.record_item_list = {}					-- 存放ChatMsgItemRecord的引用
	self.record_download_list = {}				-- 已下载语音列表

	self.wait_download_list = {}				--等待下载列表

	self.play_voice_count = 0
end

function ChatRecordMgr:__delete()
	ChatRecordMgr.Instance = nil
end

--删除所有语音信息
function ChatRecordMgr:RemoveAllRecord()
	for k, v in pairs(self.record_download_list) do
		local path = ChatRecordMgr.GetCacheSoundPath(k)
		-- print_error(os.remove(path))
	end
end

-- 语音缓存地址
function ChatRecordMgr.GetCacheSoundPath(name)
	return string.format("%s/cache/sound/%s",
		UnityEngine.Application.persistentDataPath,
		name)
end

-- 语音下载地址
function ChatRecordMgr.GetUrlSoundPath(name)
	return string.format("%ssound/%s", AVATAR_URL, name)
end

-- 下载语音
function ChatRecordMgr:DownloadVoice(sound_name, callback)
	local function load_callback(url, path, is_succ)
		print(" load_callback ", url, path, is_succ)
		self.wait_download_list[url] = nil
		if is_succ then
			self:AddRecordDownLoad(sound_name)
			if callback then
				callback()
			end
		end
	end

	-- 通过http下载
	local url = ChatRecordMgr.GetUrlSoundPath(sound_name)
	if self.wait_download_list[url] then
		return
	end
	self.wait_download_list[url] = url
	local path = ChatRecordMgr.GetCacheSoundPath(sound_name)
	if not HttpClient:Download(url, path, load_callback) then
		print_error("下载语音失败", url, path)
	end
end

-- 语音Item列表
function ChatRecordMgr:AddRecordItem(key, item)
	if key and item then
		self.record_item_list[key] = item
	end
end

-- 移除语音Item
function ChatRecordMgr:RemoveRecordItem(key)
	for k,v in pairs(self.record_item_list) do
		if k == key then
			self:RemoveRecordDownLoad(v:GetSoundName())
			v:Restore()
			self.record_item_list[k] = nil
			break
		end
	end
end

-- 已下载语音列表
function ChatRecordMgr:AddRecordDownLoad(sound_name)
	if sound_name then
		self.record_download_list[sound_name] = true
	end
end

-- 删除已下载语音
function ChatRecordMgr:RemoveRecordDownLoad(sound_name)
	self.record_download_list[sound_name] = nil
end

-- 是否已下载
function ChatRecordMgr:GetIsDownLoad(sound_name)
	local path = ChatRecordMgr.GetCacheSoundPath(sound_name)
	local file = io.open(path, "r")
	if file then
		io.close(file)
		return true
	end
	return self.record_download_list[sound_name]
end

-- 设置当前语音，关闭掉其它的
-- @audio_name == nil，关闭所有语音
function ChatRecordMgr:SetCurPlayRecord(key)
	AudioService:StopChatRecord()
	for k,v in pairs(self.record_item_list) do
		if key == nil or v:GetSoundKey() ~= key then
			v:StopRecord()
		end
	end
end

function ChatRecordMgr:StopCallBack(end_call_back)
	if self.play_voice_count <= 0 then
		return
	end
	self.play_voice_count = self.play_voice_count - 1
	if self.play_voice_count == 0 then
		AudioService.Instance:SetMasterVolume(1.0)
	end
	if end_call_back then
		end_call_back(false)
	end
end

function ChatRecordMgr:DownloadCallBack(path, play_voice_call_back, end_call_back)
	self.play_voice_count = self.play_voice_count + 1
	if play_voice_call_back then
		play_voice_call_back(true)
	end
	AudioService.Instance:SetMasterVolume(0.0)

	AudioPlayer.Stop()		--停止播放语音
	AudioPlayer.Play(path, BindTool.Bind(self.StopCallBack, self, end_call_back))
end

--播放语音
function ChatRecordMgr:PlayVoice(file_path, play_voice_call_back, end_call_back)
	if not file_path then
		return
	end
	local path = ChatRecordMgr.GetCacheSoundPath(file_path)
	if self:GetIsDownLoad(file_path) then
		self:DownloadCallBack(path, play_voice_call_back, end_call_back)
	else
		self:DownloadVoice(file_path, BindTool.Bind(self.DownloadCallBack, self, path, play_voice_call_back, end_call_back))
	end
end