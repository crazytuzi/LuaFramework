AdvanceEquipView = AdvanceEquipView or BaseClass(BaseView)

local ATTR_VALUE_COLOR = "B7D3F9FF"
local NEW_TABINDEX = {[TabIndex.mount_jinjie] = 1,
					[TabIndex.wing_jinjie] = 2,
					[TabIndex.halo_jinjie] = 3,
					[TabIndex.fight_mount] = 4,
					[TabIndex.meiren_guanghuan] = 5,
					[TabIndex.halidom_jinjie] = 6,
					[TabIndex.shengong_jinjie] = 7,
					[TabIndex.shenyi_jinjie] = 8,
					[TabIndex.headwear] = 9,
					[TabIndex.mask] = 10,
					[TabIndex.waist] = 11,
					[TabIndex.bead] = 12,
					[TabIndex.fabao] = 13,
					[TabIndex.kirin_arm] = 14,}

function AdvanceEquipView:__init()
	self.ui_config = {"uis/views/advanceview", "JingjieZhuangBeiView"}
	self.play_audio = true
	self.now_show_index = -1
	self.select_item_index = 0
	self.temp_res_id = 0
	self.skill_icon_res = ""
	self.active_skill_level = 0
	self.percent_icon_bundle = "uis/images"
	self.percent_icon_asset = ""
	self.all_normal_equip_attr_list = {}
	self.special_equip_attr_list = {}
	self.all_equip_percent_value = 0
	self.equip_min_level = 0
end

function AdvanceEquipView:ReleaseCallBack()
	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if nil ~= self.wingmodel then
		self.wingmodel:DeleteMe()
		self.wingmodel = nil
	end

	if nil ~= self.fazhen_model then
		self.fazhen_model:DeleteMe()
		self.fazhen_model = nil
	end

	for _, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	-- 清理变量
	self.display = nil
	self.wingdisplay = nil
	self.fazhen_display = nil
	self.attr_var_list = nil
	self.equip_item_var_list = nil
	self.skill_icon = nil
	self.fight_power = nil
	self.need_prop_num = nil
	self.had_prop_num = nil
	self.prop_name = nil
	self.equip_name = nil
	self.equip_level = nil
	self.skill_active_level = nil
	self.skill_detail = nil
	self.percent_attr_name = nil
	self.percent_attr_value = nil
	self.button_text = nil
	self.upgrade_btn = nil
	self.show_active_tip = nil
	self.percen_attr_icon = nil
	self.cur_equip_level = nil
	self.skill_var_name = nil
	self.next_percent_attr_var_value = nil
	self.next_percent_attr_var_level = nil
	self.equip_min_level_var = nil
	self.xu_li = nil
	self.show_maxattr = nil
	self.item_cell_toggle_group = nil
	self.foot_dis = nil
	self.upgrade_des = nil
	-- for i = 1, 3 do
	-- 	self["foot_dis_" .. i] = nil
	-- end	
end

function AdvanceEquipView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))
	self:ListenEvent("OnClickAttrPreview", BindTool.Bind(self.OnClickAttrPreview, self))
	self:ListenEvent("OnClickEquipSkill", BindTool.Bind(self.OnClickEquipSkill, self))

	self.item_cell_toggle_group = self:FindObj("ItemCellToggleGroup")

	self.equip_item_var_list = {}
	self.item_cell_list = {}
	for i = 1, 4 do
		self.equip_item_var_list[i] = {
			remind = self:FindVariable("ShowItemRemind"..i),
			level = self:FindVariable("ItemLevel"..i),
		}

		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("ItemCellRoot"..i))
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		item:SetToggleGroup(self.item_cell_toggle_group.toggle_group)
		self.item_cell_list[i] = item
	end

	self.attr_var_list = {}
	for i = 1, 4 do
		self.attr_var_list[i] = {
			text = self:FindVariable("Attr" .. i),
			show = self:FindVariable("ShowAttr" .. i),
			icon = self:FindVariable("AttrIcon" .. i),
			next_attr = self:FindVariable('NextAttr' .. i),
			attr_name = self:FindVariable("AttrName" .. i)
		}
	end

	self.skill_icon = self:FindVariable("SkillIcon")
	self.fight_power = self:FindVariable("FightPower")
	self.need_prop_num = self:FindVariable("NeedPropNum")
	self.had_prop_num = self:FindVariable("BagPropNum")
	self.prop_name = self:FindVariable("PropName")
	self.equip_name = self:FindVariable("EquipName")
	self.equip_level = self:FindVariable("EquipLevel")
	self.skill_active_level = self:FindVariable("SkillActiveLevel")
	self.skill_detail = self:FindVariable("SkillDetail")
	self.percent_attr_name = self:FindVariable("PercentAttrName")
	self.percent_attr_value = self:FindVariable("PercentAttrValue")
	self.button_text = self:FindVariable("ButtonText")
	self.show_active_tip = self:FindVariable("ShowActiveTip")
	self.percen_attr_icon = self:FindVariable("PercentAttrIcon")
	self.cur_equip_level = self:FindVariable("CurEquipLevel")
	self.skill_var_name = self:FindVariable("SkillName")
	self.next_percent_attr_var_value = self:FindVariable("NextPercentAttr")
	self.next_percent_attr_var_level = self:FindVariable("NextPercentAttrLevel")
	self.equip_min_level_var = self:FindVariable("EquipMinLevel")
	self.xu_li = self:FindVariable("XuLi")
	self.show_maxattr = self:FindVariable("ShowMaxAttr")
	self.upgrade_des = self:FindVariable("UpgradeDes")

	self.upgrade_btn = self:FindObj("UpgradeBtn")

	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self.wingdisplay = self:FindObj("WingDisplay")
	self.wingmodel = RoleModel.New("jinjie_mount_panel", 1000)
	self.wingmodel:SetDisplay(self.wingdisplay.ui3d_display)

	self.fazhen_display = self:FindObj("FaZhenDisplay")
	self.fazhen_model = RoleModel.New("jinjie_fazhen_huanhua_panel", 1000)
	self.fazhen_model:SetDisplay(self.fazhen_display.ui3d_display)

	self.foot_dis = self:FindObj("FootDis")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot" .. i)
	end

	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	if not IsNil(camera) then
		local random_num = math.random(100, 9999)
		self.foot_dis.ui3d_display:DisplayPerspectiveWithOffset(ui_foot.gameObject, Vector3(random_num, random_num, random_num), Vector3(1, 14, 2.2), Vector3(90, 0, 0))
		self.foot_dis.raw_image.raycastTarget = false
	end
end

function AdvanceEquipView:ShowIndexCallBack(tab_str)
	local index = 1
	if NEW_TABINDEX[tab_str] then
		index = NEW_TABINDEX[tab_str]
	end

	if self.now_show_index < 0 then
		self.now_show_index = index
		if self.model and self.now_show_index == ADVANCE_EQUIP_TYPE.FOOT then
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		elseif self.model then
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
	end
end

function AdvanceEquipView:OpenCallBack()
	self.select_item_index = 0
	self.item_cell_list[self.select_item_index + 1]:SetToggle(true)
	self:Flush()
end

function AdvanceEquipView:CloseCallBack()
	self.now_show_index = -1
	self.equip_cfg = nil
	self.next_equip_cfg = nil
	self.info = nil
	self.temp_res_id = 0
	self.remind_func = nil
	self.equip_skill_cfg = nil
	self.active_skill_level = 0
	self.all_normal_equip_attr_list = {}
	self.special_equip_attr_list = {}
	self.all_equip_percent_value = 0
	self.next_percent_attr_cfg = nil

	self.skill_icon_res = ""
end

function AdvanceEquipView:OnClickClose()
	self:Close()
end

function AdvanceEquipView:OnClickEquipSkill()
	ViewManager.Instance:Open(ViewName.AdvanceEquipSkillView)
end

-- 点击装备格子
function AdvanceEquipView:OnClickItem(index)
	self.select_item_index = index - 1
	self:SetNowInfo()
	self:SetRightInfo()
	self:SetEquipItemInfo()
end

function AdvanceEquipView:OnClickAttrPreview()
	local attr_des = string.format(Language.Advance.PercentAttrDesList[self.now_show_index], (self.all_equip_percent_value / 100).."%")
	self.special_equip_attr_list = {{attr_des = attr_des, bundle = self.percent_icon_bundle, asset = self.percent_icon_asset, show = self.equip_cfg.add_percent > 0}}
	TipsCtrl.Instance:ShowPreferredSizeAttrView(self.all_normal_equip_attr_list, self.special_equip_attr_list, 0)
end

function AdvanceEquipView:OnClickUpLevel()
	if nil == self.next_equip_cfg then return end

	local item_data = self.equip_cfg.item or self.equip_cfg.uplevel_item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	if had_prop_num < item_data.num then
		-- 物品不足，弹出TIP框
		local stuff_item_id = item_data.item_id
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[stuff_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(stuff_item_id)
			return
		end

		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(stuff_item_id, 2)
		-- 	return
		-- end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)
		return
	end

	if self.now_show_index == ADVANCE_EQUIP_TYPE.MOUNT then
		MountCtrl.Instance:SendMountUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.WING then
		WingCtrl.Instance:SendWingUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.HALO then
		HaloCtrl.Instance:SendHaloUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.FAZHEN then
		FaZhenCtrl.Instance:SendFaZhenOpera(FAZHEN_OPERA_REQ_TYPE.FAZHEN_OPERA_REQ_TYPE_EQUIP_UPGRADE, self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.BEAUTY_HALO then
 		SpiritCtrl.Instance:SendJinglingGuanghuanUplevelEquip(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.HALIDOM then
		SpiritCtrl.Instance:SendJinglingFazhenUplevelEquip(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.FOOT then
		ShengongCtrl.Instance:SendShengongUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.MANTLE then
		ShenyiCtrl.Instance:SendShenyiUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.HEADWEAR then
		HeadwearCtrl.Instance:SendHeadwearUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.MASK then
		MaskCtrl.Instance:SendMaskUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.WAIST then
		WaistCtrl.Instance:SendWaistUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.BEAD then
		BeadCtrl.Instance:SendBeadUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.FABAO then
		FaBaoCtrl.Instance:SendFaBaoUpLevelReq(self.select_item_index)

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.KIRINARM then
		KirinArmCtrl.Instance:SendKirinArmUpLevelReq(self.select_item_index)
	end
end

function AdvanceEquipView:SetModel()
	if nil == self.info or nil == next(self.info) then return end

	self:SetMountModel()
	self:SetWingModel()
	self:SetHaloModel()
	self:SetFightMoutModel()
	self:SetShengongModel()
	self:SetShenyiModel()
	self:SetFootModel()
	self:SetPiFengModel()
	self:SetHeadwearModel()
	self:SetMaskModel()
	self:SetWaistModel()
	self:SetBeadModel()
	self:SetFaBaoModel()
	self:SetKirinArmModel()
end

function AdvanceEquipView:SetMountModel()
	--坐骑
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.MOUNT then
		return
	end
	local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(self.info.grade)
	if nil == mount_grade_cfg then return end
	local image_cfg = MountData.Instance:GetMountImageCfg(mount_grade_cfg.image_id)
	if nil == image_cfg then return end
	
	if self.temp_res_id == image_cfg.res_id then return end
	self.model:ClearModel()

	local bundle, asset = ResPath.GetMountModel(image_cfg.res_id)
	self.wingmodel:SetMainAsset(bundle, asset)

	self.temp_res_id = image_cfg.res_id
	self.wingdisplay:SetActive(true)
	self.display:SetActive(false)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetWingModel()
	--翅膀
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.WING then
		self.model:SetWingResid(0)
		return
	end

	local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(self.info.grade)
	if wing_grade_cfg == nil then return end

	local image_cfg = WingData.Instance:GetWingImageCfg(wing_grade_cfg.image_id)
	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.model:ClearModel()
 	self.model:SetDisplayPositionAndRotation("jinjie_wing_panel")
	local bundle, asset = ResPath.GetWingModel(image_cfg.res_id)
	self.model:SetMainAsset(bundle, asset)
	self.model:SetLayer(1, 1.0)
	self.temp_res_id = image_cfg.res_id                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetHaloModel()
	--光环
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.HALO then
		self.model:SetHaloResid(0)
		return
	end

	local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.info.grade)
	if halo_grade_cfg == nil then return end

	local image_cfg = HaloData.Instance:GetHaloImageCfg(halo_grade_cfg.image_id)
	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.model:ClearModel()

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local model_info = {}
	model_info.halo_info = {used_imageid = halo_grade_cfg.image_id}
	model_info.prof = PlayerData.Instance:GetRoleBaseProf()
	model_info.sex = vo.sex
	model_info.is_not_show_weapon = true
	model_info.shizhuang_part_list = {{use_index = 0}, {use_index = vo.appearance.fashion_body}}
 	self.model:SetDisplayPositionAndRotation("jinjie_halo_panel")
	self.model:SetModelResInfo(model_info, true, true, false, true)
	self.temp_res_id = image_cfg.res_id
	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetFightMoutModel()
	--法正
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.FAZHEN then
		return
	end

	local mount_grade_cfg = FaZhenData.Instance:GetMountGradeCfg(self.info.grade)
	if mount_grade_cfg == nil then return end

	local image_cfg = FaZhenData.Instance:GetMountImageCfg(mount_grade_cfg.image_id)
	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.model:ClearModel()

	local bundle, asset = ResPath.GetFightMountModel(image_cfg.res_id)
	self.fazhen_model:SetMainAsset(bundle, asset)
	self.temp_res_id = image_cfg.res_id
	self.wingdisplay:SetActive(false)
	self.display:SetActive(false)
	self.fazhen_display:SetActive(true)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetShengongModel()
	--美人光环
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.BEAUTY_HALO then
		return
	end
	if self.temp_res_id == BeautyHaloData.Instance:GetShowShengongRes(self.info.grade) then return end

	local model_info = {}
	model_info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	model_info.weapon_res_id = BeautyHaloData.Instance:GetShowShengongRes(self.info.grade) or -1
	local beauty_halo_info = BeautyHaloData.Instance:GetBeautyHaloInfo()
	local mount_grade_cfg = BeautyHaloData.Instance:GetShowBeautyHaloGradeCfg(beauty_halo_info.show_grade)
	local image_cfg = BeautyHaloData.Instance:GetImageCfg()
	if mount_grade_cfg == nil then return end

	local beauty_seq = BeautyData.Instance:GetCurBattleBeauty()
	local beautt_cfg = BeautyData.Instance:GetBeautyActiveInfo(beauty_seq) or {}
	local res_id = beautt_cfg.model or 11101
	self.model:SetDisplayPositionAndRotation("jinjie_common_panel")
	local bundle, asset = ResPath.GetGoddessNotLModel(res_id)
	self.model:SetMainAsset(bundle, asset)
 
	self.model:SetHaloResid(image_cfg[mount_grade_cfg.image_id].res_id, true)

	self.temp_res_id = model_info.weapon_res_id
	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetShenyiModel()
	--圣物
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.HALIDOM then
		return
	end

	if self.temp_res_id == HalidomData.Instance:GetShowShenyiRes(self.info.grade) then return end
	self.model:ClearModel()
	local mount_grade_cfg = HalidomData.Instance:GetHalidomGradeCfg(self.info.grade)
	local image_cfg = HalidomData.Instance:GetImageCfg(mount_grade_cfg.image_id)
	 
	local bundle, asset = ResPath.GetAdvanceEquipIcon("halidom_name_" .. self.info.grade)
 	self.model:SetDisplayPositionAndRotation("jinjie_mantel_panel")
	if image_cfg.image_id then
		self.model:SetMainAsset(ResPath.GetBaoJuModel(image_cfg.res_id))
		self.model:SetLayer(1, 1.0)
	end
	self.temp_res_id = HalidomData.Instance:GetShowShenyiRes(self.info.grade) or -1
	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetFootModel()
	--足迹
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.FOOT then
		return
	end
	local foot_info = ShengongData.Instance:GetShengongInfo()
	local show_grade = foot_info.show_grade
	local grade_cfg = ShengongData.Instance:GetShengongShowGradeCfg(foot_info.show_grade)
	local used_imageid = grade_cfg and grade_cfg.image_id or 0
	local image_cfg = ShengongData.Instance:GetImageListInfo(used_imageid)
	if self.temp_res_id == image_cfg.res_id then return end
	if image_cfg == nil then return end
	for i = 1, 3 do
		local bundle, asset = ResPath.GetFootEffec("Foot_" .. image_cfg.res_id)
		PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
			if nil == prefab then
				return
			end
			if self.foot_parent[i] then
				local parent_transform = self.foot_parent[i].transform
				for j = 0, parent_transform.childCount - 1 do
					GameObject.Destroy(parent_transform:GetChild(j).gameObject)
				end
				local obj = GameObject.Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(parent_transform, false)
				PrefabPool.Instance:Free(prefab)
			end
		end)
	end
	self.temp_res_id = image_cfg.res_id
	self.foot_dis:SetActive(true)
	self.wingdisplay:SetActive(false)
	self.display:SetActive(false)
	self.fazhen_display:SetActive(false)
end

function AdvanceEquipView:SetPiFengModel()
	--披风
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.MANTLE then
		return
	end

	local image_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.info.grade)
	if not image_grade_cfg then return end

	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg(image_grade_cfg.image_id)
	if nil == image_cfg then return end	
	local cfg = self.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MANTLE], image_cfg.res_id, DISPLAY_PANEL.FULL_PANEL)
	self.model:SetTransform(cfg)
	local main_role = Scene.Instance:GetMainRole()
 	self.model:SetDisplayPositionAndRotation("jinjie_common_panel")
	self.model:SetRoleResid(main_role:GetRoleResId())
	self.model:SetMantleResid(image_cfg.res_id)
	self.temp_res_id = image_cfg.res_id

	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetHeadwearModel()
	--头饰
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.HEADWEAR then
		return
	end

	local image_grade_cfg = HeadwearData.Instance:GetHeadwearGradeCfg(self.info.grade)
	if not image_grade_cfg then return end

	local image_cfg = HeadwearData.Instance:GetHeadwearImageCfg(image_grade_cfg.image_id)
	if nil == image_cfg then return end	
	self.model:ClearModel()
	local main_role = Scene.Instance:GetMainRole()
	self.model:SetRoleResid(main_role:GetRoleResId())
	self.model:SetTouShiResid(image_cfg.res_id)
	self.temp_res_id = image_cfg.res_id

	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetMaskModel()
	--面饰
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.MASK then
		return
	end

	local image_grade_cfg = MaskData.Instance:GetMaskGradeCfg(self.info.grade)
	if not image_grade_cfg then return end

	local image_cfg = MaskData.Instance:GetMaskImageCfg(image_grade_cfg.image_id)
	if nil == image_cfg then return end	
	self.model:ClearModel()
	local main_role = Scene.Instance:GetMainRole()
	self.model:SetRoleResid(main_role:GetRoleResId())
	self.model:SetMaskResid(image_cfg.res_id)
	self.temp_res_id = image_cfg.res_id

	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetWaistModel()
	--腰饰
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.WAIST then
		return
	end

	local image_grade_cfg = WaistData.Instance:GetWaistGradeCfg(self.info.grade)
	if not image_grade_cfg then return end

	local image_cfg = WaistData.Instance:GetWaistImageCfg(image_grade_cfg.image_id)
	if nil == image_cfg then return end	
	self.model:ClearModel()
	local main_role = Scene.Instance:GetMainRole()
	self.model:SetRoleResid(main_role:GetRoleResId())
	self.model:SetWaistnResid(image_cfg.res_id)
	self.temp_res_id = image_cfg.res_id

	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetBeadModel()
	--灵珠
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.BEAD then
		return
	end

	local image_grade_cfg = BeadData.Instance:GetBeadGradeCfg(self.info.grade)
	if not image_grade_cfg then return end

	local image_cfg = BeadData.Instance:GetBeadImageCfg(image_grade_cfg.image_id)
	if nil == image_cfg then return end	
	self.model:ClearModel()
	local bundle, asset = ResPath.GetLingZhuModel(image_cfg.res_id, true)	
	self.model:SetMainAsset(bundle, asset, function ()
	end) 
	self.model:SetDisplayPositionAndRotation("dress_up_bead")
	self.temp_res_id = image_cfg.res_id

	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetFaBaoModel()
	--法宝
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.FABAO then
		return
	end

	local image_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.info.grade)
	if not image_grade_cfg then return end

	local image_cfg = FaBaoData.Instance:GetFaBaoImageCfg(image_grade_cfg.image_id)
	if nil == image_cfg then return end	
	self.model:ClearModel()
	local bundle, asset = ResPath.GetXianBaoModel(image_cfg.res_id)	
	self.model:SetMainAsset(bundle, asset, function ()
	end) 
	self.model:SetDisplayPositionAndRotation("dress_up_fabao")
	self.model:SetLayer(1, 1.0)
	-- self.model:SetTrigger("rest")
	self.temp_res_id = image_cfg.res_id

	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetKirinArmModel()
	--麒麟臂
	if self.now_show_index ~= ADVANCE_EQUIP_TYPE.KIRINARM then
		return
	end

	local image_grade_cfg = KirinArmData.Instance:GetKirinArmGradeCfg(self.info.grade)
	if not image_grade_cfg then return end

	local image_cfg = KirinArmData.Instance:GetKirinArmImageCfg(image_grade_cfg.image_id)
	if nil == image_cfg then return end	
	self.model:ClearModel()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local show_res_id = KirinArmData.Instance:GetResIdByImgId(image_cfg.image_id, role_vo.sex, true)
	local bundle, asset = ResPath.GetQilinBiModel(show_res_id, role_vo.sex)
	self.model:SetMainAsset(bundle, asset)
	self.model:SetDisplayPositionAndRotation("dress_up_kirin_arm")
	self.temp_res_id = image_cfg.res_id

	self.wingdisplay:SetActive(false)
	self.display:SetActive(true)
	self.fazhen_display:SetActive(false)
	self.foot_dis:SetActive(false)
end

function AdvanceEquipView:SetRightInfo()
	for _, v in pairs(self.attr_var_list) do
		v.show:SetValue(false)
	end

	if nil == self.info or nil == next(self.info) or nil == self.equip_cfg then return end

	self:SetAttr()
	self.skill_icon:SetAsset(ResPath.GetAdvanceEquipIcon(self.skill_icon_res))

	self.equip_level:SetValue(self.equip_cfg.equip_level)
	self.equip_name:SetValue(self.equip_cfg.zhuangbei_name or "")

	self.percent_attr_name:SetValue(Language.Advance.PercentAttrNameList[self.now_show_index] or "")
	self.percent_attr_value:SetValue(self.equip_cfg.add_percent	/ 100)
	local level = AdvanceData.Instance:GetEquiplevel(self.info.equip_skill_level + 1)
	self.skill_active_level:SetValue(level)
	self.show_active_tip:SetValue(self.info.equip_skill_level < 6)
	self.percen_attr_icon:SetAsset(self.percent_icon_bundle, self.percent_icon_asset)
	self.cur_equip_level:SetValue(self.info.equip_skill_level)
	self.upgrade_des:SetValue(self.info.equip_skill_level > 0 and Language.Common.UpGrade or Language.Common.Activate)
	self.equip_min_level_var:SetValue(self.equip_min_level)

	local xuli = AdvanceData.Instance:GetJinjieGaugeCount() or 0
	self.xu_li:SetValue(xuli)

	if nil ~= self.equip_skill_cfg then
		local cur_desc = ""
		cur_desc = string.gsub(self.equip_skill_cfg.skill_desc, "%b()%%", function (str)
			return (tonumber(self.equip_skill_cfg[string.sub(str, 2, -3)]) / 1000)
		end)
		cur_desc = string.gsub(cur_desc, "%b[]%%", function (str)
			return (tonumber(self.equip_skill_cfg[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		cur_desc = string.gsub(cur_desc, "%[.-%]", function (str)
			return self.equip_skill_cfg[string.sub(str, 2, -2)]
		end)
		self.skill_detail:SetValue(cur_desc)

		self.skill_var_name:SetValue(self.equip_skill_cfg.skill_name)
	end

	if nil ~= self.next_equip_cfg then
		self.button_text:SetValue(Language.Role.JinJie)
		self.upgrade_btn.grayscale.GrayScale = 0
		self.upgrade_btn.button.interactable = true
	else
		self.button_text:SetValue(Language.Common.YiManJi)
		self.upgrade_btn.grayscale.GrayScale = 255
		self.upgrade_btn.button.interactable = false
	end

	if nil ~= self.next_percent_attr_cfg then
		self.next_percent_attr_var_level:SetValue(self.next_percent_attr_cfg.equip_level)
		self.next_percent_attr_var_value:SetValue(self.next_percent_attr_cfg.add_percent / 100)
		self.show_maxattr:SetValue(false)
	else
		self.next_percent_attr_var_value:SetValue(0)
		self.show_maxattr:SetValue(true)
	end

	self:SetPropInfo()
end

function AdvanceEquipView:SetPropInfo()
	local item_data = self.equip_cfg.item or self.equip_cfg.uplevel_item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	self.need_prop_num:SetValue(nil ~= self.next_equip_cfg and item_data.num or 0)

	local bag_num_str = ""
	if had_prop_num < item_data.num then
		bag_num_str = string.format(Language.Mount.ShowRedNum, had_prop_num)
	else
		bag_num_str = string.format(Language.Mount.ShowGreenNum, had_prop_num)
	end
	self.had_prop_num:SetValue(bag_num_str)

	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	if nil == item_cfg then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)
end

function AdvanceEquipView:SetAttr()
	local attr_list = {}
	local is_zero = false
	if self.equip_cfg.equip_level <= 0 then
		attr_list = CommonDataManager.GetAttributteNoUnderline(self.next_equip_cfg)
		is_zero = true
		self.fight_power:SetValue(0)
	else
		attr_list = CommonDataManager.GetAttributteNoUnderline(self.equip_cfg)
		self.fight_power:SetValue(CommonDataManager.GetCapability(attr_list))
	end

	local next_attr_list = CommonDataManager.GetAttributteNoUnderline(self.next_equip_cfg)

	local attr_count = 1
	local value_str = ""
	local temp_value = 0
	for k, v in pairs(attr_list) do
		if v > 0 and nil ~= self.attr_var_list[attr_count] then
			self.attr_var_list[attr_count].show:SetValue(true)
			temp_value = is_zero and 0 or v
			value_str = string.format(Language.Common.ToColor, ATTR_VALUE_COLOR, temp_value)
			self.attr_var_list[attr_count].text:SetValue(value_str)
			-- self.attr_var_list[attr_count].icon:SetAsset(ResPath.GetBaseAttrIcon(k))
			self.attr_var_list[attr_count].next_attr:SetValue(next_attr_list[k] - attr_list[k])
			self.attr_var_list[attr_count].attr_name:SetValue(Language.Common.AttrNameNoUnderline[k] .. ":")

			attr_count = attr_count + 1
		end
	end
end

function AdvanceEquipView:SetEquipItemInfo()
	if nil == self.info or nil == next(self.info) then return end

	local level_list = self.info.equip_level_list
	local equip_cfg = nil

	for k, v in pairs(self.equip_item_var_list) do
		equip_cfg = self.get_now_equip_cfg_func(k - 1, level_list[k - 1] or 0)
		if nil ~= equip_cfg then
			self.item_cell_list[k]:SetData({item_id = equip_cfg.item.item_id, is_bind = 0})
		end
		v.remind:SetValue(self.remind_func(k - 1) > 0)
		v.level:SetValue(level_list[k - 1] or 0)
	end
end

function AdvanceEquipView:SetNowInfo()
	self.all_equip_percent_value = 0
	if self.now_show_index == ADVANCE_EQUIP_TYPE.MOUNT then	-- 坐骑装备
		self.info = MountData.Instance:GetMountInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(MountData.Instance.CalEquipRemind, MountData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(MountData.Instance.GetEquipInfoCfg, MountData.Instance)

			self.skill_icon_res = "mount_skill_icon"
			self.percent_icon_asset = "icon_info_zq_attr"
		end
		local equip_level = 0
		if not self.info.equip_level_list then
			equip_level = 0
		else
			equip_level = self.info.equip_level_list[self.select_item_index] or 0
		end
		
		self.equip_cfg = MountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = MountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MOUNT, temp_level)
		self.active_skill_level = MountData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = MountData.Instance:GetMountEquipAttrSum()
		self.next_percent_attr_cfg = MountData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = MountData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = MountData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.WING then		-- 羽翼装备
		self.info = WingData.Instance:GetWingInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(WingData.Instance.CalEquipRemind, WingData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(WingData.Instance.GetEquipInfoCfg, WingData.Instance)

			self.skill_icon_res = "wing_skill_icon"
			self.percent_icon_asset = "icon_info_yy_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = WingData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = WingData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WING, temp_level)
		self.active_skill_level = WingData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = WingData.Instance:GetWingEquipAttrSum()
		self.next_percent_attr_cfg = WingData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = WingData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = WingData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.HALO then		-- 光环装备
		self.info = HaloData.Instance:GetHaloInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(HaloData.Instance.CalEquipRemind, HaloData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(HaloData.Instance.GetEquipInfoCfg, HaloData.Instance)

			self.skill_icon_res = "halo_skill_icon"
			self.percent_icon_asset = "icon_info_halo_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = HaloData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = HaloData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HALO, temp_level)
		self.active_skill_level = HaloData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = HaloData.Instance:GetHaloEquipAttrSum()
		self.next_percent_attr_cfg = HaloData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = HaloData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = HaloData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.FAZHEN then		-- 战斗坐骑装备
		self.info = FaZhenData.Instance:GetFightMountInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FaZhenData.Instance.CalEquipRemind, FaZhenData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FaZhenData.Instance.GetEquipInfoCfg, FaZhenData.Instance)

			self.skill_icon_res = "shengong_skill_icon"
			self.percent_icon_asset = "icon_info_zdzq_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FaZhenData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FaZhenData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FIGHT_MOUNT, temp_level)
		self.active_skill_level = FaZhenData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = FaZhenData.Instance:GetMountEquipAttrSum()
		self.next_percent_attr_cfg = FaZhenData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = FaZhenData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FaZhenData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.BEAUTY_HALO then		-- 神弓装备
		self.info = BeautyHaloData.Instance:GetBeautyHaloInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(BeautyHaloData.Instance.CalEquipRemind, BeautyHaloData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(BeautyHaloData.Instance.GetEquipInfoCfg, BeautyHaloData.Instance)

			self.skill_icon_res = "shenyi_skill_icon"
			self.percent_icon_asset = "icon_info_gong_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = BeautyHaloData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = BeautyHaloData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG, temp_level)
		self.active_skill_level = BeautyHaloData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = BeautyHaloData.Instance:GetEquipAttrSum()
		self.next_percent_attr_cfg = BeautyHaloData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = BeautyHaloData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = BeautyHaloData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.HALIDOM then		-- 神翼装备
		self.info = HalidomData.Instance:GetHalidomInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(HalidomData.Instance.CalEquipRemind, HalidomData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(HalidomData.Instance.GetEquipInfoCfg, HalidomData.Instance)

			self.skill_icon_res = "fight_mount_skill_icon"
			self.percent_icon_asset = "icon_info_sy_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = HalidomData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = HalidomData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENYI, temp_level)
		self.active_skill_level = HalidomData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = HalidomData.Instance:GetShenyiEquipAttrSum()
		self.next_percent_attr_cfg = HalidomData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = HalidomData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = HalidomData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.FOOT then		-- 足迹装备
		self.info = ShengongData.Instance:GetShengongInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(ShengongData.Instance.CalEquipRemind, ShengongData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(ShengongData.Instance.GetEquipInfoCfg, ShengongData.Instance)

			self.skill_icon_res = "foot_skill_icon"
			self.percent_icon_asset = "icon_info_zj_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = ShengongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = ShengongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT, temp_level)
		self.active_skill_level = ShengongData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = ShengongData.Instance:GetFootEquipAttrSum()
		self.next_percent_attr_cfg = ShengongData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = ShengongData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = ShengongData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.MANTLE then		-- 披风装备
		self.info = ShenyiData.Instance:GetShengongInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(ShenyiData.Instance.CalEquipRemind, ShenyiData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(ShenyiData.Instance.GetEquipInfoCfg, ShenyiData.Instance)

			self.skill_icon_res = "pifen_skill_icon"
			self.percent_icon_asset = "icon_info_zj_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = ShenyiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = ShenyiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_PIFENG_PRINT, temp_level)
		self.active_skill_level = ShenyiData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = ShenyiData.Instance:GetFootEquipAttrSum()
		self.next_percent_attr_cfg = ShenyiData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = ShenyiData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = ShenyiData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.HEADWEAR then		-- 头饰装备
		self.info = HeadwearData.Instance:GetHeadwearInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(HeadwearData.Instance.CalEquipRemind, HeadwearData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(HeadwearData.Instance.GetEquipInfoCfg, HeadwearData.Instance)

			self.skill_icon_res = "headwear_skill_icon"
			self.percent_icon_asset = "icon_info_headwear_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = HeadwearData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = HeadwearData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = DressUpData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HEADWEAR, temp_level)
		self.active_skill_level = HeadwearData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = HeadwearData.Instance:GetHeadwearEquipAttrSum()
		self.next_percent_attr_cfg = HeadwearData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = HeadwearData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = HeadwearData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.MASK then		-- 面饰装备
		self.info = MaskData.Instance:GetMaskInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(MaskData.Instance.CalEquipRemind, MaskData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(MaskData.Instance.GetEquipInfoCfg, MaskData.Instance)

			self.skill_icon_res = "mask_skill_icon"
			self.percent_icon_asset = "icon_info_mask_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = MaskData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = MaskData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = DressUpData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MASK, temp_level)
		self.active_skill_level = MaskData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = MaskData.Instance:GetMaskEquipAttrSum()
		self.next_percent_attr_cfg = MaskData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = MaskData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = MaskData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.WAIST then		-- 腰饰装备
		self.info = WaistData.Instance:GetWaistInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(WaistData.Instance.CalEquipRemind, WaistData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(WaistData.Instance.GetEquipInfoCfg, WaistData.Instance)

			self.skill_icon_res = "waist_skill_icon"
			self.percent_icon_asset = "icon_info_waist_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = WaistData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = WaistData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = DressUpData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WAIST, temp_level)
		self.active_skill_level = WaistData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = WaistData.Instance:GetWaistEquipAttrSum()
		self.next_percent_attr_cfg = WaistData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = WaistData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = WaistData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.BEAD then		-- 灵珠装备
		self.info = BeadData.Instance:GetBeadInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(BeadData.Instance.CalEquipRemind, BeadData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(BeadData.Instance.GetEquipInfoCfg, BeadData.Instance)

			self.skill_icon_res = "bead_skill_icon"
			self.percent_icon_asset = "icon_info_bead_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = BeadData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = BeadData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = DressUpData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_BEAD, temp_level)
		self.active_skill_level = BeadData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = BeadData.Instance:GetBeadEquipAttrSum()
		self.next_percent_attr_cfg = BeadData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = BeadData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = BeadData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.FABAO then		-- 法宝装备
		self.info = FaBaoData.Instance:GetFaBaoInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FaBaoData.Instance.CalEquipRemind, FaBaoData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FaBaoData.Instance.GetEquipInfoCfg, FaBaoData.Instance)

			self.skill_icon_res = "fabao_skill_icon"
			self.percent_icon_asset = "icon_info_fabao_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FaBaoData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FaBaoData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = DressUpData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FABAO, temp_level)
		self.active_skill_level = FaBaoData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = FaBaoData.Instance:GetFaBaoEquipAttrSum()
		self.next_percent_attr_cfg = FaBaoData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = FaBaoData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FaBaoData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == ADVANCE_EQUIP_TYPE.KIRINARM then		-- 麒麟臂装备
		self.info = KirinArmData.Instance:GetKirinArmInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(KirinArmData.Instance.CalEquipRemind, KirinArmData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(KirinArmData.Instance.GetEquipInfoCfg, KirinArmData.Instance)

			self.skill_icon_res = "kirin_arm_skill_icon"
			self.percent_icon_asset = "icon_info_kirin_arm_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = KirinArmData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = KirinArmData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = DressUpData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_KIRINARM, temp_level)
		self.active_skill_level = KirinArmData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = KirinArmData.Instance:GetKirinArmEquipAttrSum()
		self.next_percent_attr_cfg = KirinArmData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = KirinArmData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = KirinArmData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	end
end

function AdvanceEquipView:OnFlush(param_list)
	self:SetNowInfo()
	self:SetModel()
	self:SetRightInfo()
	self:SetEquipItemInfo()
end