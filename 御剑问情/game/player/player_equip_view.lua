PlayerEquipView = PlayerEquipView or BaseClass(BaseRender)

local Defult_Icon_List =
	{
		"icon_toukui",
		"icon_yifu",
		"icon_kuzi",
		"icon_xiezi",
		"icon_hushou",
		"icon_xianglian",
		"icon_wuqi",
		"icon_jiezhi",
		"icon_yaodai",
		"icon_jiezhi",
		"icon_gouyu",
		"icon_gouyu2",
		"icon_tianshi",
		"icon_emo",
	}

local JIEZHI_INDEX_1 = 8
local JIEZHI_INDEX_2 = 10
local GOUYU_INDEX_1 = 11
local GOUYU_INDEX_2 = 12
local TIANSHI_INDEX = 13
local EMO_INDEX = 14

function PlayerEquipView:__init(instance,parent_view)
	if instance == nil then
		return
	end

	self.parent_view = parent_view
	self.from_view = TipsFormDef.FROM_BAG_EQUIP
	self.is_opening = false

	self.cells = {}
	self.spec_cells = {}

	self.show_shen_equip_btn = self:FindVariable("ShowShenEquipBtn")
	self.show_shen_equip_red_point = self:FindVariable("ShowShenEquipRedPoint")
	self.show_mojie_red_point = self:FindVariable("ShowMojieRed")
	self.show_goto_btn_1 = self:FindVariable("ShowGotoBtn1")
	self.show_goto_btn_2 = self:FindVariable("ShowGotoBtn2")
	for i = 1, 2 do
		self:ListenEvent("ItemGoToTreasure"..i,BindTool.Bind(self.ItemGoToTreasure, self))
	end

	self.show_goto_btn_mojie_1=self:FindVariable("ShowGotoBtn_Mojie_1")
	self.show_goto_btn_mojie_2=self:FindVariable("ShowGotoBtn_Mojie_2")
	self.show_goto_btn_mojie_3=self:FindVariable("ShowGotoBtn_Mojie_3")
	self.show_goto_btn_mojie_4=self:FindVariable("ShowGotoBtn_Mojie_4")
	self.mojie_rep_list = {}
	for i = 1, 4 do
		self:ListenEvent("GoToTreasure"..i,BindTool.Bind(self.GoToTreasure, self, i))
		self.mojie_rep_list[i] = self:FindVariable("mojie_rep_"..i)
	end

	self.tower_mojie_list = {}

	self:Init()

	self.mojie_info_event = BindTool.Bind(self.UpdateMojieData, self)
	MojieData.Instance:AddListener(MojieData.MOJIE_EVENT, self.mojie_info_event)


	-- 显示、隐藏信息Toggle
	self.info_toggle = self:FindObj("InfoToggle").toggle
	self.info_toggle.isOn = true
	self.info_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))


	self:ListenEvent("SwitchToShenEquip",BindTool.Bind(self.SwitchToShenEquip, self))
	self:ListenEvent("OpenMojie",BindTool.Bind(self.HandleOpenMojie, self))
	self:ListenEvent("OpenCheckEquipView",BindTool.Bind(self.HandleOpenCheckEquipView, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)


	RemindManager.Instance:Bind(self.remind_change, RemindName.Mojie)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ShenEquip)
end

function PlayerEquipView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)

	if EquipData.Instance ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		self.equip_data_change_fun = nil
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
		self.equip_datalist_change_fun = nil
	end
	if MojieData.Instance then
		MojieData.Instance:RemoveListener(MojieData.MOJIE_EVENT, self.mojie_info_event)
	end
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	for k, v in pairs(self.spec_cells) do
		v:DeleteMe()
	end
	self.parent_view = nil
	self.spec_cells = {}

	self.show_shen_equip_btn = nil

	for k, v in pairs(self.tower_mojie_list) do
		v:DeleteMe()
	end
	self.tower_mojie_list = nil
	self.tower_mojie_scroller = nil
end

function PlayerEquipView:OpenCallBack()
	if self.is_opening then
		return
	end
	self.is_opening = true
	if self.equip_data_change_fun == nil then
		self.equip_data_change_fun = BindTool.Bind1(self.OnEquipDataChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change_fun)
	end
	if self.equip_datalist_change_fun == nil then
		self.equip_datalist_change_fun = BindTool.Bind1(self.OnEquipDataListChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_datalist_change_fun, true)
	end

	self:OnEquipDataChange()

	if self.show_shen_equip_btn then
		local flag = OpenFunData.Instance:CheckIsHide("shenzhuang")
		self.show_shen_equip_btn:SetValue(flag)
	end
	self:InitTowerMojieScroller()
	self.tower_mojie_scroller.scroller:ReloadData(0)
end

function PlayerEquipView:CloseCallBack()
	if not self.is_opening then
		return
	end

	self.is_opening = false
	if self.equip_data_change_fun ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		self.equip_data_change_fun = nil
	end
	if self.equip_datalist_change_fun ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
		self.equip_datalist_change_fun = nil
	end
end

function PlayerEquipView:OnToggleChange(is_on)
	for k, v in pairs(self.cells) do
		v:SetInfoState(is_on)
	end
end

function PlayerEquipView:HandleOpenMojie()
	ViewManager.Instance:Open(ViewName.Mojie)
end

function PlayerEquipView:HandleOpenCheckEquipView()
	PlayerCtrl.Instance:OpenCheckEquipView()
end

--初始化爬塔魔戒滚动条
function PlayerEquipView:InitTowerMojieScroller()
	self.tower_mojie_scroller = self:FindObj("MojieScroller")
	local list_view_delegate = self.tower_mojie_scroller.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function PlayerEquipView:GetNumberOfCells()
	return FuBenData.Instance:GetActiveTowerMojieNumber() 	--魔戒激活数目
end

--滚动条刷新
function PlayerEquipView:RefreshView(cell, data_index)
	local mojie_cell = self.tower_mojie_list[cell]
	if mojie_cell == nil then
		mojie_cell = PlayerEquipTowerMojieInfo.New(cell.gameObject)
		self.tower_mojie_list[cell] = mojie_cell
	end
	mojie_cell:SetData(self:GetNumberOfCells() - data_index)
end


function PlayerEquipView:GoToTreasure(index)
	--if MojieData.Instance:IsShowMojieRedPoint(index - 1) then
	ViewManager.Instance:Open(ViewName.Mojie, index)
	--else
	--	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
	--end
end

function PlayerEquipView:ItemGoToTreasure()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
end

--主角身上的装备发生变化
function PlayerEquipView:OnEquipDataChange(item_id, index, reason)
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

--主角身上的列表装备变化
function PlayerEquipView:OnEquipDataListChange()
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

function PlayerEquipView:SetPlayerData(t)
	local equiplist = EquipData.Instance:GetDataList()
	self:SetData(equiplist)
end

function PlayerEquipView:UpdateMojieData()
	for k,v in pairs(self.spec_cells) do
		local data = MojieData.Instance:GetOneMojieInfo(k - 1)
		v:SetData(data)
		v:ListenClick(BindTool.Bind(self.OnClickMojieItem, self, k, data, v))
		v:SetItemActive(data.mojie_level > 0)
		v:ShowQuality(data.mojie_level > 0)
		v:SetDefualtBgState(false)

		local GoToTreasure=self:FindVariable("ShowGotoBtn_Mojie_"..k)
		if data.mojie_level==0 then
			GoToTreasure:SetValue(true)
        else
        	GoToTreasure:SetValue(false)
        end
	end
end

function PlayerEquipView:SetData(equiplist)
	for k, v in pairs(self.cells) do
		local data = equiplist[k - 1]
		if data and data.item_id then
			v:SetData(data)
			if GameEnum.EQUIP_INDEX_JIEZHI == (k - 1) then
				self.show_goto_btn_1:SetValue(false)
			end
			if GameEnum.EQUIP_INDEX_JIEZHI_2 == (k - 1) then
				self.show_goto_btn_2:SetValue(false)
			end

		elseif k == TIANSHI_INDEX then
			data = PlayerData.Instance:GetTianShiInfo()
			v:SetData(data)
			if nil == data or data.item_id == 0 then
				v:SetIcon(ResPath.GetRoleEquipDefualtIcon(Defult_Icon_List[k]))
			end

		elseif k == EMO_INDEX then
			data = PlayerData.Instance:GetEmoInfo()
			v:SetData(data)
			if nil == data or data.item_id == 0 then
				v:SetIcon(ResPath.GetRoleEquipDefualtIcon(Defult_Icon_List[k]))
			end

		else
			data = nil
			if GameEnum.EQUIP_INDEX_JIEZHI == (k - 1) then
				self.show_goto_btn_1:SetValue(true)
			end
			if GameEnum.EQUIP_INDEX_JIEZHI_2 == (k - 1) then
				self.show_goto_btn_2:SetValue(true)
			end
			v:SetData()
			v:SetIcon(ResPath.GetRoleEquipDefualtIcon(Defult_Icon_List[k]))
		end

		v:ListenClick(BindTool.Bind(self.OnClickItem, self, k, data, v))
	end
end

function PlayerEquipView:Init()
	for i = 1, #Defult_Icon_List do
		local item = EquipItemCell.New(self:FindObj("Item"..i))
		self.cells[i] = item
	end
	for i = 1, MOJIE_MAX_TYPE do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("SpecItem"..i))
		item:SetDefualtBgState(false)
		item:SetQualityState(2)
		self.spec_cells[i] = item
	end
	-- self:SetPlayerData(PlayerData.Instance.role_vo)
	self:UpdateMojieData()
end

function PlayerEquipView:SwitchToShenEquip()
	self.parent_view:OnSwitchToShenEquip(true)
end

function PlayerEquipView:OnClickMojieItem(index, data, cell)
	data.index = index
	local close_callback = function ()
		cell:SetHighLight(false)
	end
	cell:SetHighLight(false)
	--TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
	ViewManager.Instance:Open(ViewName.Mojie, index)  --切换成跳转到仙戒面板
end

function PlayerEquipView:OnClickItem(index, data, cell)
	if data == nil or not next(data) then
		if index == GOUYU_INDEX_1 then
			ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
		elseif index == GOUYU_INDEX_2 then
			ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
		elseif index == TIANSHI_INDEX or index == EMO_INDEX then
			ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_chengzhang)
		elseif index ~= JIEZHI_INDEX_1 and index ~= JIEZHI_INDEX_2 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
		end
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		if index == GOUYU_INDEX_1 then
			ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
		elseif index == GOUYU_INDEX_2 then
			ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
		elseif index == TIANSHI_INDEX or index == EMO_INDEX then
			ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_chengzhang)
		elseif index ~= JIEZHI_INDEX_1 and index ~= JIEZHI_INDEX_2 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
		end
		return
	end
	local close_callback = function ()
		cell:SetHightLight(false)
	end
	if data.param then
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local shen_info = EquipmentShenData.Instance:GetEquipData(equip_index)
		data.param.angel_level = shen_info and shen_info.level or 0
	end
	TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
end

function PlayerEquipView:RemindChangeCallBack(remind_name, num)
	if remind_name and num then
		if RemindName.Mojie == remind_name and self.show_mojie_red_point then
			self.show_mojie_red_point:SetValue(num > 0)
		elseif RemindName.ShenEquip == remind_name and self.show_shen_equip_red_point then
			self.show_shen_equip_red_point:SetValue(num > 0)
		end
	end
	for i=1, 4 do
		if self.mojie_rep_list[i] then
			self.mojie_rep_list[i]:SetValue(MojieData.Instance:IsShowMojieRedPoint(i - 1))
		end
	end
end

function PlayerEquipView:FlushImpGuardEquip()
	for k, v in ipairs(self.cells) do
		if k == TIANSHI_INDEX then
			local data = PlayerData.Instance:GetTianShiInfo()
			v:SetData(data)
			if nil == data or data.item_id == 0 then
				v:SetIcon(ResPath.GetRoleEquipDefualtIcon(Defult_Icon_List[k]))
			end

			v:ListenClick(BindTool.Bind(self.OnClickItem, self, k, data, v))
		elseif k == EMO_INDEX then
			local data = PlayerData.Instance:GetEmoInfo()
			v:SetData(data)
			if nil == data or data.item_id == 0 then
				v:SetIcon(ResPath.GetRoleEquipDefualtIcon(Defult_Icon_List[k]))
			end

			v:ListenClick(BindTool.Bind(self.OnClickItem, self, k, data, v))
		end
	end
end

function PlayerEquipView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "imp_guard" then
			self:FlushImpGuardEquip()
		end
	end
end

EquipItemCell = EquipItemCell or BaseClass(BaseRender)

function EquipItemCell:__init(instance)
	self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
	self.show_star_list = {}
	for i = 1, 3 do
		self.show_star_list[i] = self:FindVariable("ShowStar"..i)
	end
	self.grade = self:FindVariable("Grade")
	self.strengthen = self:FindVariable("Strengthen")
	self.show_grade = self:FindVariable("ShowGrade")
	self.show_strengthen = self:FindVariable("ShowStrengthen")
	self.show_remind = self:FindVariable("ShowRemind")
	self.show_limit = self:FindVariable("ShowLimit")
	self.active_star_num = 0
	self.is_show_strength = true
	self.is_show_grade = true
end

function EquipItemCell:__delete()

end

function EquipItemCell:Reset()
	self.icon:ResetAsset()
	self.quality:ResetAsset()
	self.show_grade:SetValue(false)
	self.show_strengthen:SetValue(false)
	if self.show_limit then
		self.show_limit:SetValue(false)
	end
	for i = 1, 3 do
		self.show_star_list[i]:SetValue(false)
	end

	if self.show_remind then
		self.show_remind:SetValue(false)
	end
end

function EquipItemCell:SetData(data)
	self.data = data
	if nil == data
		or nil == next(data) then
		self:Reset()
		return
	end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		self:Reset()
		return
	end

	self:SetStrength(data)
	self:SetStars(data)
	self:SetGrade(data, item_cfg)
	self:SetQuality(item_cfg)
	self:SetRemind(item_cfg)

	if self.show_limit then
		if data.invalid_time and data.invalid_time > 0 then
			self.show_limit:SetValue(true)
			self.show_grade:SetValue(false)
		else
			self.show_limit:SetValue(false)
		end
	end

	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self:SetIcon(bundle, asset)
end

function EquipItemCell:SetGrade(data, item_cfg)
 	self.show_grade:SetValue(self.is_show_grade and item_cfg.color < GameEnum.EQUIP_COLOR_PINK)
 	self.grade:SetValue((item_cfg.order or "") .. Language.Common.Jie)
end

function EquipItemCell:SetRemind(item_cfg)
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	-- 等级不低于130 出现可装备阶数是否为最大阶数提示
	if self.show_remind and main_role_lv >= 130 then
		self.show_remind:SetValue(item_cfg.order < max_order)
	end
end

function EquipItemCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then return end
	self.icon:SetAsset(bundle, asset)
end

function EquipItemCell:SetStrength(data)
	if nil == data.param then
		self.strengthen:SetValue(0)
		self.show_strengthen:SetValue(false)
		return
	end
	local strength_level = data.param.strengthen_level or 0
	self.show_strengthen:SetValue(self.is_show_strength and strength_level > 0)
	self.strengthen:SetValue(strength_level)
end

function EquipItemCell:SetQuality(item_cfg)
	local bundle1, asset1 = ResPath.GetRoleEquipQualityIcon(item_cfg.color)
	self.quality:SetAsset(bundle1, asset1)
end

function EquipItemCell:SetStars(data)
	self.active_star_num = 0

	if nil ~= data.param and nil ~= data.param.xianpin_type_list then
		for k, v in pairs(data.param.xianpin_type_list) do
			if v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if legend_cfg ~= nil and legend_cfg.color == 1 then
					self.active_star_num = self.active_star_num + 1
					if self.show_star_list[self.active_star_num] then
						self.show_star_list[self.active_star_num]:SetValue(true)
					end
				end
			end
		end
	end

	for i = self.active_star_num + 1, 3 do
		self.show_star_list[i]:SetValue(false)
	end
end

function EquipItemCell:SetHightLight(value)
	if nil == self.root_node.toggle then return end
	self.root_node.toggle.isOn = value
end

function EquipItemCell:SetInfoState(value)
	if nil == self.data
		or nil == self.data.param then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local strength_level = self.data.param.strengthen_level or 0
	if value then
		if self.active_star_num > 0 then
			for i = 1, self.active_star_num do
				self.show_star_list[i]:SetValue(true)
			end
		end
	else
		for i = 1, 3 do
			self.show_star_list[i]:SetValue(false)
		end
	end

	self.show_grade:SetValue(value)
	self.show_strengthen:SetValue(value and strength_level > 0)
end

function EquipItemCell:ShowStrengthLable(enable)
	if self.show_strengthen then
		self.is_show_strength = enable
		self.show_strengthen:SetValue(enable)
	end
end

function EquipItemCell:ShowGrade(enable)
	if self.show_grade then
		self.is_show_grade = enable
		self.show_grade:SetValue(enable)
	end
end

function EquipItemCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function EquipItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function EquipItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

--------------------------------------- 动态生成info ----------------------------------------------
PlayerEquipTowerMojieInfo = PlayerEquipTowerMojieInfo or BaseClass(BaseRender)

function PlayerEquipTowerMojieInfo:__init()
	self.mojie_icon = self:FindVariable("mojie_icon")
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClick, self))
	self.index = 1
end

function PlayerEquipTowerMojieInfo:__delete()
end

function PlayerEquipTowerMojieInfo:SetData(index)
	self.index = index
	self:SetIcon(index)
end
-- 设置魔戒Icon
function PlayerEquipTowerMojieInfo:SetIcon(index)
   local bundle, asset = ResPath.GetTowerMojieIcon(index)
   self.mojie_icon:SetAsset(bundle, asset)
end

function PlayerEquipTowerMojieInfo:OnClick()
	ViewManager.Instance:Open(ViewName.TowerMoJieView, self.index - 1)
end