BibleCDKeyPanel = BibleCDKeyPanel or BaseClass(BasePanel)

function BibleCDKeyPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.bible_cdkey_panel, type = AssetType.Main},
        {file = AssetConfig.GameBgOne,type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
    self.bigObj = nil
end

function BibleCDKeyPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BibleCDKeyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_cdkey_panel))
    self.gameObject.name = "CDKeyPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    local panel = self.transform


    self.InputFieldDesc = panel:Find("InputField/Placeholder"):GetComponent(Text)
    self.InputFieldDesc.text = TI18N("输入激活码...")
    self.InputFieldCDKey = panel:Find("InputField"):GetComponent(InputField)
    self.btnCDKey = panel:Find("Button"):GetComponent(Button)
    self.btnCDKey.onClick:AddListener(function()
        self:GetRewardByCDKey()
    end)
    self:OnOpen()
end

function BibleCDKeyPanel:UpdateCDKEY()
     if self:RefreshIndulge() == true and self.bigObj == nil then
        self.bigBg = self.transform:Find("Bg")
        self.bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.GameBgOne))
        UIUtils.AddBigbg(self.bigBg,self.bigObj)
    end
    self.InputFieldCDKey.text = ""
end

function BibleCDKeyPanel:OnOpen()
    self:UpdateCDKEY()
end

function BibleCDKeyPanel:OnHide()
    self:RemoveListener()
end

function BibleCDKeyPanel:RemoveListener()
end

function BibleCDKeyPanel:CheckRedPoint()
end

function BibleCDKeyPanel:GetRewardByCDKey()
    if self.InputFieldCDKey.text ~= "" then
        BibleManager.Instance:send9906(self.InputFieldCDKey.text)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请先输入CD Key,再点领取"))
    end
end

function BibleCDKeyPanel:RefreshIndulge()
    local indulgeData = ((RoleManager.Instance.indulgeData or {})[RoleManager.Instance.RoleData.platform] or {})[ctx.PlatformChanleId] or {}
    -- local indulgeData = (RoleManager.Instance.indulgeData or {})[ctx.PlatformChanleId] or {}

    if indulgeData.is_show_phone == 1 then
        return true
    else
        return false
    end
end