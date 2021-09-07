PlayerFashionHuanhuaView = PlayerFashionHuanhuaView or BaseClass(BaseView)

local CLOTHES_TOGGLE = 1
local WEAPONS_TOGGLE = 0
local MOUNT_TOGGLE = 2
local WING_TOGGLE = 3

function PlayerFashionHuanhuaView:__init()
	self.ui_config = {"uis/views/player","FashionHuanHuaView"}
	self:SetMaskBg()
	self.cell_list = {}
	self.toggle_state = CLOTHES_TOGGLE
	self.cur_cfg_list = {}
	self.cur_cell_index = 1
	self.play_audio = true
	self.level_text = 0
	self.fix_show_time = 10
	self.need_check = false
end

function PlayerFashionHuanhuaView:LoadCallBack()
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("fashion_huanhua_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHuanhuaCell, self)

	self.up_grade_btn = self:FindObj("UpGradeButton")
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
	self:ListenEvent("OnClickMount", BindTool.Bind(self.OnClickMount, self))
	self:ListenEvent("OnClickWing", BindTool.Bind(self.OnClickWing, self))

	-- 变量
	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.maxhp = self:FindVariable("ShengMing")

	self.bag_prop_num = self:FindVariable("ActivateProNum")
	self.need_prop_num = self:FindVariable("ExchangeNeedNum")
	self.fight_power = self:FindVariable("FightPower")
	--self.name = self:FindVariable("ZuoQiName")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.upgrade_btn_text = self:FindVariable("UpgradeBtnText")
	self.is_max = self:FindVariable("IsMax")

	self.show_up_grade_btn = self:FindVariable("IsShowUpGrade")
	self.show_active_btn = self:FindVariable("IsShowActivate")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")
	self.show_cloth_red_point = self:FindVariable("ShowClothRedPoint")
	self.show_weapon_red_point = self:FindVariable("ShowWeaponRedPoint")
	self.show_mount_red_point = self:FindVariable("ShowMountRedPoint")
	self.show_wing_red_point = self:FindVariable("ShowWingRedPoint")

	self.show_btn_left = self:FindVariable("ShowBtnLeft")
	self.show_btn_right = self:FindVariable("ShowBtnRight")
	--self.name_res = self:FindVariable("NameRes")
	self.name_obj = self:FindObj("NameObj")
	self:ListenEvent("OnClickBtnLeft",BindTool.Bind(self.OnClickChange, self, -1))
	self:ListenEvent("OnClickBtnRight",BindTool.Bind(self.OnClickChange, self, 1))

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
end

function PlayerFashionHuanhuaView:ReleaseCallBack()
	self.suit_cfg = nil

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
	self.up_grade_btn = nil
	self.display = nil
	self.list_view = nil
	self.clothes_toggle = nil
	self.cell_list = {}
	self.maxhp = nil
	self.fight_power = nil
	self.need_prop_num = nil
	self.toggle_state = nil
	--self.name = nil
	self.cur_cfg_list = {}
	self.cur_cell_index = nil
	self.res_id = nil
	self.weapon_id = nil
	self.show_cloth_red_point = nil
	self.fangyu = nil
	self.gongji = nil
	self.bag_prop_num = nil
	self.show_cur_level = nil
	self.show_up_grade_btn = nil
	self.weapons_toggle = nil
	self.cur_level = nil
	self.upgrade_btn_text = nil
	self.show_active_btn = nil
	self.show_weapon_red_point = nil
	self.show_mount_red_point = nil
	self.show_wing_red_point = nil
	self.show_btn_left = nil
	self.show_btn_right = nil
	--self.name_res = nil
	self.name_obj = nil
	self.is_max = nil

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function PlayerFashionHuanhuaView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.suit_cfg = nil
end

function PlayerFashionHuanhuaView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.toggle_state = CLOTHES_TOGGLE
	if self.clothes_toggle then
		self.clothes_toggle.isOn = true
	end
	self.cur_cfg_list = {}
	self.cur_cell_index = 1
	self.res_id = nil
	self.weapon_id = nil
	self.need_check = false
	self:Flush()
end

function PlayerFashionHuanhuaView:ItemDataChangeCallback()
	self:Flush()
end

function PlayerFashionHuanhuaView:OnClickChange(change_value)
	if change_value ~= nil then
		local max = #self.cur_cfg_list
		local change_index = self.cur_cell_index
		change_index = change_index + change_value
		change_index = change_index < 1 and 1 or change_index
		change_index = change_index > max and max or change_index

		if self.list_view ~= nil then
			self.list_view.scroller:JumpToDataIndex(change_index - 1)
			for k,v in pairs(self.cell_list) do
				if v ~= nil and v.index == change_index then
					self:OnClickHuanhuaCell(self.cur_cfg_list[change_index], change_index - 1, v)
				end
			end
		end
	end
end

function PlayerFashionHuanhuaView:OnClickActivate()
	if self.cur_cfg_list[self.cur_cell_index] == nil then
		return
	end

	local cfg = self.cur_cfg_list[self.cur_cell_index]
	local read_index = cfg.index
	local upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(cfg.index, self.toggle_state)
	if self.toggle_state == MOUNT_TOGGLE then
		upgrade_cfg = MountData.Instance:GetSpecialImagesCfg()
	elseif self.toggle_state == WING_TOGGLE then
		upgrade_cfg = WingData.Instance:GetSpecialImagesCfg()
	end

	local data_list = ItemData.Instance:GetBagItemDataList()
	if not cfg or not upgrade_cfg then return end
	local item_id = 0
	if self.toggle_state == MOUNT_TOGGLE or self.toggle_state == WING_TOGGLE then
		item_id = upgrade_cfg[cfg.image_id].item_id
		for k, v in pairs(data_list) do
			if v.item_id == item_id then
				PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
				return
			end
		end
		self:SendShopBuy(item_id)
	else
		item_id = cfg.active_stuff_id
		for k, v in pairs(data_list) do
			if v.item_id == item_id and v.num >= upgrade_cfg.stuff_count then
				PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
				return
			end
		end
		self:SendShopBuy(item_id)
	end
end

function PlayerFashionHuanhuaView:OnClickClose()
	self:Close()
end

function PlayerFashionHuanhuaView:OnClickUpGrade()
	if self.cur_cfg_list[self.cur_cell_index] == nil then
		return
	end

	local next_upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cfg_list[self.cur_cell_index].index, self.toggle_state, true)
	if self.toggle_state == MOUNT_TOGGLE then
		next_upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(self.cur_cfg_list[self.cur_cell_index].image_id, self.level_text)
	elseif self.toggle_state == WING_TOGGLE then
		next_upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(self.cur_cfg_list[self.cur_cell_index].image_id, self.level_text)
	end
	if not next_upgrade_cfg then return end
	if self.toggle_state == MOUNT_TOGGLE then
		if ItemData.Instance:GetItemNumInBagById(next_upgrade_cfg.stuff_id) > 0 then
			MountHuanHuaCtrl.Instance:MountSpecialImaUpgrade(self.cur_cfg_list[self.cur_cell_index].image_id)
			return
		end
		self:SendShopBuy(next_upgrade_cfg.stuff_id)
	elseif self.toggle_state == WING_TOGGLE then
		if ItemData.Instance:GetItemNumInBagById(next_upgrade_cfg.stuff_id) > 0 then
			WingHuanHuaCtrl.Instance:WingSpecialImaUpgrade(self.cur_cfg_list[self.cur_cell_index].image_id)
			return
		end
		self:SendShopBuy(next_upgrade_cfg.stuff_id)
	else
		item_id = next_upgrade_cfg.need_stuff
		if ItemData.Instance:GetItemNumInBagById(item_id) >= next_upgrade_cfg.stuff_count then
			FashionCtrl.Instance:SendFashionUpgradeReq(self.toggle_state, self.cur_cfg_list[self.cur_cell_index].index)
		else
			self:SendShopBuy(item_id)
		end
	end
end

function PlayerFashionHuanhuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" and self:IsOpen() then
		self:FlushData()
	end
end

function PlayerFashionHuanhuaView:FlushData()
	--self.all_num, self.all_data = BeautyHaloData.Instance:GetShowSpecialInfo()
	self:Flush("all", {need_flush = true})
end

function PlayerFashionHuanhuaView:SendShopBuy(item_id)
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		return
	end

	-- if item_cfg.bind_gold == 0 then
	-- 	TipsCtrl.Instance:ShowShopView(item_id, 2)
	-- 	return
	-- end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	return
end

function PlayerFashionHuanhuaView:OnClickClothes()
	if self.toggle_state ~= CLOTHES_TOGGLE then
		self:ShowIndex(TabIndex.fashion_clothe_jinjie)
		self.cur_cell_index = 1
		if self.display ~= nil then
			self.display.ui3d_display:ResetRotation()
		end

		if self.suit_cfg ~= nil then
			self.need_check = true
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

		if self.suit_cfg ~= nil then
			self.need_check = true
		end

		self:Flush()
	end
end

function PlayerFashionHuanhuaView:OnClickMount()
	if self.toggle_state ~= MOUNT_TOGGLE then
		self:ShowIndex(TabIndex.fashion_mount_jinjie)
		self.cur_cell_index = 1
		if self.display ~= nil then
			self.display.ui3d_display:ResetRotation()
		end

		if self.suit_cfg ~= nil then
			self.need_check = true
		end
		self:Flush()
	end
end

function PlayerFashionHuanhuaView:OnClickWing()
	if self.toggle_state ~= WING_TOGGLE then
		self:ShowIndex(TabIndex.fashion_wing_jinjie)
		self.cur_cell_index = 1
		if self.display ~= nil then
			self.display.ui3d_display:ResetRotation()
		end

		if self.suit_cfg ~= nil then
			self.need_check = true
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
		huanhua_cell = FashionHuanhuaItem.New(cell, self)
		self.cell_list[cell] = huanhua_cell
		huanhua_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	huanhua_cell:SetIndex(data_index + 1)
	huanhua_cell:SetData(self.cur_cfg_list[data_index + 1], self.toggle_state)
	huanhua_cell:ListenClick(BindTool.Bind(self.OnClickHuanhuaCell, self, self.cur_cfg_list[data_index + 1], data_index, huanhua_cell))
	huanhua_cell:SetHighLight(self.cur_cell_index == (data_index + 1))
end

function PlayerFashionHuanhuaView:GetCurCfgList()
	return self.cur_cfg_list or {}
end

function PlayerFashionHuanhuaView:OnClickHuanhuaCell(cfg, index, huanhua_cell)
	self.cur_cell_index = index + 1
	huanhua_cell:SetHighLight(true)
	self:SetHuanhuaInfo(index, cfg, false)

	if self.show_btn_left ~= nil then
		self.show_btn_left:SetValue(self.cur_cell_index > 1)
	end

	if self.show_btn_right ~= nil then
		self.show_btn_right:SetValue(self.cur_cell_index < #self.cur_cfg_list)
	end
end

-- 设置幻化面板显示
function PlayerFashionHuanhuaView:SetHuanhuaInfo(index, cfg, bool)
	self.cur_cell_index = self.cur_cell_index or index
	local cfg = cfg or self.cur_cfg_list[self.cur_cell_index]
	if not cfg then return end

	local upgrade_cfg = {}
	local next_upgrade_cfg = {}
	local need_stuff = 0
	local name = ""
	local stuff_count = 1
	if self.toggle_state == MOUNT_TOGGLE  then
		upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(cfg.image_id)
		name = cfg.image_name
		need_stuff = cfg.item_id
		self.level_text = upgrade_cfg.grade
		next_upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(cfg.image_id, nil, true)
	elseif self.toggle_state == WING_TOGGLE then
		upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(cfg.image_id)
		name = cfg.image_name
		need_stuff = cfg.item_id
		self.level_text = upgrade_cfg.grade
		next_upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(cfg.image_id, nil, true)
	else
		upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cfg_list[self.cur_cell_index].index, self.toggle_state, false, nil, cfg)
		next_upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(self.cur_cfg_list[self.cur_cell_index].index, self.toggle_state, true, nil, cfg)
		need_stuff = upgrade_cfg.need_stuff
		self.level_text = FashionData.Instance:GetCurLevel(self.cur_cfg_list[self.cur_cell_index].index, self.toggle_state)
		name = cfg.name

		if next_upgrade_cfg ~= nil then
			stuff_count = next_upgrade_cfg.stuff_count
		end
	end
	if not upgrade_cfg then return end

	if self.is_max ~= nil then
		self.is_max:SetValue(next_upgrade_cfg ~= nil)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(need_stuff)
	if item_cfg then
		local name_str = ToColorStr(name or "", SOUL_NAME_COLOR[item_cfg.color])
		if self.level_text == 0 then
			self.cur_level:SetValue("")
		else
			local level_text_col = ToColorStr("Lv." .. self.level_text or "","#f8f1e6ff")
			self.cur_level:SetValue(level_text_col)
		end

		if self.name_obj ~= nil and self.toggle_state ~= nil then
			local bundle, asset
			if self.toggle_state == CLOTHES_TOGGLE then
				bundle, asset = ResPath.GetPlayerImage("hh_clothes_" .. cfg.index)
			elseif self.toggle_state == WEAPONS_TOGGLE then
				bundle, asset = ResPath.GetPlayerImage("hh_weapon_" .. cfg.index)
			elseif self.toggle_state == MOUNT_TOGGLE then
				bundle, asset = ResPath.GetPlayerImage("hh_mount_" .. cfg.image_id)
			elseif self.toggle_state == WING_TOGGLE then
				bundle, asset = ResPath.GetPlayerImage("hh_wing_" .. cfg.image_id)
			end

			if bundle ~= nil and asset ~= nil then
				self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
					self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
				end)
			end
		end	
	end
	local bag_num = ItemData.Instance:GetItemNumInBagById(need_stuff)
	self.need_prop_num:SetValue(stuff_count)
	local bag_num_str = bag_num < stuff_count and string.format(Language.Mount.ShowRedNum, bag_num) or bag_num
	self.bag_prop_num:SetValue(bag_num_str)

	local attr_list = CommonDataManager.GetAttributteNoUnderline(upgrade_cfg)
	self.gongji:SetValue(attr_list.gongji)
	self.fangyu:SetValue(attr_list.fangyu)
	self.maxhp:SetValue(attr_list.maxhp)

	self.fight_power:SetValue(CommonDataManager.GetCapabilityCalculation(attr_list))

	local data = {item_id = need_stuff}

	self.suit_cfg = FashionData.Instance:GetMasterCfgById(need_stuff)

	self.item:SetData(data)
	self:SetButtonsState()
	self:SetModel(bool)
end

function PlayerFashionHuanhuaView:SetModel(bool)
	local cfg = self.cur_cfg_list[self.cur_cell_index] or {}

	local main_role = Scene.Instance:GetMainRole()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local bundle, asset = nil, nil
	local res_id = 0
	local rotation = Vector3(0, 0, 0)
	local scale = Vector3(1, 1, 1)
	if self.model and bool then
		local weapon_part = self.model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = self.model.draw_obj:GetPart(SceneObjPart.Wing)
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
	end
	if self.toggle_state == MOUNT_TOGGLE then
		bundle, asset = ResPath.GetMountModel(cfg.res_id)
		res_id = cfg.res_id
		scale = Vector3(0.5, 0.5, 0.5)
		rotation = Vector3(0, -45, 0)
		--按照策划要求改的 普天同庆·骑
		if cfg.res_id == 7304001 then
			scale = Vector3(0.3, 0.3, 0.3)
		end
	elseif self.toggle_state == WING_TOGGLE then
		bundle, asset = ResPath.GetWingModel(cfg.res_id)
		res_id = cfg.res_id
	else
		local weapon_res_id = 0
		local weapon2_res_id = 0
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
		self.model:SetRoleResid(res_id)
		self.model:SetWeaponResid(weapon_res_id)
		if weapon2_res_id then
			self.model:SetWeapon2Resid(weapon2_res_id)
		end
	end
	if self.model and res_id > 0 then
		self.model:SetRotation(rotation)
		self.model:SetModelScale(scale)
		if bundle and asset and self.model then
			self.model:SetMainAsset(bundle, asset)
		end
	end

	if self.toggle_state == MOUNT_TOGGLE then
		local part = self.model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger("rest")
		end
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self:SetModleRestAni()
	else
		if self.toggle_state == WING_TOGGLE then
			self.model:SetLayer(1, 1.0)
		end
	end
end

function PlayerFashionHuanhuaView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.model then
					local part = self.model.draw_obj:GetPart(SceneObjPart.Main)
					if part then
						part:SetTrigger("rest")
					end
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function PlayerFashionHuanhuaView:SetButtonsState()
	if self.cur_cfg_list[self.cur_cell_index] == nil then
		return
	end
	
	local image_cfg = nil
	if self.toggle_state == MOUNT_TOGGLE or self.toggle_state == WING_TOGGLE then
		local active = false
		if self.toggle_state == MOUNT_TOGGLE then
			image_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(self.cur_cfg_list[self.cur_cell_index].image_id, self.level_text)
			local info_list = MountData.Instance:GetMountInfo()
			local bit_list = info_list.active_special_image_list
			active = bit_list[self.cur_cfg_list[self.cur_cell_index].image_id] == 1
		else
			image_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(self.cur_cfg_list[self.cur_cell_index].image_id, self.level_text)
			local info_list = WingData.Instance:GetWingInfo()
			-- local active_flag = info_list.active_special_image_flag
			local bit_list = info_list.active_special_image_list
			active = bit_list[self.cur_cfg_list[self.cur_cell_index].image_id]	== 1
		end

		self.show_active_btn:SetValue(not active)
		self.show_up_grade_btn:SetValue(active)
	else
		image_cfg = FashionData.Instance:GetUpGradeCfg(self.cur_cfg_list[self.cur_cell_index].index, self.toggle_state)
		local is_suit = self.cur_cfg_list[self.cur_cell_index].is_suit
		local active = FashionData.Instance:GetFashionActFlag(self.toggle_state, self.cur_cfg_list[self.cur_cell_index].index)
		self.show_active_btn:SetValue(active ~= nil and active == 0 or false)
		self.show_up_grade_btn:SetValue(active ~= nil and active == 1 or false)
	end
	self.up_grade_btn.button.interactable = (nil ~= image_cfg)
	self.upgrade_btn_text:SetValue((nil ~= image_cfg) and Language.Common.UpGrade or Language.Common.YiManJi)
end

function PlayerFashionHuanhuaView:OnFlush(param)
	local cur_index = self:GetShowIndex()
	local cur_num = self.cur_cfg_list
	for k,v in pairs(param) do
		if k == "all" then
			if cur_index == TabIndex.fashion_clothe_jinjie or v.need_flush then
				self.toggle_state = CLOTHES_TOGGLE
				self.cur_cfg_list = FashionData.Instance:GetFashionSameTypeList(self.toggle_state)
			elseif cur_index == TabIndex.fashion_weapon_jinjie or v.need_flush then
				self.toggle_state = WEAPONS_TOGGLE
				self.cur_cfg_list = FashionData.Instance:GetFashionSameTypeList(self.toggle_state)
			elseif cur_index == TabIndex.fashion_mount_jinjie or v.need_flush then
				self.toggle_state = MOUNT_TOGGLE
				--local cfg_list = MountData.Instance:GetSpecialImagesCfg()
				local _, cfg_list = MountData.Instance:GetShowSpecialInfo()
				self.cur_cfg_list = FashionData.Instance:GetMountSpecialImagesCfg(cfg_list)
			elseif cur_index == TabIndex.fashion_wing_jinjie or v.need_flush then
				self.toggle_state = WING_TOGGLE
				--local cfg_list = WingData.Instance:GetSpecialImagesCfg()
				local _, cfg_list = WingData.Instance:GetShowSpecialInfo()
				self.cur_cfg_list = FashionData.Instance:GetMountSpecialImagesCfg(cfg_list)
			end
		end
	end

	local is_change = false
	if self.cur_cfg_list ~= nil and self.cur_cell_index ~= nil and self.cur_cfg_list[self.cur_cell_index] == nil then
		self.cur_cell_index = 1
		is_change = true
	end

	self:CheckSuit()
	if self.temp_toggle_state ~= self.toggle_state or #cur_num ~= #self.cur_cfg_list or is_change then
		if self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:ReloadData(0)
		end
	else
		if self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:RefreshActiveCellViews()
		end
	end

	if self.show_btn_left ~= nil then
		self.show_btn_left:SetValue(self.cur_cell_index > 1)
	end

	if self.show_btn_right ~= nil then
		self.show_btn_right:SetValue(self.cur_cell_index < #self.cur_cfg_list)
	end

	self.temp_toggle_state = self.toggle_state

	self.show_cloth_red_point:SetValue(FashionData.Instance:IsShowRedPointByType())
	self.show_weapon_red_point:SetValue(FashionData.Instance:IsShowRedPointByType(SHIZHUANG_TYPE.WUQI))
	self.show_mount_red_point:SetValue(FashionData.Instance:IsShowMountRed())
	self.show_wing_red_point:SetValue(FashionData.Instance:IsShowWingRed())
	self:SetHuanhuaInfo(self.cur_cell_index, self.cur_cfg_list[self.cur_cell_index], true)
end

function PlayerFashionHuanhuaView:CheckSuit()
	if self.cur_cfg_list == nil then
		return
	end

	if self.need_check then
		self.need_check = false
		-- if self.suit_cfg ~= nil then
		-- 	if need_stuff == self.suit_cfg.weapon_id or need_stuff == self.suit_cfg.dress_id 
		-- 		or need_stuff == self.suit_cfg.mount_id or need_stuff == self.suit_cfg.wing_id then

		-- 		if self.list_view and self.list_view.scroller then
		-- 			self.list_view.scroller:JumpToDataIndex(change_index - 1)
		-- 		end
		-- 	end
		-- end
		for k, v in pairs(self.cur_cfg_list) do
			if self.toggle_state == MOUNT_TOGGLE  then
				need_stuff = v.item_id or 0
			elseif self.toggle_state == WING_TOGGLE then
				need_stuff = v.item_id or 0
			else
				upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, self.toggle_state, false, nil, v)
				need_stuff = upgrade_cfg.need_stuff or 0
			end

			if need_stuff == self.suit_cfg.weapon_id or need_stuff == self.suit_cfg.dress_id 
				or need_stuff == self.suit_cfg.mount_id or need_stuff == self.suit_cfg.wing_id then

				if self.list_view and self.list_view.scroller then
					self.list_view.scroller:JumpToDataIndex(k - 1)
					self.cur_cell_index = k
					return
				end
			end
		end
	end
end


FashionHuanhuaItem = FashionHuanhuaItem or BaseClass(BaseRender)

function FashionHuanhuaItem:__init(instance, parent_view)
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.high_name = self:FindVariable("HighName")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.is_possess_img = self:FindVariable("Is_Possess")
	self.index = 0
	self.parent_view = parent_view
end

function FashionHuanhuaItem:__delete()
	self.parent_view = nil
end

function FashionHuanhuaItem:SetIndex(index)
	self.index = index
end

function FashionHuanhuaItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function FashionHuanhuaItem:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function FashionHuanhuaItem:SetData(data, toggle_state)
	if not data then return end
	local stuff_id = 0
	local name = ""

	if toggle_state < 2 then
		stuff_id = data.active_stuff_id
		name = data.name
	else
		stuff_id = data.item_id
		name = data.image_name
	end
	local item_cfg = ItemData.Instance:GetItemConfig(stuff_id)
	local index = data.index or data.image_id
	local next_upgrade_cfg = FashionData.Instance:GetFashionUpgradeCfg(index, data.part_type, true)
	if item_cfg then
		local name_str = ""
		--name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..(name or "").."</color>"
		-- local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		-- self.icon:SetAsset(bundle, asset)
		self.name:SetValue(name)
		self.high_name:SetValue(name or "")
	end
	local bag_num = ItemData.Instance:GetItemNumInBagById(stuff_id)
	if toggle_state == MOUNT_TOGGLE then
		next_upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(data.image_id, nil, true)
	elseif toggle_state == WING_TOGGLE then
		next_upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(data.image_id, nil, true)
	end
	self.show_red_point:SetValue(bag_num > 0 and next_upgrade_cfg ~= nil)
	local cur_cfg_list = self.parent_view:GetCurCfgList()
	local active = false
	if toggle_state == MOUNT_TOGGLE or toggle_state == WING_TOGGLE then
		if toggle_state == MOUNT_TOGGLE then
			local info_list = MountData.Instance:GetMountInfo()
			local bit_list = info_list.active_special_image_list
			active = bit_list[cur_cfg_list[self.index].image_id]
		else
			local info_list = WingData.Instance:GetWingInfo()
			-- local active_flag = info_list.active_special_image_flag
			local bit_list = info_list.active_special_image_list
			active = bit_list[cur_cfg_list[self.index].image_id]		
		end
	else
		active = FashionData.Instance:GetFashionActFlag(toggle_state, cur_cfg_list[self.index].index)
	end
	self.is_possess_img:SetValue(active == 1)
end

function FashionHuanhuaItem:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end