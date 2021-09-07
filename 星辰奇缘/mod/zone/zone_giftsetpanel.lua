GiftSetPanel = GiftSetPanel or BaseClass(BasePanel)

function GiftSetPanel:__init(parent)
    self.parent = parent
    self.model = parent.model
    self.resList = {
        {file = AssetConfig.zonegiftsetpanel, type = AssetType.Main}
    }
    self.timer = nil
    self.num = 10

end

function GiftSetPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.zonegiftsetpanel))
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.addbtn = self.transform:Find("AddButton"):GetComponent(CustomButton)
    self.desbtn = self.transform:Find("DesButton"):GetComponent(CustomButton)
    self.okbtn = self.transform:Find("OkButton"):GetComponent(Button)
    self.giftraretxt = self.transform:Find("GiftRareText"):GetComponent(Text)
    self.giftnumtxt = self.transform:Find("GiftnumText"):GetComponent(Text)
    self.hasText = self.transform:Find("HasText"):GetComponent(Text)
    self.closebtn = self.transform:Find("CloseButton"):GetComponent(Button)

    self.addbtn.onClick:AddListener(function() self:AddOne() end)
    self.desbtn.onClick:AddListener(function() self:DesOne() end)
    self.addbtn.onHold:AddListener(function() self:StarHold(true) end)
    self.desbtn.onHold:AddListener(function() self:StarHold(false) end)
    self.addbtn.onUp:AddListener(function() self:EndHold() end)
    self.desbtn.onUp:AddListener(function() self:EndHold() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.okbtn.onClick:AddListener(function() self:OnOkButton() end)
    self.closebtn.onClick:AddListener(function() self:Hiden() end)
    self:UpdateRare()
end

function GiftSetPanel:OnShow()
    -- self.num = 1
    self:UpdateRare()
end

function GiftSetPanel:OnHide()
end

function GiftSetPanel:AddOne()
    if self.num < 100 then
        self.num = self.num + 1 self:UpdateRare()
    end
end

function GiftSetPanel:DesOne()
    if self.num > 0 then
        self.num = self.num - 1
        self:UpdateRare()
    end
end



function GiftSetPanel:StarHold(up)
    if up then
        self.timer = LuaTimer.Add(0, 150, function() self.num = self.num + 1 self:UpdateRare() end)
    else
        self.timer = LuaTimer.Add(0, 150, function() if self.num > 0 then self.num = self.num - 1 self:UpdateRare() end end)
    end
end

function GiftSetPanel:EndHold()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
end

function GiftSetPanel:UpdateRare()
    self.giftnumtxt.text = tostring(self.num)
    local need = 35000*self.num
    if need <= RoleManager.Instance.RoleData.coin then
        self.giftraretxt.text = tostring(need)
    else
        self.giftraretxt.text = string.format("<color='#ff0000'>%s</color>", tostring(need))
    end
    self.hasText.text = tostring(RoleManager.Instance.RoleData.coin)
end

function GiftSetPanel:OnOkButton()
    local need = 35000*self.num
    if need <= RoleManager.Instance.RoleData.coin then
        self:Hiden()
        ZoneManager.Instance:Require11837(self.num)
    else
        self.giftraretxt.text = string.format("<color='#ff0000'>%s</color>", tostring(need))
        NoticeManager.Instance:FloatTipsByString(TI18N("银币不足"))
    end
end