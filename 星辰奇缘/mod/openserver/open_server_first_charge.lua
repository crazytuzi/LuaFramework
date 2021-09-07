OpenServerFirstCharge = OpenServerFirstCharge or BaseClass(BasePanel)

function OpenServerFirstCharge:__init(model, parent, data)
    self.model = model
    self.parent = parent
    self.data = data

    self.mgr = OpenServerManager.Instance

    self.resList = {
        {file = AssetConfig.open_server_first, type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateLuckyListener = function() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function OpenServerFirstCharge:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerFirstCharge:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_first))
    self.gameObject.name = "OpenServerFirstCharge"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.titleText = t:Find("Title/Text"):GetComponent(Text)
    self.resText = t:Find("CTBgImage/Text"):GetComponent(Text)
    self.descText = t:Find("DescText"):GetComponent(Text)
    self.button = t:Find("Button_text"):GetComponent(Button)
    self.rechargedTextObj = t:Find("RechargedText").gameObject

    self.titleText.text = self.data.name
    self.resText.text = TI18N("充值额外获得40%")
    self.descText.text = self.data.cond_desc

    self.button.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
    end)

    self.OnOpenEvent:Fire()
end

function OpenServerFirstCharge:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateLucky:AddListener(self.updateLuckyListener)

    local bool = FirstRechargeManager.Instance:isHadDoFirstRecharge()
    self.button.gameObject:SetActive(not bool)
    self.rechargedTextObj:SetActive(bool)
end

function OpenServerFirstCharge:RemoveListeners()
    self.mgr.onUpdateLucky:RemoveListener(self.updateLuckyListener)
end

function OpenServerFirstCharge:OnHide()
    self:RemoveListeners()
end

