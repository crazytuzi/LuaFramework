-- 特效飞行

FlyController = FlyController or BaseClass(BaseMonoBehaviour)

function FlyController:__init()
    self.transform = nil

    self.IsMove = false

    self.timeStep = 0.02
    self.srcPos = nil
    self.targetPos = nil
    self.total = 0
    self.fast = false

    self.stepQueue = {}
    self.moveEndEvent = {}
end

function FlyController:__delete()
end

function FlyController:Setting(srcPos, targetPos, total, isThunder)
    self.srcPos = srcPos
    self.targetPos = targetPos
    self.total = total / 1000
    self.isThunder = isThunder
    local dis = Vector3.Distance(srcPos, self.targetPos.transform.position)
    if dis < 2 then
        self.fast = true
    end
end

function FlyController:AddMoveEndListener(listener)
    table.insert(self.moveEndEvent, listener)
end

function FlyController:AfterInit(transform)
    self.transform = transform
end

function FlyController:Start()
    local dx = 0
    local dy = 0
    local dz = 0

    self.stepQueue = {}

    local seed = math.floor(self.total / self.timeStep)
    if self.fast then
        seed = seed / 3
        seed = math.ceil(seed)
    end

    local distX = (self.targetPos.transform.position.x - self.srcPos.x) / seed
    local distY = (self.targetPos.transform.position.y - self.srcPos.y) / seed
    local distZ = (self.targetPos.transform.position.z - self.srcPos.z) / seed

    for i = 1, seed do
        dx = distX * i
        dy = distY * i
        dz = distZ * i

        if i == seed then
            table.insert(self.stepQueue, Vector3(self.targetPos.transform.position.x, self.targetPos.transform.position.y, self.targetPos.transform.position.z))
        else
            table.insert(self.stepQueue, Vector3(self.srcPos.x + dx, self.srcPos.y + dy, self.srcPos.z + dz))
        end
    end
    self.IsMove = true
    if self.isThunder then
        -- 雷电链接用线性
        Tween.Instance:Move(self.transform.gameObject, self.targetPos.transform.position, self.total, function() self:OnMoveEnd() end, LeanTweenType.linear)
    else
        Tween.Instance:Move(self.transform.gameObject, self.targetPos.transform.position, self.total, function() self:OnMoveEnd() end, LeanTweenType.easeInSine)
    end
end

-- function FlyController:FixedUpdate()
    -- if self.IsMove then
    --     -- self:OnMoveEnd()
    --     if #self.stepQueue > 0 then
    --         local pos = self.stepQueue[1]
    --         table.remove(self.stepQueue, 1)
    --         self.transform.position = pos
    --     else
    --         self.IsMove = false
    --         self:OnMoveEnd()
    --     end
    -- end
-- end

function FlyController:OnMoveEnd()
    for _, listener in ipairs(self.moveEndEvent) do
        listener()
    end
    self.moveEndEvent = {}
end
