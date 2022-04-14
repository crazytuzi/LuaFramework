BaseTreeOneMenu = BaseTreeOneMenu or class("BaseTreeOneMenu", BaseWidget)
local BaseTreeOneMenu = BaseTreeOneMenu

function BaseTreeOneMenu:ctor(parent_node, layer, parent_cls_name, twoLvMenuCls)
    --self.abName = "system"
    --self.assetName = "BaseTreeOneMenu"
    self.layer = layer
    self.parent_cls_name = parent_cls_name
    self.twoLvMenuCls = twoLvMenuCls or TreeTwoMenu

    self.menuitem_list = {}
    self.menuHeight = 0
    self.oldMenuHeight = 0
    self.select_sub_id = -1
    self.selected = false
    self.globalEvents = {}
    --self.model = 2222222222222end:GetInstance()
    --BaseTreeOneMenu.super.Load(self)
end

function BaseTreeOneMenu:dctor()
    if self.menuitem_list == nil then
        print("aaa")
    end
    if not table.isempty(self.menuitem_list) then
        for _, menuitem in pairs(self.menuitem_list) do
            menuitem:destroy()
        end
    end
    self.menuitem_list = nil
    if self.leftsecondmenuclick_event_id then
        GlobalEvent:RemoveListener(self.leftsecondmenuclick_event_id)
        self.leftsecondmenuclick_event_id = nil
    end

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end
end

function BaseTreeOneMenu:LoadCallBack()
    self.nodes = {
        "Image",
        "MenuText",
        "Content",
        "sel_img",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    self.rectTra = self.transform:GetComponent('RectTransform')
    self:ShowPanel()

    if self.need_set_pos_end then
        self:SetItemPosition(self.x, self.y)
    end
end

function BaseTreeOneMenu:AddEvent()
    local function call_back(target, x, y)
        FashionModel.GetInstance().default_sel_id = nil
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

function BaseTreeOneMenu:BrocastSecMenu()
    if self.sub_data[1] then
        GlobalEvent:Brocast(CombineEvent.SelectSecMenuDefault .. self.parent_cls_name, self.sub_data[1][1])
    end
end

function BaseTreeOneMenu:LoadChildMenu()
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
        menuitem:SetData(typeId, item, self.select_sub_id, self.twoLvMenuSpan, i)
        table.insert(self.menuitem_list, menuitem)
        self.menuHeight = self.menuHeight + menuitem:GetHeight()
    end
    self.oldMenuHeight = self.menuHeight
    self:ReLayout()
end

--选中物体 index:二级菜单索引
function BaseTreeOneMenu:SelectedItem(index)
    if not self.selected then
        for _, menuitem in pairs(self.menuitem_list) do
            if menuitem then
                menuitem:destroy()
                menuitem = nil
            end
        end
        self.menuitem_list = {}
        local typeId = self.data[1]
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
        --是不是感觉不太对,帮我改一下嘛
        if index and self.menuitem_list and self.menuitem_list[index] then
            self.menuitem_list[index]:Select(self.menuitem_list[index].data[1]);
        end
    end
    if self.parent_cls_name == "CombinePanel" then
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
    end
    GlobalEvent:Brocast(CombineEvent.LeftFirstMenuClick .. self.parent_cls_name, self.index, self.selected)
end
--好像不行@ling写的,不太了解整个
function BaseTreeOneMenu:SetItemSelected(index)
    if index and self.menuitem_list and self.menuitem_list[index] then
        self.menuitem_list[index]:Select(index);
    end
end

function BaseTreeOneMenu:SelectedItemDefault(index)
    if self.index == index then
        self:SelectedItem()
    end
end

function BaseTreeOneMenu:SetData(data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    self.oneLvMenuSpan = oneLvMenuSpan or 7
    self.twoLvMenuSpan = twoLvMenuSpan or 6
    self.data = data
    self.sub_data = sub_data
    self.index = index
    self.select_sub_id = select_sub_id
    if self.is_loaded then
        self:ShowPanel()
    end
    self:CheckRedDot()
end

function BaseTreeOneMenu:ReLayout()
    self.Content.sizeDelta = Vector2(0, self.menuHeight)
    self.Content.anchoredPosition = Vector2(0, 0 - 64)
end

function BaseTreeOneMenu:ShowPanel()
    if self.data ~= nil and self.data[2] ~= nil then
        self.MenuText:GetComponent('Text').text = self.data[2]
        self.transform.anchoredPosition = Vector2(self.transform.anchoredPosition.x, self.transform.anchoredPosition.y - (self.index - 1) * 64)
        if self:IsHaveSubId() then
            self:LoadChildMenu()
            self:ShowChildMenu(true)
            self:Select(true)
        end
    end
end

function BaseTreeOneMenu:GetHeight()
    --local a = self.rectTra.sizeDelta
    return self.rectTra.sizeDelta.y + self.oneLvMenuSpan + self.menuHeight
    --return 70 + self.menuHeight
end

function BaseTreeOneMenu:Select(flag)
    SetVisible(self.sel_img, flag)
end

function BaseTreeOneMenu:ShowChildMenu(is_show)
    self.Content.gameObject:SetActive(is_show)
    if is_show then
        self.menuHeight = self.oldMenuHeight
    else
        self.menuHeight = 0
        for _, menuitem in pairs(self.menuitem_list) do
            menuitem:destroy()
        end
        self.menuitem_list = {}
    end
end

function BaseTreeOneMenu:OnClick(clickindex)
    if clickindex == self.index then
        self.selected = not self.selected
    else
        self.selected = false
    end
    self:ShowChildMenu(self.selected)
    self:Select(self.selected)
end

function BaseTreeOneMenu:SetItemPosition(x, y)
    if self.is_loaded then
        self.transform.anchoredPosition = Vector2(x, y)
    else
        self.need_set_pos_end = true
        self.x = x
        self.y = y
    end
end

function BaseTreeOneMenu:IsHaveSubId()
    for _, sub_data in pairs(self.sub_data) do
        if sub_data[1] == self.select_sub_id then
            return true
        end
    end
    return false
end

--红点方法 需要的自行重写
function BaseTreeOneMenu:CheckRedDot()

end
function BaseTreeOneMenu:SetRedDot(isShow)

end
