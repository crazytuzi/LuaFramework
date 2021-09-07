-- -------------------
-- 获得宠物  精灵蛋
-- -------------------
GetGodPet = GetGodPet or BaseClass(BaseDramaPanel)

function GetGodPet:__init()
    self.path = "prefabs/ui/drama/getpet.unity3d"
    self.texture = AssetConfig.getpet_textures

    self.effectPath = "prefabs/effect/20014.unity3d"  --手指点击
    self.effectPath1 = "prefabs/effect/20169.unity3d" --点击爆弹
    -- self.effectPath2 = "prefabs/effect/20172.unity3d" --点击孵化文字
    self.effectPath2 = "prefabs/effect/20481.unity3d" --点击开启文字
    -- self.effectPath3 = "prefabs/effect/20432.unity3d"  --进化闪光特效
    -- self.effectPath3 = "prefabs/effect/20526.unity3d"  --进化闪光特效
    self.effectPath3 = "prefabs/effect/20530.unity3d"  --进化闪光特效
    -- self.effectPath4 = "prefabs/effect/20433.unity3d"  --"熊猫蛋"孵化
    --self.effectPath4 = "prefabs/effect/20485.unity3d"  --"鱼蛋"孵化
    -- self.effectPath4 = "prefabs/effect/20520.unity3d"  --"狮子蛋"孵化
    -- self.effectPath4 = "prefabs/effect/20524.unity3d"  --"兔子蛋"孵化
    self.effectPath4 = "prefabs/effect/20529.unity3d"   --"萝卜蛋"孵化
    
    self.effectPath5 = "prefabs/effect/20434.unity3d" --点击进化文字
    --
    self.effect1 = nil
    self.effect2 = nil
    self.effect3 = nil
    self.effect4 = nil
    self.effect5 = nil

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.effectPath1, type = AssetType.Main},
        {file = self.effectPath2, type = AssetType.Main},
        {file = self.effectPath3, type = AssetType.Main},
        {file = self.effectPath4, type = AssetType.Main},
        {file = self.effectPath5, type = AssetType.Main},
        {file = AssetConfig.geti18npandatitle,type = AssetType.Dep},
        {file = AssetConfig.geti18nevolvetitle,type = AssetType.Dep},


        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
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

    self.goodId = nil
    self.typeId = nil
    self.callback = nil

    self.timeId = 0
    self.rotateId = 0

    self.setting = {
        name = "GetGodPetPreview"
        ,orthographicSize = 0.75
        ,width = 682
        ,height = 600
        ,noDrag = true
        ,offsetY = -0.4
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self._onvalueReturn = function() self:OnvalueReturn() end
    PetManager.Instance.onReceiveValue:Add(self._onvalueReturn)
    self.previewComp = nil

    self.clickNext = false
    self.isEgg = false
    self.time = 16
end

function GetGodPet:__delete()
    self.headImg.sprite = nil
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if self.timeId3 ~= nil then
        LuaTimer.Delete(self.timeId3)
        self.timeid3 = nil
    end
    if self.timeId10 ~= nil then
        LuaTimer.Delete(self.timeId10)
        self.timeid10 = nil
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
    if self.effect4 ~= nil then
        GameObject.DestroyImmediate(self.effect4)
        self.effect4 = nil
    end
    if self.effect5 ~= nil then
        GameObject.DestroyImmediate(self.effect5)
        self.effect5 = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    PetManager.Instance.onReceiveValue:Remove(self._onvalueReturn)
end

function GetGodPet:InitPanel()
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
    self.effect3.transform.localPosition = Vector3(0, -72, -400)
    self.effect3:SetActive(false)

    self.effect4 = GameObject.Instantiate(self:GetPrefab(self.effectPath4))
    self.effect4.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect4.transform, "UI")
    self.effect4.transform.localScale = Vector3.one
    self.effect4.transform.localPosition = Vector3(0, 0, -400)
    self.effect4:SetActive(false)

    self.effect5 = GameObject.Instantiate(self:GetPrefab(self.effectPath5))
    self.effect5.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect5.transform, "UI")
    self.effect5.transform.localScale = Vector3.one
    self.effect5.transform.localPosition = Vector3(0, -150, -400)
    self.effect5:SetActive(false)

    self.title = self.transform:Find("Main/Title").gameObject
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.light = self.transform:Find("Main/Light").gameObject


    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.name.fontSize =18
    self.rawImg = self.transform:Find("Main/RawImage").gameObject
    self.button = self.transform:Find("Main/Button").gameObject
    self.halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")
    self.newImg = self.transform:Find("Main/New").gameObject
    self.headObj = self.transform:Find("Main/Head").gameObject
    self.headRect = self.headObj:GetComponent(RectTransform)
    self.headImg = self.transform:Find("Main/Head/Img"):GetComponent(Image)
    self.countDown = self.transform:Find("Main/CountDown").gameObject
    self.countDownT = self.countDown:GetComponent(Text)

    self.rawImg:SetActive(false)
    self.newImg:SetActive(false)
    self.button:SetActive(false)
    self.halo:SetActive(false)
    self.light:SetActive(false)
    self.title:SetActive(false)
    self.countDown:SetActive(false)

    self.button:GetComponent(Button).onClick:AddListener(function() self:ClickPanelNext() end)
    self.name.text = ""
end

function GetGodPet:ClickPanelNext()
    if self.timeid3 ~= nil then
        LuaTimer.Delete(self.timeid3)
        self.timeid3 = nil
    end
    if self.clickNext then
        self:Next()
    end
end

function GetGodPet:OnInitCompleted()
    self.typeid = self.openArgs.typeid
    self.goodId = self.openArgs.goodid
    self:SetData()
end

function GetGodPet:SetData()
    DramaManager.Instance.model:ShowJump(false)
    self:Next()
end

function GetGodPet:Next()
    self.clickNext = false
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if BaseUtils.isnull(self.gameObject) then
        return
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
        --self.effect3:SetActive(false)
    end
    if self.effect4 ~= nil then
        self.effect4:SetActive(false)
    end
    if self.effect5 ~= nil then
        self.effect5:SetActive(false)
    end
    self.step = self.step + 1
    if self.typeid == 2 then        --进化
        if self.step == 1 then
          self:ShowEgg1()
        elseif self.step == 2 then
          self:BoomEgg1()
        elseif self.step == 3 then
          self:ShowPreview()
          self:ShowHaloLight()
          self:ShowTitle()
          self:PutNewImg()
        elseif self.step == 4 then
          PetManager.Instance:Send10571()
          self:ShowButton()
          self:BeginTime()
        else
          self:Destroy()
        end
    elseif self.typeid == 3 then   --孵化
        if self.step == 1 then
          self:ShowEgg2()
        elseif self.step == 2 then
          self:BoomEgg2()
        else
          self:Destroy()
        end
    elseif self.typeid == 1 then   --领取
        if self.step == 1 then
          self:ShowPreview()
          self:ShowHaloLight()
          self:ShowTitle()
          self:PutNewImg()
        elseif self.step == 2 then
          self:ShowButton()
          self:BeginTime()
        else
          self:Destroy()
        end
    end
end

function GetGodPet:ShowEgg1()
    local good = DataPet.data_pet[20013]

    self.isEgg = true
    local modelData = {type = PreViewType.Npc, skinId = good.skin_id_0, modelId = good.model_id, animationId = good.animation_id, scale = 0.8, isGetEgg = true}
    self:LoadPreview(modelData)
    self.effect5:SetActive(true)
    self.clickNext = true
    self.rawImg:GetComponent(RectTransform).localPosition =Vector3(0,0,-400)
    self.timeId = LuaTimer.Add(3000, function() self:Next() end)
end

function GetGodPet:BoomEgg1()
    --self.rawImg:SetActive(false) ---最开始的模型
    self.effect5:SetActive(false)    --点击进化  四个字
    --LuaTimer.Add(0, function() self.effect3:SetActive(true) end)
    self.effect3:SetActive(true)      --中间绽放的特效
    SoundManager.Instance:Play(231)
    self.timeId = LuaTimer.Add(1000, function() self:Next() end)
end




function GetGodPet:ShowEgg2()
     local good = DataPet.data_pet[20014]

    self.isEgg = true
    local modelData = {type = PreViewType.Npc, skinId = good.skin_id_0, modelId = good.model_id, animationId = good.animation_id, scale = 0.8, isGetEgg = true}
    self:LoadPreview(modelData)
    self.effect2:SetActive(true)
    --LuaTimer.Add(1000, function() PetManager:Send10570() end)
    self.clickNext = true
    self.timeId = LuaTimer.Add(3000, function() self:Next() end)
end

function GetGodPet:BoomEgg2()
    self.rawImg:SetActive(false)
    self.effect2:SetActive(false)
    self.effect4:SetActive(true)
    SoundManager.Instance:Play(231)
    self.timeid10 = LuaTimer.Add(1500, function() PetManager.Instance:Send10570() end)
end

function GetGodPet:OnvalueReturn()
    if self.typeid == 3 then
        self:Next()
    end
end





function GetGodPet:ShowTitle()
    if self.typeid == 1 then
        self.title:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.geti18npandatitle, "GetI18NPandaTitle")
    elseif self.typeid == 2 then
        self.title:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.geti18nevolvetitle, "GetI18NEvolveTitle")
    end
    self.title:GetComponent(RectTransform).localPosition = Vector3(0,163,0)
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
end

function GetGodPet:ShowHaloLight()
    self.halo:SetActive(true)
    self.light:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function GetGodPet:ShowPreview()

    local good = DataPet.data_pet[self.goodId]
    if self.goodId == 20013 then
       self.rawImg:GetComponent(RectTransform).localPosition = Vector3(0,-8,-400)
       self.name.text = string.format("<color='#ffff00'>%s</color>\n<color='#7fff00'>升级至30级后开启有惊喜哟~</color>",good.name)
       self.meshId = good.model_id
       local modelData = {type = PreViewType.Npc, skinId = good.skin_id_0, modelId = good.model_id, animationId = good.animation_id, scale = 0.8, isGetEgg = true}
       self:LoadPreview(modelData)
    else
       self.rawImg:GetComponent(RectTransform).localPosition = Vector3(0,-20,-400)
       self.name.text = good.name
       self.meshId = good.model_id
       local modelData = {type = PreViewType.Npc, skinId = good.skin_id_0, modelId = good.model_id, animationId = good.animation_id, scale = 0.8, isGetEgg = true}
       self:LoadPreview(modelData)
    end

    -- if self.genre == 1 then
    --     modelData.skinId = pet.skin_id_s0
    --     modelData.effects = pet.effects_s0
    -- end

end

function GetGodPet:PutNewImg()
    -- if self.typeid == 1 then
    --    self.newImg:SetActive(true)
    -- end
    self.newImg:SetActive(false)
    self.timeId = LuaTimer.Add(10, function() self:Next() end)
end

function GetGodPet:ShowButton()
    self.timeId = LuaTimer.Add(500, function() self:PlayAction() end)
    self.button.transform.localScale = Vector3.one
    self.button.transform:Find("Text"):GetComponent(Text).text =TI18N("确定")
    self.button:SetActive(true)
    Tween.Instance:Scale(self.button, Vector3.one, 1, function() self:BeginCountDown() end, LeanTweenType.easeOutElastic)
end

function GetGodPet:Rotate()
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self.light.transform:Rotate(Vector3(0, 0, 0.5))
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function GetGodPet:Destroy()

    if self.countDownId ~= nil then
        LuaTimer.Delete(self.countDownId)
        self.countDownId = nil
    end

    if self.callback ~= nil then
        self.callback()
    end
end

function GetGodPet:PlayAction()
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    if not self.actionover then
        return
    end
    self.actionover = false
    if typeid == 1 then
        self.animator:Play(self.actions[2])
    else
        self.animator:Play(self.actions[math.random(1,3)])
    end
    --self.animator:Play(self.actions[math.random(1,3)])
    self.timeId = LuaTimer.Add(20, function () self:ActionDelay() end)
end

function GetGodPet:ActionDelay()
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    if delay ~= 0 then
        self.timeId = LuaTimer.Add(delay * 1000, function() self:ActionEnd() end)
    else
        self.actionover = true
    end
end

function GetGodPet:ActionEnd()
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    if self.animator ~= nil then
        self.animator:Play("Move1")
    end
    self.actionover = true
end

function GetGodPet:LoadPreview(modelData)
    --self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function GetGodPet:SetRawImage(composite)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self:SetPosition()
    self.previewComp.tpose.transform:Rotate(Vector3(0, -30, 0))

    if self.typeid == 1 then
        self.rawImg:GetComponent(RectTransform).localPosition = Vector3(0,-8,-400)
    elseif self.typeid == 2 then
        self.rawImg:GetComponent(RectTransform).localPosition = Vector3(0,-20,-400)
    elseif self.typeid == 3 then
        self.rawImg:GetComponent(RectTransform).localPosition = Vector3(0,-20,-400)
    end
    self.rawImg:SetActive(true)
    self.animator = composite.tpose:GetComponent(Animator)
    self.rawImg:GetComponent(Button).onClick:AddListener(function() self:ClickPanelNext() end)
end

--根据模型包围盒计算中心点
function GetGodPet:SetPosition()
    if self.goodId == 20001 then
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

function GetGodPet:OnJump()
end

function GetGodPet:BeginCountDown()
    self.clickNext = true
    --self.effect:SetActive(true)
    self.timeId = LuaTimer.Add(15000, function() self:Next() end)
end

function GetGodPet:BeginTime()
    self.clickNext = true
    self.countDown:SetActive(true)
    self.countDownT.text = TI18N("--<color='#00ff00'>15秒</color>后自动关闭--")
    self:EndTime()
    self.timeid3 = LuaTimer.Add(0, 1000, function() self:LoopTime() end)
end

function GetGodPet:LoopTime()
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    self.time = self.time - 1
    if self.time == 0 then
        self:EndTime()
        self:Next()
        return
    end
    self.countDownT.text = string.format(TI18N("--<color='#00ff00'>%s秒</color>后自动关闭--"), self.time)
end

function GetGodPet:EndTime()
    if self.timeid3 ~= nil then
        LuaTimer.Delete(self.timeid3)
        self.timeid3 = nil
    end
end
