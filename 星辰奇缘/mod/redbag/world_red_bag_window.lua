WorldRedBagWindow  =  WorldRedBagWindow or BaseClass(BasePanel)

function WorldRedBagWindow:__init(model)
    self.name  =  "WorldRedBagWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.world_red_bag_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        ,{file = AssetConfig.guild_red_bag_bg2, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.windowId = WindowConfig.WinID.world_red_bag_win
    self.MainCon=nil
    self.imgHead = nil
    self.TxtName = nil
    self.TxtNum = nil
    self.TxtLink = nil
    self.BottomCon = nil
    self.ImgTitle = nil
    self.TxtValue1_has = nil
    self.TxtValue2_gx = nil
    self.MaskLayer = nil
    self.ScrollLayer = nil
    self.LayoutLayer = nil
    self.ItemMem = nil
    self.item_list = nil

    self.is_open = false
    self.loaders = {}

    return self
end

function WorldRedBagWindow:__delete()
    RedBagManager.Instance.OnUpdateRedBag:Fire()

    for _, v in pairs(self.loaders) do
        v:DeleteMe()
    end

    self.loaders = {}

    self.imgHead.sprite = nil
    self.MainCon=nil
    self.imgHead = nil
    self.TxtName = nil
    self.TxtNum = nil
    self.TxtLink = nil
    self.BottomCon = nil
    self.ImgTitle = nil
    self.TxtValue1_has = nil
    self.TxtValue2_gx = nil
    self.MaskLayer = nil
    self.ScrollLayer = nil
    self.LayoutLayer = nil
    self.ItemMem = nil
    self.item_list = nil

    self.is_open = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function WorldRedBagWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.world_red_bag_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldRedBagWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseRedBagUI() end)

    self.MainCon=self.transform:FindChild("MainCon").gameObject
    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_red_bag_bg2))
    UIUtils.AddBigbg(self.transform:FindChild("MainCon"):FindChild("bg2"), obj)
    obj.transform:SetAsFirstSibling()

    local close_btn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseRedBagUI() end)

    self.imgHead = self.MainCon.transform:FindChild("ImgHead"):FindChild("Img"):GetComponent(Image)

    self.TxtName = self.MainCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtNum = self.MainCon.transform:FindChild("TxtNum"):GetComponent(Text)
    self.TxtGift = self.MainCon.transform:FindChild("TxtGift"):GetComponent(Text)
    self.TxtNum2 = self.MainCon.transform:FindChild("TxtNum2"):GetComponent(Text)
    self.TxtLink = self.MainCon.transform:FindChild("TxtLink"):GetComponent(Button)
    self.BottomCon = self.MainCon.transform:FindChild("BottomCon").gameObject
    self.ImgTitle = self.BottomCon.transform:FindChild("ImgTitle").gameObject
    self.TxtValue1_has = self.ImgTitle.transform:FindChild("TxtValue1"):GetComponent(Text)
    self.TxtValue2_gx = self.ImgTitle.transform:FindChild("TxtValue2"):GetComponent(Text)
    self.ImgGift = self.MainCon.transform:FindChild("ImgGift")
    self.ImgGift2 = self.MainCon.transform:FindChild("ImgGift2")

    self.TxtNum2.gameObject:SetActive(false)
    self.ImgGift2.gameObject:SetActive(false)

    self.MaskLayer = self.BottomCon.transform:FindChild("MaskLayer").gameObject
    self.ScrollLayer = self.MaskLayer.transform:FindChild("ScrollLayer").gameObject
    self.LayoutLayer = self.ScrollLayer.transform:FindChild("LayoutLayer").gameObject
    self.ItemMem = self.LayoutLayer.transform:FindChild("ItemMem").gameObject
    self.ItemMem:SetActive(false)

    self.TxtLink.onClick:AddListener(function() self:on_click_link() end)
    self:update_view()

    self.is_open = true
end

function WorldRedBagWindow:on_click_link()
    local data = self.model.current_red_bag
    if #data.log < data.total then
        RedBagManager.Instance:Send18502(data.type, 1, data.total, data.title)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("该红包已经被领完"))
    end
end

function WorldRedBagWindow:update_view()

    local data = self.model.current_red_bag
    if data == nil then
        return
    end

    self.TxtGift.text = data.title

    self.imgHead.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(data.classes),tostring(data.sex)))


    self.TxtName.text = string.format(TI18N("%s的红包"), data.name)

    local showLink = false
    if data.type ~= 3 and data.rid == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
        self.TxtLink.gameObject:SetActive(true)
        showLink = true
    else
        self.TxtLink.gameObject:SetActive(false)
        showLink = false
    end

    local mine_data = nil
    for i=1,#data.log do
        local d = data.log[i]
        if d.grabid == RoleManager.Instance.RoleData.id and d.gplatform == RoleManager.Instance.RoleData.platform and d.gzone_id ==  RoleManager.Instance.RoleData.zone_id then
            mine_data = d
        end
    end

    if mine_data ~= nil then
        if mine_data.is_item == 0 then
            self.TxtNum.text = tostring(mine_data.value) --总额
            self.ImgGift:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.assets_type)
        else
            self.TxtNum.text = string.format("<color='%s'>%s</color>", ColorHelper.color[3], TI18N("红包头彩"))
            
            local instanceID = self.ImgGift.gameObject:GetInstanceID()
            local loader = self.loaders[instanceID]
            if loader == nil then
                loader = SingleIconLoader.New(self.ImgGift.gameObject)
                self.loaders[instanceID] = loader
            end
            loader:SetSprite(SingleIconType.Item, DataItem.data_get[23213].icon)

            self.TxtNum2.gameObject:SetActive(true)
            self.ImgGift2.gameObject:SetActive(true)
            self.TxtNum2.text = tostring(mine_data.value) --总额
            self.ImgGift2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.assets_type)

            if not showLink then
                self.TxtNum.transform.localPosition = Vector2(-24, 19)
                self.ImgGift.transform.localPosition = Vector2(95, 19)
                self.TxtNum2.transform.localPosition = Vector2(-148, 19)
                self.ImgGift2.transform.localPosition = Vector2(-30, 19)
            end
        end
    else
        self.TxtNum.text = tostring(0) --总额
        self.ImgGift:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.assets_type)
    end

    self.TxtValue1_has.text = string.format("%s/%s", (data.total - data.num), data.total)
    self.TxtValue2_gx.text = string.format("%s/%s", (data.amount - data.remain), data.amount)

    local log = data.log --抢夺记录
    local val_sort = function(a, b)
        return (a.is_item > b.is_item) or ((a.is_item == b.is_item) and (a.value > b.value))
    end

    table.sort(log, val_sort)

    self.item_list = {}

    for i=1, #log do
        local temp = log[i]
        local item = self:create_item(self.ItemMem)

        if data.num == 0 then
            if i == 1 then
                item.ImgIcon.gameObject:SetActive(true)
            end
        end

        self:set_item_data(item, temp)
        table.insert(self.item_list, item)
    end
end

function WorldRedBagWindow:create_item(originItem)
    local item = {}
    item.gameObject = GameObject.Instantiate(originItem)
    item.transform = item.gameObject.transform
    item.transform:SetParent(originItem.transform.parent)
    item.transform.localPosition = Vector3(0, 0, 0)
    item.transform.localScale = Vector3(1, 1, 1)

    item.gameObject:SetActive(true)

    item.ImgHead = item.transform:FindChild("ImgHead"):FindChild("Img"):GetComponent(Image)
    item.TxtName = item.transform:FindChild("TxtName"):GetComponent(Text)
    item.TxtTime = item.transform:FindChild("TxtTime"):GetComponent(Text)
    item.ImgIcon = item.transform:FindChild("ImgIcon"):GetComponent(Image)
    item.TxtGx = item.gameObject.transform:FindChild("TxtGx"):GetComponent(Text)
    item.ImgCup = item.gameObject.transform:FindChild("ImgCup"):GetComponent(Image)

    item.TxtGx2 = item.gameObject.transform:FindChild("TxtGx2"):GetComponent(Text)
    item.ImgCup2 = item.gameObject.transform:FindChild("ImgCup2"):GetComponent(Image)

    item.ImgIcon.gameObject:SetActive(false)

    return item
end

function WorldRedBagWindow:set_item_data(item, data)
    item.data = data
    item.ImgHead.sprite=PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(data.classes),tostring(data.sex)))

    item.TxtName.text = data.name

    local h = tonumber(os.date("%H", data.time))
    local m = tonumber(os.date("%M", data.time))
    -- local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(data.time)
    -- local h = my_hour >= 10 and my_hour or string.format("0%s",my_hour)
    -- local m = my_minute >= 10 and my_minute or string.format("0%s", my_minute)
    item.TxtTime.text = string.format("%s:%s", h, m)

    if data.is_item == 0 then
        item.TxtGx.text = tostring(data.value)
        item.ImgCup.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..self.model.current_red_bag.assets_type)

        item.TxtGx2.gameObject:SetActive(false)
        item.ImgCup2.gameObject:SetActive(false)
    else
        item.TxtGx.text = TI18N("红包头彩")

        local instanceID = item.ImgCup.gameObject:GetInstanceID()
        local loader = self.loaders[instanceID]
        if loader == nil then
            loader = SingleIconLoader.New(item.ImgCup.gameObject)
            self.loaders[instanceID] = loader
        end
        loader:SetSprite(SingleIconType.Item, DataItem.data_get[23213].icon)

        item.TxtGx2.text = tostring(data.value)
        item.ImgCup2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..self.model.current_red_bag.assets_type)

        item.TxtGx.transform.localPosition = Vector2(77.22498, 15)
        item.ImgCup.transform.localPosition = Vector2(147.1, 15)

        item.TxtGx2.gameObject:SetActive(true)
        item.ImgCup2.gameObject:SetActive(true)
    end
end
