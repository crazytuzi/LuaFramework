---
--- Created by  Administrator
--- DateTime: 2019/9/26 15:02
---
StigmasDropItem = StigmasDropItem or class("StigmasDropItem", BaseCloneItem)
local this = StigmasDropItem

function StigmasDropItem:ctor(obj, parent_node, parent_panel)
    StigmasDropItem.super.Load(self)
    self.events = {}
end

function StigmasDropItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function StigmasDropItem:LoadCallBack()
    self.nodes = {
        "des"
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function StigmasDropItem:InitUI()

end

function StigmasDropItem:AddEvent()

end

function StigmasDropItem:SetData(cfg,number)
    self.cfg = cfg

   -- self.des.text =
   -- local colorNum = cfg.color
   -- local str = string.format("<color=#%s>%s：%s</color>", ColorUtil.GetColor(colorNum), cfg.name,number)
    local str = cfg.name.."："..number
    self.des.text = str
    SetVisible(self,number ~= 0)
end
