---
--- Created by R2D2.
--- DateTime: 2019/1/19 17:14
---
NoticeToggleItemView = NoticeToggleItemView or class("NoticeToggleItemView", Node)
local this = NoticeToggleItemView

function NoticeToggleItemView:ctor(obj, tab)

    self.transform = obj.transform
    self.data = tab
    self.id =  0

    if (tab and  type(tab.id) == "number") then
        self.id = tab.id
    end

    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find;

    self:InitUI()
    self:AddEvent()
end

function NoticeToggleItemView:dctor()

end

function NoticeToggleItemView:SetId(id)
    self.id = id
end

function NoticeToggleItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "CaptionLabel", "New" }
    self:GetChildren(self.nodes)

    self.captionText = GetText(self.CaptionLabel)
    self.toggle = GetToggle(self.gameObject)
    self.newImage = GetImage(self.New)

    self.newImage.enabled = false
    self.captionText.text = self.data.title
end

function NoticeToggleItemView:AddEvent()
    local function toggle_callback()
        if not self.data then return end

        if self.toggle.isOn then
            SetColor(self.captionText, 234, 79, 17, 255)
            GlobalEvent:Brocast(NoticeEvent.Notice_ToggleEvent, self.id)
        else
            SetColor(self.captionText, 122, 97, 84, 255)
        end

    end
    AddValueChange(self.toggle.gameObject, toggle_callback)
end

function NoticeToggleItemView:SetItOn(bool)
    self.toggle.isOn = bool
end

function NoticeToggleItemView:SetTogGroup(group)
    self.toggle.group = group
end