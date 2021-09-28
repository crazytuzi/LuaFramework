require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.FightSkillName.FightSkillNameNotes"
require "Core.Module.FightSkillName.View.FightSkillNamePanel"

FightSkillNameMediator = Mediator:New();
function FightSkillNameMediator:OnRegister()

end

function FightSkillNameMediator:_ListNotificationInterests()
    return {
        [1] = FightSkillNameNotes.OPEN_FIGHTSKILLNAME,
        [2] = FightSkillNameNotes.CLOSE_FIGHTSKILLNAME,
    };
end

function FightSkillNameMediator:_HandleNotification(notification)
    if notification:GetName() == FightSkillNameNotes.OPEN_FIGHTSKILLNAME then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_FIGHTSKILLNAME, FightSkillNamePanel);            
        end  
        self._panel:SetSkillName(notification:GetBody())
    elseif notification:GetName() == FightSkillNameNotes.CLOSE_FIGHTSKILLNAME then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel,true)
            self._panel = nil
        end
    end
end

function FightSkillNameMediator:OnRemove()

end

