HunYinResolve = HunYinResolve or BaseClass(BaseView)

local CHECK_NUM = 4

function HunYinResolve:__init()
	self.ui_config = {"uis/views/hunqiview", "HunYinResolve"}
	self:SetMaskBg()
end

function HunYinResolve:__delete()
	-- body
end

function HunYinResolve:LoadCallBack()
	self.is_first_page = self:FindVariable("isFirstPage")
	self.is_last_page = self:FindVariable("isLastPage")
	self.ling_xing_zhi = self:FindVariable("lingxingzhi")
	self.ling_xing_zhi:SetValue(HunQiData.Instance:GetLingshuExp())

	self.cell_list_view = self:FindObj("HunYinCells")
    self.cell_list_view.page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    self.cell_list_view.page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

	for i = 1, CHECK_NUM do
 		self["check" .. i] = self:FindObj("Check_" .. i)
		self["check" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.OnCheckChange,self, i))
	end
	
	self:ListenEvent("ClickLeft", BindTool.Bind(self.ClickLeft, self))
	self:ListenEvent("ClickRight", BindTool.Bind(self.ClickRight, self))
	self:ListenEvent("ClickResolve", BindTool.Bind(self.ClickResolve, self))
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))

	self.current_page = 1
	self.check_flag = 0

    self.data_list = {}
    self.select_list = {}
 	for i = 1,5 do
		self["color_list"..i] = {}
	end
	
	self.cell_list = {}
end

function HunYinResolve:ReleaseCallBack()
	self.is_first_page = nil
	self.is_last_page = nil
	self.ling_xing_zhi = nil

	self.cell_list_view = nil
	for i = 1, CHECK_NUM do
 		self["check" .. i] = nil
	end

	self.current_page = nil
	self.check_flag = nil

    self.data_list = nil
    self.select_list = nil
    for i = 1,5 do
		self["color_list"..i] = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil	
end

function HunYinResolve:OpenCallBack()
	self.select_list = {}
	self:Flush()	
    self.cell_list_view.list_view:JumpToIndex(0)
end

function HunYinResolve:CloseCallBack()
	-- override
end

function HunYinResolve:OnFlush()
	self:GetAllItemInfo()
	self:FlushLingXingZhi()
	self.cell_list_view.list_view:Reload()
end

function HunYinResolve:GetAllItemInfo()
	self.data_list = {}
	for i = 1,5 do
		self["color_list"..i] = {}
	end
	local hunyin_info_list = HunQiData.Instance:GetHunQiInfo()
	local bag_list = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(bag_list) do
		local item_cfg = hunyin_info_list[v.item_id]
		if item_cfg then
			local color = item_cfg[1].hunyin_color --按颜色排序
			table.insert(self["color_list"..color], 
				{bag_index = k, item_id = v.item_id, num = v.num, is_bind = 0, discard_exp = item_cfg[1].discard_exp, hunyin_color = color})
		end
	end
	for i = 1,5 do
		for k,v in pairs(self["color_list"..i]) do
			self.data_list[#self.data_list + 1] = v
		end
	end
end

function HunYinResolve:NumberOfCellsDel()
	return math.max(8, math.ceil(#self.data_list / 8) * 8)
end

function HunYinResolve:CellRefreshDel(data_index, cell)
	data_index = data_index + 1 
	-- if data_index % 8 == 2 then --竖向排列改为横向排列
	-- 	data_index = data_index + 3
	-- elseif data_index % 8 == 3 then
	-- 	data_index = data_index - 1
	-- elseif data_index % 8 == 4 then
	-- 	data_index = data_index + 2
	-- elseif data_index % 8 == 5 then
	-- 	data_index = data_index - 2
	-- elseif data_index % 8 == 6 then
	-- 	data_index = data_index + 1
	-- elseif data_index % 8 == 7 then
	-- 	data_index = data_index - 3
	-- end
	local x = self.cell_list_view:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition.x
	x = math.max(0, math.min(1, x))
	local max_page = math.ceil((#self.data_list + 0.1) / 8)
	self.current_page = math.ceil((x + 0.02) / (1 / (max_page - 1))) --0.02为调整系数
	if data_index == 1 or x == 0 then
		self.is_first_page:SetValue(true)
	end
	if data_index > 10 then
		self.is_first_page:SetValue(false)
	end
	if data_index == self:NumberOfCellsDel() or x == 1 then
		self.is_last_page:SetValue(true)
	end
	if data_index < self:NumberOfCellsDel() - 9 then
		self.is_last_page:SetValue(false)
	end
	
	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cell.gameObject)
		self.cell_list[cell] = item_cell
	end

	local cell_data = self.data_list[data_index]
	item_cell:SetData(cell_data)
	item_cell:SetIndex(data_index)
	if cell_data then
		item_cell:ListenClick(BindTool.Bind(self.OnItemClick, self, item_cell))
		item_cell:SetInteractable(true) 
		item_cell.root_node.toggle.isOn = self.select_list[data_index] and true or false --已选物品高亮
		if cell_data.num > 1 then --数量大于1的物品显示数字
			item_cell.show_number:SetValue(true)
		end
	else --空格子
		item_cell:SetInteractable(false)
		item_cell.root_node.toggle.isOn = false
	end
end

function HunYinResolve:OnCheckChange(i, isOn)
	self.select_list = self.check_flag == 0 and {} or self.select_list
	if self.check_flag == 0 then
		for k,v in pairs(self.cell_list) do
			v.root_node.toggle.isOn = false
		end
	end

	self.check_flag = isOn and self.check_flag + 1 or self.check_flag - 1
	for k,v in pairs(self.data_list) do
		if v.hunyin_color == i then
			local cell = self:GetCellByIndex(k)
			if cell then
				cell.root_node.toggle.isOn = isOn
			end
			self.select_list[k] = isOn and v or nil
		end
	end
	self:FlushLingXingZhi()
end

function HunYinResolve:GetCellByIndex(index)
	for k,v in pairs(self.cell_list) do
		if v:GetIndex() == index then
			return v 
		end
	end
end

function HunYinResolve:OnItemClick(item_cell)
	if self.check_flag ~= 0 then
		for i = 1, CHECK_NUM do
			self["check" .. i].toggle.isOn = false
		end
	end

	local data = item_cell:GetData()
	local index = item_cell:GetIndex()
	if self.select_list[index] then --反选
		self.select_list[index] = nil
		item_cell.root_node.toggle.isOn = false
	else							--选择
		self.select_list[index] = data
		item_cell.root_node.toggle.isOn = true
	end
	self:FlushLingXingZhi()
end

function HunYinResolve:FlushLingXingZhi()
	local current_exp = HunQiData.Instance:GetLingshuExp()
	local add_value = 0
	if self.select_list and next(self.select_list) then
		for k,v in pairs(self.select_list) do
			add_value = add_value + v.discard_exp * v.num
		end
	end
	local value_text = add_value == 0 and current_exp or current_exp.." + "..add_value
	self.ling_xing_zhi:SetValue(value_text)
end

function HunYinResolve:ClickLeft()	
	local cell_index = math.max(0, (self.current_page - 1 - 1) * 8)
	self.cell_list_view.list_view:JumpToIndex(cell_index)

end

function HunYinResolve:ClickRight()
	local cell_index = (self.current_page - 1 + 1) * 8
	self.cell_list_view.list_view:JumpToIndex(cell_index)

end

function HunYinResolve:ClickResolve()
	local resolve_index_table = {} 	--当前需要分解的物品在背包中的索引table
	for k,v in pairs(self.select_list) do
		table.insert(resolve_index_table, v.bag_index)
	end
	for k,v in pairs(self.cell_list) do
		v.root_node.toggle.isOn = false
	end
	self.select_list = {}
	HunQiCtrl.Instance:SendHunYiResolveReq(#resolve_index_table, resolve_index_table)
end

function HunYinResolve:CloseWindow()
	self:Close()
end