TipTianshenhutiBoxShowView = TipTianshenhutiBoxShowView or BaseClass(BaseView)

local ROW = 10
local COLUMN = 5
local MAX_NUM = 50

function TipTianshenhutiBoxShowView:__init()
	self.ui_config = {"uis/views/tips/showtreasuretips_prefab", "ShowTreasureTips"}
	TipTianshenhutiBoxShowView.Instance = self
	self.current_grid_index = -1
	self.chest_shop_mode = nil
	self.play_audio = true
	self.contain_cell_list = {}
	self.view_layer = UiLayer.Pop
	self.data_list = {}
end

function TipTianshenhutiBoxShowView:__delete()
	TipTianshenhutiBoxShowView.Instance = nil
end

function TipTianshenhutiBoxShowView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.TreasureReward)
	end

	for k, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
	self.page_toggle_1 = nil
	--self.effect_1 = nil
	self.text_animator = nil
	self.btn_text_1 = nil
	self.btn_text_2 = nil
	self.is_play_ani = nil
	self.show_toggle_list = nil
	self.list_view = nil
	self.back_warehouse_btn = nil
	self.show_one_btn = nil
end

function TipTianshenhutiBoxShowView:LoadCallBack()
	self.contain_cell_list = {}
	self.list_view = self:FindObj("list_view")
	self:ListenEvent("close_tips_click",BindTool.Bind(self.OnCloseTipsClick, self))
	self:ListenEvent("OneClick",BindTool.Bind(self.OneClick, self))
	self:ListenEvent("back_warehouse_click",BindTool.Bind(self.OnBackWareHouseClick, self))
	self:ListenEvent("again_click",BindTool.Bind(self.OnAgainClick, self))


	self.page_toggle_1 = self:FindObj("page_toggle_1")
	--self.effect_1 = self:FindObj("EffectRoot")
	self.text_animator = self:FindObj("text_frame").animator

	self.btn_text_1 = self:FindVariable("btn_text_1")
	self.btn_text_2 = self:FindVariable("btn_text_2")
	self.is_play_ani = self:FindVariable("is_play_ani")
	self.show_one_btn = self:FindVariable("ShowOneBtn")

	self.show_toggle_list = {}
	for i=1,7 do
		self.show_toggle_list[i] = self:FindVariable("show_page_toggle_"..i)
	end
	self:InitListView()
end

function TipTianshenhutiBoxShowView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipTianshenhutiBoxShowView:OpenCallBack()

end

function TipTianshenhutiBoxShowView:GetNumberOfCells()
	return self.page
end

function TipTianshenhutiBoxShowView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShowTshtBoxContain.New(cell.gameObject)
		contain_cell.parent_view = self
		self.contain_cell_list[cell] = contain_cell
	end

	--改变排列方式
	contain_cell:ChangeLayoutGroup()

	local page = cell_index + 1
	contain_cell:SetPage(page)
	for i = 1, ROW do
		local index = page * 10 - (ROW - i)
		local data = nil
		data = self.data_list[index] or {}

		contain_cell:SetToggleGroup(i, self.list_view.toggle_group)
		contain_cell:SetData(i, data)
		contain_cell:ListenClick(i, BindTool.Bind(self.OnClickItem, self, contain_cell, i, index, data))
	end
end

function TipTianshenhutiBoxShowView:OnClickItem(group, group_index, index, data)
	self.current_grid_index = index
	group:SetToggle(group_index, index == self.current_grid_index)
	local close_call_back = function()
		group:SetToggle(group_index, false)
	end
	TianshenhutiCtrl.Instance:ShowEquipTips(data, nil, close_callback)
end

function TipTianshenhutiBoxShowView:OnCloseTipsClick()
	self:Close()
end

function TipTianshenhutiBoxShowView:OneClick()
	self:Close()
end

function TipTianshenhutiBoxShowView:OnBackWareHouseClick()
	self:Close()
end

function TipTianshenhutiBoxShowView:OnAgainClick()
	if self.again_func then
		self.again_func()
	end
end

function TipTianshenhutiBoxShowView:OnFlush()
	self.show_one_btn:SetValue(self.again_func == nil)
	if self.again_func then
		self.btn_text_1:SetValue(Language.RechargeChouChouLe.Sure)
		self.btn_text_2:SetValue(Language.RechargeChouChouLe.AgainOne)
	end
	self.page_toggle_1.toggle.isOn = true
	self.text_animator:SetBool("is_open", true)
	local count = self.data_list[0] and #self.data_list + 1 or #self.data_list
	self.page = math.ceil(count/10)
	for i=1,7 do
		self.show_toggle_list[i]:SetValue(i <= self.page and self.page > 1)
	end
	self.list_view.scroller:ReloadData(0)
end

function TipTianshenhutiBoxShowView:SetData(data_list, again_func)
	self.data_list = data_list
	self.again_func = again_func
	self:Open()
	self:Flush()
end

function TipTianshenhutiBoxShowView:GetPageCount()
	return self.page or 0
end

----------------------------------------------------------
ShowTshtBoxContain = ShowTshtBoxContain  or BaseClass(BaseCell)

function ShowTshtBoxContain:__init()
	self.parent_view = nil
	self.treasure_contain_list = {}
	for i = 1, 10 do
		self.treasure_contain_list[i] = TshtBoxShowItemCell.New(self:FindObj("item_" .. i))
	end
end

function ShowTshtBoxContain:__delete()
	self.parent_view = nil
	for k, v in pairs(self.treasure_contain_list) do
		v:DeleteMe()
	end
	self.treasure_contain_list = {}
end

function ShowTshtBoxContain:SetPage(page)
	self.page = page
end

function ShowTshtBoxContain:GetPage()
	return self.page
end

function ShowTshtBoxContain:SetToggleGroup(i, toggle_group)
	self.treasure_contain_list[i]:SetToggleGroup(toggle_group)
end

function ShowTshtBoxContain:SetData(i, data)
	self.treasure_contain_list[i]:SetData(data)
end

function ShowTshtBoxContain:ListenClick(i, handler)
	self.treasure_contain_list[i]:ListenClick(handler)
end

function ShowTshtBoxContain:ShowHighLight(i, enable)
	self.treasure_contain_list[i]:ShowHighLight(enable)
end

function ShowTshtBoxContain:SetToggle(i, enable)
	self.treasure_contain_list[i]:SetToggle(enable)
end

function ShowTshtBoxContain:SetAlpha(i, value)
	self.treasure_contain_list[i]:SetAlpha(value)
end

function ShowTshtBoxContain:GetTransForm(i)
	return self.treasure_contain_list[i]:GetTransForm()
end

--改变排列方式
function ShowTshtBoxContain:ChangeLayoutGroup()
	if self.parent_view then
		local page_count = self.parent_view:GetPageCount()
		local enum = 0
		if page_count > 1 then
			enum = UnityEngine.TextAnchor.UpperLeft
		else
			enum = UnityEngine.TextAnchor.MiddleCenter
		end
		self.root_node.grid_layout_group.childAlignment = enum
	end
end


TshtBoxShowItemCell = TshtBoxShowItemCell  or BaseClass(BaseRender)

function TshtBoxShowItemCell:__init()
	self.sword = self:FindVariable("sword")
	self.sword_bg = self:FindVariable("sword_bg")
	self.is_sword = self:FindVariable("is_sword")
	self.treasure_item = TianshenhutiEquipItemCell.New()
	self.treasure_item:SetInstanceParent(self:FindObj("item"))
end

function TshtBoxShowItemCell:__delete()
	if self.treasure_item then
		self.treasure_item:DeleteMe()
	end
end

function TshtBoxShowItemCell:SetToggleGroup(toggle_group)
	self.treasure_item:SetToggleGroup(toggle_group)
end

function TshtBoxShowItemCell:SetData(data)
	if not next(data) then
		self:SetActive(false)
	else
		self:SetActive(true)
	end

	self.is_sword:SetValue(false)
	self.treasure_item:SetData(data)
end

function TshtBoxShowItemCell:ListenClick(handler)
	self.treasure_item:ListenClick(handler)
end

function TshtBoxShowItemCell:ShowHighLight(enable)
	self.treasure_item:ShowHighLight(enable)
end

function TshtBoxShowItemCell:SetToggle(enable)
	self.treasure_item:SetToggle(enable)
end

function TshtBoxShowItemCell:SetAlpha(value)
	if self.root_node.canvas_group then
		self.root_node.canvas_group.alpha = value
	end
end

function TshtBoxShowItemCell:IsNil()
	return not self.root_node or not self.root_node.gameObject.activeInHierarchy
end

function TshtBoxShowItemCell:GetTransForm()
	return self.root_node.transform
end
