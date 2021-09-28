local CommonFunc = require("game/tips/tips_common_func")
TipsOtherEquipView = TipsOtherEquipView or BaseClass(BaseView)

function TipsOtherEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab","OtherEquipTip"}
	self.view_layer = UiLayer.Pop

	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.legent_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.play_audio = true
end

function TipsOtherEquipView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = self.button_root:FindObj("Btn"..i.."/Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end
	self.show_special = self:FindVariable("show_special")
	self.is_show_the_random = self:FindVariable("ShowTheRandom")

	for i = 1, 3 do
		self.base_attr_list[i] = {attr_name = self:FindVariable("BaseAttrName"..i), attr_value = self:FindVariable("BaseAttrValue"..i),
									is_show = self:FindVariable("ShowBaseAttr"..i), attr_icon = self:FindVariable("Icon_base"..i)
		}
		self.special_attr_list[i] = {attr_name = self:FindVariable("SpecialAttrName"..i), attr_value = self:FindVariable("SpecialAttrValue"..i),
									is_show = self:FindVariable("ShowSpecialAttr"..i), attr_icon = self:FindVariable("Icon_base"..i)
		}
		self.random_attr_list[i] = {attr_name = self:FindVariable("RandomName"..i), attr_value = self:FindVariable("RandomValue"..i),
									is_show = self:FindVariable("ShowRandomAttr"..i), attr_icon = self:FindVariable("Icon_Randow"..i)
		}
		self.legent_attr_list[i] = {attr_name = self:FindVariable("LegentName"..i), attr_value = self:FindVariable("LegentValue"..i),
									is_show = self:FindVariable("ShowLegentAttr"..i), attr_icon = self:FindVariable("Icon_Legent"..i)
		}
	end

	self.show_no_trade = self:FindVariable("ShowNoTrade")

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")
	self.quality = self:FindVariable("Quality")
	self.qualityline = self:FindVariable("QualityLine")
	self.decompose_text = self:FindVariable("DecomposeText")
	self.show_random = self:FindVariable("ShowRandom")
	self.show_decompose = self:FindVariable("ShowDecompose")
	self.show_wear_icon = self:FindVariable("ShowWearIcon")
	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.storge_score = self:FindVariable("StorgeScore")
	self.equip_prof = self:FindVariable("EquipProf")
	self.show_legent = self:FindVariable("Show_Legent")
	self.recyle_text = self:FindVariable("RecyleText")
	self.show_recyle_text = self:FindVariable("ShowRecyleText")
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

end

function TipsOtherEquipView:ReleaseCallBack()
	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
	self.show_special = nil
	self.is_show_the_random = nil
	self.show_no_trade = nil
	self.equip_name = nil
	self.equip_type = nil
	self.level = nil
	self.fight_power = nil
	self.quality = nil
	self.qualityline = nil
	self.decompose_text = nil
	self.show_random = nil
	self.show_decompose = nil
	self.show_wear_icon = nil
	self.show_storge_score = nil
	self.storge_score = nil
	self.equip_prof = nil
	self.show_legent = nil
	self.scroller_rect = nil
	self.button_root = nil
	self.recyle_text = nil
	self.show_recyle_text = nil

	self.buttons = {}
	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.legent_attr_list = {}
end

function TipsOtherEquipView:__delete()
	CommonFunc.DeleteMe()
	self.button_label = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.button_handle = nil
	self.buttons = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function TipsOtherEquipView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local equip_index = (item_cfg.sub_type) % 100
	if EquipData.IsMarryEqType(item_cfg.sub_type) then
		equip_index = MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type)
	end
	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	self.quality:SetAsset(bundle, sprite)
	bundle, sprite = ResPath.GetQualityLineBgIcon(item_cfg.color)
	self.qualityline:SetAsset(bundle, sprite)

	-- if self.data.is_bind then
	-- 	self.show_no_trade:SetValue(self.data.is_bind == 1)
	-- else
	-- 	self.show_no_trade:SetValue(true)
	-- end
	self.show_random:SetValue(true)
	self.show_special:SetValue(true)

	local item_name = ToColorStr(item_cfg.name, ITEM_TIP_NAME_COLOR[item_cfg.color])
	self.equip_name:SetValue(item_name)
	local power = 0
	local equip_type = ""
	local show_decompose = false
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
	level_str = string.format(Language.Tip.DengJi, level_str)

	if EquipData.IsZhuanshnegEquipType(item_cfg.sub_type) then
		local zhuanshen_level = ZhuanShengData.Instance:GetZhuanShengInfo().zhuansheng_level or 0
		power = ZhuanShengData.Instance:GetZhuangShengEquipFightPower(self.data)
		equip_type = Language.Common.ZhuanShengEquip
		-- local order_str = "天神"..(item_cfg.order).."阶"
		-- level_str = zhuanshen_level >= item_cfg.order and order_str or string.format(Language.Mount.ShowRedStr, order_str)
		self.show_special:SetValue(false)
		self.decompose_text:SetValue(item_cfg.recyclget)
		show_decompose = true

	elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
		power = CommonDataManager.GetCapability(item_cfg)
		equip_type = Language.Common.MarryEquip
		self.show_special:SetValue(false)
		self.decompose_text:SetValue(item_cfg.recyclget)
		show_decompose = true
		self.recyle_text:SetValue(Language.Marriage.MarryEquipRecyle .. item_cfg.recyclget)
		level_str = item_cfg.limit_level
		if item_cfg.limit_level > MarryEquipData.Instance:GetMarryInfo().marry_level then
			level_str = string.format(Language.Mount.ShowRedStr, level_str)
		end
		level_str = string.format(Language.Tip.MarryDengJi, level_str)
	elseif EquipData.IsLittlePetToyType(item_cfg.sub_type) then
		power = CommonDataManager.GetCapability(item_cfg)
		equip_type = Language.Common.PetEquip
		self.show_special:SetValue(false)
		show_decompose = false
	elseif GameEnum.EQUIP_TYPE_HUNJIE == item_cfg.sub_type then
		equip_type = Language.EquipTypeToName[GameEnum.EQUIP_TYPE_HUNJIE]
		power = CommonDataManager.GetCapability(item_cfg)
	end
	self.show_recyle_text:SetValue(EquipData.IsMarryEqType(item_cfg.sub_type))
	self.show_decompose:SetValue(show_decompose)
	self.equip_type:SetValue(equip_type)
	self.fight_power:SetValue(power)

	self.level:SetValue(level_str)

	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	local had_base_attr = {}

	for k, v in pairs(base_attr_list) do
		if v > 0 then
			table.insert(had_base_attr, {key = k, value = v})
		end
	end

	local show_random = false
	-- 基础
	if #had_base_attr > 0 then
		for k, v in pairs(self.base_attr_list) do
			v.is_show:SetValue(had_base_attr[k] ~= nil)
			if had_base_attr[k] ~= nil then
				v.attr_name:SetValue(Language.Common.AttrNameNoUnderline[had_base_attr[k].key])
				v.attr_value:SetValue(had_base_attr[k].value)
				local bundle,asset = ResPath.GetBaseAttrIcon(had_base_attr[k].key)
				v.attr_icon:SetAsset(bundle, asset)
			end

			if self.data.param then
				if equip_index == 0 and item_cfg.sub_type ~= 900 and not EquipData.IsMarryEqType(item_cfg.sub_type) then
					if had_base_attr[k] then
						self.random_attr_list[k].attr_name:SetValue(Language.Common.AttrNameNoUnderline[had_base_attr[k].key])
						self.random_attr_list[k].attr_value:SetValue(self.data.param["param"..k])
						self.random_attr_list[k].is_show:SetValue(true)
						self.special_attr_list[k].is_show:SetValue(false)
						local bundle,asset = ResPath.GetBaseAttrIcon(had_base_attr[k].key)
						self.random_attr_list[k].attr_icon:SetAsset(bundle, asset)
					end
				elseif item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX then
					--转生装备
					for i=1,3 do
						if nil ~= self.data.param["rand_attr_val_"..i] and self.data.param["rand_attr_val_"..i] > 0 then
							self.random_attr_list[i].is_show:SetValue(true)
							self.random_attr_list[i].attr_name:SetValue(Language.Common.ZhuanShengRandAttr[self.data.param["rand_attr_type_"..i]])
							self.random_attr_list[i].attr_value:SetValue(self.data.param["rand_attr_val_"..i])
							show_random = true
							local bundle,asset = ResPath.GetBaseAttrIcon(self.data.param["rand_attr_type_"..i])
							self.random_attr_list[i].attr_icon:SetAsset(bundle, asset)
						else
							self.random_attr_list[i].is_show:SetValue(false)
						end
					end
				else
					if nil == self.data.param.param1 or self.data.param.param1 == 0 then
						self.show_random:SetValue(false)
					else
						self.random_attr_list[1].attr_name:SetValue(Language.Common.AttrNameNoUnderline[had_base_attr[1].key])
						self.random_attr_list[1].attr_value:SetValue(self.data.param.param1 or 0)
						self.random_attr_list[1].is_show:SetValue(true)
						self.random_attr_list[2].is_show:SetValue(false)
						self.random_attr_list[3].is_show:SetValue(false)
						local bundle,asset = ResPath.GetBaseAttrIcon(self.data.param["rand_attr_type_1"])
						self.random_attr_list[1].attr_icon:SetAsset(bundle, asset)
					end

					if nil == self.data.param.param1 or self.data.param.param2 == 0 then
						self.show_special:SetValue(false)
					else
						local bundle, asset = nil, nil
						if equip_index == 1 then
							bundle,asset = ResPath.GetBaseAttrIcon(per_pofang)
							self.special_attr_list[1].attr_name:SetValue(Language.Common.AttrName.per_pofang)
						else
							bundle,asset = ResPath.GetBaseAttrIcon(per_mianshang)
							self.special_attr_list[1].attr_name:SetValue(Language.Common.AttrName.per_mianshang)
						end
						self.special_attr_list[1].attr_value:SetValue(self.data.param.param2)
						self.special_attr_list[1].is_show:SetValue(true)
						self.special_attr_list[2].is_show:SetValue(false)
						self.special_attr_list[3].is_show:SetValue(false)
						self.special_attr_list[1].attr_icon:SetAsset(bundle, asset)
					end
				end
			else
				self.show_random:SetValue(false)
				self.show_special:SetValue(false)
			end

			--随机传奇属性
			if self.is_tian_sheng and self.is_tian_sheng == true then
				self.show_legent:SetValue(true)
				local random_type_list = ForgeData.Instance:GetShowZSType(self.data.limit_level, self.data.color, self.data.sub_type)
				local random_list = ForgeData.Instance:GetZSRandomValueList(self.data.limit_level, self.data.color, self.data.sub_type)
				for k,v in pairs(random_list) do
					if v then
						color = TEXT_COLOR.BLUE
						if self.data.color == 1 then
							color = TEXT_COLOR.PURPLE
						end
						self.legent_attr_list[k].attr_name:SetValue(Language.Common.ZhuanShengRandAttr[random_type_list[k]])
						self.legent_attr_list[k].is_show:SetValue(true)
						local t = random_list[k].attr_value_min.. "-" .. random_list[k].attr_value_max
						t = ToColorStr(t, color)
						local bundle, asset = nil, nil
						bundle,asset = ResPath.GetBaseAttrIcon(Language.Common.AttrIconKey[random_type_list[k]])
						self.legent_attr_list[k].attr_icon:SetAsset(bundle, asset)

						self.legent_attr_list[k].attr_value:SetValue(t)
					else
						self.legent_attr_list[k].is_show:SetValue(false)
					end
				end
			else
				self.show_legent:SetValue(false)
			end
		end
	end

	self.show_random:SetValue(show_random)
	self.show_wear_icon:SetValue(self.from_view == TipsFormDef.FROM_ZHUANSHENG_VIEW)

	if (self.from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE
			or self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE
			or self.from_view == TipsFormDef.FROM_BAG) and not EquipData.IsMarryEqType(item_cfg.sub_type) and
			not EquipData.IsLittlePetToyType(item_cfg.sub_type) then
		self.show_storge_score:SetValue(true)
		self.storge_score:SetValue(item_cfg.guild_storage_score and item_cfg.guild_storage_score or 0)
	else
		self.show_storge_score:SetValue(false)
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local prof_str = (vo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) and Language.Common.ProfName[item_cfg.limit_prof]
						or string.format(Language.Mount.ShowRedStr, Language.Common.ProfName[item_cfg.limit_prof])
	prof_str = string.format(Language.Tip.ZhuangBeiProf, prof_str)
	if EquipData.IsMarryEqType(item_cfg.sub_type) then
		prof_str = Language.Common.SexName[item_cfg.limit_sex] or ""
		prof_str = vo.sex == item_cfg.limit_sex and prof_str or string.format(Language.Mount.ShowRedStr, prof_str)
		prof_str = string.format(Language.Tip.Sex, prof_str)
	end
	self.equip_prof:SetValue(prof_str)
	-- if self.show_the_random then
	-- 	self.show_random:SetValue(true)
	-- 	self.is_show_the_random:SetValue(true)
	-- else
	-- 	self.show_random:SetValue(false)
	-- end

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

function TipsOtherEquipView:OnClickHandle(handler_type)
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
function TipsOtherEquipView:OnClickCloseButton()
	self:Close()
end

function TipsOtherEquipView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.is_tian_sheng = nil
	if self.close_call_back ~= nil then
		self.close_call_back()
	end

	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
end

function TipsOtherEquipView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	showHandlerBtn(self)
end

--设置显示弹出Tip的相关属性显示
function TipsOtherEquipView:SetData(data,from_view, param_t, close_call_back, show_the_random, is_tian_sheng)
	if not data then
		print("数据等于空")
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end

	self.close_call_back = close_call_back
	self.is_tian_sheng = is_tian_sheng
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.show_the_random = show_the_random
	self:Flush()
end