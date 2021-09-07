RewardBackItem = RewardBackItem or BaseClass()

function RewardBackItem:__init(gameObject, assetWrappet)
    self.gameObject = gameObject
    self.assetWrappet = assetWrappet
    local t = gameObject.transform
    self.transform = t

    self.titleString = TI18N("%s(可找回<color='#ffff00'>%s</color>次)")
    self.priceString = TI18N("单价{assets_2,%s}%s")
    self.btnString2 = TI18N("普通找回")
    self.btnString1 = TI18N("完美找回")
    self.btnString3 = TI18N("已找回")
    self.priceOverString = TI18N("%s万")

    self.titleText = t:Find("Title/Text"):GetComponent(Text)
    self.scrollTrans = t:Find("Scroll")
    self.scroll = self.scrollTrans:GetComponent(ScrollRect)
    self.layout = LuaBoxLayout.New(t:Find("Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.priceExt = MsgItemExt.New(t:Find("Ext"):GetComponent(Text), 200, 16, 18)
    self.expText = t:Find("TextBg/Text"):GetComponent(Text)
    self.maskImage = t:Find("Mask"):GetComponent(Image)
    self.expBox = t:Find("TextBg")
    self.button = t:Find("Button"):GetComponent(Button)
    self.buttonExt = MsgItemExt.New(t:Find("Button/Text"):GetComponent(Text), 200, 18, 21)

    self.slotList = {}
end

function RewardBackItem:__delete()
    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v.data:DeleteMe()
                v.slot:DeleteMe()
            end
        end
    end

    if self.priceExt ~= nil then
        self.priceExt:DeleteMe()
        self.priceExt = nil
    end
    if self.buttonExt ~= nil then
        self.buttonExt:DeleteMe()
        self.buttonExt = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.maskImage ~= nil then
        self.maskImage.sprite = nil
    end
end

function RewardBackItem:SetData(data)
    local datalist = {}     -- 存放除了经验之外的一切奖励
    local exp = 0
    local protoData = data.data
    local baseData = DataRewardBack.data_active_data[protoData.active_id]

    self.data = data.data
    self.type = data.type

    for _,v in ipairs(protoData.reward) do
        if v.type ~= KvData.assets.exp then
            -- table.insert(datalist, {base_id = v.type, num = v.value})
        else
            exp = exp + v.value
        end
    end

    if data.type == 1 then  -- 完美找回
        exp = math.floor(exp * baseData.perfect_exp / 100)
        for _,v in ipairs(baseData.perfect_gift) do
            if #v == 2 then
                table.insert(datalist, {base_id = v[1], num = v[2]})
            elseif #v == 4 then
                if RewardBackManager.Instance.model.rewardData.last_lev >= v[3] and RewardBackManager.Instance.model.rewardData.last_lev < v[4] then
                    table.insert(datalist, {base_id = v[1], num = v[2]})
                end
            end
        end
        self.priceExt.contentTrans.gameObject:SetActive(false)
        self.buttonExt:SetData(self.btnString1)
        self.maskImage.sprite = self.assetWrappet:GetSprite(AssetConfig.bible_textures, "Percent100")
        self.button.transform.anchoredPosition = Vector2(196.1, 0)
    else                    -- 普通找回
        exp = math.floor(exp * baseData.normal_exp / 100)
        for _,v in ipairs(baseData.normal_gift) do
            if #v == 2 then
                table.insert(datalist, {base_id = v[1], num = v[2]})
            elseif #v == 4 then
                if RewardBackManager.Instance.model.rewardData.last_lev >= v[3] and RewardBackManager.Instance.model.rewardData.last_lev < v[4] then
                    table.insert(datalist, {base_id = v[1], num = v[2]})
                end
            end
        end
        local str = nil
        if baseData.coin > 9999 then
            str = string.format(self.priceOverString, tostring(math.ceil(baseData.coin / 10000)))
        else
            str = tostring(baseData.coin)
        end
        self.priceExt.contentTrans.gameObject:SetActive(true)
        self.priceExt:SetData(string.format(self.priceString, "90000", str))
        self.buttonExt:SetData(self.btnString2)
        self.maskImage.sprite = self.assetWrappet:GetSprite(AssetConfig.bible_textures, "Percent60")
        self.button.transform.anchoredPosition = Vector2(196.1, -13.4)
    end
    local size = self.priceExt.contentTrans.sizeDelta
    self.priceExt.contentTrans.anchoredPosition = Vector2(464.93 - size.x / 2, 32)
    self.expText.text = exp

    local max = protoData.all - protoData.finish - protoData.back

    self.titleText.text = string.format(self.titleString, baseData.active_name or "", max)
    if max == 0 then
        self.buttonExt:SetData(self.btnString3)
    end

    self.layout:ReSet()

    self.reward = datalist[1]
    for i,v in ipairs(datalist) do
        local tab = self.slotList[i]
        if tab == nil then
            tab = {}
            tab.data = ItemData.New()
            tab.slot = ItemSlot.New()
            self.slotList[i] = tab
        end
        self.layout:AddCell(tab.slot.gameObject)
        tab.data:SetBase(DataItem.data_get[v.base_id])
        tab.slot:SetAll(tab.data)
        tab.slot:SetNum(v.num)
    end
    for i=#datalist + 1, #self.slotList do
        self.slotList[i].slot.gameObject:SetActive(false)
    end
    local size = self.layout.panelRect.sizeDelta
    if #datalist > 2 then
        self.scrollTrans.sizeDelta = Vector2(120, size.y)
        self.scroll.enabled = true
    else
        self.scrollTrans.sizeDelta = Vector2(size.x, size.y)
        self.scroll.enabled = false
    end
    size = self.buttonExt.contentTrans.sizeDelta
    self.buttonExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnClick() end)
end

function RewardBackItem:OnClick()
    if self.data ~= nil then
        -- local max = self.data.all - self.data.finish - self.data.back
        -- local maxAssets = 0 -- 最大消耗货币
        -- local maxReceive = 0    -- 最大可找回次数(货币限制)
        -- local maxReceiveAssets = 0    -- 最大可找回次数消耗的货币(货币限制)
        -- local singlePrice = 0       -- 单价
        -- local myAssets = 0          -- 我的货币
        -- local baseData = DataRewardBack.data_active_data[self.data.active_id]

        -- if self.type == 1 then
        --     singlePrice = baseData.gold
        --     myAssets = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
        -- else
        --     singlePrice = baseData.coin
        --     myAssets = RoleManager.Instance.RoleData.coin
        -- end

        -- maxAssets = singlePrice * max

        -- if maxAssets > myAssets then
        --     maxReceive = math.floor(myAssets / singlePrice)
        -- else
        --     maxReceive = max
        -- end
        -- maxReceiveAssets = maxReceive * singlePrice

        RewardBackManager.Instance.model:ShowConfirm({self.data.active_id, self.type, self.reward})

        -- if max > 0 then
        --     if maxReceive > 0 then
        --         RewardBackManager.Instance.model:ShowConfirm({self.data.active_id, self.type, self.reward})
        --     else
        --         if self.type == 1 then
        --             NoticeManager.Instance:FloatTipsByString(TI18N("钻石不足"))
        --         else
        --             NoticeManager.Instance:FloatTipsByString(TI18N("银币不足"))
        --         end
        --     end
        -- else
        --     NoticeManager.Instance:FloatTipsByString(TI18N("已全部找回"))
        -- end
    end
end
