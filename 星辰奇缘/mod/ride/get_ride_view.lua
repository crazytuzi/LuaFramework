-- -------------------
-- 获得坐骑
-- ljh 20160817
-- -------------------
GetRideView = GetRideView or BaseClass(BaseDramaPanel)

function GetRideView:__init()
    self.effectPath = "prefabs/effect/20014.unity3d"
    self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.getride, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.texture, type = AssetType.Dep},
        {file = AssetConfig.ride_texture, type = AssetType.Dep},
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
    self.playaction = function() self:PlayAction() end

    self.actions = {"Move1", "Move1", "Move1"}
    self.step = 0

    self.petId = nil
    self.callback = nil

    self.timeId = 0
    self.rotateId = 0

    self.setting = {
        name = "GetRideViewPreview"
        ,orthographicSize = 0.75
        ,width = 682
        ,height = 600
        ,offsetY = -0.4
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil
end

function GetRideView:__delete()
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

function GetRideView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.getride))
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

function GetRideView:OnInitCompleted()
    print(self.openArgs.val)
    self.rideId = self.openArgs.val
    self.callback = self.openArgs.callback
    self:SetData()
end

function GetRideView:SetData()
    DramaManager.Instance.model:ShowJump(false)
    self:Next()
end

function GetRideView:Next()
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

function GetRideView:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function GetRideView:ShowHaloLight()
    self.halo:SetActive(true)
    self.light:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function GetRideView:ShowPreview()
    local ride_look = self.rideId
print(self.rideId)
    local ride = DataMount.data_ride_data[self.rideId]
    self.name.text = ride.name
    self.meshId = ride.model_id

    local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 0.7, effects = {}}
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = ride_look })
    self:LoadPreview(data)
end

function GetRideView:PutNewImg()
    self.newImg:SetActive(true)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function GetRideView:ShowButton()
    self.timeId = LuaTimer.Add(500, function() self:PlayAction() end)
    self.button.transform.localScale = Vector3.one * 3
    self.button:SetActive(true)
    Tween.Instance:Scale(self.button, Vector3.one, 1, function() self:BeginCountDown() end, LeanTweenType.easeOutElastic)
end

function GetRideView:Rotate()
    self.light.transform:Rotate(Vector3(0, 0, 0.5))
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function GetRideView:Destroy()
    if self.countDownId ~= nil then
        LuaTimer.Delete(self.countDownId)
        self.countDownId = nil
    end
    if self.callback ~= nil then
        self.callback()
    end
    RideManager.Instance.model:CloseGetRideWindow()
end

function GetRideView:PlayAction()
    if not self.actionover then
        return
    end
    self.actionover = false
    self.animator:Play(self.actions[math.random(1,3)])
    self.timeId = LuaTimer.Add(20, function () self:ActionDelay() end)
end

function GetRideView:ActionDelay()
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    if delay ~= 0 then
        self.timeId = LuaTimer.Add(delay * 1000, function() self:ActionEnd() end)
    else
        self.actionover = true
    end
end

function GetRideView:ActionEnd()
    if self.animator ~= nil then
        self.animator:Play("Move1")
    end
    self.actionover = true
end

function GetRideView:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function GetRideView:SetRawImage(composite)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self:SetPosition()
    self.previewComp.tpose.transform:Rotate(Vector3(0, -30, 0))
    self.rawImg:SetActive(true)
    self.animator = composite.tpose:GetComponent(Animator)
    self.rawImg:GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
end

--根据模型包围盒计算中心点
function GetRideView:SetPosition()
    -- if self.rideId == 20001 then
    --     self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, -0.4, 0)
    -- else
        -- local mesh = self.previewComp.tpose.transform:Find(string.format("Mesh_%s", self.meshId)):GetComponent(SkinnedMeshRenderer)
        -- local miny = mesh.bounds.min.y
        -- local maxy = mesh.bounds.max.y
        -- local y = (miny - maxy) / 2 + 0.05
        -- self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, y, 0)
    -- end
    self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, -0.25, 0)
end

function GetRideView:OnJump()
end

function GetRideView:BeginCountDown()
    self.effect:SetActive(true)
    self.countDownId = LuaTimer.Add(3000, function() self:Destroy() end)
end