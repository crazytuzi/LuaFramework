-- 
-- @Author: LaoY
-- @Date:   2018-08-21 17:34:09
-- 
MainBottomRightItem = MainBottomRightItem or class("MainBottomRightItem", BaseItem)

MainBottomRightItem.list_count = 3        --一列多少个
MainBottomRightItem.line_count = 6        --一行多少个
function MainBottomRightItem:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainBottomRightItem"
    self.layer = layer
    self.start_pos = { x = 0, y = 0 }
    self.hide_pos = { x = 0, y = 0 }
    -- self.model = 2222222222222end:GetInstance()
    self.res_name = ""

    self.model = MainModel:GetInstance()
    self.model_event_list = {}

    MainBottomRightItem.super.Load(self)
end

function MainBottomRightItem:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

    self:StopAction()
    if self.showself_event_id then
        GlobalEvent:RemoveListener(self.showself_event_id)
    end
    self.showself_event_id = nil

    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end
end

function MainBottomRightItem:LoadCallBack()
    self.nodes = {
        "icon",
    }
    self:GetChildren(self.nodes)

    self.icon_component = self.icon:GetComponent('Image')
    if self.is_need_loadimagetexture then
        self:LoadImageTexture()
    end

    self.red_dot = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.red_dot:SetPosition(25, 27)

    self:AddEvent()

    if self.is_need_setdata then
        self:SetData(self.config)
    end
    if lua_panelMgr:GetPanelOrCreate(MainUIView).main_bottom_right.switch_state then
        local isHaveToSetFalse = OpenTipModel.GetInstance():IsNeedMove(self.config.id, self.config.sub_id)
        if not isHaveToSetFalse then
            self:SetVisible(true)
        end
    else
        self:SetVisible(false)
    end
end

function MainBottomRightItem:AddEvent()
    local function call_back(target, x, y)
        -- self.config
        if not self.config then
            return
        end
        MainIconOpenLink(self.config.id, self.config.sub_id)
    end
    AddButtonEvent(self.icon.gameObject, call_back)

    self.showself_event_id = GlobalEvent:AddListener(EventName.ShowSpecifiedMainRightIcon, handler(self, self.ShowIcon))

    local function call_back(key_str, param, sign)
        if self.config.key_str == key_str then
            self:UpdateRedDot()
        end
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.UpdateRedDot, call_back)
end

function MainBottomRightItem:StartAction(delay_time, time, pos, visible)
    if not self.is_loaded then
        return
    end
    local isHaveToSetFalse = OpenTipModel.GetInstance():IsNeedMove(self.config.id, self.config.sub_id)
    if visible and not isHaveToSetFalse then
        self:SetVisible(visible)
        -- else
        --     self:SetVisible(false)
    end
    self:StopAction()
    local delay_action = cc.DelayTime(delay_time)
    local moveAction = cc.MoveTo(time, pos.x, pos.y, 0)
    local function end_call_back()
        if not isHaveToSetFalse then
            self:SetVisible(visible)
        else
            self:SetVisible(false)
        end
    end
    local call_action = cc.CallFunc(end_call_back)
    local action = cc.Sequence(delay_action, moveAction, call_action)
    self.action = action
    cc.ActionManager:GetInstance():addAction(action, self.transform)
end

function MainBottomRightItem:StopAction()
    self.action = nil
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

function MainBottomRightItem:IsActionDone()
    if not self.action then
        return true
    end
    return self.action:isDone()
end

function MainBottomRightItem:SetData(config)
    self.config = config
    if not self.is_loaded then
        self.is_need_setdata = true
        return
    end

    self.transform.name = self.config.key_str
    self.is_need_setdata = false
    self:LoadImageTexture()
    self:UpdateRedDot()
end

function MainBottomRightItem:UpdateRedDot()
    local param = self.model:GetRedDotParam(self.config.key_str)
    self.red_dot:SetRedDotParam(param)
end

function MainBottomRightItem:LoadImageTexture()
    if not self.is_loaded then
        self.is_need_loadimagetexture = true
        return
    end
    self.is_need_loadimagetexture = false
    local icon = self.config.icon
    if not self.config or not self.config.icon then
        return
    end
    local res_tab = string.split(self.config.icon, ":")
    local abName = res_tab[1]
    local assetName = res_tab[2]
    if self.res_name == assetName then
        return
    end
    self.res_name = assetName
    local function callBack(sprite)
        self.icon_component.sprite = sprite
    end
    lua_resMgr:SetImageTexture(self, self.icon_component, abName, assetName, true, callBack)
end

function MainBottomRightItem:SetStartPos(x, y)
    self.start_pos.x = x
    self.start_pos.y = y
end

function MainBottomRightItem:SetHidePos(x, y)
    self.hide_pos.x = x
    self.hide_pos.y = y
end

function MainBottomRightItem:SetLineIndex(line, line_index)
    self.line = line
    self.line_index = line_index
end

function MainBottomRightItem:ShowIcon(id, sub_id)
    if self.config.id == id and self.config.sub_id == sub_id then
        self:SetVisible(true)
    end
end

function MainBottomRightItem:GetCurPosition()
    local x, y, z = GetLocalPosition(self.icon.transform)
    local v3 = Vector3(x, y, z)
    local result = self.icon.transform:TransformPoint(v3)
    return result.x, result.y, result.z
end