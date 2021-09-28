--[[
	文件名：PvpInterShopLayer.lua
	文件描述：浑源之战商店页面
	创建人：chenqiang
	创建时间：2017.07.31
]]

local PvpInterShopLayer = class("PvpInterShopLayer", function()
    return display.newLayer()
end)

-- 构造函数
function PvpInterShopLayer:ctor()
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 玩家当前拥有的消耗道具
    self.useResTable = Utility.analysisStrResList(PvpinterShopModel.items[1].useResource)
    self.mHasFairPoint = Utility.getOwnedGoodsCount(self.useResTable[1].resourceTypeSub, self.useResTable[1].modelId)

    -- 单个条目的大小
    self.mCellSize = cc.size(607, 122)
    -- 初始化服务器消息列表
    self.mNetDataTable = {}

    -- 创建父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建底部导航页
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eGold,
            ResourcetypeSub.eDiamond,
            {
                resourceTypeSub = self.useResTable[1].resourceTypeSub, 
                modelId = self.useResTable[1].modelId
            },
        }
    })
    self:addChild(topResource)

    -- 请求商品信息
    self:requestGetChangeInfo()
end

-- 初始化UI
function PvpInterShopLayer:initUI()
    -- 创建背景图片
    self.mBgSprite = ui.newSprite("qxzb_4.jpg")
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite)

	-- 创建人物
    local meinv = ui.newSprite("bp_17.jpg")
    meinv:setPosition(cc.p(320, 931))
    self.mParentLayer:addChild(meinv)

    -- 返回按钮
    local returnButton = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(590, 1040),
        clickAction = function (sender)
            Notification:postNotification(EventsName.eGuildHomeAll)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(returnButton)

    -- 文字描述
    local decLabel = ui.newLabel({
        text = TR("少侠，看上什么请随便挑。当然，不包括我~^_^"),
        outlineColor = cc.c3b(0x28, 0x28, 0x29),
        outlineSize = 2,
        valign = ui.VERTICAL_TEXT_ALIGNMENT_TOP,
        size = 21,
        dimensions = cc.size(300, 0),
        anchorPoint = cc.p(0, 1)
    })
    decLabel:setPosition(20, 845)
    self.mParentLayer:addChild(decLabel)

    -- 下方列表背景
    local listBack = ui.newScale9Sprite("c_19.png", cc.size(640, 738))
    listBack:setAnchorPoint(cc.p(0.5, 1))
    listBack:setPosition(320, 738)
    self.mParentLayer:addChild(listBack)

    -- 商品列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(607,545))
    listBg:setPosition(320, 385)
    self.mParentLayer:addChild(listBg)

    -- 创建代币背景
    local daibiBgSprite = ui.createSpriteAndLabel({
        imgName = "c_24.png",
        scale9Size = cc.size(150, 40),
        labelStr = TR("当前%s: ", Utility.getGoodsName(self.useResTable[1].resourceTypeSub, self.useResTable[1].modelId)),
        fontColor = Enums.Color.eBlack,
        fontSize = 25,
        alignType = ui.TEXT_ALIGN_LEFT,
    })
    daibiBgSprite:setAnchorPoint(cc.p(0, 1))
    daibiBgSprite:setPosition(20, 705)
    self.mParentLayer:addChild(daibiBgSprite)

    -- 当前拥有的代币
    self.mDaibiView = ui.createDaibiView({
        resourceTypeSub = self.useResTable[1].resourceTypeSub,
        goodsModelId = self.useResTable[1].modelId,
        number = self.mHasFairPoint,
        fontSize = 24,
        fontColor = Enums.Color.eYellow,
        outlineColor = Enums.Color.eOutlineColor,
    })
    self.mDaibiView:setAnchorPoint(cc.p(0, 1))
    self.mDaibiView:setPosition(160, 705)
    self.mParentLayer:addChild(self.mDaibiView)

    -- 创建listView
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(607, 535))
    self.mListView:setItemsMargin(10)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(0.5, 0.5)
    self.mListView:setPosition(320, 385)
    self.mParentLayer:addChild(self.mListView)

    -- 刷新列表
    self:refreshShopListView()
end


-- 刷新整个listview, viewTpye为兑换和排名兑换
function PvpInterShopLayer:refreshShopListView()
    self.mListView:removeAllItems()

    for index, item in ipairs(PvpinterShopModel.items) do
        local layout = ccui.Layout:create()
        layout:setContentSize(self.mCellSize)
        self.mListView:pushBackCustomItem(layout)

        -- 刷新指定项
        self:refreshShopListItem(index, item)
    end
end

-- 每一条的信息刷新和创建
function PvpInterShopLayer:refreshShopListItem(index, data)
    local layout = self.mListView:getItem(index - 1)
    if not layout then
        layout = ccui.Layout:create()
        layout:setContentSize(self.mCellSize)
        self.mListView:insertCustomItem(layout, index - 1)
    end
    layout:removeAllChildren()

    self.mCellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(595, self.mCellSize.height))
    self.mCellBgSprite:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2)
    layout:addChild(self.mCellBgSprite)

    --消耗资源
    local useResTable = Utility.analysisStrResList(data.useResource)
    --产出资源
    local outResTable = Utility.analysisStrResList(data.outResource)

    -- goods头像
    for i = 1, #outResTable do
        local propCard = require("common.CardNode").new()
        local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        propCard:setCardData({
            resourceTypeSub = outResTable[i].resourceTypeSub,
            modelId = outResTable[i].modelId,
            num = outResTable[i].num,
            cardShowAttrs = showAttrs
        })
        propCard:setAnchorPoint(cc.p(0, 0.5))
        propCard:setPosition((25 * i) + (propCard:getContentSize().width * (i - 1)), self.mCellBgSprite:getContentSize().height / 2)
        self.mCellBgSprite:addChild(propCard)
    end

    -- goods名称
    local goodsName = Utility.getGoodsName(outResTable[1].resourceTypeSub, outResTable[1].modelId)
    local goodColorLv = Utility.getColorLvByModelId(outResTable[1].modelId, outResTable[1].resourceTypeSub)
    local nameColor = Utility.getColorValue(goodColorLv, 1)
    local goodsNameLabel = ui.newLabel({
        text = goodsName,
        color = nameColor,
        -- shadowColor = Enums.Color.eShadowColor,
        outlineColor = Enums.Color.eOutlineColor,
        anchorPoint = cc.p(0, 1),
        x = 130,
        y = self.mCellSize.height - 15,
    })
    self.mCellBgSprite:addChild(goodsNameLabel)

    -- 消耗
    local tokenCoin = useResTable[1].num
    local labelColor = 0
    if self.mHasFairPoint < tokenCoin then
        labelColor = Enums.Color.eRed
    else
        labelColor = Enums.Color.eBlack
    end

    local pvpCoinLabel = ui.newLabel({
        text = string.format("{%s}%s", Utility.getDaibiImage(useResTable[1].resourceTypeSub, useResTable[1].modelId),
        Utility.numberWithUnit(tokenCoin, 0)),
        color = labelColor,
        anchorPoint = cc.p(0, 1),
        x = 130,
        y = self.mCellSize.height - 75,
    })
    self.mCellBgSprite:addChild(pvpCoinLabel)

    -- 每日限购
    if data.maxDailyNum > 0 then
        self.mOneLimitBuyNum = ui.newLabel({
            text = TR("每日限购: %s次", data.maxDailyNum),
            color = Enums.Color.eBlack,
            size = 20,
            anchorPoint = cc.p(0, 1),
            x = 460,
            y = self.mCellSize.height - 86,
        })
        self.mCellBgSprite:addChild(self.mOneLimitBuyNum)
    end

    -- 总限购
    self.mAllLimitBuyNum = ui.newLabel({
        text = TR("总限购: %s次", data.maxTotalNum),
        color = Enums.Color.eBlack,
        anchorPoint = cc.p(0, 0.5),
        x = 130,
        y = self.mCellSize.height * 0.5,
    })
    self.mCellBgSprite:addChild(self.mAllLimitBuyNum)

    if data.maxTotalNum <= 0 then
        self.mAllLimitBuyNum:setVisible(false)
    end

    -- 创建兑换按钮
    local exchangeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("兑换"),
        position = cc.p(520, self.mCellSize.height * 0.5),
        clickAction = function()
            local exchangId = data.ID

            if self.mHasFairPoint < tokenCoin then
                ui.showFlashView({
                    text = TR("资源不足", name)
                })
                return
            end
            -- 玩家拥有资源数量
            local playerResNum = Utility.getOwnedGoodsCount(self.useResTable[1].resourceTypeSub, self.useResTable[1].modelId)
            -- 可兑换数量
            local maxNum = math.floor(playerResNum / useResTable[1].num)
            -- 今日还剩的限购数量
            local maxDailyNum = data.maxDailyNum - self.mNetDataTable[index].TodayBuyCount
            -- 去掉负数
            if maxDailyNum <= 0 then maxDailyNum = maxNum end
            -- 最后可兑换数量
            maxNum = maxNum < maxDailyNum and maxNum or maxDailyNum
            -- 最后资源判断
            if maxNum <= 0 then
                ui.showFlashView(TR("资源不足"))
                return
            end        
            

            -- 参数列表
            local params = {
                title = TR("兑换"),
                exchangePrice = useResTable[1].num,
                goodsNum = outResTable[1].num,
                modelID = outResTable[1].modelId,
                typeID = outResTable[1].resourceTypeSub,
                resourcetypeCoin = self.useResTable[1].resourceTypeSub,
                modelIdCoin = self.useResTable[1].modelId,
                maxNum = maxNum < maxDailyNum and maxNum or maxDailyNum,
                oKCallBack = function(exchangeCount, layerObj, btnObj)
                    if self.mHasFairPoint < useResTable[1].num * exchangeCount then
                        ui.showFlashView(TR("资源不足"))
                        LayerManager.removeLayer(layerObj)
                        return
                    end
                    self:requestChange(index, exchangeCount)
                    LayerManager.removeLayer(layerObj)
                end,
            }
            --兑换弹窗
            MsgBoxLayer.addExchangeGoodsCountLayer(params)
        end,
    })
    self.mCellBgSprite:addChild(exchangeBtn)

    function layout.refresh()
        local todayBuyCount = self.mNetDataTable[index] and self.mNetDataTable[index].TodayBuyCount or 0
        if tonumber(self.mHasFairPoint) < tonumber(tokenCoin) then
            exchangeBtn:setEnabled(false)
        else
            if  data.maxDailyNum > 0 and todayBuyCount >= data.maxDailyNum then
                exchangeBtn:setEnabled(false)
            end
        end
    end
    layout.refresh()
end

--==============================网络请求====================================
-- 请求商品信息
function PvpInterShopLayer:requestGetChangeInfo()
    HttpClient:request({
        moduleName = "PVPinterShopinfo",
        methodName = "ShopInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mNetDataTable = response.Value.BuyShopInfo

            self:initUI()
        end,
    })
end

-- 请求兑换商品
-- {
--     BaseGetGameResourceList:获取资源列表,
-- }
function PvpInterShopLayer:requestChange(propId, exchangeCount)
    HttpClient:request({
        moduleName = "PVPinterShopinfo",
        methodName = "BuyShop",
        svrMethodData = {propId, exchangeCount},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            for index = 1, #response.Value.BuyShopInfo do
                if propId == response.Value.BuyShopInfo[index].ShopId then
                    local dayExchangeCount = response.Value.BuyShopInfo[index].TodayBuyCount
                    self.mNetDataTable[propId].TodayBuyCount = response.Value.BuyShopInfo[index].TodayBuyCount
                    self.mNetDataTable[propId].TotalBuyCount = response.Value.BuyShopInfo[index].TotalBuyCount
                    local allExchangeCount = response.Value.BuyShopInfo[index].TotalBuyCount
                end
            end

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            -- 刷新道具数量
            self.mHasFairPoint = Utility.getOwnedGoodsCount(self.useResTable[1].resourceTypeSub, self.useResTable[1].modelId)
            self.mDaibiView.setNumber(self.mHasFairPoint)
            -- 刷新界面
            self:refreshShopListView()
        end
    })
end

return PvpInterShopLayer