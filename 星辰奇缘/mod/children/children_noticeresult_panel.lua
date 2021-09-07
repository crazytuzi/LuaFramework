--作者:hzf
--17-1-10 下02时45分00秒
--功能:子女功能消息结果确认框

ChildrenNoticeResultPanel = ChildrenNoticeResultPanel or BaseClass(BasePanel)
function ChildrenNoticeResultPanel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.childrennoticeresultpanel, type = AssetType.Main},
        {file = AssetConfig.childrentextures, type = AssetType.Dep}
    }
    --self.OnOpenEvent:Add(function() self:OnOpen() end)
    --self.OnHideEvent:Add(function() self:OnHide() end)
    self.hasInit = false
end

function ChildrenNoticeResultPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChildrenNoticeResultPanel:OnHide()

end

function ChildrenNoticeResultPanel:OnOpen()

end

function ChildrenNoticeResultPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrennoticeresultpanel))
    self.gameObject.name = "ChildrenNoticeResultPanel"
    self.data = self.openArgs
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.PanelBtn = self.transform:Find("Panel"):GetComponent(Button)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        ChildrenManager.Instance.model:CloseNoticeResultPanel()
    end)
    self.PanelBtn.enabled = false
    self.Tips = self.transform:Find("Tips")
    self.bg = self.transform:Find("Tips/bg")
    self.TitleText = self.transform:Find("Tips/Title/Text"):GetComponent(Text)
    self.descText = self.transform:Find("Tips/descText"):GetComponent(Text)
    self.LButton = self.transform:Find("Tips/LButton"):GetComponent(Button)
    self.LButtonText = self.transform:Find("Tips/LButton/Text"):GetComponent(Text)
    self.Icon = self.transform:Find("Tips/LButton/Icon"):GetComponent(Image)
    self.numbg = self.transform:Find("Tips/LButton/numbg")
    self.numbg.gameObject:SetActive(false)
    self.needtext = self.transform:Find("Tips/LButton/numbg/Text"):GetComponent(Text)
    self.LdescText = self.transform:Find("Tips/LdescText"):GetComponent(Text)
    self.Ext = MsgItemExt.New(self.LdescText, 242, 18, 19)
    self.OKButton = self.transform:Find("Tips/OKButton"):GetComponent(Button)
    self.OKButton.onClick:AddListener(function()
        self:OnOk()
    end)
    self.OKButtonText = self.transform:Find("Tips/OKButton/Text"):GetComponent(Text)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        ChildrenManager.Instance.model:CloseNoticeResultPanel()
    end)

    self:SetData(self.data)
end

function ChildrenNoticeResultPanel:SetData(data)
    BaseUtils.dump(data, " s数据  阿斯顿撒旦撒大")
    if data.mode ~= nil then
        if self.data.mode == 1 and self.data.flag == 1 then
            self.TitleText.text = TI18N("灵树开花")
            self.LButtonText.text = TI18N("天地灵种")
            self.OKButtonText.text = TI18N("查看胎儿")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target2")
        elseif self.data.mode == 1 and self.data.flag == 0 then
            self.TitleText.text = TI18N("暂未开花")
            self.LButtonText.text = TI18N("天地灵种")
            self.OKButtonText.text = TI18N("好的")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target2")
        elseif self.data.mode == 1 and self.data.flag == 2 then
            self.TitleText.text = TI18N("天地灵种")
            self.LButtonText.text = TI18N("天地灵种")
            self.OKButtonText.text = TI18N("好的")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target2")
        elseif self.data.mode == 1 and self.data.flag == 3 then
            self.TitleText.text = TI18N("孕育任务")
            self.LButtonText.text = TI18N("孕育任务")
            self.OKButtonText.text = TI18N("好的")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target3")
        elseif self.data.mode == 2 and self.data.flag == 1 then
            self.TitleText.text = TI18N("有喜啦")
            self.LButtonText.text = TI18N("浓情蜜意")
            self.OKButtonText.text = TI18N("查看胎儿")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target3")
        elseif self.data.mode == 2 and self.data.flag == 0 then
            self.TitleText.text = TI18N("暂未怀孕")
            self.LButtonText.text = TI18N("浓情蜜意")
            self.OKButtonText.text = TI18N("好的")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target3")
        elseif self.data.mode == 2 and self.data.flag == 2 then
            self.TitleText.text = TI18N("浓情蜜意")
            self.LButtonText.text = TI18N("浓情蜜意")
            self.OKButtonText.text = TI18N("好的")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target3")
        elseif self.data.mode == 2 and self.data.flag == 3 then
            self.TitleText.text = TI18N("孕育任务")
            self.LButtonText.text = TI18N("孕育任务")
            self.OKButtonText.text = TI18N("好的")
            self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, "target3")
        end
        self.Ext:SetData(self.data.msg)
    else
        self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, data.icon)
        self.LButtonText.text = data.title
        self.Ext:SetData(data.msg)
        self.TitleText.text = data.title
    end
end

function ChildrenNoticeResultPanel:OnOk()
    if self.data.mode == 2 and self.data.flag == 1 then
        ChildrenManager.Instance.model:OpenGetWindow()
    elseif self.data.mode == 1 and self.data.flag == 1 then
        ChildrenManager.Instance.model:OpenGetWindow()
    end
    ChildrenManager.Instance.model:CloseNoticeResultPanel()
end