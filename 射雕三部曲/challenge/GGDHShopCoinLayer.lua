--[[
    文件名：GGDHShopCoinLayer.lua
    描述： 序列争霸豪侠令兑换页面页面
    创建人：  wusonglin
    修改人：lengjiazhi
    创建时间：2016.6.18
-- ]]

local GGDHShopCoinLayer = class("GGDHShopCoinLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的各个字段为
    {
        serverData -- 服务器数据，缓存
        rank -- 历史排名，必选参数，上个页面传入
    }
]]
function GGDHShopCoinLayer:ctor(params)
    -- 屏蔽下层事件
	-- ui.registerSwallowTouch({node = self})

    -- 初始化数据
    if params.rank ~= nil then
        self.mRank = params.rank
        if self.mRank == 1000000 or self.mRank == 0 then
            self.mRank = TR("无排名")
        end
    end

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    
    local daibiBg = ui.newScale9Sprite("c_25.png",cc.size(590, 54))
    daibiBg:setPosition(cc.p(320, 930))
    self.mParentLayer:addChild(daibiBg)

    -- -- 代币数量
    local label = ui.newLabel({
        text = TR("当前豪侠令：{%s}%s%s",
            Utility.getDaibiImage(ResourcetypeSub.eGDDHCoin),
            Enums.Color.eYellowH,
            PlayerAttrObj:getPlayerAttrByName("GDDHCoin")),
        size = 24,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        color = Enums.Color.eNormalWhite,
        })
    label:setPosition(160, 930)
    self.mParentLayer:addChild(label)

    -- 创建刷新
    Notification:registerAutoObserver(label,
        function()
            label:setString(TR("当前豪侠令：{%s}%s%s",
                Utility.getDaibiImage(ResourcetypeSub.eGDDHCoin),
                Enums.Color.eYellowH,
                PlayerAttrObj:getPlayerAttrByName("GDDHCoin")))
        end
        , {EventsName.eGDDHCoin})

    -- 往届最高排名
    self.mOldRankLabel = ui.newLabel({  
        text = TR("往届最高排名：%s%s",Enums.Color.eYellowH, self.mRank),  
        size = 24,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        alignType = ui.TEXT_ALIGN_CENTER,
    }) 
    self.mOldRankLabel:setPosition(cc.p(450, 930))
    self.mParentLayer:addChild(self.mOldRankLabel)
	
    self.mGddhCoinList = params.serverData 

    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(606, 760))
    underBgSprite:setAnchorPoint(0.5, 1)
    underBgSprite:setPosition(320, 880)
    self.mParentLayer:addChild(underBgSprite)
    self.mUnderBgSprite = underBgSprite

    if  self.mGddhCoinList then
        -- 利用缓存数据直接创建Listview
        self:createListview()
    else
        -- 请求网络数据
        self:requestGetWrestleRaceShopInfo()
    end
end

function GGDHShopCoinLayer:createListview()
    if self.mListView then
        if next(self.mListView:getChildren()) then
            self.mListView:removeAllItems()
        end
    else
        -- 创建ListView列表
        self.mListView = ccui.ListView:create()
        self.mListView:setDirection(ccui.ScrollViewDir.vertical)
        self.mListView:setBounceEnabled(true)
        self.mListView:setContentSize(cc.size(598, 740))-- LayerManager.heightNoBottom - 269 * Adapter.AutoScaleX - Adapter.AutoHeight(85)))
        self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
        -- self.mListView:setItemsMargin(5)
        self.mListView:setAnchorPoint(cc.p(0.5, 1))
        self.mListView:setPosition(303, 750)
        self.mUnderBgSprite:addChild(self.mListView)
    end

    -- 添加数据
    for i = 1, #self.mGddhCoinList do
        self.mListView:pushBackCustomItem(self:createGddhCoinView(i))
    end
end
-- 创建item
function GGDHShopCoinLayer:createGddhCoinView(index)
    -- 初始化数据

    local info = self.mGddhCoinList[index]
    --dump(info,"tetatdafuwdvauydvavdiawyvd")
    -- local buyNum = 0

    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = 598
    local height = 126
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(590, 120))
    cellSprite:setPosition(cc.p(299, 63))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

     -- 设置物品头像
    local header = CardNode.createCardNode({
        resourceTypeSub = info.typeID,
        modelId = info.modelID,
        num = info.num,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eAddMark,
            -- CardShowAttr.eSelected,
            CardShowAttr.eSynthetic,
            CardShowAttr.eNum,
        },
    })
    header:setAnchorPoint(cc.p(0, 0.5))
    header:setPosition(cc.p(30, 63))
    custom_item:addChild(header)
    
    -- 显示物品名字
    local goodColorLv = Utility.getColorLvByModelId(info.modelID, info.typeID)
    local nameColor =  Utility.getColorValue(goodColorLv, 1)
    local nameLabel = ui.newLabel({
        text = string.format("%s", Utility.getGoodsName(info.typeID, info.modelID)),
        -- outlineColor = display.COLOR_BLACK,
        color = nameColor,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(cellSize.width * 0.25, cellSize.height * 0.7 + 10)
    cellSprite:addChild(nameLabel)

    -- local daibiSp = ui.newSprite(Utility.getDaibiImage(ResourcetypeSub.eGDDHCoin))
    -- daibiSp:setPosition(cellSize.width * 0.25, cellSize.height * 0.455 + 5)
    -- daibiSp:setAnchorPoint(cc.p(0., 0.5))
    -- cellSprite:addChild(daibiSp)
    -- 豪侠令值
    -- local gddhCoinLabel = ui.newLabel({
    --     text = TR("%s%d",Enums.Color.eNormalGreenH,info.needGDDHCoin),
    --     color = Enums.Color.eNormalGreen,
    -- })
    -- gddhCoinLabel:setScale(0.9)
    -- gddhCoinLabel:setAnchorPoint(cc.p(0, 0.5))
    -- gddhCoinLabel:setPosition(daibiSp:getPositionX() + daibiSp:getContentSize().width, cellSize.height * 0.455 + 5)
    -- cellSprite:addChild(gddhCoinLabel)

    -- 所需豪侠令
    local daibiSp = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eGDDHCoin,
        number = info.needGDDHCoin,
        -- fontColor = Enums.Color.eBlack,
        })
    daibiSp:setAnchorPoint(cc.p(0, 0.5))
    daibiSp:setPosition(cellSprite:getContentSize().width * 0.24, cellSprite:getContentSize().height * 0.5)
    cellSprite:addChild(daibiSp)

    -- 兑换按钮
    local exchangeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("兑换"),
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(width * 0.8, height * 0.5),
        clickAction = function ()
        -- print("info.perMaxNum"..info.perMaxNum)
        -- print("info.seasonMaxNum"..info.seasonMaxNum)
        -- print("info.totalMaxNum"..info.totalMaxNum)
        -- print("info.needGDDHCoin"..info.needGDDHCoin)
        
            if info.perMaxNum == 1 or info.seasonMaxNum == 1 or info.totalMaxNum == 1 then
                if PlayerAttrObj:getPlayerAttrByName("GDDHCoin") < info.needGDDHCoin then
                    -- showFlashText(TR("豪侠令不足"))
                    -- MsgBoxLayer.addOKLayer(TR("豪侠令不足"),TR("提示"))
                    ui.showFlashView({text = TR("豪侠令不足"),})
                else
                    -- 发送服务器数据
                    self:requestWrestleRaceShopBuy(info.ID, 1)
                end
            else
                local shopId = info.ID

                -- 玩家拥有资源数量
                local playerResNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eGDDHCoin)
                print("玩家拥有资源数量", playerResNum)
                -- 可兑换数量
                local maxNum = math.floor(playerResNum / GddhShopModel.items[shopId].needGDDHCoin)
                print("可兑换数量", maxNum)
                -- 今日还剩的限购数量
                local maxDailyNum = info.perMaxNum - info.BuyNum
                print("今日还剩的限购数量", maxDailyNum)
                -- 去掉负数
                if maxDailyNum <= 0 then maxDailyNum = maxNum end
                -- 最后可兑换数量
                maxNum = maxNum < maxDailyNum and maxNum or maxDailyNum
                print("最后可兑换数量", maxNum)
                -- 最后资源判断
                if maxNum <= 0 then
                    ui.showFlashView(TR("资源不足"))
                    return
                end

                -- 参数列表
                local params = {
                    title = TR("兑换"),                          
                    exchangePrice = GddhShopModel.items[shopId].needGDDHCoin,     
                    modelID = GddhShopModel.items[shopId].modelID,               
                    typeID  = GddhShopModel.items[shopId].typeID,                
                    resourcetypeCoin = ResourcetypeSub.eGDDHCoin,             
                    maxNum = maxNum,                          
                    oKCallBack = function(exchangeCount, layerObj, btnObj)
                        if exchangeCount ~= 0 then
                            if PlayerAttrObj:getPlayerAttrByName("GDDHCoin") < exchangeCount * info.needGDDHCoin then
                                ui.showFlashView({text = TR("豪侠令不足")})
                            else
                                self:requestWrestleRaceShopBuy(info.ID, exchangeCount)
                            end
                        else
                            ui.showFlashView({text = TR("请输入数量"),})
                        end
                        
                    end,                      
                }
                self.mMsgLayer = MsgBoxLayer.addExchangeGoodsCountLayer(params)


                -- -- -- 选择购买界面
                -- self.mMsgLayer = MsgBoxLayer.addExchangeGoodsCountLayer(TR("使用"), info.ID, info.perMaxNum,
                --     function (exchangeCount)
                --     self:requestWrestleRaceShopBuy(info.ID, exchangeCount)
                -- end)
                -- -- 选择购买界面
                -- self.layer = MsgBoxLayer.addSellGoodsCountLayer(TR("使用"), info.modelID, maxBuyCount,
                --     function (selCount)
                --     -- self:requestUseGoods(data, selCount, params.callback)
                --     -- LayerManager.removeLayer(self.layer)
                --     self:requestWrestleRaceShopBuy(info.ID, info.num)
                -- end
            -- )
            end
        end
    })

    -- 显示今日可兑换次数
    local maxLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eBlack,
        -- outlineColor = display.COLOR_BLACK,
    })
    maxLabel:setAnchorPoint(cc.p(0, 0.5))
    maxLabel:setPosition(cellSize.width * 0.25, cellSize.height * 0.23)
    cellSprite:addChild(maxLabel)
    -- 处理显示数据
    if info.perMaxNum > 0 then
        --if info.perMaxNum - info.BuyNum > 0 then
            maxLabel:setString(TR("今日兑换次数: %s%s/%s", Enums.Color.eNormalGreenH,info.BuyNum, info.perMaxNum))
        -- else
        --     maxLabel:setString(TR("已达兑换上限"))
        -- end
        buyNum = info.perMaxNum
        if info.perMaxNum - info.BuyNum <= 0 then
            exchangeBtn:setEnabled(false)
            exchangeBtn:setTitleText(TR("已兑换"))
        end
    else
        if info.seasonMaxNum > 0 then
            -- if info.seasonMaxNum - info.BuySeasonNum > 0 then
                maxLabel:setString(TR("赛季可兑换次数: %s%s/%s", Enums.Color.eNormalGreenH,info.BuySeasonNum, info.seasonMaxNum))
            -- else
            --     maxLabel:setString(TR("已达兑换上限"))
            -- end
            buyNum = info.seasonMaxNum
            if info.seasonMaxNum - info.BuySeasonNum <= 0 then
                exchangeBtn:setEnabled(false)
            end
        else
            if info.totalMaxNum > 0 then
                maxLabel:setString(TR("可兑换次数: %s%s/%s", Enums.Color.eNormalGreenH,info.BuyTotalNum, info.totalMaxNum))
                buyNum = info.totalMaxNum
                if info.totalMaxNum - info.BuyTotalNum <= 0 then
                    -- exchangeBtn:setVisible(false)
                    exchangeBtn:setEnabled(false)
                    exchangeBtn:setTitleText(TR("已兑换"))
                    -- local alreadExchange = ui.newSprite({
                    --     image = "c_48.png",
                    --     anchor = cc.p(0.5, 0.5),
                    --     position = cc.p(cellSize.width * 0.82, cellSize.height * 0.5)
                    -- })
                    -- cellSprite:addChild(alreadExchange)
                end
            end
        end
    end

    
    custom_item:addChild(exchangeBtn)

    return custom_item
end

-- 刷新ui
function GGDHShopCoinLayer:refreshRewardLayer()
end
-- 获取恢复数据
function GGDHShopCoinLayer:getRestoreData()
    local retData = {
       	rank = self.mRank,
        serverData = self.mGddhCoinList
	}

    return retData
end

--[[----------------------------网络相关--------------------------]]-----
function GGDHShopCoinLayer:requestGetWrestleRaceShopInfo()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "GetWrestleRaceShopInfo",
        svrMethodData = {},
        callback = function(data)    
            if data.Status ~= 0 then
                return
            end
            --存放豪侠令兑换数据
            self.mGddhCoinList = {} 
            -- 处理数据
            for i, v in ipairs(GddhShopModel.items) do
                if v.needRank == 0 then
                    -- if v.ID <= 14 then    --临时处理办法，如果服务器加上人物碎片则去掉<=14的判断
                        table.insert(self.mGddhCoinList, v)
                    -- end
                end
            end
            local list = {}
            for i,v in ipairs(data.Value) do
                if v.NeedRank == 0 then
                    if v.TypeID ~= 1111 and v.TypeID ~= 1606 then
                        table.insert(list, v)
                    end
                end
            end
            -- table.sort(self.rankList, function(a, b) return a.needRank < b.needRank end)
            --dump(self.mGddhCoinList,"ybbawdawbnodiawndoaiwndhbzju")
            for i, v in ipairs(list) do
                for m, n in ipairs(self.mGddhCoinList) do
                    if v.ShopId == n.ID then
                        self.mGddhCoinList[m].BuyNum = v.BuyNum
                        self.mGddhCoinList[m].BuySeasonNum = v.BuySeasonNum
                        self.mGddhCoinList[m].BuyTotalNum = v.BuyTotalNum
                    end
                end
            end

            -- table.sort(self.mGddhCoinList, function(a,b)
            --     return a.needGDDHCoin < b.needGDDHCoin
            -- end)

            -- 创建Listview
            self:createListview()
        end,
    })
    
end

--[[
-- 请求GddhShop接口，获取兑换结果
-- 参数
    {
        shopId -- 商店的ID
        num    -- 数量
    }
]]
function GGDHShopCoinLayer:requestWrestleRaceShopBuy(shopId, num)
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "WrestleRaceShopBuy",
        svrMethodData = {shopId, num},
        callback = function(data)  
            if data.Status ~= 0 then 
                return
            end

            local dataInfo = data.Value

            if not next(dataInfo.BaseGetGameResourceList) then
                return
            end
            
            LayerManager.removeLayer(self.mMsgLayer)
            ui.ShowRewardGoods(dataInfo.BaseGetGameResourceList)

            -- 处理显示数据
            local buyNum = num
            for i, v in ipairs(self.mGddhCoinList) do
                if shopId == v.ID then
                    v.BuyNum = v.BuyNum + buyNum
                    v.BuyTotalNum = v.BuyTotalNum + buyNum
                    v.BuySeasonNum = v.BuySeasonNum + buyNum
                    self.mListView:removeItem(i - 1)
                    self.mListView:insertCustomItem(self:createGddhCoinView(i), i - 1)
                end
            end
            self:createListview()
        end,
    })
end

return GGDHShopCoinLayer