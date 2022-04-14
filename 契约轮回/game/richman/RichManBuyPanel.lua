---
--- Created by  Administrator
--- DateTime: 2020/4/16 19:00
---
RichManBuyPanel = RichManBuyPanel or class("RichManBuyPanel", BasePanel)
local this = RichManBuyPanel

function RichManBuyPanel:ctor(parent_node, parent_panel)
    self.abName = "richman"
    self.assetName = "RichManBuyPanel"
    self.image_ab = "richman_image";
    self.layer = "UI"
    self.use_background = true
    self.show_sidebar = false
    self.events = {}
    self.model = RichManModel:GetInstance()
end

function RichManBuyPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function RichManBuyPanel:LoadCallBack()
    self.nodes = {
        "Count_Group/plus_btn","Count_Group/num","Count_Group/keypad",
        "closeBtn","diamond","Count_Group/max_btn","dimImg","Count_Group/reduce_btn",
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self.diamond = GetText(self.diamond)
    self:InitUI()
    self:AddEvent()
end

function RichManBuyPanel:InitUI()

end

function RichManBuyPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)
end