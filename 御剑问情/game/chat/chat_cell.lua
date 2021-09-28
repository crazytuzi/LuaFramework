ChatCell = ChatCell or BaseClass(BaseCell)

--可以展示频道标签
local CanShowChannel =
{
	[CHANNEL_TYPE.ALL] = true,
	[CHANNEL_TYPE.GUILD] = true,
	[CHANNEL_TYPE.WORLD] = true,
	[CHANNEL_TYPE.SYSTEM] = true,
	[CHANNEL_TYPE.WORLD_QUESTION] = true,
}

function ChatCell:__init()
	self.touch_down_time = 0
	self.old_msg_id = -1
	self.is_special_bubble = false
	self.is_easy = false 											--简单设置数据模式(计算高度用)
	self.special_bundle_prefab_name = ""							--特殊聊天框资源名

	--获取变量
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.show_left = self:FindVariable("ShowLeft")
	self.show_right = self:FindVariable("ShowRight")
	self.channel = self:FindVariable("Channel")
	self.channel_bg = self:FindVariable("ChannelBg")
	self.show_channel = self:FindVariable("ShowChannel")
	self.is_system = self:FindVariable("is_system")
	self.head_frame_res = self:FindVariable("head_frame_res")

	--头像相关
	self.left_image_res = self:FindVariable("LeftImageRes")
	self.right_image_res = self:FindVariable("RightImageRes")
	self.left_custom_obj = self:FindObj("RawLeftImg")
	self.right_custom_obj = self:FindObj("RawRightImg")
	self.is_show_image = self:FindVariable("IsShowImage")
	-- self.show_default_frame = self:FindVariable("show_default_frame")


	--获取ui
	self.left_view = self:FindObj("LeftView")
	self.right_view = self:FindObj("RightView")
	self.left_chanel_text = self:FindObj("LeftChanelText")
	self.right_chanel_text = self:FindObj("RightChanelText")

	--vip
	self.vip_res = self:FindVariable("VipRes")
	self.show_vip = self:FindVariable("ShowVip")

	self:ListenEvent("ClickRoleDown", BindTool.Bind(self.ClickRoleDown, self))
	self:ListenEvent("ClickRoleUp", BindTool.Bind(self.ClickRoleUp, self))
end

function ChatCell:__delete()
	if self.content_obj then
		GameObject.Destroy(self.content_obj.gameObject)
		self.content_obj = nil
	end

	if self.voice_obj then
		GameObject.Destroy(self.voice_obj.gameObject)
		self.voice_obj = nil
	end

	self.voice_animator = nil
	self.old_msg_id = -1
	self.special_bundle_prefab_name = ""
	self:RemoveDelayTime()
end

--添加文本到聊天框
function ChatCell:AddChatToInput()
	GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	self.icon_time_quest = nil
	if not self.data or not next(self.data) then
		return
	end
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local text = "@" .. self.data.username
	if self.data.from_uid == 0 or main_role_id == self.data.from_uid then
		return
	elseif self.data.channel_type == CHANNEL_TYPE.SCENE then
		HotStringChatCtrl.Instance:AddTextToInput(text)
	else
		ChatCtrl.Instance:AddTextToInput(text)
	end
end

function ChatCell:SetData(data)
	BaseCell.SetData(self, data)
end

function ChatCell:RemoveDelayTime()
	if self.icon_time_quest then
		GlobalTimerQuest:CancelQuest(self.icon_time_quest)
		self.icon_time_quest = nil
	end
end

function ChatCell:ClickRoleDown()
	--记录点下的时间
	self.touch_down_time = Status.NowTime
	self.icon_time_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.AddChatToInput, self), 1)
end

function ChatCell:ClickRoleUp()
	GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	self.icon_time_quest = nil
	if Status.NowTime - self.touch_down_time < 1 then
		self:ClickRoleIcon()
	end
end

function ChatCell:ClickRoleIcon()
	if not self.data or not next(self.data) then
		return
	end
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if self.data.from_uid == 0 or main_role_id == self.data.from_uid then
		return
	elseif self.data.channel_type ~= CHANNEL_TYPE.SCENE then
		local open_type = ScoietyData.DetailType.Default
		ScoietyCtrl.Instance:ShowOperateList(open_type, self.data.username)
	end
end

function ChatCell:PlayOrStopVoice(file_name)
	ChatCtrl.Instance:ClearPlayVoiceList()
	ChatCtrl.Instance:SetStartPlayVoiceState(false)
	local call_back = BindTool.Bind(self.ChangeVoiceAni, self)
	local end_back = BindTool.Bind(self.ChangeVoiceAni, self)

	-- GVoice
	local is_gvoice, file_id, str = GVoiceManager.ParseGVoice(file_name)
	if is_gvoice then
		if AudioGVoice then
			call_back(true)
			GVoiceManager.Instance:PlayVoice(file_id, function ()
				end_back(false)
			end)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CantParseVoice)
			end_back(false)
		end

		return
	end

	ChatRecordMgr.Instance:PlayVoice(file_name, call_back, end_back)
end

function ChatCell:SetEasy(state)
	self.is_easy = state
end

function ChatCell:SetPortrait(raw_img_obj, image_res)
	--先显示默认图片
	if self.role_id == 0 then
		local bundle, asset = ResPath.GetRoleIconBig(100) -- 系统头像
		image_res:SetAsset(bundle, asset)
		self.is_show_image:SetValue(true)
		self.head_frame_res:SetAsset(nil,nil)
		return
	end

	if self.data.channel_type == CHANNEL_TYPE.SCENE then
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		image_res:SetAsset(bundle, asset)
		self.head_frame_res:SetAsset(nil,nil)
		self.is_show_image:SetValue(true)
		return
	end

	--role_id不同或key值不同, 先设置默认头像
	local old_avatar_key = AvatarManager.Instance:GetAvatarKey(self.old_role_id, false)
	local now_avatar_key = AvatarManager.Instance:GetAvatarKey(self.role_id, false)
	if self.old_role_id ~= self.role_id or old_avatar_key ~= now_avatar_key then
		self.is_show_image:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		image_res:SetAsset(bundle, asset)
		self.head_frame_res:SetAsset(nil,nil)
	end

	local role_id = self.role_id

	local function download_callback(path)
		if nil == raw_img_obj or IsNil(raw_img_obj.gameObject) then
			return
		end
		if self.role_id ~= role_id then
			return
		end
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		raw_img_obj.raw_image:LoadSprite(avatar_path,
		function()
			if self.role_id ~= role_id then
				return
			end
			self.is_show_image:SetValue(false)
		end)
	end

	CommonDataManager.NewSetAvatar(self.role_id, self.is_show_image, image_res, raw_img_obj, self.data.sex, self.data.prof, false, download_callback)
	CommonDataManager.SetAvatarFrame(self.role_id, self.head_frame_res)
end

function ChatCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	self.old_role_id = self.role_id or 0
	self.role_id = self.data.role_id or 0
	self.from_uid = self.data.from_uid
	self.content = self.data.content
	self.content_type = self.data.content_type
	self.send_time_str = self.data.send_time_str
	self.channel_type = self.data.channel_type

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role_id = main_role_vo.role_id
	local main_role_id_t = main_role_vo.main_role_id_t
	self.is_left = not (self.role_id == main_role_id or main_role_id_t[self.role_id])

	--特殊处理跨服钓鱼，如果所有跨服都这样，可以使用IS_ON_CROSSSERVER
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Fishing then
		self.is_left = not (self.from_uid == main_role_id)
	end

	if self.is_easy then
		self:LoadWindow()
		self.is_easy = false
		return
	end

	--设置发送时间
	self.time:SetValue(self.send_time_str)

	--设置属性
	self.name:SetValue(string.format("<color='#0000f1'>%s</color>", self.data.username))

	--设置vip展示
	local vip_level = self.data.vip_level or 0
	local is_show_vip = true
	vip_level = IS_AUDIT_VERSION and 0 or vip_level
	if vip_level <= 0 then
		is_show_vip = false
	end

	self.show_vip:SetValue(is_show_vip)
	if is_show_vip then
		self.vip_res:SetAsset(ResPath.GetChatRes("vip_level_" .. vip_level))
	end

	local msg_id = self.data.msg_id
	--相同文本相同msg_id不处理
	if msg_id ~= self.old_msg_id then
		self.old_msg_id = msg_id
		self:LoadWindow()
	end

	--发送位置展示（左/右）
	local raw_img_obj = self.left_custom_obj
	local img_res = self.left_image_res
	if self.role_id == 0 then
		--系统展示
		self.is_system:SetValue(true)
		self.is_left = true
		self.show_left:SetValue(true)
		self.show_right:SetValue(false)
	else
		self.is_system:SetValue(false)
		if not self.is_left then
			self.show_left:SetValue(false)
			self.show_right:SetValue(true)
			raw_img_obj = self.right_custom_obj
			img_res = self.right_image_res
		else
			self.show_left:SetValue(true)
			self.show_right:SetValue(false)
		end
	end
	self:SetPortrait(raw_img_obj, img_res)

	--设置频道图片
	local curr_show_channel = ChatCtrl.Instance.view.curr_show_channel
	if self.channel_type ~= CHANNEL_TYPE.SCENE and CanShowChannel[curr_show_channel] then
		self.show_channel:SetValue(true)
		local bundle, asset = ResPath.GetA2ChatLableIcon("word")
		local title_text = Language.Channel[self.channel_type or 0]

		if self.channel_type == CHANNEL_TYPE.WORLD then
			bundle, asset = ResPath.GetA2ChatLableIcon("word")
		elseif self.channel_type == CHANNEL_TYPE.TEAM then
			bundle, asset = ResPath.GetA2ChatLableIcon("team")
		elseif self.channel_type == CHANNEL_TYPE.GUILD then
			bundle, asset = ResPath.GetA2ChatLableIcon("guild")
		elseif self.channel_type == CHANNEL_TYPE.WORLD_QUESTION then
			bundle, asset = ResPath.GetA2ChatLableIcon("word")
		elseif self.channel_type == CHANNEL_TYPE.GUILD_QUESTION then
			bundle, asset = ResPath.GetA2ChatLableIcon("guild")
		elseif self.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
			bundle, asset = ResPath.GetA2ChatLableIcon("system")
		elseif self.channel_type == CHANNEL_TYPE.SYSTEM then
			bundle, asset = ResPath.GetA2ChatLableIcon("system")
		elseif self.channel_type == CHANNEL_TYPE.PRIVATE then
			bundle, asset = ResPath.GetA2ChatLableIcon("word")
		elseif self.channel_type == CHANNEL_TYPE.SPEAKER then
			bundle, asset = ResPath.GetA2ChatLableIcon("local")
		elseif self.channel_type == CHANNEL_TYPE.CROSS then
			bundle, asset = ResPath.GetA2ChatLableIcon("cross")
		end

		self.channel:SetValue(title_text)
		self.channel_bg:SetAsset(bundle, asset)
	else
		self.show_channel:SetValue(false)
	end
end

function ChatCell:GetContentHeight()
	local height = self.root_node:GetComponent(typeof(UnityEngine.RectTransform)).rect.height

	local rect = self.content_obj:GetComponent(typeof(UnityEngine.RectTransform))
	--强制刷新
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)

	local y = rect.localPosition.y
	local des_height = rect.rect.height

	local transform = self.content_obj.transform:Find("ChatBg")
	local bg_size_y = 40
	if transform ~= nil then
		local bg_rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
		bg_size_y = bg_rect.sizeDelta.y
	end

	-- print("原始默认高度=", height, "RichText高度=", des_height, "背景图高度(相对于RichText)=", bg_rect.sizeDelta.y, "文本=", self.content)

	local content_height = height/2 - y + des_height + bg_size_y / 2
	content_height = (content_height > height) and content_height or height
	-- print("计算后的高度为=", content_height)
	return content_height
end

function ChatCell:ClickCallBack(callback, file_name)
	if callback then
		callback(file_name)
	end
end

function ChatCell:ChangeVoiceAni(state)
	if self.voice_animator and not IsNil(self.voice_animator.gameObject) then
		self.voice_animator:SetBool("play", state)
	end
end

function ChatCell:AddVoiceBtn(rich_text, tbl, is_left, callback, file_name)
	rich_text:Clear()
	if self.voice_obj then
		GameObject.Destroy(self.voice_obj.gameObject)
	end
	local time = tbl[3]
	local btn_name = is_left and "VioceButtonLeft" or "VioceButtonRight"
	local prefab = PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", btn_name)
	self.voice_obj = GameObject.Instantiate(prefab)
	local variable_table = self.voice_obj:GetComponent(typeof(UIVariableTable))
	local event_table = self.voice_obj:GetComponent(typeof(UIEventTable))
	if variable_table then
		local time_value = variable_table:FindVariable("Time")
		time_value:SetValue(time)
	end
	if event_table and callback then
		event_table:ListenEvent("ClickPlayOrStop", BindTool.Bind(self.ClickCallBack, self, callback, file_name))
	end
	rich_text:AddObject(self.voice_obj)

	self.voice_animator = self.voice_obj:GetComponent(typeof(UnityEngine.Animator))
end

function ChatCell:SetContent(rich_text, is_left, color)
	--是否语音
	if self.content_type == CHAT_CONTENT_TYPE.AUDIO then
		local temp_str = self.content
		local tbl = {}
		-- GVoice
		local is_gvoice, file_id, str, time = GVoiceManager.ParseGVoice(temp_str)
		if is_gvoice then
			tbl[3] = time
		else
			for i = 1, 3 do
				local j, k = string.find(temp_str, "(%d+)")
				local num = string.sub(temp_str, j, k)
				temp_str = string.gsub(temp_str, num, "num")
				table.insert(tbl, num)
			end
		end

		local callback = BindTool.Bind(self.PlayOrStopVoice, self)
		self:AddVoiceBtn(rich_text, tbl, is_left, callback, self.content)
		return
	end
	if color == nil then
		if self.data.tuhaojin_color > 0 then
			color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
		else
			color = COLOR.WHITE
		end
	end

	RichTextUtil.ParseRichText(rich_text, self.content, nil, color)
end

--加载聊天框
function ChatCell:LoadWindow()
	local asset = ""
	local prefab_name = ""
	local bubble_type = self.data.channel_window_bubble_type
	bubble_type = bubble_type or -1
	bubble_type = bubble_type + 1
	if bubble_type == -1 then bubble_type = 0 end

	self.is_special_bubble = false
	if self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.SCENE then
		asset = "uis/views/miscpreload_prefab"
		prefab_name = self.is_left and "ContentLeft" or "ContentRight"
	elseif not bubble_type or bubble_type == 0 then
		asset = "uis/views/miscpreload_prefab"
		prefab_name = self.is_left and "ContentLeft" or "ContentRight"
	else  -- 特殊气泡框只加载容器
		asset = "uis/views/miscpreload_prefab"
		prefab_name = self.is_left and "BubbleSlotLeft" or "BubbleSlotRight"
		self.is_special_bubble = true
	end

	if self.content_obj then
		GameObject.Destroy(self.content_obj.gameObject)
	end
	self.special_bundle_prefab_name = ""

	self.content_obj = GameObject.Instantiate(PreloadManager.Instance:GetPrefab(asset, prefab_name))
	local parent_obj = self.is_left and self.left_view or self.right_view
	self.content_obj.transform:SetParent(parent_obj.transform, false)
	local rich_text = self.content_obj:GetComponent(typeof(RichTextGroup))
	self:SetContent(rich_text, self.is_left)

	if self.is_easy then
		return
	end

	if self.is_special_bubble then
		asset = ResPath.GetBubblePrefab("", bubble_type)
		prefab_name = self.is_left and string.format("BubbleLeft%s", bubble_type) or string.format("BubbleRight%s", bubble_type)

		PrefabPool.Instance:Load(AssetID(asset, prefab_name), function(prefab)
			if nil == prefab then
				return
			end

			if self.content_obj == nil then
				PrefabPool.Instance:Free(prefab)
				return
			end

			if not self.is_special_bubble then
				PrefabPool.Instance:Free(prefab)
				return
			end

			--之前就是用相同的聊天框
			if self.special_bundle_prefab_name == prefab_name then
				PrefabPool.Instance:Free(prefab)
				return
			end

			if self.special_bundle_prefab_name ~= "" then
				--判断之前是否有聊天框存在, 有则释放
				local bundle_obj = self.content_obj.transform:Find(self.special_bundle_prefab_name .. "(Clone)")
				if nil ~= bundle_obj then
					GameObject.Destroy(bundle_obj.gameObject)
				end
				self.special_bundle_prefab_name = ""
			end

			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			obj.transform:SetParent(self.content_obj.transform, false)
			obj.transform:SetSiblingIndex(0)

			--记录当前气泡框的资源名字
			self.special_bundle_prefab_name = prefab_name
		end)
	end
end