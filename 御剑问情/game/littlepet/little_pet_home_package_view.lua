-- 宠物家园背包
LittlePetHomePackageView = LittlePetHomePackageView or BaseClass(BaseView)

local PACKAGE_MAX_GRID_NUM = 80	-- 4行 * 5列 * 4页
local PACKAGE_ROW = 4
local PACKAGE_COLUMN = 5
function LittlePetHomePackageView:__init()
	self.ui_config = {"uis/views/littlepetview_prefab","ShowHomePackagePetView"}
    self.pet_index = 0
    self.data_list = {}
end

function LittlePetHomePackageView:__delete()
end

function LittlePetHomePackageView:LoadCallBack()
    self.page = self:FindVariable("Page")
	self.package_pet_cell = {}
	self.package_list_view = self:FindObj("ListView")
	local list_delegate = self.package_list_view.list_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.PackageGetNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.PackageRefreshCell, self)

	self:ListenEvent("OnClickCloseButton", BindTool.Bind(self.OnClickClose, self))
end

function LittlePetHomePackageView:ReleaseCallBack()
	for k,v in pairs(self.package_pet_cell) do
		if v then
			v:DeleteMe()
		end
	end
	self.package_pet_cell = {}
	self.package_list_view = nil
    self.page = nil
end

function LittlePetHomePackageView:OpenCallBack()
	-- 计算页数
	local total_page_count = PACKAGE_MAX_GRID_NUM / (PACKAGE_ROW * PACKAGE_COLUMN)
	self.package_list_view.list_page_scroll:SetPageCount(total_page_count)
    self.page:SetValue(total_page_count)
    self.package_list_view.scroller:ReloadData(0)
    self:Flush()
end

function LittlePetHomePackageView:CloseCallBack()
end

function LittlePetHomePackageView:OnClickClose()
    self:Close()
end

function LittlePetHomePackageView:PackageGetNumberOfCells()
    return PACKAGE_MAX_GRID_NUM / PACKAGE_ROW
end

function LittlePetHomePackageView:PackageRefreshCell(cell, data_index)
    local group = self.package_pet_cell[cell]
    if group == nil then
        group = LittlePetHomePackageItemGroup.New(cell.gameObject)
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
        local up_arrow_flag = LittlePetData.Instance:ComparePetWithEquippedPet(data.item_id, self.pet_index + 1)
        group:SetData(i, {item_id = data.item_id, is_up_arrow = up_arrow_flag})
        group:ShowHighLight(i, false)
        group:SetHighLight(i, (self.cur_bag_index == index and nil ~= data.item_id))
        group:ListenClick(i, BindTool.Bind(self.HandlePackageOnClick, self, data, group, i, index))
        group:SetInteractable(i, nil ~= data.item_id)
    end
end

function LittlePetHomePackageView:OnFlush(param_t)
	for k,v in pairs(param_t) do
        if k == "index" then
    		self.pet_index = tonumber(v[1]) or 0
    		break
        end
	end
    self.data_list = LittlePetData.Instance:GetLittlePetHomePackageBestList()
    if self.package_list_view then
        self.package_list_view.scroller:RefreshAndReloadActiveCellViews(true)
    end
end

function LittlePetHomePackageView:HandlePackageOnClick(data, group, group_index, data_index)
	if nil == next(data) then return end

    local item_id = data.item_id or 0
    local lower_flag = LittlePetData.Instance:PackageCheckIsLowerQuality(item_id, self.pet_index)
    local bag_index = ItemData.Instance:GetItemIndex(item_id)
    if lower_flag then
        local des = Language.LittlePet.ExchangePetRemind
        local ok_callback = function ()
            local equip_id = LittlePetData.Instance:GetLittlePetIDByItemID(item_id)
            LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_PUTON, self.pet_index, bag_index)
            self:Close()
        end
	   TipsCtrl.Instance:ShowCommonAutoView("ExchangeEquipPet", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
    else
        LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_PUTON, self.pet_index, bag_index)
        self:Close()
    end
end

---------------------- 小宠物背包组 ----------------------
LittlePetHomePackageItemGroup = LittlePetHomePackageItemGroup or BaseClass(BaseCell)

function LittlePetHomePackageItemGroup:__init(instance)
    self.cells = {}
    for i = 1, PACKAGE_ROW do
        self.cells[i] = ItemCell.New()
        self.cells[i]:SetInstanceParent(self:FindObj("Item"..i))
    end
end

function LittlePetHomePackageItemGroup:__delete()
    for k, v in pairs(self.cells) do
        v:DeleteMe()
    end
    self.cells = {}
end

function LittlePetHomePackageItemGroup:SetData(i, data)
    self.cells[i]:SetData(data)
end

function LittlePetHomePackageItemGroup:ListenClick(i, handler)
    self.cells[i]:ListenClick(handler)
end

function LittlePetHomePackageItemGroup:SetToggleGroup(toggle_group)
    for k, v in ipairs(self.cells) do
        v:SetToggleGroup(toggle_group)
    end
end

function LittlePetHomePackageItemGroup:SetHighLight(i, enable)
    self.cells[i]:SetHighLight(enable)
end

function LittlePetHomePackageItemGroup:ShowHighLight(i, enable)
    self.cells[i]:ShowHighLight(enable)
end

function LittlePetHomePackageItemGroup:SetInteractable(i, enable)
    self.cells[i]:SetInteractable(enable)
end