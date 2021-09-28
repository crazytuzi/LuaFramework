--[[
    文件名：ActivityDragonTreasureLayer.lua
    文件描述：限时金龙宝藏
    创建人：yanghongsheng
    创建时间：2018.11.15
]]

local ActivityDragonTreasureLayer = class("ActivityDragonTreasureLayer", function(params)
    return display.newLayer()
end)

function ActivityDragonTreasureLayer:ctor(params)
    self.mEndTime = 0       -- 活动结束时间
    self.mIsPutIn = false   -- 是否放入箱子
    self.mOpenNum = 0       -- 剩余钥匙
    self.mNeedNum = 0      -- 再充值多少元获得钥匙
    self.mReceviedRewardList = {}   -- 开过的奖励数据
    self.mBaseRewardList = {}       -- 所有奖励信息
    self.mReceviedBoxList = {}  -- 已领宝箱列表
    self.mUseDiamond = 0        -- 刷新消耗元宝
    self.mIsNextDouble = false  -- 下次是否翻倍
    self.mDoubleRewardId = -1    -- 翻倍奖励id

    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)

    -- 初始化页面控件
    self:initUI()

	self:requestGetInfo()
end

function ActivityDragonTreasureLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("jrhd_142.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1045),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn, 1)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(45, 1045),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.九种物品和下次双倍共十种奖励可以抽取，使用刷新宝藏可以刷新想要的宝藏。"),
                TR("2.确定宝藏之后，将奖励放入宝箱，点击箱子开始抽取，放入宝箱后不能再刷新。"),
                TR("3.开启宝箱需要钥匙，每充值120、600、1000、2000、4000、10000、16000、20000、30000、60000元宝，都会获得一把钥匙，单笔充值最多获得10把钥匙。"),
                TR("4.一轮宝藏最多获得10把钥匙，10个宝箱开完之后开启下一轮。"),
                TR("5.每天会自动刷新一轮宝藏，充值进度也会重置。"),
                TR("6.抽取到下次双倍后下次奖励翻倍，下次双倍如果最后被抽到，那么在抽完九次后会自动刷新下一轮。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 创建显示宝箱和奖励
    self:refreshBoxRewardShow()

    -- 活动倒计时
    local timeBgSize = cc.size(335, 40)
    local timeBg = ui.newScale9Sprite("c_55.png", timeBgSize)
    timeBg:setPosition(178, 272)
    self.mParentLayer:addChild(timeBg)

    self.mTimeLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            size = 20,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mTimeLabel:setPosition(timeBgSize.width*0.5, timeBgSize.height*0.5)
    timeBg:addChild(self.mTimeLabel)

    -- 再充值多少元可以获得一个钥匙
    self.mRechargeHintLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            size = 18,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mRechargeHintLabel:setPosition(178, 234)
    self.mParentLayer:addChild(self.mRechargeHintLabel)

    -- 钥匙图
    local keySprite = ui.newSprite("jrhd_146.png")
    keySprite:setPosition(310, 116)
    self.mParentLayer:addChild(keySprite)
    -- 剩余钥匙数量
    self.mKeyNumLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mKeyNumLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mKeyNumLabel:setPosition(330, 116)
    self.mParentLayer:addChild(self.mKeyNumLabel)

    -- 一天获取最多钥匙提示
    local hintLabel = ui.newLabel({
            text = TR("钥匙一轮最多获取10个每日清空，请及时收取"),
            color = Enums.Color.eWhite,
            dimensions = cc.size(200, 0),
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    hintLabel:setAnchorPoint(cc.p(1, 0.5))
    hintLabel:setPosition(628, 257)
    self.mParentLayer:addChild(hintLabel)

    -- 下次是否为翻倍奖励
    self.mNextDoubleLabel = ui.newLabel({
            text = TR("下次奖励翻倍"),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mNextDoubleLabel:setPosition(320, 360)
    self.mNextDoubleLabel:setVisible(false)
    self.mParentLayer:addChild(self.mNextDoubleLabel)

    -- 刷新宝藏按钮
    self.mRefreshBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("刷新宝藏"),
            clickAction = function ()
                if self.mIsPutIn then
                    ui.showFlashView(TR("宝藏已放入箱子不能刷新"))
                    return
                end

                if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, self.mUseDiamond) then
                    return
                end

                MsgBoxLayer.addOKCancelLayer(
                    TR("是否确认花费%s%d%s元宝刷新宝藏", Enums.Color.eOrangeH, self.mUseDiamond, Enums.Color.eNormalWhiteH),
                    TR("提示"),
                    {
                        text = TR("确定"),
                        clickAction = function(layerObj)
                            self:requestRefreshReward()
                            LayerManager.removeLayer(layerObj)
                        end
                })
            end
        })
    self.mRefreshBtn:setPosition(549, 328)
    self.mParentLayer:addChild(self.mRefreshBtn)

    -- 刷新消耗
    self.mRefreshUseLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mRefreshUseLabel:setAnchorPoint(cc.p(1, 0.5))
    self.mRefreshUseLabel:setPosition(473, 328)
    self.mParentLayer:addChild(self.mRefreshUseLabel)

    -- 放入箱子按钮
    self.mOpenBtn = ui.newButton({
            normalImage = "fx_11.png",
            text = TR("放入箱子"),
            clickAction = function ()
                if self.mIsPutIn then
                    ui.showFlashView(TR("宝藏已放入箱子"))
                    return
                end

                self:PutBox()
            end
        })
    self.mOpenBtn:setPosition(320, 165)
    self.mParentLayer:addChild(self.mOpenBtn)
end

-- 创建显示宝箱和奖励
function ActivityDragonTreasureLayer:refreshBoxRewardShow()
    if not self.mBoxParent then
        self.mBoxParent = ui.newSprite("jrhd_143.png")
        self.mBoxParent:setPosition(320, 618)
        self.mParentLayer:addChild(self.mBoxParent)
    end
    self.mBoxParent:removeAllChildren()

    -- 宝箱坐标
    local boxPosList = {
        cc.p(120, 365),
        cc.p(220, 365),
        cc.p(320, 365),
        cc.p(420, 365),
        cc.p(520, 365),
        cc.p(120, 260),
        cc.p(220, 260),
        cc.p(320, 260),
        cc.p(420, 260),
        cc.p(520, 260),
    }
    -- 中心点
    local centerPos = cc.p(320, 310)
    -- 创建宝箱按钮
    local boxNodeList = {}
    for i, pos in ipairs(boxPosList) do
        local boxNode = nil
        -- 已领取宝箱
        if not self.mIsPutIn or self.mReceviedBoxList[i] then
            local boxSprite = ui.newSprite("jrhd_145.png")
            boxSprite:setAnchorPoint(cc.p(0.5, 0))
            boxSprite:setPosition(pos)
            self.mBoxParent:addChild(boxSprite)
            boxNode = boxSprite
        -- 未领取宝箱
        else
            local boxBtn = ui.newButton({
                normalImage = "jrhd_144.png",
                position = pos,
                clickAction = function (pSender)
                    if self.mOpenNum < 1 then
                        ui.showFlashView(TR("钥匙不足"))
                        return
                    end

                    self:requestGetReward(i, boxPosList[i])
                end,
            })
            boxBtn:setAnchorPoint(cc.p(0.5, 0))
            self.mBoxParent:addChild(boxBtn)
            boxNode = boxBtn
        end

        table.insert(boxNodeList, boxNode)
    end

    local cardNodeList = {}
    -- 显示所有奖励
    local col = 5
    local count = 0
    for resId, resStr in pairs(self.mBaseRewardList) do
        local cardNode = nil
        local resInfo = nil
        if resStr ~= "" then
            resInfo = Utility.analysisStrResList(resStr)[1]
            resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
            cardNode = CardNode.createCardNode(resInfo)
        else
            cardNode = ui.newSprite("jrhd_148.png")
        end
        local xCount = count%col
        local yCount = math.floor(count/col)
        cardNode:setScale(0.85)
        cardNode:setPosition(92+115*xCount, 165-85*yCount)
        self.mBoxParent:addChild(cardNode)

        -- 未开出图
        local notOpenSprite = ui.newSprite("jrhd_149.png")
        notOpenSprite:setPosition(cardNode:getContentSize().width*0.5, cardNode:getContentSize().height-10)
        cardNode:addChild(notOpenSprite, 100)
        cardNode.notOpenSprite = notOpenSprite
        -- 置灰
        cardNode:setGray(self.mIsPutIn and not self.mReceviedRewardList[resId])
        notOpenSprite:setVisible(self.mIsPutIn and not self.mReceviedRewardList[resId])

        -- 是否翻倍
        if tostring(self.mDoubleRewardId) == resId then
            -- 双倍标签
            local doubleSprite = ui.newSprite("jrhd_150.png")
            doubleSprite:setPosition(cardNode:getContentSize().width-15, cardNode:getContentSize().height-15)
            cardNode:addChild(doubleSprite)
        end

        count = count + 1

        -- 飞入宝箱动画
        cardNode.moveFun = function (target, time)
            -- 创建临时节点
            local tempCard = resInfo and CardNode.createCardNode(resInfo) or ui.newSprite("jrhd_148.png")
            tempCard:setScale(0.85)
            tempCard:setPosition(92+115*xCount, 165-85*yCount)
            self.mBoxParent:addChild(tempCard)
            -- 卡牌置灰
            target:setGray(true)
            cardNode.notOpenSprite:setVisible(true)
            -- 动画
            local move = cc.MoveTo:create(time, centerPos)
            local callfunc = cc.CallFunc:create(function(node)
                node:removeFromParent()
            end)
            local seq = cc.Sequence:create(move, callfunc)
            tempCard:runAction(seq)
        end

        table.insert(cardNodeList, cardNode)
    end

    self.mBoxParent.playAnimation = function ()
        -- 宝箱动画
        local time1 = 0.5
        local time2 = 0.5
        local time3 = 0.55
        local time4 = 0.5
        local boxAction1 = cc.CallFunc:create(function(node)
            for _, boxNode in pairs(boxNodeList) do
                local move = cc.MoveTo:create(time1, centerPos)
                boxNode:runAction(move)
            end
        end)
        -- 延时动作
        local delay1 = cc.DelayTime:create(time1)
        -- 播放卡牌动画
        local cardAction = cc.CallFunc:create(function(node)
            for _, cardNode in ipairs(cardNodeList) do
                cardNode:moveFun(time2)
            end
        end)
        -- 延时动作
        local delay2 = cc.DelayTime:create(time2)
        -- 宝箱关闭并抖动
        local boxAction2 = cc.CallFunc:create(function(node)
            for _, boxNode in pairs(boxNodeList) do
                boxNode:setTexture("jrhd_144.png")
                -- 抖动效果
                local digress = 10
                local actList = {
                    cc.RotateTo:create(0.1, -digress),
                    cc.RotateTo:create(0.1, digress),
                    cc.RotateTo:create(0.1, -digress),
                    cc.RotateTo:create(0.1, digress),
                    cc.RotateTo:create(0.1, -digress),
                    cc.RotateTo:create(0.05, 0),
                }
                local seq = cc.Sequence:create(actList)
                boxNode:runAction(seq)
            end
        end)
        -- 延时动作
        local delay3 = cc.DelayTime:create(time3)
        -- 飞回
        local boxAction3 = cc.CallFunc:create(function(node)
            for i, boxNode in ipairs(boxNodeList) do
                local move = cc.MoveTo:create(time4, boxPosList[i])
                boxNode:runAction(move)
            end
        end)
        
        local seq = cc.Sequence:create(boxAction1, delay1, cardAction, delay2, boxAction2, delay3, boxAction3)
        self.mBoxParent:runAction(seq)

        return time1+time2+time3+time4
    end
end

-- 更新时间
function ActivityDragonTreasureLayer:createUpdateTime()
    if self.mSchelTime then
        self.mTimeLabel:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end

    self.mSchelTime = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("活动倒计时：#f8ea3a%s",MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:setString(TR("活动倒计时：#f8ea3a00:00:00"))

            -- 停止倒计时
            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end

            LayerManager.removeLayer(self)
        end
    end, 1)
end

function ActivityDragonTreasureLayer:PutBox()
    -- 播放动画
    local actionTime = self.mBoxParent.playAnimation()
    -- 创建屏蔽层
    local layer = cc.Layer:create()
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = layer})
    self:addChild(layer, 10)
    -- 延时去除屏蔽
    Utility.performWithDelay(self, function ()
        layer:removeFromParent()
        -- 请求服务器放入宝箱
        self:requestPutBox()
    end, actionTime)
end

function ActivityDragonTreasureLayer:refreshUI()
    -- 刷新按钮
    if self.mIsPutIn then   -- 已放入箱子
        self.mOpenBtn:setEnabled(false)
        self.mOpenBtn:setTitleText(TR("已放入"))
        self.mRefreshBtn:setEnabled(false)
    else
        self.mOpenBtn:setEnabled(true)
        self.mOpenBtn:setTitleText(TR("放入箱子"))
        self.mRefreshBtn:setEnabled(true)
    end

    -- 刷新宝箱和奖励
    self:refreshBoxRewardShow()

    -- 刷新再充值xx元获得一个钥匙
    self.mRechargeHintLabel:setString(TR("再充值%d元宝可获得一个钥匙", self.mNeedNum))

    -- 剩余钥匙数量
    self.mKeyNumLabel:setString(string.format("x %d", self.mOpenNum))

    -- 刷新消耗
    self.mRefreshUseLabel:setString(string.format("{%s}%s", Utility.getDaibiImage(ResourcetypeSub.eDiamond), self.mUseDiamond))

    -- 下次是否翻倍
    self.mNextDoubleLabel:setVisible(self.mIsNextDouble)

    -- 创建活动倒计时
    self:createUpdateTime()
end

function ActivityDragonTreasureLayer:refreshData(response)
    self.mEndTime = response.Value.EndTime
    self.mUseDiamond = response.Value.RefreshConsume
    self.mOpenNum = response.Value.Num
    self.mIsPutIn = response.Value.IsPutIn
    self.mNeedNum = response.Value.NeedNum
    self.mReceviedBoxList = table.keys(response.Value.BoxInfo or {})
    self.mReceviedRewardList = table.values(response.Value.BoxInfo or {})
    self.mBaseRewardList = response.Value.BaseRecord
    self.mIsNextDouble = response.Value.NextIsDouble
    self.mDoubleRewardId = response.Value.DoubleRewardId

    -- 整理已开宝箱
    local tempList = self.mReceviedBoxList
    self.mReceviedBoxList = {}
    for _, boxId in pairs(tempList) do
        self.mReceviedBoxList[tonumber(boxId)] = true
    end

    -- 整理已开奖励
    local tempList = self.mReceviedRewardList
    self.mReceviedRewardList = {}
    for _, rewardId in pairs(tempList) do
        self.mReceviedRewardList[tostring(rewardId)] = true
    end
end

-- 创建双倍图飘窗
function ActivityDragonTreasureLayer:createDoubleFlash()
    local bgSprite = ui.newScale9Sprite("mrjl_01.png", cc.size(640, 150))
    bgSprite:setPosition(display.cx, display.cy)
    self:addChild(bgSprite)
    bgSprite:setOpacity(0)
    bgSprite:setScale(Adapter.MinScale)

    -- 双倍图
    local doubleSprite = ui.newSprite("jrhd_148.png")
    doubleSprite:setPosition(320, 80)
    doubleSprite:setOpacity(0)
    bgSprite:addChild(doubleSprite)

    local bgActList = {
        cc.Spawn:create({
            cc.FadeTo:create(0.5, 255),
            cc.CallFunc:create(function()
                doubleSprite:runAction(cc.FadeTo:create(0.5, 255))
            end
        )}),
        cc.DelayTime:create(0.5),
        cc.Spawn:create({
            cc.JumpBy:create(0.5, cc.p(0, 200 * Adapter.MinScale), 0, 1),
            cc.CallFunc:create(function()
                doubleSprite:runAction(cc.FadeTo:create(0.5, 255))
            end
        )}),
        cc.CallFunc:create(function(node)
            node:removeFromParent()
        end)
    }
    bgSprite:runAction(cc.Sequence:create(bgActList))
end

--======================================网络请求=================================
--请求信息
function ActivityDragonTreasureLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedGoldenDragonTreasure", 
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end

        	self:refreshData(data)

            self:refreshUI()
        end
    })
end
--请求刷新奖励列表
function ActivityDragonTreasureLayer:requestRefreshReward()
	HttpClient:request({
        moduleName = "TimedGoldenDragonTreasure", 
        methodName = "RefreshReward",
        svrMethodData = {},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end

            self:refreshData(data)

            self:refreshUI()
        end
    })
end

--请求获取奖励
function ActivityDragonTreasureLayer:requestGetReward(boxId, boxPos)
	HttpClient:request({
        moduleName = "TimedGoldenDragonTreasure", 
        methodName = "GetReward",
        svrMethodData = {boxId},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end

            -- 显示双倍图飘窗
            if data.Value.NextIsDouble then
                self:createDoubleFlash()
            else
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            end

            self:refreshData(data)

            self:refreshUI()

            -- 播放特效
            ui.newEffect({
                parent = self.mBoxParent,
                position = cc.p(boxPos.x, boxPos.y+50),
                effectName = "effect_ui_zhenyuanchuxian_cheng",
                animation = "animation",
                loop = false,
            })
        end
    })
end

--请求放入箱子
function ActivityDragonTreasureLayer:requestPutBox()
    HttpClient:request({
        moduleName = "TimedGoldenDragonTreasure", 
        methodName = "PutInReward",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end

            self:refreshData(data)

            self:refreshUI()
        end
    })
end

return ActivityDragonTreasureLayer