-- -------------------------------------
-- 宠物洗髓引导
-- hosr
-- -------------------------------------
GuidePetWash = GuidePetWash or BaseClass(BasePanel)

function GuidePetWash:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20107.unity3d"
    self.effectPath1 = "prefabs/effect/20103.unity3d"
    self.effectPath2 = "prefabs/effect/20104.unity3d"
    self.effect = nil
    self.effect1 = nil
    self.effect2 = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
        {file = self.effectPath2, type = AssetType.Main},
    }

    self.step = 0

    self.next = function() self:Next() end

    self.lastGameObject = nil
end

function GuidePetWash:__delete()
    self:GuideEnd()
    if not BaseUtils.is_null(self.effect) then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end

    if not BaseUtils.is_null(self.effect1) then
        GameObject.DestroyImmediate(self.effect1)
        self.effect1 = nil
    end

    if not BaseUtils.is_null(self.effect2) then
        GameObject.DestroyImmediate(self.effect2)
        self.effect2 = nil
    end

    if not BaseUtils.is_null(self.gameObject) then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.lastGameObject = nil
    self.next = nil
    self.panel = nil
end

function GuidePetWash:InitPanel()
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
    self.gameObject.name = "GuideAnyWay"
    UIUtils.AddUIChild(self.panel.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Next() end)

    self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
    self.effect.name = "GuideSkillEffect"
    self.effect.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    self.effect1 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath1))
    self.effect1.name = "GuideSkilleffect1"
    self.effect1.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect1.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(false)

    self.effect2 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath2))
    self.effect2.name = "GuideSkilleffect2"
    self.effect2.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effect2.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect2.transform, "UI")
    self.effect2:SetActive(false)

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self:Next()
end

function GuidePetWash:First()
    -- 选中花影
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.headbar:selectPetObjByBaseId(10003)

    if BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end

    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(114, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    self.effect:SetActive(true)
    self.panel.canUpdateHead = false
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击选择要洗髓的宠物"), forward = TipsEumn.Forward.Right})
end

function GuidePetWash:Senond()
    self.next()

    -- if not self:Check1() then
    --     self:GuideEnd()
    --     return
    -- end

    -- self.effect:SetActive(false)
    -- self.effect1:SetActive(false)
    -- if self.openArgs == 0 then
    --     -- 非出战状态
    --     self.next()
    --     return
    -- end

    -- if not BaseUtils.is_null(self.lastGameObject) then
    --     self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    -- end

    -- self.lastGameObject = self.panel.childTab[self.panel.childIndex.base].guideBattleBtn.gameObject
    -- self.effect2.transform:SetParent(self.lastGameObject.transform)
    -- self.effect2.transform.localScale = Vector3.one
    -- self.effect2.transform.localPosition = Vector3(0, 0, -400)
    -- self.effect2:SetActive(true)
    -- Utils.ChangeLayersRecursively(self.effect2.transform, "UI")
    -- self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    -- self.panel.tabGroup:ChangeTab(1)
    -- self.panel.headbar:selectPetByBaseId(10003)
    -- self.panel.canUpdateHead = true
    -- TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("先让宠物休息，才能开始洗髓哦"), forward = TipsEumn.Forward.Left})
    -- self.gameObject:SetActive(false)
end

function GuidePetWash:Third()
    if not self:Check1() then
        self:GuideEnd()
        return
    end

    if self.panel.tabGroup.currentIndex == 2 then
        self:GuideEnd()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet)
        return
    end

    self.effect:SetActive(false)
    self.effect2:SetActive(false)
    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.tabGroup.buttonTab[2].gameObject
    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(30, 0, -400)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    self.panel.headbar:selectPetByBaseId(10003)
    self.panel.canGuideSecond = true
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("现在进入洗髓界面吧"), forward = TipsEumn.Forward.Left})
end

function GuidePetWash:Next()
    self.step = self.step + 1
    if self.step == 1 then
        self:First()
    elseif self.step == 2 then
        self:Senond()
    elseif self.step == 3 then
        self:Third()
    else
        self:GuideEnd()
    end
end

function GuidePetWash:GuideEnd()
    self.panel.canGuideSecond = true
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
    end
    if not BaseUtils.is_null(self.effect) then
        self.effect.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect:SetActive(false)
    end
    if not BaseUtils.is_null(self.effect1) then
        self.effect1.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect1:SetActive(false)
    end
    if not BaseUtils.is_null(self.effect2) then
        self.effect2.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect2:SetActive(false)
    end
end

function GuidePetWash:Check()
    if RoleManager.Instance.RoleData.lev >= 15 and RoleManager.Instance.RoleData.lev < 50 and PetManager.Instance.model:getpetid_bybaseid(10003) ~= nil then
        local petData,_ = PetManager.Instance.model:getpet_byid(PetManager.Instance.model:getpetid_bybaseid(10003))
        local questData = QuestManager.Instance.questTab[10300]
        if questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish and petData.status == 0 then
            return true
        end

        questData = QuestManager.Instance.questTab[22300]
        if questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish and petData.status == 0 then
            return true
        end
    end
    return false
end

function GuidePetWash:Check1()
    if RoleManager.Instance.RoleData.lev >= 15 and RoleManager.Instance.RoleData.lev < 50 and PetManager.Instance.model:getpetid_bybaseid(10003) ~= nil then
        local questData = QuestManager.Instance.questTab[10300]
        if questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish then
            return true
        end

        questData = QuestManager.Instance.questTab[22300]
        if questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish then
            return true
        end
    end
    return false
end
