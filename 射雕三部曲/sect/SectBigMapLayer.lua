--[[
    文件名: SectBigMapLayer.lua
    描述: 八大门派大地图界面
    创建人: lengjiazhi
    创建时间: 2017.08.24
-- ]]
local SectBigMapLayer = class("SectBigMapLayer", function(params)
	return display.newLayer()
end)

--[[
    --恢复页面数据
    	scrollPos: 滚动位置
    	heroPos : 人物位置
        searchingId: 追踪任务id
--]]

function SectBigMapLayer:ctor(params)

    self.mSectInfo = SectObj:getPlayerSectInfo()
    self.curViewPosition = params.scrollPos
    self.mHeroPos = params.heroPos
    self.mCurSearchingID = params.searchingId
    self.mNpcNodeList = {}
    self.mNpcSprtieList = {}
    self.mAllTasks = {}
    self.mIsShowSearching = true
    self.mTaskIng = false
    self.mIsHaveBoss = false

	--父节点标准层
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1050),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn, 1)

    local fileName = SectModel.items[self.mSectInfo.SectId].mapFile
    self.mAstarWorld = require("common.AStar").new({"sect."..fileName})

	self:createMap()
	self:setTouchEvent()
    
    self:handletask()
    self:CheckBossRedDot()

    self:createNPC()
	self:createbottomView()
end

--创建地图
function SectBigMapLayer:createMap()
	-- 创建可拖动背景
    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(640, 1136))
    worldView:setPosition(cc.p(0,0))
    worldView:setDirection(ccui.ScrollViewDir.both)
    worldView:setSwallowTouches(false)
    worldView:setTouchEnabled(false)
    self.mParentLayer:addChild(worldView)
    self.mWorldView = worldView

    -- 创建背景
    local bgSprite = ui.newSprite(SectModel.items[self.mSectInfo.SectId].discoveryMap..".jpg")
    bgSprite:setAnchorPoint(0, 0)
    bgSprite:setPosition(0, 0)
    self.mWorldView:setInnerContainerSize(bgSprite:getContentSize())
    self.mWorldView:addChild(bgSprite, -2)
    self.mMapBg = bgSprite

    -- 创建玩家node
    local heroPos
    if self.mHeroPos then
        heroPos = self.mHeroPos
    else
        heroPos = Utility.analysisPoints(SectModel.items[self.mSectInfo.SectId].startPoint)
    end
    self.mHeroNode = cc.Node:create()
    self.mHeroNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.mHeroNode:setContentSize(120, 180)
    self.mHeroNode:setPosition(heroPos)
    self.mMapBg:addChild(self.mHeroNode)
    -- self.mHeroNode:setLocalZOrder(ENEMY_ZORDER)
    if not self.curViewPosition then
        self.curViewPosition = cc.p((heroPos.x - 320)/14.00, (2040 - heroPos.y - 568)/10.04)
    end
    self.mWorldView:scrollToPercentBothDirection(self.curViewPosition, 0, true)


    -- local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    -- HeroQimageRelation.items[playerModelId].positivePic
    local positivePic, backPic = QFashionObj:getQFashionByDressType()
    self.playerSpine = ui.newEffect({
        parent = self.mHeroNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = positivePic,
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
        scale = 0.6
    })
    self.playerSpine:setAnimation(0, "daiji", true)
    self.playerSpine1 = ui.newEffect({
        parent = self.mHeroNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = backPic,
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
        scale = 0.6
    })
    self.playerSpine1:setVisible(false)

    -- 脚底特效
    ui.newEffect({
        parent = self.mHeroNode,
        effectName = "effect_ui_renwuguangquan_Qban",
        animation = "guangquan",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
    })
    -- 上面特效
    ui.newEffect({
        parent = self.mHeroNode,
        effectName = "effect_ui_renwuguangquan_Qban",
        animation = "guangdian",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
    })
    -- self:createBossNpc()
end

function SectBigMapLayer:onEnter()
    -- self:requestGetWorldBossBaseInfo()
end

--boss小红点检测
function SectBigMapLayer:CheckBossRedDot()
    --通过小红点改变请求boss信息
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(false)
        if ModuleInfoObj:moduleIsOpen(ModuleSub.eWorldBoss) then
            self:requestGetWorldBossBaseInfo()
        else
            self:popCheckFun()
        end 
    end
    ui.createAutoBubble({parent = self.mMapBg, eventName = RedDotInfoObj:getEvents(ModuleSub.eWorldBoss), refreshFunc = dealRedDotVisible})
end

--弹窗检测
function SectBigMapLayer:popCheckFun()
    if not next(self.mAllTasks) and not self.mIsHaveBoss then
        self:showOverPop()
    end
    self:handleChamber()
end

--处理任务数据
function SectBigMapLayer:handletask()
    self.mTaskList = SectObj:getTasksInfo()
    -- dump(self.mTaskList, "测试更新")
    local allTask = {}
    for k, v in pairs(self.mTaskList) do
        local k = tonumber(k)
        local tempModel = SectTaskWeightRelation.items[k]
        if tempModel.taskType == 1 then
            local tempTaskInfo = SectTaskBattleModel.items[k]
            tempTaskInfo.ID = k
            tempTaskInfo.needNum = tempTaskInfo.fightNum
            tempTaskInfo.curNum = v.Progress
            tempTaskInfo.taskFAP = v.FAP
            tempTaskInfo.IsStory = v.IsStory
            table.insert(allTask, tempTaskInfo)
        elseif tempModel.taskType == 2 then
            local tempTaskInfo = SectTaskCollectionModel.items[k]
            tempTaskInfo.ID = k
            tempTaskInfo.needNum = tempTaskInfo.needNum
            tempTaskInfo.curNum = v.Progress
            tempTaskInfo.IsStory = v.IsStory
            table.insert(allTask, tempTaskInfo)
        elseif tempModel.taskType == 3 then
            local tempTaskInfo = SectTaskFindModel.items[k]
            tempTaskInfo.ID = k
            tempTaskInfo.needNum = 1
            tempTaskInfo.curNum = v.Progress
            tempTaskInfo.IsStory = v.IsStory
            table.insert(allTask, tempTaskInfo)
        end
    end
    table.sort(allTask, function (a, b)
        if a.IsStory ~= b.IsStory then
            return a.IsStory
        end
        if a.ID ~= b.ID then
            return a.ID < b.ID
        end
    end)
    
    if not self.mCurSearchingID then
        self.mCurSearchingID = next(allTask) and allTask[1].ID or nil
    end
    self.mAllTasks = allTask
    self:checkTaskStatus()    
end

-- 没有任务弹窗
function SectBigMapLayer:showOverPop()
    local cangetTask = SectObj:getCanCanReceiveTask()
    if cangetTask then
        MsgBoxLayer.addOKLayer(
            TR("您还有没接受的门派任务，是否前往接受门派任务？"),
            TR("前往门派"),
            {
                {
                    normalImage = "c_33.png",
                    text = TR("稍后再说"),
                    clickAction = function(boxLayer, btnObj)
                        LayerManager.removeLayer(boxLayer)
                    end
                },
                {
                    normalImage = "c_28.png",
                    text = TR("立即前往"),
                    clickAction = function(boxLayer, btnObj)
                        LayerManager.removeLayer(boxLayer)
                        -- LayerManager.removeLayer(self)
                        LayerManager.addLayer({
                            name = "sect.SectTaskLayer",
                            data = {},
                            cleanUp = false
                            })
                    end
                },
            },
            {}
        )
    else
        MsgBoxLayer.addOKLayer(
            TR("今天的门派任务已经全部做完了哦"),
            TR("前往门派"),
            {
                {
                    normalImage = "c_28.png",
                    text = TR("确定"),
                    clickAction = function(boxLayer, btnObj)
                        LayerManager.removeLayer(boxLayer)
                    end
                },
            },
            {}
        )
    end
end

--检查任务完成状态
function SectBigMapLayer:checkTaskStatus()
    local haveFinished = false
    local finishedTask = nil
    for i,v in ipairs(self.mAllTasks) do
        if v.curNum >= v.needNum then
            haveFinished = true
            finishedTask = v
            break
        end
    end
    if haveFinished then
        Utility.performWithDelay(self, function()
            self:showFinishView(finishedTask)
        end, 0.5)
    end
end

-- -- boss
-- function SectBigMapLayer:createBossNpc()
--     local bossBtn = ui.newButton({
--         normalImage = "c_28.png",
--         text = "boss",
--         clickAction = function()
--             LayerManager.addLayer({name = "sect.SectBossLayer"})
--         end
--         })
--     bossBtn:setPosition(500, 1300)
--     self.mMapBg:addChild(bossBtn)
-- end

--获取迷宫信息
function SectBigMapLayer:handleChamber()
    self.mChamberInfo = SectObj:getChamberInfo()
    self.mChamberPosId = self.mChamberInfo.ChamberLocationId
    local endTime = self.mChamberInfo.ChamberEndTime or 0
    local curTime = Player:getCurrentTime()
    local leftTime = endTime - curTime
    local passedTime = SectConfig.items[1].chamberTime - leftTime

    if endTime == 0 then
        print("没有迷宫")
    else
        if endTime < curTime then
            print("迷宫过期")
        else
            if passedTime < 5 then
                self:createChamberPop()
            end
            self:createChamberNpc()
        end
    end
end

-- 创建迷宫NPC
function SectBigMapLayer:createChamberNpc()
    if self.mChamberNpc then
        self.mChamberNpc:removeFromParent()
        self.mChamberNpc = nil  
        self.mChamberTipSprite:removeFromParent()
        self.mChamberTipSprite = nil
    end

    local chamberPos = Utility.analysisPoints(SectMapNpcRelation.items[self.mChamberPosId].npcPoint)
    --迷宫按钮
    local chamberNpc = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(140, 140),
        clickAction = function(pSender)
            pSender:unscheduleUpdate()
            pSender:setEnabled(false)
            local tempTime = 0
            pSender:scheduleUpdate(function(dt)
                tempTime = tempTime + dt
                if tempTime > 1 then
                    pSender:setEnabled(true)
                end
                if tempTime > 20 then
                    pSender:unscheduleUpdate()
                end
                local x, y = self.mHeroNode:getPosition()
                local lenth = cc.pGetLength(cc.pSub(cc.p(x, y), chamberPos))
                if lenth <= 30 then
                    self:arrivedFun()
                    if x < chamberPos.x then
                        self.playerSpine:setRotationSkewY(0)
                       self.playerSpine1:setRotationSkewY(0)
                    else
                       self.playerSpine:setRotationSkewY(180)
                       self.playerSpine1:setRotationSkewY(180)
                    end
                    
                    pSender:unscheduleUpdate()
                    LayerManager.addLayer({
                        name = "quickExp.MeetXunbaoLayer",
                        data = {chamberInfo = self.mChamberInfo}
                    })
                end
            end)
        end
        })
    chamberNpc:setPosition(chamberPos)
    self.mMapBg:addChild(chamberNpc)
    self.mChamberNpc = chamberNpc
    --迷宫特效
    local chamberEff = ui.newEffect({
            parent = chamberNpc,
            effectName = "effect_ui_xuanwomen",
            position = cc.p(70, 70),
            loop = true,
        })

    -- 迷宫图标
    local chamberTipSprite = ui.newButton({
        normalImage = "mp_69.png",
        clickAction = function()
            ui.showFlashView(TR("地宫随机出现于地图上，请前往寻找"))
        end
        })
    chamberTipSprite:setPosition(50, 820)
    self.mParentLayer:addChild(chamberTipSprite)
    self.mChamberTipSprite = chamberTipSprite
    -- 迷宫倒计时
    local leftTimeLabel = ui.newLabel({
        text = TR("迷宫倒计时"),
        size = 20,
        outlineColor = Enums.Color.eBlack,
        })
    leftTimeLabel:setPosition(45, -10)
    chamberTipSprite:addChild(leftTimeLabel)
    self.mLeftTimeLabel = leftTimeLabel

    self:updateChamber()
    self.mSchelTime = Utility.schedule(self, self.updateChamber, 1.0)

end

-- 迷宫计时器
function SectBigMapLayer:updateChamber()
    local timeLeft = self.mChamberInfo.ChamberEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mLeftTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft)))
    else
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        if self.mChamberNpc then
            self.mChamberNpc:removeFromParent()
            self.mChamberNpc = nil  
            self.mChamberTipSprite:removeFromParent()
            self.mChamberTipSprite = nil
        end
    end
end

-- 创建bossNPC
function SectBigMapLayer:createWorldBossNpc()
    if self.mWorldBossNpc then
        self.mWorldBossNpc:removeFromParent()
        self.mWorldBossNpc = nil  
        self.mBossTipSprite:removeFromParent()
        self.mBossTipSprite = nil
    end
    local bossModel = WorldbossModel.items[self.mWorldBossInfo.WorldBossModelID]
    local bossTalkStrList = string.splitBySep(bossModel.bossTalk, "|")
    local randNum = math.random(1, #bossTalkStrList)

    local bossPos = Utility.analysisPoints(SectMapNpcRelation.items[self.mWorldBossInfo.LocationId].npcPoint)
    --boss按钮
    local worldBossNpc = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(100, 160),
        clickAction = function(pSender)
            pSender:unscheduleUpdate()
            pSender:setEnabled(false)
            local tempTime = 0
            pSender:scheduleUpdate(function(dt)
                tempTime = tempTime + dt
                if tempTime > 1 then
                    pSender:setEnabled(true)
                end
                if tempTime > 20 then
                    pSender:unscheduleUpdate()
                end
                local x, y = self.mHeroNode:getPosition()
                local lenth = cc.pGetLength(cc.pSub(cc.p(x, y), bossPos))
                if lenth <= 90 then
                    self:arrivedFun()
                    if x < bossPos.x then
                        self.playerSpine:setRotationSkewY(0)
                       self.playerSpine1:setRotationSkewY(0)
                    else
                       self.playerSpine:setRotationSkewY(180)
                       self.playerSpine1:setRotationSkewY(180)
                    end
                    
                    pSender:unscheduleUpdate()
                    LayerManager.addLayer({name = "sect.SectBossLayer"})
                end
            end)
        end
        })
    worldBossNpc:setPosition(bossPos)
    self.mMapBg:addChild(worldBossNpc)
    self.mWorldBossNpc = worldBossNpc


    --气泡框
    local speakNode = cc.Node:create()
    speakNode:setPosition(150, 120)
    speakNode:setContentSize(cc.size(210, 85))
    worldBossNpc:addChild(speakNode, 10)

    local speakSprite = ui.newSprite("zf_07.png")
    speakSprite:setPosition(0, 0)
    speakNode:addChild(speakSprite)
     
    --文字
    local speakLabel = ui.newLabel({
        text = bossTalkStrList[randNum],
        size = 20,
        color = cc.c3b(0x59, 0x28, 0x17),
        dimensions = cc.size(185, 0)
        })
    speakLabel:setAnchorPoint(0, 0.5)
    speakLabel:setPosition(-90, 10)
    speakNode:addChild(speakLabel)

    --迷宫特效
    ui.newEffect({
            parent = worldBossNpc,
            effectName = "effect_ui_boss_tongyongfazhen",
            position = cc.p(50, 0),
            loop = true,
            animation = "hou",
            scale = 0.65,
        })

    --迷宫特效
    local bossEff = ui.newEffect({
            parent = worldBossNpc,
            effectName = bossModel.qpic,
            animation = "daiji",
            position = cc.p(50, 0),
            loop = true,
            scale = 0.8,
        })
    --迷宫特效
    ui.newEffect({
            parent = worldBossNpc,
            effectName = "effect_ui_boss_tongyongfazhen",
            position = cc.p(50, 0),
            loop = true,
            animation = "qian_",
            scale = 0.65,
        })

    -- 迷宫图标
    local bossTipSprite = ui.newButton({
        normalImage = bossModel.touchPic..".png",
        clickAction = function()
            ui.showFlashView(TR("魔教随机出现于地图上，请前往寻找"))
        end
        })
    bossTipSprite:setPosition(50, 730)
    self.mParentLayer:addChild(bossTipSprite)
    self.mBossTipSprite = bossTipSprite

    ui.newEffect({
        parent = bossTipSprite,
        effectName = "effect_ui_mojiaoruqin",
        position = cc.p(45, 45),
        loop = true,
    })

    -- 迷宫倒计时
    local leftTimeLabel = ui.newLabel({
        text = TR("boss倒计时"),
        size = 20,
        outlineColor = Enums.Color.eBlack,
        })
    leftTimeLabel:setPosition(45, -10)
    bossTipSprite:addChild(leftTimeLabel)
    self.mBossLeftTimeLabel = leftTimeLabel

    self:updateWorldBoss()
    self.mBossSchelTime = Utility.schedule(self, self.updateWorldBoss, 1.0)

end

-- Boss计时器
function SectBigMapLayer:updateWorldBoss()
    local timeLeft = self.mWorldBossInfo.WorldBossEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mBossLeftTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft)))
    else
        if self.mBossSchelTime then
            self:stopAction(self.mBossSchelTime)
            self.mBossSchelTime = nil
        end
        if self.mWorldBossNpc then
            self.mWorldBossNpc:removeFromParent()
            self.mWorldBossNpc = nil  
            self.mBossTipSprite:removeFromParent()
            self.mBossTipSprite = nil
        end
    end
end

-- 创建迷宫弹窗
function SectBigMapLayer:createChamberPop()
    -- 弹窗回掉函数
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- title
        local titleSprite = ui.newSprite("mp_68.png")
        titleSprite:setPosition(bgSize.width*0.5, bgSize.height*0.8)
        bgSprite:addChild(titleSprite)
        self.joinPopSprite = bgSprite
        -- 门派数据
        local sectData = SectModel.items[sectId]
        -- 提示文字
        local hintLabel = ui.newLabel({
                text = TR("地宫中有丰厚奖励，快去探险吧！"),
                size = 26,
                color = Enums.Color.eBlack,
            })
        hintLabel:setPosition(bgSize.width*0.5, 255)
        bgSprite:addChild(hintLabel)
        -- 门派图标
        local sectSprite = ui.newSprite("mp_70.png")
        sectSprite:setPosition(bgSize.width*0.5, 160)
        bgSprite:addChild(sectSprite)
        
    end
    -- 创建对话框
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgImage = "sy_25.png",
            bgSize = cc.size(506, 387),
            notNeedBlack = true,
            DIYUiCallback = DIYfunc,
            title = "",
        }
    })
    -- 弹窗动画
    -- 背面图
    local backSprite = ui.newScale9Sprite("sy_25.png", cc.size(506, 387))
    backSprite:setPosition(self.joinPopSprite:getContentSize().width*0.5, self.joinPopSprite:getContentSize().height*0.5)
    self.joinPopSprite:addChild(backSprite)
    -- 旋转圈数
    local rotateCount = 1
    -- 循环次数
    local loopCount = rotateCount*2
    -- 当前背面
    local isCurBeimian = false
    -- 先隐藏背面显示
    backSprite:setVisible(isCurBeimian)
    -- 动作总时间
    local allTime = 0.2
    -- x最小Scale
    local minScaleX = 0.05
    -- 动作列表
    local actionList = {}
    -- 循环创建动作
    for i = 1, loopCount do
        local curScale = Adapter.MinScale * (i / loopCount )
        local actionTime = allTime / (loopCount*2)

        local scaleAction = cc.ScaleTo:create(actionTime, minScaleX, curScale)

        local callAction = cc.CallFunc:create(function (node)
            isCurBeimian = not isCurBeimian
            backSprite:setVisible(isCurBeimian)
        end)
        local scaleAction2 = cc.ScaleTo:create(actionTime, curScale, curScale)

        table.insert(actionList, scaleAction)
        table.insert(actionList, callAction)
        table.insert(actionList, scaleAction2)
    end
    -- 创建序列动作
    local seqAction = cc.Sequence:create(actionList)
    self.joinPopSprite:runAction(seqAction)
end

--完成任务弹窗
function SectBigMapLayer:showFinishView(taskInfo)
    if self.mFinishBgLayer then
        return
    end
    local taskModelInfo = SectTaskWeightRelation.items[taskInfo.ID]
    --黑色底层
    local bgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    bgLayer:setContentSize(640, 1136)
    self.mParentLayer:addChild(bgLayer, 10000)
    ui.registerSwallowTouch({node = bgLayer})
    self.mFinishBgLayer = bgLayer

    --背景图
    local finishBgSprite = ui.newSprite("mp_21.png")
    finishBgSprite:setPosition(310, 568)
    bgLayer:addChild(finishBgSprite)
    local bgSize = finishBgSprite:getContentSize()

    finishBgSprite:setScale(0.1)

    --任务名字
    local masterName = SectNpcModel.items[taskModelInfo.sectNpcId].name
    local taskNameLabel = ui.newLabel({
        text = masterName.."-"..taskModelInfo.taskName,
        size = 24,
        color = cc.c3b(0x4d, 0x2e, 0x17),
        })
    taskNameLabel:setPosition(bgSize.width * 0.55, bgSize.height * 0.88)
    finishBgSprite:addChild(taskNameLabel)

    --星级
    local starLabel = ui.newStarLevel(taskInfo.star)
    starLabel:setPosition(bgSize.width * 0.55, bgSize.height * 0.82)
    finishBgSprite:addChild(starLabel)

    --介绍
    local taskIntroLabel = ui.newLabel({
        text = string.format("   %s", taskModelInfo.intro),
        size = 20,
        color = cc.c3b(0x90, 0x5e, 0x38),
        dimensions = cc.size(300, 0)
        })
    taskIntroLabel:setPosition(bgSize.width * 0.55, bgSize.height * 0.65)
    finishBgSprite:addChild(taskIntroLabel)

    --进度
    local taskProgressLabel = ui.newLabel({
        text = string.format("%s %s/%s", taskModelInfo.taskAims, taskInfo.curNum, taskInfo.needNum),
        size = 20,
        color = cc.c3b(0x20, 0x66, 0x10),
        -- dimensions = cc.size(300, 0)
        })
    taskProgressLabel:setPosition(bgSize.width * 0.55, bgSize.height * 0.35)
    finishBgSprite:addChild(taskProgressLabel)

    --奖励
    local taskRewardLabel = ui.newLabel({
        text = TR("任务奖励：%s声望", taskModelInfo.sectCoin),
        size = 20,
        color = cc.c3b(0x4d, 0x2e, 0x17),
        -- dimensions = cc.size(300, 0)
        })
    taskRewardLabel:setPosition(bgSize.width * 0.55, bgSize.height * 0.25)
    finishBgSprite:addChild(taskRewardLabel)

    --完成按钮
    local finishBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("完成任务"),
        clickAction = function()
            SectObj:finishTask(taskInfo.ID, function(response)
                self.mFinishBgLayer:removeFromParent()
                self.mFinishBgLayer = nil
                self.mCurSearchingID = nil
                self:handletask()
                self:popCheckFun()
                self:createNPC()
                self:createbottomView()
                if taskModelInfo.sectCoin > 0 then
                    ui.showFlashView(TR("获得%s声望", taskModelInfo.sectCoin))
                end
                if response.Value.IsStory and taskModelInfo.sectCoin > 0 then
                    self:finishStoryPop()
                end
            end)
        end
        })
    finishBtn:setPosition(bgSize.width * 0.55, bgSize.height * 0.15 - 10)
    finishBgSprite:addChild(finishBtn)

    if taskModelInfo.sectCoin == 0 then
        taskRewardLabel:setVisible(false)
        finishBtn:setTitleText(TR("继续下一步"))
    end

    finishBgSprite:runAction(cc.ScaleTo:create(0.2, 1))
end

--完成剧情任务弹窗
function SectBigMapLayer:finishStoryPop()
    MsgBoxLayer.addOKLayer(
        TR("您已完成剧情任务，是否前往接受门派任务？"),
        TR("前往门派"),
        {
            {
                normalImage = "c_33.png",
                text = TR("稍后再说"),
                clickAction = function(boxLayer, btnObj)
                    LayerManager.removeLayer(boxLayer)
                end
            },
            {
                normalImage = "c_28.png",
                text = TR("立即前往"),
                clickAction = function(boxLayer, btnObj)
                    LayerManager.removeLayer(boxLayer)
                    -- LayerManager.removeLayer(self)
                    LayerManager.addLayer({
                        name = "sect.SectTaskLayer",
                        data = {},
                        cleanUp = false
                    })
                end
            },
        },
        {}
        )
end

--创建任务需要的npc
function SectBigMapLayer:createNPC()
    if next(self.mNpcNodeList) ~= nil then
        for k,v in pairs(self.mNpcNodeList) do
            v:removeFromParent()
            v = nil
        end
    end

    if next(self.mNpcSprtieList) ~= nil then
        for i,v in pairs(self.mNpcSprtieList) do
            v:removeFromParent()
            v = nil
        end
    end

    local function NpcAction()
        local sq = cc.Sequence:create(cc.ScaleTo:create(1, 1.05), cc.ScaleTo:create(1, 1))
        local action = cc.RepeatForever:create(sq)
        return action
    end

    self.mNpcNodeList = {}
    self.mNpcSprtieList = {}
    for k,v in pairs(self.mAllTasks) do
        local npcModel = SectTaskWeightRelation.items[v.ID]
        local npcInfo = SectMapNpcRelation.items[tonumber(npcModel.mapNpcId)]
        local taskPos = Utility.analysisPoints(npcInfo.npcPoint)
        local leftNum = v.needNum - v.curNum

        local taskTargetNode = cc.Node:create()
        taskTargetNode:setPosition(taskPos)
        self.mMapBg:addChild(taskTargetNode)

        self.mNpcNodeList[v.ID] = taskTargetNode
        local possList = self.mAstarWorld:randomScopePoints(taskPos, 140, leftNum)
        for i, nPos in ipairs(possList) do
            if i == 1 then
                nPos = taskPos
            end
            local taskNpc = ui.newButton({
                normalImage = npcModel.npcPic..".png",
                clickAction = function(pSender)
                    pSender:unscheduleUpdate()
                    pSender:setEnabled(false)
                    local tempTime = 0
                    pSender:scheduleUpdate(function(dt)
                        tempTime = tempTime + dt
                        if tempTime > 1 then
                            pSender:setEnabled(true)
                        end

                        if tempTime > 20 then
                            pSender:unscheduleUpdate()
                        end
                        local x, y = self.mHeroNode:getPosition()
                        local lenth = cc.pGetLength(cc.pSub(cc.p(x, y), nPos))
                        -- dump(lenth, "lenth")
                        if lenth <= 90 then
                            self:arrivedFun()
                            if x < nPos.x then
                                self.playerSpine:setRotationSkewY(0)
                                self.playerSpine1:setRotationSkewY(0)
                            else
                                self.playerSpine:setRotationSkewY(180)
                                self.playerSpine1:setRotationSkewY(180)
                            end
                            if not self.mTaskIng then
                                pSender:unscheduleUpdate()
                                self:startTask(v, i, nPos, pSender)
                            end
                        end
                    end)
                end
            })

            taskNpc:setPosition(nPos)
            table.insert(self.mNpcSprtieList, taskNpc)
            self.mMapBg:addChild(taskNpc)

            local taskNameLabel = ui.createSpriteAndLabel({
                imgName = "mp_44.png",
                labelStr = npcModel.picName,
                fontSize = 22,
                alignType = ui.TEXT_ALIGN_CENTER,
                })
            taskNameLabel:setPosition(35, 140)
            taskNpc:addChild(taskNameLabel)

            taskNpc:runAction(NpcAction())
        end
    end
end

--点击开始某一个任务
function SectBigMapLayer:startTask(taskInfo, index, taskPos, npcNode)
    self.mTaskIng = true
    local heroPos = cc.p(self.mHeroNode:getPosition())
    local dis = cc.pGetLength(cc.pSub(heroPos, taskPos))
    local taskType = SectTaskWeightRelation.items[taskInfo.ID].taskType
    if taskType == 1 then -- 战斗任务
        self:battleTask(taskInfo, index, npcNode)
    elseif taskType == 2 then -- 采集任务
        self:collusionTask(taskInfo, index, npcNode)
    elseif taskType == 3 then -- 对话任务
        self:findTask(taskInfo, index, npcNode)
    end
end

-- 战斗任务
function SectBigMapLayer:battleTask(taskInfo, index, npcNode)
    if taskInfo.curNum >= 1 then
        npcNode:setEnabled(false)
        ui.newEffect({
            parent = npcNode,
            effectName = "effect_ui_kanji",
            zorder = 1,
            position = cc.p(0, 80),
            loop = false,
            endListener = function()
                local action = cc.Sequence:create({
                cc.MoveBy:create(0.3, cc.p(0, 150)),
                cc.CallFunc:create(function()
                    MqAudio.playEffect("chuangdang_hit02.mp3")
                    npcNode:setVisible(false)
                end)
                })
                npcNode:runAction(action)
            end
        })
        self:changeSkelAction(self.playerSpine, "pugong", false)
        self:changeSkelAction(self.playerSpine1, "pugong", false)

        SectObj:refreshTaskProgress(taskInfo.ID, function(response)
            self.mCurSearchingID = taskInfo.ID
            self:handletask()
            -- self:createNPC()
            self:createbottomView()
            self.mTaskIng = false
            if taskInfo.curNum < taskInfo.needNum-1 then
                ui.showFlashView(string.format("%s: %s/%s", SectTaskWeightRelation.items[taskInfo.ID].taskAims, taskInfo.curNum, taskInfo.needNum) )
            end
        end)
        return
    end

    npcNode:setEnabled(true)
    MsgBoxLayer.addDIYLayer({
        title = " ",
        closeBtnInfo = {clickAction = function(pSenderLayer, btnObj)
            LayerManager.removeLayer(pSenderLayer)
            self.mTaskIng = false
        end},
        notNeedBlack = true,
        btnInfos = {{
            normalImage = "c_28.png",
            text = TR("开始挑战"),
            clickAction = function()
                self:requestFightInfo(taskInfo)
            end
        }},
        DIYUiCallback = function(layer, layerBgSprite, layerSize)
            local heroBgSprite = ui.newSprite("fb_32.png")
            heroBgSprite:setPosition(160, 220)
            layerBgSprite:addChild(heroBgSprite)

            local heroFigure = Figure.newHero({
                heroModelID = taskInfo.heroModelId,
                parent = layerBgSprite,
                position = cc.p(150, 105),
                scale = 0.2,
                needAction = false,
            })

            local taskName = ui.newLabel({
                text = SectTaskWeightRelation.items[taskInfo.ID].taskName,
                size = 30,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                })
            taskName:setAnchorPoint(0, 0.5)
            taskName:setPosition(310, 305)
            layerBgSprite:addChild(taskName)

            local taskStars = ui.newStarLevel(taskInfo.star)
            taskStars:setAnchorPoint(0, 0.5)
            taskStars:setPosition(310, 265)
            layerBgSprite:addChild(taskStars)
            -- dump(taskInfo)
            local fapLabel = ui.newLabel({
                text = TR("推荐战力：%s%s", "#258711", Utility.numberFapWithUnit(taskInfo.taskFAP)),
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                size = 24,
                })
            fapLabel:setAnchorPoint(0, 0.5)
            fapLabel:setPosition(310, 225)
            layerBgSprite:addChild(fapLabel)

            local campBtn = ui.newButton({
                normalImage = "tb_11.png",
                clickAction = function()
                    self.mTaskIng = false
                    LayerManager.removeLayer(layer)
                    LayerManager.addLayer({
                        name = "team.CampLayer",
                        cleanUp = false,
                    })
                end
                })
            campBtn:setPosition(475, 155)
            layerBgSprite:addChild(campBtn)

        end,
        bgSize = cc.size(556, 404)
    })
end

-- 采集任务
function SectBigMapLayer:collusionTask(taskInfo, index, npcNode)   
    npcNode:setEnabled(false)
    local action = cc.Sequence:create({
            cc.MoveBy:create(0.3, cc.p(0, 150)),
            cc.CallFunc:create(function()
                MqAudio.playEffect("caiji.mp3")
                npcNode:setVisible(false)
            end)
        })
    npcNode:runAction(action)

    SectObj:refreshTaskProgress(taskInfo.ID, function(response)
        self.mCurSearchingID = taskInfo.ID
        self:handletask()
        -- self:createNPC()
        self:createbottomView()
        self.mTaskIng = false
        if taskInfo.curNum < taskInfo.needNum-1 then
            ui.showFlashView(string.format("%s: %s/%s", SectTaskWeightRelation.items[taskInfo.ID].taskAims, taskInfo.curNum, taskInfo.needNum) )
        end
    end)
end
-- 对话任务
function SectBigMapLayer:findTask(taskInfo, index, npcNode)
    npcNode:setEnabled(false)

    local taskModelInfo = SectTaskFindModel.items[taskInfo.ID]
    local talkTag = 1
    --黑色底层
    local bgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    bgLayer:setContentSize(640, 1136)
    self.mParentLayer:addChild(bgLayer, 10000)

    local talkBgSprite = ui.newSprite("jq_281.png")
    talkBgSprite:setPosition(320, 250)
    bgLayer:addChild(talkBgSprite, 10)

    local tempLeftSprite = ui.newSprite("zsf.png")
    tempLeftSprite:setPosition(100, 250)
    tempLeftSprite:setScale(0.7)
    bgLayer:addChild(tempLeftSprite)
    tempLeftSprite:setVisible(false)

    local tempRightSprite = ui.newSprite("zsf.png")
    tempRightSprite:setPosition(540, 250)
    tempRightSprite:setScale(0.7)
    bgLayer:addChild(tempRightSprite)
    tempRightSprite:setVisible(false)
    tempRightSprite:setRotationSkewY(180)

    local nameLeft = ui.newLabel({
        text = TR("是是是"),
        size = 22,
        color = cc.c3b(0xff, 0xd4, 0xa2),
        })
    nameLeft:setPosition(100, 210)
    talkBgSprite:addChild(nameLeft)
    nameLeft:setVisible(false)

    local nameRight = ui.newLabel({
        text = TR("是是是"),
        size = 22,
        color = cc.c3b(0xff, 0xd4, 0xa2),
        })
    nameRight:setPosition(540, 210)
    talkBgSprite:addChild(nameRight)
    nameRight:setVisible(false)

    local curWard = ui.newLabel({
        text = TR("吃吃吃吃错错错错错错错错错错错错错错错错错"),
        size = 22,
        dimensions = cc.size(550, 0)
        })
    curWard:setPosition(320, 150)
    talkBgSprite:addChild(curWard)
    -- curWard:setAnchorPoint(0, 0.5)

    local function refreshTalkView()
        if talkTag > #taskInfo+1 then
            return
        end

        if talkTag == #taskInfo+1 then
            tempLeftSprite:runAction(cc.Sequence:create({
                cc.MoveBy:create(0.3, cc.p(-300, 0)),
                cc.CallFunc:create(function()
                    bgLayer:removeFromParent()
                    bgLayer = nil
                end)
                }))
            tempRightSprite:runAction(cc.MoveBy:create(0.3, cc.p(300, 0)))

            SectObj:refreshTaskProgress(taskInfo.ID, function(response)
                self.mCurSearchingID = taskInfo.ID
                self:handletask()
                -- self:createNPC()
                self:createbottomView()
                self.mTaskIng = false
            end)
            talkTag = talkTag + 1
            return
        end

        local curTagInfo = taskModelInfo[talkTag]
        local nameStr = curTagInfo.name == "" and PlayerAttrObj:getPlayerAttrByName("PlayerName") or curTagInfo.name
        local pic
        if curTagInfo.staticPic == "" then
            local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
            local fashionID = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
            if fashionID ~= 0 then
                pic = FashionModel.items[fashionID].staticPic
            else
                pic = HeroModel.items[playerModelId].staticPic
            end
        else
            pic = curTagInfo.staticPic
        end

        if curTagInfo.leftOrRight == 1 then
            tempLeftSprite:setVisible(true)
            tempLeftSprite:setScale(0.8)
            tempLeftSprite:setOpacity(255)
            tempLeftSprite:setTexture(pic..".png")
            nameLeft:setVisible(true)
            nameLeft:setString(nameStr)
            curWard:setString(curTagInfo.npcSpeak)

            tempRightSprite:setScale(0.7)
            tempRightSprite:setOpacity(190)
            nameRight:setVisible(false)
            -- curWard:setAnchorPoint(0, 0.5)
            -- curWard:setPosition(60, 150)
        else
            tempRightSprite:setVisible(true)
            tempRightSprite:setScale(0.8)
            tempRightSprite:setOpacity(255)
            tempRightSprite:setTexture(pic..".png")
            nameRight:setVisible(true)
            nameRight:setString(nameStr)
            curWard:setString(curTagInfo.npcSpeak)

            tempLeftSprite:setScale(0.7)
            tempLeftSprite:setOpacity(190)
            nameLeft:setVisible(false)
            -- curWard:setAnchorPoint(1, 0.5)
            -- curWard:setPosition(320, 150)
        end

        talkTag = talkTag + 1
    end 

    ui.registerSwallowTouch({
        node = bgLayer,
        endedEvent = function(event, touch)
            refreshTalkView()
        end,
        })
    refreshTalkView()
end

--创建下方任务追踪按钮
function SectBigMapLayer:createbottomView()
    if not self.mCurSearchingID then
        if self.mSearchBtn then
            self.mSearchBtn:removeFromParent()
            self.mSearchBtn = nil
            self.mCheckAllBtn:removeFromParent()
            self.mCheckAllBtn = nil
            self.mControlBtn:removeFromParent()
            self.mControlBtn = nil
        end
        return
    end
    if self.mSearchBtn then
        self.mSearchBtn:removeFromParent()
        self.mSearchBtn = nil
        self.mCheckAllBtn:removeFromParent()
        self.mCheckAllBtn = nil
        self.mControlBtn:removeFromParent()
        self.mControlBtn = nil
    end

    local taskInfo = SectTaskWeightRelation.items[self.mCurSearchingID]
	local searchBtn = ui.newButton({
		normalImage = "mp_20.png",
		clickAction = function()
            if taskInfo.isAuto == 1 then
                self:AiWalk(self.mCurSearchingID)
            else
                ui.showFlashView(TR("该任务无法自动寻路哦"))
            end
		end
		})
	searchBtn:setPosition(275, 80)
	self.mParentLayer:addChild(searchBtn, 10)
    self.mSearchBtn = searchBtn

    if taskInfo.isAuto == 1 then
        ui.newEffect({
            parent = searchBtn,
            effectName = "effect_ui_zidongxunlu",
            zorder = 1,
            position = cc.p(157, 65),
            loop = true,
        })
    end

    local taskProgress
    for i,v in ipairs(self.mAllTasks) do
        if v.ID == self.mCurSearchingID then
            taskProgress = v
            break
        end
    end
    --任务名称
    local masterName = SectNpcModel.items[taskInfo.sectNpcId].name
    local taskNameLabel = ui.newLabel({
        text = masterName.."-"..taskInfo.taskName,
        size = 24,
        color = cc.c3b(0xff, 0xd4, 0xa2),
        })
    taskNameLabel:setPosition(157, 80)
    searchBtn:addChild(taskNameLabel)

    --任务目标
    local taskAimsLabel = ui.newLabel({
        text = string.format("%s：%s/%s", taskInfo.taskAims, taskProgress.curNum, taskProgress.needNum),
        size = 20,
        color = cc.c3b(0xff, 0xf6, 0xd2),
        })
    taskAimsLabel:setPosition(157, 40)
    searchBtn:addChild(taskAimsLabel)


	local checkAllBtn = ui.newButton({
		normalImage = "mp_42.png",
		clickAction = function()
			self:taskListPop()
		end
		})
	checkAllBtn:setPosition(495, 80)
    self.mCheckAllBtn = checkAllBtn
	self.mParentLayer:addChild(checkAllBtn)

    local controlBtn = ui.newButton({
        normalImage = self.mIsShowSearching and "mp_89.png" or "mp_88.png",
        clickAction = function(pSender)
            self.mIsShowSearching = not self.mIsShowSearching
            self.mSearchBtn:setVisible(self.mIsShowSearching)
            self.mCheckAllBtn:setVisible(self.mIsShowSearching)
            pSender:loadTextureNormal(self.mIsShowSearching and "mp_89.png" or "mp_88.png")
        end
        })
    controlBtn:setPosition(95, 80)
    self.mParentLayer:addChild(controlBtn)
    self.mControlBtn = controlBtn

    self.mSearchBtn:setVisible(self.mIsShowSearching)
    self.mCheckAllBtn:setVisible(self.mIsShowSearching)

end

--自动寻路
function SectBigMapLayer:AiWalk(taskId)
    if self.mAiWalkEff then
        self.mAiWalkEff:removeFromParent()
        self.mAiWalkEff = nil
    end

    local aiWalkEff = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_zidongxunluzhong_tw",
            zorder = 1,
            position = cc.p(320, 568),
            loop = true,
        })
    self.mAiWalkEff = aiWalkEff

    local startPos = cc.p(self.mHeroNode:getPosition())
    local targetPos = cc.p(self.mNpcNodeList[taskId]:getPosition())
    self:getPathWay(startPos, targetPos)
end

--任务列表弹窗
function SectBigMapLayer:taskListPop()
	local popLayer = LayerManager.addLayer({
            name = "commonLayer.PopBgLayer",
            data = {
                bgSize = cc.size(582, 668),
                title = TR("任务列表"),
            },
            cleanUp = false,
        })
	local popbgSprite = popLayer.mBgSprite
	local bgSize = popbgSprite:getContentSize()
	self.mPopLayer = popLayer

	local grayUnderBg = ui.newScale9Sprite("c_17.png", cc.size(524, 568))
	grayUnderBg:setPosition(291, 314)
	popbgSprite:addChild(grayUnderBg)

	local taskListView = ccui.ListView:create()
    taskListView:setDirection(ccui.ScrollViewDir.vertical)
    taskListView:setBounceEnabled(true)
    taskListView:setContentSize(cc.size(514, 548))
    taskListView:setItemsMargin(3)
    -- taskListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    taskListView:setAnchorPoint(cc.p(0.5, 1))
    taskListView:setPosition(bgSize.width / 2, 588)
    popbgSprite:addChild(taskListView)
    self.mTaskListView = taskListView

    self.mSearchBtnList = {}
    self.mSearchTipList = {}

    for i = 1, #self.mAllTasks do
    	taskListView:pushBackCustomItem(self:taskItemCell(i))
    end
    self:refreshTaskList()
end

-- 放弃任务刷新
function SectBigMapLayer:giveUpRefresh()
    if self.mTaskListView then
        self.mTaskListView:removeAllChildren()
        self.mSearchBtnList = {}
        self.mSearchTipList = {}
    end
    for i = 1, #self.mAllTasks do
        self.mTaskListView:pushBackCustomItem(self:taskItemCell(i))
    end
    self:refreshTaskList()
    if #self.mAllTasks == 0 then
        self.mPopLayer:removeFromParent()
        self.mPopLayer = nil
    end
end 

--点击追踪刷新
function SectBigMapLayer:refreshTaskList()
    for k,v in pairs(self.mSearchBtnList) do
        if k == self.mCurSearchingID then
            v:setVisible(false)
        else
            v:setVisible(true)
        end
    end
    for k,v in pairs(self.mSearchTipList) do
        if k == self.mCurSearchingID then
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end
end

--创建任务列表条目
function SectBigMapLayer:taskItemCell(i)
    local taskInfo = self.mAllTasks[i]
    local taskModelInfo = SectTaskWeightRelation.items[taskInfo.ID]

    local layout = ccui.Layout:create()
    layout:setContentSize(514, 126)

    local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(514, 126))
    bgSprite:setAnchorPoint(0.5,0.5)
    bgSprite:setPosition(257, 63)
    layout:addChild(bgSprite)

    local masterName = SectNpcModel.items[taskModelInfo.sectNpcId].name
    local taskNameLabel = ui.newLabel({
        text = masterName.."-"..taskModelInfo.taskName,
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d)
        })
    taskNameLabel:setAnchorPoint(0, 0.5)
    taskNameLabel:setPosition(40, 85)
    layout:addChild(taskNameLabel)

    local taskAimsLabel = ui.newLabel({
        text = string.format("%s: %s/%s", taskModelInfo.taskAims, taskInfo.curNum, taskInfo.needNum),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d)
        })
    taskAimsLabel:setAnchorPoint(0, 0.5)
    taskAimsLabel:setPosition(40, 35)
    layout:addChild(taskAimsLabel)

    local tipLabel = ui.newLabel({
            text = TR("正在追踪..."),
            color = cc.c3b(0x25, 0x87, 0x11),
            size = 22,
            })
    tipLabel:setPosition(442, 90)
    layout:addChild(tipLabel)
    tipLabel:setVisible(false)
    self.mSearchTipList[taskInfo.ID] = tipLabel

    local serchBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("追踪"),
        clickAction = function(pSender)
            self.mCurSearchingID = taskInfo.ID
            self:createbottomView()
            self:refreshTaskList()
        end
        })

    serchBtn:setPosition(442, 95)
    layout:addChild(serchBtn)
    serchBtn:setVisible(true)
    self.mSearchBtnList[taskInfo.ID] = serchBtn

    local giveUpBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("放弃"),
        clickAction = function()
            SectObj:giveUpTask(taskInfo.ID, function()
                if self.mCurSearchingID == taskInfo.ID then
                    self.mCurSearchingID = nil
                end
                self:handletask()
                self:createNPC()
                self:popCheckFun()
                self:createbottomView()
                self:giveUpRefresh()
            end)
        end
        })

    giveUpBtn:setPosition(442, 35)
    layout:addChild(giveUpBtn)

    return layout
end

--注册触摸事件
function SectBigMapLayer:setTouchEvent()
	local function touchBegan(touch, event)
		local touchPos = touch:getLocation()
        self.mTouchPos = touchPos
		return true
	end
	local function touchMoved(touch, event)
		-- local touchPos = touch:getLocation()
		-- dump(touchPos, "moved")
	end
	local function touchEnded(touch, event)
		local touchPos = touch:getLocation()
        local dis = cc.pGetLength(cc.pSub(self.mTouchPos, touchPos))
        if dis < 5 then
            local targetPos = self.mMapBg:convertToNodeSpace(touchPos)
            local startPos = cc.p(self.mHeroNode:getPosition())
            local dis = cc.pGetLength(cc.pSub(startPos, targetPos))
            if dis < 20 then
                return
            end
            
            --点击特效
            local canMovecheckPos = self.mAstarWorld:getPixelCollusion(targetPos)
            if self.mClickEffect then
                self.mClickEffect:removeFromParent(true)
                self.mClickEffect = nil
            end
            if canMovecheckPos ~= 2 then
                if cc.pGetLength(cc.pSub(startPos, targetPos)) > 100 then
                    self.mClickEffect = ui.newEffect({
                        parent = self.mMapBg,
                        effectName = "effect_ui_dianji",
                        zorder = 1,
                        position = targetPos,
                        loop = false,
                        endRelease = true,
                        endListener = function()
                            self.mClickEffect = nil
                        end
                    })
                end
            end
            if self.mAiWalkEff then
                self.mAiWalkEff:removeFromParent()
                self.mAiWalkEff = nil
            end
            self:getPathWay(startPos, targetPos)
        end
	end
	ui.registerSwallowTouch({
		node = self.mWorldView,
        allowTouch = false,
        beganEvent = touchBegan,
        movedEvent = touchMoved,
        endedEvent = touchEnded,
	})
end

--计算路径
function SectBigMapLayer:getPathWay(curPos, targetPos)
     -- 获取目标点tag
    local isCouldMove = self.mAstarWorld:getPixelCollusion(targetPos)
    -- 可以移动区
    if isCouldMove == 0 or isCouldMove == 1 then
        self.mHeroNode:unscheduleUpdate()
        local path = self.mAstarWorld:calcTrack(curPos, targetPos)
        self:actionFuc(path)
    -- 非移动区
    else
        print("CAN'T MOVE")
        -- -- 找到可移动且距离主角最短的点
        -- local heroformPos = self:posTransform(curPos)
        -- local centerformPos = self:posTransform(targetPos)
        -- local endPos = self:getMovePos(centerformPos, heroformPos)
        -- -- 找到该点
        -- if endPos ~= nil then
        --     local path = self.mAstarWorld:calcTrack(curPos, targetPos)
        --     self:actionFuc(path)
        -- else
        --     ui.showFlashView({text = TR("不可移动区太大")})
        -- end
    end
    -- self.touchedPos = nil
end

-- 切换骨骼动作
function SectBigMapLayer:changeSkelAction(effectObj, animationName, loop)
    effectObj:setToSetupPose()
    SkeletonAnimation.action({
        skeleton = effectObj,
        action = animationName,
        loop = loop,
    })
end

--移动
function SectBigMapLayer:actionFuc(stepList)

    if #stepList <= 1 then
        if self.mAiWalkEff then
            self.mAiWalkEff:removeFromParent()
            self.mAiWalkEff = nil
        end
        return
    end
    self:changeSkelAction(self.playerSpine, "zou", true)
    self:changeSkelAction(self.playerSpine1, "zou", true)

    self.mHeroNode:scheduleUpdate(function(dt)
        --角色位置
        local playerPos = cc.p(self.mHeroNode:getPosition())
        local isArrived, nextPos, up, angle, isAlpha = self.mAstarWorld:getCurrentStepInfo(playerPos, 150, dt)
        self.mHeroNode:setPosition(nextPos)
        --角色的方向并相应的隐藏骨骼
        if up then
            self.playerSpine1:setVisible(true)
            self.playerSpine:setVisible(false)
        else
            self.playerSpine1:setVisible(false)
            self.playerSpine:setVisible(true)
        end
        -- 角色转向
        self.playerSpine:setRotationSkewY(angle)
        self.playerSpine1:setRotationSkewY(angle)

        --当遇到矿石的时候，主角设置半透明
        -- for key, value in pairs(self.mOreTable) do
        --     if math.abs(playerPos.x - value.position.x) < 60 and math.abs(playerPos.y - value.position.y) < 60 and self.oreList[key]:isVisible() then
        --         isAlpha = 1
        --         break
        --     end
        -- end

        --设置半透明
        if isAlpha then
            self.playerSpine:setOpacity(100)
            self.playerSpine1:setOpacity(100)
        else
            self.playerSpine:setOpacity(255)
            self.playerSpine1:setOpacity(255)
        end

       -- 更新地图随人物移动
        self.curViewPosition.x = self.curViewPosition.x + (nextPos.x - playerPos.x)/14.20
        self.curViewPosition.y = self.curViewPosition.y - (nextPos.y - playerPos.y)/10.20
        -- dump(self.curViewPosition, "curViewPosition")
        -- dump(nextPos, "nextPos")
        -- dump(playerPos, "playerPos")
        --滚动层滚动
        self.mWorldView:scrollToPercentBothDirection(self.curViewPosition, 0, true)

        --当与其他玩家发生碰撞时降低或者增加层级，避免踩到别人。显得太假
        -- for i=1,#self.mEnemyTable do
        --     if math.abs(playerPos.x - self.mEnemyTable[i]:getPositionX()) < 50 then
        --         if playerPos.y > self.mEnemyTable[i]:getPositionY() then
        --             self.mHeroNode:setLocalZOrder(ENEMY_ZORDER - 1)
        --         end

        --         if playerPos.y < self.mEnemyTable[i]:getPositionY() then
        --             self.mHeroNode:setLocalZOrder(ENEMY_ZORDER + 1)
        --         end
        --     end
        -- end
        -- self.mOverActionTag = 0
        --到达制定地点并播放相应动作
        if isArrived then
            self:arrivedFun()
        end
    end)
end

--走动到达
function SectBigMapLayer:arrivedFun()
    if self.mAiWalkEff then
        self.mAiWalkEff:removeFromParent()
        self.mAiWalkEff = nil
    end
    self.playerSpine:setToSetupPose()
    self.playerSpine:setAnimation(0, "daiji", true)
    self.playerSpine1:setToSetupPose()
    self.playerSpine1:setAnimation(0, "daiji", true)
    self.mHeroNode:unscheduleUpdate()
end

-- 以某点为中心找出离主角最短且可移动的点
function SectBigMapLayer:getMovePos(centerPos, heroPos)
    for circleNum = 1, 3 do
        -- 可移动点列表
        local canMovePosList = {}
        -- 遍历外围
        for i = -circleNum, circleNum do
            for j = -circleNum, circleNum do
                --剔除内围
                if math.abs(i) == circleNum or math.abs(j) == circleNum then
                    -- 坐标
                    local y = centerPos.y + i
                    local x = centerPos.x + j
                    -- 获取这点的tag
                    local curPos = self:formTransPos(cc.p(x, y))
                    local isCouldMove = self.mAstarWorld:getPixelCollusion(curPos)
                    -- 可移动点
                    if isCouldMove == 0 or isCouldMove == 1 then
                        table.insert(canMovePosList, curPos)
                    end
                end
            end
        end
        -- 列表不空
        if #canMovePosList > 0 then
            -- 找出最短点
            local minDis = cc.pGetLength(cc.pSub(canMovePosList[1], heroPos))
            local minIndex = 1
            for i = 1, #canMovePosList do
                local curDis = cc.pGetLength(cc.pSub(canMovePosList[i], heroPos))
                if minDis > curDis then
                    minDis = curDis
                    minIndex = i
                end
            end
            local endPos = clone(canMovePosList[minIndex])
            return endPos
        end
    end
    return nil
end

function SectBigMapLayer:formTransPos(indexPos)
    local itemSize = self.mAstarWorld.itemSize
    return {x = (indexPos.x-0.5) * itemSize, y = (indexPos.y-0.5) * itemSize}
end

function SectBigMapLayer:posTransform(position)
    local itemSize = self.mAstarWorld.itemSize
    local curPos = {x = math.ceil((position.x+0.5) / itemSize), y = math.ceil((position.y+0.5) / itemSize)}
    return curPos
end

--页面恢复信息
function SectBigMapLayer:getRestoreData()
    local retData = {
        scrollPos = self.curViewPosition,
        heroPos = cc.p(self.mHeroNode:getPosition()),
        searchingId = self.mCurSearchingID,
    }
    return retData
end

--boss出现倒计时
function SectBigMapLayer:updateBossShow()

    if Player:getCurrentTime() >= self.mWorldBossStartTime then
        return
    end

    if self.mBossShowTime then
        self:stopAction(self.mBossShowTime)
        self.mBossShowTime = nil
    end

    self.mBossShowTime = Utility.schedule(self, function()
        local timeLeft = self.mWorldBossStartTime - Player:getCurrentTime()
        if timeLeft <= 0 then
            if self.mBossShowTime then
                self:stopAction(self.mBossShowTime)
                self.mBossShowTime = nil
            end
            self:requestGetWorldBossBaseInfo()
        end
    end, 1.0)
end

---==============================网络请求相关=============================================
function SectBigMapLayer:requestFightInfo(taskInfo)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "GetFightInfo",
        svrMethodData = {taskInfo.ID},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response, "FightInfo")
            -- 战斗页面控制信息
            local bgMap = SectTaskBattleModel.items[taskInfo.ID].bgPic
            local controlParams = Utility.getBattleControl(ModuleSub.eSectTask)
            local battleLayer = LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = response.Value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    map = bgMap,
                    callback = function(retData)
                        -- dump(retData, "ccccccDDDD")
                        CheckPve.sectFight(taskInfo.ID, retData, taskInfo.curNum)
                        
                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })

        end
    })
end

--获取boss信息
function SectBigMapLayer:requestGetWorldBossBaseInfo()
    HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "GetWorldBossBaseInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- dump(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mWorldBossInfo = response.Value.WorldBossInfo
            self.mWorldBossStartTime = response.Value.WorldBossStartTime
            self:updateBossShow()
            if next(self.mWorldBossInfo) ~= nil then
                self.mIsHaveBoss = true
                self:createWorldBossNpc()
            end
            self:popCheckFun()
        end
    })
end

return SectBigMapLayer