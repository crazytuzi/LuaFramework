RoleEquipBar = RoleEquipBar or BaseClass(BaseRender)

--装备格列表和数据列表都是从0开始的
local cur_index = 0
function RoleEquipBar:__init()
	--LeftBar中被选中的Toggle
	self.role_view_index = 101
	--当前选中装备的编号和Data
	self.select_index = 0
	--装备条中格子点击后调用的函数
	self.click_callback_list = {}
	--装备条
	self.equip_list = {}
	self.equip_data = {}
	for i = 0, 9 do
		UtilU3d.PrefabLoad(
			"uis/views/forgeview_prefab",
			"EquipBarItem",
			function(obj)
				if self:IsNil() then
					return
				end

				obj.transform:SetParent(self.root_node.transform, false)
				obj = U3DObject(obj)
				local cell = EquipCell.New(obj)
				if self.equip_list[0] == nil then
					self.equip_list[0] = cell
				else
					table.insert(self.equip_list, cell)
				end
				cell.mother_view = self
				cell:SetToggleGroup(self.root_node.toggle_group)
				if #self.equip_list == 9 then
					self:RefreshEquipData()
					self:LoadEquipData()
					if cur_index ~= 0 then
						self:SetToggle(cur_index)
					end
				end
			end)
	end
end

function RoleEquipBar:__delete()
	for k, v in pairs(self.equip_list) do
		v:DeleteMe()
	end

	self.click_callback_list = {}
end

function RoleEquipBar:LoadEquipData()
	for k,v in pairs(self.equip_list) do
		--是否能强化/升品/神铸
		local can_improve, improve_type = ForgeData.Instance:CheckIsCanImprove(self.equip_data[k], self.role_view_index)
		if can_improve == 0 then
			self.equip_list[k].show_improve:SetValue(true)
		else
			self.equip_list[k].show_improve:SetValue(false)
		end

		self.equip_list[k]:SetData(self.equip_data[k])
		if not self.equip_data[k] or not self.equip_data[k].item_id then   --把没有装备的隐藏掉
			self.equip_list[k]:SetActive(false)
		else
			self.equip_list[k]:SetActive(true)
		end
	end
end

--得到选中物品的数据
function RoleEquipBar:GetSelectData()
	local data = self.equip_data[self.select_index]
	if data ~= nil then
		data.item_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")[data.item_id]
		return data
	end
end

-- 格子点击后的回调函数
function RoleEquipBar:OnClick(data_index)
	local data = self.equip_data[data_index]
	ForgeData.Instance:SetCurItemData(data)

	if self.select_index == data_index then
		return
	end

	-- if nil ~= ForgeStrengthen.Instance then
	-- 	ForgeStrengthen.Instance:SetEquipModel(data)
	-- end
	self.select_index = data_index
	local call_back = self.click_callback_list[self.role_view_index]
	if call_back ~= nil then
		call_back(data_index, data)
	end
end

-- 设定装备条格子点击后的回调函数
function RoleEquipBar:SetClickCallBack(view_index, call_back)
	if self.click_callback_list[view_index] == nil then
		self.click_callback_list[view_index] = call_back
	end
end

--更新装备条Data
function RoleEquipBar:RefreshEquipData()
	self.equip_data = {}
	local equip_data = EquipData.Instance:GetDataList()
	for i=0,COMMON_CONSTS.MAX_CAN_FORGE_EQUIP_NUM - 1 do
		self.equip_data[i] = equip_data[i] or {}
		self.equip_data[i].data_index = i
	end

end

function RoleEquipBar:SelectFirst()
	for i=0,COMMON_CONSTS.MAX_CAN_FORGE_EQUIP_NUM - 1 do
		local id = self.equip_data[i].item_id
		if self.role_view_index == TabIndex.forge_red_equip then
			if ForgeData.Instance:CheckEquipCanSelect(self.equip_data[i]) then
				self:SetToggle(i)
				return
			end
		else
			if id ~= nil and id ~= 0 then
				self:SetToggle(i)
				-- if nil ~= ForgeStrengthen.Instance then
				-- 	ForgeStrengthen.Instance:SetEquipModel(self.equip_data[i])
				-- end
				return
			end
		end
	end
end

function RoleEquipBar:SetToggle(index)
	cur_index = index
	if nil == self.equip_list[index] then return end
	for k,v in pairs(self.equip_list) do
		v.toggle.isOn = false
	end
	self.equip_list[index].toggle.isOn = false
	self.equip_list[index].toggle.isOn = true
	local call_back = self.click_callback_list[self.role_view_index]
	local data = self.equip_data[index]
	if call_back ~= nil then
		call_back(index, data)
	end
end

--主角的装备变化时
function RoleEquipBar:OnEquipDataChange()
	self:RefreshEquipData()
	self:LoadEquipData()

	local data = self.equip_data[self.select_index]
	if data and data.param and data.param.shen_level == 10 then
		if self.role_view_index == TabIndex.forge_cast then
			ForgeCast.Instcance:SetEquipModel(data)
		end
	end
end

function RoleEquipBar:GetCurSelectIndex()
	return self.select_index
end

-- 设定当前选择了哪个面板
function RoleEquipBar:SetViewIndex(index)
	self.role_view_index = index
	self:LoadEquipData()
end

--------------------------------------------------------------------------
--装备格子
--------------------------------------------------------------------------
EquipCell = EquipCell or BaseClass(BaseCell)
function EquipCell:__init()
	self.is_use_step_calc = true								-- 使用分步计算
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	-- self.item_cell:SetInteractable(true)
	self.item_cell:SetHighLight(false)
	self.item_cell:ListenClick(function()
		self.item_cell:SetHighLight(false)
		if self.data == nil or self.data.item_id == nil then
			 return
		end
		self.toggle.isOn = true
		end)
	-- self.item_cell:AddValueChangedListener(BindTool.Bind(self.OnValueChangeClick,self))
	self.toggle = self.root_node.toggle
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnValueChangeClick,self))
	self:ListenEvent("Click", BindTool.Bind(self.OnButtonClick, self))
	self.show_improve = self:FindVariable("show_improve")
	self.show_sheng_level = self:FindVariable("show_sheng_level")
	self.sheng_level = self:FindVariable("sheng_level")
	self.show_lock = self:FindVariable("ShowLock")
	self.equip_name = self:FindVariable("equip_name")
	self.show_sheng_level:SetValue(false)
end

function EquipCell:__delete()
	self.mother_view = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function EquipCell:ShowEmpty()
	if not self.toggle.interactable then
		return
	end
	self.toggle.interactable = false
	self.show_improve:SetValue(false)
	self.show_sheng_level:SetValue(false)

	local data_index = self.data.data_index
	local target_id = 0

	if data_index < 2 then			--TODO 目前没有指定的置灰图标
		target_id = data_index
	elseif data_index <= 5 then
		target_id = data_index + 1
	elseif data_index == 8 then
		target_id = 2
	elseif data_index == 9 then
		target_id = 9
	else
		target_id = data_index + 2
	end

	self.item_cell:SetIconGrayScale(false)
	self.item_cell:SetData()
	self.item_cell.icon:SetAsset(ResPath.GetItemIcon(target_id * 1000 + 100))
	self.show_lock:SetValue(false)
	self.equip_name:SetValue(Language.Forge.UnEquip)
	self.item_cell:SetIconGrayVisible(false)
	self.item_cell:NotShowStar()
end

function EquipCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function EquipCell:OnFlush()
	if self.data.item_id == nil then
		self:ShowEmpty()
		return
	end
	self.toggle.interactable = true

	--Toggle是否激活
	if self.mother_view.select_index == self.data.data_index then
		self.mother_view.root_node:GetComponent(typeof(UnityEngine.UI.ToggleGroup)):SetAllTogglesOff()
		self.toggle.isOn = false
		self.toggle.isOn = true
	else
		self.toggle.isOn = false
	end

	self.item_cell:SetData(self.data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.equip_name:SetValue(item_cfg.name)
	local role_view_index = self.mother_view.role_view_index
	if role_view_index == TabIndex.forge_red_equip then
		local value = ForgeData.Instance:CheckEquipCanSelect(self.data)
		self.item_cell:SetIconGrayVisible(not value)
		self.show_lock:SetValue(not value)
		self.item_cell:SetInteractable(true)
		-- self.item_cell:SetHighLight(self.toggle.isOn and value)
		self.item_cell:SetIconGrayScale(false)
--		self.toggle.isOn = true
		self.toggle.interactable = true
	else
		self.item_cell:SetInteractable(true)
		self.item_cell:SetIconGrayScale(false)
		self.show_lock:SetValue(false)
		self.item_cell:SetIconGrayVisible(false)
	end

	if role_view_index == TabIndex.forge_strengthen then
		if self.data.param.strengthen_level > 0 then
			self.item_cell.show_strength:SetValue(true)
		end
		self.show_sheng_level:SetValue(false)
	elseif role_view_index == TabIndex.forge_cast then
		self.item_cell.show_strength:SetValue(false)
		if self.data.param.shen_level > 0 then
			self.sheng_level:SetValue(Language.Forge.ShengLevel[self.data.param.shen_level])
			self.show_sheng_level:SetValue(true)
		end
	else
		self.show_sheng_level:SetValue(false)
		if self.data.param.strengthen_level > 0 then
			self.item_cell.show_strength:SetValue(true)
		end
	end
	--self.item_cell:NotShowStar()
end

function EquipCell:OnValueChangeClick(p_bool)
	if p_bool then
		self.mother_view:OnClick(self.data.data_index)
	end
end

function EquipCell:OnButtonClick()
	local role_view_index = self.mother_view.role_view_index
		if role_view_index == TabIndex.forge_red_equip then
			local value = ForgeData.Instance:CheckEquipCanSelect(self.data)
			if not value then
				TipsCtrl.Instance:ShowSystemMsg(Language.Forge.CanNotRed,3)
			end
	end
end




