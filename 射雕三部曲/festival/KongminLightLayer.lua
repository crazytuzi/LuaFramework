--[[
    文件名: KongminLightLayer.lua
    描述: 孔明灯页面
    创建人: chenzhong
    创建时间: 2018.1.23
-- ]]
local KongminLightLayer = class("KongminLightLayer", function (params)
    return display.newLayer()
end)

-- 五个孔明灯的位置
local Giftpos = {
    [1] = cc.p(105, 720),
    [2] = cc.p(475, 720),
    [3] = cc.p(280, 565),
    [4] = cc.p(130, 340),
    [5] = cc.p(415, 340),
}
-- 五种不同的祝福
local diffConSprite = {
    [1] = "xn_27.png",
    [2] = "xn_28.png",
    [3] = "xn_29.png",
    [4] = "xn_30.png",
    [5] = "xn_31.png",
}

function KongminLightLayer:ctor()
    ui.registerSwallowTouch({node = self})
    --
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    self.mChaildLayer = ui.newStdLayer()
    self:addChild(self.mChaildLayer)
    -- 放所有道具
    self.mProList = {}
    -- 剩余祈愿次数
    self.mWiseNum = 0
    -- 创建UI
    self:initUI()
    -- 获取活动数据
    self:requestGetInfo()
end
-- 初始页面
function KongminLightLayer:initUI()
    --背景图
    local bgSprite = ui.newSprite("xn_25.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1045),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(40, 1045),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.点亮每个孔明灯选择一种祝福（奖励），然后开始每日祈福。"),
                [2] = TR("2.每日点击一次祈福，奖励会增加一定倍数，最高可以达到十倍。"),
                [3] = TR("3.祈福期结束以后可以开始领取奖励。"),
                [4] = TR("4.每日增加的倍数是恒定的，要每日祈福才能领取10倍奖励哟！"),
            })
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 祈愿按钮
    self.wiseBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("祈 福"),
        position = cc.p(350, 185),
        clickAction = function(pSender)
        end
    })
    self.mParentLayer:addChild(self.wiseBtn)

    -- 活动剩余时间
    local timeBg = ui.newScale9Sprite("c_25.png",cc.size(300, 50))
    timeBg:setPosition(140, 160)
    self.mParentLayer:addChild(timeBg)
    local timeLabel = ui.newLabel({
        text = TR("活动倒计时：00:00:00"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    timeLabel:setPosition(140, 160)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    -- 可以开始领奖倒计时
    local rewardTimeBg = ui.newScale9Sprite("c_25.png",cc.size(300, 50))
    rewardTimeBg:setPosition(140, 200)
    self.mParentLayer:addChild(rewardTimeBg)
    local rewardTimeLabel = ui.newLabel({
        text = TR("领奖倒计时：00:00:00"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    rewardTimeLabel:setPosition(140, 200)
    self.mParentLayer:addChild(rewardTimeLabel)
    self.mRewardTimeLabel = rewardTimeLabel

    -- 添加进度条
    self.mProgressBar = require("common.ProgressBar").new({
        bgImage = "zr_14.png",
        barImage = "zr_15.png",
        currValue = 0,
        maxValue=  0,
        barType = ProgressBarType.eHorizontal,
        -- color = Enums.Color.eWhite,
        -- needLabel = true,
    })
    self.mProgressBar:setPosition(cc.p(600, 490))
    self.mParentLayer:addChild(self.mProgressBar)
    self.mProgressBar:setRotation(-90)

    -- 添加一个小灯笼（跟着进度条移动）
    self.mLightSprite = ui.newSprite("xn_24.png")
    -- self.mLightSprite:setScale(10)
    self.mProgressBar:addChild(self.mLightSprite)
    self.mLightSprite:setRotation(90)
    self.mLightSprite:setVisible(false)
    -- 进度条总数
    local progSize = self.mProgressBar:getContentSize()
    self.maxCount = ui.newNumberLabel({
        text = 0,
        imgFile = "cz_20.png",
        charCount = 10,
        startChar = 48
    })
    self.maxCount:setPosition(progSize.width+15, progSize.height/2+15)
    self.mProgressBar:addChild(self.maxCount)
    self.maxCount:setRotation(90)
    -- 添加一个美术倍字
    local beiSprite = ui.newSprite("xn_32.png")
    beiSprite:setPosition(progSize.width+15, progSize.height/2-15)
    self.mProgressBar:addChild(beiSprite)
    beiSprite:setRotation(90)
    -- 当前进度
    self.currentCount = ui.newLabel({
        text = "",
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    self.mProgressBar:addChild(self.currentCount)
    self.currentCount:setRotation(90)
    self.currentCount:setVisible(false)
end

-- 创建礼物道具
function KongminLightLayer:createFiveGift( )
    self.mChaildLayer:removeAllChildren()
    self.mProList = {}
    for i,v in ipairs(self.mLayerData.RewardList or {}) do
        -- 判断是否选择奖励
        if v.IsActive then 
            -- 显示奖励头像
            local light = ui.newSprite("xn_26.png")
            light:setPosition(cc.p(Giftpos[i].x-6, Giftpos[i].y-1))
            self.mChaildLayer:addChild(light)
            -- 祝福语
            local conSprite = ui.newSprite(diffConSprite[i])
            conSprite:setPosition(67, 77)
            light:addChild(conSprite)
            local rewardInfo = Utility.analysisStrResList(v.Reward)
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = rewardInfo[1].resourceTypeSub,
                modelId = rewardInfo[1].modelId,
                num = rewardInfo[1].num,
                cardShowAttrs = {CardShowAttr.eNum},
            })
            tempCard:setScale(0.74)
            tempCard:setPosition(cc.p(67, 128))
            light:addChild(tempCard)
            -- 将道具设置成圆形
            tempCard:setCardBorder(Utility.getQualityByModelId(rewardInfo[1].modelId, rewardInfo[1].resourceTypeSub), nil, "zy_12.png")
            -- 如果已经领取了
            if v.IsReward then 
                local doneSprite = ui.newSprite("jc_21.png")
                doneSprite:setPosition(tempCard:getContentSize().width * 0.5, tempCard:getContentSize().height * 0.5)
                tempCard:addChild(doneSprite)
            end     

            table.insert(self.mProList, light)
        else 
            -- 添加加号
            local button = ui.newButton({
                normalImage = "xn_44.png",
                position = Giftpos[i],
                clickAction = function()
                    LayerManager.addLayer({
                        name = "festival.WiseTreeSeclectLayer", 
                        cleanUp = false,
                        data = {
                            callback = function ( ... )
                                self:requestGetInfo()
                            end,
                            id = v.OrderId,
                            tag = ModuleSub.eCommonHoliday19,
                        }
                    })
                end
            })
            self.mChaildLayer:addChild(button)

            table.insert(self.mProList, button)
        end 
    end

    -- 做一个动画
    self:createAni()
end

-- 动画
function KongminLightLayer:createAni()
    for i,node in ipairs(self.mProList) do
        -- 图片浮动效果
        local moveAction1 = cc.MoveTo:create(1, cc.p(Giftpos[i].x, Giftpos[i].y + 15))
        local moveAction2 = cc.MoveTo:create(1, cc.p(Giftpos[i].x, Giftpos[i].y + 8))
        local moveAction3 = cc.MoveTo:create(1, cc.p(Giftpos[i].x, Giftpos[i].y))
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.EaseSineIn:create(moveAction2),
            cc.EaseSineOut:create(moveAction1),
            cc.EaseSineIn:create(moveAction2),
            cc.EaseSineOut:create(moveAction3)
        )))
    end
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function KongminLightLayer:refreshLayer()
    -- 刷新时间
    self:refreshTime()
    -- 设置进度条
    self:refreshProgressBar()
    -- 刷新奖励
    self:createFiveGift()

    -- 刷新按钮的状态
    if self.mLayerData.CanDraw then 
        self.wiseBtn:setTitleText(TR("领 取"))
        -- 是否已经领取奖励
        if self.mLayerData.IsRewardAll then
            self.wiseBtn:setTitleText(TR("已领取")) 
            self.wiseBtn:setEnabled(false)
        else 
            self.wiseBtn:setClickAction(function()
                self:getReward()
            end)
        end 
    else 
        self.wiseBtn:setClickAction(function()
            self:requestWise()
        end)
    end 
end

 -- 设置进度条
function KongminLightLayer:refreshProgressBar()
    local durTime = 0
    -- self.mLayerData.MaxNum = 10
    -- self.mLayerData.RateNum = 1
    self.mProgressBar:setMaxValue(self.mLayerData.MaxNum)
    self.mProgressBar:setCurrValue(self.mLayerData.RateNum, durTime)
    -- 设置总倍数
    self.maxCount:setString(self.mLayerData.MaxNum)
    -- 设置小灯笼的位置
    -- if self.mLayerData.RateNum <= 0 then 
    --     return
    -- end 
    local percent = self.mLayerData.RateNum/self.mLayerData.MaxNum
    local progSize = self.mProgressBar:getContentSize()
    self.mLightSprite:setPosition(progSize.width*percent, progSize.height/2)
    -- 设置当前Label
    self.currentCount:setString(TR("%s倍", self.mLayerData.RateNum))
    self.currentCount:setPosition(progSize.width*percent, progSize.height+28)
    Utility.performWithDelay(self, function ()
        self.mLightSprite:setVisible(true)
        self.currentCount:setVisible(true)
    end, durTime)
end

-- 刷新时间
function KongminLightLayer:refreshTime( ... )
    -- 刷新活动倒计时，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

     -- 领取奖励倒计时，开始倒计时
    if self.mRewardSchelTime then
        self:stopAction(self.mRewardSchelTime)
        self.mRewardSchelTime = nil
    end
    self:updateTime()
    self.mRewardSchelTime = Utility.schedule(self, self.updateRewardTime, 1.0)
end

-- 活动倒计时
function KongminLightLayer:updateTime()
    local timeLeft = self.mLayerData.EndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时:  %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLabel:setString(TR("活动倒计时:  %s00:00:00", "#f8ea3a"))
        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
    end
end

-- 奖励倒计时
function KongminLightLayer:updateRewardTime()
    local timeLeft = self.mLayerData.DrawTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mRewardTimeLabel:setString(TR("领奖倒计时:  %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
    else
        self.mRewardTimeLabel:setString(TR("领奖倒计时:  %s00:00:00", "#f8ea3a"))
        -- 停止倒计时
        if self.mRewardSchelTime then
            self:stopAction(self.mRewardSchelTime)
            self.mRewardSchelTime = nil
        end
    end
end

--=======================================网络请求========================================
--请求信息
function KongminLightLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedKongminglights", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "ReceiveReward")
            -- 页面数据
            self.mLayerData = data.Value or {}
            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 祈福
function KongminLightLayer:requestWise()
    HttpClient:request({
        moduleName = "TimedKongminglights",
        methodName = "Wish",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            self.mLayerData = data.Value or {}
            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 领取奖励
function KongminLightLayer:getReward()
    HttpClient:request({
        moduleName = "TimedKongminglights",
        methodName = "Reward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 页面数据
            self.mLayerData = data.Value or {}
            -- 刷新页面
            self:refreshLayer()
            -- 飘窗奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return KongminLightLayer