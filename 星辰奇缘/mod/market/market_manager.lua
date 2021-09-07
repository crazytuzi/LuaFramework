MarketManager = MarketManager or BaseClass(BaseManager)

function MarketManager:__init()
    if MarketManager.Instance then
        Log.Error("MarketManager 不能重复实例化")
        return
    end
    self.model = MarketModel.New()
    MarketManager.Instance = self

    self.marketLocalSave = "marketLocalSave"

    -- 绑定协议
    self:AddNetHandler(12400, self.on12400)
    self:AddNetHandler(12401, self.on12401)
    self:AddNetHandler(12402, self.on12402)
    self:AddNetHandler(12404, self.on12404)
    self:AddNetHandler(12405, self.on12405)
    self:AddNetHandler(12406, self.on12406)
    self:AddNetHandler(12407, self.on12407)
    self:AddNetHandler(12408, self.on12408)
    self:AddNetHandler(12409, self.on12409)
    self:AddNetHandler(12411, self.on12411)
    self:AddNetHandler(12416, self.on12416)
    self:AddNetHandler(12418, self.on12418)
    self:AddNetHandler(12419, self.on12419)
    self:AddNetHandler(12420, self.on12420)
    self:AddNetHandler(12421, self.on12421)
    self:AddNetHandler(12422, self.on12422)

    self:AddNetHandler(10517, self.on10517)

    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function()
        self:send12419()
        self:RedPointMainUI()
    end)

    self.onReloadGoldMarket = EventLib.New()
    self.onUpdateRed = EventLib.New()

    self.redPointDic = {
        {
        -- [catalg_1] = {[catalg_2] = false},
            {},
        },
        {
            {},
        },
        {false},
    }

    self.sliverDataType = {
        Plant = 4,          -- 栽培
        Craft = 3,          -- 幻化
        Medicine = 2,       -- 药品
        Equip = 1,          -- 装备
        Pet = 98,            -- 宠物
        Glyphs = 5,         -- 雕文
        HightMed = 99,      -- 高级药品
        Classes = 6,       -- 职业徽章
    }

    -- 外部打开银币市场时，使用的参数
    self.originPosTab = {
        [self.sliverDataType.Plant] = 1,
        [self.sliverDataType.Craft] = 2,
        [self.sliverDataType.Medicine] = 3,
        [self.sliverDataType.HightMed] = 99,
        [self.sliverDataType.Equip] = 4,
        [self.sliverDataType.Classes] = 98,
        [self.sliverDataType.Pet] = 5,
        [self.sliverDataType.Glyphs] = 6,
    }
    -- self.silverOriIndexToNowIndex = {1, 2, 3, 5, 6, 7}
    -- self.silverOriIndexToNowIndex[99] = 4
    -- self.sliverTabList = {4, 3, 2, 99, 1, 6, 5}
    self.sliverTabList = {
        self.sliverDataType.Plant,
        self.sliverDataType.Craft,
        self.sliverDataType.Medicine,
        self.sliverDataType.HightMed,
        self.sliverDataType.Equip,
        self.sliverDataType.Classes,
        self.sliverDataType.Pet,
        self.sliverDataType.Glyphs,
    }
    self.currentPosTab = {}
    for k,v in pairs(self.sliverTabList) do
        self.currentPosTab[v] = k
    end
    self.silverOriIndexToNowIndex = {}
    for k,v in pairs(self.originPosTab) do
        self.silverOriIndexToNowIndex[v] = self.currentPosTab[k]
    end

    self.onUpdateRed:AddListener(function() self:RedPointMainUI() end)
end

-- type 1:金币市场，2:银币市场
function MarketManager:GetPrices(type, baseId)
    local model = self.model
    return model.priceByBaseid[type][baseId]
end

function MarketManager:OpenWindow(args)
    if QuestManager.Instance.taskArgs ~= nil then
        args = QuestManager.Instance.taskArgs
    end
    local model = self.model
    model.currentTab = nil

    if args == nil then
        args = {}
    end

    if args[1] == nil then
        for tab,dic in ipairs(self.redPointDic) do
            if tab == 1 then
                for main, redDic in pairs(dic) do
                    for sub, v in pairs(redDic) do
                        if v == true then
                            model.currentTab = tab
                            model.currentGoldMain = main
                            model.currentGoldSub = sub
                            break
                        end
                    end
                    if model.currentTab ~= nil then
                        break
                    end
                end
            elseif tab == 3 then
                if dic[1] == true then
                    model.currentTab = 3
                end
            end
            if model.currentTab ~= nil then
                break
            end
        end
        if model.currentTab == nil then
            model.currentTab = 1
            model.currentGoldMain = 5
            model.currentGoldSub = 1
        end
    elseif args[1] == 1 then
        model.currentTab = 1
        if args[2] == nil then
            model.currentGoldMain = 5
        elseif args[2] < 10000 then
            model.currentGoldMain = args[2]
            if args[3] == nil then
                model.currentGoldSub =  1
            elseif args[3] < 10000 then
                model.currentGoldSub = args[3]
                if args[4] == nil then
                    model.targetBaseId = nil
                else
                    model.targetBaseId = args[4]
                end
            else
                model.targetBaseId = args[3]
                local data = DataMarketGold[args[3]]
                model.currentGoldMain = data.catalg_1
                model.currentGoldSub = data.catalg_2
            end
        else
            model.targetBaseId = args[2]
            local data = DataMarketGold.data_market_gold_item[args[2]]
            model.currentGoldMain = data.catalg_1
            model.currentGoldSub = data.catalg_2
        end

        --print(model.currentGoldMain.." "..model.currentGoldSub)
    elseif args[1] == 2 then
        model.currentTab = 2
        if args[2] == nil then
            model.currentSub = self.silverOriIndexToNowIndex[1]
        elseif args[2] == 5 then
            -- 宠物面板
            model.currentSub = self.silverOriIndexToNowIndex[5]
            if args[3] == nil then
                model.targetBaseId = nil
            else
                model.targetBaseId = args[3]
            end
        else
            model.currentSub = self.silverOriIndexToNowIndex[args[2]]
            if args[3] == nil then
                model.targetBaseId = nil
            else
                local data = DataMarketSilver.data_market_silver_item[args[3]]
                if data == nil then
                    model.targetBaseId = nil
                else
                    -- model.currentSub =
                    -- print(data.type)
                    model.currentSub = self.silverOriIndexToNowIndex[args[2]]
                    for k,v in pairs(self.sliverTabList) do
                        if v == data.type then
                            -- print(k .. "-"..v)
                            model.currentSub = k --self.silverOriIndexToNowIndex[k]
                            break
                        end
                    end
                    model.targetBaseId = args[3]
                end
            end
        end
    elseif args[1] == 3 then
        model.currentTab = 3
        model.currentSub = args[2]
    elseif args[1] == 4 then
        model.currentTab = 3
        model.currentSub = 2
        if args[2] == nil then
        else
            model.targetBaseId = args[2]
        end
    end


    QuestManager.Instance.taskArgs = nil
    self.model:OpenWindow()
end

function MarketManager:send12400(catalg_1, catalg_2)
  -- print("发送12400")
    local data = {["catalg_1"] = catalg_1, ["catalg_2"] = catalg_2}
    BaseUtils.dump(data)
    Connection.Instance:send(12400, data)
end

function MarketManager:on12400(data)
    local marketWin = self.model.marketWin
    local i = 1
    local goldItemList = {}
    for _,v in pairs(data.goods) do
        table.insert(goldItemList, v)
        i = i + 1
    end
    table.sort(goldItemList, function (a, b)
        if DataMarketGold.data_market_gold_item[a.base_id].sort == DataMarketGold.data_market_gold_item[b.base_id].sort then
            return a.id < b.id
        else
            return DataMarketGold.data_market_gold_item[a.base_id].sort > DataMarketGold.data_market_gold_item[b.base_id].sort
        end
    end)

    if self.model.goldItemList[data.catalg_1] == nil then
        self.model.goldItemList[data.catalg_1] = {}
    end
    self.model.goldItemList[data.catalg_1][data.catalg_2] = goldItemList
    if marketWin ~= nil then
        local gold_panel = marketWin.subPanel[1]
        if gold_panel ~= nil then
            gold_panel:UpdateBuyPanel()
        end
    end

    EventMgr.Instance:Fire(event_name.market_gold_update, data.catalg_1, data.catalg_2)
end

function MarketManager:send12401(base_id, num)
    local dat = {["base_id"] = base_id, ["num"] = (num or 1)}
    Connection.Instance:send(12401, dat)
end

function MarketManager:on12401(data)
    if data.flag == 1 then
        print("购买成功")
    else
        print("购买失败")
    end

    if self.model.marketWin ~= nil and self.model.marketWin.subPanel ~= nil and self.model.marketWin.subPanel[1] ~= nil then
        self.model.marketWin.subPanel[1].frozen:Release()
    end
end

function MarketManager:send12402(id, num)
    local data = {["id"] = id, ["num"] = num}
    -- BaseUtils.dump(data, "=====================<color=#FF0000>出售商品</color>=====")
    Connection.Instance:send(12402, data)
end

function MarketManager:on12402(data)
    print("接收12402")
end

function MarketManager:send12404(package_type, item_id, num, percent, cell_id)
  -- print("发送12404，上架协议")
    local data = {["package_type"] = package_type, ["item_id"] = item_id, ["num"] = num, ["percent"] = percent, ["cell_id"] = cell_id}
    -- BaseUtils.dump(data, "上架数据")
    Connection.Instance:send(12404, data)
end

function MarketManager:on12404(data)
    print("上架成功")
end

function MarketManager:send12405(type, id)
    print("发送12405，购买协议 "..id)
    if AutoQuestManager.Instance.model.isOpen then -- 防止多次购买
        if AutoQuestManager.Instance.model.lockSecondBuy == false then
            AutoQuestManager.Instance.model.lockSecondBuy = true
            Connection.Instance:send(12405, {["type"] = type, ["id"] = id})
        else
            -- 自动过程中已经购买了一次不能再次购买
        end
    else
        Connection.Instance:send(12405, {["type"] = type, ["id"] = id})
    end
end

function MarketManager:on12405(data)
    local model = self.model
    local marketWin = model.marketWin
    BaseUtils.dump(data, TI18N("接收12405，购买协议"))
    if data.status == 0 then
        local itemlist_bytype = model.sliverItemList[data.type]
        if itemlist_bytype ~= nil then
            for k,v in pairs(itemlist_bytype) do
                if v.id == data.id then
                    v.status = data.status
                    v.num = data.num
                    break
                end
            end
        end
        marketWin.subPanel[2]:InitDataPanel(model.currentSliverSub[model.currentSliverMain])
    elseif data.status == 1 then
        local itemlist_bytype = model.sliverItemList[data.type]
        if itemlist_bytype ~= nil then
            for k,v in pairs(itemlist_bytype) do
                if v.id == data.id then
                    v.status = data.status
                    v.num = data.num
                    break
                end
            end
        end
        marketWin.subPanel[2]:InitDataPanel(model.currentSliverSub[model.currentSliverMain])
    elseif data.status == 2 then
        self:send12409(3)
    end

    if self.model.marketWin ~= nil and self.model.marketWin.subPanel ~= nil and self.model.marketWin.subPanel[2] ~= nil then
        self.model.marketWin.subPanel[2].buyFrozen:Release()
    end
    if data.err_code == 0 then -- 购买失败且处于自动历练/职业任务时，停止自动 inserted by 嘉俊
        if AutoQuestManager.Instance.model.isOpen then
            print("购买失败导致自动停止")
            AutoQuestManager.Instance.disabledAutoQuest:Fire()
        end
    end -- end by 嘉俊
end

function MarketManager:send12406(cell_id)
    local data = {["cell_id"] = cell_id}
    -- BaseUtils.dump(data, "下架协议数据")
    Connection.Instance:send(12406, data)
end

function MarketManager:on12406(data)
    if data.flag == 1 then
        print("下架成功")
    else
        print("下架失败")
    end
end

-- 重新上架
function MarketManager:send12413(cell_id, price, num)
    --print(string.format("%s %s %s", tostring(cell_id), tostring(price), tostring(num)))
    Connection.Instance:send(12413, {["cell_id"] = cell_id, ["percent"] = price, ["num"] = num})
end

function MarketManager:send12407()
    Connection.Instance:send(12407, {})
end

function MarketManager:on12407(data)
    -- print("接收12407")
    local model = self.model
    local marketWin = model.marketWin
    model.sellCellNum = 0
    model.sellCellItem = {}
    for k,v in pairs(data.free_ids) do
        if v.cell_id > model.sellCellNum then
            model.sellCellNum = v.cell_id
        end
        model.sellCellItem[v.cell_id] = {}
    end
    for k,v in pairs(data.cells) do
        if v.cell_id > model.sellCellNum then
            model.sellCellNum = v.cell_id
        end
        model.sellCellItem[v.cell_id] = v
    end

    if marketWin ~= nil and marketWin.subPanel ~= nil and marketWin.subPanel[3] ~= nil then
        marketWin.subPanel[3]:UpdateCells()
    end
end

-- 查询价格 type:1 不知道，type：2 不知到，type：3 赠送快捷购买
function MarketManager:send12408(base_id, type)
    Connection.Instance:send(12408, {["item_base_id"] = base_id})

    self.on12408_type = type
end

function MarketManager:on12408(data)
    local model = self.model
    local marketWin = model.marketWin
    model.standardPriceServerByBaseId[data.item_base_id] = data.price
    if marketWin ~= nil and marketWin.subPanel ~= nil and marketWin.subPanel[3] ~= nil and marketWin.subPanel[3].sellWin ~= nil and self.on12408_type == 2 then
        marketWin.subPanel[3].sellWin:UpdateInfoPanel()
    end

    if marketWin ~= nil and marketWin.subPanel ~= nil and marketWin.subPanel[3] ~= nil and self.on12408_type == 1 then
        marketWin.subPanel[3]:UpdateSellPanel()
    end
    if self.on12408_type == 3 then
        ShopManager.Instance.model:Update_QuickPricve()
    end
end

-- 刷新银币市场
function MarketManager:send12409(refresh_type)
  -- print("发送12409 "..refresh_type)
    -- print(debug.traceback())
    Connection.Instance:send(12409, {["refresh_type"] = refresh_type})
end

function MarketManager:on12409(data)
    -- BaseUtils.dump(data, "返回12409")
    local model = self.model
    local marketWin = model.marketWin

    if data.refresh_time - BaseUtils.BASE_TIME < 0 then
        self:send12409(1)
        return
    end
    model.refreshTime = data.refresh_time
    for k,v in pairs(data.data) do
        model.sliverItemList[v.type] = v.goods
        for _,d in pairs(v.goods) do
            d.type = v.type
        end
    end
    local tab = {}
    local medicine_lev = 1000
    local medicine_high = nil
    local tab1 = {}
    for k,_ in pairs(DataMarketSilver.data_market_high_level) do
        table.insert(tab1, k)
    end
    table.sort(tab1, function(a,b) return a>b end)
    for _,v in ipairs(tab1) do
        if RoleManager.Instance.RoleData.lev >= v then
            medicine_high = DataMarketSilver.data_market_high_level[v]
            break
        end
    end
    if medicine_high ~= nil then
        medicine_lev = medicine_high.lev
    end
    for _,dat in pairs(model.sliverItemList[self.sliverDataType.Medicine]) do
        for _,v in pairs(dat.item_attrs) do
            if v.attr == 1 then
                if v.value > 0 and v.value >= medicine_lev then
                    table.insert(tab, dat)
                end
                break
            end
        end
    end
    for _,dat in pairs(model.sliverItemList[self.sliverDataType.Plant]) do
        if dat.item_base_id == 21302 or dat.item_base_id == 21409 then
            for _,v in pairs(dat.item_attrs) do
                if v.attr == 1 then
                    if v.value > 0 and v.value >= medicine_lev then
                        table.insert(tab, dat)
                    end
                    break
                end
            end
        end
    end
    model.sliverItemList[self.sliverDataType.HightMed] = tab

    model.sliverRefreshType = 2
    if marketWin.subPanel[2] ~= nil then
        marketWin.subPanel[2]:DoCountDown()
        -- marketWin.subPanel[2]:LocateItem()
        -- marketWin.subPanel[2]:UpdateBuyPanel()

        marketWin.subPanel[2].tabGroup:ChangeTab(model.currentSliverTab or model.currentSub or 1)
    end
end

-- 提现单个
function MarketManager:send12411(cell_id)
  -- print("发送12411，提现单个")
    Connection.Instance:send(12411, {["cell_id"] = cell_id})
end

function MarketManager:on12411(data)
    if data.flag == 1 then
        print("提现成功")
    else
        print("提现失败")
    end
end

function MarketManager:send12412()
    Connection.Instance:send(12412, {})
end

function MarketManager:on12412(data)
    if data.flag == 1 then
        self:send12407()
    end
end

function MarketManager:send12414(type)
    Connection.Instance:send(12414, {["type"] = type})
end

-- 购买宠物
function MarketManager:send10517(base_id)
  -- print("发送10517，购买宠物 "..tostring(base_id))
    if AutoQuestManager.Instance.model.isOpen then -- 防止多次购买
        if AutoQuestManager.Instance.model.lockSecondBuy == false then
            AutoQuestManager.Instance.model.lockSecondBuy = true
            Connection.Instance:send(10517, {["base_id"] = base_id})
        else
            -- 自动过程中已经购买了一次不能再次购买
        end
    else
        Connection.Instance:send(10517, {["base_id"] = base_id})
    end
end

function MarketManager:on10517(data)
    print("响应10517")
    if data.flag == 1 then
        print("购买成功")
    else
        print("购买失败")
        -- inserted by 嘉俊 497163788@qq.com ：  检测当前是否处于自动历练或自动职业任务状态，若处于且购买宠物失败则停止自动
        if AutoQuestManager.Instance.model.isOpen then
            print("购买宠物失败导致自动停止")
            AutoQuestManager.Instance.disabledAutoQuest:Fire()
        end
        -- end by 嘉俊
    end

    if self.model.marketWin ~= nil and self.model.marketWin.subPanel ~= nil and self.model.marketWin.subPanel[2] ~= nil then
        self.model.marketWin.subPanel[2].buyFrozen:Release()
    end
end

function MarketManager:send12416(_data, callback)
-- print("send12416")
-- BaseUtils.dump(_data)
    local key = ""
    local baseids = {}
    for _,v in pairs(_data.base_ids) do
        table.insert(baseids, v.base_id)
    end
    table.sort(baseids, function (a, b) return a < b end)
    for i=1,#baseids do
        key = key.."_"..tostring(baseids[i])
    end
    if self.model.on12416_callback[key] == nil then
        self.model.on12416_callback[key] = {}
        -- setmetatable(self.model.on12416_callback[key], {__mode = 'k'})
    end
    table.insert(self.model.on12416_callback[key], callback)
    Connection.Instance:send(12416, _data)
    return key, #self.model.on12416_callback[key]
end

function MarketManager:on12416(data)
    -- BaseUtils.dump(data,"<color='#880000'>On12416:</color>---------------------------------")
    local price_list = data.market_price
    local priceByBaseid = {}

    local key = ""
    local baseids = {}

    for _,v in pairs(price_list) do
        priceByBaseid[v.base_id] = {}
        for key,value in pairs(v) do
            priceByBaseid[v.base_id][key] = value
        end
        table.insert(baseids, v.base_id)
    end
    table.sort(baseids, function (a, b) return a < b end)
    for i=1,#baseids do
        key = key.."_"..tostring(baseids[i])
    end

    if self.model.on12416_callback[key] ~= nil then
        for i,v in ipairs(self.model.on12416_callback[key]) do
           v(priceByBaseid)
           self.model.on12416_callback[key][i] = nil
        end
    end

    LuaTimer.Add(1000, function() self:Clear12416Callback() end)
end

function MarketManager:on12418(data)
    local model = self.model
    local marketWin = model.marketWin

    if model.goldItemList == nil then
        return
    end

    for k,v in pairs(data.goods) do
        local marketdata = DataMarketGold.data_market_gold_item[v.base_id]
        local catalg_1 = marketdata.catalg_1
        local catalg_2 = marketdata.catalg_2
        if model.goldItemList[catalg_1] ~= nil then
            local goldItemList = model.goldItemList[catalg_1][catalg_2]
            if goldItemList ~= nil then
                for k1,v1 in pairs(goldItemList) do
                    if v1.base_id == v.base_id then
                        goldItemList[k1] = v
                        break
                    end
                end
            end
        end
    end

    if marketWin ~= nil then
        local gold_panel = marketWin.subPanel[1]
        if gold_panel ~= nil then
            gold_panel.isRefrshData = true
            gold_panel:UpdateBuyPanel()
        end
    end
end

function MarketManager:Clear12416Callback()
    if self.clearing ~= true then
        self.clearing = true
        local callbackList = {}
        for k,v in pairs(self.model.on12416_callback) do
            if v ~= nil and #v ~= 0 then
                callbackList[k] = {}
                for k1,v1 in pairs(v) do
                    if v1 ~= nil then
                        table.insert(callbackList[k], v1)
                    end
                end
            end
        end
        self.model.on12416_callback = callbackList
        self.clearing = false
    end
end

function MarketManager:send12419()
    Connection.Instance:send(12419, {})
end

function MarketManager:on12419(data)
    local model = self.model
    local marketWin = model.marketWin
    self.redPointDic[3][1] = true
    -- NoticeManager.Instance:FloatTipsByString("可提现")
    -- print("<color=#880000>可提现</color>")
    self.onUpdateRed:Fire()

    self:send12407(function ()
        if marketWin ~= nil and marketWin.subPanel ~= nil and marketWin.subPanel[3] ~= nil then
            marketWin.subPanel[3]:UpdateCells()
        end
    end)
end

function MarketManager:Cashout(bool)
    self.redPointDic[3][1] = self.redPointDic[3][1] or bool
end

function MarketManager:RedPointMainUI()
    if self.icon == nil then
        self.icon = DataSystem.data_icon[18].icon
        if self.icon ~= nil then
            self.icon = self.icon.transform
        end
    end
    if self.icon ~= nil then
        local red = false

        -- 检查金币市场
        -- for _,dic in pairs(self.redPointDic[1]) do
        --     if dic ~= nil then
        --         for _,v in pairs(dic) do
        --             red = red or v
        --         end
        --     end
        -- end

        -- 检查银币市场
        for _,dic in pairs(self.redPointDic[2]) do
            if dic ~= nil then
                for _,v in pairs(dic) do
                    red = red or v
                end
            end
        end

        -- 检查出售
        red = red or self.redPointDic[3][1]
        self.icon:Find("RedPointImage").gameObject:SetActive(red)
    end
end

function MarketManager:ClearData()
    local model = self.model
    for _,v in pairs(DataMarketGold.data_market_gold_tab) do
        model.goldOpenTab[v.catalg_1] = model.goldOpenTab[v.catalg_1] or {}
        model.goldOpenTab[v.catalg_1][v.catalg_2] = true
    end

    model.goldItemList = {}
    model.sliverItemList = {}
    model.sellCellList = {}
    model.sellItemDic = {}
    model.limit_data = {}

    model.sliverRefreshType = 3
    self:send12420()
end

function MarketManager:send12420()
  -- print("发送12420")
    Connection.Instance:send(12420, {})
end

function MarketManager:on12420(data)
    --BaseUtils.dump(data, "on12420")
    local model = self.model
    model.limit_data = model.limit_data or {}
    local roleData = RoleManager.Instance.RoleData
    local tab = model.limit_data
    local lev = RoleManager.Instance.RoleData.lev

    local hasLimit = {}
    if #data.limit_data > 0 then
        for _,v in pairs(data.limit_data) do
            tab[v.item_id] = v.count
            local limit_count = 0
            if model.levelOpenItemLimit[v.item_id] ~= nil then
                for i,v_ in ipairs(model.levelOpenItemLimit[v.item_id]) do
                    if lev >= v_[1] then
                        limit_count = v_[2]
                    else
                        break
                    end
                end
            else
                -- 这周在把限购去掉了。。。
            end
            local golddata = DataMarketGold.data_market_gold_item[v.item_id]
            if golddata ~= nil then
                hasLimit[golddata.catalg_1] = hasLimit[golddata.catalg_1] or {}
                hasLimit[golddata.catalg_1][golddata.catalg_2] = hasLimit[golddata.catalg_1][golddata.catalg_2] or (limit_count - v.count > 0 and RoleManager.Instance.world_lev >= golddata.world_lev)
            end
        end
    else
        for base_id,_ in pairs(model.levelOpenItemLimit) do
            local golddata = DataMarketGold.data_market_gold_item[base_id]
            if golddata ~= nil then
                hasLimit[golddata.catalg_1] = hasLimit[golddata.catalg_1] or {}
                hasLimit[golddata.catalg_1][golddata.catalg_2] = true
            end
        end
    end

    self:CheckOpen()


    for _,v in pairs(DataMarketGold.data_market_gold_tab) do
        hasLimit[v.catalg_1] = hasLimit[v.catalg_1] or {}
        hasLimit[v.catalg_1][v.catalg_2] = hasLimit[v.catalg_1][v.catalg_2] or false

        local lastTime = PlayerPrefs.GetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, self.marketLocalSave, v.catalg_1, v.catalg_2))
        local thisDay = math.ceil((BaseUtils.BASE_TIME + 1) / 86400) - 4


        -- hasLimit[v.catalg_1][v.catalg_2] = hasLimit[v.catalg_1][v.catalg_2] and (not model.goldOpenTab[v.catalg_1][v.catalg_2])

        self.redPointDic[1][v.catalg_1] = self.redPointDic[1][v.catalg_1] or {}
        -- self.redPointDic[1][v.catalg_1][v.catalg_2] = (self.redPointDic[1][v.catalg_1][v.catalg_2] or hasLimit[v.catalg_1][v.catalg_2])

        if lastTime == nil then
            self.redPointDic[1][v.catalg_1][v.catalg_2] = ((self.redPointDic[1][v.catalg_1][v.catalg_2] or hasLimit[v.catalg_1][v.catalg_2]) and model.goldOpenTab[v.catalg_1][v.catalg_2]) and (lev >= 40)
        else
            local lastDay = math.ceil((lastTime + 1) / 86400) - 4
            local thisMonday = math.floor(thisDay / 7) * 7 + 1

            if lastDay < thisMonday and thisMonday <= thisDay then
                self.redPointDic[1][v.catalg_1][v.catalg_2] = ((self.redPointDic[1][v.catalg_1][v.catalg_2] or hasLimit[v.catalg_1][v.catalg_2]) and model.goldOpenTab[v.catalg_1][v.catalg_2]) and (lev >= 40)
            else
                -- print(v.catalg_1.."_"..v.catalg_2)
                self.redPointDic[1][v.catalg_1][v.catalg_2] = false and (lev >= 40)
            end
        end
    end


    self.onUpdateRed:Fire()
end

function MarketManager:CheckOpen()
    local model = self.model
    local roleData = RoleManager.Instance.RoleData
    local all_not_show = {}
    for item_id,list in pairs(model.levelOpenItemLimit) do
        local lev = 0
        for _,v in pairs(list) do
            if roleData.lev >= v[1] then
                lev = v[1]
            else
                break
            end
        end
        local goldData = DataMarketGold.data_market_gold_item[item_id]
        all_not_show[item_id] = all_not_show[item_id] or true
        all_not_show[item_id] = all_not_show[item_id] and (DataMarketGold.data_lev_limit[item_id.."_"..lev].is_show ~= 1)
    end
    local world_lev = RoleManager.Instance.world_lev
    for _,v in pairs(DataMarketGold.data_market_gold_tab) do
        if world_lev >= v.world_lev then
            model.goldOpenTab[v.catalg_1][v.catalg_2] = 0
        else
            model.goldOpenTab[v.catalg_1][v.catalg_2] = -1
        end
    end

    for _,v in pairs(DataMarketGold.data_market_gold_item) do
        if model.goldOpenTab[v.catalg_1][v.catalg_2] >= 0 then
            if not all_not_show[v.base_id] then
                model.goldOpenTab[v.catalg_1][v.catalg_2] = model.goldOpenTab[v.catalg_1][v.catalg_2] + 1
            end
        end
    end

    for k,v in pairs(model.goldOpenTab) do
        for k1,v1 in pairs(v) do
            if v1 > 0 then
                v[k1] = true
            else
                v[k1] = false
            end
        end
    end

    return all_not_show
end

function MarketManager:OpenSellWindow(args)
    self.model:OpenSellWindow(args)
end

function MarketManager:OpenConfirm(args)
    self.model:OpenConfirm(args)
end

function MarketManager:send12421(array, id)
    id = id or 0
    BaseUtils.dump({base_ids = array, id = id}, "send12421-args")
    Connection.Instance:send(12421, {base_ids = array, id = id})
end

function MarketManager:on12421(data)
    print("<color=#ff0000>on12421</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function MarketManager:send12422(array, id)
    id = id or 0
    BaseUtils.dump({base_ids = array, id = id}, "send12422-args")
    Connection.Instance:send(12422, {base_ids = array, id = id})
end

function MarketManager:on12422(data)
    print("<color=#ff0000>on12422</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
