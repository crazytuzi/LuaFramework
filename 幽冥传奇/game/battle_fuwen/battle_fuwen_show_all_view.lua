ShowAllZhanwenView = ShowAllZhanwenView or BaseClass(BaseView)

function ShowAllZhanwenView:__init()
	if ShowAllZhanwenView.Instance then
		ErrorLog("ShowAllZhanwenView.Instance is have!!!")
	end
	ShowAllZhanwenView.Instance = self

	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/battle_fuwen.png'
	}
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}, nil, 999},
		{"battle_fuwen_ui_cfg", 5, {0}},
	}

end

function ShowAllZhanwenView:ReleaseCallBack()
	if self.grid_zhanwen_scroll_list then
		self.grid_zhanwen_scroll_list:DeleteMe()
		self.grid_zhanwen_scroll_list = nil
	end
end

function ShowAllZhanwenView:LoadCallBack(index, loaded_times)
	self.data = BattleFuwenData.Instance:GetZhanwenInfo()		--获取数据
	self:CreateZhanWenScroll()
	BattleFuwenData.Instance:AddEventListener(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
end

function ShowAllZhanwenView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ShowAllZhanwenView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ShowAllZhanwenView:OnDataChange(vo)
end

function ShowAllZhanwenView:CreateZhanWenScroll()
	if nil == self.grid_zhanwen_scroll_list then
		local ph = self.ph_list.ph_item_list
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, 160, ZhanWenPreviewRender, ScrollDir.Vertical, false, self.ph_list.ph_allinfo)
		self.grid_best_list = grid_scroll
		self.node_t_list.layout_show_all.node:addChild(grid_scroll:GetView(), 3)

		self.grid_best_list:SetDataList(BattleFuwenData.Instance:GetZhanWenViewList())
		self.grid_best_list:JumpToTop()
	end
end

function ShowAllZhanwenView:OnFlush()
	self.grid_best_list:SetDataList(BattleFuwenData.Instance:GetZhanWenViewList())
end

ZhanWenPreviewCellsRender = ZhanWenPreviewCellsRender or BaseClass(BaseRender)
function ZhanWenPreviewCellsRender:__init()
	self.item_cell = nil
end

function ZhanWenPreviewCellsRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ZhanWenPreviewCellsRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(40, 14)
	self.view:addChild(self.item_cell:GetView(), 7)

	self.text = XUI.CreateText(80, 2, 160, 20, cc.TEXT_ALIGNMENT_CENTER, "",nil, 16)
	self.view:addChild(self.text,999)
end

function ZhanWenPreviewCellsRender:OnFlush()
	if nil == self.data then
		return
	end
	local item_config = ItemData.Instance:GetItemConfig(self.data.id)
	
	self.item_cell:SetData(ItemData.FormatItemData(self.data))
	self.item_cell.item_icon:setPositionY(40)
	self.item_cell:SetCellBg(ResPath.GetZhanwen("img_cell_2"))
	
	self.text:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.text:setString(item_config.name .. " LV.1") 	--符文名称
end

function ZhanWenPreviewCellsRender:CreateSelectEffect()
end

ZhanWenPreviewRender = ZhanWenPreviewRender or BaseClass(BaseRender)
function ZhanWenPreviewRender:__init()
	self.item_cell = nil
end

function ZhanWenPreviewRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ZhanWenPreviewRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell_list
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ZhanWenPreviewCellsRender, nil, nil, {h = 96, w = 80})
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView())
	XUI.RichTextSetCenter(self.node_tree.rich_part.node)
end

function ZhanWenPreviewRender:OnFlush()
	if nil == self.data then
		return
	end
	self.cell_charge_list:SetDataList(self.data)
	RichTextUtil.ParseRichText(self.node_tree.rich_part.node, string.format("{CnNum;%s}", self:GetIndex()))
end

function ZhanWenPreviewRender:CreateSelectEffect()
end
