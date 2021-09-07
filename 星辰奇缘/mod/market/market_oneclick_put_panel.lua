MarketOneClickPutPanel = MarketOneClickPutPanel or BaseClass(BasePanel)

function MarketOneClickPutPanel:__init(model, parent)
    self.model = model
    self.mgr = MarketManager.Instance
    self.parent = parent

    self.confirmCallback = nil

    self.arrayLength = 0
    self.discount = 100
    self.blacklist = {}
    self.pageList = {}

    self.resList = {
        {file = AssetConfig.market_oneclick_setting, type = AssetType.Main}
        , {file = AssetConfig.market_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MarketOneClickPutPanel:__delete()
    if self.pageList ~= nil then
        for k,v in pairs(self.pageList) do
            v:DeleteMe()
        end
        self.pageList = nil
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MarketOneClickPutPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.market_oneclick_setting))
    self.gameObject.name = "MarketOneClickPutPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.panelBtn = t:Find("Panel"):GetComponent(Button)
    if self.panelBtn == nil then self.panelBtn = t:Find("Panel").gameObject:AddComponent(Button) end

    local main = t:Find("Main")
    self.closeBtn = main:Find("CloseButton"):GetComponent(Button)
    self.priceText = main:Find("PriceObject/NumBg/Value"):GetComponent(Text)
    self.plusBtn = main:Find("PriceObject/PlusButton"):GetComponent(Button)
    self.minusBtn = main:Find("PriceObject/MinusButton"):GetComponent(Button)
    self.cancelBtn = main:Find("BtnArea/Cancel"):GetComponent(Button)
    self.confirmBtn = main:Find("BtnArea/Confirm"):GetComponent(Button)
    self.container = main:Find("Panel/Scroll/Container")
    self.pageCloner = main:Find("Panel/Scroll/Page").gameObject

    self.pageCloner:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    for i=1,5 do
        local obj = GameObject.Instantiate(self.pageCloner)
        obj.name = tostring(i)
        self.layout:AddCell(obj)
        self.pageList[i] = MarketOneclickPage.New(self.model, obj)
    end
    self.tabbedPanel = TabbedPanel.New(self.container.parent.gameObject, 0, 346)

    self.confirmBtn.onClick:AddListener(function()
        self:WriteToDrive()
        self:Hiden()
        if self.confirmCallback ~= nil then
            self.confirmCallback(self.discount, self.blacklist)
        end
    end)
    self.panelBtn.onClick:AddListener(function() self:Hiden() end)
    self.cancelBtn.onClick:AddListener(function() self:Hiden() end)
    self.closeBtn.onClick:AddListener(function() self:Hiden() end)
    self.plusBtn.onClick:AddListener(function() self:PlusMinus(true) end)
    self.minusBtn.onClick:AddListener(function() self:PlusMinus(false) end)
end

function MarketOneClickPutPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MarketOneClickPutPanel:OnOpen()
    self:ReadFromDrive()
    self:RemoveListeners()

    self.priceText.text = tostring(self.discount).."%"

    for i,v in ipairs(self.pageList) do
        v:SetData(i)
    end

    self.tabbedPanel:SetPageCount(math.ceil(#self.model.showList / 20))
end

function MarketOneClickPutPanel:OnHide()
    self:RemoveListeners()
    -- self:WriteToDrive()
end

function MarketOneClickPutPanel:RemoveListeners()
end

function MarketOneClickPutPanel:WriteToDrive()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id)
    local sellBlaclListLen = "sellBlaclListLen"
    local discount = "discount"

    PlayerPrefs.SetInt(BaseUtils.Key(key, discount), self.discount)

    self.blacklist = {}
    for k,v in pairs(self.model.showList) do
        if v.exclude == 1 then
            table.insert(self.blacklist, v.base_id)
        end
    end
    for i,v in ipairs(self.blacklist) do
        PlayerPrefs.SetInt(BaseUtils.Key(key, sellBlaclListLen, i), v)
    end

    for i=#self.blacklist + 1, self.arrayLength do
        PlayerPrefs.DeleteKey(BaseUtils.Key(key, sellBlaclListLen, i))
    end

    self.arrayLength = #self.blacklist
    PlayerPrefs.SetInt(BaseUtils.Key(key, sellBlaclListLen), self.arrayLength)
    PlayerPrefs.SetInt(BaseUtils.Key(key, discount), self.discount)
end

function MarketOneClickPutPanel:ReadFromDrive()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id)
    local sellBlaclListLen = "sellBlaclListLen"
    local discount = "discount"

    self.discount = PlayerPrefs.GetInt(BaseUtils.Key(key, discount), 100)
    local len = PlayerPrefs.GetInt(BaseUtils.Key(key, sellBlaclListLen), -1)
    if len == -1 then
        self.blacklist = {21400}
        self.arrayLength = #self.blacklist
    else
        self.arrayLength = len
        for i=1,len do
            self.blacklist[i] = PlayerPrefs.GetInt(BaseUtils.Key(key, sellBlaclListLen, i))
        end
    end

    self.model.showList = {}
    local itemDic = BackpackManager.Instance.itemDic
    local blacklist = {}
    local whitelist = {}
    for _,v in pairs(self.blacklist) do
        if v ~= nil then
            blacklist[v] = true
        end
    end
    local kvWhitelist = {}
    for k,v in pairs(itemDic) do
        if v.bind ~= 1 and blacklist[v.base_id] ~= true and DataMarketSilver.data_market_silver_item[v.base_id] ~= nil and kvWhitelist[v.base_id] == nil then
            kvWhitelist[v.base_id] = true
            table.insert(whitelist, v.base_id)
        end
    end

    for k,_ in pairs(blacklist) do
        table.insert(self.model.showList, {base_id = k, exclude = 1})
    end
    table.sort(self.model.showList, function(a,b) return a.base_id < b.base_id end)
    table.sort(whitelist, function(a,b) return a < b end)
    for i,v in ipairs(whitelist) do
        table.insert(self.model.showList, {base_id = v, exclude = 0})
    end
end

function MarketOneClickPutPanel:PlusMinus(isPlus)
    if isPlus then
        if self.discount < 130 then
            self.discount = self.discount + 10
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能再贵了"))
        end
    else
        if self.discount > 50 then
            self.discount = self.discount - 10
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能再便宜了"))
        end
    end
    self.priceText.text = tostring(self.discount).."%"
end

MarketOneclickPage = MarketOneclickPage or BaseClass()

function MarketOneclickPage:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.itemPerPage = 20

    self.itemList = {}
    for i=0,self.itemPerPage - 1 do
        self.itemList[i + 1] = MarketOneclickItem.New(self.model, self.transform:GetChild(i).gameObject)
    end
end

function MarketOneclickPage:__delete()
    for k,v in pairs(self.itemList) do
        v:DeleteMe()
    end

    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end

    self.itemList = nil
end

function MarketOneclickPage:SetData(index)
    local showList = self.model.showList
    local num = (#showList - 1) % self.itemPerPage + 1
    local pageNum = math.ceil(#showList / self.itemPerPage)
    if index < pageNum then num = self.itemPerPage
    elseif index > pageNum then num = 0 end

    self.gameObject:SetActive(num > 0)

    for i=1,num do
        self.itemList[i]:SetData(showList[self.itemPerPage * (index - 1) + i])
    end
end

function MarketOneclickPage:SetActive(bool)
    self.gameObject:SetActive(bool)
end

MarketOneclickItem = MarketOneclickItem or BaseClass()

function MarketOneclickItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.excludeObj = self.transform:Find("Exclude").gameObject
    self.slotContainer = self.transform:Find("Container")
    self.selectObj = self.transform:Find("Select").gameObject
    self.button = self.gameObject:GetComponent(Button)
    self.itemData = nil
    self.itemSlot = nil

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function MarketOneclickItem:__delete()
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
end

function MarketOneclickItem:SetData(data)
    self.data = data
    if data == nil then
        if self.itemData ~= nil then
            self.itemData:DeleteMe()
            self.itemData = nil
        end
        if self.itemSlot ~= nil then
            self.itemSlot:DeleteMe()
            self.itemSlot = nil
        end
    else
        if self.itemData == nil then self.itemData = ItemData.New() end
        self.itemData:SetBase(DataItem.data_get[data.base_id])
        if self.itemSlot == nil then self.itemSlot = ItemSlot.New() end
        NumberpadPanel.AddUIChild(self.slotContainer.gameObject, self.itemSlot.gameObject)
        self.itemSlot:SetAll(self.itemData, {inbag = false, nobutton = true})
        self.excludeObj:SetActive(data.exclude == 0)
        self.selectObj:SetActive(data.exclude == 0)
    end
end

function MarketOneclickItem:OnClick()
    if self.data ~= nil then
        if self.data.exclude == 0 then
            self.data.exclude = 1
        else
            self.data.exclude = 0
        end
        self.excludeObj:SetActive(self.data.exclude == 0)
        self.selectObj:SetActive(self.data.exclude == 0)
    end
end

