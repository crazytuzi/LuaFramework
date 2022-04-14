---
--- Created by R2D2.
--- DateTime: 2019/4/10 10:57
---
PanelTabButtonThree = PanelTabButtonThree or class("PanelTabButtonThree", BaseWidget)
local PanelTabButtonThree = PanelTabButtonThree

function PanelTabButtonThree:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "PanelTabButtonThree"

    PanelTabButtonThree.super.Load(self)
end

function PanelTabButtonThree:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function PanelTabButtonThree:LoadCallBack()
    self.nodes = {
        "OffImage", "OnImage", "Click", "Text",
    }
    self:GetChildren(self.nodes)

    self.text_component = GetText(self.Text)
    self.image_off = GetImage(self.OffImage)
    self.image_on = GetImage(self.OnImage)

    self:SetSelectState(false)

    self.red_dot = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.red_dot:SetPosition(22, 46)
    if self.red_dot_param ~= nil then
        self:SetRedDotParam(self.red_dot_param)
    end
    if self.red_dot_type ~= nil then
        self:SetRedDotType(self.red_dot_type)
    end

    self:AddEvent()
end

function PanelTabButtonThree:AddEvent()
    local function call_back(target, x, y)
        PanelTabButton.OnClick(self)
    end

    AddClickEvent(self.Click.gameObject, call_back)
end

function PanelTabButtonThree:SetAnchoredPosition(x, y)
    SetAnchoredPosition(self.transform, x, y)
end

function PanelTabButtonThree:SetCallBack(callback)
    self.callback = callback
end

function PanelTabButtonThree:SetData(data)
    data = data or {}
    self.data = data

    self.id = data.id or 1
    self.text_component.text = data.text or ""
end

function PanelTabButtonThree:SetSelectState(flag)
    if self.select_state == flag then
        return
    end

    self.select_state = flag

    if flag then
        self.image_on.enabled = true
        self.image_off.enabled = false
        SetColor(self.text_component, HtmlColorStringToColor("#8d8cbf"))
    else
        self.image_on.enabled = false
        self.image_off.enabled = true
        SetColor(self.text_component, HtmlColorStringToColor("#ffffff"))
    end
end

function PanelTabButtonThree:SetRedDotType(red_dot_type)
    if not self.red_dot then
        self.red_dot_type = red_dot_type
    else
        self.red_dot:SetRedDotType(red_dot_type)
    end
end

function PanelTabButtonThree:SetRedDotParam(param)
    if not self.red_dot then
        self.red_dot_param = param
    else
        self.red_dot:SetRedDotParam(param)
    end
end