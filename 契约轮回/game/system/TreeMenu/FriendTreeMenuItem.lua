FriendTreeMenuItem = FriendTreeMenuItem or class("FriendTreeMenuItem",BaseTreeOneMenu)
local FriendTreeMenuItem = FriendTreeMenuItem

function FriendTreeMenuItem:ctor(parent_node,layer, parent_cls_name)
	self.abName = "system"
	self.assetName = "FriendTreeMenuItem"
	self.layer = layer

	self.twoLvMenuCls = FriendTreeSubMenuItem

	--self.model = 2222222222222end:GetInstance()
	FriendTreeMenuItem.super.Load(self)
end


function FriendTreeMenuItem:dctor()
end

function FriendTreeMenuItem:AddEvent()
    local function call_back(target, x, y)
        self:SelectedItem(1)
        if self.selected then
            self:BrocastSecMenu()
        end
    end
    AddClickEvent(self.Image.gameObject, call_back)

    local function leftsecondmenuclick_call_back(menu_id, sel_type_id)
        self.select_sub_id = sel_type_id
        for i = 1, #self.menuitem_list do
            self.menuitem_list[i]:Select(sel_type_id)
        end
    end
    self.leftsecondmenuclick_event_id = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.parent_cls_name, leftsecondmenuclick_call_back)
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.SelectFstMenuDefault .. self.parent_cls_name, handler(self, self.SelectedItemDefault))
end

function FriendTreeMenuItem:ReLayout()
    self.Content.sizeDelta = Vector2(0, self.menuHeight)
    self.Content.anchoredPosition = Vector2(0, 0 - 70)
end

function FriendTreeMenuItem:UpdateData(data, sub_data)
    self.data = data
    self.sub_data = sub_data
    self.MenuText:GetComponent('Text').text = self.data[2]
    self.sub_data = sub_data
    for i=1, #self.sub_data do
        if self.menuitem_list[i] then
            self.menuitem_list[i]:UpdateData(self.sub_data[i])
        else
            if self.selected then
                local menuitem = self.twoLvMenuCls(self.Content, nil, self)
                menuitem:SetData(self.data[1], self.sub_data[i], self.select_sub_id, self.twoLvMenuSpan)
                table.insert(self.menuitem_list, menuitem)
                self.menuHeight = self.menuHeight + menuitem:GetHeight()
                self.oldMenuHeight = self.menuHeight
                self:ReLayout()
            end
        end
    end
    --删除
    if self.selected then
    if #self.menuitem_list > #self.sub_data then
        for i=#self.menuitem_list, #self.sub_data+1, -1 do
            self.menuHeight = self.menuHeight - self.menuitem_list[i]:GetHeight()
            self.menuitem_list[i]:destroy()
            self.menuitem_list[i] = nil
        end
        self.oldMenuHeight = self.menuHeight
        self:ReLayout()
    end
    end
end
