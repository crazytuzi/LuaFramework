-- -------------------------------------
-- 宠物加点引导
-- hosr
-- -------------------------------------
GuideHomeFurniture = GuideHomeFurniture or BaseClass(BasePanel)

function GuideHomeFurniture:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath1 = "prefabs/effect/20107.unity3d"
    self.effectPath2 = "prefabs/effect/20104.unity3d"
    self.effectPath3 = "prefabs/effect/20107.unity3d"
    self.effect = nil
    self.effect1 = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath2, type = AssetType.Main},
        {file = self.effectPath3, type = AssetType.Main},
    }

    self.effectList = {}

    self.step = 0

    self.next = function() self:Next() end

    self.lastGameObject = nil
end

function GuideHomeFurniture:__delete()
    self:GuideEnd()

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.lastGameObject = nil
    self.next = nil
    self.panel = nil
end

function GuideHomeFurniture:InitPanel()
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
    self.gameObject.name = "GuideAnyWay"
    UIUtils.AddUIChild(self.panel.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Next() end)

    for i=1,3 do
        self.effectList[i] = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self["effectPath" .. i]))
        self.effectList[i].name = "GuideHomeEffect" .. tostring(i)
        self.effectList[i].transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectList[i].transform.localScale = Vector3.one
        Utils.ChangeLayersRecursively(self.effectList[i].transform, "UI")
        self.effectList[i]:SetActive(false)
    end

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self:Next()
end

function GuideHomeFurniture:First()
    for i=1,3 do
        self.effectList[i]:SetActive(false)
    end
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.itemlist[1]
    if self.lastGameObject == nil or BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end

    self.effectList[3].transform:SetParent(self.lastGameObject.transform)
    self.effectList[3].transform.localScale = Vector3(1.1, 1.1, 1.1)
    self.effectList[3].transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effectList[1].transform, "UI")
    self.effectList[3]:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里，选择【卧室】")})
end

function GuideHomeFurniture:Senond()
    for i=1,3 do
        self.effectList[i]:SetActive(false)
    end
    self.gameObject:SetActive(false)

    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.okButton.gameObject
    if self.lastGameObject == nil or BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end
    self.effectList[2].transform:SetParent(self.lastGameObject.transform)
    self.effectList[2].transform.localScale = Vector3.one
    self.effectList[2].transform.localPosition = Vector3(0, 0, -400)
    self.effectList[2]:SetActive(true)
    Utils.ChangeLayersRecursively(self.effectList[2].transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里可建造卧室")})
    self.gameObject:SetActive(false)
end

function GuideHomeFurniture:Third()
    for i=1,3 do
        self.effectList[i]:SetActive(false)
    end
    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.lastGameObject = self.panel.itemlist[2]
    if self.lastGameObject == nil or BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end
    self.effectList[3].transform:SetParent(self.lastGameObject.transform)
    self.effectList[3].transform.localScale = Vector3(1.1, 1.1, 1.1)
    self.effectList[3].transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effectList[1].transform, "UI")
    self.effectList[3]:SetActive(true)
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("接下就自由选择建造的建筑吧")})
    -- self.gameObject:SetActive(true)
end

function GuideHomeFurniture:Next()
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

function GuideHomeFurniture:GuideEnd()
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
    end
    for i,v in ipairs(self.effectList) do
        v.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        v:SetActive(false)
    end
end
