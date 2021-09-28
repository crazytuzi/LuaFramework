require "Core.Module.Common.Panel"
require "Core.Module.Common.Phalanx"
require "Core.Module.Login.View.ZoneItem";
require "Core.Module.Login.View.ServerItem";

SelectServerPanel = Panel:New();

function SelectServerPanel:_Init()
    self:_InitReference();
    self:_InitListener();

    local serverConfig = LoginManager.GetServerListConfig()
    local zoneCount = table.getCount(serverConfig)
    self.zonePhalanx = Phalanx:New();
    self.zonePhalanx:Init(self._zonePhalanx, ZoneItem)
    self.zonePhalanx:Build(zoneCount, 1, serverConfig)

    self.serverPhalanx = Phalanx:New();
    self.serverPhalanx:Init(self._serverPhalanx, ServerItem);

    self:UpdateSelectserverPanel();
    --    self.timeHandle = VpHandle.New()
    --    local callBack = DelegateFactory.VPTimer_ArgCallback(function(x) print(x[2]) end);
    --    local data =  {1,2}
    --    VpTimer.In(0.0,callBack,{1,2},100,1,self.timeHandle)
end

function SelectServerPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._zonePhalanx = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "zonePhalanx");
    self._serverPhalanx = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "serverphalanx");

    self._trsMyZone = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMyZone");
    self._trsMyZoneLogic = ZoneItem:New();
    self._trsMyZoneLogic:Init(self._trsMyZone.gameObject, {id = "0"});
end

function SelectServerPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    MessageManager.AddListener(LoginNotes, LoginNotes.UPDATE_SELECTSERVER_PANEL, SelectServerPanel.UpdateSelectserverPanel, self);
end

function SelectServerPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(LoginNotes.CLOSE_SELECTSERVER_PANEL)
end

function SelectServerPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    --    self.timeHandle:Cancel()
    self._trsMyZoneLogic:Dispose()
    self.zonePhalanx:Dispose()
    self.serverPhalanx:Dispose()
end

function SelectServerPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    MessageManager.RemoveListener(LoginNotes, LoginNotes.UPDATE_SELECTSERVER_PANEL, SelectServerPanel.UpdateSelectserverPanel);
end

function SelectServerPanel:_DisposeReference()

end

function SelectServerPanel:UpdateSelectserverPanel()
    local serverList = LoginManager.GetServerList(LoginProxy.currentZoneIndex);
    local serverCount = table.getCount(serverList)
    self.serverPhalanx:Build(5, 2, serverList)
    self:UpdateZoneSelect();
end

function SelectServerPanel:UpdateZoneSelect()
    local zoneId = LoginProxy.currentZoneIndex;
    
    local items = self.zonePhalanx:GetItems();
    local count = table.getCount(items);
    for k, v in pairs(items) do
        v.itemLogic:UpdateSelected(zoneId);
    end

    self._trsMyZoneLogic:UpdateSelected(zoneId);
end





