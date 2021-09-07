FollowUi = FollowUi or BaseClass()

FollowUi.BUBBLE_VIS = false

function FollowUi:__init(obj_type)
	self.root_obj = GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "FollowUi"))
	self.root_obj.transform:SetParent(FightText.Instance.canvas.transform, false)
	self.follow_target = nil
	self.name = nil
	self.name_text = nil
	self.bubble_vis = false
	self.bubble_text = nil
	self.bubble_text_dec = nil
	self.obj_type = obj_type

	self.is_show_special_imag = false
	self.is_role_visible = false
	self.is_role_can_visible = false
	self.is_role_show = false
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

	if self.name then
		GameObjectPool.Instance:Free(self.name.gameObject)
		self.name = nil
	end

	if self.bubble_vis then
		FollowUi.BUBBLE_VIS = false
	end

	self.is_show_special_imag = false
	self.is_role_visible = false
	self.is_role_can_visible = false
	self.bundle = nil
end

function FollowUi:Create(obj_type)
	if obj_type then
		self.obj_type = obj_type		
	end
	self.follow_target = self.root_obj:GetComponent(typeof(UIFollowTarget))
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
		self.name_text.text = ""

		if self.obj_type == SceneObjType.Role then
			self.special_image_obj = self.name.transform:Find("Image").gameObject
			self.special_image = self.special_image_obj:GetComponent(typeof(UnityEngine.UI.Image))
			self.guild_name = self.name.transform:Find("GuildName")
			self.guild_name.gameObject:SetActive(false)
			self.lover_name = self.name.transform:Find("LoverName")
			self.lover_name.gameObject:SetActive(false)
			self.special_image_obj:SetActive(false)

			self.temp_height = self.name.transform:Find("TempHeight").gameObject
			if self.temp_height then
				self.temp_height:SetActive(false)
			end
		else

		end
		
	end
end

function FollowUi:SetLocalUI(x,y,z)
	local the_follow = self.root_obj.transform:Find("Follow").transform
	the_follow:SetLocalPosition(x,y,z)
end

function FollowUi:CreateTextName()
	if self.obj_type == SceneObjType.Role then
		return GameObject.Instantiate(PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "SceneRoleObjName"))
	else
		return GameObject.Instantiate(PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "SceneObjName"))
	end
end

function FollowUi:SetFollowTarget(attach_point)
	self.follow_target.Target = attach_point
end

function FollowUi:SetIsShow(is_visible)
	self.is_role_visible = is_visible
end

function FollowUi:SetIsCanShow(is_can_visible)
	self.is_role_can_visible = is_can_visible
end

function FollowUi:Show()
	self.root_obj:SetActive(true)
end

function FollowUi:Hide()
	self.root_obj:SetActive(false)
end

function FollowUi:SetName(name, secne_obj)
	if nil ~= self.name_text then
		if secne_obj and secne_obj:GetType() == SceneObjType.Npc then
			self.name_text.text = ToColorStr(name, TEXT_COLOR.NPC_BLUE)
		else
			self.name_text.text = name
		end
	end
end

function FollowUi:SetSpecialImage(is_show, asset, bundle)
	if is_show then

		if not self.is_show_special_imag or (self.bundle and self.bundle ~= bundle) then
			self.is_show_special_imag = true
			self.bundle = bundle
			if self.special_image ~= nil then
				self.special_image:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(asset, bundle, function()
					if self.special_image_obj ~= nil then
						self.special_image_obj:SetActive(self.is_show_special_imag)
					end

					if self.special_image ~= nil then
						self.special_image:SetNativeSize()
					end

					if self.temp_height and self.title_switch then
						self.temp_height:SetActive(self.is_show_special_imag)
					end
				end)
			end
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
		if self.temp_height then
			self.temp_height:SetActive(false)
		end
		if Scene.Instance:GetSceneId() == 3001 then return end --在群雄逐鹿不屏蔽
		self.is_show_special_imag = false
		self.bundle = nil
		if self.special_image_obj then
			self.special_image_obj:SetActive(false)
		end
	end
end


function FollowUi:SetGuildName(guild_name)
	if self.guild_name then
		if guild_name and guild_name ~= "" then
			self.guild_name.gameObject:SetActive(true)
			self.guild_name:GetComponent(typeof(UnityEngine.UI.Text)).text = guild_name
		else
			self.guild_name.gameObject:SetActive(false)
		end
	end
end

function FollowUi:SetLoverName(lover_name, obj)
	if nil == obj or nil == self.lover_name then return end
	local banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	if banzhuan_list == nil then return end
	local temp_banzhuan_color = banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					banzhuan_list.cur_color or banzhuan_list.get_color
	local banzhuan_color = obj:IsMainRole() and temp_banzhuan_color or obj:GetVo().banzhuan_color

	local citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	local temp_citan_color = citan_list.cur_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					citan_list.cur_qingbao_color or citan_list.get_qingbao_color
	local citan_color = obj:IsMainRole() and temp_citan_color or obj:GetVo().citan_color

	if banzhuan_color and citan_color then
		if banzhuan_color > CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID 
			or citan_color > CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
			self.lover_name.gameObject:SetActive(false)
			return
		end
	end

	if NationalWarfareData.Instance:GetBanZhuanHasReceive() then
		if lover_name and lover_name ~= "" then
			self.lover_name.gameObject:SetActive(true)
			self.lover_name:GetComponent(typeof(UnityEngine.UI.Text)).text = lover_name
		else
			if self.lover_name.gameObject.activeSelf then
				self.lover_name.gameObject:SetActive(false)
			end
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
			self.name:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 70)
		else
			self.name:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 45)
		end
	end
end

function FollowUi:CreateBubble()
	local bubble = GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "LeisureBubble"))
	return bubble
end

function FollowUi:ChangeBubble(text)
	if IsNil(self.bubble) then
		self.bubble = self:CreateBubble()
		if not IsNil(self.bubble) then
			self.bubble.transform:SetParent(self.root_obj.transform, false)
			self.bubble.transform:SetLocalPosition(-80,80,0)
			self.bubble_text = self.bubble:GetComponent(typeof(RichTextGroup))
			self.bubble_vis = true
			FollowUi.BUBBLE_VIS = true
		end
	end
	if not FollowUi.BUBBLE_VIS then
		self.bubble_text_dec = text
		return
	end
	if not IsNil(self.bubble) then
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

function FollowUi:CreateCampWarEff()
	local campwar_eff = GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "CampWarFollow"))
	return campwar_eff
end

function FollowUi:ShowBanZhuanEff(index, is_use_title)
	if IsNil(self.campwar_eff) then
		self.campwar_eff = self:CreateCampWarEff()
		if not IsNil(self.campwar_eff) then
			self.campwar_eff.transform:SetParent(self.root_obj.transform, false)
		end
	end

	self.campwar_eff.transform:Find("BanZhuanEffect").gameObject:SetActive(index > 0)

	if index <= 0 then
		if self.banzhuan_effect_obj then
			GameObjectPool.Instance:Free(self.banzhuan_effect_obj)
			self.banzhuan_effect_obj = nil
		end
		return
	end

	local asset = "zhuan_0" .. index
	local bundle = "effects2/prefab/misc/" .. string.lower(asset) .. "_prefab"

	PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
		if prefab then
			if self.banzhuan_effect_obj  ~= nil then
				GameObject.Destroy(self.banzhuan_effect_obj)
				self.banzhuan_effect_obj = nil
			end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)

			-- local pos_y = is_use_title and 0 or -50
			if IsNil(obj) then return end
			local transform = obj.transform
			--if IsNil(transform) then return end
				if not IsNil(transform) and not IsNil(self.campwar_eff) and self.campwar_eff.transform ~= nil and not IsNil(self.campwar_eff.transform) then
					local banzhuan_eff = self.campwar_eff.transform:Find("BanZhuanEffect")
					if not IsNil(banzhuan_eff) and not IsNil(banzhuan_eff.transform) then
						transform:SetParent(banzhuan_eff.transform, false)
					end
					self.banzhuan_effect_obj = obj.gameObject
					if IsNil(self.banzhuan_effect_obj) or IsNil(self.banzhuan_effect_obj.transform) then
						return
					end
					self.banzhuan_effect_obj.transform.localScale = Vector3(100, 100, 100)
					self.banzhuan_effect_obj.transform.localPosition = Vector3(0, -45, 0)
				else
					GameObject.Destroy(obj.gameObject)
				end
			end
		end)
end

function FollowUi:ShowCiTanEff(index, is_use_title)
	if IsNil(self.campwar_eff) then
		self.campwar_eff = self:CreateCampWarEff()
		if not IsNil(self.campwar_eff) then
			self.campwar_eff.transform:SetParent(self.root_obj.transform, false)
		end
	end

	if not IsNil(self.campwar_eff) then
		self.campwar_eff.transform:Find("CiTanEffect").gameObject:SetActive(index > 0)
	end

	if index <= 0 then
		if self.citan_effect_obj then
			GameObjectPool.Instance:Free(self.citan_effect_obj)
			self.citan_effect_obj = nil
		end
		return
	end

	local asset = "qingbao_0" .. index
	local bundle = "effects2/prefab/misc/" .. string.lower(asset) .. "_prefab"

	PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
		if prefab then
			if self.citan_effect_obj  ~= nil then
				GameObject.Destroy(self.citan_effect_obj)
				self.citan_effect_obj = nil
			end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)

			-- local pos_y = is_use_title and 0 or -50
			if obj == nil or IsNil(obj) then return end
			local transform = obj.transform
			--if IsNil(transform) then return end
			if not IsNil(transform) and not IsNil(self.campwar_eff) and self.campwar_eff ~= nil and not IsNil(self.campwar_eff.transform) then
				local citan_eff = self.campwar_eff.transform:Find("CiTanEffect")
				if citan_eff ~= nil and not IsNil(citan_eff.transform) then
					transform:SetParent(citan_eff.transform, false)
				end
			else
				GameObject.Destroy(obj.gameObject)
				return
			end
			self.citan_effect_obj = obj.gameObject
			
			-- if IsNil(self.citan_effect_obj) or IsNil(self.citan_effect_obj.transform) then
			-- 	return
			-- end
			self.citan_effect_obj.transform.localScale = Vector3(100, 100, 100)
			self.citan_effect_obj.transform.localPosition = Vector3(0, -45, 0)
		end
	end)
end

function FollowUi:SetCampWarEffVisiable(visible)
	if self.campwar_eff and not IsNil(self.campwar_eff) and not IsNil(self.campwar_eff.gameObject) then
		self.campwar_eff.gameObject:SetActive(visible)
	end
end

function FollowUi:ShowDeliveryArrow(flag)
	if self.npc_arrow == nil and flag then
		PrefabPool.Instance:Load(AssetID("uis/views/lianfuactivity/lianfudaily_prefab", "NpcArrow"), function(prefab)
			if nil == prefab then
				return
			end

			self.npc_arrow = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local obj_transform = self.npc_arrow.transform
			if not IsNil(obj_transform) then
				obj_transform:SetParent(self.root_obj.transform, false)
				obj_transform.localPosition = Vector3(0, 150, 0)
			end
		end)		
	end

	if self.npc_arrow ~= nil then
		self.npc_arrow:SetActive(flag)
		if not flag then
			if self.npc_arrow  ~= nil then
				GameObject.Destroy(self.npc_arrow)
				self.npc_arrow = nil
			end
		end
	end
end