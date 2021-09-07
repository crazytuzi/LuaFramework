-- -------------------------------------------
-- 引导突破后属性兑换 第二步，加点界面
-- hosr
-- -------------------------------------------
GuideBreakPointSecond = GuideBreakPointSecond or BaseClass(BasePanel)

function GuideBreakPointSecond:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20103.unity3d"
    self.effect = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
    }

    self.step = 0

    self.next = function() self:Next() end

    self.lastGameObject = nil
end

function GuideBreakPointSecond:__delete()
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

function GuideBreakPointSecond:InitPanel()
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

function GuideBreakPointSecond:First()
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.exchangeBtnObj

    if BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end

    self.effect.transform:SetParent(self.lastGameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    self.effect:SetActive(true)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里进入属性兑换"), forward = TipsEumn.Forward.Right})
end

function GuideBreakPointSecond:Next()
    self.step = self.step + 1
    if self.step == 1 then
        self:First()
    else
        self:GuideEnd()
    end
end

function GuideBreakPointSecond:GuideEnd()
	TipsManager.Instance:HideGuide()
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
