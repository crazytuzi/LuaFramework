local CommonFunc = require("game/tips/tips_common_func")

TipsEquipCompareView = TipsEquipCompareView or BaseClass(BaseView)

function TipsEquipCompareView:__init()
	self.ui_config = {"uis/views/tips/equiptips","RoleEquipCompareTip"}
	self.view_layer = UiLayer.Pop

	self.base_attr_list = {}
	self.legend_attr_list = {}
	self.cast_attr_list = {}
	self.streng_attr_list = {}
	self.star_list = {}
	self.stone_item = {}
	self.stone_attr_list = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.show_cast = false
	self.show_legend = false
	self.cp_show_legend = false
	self.cp_base_attr_list = {}
	self.cp_legend_attr_list = {}
	self.is_load_effect = false
	self.is_load_effect_cp = false
	self.play_audio = true
end

function TipsEquipCompareView:__delete()
	self.button_label = {}
	self.base_attr_list = {}
	self.legend_attr_list = {}
	self.cast_attr_list = {}
	self.streng_attr_list = {}
	self.star_list = {}
	self.stone_attr_list = {}
	self.button_handle = {}
	self.buttons = {}
	self.stone_item = {}
	self.show_cast = nil
	self.show_legend = nil
	self.cp_show_legend = nil
	self.cp_base_attr_list = {}
	self.cp_legend_attr_list = {}
	self.is_load_effect = nil
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect_cp = nil
	if self.effect_obj_cp then
		GameObject.Destroy(self.effect_obj_cp)
		self.effect_obj_cp = nil
	end

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	if self.cp_equip_item then
		self.cp_equip_item:DeleteMe()
		self.cp_equip_item = nil
	end
end

function TipsEquipCompareView:LoadCallBack()
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.cp_equip_item = ItemCell.New()
	self.cp_equip_item:SetInstanceParent(self:FindObj("CPEquipItem"))

	self.button_root = self:FindObj("RightBtn")
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = button:FindObj("Text")
		self.buttons[i] = {btn = button, text = btn_text}
		self.stone_item[i] = ItemCell.New()
		self.stone_item[i]:SetInstanceParent(self:FindObj("StoneItem"..i))
		self.stone_attr_list[i] = {scend_attr = self:FindVariable("StoneAttr2"..i), attr_name = self:FindVariable("StoneAttrName"..i),
									attr_value = self:FindVariable("StoneAttrValue"..i), is_show = self:FindVariable("ShowStone"..i)
		}
		self.star_list[i] = {is_show = self:FindVariable("ShowStar"..i), sprite = self:FindVariable("Star"..i)}
	end

	local base_attrs = self:FindObj("BaseAttrs")
	for i = 1, base_attrs.transform.childCount do
		self.base_attr_list[#self.base_attr_list + 1] = base_attrs:FindObj("BaseAttr"..i)
		local strengthen_attrs = self:FindObj("StrengthenAttrs")
		self.streng_attr_list[#self.streng_attr_list + 1] = strengthen_attrs:FindObj("StrengthenAttr"..i)
		local cast_attrs = self:FindObj("CastAttrs")
		self.cast_attr_list[#self.cast_attr_list + 1] = cast_attrs:FindObj("CastAttr"..i)
		local legend_attrs = self:FindObj("LegendAttrs")
		self.legend_attr_list[#self.legend_attr_list + 1] = legend_attrs:FindObj("LegendAttr"..i)

		local cp_base_attrs = self:FindObj("CPBaseAttrs")
		self.cp_base_attr_list[#self.cp_base_attr_list + 1] = cp_base_attrs:FindObj("BaseAttr"..i)
		local cp_legend_attrs = self:FindObj("CPLegendAttrs")
		self.cp_legend_attr_list[#self.cp_legend_attr_list + 1] = cp_legend_attrs:FindObj("LegendAttr"..i)
	end

	self.show_strengthen_attr = self:FindVariable("ShowStrengthenAttr")
	self.show_cast_attr = self:FindVariable("ShowCastAttr")
	self.show_legend_attr = self:FindVariable("ShowLegendAttr")
	self.show_gemstone_attr = self:FindVariable("ShowGemstoneAttr")
	self.show_storge_score = self:FindVariable("ShowStorgeScore")

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.equip_prof = self:FindVariable("EquipProf")
	self.quality = self:FindVariable("Quality")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")
	self.grade = self:FindVariable("Grade")
	self.storge_score = self:FindVariable("StorgeScore")
	self.recycle_value = self:FindVariable("RecycleValue")
	self.show_recycle = self:FindVariable("ShowRecycle")

	self.cp_equip_name = self:FindVariable("CPEquipName")
	self.cp_level = self:FindVariable("CPLevel")
	self.cp_prof = self:FindVariable("CPProf")
	self.cp_fight_power = self:FindVariable("CPFightPower")
	self.cp_storge_score = self:FindVariable("CPStorgeScore")
	self.cp_recycle_value = self:FindVariable("CPRecycleValue")
	self.cp_grade = self:FindVariable("CPGrade")
	self.cp_quality = self:FindVariable("CPQuality")

	self.cp_show_storge_score = self:FindVariable("CPShowStorgeScore")
	self.cp_show_recycle_value = self:FindVariable("CPShowRecyckeValue")
	self.cp_show_legend_attrs = self:FindVariable("CPShowLegendAttr")

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.show_recycle:SetValue(false)

	self.name_effect = self:FindObj("NameEffect")
	self.cp_name_effect = self:FindObj("CPNameEffect")
end

function TipsEquipCompareView:ReleaseCallBack()
	CommonFunc.DeleteMe()

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil

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

	for k, v in pairs(self.cp_base_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.cp_base_attr_list = {}

	for k, v in pairs(self.cp_legend_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.cp_legend_attr_list = {}

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	if self.cp_equip_item then
		self.cp_equip_item:DeleteMe()
		self.cp_equip_item = nil
	end
end

function TipsEquipCompareView:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
end

function TipsEquipCompareView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.show_cast = false
	self.show_legend = false
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function TipsEquipCompareView:HandelAttrs(data, table, is_legend, is_cast)
	for i=1,#table do
		if table[i] and table[i].gameObject then
			table[i].gameObject:SetActive(false)
		end
	end
	local count = 1
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
		if key ~= nil then
			local attr = table[count]
			attr.gameObject:SetActive(true)
			if is_legend then
				attr.text.text = v
			else
				attr.text.text = key..": "..ToColorStr(value, TEXT_COLOR.GREEN)
			end
			count = count + 1
			if is_legend then
				self.show_legend = true
				self.cp_show_legend = true
			elseif is_cast then
				self.show_cast = true
			end
		end
	end
end

function TipsEquipCompareView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local show_strengthen, show_gemstone = false, false
	if item_cfg == nil then
		return
	end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local data = EquipData.Instance:GetGridData(equip_index)
	if not data then print_error("没有穿着相同部位的装备", equip_index) return end

	item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.equip_name:SetValue(name_str)
	self.equip_type:SetValue(Language.EquipTypeToName[equip_index])
	self.grade:SetValue(Language.Common.NumToChs[item_cfg.order])

	local bundle, sprite = nil, nil
	local color = nil
	-- bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	-- self.quality:SetAsset(bundle, sprite)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	local level_zhuan = level_befor.."级【"..level_behind.."转】"

	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.level:SetValue(level_str)
	local prof_str = (vo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) and Language.Common.ProfName[item_cfg.limit_prof]
						or string.format(Language.Mount.ShowRedStr, Language.Common.ProfName[item_cfg.limit_prof])
	self.equip_prof:SetValue(prof_str)

	self.equip_item:SetData(data)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	local had_base_attr = {}

	local base_attr_count = 1
	for k, v in pairs(base_attr_list) do
		if v > 0 then
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[k]..": "..ToColorStr(v, TEXT_COLOR.BLUE_1)
			base_attr_count = base_attr_count + 1
		end
	end
	for i = base_attr_count, #self.base_attr_list do
		self.base_attr_list[i].gameObject:SetActive(false)
	end

	--基础、强化、神铸、传奇属性
	local base_result, strength_result, cast_result = ForgeData.Instance:GetForgeAddition(data)

	local l_data = {}
	self.show_legend_attr:SetValue(false)
	if data.param and data.param.xianpin_type_list then
		for k,v in pairs(data.param.xianpin_type_list) do
			if v ~= nil and v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if legend_cfg ~= nil then
					self.show_legend_attr:SetValue(true)
					color = TEXT_COLOR.BLUE
					if legend_cfg.color == 1 then
						color = TEXT_COLOR.PURPLE
					end
					local t = ToColorStr(legend_cfg.desc, color)
					table.insert(l_data, t)
				end
			end
		end
	end
	-- self:HandelAttrs(base_result, self.base_attr_list)

	-- local cap = ForgeData.Instance:GetGemPowerByIndex(equip_index)
	-- local attr, capability = ForgeData.Instance:GetEquipAttrAndPower(data)
	self.recycle_value:SetValue(item_cfg.recyclget)

	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(data, true)
	self.fight_power:SetValue(capability)

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

	--设置神铸等级对应的特效
	if data.param.shen_level > 0 and not self.is_load_effect and not self.effect_obj then
		local effect_index = ForgeData.Instance:GetNameEffectByData(data)
		local bundle, asset = ResPath.GetUITipsEffect(effect_index)
		self.is_load_effect =  true

		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
			if prefab then
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform:SetParent(self.name_effect.transform, false)
				self.effect_obj = obj.gameObject
				self.is_load_effect = false
			end
		end)
	end

	local star_bundle, star_asset = nil, nil
	local star_color = 0
	-- 星级属性
	if data.param then
		if data.param.strengthen_level > 0 then
			show_strengthen = true
		end
	-- 	for k, v in pairs(self.star_list) do
	-- 		v.is_show:SetValue(data.param.strengthen_level >= k)
	-- 		if data.param.strengthen_level >= 25 then
	-- 			if data.param.strengthen_level % 5 > 0 then
	-- 				if k <= data.param.strengthen_level % 5 then
	-- 					star_color = math.floor(data.param.strengthen_level / 5) + 1 - 5
	-- 					star_bundle, star_asset = ResPath.GetStrengthenMoonIcon(star_color)
	-- 					v.sprite:SetAsset(star_bundle, star_asset)
	-- 				else
	-- 					star_color = math.floor(data.param.strengthen_level / 5) - 5
	-- 					star_bundle, star_asset = ResPath.GetStrengthenMoonIcon(star_color)
	-- 					v.sprite:SetAsset(star_bundle, star_asset)
	-- 				end
	-- 			else
	-- 				star_color = math.floor(data.param.strengthen_level / 5) - 5
	-- 				star_bundle, star_asset = ResPath.GetStrengthenMoonIcon(star_color)
	-- 				v.sprite:SetAsset(star_bundle, star_asset)
	-- 			end
	-- 		else
	-- 			if data.param.strengthen_level >= k then
	-- 				if data.param.strengthen_level % 5 > 0 then
	-- 					if k <= data.param.strengthen_level % 5 then
	-- 						star_color = math.floor(data.param.strengthen_level / 5) + 1
	-- 						star_bundle, star_asset = ResPath.GetStarsIcon(star_color)
	-- 						v.sprite:SetAsset(star_bundle, star_asset)
	-- 					else
	-- 						star_color = math.floor(data.param.strengthen_level / 5)
	-- 						star_bundle, star_asset = ResPath.GetStarsIcon(star_color)
	-- 						v.sprite:SetAsset(star_bundle, star_asset)
	-- 					end
	-- 				else
	-- 					star_color = math.floor(data.param.strengthen_level / 5)
	-- 					star_bundle, star_asset = ResPath.GetStarsIcon(star_color)
	-- 					v.sprite:SetAsset(star_bundle, star_asset)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	end

	-- 宝石属性
	if equip_index >= 0 then
		for k, v in pairs(self.stone_attr_list) do
			v.is_show:SetValue(false)
		end
		for k, v in pairs(ForgeData.Instance:GetGemInfo()) do
			if k == equip_index then
				for i, j in pairs(v) do
					self.stone_attr_list[i + 1].is_show:SetValue(j.stone_id > 0)
					if j.stone_id > 0 then
						show_gemstone = true
						local stone_cfg = ForgeData.Instance:GetGemCfg(j.stone_id)
						local item_data = {}
						item_data.item_id = j.stone_id
						item_data.is_bind = 0
						self.stone_item[i + 1]:SetData(item_data)
						local stone_attr = ForgeData.Instance:GetGemAttr(j.stone_id)
						if #stone_attr >= 2 then
							local str = self:StoneScendAttrString(stone_attr[2].attr_name, stone_attr[2].attr_value)
							self.stone_attr_list[i + 1].scend_attr:SetValue(str)
						end
						self.stone_attr_list[i + 1].attr_name:SetValue(stone_attr[1].attr_name)
						self.stone_attr_list[i + 1].attr_value:SetValue(stone_attr[1].attr_value)
					end
				end
			end
		end

	end
	self.show_strengthen_attr:SetValue(show_strengthen)
	self.show_cast_attr:SetValue(self.show_cast)
	self.show_legend_attr:SetValue(self.show_legend)
	self.show_gemstone_attr:SetValue(show_gemstone)
end

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

function TipsEquipCompareView:SetCompareEquipData()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.cp_equip_name:SetValue(name_str)

	self.cp_grade:SetValue(Language.Common.NumToChs[item_cfg.order] or "")

	-- local bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	local color = nil
	-- self.cp_quality:SetAsset(bundle, sprite)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	local level_zhuan = level_befor.."级【"..level_behind.."转】"
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.cp_level:SetValue(level_str)
	local prof_str = (vo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) and Language.Common.ProfName[item_cfg.limit_prof]
						or string.format(Language.Mount.ShowRedStr, Language.Common.ProfName[item_cfg.limit_prof])
	self.cp_prof:SetValue(prof_str)
	self.cp_equip_item:SetData(self.data)

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg, true)
	self:HandelAttrs(base_attr_list, self.cp_base_attr_list)

	local l_data = {}
	if self.data.param and self.data.param.xianpin_type_list then
		for k,v in pairs(self.data.param.xianpin_type_list) do
			if v ~= nil and v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if legend_cfg ~= nil then
					self.cp_show_legend_attrs:SetValue(true)
					color = TEXT_COLOR.BLUE
					if legend_cfg.color == 1 then
						color = TEXT_COLOR.PURPLE
					end
					local t = ToColorStr(legend_cfg.desc, color)
					table.insert(l_data, t)
				end
			end
		end
	end
	self:HandelAttrs(l_data, self.cp_legend_attr_list, true)

	self.cp_recycle_value:SetValue(item_cfg.recyclget)

	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(self.data, false, true)
	self.cp_fight_power:SetValue(capability)

	if self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE or self.from_view == TipsFormDef.FROM_BAG then
		self.cp_show_storge_score:SetValue(true)
		self.cp_storge_score:SetValue(item_cfg.guild_storage_score)
	else
		self.cp_show_storge_score:SetValue(false)
	end

	self.cp_show_legend_attrs:SetValue(self.cp_show_legend)

	if self.effect_obj_cp then
		GameObject.Destroy(self.effect_obj_cp)
		self.effect_obj_cp = nil
	end

	--添加神铸等级名字特效
	if self.data.param.shen_level > 0 and not self.is_load_effect_cp and not self.effect_obj_cp then
		local effect_index = ForgeData.Instance:GetNameEffectByData(self.data)
		local bundle, asset = ResPath.GetUITipsEffect(effect_index)
		self.is_load_effect_cp =  true
		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
			if prefab then
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform:SetParent(self.name_effect.transform, false)
				self.effect_obj_cp = obj.gameObject
				self.is_load_effect_cp = false
			end
		end)
	end

end

function TipsEquipCompareView:StoneScendAttrString(attr_name, attr_value)
	return string.format("%s+%s", attr_name, attr_value)
end

function TipsEquipCompareView:OnClickHandle(handler_type)
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

function TipsEquipCompareView:OnClickCloseButton()
	self:Close()
end

--设置显示弹出Tip的相关属性显示
function TipsEquipCompareView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	self.close_call_back = close_call_back
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsEquipCompareView:OnFlush()
	self:ShowTipContent()
	self:SetCompareEquipData()
	showHandlerBtn(self)
end