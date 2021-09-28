AdvanceEquipView = AdvanceEquipView or BaseClass(BaseView)

-- local ATTR_VALUE_COLOR = "B7D3F9FF"

local DISPLAYNAME = {
	[7005001] = "equip_jinjie_panel_mount_special_1",
	[7113001] = "equip_jinjie_panel_fight_mount_special_1"
}

SPECIAL_TYPE = {
	Mount = "Mount",
	FightMount = "FightMount"
}

function AdvanceEquipView:__init()
	self.ui_config = {"uis/views/advanceview_prefab", "JingjieZhuangBeiView"}
	self.play_audio = true
	self.now_show_index = -1
	self.select_item_index = 0
	self.temp_res_id = 0
	self.skill_icon_res = ""
	self.active_skill_level = 0
	self.percent_icon_bundle = "uis/images_atlas"
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

	for _, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	-- 清理变量
	self.display = nil
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
	self.hide_max_level = nil
	self.show_max_level = nil
	self.upgrade_btn = nil
	self.show_active_tip = nil
	self.percen_attr_icon = nil
	self.cur_equip_level = nil
	self.skill_var_name = nil
	self.next_percent_attr_var_value = nil
	self.next_percent_attr_var_level = nil
	self.equip_min_level_var = nil
	self.xu_li = nil
	self.item_cell_toggle_group = nil
	self.is_fazhen = nil
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
	for i = 1, 3 do
		self.attr_var_list[i] = {
			text = self:FindVariable("Attr"..i),
			show = self:FindVariable("ShowAttr"..i),
			icon = self:FindVariable("AttrIcon"..i),
			next_attr = self:FindVariable('NextAttr'..i)
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
	self.hide_max_level = self:FindVariable("HideMaxLevel")
	self.show_max_level = self:FindVariable("ShowMaxLevel")
	self.show_active_tip = self:FindVariable("ShowActiveTip")
	self.percen_attr_icon = self:FindVariable("PercentAttrIcon")
	self.cur_equip_level = self:FindVariable("CurEquipLevel")
	self.skill_var_name = self:FindVariable("SkillName")
	self.next_percent_attr_var_value = self:FindVariable("NextPercentAttr")
	self.next_percent_attr_var_level = self:FindVariable("NextPercentAttrLevel")
	self.equip_min_level_var = self:FindVariable("EquipMinLevel")
	self.xu_li = self:FindVariable("XuLi")
	self.is_fazhen = self:FindVariable("IsFaZhen")

	self.upgrade_btn = self:FindObj("UpgradeBtn")

	self.display = self:FindObj("Display")
	self.model = RoleModel.New("equip_jinjie_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
end

function AdvanceEquipView:ShowIndexCallBack(index)
	if self.now_show_index < 0 then
		self.now_show_index = index
	end
end

function AdvanceEquipView:OpenCallBack()
	self.is_fazhen:SetValue(self.now_show_index ~= TabIndex.goddess_shenyi)
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
	self.model:SetFootState(false)
	self.skill_icon_res = ""
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
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
	self.special_equip_attr_list = {{attr_des = attr_des, bundle = self.percent_icon_bundle, asset = self.percent_icon_asset, show = self.all_equip_percent_value > 0}}
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

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(stuff_item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)
		return
	end

	if self.now_show_index == TabIndex.mount_jinjie then
		MountCtrl.Instance:SendMountUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.wing_jinjie then
		WingCtrl.Instance:SendWingUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.halo_jinjie then
		HaloCtrl.Instance:SendHaloUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.fight_mount then
		FightMountCtrl.Instance:SendFightMountUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.goddess_shengong then
		ShengongCtrl.Instance:SendShengongUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.goddess_shenyi then
		ShenyiCtrl.Instance:SendShenyiUpLevelReq(self.select_item_index)
	elseif self.now_show_index == TabIndex.foot_jinjie then
		FootCtrl.Instance:SendFootUpLevelReq(self.select_item_index)
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
end

function AdvanceEquipView:SetMountModel()
	if self.now_show_index ~= TabIndex.mount_jinjie then
		return
	end

	local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(self.info.grade)

	if nil == mount_grade_cfg then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = MountData.Instance:GetUsedImageId()
	local image_cfg = {}

	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = MountData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = MountData.Instance:GetMountImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end	

	self.model:ClearModel()
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	local bundle, asset = ResPath.GetMountModel(image_cfg.res_id)
	self.model:SetPanelName(self:SetSpecialModle(asset, "Mount"))
	self.model:SetMainAsset(bundle, asset)

	self.temp_res_id = image_cfg.res_id
end

function AdvanceEquipView:SetWingModel()
	if self.now_show_index ~= TabIndex.wing_jinjie then
		return
	end

	local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(self.info.grade)
	if wing_grade_cfg == nil then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = vo.appearance.wing_used_imageid
	local image_cfg = {}
	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = WingData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = WingData.Instance:GetWingImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end

	self.model:ClearModel()
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	local model_info = {}

	model_info.wing_info = {used_imageid = vo.appearance.wing_used_imageid}
	model_info.prof = PlayerData.Instance:GetRoleBaseProf()
	model_info.sex = vo.sex
	model_info.is_not_show_weapon = true
	model_info.shizhuang_part_list = {{use_index = 0}, {use_index = vo.appearance.fashion_body}}

	self.model:SetPanelName("equip_jinjie_panel_wing")
	self.model:SetModelResInfo(model_info, true, false, true, true) -- ResPath.GetWingModel(image_cfg.res_id)

	self.temp_res_id = image_cfg.res_id
end

function AdvanceEquipView:SetHaloModel()
	if self.now_show_index ~= TabIndex.halo_jinjie then
		return
	end

	local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.info.grade)
	if halo_grade_cfg == nil then return end

	local image_cfg = HaloData.Instance:GetHaloImageCfg()[halo_grade_cfg.image_id]
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

	-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HALO], image_cfg.res_id, DISPLAY_PANEL.ADVANCE_EQUIP)

	self.model:SetModelResInfo(model_info, true, true, false, true)

	self.temp_res_id = image_cfg.res_id
end

function AdvanceEquipView:SetFightMoutModel()
	if self.now_show_index ~= TabIndex.fight_mount then
		return
	end

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(self.info.grade)
	if mount_grade_cfg == nil then return end

	--local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = FightMountData.Instance:GetUsedImageId()
	local image_cfg = {}
	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = FightMountData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = FightMountData.Instance:GetMountImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end

	self.model:ClearModel()
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	local bundle, asset = ResPath.GetFightMountModel(image_cfg.res_id)
	self.model:SetPanelName(self:SetSpecialModle(asset, "FightMount"))
	self.model:SetMainAsset(bundle, asset)

	self.temp_res_id = image_cfg.res_id
end

function AdvanceEquipView:SetShengongModel()
	if self.now_show_index ~= TabIndex.goddess_shengong then
		return
	end

	if self.temp_res_id == ShengongData.Instance:GetShowShengongRes(self.info.grade) then return end

	self.model:ClearModel()
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	local model_info = {}
	model_info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	model_info.weapon_res_id = ShengongData.Instance:GetShowShengongRes(self.info.grade) or -1

	self.model:SetGoddessModelResInfo(model_info)
	self.model:SetPanelName("equip_jinjie_panel_huoban")

	self.temp_res_id = model_info.weapon_res_id
end

function AdvanceEquipView:SetShenyiModel()
	if self.now_show_index ~= TabIndex.goddess_shenyi then
		return
	end

	if self.temp_res_id == ShenyiData.Instance:GetShowShenyiRes(self.info.grade) then return end

	self.model:ClearModel()
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	local model_info = {}
	model_info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	model_info.wing_res_id = ShenyiData.Instance:GetShowShenyiRes(self.info.grade) or -1

	self.model:SetGoddessModelResInfo(model_info)
	self.model:SetPanelName("equip_jinjie_panel_huoban")

	self.temp_res_id = model_info.wing_res_id
end

function AdvanceEquipView:SetFootModel()
	if self.now_show_index ~= TabIndex.foot_jinjie then
		return
	end

	local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(self.info.grade)
	if foot_grade_cfg == nil then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = vo.appearance.footprint_used_imageid
	local image_cfg = {}
	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = FootData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = FootData.Instance:GetFootImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end

	self.model:ClearModel()

	local model_info = {}
	model_info.foot_info = {used_imageid = vo.appearance.footprint_used_imageid}
	model_info.prof = PlayerData.Instance:GetRoleBaseProf()
	model_info.sex = vo.sex
	model_info.is_not_show_weapon = true
	model_info.shizhuang_part_list = {{use_index = 0}, {use_index = vo.appearance.fashion_body}}
	self.model:SetPanelName("equip_jinjie_panel_footprint")
	self.model:SetModelResInfo(model_info, false, false, false, false, true)
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	self.temp_res_id = image_cfg.res_id
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
	self.skill_active_level:SetValue(self.active_skill_level)
	self.show_active_tip:SetValue(self.info.equip_skill_level <= 0)
	self.percen_attr_icon:SetAsset(self.percent_icon_bundle, self.percent_icon_asset)
	self.cur_equip_level:SetValue(self.info.equip_skill_level)
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
		self.hide_max_level:SetValue(false)
		self.show_max_level:SetValue(false)
		self.upgrade_btn.grayscale.GrayScale = 0
		self.upgrade_btn.button.interactable = true
	else
		self.button_text:SetValue(Language.Common.YiManJi)
		self.hide_max_level:SetValue(true)
		self.show_max_level:SetValue(true)
		self.upgrade_btn.grayscale.GrayScale = 255
		self.upgrade_btn.button.interactable = false
	end

	if nil ~= self.next_percent_attr_cfg then
		self.next_percent_attr_var_level:SetValue(self.next_percent_attr_cfg.equip_level)
		self.next_percent_attr_var_value:SetValue(self.next_percent_attr_cfg.add_percent / 100)
	else
		self.next_percent_attr_var_value:SetValue(0)
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
		bag_num_str = string.format(Language.Mount.ShowBlueNum, had_prop_num)
	end
	self.had_prop_num:SetValue(bag_num_str)

	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	if nil == item_cfg then return end

	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)

	local data = {}
	data.item_id = item_data.item_id
	self.item_cell:SetData(data)
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
			-- value_str = Language.Common.AttrNameNoUnderline[k]..":"..string.format(Language.Common.ToColor, ATTR_VALUE_COLOR, temp_value)
			value_str = Language.Common.AttrNameNoUnderline[k]..":"..temp_value
			self.attr_var_list[attr_count].text:SetValue(value_str)
			self.attr_var_list[attr_count].icon:SetAsset(ResPath.GetBaseAttrIcon(k))
			self.attr_var_list[attr_count].next_attr:SetValue(next_attr_list[k])

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

	if self.now_show_index == TabIndex.mount_jinjie then	-- 坐骑装备
		self.info = MountData.Instance:GetMountInfo()
		if not self.info or not next(self.info) then return end
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(MountData.Instance.CalEquipRemind, MountData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(MountData.Instance.GetEquipInfoCfg, MountData.Instance)

			self.skill_icon_res = "mount_skill_icon"
			self.percent_icon_asset = "icon_info_zq_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
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

	elseif self.now_show_index == TabIndex.wing_jinjie then		-- 羽翼装备
		self.info = WingData.Instance:GetWingInfo()
		if not self.info or not next(self.info) then return end
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

	elseif self.now_show_index == TabIndex.halo_jinjie then		-- 光环装备
		self.info = HaloData.Instance:GetHaloInfo()
		if not self.info or not next(self.info) then return end
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

	elseif self.now_show_index == TabIndex.fight_mount then		-- 战斗坐骑装备
		self.info = FightMountData.Instance:GetFightMountInfo()
		if not self.info or not next(self.info) then return end
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FightMountData.Instance.CalEquipRemind, FightMountData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FightMountData.Instance.GetEquipInfoCfg, FightMountData.Instance)

			self.skill_icon_res = "fight_mount_skill_icon"
			self.percent_icon_asset = "icon_info_zdzq_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FightMountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FightMountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FIGHT_MOUNT, temp_level)
		self.active_skill_level = FightMountData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = FightMountData.Instance:GetMountEquipAttrSum()
		self.next_percent_attr_cfg = FightMountData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = FightMountData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FightMountData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == TabIndex.goddess_shengong then		-- 神弓装备
		self.info = ShengongData.Instance:GetShengongInfo()
		if not self.info or not next(self.info) then return end
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(ShengongData.Instance.CalEquipRemind, ShengongData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(ShengongData.Instance.GetEquipInfoCfg, ShengongData.Instance)

			self.skill_icon_res = "shengong_skill_icon"
			self.percent_icon_asset = "icon_info_gong_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = ShengongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = ShengongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG, temp_level)
		self.active_skill_level = ShengongData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = ShengongData.Instance:GetShengongEquipAttrSum()
		self.next_percent_attr_cfg = ShengongData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = ShengongData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = ShengongData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == TabIndex.goddess_shenyi then		-- 神翼装备
		self.info = ShenyiData.Instance:GetShenyiInfo()
		if not self.info or not next(self.info) then return end
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(ShenyiData.Instance.CalEquipRemind, ShenyiData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(ShenyiData.Instance.GetEquipInfoCfg, ShenyiData.Instance)

			self.skill_icon_res = "shenyi_skill_icon"
			self.percent_icon_asset = "icon_info_sy_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = ShenyiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = ShenyiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENYI, temp_level)
		self.active_skill_level = ShenyiData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = ShenyiData.Instance:GetShenyiEquipAttrSum()
		self.next_percent_attr_cfg = ShenyiData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = ShenyiData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = ShenyiData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.foot_jinjie then		-- 足迹装备
		self.info = FootData.Instance:GetFootInfo()
		if not self.info or not next(self.info) then return end
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FootData.Instance.CalEquipRemind, FootData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FootData.Instance.GetEquipInfoCfg, FootData.Instance)

			self.skill_icon_res = "foot_skill_icon"
			self.percent_icon_asset = "icon_info_zj_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FootData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FootData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT, temp_level)
		self.active_skill_level = FootData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = FootData.Instance:GetFootEquipAttrSum()
		self.next_percent_attr_cfg = FootData.Instance:GetNextPercentAttrCfg(self.select_item_index)
		self.equip_min_level = FootData.Instance:GetEquipMinLevel()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FootData.Instance:GetEquipInfoCfg(k, v)
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

function AdvanceEquipView:SetSpecialModle(modle_id, special_type)
	local display_name = "equip_jinjie_panel"
	if special_type == SPECIAL_TYPE.Mount then
		display_name = "equip_jinjie_panel_mount"
	elseif special_type == SPECIAL_TYPE.FightMount then
		display_name = "equip_jinjie_panel_fight_mount"
	end
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			break
		end
	end
	return display_name
end