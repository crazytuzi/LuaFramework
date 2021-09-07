-- -------------------
-- 获得新形象
-- ljh 20161223
-- -------------------
GetRoleView = GetRoleView or BaseClass(BaseDramaPanel)

function GetRoleView:__init()
    self.effectPath = "prefabs/effect/20014.unity3d"
    self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.getrole, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.texture, type = AssetType.Dep},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
        {file = AssetConfig.haloi18ntext, type = AssetType.Dep},
    }

    self.actionover = true
    self.previewLoaded = false
    self.previewShowed = false
    self.click = function() self:Destroy() end
    self.playaction = function() self:PlayAction() end

    self.actions = {"Move1", "Move1", "Move1"}
    self.step = 0

    self.petId = nil
    self.callback = nil

    self.timeId = 0
    self.rotateId = 0

    self.setting = {
        name = "GetRoleViewPreview"
        ,orthographicSize = 1
        ,width = 682
        ,height = 600
        ,offsetY = -0.35
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil
end

function GetRoleView:__delete()
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
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function GetRoleView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.getrole))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)

    self.transform:Find("Main/Title"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.haloi18ntext, "HaloI18NText")

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, -177, -400)
    self.effect:SetActive(false)

    self.title = self.transform:Find("Main/Title").gameObject
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.light = self.transform:Find("Main/Light").gameObject
    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.rawImg = self.transform:Find("Main/RawImage").gameObject
    self.button = self.transform:Find("Main/Button").gameObject
    self.newImg = self.transform:Find("Main/New").gameObject
    self.rawImg:SetActive(false)
    self.newImg:SetActive(false)
    self.button:SetActive(false)
    self.halo:SetActive(false)
    self.light:SetActive(false)
    self.title:SetActive(false)

    self.halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")

    self.button:GetComponent(Button).onClick:AddListener(self.click)
    self.name.text = ""
end

function GetRoleView:OnInitCompleted()
    self.effectId = self.openArgs
    self:SetData()
end

function GetRoleView:SetData()
    DramaManager.Instance.model:ShowJump(false)
    self:Next()
end

function GetRoleView:Next()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.step = self.step + 1
    if self.step == 1 then
        self:ShowTitle()
    elseif self.step == 2 then
        self:ShowHaloLight()
        self:ShowPreview()
        self:PutNewImg()
    elseif self.step == 3 then
        self:ShowButton()
    end
end

function GetRoleView:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function GetRoleView:ShowHaloLight()
    self.halo:SetActive(true)
    self.light:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function GetRoleView:ShowPreview()
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks, showHalo = true}

    local llooks = {}
    local hasHale = false
    for i,v in ipairs(modelData.looks) do
        if v.looks_type == SceneConstData.lookstype_halo then
            hasHale = true
            table.insert(llooks, {looks_val = self.effectId, looks_str = "", looks_mode = 0, looks_type = SceneConstData.lookstype_halo})
        else
            table.insert(llooks, v)
        end
    end
    if not hasHale then
        table.insert(llooks, {looks_val = self.effectId, looks_str = "", looks_mode = 0, looks_type = SceneConstData.lookstype_halo})
    end
    modelData.looks = llooks

    self:LoadPreview(modelData)
end

function GetRoleView:PutNewImg()
    self.newImg:SetActive(true)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function GetRoleView:ShowButton()
    -- self.timeId = LuaTimer.Add(500, function() self:PlayAction() end)
    self.button.transform.localScale = Vector3.one * 3
    self.button:SetActive(true)
    Tween.Instance:Scale(self.button, Vector3.one, 1, function() self:BeginCountDown() end, LeanTweenType.easeOutElastic)
end

function GetRoleView:Rotate()
    self.light.transform:Rotate(Vector3(0, 0, 0.5))
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function GetRoleView:Destroy()
    if self.countDownId ~= nil then
        LuaTimer.Delete(self.countDownId)
        self.countDownId = nil
    end
    if self.callback ~= nil then
        self.callback()
    end
    EquipStrengthManager.Instance.model:CloseGetRoleHalo()
end

function GetRoleView:PlayAction()
    if not self.actionover then
        return
    end
    self.actionover = false
    self.animator:Play(self.actions[math.random(1,3)])
    self.timeId = LuaTimer.Add(20, function () self:ActionDelay() end)
end

function GetRoleView:ActionDelay()
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    if delay ~= 0 then
        self.timeId = LuaTimer.Add(delay * 1000, function() self:ActionEnd() end)
    else
        self.actionover = true
    end
end

function GetRoleView:ActionEnd()
    if self.animator ~= nil then
        self.animator:Play("Move1")
    end
    self.actionover = true
end

function GetRoleView:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function GetRoleView:SetRawImage(composite)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self:SetPosition()
    self.previewComp.tpose.transform:Rotate(Vector3(-15, 0, 0))
    self.rawImg:SetActive(true)
    self.animator = composite.tpose:GetComponent(Animator)
    -- self.rawImg:GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
    -- self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
end

--根据模型包围盒计算中心点
function GetRoleView:SetPosition()
    self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, -0.35, 0)
end

function GetRoleView:OnJump()
end

function GetRoleView:BeginCountDown()
    self.effect:SetActive(true)
    self.countDownId = LuaTimer.Add(3000, function() self:Destroy() end)
end