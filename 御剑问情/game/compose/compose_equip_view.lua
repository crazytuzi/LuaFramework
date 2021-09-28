ComposeEquipView = ComposeEquipView or BaseClass(BaseRender)

local compose_equip_index_list = {
	GameEnum.EQUIP_TYPE_TOUKUI - 100,
	GameEnum.EQUIP_TYPE_YIFU - 100,
	GameEnum.EQUIP_KUZI - 100,
	GameEnum.EQUIP_TYPE_XIEZI - 100,
	GameEnum.EQUIP_TYPE_HUSHOU - 100,
	GameEnum.EQUIP_TYPE_XIANGLIAN - 100,
	GameEnum.EQUIP_TYPE_WUQI - 100,
	GameEnum.EQUIP_TYPE_YAODAI - 100,
}

function ComposeEquipView:__init()
	self.select_parent_index = 1
	self.select_child_index = 1
	self.cell_click_call_back = BindTool.Bind(self.CellClickCallBack, self)

	self.compose_cell_data = nil
	self.stuff_cell_data = nil
	self.cell_list = {}
	self.compose_cfg_list = ComposeData.Instance:GetComposeCfgList(ComposeData.Type.equip) or {}

	self.select_btn_list = {}
	for i = 1, #self.compose_cfg_list do
		local info = {}
		info.obj = self:FindObj("select_" .. i)
		info.list_obj = self:FindObj("list_" .. i)
		info.obj.accordion_element:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, i))
		info.text = self:FindVariable("select_text_" .. i)
		table.insert(self.select_btn_list, info)
	end

	self.effect_root = self:FindObj("effect_root")

	self.compose_item = ItemCell.New()
	self.compose_item:SetInstanceParent(self:FindObj("compose_item"))

	self.stuff_item_1 = ItemCell.New()
	self.stuff_item_1:SetInstanceParent(self:FindObj("stuff_item_1"))

	self.stuff_item_2 = ItemCell.New()
	self.stuff_item_2:SetInstanceParent(self:FindObj("stuff_item_2"))

	self.compose_name = self:FindVariable("compose_name")
	self.show_add_1 = self:FindVariable("show_add_1")
	self.show_add_2 = self:FindVariable("show_add_2")
	self.show_toggle_count = self:FindVariable("show_toggle_count")

	self:ListenEvent("ClickCompose", BindTool.Bind(self.ClickCompose, self))
	self:ListenEvent("ClickAdd1", BindTool.Bind(self.ClickAdd, self, 1))
	self:ListenEvent("ClickAdd2", BindTool.Bind(self.ClickAdd, self, 2))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
end

function ComposeEquipView:__delete()
	if self.compose_item then
		self.compose_item:DeleteMe()
		self.compose_item = nil
	end

	if self.stuff_item_1 then
		self.stuff_item_1:DeleteMe()
		self.stuff_item_1 = nil
	end

	if self.stuff_item_2 then
		self.stuff_item_2:DeleteMe()
		self.stuff_item_2 = nil
	end

	for _, v1 in pairs(self.cell_list) do
		for _, v2 in pairs(v1) do
			v2:DeleteMe()
		end
	end
	self.cell_list = nil
end

function ComposeEquipView:OnToggleChange(index, is_on)
	if is_on then
		self.select_parent_index = index
		self.select_child_index = 1

		self:ClearStuff()
		self:FlushView()
	end
end

function ComposeEquipView:ClickCompose()
	if nil == self.compose_cell_data then
		return
	end

	if nil == self.stuff_cell_data or not self.stuff_cell_data[1] or not self.stuff_cell_data[2] then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.ComposeStuffInsufficient)
		return
	end

	local compose_item_cfg = ItemData.Instance:GetItemConfig(self.compose_cell_data.item_id)
	if nil == compose_item_cfg then
		SysMsgCtrl.Instance:ErrorRemind("?!?!?!?!?!?!?!?!?!?!")
		return
	end

	--获取目标装备可放置的装备index
	local target_equipment_index = EquipData.Instance:GetEquipIndexByType(compose_item_cfg.sub_type)

	local stuff_knapsack_index_list = {}
	for k, v in pairs(self.stuff_cell_data) do
		stuff_knapsack_index_list[k] = v.index
	end

	ComposeCtrl.Instance:RedColorEquipCompose(stuff_knapsack_index_list, 2, target_equipment_index)
end

function ComposeEquipView:ClickAdd(item_index)
	local compose_data = self.compose_cfg_list[self.select_parent_index]
	if nil == compose_data then
		return
	end

	--可剔除列表
	local ignore_index_list = {}
	for _, v in pairs(self.stuff_cell_data or {}) do
		ignore_index_list[v.index] = true
	end

	local list = nil
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if compose_data.star_num > 0 then
		list = ForgeData.Instance:GetEquipListByGradeAndStar(main_vo.prof, compose_data.eq_grade, compose_data.star_num - 1, ignore_index_list)
	else
		list = ForgeData.Instance:GetEquipListByGradeAndStar(main_vo.prof, compose_data.eq_grade - 1, compose_data.star_num + 1, ignore_index_list)
	end

	local function callback(data)
		if not ViewManager.Instance:IsOpen(ViewName.Compose) then
			return
		end

		if nil == self.stuff_cell_data then
			self.stuff_cell_data = {}
		end
		self.stuff_cell_data[item_index] = data

		self["stuff_item_" .. item_index]:SetData(data)
		self["show_add_" .. item_index]:SetValue(false)
	end
	ComposeCtrl.Instance:OpenSelectEquipView(list, callback)
end

function ComposeEquipView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(279)
end

--清除材料
function ComposeEquipView:ClearStuff()
	self.stuff_cell_data = nil

	self.stuff_item_1:SetData(nil)
	self.stuff_item_2:SetData(nil)

	self.show_add_1:SetValue(true)
	self.show_add_2:SetValue(true)
end

--is_compose是否合成回调
function ComposeEquipView:FlushView(is_compose)
	if is_compose then
		self:ClearStuff()
		self:PlayUpStarEffect()
	end

	local compose_data = self.compose_cfg_list[self.select_parent_index]
	if nil == compose_data then
		return
	end

	local cell = self.cell_list[self.select_parent_index] and self.cell_list[self.select_parent_index][self.select_child_index]
	if nil == cell then
		return
	end

	cell:SetToggleIsOn(true)
	local cell_data = cell:GetData()

	local star = compose_data.star_num
	self.compose_cell_data = ItemData.Instance:GetTempItemDataByStar(cell_data.item_id, star)
	self.compose_item:SetData(self.compose_cell_data)

	local name = ""
	local item_cfg = ItemData.Instance:GetItemConfig(cell_data.item_id)
	if item_cfg then
		name = item_cfg.name
	end
	self.compose_name:SetValue(name)
end

function ComposeEquipView:InitView()
	self.select_parent_index = 1
	self.select_child_index = 1

	self:ClearStuff()

	--设置总按钮量
	self.show_toggle_count:SetValue(#self.compose_cfg_list)

	local info = nil
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.compose_cfg_list) do
		info = self.select_btn_list[k]
		if info then
			info.text:SetValue(v.sub_name)

			--创造子按钮
			self:LoadCell(k, main_vo.prof, v.eq_grade)
		end
	end

	if self.cell_list[#self.compose_cfg_list] then
		--说明已经加载完毕了，重新选择第一个
		self.select_btn_list[self.select_parent_index].obj.accordion_element.isOn = true
	end

	self:FlushView()
end

function ComposeEquipView:LoadCell(index, prof, grade)
	--已经加载过了
	if self.cell_list[index] then
		return
	end

	local list = ForgeData.Instance:GetEquipComponseCfgList(prof, grade)
	if nil == list then
		return
	end

	self.cell_list[index] = {}
	PrefabPool.Instance:Load(AssetID("uis/views/composeview_prefab", "ItemType"), function (prefab)
		if nil == prefab then
			return
		end
		-- 8个装备部位
		local obj = nil
		local cell = nil
		local item_id = nil
		for k, v in ipairs(compose_equip_index_list) do
			item_id = list["equip_index_" .. v] or 0
			obj = GameObject.Instantiate(prefab)
			obj.transform:SetParent(self.select_btn_list[index].list_obj.transform, false)
			cell = EquipComposeItem.New(obj)
			cell:SetToggleGroup(self.select_btn_list[index].list_obj.toggle_group)
			cell:SetClickCallBack(self.cell_click_call_back)
			cell:SetToggleIsOn(self.select_child_index == k)
			cell:SetIndex(k)
			cell:SetData({item_id = item_id})

			self.cell_list[index][k] = cell
		end

		if index == #self.compose_cfg_list then
			--第一次进入默认选择对应父按钮
			self.select_btn_list[self.select_parent_index].obj.accordion_element.isOn = true
		end

		PrefabPool.Instance:Free(prefab)
	end)
end

function ComposeEquipView:CellClickCallBack(cell)
	if nil == cell then
		return
	end

	local index = cell:GetIndex()
	if index == self.select_child_index then
		return
	end

	self.select_child_index = index

	self:FlushView()
end

function ComposeEquipView:PlayUpStarEffect()
	EffectManager.Instance:PlayAtTransformCenter(
		"effects2/prefab/ui/ui_jinengshengji_1_prefab",
		"UI_Jinengshengji_1",
		self.effect_root.transform,
		2.0)
end

EquipComposeItem = EquipComposeItem or BaseClass(BaseCell)
function EquipComposeItem:__init()
	self.name = self:FindVariable("Name")
	self.num = self:FindVariable("Num")
	self.num:SetValue("")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function EquipComposeItem:__delete()
end

function EquipComposeItem:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function EquipComposeItem:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function EquipComposeItem:OnFlush()
	if nil == self.data then
		return
	end

	local name = ""
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg then
		name = item_cfg.name
	end
	self.name:SetValue(name)
end