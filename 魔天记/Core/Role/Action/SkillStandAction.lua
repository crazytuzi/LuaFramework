require "Core.Role.Action.RoleAction";

SkillStandAction = class("SkillStandAction", RoleAction)

SkillStandAction.WAITTIME = 5;
SkillStandAction.WAITRATE = 0.99;

function SkillStandAction:New(position, angle)
    self = { };
    setmetatable(self, { __index = SkillStandAction });
    self:Init();
    self.actionType = ActionType.COOPERATION
    self._position = position;
    self._angle = angle;

    return self;
end

function SkillStandAction:_OnStartHandler()
    local controller = self._controller
    if (controller) then
        local transform = controller.transform;

        if (self._angle) then
            --transform.rotation = Quaternion.Euler(0, self._angle, 0);
            Util.SetRotation(transform, 0,self._angle , 0)
        end
        if (self._position) then
            MapTerrain.SampleTerrainPositionAndSetPos(transform, self._position)
            --            transform.position = MapTerrain.SampleTerrainPosition(self._position);
        end
    end
end