-----钻石快速购买面板传入物品baseid---
-----hzf--------
ShopQuickBuyPanel = ShopQuickBuyPanel or BaseClass(BasePanel)

function ShopQuickBuyPanel:__init(model)
    self.model = model
    self.name = "ShopQuickBuyPanel"
    self.resList = {
        {file = AssetConfig.quickdiamonbuypanel, type = AssetType.Main}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.goods_data = nil
    self.isSlive = false
    self.num = 1
    self.timer = nil
    self.slotlist = {}
    self.listener = function() self:UpdateAsset() end
end

function ShopQuickBuyPanel:OnInitCompleted()

end

function ShopQuickBuyPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.listener)
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function ShopQuickBuyPanel:InitPanel()
    if self.openArgs == nil then
        print("没参数")
    else
        BaseUtils.dump(self.openArgs)
    end
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.listener)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.quickdiamonbuypanel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.baseItemData = DataItem.data_get[self.openArgs]
    for k,v in pairs(ShopManager.Instance.itemPriceTab) do
        if v.base_id == self.openArgs and self.goods_data == nil then
            self.goods_data = v
        end
    end
    if self.goods_data == nil then
        for k,v in pairs(DataMarketSilver.data_market_silver_item) do
            if v.base_id == self.openArgs and self.goods_data == nil then
                self.goods_data = v
                self.goods_data.price = v.def_price
                self.goods_data.name = self.baseItemData.name
                self.isSlive = true
            end
        end
    end
    self.transform:Find("Main/CloseButton"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:CloseQuickBuyPanel() end)
    self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:CloseQuickBuyPanel() end)

    self.infoText = self.transform:Find("Main/ButtonCon/InfoText"):GetComponent(Text)
    self.slotcon = self.transform:Find("Main/ButtonCon/item")
    self.itemname = self.transform:Find("Main/ButtonCon/ItemName"):GetComponent(Text)
    self.numText = self.transform:Find("Main/ButtonCon/numText"):GetComponent(Text)
    self.needtext = self.transform:Find("Main/ButtonCon/needText"):GetComponent(Text)
    self.hastext = self.transform:Find("Main/ButtonCon/hasText"):GetComponent(Text)
    self.addBtn = self.transform:Find("Main/ButtonCon/AddButton"):GetComponent(CustomButton)
    self.descBtn = self.transform:Find("Main/ButtonCon/DescButton"):GetComponent(CustomButton)
    self.okBtn = self.transform:Find("Main/okButton"):GetComponent(Button)

    self.needicon = self.transform:Find("Main/ButtonCon/needbg/Image"):GetComponent(Image)
    self.hasicon = self.transform:Find("Main/ButtonCon/hasbg/Image"):GetComponent(Image)

    self.addBtn.onClick:AddListener(function() self:Addnum() end)
    self.descBtn.onClick:AddListener(function() self:Descnum() end)

    self.addBtn.onHold:AddListener(function() self:StartTimer(true) end)
    self.descBtn.onHold:AddListener(function() self:StartTimer(false) end)

    self.addBtn.onUp:AddListener(function() self:StopTimer() end)
    self.descBtn.onUp:AddListener(function() self:StopTimer() end)

    self.okBtn.onClick:AddListener(function() self:OnOk() end)

    self.numText.gameObject.transform:GetComponent(Button).onClick:AddListener(function() self:OpenNumPad() end)
    self:InitInfo()
end

function ShopQuickBuyPanel:InitInfo()
    self.infoText.text = string.format(TI18N("%s不足，你可便捷购买"), self.baseItemData.name)
    self.itemname.text = self.goods_data.name
    local baseid = self.goods_data.base_id
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[baseid]
    info:SetBase(base)
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    table.insert(self.slotlist, slot)
    UIUtils.AddUIChild(self.slotcon.gameObject,slot.gameObject)
    if self.isSlive then
        self.needicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
        self.hasicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
        self.assets = RoleManager.Instance.RoleData.coin
    elseif self.goods_data.assets_type == "gold_bind" then
        self.needicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")
        self.hasicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")
        self.assets = RoleManager.Instance.RoleData.gold_bind
    elseif self.goods_data.assets_type == "stars_score" then
        self.needicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90012")
        self.hasicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90012")
        self.assets = RoleManager.Instance.RoleData.stars_score
    elseif self.goods_data.assets_type == "character" then
        self.needicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90007")
        self.hasicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90007")
        self.assets = RoleManager.Instance.RoleData.character
    elseif self.goods_data.assets_type == "love" then
        self.needicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90018")
        self.hasicon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90018")
        self.assets = RoleManager.Instance.RoleData.love
    else
        self.assets = RoleManager.Instance.RoleData.gold
    end

    self.numText.text = tostring(self.num)
    if self.assets >= self.num*self.goods_data.price then
        self.needtext.text = tostring(self.num*self.goods_data.price)
    else
        self.needtext.text = string.format("<color='#ff0000'>%s</color>", tostring(self.num*self.goods_data.price))
    end
    self.hastext.text = tostring(self.assets)
    if self.isSlive then
        MarketManager.Instance:send12408(self.goods_data.base_id, 3)
    end
end

function ShopQuickBuyPanel:UpdateAsset()
    if self.isSlive then
        self.assets = RoleManager.Instance.RoleData.coin
    elseif self.goods_data.assets_type == "gold_bind" then
        self.assets = RoleManager.Instance.RoleData.gold_bind
    elseif self.goods_data.assets_type == "stars_score" then
        self.assets = RoleManager.Instance.RoleData.stars_score
    elseif self.goods_data.assets_type == "character" then
        self.assets = RoleManager.Instance.RoleData.character
    elseif self.goods_data.assets_type == "love" then
        self.assets = RoleManager.Instance.RoleData.love
    end
    self.numText.text = tostring(self.num)
    if self.assets >= self.num*self.goods_data.price then
        self.needtext.text = tostring(self.num*self.goods_data.price)
    else
        self.needtext.text = string.format("<color='#ff0000'>%s</color>", tostring(self.num*self.goods_data.price))
    end
    self.hastext.text = tostring(self.assets)
end

function ShopQuickBuyPanel:StartTimer(up)
    if self.timer == nil then
        if up then
            self.timer = LuaTimer.Add(0,100,function() self:Addnum() end)
        else
            self.timer = LuaTimer.Add(0,100,function() self:Descnum() end)
        end
    end
end
function ShopQuickBuyPanel:StopTimer()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
    end
    self.timer = nil
end


function ShopQuickBuyPanel:Addnum()
    self.num = self.num + 1
    self.numText.text = tostring(self.num)
    if self.assets >= self.num*self.goods_data.price then
        self.needtext.text = tostring(self.num*self.goods_data.price)
    else
        self.needtext.text = string.format("<color='#ff0000'>%s</color>", tostring(self.num*self.goods_data.price))
    end
end

function ShopQuickBuyPanel:Descnum()
    if self.num > 1 then
        self.num = self.num - 1
    end
    self.numText.text = tostring(self.num)
    if self.assets >= self.num*self.goods_data.price then
        self.needtext.text = tostring(self.num*self.goods_data.price)
    else
        self.needtext.text = string.format("<color='#ff0000'>%s</color>", tostring(self.num*self.goods_data.price))
    end
end

function ShopQuickBuyPanel:OnOk()
    ShopManager.Instance:send11303(self.goods_data.id, self.num)
end

function ShopQuickBuyPanel:OpenNumPad()
    local buyIt = function(num)
        self:SetNum(num)
    end
    local max_by_asset = 99
    local info = {parent_obj = self.gameObject, gameObject = self.numText.gameObject, min_result = 1, max_by_asset = 99, max_result = max_by_asset, textObject = self.numText, show_num = false, funcReturn = buyIt}
    NumberpadManager.Instance:set_data(info)
    NumberpadManager.Instance:OpenWindow()
end

function ShopQuickBuyPanel:SetNum(num)
    self.num = num
    self.numText.text = tostring(self.num)
    if self.assets >= self.num*self.goods_data.price then
        self.needtext.text = tostring(self.num*self.goods_data.price)
    else
        self.needtext.text = string.format("<color='#ff0000'>%s</color>", tostring(self.num*self.goods_data.price))
    end
end

function ShopQuickBuyPanel:RefreshSlivePrive()
    self.goods_data.price = MarketManager.Instance.model.standardPriceServerByBaseId[self.goods_data.base_id]
    self.assets = RoleManager.Instance.RoleData.coin
    self.numText.text = tostring(self.num)
    if self.assets >= self.num*self.goods_data.price then
        self.needtext.text = tostring(self.num*self.goods_data.price)
    else
        self.needtext.text = string.format("<color='#ff0000'>%s</color>", tostring(self.num*self.goods_data.price))
    end
    self.hastext.text = tostring(self.assets)
end
-- (RoleManager.Instance.RoleData.gold_bind)
-- (RoleManager.Instance.RoleData.coin)
-- (RoleManager.Instance.RoleData.gold)