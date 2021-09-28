--[[
    文件名: MeetXunbaoLayer.lua
	描述: 奇遇-密室寻宝
	创建人: yanghongsheng
	创建时间: 2017.4.10
--]]

local MeetXunbaoLayer = class("MeetXunbaoLayer", function()
    return display.newLayer()
end)

-- 高度差
local heightSpace = 50

--定义方向
local MoveDirection = {
    eUp = 1,
    eDown = 2,
    eLeft = 3,
    eRight = 4,
}

--[[
    params:
        meetInfo    -- 奇遇信息
        showMeetId  -- 奇遇ID
        selIndex    -- 索引
        chamberInfo : --服务端传的迷宫信息
        isEnterGMD  -- 是否是进入光明顶
]]
function MeetXunbaoLayer:ctor(params)
    --self.meetId = params.showMeetId or 0
    --当前奇遇数据
    --self.mMeetInfo = params.meetInfo[params.selIndex]
    self.mChamberInfo = params.chamberInfo or {}
	self.mAnimationTag = 0
    self.mIsEnterGMD = params.isEnterGMD
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    ui.registerSwallowTouch({node = self})

    --关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1050),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    cancelBtn:setVisible(not self.mIsEnterGMD)
    self.mParentLayer:addChild(cancelBtn, 1)

    -- 获取奖励信息
    --self:getRewardInfo()
    self:initUI()
    -- 注册进入退出事件
    self:registerScriptHandler(function(event)
        if "enterTransitionFinish" == event then
            -- 暂停背景音乐
            MqAudio.pauseMusic()
        elseif "cleanup" == event then
            -- 播放背景音乐
            MqAudio.resumeMusic()
        end
    end)
end

function MeetXunbaoLayer:initUI()
    -- 背景图集合
    local bgSpriteName = ""
    -- 根据地图找到宝箱的位置
    local rewardPos = {}
    -- 根据地图找到人物的开始位置
    local heroPos = {}
    -- 获取随机数
    -- local randNum = math.random(1,3)
    local randNum = self.mIsEnterGMD and 2 or self.mChamberInfo.ChamberMapId
    local worldStr = ""
    if randNum == 1 then
        worldStr = "quickExp.cdjh_47"
        bgSpriteName = "cdjh_45.jpg"
        rewardPos = cc.p(455, 510)
        heroPos = cc.p(75, 720)
    elseif randNum == 2 then
        worldStr = "quickExp.cdjh_48"
        bgSpriteName = "cdjh_48.jpg"
        rewardPos = cc.p(265, 490)
        heroPos = cc.p(45, 720)
    elseif randNum == 3 then
        worldStr = "quickExp.cdjh_49"
        bgSpriteName = "cdjh_49.jpg"
        rewardPos = cc.p(355, 620)
        heroPos = cc.p(45, 670)
    end
    -- 初始化寻路
    self.curViewPosition = cc.p(50, 50)
    self.starWorld = require("common.AStar").new({worldStr})

    -- 添加背景图
    local bgSprite = ui.newSprite(bgSpriteName)
    bgSprite:setIgnoreAnchorPointForPosition(false)
    bgSprite:setAnchorPoint(0, 0)

    -- 裁剪视图
    local clipping = cc.ClippingNode:create()
    clipping:setAnchorPoint(0.5, 0.5)
    clipping:setAlphaThreshold(0)
    clipping:addChild(bgSprite)
    self.mParentLayer:addChild(clipping)
    self.mBgSprite = bgSprite

    -- 宝箱
    local rewardBtn = ui.newSprite("tb_73.png")
    rewardBtn:setAnchorPoint(0.5, 0.5)
    rewardBtn:setPosition(rewardPos)
    bgSprite:addChild(rewardBtn)
    self.mRewarBtnPos = rewardPos
    self.mRewardBtn = rewardBtn
    -- 进入光明顶隐藏宝箱
    rewardBtn:setVisible(not self.mIsEnterGMD)
    -- if not next(self.mUnRewardInfo) then
    --     rewardBtn:setTexture("r_14.png")
    -- end
    local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    -- 添加一个可以移动的小人
    self.mHeroNode = cc.Node:create()
    self.mHeroNode:setContentSize(cc.size(50, 80))
    self.mHeroNode:setAnchorPoint(cc.p(0.5, 0))
    self.mHeroNode:setPosition(heroPos)
    bgSprite:addChild(self.mHeroNode)

    -- HeroQimageRelation.items[playerModelId].positivePic
    local positivePic, backPic = QFashionObj:getQFashionByDressType()
    self.playerSpine = ui.newEffect({
        parent = self.mHeroNode,
        effectName = positivePic,
        position = cc.p(30  , 0),
        loop = true,
        endRelease = true,
        scale = 0.4
    })
    --创建渐变色光圈
    local stencilNode = ui.newSprite("cdjh_60.png")
    stencilNode:setScale(0.8)
    stencilNode:setPosition(cc.p(20, 50))
    self.mHeroNode:addChild(stencilNode)
    clipping:setStencil(stencilNode)

    self:handleChamber()

    --移动事件
   self:setTouchMoveEvent()
end

-- 处理迷宫数据
function MeetXunbaoLayer:handleChamber()
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
            self:createChamber()
        end
    end
end

--创建倒计时显示
function MeetXunbaoLayer:createChamber()

    local tipLable = ui.newLabel({
        text = TR("距离地宫消失还有"),
        size = 26,
        })
    tipLable:setPosition(320, 1035)
    self.mParentLayer:addChild(tipLable)

    local timeLabel = ui.newLabel({
        text = "zou",
        size = 28,
        })
    timeLabel:setPosition(320, 1005)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    self:updateChamber()
    self.mSchelTime = Utility.schedule(self, self.updateChamber, 1.0)
end


-- 迷宫计时器
function MeetXunbaoLayer:updateChamber()
    local timeLeft = self.mChamberInfo.ChamberEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft)))
    else
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
            ui.showFlashView(TR("地宫已消失"))
            LayerManager.removeLayer(self)
        end
    end
end

-- 判读是否达到宝箱位置
function MeetXunbaoLayer:IsRewarBtnPos(endPos)
    -- 宝箱的位置
    local rewardBtnPos = self.mRewarBtnPos
    -- 宝箱左右多少个像素范围（默认60）
    local space = 60
    local isX = endPos.x >= (rewardBtnPos.x - space) and endPos.x <= (rewardBtnPos.x + space) and true or false
    local isY = endPos.y >= (rewardBtnPos.y - space) and endPos.y <= (rewardBtnPos.y + space) and true or false
    -- 达到宝箱范围内 可以领取宝箱
    if isX and isY then
        -- 弹出对话框 领取奖励
        --if next(self.mUnRewardInfo) then
            self:addPopLayer()
        --end
    end
end

-- 对话框，领取奖励
function MeetXunbaoLayer:addPopLayer()
    local popSprite = ui.newScale9Sprite("cdjh_12.png",cc.size(580, 180))
    popSprite:setAnchorPoint(cc.p(0.5, 0))
    popSprite:setPosition(320, 120)
    self.mParentLayer:addChild(popSprite, 2)
    self.mPopSprite = popSprite

    popSprite:setScale(0.2)
    local actList = {
        cc.Show:create(),
        cc.ScaleTo:create(0.25, 1.0),
    }
    popSprite:runAction(cc.Sequence:create(actList))

    -- 添加对白
    local introLabel = ui.newLabel({
        text = self.mIsEnterGMD and TR("突然，眼前一阵白光闪过，你终于走出了密道。") or TR("哇，居然有一个古朴的宝箱! 快打开看看"),
        outlineColor = cc.c3b(0x28, 0x28, 0x29),
        outlineSize = 2,
        valign = ui.VERTICAL_TEXT_ALIGNMENT_TOP,
        size = 24,
        dimensions = cc.size(500, 0),
        anchorPoint = cc.p(0, 1)
    })
    introLabel:setPosition(40, 150)
    popSprite:addChild(introLabel)

    local openBtn = ui.newButton({
        normalImage = "c_28.png",
        text = self.mIsEnterGMD and TR("确定") or TR("打开"),
        fontSize = 24,
        anchorPoint = cc.p(0, 0),
        position = cc.p(420, 50),
        clickAction = function()
            --self:addRewardMesgLayer()
            if self.mIsEnterGMD then
                LayerManager.removeLayer(self)
            else
                self:getReward()
            end
        end,
    })
    popSprite:addChild(openBtn)
end

-- 奖励弹窗
function MeetXunbaoLayer:addRewardMesgLayer()
    if not next(self.mUnRewardInfo) then
        ui.showFlashView(TR("奖励已领完"))
        return
    end
    --默认选择第一个未领取的奖励宝箱
    local rewardID = self.mUnRewardInfo[1]
    --宝箱奖励列表（解析字符串形式的资源列表为table形式）
    local chestReward = Utility.analysisStrResList(QuickexpMeetChamberModel.items[rewardID].outStr)
    --为奖励列表中的每一个元素添加显示配置信息
    for i, v in ipairs(chestReward) do
        v.cardShowAttrs = {CardShowAttr.eName, CardShowAttr.eBorder, CardShowAttr.eNum}
    end

    -- 按钮配置信息
    local btnInfo = {
        text = TR("领取"),
        size = 22,
        color = cc.c3b(0xff, 0xff, 0xff),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
            self:getReward()
        end
    }

    --关闭按钮
    local mCloseBtn = {
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
        end
    }

    -- 弹出奖励页面
    MsgBoxLayer.addPreviewDropLayer(
        chestReward,
        nil,
        TR("宝箱奖励"),
        {btnInfo},
        mCloseBtn
    )
end

-- 奇遇结束
function MeetXunbaoLayer:meetIsDone()
    self.mMeetInfo.IsDone = true
    self.mMeetInfo.redDotSprite:setVisible(false)
end

--=========================网络=====================
-- 获取密室逃脱的奖励信息
function MeetXunbaoLayer:getRewardInfo()
    -- if self.meetId == 0 then
    --     ui.showFlashView(TR("没有传奇遇ID"))
    --     return
    -- end
    HttpClient:request({
        moduleName = "QuickExp",
        methodName = "GetMeetChamberInfo",
        svrMethodData = {self.meetId},
        callback = function(response)
            -- 判断返回数据
            if not response or response.Status ~= 0 then
                return
            end

            local info = response.Value.ChamberInfo
            self.mUnRewardInfo = {}
            self.mRewardInfo = {}
            -- 整理数据
            local unRewardIdList = string.splitBySep(info.UnRewardChamberId, ",")
            local rewardIdList = string.splitBySep(info.RewardChamberId,",")
            for i,v in ipairs(unRewardIdList) do
                table.insert(self.mUnRewardInfo, tonumber(v))
            end
            for i,v in ipairs(rewardIdList) do
                table.insert(self.mRewardInfo, tonumber(v))
            end
            self:initUI()
        end,
    })
end

-- 获取奖励
function MeetXunbaoLayer:getReward()
    -- HttpClient:request({
    --     moduleName = "SectTask",
    --     methodName = "DrawChamberReward",
    --     svrMethodData = {},
    --     callback = function(response)
    --         -- 判断返回数据
    --         if not response or response.Status ~= 0 then
    --             return
    --         end
    --         dump(response.Value, "宝箱数据：")
    --         -- 飘窗展示奖励
    --         ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
    --         -- 整理数据
    --     end,
    -- })
    SectObj:getChamberBox(function()
        LayerManager.removeLayer(self)
    end)
end

--==========================触摸层==============================
function MeetXunbaoLayer:actionFuc(stepList)
    local tempX = 0 --单帧增量
    local tempY = 0 --单帧增量
    local stepNum = 1 --控制节点的计数
    local startPoint = cc.p(self.mHeroNode:getPosition()) --起始点
    local targetPoint = self.mEndPos --下一个点
    local walkLength = 0 --走的距离累计
    local isArrived = false --是否到达位置
    self.mHeroNode:scheduleUpdate(function(dt)
        if self.mPopSprite then
            self.mPopSprite:removeFromParent()
            self.mPopSprite = nil
        end
        --角色位置
        local playerPos = cc.p(self.mHeroNode:getPosition())
        local distanceStep = cc.pGetLength(cc.pSub(startPoint, targetPoint)) --一个节点的距离


        local lengthX = self.mEndPos.x - startPoint.x
        local lengthY = self.mEndPos.y - startPoint.y

        tempX = (4/distanceStep) * lengthX
        tempY = (4/distanceStep) * lengthY

        if self.mAnimationTag == 0 then
            self.playerSpine:setToSetupPose()
            self.playerSpine:setAnimation(0, "zou", true)
            if not self.mSoundEffectId then
                self.mSoundEffectId = MqAudio.playEffect("run.mp3", true)
            end
            self.mAnimationTag = 1
        end
        --检测下一个位置是不是墙(如果是就停止)
        local tarNextPos = self:posTransform(playerPos)
        local tarX = 0
        local tarY = 0
        if self.Direction == MoveDirection.eUp then
            tarY = 1
        elseif self.Direction == MoveDirection.eDown then
            tarY = -1
        elseif self.Direction == MoveDirection.eLeft then
            tarX = -1
        elseif self.Direction == MoveDirection.eRight then
            tarX = 1
        end

        local checkPos = self:formTransPos(cc.p(tarNextPos.x + tarX, tarNextPos.y + tarY))
        local isWall = self.starWorld:getPixelCollusion(checkPos)
        if isWall == 1 then
            self.mHeroNode:setPosition(checkPos)
        end
        local isStop = isWall == 2 or (math.abs(math.floor(self.mEndPos.x) - playerPos.x) <= 4 and math.abs(math.floor(self.mEndPos.y) - playerPos.y) <= 4) and true or false
        if isStop then
            self:IsRewarBtnPos(playerPos)
            self.mHeroNode:unscheduleUpdate()
            if self.mAnimationTag == 1 then
                self.playerSpine:setToSetupPose()
                self.playerSpine:setAnimation(0, "daiji", true)
                if self.mSoundEffectId then
                    MqAudio.stopEffect(self.mSoundEffectId)
                    self.mSoundEffectId = nil
                end
                self.mAnimationTag = 0
            end
        else
            self.mHeroNode:setPosition(playerPos.x + tempX, playerPos.y + tempY)
        end

        if tempX < 0 then
            self.playerSpine:setRotationSkewY(-180)
        elseif tempX > 0 then
            self.playerSpine:setRotationSkewY(360)
        end
    end)
end

--移动触摸函数
function MeetXunbaoLayer:setTouchMoveEvent()
    -- 触摸事件处理
    local moveTouchListenner = ui.registerSwallowTouch({
        node = self.mBgSprite,
        allowTouch = false,
        -- 滑动事件完成，不响应点击移动事件
        -- 处理不同尺寸的情况
        beganEvent = function (touch, event)
           return true
        end,

        movedEvent = function (touch, event)
        end,

        endedEvent = function (touch, event)
            local startPos = cc.p(self.mHeroNode:getPosition())
            self.mEndPos = cc.p(touch:getLocation().x/Adapter.MinScale, touch:getLocation().y/Adapter.MinScale)
            --判断方向
            local angle = self:getAngle(startPos, self.mEndPos)
            self.Direction = self:getDirection(angle)

            if self.Direction == MoveDirection.eUp or self.Direction == MoveDirection.eDown then
                self.mEndPos.x = startPos.x
            elseif self.Direction == MoveDirection.eLeft or self.Direction == MoveDirection.eRight then
                self.mEndPos.y = startPos.y
            end

            local isCouldMove = self.starWorld:getPixelCollusion(self.mEndPos)
            if isCouldMove == 2 then
                local heroformPos = self:posTransform(startPos)
                local centerformPos = self:posTransform(self.mEndPos)
            end
            self:moveAction(startPos, self.mEndPos)
        end,
    })
end
-- 移动动作
function MeetXunbaoLayer:moveAction(startPos, targetPos)
    local curPos = self:posTransform(startPos)
    local disPos = self:posTransform(targetPos)
     if curPos.x ~= disPos.x or curPos.y ~= disPos.y then
        self:actionFuc(moveWayList)
    else
    end
end

function MeetXunbaoLayer:formTransPos(indexPos)
    local itemSize = self.starWorld.itemSize
    return {x = (indexPos.x-0.5) * itemSize, y = (indexPos.y-0.5) * itemSize}
end

function MeetXunbaoLayer:posTransform(position)
    local itemSize = self.starWorld.itemSize
    local curPos = {x = math.ceil((position.x+0.5) / itemSize), y = math.ceil((position.y+0.5) / itemSize)}
    return curPos
end


--[[
    描述：计算两点间夹角
    参数：两个点
]]
function MeetXunbaoLayer:getAngle(p1, p2)
    local x = p2.x - p1.x
    local y = p2.y - p1.y
    local angle = math.atan2(y, x)*180/math.pi
    return angle
end
--[[
    描述：根据夹角获得方块移动方向
    参数：角度
]]
function MeetXunbaoLayer:getDirection(angle)
    if angle >= 45 and angle < 135 then
        return MoveDirection.eUp
    elseif (angle >= 135 and angle <= 180) or (angle < -135 and angle >= -180) then
        return MoveDirection.eLeft
    elseif angle >= -135 and angle < -45 then
        return MoveDirection.eDown
    elseif angle >= -45 and angle < 45 then
        return MoveDirection.eRight
    end
end


return MeetXunbaoLayer
