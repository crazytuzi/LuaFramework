---
--- Created by R2D2.
--- DateTime: 2019/1/9 16:38
---

WelfareToggleItemView = WelfareToggleItemView or class("WelfareToggleItemView", Node)
local this = WelfareToggleItemView

function WelfareToggleItemView:ctor(obj, tab)

    self.transform = obj.transform
    self.data = tab

    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find;

    self:InitUI()
    self:AddEvent()
end

function WelfareToggleItemView:dctor()
    if (self.redPoint) then
        self.redPoint:destroy()
        self.redPoint = nil
    end
end

function WelfareToggleItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "CaptionLabel","Recommend" }
    self:GetChildren(self.nodes)

    self.recommendImage = GetImage(self.Recommend)
    self.captionText = GetText(self.CaptionLabel)
    self.toggle = GetToggle(self.gameObject)

    self.recommendImage.enabled = self.data.isRecommend == 1
    self.captionText.text = self.data.name
    self:RefreshRedPoint();

end

function WelfareToggleItemView:AddEvent()
    local function toggle_callback()
        if not self.data then return end

        if self.toggle.isOn then
            SetColor(self.captionText, 214, 121, 29, 255)
            GlobalEvent:Brocast(WelfareEvent.Welfare_ChangePageEvent, self.data.id)
        else
            SetColor(self.captionText, 205, 192, 202, 255)
        end

    end
    AddValueChange(self.toggle.gameObject, toggle_callback)
end

function WelfareToggleItemView:RefreshRedPoint()
    local value =WelfareModel:GetInstance():GetRedPointByType(self.data.id)
    self:SetRedPoint(value)
end

function WelfareToggleItemView:SetRedPoint(isShow)
    if self.redPoint == nil then
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(-76, 20)
    end

    self.redPoint:SetRedDotParam(isShow)
end

function WelfareToggleItemView:SetItOn(bool)
    self.toggle.isOn = bool
end

function WelfareToggleItemView:SetTogGroup(group)
    self.toggle.group = group
end