-- ----------------------------------------------------------
-- UI - 家园宠物训练窗口
-- ljh 20160712
-- ----------------------------------------------------------
HomePetTrainView = HomePetTrainView or BaseClass(BaseWindow)

function HomePetTrainView:__init(model)
    self.model = model
    self.name = "HomePetTrainView"
    self.windowId = WindowConfig.WinID.homepettrainview

    self.resList = {
        {file = AssetConfig.homepettrainwindow, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.previewComposite1 = nil
    self.previewComposite2 = nil
    self.previewComposite3 = nil
    ------------------------------------------------
    self.selectItem = nil
    self.selectType = 1
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HomePetTrainView:__delete()
    self:OnHide()

    if self.previewComposite1 ~= nil then
        self.previewComposite1:DeleteMe()
        self.previewComposite1 = nil
    end

    if self.previewComposite2 ~= nil then
        self.previewComposite2:DeleteMe()
        self.previewComposite2 = nil
    end

    if self.previewComposite3 ~= nil then
        self.previewComposite3:DeleteMe()
        self.previewComposite3 = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function HomePetTrainView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.homepettrainwindow))
    self.gameObject.name = "HomePetTrainView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.item1 = self.mainTransform:FindChild("Item1")
    self.item1:GetComponent(Button).onClick:AddListener(function() self:OnClickItem(self.item1, 1) end)
    self.item2 = self.mainTransform:FindChild("Item2")
    self.item2:GetComponent(Button).onClick:AddListener(function() self:OnClickItem(self.item2, 2) end)
    self.item3 = self.mainTransform:FindChild("Item3")
    self.item3:GetComponent(Button).onClick:AddListener(function() self:OnClickItem(self.item3, 3) end)

    self.preview1 = self.item1:FindChild("Preview")
    self.preview2 = self.item2:FindChild("Preview")
    self.preview3 = self.item3:FindChild("Preview")

    self.mainTransform:FindChild("OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickOkButton() end)
    ----------------------------

    self:OnShow()
end

function HomePetTrainView:OnClickClose()
    self:OnHide()
    WindowManager.Instance:CloseWindow(self)
end

function HomePetTrainView:OnShow()
	if self.openArgs ~= nil and #self.openArgs > 0 then
        self.petData = self.openArgs[1]
    end

    self:update()
end

function HomePetTrainView:OnHide()

end

function HomePetTrainView:update()
	local setting = {
        name = "HomePetTrainView"
        ,orthographicSize = 0.8
        ,width = 180
        ,height = 240
        ,offsetY = -0.55
    }

    local fun1 = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview1)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    local fun2 = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview2)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    local fun3 = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview3)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    local petModelData = PetManager.Instance.model:getPetModel(self.petData)
    local data = {type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = self.petData.base.animation_id, scale = self.petData.base.scale / 100, effects = petModelData.effects}

    self.previewComposite1 = PreviewComposite.New(fun1, setting, data)
    self.previewComposite2 = PreviewComposite.New(fun2, setting, data)
    self.previewComposite3 = PreviewComposite.New(fun3, setting, data)

    self.mainTransform:FindChild("Item1/TimeText"):GetComponent(Text).text = TI18N("训练1小时")
    self.mainTransform:FindChild("Item1/ExpText"):GetComponent(Text).text = "+1"

    self.mainTransform:FindChild("Item2/TimeText"):GetComponent(Text).text = TI18N("训练2小时")
    self.mainTransform:FindChild("Item2/ExpText"):GetComponent(Text).text = "+2"

    self.mainTransform:FindChild("Item3/TimeText"):GetComponent(Text).text = TI18N("训练3小时")
    self.mainTransform:FindChild("Item3/ExpText"):GetComponent(Text).text = "+3"

    self:OnClickItem(self.item1, 1)
end

function HomePetTrainView:OnClickItem(item, type)
	if self.selectItem ~= nil then
		self.selectItem:FindChild("Select").gameObject:SetActive(false)
	end
	self.selectItem = item
	self.selectItem:FindChild("Select").gameObject:SetActive(true)

	self.selectType = type
end

function HomePetTrainView:OnClickOkButton()
	print(self.selectType)
	self:OnClickClose()
end