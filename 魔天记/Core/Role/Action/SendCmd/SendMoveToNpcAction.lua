require "Core.Role.Action.SendCmd.SendMoveToAction";
require "Core.Module.Dialog.DialogNotes";

SendMoveToNpcAction = class("SendMoveToNpcAction", SendMoveToAction)

function SendMoveToNpcAction:New(id, map, pos)
    self = { };
    setmetatable(self, { __index = SendMoveToNpcAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self.npcInfo = self:_GetNpcInfo(id);
    self._stopDistance = 1.5;
    self._toPosition = pos or Vector3(self.npcInfo.x / 100, self.npcInfo.y / 100, self.npcInfo.z / 100);

    self._toMap = map or self.npcInfo.map;
    self._disRoleEvent = true;
    if (GameSceneManager.map) then
        self.isAcrossMap =(self._toMap ~= GameSceneManager.map.info.id);
    end
    return self;
end

function SendMoveToNpcAction:_GetNpcInfo(id)
    local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC);
    if (npcCfg) then
        return npcCfg[id];
    end
    return nil;
end

function SendMoveToNpcAction:_OnCompleteHandler()
    if (self._toMap == GameSceneManager.map.info.id) then
        self:Finish();
        -- ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, self.npcInfo.id);
        SequenceManager.TriggerEvent(SequenceEventType.Base.MOVE_TO_NPC_END, self.npcInfo.id);
    else
        self._controller:Play(RoleActionName.stand);
        self:Pause();
    end
end

-- 直接刷到目标地图
function SendMoveToNpcAction:_DirectToMap(tmap)
    local mapInfo = GameSceneManager.GetMapInfo(tmap);
    if (mapInfo) then
        if (mapInfo.type ~= 2) then
            -- 副本不能跳
            self._controller:Play(self:_GetStandActionName(self._controller));
            GameSceneManager.GotoSceneByLoading(tmap)
        else
            self:Finish()
        end
    end
end