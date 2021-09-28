PlayerFashionHuanhuaView = PlayerFashionHuanhuaView or BaseClass(BaseView)

local CLOTHES_TOGGLE = 1
local WEAPONS_TOGGLE = 0

function PlayerFashionHuanhuaView:__init()
	self.ui_config = {"uis/views/player_prefab","FashionHuanHuaView"}
	self.cell_list = {}
	self.toggle_state = CLOTHES_TOGGLE
	self.cur_cfg_list = {}
	self.cur_cell_index = 1
	self.play_audio = true
	self.prefab_preload_id = 0
end

function PlayerFashionHuanhuaView:__delete()

end

function PlayerFashionHuanhuaView:LoadCallBack()
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("player_fashion_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHuanhuaCell, self)

	self.up_grade_btn = self:FindObj("UpGradeButton")
	self.show_up_grade_text_gray = self:FindVariable("ShowUpgradeTextGray")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.clothes_toggle = self:FindObj("ClothesToggle").toggle
	self.weapons_toggle = self:FindObj("WeaponsToggle").toggle

	-- 监听事件
	self:ListenEvent("OnClickActivate", BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade", BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickClothes", BindTool.Bind(self.OnClickClothes, self))
	self:ListenEvent("OnClickWeapon", BindTool.Bind(self.OnClickWeapon, self))

	-- 变量
	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.maxhp = self:FindVariable("ShengMing")

	self.bag_prop_num = self:FindVariable("ActivateProNum")
	self.need_prop_num = self:FindVariable("ExchangeNeedNum")
	self.fight_power = self:FindVariable("FightPower")
	self.name = self:FindVariable("ZuoQiName")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.upgrade_btn_text = self:FindVariable("UpgradeBtnText")

	self.show_up_grade_btn = self:FindVariable("IsShowUpGrade")
	self.show_active_btn = self:FindVariable("IsShowActivate")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")
	self.show_cloth_red_point = self:FindVariable("ShowClothRedPoint")
	self.show_weapon_red_point = self:FindVariable("ShowWeaponRedPoint")
end

function PlayerFashionHuanhuaView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.toggle_state = nil
	self.cur_cfg_list = {}
	self.cur_cell_index = nil
	self.res_id = nil
	self.weapon_id = nil

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	-- 清理变量和对象
	self.display = nil
	self.list_view = nil
	self.up_grade_btn = nil
	self.show_up_grade_text_gray = nil
	self.clothes_toggle = nil
	self.weapons_toggle = nil
	self.gongji = nil
	self.fangyu = nil
	self.maxhp = nil
	self.bag_prop_num = nil
	self.need_prop_num = nil
	self.fight_power = nil
	self.name = nil
	self.cur_level = nil
	self.upgrade_btn_text = nil
	self.show_up_grade_btn = nil
	self.show_active_btn = nil
	self.show_cur_level = nil
	self.show_cloth_red_point = nil
	self.show_weapon_red_point = nil
end

function PlayerFashionHuanhuaView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function PlayerFashionHuanhuaView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.toggle_state = CLOTHES_TOGGLE
	self.cur_cfg_list = {}
	self.cur_cell_index = 1
	self.res_id = nil
	self.weapon_id = nil
	self:Flush()
end

function PlayerFashionHuanhuaView:ItemDataChangeCallback()
	self:Flush()
end

function PlayerFashionHuanhuaView:OnClickActivate()
	local cfg = self.cur_cfg_list[self.cur_cell_index]
	local upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cell_index, self.toggle_state)
	local data_list = ItemData.Instance:GetBagItemDataList()
	if not cfg or not upgrade_cfg then return end

	local item_id = cfg.active_stuff_id
	for k, v in pairs(data_list) do
		if v.item_id == item_id and v.num >= upgrade_cfg.stuff_count then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end

	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		return
	end

	if item_cfg.bind_gold == 0 then
		TipsCtrl.Instance:ShowShopView(item_id, 2)
		return
	end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	return
end

function PlayerFashionHuanhuaView:OnClickClose()
	self:Close()
end

function PlayerFashionHuanhuaView:OnClickUpGrade()
	local next_upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cell_index, self.toggle_state, true)
	if not next_upgrade_cfg then return end

	local item_id = next_upgrade_cfg.need_stuff
	if ItemData.Instance:GetItemNumInBagById(item_id) >= next_upgrade_cfg.stuff_count then
		FashionCtrl.Instance:SendFashionUpgradeReq(self.toggle_state, self.cur_cell_index)
	else
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	end
end

function PlayerFashionHuanhuaView:OnClickClothes()
	if self.toggle_state ~= CLOTHES_TOGGLE then
		self:ShowIndex(TabIndex.fashion_clothe_jinjie)
		self.cur_cell_index = 1
		if self.display ~= nil then
			self.display.ui3d_display:ResetRotation()
		end
		self:Flush()
	end
end

function PlayerFashionHuanhuaView:OnClickWeapon()
	if self.toggle_state ~= WEAPONS_TOGGLE then
		self:ShowIndex(TabIndex.fashion_weapon_jinjie)
		self.cur_cell_index = 1
		if self.display ~= nil then
			self.display.ui3d_display:ResetRotation()
		end
		self:Flush()
	end
end

function PlayerFashionHuanhuaView:GetNumberOfCells()
	return #self.cur_cfg_list
end

function PlayerFashionHuanhuaView:RefreshHuanhuaCell(cell, data_index)
	local huanhua_cell = self.cell_list[cell]
	if not huanhua_cell then
		huanhua_cell = FashionHuanhuaItem.New(cell)
		self.cell_list[cell] = huanhua_cell
		huanhua_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	huanhua_cell:SetData(self.cur_cfg_list[data_index + 1])
	huanhua_cell:ListenClick(BindTool.Bind(self.OnClickHuanhuaCell, self, self.cur_cfg_list[data_index + 1], data_index, huanhua_cell))
	huanhua_cell:SetHighLight(self.cur_cell_index == (data_index + 1))
end

function PlayerFashionHuanhuaView:OnClickHuanhuaCell(cfg, index, huanhua_cell)
	self.cur_cell_index = index + 1
	huanhua_cell:SetHighLight(true)
	self:SetHuanhuaInfo(index, cfg)
end

-- 设置幻化面板显示
function PlayerFashionHuanhuaView:SetHuanhuaInfo(index, cfg)
	self.cur_cell_index = self.cur_cell_index or index
	local cfg = cfg or self.cur_cfg_list[self.cur_cell_index]
	if not cfg then return end
	local upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cell_index, self.toggle_state)
	local next_upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cell_index, self.toggle_state, true)
	if not upgrade_cfg then return end

	local item_cfg = ItemData.Instance:GetItemConfig(upgrade_cfg.need_stuff)
	if item_cfg then
		-- local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..(cfg.name or "").."</color>"
		self.name:SetValue(cfg.name or "")
	end
	self.show_cur_level:SetValue(FashionData.Instance:GetFashionActFlag(self.toggle_state, self.cur_cell_index))
	self.cur_level:SetValue(upgrade_cfg.level)

	local bag_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.need_stuff)
	if next_upgrade_cfg then
		self.need_prop_num:SetValue(next_upgrade_cfg.stuff_count)
		local bag_num_str = bag_num < next_upgrade_cfg.stuff_count and string.format(Language.Mount.ShowRedNum, bag_num) or string.format(Language.Mount.ShowBlueNum, bag_num)
		self.bag_prop_num:SetValue(bag_num_str)
	else
		self.bag_prop_num:SetValue(bag_num)
		self.need_prop_num:SetValue(string.format(Language.Mount.ShowRedNum, 0))
	end

	local attr_list = CommonDataManager.GetAttributteNoUnderline(upgrade_cfg)
	self.gongji:SetValue(attr_list.gongji)
	self.fangyu:SetValue(attr_list.fangyu)
	self.maxhp:SetValue(attr_list.maxhp)

	self.fight_power:SetValue(CommonDataManager.GetCapabilityCalculation(attr_list))

	local data = {item_id = upgrade_cfg.need_stuff}
	self.item:SetData(data)
	self:SetButtonsState()
	self:SetModel()
end

function PlayerFashionHuanhuaView:SetModel()
	local cfg = self.cur_cfg_list[self.cur_cell_index] or {}
	local weapon_res_id = 0
	local weapon2_res_id = 0
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()

	if self.toggle_state == 1 then
		res_id = cfg["resouce"..game_vo.prof..game_vo.sex]
		weapon_res_id = main_role:GetWeaponResId()
		weapon2_res_id = main_role:GetWeapon2ResId()
	else
		res_id = main_role:GetRoleResId()
		weapon_res_id = cfg["resouce"..game_vo.prof..game_vo.sex]
		local temp = Split(weapon_res_id, ",")
		weapon_res_id = temp[1]
		weapon2_res_id = temp[2]
	end

	if self.res_id ~= res_id or self.weapon_id ~= weapon_res_id then
		local bundle_1, asset_1 = ResPath.GetWeaponModel(weapon_res_id)
		local bundle_2, asset_2 = ResPath.GetRoleModel(res_id)

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

		local load_list = {{bundle_1, asset_1}, {bundle_2, asset_2}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				self.model:SetRoleResid(res_id)
				self.model:SetWeaponResid(weapon_res_id)
				if weapon2_res_id then
					self.model:SetWeapon2Resid(weapon2_res_id)
				end
			end)

		self.res_id = res_id
		self.weapon_id = weapon_res_id
	end
end

function PlayerFashionHuanhuaView:SetButtonsState()
	local is_active = FashionData.Instance:GetFashionActFlag(self.toggle_state, self.cur_cell_index) == 1
	self.show_active_btn:SetValue(not is_active)
	self.show_up_grade_btn:SetValue(is_active)
	local next_upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cell_index, self.toggle_state, true)
	self.up_grade_btn.button.interactable = (nil ~= next_upgrade_cfg)
	self.show_up_grade_text_gray:SetValue(nil ~= next_upgrade_cfg)
	self.upgrade_btn_text:SetValue((nil ~= next_upgrade_cfg) and Language.Common.UpGrade or Language.Common.YiManJi)
end

function PlayerFashionHuanhuaView:OnFlush(param)
	local cur_index = self:GetShowIndex()

	if cur_index == TabIndex.fashion_clothe_jinjie then
		self.clothes_toggle.isOn = true
		self.weapons_toggle.isOn = false
		-- if self.toggle_state ~= CLOTHES_TOGGLE then
		-- 	if self.list_view.scroller.isActiveAndEnabled then
		-- 		self.list_view.scroller:ReloadData(0)
		-- 	end
		-- end
		self.toggle_state = CLOTHES_TOGGLE
	elseif cur_index == TabIndex.fashion_weapon_jinjie then
		self.weapons_toggle.isOn = true
		self.clothes_toggle.isOn = false
		-- if self.toggle_state ~= WEAPONS_TOGGLE then
		-- 	if self.list_view.scroller.isActiveAndEnabled then
		-- 		self.list_view.scroller:ReloadData(0)
		-- 	end
		-- end
		self.toggle_state = WEAPONS_TOGGLE
	end

	self.cur_cfg_list = FashionData.Instance:GetFashionSameTypeList(self.toggle_state)

	if self.temp_toggle_state ~= self.toggle_state then
		if self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:ReloadData(0)
		end
	else
		if self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:RefreshActiveCellViews()
		end
	end

	self.temp_toggle_state = self.toggle_state

	self.show_cloth_red_point:SetValue(FashionData.Instance:IsShowJinjieRedPoint(SHIZHUANG_TYPE.BODY))
	self.show_weapon_red_point:SetValue(FashionData.Instance:IsShowJinjieRedPoint(SHIZHUANG_TYPE.WUQI))
	self:SetHuanhuaInfo(self.cur_cell_index, self.cur_cfg_list[self.cur_cell_index])
end


FashionHuanhuaItem = FashionHuanhuaItem or BaseClass(BaseRender)

function FashionHuanhuaItem:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.quality = self:FindVariable("Quality")
	self.show_red_point = self:FindVariable("ShowRedPoint")
end

function FashionHuanhuaItem:__delete()

end

function FashionHuanhuaItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function FashionHuanhuaItem:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function FashionHuanhuaItem:SetData(data)
	if not data then return end
	local item_cfg = ItemData.Instance:GetItemConfig(data.active_stuff_id)
	local next_upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(data.index, data.part_type, true)
	if item_cfg then
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..(data.name or "").."</color>"
		self.name:SetValue(name_str)
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.icon:SetAsset(bundle, asset)

		self.quality:SetAsset(ResPath.GetQualityIcon(item_cfg.color))
	end
	self.show_red_point:SetValue((nil ~= next_upgrade_cfg) and ItemData.Instance:GetItemNumInBagById(next_upgrade_cfg.need_stuff) >= next_upgrade_cfg.stuff_count)
end

function FashionHuanhuaItem:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end