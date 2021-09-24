CNpc = classGc(function( self, _nType )
    self.m_nType=_nType --人物／npc
    self.m_taskStatesList = {}
end)

local DISTANCE_RADIUS=_G.Const.CONST_TASK_TALK_DISTANCE --玩家进入半径范围

function CNpc.npcInit( self,uid, npcId , npcName, npcPx , npcPy , npcSkin )
    self.m_nID=uid
    self.m_SkinId=npcId 

    self.m_bRoleEnter=false     --玩家是否进入

    self.m_lpContainer = cc.Node:create() --总层
    local shadowSprite = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    self.m_lpContainer:addChild(shadowSprite)

    self:setLocationXY(npcPx,npcPy)

    self.npcId=npcId

    -- self.m_skeletonHeight=225
    self:showBody(npcSkin)
    self:setName(npcName)

    self:initNpcStateIcon()
end
function CNpc.npcPlotInit(self,npcName,npcPx,npcPy,npcSkin)
    self.m_lpContainer = cc.Node:create() --总层
    local shadowSprite = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    self.m_lpContainer:addChild(shadowSprite)
    self:setLocationXY(npcPx,npcPy)
    -- self.m_skeletonHeight=225
    self:showBody(npcSkin)
    self:setName(npcName)


    if _G.g_Stage.m_lpMapData.id==10402 then
        self:addFlySpr()
    end
end
--添加飞云
function CNpc.addFlySpr( self )
    local spr=_G.SpineManager.createSpine("map/10402_tsp_02")
    self.m_lpContainer:addChild(spr)
    spr:setScaleX(-1)
    spr:setAnimation(0,"idle",false)
end

-- function CNpc.setStage(self,_lpStage)
    
-- end

function CNpc.setLocationXY( self, _x, _y )
    self.m_nLocationX,self.m_nLocationY=_x,_y
    self.m_lpContainer:setPosition(cc.p(_x,_y))
end

function CNpc.getLocationXY( self )
    return self.m_nLocationX, self.m_nLocationY
end

function CNpc.setName( self, _szName )
    if _szName == nil then
        return
    end
    self.m_szName = _szName or ""

    if self.m_lpName ~= nil then
        self.m_lpName : removeFromParent( true )
        self.m_lpName = nil
    end
    
    local color = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
    self.m_lpName = _G.Util:CreateTraceLabel( self.m_szName, 24, 1, color )
    self.m_lpName : setPosition(0,self.m_skeletonHeight+15)
    self.m_lpContainer : addChild( self.m_lpName )
end

function CNpc.touchSelf(self,_mainPlayer)
    local fRoleX,fRoleY=_mainPlayer:getLocationXY()
    local npcPosX,npcPosY=self:getLocationXY()
    if math.abs(npcPosX-fRoleX)>DISTANCE_RADIUS 
        or math.abs(npcPosY-fRoleY)>DISTANCE_RADIUS then
        local nPos    =cc.p( self:getLocationXY() )
        local realPos =_G.GTaskProxy:getMoveToNpcRandomPos( nPos )
        _mainPlayer:findTaskNPC( realPos, self.npcId, true )
    else
        self:createTaskDialog(self.npcId,true)
    end
end

function CNpc.showBody(self,_skinID)
    -- local nScale=0.45
    self.m_npcSpine=_G.SpineManager.createNpc(_skinID)
    if self.m_npcSpine==nil then
        CCLOG("RES ERROR CNpc.showBody plistName=%s",_skinID)
        local movBy1=cc.MoveBy:create(0.2,cc.p(0,30))
        local movBy2=cc.MoveBy:create(0.2,cc.p(0,-30))
        self.m_npcSpine=cc.Sprite:createWithSpriteFrameName("general_box_choice.png")
        self.m_npcSpine:setPosition(0,70)
        self.m_npcSpine:runAction(cc.RepeatForever:create(cc.Sequence:create(movBy1,movBy2)))
        self.m_lpContainer:addChild(self.m_npcSpine)
        return
    end
    self.m_lpContainer:addChild(self.m_npcSpine)
    if _skinID == 20542 then
        self.m_npcSpine:setAnimation(0,"idle3",true)
    else
        self.m_npcSpine:setAnimation(0,"idle",true)
    end

    -- if self.m_npcSpine~=nil and self.m_npcSpine.getSkeletonSize~=nil then
    --     self.m_skeletonHeight=self.m_npcSpine:getSkeletonSize().height*nScale
    -- end
    local skinDate = _G.g_SkillDataManager:getSkinData(_skinID)
    if skinDate == nil then
        print("lua error NPC no skinDate")
        skinDate = _G.g_SkillDataManager:getSkinData(10001)
    end
    self.m_skeletonHeight = skinDate.nameh

    -- CCLOG("CNpc.loadMovieClip success")
end
function CNpc.setMoveClipContainerScalex(self,_scale)
    if self.m_npcSpine then
        self.m_npcSpine:setScaleX(_scale)
    end
end

function CNpc.releaseResource( self )
    if self.m_lpContainer then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
end

function CNpc.initNpcStateIcon( self )

    -- print( "initNpcStateIcon",_G.GTaskProxy )
    --初始化npc头上的图标
    if _G.GTaskProxy :getInitialized() then
        local taskData  = _G.GTaskProxy : getTaskDataList() or {}
        -- print("initNpcStateIcon start",#taskData)

        for key, _taskData in ipairs( taskData ) do
            local taskBeginNpc = _taskData.sNpc
            local taskEndNpc   = _taskData.eNpc
            -- print("--->>",taskBeginNpc,taskEndNpc,_taskData.state)

            if _taskData.state >= _G.Const.CONST_TASK_STATE_ACCEPTABLE and (taskBeginNpc == self.npcId or taskEndNpc == self.npcId) then
                if (taskBeginNpc == taskEndNpc)
                    or (_taskData.state <= _G.Const.CONST_TASK_STATE_UNFINISHED and taskBeginNpc == self.npcId)
                    or (_taskData.state > _G.Const.CONST_TASK_STATE_UNFINISHED and taskEndNpc == self.npcId) then
                    self :addOneNpcIconState( _taskData )
                end
            end
        end
    end
end

function CNpc.addOneNpcIconState( self, _taskData )
    -- CCLOG("CNpc.addOneNpcIconState  %d,  %d,  %d ",_taskData.type,_taskData.state,_taskData.id)
    self.m_taskStatesList[_taskData.id] = _taskData.state
    if self.m_iconContainer == nil or _taskData.type == _G.Const.CONST_TASK_TYPE_MAIN then
        --主线优先
        self :setTaskIcon( _taskData.id,_taskData.state )
    end
end

function CNpc.updateNpcIconState( self, _taskId, _taskState )
    -- CCLOG("CNpc.updateNpcIconState  ".._taskId.."    "..self.npcId)
    self.m_taskStatesList[_taskId] = _taskState
    self :setTaskIcon( _taskId,_taskState )

    if _taskState == nil then
        -- print("updateNpcIconState next()->",next(self.m_taskStatesList))
        if next(self.m_taskStatesList) then
            local nextId, nextState = next(self.m_taskStatesList)
            self :setTaskIcon( nextId,nextState )
        -- else
        --     CCLOG("no taskState here ~~~~~~")
        end
    end
end

function CNpc.searchThisTaskNow( self, _taskId )
    -- print("searchThisTaskNow---->>>",_taskId)
    if self.m_taskStatesList[_taskId] then
        self :setTaskIcon( _taskId,self.m_taskStatesList[_taskId] )
    end
end

--增加npc任务icon
function CNpc.setTaskIcon( self , _taskId, _taskState )
    -- print("setTaskIcon---->>>>",_taskId,_taskState)
    if self.m_iconContainer then    --清除容器
        self.m_iconContainer : removeFromParent(true)
        self.m_iconContainer = nil
    end
    if not _taskState then return end

    local nY = self.m_nLocationY

    -- print("图标_taskState:",_taskState, self.m_nID)
    local iconName = nil
    if _taskState == _G.Const.CONST_TASK_STATE_ACCEPTABLE then     -- 任务状态-可接受 (2)   黄色
        iconName = "main_task_state_yelly1.png"
    elseif _taskState == _G.Const.CONST_TASK_STATE_UNFINISHED then     -- 任务状态-接受未完成 (3)
        iconName = "main_task_state_black2.png"
    elseif _taskState == _G.Const.CONST_TASK_STATE_FINISHED then       -- 任务状态-完成未提交 (4)
        local nType=_G.Cfg.task[_taskId].type
        if nType==_G.Const.CONST_TASK_TYPE_MAIN then
            iconName = "main_task_state_yelly2.png"
        else
            iconName = "main_task_state_green2.png"
        end
    end

    if iconName ~= nil then -- 如果有对应的图标
        --增加icon 容器
        local taskIcon = cc.Sprite:createWithSpriteFrameName(iconName)
        self.m_iconContainer = cc.Node:create()
        self.m_iconContainer : setPositionY ( self.m_skeletonHeight+25 )
        self.m_iconContainer : addChild( taskIcon )
        self.m_lpContainer : addChild ( self.m_iconContainer, 10 )

        -- local actionTimes=0.3
        -- local rotate=25
        local seq=cc.Sequence:create(   cc.ScaleTo:create(0.1,1.3),
                                        cc.ScaleTo:create(0.1,1),
                                        -- cc.RotateTo:create(actionTimes,-rotate),
                                        -- cc.RotateTo:create(actionTimes*2,rotate),
                                        -- cc.RotateTo:create(actionTimes,0),
                                        cc.DelayTime:create(3)
                                    )
        taskIcon :setAnchorPoint(cc.p(0.5,0))
        taskIcon :runAction( cc.RepeatForever:create( seq ) )

    end
end

function CNpc.checkZone(self,_fRoleX,_fRoleY,_isTouch)
    if math.abs(self.m_nLocationX - _fRoleX) > DISTANCE_RADIUS 
        or math.abs(self.m_nLocationY - _fRoleY) > DISTANCE_RADIUS then
        return false
    end
    self:createTaskDialog(self.npcId,_isTouch)
    return true
end


function CNpc.createTaskDialog( self, _npcId, _isTouch )
    _G.GLayerManager:openTaskDialog( _npcId, _isTouch )
end

-- function CNpc.createAskTaskDialog( self, _npcId )
--     print("createAskTaskDialog---->>>",_npcId)
--     if _npcId == nil or (_G.g_CAskTastDialogView:getNpcId() ~= nil and _G.g_CAskTastDialogView:getNpcId() == _npcId) then
--         return
--     end
--     _G.g_CAskTastDialogView:create( _npcId )
-- end

-- function CNpc.removeTaskDialog( self )
    -- _G.g_CAskTastDialogView:remove()
-- end




