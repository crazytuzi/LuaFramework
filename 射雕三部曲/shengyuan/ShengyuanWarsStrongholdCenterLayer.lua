--[[
    文件名: ShengyuanWarsStrongholdCenterLayer.lua
    描述: 圣渊中心据点界面
    创建人: peiyaoqiang
    创建时间: 2017.08.31
--]]

local ShengyuanWarsStrongholdCenterLayer = class("ShengyuanWarsStrongholdCenterLayer", function(params)
    return display.newLayer()
end)

--[[
    params:
    Table params:
    {
    }
--]]
function ShengyuanWarsStrongholdCenterLayer:ctor()
    self.mOurPlane       = {} -- 保存我方飞机列表
    self.mEnemyPlane     = {} -- 保存敌方飞机列表
    self.mLastPlayerList = {} -- 保存刷新之前 mCurrPlayerList 刷新飞机后更新
    self.mCurrPlayerList = ShengyuanWarsHelper:getEnterResInfo(ShengyuanWarsHelper.enterResInfo.PointId) -- 当前节点玩家列表
    self.mCurPointId     = ShengyuanWarsHelper.enterResInfo.PointId

    -- 创建背景
    local bgSprite = ui.newSprite("jzthd_24.jpg")
    bgSprite:setPosition(display.cx, display.cy)
    bgSprite:setScale(Adapter.MinScale)
    self:addChild(bgSprite)
    self.bgSprite = bgSprite

    -- 创建下部门
    local doorSprite = ui.newSprite("jzthd_77.png")
    doorSprite:setPosition(0, 0)
    doorSprite:setAnchorPoint(0, 0)
    bgSprite:addChild(doorSprite, 1)

    -- 将自己的位置向上+70
    self.plansPoss = clone(ShengyuanWarsUiHelper.planePos)
    for key,value in pairs(self.plansPoss) do
        if key == "Our" then
            for _,pos in ipairs(value) do
                pos.y = pos.y + 70
            end
        end
    end
    
    -- 初始化界面
    self:setUI()

    -- 刷新页面
    self:refreshLayer()
    -- 刷新飞机
    self:refreshPlane()
end

function ShengyuanWarsStrongholdCenterLayer:setUI()
    -- 创建导航栏
    local topBgSprite = ShengyuanWarsUiHelper:addTopInfoBar(
        {
            parent = self.bgSprite, 
            pos = cc.p(320, 1136), 
            closeAction = function ()
                ShengyuanWarsHelper:quitPoint(ShengyuanWarsHelper.enterResInfo.PointId, function() end)
            end
        })
    self.ourResLabel =          topBgSprite:addResLabel(cc.p(0.2, 0.75))
    self.otherResLabel =        topBgSprite:addResLabel(cc.p(0.55, 0.75))
    self.resRemainTimeLabel =   topBgSprite:addResLabel(cc.p(0.2, 0.5))
    self.buffRemainTimeLabel =  topBgSprite:addResLabel(cc.p(0.2, 0.25))
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
    end
    valueActionUpdate(nil)

    -- 显示倒计时
    Utility.schedule(self.topBgSprite, valueActionUpdate, 0.2)
    
    ------------------------------------------------------------
    -- 注册相关的通知事件
    local function registerNotificationCallback(events, action)
        Notification:registerAutoObserver(ShengyuanWarsUiHelper:getOneEmptyNode(self), action, events)
    end
    
    -- 某玩家进入或退出了资源点
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsEnterOrQuiteRes}, 
        function (node, resData)
            -- 当自己收到退出消息时，关闭当前界面
            if (resData.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) and (resData.IsEnter == false) then
                self.topBgSprite:stopAllActions()
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
            
            -- 如果是自己死亡，就退出页面
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
    
    -- 玩家buff状态变化
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsPlayerBuffChanged},
        function (node, playerId)
            self:resetPlayerBuff(playerId)
        end)
end

-- 刷新据点
function ShengyuanWarsStrongholdCenterLayer:refreshLayer() 
    -- 对战提示图片
    if not self.mFightSprite then
        self.mFightSprite = ui.newSprite("zdfb_31.png")
        self.mFightSprite:setScale(1.5)
        self.mFightSprite:setPosition(330, 540)
        self.bgSprite:addChild(self.mFightSprite)
    end
end

-- 刷新飞机
function ShengyuanWarsStrongholdCenterLayer:refreshPlane()
    local function createPlaneList(planeList, currPlayerList, lastPlayerList, posList, addPosY)
        -- 没有飞机，第一次创建
        if next(planeList) == nil then
            for k, id in ipairs(currPlayerList or {}) do
                local pos = posList[k]
                if (addPosY ~= nil) and (addPosY == true) then
                    pos = cc.p(posList[k].x, posList[k].y)
                end

                local planInfo = {}
                planInfo.Id = id
                planInfo.plan = self:addPlane(planInfo.Id, pos)
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
        createPlaneList(self.mOurPlane, self.mCurrPlayerList.B, self.mLastPlayerList.B, self.plansPoss.Our, true)
        createPlaneList(self.mEnemyPlane, self.mCurrPlayerList.A, self.mLastPlayerList.A, self.plansPoss.Enemy)
    else
        createPlaneList(self.mOurPlane, self.mCurrPlayerList.A, self.mLastPlayerList.A, self.plansPoss.Our, true)
        createPlaneList(self.mEnemyPlane, self.mCurrPlayerList.B, self.mLastPlayerList.B, self.plansPoss.Enemy)
    end

    -- 保存人物列表
    self.mLastPlayerList = clone(self.mCurrPlayerList)
end

------------------------------------------辅助函数------------------------------------------------

-- 创建一个飞机
function ShengyuanWarsStrongholdCenterLayer:addPlane(playerId, position)
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
function ShengyuanWarsStrongholdCenterLayer:findPlane(playerId)
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
function ShengyuanWarsStrongholdCenterLayer:resetPlayerBuff(playerId)
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

return ShengyuanWarsStrongholdCenterLayer