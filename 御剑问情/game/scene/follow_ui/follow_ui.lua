FollowUi = FollowUi or BaseClass()

FollowUi.BUBBLE_VIS = false

function FollowUi:__init()
	self.root_obj = GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "FollowUi"))
	self.root_obj.transform:SetParent(FightText.Instance.canvas.transform, false)
	self.follow_target = nil
	self.name = nil
	self.name_text = nil
	self.bubble_vis = false
	self.bubble_text = nil
	self.bubble_text_dec = nil

	self.is_show_special_imag = false
	self.bundle = nil
end

function FollowUi:__delete()
	if nil ~= self.root_obj then
		GameObject.Destroy(self.root_obj)
		self.root_obj = nil
	end
	-- if self.load_special_image_delay then
	-- 	GlobalTimerQuest:CancelQuest(self.load_special_image_delay)
	-- 	self.load_special_image_delay = nil
	-- end
	if self.title then
		GameObjectPool.Instance:Free(self.title.gameObject)
		self.title = nil
	end
	if self.bubble_vis then
		FollowUi.BUBBLE_VIS = false
	end

	self.is_show_special_imag = false
	self.bundle = nil
	self:RemoveDelayTime()
end

function FollowUi:Create()
	self.follow_target = self.root_obj:GetComponent(typeof(UIFollowTarget))
	self.follow_distance = self.root_obj:GetComponent(typeof(UIFollowDistance))
	self.follow_target.Canvas = FightText.Instance:GetCanvas()

	self.name = self:CreateTextName()
	if nil ~= self.name then
		local the_follow = self.root_obj.transform:Find("Follow").transform
		self.name.transform:SetParent(the_follow.transform, false)
		-- self.name.transform:SetLocalPosition(0,70,0)

		-- 设置名字默认的Position
		self.name:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 45)

		local temp_transform = self.name.transform:Find("GameObject").transform
		temp_transform = temp_transform:Find("SceneObjName").transform
		self.name_text = temp_transform:GetComponent(typeof(UnityEngine.UI.Text))
		self.special_image = self.name.transform:Find("ImageObj").gameObject
		self.special_image_obj = self.special_image.transform:Find("Image").gameObject
		self.special_image = self.special_image_obj:GetComponent(typeof(UnityEngine.UI.Image))
		self.guild_name = self.name.transform:Find("GuildName")
		self.guild_name.gameObject:SetActive(false)
		self.lover_name = self.name.transform:Find("LoverName")
		self.lover_name.gameObject:SetActive(false)

		self.temp_height = self.name.transform:Find("TempHeight").gameObject
		if self.temp_height then
			self.temp_height:SetActive(false)
		end
	end
end

function FollowUi:SetLocalUI(x,y,z)
	local the_follow = self.root_obj.transform:Find("Follow").transform
	the_follow:SetLocalPosition(x,y,z)
end

function FollowUi:CreateTextName()
	return GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "SceneObjName"))
end

function FollowUi:SetFollowTarget(attach_point)
	self.follow_target.Target = attach_point
	self.follow_distance.TargetTransform = attach_point
end

function FollowUi:Show()
	self.root_obj:SetActive(true)
end

function FollowUi:Hide()
	self.root_obj:SetActive(false)
end

function FollowUi:SetName(name, secne_obj)
	if nil ~= self.name_text then
		self.name_text.text = name
	end
end

function FollowUi:SetTextScale(x, y)
	self.name_text.transform.localScale = Vector3(x,y,1)
end

function FollowUi:SetTextPosY(y)
	self.name_text.transform.localPosition = Vector3(0,y,0)
end

function FollowUi:SetImageScale(scale_x,scale_y)
	if self.name then
		self.special_image.transform.localScale = Vector3(scale_x,scale_y,1)
	end
end

function FollowUi:SetSpecialImage(is_show, asset, bundle)
	if is_show then
		if not self.is_show_special_imag or (self.bundle and self.bundle ~= bundle) then
			self.is_show_special_imag = true
			self.bundle = bundle
			self.special_image:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(asset, bundle, function()
				self.special_image_obj:SetActive(self.is_show_special_imag)
				self.special_image:SetNativeSize()

				if self.temp_height and self.title_switch then
					self.temp_height:SetActive(self.is_show_special_imag)
				end
			end)
		end
		-- if nil == self.load_special_image_delay then
		-- 	self.load_special_image_delay = GlobalTimerQuest:AddDelayTimer(function()
		-- 		self.load_special_image_delay = nil
		-- 		self.special_image_obj:SetActive(true)
		-- 		self.special_image:SetNativeSize()
		-- 		self.is_show_special_imag = true
		-- 		if self.title_list then
		-- 			for k, v in pairs(self.title_list) do
		-- 				-- local temp = k
		-- 				-- if temp == 0 then temp = 1 end
		-- 				-- local space = 30
		-- 				local image_height = 0
		-- 				if self.special_image_obj:GetComponent(typeof(UnityEngine.RectTransform)) then
		-- 					image_height = self.special_image_obj:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.y
		-- 				end

		-- 				local temp_y = v.gameObject.transform.localPosition.y
		-- 				v.gameObject.transform:SetLocalPosition(0, image_height + temp_y, 0) -- temp * 50 + space
		-- 			end
		-- 		end
		-- 	 end, 0.1)
		-- end
	else
		-- if self.load_special_image_delay then
		-- 	GlobalTimerQuest:CancelQuest(self.load_special_image_delay)
		-- 	self.load_special_image_delay = nil
		-- end
		-- if self.title_list and self.is_show_special_imag then
		-- 	local image_height = 40
		-- 	local temp_y = self.special_image_obj.transform.localPosition.y
		-- 	self.special_image_obj.transform:SetLocalPosition(0, temp_y - image_height, 0)
		-- end
		self.is_show_special_imag = false
		self.bundle = nil
		if self.temp_height then
			self.temp_height:SetActive(false)
		end
		self.special_image_obj:SetActive(false)
	end
end


function FollowUi:SetGuildName(guild_name)
	if guild_name and guild_name ~= "" then
		self.guild_name.gameObject:SetActive(true)
		self.guild_name:GetComponent(typeof(UnityEngine.UI.Text)).text = guild_name
	else
		self.guild_name.gameObject:SetActive(false)
	end
end

function FollowUi:SetLoverName(lover_name)
	if lover_name and lover_name ~= "" then
		self.lover_name.gameObject:SetActive(true)
		self.lover_name:GetComponent(typeof(UnityEngine.UI.Text)).text = lover_name
	else
		if self.lover_name.gameObject.activeSelf then
			self.lover_name.gameObject:SetActive(false)
		end
	end
end

function FollowUi:ChangeTitle(bubble, asset, pos_x, pos_y)
	if self.title ~= nil then
		GameObjectPool.Instance:Free(self.title.gameObject)
		self.title = nil
	end
	if bubble == nil or asset == nil then
		return
	end
	GameObjectPool.Instance:SpawnAsset(
			bubble,
			asset,
			BindTool.Bind(self.OnTitleLoadComplete, self, pos_x, pos_y))
end

function FollowUi:OnTitleLoadComplete(pos_x, pos_y, obj)
	if IsNil(obj) or not self.root_obj then return end
	if self.title ~= nil then
		GameObjectPool.Instance:Free(self.title.gameObject)
		self.title = nil
	end
	self.title = U3DObject(obj)

	if nil ~= self.title then
		self.title.gameObject.transform:SetParent(self.root_obj.transform, false)
		pos_x = pos_x or 0
		pos_y = pos_y or 80
		self.title.gameObject.transform:SetLocalPosition(pos_x, pos_y, 0)
	end
end

function FollowUi:GetNameTextObj()
	return self.name
end

-- 外部设置名字的Position
function FollowUi:SetNameTextPosition()
	if self.name then
		if self.hp_bar then
			self.name:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 65)
		else
			self.name:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 45)
		end
	end
end

function FollowUi:SetHpBarLocalPosition()
end

function FollowUi:CreateBubble()
	local bubble = GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "LeisureBubble"))
	return bubble
end

function FollowUi:ChangeBubble(text, time)
	if nil == self.bubble then
		self.bubble = self.CreateBubble()
		if self.bubble then
			self.bubble.transform:SetParent(self.root_obj.transform, false)
			self.bubble.transform:SetLocalPosition(0,50,0) ---80,80,0
			self.bubble_text = self.bubble:GetComponent(typeof(RichTextGroup))
			self.bubble_vis = true
			FollowUi.BUBBLE_VIS = true
		end
	end
	if nil ~= time and time > 0 then
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:HideBubble() end, time)
	end
	if not FollowUi.BUBBLE_VIS then
		self.bubble_text_dec = text
		return
	end
	if nil ~= self.bubble then
		RichTextUtil.ParseRichText(self.bubble_text, text)
	end
end

function FollowUi:HideBubble()
	if nil ~= self.bubble then
		self.bubble_text:Clear()
		self.bubble:SetActive(false)
	end
	FollowUi.BUBBLE_VIS = false
	self.bubble_vis = false
end

function FollowUi:ShowBubble()
	if FollowUi.BUBBLE_VIS then
		return
	end
	if nil ~= self.bubble then
		self.bubble:SetActive(true)
	end
	FollowUi.BUBBLE_VIS = true
	self.bubble_vis = true
	if self.bubble_text_dec then
		self:ChangeBubble(self.bubble_text_dec)
		self.bubble_text_dec = nil
	end
end

function FollowUi:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end