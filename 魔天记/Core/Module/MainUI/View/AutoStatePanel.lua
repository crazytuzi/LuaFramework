require "Core.Module.Common.UIComponent"

AutoStatePanel = class("AutoStatePanel", UIComponent)

local ShowPos = Vector3.New(0, 0, 0);
local HidPos = Vector3.New(0, 1000, 0);
 
function AutoStatePanel:New()
    self = { };
    setmetatable(self, { __index = AutoStatePanel });
    return self;
end

function AutoStatePanel:_Init()
    self._ui_autoRoad = UIUtil.GetChildByName(self._gameObject, "Transform", "ui_autoRoad");
    self._autoRoadAnimation = UIUtil.GetComponent(self._ui_autoRoad,"Animation")
    self._ui_autoFight = UIUtil.GetChildByName(self._gameObject, "Transform", "ui_autoFight");
    self._autoFightAnimation = UIUtil.GetComponent(self._ui_autoFight,"Animation")

    self._blAutoRoad = false;
    self._blAutoFight = false;
    self._blAutoKill = false;

    MessageManager.AddListener(PlayerManager, PlayerManager.StartAutoFight, AutoStatePanel._OnStartAutoFightHandler, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.StopAutoFight, AutoStatePanel._OnStopAutoFightHandler, self);

    MessageManager.AddListener(PlayerManager, PlayerManager.StartAutoKill, AutoStatePanel._OnStartAutoKillHandler, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.StopAutoKill, AutoStatePanel._OnStopAutoKillHandler, self);

    MessageManager.AddListener(PlayerManager, PlayerManager.StartAutoRoad, AutoStatePanel._OnStartAutoRoadHandler, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.StopAutoRoad, AutoStatePanel._OnStopAutoRoadHandler, self);

    self:_Refresh();
end


function AutoStatePanel:_Dispose()
    MessageManager.RemoveListener(PlayerManager, PlayerManager.StartAutoFight, AutoStatePanel._OnStartAutoFightHandler);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.StopAutoFight, AutoStatePanel._OnStopAutoFightHandler);

    MessageManager.RemoveListener(PlayerManager, PlayerManager.StartAutoKill, AutoStatePanel._OnStartAutoKillHandler);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.StopAutoKill, AutoStatePanel._OnStopAutoKillHandler);

    MessageManager.RemoveListener(PlayerManager, PlayerManager.StartAutoRoad, AutoStatePanel._OnStartAutoRoadHandler);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.StopAutoRoad, AutoStatePanel._OnStopAutoRoadHandler);
end

function AutoStatePanel:_Refresh()
    if (self._blAutoRoad) then
        Util.SetLocalPos(self._ui_autoRoad, ShowPos.x, ShowPos.y, ShowPos.z)
        self._autoRoadAnimation:Play()
        Util.SetLocalPos(self._ui_autoFight, HidPos.x, HidPos.y, HidPos.z)
        self._autoFightAnimation:Stop()

        --        self._ui_autoRoad.localPosition = ShowPos;
        --        self._ui_autoFight.localPosition = HidPos;
    else
        self._ui_autoRoad.localPosition = HidPos;
        if (self._blAutoFight or self._blAutoKill) then
            Util.SetLocalPos(self._ui_autoFight, ShowPos.x, ShowPos.y, ShowPos.z)
               self._autoFightAnimation:Play()
            --            self._ui_autoFight.localPosition = ShowPos;
        else
            Util.SetLocalPos(self._ui_autoFight, HidPos.x, HidPos.y, HidPos.z)
             self._autoFightAnimation:Stop()
            --            self._ui_autoFight.localPosition = HidPos;
        end
    end
end

function AutoStatePanel:_OnStartAutoRoadHandler()
    self._blAutoRoad = true;
    self:_Refresh();
end

function AutoStatePanel:_OnStopAutoRoadHandler()
    self._blAutoRoad = false;
    self:_Refresh();
end


function AutoStatePanel:_OnStartAutoFightHandler()
    self._blAutoFight = true
    self:_Refresh();
end

function AutoStatePanel:_OnStopAutoFightHandler()
    self._blAutoFight = false
    self:_Refresh();
end

function AutoStatePanel:_OnStartAutoKillHandler()
    self._blAutoKill = true
    self:_Refresh();
end

function AutoStatePanel:_OnStopAutoKillHandler()
    self._blAutoKill = false
    self:_Refresh();
end