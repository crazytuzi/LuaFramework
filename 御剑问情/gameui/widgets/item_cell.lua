ItemCell = ItemCell or BaseClass(BaseRender)

local PROP_USE_TYPE = {1, 8, 21, 22, 23, 25, 26, 78, 82, 88, 90}

function ItemCell:__init()
	self.is_use_objpool = false

	if nil == self.root_node then
		local prefab = PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "ItemCell")
		local u3dobj = U3DObject(GameObjectPool.Instance:Spawn(prefab, nil))
		self:SetInstance(u3dobj)
		self.is_use_objpool = true
	end

	self.hide_numtxt_less_num = 1
	self.data = {}
	self.is_gray = false
	self.quality_enbale = true
	self.quality_state = 1
	self.effect_obj = nil
	self.is_destroy_effect = false
	self.index = -1
	self.is_clear_listen = true
	self.is_showtip = true							-- 是否显示物品信息提示

	--获取UI
	self.icon_img = self:FindObj("Icon")
	self.effect_root = self:FindObj("Quality")

	-- 获取变量
	self.show_number = self:FindVariable("ShowNumber")
	self.show_strength = self:FindVariable("ShowStrength")
	self.show_prop_name = self:FindVariable("ShowPropName")

	self.number = self:FindVariable("Number")
	self.strength = self:FindVariable("Strength")
	self.prop_name = self:FindVariable("PropName")
	self.god_quality = self:FindVariable("GodQuality")

	self.icon = self:FindVariable("Icon")
	self.left_top_img = self:FindVariable("LeftTopImg")
	self.quality = self:FindVariable("Quality")
	self.bind = self:FindVariable("Bind")
	self.cell_lock = self:FindVariable("CellLock")
	self.prop_des_num = self:FindVariable("PropDes")
	self.start_level = self:FindVariable("StarLevel")
	self.role_prof = self:FindVariable("RoleProf")

	self.show_gray = self:FindVariable("ShowGray")
	self.show_quality = self:FindVariable("ShowQuality")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_high_light = self:FindVariable("ShowHighLight")
	self.show_up_level = self:FindVariable("ShowUpLevel")
	self.show_up_arrow = self:FindVariable("ShowUpArrow")		-- 装备品质更优
	self.show_down_arrow = self:FindVariable("ShowDownArrow")
	self.show_god_quality = self:FindVariable("ShowGodQuality")
	self.show_prop_des = self:FindVariable("ShowPropDes")
	self.show_star_level = self:FindVariable("ShowStarLevel")
	self.show_up_quality = self:FindVariable("ShowUpQuality")
	self.show_role_prof = self:FindVariable("ShowRoleProf")		-- 转生装备职业
	self.show_level_limit = self:FindVariable("ShowLevelLimit")	-- 等级不足
	self.show_defualt_bg = self:FindVariable("ShowDefualtBg")
	self.show_quality_gray = self:FindVariable("ShowQualityGray")
	self.show_time_limit_img = self:FindVariable("ShowTimeLimitImg")

	self.show_top_left = self:FindVariable("ShowTopLeft")
	self.top_left_des = self:FindVariable("TopLeftDes")

	self.show_repair_image = self:FindVariable("ShowRepairImage")
	self.show_hase_get = self:FindVariable("ShowHaseGet")
	self.show_get_effect = self:FindVariable("ShowGetEffect")			--可领取特效

	self.show_time_limit = self:FindVariable("ShowTimeLimit")			-- 限时物品标签

	---[[运营需要的特殊特效
	self.show_special_effect = self:FindVariable("ShowSpecialEffect")
	self.set_special_effect = self:FindVariable("SetSpecialEffect")			--运营特殊特效
	--]]

	self.show_equip_grade = self:FindVariable("ShowEquipGrade")		-- 又上角显示装备阶数
	self.equip_grade = self:FindVariable("EquipGrade")

	self.show_inlay_slot = self:FindVariable("ShowInlaySlot")			-- 右上角魂印可镶嵌位置显示
	self.inlay_slot = self:FindVariable("inlay_slot")

	self.show_stars = {
		self:FindVariable("ShowStar1"),
		self:FindVariable("ShowStar2"),
		self:FindVariable("ShowStar3"),
	}

	self.up_level_tip_text = self:FindVariable("CanEquip")

	-- 神格等级、阶级
	self.shen_ge_level = self:FindVariable("ShenGeLevel")
	self.show_shen_ge_level = self:FindVariable("ShowShenGeLevel")
	self.show_rome_image = self:FindVariable("ShowRomeImage")
	self.rome_image = self:FindVariable("RomeImage")

	-- 是否绝版
	self.jueban = self:FindVariable("is_jueban")
	if self.jueban then
		self.jueban:SetValue(false)
	end

	self.is_load_effect = false
	self.ignore_arrow = false

	self.is_destory_effect_loading = false

	if self.is_use_objpool then
		self:Reset()
	end

	self.other_auto = ConfigManager.Instance:GetAutoConfig("cardcfg_auto")
end

function ItemCell:__delete()
	if self.is_use_objpool and not self:IsNil() then
		GameObjectPool.Instance:Free(self.root_node.gameObject)
	end

	if self.effect_obj then
		self.effect_obj:DeleteMe()
		-- GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
	self.data = nil
	self.is_destroy_effect = nil
	self.equip_fight_power = nil
	self.is_tian_sheng = nil

	if self.activity_effect_obj then
		self.activity_effect_obj:DeleteMe()
		-- GameObject.Destroy(self.activity_effect_obj)
		self.activity_effect_obj = nil
	end
	self.quality:SetAsset("", "")
end

function ItemCell:Reset()
	if nil ~= self.effect_obj then
		self.effect_obj:SetActive(false)
	end
	if nil ~= self.activity_effect_obj then
		self.activity_effect_obj:SetActive(false)
	end

	self:SetIconGrayScale(false)
	self.show_number:SetValue(false)
	self.show_strength:SetValue(false)
	self.show_prop_name:SetValue(false)
	self.show_god_quality:SetValue(false)
	self.icon:ResetAsset()
	if self.left_top_img then
		self.left_top_img:ResetAsset()
	end
	self.bind:SetValue(false)
	self.cell_lock:SetValue(false)
	self.show_prop_des:SetValue(false)
	self.show_star_level:SetValue(false)
	self.show_role_prof:SetValue(false)
	self.show_gray:SetValue(false)
	self.show_quality:SetValue(true)
	self.show_red_point:SetValue(false)
	self.show_high_light:SetValue(true)
	self.show_up_arrow:SetValue(false)
	self.show_down_arrow:SetValue(false)
	self.show_prop_des:SetValue(false)
	self.show_star_level:SetValue(false)
	self.show_up_quality:SetValue(false)
	self.show_role_prof:SetValue(false)
	self.show_level_limit:SetValue(false)
	self.show_top_left:SetValue(false)
	self.show_repair_image:SetValue(false)
	self.show_hase_get:SetValue(false)
	self.show_get_effect:SetValue(false)
	self.show_time_limit:SetValue(false)
	self.show_time_limit_img:SetValue(false)
	self.show_special_effect:SetValue(false)
	self.show_shen_ge_level:SetValue(false)
	self.show_rome_image:SetValue(false)
	self.show_inlay_slot:SetValue(false)
	self.show_defualt_bg:SetValue(true)
	self.show_quality_gray:SetValue(false)
	self.rome_image:ResetAsset()
	self.quality:SetAsset("", "")

	if nil ~= self.show_equip_grade then
		self.show_equip_grade:SetValue(false)
	end

	if self.show_stars then
		for k, v in pairs(self.show_stars) do
			v:SetValue(false)
		end
	end

	self.handler = nil
	local toggle = self.root_node.toggle
	toggle.onValueChanged:RemoveAllListeners()
	toggle.group = nil
	toggle.interactable = false
	toggle.isOn = false

	self.root_node.rect.anchorMax = Vector2(0.5, 0.5)
	self.root_node.rect.anchorMin = Vector2(0.5, 0.5)
	self.root_node.rect.sizeDelta = Vector2(94, 95)  -- 物品格子使用对象池后，不知道哪里有设置长宽，导致出问题。默认强设大小94 * 95
	self.root_node.rect.pivot = Vector2(0.5, 0.5)
	self.root_node.transform:SetLocalScale(1, 1, 1)  -- 物品格子使用对象池后，不知道哪里有设置scale
end

function ItemCell:SetShowUpQuality(enable)
	if self.show_up_quality then
		self.show_up_quality:SetValue(enable)
	end
end

function ItemCell:SetNotShowRedPoint(is_show)
	self.not_show_red_point = is_show
end

function ItemCell:SetIsTianSheng(is_tian_sheng)
	self.is_tian_sheng = is_tian_sheng
end

function ItemCell:AddValueChangedListener(call_back)
	self.root_node.toggle:AddValueChangedListener(call_back)
end

function ItemCell:SetItemActive(is_active)
	self.root_node.gameObject:SetActive(is_active)
end

function ItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self.handler = handler
	self:ListenEvent("Click", handler or BindTool.Bind(self.OnClickItemCell, self))
end

function ItemCell:OnClickItemCell()
	local data = self.data
	if data == nil then return end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		return
	end
	-- if self.root_node.toggle then
	-- 	self.root_node.toggle.isOn = true
	-- end
	if not self.is_showtip then return end
	local from_view = data.from_view
	local param_t = data.param_t
	local close_call_back = data.close_call_back or function() self:SetHighLight(false) end
	TipsCtrl.Instance:OpenItem(data, from_view, param_t, close_call_back, self.show_the_random, self.gift_id, self.is_check_item, self.is_tian_sheng)
end

function ItemCell:ClearItemEvent(handler)
	self:ClearEvent("Click")
end

function ItemCell:SetIsCheckItem(is_check_item)
	self.is_check_item = is_check_item
end

function ItemCell:SetGiftItemId(gift_id)
	self.gift_id = gift_id
end

-- 设置物品数量显示最小值
function ItemCell:SetShowNumTxtLessNum(value)
	self.hide_numtxt_less_num = value
end

function ItemCell:IgnoreArrow(boo)
	self.ignore_arrow = boo
end

function ItemCell:SetToggleGroup(toggle_group)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.group = toggle_group
	end
end

function ItemCell:ShowStrengthLable(enable)
	if self.show_strength then
		self.show_strength:SetValue(enable)
	end
end

function ItemCell:SetStrength(value)
	if self.strength then
		self.strength:SetValue(value)
	end
end

function ItemCell:ShowHighLight(enable)
	if self.show_high_light then
		self.show_high_light:SetValue(enable)
	end
end

function ItemCell:ShowToLeft(enable)
	if self.show_top_left then
		self.show_top_left:SetValue(enable)
	end
end

function ItemCell:SetTopLeftDes(des)
	if self.top_left_des then
		self.top_left_des:SetValue(des)
	end
end

function ItemCell:ShowRepairImage(enable)
	if self.show_repair_image then
		self.show_repair_image:SetValue(enable)
	end
end

function ItemCell:ShowHaseGet(enable)
	if self.show_hase_get then
		self.show_hase_get:SetValue(enable)
	end
end

function ItemCell:ShowGetEffect(enable)
	if self.show_get_effect then
		self.show_get_effect:SetValue(enable)
	end
end

function ItemCell:ShowSpecialEffect(enable)
	if self.show_special_effect then
		self.show_special_effect:SetValue(enable)
	end
end

function ItemCell:SetSpecialEffect(bunble, asset)
	if self.set_special_effect then
		self.set_special_effect:SetAsset(bunble, asset)
	end
end

--点开天神装备时,设置是否显示随机问号属性
function ItemCell:SetShowRandom(is_show)
	self.show_the_random = is_show
end

function ItemCell:SetClearListenValue(value)
	self.is_clear_listen = value
end

function ItemCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function ItemCell:ShowStarLevel(enable)
	if self.show_star_level then
		self.show_star_level:SetValue(enable)
	end
end

function ItemCell:SetHighLight(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.isOn = enable
	end
end

function ItemCell:SetIconGrayScale(enable)
	if self.icon_img then
		self.icon_img.grayscale.GrayScale = enable and 255 or 0
	end
end

function ItemCell:SetIconLittleGrayScale(enable)
	if self.icon_img then
		self.icon_img.grayscale.GrayScale = enable and 224 or 0
	end
end

function ItemCell:GetIconGrayScaleIsGray()
	if self.icon_img then
		return self.icon_img.grayscale.GrayScale == 255
	end
	return false
end

function ItemCell:GetToggleIsOn()
	if self.root_node.toggle and self:GetActive() then
		return self.root_node.toggle.isOn
	end
	return false
end

function ItemCell:SetItemNumVisible(enable)
	self.show_number:SetValue(enable)
end

function ItemCell:ShowQuality(enable)
	if self.show_quality then
		self.quality_enbale = enable
		self.show_quality:SetValue(enable)
	end
end

function ItemCell:SetQualityState(state)
	self.quality_state = state
end

function ItemCell:OnlyShowQuality(enable)
	if self.show_quality then
		self.show_quality:SetValue(enable)
	end
end

function ItemCell:IsDestroyEffect(value)
	self.is_destroy_effect = value
end

function ItemCell:SetStarLevel(value)
	if self.start_level then
		self.start_level:SetValue(value)
	end
end

function ItemCell:SetRedPoint(value)
	if self.show_red_point and value ~= nil then
		self.show_red_point:SetValue(value)
	end
end

function ItemCell:SetIndex(index)
	self.index = index
end

function ItemCell:GetIndex()
	return self.index
end

function ItemCell:FlushArrow(is_from_bag)
	if self.show_up_arrow then
		self.show_up_arrow:SetValue(false)
	end
	if self.show_down_arrow then
		self.show_down_arrow:SetValue(false)
	end

	if not self.data or not next(self.data) then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg or (big_type ~= GameEnum.ITEM_BIGTYPE_EQUIPMENT) then
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()

	self:SetItemGridArrow(big_type, equip_index, item_cfg, self.data, gamevo, is_from_bag)
end

function ItemCell:SetData(data, is_from_bag)
	self.data = data
	if self.show_stars then
		for k, v in pairs(self.show_stars) do
			v:SetValue(false)
		end
	end
	if self.show_level_limit then
		self.show_level_limit:SetValue(false)
	end
	if self.show_prop_des then
		self.show_prop_des:SetValue(false)
	end
	if self.show_god_quality then
		self.show_god_quality:SetValue(false)
	end

	if self.show_gray then
		self.show_gray:SetValue(self.is_gray)
	end
	if self.show_red_point then
		self.show_red_point:SetValue(false)
	end

	if self.show_star_level then
		self.show_star_level:SetValue(false)
	end

	if self.show_up_arrow then
		self.show_up_arrow:SetValue(false)
	end

	if self.show_down_arrow then
		self.show_down_arrow:SetValue(false)
	end

	if nil ~= self.show_equip_grade then
		self.show_equip_grade:SetValue(false)
	end

	if nil ~= self.show_shen_ge_level then
		self.show_shen_ge_level:SetValue(false)
	end

	if nil ~= self.show_rome_image then
		self.show_rome_image:SetValue(false)
	end

	if nil ~= self.show_inlay_slot then
		self.show_inlay_slot:SetValue(false)
	end

	if nil ~= self.jueban then
		self.jueban:SetValue(false)
	end

	self:ShowToLeft(false)
	self:ShowRepairImage(false)
	self:ShowHaseGet(false)
	self:ShowGetEffect(false)
	self:ShowSpecialEffect(false)
	self:SetDefualtBgState(true)

	if not data or not next(data) then
		self.icon:ResetAsset()
		self.show_number:SetValue(false)
		self.show_strength:SetValue(false)
		self.show_prop_name:SetValue(false)
		self.bind:SetValue(false)
		self.number:SetValue(false)
		if self.show_quality then
			self.show_quality:SetValue(false)
		end
		if self.effect_obj then
			self.effect_obj:DeleteMe()
			-- GameObject.Destroy(self.effect_obj)
			self.effect_obj = nil
		end
		if self.show_time_limit then
			self.show_time_limit:SetValue(false)
		end
		if self.show_time_limit_img then
			self.show_time_limit_img:SetValue(false)
		end
		self:SetRoleProf(false)
		return
	end

	-- 设置格子锁
	if self.cell_lock then
		self.cell_lock:SetValue(data.locked or false)
	end

	-- 有道具就不显示类型名字了
	if data.prop_name ~= nil then
		self.prop_name:SetValue(data.prop_name)
		self.show_prop_name:SetValue(true)
	else
		self.show_prop_name:SetValue(false)
	end

	-- 升级提示
	if self.show_up_level then
		if self.up_level_tip_text then
			self.up_level_tip_text:SetValue(data.can_equip or "可升级")
		end
		self.show_up_level:SetValue(data.is_show_up_level or false)
	end

	-- 获取配置
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if self.jueban then
		if data.is_jueban == 1 then
			self.jueban:SetValue(true)
		end
	end

	if nil == item_cfg then
		self.icon:ResetAsset()
		if self.left_top_img then
			self.left_top_img:ResetAsset()
		end
		self.show_number:SetValue(false)
		self.show_strength:SetValue(false)
		self.show_prop_name:SetValue(false)
		self.bind:SetValue(false)


		if self.effect_obj then
			self.effect_obj:DeleteMe()
			-- GameObject.Destroy(self.effect_obj)
			self.effect_obj = nil
		end
		if self.show_quality then
			self.show_quality:SetValue(false)
		end
		if self.show_time_limit then
			self.show_time_limit:SetValue(false)
		end
		if self.show_time_limit_img then
			self.show_time_limit_img:SetValue(false)
		end

		self:SetRoleProf(false)

		if nil ~= self.show_shen_ge_level then
			self.show_shen_ge_level:SetValue(false)
		end

		if nil ~= self.show_rome_image then
			self.show_rome_image:SetValue(false)
		end
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()

	-- 设置格子默认特效
	self:SetNormalItemEffect(equip_index, data, item_cfg, is_from_bag)

	-- 设置格子置灰状态
	self:SetItemGridGrayState(data, equip_index, item_cfg, big_type, gamevo, is_from_bag)

	self:SetInteractable(true)

	-- 设置格子装备上升、下降箭头
	self:SetItemGridArrow(big_type, equip_index, item_cfg, data, gamevo, is_from_bag)

	-- 设置格子道具左上角道具文本
	self:SetItemGridTopLeftPropNum(item_cfg)

	-- 设置格子道具右上角装备阶数
	self:SetEquipGrade(item_cfg, equip_index, big_type)

	-- 设置神格等级和阶数
	self:SetShenGeInfo(data, is_from_bag)

	if (data.item_id == FuBenDataExpItemId.ItemId or data.item_id == 0) and self.is_clear_listen then
		self:ClearEvent("Click")
		self:SetInteractable(false)
	elseif nil == self.handler then
		self:ListenClick()
	end

	if self.show_quality then
		self.show_quality:SetValue(self.quality_enbale)
	end
	-- 设置图标
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.icon:SetAsset(bundle, asset)

	if self.show_time_limit_img then
		self.show_time_limit_img:SetValue(item_cfg.is_curday_valid == 1)
	end
	if self.left_top_img then
		self.left_top_img:ResetAsset()
	end
	if item_cfg.use_type == 99 then
		local tsht_cfg = TianshenhutiData.Instance:GetEquipCfg(item_cfg.param1)
		if tsht_cfg then
			self:SetLeftTopImg(ResPath.GetImages("tz_" .. tsht_cfg.taozhuang_type))
		end
		self.show_equip_grade:SetValue(true)
		self.equip_grade:SetValue(tsht_cfg.level or "")
	end

	-- 符文图标特殊处理，缩小0.9倍
	if item_cfg.use_type == 74 then
		self:SetIconScale(Vector3(0.9, 0.9, 0.9))
	else
		self:SetIconScale(Vector3(1, 1, 1))
	end

	local bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
	if self.quality_state == 2 then  -- 状态为2的时候用圆底
		bundle1, asset1 = ResPath.GetEquipStarQualityIcon(item_cfg.color)
	end
	self.quality:SetAsset(bundle1, asset1)

	local temp_data = data
	-- 传奇属性显示
	if self.gift_id and ForgeData.Instance:GetEquipIsNotRandomGift(temp_data.item_id, self.gift_id) then
		temp_data = TableCopy(data)
		temp_data.param = {xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(temp_data.item_id, self.gift_id)}
	end

	-- local card_star = CardData.Instance:GetCardColor(data.item_id)
	-- if card_star > 6 then
	-- 	self:SetShowStar(card_star - 6)
	-- end

	-- 设置数量or强度
	if data.num ~= nil and big_type ~= GameEnum.ITEM_BIGTYPE_EQUIPMENT then

		if data.num > self.hide_numtxt_less_num then
			self.show_number:SetValue(true)
			if data.num >= 10000 and data.num < 100000000 then
				local num_wan = math.floor(data.num / 10000)
				self.number:SetValue(num_wan..Language.Common.Wan)
			elseif data.num >= 100000000 then
				local num_yi = data.num / 100000000
				num_yi = string.format("%.1f", num_yi)
				self.number:SetValue(num_yi..Language.Common.Yi)
			else
				self.number:SetValue(data.num)
			end
		else
			self.show_number:SetValue(false)
		end
		self.show_strength:SetValue(false)

		if big_type == GameEnum.ITEM_BIGTYPE_OTHER then
			local list = ItemData.Instance:GetItemConfig(self.data.item_id)
			if list and list.star_num then
				local star_num = tonumber(list.star_num) or 0
				for i = 1, star_num do
					if self.show_stars[i] then
						self.show_stars[i]:SetValue(true)
					end
				end
			end
		end

	elseif temp_data.param ~= nil then
		self.show_number:SetValue(false)

		local strength_level = temp_data.param.strengthen_level
		if EquipData.IsJLType(item_cfg.sub_type) then
			strength_level = self.quality_enbale and data.param.rand_attr_val_1 or 0
		end
		if self.data.mojie_level then
			strength_level = self.data.mojie_level
		end
		if strength_level == 0 or not strength_level then
			self.show_strength:SetValue(false)
		else
			self.show_strength:SetValue(not is_from_bag or (EquipData.IsJLType(item_cfg.sub_type) and self.quality_enbale) or false)
		end
		local star_index = 0

		if temp_data.param.xianpin_type_list and not EquipData.IsJLType(item_cfg.sub_type) then
			for k, v in pairs(temp_data.param.xianpin_type_list) do
				if v ~= nil and v > 0 then
					local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
					if legend_cfg ~= nil and legend_cfg.color == 1 then
						star_index = star_index + 1
						if self.show_stars[star_index] then
							self.show_stars[star_index]:SetValue(true)
						end
					end
				end
			end
		end
		self.strength:SetValue(strength_level)
	else
		self.show_strength:SetValue(false)
		self.show_number:SetValue(false)
	end

	-- 绑定标记
	if big_type == GameEnum.ITEM_BIGTYPE_VIRTUAL then
		self.bind:SetValue(false)
	elseif data.is_bind then
		self.bind:SetValue(0 ~= data.is_bind)
	elseif item_cfg.isbind then
		self.bind:SetValue(0 ~= item_cfg.isbind)
	end

	if self.show_up_arrow and not self.ignore_arrow then
		if data.is_up_arrow ~= nil then
			self.show_up_arrow:SetValue(self.data.is_up_arrow)
		end
	end

	if self.show_time_limit then
		self.show_time_limit:SetValue(item_cfg.time_length and item_cfg.time_length > 0 or false)
	end

	local is_hunyin = HunQiData.Instance:IsHunyinItem(data.item_id)
	-- 设置魂印镶嵌位置
	if is_hunyin then
		self:SetInlaySlot(data.item_id)
	end

	--处理小鬼守护图标置灰（只处理背包的）
	if is_from_bag and PlayerData.Instance:GetImpGuardCfgInfoByItemId(data.item_id) then
		if data.invalid_time and data.invalid_time <= TimeCtrl.Instance:GetServerTime() then
			self.show_quality_gray:SetValue(true)
			self:SetIconLittleGrayScale(true)
		else
			self.show_quality_gray:SetValue(false)
			self:SetIconLittleGrayScale(false)
		end
	end
end

function ItemCell:SetInlaySlot(index)
	if nil ~= self.show_inlay_slot then
		self.show_inlay_slot:SetValue(true)
		local hunyin_info = HunQiData.Instance:GetHunQiInfo()[index][1]
		self.inlay_slot:SetValue(Language.HunQi.HunYinName[hunyin_info.inlay_slot + 1])
	end
end

function ItemCell:SetRomeImageState(slot)
	if nil ~= slot and slot > -1 and nil ~= self.show_rome_image and nil ~= self.rome_image then
		self.show_rome_image:SetValue(true)
		self.rome_image:SetAsset(ResPath.GetTeamRomeNumImage(slot))
	end
end

function ItemCell:SetShenGeInfo(data, is_from_bag)
	if CardData.Instance:IsCardPiece(data.item_id) then
		local slot = CardData.Instance:GetCardSlot(data.item_id)
		self:SetRomeImageState(slot)
		return
	end
	--Boss图鉴
	local is_handbook, handbook_slot = IllustratedHandbookData.Instance:IsNeedItem(data.item_id)
	if is_handbook then
		local slot = handbook_slot
		self:SetRomeImageState(slot)
		return
	end

	if self.show_rome_image then
		self.show_rome_image:SetValue(false)
	end
	-- if nil == data.shen_ge_data then
	-- 	local quality = ShenGeData.Instance:GetShenGeQualityByItemId(data.item_id)
	-- 	if quality < 0 then
	-- 		return
	-- 	end
	-- 	if nil ~= self.show_rome_image then
	-- 		self.show_rome_image:SetValue(true)
	-- 		self.rome_image:SetAsset(ResPath.GetRomeNumImage(quality))
	-- 	end
	-- 	return
	-- end
	-- if nil ~= self.show_rome_image then
	-- 	--self.show_shen_ge_level:SetValue(not is_from_bag)
	-- 	self.show_shen_ge_level:SetValue(false)
	-- 	--self.show_rome_image:SetValue(true)
	-- 	self.show_rome_image:SetValue(false)
	-- 	self.shen_ge_level:SetValue(data.shen_ge_data.level)
	-- 	self.rome_image:SetAsset(ResPath.GetRomeNumImage(data.shen_ge_data.quality))
	-- end
end

-- 设置装备又上角阶数
function ItemCell:SetEquipGrade(item_cfg, equip_index, big_type)
	if nil ~= self.show_equip_grade and self.equip_grade then
		self.show_equip_grade:SetValue(big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 and not self:GetIconGrayScaleIsGray() and item_cfg.color < GameEnum.EQUIP_COLOR_PINK)
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 then
			self.equip_grade:SetValue(item_cfg.order or "")
		end
		if EquipData.IsMarryEqType(item_cfg.sub_type) and item_cfg.color < GameEnum.EQUIP_COLOR_PINK then
			self.show_equip_grade:SetValue(true)
			self.equip_grade:SetValue(item_cfg.order or "")
		end
	end
end

function ItemCell:ShowEquipGrade(value)
	if self.show_equip_grade then
		self.show_equip_grade:SetValue(value)
	end
end

-- 设置格子上升和下降箭头
function ItemCell:SetItemGridArrow(big_type, equip_index, item_cfg, data, gamevo, is_from_bag)
	self:SetRoleProf(false)

	local is_up_flag = false
	local is_down_flag = false

	if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0
		and (item_cfg.limit_prof == gamevo.prof or item_cfg.limit_prof == 5) then
		if is_from_bag and not self.ignore_arrow and item_cfg.limit_level <= gamevo.level then
			local bag_equip_power = EquipData.Instance:GetEquipLegendFightPowerByData(data)
			is_up_flag = (bag_equip_power - gamevo.capability) >= COMMON_CONSTS.COMPARE_MIN_POWER
			is_down_flag = (gamevo.capability - bag_equip_power) >= COMMON_CONSTS.COMPARE_MIN_POWER
		end

		if self.show_level_limit and is_from_bag then
			self.show_level_limit:SetValue(item_cfg.limit_level > gamevo.level)
		end

	elseif CardData.Instance:IsCardPiece(data.item_id) then
		local is_better, is_open, is_bad = CardData.Instance:IsBetterCardPiece(data.item_id)
		if is_from_bag and not self.ignore_arrow and is_open and item_cfg.limit_level <= gamevo.level then
			is_up_flag = is_better
			is_down_flag = is_bad
		end

		if self.show_level_limit and is_from_bag then
			self.show_level_limit:SetValue(not is_open and is_better)
		end
	elseif item_cfg.sub_type and EquipData.IsMarryEqType(item_cfg.sub_type) then
		-- 情缘装备

		local qy_dess_equip_list = MarryEquipData.Instance:GetMarryEquipInfo()
		local fight_power = CommonDataManager.GetCapability(item_cfg)
		local qy_dess_index = MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type)
		local dress_fight_power = 0
		if qy_dess_equip_list[qy_dess_index] then
			local dress_item_cfg = ItemData.Instance:GetItemConfig(qy_dess_equip_list[qy_dess_index].item_id)
			dress_fight_power = dress_item_cfg and CommonDataManager.GetCapability(dress_item_cfg) or 0
		end
		if item_cfg.limit_sex == gamevo.sex then
			local marry_info = MarryEquipData.Instance:GetMarryInfo()
			if is_from_bag and not self.ignore_arrow and item_cfg.limit_level <= marry_info.marry_level then
				is_up_flag = fight_power > dress_fight_power
				is_down_flag = fight_power < dress_fight_power
			end
			if self.show_level_limit and is_from_bag then
				self.show_level_limit:SetValue(item_cfg.limit_level > marry_info.marry_level)
			end
		end

		if self.show_god_quality then
			local score = ZhuanShengData.Instance:GetEquipScore(data, fight_power)
			self.show_god_quality:SetValue(nil ~= score)
			if score and self.god_quality then
				self.god_quality:SetValue(score)
			end
		end

	elseif item_cfg.sub_type and item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX then
		-- 转生装备
		self:SetRoleProf(true, item_cfg)

		local zs_dess_equip_list = ZhuanShengData.Instance:GetDressEquipList()
		local fight_power = ZhuanShengData.Instance:GetZhuangShengEquipFightPower(data)
		local zs_dess_index = ZhuanShengData.Instance:GetZhuanShengEquipIndex(item_cfg.sub_type)
		local dress_fight_power = ZhuanShengData.Instance:GetZhuangShengEquipFightPower(zs_dess_equip_list[zs_dess_index])

		if item_cfg.limit_prof == gamevo.prof or item_cfg.limit_prof == 5 then
			if is_from_bag and not self.ignore_arrow and item_cfg.limit_level <= gamevo.level then
				is_up_flag = fight_power > dress_fight_power
				is_down_flag = fight_power < dress_fight_power
			end
			if self.show_level_limit and is_from_bag then
				self.show_level_limit:SetValue(item_cfg.limit_level > gamevo.level)
			end
		end

		if self.show_god_quality then
			local score = ZhuanShengData.Instance:GetEquipScore(data, fight_power)
			self.show_god_quality:SetValue(nil ~= score)
			if score and self.god_quality then
				self.god_quality:SetValue(score)
			end
		end
	end

	self.show_up_arrow:SetValue(is_up_flag)
	self.show_down_arrow:SetValue(is_down_flag)

	if is_from_bag then
		self:SetActivityEffect(not is_up_flag)
	end
end

-- 设置右上角职业
function ItemCell:SetRoleProf(value, item_cfg)
	if self.show_role_prof then
		self.show_role_prof:SetValue(value)
	end

	if value and item_cfg and self.role_prof then
		self.role_prof:SetValue(Language.Common.RoleProfList[item_cfg.limit_prof] and Language.Common.RoleProfList[item_cfg.limit_prof] or "")
	end
end

-- 设置格子道具左上角物品数字
function ItemCell:SetItemGridTopLeftPropNum(item_cfg)
	if self.show_prop_des and self.prop_des_num then
		self.show_prop_des:SetValue(self:IsShowPropDesNum(item_cfg.use_type))
		self.prop_des_num:SetValue("")
		if self:IsShowPropDesNum(item_cfg.use_type) and item_cfg.param1 then
			if item_cfg.param1 >= 10000 and item_cfg.param1 < 100000000 then
				local num_wan = math.floor(item_cfg.param1 / 10000)
				self.prop_des_num:SetValue(num_wan..Language.Common.Wan)
			elseif item_cfg.param1 >= 100000000 then
				local num_yi = math.floor(item_cfg.param1 / 100000000)
				self.prop_des_num:SetValue(num_yi..Language.Common.Yi)
			else
				self.prop_des_num:SetValue(item_cfg.param1)
			end
		end
	end
end

-- 设置格子默认特效
function ItemCell:SetNormalItemEffect(equip_index, data, item_cfg, is_from_bag)
	if ((not is_from_bag and EquipData.Instance:GetGridData(equip_index) or (data.num and data.num > 0)) or is_from_bag)
			and item_cfg.special_show and 1 == item_cfg.special_show or 		-- 配置表参数
			(EquipData.IsJLType(item_cfg.sub_type) and data.param and data.param.xianpin_type_list and next(data.param.xianpin_type_list)) then -- 精灵
			if not self.effect_obj then
				self.effect_obj = AsyncLoader.New(self.effect_root.transform)
				local bundle, asset = ResPath.GetItemEffect()
				local call_back = function ()
					self.effect_obj:SetActive(not self.is_destroy_effect)
				end
				self.effect_obj:Load(bundle, asset, call_back)
			else
				self.effect_obj:SetActive(not self.is_destroy_effect)
			end
	else
		if self.effect_obj then
			self.effect_obj:SetActive(false)
		end
	end
end

-- 设置格子是否置灰
function ItemCell:SetItemGridGrayState(data, equip_index, item_cfg, big_type, gamevo, is_from_bag)
	if data.is_gray ~= nil and self.show_gray then
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 then
			if gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				data.is_gray = true
			end
		end
		self.show_gray:SetValue(data.is_gray)
	elseif self.show_gray then
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 then
			if is_from_bag then
				if gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
					self.show_gray:SetValue(true)
				else
					self.show_gray:SetValue(false)
				end
			end
		elseif is_from_bag and item_cfg.sub_type and EquipData.IsMarryEqType(item_cfg.sub_type) then
			self.show_gray:SetValue(gamevo.sex ~= item_cfg.limit_sex)
		elseif is_from_bag then
			if gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				self.show_gray:SetValue(true)
			else
				self.show_gray:SetValue(false)
			end
		elseif item_cfg.sub_type and item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN
						and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX then
			-- local zhuanshen_level = ZhuanShengData.Instance:GetZhuanShengInfo().zhuansheng_level
			-- self.show_gray:SetValue(false)
			if gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				self.show_gray:SetValue(true)
			else
				self.show_gray:SetValue(false)
			end
			-- if zhuanshen_level < item_cfg.order then
			-- 	self.show_gray:SetValue(true)
			-- end
		else
			self.show_gray:SetValue(self.is_gray)
		end
	end
end

-- 设置运营活动物品特效
function ItemCell:IsDestoryActivityEffect(value)
	self.is_destroy_activity_effect = value
end

-- 设置运营活动格子特效
function ItemCell:SetActivityEffect(value)
	local active_value = self.is_destroy_activity_effect
	if nil ~= value then
		active_value = value
	end

	if not self.activity_effect_obj then
		self.is_show_effect = true
		self.activity_effect_obj = AsyncLoader.New(self.effect_root.transform)
		local call_back = function()
			self.activity_effect_obj:SetActive(self.is_show_effect and not active_value)
		end

		local bundle, asset = ResPath.GetItemActivityEffect()
		self.activity_effect_obj:Load(bundle, asset, call_back)
	else
		self.is_show_effect = false
		self.activity_effect_obj:SetActive(not active_value)
	end
end

function ItemCell:GetData()
	return self.data or {}
end

function ItemCell:IsGray()
	return self.is_gray
end

function ItemCell:SetIconGrayVisible(value)
	if value then
		self.is_gray = true
	else
		self.is_gray = false
	end
	self.show_gray:SetValue(self.is_gray)
end

function ItemCell:SetToggle(is_on)
	if self:GetActive() then
		self.root_node.toggle.isOn = is_on
	end
end

function ItemCell:SetNum(num)
	if num > 0 then
		self.show_number:SetValue(true)
		self.number:SetValue(num)
	else
		self.show_number:SetValue(false)
	end
end

function ItemCell:IsShowPropDesNum(use_type)
	if not use_type then return false end

	for k, v in pairs(PROP_USE_TYPE) do
		if use_type == v then
			return true
		end
	end

	return false
end

function ItemCell:SetItemNum(num)
	self.number:SetValue(num)
end

function ItemCell:GetEffectRoot()
	return self.effect_root
end

function ItemCell:SetShowRedPoint(show_red_point)
	self.show_red_point:SetValue(false)
end

function ItemCell:SetAsset(bundle, asset)
	if bundle and asset then
		self.icon:SetAsset(bundle, asset)
	end
end

function ItemCell:ResetIconAsset()
	self.icon:ResetAsset()
end

function ItemCell:SetQualityByColor(color)
	local bundle, asset = ResPath.GetQualityIcon(color)
	if bundle and asset then
		self.quality:SetAsset(bundle, asset)
	end
end

function ItemCell:SetShowUpArrow(is_show)
	if self.show_up_arrow then
		self.show_up_arrow:SetValue(is_show)
	end
end

function ItemCell:SetLeftTopImg(asset, bundle)
	if self.left_top_img then
		self.left_top_img:SetAsset(asset, bundle)
	end
end

function ItemCell:SetShowDownArrow(is_show)
	if self.show_down_arrow then
		self.show_down_arrow:SetValue(is_show)
	end
end

function ItemCell:SetAlpha(value)
	if self.root_node.canvas_group and self:GetActive() then
		self.root_node.canvas_group.alpha = value
	end
end

function ItemCell:GetTransForm()
	return self.root_node.transform
end

function ItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function ItemCell:SetCellLock(is_lock)
	self.cell_lock:SetValue(is_lock)
end

function ItemCell:SetIsShowTips(flag)
	self.is_showtip = flag
end

function ItemCell:GetIsShowTips()
	return self.is_showtip
end

function ItemCell:SetDefualtQuality()
	local bundle1, asset1 = ResPath.GetQualityIcon(6)
	self.quality:SetAsset(bundle1, asset1)
end

function ItemCell:SetDefualtBgState(value)
	if self.show_defualt_bg then
		self.show_defualt_bg:SetValue(value)
	end
end

function ItemCell:SetShowStar(star_num)
	if star_num > 0 then
		for i=1,star_num do
			if self.show_stars[i] then
				self.show_stars[i]:SetValue(true)
			end
		end
	else
		if self.show_stars then
			for k, v in pairs(self.show_stars) do
				v:SetValue(false)
			end
		end
	end
end

function ItemCell:NotShowStar()
	for i=1,3 do
		if self.show_stars[i] then
			self.show_stars[i]:SetValue(false)
		end
	end
end

function ItemCell:SetQualityGray(is_show)
	if self.show_quality_gray then
		if self.quality_enbale then
			self.show_quality_gray:SetValue(is_show)
		end
	end
end

function ItemCell:SetIconScale(need_scale)
	if self.icon_img then
		self.icon_img.transform.localScale = need_scale
	end
end

function ItemCell:SetIconNativeSize()
	if self.icon_img then
		self.icon_img.image:SetNativeSize()
	end
end