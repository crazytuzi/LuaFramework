-- @author hzf家具商店子面板
-- @date 2016年7月14日,星期四

HomeShopSubPanel = HomeShopSubPanel or BaseClass(BasePanel)


function HomeShopSubPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.homeshopsubpanel, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
    }

    self.GoodsList = {}
    self.tabList = {}
    self.currData = nil
    self.currPanel = nil
    self.singleVal = 0
    self.selectnum = 0

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updatePanelListener = function() self:UpdateBuyPanel() end
    self.updateGoodsListener = function() self:InitGoods() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function HomeShopSubPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updatePanelListener)
    EventMgr.Instance:RemoveListener(event_name.home_shop_update, self.updateGoodsListener)
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gridLayoutList ~= nil then
        for k,v in pairs(self.gridLayoutList) do
            if v ~= nil then
                v:DeleteMe()
                self.gridLayoutList[k] = nil
                v = nil
            end
        end
    end
    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            if v ~= nil then
                self.itemList[k]:DeleteMe()
                self.itemList[k] = nil
                v = nil
            end
        end
        self.itemList = nil
    end
    if self.toggleLayout ~= nil then
        self.toggleLayout:DeleteMe()
        self.toggleLayout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HomeShopSubPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.homeshopsubpanel))
    self.gameObject.name = "SelectPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.goodsPanel = t:Find("GoodsPanel")
    self.baseTabBtn = self.transform:Find("Button")
    self.TopTabButtonGroup = self.transform:Find("TopTabButtonGroup")
    self.Helpbtn = self.transform:Find("Help"):GetComponent(Button)
    self.Desc = self.transform:Find("Desc"):GetComponent(Text)
    self.InfoArea = self.transform:Find("InfoArea")
    self.GoodsInfo = self.InfoArea:Find("GoodsTips/GoodsInfo")
    self.Name = self.GoodsInfo:Find("Name"):GetComponent(Text)
    self.Describe = self.GoodsInfo:Find("Describe"):GetComponent(Text)
    self.Restraint = self.GoodsInfo:Find("Restraint"):GetComponent(Text)
    self.Price = self.GoodsInfo:Find("Price")
    self.PricePrice = self.Price:Find("Prices"):GetComponent(Text)
    self.PriceDiscount = self.Price:Find("Discount/Discount"):GetComponent("Text")
    self.GirlGuide = self.InfoArea:Find("GoodsTips/GirlGuide")
    self.FashionShow = self.InfoArea:Find("GoodsTips/FashionShow")
    self.FashionShow:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.FashionShowPreview = self.FashionShow:Find("Preview")

    self.BuyArea = self.InfoArea:Find("BuyArea")
    self.MinusBtn = self.BuyArea:Find("BuyCount/MinusBtn"):GetComponent(Button)
    self.AddBtn = self.BuyArea:Find("BuyCount/AddBtn"):GetComponent(Button)
    self.CountTxt = self.BuyArea:Find("BuyCount/CountBg/Count"):GetComponent(Text)

    self.CurrencyImg = self.BuyArea:Find("BuyPrice/PriceBg/Currency"):GetComponent(Image)
    self.TotlaPrice = self.BuyArea:Find("BuyPrice/PriceBg/Price"):GetComponent(Text)
    self.OwnCurrencyImg = self.BuyArea:Find("OwnAsset/AssetBg/Currency"):GetComponent(Image)
    self.OwnPrice = self.BuyArea:Find("OwnAsset/AssetBg/Asset"):GetComponent(Text)

    self.BuyButton = self.BuyArea:Find("BtnArea/Button"):GetComponent(Button)
    self.RechargeButton = self.BuyArea:Find("BtnArea/Recharge"):GetComponent(Button)

    self.BuyButton.onClick:AddListener(function() self:OnClickBuy() end)
    self.RechargeButton.onClick:AddListener(function() self:OnClickRecharge() end)
    self.Helpbtn.onClick:AddListener(function() self:OnClickHelp() end)

    self.AddBtn.onClick:AddListener(function() self:OnClickAddMinus(true) end)
    self.MinusBtn.onClick:AddListener(function() self:OnClickAddMinus(false) end)

    self.DescribeEXT = MsgItemExt.New(self.Describe, 218, 16, 21)

    self.GirlGuide.gameObject:SetActive(true)
    self.GoodsInfo.gameObject:SetActive(false)
    self.Price.gameObject:SetActive(false)
    self.Restraint.gameObject:SetActive(false)
    self.baseTabBtn.gameObject:SetActive(false)
    self.Helpbtn.gameObject:SetActive(false)
    --self.Desc.gameObject:SetActive(false)
    self:InitGoods()
    self.OnOpenEvent:Fire()
end

function HomeShopSubPanel:OnOpen()
    self:UpdateBuyPanel()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updatePanelListener)
    EventMgr.Instance:AddListener(event_name.home_shop_update, self.updateGoodsListener)
end

function HomeShopSubPanel:OnHide()
    -- self:RemoveListeners()
end

function HomeShopSubPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updatePanelListener)
    EventMgr.Instance:RemoveListener(event_name.home_shop_update, self.updateGoodsListener)
end

function HomeShopSubPanel:OnClickHelp()
    -- body
end

function HomeShopSubPanel:OnClickBuy()
    if self.currData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
    else
        -- for i=1, self.selectnum do
            HomeManager.Instance:Send11212(self.currData.id, self.selectnum)
        -- end
    end
end

function HomeShopSubPanel:OnClickRecharge()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,1})
end

function HomeShopSubPanel:InitGoods()
    local data = self.model.shop_datalist
    -- BaseUtils.dump(data,":::::::::::::::::::::::::::::::")
    local temp = {}
    for i,v in pairs(data) do
        if temp[v.store_type] == nil then
            temp[v.store_type] = {}
        end
        -- print(v.id)
        -- BaseUtils.dump(DataFamily.data_shop_goods[v.id],"asdsadsadsadsada")
        local cfgdata = BaseUtils.copytab(DataFamily.data_shop_goods[v.id])
        if cfgdata == nil then
            Log.Error("家具商店没这个道具id："..tostring(v.id))
        else
            cfgdata.id = v.id
            cfgdata.count = v.count
            cfgdata.val = v.val
            table.insert(temp[v.store_type], cfgdata)
        end
    end
    local tabnum = 0
    for k,v in pairs(temp) do
        tabnum = tabnum + 1
        if self.GoodsList[k] == nil then
            self.GoodsList[k] = HomeShopListPanel.New(self.model, self.goodsPanel, v, self)
        else
            self.GoodsList[k]:ReloadData(v)
        end
    end
    if self.tabGroup == nil then
        for i=1,tabnum do
            if self.tabList[i] == nil then
                local obj = GameObject.Instantiate(self.baseTabBtn.gameObject)
                self.tabList[i] = obj
                obj.name = tostring(i)
                obj.transform:SetParent(self.TopTabButtonGroup)
                obj.transform.localScale = Vector3.one
                obj.transform.localPosition = Vector3.zero
                obj:SetActive(true)
                obj.transform.anchoredPosition = Vector2(((2*i)-1)*61, -19)
                if i == 1 then
                    obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, "124")
                    obj.transform:Find("CenterText"):GetComponent(Text).text = TI18N("精美商店")
                elseif i == 2 then
                    obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, "125")
                    obj.transform:Find("CenterText"):GetComponent(Text).text = TI18N("奢华商店")
                end
            end
        end
        self.setting = {
            noCheckRepeat = true,
            notAutoSelect = false,
            perWidth = 122,
            perHeight = 38,
            isVertical = false
        }
        self.tabGroup = TabGroup.New(self.TopTabButtonGroup.gameObject, function(index) self:ChangeTab(index) end, self.setting)
    end
end

function HomeShopSubPanel:OnClickItem(Item, data)
    if self.currData ~= nil and self.currData.base_id == data.base_id then
        self.currData = data
        self.singleVal = data.val
        if self.selectnum > data.count then
            self.selectnum = data.count
        end
        self:UpdateBuyPanel()
    else
        self.currData = data
        self.GirlGuide.gameObject:SetActive(false)
        self.GoodsInfo.gameObject:SetActive(true)
        local itemid = DataFamily.data_unit[data.base_id].item_id
        local baseData = DataItem.data_get[itemid]
        self.Name.text = baseData.name
        local str = string.gsub(baseData.desc, "<.->", "")
        self.DescribeEXT:SetData(str)
        self.singleVal = data.val
        self.selectnum = 1
        self.CurrencyImg.gameObject:SetActive(true)
        self.OwnCurrencyImg.gameObject:SetActive(true)
        self.CurrencyImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..tostring(data.type))
        self.OwnCurrencyImg.sprite = self.CurrencyImg.sprite
        self:UpdateBuyPanel()
    end
end

function HomeShopSubPanel:ChangeTab(index)
    if self.currPanel ~= nil then
        self.currPanel:Hiden()
    end
    self.currData = nil
    self.singleVal = 0
    self.selectnum = 0
    self.currPanel = self.GoodsList[index]
    if self.currPanel ~= nil then
        self.currPanel:Show()
    end
    self:UpdateBuyPanel()
end

function HomeShopSubPanel:OnClickAddMinus(isadd)
    if self.currData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
        return
    end
    if isadd then
        if self.selectnum >= self.currData.count then
            NoticeManager.Instance:FloatTipsByString(TI18N("不能购买更多了"))
            return
        end
        self.selectnum = self.selectnum + 1
    else
        if self.selectnum <= 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("最少买一个"))
            self.selectnum = 1
            return
        end
        self.selectnum = self.selectnum - 1
    end
    self:UpdateBuyPanel()
end

function HomeShopSubPanel:UpdateBuyPanel()
    if BaseUtils.isnull(self.CountTxt) then
        self:RemoveListeners()
        return
    end
    if self.currData == nil then
        self.GirlGuide.gameObject:SetActive(true)
        self.GoodsInfo.gameObject:SetActive(false)
        return
    end
    local roledata = RoleManager.Instance.RoleData
    local coins = roledata:GetMyAssetById(KvData.assets.coin)
    local gold_bind = roledata:GetMyAssetById(KvData.assets.gold_bind)
    local gold = roledata:GetMyAssetById(KvData.assets.gold)
    local has = roledata:GetMyAssetById(self.currData.type)
    self.CountTxt.text = tostring(self.selectnum)
    self.OwnPrice.text = tostring(has)
    local totalval = self.selectnum * self.singleVal
    self.TotlaPrice.text = totalval
    if totalval > has then
        self.TotlaPrice.color = Color(0.8, 0.129411765, 0.129411765)
    else
        self.TotlaPrice.color = Color(0.015686275, 0.866666667, 0.321568627)
    end

end