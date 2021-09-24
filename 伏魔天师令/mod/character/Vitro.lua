CVitro = classGc(CMonster,function(self,_nType)
    self.m_nType=_nType --离体攻击
    self.m_stageView=_G.g_Stage
end)

function CVitro.initVitro( self, vitroData,addVitroData, _masterCharacter, _masterUID, _masterType, masterVitroID)
    if masterVitroID ~= nil then
        self.m_nSkillID=masterVitroID
        self.m_z = 150
    else
        self.m_nSkillID=_masterCharacter.m_nSkillID
    end
    if self.m_stageView:isMultiStage() then
        if _G.g_SkillDataManager:hasParticleVitro(self.m_nSkillID) then
            return
        end
    end
    self.m_nMasterID = _masterUID
    self.m_nMasterType = _masterType
    
    self.m_nScaleXPer  = _masterCharacter.m_nScaleXPer
    local masterScaleX = _masterCharacter.m_nScaleX
    self.m_deviation=0

    self.m_fathionData=addVitroData.date

    local tempStartX,tempStartY,tempEndX,tempEndY
    if self.m_fathionData[1] then
        tempStartX=self.m_fathionData[1].startX
        tempStartY=self.m_fathionData[1].startY
        tempEndX=self.m_fathionData[1].endX
        tempEndY=self.m_fathionData[1].endY
        self.m_isCheckCollisionSkill=self.m_fathionData[1].hurt==1
        self.m_isRandomMove=self.m_fathionData[1].type==2
    else
        tempStartX=0
        tempStartY=0
        tempEndX=0
        tempEndY=0
        self.m_isCheckCollisionSkill=true
    end

    self.m_fathionIdx=1
    self.m_fathionTimes=0

    if vitroData.limit==1 then
        self.convertLimitPos=function(self,_x,_y)
            return _x,_y
        end
    end

    if vitroData.scene==1 then
        local x,y=self.m_stageView.m_lpContainer:getPosition()
        x=-x
        y=-y
        if masterScaleX==1 then
            tempStartX=x+tempStartX-_masterCharacter.m_nLocationX/self.m_nScaleXPer
            tempStartY=y+tempStartY-_masterCharacter.m_nLocationY
            tempEndX=x+tempEndX-_masterCharacter.m_nLocationX/self.m_nScaleXPer
            tempEndY=y+tempEndY-_masterCharacter.m_nLocationY
        else
            local winW=self.m_stageView.winSize.width
            x=x+winW
            tempStartX=-(x-tempStartX-_masterCharacter.m_nLocationX/self.m_nScaleXPer)
            tempStartY=y+tempStartY-_masterCharacter.m_nLocationY
            tempEndX=-(x-tempEndX-_masterCharacter.m_nLocationX/self.m_nScaleXPer)
            tempEndY=y+tempEndY-_masterCharacter.m_nLocationY
        end
    elseif vitroData.random==1 then
        local colliderData=_G.g_SkillDataManager:getAttackSkillCollider(_masterCharacter.m_nSkillID)
        math.randomseed(gc.MathGc:random_0_1())
        local vX, vY, _, vWidth, vHeight, _=_masterCharacter:getConvertCollider(colliderData)
        local x = math.random(vX,vWidth+vX)
        local y = math.random(vY,vHeight+vY)
        tempStartX=(x+tempStartX-_masterCharacter.m_nLocationX)/self.m_nScaleXPer*masterScaleX
        tempStartY=y+tempStartY-_masterCharacter.m_nLocationY
        tempEndX=(x+tempEndX-_masterCharacter.m_nLocationX)/self.m_nScaleXPer*masterScaleX
        tempEndY=y+tempEndY-_masterCharacter.m_nLocationY
    end


    self.m_nStartX= (tempStartX * masterScaleX * self.m_nScaleXPer + _masterCharacter.m_nLocationX)
    self.m_nStartY= (tempStartY + _masterCharacter.m_nLocationY)
    self.m_nEndX = (tempEndX * masterScaleX * self.m_nScaleXPer + _masterCharacter.m_nLocationX)
    self.m_nEndY = (tempEndY + _masterCharacter.m_nLocationY)
    self.m_z = 0
    self.m_isShowState=_masterCharacter.m_isShowState

    self.m_vitroId=addVitroData.id
    self.m_nID = _G.UniqueID:getNewID() --ID

    self.m_buff = {}        --buff列表
    self.vitroData=vitroData
    self.m_SkinId =vitroData.skin_id -- 皮肤
    self.m_attackTimes=vitroData.attack_times
    self.m_lifeEndTime=_G.TimeUtil:getTotalMilliseconds()+vitroData.duration*1000
    self.m_nSkillDuration = 0
    self.m_vitroType=vitroData.vitro_type or _G.Const.CONST_SKILL_VITRO_OLD
    self.m_hitDisappear=vitroData.hit_disappear
    self.m_acce = vitroData.a or 1
    if self.m_vitroType==_G.Const.CONST_SKILL_VITRO_LOCATION then
        if _masterCharacter.m_nTarget~=nil then
            self.m_nStartX=_masterCharacter.m_nTarget.m_nLocationX
            self.m_nStartY=_masterCharacter.m_nTarget.m_nLocationY
            self.m_nEndX=_masterCharacter.m_nTarget.m_nLocationX
            self.m_nEndY=_masterCharacter.m_nTarget.m_nLocationY
        end
    end

    self.m_showSkillArray={}
    self.m_curUseSkillEffectObjArray={}

    self.m_skillFrameTimesArray={}

    self.m_lpContainer = cc.Node:create()
    self.m_lpCharacterContainer = cc.Node :create() --人物层
    self.m_lpContainer:addChild(self.m_lpCharacterContainer)
    self.m_lpEffectContainer=self.m_lpCharacterContainer
    self.m_lbEffectContainer=self.m_lpCharacterContainer

    if addVitroData.scale~=nil then
        self.m_lpContainer:setScale(addVitroData.scale)
    end
    
    self.m_nStartX,self.m_nStartY=self:convertLimitPos(self.m_nStartX,self.m_nStartY)
    self.m_nEndX,self.m_nEndY=self:convertLimitPos(self.m_nEndX,self.m_nEndY)
    self:setLocation(self.m_nStartX, self.m_nStartY,0)
    -- self.m_lpZOrderCallBackPos = cc.p(self.m_nStartX, self.m_nStartY)

    self:setMoveClipContainerScalex(masterScaleX)
    self.m_lpCharacterContainer : setScaleX(self.m_nScaleXPer * self.m_nScaleX)
    self.m_lpCharacterContainer : setScaleY(self.m_nScaleXPer)

    if vitroData.hide~=0 then
        self:loadMovieClip(self.m_nSkillID)
    end

    if vitroData.bomb_effect ~= 0 then
        self.bombId = vitroData.bomb_effect
        self.bombArray = {}
        self.bombArray.x = vitroData.x
        self.bombArray.y = vitroData.y
        self.bombArray.s = vitroData.s / 10000
        self.bombArray.r = vitroData.r
    end

    self.m_speed = vitroData.speed
    if self.m_speed==0 then
        self.onUpdateMove=false
        -- self.onUpdateJump=false
    else
        if self.m_vitroType==_G.Const.CONST_SKILL_VITRO_BOMB then
            -- local angel = gc.MathGc:pointsToAngle(cc.p(self.m_nStartX,self.m_nStartY),cc.p(self.m_nEndX,self.m_nEndY))
            if _masterCharacter.m_nTarget then
                self.m_nEndX = _masterCharacter.m_nTarget.m_nLocationX or self.m_nEndX
                self.m_nEndY = _masterCharacter.m_nTarget.m_nLocationY or self.m_nEndY
            end
            self.m_acceleration=self.vitroData.acceleration or 0

            self.m_centerX = self.m_nStartX+deltaX/2
            self.m_nLocationZ=self.vitroData.startz
            self.m_endZ=self.vitroData.endz
            self:handleMoveSpeed()
            -- print("pushAngle=",pushAngle,"self.m_speedX=",self.m_speedX,"self.m_speedY=",self.m_speedY,"self.m_centerX=",self.m_centerX )
        else
            self:handleMoveSpeed()
        end
    end

    -- 是否贴地
    self.m_isSurface=vitroData.surface==1
    if self.m_isSurface then
        self.m_lpContainer:setLocalZOrder(-1000)
    else
        self.m_lpContainer:setLocalZOrder(-self.m_nLocationY)
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
        self.m_attHeiLayer = cc.LayerColor:create(cc.c4b(220,150,20,70))
        self.m_attHeiLayer : setContentSize(cc.size(0,0))
        self.m_attHeiLayer : setVisible(false)
        self.m_lpContainer : addChild(self.m_attHeiLayer)        
        self.m_numLabel = _G.Util:createLabel("",30)
        self.m_numLabel : setPosition(50,50)
        self.m_attLayer : addChild(self.m_numLabel)
        self.m_noAtt = _masterCharacter.m_noAtt
        if _masterCharacter.m_noAtt ~= true then
            self.blockLayer : setVisible(false)
        end
    end
    -- -- 调试信息（中线）
    -- self.lineLayer = cc.LayerColor:create(cc.c4b(0,255,0,255))
    -- self.lineLayer:setContentSize(cc.size(2,300))
    -- self.m_lpContainer:addChild(self.lineLayer)

    -- CCLOG("self.m_speedX=%d,self.m_speedY=%d self.m_nSkillID=%d",self.m_speedX ,self.m_speedY,self.m_nSkillID)
    -- CCLOG("CVitro.initVitro m_nStartX=%d, m_nStartY=%d, m_nEndX=%d, m_nEndY=%d",self.m_nStartX,self.m_nStartY,self.m_nEndX,self.m_nEndY)
end

function CVitro.handleMoveSpeed(self)
    if self.m_vitroType==_G.Const.CONST_SKILL_VITRO_BOMB then
        local pushAngle=self.vitroData.pushangle or 0
        local radian = math.angle2radian(pushAngle)
        self.m_speedX = self.vitroData.speed*math.cos(radian)*(self.m_nScaleX>=0 and 1 or -1)
        self.m_speedY = self.vitroData.speed*math.sin(radian)
        local deltaX = self.m_nEndX-self.m_nStartX
        self.m_centerX = self.m_nStartX+deltaX/2
    else
        local angle
        if self.m_nStartX==self.m_nEndX and self.m_nStartY==self.m_nEndY then
            angle=0
        else
            angle=gc.MathGc:pointsToAngle( cc.p(self.m_nStartX,self.m_nStartY),cc.p(self.m_nEndX,self.m_nEndY))
        end
        
        local radian = math.angle2radian(angle)
        self.m_speedX = self.vitroData.speed*math.cos(radian)
        self.m_speedY = self.vitroData.speed*math.sin(radian)
        if math.abs(angle) < 180 and math.abs(angle) > 0 then      
            if self.m_nScaleX == -1 then
                angle = angle+180
            end
            self.m_lpCharacterContainer:setRotation(-angle)
        end
    end
end

function CVitro.onUpdateMove( self, _duration)
    if self.m_vitroType==_G.Const.CONST_SKILL_VITRO_OLD then
        if self.m_stopMove then
            return
        end
        local deltaX = self.m_nLocationX-self.m_nEndX
        local deltaY = self.m_nLocationY-self.m_nEndY

        local currentDistance = deltaX*deltaX+deltaY*deltaY
        if  currentDistance<= 1 then
            self:stopMove()
            return
        end
        self.m_speedX = self.m_speedX * self.m_acce
        self.m_speedY = self.m_speedY * self.m_acce
        local movePosX = self.m_nLocationX+_duration * self.m_speedX
        local movePosY = self.m_nLocationY+_duration * self.m_speedY

        local deltaX = movePosX-self.m_nEndX
        local deltaY = movePosY-self.m_nEndY

        local moveDistance =deltaX*deltaX+deltaY*deltaY
        if currentDistance <= moveDistance then
            movePosX = self.m_nEndX
            movePosY = self.m_nEndY
            
            self:stopMove()
        end
        self:setLocation(movePosX,movePosY,0)

    elseif self.m_vitroType==_G.Const.CONST_SKILL_VITRO_BOMB then
        if self.m_nLocationZ<=self.m_endZ or self.m_stopMove then
            self:stopMove()
            return
        end

        local xDistance = _duration * self.m_speedX
        local movePosX = self.m_nLocationX+xDistance

        if self.m_nScaleX>=0 then
            if self.m_centerX~=nil and movePosX>self.m_centerX then
                self.m_centerX=nil
                self.m_speedY=-15
            end
            if self.m_nEndX~=nil and movePosX>self.m_nEndX then
                self.m_acceleration=self.m_acceleration*2
                self.m_nEndX=nil
            end
        else
            if self.m_centerX~=nil and movePosX<self.m_centerX then
                self.m_centerX=nil
                self.m_speedY=-15
            end
            if self.m_nEndX~=nil and movePosX<self.m_nEndX then
                self.m_acceleration=self.m_acceleration*2
                self.m_nEndX=nil
            end
        end

        local zDistance = _duration*self.m_speedY - 0.5 * self.m_acceleration* _duration*_duration
        local movePosZ=self.m_nLocationZ+zDistance
        self.m_speedY=self.m_speedY-self.m_acceleration * _duration
        -- print("CVitro.onUpdateMove zDistance=",zDistance,"movePosZ=",movePosZ,"self.m_nLocationZ=",self.m_nLocationZ,"self.m_speedY=",self.m_speedY)
        self:setLocation(movePosX,self.m_nStartY,movePosZ)
    end
end
function CVitro.stopMove(self)
    self.m_stopMove=true
    if self.m_vitroType==_G.Const.CONST_SKILL_VITRO_BOMB then
        self:bomb()
    elseif self.m_vitroType==_G.Const.CONST_SKILL_VITRO_OLD then
        if self.bombId~=nil and self.m_isFathionEnd then
            self:bomb()
        end
        if self.m_isRandomMove then
            self:handleCurFathion()
        end
    end
end

function CVitro.bomb(self)
    if self.m_isBomb then return end
    self.m_isBomb=true

    if self.bombId~=nil then
        -- self.m_lpCharacterContainer:removeAllChildren(true)
        self:hideEskillEffect()

        local effectName = "spine/"..self.bombId
        local effectSpine=_G.StageObjectPool:getObject(effectName,_G.Const.StagePoolTypeSpine,1)
        self.m_lpCharacterContainer:addChild(effectSpine)
        effectSpine:setAnimation(0,"idle",false)
        local function onFunc2(event)
            effectSpine:removeFromParent(true)
            _G.StageObjectPool:freeObject(effectSpine)
            self.m_stageView:removeVitro(self)
        end
        if self.bombArray~=nil then
            effectSpine:setPosition(self.bombArray.x,self.bombArray.y)
            effectSpine:setScale(self.bombArray.s)
            effectSpine:setRotation(self.bombArray.r)
        end
        self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(onFunc2)))
    else
        self.m_stageView:removeVitro(self)
    end
end

function CVitro.setMoveClipContainerScalex( self, _ScaleX)
    self.m_nScaleX = _ScaleX
    self.m_lpCharacterContainer:setScaleX(_ScaleX)

    if self.aiBlockLayer~=nil then
        self:setAIBlockWithCollider(self.aiCollider)
    end
end

function CVitro.loadMovieClip( self, _skinID )
    -- if _skinID == nil or self.m_lpContainer==nil then
    --     CCLOG("CVitro.loadMovieClip _skinID=%d",_skinID)
    --     return
    -- end
    -- local battleStr = "ccbi/"..tostring( _skinID ).."_skill.ccbi"
    -- if not _G.PathCheck:check(battleStr) then
    --     CCLOG("codeError!!!!  CVitro.loadMovieClip : battleStr=%s",battleStr)
    --     return
    -- end
    -- self.m_lpMovieClipBattle = CMovieClip:create(battleStr)
    -- self.m_lpCharacterContainer:addChild(self.m_lpMovieClipBattle)
    -- self.m_lpMovieClipBattle:play( "skill_".._skinID )
    self:showSkillEffect(_skinID,true)
    -- CCLOG("CVitro.loadMovieClip _skinID=%d  battleStr=%s",_skinID,tostring(battleStr))
end

function CVitro.releaseResource( self )
    -- print("CVitro.releaseResource=======>>>>>>",debug.traceback())
    self:releaseSkillResource()
    if self.m_lpContainer then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
end

function CVitro.getMasterUID( self )
    return self.m_nMasterID
end

function CVitro.getMasterType( self )
    return self.m_nMasterType
end

function CVitro.getProperty(self)
end

CVitro.think=nil
CVitro.onUpdateJump=nil

function CVitro.onUpdate( self, _duration, _nowTime )
    if self.m_lpContainer==nil then return end
    
    self:onUpdateSkillEffectObject(_duration)
    self:onUpdateUseSkill( _duration, _nowTime )
    self:onUpdateFathion(_duration)
    self:onUpdateDead(_nowTime)
end

function CVitro.onUpdateZOrder( self)
    if self.m_isSurface then return end

    if self.m_lpZOrderCallBackPosY==self.m_nLocationY then
        return
    end
    self.m_lpContainer:setLocalZOrder(-self.m_nLocationY+10+self.m_z)
    self.m_lpZOrderCallBackPosY=self.m_nLocationY
end

function CVitro.onUpdateDead( self,_nowTime)
    if _nowTime>=self.m_lifeEndTime then
        self:bomb()
    end
end

function CVitro.onUpdateUseSkill(self, _duration, _nowTime)
    local lastDuration = self.m_nSkillDuration
    self.m_nSkillDuration = self.m_nSkillDuration + _duration
    --循环配置表

    if not self.m_isCheckCollisionSkill then
        return
    end

    local skillNode=_G.g_SkillDataManager:getDirectSkillEffect(self.m_vitroId)
    if not skillNode or not skillNode.frame then
        CCLOG("CVitro.onUpdateUseSkill skill_effect_cnf无技能特效 vitroId=%d",self.m_vitroId)
        return
    end

    for idx,currentFrame in pairs(skillNode.frame) do
        local currentFrameTime = currentFrame.time
        if (currentFrameTime>=lastDuration and currentFrameTime<self.m_nSkillDuration) or currentFrameTime==0 then
            if currentFrameTime==0 and currentFrame.cd>0 then
                if not self.m_skillFrameTimesArray[idx] then
                    self.m_skillFrameTimesArray[idx]=_nowTime
                else
                    if _nowTime-self.m_skillFrameTimesArray[idx]<currentFrame.cd then
                        -- 碰撞检测间隔
                        return
                    else
                        self.m_skillFrameTimesArray[idx]=_nowTime
                    end
                end
            end

            self.m_deviation=currentFrame.point*self.m_nScaleX
            self:handleSkillFrameBuff(currentFrame,1,0,self.m_nSkillID)
            _G.StageXMLManager:handleSkillFrameVitro(self,currentFrame)

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
                if self.m_vitroType==_G.Const.CONST_SKILL_VITRO_OLD then
                    if self.m_hitDisappear==1 then
                        self.m_speed = 0
                        self:bomb()
                    end
                elseif self.m_vitroType==_G.Const.CONST_SKILL_VITRO_BOMB then
                    if self.m_hitDisappear==1 then
                        self.m_stopMove=true
                    end
                end
            end
        end
    end
end

function CVitro.onUpdateFathion(self,_duration)
    if self.m_isFathionEnd or (self.m_stopMove and self.m_vitroType==_G.Const.CONST_SKILL_VITRO_BOMB) then return end

    local curData=self.m_fathionData[self.m_fathionIdx]
    if curData then
        self.m_fathionTimes=self.m_fathionTimes+_duration
        if self.m_fathionTimes>=curData.time then
            self.m_fathionIdx=self.m_fathionIdx+1
            self.m_fathionTimes=0

            local nextData=self.m_fathionData[self.m_fathionIdx]
            if nextData then
                self:handleCurFathion()
            else
                self.m_isFathionEnd=true
                if self.bombId~=nil then
                    self:bomb()
                end
            end
        end
    else
        self.m_isFathionEnd=true
        if self.bombId~=nil then
            self:bomb()
        end
    end
end
function CVitro.handleCurFathion(self)
    local curData=self.m_fathionData[self.m_fathionIdx]
    if not curData then return end

    local startX=self.m_nLocationX
    local startY=self.m_nLocationY
    local endX,endY
    if curData.type==1 then
        endX=startX+curData.endX
        endY=startY+curData.endY
        self.m_isRandomMove=false
    elseif curData.type==2 then
        endX=startX+math.random(curData.startX,curData.endX)
        endY=startY+math.random(curData.startY,curData.endY)
        self.m_isRandomMove=true
    end

    endX,endY=self:convertLimitPos(endX,endY)

    self.m_isCheckCollisionSkill=curData.hurt==1
    if endX==startX and endY==startY then
        return
    end

    self.m_nStartX=startX
    self.m_nStartY=startY
    self.m_nEndX=endX
    self.m_nEndY=endY
    self:handleMoveSpeed()
    self.m_stopMove=false
end

function CVitro.setStatus(self, _nStatus)
end

function CVitro.setLocation(self, _x, _y, _z)
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
