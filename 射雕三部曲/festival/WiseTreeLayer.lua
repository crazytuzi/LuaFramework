--[[
    文件名: WiseTreeLayer.lua
    描述: 祈愿树页面
    创建人: chenzhong
    创建时间: 2018.1.23
-- ]]
local WiseTreeLayer = class("WiseTreeLayer", function (params)
    return display.newLayer()
end)

-- 十个道具在树枝上的位置
local Giftpos = {
    [1] = cc.p(150, 845),
    [2] = cc.p(150, 725),
    [3] = cc.p(320, 790),
    [4] = cc.p(510, 770),
    [5] = cc.p(150, 605),
    [6] = cc.p(510, 645),
    [7] = cc.p(510, 520),
    [8] = cc.p(120, 440),
    [9] = cc.p(310, 380),
    [10] = cc.p(195, 305),
}

function WiseTreeLayer:ctor()
    ui.registerSwallowTouch({node = self})
    --
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    self.mChaildLayer = ui.newStdLayer()
    self:addChild(self.mChaildLayer)
    -- 剩余祈愿次数
    self.mWiseNum = 0
    -- 领取奖励的ID(0表示没有领取奖励)
    self.mDrawRewardId = 0
    -- 创建UI
    self:initUI()
    -- 获取活动数据
    self:requestGetInfo()
end
-- 初始页面
function WiseTreeLayer:initUI()
    --背景图
    local bgSprite = ui.newSprite("xn_35.jpg")
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
                [1] = TR("1.祈愿树上盛开着10种不同的花朵，每个花朵代表一种奖励，可自行选择想要奖励。"),
                [2] = TR("2.花朵从上到下分为10个档次，每个档次可选一种奖励。"),
                [3] = TR("3.选择完10朵花朵以后，使用祈愿牌祈愿，每次祈愿会随机获得一种奖励，直到10种奖励都被抽完。"),
                [4] = TR("4.祈愿牌通过充值获得，每充值满120,600,1000,2000,4000,10000,16000,20000,30000,60000元宝，都会获得一个祈愿牌，单笔充值最多获得10个祈愿牌。"),
                [5] = TR("5.一轮祈愿树最多获得10个祈愿牌。"),
                [6] = TR("6.奖励全部抽完以后才能重新选择，才能开启下一轮祈愿。"),
                [7] = TR("7.祈愿树每日会自动刷新一轮，充值进度也会重置。"),
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
        text = TR("祈 愿"),
        position = cc.p(340, 185),
        clickAction = function(pSender)
            self:getReward()
        end
    })
    self.mParentLayer:addChild(self.wiseBtn)

    -- 创建许愿次数
    local introLabel = ui.newLabel({
        text = TR("祈愿牌一轮最多获得10个，每日清空，请及时抽取"),
        size = 22,
        color = cc.c3b(0x25, 0x87, 0x11),
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        x = 520,
        y = 180,
        dimensions = cc.size(200, 0)
    })
    self.mParentLayer:addChild(introLabel)

    -- 创建许愿次数
    self.wiseCountLabel = ui.newLabel({
        text = string.format("{xn_45.png} %d", self.mWiseNum),
        size = 24,
        color = cc.c3b(0xff, 0xf7, 0xbd),
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        x = 350,
        y = 130,
    })
    self.mParentLayer:addChild(self.wiseCountLabel)

    --剩余时间
    local timeBg = ui.newScale9Sprite("c_25.png",cc.size(300, 50))
    timeBg:setPosition(130, 180)
    self.mParentLayer:addChild(timeBg)
    local timeLabel = ui.newLabel({
        text = TR("活动倒计时：00:00:00"),
        -- color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    timeLabel:setPosition(130, 180)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    local extLabel = ui.newLabel({
        text = "",
        -- color = cc.c3b(0x46, 0x22, 0x0d),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        dimensions = cc.size(280, 0)
    })
    extLabel:setPosition(150, 130)
    self.mParentLayer:addChild(extLabel)
    self.mExtLabel = extLabel
end

-- 创建礼物道具
function WiseTreeLayer:createTenGift( )
    self.mChaildLayer:removeAllChildren()
    for i,v in ipairs(self.mRewardInfo) do
        -- 判断是否选择奖励
        if v.IsActive then 
            -- 显示奖励头像
            local flower = ui.newSprite("xn_38.png")
            flower:setPosition(cc.p(Giftpos[i].x-6, Giftpos[i].y-1))
            self.mChaildLayer:addChild(flower)
            flower:setScale(0.9)
            local rewardInfo = Utility.analysisStrResList(v.Reward)
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = rewardInfo[1].resourceTypeSub,
                modelId = rewardInfo[1].modelId,
                num = rewardInfo[1].num,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
            })
            tempCard:setScale(0.8)
            tempCard:setPosition(Giftpos[i])
            self.mChaildLayer:addChild(tempCard)
            -- tempCard:setClickCallback(function ( ... )
            -- end)
            -- 如果已经领取了
            if v.IsReward then 
                local doneSprite = ui.newSprite("jc_21.png")
                doneSprite:setPosition(tempCard:getContentSize().width * 0.5, tempCard:getContentSize().height * 0.5)
                tempCard:addChild(doneSprite)
            end 

            -- 该奖励是刚刚领取的奖励需要显示特效
            if self.mDrawRewardId == v.Id then 
                ui.newEffect({
                    parent = tempCard,
                    effectName = "effect_ui_qiyuanshu",
                    animation = "shan",
                    position = cc.p(tempCard:getContentSize().width * 0.5, tempCard:getContentSize().height * 0.5),
                    loop = false,
                    endRelease = true,
                    speed = 0.2,
                })
            end    
        else 
            -- 添加加号
            local flower = ui.newSprite("xn_37.png")
            flower:setPosition(Giftpos[i])
            self.mChaildLayer:addChild(flower)
            flower:setScale(0.8)
            local button = ui.newButton({
                normalImage = "c_22.png",
                position = cc.p(Giftpos[i].x+8, Giftpos[i].y),
                clickAction = function()
                    LayerManager.addLayer({
                        name = "festival.WiseTreeSeclectLayer", 
                        cleanUp = false,
                        data = {
                            callback = function ( ... )
                                self:requestGetInfo()
                            end,
                            id = v.Id,
                            tag = ModuleSub.eCommonHoliday18,
                        }
                    })
                end
            })
            button:setScale(0.9)
            self.mChaildLayer:addChild(button)
            -- 执行动画
            local array = {
                cc.Spawn:create({
                    cc.ScaleTo:create(1, 0.8),
                }),
                cc.Spawn:create({
                    cc.ScaleTo:create(1, 1),
                }),
            }
            button:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
        end 
    end
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function WiseTreeLayer:refreshLayer()
    -- 刷新祈愿剩余次数
    self.wiseCountLabel:setString(string.format("{xn_45.png} %d", self.mWiseNum))
    -- 刷新再充值提示
    self.mExtLabel:setString(TR("再充值%s元宝可获得一个祈愿牌", self.mExtNum))
    self.mExtLabel:setVisible(self.mExtNum > 0)

    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
    -- 刷新奖励
    self:createTenGift()
end

-- 活动倒计时
function WiseTreeLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
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

--=======================================网络请求========================================
--请求信息
function WiseTreeLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedWishtree", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "ReceiveReward")
            -- 活动倒计时
            self.mEndTime = data.Value.EndTime or 0
            -- 剩余次数
            self.mWiseNum = data.Value.Num or 0
            -- 再充值
            self.mExtNum = data.Value.NeedNum or 0
            -- 奖励列表
            self.mRewardInfo = data.Value.RewardList or {}
            -- 领取奖励的ID(0表示没有领取奖励)
            self.mDrawRewardId = 0
            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 领取奖励
function WiseTreeLayer:getReward()
    HttpClient:request({
        moduleName = "TimedWishtree",
        methodName = "Reward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "Reward:")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 活动倒计时
            self.mEndTime = data.Value.EndTime or 0
            -- 剩余次数
            self.mWiseNum = data.Value.Num or 0
            -- 再充值
            self.mExtNum = data.Value.NeedNum or 0
            -- 奖励列表
            self.mRewardInfo = data.Value.RewardList or {}
            -- 领取奖励的ID(0表示没有)
            self.mDrawRewardId = data.Value.DrawRewardId or 0 
            -- 飘窗奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            -- 判断是否祈愿完所有奖励
            local isGetAllReward = true
            for i,v in ipairs(self.mRewardInfo) do
                if v.IsActive and not v.IsReward then -- 已经选择奖励但是没有领取
                    isGetAllReward = false
                    break
                end 
            end
            -- 如果全部领取了添加一个特效
            if isGetAllReward then 
                for i=1,10 do
                    ui.newEffect({
                        parent = self.mChaildLayer,
                        effectName = "effect_ui_qiyuanshu",
                        animation = "hua",
                        position = cc.p(Giftpos[i].x, Giftpos[i].y + 10),
                        loop = false,
                        endRelease = true,
                        speed = 0.3,
                        zorder = 10, -- 放在花瓣上面
                        endListener = function ()
                            -- 刷新页面
                            self:refreshLayer()
                        end
                    })
                end
            else 
                -- 刷新页面
                self:refreshLayer()
            end
        end
    })
end

return WiseTreeLayer