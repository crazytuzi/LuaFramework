local CommonFunc = require("game/tips/tips_common_func")
TipsOtherRoleEquipView = TipsOtherRoleEquipView or BaseClass(BaseView)

function TipsOtherRoleEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips","OtherRoleEquipTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self:SetMaskBg(true)
	self.gift_id = nil
	self.is_data_param_nil = false
	self.cell_height = 0
	self.list_spacing = 0
	self.ceshi = 0
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
	self.equip_tips = TipsEquipComparePanel.New(nil, self)
	self.equip_tips:SetInstance(self:FindObj("EquipTip"))
	self.equip_tips.is_mine = true
	self.equip_compare_tips = TipsEquipComparePanel.New(nil, self)
	self.equip_compare_tips:SetInstance(self:FindObj("EquipCompareTip"))
	self:ListenEvent("Close",
	BindTool.Bind(self.OnClickCloseButton, self))
end

function TipsOtherRoleEquipView:CloseCallBack()
	self.equip_tips:CloseCallBack()
	self.equip_compare_tips:CloseCallBack()
end

function TipsOtherRoleEquipView:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view, self.data_cache.param_t, self.data_cache.close_call_back, self.data_cache.gift_id, self.data_cache.is_check_item)
		self.data_cache = nil
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
		--self:Flush()
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
--=========item===================================================================

TipsEquipComparePanel = TipsEquipComparePanel or BaseClass(BaseRender)

local UP_ARROW_IMAGE_NAME = "arrow_20"
local DOWN_ARROW_IMAGE_NAME = "arrow_21"

function TipsEquipComparePanel:__init(instance, parent)
	self.parent = parent
	self.base_attr_list = {}
	self.legend_attr_list = {}
	self.cast_attr_list = {}
	self.streng_attr_list = {}
	self.buttons = {}
	self.stone_attr_list = {}
	--self.star_list = {}
	--self.stone_item = {}
	self.stone_attr_list = {}
	self.upstar_attr_list = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.show_cast = false
	self.show_legend = false
	self.effect_obj = nil
	self.is_load_effect = false
	self.property_list_num = 0
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

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil
	self.parent = nil
	self.stone_attr_list = nil

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	self.buttons = {}

	self.gift_id = nil
	self.is_data_param_nil = false

	-- for k, v in pairs(self.stone_item) do
	-- 	v:DeleteMe()
	-- end
	-- self.stone_item = {}
end

function TipsEquipComparePanel:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.show_cast = false
	self.show_legend = false
	self.is_check_item = nil
	self.property_list_num = 0
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
	self.gift_id = nil
	self.is_data_param_nil = false

	if next(self.button_handle) then
		for k,v in pairs(self.button_handle) do
			v:Dispose()
		end
	end
	self.button_handle = {}
end

function TipsEquipComparePanel:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
	self.property_list_num = 0
end

function TipsEquipComparePanel:ReleaseCallBack()
	self.buttons = {}
	self.button_root = {}
	self.equip_status = {}
	self.equip_description = {}

	--清理变量
	self.property_list_num = 0 
	self.frame = nil
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

	self.grade = nil

	self.show_storge_score = nil
	self.storge_score = nil
	self.recycle_value = nil
	self.show_recycle = nil

	self.name_effect = nil

	self.show_arrow = nil
	self.arrow_icon = nil

	self.cast_shuxing_text = nil
	self.show_cast_shuxing = nil
	self.legend_level = nil
	self.is_legend_text = nil


end

function TipsEquipComparePanel:LoadCallBack()
	-- 功能按钮
	
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	self.equip_status = self:FindVariable("EquipStatus")
	self.equip_description = self:FindVariable("EquipDescription")
	self.is_legend_text = self:FindVariable("IsLegendText")

	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = button:FindObj("Text")
		self.buttons[i] = {btn = button, text = btn_text}
		-- self.star_list[i] = {is_show = self:FindVariable("ShowStar"..i), sprite = self:FindVariable("Star"..i)}
	end

	for i =1 ,GameEnum.STONE_TOTAL_NUM do
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

	--childCount都为6个
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
	end

	self.wear_icon = self:FindVariable("IsShowWearIcon")
	self.show_no_trade = self:FindVariable("ShowNoTrade")

	self.show_strengthen_attr = self:FindVariable("ShowStrengthenAttr")
	self.show_cast_attr = self:FindVariable("ShowCastAttr")
	self.show_legend_attr = self:FindVariable("ShowLegendAttr")
	self.show_gemstone_attr = self:FindVariable("ShowGemstoneAttr")
	self.show_upstar_attr = self:FindVariable("ShowUpStarAttr")

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.equip_prof = self:FindVariable("EquipProf")
	self.quality = self:FindVariable("Quality")
	self.qualityline = self:FindVariable("QualityLine")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")

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
	self.legend_level = self:FindVariable("LegendLevel")

	--根据显示内容改变面板的长短
	self.frame = self:FindObj("Frame")
	self.cell_height = 28																			--28是单条属性的高度				
	self.list_spacing = 1																			--间距
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
				--local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
				-- local asset, name = ResPath.GetBaseAttrIcon(k)
				-- image_obj.image:LoadSprite(asset, name)
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
	-- 		if not cfg then return end
	-- 		self.cast_shuxing_text:SetValue(string.format(Language.Forge.ShuXingAddDesc, cfg.attr_percent))
	-- 	end
	-- end
end

function TipsEquipComparePanel:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local show_strengthen, show_gemstone, show_upstar = false, false, false
	if item_cfg == nil then
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)

	if self.show_no_trade then
		if self.data.is_bind then
			self.show_no_trade:SetValue(self.data.is_bind == 1)
		else
			self.show_no_trade:SetValue(true)
		end
	end

	--self.wear_icon:SetValue(self.is_mine == true)
	----是否显示已绑定
	if self.is_mine == true then
		self.equip_status:SetValue(Language.Equip.HasDress)
		self.wear_icon:SetValue(true)
	else
		if self.data.is_bind == 1 then
			self.wear_icon:SetValue(true)
			self.equip_status:SetValue(Language.Equip.HasBind)
		else
			self.wear_icon:SetValue(false)
		end
	end

	--装备描述
	self.equip_description:SetValue(item_cfg.description)
	
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.equip_name:SetValue(name_str)
	self.equip_type:SetValue(Language.EquipTypeToName[equip_index])
	--self.grade:SetValue(CommonDataManager.GetDaXie(item_cfg.order))
	self.grade:SetValue(item_cfg.order)

	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityLineBgIcon(item_cfg.color)
	self.qualityline:SetAsset(bundle, sprite)
	self.is_legend_text:SetValue(item_cfg.color >= 6)

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
		self.show_arrow:SetValue(vo.capability ~= EquipData.Instance:GetEquipLegendFightPowerByData(self.data))
		local res_str = ((EquipData.Instance:GetEquipLegendFightPowerByData(self.data) - vo.capability) > 0) and UP_ARROW_IMAGE_NAME or DOWN_ARROW_IMAGE_NAME
		local arrow_b, arrow_a = ResPath.GetImages(res_str)
		self.arrow_icon:SetAsset(arrow_b, arrow_a)
	end

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	local base_attr_count = 1

	-- for i = 1, #self.base_attr_list do
	-- 	local obj = self.base_attr_list[i].gameObject
	-- 	obj:SetActive(false)
	-- 	-- if self.is_compare then
	-- 	-- 	--local temp_text_obj = U3DObject(obj.transform:GetChild(1).gameObject)
	-- 	-- 	if temp_text_obj then
	-- 	-- 		temp_text_obj.gameObject:SetActive(false)
	-- 	-- 	end
	-- 	-- end
	-- end

	local temp_base_attr_list = {}
	if self.is_compare then
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local my_data = EquipData.Instance:GetGridData(equip_index)
		local temp_item_cfg = ItemData.Instance:GetItemConfig(my_data.item_id)
		temp_base_attr_list = CommonDataManager.GetAttributteNoUnderline(temp_item_cfg, true)
	end

	for k, v in pairs(base_attr_list) do
		if v > 0 then
			local obj = self.base_attr_list[base_attr_count].gameObject
			--local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
			-- if temp_base_attr_list[k] then
			-- 	local temp_text_obj = U3DObject(obj.transform:GetChild(1).gameObject)
			-- 	if temp_text_obj then
			-- 		local diff_value = v - temp_base_attr_list[k]
			-- 		local res_str = diff_value > 0 and UP_ARROW_IMAGE_NAME or DOWN_ARROW_IMAGE_NAME
			-- 		temp_text_obj.text.text = math.abs(diff_value)

			-- 		temp_text_obj.gameObject:SetActive(diff_value ~= 0)
			-- 		if diff_value ~= 0 then
			-- 			-- local asset, name = ResPath.GetImages(res_str)
			-- 			-- local temp_image_obj = temp_text_obj:FindObj("DiffIcon"..base_attr_count)
			-- 			-- temp_image_obj.image:LoadSprite(asset, name)
			-- 		end
			-- 	end
			-- end
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[k]..": "..v
			base_attr_count = base_attr_count + 1
			self.property_list_num = self.property_list_num + 1
			--local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[k])
			--image_obj.image:LoadSprite(asset, name)
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
	--天赋属性
	if self.data.param and self.data.param.xianpin_type_list then
		for k,v in pairs(self.data.param.xianpin_type_list) do
			if v ~= nil and v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if legend_cfg ~= nil then
					self.show_legend_attr:SetValue(true)
					local vo_level = GameVoManager.Instance:GetMainRoleVo().level
					local xianpin_level = ConfigManager.Instance:GetAutoConfig("equipforge_auto")
					if xianpin_level then
						local xianpin_attr_leve = item_cfg.equip_level + xianpin_level["other"][1].xianpin_attr_level_param
						self.legend_level:SetValue(xianpin_attr_leve)
					end

					--控制天赋的颜色
					color = TEXT_COLOR.ORANGE_3
					self.property_list_num = self.property_list_num + 1
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

	--是否显示仓库积分
	if self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_BAG or self.from_view == TipsFormDef.FROM_BAG_EQUIP then
		self.show_storge_score:SetValue(true)
		--self.storge_score:SetValue(item_cfg.guild_storage_score)
	else
		self.show_storge_score:SetValue(false)
	end
	self.storge_score:SetValue(item_cfg.guild_storage_score)
	
	self:HandelAttrs(l_data, self.legend_attr_list, true)
	self:HandelAttrs(strength_result, self.streng_attr_list)
	self:HandelAttrs(cast_result, self.cast_attr_list, false, true)

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	if self.data.param then
		if self.data.param.strengthen_level > 0 then
			show_strengthen = true
			self.property_list_num = self.property_list_num + 1
		end
		if self.data.param.star_level > 0 then
			show_upstar = true
			self.property_list_num = self.property_list_num + 1
		end

		local star_attr = ForgeData.Instance:GetStarAttr(equip_index, self.data.param.star_level)
		self:HandelAttrs(star_attr, self.upstar_attr_list)
	end

	--宝石属性
	if equip_index >= 0 then
		local stone_num = 0
		local sort_stone_attr = {}
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
							if #stone_attr >= 2 then
								local str = self:StoneScendAttrString(stone_attr[2].attr_name, stone_attr[2].attr_value)
								self.stone_attr_list[i + 1].scend_attr:SetValue(str)
								self.property_list_num = self.property_list_num + 1
							end
							-- self.stone_attr_list[i + 1].attr_name:SetValue(stone_attr[1].attr_name)
							-- self.stone_attr_list[i + 1].attr_value:SetValue(stone_attr[1].attr_value)
							table.insert(sort_stone_attr, stone_attr[1])
						end
					end
				end
			end
		end
		-- if self.is_mine then
		SortTools.SortDesc(sort_stone_attr, "number_value")
		-- else
		-- end
		for k, v in pairs(sort_stone_attr) do
			self.stone_attr_list[k].attr_name:SetValue(v.attr_name)
			self.stone_attr_list[k].attr_value:SetValue(v.attr_value)
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
	self.show_recycle:SetValue(false)
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

function TipsEquipComparePanel:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	showHandlerBtn(self)
	showSellViewState(self)
	self:ChangePanelHeight(self.property_list_num)
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
			self.is_data_param_nil = true
			self.gift_id = gift_id
			self.data.param = CommonStruct.ItemParamData()
			self.data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(self.data.item_id, gift_id)
		end
	end
	self.is_check_item = is_check_item
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.is_compare = is_compare
end

function TipsEquipComparePanel:ChangePanelHeight(item_count)
	--Tips面板长短控制
	local frame_HeightMax = 704
	local frame_HeightMix = 500
	local frame_offset = 264
	self:ChangeHeight(self.frame,item_count,frame_HeightMax,frame_HeightMix,frame_offset)

end	

function TipsEquipComparePanel:ChangeHeight(panel,item_count,HeightMax,HeightMix,offset)
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