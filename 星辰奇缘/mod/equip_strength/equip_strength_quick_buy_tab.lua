EquipStrengthQuickBuyTab = EquipStrengthQuickBuyTab or BaseClass(BasePanel)

function EquipStrengthQuickBuyTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_stone_buy_win, type = AssetType.Main}
    }
    self.has_init = false
    return self
end

function EquipStrengthQuickBuyTab:__delete()
    if self.my_slot ~= nil then
        self.my_slot:DeleteMe()
        self.my_slot = nil
    end

    if self.buy_btn ~= nil then
        self.buy_btn:DeleteMe()
        self.buy_btn = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthQuickBuyTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_stone_buy_win))
    self.gameObject.name = "EquipStrengthQuickBuyTab"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self.panel = self.transform:FindChild("panel"):GetComponent(Button)
    self.MainCon = self.transform:FindChild("MainCon")
    self.Stone3 = self.MainCon:FindChild("Stone3")
    self.SlotCon = self.Stone3:FindChild("SlotCon").gameObject
    self.TxtName = self.Stone3:FindChild("TxtName"):GetComponent(Text)
    self.TxtProp = self.Stone3:FindChild("TxtProp"):GetComponent(Text)
    self.ImgIcon = self.Stone3:FindChild("ImgIcon"):GetComponent(Image)
    self.Button = self.Stone3:FindChild("Button")

    self.panel.onClick:AddListener(function() self:on_close_myself() end)


    self.on_click_buy_callback = function()
        self:on_close_myself()
    end

    self.my_slot = self:create_equip_slot(self.SlotCon)

    self.has_init = true

    self.buy_btn = BuyButton.New(self.Button, TI18N("镶嵌"))
    self.buy_btn.key = "EquipStrengthAdvance"
    self.buy_btn.protoId = 10604
    self.buy_btn:Show()

    self.on_prices_back = function(prices)
        self:price_back(prices)
    end

    self:update_content()
end

--更新显示
function EquipStrengthQuickBuyTab:update_content()
    if self.has_init == false then
        return
    end

    self.stone_quick_buy_data = EquipStrengthManager.Instance.model.stone_quick_buy_data

    local cell = ItemData.New()
    local itemData = DataItem.data_get[self.stone_quick_buy_data[3]] --设置数据
    cell:SetBase(itemData)
    self.my_slot:SetAll(cell, nil)

    self.my_slot:SetNum(self.stone_quick_buy_data.need_num)

    local cfg_data = DataBacksmith.data_gem_base[self.stone_quick_buy_data[3]]
    self.TxtName.text = itemData.name
    -- self.TxtProp.text = string.format("%s+%s", KvData.attr_name_show[cfg_data.attr[1].attr_name], cfg_data.attr[1].val1)

    local buy_list = {}
    buy_list[self.stone_quick_buy_data[3]] = {need = self.stone_quick_buy_data.total_num}
    self.buy_btn:Layout(buy_list, self.stone_quick_buy_data.callback, self.on_prices_back)

    self.buy_btn:Set_btn_txt(self.stone_quick_buy_data.btn_txt)
end

--价格回来了
function EquipStrengthQuickBuyTab:price_back(prices)

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
function EquipStrengthQuickBuyTab:create_equip_slot(slot_con)
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
function EquipStrengthQuickBuyTab:on_close_myself()
    -- self:Hiden()
    self.parent:CloseStoneQuickBuy()
end
