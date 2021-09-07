-- 宠物家园回收
LittlePetHomeRecycleView = LittlePetHomeRecycleView or BaseClass(BaseView)

local PACKAGE_MAX_GRID_NUM = 80	-- 4行 * 5列 * 4页
local PACKAGE_ROW = 4
local PACKAGE_COLUMN = 5
function LittlePetHomeRecycleView:__init()
	self.ui_config = {"uis/views/littlepetview","ShowHomeRecyclePetView"}
    self.data_list = {}
end

function LittlePetHomeRecycleView:__delete()
end

function LittlePetHomeRecycleView:LoadCallBack()
    self.recycle_score = self:FindVariable("Score")
    self.page = self:FindVariable("Page")
	self.package_pet_cell = {}
	self.package_list_view = self:FindObj("ListView")
	local list_delegate = self.package_list_view.list_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.PackageGetNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.PackageRefreshCell, self)

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
    self:ListenEvent("OnClickExchangeButton", BindTool.Bind(self.OnClickExchangeButton, self))
    self:ListenEvent("OnClickRecycleButton", BindTool.Bind(self.OnClickRecycleButton, self))
    self:ListenEvent("OnClickAutoFilt", BindTool.Bind(self.OnClickAutoFilt, self))
end

function LittlePetHomeRecycleView:ReleaseCallBack()
	for k,v in pairs(self.package_pet_cell) do
		if v then
			v:DeleteMe()
		end
	end
	self.package_pet_cell = {}
	self.package_list_view = nil
    self.page = nil
    self.recycle_score = nil
end

function LittlePetHomeRecycleView:OpenCallBack()
	-- 计算页数
	local total_page_count = PACKAGE_MAX_GRID_NUM / (PACKAGE_ROW * PACKAGE_COLUMN)
	self.package_list_view.list_page_scroll:SetPageCount(total_page_count)
    self.page:SetValue(total_page_count)

    -- 回收选择列表
    self.selected_data_list = {}
    -- 回收积分初始化为0
    self.recycle_score:SetValue(0)
    self.data_list = LittlePetData.Instance:GetLittlePetRecycleData()
    self:Flush()
end

function LittlePetHomeRecycleView:CloseCallBack()
end

function LittlePetHomeRecycleView:OnClickClose()
    self:Close()
end

function LittlePetHomeRecycleView:OnFlush(param_t)
    self.data_list = LittlePetData.Instance:GetLittlePetRecycleData()
    for k,v in pairs(param_t) do
        if k == "clear" then
            -- 回收选择列表
            self.selected_data_list = {}
            -- 回收积分初始化为0
            self.recycle_score:SetValue(0)
            -- self.package_list_view.scroller:RefreshActiveCellViews()
        end
    end
    if self.package_list_view then
        self.package_list_view.scroller:RefreshAndReloadActiveCellViews(true)
    end
end

function LittlePetHomeRecycleView:PackageGetNumberOfCells()
    return PACKAGE_MAX_GRID_NUM / PACKAGE_ROW
end

function LittlePetHomeRecycleView:PackageRefreshCell(cell, data_index)
    local group = self.package_pet_cell[cell]
    if group == nil then
        group = LittlePetHomeRecycleGroup.New(cell.gameObject)
        self.package_pet_cell[cell] = group
    end

    group:SetToggleGroup(self.package_list_view.toggle_group)
    local page = math.floor(data_index / PACKAGE_COLUMN)
    local column = data_index - page * PACKAGE_COLUMN
    local grid_count = PACKAGE_COLUMN * PACKAGE_ROW
    for i = 1, PACKAGE_ROW do
        local index = (i - 1) * PACKAGE_COLUMN + column + (page * grid_count)
        local data = nil
        data = self.data_list[index + 1]
        data = data or {}
        if data.index == nil then
            data.index = index
        end
        local up_arrow_flag = LittlePetData.Instance:CheckIsHigherEquip(data.item_id)
        group:SetData(i, {item_id = data.item_id, is_up_arrow = up_arrow_flag})
        group:ListenClick(i, BindTool.Bind(self.HandlePackageOnClick, self, data, group, i, index))
        group:SetInteractable(i, nil ~= data.item_id)
        group:ShowHighLight(i, false)
        group:SetSelected(i, data.index ~= nil and self.selected_data_list[index] ~= nil)
    end
end

function LittlePetHomeRecycleView:HandlePackageOnClick(data, group, group_index, data_index)
    if self.selected_data_list[data_index] then
        self.selected_data_list[data_index] = nil
        group:SetSelected(group_index, false)
    else
        local temp_list = {}
        local recycle_score, recycle_type = LittlePetData.Instance:GetRecycleDataByItemID(data.item_id)
        temp_list.item_id = data.item_id or 0
        temp_list.recycle_score = recycle_score or 0
        temp_list.recycle_type = recycle_type or 0
        temp_list.num = 1
        temp_list.index = data.index
        self.selected_data_list[data_index] = temp_list
        group:SetSelected(group_index, true)
    end

    self:FlushScore()
end

function LittlePetHomeRecycleView:SetItemHighLight()
end

function LittlePetHomeRecycleView:OnClickExchangeButton()
   ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_exchange)
   self:Close()
end

function LittlePetHomeRecycleView:OnClickRecycleButton()
    for k,v in pairs(self.selected_data_list) do
        PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
    end
    self.selected_data_list = {}
end

function LittlePetHomeRecycleView:OnClickAutoFilt()
    LittlePetCtrl.Instance:OpenRecyleView(BindTool.Bind(self.AutoRecyleColor, self))
end

function LittlePetHomeRecycleView:AutoRecyleColor(color)
    for i = 1, PACKAGE_MAX_GRID_NUM do
        if self.data_list[i] then
            local select_flag, cfg_color = LittlePetData.Instance:CheckIsHigherEquip(self.data_list[i].item_id)
            if cfg_color <= color and not select_flag then
                local temp_list = {}
                local recycle_score, recycle_type = LittlePetData.Instance:GetRecycleDataByItemID(self.data_list[i].item_id)
                temp_list.item_id = self.data_list[i].item_id or 0
                temp_list.recycle_score = recycle_score or 0
                temp_list.recycle_type = recycle_type or 0
                temp_list.num = 1
                temp_list.index = self.data_list[i].index
                self.selected_data_list[i - 1] = temp_list
            else
                self.selected_data_list[i - 1] = nil
            end
        end
    end
    if self.package_list_view then
        self.package_list_view.scroller:RefreshAndReloadActiveCellViews(true)
    end
    self:FlushScore()
end

function LittlePetHomeRecycleView:FlushScore()
    local total_score = 0
    for k,v in pairs(self.selected_data_list) do
        total_score = total_score + v.recycle_score
    end
    self.recycle_score:SetValue(total_score)
end

---------------------- 小宠物背包组 ----------------------
LittlePetHomeRecycleGroup = LittlePetHomeRecycleGroup or BaseClass(BaseCell)

function LittlePetHomeRecycleGroup:__init(instance)
    self.cells = {}
    self.selected_list = {}
    for i = 1, PACKAGE_ROW do
        self.cells[i] = ItemCell.New()
        self.cells[i]:SetInstanceParent(self:FindObj("Item"..i))
        self.selected_list[i] = self:FindVariable("IsSelected"..i)
    end
end

function LittlePetHomeRecycleGroup:__delete()
    for k, v in pairs(self.cells) do
        v:DeleteMe()
    end
    self.cells = {}
end

function LittlePetHomeRecycleGroup:SetData(i, data)
    self.cells[i]:SetData(data)
end

function LittlePetHomeRecycleGroup:ListenClick(i, handler)
    self.cells[i]:ListenClick(handler)
end

function LittlePetHomeRecycleGroup:SetToggleGroup(toggle_group)
    for k, v in ipairs(self.cells) do
        v:SetToggleGroup(toggle_group)
    end
end

function LittlePetHomeRecycleGroup:SetInteractable(i, enable)
    self.cells[i]:SetInteractable(enable)
end

function LittlePetHomeRecycleGroup:SetSelected(i, enable)
    self.selected_list[i]:SetValue(enable)
end

function LittlePetHomeRecycleGroup:ShowHighLight(i, enable)
    self.cells[i]:ShowHighLight(enable)
end