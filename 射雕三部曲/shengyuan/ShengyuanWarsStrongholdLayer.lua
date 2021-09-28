--[[
	文件名: ShengyuanWarsStrongholdLayer.lua
	描述: 圣渊普通据点界面
	创建人: peiyaoqiang
	创建时间: 2017.08.31
--]]

local ShengyuanWarsStrongholdLayer = class("ShengyuanWarsStrongholdLayer", function(params)
    return display.newLayer()
end)

--[[
    params:
    Table params:
    {
    }
--]]
function ShengyuanWarsStrongholdLayer:ctor()
    self.mCurPointId     = ShengyuanWarsHelper.enterResInfo.PointId
    self.mOurPlane       = {} -- 保存我方飞机列表
    self.mEnemyPlane     = {} -- 保存敌方飞机列表
    self.mLastPlayerList = {} -- 保存刷新之前 mCurrentPlayerList 刷新飞机后更新
    self.mCurrPlayerList = ShengyuanWarsHelper:getEnterResInfo(self.mCurPointId) -- 当前节点玩家列表

    -- 创建背景
    local bgSprite = ui.newSprite("jzthd_25.jpg")
    bgSprite:setPosition(display.cx, display.cy)
    bgSprite:setScale(Adapter.MinScale)
    self:addChild(bgSprite)
    self.bgSprite = bgSprite
    
    -- 神符提示文字
    self.mRollNameLabel = ui.newLabel({
        text = "",
        size = 26,
        color= Enums.Color.eYellow,
        outlineColor = Enums.Color.eBlack,
    }):addTo(self.bgSprite):setPosition(cc.p(320, 455))
    
    -- 初始化界面
    self:setUI()

    -- 刷新页面
    self:refreshLayer()
    -- 刷新飞机
    self:refreshPlane()
end

function ShengyuanWarsStrongholdLayer:setUI()
    -- 创建导航栏
    local topBgSprite = ShengyuanWarsUiHelper:addTopInfoBar(
        {
            parent = self.bgSprite, 
            pos = cc.p(320, 1136), 
            closeAction = function ()
                ShengyuanWarsHelper:quitPoint(ShengyuanWarsHelper.enterResInfo.PointId, function() end)
            end
        })
    self.ourResLabel         = topBgSprite:addResLabel(cc.p(0.2, 0.75))
    self.otherResLabel       = topBgSprite:addResLabel(cc.p(0.55, 0.75))
    self.resRemainTimeLabel  = topBgSprite:addResLabel(cc.p(0.2, 0.5))
    self.buffRemainTimeLabel = topBgSprite:addResLabel(cc.p(0.2, 0.25))
    self.topBgSprite = topBgSprite

    -- 创建底部技能栏
    local buttomBgSprite = cc.LayerColor:create(cc.c4b(100, 100, 0 , 0))
    local buttomBgSize = cc.size(640,120)
    buttomBgSprite:setContentSize(buttomBgSize)
    buttomBgSprite:setAnchorPoint(cc.p(0,0))
    buttomBgSprite:setPosition(cc.p(0,0))
    buttomBgSprite:setScale(Adapter.MinScale)
    self:addChild(buttomBgSprite)
    -- 创建技能图标
    ShengyuanWarsUiHelper:createSKillBtn({parent = buttomBgSprite, range = 1})

    -- 重置资源Label显示
    local function resetResLabel()
        self.ourResLabel:resetResString(true)
        self.otherResLabel:resetResString(false)
    end

    -- 倒计时刷新回调
    local function valueActionUpdate(dt)
        resetResLabel()
        
        self.resRemainTimeLabel:resetBuffString(false)
        self.buffRemainTimeLabel:resetBuffString(true)

        -- 刷新神符的显示
        local enterResInfo = ShengyuanWarsHelper.enterResInfo
        if (enterResInfo.BuffNum == 0) or (enterResInfo.Status == 2) then 
            if (ShengyuanWarsHelper.buffRemainTime > 0) then
                self.mRollNameLabel:setString(TR("%d秒后将会随机出现新的神符", ShengyuanWarsHelper.buffRemainTime))
            else
                self.mRollNameLabel:setString("")
            end
            -- 没有这句的话，如果新神符与之前的神符一样，会导致该Label显示为空不再刷新出来
            -- 有时候 buffRemainTime 会从1直接变成89，导致设成空字符串的代码没执行到，所以要在这里确保万一
            self.mRollNameLabel.buffId = nil
        else
            local newBuffId = enterResInfo.BuffId
            if (self.mRollNameLabel.buffId == nil) or (self.mRollNameLabel.buffId ~= newBuffId) then
                local buffModel = ShengyuanwarsBuffModel.items[newBuffId]
                if (buffModel ~= nil) then
                    self.mRollNameLabel:setString(buffModel.name .. ":" .. buffModel.intro)
                    self.mRollNameLabel.buffId = newBuffId
                end
            end
        end
    end
    valueActionUpdate(nil)

    -- 显示倒计时
    Utility.schedule(self.topBgSprite, valueActionUpdate, 0.2)
    
    ------------------------------------------------------------
    -- 注册相关的通知事件
    local function registerNotificationCallback(events, action)
        Notification:registerAutoObserver(ShengyuanWarsUiHelper:getOneEmptyNode(self), action, events)
    end

    -- 当前资源点数据变化
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsResInfo},
        function (node, resData)
            self:refreshLayer()
        end)

    -- 某玩家进入或退出了资源点
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsEnterOrQuiteRes},
        function (node, resData)
            -- 如果是自己退出的消息，就关闭当前页面
            if (resData.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) and (resData.IsEnter == false) then
                self.topBgSprite:stopAllActions()
                self:stopTimeSchedule()
                LayerManager.removeLayer(self)
                return
            end

            if resData.PointId == self.mCurPointId then
                self.mCurrPlayerList = ShengyuanWarsHelper:getEnterResInfo(ShengyuanWarsHelper.enterResInfo.PointId)
                self:refreshLayer()
                self:refreshPlane()
            end
        end)

    -- 发生了战斗
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsFightOver},
        function (node, resData)
            -- 获取死亡的玩家ID
            local deathId = resData.isWin and resData.targetPlayerId or resData.attackPlayerId
            local winId   = resData.isWin and resData.attackPlayerId or resData.targetPlayerId

            -- 五毒散
            self:resetPlayerBuff(resData.targetPlayerId)
            self:resetPlayerBuff(resData.attackPlayerId)
            
            -- 如果是自己死亡，则退出页面
            if deathId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                LayerManager.removeLayer(self)
                return
            end

            -- 显示击杀提示
            ShengyuanWarsUiHelper:showKillFlash(self, winId)
            
            -- 刷新页面
            self.mCurrPlayerList = ShengyuanWarsHelper:getEnterResInfo(ShengyuanWarsHelper.enterResInfo.PointId)
            self:refreshLayer()
            self:refreshPlane()
        end)

    -- 比赛结束
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsFightResult},
        function (node, info)
            -- 停止倒计时
            self.topBgSprite:stopAllActions()
            resetResLabel()
            self.resRemainTimeLabel:setString(TR("本场比赛已结束"))

            -- 比赛结束
            ShengyuanWarsUiHelper:showEndPopLayer(info)
        end)

    -- 神符刷新
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsResBuffChanged},
        function ()
            self:refreshLayer()
        end)

    -- 玩家buff状态变化
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsPlayerBuffChanged},
        function (node, playerId)
            self:resetPlayerBuff(playerId)
        end)
end

-- 刷新据点
function ShengyuanWarsStrongholdLayer:refreshLayer()
    -- 获取神符的按钮
    if not self.mGetBtn then
        self.mGetBtn = ui.newButton({
            normalImage = "jzthd_48.png",
            position    = cc.p(330, 530),
            }):addTo(self.bgSprite)
    end
    self.mGetBtn:setVisible(self:checkGetBtnVisible())
    self:setGetBtnAction()

    -- 如果正在占领资源点
    self:stopTimeSchedule()
    if ShengyuanWarsHelper.enterResInfo.Status == 1 then
        self:beginTimeSchedule()
    end
end

-- 刷新飞机
function ShengyuanWarsStrongholdLayer:refreshPlane()
    local function createPlaneList(planeList, currPlayerList, lastPlayerList, posList)
        -- 没有飞机，第一次创建
        if next(planeList) == nil then
            for k, id in ipairs(currPlayerList or {}) do
                local planInfo = {}
                planInfo.Id = id
                planInfo.plan = self:addPlane(planInfo.Id, posList[k])
                table.insert(planeList, planInfo)
            end
        else
            -- 先删除
            local delList = ShengyuanWarsUiHelper:getTeamDelList(currPlayerList, lastPlayerList)
            ShengyuanWarsUiHelper:deletePlaneInTeam(planeList, delList)

            -- 再添加
            local addList = ShengyuanWarsUiHelper:getTeamAddList(currPlayerList, lastPlayerList)
            ShengyuanWarsUiHelper:addPlaneToTeam(self, planeList, addList, posList)
        end
    end

    -- 判断是否属于B队 自己队伍显示在下方
    if ShengyuanWarsHelper.myTeamName and (ShengyuanWarsHelper.myTeamName == ShengyuanWarsHelper.teamB) then        
        createPlaneList(self.mOurPlane, self.mCurrPlayerList.B, self.mLastPlayerList.B, ShengyuanWarsUiHelper.planePos.Our)
        createPlaneList(self.mEnemyPlane, self.mCurrPlayerList.A, self.mLastPlayerList.A, ShengyuanWarsUiHelper.planePos.Enemy)
    else
        createPlaneList(self.mOurPlane, self.mCurrPlayerList.A, self.mLastPlayerList.A, ShengyuanWarsUiHelper.planePos.Our)
        createPlaneList(self.mEnemyPlane, self.mCurrPlayerList.B, self.mLastPlayerList.B, ShengyuanWarsUiHelper.planePos.Enemy)
    end
    
    -- 保存人物列表
    self.mLastPlayerList = clone(self.mCurrPlayerList)
end

-- 开启吃符的定时器
function ShengyuanWarsStrongholdLayer:beginTimeSchedule()
    self:stopTimeSchedule()

    -- 剩余时间的Label
    self.mRemainTimeLabel = ui.newLabel({
        text = "",
        size = 26,
        x = 320,
        y = 545,
        color= cc.c3b(0xF6, 0xD9, 0x08),
        outlineColor = Enums.Color.eBlack,
        }):addTo(self.bgSprite)

    -- 吃符进度条
    local maxNeedTime = 0
    for _, v in ipairs(ShengyuanWarsHelper.allResList) do
        if v.PointId == ShengyuanWarsHelper.enterResInfo.PointId then
            maxNeedTime = ShengyuanwarsBuffModel.items[v.BuffId].getBuffNeedTime
            break
        end
    end
    self.mTimeProgress = require("common.ProgressBar"):create({
        bgImage = "fb_17.png",
        barImage = "fb_18.png",
        currValue = 0,
        maxValue = maxNeedTime,
        percentView = false,
        outlineColor = Enums.Color.eBlack,
    })
    self.mTimeProgress:setPosition(320, 500)
    self.bgSprite:addChild(self.mTimeProgress)

    -- 刷新显示
    local function resetTimeLabel()
        local currTime = ShengyuanWarsHelper.enterResInfo.Time
        if ShengyuanWarsUiHelper:checkPlayerSide() == ShengyuanWarsUiHelper.sideType.Our then
            self.mRemainTimeLabel:setString(TR("我方正在获取，剩余时间%s秒", currTime))
        else
            self.mRemainTimeLabel:setString(TR("敌方正在获取，剩余时间%s秒", currTime))
        end
        self.mTimeProgress:setCurrValue(maxNeedTime - currTime)
    end
    resetTimeLabel()

    -- 开启定时器
    Utility.schedule(self.mRollNameLabel, function ()
            if (ShengyuanWarsHelper.enterResInfo.Time == nil) or (ShengyuanWarsHelper.enterResInfo.Time < 0) then
                self.mRollNameLabel:setString("")
                self.mRollNameLabel.buffId = nil
                self:stopTimeSchedule()
            else
                resetTimeLabel()
            end
        end, 0.2)
end

-- 关闭吃符的定时器
function ShengyuanWarsStrongholdLayer:stopTimeSchedule()
    self.mRollNameLabel:stopAllActions()
    
    if self.mTimeProgress ~= nil then
        self.mTimeProgress:removeFromParent()
        self.mTimeProgress = nil
    end

    if self.mRemainTimeLabel ~= nil then
        self.mRemainTimeLabel:removeFromParent()
        self.mRemainTimeLabel = nil
    end
end

------------------------------------------辅助函数------------------------------------------------

-- 创建一个飞机
function ShengyuanWarsStrongholdLayer:addPlane(playerId, position)
    local planeNode = nil
    planeNode = ShengyuanWarsUiHelper:createHero(playerId, {scale = 0.7, showShenfu = true, 
            clickAction = function ()
                if (planeNode.isShowVisible == nil) or (planeNode.isShowVisible == false) then
                    planeNode:showCtrlBtn(true)
                else
                    planeNode:showCtrlBtn(false)
                end
            end
        })
    planeNode:setPosition(position)
    self.bgSprite:addChild(planeNode)
    return planeNode
end

-- 查找某个玩家的飞机
function ShengyuanWarsStrongholdLayer:findPlane(playerId)
    local playerInfo = ShengyuanWarsHelper:getPlayerData(playerId)
    if (playerInfo.CurPointId ~= self.mCurPointId) then 
        return nil
    end

    local function findPlayerNode(planeList)
        local tmpNode = nil
        for _, v in ipairs(planeList) do
            if v.Id == playerId then
                tmpNode = v.plan
                break
            end
        end
        return tmpNode
    end
    return (playerInfo.TeamName == ShengyuanWarsHelper.myTeamName) and findPlayerNode(self.mOurPlane) or findPlayerNode(self.mEnemyPlane)
end

-- 刷新某个玩家的Buff显示
function ShengyuanWarsStrongholdLayer:resetPlayerBuff(playerId)
    local tmpNode = self:findPlane(playerId)
    if (tmpNode == nil) then
        return
    end

    if tmpNode.refreshHpBar then
        tmpNode:refreshHpBar()
    end
    if tmpNode.refreshBuff then
        tmpNode:refreshBuff(true)
    end
end

-- 判断是否显示获取按钮
function ShengyuanWarsStrongholdLayer:checkGetBtnVisible()
    local flag = false

    if ShengyuanWarsHelper.enterResInfo.BuffNum == 0 then
        -- 没有道具
    else
        if ShengyuanWarsHelper.enterResInfo.Status == 0 then
            flag = true
        end
        if ShengyuanWarsHelper.enterResInfo.Status == 1 then
            if ShengyuanWarsUiHelper:checkPlayerSide() == ShengyuanWarsUiHelper.sideType.Enemy then
                -- 敌方占领
                flag = true
            end
        end
    end

    return flag
end

-- 获取按钮的点击事件处理
function ShengyuanWarsStrongholdLayer:setGetBtnAction()
    if not self.mGetBtn then 
        return 
    end
    if not self:checkGetBtnVisible() then 
        return 
    end

    -- 有无敌方飞机
    if ShengyuanWarsHelper.myTeamName and ShengyuanWarsHelper.myTeamName == ShengyuanWarsHelper.teamB then
        if self.mCurrPlayerList.A and next(self.mCurrPlayerList.A) then
            self.mGetBtn:setClickAction(function()
                ui.showFlashView(TR("请先打败所有敌人"), 1.5)
            end)
        else
            self.mGetBtn:setClickAction(function()
                ShengyuanWarsHelper:occupyPoint(ShengyuanWarsHelper.enterResInfo.PointId, function()
                    end)
            end)
        end
    else
        if self.mCurrPlayerList.B and next(self.mCurrPlayerList.B) then
            self.mGetBtn:setClickAction(function()
                ui.showFlashView(TR("请先打败所有敌人"), 1.5)
            end)
        else
            self.mGetBtn:setClickAction(function()
                ShengyuanWarsHelper:occupyPoint(ShengyuanWarsHelper.enterResInfo.PointId, function()
                    end)
            end)
        end
    end
end

return ShengyuanWarsStrongholdLayer