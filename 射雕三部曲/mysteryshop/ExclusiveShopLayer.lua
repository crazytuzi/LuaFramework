--[[
	文件名：ExclusiveShopLayer.lua
	描述：神秘商店之专属卖场分页面
	创建人：libowen
	创建时间：2016.7.7
--]]

-- 该页面作为子节点添加到已适配的父节点上，坐标按照 640 1136来即可
local ExclusiveShopLayer = class("ExclusiveShopLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
    params:
    Table params:
    {

    }
--]]
function ExclusiveShopLayer:ctor(params)
	self:setContentSize(640, 1136)

	-- 初始化UI
	self:initUI()

	-- 请求服务器，获取专属卖场数据
	self:requestSVipGetInfo()
end

-- 初始化UI元素
function ExclusiveShopLayer:initUI()
    -- 背景框
    local bgSpr = ui.newSprite("hs_05.png")
    bgSpr:setPosition(320, 550)
    self:addChild(bgSpr)

    -- XXX专属卖场标题
    local title = ui.newLabel({
        text = TR("%s专属卖场", PlayerAttrObj:getPlayerAttrByName("PlayerName")),
        color = Enums.Color.eBrown,
        x = 320,
        y = 943,
        align = ui.TEXT_ALIGN_CENTER
    })
    self:addChild(title)

    -- 添加ListView
    self:addListView()
end

-- 创建物品滑动列表
function ExclusiveShopLayer:addListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 750))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(320, 1136 - 218)
    self:addChild(self.mListView)
end

-- 整理物品信息，2个为一组
function ExclusiveShopLayer:handleGoodsInfo()
    self.mGoodsList = {}
    local tempList = {}
    for i = 1, #self.mShopInfo.MysteryShopGoodsList do
        table.insert(tempList, self.mShopInfo.MysteryShopGoodsList[i])
        if i % 2 == 0 then
            table.insert(self.mGoodsList, tempList)
            tempList = {}
        end
    end

    if #tempList ~= 0 then
        table.insert(self.mGoodsList, tempList)
    end
end

-- 获取数据后，刷新ListView
function ExclusiveShopLayer:refreshListView()
    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, #self.mGoodsList do
        -- 创建cell
        local cellWidth, cellHeight = 640, 188
        local customCell = ccui.Layout:create()
        customCell:setContentSize(cc.size(cellWidth, cellHeight))

        -- 向已创建的cell添加UI元素
        self:addElementsToCell(customCell, i)

        -- 添加cell到listview
        self.mListView:pushBackCustomItem(customCell)
    end
end


-- 向创建的cell添加UI元素
--[[
    cell                -- 需要添加UI元素的cell
    cellIndex           -- cell索引号
--]]
function ExclusiveShopLayer:addElementsToCell(cell, cellIndex)
    -- 获取cell数据
    local groupInfo = self.mGoodsList[cellIndex]

    -- 获取cell宽高
    local cellWidth = cell:getContentSize().width
    local cellHeight = cell:getContentSize().height

    -- 格子坐标
    local boxPos = {
        [1] = cc.p(cellWidth * 0.28, cellHeight * 0.5),
        [2] = cc.p(cellWidth * 0.72, cellHeight * 0.5)
    }
    for i = 1, #groupInfo do
        -- 格子
        local cellBox = ui.newSprite("hs_10.png")
        cellBox:setPosition(boxPos[i])
        cell:addChild(cellBox)
        local boxSize = cellBox:getContentSize()

        -- 头像
        local header = CardNode.createCardNode({
            resourceTypeSub = groupInfo[i].SellResourceTypeSub,
            modelId = groupInfo[i].SellGoodsModelId,
            num = groupInfo[i].SellNum,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr,eDebris}
        })
        header:setAnchorPoint(cc.p(0, 0.5))
        header:setPosition(boxSize.width * 0.1, boxSize.height * 0.5)
        cellBox:addChild(header)

        -- 今日限购XX次标签
        local timesLeft = MysteryshopConfig.items[1].SVipShopPurchaseS - groupInfo[i].BuyCount
        local timesLabel = ui.newLabel({
            text = TR("今日限购:%s", timesLeft),
            x = boxSize.width * 0.73,
            y = boxSize.height * 0.9,
            color = Enums.Color.eWhite,
            align = ui.TEXT_ALIGN_CENTER
        })
        cellBox:addChild(timesLabel)

        -- 原价标签
        local picName = Utility.getResTypeSubImage(groupInfo[i].BuyResourceTypeSub)
        local oldPriceLabel = ui.newLabel({
            text = TR("{%s} %d", picName, groupInfo[i].OldUseNum),
            color = Enums.Color.eDarkGreen,
            align = ui.TEXT_ALIGN_CENTER
        })
        oldPriceLabel:setPosition(boxSize.width * 0.7, boxSize.height * 0.71)
        cellBox:addChild(oldPriceLabel)
        -- 删除线        
        -- todo

        -- 现价标签
        local currPriceLabel = ui.createLabelWithBg({
            bgFilename = "c_85.png",
            bgSize = cc.size(100, 45),
            labelStr = TR("{%s}%d", picName, groupInfo[i].BuyNum),
            color = Enums.Color.eBrown,
            alignType = ui.TEXT_ALIGN_CENTER
        })
        currPriceLabel:setPosition(boxSize.width * 0.72, boxSize.height * 0.47)
        cellBox:addChild(currPriceLabel)

        -- 购买按钮
        local buyButton = ui.newButton({
            normalImage = "c_16.png",
            size = cc.size(127 * 0.8, 55 * 0.8),
            text = TR("购买"),
            position = cc.p(boxSize.width * 0.72, boxSize.height * 0.18),
            clickAction = function()
                -- 购买花费全是代币，获取代币名
                local name = ResourcetypeSubName[groupInfo[i].BuyResourceTypeSub]
                local haveNum = PlayerAttrObj:getPlayerAttr(groupInfo[i].BuyResourceTypeSub)
                
                if haveNum >= groupInfo[i].BuyNum then
                    self:requestSVipMysteryShopBuyGoods(groupInfo[i].Id, cellIndex)
                else
                    -- 元宝不足给弹窗提示，其他资源不足给飘窗提示
                    if groupInfo[i].BuyResourceTypeSub == ResourcetypeSub.eDiamond then
                        MsgBoxLayer.addGetDiamondHintLayer()
                    else
                        ui.showFlashView({
                            text = TR("%s不足", name)
                        })
                    end
                end
            end
        })
        cellBox:addChild(buyButton)

        if timesLeft == 0 then
            buyButton:setEnabled(false)
        end
    end
end

-----------------------网络相关-------------------------
-- 请求服务器，获取玩家专属卖场相关数据
function ExclusiveShopLayer:requestSVipGetInfo()
	HttpClient:request({
        moduleName = "MysteryShop",
        methodName = "SVipGetInfo",
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestSVipGetInfo:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mShopInfo = data.Value

            -- 物品信息分组
            self:handleGoodsInfo()

            -- 刷新ListView
            self:refreshListView()
        end
    })
end

-- 请求服务器，购买相应物品
--[[
    params:
    id               -- 物品Id号
    cellIndex        -- cell索引号
--]]
function ExclusiveShopLayer:requestSVipMysteryShopBuyGoods(id, cellIndex)
    HttpClient:request({
        moduleName = "MysteryShop",
        methodName = "SVipMysteryShopBuyGoods",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestSVipMysteryShopBuyGoods:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 更新数据
            for i, v in ipairs(self.mShopInfo.MysteryShopGoodsList) do
                if v.Id == id then
                    self.mShopInfo.MysteryShopGoodsList[i].BuyCount = self.mShopInfo.MysteryShopGoodsList[i].BuyCount + 1
                    break
                end
            end

            -- 数据重新分组
            self:handleGoodsInfo()

            -- 移除每个cell上的所有，重新添加
            for i, v in ipairs(self.mListView:getItems()) do
                v:removeAllChildren()
                self:addElementsToCell(v, i)
            end

            -- 飘窗显示获得的物品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return ExclusiveShopLayer