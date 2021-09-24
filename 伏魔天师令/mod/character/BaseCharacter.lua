CBaseCharacter=classGc(view,function(self,_nType)
    self.m_nType=_nType
    self.m_stageView=_G.g_Stage
end)

CBaseCharacter.SKILL_EFFECT_NODE_NAME="SKILL_EFFECT_NODE_NAME"

--每个继承此类的必须 init一次
function CBaseCharacter.init( self, _nID , _szName, _nMaxHP, _nHP, _nMaxSP, _nSP, _fx, _fy, _skinID, _type, _appera_skill)
    -- GCLOG("[CBaseCharacter.init]=======>>>>>_nType=%d,_nID=%d,_skinID=%d",self.m_nType,_nID,_skinID)
    print("OOOOOO=====>>>>>",self.m_nType,_nID,_skinID)
    -- print(debug.traceback())
    
    self.m_lpContainer = cc.Node:create() --总层
    self.m_lpCharacterContainer = cc.Node:create() --人物层
    self.m_lpMovieClipContainer = cc.Node:create() --人物MC层
    self.m_lpNameContainer = cc.Node:create() --名字层
    self.m_lpHurtStringContainer = cc.Node:create() --名字层
    self.m_lpEffectContainer = cc.Node:create() --特效层
    self.m_lbEffectContainer = cc.Node:create() --后置特效层
    -- 调试信息（红块）
    if _G.SysInfo:isIpNetwork() then
        self.blockLayer = cc.LayerColor:create(cc.c4b(255,0,0,255))
        self.blockLayer:setContentSize(cc.size(100,200))
        self.blockLayer:setPosition(-50,0)
        self.blockLayer:setOpacity(90)
        self.blockLayer:setVisible(false)
        self.m_lpContainer:addChild(self.blockLayer)

        self.m_attHeiLayer=cc.LayerColor:create(cc.c4b(220,150,20,70))
        self.m_attHeiLayer:setContentSize(cc.size(100,200))
        self.m_attHeiLayer:setPosition(-50,0)
        self.m_attHeiLayer:setOpacity(90)
        self.m_attHeiLayer:setVisible(false)
        self.m_lpContainer:addChild(self.m_attHeiLayer)        

        self.m_attLayer = cc.LayerColor:create(cc.c4b(0,255,0,160))
        self.m_attLayer : setContentSize(cc.size(0,0))
        self.m_attLayer : setVisible(false)
        self.m_lpContainer : addChild(self.m_attLayer)
        self.m_numLabel = _G.Util:createLabel("",30)
        self.m_numLabel : setPosition(50,50)
        self.m_attLayer : addChild(self.m_numLabel)
        self.m_noAtt = nil
    end
    -- -- 调试信息（中线）
    -- self.lineLayer = cc.LayerColor:create(cc.c4b(0,255,0,255))
    -- self.lineLayer:setContentSize(cc.size(2,300))
    -- self.m_lpContainer:addChild(self.lineLayer)

    -- local skinIDLabel = CCLabelTTF : create(tostring(_skinID), "Marker Felt", 21 )
    -- skinIDLabel:setPosition(0,100)
    -- self.m_lpContainer:addChild(skinIDLabel,1000000)

    self.m_lpContainer:addChild( self.m_lpCharacterContainer )
    self.m_lpCharacterContainer:addChild( self.m_lbEffectContainer)
    self.m_lpCharacterContainer:addChild( self.m_lpMovieClipContainer )
    self.m_lpCharacterContainer:addChild( self.m_lpEffectContainer )
    self.m_lpCharacterContainer:addChild( self.m_lpHurtStringContainer,200)
    -- self.m_lpCharacterContainer:addChild( self.m_lpNameContainer,100 )

    self.m_lpContainer:addChild(self.m_lpNameContainer,-1)

    -- 皮肤
    self.m_SkinId = tonumber(_skinID)
    if (self.m_SkinId>=10001 and self.m_SkinId<=10005) 
        or (self.m_SkinId==11020 or self.m_SkinId==12020 or self.m_SkinId==13020 or self.m_SkinId==14020 or self.m_SkinId==15020)
        or self.m_SkinId==100021 then
        self.m_idleName="idle2"
    else
        self.m_idleName="idle"
    end

    local skinData=_G.g_SkillDataManager:getSkinData(self.m_SkinId)
    if skinData==nil then
        skinData=_G.g_SkillDataManager:getSkinData(10001)
        -- CCMessageBox("skill_skin 没配置 ID="..self.m_SkinId)
    end
    self.m_skeletonHeight = skinData.nameh
    self.m_noLimit = skinData.limit
    self.m_backMap = skinData.back
    self.m_deadAction = skinData.dead
    self.m_isAirHurtAction = skinData.hurt

    -- self.m_crashRotation = 0
    self.m_skinScale = skinData.scale / 10000
    self.m_lpMovieClipContainer : setPosition(0,-skinData.offset)

    
    self.m_skinData=skinData

    --buff列表
    self.m_buff = {}

    self.m_nID = _nID --ID
    self.m_nMaxHP = _nMaxHP or 1
    self.m_nMaxSP = _nMaxSP or 1
    
    self.m_nHP = _nHP or 0
    self.m_nSP = _nSP or 0

    self.m_nMaxMP=_G.Const.CONST_BATTLE_MAX_MP
    self.m_nMP=50
    
    self.m_lpZOrderCallBackPosY=self.m_nLocationY

    self.m_showSkillArray={}
    self.m_curUseSkillEffectObjArray={}

    self.m_nSkillDuration = 0
    self.m_nSkillID = 0             --当前技能ID
    self.m_nNextSkillID = 0         --下次连技ID
    -- self.m_nNextSkillID2 = 0        --下下次连技ID
    -- self.m_nNextSkillID3 = 0        --下下下次连技ID

    --人物边界值  用于判断越过地图
    self : setBorder()

    --技能CD时间表
    self.m_SkillCDTab = {}

    self.m_fXSpeed = nil
    self.m_fYSpeed = nil
    self.m_hYSpeed = nil  -- 平面Y轴速度
    self.m_nScaleX = 1 --反转值
    self.m_nScaleXPer = 1 --放缩比例
    self.m_TSpeed = nil
    self.m_critHurt=self.m_critHurt and self.m_critHurt or 1

    self.m_nLocationX=_fx or 0
    self.m_nLocationY=_fy or 0
    self:showBody(_skinID)

    --重力
    self.m_nCurrentAcceleration = _G.Const.CONST_BATTLE_JUMP_ACCELERATION
    self.m_accRate=1

    self.m_lpBigHp = nil --大血条
    self.m_cutTime=0

    self.m_nTenacity = 0 --当前韧性值

    self.m_lpMovePos = nil
    self.m_deviation = 0
    -- self.m_skillIndex = 0

    --碰撞机配置
    self : setColliderXmlByID( self.m_SkinId)

    if self.m_stageView.m_lpMapData and self.m_stageView.m_lpMapData.id==10402 then
        self:addFlySpr()
    end
    if self.m_noLimit==1 then 
        self.setShadow=function () end
        self.convertLimitPos = function (self,x,y) return x,y end
    elseif  self.m_noLimit==2 then
        self.setShadow=function () end
        self.convertLimitPos = function (self,x,y) return x,y end
        self.m_lpMovieClip.setColor=function () end
        if self.m_backBody then
            self.m_backBody.setColor=function () end
        end
    end
    _fx,_fy=_fx or 0, _fy or 0
    if _type~=nil and _type>=_G.Const.CONST_MONSTER_JUMP and _type<=20 then
        self:initMovie(_fx,_fy,_type,_appera_skill)
    else
        self:setLocation(_fx,_fy,0)
        self:setStatus( _G.Const.CONST_BATTLE_STATUS_IDLE )
    end

    if self.m_nType==_G.Const.CONST_PLAYER
        or self.m_nType==_G.Const.CONST_PARTNER
        or self.m_nType==_G.Const.CONST_MONSTER then
        self:checkObstacleLimit()
    end

    if self.m_nMoveSpeedX == 0 and self.m_nMoveSpeedY == 0 then
        self:removeUpdateMove()
        self.setMovePos=function() end
        self.setLocation=function() end
    end
    self:setScalePer(self.m_scale)

    if self.m_stageView.m_lpMapData and self.m_stageView.m_lpMapData.yRatio and self.m_stageView.m_lpMapData.yRatio ~= 0 then
        local yRatio=self.m_stageView.m_lpMapData.yRatio
        local maxY,minY = self.m_stageView:getMapLimitHeight(self.m_nLocationX)
        local y = maxY-minY
        self.m_yRatio=(1-yRatio)/y
        self.onUpdateZOrder = function ( self )
            if self.m_lpZOrderCallBackPosY==self.m_nLocationY then
                return
            end
            self.m_lpContainer:setLocalZOrder(-self.m_nLocationY)
            self.m_lpZOrderCallBackPosY=self.m_nLocationY

            local maxY,minY = self.m_stageView:getMapLimitHeight(self.m_nLocationX)
            local scale = 1-(self.m_nLocationY-minY)*self.m_yRatio
            scale=scale/self.m_nScaleXPer
            if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_VARY) then
                local buff = self:getBuff(_G.Const.CONST_BATTLE_BUFF_VARY)
                scale=scale*buff.per
            end
            self:setScalePer(scale,true)
        end
    end
    if self.setName then
        self:setName( _szName )
    end
    self:setShadow()
    CCLOG("CBaseCharacter.init end self.m_nHP=%d,self.m_nMaxHP=%d,_fx=%d,_fy=%d",self.m_nHP,self.m_nMaxHP,_fx,_fy)
end

function CBaseCharacter.initMovie( self, _x, _y, _type, _appera_skill )
    -- print("initMovie============>>",debug.traceback())
    if _type==_G.Const.CONST_MONSTER_SKILL then
        if _appera_skill~=nil and _appera_skill~=0 then
            local statusFun=self.setStatus
            local thinkFun = self.think
            local onUpdateMoveFun = self.onUpdateMove
            self.setStatus=function() end
            self:removeThink()
            self:removeUpdateMove()
            self.m_noBeTarget=true
            self.m_lpMovieClip:setVisible(false)
            local function nFun()
                self.setStatus=statusFun
                self.think=thinkFun
                self.onUpdateMove=onUpdateMoveFun
                self.m_noBeTarget=nil
                self.m_lpMovieClip:setVisible(true)
                self:useSkill(_appera_skill)
            end
            self:setLocation(_x,_y,0)
            self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(nFun)))
        end
        return
    end


    local runTime = 0.7
    local fStartPosX = _x
    local fStartPosY = _y
    local convertLimitPosFunc = self.convertLimitPos
    self.convertLimitPos = function (self,_x,_y)
        return _x,_y
    end
    if _type == _G.Const.CONST_MONSTER_SLRUN then
        _type = _G.Const.CONST_MONSTER_RUN 
        runTime = 1.3
    end
    if _type == _G.Const.CONST_MONSTER_ROCKFALL then
        local moveY = 500
        local bornY = self.m_stageView.m_nMapBornY or 0
        if fStartPosY < bornY then
            moveY = -moveY
        else
            moveY = moveY
        end
        _y = _y + moveY
        runTime = 0.3
    elseif _type == _G.Const.CONST_MONSTER_RUN then
        local moveX = 500
        local bornX = self.m_stageView.m_nMapBornX or 0
        if fStartPosX < bornX then
            moveX = -moveX
        else
            moveX = moveX
        end
        _x = _x + moveX
    elseif _type == _G.Const.CONST_MONSTER_PATIAO then
        local moveX = 100
        local bornX = self.m_stageView.m_nMapBornX or 0
        if fStartPosX < bornX then
            moveX = -moveX
        else
            moveX = moveX
        end
        _x = _x + moveX
    -- elseif _type == _G.Const.CONST_MONSTER_XIAOTIAO or _type == _G.Const.CONST_MONSTER_DATIAO  then
    --     local moveX = 500
    --     local bornX = self.m_stageView.m_nMapBornX or 0
    --     if fStartPosX < bornX then
    --         moveX = -moveX
    --     else
    --         moveX = moveX
    --     end
    --     _x = _x + moveX
    end
    self:setLocation(_x,_y,0)

    local statusFun = self.setStatus
    local thinkFun = self.think
    local onUpdateMoveFun = self.onUpdateMove
    self:removeThink()
    self:removeUpdateMove()
    self.m_noBeTarget=true
    self:setMoveClipContainerScalex(-1)

    local function movieEnd()
        if self.m_movieEffect then
            self.m_movieEffect:removeFromParent(true)
            self.m_movieEffect=nil
        end

        self.setStatus = statusFun
        self.m_lpEffectContainer:removeAllChildren(true)
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
        self.m_noBeTarget=nil
        self.think=thinkFun
        self.onUpdateMove=onUpdateMoveFun
        self.convertLimitPos=convertLimitPosFunc
        self:setLocationXY(fStartPosX,fStartPosY)
        self.cancelMovie=function() end
    end
    self.cancelMovie=function(self)
        if _type == _G.Const.CONST_MONSTER_JUMP then
            self.m_lpContainer:stopAllActions()
            self.m_lpCharacterContainer:setVisible(true)
        elseif _type == _G.Const.CONST_MONSTER_RUN then
            self.m_lpContainer:stopAllActions()
            self.m_lpEffectContainer:stopAllActions()
        elseif _type == _G.Const.CONST_MONSTER_CANYING then
            self.m_lpMovieClip:stopAllActions()
            -- self.m_lpContainer:stopAllActions()
            self.m_lpEffectContainer:removeAllChildren(true)
            self.m_lpMovieClip:setOpacity(255)
        elseif _type == _G.Const.CONST_MONSTER_PATIAO then
            self.m_lpMovieClip:stopAllActions()
            self.m_lpContainer:stopAllActions()
            self.m_lpEffectContainer:removeAllChildren(true)
            -- self.m_lpCharacterContainer:setVisible(true)
            self.m_lpMovieClip:setOpacity(255)
        end
        movieEnd()
    end

    if _type == _G.Const.CONST_MONSTER_JUMP then
        self.m_lpCharacterContainer:setVisible(false)

        local function jumpingCallFunc()
            movieEnd()
            self.m_lpCharacterContainer : setVisible(true)
        end
        
        local jumpTo = cc.JumpTo:create(0.8,cc.p(fStartPosX,fStartPosY),150,1)
        local func = cc.CallFunc:create(jumpingCallFunc)
        self.m_lpContainer:runAction(cc.Sequence:create(jumpTo,func))
    elseif _type == _G.Const.CONST_MONSTER_RUN then
        local effectName = "spine/come7"
        local effect = _G.SpineManager.createSpine(effectName,1)
        effect:setPosition(0,0)
        self.m_lpEffectContainer:addChild(effect)
        effect:setAnimation(0,"idle",true)

        local bornX = self.m_stageView.m_nMapBornX
        if bornX ~= nil then
            if fStartPosX < bornX then
                self:setMoveClipContainerScalex(1)
            end
        end
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)
        self.setStatus=function() end
        local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
        local func1 = cc.CallFunc:create(movieEnd)
        self.m_lpContainer:runAction(cc.Sequence:create(moveTo,func1))
    elseif _type == _G.Const.CONST_MONSTER_PATIAO then
        local effectName = "spine/come1"
        self.m_movieEffect=_G.SpineManager.createSpine(effectName,0.7)
        self.m_movieEffect:setPosition(self.m_nLocationX,self.m_nLocationY)
        self.m_stageView.m_lpCharacterContainer:addChild(self.m_movieEffect,-600)
        self.m_movieEffect:setAnimation(0,"idle",false)
        -- self.m_lpMovieClip:setOpacity(0)

        local runTime = 0.5
        -- local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
        local function c()
            local tin = cc.FadeIn:create(0.5)
            local fun = cc.CallFunc:create(movieEnd)
            self:hideEskillEffect()
            self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        end
        local tin = cc.DelayTime:create(runTime)
        local fun = cc.CallFunc:create(c)
        -- self.m_lpContainer:setOpacity(100)
        self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        -- self.m_lpContainer:runAction(cc.Sequence:create(moveTo))

        -- self.m_lpCharacterContainer:setVisible(false)

        local function jumpingCallFunc()
            movieEnd()
            -- self.m_lpCharacterContainer : setVisible(true)
        end
        
        local jumpTo = cc.JumpTo:create(0.8,cc.p(fStartPosX,fStartPosY),150,1)
        local func = cc.CallFunc:create(jumpingCallFunc)
        self.m_lpContainer:runAction(cc.Sequence:create(jumpTo,func))

        _type=_G.Const.CONST_MONSTER_PATIAO
    elseif _type == _G.Const.CONST_MONSTER_CANYING then
        local effectName = "spine/come5"
        local effect = _G.SpineManager.createSpine(effectName,1.2)
        effect:setPosition(0,0)
        self.m_lpEffectContainer:addChild(effect)
        effect:setAnimation(0,"idle",false)
        self.m_lpMovieClip:setOpacity(0)
        local runTime = 0.5
        -- local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
        local function c()
            local tin = cc.FadeIn:create(0.5)
            local fun = cc.CallFunc:create(movieEnd)
            self:hideEskillEffect()
            self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        end
        local tin = cc.DelayTime:create(runTime)
        local fun = cc.CallFunc:create(c)
        -- self.m_lpContainer:setOpacity(100)
        self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        -- self.m_lpContainer:runAction(cc.Sequence:create(moveTo))
        _type=_G.Const.CONST_MONSTER_CANYING
    elseif _type == _G.Const.CONST_MONSTER_PACHU then
        local effectName = "spine/come1"
        local effect = _G.SpineManager.createSpine(effectName,0.7)
        effect:setPosition(0,0)
        self.m_lpEffectContainer:addChild(effect)
        effect:setAnimation(0,"idle",false)
        self.m_lpMovieClip:setOpacity(0)
        local runTime = 0.5
        -- local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
        local function c()
            local tin = cc.FadeIn:create(0.5)
            local fun = cc.CallFunc:create(movieEnd)
            self:hideEskillEffect()
            self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        end
        local tin = cc.DelayTime:create(runTime)
        local fun = cc.CallFunc:create(c)
        -- self.m_lpContainer:setOpacity(100)
        self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        -- self.m_lpContainer:runAction(cc.Sequence:create(moveTo))
        _type=_G.Const.CONST_MONSTER_CANYING
    elseif _type == _G.Const.CONST_MONSTER_GUANCAI then
        local effectName = "spine/come2"
        local effect = _G.SpineManager.createSpine(effectName,0.7)
        effect:setPosition(0,0)
        self.m_lpEffectContainer:addChild(effect)
        effect:setAnimation(0,"idle",false)
        self.m_lpMovieClip:setOpacity(0)
        local runTime = 0.7
        -- local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
        local function c()
            local tin = cc.FadeIn:create(0.5)
            local fun = cc.CallFunc:create(movieEnd)
            self:hideEskillEffect()
            self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        end
        local tin = cc.DelayTime:create(runTime)
        local fun = cc.CallFunc:create(c)
        -- self.m_lpContainer:setOpacity(100)
        self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        -- self.m_lpContainer:runAction(cc.Sequence:create(moveTo))
        _type=_G.Const.CONST_MONSTER_CANYING
    elseif _type == _G.Const.CONST_MONSTER_WHIRL then
        local effectName = "spine/come6"
        local effect = _G.SpineManager.createSpine(effectName,1)
        effect:setPosition(0,0)
        self.m_lpEffectContainer:addChild(effect)
        effect:setAnimation(0,"idle",true)
        self.m_lpMovieClip:setOpacity(0)
        local runTime = 0.5
        -- local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
        local function c()
            local tin = cc.FadeIn:create(0.5)
            local fun = cc.CallFunc:create(movieEnd)
            self:hideEskillEffect()
            self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        end
        local tin = cc.DelayTime:create(runTime)
        local fun = cc.CallFunc:create(c)
        -- self.m_lpContainer:setOpacity(100)
        self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        -- self.m_lpContainer:runAction(cc.Sequence:create(moveTo))
        _type=_G.Const.CONST_MONSTER_CANYING
    -- elseif _type == _G.Const.CONST_MONSTER_XIAOTIAO then
    --     local runTime = 0.5
    --     -- local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
    --     local function c()
    --         local tin = cc.FadeIn:create(0.5)
    --         local fun = cc.CallFunc:create(movieEnd)
    --         self:hideEskillEffect()
    --         self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
    --     end
    --     local tin = cc.DelayTime:create(runTime)
    --     local fun = cc.CallFunc:create(c)
    --     -- self.m_lpContainer:setOpacity(100)
    --     self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
    --     -- self.m_lpContainer:runAction(cc.Sequence:create(moveTo))

    --     self.m_lpCharacterContainer:setVisible(false)

    --     local function jumpingCallFunc()
    --         movieEnd()
    --         self.m_lpCharacterContainer : setVisible(true)

    --         local effectName = "spine/come4"
    --         local effect = _G.SpineManager.createSpine(effectName,0.7)
    --         effect:setPosition(0,0)
    --         self.m_lpEffectContainer:addChild(effect)
    --         effect:setAnimation(0,"idle",false)
    --         self.m_lpMovieClip:setOpacity(0)
    --     end
        
    --     local jumpTo = cc.JumpTo:create(0.8,cc.p(fStartPosX,fStartPosY),150,1)
    --     local func = cc.CallFunc:create(jumpingCallFunc)
    --     self.m_lpContainer:runAction(cc.Sequence:create(jumpTo,func))

    --     _type=_G.Const.CONST_MONSTER_PATIAO
    -- elseif _type == _G.Const.CONST_MONSTER_DATIAO then
    --     local effectName = "spine/come4"
    --     local effect = _G.SpineManager.createSpine(effectName,0.7)
    --     effect:setPosition(0,0)
    --     self.m_lpEffectContainer:addChild(effect)
    --     effect:setAnimation(0,"idle",false)
    --     self.m_lpMovieClip:setOpacity(0)
    --     local runTime = 0.5
    --     -- local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
    --     local function c()
    --         local tin = cc.FadeIn:create(0.5)
    --         local fun = cc.CallFunc:create(movieEnd)
    --         self:hideEskillEffect()
    --         self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
    --     end
    --     local tin = cc.DelayTime:create(runTime)
    --     local fun = cc.CallFunc:create(c)
    --     -- self.m_lpContainer:setOpacity(100)
    --     self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
    --     -- self.m_lpContainer:runAction(cc.Sequence:create(moveTo))

    --     self.m_lpCharacterContainer:setVisible(false)

    --     local function jumpingCallFunc()
    --         movieEnd()
    --         self.m_lpCharacterContainer : setVisible(true)
    --         local effectName = "spine/come3"
    --         local effect = _G.SpineManager.createSpine(effectName,0.7)
    --         effect:setPosition(0,0)
    --         self.m_lpEffectContainer:addChild(effect)
    --         effect:setAnimation(0,"idle",false)
    --         self.m_lpMovieClip:setOpacity(0)
    --     end
        
    --     local jumpTo = cc.JumpTo:create(0.8,cc.p(fStartPosX-50,fStartPosY),150,1)
    --     local func = cc.CallFunc:create(jumpingCallFunc)
    --     self.m_lpContainer:runAction(cc.Sequence:create(jumpTo,func))

    --     _type=_G.Const.CONST_MONSTER_PATIAO
    -- elseif _type == _G.Const.CONST_MONSTER_SLRUN then
    --     local effectName = "spine/come7"
    --     local effect = _G.SpineManager.createSpine(effectName,0.7)
    --     effect:setPosition(-20,-10)
    --     self.m_lpEffectContainer:addChild(effect)
    --     effect:setAnimation(0,"idle",false)

    --     local bornX = self.m_stageView.m_nMapBornX
    --     if bornX ~= nil then
    --         if fStartPosX < bornX then
    --             self:setMoveClipContainerScalex(1)
    --         end
    --     end
    --     self:setStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)
    --     self.setStatus=function() end
    --     local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
    --     local func1 = cc.CallFunc:create(movieEnd)
    --     self.m_lpContainer:runAction(cc.Sequence:create(moveTo,func1))
    elseif _type == _G.Const.CONST_MONSTER_FLY then
        local effectName = "spine/3631"
        local effect = _G.SpineManager.createSpine(effectName,0.7)
        effect:setPosition(0,200)
        self.m_lpEffectContainer:addChild(effect)
        effect:setAnimation(0,"idle",false)

        self.m_lpMovieClip : setOpacity(0)
        local time = cc.DelayTime:create(1)
        local tin = cc.FadeIn:create(2)
        local fun = cc.CallFunc:create(movieEnd)
        self.m_lpMovieClip:runAction(cc.Sequence:create(time,tin,fun))
    elseif _type == _G.Const.CONST_MONSTER_BOOM then
        local effectName = "spine/7206"
        local effect = _G.SpineManager.createSpine(effectName,0.4)
        self.m_lpEffectContainer:addChild(effect)
        effect:setAnimation(0,"idle",false)

        self.m_lpMovieClip : setOpacity(0)
        local tin = cc.FadeIn:create(1)
        local fun = cc.CallFunc:create(movieEnd)
        self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        _type=_G.Const.CONST_MONSTER_FLY
    elseif _type == _G.Const.CONST_MONSTER_CLIMB then
        self.m_lpMovieClip:setOpacity(0)
        local function c()
            if self.m_SkinId==20141 then
                self.m_lpMovieClip:setAnimation(0,"out",false)
            end
            local tin = cc.FadeIn:create(1)
            local fun = cc.CallFunc:create(movieEnd)
            self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        end
        local tin = cc.DelayTime:create(0)
        local fun = cc.CallFunc:create(c)
        self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        _type=_G.Const.CONST_MONSTER_FLY
    elseif _type == _G.Const.CONST_MONSTER_ROCKFALL then
        -- local effectName = "spine/6046"
        -- local effect = _G.SpineManager.createSpine(effectName,1)
        -- self.m_lpEffectContainer:addChild(effect)
        -- effect:setAnimation(0,"idle",false)
        -- self.m_lpMovieClip:setOpacity(0)
        local function c()
            local effectName = "spine/come3"
            local effect = _G.SpineManager.createSpine(effectName,0.7)
            effect:setPosition(0,-20)
            self.m_lpEffectContainer:addChild(effect)
            effect:setAnimation(0,"idle",false)
            if self.m_SkinId==20141 then
                self.m_lpMovieClip:setAnimation(0,"out",false)
                self.m_lpMovieClip:setOpacity(255)
            end
            local tin = cc.FadeIn:create(1)
            local fun = cc.CallFunc:create(movieEnd)
            -- self.m_lpMovieClip:setOpacity(100)
            self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))
        end
        -- local tin = cc.DelayTime:create(0.5)
        -- local fun = cc.CallFunc:create(c)
        -- self.m_lpMovieClip:setOpacity(100)
        -- self.m_lpMovieClip:runAction(cc.Sequence:create(tin,fun))

        local bornY = self.m_stageView.m_nMapBornY
        if bornY ~= nil then
            if fStartPosY < bornY then
                self:setMoveClipContainerScalex(1)
            end
        end
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)
        self.setStatus=function() end
        local moveTo = cc.MoveTo:create(runTime,cc.p(fStartPosX,fStartPosY))
        local func1 = cc.CallFunc:create(c)
        self.m_lpContainer:runAction(cc.Sequence:create(moveTo,func1))
        _type=_G.Const.CONST_MONSTER_JUMP
    else
        movieEnd()
    end    
    -- self.convertLimitPos = convertLimitPosFunc
end

function CBaseCharacter.cancelMovie(self)
end

function CBaseCharacter.checkObstacleLimit(self)
    local goodsMonsArray={}
    for k,v in pairs(_G.CharacterManager.m_lpGoodsMonsterArray) do
        table.insert(goodsMonsArray,v)
    end 
    for k,v in pairs(_G.CharacterManager.m_lpHookArray) do
        table.insert(goodsMonsArray,v)
    end 
    local limitLx,limitRx
    for k,v in pairs(goodsMonsArray) do
        if v.m_boxLimit~=nil then
            if self.m_nLocationX>=v.m_boxLimit then
                if limitLx==nil then
                    limitLx=v.m_boxLimit
                elseif limitLx<v.m_boxLimit then
                    limitLx=v.m_boxLimit
                end
            elseif self.m_nLocationX<v.m_boxLimit then
                if limitRx==nil then
                    limitRx=v.m_boxLimit
                elseif limitRx>v.m_boxLimit then
                    limitRx=v.m_boxLimit
                end
            end
        end
    end
    if limitLx ~= nil then
        limitLx = limitLx + 40
    end
    if limitRx ~= nil then
        limitRx = limitRx - 40
    end
    self.m_obstacleLimitLx=limitLx
    self.m_obstacleLimitRx=limitRx
end

function CBaseCharacter.setBlock(self,offsetX,offsetY,vWidth,vHeight,offsetZ,vRange)
    local scaleX = self.m_nScaleX or 1
    if scaleX > 0 then
        offsetX = offsetX
    else
        offsetX = -offsetX - vWidth
    end

    if self.blockLayer==nil then
        return
    end
    self.blockLayer:setContentSize(cc.size(vWidth,vHeight))
    self.blockLayer:setPosition(offsetX,offsetY)
end

function CBaseCharacter.setBlockByColliderId(self,colliderId)
    local colliderData=_G.g_SkillDataManager:getSkillCollider(colliderId)
    if colliderData==nil then
        colliderData=_G.g_SkillDataManager:getSkillCollider(1)
    end
    self:setBlock(colliderData.offsetX,colliderData.offsetY,colliderData.vWidth,colliderData.vHeight,colliderData.offsetZ,colliderData.vRange)
end

function CBaseCharacter.setBlockByCollider(self,collider)
    if collider==nil then
        collider=_G.g_SkillDataManager:getSkillCollider(1)
    end
    self:setBlock(collider.offsetX,collider.offsetY,collider.vWidth,collider.vHeight,collider.offsetZ,collider.vRange)
end

function CBaseCharacter.setProperty(self,_property)
    self.m_property=_property
end

function CBaseCharacter.getProperty(self)
    return self.m_property
end

function CBaseCharacter.getWarAttr( self )
    return self.m_warAttr
end

function CBaseCharacter.setWarAttr(self,attr)
    self.m_warAttr = attr : clone()
end

function CBaseCharacter.isSkillCD( self, _skillID )
    if self.m_SkillCDTab[_skillID] == nil then
        return false
    else
        return _G.TimeUtil:getTotalMilliseconds()<self.m_SkillCDTab[_skillID]
    end
end

function CBaseCharacter.setSkillCD( self, _skillID, _fCooldownInterval )
    local cdTimes=_fCooldownInterval*1000+_G.TimeUtil:getTotalMilliseconds()
    self.m_SkillCDTab[_skillID]=cdTimes
    if self.m_skillCDCall then
        -- _G.Scheduler:performWithDelay(_fCooldownInterval,self.m_skillCDCall)
        self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(_fCooldownInterval),cc.CallFunc:create(self.m_skillCDCall)))
    end
end

function CBaseCharacter.getSkinID( self )
    return self.m_SkinId
end

function CBaseCharacter.setBorder( self )
    local collider = self : getCollider()
    if collider == nil then
        return
    end
    self.m_nBorder = collider.vWidth + collider.offsetX
end

function CBaseCharacter.getMonsterXMLID( self )
    return self.m_monsterId or 0
end

function CBaseCharacter.setMonsterXMLID( self, _xmlID )
    self.m_monsterId = _xmlID
end

function CBaseCharacter.getLv( self )
    return self.m_nLv
end
function CBaseCharacter.setLv( self, _nLv )
    self.m_nLv = _nLv
end

function CBaseCharacter.setXSpeedZero( self )
    self.m_fXSpeed = nil
end

--设置竞技场血量
-- function CBaseCharacter.setArenaHp( self )
--     self.m_nMaxHP=self.m_nMaxHP*_G.Const.CONST_ARENA_ATTR_HP_TIMES
--     self:setFull()
-- end

function CBaseCharacter.setCollider( self, _collider )
    self.m_lpCurrentCollider = _collider
    self:setBlockByCollider(_collider)
end
function CBaseCharacter.getCollider( self )
    return self.m_lpCurrentCollider
end

function CBaseCharacter.getWorldCollider( self )
    if self.m_lpContainer== nil then
        return
    end
    if self.m_lpCurrentCollider==nil then
        self:setColliderXmlByID(10001)
    end
    -- print("SSSSSSSSSSSSSSSSSSSSS========>>>>",debug.traceback())
    local colliderNode = self.m_lpCurrentCollider

    local offsetX = colliderNode.offsetX
    local offsetY = colliderNode.offsetY
    local vWidth = colliderNode.vWidth
    local vHeight =colliderNode.vHeight
    local scaleX = self.m_nScaleX or 1
    local vX = nil
    if scaleX>=0 then
        vX = offsetX + self.m_nLocationX
    else
        vX = -offsetX + self.m_nLocationX - vWidth
    end
    local vY = offsetY + self.m_nLocationY

    -- print(vY,self.m_nLocationY,vHeight,colliderNode.vHeight,"getWorldCollider")
    return vX, vY, vWidth, vHeight
end

-- {设置碰撞机}
function CBaseCharacter.setColliderXmlByID( self, _skinID )
    _skinID=_skinID or 10001
    -- self.currentColliderId=_skinID
    print(_skinID,"@$%%")
    local colliderData=_G.g_SkillDataManager:getSkinData(_skinID).collider
    self:setCollider( colliderData )
end

--根据人物皮肤设置碰撞机
function CBaseCharacter.setColliderXml( self, _nStatus, _skinID )
    self:setColliderXmlByID(_skinID)
end

function CBaseCharacter.clearAiAttackSkill(self)
    self.m_attackSkillData=nil

    if self.aiBlockLayer then
        self.aiBlockLayer:setColor(cc.c4b(0,0,255,50))
        self.aiBlockLayer:setOpacity(50)
    end
end

function CBaseCharacter.releaseSkillResource(self)
    if self.m_curUseSkillEffectObjArray then
        self:hideEskillEffect()
    end
    if self.m_hurtTable and self.m_hurtTable.showSpine then
        _G.StageObjectPool:freeObject(self.m_hurtTable.showSpine)
        self.m_hurtTable.showSpine=nil
    end
end

function CBaseCharacter.setBodySkinId(self,_skinID)
    if _skinID and self.m_lpMovieClip then
        self.m_lpMovieClip:setSkin(tostring(_skinID))
    end
end
function CBaseCharacter.releaseResource( self )
    if self.m_lpMovieClip~=nil then
        self.m_lpMovieClip:removeFromParent(true)
        self.m_lpMovieClip=nil
    end

    if self.m_lpContainer~=nil then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
    self:destoryBigHpView()
    self:removeAllClones()
    
    print("CBaseCharacter.releaseResource self.m_nID=",self.m_nID)
end

function CBaseCharacter.showDead(self,_noEffect)
    if self.m_lpContainer==nil then return end

    self:destoryBigHpView()
    self.m_noBeTarget=true

    local function actionCallFunc()
        if self.m_stageView~=nil then
            self.m_stageView:removeCharacter(self)
        end
    end
    if self.m_isCorpse then
        self:removeAllBuff()
        actionCallFunc()
        return
    end
    if self.m_flySpr~=nil then
        self.m_flySpr:setAnimation(0,"dead",false)
    end

    if self.m_lpHurtStringContainer~=nil then
        self.m_lpHurtStringContainer:removeAllChildren(true)
        self.m_lpHurtStringContainer = nil
    end

    if _noEffect then
        actionCallFunc()
        return
    end

    local pSprite = cc.Sprite:create()
    pSprite:setPosition(0,80)
    self.m_lpContainer:addChild(pSprite)

    local animation = _G.AnimationUtil:getRoleDeadAnimate()
    local func = cc.CallFunc:create(actionCallFunc)
    pSprite:runAction(cc.Sequence:create(animation,func))
    self.m_lpMovieClip:runAction(cc.FadeOut:create(0.2))
end

function CBaseCharacter.animationCallFunc( self,eventType, arg0, event, arg2, arg3  )
    if eventType == "complete" then
        if arg0 == "idle" or arg0 == "move" or arg0 == "m_idle" or arg0 == "m_move" or arg0 == "idle2" then return end
        self:onAnimationCompleted( eventType, arg0,event )
    end
end

function CBaseCharacter.onAnimationCompleted( self, eventType, _animationName,event )
    if _animationName == "dead" then
        -- print("animationCallFunc====>>>>>>dead")
        self.m_nAI=0
        local function actionCallFunc()
            self:showDead()
        end
        local delay=cc.DelayTime:create(0.5)
        local func=cc.CallFunc:create(actionCallFunc)
        self.m_lpContainer:runAction(cc.Sequence:create(delay,func))
        return
    elseif _animationName == "dead2" then
        -- print("animationCallFunc====>>>>>>dead2")
        self.m_nAI=0
        local function actionCallFunc()
            self:showDead()
        end
        local delay=cc.DelayTime:create(0.01)
        local func=cc.CallFunc:create(actionCallFunc)
        self.m_lpContainer:runAction(cc.Sequence:create(delay,func))
        return
    elseif _animationName == "fall" then
        self.m_nNextSkillID = 0
        local function c()
            if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_FALL then
                self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
                if self.m_climb~=nil then
                    local data=_G.g_SkillDataManager:getSkillData(self.m_climb)
                    if data.type==_G.Const.CONST_SKILL_DODGE_SKILL then
                        local dir=gc.MathGc:random_0_1()>0.5 and 1 or -1
                        self:setMoveClipContainerScalex(dir)
                    elseif self.m_nTarget then
                        -- self:adjustDirect(self.m_nTarget)
                        local nScalex=self:getDirectWithThis(self.m_nTarget)
                        self:setMoveClipContainerScalex(nScalex)
                    end
                    if self.m_climbBuff then
                        local invBuff=_G.GBuffManager:getBuffNewObject(self.m_climbBuff,0)
                        self:addBuff(invBuff)
                    end
                    self:useSkill(self.m_climb)
                end
            end
        end
        self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(c)))
        return
    elseif _animationName == "hurt" or _animationName == "hurt2" then
        if not self:isHaveBuff( _G.Const.CONST_BATTLE_BUFF_RIGIDITY) then
            if self:getLocationZ() <= 1 then
                self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
            end
        end
        return
    elseif _animationName == "out" then
        self.m_lpMovieClip:setAnimation(0,self.m_idleName,true)
        return
    elseif _animationName == "crash" then
        return
    -- else
        -- local animationName,num = string.gsub(_animationName , "pre(%d+)", "%1")
        -- if num~=0 and self.m_preSkillNumData and type(self.m_preSkillNumData)=="table" then
        --     self.m_preSkillNum=self.m_preSkillNum
        --     if self.m_preSkillNum==nil then
        --         for k,v in pairs(self.m_preSkillNumData) do
        --             if v[1]==self.m_preSkillId then
        --                 self.m_preSkillNum=v[2]
        --             end
        --         end
        --     end
        --     if event.loopCount>=self.m_preSkillNum then
        --         self:hideEskillEffect()
        --         self:sureUseskill(self.m_preSkillId,self.m_preSkillData)
        --     end
        -- end
    end

    local animationName = string.gsub(_animationName , "skill_(%d+)", "%1")
    local nSkillID = tonumber(animationName)
    if nSkillID~=nil then
        if self.m_completeSkill then
            self:setStatus(Const.CONST_BATTLE_STATUS_IDLE)
            self:hideMonster()
            return
        end
        self.m_nSkillDuration = 0
        self.m_nSkillID = 0

        self:setStatus(Const.CONST_BATTLE_STATUS_IDLE)

        if self.m_isShowState==true then
            self:setLocationXY(0,0)
            return
        end

        local useNextSkillID=nil
        if self.m_nNextSkillID~=0 then
            useNextSkillID=self.m_nNextSkillID
            self.m_nNextSkillID = self.m_nNextSkillID2
            self.m_nNextSkillID2 = self.m_nNextSkillID3
            self.m_nNextSkillID3 = 0
        end
        if useNextSkillID~=nil and useNextSkillID~=nSkillID then
            self:useSkill(useNextSkillID)
        end
    end

end

function CBaseCharacter.setMovePos(self, _movePos)
    if _movePos~=nil and self.m_lpContainer~=nil then
        if self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_IDLE
            and self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_MOVE then
            return
        end

        if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN)
           or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY) then
            return
        end
        
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)

        if not self.isPlotMonster then
            self.m_lpMovePos=cc.p(self:convertLimitPos(_movePos.x, _movePos.y))
        else
            self.m_lpMovePos=_movePos
        end

        if self.m_nLocationX<=self.m_lpMovePos.x then
            self:setMoveClipContainerScalex(1)
            self.m_lpMovePos.scaleX=1
        else
            self:setMoveClipContainerScalex(-1)
            self.m_lpMovePos.scaleX=-1
        end

        if self.m_enableBroadcastMove then
            self.m_stageView:onRoleMove(self,self.m_lpMovePos.x,self.m_lpMovePos.y,0,false)
        end
    end
end

function CBaseCharacter.cancelMove( self )
    self.m_lpMovePos = nil
    if self.m_nStatus == Const.CONST_BATTLE_STATUS_MOVE then
        self : setStatus(Const.CONST_BATTLE_STATUS_IDLE)
        if self.m_enableBroadcastMove then
            self.m_stageView:onRoleMove(self,self.m_nLocationX,self.m_nLocationY,self.m_nScaleX,false)
        end
    elseif self.m_enableBroadcastMove then
        self.m_stageView:onRoleMove(self,self.m_nLocationX,self.m_nLocationY,self.m_nScaleX,true)
    end
end

function CBaseCharacter.cancelTSpeed( self )
    self.m_TSpeed=nil
end

function CBaseCharacter.getID( self )
    return self.m_nID
end


function CBaseCharacter.getType( self )
    return self.m_nType
end

function CBaseCharacter.setType( self, _nType )
    self.m_nType = _nType
end

function CBaseCharacter.setColor(self, _rgb )
    if self.m_lpName~=nil then
        self.m_lpName:setColor( _rgb )
    end
end

function CBaseCharacter.getName( self )
    return self.m_szName
end

function CBaseCharacter.getHP( self )
    return self.m_nHP
end

function CBaseCharacter.getMaxHp( self )
    return self.m_nMaxHP
end
function CBaseCharacter.setMaxHp( self, _nMaxHP )
    self.m_nMaxHP = _nMaxHP
end
function CBaseCharacter.getMaxSp( self )
    return self.m_nMaxSP
end

function CBaseCharacter.setHP( self, _nHP, _noEffect)
    -- print("CBaseCharacter.setHP   _nHP=",_nHP," self.m_nHP=",self.m_nHP,"self.m_SkinId=",self.m_SkinId)
    -- if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_CITY then return end
    
    if self.m_nHP == _nHP or self.m_nHP <= 0 then
        return
    end
    local deadHP=_nHP
    _nHP=_nHP<=0 and 0 or _nHP
    _nHP=_nHP>=self.m_nMaxHP and self.m_nMaxHP or _nHP

    if self.m_buffHp and self.m_buffHp>_nHP then
        return
    end

    self.m_nHP = _nHP

    if self.m_triggerHp~=nil then
        local nowHpPer=self.m_nHP/self.m_nMaxHP*100
        local triggerPer=self.m_triggerHp
        if nowHpPer<triggerPer then
            self:setAI(self.m_triggerAI)
            self.m_attackSkillDatas=nil
            self.m_triggerHp=nil
        end
    end
    if self.m_shieldHpNum~=nil and self.m_shieldHpNum>self.m_nHP then
        self:removeBuff(_G.Const.CONST_BATTLE_BUFF_SHIELD)
    end
    -- print("setHP--------->>>>>>  111",self.m_szName)
    if self.m_lpBigHp ~= nil then
        -- print("setHP--------->>>>>>  222",self.m_szName)
       self.m_lpBigHp : setHpValue(self.m_nHP, self.m_nMaxHP, _noEffect)
    end

    if self.m_cloneList ~= nil then
        if self.m_nHP<=0 then
            if self.m_cloneList~=nil then
                for _,v in pairs(self.m_cloneList) do
                    v.m_nHP = _nHP
                    v.m_noBeTarget=nil
                    self:removeClone(v)
                end
                self.m_cloneList=nil
            end
        else
            for _,v in pairs(self.m_cloneList) do
                v.m_nHP = _nHP
            end
        end
    end

    if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_PK_LY and self.m_nType==_G.Const.CONST_PARTNER then
        self.m_stageView:setLingYaoHp(self,_nHP)
    end

    --地面死亡
    if self.m_nHP<=0 then --and self : getLocationZ() <= 0 then 
        self:cancelTSpeed()
        -- print("AAAAAAAAAAAAA===>>>",self.m_nID)
        self:removeBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN)
        self:removeBuff(_G.Const.CONST_BATTLE_BUFF_STOP_ACTION)


        if self.m_deadBuff and self.m_deadBuffTarget then
            for _,monster in pairs(_G.CharacterManager:getMonster()) do
                if monster.m_SkinId==self.m_deadBuffTarget then
                    local invBuff= _G.GBuffManager:getBuffNewObject(self.m_deadBuff, 0)
                    monster:addBuff(invBuff)
                end
            end
        end

        if self.m_nType==_G.Const.CONST_PARTNER then
            if self.m_boss and self.m_boss.m_parHp~=nil then
                self:reborn(self.m_nMaxHP*self.m_boss.m_parHp)
                return
            end
        elseif self.m_nType==_G.Const.CONST_PLAYER then
            -- 离开或时间到血量为-12345
            if deadHP==-12345 then
                self.m_playHp=nil
                self:cancelReborn()
            end
            if self.m_playHp~=nil and not self.m_isRebornYet then
                local rebornHp=self.m_property:getAttr():getMaxHp()*self.m_playHp
                self:reborn(rebornHp)
                return
            end
        end
        CCLOG("CBaseCharacter.setHP  死亡飞起")

        if self.m_deadAction and self.m_nLocationZ<=0 then
            return
        end

        local monsterRank=self:getMonsterRank()
        if not(monsterRank and monsterRank>=_G.Const.CONST_MONSTER_RANK_BOSS_SUPER) and not self.m_isMountBattle then
            local _Angle=_G.Const.CONST_BATTLE_DEAD_ANGLE
            local tempScaleX=self.m_thrustScaleX or self.m_nScaleX
            if tempScaleX>0 then
                _Angle = math.abs(_Angle)-180
            end
            self.m_sceFly=nil
            self:thrust( _G.Const.CONST_BATTLE_DEAD_SPEED, _Angle , _G.Const.CONST_BATTLE_DEAD_ACCELERATION )
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_CRASH)
        end
        if self.m_skinData.dead_sound~=nil then
            if self.isMainPlay or self.m_stageView.m_onUpdateCharcterCount<10 then
                _G.Util:playBattleEffect(self.m_skinData.dead_sound)
            end
        end
        self.m_noBeTarget=true

        if self.m_nType == _G.Const.CONST_MONSTER then
            if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_BOX then return end
            if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_CITY_BOSS then return end

            local monsterRank = self:getMonsterRank()
            if monsterRank and monsterRank>=_G.Const.CONST_MONSTER_RANK_BOSS_SUPER then
                self:removeThink()
                self.thrust=function() end
                self.Translation=function() end

                local i = 1
                local actions = {{name="fall",loop=false},{name="dead",loop=false}}
                self.m_stageView:slowMotion()
                self:setLocationZ(0)

                self.m_stageView:stopAllCharacterAI()
                self.onAnimationCompleted = function()
                    local action = actions[i]
                    if action == nil then return end
                    print(actions[i].name,actions[i].loop,"actions[i].name,actions[i].loop")
                        -- self.m_lpMovieClip:setToSetupPose()
                    self.m_lpMovieClip:setAnimation(0,actions[i].name,actions[i].loop)
                    if i ~= #actions then i = i + 1 return end
                
                    self.m_nAI=0
                    if self.m_flySpr==nil then
                        self.m_isCorpse=true
                    end
                    local function actionCallFunc()
                        self:showDead()
                    end
                    self.onAnimationCompleted=function()end

                    local delay=cc.DelayTime:create(0.5)
                    local func=cc.CallFunc:create(actionCallFunc)
                    self.m_lpContainer:runAction(cc.Sequence:create(delay,func))
                        
                end
                self.setStatus=function() end
                self:onAnimationCompleted()
                if self.m_stageView.m_sceneType ~= _G.Const.CONST_MAP_CLAN_DEFENSE and monsterRank >= _G.Const.CONST_MONSTER_RANK_BOSS_SUPER then
                    --boss死，众兵亡
                    local list =  _G.CharacterManager:getMonster()
                    for _,monsterC in pairs(list) do
                        if not monsterC.isPlotMonster then
                            if monsterC.isPartner~=true then
                                monsterC:setHP(0)
                            end
                        end
                    end
                end
            else
                if self.m_stageView.isBossBattle~=true then
                    if self.m_stageView:isLastMonster()==true then
                        self.m_stageView:passWar()
                    end
                end
            end
        elseif self.m_nType == _G.Const.CONST_PLAYER then
            self.m_isCorpse=true
            self.m_noBeTarget=true
            self.m_parHp=nil
            if self.isMainPlay then
                
                for _,v in pairs(_G.CharacterManager.m_lpHookArray) do
                    v.m_noUpdate = true                                
                end
                for _,v in pairs(_G.CharacterManager.m_lpGoodsMonsterArray) do
                    v.m_noUpdate = true                                
                end

                self.m_stageView.m_slowMotion=true
                if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_NORMAL
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_HERO
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_FIEND
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_FIGHTERS
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_ROAD
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_KOF
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_THOUSAND
                         then  
                        local property = _G.GPropertyProxy:getOneByUid( self:getID(), characterType )
                        local warPartner=self.m_property:getWarPartner()
                        if warPartner~=nil then
                            local roleUid=self.m_property:getUid()
                            local partnerIdx=warPartner:getPartner_idx()
                            local indexId= tostring(roleUid)..tostring(partnerIdx)
                            local partner=_G.CharacterManager:getCharacterByTypeAndID(_G.Const.CONST_PARTNER,indexId)
                            if partner~=nil then
                                partner:setHP(0)
                            end
                        end
                        local list = _G.CharacterManager:getCharacter()
                        for k,character in pairs(list) do
                            if character.setAI then
                                character:setAI(0)
                            end
                        end
                        self:removeWing()
                        self.m_stageView.m_slowMotion=nil
                -- elseif self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_THOUSAND then
                        -- self.showDead = function ( )
                        --     self.m_stageView:removeKeyBoardAndJoyStick()
                        --     self.m_stageView:IkkiTousen_finishCopy()
                        -- end
                        -- self.m_stageView.m_slowMotion=nil
                elseif self.m_stageView.m_sceneType==_G.Const.CONST_MAP_CLAN_WAR then
                    self.m_stageView:addClanWarDeadAction()
                -- elseif self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then
                --     self.m_stageView.m_slowMotion=nil
                elseif self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
                    _G.g_BattleView:conditionSubRole()
                end

                self.m_stageView:slowMotionDead()
            elseif self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL 
                        or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_KOF then
                local list = _G.CharacterManager:getCharacter()
                for k,character in pairs(list) do
                    if character.setAI then
                        character:setAI(0)
                    end
                end
                self:removeWing()
                self.m_stageView:slowMotion()
                return
            elseif self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
                _G.g_BattleView:conditionSubRole()
            end
        end
    end
end

function CBaseCharacter.addHP(self,_nHP,_crit,_bleed)
    local currentHP=self.m_nHP+_nHP
    if self.m_subject == nil then
        self:setHP(currentHP)
    else
        self.m_subject:setHP(currentHP)
    end
    if _nHP<0 then
        if _crit then
            self:showCritHurtNumber(_nHP)
        else
            if _bleed then
                self:showBleedHurtNumber(_nHP)
            else
                self:showNormalHurtNumber(_nHP)
            end
        end
    end
end

function CBaseCharacter.getSP( self )
    return self.m_nSP
end

function CBaseCharacter.setSP( self, _nSP )
    self.m_nSP = _nSP
    self.m_nSP = self.m_nSP <= 0 and 0 or self.m_nSP
    self.m_nSP = self.m_nSP > self.m_nMaxSP and self.m_nMaxSP or self.m_nSP
    if self.m_lpBigHp then
        self.m_lpBigHp:setSpValue( self.m_nSP , self.m_nMaxSP )

        -- if self.isMainPlay and self.m_stageView.m_keyBoard then
        --     self.m_stageView.m_keyBoard:isBlackOrColor()
        -- end
    end
end

function CBaseCharacter.canSubSp( self, _nSP )
    return self.m_nSP>=-_nSP
end

function CBaseCharacter.addSP( self, _nSP )
    if self.m_nSP==self.m_nMaxSP and _nSP>0 then return end
    self:setSP(self.m_nSP + _nSP)
end

function CBaseCharacter.canSubMp( self, _nMP )
    return self.m_nMP>=-_nMP
end

function CBaseCharacter.getMP(self)
    return self.m_nMP
end

function CBaseCharacter.setMP(self,_nMP)
end

function CBaseCharacter.addMP(self, _nMP)
end

function CBaseCharacter.setFull( self )
    self :setHP( self.m_nMaxHP )
    self :setSP( self.m_nMaxSP )
end

function CBaseCharacter.getContainer( self )
    return self.m_lpContainer
end

--获取当前生物的X轴比例
function CBaseCharacter.getScaleX( self )
    return self.m_nScaleX or 1
end

--设置当前生物X轴比例
function CBaseCharacter.setScaleX( self ,_ScaleX )
    self.m_nScaleX = _ScaleX
end

--设置当前生物放缩比例
function CBaseCharacter.setScalePer( self,per,isMoment )
    self.m_nScaleXPer = self.m_nScaleXPer * per
    self.m_skeletonHeight = self.m_skeletonHeight * per
    if not isMoment then
        local scale = cc.ScaleTo:create(0.1,self.m_nScaleXPer)
        self.m_lpMovieClipContainer:runAction(scale)
        self.m_lpEffectContainer:runAction(scale:clone())
        self.m_lbEffectContainer:runAction(scale:clone())
        self.m_lpHurtStringContainer:runAction(scale:clone())
    else
        self.m_lpMovieClipContainer:setScale(self.m_nScaleXPer)
        self.m_lpEffectContainer:setScale(self.m_nScaleXPer)
        self.m_lbEffectContainer:setScale(self.m_nScaleXPer)
        self.m_lpHurtStringContainer:setScale(self.m_nScaleXPer)
    end
    self:resetNamePos()
    local colliderData = {
        vWidth=self.m_lpCurrentCollider.vWidth * per,
        vHeight=self.m_lpCurrentCollider.vHeight * per,
        offsetX=self.m_lpCurrentCollider.offsetX * per,
        offsetY=self.m_lpCurrentCollider.offsetY * per
    }
    self.m_lpCurrentCollider = colliderData
    self:setBlock(self.m_lpCurrentCollider.offsetX,self.m_lpCurrentCollider.offsetY,self.m_lpCurrentCollider.vWidth,self.m_lpCurrentCollider.vHeight,self.m_lpCurrentCollider.offsetZ,self.m_lpCurrentCollider.vRange)
end

function CBaseCharacter.setMoveClipContainerScalex( self, _ScaleX )
    -- print("setMoveClipContainerScalex==>>",_ScaleX,debug.traceback())
    if self.m_nScaleX==_ScaleX 
        or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN)
        -- or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY)  
        then
        return
    elseif self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_USESKILL then
        if not self.m_isMoveAndSkill then
            local tempBuff=self:getBuff(_G.Const.CONST_BATTLE_BUFF_SKILL_MOVE)
            if not tempBuff or tempBuff.data~=1 then
                return
            end
        end
        self:resetSkillEffectObjectScaleX(_ScaleX)
    end
    
    self:setScaleX(_ScaleX)
    self.m_lpCharacterContainer : setScaleX( self.m_nScaleX )
    if self.m_flySpr~=nil then
        self.m_flySpr:setScaleX(self.m_nScaleX)
    end
    if self.m_backBody then
        self.m_backBody:setScaleX(self.m_skinScale*self.m_nScaleX)
    end
    if self.aiBlockLayer then
        self:setAIBlockWithCollider(self.aiCollider)
    end
    if self.blockLayer then
        self:setBlock(self.m_lpCurrentCollider.offsetX,self.m_lpCurrentCollider.offsetY,self.m_lpCurrentCollider.vWidth,self.m_lpCurrentCollider.vHeight,self.m_lpCurrentCollider.offsetZ,self.m_lpCurrentCollider.vRange)
    end
end

function CBaseCharacter.adjustDirect(self,_target)
    if self.m_noLimit~=nil then return end
    local toDirect=self:getDirectWithThis(_target)
    if not(self:isHaveBuff( _G.Const.CONST_BATTLE_BUFF_ENDUCE) or self:isHaveBuff( _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER)) then
        -- self:setMoveClipContainerScalex(toDirect)
        self.m_thrustScaleX=toDirect
    end
    
    return toDirect
end
function CBaseCharacter.getDirectWithThis(self,_target)
    if self.m_nLocationX>_target.m_nLocationX+_target.m_deviation then
        return -1
    else
        return 1
    end
end

--根据角度翻转生物
-- function CBaseCharacter.setflipHorizontal( self, _angle )
--     --反转显示
--     _angle = math.abs(_angle)
--     local scaleX = 1
--     if _angle > 90 then
--         scaleX = 1
--     end
--     if _angle < 90 then
--         scaleX = -1
--     end
--     self : setMoveClipContainerScalex( scaleX )
-- end

-- function CBaseCharacter.setStage( self, _lpStage )
--     self.m_lpStage = _lpStage
-- end

-- function CBaseCharacter.getStage( self )
--     return self.m_lpStage
-- end

function CBaseCharacter.onUpdateZOrder( self )
    if self.m_lpZOrderCallBackPosY==self.m_nLocationY then
        return
    end
    self.m_lpContainer:setLocalZOrder(-self.m_nLocationY)
    self.m_lpZOrderCallBackPosY=self.m_nLocationY
end

function CBaseCharacter.setZOrder( self, _z )
    self.m_lpContainer:setLocalZOrder( _z )
end

--设置生物X坐标
function CBaseCharacter.setLocationX( self, _x )
    self:setLocation( _x, self.m_nLocationY, self.m_nLocationZ)
end
--获取生物X坐标
function CBaseCharacter.getLocationX( self )
    return self.m_nLocationX
end

--设置生物Y坐标
function CBaseCharacter.setLocationY( self, _y )
    self:setLocation( self.m_nLocationX, _y, self.m_nLocationZ)
end
--获取生物Y坐标
function CBaseCharacter.getLocationY( self )
    return self.m_nLocationY
end

--设置生物Z坐标
function CBaseCharacter.setLocationZ( self, _z )
    self:setLocation(self.m_nLocationX,self.m_nLocationY, _z )
end
--获取生物Z坐标
function CBaseCharacter.getLocationZ( self )
    self.m_nLocationZ=self.m_nLocationZ or 0
    return self.m_nLocationZ
end

--设置生物X,Y坐标
function CBaseCharacter.setLocationXY( self, _x, _y )
    self:setLocation( _x, _y, self.m_nLocationZ )
end
--获取生物X,Y坐标
function CBaseCharacter.getLocationXY( self )
    return self.m_nLocationX, self.m_nLocationY
end

function CBaseCharacter.convertLimitX( self,_x )
    local stage=self.m_stageView
    local lx = stage:getMaplx()
    local rx = stage: getMaprx()
    lx = lx + 80
    rx = rx - 80
    if _x>rx or _x<lx then
        return true
    else
        return false
    end
end

function CBaseCharacter.convertLimitPos( self, _x , _y )
    local stage=self.m_stageView
    if stage~=nil and stage:getCanControl() == true then
        local lx = stage:getMaplx()
        -- if (self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_BOSS or self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_CLAN_BOSS) 
        --         and self:getType() == _G.Const.CONST_MONSTER then
        --     lx = _G.Const.CONST_BOSS_SECURITY_X + 1
        -- end
        local rx = stage: getMaprx()


        if self.m_obstacleLimitLx ~= nil then
            lx = self.m_obstacleLimitLx
        end
        if self.m_obstacleLimitRx ~= nil then
            rx = self.m_obstacleLimitRx
        end
        lx = lx + 80
        rx = rx - 80

        -- local isCancelMove = false
        if _x <= lx then
            _x=lx
            -- isCancelMove=true
        elseif _x >= rx then
            _x=rx
            -- isCancelMove=true
        end

        local maxY,minY = stage:getMapLimitHeight(_x)

        if self.m_nType==_G.Const.CONST_MONSTER then
            minY=minY+10
            maxY=maxY-10
            if _y <= minY then
                _y = minY + 1
            elseif _y >= maxY then
                _y = maxY - 1
            end
        end

        if _y <= minY then
            _y=minY
            -- isCancelMove=true
        elseif _y >= maxY then
            _y=maxY
            -- isCancelMove=true
        end
        -- if isCancelMove and self.m_nAI and self.m_nAI~=0 then
        --     self:cancelMove()
        -- end
    end
    return _x,_y
end

--设置生物坐标， x,y,z
function CBaseCharacter.setLocation( self, _x, _y, _z )
    _z = _z < 0 and 0 or _z
    -- if _y + _z < _y then
    --     return
    -- end

    _x=math.floor(_x)
    _y=math.floor(_y)
    _z=math.floor(_z)

    if not self.isPlotMonster then
        _x,_y = self:convertLimitPos( _x, _y)
    end
    self.m_nLocationX = _x
    self.m_nLocationY = _y
    self.m_nLocationZ = _z

    self : getContainer() : setPosition( _x, _y)
    self.m_lpCharacterContainer:setPosition(0,_z)
    self:onUpdateZOrder()
    self:resetSkillEffectObjectPos()
end

function CBaseCharacter.jump( self )
    if self.m_nStatus==Const.CONST_BATTLE_STATUS_USESKILL or
        self.m_nStatus==Const.CONST_BATTLE_STATUS_JUMP or
        self.m_nLocationZ>0 then
        return
    end
    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_LOCKZ) then
        return
    end

    self:thrust(_G.Const.CONST_BATTLE_JUMP_THRUST,-90,_G.Const.CONST_BATTLE_JUMP_ACCELERATION)
    self:setStatus(_G.Const.CONST_BATTLE_STATUS_JUMP)
    if self.m_lpMovePos~=nil then
        self.m_stageView:onRoleMove(self,self.m_lpMovePos.x,self.m_lpMovePos.y,10,true)
    else
        self.m_stageView:onRoleMove(self,self.m_nLocationX,self.m_nLocationY,10,true)
    end
end

--使用技能
function CBaseCharacter.useSkill(self, _nSkillID)
    if _nSkillID==nil or _nSkillID==0 or self.m_lpContainer==nil or self.m_cantUseskil then
            return
    end

    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_HURT
       or self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH
       or (self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_FALL and not self.m_reborning)
       or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN)
       or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY)
       or self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD then
        return
    end

    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL and _nSkillID == self.m_nSkillID then
        return
    end

    if self.m_nSkillID == 0 then
        local skillEffectData = _G.g_SkillDataManager:getSkillData(_nSkillID)
        if skillEffectData==nil then
            CCLOG("CBaseCharacter.useSkill skillEffectData==nil  _nSkillID=%d",_nSkillID)
            return
        end
        self:setStatus( _G.Const.CONST_BATTLE_STATUS_USESKILL )
        -- if skillEffectData.pre_id~=0 then
        --     self.m_lpMovieClip:setToSetupPose()
        --     self.m_lpMovieClip:setAnimation(0,string.format("pre%d",skillEffectData.pre_id),true)
        --     self.m_preSkillId=_nSkillID
        --     self.m_preSkillData=skillEffectData
        --     self:showSkillEffect(_nSkillID,nil,true)
        -- else
            self:sureUseskill(_nSkillID,skillEffectData)
        -- end
    else
        self.m_nNextSkillID = _nSkillID
    end
    if self.m_enableBroadcastSkill then
        self:sendToServerUseSkill(_nSkillID)
    end
end

function CBaseCharacter.sureUseskill( self,_nSkillID,data )
    -- print("召唤技能====",data.type,_nSkillID,data)
    -- if data.type == _G.Const.CONST_SKILL_CALL_SKILL then
    --     if self.m_stageView:canCallSkill() then
    --         self.m_stageView:useCallSkill(self,_nSkillID)
    --     else
    --         self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
    --         self.setSkillCD(_nSkillID,data.cd)
    --         return
    --     end
    -- end
    -- print("CBaseCharacter.useSkill  cd=",data.cd)
    self:setSkillCD(_nSkillID,data.cd)

    self.m_nSkillDuration = 0
    self.m_skillIndex = 1

    -- if self.m_isNoRes then
    --     local moveClip = self:getBattleMoveClip()
    --     if moveClip and moveClip:getParent() then
    --         moveClip:play("skill_10000")
    --     end
    --     return
    -- end
    self.m_iscollider=nil

    if self.m_nType~=_G.Const.CONST_VITRO and self.m_nType~=_G.Const.CONST_TRAP then
        self.m_beAttackers={}
        self.m_attackTimes=nil
        self.m_attackFrame=nil
    end

    local isHasSkill = self:showSkillAction(_nSkillID)
    self:showSkillEffect(_nSkillID)

    -- if isHasSkill then
        self.m_nSkillID = _nSkillID
    -- end
end

function CBaseCharacter.showSkillAction( self, _nSkillID)
    if self.m_lpMovieClip then
        local askillId = _G.g_SkillDataManager:getAskillId(_nSkillID)
        if askillId==nil then
            return
        end
        if self.m_isNoRes then
            askillId = "20110"
        end

        self.m_lpMovieClip:setToSetupPose()
        self.m_lpMovieClip:setAnimation(0,"skill_"..askillId,false)
        if self.m_backBody then
            self.m_backBody:setAnimation(0,"skill_"..askillId,false)
        end
        return true
    end
end

--发送使用技能给服务器
function CBaseCharacter.sendToServerUseSkill( self, _nSkillID )
    local selfProperty =self:getProperty()
    if selfProperty == nil then
        CCLOG("sendToServerUseSkill selfProperty is nil")
        return
    end
    local uid = self:getID()
    if self:getType() == _G.Const.CONST_PARTNER then
        uid = selfProperty:getPartnerId()
    end
    local direct
    if self.m_isJoyStickPress and self.m_nextScalex~=nil then
        direct=self.m_nextScalex==1 and 1 or 2
    else
        direct=self.m_nScaleX>0 and 1 or 2
    end

    if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_KOF and _G.IS_PVP_NEW_DDX then
        -- if self.m_stageView.m_pvpMilliSeconds then
            -- local msg = REQ_WAR_PVP_USE_SKILL()
            -- msg:setArgs(self.m_stageView.m_pvpMilliSeconds,self.m_nType, uid, _nSkillID, direct, self.m_nLocationX, self.m_nLocationY)
            -- _G.Network:send(msg)

            local msg = REQ_WAR_PVP_SKILL()
            msg:setArgs(uid,_nSkillID,direct,self.m_nLocationX,self.m_nLocationY)
            _G.Network:send(msg)
        -- end
    else
        local msg = REQ_WAR_USE_SKILL()
        msg:setArgs(self.m_nType, uid, _nSkillID, direct, self.m_nLocationX, self.m_nLocationY)
        _G.Network:send(msg)
    end

    CCLOG("CBaseCharacter.sendToServerUseSkill  self.m_nType=%d ,uid=%d ,_nSkillID=%d ,direct=%d",self.m_nType,uid,_nSkillID,direct)
end

function CBaseCharacter.onHurt(self, hurtData, isnormalSkill , _hurtType)
    if self.m_lpContainer==nil or not hurtData or type(hurtData)~="table" then
        return 
    end

    if not self.isMainPlay and self.m_stageView.m_onUpdateCharcterCount>7 then
        if self.m_stageView.m_onUpdateCharcterCount>20 then
            if math.random(1,100)<80 then return end
        elseif self.m_stageView.m_onUpdateCharcterCount>10 then
            if math.random(1,100)<55 then return end
        else
            if math.random(1,100)<30 then return end
        end
    end

    -- [{id,x,y,scale,angles}
    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_STOP_ACTION) then return end

    local effectId=hurtData[1]
    if effectId==0 then
        effectId=10
    end
    -- if _G.StageXMLManager.m_noHurtEffect then return end

    local hurtSprite,hurtSpine
    if self.m_hurtTable==nil then
        self.m_hurtTable={}

        local hurtX = self.m_skinData.hurt_x*self.m_nScaleXPer
        local hurtY = self.m_skinData.hurt_y*self.m_nScaleXPer
        hurtSprite=cc.Sprite:create()
        hurtSprite:setPosition(hurtX, hurtY)
        self.m_lpCharacterContainer:addChild(hurtSprite,10)
        self.m_hurtTable.baseNode=hurtSprite
    -- elseif self.m_hurtTable.showId==hurtData then
    --     return
    else
        hurtSprite=self.m_hurtTable.baseNode
        if self.m_hurtTable.showId then
            if self.m_hurtTable.showId==effectId then
                hurtSpine=self.m_hurtTable.showSpine
            else
                self.m_hurtTable.showId=effectId
                _G.StageObjectPool:freeObject(self.m_hurtTable.showSpine)
                self.m_hurtTable.showSpine:removeFromParent(true)
            end
            hurtSprite:stopAllActions()
        end
    end

    local invBuff= _G.GBuffManager:getBuffNewObject(1399, 0)
    self:addBuff(invBuff)

    if not hurtSpine then
        local spriteFrameName=string.format("spine/%d",effectId)
        hurtSpine=_G.StageObjectPool:getObject(spriteFrameName,_G.Const.StagePoolTypeSpine)

        self.m_hurtTable.showSpine=hurtSpine

        local function onFunc()
            self.m_hurtTable.showId=nil
            self.m_hurtTable.showSpine=nil
            hurtSpine:removeFromParent(true)
            _G.StageObjectPool:freeObject(hurtSpine)
            -- hurtSpine:setVisible(false)
        end
        hurtSpine:registerSpineEventHandler(onFunc,2)
        hurtSprite:addChild(hurtSpine)
    end

    hurtSpine:setPosition(hurtData[2],hurtData[3])
    hurtSpine:setScale(hurtData[4])
    hurtSpine:setRotation(hurtData[5])
    hurtSpine:setAnimation(0,"idle",false)

    local function noHurting()
        if self.m_subject==nil then
            self.m_lpMovieClip:setColor(cc.c3b(255,255,255))
            if self.m_backBody then
                self.m_backBody:setColor(cc.c3b(255,255,255))
            end
            if self.m_isMountBattle then
                self.m_mountMovieClip:setColor(cc.c3b(255,255,255))
            end
        else
            self.m_lpMovieClip:setColor(cc.c3b(96,134,169))
        end
    end
    local delay2=cc.DelayTime:create(0.3)
    hurtSprite:runAction(cc.Sequence:create(delay2,cc.CallFunc:create(noHurting)))

    if self.m_nLocationZ>0 then
        if isnormalSkill then
            self.m_accRate = self.m_accRate + _G.Const.CONST_WAR_DECAY_COEFFICIENT
        else
            self.m_accRate = 1
        end
    end 

    if self.m_nType==_G.Const.CONST_PLAYER and not(self.m_noHurtSound) then
        -- if self.m_preHurtName == "hurt" then
        if _hurtType==1 then
            if self.m_skinData.hurt_sound then
                if self.isMainPlay or self.m_stageView.m_onUpdateCharcterCount<7 then
                    _G.Util:playBattleEffect(self.m_skinData.hurt_sound)
                end
            end
        else
            if self.m_skinData.hurt_sound1 then
                if self.isMainPlay or self.m_stageView.m_onUpdateCharcterCount<7 then
                    _G.Util:playBattleEffect(self.m_skinData.hurt_sound1)
                end
            end
        end
    end

    if self.m_buff[_G.Const.CONST_BATTLE_BUFF_ENDUCE] or self.m_buff[_G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER] then
        self.m_lpMovieClip:setColor(cc.c3b(255,80,80))
        if self.m_backBody then
            self.m_backBody:setColor(cc.c3b(255,80,80))
        end
        if self.m_isMountBattle then
            self.m_mountMovieClip:setColor(cc.c3b(255,80,80))
        end
        -- _G.ShaderUtil:setInvincibleHurtShader(self.m_lpMovieClip)
    else
        self.m_lpMovieClip:setColor(cc.c3b(255,155,155))
        if self.m_backBody then
            self.m_backBody:setColor(cc.c3b(255,155,155))
        end
        if self.m_isMountBattle then
            self.m_mountMovieClip:setColor(cc.c3b(255,155,155))
        end
    end
    -- end

    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_ENDUCE)==true then
        -- print("CBaseCharacter.onHurt _G.Const.CONST_BATTLE_BUFF_ENDUCE")
        return
    end

    if self.m_nMaxTenacity==nil then 
        if self.m_nType==_G.Const.CONST_PLAYER then
            if self.m_stageView.m_sceneType== _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL or 
                self.m_stageView.m_sceneType== _G.Const.CONST_MAP_TYPE_CITY_BOSS then
                
                self.m_nMaxTenacity=_G.Const.CONST_ARENA_BATI_NUM
                self.m_toughnessBuff=_G.Const.CONST_ARENA_BATI_BUFF
            else
                self.m_nMaxTenacity=9999
            end
        end
    end
    
    if self.m_nTenacity==nil or self.m_nMaxTenacity==nil then return end
    if self.m_nTenacity>=self.m_nMaxTenacity then
        self:setToughness()
        return
    end
    self.m_nTenacity=self.m_nTenacity+1
    -- if self.m_nMaxProtect~=nil and self.m_nMaxProtect~=0 then
    --     self:updateProtect()
    -- end
end

function CBaseCharacter.setToughness(self)
    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH then
        return
    end

    self.m_nTenacity=0
    local buffId = 301
    if self.m_toughnessBuff~=nil and self.m_toughnessBuff~=0 then
        buffId=self.m_toughnessBuff
    end
    local invBuff= _G.GBuffManager:getBuffNewObject(buffId, 0)
    self:addBuff(invBuff) 
end

-- function CBaseCharacter.setProtect( self )
--     if self.m_nMaxProtect == nil or self.m_nMaxProtect == 0 then return end
--     local invBuff = _G.GBuffManager:getBuffNewObject(1401,0)
--     self:addBuff(invBuff)
--     self.m_nIsProtect = true
--     local per = self:getHP()/self:getMaxHp() * 100
--     -- local num = per % self.m_nMaxProtect
--     -- num = num==0 and self.m_nMaxProtect or num
--     -- self.m_nNoProPer = per - num
--     self.m_nNoProPer = per - self.m_nMaxProtect
--     self.m_nNoProPer = self.m_nNoProPer <= 0 and 0 or self.m_nNoProPer
--     print(" CBaseCharacter.setProtect+++++++++++++",per,num,debug.traceback())
--     self:updateProtect()
-- end

-- function CBaseCharacter.updateProtect( self )
--     if self.m_nIsProtect ~= true and self.m_nMaxProtect >= 100 then return end
--     local per = self:getHP()/self:getMaxHp() * 100
--     -- local num = per % self.m_nMaxProtect
--     local num = (per - self.m_nNoProPer)/self.m_nMaxProtect*100
--     if self.m_nNoProPer >= per then
--         num = 0
--         self:removeBuff(_G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER)
--         self.m_nIsProtect = nil
--         local function addProtect()
--             self:setProtect()
--         end
--         self.m_lpContainer : runAction(cc.Sequence:create(cc.DelayTime:create(self.m_nNoProTime),cc.CallFunc:create(addProtect)))
--     end
--     if self.m_lpBigHp ~= nil then
--         self.m_lpBigHp:setProtectValue(num)
--     end
-- end

function CBaseCharacter.getMovieClip( self )
    return self.m_lpMovieClip
end

-- function CBaseCharacter.getBattleMoveClip( self )
--     return self.m_lpMovieClipBattle
-- end

-- function CBaseCharacter.setLastDangerTime( self )
--     if self:getAI() == nil or self:getAI() == 0 then
--         return
--     end
-- end

function CBaseCharacter.setStatus(self, _nStatus, _isReset, _hurtType)
    -- print(_nStatus,"@@$@@##@#@#",debug.traceback())
    if _nStatus == self.m_nStatus then
        return
    end

    local addMovieClip = self.m_lpMovieClip
    local actionName = nil
    local loop = nil
    if self.m_flySpr~=nil then
        if _nStatus~=_G.Const.CONST_BATTLE_STATUS_MOVE then
            self.m_flySpr:setAnimation(0,"idle",true)
        else
            self.m_flySpr:setAnimation(0,"move",true)
        end
    end
    if _nStatus == _G.Const.CONST_BATTLE_STATUS_IDLE then --站立,循环
        -- addMovieClip = self.m_lpMovieClip
        -- self:hideEskillEffect()
        actionName = self.m_idleName
        loop=true
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE then --移动,循环
        -- addMovieClip = self.m_lpMovieClip
        if self.moveActionName~=nil then
            actionName = self.moveActionName
        else
            actionName = "move"
        end
        loop=true
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_HURT then --受击,循环
        -- addMovieClip = self.m_lpMovieClipBattle
        -- self:hideEskillEffect()
        if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_CRASH then
            actionName = "hurt3"
            _nStatus=_G.Const.CONST_BATTLE_STATUS_CRASH
        elseif _hurtType==2 then
            actionName = "hurt2"
        else
            actionName = "hurt"
        end

        self:startHurtVibrate()
        -- if self.m_preHurtName == "hurt" then
        --     actionName = "hurt2"
        -- else
        --     actionName = "hurt"
        -- end
        -- self.m_preHurtName = actionName
        
        self:cancelTSpeed()
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_FALL then --倒地,循环
        actionName = "fall"
        self:AshShow()
        -- self:cancelTSpeed()
        -- if self.m_sceFly then
        --     local _Angle=_G.Const.CONST_BATTLE_FLY_ANGLE
        --     if self.m_nScaleX>0 then
        --         _Angle = math.abs(_Angle)-180
        --     end
        --     self:thrust( _G.Const.CONST_BATTLE_FLY_SPEED, _Angle , _G.Const.CONST_BATTLE_FLY_ACCELERATION )
        --     self:setStatus( _G.Const.CONST_BATTLE_STATUS_CRASH)
        --     self.m_sceFly=nil
        --     return
        -- end
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH then --击飞,循环
        -- self:hideEskillEffect()
        actionName = "crash"
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD then --死亡,非循环
        self:removeAllBuff()

        if self.m_deadAction and self.m_nLocationZ<=0 and self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_FALL then
            actionName = "dead2"
            self.m_noBeTarget=true
        else
            actionName = "dead"
        end
        self:setAI(0)
        -- self:cancelTSpeed()

    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then --使用技能时,因技能ID不同,外部调用其播放动画
        -- addMovieClip = self.m_lpMovieClipBattle
        self.m_nStatus = _nStatus
        -- self :setColliderXml( self.m_nStatus, self.m_SkinId )    --默认职业为 1 先
    end
    self.m_nSkillID = 0
    if addMovieClip then
        if actionName then
            if not self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_STOP_ACTION) then
                addMovieClip:setToSetupPose()
                addMovieClip:setAnimation(0,actionName,loop)
            end
            
            if self.m_backBody then
                self.m_backBody:setAnimation(0,actionName,loop)
            end
        end
        self.m_nStatus = _nStatus
        -- self :setColliderXml(self.m_nStatus, self.m_SkinId )   
    end
end
function CBaseCharacter.AshShow(self)
    local spriteFrameName="spine/109"
    local hurtSpine=_G.StageObjectPool:getObject(spriteFrameName,_G.Const.StagePoolTypeSpine)

    local function onFunc()
        hurtSpine:removeFromParent(true)
        _G.StageObjectPool:freeObject(hurtSpine)
    end
    hurtSpine:registerSpineEventHandler(onFunc,2)
    hurtSpine:setAnimation(0,"idle",false)
    self.m_lpContainer:addChild(hurtSpine)
end

function CBaseCharacter.getStatus( self )
    return self.m_nStatus
end

function CBaseCharacter.startHurtVibrate(self)
    if self.m_lpMovieClip then
        -- self:stopHurtVibrate()
        if self.m_lpMovieClip:getActionByTag(9699) then
            return
        end
        local tempAct=cc.Repeat:create(cc.Sequence:create(cc.MoveBy:create(0.05,cc.p(-10,-10)),cc.MoveBy:create(0.05,cc.p(10,10))),10)
        tempAct:setTag(9699)
        self.m_lpMovieClip:runAction(tempAct)
    end
end
function CBaseCharacter.stopHurtVibrate(self)
    if self.m_lpMovieClip then
        self.m_lpMovieClip:setPosition(0,0)
        self.m_lpMovieClip:stopActionByTag(9699)
    end
end

function CBaseCharacter.Translation(self,speed,x,y,_Assailant)
    if speed==0 or speed==nil then return end
    local rank = self:getMonsterRank()
    -- if rank ~= nil and rank >= _G.Const.CONST_MONSTER_RANK_ELITE and _Assailant ~= nil then return end
    self.m_TSpeed = speed*self.m_nScaleXPer
    if _Assailant == nil then
        self.m_TEndX  = self.m_nLocationX+x*self.m_nScaleX*self.m_nScaleXPer
        self.m_TEndY  = self.m_nLocationY+y
    else
        local tempRan = math.random()
        self.m_TEndX  = _Assailant.m_nLocationX+x*_Assailant.m_nScaleX*self.m_nScaleXPer
        local scaleY  = tempRan>0.5 and 1 or -1
        self.m_TEndY  = _Assailant.m_nLocationY+y+tempRan*50*scaleY
    end
    self.m_TEndX,self.m_TEndY =self:convertLimitPos(self.m_TEndX,self.m_TEndY)

    if y==0 then
        self.m_TScaleX = self.m_TEndX>self.m_nLocationX and 1 or -1
        self.m_TSpeedX = speed*self.m_TScaleX
        self.m_TSpeedY = 0
    elseif x==0 then
        self.m_TScaleX = self.m_nScaleX
        self.m_TSpeedX = 0
        self.m_TSpeedY = speed
    else
        local subX = self.m_TEndX - self.m_nLocationX
        local subY = self.m_TEndY - self.m_nLocationY
        local distance = math.sqrt(subX*subX+subY*subY)
        self.m_TSpeedX = speed*subX/distance
        self.m_TSpeedY = speed*subY/distance
        self.m_TScaleX = subX>0 and 1 or -1
    end
    
    -- local angle = gc.MathGc:pointsToAngle(cc.p(self.m_nLocationX,self.m_nLocationY),cc.p(self.m_TEndX,self.m_TEndY))
    -- local radian = gc.MathGc:angleToRadian(angle)
    -- self.m_TSpeedX = speed*math.cos(radian)
    -- self.m_TSpeedY = speed*math.sin(radian)
end

--给对象推力
function CBaseCharacter.thrust(self, _speed, _angle, _acceleration,_downAcceleration,_xyangle)
    -- print( _speed, _angle, _acceleration,_downAcceleration,_xyangle," _speed, _angle, _acceleration,_downAcceleration,_xyangle",debug.traceback())
    if _speed == 0.0 or (self:getHP() <= 0 and (_angle > -20 or _angle < -160) ) then
        CCLOG("thrust fail _SPPED == 0.0")
        return
    end
    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_ENDUCE) or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER) then
        local isNoThrust =true
        if _speed == _G.Const.CONST_BATTLE_DEAD_SPEED then
            isNoThrust=false
            -- self:removeBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN)
        end
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_THRUST] then
            local buffId=self.m_buff[_G.Const.CONST_BATTLE_BUFF_THRUST].m_buffId
            if (buffId>=111 and buffId<=118) then
                isNoThrust=false
            end
        end
        if isNoThrust then
            return
        end
    end

    -- print("_acceleration,wwwwwwwwww",_speed,self.m_nLocationZ) 
    _speed=_speed/(self.m_nLocationZ/_G.Const.CONST_WAR_DECAY_HIGHT+1*self.m_skinData.collider.vWeight*self.m_accRate)
    -- print("_acceleration,wwwwwwwwww",_speed)
    self.m_nCurrentAcceleration = _acceleration
    self.m_nDownAcceleration=_downAcceleration

    self.m_fXSpeed=nil
    if math.abs(_angle)~=90 then
        local xRadian = math.angle2radian( 180 + _angle )
        self.m_fXSpeed = _speed * math.cos( xRadian )
    end

    -- if _xyangle ~= nil then
    --     local yRadian = gc.MathGc:angleToRadian( _xyangle )
    --     self.m_hYSpeed = _speed * math.sin( yRadian )
        -- if _xyangle > -90 and _xyangle < 90 then 
        --     if self.m_fXSpeed < 0 then
        --         self.m_fXSpeed = - self.m_fXSpeed
        --     end
        -- else 
        --     if self.m_fXSpeed > 0 then
        --         self.m_fXSpeed = - self.m_fXSpeed
        --     end
        -- end
    -- end

    if self.m_nLocationZ and self.m_nLocationZ>450 then
        return
    end
    -- local monsterRank = self : getMonsterRank()
    -- if monsterRank ~= nil and (monsterRank == _G.Const.CONST_MONSTER_RANK_BOSS_SUPER or monsterRank == _G.Const.CONST_MONSTER_RANK_GOOD) then
    --     -- self.m_fYSpeed=100
    --     -- -179 -1 是突击角度
    --     if _angle~=-179 and _angle~=-1 then
    --         return
    --     end
    -- end
    local yRadian = math.angle2radian( _angle )
    self.m_fYSpeed = _speed * math.sin( -yRadian )
    -- print("self.m_fYSpeed,self.m_fXSpeed,",self.m_fYSpeed,self.m_fXSpeed)
end

function CBaseCharacter.onUpdate( self, _duration, _nowTime )
    self:onUpdateSkillEffectObject(_duration)
    self:onUpdateUseSkill( _duration )
    self:onUpdateBuff( _duration )

    if self.m_nHP<=0 then
        self:onUpdateDead()
    end
end

function CBaseCharacter.onUpdateDead( self)
    -- local z = self:getLocationZ()
    -- if z>0 then
    --     -- print(z)
    --     return
    -- end
    if not(self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_CRASH or self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_DEAD) then
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_DEAD)
    end
end

function CBaseCharacter.removeSkillShow(self,_nSkillID)
    if self.m_showSkillArray[_nSkillID] then
        self.m_showSkillArray[_nSkillID]=nil

        self.m_isWantToShowSkillEffect=next(self.m_showSkillArray)~=nil
    end
end
function CBaseCharacter.showSkillEffect( self, _nSkillID,isVitro,ispreAction)
    -- 特效显示
    print("CBaseCharacter.showSkillEffect _nSkillID=",_nSkillID)

    if self.m_showSkillArray[_nSkillID] then return end

    local eskillData = nil 
    if isVitro == true then
        eskillData=_G.g_SkillDataManager:getEskillId2(_nSkillID)
    elseif ispreAction==true then
        eskillData=_G.g_SkillDataManager:getEskillId3(_nSkillID)
    else
        eskillData=_G.g_SkillDataManager:getEskillId(_nSkillID)
    end
    if eskillData==nil or #eskillData == 0 then
        CCLOG("CBaseCharacter.showSKillEffect no skill effect _nSkillID=%d",_nSkillID)
        return
    end

    self.m_showSkillArray[_nSkillID]={
        skillId=_nSkillID,
        eskillData=eskillData,
        curTimes=0,
        handleIdx=0
    }

    self.m_isWantToShowSkillEffect=true
    self:onUpdateSkillEffectObject(0,_nSkillID)
end

function CBaseCharacter.hideEskillEffect( self)
    -- self.m_lpEffectContainer:removeAllChildren(false)
    -- self.m_lbEffectContainer:removeAllChildren(false)

    for _effectId,v in pairs(self.m_curUseSkillEffectObjArray) do
        v.obj:removeFromParent(true)
        v.parent:removeFromParent(true)
        _G.StageObjectPool:freeObject(v.obj)
        _G.StageObjectPool:freeObject(v.parent)
    end

    self.m_curUseSkillEffectObjArray={}
    self.m_showSkillArray={}
    self.m_isWantToShowSkillEffect=false
end

function CBaseCharacter.resetSkillEffectObjectPos(self)
    for effectId,v in pairs(self.m_curUseSkillEffectObjArray) do
        if self.m_showSkillArray[v.skill_id] or self.m_nSkillID==v.skill_id then
            v.parent:setPosition(self.m_nLocationX,self.m_nLocationY)
            if v.zOrder==0 then
                v.parent:setLocalZOrder(-self.m_nLocationY+1)
            else
                v.parent:setLocalZOrder(-self.m_nLocationY-1)
            end
        end
    end
end

function CBaseCharacter.resetSkillEffectObjectScaleX(self,_ScaleX)
    for effectId,v in pairs(self.m_curUseSkillEffectObjArray) do
        if self.m_showSkillArray[v.skill_id] or self.m_nSkillID==v.skill_id then
            local tempScale=self.m_nScaleXPer
            v.parent:setScaleX(tempScale*(_ScaleX or self.m_nScaleX))
        end
    end
end

function CBaseCharacter.removeSkillEffectObject(self,_node,_effectId)
    function c()
        local tempT=self.m_curUseSkillEffectObjArray[_effectId]
        if tempT then
            tempT.obj:removeFromParent(true)
            tempT.parent:removeFromParent(true)

            _G.StageObjectPool:freeObject(tempT.obj)
            _G.StageObjectPool:freeObject(tempT.parent)
            self.m_curUseSkillEffectObjArray[_effectId]=nil
        end
    end
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(c)))
end
function CBaseCharacter.onUpdateSkillEffectObject(self,_duration,_skillId)
    if _G.IsHideSkillEffect then return end
    if not self.m_isWantToShowSkillEffect then
        return
    end

    for skillId,tempT in pairs(self.m_showSkillArray) do
        if _skillId==nil or _skillId==skillId then
            tempT.curTimes=tempT.curTimes+_duration*1000

            local dataCount=#tempT.eskillData
            local dataIdx=tempT.handleIdx
            for j=dataIdx+1,dataCount do
                local tempData=tempT.eskillData[j]
                local effectId=skillId..tempData.id..j
                if tempT.curTimes>=tempData.t then
                    dataIdx=j

                    local isLoop=tempData.l>0
                    local tempScale=tempData.s/10000
                    local tempObject=nil

                    if tempData.id~=0 then
                        if self.m_curUseSkillEffectObjArray[effectId] then
                            local tempT=self.m_curUseSkillEffectObjArray[effectId]
                            tempT.obj:removeFromParent(true)
                            tempT.parent:removeFromParent(true)

                            _G.StageObjectPool:freeObject(tempT.obj)
                            _G.StageObjectPool:freeObject(tempT.parent)
                        end

                        if tempData.class==1 then
                            tempObject=_G.StageObjectPool:getObject("spine/"..tempData.id,_G.Const.StagePoolTypeSpine)
                            if not tempObject then
                                self:removeSkillShow(skillId)
                                return
                            end

                            if not isLoop then
                                local function onFunc2(event)
                                    self:removeSkillEffectObject(tempObject,effectId)
                                end
                                tempObject:registerSpineEventHandler(onFunc2,2)
                            end

                            tempObject:clearTrack(0)
                            tempObject:setAnimation(0,"idle",isLoop)
                        elseif tempData.class==2 then
                            tempObject=cc.Node:create()

                            if not self.m_stageView:isMultiStage() then
                                local effectName=string.format("particle/%d.plist",tempData.id)
                                local particle=cc.ParticleSystemQuad:create(effectName)
                                particle:setPositionType(cc.POSITION_TYPE_GROUPED)
                                tempObject:addChild(particle)
                            end
                        elseif tempData.class==3 then
                            tempObject=_G.StageObjectPool:getObject(string.format("gaf/%d.gaf",tempData.id),_G.Const.StagePoolTypeGaf)

                            if not tempObject then
                                self:removeSkillShow(skillId)
                                return
                            end

                            tempObject:stop()
                            if tempData.flash~=0 then
                                tempObject:playSequence(tostring(tempData.flash),false,true)
                                local tempFrame=tempObject:getStartFrame(tempData.flash)
                                tempFrame=tempFrame>10000 and 0 or tempFrame
                                tempObject:setFrame(tempFrame)
                                -- tempObject:setFpsLimitations(false)
                            else
                                tempObject:setFrame(0)
                            end

                            if not isLoop then
                                local function onFunc2()
                                    self:removeSkillEffectObject(tempObject,effectId)
                                end
                                tempObject:setLooped(false,false)
                                tempObject:setAnimationFinishedPlayDelegate(onFunc2)
                            else
                                tempObject:setLooped(true,false)
                            end
                            tempObject:start()
                        end

                        local temoNode=_G.StageObjectPool:getObject(self.SKILL_EFFECT_NODE_NAME,_G.Const.StagePoolTypeNode)
                        temoNode:setPosition(self.m_nLocationX,self.m_nLocationY)
                        temoNode:addChild(tempObject)
                        temoNode:setScale(self.m_nScaleXPer*self.m_nScaleX,self.m_nScaleXPer)

                        self.m_curUseSkillEffectObjArray[effectId]={
                            obj=tempObject,
                            skill_id=skillId,
                            parent=temoNode,
                            zOrder=tempData.b
                        }

                        if tempData.flip==1 then
                            tempObject:setScale(-tempScale,tempScale)
                        else
                            tempObject:setScale(tempScale)
                        end

                        tempObject:stopAllActions()
                        tempObject:setPosition(tempData.x,tempData.y)
                        tempObject:setLocalZOrder(tempData.z)
                        tempObject:setRotation(tempData.r)
                        tempObject:setOpacity(255)

                        if tempData.b==0 then
                            self.m_stageView.m_lpCharacterContainer:addChild(temoNode,-self.m_nLocationY+1)
                        else
                            self.m_stageView.m_lpCharacterContainer:addChild(temoNode,-self.m_nLocationY-1)
                        end

                        if isLoop then
                            local lifeTime=(tempData.lt-tempData.ft)*0.001
                            local fateTime=tempData.ft*0.001

                            local function nFun()
                                self:removeSkillEffectObject(tempObject,effectId)
                            end

                            -- tempObject:setOpacity(255)
                            tempObject:runAction(cc.Sequence:create(cc.DelayTime:create(lifeTime),cc.FadeTo:create(fateTime,0),cc.CallFunc:create(nFun)))
                        end
                    end
                end
            end

            if dataIdx==dataCount then
                self:removeSkillShow(skillId)
            else
                tempT.handleIdx=dataIdx
            end
        end
    end
end

--更新  生物使用技能
function CBaseCharacter.onUpdateUseSkill(self, _duration)
    if not self.m_nSkillID or self.m_nSkillID==0 or self.m_nStatus ~= _G.Const.CONST_BATTLE_STATUS_USESKILL or self.m_pauseing then
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
    for k=self.m_skillIndex,#skillNode.frame do
        local currentFrame=skillNode.frame[k]
        local currentFrameTime = currentFrame.time
        if currentFrameTime < self.m_nSkillDuration and lastDuration <= currentFrameTime then
            self.m_skillIndex=k
            self.m_deviation=currentFrame.point*self.m_nScaleX
            self:handleSkillFrameBuff(currentFrame,1,0,self.m_nSkillID)
            _G.StageXMLManager:handleSkillFrameVitro(self,currentFrame)
            _G.StageXMLManager:handleSkillFrameMonster(self,currentFrame,self.m_nSkillID)

            -- --技能攻击音效
            if not _G.IsHideSkillEffect then
                if currentFrame.sound and type(currentFrame.sound)=="table" then
                    local i=math.ceil(gc.MathGc:random_0_1()*#(currentFrame.sound))
                    _G.Util:playAudioEffect(currentFrame.sound[i])
                end
            end

            local attackNumber=currentFrame.count
            if attackNumber and self.m_attackFrame~=attackNumber then
                self.m_attackFrame=attackNumber
                self.m_attackTimes=1
                self.m_beAttackers={}
            end
            
            local iscollider,isHit = self:checkCollisionSkill( skillNode, currentFrame )
            self:removeThrustBuff()

            --打中
            if iscollider then
                if not isPlayHitAudio and currentFrame.hit_s then
                    if self.isMainPlay or self.m_stageView.m_onUpdateCharcterCount<7 then
                        _G.Util:playBattleEffect(currentFrame.hit_s)
                    end

                    isPlayHitAudio=true
                    self.m_iscollider=true
                end
                
                if not self.m_addMpSkillId or self.m_addMpSkillId~=self.m_nSkillID then
                    self:addMP(_G.Const.CONST_BATTLE_HIT_ADD_MP)
                    self.m_addMpSkillId=self.m_nSkillID
                end
            end
        end
    end
end

function CBaseCharacter.handleSkillFrameBuff( self, _currentFrame, _isPersonal, _iscollision, _skillId,totalHurtValue)
    --_isPersonal 1 自己  0 他人 2 队友 怪物皮肤（五位数）
    --_iscollision 1 撞了   0 没撞
    local hasRigidityBuff = nil
    local hasCrashBuff = nil
    local hasBeatbackBuff = nil
    local gatherData = nil
    local buffArray=_currentFrame.buff
    if buffArray then
        for i=1,#buffArray do
            local currentBuff=buffArray[i]
            if currentBuff.personal>10000 and _iscollision==0 then
                for _ ,v in pairs(_G.CharacterManager.m_lpCharacterArray) do
                    if v.m_SkinId==currentBuff.personal then
                        local buffObject = _G.GBuffManager:getBuffNewObject(currentBuff.id ,_skillId)
                        v:addBuff(buffObject)
                    end
                end
            elseif currentBuff.personal == _isPersonal and currentBuff.collision == _iscollision then
                if currentBuff.move ~= nil then
                    -- self:Translation(currentBuff.move.speed,currentBuff.move.x,currentBuff.move.y)
                    if _isPersonal == 1 then
                        self:Translation(currentBuff.move.speed,currentBuff.move.x,currentBuff.move.y)
                    else 
                        gatherData = currentBuff.move
                    end
                end
                local buffObject = _G.GBuffManager:getBuffNewObject(currentBuff.id ,_skillId)
                if buffObject then
                    self:addBuff(buffObject)

                    if buffObject:gettype()==_G.Const.CONST_BATTLE_BUFF_RIGIDITY then
                        hasRigidityBuff=true
                    elseif buffObject:gettype()==_G.Const.CONST_BATTLE_BUFF_CRASH and self.m_nLocationZ==0 then
                        if not self.m_noFly then
                            hasCrashBuff=true
                        end
                    elseif buffObject:gettype()==_G.Const.CONST_BATTLE_BUFF_BEATBACK and self.m_nLocationZ==0 then
                        if not self.m_noFly then
                            hasBeatbackBuff=true
                        end
                    elseif buffObject:gettype()==_G.Const.CONST_BATTLE_BUFF_BLEED then

                        -- print("CBaseCharacter.handleSkillFrameBuff totalHurtValue=",totalHurtValue,not totalHurtValue)
                        buffObject.totalHurtValue=totalHurtValue
                        -- if not buffObject.totalHurtValue then
                        --     self.m_buff[_G.Const.CONST_BATTLE_BUFF_BLEED]=nil
                        -- end
                    end
                end
            end
        end
    end
    return hasRigidityBuff,hasCrashBuff,hasBeatbackBuff,gatherData
end

function CBaseCharacter.onUpdateBuff(self, _duration)
    local removeList = {}
    local removeCount= 0
    for k,buff in pairs(self.m_buff) do
        if buff.update then
            buff:update(_duration)
        end
        if buff:isTimeOut() then
            removeCount=removeCount+1
            removeList[removeCount]=k
        elseif buff : gettype() == _G.Const.CONST_BATTLE_BUFF_BLEED then
            if not buff.m_fSecond then
                buff.m_fSecond = 0
            end
            if buff.m_fSecond <= buff.m_fDuration then
                buff.m_fSecond = buff.m_fSecond + buff.timeinterval
                if not self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_INVINCIBLE) then
                    local hurt
                    if buff.hit_per~=nil then
                        if not buff.totalHurtValue then
                            buff.totalHurtValue = 0
                        end
                        hurt=math.ceil(buff.hit_per*buff.totalHurtValue)
                    else
                        hurt =math.ceil(self:getMaxHp()*buff.per)
                    end
                    if _G.SkillHurt.isNeedBroadcastHurt==true then
                        if self.isMainPlay then
                            local msg = REQ_WAR_SKILL_HARM()
                            msg:setArgs(hurt)
                            _G.Network:send(msg)
                        end
                    else
                        self:addHP(-hurt,nil,true)
                    end

                end
            end
        end
    end

    for i=1,removeCount do
        self:removeBuff(removeList[i])
    end
end

function CBaseCharacter.addBuff( self, _buff )
    if _buff==nil or not _buff.isBuff then
        CCLOG("have some one add buff ,but this object not is CBuff or CBuff extend")
        print("Zzz...",_buff,debug.traceback())
        return
    end

    local buffType=_buff:gettype()
    if buffType==_G.Const.CONST_BATTLE_BUFF_ENDUCE or buffType==_G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER then
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_ENDUCE] or self.m_buff[_G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER] then
            return
        end
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_DISPEL] then return end
        self:addBuffEffect(_buff)
        -- if not(self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL or 
        --     self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CITY_BOSS) then 
        --     if _buff.openEffect~=false and self.m_lpMovieClip then
        --         local ccbiNode = self.m_lpMovieClip:getCCBINode()
        --         if ccbiNode then
        --             local effectChild = ccbiNode:getChildByTag(168)
        --             if effectChild then
        --                 effectChild:setVisible(true)
        --             end
        --         end
        --     end
        --     if _buff.openEffect~=false and self.m_lpMovieClipBattle then
        --         local ccbiNode = self.m_lpMovieClipBattle:getCCBINode()
        --         if ccbiNode then
        --             local effectChild = ccbiNode:getChildByTag(168)
        --             if effectChild then
        --                 effectChild:setVisible(true)
        --             end
        --         end
        --     end
        -- end

    elseif buffType == _G.Const.CONST_BATTLE_BUFF_CRASH then
        if self.m_buff[ _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER] then return end
        self.m_buff[_G.Const.CONST_BATTLE_BUFF_CRASH] = nil

    elseif buffType == _G.Const.CONST_BATTLE_BUFF_RIGIDITY then
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_RIGIDITY] then
            self.m_buff[_G.Const.CONST_BATTLE_BUFF_RIGIDITY] = nil
            if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_HURT then
                self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
            end
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_INVINCIBLE then
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_INVINCIBLE] then return end
        if _buff.id==410 then
            self.m_lpMovieClip:setOpacity(100)
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_VIBRATE then
        if not self.isMainPlay and self.m_stageView:isMultiStage()
            -- (self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CITY_BOSS 
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_BOSS
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS 
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_CLAN_DEFENSE
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_CLAN_WAR)
                then return end
        local vibrateFunc ="vibrate"
        vibrateFunc=self.m_stageView[vibrateFunc]
        if vibrateFunc~=nil then
            vibrateFunc(self.m_stageView,_buff.num,_buff.positiony,_buff.duration)
        end

    elseif buffType == _G.Const.CONST_BATTLE_BUFF_SPLASH then
        if not self.isMainPlay and self.m_stageView:isMultiStage()
            -- (self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CITY_BOSS 
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_BOSS
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS 
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_CLAN_DEFENSE
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_CLAN_WAR)
                then return end
        local vibrateFunc ="splash"
        vibrateFunc=self.m_stageView[vibrateFunc]
        if vibrateFunc~=nil then
            vibrateFunc(self.m_stageView,_buff.duration,_buff.num)
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_SLOW then
        self.m_stageView:slowBuff(_buff.duration,_buff.per)

    elseif buffType == _G.Const.CONST_BATTLE_BUFF_BLACK then   
        if not self.isMainPlay and self.m_stageView:isMultiStage()
            -- (self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CITY_BOSS 
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_BOSS
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS 
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_CLAN_DEFENSE
            --         or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_CLAN_WAR)
                then return end
        local vibrateFunc
        if _buff.id>3100 and _buff.id<3110 then
            vibrateFunc="black"
        elseif _buff.id<3120 then
            vibrateFunc="black2"
        end
        vibrateFunc=self.m_stageView[vibrateFunc]
        if vibrateFunc~=nil then
            vibrateFunc(self.m_stageView,_buff.duration,_buff.num)
        end 
    elseif buffType== _G.Const.CONST_BATTLE_BUFF_STOP then
        if self.m_stageView:isMultiStage() then
            return
        end
        if _buff.id>3300 and _buff.id<3310 then
            self.m_stageView:setPause()
            local function c(  )
                self.m_stageView:setResume()
            end
            self.m_lpMovieClip:runAction(cc.Sequence:create(cc.DelayTime:create(_buff.duration),cc.CallFunc:create(c)))
        elseif _buff.id<3320 then
            self.m_lpMovieClip:pause()
            local function c(  )
                self.m_lpMovieClip:resume()
            end
            self.m_lpMovieClip:runAction(cc.Sequence:create(cc.DelayTime:create(_buff.duration),cc.CallFunc:create(c)))
        end
    elseif buffType== _G.Const.CONST_BATTLE_BUFF_HANGIN then
        if self.m_nLocationZ==0 then return end
        if self.m_nLocationZ>=400 then return end
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_ENDUCE] then return end
        if self.m_buff[ _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER] then return end

    elseif buffType == _G.Const.CONST_BATTLE_BUFF_BEATBACK then
        if self.m_nLocationZ > 0 then return end

    elseif buffType==_G.Const.CONST_BATTLE_BUFF_BLEED then
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_BLEED] then self.m_buff[buffType] = _buff return end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_FROZEN then
        if self.m_buff[buffType] then return end
        if self.m_nHP<=0 then return end
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_ENDUCE] then return end
        if self.m_buff[ _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER] then return end
        if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then return end
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_HURT)
        self.m_setStatusFun=self.setStatus
        self.setStatus=function ( ) end
        self:addBuffEffect(_buff)
    elseif buffType >= _G.Const.CONST_BATTLE_BUFF_POISON  and buffType <= _G.Const.CONST_BATTLE_BUFF_BURN then
        -- if self.m_buff[ _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER] then return end
        if self.m_buff[buffType] then self.m_buff[buffType] = _buff return end
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_ENDUCE] then return end
        if self.m_buff[ _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER] then return end
        if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then return end
        self:addBuffEffect(_buff)
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_ADD or buffType == _G.Const.CONST_BATTLE_BUFF_MINUS then
        if self.m_buff[buffType] then self.m_buff[buffType] = _buff return end
        local warAttr = self:getWarAttr()
        local attr = {"strong_att","strong_def","wreck","hit","dodge","crit","crit_res","bonus","reduction"}
        for _,attrData in pairs(_buff.data) do
            local value = warAttr[attr[attrData.id-41]]
            value = value * (1+attrData.per)
            warAttr:updateProperty(attrData.id,value)
        end
        self.m_skillToVictims = {}
        local id
        if self.m_nType==_G.Const.CONST_MONSTER then
            id=self.m_monsterId
        else
            id=self.m_nID
        end
        for _,character in pairs(_G.CharacterManager:getCharacter()) do
            if character.m_skillToVictims and character.m_skillToVictims[id]~=nil then
                character.m_skillToVictims[id]=nil
            end
        end

        if _buff.id == nil then return  end
        if _buff.idEffect~=nil then 
            local buffEffect=_G.SpineManager.createSpine("spine/".._buff.idEffect,1)
            buffEffect:setAnimation(0,"idle",false)
            buffEffect:setPosition(0,_buff.positiony)
            buffEffect:setTag(buffType)
            self.m_lpHurtStringContainer:addChild(buffEffect)
            local function onFunc2(event)
                buffEffect:removeFromParent(true)
            end
            -- buffEffect : registerSpineEventHandler(onFunc2,2)
            buffEffect:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(onFunc2)))
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_SPEED then
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_SPEED] then self.m_buff[buffType] = _buff return end
        self.m_nMoveSpeedX = self.m_nMoveSpeedX * (_buff.per + 1)
        self.m_nMoveSpeedY = self.m_nMoveSpeedY * (_buff.per + 1)
        self:addBuffEffect(_buff)
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_UNDEAD then
        if self.m_buffHp then return end
        self.m_buffHp=_buff.per*self.m_nMaxHP
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_SHIELD then
        -- print("CONST_BATTLE_BUFF_SHIELD======>>>  addBuff  1")
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_SHIELD] then
            -- print("CONST_BATTLE_BUFF_SHIELD======>>>  addBuff  2")
            local preBuff=self.m_buff[_G.Const.CONST_BATTLE_BUFF_SHIELD]
            local tempArray={}
            for i=1,#_buff.data do
                local nBuff=_buff.data[i]
                for j=1,#preBuff.data do
                    local pBuff=preBuff.data[j]
                    if nBuff.type==pBuff.type then
                        tempArray[nBuff.type]=true
                        break
                    end
                end 

                local invBuff=_G.GBuffManager:getBuffNewObject(nBuff.id,0)
                invBuff.duration=nil
                -- print("重复加buff，新buff添加=====>>>>>",invBuff:gettype())
                self:addBuff(invBuff)
            end

            for i=1,#preBuff.data do
                local nType=preBuff.data[i].type
                if not tempArray[nType] then
                    local oldBuff=self:getBuff(nType)
                    -- print("重复加buff，旧buff独立更新======>>>",nType)
                    oldBuff.m_fDuration=preBuff.m_fDuration
                    oldBuff.duration=preBuff.duration
                end
            end

            self.m_buff[buffType]=_buff
            -- self.m_buff[_G.Const.CONST_BATTLE_BUFF_SHIELD].m_fDuration=0

            -- for _,buff in pairs(_buff.data) do
            --     if self.m_buff[buff.type] then
            --         self.m_buff[buff.type].duration=nil
            --     else
            --         local invBuff= _G.GBuffManager:getBuffNewObject(buff.id, 0)
            --         self:addBuff(invBuff)
            --         invBuff.duration=nil
            --     end
            -- end
            return
        end
        -- print("CONST_BATTLE_BUFF_SHIELD======>>>  addBuff  3")
        for _,buff in pairs(_buff.data) do
            local invBuff= _G.GBuffManager:getBuffNewObject(buff.id, 0)
            self:addBuff(invBuff)
            -- print("新buff添加=====>>>>>",invBuff:gettype())
            invBuff.duration=nil
        end
        local hp=self.m_nMaxHP*_buff.per
        self.m_shieldHpNum=self.m_nHP-hp
        self:addBuffEffect(_buff)
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_VARY then
        if self.m_buff[buffType] then return end
        self:setScalePer(_buff.per)
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_RENEW then
        self:addHP(self:getMaxHp()*_buff.per)
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_STEALTH then
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_STEALTH] then return end
        if _buff.num == 0 then
            self.m_lpContainer:setVisible(false)
        else
           self.m_lpMovieClip:setOpacity(_buff.num)
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_CLONE then
        if self.m_buff[buffType] then return end
        if self.m_nHP == 0 or self.m_subject ~= nil then return end
        self.m_cloneList = self.m_cloneList or {}
        for i=1,_buff.num do
            local x=self:getLocationX()
            x=x+200*self.m_nScaleX
            local obj
            if self.m_nType==_G.Const.CONST_MONSTER then
                
                obj = _G.StageXMLManager:addOneMonster(nil,self.m_xmlProperty,self.m_monsterId,x,
                                        self:getLocationY(),self.m_nScaleX,self:getHP(),self:getMaxHp(),nil,self)
            elseif self.m_nType==_G.Const.CONST_PLAYER then
                obj = _G.StageXMLManager:addOnePlayerMonster2(nil,self.m_property,nil,x,
                                        self:getLocationY(),self.m_nScaleX,self:getHP(),self:getMaxHp(),nil,self)
                obj.m_noBeTarget=true
                obj.m_subject=self
                local skillData = self.m_property:getSkillData()
                local skillLv_data = skillData:getSkillLvBySkillID(self.m_nSkillID)
                local skillLv = 1
                if skillLv_data~=nil then
                    skillLv = skillLv_data.skill_lv
                end
                local skillData=_G.g_SkillDataManager:getSkillData(self.m_nSkillID)
                if skillData and skillData.lv and skillData.lv[skillLv] then
                    local lvData = skillData.lv[skillLv]
                    obj.m_cloneRatio=lvData.mc_arg1*0.0001
                    obj.m_cloneConst=lvData.mc_arg2
                end
                obj.m_subjectSkill=self.m_nSkillID
                obj.isNeedBroadcastHurt=self.isNeedBroadcastHurt
                _G.CharacterManager:removeNoHookArray(obj)
            elseif self.m_nType==_G.Const.CONST_PARTNER then
                obj=CPartner(_G.Const.CONST_PARTNER)
                local property=clone(self:getProperty())
                property.partner_idx=math.abs(property.partner_idx+(_G.UniqueID : getNewID()))
                property.attr.hp=self.m_nHP
                obj:partnerInit(property)
                obj.m_subject=self
                obj.m_boss=self.m_boss
                obj:setAI(self:getAI())
                obj:setLocationXY(x,self:getLocationY())
                self.m_stageView:addCharacter(obj)
            end
            if obj~=nil then
                table.insert(self.m_cloneList,obj)
                obj.m_lpMovieClip:setColor(cc.c3b(96,134,169))
                obj:setSkillCD(self.m_nSkillID,100000)
            end
        end

    elseif buffType == _G.Const.CONST_BATTLE_BUFF_DISPEL then
        if _buff.idEffect~=nil then
            -- print()
            self:removeBuff(_buff.idEffect)
        else
            for _buffType,_buff in pairs(self.m_buff) do
                if _buffType >= _G.Const.CONST_BATTLE_BUFF_DIZZY or _buffType <= _G.Const.CONST_BATTLE_BUFF_VARY then
                    self:removeBuff(_buffType)
                end
            end
        end
        -- if self.m_buff[_G.Const.CONST_BATTLE_BUFF_DISPEL] then return end
        -- for k,v in pairs(table_name) do
        --     print(k,v)
        -- end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_EFFECT_DISPLAY then
        if self.m_buff[buffType] then return end
        if self.m_lpMovieClip and type(_buff.idEffect)=="table" and self.m_lpMovieClip.delSoltHideName then
            for i=1,#_buff.idEffect do
                self.m_lpMovieClip:delSoltHideName(_buff.idEffect[i])
            end
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_EFFECT_HIDDEN then
        if self.m_buff[buffType] then return end
        if self.m_lpMovieClip and type(_buff.idEffect)=="table" and self.m_lpMovieClip.addSoltHideName then
            for i=1,#_buff.idEffect do
                self.m_lpMovieClip:addSoltHideName(_buff.idEffect[i])
            end
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_STOP_ACTION then
         -- print("怪物暂停buff,",self.m_nID,self.m_nHP)
        if self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_USESKILL and self.m_nHP>0 then
            if not self.m_buff[buffType] then
                if self.m_lpMovieClip then
                    self.m_lpMovieClip:setTimeScale(0)
                end
            end
            
        else
            return
        end
    elseif buffType == _G.Const.CONST_BATTLE_BUFF_DODGE then
        self.m_noBeTarget=true
    end

    self.m_buff[buffType] = _buff
    if buffType == _G.Const.CONST_BATTLE_BUFF_THRUST 
        or buffType== _G.Const.CONST_BATTLE_BUFF_HANGIN then
        if _buff.speed and _buff.pushAngle and _buff.acceleration then
            local pushAngle = _buff.pushAngle
            local tempScaleX= self.m_thrustScaleX or self.m_nScaleX
            if tempScaleX>0 then
                pushAngle =math.abs(_buff.pushAngle)-180
            end
            self:thrust( _buff.speed, pushAngle, _buff.acceleration,_buff.downacceleration)
        end
    end
end

function CBaseCharacter.initialShaderType(self,_type)
    self.m_initialShaderType=_type
    print("initialShaderType====>>>",_type)
    if self.m_initialShaderType~=nil then
        _G.ShaderUtil:shaderSpineById(self.m_lpMovieClip,self.m_initialShaderType)
        if self.m_backBody then
            _G.ShaderUtil:shaderSpineById(self.m_backBody,self.m_initialShaderType)
        end
        if self.m_isMountBattle then
            _G.ShaderUtil:shaderSpineById(self.m_mountMovieClip,self.m_initialShaderType)
        end
    else
        _G.ShaderUtil:resetSpineShader(self.m_lpMovieClip)
        if self.m_backBody then
            _G.ShaderUtil:resetSpineShader(self.m_backBody)
        end
        if self.m_isMountBattle then
            _G.ShaderUtil:resetSpineShader(self.m_mountMovieClip)
        end
    end
end

function CBaseCharacter.removeBuffEffect(self,_buffType)
    if self.m_isShader then
        self:initialShaderType(self.m_initialShaderType)
        self.m_isShader=nil
    end
    if self.m_buffEffect ~= nil then
        local spr = self.m_buffEffect:getChildByTag(_buffType)
        if spr ~= nil then
            local function c()
                spr:removeFromParent(true)
            end
            spr:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(c)))
        end
    end
    if self.m_ringEffect ~= nil then
        local spr = self.m_ringEffect:getChildByTag(_buffType)
        if spr ~= nil then
            local function c()
                spr:removeFromParent(true)
            end
            spr:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(c)))
        end
    end
end

function CBaseCharacter.addBuffEffect(self,_buff)
    if not self.isMainPlay and self.m_stageView.m_onUpdateCharcterCount>=10 then
        if self.m_nType==_G.Const.CONST_PLAYER then return end
    end

    local buffType=_buff:gettype()
    local duration = _buff.duration
    local offsetY=_buff.positiony
    if offsetY~=nil then
        if buffType==_G.Const.CONST_BATTLE_BUFF_DIZZY then
            offsetY=self.m_skeletonHeight
        else
            offsetY=offsetY*self.m_nScaleXPer
        end
    end
    local offsetX=_buff.timeinterval

    if _buff.num ~=nil and not self.m_isShader then
        self.m_isShader=true
        _G.ShaderUtil:shaderSpineById(self.m_lpMovieClip,_buff.num)
        if self.m_backBody then
            _G.ShaderUtil:shaderSpineById(self.m_backBody,_buff.num)
        end
        if self.m_isMountBattle then
            _G.ShaderUtil:shaderSpineById(self.m_mountMovieClip,_buff.num)
        end
    end
    if _buff.idEffect == nil then return  end
    local buffEffect = _G.SpineManager.createSpine("spine/".._buff.idEffect,1)
    buffEffect:setAnimation(0,"idle",true)
    buffEffect:setPosition(offsetX,offsetY)
    buffEffect:setTag(buffType)
    if _buff.hit_per==1 then
        if self.m_ringEffect == nil then 
            self.m_ringEffect = cc.Sprite:create()
            self.m_lpContainer:addChild(self.m_ringEffect,-9)
        end
        self.m_ringEffect:addChild(buffEffect)
    else
        if self.m_buffEffect == nil then 
            self.m_buffEffect = cc.Sprite:create()
            self.m_lpMovieClipContainer:addChild(self.m_buffEffect,1000)
        end
        self.m_buffEffect:addChild(buffEffect)
    end
end

function CBaseCharacter.getBuff( self, _buffType )
    return self.m_buff[_buffType]
end

function CBaseCharacter.removeBuff( self, _buffType )
    if self.m_buff[_buffType] and type(self.m_buff[_buffType].buffId)=="table" then
        for _,buff in pairs(self.m_buff[_buffType].buffId) do
            local invBuff= _G.GBuffManager:getBuffNewObject(buff, 0)
            self:addBuff(invBuff)
        end
    end
    -- print("removeBuff=======",_buffType,debug.traceback())
    if _buffType == _G.Const.CONST_BATTLE_BUFF_RIGIDITY then
        if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_HURT then
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
        end
        self:stopHurtVibrate()
    -- elseif _buffType==_G.Const.CONST_BATTLE_BUFF_ENDUCE or
    --        buffType==_G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER then
        -- if self.m_lpMovieClip then
        --     local ccbiNode = self.m_lpMovieClip:getCCBINode()
        --     if ccbiNode then
        --         local effectChild = ccbiNode:getChildByTag(168)
        --         if effectChild then
        --             effectChild:setVisible(false)
        --         end
        --     end
        -- end
        -- if self.m_lpMovieClipBattle then
        --     local ccbiNode = self.m_lpMovieClipBattle:getCCBINode()
        --     if ccbiNode then
        --         local effectChild = ccbiNode:getChildByTag(168)
        --         if effectChild then
        --             effectChild:setVisible(false)
        --         end
        --     end
        -- end
    elseif _buffType >= _G.Const.CONST_BATTLE_BUFF_FROZEN  and _buffType <= _G.Const.CONST_BATTLE_BUFF_BURN 
        or _buffType == _G.Const.CONST_BATTLE_BUFF_ENDUCE or _buffType == _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER
        then
        if self.m_buff[_G.Const.CONST_BATTLE_BUFF_FROZEN] and _buffType == _G.Const.CONST_BATTLE_BUFF_FROZEN then
            self.setStatus=self.m_setStatusFun
            self.m_setStatusFun=nil
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
        end
        self:removeBuffEffect(_buffType)
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_ADD or _buffType == _G.Const.CONST_BATTLE_BUFF_MINUS then
        local buff = self:getBuff(_buffType)
        self:removeChangeAttrBuff(buff)
    -- elseif _buffType == _G.Const.CONST_BATTLE_BUFF_STOP then
    --     local _buff = self:getBuff(_buffType)
    --     if _buff.id>3300 and _buff.id<3310 then
    --         -- self.m_stageView:setResume()
    --     elseif _buff.id<3320 then
    --         self.m_lpMovieClip:resume()
    --         -- cc.Director:getInstance():pause()
    --     end
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_SPEED then
        local buff = self:getBuff(_buffType)
        self.m_nMoveSpeedX = self.m_nMoveSpeedX / (buff.per + 1)
        self.m_nMoveSpeedY = self.m_nMoveSpeedY / (buff.per + 1)
        self:removeBuffEffect(_buffType)
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_SHIELD then
        local buff = self:getBuff(_buffType)
        for _,buff in pairs(buff.data) do
            self:removeBuff(buff.type)
        end
        self:removeBuffEffect(_buffType)
        self.m_shieldHpNum=nil
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_INVINCIBLE then
        self.m_lpMovieClip:setOpacity(255)
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_VARY then
        local buff = self:getBuff(_buffType)
        self:setScalePer(1/buff.per)
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_STEALTH then
        local buff = self:getBuff(_buffType)
        if buff.num==0 then
            self.m_lpContainer:setVisible(true)
        else
            self.m_lpMovieClip:setOpacity(255)
        end
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_UNDEAD then
        self.m_buffHp=nil
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_CLONE then
        self:removeAllClones()
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_EFFECT_DISPLAY then
        local buff=self.m_buff[_buffType]
        if not buff then return end
        if self.m_lpMovieClip and type(buff.idEffect)=="table" and self.m_lpMovieClip.addSoltHideName then
            for i=1,#buff.idEffect do
                self.m_lpMovieClip:addSoltHideName(buff.idEffect[i])
            end
        end
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_EFFECT_HIDDEN then
        local buff=self.m_buff[_buffType]
        if not buff then return end
        if self.m_lpMovieClip and type(buff.idEffect)=="table" and self.m_lpMovieClip.delSoltHideName then
            for i=1,#buff.idEffect do
                self.m_lpMovieClip:delSoltHideName(buff.idEffect[i])
            end
        end
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_STOP_ACTION then
        print("释放掉暂停buff")
        if self.m_lpMovieClip then
            self.m_lpMovieClip:setTimeScale(1)
        end
    elseif _buffType == _G.Const.CONST_BATTLE_BUFF_DODGE then
        self.m_noBeTarget=false
    end
    self.m_buff[_buffType] = nil
end
function CBaseCharacter.removeAllClones(self)
    if self.m_cloneList~=nil then
        for i,monster in pairs(self.m_cloneList) do
            monster:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
            monster.m_noBeTarget=true
            self:removeClone(monster)
        end
        self.m_cloneList=nil
    end
end

function CBaseCharacter.removeBuffBySkillId( self, _skillId )
    local toBeRemoved={}
    local removeCount=0
    for k,v in pairs(self.m_buff) do
        if v:getSkillId() == _skillId then
            removeCount=removeCount+1
            toBeRemoved[removeCount]=v:gettype()
        end
    end
    for i=1,removeCount do
        self:removeBuff(toBeRemoved[i])
    end
    self:cancelTSpeed()
    toBeRemoved = nil
end

function CBaseCharacter.removeAllBuff( self )
    -- print("@$@@%@%$$$$")
    for _,buff in pairs(self.m_buff) do
        self:removeBuff(buff:gettype())
    end

    self.m_buff = {}
end

function CBaseCharacter.isHaveBuff( self, _buffType )
    return self.m_buff[_buffType]~=nil
end

function CBaseCharacter.removeThrustBuff( self )
    self : removeBuff( _G.Const.CONST_BATTLE_BUFF_RIGIDITY )
    self : removeBuff( _G.Const.CONST_BATTLE_BUFF_CRASH )
end

function CBaseCharacter.removeChangeAttrBuff( self,_buff )
    if _buff == nil then return end
    local warAttr = self:getWarAttr()
    local attr = {"strong_att","strong_def","wreck","hit","dodge","crit","crit_res","bonus","reduction"}
    for _,attrData in pairs(_buff.data) do
        local value = warAttr[attr[attrData.id-41]]
        value = value / (1+attrData.per)
        warAttr:updateProperty(attrData.id,value)
    end
    self.m_skillToVictims = {}
    local id
    if self.m_nType==_G.Const.CONST_MONSTER then
        id=self.m_monsterId
    else
        id=self.m_nID
    end
    for _,character in pairs(_G.CharacterManager:getCharacter()) do
        if character.m_skillToVictims and character.m_skillToVictims[id]~=nil then
            character.m_skillToVictims[id]=nil
        end
    end

end

function CBaseCharacter.removeUpdateJump(self)
    self.onUpdateJump=false
end
function CBaseCharacter.onUpdateJump( self, _duration )
    if not self.m_fYSpeed then
        return
    end
    
    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_STOP_ACTION) then return end

    local yDistance = self.m_fYSpeed*_duration-(0.5*self.m_nCurrentAcceleration*_duration*_duration)
    self.m_fYSpeed = self.m_fYSpeed-(self.m_nCurrentAcceleration*_duration)

    if yDistance<=0 then
        if self.m_nDownAcceleration then
            self.m_nCurrentAcceleration=self.m_nDownAcceleration
            self.m_nDownAcceleration=nil
        end
    end  

    local moveToZ = self.m_nLocationZ or 0
    moveToZ = moveToZ + yDistance
    moveToZ = moveToZ < 0 and 0 or moveToZ

    -- if moveToZ<=50 and yDistance<=0 then
    --     local invBuff= _G.GBuffManager:getBuffNewObject(401, 0)
    --     self:addBuff(invBuff)
    --     self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
    --     moveToZ=0
    --  end

    local moveX,moveY=self.m_nLocationX,self.m_nLocationY
    if self.m_fXSpeed~=nil then
        moveX = self.m_nLocationX+ self.m_fXSpeed * _duration
        local lx=self.m_stageView:getMaplx()+80
        local rx=self.m_stageView:getMaprx()-80
        if (moveX<=lx or moveX>=rx) and moveToZ>30 then
            -- local invBuff= _G.GBuffManager:getBuffNewObject(1599, 0)
            -- self:addBuff(invBuff)
            local invBuff= _G.GBuffManager:getBuffNewObject(406, 0)
            self:addBuff(invBuff)
            local invBuff= _G.GBuffManager:getBuffNewObject(1302, 0)
            self:addBuff(invBuff)
        end
    end

    if self.m_hYSpeed~=nil then
        moveY = self.m_nLocationY+ self.m_hYSpeed * _duration
    end
    self:setLocation(moveX,moveY,moveToZ)
    self:resetNamePos()
    if moveToZ<=0 then
        self.m_fYSpeed=nil
        self.m_accRate=1
        -- if self.m_nHP<=0 then 
        --     self:setStatus(_G.Const.CONST_BATTLE_STATUS_DEAD)
        -- else
        if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_CRASH then
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_FALL)
        end
        
    end
end

function CBaseCharacter.removeUpdateMove(self)
    self.onUpdateMove=false
end
function CBaseCharacter.onUpdateMove( self, _duration )
    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_STOP_ACTION) then return end

    if _duration==0 then return end
    
    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD 
        or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN) then
        if self.m_lpMovePos==nil and self.m_TSpeed==nil then return end
        self:cancelMove()
        self.m_TSpeed=nil
        return
    end

    if self.m_TSpeed~=nil then
        self.m_lpMovePos = nil
        local deltaX = self.m_nLocationX-self.m_TEndX
        local deltaY = self.m_nLocationY-self.m_TEndY
        local currentDistance = deltaX*deltaX+deltaY*deltaY
        if  currentDistance<= 1 then
            self:cancelTSpeed()
            return
        end

        local movePosX = self.m_nLocationX + _duration * self.m_TSpeedX
        local movePosY = self.m_nLocationY + _duration * self.m_TSpeedY

        local deltaX = movePosX-self.m_TEndX
        local deltaY = movePosY-self.m_TEndY

        local moveDistance =deltaX*deltaX+deltaY*deltaY
        if currentDistance <= moveDistance or deltaX*self.m_TScaleX>0 then
            movePosX = self.m_TEndX
            movePosY = self.m_TEndY

            self:setLocationXY(movePosX,movePosY)
            self:cancelTSpeed()
            return
        end
        self:setLocationXY(movePosX,movePosY)
        return
    end

    if self.m_lpMovePos~=nil
        and (self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_FALL
                or self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_HURT
                or self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH
                or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY))  then
        self:cancelMove()
        return
    end

    if self.m_lpMovePos==nil then
        if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_MOVE then
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
        end
        return
    end

    local deltaX=self.m_nLocationX-self.m_lpMovePos.x
    local deltaY=self.m_nLocationY-self.m_lpMovePos.y
    local characterDistance=deltaX*deltaX+deltaY*deltaY
    if characterDistance<=1 then
        if self.m_lpMovePos.scaleX~=nil then
            self:setMoveClipContainerScalex(self.m_lpMovePos.scaleX)
        end
        self:cancelMove()
        return
    end

    local realDiatance=math.sqrt(characterDistance)
    local speedx=self.m_nMoveSpeedX*deltaX/realDiatance
    local speedy=self.m_nMoveSpeedY*deltaY/realDiatance
    self.m_lpMovePos.speedx=speedx
    self.m_lpMovePos.speedy=speedy

    local movePosX=self.m_nLocationX-_duration*speedx
    local movePosY=self.m_nLocationY-_duration*speedy

    deltaX=movePosX-self.m_lpMovePos.x
    deltaY=movePosY-self.m_lpMovePos.y
    local moveDistance=deltaX*deltaX+deltaY*deltaY
    if characterDistance<=moveDistance then
        self:setLocation(self.m_lpMovePos.x,self.m_lpMovePos.y,self.m_nLocationZ)
        if not self.m_isJoyStickPress then
            self:cancelMove()
        end
        return
    end

    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_IDLE then
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)
    end

    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then
        -- if not self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_LOCKX) then
        --     movePosX = self.m_nLocationX
        -- end
        -- if not self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_LOCKY) then
        --     movePosY = self.m_nLocationY
        -- end
        if not self:getBuff(_G.Const.CONST_BATTLE_BUFF_SKILL_MOVE) and not self.m_isMoveAndSkill then
            self.m_lpMovePos=nil
        end
    elseif not self.m_stageView.m_isCity then
        local subX=self.m_nLocationX-movePosX
        if math.abs(subX)>5 then
            if subX<0 then
                self:setMoveClipContainerScalex(1)
            else
                self:setMoveClipContainerScalex(-1)
            end
        end
    end

    -- if self.m_nMoveSpeedY==0 then
    --     movePosY=self.m_nLocationY
    -- end
    -- if self.m_nMoveSpeedX==0 then
    --     movePosX=self.m_nLocationX
    -- end
    self:setLocation(movePosX, movePosY, self.m_nLocationZ)
end
--添加飞云
function CBaseCharacter.addFlySpr( self )
    local spr=_G.SpineManager.createSpine("map/10402_tsp_02")
    self.m_lpContainer:addChild(spr)
    self.m_flySpr=spr
    self.moveActionName="idle"
end
--设置影子
function CBaseCharacter.setShadow( self )
    local lpShadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    lpShadow:setScale(self.m_nScaleXPer*1.5)
    lpShadow:setTag(66659)
    if self.m_mountSkinId and self.m_mountSkinId>0 and self.m_stageView.m_isCity then
        lpShadow:setScale(self.m_nScaleXPer*3)
    elseif self.m_SkinId==20731 then
        lpShadow:setScaleX(5)
        lpShadow:setScaleY(3)
        local spr = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
        spr:setAnchorPoint(0,0)
        lpShadow:addChild(spr)
    end
    self.m_lpContainer:addChild(lpShadow,-10)
end
function CBaseCharacter.removeShadow( self )
    self.m_lpContainer:removeChildByTag(66659)
end
function CBaseCharacter.setShadowScale(self,_scale)
    local lpShadow=self.m_lpContainer:getChildByTag(66659)
    if lpShadow then
        lpShadow:setScale(_scale)
    end
end
function CBaseCharacter.addPartnerHalo(self)
    local tempAsset=gaf.GAFAsset:create("gaf/halo.gaf")
    self.m_partnerHaloGaf=tempAsset:createObject()
    self.m_partnerHaloGaf:setLooped(true,false)
    self.m_partnerHaloGaf:start()
    self.m_partnerHaloGaf:setScale(self.m_nScaleXPer*0.7)
    self.m_partnerHaloGaf:setPositionY(10)
    self.m_lpContainer:addChild(self.m_partnerHaloGaf,-5)
end

function CBaseCharacter.getAttackSkillID( self )
    if self.m_AttackSkillIds==nil then
        local initSKillData =_G.g_SkillDataManager:getSkillInitData(self.m_SkinId)
        if initSKillData==nil then return end
        self.m_AttackSkillIds=initSKillData.skill_none

        if self.m_AttackSkillIds==nil then return end
    end
    if self.m_nSkillID == 0 then
        self.m_nNextSkillID = 0
        -- self.m_nNextSkillID2 = 0
        return self.m_AttackSkillIds[1]
    end
    local lastSelectSkillId = self.m_nSkillID
    -- if self.m_nNextSkillID3~=0 then
    --     lastSelectSkillId=self.m_nNextSkillID3
    -- else
    -- if self.m_nNextSkillID2~=0 then
    --     lastSelectSkillId=self.m_nNextSkillID2
    -- elseif self.m_nNextSkillID~=0 then
    --     lastSelectSkillId=self.m_nNextSkillID
    -- elseif self.m_nSkillID~=0 then
    --     lastSelectSkillId=self.m_nSkillID
    -- end
    -- if lastSelectSkillId == 0 or lastSelectSkillId == nil then
    --     return self.m_AttackSkillIds[1]
    -- end
    print(lastSelectSkillId,"skill_noneID")
    for i=1,_G.Const.CONST_BATTLE_SKILL_NONE_NUM-1 do
        if lastSelectSkillId ==self.m_AttackSkillIds[i] then
            local skillNode =_G.g_SkillDataManager:getSkillEffect(lastSelectSkillId)
            if skillNode == nil then
                CCLOG("CBaseCharacter.getAttackSkillID 无技能数据")
                return 0
            end
            return self.m_AttackSkillIds[i+1]
        end
    end
    return self.m_AttackSkillIds[1]
end

-- function CBaseCharacter.setLeaderUID( self, _leaderUid )
--     self.m_nLeaderUid = _leaderUid
-- end

-- function CBaseCharacter.getLeaderUID( self )
--     return self.m_nLeaderUid
-- end

function CBaseCharacter.getConvertCollider( self, _collider, _isFlip )
    if self.m_lpContainer==nil or _collider == nil or _collider.offsetX==nil then
        return
    end

    -- print("TTTTTTTTTTTTTTTTTTTTTTTTTTTT=======>>>")
    local offsetX = _collider.offsetX
    local offsetY = _collider.offsetY
    local vWidth = _collider.vWidth
    local vHeight =_collider.vHeight

    local scaleX=self.m_nScaleX or 1
    if _isFlip == true then
        scaleX = -scaleX
    end

    local vX = nil
    if scaleX>= 0 then
        vX =offsetX+ self.m_nLocationX
    else
        vX =-offsetX + self.m_nLocationX - vWidth
    end
    local vY =offsetY+ self.m_nLocationY
    -- print(vY,self.m_nLocationY,vHeight,_collider.vHeight,"getConvertCollider")
    return vX, vY, nil, vWidth, vHeight, nil
end

function CBaseCharacter.checkCollisionSkill( self, _skillNode, _currentFrame)
    if _currentFrame.collider==0 then
        return false
    end
   
    local currentCollider=_currentFrame.collider
    if not currentCollider then
        return false
    end
    if currentCollider.vWidth==0 and currentCollider.vHeight==0 and currentCollider.offsetX==0 and currentCollider.offsetY==0 then
        return false
    end
    if self.m_nScaleXPer ~= 1 and self.m_nScaleXPer ~= nil then
        currentCollider = {}
        currentCollider.vWidth=_currentFrame.collider.vWidth * self.m_nScaleXPer
        currentCollider.vHeight=_currentFrame.collider.vHeight * self.m_nScaleXPer
        currentCollider.offsetX=_currentFrame.collider.offsetX * self.m_nScaleXPer
        currentCollider.offsetY=_currentFrame.collider.offsetY * self.m_nScaleXPer
        currentCollider.offsetZ=_currentFrame.collider.offsetZ * self.m_nScaleXPer
        currentCollider.vRange=_currentFrame.collider.vRange * self.m_nScaleXPer
    end

    if self.m_attLayer ~= nil and self.m_noAtt then
        local scaleX = self.m_nScaleX
        if scaleX > 0 then
            offsetX = currentCollider.offsetX
        else
            offsetX = currentCollider.offsetX * scaleX - currentCollider.vWidth
        end
        self.m_attLayer:stopAllActions()
        self.m_attLayer:setContentSize(cc.size(currentCollider.vWidth,currentCollider.vHeight))
        self.m_attLayer:setPosition(offsetX,currentCollider.offsetY)
        self.m_attLayer:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(0.2),cc.Hide:create()))

        if self.m_numLabel~=nil then
            self.m_numLabel:setString(_currentFrame.id)
        end
    end
    if self.m_attHeiLayer~=nil and self.m_noAtt and currentCollider and currentCollider.vHeight~=nil and currentCollider.offsetY~=nil then
        local scaleX = self.m_nScaleX
        if scaleX > 0 then
            offsetX = currentCollider.offsetX
        else
            offsetX = currentCollider.offsetX * scaleX - currentCollider.vWidth
        end        
        self.m_attHeiLayer:stopAllActions()
        self.m_attHeiLayer:setContentSize(cc.size(currentCollider.vWidth,currentCollider.vRange))
        self.m_attHeiLayer:setPosition(offsetX,(currentCollider.offsetY+currentCollider.vHeight)*0.5)
        self.m_attHeiLayer:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(0.2),cc.Hide:create()))            
    end    

    -- self:setBlockByColliderId(_currentFrame.collider)
    
    local iscollider = false
    local isHit = false
    -- if self : getLocationX() <= _G.Const.CONST_BOSS_SECURITY_X and 
    --         (self.m_stageView : getScenesType() == _G.Const.CONST_MAP_TYPE_BOSS 
    --             or self.m_stageView : getScenesType() == _G.Const.CONST_MAP_TYPE_CLAN_BOSS ) then
    --     return false
    -- end

    local masterUid = self.m_nID
    local masterType = self.m_nType
    local assailant = self

    if masterType == _G.Const.CONST_VITRO then
        masterUid = self.m_nMasterID
        masterType = self.m_nMasterType

        assailant = _G.CharacterManager : getCharacterByTypeAndID(self.m_nMasterType, self.m_nMasterID)
        -- local sss=assailant~=nil and assailant.m_nType
    end

    if assailant==nil then return false end
    local selfProperty = assailant.m_property -- _G.GPropertyProxy:getOneByUid( masterUid, masterType )
    if selfProperty == nil then
        return false
    end
    local num=nil
    if _currentFrame.num~=0 then
        num=_currentFrame.num
    end
    local characterList,teamList =_G.CharacterManager:getCharacterByVertex(self,currentCollider,selfProperty:getTeamID(),num)
    -- print("characterList",#characterList)
    if #teamList~=0 then
        for _,character in pairs(teamList) do
            character:handleSkillFrameBuff(_currentFrame,2,1,self.m_nSkillID)
        end
    end
    if #characterList==0 then
        return
    end
    
    local skillData = selfProperty:getSkillData()
    local skillLv_data = skillData:getSkillLvBySkillID(self.m_nSkillID)
    local skillLv = 1
    if skillLv_data~=nil then
        skillLv = skillLv_data.skill_lv
    else
        if masterType==_G.Const.CONST_PLAYER then
            -- 第二把箭要减1000
            -- if self.m_nSkillID==selfProperty:getMountID() or self.m_nSkillID-1000==selfProperty:getMountID() then
            if assailant.m_isMountBattle then
                skillLv=selfProperty:getMountLv()
            elseif self.m_nSkillID==selfProperty:getArtifactSkillLv() or self.m_nSkillID-1000==selfProperty:getArtifactSkillLv() then
                skillLv=selfProperty:getArtifactSkillLv() or 1
            else                
                local skillData=_G.g_SkillDataManager:getSkillData(self.m_nSkillID)
                if skillData and skillData.lv then
                    local key = next(skillData.lv)
                    if key~=nil then
                        skillLv=key
                    end
                end
            end
        end
    end

    local isTouchFeatherEffect=self.m_skillBuffIndex~=0 and _currentFrame.id==self.m_skillBuffIndex
    local featherBuffData
    if isTouchFeatherEffect then
        featherBuffData=_G.Cfg.feather_quality[self.m_featherId][self.m_featherLv]
        if featherBuffData then
            featherBuffData=featherBuffData.buff
            local newData={}
            for _,buff in pairs(featherBuffData) do
                if buff[1]==0 then
                    local invBuff=_G.GBuffManager:getBuffNewObject(buff[2],0)
                    self:addBuff(invBuff)
                else
                    newData[#newData+1]=buff
                end
            end
            featherBuffData=newData
            self:showFeatherBuffEffect()
        else
            isTouchFeatherEffect=false
        end
        self.m_skillBuffIndex=nil
    end

    local _Assailant, _Victim, _VictimBoss = nil

    for _,character in pairs(characterList) do
        -- if character.m_nLocationX <= _G.Const.CONST_BOSS_SECURITY_X and 
        --     (self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_BOSS or self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS) then
        --     CCLOG("在安全区域")
        -- else
            -- if self.m_nType == _G.Const.CONST_VITRO or self.m_nType == _G.Const.CONST_TRAP then
            if self.m_beAttackers and self.m_attackTimes then
                local isCanAttack = false
                local mID=string.format("%s_%s",character.m_nID,character.m_nType)
                local attackTimes=self.m_beAttackers[mID]
                if attackTimes==nil then
                    self.m_beAttackers[mID]=1
                    isCanAttack=true
                else
                    if attackTimes>=self.m_attackTimes then
                        isCanAttack=false
                    else
                        attackTimes=attackTimes+1
                        self.m_beAttackers[mID]=attackTimes
                        isCanAttack=true
                    end
                end
                -- print("JKJKJKJJJKJKJKJKJKJKJKJKJK====>>>>>",isCanAttack)
                if isCanAttack then
                    local vitroCharacter=nil
                    if self.m_nType == _G.Const.CONST_VITRO or self.m_nType == _G.Const.CONST_TRAP then
                        vitroCharacter=self
                    end
                    isHit =_G.SkillHurt:calculateSkillHurt( _skillNode, _currentFrame, assailant, character,self.m_nSkillID,skillLv,vitroCharacter)
                    iscollider = true
                end
            else
                isHit =_G.SkillHurt:calculateSkillHurt( _skillNode, _currentFrame, assailant, character,self.m_nSkillID,skillLv)
                iscollider = true
            end

            if isTouchFeatherEffect and character.m_nType==_G.Const.CONST_MONSTER then
                for _,buff in pairs(featherBuffData) do
                    local invBuff=_G.GBuffManager:getBuffNewObject(buff[2],0)
                    if invBuff.type==_G.Const.CONST_BATTLE_BUFF_BLEED then
                        local _,totalHurtValue=_G.SkillHurt:compute( _skillNode, _currentFrame, assailant, character, self.m_nSkillID,skillLv)
                        invBuff.totalHurtValue=totalHurtValue
                    end
                    character:addBuff(invBuff)
                end
            end

            if assailant~=nil and assailant.m_nType==_G.Const.CONST_PLAYER then
                _Assailant=assailant
                -- 改
                if _Assailant.m_targeter~=character then
                    if _Victim==nil then

                        _Victim=character   
                    elseif self.m_stageView:getScenesType()==_G.Const.CONST_MAP_TYPE_CITY_BOSS and character.m_nType==_G.Const.CONST_MONSTER then

                        _Victim = character
                        _VictimBoss=_Victim
                        break;
                    end                
                else
                    _Victim=false
                end
            end
        -- end
    end
    if _Assailant~=nil then
        if _Victim~=nil and _Victim~=false then
            if _VictimBoss~=nil then
                _Assailant:setTargeter(_VictimBoss)
                -- print("setTargeter is boss")
            else
                _Assailant:setTargeter(_Victim)
                -- print("setTargeter is player")
            end
        end
    end

    if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        if assailant.m_victimDatas~=nil then
            local msg = REQ_WAR_HARM_ALL()
            msg.count = #assailant.m_victimDatas
            msg.msg_xxx = assailant.m_victimDatas
            _G.Network:send(msg)
        end
        assailant.m_victimDatas=nil
    end
    return iscollider,isHit
end

function CBaseCharacter.showNormalHurtNumber(self, _nHp)
    if self.m_stageView.m_lpCharacterContainer==nil or self.m_stageView.m_hurtHpNum>_G.Const.CONST_BOSS_BX_TIME then return end

    if not self.isMainPlay and self.m_stageView.m_onUpdateCharcterCount>7 then
        if self.m_stageView.m_onUpdateCharcterCount>20 then
            if math.random(1,100)<80 then return end
        elseif self.m_stageView.m_onUpdateCharcterCount>10 then
            if math.random(1,100)<55 then return end
        else
            if math.random(1,100)<30 then return end
        end
    end
    
    _nHp=math.ceil(math.abs(_nHp))

    local stringHp=tostring(_nHp)
    local nlength =string.len(stringHp)
    if nlength <= 0 then
        return
    end
    local _hurtSprite = cc.Node:create()--cc.SpriteBatchNode:create("ui/battle.pvr.ccz")

    local x = -nlength*12.5
    local y = 0
    local spriteFrameName = nil
    if self.isMainPlay then
        spriteFrameName="player_hp_"
    else
        spriteFrameName="monster_hp_"
    end

    local fIn=cc.FadeIn:create(0.2)
    local ebIn1=cc.EaseBounceIn:create(cc.ScaleTo:create(0.2,1.5))
    local ebIn2=cc.EaseBounceIn:create(cc.ScaleTo:create(0.01,1))
    local fOut=cc.FadeTo:create(0.4,0)
    local seq1 = cc.Sequence:create(fIn,ebIn1,ebIn2,fOut)
    local currSprSize = cc.size(28,39)
    for i=1, nlength do
        local currStr = string.sub(stringHp, i, i)
        local currStrSprName =string.format("battle_%s%s.png",spriteFrameName,currStr)
        local currSprite = cc.Sprite :createWithSpriteFrameName( currStrSprName )
        -- currSprite : setScale(1)
        _hurtSprite :addChild( currSprite )
        currSprite :runAction(seq1:clone())
        -- local currSprSize = currSprite :getContentSize()
        x=x+currSprSize.width*0.5
        currSprite :setPosition(x, y)
        x=x+currSprSize.width*0.5
    end

    local selfX,selfY = self:getLocationXY()
    local locationZ = self.m_nLocationZ or 0
    local hurtX = self.m_skinData.hurt_x*self.m_nScaleX+selfX+math.random(0,50)*-self.m_nScaleX
    local hurtY = self.m_skinData.hurt_y+selfY+locationZ
    
    local lastX = hurtX+(math.random(0,100)+50)*-self.m_nScaleX
    local lastY = hurtY+math.random(0,30)+90
    local midX   = (lastX - hurtX) * 0.6 + hurtX
    local midY   = (lastY - hurtY) * 0.6 + hurtY 
    _hurtSprite:setPosition(hurtX,hurtY)

    local function delfunc()
        _hurtSprite:removeFromParent( true )
        self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum-1
    end
    local cFun=cc.CallFunc:create(delfunc)
    local moveTo1 = cc.MoveTo:create(0.2,cc.p(midX,midY))
    local delayTime = cc.DelayTime:create(0.3)
    local moveTo2 = cc.MoveTo:create(0.4,cc.p(lastX,lastY))
    local seq2 = cc.Sequence:create(moveTo1,delayTime,moveTo2,cFun)
    _hurtSprite:runAction(seq2)
    self.m_stageView.m_lpCharacterContainer:addChild(_hurtSprite,-1)
    self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum+1
end
function CBaseCharacter.showBleedHurtNumber(self, _nHp)
    if self.m_stageView.m_lpCharacterContainer==nil or self.m_stageView.m_hurtHpNum>_G.Const.CONST_BOSS_BX_TIME then return end
    
    _nHp=math.ceil(math.abs(_nHp))

    local stringHp=tostring(_nHp)
    local nlength =string.len(stringHp)
    if nlength<=0 then
        return
    end
    local _hurtSprite = cc.Node:create()

    local x = -nlength*12.5
    local spriteFrameName = nil
    spriteFrameName="player_hp_"

    -- local fIn=cc.FadeIn:create(0.2)
    -- local ebIn1=cc.EaseBounceIn:create(cc.ScaleTo:create(0.2,1.5))
    -- local ebIn2=cc.EaseBounceIn:create(cc.ScaleTo:create(0.01,1))
    -- local fOut=cc.FadeTo:create(0.4,0)
    -- local seq1 = cc.Sequence:create(fIn,ebIn1,ebIn2,fOut)
    local currSprWid=28
    for i=1, nlength do
        local currStr = string.sub(stringHp, i, i)
        local currStrSprName =string.format("battle_%s%s.png",spriteFrameName,currStr)
        local currSprite = cc.Sprite :createWithSpriteFrameName( currStrSprName )
        currSprite : setScale(0.5)
        _hurtSprite :addChild( currSprite )
        -- currSprite :runAction(seq1:clone())

        x=x+currSprWid*0.2
        currSprite :setPositionX(x)
        x=x+currSprWid*0.2
    end

    local selfX,selfY = self:getLocationXY()
    local locationZ = self.m_nLocationZ or 0
    local hurtX = self.m_skinData.hurt_x+selfX+30*-self.m_nScaleX
    local hurtY = self.m_skinData.hurt_y+selfY+locationZ+50
    
    local lastX = 100*-self.m_nScaleX
    local lastY = -150
    _hurtSprite:setPosition(hurtX,hurtY)

    local function delfunc()
        _hurtSprite:removeFromParent( true )
        self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum-1
    end
    local cFun=cc.CallFunc:create(delfunc)    
    local moveTo1 = cc.MoveBy:create(1,cc.p(lastX,0))
    -- local delayTime = cc.DelayTime:create(0.3)
    local moveTo2 = cc.MoveBy:create(1,cc.p(0,lastY))
    local moveTo2  = cc.EaseSineIn:create(moveTo2)
    local seq2 = cc.Sequence:create(cc.Spawn:create(moveTo1,moveTo2),cFun)
    _hurtSprite:runAction(seq2)
    self.m_stageView.m_lpCharacterContainer:addChild(_hurtSprite,-1)
    self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum+1
end

function CBaseCharacter.showCritHurtNumber(self, _nHp)
    if self.m_stageView.m_lpCharacterContainer==nil or self.m_stageView.m_hurtHpNum>_G.Const.CONST_BOSS_BX_TIME-100 then return end

    if not self.isMainPlay and self.m_stageView.m_onUpdateCharcterCount>7 then
        if self.m_stageView.m_onUpdateCharcterCount>20 then
            if math.random(1,100)<80 then return end
        elseif self.m_stageView.m_onUpdateCharcterCount>10 then
            if math.random(1,100)<55 then return end
        else
            if math.random(1,100)<30 then return end
        end
    end

    _nHp=math.ceil(math.abs(_nHp))

    local stringHp=tostring(_nHp)
    local nlength = string.len(stringHp)
    if nlength <= 0 then
        return
    end
    local spriteFrameName
    local spriteFrameNamec
    if self.isMainPlay then
        spriteFrameName="battle_crit_hitp_"
        spriteFrameNamec="battle_attackp.png"
    else
        spriteFrameName="battle_crit_hit_"
        spriteFrameNamec="battle_attack.png"
    end
    local _hurtSprite = cc.Node:create()
    
    local critSprite=cc.Sprite:createWithSpriteFrameName(spriteFrameNamec)
    critSprite:setAnchorPoint(cc.p(1,0.5))
    local critWidth=102
    _hurtSprite:addChild(critSprite)

    local spritesList = {}
    local totalLength =critWidth

    local fIn=cc.FadeIn:create(0.2)
    local ebIn1=cc.EaseBounceIn:create(cc.ScaleTo:create(0.2,1.5))
    local ebIn2=cc.EaseBounceIn:create(cc.ScaleTo:create(0.01,1))
    local fOut=cc.FadeTo:create(0.4,0)
    local seq1 = cc.Sequence:create(fIn,ebIn1,ebIn2,fOut)
    local currSprWid=28
    for i=1, nlength do
        local currStr = string.sub( stringHp, i, i)
        local currStrSprName=string.format("%s%s.png",spriteFrameName,currStr)
        local currSprite = cc.Sprite :createWithSpriteFrameName( currStrSprName )
        _hurtSprite :addChild( currSprite )
        currSprite : setAnchorPoint(cc.p(0,0.5))
        currSprite : runAction(seq1:clone())

        spritesList[i]=currSprite
        totalLength=totalLength+currSprWid-10
    end

    local x=-totalLength*0.5+critWidth
    critSprite:setPositionX(x)
    critSprite:runAction(seq1:clone())
    for i=1,nlength do
        spritesList[i]:setPositionX(x)
        x=x+currSprWid
    end

    spritesList=nil

    local selfX,selfY = self:getLocationXY()
    local locationZ = self.m_nLocationZ or 0
    local hurtX = self.m_skinData.hurt_x+selfX+math.random(0,50)*-self.m_nScaleX
    local hurtY = self.m_skinData.hurt_y+selfY+locationZ
    
    local lastX = hurtX+(math.random(0,100)+50)*-self.m_nScaleX
    local lastY = hurtY+math.random(0,30)+90
    local midX  = (lastX - hurtX) * 0.6 + hurtX
    local midY  = (lastY - hurtY) * 0.6 + hurtY 
    _hurtSprite:setPosition(hurtX,hurtY)

    local function delfunc()
        _hurtSprite:removeFromParent( true )
        self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum-1
    end
    local cFun=cc.CallFunc:create(delfunc)
    local moveTo1 = cc.MoveTo:create(0.2,cc.p(midX,midY))
    local delayTime = cc.DelayTime:create(0.3)
    local moveTo2 = cc.MoveTo:create(0.4,cc.p(lastX,lastY))
    local seq2 = cc.Sequence:create(moveTo1,delayTime,moveTo2,cFun)
    _hurtSprite:runAction(seq2)
    self.m_stageView.m_lpCharacterContainer:addChild(_hurtSprite,-1)
    self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum+1
end

function CBaseCharacter.showdodge(self,hurtType)
    if self.m_stageView.m_lpCharacterContainer==nil or self.m_stageView.m_hurtHpNum>_G.Const.CONST_BOSS_BX_TIME then return end

    if not self.isMainPlay and self.m_stageView.m_onUpdateCharcterCount>7 then
        return
    end

    local dodgeSprite=cc.Sprite:createWithSpriteFrameName("battle_dodge.png")

    local fIn=cc.FadeIn:create(0.2)
    local ebIn1=cc.EaseBounceIn:create(cc.ScaleTo:create(0.2,1.5))
    local ebIn2=cc.EaseBounceIn:create(cc.ScaleTo:create(0.01,1))
    local fOut=cc.FadeTo:create(0.4,0)
    local seq1 = cc.Sequence:create(fIn,ebIn1,ebIn2,fOut)

    local selfX,selfY = self:getLocationXY()
    local locationZ = self.m_nLocationZ or 0
    local hurtX = self.m_skinData.hurt_x+selfX+math.random(0,50)*-self.m_nScaleX
    local hurtY = self.m_skinData.hurt_y+selfY+locationZ
    
    local lastX = hurtX+(math.random(0,100)+50)*-self.m_nScaleX
    local lastY = hurtY+math.random(0,30)+90
    local midX   = (lastX - hurtX) * 0.6 + hurtX
    local midY   = (lastY - hurtY) * 0.6 + hurtY 
    dodgeSprite:setPosition(hurtX,hurtY)


    local function delfunc()
        dodgeSprite:removeFromParent( true )
        self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum-1
    end
    local cFun=cc.CallFunc:create(delfunc)
    local moveTo1 = cc.MoveTo:create(0.2,cc.p(midX,midY))
    local delayTime = cc.DelayTime:create(0.3)
    local moveTo2 = cc.MoveTo:create(0.4,cc.p(lastX,lastY))
    local seq2 = cc.Sequence:create(moveTo1,delayTime,moveTo2,cFun)
    dodgeSprite:runAction(cc.Spawn:create(seq1,seq2))

    self.m_stageView.m_lpCharacterContainer:addChild(dodgeSprite,self.m_nLocationY)
    self.m_stageView.m_hurtHpNum=self.m_stageView.m_hurtHpNum+1
end


function CBaseCharacter.setTargeter(self,character)
    if character==nil or character.m_nHP==0 then
        return 
    end
    -- print("CBaseCharacter.setTargeter====>>>self.m_nID=",self.m_nID,"character.m_nHP=",character.m_nHP,"character.m_nType=",character.m_nType,"character.m_nID",character.m_nID)
    if character.m_lpBigHp==nil and 
        (character.m_nType==_G.Const.CONST_MONSTER 
            or character.m_nType==_G.Const.CONST_PLAYER
            or character.m_nType==_G.Const.CONST_PARTNER
            or (character.m_nType==_G.Const.CONST_GOODS_MONSTER and character:getMaxHp()~=nil)) then

        character.m_attacker=self
        self.m_targeter=character

        -- if self.isMainPlay~=true and character.m_nType==_G.Const.CONST_PLAYER then
        --     print("CBaseCharacter.setTargeter====>>> 忽略,不是自己打的。")
        -- else
        if not character.isMainPlay and self.isMainPlay then
            character:addBigHpView(false)
        end
    end
end

function CBaseCharacter.destoryBigHpView(self)
    if self.m_lpBigHpView~=nil then
        if self.m_lpBigHp ~= nil then
            self.m_lpBigHp:setHpValue(0,self.m_nMaxHP)
            self.m_lpBigHp=nil
        end
        if not(self.m_nType==_G.Const.CONST_PLAYER or self.m_nType==_G.Const.CONST_TEAM_HIRE) then
            self.m_lpBigHpView:removeFromParent(true)
        elseif self.m_stageView.m_sceneType== _G.Const.CONST_MAP_TYPE_CITY_BOSS then
            if not self.isMainPlay then
                self.m_lpBigHpView:removeFromParent(true)
            end
        end
        self.m_lpBigHpView=nil
    end
end

function CBaseCharacter.addBigHpView( self, _isleft,isSmallView)
    if self.m_stageView.m_isCity or self.m_subject~=nil then
        return
    end
    local container = self.m_stageView:getUIContainer()
    if container==nil then
        return
    end

    local bigHpViewData={}

    local left = true
    if self.m_nType==_G.Const.CONST_MONSTER then
        left = false
        -- bigHpViewData.characterId=_G.Cfg.scene_monster[self.m_monsterId].head_icon

    -- elseif self.m_nType==_G.Const.CONST_PARTNER then
        -- bigHpViewData.characterId=_G.Cfg.partner_init[self.m_partnerId].head_icon
        -- self.m_szName=_G.Cfg.partner_init[self.m_partnerId].name
    elseif self.m_nType==_G.Const.CONST_GOODS_MONSTER then
        return
    else
        bigHpViewData.characterId=self.m_property:getPro()
    end
    if _isleft ~= nil then
        left = _isleft
    else
        left = true
    end

    bigHpViewData.szName=self.m_szName or ""
    bigHpViewData.characterType=self.m_nType
    bigHpViewData.lv=self.m_nLv or 0
    bigHpViewData.left=left
    bigHpViewData.isMonsterBoss=self.isMonsterBoss
    bigHpViewData.hp=self.m_nHP or 0
    bigHpViewData.maxHp=self.m_nMaxHP or 0.1
    bigHpViewData.sp=self.m_nSP or 0
    bigHpViewData.maxSp=self.m_nMaxSP or 0.1
    -- local enableSp = true
    self.m_lpBigHp = require("mod.map.UIBigHp")()

    if self:getType()==_G.Const.CONST_MONSTER then
        if bigHpViewData.isMonsterBoss~=true then
            bigHpViewData.isPartner=self.isPartner
            self.m_lpMonsterHpView = self.m_lpBigHp:layer(bigHpViewData)
            self.m_lpMonsterHpView:setPosition(0,self.m_skeletonHeight+5)
            self.m_lpNameContainer:addChild(self.m_lpMonsterHpView)
        else  
            bigHpViewData.hpNum = self.m_hpNum
            bigHpViewData.characterId=self.m_head_icon
            self.m_stageView:showRightHpView(self,bigHpViewData)
        end
        return
    elseif self.m_nType==_G.Const.CONST_PARTNER then
        isSmallView = true
        -- _isleft = _isleft ~= nil and _isleft or true
        -- _isleft = true
        bigHpViewData.characterId = _G.Cfg.partner_init[self.m_partnerId].head_icon
        bigHpViewData.szName = _G.Cfg.partner_init[self.m_partnerId].name
    end

    if isSmallView then

        bigHpViewData.isSmall=true
        self.m_lpBigHpView = self.m_lpBigHp:layer(bigHpViewData)
        self.m_lpBigHpView:setTag(tonumber(self.m_nID))
        _G.g_BattleView:addHpView(self.m_lpBigHp,self.m_lpBigHpView,left)
        return
    end
    if not self.isMainPlay then
        bigHpViewData.left=false
        self.m_stageView:showRightHpView(self,bigHpViewData)
        return
    end

    self.m_lpBigHpView = self.m_lpBigHp:layer(bigHpViewData)
    container:addChild(self.m_lpBigHpView)


    local oldBigHpView = container:getChildByTag(8836)
    if oldBigHpView then
        oldBigHpView:removeFromParent(true)
    end
    self.m_lpBigHpView:setTag(8836)
end

function CBaseCharacter.resetBigHpData( self )
    self.m_lpBigHp=nil
    self.m_lpBigHpView=nil
end

function CBaseCharacter.removeClone( self,clone )
    
    local function actionCallFunc()
        self.m_stageView:removeCharacter(clone)
    end
    clone:setAI(0)
    if clone.m_lpContainer==nil or clone.m_lpMovieClip==nil then actionCallFunc() return end
    local pSprite = cc.Sprite:create()
    local animate = _G.AnimationUtil:getRoleDeadAnimate()
    local func = cc.CallFunc:create(actionCallFunc)
    pSprite:setPosition(0,50)
    pSprite:runAction(cc.Sequence:create(animate,func))
    clone.m_lpContainer:addChild(pSprite)
    clone.m_lpMovieClip:runAction(cc.FadeOut:create(0.1))
end

function CBaseCharacter.showFeatherBuffEffect(self)
    if not self.m_featherId or self.m_featherId==0 then return end
    if self.m_lpMovieClip~=nil and self.m_lpContainer~=nil then
        local tempSpine=_G.SpineManager.createSpine(string.format("spine/tx_%d",self.m_featherId),1.2)

        if not tempSpine then return end

        local zOrder=self.m_featherId==44115 and 10 or -10
        tempSpine:setAnimation(0,"idle",false)
        self.m_lpMovieClip:addChild(tempSpine,zOrder)

        local function tempFun()
            tempSpine:removeFromParent(true)
        end
        local function onCallFunc(event)
            if event.type=="complete" then
                tempSpine:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,0),cc.CallFunc:create(tempFun)))
            end
        end
        tempSpine:registerSpineEventHandler(onCallFunc,2)
    end
end