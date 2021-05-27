------------------------------------------------------------
-- 装备分解 使用 ItemSynthesisConfig配置
------------------------------------------------------------
local CSDecomposeView = BaseClass(SubView)

function CSDecomposeView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 4, {0}},
	}
	self.need_del_objs = {}
end

function CSDecomposeView:__delete()
end

function CSDecomposeView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
        v:DeleteMe()
    end
    self.need_del_objs = {}
end

function CSDecomposeView:LoadCallBack(index, loaded_times)
	self:CreateBagView()

	XUI.AddClickEventListener(self.node_t_list.btn_back.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Show)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_decompose.node, function ()
		local compose_data = EquipData.Instance:GetCsDecompose()
		if compose_data and compose_data.input_data then
			BagCtrl.SendEquipDecompose(EquipData.CS_DECOMPOSE_CFG_IDX, compose_data.input_data.series)
		else
			SysMsgCtrl.Instance:FloatingTopRightText("未投入装备")
		end
	end)

	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHUANSHI_DECOMPOSE_CHANGE, BindTool.Bind(self.Flush, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))


	self.input_cell = BaseCell.New()
	self.need_del_objs[#self.need_del_objs + 1] = self.input_cell
	self.input_cell:SetPosition(self.ph_list.ph_input_item.x, self.ph_list.ph_input_item.y)
	self.input_cell:SetAnchorPoint(0.5, 0.5)
	self.input_cell:SetCellBg()
	self.input_cell:SetItemTipFrom(EquipTip.FROM_CS_DECOMPOSE_VIEW)
	self.node_t_list.layout_show_c.node:addChild(self.input_cell:GetView(), 10)

	self.get_cell = BaseCell.New()
	self.need_del_objs[#self.need_del_objs + 1] = self.get_cell
	self.get_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.get_cell:SetAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_show_c.node:addChild(self.get_cell:GetView(), 10)
end

function CSDecomposeView:OpenCallBack()
	EquipData.Instance:ClearCsComposeData()
end

function CSDecomposeView:ShowIndexCallBack(index)
	self:Flush()
end


function CSDecomposeView:CreateBagView()
    local ph = self.ph_list.ph_bag
    self.bag_grid = BaseGrid.New()
    local grid_node =  self.bag_grid:CreateCells({w=ph.w, h=ph.h, cell_count=110, col=3, row=5, itemRender = BaseCell,
                                                   direction = ScrollDir.Vertical})

    self.bag_grid:SetSelectCallBack(BindTool.Bind(self.OnClickBagGridHandle, self))
    self.node_t_list.layout_bag.node:addChild(grid_node, 100)
end

function CSDecomposeView:OnClickBagGridHandle(cell)
    if nil == cell:GetData() then
        return
    end
    TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_CS_DECOMPOSE_BAG)
end

function CSDecomposeView:OnFlush(param_t, index)
	local data = EquipData.Instance:GetCsDecompose()
	self.input_cell:SetData(data and data.input_data)
	self.get_cell:SetData(data and data.get_data)
	self.get_cell:SetRightTopNumText(data and data.get_data.right_top_num or 0, COLOR3B.GREEN)
    self.bag_grid:SetDataList(BagData.Instance:GetBagHandedDownList())
end
-------------------------------------------------------------------------

function CSDecomposeView:OnBagItemChange()
	self:Flush()
end


return CSDecomposeView