--[[
    文件名: ActivityTimedChargeRebateLayer.lua
    描述: 限时-充值返利
    创建人: yanghongsheng
    创建时间: 2018.7.30
--]]

local ActivityTimedChargeRebateLayer = class("ActivityTimedChargeRebateLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：

]]
function ActivityTimedChargeRebateLayer:ctor(params)
    -- 活动结束时间
    self.mEndTime = 0
    -- 礼包信息
    self.mGiftInfoList = {}
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()

    -- 获取射靶信息
    self:requestGetInfo()
end

function ActivityTimedChargeRebateLayer:initUI()
    -- 背景图片
    local bgSprite = ui.newSprite("fl_6.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(608, 1099),
        clickAction = function()
            if self.mCloseCallBack then
                self.mCloseCallBack()
            end

            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn, 10)
    -- title图片
    local titleSprite = ui.newSprite("fl_4.png")
    titleSprite:setAnchorPoint(cc.p(0.5, 1))
    titleSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(titleSprite)
    -- 倒计时
    self.mTimeLabel = ui.newLabel({
            text = "",
            color = cc.c3b(0x6e, 0x3c, 0x05),
        })
    self.mTimeLabel:setPosition(320, 850)
    self.mParentLayer:addChild(self.mTimeLabel)
    -- 列表背景
    local listBg = ui.newScale9Sprite("c_97.png", cc.size(626, 705))
    listBg:setPosition(320, 480)
    self.mParentLayer:addChild(listBg)
    -- 返利列表
    self.mGiftListView = ccui.ListView:create()
    self.mGiftListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mGiftListView:setBounceEnabled(true)
    self.mGiftListView:setContentSize(cc.size(626, 705))
    self.mGiftListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mGiftListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mGiftListView:setPosition(320, 480)
    self.mParentLayer:addChild(self.mGiftListView)
    -- 充值按钮
    local chargeBtn = ui.newButton({
            normalImage = "fl_5.png",
            text = TR("立即充值"),
            titlePosRateY = 0.6,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "recharge.RechargeLayer",
                })
            end,
        })
    chargeBtn:setPosition(320, 70)
    self.mParentLayer:addChild(chargeBtn)
end

-- 刷新列表
function ActivityTimedChargeRebateLayer:refreshListView()
    self.mGiftListView:removeAllChildren()

    for i = 1, #self.mGiftInfoList do
        self.mGiftListView:pushBackCustomItem(self:lineList(i))
    end
end

-- 处理数据
function ActivityTimedChargeRebateLayer:handleData(dataList)
    local totalList = {}
    local lineList = {}
    for i = 1, #dataList do
        table.insert(lineList, dataList[i])
        if i % 3 == 0 then
            table.insert(totalList, lineList)
            lineList = {}
        end
    end
    if #lineList ~= 0 then
        table.insert(totalList, lineList)
    end
    return totalList
end

function ActivityTimedChargeRebateLayer:lineList(index)
    local layout = ccui.Layout:create()
    layout:setContentSize(618, 270)

    local underSprite = ui.newScale9Sprite("c_96.png", cc.size(618, 35))
    underSprite:setPosition(309, 0)
    layout:addChild(underSprite)

    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setBounceEnabled(true)
    listView:setTouchEnabled(false)
    listView:setContentSize(cc.size(618, 270))
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(309, 122)
    layout:addChild(listView)

    for i = 1, #self.mGiftInfoList[index] do
        local info = self.mGiftInfoList[index][i]
        local oneCell = ccui.Layout:create()
        oneCell:setContentSize(198, 260)

        --背景板
        local bgSprite = ui.newSprite("fl_3.png")
        bgSprite:setPosition(115, 140)
        oneCell:addChild(bgSprite)

        --单笔充值
        local priceTag = ui.newLabel({
            text = TR("单笔充值%s元宝", info.ChargeNum),
            color = cc.c3b(0xff, 0xf4, 0xc1),
            size = 22,
        })
        priceTag:setPosition(115, 235)
        oneCell:addChild(priceTag)

        -- 奖励
        local rewardList = Utility.analysisStrResList(info.Reward)
        local cardInfo = rewardList[1]
        cardInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        local rewardCard = CardNode.createCardNode(cardInfo)
        rewardCard:setPosition(115, 160)
        oneCell:addChild(rewardCard)

        -- 可领取次数
        local canGetLabel = ui.newLabel({
                text = info.LimitNum <= info.TotalNum and TR("已领取完该档位奖励") or TR("可领取次数%d/%d", info.RewardNum, info.LimitNum-info.TotalNum),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
        canGetLabel:setPosition(115, 95)
        oneCell:addChild(canGetLabel)

        -- 返利
        local fanliBg = ui.newSprite("fl_2.png")
        fanliBg:setPosition(60, 170)
        oneCell:addChild(fanliBg)
        local fanliLabel = ui.newNumberLabel({
                text = info.DiscountDesc,
                imgFile = "fl_1.png",
            })
        fanliLabel:setPosition(cc.p(50, 40))
        fanliLabel:setAnchorPoint(cc.p(1, 1))
        fanliLabel:setRotation(-40)
        fanliBg:addChild(fanliLabel)

        -- 领取按钮
        local getBtn = ui.newButton({
                normalImage = "c_59.png",
                text = TR("领取"),
                clickAction = function ()
                    self:requestReward(info.OrderId)
                end,
            })
        getBtn:setEnabled(info.RewardStatus)
        getBtn:setPosition(115, 50)
        oneCell:addChild(getBtn)

        listView:pushBackCustomItem(oneCell)
    end
    return layout
end

-- 创建倒计时
function ActivityTimedChargeRebateLayer:createTimeUpdate()
    if self.timeUpdate then
        self.mTimeLabel:stopAction(self.timeUpdate)
        self.timeUpdate = nil
    end

    self.timeUpdate = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("倒计时:  %s", MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:stopAction(self.timeUpdate)
            self.timeUpdate = nil
            self.mTimeLabel:setString("")
        end
    end, 1.0)
end

-- 刷新页面
function ActivityTimedChargeRebateLayer:refreshUI()
    -- 倒计时
    self:createTimeUpdate()

    -- 刷新列表
    self:refreshListView()
end

---------------------------网络相关-------------------------------
-- 请求初始信息
function ActivityTimedChargeRebateLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedChargerebate",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            
            self.mEndTime = data.Value.EndTime
            self.mGiftInfoList = self:handleData(data.Value.RewardList)

            self:refreshUI()
        end
    })
end

-- 领取奖励
function ActivityTimedChargeRebateLayer:requestReward(giftId)
    HttpClient:request({
        moduleName = "TimedChargerebate",
        methodName = "Reward",
        svrMethodData = {giftId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            
            self.mGiftInfoList = self:handleData(data.Value.RewardList)

            self:refreshUI()
        end
    })
end

return ActivityTimedChargeRebateLayer