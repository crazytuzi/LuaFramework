-- -------------------
-- 获得宠物
-- -------------------
DramaGetPetNew = DramaGetPetNew or BaseClass(BaseDramaPanel)

function DramaGetPetNew:__init()
    self.path = "prefabs/ui/drama/getpet.unity3d"
    self.texture = AssetConfig.getpet_textures

    self.effectPath = "prefabs/effect/20014.unity3d"
    self.effectPath1 = "prefabs/effect/20169.unity3d" --点击爆弹
    self.effectPath2 = "prefabs/effect/20172.unity3d" --点击孵化文字
    self.effectPath3 = "prefabs/effect/20230.unity3d"

    self.effect1 = nil
    self.effect2 = nil
    self.effect3 = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
        {file = self.effectPath2, type = AssetType.Main},
        {file = self.effectPath3, type = AssetType.Main},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
        {file = AssetConfig.geti18ngetpettitle,type = AssetType.Dep},
        {file = self.texture, type = AssetType.Dep},
    }

    self.actionover = true
    self.meshId = 0
    self.previewLoaded = false
    self.previewShowed = false
    self.listener = function(texture, modleList) self:OnTposeLoad(texture, modleList) end
    self.click = function() self:Destroy() end
    self.playaction = function() self:PlayAction() end

    self.actions = {"Idle1", "1000", "2000"}
    self.step = 0

    self.petId = nil
    self.callback = nil

    self.timeId = 0
    self.rotateId = 0

    self.setting = {
        name = "DramaGetPetNewPreview"
        ,orthographicSize = 0.45
        ,width = 341
        ,height = 341
        ,noDrag = true
        ,offsetY = -0.4
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil

    self.clickNext = false
    self.isEgg = false
end

function DramaGetPetNew:__delete()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    self.headImg.sprite = nil
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end
    if self.effect1 ~= nil then
        GameObject.DestroyImmediate(self.effect1)
        self.effect1 = nil
    end
    if self.effect2 ~= nil then
        GameObject.DestroyImmediate(self.effect2)
        self.effect2 = nil
    end
    if self.effect3 ~= nil then
        GameObject.DestroyImmediate(self.effect3)
        self.effect3 = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function DramaGetPetNew:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:ClickPanelNext() end)
    self.panelImg = self.transform:Find("Panel"):GetComponent(Image)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, -177, -400)
    self.effect:SetActive(false)

    self.effect1 = GameObject.Instantiate(self:GetPrefab(self.effectPath1))
    self.effect1.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1.transform.localScale = Vector3.one
    self.effect1.transform.localPosition = Vector3(0, -42, -400)
    self.effect1:SetActive(false)

    self.effect2 = GameObject.Instantiate(self:GetPrefab(self.effectPath2))
    self.effect2.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect2.transform, "UI")
    self.effect2.transform.localScale = Vector3.one
    self.effect2.transform.localPosition = Vector3(0, 137, -400)
    self.effect2:SetActive(false)

    self.effect3 = GameObject.Instantiate(self:GetPrefab(self.effectPath3))
    self.effect3.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect3.transform, "UI")
    self.effect3.transform.localScale = Vector3.one
    self.effect3.transform.localPosition = Vector3(0, 0, -400)
    self.effect3:SetActive(false)

    self.title = self.transform:Find("Main/Title").gameObject
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.light = self.transform:Find("Main/Light").gameObject
    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.rawImg = self.transform:Find("Main/RawImage").gameObject
    self.button = self.transform:Find("Main/Button").gameObject
    self.button.transform:GetComponent(TransitionButton).enabled = false

    self.newImg = self.transform:Find("Main/New").gameObject
    self.headObj = self.transform:Find("Main/Head").gameObject
    self.headRect = self.headObj:GetComponent(RectTransform)
    self.headImg = self.transform:Find("Main/Head/Img"):GetComponent(Image)
    self.halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")
    self.title.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.geti18ngetpettitle,"GetI18NGetPetTitle")


    self.rawImg:SetActive(false)
    self.newImg:SetActive(false)
    self.button:SetActive(false)
    self.halo:SetActive(false)
    self.light:SetActive(false)
    self.title:SetActive(false)

    self.button:GetComponent(Button).onClick:AddListener(function() self:Next() end)
    self.name.text = ""
end

function DramaGetPetNew:ClickPanelNext()
    if self.clickNext then
        self:Next()
    end
end

function DramaGetPetNew:OnInitCompleted()
    self.petId = self.openArgs.val
    self.genre = self.openArgs.genre
    self:SetData()
end

function DramaGetPetNew:SetData()
    DramaManager.Instance.model:ShowJump(false)
    self:Next()
end

function DramaGetPetNew:Next()
    self.clickNext = false
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.isEgg = false
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
    if self.effect1 ~= nil then
        self.effect1:SetActive(false)
    end
    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end
    if self.effect3 ~= nil then
        self.effect3:SetActive(false)
    end
    self.step = self.step + 1
    if self.step == 1 then
        self:ShowEgg()
    elseif self.step == 2 then
        self:BoomEgg()
    elseif self.step == 3 then
        self:ShowTitle()
    elseif self.step == 4 then
        self:ShowHaloLight()
        self:ShowPreview()
        self:PutNewImg()
    elseif self.step == 5 then
        self:ShowButton()
    elseif self.step == 6 then
        self:FxxkingCloud()
    elseif self.step == 7 then
        self:FxxkingFly()
    else
        self:Destroy()
    end
end

function DramaGetPetNew:ShowEgg()
    self.isEgg = true
    local modelData = {type = PreViewType.Npc, skinId = 40063, modelId = 40063, animationId = 4006301, scale = 1.5, isGetEgg = true}
    self:LoadPreview(modelData)
    self.effect2:SetActive(true)
    self.clickNext = true
    self.timeId = LuaTimer.Add(3000, function() self:Next() end)
end

function DramaGetPetNew:BoomEgg()
    self.rawImg:SetActive(false)
    self.effect2:SetActive(false)
    self.effect1:SetActive(true)
    SoundManager.Instance:Play(231)
    self.timeId = LuaTimer.Add(2000, function() self:Next() end)
end

function DramaGetPetNew:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function DramaGetPetNew:ShowHaloLight()
    self.halo:SetActive(true)
    self.light:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function DramaGetPetNew:ShowPreview()
    local pet = DataPet.data_pet[self.petId]
    self.name.text = pet.name
    self.meshId = pet.model_id
    local modelData = {type = PreViewType.Pet, skinId = pet.skin_id_0, modelId = pet.model_id, animationId = pet.animation_id, scale = pet.scale/100, effects = pet.effects_0}
    if self.genre == 1 then
        modelData.skinId = pet.skin_id_s0
        modelData.effects = pet.effects_s0
    end
    self:LoadPreview(modelData)
end

function DramaGetPetNew:PutNewImg()
    self.newImg:SetActive(true)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function DramaGetPetNew:ShowButton()
    self.timeId = LuaTimer.Add(500, function() self:PlayAction() end)
    self.button.transform.localScale = Vector3(3,3,1)
    self.button:SetActive(true)
    Tween.Instance:Scale(self.button, Vector3.one, 1, function() self:BeginCountDown() end, LeanTweenType.easeOutElastic)
end

function DramaGetPetNew:Rotate()
    self.light.transform:Rotate(Vector3(0, 0, 0.5))
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function DramaGetPetNew:Destroy()
    if self.countDownId ~= nil then
        LuaTimer.Delete(self.countDownId)
        self.countDownId = nil
    end
    if self.callback ~= nil then
        self.callback()
    end
end

function DramaGetPetNew:PlayAction()
    if not self.actionover then
        return
    end
    self.actionover = false
    self.animator:Play(self.actions[math.random(1,3)])
    self.timeId = LuaTimer.Add(20, function () self:ActionDelay() end)
end

function DramaGetPetNew:ActionDelay()
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    if delay ~= 0 then
        self.timeId = LuaTimer.Add(delay * 1000, function() self:ActionEnd() end)
    else
        self.actionover = true
    end
end

function DramaGetPetNew:ActionEnd()
    if self.animator ~= nil then
        self.animator:Play("Move1")
    end
    self.actionover = true
end

function DramaGetPetNew:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function DramaGetPetNew:SetRawImage(composite)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self:SetPosition()
    self.previewComp.tpose.transform:Rotate(Vector3(0, -30, 0))
    self.rawImg:SetActive(true)
    self.animator = composite.tpose:GetComponent(Animator)
    self.rawImg:GetComponent(Button).onClick:AddListener(function() self:ClickPanelNext() end)
end

--根据模型包围盒计算中心点
function DramaGetPetNew:SetPosition()
    if self.petId == 20001 then
        self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, -0.4, 0)
    else
        if not self.isEgg then
            local mesh = self.previewComp.tpose.transform:Find(string.format("Mesh_%s", self.meshId)):GetComponent(SkinnedMeshRenderer)
            local miny = mesh.bounds.min.y
            local maxy = mesh.bounds.max.y
            local y = (miny - maxy) / 2 + 0.05
            self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, y, 0)
        else
            self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, -0.25, 0)
        end
    end
end

function DramaGetPetNew:OnJump()
end

function DramaGetPetNew:BeginCountDown()
    self.clickNext = true
    self.effect:SetActive(true)
    self.timeId = LuaTimer.Add(3000, function() self:Next() end)
end

function DramaGetPetNew:FxxkingCloud()
    self.name.text = ""
    self.newImg:SetActive(false)
    self.title:SetActive(false)
    self.button:SetActive(false)
    self.rawImg:SetActive(false)
    self.effect3:SetActive(true)
    self.timeId = LuaTimer.Add(1000, function() self:Next() end)
end

function DramaGetPetNew:FxxkingFly()
    self.previewComp:Hide()
    self.headRect.anchorMax = Vector2.one * 0.5
    self.headRect.anchorMin = Vector2.one * 0.5
    self.headRect.anchoredPosition = Vector3.zero

    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.headImg.gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet,self.petId)
    -- self.headImg.sprite = PreloadManager.Instance:GetPetSprite(self.petId)
    self.headObj:SetActive(true)
    self.clickNext = true
    self.timeId = LuaTimer.Add(1000, function() self:BeginFly() end)
end

function DramaGetPetNew:BeginFly()
    if MainUIManager.Instance.petInfoView ~= nil then
        self.halo:SetActive(false)
        self.light:SetActive(false)
        self.panelImg.color = Color(1, 1, 1, 0)
        local t = MainUIManager.Instance.petInfoView.transform:Find("Main/PetHeadContainer/PetImage").transform.position
        Tween.Instance:Move(self.headObj, t, 0.4, function() self:FlyEnd() end, LeanTweenType.easeOutQuart)
    else
        self:FlyEnd()
    end
end

function DramaGetPetNew:FlyEnd()
    self:Next()
end
