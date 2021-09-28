----------------------------------------------------
-- 角色模型
----------------------------------------------------
RoleModel = RoleModel or BaseClass()

RoleModelType = {
	whole_body = 1,					-- 全身
	half_body = 2,					-- 半身
}



DISPLAY_MODEL_TYPE = {
	[DISPLAY_TYPE.MOUNT] = "mount_model", [DISPLAY_TYPE.FIGHT_MOUNT] = "fightmount_model", [DISPLAY_TYPE.WING] = "wing_model",
	[DISPLAY_TYPE.HALO] = "halo_model", [DISPLAY_TYPE.SHENGONG] = "shengong_model", [DISPLAY_TYPE.SHENYI] = "shenyi_model",
	[DISPLAY_TYPE.SPIRIT] = "spirit_model", [DISPLAY_TYPE.FASHION] = "fashion_model", [DISPLAY_TYPE.XIAN_NV] = "xiannv_model",
	[DISPLAY_TYPE.SPIRIT_HALO] = "spirit_halo_model", [DISPLAY_TYPE.SPIRIT_FAZHEN] = "spirit_fazhen_model",
	[DISPLAY_TYPE.NPC] = "npc_model", [DISPLAY_TYPE.ZHIBAO] = "zhibao_model", [DISPLAY_TYPE.MONSTER] = "monster_model",
	[DISPLAY_TYPE.ROLE] = "role_model", [DISPLAY_TYPE.DAILY_CHARGE] = "charge_model", [DISPLAY_TYPE.XUN_ZHANG] = "xunzhang_model",
	[DISPLAY_TYPE.ROLE_WING] = "wing_role_model", [DISPLAY_TYPE.WEAPON] = "weapon_model", [DISPLAY_TYPE.SHENGONG_WEAPON] = "shengong_weapon_model",
	[DISPLAY_TYPE.FORGE] = "forge_model", [DISPLAY_TYPE.GATHER] = "gather_model", [DISPLAY_TYPE.STONE] = "stone_model", [DISPLAY_TYPE.SHEN_BING] = "shenbing_model",
	[DISPLAY_TYPE.BOX] = "box_model", [DISPLAY_TYPE.HUNQI] = "hunqi_model", [DISPLAY_TYPE.ZEROGIFT] = "zero_gift_model",
	[DISPLAY_TYPE.FOOTPRINT] = "footprint_model",[DISPLAY_TYPE.TASKDIALOG] = "task_dialog", [DISPLAY_TYPE.CLOAK] = "cloak_model",
	[DISPLAY_TYPE.COUPLE_HALO] = "couple_halo_model",
}

DISPLAY_PANEL = {
	FULL_PANEL = 1, PROP_TIP = 2, ADVANCE_SUCCE = 3, HUAN_HUA = 4, RANK = 5, OPEN_FUN = 6, SEVEN_DAY_LOGIN = 7, OPEN_TRAILER = 8,FIRST_CHARGE = 9, DISCOUNT = 10,
	ADVANCE_EQUIP = 11, JUHUN = 12, SPIRIT_HOME_FIGHT = 13, SPIRIT_HOME_SEND = 14,	GOLDEN_PIG_CALL = 15, CHONGZHITEHUI_CHU = 16, CHONGZHITEHUI_GAO = 17, ZHUANZHUANLE = 18,
	LING_PO = 18, PUSH_BOSS = 19, SPRIT_EXP = 20, SPIRIT_HOME_ENEMY = 21, YUNBIAO = 22, GONGCHENG = 23, MARRY = 24, RIRINGSTAR = 25,
}

local TmpDisplayPosition = Vector3(0, 1.5, 5)
local TmpDisplayRotation = Vector3(0, 180, 0)

local UIObjLayer = GameObject.Find("GameRoot/UIObjLayer").transform

local MODLE_OFFSET = 100
function RoleModel:__init(panel_name, offset)
	self.draw_obj = DrawObj.New(self, UIObjLayer)
	self.draw_obj:SetRemoveCallback(BindTool.Bind(self._OnModelRemove, self))
	self.draw_obj.auto_fly = false
	self.draw_obj:SetIsUseObjPool(false)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if main_part then
		main_part:SetMainRole(false)
		main_part:EnableHalt(false)
		main_part:EnableCameraShake(false)
		main_part:EnableCameraFOV(false)
		main_part:EnableSceneFade(false)
	end

	self.display = nil
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.halo_res_id = 0
	self.mount_res_id = 0
	self.fight_mount_res_id = 0
	self.weapon2_res_id = 0
	self.fazhen_res_id = 0
	self.foot_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0

	self.next_wing_fold = false
	self.wing_need_action = true
	self.goddess_wing_need_action = true
	self.is_create_footprint = false
	self.cloak_need_action = true

	self.model_type = RoleModelType.whole_body
	-- self.model_display_parameter_cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto")
	self.load_complete = nil
	self.is_load_effect2 = false
	self.loop_name = ""
	self.loop_interval = 2					--循环播放间隔
	self.loop_last_time = 0 				--最后循环播放时间
	self.footprint_eff_t = {}

	self.model_type = RoleModelType.whole_body

	self.ui3d_display_cfg = ConfigManager.Instance:GetAutoConfig("ui3d_display_auto") or {}
	self:SetPanelName(panel_name)

	if nil == offset then
		-- 这个值太大会引起人物抖动，原因未知
		offset = MODLE_OFFSET
		MODLE_OFFSET = MODLE_OFFSET + 300
		if MODLE_OFFSET >= 2000 then
			MODLE_OFFSET = 100
		end
	end
	self.ui_model_offset = Vector3(offset, offset, offset) or Vector3(0, 0, 0)
end

function RoleModel:__delete()
	if self.display then
		self.display:ClearDisplay()
		self.display = nil
	end
	self.draw_obj:DeleteMe()
	self.draw_obj = nil
	self.ui3d_display_cfg = {}
	if self.weapon_effect then
		GameObject.Destroy(self.weapon_effect)
		self.weapon_effect = nil
	end
	if self.weapon2_effect then
		GameObject.Destroy(self.weapon2_effect)
		self.weapon2_effect = nil
	end
	self.is_load_effect = nil
	self.is_load_effect2 = nil
	self.is_create_footprint = nil

	if self.loop_time_quest then
		GlobalTimerQuest:CancelQuest(self.loop_time_quest)
		self.loop_time_quest = nil
	end
	self.loop_name = ""
	self.loop_last_time = 0
	self.info = nil
	self:ClearFootprint()
	self:RemoveSprite()
	self:RemoveGoddess()
end

function RoleModel:SetPanelName(panel_name)
	if panel_name then
		self:SetDisplayPositionAndRotation(panel_name)
	else
		self.display_position = TmpDisplayPosition
		self.display_rotation = TmpDisplayRotation
	end
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local display_obj = self.draw_obj:GetRoot().gameObject
	if not IsNil(self.display) and not IsNil(display_obj) then
		self.display:DisplayPerspectiveWithOffset(display_obj, self.ui_model_offset, self.display_position, self.display_rotation)
	end
end

function RoleModel:SetIsUseObjPool(is_use_objpool)
	self.draw_obj:SetIsUseObjPool(is_use_objpool)
end

function RoleModel:SetLoadComplete(complete)
	self.load_complete = complete
end

function RoleModel:SetDisplayPositionAndRotation(panel_name)
	local ui3d_display_data = self.ui3d_display_cfg[panel_name]
	if not ui3d_display_data then
		return
	end

	self.display_position = ui3d_display_data.position or TmpDisplayPosition
	self.display_rotation = ui3d_display_data.rotation or TmpDisplayRotation
end

function RoleModel:SetDisplay(display, model_type)
	self.display = display
	self.model_type = model_type or RoleModelType.whole_body
end

function RoleModel:SetMainAsset(bundle, asset, func)
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:RemoveModel()
	part:ChangeModel(bundle, asset, func)
end

function RoleModel:SetGoddessAsset(bundle, asset)
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	part:ChangeModel(bundle, asset)
end

function RoleModel:SetRoleResid(role_res_id)
	self.role_res_id = role_res_id
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:ChangeModel(ResPath.GetRoleModel(self.role_res_id))
end

function RoleModel:SetGoddessResid(role_res_id)
	self.role_res_id = role_res_id
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:ChangeModel(ResPath.GetGoddessModel(self.role_res_id))
end

function RoleModel:SetGoddessWeaponResid(weapon_res_id)
	self.weapon_res_id = weapon_res_id
	if nil == self.weapon_res_id or self.weapon_res_id == -1 then
		return
	end

	local part = self.draw_obj:GetPart(SceneObjPart.Halo)
	part:ChangeModel(ResPath.GetGoddessWeaponModel(self.weapon_res_id))
end

--设置腰饰
function RoleModel:SetWaistResid(waist_res_id)
	self.waist_res_id = waist_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.Waist)
	if nil == waist_res_id or waist_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetWaistModel(waist_res_id))
end

--设置头饰
function RoleModel:SetTouShiResid(toushi_res_id)
	self.toushi_res_id = toushi_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.TouShi)
	if nil == toushi_res_id or toushi_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetTouShiModel(toushi_res_id))
end

--设置麒麟臂（这个是装在人身上的, 单独展示麒麟臂调SetMainAsset）
function RoleModel:SetQilinBiResid(qilinbi_res_id, sex)
	self.qilinbi_res_id = qilinbi_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.QilinBi)
	if nil == qilinbi_res_id or qilinbi_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetQilinBiModel(qilinbi_res_id, sex))
end

--设置面饰
function RoleModel:SetMaskResid(mask_res_id)
	self.mask_res_id = mask_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.Mask)
	if nil == mask_res_id or mask_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetMaskModel(mask_res_id))
end

function RoleModel:SetMountResid(mount_res_id)
	if self.mount_res_id == mount_res_id then
		return
	end

	self.mount_res_id = mount_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Mount)
	local layer = self:GetMountLayer(mount_res_id)
	local asset, bundle = ResPath.GetMountModel(self.mount_res_id)
	part:ChangeModel(asset, bundle, function ()
		if self.draw_obj then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			main_part:SetLayer(layer, 1)
		end
	end)
end

function RoleModel:RemoveMount()
	self.mount_res_id = 0
	self.draw_obj:RemoveModel(SceneObjPart.Mount)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
end

function RoleModel:GetMountLayer(mount_res_id)
	local layer = ANIMATOR_PARAM.MOUNT_LAYER
	local cfg = MountData.Instance:GetSpecialImagesCfg()
	for k,v in pairs(cfg) do
		if v.res_id == mount_res_id then
			layer = v.is_sit == 2 and ANIMATOR_PARAM.MOUNT_LAYER2 or layer
			break
		end
	end
	return layer
end

function RoleModel:SetFightMountResid(fight_mount_res_id)
	if self.fight_mount_res_id == fight_mount_res_id then
		return
	end

	self.fight_mount_res_id = fight_mount_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	part:ChangeModel(ResPath.GetFightMountModel(self.fight_mount_res_id))
end

function RoleModel:RemoveFightMount()
	self.fight_mount_res_id = 0
	self.draw_obj:RemoveModel(SceneObjPart.FightMount)
end

function RoleModel:SetHaloResid(halo_res_id)
	self.halo_res_id = halo_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Halo)
	part:ChangeModel(ResPath.GetHaloModel(self.halo_res_id))
end

function RoleModel:SetWeaponResid(weapon_res_id)
	self.weapon_res_id = weapon_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	part:ChangeModel(ResPath.GetWeaponModel(self.weapon_res_id))
end

function RoleModel:SetWeapon2Resid(weapon2_res_id)
	self.weapon2_res_id = weapon2_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon2)
	part:ChangeModel(ResPath.GetWeaponModel(self.weapon2_res_id))
end

function RoleModel:SetFaZhenResid(fazhen_res_id)
	-- self.fazhen_res_id = fazhen_res_id
	-- local part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
	-- part:ChangeModel(ResPath.GetZhenfaEffect(self.fazhen_res_id))
end

function RoleModel:ClearFootprint()
	if self.foot_timer then
		GlobalTimerQuest:CancelQuest(self.foot_timer)
		self.foot_timer = nil
	end

	self:RemoveFootDelayTime()

	for k,v in pairs(self.footprint_eff_t) do
		if not IsNil(v) then
			GameObject.Destroy(v)
		end
	end
	self.footprint_eff_t = {}
end

function RoleModel:SetFootResid(foot_res_id)
	self.is_create_footprint = true
	self.foot_res_id = foot_res_id
	self:ClearFootprint()

	if type(foot_res_id) == "number" then
		if self.foot_res_id > 0  then
			self:CreateFootprint()
			self.foot_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateFootprintPos, self), 0)
		end
    else
	   	if self.foot_res_id ~= nil then
		   self:CreateFootprint()
			self.foot_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateFootprintPos, self), 0)
		end
	end
end

function RoleModel:CreateFootprint()
	if type(self.foot_res_id) == "number" then
		if self.foot_res_id <= 0  then return end
	else
		if self.foot_res_id == nil then return end
	end

	if self.draw_obj and self.is_create_footprint then
		local pos = self.draw_obj:GetRoot().transform.position
		local bundle, asset = ResPath.GetFootModel(self.foot_res_id)
		if #self.footprint_eff_t > 5 then
			local footprint = table.remove(self.footprint_eff_t, 1)
			if not IsNil(footprint) then
				GameObject.Destroy(footprint)
			end
		end
		GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
			if not IsNil(obj) then
				if nil == self.draw_obj then
					GameObject.Destroy(obj)
					return
				end
				obj.transform:SetParent(self.draw_obj:GetRoot().transform, false)
				obj.gameObject:SetLayerRecursively(self.draw_obj:GetRoot().gameObject.layer)
				table.insert(self.footprint_eff_t, obj)
				-- obj.transform.localPosition = Vector3(0, 0, 0)
				self:RemoveFootDelayTime()
				self.foot_print_delay_time = GlobalTimerQuest:AddDelayTimer(function ()
					self:CreateFootprint()
				end, COMMON_CONSTS.FOOTPRINT_CREATE_GAP_TIME)
			end
		end)
	end
end

function RoleModel:RemoveFootDelayTime()
	if self.foot_print_delay_time then
		GlobalTimerQuest:CancelQuest(self.foot_print_delay_time)
		self.foot_print_delay_time = nil
	end
end

function RoleModel:UpdateFootprintPos()
	for k,v in pairs(self.footprint_eff_t) do
		if not IsNil(v) then
			local pos = v.transform.localPosition
			v.transform.localPosition = Vector3(pos.x, pos.y, pos.z - 0.08)
		end
	end
end

function RoleModel:SetWingResid(wing_res_id)
	self.wing_res_id = wing_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Wing)
	local bundle, asset = ResPath.GetWingModel(self.wing_res_id)
	part:ChangeModel(bundle, asset,function()
		if self.wing_need_action or self.goddess_wing_need_action then
			part:SetTrigger("action")
		end
	end)
end

function RoleModel:SetWingNeedAction(is_need)
	self.wing_need_action = is_need
end

function RoleModel:SetGoddessWingNeedAction(is_need)
	self.goddess_wing_need_action = is_need
end

function RoleModel:SetGoddessWingResid(wing_res_id)
	self.wing_res_id = wing_res_id
	if nil == self.wing_res_id or self.wing_res_id == -1 then
		return
	end

	local part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
	part:ChangeModel(ResPath.GetGoddessWingModel(self.wing_res_id))
end

function RoleModel:SetWingAsset(bundle,asset)
	local part = self.draw_obj:GetPart(SceneObjPart.Wing)
	part:ChangeModel(bundle, asset, function()
		if self.goddess_wing_need_action or self.wing_need_action then
			part:SetTrigger("action")
		end
	end)
end

function RoleModel:SetParticleAsset(bundle,asset)
	local part = self.draw_obj:GetPart(SceneObjPart.Particle)
	part:ChangeModel(bundle, asset)
end

function RoleModel:SetCloakResid(cloak_res_id)
	self.cloak_res_id = cloak_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Cloak)
	local bundle, asset = ResPath.GetPifengModel(self.cloak_res_id)
	part:ChangeModel(bundle, asset, function()
		if self.cloak_need_action then
			part:SetTrigger("action")
		end
	end)
end

function RoleModel:SetCloakAction(is_need)
	self.cloak_need_action = is_need
end

function RoleModel:SetVisible(state)
	self.draw_obj:SetVisible(state)
end

function RoleModel:SetModelTransformParameter(model_type, res_id, panel_type)

end

function RoleModel:SetRotation(rotation)
	if rotation and self.display then
		self.display:SetRotation(rotation)
	end
end

function RoleModel:SetTransform(cfg)
	if cfg and self.display then
		-- self.display:SetOffset(cfg.position)
		self.display:SetRotation(cfg.rotation)
		self.display:SetScale(cfg.scale)
	end
end

function RoleModel:SetModelScale(scale)
	if self.display then
		self.display:SetScale(scale)
	end
end

function RoleModel:_OnModelLoaded(part, obj)
	-- ui上的特效强制使用最高品质
	CommonDataManager.ChangeQuality(obj, COMMON_CONSTS.UI_QUALITY_OVER_LEVEL)
	local main_part = self.draw_obj:GetPart(part)
	if nil ~= main_part then
		main_part:SetMaterialIndex(1)
	end

	if part == SceneObjPart.Main then
		local display_obj = self.draw_obj:GetRoot().gameObject
		if not IsNil(self.display) and not IsNil(display_obj) then
			-- FIXME:
			-- 不同UI面板的position和rotation要不同
			self.display:DisplayPerspectiveWithOffset(display_obj, self.ui_model_offset, self.display_position, self.display_rotation)
		end

		if self.trigger_name then
			part_obj:SetTrigger(self.trigger_name)
			self.trigger_name = nil
		end
	end
	if self.load_complete then
		self.load_complete(part, obj)
	end
end

function RoleModel:_OnModelRemove(part, obj)
	-- 还原游戏品质
	CommonDataManager.ResetQuality(obj)
end

function RoleModel:SetTrigger(name)
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				GlobalTimerQuest:AddDelayTimer(function() main_part:SetTrigger(name) end, 0.1)
			else
				self.trigger_name = name
			end
		end
	end
end

function RoleModel:SetBool(name, state)
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				GlobalTimerQuest:AddDelayTimer(function() main_part:SetBool(name, state) end, 0.1)
			end
		end
	end
end

function RoleModel:SetInteger(key, value)
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				main_part:SetInteger(key, value)
			end
		end
	end
end

function RoleModel:Rotate(x_angle, y_angle, z_angle)
	if self.draw_obj then
		self.draw_obj:Rotate(x_angle, y_angle, z_angle)
	end
end

function RoleModel:ResetRotation()
	if self.display then
		self.display:ResetRotation()
	end
end

-- 通过模型类型 【DISPLAY_MODEL_TYPE】、 资源ID 、和展示界面的类型 【DISPLAY_PANEL】 获取配置
-- 默认全屏界面
function RoleModel:GetModelDisplayParameterCfg(model_type, res_id, display_panel)

end

function RoleModel:SetGoddessModelResInfo(info)
	for k, v in pairs(SceneObjPart) do
		local part = self.draw_obj:GetPart(v)
		if part then
			part:RemoveModel()
		end
	end
	if info ~= nil then
		self.role_res_id = info.role_res_id or -1
		self.weapon_res_id = info.weapon_res_id or -1
		self.wing_res_id = info.wing_res_id or -1
	end
	if self.role_res_id ~= -1 then
		self:SetGoddessResid(self.role_res_id)
	end
	if self.weapon_res_id ~= -1 then
		self:SetGoddessWeaponResid(self.weapon_res_id)
	end
	if self.wing_res_id ~= -1 then
		self:SetGoddessWingResid(self.wing_res_id)
	end
end

function RoleModel:ResetWeapon()
	local part_one = self.draw_obj:GetPart(SceneObjPart.Weapon)
	if part_one then
		part_one:RemoveModel()
	end
	local part_two = self.draw_obj:GetPart(SceneObjPart.Weapon2)
	if part_two then
		part_two:RemoveModel()
	end
end

function RoleModel:SetModelResInfo(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak)
	self.info = info
	self.ignore_find = ignore_find
	self.ignore_wing = ignore_wing
	self.ignore_halo = ignore_halo
	self.ignore_weapon = ignore_weapon
	self.show_footprint = show_footprint
	self.ignore_cloak = ignore_cloak

	if info == nil then return end
	local prof = info.prof
	local sex = info.sex
	if nil == prof or nil == sex then
		return
	end

	self:ResetWeapon()

	self:UpdateAppearance(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak)
	self:SetRoleResid(self.role_res_id)

	if not info.is_not_show_weapon then
		self:SetWeaponResid(self.weapon_res_id)
		self:SetWeapon2Resid(self.weapon2_res_id)
	end

	self:SetWingResid(self.wing_res_id)
	self:SetHaloResid(self.halo_res_id)
	self:SetFootResid(self.foot_res_id)
	self:SetCloakResid(self.cloak_res_id)
	self:SetWaistResid(self.waist_res_id)
	self:SetTouShiResid(self.toushi_res_id)
	self:SetQilinBiResid(self.qilinbi_res_id, sex)
	self:SetMaskResid(self.mask_res_id)
end

function RoleModel:UpdateAppearance(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak)
	local prof = info.prof
	local sex = info.sex
	if nil == prof or nil == sex then
		return
	end
	local wuqi_color = info.wuqi_color
	if nil == wuqi_color and info.equipment_info then
		local equip_info = info.equipment_info[GameEnum.EQUIP_INDEX_WUQI + 1]
		if equip_info then
			local cfg = ItemData.Instance:GetItemConfig(equip_info.equip_id)
			if cfg then
				wuqi_color = cfg.color
			end
		end
	end
	wuqi_color = wuqi_color and wuqi_color or 0
	--清空缓存
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.halo_res_id = 0
	self.wing_res_id = 0
	self.weapon2_res_id = 0
	self.fazhen_res_id = 0
	self.foot_res_id = 0
	self.cloak_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0

	local wing_index = 0
	local halo_index = 0
	local foot_index = 0
	local cloak_index = 0
	-- 先查找时装的武器和衣服
	local appearance = info.appearance
	if appearance == nil then
		local shizhuang_part_list = info.shizhuang_part_list
		if shizhuang_part_list then
			appearance = {fashion_body = shizhuang_part_list[2].use_index, fashion_wuqi = shizhuang_part_list[1].use_index}
		end
	else
		wing_index = appearance.wing_used_imageid or 0
		if not ignore_halo then
			halo_index = appearance.halo_used_imageid or 0
		end
		if show_footprint then
			foot_index = appearance.footprint_used_imageid or 0
		end
		if not ignore_cloak then
			cloak_index = appearance.cloak_used_imageid or 0
		end
	end

	if appearance ~= nil then
		local fashion_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
		if appearance.fashion_wuqi ~= 0 then
			local wuqi_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.WUQI, appearance.fashion_wuqi)
			if wuqi_cfg and not ignore_weapon then
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

		if appearance.fashion_body ~= 0 then
			local clothing_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.BODY, appearance.fashion_body)
			if clothing_cfg then
				local res_id = clothing_cfg["resouce" .. prof .. sex]
				self.role_res_id = res_id
			end
		end

		--腰饰
		if appearance.yaoshi_used_imageid and appearance.yaoshi_used_imageid > 0 then
			self.waist_res_id = WaistData.Instance:GetResIdByImageId(appearance.yaoshi_used_imageid)
		end

		--头饰
		if appearance.toushi_used_imageid and appearance.toushi_used_imageid > 0 then
			self.toushi_res_id = TouShiData.Instance:GetResIdByImageId(appearance.toushi_used_imageid)
		end

		--麒麟臂
		if appearance.qilinbi_used_imageid and appearance.qilinbi_used_imageid > 0 then
			self.qilinbi_res_id = QilinBiData.Instance:GetResIdByImageId(appearance.qilinbi_used_imageid, sex)
		end

		--面饰
		if appearance.mask_used_imageid and appearance.mask_used_imageid > 0 then
			self.mask_res_id = MaskData.Instance:GetResIdByImageId(appearance.mask_used_imageid)
		end
	end
	-- 查找翅膀
	if wing_index == 0 then
		if info.wing_info then
			wing_index = info.wing_info.used_imageid or 0
		end
	end
	local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	local image_cfg = nil
	if wing_config and not ignore_wing then
		if wing_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = wing_config.special_img[wing_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = wing_config.image_list[wing_index]
		end
		if image_cfg then
			self.wing_res_id = image_cfg.res_id
		end
	end

	-- 查找光环
	if halo_index == 0 and not ignore_halo then
		if info.halo_info then
			halo_index = info.halo_info.used_imageid or 0
		end
	end
	local halo_config = ConfigManager.Instance:GetAutoConfig("halo_auto")
	image_cfg = nil

	if halo_config and halo_index > 0 then
		if halo_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[halo_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[halo_index]
		end
		if image_cfg then
			self.halo_res_id = image_cfg.res_id
		end
	end

	-- 查找足迹
	if foot_index == 0 and show_footprint then
		if info.foot_info then
			foot_index = info.foot_info.used_imageid or 0
		end
	end
	local foot_config = ConfigManager.Instance:GetAutoConfig("footprint_auto")
	image_cfg = nil

	if foot_config and foot_index > 0 then
		if foot_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = foot_config.special_img[foot_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = foot_config.image_list[foot_index]
		end
		if image_cfg then
			self.foot_res_id = image_cfg.res_id
		end
	end

	-- 查找披风
	if cloak_index == 0 and not ignore_cloak then
		if info.cloak_info then
			cloak_index = info.cloak_info.used_imageid or 0
		end
	end
	local cloak_config = ConfigManager.Instance:GetAutoConfig("cloak_auto")
	image_cfg = nil
	if cloak_config and not ignore_cloak then
		if cloak_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = cloak_config.special_img[cloak_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = cloak_config.image_list[cloak_index]
		end
		if image_cfg then
			self.cloak_res_id = image_cfg.res_id
		end
	end

	-- 最后查找职业表
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[prof]
	if role_job ~= nil then
		if self.role_res_id == 0 then
			self.role_res_id = role_job["model" .. sex]
		end
		if not ignore_find then
			if self.weapon_res_id == 0 then
				-- 武器颜色为红色时，使用特殊的模型
				if wuqi_color >= GameEnum.ITEM_COLOR_RED then
					self.weapon_res_id = role_job["right_red_weapon" .. sex]
				else
					self.weapon_res_id = role_job["right_weapon" .. sex]
				end
			end

			if self.weapon2_res_id == 0 then
				if wuqi_color >= GameEnum.ITEM_COLOR_RED then
					self.weapon2_res_id = role_job["left_red_weapon" .. sex]
				else
					self.weapon2_res_id = role_job["left_weapon" .. sex]
				end
			end
		end
	else
		if self.role_res_id == 0 then
			self.role_res_id = 1001001
		end
		if not ignore_find then
			if self.weapon_res_id == 0 then
				self.weapon_res_id = 900100101
			end
		end
	end
end

--根据type, index获取服装的配置
function RoleModel:GetFashionConfig(fashion_cfg_list, part_type, index)
	for k, v in pairs(fashion_cfg_list) do
		if v.part_type == part_type and index == v.index then
			return v
		end
	end
	return nil
end

function RoleModel:EquipDataChangeListen()
	self:SetModelResInfo(self.info, self.ignore_find, self.ignore_wing, self.ignore_halo, self.ignore_weapon, self.show_footprint, self.ignore_cloak)
end

function RoleModel:SetWeaponEffect(part, obj)
	if not obj or (part ~= SceneObjPart.Weapon and part ~= SceneObjPart.Weapon2) then return end
	local main_role = Scene.Instance:GetMainRole()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local weapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	local weapon2_part = self.draw_obj:GetPart(SceneObjPart.Weapon2)
	if vo.appearance and vo.appearance.fashion_wuqi and vo.appearance.fashion_wuqi == 0
		and (main_role:GetWeaponResId() == tonumber(weapon_part.asset_name) or weapon2_part and main_role:GetWeapon2ResId() == tonumber(weapon2_part.asset_name))
		and main_role.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then
			local bundle, asset = ResPath.GetWeaponEffect(self.weapon_res_id)
			if self.weapon_effect_name and self.weapon_effect_name ~= asset then
				if self.weapon_effect then
					GameObject.Destroy(self.weapon_effect)
					self.weapon_effect = nil
				end
			end
			if bundle and asset and not self.weapon_effect and not self.is_load_effect then
				self.is_load_effect = true

				PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
					if nil == prefab then return end
					local effct_obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)

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
			local bundle, asset = ResPath.GetWeaponEffect(self.weapon_res_id)
			if self.weapon2_effect_name and self.weapon2_effect_name ~= asset then
				if self.weapon2_effect then
					GameObject.Destroy(self.weapon2_effect)
					self.weapon2_effect = nil
				end
			end
			if bundle and asset and not self.weapon2_effect and not self.is_load_effect2 then
				self.is_load_effect2 = true
				PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
					if nil == prefab then return end
					local effct_obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)
					self.weapon2_effect = effct_obj.gameObject
					effct_obj.transform:SetParent(obj.transform, false)
					if self.draw_obj then
						obj.gameObject:SetLayerRecursively(self.draw_obj.root.gameObject.layer)
					end
					self.weapon2_effect_name = asset
					self.is_load_effect2 = false
				end)
			end
		end
	else
		if self.weapon_effect then
			GameObject.Destroy(self.weapon_effect)
			self.weapon_effect = nil
		end
		if self.weapon2_effect then
			GameObject.Destroy(self.weapon2_effect)
			self.weapon2_effect = nil
		end
	end
end

function RoleModel:SetListenEvent(list_name, callback)
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				main_part:ListenEvent(list_name, callback)
			end
		end
	end
end

function RoleModel:ClearModel()
	for k, v in pairs(SceneObjPart) do
		local part = self.draw_obj:GetPart(v)
		if part then
			part:RemoveModel()
		end
	end

	self:ClearFootprint()
end

function RoleModel:ShowAttachPoint(point, state)
	if nil == self.draw_obj then
		return
	end
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local attach_point = part:GetAttachPoint(point)
	if nil ~= attach_point then
		attach_point.gameObject:SetActive(state)
	end
end

--[[
	有些模型需要手动循环播放
	调用SetLoopAnimal传入动作名字
]]
function RoleModel:ListCallBack()
	self.loop_last_time = Status.NowTime
end

function RoleModel:SetLoopAnimal(ani_name, list_name)
	if ani_name == "" or not ani_name then return end
	if list_name then
		self:SetListenEvent(list_name, BindTool.Bind(self.ListCallBack, self))
	end
	self.loop_name = ani_name
	if self.loop_time_quest then
		GlobalTimerQuest:CancelQuest(self.loop_time_quest)
		self.loop_time_quest = nil
	end
	self.loop_last_time = 0
	self.loop_time_quest = GlobalTimerQuest:AddRunQuest(function()
		if Status.NowTime - self.loop_interval < self.loop_last_time then
			return
		end
		self.loop_last_time = Status.NowTime + 999
		if self.loop_name and self.loop_name ~= "" then
			self:SetTrigger(self.loop_name)
		end
	end, 12)
end

function RoleModel:SetFootState(is_create_footprint)
	self.is_create_footprint = is_create_footprint
end

function RoleModel:GetFootState()
	return self.is_create_footprint
end

function RoleModel:SetHeadRes(bundle, name)
	local part = self.draw_obj:GetPart(SceneObjPart.Head)
	part:ChangeModel(bundle, name)
end

function RoleModel:RemoveHead()
	local part = self.draw_obj:GetPart(SceneObjPart.Head)
	part:RemoveModel()
end

-- 衣柜展示用的方法
-- 可以支持同时创建人物、伙伴、仙宠、坐骑
function RoleModel:SetClosetInfo(role_info, sprite_info, goddess_info, mount_res_id, fight_mount_resid, show_footprint)
	self:SetModelResInfo(role_info, false , false, false, false, show_footprint, false)

	if sprite_info then
		self:AddSprite(sprite_info.res_id, sprite_info.offset or 1)
	else
		self:RemoveSprite()
	end

	if goddess_info then
		self:AddGoddess(goddess_info.res_id, goddess_info.offset or -1)
	else
		self:RemoveGoddess()
	end

	if mount_res_id then
		self:SetMountResid(mount_res_id)
	else
		self:RemoveMount()
	end

	if fight_mount_resid then
		self:SetFightMountResid(fight_mount_resid)
	else
		self:RemoveFightMount()
	end

	if not show_footprint then
		self:ClearFootprint()
	end
end

function RoleModel:AddSprite(sprite_res_id, offset)
	if not self.sprite_obj then
		self.sprite_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
		self.sprite_obj:GetRoot().gameObject.transform.localPosition = Vector3(offset, 0, 0)
		self.sprite_obj:GetRoot().gameObject.transform.localScale = Vector3(1, 1, 1)
		self.sprite_obj.auto_fly = false
		self.sprite_obj:SetIsUseObjPool(false)
		self.sprite_obj:GetPart(SceneObjPart.Main):SetMainRole(false)
	end
	local main_part = self.sprite_obj:GetPart(SceneObjPart.Main)
	main_part:ChangeModel(ResPath.GetSpiritModel(sprite_res_id))
end

function RoleModel:RemoveSprite()
	if self.sprite_obj then
		self.sprite_obj:DeleteMe()
		self.sprite_obj = nil
	end
end

function RoleModel:AddGoddess(goddess_res_id, offset)
	if not self.goddess_obj then
		self.goddess_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
		self.goddess_obj:GetRoot().gameObject.transform.localPosition = Vector3(offset, 0, 0)
		self.goddess_obj:GetRoot().gameObject.transform.localScale = Vector3(1, 1, 1)
		self.goddess_obj.auto_fly = false
		self.goddess_obj:SetIsUseObjPool(false)
		self.goddess_obj:GetPart(SceneObjPart.Main):SetMainRole(false)
	end
	local main_part = self.goddess_obj:GetPart(SceneObjPart.Main)
	main_part:ChangeModel(ResPath.GetGoddessModel(goddess_res_id))
end

function RoleModel:RemoveGoddess()
	if self.goddess_obj then
		self.goddess_obj:DeleteMe()
		self.goddess_obj = nil
	end
end