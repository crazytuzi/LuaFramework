--地图渐色
GradualAction = GradualAction or BaseClass(CombatBaseAction)

function GradualAction:__init(brocastCtx, IsStart)
    self.map = self.brocastCtx.controller.map
    self.IsStart = IsStart
    -- self.material = self.map:GetComponent(MeshRenderer).material.sharedMaterial
    self.material = self.map.gameObject.renderer.sharedMaterial
    self.firstAction = nil
    local list = {}
    if self.IsStart then
        list = {
            {delay = 50, val = 0.8}
            ,{delay = 50, val = 0.6}
            ,{delay = 50, val = 0.4}
            ,{delay = 50, val = 0.2}
        }
    end
    self:Build(list)
end

function GradualAction:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    end
    self:OnActionEnd()
end

function GradualAction:OnActionEnd()
    if not self.IsStart then
        self:SetColorRGB(1)
    end
    self:InvokeAndClear(CombatEventType.End)
end

function GradualAction:Build(list)
    local delayAction = nil
    local lastAction = nil
    for _, data in ipairs(list) do
        delayAction = DelayAction.New(self.brocastCtx, data.delay)
        delayAction:AddEvent(CombatEventType.End, function() self:SetColorRGB(data.val) end)
        if self.firstAction == nil then
            self.firstAction = delayAction
        end
        if lastAction ~= nil then
            lastAction:AddEvent(CombatEventType.End, delayAction)
        end
        lastAction = delayAction
    end
end

function GradualAction:SetColorRGB(val)
    local color = self.material.color
    color.r = val
    color.g = val
    color.b = val
    self.material.color = color
end
