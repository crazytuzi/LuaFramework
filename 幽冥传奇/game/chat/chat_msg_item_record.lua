ChatMsgItemRecord = ChatMsgItemRecord or BaseClass()

function ChatMsgItemRecord:__init(show_type)
	self.show_type = show_type								-- 0 聊天面板 1主UI
	self.lyaout_w, self.lyaout_h = 89, 24

	self.view = XUI.CreateLayout(0, 0, self.lyaout_w, self.lyaout_h)
	self.view:setAnchorPoint(0, 0)
	self.view:setTouchEnabled(true)

	self.bg = XUI.CreateImageViewScale9(0, 0, self.lyaout_w, self.lyaout_h, ResPath.GetMainui("chat_record_bg3"), true)
	self.bg:setAnchorPoint(0, 0)
	self.view:addChild(self.bg)

	self.icon_unread = XUI.CreateImageView(self.lyaout_w - 19, self.lyaout_h - 10, ResPath.GetMainui("chat_record_icon1"), true) 
	self.icon_unread:setAnchorPoint(0, 0)
	self.view:addChild(self.icon_unread)

	self.icon_eff_bg = XUI.CreateImageView(12, self.lyaout_h / 2, ResPath.GetMainui("chat_record_icon2"), true)
	self.view:addChild(self.icon_eff_bg)

	self.time_text = XUI.CreateText(self.lyaout_w / 2 + 5, self.lyaout_h / 2, 0, 0, nil, "")
	self.view:addChild(self.time_text)

	self.data = nil
	self.is_play = false
	self.is_start_load = false
	self.direction = 0									-- 方向 0 左 1右
	self.stop_timer = nil
	self.audio = nil									-- 声音对象

	self.upload_callback = BindTool.Bind1(self.UploadCallback, self)
	self.stop_callback = BindTool.Bind2(self.SetIsPlay, self, false)
	XUI.AddClickEventListener(self.view, BindTool.Bind1(self.OnClickViewHandler, self))
end

function ChatMsgItemRecord:__delete()
	ChatRecordMgr.Instance:RemoveRecordItem(self:GetSoundKey())
end

-- 移除的时候还原所有设置，清缓存
function ChatMsgItemRecord:Restore()
	if self:GetCachePath() then
		PlatformAdapter.RemoveFile(self:GetCachePath())
	end

	self.data = nil
	self:SetIsload(false)
	self:SetIsPlay(false)

	self.direction = 0
	self.audio = nil

	self.icon_unread:setVisible(true)
end

function ChatMsgItemRecord:StopRecord()
	if self.is_start_load then
		self:SetIsload(false)
	end
	if self.is_play then
		self:SetIsPlay(false)
	end
end

function ChatMsgItemRecord:GetView()
	return self.view
end

function ChatMsgItemRecord:GetIsMain()
	local is_main = false
	if self.data then
		is_main = self.data.from_uid == GameVoManager.Instance:GetMainRoleVo().role_id
	end
	return is_main
end

-- 获取时长
function ChatMsgItemRecord:GetDuration()
	local duration = 0
	if self.data then
		local str_arr = Split(self.data.content, "_")
		if str_arr then
			local str_arr2 = Split(str_arr[#str_arr], ".amr")
			if str_arr2 and tonumber(str_arr2[1]) then
				duration = tonumber(str_arr2[1])
			end
		end
	end
	return duration
end

-- 音效名字
function ChatMsgItemRecord:GetSoundName()
	local sound_name = nil
	if self.data then
		sound_name = self.data.content
	end
	return sound_name
end

-- 控制器中的唯一KEY  name + showtype
function ChatMsgItemRecord:GetSoundKey()
	local key = nil
	if self:GetSoundName() then
		key = self:GetSoundName() .. self.show_type
	end
	return key
end

-- 缓存目录
function ChatMsgItemRecord:GetCachePath()
	local cache_path = nil
	if self.data then
		cache_path = ChatRecordMgr.GetCacheSoundPath(self.data.content)
	end
	return cache_path
end

-- URL地址
function ChatMsgItemRecord:GetUrlPath()
	local url_path = nil
	if self.data then
		url_path = ChatRecordMgr.GetUrlSoundPath(self.data.content)
	end
	return url_path
end

function ChatMsgItemRecord:SetData(data)
	self.data = data
	ChatRecordMgr.Instance:AddRecordItem(self:GetSoundKey(), self)
	self.time_text:setString(math.floor(self:GetDuration() / 10)  .. "〃")
	if SettingProtectData.SettingPlayNow(data.channel_type) then
		self:OnClickViewHandler()
	end
end

function ChatMsgItemRecord:OnClickViewHandler()
	ChatRecordMgr.Instance:SetCurPlayRecord(self:GetSoundKey())
	local is_download = ChatRecordMgr.Instance:GetIsDownLoad(self:GetSoundName())
	
	if is_download or self:GetIsMain() then
		self:SetIsPlay(not self.is_play)
	else
		self:SetIsload(not self.is_start_load)
	end
end

-- 下载状态
function ChatMsgItemRecord:SetIsload(is_start_load)
	if self.is_start_load == is_start_load then
		return
	end

	if is_start_load then
		self:LoadRecordHandler()
	else
		self:CancelDownload()
	end
end

-- 开始下载
function ChatMsgItemRecord:LoadRecordHandler()
	if self:GetCachePath() and self:GetUrlPath() then
		self.is_start_load = true
		HttpClient:Download(self:GetUrlPath(), self:GetCachePath(), self.upload_callback)
	end
end

-- 取消下载
function ChatMsgItemRecord:CancelDownload()
	self.is_start_load = false
	if self:GetUrlPath() then
		HttpClient:CancelDownload(self:GetUrlPath(), self.upload_callback)
	end
end

-- 下载完成
function ChatMsgItemRecord:UploadCallback(url, path, size)
	self.is_start_load = false
	if size > 0 then
		PlatformBinder:JsonCall("call_amr_to_wave", path)
		ChatRecordMgr.Instance:AddRecordDownLoad(self:GetSoundName())
		self:SetIsPlay(true)
	end
end

-- 播放状态
function ChatMsgItemRecord:SetIsPlay(is_play)
	if self.is_play == is_play then
		return
	end
	self.is_play = is_play
	if self.is_play then
		if self:GetCachePath() then
			AudioManager.Instance:PlayChatRecord(self:GetCachePath(), self:GetDuration() / 10, self.stop_callback)
		end
	else
		AudioManager.Instance:StopChatRecord()
	end
	self:SetShowPlayEff(self.is_play)
	self.icon_unread:setVisible(false)
end

-- 播放特效
function ChatMsgItemRecord:SetShowPlayEff(is_play)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.view:addChild(self.play_eff, 9999)
		self.play_eff:setPosition(self.icon_eff_bg:getPosition())
	end
	self.play_eff:setScaleX(self.direction == 0 and 1 or -1)
	self.icon_eff_bg:setVisible(not is_play)
	if is_play then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(3080)
		self.play_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.4, false)
	else
		self.play_eff:setVisible(setStop)
	end
end

-- direction 方向 0 左 1右
function ChatMsgItemRecord:SetDirection(direction)
	self.direction = direction
	self.icon_eff_bg:setScale(self.direction == 0 and -1 or 1)
end

function ChatMsgItemRecord:SetPosition(x, y)
	self.view:setPosition(x, y)
end