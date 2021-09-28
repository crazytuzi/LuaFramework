--[[
    文件名：ShengyuanWarsShopLayer
    描述：决战桃花岛商店页面
    创建人：chenzhong
    创建时间：2017.9.2
-- ]]
local ShengyuanWarsShopLayer = class("ShengyuanWarsShopLayer", function()
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

-- 构造函数
function ShengyuanWarsShopLayer:ctor(params)
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化UI
    self:initUI()

    -- 保存数据
    self.mShopInfo = GoddomainShopModel.items

    -- 物品信息分组
    self:dealGoodsInfo()

    -- 刷新listview
    self:refreshListView()

    -- 请求服务器，获取商店
    -- self:requestGodDomainShopInfo()
end

-- 初始化UI元素
function ShengyuanWarsShopLayer:initUI()
    -- 背景框
    local bgSprite = ui.newScale9Sprite("c_94.png", cc.size(634, 670))
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 标题
    local title = ui.newLabel({
        text = TR("商 店"),
        size = 26,
        color = cc.c3b(0x4e, 0x15, 0x0c),
        x = 320,
        y = 880,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mParentLayer:addChild(title)

    -- 当前代币
    local coinImg = Utility.getDaibiImage(ResourcetypeSub.eGodDomainGlory)
    local coinNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eGodDomainGlory)
    local curCoinLabel = ui.newLabel({
            text = TR("当前落英铃: #d17b00{%s}%d", coinImg, coinNum),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    curCoinLabel:setAnchorPoint(cc.p(0, 0.5))
    curCoinLabel:setPosition(40, 840)
    self.mParentLayer:addChild(curCoinLabel)
    self.curCoinLabel = curCoinLabel
    self.curCoinLabel.refesh = function ()
        local coinNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eGodDomainGlory)
        self.curCoinLabel:setString(TR("当前落英铃: #d17b00{%s}%d", coinImg, coinNum))
    end

    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(610, 630),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    bgSprite:addChild(closeBtn)

    -- 添加一张黑色背景图
    local bottomBg = ui.newScale9Sprite("c_97.png", cc.size(570, 545))
    bottomBg:setPosition(317, 30)
    bottomBg:setAnchorPoint(0.5, 0)
    bgSprite:addChild(bottomBg)

    -- 添加ListView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(634, 530))
    self.mListView:setItemsMargin(0)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(634 * 0.5, 35)
    bgSprite:addChild(self.mListView)
end

-- 刷新listview
function ShengyuanWarsShopLayer:refreshListView()
    self.mListView:removeAllItems()
    for i = 1, #self.mGoodsList do
        -- 创建cell
        local width, height = 633, 170
        local cell = ccui.Layout:create()
        cell:setContentSize(cc.size(width, height))

        -- 添加cell
        self:addElementsToCell(cell, i)
        self.mListView:pushBackCustomItem(cell)
    end
end

-- 向创建的cell添加UI元素
--[[
    cell                -- 需要添加UI元素的cell
    cellIndex           -- cell索引号
--]]
function ShengyuanWarsShopLayer:addElementsToCell(cell, cellIndex)
    -- 获取cell数据
    local groupInfo = self.mGoodsList[cellIndex]

    -- 获取cell宽高
    local cellWidth = cell:getContentSize().width
    local cellHeight = cell:getContentSize().height
    for i = 1, #groupInfo do
        -- 矩形框
        local tempBg = ui.newScale9Sprite("c_65.png", cc.size(270, 140))
        tempBg:setAnchorPoint(0.5, 1)
        tempBg:setPosition(i == 1 and cellWidth * 0.28 or cellWidth * 0.72, cellHeight)
        cell:addChild(tempBg)
        local tempSize = tempBg:getContentSize()

        local lineSprite = ui.newScale9Sprite("c_96.png", cc.size(cellWidth-70, 27))
        lineSprite:setPosition(cellWidth/2, -5)
        lineSprite:setAnchorPoint(0.5, 0)
        cell:addChild(lineSprite)

        -- 购买物品
        local goods = Utility.analysisStrResList(groupInfo[i].goods)[1]
        -- 名字
        local colorLv = Utility.getColorLvByModelId(goods.modelId, goods.resourceTypeSub)
        local nameLabel = ui.newLabel({
            text = TR(Utility.getGoodsName(goods.resourceTypeSub, goods.modelId)),
            size = 22,
            color = Utility.getColorValue(colorLv, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            x = tempSize.width * 0.45,
            y = tempSize.height * 0.8,
            align = ui.TEXT_ALIGN_CENTER
        })
        nameLabel:setAnchorPoint(0, 0.5)
        tempBg:addChild(nameLabel)
        ui.createLabelClipRoll({label = nameLabel, dimensions = cc.size(140, 38), anchorPoint = cc.p(0, 0.5)})

        -- 头像
        local header = CardNode.createCardNode({
            resourceTypeSub = goods.resourceTypeSub,
            modelId = goods.modelId,
            num = goods.num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        })
        header:setAnchorPoint(cc.p(0, 0.5))
        header:setPosition(tempSize.width * 0.05, tempSize.height * 0.50)
        tempBg:addChild(header)

        -- 拥有xx
        local ownNum = Utility.getOwnedGoodsCount(goods.resourceTypeSub, goods.modelId)
        local ownLabel = ui.newLabel({
            text = TR("拥有:%s", Utility.numberWithUnit(ownNum)),
            color = cc.c3b(0x56, 0xc6, 0x36),
            anchorPoint = cc.p(0, 0.5),
            x = tempSize.width * 0.45,
            y = tempSize.height * 0.55
        })
        tempBg:addChild(ownLabel)

        -- 所需资源
        local useGoods = Utility.analysisStrResList(groupInfo[i].needCoin)[1]
        local picName = Utility.getDaibiImage(useGoods.resourceTypeSub, useGoods.modelId)
        local ownNum = Utility.getOwnedGoodsCount(useGoods.resourceTypeSub, useGoods.modelId)
        -- 购买按钮
        local buyBtn = ui.newButton({
            normalImage = "c_59.png",
            text = TR("{%s}%s", picName, useGoods.num),
            anchorPoint = cc.p(0 , 0.5),
            position = cc.p(tempSize.width * 0.45, tempSize.height * 0.25),
            clickAction = function()
                if ownNum >= useGoods.num then
                    self:requestGodDomainBuyShopGoods(groupInfo[i].ID)
                else
                    ui.showFlashView({
                        text = TR("%s不足", Utility.getGoodsName(useGoods.resourceTypeSub, useGoods.modelId))
                    })
                end
            end
        })
        tempBg:addChild(buyBtn)
    end
end

-- 整理物品信息，2个为一组
function ShengyuanWarsShopLayer:dealGoodsInfo()
    self.mGoodsList = {}
    local tempList = {}
    for i, v in ipairs(self.mShopInfo) do
        table.insert(tempList, v)
        if i % 2 == 0 then
            table.insert(self.mGoodsList, tempList)
            tempList = {}
        end
    end

    if #tempList ~= 0 then
        table.insert(self.mGoodsList, tempList)
    end
end

-----------------------网络相关-------------------------
-- 请求服务器，获取商店相关数据
function ShengyuanWarsShopLayer:requestGodDomainShopInfo()
    HttpClient:request({
        moduleName = "GodDomain",
        methodName = "GodDomainShopInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
        end
    })
end

-- 请求服务器，购买相应商品
--[[
    goodsIndex               -- 商品编号
--]]
function ShengyuanWarsShopLayer:requestGodDomainBuyShopGoods(goodsIndex)
    HttpClient:request({
        moduleName = "GodDomain",
        methodName = "GodDomainBuyShopGoods",
        svrMethodData = {goodsIndex},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 移除每个cell上的所有，重新添加(其他cell上可能也有当前的商品，需刷新数量)
            for i, v in ipairs(self.mListView:getItems()) do
                v:removeAllChildren()
                self:addElementsToCell(v, i)
            end

            -- 飘窗显示获得的物品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            -- 刷新代币数量显示
            self.curCoinLabel.refesh()
        end
    })
end

return ShengyuanWarsShopLayer