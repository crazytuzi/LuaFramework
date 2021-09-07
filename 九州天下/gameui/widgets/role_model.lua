----------------------------------------------------
-- 角色模型
----------------------------------------------------
RoleModel = RoleModel or BaseClass()

RoleModelType = {
	whole_body = 1,					-- 全身
	half_body = 2,					-- 半身
}

DISPLAY_TYPE = {XIAN_NV = 1, MOUNT = 2, WING = 3, FASHION = 4, HALO = 5, SPIRIT = 6, FIGHT_MOUNT = 7, SHENGONG = 8, SHENYI = 9,
				SPIRIT_HALO = 10, SPIRIT_FAZHEN = 11, NPC = 12, BUBBLE = 13, ZHIBAO = 14, MONSTER = 15, ROLE = 16, DAILY_CHARGE = 17,
				TITLE = 18, XUN_ZHANG = 19, ROLE_WING = 20, WEAPON = 21, SHENGONG_WEAPON = 22, FORGE = 23, GATHER = 24, STONE = 25,
				SHEN_BING = 26, BOX = 27, HUNQI = 28, ZEROGIFT = 29, JUN = 30, SHENQI = 31, GENERAL = 32, FAZHEN = 33, MANTLE = 34,
				HUANZHUANG_SHOP = 35, COUPLE_HALO = 36, MULTI_MOUNT = 37, HEADWEAR = 38, MASK = 39, WAIST = 40, BEAD = 41, FABAO = 42,
				KIRINARM = 43, HEAD_FRAME = 44,LITTTLE_PET = 45,
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
	[DISPLAY_TYPE.JUN] = "jun_xian", [DISPLAY_TYPE.SHENQI] = "shenqi", [DISPLAY_TYPE.GENERAL] = "general", [DISPLAY_TYPE.FAZHEN] = "fazhen_model",
	[DISPLAY_TYPE.MANTLE] = "mantle_model", [DISPLAY_TYPE.HUANZHUANG_SHOP] = "huan_zhuang_shop_model", [DISPLAY_TYPE.COUPLE_HALO] = "couple_halo_model",
}

DISPLAY_PANEL = {
	FULL_PANEL = 1, PROP_TIP = 2, ADVANCE_SUCCE = 3, HUAN_HUA = 4, RANK = 5, OPEN_FUN = 6, SEVEN_DAY_LOGIN = 7, OPEN_TRAILER = 8,FIRST_CHARGE = 9, DISCOUNT = 10,
	ADVANCE_EQUIP = 11, JUHUN = 12, JUN = 13, RISING = 14, CHUJUN_GIFT_MIDDLE = 15, SHENQI_VIEW = 16, GUILD_VIEW = 17, XIANNV_YOUHUI = 18, ROLE_HUANHUA = 19, CHECK_DISPLAY_VIE = 20,
	RANK_ROLE_MODEL = 21, CHUJUN_GIFT_LEFT = 22, CHUJUN_GIFT_RIGHT = 23, GENERAL_FIGHT = 24, GENERAL_COMBO = 25, GENERAL_FIGHT_MAIN = 26, RANK_ADVANCE_MODEL = 27, RED_EQUIP_ACT = 28,
	QITIAN_CHOGNZHI = 29,
}

local MODLE_OFFSET = 100

local TmpDisplayPosition = Vector3(0, 1.5, 5)
local TmpDisplayRotation = Vector3(0, 180, 0)

local UIObjLayer = GameObject.Find("GameRoot/UIObjLayer").transform

function RoleModel:__init(panel_name, offset)
	self.draw_obj = DrawObj.New(self, UIObjLayer)
	self.draw_obj:SetRemoveCallback(BindTool.Bind(self._OnModelRemove, self))
	self.draw_obj.auto_fly = false

	self.display = nil
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.mount_res_id = 0
	self.halo_res_id = 0
	self.weapon2_res_id = 0
	self.mantle_res_id = 0
	self.fazhen_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0
	self.lingzhu_res_id = 0

	self.next_wing_fold = false
	self.wing_need_action = true
	self.goddess_wing_need_action = true
	self.model_type = RoleModelType.whole_body
	
	self.ui3d_display_cfg = ConfigManager.Instance:GetAutoConfig("ui3d_display_auto") or {}
	if panel_name then
		self:SetDisplayPositionAndRotation(panel_name)
	else
		self.display_position = TmpDisplayPosition
		self.display_rotation = TmpDisplayRotation
	end

	if nil == offset then
		-- 这个值太大会引起人物抖动，原因未知
		offset = MODLE_OFFSET
		MODLE_OFFSET = MODLE_OFFSET + 300
		if MODLE_OFFSET >= 2000 then
			MODLE_OFFSET = 100
		end
	end
	self.ui_model_offset = Vector3(offset, offset, offset) or Vector3(0, 0, 0)

	self.load_complete = nil
	self.is_load_effect2 = false
	self.loop_name = ""
	self.loop_interval = 10					--循环播放间隔
	self.loop_last_time = 0 				--最后循环播放时间
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

	if self.loop_time_quest then
		GlobalTimerQuest:CancelQuest(self.loop_time_quest)
		self.loop_time_quest = nil
	end
	self.loop_name = ""
	self.loop_last_time = 0
	self.info = nil

	if self.listen_role ~= nil then
		GlobalEventSystem:UnBind(self.listen_role)
		self.listen_role = nil
	end
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

function RoleModel:ResetDisplayPositionAndRotation()
	self.display_position = TmpDisplayPosition
	self.display_rotation = TmpDisplayRotation	
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

function RoleModel:SetRoleResid(role_res_id, func)
	self.role_res_id = role_res_id
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local bundle, asset = ResPath.GetRoleModel(self.role_res_id)
	part:ChangeModel(bundle, asset, func)
end

function RoleModel:SetGoddessResid(role_res_id)
	self.role_res_id = role_res_id
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:ChangeModel(ResPath.GetGoddessModel(self.role_res_id))
end

function RoleModel:SetGoddessWeaponResid(weapon_res_id)
	self.weapon_res_id = weapon_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	part:ChangeModel(ResPath.GetGoddessWeaponModel(self.weapon_res_id))
end

function RoleModel:SetMountResid(mount_res_id)
	local cfg = MountData.Instance:GetMountCfgByResId(mount_res_id)
	if self.mount_res_id == mount_res_id then
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		local layer = 2
		if cfg ~= nil and cfg.is_sit == 1 then
			layer = 3
		end

		if main_part:GetObj() and main_part:GetObj().animator then
			main_part:GetObj().animator:SetLayerWeight(layer, 1.0)
		end
		return
	else
		--self:RemoveMount()
		local old_cfg = MountData.Instance:GetMountCfgByResId(self.mount_res_id)
		if old_cfg ~= nil and next(old_cfg) ~= nil then
			if (old_cfg.is_sit ~= nil and old_cfg.is_sit == 1) and (cfg.is_sit ~= nil and cfg.is_sit == 0) then
				local part_other = self.draw_obj:GetPart(SceneObjPart.FightMount)
				part_other:RemoveModel()		
			elseif (old_cfg.is_sit ~= nil and old_cfg.is_sit == 0) and (cfg.is_sit ~= nil and cfg.is_sit == 1) then		
				local part = self.draw_obj:GetPart(SceneObjPart.Mount)
				part:RemoveModel()
			end
		end
	end

	self.mount_res_id = mount_res_id

	if cfg ~= nil and cfg.is_sit == 1 then
		local part = self.draw_obj:GetPart(SceneObjPart.FightMount)
		part:ChangeModel(ResPath.GetMountModel(self.mount_res_id))
	else
		local part = self.draw_obj:GetPart(SceneObjPart.Mount)
		part:ChangeModel(ResPath.GetMountModel(self.mount_res_id))
	end
end

function RoleModel:RemoveMount()
	self.mount_res_id = 0
	local part = self.draw_obj:GetPart(SceneObjPart.Mount)
	part:RemoveModel()

	local part_other = self.draw_obj:GetPart(SceneObjPart.FightMount)
	part_other:RemoveModel()
end

function RoleModel:RemoveWeapon()
	self.weapon_res_id = 0
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	part:RemoveModel()
end

function RoleModel:RemoveWing()
	self.wing_res_id = 0
	local part = self.draw_obj:GetPart(SceneObjPart.Wing)
	part:RemoveModel()
end

function RoleModel:SetHaloResid(halo_res_id, is_nvshen)
	self.halo_res_id = halo_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Halo)
	if is_nvshen then
		part:ChangeModel(ResPath.GetNvShenHaloModel(self.halo_res_id))
	else
		part:ChangeModel(ResPath.GetHaloModel(self.halo_res_id))
	end
end

function RoleModel:SetZhiBaoResid(zhibao_res_id)
	self.zhibao_res_id = zhibao_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.BaoJu)
	part:ChangeModel(ResPath.GetHighBaoJuModel(self.zhibao_res_id))
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

function RoleModel:SetWingResid(wing_res_id)
	self.wing_res_id = wing_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Wing)
	local bundle, asset = ResPath.GetWingModel(self.wing_res_id)
	part:ChangeModel(bundle, asset, function()
		if self.wing_need_action then
			part:SetTrigger("action")
		end
	end)
end

function RoleModel:SetMantleResid(mantle_res_id)
	self.mantle_res_id = mantle_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Mantle)
	local bundle, asset = ResPath.GetPifengModel(self.mantle_res_id)
	part:ChangeModel(bundle, asset, function()
		if self.wing_need_action then
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
	local part = self.draw_obj:GetPart(SceneObjPart.Wing)
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

function RoleModel:SetFightMountResid(fight_mount_res_id)
	self.fight_mount_res_id = fight_mount_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	part:ChangeModel(ResPath.GetFightMountModel(self.fight_mount_res_id))
end

function RoleModel:SetFaZhenResid(fazhen_res_id)
	self.fazhen_res_id = fazhen_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
	local has_fazhen = tonumber(self.fazhen_res_id) ~= nil and self.fazhen_res_id > 0 or self.fazhen_res_id ~= ""
	if part ~= nil and has_fazhen then
		part:ReSetOffsetY()
	end
	part:ChangeModel(ResPath.GetFaZhenModel(self.fazhen_res_id))
end

function RoleModel:SetFaZhenOffY(y)
	local part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
	local has_fazhen = tonumber(self.fazhen_res_id) ~= nil and self.fazhen_res_id > 0 or self.fazhen_res_id ~= ""
	if part ~= nil and has_fazhen then
		part:SetOffsetY(y)
	end
end


function RoleModel:SetWaistnResid(waist_res_id)
	self.waist_res_id = waist_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Waist)
	part:ChangeModel(ResPath.GetWaistModel(self.waist_res_id))
end

function RoleModel:SetTouShiResid(toushi_res_id)
	self.toushi_res_id = toushi_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.TouShi)
	part:ChangeModel(ResPath.GetTouShiModel(self.toushi_res_id))
end

function RoleModel:SetMaskResid(mask_res_id)
	self.mask_res_id = mask_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Mask)
	part:ChangeModel(ResPath.GetMaskModel(self.mask_res_id))
end

function RoleModel:SetLingZhuResid(lingzhu_res_id)
	self.lingzhu_res_id = lingzhu_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.HALO)
	part:ChangeModel(ResPath.GetLingZhuModel(self.lingzhu_res_id, true))
end


function RoleModel:SetVisible(state)
	self.draw_obj:SetVisible(state)
end

function RoleModel:SetModelTransformParameter(model_type, res_id, panel_type)
	self.display_model_type = model_type
	self.display_res_id = res_id
	self.display_panel_type = panel_type or DISPLAY_PANEL.FULL_PANEL
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

function RoleModel:SetTrigger(name, is_delay)
	if is_delay == nil then
		is_delay = true
	end
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				if is_delay then
					GlobalTimerQuest:AddDelayTimer(function() main_part:SetTrigger(name) end, 0.1)
				else
					main_part:SetTrigger(name)
				end
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
				GlobalTimerQuest:AddDelayTimer(function() main_part:SetInteger(key, value) end, 0.1)
			end
		end
	end
end

function RoleModel:SetLayer(layer, value)
	if self.draw_obj then
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		if main_part then
			main_part:SetLayer(layer, value)
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
-- 此方法待删除
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
		local asset, bundle = ResPath.GetGoddessWingModel(self.wing_res_id)
		self:SetWingAsset(asset, bundle)
	end
end

function RoleModel:SetModelResInfo(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, ignore_fazhen, ignore_mantle, ignore_zhibao, is_preview, ignore_toushi, ignore_waist, ignore_mask)
	self.info = info
	self.ignore_find = ignore_find
	self.ignore_wing = ignore_wing
	self.ignore_halo = ignore_halo
	self.ignore_weapon = ignore_weapon
	self.ignore_fazhen = ignore_fazhen
	if info == nil then return end
	local prof = info.prof
	local sex = info.sex
	if nil == prof or nil == sex then
		return
	end
	self:UpdateAppearance(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, ignore_fazhen, ignore_mantle, ignore_zhibao, is_preview, ignore_toushi, ignore_waist, ignore_mask)
	self:SetRoleResid(self.role_res_id)
	if not info.is_not_show_weapon then
		self:SetWeaponResid(self.weapon_res_id)
		self:SetWeapon2Resid(self.weapon2_res_id)
	else
		local part_one = self.draw_obj:GetPart(SceneObjPart.Weapon)
		if part_one then
			part_one:RemoveModel()
		end
		local part_two = self.draw_obj:GetPart(SceneObjPart.Weapon2)
		if part_two then
			part_two:RemoveModel()
		end
	end
	self:SetWingResid(self.wing_res_id)
	self:SetHaloResid(self.halo_res_id)
	self:SetZhiBaoResid(self.zhibao_res_id)
	self:SetMantleResid(self.mantle_res_id)
	self:SetFaZhenResid(self.fazhen_res_id)
	self:SetWaistnResid(self.waist_res_id)
	self:SetTouShiResid(self.toushi_res_id)
	self:SetMaskResid(self.mask_res_id)
end

function RoleModel:UpdateAppearance(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, ignore_fazhen, ignore_mantle, ignore_zhibao, is_preview, ignore_toushi, ignore_waist, ignore_mask)
	local prof = info.prof
	local sex = info.sex
	local is_preview = is_preview or false
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
	self.wing_res_id = 0
	self.halo_res_id = 0
	self.weapon2_res_id = 0
	self.zhibao_res_id = 0
	self.mantle_res_id = 0
	self.fazhen_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0

	local wing_index = 0
	local halo_index = 0
	local zhibao_index = 0
	local mantle_index = 0
	local fazhen_index = 0
	local waist_index = 0
	local toushi_index = 0
	local qilinbi_index = 0
	local mask_index = 0
	-- 先查找时装的武器和衣服
	local appearance = info.appearance
	if appearance == nil then
		local shizhuang_part_list = info.shizhuang_part_list
		if shizhuang_part_list then
			appearance = {fashion_body = shizhuang_part_list[2].use_index, fashion_wuqi = shizhuang_part_list[1].use_index}
		end
	else
		wing_index = appearance.wing_used_imageid or 0
		halo_index = appearance.halo_used_imageid or 0
		zhibao_index = appearance.zhibao_used_imageid or 0
		mantle_index = appearance.shenyi_used_imageid or 0
		fazhen_index = appearance.fazhen_image_id or 0
		waist_index = appearance.ugs_waist_img_id or 0
		toushi_index = appearance.ugs_head_wear_img_id or 0
		qilinbi_index = appearance.ugs_kirin_arm_img_id or 0
		mask_index = appearance.ugs_mask_img_id or 0
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

		if not is_preview and appearance.body_use_type == APPEARANCE_BODY_USE_TYPE.APPEARANCE_BODY_USE_TYPE_SHENQI then 		-- 神器衣服形象
			if ShenqiData.Instance then
				local res_id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(appearance.baojia_image_id)
				self.role_res_id = res_id
			end
		end

		if not is_preview and appearance.wuqi_use_type == APPEARANCE_USE_TYPE.APPEARANCE_WUQI_USE_TYPE_SHENQI then 			-- 神器武器形象
			if ShenqiData.Instance then
				self.weapon_res_id = ShenqiData.Instance:GetResCfgByIamgeID(appearance.shengbing_image_id)
			end
		end
		
		if not is_preview and info.baojia_use_image_id and info.baojia_use_image_id ~= 0  then 		-- 神器衣服形象
			if ShenqiData.Instance then
				local res_id = ShenqiData.Instance:GetBaojiaResCfgByInfo(info.baojia_use_image_id,prof,sex)
				self.role_res_id = res_id
			end
		end

		if not is_preview and info.shenbin_use_image_id and info.shenbin_use_image_id ~= 0 then 			-- 神器武器形象
			if ShenqiData.Instance then
				self.weapon_res_id = ShenqiData.Instance:GetResCfgByInfo(info.shenbin_use_image_id,prof,sex)
			end
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
	if halo_config and not ignore_halo then
		if halo_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[halo_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[halo_index]
		end
		if image_cfg then
			self.halo_res_id = image_cfg.res_id
		end
	end
	-- 查找至宝
	if zhibao_index == 0 and not ignore_zhibao then
		if info.zhibao_info then
			zhibao_index = info.zhibao_info.used_imageid or 0
		end
	end
	local zhibao_config = ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto")
	image_cfg = nil
	if zhibao_config and not ignore_zhibao then
		if zhibao_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = zhibao_config.special_img[zhibao_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = zhibao_config.image_list[zhibao_index]
		end
		if image_cfg then
			self.zhibao_res_id = image_cfg.res_id
		end
	end
		-- 查找披风
	if mantle_index == 0 and not ignore_mantle then
		if info.shenyi_info then
			mantle_index = info.shenyi_info.used_imageid or 0
		end
	end
	local mantle_config = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	image_cfg = nil
	if mantle_config and not ignore_mantle then
		if mantle_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = mantle_config.special_img[mantle_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = mantle_config.image_list[mantle_index]
		end
		if image_cfg then
			self.mantle_res_id = image_cfg.res_id
		end
	end

	-- 查找法阵
	if fazhen_index == 0 and not ignore_fazhen then
		if info.fazhen_info then
			fazhen_index = info.fazhen_info.used_imageid or 0
		end
	end

	if not ignore_fazhen then
		local fazhen_config = ConfigManager.Instance:GetAutoConfig("fazhen_cfg_auto")
		local single_cfg = nil
		if fazhen_index > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			single_cfg = fazhen_config.special_img[fazhen_index - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET]
		else
			single_cfg = fazhen_config.image_list[fazhen_index]
		end
		if single_cfg then
			self.fazhen_res_id = single_cfg.res_id or 0
		end
	end

		-- 头饰
	if not ignore_toushi then
		if toushi_index > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			self.toushi_res_id = HeadwearData.Instance:GetSpecialResId(toushi_index - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
		else
			if toushi_index ~= 0 then
				self.toushi_res_id = HeadwearData.Instance:GetResIdByImgId(toushi_index)
			end			
		end
	end

	-- 腰饰
	if not ignore_waist then
		if waist_index > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			self.waist_res_id = WaistData.Instance:GetSpecialResId(waist_index - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
		else
			if waist_index ~= 0 then
				self.waist_res_id = WaistData.Instance:GetResIdByImgId(waist_index)
			end			
		end
	end

	-- 麒麟臂
	-- (怕穿模 带角色的展示不穿麒麟臂)
	if not ignore_qilinbi then
		if qilinbi_index > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			self.qilinbi_res_id = 0--KirinArmData.Instance:GetSpecialResId(qilinbi_index - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET, sex)
		else
			if qilinbi_index ~= 0 then
				self.qilinbi_res_id = 0--KirinArmData.Instance:GetResIdByImgId(qilinbi_index, sex)
			end			
		end
	end

	-- 面饰
	if not ignore_mask then
		if mask_index > COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
			self.mask_res_id = MaskData.Instance:GetSpecialResId(mask_index - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
		else
			if mask_index ~= 0 then
				self.mask_res_id = MaskData.Instance:GetResIdByImgId(mask_index)
			end			
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
	self:SetModelResInfo(self.info, self.ignore_find, self.ignore_wing, self.ignore_halo, self.ignore_weapon)
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
	end, 0)
end

function RoleModel:SetIsNeedListenRoleChange(is_need)
	if is_need then
		if self.listen_role == nil then
			self.listen_role = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_APPERANCE_CHANGE, function()
				if self.display ~= nil then
					local role_vo = GameVoManager.Instance:GetMainRoleVo()
					self:RemoveMount()
					self:ResetRotation()
					self:SetModelResInfo(role_vo, nil, nil, nil, nil, true)	
				end			
			end)
		end
	else
		if self.listen_role ~= nil then
			GlobalEventSystem:UnBind(self.listen_role)
			self.listen_role  = nil
		end
	end
end

function RoleModel:SetHeadRes(bundle, name)
	local part = self.draw_obj:GetPart(SceneObjPart.Head)
	part:ChangeModel(bundle, name)
end

function RoleModel:RemoveHead()
	local part = self.draw_obj:GetPart(SceneObjPart.Head)
	part:RemoveModel()
end