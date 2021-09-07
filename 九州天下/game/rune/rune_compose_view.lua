RuneComposeView = RuneComposeView or BaseClass(BaseRender)

local EFFECT_CD = 1
function RuneComposeView:__init()

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

function RuneComposeView:LoadCallBack()
	self.effect_obj = self:FindObj("EffectObj")

	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell"..i))
	end

	self.details0 = self:FindVariable("Details1")
	self.details1 = self:FindVariable("Details2")
	self.percent = self:FindVariable("Precent")
	self.show_details0 = self:FindVariable("ShowDetails1")
	self.show_details1 = self:FindVariable("ShowDetails2")

	for i = 1, 3 do
		self["need_num" .. i] = self:FindVariable("NeedNum" .. i)
		self["show_red_point" .. i] = self:FindVariable("ShowRedPoint" .. i)
	end

	self:ListenEvent("OnClickCompose", BindTool.Bind(self.OnClickCompose, self))

	-- 成功率写死100%
	self.percent:SetValue("100")
	self.select_id = 0
	self.defalut_id = 23368

	self:CreatCell()
end

function RuneComposeView:InitView()
	self.effect_cd = 0
	self:FlushView()
end

function RuneComposeView:ItemDataChangeCallback()
	if next(self.type_list) then
		for k, v in pairs(self.type_list) do
			for _k, _v in pairs(v) do
				_v:SetRedPoint()
			end		
		end
	end
end

-- 点击合成
function RuneComposeView:OnClickCompose()
	local compose_cfg = RuneData.Instance:GetMaterialByItemId(self.select_id) or {}
	if next(compose_cfg) then
		local data = {}
		local seq = {}
		for i = 1, 3 do
			local item_index = RuneData.Instance:GetBagIndexByItemId(compose_cfg["rune" .. i .. "_id"], data)
			data[item_index] = item_index
			seq[i] = item_index
		end
		if seq[1] ~= -1 and seq[2] ~= -1 and seq[3] ~= -1 then
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_COMPOSE, seq[1] + 1000, seq[2] + 1000, seq[3] + 1000)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Rune.NotEnoughRune)
		end
	end
end

function RuneComposeView:FlushView(param)
	if param and param > 0 then
		self.select_id = param
	end
	if self.select_id <= 0 then
		self.select_id = self.defalut_id
	end
	self:FlushDetails(self.select_id)
	self:FlushRedPoint()
end

function RuneComposeView:CreatCell()
	local compose_show_cfg = RuneData.Instance:GetComposeShow() or {}
	self.toggle_group = self:FindObj("ToggleGroup"):GetComponent(typeof(UnityEngine.UI.ToggleGroup))
	self.button_table = {}
	self.list_table = {}
	self.type_list = {}
	for i = 1, 2 do
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
			-- PrefabPool.Instance:Free(prefab)
			
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
	self.item_cell_list[4]:SetData({item_id = item_id})
	local rune_cfg = RuneData.Instance:GetRuneDataByItemId(item_id) or {}
	if next(rune_cfg) then
		if 	"" ~= rune_cfg.attr_type1 then
			self.show_details0:SetValue(true)
			local attr_type1 = Language.Rune.AttrName[rune_cfg.attr_type1] or ""
			local attr_value1 = rune_cfg.attr_value1 or 0
			if RuneData.Instance:IsPercentAttr(rune_cfg.attr_type1) then
				attr_value1 = attr_value1 / 100
			end
			self.details0:SetValue(attr_type1 .. ": +" .. attr_value1)
		else
			self.show_details0:SetValue(false)
		end

		if "" ~= rune_cfg.attr_type2 then
			self.show_details1:SetValue(true)
			local attr_type2 = Language.Rune.AttrName[rune_cfg.attr_type2] or ""
			local attr_value2 = rune_cfg.attr_value2 or 0
			if RuneData.Instance:IsPercentAttr(rune_cfg.attr_type2) then
				attr_value2 = (attr_value2 / 100) .. "%"
			end
			self.details1:SetValue(attr_type2 .. ": +" .. attr_value2)
		else
			self.show_details1:SetValue(false)
		end
	end
	
	local compose_cfg = RuneData.Instance:GetMaterialByItemId(item_id) or {}

	local data = {}
	for i = 1, 3 do
		if compose_cfg["rune" .. i .. "_id"] then
			local item = compose_cfg["rune" .. i .. "_id"]
			if data[item] == nil then
				data[item] = RuneData.Instance:GetBagNumByItemId(item)
			end
		end

		if next(compose_cfg) then
			self["item_id" .. i] = compose_cfg["rune" .. i .. "_id"]
			self.item_cell_list[i]:SetData({item_id = self["item_id" .. i]})
			self["NeedNum" .. i] = 1
			self["HasNum" .. i] = 0
			if data[self["item_id" .. i]] then
				if data[self["item_id" .. i]] >= self["NeedNum" .. i] then
					self["HasNum" .. i] = self["NeedNum" .. i]
					data[self["item_id" .. i]] = data[self["item_id" .. i]] - 1
					data[self["item_id" .. i]] = data[self["item_id" .. i]] < 0 and 0 or data[self["item_id" .. i]]
				end
			end
			if self["NeedNum" .. i] > self["HasNum" .. i] then
				self["need_num" .. i]:SetValue(ToColorStr(self["HasNum" .. i], TEXT_COLOR.RED) .. "/" .. self["NeedNum" .. i])
			else
				self["need_num" .. i]:SetValue(self["HasNum" .. i] .. "/" .. self["NeedNum" .. i])
			end
		end
	end
	self:ItemDataChangeCallback()
end

-- 刷新红点
function RuneComposeView:FlushRedPoint()
	for i=1,2 do
		self["show_red_point" .. i]:SetValue(RuneData.Instance:IsDoubleRedPoint(i))
	end
end

-- 跳转
function RuneComposeView:JumpToIndex(item_id)
	if item_id == nil or item_id <= 0 then
		return
	end
	for i = 1, 2 do
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
	-- if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
	-- 	EffectManager.Instance:PlayAtTransformCenter(
	-- 		"effects2/prefab/ui_prefab",
	-- 		"UI_shengjichenggong",
	-- 		self.effect_obj.transform,
	-- 		2.0)
	-- 	self.effect_cd = Status.NowTime + EFFECT_CD
	-- end
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
		local level_name = RuneData.Instance:GetRuneNameByItemId(self.data.item_id)
		self.name:SetValue(level_name)
	end
	self:SetRedPoint()
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

function RuneComposeButton:SetRedPoint()
	self.show_red_point:SetValue(RuneData.Instance:IsRuneTokenRedPoint(self.data.item_id))
end
