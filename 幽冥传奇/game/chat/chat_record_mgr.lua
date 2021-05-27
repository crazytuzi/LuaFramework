ChatRecordMgr = ChatRecordMgr or BaseClass()

function ChatRecordMgr:__init()
	if ChatRecordMgr.Instance then
		ErrorLog("[ChatRecordMgr]:Attempt to create singleton twice!")
	end
	ChatRecordMgr.Instance = self

	self.record_item_list = {}					-- 存放ChatMsgItemRecord的引用 
	self.record_download_list = {}				-- 已下载语音列表
end

function ChatRecordMgr:__delete()
	ChatRecordMgr.Instance = nil
end


-- 语音缓存地址
function ChatRecordMgr.GetCacheSoundPath(name)
	return string.format("%ssound/%s", PlatformAdapter.GetCachePath(), name)
end

-- 语音下载地址
function ChatRecordMgr.GetUrlSoundPath(name)
	return string.format("%ssound/%s", GLOBAL_CONFIG.param_list.upload_url, name)
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
	return self.record_download_list[sound_name]
end

-- 设置当前语音，关闭掉其它的
-- @audio_name == nil，关闭所有语音
function ChatRecordMgr:SetCurPlayRecord(key)
	AudioManager:StopChatRecord()
	for k,v in pairs(self.record_item_list) do
		if key == nil or v:GetSoundKey() ~= key then
			v:StopRecord()
		end
	end
end