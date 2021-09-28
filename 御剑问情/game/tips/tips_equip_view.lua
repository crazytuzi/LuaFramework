local CommonFunc = require("game/tips/tips_common_func")
TipsEquipView = TipsEquipView or BaseClass(BaseView)

function TipsEquipView.TipsAlwaysShowAttr(sub_type, attr_name)
	if sub_type == GameEnum.EQUIP_TYPE_WUQI and (attr_name == "huixinyiji" or attr_name == "huixinyiji_hurt") then
		return true
	end
	return false
end

function TipsEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab","RoleEquipTip"}
	self.view_layer = UiLayer.Pop

	self.base_attr_list = {}
	self.legend_attr_list = {}
	self.cast_attr_list = {}
	self.streng_attr_list = {}
	self.star_list = {}
	self.stone_item = {}
	self.stone_attr_list = {}
	self.upstar_attr_list = {}
	self.eternity_attr_list = {}		-- 永恒属性
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.show_cast = false
	self.show_legend = false
	self.effect_obj = nil
	self.is_load_effect = false
	self.suit_attr_list = {}
	self.play_audio = true
	self.is_show_eternity = false
end

function TipsEquipView:__delete()
	self.button_label = {}
	self.base_attr_list = {}
	self.legend_attr_list = {}
	self.cast_attr_list = {}
	self.streng_attr_list = {}
	self.star_list = {}
	self.stone_attr_list = {}
	self.upstar_attr_list = {}
	self.button_handle = {}
	self.buttons = {}

	for k, v in pairs(self.stone_item) do
		v:DeleteMe()
	end
	self.stone_item = {}

	self.show_cast = nil
	self.show_legend = nil
	self.suit_attr_list = {}
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function TipsEquipView:ReleaseCallBack()
	CommonFunc.DeleteMe()

	for k, v in pairs(self.base_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.base_attr_list = {}

	for k, v in pairs(self.streng_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.streng_attr_list = {}

	for k, v in pairs(self.cast_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.cast_attr_list = {}

	for k, v in pairs(self.legend_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.legend_attr_list = {}

	for k, v in pairs(self.upstar_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.upstar_attr_list = {}

	for k, v in pairs(self.suit_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.suit_attr_list = {}

	for k, v in pairs(self.eternity_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.eternity_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil
	self.gift_id = nil
	self.is_data_param_nil = false

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	for k, v in pairs(self.stone_item) do
		v:DeleteMe()
	end
	self.stone_item = {}

	-- 清理变量和对象
	self.button_root = nil
	self.buttons = {}
	self.stone_attr_list = {}
	self.wear_icon = nil
	self.show_no_trade = nil
	self.show_strengthen_attr = nil
	self.show_cast_attr = nil
	self.show_legend_attr = nil
	self.show_gemstone_attr = nil
	self.show_upstar_attr = nil
	self.equip_name = nil
	self.equip_type = nil
	self.equip_prof = nil
	self.quality = nil
	self.qualityline = nil
	self.level = nil
	self.fight_power = nil
	self.color_1 = nil
	self.color_2 = nil
	self.type = nil
	self.scroller_rect = nil
	self.grade = nil
	self.show_storge_score = nil
	self.storge_score = nil
	self.recycle_value = nil
	self.show_recycle = nil
	self.show_suit_attr = nil
	self.suit_attrs = nil
	self.suit_name = nil
	self.suit_num = nil
	self.suit_content = nil
	self.show_effe = nil
	self.suit_attr_list = {}
	self.name_effect = nil
	self.cast_shuxing_text = nil
	self.show_cast_shuxing = nil
	self.orange_crystal = nil
	self.show_orange_crystal = nil
	self.red_crystal = nil
	self.show_red_crystal = nil
	self.show_eternity_attr = nil
	self.role_level = nil
	self.max_grade = nil
	self.cur_grade = nil
	self.show_small_plane = nil
	self.can_up_cap = nil
end

function TipsEquipView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.show_cast = false
	self.show_legend = false
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}

	self.gift_id = nil
	self.is_data_param_nil = false
end

function TipsEquipView:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
end

function TipsEquipView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = button:FindObj("Text")
		self.buttons[i] = {btn = button, text = btn_text}
		-- self.star_list[i] = {is_show = self:FindVariable("ShowStar"..i), sprite = self:FindVariable("Star"..i)}
	end
	for i = 1, 7 do
		self.stone_item[i] = ItemCell.New()
		self.stone_item[i]:SetInstanceParent(self:FindObj("StoneItem"..i))
		self.stone_attr_list[i] = {scend_attr = self:FindVariable("StoneAttr2"..i), attr_name = self:FindVariable("StoneAttrName"..i),
									attr_value = self:FindVariable("StoneAttrValue"..i), is_show = self:FindVariable("ShowStone"..i),
		}
	end

	-- local obj_group = self:FindObj("ObjGroup")
	-- local child_number = obj_group.transform.childCount
	-- local count = 1
	-- for i = 0, child_number - 1 do
	-- 	local obj = obj_group.transform:GetChild(i).gameObject
	-- 	if string.find(obj.name, "BaseAttr") ~= nil then
	-- 		self.base_attr_list[#self.base_attr_list + 1] = U3DObject(obj)
	-- 	elseif string.find(obj.name, "StrengthenAttr") ~= nil then
	-- 		self.streng_attr_list[#self.streng_attr_list + 1] = U3DObject(obj)
	-- 	elseif string.find(obj.name, "CastAttr") ~= nil then
	-- 		self.cast_attr_list[#self.cast_attr_list + 1] = U3DObject(obj)
	-- 	elseif string.find(obj.name, "LegendAttr") ~= nil then
	-- 		self.legend_attr_list[#self.legend_attr_list + 1] = U3DObject(obj)
	-- 	end
	-- end

	local base_attrs = self:FindObj("BaseAttrs")
	for i = 1, base_attrs.transform.childCount do
		self.base_attr_list[#self.base_attr_list + 1] = base_attrs:FindObj("BaseAttr"..i)
		local strengthen_attrs = self:FindObj("StrengthenAttrs")
		self.streng_attr_list[#self.streng_attr_list + 1] = strengthen_attrs:FindObj("StrengthenAttr"..i)
		local cast_attrs = self:FindObj("CastAttrs")
		self.cast_attr_list[#self.cast_attr_list + 1] = cast_attrs:FindObj("CastAttr"..i)
		local legend_attrs = self:FindObj("LegendAttrs")
		self.legend_attr_list[#self.legend_attr_list + 1] = legend_attrs:FindObj("LegendAttr"..i)
		local upstar_attrs = self:FindObj("UpStarAttrs")
		self.upstar_attr_list[#self.upstar_attr_list + 1] = upstar_attrs:FindObj("UpStarAttr"..i)
		local eternity_attr = self:FindObj("EternityAttrs")
		self.eternity_attr_list[#self.eternity_attr_list + 1] = eternity_attr:FindObj("EternityAttr"..i)
	end

	self.wear_icon = self:FindVariable("IsShowWearIcon")
	self.show_no_trade = self:FindVariable("ShowNoTrade")

	self.show_strengthen_attr = self:FindVariable("ShowStrengthenAttr")
	self.show_cast_attr = self:FindVariable("ShowCastAttr")
	self.show_legend_attr = self:FindVariable("ShowLegendAttr")
	self.show_gemstone_attr = self:FindVariable("ShowGemstoneAttr")
	self.show_upstar_attr = self:FindVariable("ShowUpStarAttr")
	self.show_eternity_attr = self:FindVariable("ShowEternityAttr")

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.equip_prof = self:FindVariable("EquipProf")
	self.quality = self:FindVariable("Quality")
	self.qualityline = self:FindVariable("QualityLine")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")
	self.color_1 = self:FindVariable("Color1")
	self.color_2 = self:FindVariable("Color2")
	self.type = self:FindVariable("Type")

	self.orange_crystal = self:FindVariable("OrangeCrystal")
	self.show_orange_crystal = self:FindVariable("ShowOrangeCrystal")
	self.red_crystal = self:FindVariable("RedCrystal")
	self.show_red_crystal = self:FindVariable("ShowRedCrystal")

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.grade = self:FindVariable("Grade")

	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.storge_score = self:FindVariable("StorgeScore")
	self.recycle_value = self:FindVariable("RecycleValue")
	self.show_recycle = self:FindVariable("ShowRecycle")

	self.show_suit_attr = self:FindVariable("ShowSuitAttr")
	self.suit_attrs = self:FindObj("SuitAttrs")
	self.suit_name = self.suit_attrs:FindObj("SuitName")
	self.suit_num = self.suit_attrs:FindObj("SuitNum")
	self.suit_content = self.suit_attrs:FindObj("SuitContent")
	self.show_effe = self:FindVariable("ShowEffe")
	for i = 1, self.suit_content.transform.childCount do
		self.suit_attr_list[#self.suit_attr_list + 1] = self.suit_content:FindObj("SuitAtt"..i)
	end

	self.name_effect = self:FindObj("NameEffect")

	self.show_recycle:SetValue(false)

	self.cast_shuxing_text = self:FindVariable("CastShuXingText")
	self.show_cast_shuxing = self:FindVariable("ShowCastShuXing")

	self.role_level = self:FindVariable("MainRoleLevel")
	self.max_grade = self:FindVariable("MaxGrade")
	self.cur_grade = self:FindVariable("CurGrade")
	self.show_small_plane = self:FindVariable("IsShowSPlane")
	self.can_up_cap = self:FindVariable("CanUpCap")

	self:ListenEvent("ClickSkip",BindTool.Bind(self.OnClickSkip, self))
end

function TipsEquipView:OnClickSkip()
	self:Close()
	BossData.Instance:SetSelectIndexFlag(true)
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
end

--套装属性设置
function TipsEquipView:HandelSuitAttrs(data, table)
	for i=1,#table do
		table[i].gameObject:SetActive(false)
	end
	local count = 1
	for k,v in ipairs(CommonDataManager.suit_att_t) do
		local key = nil
		local value = data[v[1]]
		if value > 0 then
			key = Language.Common.SuitAttName[v[1]]
			if k > 7 then
				value = value/100 .. "%"
			end
		end
		if key ~= nil then
			local attr = table[count]
			if attr then
				attr.gameObject:SetActive(true)
				attr.text.text = key..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
				count = count + 1
			else
				break
			end
		end
	end
end

function TipsEquipView:HandelAttrs(data, table, is_legend, is_cast)
	for i=1,#table do
		table[i].gameObject:SetActive(false)
	end
	local count = 1

	if nil == data then
		return
	end

	for k,v in pairs(data) do
		local key = nil
		local value = nil
		if is_legend then
			key = v
		else
			if v > 0 then
				key = CommonDataManager.GetAttrName(k)
				value = v
			end
		end
		if key ~= nil and key ~= "nil" then
			local attr = table[count]
			if nil ~= attr then
				attr.gameObject:SetActive(true)
				if is_legend then
					if self.is_data_param_nil and (not self.gift_id or
						(self.gift_id and not ForgeData.Instance:GetEquipIsNotRandomGift(self.data.item_id, self.gift_id))) then

						if count == 1 then
							attr.text.text = v
						else
							attr.text.text = Language.Forge.RandomAttrDes..v
						end
					else
						attr.text.text = v
					end
				else
					local obj = attr.gameObject
					local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
					local asset, name = ResPath.GetBaseAttrIcon(k)
					image_obj.image:LoadSprite(asset, name, function()
						image_obj.image:SetNativeSize()
					end)
					attr.text.text = key..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
				end
				count = count + 1
				if is_legend then
					self.show_legend = true
				elseif is_cast then
					self.show_cast = true
				end
			end
		end
	end

	self.show_cast_shuxing:SetValue(self.show_cast == true)
	if self.show_cast == true then
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		if item_cfg then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			local cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, data.shen_level)
			self.cast_shuxing_text:SetValue(string.format(Language.Forge.ShuXingAddDesc, cfg.attr_percent))
		end
	end
end

--计算当前装备与人物同部位可穿的最高阶红装的战力差距
function TipsEquipView:CalculateCapGap(item_cfg)
	if not item_cfg then return 0 end
	local max_order = self:CalculateMaxOrder()
	local max_order_cfg = ItemData.Instance:GetRedEquipCfgBySearchTypeAndOrder(item_cfg.search_type, max_order)		--根据当前装备的搜索类型和人物可穿的最大阶数获取对应的红装的配置
	if not max_order_cfg then return 0 end
	local max_data = {item_id = max_order_cfg.id}
	local cur_data = {item_id = item_cfg.id}
	local max_equip_cap = EquipData.Instance:GetEquipLegendFightPowerByData(max_data)		--获得最高阶红装战力
	local cur_equip_cap = EquipData.Instance:GetEquipLegendFightPowerByData(cur_data)		--获得当前装备战力
	return max_equip_cap - cur_equip_cap
end

--获得当前人物可穿的装备的最高阶数
function TipsEquipView:CalculateMaxOrder()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	return max_order
end

function TipsEquipView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local show_strengthen, show_gemstone, show_upstar = false, false, false
	if item_cfg == nil then
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)

	if self.from_view == TipsFormDef.FROM_BAG_EQUIP then
		self.wear_icon:SetValue(true)
		self.show_suit_attr:SetValue(true)
		local max_order = self:CalculateMaxOrder()
		-- 等级不低于130 出现可装备阶数是否为最大阶数提示
		local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
		local role_zhuan = PlayerData.GetLevelString(main_role_lv)
		local cap_gap = self:CalculateCapGap(item_cfg)
		if self.role_level and self.max_grade and nil ~= max_order and cap_gap > 0 and main_role_lv >= 130 then
			self.role_level:SetValue(role_zhuan)
			local cur_order = string.format(Language.Common.Order, item_cfg.order)	--"%d阶"
			if item_cfg.order < max_order then
				cur_order = ToColorStr(cur_order, TEXT_COLOR.RED)
			end
			self.cur_grade:SetValue(cur_order)
			self.max_grade:SetValue(max_order)
			self.show_small_plane:SetValue(true)
			self.can_up_cap:SetValue(cap_gap)
		else
			self.show_small_plane:SetValue(false)
		end
	else
		self.wear_icon:SetValue(false)
		self.show_suit_attr:SetValue(false)
	end
	if self.show_no_trade then
		if self.data.is_bind then
			self.show_no_trade:SetValue(self.data.is_bind == 1)
		else
			self.show_no_trade:SetValue(true)
		end
	end
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	-- local color_1 = EquipData.Instance:GetTextColor1(item_cfg.color)
	-- local color_2 = EquipData.Instance:GetTextColor2(item_cfg.color)
	-- self.color_1:SetValue(color_1)
	-- self.color_2:SetValue(color_2)
	if self.is_show_eternity then
		local cfg = ForgeData.Instance:GetEternityEquipCfg(equip_index)
		local etern_name = ""
		if nil ~= cfg then
			etern_name = cfg.name
		end
		name_str = string.format(Language.Common.ToColor, ITEM_TIP_NAME_COLOR[item_cfg.color], string.format(Language.Forge.EternityDes, name_str, etern_name))
	end
	self.equip_name:SetValue(name_str)
	self.equip_type:SetValue(Language.EquipTypeToName[equip_index])
	self.grade:SetValue(item_cfg.order)

	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	self.quality:SetAsset(bundle, sprite)
	bundle, sprite = ResPath.GetQualityLineBgIcon(item_cfg.color)
	self.qualityline:SetAsset(bundle, sprite)

	local vo = GameVoManager.Instance:GetMainRoleVo()

	local level_befor = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100) or 0
	local level_behind = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1) or 0

	if item_cfg.equip_level then
		if item_cfg.equip_level == "" or item_cfg.equip_level <= 0 then
			level_befor = 0
			level_behind = 0
		else
			level_befor = math.floor(item_cfg.equip_level % 100) ~= 0 and math.floor(item_cfg.equip_level % 100) or 100
			level_behind = math.floor(item_cfg.equip_level % 100) ~= 0 and math.floor(item_cfg.equip_level / 100) or math.floor(item_cfg.equip_level / 100) - 1
		end
	end

	local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.level:SetValue(level_str)

	local prof_str = (vo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) and Language.Common.ProfName[item_cfg.limit_prof]
						or string.format(Language.Mount.ShowRedStr, Language.Common.ProfName[item_cfg.limit_prof])
	self.equip_prof:SetValue(prof_str)

	if self.is_data_param_nil then
		if (self.gift_id and not ForgeData.Instance:GetEquipIsNotRandomGift(self.data.item_id, self.gift_id)) or not self.gift_id then
			self.equip_item:SetData(self.item_data)
		else
			self.equip_item:SetData(self.data)
		end
	else
		self.equip_item:SetData(self.data)
	end
	self.equip_item:SetInteractable(false)

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	local base_attr_count = 1
	local base_attr_name = CommonStruct.AttributeName()
	for k, v in ipairs(base_attr_name) do
		local value = base_attr_list[v] or 0
		if value > 0 or ((self.from_view == TipsFormDef.FROM_BAG_EQUIP or self.from_view == TipsFormDef.FROME_BROWSE_ROLE) and TipsEquipView.TipsAlwaysShowAttr(item_cfg.sub_type, v)) then
			local obj = self.base_attr_list[base_attr_count].gameObject
			local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			if v == "huixinyiji" or v == "huixinyiji_hurt" then
				local use_eternity_level = self.data.use_eternity_level or EquipData.Instance:GetMinEternityLevel()
				local hxyj, hxyj_hurt = ForgeData.Instance:GetEternitySuitHXYJPerByLevel(use_eternity_level)
				if v == "huixinyiji" then
					value = hxyj
				else
					value = hxyj_hurt
				end
				value = value / 100 .. "%"
			end
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[v]..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
			base_attr_count = base_attr_count + 1
			local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[v])
			image_obj.image:LoadSprite(asset, name, function()
				image_obj.image:SetNativeSize()
			end)
		else
			self.base_attr_list[base_attr_count].gameObject:SetActive(false)
		end
	end

	for i = base_attr_count, #self.base_attr_list do
		self.base_attr_list[i].gameObject:SetActive(false)
	end

	--基础、强化、神铸、传奇属性
	local base_result, strength_result, cast_result = ForgeData.Instance:GetForgeAddition(self.data)
	local l_data = {}
	-- 设置推荐随机属性文本描述
	if self.is_data_param_nil and next(self.data.param.xianpin_type_list) and (not self.gift_id or
		(self.gift_id and not ForgeData.Instance:GetEquipIsNotRandomGift(self.data.item_id, self.gift_id))) then

		local attr_num = item_cfg and item_cfg.color or 0
		local attr_des = ""
		if self.data.speacal_from then
			attr_num = self.data.show_star_num
			attr_des = string.format(Language.Forge.MustCreateAttr, attr_num)
		else
			attr_num = attr_num - 2
			attr_des = string.format(Language.Forge.RandomCreateAttr, attr_num)
		end
		table.insert(l_data, attr_des)
	end
	self.show_legend_attr:SetValue(false)
	if self.data.param and self.data.param.xianpin_type_list then
		for k,v in pairs(self.data.param.xianpin_type_list) do
			if v ~= nil and v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if legend_cfg ~= nil then
					self.show_legend_attr:SetValue(true)
					color = TEXT_COLOR.BLACK_1
					if legend_cfg.color == 1 then
						color = TEXT_COLOR.BLACK_1
					end
					--计算仙品属性加成的描述
					local xianpin_order_desc = ForgeData.Instance:CalculateLegendDes(legend_cfg, item_cfg.order)
					--local t = ToColorStr(legend_cfg.desc, color)
					local t = ToColorStr(xianpin_order_desc, color)
					table.insert(l_data, t)
				end
			end
		end
	end
	-- self:HandelAttrs(base_result, self.base_attr_list)

	-- local cap = ForgeData.Instance:GetGemPowerByIndex(equip_index)
	-- local attr, capability = ForgeData.Instance:GetEquipAttrAndPower(self.data)

	self.recycle_value:SetValue(item_cfg.recyclget)
	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(self.data,
		self.from_view == TipsFormDef.FROM_BAG_EQUIP, not (self.from_view == TipsFormDef.FROM_BAG_EQUIP))
	self.fight_power:SetValue(capability)

	if self.data.speacal_from and self.data.param and self.data.param.xianpin_type_list then
		local valtrue_data = TableCopy(self.data, 3)
		-- local max_num = 3 - self.data.show_star_num
		for i = 1, 2 do
			if nil ~= valtrue_data.param.xianpin_type_list[i] then
				table.remove(valtrue_data.param.xianpin_type_list, i)
			end
		end
		capability = EquipData.Instance:GetEquipLegendFightPowerByData(valtrue_data,
			self.from_view == TipsFormDef.FROM_BAG_EQUIP, not (self.from_view == TipsFormDef.FROM_BAG_EQUIP))
		self.fight_power:SetValue((capability + 60000) * math.pow(1.2, self.data.show_star_num))
	end

	if self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_BAG then
		self.show_storge_score:SetValue(true)
		self.storge_score:SetValue(item_cfg.guild_storage_score)
	else
		self.show_storge_score:SetValue(false)
	end

	self:HandelAttrs(l_data, self.legend_attr_list, true)

	if self.from_view ~= TipsFormDef.FROM_BAG_EQUIP and self.handle_param_t.role_vo == nil then
		self.show_strengthen_attr:SetValue(false)
		self.show_cast_attr:SetValue(false)
		self.show_gemstone_attr:SetValue(false)
		self.show_upstar_attr:SetValue(false)
		self:HandelAttrs({}, self.streng_attr_list)
		self:HandelAttrs({}, self.cast_attr_list)
		return
	end

	self:HandelAttrs(strength_result, self.streng_attr_list)
	self:HandelAttrs(cast_result, self.cast_attr_list, false, true)

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	if self.data.param.shen_level > 0 then
		self.show_effe:SetValue(true)
	else
		self.show_effe:SetValue(false)
	end

	if self.data.param then
		if self.data.param.strengthen_level > 0 then
			show_strengthen = true
		end

		if self.data.param.star_level > 0 then
			show_upstar = true
		end

		local star_attr = ForgeData.Instance:GetStarAttr(equip_index, self.data.param.star_level)
		self:HandelAttrs(star_attr, self.upstar_attr_list)
	end
	-- 宝石属性
	if equip_index >= 0 then
		for k, v in pairs(self.stone_attr_list) do
			v.is_show:SetValue(false)
		end
		local info = {}
		if self.handle_param_t.role_vo then
			info = CheckData.Instance:GetRoleInfo().stone_param or {}
		else
			info = ForgeData.Instance:GetGemInfo()
		end
		for k, v in pairs(info) do
			if k == equip_index then
				for i, j in pairs(v) do
					if self.stone_attr_list[i + 1] then
						self.stone_attr_list[i + 1].is_show:SetValue(j.stone_id > 0)
						if j.stone_id > 0 then
							show_gemstone = true
							local stone_cfg = ForgeData.Instance:GetGemCfg(j.stone_id)
							local data = {}
							data.item_id = j.stone_id
							data.is_bind = 0
							self.stone_item[i + 1]:SetData(data)
							local stone_attr = ForgeData.Instance:GetGemAttr(j.stone_id)
							if #stone_attr == 2 then
								local str = self:StoneScendAttrString(stone_attr[2].attr_name, stone_attr[2].attr_value)
								self.stone_attr_list[i + 1].scend_attr:SetValue(str)
							end
							if #stone_attr == 3 then
								local str2 = string.format(Language.Forge.EquipSpecialGemAttr, stone_attr[2].attr_name, stone_attr[2].attr_value)
								local str3 = string.format(Language.Forge.EquipSpecialGemAttr, stone_attr[3].attr_name, stone_attr[3].attr_value)
								self.stone_attr_list[i + 1].scend_attr:SetValue(str2.."\n"..str3)
							end
							self.stone_attr_list[i + 1].attr_name:SetValue(stone_attr[1].attr_name)
							self.stone_attr_list[i + 1].attr_value:SetValue(stone_attr[1].attr_value)
						end
					end
				end
			end
		end
	end

	--套装属性
	local suit_type = ForgeData.Instance:GetCurEquipSuitType(equip_index)
	self.show_suit_attr:SetValue(false)
	if suit_type == 1 or suit_type == 2 then
		local suit_uplevel_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.data.item_id)
		local suit_num = ForgeData.Instance:GetSuitNumByItemId(self.data.item_id, suit_type)
		local suit_cfg = ForgeData.Instance:GetSuitAttCfg(suit_uplevel_cfg.suit_id, suit_num, suit_type == 2 and -1 or 1)
		if nil ~= suit_cfg then
			self.show_suit_attr:SetValue(true)
			self.suit_num.text.text = string.format("【%d件】", suit_num)
			local prof = PlayerData.Instance:GetRoleBaseProf()
			self.suit_name.text.text = suit_cfg["suit_name_" .. prof]
			self:HandelSuitAttrs(suit_cfg, self.suit_attr_list)
		end
	end


	self.show_strengthen_attr:SetValue(show_strengthen)
	self.show_cast_attr:SetValue(self.show_cast)
	self.show_legend_attr:SetValue(self.show_legend)
	self.show_gemstone_attr:SetValue(show_gemstone)
	self.show_upstar_attr:SetValue(show_upstar)
end

-- 设置回收水晶信息
function TipsEquipView:SetEquipCrystal()
	self.show_red_crystal:SetValue(false)
	self.show_orange_crystal:SetValue(false)

	local param = self.data and self.data.param or {}
	local xianpin_count = param.xianpin_type_list or {}
	local now_cfg = ForgeData.Instance:GetRedEquipComposeCfg(self.data.item_id, #xianpin_count)
	if nil == now_cfg or nil == now_cfg.discard_return[0] then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	if item_cfg.color == 4 then
		self.show_orange_crystal:SetValue(true)
		self.orange_crystal:SetValue(now_cfg.discard_return[0].num)
	elseif item_cfg.color == 5 then
		self.show_red_crystal:SetValue(true)
		self.red_crystal:SetValue(now_cfg.discard_return[0].num)
	end
end

function TipsEquipView:StoneScendAttrString(attr_name, attr_value)
	return string.format("%s+%s", attr_name, attr_value)
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	self.show_recycle:SetValue(false)
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if handler_type == 23 then
			--显示回收值
			self.show_recycle:SetValue(true)
		end

		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			self.button_handle[k] = self:ListenEvent("Button"..k,
				BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

-- 设置永恒属性
function TipsEquipView:SetEternityAttr()
	self.is_show_eternity = false
	if nil == self.data.param
		or nil == self.data.param.eternity_level
		or self.data.param.eternity_level <= 0 then

		self.show_eternity_attr:SetValue(false)
		return
	end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		self.show_eternity_attr:SetValue(false)
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local cfg = ForgeData.Instance:GetEternityEquipCfg(equip_index)
	if nil == cfg then
		self.show_eternity_attr:SetValue(false)
		return
	end

	local attr_list = CommonDataManager.GetAttributteNoUnderline(cfg)
	self:HandelAttrs(attr_list, self.eternity_attr_list)
	self.is_show_eternity = true
	self.show_eternity_attr:SetValue(true)
end

local function showSellViewState(self)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then
		return
	end
	local salestate = CommonFunc.IsShowSellViewState(self.from_view)
end

function TipsEquipView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:SetEternityAttr()
	self:ShowTipContent()
	showHandlerBtn(self)
	showSellViewState(self)
	self:SetEquipCrystal()
end

function TipsEquipView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end
	self:Close()
end

--关闭装备Tip
function TipsEquipView:OnClickCloseButton()
	self:Close()
end

--设置显示弹出Tip的相关属性显示
function TipsEquipView:SetData(data, from_view, param_t, close_call_back, gift_id)
	if not data then
		return
	end
	self.close_call_back = close_call_back
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = TableCopy(data)
		self.item_data = data
		if self.data.param == nil then
			-- self.is_data_param_nil = true
			-- self.gift_id = gift_id
			self.data.param = CommonStruct.ItemParamData()
			-- self.data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(self.data.item_id, gift_id)
			if gift_id and ForgeData.Instance:GetEquipIsNotRandomGift(self.data.item_id, gift_id)  then
				self.is_data_param_nil = true
				self.gift_id = gift_id
				self.data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(self.data.item_id, gift_id)
			end
		end
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end