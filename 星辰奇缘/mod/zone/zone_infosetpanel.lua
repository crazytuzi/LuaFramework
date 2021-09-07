InfoSetPanel = InfoSetPanel or BaseClass(BasePanel)

function InfoSetPanel:__init(parent)
    self.parent = parent
    self.model = parent.model
    self.resList = {
        {file = AssetConfig.zoneinfosetpanel, type = AssetType.Main}
    }
    self.selectxingzuo = nil
    self.selectblood = nil
end

function InfoSetPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.zoneinfosetpanel))
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.XingzuoScroll = self.transform:Find("XingzuoScroll")
    self.BloodScroll = self.transform:Find("BloodScroll")
    self.XingzuoButton = self.transform:Find("XingzuoButton")
    self.BloodButton = self.transform:Find("BloodButton")
    self.transform:Find("XingzuoButton"):GetComponent(Button).onClick:AddListener(function() self.XingzuoScroll.gameObject:SetActive(true) end)
    self.transform:Find("BloodButton"):GetComponent(Button).onClick:AddListener(function() self.BloodScroll.gameObject:SetActive(true) end)
    self.transform:Find("bg1"):GetComponent(Button).onClick:AddListener(function() self.XingzuoScroll.gameObject:SetActive(false) self.BloodScroll.gameObject:SetActive(false) end)
    self.transform:Find("Bg"):GetComponent(Button).onClick:AddListener(function() self.XingzuoScroll.gameObject:SetActive(false) self.BloodScroll.gameObject:SetActive(false) end)
    self.transform:Find("OKButton"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self:InitScrollList()
    self.XingzuoButton:Find("Text"):GetComponent(Text).text = Constellation[self.parent.myzoneData.constellation].name
    self.BloodButton:Find("Text"):GetComponent(Text).text = BloodSetting[self.parent.myzoneData.abo]
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end


function InfoSetPanel:OnShow()
    self.XingzuoButton:Find("Text"):GetComponent(Text).text = Constellation[self.parent.myzoneData.constellation].name
    self.BloodButton:Find("Text"):GetComponent(Text).text = BloodSetting[self.parent.myzoneData.abo]

end

function InfoSetPanel:OnHide()
    if self.selectxingzuo ~= nil or self.selectblood ~= nil then
        self.parent.zoneMgr:Require11833(TI18N("1992年12月12日"), self.selectxingzuo or self.parent.myzoneData.constellation, self.selectblood or self.parent.myzoneData.abo, self.parent.myzoneData.signature, self.parent.myzoneData.region, self.parent.myzoneData.sex)
    end
end

function InfoSetPanel:InitScrollList()
    for i = 1,12 do
        local item = self.XingzuoScroll:Find(string.format("Mask/XingzuoList/%s", tostring(i)))
        item:GetComponent(Button).onClick:AddListener(function()
            self.XingzuoButton:Find("Text"):GetComponent(Text).text = Constellation[i].name
            self.selectxingzuo = i
            self.XingzuoScroll.gameObject:SetActive(false)
            end)
    end

    for i = 1, 4 do
        local item = self.BloodScroll:Find(string.format("Mask/BloodList/%s", tostring(i)))
        item:GetComponent(Button).onClick:AddListener(function()
            self.BloodButton:Find("Text"):GetComponent(Text).text = BloodSetting[i]
            self.selectblood = i
            self.BloodScroll.gameObject:SetActive(false)
            end)
    end
end