-- @author 黄耀聪
-- @date 2016年12月30日

-- 奖励找回

RewardBackPanel = RewardBackPanel or BaseClass(BasePanel)

function RewardBackPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RewardBackPanel"

    self.tabDataList = {
        {name = TI18N("完美找回"), icon = "29255"},
        {name = TI18N("普通找回"), icon = "90000"}
    }

    self.resList = {
        {file = AssetConfig.reward_getback, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.reloadListener = function() self.tabGroup:ChangeTab(self.currentIndex or 1) end

    self.setting = {
        perWidth = 120,
        perHeight = 40,
        spacing = 5,
        isVertical = false,
        notAutoSelect = true,
        noCheckRepeat = true,
    }

    self.tabList = {}
    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RewardBackPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for _,item in pairs(self.itemList) do
            if item ~= nil then
                item:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.tabList ~= nil then
        for _,v in pairs(self.tabList) do
            if v ~= nil then
                v.loader:DeleteMe()
            end
        end
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.button1Ext ~= nil then
        self.button1Ext:DeleteMe()
        self.button1Ext = nil
    end
    if self.button2Ext ~= nil then
        self.button2Ext:DeleteMe()
        self.button2Ext = nil
    end
    if self.model.confirmPanel ~= nil then
        self.model.confirmPanel:DeleteMe()
        self.model.confirmPanel = nil
    end
    self:AssetClearAll()
end

function RewardBackPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.reward_getback))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.tabGroup = TabGroup.New(t:Find("Bg/Top"), function(index) self:ChangeTab(index) end, self.setting)
    self.layout = LuaBoxLayout.New(t:Find("Bg/Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 10, border = 5})
    self.cloner = t:Find("Bg/Scroll/Cloner").gameObject

    self.button1 = t:Find("ButtonArea/Button1"):GetComponent(Button)
    self.button1Ext = MsgItemExt.New(t:Find("ButtonArea/Button1/Text"):GetComponent(Text), 300, 20, 23.276)
    self.button2 = t:Find("ButtonArea/Button2"):GetComponent(Button)
    self.button2Ext = MsgItemExt.New(t:Find("ButtonArea/Button2/Text"):GetComponent(Text), 300, 20, 23.276)
    self.noticeBtn = t:Find("ButtonArea/Notice"):GetComponent(Button)

    for i,v in ipairs(self.tabGroup.buttonTab) do
        v.red:SetActive(false)
        v.normalTxt.text = self.tabDataList[i].name
        v.selectTxt.text = self.tabDataList[i].name
        self.tabList[i] = {}
        self.tabList[i].loader = SingleIconLoader.New(v.transform:Find("Icon").gameObject)
        self.tabList[i].loader:SetSprite(SingleIconType.Item, DataItem.data_get[tonumber(self.tabDataList[i].icon)].icon)
        v.transform:GetComponent(TransitionButton).scaleSetting = true
    end

    self.button1Ext:SetData(TI18N("{assets_2, 29255}完美找回"))
    self.button2Ext:SetData(TI18N("{assets_2, 90000}一键找回"))

    local size = self.button1Ext.contentTrans.sizeDelta
    self.button1Ext.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
    size = self.button2Ext.contentTrans.sizeDelta
    self.button2Ext.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

    self.button1.onClick:AddListener(function() self:OnOnePress(1) end)
    self.button2.onClick:AddListener(function() self:OnOnePress(2) end)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
end

function RewardBackPanel:OnOpen()
    self:RemoveListeners()
    RewardBackManager.Instance.rewardBackEvent:AddListener(self.reloadListener)

    self.tabGroup:ChangeTab(self.currentIndex or 1)
end

function RewardBackPanel:OnHide()
    self:RemoveListeners()

    self.currentIndex = nil
end

function RewardBackPanel:RemoveListeners()
    RewardBackManager.Instance.rewardBackEvent:RemoveListener(self.reloadListener)
end

function RewardBackPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RewardBackPanel:ChangeTab(index)
    self.currentIndex = index
    self:Reload(index)
end

-- index = 1 表示完美找回，否则普通找回
function RewardBackPanel:Reload(index)
    local datalist = {}
    -- BaseUtils.dump(self.model.rewardData, "self.model.rewardData")

    for i,v in pairs((self.model.rewardData or {}).list or {}) do
        if v ~= nil and #(v.reward or {}) > 0 and v.all - v.finish - v.back > 0 then
            local exp = 0
            for _,reward in pairs(v.reward) do
                if reward.type == KvData.assets.exp then
                    exp = exp + reward.value
                end
            end
            if exp > 0 then
                table.insert(datalist, v)
            end
        end
    end
    table.sort(datalist, function(a,b) return a.active_id < b.active_id end)
    local tab = nil

    self.layout:ReSet()
    for i,v in ipairs(datalist) do
        tab = self.itemList[i]
        if tab == nil then
            tab = RewardBackItem.New(GameObject.Instantiate(self.cloner), self.assetWrapper)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)
        tab:SetData({data = v, type = index})
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    self.cloner:SetActive(false)
end

function RewardBackPanel:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {
        TI18N("1.可找回<color='#00ff00'>2天</color>内未参加活动的奖励"),
        TI18N("2.可选择<color='#ffff00'>完美找回</color>和<color='#ffff00'>普通找回</color>两种方式。<color='#ffff00'>完美找回</color>可找回<color='#00ff00'>100%</color>的奖励；<color='#ffff00'>普通找回</color>可找回<color='#00ff00'>60%</color>的奖励"),
        TI18N("3.人物等级高于世界等级<color='#00ff00'>7级及以上</color>时，无法找回<color='#ffff00'>经验</color>奖励")
        }})
end

function RewardBackPanel:OnOnePress(type)
    if self.model.rewardData ~= nil then
        local confirmData = NoticeConfirmData.New()
        local count = 0
        local exp = 0
        if type == 1 then    -- 完美找回
            local baseData = nil
            for _,v in pairs(self.model.rewardData.list) do
                local exp1 = 0
                if v ~= nil and #(v.reward or {}) > 0 and v.all - v.finish - v.back > 0 then
                    for _,reward in pairs(v.reward) do
                        if reward.type == KvData.assets.exp then
                            exp1 = exp1 + reward.value
                        end
                    end
                end
                if exp1 > 0 then
                    count = count + math.ceil((v.all - v.finish - v.back) / DataRewardBack.data_active_data[v.active_id].item[1][2])
                    exp = DataRewardBack.data_active_data[v.active_id].perfect_exp
                    baseData = DataItem.data_get[DataRewardBack.data_active_data[v.active_id].item[1][1]]
                end
            end
            if baseData ~= nil then 
                confirmData.content = string.format(TI18N("一键找回<color='#00ff00'>%s%%</color>的奖励，共消耗<color='#00ff00'>%s个</color>%s，是否继续？"), exp, count, ColorHelper.color_item_name(baseData.quality, baseData.name))
                confirmData.sureCallback = function() self:OnOnePressConfirm(count, baseData.id) end
            end
        else
            for _,v in pairs(self.model.rewardData.list) do
                local exp1 = 0
                if v ~= nil and #(v.reward or {}) > 0 and v.all - v.finish - v.back > 0 then
                    for _,reward in pairs(v.reward) do
                        if reward.type == KvData.assets.exp then
                            exp1 = exp1 + reward.value
                        end
                    end
                end
                if exp1 > 0 then
                    count = count + DataRewardBack.data_active_data[v.active_id].coin * (v.all - v.finish - v.back)
                    exp = DataRewardBack.data_active_data[v.active_id].normal_exp
                end
            end
            confirmData.content = string.format(TI18N("一键找回<color='#00ff00'>%s%%</color>的奖励，共花费<color='#00ff00'>%s</color>{assets_2, 90000}，是否继续？"), exp, count)
            confirmData.sureCallback = function() RewardBackManager.Instance:send18402(type) end
        end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function RewardBackPanel:OnOnePressConfirm(needCount, baseId)
    local count = BackpackManager.Instance:GetItemCount(baseId)

    local backCount = self.count
    local active_id = self.active_id

    if count < needCount then
        MarketManager.Instance:send12416({base_ids = {{base_id = baseId}}}, function(priceTab)
            local all = 0
            local world_lev = math.floor(RoleManager.Instance.world_lev / 5) * 5
            for _,v in pairs(priceTab) do
                if v.assets == KvData.assets.gold then
                    all = all + v.price * (needCount - count)
                elseif v.assets == KvData.assets.gold_bind then
                    all = all + math.ceil(v.price / DataMarketGold.data_market_gold_ratio[world_lev].rate) * (needCount - count)
                elseif v.assets == KvData.assets.coin then
                    all = all + math.ceil(v.price / DataMarketSilver.data_market_silver_ratio[world_lev].rate) * (needCount - count)
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
            confirmData.sureCallback = function() RewardBackManager.Instance:send18402(1) end
            NoticeManager.Instance:ConfirmTips(confirmData)
        end)
    else
        RewardBackManager.Instance:send18402(1)
    end
end
