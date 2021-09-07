-- @author hze
-- @date #2019/09/19#
-- 祈愿宝阁

PrayTreasureShopPanel = PrayTreasureShopPanel or BaseClass(BasePanel)

function PrayTreasureShopPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.pray_treasure_shop_panel, type = AssetType.Main},
        {file = AssetConfig.praytreasuretextures, type = AssetType.Dep},
    }
    self.model = model
    self.parent = parent
    self.mgr = self.model.mgr


    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self._update_load_listener = function() self:ReloadData(self.model.praytreasure_shoplist) end
    self.assetListener = function() self:SetAsset() end
end

function PrayTreasureShopPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for i, item in ipairs(self.itemList) do
            item:DeleteMe()
        end
    end
end

function PrayTreasureShopPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pray_treasure_shop_panel))
    self.gameObject.name = "PrayTreasureShopPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("ScrollRect/Container")
    self.itemCloner = self.container:Find("Tab").gameObject
    self.container:Find("Tab/Name").sizeDelta = Vector2(140,23.9)

    self.descTxt = self.transform:Find("Bottom/DescText")
    self.iconLoader = SingleIconLoader.New(self.transform:Find("Bottom/IconBg/Icon").gameObject)
    self.ownerTxt = self.transform:Find("Bottom/IconBg/Text"):GetComponent(Text)
end

function PrayTreasureShopPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PrayTreasureShopPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    if not self.openArgs then
        return
    end
    self.campId = self.openArgs[1]
    print(self.campId)

    self.campaignData = DataCampaign.data_list[self.campId]

    local datalist = {}
    local strList = StringHelper.Split(self.campaignData.camp_cond_client, ",")
    local exchange_first = tonumber(strList[1])
    local exchange_second = tonumber(strList[2])
    -- local exchange_first = 2
    -- local exchange_second = 34
    if exchange_first and exchange_second and ShopManager.Instance.model.datalist and ShopManager.Instance.model.datalist[exchange_first] and ShopManager.Instance.model.datalist[exchange_first][exchange_second] then
        for i, v in pairs(ShopManager.Instance.model.datalist[exchange_first][exchange_second]) do
            table.insert(datalist, v)
        end
    end
    self.model.praytreasure_shoplist = datalist
    BaseUtils.dump(datalist, "datalist++++++++++")
    self.assets_type = (datalist or {})[1].assets_type or "camp_pray_sc"

    self:SetAsset()
    self:ReloadData(datalist)
end

function PrayTreasureShopPanel:OnHide()
    self:RemoveListeners()
end

function PrayTreasureShopPanel:AddListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
    ShopManager.Instance.onUpdateBuyPanel:AddListener(self._update_load_listener)
end

function PrayTreasureShopPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
    ShopManager.Instance.onUpdateBuyPanel:RemoveListener(self._update_load_listener)
end

function PrayTreasureShopPanel:ReloadData(datalist)
    for i, v in ipairs(datalist) do
        local item = self.itemList[i]
        if item == nil then
            item = PrayTreasureShopItem.New(self.model, GameObject.Instantiate(self.itemCloner))
            UIUtils.AddUIChild(self.container.gameObject, item.gameObject)
            self.itemList[i] = item
        end
        item:SetData(v, i)
    end
    self.itemCloner:SetActive(false)
    local count = math.ceil(#datalist / 2)
    self.container.sizeDelta = Vector2(720, count * 98)
end

function PrayTreasureShopPanel:SetAsset()
    if GlobalEumn.CostTypeIconName[self.assets_type] == nil then
        self.iconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[self.assets_type]].icon)
    else
        self.iconLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[self.assets_type]))
    end
    self.ownerTxt.text = RoleManager.Instance.RoleData[self.assets_type]
end

