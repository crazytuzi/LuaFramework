BaseTreeMenu = BaseTreeMenu or class("BaseTreeMenu", BaseWidget)
local this = BaseTreeMenu

function BaseTreeMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCls)
    -- self.abName = "system"
    -- self.assetName = "BaseTreeMenu"
    self.layer = layer
    self.parent_cls_name = parent_cls and parent_cls.__cname or ""

    self.oneLvMenuCls = oneLvMenuCls or TreeOneMenu
    self.twoLvMenuCls = twoLvMenuCls or TreeTwoMenu
    self.globalEvents = {}
    self.leftmenu_list = {}
    self.leftHeight = 0
    self.select_sub_id = -1
    self.first_item_height = 70
    self.content_anchored_x = 0
    self.isStickItemWhenClick = true
    self.isMovingContent = false
    self.click_index = 1
    self.is_go_bottom = false
    --self.model = 2222222222222end:GetInstance()
    --BaseTreeMenu.super.Load(self)
end

function BaseTreeMenu:dctor()
    for _, menuitem in pairs(self.leftmenu_list) do
        menuitem:destroy()
    end
    self.leftmenu_list = nil
    if self.leftfirstmenuclick_event_id then
        GlobalEvent:RemoveListener(self.leftfirstmenuclick_event_id)
        self.leftfirstmenuclick_event_id = nil
    end

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end

    self.globalEvents = {}
end

function BaseTreeMenu:LoadCallBack()
    self.nodes = {
        "LeftScrollView/Viewport/LeftContent",
        "LeftScrollView",
        "LeftScrollView/Viewport",
    }
    self:GetChildren(self.nodes)
    self.content_rect = GetRectTransform(self.LeftContent)
    self.content_anchored_x = self.content_rect.anchoredPosition.x
    self.scroll = GetScrollRect(self.LeftScrollView)
    self.view_port_rect = GetRectTransform(self.Viewport)
    self.scroll_rect = GetRectTransform(self.LeftScrollView)
    self:UpdateView()
    self:AddEvent()
end

function BaseTreeMenu:ResetMoveMentType()
    if not self.isMovingContent then
        self.scroll.movementType = UnityEngine.UI.ScrollRect.MovementType.Elastic
    end
end

function BaseTreeMenu:AddEvent()
    local function leftfirstmenuclick_call_back(ClickIndex, isShow)
        self.leftHeight = 0
        local c_item, p_item
        for i = 1, #self.leftmenu_list do
            c_item = self.leftmenu_list[i]
            --c_item:ShowChildMenu(i==ClickIndex)
            --c_item:Select(i==ClickIndex)
            c_item:OnClick(ClickIndex)
            if i == 1 then
                c_item:SetItemPosition(0, 0)
            else
                local p_item = self.leftmenu_list[i - 1]
                c_item:SetItemPosition(0, p_item.transform.anchoredPosition.y - p_item:GetHeight())
            end
            self.leftHeight = self.leftHeight + c_item:GetHeight()
        end
        self:RelayoutLeftMenu()

        self.click_index = ClickIndex
        if isShow then
            self.scroll.movementType = UnityEngine.UI.ScrollRect.MovementType.Elastic
        else
            if ClickIndex ~= 1 and self.isStickItemWhenClick then
                local times = ClickIndex - 1
                local move_dis = times * self.first_item_height
                --SetAnchoredPosition(self.content_rect, self.content_anchored_x, move_dis, 0)
                self.isMovingContent = true
                self.scroll.movementType = UnityEngine.UI.ScrollRect.MovementType.Unrestricted
                cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.content_rect)
                local time = 0.2
                local moveAction = cc.MoveTo(time, self.content_anchored_x, move_dis, 0)
                local function end_call_back()
                    self.isMovingContent = false
                end
                local call_action = cc.CallFunc(end_call_back)
                local sys_action = cc.Sequence(moveAction, cc.DelayTime(0.2), call_action)
                cc.ActionManager:GetInstance():addAction(sys_action, self.content_rect)
            end
        end
    end
    self.leftfirstmenuclick_event_id = GlobalEvent:AddListener(CombineEvent.LeftFirstMenuClick .. self.parent_cls_name, leftfirstmenuclick_call_back)

    if self.isStickItemWhenClick then
        self.scroll.onValueChanged:AddListener(handler(self, self.ResetMoveMentType))
    end

    local function call_back(first_id, data, is_show_red, index, height)
        local function call_back2()
            if self.is_go_bottom then
                self:MoveMenu(index, height)
            end
        end
        GlobalSchedule:StartOnce(call_back2, 0.2)
    end
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.parent_cls_name, call_back)
end

function BaseTreeMenu:MoveMenu(index, height)
    if self.is_go_bottom then
        local times = self.click_index - 1
        local viewrect_height = GetSizeDeltaY(self.view_port_rect)
        local dis = 0
        local move_dis = 0
        if self.first_item_height + index * height > viewrect_height then
            dis = self.first_item_height + index * height - viewrect_height
            move_dis = times * self.first_item_height + dis
        end
        local y = GetLocalPositionY(self.content_rect)
        --SetAnchoredPosition(self.content_rect, self.content_anchored_x, move_dis, 0)
        self.isMovingContent = true
        --self.scroll.movementType = UnityEngine.UI.ScrollRect.MovementType.Unrestriscted
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.content_rect)
        local time = 0.2
        local moveAction = cc.MoveTo(time, self.content_anchored_x, move_dis, 0)
        local function end_call_back()
            self.isMovingContent = false
        end
        local call_action = cc.CallFunc(end_call_back)
        local sys_action = cc.Sequence(moveAction, cc.DelayTime(0.2), call_action)
        cc.ActionManager:GetInstance():addAction(sys_action, self.content_rect)
    end
end

function BaseTreeMenu:SetStickXAxis(x)
    self.content_anchored_x = x
end

function BaseTreeMenu:SetScrollSize(x, y)
    SetSizeDelta(self.scroll_rect, x, y)
end

function BaseTreeMenu:SetViewSize(x, y)
    SetSizeDelta(self.view_port_rect, x, y)
end


--data:第一层菜单数据,数组[[id,name], ... ]
--sub_data:子菜单数据, [[父菜单id]=[[id,name], ...],...]
function BaseTreeMenu:SetData(data, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    self.data = data
    self.sub_data = sub_data
    self.select_sub_id = select_sub_id
    self.oneLvMenuSpan = oneLvMenuSpan
    self.twoLvMenuSpan = twoLvMenuSpan

    if self.is_loaded then
        self:UpdateView()
    end
end

function BaseTreeMenu:UpdateView()
    if not self.data then
        return
    end
    for _, menuitem in pairs(self.leftmenu_list) do
        menuitem:destroy()
    end
    self.leftmenu_list = {}
    self.leftHeight = 0
    local count = #self.data
    for i = 1, count do
        local item = self.data[i]
        local menuItem = self.oneLvMenuCls(self.LeftContent, nil, self.parent_cls_name, self.twoLvMenuCls)
        if self.sub_data[item[1]] ~= nil then
            menuItem:SetData(item, i, self.sub_data[item[1]], self.select_sub_id, self.oneLvMenuSpan, self.twoLvMenuSpan)
            if i == 1 then
                SetLocalPosition(menuItem.transform, 0, 0)
            else
                local p_item = self.leftmenu_list[i - 1]
                SetLocalPosition(menuItem.transform, 0, p_item.transform.localPosition.y - p_item:GetHeight())
            end
            self.leftHeight = self.leftHeight + menuItem:GetHeight()
            table.insert(self.leftmenu_list, menuItem)
        end
    end
    self:RelayoutLeftMenu()
end

function BaseTreeMenu:RelayoutLeftMenu()
    self.LeftContent.sizeDelta = Vector2(self.LeftContent.sizeDelta.x, self.leftHeight)
end

function BaseTreeMenu:SetDefaultSelected(first, second)
    self.defultFirst = first;
    self.defaultSecone = second;

    if self.is_loaded then
        if self.leftmenu_list[first] then
            --self.leftmenu_list[first].index = 1;
            self.leftmenu_list[first]:SelectedItem(second);
            self.defultFirst = nil;
            self.defaultSecone = nil;
        end
        --self.leftmenu_list[1]:Set
    end
end