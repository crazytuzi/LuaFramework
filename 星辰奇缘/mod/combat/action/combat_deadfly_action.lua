-- 死飞
DeadFlyAction = DeadFlyAction or BaseClass(CombatBaseAction)

function DeadFlyAction:__init(brocastCtx, fighterId)
    self.fighterId = fighterId
    self.fighterCtrl = self:FindFighter(fighterId)
    -- if not self.fighterCtrl.IsDisappear then
    if self.fighterCtrl == nil or BaseUtils.isnull(self.fighterCtrl.transform) then
        self.list = {Vector3.zero}
        return
    end
    self.originPos = self.fighterCtrl.transform.position
    self.targetPos = CombatUtil.GetBehindPoint(self.fighterCtrl, -20)

    self.list = {}

    local dist =  CombatUtil.Distance(
                        self.originPos.x
                        ,self.originPos.z
                        ,self.targetPos.x
                        ,self.targetPos.z
                    )
    local speed = 0.227
    local seed = math.floor(dist / speed)
    local dx = 0
    local dz = 0
    if seed < 1 then
        seed = 1
    end
    local distX = (self.originPos.x - self.targetPos.x) / seed
    local distZ = (self.originPos.z - self.targetPos.z) / seed
    for i = 1, seed do
        if i == 1 then
            table.insert(self.list, self.originPos)
        elseif i == seed then
            table.insert(self.list, self.targetPos)
        else
            dx = distX * i
            dz = distZ * i
            table.insert(self.list, Vector3(self.originPos.x + dx, self.originPos.y, self.originPos.z + dz))
        end
    end
    -- end
    if self.fighterCtrl ~= nil and islast ~= false then
        local modelid = self.fighterCtrl:GetModelId()
        local key = 1
        if self.fighterCtrl.fighterData.type == FighterType.Role or self.fighterCtrl.fighterData.type == FighterType.Cloner then
            key = BaseUtils.Key(0, self.fighterCtrl.fighterData.classes, self.fighterCtrl.fighterData.sex)
        else
            key = BaseUtils.Key(modelid, 0, 0)
        end
        local data = DataSkillSound.data_skill_sound_hit[key]
        if data ~= nil then
            self.soundaction = SoundAction.New(self.brocastCtx, data)
        end
    end
end

function DeadFlyAction:Play()
    if self.soundaction ~= nil then
        self.soundaction:Play()
    end
    if self.fighterCtrl ~= nil and not self.fighterCtrl.IsDisappear then
        self.fighterCtrl:HideBloodBar()
        self.fighterCtrl:HideCommand()
        self.fighterCtrl:HideNameText()
        self.fighterCtrl:HideBuffPanel()
        self.fighterCtrl:SetDisappear(true)
        if self.fighterCtrl.fighterData ~= nil then
        self.fighterCtrl.fighterData.is_die = 1
    end
        self:SetPos()
    else
        self:OnActionEnd()
    end
end

function DeadFlyAction:SetPos()
    if #self.list > 1 and CombatManager.Instance.isFighting and self.fighterCtrl ~= nil and not BaseUtils.is_null(self.fighterCtrl.transform) and self.fighterCtrl.IsDisappear then
        local pos = self.list[1]
        table.remove(self.list, 1)
        self.fighterCtrl.transform:Rotate(Vector3(0, 30, 0))
        self.fighterCtrl.transform.position = pos
        self:InvokeDelay(self.SetPos, 0.02, self)
    else
        self:OnActionEnd()
    end
end

function DeadFlyAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
    if self.fighterCtrl ~= nil and not BaseUtils.isnull(self.fighterCtrl.transform) then
        LuaTimer.Add(2000, function() if self.fighterCtrl.fighterData ~= nil and self.fighterCtrl.fighterData.IsDisappear then self.fighterCtrl:DeleteMe() end  end)
    end
end
