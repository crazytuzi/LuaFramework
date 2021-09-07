-- 震屏
ShakeCameraAction = ShakeCameraAction or BaseClass(CombatBaseAction)

function ShakeCameraAction:__init(brocastCtx, shakeType)
    self.mainCamera = self.brocastCtx.controller.mainCamera
    self.mainOriginPos = self.brocastCtx.controller.mainCameraPos
    self.combatMapCamera = self.brocastCtx.controller.combatMapCamera
    self.combatCamera = self.brocastCtx.controller.combatCamera
    self.originPos = self.brocastCtx.controller.combatCameraPosition
    self.list = {
        {0.025, 0.025}
        ,{-0.025, -0.025}
        ,{0.02, 0.02}
        ,{-0.02, -0.02}
    }
    if shakeType == CombatShakeType.Small then
        self.list = {
            {0.015, 0.015}
            ,{-0.015, -0.015}
            ,{0.01, 0.01}
            ,{-0.01, -0.01}
        }
    end
end

function ShakeCameraAction:Play()
    self:SetPos()
end

function ShakeCameraAction:SetPos()
    if #self.list > 0 then
        if BaseUtils.isnull(self.combatCamera) or BaseUtils.isnull(self.combatMapCamera) then
            -- Log.Error("抖镜头出错self.combatCamera是空，如果战斗正常结束可以无视")
            self:OnActionEnd()
            return
        end
        local pos = self.list[1]
        table.remove(self.list, 1)
        self.combatMapCamera.transform.position = Vector3(self.originPos.x + pos[1], self.originPos.y + pos[2], self.originPos.z)
        self.combatCamera.transform.position = Vector3(self.originPos.x + pos[1], self.originPos.y + pos[2], self.originPos.z)
        self.mainCamera.transform.position = Vector3(self.mainOriginPos.x + pos[1], self.mainOriginPos.y + pos[2], self.mainOriginPos.z)
        LuaTimer.Add(40, function () self:SetPos() end)
    else
        if BaseUtils.isnull(self.combatCamera) or BaseUtils.isnull(self.combatMapCamera) then
            -- Log.Error("抖镜头出错self.combatCamera是空，如果战斗正常结束可以无视")
            self:OnActionEnd()
        else
            self.combatMapCamera.transform.position = self.originPos
            self.combatCamera.transform.position = self.originPos
            self.mainCamera.transform.position = self.mainOriginPos
            self:OnActionEnd()
        end
    end
end

function ShakeCameraAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

ShakeCameraHandler = ShakeCameraHandler or BaseClass()

function ShakeCameraHandler:__init(sCamera, list, time, callback)
    self.count = 0
    self.isOver = false
    self.sCamera = sCamera
    self.list = list
    self.time = time
    self.callback = callback
end

function ShakeCameraHandler:Play()
    self.originPos = self.sCamera.transform.position
    LuaTimer.Add(self.time*1000, function () self:Over() end)
    self.count = 0
    self.isOver = false
    self:SetPos()
end

function ShakeCameraHandler:SetPos()
    if self.isOver then
        return
    end
    if BaseUtils.isnull(self.sCamera) then
        -- Log.Error("抖镜头出错self.sCamera是空，如果战斗正常结束可以无视")
        return
    end
    if self.count == #self.list then
        self.count = 0
    end
    self.count = self.count + 1
    local pos = self.list[self.count]
    self.sCamera.transform.position = Vector3(self.originPos.x + pos[1], self.originPos.y + pos[2], self.originPos.z)
    LuaTimer.Add(100, function () self:SetPos() end)
end

function ShakeCameraHandler:Over()
    self.isOver = true
    if BaseUtils.isnull(self.sCamera) then
        -- Log.Error("抖镜头出错self.sCamera是空，如果战斗正常结束可以无视")
        return
    end
    self.sCamera.transform.position = self.originPos
    if self.callback ~= nil then
        self.callback()
    end
end
