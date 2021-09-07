-- 参战者状态更新
ResetStatusAction = ResetStatusAction or BaseClass(CombatBaseAction)

function ResetStatusAction:__init(brocastCtx, statusList, isbuffbrocast)
    self.statusList = statusList
    self.selfData = self.brocastCtx.controller.selfData
    self.selfPetData = self.brocastCtx.controller.selfPetData
    self.isbuffbrocast = isbuffbrocast
    self.syncAction = SyncSupporter.New(brocastCtx)
end

function ResetStatusAction:Play()
    for _, data in ipairs(self.statusList) do
        if self.selfData.id == data.id then
            self.selfData.is_die = data.is_die
        elseif self.selfPetData ~= nil and self.selfPetData.id == data.id then
            self.selfPetData.is_die = data.is_die
        end
    end
    for _, data in ipairs(self.statusList) do
        local fighter = self.brocastCtx:FindFighter(data.id)
        if fighter ~= nil then
            fighter.fighterData.hp = data.hp
            fighter.fighterData.mp = data.mp
            fighter.fighterData.hp_max = data.hp_max
            fighter.fighterData.mp_max = data.mp_max
            fighter:SetOrder(data.order)
            fighter:UpdateHpBar()
            -- if self.isbuffbrocast then
            --     print("_________________________")
            --     print(data.id)
            --     print(string.format("客户端单位死亡：%s", tostring(fighter.fighterData.is_die == 1)))
            --     print(string.format("服务单位死亡：%s", tostring(data.is_die == 1)))
            --     print(string.format("单位是不是死亡动作：%s", tostring(fighter.currAction == FighterAction.Dead)))
            --     print("++++++++++++++++++++++++++++")
            -- end
            if self.isbuffbrocast == true and data.is_die == 1 and fighter.currAction ~= FighterAction.Dead and fighter.IsDisappear == false then -- 是否buff扣血死亡
            -- if fighter.fighterData.is_die == 0 and data.is_die == 1 then -- 是否buff扣血死亡
                local deadAction = nil
                -- if data.is_die_disappear == 0 then
                    deadAction = DeadAction.New(self.brocastCtx, data.id)
                -- else
                    -- deadAction = DeadFlyAction.New(self.brocastCtx, data.id)
                -- end
                local delay = DelayAction.New(self.brocastCtx, 750)
                delay:AddEvent(CombatEventType.End, deadAction)
                if data.is_die_disappear == 1 then
                    local disapper = DisapperAction.New(self.brocastCtx, fighter.fighterData.id)
                    delay:AddEvent(CombatEventType.End, disapper)
                end
                self.syncAction:AddAction(delay)
            elseif self.isbuffbrocast == true and data.is_die == 1 and (data.is_die_disappear == 1 and fighter.IsDisappear == false) then
                local disapper = DisapperAction.New(self.brocastCtx, fighter.fighterData.id)
                self.syncAction:AddAction(disapper)
            elseif data.is_escape == 1 and fighter.IsDisappear == false then
                fighter:HideBloodBar()
                fighter:HideCommand()
                fighter:HideNameText()
                fighter:HideBuffPanel()
                fighter:ShowShadow(false)
                fighter:SetDisappear(true)
                if not BaseUtils.isnull(fighter.tpose) then
                    CombatUtil.SetMesh(fighter.tpose, false)
                end
                if not BaseUtils.isnull(fighter.transform) then
                    fighter.transform.gameObject:SetActive(false)
                end
            elseif data.is_die == 0 and (fighter.IsDisappear == true or fighter.currAction == FighterAction.Dead) and data.is_escape ~= 1 then
                fighter:ShowBloodBar()
                fighter:ShowNameText()
                fighter:ShowBuffPanel()
                fighter:ShowShadow(true)
                fighter:SetDisappear(false)
                fighter:SetAlpha(1)
                if not BaseUtils.isnull(fighter.tpose) then
                    CombatUtil.SetMesh(fighter.tpose, true)
                end
                if not BaseUtils.isnull(fighter.transform) then
                    fighter.transform.gameObject:SetActive(true)
                end
            end
            fighter.fighterData.is_die = data.is_die
        end
    end
    self:OnActionEnd()
    self.syncAction:Play()
end

function ResetStatusAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
