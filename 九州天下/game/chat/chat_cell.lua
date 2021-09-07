ChatCell = ChatCell or BaseClass(BaseCell)
function ChatCell:__init()
	self.touch_down_time = 0
	self.avatar_key = 0
	self.old_msg_id = -1
	self.is_special_bubble = false

	--获取变量
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.show_left = self:FindVariable("ShowLeft")
	self.show_right = self:FindVariable("ShowRight")
	self.channel = self:FindVariable("Channel")
	self.channel_bg = self:FindVariable("ChannelBg")
	self.show_channel = self:FindVariable("ShowChannel")
	self.is_system = self:FindVariable("IsSystem")
	self.is_system_head = self:FindVariable("IsSystemHead")
	self.head_frame_res = self:FindVariable("head_frame_res")

	--头像相关
	self.left_image_res = self:FindVariable("LeftImageRes")
	self.right_image_res = self:FindVariable("RightImageRes")
	self.is_show_image = self:FindVariable("IsShowImage")
	self.raw_left_img = self:FindObj("RawLeftImg")
	self.raw_right_img = self:FindObj("RawRightImg")

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
	self.avatar_key = 0
	self.old_msg_id = -1
end

--添加文本到聊天框
function ChatCell:AddChatToInput()
	GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	self.icon_time_quest = nil
	if not self.data or not next(self.data) then
		return
	end
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().origin_role_id
	local text = "@" .. self.data.username
	if self.avatar_id == 0 or main_role_id == self.avatar_id then
		return
	elseif self.data.channel_type == CHANNEL_TYPE.SCENE then
		HotStringChatCtrl.Instance:AddTextToInput(text)
	else
		ChatCtrl.Instance:AddTextToInput(text)
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
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().origin_role_id
	if self.avatar_id == 0 or main_role_id == self.avatar_id then
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
	ChatRecordMgr.Instance:PlayVoice(file_name, call_back, call_back)
end

--头像回调
function ChatCell:AvatarLoadCallBack(role_id, raw_img_obj, path)
	if self:IsNil() then
		return
	end

	if role_id ~= self.role_id then
		self.is_show_image:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(self.avatar_id, false)
	end

	raw_img_obj.raw_image:LoadSprite(path, function ()
		if role_id ~= self.role_id then
			self.is_show_image:SetValue(true)
			return
		end
		self.is_show_image:SetValue(false)
	end)
end

function ChatCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	self.role_id = self.data.from_uid
	self.avatar_id = self.data.from_origin_uid or self.data.from_uid
	self.content = self.data.content
	self.content_type = self.data.content_type
	self.send_time_str = self.data.send_time_str
	self.channel_type = self.data.channel_type

	--设置发送时间
	self.time:SetValue(self.send_time_str)

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().origin_role_id

	--设置属性
	local name_str = self.data.username
	-- if self.data.sex == 1 then
	-- 	name_str = string.format("<color='#a9d3fe'>%s</color>", self.data.username)
	-- elseif self.data.sex == 2 then
	-- 	name_str = string.format("<color='#cb74d0'>%s</color>", self.data.username)
	-- end
	-- 跨服与喇叭也要看到国家标记
	if ((self.channel_type == CHANNEL_TYPE.WORLD)
		 or (self.channel_type == CHANNEL_TYPE.SPEAKER)
		 or (self.channel_type == CHANNEL_TYPE.CROSS))
		 and self.role_id ~= 0 then
		local camp_name = CampData.Instance:GetCampNameByCampType(self.data.camp, true)
		name_str = string.format(Language.Chat.ChatNameSecond, ToColorStr(camp_name, CAMP_COLOR[self.data.camp]), name_str)
	end
	self.name:SetValue(name_str)

	--设置vip展示
	local vip_level = self.data.vip_level or 0
	local is_show_vip = true
	vip_level = IS_AUDIT_VERSION and 0 or vip_level
	if vip_level <= 0 then
		is_show_vip = false
	end

	self.show_vip:SetValue(is_show_vip)
	if is_show_vip then
		self.vip_res:SetAsset(ResPath.GetVipLevelIcon(vip_level))
	end

	local msg_id = self.data.msg_id
	--相同文本相同msg_id不处理
	if msg_id ~= self.old_msg_id then
		self.old_msg_id = msg_id
		self:LoadWindow(main_role_id)
	end

	local function SetIconImage(raw_img_obj, image_res)
		self.is_system_head:SetValue(false)
		--先显示默认图片
		if not self.role_id or self.role_id == 0 then
			self.avatar_key = 0
			local bundle, asset = ResPath.GetRoleIconBig(100) -- 系统头像
			image_res:SetAsset(bundle, asset)
			self.is_show_image:SetValue(true)
			self.is_system_head:SetValue(true)
			self.head_frame_res:SetAsset(nil, nil)
			return
		end

		if self.data.channel_type == CHANNEL_TYPE.SCENE then
			self.avatar_key = 0
			local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
			image_res:SetAsset(bundle, asset)
			self.is_show_image:SetValue(true)
			self.head_frame_res:SetAsset(nil, nil)
			return
		end

		local avatar_key = AvatarManager.Instance:GetAvatarKey(self.avatar_id)
		if avatar_key == 0 then
			self.avatar_key = 0
			local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
			image_res:SetAsset(bundle, asset)
			self.is_show_image:SetValue(true)
		else
			if avatar_key ~= self.avatar_key then
				self.avatar_key = avatar_key
				AvatarManager.Instance:GetAvatar(self.avatar_id, false, BindTool.Bind(self.AvatarLoadCallBack, self, self.role_id, raw_img_obj))
			end
		end
	end

	--发送位置展示（左/右）
	local raw_img_obj = self.raw_left_img
	local img_res = self.left_image_res
	if not self.role_id or self.role_id == 0 then
		--系统展示
		self.is_left = true
		self.show_left:SetValue(true)
		self.show_right:SetValue(false)
	else
		if self.avatar_id == main_role_id then
			self.is_left = false
			self.show_left:SetValue(false)
			self.show_right:SetValue(true)
			raw_img_obj = self.raw_right_img
			img_res = self.right_image_res
		else
			self.is_left = true
			self.show_left:SetValue(true)
			self.show_right:SetValue(false)
		end
	end
	SetIconImage(raw_img_obj, img_res)

	--设置频道图片
	local curr_show_channel = ChatCtrl.Instance.view.curr_show_channel
	if self.channel_type ~= CHANNEL_TYPE.SCENE and CanShowChannel[curr_show_channel] then
		self.show_channel:SetValue(true)
		local bundle, asset = ResPath.GetMainlblIcon(CHANNEL_TYPE.WORLD)
		local title_text = Language.Channel[self.data.channel_type or 0]
		if CanShowChannel[self.data.channel_type] then
			bundle, asset = ResPath.GetMainlblIcon(self.data.channel_type)			
		end
		self.channel:SetValue(title_text)
		self.channel_bg:SetAsset(bundle, asset)
		--设置描边颜色
		local outline_color = CHANEL_TEXT_OUTLINE_COLOR[self.data.channel_type] or CHANEL_TEXT_OUTLINE_COLOR[CHANNEL_TYPE.WORLD]
		if self.is_left and self.left_chanel_text.outline then
			self.left_chanel_text.outline.effectColor = outline_color
		elseif self.right_chanel_text.outline then
			self.right_chanel_text.outline.effectColor = outline_color
		end
	else
		self.show_channel:SetValue(false)
	end

	self.is_system:SetValue(self.data.channel_type == CHANNEL_TYPE.SYSTEM)

	CommonDataManager.SetAvatarFrame(self.role_id, self.head_frame_res)
end

function ChatCell:GetContentHeight()
	local height = self.root_node:GetComponent(typeof(UnityEngine.RectTransform)).rect.height

	local rect = self.content_obj:GetComponent(typeof(UnityEngine.RectTransform))
	--强制刷新
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)

	local y = rect.localPosition.y
	local des_height = rect.sizeDelta.y

	local transform = self.content_obj.transform:FindHard("ChatBg")
	local bg_obj = nil
	local bg_size_y = 40
	if transform ~= nil then
		bg_obj = U3DObject(transform.gameObject, transform)
		local bg_rect = bg_obj.rect
		bg_size_y = bg_rect.sizeDelta.y
	end

	-- print("原始默认高度=", height, "RichText高度=", des_height, "背景图高度(相对于RichText)=", bg_rect.sizeDelta.y, "文本=", self.content)

	local content_height = height/2 - y + des_height + bg_size_y / 2
	-- print("计算后的高度为=", content_height)
	return content_height
end

function ChatCell:ClickCallBack(callback, file_name)
	if callback then
		callback(file_name)
	end
end

function ChatCell:ChangeVoiceAni(state)
	if self.voice_animator and not IsNil(self.voice_animator) and not IsNil(self.voice_animator.gameObject) then
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
		if time_value and time ~= nil then
			time_value:SetValue(time)
		end
	end
	if event_table and callback then
		event_table:ListenEvent("ClickPlayOrStop", BindTool.Bind(self.ClickCallBack, self, callback, file_name))
	end
	rich_text:AddObject(self.voice_obj)

	self.voice_animator = self.voice_obj:GetComponent(typeof(UnityEngine.Animator))
end

function ChatCell:SetContent(rich_text, is_left)
	--是否语音
	if self.content_type == CHAT_CONTENT_TYPE.AUDIO then
		local str = self.content
		local tbl = {}
		for i = 1, 3 do
			local j, k = string.find(str, "(%d+)")
			if (nil ~= j) and (nil ~= k) then
				local num = string.sub(str, j, k)
				str = string.gsub(str, num, "num")
				table.insert(tbl, num)
			end
		end
		local callback = BindTool.Bind(self.PlayOrStopVoice, self)
		self:AddVoiceBtn(rich_text, tbl, is_left, callback, self.content)
		return
	end

	local color = ""
	if self.data.tuhaojin_color > 0 then
		color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
	else
		color = TEXT_COLOR.BLACK_1
	end

	if self.role_id ~= 0 and self.content_type ~= CHAT_CONTENT_TYPE.AUDIO then
		self.content = ChatFilter.Instance:Filter(self.content)
	end

	RichTextUtil.ParseRichText(rich_text, self.content, nil, color)
end

--加载聊天框
function ChatCell:LoadWindow(main_role_id)
	local assetbundle = ""
	local prefab_name = ""
	local left = true
	local bubble_type = self.data.channel_window_bubble_type
	bubble_type = bubble_type or -1
	bubble_type = bubble_type + 1
	if bubble_type == -1 then bubble_type = 0 end
	if main_role_id == self.avatar_id then
		left = false
	end
	self.is_special_bubble = false
	if self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.SCENE then
		assetbundle = "uis/views/miscpreload_prefab"
		prefab_name = left and "ContentLeft" or "ContentRight"
	elseif self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.SYSTEM then
		assetbundle = "uis/views/miscpreload_prefab"
		prefab_name = left and "SystemContentLeft" or "SystemContentRight"
	elseif not bubble_type or bubble_type == 0 then
		assetbundle = "uis/views/miscpreload_prefab"
		prefab_name = left and "ContentLeft" or "ContentRight"
	else  -- 特殊气泡框只加载容器
		assetbundle = "uis/views/miscpreload_prefab"
		prefab_name = left and "BubbleSlotLeft" or "BubbleSlotRight"
		self.is_special_bubble = true
	end

	if self.content_obj then
		GameObject.Destroy(self.content_obj.gameObject)
	end

	self.content_obj = GameObject.Instantiate(PreloadManager.Instance:GetPrefab(assetbundle, prefab_name))
	local parent_obj = left and self.left_view or self.right_view
	self.content_obj.transform:SetParent(parent_obj.transform, false)
	local rich_text = self.content_obj:GetComponent(typeof(RichTextGroup))
	self:SetContent(rich_text, left)

	if self.is_special_bubble then
		assetbundle = string.format("uis/chatres/bubbleres/bubble%s_prefab", bubble_type)
		prefab_name = left and string.format("BubbleLeft%s", bubble_type) or string.format("BubbleRight%s", bubble_type)
		PrefabPool.Instance:Load(AssetID(assetbundle, prefab_name), function(prefab)
			if nil == prefab then
				return
			end
			
			if nil == self.content_obj then
				return
			end

			if not self.is_special_bubble then
				PrefabPool.Instance:Free(prefab)
				return
			end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			obj.transform:SetParent(self.content_obj.transform, false)
			obj.transform:SetSiblingIndex(0)
		end)
	end
end
