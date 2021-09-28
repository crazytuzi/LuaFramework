--[[
    文件名：LimitStoreLayer.lua
    描述： 限时商店
    创建人：  yanghongsheng
    创建时间：2017.4.22
-- ]]

local LimitStoreLayer = class("LimitStoreLayer", function(params)
	return display.newLayer(cc.c4b(0, 0, 0, 150))
end)

local Exchange = {
    enabled = false,
    unabled = true
}

function LimitStoreLayer:ctor()
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:initUI()
end

function LimitStoreLayer:initUI()

    self.mBgSprite = ui.newSprite("bwzq_05.png")
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)
    self.mBgSprite:setScale(0)

	-- 关闭时间
    self.mCloseTimeLabel = ui.newLabel({
        text = TR("#46220d限时商店将于:  #258711%s#46220d后关闭", "00:00:00"),
        size = 22,
    })
    self.mCloseTimeLabel:setAnchorPoint(cc.p(0.5, 1))
    self.mCloseTimeLabel:setPosition(cc.p(320, 930))
    self.mBgSprite:addChild(self.mCloseTimeLabel)

    -- 提示:
    local lblHint = ui.newLabel({
        text = TR("#46220d关闭以后, 可在首页上方再次打开！"),
        size = 24,
    })
    lblHint:setAnchorPoint(cc.p(0.5, 1))
    lblHint:setPosition(cc.p(320, 900))
    self.mBgSprite:addChild(lblHint)

    -- 关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_28.png",
        text = TR("返回"),
        fontSize = 24,
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(320, 230)
	self.mBgSprite:addChild(self.mCloseBtn)

	-- 设置滑动列表
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(550,575))
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(cc.p(320, 280))
    self.mListView:setChildrenActionType(0)
    self.mBgSprite:addChild(self.mListView)

    -- 定时器
    Utility.schedule(self, self.onSchedule, 1.0)
    -- 请求网络数据
    self:requestGetInfo()
end

function LimitStoreLayer:refreshUI()

end

function LimitStoreLayer:onEnterTransitionFinish()
	-- 面板出现动画
    local scale = cc.ScaleTo:create(0.5, 1.0)
    local easeBaseAction = cc.EaseBackOut:create(scale)
    self.mBgSprite:runAction(easeBaseAction)
end

-- 定时器
function  LimitStoreLayer:onSchedule()
    if not self.mCloseTime then
        return
    end
    -- 计算时间
    local closeTime  = self.mCloseTime - Player:getCurrentTime()
    if self.mIsOpen == 0 or closeTime <= 0 then
        self:stopAllActions()
        --dump("限时商店已经关闭")
        self:showStoreCloseHint()
        return
    end

    self.mCloseTimeLabel:setString(TR("#46220d限时商店将于:  #258711%s#46220d后关闭", MqTime.formatAsDay(closeTime)))
end
-- 关闭商店
function LimitStoreLayer:showStoreCloseHint()
    if self.mMsgBoxLayer then
        return
    end
    MsgBoxLayer.addOKLayer(
    	TR("限时商店已经关闭"),
    	TR("提示")
    )
end

-- 刷新列表
function LimitStoreLayer:refreshListView()
	if not self.mListView then
        return
    end

    --dump(self.mShopGoodsList)

    -- 添加数据
    self.mListView:removeAllChildren()
    local itemSize = cc.size(180, 660)
    local listCount = table.maxn(self.mShopGoodsList)
    print("listCount---->",listCount)
    local itemCount = math.ceil(listCount / 2)
    for i = 1, itemCount do

        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(itemSize)
        self.mListView:pushBackCustomItem(lvItem)
        for k = 1, 2 do
            local index = 2 * (i - 1) + k
            if index > listCount then
                break
            end
            local item = self.mShopGoodsList[index]
            -- 创建背景
            local cellSprite = ui.newScale9Sprite("bwzq_06.png", cc.size(160, 250))
            cellSprite:setPosition(95,  460 - (k - 1) * 280 + 23)
            lvItem:addChild(cellSprite)
            local callSize = cellSprite:getContentSize()
            -- 道具头像
            local cardNode = CardNode.createCardNode({
                    resourceTypeSub = item.SellResourceTypeSub, -- 资源类型
					modelId = item.SellGoodsModelId,  -- 模型Id
					num = item.SellNum, -- 资源数量
					cardShowAttrs = {
			            CardShowAttr.eBorder,
			        }
				})
            cardNode:setAnchorPoint(cc.p(0.5, 0))
            cardNode:setPosition(cc.p(callSize.width*0.5, callSize.height*0.45))
            cellSprite:addChild(cardNode)
            -- 道具名字
            local sellName = ui.newLabel({
                text = TR("%s",Utility.getGoodsName(item.SellResourceTypeSub, item.SellGoodsModelId)),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 22,
                })
            sellName:setPosition(cc.p(callSize.width*0.5, callSize.height*0.9))
            cellSprite:addChild(sellName)

            local dicount = 10
            if item.Discount < 10000 then
                dicount = math.ceil(item.Discount / 1000)
                local iconFile = "bwzq_07.png"
                local numDiscount = 6 -- 默认打6折

                local icon = ui.newSprite(iconFile)
                icon:setAnchorPoint(cc.p(0, 1))
                icon:setPosition(cc.p(0, cellSprite:getContentSize().height + 1))
                cellSprite:addChild(icon)

                local lableDiscountNum = ui.newLabel({
                    text = TR("%d折", dicount),
                    font = _FONT_PANGWA,
                    x = (23),
                    y = (38),
                    size = (24),
                    color = Enums.Color.eYellow,
                    outlineColor = cc.c3b(0xba, 0x22, 0x15)
                })
                icon:addChild(lableDiscountNum)
                lableDiscountNum:setRotation(-46)
            end

            local price = item.BuyNum * dicount * 0.1
            local labelCount = ui.createSpriteAndLabel({
	            imgName = Utility.getResTypeSubImage(item.BuyResourceTypeSub),
                labelStr = price,
	            alignType = ui.TEXT_ALIGN_RIGHT,
	            fontColor = cc.c3b(0xde, 0x6e, 0x00),
                fontSize = 20
        		})
            labelCount:setAnchorPoint(cc.p(0.5, 0.5 ))
	        labelCount:setPosition(cc.p(callSize.width / 2, 90))
            cellSprite:addChild(labelCount)


            local count = Utility.getOwnedGoodsCount(item.SellResourceTypeSub,item.SellGoodsModelId)
            local needCount = self:getComposeCount(item)
            local textStr = "";
            if needCount > 0 then
                textStr = TR("#258711拥有:%d/%d", count, needCount)
            else
                count = Utility.getOwnedGoodsCount(item.SellResourceTypeSub,item.SellGoodsModelId)
                textStr = TR("#258711拥有:%d", count)
            end
            -- -- 目标 Goods 数量
            local lblGoodsNum = ui.newLabel({
                text = textStr,
                x = (78),
                y = (60),
                size = 20,
                color = Enums.Color.eOrange
            })
            cellSprite:addChild(lblGoodsNum)

            local btnImage = "c_95.png"
            local btnText = TR("购买")
            local txtColor = Enums.Color.eBlack
            if item.IsSell == Exchange.unabled then
                btnText = TR("已售")
                txtColor = cc.c3b(0xA8, 0xA8, 0xA8)
            end
            local btnPurchase = ui.newButton({
                normalImage = btnImage,
                position = cc.p(78, 30),
                text = btnText,
                fontSize = 24,
                outlineColor = cc.c3b(0xc4, 0x55, 0x57),
                clickAction = function()
                    if item.IsSell == Exchange.unabled then
                        return
                    end
                    if Utility.isResourceEnough(item.BuyResourceTypeSub, price)  then
                        self.mExchangeId = item.Id
                        self:requestBuyGoods()
                    end
                end
            })
            btnPurchase:setScale(0.75)
            if item.IsSell == Exchange.unabled then
                btnPurchase:setEnabled(false)
            end
            cellSprite:addChild(btnPurchase)
        end
    end
end
-- 更新容器内的商品信息
function LimitStoreLayer:updateShopGoodsList()
    for _, v in pairs(self.mShopGoodsList) do
        if v.Id == self.mExchangeId then
            v.IsSell = Exchange.unabled
            break
        end
    end
end

function LimitStoreLayer:getComposeCount(item)
    if item.SellResourceTypeSub == ResourcetypeSub.eHeroDebris or
            item.SellResourceTypeSub == ResourcetypeSub.eEquipmentDebris then
        return GoodsModel.items[item.SellGoodsModelId].maxNum
    end
    return 0
end

--[[------网络请求-----]]-----
-- 请求基本信息
function LimitStoreLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TraderInfo",
        methodName = "GetInfo",
        svrMethodData = {self.mCurrentBossId},
        callback = function(data)
            if not data or data.Status ~= 0 then
                return
            end

            self.mData = data.Value
            local response = data.Value
            self.mIsOpen = response.IsOpen
    		self.mGoldCount = response.GoldCount
    		self.mShopGoodsList = response.TraderGoodsList or {}
    		self.mCloseTime = response.OpenDate or 0
    		-- 刷新列表
    		self:refreshListView()
        end,
    })
end

--- 兑换购买商品
function LimitStoreLayer:requestBuyGoods()
    --@Int32:商品编号
    HttpClient:request({
        moduleName = "TraderInfo",
        methodName = "BuyGoods",
        svrMethodData = {self.mExchangeId},
        callback = function(data)
            if not data or data.Status ~= 0 then
                return
            end

            local response = data.Value
            self:updateShopGoodsList()
            self:refreshListView()
            ui.showFlashView({
                text = TR("购买成功")
            })
        end,
    })
end

return LimitStoreLayer
