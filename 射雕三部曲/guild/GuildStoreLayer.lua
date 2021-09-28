--[[
    文件名：GuildStoreLayer
    描述：帮派商店
    创建人：chenzhong
    创建时间：2017.3.7
-- ]]

local GuildStoreLayer = class("GuildStoreLayer", function()
    return display.newLayer()
end)

function GuildStoreLayer:ctor()
    -- 初始化
    self.mGuildStoreList = {}         -- 商店物品列表
    self.mStoreLevel = 0              -- 商城等级

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    for _, v in ipairs(GuildObj:getGuildBuildInfo()) do
        if v.BuildingId == 34005000 then
            self.mStoreLevel = v.Lv
        end
    end

    self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eContribution, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 网络相关
    self:requestGetGuildShopBuyList()
end

function GuildStoreLayer:initUI()
	-- 创建背景
    self.mBgSprite = ui.newSprite("c_34.jpg")
    --self.mBgSprite:setPosition(cc.p(320, 568))
    self.mBgSprite:setAnchorPoint(cc.p(0, 0))
    local size = self.mBgSprite:getContentSize()
    self.mBgSprite:setScaleX(640 / size.width)
    self.mBgSprite:setScaleY(1136 / size.height)
    --mapBg1Sprite:setScale(Adapter.MinScale)
    self.mBgSprite:setPosition(0, 0)
    self.mParentLayer:addChild(self.mBgSprite)

    -- 创建人物
    local meinv = ui.newSprite("bp_17.jpg")
    self.mParentLayer:addChild(meinv)
    meinv:setPosition(cc.p(320, 931))

    self.mBgSize = self.mBgSprite:getContentSize()

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
        text = TR("个人贡献值可通过帮派建设或每日任务获取，个人贡献值越多，在帮派商店可兑换的道具越多"),
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
    listBack:setPosition(cc.p(320, 738))
    self.mParentLayer:addChild(listBack)

    -- 商品列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610,534))
    listBg:setPosition(320, 375)
    self.mParentLayer:addChild(listBg)

    --贡献代币图片
    local contributionImage = Utility.getDaibiImage(ResourcetypeSub.eContribution)
    -- 资源名
    local resName = Utility.getGoodsName(ResourcetypeSub.eContribution)

    local haveContrBack = ui.newScale9Sprite("c_24.png", cc.size(120, 35))
    haveContrBack:setPosition(cc.p(240, 675))
    self.mParentLayer:addChild(haveContrBack)

    self.mHaveContributionNum = ui.newLabel({
        text = TR("当前个人%s: {%s}%s%d", resName, contributionImage, "#BD6E00", PlayerAttrObj:getPlayerAttrByName("Contribution")),
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0.5),
        size = 22,
        x = 10,
        y = 675,
        })
    self.mParentLayer:addChild(self.mHaveContributionNum)

    Notification:registerAutoObserver(self.mHaveContributionNum,
        function()
            local nowValue = PlayerAttrObj:getPlayerAttrByName("Contribution")
            self.mHaveContributionNum:setString(TR("当前个人%s: {%s}%s%d", Utility.getGoodsName(ResourcetypeSub.eContribution),
            contributionImage, "#BD6E00", 
            PlayerAttrObj:getPlayerAttrByName("Contribution")))
        end, {EventsName.eContribution})

    -- 商店等级label
    local sp = ui.newScale9Sprite("c_24.png", cc.size(120, 35))
    sp:setPosition(cc.p(510, 675))
    self.mParentLayer:addChild(sp)

    local storeLevelLabel = ui.newLabel({
        text = TR("商店等级: %s    %d", "#BD6E00", self.mStoreLevel),
        anchorPoint = cc.p(0, 0.5),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
        })
    storeLevelLabel:setPosition(cc.p(350, 675))
    self.mParentLayer:addChild(storeLevelLabel)
end

function GuildStoreLayer:createListView()
    -- 创建ListView列表
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ListViewDirection.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(610, 515))
    self.listView:setGravity(ccui.ListViewGravity.centerVertical)
    self.listView:setPosition(cc.p(320, 635))
    self.listView:setAnchorPoint(cc.p(0.5, 1))
    self.mParentLayer:addChild(self.listView)

    for i = 1, #self.mGuildStoreList do
        self.listView:pushBackCustomItem(self:createCellView(i))
    end
end

function GuildStoreLayer:createCellView(index)
    local info = self.mGuildStoreList[index]

    local cellSize = cc.size(610, 125)

    local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cellSize)

    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(582,118))
    cellSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    custom_item:addChild(cellSprite)

    local offfsety = -20 -- 位置Y偏移量

    -- 头像
    local goodsHeader = CardNode.createCardNode({
        resourceTypeSub = info.TypeId,
        modelId = info.ModelId,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eNum,
         },
        num = info.Num,
    })
    goodsHeader:setScale(1.1)
    goodsHeader:setAnchorPoint(cc.p(0.5, 0.5))
    goodsHeader:setPosition(cc.p(80, 80 + offfsety))
    cellSprite:addChild(goodsHeader)

    offfsety = offfsety + 8
    -- 名字
    local nameLabel = ui.newLabel({
            text = Utility.getGoodsName(info.TypeId, info.ModelId),
            color = Utility.getColorValue(Utility.getColorLvByModelId(info.ModelId, info.TypeId), 1),
            anchorPoint = cc.p(0, 0.5),
            x = 150,
            y = 105 + offfsety + 2,
            size = 22,
            outlineColor = Enums.Color.eBlack,
            outlineSize = 2,
        })
    cellSprite:addChild(nameLabel)

    -- 消耗贡献
    local needCoin = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eContribution,
        number = info.NeedCoin,
        fontColor = Enums.Color.eDarkGreen,
        fontSize = 22,
        })
    needCoin:setScale(0.9)
    needCoin:setAnchorPoint(cc.p(0, 0.5))
    needCoin:setPosition(cc.p(150, 70 + offfsety - 2))
    cellSprite:addChild(needCoin)

    -- 今日可兑换几次
    local cishuLabel = ui.newLabel({
        text = "",
        anchorPoint = cc.p(0, 0.5),
        x = 150,
        y = 35 + offfsety - 2,
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    cellSprite:addChild(cishuLabel)

    if info.PerMaxNum == 0 then
        cishuLabel.numType = 1 -- 可兑换%d次
        cishuLabel.canUseNum = info.TotalMaxNum - info.BuyNum
        cishuLabel.maxNum = info.TotalMaxNum
        cishuLabel:setString(TR("可兑换%s%d%s次", Enums.Color.eDarkGreenH, cishuLabel.canUseNum, "#46220d"))
    else
        cishuLabel.numType = 2 -- 今日可兑换%d次
        cishuLabel.canUseNum = info.PerMaxNum - info.BuyNum
        cishuLabel.maxNum = info.PerMaxNum
        cishuLabel:setString(TR("今日可兑换%s%d%s次", Enums.Color.eDarkGreenH, cishuLabel.canUseNum, "#46220d"))
    end

    -- 购买
    local buyButton
    buyButton = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(520, 80 + offfsety),
        text = TR("购买"),
        fontSize = 21,
        clickAction = function()
            --dump(info, "infoasdsajdadjs0000----")

            if not Utility.isResourceEnough(ResourcetypeSub.eContribution, info.NeedCoin) then
                ui.showFlashView({text = TR("个人贡献不足")})
                return
            end
            
            -- 选择购买界面
            local shopId = info.Id
            local maxNum = 0
            -- 购买数量限制
            if cishuLabel.numType == 1 then
                maxNum = info.TotalMaxNum - info.BuyNum
            else
                maxNum = info.PerMaxNum - info.BuyNum
            end
            -- 代币限制
            local daibiOwnNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eContribution)
            local daibiBuyNum = math.floor(daibiOwnNum / info.NeedCoin)
            -- 购买最大数量
            maxNum = maxNum < daibiBuyNum and maxNum or daibiBuyNum

            if maxNum == 1 then -- 只购买一次不弹多次购买弹窗
                self:requestGuildShopBuy(info.Id, maxNum,function ()
                    cishuLabel.canUseNum = cishuLabel.canUseNum - maxNum
                    if cishuLabel.numType == 1 then
                        cishuLabel:setString(TR("可兑换%s%d%s次", Enums.Color.eDarkGreenH, cishuLabel.canUseNum, "#46220d"))
                    else
                        cishuLabel:setString(TR("今日可兑换%s%d%s次", Enums.Color.eDarkGreenH, cishuLabel.canUseNum, "#46220d"))
                    end

                    if cishuLabel.canUseNum <= 0 then
                        buyButton:setEnabled(false)
                    end
                    --  关闭按钮
                    LayerManager.removeLayer(self.mMsgLayer)
                end)
            else
                local params = {
                    title = TR("兑换"),                          
                    exchangePrice = info.NeedCoin,
                    modelID = info.ModelId,
                    typeID = info.TypeId,
                    resourcetypeCoin = ResourcetypeSub.eContribution, 
                    maxNum = maxNum,                          
                    oKCallBack = function(exchangeCount, layerObj, btnObj)
                        self:requestGuildShopBuy(info.Id, exchangeCount,function ()
                            cishuLabel.canUseNum = cishuLabel.canUseNum - exchangeCount
                            if cishuLabel.numType == 1 then
                                cishuLabel:setString(TR("可兑换%s%d%s次", Enums.Color.eDarkGreenH, cishuLabel.canUseNum, "#46220d"))
                            else
                                cishuLabel:setString(TR("今日可兑换%s%d%s次", Enums.Color.eDarkGreenH, cishuLabel.canUseNum, "#46220d"))
                            end

                            if cishuLabel.canUseNum <= 0 then
                                buyButton:setEnabled(false)
                            end
                            --  关闭按钮
                            LayerManager.removeLayer(self.mMsgLayer)
                        end)
                    end,                      
                }
                self.mMsgLayer = MsgBoxLayer.addExchangeGoodsCountLayer(params)
            end
        end,
    })

    if cishuLabel.canUseNum <= 0 or self.mStoreLevel < info.NeedBuildingLv then
        buyButton:setEnabled(false)
    end

    if self.mStoreLevel < info.NeedBuildingLv then
        local openLabel = ui.newLabel({
            text = TR("商店%s%d级%s开放", Enums.Color.eOrangeH, info.NeedBuildingLv, "#46220d"),
            x = 505,
            y = 35 + offfsety - 5,
            size = 18,
            color = cc.c3b(0x46, 0x22, 0x0d)
            })
        cellSprite:addChild(openLabel)
    end

    custom_item:addChild(buyButton)

    return custom_item
end

-- =============================== 请求服务器数据相关函数 ===================

function GuildStoreLayer:requestGuildShopBuy(id, num, callBack)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildShopBuy",
        svrMethodData = {id, num},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            
            --刷新页面
            callBack()
        end,
    })
end

function GuildStoreLayer:requestGetGuildShopBuyList()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildShopBuyList",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mGuildStoreList = response.Value.GuildShopInfo
            --dump(self.mGuildStoreList, "sadjasdjsdj0------")

            -- 建列表
            self:createListView()
        end,
    })
end

return GuildStoreLayer
