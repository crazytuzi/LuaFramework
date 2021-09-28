--[[
    文件名: CollectFiveFuLayer.lua
	描述: 集5福活动
	创建人: lengjiazhi
	创建时间: 2018.02.02
-- ]]
local CollectFiveFuLayer = class("CollectFiveFuLayer", function (params)
	return display.newLayer()
end)

function CollectFiveFuLayer:ctor()

	ui.registerSwallowTouch({node = self})

    self.mCardList = {}
    self.mCanExchangeLabelList = {}

    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self.mRefreshLayer = ui.newStdLayer()
    self:addChild(self.mRefreshLayer)

	self:initUI()
	self:requestGetInfo()
end

function CollectFiveFuLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("xn_74.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1035),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn, 1000)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(35, 1035),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.参与限时掉落活动搜集藏宝图碎片。"),
                TR("2.使用藏宝图碎片探索不同的宝藏。"),
                TR("3.每种宝藏都有探寻次数限制。"),
                TR("4.活动结束后所有兑换道具都会清除，请及时使用。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    --活动倒计时
    local activityEndLabel = ui.newLabel({
    	text = TR("活动倒计时:%s10天00:00:00", Enums.Color.eGreenH),
    	size = 22,
        outlineColor = Enums.Color.eOutlineColor,
    	})
    activityEndLabel:setAnchorPoint(0, 0.5)
    activityEndLabel:setPosition(370, 855)
    self.mParentLayer:addChild(activityEndLabel)
    self.mActivityEndLabel = activityEndLabel

    --箭头
    local arrowR = ui.newSprite("c_26.png")
    arrowR:setPosition(620, 585)
    self.mParentLayer:addChild(arrowR)

    local arrowL = ui.newSprite("c_26.png")
    arrowL:setPosition(20, 585)
    arrowL:setRotation(180)
    self.mParentLayer:addChild(arrowL)

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

end

-- 更新时间
function CollectFiveFuLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mActivityEndLabel:setString(TR("活动倒计时:%s%s",Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mActivityEndLabel:setString(TR("活动倒计时:%s 00:00:00", Enums.Color.eGreenH))
        
        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        LayerManager.removeLayer(self)
    end
end

--创建滑动页面
function CollectFiveFuLayer:createTouchMoveLayer()
    -- 创建分页滑动控件
    self.mSliderView = ui.newSliderTableView({
        width = 640,
        height = 1136,
        isVertical = false,
        selectIndex = 0,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
            return #self.mActivityList
        end,
        itemSizeOfSlider = function(sliderView)
            return 640, 1136
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index, isSelected)
            self:createCards(itemNode, index)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    self.mSliderView:setPosition(320, 568)
    self.mParentLayer:addChild(self.mSliderView)
end

local CardPosList3 = {
    [1] = cc.p(320, 750),
    [2] = cc.p(474, 418),
    [3] = cc.p(164, 418),
}

local CardPosList4 = {
    [1] = cc.p(485, 705),
    [2] = cc.p(485, 418),
    [3] = cc.p(154, 418),
    [4] = cc.p(154, 705),
}

local CardPosList5 = {
    [1] = cc.p(320, 790),
    [2] = cc.p(525, 645),
    [3] = cc.p(474, 405),
    [4] = cc.p(164, 405),
    [5] = cc.p(110, 645),
}

--创建卡牌
function CollectFiveFuLayer:createCards(itemNode, index)
    local info = self.mActivityList[index+1]
    self.mCardList[info.Serial] = {}
    --根据道具数量判断位置
    local positionInfo
    if #info.NeedGameResourceList == 3 then
        positionInfo = CardPosList3
    elseif #info.NeedGameResourceList == 4 then
        positionInfo = CardPosList4
    elseif #info.NeedGameResourceList == 5 then
        positionInfo = CardPosList5
    else
        return
    end

    --创建卡牌
    for i,v in ipairs(positionInfo) do
        local goodsInfo = info.NeedGameResourceList[i]

        local tempCard = CardNode.createCardNode({
            resourceTypeSub = goodsInfo.ResourceTypeSub,
            modelId = goodsInfo.ModelId,  
            num = goodsInfo.Count,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
            })
        tempCard:setPosition(positionInfo[i])
        itemNode:addChild(tempCard)

        local haveNum = Utility.getOwnedGoodsCount(goodsInfo.ResourceTypeSub, goodsInfo.ModelId)

        local numLabel = tempCard:setCardCount(haveNum, goodsInfo.Count)
        numLabel:setColor(Enums.Color.eGreen)
        if haveNum < goodsInfo.Count then
            numLabel:setColor(Enums.Color.eRed)
            tempCard:setGray(true)
        end

        tempCard.goodsInfo = goodsInfo
        table.insert(self.mCardList[info.Serial], tempCard)
    end

    --兑换按钮
    local exchangeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("探索"),
        clickAction = function()
            -- print(info.Serial, "ooooo")
            self:requestExchange(1, info.Serial)
        end
        })
    exchangeBtn:setPosition(320, 245)
    itemNode:addChild(exchangeBtn)

    --兑换目标道具
    local targetInfo = info.ExchaneGameResourceList[1]
    local tempRewardCard = CardNode.createCardNode({
        resourceTypeSub = targetInfo.ResourceTypeSub,
        modelId = targetInfo.ModelId,  
        num = targetInfo.Count,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},    
        })
    tempRewardCard:setPosition(320, 568)
    itemNode:addChild(tempRewardCard)

    --可兑换数量显示
    local canExchange = ui.newLabel({
        text = TR("可兑换:%s%s%s次", Enums.Color.eGreenH, info.PersonalNum, Enums.Color.eNormalWhiteH),
        outlineColor = Enums.Color.eOutlineColor,
        })
    canExchange:setPosition(320, 500)
    itemNode:addChild(canExchange)    
    table.insert(self.mCanExchangeLabelList, canExchange)
end

--刷新中间道具信息
function CollectFiveFuLayer:refreshCards()
    for index, item in ipairs(self.mCardList) do
        local needInfo = self.mActivityList[index].NeedGameResourceList
        for i,v in ipairs(item) do
            local goodsInfo = needInfo[i]
            local haveNum = Utility.getOwnedGoodsCount(goodsInfo.ResourceTypeSub, goodsInfo.ModelId)

            local numLabel = v.mShowAttrControl[CardShowAttr.eNum].label
            numLabel:setString(string.format("%s/%s", haveNum, goodsInfo.Count))
            numLabel:setColor(Enums.Color.eGreen)
            if haveNum < goodsInfo.Count then
                numLabel:setColor(Enums.Color.eRed)
                v:setGray(true)
            end
        end
    end

    for i,v in ipairs(self.mCanExchangeLabelList) do
        local info = self.mActivityList[i]
        v:setString(TR("可兑换:%s%s%s次", Enums.Color.eGreenH, info.PersonalNum, Enums.Color.eNormalWhiteH))
    end
end

--=======================================网络请求========================================
--请求信息
function CollectFiveFuLayer:requestGetInfo()
    local info = ActivityObj:getActivityItem(4451)
    self.mActivityId = info[1].ActivityId
    -- dump(info)
	HttpClient:request({
        moduleName = "TimedLimitExchange", 
        methodName = "GetInfo",
        svrMethodData = {info[1].ActivityId},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data, "ReceiveReward")

            self.mActivityList = data.Value.ActivityList

            self.mEndTime = data.Value.EndTime
          	self:updateTime()
			self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

            self:createTouchMoveLayer()
        end
    })

end

--请求兑换
function CollectFiveFuLayer:requestExchange(num, Serial)
	HttpClient:request({
        moduleName = "TimedLimitExchange", 
        methodName = "Exchange",
        svrMethodData = {self.mActivityId, Serial, num},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        dump(data)
            self.mActivityList = data.Value.ActivityList

            self:refreshCards()
	        
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList, true)

        end
    })
end

return CollectFiveFuLayer