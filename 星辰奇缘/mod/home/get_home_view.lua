-- -------------------
-- 获得家园
-- ljh 160715
-- -------------------
GetHomeView = GetHomeView or BaseClass(BaseDramaPanel)

function GetHomeView:__init()
    self.effectPath = "prefabs/effect/20014.unity3d"
    self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.gethome, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.texture, type = AssetType.Dep},
        {file = AssetConfig.ride_texture, type = AssetType.Dep},
        {file = AssetConfig.homeTexture, type = AssetType.Dep},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
    }

    self.actionover = true
    self.meshId = 0
    self.previewLoaded = false
    self.previewShowed = false
    self.listener = function(texture, modleList) self:OnTposeLoad(texture, modleList) end
    self.click = function() self:Destroy() end
    self.clickClose = function() self:Close() end
    self.playaction = function() self:PlayAction() end

    self.step = 0

    self.callback = nil

    self.timeId = 0
    self.rotateId = 0
end

function GetHomeView:__delete()
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function GetHomeView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.gethome))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, -177, -400)
    self.effect:SetActive(false)

    self.title = self.transform:Find("Main/Title").gameObject
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.light = self.transform:Find("Main/Light").gameObject
    self.button = self.transform:Find("Main/Button").gameObject
    self.newImg = self.transform:Find("Main/New").gameObject
    self.modelImg = self.transform:Find("Main/ModelImage").gameObject
    self.newImg:SetActive(false)
    self.button:SetActive(false)
    self.halo:SetActive(false)
    self.light:SetActive(false)
    self.title:SetActive(false)
    self.modelImg:SetActive(false)

    self.halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")

    self.button:GetComponent(Button).onClick:AddListener(self.click)
end

function GetHomeView:OnInitCompleted()
    self:SetData()
end

function GetHomeView:SetData()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        local lev = self.openArgs[1]
        local home_data = DataFamily.data_home_data[lev]
        if lev > 1 and home_data ~= nil then
            self.transform:Find("Main/Button/Text"):GetComponent(Text).text = TI18N("确定")
            self.transform:Find("Main/New/Text"):GetComponent(Text).text = home_data.name2
            self.transform:Find("Main/Title"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, "I18NUpgradeHomeTitle")
            self.transform:Find("Main/ModelImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, string.format("home%s", lev))
        end
    end
    self:Next()
end

function GetHomeView:Next()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.step = self.step + 1
    if self.step == 1 then
        self:ShowTitle()
    elseif self.step == 2 then
        self:ShowHaloLight()
        self:ShowModelImage()
        self:PutNewImg()
    elseif self.step == 3 then
        self:ShowButton()
    end
end

function GetHomeView:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function GetHomeView:ShowHaloLight()
    self.halo:SetActive(true)
    self.light:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function GetHomeView:ShowModelImage()
    self.modelImg.transform.localScale = Vector3.one * 0.2
    self.modelImg:SetActive(true)
    Tween.Instance:Scale(self.modelImg, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)

    SoundManager.Instance:Play(230)
end

function GetHomeView:PutNewImg()
    self.newImg:SetActive(true)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function GetHomeView:ShowButton()
    self.button.transform.localScale = Vector3.one * 3
    self.button:SetActive(true)
    Tween.Instance:Scale(self.button, Vector3.one, 1, function() self:BeginCountDown() end, LeanTweenType.easeOutElastic)
end

function GetHomeView:Rotate()
    self.light.transform:Rotate(Vector3(0, 0, 0.5))
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function GetHomeView:Close()
    HomeManager.Instance.model:CloseGetHomeWindow()
end

function GetHomeView:Destroy()
    if self.countDownId ~= nil then
        LuaTimer.Delete(self.countDownId)
        self.countDownId = nil
    end
    if self.callback ~= nil then
        self.callback()
    end
end

function GetHomeView:BeginCountDown()
    self.effect:SetActive(true)
    -- self.countDownId = LuaTimer.Add(3000, function() self:Destroy() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(self.clickClose)
end