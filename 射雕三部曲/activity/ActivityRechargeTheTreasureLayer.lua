--[[
    文件名：ActivityRechargeTheTreasureLayer.lua
    文件描述：充值夺宝
    创建人：chenzhong
    创建时间：2017.12.21
]]

local ActivityRechargeTheTreasureLayer = class("ActivityRechargeTheTreasureLayer", function(params)
    return display.newLayer()
end)

function ActivityRechargeTheTreasureLayer:ctor(params)
    -- package.loaded["activity.ActivityRechargeTheTreasureLayer"] = nil
    dump(params,"params")
    params = params or {}
    -- 活动实体Id列表
    self.mActivityIdList = params.activityIdList
    -- 该活动的主模块Id
    self.mParentModuleId = params.parentModuleId
    -- 该页面的数据信息
    self.mLayerData = params.cacheData

    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self.mChaildLayer = ui.newStdLayer()
    self:addChild(self.mChaildLayer)

    self.mActiveDay = 5  -- 默认活动多少天

    self:initUI()

    --获取数据
    self:requestGetInfo()
end

function ActivityRechargeTheTreasureLayer:initUI()
    --背景图
    local bgSprite = ui.newSprite("xshd_44.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 标记
    local titleSprite = ui.newSprite("xshd_46.png")
    titleSprite:setAnchorPoint(0, 0.6)
    titleSprite:setPosition(0, 850)
    self.mParentLayer:addChild(titleSprite)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(46, 930),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.每日累计充值600元宝可领取充值奖励。"),
                [2] = TR("2.累计充值3和5天都可以领取额外奖励。"),
                [3] = TR("3.活动结束前若没有累计充值满3天或5天将无法领取额外奖励。"),
            })
        end})
    bgSprite:addChild(ruleBtn, 1)

    --剩余时间
    local timeBg = ui.newScale9Sprite("c_25.png",cc.size(400, 50))
    timeBg:setPosition(320, 930)
    self.mParentLayer:addChild(timeBg)
    local timeLabel = ui.newLabel({
        text = TR("活动倒计时：00:00:00"),
        -- color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    timeLabel:setPosition(320, 930)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    -- 累积充值天数
    local dayLabel = ui.newLabel({
        text = TR("已累计充值：0天"),
        -- color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
    })
    dayLabel:setPosition(320, 890)
    self.mParentLayer:addChild(dayLabel)
    self.mDayLabel = dayLabel

    -- 累积充值金额
    local chargeNumLabel = ui.newLabel({
        text = TR("今日累计充值：0/0"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    chargeNumLabel:setAnchorPoint(0, 0.5)
    chargeNumLabel:setPosition(20, 382)
    self.mParentLayer:addChild(chargeNumLabel)
    self.mChargeNumLabel = chargeNumLabel

    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.horizontal)
    tempListView:setBounceEnabled(true)
    tempListView:setAnchorPoint(cc.p(0, 0.5))
    tempListView:setPosition(23, 285)
    tempListView:setContentSize(cc.size(594, 150))
    self.mParentLayer:addChild(tempListView)
    self.mRewardListView = tempListView

    -- 充值按钮
    local chargeBtn = ui.newButton({
        normalImage = "shouc_12.png",
        titleImage = "shouc_08.png",
        position = cc.p(320, 165),
        clickAction = function(pSender)
            
        end
    })
    -- chargeBtn:setScale(0.9)
    self.mParentLayer:addChild(chargeBtn)
    self.mChargeBtn = chargeBtn

    local labelBg = ui.newScale9Sprite("xshd_27.png",cc.size(600, 180))
    labelBg:setPosition(320, 660)
    self.mParentLayer:addChild(labelBg)
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function ActivityRechargeTheTreasureLayer:refreshLayer()
    self.mChargeBtn:setEnabled(true)
    -- 刷新累计充值金额
    self.mChargeNumLabel:setString(TR("今日累计充值：%s/%s", self.mChargeInfo.ChargeMoney or 0, self.mChargeInfo.NeedChargeNum or 0))
    -- 刷新累计充值天数
    self.mDayLabel:setString(TR("已累计充值：%s天", self.mChargeInfo.TotalNum or 0))
    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 刷新充值按钮
    self:refreshBtn()
    -- 刷新充值奖励
    self:refreshReward()
    -- 刷新图中间的宝箱奖励进度条和宝箱说明介绍
    self:refreshBoxReward()
end

-- 刷新充值奖励
function ActivityRechargeTheTreasureLayer:refreshReward()
    self.mRewardListView:removeAllItems()
    local goodsList = Utility.analysisStrResList(self.mChargeInfo.Reward or "")
    for i,v in ipairs(goodsList) do
        local layout = ccui.Layout:create()
        layout:setContentSize(122, 148)

        local bgSprite = ui.newSprite("xshd_40.png")
        bgSprite:setPosition(61, 74)
        layout:addChild(bgSprite)

        local goodsCard = CardNode.createCardNode({
            resourceTypeSub = v.resourceTypeSub,
            modelId = v.modelId,
            num = v.num,
            })
        goodsCard:setPosition(61, 84)
        layout:addChild(goodsCard)

        self.mRewardListView:pushBackCustomItem(layout)
    end
end

-- 刷新充值按钮
function ActivityRechargeTheTreasureLayer:refreshBtn()
    if self.mChargeInfo.RewardStatus == 0 then 
        self.mChargeBtn:setEnabled(true)
        self.mChargeBtn:setTitleImage("shouc_08.png")
        self.mChargeBtn:setClickAction(function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end)
    elseif self.mChargeInfo.RewardStatus == 2 then 
        self.mChargeBtn:setEnabled(false)
        self.mChargeBtn:setTitleImage("shouc_14.png")
    elseif self.mChargeInfo.RewardStatus == 1 then 
        self.mChargeBtn:setEnabled(true)
        self.mChargeBtn:setTitleImage("shouc_13.png")
        self.mChargeBtn:setClickAction(function()
            self:getReward()
        end)
    end 
end

-- 刷新图中间的宝箱奖励进度条和宝箱说明介绍
function ActivityRechargeTheTreasureLayer:refreshBoxReward()
    self.mChaildLayer:removeAllChildren()
    local function getPercent(day)
        return 100/(self.mActiveDay-1)*(day>0 and (day-1) or 0)
    end    

    -- 进度条
    local expSize = cc.size(530, 26)
    local expProgress = require("common.ProgressBar"):create({
        bgImage = "zr_14.png",
        barImage = "zr_15.png",
        currValue = getPercent(self.mChargeInfo.TotalNum),
        maxValue = 100,
        contentSize = expSize,
        barType = ProgressBarType.eHorizontal,
    })
    expProgress:setAnchorPoint(cc.p(0.5, 0.5))
    expProgress:setPosition(320, 450)
    self.mChaildLayer:addChild(expProgress)

    for i,v in ipairs(self.mChargeInfo.BoxList or {}) do
        local rewardInfo = Utility.analysisStrResList(v.Reward)
        local tempCard = CardNode.createCardNode({
            resourceTypeSub = rewardInfo[1].resourceTypeSub,
            modelId = rewardInfo[1].modelId,
            num = rewardInfo[1].num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        })
        tempCard:setScale(0.9)
        tempCard:setAnchorPoint(0.5, 0)
        tempCard:setPosition(expSize.width*getPercent(v.OrderId)/100, 30)
        expProgress:addChild(tempCard)

        --RewardStatus:领奖状态：2：已经领取，1：可以领取，0不可以领取
        if v.RewardStatus == 1 then 
            ui.setWaveAnimation(tempCard)
            tempCard:setClickCallback(function ()
                self:getBoxReward(v.OrderId)
            end)
        elseif v.RewardStatus == 2 then 
            local doneSprite = ui.newSprite("jc_21.png")
            doneSprite:setPosition(tempCard:getContentSize().width * 0.5, tempCard:getContentSize().height * 0.5)
            tempCard:addChild(doneSprite)
        end 

        -- 添加说明
        local introLabel = ui.newLabel({
            text = TR("累计充值#ffe65e%s#ffffff天可获得：#ffe65e%s*%s", v.OrderId, Utility.getGoodsName(rewardInfo[1].resourceTypeSub, rewardInfo[1].modelId), rewardInfo[1].num),
            size = 20,
        })
        introLabel:setAnchorPoint(cc.p(0, 0.5))
        introLabel:setPosition(140, 720-(i-1)*30)
        self.mChaildLayer:addChild(introLabel)
    end

    -- 添加小黑线
    for i=1, self.mActiveDay do
        local image = self.mChargeInfo.TotalNum >= i and "xshd_43.png" or "xshd_42.png"
        local pointSprite = ui.newSprite(image)
        pointSprite:setPosition(expSize.width*getPercent(i)/100, expSize.height/2)
        expProgress:addChild(pointSprite)

        -- 天数
        local dayBg = ui.newSprite("c_92.png")
        dayBg:setPosition(expSize.width*getPercent(i)/100, -15)
        dayBg:setScale(0.65)
        expProgress:addChild(dayBg)
        local dayLabel = ui.newLabel({
            text = TR("%s日%s", i, i==self.mActiveDay and TR("大奖") or ""),
            size = 30,
        })
        dayLabel:setPosition(60, 15)
        dayBg:addChild(dayLabel)
    end
end

-- 活动倒计时
function ActivityRechargeTheTreasureLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时:  %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时:  %s00:00:00", "#f8ea3a"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 重新进入提示
        MsgBoxLayer.addOKLayer(
            TR("%s活动已结束，请重新进入", self.mActivityIdList[1].Name),
            TR("提示"),
            {
                normalImage = "c_28.png",
            },
            {
                normalImage = "c_29.png",
                clickAction = function()
                    LayerManager.addLayer({
                        name = "activity.ActivityMainLayer",
                        data = {moduleId = ModuleSub.eTimedActivity},
                    })
                end
            }
        )
    end
end

-- 获取恢复数据
function ActivityRechargeTheTreasureLayer:getRestoreData()
    local retData = {
        activityIdList = self.mActivityIdList,
        parentModuleId = self.mParentModuleId,
        cacheData = self.mLayerData
    }
    return retData
end

---------------------网络相关------------------------
-- 请求服务器，获取当家当前限时兑换的相关信息
function ActivityRechargeTheTreasureLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedChargebox",
        methodName = "GetInfo",
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestInfo:")

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 活动倒计时
            self.mEndTime = data.Value.EndTime or 0
            self.mChargeInfo = data.Value or {}
            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 领取充值奖励奖励
function ActivityRechargeTheTreasureLayer:getReward()
    HttpClient:request({
        moduleName = "TimedChargebox",
        methodName = "Reward",
        svrMethodData = {self.mChargeInfo.OrderId},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 活动倒计时
            self.mEndTime = data.Value.EndTime or 0
            self.mChargeInfo = data.Value or {}
            -- 刷新页面
            self:refreshLayer()

            -- 飘窗奖励
            ui.ShowRewardGoods(self.mChargeInfo.BaseGetGameResourceList)
        end
    })
end

function ActivityRechargeTheTreasureLayer:getBoxReward(OrderId)
    HttpClient:request({
        moduleName = "TimedChargebox",
        methodName = "BoxReward",
        svrMethodData = {OrderId},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 活动倒计时
            self.mEndTime = data.Value.EndTime or 0
            self.mChargeInfo = data.Value or {}
            -- 刷新页面
            self:refreshLayer()

            -- 飘窗奖励
            ui.ShowRewardGoods(self.mChargeInfo.BaseGetGameResourceList)
        end
    })
end

return ActivityRechargeTheTreasureLayer