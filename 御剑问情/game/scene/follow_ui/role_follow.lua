
RoleFollow = RoleFollow or BaseClass(CharacterFollow)

function RoleFollow:__init()
	self.achieve_title_text = nil
	self.dafuhao_icon = nil
	self.guild_icon_owner = nil
	self.name_str = ""
end

function RoleFollow:__delete()
	self.guild_icon_owner = nil
	self.name_str = ""
end

function RoleFollow:Create()
	CharacterFollow.Create(self)
	if nil ~= self.name then
		local temp_transform = self.name.transform:Find("GameObject").transform
		temp_transform = temp_transform:Find("SceneObjName").transform
		local right_transform = temp_transform:Find("RightIcon").transform
		self.dafuhao_icon = right_transform:Find("DaFuHaoIcon").gameObject
		self.vip_level_icon = right_transform:Find("VipIcon").gameObject

		local left_transform = temp_transform:Find("LeftIcon").transform
		self.portrait_image = left_transform:Find("portrait_image").gameObject
		self.portrait_raw = self.portrait_image.transform:Find("portrait_raw").gameObject
		self.longxing_icon = left_transform:Find("LongXingIcon").gameObject
		self.longxing_rank = self.longxing_icon.transform:Find("LongXingRank").gameObject
	end
end

function RoleFollow:CreateHpBar()
	return GameObject.Instantiate(PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "RoleHP"))
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

-- 外部设置名字的Position
function RoleFollow:SetNameTextPosition()
	if self.name then
		if self.hp_bar then
			self.name:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 70)
		else
			self.name:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(0, 45)
		end
	end
end


function RoleFollow:SetDaFuHaoIconState(enable)
	if self.dafuhao_icon then
		self.dafuhao_icon:SetActive(enable)
	end
end

function RoleFollow:SetVipIcon(scene_obj)
	if self.vip_level_icon and scene_obj and
		(scene_obj:GetType() == SceneObjType.Role or scene_obj:GetType() == SceneObjType.MainRole) then

		local vip_level = scene_obj:GetAttr("vip_level")
		vip_level = IS_AUDIT_VERSION and 0 or vip_level
		if vip_level <= 0 then self.vip_level_icon:SetActive(false) return end
		local asset, bundle = ResPath.GetMiscPreloadVipLevelIcon(vip_level)
		self.vip_level_icon:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(asset, bundle, function ()
			self.vip_level_icon:SetActive(true)
		end)
	end
end

function RoleFollow:SetLongXingIcon(scene_obj)
	if self.longxing_icon and scene_obj and
		(scene_obj:GetType() == SceneObjType.Role or scene_obj:GetType() == SceneObjType.MainRole) then

		local longxing_level = scene_obj:GetAttr("touxian")
		longxing_level = IS_AUDIT_VERSION and 0 or longxing_level
		if longxing_level <= 0 then
			self.longxing_icon:SetActive(false)
			self.longxing_rank:SetActive(false)
			return
		end
		local asset, bundle = ResPath.GetFollowLongxingLevelIcon(TouxianData.GetTouxianIcon(longxing_level))
		self.longxing_icon:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(asset, bundle, function ()
			self.longxing_icon:SetActive(true)
			self.longxing_rank:SetActive(true)
			self.longxing_rank:GetComponent(typeof(UnityEngine.UI.Text)).text = TouxianData.GetTouxianNum(longxing_level)
		end)
	end
end

function RoleFollow:SetGuildIcon(scene_obj)
	if not scene_obj:IsRole() or scene_obj:GetVo().guild_id == nil or scene_obj:GetVo().guild_id <= 0
		or AvatarManager.Instance:isDefaultImg(scene_obj:GetVo().guild_id, true) == 0 then
			self:SetIsShowGuildIcon(false)
		return
	end
	self.guild_icon_owner = scene_obj
	if self.portrait_raw then
		local callback = function (path)
			if self.guild_icon_owner and self.guild_icon_owner.draw_obj then
				self.avatar_path_big = path or AvatarManager.GetFilePath(self.guild_icon_owner:GetVo().guild_id, true, true)
				if self.avatar_path_big then
					self.portrait_raw:GetComponent(typeof(UnityEngine.UI.RawImage)):LoadSprite(self.avatar_path_big, function()
					end)
				end
				local vis = self.guild_icon_owner:IsRoleVisible() and AvatarManager.Instance:isDefaultImg(self.guild_icon_owner:GetVo().guild_id, true) ~= 0
				self.portrait_raw:SetActive(vis)
				self.portrait_image:SetActive(vis)
			end
		end
		local guild = self.guild_icon_owner:GetVo().guild_id
		AvatarManager.Instance:GetAvatar(guild, false, callback, guild)
	end
end

function RoleFollow:SetIsShowGuildIcon(enable)
	if self.portrait_raw then
		if enable and self.guild_icon_owner then
			local is_show = self.guild_icon_owner:IsRoleVisible() and AvatarManager.Instance:isDefaultImg(self.guild_icon_owner:GetVo().guild_id, true) ~= 0
			self.portrait_raw:SetActive(is_show)
			self.portrait_image:SetActive(is_show)
		else
			self.portrait_raw:SetActive(false)
			self.portrait_image:SetActive(false)
		end
	end
end
