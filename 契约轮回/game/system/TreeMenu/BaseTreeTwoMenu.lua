BaseTreeTwoMenu = BaseTreeTwoMenu or class("BaseTreeTwoMenu", BaseWidget)
local SecondMenuItem = BaseTreeTwoMenu

function BaseTreeTwoMenu:ctor(parent_node, layer, first_menu_item)
    --self.abName = "system"
    --self.assetName = "BaseTreeTwoMenu"
    self.layer = layer
    self.first_menu_item = first_menu_item
    self.parent_cls_name = self.first_menu_item.parent_cls_name

    self.globalEvents = {}
    self.select_sub_id = -1
    self.index = 1
    -- self.model=CombineModel.GetInstance()
    --BaseTreeTwoMenu.super.Load(self)
end

function BaseTreeTwoMenu:dctor()
    if self.sche_id ~= nil then
        GlobalSchedule:Stop(self.sche_id)
    end

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end

    if self.first_menu_item then
        self.first_menu_item = nil
    end
end

function BaseTreeTwoMenu:LoadCallBack()
    self.nodes = {
        "Image",
        "Text",
        "sel_img",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self.rectTra = self.transform:GetComponent('RectTransform')

    self:ShowPanel()
end

function BaseTreeTwoMenu:AddEvent()
    local function call_back(target, x, y)
        self.first_menu_item.select_sec_menu_id = self.data[1]
        GlobalEvent:Brocast(CombineEvent.LeftSecondMenuClick .. self.parent_cls_name, self.first_menu_id, self.data[1], nil, self.index, self:GetHeight())
    end
    AddClickEvent(self.Image.gameObject, call_back)

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.SelectSecMenuDefault .. self.parent_cls_name, handler(self, self.SelectDefault))
end

function BaseTreeTwoMenu:SelectDefault(data)
    if data == self.data[1] then
        local tart_id = FashionModel.GetInstance().default_sel_id or self.data[1]
        self.first_menu_item.select_sec_menu_id = tart_id
        GlobalEvent:Brocast(CombineEvent.LeftSecondMenuClick .. self.parent_cls_name, self.first_menu_id, tart_id, self.data.is_show_red, self.index, self:GetHeight())
    end
end

function BaseTreeTwoMenu:SetData(first_menu_id, data, select_sub_id, menuSpan, index)
    self.first_menu_id = first_menu_id
    self.data = data
    self.select_sub_id = select_sub_id
    self.menuSpan = menuSpan or 6
    self.index = index or 1
    if self.is_loaded then
        self:ShowPanel()
    end
end

function BaseTreeTwoMenu:ShowPanel()
    if self.data then
        if self.Text then
            self.Text:GetComponent('Text').text = self.data[2]
        end
        self:Select(self.select_sub_id)
    end
end

function BaseTreeTwoMenu:GetHeight()
    return self.rectTra.sizeDelta.y + self.menuSpan
end

function BaseTreeTwoMenu:Select(sel_type_id)
    self.select_sub_id = sel_type_id
    SetVisible(self.sel_img, self.data[1] == sel_type_id)
end

function BaseTreeTwoMenu:SetRedDot(isShow)
end