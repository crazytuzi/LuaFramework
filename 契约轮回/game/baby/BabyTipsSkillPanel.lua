---
--- Created by  Administrator
--- DateTime: 2019/9/3 17:23
---
BabyTipsSkillPanel = BabyTipsSkillPanel or class("TipsSkillPanel", TipsSkillPanel)
local this = BabyTipsSkillPanel

function BabyTipsSkillPanel:ctor(parent_node, parent_panel)
    self.abName = "baby"
    self.assetName = "BabyTipsSkillPanel"
    self.layer = "UI"
   -- self.events = {}
   -- BabyTipsSkillPanel.super.Load(self)
end

function BabyTipsSkillPanel:dctor()
   -- GlobalEvent:RemoveTabListener(self.events)
end

function BabyTipsSkillPanel:LoadCallBack()
    self.nodes = {
        "activeText",
    }
    self:GetChildren(self.nodes)
    self.activeText = GetText(self.activeText)
    BabyTipsSkillPanel.super.LoadCallBack(self)

    if self.is_need_setData then
        self:SetOrder(self.curOrder,self.dataOrder)
    end

end

function BabyTipsSkillPanel:SetId(id, parentNode, pos, layer, setmaxlayer)
    BabyTipsSkillPanel.super.SetId(self,id, parentNode, pos, layer, setmaxlayer)
end

function BabyTipsSkillPanel:SetOrder(curOrder,dataOrder)
    local str = "<color=#40AD30>(Activated)</color>"
    self.curOrder = curOrder
    self.dataOrder = dataOrder
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    if  self.curOrder < self.dataOrder then
        str = string.format("<color=#F30F0F>(Auto Activate: T%s)</color>",dataOrder)
    end
    self.activeText.text = str
end



