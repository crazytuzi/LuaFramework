CHook = classGc(CBaseCharacter,function(self,_nType)
    self.m_nType=_nType
    self.m_stageView=_G.g_Stage
end)
local FOLLOW = 10001
local RANDOM = 10002
local RANDOMNONE = 0
local RANDOMX = 1
local RANDOMY = 2
local RANDOMALL = 3
function CHook.init(self,uid,hookData)
    self.m_nScaleXPer = 1 --放缩比例
    self.m_nID = uid 
    self.m_nSkillID=hookData.id
    self.m_proportion=hookData.p
    self.m_fixedHurt=hookData.h
    self.m_hurtNum=hookData.hurt_n
    self.m_hide=hookData.hide
    self.m_buff={}
    self.m_SkillCDTab={}
    self.m_deviation=0
    self.m_SkinId=hookData.skin
    self.m_nScaleX=hookData.dir == 6 and 1 or -1
    self.m_skinData=_G.g_SkillDataManager:getSkinData(self.m_SkinId)

    -- 离体攻击需添加
    self.m_noBeTarget=true
    local x = hookData.x
    local y = hookData.y
    self.m_randomType=RANDOMNONE

    self.m_lx=self.m_stageView:getMaplx()
    self.m_rx=self.m_stageView:getMaprx()
    self.m_lpContainer=cc.Layer:create() --总层
    if x == FOLLOW then
        self.m_runAI = true
    elseif y == RANDOM then
        self.m_randomType=RANDOMY
        self.m_nLocationX=x
        if x == RANDOM then
            self.m_randomType=RANDOMALL
        end
        self:setRandomLocation()
    elseif x == RANDOM then
        self.m_randomType=RANDOMX
        self.m_nLocationY=y
        self:setRandomLocation()
    else
        x=x<=self.m_lx and self.m_lx or x
        x=x>=self.m_rx and self.m_rx or x 
        local maxY,minY = self.m_stageView:getMapLimitHeight(x)
        y=y<=minY and minY or y
        y=y>=maxY and maxY or y

        self:setLocationXY(x,y)
    end

    self.m_nSkillDuration=0

    self.m_nLocationZ = 0
    self.m_lbEffectContainer = cc.Node : create() --特效层
    self.m_lpContainer : addChild( self.m_lbEffectContainer )
    self.m_lpEffectContainer = cc.Node : create() --特效层
    self.m_lpCharacterContainer = self.m_lpContainer
    if self.m_skinData ~= nil then
        local bodySpine = _G.SpineManager.createSpine("spine/"..self.m_SkinId,self.m_skinData.scale/10000)
        self.m_lpContainer : addChild(bodySpine)
        bodySpine:setAnimation(0,"idle",true)
        bodySpine:setScaleX(self.m_nScaleX*self.m_skinData.scale/10000)
        self.m_bodySpine = bodySpine
        local function onFunc2(event)
            if event.animation == "idle" or event.animation == "dead" then return end
            self:hideEskillEffect()
            bodySpine:setAnimation(0,"idle",true)
        end
        bodySpine : registerSpineEventHandler(onFunc2,2)
    end

    self.m_lpContainer : addChild( self.m_lpEffectContainer )
    
    self.m_attLayer = cc.LayerColor:create(cc.c4b(0,255,0,160))
    self.m_attLayer : setContentSize(cc.size(0,0))
    self.m_attLayer : setVisible(false)
    self.m_lpContainer : addChild(self.m_attLayer)
    self.m_noAtt = nil

    -- cc.LOG("CHook.init x=%d",uid)
    if hookData.l~=0 then
        self.m_boxLimit = hookData.x
        if self.m_SkinId==0 then
            self.m_SkinId=10001
        end
        self:setColliderXmlByID(self.m_SkinId)
    end
    self.m_hurtTimes = 0
    if hookData.hurt~=0 then
        self.m_noBeTarget = nil
        self.m_hurt = hookData.hurt
    end

    if hookData.hurt_f==0 then
        self.m_noFirstHurt = true
        self.m_noUpdate = true
        self.m_noUseskill = true
    end

    if hookData.hook~=0 then
        self.m_noHurtEffect = true
    end

    self.m_speed = hookData.speed

    if hookData.hurt_c~=0 then
        self.m_changeHurt=hookData.hurt_c
    end

    if hookData.c~=0 then
        self.m_corpse=true
    end

    if hookData.ai~=0 and self.m_nSkillID~=0 then
        self.m_currentCollider = _G.g_SkillDataManager:getAttackSkillCollider(self.m_nSkillID)
        self.m_ai = true
    end

    print("hookinit =======>>>>>>")
end

CHook.onUpdateMove=nil

function CHook.setRandomLocation(self)
    math.randomseed(gc.MathGc:random_0_1())
    local x,y=self:getLocationXY()
    x=x or self.m_lx
    y=y or self.m_stageView:getMapLimitHeight(x)
    if self.m_randomType == RANDOMX then
        x=math.random(self.m_lx,self.m_rx)
    elseif self.m_randomType == RANDOMY then
        local maxY,minY = self.m_stageView:getMapLimitHeight(x)
        y=math.random(minY,maxY)

    else
        x=math.random(self.m_lx,self.m_rx)
        local maxY,minY = self.m_stageView:getMapLimitHeight(x)
        y=math.random(minY,maxY)
    end
    self:setLocationXY(x,y)
end

function CHook.useSkill(self, _skillID)
    if _skillID == nil or _skillID == 0 or self:isSkillCD(_skillID) then
        return
    end
    if self.m_runAI == true then
        local x,y = _G.g_lpMainPlay:getLocationXY()
        self:setLocationXY(x,y)
    end
    -- local scaleX = gc.MathGc:random_0_1()
    -- if scaleX > 0.5 then
    --     self.m_lpEffectContainer : setScaleX(1)
    -- else
    --     self.m_lpEffectContainer : setScaleX(-1)
    -- end
    local skillEffectData = _G.g_SkillDataManager:getSkillData(_skillID)
    -- if skillEffectData == nil then skillEffectData = _G.g_SkillDataManager:getSkillEffect(42640) end
    self:setSkillCD(_skillID,skillEffectData.cd)
    self:setStatus( _G.Const.CONST_BATTLE_STATUS_USESKILL )
    self.m_nSkillDuration=0

    self:hideEskillEffect()
    self:showSkillEffect(_skillID)
    if self.m_bodySpine ~= nil and not self.m_noHurtEffect then
        if skillEffectData.action_id~=0 then
            self.m_bodySpine:setAnimation(0,string.format("skill_%d",skillEffectData.action_id),false)
        else
            self.m_bodySpine:setAnimation(0,"kill",false)
        end
    end
    self.m_nSkillID = _skillID
end

function CHook.onUpdate( self, _duration, _nowTime )
    if self.m_lpContainer==nil or self.m_stageView.m_stopAI or self.m_noUpdate then return end
    if self.m_speed ~= 0 then
        self:setSkillCD(self.m_nSkillID, self.m_speed)
        self.m_speed = 0
    end

    self:onUpdateSkillEffectObject(_duration)
    self:onUpdateUseSkill( _duration )
    if self.m_cdChange ~= self:isSkillCD(self.m_nSkillID) then
        self.m_cdChange = self:isSkillCD(self.m_nSkillID)
        if self.m_hide~=0 then
            if self.m_cdChange then
                self.m_bodySpine:setVisible(false)
            else
                self.m_bodySpine:setVisible(true)
            end
        end
        if self.m_randomType ~= RANDOMNONE then
            if self.m_cdChange then
                local function c()
                    self:setRandomLocation()
                end

                local delay=cc.DelayTime:create(3)
                local func=cc.CallFunc:create(c)
                self.m_lpContainer:runAction(cc.Sequence:create(delay,func))
            end
        end
    end


    if self.m_ai and self.m_bodySpine then
        local characterList =_G.CharacterManager:getCharacterByVertex(self,self.m_currentCollider,self.m_property:getTeamID())
        if #characterList==0 then
            return
        end
    end
    if not self.m_noUseskill then
        self:useSkill(self.m_nSkillID)
    end
end
--更新  生物使用技能
function CHook.onUpdateUseSkill(self, _duration)
    if not self.m_nSkillID or self.m_nSkillID==0 or self.m_nStatus ~= _G.Const.CONST_BATTLE_STATUS_USESKILL then
        return
    end

    local lastDuration = self.m_nSkillDuration
    self.m_nSkillDuration = self.m_nSkillDuration + _duration
    --循环配置表
    local skillNode=_G.g_SkillDataManager:getSkillEffect(self.m_nSkillID)
    if not skillNode or not skillNode.frame then
        return
    end

    local isPlayHitAudio=false
    for _,currentFrame in pairs(skillNode.frame) do
        local currentFrameTime = currentFrame.time
        if currentFrameTime >= lastDuration and currentFrameTime < self.m_nSkillDuration then
            self:handleSkillFrameBuff(currentFrame,1,0,self.m_nSkillID)
            _G.StageXMLManager:handleSkillFrameVitro(self,currentFrame)
            _G.StageXMLManager:handleSkillFrameTrap(self,currentFrame)

            --技能攻击音效
            if currentFrame.sound and type(currentFrame.sound)=="table" then
                local i=math.ceil(gc.MathGc:random_0_1()*#(currentFrame.sound))
                _G.Util:playAudioEffect(currentFrame.sound[i])
            end
            
            local iscollider,isHit = self:checkCollisionSkill( skillNode, currentFrame )

            --打中
            if iscollider then
                if not isPlayHitAudio and currentFrame.hit_s then
                    _G.Util:playAudioEffect(currentFrame.hit_s)
                    isPlayHitAudio=true
                end
                
                if not self.m_addMpSkillId or self.m_addMpSkillId~=self.m_nSkillID then
                    self:addMP(_G.Const.CONST_BATTLE_HIT_ADD_MP)
                    self.m_addMpSkillId=self.m_nSkillID
                end
            end
        end
    end
end

function CHook.setLocationXY( self,x,y )
    self.m_lpContainer:setPosition(cc.p(x,y))
    self.m_nLocationX = x
    self.m_nLocationY = y

    self:onUpdateZOrder()
    self:resetSkillEffectObjectPos()
end

--受伤害
function CHook.onHurt(self, hurtData,_Assailant)
    if not hurtData or type(hurtData)~="table" then return end

    if self.m_lpContainer==nil or self.m_hurtTimes>=self.m_hurtNum or self.m_bodySpine==nil then return end
    self.m_bodySpine : setAnimation(0,"hurt",false)
    
    local effectId=hurtData[1]
    if effectId==0 then
        effectId=10
    end

    if self.m_hurtSprite==nil then
        local hurtX = self.m_skinData.hurt_x
        local hurtY = self.m_skinData.hurt_y

        local hurtSprite = cc.Sprite:create()
        hurtSprite:setPosition(cc.p(hurtX, hurtY))
        self.m_lpCharacterContainer:addChild( hurtSprite, 10)
        self.m_hurtSprite=hurtSprite
    end

    -- if self.m_hurting == nil then
    self.m_hurtSprite:stopAllActions()
    self.m_hurtSprite:setVisible(true)
    local spriteFrameName = string.format("spine/%d",effectId)
    local hurtSpine=_G.StageObjectPool:getObject(spriteFrameName,_G.Const.StagePoolTypeSpine)
    local function onFunc()
        local delay=cc.DelayTime:create(0.1)
        local function c()
            hurtSpine:removeFromParent(true)
            _G.StageObjectPool:freeObject(hurtSpine)
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
    -- self.m_hurtSprite:runAction(cc.Sequence:create(animate,delay,hide))

    self.m_hurtTimes=self.m_hurtTimes+1
    if self.m_hurtTimes>=self.m_hurtNum then
        
        if self.m_skinData.dead_sound~=nil then
            _G.Util:playAudioEffect(self.m_skinData.dead_sound)
        end
        self.m_nTarget=nil
        self.m_noUpdate=true

        if self.m_boxLimit == nil then
            if self.m_nSkillID ~= nil and self.m_noFirstHurt then
                self.m_noUpdate=nil
                self:useSkill(self.m_nSkillID)
            end
            self.m_bodySpine:setAnimation(0,"dead",false)

            local function c( )
                if self.m_changeHurt~=nil then
                    local data = {}
                    data.id = self.m_changeHurt
                    data.x  = self.m_nLocationX
                    data.y  = self.m_nLocationY
                    _G.StageXMLManager:addOneHook(nil,data)
                end
                if not self.m_corpse then
                    self:releaseResource()
                else
                    _G.CharacterManager:remove(self)
                end
                
            end
            self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(c)))
        else
            local function onDestoryEffectCallback()
                self:destory()
            end
            self.m_bodySpine:setAnimation(0,"dead",false)
            self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(onDestoryEffectCallback)))
        end
    end
end
function CHook.addBuff(self,_buff )
    local buffType = _buff:gettype()
    local vibrateFunc ="vibrate"
    vibrateFunc=self.m_stageView[vibrateFunc]
    if vibrateFunc~=nil then
        vibrateFunc(self.m_stageView,_buff.num,_buff.positiony,_buff.duration)
    end
end

function CHook.destory( self )
    self:releaseResource()

    if self.m_boxLimit ~= nil then
        _G.CharacterManager:checkObstacleLimits()
    end
end

function CHook.releaseResource( self )
    if self.m_bodySpine~=nil then
        self.m_bodySpine:removeFromParent(true)
        self.m_bodySpine=nil
    end
    self:releaseSkillResource()
    _G.CharacterManager:remove(self)
    if self.m_lpContainer~=nil then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
end
