Role = Role or BaseClass(Character)

function Role:__init(vo)
	self.obj_type = SceneObjType.Role
	self.draw_obj:SetObjType(self.obj_type)
	self.role_res_id = 0
	self.special_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.mount_res_id = 0
	self.fight_mount_res_id = 0
	self.halo_res_id = 0
	self.baoju_res_id = 0
	self.cloak_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0
	self.fazhen_res_id = ""
	self.is_gather_state = false
	self.attack_index = 1
	self.role_is_visible = true
	self.role_temp_visible = true
	self.goddess_obj = nil
	self.is_sit_mount = 0
	self.has_mount = false
	self.is_load_effect = false
	self.is_load_effect2 = false
	self.goddess_visible = true
	self.spirit_visible = true
	self.lingchong_visible = true
	self.super_baby_visible = true
	self.attack_index_shadow = 0
	self.role_last_logic_pos_x = 0
	self.role_last_logic_pos_y = 0
	self.next_create_footprint_time = -1 			-- 下一次生成足迹的时间
	self.foot_res_id = 0
	self.is_parnter = false
	self.is_chongci = false						-- 是否冲刺状态
	self.hug_res_id = 0
	self.mount_other_objid = 0x10000
	self:UpdateHoldBeauty()

	self:UpdateAppearance()
	self:UpdateMount()
	self:UpdateFightMount()

	self.shield_spirit_helo = true --暂时屏蔽光环
	self.is_enter_fight = false
end

function Role:__delete()
	local settingData = SettingData.Instance
	if self.setting_shield_others ~= nil then
		settingData:UnNotifySettingChangeCallBack(
			SETTING_TYPE.SHIELD_OTHERS,
			self.setting_shield_others)
		self.setting_shield_others = nil
	end

	if self.setting_shield_self_effect ~= nil then
		settingData:UnNotifySettingChangeCallBack(
			SETTING_TYPE.SELF_SKILL_EFFECT,
			self.setting_shield_self_effect)
		self.setting_shield_self_effect = nil
	end

	if self.setting_shield_other_effect ~= nil then
		settingData:UnNotifySettingChangeCallBack(
			SETTING_TYPE.SKILL_EFFECT,
			self.setting_shield_other_effect)
		self.setting_shield_other_effect = nil
	end

	if self.setting_close_shake_camera ~= nil then
		settingData:UnNotifySettingChangeCallBack(
			SETTING_TYPE.CLOSE_SHOCK_SCREEN,
			self.setting_close_shake_camera)
		self.setting_close_shake_camera = nil
	end

	if self.truck_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.TruckObj, self.truck_obj:GetObjKey())
		self.truck_obj = nil
	end

	if self.spirit_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpriteObj, self.spirit_obj:GetObjKey())
		self.spirit_obj = nil
	end

	if self.pet_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.PetObj, self.pet_obj:GetObjKey())
		self.pet_obj = nil
	end

	if self.goddess_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
		self.goddess_obj = nil
	end

	if self.lingchong_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.LingChongObj, self.lingchong_obj:GetObjKey())
		self.lingchong_obj = nil
	end

	if self.super_baby_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SuperBabyObj, self.super_baby_obj:GetObjKey())
		self.super_baby_obj = nil
	end

	if self.fight_mount_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FightMount, self.fight_mount_obj:GetObjKey())
		self.fight_mount_obj = nil
	end
	if self.load_mount_quest then
		GlobalTimerQuest:CancelQuest(self.load_mount_quest)
		self.load_mount_quest = nil
	end
	if self.load_fightmount_quest then
		GlobalTimerQuest:CancelQuest(self.load_fightmount_quest)
		self.load_fightmount_quest = nil
	end

	if nil ~= self.baoju_effect then
		self.baoju_effect:Destroy()
		self.baoju_effect:DeleteMe()
		self.baoju_effect = nil
	end

	if self.spirit_halo then
		self.spirit_halo:Destroy()
		self.spirit_halo:DeleteMe()
		self.spirit_halo = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.weapon_effect then
		GameObjectPool.Instance:Free(self.weapon_effect)
		self.weapon_effect = nil
	end
	if self.weapon2_effect then
		GameObjectPool.Instance:Free(self.weapon2_effect)
		self.weapon2_effect = nil
	end
	self.is_load_effect = nil
	self.is_load_effect2 = nil
	self.weapon2_effect_name = nil
	self.weapon_effect_name = nil

	GlobalTimerQuest:CancelQuest(self.do_mount_up_delay)
	self:DestroyXiaMaEffect()
	self:RemoveXiamaDelay()

	if self.shuijing_buff_chang then
		GlobalEventSystem:UnBind(self.shuijing_buff_chang)
		self.shuijing_buff_chang = nil
	end

	if self.dance_delay_time then
		GlobalTimerQuest:CancelQuest(self.dance_delay_time)
		self.dance_delay_time = nil
	end

	self.multi_mount_owner_role = nil
end

function Role:OnEnterScene()
	Character.OnEnterScene(self)
	self:GetFollowUi()
	self:CreateTitle()
	self:ChangeHuSong()
	self:ChangeJingHuaHuSong()
	self:ChangeGuildBattle()
	self:ChangeSpirit()
	self:ChangeLingChong()
	self:ChangeSuperBaby()
	self:ChangeGoddess()
	self:UpdateBoat()
	self:UpdateRoleFaZhen()
	self:ChangeFaZhen()
	self:InitWuDiGather()
	self:InitModelSize()
	self:InitXiuLuoWuDiGather()
	self:InitKFMiningGatherTitle()
	self:InitTianShenGraveTitle()
	self:UpdateGatherStatus()
	self:InitModelTransparent()

	if self.follow_ui then
		self.follow_ui:SetSpecialImage(false)
	end

	if self.draw_obj then
		self.draw_obj:SetWaterHeight(COMMON_CONSTS.WATER_HEIGHT)
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			local flag = scene_logic:IsCanCheckWaterArea() and true or false
			self.draw_obj:SetCheckWater(flag)
			if flag then
				self.draw_obj:SetEnterWaterCallBack(BindTool.Bind(self.EnterWater, self))
			end
		end
	end
end

Role.FootPrintCount = 0
function Role:CreateFootPrint()
	if not self:IsRoleVisible() or self:IsWaterWay() then return end
	if self.is_jump or self.draw_obj == nil or self.foot_res_id < 1 then return end

	if not self:IsMainRole() and Role.FootPrintCount > 8 then
		return
	end

	Role.FootPrintCount = Role.FootPrintCount + 1

	local pos = self.draw_obj:GetRoot().transform.position
	local bundle, asset = ResPath.GetFootModel(self.foot_res_id)
	EffectManager.Instance:PlayControlEffect(bundle, asset, Vector3(pos.x, pos.y + 0.25, pos.z), nil)
	GlobalTimerQuest:AddDelayTimer(function ()
		Role.FootPrintCount = Role.FootPrintCount - 1
	end, 1)
end

function Role:OnQualityChanged()
	SceneObj.OnQualityChanged(self)
	local pb_streamer = 1
	if QualityConfig.QualityLevel <= 1 then
		local scene_type = Scene.Instance.scene_config.scene_type
		local fb_scene_cfg_list = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto").fb_scene_cfg_list
		for k,v in pairs(fb_scene_cfg_list) do
			if v.scene_type == scene_type then
				pb_streamer = v.pb_streamer
				break
			end
		end
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if pb_streamer == 0 then
		main_part:SetMaterialIndex(1)
	else
		main_part:SetMaterialIndex(0)
	end
end

function Role:ChangeFollowUiName(name)
	if name then
		self.vo.name = name
	end
	self:ReloadUIName()
end

function Role:IsRole()
	return true
end

-- 是否隐身
function Role:IsModelTransparent()
	return self.vo and self.vo.is_invisible and self.vo.is_invisible > 0 or false
end

function Role:InitInfo()
	Character.InitInfo(self)

end

function Role:GetObjKey()
	return self.vo.role_id
end

function Role:InitShow()
	Character.InitShow(self)
	if self:IsMainRole() then
		self.load_priority = 5
	end

	if self.special_res_id ~= 0
		and SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.vo.special_appearance
		and (self.vo.bianshen_param == "" or self.vo.bianshen_param == 0) then

		self:ChangeModel(SceneObjPart.Main, ResPath.GetGeneralRes(self.special_res_id))
		return
	end

	-- 变身卡
	if self.special_res_id ~= 0 and SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD == self.vo.special_appearance then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.appearance_param]
		if monster_cfg then
			self.special_res_id = monster_cfg.resid
		end

		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	end

	if self.special_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:EnableMountUpTrigger(false)

	if self.role_res_id ~= nil and self.role_res_id ~= 0 then
		self:InitModel(ResPath.GetRoleModel(self.role_res_id))
	end

	if self.weapon_res_id ~= nil and self.weapon_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
	end

	if self.weapon2_res_id ~= nil and self.weapon2_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
	end

	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()

	if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id <= 0 then
		self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
	end

	if self.halo_res_id ~= nil and self.halo_res_id ~= 0 and fb_scene_cfg.pb_guanghuan ~= 1 then
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetHaloModel(self.halo_res_id))
	end

	if self.cloak_res_id ~= nil and self.cloak_res_id ~= 0 and fb_scene_cfg.pb_cloak ~= 1 then
		self:ChangeModel(SceneObjPart.Cloak, ResPath.GetPifengModel(self.cloak_res_id))
	end

	if self.fight_mount_res_id ~= nil and self.fight_mount_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
	elseif self.mount_res_id ~= nil and self.mount_res_id ~= 0 and not self:IsMultiMountPartner() then
		if self.is_sit_mount == 1 then
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.mount_res_id))
		else
			self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
		end
	end

	-- 人物法阵
	self:ChangeFaZhen()

	if self.baoju_res_id ~= nil and self.baoju_res_id ~= 0 and fb_scene_cfg.pb_zhibao ~= 1 then
		self:ChangeModel(SceneObjPart.BaoJu, ResPath.GetBaoJuModel(self.baoju_res_id))
	end

	if self:CanHug() then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
		self:DoHug()
	end

	self:CheckDanceState()
	self:ChangeYaoShi()
	self:ChangeTouShi()
	self:ChangeQilinBi()
	self:ChangeMask()

	self:ApperanceShieldChanged()

	self:InitModelTransparent()
end

function Role:InitModel(bundle, asset)
	if AssetManager.Manifest ~= nil and not AssetManager.IsVersionCached(bundle) then
		local default_res_id = nil
		if self.vo.sex == 0 then
			default_res_id = "100" .. PROF_ROLE[self.vo.prof] .. "001"
		else
			default_res_id = "110" .. PROF_ROLE[self.vo.prof] .. "001"
		end
		self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(default_res_id))

		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset)
			end
		end)
	else
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end

function Role:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)
	if self.role_last_logic_pos_x ~= self.logic_pos.x or self.role_last_logic_pos_y ~= self.logic_pos.y then
		self.role_last_logic_pos_x = self.logic_pos.x
		self.role_last_logic_pos_y = self.logic_pos.y

		if self.next_create_footprint_time == 0 then
			self:CreateFootPrint()
			self.next_create_footprint_time = Status.NowTime + COMMON_CONSTS.FOOTPRINT_CREATE_GAP_TIME
		end

		if self.next_create_footprint_time == -1 then --初生时也是位置改变，不播
			self.next_create_footprint_time = 0
		end
	end

	if self.next_create_footprint_time > 0 and now_time >= self.next_create_footprint_time then
		self.next_create_footprint_time = 0
	end
	self:UpdateMultiMountParnter(now_time, elapse_time)
end

function Role:EnterStateAttack()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if self.vo.task_appearn and self.vo.task_appearn > 0 then
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		self:StopHug()
	end
	local anim_name = SceneObjAnimator.Atk1
	local info_cfg = SkillData.GetSkillinfoConfig(self.attack_skill_id)
	if nil ~= info_cfg then
		anim_name = info_cfg.skill_action
		-- 机器人attack_index要特殊处理
		if self.vo.is_shadow == 1 then
			if info_cfg.hit_count > 1 then
				self.attack_index_shadow = self.attack_index_shadow + 1
				if self.attack_index_shadow > 3 then
					self.attack_index_shadow = 1
				end
				anim_name = anim_name.."_"..self.attack_index_shadow
			end
		else
			if info_cfg.hit_count > 1 then
				anim_name = anim_name.."_"..self.attack_index
			end
		end

		local play_speed = info_cfg.play_speed or 1
		if self.attack_skill_id == 5 then
			play_speed = ANGER_SKILL_PLAY_SPEED[self.vo.prof] or 1
		end

		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		main_part:SetFloat(anim_name.."_speed", play_speed)
	end
	Character.EnterStateAttack(self, anim_name)
end

function Role:GetRoleId()
	return self.vo.role_id
end

function Role:GetRoleResId()
	return self.role_res_id
end

function Role:GetRoleHead()
	return string.format("%3d", self.vo.prof)
end

function Role:GetWeaponResId()
	return self.weapon_res_id
end

function Role:GetWeapon2ResId()
	return self.weapon2_res_id
end

function Role:GetWingResId()
	return self.wing_res_id
end

function Role:GetCloakResId()
	return self.cloak_res_id
end

function Role:GetWaistResId()
	return self.waist_res_id
end

function Role:GetTouShiResId()
	return self.toushi_res_id
end

function Role:GetQilinBiResId()
	return self.qilinbi_res_id
end

function Role:GetMaskResId()
	return self.mask_res_id
end

function Role:GetMountResId()
	return self.mount_res_id
end

function Role:GetHaloResId()
	return self.halo_res_id
end

function Role:GetBaoJuResId()
	return self.baoju_res_id
end

function Role:SetAttackMode(attack_mode)
	self.vo.attack_mode = attack_mode
end

function Role:SetIsGatherState(is_gather_state, is_fishing, is_kf_mining)
	self.is_fishing = is_fishing
	self.is_kf_mining = is_kf_mining
	self.is_gather_state = is_gather_state
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)

	if is_gather_state then
		self:StopHug()
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.Fishing then
			--钓鱼特殊处理
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		elseif is_fishing then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.ShuaiGan)
		elseif is_kf_mining then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Mining)
		else
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		end
	else
		if self:IsStand() then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		end
		if self:CanHug() then
			main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			self:DoHug()
			local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
			if holdbeauty_part then
				holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			end
		end
	end
	if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 and nil == self.do_mount_up_delay then
		self.do_mount_up_delay = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnMountUpEnd,self), 0.1)
	end
	self:EquipDataChangeListen()
end

function Role:GetIsGatherState()
	return self.is_gather_state
end

function Role:OnRealive()
	self:InitShow()
	self:ChangeSpirit()
	self:ChangeGoddess()
	self:OnFightMountUpEnd()
end

function Role:OnDie()
	self:RemoveModel(SceneObjPart.Weapon)
	self:RemoveModel(SceneObjPart.Weapon2)
	self:RemoveModel(SceneObjPart.Wing)
	self:RemoveModel(SceneObjPart.Halo)
	self:RemoveModel(SceneObjPart.BaoJu)
	self:RemoveModel(SceneObjPart.FightMount)
	if self.spirit_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpriteObj, self.spirit_obj:GetObjKey())
		self.spirit_obj = nil
	end

	if self.goddess_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
		self.goddess_obj = nil
	end

	if self.pet_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.PetObj, self.pet_obj:GetObjKey())
		self.pet_obj = nil
	end
end

function Role:RemoveSomeModel()
	--先清除一些部位
	for _, v in pairs(SceneObjPart) do
		if v ~= SceneObjPart.Shadow
			and v ~= SceneObjPart.Main
			and v ~= SceneObjPart.Particle then
			self:RemoveModel(v)
		end
	end
end

function Role:SetAttr(key, value)
	Character.SetAttr(self, key, value)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local main_role = Scene.Instance:GetMainRole()
	if key == "prof" or key == "appearance" or key == "special_appearance" or key == "bianshen_param" then
		--先清除一些模型
		self:RemoveSomeModel()

		self:UpdateAppearance()
		self:UpdateBaoJu()
		self:UpdateMount()
		self:UpdateRoleFaZhen()
		self:CheckDanceState()
		if self.vo.use_xiannv_id ~= nil and self.vo.use_xiannv_id > -1 then
			self:ChangeGoddess()
		end
		if self:CheckIsGeneral() then
			return
		end
		if self.special_res_id ~= 0 and (self.mount_res_id == 0 or self.mount_res_id == "") then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
			return
		end
		-- 变身卡
		if self.special_res_id ~= 0 and self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
			return
		end
		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if self.role_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res_id))
		end

		if self.weapon_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
		end

		if self.weapon2_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
		end

		if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id <= 0 then
			self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
		else
			self:RemoveModel(SceneObjPart.Wing)
		end

		if self.halo_res_id ~= nil and self.halo_res_id ~= 0 and fb_scene_cfg.pb_guanghuan ~= 1 then
			self:ChangeModel(SceneObjPart.Halo, ResPath.GetHaloModel(self.halo_res_id))
		else
			self:RemoveModel(SceneObjPart.Halo)
		end

		if self.baoju_res_id ~= nil and self.baoju_res_id ~= 0 and fb_scene_cfg.pb_zhibao ~= 1 then
			self:ChangeModel(SceneObjPart.BaoJu, ResPath.GetBaoJuModel(self.baoju_res_id))
		else
			self:RemoveModel(SceneObjPart.BaoJu)
		end

		if self.fight_mount_res_id ~= nil and self.fight_mount_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
		elseif self.mount_res_id ~= nil and self.mount_res_id ~= 0 and not self:IsMultiMountPartner() then
			if self.is_sit_mount == 1 then
				self:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.mount_res_id))
			else
				self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
			end
		end

		self:ChangeFaZhen()
		self:ChangeSpiritHalo()
		self:ChangeSpiritFazhen()
		self:ChangeYaoShi()
		self:ChangeTouShi()
		self:ChangeQilinBi()
		self:ChangeMask()
		self:ChangeCloak()
	elseif key == "mount_appeid" then
		self:UpdateMount()
		if main_part then
			if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 then
				self.has_mount = true
			else
				if self.vo.move_mode ~= MOVE_MODE.MOVE_MODE_JUMP2 then
					if self.has_mount then
						self.has_mount = false
					end
				end
			end
			main_part:EnableMountUpTrigger(false) --nil ~= main_part:GetObj() and main_role and not main_role:IsFightState()
			self:OnMountUpEnd()
		end

	elseif key == "fight_mount_appeid" then
		self:UpdateFightMount()
		main_part:EnableMountUpTrigger(false)
		if main_part then
			if nil ~= self.fight_mount_res_id and self.fight_mount_res_id ~= "" and self.fight_mount_res_id > 0 then
				if main_part:GetObj() and main_part:GetObj().animator then
					main_part:GetObj().animator:SetLayerWeight(3, 1.0)
				end
				self.has_mount = true
			else
				if self.vo.move_mode ~= MOVE_MODE.MOVE_MODE_JUMP2 then
					if self.has_mount then
						self.has_mount = false
					end
				end
			end

			self:OnFightMountUpEnd()
		end
	elseif key == "used_title_list" then
		self:UpdateTitle()
		if nil ~= self.spirit_obj then
			self.spirit_obj:UpdateSpiritTitle()
		end
	elseif key == "husong_taskid" or key == "husong_color" then
		self:ChangeHuSong()
	elseif	key == "jinghua_husong_status" or key == "jinghua_husong_type" then
		self:ChangeJingHuaHuSong()
	elseif key == "hp" or key == "max_hp" then
		if ScoietyData.Instance.have_team then
			ScoietyData.Instance:ChangeTeamList(self.vo)
			GlobalEventSystem:Fire(ObjectEventType.TEAM_HP_CHANGE, self.vo)
		end
		if self:IsMainRole() then
			self:SyncShowHp()
		end
	elseif key == "special_param" then
		self:ChangeGuildBattle()
		self:ChangeFollowUiName()
		self:UpdateBoat()
	elseif key == "task_appearn" then
		self:UpdateHoldBeauty()
		local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
		if self:CanHug() then
			self:UpdateMount()
			self:OnMountUpEnd()
			self:UpdateFightMount()
			self:OnFightMountUpEnd()
			self:DoHug()
			if main_part then
				main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			end
			if holdbeauty_part then
				holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			end
		else
			self:StopHug()
			if main_part then
				main_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
			end
		end
	elseif key == "used_sprite_id" or key == "sprite_name" or key == "user_pet_special_img" then
		self:ChangeSpirit()
	elseif key == "use_jingling_titleid" then
		if self.spirit_obj then
			self.spirit_obj:SetAttr(key, value)
		end
	elseif key == "use_xiannv_id" or key == "xiannv_huanhua_id" then
		self:ChangeGoddess()
	elseif key == "use_pet_id"then
		self:ChangePet()
	elseif key == "xiannv_name" then
		local goddess_obj = self:GetGoddessObj()
		if goddess_obj then
			goddess_obj:SetAttr("name", value)
			goddess_obj:GetFollowUi()
		end
	elseif key == "millionare_type" then
		if self.vo.millionare_type and self.vo.millionare_type > 0 then
			self:GetFollowUi():SetDaFuHaoIconState(true)
		else
			self:GetFollowUi():SetDaFuHaoIconState(false)
		end
	elseif key == "guild_name" then
		self:ReloadUIGuildName()
		self:UpdateTitle()
	elseif key == "touxian" then
		if self.follow_ui then
			self.follow_ui:SetLongXingIcon(self)
		end
	elseif key == "lover_name" then
		self:ReloadUILoverName()
		self:UpdateTitle()
	elseif key == "wuqi_color" then
		self:EquipDataChangeListen()
	elseif key == "name_color" then
		self:ChangeFollowUiName()
	elseif key == "top_dps_flag" then
		self:ReloadSpecialImage()
	elseif key == "vip_level" then
		if self.follow_ui then
			self.follow_ui:SetVipIcon(self)
		end
	elseif key == "halo_lover_uid" then
		local role_id = self.vo.role_id
		if value > 0 then
			local lover_obj = Scene.Instance:GetObjByUId(value)
			if lover_obj then
				local lover_role_id = value
				local halo_type = self:GetAttr("halo_type")
				Scene.Instance:CreateCoupleHaloObj(role_id, lover_role_id, halo_type)
			end
		else
			Scene.Instance:DeleteCoupleHaloObj(role_id)
		end
	elseif key == "combine_server_equip_active_special" then
		self:UpdateTitle()
	elseif key == "baojia_image_id" then
		if value ~= nil then
			self.vo.baojia_use_image_id = value or 0
		end
	elseif key == "lingzhu_use_imageid" then
		if self.spirit_obj then
			self.spirit_obj:SetAttr(key, value)
		end
	elseif key == "lingchong_used_imageid" or key == "linggong_used_imageid" or key == "lingqi_used_imageid" then
		self:ChangeLingChong()
	elseif key == "sup_baby_id" or key == "sup_baby_name" then
		self:ChangeSuperBaby()
	end
end

--怀抱中的资源id
function Role:UpdateHoldBeauty()
	self.hug_res_id = 0
	local obj_cfg = nil
	if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER then
		obj_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.task_appearn_param_1]
	elseif self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
		obj_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.vo.task_appearn_param_1]
	end
	if obj_cfg and obj_cfg.resid and obj_cfg.resid ~= "" and obj_cfg.resid > 0 then
		self.hug_res_id = obj_cfg.resid
	end
end

--根据type, index获取服装的配置
function Role:GetFashionConfig(fashion_cfg_list, part_type, index)
	for k, v in pairs(fashion_cfg_list) do
		if v.part_type == part_type and index == v.index then
			return v
		end
	end
	return nil
end

function Role:OnMountUpEnd()
	self.do_mount_up_delay = nil
	if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 and not self:IsMultiMountPartner() then
		self:RemoveModel(SceneObjPart.FightMount)
		self:RemoveModel(SceneObjPart.FaZhen)
		if self.is_sit_mount == 1 then
			self:RemoveModel(SceneObjPart.Mount)
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.mount_res_id))
		else
			if self.is_gather_state then
				self:RemoveModel(SceneObjPart.Mount)
			else
				self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
				self.show_fade_in = true
			end
		end
		if self.role_res_id ~= 0 and
			self.vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res_id))
		end
	else
		if self:CheckIsGeneral() then
			return
		end

		if self.special_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
			self:RemoveModel(SceneObjPart.Weapon)
			self:RemoveModel(SceneObjPart.Weapon2)
			self:RemoveModel(SceneObjPart.Wing)
			self:RemoveModel(SceneObjPart.Halo)
		end
		if self.is_sit_mount == 1 then
			self:RemoveModel(SceneObjPart.FightMount)
			self.is_sit_mount = 0
		else
			self:RemoveMonutWithFade()
		end

		self:ChangeFaZhen()
	end
	self:CheckDanceState()
end

function Role:OnBeHit(real_blood, deliverer, skill_id)
	if real_blood >= 0 or self.vo.hp <= 0 then
		return
	end
	if self:IsMainRole() and deliverer and deliverer:GetType() == SceneObjType.Role and deliverer.vo.is_shadow == 0 then
		MainUICtrl.Instance:SetBeAttackedIcon(deliverer.vo)
	end
end

function Role:OnFightMountUpEnd()
	if nil ~= self.fight_mount_res_id and self.fight_mount_res_id ~= "" and self.fight_mount_res_id > 0 then
		self:RemoveModel(SceneObjPart.Mount)
		self:RemoveModel(SceneObjPart.FaZhen)
		self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))

		if self.role_res_id ~= 0 and
			self.vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res_id))
		end
	else
		if self:CheckIsGeneral() then
			return
		end
		if self.special_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
			self:RemoveModel(SceneObjPart.Weapon)
			self:RemoveModel(SceneObjPart.Weapon2)
			self:RemoveModel(SceneObjPart.Wing)
			self:RemoveModel(SceneObjPart.Halo)
		end
		self:RemoveModel(SceneObjPart.FightMount)

		self:ChangeFaZhen()
	end

	self:CheckDanceState()
end

function Role:UpdateWingResId()
	local index = self.vo.appearance.wing_used_imageid or 0
	local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.wing_res_id = 0
	if wing_config and fb_scene_cfg.pb_wing ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = wing_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = wing_config.image_list[index]
		end
		if image_cfg then
			self.wing_res_id = image_cfg.res_id
		end
	end
end

function Role:UpdateCloakResId()
	local index = self.vo.appearance.cloak_used_imageid or 0
	local cloak_config = ConfigManager.Instance:GetAutoConfig("cloak_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.cloak_res_id = 0
	if cloak_config and fb_scene_cfg.pb_cloak ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = cloak_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = cloak_config.image_list[index]
		end
		if image_cfg then
			self.cloak_res_id = image_cfg.res_id
		end
	end
end

function Role:UpdateFootResId()
	local index = self.vo.appearance.footprint_used_imageid or 0
	local foot_config = ConfigManager.Instance:GetAutoConfig("footprint_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.foot_res_id = 0
	if foot_config and fb_scene_cfg.pb_foot ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = foot_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = foot_config.image_list[index]
		end
		if image_cfg then
			self.foot_res_id = image_cfg.res_id
		end
	end
end

function Role:UpdateHaloResId()
	local index = self.vo.appearance.halo_used_imageid or 0
	local halo_config = ConfigManager.Instance:GetAutoConfig("halo_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.halo_res_id = 0
	if halo_config and fb_scene_cfg.pb_guanghuan ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[index]
		end
		if image_cfg then
			self.halo_res_id = image_cfg.res_id
		end
	end
end

function Role:UpdateAppearance()
	local vo = self.vo
	local prof = vo.prof
	local sex = vo.sex
	--清空缓存
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.foot_res_id = 0
	self.special_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0
	-- 先查找时装的武器和衣服
	if vo.appearance ~= nil then
		local fashion_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
		if vo.appearance.fashion_wuqi ~= 0 then
			local wuqi_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.WUQI, vo.appearance.fashion_wuqi)
			if wuqi_cfg then
				local cfg = wuqi_cfg["resouce" .. prof .. sex]
				if type(cfg) == "string" then
					local temp_table = Split(cfg, ",")
					if temp_table then
						self.weapon_res_id = temp_table[1]
						self.weapon2_res_id = temp_table[2]
					end
				elseif type(cfg) == "number" then
					self.weapon_res_id = cfg
				end
			end
		end
		if vo.appearance.fashion_body ~= 0 then
			local clothing_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.BODY, vo.appearance.fashion_body)
			if clothing_cfg then
				local index = string.format("resouce%s%s", prof, sex)
				local res_id = clothing_cfg[index]
				self.role_res_id = res_id
			end
		end


		if vo.appearance.shenbing_image_id ~= nil and vo.appearance.shenbing_image_id > 0 then
			local res_id = ShenqiData.Instance:GetResCfgByIamgeID(vo.appearance.shenbing_image_id, vo)
			if nil ~= res_id then
				self.weapon_res_id = res_id
			end
		end


		if nil ~= vo.appearance.baojia_image_id and vo.appearance.baojia_image_id > 0 then
			local res_id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(vo.appearance.baojia_image_id, vo)
			if nil ~= res_id then
				self.role_res_id = res_id
			end
		end

		--腰饰
		if vo.appearance.yaoshi_used_imageid and vo.appearance.yaoshi_used_imageid > 0 then
			self.waist_res_id = WaistData.Instance:GetResIdByImageId(vo.appearance.yaoshi_used_imageid)
		end

		--头饰
		if vo.appearance.toushi_used_imageid and vo.appearance.toushi_used_imageid > 0 then
			self.toushi_res_id = TouShiData.Instance:GetResIdByImageId(vo.appearance.toushi_used_imageid)
		end

		--麒麟臂
		if vo.appearance.qilinbi_used_imageid and vo.appearance.qilinbi_used_imageid > 0 then
			self.qilinbi_res_id = QilinBiData.Instance:GetResIdByImageId(vo.appearance.qilinbi_used_imageid, sex)
		end

		--面饰
		if vo.appearance.mask_used_imageid and vo.appearance.mask_used_imageid > 0 then
			self.mask_res_id = MaskData.Instance:GetResIdByImageId(vo.appearance.mask_used_imageid)
		end

		self:UpdateWingResId()
		self:UpdateCloakResId()
		self:UpdateHaloResId()
		self:UpdateFootResId()
		self:UpdateBaoJu()
		self:UpdateHead()
	end

	-- 最后查找职业表
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[vo.prof]
	if role_job ~= nil then
		if self.role_res_id == 0 then
			self.role_res_id = role_job["model" .. vo.sex]
		end

		if self.weapon_res_id == 0 then
			-- 武器颜色为红色时，使用特殊的模型
			if self.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
				self.weapon_res_id = role_job["right_red_weapon" .. vo.sex]
			else
				self.weapon_res_id = role_job["right_weapon" .. vo.sex]
			end
		end

		if self.weapon2_res_id == 0 then
			if self.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
				self.weapon2_res_id = role_job["left_red_weapon" .. vo.sex]
			else
				self.weapon2_res_id = role_job["left_weapon" .. vo.sex]
			end
		end
	else
		if self.role_res_id == 0 then
			self.role_res_id = 1001001
		end

		if self.weapon_res_id == 0 then
			self.weapon_res_id = 900100101
		end
	end

	if self.is_fishing then
		self.weapon_res_id = 10050101
		self.weapon2_res_id = 0
	end
	if self.vo.bianshen_param ~= "" and self.vo.bianshen_param ~= 0 then
		if self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_MOJIE_GUAIWU then
			self.special_res_id = 2007001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOTU then
			self.special_res_id = 3002001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOZHU then
			self.special_res_id = 3003001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_YIZHANDAODI then 		-- 一战到底小树人
			self.special_res_id = 2007001
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD == self.vo.special_appearance then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.appearance_param]
		if monster_cfg then
			self.special_res_id = monster_cfg.resid
		end
		self.weapon_res_id = 0
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR == self.vo.special_appearance then
		self.special_res_id = ClashTerritoryData.Instance:GetMonsterResId(self.vo.appearance_param, self.vo.guild_id)
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_HUASHENG == self.vo.special_appearance then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.vo.appearance_param]
		if monster_cfg then
			self.special_res_id = monster_cfg.resid
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_CROSS_HOTSPRING == self.vo.special_appearance then
		if sex == 1 then
			self.special_res_id = 3022001
		else
			self.special_res_id = 3023001
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_CROSS_MINING == self.vo.special_appearance then
		if sex == 1 then
			self.special_res_id = 3047001
		else
			self.special_res_id = 3048001
		end
		self.weapon_res_id = 0
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.vo.special_appearance then
		self.special_res_id = self.vo.appearance_param
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CROSS_FISHING == self.vo.special_appearance then
		local fishing_other_cfg = CrossFishingData.Instance:GetFishingOtherCfg()
		self.special_res_id = fishing_other_cfg["resource_id_" .. sex] or self.role_res_id
		self.weapon_res_id = 0
	end
end

function Role:UpdateMount()
	local vo = self.vo
	self.mount_res_id = 0
	if self.vo.multi_mount_res_id > 0 then
		self.mount_res_id = self.vo.multi_mount_res_id
		return
	end
	local image_cfg = nil
	if nil ~= vo.mount_appeid and vo.mount_appeid > 0 and self.special_res_id == 0 then
		if self.vo.mount_appeid > 1000 then
			image_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img[self.vo.mount_appeid - 1000]
		else
			image_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").image_list[self.vo.mount_appeid]
		end
	end

	if nil ~= image_cfg and not self:CanHug() then
		self.mount_res_id = image_cfg.res_id
		self.is_sit_mount = image_cfg.is_sit
	end
	if self:CheckIsGeneral() then
		self.mount_res_id = 0
	end
end

function Role:UpdateFightMount()
	local vo = self.vo
	self.fight_mount_res_id = 0
	local image_cfg = nil
	if nil ~= vo.fight_mount_appeid and vo.fight_mount_appeid > 0 then
		if self.vo.fight_mount_appeid > 1000 then
			image_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img[self.vo.fight_mount_appeid - 1000]
		else
			image_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").image_list[self.vo.fight_mount_appeid]
		end
	end

	if nil ~= image_cfg and not self:CanHug() then
		self.fight_mount_res_id = image_cfg.res_id
	end
	if self:CheckIsGeneral() then
		self.fight_mount_res_id = 0
	end
end

function Role:UpdateBaoJu()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.appearance.zhibao_used_imageid and self.vo.appearance.zhibao_used_imageid > 0 and fb_scene_cfg.pb_zhibao ~= 1 then
		if self.vo.appearance.zhibao_used_imageid < 1000 and ZhiBaoData.Instance then  -- 大于1000特殊形象
			self.baoju_res_id = ZhiBaoData.Instance:GetZhiBaoXingX(self.vo.appearance.zhibao_used_imageid)
			-- if self.baoju_res_id > 13014 then
			-- 	self.baoju_res_id = 13014
			-- end
		else
			if ZhiBaoData.Instance then
				self.baoju_res_id = ZhiBaoData.Instance:GetSpecialResId(self.vo.appearance.zhibao_used_imageid - 1000)
			end
			-- if self.baoju_res_id > 13014 then
				-- self.baoju_res_id = 13014
			-- end
		end
	end
end

function Role:UpdateHead()

	if SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_SHNEQI == self.vo.special_appearance then
		if self.vo.appearance_param ~= nil and self.vo.appearance_param > 0 then
			local head_id = ShenqiData.Instance:GetHeadResId(self.vo.appearance_param)
			if head_id ~= nil then
				self:ChangeModel(SceneObjPart.Head, ResPath.GetHeadModel(head_id))
			end
		end
	else
		self:RemoveModel(SceneObjPart.Head)
	end
end

function Role:ChangeYaoShi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_yaoshi == 1 or self.special_res_id > 0 or self.waist_res_id <= 0 or self.is_enter_fight then
		self:RemoveModel(SceneObjPart.Waist)
		return
	end

	self:ChangeModel(SceneObjPart.Waist, ResPath.GetWaistModel(self.waist_res_id))
end

function Role:ChangeTouShi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_toushi == 1 or self.special_res_id > 0 or self.toushi_res_id <= 0 or self.is_enter_fight then
		self:RemoveModel(SceneObjPart.TouShi)
		return
	end

	self:ChangeModel(SceneObjPart.TouShi, ResPath.GetTouShiModel(self.toushi_res_id))
end

function Role:ChangeQilinBi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_qilinbi == 1 or self.special_res_id > 0 or nil == self.vo or self.qilinbi_res_id <= 0 then
		self:RemoveModel(SceneObjPart.QilinBi)
		return
	end

	self:ChangeModel(SceneObjPart.QilinBi, ResPath.GetQilinBiModel(self.qilinbi_res_id, self.vo.sex))
end

function Role:ChangeMask()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_mask == 1 or self.special_res_id > 0 or nil == self.vo or self.mask_res_id <= 0 or self.is_enter_fight then
		self:RemoveModel(SceneObjPart.Mask)
		return
	end

	self:ChangeModel(SceneObjPart.Mask, ResPath.GetMaskModel(self.mask_res_id))
end

function Role:ChangeCloak()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.cloak_res_id == nil or self.cloak_res_id <= 0 or fb_scene_cfg.pb_cloak == 1 or nil == self.vo or self.is_enter_fight then
		self:RemoveModel(SceneObjPart.Cloak)
		return
	end

	self:ChangeModel(SceneObjPart.Cloak, ResPath.GetPifengModel(self.cloak_res_id))
end

-- 创建温泉皮艇
function Role:UpdateBoat()
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then --温泉场景
		local special_param = self.vo.special_param
		if self:IsMainRole() then
			special_param = HotStringChatData.Instance:GetpartnerObjId()
		end
		if special_param >= 0 and special_param < 65535 then
			local obj = Scene.Instance:GetObjectByObjId(special_param)
			if obj and obj:IsMainRole() then
				Scene.Instance:CreateBoatByCouple(self:GetObjId(), special_param, obj, HOTSPRING_ACTION_TYPE.SHUANG_XIU)
			else
				Scene.Instance:CreateBoatByCouple(self:GetObjId(), special_param, self, HOTSPRING_ACTION_TYPE.SHUANG_XIU)
			end
		else
			Scene.Instance:DeleteBoatByRole(self:GetObjId())
		end
	end
end

function Role:CreateTitle()
	self:UpdateTitle()
end

function Role:UpdateTitle()
	if nil == self:GetFollowUi() then return end
	self:GetFollowUi():CreateTitleEffect(self.vo)
	-- self.title_layer:SetTitleListOffsetY(self.model:GetHeight())
	self:InspectTitleLayerIsShow()
end

function Role:IsRoleVisible()
	return self.role_is_visible
end

function Role:SetRoleVisible(is_visible)
	self.role_temp_visible = is_visible
	self.role_is_visible = is_visible and not self:IsModelTransparent()
	self:SetTitleVisible(self.role_is_visible)
	self:SetGoddessVisible(self.role_is_visible)
	self:SetSpriteVisible(self.role_is_visible)
	self:SetLingChongVisible(self.role_is_visible)
	self:SetSuperBabyVisible(self.role_is_visible)

	if self.follow_ui then
		self.follow_ui:SetIsShowGuildIcon(self.role_is_visible)
	end

	if not self.role_is_visible then
		self:GetOrAddSimpleShadow()
	end
	if self.simple_shadow ~= nil then
		if self.role_is_visible then
			self.simple_shadow.enabled = false
		else
			self.simple_shadow.enabled = true
		end
	end

	if self.role_is_visible and self:IsMultiMountPartner() then
		local main_part = self.draw_obj:_TryGetPartObj(SceneObjPart.Main)
		if main_part then
			main_part.animator:SetLayerWeight(2, 1.0)
			main_part.animator:SetLayerWeight(3, 0)
		end
	end
end

function Role:SetGoddessVisible(is_visible)
	local flag = not SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_GODDESS) and is_visible
	self.goddess_visible = flag and self.role_is_visible
	if self.goddess_visible then
		self:ChangeGoddess()
	end

	local goddess_obj = self:GetGoddessObj()
	if goddess_obj then
		goddess_obj:SetGoddessVisible(self.goddess_visible)
	end
end

function Role:SetSpriteVisible(is_visible)
	local flag = not SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SPIRIT) and is_visible
	self.spirit_visible = flag and self.role_is_visible
	if self.spirit_visible then
		self:ChangeSpirit()
	end

	if self.spirit_obj then
		self.spirit_obj:SetSpiritVisible(self.spirit_visible)
	end
end

function Role:SetLingChongVisible(is_visible)
	self.lingchong_visible = is_visible and self.role_is_visible
	if self.lingchong_visible then
		self:ChangeLingChong()
	end

	if self.lingchong_obj then
		self.lingchong_obj:ChangeVisible(self.lingchong_visible)
	end
end

function Role:SetSuperBabyVisible(is_visible)
	self.super_baby_visible = is_visible and self.role_is_visible
	if self.super_baby_visible then
		self:ChangeSuperBaby()
	end

	if self.super_baby_obj then
		self.super_baby_obj:ChangeVisible(self.super_baby_visible)
	end
end

function Role:SetTitleVisible(is_visible)
	-- if nil == self.title_layer then return end
	self:InspectTitleLayerIsShow(is_visible)
end

function Role:InspectTitleLayerIsShow(is_visible)
	local flag = true
	if nil ~= is_visible then flag = is_visible end

	if SettingData.Instance then
		flag = not SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_TITLE)
	end

	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_chenhao and fb_scene_cfg.pb_chenhao == 1 or BossData.IsBossScene() then
		flag = false
	end

	-- if SceneType.XianMengzhan == Scene.Instance:GetSceneType()
	-- or SceneType.HunYanFb == Scene.Instance:GetSceneType()
	-- or SceneType.Field1v1 == Scene.Instance:GetSceneType() then
	-- 	flag = false
	-- elseif self.vo.husong_taskid > 0 or self.vo.jilian_type > 0 or self.special_res_id ~= 0 then
	-- 	flag = false
	-- elseif self.vo.jinghua_husong_status > 0 then
	-- 	flag = false
	-- end

	if not self.role_is_visible then
		flag = false
	end
	self:GetFollowUi():SetTitleVisible(flag)
end

function Role:ChangeHuSong()
	if self:CheckIsHuSong() then
		if self:IsMainRole() then
			MainUICtrl.Instance:ShowHuSongButton(true)
			MountCtrl.Instance:SendGoonMountReq(0)
			FightMountCtrl.Instance:SendGoonFightMountReq(0)
		end
		if not self.truck_obj then
			self.truck_obj = Scene.Instance:CreateTruckObjByRole(self)
		end
		local str = "hu_" .. self.vo.husong_color
		self:GetFollowUi():ChangeSpecailTitle(str)
		-- 屏蔽女神和精灵
		self:SetGoddessVisible(false)
		self:SetSpriteVisible(false)
		self:SetLingChongVisible(false)
		self:SetSuperBabyVisible(false)
	else
		if self:IsMainRole() then
			MainUICtrl.Instance:ShowHuSongButton(false)
		end
		if self.truck_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.TruckObj, self.truck_obj:GetObjKey())
			self.truck_obj = nil
		end

		if self:CheckCanCancelSpecailTitle() then 							-- 检查是否能去掉特殊标志
			self:GetFollowUi():ChangeSpecailTitle(nil)
		end
		-- 还原女神和精灵
		self:SetGoddessVisible(true)
		self:SetSpriteVisible(true)
		self:SetLingChongVisible(true)
		self:SetSuperBabyVisible(true)
	end
end

--更改精华护送时候的护送图标
function Role:ChangeJingHuaHuSong()
	-- 判断是否处于护送状态
	if self.vo.jinghua_husong_status and self.vo.jinghua_husong_status ~= JH_HUSONG_STATUS.NONE and self.vo.jinghua_husong_type and self.vo.jinghua_husong_type ~= JingHuaHuSongData.JingHuaType.None then
		local str = "jinghua_husong_" .. self.vo.jinghua_husong_status .. "_" .. self.vo.jinghua_husong_type		-- jinghua_husong_status(1为Full，2为lost)  jinghua_husong_type(0为Big,1为Small)
		self:GetFollowUi():ChangeSpecailTitle(str)							-- 显示护送图标到称号位置
		--判断是否为当前玩家角色
		if self:IsMainRole() then
			MainUICtrl.Instance:ShowJingHuaHuSongButton(true)				-- 显示主界面继续护送按钮
			MountCtrl.Instance:SendGoonMountReq(0)							-- 禁止使用坐骑
			FightMountCtrl.Instance:SendGoonFightMountReq(0)				-- 禁止使用战斗坐骑
		end
	else
		if self:CheckCanCancelSpecailTitle() then 							-- 检查是否能去掉特殊标志
			self:GetFollowUi():ChangeSpecailTitle(nil)
		end
		if self:IsMainRole() then
			MainUICtrl.Instance:ShowJingHuaHuSongButton(false)
		end
	end
end
--检查是否能去掉护送的特殊标志
function Role:CheckCanCancelSpecailTitle()
	if self:CheckIsHuSong() then 									--是否是护送仙女中
		return false
	end
	if self.vo.jinghua_husong_status ~= JH_HUSONG_STATUS.NONE then 	--是否是护送灵石中
		return false
	end
	return true
end

--初始化无敌采集称号
function Role:InitWuDiGather()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.ShuiJing then
			if not self:CheckShuijingBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
			 	return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		end
	end
end

--改变无敌采集称号
function Role:ChangeWuDiGather(shuijing_buff)
	if not self:CheckShuijingBuff(shuijing_buff) then
		self:GetFollowUi():ChangeSpecailTitle(nil)
		return
	end
	local str = "wudi_gather"
	self:GetFollowUi():ChangeSpecailTitle(str)
end

--检测是否有水晶buff
function Role:CheckShuijingBuff(shuijing_buff)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id ~= FUBEN_SCENE_ID.SHUIJING then
	 	return false
	end

	if shuijing_buff ~= nil then
		return shuijing_buff == 1
	end

	if self:IsMainRole() then
		local crystal_info = CrossCrystalData.Instance:GetCrystalInfo()
		return crystal_info.gather_buff_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

--初始化跨服修罗塔无敌采集称号
function Role:InitXiuLuoWuDiGather()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.Kf_XiuLuoTower then
			if not self:CheckXiuLuoBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
			 	return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		end
	end
end

--改变跨服修罗塔无敌采集称号
function Role:ChangeXiuLuoWuDiGather(shuijing_buff)
	if not self:CheckXiuLuoBuff(shuijing_buff) then
		self:GetFollowUi():ChangeSpecailTitle(nil)
		return
	end
	local str = "wudi_gather"
	self:GetFollowUi():ChangeSpecailTitle(str)
end

--检测是否有跨服修罗塔buff
function Role:CheckXiuLuoBuff(shuijing_buff)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.Kf_XiuLuoTower then
	 	return false
	end

	if shuijing_buff ~= nil then
		return shuijing_buff == 1
	end

	if self:IsMainRole() then
		local gather_buff_time =  KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
		return gather_buff_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

--初始化跨服挖矿无敌采集称号
function Role:InitKFMiningGatherTitle()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.KfMining then
			if not self:CheckKuaFuMiningBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
			 	return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		end
	end
end

--改变跨服挖矿无敌采集称号
function Role:ChangeKuaFuMiningWuDiGather(shuijing_buff)
	if not self:CheckKuaFuMiningBuff(shuijing_buff) then
		self:GetFollowUi():ChangeSpecailTitle(nil)
		return
	end
	local str = "wudi_gather"
	self:GetFollowUi():ChangeSpecailTitle(str)
end

--检测是否有挖矿无敌采集buff
function Role:CheckKuaFuMiningBuff(shuijing_buff)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.KfMining then
	 	return false
	end

	if shuijing_buff ~= nil then
		return shuijing_buff == 1
	end

	if self:IsMainRole() then
		local gather_buff_time =  KuaFuMiningData.Instance:GetGatherBuffEndTime() or 0
		return gather_buff_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

--初始化跨服挖矿无敌采集称号
function Role:InitTianShenGraveTitle()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.CrossShuijing then
			if not self:CheckTianShenGraveBuff() then
				self:GetFollowUi():ChangeSpecailTitle(nil)
			 	return
			end
			local str = "wudi_gather"
			self:GetFollowUi():ChangeSpecailTitle(str)
		end
	end
end

--改变跨服挖矿无敌采集称号
function Role:ChangeTianShenGraveWuDiGather(shuijing_buff)
	if not self:CheckTianShenGraveBuff(shuijing_buff) then
		self:GetFollowUi():ChangeSpecailTitle(nil)
		return
	end
	local str = "wudi_gather"
	self:GetFollowUi():ChangeSpecailTitle(str)
end

--检测是否有挖矿无敌采集buff
function Role:CheckTianShenGraveBuff(shuijing_buff)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.CrossShuijing then
	 	return false
	end

	if shuijing_buff ~= nil then
		return shuijing_buff == 1
	end

	if self:IsMainRole() then
		local gather_buff_time =  TianShenGraveData.Instance:GetGatherBuffEndTime() or 0
		return gather_buff_time > TimeCtrl.Instance:GetServerTime()
	else
		return self.vo.special_param == 1
	end
	return true
end

function Role:ChangeSpirit()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local call_back = function()
		self:ChangeSpiritHalo()
		self:ChangeSpiritFazhen()
	end
	if self.vo.used_sprite_id and self.vo.used_sprite_id > 0 and fb_scene_cfg.pb_jingling ~= 1 and self.spirit_visible then
		if not self.spirit_obj then
			self.spirit_obj = Scene.Instance:CreateSpiritObjByRole(self)
			self.spirit_obj:SetLoadCallBack(call_back)
		else
			local spirit_cfg = nil
			if nil ~= self.vo.user_pet_special_img and self.vo.user_pet_special_img >= 0 then
				spirit_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(self.vo.user_pet_special_img)
			else
				spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.vo.used_sprite_id)
			end

			if spirit_cfg and spirit_cfg.res_id and spirit_cfg.res_id > 0 then
				self.spirit_obj:SetObjId(self.vo.used_sprite_id)
				self.spirit_obj:UpdateSpritId(self.vo.used_sprite_id)
				if nil ~= self.vo.user_pet_special_img then
					self.spirit_obj:UpdateSpecialSpritId(self.vo.user_pet_special_img)
				end
				self.spirit_obj:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(spirit_cfg.res_id))
				self.spirit_obj:SetSpiritName(self.vo.sprite_name)
			end
			call_back()
		end
	else
		if self.spirit_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpriteObj, self.spirit_obj:GetObjKey())
			self.spirit_obj:RemoveModel(SceneObjPart.Main)
			self.spirit_obj:DeleteMe()
			self.spirit_obj = nil
		end
		call_back()
	end
end

function Role:ChangeSpiritHalo()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.used_sprite_id and self.vo.used_sprite_id > 0 and fb_scene_cfg.pb_jingling ~= 1 and not self.shield_spirit_helo then
		if self.vo.appearance.jingling_guanghuan_imageid and self.vo.appearance.jingling_guanghuan_imageid > 0 then
			if self.spirit_obj then
				local image_cfg = SpiritData.Instance:GetSpiritHaloImageCfg()[self.vo.appearance.jingling_guanghuan_imageid]
				if self.vo.appearance.jingling_guanghuan_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
					image_cfg = SpiritData.Instance:GetSpiritHaloSpecialImageCfg()[self.vo.appearance.jingling_guanghuan_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID]
				end
				local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_SPIRIT]
				if not is_hide then
					GlobalTimerQuest:AddDelayTimer(function()
						if self.spirit_obj then
							if not self.spirit_halo then
								self.spirit_halo = AsyncLoader.New(self.spirit_obj.draw_obj:GetAttachPoint(AttachPoint.Hurt))
							end
							if image_cfg then
								local load_call_back = function(obj)
									local go = U3DObject(obj)
									obj.transform:SetParent(self.spirit_obj.draw_obj:GetAttachPoint(AttachPoint.Hurt), false)
									local main_obj = self.spirit_obj.draw_obj:GetPart(SceneObjPart.Main):GetObj()
									local attachment = main_obj and main_obj.actor_attachment
									if go.attach_obj then
										go.attach_obj:SetAttached(self.spirit_obj.draw_obj:GetAttachPoint(AttachPoint.Hurt))
										if attachment then
											go.attach_obj:SetTransform(attachment.Prof)
										end
									end
								end
								local bundle, asset = ResPath.GetHaloModel(image_cfg.res_id)
								self.spirit_halo:Load(bundle, asset, load_call_back)
							end
						end
					end, 0.8)
				end
			end
		end
	else
		if self.spirit_halo then
			self.spirit_halo:Destroy()
			self.spirit_halo:DeleteMe()
			self.spirit_halo = nil
		end
	end
end

function Role:ChangeSpiritFazhen()
	if self.spirit_obj then
		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if self.vo.used_sprite_id and self.vo.used_sprite_id > 0 and fb_scene_cfg.pb_jingling ~= 1 then
			if self.vo.appearance and self.vo.appearance.jingling_fazhen_imageid > 0 then
				local image_cfg = SpiritData.Instance:GetSpiritFazhenImageCfg()[self.vo.appearance.jingling_fazhen_imageid] or {}
				if self.vo.appearance.jingling_fazhen_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
					image_cfg = SpiritData.Instance:GetSpiritFazhenSpecialImageCfg()[self.vo.appearance.jingling_fazhen_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID] or {}
				end
				self.spirit_obj:ChangeSpiritFazhen(image_cfg.res_id)
			else
				self.spirit_obj:ChangeSpiritFazhen()
			end
		else
			self.spirit_obj:ChangeSpiritFazhen()
		end
	end
end

-- function Role:ChangeFightMount()
-- 	if self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0 then
-- 		if not self.fight_mount_obj then
-- 			self.fight_mount_obj = Scene.Instance:CreateFightMountObjByRole(self)
-- 		else
-- 			self.fight_mount_obj:ChangeModel(SceneObjPart.Main, ResPath.GetFightMountModle())
-- 		end
-- 	else
-- 		if self.fight_mount_obj then
-- 			self.fight_mount_obj:RemoveModel(SceneObjPart.Main)
-- 			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FightMount, self.fight_mount_obj:GetObjKey())
-- 			-- self.fight_mount_obj:GetFollowUi():DeleteMe()
-- 			-- GameObject.Destroy(self.spirit_obj.draw_obj:GetRoot().gameObject)
-- 			self.fight_mount_obj:DeleteMe()
-- 			self.fight_mount_obj = nil
-- 		end
-- 	end
-- end

function Role:ChangeGuildBattle()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() ~= SceneType.LingyuFb then
			return
		end
	end
	if self.vo.special_param ~= 0 then
		local str = "guild_battle_" .. self.vo.special_param
		self:GetFollowUi():ChangeSpecailTitle(str)
	else
		self:GetFollowUi():ChangeSpecailTitle(nil)
	end
end

function Role:ChangePet()
	if self.vo.pet_id and self.vo.pet_id > 0 then
		if not self.pet_obj then
			self.pet_obj = Scene.Instance:CreatePetObjByRole(self)
		else
			local pet_cfg = LittlePetData.Instance:GetSinglePetCfgByPetId(self.vo.pet_id)
			if pet_cfg and pet_cfg.using_img_id and pet_cfg.using_img_id > 0 then
				self.pet_obj:SetObjId(self.vo.pet_id)
				self.pet_obj:UpdatePetId(self.vo.pet_id)
				self.pet_obj:ChangeModel(SceneObjPart.Main, ResPath.GetLittlePetModel(pet_cfg.using_img_id))
				self.pet_obj:SetPetName(pet_cfg.name)
			end
		end
	else
		if self.pet_obj then
			local delete_call_back = function()
				self:RemovePetModel()
			end
			self.pet_obj:RemovePetWithFade(delete_call_back)
		end
	end
end

function Role:RemovePetModel()
	if self.pet_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.PetObj, self.pet_obj:GetObjKey())
		self.pet_obj:RemoveModel(SceneObjPart.Main)
		self.pet_obj:DeleteMe()
		self.pet_obj = nil
	end
end

function Role:ChangeGoddess()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.appearance and self.vo.use_xiannv_id and self.vo.use_xiannv_id >= 0 and fb_scene_cfg.pb_god ~= 1 and self.goddess_visible then
		if not self.goddess_obj then
			self.goddess_obj = Scene.Instance:CreateGoddessObjByRole(self)
		else
			self.goddess_obj:SetAttr("use_xiannv_id", self.vo.use_xiannv_id)
			self.goddess_obj:SetAttr("goddess_wing_id", self.vo.appearance.shenyi_used_imageid)
			self.goddess_obj:SetAttr("goddess_shen_gong_id", self.vo.appearance.shengong_used_imageid)
			self.goddess_obj:SetAttr("xiannv_huanhua_id", self.vo.xiannv_huanhua_id)
		end
	else
		if self.goddess_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
			self.goddess_obj = nil
		end
	end
end

function Role:ChangeLingChong()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_id = self.vo.lingchong_used_imageid or 0
	if image_id <= 0 or fb_scene_cfg.pb_lingchong == 1 or not self.lingchong_visible then
		if self.lingchong_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.LingChongObj, self.lingchong_obj:GetObjKey())
			self.lingchong_obj = nil
		end

		return
	end

	if nil == self.lingchong_obj then
		self.lingchong_obj = Scene.Instance:CreateLingChongObjByRole(self)
	else
		self.lingchong_obj:SetAttr("lingchong_used_imageid", self.vo.lingchong_used_imageid)
		self.lingchong_obj:SetAttr("linggong_used_imageid", self.vo.linggong_used_imageid)
		self.lingchong_obj:SetAttr("lingqi_used_imageid", self.vo.lingqi_used_imageid)
	end
end

function Role:ChangeSuperBaby()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local baby_id = self.vo.sup_baby_id or -1
	if baby_id < 0 or fb_scene_cfg.pb_super_baby == 1 or not self.super_baby_visible then
		if self.super_baby_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SuperBabyObj, self.super_baby_obj:GetObjKey())
			self.super_baby_obj = nil
		end
		return
	end
	
	if nil == self.super_baby_obj then
		self.super_baby_obj = Scene.Instance:CreateSuperBabyObjByRole(self)
	else
		self.super_baby_obj:SetAttr("sup_baby_id", baby_id)
		self.super_baby_obj:SetAttr("sup_baby_name", self.vo.sup_baby_name or "")
	end
end
function Role:GetLingChongObj()
	return self.lingchong_obj
end

function Role:GetSuperBabyObj()
	return self.super_baby_obj
end

function Role:CreateFollowUi()
	self.follow_ui = RoleFollow.New()
	self.follow_ui:Create()
	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform)
	end
	self:SyncShowHp()
end

function Role:GetGoddessObj()
	return self.goddess_obj
end

function Role:ReloadUIName()
	if self.follow_ui ~= nil then
		local scene_logic = Scene.Instance:GetSceneLogic()
		if nil == scene_logic then
			return
		end
		local color_name = scene_logic:GetColorName(self)
		-- if self:IsMainRole() then
			-- color_name = ToColorStr(color_name, ROLE_FOLLOW_UI_COLOR.ROLE_NAME)
		-- end
		self.follow_ui:SetName(color_name, self)
		self:ReloadUIGuildName()
		self:ReloadUILoverName()
		self:ReloadSpecialImage()
		self.follow_ui:SetVipIcon(self)
		self.follow_ui:SetGuildIcon(self)
		self.follow_ui:SetLongXingIcon(self)
	end
end

function Role:ReloadGuildIcon()
	if self.follow_ui ~= nil then
		self.follow_ui:SetGuildIcon(self)
		-- self:GetFollowUi():SetIsShowGuildIcon(Scene.Instance:GetCurFbSceneCfg().guild_badge == 0) --0显示公会头像
	end
end

function Role:SetRoleEffect(bundle, asset, duration, position, rotation, scale)
	if self.draw_obj then
		local transform = self.draw_obj:GetTransfrom()
		PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
			if nil == prefab then
				return
			end
			if not IsNil(transform) then
				local obj = GameObject.Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(transform, false)
				PrefabPool.Instance:Free(prefab)

				GlobalTimerQuest:AddDelayTimer(function()
					if not IsNil(obj) then
						GameObject.Destroy(obj)
					end
				end, duration)
			end
		end)
	end
end

function Role:ReloadUIGuildName()
	if self.follow_ui ~= nil then
		local guild_id = self:GetVo().guild_id
		if guild_id > 0 then
			local guild_name = self:GetVo().guild_name
			guild_name = ToColorStr(guild_name, ROLE_FOLLOW_UI_COLOR.GUILD_NAME)
			guild_name = "[" .. guild_name .. "]"
			local post = GuildData.Instance:GetGuildPostNameByPostId(self:GetVo().guild_post)
			if post then
				guild_name = guild_name .. " . " .. post
			end
			self.follow_ui:SetGuildName(guild_name)
		else
			self.follow_ui:SetGuildName()
		end
	end
end

function Role:ReloadUILoverName()
	if self.follow_ui ~= nil then
		local lover_name = self:GetVo().lover_name
		if lover_name and lover_name ~= "" then
			lover_name = ToColorStr(lover_name, ROLE_FOLLOW_UI_COLOR.LOVER_NAME)
			lover_name = "[" .. lover_name .. "]" .. (Language.Marriage.LoverNameFormat[self:GetVo().sex])
			self.follow_ui:SetLoverName(lover_name)
		else
			self.follow_ui:SetLoverName()
		end
	end
end

function Role:ReloadSpecialImage()
	if nil == self.follow_ui then
		return
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	local is_show_special_image, asset, bundle = scene_logic:GetIsShowSpecialImage(self)

	if self.vo.top_dps_flag and self.vo.top_dps_flag > 0 then
		is_show_special_image, asset, bundle = true, ResPath.GetDpsIcon()
	end

	-- 容错防止跨服温泉出现称号（BOSS归属者）
	local cur_scene_type = Scene.Instance:GetSceneType()
	if IS_ON_CROSSSERVER and cur_scene_type == SceneType.HotSpring then
		is_show_special_image = false
	end
	self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
end

function Role:AddBaoJuEffect(asset_bundle, name, time)
	if not asset_bundle or not name then
		return
	end

	local is_shield_self = SettingData.Instance:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	if is_shield_self then
		if self:IsMainRole() then
			return
		end
	end
	local is_shield_other = SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	if is_shield_other then
		if not self:IsMainRole() then
			return
		end
	end

	local baoju_part = self.draw_obj:GetPart(SceneObjPart.BaoJu)
	if baoju_part then
		if self.baoju_effect == nil then
			local obj = baoju_part:GetObj()
			if obj then
				self.baoju_effect = AsyncLoader.New(obj.transform)
				self.baoju_effect:Load(asset_bundle, name)
				self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
					self.baoju_effect:Destroy()
					self.baoju_effect:DeleteMe()
					self.baoju_effect = nil end, time or 1)
			end
		end
	end
end

-- 武器为红色时，更换武器模型
function Role:EquipDataChangeListen()
	self:UpdateAppearance()
	if self.weapon_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
	end

	if self.weapon2_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
	end
end

function Role:SetWeaponEffect(part, obj)
	if not obj or (part ~= SceneObjPart.Weapon and part ~= SceneObjPart.Weapon2) then return end

	if self.vo.appearance and self.vo.appearance.fashion_wuqi and self.vo.appearance.fashion_wuqi == 0 and self.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
		local bundle, asset = ResPath.GetWeaponEffect(self.weapon_res_id)
		if self.weapon_effect_name and self.weapon_effect_name ~= asset then
			if self.weapon_effect then
				GameObjectPool.Instance:Free(self.weapon_effect)
				self.weapon_effect = nil
			end
		end
		if bundle and asset and not self.weapon_effect and not self.is_load_effect then
			self.is_load_effect = true
			GameObjectPool.Instance:SpawnAsset(bundle, asset, function (effct_obj)
				if nil == effct_obj then return end
				self.weapon_effect = effct_obj.gameObject
				effct_obj.transform:SetParent(obj.transform, false)
				if self.draw_obj then
					obj.gameObject:SetLayerRecursively(self.draw_obj.root.gameObject.layer)
				end
				self.weapon_effect_name = asset
				self.is_load_effect = false
			end)
		end
		if part == SceneObjPart.Weapon2 then
			local bundle, asset = ResPath.GetWeaponEffect(self.weapon2_res_id)
			if self.weapon2_effect_name and self.weapon2_effect_name ~= asset then
				if self.weapon2_effect then
					GameObject.Destroy(self.weapon2_effect)
					self.weapon2_effect = nil
				end
			end
			if bundle and asset and not self.weapon2_effect and not self.is_load_effect2 then
				self.is_load_effect2 = true
				GameObjectPool.Instance:SpawnAsset(bundle, asset, function (effct_obj)
					if nil == effct_obj then return end
					self.weapon2_effect = effct_obj.gameObject
					effct_obj.transform:SetParent(obj.transform, false)
					if self.draw_obj then
						obj.gameObject:SetLayerRecursively(self.draw_obj.root.gameObject.layer)
					end
					self.is_load_effect2 = false
					self.weapon2_effect_name = asset
				end)
			end
		end
	else
		if self.weapon_effect then
			GameObjectPool.Instance:Free(self.weapon_effect)
			self.weapon_effect = nil
		end
		if self.weapon2_effect then
			GameObjectPool.Instance:Free(self.weapon2_effect)
			self.weapon2_effect = nil
		end
	end
end

function Role:OnModelLoaded(part, obj)
	Character.OnModelLoaded(self, part, obj)
	if self:IsMainRole() then
		if part == SceneObjPart.Mount then
			if self.mount_res_id == nil or self.mount_res_id <= 0 then
				self:RemoveModel(SceneObjPart.Mount)
			elseif self.show_fade_in then
				self.show_fade_in = false
				local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
				mount_part:RemoveOcclusion()
				local call_back = function()
					if mount_part then
						GlobalTimerQuest:AddDelayTimer(function()
							mount_part:AddOcclusion()
						end, 0)
					end
				end
				self:PlayMountFade(1, 1, call_back)
			end
			self:FixMeshRendererBug()
		end
		if part == SceneObjPart.Main then
			local logic = Scene.Instance:GetSceneLogic()
			if self:IsAtk() or (logic and not logic:CanCancleAutoGuaji()) then
				self:OnAnimatorEnd()
			end
			for _, v in pairs(self.animator_handle_t) do
				v:Dispose()
			end
			self.animator_handle_t = {}
		end
	end
	if part == SceneObjPart.Main then
		local boat_obj = Scene.Instance:GetBoatByRole(self:GetObjId())
		local special_param = self.vo.special_param
		if boat_obj then
			if special_param >= 0 and special_param < 65535 then
				self.draw_obj:GetPart(SceneObjPart.Main):SetInteger(ANIMATOR_PARAM.STATUS, 2)
			else
				self.draw_obj:GetPart(SceneObjPart.Main):SetInteger(ANIMATOR_PARAM.STATUS, 3)
			end
			local point = boat_obj:GetBoatAttachPoint(self:GetObjId())
			if point then
				obj.gameObject.transform:SetParent(point, false)
				obj.gameObject.transform:SetLocalPosition(0,0,0)
				obj.gameObject.transform.rotation = Vector3(0,0,0)
				obj.gameObject.transform:SetLocalScale(1,1,1)
			end
		end
		self:UpdateFaZhenAttach()
		self:CheckDanceState()
	elseif part == SceneObjPart.HoldBeauty then
		if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER then
			obj.gameObject.transform.transform:SetLocalScale(1.3, 1.3, 1.3)
		end
	end
end

-- 角色更换时装，重新设置法阵挂点
function Role:UpdateFaZhenAttach()
	if nil == self.fazhen_res_id or "" == self.fazhen_res_id then
		return
	end
	local attachment = self.draw_obj:_TryGetPartAttachment(SceneObjPart.Main)
	if attachment ~= nil then
		local fazhen_part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
		local fazhen_obj = fazhen_part and fazhen_part:GetObj()
		if nil ~= fazhen_obj then
			fazhen_obj.gameObject:SetActive(true)
			local point = attachment:GetAttachPoint(AttachPoint.HurtRoot)
			if not IsNil(point) then
				fazhen_obj.attach_obj:SetAttached(point)
				fazhen_obj.attach_obj:SetTransform(attachment.Prof)
			end
		end
	end
end

function Role:OnModelRemove(part, obj)
	Character.OnModelRemove(self, part, obj)
	if part == SceneObjPart.Main then
		if SimpleShadow ~= nil then
			local simple_shadow = obj.gameObject:GetComponent(typeof(SimpleShadow))
			if simple_shadow then
				self:GetOrAddSimpleShadow()
				if self.simple_shadow then
					self.simple_shadow.enabled = not self.role_is_visible
					self.simple_shadow.ShadowMaterial = simple_shadow.ShadowMaterial
					self.simple_shadow.GroundMask = simple_shadow.GroundMask
					self.simple_shadow.Offset = simple_shadow.Offset
					self.simple_shadow.ScaleDistance = simple_shadow.ScaleDistance
					self.simple_shadow.ShadowSize = simple_shadow.ShadowSize
				end
			end
		end
	end
end

-- 带渐变效果移除坐骑
function Role:RemoveMonutWithFade()
	if not self:IsMainRole() or CgManager.Instance:IsCgIng() then
		self:RemoveModel(SceneObjPart.Mount)
		return
	end

	-- 坐骑渐变
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	if nil ~= mount_part and mount_part:GetObj() then
		mount_part:Reset()
		mount_part:RemoveOcclusion()
		mount_part:SetMainRole(false)

		local obj = mount_part:GetObj()
		if mount_part.remove_callback ~= nil then
			mount_part.remove_callback(obj)
			mount_part.remove_callback = nil
		end
		local call_back = function() mount_part:RemoveModel() mount_part:DeleteMe() end
		local fade_time = 1
		self.show_fade_out = false
		self:PlayMountFade(0, fade_time, call_back)
		if obj and obj.gameObject then
			self:DoMountRun(obj.gameObject, fade_time, 10)
			-- 下马特效
			self:DestroyXiaMaEffect()
			self:RemoveXiamaDelay()
			self.xiama_effect = AsyncLoader.New(self:GetRoot().transform)
			self.xiama_effect:Load("effects2/prefab/misc/xiamatexiao_prefab", "xiamatexiao")
			self.xiama_delay_time = GlobalTimerQuest:AddDelayTimer(function() self:DestroyXiaMaEffect() end, 5)
		end
		self.draw_obj.part_list[SceneObjPart.Mount] = nil
	end
end

-- 坐骑渐变
function Role:PlayMountFade(fade_type, fade_time, call_back)
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	if nil ~= mount_part then
		local mount_obj = mount_part:GetObj()
		if mount_obj == nil then
			call_back()
			return
		end
		local fadeout = mount_obj.actor_fadout
		if fadeout ~= nil then
			if fade_type == 0 then
				fadeout:Fadeout(fade_time, call_back)
			elseif fade_type == 1 then
				fadeout:Fadein(fade_time, call_back)
			end
		else
			call_back()
		end
	end
end

-- 坐骑位移
function Role:DoMountRun(obj, time, distance)
	if obj and obj.transform then
		local anim = obj:GetComponent(typeof(UnityEngine.Animator))
		if anim == nil then
			return
		end
		local target_pos = obj.transform.position + obj.transform.forward * distance
		if not self.game_root then
			self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
		end
		if self.game_root then
			obj.transform:SetParent(self.game_root.transform, true)
		end
		anim:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		local tween = obj.transform:DOMove(target_pos, time)
		tween:SetEase(DG.Tweening.Ease.Linear)
	end
end

-- 移除下马特效
function Role:DestroyXiaMaEffect()
	if self.xiama_effect ~= nil then
		self.xiama_effect:Destroy()
		self.xiama_effect:DeleteMe()
		self.xiama_effect = nil
	end
end

-- 清除下马特效延迟
function Role:RemoveXiamaDelay()
	if self.xiama_delay_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.xiama_delay_time)
		self.xiama_delay_time = nil
	end
end

function Role:GetOrAddSimpleShadow()
	if SimpleShadow ~= nil then
		self.simple_shadow = self.draw_obj:GetRoot().gameObject:GetOrAddComponent(typeof(SimpleShadow))
	end
end

function Role:UpdateRoleFaZhen()
	local eternity_level = self.vo.appearance and self.vo.appearance.use_eternity_level or 0
	local suit_cfg = nil
	-- if nil == ForgeData.Instance then
	-- 	suit_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("equipforge_auto").eternity_suit, "suit_level")
	-- else
		suit_cfg= ForgeData.Instance:GetEternitySuitCfg(eternity_level)
	-- end

	if nil == suit_cfg then return end

	self.fazhen_res_id = suit_cfg.fazhen
end

function Role:ChangeFaZhen()
	-- 人物法阵
	if nil ~= self.fazhen_res_id and self.fazhen_res_id ~= "" and self.fight_mount_res_id == 0 and self.mount_res_id == 0 then
		--self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetZhenfaEffect(self.fazhen_res_id))
	end
end

-- 修复MeshRenderer被隐藏的bug
function Role:FixMeshRendererBug()
	if self.draw_obj then
		-- 取到身上所有部件
		for k,v in pairs(SceneObjPart) do
			local part_obj = self.draw_obj:_TryGetPartObj(v)
			if part_obj then
				local mesh_renderer_list = part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
				-- 把每个meshRenderer的Enabled强制设为true
				for i = 0, mesh_renderer_list.Length - 1 do
					local mesh_renderer = mesh_renderer_list[i]
					if mesh_renderer then
						mesh_renderer.enabled = true
					end
				end
			end
		end
	end
end


function Role:EnterWater(is_in_water)
	Character.EnterWater(self, is_in_water)
	if self.draw_obj then
		local root = self.draw_obj:GetRoot()
		if root then
			local part = self.draw_obj:GetPart(SceneObjPart.Main)
			if is_in_water then
				if Scene.Instance:GetSceneType() == SceneType.HotSpring then
					part:SetLayer(2, 1)
					part:SetLayer(3, 1)
				end
			else
				if Scene.Instance:GetSceneType() == SceneType.HotSpring then
					part:SetLayer(2, 0)
					part:SetLayer(3, 0)
				end
			end
		end
	end
end

function Role:EnterStateStand()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)

	if self.is_gather_state then
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.Fishing then
			--钓鱼特殊处理
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		elseif self.is_fishing then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.ShuaiGan)
			self.draw_obj:SetDirectionByXY(-282.25, -153.75) --捕鱼写死位置
		elseif self.is_kf_mining then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Mining)
		else
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		end
		self:StopHug()
	else
		if self:CanHug() then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			self:DoHug()
			local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
			if holdbeauty_part then
				holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
			end
		else
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
			local cloak_part = self.draw_obj:GetPart(SceneObjPart.Cloak)
			if self:IsRole() and cloak_part then
				cloak_part:SetBool("run", false)
			end
		end
	end

	local fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	fight_mount_part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	-- 温泉场景
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		local special_param = self.vo.special_param
		if self:IsMainRole() then
			special_param = HotStringChatData.Instance:GetpartnerObjId()
		end
		local boat_obj = Scene.Instance:GetBoatByRole(self:GetObjId())
		if boat_obj then
			if special_param >= 0 and special_param < 65535 then
				part:SetInteger(ANIMATOR_PARAM.STATUS, 2)
				self:UpdateBoat()
			else
				part:SetInteger(ANIMATOR_PARAM.STATUS, 3)
			end
		end
	end
end



function Role:EnterStateDead()
	Character.EnterStateDead(self)
	self:StopHug()
end

function Role:EnterStateMove()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	-- 抱美人
	if self:CanHug() then
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.HugRun)
		self:DoHug()
		local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
		if holdbeauty_part then
			holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.HugRun)
		end
	else
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		local cloak_part = self.draw_obj:GetPart(SceneObjPart.Cloak)
		if self:IsRole() and cloak_part then
			cloak_part:SetBool("run", true)
		end
	end
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		Scene.Instance:DeleteBoatByRole(self:GetObjId())
	end
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	mount_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
	local fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	fight_mount_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
end

function Role:UpdateStateMove(elapse_time)
	if self.delay_end_move_time > 0 then
		if Status.NowTime >= self.delay_end_move_time then
			self.delay_end_move_time = 0
			self:ChangeToCommonState()
		end
		return
	end

	if self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		if self:CanHug() then
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.HugRun)
		else
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Run)
		end
		--移动状态更新
		local distance = elapse_time * self:GetMoveSpeed()
		self.move_pass_distance = self.move_pass_distance + distance

		if self.move_pass_distance >= self.move_total_distance then
			self.is_special_move = false
			self:SetRealPos(self.move_end_pos.x, self.move_end_pos.y)

			if self:MoveEnd() then
				self.move_pass_distance = 0
				self.move_total_distance = 0
				if self:IsMainRole() then
					self.delay_end_move_time = Status.NowTime + 0.05
				elseif self:IsSpirit() then
					self.delay_end_move_time = Status.NowTime + 0.02
				else
					self.delay_end_move_time = Status.NowTime + 0.2
				end
			end
		else
			local mov_dir = u3d.v2Mul(self.move_dir, distance)
			self:SetRealPos(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
		end
	end
end

function Role:CheckIsHuSong()
	return self.vo.husong_taskid ~= 0 and self.vo.husong_color ~= 0
end

function Role:DoHug()
	if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER then
		self:ChangeModel(SceneObjPart.HoldBeauty, ResPath.GetGatherModel(self.hug_res_id))
	elseif self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
		self:ChangeModel(SceneObjPart.HoldBeauty, ResPath.GetNpcModel(self.hug_res_id))
	end
end

function Role:StopHug()
	self:RemoveModel(SceneObjPart.HoldBeauty)
	local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
	if holdbeauty_part then
		holdbeauty_part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	end
end

------------------------双人坐骑-------------------------------------


--双人坐骑搭档位置刷新
function Role:UpdateMultiMountParnter(now_time, elapse_time)

	--延迟刷新位置
	if self.partner_point and self.on_multi_mount > 0 and self.on_multi_mount < 5 and self.update_multi_mount_time and self.update_multi_mount_time < now_time then
		if self.is_sit_mount2 == 0 then
			local off_y = 0
			local main_part = self.draw_obj:_TryGetPartObj(SceneObjPart.Main)
			if main_part then
				local mount_point = main_part.transform:Find("mount_point")
				if mount_point then
					off_y = mount_point.localPosition.y or 0
				end
			end
			self.draw_obj.root.transform.position = Vector3(self.partner_point.position.x, self.partner_point.position.y - off_y, self.partner_point.position.z)
		else
			self.draw_obj.root.transform.position = Vector3(self.partner_point.position.x, self.partner_point.position.y, self.partner_point.position.z)
		end
		self.draw_obj.root.transform.localRotation = Quaternion.Euler(0, -self.partner_point.localEulerAngles.y, 0)
		self.update_multi_mount_time = now_time + 1
		self.on_multi_mount = self.on_multi_mount + 1
		if self.partner_scale then
			self.draw_obj.root.transform.localScale = Vector3(1 / self.partner_scale.x, 1 / self.partner_scale.y, 1 / self.partner_scale.z)
		end
	end

	if self:IsMultiMountPartner() and self.on_multi_mount == 0 then
		self.multi_mount_owner_role = self:GetMountOwnerRole()
		if self.multi_mount_owner_role then
			if not self:IsRoleVisible()then
				self:SetRoleVisible(true)
			end
			local mount_part = self.multi_mount_owner_role.draw_obj:_TryGetPartObj(SceneObjPart.Mount) or self.multi_mount_owner_role.draw_obj:_TryGetPartObj(SceneObjPart.FightMount)
			if mount_part then
				self.partner_point = mount_part.transform:Find("mount_point001")
				self.partner_scale = mount_part.transform.localScale
				self.draw_obj:StopMove()
				self.draw_obj:StopRotate()
				self.draw_obj.root.transform:SetParent(self.partner_point)
				self:RemoveModel(SceneObjPart.FightMount)
				self:RemoveModel(SceneObjPart.Mount)
				local main_part = self.draw_obj:_TryGetPartObj(SceneObjPart.Main)
				if main_part then
					if self.is_sit_mount2 == 0 then
						main_part.animator:SetLayerWeight(2, 1.0)
						main_part.animator:SetLayerWeight(3, 0)
					else
						main_part.animator:SetLayerWeight(2, 0)
						main_part.animator:SetLayerWeight(3, 1.0)
					end
					self.on_multi_mount = 1
					self.update_multi_mount_time = now_time
				end
			end
		end
	end
end


function Role:SetMultiMountIdAndOnwerFlag(multi_mount_res_id, multi_mount_is_owner, multi_mount_other_uid)
	local is_parnter = self.is_parnter
	local old_multi_mount_res_id = self.vo.multi_mount_res_id

	self.vo.multi_mount_res_id = multi_mount_res_id
	self.vo.multi_mount_is_owner = multi_mount_is_owner
	self.vo.multi_mount_other_uid = multi_mount_other_uid
	--有双人坐骑不显示羽翼
	if self.vo.multi_mount_res_id > 0 then
		self:RemoveModel(SceneObjPart.Wing)
		self.is_sit_mount, self.is_sit_mount2 = MultiMountData.Instance:GetMultiMountSitTypeByResid(multi_mount_res_id)
	--下双人坐骑时恢复
	elseif old_multi_mount_res_id > 0 then
		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id <= 0 then
			self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
		end
	end
	self.is_parnter = self.vo.multi_mount_other_uid > 0 and self.vo.multi_mount_is_owner == 0
	if is_parnter and not self.is_parnter then
		self:MultiMountPartnerDismount()
	else
		self:UpdateMountAnimation()
	end
	self.partner_point = nil
	self.multi_mount_owner_role = nil
end

-- 是否跟随者
function Role:IsMultiMountPartner()
	return self.is_parnter
end

function Role:SetMountOtherObjId(mount_other_objid)
	self.mount_other_objid = mount_other_objid
	self.on_multi_mount = 0
end

--跟随者下坐骑
function Role:MultiMountPartnerDismount()
	self.on_multi_mount = 0
	self.draw_obj.root.transform:SetParent(SceneObjLayer)
	self.draw_obj.root.transform.localScale = Vector3(1, 1, 1)
	if self.multi_mount_owner_role then
		local logic_x, logic_y = self.multi_mount_owner_role.logic_pos.x, self.multi_mount_owner_role.logic_pos.y
		self:SetLogicPos(logic_x, logic_y)
	end
	self.draw_obj:StopMove()
	self:UpdateMountAnimation()
	if self.mount_res_id <= 0 then
		local main_part = self.draw_obj:_TryGetPartObj(SceneObjPart.Main)
		if main_part then
			main_part.animator:SetLayerWeight(2, 0)
			main_part.animator:SetLayerWeight(3, 0)
		end
	end
end

function Role:SetLogicPos(pos_x, pos_y)
	if not self.is_parnter then
		Character.SetLogicPos(self, pos_x, pos_y)
	else
		self:SetLogicPosData(pos_x, pos_y)
	end
end

function Role:DoMove(pos_x, pos_y, is_chongci)
	self.is_chongci = is_chongci
	self:ChangeChongCi(is_chongci)
	if not self.is_parnter then
		Character.DoMove(self, pos_x, pos_y)
	else
		-- self:SetRealPos(pos_x, pos_y)
	end
end

function Role:SetDirectionByXY(x, y)
	if not self.is_parnter then
		Character.SetDirectionByXY(self, x, y)
	end
end

function Role:GetMountOwnerRole()
	if self.vo.multi_mount_is_owner == 0 and self.mount_other_objid >= 0 then
		local owner_role = self.parent_scene:GetRoleByObjId(self.mount_other_objid)
		if nil ~= owner_role and owner_role:GetRoleId() == self.vo.multi_mount_other_uid then
			return owner_role
		end
	end
	return nil
end

function Role:GetMountParnterRole()
	if self.vo.multi_mount_is_owner ~= 0 and self.mount_other_objid >= 0 then
		local partner_role = self.parent_scene:GetRoleByObjId(self.mount_other_objid)
		if nil ~= partner_role and partner_role:GetRoleId() == self.vo.multi_mount_other_uid then
			return partner_role
		end
	end
	return nil
end

function Role:UpdateMountAnimation()
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	self:UpdateMount()
	if main_part then
		if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 then
			self.has_mount = true
		else
			if self.vo.move_mode ~= MOVE_MODE.MOVE_MODE_JUMP2 then
				if self.has_mount then
					self.has_mount = false
				end
			end
		end
		main_part:EnableMountUpTrigger(false) --nil ~= main_part:GetObj() and main_role and not main_role:IsFightState()
		self:OnMountUpEnd()
	end
end

function Role:GetMoveSpeed()
	local speed = Scene.ServerSpeedToClient(self.vo.move_speed) + self.special_speed
	if self.is_jump or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		if self.vo.jump_factor then
			speed = self.vo.jump_factor * speed
		else
			speed = 1.8 * speed
		end
	end

	if self.is_chongci then
		speed = COMMON_CONSTS.CHONGCI_SPEED
	end
	return speed
end

function Role:ChangeChongCi(state)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= part then
		part:SetLayer(ANIMATOR_PARAM.CHONGCI_LAYER, state and 1 or 0)
	end
end

function Role:OnAnimatorBegin(anim_name)
	Character.OnAnimatorBegin(self, anim_name)
	-- 增加打击感
	if RoleSkillHit[self.vo.prof] then
		local hit_timer = RoleSkillHit[self.vo.prof][anim_name]
		if hit_timer then
			if self.attack_target_obj ~= nil and self.attack_target_obj:IsMonster() and not self.attack_target_obj:IsBoss() and self.attack_target_obj.draw_obj ~= nil then
				self.attack_target_obj:SetIsMainTarget(true)
				local target_main_part = self.attack_target_obj.draw_obj:GetPart(SceneObjPart.Main)
				for k,v in ipairs(hit_timer) do
					GlobalTimerQuest:AddDelayTimer(
					function()
						if target_main_part then
							target_main_part:SetTrigger("hurt")
							target_main_part:SetFloat("speed", 0)
							GlobalTimerQuest:AddDelayTimer(function()
								if nil ~= target_main_part then
									target_main_part:SetFloat("speed", 1)
								end
							end, 0.1)
						end
					end, v)
				end
			end
		end
	end
end

function Role:OnAnimatorEnd(anim_name)
	Character.OnAnimatorEnd(self, anim_name)
	if self.attack_target_obj ~= nil and self.attack_target_obj:IsMonster() then
		self.attack_target_obj:SetIsMainTarget(false)
	end
end

function Role:SetFollowLocalPosition()
	local follow_ui = self:GetFollowUi()
	local settingData = SettingData.Instance
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
	local temp_high = ((shield_others or (shield_friend and not Scene.Instance:IsEnemy(self))) and not self:IsMainRole()) and 100 or 0
	local high = temp_high

	if follow_ui then
		follow_ui:SetFollowTarget(self.draw_obj:GetTransfrom())
		follow_ui:SetLocalUI(0,high,0)
		follow_ui:GetHpObj().transform:SetLocalPosition(0,10,0)
		follow_ui:SetNameTextPosition()
	end
end

-- 是否可以抱东西
function Role:CanHug()
	return Scene.Instance:GetSceneType() == 0 and self.vo.task_appearn > 0
	and self.is_jump == false and not self:IsDead() and not self.is_gather_state
end

-- 是否使用第二个坐骑动作
function Role:IsMountLayer2()
	return self.is_sit_mount == 2
end

function Role:CheckIsGeneral()
	if self.special_res_id ~= 0
		and SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.vo.special_appearance
		and (self.vo.bianshen_param == "" or self.vo.bianshen_param == 0) then

		local bundle, name = ResPath.GetGeneralRes(self.special_res_id)
		self:ChangeModel(SceneObjPart.Main, bundle, name, function (obj)
			FamousGeneralCtrl.Instance:CheckEffect(self.special_res_id, obj)
		end)

		return true
	end

	return false
end

function Role:CheckDanceState()
	if self.vo.appearance == nil then
		return
	end

	local is_active = false
	for i = 1, 3 do
		local value = self.vo.appearance.baojia_texiao_id == i and 1 or 0
		local layer = ANIMATOR_PARAM.DANCE1_LAYER - 1 + i
		if (self.vo.mount_appeid and self.vo.mount_appeid > 0)
			or (self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0)
			or (self.vo.multi_mount_res_id and self.vo.multi_mount_res_id > 0)
			or self.special_res_id ~= 0 then
			value = 0
		end

		if self.draw_obj then
			self.draw_obj:GetPart(SceneObjPart.Main):SetLayer(layer, value)
		end

		if value == 1 then
			is_active = true
		end
	end

	if is_active then
		self:RandomDance()
	end
end

function Role:UpdateGatherStatus()
	local is_gather = false
	if self.vo.role_status == RoleStatus.ROLE_STATUS_GATHER then
		if self.vo.gather_obj_id and self.vo.gather_obj_id ~= 0x10000 then
			is_gather = true
		end
	end
	self:SetIsGatherState(is_gather)
end

function Role:RandomDance()
	if not self.dance_delay_time then
		self.dance_delay_time = GlobalTimerQuest:AddDelayTimer(function ()
			for i = 1, 3 do
				if self.draw_obj then
					local layer = ANIMATOR_PARAM.DANCE1_LAYER - 1 + i
					self.draw_obj:GetPart(SceneObjPart.Main):SetLayer(layer, 0)
				end
			end
			self.dance_delay_time = GlobalTimerQuest:AddDelayTimer(function ()
				self.dance_delay_time = nil
				self:CheckDanceState()
			end, math.random(5, 10))
		end, math.random(10, 20))
	end
end

function Role:EnterFightState(...)
	Character.EnterFightState(self, ...)
	self:ChangeFightState(true)
end

function Role:LeaveFightState(...)
	Character.LeaveFightState(self, ...)
	self:ChangeFightState(false)
end

function Role:ChangeFightState(state)
	self.is_enter_fight = state
	self:ChangeYaoShi()
	self:ChangeTouShi()
	self:ChangeMask()
	self:ChangeCloak()
	if self.spirit_obj then
		self.spirit_obj:SetFightState(state)
	end
end

function Role:ApperanceShieldChanged()
	if self:IsMainRole() then
		return
	end
	if self.draw_obj then
		for _, part in pairs (VisibleApperance) do
			local is_shield = SettingData.Instance:GetApperanceSetting(RolePartApperanceSettingType[part])
			self.draw_obj:ShieldPart(part, is_shield)
		end
	end

	if self.spirit_obj then
		self.spirit_obj:ApperanceShieldChanged()
	end
end

-- 是否是主角的双骑伙伴
function Role:IsMainRoleParnter()
	local flag = false
	local role = self:GetMountParnterRole() or self:GetMountOwnerRole()
	if role and role:IsMainRole() then
		flag = true
	end
	return flag
end

-- 模型大小
function Role:InitModelSize()
	if nil == self.vo.model_size then
		return
	end
	self.draw_obj:GetRoot().transform.localScale = Vector3(self.vo.model_size / 100, self.vo.model_size / 100, self.vo.model_size / 100)
end

-- 模型隐身
function Role:InitModelTransparent()
	if nil == self.vo.is_invisible then
		return
	end

	if self.vo.is_invisible == 0 then 						-- 0代表可见，1代表不可见
		self:SetRoleVisible(self.role_temp_visible)
		self.draw_obj:SetVisible(self.role_is_visible)
		self:ShowFollowUi()
	elseif self.vo.is_invisible == 1 then
		self:SetRoleVisible(self.role_temp_visible)
		self.draw_obj:SetVisible(false)
		self:HideFollowUi()
	end
end

-- 改变模型大小
function Role:ChangeModelSize(size)
	if nil == size then
		return
	end
	self.draw_obj:GetRoot().transform.localScale = Vector3(size / 100, size / 100, size / 100)
end

-- 改变模型隐身
function Role:ChangeModelTransparent(state)
	if nil == state then
		return
	end

	self.vo.is_invisible = state
	if state == 0 then 						-- 0代表可见，1代表不可见
		self:SetRoleVisible(self.role_temp_visible)
		self.draw_obj:SetVisible(self.role_is_visible)
		self:ShowFollowUi()
	elseif state == 1 then
		self:SetRoleVisible(self.role_temp_visible)
		self.draw_obj:SetVisible(false)
		self:HideFollowUi()
	end
end