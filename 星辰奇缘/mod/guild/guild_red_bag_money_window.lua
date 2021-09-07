GuildRedBagMoneyWindow  =  GuildRedBagMoneyWindow or BaseClass(BasePanel)

function GuildRedBagMoneyWindow:__init(model)
    self.name  =  "GuildRedBagMoneyWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.guild_red_bag_money_win, type  =  AssetType.Main}
    }

    self.windowId = WindowConfig.WinID.guild_red_bag_money_win
    self.is_open = false

    self.selected_index = 0

    return self
end

function GuildRedBagMoneyWindow:__delete()
    self.is_open = false

    self.selected_index = 0
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildRedBagMoneyWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_red_bag_money_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "GuildRedBagMoneyWindow"
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
function GuildRedBagMoneyWindow:update_cfg_data()
    for i=1,#self.item_list do
        local item = self.item_list[i]
        local txtStone = item:FindChild("TxtNum"):GetComponent(Text)
        local txtCoin = item:FindChild("TxtCost"):GetComponent(Text)
        local imgCoin = item:FindChild("ImgCoin")

        local cfg_data = DataGuild.data_get_redbag_data[i]
        txtStone.text = string.format("%s=", cfg_data.loss_num)
        txtCoin.text = string.format("%s%s", cfg_data.amount/10000, TI18N("万"))

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