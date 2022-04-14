--
-- @Author: LaoY
-- @Date:   2018-12-08 11:10:22
--
TurnTable = TurnTable or class("TurnTable", BaseWidget)
local TurnTable = TurnTable

function TurnTable:ctor(parent_node, builtin_layer, child_class, turn_time, is_hide_light, extra_rotate)
    self.abName = "system"
    self.assetName = "TurnTable"
    -- 场景对象才需要修改
    -- self.builtin_layer = builtin_layer
    self.child_class = child_class
    self.turn_time = turn_time
    self.is_hide_light = is_hide_light
    self.extra_rotate = extra_rotate
    TurnTable.super.Load(self)
end

function TurnTable:dctor()
    self:StopAction()

    for k, item in pairs(self.item_list) do
        item:destroy()
    end
    self.item_list = {}
end

function TurnTable:LoadCallBack()
    self.nodes = {
        "img_pointer", "award_con", "TurnTableItem",
    }
    self:GetChildren(self.nodes)

    SetVisible(self.TurnTableItem, false)

    self.img_pointer_component = self.img_pointer:GetComponent('Image')
    if not self.child_class then
        self.TurnTableItem_gameobject = self.TurnTableItem.gameObject
    end
    self:AddEvent()
end

function TurnTable:AddEvent()
end

function TurnTable:SetPointer(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_pointer_component, abName, assetName, false)
end

function TurnTable:GetItemList()
    return self.item_list
end

function TurnTable:SetData(data, radius, light_radius)
    radius = radius or 200
    local list = data
    local len = #list
    self.item_list = self.item_list or {}
    self.len = len
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            if self.child_class then
                item = self.child_class(self.award_con)
            else
                item = TurnTableItem(self.TurnTableItem_gameobject, self.award_con, nil, self.is_hide_light)
                item:SetRadius(len, radius, light_radius)
                item:SetRes("dungeon_image", "img_select")
            end
            self.item_list[i] = item
            local x, y = GetTurnTablePos(i, len, radius)
            item:SetPosition(x, y)
        end
        item:SetData(i, list[i])
    end
end

function TurnTable:SetLightVisible(index)
    for k, item in pairs(self.item_list) do
        item:SetLightVisible(k == index)
    end
end

function TurnTable:SetTurnToIndex(index, call_back, is_ingore_action)
    local rotate = GetTurnTableAngle(index, self.len)
    self:SetLightVisible()
    local function end_call_back()
        self:SetLightVisible(index)
        if call_back then
            call_back(index)
        end
    end
    if is_ingore_action then
        SetLocalRotation(self.img_pointer, 0, 0, rotate)
        end_call_back()
    else
        self:StartAction(rotate, end_call_back)
    end
end

function TurnTable:IsAction()
    return self.is_action
end

function TurnTable:StartAction(rotate, call_back)
    local time = self.turn_time or 2.0
    self:StopAction()
    self.is_action = true
    local extra = self.extra_rotate or -1080
    local action = cc.RotateTo(time, extra + rotate)
    action = cc.EaseInOut(action, 4)
    local function end_call_back()
        self:StopAction()
        if call_back then
            call_back()
        end
    end
    local call_action = cc.CallFunc(end_call_back)
    action = cc.Sequence(action, call_action)
    cc.ActionManager:GetInstance():addAction(action, self.img_pointer)
end

function TurnTable:StopAction()
    self.is_action = false
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.img_pointer)
end