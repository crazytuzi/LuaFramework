--[[
    文件名：ExpediShopLayer.lua
    描述：  组队副本商店
    创建人： yanghongsheng
    创建时间：2017.7.8
-- ]]

local ExpediShopLayer = class("ExpediShopLayer", function(params)
    return display.newLayer()
end)

-- 组队产出(根据商店表里面的售价saleResource字段获取)
local needGoodId = tonumber(string.splitBySep(ExpeditionShopRelation.items[1].saleResource, ",")[2])

-- 初始化
function ExpediShopLayer:ctor(params)
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {
                {
                    resourceTypeSub = ResourcetypeSub.eFunctionProps,
                    modelId = needGoodId
                },
                ResourcetypeSub.eGold,
                ResourcetypeSub.eDiamond
            }
    })
    self:addChild(tempLayer)
    -- self.mCommonLayer = tempLayer
    -- 创建基础UI
    self:initUI()
    -- 请求服务器数据
    self:requestShopInfo()
end

-- ui
function ExpediShopLayer:initUI()
    -- 背景
    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(cc.p(320, 658))
    self.mParentLayer:addChild(bgSprite)
    -- 欢迎光临
    local upBgSprite = ui.newScale9Sprite("zb_02.png")
    upBgSprite:setAnchorPoint(cc.p(0, 1))
    upBgSprite:setPosition(0, 1090)
    self.mParentLayer:addChild(upBgSprite)

    -- 显示npc
    local npcSprite = ui.newSprite("jc_18.png")
    npcSprite:setAnchorPoint(cc.p(0.5, 1))
    npcSprite:setPosition(cc.p(430, 1050))
    self.mParentLayer:addChild(npcSprite)

    -- 提示背景
    local hintBg = ui.newScale9Sprite("c_145.png", cc.size(380, 100))
    hintBg:setAnchorPoint(cc.p(0, 0))
    hintBg:setPosition(-10, 800)
    self.mParentLayer:addChild(hintBg)

    -- 提示信息
    local hintLabel = ui.newLabel({
            text = TR("只有组队通关后才能兑换奖励呦～～～"),
            size = 24,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x30, 0x30, 0x30),
            dimensions = cc.size(300, 0)
        })
    hintLabel:setAnchorPoint(cc.p(0, 0))
    hintLabel:setPosition(30, 820)
    self.mParentLayer:addChild(hintLabel)

    -- 显示面板的背景
    local mInfoBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 780))
    mInfoBgSprite:setAnchorPoint(cc.p(0.5, 0))
    mInfoBgSprite:setPosition(cc.p(320, 0))
    self.mParentLayer:addChild(mInfoBgSprite)

    -- 商品列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(606,590))
    listBg:setAnchorPoint(0.5, 0)
    listBg:setPosition(320, 100)
    self.mParentLayer:addChild(listBg)

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(closeBtn)

    -- 图片信息
    local goodsImage = Utility.getDaibiImage(ResourcetypeSub.eFunctionProps, needGoodId)

    -- 数量背景
    local numBgSize = cc.size(590, 54)
    local haveContrBack = ui.newScale9Sprite("c_25.png", numBgSize)
    haveContrBack:setPosition(cc.p(320, 725))
    self.mParentLayer:addChild(haveContrBack)

    -- 数量Label
    self.mInfoLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eWhite,
        anchorPoint = cc.p(0.5, 0.5),
        size = 22,
        x = numBgSize.width*0.5,
        y = numBgSize.height*0.5,
        outlineColor = Enums.Color.eBlack,
    })
    self.mInfoLabel.refreshCount = function (target)
        target:setString(TR("当前神秘符牌: {%s}%s%d", goodsImage, "#FF952A", Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, needGoodId)))
    end
    self.mInfoLabel:refreshCount()
    haveContrBack:addChild(self.mInfoLabel)

    -- 创建ListView列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(590, 580))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(10)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(320, 105)
    self.mParentLayer:addChild(self.mListView)
end

-- 创建显示的列表控件
function ExpediShopLayer:refreshListView()
    self.mListView:removeAllItems()
    -- 添加数据
    for _, v in pairs(self.shopData.ExpeditionShopInfo) do
        local itemData = ExpeditionShopRelation.items[v.ShopId]
        if itemData then
            itemData.TotalBuyCount = v.TotalBuyCount
            self.mListView:pushBackCustomItem(self:createCellView(itemData))
        end
    end
end

-- 创建列表cell
function ExpediShopLayer:createCellView(info)
    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = 590
    local height = 120
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
    cellSprite:setPosition(cc.p(width / 2, height / 2))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    -- 设置物品头像
    local cardData = string.splitBySep(info.outResource, ",")
    cardData.resourceTypeSub = tonumber(cardData[1])
    cardData.modelId = tonumber(cardData[2])
    cardData.num = tonumber(cardData[3])
    local header = CardNode.createCardNode({
        resourceTypeSub = cardData.resourceTypeSub,
        modelId = cardData.modelId,
        num = cardData.num,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eNum,
            CardShowAttr.eDebris
        },
    })
    header:setPosition(cc.p(60, height/2))
    custom_item:addChild(header)

    -- 显示物品名字
    local nameLabel = ui.newLabel({
        text = Utility.getGoodsName(cardData.resourceTypeSub, cardData.modelId),
        color = Utility.getColorValue(Utility.getColorLvByModelId(cardData.modelId, cardData.resourceTypeSub), 1),
        outlineColor = Enums.Color.eOutlineColor,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(120, cellSize.height * 0.75)
    cellSprite:addChild(nameLabel)

    -- 显示价格
    local saleData = string.splitBySep(info.saleResource, ",")
    saleData.resourceTypeSub = tonumber(saleData[1])
    saleData.modelId = tonumber(saleData[2])
    saleData.num = tonumber(saleData[3])
    local terrLabel = ui.newLabel({
        text = TR("价格:{%s}%s%s",Utility.getDaibiImage(saleData.resourceTypeSub, saleData.modelId), "#d17b00", saleData.num),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    terrLabel:setAnchorPoint(cc.p(0, 0.5))
    terrLabel:setPosition(120, cellSize.height * 0.4)
    cellSprite:addChild(terrLabel)

    -- 显示拥有的碎片数量
    local haveNum = GoodsObj:getCountByModelId(cardData.modelId)
    local maxNum = GoodsModel.items[cardData.modelId].maxNum
    local countLabel = ui.newLabel({
        text = TR("当前拥有: %s%d/%d", ((haveNum >= maxNum) and Enums.Color.eNormalGreenH or "#d17b00"), haveNum, maxNum),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    countLabel:setAnchorPoint(cc.p(0, 0.5))
    countLabel:setPosition(260, cellSize.height * 0.4)
    cellSprite:addChild(countLabel)

    local isSuccessFight = false
    if self.shopData.MaxPassNode ~= 0 and info.needNodeModelID <= self.shopData.MaxPassNode then
        isSuccessFight = true
    end

    if not isSuccessFight then
        local vipLimit = ui.newLabel({
            text = TR("需通关[%s]", ExpeditionNodeModel.items[info.needNodeModelID].name),
            color = Enums.Color.eRed,
            size = 18,
        })
        vipLimit:setPosition(cc.p(width * 0.85, height * 0.45 + 40))
        cellSprite:addChild(vipLimit)
    end

    -- 显示总限购
    local maxBuyLabel = ui.newLabel({
        text = TR("每日限购:%s/%s", info.TotalBuyCount, info.dailyNum),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    maxBuyLabel:setAnchorPoint(cc.p(0, 0.5))
    maxBuyLabel:setPosition(cc.p(300, height * 0.15))
    cellSprite:addChild(maxBuyLabel)
    maxBuyLabel:setVisible(false)
    if info.dailyNum > 0 then
        maxBuyLabel:setVisible(true)
    end

    -- 显示兑换按钮
    local exchangeNum = Utility.getOwnedGoodsCount(saleData.resourceTypeSub, saleData.modelId)
    local exchangeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("兑换"),
        fontSize = 24,
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(width * 0.85, height * 0.45),
        clickAction = function()
            -- 弹出选择数量 参照兑换界面
            local params = {
                title = TR("兑换"),
                exchangePrice = saleData.num,
                modelID = cardData.modelId,
                typeID  = cardData.resourceTypeSub,
                resourcetypeCoin = saleData.resourceTypeSub, -- 精髓的 resourcetype没有 暂时用元宝替代
                modelIdCoin = saleData.modelId,
                maxNum = math.floor(exchangeNum / saleData.num),
                oKCallBack = function(exchangeCount, layerObj, btnObj)
                    if exchangeCount ~= 0 then
                        self:requestBuyItem(info.ID, exchangeCount)
                        layerObj:removeFromParent()
                    else
                        ui.showFlashView({text = TR("请输入数量"),})
                    end
                end,
            }
            self.mMsgLayer = MsgBoxLayer.addExchangeGoodsCountLayer(params)
        end,
    })
    custom_item:addChild(exchangeBtn)

    -- 是否开放购买权限
    exchangeBtn:setEnabled(info.ifOpen)

    if Utility.getOwnedGoodsCount(saleData.resourceTypeSub, saleData.modelId) < saleData.num or info.TotalBuyCount >= info.dailyNum and info.dailyNum ~= 0 then
        exchangeBtn:setEnabled(false)
    end

    -- 购买通关限制
    if not isSuccessFight then
        exchangeBtn:setEnabled(false)
    end

    return custom_item
end

function ExpediShopLayer:refreshUI()
    -- 刷新拥有资源数量
    self.mInfoLabel:refreshCount()
    -- 刷新列表
    self:refreshListView()
end

--[-----------请求网络接口---------]--
function ExpediShopLayer:requestShopInfo()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ShopInfo",
        svrMethodData = {},
        callback = function(data)
            -- 判断返回数据
            if data.Status ~= 0 then
                return
            end

            self.shopData = data.Value

            self:refreshUI()
        end
    })
end

-- 进行道具购买，领取
--[[
params:
    shopId: 商品ID，
    num:    购买数量
]]--
function ExpediShopLayer:requestBuyItem(shopId, num)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "BuyShop",
        svrMethodData = {shopId, num},
        callback = function(data)
            -- 判断返回数据
            if data.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self:requestShopInfo()
        end
    })
end

return ExpediShopLayer
