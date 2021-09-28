local CommonFunc = require("game/tips/tips_common_func")
TipsSpiritEquipView = TipsSpiritEquipView or BaseClass(BaseView)

function TipsSpiritEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab","SpiritEquipTip"}
	self.view_layer = UiLayer.Pop
	self.close_call_back = nil
	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.fix_show_time = 8
	self.play_audio = true
	self.total_attr_list = CommonStruct.AttributeNoUnderline()
end

function TipsSpiritEquipView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = self.button_root:FindObj("Btn"..i.."/Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end

	for i = 1, 4 do
		self.base_attr_list[i] = {attr_name = self:FindVariable("BaseAttrName"..i), attr_value = self:FindVariable("BaseAttrValue"..i),
									is_show = self:FindVariable("ShowBaseAttr"..i), attr_icon = self:FindVariable("Icon_base"..i)
		}
	end

	for i = 1, 7 do
		self.special_attr_list[i] = {attr_name = self:FindVariable("SpecialAttrName"..i), attr_value = self:FindVariable("SpecialAttrValue"..i),
									is_show = self:FindVariable("ShowSpecialAttr"..i), attr_icon = self:FindVariable("Icon_Special"..i)
		}
	end

	self.show_no_trade = self:FindVariable("ShowNoTrade")

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.quality = self:FindVariable("Quality")
	self.qualityline = self:FindVariable("QualityLine")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")
	self.sale_price = self:FindVariable("SalePrice")
	self.sale_price2 = self:FindVariable("SalePrice2")
	self.extra_attr_name=self:FindVariable("ExtraAttrName")
	self.extra_attr_value=self:FindVariable("ExtraAttrValue")
	self.show_extra_attr=self:FindVariable("ShowExtraAttr")
	self.add_attr_values = {}
	for i=1,3 do
		self.add_attr_values[i] = self:FindVariable("AddAttr" .. i)
	end


	self.show_special_attrs = self:FindVariable("ShowSpecialAttrs")

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("spirit_equip_frame")
	self.model:SetDisplay(self.display.ui3d_display)
	self.tab_images = self:FindVariable("tab_images")
end

function TipsSpiritEquipView:__delete()
	CommonFunc.DeleteMe()
	self.button_label = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.buttons = nil
	self.fix_show_time = nil
	self.button_handle = nil
	
end

function TipsSpiritEquipView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	-- 清理变量
	self.button_root = nil
	self.display = nil
	self.scroller_rect = nil
	self.show_special_attrs = nil
	self.sale_price = nil
	self.sale_price2 = nil
	self.fight_power = nil
	self.level = nil
	self.qualityline = nil
	self.quality = nil
	self.equip_type = nil
	self.equip_name = nil
	self.show_no_trade = nil
	self.show_extra_attr = nil
	self.extra_attr_value = nil
	self.extra_attr_name = nil
	self.add_attr_values = nil
	self.tab_images = nil
end

function TipsSpiritEquipView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	self.time_quest = nil
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end

	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
end

function TipsSpiritEquipView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	local spirit_level = nil ~= self.data.param and self.data.param.strengthen_level or 0
	local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.data.item_id, spirit_level)
	local aptitude_data = SpiritData.Instance:GetSpiritTalentAttrCfgById(self.data.item_id)
	if self.data.param then
		local wuxing = self.data.param.param1 or 0
		local total_attr_list = SpiritData.Instance:GetSpiritLevelAptitude(self.data.item_id, self.data.param.strengthen_level,aptitude_data,wuxing)
		self.total_attr_list = CommonDataManager.GetAttributteNoUnderline(total_attr_list, true)
		self.show_extra_attr:SetValue(true)
		self.extra_attr_name:SetValue(Language.JingLing.WuXing)
		self.extra_attr_value:SetValue(wuxing)
		local recycl_wuxing_value = SpiritData.Instance:GetRecyclWuxingValue(wuxing)
		self.sale_price2:SetValue(recycl_wuxing_value)
	else
		self.sale_price2:SetValue("")
		local total_attr_list = SpiritData.Instance:GetSpiritLevelAptitude(self.data.item_id, 1,aptitude_data,0)
		self.total_attr_list = CommonDataManager.GetAttributteNoUnderline(total_attr_list, true)
	end
	if item_cfg == nil or spirit_cfg == nil then
		return
	end

	self:SetRoleModel(item_cfg.is_display_role)

	if self.show_no_trade then
		if self.data.is_bind then
			self.show_no_trade:SetValue(self.data.is_bind == 1)
		else
			self.show_no_trade:SetValue(true)
		end
	end
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.equip_name:SetValue(name_str)
	local bundle, asset = ResPath.GetTipsImageByIndex(item_cfg.color)
	self.tab_images:SetAsset(bundle, asset)
	self.equip_type:SetValue(Language.JingLing.JingLing)

	local recycl_value = SpiritData:GetSpiritAllLingjingByLevel(self.data.item_id, self.data.param and self.data.param.strengthen_level or 1)
	self.sale_price:SetValue(recycl_value + item_cfg.recyclget)
	local bundle, sprite = nil, nil
	if self.data.param then
	bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	bundle1, sprite1 = ResPath.GetQualityLineBgIcon(item_cfg.color)
	end
	self.quality:SetAsset(bundle, sprite)
	self.qualityline:SetAsset(bundle1, sprite1)

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

	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(spirit_cfg, true)
	local had_base_attr = {}

	local show_special_attr = false
	for k, v in pairs(base_attr_list) do
		if v > 0 then
			table.insert(had_base_attr, {key = k, value = v})
		end
	end
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

			if self.data.param and self.data.param.xianpin_type_list then
				if next(self.data.param.xianpin_type_list) == nil then
					for _, v2 in pairs(self.special_attr_list) do
						v2.is_show:SetValue(false)
					end
				end
				for k2, v2 in pairs(self.data.param.xianpin_type_list) do
					local cfg = SpiritData.Instance:GetSpiritTalentAttrCfgById(self.data.item_id)
					if self.special_attr_list[k2] then
						if cfg["type"..v2] then
							self.special_attr_list[k2].attr_name:SetValue(JINGLING_TALENT_ATTR_NAME[JINGLING_TALENT_TYPE[v2]])
							self.special_attr_list[k2].attr_value:SetValue(cfg["type"..v2] / 100)
							self.special_attr_list[k2].is_show:SetValue(true)
							local bundle,asset = ResPath.GetBaseAttrIcon(JINGLING_TALENT_TYPE[v2])
							self.special_attr_list[k2].attr_icon:SetAsset(bundle, asset)
							show_special_attr = true
						else
							print_error("No Spirit Talent Type :", "type"..v2)
						end
					end
					for i = (#self.data.param.xianpin_type_list + 1), #self.special_attr_list do
						self.special_attr_list[i].is_show:SetValue(false)
					end
				end
			else
				for _, v2 in pairs(self.special_attr_list) do
					v2.is_show:SetValue(false)
				end
			end
		end
	end


	local add_attr_value = SpiritData.Instance:GetAddAttrValue(self.total_attr_list,base_attr_list)
	for i=1,3 do
		if add_attr_value[i] ~= 0 and nil ~= self.data.param then
			self.add_attr_values[i]:SetValue("<color=" .. TEXT_COLOR.BLUE .. ">(+" .. add_attr_value[i] .. ")</color>")
		else
			self.add_attr_values[i]:SetValue("")
		end
	end
	self.fight_power:SetValue(CommonDataManager.GetCapability(self.total_attr_list))
	self.show_special_attrs:SetValue(show_special_attr)
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
		-- 按钮文字显示将出战改为使用
		local cur_type = handler_type == 30 and 2 or handler_type 
		local tx = self.button_label[cur_type]
		if tx ~= nil and handler_type ~= 23 then			--仙宠屏蔽回收按钮
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

function TipsSpiritEquipView:SetRoleModel(display_role)
	local bundle, asset = nil, nil
	local res_id = 0
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	--elseif display_role == DISPLAY_TYPE.XIAN_NV then
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetWingModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	--elseif display_role == DISPLAY_TYPE.FASHION then
	--elseif display_role == DISPLAY_TYPE.HALO then
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == self.data.item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	--elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
	--elseif display_role == DISPLAY_TYPE.SHENGONG then
	--elseif display_role == DISPLAY_TYPE.SHENYI then
	end

	if bundle and asset and self.model then
		self.model:SetMainAsset(bundle, asset)
	end
end

function TipsSpiritEquipView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	-- if TipsHandleDef.HANDLE_RECOVER_SPIRIT == handler_type then
	-- 	local  func = function ()
	-- 		CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t)
	-- 		ViewManager.Instance:Close(ViewName.TipsSpiritEquipView)
	-- 	end
	-- 	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.JingLing.OneKeyRecyle, nil, nil, false, false, nil, false, Language.JingLing.AutoRecyclePurple)
	-- 	return
	-- end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
	 	return
	end
	self:Close()
end

function TipsSpiritEquipView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.model then
					self.model:SetTrigger("rest")
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

--关闭装备Tip
function TipsSpiritEquipView:OnClickCloseButton()
	self:Close()
end

function TipsSpiritEquipView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	showHandlerBtn(self)
	self:SetModleRestAni()
	if self.display ~= nil then
		self.display.ui3d_display:ResetRotation()
	end
end

--设置显示弹出Tip的相关属性显示
function TipsSpiritEquipView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.close_call_back = close_call_back
	self:Flush()
end