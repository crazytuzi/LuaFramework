Role = Role or BaseClass(Character)

local SHOW_BABY_TIMER = 5

function Role:__init(vo)
	self.obj_type = SceneObjType.Role
	self.draw_obj:SetObjType(self.obj_type)
	self.role_res_id = 0
	self.special_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.mount_res_id = 0
	self.halo_res_id = 0
	self.baoju_res_id = 0
	self.mantle_res_id = 0
	self.fazhen_res_id = ""
	self.hold_beauty_res_id = 0
	self.is_gather_state = false
	self.attack_index = 1
	self.role_is_visible = true
	self.goddess_obj = nil
	self.beauty_obj = nil
	self.baby_obj = nil
	self.mingjiang_obj = nil
	self.is_sit_mount = 0
	self.has_mount = false
	self.is_load_effect = false
	self.is_load_effect2 = false
	self.goddess_visible = true
	self.beauty_visible = true
	self.spirit_visible = true
	self.role_last_logic_pos_x = 0
	self.role_last_logic_pos_y = 0
	self.next_create_footprint_time = -1 			-- 下一次生成足迹的时间
	self.buff_list = {}
	self.is_war_scene_state = false					-- 是否是战场变身状态

	self.is_parnter = false
	self.on_multi_mount = 0
	self.multi_mount_owner_role = nil

	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.mask_res_id = 0

	self:UpdateAppearance()
	self:UpdateMount()
	self:UpdateFightMount()
	self:UpdateHoldBeauty()

	self.shield_spirit_helo = true --暂时屏蔽光环
	self.show_no_jump_flag = false

	self.is_need_stop_flush = false

	self.show_baby_timer = 0       -- 展示宝宝倒计时
	self.baby_visible = false 		
end

function Role:OnEnterScene()
	Character.OnEnterScene(self)
	self:GetFollowUi()
	self:CreateTitle()
	self:ChangeHuSong()
	self:ChangeGuildBattle()
	self:ChangeSpirit()
	self:ChangeGoddess()
	self:UpdateBoat()
	self:ChangeBeauty()
	self:UpdateRoleFaZhen()
	if self.follow_ui then
		self.follow_ui:SetSpecialImage(false)
	end
end

function Role:HideFollowUi()
end

function Role:ChangeFollowUiName(name)
	if name then
		self.vo.name = name
	end
	self:ReloadUIName()
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

	if self.goddess_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
		self.goddess_obj = nil
	end

	if self.beauty_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.BeautyObj, self.beauty_obj:GetObjKey())
		self.beauty_obj = nil
	end

	if self.baby_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Baby, self.baby_obj:GetObjKey())
		self.baby_obj = nil
	end

	if self.fight_mount_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.FightMount, self.fight_mount_obj:GetObjKey())
		self.fight_mount_obj = nil
	end

	if self.mingjiang_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.MingJiangObj, self.mingjiang_obj:GetObjKey())
		self.mingjiang_obj = nil
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
	self.buff_list = {}

	GlobalTimerQuest:CancelQuest(self.do_mount_up_delay)
	self:DestroyXiaMaEffect()
	self:RemoveXiamaDelay()
end

function Role:IsRole()
	return true
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

	if self.special_res_id ~= 0 and SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.vo.special_appearance then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMingJiangRes(self.special_res_id))
		return
	end

	if self.special_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
		return
	end
	self.draw_obj:GetPart(SceneObjPart.Main):EnableMountUpTrigger(false)

	-- if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_MONSTER_SIEGE_KING then
	-- 	local statue_id = CampData.Instance:GetOtherByStr("statue_id")
	-- 	if statue_id ~= nil then
	-- 		local statue_cfg = BossData.Instance:GetMonsterInfo(statue_id)
	-- 		if statue_cfg ~= nil and statue_cfg.resid ~= nil then
	-- 			local bundle, asset = ResPath.GetOtherModel(statue_cfg.resid)
	-- 			if self.follow_ui then
	-- 				self.follow_ui:SetHpVisiable(false)
	-- 				self.follow_ui:SetNameLocalPosition(0,200,0)
	-- 				self:GetFollowUi():SetIsShowGuildIcon(self.vo, false)
	-- 			end
	-- 			self:ChangeModel(SceneObjPart.Main, bundle, asset)
	-- 			return
	-- 		end
	-- 	end

	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_DAKUAFU_BOSS_ROLE then
		self.draw_obj:GetRoot().transform:SetLocalScale(1.5, 1.5, 1.5)
	end

	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_KING_STATUES 
		or self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_EMPEROR_STATUES
		or self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_MONSTER_SIEGE_KING then

		if self.follow_ui then
			self.follow_ui:SetHpVisiable(false)
			self.follow_ui:SetName("")
			-- self:GetFollowUi():SetIsShowGuildIcon(self.vo, false)
		end
		local model_id = CampData.Instance:GetOtherByStr("gw_resouce") or 50001001
		-- if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_KING_STATUES then
		-- 	model_id = 50002001
		-- end
		
		local func = function ()
			local model = self.draw_obj:GetRoot().transform:Find(model_id .. "(Clone)/ui/3DText")
			if model then
				
				local text_mesh = model:GetComponent(typeof(UnityEngine.TextMesh))
				if text_mesh then
					if self.vo.name == "" then
						text_mesh.text = Language.Common.XuWeiYiDai
					else
						local scene_logic = Scene.Instance:GetSceneLogic()
						local color_name = scene_logic:GetColorName(self)
						text_mesh.text = color_name
					end
				end
			end
		end

		local bundle, asset = ResPath.GetOtherModel(model_id)
		self:ChangeModel(SceneObjPart.Main, bundle, asset, func)
		self.beauty_visible = false
		return
	end

	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER then
		local singer_cfg = BrothelData.Instance:GetSingerShow(self.vo.pos_x, self.vo.pos_y)
		if singer_cfg ~= nil then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(singer_cfg.id))
			if singer_cfg.dance > 0 then
				self:CheckDanceState(singer_cfg.dance)
			end
		end

		self:GetFollowUi():Hide()
		return
	end

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

	if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id < 0 then
		self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
	end

	if self.mantle_res_id ~= nil and self.mantle_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 then
		self:ChangeModel(SceneObjPart.Mantle, ResPath.GetPifengModel(self.mantle_res_id))
	end

	if self.fight_mount_res_id ~= nil and self.fight_mount_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
	elseif self.mount_res_id ~= nil and self.mount_res_id ~= 0 then
		if self.is_sit_mount == 1 then
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.mount_res_id))
		else
			self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
		end

		if self.draw_obj ~= nil then
			self.draw_obj:SetIsFightMount(self.is_sit_mount == 1)
		end
	end

	if self:IsMultiMountPartner() then
		self.on_multi_mount = 0
	end

	if self.halo_res_id ~= nil and self.halo_res_id ~= 0 and fb_scene_cfg.pb_guanghuan ~= 1 then
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetHaloModel(self.halo_res_id))
	end

	if self.baoju_res_id ~= nil and self.baoju_res_id ~= 0 and fb_scene_cfg.pb_zhibao ~= 1 then
		self:ChangeModel(SceneObjPart.BaoJu, ResPath.GetHighBaoJuModel(self.baoju_res_id))
	end

	if nil ~= self.fazhen_res_id and self.fazhen_res_id ~= "" and fb_scene_cfg.pb_fazhen ~= 1 then
		self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetFaZhenModel(self.fazhen_res_id))
	end

	if self.hold_beauty_res_id > 0 then
		self:ChangeModel(SceneObjPart.HoldBeauty, ResPath.GetGoddessModel(self.hold_beauty_res_id))
	end

	self:CheckDanceState()
	self:ChangeYaoShi()
	self:ChangeTouShi()
	self:ChangeMask()
end

function Role:InitModel(bundle, asset)
	if AssetManager.Manifest ~= nil and not AssetManager.IsVersionCached(bundle) then
		local default_res_id = nil
		-- if self.vo.sex == 0 then
		-- 	default_res_id = "100" .. self.vo.prof .. "001"
		-- else
		-- 	default_res_id = "110" .. self.vo.prof .. "001"
		-- end

		default_res_id = "120" .. self.vo.prof .. "001"
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

Role.FootPrintCount = 0
function Role:CreateFootPrint()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg.pb_zuji and 1 == scene_cfg.pb_zuji then
		return
	end

	if not self:IsMainRole() and Role.FootPrintCount > 8 then
		return
	end
	Role.FootPrintCount = Role.FootPrintCount + 1

	local pos = self.draw_obj:GetRoot().transform.position
	local foot_id = self.vo.appearance.shengong_used_imageid
	if foot_id == 0 then return end
	local res_id = 1
	if foot_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		local special_cfg = ShengongData.Instance:GetSpecialImageCfg(foot_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
		res_id = special_cfg and special_cfg.res_id or 1
	end
	if foot_id <= 10 then
		local res_cfg = ShengongData.Instance:GetShengongImageCfg(foot_id)
		res_id = res_cfg and res_cfg.res_id or 1
	end
	if self.is_jump or pos == nil or res_id < 1 then return end

	local asset_name = "Foot_" .. res_id--足迹
	EffectManager.Instance:PlayControlEffect("effects2/prefab/footprint_prefab", asset_name, Vector3(pos.x, pos.y + 0.25, pos.z))

	GlobalTimerQuest:AddDelayTimer(function ()
		Role.FootPrintCount = Role.FootPrintCount - 1
	end, 1)
end

function Role:EnterStateAttack()
	local anim_name = SceneObjAnimator.Atk1
	local info_cfg = SkillData.GetSkillinfoConfig(self.attack_skill_id)
	if nil ~= info_cfg then
		anim_name = info_cfg.skill_action
		if info_cfg.hit_count > 1 then
			anim_name = anim_name.."_"..self.attack_index
		end

		if info_cfg.play_speed ~= nil then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			main_part:SetFloat(anim_name.."_speed", info_cfg.play_speed)
		end
	end
	Character.EnterStateAttack(self, anim_name)
end

function Role:EnterFightState()
	if self:IsMainRole() then
		MountCtrl.Instance:SendGoonMountReq(0)
		if nil ~= self.vo.mount_appeid and self.vo.mount_appeid > 0 then
			FightMountCtrl.Instance:SendGoonFightMountReq(1)
		end
	end
	Character.EnterFightState(self)
end

function Role:LeaveFightState()
	Character.LeaveFightState(self)
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

function Role:GetMantleResId()
	return self.mantle_res_id
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

function Role:SetIsGatherState(is_gather_state)
	self.is_gather_state = is_gather_state
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if is_gather_state then
		main_part:SetBool("fight", false) -- 采集时先退出战斗状态不然会出现滑步的情况
		main_part:SetInteger("status", ActionStatus.Gather)
	elseif self:IsStand() then
		main_part:SetInteger("status", ActionStatus.Idle)
	end
	if nil ~= self.mount_res_id and self.mount_res_id ~= "" and self.mount_res_id > 0 and nil == self.do_mount_up_delay then
		self.do_mount_up_delay = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnMountUpEnd,self), 0.1)
	end
end

function Role:GetIsGatherState()
	return self.is_gather_state
end

function Role:OnRealive()
	self:InitShow()
	self:ChangeSpirit()
	self:ChangeGoddess()
	self:OnFightMountUpEnd()
	self:ChangeBeauty()
end

function Role:OnDie()
	self:RemoveModel(SceneObjPart.Weapon)
	self:RemoveModel(SceneObjPart.Weapon2)
	self:RemoveModel(SceneObjPart.Wing)
	self:RemoveModel(SceneObjPart.Halo)
	self:RemoveModel(SceneObjPart.BaoJu)
	self:RemoveModel(SceneObjPart.FightMount)
	self:CheckDanceState()
	if self.spirit_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpiritObj, self.spirit_obj:GetObjKey())
		self.spirit_obj:RemoveModel(SceneObjPart.Main)
		self.spirit_obj:DeleteMe()
		self.spirit_obj = nil
	end

	if self.goddess_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
		self.goddess_obj = nil
	end

	if self.beauty_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.BeautyObj, self.beauty_obj:GetObjKey())
		self.beauty_obj = nil
	end

	if self.baby_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Baby, self.baby_obj:GetObjKey())
		self.baby_obj = nil
	end

	if self.mingjiang_obj then
		Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.MingJiangObj, self.mingjiang_obj:GetObjKey())
		self.mingjiang_obj = nil
	end
end

function Role:SetNoJumpStrFlag(value)
	self.show_no_jump_flag = value
end

function Role:GetNoJumpStrFlag()
	return self.show_no_jump_flag
end

function Role:SetAttr(key, value)
	Character.SetAttr(self, key, value)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local main_role = Scene.Instance:GetMainRole()
	if key == "prof" or key == "appearance" or key == "special_appearance" or key == "bianshen_param" 
		or key == "shengbing_image_id" or key == "shengbing_texiao_id" or key == "baojia_image_id" or key == "baojia_texiao_id" then
		if SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.vo.special_appearance then
			self:SetNoJumpStrFlag(true)
		end

		self:UpdateAppearance()
		self:UpdateBaoJu()
		self:UpdateMount()
		if self.vo.use_xiannv_id ~= nil and self.vo.use_xiannv_id > -1 then
			self:ChangeGoddess()
		end
		if self:CheckIsGeneral() then
			return
		end

		if self.special_res_id ~= 0 and (self.mount_res_id == 0 or self.mount_res_id == "") then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.special_res_id))
			self:RemoveModel(SceneObjPart.Weapon)
			self:RemoveModel(SceneObjPart.Weapon2)
			self:RemoveModel(SceneObjPart.Mantle)
			self:RemoveModel(SceneObjPart.Wing)
			self:RemoveModel(SceneObjPart.Halo)
			self:RemoveModel(SceneObjPart.BaoJu)
			return
		end
		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if self.role_res_id ~= 0 then
			local role_bundle, role_name = ResPath.GetRoleModel(self.role_res_id)
			self:ChangeModel(SceneObjPart.Main, role_bundle, role_name, function() self:CheckDanceState() end)
		end

		if self.weapon_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapon_res_id))
		else
			self:RemoveModel(SceneObjPart.Weapon)
		end

		if self.weapon2_res_id ~= 0 then
			self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapon2_res_id))
		end

		if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id < 0 then
			self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res_id))
		else
			self:RemoveModel(SceneObjPart.Wing)
		end

		if self.mantle_res_id ~= nil and self.mantle_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 then
			self:ChangeModel(SceneObjPart.Mantle, ResPath.GetPifengModel(self.mantle_res_id))
		end

		if self.halo_res_id ~= nil and self.halo_res_id ~= 0 and fb_scene_cfg.pb_guanghuan ~= 1 then
			self:ChangeModel(SceneObjPart.Halo, ResPath.GetHaloModel(self.halo_res_id))
		else
			self:RemoveModel(SceneObjPart.Halo)
		end

		if self.baoju_res_id ~= nil and self.baoju_res_id ~= 0 and fb_scene_cfg.pb_zhibao ~= 1 then
			self:ChangeModel(SceneObjPart.BaoJu, ResPath.GetHighBaoJuModel(self.baoju_res_id))
		else
			self:RemoveModel(SceneObjPart.BaoJu)
		end

		if nil ~= self.fazhen_res_id and self.fazhen_res_id ~= "" and fb_scene_cfg.pb_fazhen ~= 1 then
			self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetFaZhenModel(self.fazhen_res_id))
		end

		if self.vo.beauty_used_seq and self.vo.beauty_used_seq >= 0 and fb_scene_cfg.pb_god ~= 1 and self.beauty_visible then
			if self.beauty_obj ~= nil and key == "appearance" and value ~= nil then
				self.beauty_obj:SetAttr("beauty_used_halo_seq", value.jingling_guanghuan_imageid)
			end
		end

		if self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CAPTURE_CAPTIVE then
			IS_CARRY_BAG = true
			MountCtrl.Instance:SendGoonMountReq(0)

			local part = self.draw_obj:GetPart(SceneObjPart.Main)
			self:ChangeModel(SceneObjPart.Bag, ResPath.GetMonsterModel(1002001))
			self:RemoveModel(SceneObjPart.Wing)
			self:RemoveModel(SceneObjPart.Mantle)
			self:RemoveModel(SceneObjPart.Weapon)
			if part then
				part:SetInteger("status", ActionStatus.Carry)	
			end
		else
			IS_CARRY_BAG = false
			self:RemoveModel(SceneObjPart.Bag)
			local part = self.draw_obj:GetPart(SceneObjPart.Main)
			if part then
				part:SetInteger("status", ActionStatus.Idle)	
			end
		end


		local is_hide = SettingData.Instance:GetSettingList()[SETTING_TYPE.SHIELD_SPIRIT]

		self:ChangeSpiritHalo()
		self:ChangeSpiritFazhen()
		self:ChangeYaoShi()
		self:ChangeTouShi()
		self:ChangeMask()
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
		self:ReloadBanZhuanEff()
		self:ReloadCiTanEff()
	elseif key == "husong_taskid" or key == "husong_color" then
		self:ChangeHuSong()
	elseif key == "hp" or key == "max_hp" then
		if ScoietyData.Instance and ScoietyData.Instance:GetTeamState() then
			ScoietyData.Instance:ChangeTeamList(self.vo)
			GlobalEventSystem:Fire(ObjectEventType.TEAM_HP_CHANGE, self.vo)
		end
		self:SyncShowHp()
	elseif key == "special_param" then
		self:ChangeGuildBattle()
		self:ChangeFollowUiName()
		self:UpdateBoat()
	elseif key == "used_sprite_id" or key == "sprite_name" then
		self:ChangeSpirit()
	elseif key == "use_xiannv_id" or key == "xiannv_huanhua_id" then
		self:ChangeGoddess()
	elseif key == "hold_beauty_npcid" then
		self:UpdateHoldBeauty()
		local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)

		if self.hold_beauty_res_id > 0 then
			self:ChangeModel(SceneObjPart.HoldBeauty, ResPath.GetGoddessModel(self.hold_beauty_res_id))
			if main_part then
				main_part:SetInteger("status", ActionStatus.Hug)
			end
			if holdbeauty_part then
				holdbeauty_part:SetInteger("status", ActionStatus.Hug)
			end
		else
			self:RemoveModel(SceneObjPart.HoldBeauty)
			if main_part then
				main_part:SetInteger("status", ActionStatus.Idle)
			end
			if holdbeauty_part then
				holdbeauty_part:SetInteger("status", ActionStatus.Idle)
			end
		end
	elseif key == "beauty_used_seq" or key == "beauty_used_huanhua_seq" or key == "beauty_is_active_shenwu" or key == "beauty_used_halo_seq" then
		local beauty_obj = self:GetBeautyObj()
		if beauty_obj then
			beauty_obj:SetAttr(key, value)
		else
			self:ChangeBeauty()
		end
	elseif key == "xiannv_name" then
		local goddess_obj = self:GetGoddessObj()
		if goddess_obj then
			goddess_obj:SetAttr("name", value)
			goddess_obj:GetFollowUi()
		end
	elseif key == "millionare_type" then
		if self.vo.millionare_type and self.vo.millionare_type > 0 then
			self:GetFollowUi():SetDaFuHaoIconState(false)		-- 策划需求
		else
			self:GetFollowUi():SetDaFuHaoIconState(false)
		end
	elseif key == "guild_name" then
		self:ReloadUIGuildName()
		self:UpdateTitle()
	elseif key == "lover_name" then
		self:ReloadUILoverName()
		self:UpdateTitle()
	elseif key == "wuqi_color" or key == "total_strengthen_level" then
		self:EquipDataChangeListen()
	elseif key == "name_color" or key == "is_neijian" then
		self:ChangeFollowUiName()
	elseif key == "top_dps_flag" or 
		key == "first_hurt_flag" then
		self:ReloadSpecialImage()
	elseif key == "vip_level" and self.follow_ui then
		self.follow_ui:SetVipIcon(self)
	elseif key == "banzhuan_color" then
		self:ReloadUILoverName()
		self:UpdateTitle()
		self:ReloadBanZhuanEff()
	elseif key == "citan_color" then
		self:ReloadUILoverName()
		self:UpdateTitle()
		self:ReloadCiTanEff()
	elseif key == "halo_lover_uid" then
		-- print_error("halo_lover_uid", value, self.vo.role_id)
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

	-- 暂时屏蔽人物移动改变移动速度频率
	-- elseif key == "move_speed" then
		-- self:UpdateMainRoleMoveSpeed()
	elseif key == "baojia_id" then
		if value ~= nil then
			self.vo.baojia_speical_image_id = value or 0
			self:CheckDanceState()
		end
	elseif key == "touxian_level" then
		self:ChangeFollowUiName()
	elseif key == "change_camp" then
		if value ~= nil then
			self.vo.camp = value
		end
		self:ChangeFollowUiName()
	elseif key == "junxian_level" then
		self:ChangeFollowUiName()
	elseif key == "set_baby_id" then
		self.vo.baby_id = value
		
		if self.baby_visible then
			if value == -1 then
				if self.baby_obj then
					Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Baby, self.baby_obj:GetObjKey())
					self.baby_obj = nil
				end					
			else
				if self.show_baby_timer >= SHOW_BABY_TIMER then
					local baby_obj = self:GetBabyObj()
					if baby_obj then
						baby_obj:SetAttr(key, value)
					else
						self.show_baby_timer = 0
						self.baby_visible = false
						--self:ChangeBaby()
					end
				end
			end
		end	
	end
end

function Role:UpdateMainRoleMoveSpeed()
	-- 设置人物模型移动速度
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if main_part then
		local speed = Scene.ServerSpeedToClient(self.vo.move_speed)
		local move_speed_type = 1
		if (self.vo.mount_appeid and self.vo.mount_appeid > 0) or (self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0) then
			move_speed_type = Config.SCENE_MOUNT_MOVE_SPEED
		else
			move_speed_type = Config.SCENE_ROLE_MOVE_SPEED
		end
		local role_move_speed = speed / Scene.ServerSpeedToClient(move_speed_type)
		main_part:SetFloat("speed", role_move_speed)
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
		if self.draw_obj ~= nil then
			self.draw_obj:SetIsFightMount(self.is_sit_mount == 1)
		end

		self:RemoveModel(SceneObjPart.FightMount)
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
		if self.role_res_id ~= 0 then
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

		if self.draw_obj ~= nil then
			self.draw_obj:SetIsFightMount(self.is_sit_mount == 1)
		end

		if self.is_sit_mount == 1 then
			self:RemoveModel(SceneObjPart.FightMount)
			self:RemoveModel(SceneObjPart.Mount)
			self.is_sit_mount = 0
		else
			self:RemoveMonutWithFade()
		end
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
		self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
		if self.role_res_id ~= 0 then
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
	end
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

function Role:UpdateMantleResId()
	local index = self.vo.appearance.shenyi_used_imageid or 0
	local mantle_config = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	self.mantle_res_id = 0
	if mantle_config and fb_scene_cfg.pb_wing ~= 1 then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = mantle_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = mantle_config.image_list[index]
		end
		if image_cfg then
			self.mantle_res_id = image_cfg.res_id
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
	self.special_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
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

		if vo.appearance.body_use_type == APPEARANCE_BODY_USE_TYPE.APPEARANCE_BODY_USE_TYPE_SHENQI then 		-- 神器衣服形象
			if ShenqiData.Instance then
				local data = {baojia_img_id = vo.appearance.baojia_image_id, prof = vo.prof, sex = vo.sex}
				local res_id = ShenqiData.Instance:GetDataBaojiaResCfgByIamgeID(data)
				self.role_res_id = res_id
			end
		end

		if vo.appearance.wuqi_use_type == APPEARANCE_USE_TYPE.APPEARANCE_WUQI_USE_TYPE_SHENQI then 			-- 神器武器形象
			if ShenqiData.Instance then
				local data = {shengbing_img_id = vo.appearance.shengbing_image_id, prof = vo.prof, sex = vo.sex}
				self.weapon_res_id = ShenqiData.Instance:GetDataResCfgByIamgeID(data)
			end
		end

		self:UpdateWingResId()
		self:UpdateMantleResId()
		self:UpdateHaloResId()
		self:UpdateBaoJu()
		self:UpdateRoleFaZhen()
		self:UpdateWaist()
		self:UpdateTouShi()
		self:UpdateMask()
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

	if self.vo.bianshen_param ~= "" and self.vo.bianshen_param ~= 0 then
		if self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_MOJIE_GUAIWU then
			self.special_res_id = 2127001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOTU then
			self.special_res_id = 7212001
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOZHU then
			self.special_res_id = 7212001
		-- elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOZHU then
		-- 	local cur_use_id = FamousGeneralData.Instance:GetResIdBySeq(FamousGeneralData.Instance:GetCurUseSeq())
		-- 	self.mingjiang_res_id = cur_use_id
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.vo.special_appearance then
		self.special_res_id = self.vo.appearance_param
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
			self.role_res_id = 1201012
		else
			self.role_res_id = 1202012
		end
		self.weapon_res_id = 950101201

	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CROSS_FISHING == self.vo.special_appearance then
		self.weapon_res_id = 0
		local fishing_other_cfg = FishingData.Instance:GetFishingOtherCfg()
		self.role_res_id = fishing_other_cfg["resource_id_" .. sex] or self.role_res_id

	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_HUNYAN == self.vo.special_appearance then
		local fashion_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
		local model_data =  MarriageData.Instance:GetModelCfgById(prof)
		local wuqi_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.WUQI, model_data.weapon_model)
		if wuqi_cfg then
			local index = string.format("resouce%s%s", prof, sex)
			self.weapon_res_id = wuqi_cfg[index]
		end
		local body_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.BODY, model_data.role_model)
		if body_cfg then
			local index = string.format("resouce%s%s", prof, sex)
			self.role_res_id = body_cfg[index]
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_SHNEQI == self.vo.special_appearance then
		--self.special_res_id = 7215001
		if self.vo.appearance_param ~= nil and self.vo.appearance_param > 0 then
			--local head_bundle, head_name = ResPath.GetHeadModel(1210)
			local head_id = ShenqiData.Instance:GetHeadResId(self.vo.appearance_param)
			if head_id ~= nil then
				self:ChangeModel(SceneObjPart.Head, ResPath.GetHeadModel(head_id))
			end
		end
	elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_BIANSHEN == self.vo.special_appearance then
		MountCtrl.Instance:SendGoonMountReq(0)
		
		local war_scene_cfg = SkillData.Instance:GetWarSceneOtherCfg()
		if war_scene_cfg.model_res then
			self.special_res_id = war_scene_cfg.model_res
		end
	end

	if SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_SHNEQI ~= self.vo.special_appearance then
		if self.draw_obj ~= nil then
			local part = self.draw_obj:GetPart(SceneObjPart.Head)
			part:RemoveModel()
		end
	end

	if self:IsMainRole() then
		local value = false
		if SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_NORMAL == self.vo.special_appearance then
			value = false
		elseif SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_BIANSHEN == self.vo.special_appearance then
			value = true
		end

		self:SetWarSceneState(value)
	end
end

function Role:UpdateMount()
	local vo = self.vo
	self.mount_res_id = 0
	if self.vo.multi_mount_res_id >= 0 then
		local multi_cfg = nil
		local all_cfg = ConfigManager.Instance:GetAutoConfig("multi_mount_auto").mount_info
		for k,v in pairs(all_cfg) do
			if v.mount_id == self.vo.multi_mount_res_id then
				multi_cfg = v
				break
			end
		end
		--self.mount_res_id = self.vo.multi_mount_res_id
		if multi_cfg ~= nil then
			self.mount_res_id = multi_cfg.res_id
			if self:IsMultiMountPartner() then
				self.is_sit_mount = multi_cfg.sit_2
			else
				self.is_sit_mount = multi_cfg.sit_1
			end
		end

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

	if nil ~= image_cfg then
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

	if nil ~= image_cfg then
		self.fight_mount_res_id = tonumber(image_cfg.res_id) or 0
	end

	if self:CheckIsGeneral() then
		self.fight_mount_res_id = 0
	end
end

function Role:UpdateBaoJu()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.appearance.jingling_fazhen_imageid and self.vo.appearance.jingling_fazhen_imageid > 0 and fb_scene_cfg.pb_zhibao ~= 1 then
		if not HalidomData.Instance then return end
		if self.vo.appearance.jingling_fazhen_imageid < 1000 then  -- 大于1000特殊形象
			self.baoju_res_id = HalidomData.Instance:GetNormalResId(self.vo.appearance.jingling_fazhen_imageid)
			-- if self.baoju_res_id > 13014 then
			-- 	self.baoju_res_id = 13014
			-- end
		else
			self.baoju_res_id = HalidomData.Instance:GetSpecialResId(self.vo.appearance.jingling_fazhen_imageid - 1000)
			-- if self.baoju_res_id > 13014 then
				-- self.baoju_res_id = 13014
			-- end
		end
	end
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
				Scene.Instance:CreateBoatByCouple(self:GetObjId(), special_param, obj)
			else
				Scene.Instance:CreateBoatByCouple(self:GetObjId(), special_param, self)
			end
		else
			Scene.Instance:DeleteBoatByRole(self:GetObjId())
		end
	end
end

function Role:UpdateHoldBeauty()
	self.hold_beauty_res_id = 0
	local npc_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.vo.hold_beauty_npcid]
	if npc_cfg then
		if npc_cfg.beauty_res and npc_cfg.beauty_res ~= "" and npc_cfg.beauty_res > 0 then
			self.hold_beauty_res_id = npc_cfg.beauty_res
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

	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_DAKUAFU_BOSS_ROLE and self.vo.used_title ~= nil and self.vo.used_title > 0 then
		self:GetFollowUi():SetTitle(1, self.vo.used_title)
	end

	self:InspectTitleLayerIsShow()
end

function Role:IsRoleVisible()
	return self.role_is_visible
end

function Role:SetRoleVisible(is_visible)
	self.draw_obj:SetVisible(is_visible)
	self.role_is_visible = is_visible
	self:SetTitleVisible(is_visible)
	self:SetGoddessVisible(is_visible and self.goddess_visible, true)
	self:SetSpriteVisible(is_visible and self.spirit_visible)
	self:SetBeautyVisible(is_visible)
	self:SetFollowIsShow(is_visible)
end

function Role:SetGoddessVisible(is_visible, is_all)
	if is_all ~= true  then
		self.goddess_visible = is_visible
	end
	if self.vo.husong_color ~= 0 then
		if is_visible then
			self.goddess_visible = false
			return
		end
	end
	local goddess_obj = self:GetGoddessObj()
	if goddess_obj then
		goddess_obj:SetGoddessVisible(is_visible and self.role_is_visible)
	elseif is_visible and self.role_is_visible then
		self:ChangeGoddess()
	end
end

function Role:SetSpriteVisible(is_visible)
	self.spirit_visible = is_visible
	if self.vo.husong_color ~= 0 then
		if is_visible then
			self.spirit_visible = false
			return
		end
	end
	if self.spirit_obj then
		self.spirit_obj:SetSpiritVisible(is_visible and self.role_is_visible)
	elseif is_visible and self.role_is_visible then
		self:ChangeSpirit()
	end
end

function Role:SetBeautyVisible(is_visible)
	local shield_friend = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
	local shield_goddess = SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	if shield_friend or shield_goddess then
		is_visible = false
	end
	if self.beauty_obj then
		self.beauty_obj:SetBeautyVisible(is_visible)
	end

	if self.baby_obj then
		self.baby_obj:SetBabyVisible(is_visible)
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

	if self.vo.first_hurt_flag and self.vo.first_hurt_flag > 0 then
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

	local citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	if citan_list ==  nil then return end
	local color = citan_list.cur_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					citan_list.cur_qingbao_color or citan_list.get_qingbao_color
	local citan_color = self:IsMainRole() and color or self:GetVo().citan_color

	local banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	local color = banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					banzhuan_list.cur_color or banzhuan_list.get_color
	local banzhuan_color = self:IsMainRole() and color or self:GetVo().banzhuan_color

	if citan_color > 0 or banzhuan_color > 0 then
		flag = false
	end

	self:GetFollowUi():SetTitleVisible(flag)
end

function Role:ChangeHuSong()
	if self.vo.husong_taskid ~= 0 and self.vo.husong_color ~= 0 then
		if self:IsMainRole() then
			MainUICtrl.Instance:ShowHuSongButton(true)
			MountCtrl.Instance:SendGoonMountReq(0)
			FightMountCtrl.Instance:SendGoonFightMountReq(0)
		end
		if not self.truck_obj then
			self.truck_obj = Scene.Instance:CreateTruckObjByRole(self)
		end
		-- local str = "hu_" .. self.vo.husong_color
		-- self:GetFollowUi():ChangeSpecailTitle(str)
		-- 屏蔽女神和精灵
		self:SetBeautyVisible(false)
		self:SetSpriteVisible(false)
	else
		if self:IsMainRole() then
			MainUICtrl.Instance:ShowHuSongButton(false)
		end
		if self.truck_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.TruckObj, self.truck_obj:GetObjKey())
			self.truck_obj = nil
		end
		self:GetFollowUi():ChangeSpecailTitle(nil)
		-- 还原女神和精灵
		local flag = SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_GODDESS) or false
		if SettingData.Instance:IsShieldOtherRole(Scene.Instance:GetSceneId()) then
			flag = true
		end
		self:SetBeautyVisible(not flag)
		flag = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SPIRIT) or false
		self:SetSpriteVisible(not flag)
	end
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
			local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.vo.used_sprite_id)
			if spirit_cfg and  spirit_cfg.res_id and spirit_cfg.res_id > 0 then
				self.spirit_obj:SetObjId(self.vo.used_sprite_id)
				self.spirit_obj:ChangeModel(SceneObjPart.Main, ResPath.GetSpiritModel(spirit_cfg.res_id))
				self.spirit_obj:SetSpiritName(self.vo.sprite_name)
			end
			call_back()
		end
	else
		if self.spirit_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.SpiritObj, self.spirit_obj:GetObjKey())
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

function Role:ChangeGoddess()
	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_KING_STATUES 
		or self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_EMPEROR_STATUES
		or self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_MONSTER_SIEGE_KING then

		if self.goddess_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.GoddessObj, self.goddess_obj:GetObjKey())
			self.goddess_obj = nil
		end		

		return
	end

	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if self.vo.use_xiannv_id and self.vo.use_xiannv_id >= 0 and fb_scene_cfg.pb_god ~= 1 and self.goddess_visible then
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

function Role:ChangeBeauty()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()

	local is_shadow = false
	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER
	or self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_DAKUAFU_BOSS_ROLE then
		is_shadow = true
	end

	if self.vo.beauty_used_seq and self.vo.beauty_used_seq >= 0 and fb_scene_cfg.pb_god ~= 1 and self.beauty_visible and not is_shadow then
		if not self.beauty_obj then
			self.beauty_obj = Scene.Instance:CreateBeautyObjByRole(self)
		else
			self.beauty_obj:SetAttr("beauty_used_seq", self.vo.beauty_used_seq)
			self.beauty_obj:SetAttr("beauty_is_active_shenwu", self.vo.beauty_is_active_shenwu)
			self.beauty_obj:SetAttr("beauty_used_huanhua_seq", self.vo.beauty_used_huanhua_seq)
			self.beauty_obj:SetAttr("beauty_used_halo_seq")
		end
	else
		if self.beauty_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.BeautyObj, self.beauty_obj:GetObjKey())
			self.beauty_obj = nil
		end
	end
end

function Role:ChangeBaby()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()

	local is_shadow = false
	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER
	or self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_DAKUAFU_BOSS_ROLE then
		is_shadow = true
	end

	if self.vo.baby_id and self.vo.baby_id >= 0 and fb_scene_cfg.pb_god ~= 1 and self.beauty_visible and not is_shadow and self.baby_visible then
		if not self.baby_obj then
			self.baby_obj = Scene.Instance:CreateBabyObjByRole(self)
		else
			self.baby_obj:SetAttr("set_baby_id", self.vo.baby_id)
		end
	else
		if self.baby_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Baby, self.baby_obj:GetObjKey())
			self.baby_obj = nil
		end		
	end
end

function Role:ChangeMingJiang(task_id)
	if TaskData.Instance:GetTaskIsAccepted(task_id) then
		if not self.mingjiang_obj and self:IsMainRole() then
			self.mingjiang_obj = Scene.Instance:CreateMingjiangObjByRole(self)
		end
	else
		if self.mingjiang_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.MingJiangObj, self.mingjiang_obj:GetObjKey())
			self.mingjiang_obj = nil
		end
	end
end

function Role:ChangeYaoShi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_yaoshi == 1 or self.special_res_id > 0 or self.waist_res_id <= 0 then
		self:RemoveModel(SceneObjPart.Waist)
		return
	end

	self:ChangeModel(SceneObjPart.Waist, ResPath.GetWaistModel(self.waist_res_id))
end

function Role:ChangeTouShi()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_toushi == 1 or self.special_res_id > 0 or self.toushi_res_id <= 0 then
		self:RemoveModel(SceneObjPart.TouShi)
		return
	end

	self:ChangeModel(SceneObjPart.TouShi, ResPath.GetTouShiModel(self.toushi_res_id))
end

function Role:ChangeMask()
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_mask == 1 or self.special_res_id > 0 or nil == self.vo or self.mask_res_id <= 0 then
		self:RemoveModel(SceneObjPart.Mask)
		return
	end
	self:ChangeModel(SceneObjPart.Mask, ResPath.GetMaskModel(self.mask_res_id))
end

function Role:CreateFollowUi()
	self.follow_ui = RoleFollow.New()
	self.follow_ui:Create(SceneObjType.Role)
	if self.draw_obj then
		local point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
		self.follow_ui:SetFollowTarget(point)
	end

	self.follow_ui:SetIsCanShow(true)
	self:SyncShowHp()
end

function Role:GetGoddessObj()
	return self.goddess_obj
end

function Role:GetBeautyObj()
	return self.beauty_obj
end

function Role:GetMingjaingObj()
	return self.mingjiang_obj
end

function Role:GetBabyObj()
	return self.baby_obj
end

function Role:ReloadUIName()
	if self.follow_ui ~= nil then
		local scene_logic = Scene.Instance:GetSceneLogic()
		local color_name = scene_logic:GetColorName(self)
		-- if self:IsMainRole() then
			color_name = ToColorStr(color_name, TEXT_COLOR.YELLOW)
		-- end
		---local cur_level = MilitaryRankData.Instance:GetCurLevel()
		local cur_level = self.vo.junxian_level
		if cur_level ~= nil and cur_level > 0 then
			local data = MilitaryRankData.Instance:GetLevelSingleCfg(cur_level)
			if data ~= nil and data.name ~= nil then
				local military_str = ToColorStr(data.name, CAMP_COLOR[self.vo.camp])
				color_name = color_name .. "[" .. military_str .. "]"
			end
		end
		self.follow_ui:SetName(color_name, self)
		self:ReloadUIGuildName()
		self:ReloadUILoverName()
		self:ReloadSpecialImage()
		self:ReloadBanZhuanEff()
		self:ReloadCiTanEff()
		self.follow_ui:SetVipIcon(self)
		self:SetGuildIcon()
		self:GetFollowUi():SetIsShowGuildIcon(self.vo, Scene.Instance:GetCurFbSceneCfg().guild_badge == 0) --0显示公会头像
	end
end

function Role:ReloadUIGuildName()
	if self.follow_ui ~= nil then
		local guild_id = self:GetVo().guild_id
		local touxian_level = self:GetVo().touxian_level
		local touxian_name = ""
		if touxian_level > 0 then
			local level_cfg = TouXianData.Instance:GetConfigByLevel(touxian_level)
			if next(level_cfg) then
				touxian_name = "[" .. ToColorStr(level_cfg.title_name, level_cfg.scene_color) .. "]"
			end
		end
		if guild_id > 0 then
			local guild_name = self:GetVo().guild_name
		
			guild_name = guild_name
			local post = GuildData.Instance:GetGuildPostNameByPostId(self:GetVo().guild_post)
			if post then
				guild_name = guild_name .. post
			end
			guild_name = ToColorStr(guild_name, GUILD_NAME_COLOR[self:GetVo().guild_post] or COLOR.GREEN)
			self.follow_ui:SetGuildName(touxian_name .. guild_name)
		else
			self.follow_ui:SetGuildName(touxian_name)
		end
	end
end

function Role:ReloadUILoverName()
	if self.follow_ui ~= nil then
		local lover_name = self:GetVo().lover_name
		if lover_name and lover_name ~= "" then
			lover_name = ToColorStr(lover_name, TEXT_COLOR.YELLOW)
			lover_name = lover_name .. (Language.Marriage.LoverNameFormat[self:GetVo().sex])
			self.follow_ui:SetLoverName(lover_name, self)
		else
			self.follow_ui:SetLoverName()
		end
	end
end

function Role:ReloadSpecialImage()
	local scene_logic = Scene.Instance:GetSceneLogic()
	local is_show_special_image, asset, bundle = scene_logic:GetIsShowSpecialImage(self)

	if self.vo.top_dps_flag and self.vo.top_dps_flag > 0 then
		is_show_special_image, asset, bundle = true, ResPath.GetDpsIcon()
	end

	if self.vo.first_hurt_flag then
		if self.vo.first_hurt_flag > 0 then
			is_show_special_image, asset, bundle = true, ResPath.GetBoss("first_hurt_flag")
		end
		self:InspectTitleLayerIsShow()
	end

	if self.follow_ui then
		self.follow_ui:SetSpecialImage(is_show_special_image, asset, bundle)
	end
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
				local call_back = function()
					if mount_part then
						GlobalTimerQuest:AddDelayTimer(function()
							mount_part:RemoveOcclusion()
							mount_part:AddOcclusion()
						end, 0)
					end
				end
				self:PlayMountFade(1, 1, call_back)
			end
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
		if boat_obj then
			self.draw_obj:GetPart(SceneObjPart.Main):SetInteger("status", ActionStatus.Die)
			local point = boat_obj:GetBoatAttachPoint(self:GetObjId())
			if point then
				obj.gameObject.transform:SetParent(point, false)
				obj.gameObject.transform:SetLocalPosition(0, 0, 0)
				obj.gameObject.transform.rotation = Vector3(0, 0, 0)
				obj.gameObject.transform:SetLocalScale(1, 1, 1)			
			end
		end
	end
	if self.vo.shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_KING_STATUES then
		obj.gameObject.transform:SetLocalScale(0.8, 0.8, 0.8)		
	end
end

function Role:SetFollowLocalPosition(high)
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

function Role:SetFollowIsShow(is_visible)
	local follow_ui = self:GetFollowUi()

	local settingData = SettingData.Instance
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)

	local is_show = ((shield_others or (shield_friend and not Scene.Instance:IsEnemy(self))) and not self:IsMainRole())
	if is_visible == false and is_show then
		is_visible = false
	end

	if follow_ui then
		follow_ui:SetIsShow(not is_visible)
		if is_visible or follow_ui:GetIsCanShowUi() then
			follow_ui:Show()
			if self.draw_obj then
				follow_ui:SetFollowTarget(self.draw_obj:GetTransfrom())
			end
		else
			follow_ui:Hide()
		end
	end
end

-- 带渐变效果移除坐骑
function Role:RemoveMonutWithFade()
	if not self:IsMainRole() then
		self:RemoveModel(SceneObjPart.Mount)
		return
	end

	-- 坐骑渐变
	local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	if nil ~= mount_part and mount_part:GetObj() then
		mount_part:Reset()
		local obj = mount_part:GetObj()
		if mount_part.remove_callback ~= nil then
			mount_part.remove_callback(obj)
			mount_part.remove_callback = nil
		end
		local call_back = function() mount_part:RemoveModel() mount_part:DeleteMe() end
		if CgManager.Instance:IsCgIng() then
			call_back()
			self.draw_obj.part_list[SceneObjPart.Mount] = nil
			return
		end
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
			if call_back then
				call_back()
			end
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
			if call_back then
				call_back()
			end
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
		anim:SetInteger("status", ActionStatus.Run)
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

function Role:CheckIsGeneral()
	if self.special_res_id ~= 0 and SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.vo.special_appearance then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMingJiangRes(self.special_res_id))
		self:RemoveModel(SceneObjPart.Weapon)
		self:RemoveModel(SceneObjPart.Weapon2)
		self:RemoveModel(SceneObjPart.Wing)
		self:RemoveModel(SceneObjPart.Halo)
		self:RemoveModel(SceneObjPart.BaoJu)
		self:RemoveModel(SceneObjPart.FightMount)
		self:RemoveModel(SceneObjPart.Mount)
		self:RemoveModel(SceneObjPart.Mantle)
		return true
	end
	return false
end

function Role:AddBuff(buff_type, time)
	Character.AddBuff(self, buff_type)
	if time and time > TimeCtrl.Instance:GetServerTime() and nil == self.buff_list[buff_type] then
		self.buff_list[buff_type] = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.RemoveBeautyBuff, self, buff_type), time - TimeCtrl.Instance:GetServerTime())
	end
end

function Role:RemoveBeautyBuff(buff_type)
	self:RemoveBuff(buff_type)
	if self.buff_list[buff_type] then
		GlobalTimerQuest:CancelQuest(self.buff_list[buff_type])
		self.buff_list[buff_type] = nil
	end
end

function Role:UpdateRoleFaZhen()
	local image_id = self.vo.appearance and self.vo.appearance.fazhen_image_id or 0
	if image_id > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = ConfigManager.Instance:GetAutoConfig("fazhen_cfg_auto").special_img[image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET]
	else
		image_cfg = ConfigManager.Instance:GetAutoConfig("fazhen_cfg_auto").image_list[image_id]
	end
	if image_cfg then
		self.fazhen_res_id = image_cfg.res_id
	end
end

function Role:UpdateWaist()
	--腰饰
	local waist_id = self.vo.appearance.ugs_waist_img_id or 0
	if WaistData.Instance then
		if waist_id > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			self.waist_res_id = WaistData.Instance:GetSpecialResId(waist_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
		elseif waist_id > 0 then
			self.waist_res_id = WaistData.Instance:GetResIdByImgId(waist_id)
		end
	end
end

function Role:UpdateTouShi()
	--头饰
	local toushi_id = self.vo.appearance.ugs_head_wear_img_id or 0
	if HeadwearData.Instance then
		if toushi_id > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			self.toushi_res_id = HeadwearData.Instance:GetSpecialResId(toushi_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
		elseif toushi_id > 0 then
			self.toushi_res_id = HeadwearData.Instance:GetResIdByImgId(toushi_id)
		end
	end
end

function Role:UpdateMask()
	--面饰
	local mask_id = self.vo.appearance.ugs_mask_img_id or 0
	if MaskData.Instance then
		if mask_id > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			self.mask_res_id = MaskData.Instance:GetSpecialResId(mask_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
		elseif mask_id > 0 then
			self.mask_res_id = MaskData.Instance:GetResIdByImgId(mask_id)
		end
	end
end


-- 隐藏公会图标
function Role:SetRoleGuildIconValue()
	if self.follow_ui then
		self.follow_ui:SetRoleGuildIconValue()
	end
end

-- 刷新设置公会图标
function Role:SetGuildIcon()
	if self.follow_ui then
		self.follow_ui:SetGuildIcon(self)
	end
end

function Role:ReloadBanZhuanEff()
	local banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	local color = banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					banzhuan_list.cur_color or banzhuan_list.get_color
	local banzhuan_color = self:IsMainRole() and color or self:GetVo().banzhuan_color
	local title_id = self:IsMainRole() and TitleData.Instance:GetUsedTitle() or self:GetVo().used_title_list[1]
	local is_use_title = false
	if title_id then
		is_use_title = title_id > 0
	end
	self:SetTitleVisible(banzhuan_color <= 0)
	if self.follow_ui then
		self.follow_ui:ShowBanZhuanEff(banzhuan_color, is_use_title)

		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if fb_scene_cfg.citan_icon then
			self.follow_ui:SetCampWarEffVisiable(fb_scene_cfg.citan_icon == 0)
		end
	end
end

function Role:ReloadCiTanEff()
	local citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	if citan_list == nil then return end
	local color = citan_list.cur_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					citan_list.cur_qingbao_color or citan_list.get_qingbao_color
	local citan_color = self:IsMainRole() and color or self:GetVo().citan_color
	local title_id = self:IsMainRole() and TitleData.Instance:GetUsedTitle() or self:GetVo().used_title_list[1]
	local is_use_title = false
	if title_id then
		is_use_title = title_id > 0
	end
	self:SetTitleVisible(citan_color <= 0)
	if self.follow_ui then
		self.follow_ui:ShowCiTanEff(citan_color, is_use_title)

		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if fb_scene_cfg.citan_icon then
			self.follow_ui:SetCampWarEffVisiable(fb_scene_cfg.citan_icon == 0)
		end
	end
end

function Role:SetRoleEffect(bundle, asset, duration, position, rotation, scale)
	if self.draw_obj then
		local transform = self.draw_obj:GetTransfrom()
		PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
			if nil == prefab then
				return
			end
			if transform then
				local obj = GameObject.Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(transform, false)
				PrefabPool.Instance:Free(prefab)

				GlobalTimerQuest:AddDelayTimer(function()
					GameObjectPool.Instance:Free(obj)
				end, duration)
			end
		end)
	end
end

function Role:CheckDanceState(dance_id)
	local show_dance = dance_id or self.vo.baojia_speical_image_id

	if self:IsDead() then
		show_dance = 0.0
	end

	for i = 1, 6 do
		if i ~= 4 then
			local value = show_dance == i and 1.0 or 0.0
			local layer = 8 + i
			if self.mount_res_id > 0 or self.special_res_id ~= 0 then
				value = 0
			end

			if self.draw_obj then
				self.draw_obj:GetPart(SceneObjPart.Main):SetLayer(layer, value)
			end
		end
	end
end

function Role:IsWarSceneState()
	return self.is_war_scene_state
end

function Role:SetWarSceneState(value)
	self.is_war_scene_state = value
end

------------------------双人坐骑-------------------------------------
function Role:SetMultiMountIdAndOnwerFlag(multi_mount_res_id, multi_mount_is_owner, multi_mount_other_uid)
	local is_parnter = self.is_parnter
	local old_multi_mount_res_id = self.vo.multi_mount_res_id

	self.vo.multi_mount_res_id = multi_mount_res_id
	self.vo.multi_mount_is_owner = multi_mount_is_owner
	self.vo.multi_mount_other_uid = multi_mount_other_uid
	--有双人坐骑不显示羽翼
	if self.vo.multi_mount_res_id >= 0 then
		self:RemoveModel(SceneObjPart.Wing)
		self.is_sit_mount, self.is_sit_mount2 = MultiMountData.Instance:GetMultiMountSitTypeByResid(multi_mount_res_id)
	--下双人坐骑时恢复
	elseif old_multi_mount_res_id >= 0 then
		local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if self.wing_res_id ~= nil and self.wing_res_id ~= 0 and fb_scene_cfg.pb_wing ~= 1 and self.vo.multi_mount_res_id < 0 then
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

function Role:DoMove(pos_x, pos_y)
	if not self.is_parnter then
		Character.DoMove(self, pos_x, pos_y)
	else
		-- self:SetRealPos(pos_x, pos_y)
	end

	-- if not self.is_need_stop_flush then
	-- 	self.on_multi_mount = 0
	-- 	self.is_need_stop_flush = true
	-- end
end

function Role:SetDirectionByXY(x, y)
	if not self.is_parnter then
		Character.SetDirectionByXY(self, x, y)
	end
end

function Role:GetMountOwnerRole()
	if self.vo.multi_mount_is_owner == 0 and (self.mount_other_objid ~= nil and self.mount_other_objid >= 0) then
		local owner_role = self.parent_scene:GetRoleByObjId(self.mount_other_objid)
		if nil ~= owner_role and owner_role:GetRoleId() == self.vo.multi_mount_other_uid then
			return owner_role
		end
	end
	return nil
end

function Role:GetMountParnterRole()
	if self.vo.multi_mount_is_owner ~= 0 and (self.mount_other_objid ~= nil and self.mount_other_objid >= 0) then
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
				self.draw_obj.root.transform:SetParent(self.partner_point.transform.parent)
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
					self.update_multi_mount_time = now_time + 0.5
				end


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
	
				self.draw_obj.root.transform:SetParent(self.partner_point)
				self.draw_obj.root.transform.localRotation = Quaternion.Euler(0, -self.partner_point.localEulerAngles.y, 0)
			end
		end
	end
end

function Role:EnterStateStand()
	Character.EnterStateStand(self)

	self.show_baby_timer = 0
end

function Role:UpdateStateStand(elapse_time)
	Character.UpdateStateStand(self, elapse_time)

	if not self.baby_visible and self.vo.baby_id and self.vo.baby_id >= 0 then
		self.show_baby_timer = self.show_baby_timer + elapse_time
		if self.show_baby_timer >= SHOW_BABY_TIMER then
			self.baby_visible = true
			self:ChangeBaby()
		end
	end
end

function Role:QuitStateStand()
	Character.EnterStateStand(self)

	self.baby_visible = false
	self.show_baby_timer = 0
	self:ChangeBaby()
end