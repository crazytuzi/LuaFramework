------------------------------------------------------------
-- 装备分解
------------------------------------------------------------
EquipDecomposeView = EquipDecomposeView or BaseClass(BaseView)

function EquipDecomposeView:__init()
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {
	}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"decompose_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
	}
	self.decompose_type = EQUIP_DECOMPOSE_TYPES.GOD_EQUIP
end

function EquipDecomposeView:__delete()
end

function EquipDecomposeView:ReleaseCallBack()
	if self.list then
		self.list:DeleteMe()
		self.list = nil
	end

	self.no_item_txt = nil
end

function EquipDecomposeView:LoadCallBack(index, loaded_times)
	self:CreateTopTitle(ResPath.GetWord("word_fenjie"), 275, 695)

	self:CreateList()

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function EquipDecomposeView:OpenCallBack()
end

function EquipDecomposeView:ShowIndexCallBack(index)
	self:Flush()
end

function EquipDecomposeView:OnFlush(param_t, index)
	self:FlushList()
end
-------------------------------------------------------------------------
function EquipDecomposeView:SetDecomposeType(type)
	self.decompose_type = type
end

function EquipDecomposeView:OnBagItemChange()
	self:Flush()
end

function EquipDecomposeView:FlushList()
	local cfg = EquipDecomposeConfig[self.decompose_type]
	local item_map = cfg.itemList
	local item_data_list = {}
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		if item_map[v.item_id] then
			item_data_list[#item_data_list + 1] = {item_data = v, decompose_cfg = item_map[v.item_id], decompose_type = self.decompose_type}
		end
	end
	self.list:SetDataList(item_data_list)

	local no_item = #item_data_list == 0
	if nil == self.no_item_txt and no_item then
		local size = self.node_t_list.layout_decompose.node:getContentSize()
		self.no_item_txt = XUI.CreateTextByType(size.width / 2, 600, 300, 20, "没有可分解的装备", 3)
		self.node_t_list.layout_decompose.node:addChild(self.no_item_txt, 99)
	elseif nil ~= self.no_item_txt then
		self.no_item_txt:setVisible(no_item)
	end
	self.list:JumpToTop(true)
end

function EquipDecomposeView:CreateList()
	self.list = ListView.New()
	local ph_list = self.ph_list.ph_list
	self.list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, nil, EquipDecomposeView.DecomposeItem, nil, nil, self.ph_list.ph_item)
	self.node_t_list.layout_decompose.node:addChild(self.list:GetView(), 100, 100)
	self.list:GetView():setAnchorPoint(0.5, 0.5)
	self.list:SetItemsInterval(8)
	self.list:JumpToTop(true)
end

---------------------------------------------
EquipDecomposeView.DecomposeItem = BaseClass(BaseRender)
local DecomposeItem = EquipDecomposeView.DecomposeItem
function DecomposeItem:__init()
end

function DecomposeItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function DecomposeItem:CreateChildCallBack()
	self.cell = BaseCell.New()
	self.cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(true)
	self.view:addChild(self.cell:GetView(), 10)

	self.txt_level = XUI.CreateText(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y - 45, 100, 16, nil, "", nil, 16, COLOR3B.WHITE, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self.view:addChild(self.txt_level, 10)

	XUI.AddClickEventListener(self.node_tree.btn_decompose.node, BindTool.Bind(self.OnClickBtn, self))
end

function DecomposeItem:OnClickBtn()
	if self.data == nil then return end

	BagCtrl.SendEquipDecompose(self.data.decompose_type, self.data.item_data.series)
end

function DecomposeItem:OnFlush()
	if self.data == nil then return end

	self.cell:SetData(self.data.item_data)
	local item_id = self.data.item_data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local item_color = string.format("%06x", item_cfg.color)
	local item_name = string.format("{color;%s;%s}", item_color, item_cfg.name)
	local award = self.data.decompose_cfg.award[1]
	local desc = string.format("分解可获得%s:%d", ItemData.Instance:GetItemConfig(award.id).name, award.count)
	RichTextUtil.ParseRichText(self.node_tree.rich_name.node, item_name)
	RichTextUtil.ParseRichText(self.node_tree.rich_desc.node, desc, 18, COLOR3B.OLIVE)

	local ji, zhuan = ItemData.GetItemLevel(item_id)
	local text = ""
	if zhuan > 0 then
		text = zhuan .. Language.Common.Zhuan
	else
		text = ji .. Language.Common.Ji
	end
	self.txt_level:setString(text)
end

function DecomposeItem:CreateSelectEffect()
end
