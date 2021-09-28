
SelectEquipView = SelectEquipView or BaseClass(BaseView)

function SelectEquipView:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","SelectEquipView"}
	self.select_data = {}
end

function SelectEquipView:__delete()

end

function SelectEquipView:ReleaseCallBack()
	self.have_equip = nil
	self.list_view = nil

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = nil

end

function SelectEquipView:LoadCallBack()
	
	self.have_equip = self:FindVariable("HaveEquip")

	self:ListenEvent("close_click",BindTool.Bind(self.BackOnClick, self))
	self.contain_cell_list = {}
	self.list_view = self:FindObj("equip_list")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function SelectEquipView:GetNumberOfCells()
	return #self.select_data
end

function SelectEquipView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShenshouEquipContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetData(self.select_data[cell_index])
	contain_cell:SetIndex(cell_index)
end

function SelectEquipView:OpenCallBack()
	if self.select_data and nil ~= next(self.select_data) then
		self.have_equip:SetValue(true)
		self.list_view.scroller:ReloadData(0)
	else
		self.have_equip:SetValue(false)
	end
end

function SelectEquipView:CloseCallBack()

end

function SelectEquipView:ItemChange(item_id)
	self:Flush(nil, {item_id})
end

--关闭面板
function SelectEquipView:BackOnClick()
	ViewManager.Instance:Close(ViewName.ShenShouSelectEquip)
end

function SelectEquipView:ShowIndexCallBack(index)
end


function SelectEquipView:SetHeChengData(select_data)
	local demand_data = ShenShouData.Instance:GetSSEquinHechengItemData(select_data.compose_equip_best_attr_num, select_data.item_id)
	local equip_list = ShenShouData.Instance:GetSSHechengEquipmentItemList(demand_data)
	self.select_data = equip_list
end

ShenshouEquipContain = ShenshouEquipContain or BaseClass(BaseCell)

function ShenshouEquipContain:__init()
	self:ListenEvent("onclick", BindTool.Bind(self.OnClick, self))
	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.name = self:FindVariable("name")

	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
end

function ShenshouEquipContain:OnClick()
	ShenShouComposeView.Instance:SetSShechengSelecIndexData(self.data)
	ViewManager.Instance:Close(ViewName.ShenShouSelectEquip)
end

function ShenshouEquipContain:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShenshouEquipContain:OnFlush()
	self.item_cell:SetData(self.data)
	self.item_cell:SetShowStar(self.data.star_count)
	self.item_cell:Flush()
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	self.name:SetValue(ToColorStr(shenshou_equip_cfg.name, ITEM_COLOR[shenshou_equip_cfg.quality + 1]))
	self.item_cell:SetHighLight(false)
end