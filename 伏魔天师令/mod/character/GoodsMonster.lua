CGoodsMonster = classGc(CBaseCharacter,function(self,_nType)
    self.m_nType=_nType
    self.m_stageView=_G.g_Stage
end)

function CGoodsMonster.init(self,_boxId,_boxData,_skinID,_x,_y,_nowHp,_maxHp,_szName)
    self.m_nID = _boxId 
    
    self.m_lpContainer = cc.Layer:create() --总层

    if _boxData~=nil and type(_boxData)=="table" then
        self:setBoxDataBySceneXml(_boxData)
    else
        self:initPos(_x,_y)
        self:setSkinId(_skinID)
    end

    if _nowHp and _maxHp then
        self.m_nMaxHP=_maxHp
        self.m_nHP=_nowHp
    end

    self:resetName(_szName)

    if self.m_stageView:getScenesType()==_G.Const.CONST_MAP_TYPE_COPY_BOX then
        self.m_nScaleXPer=2
        self:setShadow()
    end

    self.m_nScaleX = 1
end

function CGoodsMonster.setHitData(self,_teamId)
    self.teamID=_teamId
    if _teamId then
        self.m_deviation=0
    end
end

function CGoodsMonster.setBoxDataBySceneXml(self,_boxData)
    self:initPos(_boxData[2],_boxData[3])
    self:setMonsterId(_boxData[1])
end

function CGoodsMonster.initPos(self,x,y)
    local lx = self.m_stageView:getMaplx()
    local rx = self.m_stageView:getMaprx()
    x=x<=lx and lx or x
    x=x>=rx and rx or x

    local maxY,minY = self.m_stageView:getMapLimitHeight(x)
    y=y<=minY and minY or y
    y=y>=maxY and maxY or y

    self:setLocationXY(x,y)
end

function CGoodsMonster.setMonsterId(self,_monsterId)
    self.m_goodsMonsterId=_monsterId

    local boxCnfData=_G.Cfg.goods_box[self.m_goodsMonsterId]
    if boxCnfData==nil then return end

    self.m_hurtNum=0
    self.m_timeInterval = boxCnfData.time/1000
    self.m_hurtLastTime=0
    self.m_breakNum = boxCnfData.break_num
    self.m_SkinId = boxCnfData.goods_icon
    self.m_corpse = boxCnfData.corpse
    self:setSkinId(self.m_SkinId)
end
function CGoodsMonster.setSkinId(self,_skinID)
    self.m_SkinId=_skinID
    self.m_skinData=_G.g_SkillDataManager:getSkinData(self.m_SkinId)
    if self.m_skinData == nil then
        self.m_SkinId=61001
        self.m_skinData=_G.g_SkillDataManager:getSkinData(self.m_SkinId)
    end
    self:showBody(self.m_SkinId)
end
function CGoodsMonster.setHurtInterval(self,_interval)
    self.m_timeInterval=_interval
    self.m_hurtLastTime=0
end

CGoodsMonster.onUpdate=nil
CGoodsMonster.onUpdateMove=nil

function CGoodsMonster.setBlock(self,offsetX,offsetY,vWidth,vHeight)
    if self.blockLayer==nil then
        return
    end

    local scaleX = self.m_nScaleX or 1
    if scaleX > 0 then
        offsetX = offsetX
    else
        offsetX = offsetX * scaleX - vWidth
    end

    self.blockLayer:setContentSize(cc.size(vWidth,vHeight))
    self.blockLayer:setPosition(cc.p(offsetX,offsetY))
end

function CGoodsMonster.setBlockByCollider(self,collider)
    if collider==nil then
        collider=_G.g_SkillDataManager:getSkillCollider(1)
    end
    self:setBlock(collider.offsetX,collider.offsetY,collider.vWidth,collider.vHeight)
end

function CGoodsMonster.showBody(self,_skinID)
    local function onCallFunc(event)
        if event.type=="complete" then
            if event.animation=="idle" then
                self.m_bodySpine:setAnimation(0,"idle",true)
            elseif event.animation=="dead" then
                local function nFun()
                    _G.CharacterManager:remove(self)
                    self:releaseResource()
                    if self.deadCallBack~=nil and type(self.deadCallBack)=="function" then
                        self.deadCallBack()
                    end
                end
                self.m_bodySpine:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,0),cc.CallFunc:create(nFun)))
            elseif event.animation=="hurt" then
                self.m_bodySpine:setAnimation(0,"idle",true)
            end
        end
    end

    local bodySpine=_G.SpineManager.createSpine("spine/".._skinID,self.m_skinData.scale/10000)
    bodySpine:setAnimation(0,"idle",true)
    bodySpine:registerSpineEventHandler(onCallFunc,2)
    bodySpine:registerSpineEventHandler(onCallFunc,3)
    self.m_lpContainer:addChild(bodySpine)
    self.m_bodySpine=bodySpine
end

--受伤害
function CGoodsMonster.onHurt(self, hurtSkillId,_Assailant)
    if self.m_timeInterval~=nil then
        local time = _G.TimeUtil:getNowSeconds()
        if self.m_noBeTarget or self.m_lpContainer==nil or time<self.m_hurtLastTime+self.m_timeInterval then return end
        self.m_hurtLastTime=time
    end

    if self.m_nType==_G.Const.CONST_DEFENSE then
        self.m_bodySpine:setAnimation(0,"hurt",false)
    elseif self.m_hurtNum~=nil then
        local status=string.format("idle%d",self.m_hurtNum)
        self.m_bodySpine:setAnimation(0,status,false)

        self.m_hurtNum=self.m_hurtNum+1
        if self.m_nType ~= _G.Const.CONST_DEFENSE then
            if self.m_hurtNum==self.m_breakNum then

                _Assailant.m_nTarget=nil
                -- _G.CharacterManager:remove(self)
                self:releaseResource()
                self.m_noBeTarget=true
            end
        end
    else
        self.m_bodySpine:setAnimation(0,"hurt",false)
    end
end

function CGoodsMonster.getLocationXY( self )
    return self.m_nLocationX, self.m_nLocationY
end

function CGoodsMonster.setLocationXY( self,x,y )
    self.m_nLocationX=x
    self.m_nLocationY=y
    self.m_lpContainer:setPosition(cc.p(x,y))
end

function CGoodsMonster.setZOrder( self, _z )
    self.m_lpContainer:setLocalZOrder( _z )
end

function CGoodsMonster.getWorldCollider( self )
    if self.m_lpCurrentCollider == nil then
        self:setColliderXmlByID(self.m_SkinId)
    end
    local colliderNode = self.m_lpCurrentCollider
    local vWidth = colliderNode.vWidth
    local vX = colliderNode.offsetX + self.m_nLocationX
    local vY = colliderNode.offsetY + self.m_nLocationY
    local vHeight = colliderNode.vHeight
    return vX, vY,vWidth, vHeight
end

function CGoodsMonster.releaseResource( self )
    if self.m_corpse~=nil and self.m_corpse~=0 then
        self.m_corpse=0
        return
    end
    if self.m_lpContainer~=nil then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
        print("self.m_plistName=",self.m_plistName,"pvrFileName=",pvrFileName)
    end
    self:destoryBigHpView()
    self.m_isRelease=true
    -- GCLOG("CGoods.releaseResource====>>>>self.m_nID=%d",self.m_nID)
end

function CGoodsMonster.getContainer( self )
    return self.m_lpContainer
end

function CGoodsMonster.showMonster( self )
    local function onDestoryEffectCallback()
        _G.CharacterManager:remove(self)
        self:releaseResource()
    end
    local animation=genarelAnimation(string.format("anim/%d_idle.plist",self.m_SkinId),self.m_SkinId.."_idle_",0.2,-1)
    local actionsArray = CCArray:create()
    actionsArray:addObject(CCAnimate:create(animation))
    actionsArray:addObject(CCDelayTime:create(0.3))
    actionsArray:addObject(CCFadeOut:create(0.3))
    actionsArray:addObject(CCCallFuncN:create(onDestoryEffectCallback))
    self.pSprite:runAction(CCSequence:create(actionsArray))
end

function CGoodsMonster.addHP(self,_nHP,_crit,_bleed)
    local currentHP=self.m_nHP+_nHP
    self:setHP(currentHP)
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
function CGoodsMonster.setHP(self, _nHP, _noEffect)
    if self.m_nHP==nil then
        _G.CharacterManager:remove(self)
        self:releaseResource()
        return
    end

    if self.m_nHP==_nHP or self.m_nHP <= 0 then
        return
    end
    local deadHP=_nHP
    _nHP=_nHP<=0 and 0 or _nHP
    _nHP=_nHP>=self.m_nMaxHP and self.m_nMaxHP or _nHP

    self.m_nHP = _nHP

    if self.m_lpBigHp~=nil then
       self.m_lpBigHp:setHpValue(self.m_nHP, self.m_nMaxHP, _noEffect)
    end

    --地面死亡
    if self.m_nHP<=0 then
        if self.m_skinData.dead_sound~=nil then
            if not self.isMainPlay then
                _G.Util:playBattleEffect(self.m_skinData.dead_sound)
            end
        end
        self.m_noBeTarget=true

        print("CCCCCCCCCCCCCCCCCCCCCC===>>>1")
        self.m_bodySpine:setToSetupPose()
        self.m_bodySpine:setAnimation(0,"dead",false)
    end
end

function CGoodsMonster.addBigHpView( self, _isleft,isSmallView)
    if self.m_stageView.m_isCity or self.m_subject~=nil then
        return
    end
    local container = self.m_stageView:getUIContainer()
    if container==nil then
        return
    end

    local bigHpViewData={}
    local left = false

    bigHpViewData.szName=self.m_szName
    bigHpViewData.characterType=self.m_nType
    bigHpViewData.lv=self.m_nLv or 1
    bigHpViewData.left=left
    bigHpViewData.isMonsterBoss=true
    bigHpViewData.hp=self.m_nHP or 0
    bigHpViewData.maxHp=self.m_nMaxHP or 0.1
    bigHpViewData.sp=self.m_nSP or 0
    bigHpViewData.maxSp=self.m_nMaxSP or 0.1
    bigHpViewData.characterId=45000

    isSmallView=false
    if isSmallView then
        bigHpViewData.isSmall=true
        self.m_lpBigHp = require("mod.map.UIBigHp")()
        self.m_lpBigHpView = self.m_lpBigHp:layer(bigHpViewData)
        self.m_lpBigHpView:setTag(tonumber(self.m_nID))
        _G.g_BattleView:addHpView(self.m_lpBigHp,self.m_lpBigHpView,left)
        return
    end

    bigHpViewData.left=false
    self.m_stageView:showRightHpView(self,bigHpViewData)
end

function CGoodsMonster.resetName(self,_szName)
    self.m_szName=_szName
    if self.m_lpBigHp then
        self.m_lpBigHp:resetNameLabel(_szName)
    end
end
