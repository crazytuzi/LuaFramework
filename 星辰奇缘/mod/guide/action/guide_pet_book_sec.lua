-- ---------------------------------
-- 宠物打书引导最后一步
-- hosr
-- ---------------------------------
GuidePetBookSec = GuidePetBookSec or BaseClass(BasePanel)

function GuidePetBookSec:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20104.unity3d"
    self.effect = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
    }

    self.step = 0

    self.next = function() self:Next() end

    self.lastGameObject = nil
end

function GuidePetBookSec:__delete()
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

    self.panel = nil
    self.lastGameObject = nil
    self.next = nil
end

function GuidePetBookSec:InitPanel()
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

function GuidePetBookSec:First()
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.guideOkBtn

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
    LuaTimer.Add(200, function() TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点这里就可以学新技能啦")}) end)
end

function GuidePetBookSec:Next()
    self.step = self.step + 1
    if self.step == 1 then
        self:First()
    else
        self:GuideEnd()
    end
end

function GuidePetBookSec:GuideEnd()
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

    self.gameObject:SetActive(false)
    if not BaseUtils.is_null(self.effect) then
        self.effect.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect:SetActive(false)
    end

    TipsManager.Instance:HideGuide()
end
