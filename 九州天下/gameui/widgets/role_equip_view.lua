----------------------------------------------------
-- 角色信息展示带装备，带展示。如人物面板上的
----------------------------------------------------
RoleEquipView = RoleEquipView or BaseClass()

function RoleEquipView:__init()
	self.from_view = TipsFormDef.FROM_BAG_EQUIP
	self.role_view_index = -1
	self.select_index = GameEnum.EQUIP_INDEX_WUQI 		--默认第一个装备
	self.click_callback_list = {}

	self.cell_list = {}
	self.cell_data_list = {}
	self.cell_toggle_list = {}
	self.equip_pos = RoleEquipView.InitIndexToPos()

	self.equip_data_change_fun = BindTool.Bind1(self.OnEquipDataChange, self)
	self.equip_datalist_change_fun = BindTool.Bind1(self.OnEquipDataListChange, self)
end

function RoleEquipView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}
	self.cell_data_list = {}
	self.click_callback_list = {}
	self.cell_toggle_list = {}
	self.role_view_index = -1

	if EquipData.Instance then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
	end
end

function RoleEquipView.InitIndexToPos()
	--装备Index（左）对应界面item 位置
	local tb = {}
	tb[GameEnum.EQUIP_INDEX_WUQI] = 1
	tb[GameEnum.EQUIP_INDEX_TOUKUI] = 2
	tb[GameEnum.EQUIP_INDEX_XIANLIAN2] = 3
	tb[GameEnum.EQUIP_INDEX_XIANLIAN1] = 4
	tb[GameEnum.EQUIP_INDEX_YIFU] = 5
	tb[GameEnum.EQUIP_INDEX_HUSHOU] = 6
	tb[GameEnum.EQUIP_INDEX_HUTUI] = 7
	tb[GameEnum.EQUIP_INDEX_XIEZI] = 8
	tb[GameEnum.EQUIP_JIEZHI_2] = 9
	tb[GameEnum.EQUIP_JIEZHI_1] = 10
	return tb
end

function RoleEquipView.InitPosToIndex()
	--界面item 位置对应装备Index
	local tb = {}
	tb[1] = GameEnum.EQUIP_INDEX_WUQI
	tb[2] = GameEnum.EQUIP_INDEX_TOUKUI
	tb[3] = GameEnum.EQUIP_INDEX_XIANLIAN2
	tb[4] = GameEnum.EQUIP_INDEX_XIANLIAN1
	tb[5] = GameEnum.EQUIP_INDEX_YIFU
	tb[6] = GameEnum.EQUIP_INDEX_HUSHOU
	tb[7] = GameEnum.EQUIP_INDEX_HUTUI
	tb[8] = GameEnum.EQUIP_INDEX_XIEZI
	tb[9] = GameEnum.EQUIP_JIEZHI_2
	tb[10] = GameEnum.EQUIP_JIEZHI_1
	return tb
end

local function getEquipIndex(self, obj_index)
	for index, v in pairs(self.equip_pos) do
		if v == obj_index then
			return index
		end
	end
end

local function getObjIndex(self, equip_index)
	for index, v in pairs(self.equip_pos) do
		if index == equip_index then
			return v
		end
	end
end

local function getEquipStr(self, equip_index)
	return Language.EquipTypeToName[equip_index] or ""
end

function RoleEquipView:Init(prefabs, from_view)
	if prefabs == nil then
		return
	end
	self.from_view = from_view or TipsFormDef.FROM_BAG_EQUIP

	self.cell_list = {}
	self.cell_data_list = {}

	for obj_index, prefab in pairs(prefabs) do
		local equip_index = getEquipIndex(self, obj_index)
		if equip_index ~= nil then
			local cell = ItemCell.New(prefab)
			cell:SetIndex(equip_index)

			local iconname = EquipData.GetEquipBg(equip_index)
			cell:SetBg(iconname)

			local equip_str = getEquipStr(self, equip_index)
			cell:SetBgText(equip_str)

			cell:AddClickEventListener(BindTool.Bind(self.OnClick, self, equip_index))

			cell:SetSelect(false)
			self.cell_list[equip_index] = cell
		end
	end
end

function RoleEquipView:OnClick(equip_index)
	self:ClickEquipSlot(equip_index)

	local call_back = self.click_callback_list[self.role_view_index]
	if call_back == nil then
		local data = self.cell_data_list[equip_index]
		if data == nil then
			print_log("data == nil")
			return
		end
		TipsCtrl.Instance:OpenItem(data, self.from_view)
	else
		call_back()
	end
end

--主角身上的装备变化
function RoleEquipView:OnEquipDataChange(item_id, index, reason)
	print("OnEquipDataChange 主角身上的装备变化")
	local item_data = EquipData.Instance:GetGridData(index)
	self.cell_data_list[index] = item_data

	local cell = self.cell_list[index]
	if nil ~= cell then
		cell:SetData(item_data)
		cell:SetLockFill(self:CheckIsLock(item_data))

		if item_data == nil and cell ~= nil then
			local iconname = EquipData.GetEquipBg(index)
			cell:SetBg(iconname)

			local equip_str = getEquipStr(self, index)
			cell:SetBgText(equip_str)
		end
	end
end

--主角身上的列表装备变化
function RoleEquipView:OnEquipDataListChange()
	print("OnEquipDataListChange 主角身上的列表装备变化")
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

function RoleEquipView:ClickEquipSlot(equip_index)
	for k, v in pairs(self.cell_list) do
		if equip_index == k then
			v:SetSelect(true)
		else
			v:SetSelect(false)
		end
	end
	self.select_index = equip_index
end

function RoleEquipView:SetViewIndex(index)
	print("SetViewIndex 执行了")
	if self.role_view_index == index then
		return
	end
	self.role_view_index = index
	self:CheckAllIsLock()
end

function RoleEquipView:SetClickCallBack(view_index, call_back)
	print("执行了 SetClickCallBack")
	if self.click_callback_list[view_index] == nil then
		self.click_callback_list[view_index] = call_back
	end
end

function RoleEquipView:GetSelectIndex()
	return self.select_index
end

function RoleEquipView:CheckAllIsLock()
	for k, v in pairs(self.cell_data_list) do
		local cell = self.cell_list[k]
		if cell ~= nil then
			cell:SetLockFill(self:CheckIsLock(v))
		end
	end
end

function RoleEquipView:CheckIsLock(data)
	-- if self.role_view_index == TabIndex.equipment_fuling then
	-- 	local flag, remind = ForgeData.Instance:GetIsCanFuling(data)
	-- 	if flag < 0 then
	-- 		return true
	-- 	end
	-- end
	-- return false
end

--设置人物数据
function RoleEquipView:SetPlayerData(t)
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
	EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change_fun)
	EquipData.Instance:NotifyDataChangeCallBack(self.equip_datalist_change_fun,true)
end

function RoleEquipView:SetData(equip_list)
	if nil == equip_list then
		return
	end
	local tb = {}
	for _, equip in pairs(equip_list) do
		local index = equip.index
		self.cell_data_list[index] = equip
		local cell = self.cell_list[index]
		if nil ~= cell then
			tb[index] = 1
			cell:SetData(equip)
			cell:SetLockFill(self:CheckIsLock(equip))
			cell:SetBgActivity(equip == nil)
		end
	end

	for equip_index, obj_index in pairs(self.equip_pos) do
		if tb[equip_index] == nil then
			local cell = self.cell_list[equip_index]
			if cell ~= nil then
				local iconname = EquipData.GetEquipBg(equip_index)
				cell:SetBg(iconname)

				local equip_str = getEquipStr(self, equip_index)
				cell:SetBgText(equip_str)
			end
		end
	end
end
