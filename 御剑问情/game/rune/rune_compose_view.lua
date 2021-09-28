RuneComposeView = RuneComposeView or BaseClass(BaseRender)

local EFFECT_CD = 1
function RuneComposeView:__init()
	self.effect_obj = self:FindObj("EffectObj")

	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_list[i] = ItemCell.New(self:FindObj("ItemCell" .. i))
	end

	self.details0 = self:FindVariable("Details1")
	self.details1 = self:FindVariable("Details2")
	self.percent = self:FindVariable("Precent")
	self.combine_name = self:FindVariable("combine_name")
	self.show_details0 = self:FindVariable("ShowDetails1")
	self.show_details1 = self:FindVariable("ShowDetails2")

	for i = 1, 4 do
		self["need_num" .. i] = self:FindVariable("NeedNum" .. i)
		self["show_red_point" .. i] = self:FindVariable("ShowRedPoint" .. i)
	end

	self:ListenEvent("OnClickCompose", BindTool.Bind(self.OnClickCompose, self))

	-- 成功率写死100%
	self.percent:SetValue("100")
	self.select_id = 0
	self.defalut_id = 0

	self:CreatCell()
end

function RuneComposeView:__delete()
	for k,v in pairs(self.type_list) do
		if type(v) == "table" then
			for k2,v2 in pairs(v) do
				v2:DeleteMe()
			end
		end
	end
	self.type_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function RuneComposeView:InitView()
	self.effect_cd = 0
	self:FlushView()
end

-- 点击合成
function RuneComposeView:OnClickCompose()
	local compose_cfg = RuneData.Instance:GetMaterialByItemId(self.select_id) or {}
	if next(compose_cfg) then
		local index1 = RuneData.Instance:GetBagIndexByItemId(compose_cfg.rune1_id) or -1
		local index2 = RuneData.Instance:GetBagIndexByItemId(compose_cfg.rune2_id) or -1
		if index1 > -1 and index2 > -1 then
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_COMPOSE, index1, 1, index2, 1)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Rune.NotEnoughRune)
		end
	end
end

function RuneComposeView:FlushView(param)
	if param and param > 0 then
		self.select_id = param
	end
	self:FlushRedPoint()
	if self.select_id <= 0 then
		self.select_id = self.defalut_id
	end
	self:FlushDetails(self.select_id)
end

function RuneComposeView:CreatCell()
	local compose_show_cfg = RuneData.Instance:GetComposeShow() or {}
	self.toggle_group = self:FindObj("ToggleGroup"):GetComponent(typeof(UnityEngine.UI.ToggleGroup))
	self.button_table = {}
	self.list_table = {}
	self.type_list = {}
	for i = 1, 3 do
		self.type_list[i] = {}
		local cfg = RuneData.Instance:GetComposeShowByType(i) or {}
		self.button_table[i] = self:FindObj("Button" .. i)
		self.button_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(cfg.type_name or "")
		self.button_table[i]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:ClearToggle(i) end)
		self.list_table[i] = self:FindObj("List" .. i):GetComponent(typeof(UnityEngine.Transform))
	end

	PrefabPool.Instance:Load(AssetID("uis/views/rune_prefab", "ComposeButton"), function (prefab)
		if nil == prefab then
			return
		end
		for k,v in ipairs(compose_show_cfg) do
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			
			local obj_transform = obj.transform
			obj_transform:SetParent(self.list_table[v.sub_type], false)
			local cell = RuneComposeButton.New(obj)
			cell:SetToggleGroup(self.toggle_group)
			cell:SetClickCallBack(BindTool.Bind(self.OnClickRune, self))
			cell:SetData(v)
			table.insert(self.type_list[v.sub_type], cell)
		end

		self:FlushView()
	end)
end

function RuneComposeView:OnClickRune(item_id)
	self.select_id = item_id
	self:FlushDetails(item_id)
end

-- 刷新符文内容
function RuneComposeView:FlushDetails(item_id)
	item_id = item_id or 0
	if item_id <= 0 then
		return
	end
	self:JumpToIndex(item_id)
	local data = ItemData.Instance:GetItemConfig(item_id)
	self.combine_name:SetValue("<color="..Rune_Compose_Quality_Color[data.color]..">"..data.name.."</color>")
	self.item_cell_list[4]:SetData({item_id = item_id})
	local rune_cfg = RuneData.Instance:GetRuneDataByItemId(item_id) or {}
	if next(rune_cfg) then
		if rune_cfg.attr_type_0 > 0 then
			self.show_details0:SetValue(true)
			local attr_type_0 = Language.Rune.AttrName[rune_cfg.attr_type_0] or ""
			local add_attributes_0 = rune_cfg.add_attributes_0 or 0
			if RuneData.Instance:IsPercentAttr(rune_cfg.attr_type_0) then
				add_attributes_0 = add_attributes_0 / 100
			end
			self.details0:SetValue(attr_type_0 .. ": +" .. add_attributes_0)
		else
			self.show_details0:SetValue(false)
		end

		if rune_cfg.attr_type_1 > 0 then
			self.show_details1:SetValue(true)
			local attr_type_1 = Language.Rune.AttrName[rune_cfg.attr_type_1] or ""
			local add_attributes_1 = rune_cfg.add_attributes_1 or 0
			if RuneData.Instance:IsPercentAttr(rune_cfg.attr_type_1) then
				add_attributes_1 = (add_attributes_1 / 100) .. "%"
			end
			self.details1:SetValue(attr_type_1 .. ": +" .. add_attributes_1)
		else
			self.show_details1:SetValue(false)
		end
	end

	local compose_cfg = RuneData.Instance:GetMaterialByItemId(item_id) or {}
	if next(compose_cfg) then
		local item_id1 = compose_cfg.rune1_id
		self.item_cell_list[1]:SetData({item_id = item_id1})
		local need_num1 = 1
		local has_num1 = RuneData.Instance:GetBagNumByItemId(item_id1) or 0
		if need_num1 > has_num1 then
			self.need_num1:SetValue(ToColorStr(has_num1, TEXT_COLOR.RED) .. "/" .. need_num1)
		else
			self.need_num1:SetValue(has_num1 .. "/" .. need_num1)
		end

		local item_id2 = compose_cfg.rune2_id
		self.item_cell_list[2]:SetData({item_id = item_id2})
		local need_num2 = 1
		local has_num2 = RuneData.Instance:GetBagNumByItemId(item_id2) or 0
		if need_num2 > has_num2 then
			self.need_num2:SetValue(ToColorStr(has_num2, TEXT_COLOR.RED) .. "/" .. need_num2)
		else
			self.need_num2:SetValue(has_num2 .. "/" .. need_num2)
		end

		local item_id3 = ResPath.CurrencyToIconId["magic_crystal"]
		self.item_cell_list[3]:SetData({item_id = item_id3})
		local need_num3 = compose_cfg.magic_crystal_num
		self.need_num4:SetValue(need_num3)
		local has_num3 = RuneData.Instance:GetMagicCrystal() or 0
		if need_num3 > has_num3 then
			self.need_num3:SetValue(ToColorStr(has_num3, TEXT_COLOR.RED))
		else
			self.need_num3:SetValue(has_num3)
		end
	end
end

-- 刷新红点
function RuneComposeView:FlushRedPoint()
	local first_id = 0
	local find_id = 0
	local has_magic_crystal_num = RuneData.Instance:GetMagicCrystal() or 0
	for i = 1, 3 do
		local flag = false
		local list = self.type_list[i] or {}
		if type(list) == "table" then
			for k,v in ipairs(list) do
				v:SetRedPoint(false)
				local data = v:GetData() or {}
				if next(data) then
					first_id = first_id == 0 and data.item_id or first_id
					local compose_cfg = RuneData.Instance:GetMaterialByItemId(data.item_id) or {}
					if next(compose_cfg) then
						if compose_cfg.magic_crystal_num <= has_magic_crystal_num then
							local has_num1 = RuneData.Instance:GetBagNumByItemId(compose_cfg.rune1_id) or 0
							local has_num2 = RuneData.Instance:GetBagNumByItemId(compose_cfg.rune2_id) or 0
							if has_num1 > 0 and has_num2 > 0 then
								v:SetRedPoint(true)
								find_id = find_id == 0 and data.item_id or find_id
								flag = true
							end
						end
					end
				end
			end
		end
		self["show_red_point" .. i]:SetValue(flag)
	end
	self.defalut_id = find_id > 0 and find_id or first_id
end

-- 跳转
function RuneComposeView:JumpToIndex(item_id)
	if item_id == nil or item_id <= 0 then
		return
	end
	for i = 1, 3 do
		local list = self.type_list[i] or {}
		if type(list) == "table" then
			for k,v in ipairs(list) do
				local data = v:GetData() or {}
				if next(data) then
					if data.item_id == item_id then
						if self.button_table[i] then
							self.button_table[i]:GetComponent("Toggle").isOn = true
						end
						v.toggle.isOn = true
						v:ShowHighLight(true)
						break
					end
				end
			end
		end
	end
end

function RuneComposeView:ClearToggle(index)
	index = index or 0
	local list = self.type_list[index] or {}
	if type(list) == "table" then
		for k,v in ipairs(list) do
			local data = v:GetData() or {}
			if next(data) then
				if data.item_id == self.select_id then
					v.isOn = true
					v:ShowHighLight(true)
				else
					v.isOn = false
					v:ShowHighLight(false)
				end
			end
		end
	end
end

function RuneComposeView:PlayUpEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_choujiang_prefab",
			"UI_choujiang",
			self.effect_obj.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

----------------------------------------------------RuneComposeButton-----------------------------------------------------------

RuneComposeButton = RuneComposeButton or BaseClass(BaseCell)

function RuneComposeButton:__init()
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
	self.name = self:FindVariable("Name")
	self.show_high_light = self:FindVariable("ShowHighLight")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.toggle = self.root_node:GetComponent("Toggle")
end

function RuneComposeButton:__delete()

end

function RuneComposeButton:SetToggleGroup(toggle_group)
	self.toggle_group = toggle_group
	self.toggle.group = toggle_group
end

function RuneComposeButton:SetClickCallBack(call_back)
	self.call_back = call_back
end

function RuneComposeButton:OnFlush()
	if self.data then
		self.name:SetValue(self.data.sub_name)
	end
end

function RuneComposeButton:OnClick()
	if self.call_back then
		if self.data then
			self.call_back(self.data.item_id)
		end
	end
end

function RuneComposeButton:ShowHighLight(state)
	if self.show_high_light then
		self.show_high_light:SetValue(state or false)
	end
end

function RuneComposeButton:SetRedPoint(state)
	if self.show_red_point then
		self.show_red_point:SetValue(state or false)
	end
end