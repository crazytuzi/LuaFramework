--[[
    文件名：ActivityAdvanced.lua
    文件描述：限时活动船只进阶升级
    创建人：lichunsheng
    创建时间：2017.09.15
]]

local ActivityAdvanced = class("ActivityAdvanced",function()
    return display.newLayer()
end)

--构造
function ActivityAdvanced:ctor()
    --所有船的数据
    self.mShopData = clone(GoddomainMountModel.items) or {}
    self:requestGetInfo()
end

--界面初始化
function ActivityAdvanced:initUI()
    --屏蔽下层触控
    ui.registerSwallowTouch({node = self})
    --

    --创建标准适配层
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --创建底部和顶部的控件
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    --创建上部分UI
    local topBgSprite = ui.newSprite("jzthd_72.jpg")
    topBgSprite:setAnchorPoint(cc.p(0.5, 1))
    topBgSprite:setPosition(cc.p(320, 1136))
    self.mParentLayer:addChild(topBgSprite)

    --创建返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        fontSize = 24,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setPosition(cc.p(600, 1030))
    self.mParentLayer:addChild(closeBtn)

    --创建活动说明的label
    local infoLabel = ui.newLabel({
        text = TR("活動期間每儲值#fff44c%d元寶#F7F5F0,獲得#fff44c%d積分#F7F5F0,活動結束後積分清零。", 1, 1),
        size = 24,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x0b, 0x6b, 0x8c),
    })
    infoLabel:setPosition(cc.p(320, 830))
    self.mParentLayer:addChild(infoLabel)

    --创建下半部背景
    local bottomBgSize = cc.size(640, 750)
    local bottomBg = ui.newScale9Sprite("c_19.png", bottomBgSize)
    bottomBg:setAnchorPoint(cc.p(0.5, 0))
    bottomBg:setPosition(cc.p(320, 60))
    self.mParentLayer:addChild(bottomBg)

    --创建LIsteView背景
    local listBg = ui.newSprite("jzthd_73.png")
    listBg:setPosition(cc.p(320, 450))
    self.mParentLayer:addChild(listBg)


    --创建拥有积分的Label以及数量
    local cointLabel = ui.newLabel({
        text = TR("拥有积分："),
        size = 24,
        color = Enums.Color.eBlack,
    })
    cointLabel:setPosition(cc.p(80, 580))
    listBg:addChild(cointLabel)

    local cointBg = ui.newScale9Sprite("c_24.png", cc.size(120, 45))
    cointBg:setPosition(cc.p(190, 580))
    listBg:addChild(cointBg)

    --积分label
    self.mCountLabel = ui.newLabel({
        text = self.mActivityData.Score,
        size = 24,
        color = cc.c3b(0xd1, 0x7b, 0x00),
    })
    self.mCountLabel:setPosition(cc.p(60, 22.5))
    cointBg:addChild(self.mCountLabel)

    --创建活动倒计时的label以及倒计时
    local timeLabel = ui.newLabel({
        text = TR("活动倒计时："),
        size = 24,
        color = Enums.Color.eBlack,
    })
    timeLabel:setPosition(cc.p(380, 580))
    listBg:addChild(timeLabel)

    local timeBg = ui.newScale9Sprite("c_24.png", cc.size(150, 45))
    timeBg:setPosition(cc.p(520, 580))
    listBg:addChild(timeBg)

    self.mCountDownLable = ui.newLabel({
        text = "",
        size = 24,
        color = cc.c3b(0xd1, 0x7b, 0x00),
    })
    self.mCountDownLable:setPosition(cc.p(75, 22.5))
    timeBg:addChild(self.mCountDownLable)


    --倒计时
    Utility.schedule(self.mCountDownLable, function()
        local currTime = self.mActivityData.EndDate - Player:getCurrentTime()
        self.mCountDownLable:setString(TR("%s",  MqTime.formatAsDay(currTime)))
    end, 1)

    --创建去充值按钮
    local punchBtn = ui.newButton({
        normalImage = "sc_03.png",
        fontSize = 24,
        clickAction = function()
            LayerManager.addLayer({
                name = "recharge.RechargeLayer",
                cleanUp = false,
            })
        end
    })
    punchBtn:setPosition(cc.p(320, 130))
    self.mParentLayer:addChild(punchBtn)


    --创建listView
    self.listViewSize = cc.size(600, 530)
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(self.listViewSize)
    self.mListView:setItemsMargin(5)
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(307.5, 544))
    listBg:addChild(self.mListView)

    self:refreshList()
end

function ActivityAdvanced:refreshList()
    --刷新拥有的积分
    self.mCountLabel:setString(self.mActivityData.Score)
    self.mListView:removeAllItems()
    --添加items
    for index, items in pairs(self.mExchangeInfo) do
        local layout = self:addItems(items)
        self.mListView:pushBackCustomItem(layout)
    end
end

--添加items
 --[[
    params说明:
        data：填充layout 的数据
 ]]
function ActivityAdvanced:addItems(data)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(600, 175))

    --创建items背景
    local itemsBg = ui.newScale9Sprite("jzthd_76.png",cc.size(600, 175))
    itemsBg:setPosition(cc.p(300, 87.5))
    layout:addChild(itemsBg)

    --兑换所需模型id
    local baseModelId = data.BaseMountModelId
    --想要兑换的船id
    local targetModelId = data.TargetMountModelId
    --价格
    local price = data.Price
    --折扣
    local discount = data.Discount
    --消耗的船是否拥有
    local isHaveBase = data.IsHaveBaseMount
    --想要兑换的船是否拥有
    local isHaveTarget = data.IsHaveTargetMount
    --档位Id
    local exchangeId = data.ExchangeId

    --创建进阶按钮
    local exchangeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("进 阶"),
        clickAction = function()
            self:requestExchange(exchangeId)
        end
    })
    exchangeBtn:setPosition(cc.p(300, 30))
    itemsBg:addChild(exchangeBtn)


    --创建消耗船
    local costShop = ui.newSprite(self.mShopData[baseModelId].pic..".png")
    costShop:setPosition(cc.p(140, 105))
    itemsBg:addChild(costShop)
    costShop:setScale(0.6)
    --是否拥有消耗船标示
    if isHaveBase == 1 then
        local haveSprite = ui.newSprite("jzthd_74.png")
        haveSprite:setPosition(cc.p(120, 120))
        itemsBg:addChild(haveSprite)
    end

    --创建目标船
    local targetShop = ui.newSprite(self.mShopData[targetModelId].pic..".png")
    targetShop:setPosition(cc.p(460, 105))
    itemsBg:addChild(targetShop)
    targetShop:setScale(0.6)

    --是否拥有目标船标示
    if isHaveTarget == 1 then
        local haveSprite = ui.newSprite("jzthd_74.png")
        haveSprite:setPosition(cc.p(440, 120))
        itemsBg:addChild(haveSprite)
        exchangeBtn:loadTextures("c_82.png", "c_82.png")
    end

    --创建消耗船名
    local costShopName = ui.newLabel({
        text = self.mShopData[baseModelId].name,
        size = 22,
        color = Enums.Color.eWhite,
    })
    costShopName:setPosition(cc.p(140, 20))
    itemsBg:addChild(costShopName)

    --创建目标船名
    local TagetShopName = ui.newLabel({
        text = self.mShopData[targetModelId].name,
        size = 22,
        color = Enums.Color.eWhite,
    })
    TagetShopName:setPosition(cc.p(460, 20))
    itemsBg:addChild(TagetShopName)

    --创建绿色箭头
    local arrow = ui.newSprite("jzthd_75.png")
    arrow:setPosition(cc.p(300, 135))
    itemsBg:addChild(arrow)

    local costLabelY = 80
    if discount < 1 then
        costLabelY = 100
        --创建折扣
        local zhekouSprite = ui.newSprite("jzthd_78.png")
        zhekouSprite:setPosition(cc.p(520, 130))
        itemsBg:addChild(zhekouSprite)

        local discountSprite = ui.newNumberLabel({
            text = tostring(discount * 10),
            imgFile = "jzthd_79.png", -- 数字图片名
        })
        discountSprite:setAnchorPoint(cc.p(0, 0.5))
        discountSprite:setPosition(cc.p(5, zhekouSprite:getContentSize().height / 2))
        zhekouSprite:addChild(discountSprite)

        --折扣积分label
        local discountLabel = ui.newLabel({
            text = TR("+%d积分", price * discount),
            size = 22,
            color = Enums.Color.eWhite,
        })
        discountLabel:setPosition(cc.p(300, 70))
        itemsBg:addChild(discountLabel)

        local __Label = ui.newLabel({
            text = "——————",
            size = 22,
            color = cc.c3b(0xFE, 0x1C, 0x46),
        })
        __Label:setPosition(cc.p(300, costLabelY))
        itemsBg:addChild(__Label)
    end

    --创建积分label
    local costNum = ui.newLabel({
        text = TR("+%d积分", price),
        size = 22,
        color = Enums.Color.eWhite,
    })
    costNum:setPosition(cc.p(300, costLabelY))
    itemsBg:addChild(costNum)


    return layout
end

--=======================网络数据=========================
--请求网络数据
function ActivityAdvanced:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedMountExchange",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value, "初始化数据：")
            --活动配置数据
            self.mActivityData = response.Value.ActivityInfo or {}
            --船只兑换数据
            self.mExchangeInfo = response.Value.MountExchangeInfo or {}
            self:initUI()
        end
    })
end


--船只兑换
function ActivityAdvanced:requestExchange(exchangeId)
    HttpClient:request({
        moduleName = "TimedMountExchange",
        methodName = "Exchange",
        svrMethodData = {exchangeId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value, "兑换之后数据数据：")
            --活动配置数据
            self.mActivityData = response.Value.ActivityInfo or {}
            --船只兑换数据
            self.mExchangeInfo = response.Value.MountExchangeInfo or {}

            self:refreshList()
        end
    })
end


return ActivityAdvanced
