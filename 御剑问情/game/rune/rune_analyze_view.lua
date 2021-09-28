RuneAnalyzeView = RuneAnalyzeView or BaseClass(BaseRender)

local CheckType = {
	[1] = "white",
	[2] = "blue",
	[3] = "purple",
	[4] = "orange",
}

local CheckList = {
	["white"] = false,
	["blue"] = false,
	["purple"] = false,
	["orange"] = false,
}

local CheckNum = 4
local COLUMN = 4

local EFFECT_CD = 1

function RuneAnalyzeView:__init()
	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	for i = 1, CheckNum do
		self["check" .. i] = self:FindObj("Check" .. i)
		self["check" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.OnCheckChange,self, i))
	end

	self.now_jing_hua = self:FindVariable("NowJingHua")
	self.add_jing_hua = self:FindVariable("AddJingHua")
	self.show_add_des = self:FindVariable("ShowAddDes")
	self.is_empty = self:FindVariable("IsEmpty")

	self.effect_obj = self:FindObj("EffectObj")

	self:ListenEvent("AutoAnalyze", BindTool.Bind(self.AutoAnalyze, self))
end

function RuneAnalyzeView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function RuneAnalyzeView:InitView()
	self.effect_cd = 0
	GlobalTimerQuest:AddDelayTimer(function()
		self.list_data = {}
		self.select_data = {}			--选择列表
		--初始化筛选
		for i = 1, CheckNum do
			self["check" .. i].toggle.isOn = false
		end

		self:FlushView()
	end, 0)
end

function RuneAnalyzeView:FlushView()
	self.select_data = {}
	self.list_data = RuneData.Instance:GetAnalyList()

    self.list_view.scroller:ReloadData(0)
    if not next(self.list_data) then
		self.is_empty:SetValue(true)
	else
	    self.is_empty:SetValue(false)
	end

	self:FlushJingHua()
end

function RuneAnalyzeView:GetCellNumber()
	return math.ceil(#self.list_data/COLUMN)
end

function RuneAnalyzeView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RuneAnalyzeGroupCell.New(cell.gameObject)
		group_cell:SetIsAnalyze(true)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)

		if data and self.select_data[data.index] then
			group_cell:SetToggleHighLight(i, true)
		else
			group_cell:SetToggleHighLight(i, false)
		end

		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function RuneAnalyzeView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	if self.select_data[data.index] then
		self.select_data[data.index] = nil
	else
		self.select_data[data.index] = data
	end
	self:FlushJingHua()
end

function RuneAnalyzeView:FlushSelect(change_quality, state)
	if not next(self.list_data) then
		return
	end
	if state then
		for k, v in ipairs(self.list_data) do
			local index = v.index
			if change_quality == v.quality and not self.select_data[index] then
				self.select_data[index] = v
			end
		end
	else
		--清除选中列表
		for k, v in pairs(self.select_data) do
			if change_quality == v.quality then
				self.select_data[k] = nil
			end
		end
	end

	self.list_view.scroller:RefreshActiveCellViews()
	self:FlushJingHua()
end

function RuneAnalyzeView:FlushJingHua()
	local jinghua = RuneData.Instance:GetJingHua()
	self.now_jing_hua:SetValue(CommonDataManager.ConverTenNum(jinghua))

	local add_jinghua = 0
	for k, v in pairs(self.select_data) do
		add_jinghua = add_jinghua + v.dispose_fetch_jinghua
	end
	local add_str = ""
	if add_jinghua > 0 then
		add_str = "+" .. add_jinghua
		self.show_add_des:SetValue(true)
	else
		self.show_add_des:SetValue(false)
	end
	self.add_jing_hua:SetValue(add_str)
end

function RuneAnalyzeView:OnCheckChange(i, ison)
	local str_type = CheckType[i]
	if nil ~= CheckList[str_type] then
		CheckList[str_type] = ison
		self:FlushSelect(i-1, ison)
	end
end

function RuneAnalyzeView:AutoAnalyze()
	--自动添加符文精华
	for k, v in ipairs(self.list_data) do
		if v.type == GameEnum.RUNE_JINGHUA_TYPE then
			if not self.select_data[v.index] then
				self.select_data[v.index] = v
			end
		end
	end

	if not next(self.select_data) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rune.NotSelectRune)
		return
	end

	local tbl = {}
	for k, v in pairs(self.select_data) do
		table.insert(tbl, k)
	end
	self.select_data = {}
	SortTools.SortAsc(tbl)
	local max_count = #tbl
	RuneCtrl.Instance:SendOneKeyAnalyze(max_count, tbl)
end

--播放分解成功特效
function RuneAnalyzeView:PlayAni()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_guihuo_lizi_prefab",
			"UI_guihuo_lizi",
			self.effect_obj.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

--------------------RuneAnalyzeGroupCell---------------------------
RuneAnalyzeGroupCell = RuneAnalyzeGroupCell or BaseClass(BaseRender)
function RuneAnalyzeGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = RuneAnalyzeItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, item_cell)
	end
	self.gray_count = 0
end

function RuneAnalyzeGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RuneAnalyzeGroupCell:SetIsAnalyze(bool)
	for i = 1, COLUMN do
		self.item_list[i]:SetIsAnalyze(bool)
	end
end

function RuneAnalyzeGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RuneAnalyzeGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RuneAnalyzeGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RuneAnalyzeGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

function RuneAnalyzeGroupCell:SetToggleHighLight(i, state)
	self.item_list[i]:SetToggleHighLight(state)
end

function RuneAnalyzeGroupCell:SetGrayCount(count)
	for i= 1, COLUMN do
		self.item_list[i]:SetGrayCount(count)
	end
end

--------------------RuneAnalyzeItemCell----------------------
RuneAnalyzeItemCell = RuneAnalyzeItemCell or BaseClass(BaseCell)
function RuneAnalyzeItemCell:__init()
	self.level_text = self:FindVariable("LevelText")
	self.attr_text_1 = self:FindVariable("AttrText1")
	self.attr_text_2 = self:FindVariable("AttrText2")
	self.image_res = self:FindVariable("ImageRes")
	self.is_gray = self:FindVariable("is_gray")
	self.show_special_effect = self:FindVariable("ShowSpecialEffect")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
	self.gray_count = 0
	self.is_analyze = false
end

function RuneAnalyzeItemCell:__delete()

end

function RuneAnalyzeItemCell:SetToggleHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneAnalyzeItemCell:SetGrayCount(count)
	self.gray_count = count
end

function RuneAnalyzeItemCell:SetIsAnalyze(bool)
	self.is_analyze = bool
end

function RuneAnalyzeItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	-- 设置战斗力
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type_1 = Language.Rune.AttrType[self.data.attr_type_0]
	local attr_type_2 = Language.Rune.AttrType[self.data.attr_type_1]
	if attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, self.data.add_attributes_0)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, self.data.add_attributes_1)
	end
	local capability = CommonDataManager.GetCapabilityCalculation(attr_info)

	if self.data.item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(self.data.item_id))
		--展示特殊特效
		if self.show_special_effect then
			if self.data.quality == 4 and self.data.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				self.show_special_effect:SetValue(true)
			else
				self.show_special_effect:SetValue(false)
			end
		end
	end

	if self.is_gray then
		self.is_gray:SetValue(self:GetIndex() > self.gray_count)
	end

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[self.data.type] or ""
	if self.is_analyze then	
		local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
		self.level_text:SetValue(level_str)
	else
		local level_str = string.format(Language.Rune.LevelDes2, level_color, level_name)
		self.level_text:SetValue(level_str)
	end

	-- local attr_type_name = ""
	-- local attr_value = 0
	-- if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
	-- 	--符文精华特殊处理
	-- 	attr_type_name = Language.Rune.JingHuaAttrName
	-- 	attr_value = self.data.dispose_fetch_jinghua
	-- 	local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	-- 	self.attr_text_1:SetValue(str)
	-- 	--self.attr_text_2:SetValue("")
	-- 	if capability~=0 then
	-- 		str=string.format(Language.Rune.AttrDes, Language.Rune.Capability, capability)
	-- 		self.attr_text_2:SetValue(attr_des)
	-- 	else
	-- 		self.attr_text_2:SetValue("")
	-- 	end
	-- 	return
	-- end



	-- attr_type_name = Language.Rune.AttrName[self.data.attr_type_0] or ""
	-- attr_value = self.data.add_attributes_0
	-- if RuneData.Instance:IsPercentAttr(self.data.attr_type_0) then
	-- 	attr_value = (self.data.add_attributes_0/100.00) .. "%"
	-- end
	-- local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	-- self.attr_text_1:SetValue(attr_des)

	-- if self.data.attr_type_1 > 0 then
	-- 	attr_type_name = Language.Rune.AttrName[self.data.attr_type_1] or ""
	-- 	attr_value = self.data.add_attributes_1
	-- 	if RuneData.Instance:IsPercentAttr(self.data.attr_type_1) then
	-- 		attr_value = (self.data.add_attributes_1/100.00) .. "%"
	-- 	end
	-- 	attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	-- 	self.attr_text_2:SetValue(attr_des)
	-- else
	-- 	--self.attr_text_2:SetValue("")
	-- 	if capability~=0 then
	-- 		attr_des=string.format(Language.Rune.AttrDes, Language.Rune.Capability, capability)
	-- 		self.attr_text_2:SetValue(attr_des)
	-- 	else
	-- 		self.attr_text_2:SetValue("")
	-- 	end
	-- end

	

	---------------------
	local str=string.format(Language.Rune.AttrDes, Language.Rune.Capability, self.data.power)
	if  self.data.power~=0 then
		self.attr_text_1:SetValue(str)
	else
		self.attr_text_1:SetValue("")
	end
	self.attr_text_2:SetValue("")


	
end