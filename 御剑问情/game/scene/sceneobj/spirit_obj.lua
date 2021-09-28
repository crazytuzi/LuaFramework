
SpiritObj = SpiritObj or BaseClass(FollowObj)

-- 精灵
function SpiritObj:__init(spirit_vo)
	self.obj_type = SceneObjType.SpiritObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(spirit_vo.used_sprite_id)
	self.vo = spirit_vo
	self.is_spirit = true

	self.follow_offset = -2
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 10

	self.lingzhu_res_id = -1
	self.fight_state = false
end

function SpiritObj:__delete()
	self.obj_type = nil
	self.load_call_back = nil
	--if self.draw_obj then
		--GameObject.Destroy(self.draw_obj:GetRoot().gameObject)
	--end
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end
	if self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
	self:DeleteFaZhen()
end

function SpiritObj:SetAttr(key, value)
	Character.SetAttr(self, key, value)

	if key == "lingzhu_use_imageid" then
		self:UpdateSpritLingZhu()
		self:ChangeSpritLingZhu()
	elseif key == "use_jingling_titleid" then
		self:UpdateSpiritTitle()
	end
end

function SpiritObj:InitShow()
	self:ShowFirstBubble()
	FollowObj.InitShow(self)
	if self.vo.used_sprite_id ~= nil and self.vo.used_sprite_id ~= 0 then
		local spirit_cfg = nil
		if self.vo.user_pet_special_img ~= nil and self.vo.user_pet_special_img >= 0 then
			spirit_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(self.vo.user_pet_special_img)
		else
			spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.vo.used_sprite_id)
		end
		if spirit_cfg and  spirit_cfg.res_id and spirit_cfg.res_id > 0 then
			-- self.vo.name = spirit_cfg.name
			self:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(spirit_cfg.res_id))
			self:ShowFollowUi()
			local spirit_name = self.vo.spirit_name ~= "" and self.vo.spirit_name or spirit_cfg.name
			spirit_name = spirit_name or spirit_cfg.image_name -- 他喵的 特殊形象配置表里面字段名不一样！！！
			self:GetFollowUi():SetName(spirit_name)
			self:UpdateSpiritTitle()
			self.follow_ui:SetHpVisiable(false)
			self:UpdateSpritLingZhu()
			self:ChangeSpritLingZhu()
		end
	end
	self:ApperanceShieldChanged()
end

function SpiritObj:UpdateSpritId(used_sprite_id)
	self.vo.used_sprite_id = used_sprite_id or self.vo.used_sprite_id
end

function SpiritObj:UpdateSpecialSpritId(user_pet_special_img)
	self.vo.user_pet_special_img = user_pet_special_img or -1
end

function SpiritObj:UpdateSpiritTitle()
	local title_id = self.vo.use_jingling_titleid or 0
	if TitleData.Instance:IsLingPoTitle(title_id) then
		self:GetFollowUi():SetTitle(1, title_id)
	end
end

function SpiritObj:SetSpiritName(spirit_name)
	local spirit_info_list = SpiritData.Instance:GetSpiritInfo()
	if self.vo.used_sprite_id ~= nil and self.vo.used_sprite_id ~= 0 or (spirit_info_list and spirit_info_list.phantom_imageid and spirit_info_list.phantom_imageid >= 0) then
		local spirit_cfg = nil
		if self.vo.user_pet_special_img ~= nil and self.vo.user_pet_special_img >= 0 then
			spirit_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(self.vo.user_pet_special_img)
		else
			spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.vo.used_sprite_id)
		end

		if spirit_cfg and  spirit_cfg.res_id and spirit_cfg.res_id > 0 then
			spirit_name = spirit_name ~= "" and spirit_name or spirit_cfg.name
			spirit_name = spirit_name or spirit_cfg.image_name
			self:GetFollowUi():SetName(spirit_name)
			self.follow_ui:SetHpVisiable(false)
		end
	end
end

function SpiritObj:SetLoadCallBack(call_back)
	self.load_call_back = call_back
end

function SpiritObj:LoadOver()
	local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_SPIRIT]
	if is_hide then
		self:GetDrawObj():SetVisible(not is_hide)
		self:GetFollowUi():Hide()
	end
	if self.load_call_back then
		self.load_call_back()
	end
end

function SpiritObj:IsCharacter()
	return false
end

function SpiritObj:GetOwerRoleId()
	return self.vo.owner_role_id
end

function SpiritObj:MoveEnd()
	if nil == self.distance then
		return false
	end
	return self.distance <= 6
end

function SpiritObj:IsSpirit()
	return true
end

function SpiritObj:SetSpiritVisible(is_visible)
	self.is_visible = is_visible
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)
		if is_visible then
			self:GetFollowUi():Show()
		else
			self:GetFollowUi():Hide()
		end
	end
	if not is_visible then
		self:ChangeSpiritFazhen()
	end
end

function SpiritObj:GetRandBubbletext()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_jingling_list

	local temp_list = {}
	for k,v in pairs(bubble_cfg) do
		if v.jingling_scene_id == 0 then
			table.insert(temp_list,v)
		end
	end

	if #temp_list > 0 then
		math.randomseed(os.time())
		local bubble_text_index = math.random(1, #temp_list)
		return temp_list[bubble_text_index].bubble_jingling_text
	else
		return ""
	end
end

function SpiritObj:GetFirstBubbleText()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_jingling_list
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(bubble_cfg) do
		if v.jingling_scene_id == scene_id then
			return v.bubble_jingling_text
		end
	end
end

function SpiritObj:ShowFirstBubble()
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			if nil ~= self.follow_ui and self:IsMySpirit() then
				local text = self:GetFirstBubbleText()
				if nil ~= text then
					self.follow_ui:ChangeBubble(text)
				end
			end
			self:UpdataTimer()
		end, 8)
	end
end

function SpiritObj:UpdataBubble()
	if nil ~= self.follow_ui then
		local text = self:GetRandBubbletext()
		self.follow_ui:ChangeBubble(text)
	end
end

function SpiritObj:UpdataTimer()
	local exist_time = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].exist_time
	local jingling_interval = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].jingling_interval
	self.bobble_timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:UpdataTimer() end, exist_time)

	if self.timer and nil ~= self.follow_ui and self:IsMySpirit() then
		if self.timer >= jingling_interval then
			self.timer = self.timer - jingling_interval
			local rand_num = math.random(1, 10)
			local jingling_odds = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].jingling_odds
			if rand_num * 0.1 <= jingling_odds then
				self:UpdataBubble()
				self.follow_ui:ShowBubble()
			end
		else
			self.follow_ui:HideBubble()
		end
	end
	self.timer = self.timer and self.timer + exist_time or exist_time
end

function SpiritObj:IsMySpirit()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		return true
	end
	return false
end

function SpiritObj:ChangeSpiritFazhen(res_id)
	if self.is_visible and nil ~= self.draw_obj then
		if not self.spirit_fazhen then
			self.spirit_fazhen = AsyncLoader.New(self.draw_obj:GetAttachPoint(AttachPoint.Mount))
		end
		if res_id and res_id ~= "" then
			local bundle, asset = ResPath.GetMiscEffect(res_id)
			local load_call_back = function(obj)
				if not self.is_visible then
					self:DeleteFaZhen()
					return
				end
				local go = U3DObject(obj)
				obj.transform:SetParent(self.draw_obj:GetAttachPoint(AttachPoint.Mount), false)
			end
			self.spirit_fazhen:Load(bundle, asset, load_call_back)
		else
			self:DeleteFaZhen()
		end
	else
		self:DeleteFaZhen()
	end
end

function SpiritObj:UpdateSpritLingZhu()
	if self.vo then
		self.lingzhu_res_id = LingZhuData.Instance:GetResIdByImageId(self.vo.lingzhu_use_imageid)
	end
end

--更新仙宠灵珠
function SpiritObj:ChangeSpritLingZhu()
	if self.lingzhu_res_id <= 0 or self.fight_state then
		self:RemoveModel(SceneObjPart.Halo)
		return
	end

	self:ChangeModel(SceneObjPart.Halo, ResPath.GetLingZhuModel(self.lingzhu_res_id))
end

function SpiritObj:DeleteFaZhen()
	if self.spirit_fazhen then
		self.spirit_fazhen:DeleteMe()
		self.spirit_fazhen = nil
	end
end

-- 角色是否战斗状态
function SpiritObj:SetFightState(state)
	self.fight_state = state
	self:ChangeSpritLingZhu()
end

function SpiritObj:ApperanceShieldChanged()
	if self:OwnerIsMainRole() then
		return
	end
	if self.draw_obj then
		for _, part in pairs (SpriteVisibleApperance) do
			local is_shield = SettingData.Instance:GetApperanceSetting(SpritePartApperanceSettingType[part])
			self.draw_obj:ShieldPart(part, is_shield)
		end
	end
end