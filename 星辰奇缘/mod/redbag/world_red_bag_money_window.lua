WorldRedBagMoneyWindow  =  WorldRedBagMoneyWindow or BaseClass(BasePanel)

function WorldRedBagMoneyWindow:__init(model)
    self.name  =  "WorldRedBagMoneyWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.world_red_bag_money_win, type  =  AssetType.Main}
    }

    self.windowId = WindowConfig.WinID.world_red_bag_money_win
    self.is_open = false

    self.selected_index = 0
    self.loaders = {}

    return self
end

function WorldRedBagMoneyWindow:__delete()
    for _, v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = {}
    self.is_open = false

    self.selected_index = 0
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function WorldRedBagMoneyWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.world_red_bag_money_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldRedBagMoneyWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseRedBagMoneyUI() end)
    -- self.

    self.MainCon = self.transform:FindChild("MainCon")
    local close_btn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseRedBagMoneyUI() end)

    self.item_list = {}
    for i=1,6 do
        local item = self.MainCon:FindChild(string.format("Item%s",i))
        local Checkmark = item:FindChild("Toggle"):FindChild("Background"):FindChild("Checkmark").gameObject
        local index = i
        item:GetComponent(Button).onClick:AddListener(function()
            --勾选，同时关闭界面
            -- print(index)
            if self.selected_index ~= 0 then
                return
            end
            self.selected_index = index
            self.model:update_red_bag_set_win(index)
            Checkmark:SetActive(true)
            LuaTimer.Add(300, function() self.model:CloseRedBagMoneyUI() end )
        end)
        table.insert(self.item_list, item)
    end

    self:update_cfg_data()
end

--对界面设置数据
function WorldRedBagMoneyWindow:update_cfg_data()
    local redbag_data = {}
    if self.openArgs ~= nil and #self.openArgs > 0 then
        for k,v in pairs(DataRedPacket.data_red_packet) do
            if v.type == self.openArgs[1] then
                redbag_data[v.lev] = v
            end
        end
    end

    for i=1,#self.item_list do
        local item = self.item_list[i]

        local cfg_data = redbag_data[i]
        if cfg_data == nil then
            item.gameObject:SetActive(false)
        else
            item.gameObject:SetActive(true)

            local txtStone = item:FindChild("TxtNum"):GetComponent(Text)
            local txtCoin = item:FindChild("TxtCost"):GetComponent(Text)
            local imgCoin = item:FindChild("ImgCoin")
            local imgStone = item:FindChild("ImgStone")

            txtStone.text = string.format("%s=", cfg_data.cost[1][2])
            txtCoin.text = string.format("%s%s", cfg_data.val/10000, TI18N("万"))

            if GlobalEumn.CostTypeIconName[cfg_data.cost[1][1]] ~= nil then
                imgStone:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[cfg_data.cost[1][1]])
            else
                local instanceID = imgStone.gameObject:GetInstanceID()
                local loader = self.loaders[instanceID]
                if loader == nil then
                    loader = SingleIconLoader.New(imgStone.gameObject)
                    self.loaders[instanceID] = loader
                end
                loader:SetSprite(SingleIconType.Item, DataItem.data_get[cfg_data.cost[1][1]].icon)
            end
            if GlobalEumn.CostTypeIconName[cfg_data.assets] ~= nil then
                imgCoin:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[cfg_data.assets])
            else
                local instanceID = imgCoin.gameObject:GetInstanceID()
                local loader = self.loaders[instanceID]
                if loader == nil then
                    loader = SingleIconLoader.New(imgCoin.gameObject)
                    self.loaders[instanceID] = loader
                end
                loader:SetSprite(SingleIconType.Item, DataItem.data_get[cfg_data.assets].icon)
            end

            local txt_stone_rect = txtStone:GetComponent(RectTransform)
            local txt_stone_anchor = txt_stone_rect.anchoredPosition
            local imgCoin_rect = imgCoin:GetComponent(RectTransform)
            local txt_coin_rect = txtCoin:GetComponent(RectTransform)
            txt_stone_rect.sizeDelta = Vector2(txtStone.preferredWidth+5, 30)
            txt_coin_rect.sizeDelta = Vector2(txtCoin.preferredWidth+5, 30)
            imgCoin_rect.anchoredPosition = Vector2(txt_stone_anchor.x+txt_stone_rect.rect.width - 3, -2)
            txt_coin_rect.anchoredPosition = Vector2(imgCoin_rect.anchoredPosition.x+imgCoin_rect.rect.width - 3, -3)
        end
    end
end