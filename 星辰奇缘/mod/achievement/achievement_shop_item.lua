AchievementShopItem = AchievementShopItem or BaseClass()

function AchievementShopItem:__init(parent, model, gameObject, callback)
    self.parent = parent
    self.model = model
    self.gameObject = gameObject
    self.callback = callback
    self.mgr = ShopManager.Instance

    local t = gameObject.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.priceText = t:Find("PriceBg/Price"):GetComponent(Text)
    self.currencyImage = t:Find("PriceBg/Currency"):GetComponent(Image)
    -- self.iconImage = t:Find("IconBg/Icon"):GetComponent(Image)
    self.selectObj = t:Find("Select").gameObject
    -- self.tipsImage = t:Find("TipsLabel"):GetComponent(Image)
    -- self.tipsText = t:Find("TipsLabel/Text"):GetComponent(Text)
    -- self.discountObj = t:Find("Discount").gameObject
    -- self.discountText = t:Find("Discount/Discount"):GetComponent(Text)
    -- self.soldoutObj = t:Find("SoldoutImage").gameObject
    self.numText = t:Find("Num"):GetComponent(Text)
    self.btn = gameObject:GetComponent(Button)
    self.iconLoader = nil
    self.numText.gameObject:SetActive(true)
end

function AchievementShopItem:__delete()
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    self.currencyImage = nil
    self.iconImage = nil
end

function AchievementShopItem:SetData(data, index) -- data 是协议数据
    local shopData = DataAchieveShop.data_list[data.id] -- 成就商店表数据

    local model = self.model
    local currency = 90008

    if shopData.goods_type == 1 then
        self.iconImage = self.gameObject.transform:Find("IconBg/Icon"):GetComponent(Image)
        self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.zonestyleicon, tostring(shopData.source_id))

        if ZoneManager.Instance.theme == data.id then
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(true)
        else
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(false)
        end
        if data.state == 0 then
            self.iconImage.color = Color(156/255, 156/255, 156/255, 1)
        else
            self.iconImage.color = Color(1, 1, 1)
        end
    elseif shopData.goods_type == 2 then
        self.iconImage = self.gameObject.transform:Find("IconBg/Icon"):GetComponent(Image)
        self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.photo_frame, string.format("icon%s", shopData.source_id))

        if ZoneManager.Instance.Frame == data.id then
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(true)
        else
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(false)
        end

        if data.state == 0 then
            self.iconImage.color = Color(156/255, 156/255, 156/255, 1)
        else
            self.iconImage.color = Color(1, 1, 1)
        end
    elseif shopData.goods_type == 3 then
        self.iconImage = self.gameObject.transform:Find("IconBg/Icon"):GetComponent(Image)
        self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(shopData.source_id))
        self.numText.gameObject:SetActive(false)

        -- local mark = false
        -- for k,v in pairs(ZoneManager.Instance.badges) do
        --     if v.badge_id == data.id then
        --         mark = true
        --     end
        -- end

        -- if mark then
        --     self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(true)
        -- else
        --     self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(false)
        -- end

        local badge_data = self.model:getBadgeDataById(shopData.id)
        if badge_data ~= nil then
            if badge_data.star == 0 then
                self.gameObject.transform:FindChild("Star").gameObject:SetActive(false)
            else
                self.gameObject.transform:FindChild("Star").gameObject:SetActive(true)
                local star = badge_data.star + 1
                -- for i=1,star - 1 do
                --     self.gameObject.transform:FindChild("Star/"..i).gameObject:SetActive(true)
                -- end
                if star < 4 then
                    for i=star,3 do
                        self.gameObject.transform:FindChild("Star/"..i).gameObject:SetActive(false)
                    end
                end
            end
        else
            self.gameObject.transform:FindChild("Star").gameObject:SetActive(false)
        end

        if data.state == 0 then
            self.iconImage.color = Color(156/255, 156/255, 156/255, 1)
            for i=1,3 do
                self.gameObject.transform:FindChild("Star/"..i):GetComponent(Image).color = Color(156/255, 156/255, 156/255, 1)
            end
        else
            self.iconImage.color = Color(1, 1, 1)
            for i=1,3 do
                self.gameObject.transform:FindChild("Star/"..i):GetComponent(Image).color = Color(1, 1, 1)
            end
        end
    elseif shopData.goods_type == 4 then
        local cfg_data
        for i,v in ipairs(DataFriendZone.data_bubble) do
            if v.id == data.source_id then
                cfg_data = v
            end
        end
        if cfg_data ~= nil then
            local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.color)
            self.gameObject.transform:Find("Image"):GetComponent(Image).color = Color(r/255,g/255,b/255)
            if cfg_data.outcolor ~= "" then
                local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.outcolor)

                if self.gameObject.transform:Find("Image").transform:GetComponent(Outline) == nil then
                    self.gameObject.transform:Find("Image").gameObject:AddComponent(Outline)
                end
                self.gameObject.transform:Find("Image").transform:GetComponent(Outline).effectColor = Color(r/255,g/255,b/255)
                self.gameObject.transform:Find("Image").transform:GetComponent(Outline).effectDistance = Vector2(3, -3)
                self.gameObject.transform:Find("Image").transform:GetComponent(Outline).enabled = true
            end
            for i,v in ipairs(cfg_data.location) do


                local spriteid = tostring(v[1])
                local x = v[2]*0.7
                local y = v[3]
                local item = self.gameObject.transform:Find("Image"):Find(tostring(i))
                local sprite = PreloadManager.Instance:GetSprite(AssetConfig.bubble_icon, spriteid)
                local img = item.transform:GetComponent(Image)
                img.sprite = sprite
                img:SetNativeSize()
                item.transform.anchoredPosition = Vector2(x,y)
                if cfg_data.id == 30016 and i == 1 then
                    item.transform.sizeDelta = Vector2(50,60)
                end
                item.gameObject:SetActive(true)
            end
        end

        if ChatManager.Instance.model.bubble_id == data.id then
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(true)
        else
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(false)
        end
    elseif shopData.goods_type == 5 then
        self.iconImage = self.gameObject.transform:Find("IconBg/Icon"):GetComponent(Image)
        if shopData.source_id == 30197 then
            -- 这个资源当时忘记放了，特殊处理了，后面谁看到就检查一下这个资源，在的话就删了这段代码
            if self.iconLoader == nil then
                self.iconLoader = SingleIconLoader.New(self.iconImage.gameObject)
            end
            self.iconLoader:SetSprite(SingleIconType.Item, 23228)
            if data.state == 0 then
                self.iconLoader:SetIconColor(Color(156/255, 156/255, 156/255, 1))
            else
                self.iconLoader:SetIconColor(Color(1, 1, 1))

            end
            -- self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.teammark_icon, tostring(shopData.source_id))
        else
            self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.teammark_icon, tostring(shopData.source_id))
        end


        if TeamManager.Instance.model.team_mark == data.id then
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(true)
        else
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(false)
        end

        if data.state == 0 then
            self.iconImage.color = Color(156/255, 156/255, 156/255, 1)
        else
            self.iconImage.color = Color(1, 1, 1)
        end
    elseif shopData.goods_type == 6 then
        self.iconImage = self.gameObject.transform:Find("IconBg/Icon"):GetComponent(Image)
        self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.chat_prefix, tostring(shopData.source_id))
        self.iconImage:SetNativeSize()

        if ChatManager.Instance.model.prefix_id == data.id then
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(true)
        else
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(false)
        end
        if data.state == 0 then
            self.iconImage.color = Color(156/255, 156/255, 156/255, 1)
        else
            self.iconImage.color = Color(1, 1, 1)
        end
    elseif shopData.goods_type == 8 then
        --足迹
        --BaseUtils.dump(shopData,"shopData__")
        self.iconImage = self.gameObject.transform:Find("IconBg/Icon"):GetComponent(Image)
        self.iconImage.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.footmark_icon, tostring(shopData.source_id))
        self.iconImage:SetNativeSize()

        --是否使用中
        if RoleManager.Instance.foot_mark_id == data.id then
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(true)
        else
            self.gameObject.transform:Find("TipsLabel").gameObject:SetActive(false)
        end
        if data.state == 0 then
            --未购买或未激活
            self.iconImage.color = Color(156/255, 156/255, 156/255, 1)
        else
            self.iconImage.color = Color(1, 1, 1)
        end
    end

    self.nameText.text = shopData.name
    self.selectObj:SetActive(false)
    self.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..currency)

    self.priceText.text = tostring(shopData.price)

    self.data = data
    self.currency = currency
    self.price = shopData.price

    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function()
        self:onClick()
        -- if model.selectObj ~= nil then
        --     model.selectObj:SetActive(false)
        -- end
        -- model.selectItem = self.gameObject
        -- model.selectObj = self.selectObj
        -- model.selectObj:SetActive(true)
        -- model.selectedInfo = data
        -- model.selectNum = 1
        -- model.infoCurrencyType = currency
        -- model.uniPrice = shopData.price
        -- self.mgr.onUpdateCurrency:Fire()
        -- if self.callback ~= nil then
        --     self.callback(data)
        -- end
    end)

    if model.selectedInfo ~= nil and model.selectedInfo.id == data.id then
        model.selectObj:SetActive(true)
        if self.callback ~= nil then
            self.callback(data)
        end
    end

    self:SetActive(true)
end

function AchievementShopItem:SetActive(bool)
    self.gameObject:SetActive(bool == true)
end

function AchievementShopItem:onClick()

    local model = self.model
    if model.selectObj ~= nil then
        model.selectObj:SetActive(false)
    end
    model.selectItem = self.gameObject
    model.selectObj = self.selectObj
    model.selectObj:SetActive(true)
    model.selectedInfo = self.data
    model.selectNum = 1
    model.infoCurrencyType = self.currency
    model.uniPrice = self.price
    self.mgr.onUpdateCurrency:Fire()
    if self.callback ~= nil then
        self.callback(self.data)
    end
end