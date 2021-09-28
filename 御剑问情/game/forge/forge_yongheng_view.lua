ForgeYongHengView = ForgeYongHengView or BaseClass(BaseRender)

local Defult_Icon_List = {
	[1] = "icon_toukui",
	[2] = "icon_yifu",
	[3] = "icon_kuzi",
	[4] = "icon_xiezi",
	[5] = "icon_hushou",
	[6] = "icon_xianglian",
	[7] = "icon_wuqi",
	[8] = "icon_jiezhi",
	[9] = "icon_yaodai",
	[10] = "icon_jiezhi"
}

function ForgeYongHengView:__init(instance)
	self:ListenEvent("OnClickYongHeng", BindTool.Bind(self.OnClickYongHeng, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
    
	self.toggle_group = self:FindObj("ToggleGroup").toggle_group
	self.item_list = {}
	self.show_arrow_list = {}
	self.show_text_hight_light_list = {}
	self.equip_color_list = {}
	local item = nil
	for i = 1, 10 do
		item = EquipItemCell.New(self:FindObj("EquipItem"..i))
		item:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, item, i - 1))
		item:ShowStrengthLable(false)
		self.item_list[i] = item

		self.show_arrow_list[i] = self:FindVariable("ShowArrow"..i)
		self.show_text_hight_light_list[i] = self:FindVariable("ShowTextHL"..i)
		self.equip_color_list[i] = self:FindVariable("EquipColor"..i)
	end

	local item1 = ItemCell.New()
	item1:SetInstanceParent(self:FindObj("CostItem"))
	self.cost_item = item1

	local item2 = ItemCell.New()
	item2:SetInstanceParent(self:FindObj("CostItem2"))
	self.cost_item2 = item2

	self.display = self:FindObj("Display")
	self.role_model = RoleModel.New("yongheng_panel")
	self.role_model:SetDisplay(self.display.ui3d_display)

	self.attr_list = {}
	for i = 1, 3 do
		self.attr_list[i] = {
			attr = self:FindVariable("Attr"..i),
			next_attr = self:FindVariable("NextAttr"..i),
			icon = self:FindVariable("Icon"..i),
			show = self:FindVariable("ShowAttr"..i),
		}
	end

	self.cur_suit_var_list = {
		percent = self:FindVariable("CurAddPercent"),
		percent2 = self:FindVariable("CurAddPercent2"),
	}

	self.next_suit_var_list = {
		name = self:FindVariable("NextSuitName"),
		percent = self:FindVariable("NextAddPercent"),
		percent2 = self:FindVariable("NextAddPercent2"),
		active_equip_num = self:FindVariable("NextActiveNum"),
	}

	self.fight_power = self:FindVariable("FightPower")
	self.bag_prop_num = self:FindVariable("BagNum")
	self.bag_prop_num2 = self:FindVariable("BagNum2")
	self.need_prop_num = self:FindVariable("NeedNum")
	self.need_prop_num2 = self:FindVariable("NeedNum2")
	self.single_equip_name = self:FindVariable("EquipTpyeName")
	self.middle_suit_name = self:FindVariable("MiddleSuitName")
	self.yongheng_text = self:FindVariable("YongHengText")
	self.equip_need = self:FindVariable("EquipNeed")
	self.equip_need:SetValue(ETERNITY_ACTIVE_NEED)

	self.show_left_arrow = self:FindVariable("ShowLeftArrow")
	self.show_right_arrow = self:FindVariable("ShowRightArrow")
	self.show_next_suit_des = self:FindVariable("ShowNextSuitDes")
	self.show_next_suit_des2 = self:FindVariable("ShowNextSuitDes2")
	self.show_yongheng_btn = self:FindVariable("ShowYngHengBtn")
	self.total_power = self:FindVariable("TotalPower")

	self.select_item_index = -1
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self.select_suit_index = ForgeData.Instance:GetEternitySuitIndex(game_vo.appearance.use_eternity_level)
	self.temp_use_eternity_level = game_vo.appearance.use_eternity_level
end

function ForgeYongHengView:__delete()
	if nil ~= self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end
	if nil ~= self.cost_item2 then
		self.cost_item2:DeleteMe()
		self.cost_item2 = nil
	end

	for _, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end


function ForgeYongHengView:OnClickYongHeng()
	ForgeCtrl.Instance:SendEquipUpEternityReq(self.select_item_index)
end

function ForgeYongHengView:OnClickHelp()
	local tips_id = 187
  	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeYongHengView:OnClickBuy()
	local content_type = CHAT_CONTENT_TYPE.TEXT
	if not self.cost_item or not self.cost_item.data then
	    return
	end
    
    local time = ForgeData:GetTime()
    if time <= 0 then
    	local cfg = self.cost_item.data
		local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], cfg.item_id)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
		TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)
		ForgeData:SetTime(Status.NowTime)
    else
		if Status.NowTime - time >= 30 then 
			local cfg = self.cost_item.data
			local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], cfg.item_id)
			ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
			TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)
			ForgeData:SetTime(Status.NowTime)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Cold)
	    end
	end
    
end


function ForgeYongHengView:OnClickEquipItem(cell, equip_index)
	if self.select_item_index == equip_index then
		if cell.data and cell.data.item_id > 0 then
			TipsCtrl.Instance:OpenItem(cell.data, TipsFormDef.FROM_BAG_EQUIP)
		end
		return
	end

	self.select_item_index = equip_index
	self:SetRightInfo()
end

function ForgeYongHengView:SetRightInfo()
	local cfg = ForgeData.Instance:GetEternityEquipCfg(self.select_item_index)
	local next_cfg = ForgeData.Instance:GetEternityEquipCfg(self.select_item_index, true)
	local equip_data = EquipData.Instance:GetGridData(self.select_item_index)
	if nil == cfg then
		return
	end
	local attr_list = CommonDataManager.GetAttributteNoUnderline(cfg)
	self:SetAttr(attr_list, equip_data.param.eternity_level)

	self:SetCostInfo(cfg)
	self:SetSuitValue()

	self.fight_power:SetValue(CommonDataManager.GetCapability(attr_list))

	self.show_yongheng_btn:SetValue(true)
	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	local des_text = ""
	if nil ~= item_cfg then
		local equip_name = "<color="..ITEM_COLOR[item_cfg.color]..">"..string.format(Language.Forge.EternityDes, item_cfg.name, cfg.name).."</color>"
		self.single_equip_name:SetValue(equip_name)

		if nil ~= next_cfg and item_cfg.order < next_cfg.show_level then
			self.show_yongheng_btn:SetValue(false)
			des_text = string.format(Language.Forge.NeedEquipGradeTip, CommonDataManager.GetDaXie(next_cfg.show_level))
		elseif nil == next_cfg then
			self.show_yongheng_btn:SetValue(false)
			des_text = Language.Common.MaxLvTips
		end
		self.yongheng_text:SetValue(des_text)
	end
end

function ForgeYongHengView:SetAttr(attr_list, eternity_level)
	local attr_count = 1
	local value_str = ""
	local next_cfg = ForgeData.Instance:GetEternityEquipCfg(self.select_item_index, true)
	local next_attr_list = CommonDataManager.GetAttributteNoUnderline(next_cfg)

	local temp = CommonDataManager.SortAttribute(attr_list)
	local next_temp = CommonDataManager.SortAttribute(next_attr_list)
	if eternity_level > 0 then
		for k, v in ipairs(temp) do
			if v.value > 0 and nil ~= self.attr_list[attr_count] then
				value_str = Language.Common.AttrNameNoUnderline[v.key]..":"..string.format(Language.Common.ToColor, TEXT_COLOR.BLACK_1, v.value)
				self.attr_list[attr_count].attr:SetValue(value_str)
				self.attr_list[attr_count].icon:SetAsset(ResPath.GetBaseAttrIcon(v.key))
				self.attr_list[attr_count].next_attr:SetValue(CommonDataManager.SearchAttributeValue(next_temp, v.key) - v.value)
				self.attr_list[attr_count].show:SetValue(true)
				attr_count = attr_count + 1
			end
		end
	else
		for k, v in ipairs(next_temp) do
			if v.value > 0 and nil ~= self.attr_list[attr_count] then
				value_str = Language.Common.AttrNameNoUnderline[v.key]..":"..string.format(Language.Common.ToColor, TEXT_COLOR.BLACK_1, 0)
				self.attr_list[attr_count].attr:SetValue(value_str)
				self.attr_list[attr_count].icon:SetAsset(ResPath.GetBaseAttrIcon(v.key))
				self.attr_list[attr_count].next_attr:SetValue(v.value)
				self.attr_list[attr_count].show:SetValue(true)

				attr_count = attr_count + 1
			end
		end
	end

	for i = attr_count, #self.attr_list do
		self.attr_list[i].show:SetValue(false)
	end
end

function ForgeYongHengView:SetArrowState()
	local use_eternity_level = EquipData.Instance:GetUseEternityLevel()
	local min_eternity_level = EquipData.Instance:GetMinEternityLevel()
	local temp_suit_level = ForgeData.Instance:GetSuitLevelByIndex(self.select_suit_index)
	local now_suit_cfg, next_suit_cfg = ForgeData.Instance:GetEternitySuitCfg(temp_suit_level)
	local min_suit_index = ForgeData.Instance:GetEternitySuitIndex(min_eternity_level)
	local use_suit_index = ForgeData.Instance:GetEternitySuitIndex(use_eternity_level)

	self.show_left_arrow:SetValue(nil ~= now_suit_cfg and self.select_suit_index > 1) --self.select_suit_index > game_vo.appearance.use_eternity_level
	self.show_right_arrow:SetValue(nil ~= next_suit_cfg and min_eternity_level > 0 and self.select_suit_index <= min_suit_index)
end

function ForgeYongHengView:SetSuitValue()
	local min_eternity_level = EquipData.Instance:GetMinEternityLevel()
	local now_suit_cfg, next_suit_cfg = ForgeData.Instance:GetEternitySuitCfg(min_eternity_level)-- game_vo.appearance.use_eternity_level
	local cur_active_num, next_active_num = ForgeData.Instance:GetEternityActiveNum()

	self.show_next_suit_des:SetValue(nil ~= next_suit_cfg)
	self.show_next_suit_des2:SetValue(nil ~= next_suit_cfg)

	if nil ~= now_suit_cfg then
		self.cur_suit_var_list.percent:SetValue(now_suit_cfg.hxyj_hurt_per / 100)
		self.cur_suit_var_list.percent2:SetValue(now_suit_cfg.hxyj / 100)
	else
		self.cur_suit_var_list.percent:SetValue(0)
		self.cur_suit_var_list.percent2:SetValue(0)
	end
	local color = "#ffffff"
	if nil ~= next_suit_cfg then
		local now_per = now_suit_cfg and now_suit_cfg.hxyj or 0
		local now_hurt_per = now_suit_cfg and now_suit_cfg.hxyj_hurt_per or 0
		color = ITEM_COLOR[next_suit_cfg.color] or "#ffffff"
		self.next_suit_var_list.name:SetValue("<color=" .. color .. ">" .. next_suit_cfg.name .. "</color>")
		self.next_suit_var_list.percent:SetValue(next_suit_cfg.hxyj_hurt_per / 100 - now_hurt_per / 100)
		self.next_suit_var_list.percent2:SetValue(next_suit_cfg.hxyj / 100 - now_per / 100)
		color = next_active_num < ETERNITY_ACTIVE_NEED and TEXT_COLOR.RED or TEXT_COLOR.BLUE_4
		self.next_suit_var_list.active_equip_num:SetValue("<color=" .. color .. ">" .. next_active_num .. "</color>")
	elseif now_suit_cfg then
		color = ITEM_COLOR[now_suit_cfg.color] or "#ffffff"
		self.next_suit_var_list.name:SetValue("<color=" .. color .. ">" .. now_suit_cfg.name .. "</color>")
		self.next_suit_var_list.active_equip_num:SetValue("<color=" .. TEXT_COLOR.BLUE_4 .. ">" .. ETERNITY_ACTIVE_NEED .. "</color>")
	end
end

function ForgeYongHengView:SetCostInfo(cfg)
	if nil == cfg or nil == self.cost_item then return end

	self.cost_item:SetData({item_id = cfg.stuff_id})
	self.need_prop_num:SetValue(cfg.stuff_count)

	self.cost_item2:SetData({item_id = cfg.stuff_2_id})
	self.need_prop_num2:SetValue(cfg.stuff_2_num)

	local bag_num_str = ""
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	if had_prop_num < cfg.stuff_count or had_prop_num == 0 then
		bag_num_str = string.format(Language.Mount.ShowRedNum, had_prop_num)
	else
		bag_num_str = string.format(Language.Mount.ShowBlueNum, had_prop_num)
	end
	self.bag_prop_num:SetValue(bag_num_str)
	had_prop_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_2_id)
	if had_prop_num < cfg.stuff_2_num or had_prop_num == 0 then
		bag_num_str = string.format(Language.Mount.ShowRedNum, had_prop_num)
	else
		bag_num_str = string.format(Language.Mount.ShowBlueNum, had_prop_num)
	end
	self.bag_prop_num2:SetValue(bag_num_str)
end

function ForgeYongHengView:SetModelDisolay(use_eternity_level)
	if nil == self.role_model then
		return
	end
	local temp_use_eternity_level = EquipData.Instance:GetUseEternityLevel()
	local temp_suit_index = ForgeData.Instance:GetEternitySuitIndex(temp_use_eternity_level)

	if self.temp_use_eternity_level ~= temp_use_eternity_level then -- game_vo.appearance.use_eternity_level
		self.temp_use_eternity_level = temp_use_eternity_level -- game_vo.appearance.use_eternity_level
		self.select_suit_index = temp_suit_index -- game_vo.appearance.use_eternity_level
	end
	use_eternity_level = self.select_suit_index -- use_eternity_level or

	local temp_suit_level = ForgeData.Instance:GetSuitLevelByIndex(use_eternity_level)
	local now_suit_cfg, next_suit_cfg = ForgeData.Instance:GetEternitySuitCfg(temp_suit_level)

	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetRoleResid(main_role:GetRoleResId())
	if nil == now_suit_cfg and nil ~= next_suit_cfg then
		self.role_model:SetFaZhenResid(next_suit_cfg.fazhen)
		self.middle_suit_name:SetValue(next_suit_cfg.name)
	elseif nil ~= now_suit_cfg then
		self.role_model:SetFaZhenResid(now_suit_cfg.fazhen)
		self.middle_suit_name:SetValue(now_suit_cfg.name)
	end
end

function ForgeYongHengView:SetEquipData()
	local data_list = EquipData.Instance:GetDataList()
	local temp_equip_cfg = nil
	for k, v in pairs(self.item_list) do
		if data_list[k - 1] and data_list[k - 1].item_id and data_list[k - 1].item_id > 0 then
			if self.select_item_index < 0 then
				self.select_item_index = k - 1
			end
			v:SetData(data_list[k - 1])
			v:SetInteractable(true)
			v:SetHightLight(self.select_item_index == k - 1)
			temp_equip_cfg = ForgeData.Instance:GetEternityEquipCfg(k - 1)
			if nil ~= temp_equip_cfg and temp_equip_cfg.eternity_level > 0 then
				-- self.equip_grade_list[k]:SetValue(string.format(Language.Forge.EquipGradeText, temp_equip_cfg.eternity_level))
				self.equip_color_list[k]:SetAsset(ResPath.GetForgeImg("colorlabel_" .. temp_equip_cfg.eternity_level))
			else
				self.equip_color_list[k]:SetAsset(nil, nil)
			end
		else
			local data = {}
			v:SetData(data)
			v:SetInteractable(false)
			v:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[k]))
			v:SetHightLight(false)
			self.equip_color_list[k]:SetAsset(nil, nil)
		end
		self.show_arrow_list[k]:SetValue(false)
		self.show_arrow_list[k]:SetValue(ForgeData.Instance:GetEquipCanEternity(k - 1))
		self.show_text_hight_light_list[k]:SetValue(ForgeData.Instance:GetEquipIsActive(k - 1, true))
	end
end

function ForgeYongHengView:FlushTotlePower()
	local capability = ForgeData.Instance:GetEternityTotalCapability()
	self.total_power:SetValue(capability)
end

function ForgeYongHengView:OnFlush()
	self:SetModelDisolay()
	self:SetEquipData()
	self:SetRightInfo()
	self:SetArrowState()
	self:FlushTotlePower()
end
