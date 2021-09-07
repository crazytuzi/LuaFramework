RuneBagView = RuneBagView or BaseClass(BaseView)
local COLUMN = 2
function RuneBagView:__init()
    self.ui_config = {"uis/views/rune", "RuneBagView"}
    self.play_audio = true
    self.slot_index = 0
    self.view_type = 0
end

function RuneBagView:__delete()
end

function RuneBagView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.view_type = 0
	self.slot_index = 0

	-- 清理变量和对象
	self.list_view = nil
	self.bag_count = nil
end

function RuneBagView:LoadCallBack()
	self.list_data = {}
	self.cell_list = {}

	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self.bag_count = self:FindVariable("BagCount")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

--设置打开的格子
function RuneBagView:SetSlotIndex(slot)
	self.slot_index = slot
	RuneData.Instance:ResetBagList(slot)
end

--设置打开的Type
function RuneBagView:SetViewType(type)
	self.view_type = type
end

--设置打开的DATA
function RuneBagView:SetViewData()
	local bag_data = RuneData.Instance:GetBagList()
	local show_data = {}
	if self.view_type == RUNE_CELL_TYPE.RUNE_XIANGQIAN_BTN or self.view_type == RUNE_CELL_TYPE.RUNE_TIHUAN_BTN then
		local slot_list = RuneData.Instance:GetSlotList() 
		for k, v in ipairs(bag_data) do
			local is_has_type = 0
			for _k, _v in pairs(slot_list) do
				while true do  
		            if _v.type == v.type then   
		                is_has_type = 1  
		                break   
		            end  
		        	break  
		        end
	   		end
			if is_has_type == 0 then
				show_data[#show_data + 1] = v
			end
		end
		if self.view_type == RUNE_CELL_TYPE.RUNE_TIHUAN_BTN then
			local remove_type = slot_list[self.slot_index].type
			for k, v in ipairs(bag_data) do
				if v.type == remove_type then
					show_data[#show_data + 1] = v
				end
			end
		end
	else
		show_data = bag_data
	end
	table.sort(show_data, SortTools.KeyUpperSorters("quality","level","type"))
	self.list_data = show_data
end

function RuneBagView:OpenCallBack()
	self:FlushView()
end

function RuneBagView:CloseCallBack()
	
end

function RuneBagView:FlushView()
	-- self.list_data = RuneData.Instance:GetBagList()
	self:SetViewData()
	local count_des = string.format(Language.Exchange.Expend, #self.list_data, GameEnum.RUNE_SYSTEM_BAG_MAX_GRIDS)
	self.bag_count:SetValue(count_des)
	self.list_view.scroller:ReloadData(0)
end

function RuneBagView:CloseWindow()
	self.slot_index = 0
	self:Close()
end

function RuneBagView:GetCellNumber()
	return math.ceil(#self.list_data/COLUMN)
end

function RuneBagView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if not group_cell then
		group_cell = RuneBagGroupCell.New(cell.gameObject)
		group_cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)
		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function RuneBagView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end
	if self.slot_index <= 0 then
		local function callback()
			if not cell:IsNil() then
				cell:SetHighLight(false)
			end
		end
		RuneCtrl.Instance:SetTipsData(data)
		RuneCtrl.Instance:SetTipsCallBack(callback)
		ViewManager.Instance:Open(ViewName.RuneItemTips)
	else
		if data.type == GameEnum.RUNE_JINGHUA_TYPE then
			SysMsgCtrl.Instance:ErrorRemind(Language.Rune.JingHuaNotEquip)
			return
		end
		if data.is_repeat then
			SysMsgCtrl.Instance:ErrorRemind(Language.Rune.IsRepeatAttr)
			return
		end
		
		local index = data.index
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_SET_RUAN, index, self.slot_index - 1)
		self:Close()
	end
end

function RuneBagView:OnFlush(params_t)
	self:FlushView()
end


-------------------RuneBagGroupCell-----------------------
RuneBagGroupCell = RuneBagGroupCell or BaseClass(BaseRender)
function RuneBagGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = RuneBagItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function RuneBagGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RuneBagGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RuneBagGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RuneBagGroupCell:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function RuneBagGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RuneBagGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------RuneBagItemCell-----------------------
RuneBagItemCell = RuneBagItemCell or BaseClass(BaseCell)
function RuneBagItemCell:__init()
	self.level_des = self:FindVariable("LevelDes")
	self.attr_des_1 = self:FindVariable("AttrDes1")
	self.attr_des_2 = self:FindVariable("AttrDes2")
	self.show_repeat = self:FindVariable("ShowRepeat")
	self.image_res = self:FindVariable("ImageRes")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function RuneBagItemCell:__delete()

end

function RuneBagItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function RuneBagItemCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneBagItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	if self.data.item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(self.data.item_id))
	end

	--self.show_repeat:SetValue(self.data.is_repeat)

	local level_name = RuneData.Instance:GetRuneNameByItemId(self.data.item_id)
	local quality, types = RuneData.Instance:GetQualityTypeByItemId(self.data.item_id)
	local level_color = RUNE_COLOR[quality] or TEXT_COLOR.WHITE
	local level_str = string.format(Language.Rune.LevelDes2, level_color, level_name, self.data.level)
	self.level_des:SetValue(level_str)

	local attr_type_name = ""
	local attr_value = 0
	if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = self.data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.attr_des_1:SetValue(str)
		self.attr_des_2:SetValue("")
		return
	end

	attr_type_name = Language.Rune.AttrName[self.data.attr_type1] or ""
	attr_value = self.data.attr_value1
	if RuneData.Instance:IsPercentAttr(self.data.attr_type1) then
		attr_value = (self.data.attr_value1/100.00) .. "%"
	end
	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.attr_des_1:SetValue(attr_des)

	if "" ~= self.data.attr_type2 then
		attr_type_name = Language.Rune.AttrName[self.data.attr_type2] or ""
		attr_value = self.data.attr_value2
		if RuneData.Instance:IsPercentAttr(self.data.attr_type2) then
			attr_value = (self.data.attr_value2/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.attr_des_2:SetValue(attr_des)
	else
		self.attr_des_2:SetValue("")
	end
end