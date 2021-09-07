-- 战斗摄像机
CombatCameraController = CombatCameraController or BaseClass(BaseMonoBehaviour)

function CombatCameraController:__init()
    self.transform = nil
    self.originPos = nil

    self.IsShake = false
    self.stepQueue = {}
end

function CombatCameraController:AfterInit(transform)
    self.transform = transform
    self.originPos = self.transform.position
end

function CombatCameraController:Start()
end

function CombatCameraController:FixedUpdate()
    if self.IsShake then
        if #self.stepQueue > 0 then
            local pos = self.stepQueue[1]
            table.remove(self.stepQueue, 1)
            self.transform.position = pos
        else
            self.transform.position = self.originPos
            self.stepQueue = {}
            self.IsShake = false
        end
    end
end

function CombatCameraController:SetQueue(queue)
    self.stepQueue = queue
    self.IsShake = true
end
