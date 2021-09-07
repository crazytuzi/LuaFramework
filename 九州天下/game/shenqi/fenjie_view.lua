FenjieView = FenjieView or BaseClass(BaseRender)
local BAG_MAX_GRID_NUM = 80			-- 最大格子数
local BAG_ROW = 4					-- 每一页有4行
local BAG_COLUMN = 4				-- 每一页有4列

-- 分解类型
Fenjie_TYPE =
{
	BLUE = 1,						-- 蓝色
	PURPLE = 2,						-- 紫色
	ORANGE = 3,						-- 橙色
	RED = 4,						-- 红色
}

-- 分解
function FenjieView:__init()
	self.bag_cell = {}
	self.select_send_type = {true, true, false, false}		-- 选中分解类型
end

function FenjieView:__delete()
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
end

function FenjieView:LoadCallBack(instance)
	-- 神兵分解背包
	self.bag_list_view = self:FindObj("ListView")
	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self:ListenEvent("Toggle_1", BindTool.Bind2(self.OnToggleOnClick,self,Fenjie_TYPE.PURPLE))
	self:ListenEvent("Toggle_2", BindTool.Bind2(self.OnToggleOnClick,self,Fenjie_TYPE.ORANGE))
	self:ListenEvent("Toggle_3", BindTool.Bind2(self.OnToggleOnClick,self,Fenjie_TYPE.RED))

	-- 分解按钮
	self:ListenEvent("Decompose", BindTool.Bind(self.OnDecompose,self))
	self:ListenEvent("OnClickShenqiTip", BindTool.Bind(self.OnClickShenqiTip, self))

	-- 神兵分解材料个数
	self.shenbing_stuff_num = self:FindVariable("ShenbingStuffNum")

	-- 宝甲分解材料个数
	self.baojia_stuff_num = self:FindVariable("BaojiaStuffNum")

	self:Flush()
end

function FenjieView:OnToggleOnClick(i, is_click)
	self.select_send_type[i] = is_click
	if i == Fenjie_TYPE.PURPLE then
		self.select_send_type[1] = is_click
	end

	self:FlushFenjieStuffNum()
	self.bag_list_view.scroller:RefreshActiveCellViews()
end

function FenjieView:FlushFenjieStuffNum()
	local stuff_list = {}
	for k, v in pairs(self.select_send_type) do
		if v then
			local data_list = ShenqiData.Instance:GetFenjieListbyQuality(k)
			for _, v1 in pairs(data_list) do
				table.insert(stuff_list, v1)
			end
		end
	end

	local shenbing_stuff = 0
	local baojia_stuff = 0

	if next(stuff_list) then
		for k,v in pairs(stuff_list) do
			local shenbing_num = ShenqiData.Instance:GetFenjieNumByItemID(v.item_id, 0)
			shenbing_stuff = shenbing_stuff + shenbing_num * v.num
			local baojia_num = ShenqiData.Instance:GetFenjieNumByItemID(v.item_id, 1)
			baojia_stuff = baojia_stuff + baojia_num * v.num
		end
	end

	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	local shenbing_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.shenbing_uplevel_stuff)

	local baojia_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.baojia_uplevel_stuff_id)

	if shenbing_stuff == 0 then
		self.shenbing_stuff_num:SetValue(shenbing_stuff_num)
	else
		self.shenbing_stuff_num:SetValue(shenbing_stuff_num..ToColorStr("+",COLOR.GREEN)..ToColorStr(shenbing_stuff,COLOR.GREEN))
	end

	if baojia_stuff == 0 then
		self.baojia_stuff_num:SetValue(baojia_stuff_num)
	else
		self.baojia_stuff_num:SetValue(baojia_stuff_num..ToColorStr("+",COLOR.GREEN)..ToColorStr(baojia_stuff,COLOR.GREEN))
	end
end

-- 分解按钮
function FenjieView:OnDecompose()
	-- if not next(self.select_send_type) then
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Shenqi.NoSelectFenjieType)
	-- end

	local stuff_list = {}
	for k, v in pairs(self.select_send_type) do
		if v then
			local data_list = ShenqiData.Instance:GetFenjieListbyQuality(k)
			for _, v1 in pairs(data_list) do
				table.insert(stuff_list, v1)
			end
		end
	end

	if next(stuff_list) then
		for k,v in pairs(stuff_list) do
			-- for i = 1, v.num do
				ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_DECOMPOSE, v.item_id,v.num)
			-- end
		end
	else	
		SysMsgCtrl.Instance:ErrorRemind(Language.Shenqi.NoFenjieMet)
	end

end

function FenjieView:BagRefreshCell(cell, data_index, cell_index)
	-- 构造Cell对象
	local group = self.bag_cell[cell]
	if nil == group then
		group = ShenBingFenJieStuffItemGroup.New(cell.gameObject)
		group:SetToggleGroup(self.root_node.toggle_group)
		self.bag_cell[cell] = group
	end

	-- 计算索引
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)

		local stuff_list = {}
		for k, v in pairs(self.select_send_type) do
			if v then
				local data_list = ShenqiData.Instance:GetFenjieListbyQuality(k)
				for _, v1 in pairs(data_list) do
					table.insert(stuff_list, v1)
				end
			end
		end

		local data = stuff_list[index + 1]
		if nil == data then data = {} end

		group:SetData(i, data, true)
	end
end

function FenjieView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW		-- 80/4=20 总共20组
end

function FenjieView:OnFlush(param_list)
	self.bag_list_view.scroller:RefreshActiveCellViews()
	self:FlushFenjieStuffNum()
end

function FenjieView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(202)
end

---------------------------- 神兵分解背包 begin-------------------------------------
ShenBingFenJieStuffItemGroup = ShenBingFenJieStuffItemGroup or BaseClass(BaseRender)

function ShenBingFenJieStuffItemGroup:__init()
	self.cells = {}
	for i = 1, BAG_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self.index_table = {}
end

function ShenBingFenJieStuffItemGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function ShenBingFenJieStuffItemGroup:SetData(i, data, enable)
	if nil == data then return end
	self.cells[i]:SetData(data, enable)
	data.from_view = TipsFormDef.FROM_SHENQI_BAG
	self.index_table[i] = data.index

	self.cells[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
end

function ShenBingFenJieStuffItemGroup:OnClickItem(index)
	local data = self.cells[index]:GetData()

	if data and data.item_id then
		self.cells[index]:ShowHighLight(true)
		self.cells[index]:OnClickItemCell(data)
	else
		self.cells[index]:ShowHighLight(false)
	end
end

function ShenBingFenJieStuffItemGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function ShenBingFenJieStuffItemGroup:SetIconGrayScale(i, enable)
	self.cells[i]:SetIconGrayScale(enable)
end

function ShenBingFenJieStuffItemGroup:GetIconGrayScaleIsGray(i)
	return self.cells[i]:GetIconGrayScaleIsGray()
end

function ShenBingFenJieStuffItemGroup:SetToggleGroup(toggle_group)
	for k, v in pairs(self.cells) do
		self.cells[k]:SetToggleGroup(toggle_group)
	end
end

function ShenBingFenJieStuffItemGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function ShenBingFenJieStuffItemGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function ShenBingFenJieStuffItemGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function ShenBingFenJieStuffItemGroup:ShowQuality(i, enable)
	self.cells[i]:ShowQuality(enable)
end

function ShenBingFenJieStuffItemGroup:FlushArrow(value)
	for k,v in pairs(self.cells) do
		self.cells[k]:FlushArrow(value)
	end
end

-- 通过背包索引刷新格子
function ShenBingFenJieStuffItemGroup:SetDataByIndex(index, data)
	for i = 1, BAG_ROW do
		if self.index_table[i] == index then
			self.cells[i]:SetIconGrayScale(false)
			self.cells[i]:ShowQuality(nil ~= data.item_id)
			local recycle_list = ItemData.Instance:GetRecycleItemDataList()
			for k,v in pairs(recycle_list) do
				if data.item_id == v.item_id and data.index == v.index then
					self.cells[i]:SetIconGrayScale(true)
					self.cells[i]:ShowQuality(false)
				end
			end
			self.cells[i]:SetData(data, true)
			self.cells[i]:SetInteractable(nil ~= data.item_id or data.locked)
			return true, i
		end
	end
	return false
end

------------------------------ 神兵分解背包 end-------------------------------------
