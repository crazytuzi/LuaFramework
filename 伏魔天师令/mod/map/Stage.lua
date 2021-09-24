require "mod.map.SkillHurt"
require "mod.map.StageXMLManager"
require "mod.map.CharacterManager"
require "mod.map.StageObjectPool"

require "mod.character.BaseCharacter"
require "mod.character.Goods"
require "mod.character.GoodsMonster"
require "mod.character.Hook"
require "mod.character.Monster"
require "mod.character.Npc"
require "mod.character.Partner"
require "mod.character.Player"
require "mod.character.Transport"
require "mod.character.Vitro"
require "mod.character.Trap"

local __StageXMLManager=_G.StageXMLManager
local __CharacterManager=_G.CharacterManager
local __Const=_G.Const
local __controller=_G.controller
local __Network=_G.Network

local CStage = classGc(view,function(self)
    self.m_bIsInit = false
end)

function CStage.create( self )
    local director = cc.Director:getInstance()
    self.winSize = director:getWinSize()

    local isFirstEnter=true
    local function onNodeEvent(event)
        print("CStage  onNodeEvent===========>>>>",event)
        if "enter"==event then
            self:registerEnterFrameCallBack()
            if isFirstEnter then
                _G.Util:getLogsView():showMarquee()
                isFirstEnter=false
            end

            _G.Util:initLog()
            _G.Util:getLogsView():initMarqueeParent(self.m_lpScene)
        elseif "exit"==event then
            _G.Util:initLog()
            self:removeFrameCallBack()
        end
    end
    
    -- 场景
    self.m_lpScene = cc.Scene:create()
    self.m_lpScene:registerScriptHandler(onNodeEvent)
    -- 层
    self.m_lpContainer              = cc.Layer:create() -- 总层
    self.m_lpStageContainer         = cc.Node:create()
    self.m_lpMapContainer           = cc.Layer:create() --地表层
    self.m_lpMapDisContainer        = cc.Node:create() --远地表
    self.m_lpMapNearContainer       = cc.Node:create() --近景层
    self.m_lpCharacterContainer     = cc.Node:create() --角色层
    self.m_lpUIContainer            = cc.Node:create() --场景UI层
    
    self.m_lpMessageContainer       = cc.Node:create() --信息层  比如:本奖励/死亡/时间到
    self.m_lpSysViewContainer       = cc.Node:create() --系统界面层
    self.m_lpComboContainer         = cc.Node:create() --连击 图片层
    self.m_lpKOFContainer           = cc.Node:create() --模式层
    self.m_lpEffectContainer        = cc.Node:create() --特效层
    
    -- self.m_lpMapContainer:setScale(1.008)
    self.m_lpStageContainer : addChild( self.m_lpMapContainer, 100 )
    self.m_lpStageContainer : addChild( self.m_lpCharacterContainer,200 )
    self.m_lpStageContainer : addChild( self.m_lpMapNearContainer, 300)
    self.m_lpContainer : addChild( self.m_lpStageContainer, 200 )

    self.m_lpScene : addChild(self.m_lpMapDisContainer, 50 )
    self.m_lpScene : addChild(self.m_lpContainer,60 )
    self.m_lpScene : addChild( self.m_lpUIContainer, 100 )
    self.m_lpScene : addChild( self.m_lpComboContainer, 200 )
    self.m_lpScene : addChild( self.m_lpMessageContainer, __Const.CONST_MAP_ZORDER_LAYER - 50 )
    self.m_lpScene : addChild( self.m_lpSysViewContainer, __Const.CONST_MAP_ZORDER_LAYER )
    self.m_lpScene : addChild( self.m_lpKOFContainer, __Const.CONST_MAP_ZORDER_LAYER+100 )
    return self.m_lpScene
end

function CStage.initView(self)
    if self.m_isCity then
        _G.SysInfo:setGameIntervalLow()

        _G.g_BattleView=nil
        _G.pmainView=require("mod.mainUI.MainView")()
        local node=_G.pmainView:create()
        self.m_lpUIContainer:addChild(node)
    else
        _G.SysInfo:setGameIntervalHigh()

        _G.pmainView=nil
        _G.g_BattleView=require("mod.map.UIBattle")()
        self.m_battleViw=_G.g_BattleView
    end

    if _G.g_SmallChatView==nil then
        _G.g_SmallChatView=require("mod.chat.ChatWindow")()
        _G.g_SmallChatView:create():retain()
    end
    local chatNode=_G.g_SmallChatView:getLayer()
    self.m_lpUIContainer:addChild(chatNode,-10)

    if _G.SysInfo:isIpNetwork() then
        local memoryView=require("mod.support.UIMemory")()
        local memoryLayer=memoryView:create()
        self.m_lpScene:addChild(memoryLayer,9999)
        self.m_memoryView=memoryView
    end

    cc.Director:getInstance():getScheduler():setTimeScale(1)
end

function CStage.init( self, _nScenesID,_x, _y, _mbg)
    self:delayFadeInStageScene()

    -- _G.StageObjectPool:init()

    self.isFinishCopy=false
    --取出场景数据
    local scenesXML = __StageXMLManager:getXMLScenes(_nScenesID)
    if scenesXML == nil then
        CCMessageBox("scenesXML is nil", "GET ID ERROR")
        print("codeError!!!! scenesXML is nil")
        return
    end
    self.m_lpScenesXML = scenesXML
    self.m_sceneId=_nScenesID
    self.m_sceneType=scenesXML.scene_type
    if scenesXML.partner~=nil then
        self.m_partner=scenesXML.partner;
    end
    if self.m_sceneType==__Const.CONST_MAP_TYPE_CITY then
        _G.m_IkkiTousenWarData=nil
        self.m_isCity=true
        _G.GPropertyProxy:setChallengePanePlayInfo(nil)
        _G.TimeUtil:initServerAdjust()
        local property=_G.GPropertyProxy:getMainPlay()
        property.soulStatus=nil
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_GEM then
        self.m_sceneType=__Const.CONST_MAP_TYPE_COPY_HERO
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_PK_ROBOT then
        self.m_isCity=false
        self.m_isUserPkRobot=true
        self.m_sceneType=__Const.CONST_MAP_TYPE_CHALLENGEPANEL
    elseif self.m_sceneType == __Const.CONST_MAP_TYPE_TXDY_SUPER then
        self.m_sceneType = __Const.CONST_MAP_TYPE_KOF
        self.m_isCity=false
    elseif self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then
        self.m_isCity=false
        self.m_isCanAttackOrther=true
        local mibaoArrayCnf=_G.Cfg.mibao
        for i=1,#mibaoArrayCnf do
            local sceneArray=mibaoArrayCnf[i].map_ids
            for j=1,#sceneArray do
                if sceneArray[j]==_nScenesID then
                    self.m_isCanAttackOrther=mibaoArrayCnf[i].attack_type==2
                    break
                end
            end
        end
        print("CCCCCCCCCCCCCCCCCCCCCCCCC=======>>>",self.m_isCanAttackOrther)
    else
        self.m_isCity=false
    end
    if self.m_sceneType==__Const.CONST_MAP_TYPE_KOF then
        __Network:setHandleAckCountOneTimes(50)
    else
        __Network:setHandleAckCountOneTimes(10)
    end

    _G.Util.m_battleEffect={}
    -- self.m_sceneDir = 1
    self.m_sceneDir = scenesXML.direction == __Const.CONST_DIRECTION_WEST and -1 or 1
    self.m_nPlayDir = 1
    if scenesXML.born ~= nil then
        if scenesXML.born[1] ~= nil then
            self.m_nPlayDir = scenesXML.born[1][4] == __Const.CONST_DIRECTION_WEST and -1 or 1
            if _x == nil then
                _x = scenesXML.born[1][2]
                _y = scenesXML.born[1][3]
            end
        end
    end
    
    --取出资源数据
    self.m_lpMapData=_G.MapData[scenesXML.material_id]
    
    --{ 副本时间 倒计时 }
    -- self.m_nRemainingTime = nil
    self.m_lastCountTime=0
    self.m_lastRecordTime=_G.TimeUtil:getTotalSeconds()
    self.m_plotUseTime=0
    --{ 地图加载间隔时间 }
    self.m_nLoadMapTime = 0
    self.m_hurtHpNum=0

    self.m_mapSpriteArray={}
    self.m_mapSpineArray={}

    -- 优化参数
    self.m_onUpdateCharcterCount=0
    
    --是否进入下一个checkPoint
    self.isGoingNextChecKPoint=false
    --是否自动战斗模式
    self.isAutoFightMode=false

    self.m_stopMove=false

    local movesArray=self.m_lpMapData.data.move
    if movesArray and movesArray[1] then
        self.m_nMaplx=movesArray[1].x
    else
        self.m_nMaplx=0
    end
    self.m_nMapViewlx = self.m_lpMapData.lx
    self.m_nMapBaseY = 0
    self.m_nMaprx=movesArray[#movesArray].x+movesArray[#movesArray].w
    
    _G.GPropertyProxy:resetMainPlay()
    self:initView()

    self.m_farMapSpeed=self.m_lpMapData.speedMap or 0
    self.m_heightWidth=self.m_lpMapData.heightWidth
    
    -- local farMapPaths = self.m_lpMapData.farMap
    -- if farMapPaths and self.m_farMapSpeed>0 then
    --     self.m_nFarMaprx=self.m_lpMapData.mapWidth
    --     -- _G.g_StageEffect:boatFLoat(self)
        
    --     self.m_farMapSpeed=8
    -- end
    -- --加载地图
    self:loadMap()

    local nextCopyHpData=_G.g_nextCopyData
    if nextCopyHpData~=nil then
        _G.g_nextCopyData=nil
        if nextCopyHpData.attributeAdds~=nil then
            self.m_attributeAdds=nextCopyHpData.attributeAdds
            self.m_battleViw:showAttributeAdd(self.m_lpUIContainer,self.m_attributeAdds)
        end
        if nextCopyHpData.nextCopyHpData~=nil then
            self.m_nextCopyHpData=nextCopyHpData.nextCopyHpData
        end
        -- if nextCopyHpData.isAutoFight~=nil then
        --     self.m_isAutoFightNextScene=true
        -- end
        if nextCopyHpData.playerMP~=nil then
            self.m_playerLastMP=nextCopyHpData.playerMP
        end

        self.m_parHp=nextCopyHpData.parHp
        self.m_condPreTimes=nextCopyHpData.preCondTimes
        self.m_copyPassLimitTimes=nextCopyHpData.copyPassLimitTimes
        self.m_copyPassAllowTimes=nextCopyHpData.copyPassAllowTimes
        self.m_mountSkillCD=nextCopyHpData.mountSkillCd
        self.m_artifactSkillCD=nextCopyHpData.artifactSkillCd
    end
    
    self.m_nMapViewrx=self.m_lpMapData.mapWidth
    self.m_lpMapContainer:setContentSize(cc.size(self.m_nMapViewrx,640))
    self.m_lpContainer:setContentSize(cc.size(self.m_nMapViewrx,640))

    if self.m_lpMapData.mx ~= 0 then
        self.m_nMapmx = self.m_lpMapData.mx
        self.m_jumpX = self.m_lpMapData.jump_x
        self.m_jumpY = self.m_lpMapData.jump_y
    end
    
    self.m_nFarMaplx=0
    self.m_nFarMaprx= self.m_nFarMaprx or 0

    self.m_canControl=true
    
    --一骑当千code 加载表数据属性
    if self.m_sceneType == __Const.CONST_MAP_TYPE_THOUSAND then
        self:IkkiTousen_initMainPlay(_x,_y)
    elseif self.m_sceneType~=__Const.CONST_MAP_TYPE_PK_LY then
        self:initMainPlay(_x, _y)
    end
    self:addControlMode()
    self:moveArea3(0,true)
    -- self:moveArea(self.m_lpPlay:getLocationX(),self.m_lpPlay:getLocationY(),nil,self.m_lpPlay.m_nScaleX,true)
    
    self.hit_times = 0  -- {被击数}
    self.carom_times  = 0  -- {最高连击数}
    self.mons_hp   = 0  -- {对怪物伤害(所有怪物杀出的血)}
    self.m_nCombo = 0 --{当前连击数}
    self.m_nComboTime = nil --{连击时间}
    
    self.m_bIsInit = true
    
    self:initBackgroundMusic(_mbg)
    
    --之后再做的事情
    local function onInitializeStage()
        self:WaitMomentInitializeStage()
    end
    _G.Scheduler:performWithDelay(0.3,onInitializeStage)
    
    if self.m_isCity then
        _G.g_nLastScenesID=_nScenesID
        _G.g_nLastX,_G.g_nLastY = _x,_y

        _G.SkillHurt.m_stageView=nil
    else
        _G.SkillHurt.m_stageView=self
    end
    
    return self.m_lpScene
end

function CStage.initBackgroundMusic(self,_mbg)
    if _mbg==nil then return end

    _G.Util:unloadAllAudioEffect()
    _G.Util:playAudioMusic(_mbg)
    self.m_musicId=_mbg
end
function CStage.getBackgroundMusicId(self)
    return self.m_musicId
end

function CStage.loadMap(self)
    if self.m_isLoadMap then return end
    self.m_isLoadMap=true

    self:loadDataMap()
    if self.m_lpScenesXML.material_id==10531 then
        self:createRollBg()
    elseif self.m_lpScenesXML.material_id==10402 then
        self:createRollStarBg()
    else
        self:loadDataBgMap()
    end
    self:loadMapAdorn()
end
function CStage.unloadMap(self)
    self.m_lpMapContainer:removeAllChildren(true)
    self.m_lpMapDisContainer:removeAllChildren(true)
    self.m_lpMapNearContainer:removeAllChildren(true)

    self.m_mapSpriteArray={}
    self.m_mapSpineArray={}

    self.m_isLoadMap=false
end

function CStage.initMainPlay( self,_x, _y)
    local property=_G.GPropertyProxy:getMainPlay()

    local uid = property:getUid()
    local name = property:getName()
    local pro = property:getPro()
    local hp = property:getAttr():getHp()
    local maxHP = property:getAttr():getMaxHp()
    local sp = property:getAttr():getSp()
    local lv = property:getLv()
    local skinId = property:getSkinArmor()
    local wingSkin = property:getWingSkin()
    local mountId= property:getMountID()
    local mountTX= property:getMountTexiao()
    local meirenSkin = property:getMeirenId()
    local magic_msg= property:getmagicSkinIdmsg() --神器id数据
    
    local mainPlay=CPlayer(__Const.CONST_PLAYER)
    local fashionSkinId = 0
    local magicSkinId   = 0
    _G.SkillHurt.isNeedBroadcastHurt=false
    if self.m_sceneType==__Const.CONST_MAP_TYPE_KOF or self:isMultiStage() then
        
        mainPlay.m_enableBroadcastSkill=true
        mainPlay.m_enableBroadcastAttack=true
        mainPlay.m_enableBroadcastMove=true
        
        _G.SkillHurt.isNeedBroadcastHurt=true
        
        print("设置玩家广播项==============================>>>")
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_ROAD then
        wingSkin=property.m_provisionalStar
        maxHP=property.m_provisionalMaxHP
        print(wingSkin,maxHP,"initMainPlay=======>>>>")
    elseif self.m_isCity then
        mainPlay.m_enableBroadcastMove=true
        property.m_isReborn=nil
    end
    
    mainPlay:setProperty(property)
    mainPlay:playerInit(uid,name,pro,lv,skinId,mountId,wingSkin,fashionSkinId,magicSkinId,mountTX)
    mainPlay:init(uid,name,maxHP,hp,sp,sp,_x,_y,skinId)
    mainPlay:setPetId(meirenSkin)
    mainPlay:setFeatherProperty(property:getSkinFeather(),property:getFeatherLv())
    if property.m_isReborn then
        mainPlay.m_playHp=nil
    end
    
    
    mainPlay:resetNamePos()
    mainPlay.isMainPlay=true
    mainPlay:addBigHpView()
    if property.m_isDead then
        mainPlay:quickDead()
        property.m_isDead=nil
    end
    
    self:addCharacter(mainPlay)
    _G.g_lpMainPlay=mainPlay
    self.m_lpPlay=mainPlay

    -- if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
    --     if self.m_nextCopyHpData~=nil and self.m_nextCopyHpData[1]==0 then
    --         self.m_lpPlay:setHP(0)
    --         self.m_lpPlay.m_lpContainer:setVisible(false)
    --         return
    --     end
    -- end

    if self.m_nPlayDir < 0 then
        mainPlay : setMoveClipContainerScalex(self.m_nPlayDir)
    elseif mainPlay.m_nLocationX > 800 then
        self.m_nPlayDir = -1 
        mainPlay : setMoveClipContainerScalex(self.m_nPlayDir)
    end
end

function CStage.getTouchPlayContainer( self )
    if self.m_lpTouchPlayContainer==nil then
        self.m_lpTouchPlayContainer=cc.Node:create() --查看信息层
        self.m_lpScene:addChild( self.m_lpTouchPlayContainer,__Const.CONST_MAP_ZORDER_LAYER-10 )
    end
    return self.m_lpTouchPlayContainer
end
function CStage.removeTouchPlayContainerChild( self )
    if _G.g_CTouchPlayViewMediator ~= nil and _G.g_isSeeingOtherPlayer == nil  then
        __controller :unregisterMediator(_G.g_CTouchPlayViewMediator)
        _G.g_CTouchPlayViewMediator = nil
    end
    _G.g_isSeeingOtherPlayer = nil 
    print("删除查看其他人框")
    if self.m_lpTouchPlayContainer~=nil then
        self.m_lpTouchPlayContainer:removeAllChildren(true)
    end
end

function CStage.getScene( self )
    return self.m_lpScene
end
--慢动作
function CStage.slowBuff( self, time, scale)
    if self.m_slowBuff==true then return end
    local function actionCallFunc(_layer)
        cc.Director:getInstance():getScheduler():setTimeScale(1)
        self.m_slowBuff=nil
    end
    self.m_slowBuff=true
    cc.Director:getInstance():getScheduler():setTimeScale(scale)
    self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(actionCallFunc)))
end
--黑屏
function CStage.black( self, time, num)
    if self.m_blackSkillBg==true then return end
    self.m_blackSkillBg=true
    local spine=_G.SpineManager.createSpine("spine/7663")
    local function actionCallFunc(_layer)
        spine:setAnimation(0,"idle",false)
    end
    local function c(event)
        if event.animation=="idle2" then return end
        local function f( ... )
            self:showMapDisContainer()
            spine:removeFromParent(true)
            self.m_blackSkillBg=nil
        end
        local time=cc.DelayTime:create(0.1)
        local fun=cc.CallFunc:create(f)
        spine:runAction(cc.Sequence:create(time,fun))
    end
    self:hideMapDisContainer()
    self.m_lpStageContainer:addChild(spine,101)
    spine:setAnimation(0,"idle2",true)
    spine:registerSpineEventHandler(c,2)
    local x,y=self.m_lpContainer:getPosition()
    spine:setPosition(-x-500,-y)
    spine:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(actionCallFunc)))
    self.m_blackSkillBg=spine
end
--黑屏2
function CStage.black2( self, time, num)
    if self.m_blackSkillBg==true then return end
    local function actionCallFunc(_layer)
        _layer:removeFromParent(true)
        self.m_blackSkillBg=nil
        self:showMapDisContainer()
    end
    self.m_blackSkillBg=true
    local layer=cc.LayerColor:create(cc.c4b(0,0,0,num))
    self.m_lpStageContainer:addChild(layer,101)
    local x,y=self.m_lpContainer:getPosition()
    self:hideMapDisContainer()
    layer:setContentSize(cc.size(2000,640))
    layer:setPosition(-x-500,-y)
    layer:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(actionCallFunc)))
    self.m_blackSkillBg=layer
end

--灰
function CStage.gray( self, time, num)
    if self.m_runGray==true then return end
    local function actionCallFunc()
        self.m_runGray=nil
        for i=1,#self.m_mapSpriteArray do
            _G.ShaderUtil:shaderNormalById(self.m_mapSpriteArray[i].node,0)
        end

    end
    self.m_runGray=true

    for i=1,#self.m_mapSpriteArray do
        _G.ShaderUtil:shaderNormalById(self.m_mapSpriteArray[i].node,12)
    end
    self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(actionCallFunc)))
end
--闪屏
function CStage.splash( self, time, count)
    if self.m_runSplash==true then return end
    local function actionCallFunc(_layer)
        _layer:setVisible(false)
        self.m_runSplash=nil
    end
    self.m_runSplash=true

    if self.m_blinkLayer==nil then
        self.m_blinkLayer=cc.LayerColor:create(cc.c4b(255,255,255,180))
        self.m_lpKOFContainer:addChild(self.m_blinkLayer)
    else
        self.m_blinkLayer:setVisible(true)
    end
    local blink=cc.Blink:create(time,count)
    self.m_blinkLayer:runAction(cc.Sequence:create(blink,cc.CallFunc:create(actionCallFunc)))
end

--振屏
function CStage.vibrate( self,count,posY, time )
    if self.runVibrate==true or self.m_isCity then return end
    local function actionCallFunc()
        self.m_lpContainer:runAction(cc.ScaleTo:create(0.1,1))
        self.m_lpContainer:setPositionY(self.m_nMapBaseY)
        self.runVibrate=nil
    end
    self.runVibrate=true

    self:resetContainerAR()
    local nPoint1={x=0,y=-posY}
    local nPoint2={x=0,y=posY}
    local movBy1=cc.MoveBy:create(time,nPoint1)
    local movBy2=cc.MoveBy:create(time,nPoint2)
    local cFun=cc.CallFunc:create(actionCallFunc)
    local scale = cc.ScaleTo:create(time,1.02)
    self.m_lpContainer:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(movBy1,movBy2),count),cFun))
    self.m_lpContainer:runAction(scale)
end
function CStage.vibrate1399(self)
    if self.runVibrate==true or self.m_isCity then return end
    local function actionCallFunc()
        self.m_lpContainer:runAction(cc.ScaleTo:create(0.1,1))
        self.m_lpContainer:setPositionY(self.m_nMapBaseY)
        self.runVibrate=nil
    end
    self.runVibrate=true

    self:resetContainerAR()
    local nPoint1={x=0,y=-10}
    local nPoint2={x=0,y=10}
    local movBy1=cc.MoveBy:create(0.05,nPoint1)
    local movBy2=cc.MoveBy:create(0.05,nPoint2)
    local movBy3=cc.MoveBy:create(0.05,nPoint1)
    local movBy4=cc.MoveBy:create(0.05,nPoint2)
    local movBy5=cc.MoveBy:create(0.05,nPoint1)
    local movBy6=cc.MoveBy:create(0.05,nPoint2)
    local movBy7=cc.MoveBy:create(0.05,nPoint1)
    local movBy8=cc.MoveBy:create(0.05,nPoint2)
    local movBy9=cc.MoveBy:create(0.05,nPoint1)
    local movBy10=cc.MoveBy:create(0.05,nPoint2)
    local cFun=cc.CallFunc:create(actionCallFunc)
    local scale = cc.ScaleTo:create(0.05,1.03)
    self.m_lpContainer:runAction(cc.Speed:create(cc.Sequence:create(movBy1,movBy2,movBy3,movBy4,movBy5,movBy6,movBy7,movBy8,movBy9,movBy10,cFun),15))
    self.m_lpContainer:runAction(scale)
end
function CStage.resetMapContainerAR(self)
    local focusPlay
    if self.m_lpPlay~=nil and self.m_lpPlay.m_lpContainer~=nil then
        focusPlay=self.m_lpPlay
    elseif self.m_survival~=nil then
        focusPlay=self.m_survival
    else
        return
    end
    local nPosX,nPosY=focusPlay:getLocationXY()
    local nArPoint={x=nPosX/self.m_nMapViewrx,y=nPosY/self.m_heightWidth}
    self.m_lpMapContainer:setAnchorPoint(nArPoint)
end
function CStage.resetContainerAR(self)
    local focusPlay
    if self.m_lpPlay~=nil and self.m_lpPlay.m_lpContainer~=nil then
        focusPlay=self.m_lpPlay
    elseif self.m_survival~=nil then
        focusPlay=self.m_survival
    else
        return
    end
    local nPosX,nPosY=focusPlay:getLocationXY()
    local nArPoint={x=nPosX/self.m_nMapViewrx,y=nPosY/self.m_heightWidth}
    self.m_lpContainer:setAnchorPoint(nArPoint)
end

function CStage.setStopAI( self, _bool )
    if _G.controller.m_aiState~=nil then return end
    self.m_stopAI = _bool
end

--æææææææææææææææææææææææææææææææææææææææ
--添加剧情接口         START
--æææææææææææææææææææææææææææææææææææææææ
function CStage.checkMapPlot(self,_touchType)
    print("checkMapPlot=======>>>>",self.m_sceneType,_touchType)
    if self.m_sceneType~=__Const.CONST_MAP_TYPE_COPY_NORMAL
        and self.m_sceneType~=__Const.CONST_MAP_TYPE_COPY_HERO
        and self.m_sceneType~=__Const.CONST_MAP_TYPE_COPY_FIEND then

        return false
    end

    local touchId=nil
    if _touchType==__Const.CONST_DRAMA_GETINTO then
        print("[触发剧情数据-进入副本]")
        touchId=self:getScenesCopyID()
    elseif _touchType==__Const.CONST_DRAMA_FINISHE then
        print("[触发剧情数据-通关副本]")
        touchId=self:getScenesCopyID()
    elseif _touchType==__Const.CONST_DRAMA_ENCOUNTER then
        print("[触发剧情数据-遇到boss]")
        touchId=self:getMonsterBossId()
    end

    self.m_plotManager=self.m_plotManager or require("mod.map.PlotManager")()
    local plotData=self.m_plotManager:checkPlot(_touchType,touchId)
    return plotData
end
function CStage.isPlotPlaying(self)
    if self.m_plotManager then
        return self.m_plotManager:isPlayingPlot()
    end
    return false
end
function CStage.runMapPlot(self,_plotData,_finishFun,_delayTimes)
    self.m_plotManager:runThisPlot(_plotData,_finishFun,_delayTimes)
end
function CStage.getMonsterBossId(self)
    local bossId=nil
    local maxRank=0
    local monstersArray=__StageXMLManager:getXMLScenesMonsterList(self:getScenesID(),self:getCheckPointID())
    for i=1,#monstersArray do
        local monsterId=monstersArray[i][1]
        local monsterCnf=_G.Cfg.scene_monster[monsterId]
        if monsterCnf~=nil then
            if monsterCnf.steps>=__Const.CONST_MONSTER_RANK_ELITE and maxRank<monsterCnf.steps then
                maxRank = monsterCnf.steps
                bossId  = monsterId
            end
        end
    end
    return bossId
end

--启动剧情 隐藏该隐藏的东西  _visible{false:隐藏,true:显示}
function CStage.setSomeViewVisible( self, _visible )
    print("CStage.setSomeViewVisible _visible=",_visible)
    
    self.m_lpUIContainer:setVisible( _visible )
    self.m_lpMessageContainer:setVisible( _visible )
    self.m_lpComboContainer:setVisible( _visible )
    
    if self.m_joyStick~=nil then
        self.m_joyStick:setVisible( _visible )
    end
    
    if self.m_keyBoard~=nil then
        self.m_keyBoard:setVisible( _visible )
        self.m_keyBoard:cancelAttack()
    end
    
    self:setCanControl(_visible)
end

function CStage.setPause( self )
    for k,v in pairs(__CharacterManager[__Const.CONST_MONSTER]) do
        local function c()
            v.m_lpMovieClip:pause()
        end
        if v.m_nStatus~=__Const.CONST_BATTLE_STATUS_CRASH then
            v:setStatus(__Const.CONST_BATTLE_STATUS_HURT)
            v.m_lpMovieClip:setAnimation(7,"hurt",false)
            v.m_lpMovieClip:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(c)))
            v.m_thinkFunc=v.think
            v.think=function () end
            -- v.m_onUpdateFunc=v.onUpdate
            -- v.onUpdate=function () end
        -- else
        --     c()
        --     v.m_eeeee=v.m_fYSpeed
        --     v.m_fYSpeed=nil
        end
    end
    for k,v in pairs(__CharacterManager[__Const.CONST_PLAYER]) do
        v.m_lpMovieClip:pause()
    end
    for k,v in pairs(__CharacterManager[__Const.CONST_PARTNER]) do
        v.m_lpMovieClip:pause()
    end
end

function CStage.setResume( self )
    for k,v in pairs(__CharacterManager[__Const.CONST_MONSTER]) do
        v.m_lpMovieClip:resume()
        if v.m_nStatus~=__Const.CONST_BATTLE_STATUS_CRASH then
            v:setStatus(__Const.CONST_BATTLE_STATUS_IDLE)
            v.think=v.m_thinkFunc
            -- v.onUpdate=v.m_onUpdateFunc
        -- else
        --     v.m_fYSpeed=v.m_eeeee
        end
    end
    for k,v in pairs(__CharacterManager[__Const.CONST_PLAYER]) do
        v.m_lpMovieClip:resume()
    end
    for k,v in pairs(__CharacterManager[__Const.CONST_PARTNER]) do
        v.m_lpMovieClip:resume()
    end
end

function CStage.setCharacterVisible( self,_visible,_AI )
    print("CStage.setCharacterVisible==========>>",_visible,_AI)
    local nAi=(not _visible) and 0 or _AI
    if _visible==true then
        for i,v in pairs(__CharacterManager[__Const.CONST_MONSTER]) do
            if v :getContainer() then
                v :getContainer() :setVisible( _visible )
                v :cancelMove()
                v :setAI(nAi)
            end
        end
        
        for i,v in pairs(__CharacterManager[__Const.CONST_PARTNER]) do
            if v :getContainer() then
                v :getContainer() :setVisible( _visible )
                v :cancelMove()
                v :setAI(nAi)
            end
        end
        
        self :getMainPlayer() :showStar()
        self :getMainPlayer() :getContainer() :setVisible( _visible )
        self :getMainPlayer() :cancelMove()
    else
        for i,v in pairs(__CharacterManager[__Const.CONST_MONSTER]) do
            if v :getContainer() then
                v :getContainer() :setVisible( _visible )
                v :cancelMove()
                v :setAI(nAi)
            end
        end
        
        for i,v in pairs(__CharacterManager[__Const.CONST_PARTNER]) do
            if v :getContainer() then
                v :getContainer() :setVisible( _visible )
                v :cancelMove()
                v :setAI(nAi)
            end
        end
        
        self :getMainPlayer() :hideStar()
        self :getMainPlayer() :getContainer() :setVisible( _visible )
        self :getMainPlayer() :cancelMove()
    end
end

--添加剧情怪物 _id:tag值    _pos:出现的位置
function CStage.addPlotMonster( self, _id, _name, _pos, _dir )
    local monster=__StageXMLManager:addPlotMonsterByID( _id, _name, _pos )
    if monster~=nil then
        if _dir~=9 and _dir~=__Const.CONST_DRAMA_DIR_EAST then
            monster:setMoveClipContainerScalex(-1)
        end
        -- monster:setStage( self )
        self.m_lpCharacterContainer:addChild( monster:getContainer(),-_pos.y,_id )
        -- monster:getContainer():setPosition(_pos.x,_pos.y)
        monster:setAI(0)
        __CharacterManager:add(monster)
    end
    return monster
end

--根据tag值 移除剧情怪物
function CStage.removePlotMonster( self, _monster )
    if _monster~=nil then
        __CharacterManager:remove(_monster)
        _monster:releaseResource()
    end
end
--æææææææææææææææææææææææææææææææææææææææ
--添加剧情接口         END
--æææææææææææææææææææææææææææææææææææææææ

--_isENDUCE 是否霸体 --_isCHALLENGEPANEL是否竞技场
function CStage.addPartnerByProperty( self,character,_roleProperty,isChallengePanel,isRightSide)
    -- print("CStage.addPartnerByProperty",debug.traceback())
    local currentHp = 0
    if self.m_nextCopyHpData~=nil then
        self.m_lpPlay:setHP(self.m_nextCopyHpData[1])
    end

    do return 0 end

    local warPartner=_roleProperty:getWarPartner()
    if warPartner==nil then
        print("无伙伴")
        return 0
    end

    if warPartner:getStata() == __Const.CONST_INN_STATA2 and warPartner:getAttr():getHp() > 0 then
        local characterPartner=CPartner(__Const.CONST_PARTNER)
        characterPartner.m_boss=character
        characterPartner:partnerInit(warPartner)
        
        characterPartner:setAI(warPartner:getAI())
        
        if self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_MULTIPLAYER or 
            self.m_sceneType==__Const.CONST_MAP_TYPE_KOF then
            
            characterPartner.m_enableBroadcastSkill=true
            characterPartner.m_enableBroadcastAttack=true
            characterPartner.m_enableBroadcastMove=true
        end
        
        if currentHp>0 then
            print("partnerID=%d 伙伴当前的血量:%d",partnerID,currentHp)
            characterPartner:setHP(currentHp)
        end
        if isRightSide==true then
            local bossX,bossY=character:getLocationXY()
            bossY = bossY + 10
            characterPartner:setLocationXY(bossX+100,bossY)
            characterPartner:setMoveClipContainerScalex(-1)
        else
            local bossX,bossY=character:getLocationXY()
            bossY = bossY + 10
            characterPartner:setLocationXY(bossX-100,bossY)
        end
        
        self:addCharacter(characterPartner)
        local left = true
        if not character.isMainPlay then
            left = false
        end
        characterPartner:addBigHpView(left)
    end
    self.m_nextCopyHpData=nil

    return 1
end

--之后做的事情
function CStage.WaitMomentInitializeStage( self )

    -- 场景调用结算
    -- local _ackMsg = {res=1}
    -- local view=require("mod.map.UIBattleResult")(_ackMsg)
    -- self:addMessageView(view:create())

    -- _G.ScenesManger.releaseLoadingResources()

    GCLOG("CStage.WaitMomentInitializeStage=====>>")
    local msg=REQ_SCENE_LOAD_READY()
    __Network:send(msg)
    
    cc.Director:getInstance():getEventDispatcher():setEnabled(true)
    
    local scene_type=self.m_sceneType
    --主城
    if self.m_isCity then
        --登陆获取是否打开挂机界面
        if not _G.GSystemProxy:isHideOrtherOpen() then
            --请求场景内人物数据
            local msg=REQ_SCENE_REQ_PLAYERS_NEW()
            __Network:send(msg)
        end
        
        -- if _G.g_firstLogin then
        --     print("发送弹窗请求协议 -----> 40060")
        --     local msg = REQ_SIGN_IS_POP()
        --     __Network :send(msg)
        --     _G.g_firstLogin = false
        -- end
        
        --切换场景后是否继续寻路到npc
        self:autoSearchRoad()
        
        --竞技场
    elseif scene_type == __Const.CONST_MAP_TYPE_CHALLENGEPANEL  then
        local pkPlayInfo = _G.GPropertyProxy:getChallengePanePlayInfo()
        local rivalPlayer=nil
        if pkPlayInfo~=nil then
            local attr=pkPlayInfo:getAttr()
            rivalPlayer = CPlayer(__Const.CONST_PLAYER)
            rivalPlayer : setProperty(pkPlayInfo)
            rivalPlayer : playerInit( pkPlayInfo : getUid(), pkPlayInfo:getName(), pkPlayInfo:getPro(), pkPlayInfo:getLv(), pkPlayInfo :getSkinArmor(),nil, pkPlayInfo:getWingSkin() )
            local x,y = __Const.CONST_ARENA_RIGHT_X, __Const.CONST_ARENA_SENCE_RIGHT_Y
            if self.m_lpScenesXML.born~=nil and self.m_lpScenesXML.born[2]~=nil then
                x = self.m_lpScenesXML.born[2][2]
                y = self.m_lpScenesXML.born[2][3]
            end
            rivalPlayer : init( pkPlayInfo:getUid() , pkPlayInfo:getName(), attr.hp, attr.hp, attr.sp, attr.sp, x,y, pkPlayInfo :getSkinArmor() )
            rivalPlayer : resetNamePos()
            rivalPlayer : addBigHpView(false)
            rivalPlayer : setMoveClipContainerScalex(-1)
            
            self : addCharacter( rivalPlayer )
            
            self : addPartnerByProperty(rivalPlayer,pkPlayInfo,true,true)
            rivalPlayer : setAI(pkPlayInfo:getAI())
            
            local invBuff= _G.GBuffManager:getBuffNewObject(__Const.CONST_ARENA_BATI_BUFF, 0)
            rivalPlayer:addBuff(invBuff)
            rivalPlayer.isMonsterBoss=true
        end
        
        local mainPlayer = self.m_lpPlay
        local invBuff= _G.GBuffManager:getBuffNewObject(__Const.CONST_ARENA_BATI_BUFF, 0)
        mainPlayer:addBuff(invBuff)

        if self.m_sceneId == __Const.CONST_MOUNTAIN_KING_MAP then
            if rivalPlayer then
                -- 第一门派不能复活主角
                rivalPlayer.m_playHp=nil
            end

            local msg = REQ_HILL_ASK_ADD()
            msg:setArgs(pkPlayInfo : getUid())
            __Network : send(msg)
        end
        
        if not self.m_isUserPkRobot then
            mainPlayer:setAI(mainPlayer:getProperty():getAI())
        else
            cc.Director:getInstance():getEventDispatcher():setEnabled(false)
        end
        
        local mainPlayProperty = _G.GPropertyProxy:getMainPlay()
        self : addPartnerByProperty(mainPlayer, mainPlayProperty,true,false)
        
        --BOSS
    elseif scene_type == __Const.CONST_MAP_TYPE_BOSS or 
        scene_type == __Const.CONST_MAP_TYPE_CLAN_BOSS then
        --请求场景怪物数据
        local msg=REQ_SCENE_REQUEST_MONSTER()
        __Network:send(msg)
        
        --请求场景内人物数据
        local msg=REQ_SCENE_REQ_PLAYERS_NEW()
        __Network:send(msg)
        
        --请求倒计时
        local msg=REQ_WORLD_BOSS_CITY_BOOSS()
        __Network:send(msg)
        
        local tempMediator=require("mod.worldboss.WorldBossMediator")()
    elseif scene_type == __Const.CONST_MAP_TYPE_KOF then
        print("天下第一...")
        cc.Director:getInstance():getEventDispatcher():setEnabled(false)
        
        self.hasSLowMotion=true
        --请求场景内人物数据
        local msg=REQ_SCENE_REQ_PLAYERS_NEW()
        __Network:send(msg)
        
        local property=_G.GPropertyProxy:getMainPlay()
        -- print(self.m_lpPlay.m_nLocationX,"@@@@@@!!!!")
        local isRightSide = self.m_nPlayDir < 0 and true or false
        self:addPartnerByProperty(self.m_lpPlay,property, true,isRightSide)
        
        --多人副本
    elseif scene_type == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        print("多人副本，请求玩家列表")
        local msg = REQ_SCENE_REQ_PLAYERS_NEW()
        __Network : send(msg)

        --请求怪物列表
        local msg = REQ_COPY_REQUEST_MONSTER()
        __Network:send(msg)
        
        --更新玩家血量
        local msg = REQ_WAR_HP_REQUEST()
        __Network:send(msg)
        
        --门派塔防
    elseif scene_type == __Const.CONST_MAP_CLAN_DEFENSE then
        --请求怪物列表
        local msg = REQ_COPY_REQUEST_MONSTER()
        __Network:send(msg)
        
        --请求场景内人物数据
        local msg = REQ_SCENE_REQ_PLAYERS_NEW()
        __Network : send(msg)
        
        --请求参加守卫战
        -- local msg = REQ_DEFENSE_REQUEST(  )
        -- __Network : send(msg)
        -- require "mediator/FactionMediator"
        -- _G.g_FactionTDMediator = CFactionTDMediator( self )
        -- __controller :registerMediator( _G.g_FactionTDMediator )
        
        -- 请求地图数据
        local msg = REQ_DEFENSE_MAP_DATA()
        __Network : send( msg )
        
        self.m_battleViw : clanDefenseTitle( self.m_lpUIContainer )
        
    elseif scene_type == __Const.CONST_MAP_CLAN_WAR then
        --请求场景内人物数据
        local msg = REQ_SCENE_REQ_PLAYERS_NEW()
        __Network : send(msg)
        
        -- [40520]门派战个人信息 -- 门派战 
        local msg = REQ_GANG_WARFARE_ONCE_REQ()
        __Network : send(msg)
        
    elseif scene_type == __Const.CONST_MAP_TYPE_CITY_BOSS then
        --请求怪物列表
        local msg = REQ_COPY_REQUEST_MONSTER()
        __Network:send(msg)
        
        --请求场景内人物数据
        local msg = REQ_SCENE_REQ_PLAYERS_NEW()
        __Network : send(msg)
        
        local msg = REQ_WORLD_BOSS_CITY_BOOSS()
        __Network : send(msg)
        -- --其他副本
    elseif scene_type == __Const.CONST_MAP_TYPE_THOUSAND then
        self.m_battleViw:addCopyTotal(self.m_lpUIContainer)
        self:IkkiTousen_timeScheduler()
        
        if self.m_nextCopyHpData ~= nil then
            self.m_lpPlay:setHP(self.m_nextCopyHpData[1],true)
            self:addMonsHp(self.m_nextCopyHpData[2])
        end
    elseif scene_type == __Const.CONST_MAP_TYPE_COPY_ROAD then
        local curTimes=_G.TimeUtil:getTotalSeconds()
        if self.m_copyPassLimitTimes==nil then
            local copyId=self:getScenesCopyID()
            local copyCnf=_G.Cfg.scene_copy[copyId]
            local allowTimes=copyCnf.time
            self.m_copyPassLimitTimes=allowTimes+curTimes
            self.m_copyPassAllowTimes=allowTimes
        end
        self.m_battleViw:addRoadCopyTotal(self.m_lpUIContainer,self.m_copyPassLimitTimes*1000)
    elseif scene_type == __Const.CONST_MAP_TYPE_COPY_BOX then
        --请求场景内人物数据
        local msg = REQ_SCENE_REQ_PLAYERS_NEW()
        __Network : send(msg)

        -- 箱子请求
        local msg = REQ_MIBAO_BOX_REQUEST()
        __Network : send(msg)

        local msg=REQ_SCENE_REQUEST_MONSTER()
        __Network:send(msg)
    elseif self.m_plotFirstGame~=nil then
        print("进入新手指引副本") 
    else
        print("进入其他副本")
    end

    if self.m_lpPlay then
        if self.m_playerLastMP~=nil then
            self.m_lpPlay:setMP(self.m_playerLastMP)
            self.m_playerLastMP=nil
        else
            self.m_lpPlay:setMP(__Const.CONST_BATTLE_START_MP)
        end
        if self.m_parHp==false then
            self.m_lpPlay.m_parHp=nil
        end
    end

    self.m_finallyInitialize=true
    print("STAGE 最后的通牒")
end

function CStage.releaseCharacterResource(self)
    gcprint("2CStage.releaseCharacterResource============>>")
    for _,character in pairs(__CharacterManager.m_lpCharacterArray) do
        if character.releaseSkillResource then
            character:releaseSkillResource()
        end
    end
    for k,v in pairs(__CharacterManager.m_lpVitroArray) do
        self:removeVitro(v)
    end
    __CharacterManager:init()
    _G.StageObjectPool:releaseAllObject()
    gcprint("1CStage.releaseCharacterResource============>>")
end

--{自动寻路查找npc}
function CStage.autoSearchRoad( self )
    if _G.GLayerManager:hasSysOpen() then return end

    local nTaskProxy=_G.GTaskProxy
    if nTaskProxy==nil then return end
    local autoFindWayData = nTaskProxy:getAutoFindWayData()
    if autoFindWayData == nil then
        local copyTask = nTaskProxy:getCopyTask()
        if copyTask == nil then return end
        local taskList = nTaskProxy:getTaskDataList() or {}
        for i=1,#taskList do
            local task=taskList[i]
            if (task.id == copyTask.id) and (task.state ~= copyTask.state) then
                --完成副本自动寻路交任务
                nTaskProxy:setMainTask(task)
                local command = CTaskDialogUpdateCommand( CTaskDialogUpdateCommand.GOTO_TASK )
                __controller :sendCommand( command )
                break
            end
        end
        nTaskProxy:setCopyTask()
        return
    end
    nTaskProxy:autoWayFinding( autoFindWayData.npcId, autoFindWayData.sceneId )
end

function CStage.cleanupCombo( self )
    if self.m_lpComboContainer~=nil then
        self.m_lpComboContainer:removeAllChildren( true )
    end
end

function CStage.addCombo( self )
    self.m_nCombo = self.m_nCombo + 1
    if self.m_nCombo > self.carom_times then
        self.carom_times = self.m_nCombo
    end
    self.m_nComboTime = _G.TimeUtil:getTotalMilliseconds() --毫秒数
    self : cleanupCombo()
    if self.m_lpComboContainer==nil then
        self.m_lpComboContainer = cc.Node :create() --连击 图片层
        self.m_lpScene : addChild( self.m_lpComboContainer, 600 )
    end
    self.m_battleViw : showCombo( self.m_nCombo, self.m_lpComboContainer)
end

function CStage.autoHideCombo( self, _nowTime )
    if _nowTime - self.m_nComboTime < __Const.CONST_BATTLE_COMBO_TIME*1000 then
        return
    end
    self : cleanupCombo()
    self.m_nComboTime = nil
    self.m_nCombo = 0
end

--{是否已经初始化}
function CStage.isInit( self )
    return self.m_bIsInit
end

--添加 信息层
function CStage.addMessageView( self, _container )
    self:removeMessageView()
    self.m_lpMessageContainer:addChild( _container )
end
function CStage.removeMessageView( self )
    self.m_lpMessageContainer:removeAllChildren(true)
end

function CStage.addControlMode( self )
    GCLOG("CStage.addControlMode scenesID=%d,sceneType=%d",self:getScenesID(),self.m_sceneType)
    self:setStopAI(false)
    
    CCLOG("CStage.addControlMode  self.m_nMaplx =%d,self.m_nMapViewrx =%d,self.m_nFarMaplx=%d,self.m_nFarMaprx=%d,self.m_farMapSpeed=%d",self.m_nMaplx, self.m_nMapViewrx, self.m_nFarMaplx,self.m_nFarMaprx,self.m_farMapSpeed)
    
    -- if self.m_lpScenesXML.rain_style==0 then
        
    -- elseif self.m_lpScenesXML.rain_style==1 then
    --     print("下雨zZzz......")
        -- _G.g_StageEffect:raining(self)
        
    -- elseif self.m_lpScenesXML.rain_style==2 then
    --     print("下桃花zZzz......")
        -- _G.g_StageEffect:flower(self)
    -- elseif self.m_lpScenesXML.rain_style==3 then
    --     print("水车zZzz......")
        -- _G.g_StageEffect:waterwheel(self)
        
    -- end
    
    self.pieceSubX = 120
    self.winSizeLPiece = self.winSize.width*0.5 - self.pieceSubX
    self.winSizeRPiece = self.winSize.width*0.5 + self.pieceSubX
    
    local scenesID = self:getScenesID()
    print(">>>>>CStage.addControlMode self:getScenesType =  ", self.m_sceneType )
    --主城
    if self.m_isCity then
        local __rectContainsPoint=cc.rectContainsPoint
        local function onTouchBegan(touch, event)
            if self.m_cancelTouch then return true end
            local location=touch:getLocation()
            local nodePosition=self.m_lpContainer:convertToNodeSpace(location)

            for _,npc in pairs(__CharacterManager.m_lpNpcArray) do
                local tempX=npc.m_nLocationX
                local tempY=npc.m_nLocationY
                local tempRect={x=tempX-50,y=tempY,width=100,height=190}
                if __rectContainsPoint(tempRect,nodePosition) then
                    npc:touchSelf(self.m_lpPlay)
                    return
                end
            end
            if not _G.GSystemProxy:isRoleInfoOpen() then
                for _,player in pairs(__CharacterManager.m_lpPlayerArray) do
                    if not player.isMainPlay then
                        local tempX=player.m_nLocationX
                        local tempY=player.m_nLocationY
                        local tempRect={x=tempX-player.m_touchSize.width*0.5,y=tempY,width=player.m_touchSize.width,height=player.m_touchSize.height}
                        if __rectContainsPoint(tempRect,nodePosition) then
                            local infoView=require("mod.map.UIPlayerInfo")(player)
                            local nLayer=infoView:create()
                            self:getTouchPlayContainer():addChild(nLayer)
                            return
                        end
                    end
                end
            end
            if nodePosition.y<=self:getMapLimitHeight(nodePosition.x) then
                self.m_lpPlay:setMovePos(nodePosition)
                _G.GTaskProxy:setAutoFindWayData()
            end
            return true
        end

        local listener=cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher=self.m_lpContainer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self.m_lpContainer)
        
        __StageXMLManager:addNPC( scenesID )
        __StageXMLManager:addTransport( scenesID )

        self:addJoyStick()
        
        self:setStopAI(true)
        return
        --竞技场
    elseif self.m_sceneType== __Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        print("竞技场 __Const.CONST_MAP_TYPE_CHALLENGEPANEL ")
        self.m_battleViw : addExitCopyButton( self.m_lpUIContainer )
        if self.m_isUserPkRobot then
            self:setStopAI(true)
            self.m_battleViw :addhostingBtn( self.m_lpUIContainer)
            self:startAutoFight()
            
            local delayTimes=4
            self.endTime2=_G.TimeUtil:getServerTimeSeconds()+delayTimes
            self:setRemainingTime( delayTimes,"距离开始时间:")
            
            self:addJoyStick()
            self:addKeyBoard()
        else
            self:setRemainingTime( __Const.CONST_ARENA_BATTLE_TIME,"PK倒计时")
        end
        -- 世界BOSS
    elseif self.m_sceneType== __Const.CONST_MAP_TYPE_BOSS or 
        self.m_sceneType == __Const.CONST_MAP_TYPE_CLAN_BOSS then
        
        self.m_bBossVipRmb = false --是否开启鼓舞
        self.m_lpBossCharacter = nil --世界BOSS
        self.m_nBossDeadTime = 0--re复活时间
        
        --默认关卡 为第一关
        self.m_nCheckPointID = 1
        
        self.m_enableBigSkill=false
        
        --注册手柄事件
        self : addJoyStick()
        self : addKeyBoard()
        
        --注册AI回调
        self.m_battleViw : addExitCopyButton( self.m_lpUIContainer )
        local property=_G.GPropertyProxy:getMainPlay()
        self.m_battleViw : addhostingBtn( self.m_lpUIContainer,property.autoStatus)
        self.m_battleViw : addShieldButton( self.m_lpUIContainer, self.m_sceneType )

        if self.m_sceneType == __Const.CONST_MAP_TYPE_BOSS then
            self.m_battleViw:addEmbraveButton(self.m_lpUIContainer )
            
        end
        
        self.m_battleViw:showDps()
        --格斗之王
    elseif self.m_sceneType == __Const.CONST_MAP_TYPE_KOF then
        --注册手柄事件
        self.m_enableBigSkill=false
        self : addJoyStick()
        self : addKeyBoard()
        --默认关卡 为第一关
        self.m_nCheckPointID = 1
        
        --注册AI回调
        self:setStopAI(true)
        self.m_stopMove=true
        self.m_lpPlay.m_isShowState=true
        --退出副本
        self.m_battleViw : addExitCopyButton( self.m_lpUIContainer )
        self.m_battleViw : addhostingBtn( self.m_lpUIContainer )
        
    elseif self.m_sceneType == __Const.CONST_MAP_CLAN_DEFENSE then
        --注册手柄事件
        self.m_enableBigSkill=false
        
        self : addJoyStick()
        self : addKeyBoard()
        --默认关卡 为第一关
        self.m_nCheckPointID = 1
        print("塔防守卫战，需要广播位置")
        -- 刷新箱子
        __StageXMLManager:addGoodsMonster(scenesID, __Const.CONST_DEFENSE )
        --注册AI回调
        --退出副本
        self.m_battleViw : addExitCopyButton( self.m_lpUIContainer )
        local property=_G.GPropertyProxy:getMainPlay()
        self.m_battleViw : addhostingBtn( self.m_lpUIContainer, property.autoStatus)
        self.m_battleViw:showStageName(self.m_lpUIContainer,self.m_lpScenesXML.scene_name)
        
        --门派战
    elseif self.m_sceneType == __Const.CONST_MAP_CLAN_WAR then
        self.m_enableBigSkill=false
        --注册手柄事件
        self : addJoyStick()
        self : addKeyBoard()
        --退出副本
        self.m_battleViw:addExitCopyButton( self.m_lpUIContainer )
        local property=_G.GPropertyProxy:getMainPlay()
        if property.soulStatus==true then
            self.m_lpPlay:showSoul()
        end
        -- local titleSpr=CCSprite:createWithSpriteFrameName("battle_word_bpzbs.png")
        -- titleSpr:setPosition(self.winSize.width*0.5,612)
        -- self.m_lpUIContainer:addChild(titleSpr)
        self.m_lpPlay:setMaxHp(self.m_lpPlay:getHP()*_G.Const.CONST_GANG_WARFARE_HP_ADD)
        self.m_battleViw:showStageName(self.m_lpUIContainer,self.m_lpScenesXML.scene_name)
        -- 世界BOSS2
    elseif self.m_sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS then
        self.m_enableBigSkill=false
        self:addJoyStick()
        self:addKeyBoard()
        self.m_battleViw:addExitCopyButton(self.m_lpUIContainer)
        local property=_G.GPropertyProxy:getMainPlay()
        self.m_battleViw:addhostingBtn(self.m_lpUIContainer,property.autoStatus)
        self.m_battleViw:addModelButton(self.m_lpUIContainer)

        local rolePlayerProperty = self.m_lpPlay.m_property
        local clanId = rolePlayerProperty:getClan()
        
        rolePlayerProperty.team_id=clanId
        self.m_isFreeFight=false
        
        self.m_battleViw:showDps()
        self.m_lpPlay:setMaxHp(self.m_lpPlay:getHP()*_G.Const.CONST_BATTLE_CITY_BOSS_HP)
        
        print("CStage.addControlMode  clanId=",clanId)
        
    elseif self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then
        self.m_enableBigSkill=false
        self:addJoyStick()
        self:addKeyBoard()
        self.m_battleViw:addExitCopyButton(self.m_lpUIContainer)
        if self.m_isCanAttackOrther then
            self.m_battleViw:addModelButton(self.m_lpUIContainer)
        end

        local property=_G.GPropertyProxy:getMainPlay()
        local clanId  = property:getClan()
        property.team_id=clanId
        self.m_isFreeFight=false

        self.m_lpPlay:setMaxHp(self.m_lpPlay:getHP()*_G.Const.CONST_BATTLE_MIBAO_BOSS_HP)
        self.m_battleViw:addhostingBtn( self.m_lpUIContainer, property.autoStatus)
        self.m_battleViw:showStageName(self.m_lpUIContainer,self.m_lpScenesXML.scene_name)
        __StageXMLManager:addTransport( scenesID )
    elseif self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_MONEY then
        self.m_nCheckPointID=1

        self:addJoyStick()
        self:addKeyBoard()

        local property=_G.GPropertyProxy:getMainPlay()
        self.m_battleViw:addExitCopyButton( self.m_lpUIContainer )
        self.m_battleViw:addhostingBtn( self.m_lpUIContainer,property.autoStatus)
        self.m_battleViw:addCopyTotal(self.m_lpUIContainer)

        self:addFirstPointMonster(false)

        -- 给主角加buff
        local invBuff=_G.GBuffManager:getBuffNewObject(2304,0)
        self.m_lpPlay:addBuff(invBuff)
    elseif self.m_sceneType==_G.Const.CONST_MAP_TYPE_PK_LY then
        self.m_lingYaoPkData=_G.g_lingYaoPkData
        _G.g_lingYaoPkData=nil

        -- self:addJoyStick()
        self.m_battleViw:addExitCopyButton(self.m_lpUIContainer)
        self:initLingYaoData()
        self:runNextLingYaoBattle()
    else
        self.m_nCheckPointID=1

        if self.m_nMapViewrx==nil then
            print("codeError!!!! 副本关卡 x,y 错误")
        end
        print("副本战斗==>self.m_nMaplx=%d,self.m_nMapViewrx=%d",self.m_nMaplx,self.m_nMapViewrx)

        -- __StageXMLManager:addGoodsMonster(scenesID)
        __StageXMLManager:addHook(scenesID)
        self.m_lpPlay:checkObstacleLimit()

        local plotData=nil
        local isGuideCopy=false
        if self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
            print("多人副本，需要广播位置")
            self.m_enableBigSkill=false
            self.m_nMapViewrx=self.m_lpMapData.mapWidth
        else
            self:setStopAI(true)
            if self:getScenesCopyID()==__Const.CONST_COPY_FIRST_COPY and _G.GLoginPoxy:getFirstLogin()==true then
                isGuideCopy=true
                self:addFirstPointMonster(plotData~=nil and plotData~=false)
            else
                plotData=self:checkMapPlot(__Const.CONST_DRAMA_GETINTO)
                self:addFirstPointMonster(plotData~=nil and plotData~=false)
            end

            if self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_NORMAL
                or self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_FIEND
                or self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_HERO then
                self.m_battleViw:addNormalCopyCondition(self.m_lpUIContainer,self.m_condPreTimes)
                self.m_condPreTimes=nil
                self.m_enableMountSkill=true
            elseif self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_FIGHTERS then
                self.m_enableMountSkill=true
            end
        end

        local property=_G.GPropertyProxy:getMainPlay()
        local isRightSide = self.m_nPlayDir < 0 and true or false

        self:addJoyStick()
        self:addKeyBoard()

        if self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_FIGHTERS then
            self.m_battleViw:addExitCopyButton( self.m_lpUIContainer )
            self.m_battleViw:addhostingBtn( self.m_lpUIContainer,property.autoStatus)
            
            local curTimes=_G.TimeUtil:getTotalSeconds()
            if self.m_copyPassLimitTimes==nil then
                local copyId=self:getScenesCopyID()
                local copyCnf=_G.Cfg.scene_copy[copyId]
                local allowTimes=copyCnf.time
                self.m_copyPassLimitTimes=allowTimes+curTimes
                self.m_copyPassAllowTimes=allowTimes
            end
            self:addPartnerByProperty(self.m_lpPlay,property, false,isRightSide)
            self.m_battleViw:addTuFuNotic(self.m_lpUIContainer,self.m_copyPassLimitTimes*1000)
        else
            -- if self.m_sceneType ~=__Const.CONST_MAP_TYPE_THOUSAND and self.m_sceneType ~=__Const.CONST_MAP_TYPE_COPY_MULTIPLAYER
            -- and self.m_sceneType ~=__Const.CONST_MAP_TYPE_COPY_ROAD then
            --     local partnerCount=self:addPartnerByProperty(self.m_lpPlay,property, false,isRightSide)
            --     partnerCount=partnerCount+1
            --     self.m_battleViw:addZuDuiCondition(self.m_lpUIContainer,self.m_condPreTimes,partnerCount)
            --     self.m_condPreTimes=nil
            -- end

            if not isGuideCopy then
                self.m_battleViw:addExitCopyButton( self.m_lpUIContainer )
                self.m_battleViw:addhostingBtn( self.m_lpUIContainer, property.autoStatus)
                if plotData then
                    self:runMapPlot(plotData)
                -- else
                --     local copyId=self:getScenesCopyID()
                --     if copyId==10011 then
                --         if not self.m_plotManager:checkCopyPass(_G.Const.CONST_DRAMA_GETINTO,copyId) then
                --             local guideView=require("mod.map.PlotDodge")()
                --             guideView:startPlot()
                --         end
                --     end
                end
            else
                self.m_battleViw:addExitCopyButton( self.m_lpUIContainer )
                self.m_enableBigSkill=true
                self.m_lpPlay:setMP(100)
                self.m_plotFirstGame=require("mod.map.PlotFirstGame")()
                self.m_plotFirstGame:startPlot()
            end
        end
        
        -- if self.m_isAutoFightNextScene then
        --     self.m_lpPlay:enableAI(true)
        --     self:startAutoFight()
        --     self.m_isAutoFightNextScene=nil
        -- end
    end
end

function CStage.addFirstPointMonster(self,_hasPlot)
    local scenesID=self:getScenesID()
    -- local checkPoints=__StageXMLManager:getXMLScenesCheckpointList(scenesID)
    -- for i=1,#checkPoints do
    --     local monsterList=__StageXMLManager:getXMLScenesMonsterList(scenesID,i)
    --     for _,monster in pairs(monsterList) do
    --         if monster.type ~= nil and monster.type > 1000 then
    --             local boxData = {}
    --             boxData.type = __Const.CONST_BOX_MONSTER
    --             boxData.x = monster.x
    --             boxData.y = monster.y
    --             boxData.id = monster.type
    --             local uid = _G.UniqueID:getNewID()
    --             local goodsMonster=CGoodsMonster(__Const.CONST_BOX_MONSTER)
    --             goodsMonster:init(uid,boxData)
    --             self:addCharacter(goodsMonster)
    --         end
    --     end
    -- end
    print("addFirstPointMonster.m_partner",m_partner)
    __StageXMLManager:addMonster(scenesID,self.m_nCheckPointID,_hasPlot,self.m_partner)
end

function CStage.showSceneName(self)
    local szName=self.m_lpScenesXML.scene_name
    if szName==nil then return end

    local nameColor=cc.c3b(255,10,30)--_G.ColorUtil:getRGB(__Const.CONST_COLOR_GOLD)
    local backColor=cc.c4b(0,0,0,255)--_G.ColorUtil:getRGBA(__Const.CONST_COLOR_WHITE)
    local sceneNameLabel=_G.Util:createLabel(szName,32)
    sceneNameLabel:setColor(nameColor)
    sceneNameLabel:enableOutline(backColor,1)
    sceneNameLabel:enableShadow(cc.c4b(255,215,0,255),cc.size(1.7,-1.7))
    sceneNameLabel:setPosition(self.winSize.width*0.5,605)
    self.m_lpScene:addChild(sceneNameLabel,99999)

    local bgSpr=cc.Sprite:createWithSpriteFrameName("general_loading_tip_bg.png")
    bgSpr:setPosition(self.winSize.width*0.5,605)
    bgSpr:setScaleX(1.4)
    bgSpr:setScaleY(1.2)
    self.m_lpScene:addChild(bgSpr,99998)

    local function call()
        sceneNameLabel:removeFromParent(true)
        bgSpr:removeFromParent(true)
    end
    local action1=cc.Sequence:create(cc.DelayTime:create(4),cc.FadeTo:create(2.5,0),cc.CallFunc:create(call))
    local action2=cc.Sequence:create(cc.DelayTime:create(4),cc.FadeTo:create(2.5,0))
    sceneNameLabel:runAction(action1)
    bgSpr:runAction(action2)
end

function CStage.fadeInStageScene( self )
    local function local_fun(_node)
        _node:removeFromParent(true)
    end

    local layer=cc.LayerColor:create(cc.c4b(0,0,0,255))
    self.m_lpScene:addChild(layer,9999999)

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,layer)

    layer:runAction(cc.Sequence:create(cc.FadeTo:create(0.3,0),cc.CallFunc:create(local_fun)))
end
function CStage.delayFadeInStageScene( self )
    local function local_fun()
        self:fadeInStageScene()
        -- self:showSceneName()
    end
    _G.Scheduler:performWithDelay(0.01,local_fun)
end

function CStage.fadeOutStageScene( self, _fun )
    local function local_fun()
        if _fun then
            _fun()
        end
    end
    local runningScene=cc.Director:getInstance():getRunningScene()
    local layer=cc.LayerColor:create(cc.c4b(0,0,0,0))
    runningScene:addChild(layer,9999999)

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,layer)

    layer:runAction(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.CallFunc:create(local_fun)))
end
function CStage.delayFadeOutStageScene( self, _fun )
    local function local_fun()
        self:fadeOutStageScene(_fun)
    end
    _G.Scheduler:performWithDelay(0.01,local_fun)
end

function CStage.setOpenId( self, _state )
    self.OpenId = _state
end
function CStage.getOpenId( self )
    return self.OpenId
end

function CStage.setBossDeadTime( self, _time )
    self.m_nBossDeadTime = _time
end
function CStage.setBoss( self, _lpCharacter )
    self.m_lpBossCharacter = _lpCharacter
end
function CStage.getBoss( self )
    return self.m_lpBossCharacter
end
function CStage.setBossHp( self, _hp )
    if self.m_lpBossCharacter==nil then
        return
    end
    self.m_lpBossCharacter:setHP(_hp)
    -- self.m_battleViw:updateDps()
end
function CStage.getSysViewContainer(self)
    return self.m_lpSysViewContainer
end

function CStage.setBossVipRmb( self, _isOpen )
    self.m_bBossVipRmb = _isOpen
end
function CStage.getBossVipRmb( self )
    return self.m_bBossVipRmb
end

function CStage.getCheckPointID( self )
    --关卡ID
    return self.m_nCheckPointID
end
function CStage.setCheckPointID( self, _nID )
    self.m_nCheckPointID = _nID
end

function CStage.getScenesID( self )
    return self.m_lpScenesXML.scene_id
end
function CStage.getScenesCopyID( self )
    return self.m_lpScenesXML.copy_id
end

function CStage.getScenesType( self )
    return self.m_sceneType
end

function CStage.getScenesPassType( self )
    return self.m_lpScenesXML.pass_type
end
function CStage.getScenesPassValue( self )
    return self.m_lpScenesXML.pass_value
end

function CStage.getMainPlayer( self )
    return self.m_lpPlay
end

function CStage.getMaplx( self )
    return self.m_nMaplx
end
function CStage.getMaprx( self )
    return self.m_nMaprx
end

function CStage.getMapViewlx( self )
    return self.m_nMapViewlx
end
function CStage.getMapViewrx( self )
    return self.m_nMapViewrx
end

function CStage.setCanControl( self, _canControl )
    self.m_canControl = _canControl
end

function CStage.getCanControl( self )
    return self.m_canControl
end

function CStage.finishOneSceneInCopy(self)
    print("CStage.finishOneSceneInCopy===>>>")

    __StageXMLManager:addTransport(self:getScenesID())
    
    if self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        self:addGoNextCheckPointTips()
    end
    
    self.m_lpPlay.m_isFinishBattle=true
    if  self.isAutoFightMode==168 then
        self.m_lpPlay:enableAI(true)
    elseif self.isAutoFightMode==true then
        self.isAutoFightMode=168
        self.m_lpPlay:enableAI(true)
    end
end

function CStage.autoExitCopy(self)
    print("CStage.autoExitCopy ",debug.traceback())
    
    self:exitCopy()
    
    self.isFinishCopy=true
    
    if self.m_lpScenesXML==nil then
        print("CStage.autoExitCopy self.m_lpScenesXML==nil 无场景数据")
        return
    end

    local remainTime = self.m_lpScenesXML.is_time
    if remainTime~=nil and remainTime>0 then
        self:setRemainingTime(remainTime)
    end
    
    self.m_lpPlay.m_isFinishBattle=true
    -- if self.isAutoFightMode==168 then
    --     self.m_lpPlay:enableAI(true)
    -- end
end

function CStage.exitCopy( self )
    print("CStage.exitCopy scenesType=%d,scenesId=%d",self.m_sceneType,self : getScenesID())
    
    if self.m_sceneType == __Const.CONST_MAP_TYPE_CHALLENGEPANEL  then 
        if  self.m_stageMediator~=nil then
            self.m_stageMediator:gotoScene(_G.g_nLastScenesID,_G.g_nLastX,_G.g_nLastY )
        else
            print("codeError!!!! pStageMediator == nil")
        end
    elseif  self.m_sceneType == __Const.CONST_MAP_TYPE_BOSS or self.m_sceneType == __Const.CONST_MAP_TYPE_CLAN_BOSS then
        local msg = REQ_WORLD_BOSS_EXIT_S()
        __Network:send(msg)
    elseif self.m_sceneType == __Const.CONST_MAP_TYPE_INVITE_PK then
        print("发送出去")
        local msg=REQ_SCENE_ENTER_CITY()
        __Network:send(msg)
    elseif self.m_sceneType == __Const.CONST_MAP_TYPE_KOF then --格斗之王
        print("发送出去")
        print("为什么是这样？")
        local msg=REQ_SCENE_ENTER_CITY()
        __Network:send(msg)
    elseif self.m_sceneType == __Const.CONST_MAP_CLAN_WAR then
        print("[门派战]- 退出")
        local msg = REQ_GANG_WARFARE_EXIT_WAR()
        __Network:send(msg)
    else
        print("退出副本。。。。")
        if _G.IS_TEST_COPY and self.m_sceneId==9998 then
            self.m_stageMediator:gotoScene(_G.g_nLastScenesID,_G.g_nLastX,_G.g_nLastY )
        else
            local msg = REQ_COPY_COPY_EXIT()
            __Network : send(msg)
        end
    end
end

--注册AI回调
function CStage.registerEnterFrameCallBack(self)
    if self.m_slowSchedule~=nil then return end

    local pTime=_G.TimeUtil
    if not self.m_isCity then
        local onEnterFrame=function(_duration)
            local nowTime=pTime:getTotalMilliseconds() --毫秒数

            if self.m_deadlineTime then
                self:showRemainingTime( _duration ,nowTime )
            end
            
            if self.m_nComboTime~=nil then
                self:autoHideCombo( nowTime )
            end
            if self.m_nBossDeadTime~=nil then
                self:updateBossDeadTime( _duration, nowTime )
            end
            if self.isGoingNextCheckPoint and self.m_lpPlay~=nil then
                if self.m_sceneDir > 0 then
                    if self.m_lpPlay.m_nLocationX>=self.m_nMapBornX then
                        self.isGoingNextCheckPoint=false
                        self:runNextCheckPoint()
                    end
                else
                    if self.m_lpPlay.m_nLocationX<=self.m_nMapBornX then
                        self.isGoingNextCheckPoint=false
                        self:runNextCheckPoint()
                    end
                end
            end

            if self.m_canJump then
                print(self.m_lpPlay.m_nLocationX)
                if self.m_sceneDir > 0 then
                    if self.m_lpPlay.m_nLocationX>=self.m_nMapmx-150 then
                        self.m_canJump = nil
                        self:jump()
                        self.m_nMapmx = nil
                    end
                else
                    if self.m_lpPlay.m_nLocationX<=self.m_nMapmx+150 then
                        self.m_canJump = nil
                        self:jump()
                        self.m_nMapmx =nil
                    end
                end
            end
            if not self.m_stopAI then
                for _,character in pairs(__CharacterManager.m_lpCharacterArray) do
                    if character.think and character.m_lpContainer then
                        character:think(nowTime)
                    end
                    if character.onUpdate and character.m_lpContainer then
                        character:onUpdate( _duration, nowTime )
                    end
                end
            else
                for _,character in pairs(__CharacterManager.m_lpCharacterArray) do
                    if character.onUpdate and character.m_lpContainer then
                        character:onUpdate( _duration, nowTime )
                    end
                end
            end
        end
        self.m_slowSchedule=_G.Scheduler:schedule(onEnterFrame,0.0666)
    else
        local onEnterFrame=function(_duration)
            local nowTime=pTime:getTotalMilliseconds() --毫秒数
            -- for _,character in pairs(__CharacterManager.m_lpCharacterArray) do
            --     if character.onUpdate and character.m_lpContainer then
            --         character:onUpdate( _duration, nowTime )
            --     end
            -- end
            if self.m_lpPlay then
                self.m_lpPlay:updateMainPlayer(nowTime)
            end
        end
        self.m_slowSchedule=_G.Scheduler:schedule(onEnterFrame,0.1)
    end

    self:registerMoveFrameCallBack()
end
function CStage.registerMoveFrameCallBack(self)
    if self.m_fastSchedule~=nil then return end

    local pChaMan=__CharacterManager
    if self.m_isCity then
        local function onEnterFrame( _duration )
            if not self.m_stopMove then
                for _,character in pairs(pChaMan.m_lpCharacterArray) do
                    if character.onUpdateMove and character.m_lpContainer then
                        character:onUpdateMove(_duration)
                    end
                end
                -- print("AAHDSJDASHDAS====>>>",_duration)
                self:moveArea3(_duration)
            end
        end
        self.m_fastSchedule=_G.Scheduler:schedule(onEnterFrame,0)
    else
        local tempCount=0
        local tempBool=false
        if self.m_sceneType==__Const.CONST_MAP_TYPE_CLAN_BOSS or 
            self.m_sceneType==__Const.CONST_MAP_TYPE_BOSS or 
            self.m_sceneType==__Const.CONST_MAP_TYPE_CITY_BOSS or
            self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_BOX then
            tempBool=true
        end

        local function onEnterFrame( _duration )
            if not self.m_stopMove then
                for _,character in pairs(pChaMan.m_lpCharacterArray) do
                    if character.onUpdateMove and character.m_lpContainer then
                        character:onUpdateMove(_duration)
                        if tempBool then
                            tempCount=tempCount+1
                        end
                    end
                    if character.onUpdateJump and character.m_lpContainer then
                        character:onUpdateJump(_duration)
                    end
                end
                self:moveArea3(_duration)
                self.m_onUpdateCharcterCount=tempCount
                -- print("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=======>>>>>",tempCount)
                -- print("CCCC+====asDAd=========>>>>>",self.m_onUpdateCharcterCount)
            end
        end
        self.m_fastSchedule=_G.Scheduler:schedule(onEnterFrame,0.02)
    end
end
function CStage.removeFrameCallBack(self)
    if self.m_slowSchedule then
        _G.Scheduler:unschedule(self.m_slowSchedule)
        self.m_slowSchedule=nil
    end
    if self.m_fastSchedule then
        _G.Scheduler:unschedule(self.m_fastSchedule)
        self.m_fastSchedule=nil
    end
    if self.m_loopMapSchedule then
        _G.Scheduler:unschedule(self.m_loopMapSchedule)
        self.m_loopMapSchedule=nil
    end
end

function CStage.getUIContainerChild( self )
    return self.m_lpUIContainerChild
end

function CStage.getUIContainer( self )
    return self.m_lpUIContainer
end


function CStage.addStageMediator( self )
    --场景
    self.m_stageMediator=require("mod.map.StageMediator")()
    self.m_stageMediator:registerProtocol(self.m_sceneType)
    
    if self.m_isCity then
        --注册NPC mediator
        require("mod.map.NpcMediator")()
    end
end
function CStage.getStageMediator(self)
    return self.m_stageMediator
end

function CStage.setSkillCD(self, skillId, cd)
    if self.m_keyBoard~=nil then
        self.m_keyBoard:setSkillCD(skillId, cd)
    end
end

function CStage.addKeyBoard( self )
    if self.m_keyBoard==nil then
        self.m_keyBoard=require("mod.map.UIKeyBoard")()
        local layer=self.m_keyBoard:create(self.m_enableBigSkill,self.m_enableMountSkill,self.m_mountSkillCD,self.m_artifactSkillCD)
        self.m_lpUIContainer:addChild(layer,10)
    end
end

function CStage.removeKeyBoard(self)
    if self.m_keyBoard~=nil then
        self.m_keyBoard:destory()
        self.m_keyBoard=nil
    end
end

function CStage.removeJoyStick( self )
    print("CStage.removeJoyStick===>>")
    if self.m_joyStick~=nil then
        self.m_joyStick:removeFromParent( true )
        self.m_joyStick=nil
    end
end

function CStage.removeKeyBoardAndJoyStick( self )
    print("CStage.removeKeyBoardAndJoyStick==>>")
    self:removeKeyBoard()
    self:removeJoyStick()
    if self.m_lpPlay~=nil then
        self.m_lpPlay:cancelMove()
    end
end

function CStage.addJoyStick( self )
    local joy=_G.GJoyStick
    if joy==nil then
        local szName1="general_joystick_box.png"
        local szName2="general_joystick_circle.png"
        -- local sprite1=cc.Sprite:create(szName1)
        -- local sprite2=cc.Sprite:create(szName2)
        joy=gc.JoyStick:create(szName1,szName2,"");
        -- joy=gc.JoyStick:create(sprite1,sprite2,"")
        joy:setFireMode(1)
        joy:setMaxRadius(160)
        joy:setMaxStickRadius(40)
        joy:setAutoHide(false)
        joy:setFireInterval(0.15)
        joy:setPosition(160,160)
        joy:retain()
        _G.GJoyStick=joy
    end
    self.m_joyStick=joy
    joy:removeFromParent(true)
    joy:setVisible(true)

    self.m_lpUIContainer:addChild(joy,10)

    local preJoyTimes=0
    self.joyCdTimes=0
    local preX=0
    local function callBack(eventType, radian, radius)

        if eventType=="JoyStickBegan" then
            if radius>55 or radius<-55 or math.abs(radian)<20 then preJoyTimes=0 return end
            local curJoyTimes=_G.TimeUtil:getTotalMilliseconds()
            if not self.m_isCity and curJoyTimes-preJoyTimes<500 and curJoyTimes-self.joyCdTimes>_G.Const.CONST_WAR_ROLL_CD and radian*preX>0 then
                preJoyTimes=0
                -- joyCdTimes=curJoyTimes
                print("双击方向盘")
                self.m_lpPlay:dodge(radian,radius)
            else
                preJoyTimes=curJoyTimes
            end
            preX=radian
        elseif eventType=="JoyStickCallBack" then
            if radius<=10 then
                return
            end
            
            self:startBattleAI()
            self.m_lpPlay.m_isJoyStickPress=true

            local moveX=250*math.cos(radian)
            local moveY=250*math.sin(radian)

            local characterPosX,characterPosY=self.m_lpPlay:getLocationXY()
            local x = characterPosX-moveX
            local y = characterPosY-moveY
            
            
            self.m_lpPlay:setMovePos({x=x,y=y})

            if not(self.m_lpPlay.m_nAI==nil or self.m_lpPlay.m_nAI==0) then
                -- self.isAutoFightMode=false
                -- self.m_lpPlay:enableAI(false)
                -- self.m_battleViw:removeAutoFightTips(self.m_lpMessageContainer)
                self:stopAutoFight()
            end
            
            -- if self.m_lpPlay.m_isFinishBattle then
            --     self.m_lpPlay:enableAI(false)
            -- end

            _G.GTaskProxy:setAutoFindWayData()
            
        elseif eventType == "JoyStickEnded" then
            self.m_lpPlay.m_isJoyStickPress=false
            if self.m_plotFirstGame and self.m_plotFirstGame.m_isAAAAAAAA then
                return
            end
            self.m_lpPlay:cancelMove()
            -- self.isAutoFightMode=nil
        end
    end
    
    local handler=gc.ScriptHandlerControl:create(callBack)
    joy:registerScriptHandler(handler)
    return true
end
function CStage.cancelJoyStickTouch(self)
    if self.m_joyStick then
        self.m_joyStick:cancelUserTouches()
    end
end

function CStage.startBattleAI(self)
    if self.m_stopAI==true then
        if not self.m_isCity then
            self:setStopAI(false)
        end
    end
end

function CStage.startAutoFight(self)
    self.m_lpPlay:enableAI(true)
    self.m_battleViw:addAutoFightTips( self.m_lpMessageContainer )
    self.isAutoFightMode=true
    
    if self.m_sceneType==__Const.CONST_MAP_TYPE_CHALLENGEPANEL
        and self.m_isUserPkRobot
        and not self.m_startUserPkRobotTime then
        return
    end
    
    self:setStopAI(false)
    
    if self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        local msg = REQ_SCENE_WAR_STATE()
        msg.state=1
        __Network : send(msg)
    end
    local property=_G.GPropertyProxy:getMainPlay()
    property.autoStatus=true
end

function CStage.stopAutoFight(self,noStopAuto)
    self.isAutoFightMode=168
    self.m_lpPlay:enableAI(false)
    self.m_lpPlay.m_fLastThinkTime=0
    self.m_battleViw:removeAutoFightTips(self.m_lpMessageContainer)
    
    if self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        local msg = REQ_SCENE_WAR_STATE()
        msg.state=2
        __Network : send(msg)
    end
    if not noStopAuto then
        local property=_G.GPropertyProxy:getMainPlay()
        property.autoStatus=false
    end
end

function CStage.addCharacter( self, _lpPlayer)
    CCLOG("CStage.addCharacter _lpPlayer.m_SkinId=%d",_lpPlayer.m_SkinId)
    self.m_lpCharacterContainer:addChild( _lpPlayer.m_lpContainer, -_lpPlayer.m_nLocationY)
    __CharacterManager:add(_lpPlayer)
    -- _lpPlayer:setStage(self)
    
    if self.m_sceneType == __Const.CONST_MAP_TYPE_BOSS then
        if _lpPlayer.m_nType==__Const.CONST_PLAYER then
            _lpPlayer:setScalePer(0.8)
            if _lpPlayer.m_star then
                _lpPlayer.m_star.m_lpContainer:setScale(0.8)
                -- _lpPlayer.m_skeletonHeight=_lpPlayer.m_skeletonHeight*0.8
            end
        else
            _lpPlayer:setScalePer(1.2)
        end
    -- elseif self.m_sceneType == __Const.CONST_MAP_TYPE_KOF then
    --     if _lpPlayer.m_nLocationX>800 then
    --         _lpPlayer:setMoveClipContainerScalex(-1)
    --     end
    end
end

function CStage.addVitro(self,_lpPlayer, _lpVitro)
    local parentContainer = _lpPlayer.m_lpContainer:getParent()
    if  parentContainer == nil then
        print("codeError!!!! addVitro".."addVitro,ERROR")
        return
    end
    parentContainer:addChild(_lpVitro.m_lpContainer)
    
    __CharacterManager:add(_lpVitro)
    -- _lpVitro:setStage(self)
end
function CStage.addTrap(self,_lpPlayer, _lpVitro)
    local parentContainer = _lpPlayer.m_lpContainer:getParent()
    if  parentContainer == nil then
        print("codeError!!!! addTrap".."addTrap,ERROR")
        return
    end
    parentContainer:addChild(_lpVitro.m_lpContainer, -_lpVitro.m_nLocationY)
    
    __CharacterManager:add(_lpVitro)
    -- _lpVitro:setStage(self)
end

function CStage.removeVitro(self,_vitro)
    if _vitro==nil then return end
    __CharacterManager:remove( _vitro )
    _vitro:releaseResource()
end

function CStage.removeCharacter( self, _lpPlayer )
    -- print("CStage.removeCharacter",debug.traceback())
    
    if _lpPlayer==nil then return end
    
    local characterType=_lpPlayer:getType()
    -- for k,v in pairs(__CharacterManager) do
    --     print(k,v)
    -- end
    __CharacterManager:remove(_lpPlayer)
    local mapType=self.m_sceneType
    
    print("CStage.removeCharacter _lpPlayer.m_nID=%d characterType=%d",_lpPlayer.m_nID,characterType)
    
    if characterType==__Const.CONST_PLAYER then
        if _lpPlayer.m_property~=nil then
            local warPartner=_lpPlayer.m_property:getWarPartner()
            if warPartner~=nil then
                local roleUid=_lpPlayer.m_property:getUid()
                local partnerIdx=warPartner:getPartner_idx()
                local indexId= tostring(roleUid)..tostring(partnerIdx)
                local partner=__CharacterManager:getCharacterByTypeAndID(__Const.CONST_PARTNER,indexId)
                if partner~=nil then
                    partner:setHP(0)
                end
            end
        end
        if _lpPlayer.m_isCorpse then
            __CharacterManager:addCorpse(_lpPlayer)
        end
    end
    
    if _lpPlayer.isMainPlay then
        -- self:removeKeyBoardAndJoyStick()
        self:removeKeyBoard()
        self:removeJoyStick()
        print("sssssssssssss->4",self.m_sceneType)
        if mapType == __Const.CONST_MAP_TYPE_COPY_NORMAL
            or mapType == __Const.CONST_MAP_TYPE_COPY_HERO
            or mapType == __Const.CONST_MAP_TYPE_COPY_FIEND
            or mapType == __Const.CONST_MAP_TYPE_COPY_FIGHTERS 
            or  mapType == __Const.CONST_MAP_CLAN_DEF_TIME2 then 
             
            if self.m_isPassWar==true or self.hasSLowMotion==true then
                _lpPlayer:releaseSkillResource()
                return
            end
            
            _lpPlayer:releaseResource()
            self:copyLose()
            return
        elseif mapType == __Const.CONST_MAP_TYPE_THOUSAND then
            self:IkkiTousen_finishCopy()
        elseif mapType == __Const.CONST_MAP_TYPE_COPY_MONEY then
            self:finishCopy()
        end
    end
    
    if characterType==__Const.CONST_MONSTER then
        _lpPlayer:releaseResource()
        
        if _lpPlayer.m_isCorpse then
            __CharacterManager:addCorpse(_lpPlayer)
        end

        -- 改
        if self.m_sceneType==__Const.CONST_MAP_TYPE_CITY_BOSS or self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_BOX or _lpPlayer.isPlotMonster then 
            return
        end

        if _lpPlayer.isPartner and self.m_protectNpcType~=nil and self.m_protectNpcType~=__Const.CONST_COPY_PASS_NPC0 then
            if self.m_protectNpcType==__Const.CONST_COPY_PASS_NPC1 then
                self.m_lpPlay:setHP(-12345)
                return
            else
                local hasOrtherNpc=false
                for k,v in pairs(__CharacterManager.m_lpMonsterArray) do
                    if v.isPartner then
                        hasOrtherNpc=true
                        break
                    end
                end
                if not hasOrtherNpc then
                    self.m_lpPlay:setHp(-12345)
                    return
                end
            end
        end

        self:checkNextCheckPoint()
        
        _lpPlayer=nil
        return
    elseif characterType==__Const.CONST_GOODS or characterType==__Const.CONST_GOODS_MONSTER then
        if self.m_lpPlay.m_nTarget==_lpPlayer then
            self.m_lpPlay.m_nTarget=nil
        end
        _lpPlayer:releaseResource()
        _lpPlayer=nil
        return
    end
    
    print("CStage.removeCharacter  _lpPlayer:releaseResource()")
    
    _lpPlayer:releaseResource()
    
    if mapType==__Const.CONST_MAP_TYPE_CHALLENGEPANEL then -- 竞技场
        self.m_lpContainer:stopAllActions()
        
        self:autoPKFinish(_lpPlayer)
    elseif mapType==__Const.CONST_MAP_TYPE_PK_LY then -- 灵妖竞技场
        self:deadLingYao(_lpPlayer)
    else --其他副本类型
        --自己的伙伴死亡
        if characterType == __Const.CONST_PARTNER then
            local property = _G.GPropertyProxy:getOneByUid( _lpPlayer:getID(), characterType )
            if property~=nil and property:getUid()==_G.GPropertyProxy:getMainPlay():getUid() then
                -- local msg=REQ_SCENE_DIE_PARTNER()
                -- msg:setArgs(property:getPartnerId())
                -- __Network:send(msg)
                self.m_battleViw:conditionSubRole()
            end
        end
    end
    _lpPlayer=nil
end

function CStage.showPKResult(self,_resultData)
    if self.m_resultData~=nil then return end
    self.m_resultData=_resultData
    if _resultData.res==1 then
        if self.m_counterWorker~=nil and self.m_counterWorker.m_property~=nil then
            self:killPartners(self.m_counterWorker.m_property)
            self.m_counterWorker:setHP(0)
            if self.m_sceneType == __Const.CONST_MAP_TYPE_KOF then
                self.hasSLowMotion=false
                self:slowMotion()
                return
            end
        else
            self:passWar()
        end
    else
        if self.m_lpPlay~=nil and self.m_lpPlay.m_property~=nil then
            self:killPartners(self.m_lpPlay.m_property)
            self.m_lpPlay:setHP(-12345)
        end
        self:passWar()
        -- local view=require("mod.map.UIBattleResult")(_resultData)
        -- self:addMessageView(view:create())
    end
    
    self:removeKeyBoardAndJoyStick()
    
end

function CStage.showKO(self,character)
    print("CStage.showKO================>>>")
    -- cc.Director:getInstance():getEventDispatcher():setEnabled( true )
    -- self:passWar()
    -- cc.Director:getInstance():getScheduler():setTimeScale(1)
    -- _G.Util:playAudioEffect("kill")
    
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/battle_ko.plist")
    
    -- self.m_battleRedBg  = CCSprite:createWithSpriteFrameName("battle_ko_red.png")
    -- self.m_battleRedBg:setPosition(self.winSize.width*0.5, self.winSize.height*0.5)
    -- self.m_lpScene:addChild(self.m_battleRedBg,10001)
    -- self.m_battleRedBg:setScaleX(self.winSize.width/480)
    -- self.m_battleRedBg:setScaleY(self.winSize.height/320)
    
    -- self.m_battleRedBg:runAction(CCFadeOut:create(0.4))
    
    -- self.m_battleKO = CCSprite :createWithSpriteFrameName( "zbattle_ko_text.png" )
    -- self.m_battleKO:setPosition(self.winSize.width*0.5, self.winSize.height*0.5)
    -- self.m_battleKO:setScale(1.47)
    -- self.m_lpScene:addChild(self.m_battleKO,10002)
    
    -- self.m_KOFlashBar  = CCSprite:createWithSpriteFrameName( "ko_flash_bar.png" )
    -- self.m_KOFlashBar:setPosition(self.winSize.width*0.5, self.winSize.height*0.5)
    -- self.m_lpScene:addChild(self.m_KOFlashBar,10003)
    -- self.m_KOFlashBar:setScaleX(self.winSize.width/480)
    -- self.m_KOFlashBar:setScaleY(self.winSize.height/320)

    local lpScheduler = cc.Director:getInstance():getScheduler()
    self.m_deadSpr = _G.SpineManager.createSpine("spine/shengli")
    if self.m_deadSpr == nil or character == nil or character.m_skinData == nil or character.m_skinData.hurt_x == nil or character.m_skinData.hurt_Y then
        cc.Director:getInstance():getEventDispatcher():setEnabled( true )
        self:passWar()
        lpScheduler:setTimeScale(1)
        return
    end
    -- local x,y = character : getLocationXY()
    -- local z   = character : getLocationZ()
    -- print("@@@@$@$@%@%",x,y,z)
    -- self.m_deadSpr : setPosition(x,y+z)
    self.m_deadSpr : setPosition(self.winSize.width*0.5,self.winSize.height*0.5)
    self.m_deadSpr : setAnimation(0,"idle",false)
    -- self.m_lpCharacterContainer : addChild(self.m_deadSpr)

    self.m_lpScene:addChild(self.m_deadSpr,100)
    local function onActionCallFunc()
        -- self.m_battleRedBg:removeFromParent(true)
        -- self.m_KOFlashBar:removeFromParent(true)
        -- self.m_battleRedBg=nil
        -- self.m_KOFlashBar=nil
        
        -- local function actionCallFunc1()
            self.m_lpContainer:runAction(cc.MoveTo:create(0.3,self.m_slowMotionMapPos))
            self.m_lpContainer:runAction(cc.ScaleTo:create(0.3,1))
            
            self.m_slowMotionMapPos=nil
            -- self.m_battleKO:removeFromParent(true)
            -- self.m_battleKO=nil
            
            cc.Director:getInstance():getEventDispatcher():setEnabled( true )
            self:passWar()
        -- end
        
        lpScheduler:setTimeScale(1)
        self.m_deadSpr : removeFromParent(true)
        self.m_deadSpr = nil
        -- self.m_battleKO:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(actionCallFunc1)))
    end
    
    -- self.m_KOFlashBar:runAction(cc.Sequence:create(cc.FadeOut:create(0.9),cc.CallFunc:create(onActionCallFunc)))
    -- self.m_deadSpr : registerSpineEventHandler(onActionCallFunc,2)
    self.m_lpCharacterContainer : runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onActionCallFunc)))
    lpScheduler:setTimeScale(0.3)
    print("CStage.showKO================<<<")
end

function CStage.slowMotion( self )
    print("1CStage.slowMotion============>>>",debug.traceback())
    if self.m_slowMotion then
        return
    end 
    self.m_deadlineTime=nil

    self.m_slowMotion=true
    self.m_lpPlay:cancelMove()
    -- if self.isAutoFightMode==true then
    --     self:stopAutoFight()
    -- end

    _G.Util:playAudioEffect("ui_kill")
    
    if self.isAutoFightMode==true then
        self:stopAutoFight(true)
    end
    self.m_battleViw:showWin(self.m_lpUIContainer)
    self:removeJoyStick()
    self:removeKeyBoard()
    local character
    for k,v in pairs(__CharacterManager:getCharacter()) do
        if v.isMonsterBoss then
            if v:getType() == __Const.CONST_PLAYER and self.m_lpPlay:getHP() == 0 then
                character = self.m_lpPlay
                break
            end
            character=v
            break
        end
    end
-- if character==nil then
--     character=self.m_lpPlay
-- end
    if character==nil then
        print("lua error....slowMotion!!!!!!!  no character")
        self:passWar()
        return
    end
    
    cc.Director:getInstance():getEventDispatcher():setEnabled( false )

    local bigScale = 1.3
    local mapActionTimes = 0.3
    local lpScheduler = cc.Director:getInstance():getScheduler()
    self.m_deadSpr = _G.SpineManager.createSpine("spine/shengli")
    if self.m_deadSpr == nil or character == nil or character.m_skinData == nil or character.m_skinData.hurt_x == nil or character.m_skinData.hurt_Y then
        cc.Director:getInstance():getEventDispatcher():setEnabled( true )
        self:passWar()
        lpScheduler:setTimeScale(1)
        return
    end
    -- local x,y = character : getLocationXY()
    -- local z   = character : getLocationZ()
    -- self.m_deadSpr : setPosition(x,y+z)
    self.m_deadSpr : setPosition(self.winSize.width*0.5,self.winSize.height*0.5)
    self.m_deadSpr : setAnimation(0,"idle",false)
    -- self.m_lpCharacterContainer : addChild(self.m_deadSpr)

    self.m_lpScene:addChild(self.m_deadSpr,100)

    local function onActionCallFunc()
            lpScheduler:setTimeScale(1)
    end
    local function deleteFunc()
        self.m_deadSpr : removeFromParent(true)
        self.m_deadSpr = nil
        self:passWar()
        cc.Director:getInstance():getEventDispatcher():setEnabled( true )    
    end
    
    self.m_lpCharacterContainer : runAction(cc.Sequence:create(cc.DelayTime:create(2.1),cc.CallFunc:create(deleteFunc)))

    self.m_lpCharacterContainer : runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(onActionCallFunc)))
    lpScheduler:setTimeScale(0.1)
    print("2CStage.slowMotion============>>>")
end

function CStage.slowMotionDead( self )
    if self.m_slowMotion then
        return
    end
    self.m_slowMotion=true
    self.m_deadlineTime=nil

    local lpScheduler = cc.Director:getInstance():getScheduler()
    lpScheduler:setTimeScale(0.1)
    local function onActionCallFunc()
        lpScheduler:setTimeScale(1)
        print("----------------->3",self.m_sceneType)
        if self.m_sceneType ==  __Const.CONST_MAP_TYPE_COPY_NORMAL
                or self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_HERO
                or self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_FIEND
                or self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_FIGHTERS
                or self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_ROAD 
                or self.m_sceneType == __Const.CONST_MAP_CLAN_DEF_TIME2 then
                self:copyLose()
        elseif self.m_sceneType == __Const.CONST_MAP_TYPE_KOF or self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_MONEY then
            self:passWar() 
        end
    end
    self.m_battleViw:showDead(self.m_lpUIContainer)
    self.m_lpCharacterContainer : runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(onActionCallFunc)))
end

function CStage.showPlayerLowHP(self)
    if self.redHurt==nil then
        self.redHurt= cc.Sprite:createWithSpriteFrameName("battle_role_hp_warning.png")
        self.redHurt:setPosition(self.winSize.width*0.5,self.winSize.height*0.5)
        self.m_lpScene:addChild(self.redHurt,10001)
        self.redHurt:setScaleX(self.winSize.width/240)
        self.redHurt:setScaleY(self.winSize.height/240)
    else
        self.redHurt:stopAllActions()
    end
    
    local function callFun()
        if self.redHurt~=nil then
            self.redHurt:removeFromParent(true)
            self.redHurt=nil
        end
    end
    self.redHurt:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(cc.FadeIn:create(0.25),cc.FadeOut:create(0.25)),4),cc.CallFunc:create(callFun)))
end

--{副本失败}
function CStage.copyLose( self )
    print("CStage.copyLose")
    local msg = REQ_SCENE_DIE()
    __Network:send(msg)
    
    self.sendMsg=msg
end

function CStage.failWar(self)
    local _ackMsg = {res=0}
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self:addMessageView(view:create())
end

function CStage.addGoNextCheckPointTips(self)
    self.m_battleViw:addGoNextCheckPointTips( self.m_lpUIContainer )
end

function CStage.removeGoNextCheckPointTips(self)
    self.m_battleViw:removeGoNextCheckPointTips( self.m_lpUIContainer )
end

function CStage.getNextCheckPoint( self )
    return __StageXMLManager:getXMLScenesCheckpoint(self:getScenesID(),self:getCheckPointID()+1)
end

function CStage.runNextCheckPoint( self )
    self:removeGoNextCheckPointTips()

    local nextCheckpointId=self:getCheckPointID()+1
    self:setCheckPointID(nextCheckpointId)

    self.m_canJump = nil
    
    --多人副本
    if self.m_sceneType~=__Const.CONST_MAP_TYPE_COPY_MULTIPLAYER 
        and self.m_sceneType~=__Const.CONST_MAP_CLAN_DEFENSE then

        local plotData=nil
        if self:getNextCheckPoint()==nil then
            plotData=self:checkMapPlot(__Const.CONST_DRAMA_ENCOUNTER)
        end
        local hasPlot=plotData~=false and plotData~=nil
        if self.m_plotFirstGame~=nil then
            self.m_plotFirstGame:gotoNextCheckPoint()
            local scenesID=self:getScenesID()
            __StageXMLManager:addMonster(scenesID,nextCheckpointId,hasPlot)
            self.m_plotFirstGame:addMonsterEnd()
        else
            local scenesID=self:getScenesID()
            __StageXMLManager:addMonster(scenesID,nextCheckpointId,hasPlot)
        end

        if plotData then
            self:runMapPlot(plotData)
        end
    end
end

function CStage.checkNextCheckPoint(self)
    if self.m_sceneType== __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER or self.m_sceneType == __Const.CONST_MAP_CLAN_DEFENSE then
        return
    end
    
    if __CharacterManager:isMonsterEmpty() == true then
        
        if self.m_nMapmx ~= nil then
            self.m_canJump = true
        end

        local nextXmlCheckpoint=self:getNextCheckPoint()
        --准备进入下个点
        if nextXmlCheckpoint ~=nil and self.m_lpPlay~=nil then
            local scenesID=self:getScenesID()
            local isBoss=__StageXMLManager:checkBossMonster(scenesID,self.m_nCheckPointID+1)

            if isBoss then --and not self.m_plotFirstGame 
                print("boss出来了")
                self.m_battleViw:addBossWaring(self.m_lpUIContainer)
            else
                self.isGoingNextCheckPoint=true
            end
            if self.m_plotFirstGame then
                self.m_plotFirstGame:autoGoNextCheckPoint()
            else
                self:addGoNextCheckPointTips()
            end
            
            -- self.m_nRealMaplx = nextXmlCheckpoint.lx
            self.m_nMapBornX = nextXmlCheckpoint.born_x
        end
    end
end

function CStage.isLastMonster(self)
    if self:getNextCheckPoint()~=nil then
        return false
    end
    
    local teamID=_G.GPropertyProxy:getMainPlay():getTeamID()
    local monstersArray = __CharacterManager.m_lpMonsterArray
    for _,monster in pairs(monstersArray) do
        if monster:getProperty():getTeamID()~=teamID and monster.m_nHP>0 then
            return false
        end
    end
    return true
end

function CStage.passWar( self )
    print("1CStage.passWar======================>>>")
    if self.m_isPassWar==true then
        return
    end
    self.m_isPassWar=true
    self.m_deadlineTime=nil
    
    local sceneType = self.m_sceneType
    if sceneType==__Const.CONST_MAP_TYPE_CHALLENGEPANEL or
        sceneType == __Const.CONST_MAP_TYPE_BOSS or
        sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS or
        sceneType == __Const.CONST_MAP_TYPE_CLAN_BOSS or 
        sceneType == __Const.CONST_MAP_CLAN_DEFENSE or
        sceneType == __Const.CONST_MAP_CLAN_WAR or
        sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then
        return
    end
    
    if sceneType==__Const.CONST_MAP_TYPE_KOF then
        local view=require("mod.map.UIBattleResult")(self.m_resultData)
        self:addMessageView(view:create())
        return
    end
    
    local function local_finishCopy()
        self:finishCopy()
    end
    --通关 发放奖励之类的
    local plotData=self:checkMapPlot(__Const.CONST_DRAMA_FINISHE)
    if plotData then
        self:runMapPlot(plotData,local_finishCopy)
        return
    end

    self:finishCopy()
    -- end
    print("2CStage.passWar======================>>>")
end

function CStage.addHitTimes( self )
    self.hit_times=self.hit_times or 0
    self.hit_times = self.hit_times + 1
end

function CStage.addMonsHp( self, _hp )
    self.mons_hp = self.mons_hp + _hp
    if self.m_sceneType == _G.Const.CONST_MAP_TYPE_THOUSAND or self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_MONEY then
        -- 防止数据(self.mons_hp)被修改，加个隐式的参数保存
        self.m_thousandHurtMonsterHp=self.m_thousandHurtMonsterHp or 0
        self.m_thousandHurtMonsterHp=self.m_thousandHurtMonsterHp+_hp*10
        self : IkkiTousen_showhp(self.m_thousandHurtMonsterHp/10)
    end
end
function CStage.getMonsHp(self)
    return self.mons_hp
end

function CStage.finishCopy( self )
    print("CStage.finishCopy ",debug.traceback())
    local property=_G.GPropertyProxy.m_lpMainPlay
    local time=0
    if self.m_battleViw.m_conditionTimes~=nil then
        time=(self.m_lastCountTime-self.m_battleViw.m_conditionTimes)*0.001-self.m_plotUseTime
        time=math.floor(time)
    end
    local sceneType = self.m_sceneType
    if sceneType== __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER or
        sceneType == __Const.CONST_MAP_TYPE_KOF then
        
        local msg = REQ_COPY_NOTICE_OVER()
        msg : setArgs(self.hit_times, self.carom_times,self.mons_hp,time,self.m_sceneId)
        __Network:send(msg)
        
        self.sendMsg=msg
        return
    elseif sceneType==__Const.CONST_MAP_TYPE_COPY_NORMAL
        or sceneType==__Const.CONST_MAP_TYPE_COPY_FIEND
        or scenesType==__Const.CONST_MAP_TYPE_COPY_HERO then
        time=self.m_battleViw:getNormalCopyRemainingTimes() or 0
    end
    
    local nCount=__CharacterManager:getPartnerCount()
    if self.m_lpPlay.m_nHP>0 then
        nCount=nCount+1
    end

    if self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_ROAD then
        local deadTimes=0
        if self.m_lpPlay.m_isRebornYet then
            deadTimes=1
        end
        self.carom_times=deadTimes
        self.mons_hp=self.m_lpPlay.m_nHP
        self.m_lpPlay.m_hpUP=nil
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_THOUSAND or self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_MONEY then
        if self.m_thousandHurtMonsterHp then
            self.mons_hp=self.m_thousandHurtMonsterHp/10
        end
    end

    local md5Key=self:getMd5Key({self.carom_times,self.mons_hp,time})
    local msg=REQ_COPY_NEW_NOTICE_OVER()

    msg:setArgs(nCount,self.carom_times,self.mons_hp,time,md5Key,self.m_sceneId)
    __Network:send(msg)

    self:removeKeyBoard()

    self.m_copyPassTimes=_G.TimeUtil:getTotalSeconds()
    print("CStage.finishCopy ===>nCount=",nCount)
    
    self.sendMsg=msg
end

function CStage.getMapData(self)
    return self.m_lpMapData
end

function CStage.showMoveArea(self)
    if self.m_moveAreaDraw~=nil then
        self.m_moveAreaDraw:setVisible(true)
        return
    end

    self.m_moveAreaDraw=cc.DrawNode:create()
    local moveData=self.m_lpMapData.data.move
    local dataCount=#moveData
    for i=1,dataCount do
        local data=moveData[i]
        local ltp={x=data.x,y=data.ty}
        local lbp={x=data.x,y=data.by}
        local rtp,rbp
        if i==dataCount then
            rtp={x=self.m_nMaprx,y=data.ty}
            rbp={x=self.m_nMaprx,y=data.by}
        else
            data=moveData[i+1]
            rtp={x=data.x,y=data.ty}
            rbp={x=data.x,y=data.by}
        end
        local pointArray={ltp,rtp,rbp,lbp}
        self.m_moveAreaDraw:drawSolidPoly(pointArray,4,cc.c4f(0.6,0.2,0.3,0.4))
    end
    self.m_lpMapContainer:addChild(self.m_moveAreaDraw,1)
end
function CStage.hideMoveArea(self)
    if self.m_moveAreaDraw~=nil then
        self.m_moveAreaDraw:setVisible(false)
    end
end

function CStage.getMapLimitHeight(self,x)
    local maxY=300
    local minY=20
    -- do return maxY,minY end
    local moveData=self.m_lpMapData.data.move
    local dataCount=#moveData
    -- for i=1,dataCount do
    --     local data=moveData[i]
    --     if x>data.x and (moveData[i+1]==nil or x<moveData[i+1].x) then
    --         maxY=data.ty
    --         minY=data.by
    --         break
    --     end
    -- end
    -- do return maxY,minY end
    for i=1,dataCount do
        local data=moveData[i]
        if moveData[i+1]==nil then
            maxY=data.ty
            minY=data.by
            break
        end
        local nextData=moveData[i+1]
        if x>data.x and x<nextData.x then
            local subTy=data.ty-nextData.ty
            local subBy=data.by-nextData.by
            local subX=nextData.x-data.x
            local scaX=(x-data.x)/subX
            local addTy=scaX*subTy
            local addBy=scaX*subBy
            if subTy>0 then
                maxY=nextData.ty+subTy-addTy
            else
                maxY=data.ty-addTy
            end
            if subBy>0 then
                minY=nextData.by+subBy-addBy
            else
                minY=data.by-addBy
            end
            break
        end

    end
    
    return maxY,minY
end

-- function CStage.addMap( self, _lpMap )
--     self : removeMap( _lpMap )
--     self.m_lpMapContainer : addChild( _lpMap )
-- end

-- function CStage.removeMap( self, _lpMap )
--     self.m_lpMapContainer : removeChild( _lpMap )
-- end

-- function CStage.convertStageSpace( self, _ccpPos )
--     --转换成舞台坐标
--     return self.m_lpContainer : convertToNodeSpace( _ccpPos )
-- end

function CStage.createMapSprite(self,_container, _path,x,y,_zOrder,_isFarBg)
    if _G.FilesUtil:check(_path) == false then
        CCMessageBox("没有地图图片，找策划".._path, "Error!")
        print("没有地图图片:".._path)
        return false
    end

    local function show()
        local nPos=cc.p(x,y)
        local mapSprite=cc.Sprite:create(_path)
        mapSprite:setPosition(nPos)
        mapSprite:setAnchorPoint(cc.p(0,0))
        _container:addChild(mapSprite,_zOrder or 0)

        self.m_mapSpriteArray[#self.m_mapSpriteArray+1]={node=mapSprite,pos=nPos,size=mapSprite:getContentSize(),isFarBg=_isFarBg}
    end
    cc.Director:getInstance():getTextureCache():addImageAsync(_path,show)
end

function CStage.createMapSpine(self,_container,_path,x,y,_zOrder)
    local mapSpine=_G.SpineManager.createSpine(_path)
    if mapSpine==nil then
        CCMessageBox("没有地图图片，找策划".._path, "Error!")
        print("没有地图图片:".._path)
        return false
    end
    local nPos=cc.p(x,y)
    mapSpine:setAnimation(0, "idle", true)
    mapSpine:setPosition(nPos)
    _container:addChild(mapSpine,_zOrder or 0)
    self.m_mapSpineArray[#self.m_mapSpineArray+1]={node=mapSpine,pos=nPos,size=mapSpine:getSkeletonSize()}
end

function CStage.createMapGaf(self,_container,_path,x,y,_zOrder)
    if not _G.FilesUtil:check(_path) then
        CCMessageBox("没有地图图片，找策划".._path, "Error!")
        print("没有地图图片:".._path)
        return false
    end
    local tempGafAsset=gaf.GAFAsset:create(_path)
    local tempObj=tempGafAsset:createObject()
    local nPos=cc.p(x,y)
    tempObj:setLooped(true,false)
    tempObj:start()
    tempObj:setPosition(nPos)
    _container:addChild(tempObj,_zOrder or 0)
end

function CStage.createMapAdorn(self,adornData,_container,_zOrder)
    local sFormat=string.format
    for i=1,#adornData do
        local dataMap=adornData[i]
        local szPath
        if dataMap.type == "spine" then
            szPath=sFormat("map/%s",dataMap.name)
            self:createMapSpine(_container,szPath,dataMap.x,dataMap.y,_zOrder or i)
        elseif dataMap.type == "gaf" then
            szPath=sFormat("map/%s.gaf",dataMap.name)
            self:createMapGaf(_container,szPath,dataMap.x,dataMap.y,_zOrder or i)
        else
            szPath=sFormat("map/%s.%s",dataMap.name,dataMap.type)
            self:createMapSprite(_container,szPath,dataMap.x,dataMap.y,_zOrder or i)
        end
    end
end
--坠落门穴
function CStage.createRollBg( self )
    self.m_loopMap = {}
    local nData=self.m_lpMapData.data.bg
    for j=1,2 do
        self.m_loopMap[j] = cc.Node:create()
        for i=1,#nData do
            local dataMap=nData[i]
            local szPath=string.format("map/%s.%s",dataMap.name,dataMap.type)
            self:createMapSprite(self.m_loopMap[j],szPath,dataMap.x,dataMap.y)
        end
        self.m_lpMapDisContainer:addChild(self.m_loopMap[j])
        self.m_loopMap[j]:setPosition(0,(j-1)*-640)
    end
    local num = 640 % self.m_farMapSpeed
    local startY = 0
    local endY = 640-num
    local function onEnterFrame()
        local x,y = self.m_lpMapDisContainer:getPosition()
        if y == endY then
            self.m_lpMapDisContainer:setPosition(x,startY)
            startY = (endY+self.m_farMapSpeed-640)%self.m_farMapSpeed
            endY   = 640-(640-startY)%self.m_farMapSpeed

        else
            self.m_lpMapDisContainer:setPosition(x,y+2)
        end
    end
    self.m_loopMapSchedule=_G.Scheduler:schedule(onEnterFrame,0.02)
    self.m_zOrder = -1

    local pMath=gc.MathGc
    local function c()
        local timeIntervel = 0.7*pMath:random_0_1()+0.2
        local dir    = pMath:random_0_1()>0.5 and 1 or -1 
        local deltaX = 15*pMath:random_0_1()*dir
        local deltaY = -(5+10*pMath:random_0_1())
        local move1  = cc.MoveBy:create(timeIntervel,{x=deltaX,y=deltaY})
        local move2  = cc.MoveTo:create(timeIntervel,{x=0,y=0})
        local fun    = cc.CallFunc:create(c)
        self.m_lpMapContainer:runAction(cc.Sequence:create(move1,move2,fun))
        self.m_lpCharacterContainer:runAction(cc.Sequence:create(move1:clone(),move2:clone()))

    end
    c()
end
--开场副本
function CStage.createRollStarBg( self )
    self.m_loopMap = {}
    local nData=self.m_lpMapData.data.bg
    for j=1,3 do
        self.m_loopMap[j] = cc.Node:create()
        for i=1,#nData do
            local dataMap=nData[i]
            local szPath=string.format("map/%s.%s",dataMap.name,dataMap.type)
            self:createMapSprite(self.m_loopMap[j],szPath,dataMap.x,dataMap.y)
        end
        self.m_lpMapDisContainer:addChild(self.m_loopMap[j])
        self.m_loopMap[j]:setPosition((j-1)*1200,0)
    end
    local num = 1200 % self.m_farMapSpeed
    local startX = 0
    local endX = -1200+self.m_farMapSpeed
    local function onEnterFrame()
        local x = self.m_lpMapDisContainer:getPosition()
        if x == endX then
            self.m_lpMapDisContainer:setPosition(startX,0)
            -- startX = -((endX+self.m_farMapSpeed-1200)%self.m_farMapSpeed)
            -- endX   = -(1200-(1200+startX)%self.m_farMapSpeed)
        else
            self.m_lpMapDisContainer:setPosition(x-self.m_farMapSpeed,0)
        end
    end
    self.m_loopMapSchedule=_G.Scheduler:schedule(onEnterFrame,0.02)
    self.m_disMapNoMove=true
end

function CStage.loadDataMap(self)
    if self.m_lpMapData.data~=nil and self.m_lpMapData.data.map~=nil then
        local sFormat=string.format
        local nData=self.m_lpMapData.data.map
        for i=1,#nData do
            local dataMap=nData[i]
            local szPath=sFormat("map/%s.%s",dataMap.name,dataMap.type)
            self:createMapSprite(self.m_lpMapContainer,szPath,dataMap.x,dataMap.y)
        end
        print("=======a=sd=asd=as=d=asd=a===>>>>",-self:getMapViewlx())
        self.m_lpContainer:setPosition(-self:getMapViewlx(),0)
    else
        print("map error self.m_lpMapData.data.map == nil  ",self.m_lpMapData.data)
    end
end

function CStage.loadDataBgMap(self)
    if self.m_lpMapData.data~=nil and self.m_lpMapData.data.bg~=nil then
        local sFormat=string.format
        local nData=self.m_lpMapData.data.bg
        for i=1,#nData do
            local dataMap=nData[i]
            local szPath=sFormat("map/%s.%s",dataMap.name,dataMap.type)
            self:createMapSprite(self.m_lpMapDisContainer,szPath,dataMap.x,dataMap.y,0,true)
        end
    end
end

function CStage.loadMapAdorn(self)
    if self.m_lpMapData.data~=nil then
        if self.m_lpMapData.data.topside~=nil then
            local adornData = self.m_lpMapData.data.topside
            self:createMapAdorn(adornData,self.m_lpMapNearContainer)
        end
        if self.m_lpMapData.data.before~=nil then
            local adornData = self.m_lpMapData.data.before
            self.m_zOrder = self.m_zOrder or 10
            self:createMapAdorn(adornData,self.m_lpMapContainer,self.m_zOrder)
        end
    -- else
    --     print("lua error self.m_lpMapData.data == nil",self.m_lpMapData.data)
    end
end

function CStage.moveArea2(self,_duration,_isInit)
    local mainCharacter=nil
    if self.m_lpPlay and self.m_lpPlay.m_lpContainer then
        mainCharacter=self.m_lpPlay
    elseif self.m_survival and self.m_survival.m_lpContainer then
        mainCharacter=self.m_survival
    else
        return
    end

    local mainX,mainY=mainCharacter:getLocationXY()
    local mainScale=mainCharacter:getScaleX()
    if self.__movePlayer==mainCharacter and mainX==self.__movePlayerX and mainScale==self.__movePlayerScaleX then
        if not self.__isMapNeedMove then
            if self.m_isCity then
                if self.__isHandleInterval then
                    _G.SysInfo:setGameIntervalLow()
                else
                    self.__isHandleInterval=true
                end
            end
            return
        end
    end

    self.__movePlayer=mainCharacter
    self.__movePlayerX=mainX
    self.__movePlayerScaleX=mainScale

    local winSize =self.winSize
    local midWidth=winSize.width*0.5
    local mapX=self.m_lpContainer:getPositionX()
    local characterWinPosX=mainX+mapX

    local lx = self : getMapViewlx()
    local rx = self : getMapViewrx()

    local moveMapX =mapX
    if mainX<self.winSizeLPiece then
        moveMapX=0
    elseif mainX>(rx - (winSize.width - self.winSizeRPiece)) then
        moveMapX=-rx+winSize.width
    else
        if mainScale>0 then
            moveMapX=-mainX+self.winSizeLPiece
        else
            moveMapX=-mainX+self.winSizeRPiece
        end
    end

    local rMaxX=-(rx - winSize.width)
    moveMapX=moveMapX<rMaxX and rMaxX or moveMapX
    moveMapX=moveMapX>-lx and -lx or moveMapX
    -- print("moveArea==========>>>>>>>>",moveMapX,self.m_nMapBaseY)

    if not _isInit then
        self.__isMapNeedMove=false
        local subMap=mapX-moveMapX
        local tempWid=_duration*900
        if math.abs(subMap)>tempWid then
            if subMap>0 then
                moveMapX=mapX-tempWid
            else
                moveMapX=mapX+tempWid
            end
            self.__isMapNeedMove=true
        end
    end

    if moveMapX==mapX then return end
    self.__isHandleInterval=false
    self.m_lpContainer:setPosition(moveMapX,self.m_nMapBaseY)

    self:autoHideCharacter()

    if self.m_blackSkillBg~=nil then
        local _,y=self.m_blackSkillBg:getPosition()
        self.m_blackSkillBg:setPosition(-moveMapX-500,y)
    end
    if self.m_farMapSpeed<=0 then
        local farMapX =self.m_lpMapData.speedRatio*moveMapX
        self.m_lpMapDisContainer:setPosition(farMapX,0)
    else
        if self.m_disMapNoMove then return end
        local x,y = self.m_lpMapDisContainer:getPosition()
        self.m_lpMapDisContainer:setPosition(moveMapX,y)
    end

    if self.m_isCity then
        local tempLx=-moveMapX
        local tempRx=-moveMapX+self.winSize.width
        for i=1,#self.m_mapSpineArray do
            local tempT=self.m_mapSpineArray[i]
            local nX=tempT.pos.x
            if nX+tempT.size.width<tempLx or nX>tempRx then
                tempT.node:setVisible(false)
            else
                tempT.node:setVisible(true)
            end
        end
        _G.SysInfo:setGameIntervalHigh()
    end
end
function CStage.moveArea3(self,_duration,_isInit)
    if self.m_slowMotionMapPos then return end
    
    local mainCharacter=nil
    if self.m_lpPlay and self.m_lpPlay.m_lpContainer then
        mainCharacter=self.m_lpPlay
    elseif self.m_survival and self.m_survival.m_lpContainer then
        mainCharacter=self.m_survival
    else
        return
    end

    local mainX,mainY=mainCharacter:getLocationXY()
    local mainScale=mainCharacter:getScaleX()
    if self.__movePlayer==mainCharacter and mainX==self.__movePlayerX and mainScale==self.__movePlayerScaleX then
        if self.m_isCity then
            if not self.__movePlayer.m_lpMovePos then
                _G.SysInfo:setGameIntervalLow()
            end
        end
        return
    end

    self.__movePlayer=mainCharacter
    self.__movePlayerX=mainX
    self.__movePlayerScaleX=mainScale

    local winSize =self.winSize
    local midWidth=winSize.width*0.5
    local mapX=self.m_lpContainer:getPositionX()
    local characterWinPosX=mainX+mapX

    local lx = self : getMapViewlx()
    local rx = self : getMapViewrx()

    local moveMapX =mapX
    if mainX<lx+winSize.width*0.5 then
        moveMapX=lx
    elseif mainX>(rx - winSize.width*0.5) then
        moveMapX=-rx+winSize.width
    else
        moveMapX=-mainX+winSize.width*0.5
    end

    -- local rMaxX=-(rx - winSize.width)
    -- moveMapX=moveMapX<rMaxX and rMaxX or moveMapX
    -- moveMapX=moveMapX>-lx and -lx or moveMapX
    -- print("moveArea==========>>>>>>>>",moveMapX,self.m_nMapBaseY)

    if moveMapX==mapX then return end
    self.m_lpContainer:setPosition(moveMapX,self.m_nMapBaseY)

    if self.m_blackSkillBg~=nil then
        local _,y=self.m_blackSkillBg:getPosition()
        self.m_blackSkillBg:setPosition(-moveMapX-500,y)
    end
    if self.m_farMapSpeed<=0 then
        local farMapX =self.m_lpMapData.speedRatio*moveMapX
        self.m_lpMapDisContainer:setPosition(farMapX,0)
    else
        if self.m_disMapNoMove then return end
        local x,y = self.m_lpMapDisContainer:getPosition()
        self.m_lpMapDisContainer:setPosition(moveMapX,y)
    end

    if self.m_isCity then
        local tempLx=-moveMapX
        local tempRx=-moveMapX+self.winSize.width
        for i=1,#self.m_mapSpineArray do
            local tempT=self.m_mapSpineArray[i]
            local nX=tempT.pos.x
            if nX+tempT.size.width<tempLx or nX>tempRx then
                tempT.node:setVisible(false)
            else
                tempT.node:setVisible(true)
            end
        end
        _G.SysInfo:setGameIntervalHigh()

        self:autoHideCharacter()
    end
end

function CStage.moveArea( self, _myPosX, _myPosY , _preX, _myScale, _isInit)
    if self.m_lpContainer==nil or self.m_slowMotionMapPos~=nil then
        return
    end

    self:moveAreaStop()
    
    local winSize =self.winSize
    local midWidth=winSize.width*0.5
    local mapX = self.m_lpContainer:getPositionX()
    local characterWinPosX=_myPosX+mapX

    local lx = self : getMapViewlx()
    local rx = self : getMapViewrx()
    local moveMapX =mapX

    if _myPosX<self.winSizeLPiece then
        moveMapX=0
    elseif _myPosX>(rx - (winSize.width - self.winSizeRPiece)) then
        moveMapX=-rx+winSize.width
    else
        if _myScale>0 then
            moveMapX=-_myPosX+self.winSizeLPiece
        else
            moveMapX=-_myPosX+self.winSizeRPiece
        end
    end

    local rMaxX=-(rx - winSize.width)
    moveMapX=moveMapX<rMaxX and rMaxX or moveMapX
    moveMapX=moveMapX>-lx and -lx or moveMapX
    -- print("moveArea==========>>>>>>>>",moveMapX,self.m_nMapBaseY)

    if not _isInit then
        local subMap=mapX-moveMapX
        if math.abs(subMap)>40 then
            if subMap>0 then
                moveMapX=mapX-35
            else
                moveMapX=mapX+35
            end
        end
    end
    self.m_lpContainer:setPosition(moveMapX,self.m_nMapBaseY)

    if self.m_blackSkillBg~=nil then
        local _,y=self.m_blackSkillBg:getPosition()
        self.m_blackSkillBg:setPosition(-moveMapX-500,y)
    end
    if self.m_farMapSpeed<=0 then
        local farMapX =self.m_lpMapData.speedRatio*moveMapX
        self.m_lpMapDisContainer:setPosition(farMapX,0)
    else
        if self.m_disMapNoMove then return end
        local x,y = self.m_lpMapDisContainer:getPosition()
        self.m_lpMapDisContainer:setPosition(moveMapX,y)
    end

    if self.m_isCity then
        local tempLx=-moveMapX
        local tempRx=-moveMapX+self.winSize.width
        for i=1,#self.m_mapSpineArray do
            local tempT=self.m_mapSpineArray[i]
            local nX=tempT.pos.x
            if nX+tempT.size.width<tempLx or nX>tempRx then
                tempT.node:setVisible(false)
            else
                tempT.node:setVisible(true)
            end
        end
    end
end

function CStage.moveAreaStop(self)
    if self.m_isMapGradually1 then
        self.m_isMapGradually1=nil
        self.m_lpContainer:stopActionByTag(12332)
    end
    if self.m_isMapGradually2 then
        self.m_isMapGradually2=nil
        self.m_lpMapDisContainer:stopActionByTag(12333)
    end
end

function CStage.moveAreaGradually( self, _myPosX, _myPosY ,_myScale )
    if self.m_lpContainer==nil or self.m_slowMotionMapPos~=nil or self.m_farMapSpeed>0 then
        return
    end

    -- print("CCCCCCCCCCCCCCCSSSSSSSSSS====>>>>",debug.traceback())

    self:moveAreaStop()
    
    local winSize =self.winSize
    local mapX,mapY = self.m_lpContainer:getPosition()
    local characterWinPosX=_myPosX+mapX

    local lx = self : getMapViewlx()
    local rx = self : getMapViewrx()
    local moveMapX =mapX

    if _myScale>0 then
        if characterWinPosX<self.winSizeLPiece then return end

        moveMapX=-_myPosX+self.winSizeLPiece
    else
        if characterWinPosX>self.winSizeRPiece then return end

        moveMapX=-_myPosX+self.winSizeRPiece
    end

    local rMaxX=-(rx - winSize.width)
    moveMapX=moveMapX<rMaxX and rMaxX or moveMapX
    moveMapX=moveMapX>-lx and -lx or moveMapX

    local subX=math.abs(moveMapX - mapX)
    if subX==0 then return end

    local nSpeed=self.m_isCity and 500 or 700
    local nTime=subX/700

    self.m_isMapGradually1=true
    local function nFun1()
        self.m_isMapGradually1=nil
    end

    local nMove=cc.MoveTo:create(nTime,{x=moveMapX,y=mapY})
    local nAct=cc.Sequence:create(nMove,cc.CallFunc:create(nFun1))
    nAct:setTag(12332)
    self.m_lpContainer:runAction(nAct)

    if self.m_farMapSpeed<=0 then
        local farMapX=self.m_lpMapData.speedRatio*moveMapX

        self.m_isMapGradually2=true
        local function nFun2()
            self.m_isMapGradually2=nil
        end
        local nMove=cc.MoveTo:create(nTime,{x=farMapX,y=mapY})
        local nAct=cc.Sequence:create(nMove,cc.CallFunc:create(nFun2))
        nAct:setTag(12333)
        self.m_lpMapDisContainer:runAction(nAct)
    -- else
    --     self.m_lpMapDisContainer:runAction(nAct)
    end
end

function CStage.autoHideCharacter(self)
    local _mapX=self.m_lpContainer:getPositionX()

    local nPosRX=-_mapX+self.winSize.width
    local nWidth=80
    local tempLx=-_mapX-nWidth
    local tempRx=nPosRX+nWidth
    for _,tempCharacter in pairs(__CharacterManager.m_lpNpcArray) do
        if tempCharacter.m_nLocationX<tempLx or tempCharacter.m_nLocationX>tempRx then
            if not tempCharacter.__isHide then
                tempCharacter.m_lpContainer:setVisible(false)
                tempCharacter.__isHide=true
            end
        elseif tempCharacter.__isHide then
            tempCharacter.m_lpContainer:setVisible(true)
            tempCharacter.__isHide=false
        end
    end

    for _,tempCharacter in pairs(__CharacterManager.m_lpPetArray) do
        if tempCharacter.m_nLocationX<tempLx or tempCharacter.m_nLocationX>tempRx then
            if not tempCharacter.__isHide then
                tempCharacter.m_lpContainer:setVisible(false)
                tempCharacter.__isHide=true
            end
        elseif tempCharacter.__isHide then
            tempCharacter.m_lpContainer:setVisible(true)
            tempCharacter.__isHide=false
        end
    end

    nWidth=100
    tempLx=-_mapX-nWidth
    tempRx=nPosRX+nWidth
    for _,tempCharacter in pairs(__CharacterManager.m_lpPlayerArray) do
        if tempCharacter.m_nLocationX<tempLx or tempCharacter.m_nLocationX>tempRx then
            if not tempCharacter.__isHide then
                tempCharacter.m_lpContainer:setVisible(false)
                tempCharacter.__isHide=true
            end
        elseif tempCharacter.__isHide then
            tempCharacter.m_lpContainer:setVisible(true)
            tempCharacter.__isHide=false
        end
    end
end

function CStage.onRoleMove( self, _lpCharacter, _fx, _fy, dir, _isStop)
    local move_type=nil
    dir=dir or 0
    dir=dir<0 and 0 or dir

    if _isStop==true then
        move_type = __Const.CONST_MAP_MOVE_STOP
    else
        move_type = __Const.CONST_MAP_MOVE_MOVE
    end

    _fx = _fx <= 0 and 0 or _fx
    _fy = _fy <= 0 and 0 or _fy
    
    local uid =_lpCharacter:getID()

    if self.m_sceneType==__Const.CONST_MAP_TYPE_KOF and _G.IS_PVP_NEW_DDX then
        self.m_moveMsg=self.m_moveMsg or REQ_WAR_PVP_MOVE()
        self.m_moveMsg:setArgs(uid,move_type,dir,_lpCharacter.m_nLocationX,_lpCharacter.m_nLocationY,_fx,_fy)
        __Network:send(self.m_moveMsg)
        return
    end

    local characterType=_lpCharacter:getType()
    if characterType==__Const.CONST_PARTNER or characterType==__Const.CONST_TEAM_HIRE then
        uid=_lpCharacter.m_partnerId
    end
    -- print(">>>>>>>>>>>>>>>> CStage.onRoleMove  >>>>>   ",uid,dir,debug.traceback())
    self.m_moveMsg=self.m_moveMsg or REQ_SCENE_MOVE()
    self.m_moveMsg:setArgs(characterType,uid,move_type,_fx,_fy,dir)
    __Network:send(self.m_moveMsg)
end

function CStage.checkNPCZone(self,_npcId,_fx,_fy,_isTouch)
    local npcList=__CharacterManager.m_lpNpcArray
    for _,npcCharacter in pairs(npcList) do
        if npcCharacter.npcId==_npcId then
            return npcCharacter:checkZone(_fx,_fy,_isTouch)
        end
    end
    return false
end
function CStage.checkTransportZone(self,_fx,_fy)
    local transportList=__CharacterManager:getTransport()
    for _,transporCharacter in pairs(transportList) do
        if transporCharacter:checkZone(_fx,_fy) then
            return true
        end
    end
    return false
end

function CStage.checkCollisionGoods(self,_lpCharacter,_fx,_fy)
    --检查 进入NPC区域
    if not _lpCharacter.isMainPlay then
        return
    end

    if not self.m_isCity and self.m_sceneType~=__Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        local goodsList = __CharacterManager:getGoods()
        local isExistGoods = false
        for _,goods in pairs(goodsList) do
            -- if not goods:isOthers() then
                isExistGoods=true
                local isEnter=goods:onRoleEnter(_lpCharacter)
                if isEnter==true then
                    goods:pickUp(self.m_lpPlay)
                end
            -- end
        end
        -- if isExistGoods==false then
        --     local goodsSprite=self.m_lpCharacterContainer:getChildByTag(168)
        --     if goodsSprite~=nil then
        --         goodsSprite:removeFromParent(true)
        --     end
        -- end
    end
end

function CStage.updateBossAttackPlus(self,_plusPercent)
    -- print("CStage.updateBossAttackPlus _plusPercent=",_plusPercent)
    self.m_battleViw:updateCurrentAttackPlus(_plusPercent)
    self.m_lpPlay.m_attackPlus=_plusPercent
end

--{ 副本剩余时间 }
function CStage.setRemainingTime(self,_time,_timeTips,_colorIdx)
    if _time==nil then
        self.m_deadlineTime=nil
        if self.m_lpRemainingTimeContainer~=nil then
            self.m_lpRemainingTimeContainer:removeAllChildren(true)
        end
        return
    end
    -- self.m_nRemainingTime = _time
    self.m_nTimeTips=_timeTips
    self.m_colorIdx=_colorIdx
    
    self.m_lastCountTime=_G.TimeUtil:getTotalMilliseconds()
    self.m_deadlineTime=self.m_lastCountTime+_time*1000
end

function CStage.showRemainingTime( self, _duration , _nowTime )    
    if _nowTime-self.m_lastCountTime<1000 then
        return
    end
    self.m_lastCountTime=_nowTime
    
    if self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_NORMAL
        or self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_HERO
        or self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_FIEND then
        self.m_battleViw:updateNormalCopyTimes(_nowTime)
        return
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        self.m_battleViw:updateConditionTimes(_nowTime)
        return
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_FIGHTERS or
        self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_ROAD then
        self.m_battleViw:updateFutuOutTimes(_nowTime)
        return
    end
    print("showRemainingTime========>> 4")

    local showBigNum=false
    if (self.m_sceneType==__Const.CONST_MAP_TYPE_KOF or self.m_sceneType==__Const.CONST_MAP_TYPE_CHALLENGEPANEL) and self.endTime2~=nil then
        showBigNum=true
    end

    local remainTime=self.m_deadlineTime-_nowTime
    local secondTIme=remainTime*0.001
    if self.m_lpRemainingTimeContainer==nil then
        self.m_lpRemainingTimeContainer=cc.Node:create() -- 倒计时层
        self.m_lpScene:addChild(self.m_lpRemainingTimeContainer,400)
    end
    self.m_lpRemainingTimeContainer:removeAllChildren(true)
        
    if not showBigNum then
        self.m_battleViw:showRemainingTime(secondTIme,self.m_lpRemainingTimeContainer,self.m_nTimeTips,self.m_colorIdx)
    end

    if remainTime<=0 then
        self.m_deadlineTime=nil

        self:timeOut()
    end

    if showBigNum then
        self:showRemainingBigTime(remainTime*0.001)
    end
end

function CStage.showRemainingBigTime( self,remainTime)
    local timeOfSeconds=math.ceil(remainTime)
    timeOfSeconds=timeOfSeconds<=0 and 0 or timeOfSeconds
    local stringStr=tostring(timeOfSeconds)
    local nlength = string.len( stringStr )
    if nlength <= 0 then
        return
    end
    
    local timeSprite=cc.Sprite:create()
    timeSprite:setScale(10)
    local timeWidth = 0
    local spritesList = {}
    for i=1, nlength do
        local currStr = string.sub(stringStr, i, i)
        local currStrSprName=string.format("battle_crit_hit_%s.png",currStr)
        local currSprite = cc.Sprite:createWithSpriteFrameName(currStrSprName)
        timeSprite :addChild( currSprite )
        local currSprSize = currSprite:getContentSize()
        timeWidth=timeWidth+currSprSize.width
        
        spritesList[i]=currSprite
    end
    
    x=-timeWidth*0.5
    for _,currSprite in ipairs(spritesList) do
        local currSprSize = currSprite:getContentSize()
        x=x+currSprSize.width*0.5
        currSprite:setPosition(x, 0)
        x=x+currSprSize.width*0.5
    end
    spritesList=nil
    
    
    timeSprite:setPosition(self.winSize.width*0.5,self.winSize.height*0.5)
    self.m_lpRemainingTimeContainer:addChild(timeSprite)
    timeSprite:runAction(cc.EaseBounceOut:create(cc.ScaleTo:create(0.8,3))) 
end

--{超出时间处理}
function CStage.timeOut( self )
    -- self.m_nRemainingTime = nil
    if self.isFinishCopy==true then
        self:exitCopy()
        return
    end
    
    if self.m_sceneType == __Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        if self.m_isUserPkRobot and not self.m_startUserPkRobotTime then
            self.m_startUserPkRobotTime=true
            self:setStopAI(false)
            self.endTime2=nil
            self:setRemainingTime( __Const.CONST_ARENA_BATTLE_TIME,"PK倒计时")
            
            self:addJoyStick()
            self:addKeyBoard()
            cc.Director:getInstance():getEventDispatcher():setEnabled(true)
            return
        end
        local mainPlay = self : getMainPlayer()
        mainPlay : setHP(-12345)
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_MONEY then
        local mainPlay = self : getMainPlayer()
        mainPlay : setHP(-12345)
        return
    elseif self.m_sceneType== __Const.CONST_MAP_TYPE_BOSS 
        or self.m_sceneType== __Const.CONST_MAP_TYPE_CLAN_BOSS 
        or self.m_sceneType== __Const.CONST_MAP_TYPE_CITY_BOSS
        or self.m_sceneType== __Const.CONST_MAP_TYPE_COPY_BOX then
        if self.m_lpRemainingTimeContainer~=nil then
            self.m_lpRemainingTimeContainer:removeFromParent(true)
            self.m_lpRemainingTimeContainer=nil
        end
        return
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_KOF then
        if self.endTime2~=nil then
            cc.Director:getInstance():getEventDispatcher():setEnabled(true)
            self:setStopAI(false)
            local remainingBattleTime = self.endTime2 -_G.TimeUtil:getServerTimeSeconds()
            self:setRemainingTime(remainingBattleTime,"PK结束倒计时")
            self.endTime2=nil
            self.m_stopMove=nil
            self.m_lpPlay.m_isShowState=nil

            if _G.IS_PVP_NEW_DDX then
                local function pvpFrameUpdate(_duration)
                    self:updatePVPFrame(_duration)
                end
                self.m_pvpSchedule=_G.Scheduler:schedule(pvpFrameUpdate,0)
            end
            return
        end
    elseif self.m_sceneType==__Const.CONST_MAP_CLAN_WAR then
        return
    elseif self.m_sceneType==__Const.CONST_MAP_CLAN_DEFENSE then
        return
    -- elseif self.m_sceneType==__Const.CONST_MAP_TYPE_COPY_FIGHTERS then
    --     self.m_lpPlay:setHP(0)
    --     return
    elseif self.m_sceneType==__Const.CONST_MAP_TYPE_PK_LY then
        self:lingYaoPkTimeOut()
        return
    end
    
    local passType = self:getScenesPassType()
    
    print("CStage.timeOut passType=",passType)
    
    if passType == __Const.CONST_COPY_PASS_ALIVE then
        local list = __CharacterManager:getMonster()
        for _,monsterC in pairs(list) do
            monsterC : setHP(0)
        end
    elseif passType == __Const.CONST_COPY_PASS_TIME then
        -- local mainPlay = self : getMainPlayer()
        -- mainPlay : setHP(0)
        self.m_lpPlay:setHP(-12345)
    else
        self:finishCopy()
    end
end

--{更新复活时间}
function CStage.updateBossDeadTime( self, _duration, _nowTime )
    local deadTime = self.m_nBossDeadTime
    if deadTime <= 0 then
        return
    end
    deadTime = deadTime - _duration
    deadTime = deadTime <=0 and 0 or deadTime
    self.m_battleViw : showBossDeadViewString( deadTime )
    self : setBossDeadTime( deadTime )
    if deadTime <= 0 then
        if self.m_sceneType == __Const.CONST_MAP_CLAN_WAR then
            print("[门派战]  发送复活！！！！")
            local msg = REQ_GANG_WARFARE_INITIATIVE_REC()
            __Network:send(msg)
        -- elseif self.m_sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS then 
        --     local msg=REQ_SCENE_ENTER_CITY()
        --     __Network:send(msg)
        elseif self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then
            local msg=REQ_MIBAO_REVIVE()
            msg:setArgs(0)
            __Network:send(msg)
        else
            --自动复活
            local msg=REQ_WORLD_BOSS_REVIVE()
            msg:setArgs(0)
            __Network:send(msg)
        end
    end
end

--自动PK反回
function CStage.autoPKFinish(self,_lpPlayer)
    print("CStage.autoPKFinish")
    
    local property = _G.GPropertyProxy:getChallengePanePlayInfo()
    local mainProperty = _G.GPropertyProxy:getMainPlay()
    if property ~= nil and mainProperty ~= nil then
        if mainProperty:getUid()==_lpPlayer:getID() or property:getUid()==_lpPlayer:getID() then
            self:autoPKCallback(_lpPlayer,mainProperty,property)
            --删除伙伴
            local masterProperty = mainProperty
            if property : getUid() == _lpPlayer : getID() then
                masterProperty = property
            end
            self:killPartners(masterProperty)
        end
    end
end

function CStage.killPartners(self,_property)
    local warPartner=_property:getWarPartner()
    if warPartner==nil then return end
    local indexID = tostring(_property:getUid())..tostring(warPartner:getPartner_idx())
    local tempCharacter = __CharacterManager:getCharacterByTypeAndID(__Const.CONST_PARTNER,indexID)
    if tempCharacter~=nil then
        tempCharacter:setHP(0)
    end
end

function CStage.updatePlayerAttribute(self)
    self.m_lpPlay.m_skillToVictims=nil
    if self.m_attributeAdds~=nil then
        self.m_battleViw:showAttributeAdd(self.m_lpUIContainer,self.m_attributeAdds)
    end
end

function CStage.setOtherPlayerVisible(self,_isVisible)
    if _isVisible then
        local msg = REQ_SCENE_CANCLE_SCREEN()
        __Network:send(msg)

        if self.m_isCity then
            local msgArray={
                _G.Msg.ACK_SCENE_PLAYER_LIST,
                _G.Msg.ACK_SCENE_MOVE_RECE,
                _G.Msg.ACK_SCENE_OUT,
            }
            _G.controller:regMediator(self.m_stageMediator,msgArray,{})
        end
    else
        local msg = REQ_SCENE_SCREEN_OTHER()
        __Network:send(msg)
        self:destroyOtherPlayers()

        if self.m_isCity then
            local msgArray={
                _G.Msg.ACK_SCENE_PLAYER_LIST,
                _G.Msg.ACK_SCENE_MOVE_RECE,
                _G.Msg.ACK_SCENE_OUT,
            }
            _G.controller:unMediator(self.m_stageMediator,msgArray,{})
        end
    end
end


function CStage.destroyOtherPlayers(self)
    local removePlayersList = {}
    for _,player in pairs(__CharacterManager.m_lpPlayerArray) do
        if self.m_lpPlay~= player then
            table.insert(removePlayersList,player)
        end
    end
    for _,player in pairs(__CharacterManager.m_lpCorpseArray) do
        if self.m_lpPlay~= player then
            table.insert(removePlayersList,player)
        end
    end
    
    for _,player in pairs(removePlayersList) do
        player.m_isCorpse=nil
        __CharacterManager:remove( player)
        player:releaseResource()
    end
end

function CStage.showRightHpView(self,character,bigHpViewData)
    -- print("CStage.showRightHpView==============>>>>")
    
    local container = self:getUIContainer()
    if self.m_currentCharacter==character then
        return
    end
    
    self:removeCurRightHpView()
    
    self.m_currentCharacter=character
    character.m_lpBigHp=require("mod.map.UIBigHp")()
    character.m_lpBigHpView= character.m_lpBigHp:layer(bigHpViewData)
    container:addChild(character.m_lpBigHpView)
    
    character.m_lpBigHpView:setTag(4563456)
end

function CStage.removeCurRightHpView( self,_character )
    local container = self:getUIContainer()
    
    if self.m_currentCharacter~=nil then
        if _character~=nil and _character~=self.m_currentCharacter then return end
        self.m_currentCharacter:resetBigHpData()
    end
    
    local oldBigHpView = container:getChildByTag(4563456)
    if oldBigHpView~=nil then
        oldBigHpView:removeFromParent(true)
    end
    
    self.m_currentCharacter=nil
end

function CStage.getMd5Key( self,_keyArray)
    local property  = _G.GPropertyProxy.m_lpMainPlay
    local normalStr = property:getPropertyKey()
    if _keyArray ~= nil then
        for i=1,#_keyArray do
            normalStr=normalStr.._keyArray[i]
        end
    end
    local netKeyStr = property:getBattleKey()

    print("[getMd5Key]==========>>> normalStr="..normalStr)
    print("[getMd5Key]==========>>> netKeyStr="..netKeyStr)
    -- print("[getMd5Key]==========>>> carom_times="..carom_times)
    -- print("[getMd5Key]==========>>> mons_hp="..mons_hp)

    local szKey=gc.Md5Crypto:getCopyEncryptKey(normalStr,netKeyStr)
    print("[getMd5Key]==========>>> szKey=",szKey)
    return szKey
end

function CStage.setFightModel(self,isFreeFight)
    if isFreeFight==true then
        local playerUid = self.m_lpPlay.m_nID
        self.m_lpPlay.m_property:setTeamID(playerUid)
        
        local color=_G.ColorUtil : getRGB(__Const.CONST_COLOR_RED)
        for _,gamePlayer in pairs(__CharacterManager.m_lpPlayerArray) do
            if self.m_lpPlay~=gamePlayer then
                gamePlayer:setNameColor(color)
            end
        end
    else
        local clanId = self.m_lpPlay.m_property:getClan()
        -- local playerUid = self.m_lpPlay.m_nID
        self.m_lpPlay.m_property:setTeamID(clanId)
        local color=_G.ColorUtil : getRGB(__Const.CONST_COLOR_WHITE)
        self.m_lpPlay.m_nTarget = nil        
        for _,gamePlayer in pairs(__CharacterManager.m_lpPlayerArray) do 
            if self.m_lpPlay~=gamePlayer then
                if gamePlayer.m_property :getClan() == clanId then
                    if clanId == 0 then
                        gamePlayer.m_property:setTeamID(-1)
                    else
                        gamePlayer:setNameColor(color)
                    end
                end
            end
        end
    end
    
    self.m_isFreeFight=isFreeFight
end

function CStage.autoPKCallback(self,losePlayer,rolePlayerProperty,otherPlayerProperty)
    print("CStage.autoPKCallback")
    if self.m_autoPkFinish==true then
        return
    end
    self.m_autoPkFinish=true
    
    local loserUid=losePlayer:getID()
    local roleUid =rolePlayerProperty:getUid()
    local otherUid= otherPlayerProperty:getUid()
    local ranking = otherPlayerProperty:getRank()
    print("CStage.autoPKCallback====",self.m_sceneId,__Const.CONST_ARENA_THE_ARENA_ID)
    --竞技场
    if self.m_sceneId==__Const.CONST_ARENA_THE_ARENA_ID then
        local resTemp = 1
        if loserUid == roleUid then
            resTemp = 0
            print("挑战失败!")
        else
            print("挑战成功!")
        end
        
        local md5Key=self:getMd5Key({ranking,resTemp})
        local msg = REQ_ARENA_FINISH_NEW()
        msg : setArgs(otherUid,ranking,resTemp,md5Key)
        __Network : send(msg)
        
        self.sendMsg=msg
        ---------------------------------------------------------------------------------------------------------------------------
        --抓苦工
    elseif self.m_sceneId==__Const.CONST_ARENA_JJC_MOIL_ID then
        print("抓苦工 战斗结束 发协议给后端")
        local pkType=__StageXMLManager:getScenePkType()
        if pkType~=nil then
            print("战斗类型是＝＝＝＝",pkType)
            local resTemp = 1
            if loserUid == roleUid then
                resTemp = 0
                print("挑战失败!")
            else
                print("挑战成功!")
            end
            
            local msg = REQ_MOIL_CALL_RES()
            msg       : setArgs(pkType,otherUid,resTemp)
            _G.Network  : send(msg)
            
            self.sendMsg=msg
        end      
        ---------------------------------------------------------------------------------------------------------------------------
        --美人护送
    elseif self.m_sceneId ==__Const.CONST_ARENA_JJC_ESCORT_ID then
        print("美人护送 战斗结束,发协议给后端")
        local resTemp = 1
        if loserUid == roleUid then
            resTemp = 0
            print("挑战失败!")
            
        else
            print("挑战成功!")
        end
        
        local msg = REQ_ESCORT_ROB_OVER()
        msg       : setArgs(otherUid,resTemp)
        CNetwork  : send(msg)
        
        self.sendMsg=msg
        ----------------------------------------------------------------------------------------------------------------------------
        --跨服战（大闹天宫） 
    elseif self.m_sceneId == __Const.CONST_OVER_SERVER_PEAK_ID then
        print("跨服战 战斗结束,发协议给后端")
        local resTemp = 1
        if loserUid == roleUid then
            resTemp = 0
            print("挑战失败!",resTemp)     
        else
            print("挑战成功!",resTemp)
        end
        print("zuihou----",resTemp,__StageXMLManager:getScenePkType())
        local msg = REQ_STRIDE_WAR_OVER()
        local warType = __StageXMLManager:getScenePkType()
        local serverId = __StageXMLManager:getServerId()
        -- if _G.g_HeroMeetingGoType == 1 then
        --     warType = __Const.CONST_OVER_SERVER_STRIDE_TYPE_5
        -- elseif _G.g_HeroMeetingGoType == 2 then
        --     warType = __Const.CONST_OVER_SERVER_STRIDE_TYPE_6
        -- end
        local key = self:getMd5Key({warType,resTemp})
        msg : setArgs(warType,serverId,otherUid,resTemp,key)
        _G.Network : send(msg)
        
        self.sendMsg=msg
        ----------------------------------------------------------------------------------------------------------------------------
        --巅峰之战（上清灵宝）
    elseif self.m_sceneId == __Const.CONST_OVER_SERVER_QUNYING_ID then
        local resTemp = 1
        if loserUid == roleUid then
            resTemp = 0
            print("挑战失败!",resTemp)     
        else
            print("挑战成功!",resTemp)
        end
        print("巅峰之战 战斗结束,发协议给后端", resTemp)
        local warType = __StageXMLManager:getScenePkType()
        local rank = __StageXMLManager:getServerId()
        local key  = self:getMd5Key({rank,resTemp})
        local msg  = REQ_STRIDE_SUPERIOR_OVER()
        print( "warType = ", rank, resTemp, key )
        msg : setArgs( rank, resTemp, key)
        _G.Network  : send(msg)
        
        self.sendMsg=msg
        ----------------------------------------------------------------------------------------------------------------------------
        --群雄争霸 -- 封神榜
    elseif self.m_sceneId == __Const.CONST_ARENA_JJC_WARLORDS_ID then
        print("群雄争霸 战斗结束,发协议给后端")
        local resTemp = 1
        if loserUid == roleUid then
            resTemp = 0
            print("挑战失败!",resTemp)     
        else
            print("挑战成功!",resTemp)
        end
        local msg=REQ_EXPEDIT_FINISH()
        local key = self:getMd5Key({resTemp,otherUid})
        msg:setArgs(resTemp,otherUid,key)
        _G.Network:send(msg)
        
        self.sendMsg=msg
        ----------------------------------------------------------------------------------------------------------------------------
        --英雄塔
    elseif self.m_sceneId == __Const.CONST_ARENA_JJC_HERO_TOWER_ID then
        print("英雄塔 战斗结束,发协议给后端")
        local resTemp = 1
        if loserUid == roleUid then
            resTemp = 0
            print("挑战失败!",resTemp)     
        else
            print("挑战成功!",resTemp)
        end
        local msg = REQ_FUTU_OVER()
        msg : setArgs(resTemp)
        _G.Network  : send(msg)
        
        self.sendMsg=msg
        ----------------------------------------------------------------------------------------------------------------------------        ----------------------------------------------------------------------------------------------------------------------------
        --第一门派
    elseif self.m_sceneId == __Const.CONST_MOUNTAIN_KING_MAP then
        print("第一门派 战斗结束,发协议给后端")

        local resTemp=1
        local ortherPlayer=nil
        if loserUid==roleUid then
            resTemp=0
            ortherPlayer=__CharacterManager:getPlayerByID(otherUid)
            print("挑战失败!",resTemp)     
        else
            ortherPlayer=losePlayer
            print("挑战成功!",resTemp)
        end
        local hp = ortherPlayer.m_nowHp - ortherPlayer:getHP()
        local addOrSub=hp>0 and 0 or 1 --0:扣血，1:加血

        print("hp=============>>>>",hp)
        self.m_ortherPlayerHp = hp
        local key=self:getMd5Key({resTemp,math.abs(hp)})
        local msg = REQ_HILL_FINISH()
        msg : setArgs(otherUid,resTemp,math.abs(hp),key,addOrSub)
        __Network:send(msg)
        
        self.sendMsg=msg
        ----------------------------------------------------------------------------------------------------------------------------
    else

        print("未知的自动pk")
    end
end

function CStage.autoLingYaoPKFinish(self)
    if self.m_autoPkFinish then
        return
    end
    self.m_autoPkFinish=true
    self.m_deadlineTime=nil

    local msg=REQ_LINGYAO_ARENA_OVER()
    msg.uid=self.m_lingYaoPkData.uid
    msg.rank=self.m_lingYaoPkData.rank
    msg.result1=self.m_lingYaoResultArray[1] or 2
    msg.result2=self.m_lingYaoResultArray[2] or 2
    msg.result3=self.m_lingYaoResultArray[3] or 2
    msg.key=self:getMd5Key({msg.result1,msg.result2,msg.result3})

    print("REQ_LINGYAO_ARENA_OVER====>>>>")
    for k,v in pairs(msg) do
        print(k,v)
    end

    _G.Network:send(msg)

    self.sendMsg=msg
end

function CStage.enterStageCallback(self,currentSceneType,currentSceneId,lastSceneType,lastSceneId)
    print("CStage gotoScene currentSceneType=",currentSceneType,"currentSceneId=",currentSceneId,type(currentSceneId),"lastSceneType=",lastSceneType,"lastSceneId=",lastSceneId)

    if not self.m_isCity then
        if currentSceneType == __Const.CONST_MAP_TYPE_KOF then
            cc.Director:getInstance():getEventDispatcher():setEnabled(false)
        end
        return
    end

    if _G.GLayerManager:hasSysOpen() then
        _G.g_WoYaoBianQiang=nil
        return
    end

    if _G.g_WoYaoBianQiang == true then
        --战斗失败，弹开我要变强
        print("[CStage.enterStageCallback] 战斗失败，弹开我要变强")
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_STRATEGY,nil,713,nil,nil,0.3)
        _G.g_WoYaoBianQiang = false
    elseif lastSceneType == __Const.CONST_MAP_TYPE_COPY_NORMAL
        or lastSceneType == __Const.CONST_MAP_TYPE_COPY_HERO
        or lastSceneType == __Const.CONST_MAP_TYPE_COPY_FIEND then
        if _G.g_waitToCopyId then
            local copyId=_G.g_waitToCopyId
            local copyCnf=_G.Cfg.scene_copy[copyId]
            local roleProperty=_G.GPropertyProxy:getMainPlay()
            roleProperty:setTaskInfo()
            -- roleProperty:setTaskInfo(_G.Const.CONST_TASK_TRACE_MAIN_TASK,
            --                          copyId,
            --                          copyCnf.belong_id,
            --                          0,
            --                          1,
            --                          nil)
            _G.GLayerManager :delayOpenLayer(_G.Cfg.UI_CCopyMapLayer,nil,copyCnf.belong_id,nil,nil,0.3)
            _G.g_waitToCopyId=nil
        end
    elseif lastSceneType == __Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        if lastSceneId == __Const.CONST_ARENA_JJC_MOIL_ID then --苦工战斗返回
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_MOIL,nil,true,nil,nil,0.3)
        elseif lastSceneId == __Const.CONST_ARENA_JJC_HERO_TOWER_ID then --浮屠静修战斗返回
        	_G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_JINGXIU,nil,nil,nil,nil,0.3)
        elseif lastSceneId == __Const.CONST_ARENA_JJC_ESCORT_ID then --美人护送
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_DEVIL_ESCORT,nil,nil,nil,nil,0.3)
        elseif lastSceneId == __Const.CONST_ARENA_JJC_PEAK_ID then 
            -- 巅峰之战
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_PEAK,nil,1000,nil,nil,0.3)
        elseif lastSceneId == __Const.CONST_ARENA_JJC_HERO_TOWER_ID then --英雄塔
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_HERO_TOWER,nil,nil,nil,nil,0.3)
        elseif lastSceneId == __Const.CONST_MOUNTAIN_KING_MAP then --第一门派
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_GANGS,nil,nil,4,2,0.3)
            
        elseif lastSceneId == __Const.CONST_ARENA_JJC_QUNYING_ID then
            -- 三国群英
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_SANGO,nil,nil,nil,nil,0.3)
        elseif lastSceneId == __Const.CONST_OVER_SERVER_PEAK_ID then 
            -- 大闹天宫 - 玉清元始
            print( "_G.StageXMLManager:setScenePkType() = ", __StageXMLManager:getScenePkType() )
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_WELKIN,nil,1,_G.StageXMLManager:getScenePkType(),nil,0.3)    
        elseif lastSceneId == __Const.CONST_OVER_SERVER_QUNYING_ID then 
            -- 大闹天宫 - 上清灵宝
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_WELKIN_BATTLE,nil,1,nil,nil,0.3)    
        elseif lastSceneId == __Const.CONST_ARENA_JJC_WARLORDS_ID then
            -- 群雄争霸 -- 封神榜
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_MYTH,nil,nil,nil,nil,0.3) 
        else
            _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_ARENA,nil,true,nil,nil,0.3)
        end
        
    elseif lastSceneType == __Const.CONST_MAP_TYPE_INVITE_PK then
        if lastSceneId==__Const.CONST_INVITE_PK_SENCE then
            return
        end
    elseif lastSceneType==__Const.CONST_MAP_TYPE_PK_LY then
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_LYJJ,nil,nil,nil,nil,nil,0.3)
    elseif lastSceneType==__Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        --组队副本 
        print("战斗结束后跳转到组队副本")
        
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_TEAM,nil,nil,nil,nil,nil,0.3)
        -- local function local_delayFun()
        --     _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_TEAM)
        -- end
        -- _G.Scheduler : performWithDelay(1, local_delayFun )
        -- _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_TEAM)
    elseif lastSceneType==__Const.CONST_MAP_TYPE_COPY_FIGHTERS then
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_TOWER)
    elseif lastSceneId == __Const.CONST_THOUSAND_MAP then
        -- 斗转星移
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_DEMONS,nil,nil,nil,nil,nil,0.3)
    elseif lastSceneType==__Const.CONST_MAP_TYPE_COPY_ROAD then        
        -- 降魔之路
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_SURRENDER,nil,nil,nil,nil,nil,0.3)
    elseif lastSceneId == __Const.CONST_OVER_SERVER_PEAK_ID then 
        -- 大闹天宫 - 玉清元始
        _G.GLayerManager :delayOpenLayer(__Const.CONST_MAP_WELKIN_FIRST,nil,1,nil,nil,nil,0.3)
    elseif lastSceneId == __Const.CONST_WRESTLE_KOF_SENCE then
        -- 三界争锋
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_STRIVE,nil,nil,nil,nil,0.3)
    elseif lastSceneType == __Const.CONST_MAP_CLAN_DEF_TIME2 then
        -- 道劫
        print(" -- 道劫=====>")
        _G.GLayerManager :delayOpenLayer(__Const.CONST_FUNC_OPEN_DAOJIE,nil,nil,nil,lastSceneId,0.3)    
    end
    self.m_fromBattleScene=true
end

--- 门派守卫
function CStage.setClanDefenseHp( self , hpDate)
    self.m_battleViw : setClanDefenseHp( self.m_lpUIContainer, hpDate )
end

function CStage.setGameOver( self, _ackMsg )

    print( "CStage.setGameOver, cancelMove!" )
    local transportList=__CharacterManager:getTransport()
    for _,transporCharacter in pairs(transportList) do
        __CharacterManager:remove(transporCharacter)
        transporCharacter:releaseResource()
    end
    self : stopAutoFight( true ) 
    self.m_lpPlay : cancelMove() 
    for i,v in pairs(__CharacterManager[__Const.CONST_MONSTER]) do
        self:removeCharacter(v)
    end       
    self.m_battleViw : setGameOver( self.m_lpUIContainer, _ackMsg )
end

function CStage.setClanDefensekill( self, Date )  
    self.m_battleViw : setClanDefensekill( self.m_lpUIContainer,  Date )
end

-- function CStage.setClanDefenseReword( self, Date )  
--     self.m_battleViw : setClanDefenseReword( self.m_lpUIContainer,  Date )
-- end

function CStage.setClanCenci( self, Date )
    self.m_battleViw : setClanCenci( self.m_lpUIContainer,  Date )
end

function CStage.setClanDefensePower( self, Date )
    self.m_battleViw : setClanDefensePower( self.m_lpUIContainer,  Date )
end

function CStage.setClanDefenseLog( self, _boci, _time )
    self.m_battleViw : setClanDefenseLog( self.m_lpUIContainer, _boci, _time )
end

function CStage.setNextDefenseLog( self )
    self.m_battleViw : setNextDefenseLog( self.m_lpUIContainer )
end

function CStage.setNextCengDefenseLog( self )
    self.m_battleViw : setNextDoorLog( self.m_lpUIContainer )
end
--------

function CStage.addClanWarDeadAction( self )
    print("addClanWarDeadAction--->>>  1")
    if self.m_lpScene==nil then return end
    
    print("addClanWarDeadAction--->>>  2")
    self:removeClanWarDeadAction()
    
    self.m_clanWarDeadActionContainer=cc.Node:create()
    self.m_lpScene:addChild(self.m_clanWarDeadActionContainer)
    
    local function local_fun()
        print("addClanWarDeadAction--->>>  3")
        self:removeClanWarDeadAction()
        
        local msg=REQ_GANG_WARFARE_INITIATIVE_REC()
        __Network:send(msg)
        print("addClanWarDeadAction--->>>  4")
    end

    self.m_clanWarDeadActionContainer:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(local_fun)))
end
function CStage.removeClanWarDeadAction( self )
    print("removeClanWarDeadAction---->> 1")
    if self.m_clanWarDeadActionContainer==nil then return end
    print("removeClanWarDeadAction---->> 2")
    self.m_clanWarDeadActionContainer:removeFromParent(true)
    self.m_clanWarDeadActionContainer=nil
end
function CStage.jump(self)
    print("开始跳yes")
    self:setStopAI(true)
    cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    self:cancelJoyStickTouch()
    self.m_keyBoard:cancelAttack()
    -- self.m_lpPlay:cancelDodge()
    self.m_lpPlay:setStatus(__Const.CONST_BATTLE_STATUS_IDLE)
    self.m_lpPlay:setMoveClipContainerScalex(1)
    self.m_slowMotionMapPos = true
    local invBuff= _G.GBuffManager:getBuffNewObject(406, 0)
    self.m_lpPlay:addBuff(invBuff)

    local ContainerX, ContainerY=self.m_lpContainer:getPosition()

    local downMoveX = self.m_jumpX
    local downMoveY = self.m_jumpY
    local _speed = 930

    if self.m_sceneDir < 0 then
        downMoveX = -downMoveX
        downMoveY = -downMoveY
    end

    -- local mapMoveX = ContainerX - downMoveX
    -- print(mapMoveX,downMoveX,self.m_sceneDir,ContainerX,"***1***")
    local distanceTime=math.abs(downMoveX)/_speed
    local act1=cc.MoveBy:create(distanceTime,cc.p(-downMoveX,downMoveY))
    self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),act1))

    local playerPosX,playerPosY = self.m_lpPlay:getLocationXY()
    playerPosX = playerPosX + downMoveX
    local maxY,minY = self:getMapLimitHeight(playerPosX)
    downMoveY = (maxY + minY)/2
    local function local_moveEnd()
        print("[PlotView.moveMap]     end")
        local ContainerX, ContainerY=self.m_lpContainer:getPosition()
        self:setCharacterVisible(true)
        self:setStopAI(false)
        self.m_lpPlay.m_obstacleLimitLx = nil
        self.m_lpPlay.m_obstacleLimitRx = nil
        self.m_lpPlay:setLocationXY(playerPosX,downMoveY)
        self.m_lpPlay:checkObstacleLimit()
        for k,v in pairs(__CharacterManager.m_lpPartnerArray) do
            v.m_obstacleLimitLx = nil
            v.m_obstacleLimitRx = nil
            v:setLocationXY(playerPosX-40,downMoveY)
            v:checkObstacleLimit()
        end
        self.m_nMapBaseY=self.m_jumpY
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
        self.m_slowMotionMapPos = nil
        self.m_lpPlay:setMoveClipContainerScalex(self.m_sceneDir)
        -- self.m_lpPlay.m_lpMovieClip:setAnimation(0,"idle",true)
    end
    local act2=cc.CallFunc:create(local_moveEnd)
    -- local function f( ... )
        self.m_lpPlay.m_lpMovieClip:setAnimation(0,"jump",false)
    -- end
    -- cc.Director:getInstance():getScheduler():setTimeScale(0.1)
    -- print(playerPosX,downMoveY,"345lll")
    local jumpTo = cc.MoveTo:create(distanceTime,cc.p(playerPosX,downMoveY))
    self.m_lpPlay.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),jumpTo,cc.DelayTime:create(0.2),act2))
    -- self.m_lpPlay.m_lpContainer:runAction(cc.Sequence:create(cc.CallFunc:create(f)))

    -- self.m_lpMapDisContainer:runAction(cc.MoveBy:create(distanceTime,cc.p(upMoveX,-100)))
end

------一骑当千code---------------------------
--用于加载一骑当千资源
function CStage.getIkkiTousenWarData(self)
    return self.m_IkkiTousenWarData
end
function CStage.setIkkiTousenWarData(self,_data)
    self.m_IkkiTousenWarData = _data
    _G.m_IkkiTousenWarData = _data
end

function CStage.IkkiTousen_initMainPlay( self,_x, _y )
    local property = _G.GPropertyProxy : getMainPlay()
    
    local newproperty= require("mod.support.Property")()

    local pro = property : getPro()

    local ikkiTousendata = _G.m_IkkiTousenWarData
    print("if is empty ikkiTousendata==",ikkiTousendata)
    if ikkiTousendata ~= nil then
        print(pro)
        local skin = ikkiTousendata.skin 

        pro = tonumber(skin)%10
        newproperty : setPro(pro)
        newproperty : setSkinArmor(skin)
    end
    newproperty.attr=require("mod.support.PropertyWar")()
    local tempNode = _G.Cfg.thousand_role[pro]
    local luanode  = tempNode.attr
    if tempNode~=nil then
        if luanode~=nil then
            print("一骑当千替换成表的攻击属性")
            newproperty : updateProperty( __Const.CONST_ATTR_SP ,luanode.sp )
            newproperty : updateProperty( __Const.CONST_ATTR_HP ,luanode.hp )
            newproperty : updateProperty( __Const.CONST_ATTR_STRONG_ATT ,luanode.strong_att )
            newproperty : updateProperty( __Const.CONST_ATTR_STRONG_DEF ,luanode.strong_def )
            newproperty : updateProperty( __Const.CONST_ATTR_DEFEND_DOWN ,luanode.strong_down )
            newproperty : updateProperty( __Const.CONST_ATTR_HIT , luanode.hit)
            newproperty : updateProperty( __Const.CONST_ATTR_DODGE , luanode.dod)
            newproperty : updateProperty( __Const.CONST_ATTR_CRIT ,luanode.crit )
            newproperty : updateProperty( __Const.CONST_ATTR_RES_CRIT ,luanode.crit_res )
            newproperty : updateProperty( __Const.CONST_ATTR_BONUS ,luanode.bonus )
            newproperty : updateProperty( __Const.CONST_ATTR_REDUCTION ,luanode.reduction )
        end
        newproperty : setLv(tempNode.lv)
    end
    
    if ikkiTousendata ~= nil and  ikkiTousendata.msg_skills ~= nil then
        print("添加 一骑当千的技能")
        newproperty : setSkillData(nil)
        local roleSkillData = newproperty :getSkillData()
        roleSkillData.skill_study_list={}

        for k,v in pairs(ikkiTousendata.msg_skills) do
            local m_position = k
            if m_position > 4 then
                m_position = 4
            end 
            local singleSkillData = {
                equip_pos = m_position,
                skill_id  = v.skill_id,
                skill_lv  = __Const.CONST_THOUSAND_SKILL_LV,
            }
            
            roleSkillData : addEquipSkillData(singleSkillData)
            roleSkillData.skill_study_list[v.skill_id]=singleSkillData
        end
    end

    local uid =-123457
    newproperty : setUid(uid)
    
    _G.GPropertyProxy:addOne(newproperty, __Const.CONST_PLAYER )
    
    local name     = property : getName()
    local hp       = newproperty : getAttr() : getHp()
    local maxHP    = newproperty : getAttr() : getMaxHp()
    local sp       = newproperty : getAttr() : getSp()
    local lv       = newproperty : getLv()
    local skinId   = newproperty : getSkinArmor()
    _G.SkillHurt.isNeedBroadcastHurt=false

    local mainPlay = CPlayer( __Const.CONST_PLAYER )
    mainPlay:setProperty(newproperty)
    mainPlay:playerInit( uid, name, pro, lv, skinId,0,0,0,0)
    mainPlay:init( uid , name, maxHP,hp, sp, sp, _x, _y, skinId )
    mainPlay:resetNamePos()
    mainPlay.isMainPlay=true
    mainPlay:addBigHpView()
    
    self:addCharacter(mainPlay)
    _G.g_lpMainPlay = mainPlay
    self.m_lpPlay   = mainPlay
end
--离开按钮回调
function CStage.IkkiTousen_finishCopy( self )
    print("CStage.IkkiTousen_finishCopy")
    if self.IkkiTousen_OK then return end
    local time=0
    if self.m_battleViw.m_conditionTimes~=nil then
        time=(self.m_lastCountTime-self.m_battleViw.m_conditionTimes)*0.001-self.m_plotUseTime
        time=math.floor(time)
    end
    local hurtHp=self.m_thousandHurtMonsterHp and self.m_thousandHurtMonsterHp/10 or self.mons_hp
    local md5Key = self:getMd5Key({self.carom_times,self.mons_hp,time})
    local msg = REQ_COPY_NEW_NOTICE_OVER()
    msg : setArgs(0, self.carom_times,self.mons_hp,time,md5Key,self.m_sceneId)

    _G.Network:send(msg)

    self.sendMsg=msg

    self.IkkiTousen_OK = true
end

    --{ 副本剩余时间 }
function CStage.IkkiTousen_setshowtime( self, _time)
    self.IkkiTousen_SchedulerTime=_time
end
function CStage.IkkiTousen_showtime( self)
    if self.IkkiTousen_SchedulerTime==nil then
        return
    end
    local remainTime=self.IkkiTousen_SchedulerTime+1
    self.IkkiTousen_SchedulerTime=remainTime

    local time = self.m_battleViw:getTimesStr(remainTime)
    self.m_battleViw.m_totalTimeLabel:setString(string.sub(time,4))
end
function CStage.IkkiTousen_timeScheduler(self,_istrue)
    local function onEnterFrame()
        self:IkkiTousen_showtime()
    end
    _G.Scheduler:schedule(onEnterFrame,1)
end

--打出的伤害 一骑当千
function CStage.IkkiTousen_showhp( self,_hp)
     self.m_battleViw.m_totalHurtLabel:setString(_hp)
end

function CStage.stopAllCharacterAI(self)
    for _,v in pairs(__CharacterManager.m_lpHookArray) do
        v.m_noUpdate = true
        v.m_lpContainer:setVisible(false)
    end
    for _,v in pairs(__CharacterManager.m_lpGoodsMonsterArray) do
        v.m_noUpdate = true
        v.m_lpContainer:setVisible(false)
    end
    for _,v in pairs(__CharacterManager.m_lpTrapArray) do
        v:removeTrap()                           
    end
    for _,v in pairs(__CharacterManager.m_lpPartnerArray) do
        v:setAI(0)
        v.m_preAi=0
        v.m_nTarget = nil
    end
    for _,v in pairs(__CharacterManager.m_lpMonsterArray) do
        v:setAI(0)
        v.m_preAi=0
        v.m_nTarget = nil
    end
end

function CStage.canCallSkill( self )
    if self.m_lpScenesXML.call~=0 then
        local maxNum=#self.m_lpScenesXML.call
        for i=1,maxNum do
            local num=0
            local data=self.m_lpScenesXML.call[i]
            for _,character in pairs(__CharacterManager:getMonster()) do
                if character.m_monsterId==data[1] then
                    num=num+1
                end
            end
            if data[3]-data[2] < num then
                return false
            end
            if i==maxNum then
                return true
            end
        end
    end
end

function CStage.useCallSkill( self, character, _skill)
    if self.m_lpScenesXML.call~=0 then
        local x = character.m_nLocationX
        local dir = character.m_nScaleX
        x = x + 100 * dir
        local maxY,minY=self:getMapLimitHeight(x)
        for _,data in pairs(self.m_lpScenesXML.call) do
            local monsterXmlProperty = __StageXMLManager:getMonsterData(data[1])
            local height = (maxY - minY)/(data[2]+1)
            local vX, vY, vWidth, vHeight
            if data[5]==1 then
                local colliderData=_G.g_SkillDataManager:getAttackSkillCollider(_skill)
                vX,vY,_,vWidth,vHeight,_=character:getConvertCollider(colliderData)
            end
            for i=1,data[2] do
                local y = minY+i*height
                if vX~=nil then
                    math.randomseed(gc.MathGc:random_0_1())
                    x = math.random(vX,vWidth+vX)
                    y = math.random(vY,vHeight+vY)
                end
                __StageXMLManager:addOneMonster(nil,monsterXmlProperty,data[1],x,y,dir,nil,nil,data[4])
            end
        end
    end
end

function CStage.showRuler(self)
    self.lineNode  = cc.Node:create()
    local size = cc.size(2,600)
    local num = math.ceil(self.m_nMaprx/200)
    for i=1,num do
        local line = cc.LayerColor:create(cc.c4b(0,255,0,255))
        line:setContentSize(size)
        line:setPosition((i-1)*200,0)
        self.lineNode:addChild(line)
        local text = _G.Util : createLabel( (i-1)*200, 20 )
        text:setPosition((i-1)*200,100)
        self.lineNode:addChild(text)
    end
    self.m_lpMapNearContainer:addChild(self.lineNode,1000)
    size=cc.size(3048,2)
    for i=1,6 do
        local line = cc.LayerColor:create(cc.c4b(0,255,0,255))
        line:setContentSize(size)
        line:setPosition(0,i*100)
        self.lineNode:addChild(line)
        local text = _G.Util : createLabel( i*100, 20 )
        text:setPosition(200,i*100)
        self.lineNode:addChild(text)
    end
end
function CStage.hideRuler(self)
    if self.lineNode ~= nil then
        self.lineNode  :removeAllChildren(true)
    end
end
function CStage.isMultiStage(self)
    if self.m_isMultiStage~=nil then
        return self.m_isMultiStage
    end
    if self.m_sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS 
        or self.m_sceneType == __Const.CONST_MAP_TYPE_BOSS
        or self.m_sceneType == __Const.CONST_MAP_TYPE_CLAN_BOSS 
        or self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER 
        or self.m_sceneType == __Const.CONST_MAP_CLAN_DEFENSE
        or self.m_sceneType == __Const.CONST_MAP_CLAN_WAR
        or self.m_sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then
        self.m_isMultiStage=true
    else
        self.m_isMultiStage=false
    end
    return self.m_isMultiStage
end
function CStage.hideMapDisContainer( self )
    self.m_lpMapNearContainer:setVisible(false)
end
function CStage.showMapDisContainer( self )
    self.m_lpMapNearContainer:setVisible(true)
end

function CStage.addHongBaoView(self,_ackMsg)
    print("addHongBaoView===========>>  1")
    local runningScene=cc.Director:getInstance():getRunningScene()
    local myScene=runningScene
    if myScene:getChildByTag(7795) then return end
    print("addHongBaoView===========>>  2")
    local tempView=require("mod.mainUI.GrabRedTipsView")(_ackMsg)
    local tempLayer=tempView:create()
    myScene:addChild(tempLayer,_G.Const.CONST_MAP_ZORDER_MARQUEE+20,7795)
end

function CStage.initLingYaoData(self)
    local myLingYaoArray={{},{},{}}
    for i=1,#self.m_lingYaoPkData.lingyao_data do
        local tempData=self.m_lingYaoPkData.lingyao_data[i]
        local roundIdx=math.ceil(tempData.pos/2)
        -- local posIdx=tempData.pos%2
        -- posIdx=posIdx==0 and 2 or posIdx
        local tempCount=#myLingYaoArray[roundIdx]
        myLingYaoArray[roundIdx][tempCount+1]=tempData
    end

    local heLingYaoArray={{},{},{}}
    for i=1,#self.m_lingYaoPkData.lingyao_data2 do
        local tempData=self.m_lingYaoPkData.lingyao_data2[i]
        local roundIdx=math.ceil(tempData.pos/2)
        -- local posIdx=tempData.pos%2
        -- posIdx=posIdx==0 and 2 or posIdx
        local tempCount=#heLingYaoArray[roundIdx]
        heLingYaoArray[roundIdx][tempCount+1]=tempData
    end

    self.m_myLingYaoArray=myLingYaoArray
    self.m_heLingYaoArray=heLingYaoArray
    self.m_lingYaoResultArray={}
    self.m_curLingYaoRound=0

    self.m_lingYaoView=require("mod.map.UILingYao")(self.m_lingYaoPkData,myLingYaoArray,heLingYaoArray)
    local tempNode=self.m_lingYaoView:create()
    self.m_lpUIContainer:addChild(tempNode)

    -- print("我的出战灵妖。。。。。")
    -- for i=1,#self.m_myLingYaoArray do
    --     print("第"..i.."轮：")
    --     for j=1,#self.m_myLingYaoArray[i] do
    --         print("    出战灵妖ID:"..self.m_myLingYaoArray[i][j].id)
    --     end
    -- end

    -- print("对方的出战灵妖。。。。。")
    -- for i=1,#self.m_heLingYaoArray do
    --     print("第"..i.."轮：")
    --     for j=1,#self.m_heLingYaoArray[i] do
    --         print("    出战灵妖ID:"..self.m_heLingYaoArray[i][j].id)
    --     end
    -- end
end
function CStage.saveBattleRes(self,_res)
    -- res: 1:我输了，  2:平手，  4:我赢了
    self.m_lingYaoResultArray[self.m_curLingYaoRound]=_res
    self.m_lingYaoView:updateResult(self.m_curLingYaoRound,_res)
end
function CStage.hasNextLingYaoBattle(self)
    if not self.m_curLingYaoRound then
        return true
    elseif self.m_curLingYaoRound>=3 then
        return false
    end
end
function CStage.runNextLingYaoBattle(self)
    self.m_curLingYaoRound=self.m_curLingYaoRound+1

    self:setStopAI(true)

    if self.m_curLingYaoRound>3 then
        -- 战斗结束
        local function nFun()
            self:autoLingYaoPKFinish()
        end
        _G.Scheduler:performWithDelay(0.2,nFun)
        return
    end

    if #self.m_myLingYaoArray[self.m_curLingYaoRound]==0 then
        if #self.m_heLingYaoArray[self.m_curLingYaoRound]==0 then
            self:saveBattleRes(2)
        else
            self:saveBattleRes(1)
        end
        self:runNextLingYaoBattle()
        return
    elseif #self.m_heLingYaoArray[self.m_curLingYaoRound]==0 then
        self:saveBattleRes(4)
        self:runNextLingYaoBattle()
        return
    end

    local winSize=cc.Director:getInstance():getWinSize()
    local function _initScene()
        for k,v in pairs(__CharacterManager.m_lpPartnerArray) do
            v:releaseResource()
            __CharacterManager:remove(v)
        end

        for _,v in pairs(__CharacterManager.m_lpVitroArray) do
            self:removeVitro(v)
        end

        self.m_lingYaoView:resetRoundView(self.m_curLingYaoRound)

        local tempUid=_G.GPropertyProxy:getMainPlay():getUid()
        local tempData=self.m_myLingYaoArray[self.m_curLingYaoRound]
        for i=1,#tempData do
            local id=tempData[i].id
            -- local id=12301
            -- local lv=5
            local lv=tempData[i].lv
            local attr=tempData[i].attr
            __StageXMLManager:addLingYaoMonster(tempUid,id,lv,attr,0,1,cc.p(300,100))
        end

        local tempUid=self.m_lingYaoPkData.uid
        local tempData=self.m_heLingYaoArray[self.m_curLingYaoRound]
        for i=1,#tempData do
            local id=tempData[i].id
            -- local id=12301
            -- local lv=5
            local lv=tempData[i].lv
            local attr=tempData[i].attr
            __StageXMLManager:addLingYaoMonster(tempUid,id,lv,attr,1,-1,cc.p(900,100))
        end

        if self.m_lpRemainingTimeContainer then
            self.m_lpRemainingTimeContainer:removeAllChildren(true)
        end
    end
    
    local function _showRoundEff(_node)
        if _node then
            _node:removeFromParent(true)
        end

        local tempLabel=_G.Util:createBorderLabel(string.format("第%d轮",self.m_curLingYaoRound),50)
        tempLabel:setPosition(winSize.width*0.5,winSize.height*0.5)
        tempLabel:setScale(10)
        tempLabel:setTag(1125)
        tempLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        self.m_lpScene:removeChildByTag(1125)
        self.m_lpScene:addChild(tempLabel,401)

        
        self:setRemainingTime(__Const.CONST_PAR_ARENA_BATTLE_TIME,"")

        local function nFun(_node)
            cc.Director:getInstance():getEventDispatcher():setEnabled(true)
            self:setStopAI(false)
            _node:runAction(cc.Spawn:create(cc.MoveTo:create(0.3,cc.p(winSize.width*0.5,595)),cc.ScaleTo:create(0.28,0.6)))
        end
        tempLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1),cc.DelayTime:create(1),cc.CallFunc:create(nFun)))
    end

    cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    self.m_deadlineTime=nil
    if self.m_curLingYaoRound>1 then
        local tempLayer=cc.LayerColor:create(cc.c4b(0,0,0,255))
        tempLayer:setPosition(-winSize.width*1.3,0)
        self.m_lpMessageContainer:addChild(tempLayer)

        local tempSpr=cc.Sprite:create("ui/bg/excessive_spr.png")
        tempSpr:setAnchorPoint(cc.p(0,0))
        tempSpr:setPosition(winSize.width,0)
        tempLayer:addChild(tempSpr)

        tempSpr=cc.Sprite:create("ui/bg/excessive_spr.png")
        tempSpr:setAnchorPoint(cc.p(0,0))
        tempSpr:setPosition(0,0)
        tempSpr:setScaleX(-1)
        tempLayer:addChild(tempSpr)

        tempLayer:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(winSize.width*0.5,0))
                                                ,cc.CallFunc:create(_initScene)
                                                ,cc.MoveTo:create(0.5,cc.p(winSize.width*1.3,0))
                                                ,cc.DelayTime:create(0.3)
                                                ,cc.CallFunc:create(_showRoundEff)
                                                ))
    else
        _initScene()
        _showRoundEff()
    end

    
end
function CStage.deadLingYao(self,_character)
    local teamId=_character:getProperty():getTeamID()
    for k,v in pairs(__CharacterManager.m_lpPartnerArray) do
        if v:getProperty():getTeamID()==teamId then
            return
        end
    end

    if teamId==0 then
        self:saveBattleRes(1)
    else
        self:saveBattleRes(4)
    end
    self:runNextLingYaoBattle()
end
function CStage.setLingYaoHp(self,_character,_hp)
    local pIdx=_character:getID()
    self.m_lingYaoView:setHp(pIdx,_hp)
end
function CStage.lingYaoPkTimeOut(self)
    self:saveBattleRes(2)
    self:runNextLingYaoBattle()
end
function CStage.exitLingYao(self)
    if self.m_autoPkFinish then return end

    self:setStopAI(true)
    self.m_deadlineTime=nil
    self.m_lpUIContainer:removeChildByTag(1125)

    for i=self.m_curLingYaoRound,3 do
        self:saveBattleRes(1)
        self.m_curLingYaoRound=self.m_curLingYaoRound+1
    end

    self:autoLingYaoPKFinish()
end




function CStage.updatePVPTimes(self,_time)
    if self.m_pvpWaitSyncTimes>0 then
        local nowTime=_G.TimeUtil:getTotalMilliseconds()
        self.m_memoryView:setDelayFPS(math.ceil((nowTime-self.m_pvpWaitSyncTimes)/2))
    end

    self.m_pvpMilliSeconds=_time
    self.m_pvpWaitSyncTimes=0

    if self.m_pvpIsDelay then
        local msg=REQ_WAR_PVP_STATE_REQ()
        msg:setArgs(self.m_pvpMilliSeconds)
        __Network:send(msg)
    end
end

function CStage.updatePVPInfo(self,_nowTime)
    self.m_pvpSendSyncTimes=self.m_pvpSendSyncTimes or 0
    self.m_pvpWaitSyncTimes=self.m_pvpWaitSyncTimes or 0
    if _nowTime-self.m_pvpSendSyncTimes>200 then
        local msg=REQ_WAR_PVP_TIME()
        __Network:send(msg)
        if self.m_pvpWaitSyncTimes==0 then
            self.m_pvpWaitSyncTimes=_nowTime
        end
        self.m_pvpSendSyncTimes=_nowTime
    end

    if self.m_pvpWaitSyncTimes>0 and _nowTime-self.m_pvpWaitSyncTimes>200 then
        -- 网络延迟
        self.m_pvpIsDelay=true

        self.m_memoryView:setDelayFPS(math.ceil((_nowTime-self.m_pvpWaitSyncTimes)/2))
    end

    self.m_pvpSendStateTimes=self.m_pvpSendStateTimes or 0
    if self.m_pvpMilliSeconds and _nowTime-self.m_pvpSendStateTimes>1000 then
        if self.m_lpPlay and self.m_lpPlay:getHP()>0 and self.m_counterWorker and self.m_counterWorker:getHP()>0 then
            self.m_pvpSendStateTimes=_nowTime

            self:sendPVPState()
        end
    end
end

function CStage.sendPVPState(self)
    local dir=self.m_lpPlay:getScaleX()>0 and 1 or 0
    local msg=REQ_WAR_PVP_STATE_UPLOAD()
    msg:setArgs(self.m_pvpMilliSeconds,self.m_lpPlay:getID(),self.m_lpPlay:getLocationX(),self.m_lpPlay:getLocationY(),self.m_lpPlay:getLocationZ(),dir,self.m_lpPlay:getStatus())
    __Network:send(msg)
end

function CStage.updatePVPPlayerState(self,_time,_stateGroup,_isReset)
    if self.m_pvpIsDelay or _isReset then
        self.m_pvpIsDelay=nil

        for i=1,#_stateGroup do
            local tempStateInfo=_stateGroup[i]

            local tempPlayer
            if tempStateInfo.uid==self.m_lpPlay:getID() then
                tempPlayer=self.m_lpPlay
            elseif tempStateInfo.uid==self.m_counterWorker:getID() then
                tempPlayer=self.m_counterWorker
            end

            if tempPlayer then
                local tempScale=tempStateInfo.dir==0 and -1 or 1
                tempPlayer:setLocationXY(tempStateInfo.pos_x,tempStateInfo.pos_y)
                tempPlayer:setMoveClipContainerScalex(tempScale)
            end
        end

        if not _isReset then
            local command=CErrorBoxCommand("延迟矫正")
            __controller:sendCommand(command)
        end
    end
end

function CStage.pushPVPFrameData(self,_ackMsg)
    self.m_pvpFrameDataArray=self.m_pvpFrameDataArray or {}
    self.m_pvpFrameDataArray[#self.m_pvpFrameDataArray+1]=_ackMsg

    local nowTime=_G.TimeUtil:getTotalMilliseconds()
    if not self.m_pvpLastReponeseTimes then
        self.m_pvpLastReponeseTimes=nowTime
    else
        local subTimes=nowTime-self.m_pvpLastReponeseTimes-100
        if subTimes>0 then
            self.m_memoryView:setDelayFPS(math.ceil(subTimes/2))
        end
        self.m_pvpLastReponeseTimes=self.m_pvpLastReponeseTimes+100
    end
end
function CStage.updatePVPFrame(self,_duration)
    self.m_pvpPlayFrameTimes=self.m_pvpPlayFrameTimes or 0

    if self.m_pvpIsPlayFrameingData~=nil then
        if #self.m_pvpFrameDataArray>0 then
            if self.m_pvpIsPlayFrameingData.count>0 then
                -- 加速播放
                if #self.m_pvpFrameDataArray>1 and self.m_pvpFrameDataArray[1].count==0 then
                    table.remove(self.m_pvpFrameDataArray,1)
                else
                    cc.Director:getInstance():getScheduler():setTimeScale(3)
                end
            else
                self.m_pvpIsPlayFrameingData=nil
            end
        else
            cc.Director:getInstance():getScheduler():setTimeScale(1)
        end
        self.m_pvpPlayFrameTimes=self.m_pvpPlayFrameTimes+_duration

        if self.m_pvpPlayFrameTimes>0.1 then
            -- 播放完毕一帧
            -- if self.m_pvpIsPlayFrameingData and self.m_pvpIsPlayFrameingData.count>0 then
            --     for i=1,#self.m_pvpIsPlayFrameingData.order_array do
            --         local tempOrder=self.m_pvpIsPlayFrameingData.order_array[i]
            --         local tempPlayer=__CharacterManager:getPlayerByID(tempOrder.uid)
            --         if tempPlayer then
                        -- if tempOrder.type==1 then
                        --     tempPlayer:cancelMove()
                        -- end
                        -- tempPlayer.pvpPreMoveX=nil
                        -- tempPlayer.pvpPreMoveY=nil
            --         end
            --     end
            -- end
            self.m_pvpIsPlayFrameingData=nil
        end
    elseif self.m_pvpPlayFrameTimes>0 then
        self.m_pvpPlayFrameTimes=self.m_pvpPlayFrameTimes+_duration
    end

    if self.m_pvpIsPlayFrameingData==nil then
        if #self.m_pvpFrameDataArray>0 then
            local frameData=table.remove(self.m_pvpFrameDataArray,1)
            -- print("AAAAAAAAAAAAAAAAAA===>",frameData.count)
            if frameData.count>0 then
                for i=1,#frameData.order_array do
                    local tempOrder=frameData.order_array[i]
                    local tempPlayer=__CharacterManager:getPlayerByID(tempOrder.uid)

                    -- print("==========>>>>>>",tempOrder.uid,tempOrder.type,tempPlayer)
                    if tempPlayer then
                        if tempOrder.type==1 then
                            if tempOrder.move_type==__Const.CONST_MAP_MOVE_MOVE then
                                -- if not (tempPlayer.pvpPreMoveX==tempOrder.sx and tempPlayer.pvpPreMoveY==tempOrder.sy and tempPlayer.pvpPreMoveX==tempPlayer.m_nLocationX and tempPlayer.pvpPreMoveY==tempPlayer.m_nLocationY) then
                                --     tempPlayer:setLocationXY(tempOrder.sx,tempOrder.sy)
                                    tempPlayer:setMovePos(cc.p(tempOrder.ex,tempOrder.ey),true)
                                    tempPlayer.pvpPreMoveX=tempOrder.sx
                                    tempPlayer.pvpPreMoveY=tempOrder.sy
                                -- end
                            else
                                tempPlayer:setLocationXY(tempOrder.sx,tempOrder.sy)
                                tempPlayer:cancelMove()
                                if tempOrder.move_dir>0 then
                                    tempPlayer:setMoveClipContainerScalex(1)
                                elseif tempOrder.move_dir==0 then
                                    tempPlayer:setMoveClipContainerScalex(-1)
                                end
                            end
                        elseif tempOrder.type==2 then
                            -- print("SAJDASKJDLA=====>>>>",)
                            tempPlayer.m_netScalex=true
                            if tempOrder.skill_dir==1 then
                                tempPlayer.m_nextScalex=1
                            elseif tempOrder.skill_dir==2 then
                                tempPlayer.m_nextScalex=-1
                            end
                            if tempOrder.skill_id%1000==900 then
                                tempPlayer.m_cutSkill=true
                            end
                            tempPlayer:setLocationXY(tempOrder.pos_x,tempOrder.pos_y)
                            tempPlayer:useSkill(tempOrder.skill_id,true)
                        end
                    end
                end
            end
            self.m_pvpPlayFrameTimes=0
            self.m_pvpIsPlayFrameingData=frameData

            -- cc.Director:getInstance():resume()
            -- self.m_lpContainer:resume()
            self:onBattleResume()
        else
            -- 暂停，等待帧数据
            if self.m_pvpPlayFrameTimes>0.2 then
                self.m_pvpPlayFrameTimes=0
                -- self.m_lpContainer:pause()
                self:onBattlePause()
                -- cc.Director:getInstance():pause()
                -- local command=CErrorBoxCommand("网络延迟")
                -- __controller:sendCommand(command)
            end
        end
    end
end

function CStage.onBattlePause(self)
    local nFun1
    nFun1=function(_node)
        _node:pause()
        for k,v in pairs(_node:getChildren()) do
            nFun1(v)
        end
    end
    nFun1(self.m_lpContainer)
end
function CStage.onBattleResume(self)
    local nFun1
    nFun1=function(_node)
        _node:resume()
        for k,v in pairs(_node:getChildren()) do
            nFun1(v)
        end
    end
    nFun1(self.m_lpContainer)
end

return CStage