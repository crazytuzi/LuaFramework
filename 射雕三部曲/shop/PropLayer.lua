--[[
	文件名：PropLayer.lua
	描述：商城招募之道具页面
	创建人：chenzhong
	创建时间：2017.3.14
--]]

-- 当前页面是添加到ShopLayer的BgSprite上的，此layer中的元素不必适配，按照(640,1136)坐标系来
local PropLayer = class("PropLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
	params:
	Table params:
	{

	}
--]]
function PropLayer:ctor(params)
	-- 页面大小
	self:setContentSize(cc.size(640, 1136))

	-- UI相关
	self:initUI()

	-- 请求服务器，获取道具信息
	self:requestShopGoodsList()
end

-- 添加相关UI元素
function PropLayer:initUI()
    -- 广告语
    local noticeSprite1 = ui.newSprite("sc_13.png")
    noticeSprite1:setPosition(320, 905)
    self:addChild(noticeSprite1)

    -- 添加物品背景
    local bottomBg = ui.newScale9Sprite("c_97.png", cc.size(596, 694))
    bottomBg:setPosition(320, 115)
    bottomBg:setAnchorPoint(0.5, 0)
    self:addChild(bottomBg)

    for i=1,2 do
        local pos = i == 1 and cc.p(298, 15) or cc.p(298, 345)
        local lineSprite = ui.newScale9Sprite("c_96.png", cc.size(599, 27))
        lineSprite:setPosition(pos)
        lineSprite:setAnchorPoint(0.5, 0)
        bottomBg:addChild(lineSprite)
    end

    -- 添加ListView
    self:addListView()

    -- 左箭头
    local tempSprite = ui.newSprite("c_26.png")
    tempSprite:setPosition(35, 475)
    tempSprite:setScaleX(-1)
    self:addChild(tempSprite)

    -- 右箭头
    local tempSprite = ui.newSprite("c_26.png")
    tempSprite:setPosition(605, 475)
    self:addChild(tempSprite)
end

-- 创建ListView列表视图
function PropLayer:addListView()
    self.mListView = ccui.ListView:create()
   	self.mListView:setContentSize(cc.size(580, 700))
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(10)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(320, 840)
    self.mListView:setScrollBarEnabled(false)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self:addChild(self.mListView)
end

-- 物品信息分组后，刷新ListView
function PropLayer:refreshListView()
    -- 先移除所有再重新添加
    self.mListView:removeAllItems()

    for i = 1, table.maxn(self.mPropList) do
        -- 创建cell
        local cellWidth, cellHeight = 190, 700
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
function PropLayer:addElementsToCell(cell, cellIndex)
	-- 获取每个小组的数据信息, 可能包含2个道具信息  也可能只有1个
    local groupInfo = self.mPropList[cellIndex]

    -- 获取cell宽高
    local cellWidth = cell:getContentSize().width
    local cellHeight = cell:getContentSize().height

    local propPos = {
        cc.p(95, 500),
        cc.p(95, 160)
    }
    for i, v in ipairs(groupInfo) do
    	-- 底层背景框
        local prop = ui.newSprite("sc_14.png")
        prop:setPosition(propPos[i])
        cell:addChild(prop)

        local propSize = prop:getContentSize()
        -- 道具名字
        local propName = ui.newLabel({
            text = GoodsModel.items[v.ModelId].name,
            size = 20,
            color = Utility.getQualityColor(GoodsModel.items[v.ModelId].quality, 1),
            outlineColor = Enums.Color.eOutlineColor,
            align = ui.TEXT_ALIGN_CENTER,
        })
        propName:setPosition(propSize.width*0.5, propSize.height*0.86)
        prop:addChild(propName)

        -- 设置头像
        local propHead = CardNode.createCardNode({
            modelId = v.ModelId,
            resourceTypeSub = GoodsModel.items[v.ModelId].typeID,
            cardShowAttrs = {CardShowAttr.eBorder},
            cardShape = Enums.CardShape.eCircle
        })
        propHead:setAnchorPoint(cc.p(0.5, 0))
        propHead:setPosition(propSize.width*0.5, propSize.height*0.45)
        propHead:setSwallowTouches(false)
        prop:addChild(propHead)

        -- 价格
        local picName = Utility.getResTypeSubImage(ResourcetypeSub.eDiamond)
        local num = v.CurrPrice
        local priceLabel = ui.newLabel({
            text = TR("#258711售价{%s} %d", picName, num),
            size = 22,
            align = ui.TEXT_ALIGN_CENTER
        })
        priceLabel:setAnchorPoint(cc.p(0.5, 0.5))
        priceLabel:setPosition(propSize.width*0.5, propSize.height*0.39)
        prop:addChild(priceLabel)

        --如果是宗师十连令 判断 翻倍收益-十连抽令打折活动 开启没
        --如果开启则需要打折显示
        -- if v.ModelId == 16050047 and ActivityObj:getActivityItem(ModuleSub.eTimedSalesRecruitUse) then
        --     --之前的价格显示成2倍
        --     priceLabel:setString(TR("#46220d售价{%s} %d", picName, v.InitPrice))
        --     priceLabel:setScale(0.8)
        --     --打折显示
        --     --红色斜杠
        --     local slash = ui.newSprite("sc_12.png")
        --     slash:setPosition(cc.p(0, 0))
        --     priceLabel:addChild(slash)
        --     --打折后的价格
        --     local saleLabel = ui.newLabel({
        --         text = TR("#46220d售价{%s} %d", picName, v.CurrPrice),
        --         size = 20,
        --         align = ui.TEXT_ALIGN_CENTER
        --     })
        --     saleLabel:setAnchorPoint(cc.p(0.5, 0.5))
        --     saleLabel:setPosition(propSize.width * 0.5, propSize.height * 0.32)
        --     prop:addChild(saleLabel)

        --     --角标
        --     local corner = ui.newSprite("c_57.png")
        --     corner:setAnchorPoint(cc.p(0, 1))
        --     corner:setPosition(0, propHead:getContentSize().height)
        --     corner:setScale(0.75)
        --     propHead:addChild(corner)
        --     -- --折数
        --     local saleNum = ui.newLabel({
        --         text = TR("打折"),
        --         size = 18,
        --     })
        --     saleNum:setRotation(45)
        --     saleNum:setPosition(corner:getContentSize().width / 2 - 8, corner:getContentSize().height / 2 + 12)
        --     corner:addChild(saleNum)
        -- end

        -- 复制数据，用于修改，确保每次购买弹窗的购买次数上限是对的
        local copyInfo = clone(v)
        copyInfo.MaxNum = v.MaxNum - v.Num

        -- 购买按钮
        local buyBtn = ui.newButton({
            normalImage = "c_95.png",
            text = TR("购买"),
            outlineColor = cc.c3b(0xc0, 0x49, 0x48),
            clickAction = function()
                MsgBoxLayer.addBuyGoodsCountLayer(
                    TR("购买"),
                    copyInfo,
                    function(selCount, layerObj, btnObj)
                        if selCount == 0 then
                            return
                        end

                        -- 判断元宝是否足够
                        if Utility.isResourceEnough(ResourcetypeSub.eDiamond, selCount * v.CurrPrice) then
                            self:requestBuyGoods(v.ModelId, selCount)

                            LayerManager.removeLayer(layerObj)
                        end
                    end
                )
            end
        })
        buyBtn:setPosition(propSize.width*0.5, propSize.height*0.13)
        buyBtn:setScale(0.9)
        prop:addChild(buyBtn)

        -- 显示可购买次数
        local maxLabel = ui.newLabel({
            text = "",
            align = ui.TEXT_ALIGN_CENTER,
            size = 20
        })
        maxLabel:setAnchorPoint(cc.p(0.5, 0.5))
        maxLabel:setPosition(propSize.width*0.5, propSize.height*0.27)
        prop:addChild(maxLabel)

        -- MaxNum为 -1 时，可购买无数次
        if v.MaxNum > 0 then
            if v.Num < v.MaxNum then
                maxLabel:setString(TR("#b96237今日可购%s次", v.MaxNum - v.Num))
            else
                maxLabel:setString(TR("#b96237已达购买上限"))
                buyBtn:setEnabled(false)
            end
        end
    end

    return customCell
end

-- 整理物品信息，2个为一组
function PropLayer:handleGoodsInfo()
    -- 重置为空表
    self.mPropList = {}

    local tempList = {}
    for i = 1, #self.mGoodsInfo do
        table.insert(tempList, self.mGoodsInfo[i])
        if i % 2 == 0 then
            table.insert(self.mPropList, tempList)
            tempList = {}
        end
    end

    if #tempList ~= 0 then
        table.insert(self.mPropList, tempList)
    end
end

---------------------网络相关---------------------
-- 请求服务器，获取所有要显示的道具的信息
function PropLayer:requestShopGoodsList()
	HttpClient:request({
		moduleName = "ShopGoods",
		methodName = "ShopGoodsList",
        callbackNode = self,
        callback = function(data)
            --dump(data, "requestShopGoodsList")

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mGoodsInfo = data.Value

            -- 整理物品信息，2个为1组
            self:handleGoodsInfo()

            -- 刷新ListView
            self:refreshListView()
        end
    })
end

-- 请求购买道具
--[[
    params:
    propModelId:   道具的ID
    num:           购买的数量
--]]
function PropLayer:requestBuyGoods(propModelId, num)
    local requestData = {propModelId, num}
    HttpClient:request({
    	moduleName = "ShopGoods",
    	methodName = "BuyGoods",
    	svrMethodData = requestData,
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 文字提示
            ui.showFlashView({
            	text = TR("购买成功")
            })

            -- 更新数据
            for i, v in ipairs(self.mGoodsInfo) do
                if data.Value.ModelId == v.ModelId then
                    v.Num = data.Value.Num
                    v.CurrPrice = data.Value.CurrPrice
                    break
                end
            end

            -- 重新整理数据
            self:handleGoodsInfo()

            -- 移除每个cell上的所有，重新添加
            for index, cell in ipairs(self.mListView:getItems()) do
                cell:removeAllChildren()
                self:addElementsToCell(cell, index)
            end
        end
    })
end

return PropLayer
