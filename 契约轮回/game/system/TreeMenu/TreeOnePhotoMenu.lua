-- @Author: lwj
-- @Date:   2018-12-21 10:12:34
-- @Last Modified by:   win 10
-- @Last Modified time: 2018-12-21 10:12:34

TreeOnePhotoMenu = TreeOnePhotoMenu or class("TreeOnePhotoMenu", BaseTreeOneMenu)
local TreeOnePhotoMenu = TreeOnePhotoMenu

function TreeOnePhotoMenu:ctor(parent_node, layer, parent_cls_name, twoLvMenuCls)
    self.abName = "system"
    self.assetName = "TreeOnePhotoMenu"
    self.layer = layer


    --self.model = 2222222222222end:GetInstance()
    TreeOnePhotoMenu.super.Load(self)
end

function TreeOnePhotoMenu:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function TreeOnePhotoMenu:AddEvent()
    local function call_back(target, x, y)
        self:SelectedItem(1)
    end
    AddClickEvent(self.Image.gameObject, call_back)

    local function leftsecondmenuclick_call_back(menu_id, sel_type_id)
        for i = 1, #self.menuitem_list do
            self.menuitem_list[i]:Select(sel_type_id)
        end
    end
    self.leftsecondmenuclick_event_id = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.parent_cls_name, leftsecondmenuclick_call_back)
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.SelectFstMenuDefault .. self.parent_cls_name, handler(self, self.SelectedItemDefault))
end

function TreeOnePhotoMenu:LoadCallBack()
    self.nodes = {
        "red_content",
    }
    self:GetChildren(self.nodes)
    TreeOnePhotoMenu.super.LoadCallBack(self)
end

function TreeOnePhotoMenu:LoadChildMenu()
    local typeId = self.data[1]
    for _, menuitem in pairs(self.menuitem_list) do
        menuitem:destroy()
    end
    self.menuitem_list = {}
    local subtypes = self.sub_data
    local count = #subtypes
    self.menuHeight = 0
    for i = 1, count do
        local item = subtypes[i]
        local menuitem = self.twoLvMenuCls(self.Content, nil, self)
        menuitem:SetData(typeId, item, self.select_sub_id, nil, i)
        table.insert(self.menuitem_list, menuitem)
        self.menuHeight = self.menuHeight + menuitem:GetHeight()
    end
    self.oldMenuHeight = self.menuHeight
    self:ReLayout()
end

function TreeOnePhotoMenu:SelectedItem(index)
    if not self.selected then
        local typeId = self.data[1]
        for _, menuitem in pairs(self.menuitem_list) do
            menuitem:destroy()
        end
        self.menuitem_list = {}
        self.menuHeight = 0
        local subtypes = self.sub_data
        local count = #subtypes
        for i = 1, count do
            local item = subtypes[i]
            local menuitem = self.twoLvMenuCls(self.Content, nil, self)
            menuitem:SetData(typeId, item, nil, nil, i)
            table.insert(self.menuitem_list, menuitem)
            self.menuHeight = self.menuHeight + menuitem:GetHeight()
        end
        self.oldMenuHeight = self.menuHeight
        self:ReLayout()
        if index and self.menuitem_list and self.menuitem_list[index] then
            self.menuitem_list[index]:Select(self.menuitem_list[index].data[1]);
        end
    end
    local sec_id = self.menuitem_list[1].data[1]
    local defa_sec_id = CombineModel.GetInstance().default_sec_id
    if defa_sec_id then
        sec_id = defa_sec_id
        CombineModel.GetInstance().default_sec_id = nil
    end
    self.select_sec_menu_id = sec_id
    for i = 1, #self.menuitem_list do
        self.menuitem_list[i]:SelectDefault(self.select_sec_menu_id)
    end
    GlobalEvent:Brocast(CombineEvent.LeftFirstMenuClick .. self.parent_cls_name, self.index, self.selected)
end

function TreeOnePhotoMenu:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_content, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(-9, -10)
    self.red_dot:SetRedDotParam(isShow)
end

function TreeOnePhotoMenu:CheckRedDot()
    local is_show_red = false
    local list = self.sub_data
    for i = 1, #list do
        local is_show_sec_red = false
        local id = list[i][1]
        local p_title = TitleModel.GetInstance():GetPTitleBySunId(id)
        if not p_title then
            local num = BagModel.GetInstance():GetItemNumByItemID(id)
            local is_showed = TitleModel.GetInstance():CheckIsShowedRedById(id)
            if num > 0 and is_showed == nil then
                is_show_red = true
                is_show_sec_red = true
            end
        end
        self.sub_data[i].is_show_red = is_show_sec_red
    end

    self:SetRedDot(is_show_red)
    return is_show_red
end

