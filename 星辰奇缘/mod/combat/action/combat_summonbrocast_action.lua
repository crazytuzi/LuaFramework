-- 10720播报招唤
SummonBrocastAction = SummonBrocastAction or BaseClass(CombatBaseAction)

function SummonBrocastAction:__init(brocastCtx)
    self.brocastCtx = brocastCtx
    self.firstAction = nil
    self:Parse()

    local enterData = CombatManager.Instance.enterData
    self.atk_formation = enterData.atk_formation
    self.atk_formation_lev = enterData.atk_formation_lev
    self.dfd_formation = enterData.dfd_formation
    self.dfd_formation_lev = enterData.dfd_formation_lev
end

function SummonBrocastAction:Parse()
    local summonPlayList = self.brocastCtx.brocastData.summon_play_list
    self.majorctx = {
        assetwrapper = 1
    }
    local loadAction = AssetWrapperAction.New(self.brocastCtx, self.majorctx, {})
    local createFighterAction = SyncSupporter.New(self.brocastCtx)
    for _, summonData in ipairs(summonPlayList) do
        if summonData.group == 0 then
            CombatManager.Instance:ChangeFighterPos(self.atk_formation, self.atk_formation_lev, summonData)
        else
            CombatManager.Instance:ChangeFighterPos(self.dfd_formation, self.dfd_formation_lev, summonData)
        end
        local resList = self.brocastCtx.controller:GetFighterResList(summonData.summons)
        loadAction:AddResPath(resList)
        loadAction:AddResPath({"prefabs/effect/16162.unity3d"})
        loadAction:AddResPath({"prefabs/effect/16271.unity3d"})

        local order = summonData.order
        local subOrder = summonData.sub_order
        for _, fighterData in ipairs(summonData.summons) do
            createFighterAction:AddAction(SummonCreateAction.New(self.brocastCtx, fighterData, self.majorctx))
        end
    end
    loadAction:AddEvent(CombatEventType.End, createFighterAction)
    createFighterAction:AddEvent(CombatEventType.End, self.OnActionEnd, self)
    self.firstAction = loadAction
end

function SummonBrocastAction:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    else
        self:OnActionEnd()
    end
end

function SummonBrocastAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
    if self.majorctx ~= nil and self.majorctx.assetwrapper ~= nil then
        self.majorctx.assetwrapper:DeleteMe()
        self.majorctx.assetwrapper = nil
    end
end


-- 创建fighter
SummonCreateAction = SummonCreateAction or BaseClass(CombatBaseAction)

function SummonCreateAction:__init(brocastCtx, fighterData, majorctx)
    self.controller = self.brocastCtx.controller
    self.fighterData = fighterData
    self.majorctx = majorctx
    self.effectObject = nil
    self.target = nil
end

function SummonCreateAction:Play()
    local fighter = self.fighterData
    local selfGroup = self.brocastCtx.controller.selfData.group
    if fighter.type == FighterType.Role or fighter.type == FighterType.Cloner then
        self.controller:CreateRoleFighter(fighter, selfGroup, self.majorctx.assetwrapper, true)
    elseif fighter.type == FighterType.Unit then
        self.controller:CreateNpcFighter(fighter, selfGroup, self.majorctx.assetwrapper, true)
    elseif fighter.type == FighterType.Pet then
        self.controller:CreateNpcFighter(fighter, selfGroup, self.majorctx.assetwrapper, true)
    elseif fighter.type == FighterType.Child then
        self.controller:CreateNpcFighter(fighter, selfGroup, self.majorctx.assetwrapper, true)
        --if fighter.master_fid == self.brocastCtx.controller.selfData.id then
        --    self.controller.selfPetData = fighter
        --end
    elseif fighter.type == FighterType.Guard then
        self.controller:CreateNpcFighter(fighter, selfGroup, self.majorctx.assetwrapper, true)
    end
    local ctrl = self.brocastCtx:FindFighter(fighter.id)
    if ctrl ~= nil then
        ctrl:HideBloodBar()
        ctrl:HideBuffPanel()
        ctrl:HideNameText()
        ctrl:HideCommand()
        ctrl:SetDisappear(true)
        -- ctrl:ShowShadow(false)
        -- -- ctrl:SetAlpha(0)
        -- CombatUtil.SetMesh(ctrl.tpose, false)
        ctrl.transform.gameObject:SetActive(false)
    end

    local effectPrefab = nil
    if fighter.type == 6 then
        effectPrefab = self.majorctx.assetwrapper:GetMainAsset("prefabs/effect/16271.unity3d")
    else
        effectPrefab = self.majorctx.assetwrapper:GetMainAsset("prefabs/effect/16162.unity3d")
    end
    self.effectObject = GameObject.Instantiate(effectPrefab)
    if ctrl ~= nil then
        self.target = ctrl.transform:FindChild("tpose").gameObject
    end
    self.effectObject.gameObject.name = "summonsEffect"
    self.effectObject.transform:SetParent(self.target.transform)
    self.effectObject.transform.localScale = Vector3(1, 1, 1)
    self.effectObject.transform.localPosition = Vector3(0, 0, 0)
    self.effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effectObject.transform, "Ignore Raycast")
    self.effectObject:SetActive(false)
    self:OnActionEnd()
end

function SummonCreateAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

