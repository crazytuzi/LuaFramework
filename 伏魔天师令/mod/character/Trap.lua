CTrap = classGc(CBaseCharacter,function(self,_nType)
    self.m_nType=_nType --滚动陷阱
    self.m_stageView=_G.g_Stage
end)

function CTrap.initTrap( self, trapData,addTrapData, _masterCharacter, uid)
    -- self.m_nMasterID = _masterUID
    -- self.m_nMasterType = _masterType
    
    local masterScaleX = trapData.dir == 6 and 1 or -1
    self.m_nStartX= (addTrapData.startX * masterScaleX + _masterCharacter.m_nLocationX)
    self.m_nStartY= (addTrapData.startY + _masterCharacter.m_nLocationY)
    self.m_nEndX = (addTrapData.endX * masterScaleX + _masterCharacter.m_nLocationX)
    self.m_nEndY = (addTrapData.endY + _masterCharacter.m_nLocationY)
    print(masterScaleX,self.m_nStartX,self.m_nStartY,self.m_nEndX,self.m_nEndY)
    self.m_z = 0

    self.m_vitroId=addTrapData.id
    self.m_nID = uid --ID

    self.m_buff = {}        --buff列表
    self.trapData=trapData
    self.m_SkinId =trapData.skin_id -- 皮肤
    self.m_attackTimes=trapData.attack_times
    self.m_lifeEndTime=_G.TimeUtil:getTotalMilliseconds()+trapData.duration*1000
    self.m_nSkillDuration = 0
    self.m_hitDisappear=trapData.hit_disappear
    self.m_corpse = trapData.corpse
    self.m_proportion=_masterCharacter.m_proportion
    self.m_fixedHurt=_masterCharacter.m_fixedHurt
    self.m_lpContainer = cc.Node:create()
    self.m_lpCharacterContainer = cc.Node :create() --人物层
    self.m_lpContainer:addChild(self.m_lpCharacterContainer,1)
    self.m_lpEffectContainer = cc.Node :create() --人物层
    self.m_lpContainer:addChild(self.m_lpEffectContainer,1)
    self.m_lbEffectContainer=cc.Node :create()
    self.m_lpContainer:addChild(self.m_lbEffectContainer,-1)

    self.m_showSkillArray={}
    self.m_curUseSkillEffectObjArray={}
    self.m_nSkillID=_masterCharacter.m_nSkillID
    self:loadMovieClip(self.m_nSkillID)
    self:setLocation(self.m_nStartX, self.m_nStartY,0)
    -- self.m_lpZOrderCallBackPos = cc.p(self.m_nStartX, self.m_nStartY)
    self.m_deviation=0
    self:setMoveClipContainerScalex(masterScaleX)
    self.m_addHookId=trapData.hookid
    self.m_hurtNum=trapData.hurt_num
    if trapData.hurt==0 then
        self.m_noBeTarget=true
    end
    self.m_hurtTimes=0

    self.m_speed = trapData.speed
    if trapData.bomb_effect ~= 0 then
        self.bombId = trapData.bomb_effect
        self.bombArray = {}
        self.bombArray.x = trapData.x
        self.bombArray.y = trapData.y
        self.bombArray.s = trapData.s / 10000
        self.bombArray.r = trapData.r
    end
    
    
    local angle
    if self.m_nStartX==self.m_nEndX and self.m_nStartY==self.m_nEndY then
        angle=0
    else
        angle = gc.MathGc:pointsToAngle( cc.p(self.m_nStartX,self.m_nStartY),cc.p(self.m_nEndX,self.m_nEndY))
    end
    -- self.angle = angle
    local radian = math.angle2radian(angle)
    self.m_speedX = trapData.speed*math.cos(radian)
    self.m_speedY = trapData.speed*math.sin(radian)
    if math.abs(angle) < 180 and math.abs(angle) > 0 then      
        if self.m_nScaleX == -1 then
            angle = angle+180
        end
        self.m_lpCharacterContainer:setRotation(-angle)
    end

    self.m_beAttackers={}

    -- 调试信息（红块）
    if _G.SysInfo:isIpNetwork() then
        self.blockLayer = cc.LayerColor:create(cc.c4b(255,0,0,255))
        self.blockLayer:setContentSize(cc.size(100,200))
        self.blockLayer:setPosition(cc.p(-50,0))
        self.blockLayer:setOpacity(90)
        self.m_lpContainer:addChild(self.blockLayer)
        self.m_attLayer = cc.LayerColor:create(cc.c4b(0,255,0,160))
        self.m_attLayer : setContentSize(cc.size(0,0))
        self.m_attLayer : setVisible(false)
        self.m_lpContainer : addChild(self.m_attLayer)
        self.m_noAtt = _masterCharacter.m_noAtt
        if _masterCharacter.m_noAtt ~= true then
            self.blockLayer : setVisible(false)
        end
    end
    self:setColliderXmlByID(self.m_SkinId)
    -- -- 调试信息（中线）
    -- self.lineLayer = cc.LayerColor:create(cc.c4b(0,255,0,255))
    -- self.lineLayer:setContentSize(cc.size(2,300))
    -- self.m_lpContainer:addChild(self.lineLayer)
    if trapData.scale~=0 then
        self.m_lpContainer:setScale(trapData.scale/10000)
    end

    -- CCLOG("self.m_speedX=%d,self.m_speedY=%d self.m_nSkillID=%d",self.m_speedX ,self.m_speedY,self.m_nSkillID)
    -- CCLOG("CTrap.initTrap m_nStartX=%d, m_nStartY=%d, m_nEndX=%d, m_nEndY=%d",self.m_nStartX,self.m_nStartY,self.m_nEndX,self.m_nEndY)
end

function CTrap.onHurt( self,hurtData )
    if not hurtData or type(hurtData)~="table" then return end
    if self.m_lpContainer==nil or self.m_hurtTimes>=self.m_hurtNum then return end
    self.m_bodySpine : setAnimation(0,"hurt",false)

    local skinData=_G.g_SkillDataManager:getSkinData(self.m_SkinId)

    local effectId=hurtData[1]
    if effectId==0 then
        effectId=10
    end

    if self.m_hurtSprite==nil then
        local hurtX = skinData.hurt_x
        local hurtY = skinData.hurt_y

        local hurtSprite = cc.Sprite:create()
        hurtSprite:setPosition(cc.p(hurtX, hurtY))
        self.m_lpCharacterContainer:addChild( hurtSprite, 10)
        self.m_hurtSprite=hurtSprite
    end

    -- if self.m_hurting == nil then
    self.m_hurtSprite:stopAllActions()
    self.m_hurtSprite:setVisible(true)
    -- local spriteFrameName = string.format("%d_heffect_",effectId)
    local spriteFrameName = string.format("spine/%d",effectId)
    -- local spriteFrameName=effectId.."_"
    -- local animation=_G.Util:GenarelAnimation("anim/effect_hurt.plist",spriteFrameName,0.03)
    local hurtSpine=_G.SpineManager.createSpine(spriteFrameName)
    local function onFunc()
        local delay=cc.DelayTime:create(0.1)
        local function c()
            hurtSpine:removeFromParent(true)
        end
        hurtSpine:runAction(cc.Sequence:create(delay,cc.CallFunc:create(c)))
    end
    hurtSpine:setPosition(hurtData[2],hurtData[3])
    hurtSpine:setScale(hurtData[4])
    hurtSpine:setRotation(hurtData[5])
    hurtSpine:setAnimation(0,"idle",false)
    hurtSpine:registerSpineEventHandler(onFunc,2)
    self.m_hurtSprite:addChild(hurtSpine)
    self.m_hurting = true


    self.m_hurtTimes=self.m_hurtTimes+1
    if self.m_hurtTimes==self.m_hurtNum then
        self.m_noBeTarget=true
        -- function onDestoryEffectCallback(  )
            self:bomb()
        -- end
        -- self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(onDestoryEffectCallback)))
    end
end

function CTrap.onUpdateMove( self, _duration)
    if self.m_speed ==0 then
        return
    end
    if not (self.m_stageView.m_nMaplx<self.m_nLocationX and self.m_stageView.m_nMaprx>self.m_nLocationX )then
        self:removeTrap()
    end
    local deltaX = self.m_nLocationX-self.m_nEndX
    local deltaY = self.m_nLocationY-self.m_nEndY

    local currentDistance = deltaX*deltaX+deltaY*deltaY
    if  currentDistance<= 1 then
        CCLOG("到达目的地，停止移动1")
        self.m_speed = 0
        if self.bombId ~= nil then
            self:bomb()
        end
        return
    end
    self.m_speedX = self.m_speedX
    self.m_speedY = self.m_speedY
    local movePosX = self.m_nLocationX+_duration * self.m_speedX
    local movePosY = self.m_nLocationY+_duration * self.m_speedY

    local deltaX = movePosX-self.m_nEndX
    local deltaY = movePosY-self.m_nEndY

    local moveDistance =deltaX*deltaX+deltaY*deltaY
    if currentDistance <= moveDistance then
        movePosX = self.m_nEndX
        movePosY = self.m_nEndY
        self.m_speed = 0
        CCLOG("到达目的地，停止移动2")
        if self.bombId ~= nil then
            self:bomb()
        end
    end
    self:setLocation(movePosX,movePosY,0)
end

function CTrap.bomb(self)
    if self.m_noUpdate then return end

    if self.m_skinData.dead_sound~=nil then
        _G.Util:playAudioEffect(self.m_skinData.dead_sound)
    end
    self.m_speed=0
    self.m_noUpdate=true
    if self.m_bodySpine~=nil then
        self.m_bodySpine:setAnimation(0,"dead",false)
    else
        self.m_bodySpine=self.m_lpContainer
    end
    if self.m_addHookId ~= 0 then
        local data = {}
        data.id = self.m_addHookId
        data.x  = self.m_nLocationX
        data.y  = self.m_nLocationY
        if self.m_stageView.m_nMaplx<self.m_nLocationX and self.m_stageView.m_nMaprx>self.m_nLocationX then
            _G.StageXMLManager:addOneHook(nil,data)
        end
    end
    if self.m_corpse==0 then
        self:removeTrap(self)
        return
    end
    if self.bombId~=nil then
        local effectName = "spine/"..self.bombId
        local effectSpine=_G.StageObjectPool:getObject(effectName,_G.Const.StagePoolTypeSpine,1)
        self.m_lpCharacterContainer:addChild(effectSpine)
        effectSpine:setAnimation(0,"idle",false)
        local function onFunc2(event)
            effectSpine:removeFromParent(true)
            _G.StageObjectPool:freeObject(effectSpine)
            self:removeTrap(self)
        end
        if self.bombArray~=nil then
            effectSpine:setPosition(self.bombArray.x,self.bombArray.y)
            effectSpine:setScale(self.bombArray.s)
            effectSpine:setRotation(self.bombArray.r)
        end
        self:hideEskillEffect()
        self.m_bodySpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(0.5),cc.CallFunc:create(onFunc2)))
    else
        local function onFunc2(event)
            self:removeTrap(self)
        end
        self:hideEskillEffect()
        self.m_bodySpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(0.5),cc.CallFunc:create(onFunc2)))
    end
end

function CTrap.removeTrap( self )
    _G.CharacterManager:remove( self )
    self:releaseResource()
end

function CTrap.loadMovieClip( self )
    
    local skinData=_G.g_SkillDataManager:getSkinData(self.m_SkinId)
    self.m_skinData=skinData
    if skinData ~= nil then
        local bodySpine = _G.SpineManager.createSpine("spine/"..self.m_SkinId,skinData.scale/10000)
        print(bodySpine)
        self.m_lpContainer : addChild(bodySpine,0)
        bodySpine:setAnimation(0,"idle",true)
        self.m_bodySpine = bodySpine
        local function onFunc2(event)
            if event.animation == "idle" or event.animation == "dead" then return end
            self:hideEskillEffect()
            bodySpine:setAnimation(0,"idle",true)
        end
        bodySpine : registerSpineEventHandler(onFunc2,2)
    end

    self:showSkillEffect(self.m_nSkillID,true)
    CCLOG("CTrap.loadMovieClip self.m_nSkillID=%d %d",self.m_nSkillID,self.m_SkinId)
end


function CTrap.releaseResource( self )
    self:releaseSkillResource()
    if self.m_lpContainer then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
end

function CTrap.onUpdate( self, _duration, _nowTime )
    if self.m_lpContainer==nil or self.m_noUpdate then return end
    
    self:onUpdateSkillEffectObject(_duration)
    self:onUpdateUseSkill( _duration )
    self:onUpdateDead(_nowTime)
end

function CTrap.onUpdateZOrder( self)
    if self.m_lpZOrderCallBackPosY==self.m_nLocationY then
        return
    end
    self.m_lpContainer:setLocalZOrder(-self.m_nLocationY+10+self.m_z)
    self.m_lpZOrderCallBackPosY=self.m_nLocationY
end

function CTrap.onUpdateDead( self,_nowTime)
    if _nowTime>=self.m_lifeEndTime then
        self:bomb()
    end
end

function CTrap.onUpdateUseSkill(self, _duration)
    local lastDuration = self.m_nSkillDuration
    self.m_nSkillDuration = self.m_nSkillDuration + _duration
    --循环配置表

    local skillNode=_G.g_SkillDataManager:getDirectSkillEffect(self.m_vitroId)
    if not skillNode or not skillNode.frame then
        CCLOG("CTrap.onUpdateUseSkill skill_effect_cnf无技能特效 vitroId=%d",self.m_vitroId)
        return
    end

    for _,currentFrame in pairs(skillNode.frame) do
        local currentFrameTime = currentFrame.time
        if currentFrameTime >= lastDuration and currentFrameTime < self.m_nSkillDuration or currentFrameTime==0 then
            self:handleSkillFrameBuff(currentFrame,1,0,self.m_nSkillID)

            --技能攻击音效
            if currentFrame.sound and type(currentFrame.sound)=="table" then
                local i=math.ceil(gc.MathGc:random_0_1()*#(currentFrame.sound))
                _G.Util:playAudioEffect(currentFrame.sound[i])
            end
           
            local iscollider = self:checkCollisionSkill(skillNode, currentFrame)

            if iscollider then
                if currentFrame.hit_s then
                    _G.Util:playAudioEffect(currentFrame.hit_s)
                end
                if self.m_hitDisappear==1 then
                    self.m_speed = 0
                    self:bomb()
                end
            end
        end
    end
end

function CTrap.setMoveClipContainerScalex( self, _ScaleX)
    -- print("self.m_nScaleX",_ScaleX)
    self.m_nScaleX = _ScaleX
    self.m_lpCharacterContainer:setScaleX(_ScaleX)

    if self.aiBlockLayer~=nil then
        self:setAIBlockWithCollider(self.aiCollider)
    end
end

function CTrap.setLocation(self, _x, _y, _z)
    _z=_z or 0
    self.m_nLocationX = _x
    self.m_nLocationY = _y
    self.m_nLocationZ = _z

    if self.m_lpContainer then
        self.m_lpContainer:setPosition( _x, _y)
        self.m_lpCharacterContainer:setPosition(0,_z)
        self:onUpdateZOrder()
        self:resetSkillEffectObjectPos()
    end
end
