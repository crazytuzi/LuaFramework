RewardBackConfirm = RewardBackConfirm or BaseClass(BasePanel)

function RewardBackConfirm:__init(model, parent)
    self.model = model
    self.name = "RewardBackConfirm"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.reward_back_confirm, type = AssetType.Main},
    }

    self.descString = TI18N("%s<color='#00ff00'>%s%%</color>奖励")
    self.priceString = TI18N("总价:{assets_2,%s}%s")
    self.priceString1 = TI18N("总价:{assets_2,%s}<color='#ff0000'>%s</color>")
    self.expString = "{assets_2,90010}%s"
    self.costString = TI18N("消耗:        <color='%s'>%s×%s</color>")

    self.count = 0
    self.slotList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RewardBackConfirm:__delete()
    self.OnHideEvent:Fire()
    if self.itemLoader ~= nil then
        self.itemLoader:DeleteMe()
        self.itemLoader = nil
    end
    if self.priceExt ~= nil then
        self.priceExt:DeleteMe()
        self.priceExt = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    self:AssetClearAll()
end

function RewardBackConfirm:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.reward_back_confirm))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    local main = t:Find("Main")
    main:Find("Title/I18N"):GetComponent(Text).text = TI18N("奖励找回")
    self.descExt = MsgItemExt.New(main:Find("Bg/Desc"):GetComponent(Text), 300, 18, 21)
    -- self.priceExt = MsgItemExt.New(main:Find("Price"):GetComponent(Text), 300, 18, 21)

    self.addBtn = main:Find("BuyCount/AddBtn"):GetComponent(Button)
    self.minusBtn = main:Find("BuyCount/MinusBtn"):GetComponent(Button)
    self.countText = main:Find("BuyCount/CountBg/Count"):GetComponent(Text)
    self.costText = main:Find("Text"):GetComponent(Text)
    self.itemLoader = SingleIconLoader.New(main:Find("Text/Item").gameObject)

    self.cancelBtn = main:Find("Cancel"):GetComponent(Button)
    self.confirmBtn = main:Find("Confirm"):GetComponent(Button)

    self.container = main:Find("Container")
    for i=1,2 do
        local tab = {}
        tab.transform = self.container:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(tab.transform, tab.slot.gameObject)
        tab.data = ItemData.New()
        self.slotList[i] = tab
    end

    self.itemLoader.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnShowItem(self.itemLoader.gameObject) end)
    self.costText.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnShowItem(self.costText.gameObject) end)

    self.addBtn.onClick:AddListener(function() self:AddOrMinus(1) end)
    self.minusBtn.onClick:AddListener(function() self:AddOrMinus(2) end)
    self.cancelBtn.onClick:AddListener(function() self:Hiden() end)
    self.confirmBtn.onClick:AddListener(function() self:OnConfirm() end)
    local btn = main:Find("Close"):GetComponent(Button)
    if btn ~= nil then
        btn.onClick:AddListener(function() self:Hiden() end)
    end
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
end

function RewardBackConfirm:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RewardBackConfirm:OnOpen()
    self.active_id = self.openArgs[1]  -- 必须传入
    self.type = self.openArgs[2]  -- 必须传入

    self:Reload()
end

function RewardBackConfirm:Reload()
    local protoData = self.model.rewardData.list[self.active_id]
    local baseData = DataRewardBack.data_active_data[self.active_id]
    local max = protoData.all - protoData.finish - protoData.back
    self.exp = 0
    self.reward = {}

    for _,v in ipairs(protoData.reward) do
        if v.type == KvData.assets.exp then
            if self.type == 1 then
                table.insert(self.reward, {base_id = v.type, num = v.value * baseData.perfect_exp / 100})
            else
                table.insert(self.reward, {base_id = v.type, num = v.value * baseData.normal_exp / 100})
            end
        else
            -- table.insert(self.reward, {base_id = v.type, num = v.value})
        end
    end

    local maxAssets = 0 -- 最大消耗货币
    local maxReceive = 10    -- 最大可找回次数(货币限制)
    local maxReceiveAssets = 0    -- 最大可找回次数消耗的货币(货币限制)
    local singlePrice = 0       -- 单价
    local myAssets = 0          -- 我的货币
    local baseData = DataRewardBack.data_active_data[self.active_id]

    if self.type == 1 then
        singlePrice = baseData.gold
        myAssets = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
        for _,v in ipairs(baseData.perfect_gift) do
            if #v == 2 then
                table.insert(self.reward, {base_id = v[1], num = v[2]})
            elseif #v == 4 then
                if RewardBackManager.Instance.model.rewardData.last_lev >= v[3] and RewardBackManager.Instance.model.rewardData.last_lev < v[4] then
                    table.insert(self.reward, {base_id = v[1], num = v[2]})
                end
            end
        end
        maxReceive = protoData.all - protoData.back - protoData.finish
    else
        singlePrice = baseData.coin
        myAssets = RoleManager.Instance.RoleData.coin
        for _,v in ipairs(baseData.normal_gift) do
            if #v == 2 then
                table.insert(self.reward, {base_id = v[1], num = v[2]})
            elseif #v == 4 then
                if RewardBackManager.Instance.model.rewardData.last_lev >= v[3] and RewardBackManager.Instance.model.rewardData.last_lev < v[4] then
                    table.insert(self.reward, {base_id = v[1], num = v[2]})
                end
            end
        end

        maxAssets = singlePrice * max
        maxReceive = max
        maxReceiveAssets = maxReceive * singlePrice
    end

    -- if maxAssets > myAssets then
    --     maxReceive = math.floor(myAssets / singlePrice)
    -- else
    --     maxReceive = max
    -- end

    self:SetNum(maxReceive)

    if self.type == 1 then
        self.descExt:SetData(string.format(self.descString, baseData.active_name, baseData.perfect_exp))
    else
        self.descExt:SetData(string.format(self.descString, baseData.active_name, baseData.normal_exp))
    end
    local size = self.descExt.contentTrans.sizeDelta
    local pos = self.descExt.contentTrans.anchoredPosition
    self.descExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

    local itemBaseData = nil
    if self.type == 1 then
        itemBaseData = DataItem.data_get[baseData.item[1][1]]
        -- self.priceExt:SetData(string.format(self.priceString, 29255, baseData.gold * self.count))
        self.costText.text = string.format(self.costString, ColorHelper.color[2], itemBaseData.name, math.ceil(self.count / baseData.item[1][2]))
    else
        itemBaseData = DataItem.data_get[KvData.assets.coin]
        -- self.priceExt:SetData(string.format(self.priceString, 90000, baseData.coin * self.count))
        self.costText.text = string.format(self.costString, ColorHelper.color[2], itemBaseData.name, self.count * baseData.coin)
    end
    self.costText.transform.sizeDelta = Vector2(math.ceil(self.costText.preferredWidth), 30)
    self.itemLoader:SetSprite(SingleIconType.Item, itemBaseData.icon)
end

function RewardBackConfirm:OnHide()
    self.count = 0
end

function RewardBackConfirm:SetNum(num)
    local baseData = DataRewardBack.data_active_data[self.active_id]
    local protoData = self.model.rewardData.list[self.active_id]
    local coin = RoleManager.Instance.RoleData.coin
    local gold = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold

    print(num)
    self.count = num
    self.countText.text = string.format("<color='#00ff00'>%s</color>/%s", self.count, protoData.all - protoData.finish - protoData.back)

    local itemBaseData = nil
    if self.type == 1 then
        itemBaseData = DataItem.data_get[baseData.item[1][1]]
        self.costNum = math.ceil(self.count / baseData.item[1][2])
        self.costText.text = string.format(self.costString, ColorHelper.color[2], itemBaseData.name, self.costNum)
    else
        itemBaseData = DataItem.data_get[KvData.assets.coin]
        self.costText.text = string.format(self.costString, ColorHelper.color[2], itemBaseData.name, self.count * baseData.coin)
    end
    self.costText.transform.sizeDelta = Vector2(math.ceil(self.costText.preferredWidth), 30)

    for i,v in ipairs(self.slotList) do
        v.gameObject:SetActive(false)
        v.slot.gameObject:SetActive(false)
    end

    for i,v in ipairs(self.reward) do
        if v ~= nil and self.slotList[i] ~= nil then
            if self.slotList[i].data.base_id ~= v.base_id then
                self.slotList[i].data:SetBase(DataItem.data_get[v.base_id])
                self.slotList[i].slot:SetAll(self.slotList[i].data)
            end
            self.slotList[i].slot:SetNum(v.num * self.count)
            self.slotList[i].slot.gameObject:SetActive(true)
            self.slotList[i].gameObject:SetActive(true)
        end
    end
    if #self.reward == 0 then
        self.slotList[1].gameObject:SetActive(true)
        self.container.sizeDelta = Vector2(60, 60)
    elseif #self.reward == 1 then
        self.container.sizeDelta = Vector2(60, 60)
    else
        self.container.sizeDelta = Vector2(150, 60)
    end
end

-- type == 1 为加，否则为减
function RewardBackConfirm:AddOrMinus(type)
    local protoData = self.model.rewardData.list[self.active_id]
    local max = protoData.all - protoData.finish - protoData.back
    if type == 1 then
        if self.count < max then
            self:SetNum(self.count + 1)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能找回更多"))
        end
    else
        if self.count > 1 then
            self:SetNum(self.count - 1)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("至少找回一次"))
        end
    end
end

function RewardBackConfirm:OnConfirm()
    if self.count > 0 then
        if self.type == 1 then
            local baseData = DataRewardBack.data_active_data[self.active_id]
            local baseId = baseData.item[1][1]
            local count = BackpackManager.Instance:GetItemCount(baseId)

            local backCount = self.count
            local backType = self.type
            local active_id = self.active_id

            if count < self.costNum then
                MarketManager.Instance:send12416({base_ids = {{base_id = baseId}}}, function(priceTab)
                    local all = 0
                    local world_lev = math.floor(RoleManager.Instance.world_lev / 5) * 5
                    for _,v in pairs(priceTab) do
                        if v.assets == KvData.assets.gold then
                            all = all + v.price * (self.costNum - count)
                        elseif v.assets == KvData.assets.gold_bind then
                            all = all + math.ceil(v.price / DataMarketGold.data_market_gold_ratio[world_lev].rate) * (self.costNum - count)
                        elseif v.assets == KvData.assets.coin then
                            all = all + math.ceil(v.price / DataMarketSilver.data_market_silver_ratio[world_lev].rate) * (self.costNum - count)
                        end
                    end
                    local confirmData = NoticeConfirmData.New()
                    local star_gold = RoleManager.Instance.RoleData.star_gold
                    if star_gold == 0 then
                        confirmData.content = string.format(TI18N("道具不足，是否消耗<color='#00ff00'>%s</color>{assets_2, 90002}补足？"), tostring(all))
                    elseif star_gold < all then
                        confirmData.content = string.format(TI18N("道具不足，是否消耗<color='#00ff00'>%s</color>{assets_2, 90026}<color='#00ff00'>%s</color>{assets_2, 90002}补足？"), tostring(star_gold), tostring(all - star_gold))
                    else
                        confirmData.content = string.format(TI18N("道具不足，是否消耗<color='#00ff00'>%s</color>{assets_2, 90026}补足？"), tostring(all))
                    end
                    confirmData.sureCallback = function() RewardBackManager.Instance:send18401(active_id, backCount, backType) end
                    NoticeManager.Instance:ConfirmTips(confirmData)
                end)
            else
                RewardBackManager.Instance:send18401(self.active_id, self.count, self.type)
            end
        else
            -- 普通找回直接发协议
            RewardBackManager.Instance:send18401(self.active_id, self.count, self.type)
        end
    end
    self:Hiden()
end

function RewardBackConfirm:OnShowItem(gameObject)
    if self.type == 1 then
        TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = DataItem.data_get[DataRewardBack.data_active_data[self.active_id].item[1][1]]})
    end
end

