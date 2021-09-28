local CommonFunc = require("game/tips/tips_common_func")
TipsOtherRoleEquipView = TipsOtherRoleEquipView or BaseClass(BaseView)

function TipsOtherRoleEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab","OtherRoleEquipTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.gift_id = nil
	self.is_data_param_nil = false
end

function TipsOtherRoleEquipView:__delete()

end

function TipsOtherRoleEquipView:ReleaseCallBack()
	CommonFunc.DeleteMe()
	self.equip_tips:DeleteMe()
	self.equip_tips = nil

	self.equip_compare_tips:DeleteMe()
	self.equip_compare_tips = nil
end

function TipsOtherRoleEquipView:LoadCallBack()
	self.equip_tips = TipsEquipComparePanel.New(self:FindObj("EquipTip"), self)
	self.equip_tips.is_mine = true
	self.equip_compare_tips = TipsEquipComparePanel.New(self:FindObj("EquipCompareTip"), self)
	self:ListenEvent("Close",
	BindTool.Bind(self.OnClickCloseButton, self))
end

function TipsOtherRoleEquipView:CloseCallBack()
	if self.equip_tips then
		self.equip_tips:CloseCallBack()
	end
	self.equip_compare_tips:CloseCallBack()
end

function TipsOtherRoleEquipView:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view, self.data_cache.param_t, self.data_cache.close_call_back, self.data_cache.gift_id, self.data_cache.is_check_item)
		self.data_cache = nil
		self:Flush()
	end

	self.equip_tips:OpenCallBack()
	self.equip_compare_tips:OpenCallBack()
end

--关闭装备Tip
function TipsOtherRoleEquipView:OnClickCloseButton()
	self:Close()
end


--设置显示弹出Tip的相关属性显示
function TipsOtherRoleEquipView:SetData(data, from_view, param_t, close_call_back, gift_id, is_check_item)
	if not data then
		return
	end
	if self:IsOpen() and self:IsLoaded() then
		self.equip_compare_tips:SetData(data, from_view, param_t, close_call_back, gift_id, is_check_item, true)
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
		local show_strengthen, show_gemstone = false, false
		if item_cfg == nil then
			return
		end
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local my_data = EquipData.Instance:GetGridData(equip_index)
		if my_data then
			self.equip_tips:SetData(my_data, nil, nil, nil, gift_id, is_check_item, false)
		end
		self:Flush()
	else
		self.data_cache = {data = data, from_view = from_view, param_t = param_t, close_call_back = close_call_back, gift_id = gift_id, is_check_item = is_check_item}
		self:Open()
		self:Flush()
	end
end

function TipsOtherRoleEquipView:OnFlush(param_t)
	self.equip_tips:OnFlush(param_t)
	self.equip_compare_tips:OnFlush(param_t)
end
--=========item====================

TipsEquipComparePanel = TipsEquipComparePanel or BaseClass(BaseRender)

local UP_ARROW_IMAGE_NAME = "arrow_20"
local DOWN_ARROW_IMAGE_NAME = "arrow_21"
local UP_ARROW_IMAGE_NAME_1 = "arrow_15"
local DOWN_ARROW_IMAGE_NAME_1 = "arrow_16"

function TipsEquipComparePanel:__init(instance, parent)
	self.parent = parent
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
	self.is_show_eternity = false
	self:LoadCallBack()
end

function TipsEquipComparePanel:__delete()
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

	for k, v in pairs(self.eternity_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.eternity_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil
	self.parent = nil

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	self.gift_id = nil
	self.is_data_param_nil = false

	for k, v in pairs(self.stone_item) do
		v:DeleteMe()
	end
	self.stone_item = {}
end

function TipsEquipComparePanel:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.show_cast = false
	self.show_legend = false
	self.is_check_item = nil
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
	self.gift_id = nil
	self.is_data_param_nil = false

	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
end

function TipsEquipComparePanel:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
end

function TipsEquipComparePanel:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	for j = 1,5 do 
		local button = self.button_root:FindObj("Btn"..j)
		local btn_text = button:FindObj("Text")
		self.buttons[j] = {btn = button, text = btn_text}
	end
	for i =1 ,7 do
		-- local button = self.button_root:FindObj("Btn"..i)
		-- local btn_text = button:FindObj("Text")
		-- self.buttons[i] = {btn = button, text = btn_text}
		self.stone_item[i] = ItemCell.New()
		self.stone_item[i]:SetInstanceParent(self:FindObj("StoneItem"..i))
		self.stone_attr_list[i] = {scend_attr = self:FindVariable("StoneAttr2"..i), attr_name = self:FindVariable("StoneAttrName"..i),
									attr_value = self:FindVariable("StoneAttrValue"..i), is_show = self:FindVariable("ShowStone"..i)
		}
		self.star_list[i] = {is_show = self:FindVariable("ShowStar"..i), sprite = self:FindVariable("Star"..i)}
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
	self.down_arrow = self:FindVariable("IsShowDownArrow")
	self.show_small_plane = self:FindVariable("IsShowSPlane")
	self.role_level = self:FindVariable("MainRoleLevel")
	self.max_grade = self:FindVariable("MaxGrade")
	self.cur_grade = self:FindVariable("CurGrade")
	self.can_up_cap = self:FindVariable("CanUpCap")


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

	self.orange_crystal = self:FindVariable("OrangeCrystal")
	self.show_orange_crystal = self:FindVariable("ShowOrangeCrystal")
	self.red_crystal = self:FindVariable("RedCrystal")
	self.show_red_crystal = self:FindVariable("ShowRedCrystal")

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.grade = self:FindVariable("Grade")

	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.storge_score = self:FindVariable("StorgeScore")
	self.recycle_value = self:FindVariable("RecycleValue")
	self.show_recycle = self:FindVariable("ShowRecycle")

	self.name_effect = self:FindObj("NameEffect")

	self.show_arrow = self:FindVariable("ShowArrow")
	self.arrow_icon = self:FindVariable("ArrowIcon")

	self.show_recycle:SetValue(false)
	self.cast_shuxing_text = self:FindVariable("CastShuXingText")
	self.show_cast_shuxing = self:FindVariable("ShowCastShuXing")

	self:ListenEvent("ClickSkip",BindTool.Bind(self.OnClickSkip, self))
end

function TipsEquipComparePanel:OnClickSkip()
	ViewManager.Instance:CloseAll()
	BossData.Instance:SetSelectIndexFlag(true)
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
end

function TipsEquipComparePanel:HandelAttrs(data, table, is_legend, is_cast)
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
					if self.is_data_param_nil and not self.gift_id then
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
function TipsEquipComparePanel:CalculateCapGap(item_cfg)
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
function TipsEquipComparePanel:CalculateMaxOrder()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	return max_order
end

function TipsEquipComparePanel:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local show_strengthen, show_gemstone, show_upstar = false, false, false
	if item_cfg == nil then
		return
	end

	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local max_order = self:CalculateMaxOrder()
	local cap_gap = self:CalculateCapGap(item_cfg)
	if nil ~= max_order then
		if not self.is_compare then
			self.down_arrow:SetValue(item_cfg.order < max_order)
		end
		local role_zhuan = PlayerData.GetLevelString(main_role_lv)
		if self.show_small_plane then
			if main_role_lv >= 130 and cap_gap > 0 then
				local cur_order = string.format(Language.Common.Order, item_cfg.order)	--"%d阶"
				if item_cfg.order < max_order then
					cur_order = ToColorStr(cur_order, TEXT_COLOR.RED)
				end
				self.cur_grade:SetValue(cur_order)
				self.role_level:SetValue(role_zhuan)
				self.max_grade:SetValue(max_order)
				self.can_up_cap:SetValue(cap_gap)
				self.show_small_plane:SetValue(true)
			else
				self.show_small_plane:SetValue(false)
			end
		end
	end

	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)

	self.wear_icon:SetValue(self.is_mine == true)
	if self.show_no_trade then
		if self.data.is_bind then
			self.show_no_trade:SetValue(self.data.is_bind == 1)
		else
			self.show_no_trade:SetValue(true)
		end
	end
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
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

	if self.show_arrow then
		local down_power = vo.capability - EquipData.Instance:GetEquipLegendFightPowerByData(self.data) >= COMMON_CONSTS.COMPARE_MIN_POWER
		self.show_arrow:SetValue(down_power)
		local res_str = ((EquipData.Instance:GetEquipLegendFightPowerByData(self.data) - vo.capability) > 0) and UP_ARROW_IMAGE_NAME_1 or DOWN_ARROW_IMAGE_NAME_1
		local arrow_b, arrow_a = ResPath.GetStarImages(res_str)
		self.arrow_icon:SetAsset(arrow_b, arrow_a)
	end

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	local base_attr_count = 1

	for i = 1, #self.base_attr_list do
		local obj = self.base_attr_list[i].gameObject
		obj:SetActive(false)
		if self.is_compare then
			local temp_text_obj = U3DObject(obj.transform:GetChild(1).gameObject)
			if temp_text_obj then
				temp_text_obj.gameObject:SetActive(false)
			end
		end
	end

	local temp_base_attr_list = {}
	if self.is_compare then
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local my_data = EquipData.Instance:GetGridData(equip_index)
		local temp_item_cfg = ItemData.Instance:GetItemConfig(my_data.item_id)
		temp_base_attr_list = CommonDataManager.GetAttributteNoUnderline(temp_item_cfg, true)
	end

	for k, v in pairs(base_attr_list) do
		if v > 0 or (self.is_mine == true and TipsEquipView.TipsAlwaysShowAttr(item_cfg.sub_type, k)) then
			local obj = self.base_attr_list[base_attr_count].gameObject
			local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
			if temp_base_attr_list[k] then
				local temp_text_obj = U3DObject(obj.transform:GetChild(1).gameObject)
				if temp_text_obj then
					local diff_value = v - temp_base_attr_list[k]
					local res_str = diff_value > 0 and UP_ARROW_IMAGE_NAME or DOWN_ARROW_IMAGE_NAME
					temp_text_obj.text.text = math.abs(diff_value)

					temp_text_obj.gameObject:SetActive(diff_value ~= 0)
					if diff_value ~= 0 then
						local asset, name = ResPath.GetStarImages(res_str)
						local temp_image_obj = temp_text_obj:FindObj("DiffIcon"..base_attr_count)
						temp_image_obj.image:LoadSprite(asset, name, function()
							temp_image_obj.image:SetNativeSize()
						end)
					end
				end
			end
			local value = v
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			if k == "huixinyiji" or k == "huixinyiji_hurt" then
				local use_eternity_level = EquipData.Instance:GetMinEternityLevel()
				local hxyj, hxyj_hurt = ForgeData.Instance:GetEternitySuitHXYJPerByLevel(use_eternity_level)
				if k == "huixinyiji" then
					value = hxyj
				else
					value = hxyj_hurt
				end
				value = value / 100 .. "%"
			end
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[k]..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
			base_attr_count = base_attr_count + 1
			local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[k])
			image_obj.image:LoadSprite(asset, name, function()
				image_obj.image:SetNativeSize()
			end)
		end
	end

	--基础、强化、神铸、传奇属性
	local base_result, strength_result, cast_result = ForgeData.Instance:GetForgeAddition(self.data)

	local l_data = {}
	self.show_legend_attr:SetValue(false)
	-- 设置推荐随机属性
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
	local add_role_attr = self.is_mine --or self.handle_param_t.role_vo ~= nil

	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(self.data,
		add_role_attr, not add_role_attr, nil)
	self.fight_power:SetValue(capability)
	if self.data.speacal_from and not add_role_attr and self.data.param and self.data.param.xianpin_type_list then
		local valtrue_data = TableCopy(self.data, 3)
		-- local max_num = 3 - self.data.show_star_num
		for i = 1, 2 do
			if nil ~= valtrue_data.param.xianpin_type_list[i] then
				table.remove(valtrue_data.param.xianpin_type_list, i)
			end
		end
		capability = EquipData.Instance:GetEquipLegendFightPowerByData(valtrue_data,
			add_role_attr, not add_role_attr, nil)
		self.fight_power:SetValue((capability + 60000) * math.pow(1.2, self.data.show_star_num))
	end
	if self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_BAG then
		self.show_storge_score:SetValue(true)
		self.storge_score:SetValue(item_cfg.guild_storage_score)
	else
		self.show_storge_score:SetValue(false)
	end

	self:HandelAttrs(l_data, self.legend_attr_list, true)

	self:HandelAttrs(strength_result, self.streng_attr_list)
	self:HandelAttrs(cast_result, self.cast_attr_list, false, true)

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	if self.data.param then
		if self.data.param.strengthen_level
			and self.data.param.strengthen_level > 0 then
			show_strengthen = true
		end
		if self.data.param.star_level
			and self.data.param.star_level > 0 then
			show_upstar = true
		end

		local star_attr = ForgeData.Instance:GetStarAttr(equip_index, self.data.param.star_level or 0)
		self:HandelAttrs(star_attr, self.upstar_attr_list)
	end

	--宝石属性
	if equip_index >= 0 then
		if self.from_view == TipsFormDef.FROM_BAG then
			for k, v in pairs(self.stone_attr_list) do
				v.is_show:SetValue(false)
			end
		else
			local info = {}
			if self.is_mine then
				info = ForgeData.Instance:GetGemInfo()
			else
				if self.is_check_item ~= nil then
					info = CheckData.Instance:GetRoleInfo().stone_param or {}
				else
					info = {}
				end
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
	end
	self.show_strengthen_attr:SetValue(show_strengthen)
	self.show_cast_attr:SetValue(self.show_cast)
	self.show_legend_attr:SetValue(self.show_legend)
	self.show_gemstone_attr:SetValue(show_gemstone)
	self.show_upstar_attr:SetValue(show_upstar)
end

function TipsEquipComparePanel:StoneScendAttrString(attr_name, attr_value)
	return string.format("%s+%s", attr_name, attr_value)
end

-- 设置回收水晶信息
function TipsEquipComparePanel:SetEquipCrystal()
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

	--以前是通过color判断是否分解出红水晶的，现在又出现橙色装备也出现红水晶，所以暂时写死，后人可修改
	if now_cfg.discard_return[0].item_id == 27590 then
		self.show_orange_crystal:SetValue(true)
		self.orange_crystal:SetValue(now_cfg.discard_return[0].num)
	elseif now_cfg.discard_return[0].item_id == 27591 then
		self.show_red_crystal:SetValue(true)
		self.red_crystal:SetValue(now_cfg.discard_return[0].num)
	end
end

-- 设置永恒属性
function TipsEquipComparePanel:SetEternityAttr()
	self.is_show_eternity = false
	if nil == self.data.param.eternity_level or self.data.param.eternity_level <= 0 then
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

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
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

local function showSellViewState(self)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then
		return
	end
	local salestate = CommonFunc.IsShowSellViewState(self.from_view)
end

function TipsEquipComparePanel:OnFlush(param_t)
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

function TipsEquipComparePanel:OnClickHandle(handler_type)
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
	self.parent:Close()
end

--设置显示弹出Tip的相关属性显示
function TipsEquipComparePanel:SetData(data, from_view, param_t, close_call_back, gift_id, is_check_item, is_compare)
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
			self.data.param = CommonStruct.ItemParamData()
			if gift_id and ForgeData.Instance:GetEquipIsNotRandomGift(self.data.item_id, gift_id) then
				self.is_data_param_nil = true
				self.gift_id = gift_id
				self.data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(self.data.item_id, gift_id)
			end
		end
	end
	self.is_check_item = is_check_item
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.is_compare = is_compare
end