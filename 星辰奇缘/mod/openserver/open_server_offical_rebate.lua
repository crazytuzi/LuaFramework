OpenServerOfficalRebate = OpenServerOfficalRebate or BaseClass(BasePanel)

function OpenServerOfficalRebate:__init(model, parent, data)
    self.model = model
    self.parent = parent
    self.data = data

    self.resList = {
        {file = AssetConfig.open_server_offical, type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function OpenServerOfficalRebate:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerOfficalRebate:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_offical))
    self.gameObject.name = "OpenServerOfficalRebate"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.descText = t:Find("Desc"):GetComponent(Text)
    self.button = t:Find("Button"):GetComponent(Button)

    self.descText.text = self.data.cond_desc

    self.button.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
    end)

    self.OnOpenEvent:Fire()
end

function OpenServerOfficalRebate:OnOpen()
end

function OpenServerOfficalRebate:OnHide()
end
