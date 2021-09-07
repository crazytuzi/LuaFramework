DemoWindow = DemoWindow or BaseClass(BaseWindow)

function DemoWindow:__init(model)
    self.model = model
    self.name = "DemoWindow"
    self.resList = {
        {file = AssetConfig.demo_mainui_window1, type = AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
    }

    self.name = "<Unknown View>"
    self.closeBut = nil
end

function DemoWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DemoWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo_mainui_window1))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DemoMainWinsow1"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.closeBut = self.gameObject.transform:FindChild("Window/CloseBut").gameObject
    self.closeBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseButtonClick() end)
    self.gameObject:SetActive(true)
end

function DemoWindow:OnCloseButtonClick()
    self.model:CloseWindow()
end
