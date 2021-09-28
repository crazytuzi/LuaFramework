--无双装备
TianshenhutiInfoView = TianshenhutiInfoView or BaseClass(BaseRender)
local Defult_Icon_List = {
	[1] = "icon_shouzhuo",
	[2] = "icon_hushou",
	[3] = "icon_xianglian",
	[4] = "icon_jiezhi",
	[5] = "icon_yifu",
	[6] = "icon_yaodai",
	[7] = "icon_xiezi",
	[8] = "icon_toukui",
}

local EQUIO_SORT = {8, 1, 5, 3, 6, 2, 7, 4}
-- 常亮定义
local BAG_MAX_GRID_NUM = 100			-- 最大格子数
local BAG_PAGE_NUM = 8					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 4					-- 列数
function TianshenhutiInfoView:__init()
	self.tz_index = 0
	self.equip_list = {}
	local equip_parent = self:FindObj("EquipParent")
	local item = nil
	for i = 1,GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT do
		item = TianshenhutiEquipItemCell.New()
		item:SetInstanceParent(equip_parent)
		item:SetToggleGroup(equip_parent.toggle_group)
		item:ShowDefaulBg(false)
		local index = EQUIO_SORT[i] or 0
		item:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, item, index - 1))
		self.equip_list[index] = item
	end

	-- 获取控件
	self.bag_data_list = {}
	self.bag_list_view = self:FindObj("BagList")
	self.bag_cell = {}
	local list_delegate = self.bag_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.role_display = self:FindObj("Display")
	self.role_model = RoleModel.New("player_view_panel")
	self.role_model:SetDisplay(self.role_display.ui3d_display)

	self:ListenEvent("OnClickAttrReview", BindTool.Bind(self.OnClickAttrReview, self))
	self:ListenEvent("OnClickSkill", BindTool.Bind(self.OnClickSkill, self))
	local tz_name = nil
	for i = 0, 3 do
		if i > 0 then
			tz_name = self:FindVariable("TzName" .. i)
			tz_name:SetValue(TianshenhutiData.Instance:GetTaozhuangTypeName(i))
		end
		self:ListenEvent("OnClickTz" .. i, BindTool.Bind(self.OnClickTz, self, i))
	end
	self.cap = self:FindVariable("Cap")
end

function TianshenhutiInfoView:__delete()
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
end

function TianshenhutiInfoView:OnClickAttrReview()
	TianshenhutiCtrl.Instance:OpenAttrView()
end
function TianshenhutiInfoView:OnClickSkill()
	ViewManager.Instance:Open(ViewName.TianShenHuTiSkillView)
end

function TianshenhutiInfoView:OnClickTz(index)
	self.tz_index = index
	self.need_jump = true
	self:Flush()
end

function TianshenhutiInfoView:OnClickEquipItem(cell, equip_index)
	local close_callback = function ()
		cell:SetHighLight(false)
	end
	TianshenhutiCtrl.Instance:ShowEquipTips(cell.data, TianshenhutiEquipTips.FromView.EquipView, close_callback)
end

function TianshenhutiInfoView:FlushBagList()
	for k,v in pairs(self.bag_list_view.list_view.ActiveCells:ToTable()) do
		if self.bag_cell[v] then
			self:RefreshCell(self.bag_cell[v])
		end
	end
end

function TianshenhutiInfoView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function TianshenhutiInfoView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = TianshenhutiEquipItemCell.New(cellObj)
		cell:SetToggleGroup(self.bag_list_view.toggle_group)
		self.bag_cell[cellObj] = cell
	end
	cell.local_index = index
	self:RefreshCell(cell)
end

--刷新格子
function TianshenhutiInfoView:RefreshCell(cell)
	local index = cell.local_index or 0
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN  + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	-- 获取数据信息
	local cell_data = self.bag_data_list[grid_index]
	local data = {}
	if cell_data and cell_data.item_id > 0 then
		data = cell_data
	end

	cell:SetData(data, true)
	cell:SetHighLight(false)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, data, cell))
	cell:SetInteractable(nil ~= data.item_id)
end

--点击格子事件
function TianshenhutiInfoView:HandleBagOnClick(data, cell)
	local close_callback = function ()
		cell:SetHighLight(false)
	end

	TianshenhutiCtrl.Instance:ShowEquipTips(cell.data, TianshenhutiEquipTips.FromView.BagView, close_callback)
end

function TianshenhutiInfoView:OpenCallBack()
	self.need_jump = true
	self:Flush()
	self:FlushFashion()
end

function TianshenhutiInfoView:CloseCallBack()

end

function TianshenhutiInfoView:OnFlush(param_t)
	local data = TianshenhutiData.Instance
	self.bag_data_list = data:GetBagListByType(self.tz_index)
	if next(self.bag_cell) ~= nil and (not self.need_jump or self.bag_list_view.list_page_scroll2:GetNowPage() == 0) then
		self:FlushBagList()
	else
		self.bag_list_view.list_view:Reload(function()
			self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
		end)
		self.bag_list_view.list_view:JumpToIndex(0)
		self.need_jump = false
	end
	local equip_info = data:GetEquipList()
	for k,v in pairs(self.equip_list) do
		v:SetData(equip_info[k - 1])
		v:SetInteractable(equip_info[k - 1] and equip_info[k - 1].item_id ~= 0)
		if equip_info[k - 1] == nil then
			v:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[k]))
		end
	end
	self.cap:SetValue(data:GetProtectEquipTotalCapability())
end

--数据改变时刷新
function TianshenhutiInfoView:FlushFashion(role_res_id, weapon_res_id)
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetRoleResid(role_res_id or main_role:GetRoleResId())
	if main_role.vo.prof == ROLE_PROF.PROF_3 then
		--逍遥用idle_n2动作
		self.role_model:SetBool("idle_n2", true)
	else
		self.role_model:SetBool("idle_n2", false)
	end
	self.role_model:SetWeaponResid(weapon_res_id or main_role:GetWeaponResId())
	self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
	self.role_model:SetWaistResid(main_role:GetWaistResId())
	self.role_model:SetTouShiResid(main_role:GetTouShiResId())
	self.role_model:SetQilinBiResid(main_role:GetQilinBiResId(), main_role.vo.sex)
end


------------------------------itemcell-----------------------------

TianshenhutiEquipItemCell = TianshenhutiEquipItemCell or BaseClass(BaseCell)

function TianshenhutiEquipItemCell:__init(instance)
	self.is_use_objpool = false

	if nil == self.root_node then
		local prefab = PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "TianshenhutiEquip")
		local u3dobj = U3DObject(GameObjectPool.Instance:Spawn(prefab, nil))
		self:SetInstance(u3dobj)
		self.is_use_objpool = true
	end
	self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
	self.tz_type = self:FindVariable("TzType")
	self.strengthen = self:FindVariable("Strengthen")
	self.show_strengthen = self:FindVariable("ShowStrengthen")
	self.show_remind = self:FindVariable("ShowRemind")
	self.show_up_arrow = self:FindVariable("ShowUpArrow")
	self.show_defual_bg = self:FindVariable("ShowDefualtBg")
	self.active_star_num = 0
	self.is_show_strength = true
	self.index = -1
	self:ClearEvent("Click")
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
	if self.is_use_objpool then
		self:Reset()
	end
end

function TianshenhutiEquipItemCell:__delete()
	self.show_defual_bg:SetValue(true)
	if self.is_use_objpool and not self:IsNil() then
		GameObjectPool.Instance:Free(self.root_node.gameObject)
	end
end

function TianshenhutiEquipItemCell:Reset()
	self.icon:ResetAsset()
	self.tz_type:ResetAsset()
	self.quality:ResetAsset()
	self.show_strengthen:SetValue(false)
	self.show_up_arrow:SetValue(false)
	if self.show_remind then
		self.show_remind:SetValue(false)
	end
	self:SetInteractable(true)
end

function TianshenhutiEquipItemCell:SetData(data)
	self.data = data
	if nil == data
		or nil == next(data) or data.item_id == 0 then
		self:Reset()
		return
	end
	local item_cfg = TianshenhutiData.Instance:GetEquipCfg(data.item_id)
	if nil == item_cfg then
		self:Reset()
		return
	end

	self:SetQuality(item_cfg)
	self.show_strengthen:SetValue(true)
	self.strengthen:SetValue(item_cfg.level)
	self.tz_type:SetAsset(ResPath.GetImages("tz_" .. item_cfg.taozhuang_type))
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self:SetIcon(bundle, asset)
end

function TianshenhutiEquipItemCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then return end
	self.icon:SetAsset(bundle, asset)
end

function TianshenhutiEquipItemCell:ShowUpArrow(value)
	if self.show_up_arrow then
		self.show_up_arrow:SetValue(value)
	end
end

function TianshenhutiEquipItemCell:ShowDefaulBg(value)
	if self.show_defual_bg then
		self.show_defual_bg:SetValue(value)
	end
end

function TianshenhutiEquipItemCell:SetQuality(item_cfg)
	local bundle1, asset1 = ResPath.GetRoleEquipQualityIcon(item_cfg.color)
	self.quality:SetAsset(bundle1, asset1)
end

function TianshenhutiEquipItemCell:SetDefualtQuality()
	local bundle1, asset1 = ResPath.GetRoleEquipQualityIcon(6)
	self.quality:SetAsset(bundle1, asset1)
end

function TianshenhutiEquipItemCell:SetHighLight(value)
	if nil == self.root_node.toggle then return end
	self.root_node.toggle.isOn = value
end

function TianshenhutiEquipItemCell:SetToggle(value)
	if nil == self.root_node.toggle then return end
	self.root_node.toggle.isOn = value
end

function TianshenhutiEquipItemCell:SetInfoState(value)
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

	self.show_strengthen:SetValue(value and strength_level > 0)
end

function TianshenhutiEquipItemCell:SetIndex(index)
	self.index = index
end

function TianshenhutiEquipItemCell:ShowStrengthLable(enable)
	if self.show_strengthen then
		self.is_show_strength = enable
		self.show_strengthen:SetValue(enable)
	end
end

function TianshenhutiEquipItemCell:SetInteractable(enable)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.interactable = enable
	end
end

function TianshenhutiEquipItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function TianshenhutiEquipItemCell:GetData()
	return self.data or {}
end

function TianshenhutiEquipItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function TianshenhutiEquipItemCell:SetToggleGroup(toggle_group)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.group = toggle_group
	end
end