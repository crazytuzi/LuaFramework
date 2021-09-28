require "Core.Role.Action.AbsAction";

ArathiPointStandAction = class("ArathiPointStandAction", AbsAction)

function ArathiPointStandAction:New()
    self = { };
    setmetatable(self, { __index = ArathiPointStandAction });
    self:Init();
    self.actionType = ActionType.BLOCK;
    self._isInArea = false;
    return self;
end

function ArathiPointStandAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        MapTerrain.SampleTerrainPositionAndSetPos(controller.transform, controller.info.position)
        --        controller.transform.position = MapTerrain.SampleTerrainPosition(controller.info.position);
        self._target = HeroController.GetInstance();
        self._camp = controller.info.camp;
        self:_InitTimer(0.2, -1);
    end
end

function ArathiPointStandAction:_OnStopHandler()
    MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_HEROOUTPOINTAREA, self._controller.info);
end

function ArathiPointStandAction:_OnTimerHandler()
    local controller = self._controller;
    if (controller) then
        local target = controller.target;
        if (target) then
            -- local act = target:GetAction();
            -- if (act ~= nil and (act.__cname == "SendMoveToAngleAction" or act.__cname == "SendMoveToAction" or act.__cname == "SendMoveToNpcAction")) then
            if (Vector3.Distance2(controller.transform.position, target.transform.position) < controller.info.radius) then
                if (self._camp ~= self._controller.info.camp) then
                    self._camp = self._controller.info.camp
                    self._isInArea = false;
                end
                if (not self._isInArea) then
                    MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_HEROINPOINTAREA, controller.info);
                    self._isInArea = true;
                end
            else
                if (self._isInArea) then
                    MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_HEROOUTPOINTAREA, controller.info);
                    self._isInArea = false;
                end
            end
            -- end
        end
    end
end