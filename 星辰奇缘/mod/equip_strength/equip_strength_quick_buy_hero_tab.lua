EquipStrengthQuickBuyHeroTab = EquipStrengthQuickBuyHeroTab or BaseClass(BasePanel)

function EquipStrengthQuickBuyHeroTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_hero_stone_buy_win, type = AssetType.Main}
        ,{file = AssetConfig.stongbg, type = AssetType.Dep}
    }
    self.has_init = false
    return self
end

function EquipStrengthQuickBuyHeroTab:__delete()
    if self.my_slot ~= nil then
        self.my_slot:DeleteMe()
        self.my_slot = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthQuickBuyHeroTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_hero_stone_buy_win))
    self.gameObject.name = "EquipStrengthQuickBuyHeroTab"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self.panel = self.transform:FindChild("panel"):GetComponent(Button)
    self.MainCon = self.transform:FindChild("MainCon")

    self.MainCon:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")


    self.Stone3 = self.MainCon:FindChild("Stone3")
    self.TxtDesc = self.Stone3:FindChild("TxtDesc"):GetComponent(Text)
    self.SlotCon = self.Stone3:FindChild("SlotCon").gameObject
    self.TxtName = self.Stone3:FindChild("TxtName"):GetComponent(Text)
    self.Button = self.Stone3:FindChild("Button"):GetComponent(Button)
    self.Button.onClick:AddListener(function()
        local cost_num = self.stone_quick_buy_data.need_num
        local has_num = BackpackManager.Instance:GetItemCount(self.stone_quick_buy_data[4][1])
        if cost_num > has_num then
            local itemData = DataItem.data_get[self.stone_quick_buy_data[4][1]]
            local info = {itemData = itemData, gameObject = self.SlotCon.gameObject}
            TipsManager.Instance:ShowItem(info)
            self:on_close_myself()
            NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
        else
            self.stone_quick_buy_data.callback()
        end
    end)
    self.panel.onClick:AddListener(function() self:on_close_myself() end)

    self.on_click_buy_callback = function()
        self:on_close_myself()
    end

    self.my_slot = self:create_equip_slot(self.SlotCon)

    self.has_init = true

    self.on_prices_back = function(prices)
        self:price_back(prices)
    end

    self:update_content()
end

--更新显示
function EquipStrengthQuickBuyHeroTab:update_content()
    if self.has_init == false then
        return
    end

    self.stone_quick_buy_data = EquipStrengthManager.Instance.model.hero_stone_quick_buy_data

    self.TxtDesc.text = string.format("%s<color='#ff0000'>%s</color>%s", TI18N("镶嵌"), DataItem.data_get[self.stone_quick_buy_data[3]].name, TI18N("需要消耗："))
    local has_num = BackpackManager.Instance:GetItemCount(self.stone_quick_buy_data[4][1])
    local cell = ItemData.New()
    local itemData = DataItem.data_get[self.stone_quick_buy_data[4][1]] --设置数据
    cell:SetBase(itemData)
    self.my_slot:SetAll(cell, nil)
    self.my_slot:SetNum(has_num, self.stone_quick_buy_data.need_num)
    self.TxtName.text = itemData.name
end

--价格回来了
function EquipStrengthQuickBuyHeroTab:price_back(prices)

    local allprice = prices[self.stone_quick_buy_data[3]].allprice
    local price_str = ""
    if allprice >= 0 then
        price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[1], allprice)
    else
        price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], -allprice)
    end
    self.TxtProp.text = price_str
    self.ImgIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[prices[self.stone_quick_buy_data[3]].assets])
end

--为每个武器创建slot
function EquipStrengthQuickBuyHeroTab:create_equip_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end


--点击panel关闭自己
function EquipStrengthQuickBuyHeroTab:on_close_myself()
    -- self:Hiden()
    self.parent:CloseHeroStoneQuickBuy()
end
