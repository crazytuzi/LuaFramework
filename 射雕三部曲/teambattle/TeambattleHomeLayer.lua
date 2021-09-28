
--[[
    文件名：TeambattleHomeLayer.lua
    描述：   西漠 主界面
    创建人：  wusonglin
    创建时间：2016.7.18
-- ]]

local TeambattleHomeLayer = class("TeambattleHomeLayer", function(params)
    return display.newLayer()
end)

-- 图片大小不规则，初始化图片装饰物的坐标
-- 根据图片配置表id
local btnPoints = {
    [11] = cc.p(160,190),
    [12] = cc.p(135,185),
    [13] = cc.p(140,160),
    [14] = cc.p(165,150),
    [15] = cc.p(140,157),
    [16] = cc.p(160,125),
}

--[[
params:
    isInTeam  是否组队进入
    isGotoShop  是否进入商店，优先级在组队进入之后
    nodeId    节点ID，必须和是否组队同时传入
]]
function TeambattleHomeLayer:ctor(params)
    -- 处理参数
    param = param or {}
    self.mIsShowNode = param.isShowNode
    self.mIsGotoShop = param.isGotoShop
    self.mNodeId     = param.nodeId

    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 界面背景
    self.mBgSprite = ui.newSprite("jsxy_29.jpg")
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)

    --朱雀门
    self.zhuqueBtn = ui.newButton({
        normalImage = "jsxy_33.png",
        position = cc.p(187, 420),
        anchorPoint = cc.p(0.5, 0.5)
    })
    self.mParentLayer:addChild(self.zhuqueBtn)

    self.mZhuqueLayout = ui.newButton({
        normalImage = "c_83.png",
        position = cc.p(187, 420),
        anchorPoint = cc.p(0.5, 0),
        size = cc.size(100, 100)
    })
    self.mParentLayer:addChild(self.mZhuqueLayout)

    --青龙门
    self.qinglongBtn = ui.newButton({
        normalImage = "jsxy_34.png",
        position = cc.p(468, 405),
        anchorPoint = cc.p(0.5, 0.5)
    })
    self.mParentLayer:addChild(self.qinglongBtn)

    self.mQinglongLayout = ui.newButton({
        normalImage = "c_83.png",
        position = cc.p(468, 405),
        anchorPoint = cc.p(0.5, 0),
        size = cc.size(100, 100)
    })
    self.mParentLayer:addChild(self.mQinglongLayout)


    --白虎门
    self.baihuBtn = ui.newButton({
        normalImage = "jsxy_35.png",
        position = cc.p(492, 259),
        anchorPoint = cc.p(0.5, 0.5)
    })
    self.mParentLayer:addChild(self.baihuBtn)

    self.mBaihuLayout = ui.newButton({
        normalImage = "c_83.png",
        position = cc.p(492, 259),
        anchorPoint = cc.p(0.5, 0),
        size = cc.size(100, 100)
    })
    self.mParentLayer:addChild(self.mBaihuLayout)
    --玄武门
    self.xuanwuBtn = ui.newButton({
        normalImage = "jsxy_36.png",
        position = cc.p(174, 266),
        anchorPoint = cc.p(0.5, 0.5)
    })
    self.mParentLayer:addChild(self.xuanwuBtn)

    self.mXuanwuLayout = ui.newButton({
        normalImage = "c_83.png",
        position = cc.p(174, 266),
        anchorPoint = cc.p(0.5, 0),
        size = cc.size(100, 100)
    })
    self.mParentLayer:addChild(self.mXuanwuLayout)

    --鞑子先锋
    self.xianfengBtn = ui.newButton({
        normalImage = "jsxy_32.png",
        position = cc.p(140, 682),
        anchorPoint = cc.p(0.5, 0.5)
    })
    self.mParentLayer:addChild(self.xianfengBtn)

    self.mXianfengLayout = ui.newButton({
        normalImage = "c_83.png",
        position = cc.p(140, 682),
        anchorPoint = cc.p(0.5, 0),
        size = cc.size(100, 100)
    })
    self.mParentLayer:addChild(self.mXianfengLayout)

    --鞑子大营
    self.dayingBtn = ui.newButton({
        normalImage = "jsxy_30.png",
        position = cc.p(455, 827),
        anchorPoint = cc.p(0.5, 0.5)
    })
    self.mParentLayer:addChild(self.dayingBtn)

    self.mDayingLayout = ui.newButton({
        normalImage = "c_83.png",
        position = cc.p(455, 827),
        anchorPoint = cc.p(0.5, 0),
        size = cc.size(100, 100)
    })
    self.mParentLayer:addChild(self.mDayingLayout)


    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            {
                resourceTypeSub = ResourcetypeSub.eFunctionProps,
                modelId = 16050023
            },
            ResourcetypeSub.eGold,
            ResourcetypeSub.eDiamond
        },
        currentLayerType = Enums.MainNav.ePractice,
    })
    self:addChild(tempLayer)

    -- 玩家的领地信息
    self.mCrusadeInfo = {}
    -- 好友的领地信息
    self.mFriendCrusadeInfo = nil
    -- 计时器容器
    self.mScheduleFuncVec = {}
    -- 领取按钮
    self.mBtnDrawReward = {}
    --全服邀请状态
    self.mInviteState = false

    self:initUI()

    -- 内容按钮
    self:initContent(true)

    -- 注册进入退出事件
    self:registerScriptHandler(function(event)
        if "enter" == event then
            -- todo
        elseif "exit" == event then
            -- todo
        elseif "enterTransitionFinish" == event then
            -- todo
            self:enterTransitionFinish()
        elseif "exitTransitionStart" == event then
            -- Todo
            self:exitTransitionStart()
        elseif "cleanup" == event then

        end
    end)
end

-- 初始化UI
function TeambattleHomeLayer:initUI()
    -- 内功心法兑换按钮
    local exchangeImage = ui.newButton({
        normalImage = "jsxy_43.png",
        clickAction = function ()
            LayerManager.addLayer({
                name ="teambattle.TeambattleShop",
                data = {crusadeInfo = self.mCrusadeInfo},
                cleanUp = true,
            })
        end
    })
    exchangeImage:setPosition(cc.p(70, 1027))
    self.mParentLayer:addChild(exchangeImage)
    -- 保存按钮，引导使用
    self.exchangeImage = exchangeImage

    --全服邀请按钮
    self.mInviteBtn = nil
    local serverInviteBtn = ui.newButton({
        normalImage = "",
        clickAction = function(pSender, eventType)
            self:showInviteTips()--显示邀请提示
        end
    })
    serverInviteBtn:setPosition(cc.p(70, 927))
    self.mParentLayer:addChild(serverInviteBtn)
    self.mInviteBtn = serverInviteBtn

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0, 1),
        position = cc.p(640 * 0.865 + 5, 1080),
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(closeBtn)
end

--显示邀请提示
function TeambattleHomeLayer:showInviteTips()
    --选择描述
    local describe = self.mInviteState and
        TR("关闭以后，只能接受到好友和帮派的邀请，无法接受到全服玩家的邀请，是否关闭") or
        TR("开启以后，可以接受全服玩家邀请,是否开启")
    --显示提示确认弹窗
    self.mMsgbox = MsgBoxLayer.addOKLayer(
        describe,
        TR("提示"),
        {{
            text = TR("确定"),
            clickAction = function ()
                LayerManager.removeLayer(self.mMsgbox)
                self:requestUpdateAllInviteFlag() --是否开启全服邀请 请求服务器
            end
        },
        {
            text = TR("取消"),
            clickAction = function ()
                LayerManager.removeLayer(self.mMsgbox)
            end
        }},
        {}
    )
end

-- 内容按钮
function TeambattleHomeLayer:initContent(isFirstComing)
    self.mBgSprite:removeAllChildren()
    -- 从上倒下 ui
    self.count = 0
    --具体特效位置偏移
    local effectOffset = {
        [1] = cc.p(3, 0),
        [2] = cc.p(6, 5),
        [3] = cc.p(-7, -10),
        [4] = cc.p(-10, -25),
        [5] = cc.p(5, 0),
        [6] = cc.p(5, 0),
    }

    self.nodeInfo = {
        [1] = {
            ID = 11,
            btn = self.baihuBtn,
            actMation = "jianzhu1",
            noadeNameImage = "jsxy_12.png",
            namePos = cc.p(380, 280),
            countDownPos = cc.p(490, 340),
            x = 10,
            y = -5,
            layout = self.mBaihuLayout,
        },
        [2] = {
            ID = 12,
            btn = self.xuanwuBtn,
            actMation = "jianzhu2",
            noadeNameImage = "jsxy_14.png",
            namePos = cc.p(275, 275),
            countDownPos = cc.p(180, 345),
            x = -10,
            y = 5,
            layout = self.mXuanwuLayout,
        },
        [3] = {
            ID = 13,
            btn = self.qinglongBtn,
            actMation = "jianzhu3",
            noadeNameImage = "jsxy_13.png",
            namePos = cc.p(370, 445),
            countDownPos = cc.p(460, 520),
            x = -15,
            y = -5,
            layout = self.mQinglongLayout,
        },
        [4] = {
            ID = 14,
            btn = self.zhuqueBtn,
            actMation = "jianzhu4",
            noadeNameImage = "jsxy_15.png",
            namePos = cc.p(90, 425),
            countDownPos = cc.p(186, 505),
            x = 10,
            y = -5,
            layout = self.mZhuqueLayout,
        },
        [5] = {
            ID = 15,
            btn = self.xianfengBtn,
            actMation = "jianzhu5",
            noadeNameImage = "jsxy_11.png",
            namePos = cc.p(40, 730),
            countDownPos = cc.p(140, 790),
            x = 0,
            y = 0,
            layout = self.mXianfengLayout,
        },
        [6] = {
            ID = 16,
            btn = self.dayingBtn,
            actMation = "jianzhu6",
            noadeNameImage = "jsxy_10.png",
            namePos = cc.p(560, 895),
            countDownPos = cc.p(445, 975),
            x = 0,
            y = 0,
            layout = self.mDayingLayout,
        },
    }
    for i = 1,#self.nodeInfo do
        local actMation = self.nodeInfo[i].actMation
        local pos = self.nodeInfo[i].pos
        -- 创建按钮
        local tempBtn = self.nodeInfo[i].btn
        local btSize = tempBtn:getContentSize()

        local layout = self.nodeInfo[i].layout

        --创建节点名字的图片
        local nameSprite = ui.newSprite(self.nodeInfo[i].noadeNameImage)
        nameSprite:setPosition(self.nodeInfo[i].namePos)
        self.mParentLayer:addChild(nameSprite)


        self.mNodeBtVec = self.mNodeBtVec or {}
        self.mLayoutVec = self.mLayoutVec or {}
        self.mNodeModelData = self.mNodeModelData or {}
        self.mNodeBtVec[i] = tempBtn
        self.mLayoutVec[i] = layout
        tempBtn:setTag(self.nodeInfo[i].ID)
        self.mNodeModelData[i] = self.nodeInfo[i]
        self.count = self.count + 1

        --特效创建及其位置
        local btnTag = tempBtn:getTag()
        local tempX = self.nodeInfo[btnTag - 10].x
        local tempY = self.nodeInfo[btnTag - 10].y


        local animationName = ""
        local effectPos = {}
        if btnTag <= 14 then
            animationName = "huo"
            effectPos = cc.p(btSize.width / 2 + tempX, btSize.height / 2 + tempY)
        else
            animationName = "yan"
            effectPos = cc.p(btSize.width / 2 + 100, btSize.height + 50)
        end

        ui.newEffect({
            parent = tempBtn,
            effectName = "effect_ui_jsxy",
            animation = animationName,
            position = effectPos,
            loop = true,
            endRelease = true,
        })

    end

    -- 将每个节点的下标转化为1开始
    self.mBattleNode = {}
    for k, v in pairs(self.mNodeModelData) do
        table.insert(self.mBattleNode, v)
    end

    --获取玩家的领地信息
    self:requestCrusadeInfo(isFirstComing)
end

-- 刷新页面
--[[
    params:
        data: 传入的数据
--]]
function TeambattleHomeLayer:refreshLayer(data)
    -- 关闭定时器
    self:exitTransitionStart()

    -- 重新获取数据加载页面
    self:initContent(false)

    -- 如果有倒计时重新开始计时
    self:enterTransitionFinish()
end

-- 完成数据请求后的操作
function TeambattleHomeLayer:afterPlayerTerritoryInit()
    local nodeInfoCount = 0
    for k,v in pairs(self.mNodeModelData) do
        nodeInfoCount = nodeInfoCount + 1
        --找到节点的info（已经挑战过了之后才会有数据）
        local info = nil
        for i = 1, 6 do
            if self.mCrusadeInfo[i] ~= nil then
                if info == nil then
                    for m, n in ipairs(self.mCrusadeInfo[i]) do
                        if v.ID == TeambattleNodeModel.items[n.NodeModelID].chapterModelID then
                           info = clone(self.mCrusadeInfo[i])
                           break
                        end
                    end
                else
                    break
                end
            end
        end
        -- 节点状态
        self:crusadeNodeState(self.mNodeBtVec[k], self.mLayoutVec[k], v,info)
        -- 响应函数
        self.mNodeBtVec[k]:setClickAction(function ()
            if self.mNodeBtVec[k].isOpen == false then
                ui.showFlashView({text = TR("未通关上一据点")})
                return
            end
            self:crusadeNodeClick(v, info)
        end)

        self.mLayoutVec[k]:setClickAction(function()
            if self.mLayoutVec[k].isOpen == false then
                ui.showFlashView({text = TR("未通关上一据点")})
                return
            end
            self:crusadeNodeClick(v, info)
        end)

        if info ~= nil then
            -- 当有该节点的挑战信息的时候并且需要显示镇守倒计时
            for i, v in ipairs(info) do
                -- 不需要显示镇守倒计时就直接return
                if v.TodayIsHolding == false and v.HoldEndTime <= Player:getCurrentTime() then
                    break
                end

                --显示倒计时
                local pos = nil
                if self.nodeInfo[nodeInfoCount].ID == TeambattleNodeModel.items[v.NodeModelID].chapterModelID then
                    pos = self.nodeInfo[nodeInfoCount].countDownPos
                end


                local size = ui.getImageSize("jsxy_17.png")
                local labelBg = ui.newScale9Sprite("jsxy_17.png",cc.size(size.width + 5, size.height))
                labelBg:setPosition(pos)
                self.mParentLayer:addChild(labelBg)

                local zhenshouLabel = ui.newLabel({
                    text = TR("镇守中"),
                    size = 20,
                    color = Enums.Color.eNormalWhite,
                    outlineColor = cc.c3b(0x0b, 0x29, 0x0b),
                    outlineSize = 2,
                })
                zhenshouLabel:setAnchorPoint(cc.p(0.5, 1))
                zhenshouLabel:setPosition(labelBg:getContentSize().width / 2, labelBg:getContentSize().height - 7)
                labelBg:addChild(zhenshouLabel)

                local label = ui.newLabel({
                    text = "",
                    size = 20,
                    color = Enums.Color.eNormalWhite,
                    outlineColor = cc.c3b(0x0b, 0x29, 0x0b),
                    outlineSize = 2,
                })
                label:setAnchorPoint(cc.p(0.5, 0))
                local offset = {}
                label:setPosition(labelBg:getContentSize().width / 2, 7)
                labelBg:addChild(label)


                local endTimeStamp = v.HoldEndTime
                local timeStart = v.HoldStartTime or 0

                local timeLeft = endTimeStamp - Player:getCurrentTime()
                -- 倒计时函数
                table.insert(self.mScheduleFuncVec,function(deltaTime)
                    if timeLeft - deltaTime <= 0 then
                        self:refreshLayer()
                        return
                    end
                    timeLeft = timeLeft - deltaTime
                    label:setString(MqTime.formatAsDay(timeLeft))
                end)

                -- -- 显示加速按钮
                -- 加速消耗 (单位时间消耗 * (最大镇守时间 - (当前时间 - 镇守开始时间)))
                local jiaSuXiaoHao = TeambattleConfig.items[1].holdTimeOver * (math.ceil(((TeambattleConfig.items[1].maxHoldTime) - (Player:getCurrentTime() - timeStart))/3600)) or 0

                local jiaSuBtn = ui.newButton({
                    normalImage = "jsxy_16.png",
                    position = cc.p(580, 160),
                    clickAction = function()
                        print(MqTime.formatAsDay(timeLeft))
                        MsgBoxLayer.addOKLayer(
                            TR("剩余时间：%s  是否花费%s%s宝石%s直接镇守完毕并获得全额奖励",
                                MqTime.formatAsDay(timeLeft),
                                Enums.Color.eNormalGreenH, jiaSuXiaoHao, Enums.Color.eNormalWhiteH
                            ),
                            TR("提示"),
                            {
                                {
                                    text = TR("确定"),
                                    clickAction = function (layerObj, btnObj)
                                        if Utility.isResourceEnough(ResourcetypeSub.eDiamond, jiaSuXiaoHao) then

                                            HttpClient:request({
                                            moduleName = "TeambattleHoldinfo",
                                            methodName = "QuickDrawHoldReward",
                                            svrMethodData = {v.NodeModelID},
                                            callback = function(data)
                                                -- 判断返回数据
                                                if data.Status ~= 0 then
                                                    return
                                                end
                                                local dataInfo = data.Value
                                                layerObj:removeFromParent()
                                                ui.ShowRewardGoods(dataInfo.BaseGetGameResourceList)
                                                -- 刷新
                                                LayerManager.addLayer({
                                                    cleanUp = true,
                                                    name ="teambattle.TeambattleHomeLayer",
                                                })
                                            end,
                                            })
                                        end
                                    end
                                },
                                {
                                    text = TR("取消"),
                                },
                            }
                        )
                    end
                })
                self.mBgSprite:addChild(jiaSuBtn)

                self.mScheduleFuncVec[#self.mScheduleFuncVec](0)
                break
            end
        end
    end
end

--计时
function TeambattleHomeLayer:enterTransitionFinish( ... )
    local lastTimeTick = os.time()
    -- body
    self.id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function( ... )
        -- body
        local deltaTime = os.time() - lastTimeTick
        lastTimeTick = os.time()

        for k,v in pairs(self.mScheduleFuncVec) do
            v(deltaTime)
        end
    end,1,false)
end

function TeambattleHomeLayer:exitTransitionStart( ... )
    -- body
    self.mScheduleFuncVec = {}
    self:stopAllActions()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.id)
end

--为按钮添加节点状态效果
--[[
    bt  --节点按钮
    modelData  -- 节点按钮对应的初始化数据
    nodeInfo   -- 节点被挑战后的数据（有可能没有被挑战数据为nil）
]]
function TeambattleHomeLayer:crusadeNodeState(bt, layout, modelData, nodeInfo)
    -- 初始化数据
    local btSize = bt:getContentSize()
    layout.isOpen = true
    bt.isOpen = true
    -- 该节点没有被挑战时
    if nodeInfo == nil then
        layout.isOpen = false
        bt.isOpen = false
        -- 当一个节点都没有被挑战时,让第一个节点显示为可以挑战状态
        if self.mCrusadeInfo[1] == nil and modelData.ID == self.mBattleNode[1].ID then
            --展示刀叉PK动画
            ui.newEffect({
                parent = bt,
                effectName = "effect_ui_jiaochadao",
                position = cc.p(btSize.width / 2, btSize.height + 300),
                loop = true,
                endRelease = true,
            })
        end

        return  -- 没有挑战就在这儿返回
    end

    -- 可以领取首通奖励时的节点集合
    local isFirstReward = {}
    for i, v in ipairs(nodeInfo) do
        -- 是否可以领取首通奖励
        if v.IsCanDrawFirstReward == true then
            table.insert(isFirstReward, v.NodeModelID)
        end
    end

    -- 是否可以领取镇守奖励
    local holdRewardIsCanDraw = false
    for i, v in ipairs(nodeInfo) do
        if v.HoldRewardIsCanDraw == true then
            holdRewardIsCanDraw = true
            break
        end
    end

    -- 可以领取镇守奖励
    if holdRewardIsCanDraw == true then
        -- local rewardBox = ui.newEffect({
        --         parent = bt,
        --         effectName = "effect_jipingbaoxiang",
        --         scale = 0.2,
        --         position = cc.p(btSize.width / 2, btSize.height / 2),
        --         loop = true,
        --         endRelease = true,
        --     })
        -- rewardBox:setAnimation(0, "kaiqi", true)
    else
        -- 判断是否可以看战报
        local isFight = false
        for i, v in ipairs(nodeInfo) do
            if v.IsFight == true then
                isFight = true
                break
            end
        end
        -- 可以看战报
        if isFight == true then
            local effect = ui.createLabelWithBg({
                bgFilename = "c_54.png",
                bgSize = cc.size(200, 30),
                labelStr = TR("点击继续讨伐"),
                color = Enums.Color.eLightYellow,
                alignType = ui.TEXT_ALIGN_CENTER
            })
            effect:setPosition(cc.p(btSize.width / 2, btSize.height / 2))
            bt:addChild(effect)
        else
            -- 判断今日是否已经成功挑战该节点
            local todayIsSuccess = false
            for i, v in ipairs(nodeInfo) do
                if v.TodayIsSuccess == true then
                    todayIsSuccess = true
                    break
                end
            end
            if todayIsSuccess == false then
                ui.newEffect({
                    parent = bt,
                    effectName = "effect_ui_jiaochadao",
                    position = cc.p(btSize.width / 2, btSize.height + 35),
                    loop = true,
                    endRelease = true,
                })
            else
                -- local todayIsHolding = false  -- 判断该节点是否在镇守中
                -- local todayIsHolded = false  -- 判断该节点是否镇守完毕
                -- for i, v in ipairs(nodeInfo) do
                --     if v.TodayIsHolding == true then
                --         todayIsHolding = true
                --     end
                --     if v.TodayIsHolded == true then
                --         todayIsHolded = true
                --     end
                -- end
                --
                -- if todayIsHolded == false and todayIsHolding == true then
                --     bt:removeAllChildren(true)
                -- end
                bt:removeAllChildren(true)

                -- 该节点是否在镇守中
                if todayIsHolded == false and todayIsHolding == false then
                    -- bt:removeAllChildren(true)
                    -- local effect = cc.Sprite:create("jsxy_19.png")
                    -- effect:setPosition(cc.p(btSize.width / 2, btSize.height / 2 - 10))
                    -- bt:addChild(effect)
                    -- local actionBig = cc.ScaleTo:create(1.1, 1.5)
                    -- local actionSmall = cc.ScaleTo:create(1.5, 1.1)
                    -- local actionSleep = cc.DelayTime:create(0.2)
                    -- effect:runAction(cc.RepeatForever:create(cc.Sequence:create(actionBig, actionSmall, actionSleep)))
                end

                if todayIsHolded == true and todayIsHolding == false then
                    -- local effect = ui.createLabelWithBg({
                    --     bgFilename = "jsxy_04.png",
                    --     bgSize = cc.size(200, 30),
                    --     labelStr = TR("今日镇守已完成"),
                    --     color = Enums.Color.eLightYellow,
                    --     alignType = ui.TEXT_ALIGN_CENTER
                    -- })
                    -- effect:setPosition(cc.p(btSize.width / 2, btSize.height / 2))
                    -- bt:addChild(effect)
                end
            end
        end
    end

    local FirstTempX = 0
    if btnTag == 16 then
        FirstTempX = 80
    end
    -- 是否可以领取首通奖励
    if #isFirstReward > 0 then

        local boxEffect = ui.newEffect({
            parent = bt,
            effectName = "effect_hualibaoxiang",
            scale = 0.2,
            position = cc.p(btSize.width / 2 + FirstTempX, btSize.height / 2),
            loop = true,
            endRelease = true,
            --startListener  --动作开始回调
            --endListener    --动作结束回调
            completeListener = function(boxEffect)
                boxEffect:removeFromParent(true)
            end--动作完成回调
        })
        boxEffect:setName("boxEffect")
        boxEffect:setAnimation(0, "kaiqi", true)


        local rewardBtn = ui.newButton({
            normalImage = "c_83.png",
            text = TR("首通奖励"),
            size = cc.size(140, 140),
            titlePosRateY = 0.1,
            clickAction = function(pSender)
                boxEffect:setAnimation(0, "kaiqi", false)
                self:requestGetReward(isFirstReward, modelData.ID)
                local yanhua = ui.newEffect({
                    parent = bt,
                    effectName = "effect_ui_xiangzitexiao",
                    animation = "kaiqi",
                    scale = 0.2,
                    position = cc.p(btSize.width / 2 + FirstTempX, btSize.height / 2+30),
                    loop = false,
                    endRelease = true,
                    --startListener  --动作开始回调
                    --endListener    --动作结束回调
                    completeListener = function(boxEffect)
                        bt:removeChildByName("boxEffect")
                        bt:removeChildByName("yanhua")
                    end--动作完成回调
                })
                boxEffect:setName("yanhua")

            end,
        })
        rewardBtn:setAnchorPoint(cc.p(0.5, 0.5))
        rewardBtn:setPosition(cc.p(btSize.width / 2 + FirstTempX, btSize.height / 2 + 10))
        bt:addChild(rewardBtn)

        -- 宝箱抖动效果
        --ui.setWaveAnimation(rewardBtn)
        self.mBtnDrawReward[modelData.ID] = rewardBtn
    end
end

--改变全服邀请状态
--[[
    param:
        bool: boolean true = 设置开启 false = 不开启
--]]
function TeambattleHomeLayer:setInviteState(bool)
    --改变状态
    self.mInviteState = bool
    --设置按钮图片
    self.mInviteBtn:loadTextureNormal(self.mInviteState and "tb_31.png" or "tb_30.png")
    self.mInviteBtn:loadTexturePressed(nil)
end

--节点按钮点击响应,玩家的领地
--[[
params:
    bt: 节点
    modelData: 模型数据
    nodeInfo: 服务器获取的节点信息
]]--
function TeambattleHomeLayer:crusadeNodeClick(modelData, nodeInfo)
    --[[--------新手引导, 因为2个按钮都会触发，所以11903不能在GuideConfig里面添加--------]]--
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 11903 then
        Guide.manager:nextStep(eventID)
    end
    --已开启的
    if self.mFight == nil then
        if nodeInfo == nil then
            if (self.mCrusadeInfo[1] == nil and modelData.ID == self.mBattleNode[1].ID) or
                (#self.mCrusadeInfo + 1 <= 6 and modelData.ID == self.mBattleNode[#self.mCrusadeInfo + 1].ID) then
                -- 进入选入难度页面
                LayerManager.addLayer({
                    name ="teambattle.TeambattleBossLayer",
                    data = {
                        chapterModelID = modelData.ID,
                        crusadeInfo = self.mCrusadeInfo,
                    },
                    cleanUp = false,
                })
            end
        else
            local TodayIsSuccess = false
            local TodayIsHolding = false
            local HoldRewardIsCanDraw = false
            local TodayIsHolded = false
            local TodayIsSuccessId = 0
            local HoldRewardIsCanDrawId = 0
            local cofigData = {}   -- 节点配置

            for k, v in ipairs(nodeInfo) do
                if v.TodayIsSuccess == true then
                    TodayIsSuccess = true
                    TodayIsSuccessId = v.NodeModelID
                end
                if v.TodayIsHolding == true then
                    TodayIsHolding = true
                    TodayIsHoldingId = v.NodeModelID
                end
                if v.HoldRewardIsCanDraw == true then
                    HoldRewardIsCanDraw = true
                    HoldRewardIsCanDrawId = v.NodeModelID
                end
                if v.TodayIsHolded == true then
                    TodayIsHolded = true
                end
            end

            if TodayIsSuccessId ~= 0 or HoldRewardIsCanDrawId ~= 0 then
                if TodayIsSuccessId ~= 0 then
                    cofigData = TeambattleNodeModel.items[TodayIsSuccessId]
                end

                if HoldRewardIsCanDrawId ~= 0 then
                    cofigData = TeambattleNodeModel.items[HoldRewardIsCanDrawId]
                end

                if TodayIsHolding then
                    cofigData = TeambattleNodeModel.items[TodayIsHoldingId]
                end
            end

            if HoldRewardIsCanDraw then
                -- LayerManager.addLayer({
                --     -- 领取镇守奖励
                --     name ="teambattle.TeambattleOutPutViewLayer",
                --     cleanUp = true,
                --     data = {
                --         config = cofigData,
                --         info = nodeInfo,
                --         callBack = function()
                --             --self:refreshLayer()
                --             LayerManager.addLayer({
                --                 name ="teambattle.TeambattleHomeLayer",
                --             })
                --         end
                --     },
                -- })
            else
                if TodayIsSuccess == false then  -- 该节点没有挑战成功
                        -- 进入选入难度页面
                        LayerManager.addLayer({
                        name ="teambattle.TeambattleBossLayer",
                        data = {
                            chapterModelID = modelData.ID,
                            crusadeInfo = self.mCrusadeInfo,
                        },
                        cleanUp = false,
                    })
                else
                    -- 该节点是否在镇守中
                    if TodayIsHolding then
                        -- LayerManager.addLayer({
                        --     name ="teambattle.TeambattleOutPutViewLayer",
                        --     data = {
                        --         config = cofigData,
                        --         info = nodeInfo,
                        --         callBack = function()
                        --             self:refreshLayer()
                        --         end
                        --     },
                        --     cleanUp = false,
                        -- })
                    else
                        if TodayIsHolded then
                            --ui.showFlashView({text = TR("今日已镇守完毕,请等待0点刷新"),})
                        else
                            -- 西漠添加镇守人物界面
                            -- LayerManager.addLayer({
                            --     name ="teambattle.TeambattleManorLayer",
                            --     data = {
                            --         config = cofigData,
                            --         info = nodeInfo,
                            --         callBack = function()
                            --             self:refreshLayer()
                            --         end,
                            --         banList = self.mCrusadeInfo.NodeModelID
                            --     },
                            --     cleanUp = false,
                            -- })
                        end
                    end
                end
            end
        end
    else
        if #nodeInfo > 0 then
            local needFight = false
            for i, v in ipairs(nodeInfo) do
                if v.NodeModelID == self.mFight then
                    needFight = true
                    break
                end
            end

            local fightSkep = false                          -- 战斗可否跳过
            if self.mCrusadeInfo ~= nil and next(self.mCrusadeInfo)then
                for k, info in ipairs(self.mCrusadeInfo) do
                    if next(info) then
                        for _, v in ipairs(info) do
                            if v.NodeModelID == self.mFight and v.SuccessFightCount > 0 then
                                fightSkep = true
                            end
                        end
                    end
                end
            end

            if needFight == true then
                self:ToMakeTeamLayer(nil)
            else
                ui.showFlashView({text = TR("你的组队副本已开始，可点击查看战斗结果"),})
            end
        else
            ui.showFlashView({text = TR("你的组队副本已开始，可点击查看战斗结果"),})
        end
    end
end


----[[---------------网络请求---------------]]--------
-- 获取信息接口
function TeambattleHomeLayer:requestCrusadeInfo(isFirstComing)
    HttpClient:request({
        moduleName = "TeambattleFightinfo",
        methodName = "GetInfo",
        needWait = isFirstComing,
        svrMethodData = {},
        callback = function(data)
            -- 判断返回数据
            if data.Status ~= 0 then
                return
            end

            local dataInfo = data.Value
            --dump(dataInfo, "返回的六道天伦数据为:")

            -- 已战斗需要看战报时的章节节点ID
            self.mFight = nil
            -- 已经挑战过的当前六个节点的信息(有可能一个都还没有挑战)
            self.mCrusadeInfo = {}
            -- 镇守的主将id集合
            self.mCrusadeInfo.NodeModelID = dataInfo.NodeModelID or {}

            -- 已挑战过的节点集合不为空时
            local teambattleFightinfo = dataInfo.TeambattleFightinfo or {}
            if #teambattleFightinfo ~= 0 then
                -- 返回的节点信息是否为当前显示的六个节点的信息
                for i=1, 6 do
                    for m, n in ipairs(teambattleFightinfo) do
                        if TeambattleNodeModel.items[n.NodeModelID].chapterModelID == self.mBattleNode[i].ID then
                            if self.mCrusadeInfo[i] == nil then
                                self.mCrusadeInfo[i] = {}
                            end
                            table.insert(self.mCrusadeInfo[i], n)
                        end
                    end
                end

                -- 是否有已战斗的章节需要看战报
                for i, v in pairs(teambattleFightinfo) do
                    if v.IsFight == true then
                        self.mFight = v.NodeModelID
                        break
                    end
                end
                -- 如果不需要看战报 判断是否进入了队伍
                local isInTeam, nodeModelId = false, nil
                if self.mFight == nil then
                    for i, v in ipairs(teambattleFightinfo) do
                        if v.IsInTeam == true then
                            isInTeam = true
                            nodeModelId = v.NodeModelID
                            break
                        end
                    end
                end
                -- 判断是否直接进入组队页面
                if isInTeam == true then
                    self:ToMakeTeamLayer(nodeModelId)
                elseif self.mIsGotoShop then  -- 是否直接进入商店
                    -- 进入商店
                    LayerManager.addLayer({
                      name ="teambattle.TeambattleShop",
                      data = {crusadeInfo = self.mCrusadeInfo},
                      cleanUp = false,
                    })
                end
            end
            -- 设置全服邀请的图标状态
            self:setInviteState(dataInfo.IsAllInviteFlg)

            --完成数据请求后的操作
            self:afterPlayerTerritoryInit()

            -- 新手引导
            self:executeGuide()
        end,
    })
end

-- 直接进入组队页面或者战斗页面
function TeambattleHomeLayer:ToMakeTeamLayer(nodeModelId)
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "GetMyTeamInfo",
        svrMethodData = {},
        callback = function(data)
            -- 判断返回数据
            if data.Status ~= 0 then
                return
            end
            local dataInfo = data.Value
            if dataInfo then
                if dataInfo.IsInTeam and dataInfo.FightInfo == nil then
                    -- showFlashText(TR("队伍已经被解散"))
                elseif dataInfo.TeamsInfo ~= nil then
                    --[[--------新手引导, 已经在队伍中, 指向后面的步骤--------]]--
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 11903 then
                        Guide.manager:nextStep(eventID)
                        Guide.manager:nextStep(1190301)
                    end

                    LayerManager.addLayer({
                        name = "teambattle.TeambattleMakeTeamLayer",
                        data = {
                            teamInfo = dataInfo.TeamsInfo,
                            nodeId = nodeModelId,
                            crusadeInfo = self.mCrusadeInfo,
                            totalMan = #dataInfo.TeamsInfo,
                        },
                        cleanUp = false,
                    })
                elseif dataInfo.FightInfo ~= nil then
                    -- 加入战斗
                    local control = Utility.getBattleControl(ModuleSub.eTeambattle, fightSkep)
                    LayerManager.addLayer({
                        name = "ComBattle.BattleLayer",
                        data = {
                            data = dataInfo.FightInfo,
                            skip = control.skip,
                            trustee = control.trustee,
                            skill = control.skill,
                            map = Utility.getBattleBgFile(ModuleSub.eTeambattle),
                            callback = function(result)
                                PvpResult.showPvpResultLayer(ModuleSub.eTeambattle, dataInfo)

                                if control.trustee and control.trustee.changeTrusteeState then
                                    control.trustee.changeTrusteeState(result.trustee)
                                end
                            end
                        },
                    })
                end
            end
        end,
    })
end

-- 领取首通奖励
--[[
params:
    nodeID: 节点ID
]]--
function TeambattleHomeLayer:requestGetReward(nodeId, btnCount, boxEffect)
    --处理nodeId 为字符串1
    local str = ""
     for k, v in ipairs(nodeId) do
        str = str .. v
        if nodeId[k + 1] then
            str = str .. ","
        end
     end

     HttpClient:request({
        moduleName = "TeambattleFightinfo",
        methodName = "DrawFirstReward",
        svrMethodData = {str},
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            local dataInfo = data.Value
            MqAudio.playEffect("sound_kaibaoxiang.mp3")
            -- 兑换成功，获得以下物品
            ui.ShowRewardGoods(dataInfo.BaseGetGameResourceList)

            self.mBtnDrawReward[btnCount]:removeFromParent(true)
        end,
    })
end

-- 开启或关闭全服邀请
--[[
    isOpen: 开启或关闭
]] --
function TeambattleHomeLayer:requestUpdateAllInviteFlag()
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "UpdateAllInviteFlag",
        svrMethodData = {not self.mInviteState},
        callback = function(response)
            if not response or response.Status ~= 0 then return end
            --显示提示
            local describe = self.mInviteState and TR("全服邀请已关闭") or TR("全服邀请已开启")
            ui.showFlashView({text = describe})
            self:setInviteState(not self.mInviteState)
        end,
    })
end


----[[---------------------新手引导---------------------]]--
-- 执行新手引导
function TeambattleHomeLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    local isSucessed = false
    for _,nodes in ipairs(self.mCrusadeInfo) do
        for _,node in pairs(nodes) do
            if node.NodeModelID == 1111 then
                isSucessed = node.TodayIsSuccess
                break
            end
        end
    end
    if eventID == 11903 and isSucessed then
        -- 白虎门已打过，退出引导
        Guide.helper:guideError(eventID, -1)
        return
    end 
    Guide.helper:executeGuide({
        -- 白虎城门
        [11903] = {clickNode = self.baihuBtn},
        -- 兑换商店
        [11903041] = {clickNode = self.exchangeImage}
    })
end

return TeambattleHomeLayer
