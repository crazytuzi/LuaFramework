require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Skill.SkillNotes"
require "Core.Module.Skill.View.SkillPanel";
require "Core.Module.Skill.View.SkillTipsPanel";

SkillMediator = Mediator:New();
function SkillMediator:OnRegister()

end

function SkillMediator:_ListNotificationInterests()
    return {
        [1] = SkillNotes.OPEN_SKILLPANEL,
        [2] = SkillNotes.CLOSE_SKILLPANEL,
        [3] = SkillNotes.OPEN_SKILL_TIPS_PANEL,
        [4] = SkillNotes.CLOSE_SKILL_TIPS_PANEL,
    };
end

function SkillMediator:_HandleNotification(notification)
    if notification:GetName() == SkillNotes.OPEN_SKILLPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_SkillPanel, SkillPanel, true);            
        end
        self._panel:SetData(notification:GetBody());
    elseif notification:GetName() == SkillNotes.CLOSE_SKILLPANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil
        end
    elseif notification:GetName() == SkillNotes.OPEN_SKILL_TIPS_PANEL then
        if (self._tipsPanel == nil) then
            self._tipsPanel = PanelManager.BuildPanel(ResID.UI_SkillTipsPanel, SkillTipsPanel);            
        end
        self._tipsPanel:SetData(notification:GetBody());
    elseif notification:GetName() == SkillNotes.CLOSE_SKILL_TIPS_PANEL then
        if (self._tipsPanel ~= nil) then
            PanelManager.RecyclePanel(self._tipsPanel, ResID.UI_SkillTipsPanel)
            self._tipsPanel = nil
        end
    end
end

function SkillMediator:OnRemove()

end

