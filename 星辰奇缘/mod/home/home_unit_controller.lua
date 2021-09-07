-- 家园单元控制器
-- ljh 20160629
HomeUnitController = HomeUnitController or BaseClass(BaseMonoBehaviour)

local Vector3 = UnityEngine.Vector3

-- 家园单元控制器
function HomeUnitController:__init()
    self.transform = nil
    self.tpose = nil
    self.originTpose = nil

    -- Vector3
    self.originPos = nil

    -- Vector3
    self.selfWorldScreenPoint = nil
    self.isScreenPointChange = true

    self.downTime = 0
    self.isdown = false
    self.PointerClickEvent = {}
    self.PointerHoldEvent = {}

    self.isEdit = false
    self.mouseOffsetX = 0
    self.mouseOffsetY = 0
    self.mouseOffsetX2 = 0
    self.mouseOffsetY2 = 0

    self.homeUnitView = nil
    self.sceneElementsModel = SceneManager.Instance.sceneElementsModel
    self.mainCamera = SceneManager.Instance.MainCamera.camera
    self.homeElementsModel = HomeManager.Instance.homeElementsModel
    self.homeCanvasView = HomeManager.Instance.homeCanvasView

    self.OnPointerDown = function(eventData)
        self:__OnPointerDown(eventData)
    end
    self.OnPointerUp = function(eventData)
        self:__OnPointerUp(eventData)
    end
end

function HomeUnitController:__delete()

end

function HomeUnitController:AfterInit(transform)
    self.transform = transform
    self.originPos = self.transform.position
    self.tpose = transform:FindChild("tpose")
    self.originTpose = self.tpose
end

function HomeUnitController:Start()
    self.originPos = self.transform.position
end

-- 不需要FixedUpdate，就不要写FixedUpdate
-- function HomeUnitController:FixedUpdate()
    
-- end

function HomeUnitController:__OnPointerDown(eventData)
    self.downTime = Time.time
    self.isdown = true
    local pos = CombatUtil.WorldToUIPoint(self.mainCamera, self.transform.position)
    pos = Vector3(pos.x, pos.y,pos.z)
    self.holdTimer = LuaTimer.Add(640, function () self:OnPointerHold() end)
    if not self.isEdit and HomeManager.Instance.model:CanEditHome() then
        self.holdEffectTimer = LuaTimer.Add(300, function () if self.isdown then self.homeCanvasView:ShowHoldEffect({x = pos.x, y = pos.y + 75}) end end)
    end
    
    self.mouseOffsetX = Input.mousePosition.x - pos.x
    self.mouseOffsetY = Input.mousePosition.y - pos.y

    -- local p = CombatUtil.UIToWorldPoint(self.mainCamera, pos)
    local p = self.mainCamera:ScreenToWorldPoint(pos)
    self.mouseOffsetX2 = self.transform.position.x - p.x
    self.mouseOffsetY2 = self.transform.position.y - p.y
end

function HomeUnitController:__OnPointerUp(eventData)
    self.isdown = false
    local time = Time.time
    local offset = time - self.downTime
    if offset < 0.4 then
        for _, event in ipairs(self.PointerClickEvent) do
            event(eventData)
        end
        if self.holdEffectTimer ~= nil then LuaTimer.Delete(self.holdEffectTimer) end
        if self.holdTimer ~= nil then LuaTimer.Delete(self.holdTimer) end
    end
    self.homeCanvasView:HidHoldEffect()
    self.downTime = 0
end

function HomeUnitController:OnPointerHold()
    local time = Time.time
    local offset = time - self.downTime
    if self.downTime ~= 0 and offset >= 0.37 then
        for _, event in ipairs(self.PointerHoldEvent) do
            event()
        end
    end
    self.downTime = 0
end

function HomeUnitController:UpdateMove()
    if self.isdown and self.isEdit then
        local inputPoint = Vector2(Input.mousePosition.x - self.mouseOffsetX, Input.mousePosition.y - self.mouseOffsetY)
        local p = self.mainCamera:ScreenToWorldPoint(inputPoint)
        -- self.transform.position = Vector3(p.x + self.mouseOffsetX2, p.y + self.mouseOffsetY2, p.y + self.mouseOffsetY2 - 5)
        local px = ((p.x + self.mouseOffsetX2) / SceneManager.Instance.Mapsizeconvertvalue)
        local py = ((p.y + self.mouseOffsetY2) / SceneManager.Instance.Mapsizeconvertvalue)
        local gridWidth = ctx.sceneManager.Map.GridWidth
        local gridHeight = ctx.sceneManager.Map.GridHeight
        local gridOffsetX = (gridWidth / 2) - (px % gridWidth)
        local gridOffsetY = (gridHeight / 2) - (py % gridHeight)
        px = px + gridOffsetX
        py = py + gridOffsetY
        px = px * SceneManager.Instance.Mapsizeconvertvalue
        py = py * SceneManager.Instance.Mapsizeconvertvalue
        self.transform.position = Vector3(px, py, py - 5)
    end
end