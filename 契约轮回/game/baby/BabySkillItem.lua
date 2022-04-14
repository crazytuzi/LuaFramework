---
--- Created by  Administrator
--- DateTime: 2019/9/2 17:02
---
BabySkillItem = BabySkillItem or class("BabySkillItem", BaseItem)
local this = BabySkillItem

function BabySkillItem:ctor(parent_node, parent_panel)
    self.abName = "baby"
    self.assetName = "BabySkillItem"
    self.layer = layer
    self.events = {}
    self.model = BabyModel:GetInstance()
    BabySkillItem.super.Load(self)
end

function BabySkillItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function BabySkillItem:LoadCallBack()
    self.nodes = {
        "skill"
    }
    self:GetChildren(self.nodes)
    self.skill = GetImage(self.skill)
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.data,self.curCfg)
    end
end

function BabySkillItem:InitUI()

end

function BabySkillItem:AddEvent()
    local function call_back()
        local tipsPanel = lua_panelMgr:GetPanelOrCreate(BabyTipsSkillPanel)
        tipsPanel:Open()
        tipsPanel:SetId(self.skillID, self.skill.transform)
        tipsPanel:SetOrder(self.curCfg.order,self.data.order)
    end
    AddButtonEvent(self.skill.gameObject,call_back)
end

function BabySkillItem:SetData(data,curCfg)
    self.data = data
    self.curCfg = curCfg
    if not self.data then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    local skillTab = String2Table(self.data.skill)
    self.skillID = skillTab[1]

    local skillCfg = Config.db_skill[self.skillID]
    if not skillCfg then
        logError("缺少技能配置"..self.skillID)
        return
    end
    if self.curCfg.order >= self.data.order then
        ShaderManager:GetInstance():SetImageNormal(self.skill)
    else
        ShaderManager:GetInstance():SetImageGray(self.skill)
    end

    if self.skillName ~= skillCfg.icon then
        self.skillName = skillCfg.icon
        lua_resMgr:SetImageTexture(self, self.skill, "iconasset/icon_skill",skillCfg.icon,true)
    end

end

