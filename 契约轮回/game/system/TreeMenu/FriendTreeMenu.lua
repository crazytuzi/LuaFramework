FriendTreeMenu = FriendTreeMenu or class("FriendTreeMenu", BaseTreeMenu)
local FriendTreeMenu = FriendTreeMenu

function FriendTreeMenu:ctor(parent_node, layer, parent_cls, isStickItemWhenClick, is_go_bottom)
    self.abName = "system"
    self.assetName = "FriendTreeMenu"
    self.layer = layer

    self.oneLvMenuCls = FriendTreeMenuItem
    
    if isStickItemWhenClick == true or isStickItemWhenClick == nil then
        self.isStickItemWhenClick = true
    else
        self.isStickItemWhenClick = false
    end

    if is_go_bottom then
        self.is_go_bottom = true
    end

    FriendTreeMenu.super.Load(self)
end

function FriendTreeMenu:dctor()

end

--更新数据
function FriendTreeMenu:UpdateData(data, sub_data)
    self.data = data
    self.sub_data = sub_data
    local count = #self.data
    self.leftHeight = 0
    for i = 1, count do
        local item = self.data[i]
        local menuItem = self.leftmenu_list[i]
        if menuItem then
            if i == 1 then
                menuItem.transform.anchoredPosition = Vector2(0, 0)
            else
                local p_item = self.leftmenu_list[i - 1]
                menuItem.transform.anchoredPosition = Vector2(0, p_item.transform.anchoredPosition.y - p_item:GetHeight())
            end
            menuItem:UpdateData(item, self.sub_data[item[1]])
            self.leftHeight = self.leftHeight + menuItem:GetHeight()
        end
    end
    self:RelayoutLeftMenu()
end

