-- @author 黄耀聪
-- @date 2016年8月31日

ShopTimelyPanel = ShopTimelyPanel or BaseClass(BasePanel)

function ShopTimelyPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ShopTimelyPanel"

    self.resList = {
        {file = AssetConfig.shop_timely_panel, type = AssetType.Main},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
    }

    self.panelList = {}

    self.setting = {
        isVertical = true,
        notAutoSelect = true,
        noCheckRepeat = true,
        perWidth = 203,
        perHeight = 132,
        spacing = 0,
    }

    self.tabData = {
        {nameImg = "monthly_gift_I18N", moneyString = "￥30", icon = "I18N_Monthly",
            timeFunc = function()
                if PrivilegeManager.Instance.monthlyExcessDays > 0 then
                    return string.format(TI18N("剩余：%s天"), tostring(PrivilegeManager.Instance.monthlyExcessDays))
                else
                    return ""
                end
            end
        }
    }
    self.tabList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ShopTimelyPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.tabList ~= nil then
        for _,v in pairs(self.tabList) do
            if v ~= nil then
                v.titleImage.sprite = nil
            end
        end
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShopTimelyPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_timely_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.panelContaienr = t:Find("Panel")
    self.container = t:Find("TabGroup/Container")
    self.cloner = t:Find("TabGroup/Cloner").gameObject
    self.transform:Find("TabGroup").anchoredPosition3D = Vector2(16, -41.4, 0)

    if BaseUtils.IsVerify then
        self.cloner.transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Excharge1")
    end

    self:ReloadTab()
    self.tabGroup = TabGroup.New(self.container, function(index) self:ChangeTab(index) end, self.setting)
    self.cloner:SetActive(false)
end

function ShopTimelyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ShopTimelyPanel:OnOpen()
    self:RemoveListeners()
    -- self:ReloadTab()

    self:RefreshTab()

    self.tabGroup:Layout()
    self.tabGroup:ChangeTab(1)
end

function ShopTimelyPanel:OnHide()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            v:Hiden()
        end
    end
    self:RemoveListeners()
end

function ShopTimelyPanel:RemoveListeners()
end

function ShopTimelyPanel:ChangeTab(index)
    local panel = nil
    if self.lastIndex ~= nil then
        panel = self.panelList[self.lastIndex]
        if panel ~= nil then
            panel:Hiden()
        end
    end

    panel = self.panelList[index]
    if panel == nil then
        if index == 1 then
            panel = ShopMonthlyPanel.New(self.model, self.panelContaienr)
        end
        self.panelList[index] = panel
    end

    if panel ~= nil then
        panel:Show()
    end
end

function ShopTimelyPanel:ReloadTab()
    for i,v in ipairs(self.tabData) do
        local tab = self.tabList[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.cloner)
            tab.obj.name = tostring(i)
            tab.transform = tab.obj.transform
            tab.titleImage = tab.transform:Find("Title"):GetComponent(Image)
            tab.timeText = tab.transform:Find("Titme"):GetComponent(Text)
            tab.moneyText = tab.transform:Find("Money"):GetComponent(Text)
            tab.transform:SetParent(self.container)
            tab.transform.localScale = Vector3.one
            self.tabList[i] = tab
        end
        tab.titleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, v.nameImg)
        tab.timeText.text = v.timeFunc()
        tab.moneyText.text = v.moneyString
    end
    for i=#self.tabData + 1,#self.tabList do
        self.tabList[i].obj:SetActive(false)
    end
end

function ShopTimelyPanel:RefreshTab()
    for i,v in ipairs(self.tabData) do
        local tab = self.tabList[i]
        tab.titleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, v.nameImg)
        tab.timeText.text = v.timeFunc()
        tab.moneyText.text = v.moneyString
    end
end

