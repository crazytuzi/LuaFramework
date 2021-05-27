------------------------------------------------------------
-- 装备合成 使用 ItemSynthesisConfig配置
------------------------------------------------------------
local CScomposeView = BaseClass(SubView)

function CScomposeView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 5, {0}},
	}
	self.need_del_objs = {}
end

function CScomposeView:__delete()
end

function CScomposeView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
        v:DeleteMe()
    end
    self.need_del_objs = {}
end

function CScomposeView:LoadCallBack(index, loaded_times)
	XUI.AddClickEventListener(self.node_t_list.btn_back.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Show)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_compose.node, function ()
		local compose_data = EquipData.Instance:GetCsCompose()
		if compose_data and #compose_data.consum_data >= 3 then
			BagCtrl.SendComposeItem(compose_data.synthesis_type, compose_data.item_index, 0)			
		elseif compose_data and #compose_data.consum_data > 0 then
			TipCtrl.Instance:OpenGetStuffTip(compose_data.consum_data[1].item_id)
		else
			SysMsgCtrl.Instance:FloatingTopRightText("未投入装备")
		end
	end)

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHUANSHI_COMPOSE_CHANGE, BindTool.Bind(self.OnComposeChange, self))

	self:CreateBagView()

	self.pre_icon = BaseCell.New()
	self.need_del_objs[#self.need_del_objs + 1] = self.pre_icon
	self.pre_icon:SetPosition(self.ph_list.ph_get_item.x, self.ph_list.ph_get_item.y)
	self.pre_icon:SetAnchorPoint(0.5, 0.5)
	self.pre_icon:SetCellBg()
	self.node_t_list.layout_show_c.node:addChild(self.pre_icon:GetView(), 10)

	for i = 1, 3 do
		self["input_cell_" .. i] = BaseCell.New()
		self.need_del_objs[#self.need_del_objs + 1] = self["input_cell_" .. i]
		self["input_cell_" .. i]:SetPosition(self.ph_list["ph_cell_" .. i].x, self.ph_list["ph_cell_" .. i].y)
		self["input_cell_" .. i]:SetAnchorPoint(0.5, 0.5)
		self["input_cell_" .. i]:SetItemTipFrom(EquipTip.FROM_CS_CONSUM)
		-- self["input_cell_" .. i]:SetCellBg()
		self.node_t_list.layout_show_c.node:addChild(self["input_cell_" .. i]:GetView(), 10)
	end
end

function CScomposeView:OpenCallBack()
	EquipData.Instance:ClearCsComposeData()
end

function CScomposeView:ShowIndexCallBack(index)
	self:Flush()
end

function CScomposeView:CreateBagView()
    local ph = self.ph_list.ph_bag
    self.bag_grid = BaseGrid.New()
    local grid_node =  self.bag_grid:CreateCells({w=ph.w, h=ph.h, cell_count=110, col=3, row=5, itemRender = BaseCell,
                                                   direction = ScrollDir.Vertical})

    self.bag_grid:SetSelectCallBack(BindTool.Bind(self.OnClickBagGridHandle, self))
    self.node_t_list.layout_bag.node:addChild(grid_node, 100)
end

function CScomposeView:OnClickBagGridHandle(cell)
    if nil == cell:GetData() then
        return
    end
    TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_CS_BAG)
end

function CScomposeView:OnFlush(param_t, index)
	local compose_data = EquipData.Instance:GetCsCompose()
	self.pre_icon:SetData(compose_data and compose_data.pre_data)
	self.pre_icon:MakeGray(not compose_data or #compose_data.consum_data < 3)
	for i = 1, 3 do
		self["input_cell_" .. i]:SetData(compose_data and compose_data.consum_data[i])
	end

    self.bag_grid:SetDataList(BagData.Instance:GetBagHandedDownList())
end

function CScomposeView:OnBagItemChange()
	self:Flush()
end

function CScomposeView:OnComposeChange()
	self:Flush()
end

return CScomposeView