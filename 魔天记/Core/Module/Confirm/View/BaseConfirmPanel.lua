require "Core.Module.Common.Panel"

BaseConfirmPanel = class("BaseConfirmPanel", Panel);
 
function BaseConfirmPanel:SetPanelId(id)
    self._id = id
end

function BaseConfirmPanel:ClosePanel(notificationName)
    ModuleManager.SendNotification(notificationName, self._id)
end

--function BaseConfirmPanel:IsFixDepth()
--    return true
--end