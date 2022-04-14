--
-- @Author: lwj
-- @Date:  2018-10-15 20:12:46
--
SkillUIPanel = SkillUIPanel or class("SkillUIPanel", WindowPanel)
local SkillUIPanel = SkillUIPanel

function SkillUIPanel:ctor()
    self.abName = "skill"
    self.assetName = "SkillUIPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.model = SkillUIModel.GetInstance()
    self.show_sidebar = true        --是否显示侧边栏
    if self.show_sidebar then
        -- 侧边栏配置
        self.sidebar_data = {
            { text = ConfigLanguage.Skill.ActiveSkill, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", },
            { text = ConfigLanguage.Skill.PassiveSkill, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
        }
        if RoleInfoModel:GetInstance():GetRoleValue("wake") >= 4 then
            self.sidebar_data[#self.sidebar_data+1] = { text = ConfigLanguage.Skill.TalentSkill, id = 3, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n"}
        end
    end
    self.events = {}
end

function SkillUIPanel:dctor()
end

function SkillUIPanel:Open(index)
    self.default_table_index = index
    WindowPanel.Open(self)
end

function SkillUIPanel:LoadCallBack()
    self.nodes = {
        "ActiveContainer",
        "PassiveContainer",
        "talentContainer",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    --self:LoadActivePanel()  --加载主动技能界面
    --self:SwitchCallBack(self.index)
    self:SetTileTextImage("skill_image", "Skill_Title")
    self:ShowTalentReddot()
end

function SkillUIPanel:AddEvent()

    local function call_back()
        self:ShowTalentReddot()
    end
    self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentUpdateSkill, call_back)
    self.model:AddListener(SkillUIEvent.TalentUpdateInfo, call_back)
end

function SkillUIPanel:OpenCallBack()
end

function SkillUIPanel:LoadActivePanel()
    --self.activePanel = SkillActivePanel(self.ActiveContainer, self.layer)
end

function SkillUIPanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    if index == 1 then
        if not self.activePanel then
            self.activePanel = SkillActivePanel(self.ActiveContainer, self.layer)
        end
        self:PopUpChild(self.activePanel)
        self.model.isOpenPassive = false
    elseif index == 2 then

        if not self.passivePanel then
            self.passivePanel = SkillPassivePanel(self.PassiveContainer, self.layer)
        end
        self:PopUpChild(self.passivePanel)
        self.model.isOpenPassive = true
    elseif index == 3 then
        if not self.talentView then
            self.talentView = SkillTalentView(self.talentContainer)
        end
        self:PopUpChild(self.talentView)
        self.model.isOpenPassive = false
    end
end

function SkillUIPanel:CloseCallBack()
    self.model.is_need_set_default = true
    self.model.curShowDesId = nil
    if self.activePanel then
        self.activePanel:destroy()
        self.activePanel = nil
    end

    if self.passivePanel ~= nil then
        self.passivePanel:destroy()
        self.passivePanel = nil
    end

    if self.talentView then
        self.talentView:destroy()
        self.talentView = nil
    end
    self.model:RemoveTabListener(self.events)
end

function SkillUIPanel:ShowTalentReddot()
    self:SetIndexRedDotParam(3, self.model.point>0)
end
