-- ----------------------------------------------------------
-- UI - 坐骑洗炼窗口
-- @ljh 2016.8.16
-- ----------------------------------------------------------
RideWashView = RideWashView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function RideWashView:__init(model)
    self.model = model
    self.name = "RideWashView"
    self.windowId = WindowConfig.WinID.ridewash
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.ridewash_real, type = AssetType.Main}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.ride_texture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
    self.attrItemList = {}

    self.itemSolt = nil

    self.startList = {}

    self.starEffect = nil
    self.washEffect = nil
	------------------------------------------------
    ------------------------------------------------
    self._update = function() self:update() end
    self.itemChangeListener = function() self:update_item() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RideWashView:__delete()
    self:OnHide()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end
    if self.washButton ~= nil then
        self.washButton:DeleteMe()
        self.washButton = nil
    end
    if self.slotNumExt ~= nil then
        self.slotNumExt:DeleteMe()
        self.slotNumExt = nil
    end
    self:AssetClearAll()
end

function RideWashView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewash_real))
    self.gameObject.name = "RideWashView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainPanel = self.transform:FindChild("Main").gameObject

    local btn = self.mainPanel.transform:FindChild("CloseButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnClickClose() end)

    self.washButton = BuyButton.New(self.mainPanel.transform:FindChild("Normal/WashContainer"), TI18N("洗 髓"))
    self.washButton.key = "RideWash"
    self.washButton.protoId = 17002
    self.washButton:Show()
    btn = self.mainPanel.transform:FindChild("Normal/WashButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self.washButton:OnClick() end)

    self.mainPanel.transform:FindChild("Normal/SaveButton").gameObject:SetActive(false)

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.mainPanel.transform:FindChild("Normal/ItemSolt").gameObject, self.itemSolt.gameObject)

    self.normal = self.transform:Find("Main/Normal").gameObject
    self.maxAttr = self.transform:Find("Main/MaxAttr").gameObject
    self.max = self.transform:Find("Main/Max").gameObject
    self.attr = self.transform:Find("Main/NewAttrPanel").gameObject

    self.attrItemClone = self.transform:Find("Main/NowAttrPanel/Mask/Panel/AttrObject").gameObject
    self.attrItemClone:SetActive(false)

    -- for i=1, 5 do
    --     local item = self.mainPanel.transform:FindChild(string.format("NowAttrPanel/AttrObject%s", i)).gameObject
    --     if i %2 == 0 then
    --         item.transform:FindChild("Image").gameObject:SetActive(true)
    --     end
    -- end

    self.startList = {}
    for i=1, 6 do
        local item = self.mainPanel.transform:FindChild(string.format("Star%s", i))
        self.startList[i] = item
    end

    local fun = function(effectView)
        local effectObject = effectView.gameObject

        self.starEffect = effectObject

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        self:update_star()
    end
    BaseEffectView.New({effectId = 20176, time = nil, callback = fun})

    local fun2 = function(effectView)
        local effectObject = effectView.gameObject

        self.washEffect = effectObject

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        effectObject.transform:SetParent(self.mainPanel.transform:FindChild("NowAttrPanel"))
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity

        effectObject:SetActive(false)
    end
    BaseEffectView.New({effectId = 20049, time = nil, callback = fun2})

    self.mainPanel.transform:FindChild("Normal/ItemNumText"):GetComponent(Text).text = ""
    self.slotNumExt = MsgItemExt.New(self.mainPanel.transform:FindChild("Normal/ItemNumText"):GetComponent(Text), 100, 14, 16.21)
    self.slotNumExt:SetData("")
    ----------------------------
    self:OnShow()
    self:ClearMainAsset()

end

function RideWashView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function RideWashView:OnShow()
    RideManager.Instance.OnUpdateOneRide:Add(self._update)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemChangeListener)

    self:update()
end

function RideWashView:OnHide()
    RideManager.Instance.OnUpdateOneRide:Remove(self._update)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemChangeListener)
end

function RideWashView:update()
    self:update_star()
    self:update_attr()
    self:update_probability()
    self:update_item()
end

function RideWashView:update_star()
    if self.model.cur_ridedata == nil then return end

    if self.starEffect ~= nil and self.starEffect.transform ~= nil then
        self.starEffect.transform:SetParent(self.startList[self.model.cur_ridedata.growth])
        self.starEffect.transform.localScale = Vector3(1, 1, 1)
        self.starEffect.transform.localPosition = Vector3(0, 0, -400)
        self.starEffect.transform.localRotation = Quaternion.identity
    end
end

function RideWashView:update_attr()
    if self.model.cur_ridedata == nil then return end

    local wash_data = DataMount.data_ride_reset[string.format("%s_%s", self.model.cur_ridedata.index, self.model.cur_ridedata.growth)]
    if wash_data == nil then
        return
    end

    self.mainPanel.transform:FindChild("NowAttrPanel/GrowthText"):GetComponent(Text).text = string.format("%s%%", wash_data.value/10)
    self.mainPanel.transform:FindChild("NowAttrPanel/GrowthIcon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.ride_texture, string.format("RideGrowth%s", tostring(self.model.cur_ridedata.growth)))

    -- 处理属性
    local attr_list = self.model:get_ride_all_attr_val(self.model.cur_ridedata.mount_base_id)
    -- 处理属性提升百分比
    local percent = 0
    local next_wash_data = DataMount.data_ride_reset[string.format("%s_%s", self.model.cur_ridedata.index, self.model.cur_ridedata.growth+1)]
    if next_wash_data ~= nil then
        percent = math.floor((next_wash_data.value - wash_data.value) / wash_data.value * 100)
    end
    -- 把速度加入列表
    local speed_attr = self.model.cur_ridedata.base.speed_attr[1]
    local item = self.mainPanel.transform:FindChild("NowAttrPanel/SpeedAttrObject").gameObject
    item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(speed_attr.attr_name))
    item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(speed_attr.val1)
    item.transform:FindChild("Icon"):GetComponent(Image).sprite
        = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[speed_attr.attr_name])))
    item.transform:FindChild("Image").gameObject:SetActive(true)

    -- table.insert(attr_list, { key = speed_attr.attr_name, value = speed_attr.val1 })
    -- for i=1, #attr_list do
    --     local item = self.mainPanel.transform:FindChild(string.format("NowAttrPanel/AttrObject%s", i)).gameObject
    --     item.gameObject:SetActive(true)

    --     item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
    --     item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].value)
    --     item.transform:FindChild("Icon"):GetComponent(Image).sprite
    --         = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))

    --     if attr_list[i].key == 12 or percent == 0 then
    --         item.transform:FindChild("PercentText").gameObject:SetActive(false)
    --     else
    --         item.transform:FindChild("PercentText").gameObject:SetActive(true)
    --         item.transform:FindChild("PercentText"):GetComponent(Text).text = string.format("%s%%", percent)
    --     end
    -- end

    -- if #attr_list < 5 then
    --     for i=#attr_list+1, 5 do
    --         self.mainPanel.transform:FindChild(string.format("NowAttrPanel/AttrObject%s", i)).gameObject:SetActive(false)
    --     end
    -- end

    for i=1, #attr_list do
        item = self.attrItemList[i]
        if item == nil then
            item = GameObject.Instantiate(self.attrItemClone)
            item:SetActive(true)
            item.transform:SetParent(self.mainPanel.transform:FindChild("NowAttrPanel/Mask/Panel"))
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            self.attrItemList[i] = item

            -- if i %2 == 0 then
            --     item.transform:FindChild("Image").gameObject:SetActive(true)
            -- end
        end

        item:SetActive(true)
        if string.len(KvData.GetAttrName(attr_list[i].key)) > 6 then
            item.transform:FindChild("ValueText").sizeDelta = Vector2(101, 27)
            item.transform:FindChild("ValueText").anchoredPosition = Vector2(97, 0)
        end
        item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
        item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].value)

        item.transform:FindChild("Icon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))

        item.transform:FindChild("PercentText").gameObject:SetActive(true)
        item.transform:FindChild("PercentText"):GetComponent(Text).text = string.format("%s%%", percent)
    end

    if #attr_list < #self.attrItemList then
        for i=#attr_list+1, #self.attrItemList do
            item = self.attrItemList[i]
            if item ~= nil then
                item:SetActive(false)
            end
        end
    end
end

function RideWashView:update_probability()
    if self.model.cur_ridedata == nil then
        return
    end

    self.maxAttr:SetActive(false)
    self.attr:SetActive(true)

    local wash_data = DataMount.data_ride_reset[string.format("%s_%s", self.model.cur_ridedata.index, self.model.cur_ridedata.growth)]
    if wash_data == nil then
        self.maxAttr:SetActive(true)
        self.attr:SetActive(false)
        return
    end

    local max_wash_data = DataMount.data_ride_reset[string.format("%s_%s", self.model.cur_ridedata.index, self.model.cur_ridedata.tmp_growth)]
    if max_wash_data == nil then
        self.maxAttr:SetActive(true)
        self.attr:SetActive(false)
        return
    end

    local list = {}
    local count = 0
    for i, data in ipairs(wash_data.rand_list) do
        for j, max_data in ipairs(max_wash_data.rand_list) do
            if data[1] == max_data[1] and data[2] ~= 0 and (self.model.cur_ridedata.growth == self.model.cur_ridedata.tmp_growth or max_data[1] > self.model.cur_ridedata.growth) then
                table.insert(list, data)
                count = count + data[2]
            end
        end
    end
    for i,v in ipairs(list) do
        list[i].rate = Mathf.Round(v[2]/count*100)
    end

    for i=1, 3 do
        self.mainPanel.transform:FindChild("NewAttrPanel/Item"..i).gameObject:SetActive(false)
    end

    for i=1, #list do
        local item = self.mainPanel.transform:FindChild("NewAttrPanel/Item"..i)
        item.gameObject:SetActive(true)

        item.transform:FindChild("NumText"):GetComponent(Text).text = string.format("<color='#13fc60'>%s%%</color>", list[i].rate)
        item:GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.ride_texture, string.format("RideGrowth%s", list[i][1]))
    end

    if #list == 0 then
        self.maxAttr:SetActive(true)
        self.attr:SetActive(false)
    end
end

function RideWashView:update_item()
    if self.model.cur_ridedata == nil then return end

    local wash_data = DataMount.data_ride_reset[string.format("%s_%s", self.model.cur_ridedata.index, self.model.cur_ridedata.growth)]
    local cost = wash_data.cost[1]
    self.max:SetActive(false)
    self.normal:SetActive(true)
    if cost == nil then
        self.max:SetActive(true)
        self.normal:SetActive(false)
        return
    end

    local itembase = BackpackManager.Instance:GetItemBase(cost[1])
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    self.itemSolt:SetAll(itemData)

    local num = BackpackManager.Instance:GetItemCount(cost[1])
    self.itemSolt:SetNum(num, cost[2])

    self.mainPanel.transform:FindChild("Normal/ItemNameText"):GetComponent(Text).text = itemData.name
    -- self.mainPanel.transform:FindChild("ItemNumText"):GetComponent(Text).text = string.format("%s/%s", num, cost[2])

    self.washButton:Layout({[cost[1]] = {need = cost[2]}}, function() self:OnClickWashButton() end, function(tab) self:AfterPriceBack(tab) end, {antofreeze = true})
end

function RideWashView:showWashEffect()
    if self.washEffect ~= nil then
        self.washEffect:SetActive(false)
        self.washEffect:SetActive(true)
    end
end

function RideWashView:AfterPriceBack(priceTab)
    for _,v in pairs(priceTab) do
        if v.allprice > 0 then
            self.slotNumExt:SetData(string.format("%s{assets_2, %s}", v.allprice, v.assets))
        else
            self.slotNumExt:SetData(string.format("<color='#ff0000'>%s</color>{assets_2, %s}", -v.allprice, v.assets))
        end
        self.slotNumExt.contentTrans.anchoredPosition = Vector2(-53 - self.slotNumExt.contentTrans.sizeDelta.x / 2, -14 + self.slotNumExt.contentTrans.sizeDelta.y / 2)
        break
    end
end

function RideWashView:OnClickWashButton()
    if self.model.cur_ridedata == nil then return end

    -- local wash_data = DataMount.data_ride_reset[string.format("%s_%s", self.model.cur_ridedata.index, self.model.cur_ridedata.growth)]
    -- if wash_data == nil then return end
    -- local cost = wash_data.cost[1]
    -- if cost == nil then return end
    -- local num = BackpackManager.Instance:GetItemCount(cost[1])
    -- if num < cost[2] then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("物品不足"))

    --     local itembase = BackpackManager.Instance:GetItemBase(cost[1])
    --     local itemData = ItemData.New()
    --     itemData:SetBase(itembase)
    --     local tipsData = { itemData = itemData, gameObject = self.mainPanel.transform:FindChild("Normal/WashButton").gameObject}
    --     TipsManager.Instance:ShowItem(tipsData)
    --     return
    -- else
        RideManager.Instance:Send17002(self.model.cur_ridedata.index)
    -- end
end