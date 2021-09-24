CPet = classGc(CBaseCharacter,function(self,_nType)
    self.m_nType=_nType --人物／npc
    self.m_stageView=_G.g_Stage
end)

CPet.resList={}

function CPet.petInit( self,_uid,_x,_y,_skinID,player)
    self.m_nMoveSpeedX=350
    self.m_nMoveSpeedY=150

    if _skinID>54100 and _skinID<54150 then
        self.m_nMoveSpeedX=300
        self.m_nMoveSpeedY=100
        self.m_data=_G.Cfg.wing_des[_skinID]
        _skinID=self.m_data.skin_id

        if self.m_data.fly==1 then
            self.setShadow=function() end
            self.addFlySpr=function() end
        end
    end
    self.onUpdateDead=function () end
    self:init(_uid,nil,nil,nil,nil,nil,_x,_y,_skinID)

    self.m_masterLastPos=cc.p(_x,_y)
    self.m_master=player
end

function CPet.showBody(self,_skinID)
    if _skinID==0 or self.m_lpContainer==nil then return end

    local szSpine=string.format("spine/%d",_skinID)
    if self.m_data~=nil then
        self.m_skinScale=self.m_data.scale/10000
    end
    
    self.m_szSpineName=szSpine

    local function nCall()
        if self.m_lpContainer==nil then return end

        self.m_lpMovieClip=_G.SpineManager.createSpine(szSpine,self.m_skinScale)
        if self.m_lpMovieClip==nil then
            CCLOG("codeError!!!! CPet skinID  : ".._skinID.." this loadError 2")
            return
        end
        self.m_lpMovieClip:setToSetupPose()
        self.m_lpMovieClipContainer:addChild(self.m_lpMovieClip)
        local function onCallFunc(event)
            self:animationCallFunc(event.type,event.animation,event)
            if event.animation=="idle" or event.animation=="move" then return end
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
        end

        self.m_lpMovieClip:registerSpineEventHandler(onCallFunc,2)

        local preStatus=self.m_nStatus
        self.m_nStatus=-100
        self:setStatus(preStatus)
    end

    cc.Director:getInstance():getTextureCache():addImageAsync(szSpine..".png",nCall)

    CCLOG("CPet.loadMovieClip success")
end

function CPet.setMoveClipContainerScalex( self, _ScaleX )
    self.m_nScaleX = _ScaleX
    self.m_lpCharacterContainer:setScaleX( _ScaleX )
end

function CPet.setStatus(self, _nStatus)
    if _nStatus == self.m_nStatus then
        return
    end

    if self.m_flySpr~=nil then
        if _nStatus~=_G.Const.CONST_BATTLE_STATUS_MOVE then
            self.m_flySpr:setAnimation(0,"idle",true)
        else
            self.m_flySpr:setAnimation(0,"move",true)
        end
    end
    self.m_nStatus=_nStatus

    if self.m_lpMovieClip==nil then return end

    local actionName=nil
    local loop=true
    if _nStatus == _G.Const.CONST_BATTLE_STATUS_IDLE then --站立,循环
        actionName="idle"
        if self.m_master and self.m_master.m_nScaleX ~= self.m_nScaleX then
            self:setMoveClipContainerScalex(self.m_master.m_nScaleX)
        end
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE then --移动,循环
        actionName="move"
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then
        actionName="skill"
        loop=false
    end
    if actionName~=nil then
        self.m_lpMovieClip:setAnimation(0,actionName,loop)
    end
end

-- function CPet.onUpdate( self )
--     self:onUpdateZOrder()
-- end

function CPet.setMovePos( self, _movePosX, _movePosY, ScaleX, stopStar)
    if _movePosX ~= nil then
        local moveX
        local moveY = _movePosY

        if stopStar and self.m_data then
            -- local scaleX=gc.MathGc:random_0_1()>0.5 and -1 or 1
            local randomX=math.random(0,200)
            if ScaleX > 0 then
                moveX=_movePosX-randomX
            else
                moveX=_movePosX+randomX
            end
            if self.m_data.fly==1 then
                local randomY=math.random(0,50)
                moveY=randomY+_movePosY
            else
                local randomY=math.random(0,50)
                moveY=_movePosY-randomY
            end
        else
            if ScaleX > 0 then
                moveX = _movePosX - 150
            else
                moveX = _movePosX + 150
            end 
            if _movePosX < self.m_stageView:getMaplx()+160 then
                moveX = _movePosX + 80       
            elseif _movePosX > self.m_stageView:getMaprx()-160 then
                moveX = _movePosX - 80
            end 
        end

        local max,min = _G.g_Stage:getMapLimitHeight(moveX)

        if moveY > min + 5 then
        	moveY = moveY - 5
        else
        	moveY = moveY + 5
        end

        self.m_lpMovePos=cc.p(self:convertLimitPos(moveX,moveY))
              
        if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_IDLE then
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)
        end
        if self.m_nLocationX<= self.m_lpMovePos.x then
            ScaleX = 1
        else
            ScaleX = -1
        end
        if self.m_nScaleX ~= ScaleX then
            self:setMoveClipContainerScalex(ScaleX)
        end
    end
end

function CPet.releaseResource( self )
    if self.m_lpContainer~=nil then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
    self.m_szSpineName=nil
end

function CPet.setScalePer(self)
end
