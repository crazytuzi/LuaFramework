-- -------------------------------------
-- 宠物洗髓引导
-- hosr
-- -------------------------------------
GuideWorldChampionShare = GuideWorldChampionShare or BaseClass(BasePanel)

function GuideWorldChampionShare:__init(panel,startNum)
    self.panel = panel
    self.startNum = startNum or 1
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

function GuideWorldChampionShare:__delete()
    self:GuideEnd()
    if not BaseUtils.is_null(self.effect) then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
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

function GuideWorldChampionShare:InitPanel()
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

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self:Next()
end

function GuideWorldChampionShare:First()
    -- 选中花影
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.itemTab[self.startNum]["gameObject"]

    if BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end
    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3(0.85, 1, 1)
    self.effect.transform.localPosition = Vector3(0.5, 2, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(true)

    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
end


function GuideWorldChampionShare:Next()
    self.step = self.step + 1
    if self.step == 1 then
        self:First()
    else
        self:GuideEnd()
    end
end

function GuideWorldChampionShare:GuideEnd()
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
end