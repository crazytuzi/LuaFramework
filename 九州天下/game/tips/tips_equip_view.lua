local CommonFunc = require("game/tips/tips_common_func")
TipsEquipView = TipsEquipView or BaseClass(BaseView)
local ShowRemindLevel = 60					-- 出现可装备阶数是否为最大阶数提示的最低等级
function TipsEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips","RoleEquipTip"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)

	self.base_attr_list = {}
	self.legend_attr_list = {}
	self.cast_attr_list = {}
	self.streng_attr_list = {}
	self.star_list = {}
	self.stone_item = {}
	self.stone_attr_list = {}
	self.upstar_attr_list = {}
	self.deity_attr_list = {}
	self.deity_spc_attr = nil
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
	self.cell_height = 0
	self.list_spacing = 0
	self.property_list_num = 0 
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
	self.deity_attr_list = {}
	self.deity_spc_attr = nil
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

	for k,v in pairs(self.deity_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.deity_attr_list = {}

	for k, v in pairs(self.suit_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.suit_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil
	self.gift_id = nil
	self.is_data_param_nil = false
	self.property_list_num = 0 


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
	self.name_effect = nil
	self.cast_shuxing_text = nil
	self.show_cast_shuxing = nil
	self.frame = nil
	self.equip_description = nil
	self.equip_status = nil
	self.legend_level = nil
	self.show_deity = nil
	self.show_deity_spc_attr = nil
	self.islegendtext = nil
	self.role_level = nil
	self.max_grade = nil
	self.up_desc = nil
	self.is_show_splane = nil
	self.can_up_cap = nil
	self.equip_frame = nil
	self.deity_spc_attr = nil
	self.equip_zhiye = nil
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
	self.property_list_num = 0 
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

	for i = 1, GameEnum.STONE_TOTAL_NUM do
		--self.stone_item[i] = ItemCell.New()
		--self.stone_item[i]:SetInstanceParent(self:FindObj("StoneItem"..i))
		self.stone_attr_list[i] = {scend_attr = self:FindVariable("StoneAttr2"..i), attr_name = self:FindVariable("StoneAttrName"..i),
									attr_value = self:FindVariable("StoneAttrValue"..i), is_show = self:FindVariable("ShowStone"..i)
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
		local deity_attrs = self:FindObj("DeityAttrs")
		self.deity_spc_attr = self:FindObj("DeityAttrsSpeAttr")
		self.deity_attr_list[#self.deity_attr_list + 1] = deity_attrs:FindObj("DeityAttr"..i)
	end

	self.wear_icon = self:FindVariable("IsShowWearIcon")
	self.show_no_trade = self:FindVariable("ShowNoTrade")

	self.show_strengthen_attr = self:FindVariable("ShowStrengthenAttr")
	self.show_cast_attr = self:FindVariable("ShowCastAttr")
	self.show_legend_attr = self:FindVariable("ShowLegendAttr")
	self.show_gemstone_attr = self:FindVariable("ShowGemstoneAttr")
	self.show_upstar_attr = self:FindVariable("ShowUpStarAttr")
	self.show_deity = self:FindVariable("ShowDeity")
	self.show_deity_spc_attr = self:FindVariable("ShowDeitySpcAttr")

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
	self.legend_level = self:FindVariable("LegendLevel")

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
	self.equip_description = self:FindVariable("EquipDescription")
	self.equip_status = self:FindVariable("EquipStatus")
	self.islegendtext = self:FindVariable("IsLegendText")

	-- 可装备阶数最大阶数提示
	self.role_level = self:FindVariable("RoleLevel")
	self.max_grade = self:FindVariable("MaxGrade")
	self.up_desc = self:FindVariable("Desc")
	self.is_show_splane = self:FindVariable("IsShowSPlane")
	self.can_up_cap = self:FindVariable("UpCap")
	self.up_desc:SetValue(Language.RedEquip.UpPanelDesc)
	self:ListenEvent("ClickSkip",BindTool.Bind(self.OnClickSkip, self))

	--根据显示内容改变面板的长短
	self.frame = self:FindObj("Frame")
	self.equip_frame = self:FindObj("EquipFrame")
	self.cell_height = 28																			--28是单条属性的高度				
	self.list_spacing = 1	
	self.equip_zhiye = self:FindVariable("Equip_zhiye")																		--间距
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
				attr.text.text = key..": "..ToColorStr(value, TEXT_COLOR.BLUE_1)
				count = count + 1
				self.property_list_num = self.property_list_num + 1
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
				value = (k ~= "per_pvp_hurt_increase" and k ~= "per_pvp_hurt_reduce") and v or (v * 0.01 .. "%")
			end
		end
		if key ~= nil and key ~= "nil" then
			local attr = table[count]
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
				--local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
				--local asset, name = ResPath.GetBaseAttrIcon(k)
				--image_obj.image:LoadSprite(asset, name)
				--attr.text.text = key..": "..ToColorStr(value, TEXT_COLOR.BLUE_1)
				attr.text.text = key..": "..value
			end
			count = count + 1
			self.property_list_num = self.property_list_num + 1
			if is_legend then
				self.show_legend = true
				self.property_list_num = self.property_list_num + 1
			elseif is_cast then
				self.show_cast = true
				self.property_list_num = self.property_list_num + 1
			end
		end
	end

	--国战项目没有这个加成
	-- self.show_cast_shuxing:SetValue(self.show_cast == true)
	-- if self.show_cast == true then
	-- 	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	-- 	if item_cfg then
	-- 		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	-- 		local cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, data.shen_level)
	-- 		self.cast_shuxing_text:SetValue(string.format(Language.Forge.ShuXingAddDesc, cfg.attr_percent))
	-- 	end
	-- end
end

function TipsEquipView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local show_strengthen, show_gemstone, show_upstar = false, false, false
	
	if item_cfg == nil then
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	--装备描述
	self.equip_description:SetValue(item_cfg.description)

	--从当前穿着装备中打开面板
	if self.from_view == TipsFormDef.FROM_BAG_EQUIP then
		self.wear_icon:SetValue(true)
		self.show_suit_attr:SetValue(true)
		self.equip_status:SetValue(Language.Equip.HasDress)
		local max_order = self:CalculateMaxOrder()
		-- 等级不低于60 出现可装备阶数是否为最大阶数提示
		local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
		local cap_gap = self:CalculateCapGap(item_cfg)
		if self.role_level and self.max_grade and nil ~= max_order and cap_gap > 0 and main_role_lv >= ShowRemindLevel then
			self.role_level:SetValue(string.format(Language.RedEquip.RoleLevel, main_role_lv))
			local cur_order = string.format(Language.Common.Order, item_cfg.order)	--"%d阶"
			if item_cfg.order < max_order then
				cur_order = ToColorStr(cur_order, TEXT_COLOR.RED)
			else
				cur_order = ToColorStr(cur_order, TEXT_COLOR.YELLOW)
			end
			local max_order = string.format(Language.Common.Order, max_order)	--"%d阶"
			self.max_grade:SetValue(cur_order .. "/" .. max_order)
			self.is_show_splane:SetValue(true)
			--  这个值 加上 “人物当前等级*6（理论每级每条属性增加战力）*3（随机属性条数）”
			cap_gap = cap_gap + (main_role_lv * 3 * 6)
			self.can_up_cap:SetValue(string.format(Language.RedEquip.CanUpCap, cap_gap))
		else
			self.is_show_splane:SetValue(false)
		end
	else
		self.show_suit_attr:SetValue(false)
		self.is_show_splane:SetValue(false)
		--装备是否绑定
		if self.data.is_bind == 1  then
			self.wear_icon:SetValue(true)
			self.equip_status:SetValue(Language.Equip.HasBind)
		else
			self.wear_icon:SetValue(false)
		end	
	end

	if self.show_no_trade then
		if self.data.is_bind then
			self.show_no_trade:SetValue(self.data.is_bind == 1)
		else
			self.show_no_trade:SetValue(true)
		end
	end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	-- local color_1 = EquipData.Instance:GetTextColor1(item_cfg.color)
	-- local color_2 = EquipData.Instance:GetTextColor2(item_cfg.color)
	-- self.color_1:SetValue(color_1)
	-- self.color_2:SetValue(color_2)
	self.equip_name:SetValue(name_str)
	self.equip_type:SetValue(Language.EquipTypeToName[equip_index])
	--self.grade:SetValue(CommonDataManager.GetDaXie(item_cfg.order))
	self.grade:SetValue(item_cfg.order)


	local bundle, sprite = nil, nil
	local color = nil
	-- bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	-- self.quality:SetAsset(bundle, sprite)
	bundle, sprite = ResPath.GetQualityLineBgIcon(item_cfg.color)
	self.qualityline:SetAsset(bundle, sprite)

	local vo = GameVoManager.Instance:GetMainRoleVo()

	local level_befor = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100) or 0
	local level_behind = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1) or 0

	if item_cfg.equip_level then
		if item_cfg.equip_level == "" or item_cfg.equip_level <= 0 then
			level_befor = 0
			level_behind = 0
		-- else
		-- 	level_befor = math.floor(item_cfg.equip_level % 100) ~= 0 and math.floor(item_cfg.equip_level % 100) or 100
		-- 	level_behind = math.floor(item_cfg.equip_level % 100) ~= 0 and math.floor(item_cfg.equip_level / 100) or math.floor(item_cfg.equip_level / 100) - 1
		end
	end

	local level_zhuan = string.format(Language.Common.Zhuan_Level, item_cfg.equip_level)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.level:SetValue(level_str)

	local prof_str = (vo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) and Language.Common.ProfName[item_cfg.limit_prof]
						or string.format(Language.Mount.ShowRedStr, Language.Common.ProfName[item_cfg.limit_prof])
	local flag = item_cfg.sub_type >= GameEnum.E_TYPE_QINGYUAN_1 and item_cfg.sub_type <= GameEnum.E_TYPE_QINGYUAN_4
	self.equip_zhiye:SetValue(flag)					
	if flag then
		prof_str = Language.Common.SexName[item_cfg.limit_sex] or string.format(Language.Mount.ShowRedStr, Language.Common.ProfName[item_cfg.limit_prof])
	end								
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

	--属性排序
	local base_sort_attr_list = {}
	local count = 1
	for k, v in pairs(base_attr_list) do
		if v > 0 then
			base_sort_attr_list[count] = {}
			base_sort_attr_list[count].name = k
			base_sort_attr_list[count].value = v
			base_sort_attr_list[count].sort = CommonDataManager.base_sort_list[k]
			count = count + 1
		end
	end
	SortTools.SortAsc(base_sort_attr_list, "sort")

	for k, v in pairs(base_sort_attr_list) do
		-- if v > 0 then
		local obj = self.base_attr_list[base_attr_count].gameObject
		--local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
		self.base_attr_list[base_attr_count].gameObject:SetActive(true)
		self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[v.name]..": "..v.value		--ToColorStr(v, TEXT_COLOR.BLUE_1)
		base_attr_count = base_attr_count + 1
		self.property_list_num = self.property_list_num + 1
			--local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[k])
			--image_obj.image:LoadSprite(asset, name)
		-- else
		-- 	self.base_attr_list[base_attr_count].gameObject:SetActive(false)
		-- end
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
					self.property_list_num = self.property_list_num + 1
					local vo_level = GameVoManager.Instance:GetMainRoleVo().level
					local xianpin_level = ConfigManager.Instance:GetAutoConfig("equipforge_auto")
					if xianpin_level then
						local xianpin_attr_leve = item_cfg.equip_level + xianpin_level["other"][1].xianpin_attr_level_param
						self.legend_level:SetValue(xianpin_attr_leve)
					end
					self.islegendtext:SetValue(item_cfg.color >= GameEnum.ITEM_COLOR_GLOD)	
					--控制天赋颜色
					color = TEXT_COLOR.ORANGE_3
					if legend_cfg.color == 1 then
						color = TEXT_COLOR.PURPLE_3
					end
					local t = ToColorStr(legend_cfg.desc, color)
					--local t = legend_cfg.desc
					table.insert(l_data, t)
				end
			end
		end
	end
	-- self:HandelAttrs(base_result, self.base_attr_list)

	-- local cap = ForgeData.Instance:GetGemPowerByIndex(equip_index)
	-- local attr, capability = ForgeData.Instance:GetEquipAttrAndPower(self.data)

	local recycle_jingyan = EquipData.Instance:GetEquipResolve(item_cfg.color, item_cfg.equip_level)
	if recycle_jingyan then
		self.recycle_value:SetValue(recycle_jingyan)
	end
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
		--self.storge_score:SetValue(item_cfg.guild_storage_score)
	else
		self.show_storge_score:SetValue(false)
	end
	self.storge_score:SetValue(item_cfg.guild_storage_score)

	self:HandelAttrs(l_data, self.legend_attr_list, true)

	-- if self.from_view ~= TipsFormDef.FROM_BAG_EQUIP and self.handle_param_t.role_vo == nil then
	-- 	self.show_strengthen_attr:SetValue(false)
	-- 	self.show_cast_attr:SetValue(false)
	-- 	self.show_gemstone_attr:SetValue(false)
	-- 	self.show_upstar_attr:SetValue(false)
	-- 	self:HandelAttrs({}, self.streng_attr_list)
	-- 	self:HandelAttrs({}, self.cast_attr_list)
	-- 	return
	-- end

	self:HandelAttrs(strength_result, self.streng_attr_list)
	self:HandelAttrs(cast_result, self.cast_attr_list, false, true)
	

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	local cur_shen_level = self.data.param.grid_shen_level or self.data.param.shen_level
	if cur_shen_level > 0 then
		self.show_effe:SetValue(true)
	else
		self.show_effe:SetValue(false)
	end

	if self.data.param then
		local cur_strengthen_level = self.data.param.grid_strengthen_level or self.data.param.strengthen_level
		if cur_strengthen_level > 0 then
			show_strengthen = true
			self.property_list_num = self.property_list_num + 1
		end

		local cur_star_level = self.data.param.grid_star_level or self.data.param.star_level
		if cur_star_level > 0 then
			show_upstar = true
			self.property_list_num = self.property_list_num + 1
		end
		local cur_star_level = self.data.param.grid_star_level or self.data.param.star_level
		local star_attr = ForgeData.Instance:GetStarAttr(equip_index, cur_star_level)
		self:HandelAttrs(star_attr, self.upstar_attr_list)
	end
	-- 宝石属性
	--if equip_index >= 0 and self.from_view ~= TipsFormDef.FROM_BAG and self.from_view ~= TipsFormDef.FROM_STORGE_ON_BAG_STORGE then
	if equip_index >= 0 and (self.from_view == TipsFormDef.FROM_BAG_EQUIP or self.from_view == TipsFormDef.FROME_BROWSE_ROLE 
		or self.from_view == TipsFormDef.FROM_CHECK_OTHER) then
		for k, v in pairs(self.stone_attr_list) do
			v.is_show:SetValue(false)
		end
		local info = {}
		local sort_stone_attr = {}
		local stone_num = 0
		if self.from_view == TipsFormDef.FROM_CHECK_OTHER then
			info = CheckData.Instance:GetRoleInfo().stone_param or {}
		else
			info = ForgeData.Instance:GetGemInfo()
		end
		for k, v in pairs(info) do
			if k == equip_index then
				for i, j in pairs(v) do
					-- self.stone_attr_list[i + 1].is_show:SetValue(j.stone_id > 0)
					if j.stone_id > 0 then
						stone_num = stone_num + 1
						self.stone_attr_list[stone_num].is_show:SetValue(true)
						show_gemstone = true
						self.property_list_num = self.property_list_num + 1
						local stone_cfg = ForgeData.Instance:GetGemCfg(j.stone_id)
						local data = {}
						data.item_id = j.stone_id
						data.is_bind = 0
						--self.stone_item[i + 1]:SetData(data)
						local stone_attr = ForgeData.Instance:GetGemAttr(j.stone_id)
						--宝石属性大于2时
						-- if #stone_attr >= 2 then
						-- 	local str = self:StoneScendAttrString(stone_attr[2].attr_name, stone_attr[2].attr_value)
						-- 	self.stone_attr_list[i + 1].scend_attr:SetValue(str)
						-- 	self.property_list_num = self.property_list_num + 1
						-- end
						-- self.stone_attr_list[i + 1].attr_name:SetValue(stone_attr[1].attr_name)
						-- self.stone_attr_list[i + 1].attr_value:SetValue(stone_attr[1].attr_value)
						table.insert(sort_stone_attr, stone_attr[1])
					end
				end
			end
		end
		SortTools.SortDesc(sort_stone_attr, "number_value")

		for k, v in pairs(sort_stone_attr) do
			self.stone_attr_list[k].attr_name:SetValue(v.attr_name)
			self.stone_attr_list[k].attr_value:SetValue(v.attr_value)
		end
	end

	--征途属性
	local name = item_cfg.name
	if self.data.param and self.data.param.angel_level and self.data.param.angel_level > 0 then
		name = DeitySuitData.ReplacePrefix(name)
		self.show_deity:SetValue(true)

		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local cfg = DeitySuitData.Instance:GetShenzhuangCfg(equip_index, self.data.param.angel_level)
		local deity_attr_list = CommonDataManager.GetAttributteNoUnderline(cfg, true)
		local deity_attr_count = 0
		for k, v in pairs(deity_attr_list) do
			if v > 0 then
				deity_attr_count = deity_attr_count + 1
				if nil == self.deity_attr_list[deity_attr_count] then
					break
				end 
				self.deity_attr_list[deity_attr_count].gameObject:SetActive(true)
				self.deity_attr_list[deity_attr_count].text.text = ToColorStr(Language.Common.AttrNameNoUnderline[k]..": ".. v, COLOR.ORANGE)
			end
		end

		for i = deity_attr_count + 1, #self.deity_attr_list do
			self.deity_attr_list[i].gameObject:SetActive(false)
		end

		local star_num = 0
		if self.data.param and self.data.param.xianpin_type_list then
			for k,v in pairs(self.data.param.xianpin_type_list) do
				if v ~= nil then
					local xin_data = ForgeData.Instance:GetLegendCfgByType(v)
					if xin_data ~= nil and xin_data.color ~= nil and xin_data.color == 2 then
						star_num = star_num + 1
					end
				end
			end
			--star_num = #self.data.param.xianpin_type_list
		end
		self.show_deity_spc_attr:SetValue(star_num > 0)
		local add_rate = cfg["red_ratio_" .. star_num] or 0
		if item_cfg.color >= GameEnum.ITEM_COLOR_GLOD then
			add_rate = cfg["pink_ratio"] or 0
		end
		self.deity_spc_attr.text.text = string.format(Language.Common.EquipTipsDesc, (add_rate / 100) .. "%")
	else
		self.show_deity:SetValue(false)
		self.show_deity_spc_attr:SetValue(false)
	end



	--套装属性
	local suit_type = ForgeData.Instance:GetCurEquipSuitType(equip_index)
	self.show_suit_attr:SetValue(false)
	if suit_type == 1 or suit_type == 2 then
		local suit_uplevel_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.data.item_id)
		local suit_num = ForgeData.Instance:GetSuitNumByItemId(self.data.item_id, suit_type)
		local suit_cfg = ForgeData.Instance:GetSuitAttCfg(suit_uplevel_cfg.suit_id, suit_num, suit_type)
		if nil ~= suit_cfg then
			self.show_suit_attr:SetValue(true)
			self.property_list_num = self.property_list_num + 1
			self.suit_num.text.text = string.format("【%d件】", suit_num)
			self.suit_name.text.text = suit_cfg.suit_name
			self:HandelSuitAttrs(suit_cfg, self.suit_attr_list)
		end
	end

	self.show_strengthen_attr:SetValue(show_strengthen)
	self.show_cast_attr:SetValue(self.show_cast)
	self.show_legend_attr:SetValue(self.show_legend)
	self.show_gemstone_attr:SetValue(show_gemstone)
	self.show_upstar_attr:SetValue(show_upstar)
	
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
		if tx ~= nil then
			--显示回收值
			if handler_type == 23 then
				self.show_recycle:SetValue(true)
			end
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
	self:ShowTipContent()
	showHandlerBtn(self)
	showSellViewState(self)
	self:ChangePanelHeight(self.property_list_num)
end

function TipsEquipView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not CommonFunc.DoClickHandler(self.data, item_cfg, handler_type, self.from_view, self.handle_param_t) then
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
			self.is_data_param_nil = true
			self.gift_id = gift_id
			self.data.param = CommonStruct.ItemParamData()
			self.data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(self.data.item_id, gift_id)
		end
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsEquipView:ChangePanelHeight(item_count)
	--Tips面板长短控制
	local frame_HeightMax = 704
	local frame_HeightMix = 500
	local frame_offset = 264
	self:ChangeHeight(self.frame, item_count, frame_HeightMax, frame_HeightMix, frame_offset)
	self:ChangeHeight(self.equip_frame, item_count, frame_HeightMax, frame_HeightMix, frame_offset)
end

function TipsEquipView:ChangeHeight(panel,item_count,HeightMax,HeightMix,offset)
	--Tips面板长短控制
	local panel_Width = panel.rect.rect.width
	local panel_height = self.cell_height * item_count + self.list_spacing * (item_count - 1) + offset			--offset是listview和底框的间距和
	
	--最小高度和最大高度
	if panel_height > HeightMax then
		panel_height = HeightMax
	end
	if panel_height < HeightMix then
		panel_height = HeightMix
	end
	panel.rect.sizeDelta = Vector2(panel_Width, panel_height)
end

--获得当前人物可穿的装备的最高阶数
function TipsEquipView:CalculateMaxOrder()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then return 0 end
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv, prof, item_cfg.sub_type)
	return max_order
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

function TipsEquipView:OnClickSkip()
	self:Close()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
end