-- 物品窗口
CombatItemPanel = CombatItemPanel or BaseClass()

function CombatItemPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.assetWrapper = self.mainPanel.combatMgr.assetWrapper
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.combat_itempanel_path))
    self.transform = self.gameObject.transform

    UIUtils.AddUIChild(self.mainPanel.mixPanel.gameObject, self.gameObject)
 
    self.LeftPanel = self.transform:FindChild("Window/LeftPanel").gameObject
    self.RightPanel = self.transform:FindChild("Window/RightPanel").gameObject
    self.UseButton = self.transform:FindChild("Window/UseButton").gameObject
    self.UseButtonText = self.transform:FindChild("Window/UseButton/Text"):GetComponent(Text)
    self.BuyButton = self.transform:FindChild("Window/BuyButton").gameObject
    self.MarketButton = self.transform:Find("Window/MarketButton").gameObject
    self.LeiTaiButton = self.transform:Find("Window/LeiTaiButton").gameObject
    self.CloseBut = self.transform:FindChild("Window/CloseBut").gameObject
    self.Mash = self.transform:FindChild("Panel").gameObject

    self.LText = self.LeftPanel.transform:FindChild("Text").gameObject
    self.LText.transform:GetComponent(Text).text = TI18N("战斗中可使用物品，一场战斗中最多可使用10次道具。\n(爵位挑战中限制为3次)")
    self.ItemInfoPanel = self.LeftPanel.transform:FindChild("ItemInfoPanel").gameObject
    self.UseCount = self.LeftPanel.transform:FindChild("Count").gameObject

    self.RContainer = self.RightPanel.transform:FindChild("Mash/Container").gameObject
    self.RItemSlot = self.RightPanel.transform:FindChild("Mash/Container/ItemSlot").gameObject

    self.Scrollrect = self.RightPanel.transform:Find("Mash"):GetComponent(ScrollRect)

    self.CloseBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseBtnClick() end )
    self.UseButton:GetComponent(Button).onClick:AddListener(function() self:OnUseButClick() end )
    self.BuyButton:GetComponent(Button).onClick:AddListener(function() self:OnBuyButClick() end )
    self.MarketButton:GetComponent(Button).onClick:AddListener(function() MarketManager.Instance:OpenWindow({2,3}) end )
    self.LeiTaiButton:GetComponent(Button).onClick:AddListener(function() NpcshopManager.Instance:OpenWindow({3}) end )
    self.Mash:GetComponent(Button).onClick:AddListener(function() self:OnCloseBtnClick() end )

    self.data10731 = nil
    self.gameObject:SetActive(false)

    self.selectItemId = 0
    self.selectItemSlot = nil
    self.UseButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    self.UseButtonText.color = Color.white
    -- self.BuyButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    self.updatecb = function()
        self:RefreshItemPanel()
    end
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updatecb)
    self.slotlist = {}

    self:ShowSpecialBtn()
end

function CombatItemPanel:__delete()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updatecb)
end

function CombatItemPanel:SetData10731(data)
    self.data10731 = data
end

function CombatItemPanel:OnCloseBtnClick()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updatecb)
    self.gameObject:SetActive(false)
end

function CombatItemPanel:Show()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updatecb)
    UIUtils.AddUIChild(self.mainPanel.extendPanel.gameObject, self.gameObject)
    self.LText:SetActive(true)
    self.ItemInfoPanel:SetActive(false)
    self:RefreshItemPanel()
    self.gameObject:SetActive(true)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updatecb)
end

function CombatItemPanel:RefreshItemPanel()
    self.UseButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    self.UseButtonText.color = Color.white
    -- self.BuyButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    self.selectItemSlot = nil
    CombatUtil.DestroyChildActive(self.RContainer)
    local itemList = BackpackManager.Instance:GetItemByType(118)
    -- print("战斗类型：")
    -- print(self.mainPanel.combatMgr.combatType)
    if self.mainPanel.combatMgr.combatType == 6 or self.mainPanel.combatMgr.combatType == 115 or self.mainPanel.combatMgr.combatType == 40 or self.mainPanel.combatMgr.combatType == 58 then
        -- print("进来看看")
        local spitemList = BackpackManager.Instance:GetItemByType(134)
        -- BaseUtils.dump(spitemList)
        for k,v in pairs(spitemList) do
            table.insert(itemList, v)
        end
    end

    -- BaseUtils.dump(itemList)
    if self.data10731 == nil then
        return
    end
    local useNum = self.data10731.use_item_num
    itemList = self:GroupItemByBaseid(itemList)
    -- BaseUtils.dump(itemList)
    self.UseCount:GetComponent(Text).text = tostring(useNum) .. "/10"
    if self.mainPanel.combatMgr.combatType == 43 then
        self.UseCount:GetComponent(Text).text = tostring(useNum) .. "/3"
    elseif self.mainPanel.combatMgr.combatType == 60 then
        self.UseCount:GetComponent(Text).text = tostring(useNum) .. "/3"
    end
    local itemnum = 0
    for _, data in pairs(itemList) do
        local backdata = data
        backdata = self:GroupItemByStep(backdata)
        for i,v in pairs(backdata) do
            local itemId = v.base_id
            -- print(i,v)
            local quantity = v.quantity
            local step = nil
            if backdata ~= nil then
                step = v.step
            end
            if quantity > 0 then
                local itemSlot = self:SetItemSlot(self.RContainer, v, quantity)
                local button = itemSlot:GetComponent(Button)
                button.onClick:AddListener(function(_go) self:OnItemSlotClick(v.id, itemId, itemSlot, step) end)
            end
            itemnum = itemnum + 1
        end
    end
    if #itemList < 12 then
        for i = #itemList + 1, 12 do
            local itemBg = GameObject.Instantiate(self.RItemSlot)
            itemBg.transform:SetParent(self.RContainer.transform)
            itemBg.transform.localScale = Vector3(1, 1, 1)
            itemBg.name = "itemBg"
            itemBg:SetActive(true)
        end
    end
    if itemnum < 1 then
        self.BuyButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    else
        self.BuyButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    end
end

function CombatItemPanel:SetItemSlot(parent, base, num)
    local slot = ItemSlot.New()
    table.insert(self.slotlist, slot)
    local extra = {inbag = true}
    slot.noTips = true
    slot:SetAll(base, extra)
    local tempData = DataMarketSilver.data_market_silver_item[base.base_id]
    if tempData ~= nil and (tempData.type == 2 or tempData.type == 4) and base.step ~= 0 then
        slot:SetStep(base.step)
    end
    -- slot:SetNotips()
    if base.id == self.mainPanel.currSelectItem then
        local tag = slot.transform:Find("Tag")
        tag:Find("Text"):GetComponent(Text).text = TI18N("已选")
        tag.gameObject:SetActive(true)
    end
    UIUtils.AddUIChild(parent, slot.gameObject)

    return slot.gameObject
end

function CombatItemPanel:OnItemSlotClick(BackpackID, itemId, itemSlot, step)
    self.UseButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    self.UseButtonText.color = Color(178/255, 110/255, 49/255)
    self.BuyButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    self.selectItemId = BackpackID
    if self.selectItemSlot ~= nil then
        self.selectItemSlot.transform:FindChild("SelectImg").gameObject:SetActive(false)
    end
    self.selectItemSlot = itemSlot
    self.selectItemSlot.transform:FindChild("SelectImg").gameObject:SetActive(true)
    local itemData = DataItem.data_get[itemId]
    -- BaseUtils.dump(itemData)
    if itemData ~= nil then
        self.LText:SetActive(false)
        self.ItemInfoPanel:SetActive(true)
        -- self.ItemInfoPanel.transform:FindChild("ItemBg/ItemIcon"):GetComponent(Image).sprite = sprite
        self.ItemInfoPanel.transform:FindChild("Name"):GetComponent(Text).text = itemData.name
        local ddesc = itemData.desc
        if step ~= nil and step ~= 0 then
            -- time_limit_text.text = string.format("品阶:%s", step)
            local step_data = DataSkillLife.data_fight_effect[string.format("%s_%s", itemData.id, step)]
            if step_data ~= nil then
                ddesc = string.gsub(ddesc, "%[skill_life1%]", tostring(step_data.args[1]))
                ddesc = string.gsub(ddesc, "%[skill_life2%]", tostring(step_data.args[2]))
            end
        else
            -- time_limit_text.text = ""
            ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
        end
        self.ItemInfoPanel.transform:FindChild("Desc"):GetComponent(Text).text = ddesc
    end
end

function CombatItemPanel:OnUseButClick()
    if self.selectItemId ~= 0 then
        self.gameObject:SetActive(false)
        self.mainPanel:OnSkillItemIconClick(self.selectItemId)
        -- self.mainPanel.currSelectItem = self.selectItemId
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择物品"))
    end
end

function CombatItemPanel:GroupItemByBaseid(list)
    local newlist = {}
    for k,v in pairs(list) do
        if newlist[v.base_id] ~= nil then
            -- newlist[v.base_id].quantity = newlist[v.base_id].quantity + v.quantity
            table.insert(newlist[v.base_id],v)
        else
            newlist[v.base_id] = {v}
        end
    end
    return newlist
end

function CombatItemPanel:GroupItemByStep(list)
    local newlist = {}
    for i,v in ipairs(list) do
        if newlist[v.step] ~= nil then
            newlist[v.step].quantity = newlist[v.step].quantity + v.quantity
        else
            newlist[v.step] = v
        end
    end
    return newlist
end

function CombatItemPanel:OnBuyButClick()
    -- print(self.mainPanel.combatMgr.combatType)
    if self.mainPanel.combatMgr.combatType == 6 or self.mainPanel.combatMgr.combatType == 115 or self.mainPanel.combatMgr.combatType == 40 or self.mainPanel.combatMgr.combatType == 58 then
        NpcshopManager.Instance:OpenWindow({3})
    else
        MarketManager.Instance:OpenWindow({2,3})
    end
end

function CombatItemPanel:ShowSpecialBtn()
    if self.mainPanel.combatMgr.combatType == 40 or self.mainPanel.combatMgr.combatType == 58 then
        self.BuyButton.gameObject:SetActive(false)
        self.MarketButton.gameObject:SetActive(true)
        self.LeiTaiButton.gameObject:SetActive(true)
    else
        self.BuyButton.gameObject:SetActive(true)
        self.MarketButton.gameObject:SetActive(false)
        self.LeiTaiButton.gameObject:SetActive(false)
    end
end