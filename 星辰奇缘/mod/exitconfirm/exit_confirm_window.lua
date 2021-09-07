ExitConfirmWindow = ExitConfirmWindow or BaseClass(BaseWindow)

function ExitConfirmWindow:__init(model)
    self.model = model
    self.gameObject = nil
    self.name = "ExitConfirmWindow"

    self.resList = {
        {file = AssetConfig.exit_confirm_window, type = AssetType.Main}
    }

    self.sumbitBut = nil
    self.cancelBut = nil
end

function ExitConfirmWindow:__delete()
end

function ExitConfirmWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exit_confirm_window))
    self.gameObject.name = "ExitConfirmWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.sumbitBut = self.gameObject.transform:FindChild("Window/Submit").gameObject
    self.cancelBut = self.gameObject.transform:FindChild("Window/Cancel").gameObject

    self.sumbitBut:GetComponent(Button).onClick:AddListener(function() self:OnSumbitButClick() end)
    self.cancelBut:GetComponent(Button).onClick:AddListener(function() self:OnCancelButClick() end)
end

function ExitConfirmWindow:OnSumbitButClick()
    Application.Quit()
end

function ExitConfirmWindow:OnCancelButClick()
    self.model:CloseWindow()
end
