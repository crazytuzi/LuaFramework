EquipmentView = EquipmentView or BaseClass(XuiBaseView)

function EquipmentView:StoneInit()
	self.cur_stone_index = 1
	self:CreateStoneCells()
	self:CreateStonelist()
	self:CreateBsEquiplist()
	self:CreateStoneEquipTab()
	self.node_t_list.btn_bs_tips.node:addClickEventListener(BindTool.Bind1(self.OnClickBsTipHandler, self))
end

function EquipmentView:StoneDelete()
	if self.stone_cell_list then
		for k,v in pairs(self.stone_cell_list) do
			v:DeleteMe()
		end
		self.stone_cell_list = {}
	end
	if self.stone_eq_tabbar then
		self.stone_eq_tabbar:DeleteMe()
		self.stone_eq_tabbar = nil
	end
end

function EquipmentView:CreateStoneEquipTab()
	if nil == self.stone_eq_tabbar then
		self.stone_eq_index = 1
		self.stone_eq_tabbar = Tabbar.New()
		self.stone_eq_tabbar:CreateWithNameList(self.view.node_t_list["layout_qianghua"].node, 470, 536,
			function(index) self:StoneEquipChangeIndex(index) end,
			Language.Equipment.StoneTab,
			false, ResPath.GetCommon("toggle_104"))
		self.stone_eq_tabbar:SetSpaceInterval(15)
		self.stone_eq_tabbar:ChangeToIndex(self.stone_eq_index)
		self:StoneEquipChangeIndex(self.stone_eq_index)
	end
end

function EquipmentView:StoneEquipChangeIndex(index)
	if self.stone_eq_index ~= index then
		self.cur_stone_index = 1
	end
	self.stone_eq_index = index
	self:Flush(TabIndex.equipment_stone, "stone_eq_change")
end

function EquipmentView:CreateStoneCells()
	self.stone_cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list["ph_bscell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:GetView():setAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_stone.node:addChild(cell:GetView(), 100)
		cell:SetSkinStyle({cell_desc = Language.Equipment.StoneSlotTxt[i]})
		cell:SetIsShowTips(false)
		cell:AddClickEventListener(BindTool.Bind(self.SelectEquipStoneCallBack, self, cell))
		table.insert(self.stone_cell_list, cell)
	end
	local ph = self.ph_list.ph_bsequip_select
	self.cur_bs_cell = BaseCell.New()
	self.cur_bs_cell:SetPosition(ph.x, ph.y)
	self.cur_bs_cell:GetView():setAnchorPoint(0.5, 0.5)
	self.cur_bs_cell:SetCellBg(ResPath.GetCommon("cell_101"))
	self.node_t_list.layout_stone.node:addChild(self.cur_bs_cell:GetView(), 100)
end

function EquipmentView:CreateStonelist()
	local ph = self.ph_list.ph_bs_list
	self.stone_list = ListView.New()
	self.stone_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, StoneBagCell, nil, nil, self.ph_list.ph_bs_bag_cell)
	self.stone_list:SetItemsInterval(10)
	self.stone_list:SetSelectCallBack(BindTool.Bind1(self.SelectStoneItemCallBack, self))
	self.node_t_list.layout_stone.node:addChild(self.stone_list:GetView(), 100)
end

function EquipmentView:SelectStoneItemCallBack(cell)
	if nil == cell or nil == cell:GetData() then return end
	local slot = EquipmentData.GetStoneSlot(cell:GetData().item_id)
	local equip_series = self.cur_stone_equip and self.cur_stone_equip.series or 0
--	TipsCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROME_BAG_STONE, {inlay_hole_index = slot, equip_pos = self.stone_eq_index - 1, equip_series = equip_series})
end

function EquipmentView:SelectEquipStoneCallBack(cell)
	if nil == cell or nil == cell:GetData() then return end
	local slot = EquipmentData.GetStoneSlot(cell:GetData().item_id)
	local equip_series = self.cur_stone_equip and self.cur_stone_equip.series or 0
	TipsCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROME_EQUIP_STONE, {inlay_hole_index = slot, equip_pos = self.stone_eq_index - 1, equip_series = equip_series})
end

function EquipmentView:CreateBsEquiplist()
	local ph = self.ph_list.ph_bsequip_list
	self.bs_equip_list = ListView.New()
	self.bs_equip_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BsEquipRander, nil, nil, self.ph_list.ph_bsequip_rander)
	self.bs_equip_list:SetItemsInterval(10)
	self.bs_equip_list:SetMargin(2)
	-- self.bs_equip_list:SetJumpDirection(ListView.Top)
	self.bs_equip_list:SetSelectCallBack(BindTool.Bind1(self.SelectBsEquipItemCallBack, self))
	self.node_t_list.layout_stone.node:addChild(self.bs_equip_list:GetView(), 100)
end

function EquipmentView:SelectBsEquipItemCallBack(item)
	if item:GetData() and not item:GetData().empty then
		self.cur_stone_equip = item:GetData()
	else
		self.cur_stone_equip = nil
	end
	self.cur_stone_index = item:GetIndex()
	self:FlushCurStoneView()
end

function EquipmentView:StoneOnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:FlushCurStoneView()
		elseif k == "stone_eq_change" then
			local select_index = 0
			local old_Equip_count = self.bs_equip_list:GetCount()
			if self.stone_eq_index == 1 then
				self.bs_equip_list:SetDataList(EquipmentData.Instance:GetStoneRoleEquip())
				if self.cur_stone_index and EquipmentData.Instance:GetStoneRoleEquip()[self.cur_stone_index] then
					select_index = self.cur_stone_index
				end
			else
				self.bs_equip_list:SetDataList(EquipmentData.Instance:GetStoneBagEquip())
				if self.cur_stone_index and EquipmentData.Instance:GetStoneBagEquip()[self.cur_stone_index] then
					select_index = self.cur_stone_index
				end
			end

			if select_index > 0 then
				self.bs_equip_list:SelectIndex(select_index)
			end
			if self.cur_stone_equip then
				self.stone_list:SetDataList(EquipmentData.Instance:GetBagStoneList(self.cur_stone_equip.item_id))
			else
				self.stone_list:SetDataList(EquipmentData.Instance:GetBagStoneList())
			end
			if old_Equip_count ~= self.bs_equip_list:GetCount() then
				self.bs_equip_list:JumpToTop(true)
			end
		end
	end	
end

function EquipmentView:FlushCurStoneView()
	self.cur_bs_cell:SetData(self.cur_stone_equip)
	for k,v in pairs(self.stone_cell_list) do
		if self.cur_stone_equip and self.cur_stone_equip["slot_" .. k] then 
			local index = bit:_and(self.cur_stone_equip["slot_" .. k], 0x7F)
			local item_id = EquipmentData.GetStoneSlotitem(k, index)
			if item_id then
				v:SetData({item_id = item_id, num = 1, is_bind = 1})
			else
				v:SetData()
			end
		else
			v:SetData()
		end
	end
	if self.cur_stone_equip then
		self.stone_list:SetDataList(EquipmentData.Instance:GetBagStoneList(self.cur_stone_equip.item_id))
	else
		self.stone_list:SetDataList(EquipmentData.Instance:GetBagStoneList())
	end
end

function EquipmentView:OnClickBsTipHandler()
	DescTip.Instance:SetContent(Language.Equipment.StoneDetail, Language.Equipment.StoneTitle)
end

----------------------------------------------------------------------------------------------------
--宝石背包格子
----------------------------------------------------------------------------------------------------
StoneBagCell = StoneBagCell or BaseClass(BaseCell)
function StoneBagCell:__init()
	self.is_showtip = false
end

function StoneBagCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function StoneBagCell:CreateChild()
	BaseCell.CreateChild(self)
end

function StoneBagCell:SetData(data)
	if data and data.empty then
		data = nil
	end
	BaseCell.SetData(self, data)
end

-- 创建选中特效
function StoneBagCell:CreateSelectEffect()

end

----------------------------------------------------------------------------------------------------
--宝石装备格子
----------------------------------------------------------------------------------------------------
BsEquipRander = BsEquipRander or BaseClass(BaseRender)
function BsEquipRander:__init()
	self:AddClickEventListener()
end

function BsEquipRander:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	if self.stone_cell_list then
		for k,v in pairs(self.stone_cell_list) do
			v:DeleteMe()
		end
		self.stone_cell_list = {}
	end
end

function BsEquipRander:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_bsequip
	self.cell = BaseCell.New()
	self.cell:SetPosition(ph.x, ph.y)
	self.cell:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.cell:GetView(), 100)
	self.stone_cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list["ph_bscell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:GetView():setScale(0.4)
		self.view:addChild(cell:GetView(), 100)
		table.insert(self.stone_cell_list, cell)
	end
end

function BsEquipRander:OnFlush()
	if self.data == nil then return end
	if self.data.empty then
		self.data = nil
		self.cell:SetData()
		for k,v in pairs(self.stone_cell_list) do
			v:SetData()
		end
		self.node_tree.lbl_equip_name.node:setString("")
	else
		self.cell:SetData(self.data)
		for k,v in pairs(self.stone_cell_list) do
			if self.data["slot_" .. k] > 0 then
				local index = bit:_and(self.data["slot_" .. k], 0x7F)
				local item_id = EquipmentData.GetStoneSlotitem(k, index)
				if item_id then
					v:SetData({item_id = item_id, num = 1, is_bind = 0})
				else
					v:SetData()
				end
			else
				v:SetData()
			end
		end
		local equip_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		self.node_tree.lbl_equip_name.node:setString(equip_cfg.name)
	end
end