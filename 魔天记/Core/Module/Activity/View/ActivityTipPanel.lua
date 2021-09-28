require "Core.Module.Common.Panel"

local ActivityTipPanel = class("ActivityTipPanel", Panel);
function ActivityTipPanel:New()
    self = { };
    setmetatable(self, { __index = ActivityTipPanel });
    return self
end


function ActivityTipPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ActivityTipPanel:_InitReference()

    self.tipPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "tipPanel");

    self.infosPanelCtr = InfosPanelCtr:New();
    self.infosPanelCtr:Init(self.tipPanel)

end

function ActivityTipPanel:_InitListener()
end

function ActivityTipPanel:_OnBtnsClick(go)
end

--  ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY_TIP,active_id);
function ActivityTipPanel:Show(active_id)
	 
     
    self.data = ActivityDataManager.GetCfBy_id(active_id);
	self.infosPanelCtr:Show(self.data);
	
end

function ActivityTipPanel:_Dispose()
    self:_DisposeReference();
end

function ActivityTipPanel:_DisposeReference()

    self.infosPanelCtr:Dispose();
    self.infosPanelCtr = nil;

end
return ActivityTipPanel