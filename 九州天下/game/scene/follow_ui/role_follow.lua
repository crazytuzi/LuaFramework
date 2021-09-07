
RoleFollow = RoleFollow or BaseClass(CharacterFollow)

function RoleFollow:__init()
	self.achieve_title_text = nil
	self.dafuhao_icon = nil

	self.portrait_image = nil
	self.portrait_raw = nil
end

function RoleFollow:__delete()
	self.dafuhao_icon = nil
	self.vip_level_icon = nil

	self.portrait_image = nil
	self.portrait_raw = nil

	if self.is_role_show then
		RoleFollow.RoleFollowUiNum = RoleFollow.RoleFollowUiNum - 1
	end
	self.is_role_show = false
end

function RoleFollow:Create(obj_type)
	-- CharacterFollow.Create(self, obj_type)
	FollowUi.Create(self, obj_type or 0)
	if nil ~= self.name then
		local temp_transform = self.name.transform:Find("GameObject").transform
		temp_transform = temp_transform:Find("SceneObjName").transform
		
		self.achieve_title_list = {}
		for i=1,5 do
			self.achieve_title_list[i] = temp_transform:Find("AchieveTitle ("..i..")"):GetComponent(typeof(UnityEngine.UI.Text))
		end
		local right_transform = temp_transform:Find("RightIcon").transform
		self.dafuhao_icon = right_transform:Find("DaFuHaoIcon").gameObject
		self.vip_level_icon = right_transform:Find("VipIcon").gameObject

		local left_transform = temp_transform:Find("LeftIcon").transform
		self.portrait_image = left_transform:Find("portrait_image").gameObject
		self.portrait_raw = left_transform:Find("portrait_raw").gameObject
	end

	self.hp_bar = self:CreateHpBar()
	local the_follow = self.root_obj.transform:Find("Follow").transform
	if nil ~= self.hp_bar then
		self.hp_bar.transform:SetParent(the_follow, false)
		--self.hp_bar.transform:SetLocalPosition(0,5,0)
	end
end

function RoleFollow:CreateHpBar()
	return GameObject.Instantiate(
		PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RoleHP"))
end

function RoleFollow:SetHpPercent(percent)
	if nil == self.hp_bar then
		return
	end

	if nil == self.hp_slider_top then
		self.hp_slider_top = self.hp_bar.transform:Find("RoleHPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	end
	self.hp_slider_top.value = percent

	if nil == self.hp_slider_bottom then
		self.hp_slider_bottom = self.hp_bar.transform:Find("RoleHPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))
		self.hp_slider_bottom.value = percent
	else
		self.hp_slider_bottom:DOValue(percent, 0.5, false)
	end
end

function RoleFollow:SetDaFuHaoIconState(enable)
	if self.dafuhao_icon then
		self.dafuhao_icon:SetActive(enable)
	end
end

function RoleFollow:SetName(name, secne_obj)
	if nil ~= self.name_text then
		self.name_text.text = name
	end
	if nil ~= self.achieve_title_list then
		for k,v in pairs(self.achieve_title_list) do
			v.gameObject:SetActive(false)
		end
		if secne_obj ~= nil then
			if secne_obj:GetType() == SceneObjType.Role or secne_obj:GetType() == SceneObjType.MainRole then
				local chengjiu_title_level = secne_obj:GetAttr("chengjiu_title_level")
				if chengjiu_title_level ~= nil and chengjiu_title_level > 0 then
					if AchieveData.Instance ~= nil then
						local show_index = math.ceil(chengjiu_title_level / 25)
						if self.achieve_title_list[show_index] then
							self.achieve_title_list[show_index].gameObject:SetActive(true)
							self.achieve_title_list[show_index].text = AchieveData.Instance:GetTitleNameByLevel(chengjiu_title_level)
						end
					end
				end
			end
		end
	end
end

function RoleFollow:SetVipIcon(scene_obj)
	if self.vip_level_icon and scene_obj and
		(scene_obj:GetType() == SceneObjType.Role or scene_obj:GetType() == SceneObjType.MainRole) then

		local vip_level = scene_obj:GetAttr("vip_level")
		vip_level = IS_AUDIT_VERSION and 0 or vip_level
		if vip_level <= 0 then self.vip_level_icon:SetActive(false) return end
		local asset, bundle = ResPath.GetVipLevelIcon(vip_level)
		self.vip_level_icon:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(asset, bundle, function ()
			if self.vip_level_icon ~= nil then
				self.vip_level_icon:SetActive(true)
				--self.vip_level_icon:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
			end
		end)
	end
end

function RoleFollow:SetGuildIcon(scene_obj)
	if self.portrait_image and self.portrait_raw and scene_obj and (scene_obj:GetType() == SceneObjType.Role or scene_obj:GetType() == SceneObjType.MainRole) then
		local guild_id = scene_obj:GetAttr("guild_id")
		if guild_id <= 0 then
			self.portrait_image:SetActive(false)
			self.portrait_raw:SetActive(false)
			return
		end
		local role_id = scene_obj:GetAttr("role_id")

		-- self.portrait_image:SetActive(AvatarManager.Instance:isDefaultImg(guild_id) == 0)
		-- self.portrait_raw:SetActive(AvatarManager.Instance:isDefaultImg(guild_id) ~= 0)

		if AvatarManager.Instance:isDefaultImg(guild_id) == 0 then
			local camp = scene_obj:GetAttr("camp")
			local bundle, asset = ResPath.GetGuildBadgeIcon(camp)
			self.portrait_image:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function ()
				if self.portrait_image and self.portrait_raw then
					if self.portrait_image ~= nil then
						self.portrait_image:SetActive(true)
						self.portrait_image:SetActive(Scene.Instance:GetCurFbSceneCfg().guild_badge == 0)
					end

					if self.portrait_raw ~= nil then
						self.portrait_raw:SetActive(false)
					end
				end
			end)
			return
		else
			local callback = function (path)
				self.avatar_path_big = path or AvatarManager.GetFilePath(guild_id, true)
				if self.portrait_image and self.portrait_raw then
					local raw_image_obj = self.portrait_raw:GetComponent(typeof(UnityEngine.UI.RawImage))
					if not IsNil(raw_image_obj) then
						raw_image_obj:LoadSprite(self.avatar_path_big, function ()
							if self.portrait_image ~= nil then
								self.portrait_image:SetActive(false)
							end

							if self.portrait_raw ~= nil then
								self.portrait_raw:SetActive(true)
							end
						end)
					end
				end
			end
			AvatarManager.Instance:GetGuildAvatar(role_id, guild_id, false, callback)
		end
	end
end

function RoleFollow:SetIsShowGuildIcon(vo, enable)
	if self.portrait_image then
		vo = vo or {}
		if vo.guild_id and vo.guild_id > 0 then
			if AvatarManager.Instance:isDefaultImg(vo.guild_id) ~= 0 then
				self.portrait_image:SetActive(false)
			else
				self.portrait_image:SetActive(enable)
			end
		else
			self.portrait_image:SetActive(false)
		end
	end
end

-- 退出家族情况出来
function RoleFollow:SetRoleGuildIconValue()
	if self.portrait_image and self.portrait_raw then
		self.portrait_image:SetActive(false)
		self.portrait_raw:SetActive(false)
	end
end

function RoleFollow:SetIsShow(is_visible)
	self.is_role_visible = is_visible
end

function RoleFollow:SetIsCanShow(is_can_visible)
	self.is_role_can_visible = is_can_visible
end

RoleFollow.RoleFollowUiNum = 0
function RoleFollow:Show()
	if self.is_role_visible == false then
		self.root_obj:SetActive(true)
	elseif RoleFollow.RoleFollowUiNum < 10 and self.is_role_can_visible then
		if self.is_role_show == false then
			RoleFollow.RoleFollowUiNum = RoleFollow.RoleFollowUiNum + 1
			self.is_role_show = true
		end
		self.root_obj:SetActive(true)
	end
end

function RoleFollow:Hide()
	self.root_obj:SetActive(false)
	if self.is_role_show then
		RoleFollow.RoleFollowUiNum = RoleFollow.RoleFollowUiNum - 1
		self.is_role_show = false
	end
end

function RoleFollow:GetIsCanShowUi()
	return RoleFollow.RoleFollowUiNum < 10
end