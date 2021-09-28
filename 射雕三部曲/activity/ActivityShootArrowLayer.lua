--[[
    文件名: ActivityShootArrowLayer.lua
    描述: 射箭活动页面
    效果图: 
    创建人: yanghongsheng
    创建时间: 2018.7.30
--]]

local ActivityShootArrowLayer = class("ActivityShootArrowLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：

]]
function ActivityShootArrowLayer:ctor(params)
    self.mRingRewardList = {}
    self.mReceivedList = {}
    self.mShootTargetInfo = {}
    self.mRankList = {}
    -- 游戏是否结束
    self.gameover = true
    -- 游戏是否在时间段内
    self.isCanPlay = true
    -- 修改随机种子
    math.randomseed(os.time())
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    --创建底部和顶部的控件
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 初始化页面控件
    self:initUI()

    -- 获取射靶信息
    self:requestGetInfo()
end

function ActivityShootArrowLayer:initUI()
    -- 背景
    local bgSprite = ui.newSprite("jchd_19.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 按钮
    self:createBtns()
end

function ActivityShootArrowLayer:refreshWindShow()
    if not self.mWindBg then
        self.mWindBg = ui.newSprite("jchd_28.png")
        self.mWindBg:setPosition(320, 1000)
        self.mParentLayer:addChild(self.mWindBg)

        local bgSize = self.mWindBg:getContentSize()

        -- 左进度条
        self.leftBar = require("common.ProgressBar"):create({
                bgImage = "jchd_29.png",
                barImage = "jchd_30.png",
                currValue = self.mShootTargetInfo.WindPowerLv >= 0 and 0 or math.abs(self.mShootTargetInfo.WindPowerLv),
                maxValue = 3,
                needLabel = false,
            })
        self.leftBar:setRotation(180)
        self.leftBar:setAnchorPoint(cc.p(0, 0.5))
        self.leftBar:setPosition(cc.p(5, bgSize.height*0.4))
        self.mWindBg:addChild(self.leftBar)

        -- 右进度条
        self.rightBar = require("common.ProgressBar"):create({
                bgImage = "jchd_29.png",
                barImage = "jchd_30.png",
                currValue = self.mShootTargetInfo.WindPowerLv <= 0 and 0 or math.abs(self.mShootTargetInfo.WindPowerLv),
                maxValue = 3,
                needLabel = false,
            })
        self.rightBar:setAnchorPoint(cc.p(0, 0.5))
        self.rightBar:setPosition(cc.p(bgSize.width-5, bgSize.height*0.4))
        self.mWindBg:addChild(self.rightBar)

        local tempSprite = ui.newSprite("jchd_28.png")
        tempSprite:setPosition(bgSize.width*0.5, bgSize.height*0.5)
        self.mWindBg:addChild(tempSprite)

        -- 等级数字
        self.lvLabel = ui.newLabel({
                text = math.abs(self.mShootTargetInfo.WindPowerLv),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 27,
            })
        self.lvLabel:setPosition(bgSize.width*0.5, bgSize.height*0.4)
        self.mWindBg:addChild(self.lvLabel)

        -- 左箭头
        self.leftArrow = ui.newSprite("jchd_32.png")
        self.leftArrow:setPosition(-100, bgSize.height*0.4)
        self.mWindBg:addChild(self.leftArrow)

        -- 右箭头
        self.rightArrow = ui.newSprite("jchd_32.png")
        self.rightArrow:setRotation(180)
        self.rightArrow:setPosition(bgSize.width+100, bgSize.height*0.4)
        self.mWindBg:addChild(self.rightArrow)

        -- 竖线
        local posXList = {-69, -30, bgSize.width+31, bgSize.width+69}
        for i = 1, 4 do
            local line = ui.newSprite("jchd_31.png")
            line:setPosition(posXList[i], bgSize.height*0.4)
            self.mWindBg:addChild(line)
        end
    end

    self.lvLabel:setString(math.abs(self.mShootTargetInfo.WindPowerLv))
    self.leftBar:setCurrValue(self.mShootTargetInfo.WindPowerLv >= 0 and 0 or math.abs(self.mShootTargetInfo.WindPowerLv))
    self.rightBar:setCurrValue(self.mShootTargetInfo.WindPowerLv <= 0 and 0 or math.abs(self.mShootTargetInfo.WindPowerLv))
    self.leftArrow:setVisible(self.mShootTargetInfo.WindPowerLv < 0)
    self.rightArrow:setVisible(self.mShootTargetInfo.WindPowerLv > 0)
end

function ActivityShootArrowLayer:refreshTargetShow()
    -- 缩放列表
    local targetScaleList = {0.28, 0.2, 0.12}  
    local lanScaleList = {0.8, 0.58, 0.3}
    -- 箭靶移动
    local timeList = {2, 1.5, 1, 0.5, 0.4}  -- 箭靶移动速度
    local distanceList = {200, 180, 90} -- 箭靶移动距离

    -- 创建护栏
    if not self.mLand then
        self.mLand = ui.newSprite("jchd_25.png")
        self.mLand:setPosition(320, 650)
        self.mParentLayer:addChild(self.mLand)
    end
    -- 创建靶子
    if not self.mTarget then
        self.mTarget = ui.newSprite("jchd_23.png")
        self.mTarget:setPosition(320, 650)
        self.mParentLayer:addChild(self.mTarget)
        self.mTarget:setScale(0.32)
    end

    -- 设置视距缩放
    self.mTargetScale = targetScaleList[self.mShootTargetInfo.ScaleLv]   -- 靶子缩放大小
    self.mLand:setScale(lanScaleList[self.mShootTargetInfo.ScaleLv])
    self.mTarget:setScale(self.mTargetScale)
    self.mLand:setPosition(320, 650)
    self.mTarget:setPosition(320, 650)
    self.mTarget:stopAllActions()

    -- 添加移动
    if self.mShootTargetInfo.MoveSpeedLv >= 2 then 
        local time = timeList[self.mShootTargetInfo.MoveSpeedLv]
        local posX = distanceList[self.mShootTargetInfo.ScaleLv]
        self.mTarget:runAction(cc.MoveBy:create(time, cc.p(posX, 0)))
        Utility.performWithDelay(self.mTarget, function()
            local sequence = cc.Sequence:create(cc.MoveBy:create(time*2, cc.p(posX * -2, 0)), cc.MoveBy:create(time*2, cc.p(posX * 2, 0)))
            local action = cc.RepeatForever:create(sequence)
            self.mTarget:runAction(action)
        end, time)
    end

end

-- 刷新弓箭位置
function ActivityShootArrowLayer:refreshArchShow()
    -- 弓箭
    if not self.mArchSprite then
        self.mArchSprite = ui.newSprite("jchd_20.png")
        self.mArchSprite:setPosition(380, 600)
        self.mParentLayer:addChild(self.mArchSprite)

        self.arrow = ui.newSprite("jchd_21.png")
        self.arrow:setScale(0.5)
        self.arrow:setPosition(self.mArchSprite:getContentSize().width, self.mArchSprite:getContentSize().height*0.2)
        self.mArchSprite:addChild(self.arrow)
    end

    -- 瞄准
    if not self.mAimSprite then
        self.mAimSprite = ui.newSprite("jchd_22.png")
        self.mAimSprite:setPosition(380, 750)
        self.mParentLayer:addChild(self.mAimSprite)
    end

    -- 创建箭头
    if self.arrowNock then
        self.arrowNock:removeFromParent()
        self.arrowNock = nil
    end
    self.arrowNock = ui.newSprite("jchd_24.png")
    self.mParentLayer:addChild(self.arrowNock)

    -- 触摸层
    if not self.mTouchLayer then
        self.mTouchLayer = display.newLayer()
        self.mParentLayer:addChild(self.mTouchLayer)

        ui.registerSwallowTouch({
            node =  self.mTouchLayer,
            allowTouch = false,
            beganEvent = function (touch, event)
                if self.gameover then
                    starPos = self.mParentLayer:convertToNodeSpace(touch:getLocation())
                    disX = starPos.x - 320
                    disY = starPos.y - 640
                    -- 游戏开始
                    if starPos.x >= 120 and starPos.x <= 600 then 
                        if starPos.y >= 320 and starPos.y <= 820 then
                            if not self.isCanPlay then
                                local startDate = os.date("*t", self.mActivityInfo.StartDate)
                                local endDate = os.date("*t", self.mActivityInfo.EndDate)
                                ui.showFlashView(TR("请在%02d:%02d:%02d到%02d:%02d:%02d时间内参与活动",
                                    startDate.hour, startDate.min, startDate.sec,
                                    endDate.hour, endDate.min, endDate.sec))
                            elseif self.mShootTargetInfo.DailyNum <= 0 then 
                                color = cc.c3b(0x46, 0x22, 0x0d),
                                ui.showFlashView(TR("没有箭矢了"))
                            else
                                self:gameStart()
                                return true
                            end
                        end
                    end
                end
            end,
            movedEvent = function (touch, event)
                -- 瞄准
                local movePos = self.mParentLayer:convertToNodeSpace(touch:getLocation())
                local posX = movePos.x - disX 
                local posY = movePos.y - disY
                if posX > 600 then 
                    posX = 600
                elseif posX < 40 then
                    posX = 40
                end
                if posY > 900 then 
                    posY = 900
                elseif posY < 300 then
                    posY = 300
                end
                self.mAimSprite:setPosition(posX, posY)
                self.mArchSprite:setPosition(posX, posY - 160)
            end,
            endedEvent = function (touch, event)
                self.arrow:runAction(cc.MoveBy:create(0.05, cc.p(-15, 50)))
                
                Utility.performWithDelay(self.mTarget, function()
                    self.arrow:setVisible(false)
                    self:shootArrow()
                end, 0.05)
            end,
        })
    end

    self.mArchSprite:setVisible(true)
    self.arrow:setVisible(true)
    self.mArchSprite:setPosition(380, 600)
    self.mAimSprite:setPosition(380, 750)
    self.mAimSprite:setScale(1.2)
    self.mAimSprite:stopAllActions()

end

-- 游戏开始
function ActivityShootArrowLayer:gameStart()
    self.gameover = false
    -- 缩小准星
    self.mAimSprite:runAction(cc.ScaleTo:create(0.2, 1))
    -- 拉弓
    self.arrow:runAction(cc.MoveBy:create(0.2, cc.p(15, -50)))
    -- 记录所耗时间
    self.mCostTime = 0
    -- 所耗时间
    Utility.schedule(self.arrowNock, function()
        self.mCostTime = self.mCostTime + 0.1
    end, 0.1)
   
    Utility.performWithDelay(self.mAimSprite, function()
        -- 箭头抖动
        Utility.schedule(self.mAimSprite, function()
            local pos = cc.p(math.random(-12, 12), math.random(-12, 12))
            self.mArchSprite:runAction(cc.MoveBy:create(0.3, pos))
            self.mAimSprite:runAction(cc.MoveBy:create(0.3, pos))
        end, 0.3)
    end, 0.2)
end

-- 射出箭
function ActivityShootArrowLayer:shootArrow()
    self.mAimSprite:stopAllActions()
    local posX = self.mAimSprite:getPositionX() 
    local posY = self.mAimSprite:getPositionY()
    -- 箭飞行效果
    self.arrowNock:setVisible(true)
    self.arrowNock:setPosition(cc.p(posX, posY))

    -- 箭飞行时间
    local timeList = {0.2, 0.3, 0.4}
    local scaleList = {0.3, 0.2, 0.1}
    local flyTime = timeList[self.mShootTargetInfo.ScaleLv]

    -- 风力所造成的偏移量
    local deviationX = self.mShootTargetInfo.WindPowerLv * 15 * self.mTargetScale
    -- 旋转度
    local actList = cc.Spawn:create(
        cc.ScaleTo:create(flyTime, scaleList[self.mShootTargetInfo.ScaleLv]),
        cc.MoveBy:create(flyTime, cc.p(deviationX, 0))
    )
    self.arrowNock:runAction(actList)

    Utility.performWithDelay(self.mTarget, function()
        self:gameOver()
    end, flyTime)
end

-- 游戏结果
function ActivityShootArrowLayer:gameOver()
    -- print("游戏结束")
    self.arrowNock:stopAllActions()
    self.mTarget:stopAllActions()
    -- 计算环数
    -- 箭靶坐标
    local posTarget = cc.p(self.mTarget:getPositionX(), self.mTarget:getPositionY())
    -- 落点坐标
    local posArrowNock = cc.p(self.arrowNock:getPositionX(), self.arrowNock:getPositionY())
    -- 距离
    local distance = cc.pGetLength(cc.pSub(posTarget, posArrowNock))
    
    -- 当前箭靶半径
    local radius = self.mTarget:getBoundingBox().width / 2 - 26 * self.mTargetScale
    -- 环数
    local ring 
    if distance > radius then 
        ring = 0
    else
        local num = distance / (radius / 10) - math.floor(distance / (radius / 10))
        -- print("误差", distance / (radius / 10), math.floor(distance / (radius / 10)), num)
        ring = 10 - math.floor(distance / (radius / 10))
        if ring < 10 then
            if num < 0.28 then 
                ring = ring + 1
            end
        end
    end
    local disX = (posArrowNock.x - posTarget.x) / self.mTargetScale
    local disY = (posArrowNock.y - posTarget.y) / self.mTargetScale
    local posPoint = cc.p(disX + 299, disY + 299)

    Utility.performWithDelay(self.mTarget, function()
        self.mArchSprite:setVisible(false)
        self.arrow:setVisible(false)
        self:createRingShow(posPoint, ring, self.mCostTime)
        self:requestShoot(ring, self.mCostTime)
    end, 0.3)
end

function ActivityShootArrowLayer:createRingShow(pos, ring, costTime)
    local popSize = cc.size(598, 599)
    local ringPop = require("commonLayer.PopBgLayer").new({
            bgImage = "jchd_23.png",
            bgSize = popSize,
            closeImg = "",
            title = "",
            isCloseOnTouch = true,
            closeAction = function (pSender)
                LayerManager.removeLayer(pSender)
            end,
        })
    self:addChild(ringPop)
    -- 箭头
    local arrSprite = ui.newSprite("jchd_24.png")
    arrSprite:setPosition(pos)
    ringPop.mBgSprite:addChild(arrSprite)
    -- 环数
    local ringLabel = ui.newLabel({
            text = TR("%d环", ring),
            outlineColor = Enums.Color.eOutlineColor,
        })
    ringLabel:setPosition(popSize.width*0.5, -20)
    ringPop.mBgSprite:addChild(ringLabel)
    -- 秒数
    local timeLabel = ui.newLabel({
            text = TR("耗时%.1f秒", costTime),
            outlineColor = Enums.Color.eOutlineColor,
        })
    timeLabel:setPosition(popSize.width*0.5, -50)
    ringPop.mBgSprite:addChild(timeLabel)
end

function ActivityShootArrowLayer:createBtns()
    local btnList = {
        -- 规则
        {
            position = cc.p(50, 1050),
            normalImage = "c_72.png",
            clickAction = function ()
                MsgBoxLayer.addRuleHintLayer(TR("规则"),
                {
                    TR("1.每日获得一定数量的箭矢，消耗箭矢参与竞赛，根据环数排行。"),
                    TR("2.射靶竞赛每天5点开启，22点结束并发放排行奖励。"),
                    TR("3.每日达到射箭一定环数可以领取环数奖励。"),
                })
            end
        },
        -- 返回
        {
            position = cc.p(590, 1050),
            normalImage = "c_29.png",
            clickAction = function ()
                LayerManager.removeLayer(self)
            end
        },
    }

    for _, btnInfo in pairs(btnList) do
        local tempBtn = ui.newButton(btnInfo)
        self.mParentLayer:addChild(tempBtn)
    end
end

-- 创建宝箱按钮
function ActivityShootArrowLayer:refreshBoxsBtn()
    if not self.BoxsParent then
        self.BoxsParent = cc.Node:create()
        self.mParentLayer:addChild(self.BoxsParent)
    end
    self.BoxsParent:removeAllChildren()

    local posX = 50
    local posY = 260
    local space = 120
    for i, rewardInfo in ipairs(self.mRingRewardList) do
        local bgSprite = ui.newSprite("jchd_15.png")
        bgSprite:setPosition(posX, posY+i*space)
        self.BoxsParent:addChild(bgSprite)

        local boxBtn = ui.newButton({
                position = cc.p(45, 45),
                normalImage = self.mReceivedList[rewardInfo.RingNum] and "jchd_27.png" or "jchd_26.png",
                clickAction = function ()
                    -- 可以领奖
                    if self.mShootTargetInfo.RingNum >= rewardInfo.RingNum then
                        self:requestReward(rewardInfo.RingNum)
                    else
                        MsgBoxLayer.addPreviewDropLayer(Utility.analysisStrResList(rewardInfo.Reward))
                    end
                end,
            })
        bgSprite:addChild(boxBtn)

        if self.mShootTargetInfo.RingNum >= rewardInfo.RingNum and not self.mReceivedList[rewardInfo.RingNum] then
            ui.setWaveAnimation(boxBtn, nil, nil, cc.p(35, 45))
        end

        -- 环数
        local ringLabel = ui.newLabel({
                text = TR("%d环", rewardInfo.RingNum),
            })
        ringLabel:setPosition(45, 5)
        bgSprite:addChild(ringLabel)
    end
end

-- 刷新底部信息显示
function ActivityShootArrowLayer:refreshBottowShow()
    -- 背景
    if not self.mBottowBg then
        self.mBottowBg = ui.newSprite("jchd_16.png")
        self.mBottowBg:setAnchorPoint(cc.p(0.5, 0))
        self.mBottowBg:setPosition(320, 0)
        self.mParentLayer:addChild(self.mBottowBg)
    end
    self.mBottowBg:removeAllChildren()

    if not next(self.mShootTargetInfo) then return end

    -- 剩余箭支
    local arrowCountLabel = ui.newLabel({
            text = TR("剩余箭支：%d", self.mShootTargetInfo.DailyNum),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    arrowCountLabel:setAnchorPoint(cc.p(0, 0))
    arrowCountLabel:setPosition(50, 200)
    self.mBottowBg:addChild(arrowCountLabel)

    -- 当前总耗时
    local allTimeLabel = ui.newLabel({
            text = TR("当前总耗时数：%.1f", self.mShootTargetInfo.TotalSeconds/1000),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    allTimeLabel:setAnchorPoint(cc.p(0, 0))
    allTimeLabel:setPosition(240, 200)
    self.mBottowBg:addChild(allTimeLabel)

    -- 当前总环数
    local allRingLabel = ui.newLabel({
            text = TR("当前总环数：%d", self.mShootTargetInfo.RingNum),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    allRingLabel:setAnchorPoint(cc.p(0, 0))
    allRingLabel:setPosition(50, 150)
    self.mBottowBg:addChild(allRingLabel)

    -- 当前排名
    local rankLabel = ui.newLabel({
            text = TR("当前排名：%s", self.mShootTargetInfo.MyRank > 0 and tostring(self.mShootTargetInfo.MyRank) or TR("未上榜")),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    rankLabel:setAnchorPoint(cc.p(0, 0))
    rankLabel:setPosition(240, 150)
    self.mBottowBg:addChild(rankLabel)

    -- 查看排名
    local rankBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("查看排名"),
            clickAction = function ()
                self:requestRank()
            end
        })
    rankBtn:setPosition(550, 190)
    self.mBottowBg:addChild(rankBtn)
end

function ActivityShootArrowLayer:createRankBox()
    local popSize = cc.size(600, 600)
    local rankPop = require("commonLayer.PopBgLayer").new({
            bgImage = "mrjl_02.png",
            bgSize = popSize,
            title = TR("排行榜"),
            closeAction = function (pSender)
                LayerManager.removeLayer(pSender)
            end,
        })
    self:addChild(rankPop)
    local bgSprite = rankPop.mBgSprite

    -- 灰背景
    local blackBg = ui.newScale9Sprite("c_17.png", cc.size(520, 400))
    blackBg:setAnchorPoint(cc.p(0.5, 1))
    blackBg:setPosition(popSize.width*0.5, popSize.height-70)
    bgSprite:addChild(blackBg)
    -- 灰背景
    local blackBg2 = ui.newScale9Sprite("c_17.png", cc.size(520, 80))
    blackBg2:setAnchorPoint(cc.p(0.5, 0))
    blackBg2:setPosition(popSize.width*0.5, 40)
    bgSprite:addChild(blackBg2)

    -- title
    local titleLabel = ui.newLabel({
            text = TR("排名         玩家名        总环数     总耗时     排行奖励"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    titleLabel:setPosition(popSize.width*0.5, popSize.height-90)
    bgSprite:addChild(titleLabel)

    -- 我的排名
    local myRankLabel = ui.newLabel({
            text = TR("排名：%s        总环数：%d        总耗时：%.1f",
                self.mShootTargetInfo.MyRank > 0 and tostring(self.mShootTargetInfo.MyRank) or TR("未上榜"),
                self.mShootTargetInfo.RingNum, self.mShootTargetInfo.TotalSeconds/1000),
            outlineColor = Enums.Color.eOutlineColor,
            size = 20,
        })
    myRankLabel:setAnchorPoint(cc.p(0, 0.5))
    myRankLabel:setPosition(50, 80)
    bgSprite:addChild(myRankLabel)

    -- 排行榜
    listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(520, 350))
    listView:setItemsMargin(5)
    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
    listView:setAnchorPoint(cc.p(0.5, 1))
    listView:setPosition(popSize.width*0.5, popSize.height-110)
    bgSprite:addChild(listView)

    -- 创建项
    local function createItem(rankInfo)
        local cellSize = cc.size(500, 85)
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(listView:getContentSize().width, cellSize.height))
        -- 背景
        local cellBg = ui.newScale9Sprite("c_18.png", cellSize)
        cellBg:setPosition(listView:getContentSize().width*0.5, cellSize.height*0.5)
        layout:addChild(cellBg)

        -- 排名
        local rankPic = {
            "c_44.png",
            "c_45.png",
            "c_46.png",
        }
        local rankSprite = ui.newSprite(rankPic[rankInfo.Rank] or "c_47.png")
        rankSprite:setPosition(40, cellSize.height*0.5)
        cellBg:addChild(rankSprite)

        local rankLabel = ui.newLabel({
                text = rankPic[rankInfo.Rank] and "" or rankInfo.Rank,
            })
        rankLabel:setPosition(rankSprite:getContentSize().width*0.5, rankSprite:getContentSize().height*0.5)
        rankSprite:addChild(rankLabel)

        -- 玩家名
        local nameLabel = ui.newLabel({
                text = rankInfo.PlayerName,
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
                dimensions = cc.size(100, 0)
            })
        nameLabel:setAnchorPoint(cc.p(0, 0.5))
        nameLabel:setPosition(90, cellSize.height*0.5)
        cellBg:addChild(nameLabel)

        -- 总环数
        local ringNumLabel = ui.newLabel({
                text = rankInfo.RingNum,
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
        ringNumLabel:setPosition(250, cellSize.height*0.5)
        cellBg:addChild(ringNumLabel)

        -- 总耗时
        local timeLabel = ui.newLabel({
                text = string.format("%.1f", rankInfo.TotalSeconds/1000),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
        timeLabel:setPosition(345, cellSize.height*0.5)
        cellBg:addChild(timeLabel)

        -- 奖励
        local rewardList = Utility.analysisStrResList(rankInfo.Reward)
        local cardList = ui.createCardList({
                maxViewWidth = 200,
                cardDataList = rewardList,
            })
        cardList:setAnchorPoint(cc.p(0, 0.5))
        cardList:setPosition(380, cellSize.height*0.5)
        cardList:setScale(0.55)
        cellBg:addChild(cardList)

        return layout
    end

    for _, rankInfo in ipairs(self.mRankList) do
        local item = createItem(rankInfo)
        listView:pushBackCustomItem(item)
    end
end

function ActivityShootArrowLayer:refreshUI()
    self.gameover = true
    -- 风力
    self:refreshWindShow()
    -- 靶子
    self:refreshTargetShow()
    -- 弓箭
    self:refreshArchShow()
    -- 刷新底部信息显示
    self:refreshBottowShow()
    -- 刷新宝箱
    self:refreshBoxsBtn()
end

function ActivityShootArrowLayer.createTimeUpdate(node, timeTick)
    if node.timeUpdate then
        node:stopAction(node.timeUpdate)
        node.timeUpdate = nil
    end

    node.timeUpdate = Utility.schedule(node, function ()
        local timeLeft = timeTick - Player:getCurrentTime()
        if timeLeft > 0 then
            node:setString(string.format("%s", MqTime.formatAsDay(timeLeft)))
        else
            node:stopAction(node.timeUpdate)
            node.timeUpdate = nil
        end
    end, 1)
end

-- 创建活动结束倒计时
function ActivityShootArrowLayer:createActivityEndTime()
    if not self.mEndTimeLabel then
        self.mEndTimeLabel = ui.newLabel({
                text = "",
                color = cc.c3b(0x46, 0x22, 0x0d)
            })
        self.mEndTimeLabel:setAnchorPoint(cc.p(0, 0))
        self.mEndTimeLabel:setPosition(50, 100)
        self.mParentLayer:addChild(self.mEndTimeLabel, 1)
    end
    self.mEndTimeLabel:setString("")

    if self.mEndTimeLabel.timeUpdate then
        self.mEndTimeLabel:stopAction(self.mEndTimeLabel.timeUpdate)
        self.mEndTimeLabel.timeUpdate = nil
    end

    self.mEndTimeLabel.timeUpdate = Utility.schedule(self.mEndTimeLabel, function ()
        local timeLeft = self.mActivityEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mEndTimeLabel:setString(TR("活动倒计时: %s", MqTime.formatAsDay(timeLeft)))
        else
            self.mEndTimeLabel:stopAction(self.mEndTimeLabel.timeUpdate)
            self.mEndTimeLabel.timeUpdate = nil
        end
    end, 1)
end

-- 创建今日活动计时
function ActivityShootArrowLayer:createActivityDailyTime()
    if not self.mDailyTimeLabel then
        self.mDailyTimeLabel = ui.newLabel({
                text = "",
                color = cc.c3b(0x46, 0x22, 0x0d)
            })
        self.mDailyTimeLabel:setAnchorPoint(cc.p(0, 0))
        self.mDailyTimeLabel:setPosition(350, 100)
        self.mParentLayer:addChild(self.mDailyTimeLabel, 1)
    end
    self.mDailyTimeLabel:setString("")

    if self.mDailyTimeLabel.timeUpdate then
        self.mDailyTimeLabel:stopAction(self.mDailyTimeLabel.timeUpdate)
        self.mDailyTimeLabel.timeUpdate = nil
    end

    self.mEndTimeLabel.timeUpdate = Utility.schedule(self.mEndTimeLabel, function ()
        if Player:getCurrentTime() <= self.mActivityInfo.StartDate then
            local timeLeft = self.mActivityInfo.StartDate - Player:getCurrentTime()
            self.mDailyTimeLabel:setString(TR("活动开始倒计时: %s", MqTime.formatAsDay(timeLeft)))
            self.isCanPlay = false
        elseif self.mActivityInfo.StartDate < Player:getCurrentTime() and Player:getCurrentTime() <= self.mActivityInfo.EndDate then
            local timeLeft = self.mActivityInfo.EndDate - Player:getCurrentTime()
            self.mDailyTimeLabel:setString(TR("发奖倒计时: %s", MqTime.formatAsDay(timeLeft)))
            self.isCanPlay = true
        else
            self.mDailyTimeLabel:setString(TR("今日射靶活动已结束"))
            self.isCanPlay = false
            self.mDailyTimeLabel:stopAction(self.mDailyTimeLabel.timeUpdate)
            self.mDailyTimeLabel.timeUpdate = nil
        end
    end, 1)
end

---------------------------网络相关------------------------------
-- 请求服务器数据
function ActivityShootArrowLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedShoottarget",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mShootTargetInfo = response.Value.ShootTargetInfo
            self.mActivityInfo = response.Value.ActivityInfo
            self.mActivityEndTime = response.Value.ActivityEndTime

            -- 是否开启活动
            if self.mActivityInfo.StartDate <= Player:getCurrentTime() and self.mActivityInfo.EndDate > Player:getCurrentTime() then
                self.isCanPlay = true
            else
                self.isCanPlay = false
            end

            -- 创建活动倒计时
            self:createActivityEndTime()
            self:createActivityDailyTime()

            -- 宝箱奖励列表
            self.mRingRewardList = response.Value.ActivityInfo.RingNumRewardInfo
            table.sort(self.mRingRewardList, function (rewardInfo1, rewardInfo2)
                return rewardInfo1.RingNum < rewardInfo2.RingNum
            end)
            -- 已领取宝箱奖励列表
            local receiveStrList = string.splitBySep(response.Value.ShootTargetInfo.RingRewardIdStr, ",")
            for _, receiveRing in pairs(receiveStrList) do
                self.mReceivedList[tonumber(receiveRing)] = true
            end

            self:refreshUI()
        end
    })
end

-- 请求射箭
function ActivityShootArrowLayer:requestShoot(ring, time)
    HttpClient:request({
        moduleName = "TimedShoottarget",
        methodName = "Shoot",
        svrMethodData = {ring, time*1000},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mShootTargetInfo = response.Value.ShootTargetInfo

            -- 已领取宝箱奖励列表
            local receiveStrList = string.splitBySep(response.Value.ShootTargetInfo.RingRewardIdStr, ",")
            for _, receiveRing in pairs(receiveStrList) do
                self.mReceivedList[tonumber(receiveRing)] = true
            end

            self:refreshUI()
        end
    })
end

-- 请求领奖
function ActivityShootArrowLayer:requestReward(ring)
    HttpClient:request({
        moduleName = "TimedShoottarget",
        methodName = "DrawReward",
        svrMethodData = {ring},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mShootTargetInfo = response.Value.ShootTargetInfo
            
            -- 已领取宝箱奖励列表
            local receiveStrList = string.splitBySep(response.Value.ShootTargetInfo.RingRewardIdStr, ",")
            for _, receiveRing in pairs(receiveStrList) do
                self.mReceivedList[tonumber(receiveRing)] = true
            end

            self:refreshUI()
        end
    })
end

-- 请求排行榜
function ActivityShootArrowLayer:requestRank()
    HttpClient:request({
        moduleName = "TimedShoottarget",
        methodName = "GetRank",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mShootTargetInfo.reward = ""
            
            self.mRankList = response.Value.RankList
            -- 排序
            table.sort(self.mRankList, function (rankInfo1, rankInfo2)
                return rankInfo1.Rank < rankInfo2.Rank
            end)
            -- 我的奖励
            for _, rankInfo in ipairs(self.mRankList) do
                if rankInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                    self.mShootTargetInfo.reward = rankInfo.Reward
                    break
                end
            end

            self:createRankBox()
        end
    })
end

return ActivityShootArrowLayer