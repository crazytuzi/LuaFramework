DemoPreviewWindow = DemoPreviewWindow or BaseClass(BaseWindow)

function DemoPreviewWindow:__init(model)
    self.model = model
    self.name = "DemoPreviewWindow"
    -- self.cacheMode = CacheMode.Visible
    self.holdTime = BaseUtils.DefaultHoldTime()
    self.resList = {
        {file = AssetConfig.demo_preview_window, type = AssetType.Main}
    }

    self.closeBut = nil
    self.view1 = nil
    self.view2 = nil

    self.previewComp1 = nil
    self.previewComp2 = nil
end

function DemoPreviewWindow:__delete()
    -- 记得这里销毁
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end

    if self.previewComp2 ~= nil then
        self.previewComp2:DeleteMe()
        self.previewComp2 = nil
    end
end

function DemoPreviewWindow:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.demo_preview_window))
    self.gameObject.name  =  "DemoPreviewWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.closeBut = self.gameObject.transform:FindChild("Window/Close").gameObject
    self.view1 = self.gameObject.transform:FindChild("Window/View1").gameObject
    self.view2 = self.gameObject.transform:FindChild("Window/View2").gameObject
    self.closeBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseButtonClick() end)

    self:BuildModel1()
    self:BuildModel2()
end

function DemoPreviewWindow:OnCloseButtonClick()
    self.model:ClosePreviewWindow()
end

function DemoPreviewWindow:BuildModel1()
    local previewComp = nil
    local callback = function(composite)
        self:BuildCompleted1(composite)
    end
    local setting = {
        name = "demo1"
        ,orthographicSize = 1
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Npc, skinId = 30000, modelId = 30000, animationId = 3000001, scale = 1}
    self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

    -- 有缓存的窗口要写这个
    self.OnHideEvent:AddListener(function() self.previewComp1:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComp1:Show() end)
end

function DemoPreviewWindow:BuildCompleted1(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.view1.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end

function DemoPreviewWindow:BuildModel2()
    local previewComp = nil
    local callback = function(composite)
        self:BuildCompleted2(composite)
    end
    local setting = {
        name = "demo2"
        ,orthographicSize = 1
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Npc, skinId = 30000, modelId = 30000, animationId = 3000001, scale = 1}
    self.previewComp2 = PreviewComposite.New(callback, setting, modelData)
    self.OnHideEvent:AddListener(function() self.previewComp2:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComp2:Show() end)
end

function DemoPreviewWindow:BuildCompleted2(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.view2.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end
