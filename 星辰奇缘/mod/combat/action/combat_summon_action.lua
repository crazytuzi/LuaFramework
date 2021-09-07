-- 召唤
SummonAction = SummonAction or BaseClass(CombatBaseAction)

function SummonAction:__init(brocastCtx, fighter)
    -- BaseUtils.dump(fighter,"召唤数据")
    self.controller = self.brocastCtx.controller
    self.fighter = fighter
    self.syncBuffAction = SyncSupporter.New(self)
    self.fighter.buffs = self.fighter.buff_infos
    if self.fighter.buffs ~= nil and next(self.fighter.buffs) ~= nil then
        local buffAction = BuffSimplePlayAction.New(self, self.fighter)
        self.syncBuffAction:AddAction(buffAction)
    end
end

function SummonAction:Play()
    local ctrl = self:FindFighter(self.fighter.id)
    if ctrl ~= nil then
        self:HideOldPet(ctrl)

        ctrl:ShowBloodBar()
        ctrl:ShowNameText()
        ctrl:SetDisappear(false)
        ctrl:ShowShadow(true)
        -- ctrl:SetAlpha(1)
        CombatUtil.SetMesh(ctrl.tpose, true)
        ctrl.transform.position = ctrl.originPos
        ctrl.transform.gameObject:SetActive(true)
        local effect = ctrl.tpose:FindChild("summonsEffect")
        if not BaseUtils.isnull(effect) then
            effect.gameObject:SetActive(true)
            self:InvokeDelay(function() if not BaseUtils.isnull(effect) then GameObject.Destroy(effect.gameObject) end end, 1.5)
        end
    end
    -- print("<color='#ffff00'>召唤播放完毕？？？？？</color>")
    self:OnActionEnd()
end

function SummonAction:OnActionEnd()
    self.syncBuffAction:Play()
    self:InvokeAndClear(CombatEventType.End)
end

function SummonAction:HideOldPet(newCtrl)
    local fighterData = newCtrl.fighterData
    local masterId = fighterData.master_fid

    if masterId == self.controller.selfData.id then
        self.controller.selfPetData = fighterData
        self.controller.mainPanel.skillareaPanel:RefreshPetSkill()
        self.controller.mainPanel:InitPetHeadPanel(fighterData)
    end

    local eastList = self.controller.eastFighterList
    local westList = self.controller.westFighterList
    if not self:FindMaster(eastList, masterId, fighterData) then
        self:FindMaster(westList, masterId, fighterData)
    end
end

function SummonAction:FindMaster(FighterComboList, masterId, newData)
    for _, combo in ipairs(FighterComboList) do
        local fighterId = combo.fighterId
        local ctrl = self.brocastCtx:FindFighter(fighterId)
        if (ctrl.fighterData.type == newData.type or ((ctrl.fighterData.type == FighterType.Child or ctrl.fighterData.type == FighterType.Pet) and (newData.type == FighterType.Child or newData.type == FighterType.Pet)))
            -- 单位类型一样或者都是宠物和孩子
            and fighterId ~= newData.id
            and ctrl.fighterData.master_fid == masterId
            and (ctrl.fighterData.type == FighterType.Child or ctrl.fighterData.type == FighterType.Pet) then
            ctrl:HideBloodBar()
            ctrl:HideNameText()
            ctrl:SetDisappear(true)
            ctrl:ShowShadow(false)
            ctrl:HideCommand()
            ctrl:SetAlpha(0)
            ctrl.buffCtrl:HideBuffPanel()
            if BaseUtils.isnull(ctrl.transform) then
                return
            end
            ctrl.transform.gameObject:SetActive(false)
            local targetPos = CombatUtil.GetBehindPoint(ctrl, -10)
            ctrl.transform.position = targetPos
        end
    end
    return false
end
