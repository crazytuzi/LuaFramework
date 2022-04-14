AchieveFoldMenu = AchieveFoldMenu or class("AchieveFoldMenu", BaseTreeMenu)
local this = AchieveFoldMenu

function AchieveFoldMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCl, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "AchieveFoldMenu"
    --self.layer = layer
    --self.parent_cls_name = parent_cls and parent_cls.__cname or ""
    self.oneLvMenuCls = AchieveOneMenu
    self.isStickItemWhenClick = isStickItemWhenClick or true
    --self.globalEvents = {}
    --self.leftmenu_list = {}
    --self.leftHeight = 0
    --self.select_sub_id = -1
    --self.model = 2222222222222end:GetInstance()
    AchieveFoldMenu.super.Load(self)
end

function AchieveFoldMenu:dctor()
end



function AchieveFoldMenu:CheckAchieveRedPoint()

    for i = 1, #self.sub_data do
        --if i == 1 then
        --    local isRed = AchieveModel:GetInstance():CheckRedPoint(1,i)
        --    self.leftmenu_list[i]:SetRedDot(isRed)
        --end
        for j = 1, #self.sub_data[i] do
            local isRed = AchieveModel:GetInstance():CheckRedPoint(i,j)
            --self.leftmenu_list[i]:SetRedDot(isRed)
            self.leftmenu_list[i].sub_data[j].isRed = isRed
        end
        local isRed = AchieveModel:GetInstance():CheckRedPointByGroup(i)
        self.leftmenu_list[i]:SetRedDot(isRed)
    end

end

function AchieveFoldMenu:AddEvent()
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
            self.LeftContent.sizeDelta = Vector2(self.LeftContent.sizeDelta.x, 0)
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
