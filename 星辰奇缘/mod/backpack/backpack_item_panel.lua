BackpackItemPanel = BackpackItemPanel or BaseClass(BasePanel)

function BackpackItemPanel:__init(model, storageType, isInStorage, doubleClickFunc)
    self.model = model
    self.parent = nil
    self.resList = {
        {file = AssetConfig.backpack_item, type = AssetType.Main},
    }

    self.storageType = storageType

    self.gridPanel = BackpackGridPanel.New(self, true, self.storageType, isInStorage, doubleClickFunc)
    self.toggleTab = {}
    self.listener = function() self:UpdateAssets() end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
end

function BackpackItemPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.listener)
    if self.gridPanel ~= nil then
        self.gridPanel:DeleteMe()
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function BackpackItemPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_item))
    self.gameObject.name = "BackpackItemPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(185, 0, 0)

    self.transform:Find("Glod"):GetComponent(Button).onClick:AddListener(function() self:ClickIcon(1) end)
    self.transform:Find("Silver"):GetComponent(Button).onClick:AddListener(function() self:ClickIcon(2) end)
    self.transform:Find("Diamod"):GetComponent(Button).onClick:AddListener(function() self:ClickIcon(3) end)

    self.transform:Find("GoldVal"):GetComponent(Button).onClick:AddListener(function() self:ClickIcon(1) end)
    self.transform:Find("SliverVal"):GetComponent(Button).onClick:AddListener(function() self:ClickIcon(2) end)
    self.transform:Find("DiamondVal"):GetComponent(Button).onClick:AddListener(function() self:ClickIcon(3) end)

    self.goldTxt = self.transform:Find("GoldVal"):GetComponent(Text)
    self.silverTxt = self.transform:Find("SliverVal"):GetComponent(Text)
    self.diamondTxt = self.transform:Find("DiamondVal"):GetComponent(Text)
    self.goldTxt.color = Color(232/255, 250/255, 255/255, 1)
    self.silverTxt.color = Color(232/255, 250/255, 255/255, 1)
    self.diamondTxt.color = Color(232/255, 250/255, 255/255, 1)

    self.addGoldBtn = self.transform:Find("AddGoldBtn"):GetComponent(Button)
    self.addSilverBtn = self.transform:Find("AddSilverBtn"):GetComponent(Button)
    self.addDiamondBtn = self.transform:Find("AddDiamondBtn"):GetComponent(Button)

    self.restoreBtn = self.transform:Find("RestoreButton"):GetComponent(Button)

    self.toggleGroup = self.transform:Find("ToggleGroup")
    self:UpdateToggle()

    self.addGoldBtn.onClick:AddListener(function() self:AddGold() end)
    self.addSilverBtn.onClick:AddListener(function() self:AddSilver() end)
    self.addDiamondBtn.onClick:AddListener(function() self:AddDiamond() end)
    self.restoreBtn.onClick:AddListener(function() self:ClickRestore() end)

    self.gridPanel.parent = self.gameObject
    self.gridPanel:Show()

    self.goldTxt.text = "0"
    self.silverTxt.text = "0"
    self.diamondTxt.text = "0"

    self:UpdateAssets()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.listener)
end

function BackpackItemPanel:OnInitCompleted()
    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end

function BackpackItemPanel:UpdateAssets()
    self.goldTxt.text = tostring(RoleManager.Instance.RoleData.gold_bind)
    self.silverTxt.text = tostring(RoleManager.Instance.RoleData.coin)
    self.diamondTxt.text = tostring(RoleManager.Instance.RoleData.gold)

    if RoleManager.Instance.RoleData.debt_gold_bind > 0 then
        self.goldTxt.text = string.format("-%s", RoleManager.Instance.RoleData.debt_gold_bind)
        self.goldTxt.color = Color(1, 1, 0, 1)
        self.debt_gold_bind_mark = true
    elseif self.debt_gold_bind_mark then
        self.goldTxt.color = Color(232/255, 250/255, 255/255, 1)
        self.debt_gold_bind_mark = false
    end

    if RoleManager.Instance.RoleData.debt_coin > 0 then
        self.silverTxt.text = string.format("-%s", RoleManager.Instance.RoleData.debt_coin)
        self.silverTxt.color = Color(1, 1, 0, 1)
        self.debt_coin_mark = true
    elseif self.debt_coin_mark then
        self.silverTxt.color = Color(232/255, 250/255, 255/255, 1)
        self.debt_coin_mark = false
    end

    if RoleManager.Instance.RoleData.debt_gold > 0 then
        self.diamondTxt.text = string.format("-%s", RoleManager.Instance.RoleData.debt_gold)
        self.diamondTxt.color = Color(1, 1, 0, 1)
        self.debt_gold_mark = true
    elseif self.debt_gold_mark then
        self.diamondTxt.color = Color(232/255, 250/255, 255/255, 1)
        self.debt_gold_mark = false
    end
end

function BackpackItemPanel:AddGold()
    ExchangeManager.Instance.model:OpenWindow(1)
end

function BackpackItemPanel:AddSilver()
    ExchangeManager.Instance.model:OpenWindow(2)
end

function BackpackItemPanel:AddDiamond()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
end

function BackpackItemPanel:ClickRestore()
    SoundManager.Instance:Play(256)
    BackpackManager.Instance:Send10321()
end

function BackpackItemPanel:OnChangePage(index)
    if self.toggleTab[index] ~= nil then
        self.toggleTab[index].isOn = true
    end
end

function BackpackItemPanel:ExtendGrid()
    self.gridPanel:UnlockNewSlot()
end

function BackpackItemPanel:UpdateToggle()
    -- local maxpage = math.ceil(BackpackManager.Instance.volumeOfItem / 25)
    -- local maxpage = math.min(5, math.ceil(BackpackManager.Instance.volumeOfItem / 25) + 1)
    local maxpage = 5
    if math.ceil(BackpackManager.Instance.volumeOfItem / 25) > 3 then
        -- 开过的显示5页
        maxpage = 5
    else
        -- 没开过的显示4页
        maxpage = 4
    end
    for i = 1, 5 do
        self.toggleTab[i] = self.toggleGroup:GetChild(i - 1):GetComponent(Toggle)
        self.toggleTab[i].gameObject.transform.anchoredPosition = Vector2((i - 1) * 20 + 12, -12)
        self.toggleTab[i].gameObject:SetActive(i <= maxpage)
    end
end

function BackpackItemPanel:ClickIcon(index)
    local gameObject = nil
    local itemData = ItemData.New()
    if index == 1 then
        gameObject = self.goldTxt.gameObject
        itemData:SetBase(DataItem.data_get[90003])
    elseif index == 2 then
        gameObject = self.silverTxt.gameObject
        itemData:SetBase(DataItem.data_get[90000])
    elseif index == 3 then
        gameObject = self.diamondTxt.gameObject
        itemData:SetBase(DataItem.data_get[90002])
    end
    TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = itemData, extra = {nobutton = false, inbag = false}})
end

function BackpackItemPanel:OnShow()
end

