--[[
    文件名：AuctionHouseLayer.lua
    文件描述：门派boss拍卖行
    创建人：peiyaoqiang
    创建时间：2017.11.20
]]

local AuctionHouseLayer = class("AuctionHouseLayer",function()
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

local tagOfButtons = {
    tagDefault = 0,     -- 未初始化
    tagAllList = 1,     -- 所有商品
    tagMyList = 2,      -- 我的竞拍
}

-- 初始化
function AuctionHouseLayer:ctor()
    -- 屏蔽下层触控
    ui.registerSwallowTouch({node = self})

    -- 参数
    self.selectTag = tagOfButtons.tagDefault

    -- 创建适配父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 背景图
    local parentSprite = ui.newSprite("mjrq_18.png")
    parentSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(parentSprite)

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(40, 970),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.魔教被击退后，所有掉落物品均在拍卖行中进行竞拍"),
                TR("2.拍卖行截止时间为14点，无人参与竞拍的物品将会流拍"),
                TR("3.拍卖获得的物品将在拍卖结束后通过领奖中心发放"),
                TR("4.本次拍卖获得的全部元宝，将在拍卖结束后通过领奖中心，分红给魔教入侵个人伤害排行榜上的玩家，每位玩家最多分红2000元宝"),
                TR("5.竞拍结束后，剩余十分钟展示期，展示拍卖结果。"),
            })
        end})
    self.mParentLayer:addChild(ruleBtn)
    
    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 970),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 排行榜按钮
    local rankBtn = ui.newButton({
        normalImage = "tb_16.png",
        position = cc.p(150, 985),
        clickAction = function()
            LayerManager.addLayer({name = "sect.SectBossRankLayer", cleanUp = false,})
        end
    })
    self.mParentLayer:addChild(rankBtn)

    -- 界面
    self:initUI()

    -- 获取竞拍信息
    self:requestGetInfo()
end

-- 初始化界面
function AuctionHouseLayer:initUI()
    -- 列表背景图
    local listBgSize = cc.size(584, 650)
    local listBgSprite = ui.newScale9Sprite("bg_06.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 1))
    listBgSprite:setPosition(320, 870)
    self.mParentLayer:addChild(listBgSprite)

    -- 物品列表
    local listViewSize = cc.size(listBgSize.width, listBgSize.height - 20)
    local mListView = ccui.ListView:create()
    mListView:setContentSize(listViewSize)
    mListView:setAnchorPoint(0.5, 0.5)
    mListView:setPosition(listBgSize.width * 0.5, listBgSize.height * 0.5)
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    listBgSprite:addChild(mListView)
    self.mListView = mListView

    -- 空白提示
    local emptyHintSprite = ui.createEmptyHint(TR("暂时没有商品哦"))
    emptyHintSprite:setPosition(listBgSize.width * 0.5, listBgSize.height * 0.5)
    listBgSprite:addChild(emptyHintSprite)
    self.emptyHintSprite = emptyHintSprite

    -- 倒计时文字
    local timeLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        anchorPoint = cc.p(0, 0.5),
        x = 320,
        y = 920,
    })
    self.mParentLayer:addChild(timeLabel)
    self.timeLabel = timeLabel

    -- 总收入文字
    local moneyLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        anchorPoint = cc.p(0, 0.5),
        x = 320,
        y = 890,
    })
    self.mParentLayer:addChild(moneyLabel)
    self.moneyLabel = moneyLabel

    -- 竞拍列表和我的竞拍
    local tabItemList = {
        {tag = tagOfButtons.tagAllList, name = TR("竞拍列表"), posX = 110}, 
        {tag = tagOfButtons.tagMyList, name = TR("我的竞拍"), posX = 240}, 
    }
    self:createCustomTab(tabItemList)

    -- 箭头
    local upSprite = ui.newSprite("c_26.png")
    local downSprite = ui.newSprite("c_26.png")
    upSprite:setRotation(265)
    downSprite:setRotation(85)
    upSprite:setPosition(320, 865)
    downSprite:setPosition(320, 225)
    self.mParentLayer:addChild(upSprite)
    self.mParentLayer:addChild(downSprite)

    -- 确定按钮
    local btnOk = ui.newButton({
        normalImage = "c_28.png",
        text = TR("刷新列表"),
        position = cc.p(320, 185),
        clickAction = function()
            self:requestGetInfo()
        end
    })
    self.mParentLayer:addChild(btnOk)
end

-- 刷新界面
function AuctionHouseLayer:refreshUI()
    --dump(self.auctionInfo, "self.auctionInfo")
    if (self.auctionInfo == nil) then
        return
    end
    if (self.selectTag == tagOfButtons.tagDefault) then
        return
    end

    -- 刷新倒计时
    local nTime = self.auctionInfo.AuctionEndTime or 0
    local auctionEndTime = MqTime.getConfigTime(AuctionConfig.items[1].endTime)
    self.timeLabel:stopAllActions()
    Utility.schedule(self.timeLabel, function () 
            local lastTime = nTime - Player:getCurrentTime()
            local leftTime = auctionEndTime - Player:getCurrentTime()
            if (lastTime <= 0) then
                LayerManager.removeLayer(self)
                ui.showFlashView(TR("本次拍卖活动已经结束"))
            elseif leftTime <= 0 then
            	self.timeLabel:stopAllActions()
            	self.timeLabel:setString(TR("竞拍已结束"))
            else
                self.timeLabel:setString(TR("剩余时间 %s%s", Enums.Color.eNormalGreenH, MqTime.formatAsHour(leftTime)))
            end
        end, 0.5)
    self.moneyLabel:setString(TR("本次拍卖已收入:{%s}%s%s", Utility.getDaibiImage(ResourcetypeSub.eDiamond), Enums.Color.eNormalGreenH, self.auctionInfo.TotalNum))

    -- 清空以前的内容
    self.mListView:removeAllItems()
    self.emptyHintSprite:setVisible(false)

    -- 读取要显示的内容
    local showList = {}
    local function analyzeGoodStr(str)
        local list = string.split(str, ",")
        return {goodType = tonumber(list[1]), modelId = tonumber(list[2]), goodNum = tonumber(list[3])}
    end
    local tempList = (self.selectTag == tagOfButtons.tagAllList) and self.auctionInfo.AuctionConfig or self.auctionInfo.AuctionInfo
    for _,v in pairs(tempList or {}) do
        local tmpV = clone(v)
        tmpV.GoodItem = clone(AuctionShop.items[tonumber(v.ShopId)][tonumber(v.Id)])
        tmpV.GoodInfo = analyzeGoodStr(tmpV.GoodItem.auctionGoods)
        tmpV.CurPrice = analyzeGoodStr(v.AuctionUseResouce)
        tmpV.TopPrice = analyzeGoodStr(tmpV.GoodItem.finishPrice)
        tmpV.Quality = Utility.getQualityByModelId(tmpV.GoodInfo.modelId, tmpV.GoodInfo.goodType)
        table.insert(showList, tmpV)
    end
    if (showList == nil) or (table.nums(showList) == 0) then
        self.emptyHintSprite:setVisible(true)
        return
    end

    -- 排序并显示列表
    table.sort(showList, function (a, b)
            -- 已被拍的放到最后
            if (a.IsFinishPrice ~= b.IsFinishPrice) then
                return (a.IsFinishPrice == false)
            end
            -- 品质高的优先
            if (a.Quality ~= b.Quality) then
                return a.Quality > b.Quality
            end
            -- 价格低的优先
            if (a.CurPrice.goodNum ~= b.CurPrice.goodNum) then
                return a.CurPrice.goodNum < b.CurPrice.goodNum
            end
            return a.TopPrice.goodNum < b.TopPrice.goodNum
        end)
    self:showAuctionList(showList)
end

----------------------------------------------------------------------------------------------------
-- 辅助接口

-- 显示竞拍列表
function AuctionHouseLayer:showAuctionList(showList)
    -- 一口价上限（在一口价配置达到该限制时，不显示一口价，及一口价按钮）
    local topPriceLimit = 99999

    local listViewSize = self.mListView:getContentSize()
    local function addOneGood(index, parent, pos)
        local item = showList[index]
        if (item == nil) then
            return
        end

        -- 背景底板
        local bgPanelSprite = ui.newSprite("mjrq_17.png")
        local bgPanelSize = bgPanelSprite:getContentSize()
        bgPanelSprite:setPosition(pos)
        parent:addChild(bgPanelSprite)

        -- 头像
        local list = string.split(item.GoodItem.auctionGoods, ",")
        local tempCard = CardNode:create({
            allowClick = true,
        })
        tempCard:setCardData({
            resourceTypeSub = tonumber(list[1]),
            modelId = tonumber(list[2]),
            num = tonumber(list[3]),
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}, 
        })
        tempCard:setPosition(cc.p(65, 90))
        bgPanelSprite:addChild(tempCard)

        -- 出价人
        local nameDefault = TR("暂无报价")
        local nameColor = Enums.Color.eNormalWhite
        local strPlayerName = (item.PlayerID == EMPTY_ENTITY_ID) and nameDefault or (item.PlayerName or nameDefault)
        if (strPlayerName ~= nameDefault) then
            if (strPlayerName == PlayerAttrObj:getPlayerInfo().PlayerName) then
                nameColor = Enums.Color.eGreen
            end
            strPlayerName = TR("出价最高:") .. strPlayerName
        end
        local nameLabel = ui.newLabel({
            text = strPlayerName,
            color = nameColor,
            outlineColor = Enums.Color.eBlack,
            x = bgPanelSize.width * 0.5,
            y = bgPanelSize.height - 32,
        })
        bgPanelSprite:addChild(nameLabel)

        -- 显示价格
        local function showPrice(priceName, priceColor, priceItem, posY)
            local priceText = ""
            if priceItem then
                priceText = string.format("%s{%s}%s", priceName, Utility.getDaibiImage(priceItem.goodType, priceItem.modelId), priceItem.goodNum)
            else
                priceText = priceName
            end
            local label = ui.newLabel({
                text = priceText,
                color = priceColor,
                size = 20,
                x = 115,
                y = posY,
            })
            label:setAnchorPoint(cc.p(0, 0.5))
            bgPanelSprite:addChild(label)
        end
        showPrice(TR("当前价:"), cc.c3b(0x46, 0x22, 0x0d), item.CurPrice, 110)
        if topPriceLimit > item.TopPrice.goodNum then
            showPrice(TR("一口价:"), Enums.Color.eWineRed, item.TopPrice, 70)
        else
            showPrice(TR("无一口价"), cc.c3b(0x46, 0x22, 0x0d), nil, 70)
        end

        -- 显示按钮
        local function showButton(btnName, posX, action)
            local button = ui.newButton({
                normalImage = "c_59.png",
                text = btnName,
                fontSize = 24,
                clickAction = function ()
                    -- if (self.auctionInfo.IsBattle == false) then
                    --     ui.showFlashView(TR("您没有参加今日的魔教入侵，不能参与竞拍"))
                    --     return
                    -- end
                    action()
                end
            })
            button:setScale(0.75)
            button:setPosition(posX, 30)
            button:setEnabled((item.IsFinishPrice == nil) or (item.IsFinishPrice == false))
            bgPanelSprite:addChild(button)
        end
        local auctionEndTime = MqTime.getConfigTime(AuctionConfig.items[1].endTime)
        showButton(TR("竞拍"), 160, function ()
        		if auctionEndTime < Player:getCurrentTime() then
        			ui.showFlashView(TR("竞拍已结束"))
        			return
        		end
                self:dlgBuyOfAuction(item)
            end)
        if topPriceLimit > item.TopPrice.goodNum then
            showButton(TR("一口价"), 240, function ()
            		if auctionEndTime < Player:getCurrentTime() then
	        			ui.showFlashView(TR("竞拍已结束"))
	        			return
	        		end
                    self:dlgBuyOfFixedPrice(item)
                end)
        end

        -- 已被拍走
        if (item.IsFinishPrice ~= nil) and (item.IsFinishPrice == true) then
            local finishLabel = ui.createSpriteAndLabel({
                imgName = "c_157.png",
                labelStr = TR("已被拍"),
                fontSize = 24,
            })
            finishLabel:setRotation(315)
            finishLabel:setPosition(160, 90)
            bgPanelSprite:addChild(finishLabel, 1)
        end
    end

    -- 遍历所有商品
    local nCount = #showList
    local nLine = math.ceil(nCount / 2)
    for i=1,nLine do
        local layout = ccui.Layout:create()
        layout:setContentSize(listViewSize.width, 210)
        self.mListView:pushBackCustomItem(layout)

        -- 顺序添加
        addOneGood(((i-1)*2)+1, layout, cc.p(listViewSize.width * 0.25 + 1, 105))
        addOneGood(((i-1)*2)+2, layout, cc.p(listViewSize.width * 0.75 - 1, 105))
    end
end

-- 创建特殊Tab
function AuctionHouseLayer:createCustomTab(tabItemList)
    local tabButtonList = {}
    
    -- 辅助接口：选择一个按钮
    local function showButton(tag)
        if (self.selectTag == tag) then
            return
        end
        self.selectTag = tag

        -- 刷新按钮图
        for _,v in ipairs(tabButtonList) do
            if (v:getTag() == self.selectTag) then
                v:loadTextures("c_154.png", "c_154.png")
            else
                v:loadTextures("c_155.png", "c_155.png")
            end
        end
        -- 执行点击事件
        self:refreshUI()
        self.mListView:jumpToTop()
        if (self.selectTag == tagOfButtons.tagMyList) then
            self:requestEnterMyAuction()
        end
    end

    -- 创建按钮列表
    for _,v in ipairs(tabItemList) do
        local button = ui.newButton({
            normalImage = "c_155.png",
            position = cc.p(v.posX, 905),
            clickAction = function()
                showButton(v.tag)
            end
        })
        button:setTag(v.tag)
        self.mParentLayer:addChild(button)

        -- 按钮标题
        local btnSize = button:getContentSize()
        local label = ui.newLabel({
            text = v.name,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = btnSize.width * 0.5,
            y = btnSize.height * 0.5,
        })
        button:addChild(label)

        table.insert(tabButtonList, button)
    end
    showButton(1)

    -- 创建被竞拍的小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eWorldBossAuctionRedPoint))
    end
    ui.createAutoBubble({parent = tabButtonList[2], imgName ="c_115.png", position = cc.p(0.8, 1.0),
        eventName = RedDotInfoObj:getEvents(ModuleSub.eWorldBossAuctionRedPoint), refreshFunc = dealRedDotVisible})
end

----------------------------------------------------------------------------------------------------
-- 

-- 弹出竞拍的对话框
function AuctionHouseLayer:dlgBuyOfAuction(item)
    local goodInfo = item.TopPrice
    local auctionNum = item.GoodInfo.goodNum or 1
    local auctionName = Utility.getGoodsName(item.GoodInfo.goodType, item.GoodInfo.modelId)
    -- 计算可购买最大数量
    local lowPriceInfo = Utility.analysisStrResList(item.GoodItem.needIchor)
    local perPrice = math.floor(lowPriceInfo[1].num * 0.1)
    -- 取当前拥有的和需要的最大值
    local maxNum = goodInfo.goodNum - item.CurPrice.goodNum
    local ownedNum = PlayerAttrObj:getPlayerAttr(goodInfo.goodType)
    maxNum = maxNum > ownedNum and ownedNum or maxNum
    local maxCount = math.floor(maxNum / perPrice)

    if maxCount > 0 then
        -- 打开竞拍对话框
        MsgBoxLayer.addAuctionLayer(
            {
                auctionName = auctionName,
                auctionNum = auctionNum,
                dbType = goodInfo.goodType,
                dbModelId = goodInfo.modelId,
                curPrice = item.CurPrice.goodNum,
                topCount = maxCount,
                perPrice = perPrice,
            }, 
            function (auctionCount, layerObj, btnObj)
                LayerManager.removeLayer(layerObj)
                if not tolua.isnull(self) then
                    self:requestAuction(item, 0, (item.CurPrice.goodNum + auctionCount * perPrice))
                end
            end
        )
    else
        ui.showFlashView(TR("该物品不能再加价了"))
    end
end

-- 弹出一口价的对话框
function AuctionHouseLayer:dlgBuyOfFixedPrice(item)
    local goodInfo = item.TopPrice
    local goodImage =  Utility.getDaibiImage(goodInfo.goodType, goodInfo.modelId)
    local anctionNum = item.GoodInfo.goodNum or 1
    local anctionName = Utility.getGoodsName(item.GoodInfo.goodType, item.GoodInfo.modelId)
    MsgBoxLayer.addOKCancelLayer(
        TR("是否以{%s}%s%d%s拍下%s%s*%d", goodImage, Enums.Color.eGreenH, goodInfo.goodNum, Enums.Color.eNormalWhiteH, Enums.Color.eGreenH, anctionName, anctionNum),
        TR("一口价"),
        {
            text = TR("确定"),
            clickAction = function(layerObj, btnObj)
                LayerManager.removeLayer(layerObj)
                if not tolua.isnull(self) then
                    self:requestAuction(item, 1)
                end
            end
        },
        {
            text = TR("取消")
        }
    )
end

----------------------------------------------------------------------------------------------------
-- 网络请求相关接口

-- 获取竞拍信息列表
function AuctionHouseLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "GlobalAuction",
        methodName = "GetAuctionInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.auctionInfo = clone(response.Value)
            self:refreshUI()
        end
    })
end

-- 拍下某个商品
--[[
    item: 商品信息
    isTopPrice: 是否一口价
    myPrice: 出价的钻石数量
--]]
function AuctionHouseLayer:requestAuction(item, isTopPrice, myPrice)
    -- 判断资源是否足够
    local nPrice = myPrice or item.TopPrice.goodNum
    if (Utility.isResourceEnough(ResourcetypeSub.eDiamond, nPrice, true) == false) then
        return
    end

    -- 请求接口
    HttpClient:request({
        moduleName = "GlobalAuction",
        methodName = "Auction",
        svrMethodData = {item.ShopId, item.OrderId, isTopPrice, nPrice},
        callback = function(response)
            if (response.Status == -3444) then
                ui.showFlashView(TR("有玩家先出价了，请重新出价竞拍~~"))
            elseif (response.Status == -11003) then
                ui.showFlashView(TR("少侠手慢了，该商品已被别人拍走~~"))
            end
            -- 不管成功失败，都刷新当前界面
            self:requestGetInfo()
        end
    })
end

-- 进入我的竞拍页面时调用（服务端处理小红点用，没有参数和返回值）
function AuctionHouseLayer:requestEnterMyAuction()
    -- 请求接口
    HttpClient:request({
        moduleName = "GlobalAuction",
        methodName = "InMyAuction",
        svrMethodData = {},
        callback = function(response)
        end
    })
end

return AuctionHouseLayer
