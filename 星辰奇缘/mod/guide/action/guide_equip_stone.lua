-- ----------------------------
-- 装备宝石引导
-- hosr
-- ----------------------------
GuideEquipStone = GuideEquipStone or BaseClass(BasePanel)

function GuideEquipStone:__init(panel)
    self.panel = panel
    self.path = "prefabs/ui/guide/guideanyway.unity3d"
    self.effectPath = "prefabs/effect/20103.unity3d"
    self.effectPath1 = "prefabs/effect/20107.unity3d"
    self.effect = nil
    self.effect1 = nil
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
    }
    self.step = 0
    self.next = function() self:Next() end
    self.lastGameObject = nil
end

function GuideEquipStone:__delete()
    self:GuideEnd()
    if not BaseUtils.is_null(self.effect) then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end

    if not BaseUtils.is_null(self.effect1) then
        GameObject.DestroyImmediate(self.effect1)
        self.effect1 = nil
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

function GuideEquipStone:InitPanel()
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

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self:Next()
end

function GuideEquipStone:Next()
    if not BaseUtils.is_null(self.lastGameObject) then
        self.lastGameObject:GetComponent(Button).onClick:RemoveListener(self.next)
    end

	self.step = self.step + 1
	if self.step == 1 then
		self:ChooseWeapon()
	elseif self.step == 2 then
		self:ChooseStone()
	else
		self:GuideEnd()
	end
end

function GuideEquipStone:ChooseWeapon()
    self.effect:SetActive(false)
    self.effect1:SetActive(false)
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.item_list[1].gameObject
    if BaseUtils.is_null(self.lastGameObject) then
        self:GuideEnd()
        return
    end

    self.effect1.transform:SetParent(self.lastGameObject.transform)
    self.effect1.transform.localScale = Vector3(1.3, 1.2, 1)
    self.effect1.transform.localPosition = Vector3(140, -36, -400)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.lastGameObject:GetComponent(Button).onClick:AddListener(self.next)
    self.effect1:SetActive(true)
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("选择<color='#00ff00'>镶嵌宝石</color>的部位"), forward = TipsEumn.Forward.Right})
end

function GuideEquipStone:ChooseStone()
    self.effect:SetActive(false)
    self.effect1:SetActive(false)
    self.gameObject:SetActive(false)

    self.lastGameObject = self.panel.bottom_stone1.Button.gameObject
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
    TipsManager.Instance:ShowGuide({gameObject = self.lastGameObject, data = TI18N("点击<color='#00ff00'>镶嵌宝石</color>"), forward = TipsEumn.Forward.Right})
end

function GuideEquipStone:GuideEnd()
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
    if not BaseUtils.is_null(self.effect1) then
        self.effect1.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effect1:SetActive(false)
    end
end