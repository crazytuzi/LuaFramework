require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Equip.EquipNotes"
require "Core.Module.Equip.View.EquipMainPanel"

local EquipNewStrongSuitOnePanel = require "Core.Module.Equip.View.EquipNewStrongSuitOnePanel"
local EquipNewStrongSuitPanel = require "Core.Module.Equip.View.EquipNewStrongSuitPanel"

local EquipSQSuitOnePanel = require "Core.Module.Equip.View.EquipSQSuitOnePanel"
local EquipSQSuitPanel = require "Core.Module.Equip.View.EquipSQSuitPanel"

require "Core.Module.Equip.View.GemCompPanel"

EquipMediator = Mediator:New();
local noticeList =
{
    EquipNotes.OPEN_EQUIPMAINPANEL,
    EquipNotes.CLOSE_EQUIPMAINPANELL,
    EquipNotes.OPEN_GEMCOMPOSEPANEL,
    EquipNotes.CLOSE_GEMCOMPOSEPANEL,


    EquipNotes.OPEN_EQUIPNEWSTRONGSUITONEPANEL,
    EquipNotes.CLOSE_EQUIPNEWSTRONGSUITONEPANEL,
    EquipNotes.OPEN_EQUIPNEWSTRONGSUITPANEL,
    EquipNotes.CLOSE_EQUIPNEWSTRONGSUITPANEL,

    EquipNotes.OPEN_EQUIPSQSUITPANEL,
    EquipNotes.CLOSE_EQUIPSQSUITPANEL,



}
function EquipMediator:OnRegister()

end


function EquipMediator:_ListNotificationInterests()
    return noticeList
end

function EquipMediator:_HandleNotification(notification)
    local notificationName = notification:GetName()
    if notificationName == EquipNotes.OPEN_EQUIPMAINPANEL then
        local tab = notification:GetBody();
        if (self._equipMainPanel == nil) then
            self._equipMainPanel = PanelManager.BuildPanel(ResID.UI_EQUIPMAINPANEL, EquipMainPanel, true);
        end
        self._equipMainPanel:UpData(tab);
        self._equipMainPanel:TrySetDefulSelect();

    elseif notificationName == EquipNotes.CLOSE_EQUIPMAINPANELL then
        if (self._equipMainPanel ~= nil) then
            PanelManager.RecyclePanel(self._equipMainPanel, ResID.UI_EQUIPMAINPANEL)
            self._equipMainPanel = nil
        end
    elseif notificationName == EquipNotes.OPEN_GEMCOMPOSEPANEL then
        if (self._gemCompPanel == nil) then
            self._gemCompPanel = PanelManager.BuildPanel(ResID.UI_GEMCOMPPANEL, GemCompPanel);
        end
        local gemId = notification:GetBody();
        if gemId then
            self._gemCompPanel:SetOpenParam(gemId);
        end
    elseif notificationName == EquipNotes.CLOSE_GEMCOMPOSEPANEL then
        if (self._gemCompPanel ~= nil) then
            PanelManager.RecyclePanel(self._gemCompPanel);
            self._gemCompPanel = nil
        end

   
    elseif notificationName == EquipNotes.OPEN_EQUIPNEWSTRONGSUITONEPANEL then
        if (self._equipNewStrongSuitOnePanel == nil) then
            self._equipNewStrongSuitOnePanel = PanelManager.BuildPanel(ResID.UI_EQUIPNEWSTRONGSUITONEPANEL, EquipNewStrongSuitOnePanel);
            self._equipNewStrongSuitOnePanel:UpdatePanel(notification:GetBody())
        end
    elseif notificationName == EquipNotes.CLOSE_EQUIPNEWSTRONGSUITONEPANEL then
        if (self._equipNewStrongSuitOnePanel ~= nil) then
            PanelManager.RecyclePanel(self._equipNewStrongSuitOnePanel);
            self._equipNewStrongSuitOnePanel = nil
        end
    elseif notificationName == EquipNotes.OPEN_EQUIPNEWSTRONGSUITPANEL then
        if (self._equipNewStrongSuitPanel == nil) then
            self._equipNewStrongSuitPanel = PanelManager.BuildPanel(ResID.UI_EQUIPNEWSTRONGSUITPANEL, EquipNewStrongSuitPanel);
            self._equipNewStrongSuitPanel:UpdatePanel(notification:GetBody())
        end
    elseif notificationName == EquipNotes.CLOSE_EQUIPNEWSTRONGSUITPANEL then
        if (self._equipNewStrongSuitPanel ~= nil) then
            PanelManager.RecyclePanel(self._equipNewStrongSuitPanel);
            self._equipNewStrongSuitPanel = nil
        end

        ---------------------------------------------------------------------------------------------------
    elseif notificationName == EquipNotes.OPEN_EQUIPSQSUITPANEL then
        local plData = notification:GetBody();
        local suit_id = plData.suit_id;
        local my_info = HeroController:GetInstance().info;
        local my_career = my_info:GetCareer();

        if (self._EquipSQSuitPanel == nil) then


            if suit_id == 0 then
                -- ????????
                local suitCf = MouldingDataManager.Get_treasuretype_attribute_byId(suit_id + 1, my_career);
                self._EquipSQSuitPanel = PanelManager.BuildPanel(ResID.UI_EQUIPSQSUITONEPANEL, EquipSQSuitOnePanel);
                self._EquipSQSuitPanel:UpdatePanel(suitCf, false);
            else
                local suitCf1 = MouldingDataManager.Get_treasuretype_attribute_byId(suit_id, my_career);
                if suit_id < 30 then
                   
                    local suitCf2 = MouldingDataManager.Get_treasuretype_attribute_byId(suit_id + 1, my_career);
                    self._EquipSQSuitPanel = PanelManager.BuildPanel(ResID.UI_EQUIPSQSUITPANEL, EquipSQSuitPanel);
                    self._EquipSQSuitPanel:UpdatePanel(suitCf1, suitCf2);
                else
                 -- ????????????????
                    self._EquipSQSuitPanel = PanelManager.BuildPanel(ResID.UI_EQUIPSQSUITONEPANEL, EquipSQSuitOnePanel);
                    self._EquipSQSuitPanel:UpdatePanel(suitCf1, true);
                end
            end

        end

    elseif notificationName == EquipNotes.CLOSE_EQUIPSQSUITPANEL then
        if (self._EquipSQSuitPanel ~= nil) then
            PanelManager.RecyclePanel(self._EquipSQSuitPanel);
            self._EquipSQSuitPanel = nil
        end



    end
end

function EquipMediator:OnRemove()

end

