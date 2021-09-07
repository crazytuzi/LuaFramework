-- 藏宝图兑换界面

TreasuremapExchangeView = TreasuremapExchangeView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2

function TreasuremapExchangeView:__init(model)
    self.model = model
    self.name = "TreasuremapExchangeView"
    self.windowId = WindowConfig.WinID.treasureexchangewindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end

    self.resList = {
        {file = AssetConfig.treasureexchangewindow, type = AssetType.Main},
        {file = AssetConfig.exchangebg, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    ------------------------------------------------
    self.Button = nil
    self.buttonscript = nil
    self.itemslot_list = {}
    self.lackItem = {}
    self.imgLoaderOnes = {}
    self.exchange_itemid_list = { 20054, 20055, 20056, 20057 }
    self.exchange_itemnum_list = { 1, 1, 1, 1 }

    ------------------------------------------------
    self._update = function()
        self:update()
    end
    ------------------------------------------------

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function TreasuremapExchangeView:__delete()
    for k,v in pairs(self.itemslot_list) do
        v:DeleteMe()
        v = nil
    end

    if self.buttonscript ~= nil then
        self.buttonscript:DeleteMe()
        self.buttonscript = nil
    end

    if self.imgLoaderOnes ~= nil then
        for k,v in pairs(self.imgLoaderOnes) do
            v:DeleteMe()
        end
        self.imgLoaderOnes = {}
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:OnHide()
    self:AssetClearAll()
end

function TreasuremapExchangeView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasureexchangewindow))
    self.gameObject.name = "TreasuremapExchangeView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    local transform = self.transform

    transform:Find("Main/bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.exchangebg, "ExchangeBg")

    local closeBtn = transform:FindChild("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.Button = transform:FindChild("Main/Button").gameObject
    self.buttonscript = BuyButton.New(self.Button, TI18N("兑 换"))
    self.buttonscript.key = "TreasuremapExchange"
    self.buttonscript.protoId = 13603
    self.buttonscript:Show()

    local item = nil
    for i = 1, 4 do
        item = transform:FindChild("Main/Item"..i.."/ItemSlot").gameObject
        local itemSolt = ItemSlot.New()
        UIUtils.AddUIChild(item, itemSolt.gameObject)
        table.insert(self.itemslot_list, itemSolt)
    end

    -------------------------------------------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function TreasuremapExchangeView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TreasuremapExchangeView:OnShow()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update)
    self:update()
end

function TreasuremapExchangeView:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update)
end

function TreasuremapExchangeView:update()
if self.transform == nil then return end

    local exchange_num = 999999
    local infoLack = {}
    self.lackItem = {}
    for i = 1, #self.exchange_itemid_list do
        local item_slot = self.itemslot_list[i]
        local item_baseid = self.exchange_itemid_list[i]

        local item_basedata = BackpackManager.Instance:GetItemBase(item_baseid)
        if item_basedata ~= nil then
            local num = BackpackManager.Instance:GetItemCount(item_baseid)

            local itemData = ItemData.New()
            itemData:SetBase(item_basedata)
            -- itemData.quantity = num
            item_slot:SetAll(itemData)
            self.transform:FindChild("Main/Item"..i.."/NameText"):GetComponent(Text).text = item_basedata.name

            local num_text = self.transform:FindChild("Main/Item"..i.."/NumText"):GetComponent(Text)
            num_text.text = string.format("%s/%s", num, self.exchange_itemnum_list[i])
            if num >= self.exchange_itemnum_list[i] then
                num_text.color = Color.green
                self.transform:FindChild("Main/Item"..i.."/Num").gameObject:SetActive(false)
            else
                num_text.color = Color.red
                infoLack[item_baseid] = {need = self.exchange_itemnum_list[i]}
                self.lackItem[item_baseid] = self.transform:FindChild("Main/Item"..i).gameObject
            end

            local temp = math.floor(num / self.exchange_itemnum_list[i])
            if temp < exchange_num then exchange_num = temp end
        end
    end

    local exchange_num_text = self.transform:FindChild("Main/NumText"):GetComponent(Text)
    exchange_num_text.text = tostring(exchange_num)
    if exchange_num > 0 then
        exchange_num_text.color = Color.green
    else
        exchange_num_text.color = Color.red
    end
    -- BaseUtils.dump(infoLack)
    self.buttonscript:Layout(infoLack, function() TreasuremapManager.Instance:Send13603() end,  function(baseidToBuyInfo) self:lackCallback(baseidToBuyInfo) end)
end

function TreasuremapExchangeView:GetReward()
    if self.transform == nil then return end

    TreasuremapManager.Instance:Send13603()
end

function TreasuremapExchangeView:lackCallback(baseidToBuyInfo)
    local coins = RoleManager.Instance.RoleData.coins
    local gold_bind = RoleManager.Instance.RoleData.gold_bind

    for k,v in pairs(baseidToBuyInfo) do
        local t = self.lackItem[k].transform
        local numText = t:Find("Num"):GetComponent(Text)
        local currencyImage = t:Find("Num/Currency"):GetComponent(Image)

        local idOne = currencyImage.gameObject:GetInstanceID()
        if self.imgLoaderOnes[idOne] == nil then
           local go =  currencyImage.gameObject
           self.imgLoaderOnes[idOne] = SingleIconLoader.New(go)
        end
        self.imgLoaderOnes[idOne]:SetSprite(SingleIconType.Item,v.assets)

        if v.allprice < 0 then
            numText.text = "<color=#FF0000>"..tostring(0 - v.allprice).."</color>"
        else
            numText.text = tostring(v.allprice)
        end

        t:Find("Num").gameObject:SetActive(true)
    end
end