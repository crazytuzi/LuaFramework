MarketModel = MarketModel or BaseClass(BaseModel)

function MarketModel:__init()
    self.marketWin = nil
    self.sellWin = nil

    self.goldHistory = {}
    self.currentTab = nil       -- 当前标签页
    self.goldItemList = {}
    self.sliverItemList = {nil, nil, nil, nil, nil}     -- 根据类型
    self.sellCellList = {}
    self.sellItemDic = {}
    self.standardPriceServerByBaseId = {}
    self.on12416_callback = {}
    self.goldOpenTab = {}
    for _,v in pairs(DataMarketGold.data_market_gold_tab) do
        self.goldOpenTab[v.catalg_1] = self.goldOpenTab[v.catalg_1] or {}
        self.goldOpenTab[v.catalg_1][v.catalg_2] = true
    end

    self.currentTab = 1
    self.currentGoldMain = 5
    self.currentGoldSub = 1

    self.silverIdToClasses = {
        [23711] = 1,
        [23712] = 2,
        [23713] = 3,
        [23714] = 4,
        [23715] = 5,
        [23731] = 6,
    }

    self.levelOpenItemLimit = {}
    if DataMarketGold.data_lev_limit ~= nil then
        for _,v in pairs(DataMarketGold.data_lev_limit) do
            self.levelOpenItemLimit[v.id] = self.levelOpenItemLimit[v.id] or {}
            table.insert(self.levelOpenItemLimit[v.id], {v.min, v.num, v.classes, v.sex})
        end
        for _,v in pairs(self.levelOpenItemLimit) do
            table.sort(v, function(a,b) return a[1] < b[1] end)
        end
    end

end

function MarketModel:__delete()
    if self.marketWin ~= nil then
        self.marketWin:DeleteMe()
        self.marketWin = nil
    end
end

function MarketModel:OpenWindow()
    if self.marketWin == nil then
        self.marketWin = MarketWindow.New(self)
    end
    self.marketWin:Open()
end

function MarketModel:CloseWin()
    WindowManager.Instance:CloseWindow(self.marketWin)
end

function MarketModel:OpenSellWindow(args)
    if self.sellGoldWin == nil then
        self.sellGoldWin = SellGoldWindow.New(self)
    end
    self.sellGoldWin:Open(args)
end

function MarketModel:GetConditions()
    if self.conditionTab == nil then
        self.conditionTab = {}
        self.noQuickSellTab = {}
        for _,v in pairs(DataMarketGold.data_noquick) do
            self.conditionTab[v.base_id] = self.conditionTab[v.base_id] or {base_id = v.base_id, condition = {}}
            table.insert(self.conditionTab[v.base_id].condition, {v.quick_type, v.value, v.classes, v.sex})
            if v.quick_type == MarketEumn.ConditionType.Absolute then
                self.noQuickSellTab[v.base_id] = 1
            end
        end
    end
    return self.conditionTab
end

function MarketModel:OpenSellgoldSetting(parent)
    if self.goldSetting == nil then
        self.goldSetting = MarketSellgoldSetting.New(self, parent)
    end
    self.goldSetting:Show()
end

function MarketModel:CloseSellgoldSetting()
    if self.goldSetting ~= nil then
        self.goldSetting:DeleteMe()
        self.goldSetting = nil
    end
end

function MarketModel:ReadHistoryGold()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "goldHistory")
    local tab = BaseUtils.unserialize(PlayerPrefs.GetString(key, "{}")) or {}

    self.goldHistory = self.goldHistory or {}
    self.goldHistory.list = tab.list or {}
    self.goldHistory.option1 = tab.option1 or 1
    self.goldHistory.option2 = tab.option2 or 1
end

function MarketModel:SetHistoryGold()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "goldHistory")
    PlayerPrefs.SetString(key, BaseUtils.serialize(self.goldHistory))
end

function MarketModel:OpenConfirm(args)
    if self.confirmPanel == nil then
        self.confirmPanel = SellConfirmWindow.New(self)
    end
    self.confirmPanel:Show(args)
end

function MarketModel:CloseConfirm()
    if self.confirmPanel ~= nil then
        self.confirmPanel:DeleteMe()
        self.confirmPanel = nil
    end
end

--1：金币市场物品  2：银币市场物品  0:都不是
function MarketModel:CheckGoldOrSliverItem(itemBaseId)
    if DataMarketGold.data_market_gold_item[itemBaseId] then 
        return 1
    elseif DataMarketSilver.data_market_silver_item[itemBaseId] then 
        return 2
    else
        return 0
    end
end