CPartner = classGc(CMonster,function(self,_nType)
    self.m_nType=_nType --CONST_PARTNER 2 伙伴
    self.m_stageView=_G.g_Stage

    self.m_boss=nil  --老板
    self:initAI()
end)

CPartner.resList={}

function CPartner.partnerInit( self, _property )
    local playerCharacter = _G.CharacterManager : getPlayerByID(_property:getUid())
    local attribute = _property : getAttr()
    self.m_partnerId=_property : getPartnerId()
    self:setProperty(_property)

    local pData = _G.Cfg.partner_init[self.m_partnerId]
    if pData ~= nil then
        self.m_nMoveSpeedX = pData.f.speedx
        self.m_nMoveSpeedY = pData.f.speedy
        self.m_scale       = pData.scale/10000
    end

    local locationX = 10
    local locationY = 10
    if playerCharacter~=nil then
        locationX=playerCharacter.m_nLocationX
        locationY=playerCharacter.m_nLocationY
    end

    self.m_patrolRatio=0
    -- self.m_scale=1
    self : init(tostring(_property : getUid())..tostring(_property : getPartner_idx()),
                _property : getName(),
                attribute: getMaxHp(),
                attribute: getHp(),
                attribute: getSp(),
                attribute: getSp(),
                locationX,
                locationY,
                _property : getSkinArmor())

    self.m_nLv = _property:getLv() or 1

    self.m_fBossMaxDistance=_G.Const.CONST_WAR_PARTNER_DISTANCE
    self.m_noTargetFollowMax=170*170
    self.m_noTargetFollowMin=6000

    -- self.m_lpContainer:setScale(0.75)

    self.m_fLastTraceTime=0
    self.m_fTraceInterval=3000
    self:setWarAttr(attribute)
    CCLOG("CPartner.partnerInit ")
end

function CPartner.showBody(self,_skinID)

    if self.m_lpContainer==nil or _skinID==nil or _skinID==0 then return end
    -- self.m_lpMovieClipContainer:setPosition(cc.p(0,0))

    local function onCallFunc(event)
        self:animationCallFunc(event.type,event.animation)
    end

    local skinIdStr = "spine/".._skinID

    self.m_lpMovieClip=_G.SpineManager.createSpine(skinIdStr,self.m_skinScale)

    if self.m_lpMovieClip==nil then
        -- print("lua error CPlayer.showBody self.m_normalName=",skinIdStr)
        self.m_lpMovieClip=_G.SpineManager.createSpine("spine/20001",self.m_skinScale)
        -- self.m_isNoRes=true
    end
    self.m_lpMovieClip:registerSpineEventHandler(onCallFunc,2)
    self.m_lpMovieClipContainer:addChild(self.m_lpMovieClip)

    self.m_skeletonHeight=self.m_lpMovieClip:getSkeletonSize().height*self.m_skinScale
    self.m_nStatus = -100
    self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
    -- self.evade=function() end

    CCLOG("CPartner.loadMovieClip success")
end

function CPartner.setName( self, _szName)
    if _szName == nil then return end
    print("_szName",_szName)

    self.m_lpName=_G.Util:createBorderLabel(_szName,23)
    self.m_lpName:setPosition(0,self.m_skeletonHeight)
    self.m_lpNameContainer:addChild( self.m_lpName )
    
    if self:getProperty():getTeamID()~=0 then
        self.m_lpName:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
    end
end

function CPartner.releaseResource( self )
    self:releaseSkillResource()
    self:removeAllClones()
    if self.m_lpContainer~=nil then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
    self:destoryBigHpView()
    
    GCLOG("CPartner.releaseResource====>>>>self.m_nID=%d",self.m_nID)
end

function CPartner.followBoss( self)
    local deltaX=math.random(0,150)+80
    local deltaY=math.random(0,60)

    local moveX =self.m_boss.m_nLocationX+(math.random()>0.5 and deltaX or -deltaX)
    local moveY =self.m_boss.m_nLocationY+(math.random()>0.5 and deltaY or -deltaY)

    self:setMovePos(cc.p(moveX,moveY))
end

function CPartner.noTargetFollow( self )
    local _movePosX = self.m_boss.m_nLocationX
    local _movePosY = self.m_boss.m_nLocationY 
    local ScaleX = self.m_boss.m_nScaleX
    if _movePosX ~= nil then
        local moveX
        local moveY = _movePosY
        if ScaleX > 0 then
            moveX = _movePosX - 150
        else
            moveX = _movePosX + 150
        end 
        if _movePosX < _G.g_Stage:getMaplx()+160 then
            moveX = _movePosX + 80       
        elseif _movePosX > _G.g_Stage:getMaprx()-160 then
            moveX = _movePosX - 80
        end
        local deltaX=self.m_nLocationX-moveX
        local deltaY=self.m_nLocationY-moveY
        if deltaX*deltaX+deltaY*deltaY>4000 then
            self:setMovePos(cc.p(moveX,moveY))
        end
        -- if self.m_nLocationX<= self.m_lpMovePos.x then
        --     self:setMoveClipContainerScalex(1)
        -- else
        --     self:setMoveClipContainerScalex(-1)
        -- end
    end
end

function CPartner.think( self, _now )
    if self.m_nAI == nil or self.m_nAI == 0 then
        return
    end
    --判断是否有反应
    if _now - self.m_fLastThinkTime < self.m_fThinkInterval then   
        return
    end

    self.m_fLastThinkTime = _now
    if self.m_boss~=nil then

        local deltaX = self.m_nLocationX-self.m_boss.m_nLocationX
        deltaX=math.abs(deltaX)
        if deltaX > self.m_fBossMaxDistance then
            self.m_nTarget=nil
            if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE 
                or self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then
                return
            end
            self:followBoss()
            return
        end
    end
    self:runTheAI(_now)
    if self.m_nTarget==nil and self.m_boss then
        if _now - self.m_fLastTraceTime < self.m_fTraceInterval then   
            return
        end
        self.m_fLastTraceTime = _now

        -- local deltaX = self.m_nLocationX-self.m_boss.m_nLocationX
        -- local deltaY = self.m_nLocationY-self.m_boss.m_nLocationY
        -- print(deltaX*deltaX+deltaY*deltaY,"@#@#@#@$")
        -- if deltaX*deltaX+deltaY*deltaY > self.m_noTargetFollowMax or deltaX*deltaX+deltaY*deltaY < self.m_noTargetFollowMin then
            self:noTargetFollow()
        -- end
    end
end

function CPartner.evade(self)
    do return end
--     if self.m_nTarget==nil then
--         self.m_nTarget = self:findNearTarget()
--         if  self.m_nTarget~=nil then
--             return
--         end
--     end

--     local selfx = self.m_nLocationX
--     local selfy = self.m_nLocationY
--     local moveX = math.random(0,500)+50
--     local moveY = math.random(0,300)+30

--     if math.random()>=0.5 then
--         selfx=selfx+moveX
--         local rx = self.m_stageView:getMaprx()
--         selfx=selfx>=rx and selfx-2*moveX or selfx
--     else
--         selfx=selfx-moveX
--         local lx = self.m_stageView:getMaplx()
--         selfx=selfx<=lx and selfx+2*moveX or selfx
--     end

--     if math.random()>=0.5 then
--         selfy=selfy+moveY
--         local maxY = self.m_stageView:getMapLimitHeight(selfx)
--         selfy=selfy>=maxY and selfy-2*moveY or selfy
--     else
--         selfy=selfy-moveY
--         local _,minY = self.m_stageView:getMapLimitHeight(selfx)
--         selfy=selfy<=minY and selfy+2*moveY or selfy
--     end

--     self:setMovePos(cc.p(selfx,selfy))
end
function CPartner.resetNamePos( self )
    if self.m_lpName == nil then return end
    self.m_lpName : setPosition(0,self.m_skeletonHeight)
end

function CPartner.cancelMove( self )
    self.m_lpMovePos = nil
    if self.m_nStatus== Const.CONST_BATTLE_STATUS_MOVE then
        self : setStatus(Const.CONST_BATTLE_STATUS_IDLE)
    end

    if self.m_enableBroadcastMove==true then
        self.m_stageView:onRoleMove(self, self.m_nLocationX, self.m_nLocationY, nil, true)
    end
end
function CPartner.reborn( self,_nHP )
    local _Angle=_G.Const.CONST_BATTLE_DEAD_ANGLE
    if self.m_nScaleX>0 then
        _Angle = math.abs(_Angle)-180
    end
    self:thrust( _G.Const.CONST_BATTLE_DEAD_SPEED, _Angle , _G.Const.CONST_BATTLE_DEAD_ACCELERATION )
    self:setStatus( _G.Const.CONST_BATTLE_STATUS_CRASH)
    self.m_nHP=1
    self.m_boss.m_parHp=nil
    local invBuff= _G.GBuffManager:getBuffNewObject(407, 0)
    self:addBuff(invBuff)
    local AnimationFunc=self.onAnimationCompleted
    self.onAnimationCompleted=function ( self, eventType, _animationName )
        if _animationName=="fall" then
            self.m_reborning=true
            self.m_nNextSkillID = 0
            -- self.m_nNextSkillID2 = 0
            self.m_boss.m_star:setStatus(_G.Const.CONST_BATTLE_STATUS_USESKILL)
            self:useSkill(49100)
            local function c(  )
                self.onAnimationCompleted=AnimationFunc
                self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
                self:setHP(math.ceil(_nHP))
                self.m_reborning=nil
            end
            self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(c)))
            return
        end
    end
end