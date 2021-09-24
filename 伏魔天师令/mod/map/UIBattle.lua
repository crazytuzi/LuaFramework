local BattleView = classGc( view, function (self)
    --是否显示DPS排行
    self.m_bIsShowAllDps = false
    --BOSS死亡界面
    self.m_lpSpriteBossDead = nil

    self.m_dps = nil
    self.m_stageView=_G.g_Stage
end)

local P_WINSIZE=cc.Director:getInstance():getVisibleSize()
local P_POINT_LEFT={x=0,y=0.5}
local P_CON_Y=493
local P_CON_WID=80
local P_CON_SX=85

local P_TOSTRING=tostring
local P_STRING_LEN=string.len
local P_STRING_SUB=string.sub
local P_STRING_FORMAT=string.format

local P_COLOR_GREEN=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN)

--{连击}
function BattleView.showCombo( self, _nCombo, _container )
    if _nCombo <= 0 then
        return
    end
    local strCombo = P_TOSTRING( _nCombo )
    local lenStrCombo = P_STRING_LEN(strCombo)

    local hitsBg = cc.Node:create()
    local comboBg= cc.Node:create()
    hitsBg : addChild(comboBg,20)
    local hitsBgSprite = cc.Sprite : createWithSpriteFrameName("battle_combo_attack.png")
    hitsBgSprite:setPosition(cc.p(-80,0))
    hitsBg:addChild(hitsBgSprite)

    comboBg:setScale(1.2)
    local scale = cc.ScaleTo:create(0.1,1.0)
    comboBg:runAction(cc.Sequence:create(scale))

    -- local hitsSprite = cc.Sprite : createWithSpriteFrameName( "battle_combo_attack_text.png" )
    -- hitsSprite:setPosition(cc.p(-40,15))
    -- comboBg:addChild(hitsSprite,10)

    local totalWidth = 0
    local widths ={}
    local numberSprites ={}
    for i=lenStrCombo,1,-1 do
        local strCurrent = P_STRING_SUB(strCombo,i,i)
        local frameName = P_STRING_FORMAT("battle_batter_%s.png",strCurrent)
        local numSprite = cc.Sprite:createWithSpriteFrameName(frameName)
        comboBg : addChild( numSprite )
        local numSpriteSize = numSprite:getContentSize()
        table.insert(widths,numSpriteSize.width)
        totalWidth=totalWidth+numSpriteSize.width
        table.insert(numberSprites,numSprite)
    end
    local x =-123+totalWidth/2
    if lenStrCombo==1 then
        x =x-widths[1]/ 2+5
    end
    for i,numSprite in ipairs(numberSprites) do
        x = x - widths[i]/ 2
        numSprite:setPosition( cc.p( x, 0 ) )
        x = x - widths[i]/ 2
    end
    widths=nil
    numberSprites=nil

    -- local spritebg = cc.Sprite:createWithSpriteFrameName("battle_combo_attack_2.png")
    local sprite = cc.Sprite:createWithSpriteFrameName("battle_combo_attack_3.png")
    local progress = cc.ProgressTimer:create(sprite)
    progress:setPercentage(100)
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setBarChangeRate(cc.p(1,0))
    progress:setMidpoint(cc.p(0,0.5))
    local progressTo = cc.ProgressTo:create(_G.Const.CONST_BATTLE_COMBO_TIME,0)
    progress:runAction(progressTo)
    progress:setPosition(80,15)
    -- hitsBg:addChild(spritebg)
    hitsBgSprite:addChild(progress)

    _container:addChild(hitsBg)
    hitsBg:setPosition(cc.p(P_WINSIZE.width/2+250, P_WINSIZE.height-150))
end

--{鼓励按钮}
function BattleView.addEmbraveButton( self, _container)   
    local node = cc.Node:create()
    node:setPosition(cc.p(P_CON_SX+P_CON_WID*2,P_CON_Y))

    local node1=cc.Node:create()
    node1:setPosition(P_CON_SX+P_CON_WID*2,P_CON_Y-55)

    self.m_currentAttackPlus = _G.Util:createLabel("",20)
    self.m_currentAttackPlus : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    node1:addChild(self.m_currentAttackPlus)

    local function selectedEvent(sender,eventType)
        
        if eventType==ccui.TouchEventType.ended then          
           local msg = REQ_WORLD_BOSS_RMB_ATTR()
           msg :setArgs(0)        -- {0 问价| 1 是}
           _G.Network:send(msg)
        end   
    end
    
    local checkbox = ccui.Button:create("battle_encourage.png","battle_encourage.png","",ccui.TextureResType.plistType) 
    checkbox:addTouchEventListener(selectedEvent)
    node:addChild(checkbox)
    _container : addChild(node,-30)
    _container : addChild(node1,-30)
end

function BattleView.updateCurrentAttackPlus(self,_attackPlus) -- 攻击加成显示
    if _attackPlus~=0 then
        print("好好",_attackPlus)
        local _attackBonus="伤害加成".._attackPlus.."%"
        self.m_currentAttackPlus:setString(_attackBonus)
    end
    if _attackPlus==0 then 
        print("不好",_attackPlus)
        local _attackBonus="伤害加成0%"
        self.m_currentAttackPlus:setString(_attackBonus)
    end
end
function BattleView.updateCheckBox( self,_embraveData )
    -- body
    local scene=cc.Director:getInstance():getRunningScene()
    if scene:getChildByTag(135791) then
        return
    end
    local szContent,sureFun,embraveNum
    local embraveTimes=_embraveData.times_max-_embraveData.times
    local function sureFun()
        local msg = REQ_WORLD_BOSS_RMB_ATTR()
        msg :setArgs(1)        -- {0 问价| 1 是}
        _G.Network:send(msg)
        local msg = REQ_WORLD_BOSS_RMB_ATTR()
        msg :setArgs(0)        -- {0 问价| 1 是}
        _G.Network:send(msg)
    end    
       
    if embraveTimes<=0 then
        return      
    else
        embraveNum=_embraveData.value/100
        szContent="是否使用".._embraveData.rmb.."元宝?\n".."增强"..embraveNum.."%的伤害"
        szNotic="剩余鼓舞次数: "..embraveTimes       
    end
    local view=require("mod.general.TipsBox")()
    local layer=view:create(szContent,sureFun)
    scene:addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,135791)
    
    view:setNoticLabel(szNotic)
    view:setContentPosOff(cc.p(0,20))
    view:setTitleLabel("提示")     
end
--{屏蔽按钮}
function BattleView.addShieldButton( self, _container, _type )

    local node = cc.Node:create()
    node:setPosition(cc.p(P_CON_SX+P_CON_WID*3,P_CON_Y))
    if _type == _G.Const.CONST_MAP_TYPE_CLAN_BOSS then
        node:setPosition(cc.p(P_CON_SX+P_CON_WID*2,P_CON_Y))
    end

    self.m_isShield = false
    local checkbox = gc.CButton : create()
    local function shield(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
            _G.g_Stage:setOtherPlayerVisible(self.m_isShield)
            if self.m_isShield then
                checkbox:loadTextures("battle_shield.png")
            else
                checkbox:loadTextures("battle_shield2.png")
            end
            self.m_isShield = (not self.m_isShield)
        end   
    end

    checkbox:loadTextures("battle_shield.png")
    checkbox:addTouchEventListener(shield)
    node:addChild(checkbox)
    _container : addChild(node,-30)

end

function BattleView.addModelButton( self, _container )
    self.m_modelCheckbox = ccui.CheckBox:create()
    self.m_modelCheckbox:loadTextures("battle_more.png","battle_one.png","","","",ccui.TextureResType.plistType)
    self.m_modelCheckbox:setPosition(cc.p(P_CON_SX+P_CON_WID*2,P_CON_Y))
    _container : addChild(self.m_modelCheckbox,-30)
    self.m_modelCheckbox:setTag(16866666)

    -- local function onCallBack( eventType, obj, x, y)
    --     if eventType == "TouchBegan" then
    --         return obj:containsPoint(obj:convertToNodeSpaceAR(cc.p(x,y)))
    --     elseif eventType == "TouchEnded" then
    --         self.m_stageView:setFightModel(obj:getChecked())

    --         print("BattleView.addModelButton============================>> obj:getChecked()=",obj:getChecked())
    --     end
    -- end

    local function selectedEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self.m_stageView:setFightModel(true)
            self.m_modelCheckbox:loadTextures("battle_one.png","battle_more.png","","","",ccui.TextureResType.plistType)
            self.m_modelCheckbox:setPosition(cc.p(P_CON_SX+P_CON_WID*2,P_CON_Y))
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self.m_stageView:setFightModel(false)
            self.m_modelCheckbox:loadTextures("battle_more.png","battle_one.png","","","",ccui.TextureResType.plistType)
            self.m_modelCheckbox:setPosition(cc.p(P_CON_SX+P_CON_WID*2,P_CON_Y))
        end
    end
    self.m_modelCheckbox :addEventListener(selectedEvent)
end

--{退出副本按钮}
function BattleView.addExitCopyButton( self, _container )
    CCLOG("BattleView.addExitCopyButton")
    local function callBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self : addExitCopyOKButton( _container )
        end
    end
    local button=gc.CButton:create()
    button:loadTextures("battle_leave.png")
    button:addTouchEventListener(callBack)
    button : setPosition( cc.p(P_CON_SX,P_CON_Y))
    _container : addChild( button)

end

function BattleView.addExitCopyOKButton( self, _container )
    if self.m_stageView.isFinishCopy==true then
        self.m_stageView:exitCopy()
        return
    end

    local scenesType = self.m_stageView:getScenesType()

    local function onCallBack()
        self.m_stageView:setStopAI(true)

        if scenesType == _G.Const.CONST_MAP_TYPE_BOSS or 
            scenesType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS then
            
            local msg = REQ_WORLD_BOSS_EXIT_S()
            _G.Network:send(msg)

        elseif scenesType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL
            or scenesType == _G.Const.CONST_MAP_TYPE_COPY_MONEY then
            self.m_stageView.m_lpPlay:setHP(-12345)

        elseif scenesType == _G.Const.CONST_MAP_CLAN_DEFENSE then
            if _G.g_FactionTDMediator ~= nil then
                controller :unregisterMediator( _G.g_FactionTDMediator )
                _G.g_FactionTDMediator = nil
            end
            self.m_stageView:exitCopy()
        elseif scenesType == _G.Const.CONST_MAP_TYPE_THOUSAND then
            self.m_stageView:IkkiTousen_finishCopy()
        elseif scenesType == _G.Const.CONST_MAP_TYPE_PK_LY then
            self.m_stageView:exitLingYao()
        else
            self.m_stageView:exitCopy()
        end
    end

    local str = ""
    if scenesType== _G.Const.CONST_MAP_TYPE_BOSS then
        str = _G.Lang.ERROR_N[18]
    elseif scenesType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS then
        str = _G.Lang.ERROR_N[151]
    elseif scenesType == _G.Const.CONST_MAP_TYPE_INVITE_PK then
        str =  _G.Lang.ERROR_N[19]
    elseif scenesType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL 
        or scenesType == _G.Const.CONST_MAP_TYPE_KOF
        or scenesType == _G.Const.CONST_MAP_TYPE_COPY_MONEY
        or scenesType == _G.Const.CONST_MAP_TYPE_PK_LY then
        str =  _G.Lang.ERROR_N[20]
    elseif scenesType == _G.Const.CONST_MAP_CLAN_WAR then
        str =  _G.Lang.ERROR_N[21]
    elseif scenesType == _G.Const.CONST_MAP_TYPE_CITY_BOSS then
        str =  _G.Lang.ERROR_N[22]
    else
        str =  _G.Lang.ERROR_N[23]
    end

    _G.Util:showTipsBox(str,onCallBack)
    -- self.m_stageView.m_lpScene:addChild(btn,10000)
end

--{托管}
function BattleView.addhostingBtn( self, _container, autoFight)
    local function selectedEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then

            -- if not _G.SysInfo:isDevelopType() then
                -- if _G.GPropertyProxy:getMainPlay():getVipLv() < _G.Const.CONST_WAR_ZIDONG_VIP 
                --     and _G.GPropertyProxy:getMainPlay():getLv() < _G.Const.CONST_WAR_ZIDONG_LV then 
                --     local command = CErrorBoxCommand(14320)
                --     controller : sendCommand( command )
                --     sender:setSelected(false)
                --     return 
                -- end
            -- end
            self.m_stageView:startAutoFight()
            self.yellowSpr : setVisible(true)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self.m_stageView:stopAutoFight()
            self.yellowSpr : setVisible(false)
        end
    end
    local node = cc.Node:create()
    node:setPosition(cc.p(P_CON_SX+P_CON_WID,P_CON_Y))
    self.yellowSpr = cc.Sprite:createWithSpriteFrameName("battle_automatic_2.png")
    self.yellowSpr : setVisible(false)
    self.yellowSpr : setPosition(5,-5)
    node:addChild(self.yellowSpr)
    local checkbox = ccui.CheckBox:create()
    checkbox:loadTextures("battle_hand_operation.png","battle_hand_operation.png","battle_automatic.png","","",ccui.TextureResType.plistType)
    -- checkbox:setPosition(cc.p(P_CON_SX+P_CON_WID,P_CON_Y))
    checkbox:addEventListener(selectedEvent)
    node:addChild(checkbox)
    _container : addChild(node,-30)
    self.m_checkbox=checkbox
    if autoFight then
        checkbox:setSelected(true)
        self.m_stageView:startAutoFight()
        self.yellowSpr : setVisible(true)
    end
end

function BattleView.addAutoFightTips(self,_container)
    if self.m_checkbox~=nil then
        self.m_checkbox:setSelected(true)
        self.yellowSpr : setVisible(true)
    end
    -- local checkbox = self.m_stageView.m_lpMessageContainer:getChildByTag(168888)
    -- if checkbox~=nil then
    --     checkbox:setSelected(true)
    -- end

    local autoFightTips = self.m_stageView.m_lpMessageContainer:getChildByTag(16888)
    if autoFightTips~=nil then
        autoFightTips:removeFromParent(true)
    end

    local autoFightTips = cc.Sprite:createWithSpriteFrameName("battle_automatic_3.png")
    autoFightTips:setPosition(cc.p(P_WINSIZE.width/2-100,P_WINSIZE.height-105))
    autoFightTips:setTag(16888)
    _container:addChild(autoFightTips)

    local autoFightPoints = {}
    for i=1,3 do
        local autoFightPoint= cc.Sprite:createWithSpriteFrameName("battle_automatic_4.png")
        local x = 145+(i-1)*12
        local lowY = 6
        local highY = 24
        autoFightPoint:setPosition(cc.p(x,lowY))
        autoFightTips:addChild(autoFightPoint)
        local move1
        local move2
        local delay1
        local delay2
        if i==1 then
            delay1=cc.DelayTime:create(0.01)
            move1=cc.MoveTo:create(0.16,cc.p(x,highY))
            move2=cc.MoveTo:create(0.16,cc.p(x,lowY))
            delay2=cc.DelayTime:create(0.83)
        elseif i==2 then
            delay1=cc.DelayTime:create(0.32)
            move1=cc.MoveTo:create(0.16,cc.p(x,highY))
            move2=cc.MoveTo:create(0.16,cc.p(x,lowY))
            delay2=cc.DelayTime:create(0.51)
        else
            delay1=cc.DelayTime:create(0.64)
            move1=cc.MoveTo:create(0.16,cc.p(x,highY))
            move2=cc.MoveTo:create(0.16,cc.p(x,lowY))
            delay2=cc.DelayTime:create(0.19)
        end
        local sequence=cc.Sequence:create(delay1,move1,move2,delay2)
        autoFightPoint:runAction(cc.RepeatForever:create(sequence))
    end
end

function BattleView.removeAutoFightTips(self,_container)
    print("BattleView.removeAutoFightTips=======?",debug.traceback())
    if self.m_checkbox~=nil then
        self.m_checkbox:setSelected(false)
        self.yellowSpr:setVisible(false)
    end
    -- local checkbox = self.m_stageView.m_lpMessageContainer:getChildByTag(168888)
    -- if checkbox~=nil then
    --     checkbox:setSelected(false)
    -- end
    -- _container:removeChildByTag(16888,true)
    local autoFightTips = self.m_stageView.m_lpMessageContainer:getChildByTag(16888)
    if autoFightTips~=nil then
        autoFightTips:removeFromParent(true)
    end
end

function BattleView.addGoNextCheckPointTips(self,_container)
    if _container:getChildByTag(16899)~=nil then
        CCLOG("BattleView.addGoNextCheckPointTips 已经创建了，不需要再创建")
        return
    end
    local nextCheckPointTips = cc.Sprite:createWithSpriteFrameName("battle_advance.png")
    local toPosition
    local fromPosition
    if _G.g_Stage.m_sceneDir>0 then
        nextCheckPointTips:setPosition(cc.p(P_WINSIZE.width-200,P_WINSIZE.height/2))
        toPosition =cc.p(P_WINSIZE.width-200,P_WINSIZE.height/2)
        fromPosition = cc.p(toPosition.x-20,toPosition.y)

        -- if self.m_stageView.m_plotFirstGame~=nil and self.m_stageView.m_nCheckPointID==2 then
        --     local tempNode=cc.Node:create()
        --     tempNode:setTag(16899)
        --     _container:addChild(tempNode)

        --     _container=tempNode

        --     local noticNode=_G.GGuideManager:createNoticNode("大王,前方还有大波妖怪!",true)
        --     noticNode:setPosition(P_WINSIZE.width - 200,220)
        --     tempNode:addChild(noticNode,20)
        -- end
    else
        nextCheckPointTips:setPosition(200,P_WINSIZE.height/2)
        nextCheckPointTips:setScaleX(-1)
        toPosition = cc.p(200,P_WINSIZE.height/2)
        fromPosition = cc.p(toPosition.x-20,toPosition.y)
    end

    nextCheckPointTips:setTag(16899)
    _container:addChild(nextCheckPointTips)

    local move1 = cc.EaseBounceInOut:create(cc.MoveTo:create(2/6,fromPosition))
    local move2 = cc.EaseBounceInOut:create(cc.MoveTo:create(2/6,toPosition))
    nextCheckPointTips:runAction(cc.RepeatForever:create(cc.Sequence:create(move1,move2)))
end

function BattleView.removeGoNextCheckPointTips(self,_container)
    _container:removeChildByTag(16899,true)
end

function BattleView.__createNoticBg(self,_container,_bgSize,_isleft,_pos,_ceng)
    local szNormal="general_fram_op_array.png"
    local button = gc.CButton:create(szNormal)
    local btnSize= button:getContentSize()
    local startPos,endPos,btnPos,offX,startRotation,endRotation
    local size2=cc.size(_bgSize.width+20,_bgSize.height)
    local tempWid=btnSize.width+2
    if _isleft==true then
        startPos=cc.p(size2.width/2-10,330)
        endPos=cc.p(-size2.width/2+tempWid,startPos.y)
        btnPos=cc.p(size2.width-btnSize.width/2,size2.height*0.5)
        offX=10
        startRotation=180
        endRotation=0
    else
        startPos=cc.p(P_WINSIZE.width-size2.width*0.5+10,470)
        endPos=cc.p(P_WINSIZE.width+size2.width*0.5-tempWid,startPos.y)
        btnPos=cc.p(btnSize.width/2,size2.height*0.5)
        offX=-10
        startRotation=0
        endRotation=180
    end
    if _pos then
        startPos = _pos
        endPos=cc.p(P_WINSIZE.width+size2.width-tempWid,startPos.y)
    end
    
    local tempSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_op.png")
    tempSpr:setPreferredSize(size2)
    tempSpr:setPosition(startPos)
    _container:addChild(tempSpr,_ceng or 0)

    local actionTimes=0.25
    local m_isNoticBgHide=false
    local function nFun(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local action1,action2
            if m_isNoticBgHide then
                m_isNoticBgHide=false
                sender:setRotation(startRotation)

                local act1=cc.MoveTo:create(actionTimes,cc.p(startPos.x+offX,startPos.y))
                local act2=cc.MoveTo:create(0.15,cc.p(startPos.x+4,startPos.y))
                local act3=cc.MoveTo:create(0.1,startPos)
                action2=cc.Sequence:create(act1,act2,act3)
            else
                m_isNoticBgHide=true
                sender:setRotation(endRotation)

                local act1=cc.MoveTo:create(0.1,cc.p(startPos.x+offX,startPos.y))
                local act2=cc.MoveTo:create(actionTimes,endPos)
                action2=cc.Sequence:create(act1,act2)
            end

            tempSpr:stopAllActions()
            tempSpr:setVisible(true)
            tempSpr:runAction(action2)
        end
    end

    button:setRotation(startRotation)
    button:addTouchEventListener(nFun)
    button:setPosition(btnPos)
    button:ignoreContentAdaptWithSize(false)
    button:setContentSize(cc.size(60,_bgSize.height))
    tempSpr:addChild(button)

    return tempSpr
end

function BattleView.addNormalCopyCondition(self,_container,_preTimes)
    local copyId=self.m_stageView:getScenesCopyID()
    local copyCnf=_G.Cfg.scene_copy[copyId]

    local protectNpcType=copyCnf.npc_survival or _G.Const.CONST_COPY_PASS_NPC0
    local limitTimes=copyCnf.pass_condition and copyCnf.pass_condition[2] or 0
    self.m_passType=copyCnf.pass_condition and copyCnf.pass_condition[1] or _G.Const.CONST_COPY_PASS_TYPE1

    -- protectNpcType=_G.Const.CONST_COPY_PASS_NPC1
    -- self.m_passType=_G.Const.CONST_COPY_PASS_TYPE1
    -- limitTimes=60

    self.m_stageView.m_protectNpcType=protectNpcType
    
    local cCount=0
    local npcNoticLabel=nil
    if protectNpcType==_G.Const.CONST_COPY_PASS_NPC1 then
        npcNoticLabel=_G.Util:createLabel("保证您的配角不被击杀",16)
        cCount=cCount+1
    elseif protectNpcType==_G.Const.CONST_COPY_PASS_NPC2 then
        npcNoticLabel=_G.Util:createLabel("保证所有龙套不被击杀",16)
        cCount=cCount+1
    end

    local passNoticLabel,timeLabel1,timeLabel2=nil
    if self.m_passType==_G.Const.CONST_COPY_PASS_TYPE1 then
        passNoticLabel=_G.Util:createLabel("击杀所有怪物",16)
        cCount=cCount+1
    elseif self.m_passType==_G.Const.CONST_COPY_PASS_TYPE2 then
        passNoticLabel=_G.Util:createLabel("击杀所有怪物",16)
        timeLabel1=_G.Util:createLabel("限时:",16)
        timeLabel2=_G.Util:createLabel("",16)
        cCount=cCount+2
    elseif self.m_passType==_G.Const.CONST_COPY_PASS_TYPE3 then
        passNoticLabel=_G.Util:createLabel("在规定时间内存活",16)
        timeLabel1=_G.Util:createLabel("限时:",16)
        timeLabel2=_G.Util:createLabel("",16)
        cCount=cCount+2
    end

    local taskSprSize
    if cCount==1 then
        taskSprSize=cc.size(215,70)
    elseif cCount==2 then
        taskSprSize=cc.size(215,80)
    else
        taskSprSize=cc.size(215,110)
    end
    
    local taskSpr=self:__createNoticBg(_container,taskSprSize)

    local tempX=45
    if npcNoticLabel then
        if timeLabel1 and timeLabel2 then
            npcNoticLabel:setAnchorPoint(cc.p(0,0.5))
            passNoticLabel:setAnchorPoint(cc.p(0,0.5))
            timeLabel1:setAnchorPoint(cc.p(0,0.5))
            timeLabel2:setAnchorPoint(cc.p(0,0.5))

            timeLabel1:setPosition(tempX,taskSprSize.height-25)
            timeLabel2:setPosition(tempX+40,taskSprSize.height-25)
            npcNoticLabel:setPosition(tempX,taskSprSize.height*0.5)
            passNoticLabel:setPosition(tempX,taskSprSize.height*0.23)

            taskSpr:addChild(passNoticLabel)
            taskSpr:addChild(npcNoticLabel)
            taskSpr:addChild(timeLabel1)
            taskSpr:addChild(timeLabel2)
        else
            npcNoticLabel:setAnchorPoint(cc.p(0,0.5))
            passNoticLabel:setAnchorPoint(cc.p(0,0.5))

            npcNoticLabel:setPosition(tempX,taskSprSize.height-25)
            passNoticLabel:setPosition(tempX,25)

            taskSpr:addChild(passNoticLabel)
            taskSpr:addChild(npcNoticLabel)
        end
    else
        if timeLabel1 and timeLabel2 then
            passNoticLabel:setAnchorPoint(cc.p(0,0.5))
            timeLabel1:setAnchorPoint(cc.p(0,0.5))
            timeLabel2:setAnchorPoint(cc.p(0,0.5))

            timeLabel1:setPosition(tempX,taskSprSize.height-25)
            timeLabel2:setPosition(tempX+40,taskSprSize.height-25)
            passNoticLabel:setPosition(tempX,25)

            taskSpr:addChild(passNoticLabel)
            taskSpr:addChild(timeLabel1)
            taskSpr:addChild(timeLabel2)
        else
            passNoticLabel:setAnchorPoint(cc.p(0,0.5))
            passNoticLabel:setPosition(tempX,taskSprSize.height*0.5)
            taskSpr:addChild(passNoticLabel)
        end
    end
    self.m_normalLimitTimeLabel=timeLabel2
    if self.m_normalLimitTimeLabel then
        local curTime=_G.TimeUtil:getTotalMilliseconds()
        self.m_conditionTimes=_preTimes or curTime

        self.m_normalLimitTimes=_preTimes or limitTimes
        self.m_normalSaveTimes=_G.TimeUtil:getTotalMilliseconds()

        self.m_stageView:setRemainingTime(self.m_normalLimitTimes,"倒计时")
        self.m_normalLimitTimeLabel:setString(self:getTimesStr(self.m_normalLimitTimes))
    end

    if _G.SysInfo:isIpNetwork() then
        local function local_btncallback(sender,eventType)
            if eventType==ccui.TouchEventType.ended then
                _G.g_Stage:finishCopy()
            end
        end
        local tempBtn=gc.CButton:create("general_myinput.png")
        tempBtn:setPosition(taskSprSize.width*0.5,-25)
        tempBtn:setTitleFontName(_G.FontName.Heiti)
        tempBtn:setTitleText("立刻完成")
        tempBtn:addTouchEventListener(local_btncallback)
        tempBtn:setTitleFontSize(20)
        taskSpr:addChild(tempBtn)
    end
end
function BattleView.updateNormalCopyTimes(self,_time)
    if not self.m_normalLimitTimeLabel then return end
    if self.m_stageView:isPlotPlaying() then return end

    local subTimes=_time - self.m_normalSaveTimes
    subTimes=self.m_normalLimitTimes - subTimes*0.001 + self.m_stageView.m_plotUseTime

    self.m_normalLimitTimeLabel:setString(self:getTimesStr(subTimes))

    if subTimes<=0 then
        if self.m_passType==_G.Const.CONST_COPY_PASS_TYPE2 then
            self.m_stageView.m_lpPlay:setHP(-12345)
        else
            self.m_stageView:stopAllCharacterAI()
            if self.m_stageView.isAutoFightMode==true then
                self.m_stageView:stopAutoFight(true)
            end

            self.m_stageView:passWar()
        end
    end
end
function BattleView.getNormalCopyRemainingTimes(self)
    if self.m_normalLimitTimes then
        local curTime=_G.TimeUtil:getTotalMilliseconds()
        local subTimes=curTime - self.m_normalSaveTimes
        subTimes=self.m_normalLimitTimes - subTimes*0.001 + self.m_stageView.m_plotUseTime
        subTimes=subTimes>0 and subTimes or 0
        return math.floor(subTimes)
    end
end

-- {组队副本-条件提示}
function BattleView.addZuDuiCondition(self,_container,_preTimes,_roleNum)
    if self.m_zuduiConditionSpr ~= nil then
        self.m_zuduiConditionSpr : removeFromParent(true)
        self.m_zuduiConditionSpr = nil
    end

    local taskSprSize=cc.size(230,110)
    local taskSpr=self:__createNoticBg(_container,taskSprSize)
    self.m_zuduiConditionSpr = taskSpr

    local copyId=self.m_stageView:getScenesCopyID()
    local copyCnf=_G.Cfg.scene_copy[copyId]
    if copyCnf==nil or copyCnf.over_score==nil then return end

    local condition2=copyCnf.over_score[1][2] or 0
    local condition3=copyCnf.over_score[2][2] or 0
    local type2=copyCnf.over_score[1][1] or 1
    local type3=copyCnf.over_score[2][1] or 1
    local nPosX=67
    local nPosY=taskSprSize.height-20
    local fontSize=16

    local tLabel=_G.Util:createLabel("时间:",fontSize)
    tLabel:setPosition(nPosX-20,nPosY)
    tLabel:setAnchorPoint(P_POINT_LEFT)
    taskSpr:addChild(tLabel)

    local tLbSize=tLabel:getContentSize()
    local curTime=_G.TimeUtil:getTotalMilliseconds()
    self.m_conditionTimes=_preTimes or curTime
    local subTimes=(curTime-self.m_conditionTimes)*0.001
    local szTime=self:getTimesStr(subTimes)
    self.m_conditionTimesLb=_G.Util:createLabel(szTime,fontSize)
    self.m_conditionTimesLb:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.m_conditionTimesLb:setAnchorPoint(P_POINT_LEFT)
    self.m_conditionTimesLb:setPosition(nPosX+tLbSize.width-20,nPosY)
    taskSpr:addChild(self.m_conditionTimesLb)
    
    local szCond2,szCond3,delayT2,delayT3
    if type2==1 then
        szCond2=P_STRING_FORMAT("存活人数不少于%d人",condition2)
    else
        szCond2=P_STRING_FORMAT("通关时间不超过%d秒",condition2)
        delayT2=condition2-subTimes
        delayT2=delayT2>0 and delayT2 or 0
    end
    if type3==1 then
        szCond3=P_STRING_FORMAT("存活人数不少于%d人",condition3)
    else
        szCond3=P_STRING_FORMAT("通关时间不超过%d秒",condition3)
        delayT3=condition3-subTimes
        delayT3=delayT3>0 and delayT3 or 0
    end
    local lbCondition={0,0,0}
    lbCondition[1]=_G.Util:createLabel("成功通关",fontSize)
    lbCondition[2]=_G.Util:createLabel(szCond2,fontSize)
    lbCondition[3]=_G.Util:createLabel(szCond3,fontSize)
    self.m_condSurplusRoleArray={}
    self.m_condSurplusTimeArray={}
    self.m_condSurplusRoleNum=_roleNum
    -- local function nFun(_sprite)
    --     _sprite:setGray()
    -- end
    for i=1,3 do
        local nnnnY=nPosY-i*23
        local tempStarSpr=gc.GraySprite:createWithSpriteFrameName("general_star2.png")
        tempStarSpr:setPosition(nPosX-13,nnnnY)
        tempStarSpr:setScale(0.8)
        taskSpr:addChild(tempStarSpr)

        lbCondition[i]:setPosition(nPosX,nnnnY)
        lbCondition[i]:setAnchorPoint(P_POINT_LEFT)
        taskSpr:addChild(lbCondition[i])
        if i==2 then
            if type2==2 then
                -- tempStarSpr:runAction(cc.Sequence:create(cc.DelayTime:create(delayT2),cc.CallFunc:create(nFun)))
                self.m_condSurplusTimeArray[i]={}
                self.m_condSurplusTimeArray[i].starSpr=tempStarSpr
                self.m_condSurplusTimeArray[i].time=condition2+1
            elseif condition2>_roleNum then
                tempStarSpr:setGray()
            else
                
                self.m_condSurplusRoleArray[i]={}
                self.m_condSurplusRoleArray[i].starSpr=tempStarSpr
                self.m_condSurplusRoleArray[i].num=condition2
            end
        end
        if i==3 then
            if type3==2 then
                -- tempStarSpr:runAction(cc.Sequence:create(cc.DelayTime:create(delayT3),cc.CallFunc:create(nFun)))
                self.m_condSurplusTimeArray[i]={}
                self.m_condSurplusTimeArray[i].starSpr=tempStarSpr
                self.m_condSurplusTimeArray[i].time=condition3+1
            elseif condition3>_roleNum then
                tempStarSpr:setGray()
            else
                self.m_condSurplusRoleArray[i]={}
                self.m_condSurplusRoleArray[i].starSpr=tempStarSpr
                self.m_condSurplusRoleArray[i].num=condition3
            end
        end
    end

    self.m_stageView:setRemainingTime(condition3,"倒计时")
end
--一骑当千
function BattleView.addCopyTotal( self,_container )
    local scenesType = self.m_stageView:getScenesType()
    
    local taskSprSize=cc.size(230,100)
    if scenesType == _G.Const.CONST_MAP_TYPE_COPY_MONEY then
        taskSprSize=cc.size(230,70)
    end

    local taskSpr=self:__createNoticBg(_container,taskSprSize)

    local labelSize,posX,posY,label

    if scenesType == _G.Const.CONST_MAP_TYPE_COPY_MONEY then
        label       = _G.Util:createLabel("造成伤害:",20)
        label       : setPosition(90,taskSprSize.height*0.5)
        taskSpr     : addChild(label)
        labelSize   = label:getContentSize()
        posX,posY   = label:getPosition()

        self.m_totalHurtLabel = _G.Util:createLabel("0",20)
        self.m_totalHurtLabel : setAnchorPoint(0,0.5)
        self.m_totalHurtLabel : setPosition(posX+labelSize.width/2+2,posY)
        self.m_totalHurtLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        taskSpr     : addChild(self.m_totalHurtLabel)
    else
        label       = _G.Util:createLabel("消耗时间:",20)
        label       : setPosition(90,taskSprSize.height-32)
        taskSpr     : addChild(label)
        labelSize   = label:getContentSize()
        posX,posY   = label:getPosition()

        self.m_totalTimeLabel = _G.Util:createLabel("00:00",20)
        self.m_totalTimeLabel : setPosition(posX+labelSize.width/2+2,posY)
        self.m_totalTimeLabel : setAnchorPoint(0,0.5)
        self.m_totalTimeLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        taskSpr     : addChild(self.m_totalTimeLabel)

        posY        = 32
        label       = _G.Util:createLabel("造成伤害:",20)
        label       : setPosition(posX,posY)
        taskSpr     : addChild(label)
        labelSize   = label:getContentSize()
        posX,posY   = label:getPosition()

        self.m_totalHurtLabel = _G.Util:createLabel("0",20)
        self.m_totalHurtLabel : setAnchorPoint(0,0.5)
        self.m_totalHurtLabel : setPosition(posX+labelSize.width/2+2,posY)
        self.m_totalHurtLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        taskSpr     : addChild(self.m_totalHurtLabel)
    end
end
--降魔之路
function BattleView.addRoadCopyTotal( self,_container,time )
    local taskSprSize=cc.size(230,100)
    local taskSpr=self:__createNoticBg(_container,taskSprSize)

    local labelSize,posX,posY
    local label = _G.Util:createLabel("时间:",18)
    label       : setPosition(45,taskSprSize.height-25)
    label       : setAnchorPoint(cc.p(0,0.5))
    taskSpr     : addChild(label)
    labelSize   = label:getContentSize()
    posX,posY   = label:getPosition()

    local curTime=_G.TimeUtil:getTotalMilliseconds()
    self.m_futuOutTimes=time
    local subTimes=time-curTime
    local szTime=self:getTimesStr(subTimes*0.001)
    self.m_futuOutTimesLabel = _G.Util:createLabel(szTime,18)
    self.m_futuOutTimesLabel : setPosition(posX+labelSize.width,posY)
    self.m_futuOutTimesLabel : setAnchorPoint(0,0.5)
    self.m_futuOutTimesLabel : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    taskSpr     : addChild(self.m_futuOutTimesLabel)

    local copyId=self.m_stageView:getScenesCopyID()
    local copyCnf=_G.Cfg.scene_copy[copyId]

    posY = posY - 50
    -- posX = taskSprSize.width/2+7
    label       = _G.Util:createLabel(copyCnf.desc,18)
    label       : setPosition(posX,posY)
    label       : setAnchorPoint(cc.p(0,0.5))
    taskSpr     : addChild(label)   
    label       : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label       : setDimensions(190, 65)
    self.m_stageView:setRemainingTime(100)
    
end
function BattleView.updateConditionTimes(self,_time)
    local subTimes=_time-self.m_conditionTimes
    local stime=subTimes*0.001-self.m_stageView.m_plotUseTime
    local szTime=self:getTimesStr(stime)
    self.m_conditionTimesLb:setString(szTime)
    local time2,time3
    if self.m_condSurplusTimeArray[2]~=nil then
        time2=self.m_condSurplusTimeArray[2].time
    end
    if self.m_condSurplusTimeArray[3]~=nil then
        time3=self.m_condSurplusTimeArray[3].time
    end
    if time2 and stime>time2 then
        self.m_condSurplusTimeArray[2].starSpr:setGray()
        self.m_condSurplusTimeArray[2].time=nil
    end
    if time3 and stime>time3 then
        self.m_condSurplusTimeArray[3].starSpr:setGray()
        self.m_condSurplusTimeArray[3].time=nil
    end
end
function BattleView.conditionSubRole(self)
    if self.m_condSurplusRoleNum==nil then return end

    self.m_condSurplusRoleNum=self.m_condSurplusRoleNum-1
    for k,v in pairs(self.m_condSurplusRoleArray) do
        local starSpr=v.starSpr
        local nNum=v.num
        if nNum>self.m_condSurplusRoleNum then
            starSpr:setGray()
            self.m_condSurplusRoleArray[k]=nil
        end
    end
end

-- {通天浮图-提示}
function BattleView.addTuFuNotic(self,_container,_outTimes)
    local futuSprSize=cc.size(215,80)
    local futuSpr=self:__createNoticBg(_container,futuSprSize)

    local copyId=self.m_stageView:getScenesCopyID()
    local copyCnf=_G.Cfg.scene_copy[copyId]
    if copyCnf==nil or copyCnf.over_score==nil then return end
    local chapId=copyCnf.belong_id
    local chapArrayCnf=_G.Cfg.copy_chap[_G.Const.CONST_COPY_TYPE_FIGHTERS]
    if chapArrayCnf[chapId]==nil then return end
    local copyArray=chapArrayCnf[chapId].copy_id
    local tempArray={}
    local tempCount=0
    for k,v in pairs(chapArrayCnf) do
        tempCount=tempCount+1
        tempArray[tempCount]=k
    end
    local function nSort(v1,v2)
        return v1<v2
    end
    table.sort(tempArray,nSort)
    local chapFloor,copyPos
    for i=1,tempCount do
        if tempArray[i]==chapId then
            chapFloor=i
            break
        end
    end
    for i=1,#copyArray do
        if copyArray[i]==copyId then
            copyPos=i
            break
        end
    end
    chapFloor=chapFloor or 0
    copyPos=copyPos or 0
    local szCopyInfo=P_STRING_FORMAT("当前关卡:第%s层 第%d关",_G.Lang.number_Chinese[chapFloor],copyPos)
    local fontSize=16
    local lbCondition={0,0}
    lbCondition[1]=_G.Util:createLabel(szCopyInfo,fontSize)
    lbCondition[2]=_G.Util:createLabel("剩余时间:",fontSize)

    local nPosX=45
    local nPosY=futuSprSize.height-25
    for i=1,#lbCondition do
        lbCondition[i]:setAnchorPoint(P_POINT_LEFT)
        lbCondition[i]:setPosition(nPosX,nPosY)
        futuSpr:addChild(lbCondition[i])

        if i==2 then
            local tLbSize=lbCondition[i]:getContentSize()
            local curTime=_G.TimeUtil:getTotalMilliseconds()

            local subTimes=_outTimes-curTime
            local szTime=self:getTimesStr(subTimes*0.001)
            self.m_futuOutTimesLabel=_G.Util:createLabel(szTime,fontSize)
            self.m_futuOutTimesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
            self.m_futuOutTimesLabel:setAnchorPoint(P_POINT_LEFT)
            self.m_futuOutTimesLabel:setPosition(nPosX+tLbSize.width+5,nPosY)
            futuSpr:addChild(self.m_futuOutTimesLabel)
            self.m_futuOutTimes=_outTimes
        end
        nPosY=nPosY-30
    end
    self.m_futuCopyFloor=chapFloor
    self.m_futuCopyPos=copyPos
    self.m_stageView:setRemainingTime(10,"倒计时")
end
function BattleView.updateFutuOutTimes(self,_time)
    local subTimes=self.m_futuOutTimes-_time
    local szTime=self:getTimesStr(subTimes*0.001)
    self.m_futuOutTimesLabel:setString(szTime)
    if subTimes<0 then
        self.m_stageView:setRemainingTime()
        self.m_stageView.m_lpPlay:setHP(-12345)
    end
end

function BattleView.getTimesStr(self,_time)
    _time = _time < 0 and 0 or _time
    local hor  = math.floor( _time/3600)
    hor = hor < 0 and 0 or hor
    local min  = math.floor( _time/60-hor*60)
    min = min < 0 and 0 or min
    local sec  = math.floor( _time-hor*3600-min*60)
    sec = sec < 0 and 0 or sec
    return P_STRING_FORMAT("%02d:%02d:%02d",hor,min,sec)
end

--{显示 剩余时间}
function BattleView.showRemainingTime( self, _time , _container,_timeTips,_colorIdx)
    local szTime=self:getTimesStr(_time)

    local x = P_WINSIZE.width/2
    local y = P_WINSIZE.height-67
    local timerBgSprite,contentSize
    if self.m_stageView:getScenesType()==_G.Const.CONST_MAP_TYPE_PK_LY then
        timerBgSprite = cc.Sprite:createWithSpriteFrameName("battle_lingyao_time_bg.png")
        contentSize = timerBgSprite:getContentSize()
        contentSize = cc.size(contentSize.width,46)
        y=P_WINSIZE.height-60
    else
        timerBgSprite = cc.Sprite:createWithSpriteFrameName("battle_time_bg.png")
        contentSize = timerBgSprite:getContentSize()
    end

    local timeLabel =nil
    if _timeTips~=nil then
        local timeStr = P_STRING_FORMAT("%s %s",_timeTips,szTime)
        timeLabel =_G.Util:createLabel(timeStr,24)
    else
        timeLabel =_G.Util:createLabel(szTime,24)
    end
    
    local colorIdx=_colorIdx or _G.Const.CONST_COLOR_WHITE
    timeLabel:setColor(_G.ColorUtil :getRGBA(colorIdx))
    timeLabel:setPosition(contentSize.width/2,contentSize.height/2)
    timerBgSprite:addChild(timeLabel)

    -- local dHeight=20
    -- if self.m_stageView:getScenesType()==_G.Const.CONST_MAP_CLAN_WAR then
    --     dHeight=10
    -- end

    if self.m_stageView:getScenesType()==_G.Const.CONST_MAP_TYPE_THOUSAND then
        x = P_WINSIZE.width/4*3+110
        y = P_WINSIZE.height/2+120
    end

    timerBgSprite:setPosition( cc.p( x, y ) )
    _container:addChild(timerBgSprite)
end

function BattleView.addTimeString( self, _timeSprite, _str, _isleft, _timeSpriteSize)
    local strlen = P_STRING_LEN(_str)
    local startIndex = _isleft == true and strlen or 1
    local endIndex   = _isleft == true and 1 or strlen
    local steps      = _isleft == true and -1 or 1

    local x = _timeSpriteSize.width / 2
    x = _isleft == true and -x or x
    for i = startIndex,endIndex,steps do
        local strCurrent = P_STRING_SUB(_str,i,i)
        local numSprite = CSprite : createWithSpriteFrameName( "battle_"..strCurrent..".png" )
        numSprite : setControlName( "this BattleView numSprite 131 ")
        local numSpriteSize = numSprite : getPreferredSize()
        _timeSprite : addChild( numSprite )
        local addx = numSpriteSize.width/2
        addx = _isleft == true and -addx or addx
        x = x + addx
        numSprite : setPosition( cc.p( x, 0 ) )
        x = x + addx
    end
end

--{时间转字符串}
function BattleView.toTimeString( self, _num )
    _num = _num <=0 and "00" or _num
    if type(_num) ~= "string" then
        _num = _num >=10 and P_TOSTRING(_num) or ("0"..P_TOSTRING(_num))
    end
    return _num
end

function BattleView.showStageName( self,_container,stageName)
    if stageName==nil then return end

    local nameLabel =_G.Util:createBorderLabel(stageName,28)
    nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    _container:addChild(nameLabel)
    
    -- if self.m_stageView:getScenesType()==_G.Const.CONST_MAP_CLAN_WAR then
        nameLabel:setPosition(cc.p(P_WINSIZE.width/2,P_WINSIZE.height-30))
    -- else
        -- nameLabel:setPosition(cc.p(P_WINSIZE.width/2,P_WINSIZE.height-30))
    -- end
end

function BattleView.cleanupDPS( self )
    self.m_dps = nil
    self.m_bIsShowAllDps = false

    self.m_lpSpriteBossDead = nil
    self.m_lpTipsTTF = nil
    self.m_lpTimeTTF = nil
end

function BattleView.showDps(self)
    local container = self.m_stageView.m_lpUIContainer
    
    local dpsSize = cc.size(285,185)
    local bgCon = self:__createNoticBg(container,dpsSize,true)

    local posX = {40,125,220}
    local posY = dpsSize.height-18
    local height = 23
    local label = _G.Util:createLabel("排名",18)
    label : setPosition(posX[1],posY)
    -- label : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    bgCon : addChild(label)
    label = _G.Util:createLabel("玩家名称",18)
    label : setPosition(posX[2],posY)
    -- label : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    bgCon : addChild(label)
    label = _G.Util:createLabel("伤害率",18)
    label : setPosition(posX[3],posY)
    -- label : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    bgCon : addChild(label)
    self.m_dpsLabels = {}
    for i=1,6 do
        self.m_dpsLabels[i] = {}
        for j=1,3 do
            label = _G.Util:createLabel("",18)
            label : setPosition(posX[j],posY-height*i-5)
            bgCon : addChild(label)
            self.m_dpsLabels[i][j]=label
            -- if i==6 then
            --     label : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
            -- else
            --     label : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
            -- end
        end
    end
end

function BattleView.updateDps(self,_ackMsg)
    if _ackMsg==nil or self.m_dpsLabels==nil then return end
    local topFive = nil
    for _,v in pairs(self.m_dpsLabels) do
        for i=1,3 do
            local dpsLabel=self.m_dpsLabels[i]
            dpsLabel[i] : setString("")
        end
    end
    local myUid = _G.GPropertyProxy:getMainPlay():getUid()
    if _ackMsg.count < 6 or _ackMsg.self_rank==0 then 
        topFive = true
    end
    print( "_ackMsg.count ====>>> ", _ackMsg.count, _ackMsg.data )
    for k,hurtData in pairs(_ackMsg.data) do
        local dpsLabel=self.m_dpsLabels[k]
        dpsLabel[1] : setString(hurtData.rank)
        dpsLabel[2] : setString(hurtData.name)
        local percentage = string.format("%.2f",hurtData.harm/_ackMsg.boss_hp * 100)
        dpsLabel[3] : setString(percentage.."%")
        if hurtData.uid==myUid then
            topFive=true
            for k,v in pairs(dpsLabel) do
                v:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
            end
        else
            for k,v in pairs(dpsLabel) do
                v:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_WHITE))
            end
        end
    end

    if not topFive and myUid == _ackMsg.uid then
        self.m_dpsLabels[6][1] : setString(_ackMsg.self_rank)
        self.m_dpsLabels[6][2] : setString(_G.GPropertyProxy:getMainPlay():getName())
        local percentage = string.format("%.2f",_ackMsg.self_harm/_ackMsg.boss_hp * 100)
        self.m_dpsLabels[6][3] : setString(percentage.."%")

        for k,v in pairs(self.m_dpsLabels[6]) do
            v:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
        end

    end
end

--人物死亡后的提示 414 280
function BattleView.showBossDeadView(self,_rmb,string)
    if self.m_lpSpriteBossDead~=nil then
        return
    end
    
    local container = self.m_stageView.m_lpUIContainer
    if container == nil then
        return
    end

    self : hideBossDeadView()

    local function tipsSure()
        if self.m_stageView:getScenesType()==_G.Const.CONST_MAP_TYPE_COPY_BOX then
            local msg=REQ_MIBAO_REVIVE()
            msg:setArgs(1)
            _G.Network:send(msg)
        else
            local msg=REQ_WORLD_BOSS_REVIVE()
            msg:setArgs(1)
            _G.Network:send(msg)
        end
    end
    local function cancel()
        
    end

    local tipsBox = require("mod.general.TipsBox")()
    local layer   = tipsBox :create( "", tipsSure, cancel,true,true)
    -- layer       : setPosition(P_WINSIZE.width/2,P_WINSIZE.height/2)
    container   : addChild(layer,-30)
    tipsBox     : setTitleLabel("提 示")
    layer       : setTag(414280)
    tipsBox     : setSureBtnText("复活")
    tipsBox     : hideCancelBtn()
    local layer=tipsBox:getMainlayer()
    self.m_lpSpriteBossDead = layer

    local P_VIEW_SIZE = cc.size(390,270)

    local posY = 60
    local posX = -110
    local fontSize=24
    if string ~= nil then
        posX=0
        local nameLab = _G.Util:createLabel(string,22)
        nameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
        nameLab : setPosition(posX,posY)
        nameLab : setAnchorPoint(0.5,0)
        layer:addChild(nameLab)
        local labSize = nameLab:getContentSize()

        posX = -labSize.width/2
        nameLab=_G.Util:createLabel("你被",22)
        nameLab:setPosition(posX,posY)
        nameLab:setAnchorPoint(1,0)
        -- nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
        layer:addChild(nameLab)
        -- labSize = nameLab:getContentSize()

        posX = labSize.width/2
        nameLab=_G.Util:createLabel("击杀",22)
        nameLab:setPosition(posX,posY)
        nameLab:setAnchorPoint(0,0)
        -- nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
        layer:addChild(nameLab)

        posY = 30
        posX = -100
        fontSize=22
    end

    local mainLab=_G.Util:createLabel("复活等待时间:",fontSize)
    mainLab:setPosition(posX,posY)
    mainLab:setAnchorPoint(0,0.5)
    -- mainLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    layer:addChild(mainLab)
    local labSize = mainLab:getContentSize()

    posX = posX + labSize.width + 2
    self.m_lpTimeTTF = _G.Util:createLabel("30",fontSize)
    self.m_lpTimeTTF : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.m_lpTimeTTF : setPosition(posX,posY)
    self.m_lpTimeTTF : setAnchorPoint(0,0.5)
    layer:addChild(self.m_lpTimeTTF)
    labSize = self.m_lpTimeTTF:getContentSize()

    posX = posX + labSize.width + 2
    mainLab=_G.Util:createLabel("秒",fontSize)
    mainLab:setPosition(posX,posY)
    mainLab:setAnchorPoint(0,0.5)
    -- mainLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    layer:addChild(mainLab)

    posY = 0
    posX = -30
    mainLab=_G.Util:createLabel("花费:",20)
    mainLab:setPosition(posX,posY)
    -- mainLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    layer:addChild(mainLab)
    labSize = mainLab:getContentSize()

    posX = posX + labSize.width*0.5 + 2
    mainLab = _G.Util:createLabel(tostring(_rmb),20)
    mainLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    mainLab : setPosition(posX,posY)
    mainLab : setAnchorPoint(0,0.5)
    layer:addChild(mainLab)
    labSize = mainLab:getContentSize()

    posX = posX + labSize.width + 2
    local spr=cc.Sprite:createWithSpriteFrameName("general_gold.png")
    spr:setPosition(posX,posY)
    spr:setAnchorPoint(0,0.5)
    layer:addChild(spr)

    local lab = _G.Util : createLabel( "（元宝不足则消耗钻石）", 18 )
    lab : setPosition( -10, -40 )
    -- lab : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE) )
    layer : addChild( lab )

end

--人物死亡后的提示 414 280
function BattleView.DefEnseDeadView(self)
    print( "人物死完" )
    if self.m_lpSpriteBossDead~=nil then
        return
    end
    
    local container = self.m_stageView.m_lpUIContainer
    if container == nil then
        return
    end
    
    self : hideBossDeadView()

    local function tipsSure( obj, eventType )
        if eventType==ccui.TouchEventType.ended then
            local msg  = REQ_DEFENSE_RESURREC()
            _G.Network : send( msg )
        end
        -- self.m_lpSpriteBossDead = nil
        -- self.m_lpTimeTTF=nil
    end
    local function cancel()
    
    end
 
    local tipsBox = require("mod.general.TipsBox")()
    local layer   = tipsBox :create( "", tipsSure, cancel,true, true)
    -- layer         : setPosition(cc.p(P_WINSIZE.width/2,P_WINSIZE.height/2))
    container     : addChild(layer,-11)
    layer         : setTag(414280)
    local layer=tipsBox:getMainlayer()
    self.m_lpSpriteBossDead = layer

    tipsBox : setTitleLabel("提 示")
    tipsBox : setSureBtnText( "立即复活" )
    tipsBox.m_sureButton : addTouchEventListener(tipsSure)
    tipsBox : hideCancelBtn()

    local node  = cc.Layer:create()
    local width = 0
    local myMoney = _G.Const.CONST_DEFENSE_RE_MONEY
    local lab1  = _G.Util : createLabel( "花费", 22 )
    local lab2  = _G.Util : createLabel( string.format( "%d%s", myMoney, "元宝" ), 22 )
    local lab3  = _G.Util : createLabel( "立即复活？", 22 )

    lab1 : setAnchorPoint( 0, 0.5 )
    lab2 : setAnchorPoint( 0, 0.5 )
    lab3 : setAnchorPoint( 0, 0.5 )

    lab1 : setPosition( width, 0 )
    width= width + lab1:getContentSize().width 
    lab2 : setPosition( width, 0 )
    width= width + lab2:getContentSize().width 
    lab3 : setPosition( width, 0 )
    width= width + lab3:getContentSize().width 

    node : setContentSize( width, 1 )
    node : setPosition( -width/2, 50 )
    layer: addChild( node,5 )


    lab2 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD ) )

    node : addChild(lab1,5)
    node : addChild(lab2,5)
    node : addChild(lab3,5)

    local lab4 = _G.Util : createLabel( "（元宝不足则消耗钻石）", 18 )
    lab4       : setPosition( 0, 15 )
    layer      : addChild( lab4 )

    local lab5 = _G.Util : createLabel( "复活等待时间：     秒", 20 )
    lab5       : setPosition( 0, -25 )
    layer      : addChild( lab5 )

    local myTime   = _G.Const.CONST_DEFENSE_RE_TIME 
    self.m_lpTimeTTF = _G.Util : createLabel( myTime, 20 )
    self.m_lpTimeTTF : setPosition( 70, -25 )
    self.m_lpTimeTTF : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
    self.m_lpTimeTTF : setAnchorPoint( 1, 0.5 )
    layer          : addChild( self.m_lpTimeTTF )
end

--城镇boss 人物死亡
-- 改
function BattleView.CityBossPlayerDeadView(self,_ackMag)
    if self.m_lpSpriteBossDead~=nil then
        return
    end
    
    local container = self.m_stageView.m_lpUIContainer
    if container == nil then
        return
    end
    
    self : hideBossDeadView()
    local embraveBg= CSprite:createWithSpriteFrameName("general_second_underframe.png")
    embraveBg:setPreferredSize(cc.size(400, 240))
    container:addChild(embraveBg,-11)
    embraveBg:setPosition(P_WINSIZE.width/2,P_WINSIZE.height/2)
    embraveBg:setTag(414280)

    self.m_lpSpriteBossDead=embraveBg

    local embraveFrame= CSprite:createWithSpriteFrameName("general_huabiank_tips.png")
    embraveFrame:setPreferredSize(cc.size(400, 240))
    embraveBg:addChild(embraveFrame)

    local embraveHead= cc.Sprite:createWithSpriteFrameName("general_gradient.png")
    embraveBg:addChild(embraveHead)
    embraveHead:setPosition(0,98)

    -- local boxFrame= CSprite:createWithSpriteFrameName("general_second_underframe.png")
    -- embraveBg:addChild(boxFrame)
    -- boxFrame:setPreferredSize(cc.size(380,180))
    -- boxFrame:setPosition(0,-17)

    local divideLine= cc.Sprite:createWithSpriteFrameName("general_dividing_line.png")
    divideLine:setScaleX(1.9)
    embraveBg:addChild(divideLine)
    divideLine:setPosition(0,73)

    local divideLine= cc.Sprite:createWithSpriteFrameName("general_dividing_line.png")
    divideLine:setScaleX(1.9)
    embraveBg:addChild(divideLine)
    divideLine:setPosition(0,0)

    local showTipsTTF = _G.Util:createLabel( _G.Lang.LAB_N[111],30 )
    self.m_lpSpriteBossDead:addChild(showTipsTTF)
    showTipsTTF:setColor(_G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD))
    showTipsTTF:setPosition(0, 98)

    local nameSkill = nil
    if _ackMag.type == 1 then
        if _ackMag.player_name == nil then
            nameSkill = _G.Lang.LAB_N[938]
        else            
            nameSkill = P_TOSTRING(_ackMag.player_name) 
        end       
    else
        local boss = _G.Cfg.scene_monster[_ackMag.boss_id]
        if boss == nil then
            nameSkill = _G.Lang.LAB_N[938]
        else
            nameSkill = P_TOSTRING(boss.monster_name) 
        end
    end

    local oColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_RED)
    local wColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_WHITE)

    local richText = cc.RichText:create(300,0)
    richText:setLineSpace(3)
    richText:setAnchorPoint(cc.p(0,1))
    richText:setPosition(cc.p(-150,60))

    richText :setDetailStyle( "Arial", 25, wColor )
    richText :appendRichText( _G.Lang.LAB_N[112], kTextStyleNormal, 1, 0 )
    richText :setDetailStyle( "Arial", 25, oColor )
    richText :appendRichText( nameSkill, kTextStyleNormal, 2, 0 )
    richText :setDetailStyle( "Arial", 25, wColor )
    richText :appendRichText( _G.Lang.LAB_N[113], kTextStyleNormal, 3, 0 )

    self.m_lpSpriteBossDead : addChild(richText)

    local exitBtn = CButton:createWithSpriteFrameName(_G.Lang.BTN_N[41],"general_login_click.png")
    exitBtn:setTouchesPriority(-99)
    exitBtn:setPosition(-100, -50)
    exitBtn:setFontSize(24)

    local reviveBtn = CButton:createWithSpriteFrameName(_G.Lang.BTN_N[42],"general_blue2button.png")
    reviveBtn:setTouchesPriority(-99)
    reviveBtn:setPosition(100, -50)
    reviveBtn:setFontSize(24)
    --  改！
    local reviveRMB = _G.Util:createLabel(P_STRING_FORMAT("%d%s",_G.Const.CONST_CLAN_BOSS_REPLAY_PRICE,_G.Lang.Currency_Type[2]),20)
    reviveRMB:setPosition(100, -90)
    self.m_lpSpriteBossDead : addChild(reviveRMB)

    local function onCallBack( eventType, obj, x, y)
        if eventType == "TouchBegan" then
            return obj:containsPoint(obj:convertToNodeSpaceAR(cc.p(x,y)))
        elseif eventType == "TouchEnded" then
            if obj == exitBtn then
                local msg=REQ_SCENE_ENTER_CITY()
                _G.Network:send(msg)
            end
        end
    end
    local function onRevive( eventType, obj, x, y)
        if eventType == "TouchBegan" then
            return obj:containsPoint(obj:convertToNodeSpaceAR(cc.p(x,y)))
        elseif eventType == "TouchEnded" then
            if obj == reviveBtn then
                local msg=REQ_WORLD_BOSS_REVIVE()
                msg:setArgs(1)
                _G.Network:send(msg)
            end
        end
    end

    exitBtn:registerControlScriptHandler(onCallBack)
    reviveBtn:registerControlScriptHandler(onRevive)
    self.m_lpSpriteBossDead : addChild(exitBtn)
    self.m_lpSpriteBossDead : addChild(reviveBtn)

end

function BattleView.setBossDeadTipsRMB( self, _num )
    if self.m_lpTipsTTF == nil then
        return
    end
    self.m_lpTipsTTF : setString(_G.Lang.LAB_N[211]..":".._G.Lang.LAB_N[712].._G.Lang.Currency_Type[2]..P_TOSTRING(_num) )
end

--删除BOSS死亡界面
function BattleView.hideBossDeadView( self )
    print("1BattleView.hideBossDeadView")
    if self.m_lpSpriteBossDead == nil then
        return
    end
    container = self.m_stageView:getUIContainer()
    if container ~= nil then
        local spriteBossDead = container:getChildByTag(414280)
        if spriteBossDead~=nil then
            spriteBossDead:removeFromParent( true )
        end
    end
    self.m_lpSpriteBossDead = nil
    self.m_lpTimeTTF=nil
end

--显示复活时间
function BattleView.showBossDeadViewString( self, _Time )
    if self.m_lpSpriteBossDead == nil then
        return
    end

    _Time = _Time < 0 and 0 or _Time
    local sec  = math.floor(_Time)
    sec = sec < 0 and 0 or sec
    sec = self: toTimeString( sec )

    if self.m_lpTimeTTF ~= nil then
        self.m_lpTimeTTF : setString(sec)
    end

    -- local labelStr = P_STRING_FORMAT("%sCD:%d%s",_G.Lang.BTN_N[3],sec,_G.Lang.LAB_N[538])

    -- if self.m_stageView:getScenesType() == _G.Const.CONST_MAP_CLAN_DEFENSE then
    --     labelStr = P_STRING_FORMAT("%d%s",sec,_G.Lang.LAB_N[713])
    --     if self.m_lpTimeTTF ~= nil then
    --         self.m_lpTimeTTF : setString(labelStr)
    --     else
    --         self.m_lpTimeTTF = _G.Util:createLabel(labelStr,30)
    --         self.m_lpSpriteBossDead : addChild(self.m_lpTimeTTF)
    --         self.m_lpTimeTTF:setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD))
    --     end
    --     -- 改
    -- elseif self.m_stageView:getScenesType() == _G.Const.CONST_MAP_TYPE_CITY_BOSS then
    --     labelStr = P_STRING_FORMAT("%d%s",sec,_G.Lang.LAB_N[714])
    --     if self.m_lpTimeTTF ~= nil then
    --         self.m_lpTimeTTF : setString(labelStr)
    --     else
    --         self.m_lpTimeTTF = _G.Util:createLabel(labelStr,20)
    --         self.m_lpSpriteBossDead : addChild(self.m_lpTimeTTF)
    --         self.m_lpTimeTTF:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    --     end    
    --     self.m_lpTimeTTF:setPosition(-100,-90)

    -- else
    --     if self.m_lpTimeTTF ~= nil then
    --         self.m_lpTimeTTF : setString(labelStr)
    --     else
    --         self.m_lpTimeTTF = _G.Util:createLabel(labelStr,30)
    --         self.m_lpSpriteBossDead : addChild(self.m_lpTimeTTF)
    --         self.m_lpTimeTTF:setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN))
    --     end
    -- end

end

function BattleView.showAttributeAdd(self,_container,_attributeAdds)
    if self.m_stageView.m_attributeLables==nil then
        self.m_stageView.m_attributeLables={}
    end

    for attrKey,attrValue in pairs(_attributeAdds) do
        if attrValue.labelName~=nil then

            labelText=P_STRING_FORMAT("%s +%.2d%%",attrValue.labelName,attrValue.labelValue*100)
            local labelTTF=self.m_stageView.m_attributeLables[attrKey]
            if labelTTF==nil then
                labelTTF=_G.Util:createLabel("",22)
                labelTTF:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
                _container:addChild(labelTTF)

                self.m_stageView.m_attributeLables[attrKey]=labelTTF
            end
            labelTTF:setString(labelText)
        end
    end

    local positionY = P_WINSIZE.height-130
    local index = 1
    for _,labelTTF in pairs(self.m_stageView.m_attributeLables) do
        labelTTF:setPosition(cc.p(P_WINSIZE.width-80,positionY-index*35))
        index=index+1
    end
end
function BattleView.removeAllAttributeAdd( self )
    self.m_stageView.m_attributeAdds={}
    if self.m_stageView.m_attributeLables==nil then return end
    for _,node in pairs(self.m_stageView.m_attributeLables) do
        node:removeFromParent(true)
    end
    self.m_stageView.m_attributeLables=nil
end

function BattleView.addHpView(self,hpView,hpViewLayer,_isleft)
    local container = self.m_stageView:getUIContainer()
    if container==nil then
        return
    end

    local viewCount = 0
    if _isleft then
        self.m_leftHpViewCount=self.m_leftHpViewCount or 0
        viewCount=self.m_leftHpViewCount
    else
        self.m_rightHpViewCount=self.m_rightHpViewCount or 0
        viewCount=self.m_rightHpViewCount
    end
    container:addChild(hpViewLayer,16888)
    hpView :resetTempmateView(viewCount,_isleft)
    if _isleft then
        self.m_leftHpViewCount=self.m_leftHpViewCount+1
    else
        self.m_rightHpViewCount=self.m_rightHpViewCount+1
    end
end

function BattleView.removeHpView(self,uid)
    local container = self.m_stageView:getUIContainer()
    if container==nil then
        return
    end
    local bigHpView =container:getChildByTag(uid)
    if bigHpView~=nil then
        bigHpView:removeFromParent(true)
    end
end

-----   门派守卫
function BattleView.clanDefenseTitle( self, _container )
    -- 标题
    -- local swtitleStr = cc.Sprite:createWithSpriteFrameName("clan_sw_title.png")
    -- swtitleStr:setPosition( cc.p(P_WINSIZE.width/2,P_WINSIZE.height-70) )
    -- _container:addChild( swtitleStr )
    local which_ShenShou = self : checkCeng()
    if which_ShenShou == nil then
        print( "匹配出错!" )
        return
    end
    local fontSize = 21
    -- 4BOSS 血量
    -- local qinglongSpr = CCSprite:createWithSpriteFrameName( "clan_sw_qinglong_hp.png" )
    -- local baihuSpr    = CCSprite:createWithSpriteFrameName( "clan_sw_baihu_hp.png" )
    -- local zhuqueSpr   = CCSprite:createWithSpriteFrameName( "clan_sw_zhuque_hp.png" )
    -- local xuanwuSpr   = CCSprite:createWithSpriteFrameName( "clan_sw_xuanwu_hp.png" )

    local dpsSize = cc.size(280,135)
    local pos     = cc.p( P_WINSIZE.width+10, P_WINSIZE.height-75 )
    local bgCon   = self:__createNoticBg(_container,dpsSize,false,pos,-12)
    bgCon : setAnchorPoint( 1, 1 ) 

    -- local myRightBase = ccui.Scale9Sprite : createWithSpriteFrameName( "general_box_hint.png" )
    -- myRightBase       : setPreferredSize( cc.size( 340, 115 ) )
    -- myRightBase       : setAnchorPoint( 1, 1 )
    -- myRightBase       : setPosition( P_WINSIZE.width, P_WINSIZE.height-75 )
    -- _container        : addChild( myRightBase, -13)

    local myText = { _G.Const.CONST_DEFENSE_TYPE_1,
                     _G.Const.CONST_DEFENSE_TYPE_2,
                     _G.Const.CONST_DEFENSE_TYPE_3,
                     _G.Const.CONST_DEFENSE_TYPE_4} 

    local Btn_myIconText = { [_G.Const.CONST_DEFENSE_TYPE_1] = "clan_td_icon_1.png",
                             [_G.Const.CONST_DEFENSE_TYPE_2] = "clan_td_icon_2.png",
                             [_G.Const.CONST_DEFENSE_TYPE_3] = "clan_td_icon_3.png",
                             [_G.Const.CONST_DEFENSE_TYPE_4] = "clan_td_icon_4.png"} 

    local myPro = _G.GPropertyProxy : getMainPlay() : getClanPost()
    local function buttonCallBack( obj, eventType )
        tag = obj : getTag()
        print( "which_ShenShou = ", which_ShenShou, tag )
        if eventType == ccui.TouchEventType.ended then
            if which_ShenShou == tag then
                local command = CErrorBoxCommand(34710)
                controller :sendCommand( command )
                return
            end

            -- _G.StageXMLManager : setServerId( tag )
            local msg =  REQ_DEFENSE_REQUEST()
            if tag == myText[1] then
                msg : setArgs( myText[1] )
            elseif tag == myText[2] then
                msg : setArgs( myText[2] )
           -- elseif tag == myText[3] then
            --    msg : setArgs( myText[3] )
           -- elseif tag == myText[4] then
            --    msg : setArgs( myText[4] )
            end
            _G.Network:send( msg )
        end
    end

    local nX=40
    local nWid=126
    self.Btn_myIcon = {}
    for i=1,2 do
        self.Btn_myIcon[ myText[i] ] = gc.CButton : create()
        self.Btn_myIcon[ myText[i] ] : loadTextures( Btn_myIconText[myText[i]] )
        self.Btn_myIcon[ myText[i] ] : setButtonScale( 0.6 )
        self.Btn_myIcon[ myText[i] ] : setAnchorPoint( 0.5, 1 )
        self.Btn_myIcon[ myText[i] ] : setPosition( i*nWid-nX, dpsSize.height-10 )
        self.Btn_myIcon[ myText[i] ] : setTag( myText[i] )
        self.Btn_myIcon[ myText[i] ] : addTouchEventListener( buttonCallBack )
        bgCon : addChild( self.Btn_myIcon[ myText[i] ] )
    end

    -- 青龙雕像剩余血量

    self.Lab_qinglong   = _G.Util:createLabel( "",20 )
    self.Lab_baihu      = _G.Util:createLabel( "",20 )
    --self.Lab_zhuque     = _G.Util:createLabel( "",20 )
   -- self.Lab_xuanwu     = _G.Util:createLabel( "",20 )

    self.Lab_qinglong   : setAnchorPoint( 0.5, 1 )
    self.Lab_baihu      : setAnchorPoint( 0.5, 1 )
    --self.Lab_zhuque     : setAnchorPoint( 0.5, 1 )
   -- self.Lab_xuanwu     : setAnchorPoint( 0.5, 1 )

    self.Lab_qinglong   : setPosition( 1*nWid-nX, dpsSize.height-75 )
    self.Lab_baihu      : setPosition( 2*nWid-nX, dpsSize.height-75 )
    --self.Lab_zhuque     : setPosition( 3*nWid-nX, dpsSize.height-75 )
   -- self.Lab_xuanwu     : setPosition( 4*nWid-nX, dpsSize.height-75 )

    self.Lab_qinglong   : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )
    self.Lab_baihu      : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )
    --self.Lab_zhuque     : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )
   -- self.Lab_xuanwu     : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )

    bgCon  : addChild( self.Lab_qinglong,3   )
    bgCon  : addChild( self.Lab_baihu,3      )
   -- bgCon  : addChild( self.Lab_zhuque,3     )
   -- bgCon  : addChild( self.Lab_xuanwu,3     )

    self.qinglonglabel = _G.Util:createLabel( "",fontSize )
    self.baihulabel    = _G.Util:createLabel( "",fontSize )
   -- self.zhuquelabel   = _G.Util:createLabel( "",fontSize )
   -- self.xuanwulabel   = _G.Util:createLabel( "",fontSize )

    self.qinglonglabel : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )
    self.baihulabel    : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )
   -- self.zhuquelabel   : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )
   -- self.xuanwulabel   : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_ORANGE) )

    self.qinglonglabel :setAnchorPoint( cc.p( 0.5, 1 ) )
    self.baihulabel    :setAnchorPoint( cc.p( 0.5, 1 ) )
   -- self.zhuquelabel   :setAnchorPoint( cc.p( 0.5, 1 ) )
   -- self.xuanwulabel   :setAnchorPoint( cc.p( 0.5, 1 ) )
 
    local gap = 100
    self.qinglonglabel :setPosition( 1*nWid-nX, dpsSize.height-75-26 )
    self.baihulabel    :setPosition( 2*nWid-nX, dpsSize.height-75-26 )
   -- self.zhuquelabel   :setPosition( 3*nWid-nX, dpsSize.height-75-26 )
   -- self.xuanwulabel   :setPosition( 4*nWid-nX, dpsSize.height-75-26 )

    bgCon:addChild( self.qinglonglabel,3 )
    bgCon:addChild( self.baihulabel,3 )
   -- bgCon:addChild( self.zhuquelabel,3 )
   -- bgCon:addChild( self.xuanwulabel,3 )

    -- 所有boss 总血量
    -- local allHpSpr = CCSprite:createWithSpriteFrameName( "clan_sw_all_hp.png" )
    local mySize = cc.size(230, 140)
    local pos    = cc.p( 5, P_WINSIZE.height/2+70 )
    local Spr_myBase = self:__createNoticBg(_container,mySize,true)
    self.mySpr       = Spr_myBase

    local ArialSize = 20
    -- 当前是哪只圣兽
    print( "which_ShenShou = ", which_ShenShou )
    local myText = { [_G.Const.CONST_DEFENSE_TYPE_1] = "青龙坛",
                     [_G.Const.CONST_DEFENSE_TYPE_2] = "白虎坛",
                     [_G.Const.CONST_DEFENSE_TYPE_3] = "朱雀坛",
                     [_G.Const.CONST_DEFENSE_TYPE_4] = "玄武坛"}
    -- local allHpSpr = _G.Util:createLabel(_G.Lang.LAB_N[715].."：",ArialSize)
    local tempX=22
    local myHeight  = mySize.height - 10 
    local allHpSpr  = _G.Util:createLabel( "当前所在：" ,ArialSize)
    allHpSpr : setAnchorPoint( 0, 1 )
    allHpSpr : setPosition( tempX, myHeight )
    allHpSpr : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_WHITE) )

    local myShenShow = _G.Util:createLabel( myText[which_ShenShou] ,ArialSize)
    myShenShow : setAnchorPoint( 0, 1 )
    myShenShow : setPosition( tempX+allHpSpr:getContentSize().width, myHeight )
    myShenShow : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_GOLD) )
    myHeight = myHeight - 30

    local Lab_Ceng  = _G.Util:createLabel( "第    层，第        波" ,ArialSize)
    Lab_Ceng : setAnchorPoint( 0, 1 )
    Lab_Ceng : setPosition( tempX, myHeight )
    Lab_Ceng : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_WHITE) )

    self.Lab_Ceng = _G.Util:createLabel( "" ,ArialSize)
    self.Lab_Ceng : setAnchorPoint( 0, 1 )
    self.Lab_Ceng : setPosition( tempX+20, myHeight )
    self.Lab_Ceng : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_GOLD) )

    self.Lab_Bo = _G.Util:createLabel( "" ,ArialSize)
    self.Lab_Bo : setAnchorPoint( 0.5, 1 )
    self.Lab_Bo : setPosition( tempX+120, myHeight )
    self.Lab_Bo : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_GOLD) )
    myHeight = myHeight - 30

    local Lab_myHp  =  _G.Util:createLabel( "血量：" ,ArialSize)
    Lab_myHp : setAnchorPoint( 0, 1 )
    Lab_myHp : setPosition( tempX, myHeight )
    Lab_myHp : setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_WHITE) )

    self.allHpLabel = _G.Util:createLabel( "",ArialSize )
    self.allHpLabel :setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_GOLD) )
    self.allHpLabel :setAnchorPoint( 0,1 )
    self.allHpLabel :setTag( 115 )
    self.allHpLabel :setPosition( tempX+5+Lab_myHp:getContentSize().width, myHeight )
    myHeight = myHeight - 30

    Spr_myBase:addChild( allHpSpr )
    Spr_myBase:addChild( myShenShow )
    Spr_myBase:addChild( Lab_Ceng )
    Spr_myBase:addChild( self.Lab_Ceng )
    Spr_myBase:addChild( self.Lab_Bo   )
    Spr_myBase:addChild( Lab_myHp )
    Spr_myBase:addChild( self.allHpLabel )

    -- 击杀奖励
    local killSpr = _G.Util:createLabel(_G.Lang.LAB_N[717].."：",ArialSize)
    killSpr :setPosition( tempX, myHeight )
    killSpr :setAnchorPoint( 0,1 )
    killSpr :setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_WHITE) )
    local killSprSize = killSpr:getContentSize()

    self.killLabel = _G.Util:createLabel( "",fontSize )
    self.killLabel :setColor( _G.ColorUtil :getRGBA(_G.Const.CONST_COLOR_GOLD) )
    self.killLabel :setAnchorPoint( cc.p( 0,1 ) )
    self.killLabel :setPosition( tempX+5+killSprSize.width, myHeight )
    myHeight  = myHeight - 30

    Spr_myBase:addChild( killSpr )
    Spr_myBase:addChild( self.killLabel )

end

function BattleView.checkCeng( self )
    local text = { _G.Const.CONST_DEFENSE_TYPE_1,
                    _G.Const.CONST_DEFENSE_TYPE_2,
                    _G.Const.CONST_DEFENSE_TYPE_3,
                    _G.Const.CONST_DEFENSE_TYPE_4 }
    local ScenesId = _G.g_Stage:getScenesID()
    local name = get_scene_data(ScenesId).scene_name
    print( "得到的ScenesId ", ScenesId, name )

    local check = { "青龙", "白虎"} --, "朱雀", "玄武" }
    for i=1,2 do
        local isOk = name : find( check[i] )
        if isOk ~= nil then
            print( "匹配到了：", check[i] )
            return text[i]
        end
    end

    return nil
end

--setClanDefenseHp
--setClanDefensekill

function BattleView.setClanDefenseHp( self, _container, _Date )

    if self.inToOver then return end
    local Date = _Date.data
    local function changeCeng( _cen1 )
        local cen = clone(_cen1)
        if _cen1 == 0 then
            cen = 1
        end
        return cen
    end
    local cen1  = changeCeng( Date.cen1 )
    local cen2  = changeCeng( Date.cen2 )
    local cen3  = changeCeng( Date.cen3 )
    local cen4  = changeCeng( Date.cen4 )
    self.Lab_qinglong   : setString( string.format( "%s%s", _G.Lang.number_Chinese[cen1], "层" ) )
    self.Lab_baihu      : setString( string.format( "%s%s", _G.Lang.number_Chinese[cen2], "层" ) )
   -- self.Lab_zhuque     : setString( string.format( "%s%s", _G.Lang.number_Chinese[cen3], "层" ) )
   -- self.Lab_xuanwu     : setString( string.format( "%s%s", _G.Lang.number_Chinese[cen4], "层" ) )

    local qinglongHP =  math.ceil(Date.hp1 / Date.all_hp1 * 100)
    local baihuHp    =  math.ceil(Date.hp2 / Date.all_hp2 * 100)
   -- local zhuqueHP   =  math.ceil(Date.hp3 / Date.all_hp3 * 100)
   -- local xuanwuHP   =  math.ceil(Date.hp4 / Date.all_hp4 * 100)

    self.qinglonglabel :setString( qinglongHP.."%"  )    
    self.baihulabel    :setString( baihuHp.."%"     ) 
    --self.zhuquelabel   :setString( zhuqueHP.."%"    )  
   -- self.xuanwulabel   :setString( xuanwuHP.."%"    ) 

    self.hp1 = Date.hp1
    self.hp2 = Date.hp2
    self.hp3 = Date.hp3
    self.hp4 = Date.hp4

    self.cen1 = Date.cen1
    self.cen2 = Date.cen2
    self.cen3 = Date.cen3
    self.cen4 = Date.cen4

    self.all_hp1 = Date.all_hp1
    self.all_hp2 = Date.all_hp2
    self.all_hp3 = Date.all_hp3
    self.all_hp4 = Date.all_hp4

    local function changeColor( hp, targe1, targe2 )
        if hp <= 10 then
            targe1 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_RED ) )
            targe2 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_RED ) )
        elseif hp <= 50 then
            targe1 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORANGE ) )
            targe2 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORANGE ) )
        end
    end

    changeColor( qinglongHP, self.Lab_qinglong, self.qinglonglabel  )
    changeColor( baihuHp   , self.Lab_baihu   , self.baihulabel     )
    --changeColor( zhuqueHP  , self.Lab_zhuque  , self.zhuquelabel    )
    --changeColor( xuanwuHP  , self.Lab_xuanwu  , self.xuanwulabel    )

    local myText = { [_G.Const.CONST_DEFENSE_TYPE_1] = Date.hp1,
                     [_G.Const.CONST_DEFENSE_TYPE_2] = Date.hp2,
                     [_G.Const.CONST_DEFENSE_TYPE_3] = Date.hp3,
                     [_G.Const.CONST_DEFENSE_TYPE_4] = Date.hp4}
    local witchS = { [_G.Const.CONST_DEFENSE_TYPE_1] = Date.all_hp1,
                     [_G.Const.CONST_DEFENSE_TYPE_2] = Date.all_hp2,
                     [_G.Const.CONST_DEFENSE_TYPE_3] = Date.all_hp3,
                     [_G.Const.CONST_DEFENSE_TYPE_4] = Date.all_hp4}
    local which_ShenShou = self : checkCeng()
    if which_ShenShou == nil then
        print( "匹配出错2" )
        return
    end
    local Allhp     = myText[ which_ShenShou ]
    local AllmyHp   = witchS[ which_ShenShou ]
    print( "改变了ServerID = ", which_ShenShou )
    local odds      = math.ceil( Allhp/AllmyHp * 100 )
    self.allHpLabel    :setString( Allhp.."("..odds.."%)" )
    if odds <= 10 then
        self.allHpLabel : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_RED ) )
    else
        self.allHpLabel : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD ) )
    end
end

function BattleView.setGameOver( self, _container, _ackMsg )
    local data      = _ackMsg.data
    local color4    = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)
    local myZBView  = require( "mod.general.BattleMsgView"  )()
    local ZB_D2Base = myZBView : create()
    local myHeight  = myZBView : getSize().height

    local function beforeClose(  )
        _G.g_Stage:exitCopy()
    end

    myZBView : addCloseFun( beforeClose )

    local myNode = cc.Node : create()
    ZB_D2Base : addChild( myNode )

    -- local myJian = ccui.Scale9Sprite : createWithSpriteFrameName( "general_fram_jianbian.png" )
    -- myJian       : setPreferredSize( cc.size( 540, 200 ) )
    -- myJian       : setAnchorPoint( 0, 1 )
    -- myJian       : setPosition( 0, myHeight-38 )
    -- myNode       : addChild( myJian )

    local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    line1       : setPreferredSize( cc.size( 580, 2 ) )
    line1       : setAnchorPoint( 0, 1 )
    line1       : setPosition( 20, myHeight-34 )
    myNode      : addChild( line1 )

    local lineMid = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    lineMid       : setPreferredSize( cc.size( 580, 1.5 ) )
    lineMid       : setAnchorPoint( 0, 1 )
    lineMid       : setPosition( 20, myHeight-190 )
    myNode        : addChild( lineMid )

    local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    line2       : setPreferredSize( cc.size( 580, 2 ) )
    line2       : setAnchorPoint( 0, 1 )
    line2       : setPosition( 20, myHeight-228 )
    myNode      : addChild( line2 )

    local Text1 = { "雕像", "通关层数", "剩余血量", "进度" }
    local PosX  = { 90, 230, 390, 530 }
    for i=1,#Text1 do
      local lab = _G.Util : createLabel( Text1[i],20 )
      -- lab : setColor( color4 )
      lab : setAnchorPoint( 0.5, 1 )
      lab : setPosition( PosX[i], myHeight-6 )
      myNode : addChild( lab )
    end
    local function checkState( taget )
      if taget == 1 then
        return true
      end
      return false
    end

    local function getOver( )
      if checkState(data.state1) and checkState(data.state2)  then--and checkState(data.state3) and checkState(data.state4) then
        return 1
      end
      return 0
    end

    print( "结算 =====>> ", data.cen1, data.cen2, data.cen3, data.cen4, self.myKillnum )
    local text1 = { "青龙", "白虎","总计", }--"朱雀""玄武", "总计" }
    local text2 = { string.format("%s%s", _G.Lang.number_Chinese[data.cen1 or 0 ], "层"),
                    string.format("%s%s", _G.Lang.number_Chinese[data.cen2 or 0 ], "层"),
                    --string.format("%s%s", _G.Lang.number_Chinese[data.cen3 or 0 ], "层"),
                   -- string.format("%s%s", _G.Lang.number_Chinese[data.cen4 or 0 ], "层"),
                    string.format("%s%s", _G.Lang.number_Chinese[(data.cen1 or 0) + (data.cen2 or 0) + (data.cen3 or 0) + (data.cen4 or 0)], "层") }
    local hp1   = data.hp1 or 0
    local hp2   = data.hp2 or 0
    local hp3   = data.hp3 or 0
    local hp4   = data.hp4 or 0
    local allLevHp = hp1 + hp2 --+ hp3 + hp4
    local allHp    = data.all_hp1 + data.all_hp2 -- + data.all_hp3 + data.all_hp4
    local floor1 =  { math.floor( hp1/data.all_hp1*100), 
                       math.floor( hp2/data.all_hp2*100), 
                      -- math.floor( hp3/data.all_hp3*100),
                      -- math.floor( hp4/data.all_hp4*100),
                      math.floor( allLevHp/allHp*100)}
    local text3 = { string.format( "%d%s%d%s", hp1, "(", floor1[1], "%)" ),
                    string.format( "%d%s%d%s", hp2, "(", floor1[2], "%)" ),
                    --string.format( "%d%s%d%s", hp3, "(", floor1[3], "%)" ),
                   -- string.format( "%d%s%d%s", hp4, "(", floor1[4], "%)" ),
                    string.format( "%d%s%d%s", allLevHp, "(", floor1[3], "%)" )}
    local myText = { [0] = "进行中", "已结束" }
    print( "data.state1=====>>>>>", data.state1, data.state2, data.state3, data.state4, getOver() )
    local text4  = { myText[data.state1], 
                     myText[data.state2], 
                    -- myText[data.state3], 
                     --myText[data.state4], 
                     myText[getOver()] }
    local alltext = { text1, text2, text3, text4 }
    self.myLab = {}
    for i=1,3 do
        self.myLab[i] = {}
        local myLab = {}
        for k=1,#alltext do
          myLab[k] = _G.Util : createLabel( alltext[k][i], 20 )
          myLab[k] : setPosition( PosX[k], myHeight-64-(i-1)*66 )
          myLab[k] : setAnchorPoint( 0.5, 1 )
          myNode   : addChild( myLab[k] )
          self.myLab[i][k] = myLab[k]
          if k == 4 then
            myLab[k] : setColor( color4 )
            if alltext[k][i] == "已结束" then
              myLab[k] : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
            end
          end
          if i == 3 then
            myLab[k] : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD) )
          end
        end
        if floor1[i] <= 10 then
          myLab[3] : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
        elseif floor1[i] <= 50 then
         -- myLab[3] : setColor( color4 )
        end
    end

    local width   = 200 
    local endlab1 = _G.Util : createLabel( "你本次击杀了       个敌人", 20 )
    endlab1       : setAnchorPoint( 0, 0 )
    endlab1       : setPosition( width, 15 )
    myNode        : addChild( endlab1 )

    self.killlab = _G.Util : createLabel( self.myKillnum or "100", 20 )
    self.killlab : setAnchorPoint( 0.5, 0 )
    self.killlab : setPosition( 337, 15 )
    self.killlab : setColor( color4 )
    myNode       : addChild( self.killlab,5 )

    self.OverCreate = true
end

function BattleView.setClanDefensekill( self, _container, Date )

    self.myKillnum   = Date.kill_num
    self.killLabel   : setString( Date.kill_num )
    if self.killlab then 
        self.killlab     : setString( Date.kill_num ) 
    end
end

-- function BattleView.setClanDefenseReword( self, _container, Date )
--     self.rewardLabel :setString( _G.Lang.Currency_Type[1]..":"..Date.gold ) 
--     self.bgLabel     :setString( _G.Lang.LAB_N[719]..":"..Date.devote ) 
-- end

function BattleView.setClanCenci( self, _container, Date )
    self.Lab_Ceng : setString( _G.Lang.number_Chinese[Date.cen] )
    self.Lab_Bo   : setString( string.format( "%d%s%d", Date.boci, "/", Date.all ) )
end

function BattleView.setClanDefensePower( self, _container, Date )
    local strPowerful = P_TOSTRING( Date )
    if self.gx_timesLabel == nil then
        self.gx_timesLabel = {}
    end
    print( "这里是干嘛的？" )
    -- for i=1, P_STRING_LEN( strPowerful ) do
    --     local currNum = P_STRING_SUB( P_TOSTRING(strPowerful), i, i )
    --     print("当前数字 图片", i,currNum)
    --     if self.gx_timesLabel[i] ~= nil then
    --         self.gx_timesLabel[i]:removeFromParent(true)
    --         self.gx_timesLabel[i] = nil
    --     end
    --     local timesLabel = cc.Sprite :createWithSpriteFrameName( "clan_sw_0" .. ( currNum or "1" ) .. ".png" )
    --     if P_STRING_LEN( strPowerful ) > 1 then
    --         timesLabel :setPosition( cc.p( 88+15*i, 23 ) )
    --     else
    --         timesLabel :setPosition( cc.p( 112,23 ) )
    --     end 
    --     self.gx_timesLabel[i] = timesLabel
    --     self.gx_timesSpr :addChild( self.gx_timesLabel[i] )
    -- end
end

function BattleView.setClanDefenseLog( self,_container, _boci, _time )
    local myNode = nil
    if _time ~= 0 and _time ~= 10 then
        return
    end
    local text1 = string.format( "%s%d%s", "第", _boci, "波怪物已经到达战场" )
    local text2 = string.format( "%s%d%s", "第", _boci, "波怪物将在10秒后到达战场" )
    local text = { [0] = text1, [10] = text2 }

    myNode = cc.Node : create()
    local m_winSize  = cc.Director : getInstance() : getVisibleSize()
    myNode : setPosition( m_winSize.width/2, m_winSize.height - 140 )
    _container : addChild( myNode, 5 )

    local function creatLab()
        local lab = _G.Util : createLabel( text[_time], 20 )
        myNode : addChild( lab )
    end

    local function destroNode( )
        if myNode ~= nil then
            myNode : removeFromParent()
            myNode = nil
        end
    end

    local action1  = cc.CallFunc  : create( creatLab )
    local StopTime = cc.DelayTime : create( 4 )
    local action2  = cc.CallFunc  : create( destroNode )
    myNode : runAction( cc.Sequence:create(  action1, StopTime, action2 ) )
   
end

function BattleView.setNextDefenseLog( self, _container )
    local myNode = nil
    myNode = cc.Node : create()
    local m_winSize  = cc.Director : getInstance() : getVisibleSize()
    myNode : setPosition( m_winSize.width/2, m_winSize.height - 140 )
    _container : addChild( myNode, 5 )

    local text1 = "30秒后刷新下一层怪物" 

    local function creatLab()        
        local lab = _G.Util : createLabel( text1, 20 )
        myNode : addChild( lab )
    end

    local function destroNode( )
        if myNode ~= nil then
            myNode : removeFromParent()
            myNode = nil
        end
    end

    local action1  = cc.CallFunc  : create( creatLab )
    local StopTime = cc.DelayTime : create( 4 )
    local action2  = cc.CallFunc  : create( destroNode )
    myNode : runAction( cc.Sequence:create(  action1, StopTime, action2 ) )
end

function BattleView.setNextDoorLog( self, _container )
     local myNode = nil
    myNode = cc.Node : create()
    local m_winSize  = cc.Director : getInstance() : getVisibleSize()
    myNode : setPosition( m_winSize.width/2, m_winSize.height - 140 )
    _container : addChild( myNode, 5 )

    local text1 = "30秒后刷新下一层怪物"
    local text2 = "请选择正确的传送门进入下一层"    
    local text3 = "(选择错误将被传送回第一层)"

    local function creatLab()        
        local lab = _G.Util : createLabel( text1, 20 )
        myNode : addChild( lab )

        local lab = _G.Util : createLabel( text2, 20 )
        lab : setPosition( 0, -25 )
        myNode : addChild( lab )

        local lab = _G.Util : createLabel( text3, 20 )
        lab : setPosition( 0, -50 )
        myNode : addChild( lab )
    end

    local function destroNode( )
        if myNode ~= nil then
            myNode : removeFromParent()
            myNode = nil
        end
    end

    local action1  = cc.CallFunc  : create( creatLab )
    local StopTime = cc.DelayTime : create( 4 )
    local action2  = cc.CallFunc  : create( destroNode )
    myNode : runAction( cc.Sequence:create(  action1, StopTime, action2 ) )
end

-- {门派战}
function BattleView.setClanFight_clanInfo( self )
    local _container = self.m_stageView:getUIContainer()
    if _container == nil then return end

    local dpsSize = cc.size(270,180)
    local bgCon   = self:__createNoticBg(_container,dpsSize,true)

    -- 击杀人数， 剩余复活次数
    local gap = 30
    local fontSize=20
    local oColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)
    local rColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
    local gColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN) 
    local kill_title = _G.Util:createLabel(_G.Lang.LAB_N[720]..": ",fontSize)
    local kill_num = _G.Util:createLabel("",fontSize)
    kill_title :setColor(oColor)
    kill_num   :setColor(oColor)

    kill_title :setAnchorPoint(cc.p(0,1))
    kill_num   :setAnchorPoint(cc.p(0,1))

    bgCon :addChild(kill_title)
    bgCon :addChild(kill_num)

    local posy = dpsSize.height-10
    local posx = 22
    local kill_titleSize=kill_title:getContentSize()
    kill_title :setPosition( cc.p(posx,posy) )
    kill_num   :setPosition( cc.p(posx+kill_titleSize.width+5,posy) )

    posy = posy - gap
    local resurgence_num = _G.Util:createLabel(_G.Lang.LAB_N[721]..": ",fontSize)
    resurgence_num :setColor(gColor)
    resurgence_num :setAnchorPoint(cc.p(0,1))
    resurgence_num :setPosition(cc.p(posx,posy))
    bgCon :addChild(resurgence_num)

    -- 门派名称，剩余人数
    fontSize=20
    local t_clanName = _G.Util:createLabel(_G.Lang.LAB_N[215],fontSize)
    local t_clanNum  = _G.Util:createLabel(_G.Lang.LAB_N[722],fontSize)
    t_clanName :setColor(oColor)
    t_clanNum  :setColor(oColor)
    t_clanName :setAnchorPoint( 0.5, 1 )
    t_clanNum  :setAnchorPoint( 0.5, 1 )
    bgCon :addChild(t_clanName)
    bgCon :addChild(t_clanNum)

    local lX=posx+40
    local rX=185
    posy = posy - gap
    t_clanName :setPosition(cc.p(lX,posy))
    t_clanNum  :setPosition(cc.p(rX,posy))

    local clanInfoList={}
    for i=1,3 do
        local clanName = _G.Util:createLabel("",fontSize)
        local clanNum  = _G.Util:createLabel("",fontSize)
        bgCon :addChild(clanName)
        bgCon :addChild(clanNum)

        clanName : setAnchorPoint( 0, 1 )
        clanNum  : setAnchorPoint( 0.5, 1 )

        posy = posy - gap + 5
        clanName :setPosition(cc.p(lX-35,posy))
        clanNum  :setPosition(cc.p(rX,posy))

        clanInfoList[i] = {}
        clanInfoList[i].clanName = clanName
        clanInfoList[i].clanNum  = clanNum
    end

    self.clanFight_killNum=kill_num
    self.clanFight_resurgenceNum=resurgence_num
    self.clanFight_clanInfoList=clanInfoList

    return true
end
function BattleView.updateClanFight_clanInfo( self,_data )
    if self.clanFight_killNum==nil
        or self.clanFight_resurgenceNum==nil
        or self.clanFight_clanInfoList==nil then

        if self:setClanFight_clanInfo()~=true then
            return
        end
    end

    local clanList=_data or {}
    for i=1,3 do
        local infoList=self.clanFight_clanInfoList[i]
        local clanData=clanList[i]
        if clanData~=nil and infoList~=nil then
            local clanName=clanData.clan_name or "?"
            local surplus=clanData.surplus or "?"
            local maxNum=clanData.max or "?"

            infoList.clanName :setString(clanName)
            infoList.clanNum  :setString(surplus.."/"..maxNum)

        end
    end
end
function BattleView.showDead( self, _container )
    local tempNode=cc.Node:create()
    _container:addChild(tempNode)
    tempNode:setPosition(cc.p(P_WINSIZE.width/2,P_WINSIZE.height/2))

    local spr = cc.Sprite:createWithSpriteFrameName("battle_dead.png")
    tempNode:addChild(spr)
    spr:setScale(6)
    spr:runAction(cc.Speed:create( cc.Sequence:create(cc.ScaleTo:create(0.2,1),
                                          cc.MoveBy:create(0.05,cc.p(-6,0)),                                          
                                          cc.MoveBy:create(0.05,cc.p(12,0)),
                                          cc.MoveBy:create(0.05,cc.p(-12,0)),
                                          cc.MoveBy:create(0.05,cc.p(6,0)),
                                          cc.DelayTime:create(1.5),
                                          cc.Spawn:create(cc.FadeOut:create(1.06),
                                            cc.ScaleTo:create(1.06,1.5))),15))

    -- local tempEff=_G.SpineManager.createSpine("spine/shibai",1)
    -- tempEff:setAnimation(0,"idle",false)
    -- tempNode:addChild(tempEff)

end
function BattleView.showWin( self, _container )
    local tempNode=cc.Node:create()
    _container:addChild(tempNode)
    tempNode:setPosition(cc.p(P_WINSIZE.width/2,P_WINSIZE.height/2))

    local spr1 = cc.Sprite:createWithSpriteFrameName("battle_win_1.png")
    local spr2 = cc.Sprite:createWithSpriteFrameName("battle_win_2.png")

    -- local fadeTo=cc.FadeTo:create(0.4,50)
    spr1 : setPosition( -1, 0 )
    -- spr2 : setPosition( 0.5, 20.5 )
    -- spr2 : setTag(88)

    tempNode : addChild( spr2 )
    tempNode : addChild( spr1 )

    local function nRemove(_node)
        -- if _node:getTag()==88 then
        --     self:showWin()
        -- end
        _node:removeFromParent(true)
    end

    local function nFun3()
        spr1:runAction(cc.Speed:create(cc.Sequence:create(
                                            cc.MoveTo:create(0.03, cc.p( 10, -4 )),
                                            cc.DelayTime:create(0.23),
                                            cc.Spawn:create(
                                            cc.MoveTo:create(1.06, cc.p( 40, -21 )),
                                            cc.ScaleTo:create(1.06,1.5),
                                            cc.FadeTo:create(1.1,0)),
                                          cc.CallFunc:create(nRemove)),1))
        spr2:runAction(cc.Speed:create(cc.Sequence:create(
                                            cc.MoveTo:create(0.03, cc.p( -10, 4 )),
                                            cc.DelayTime:create(0.23),
                                            cc.Spawn:create(
                                            cc.MoveTo:create(1.06, cc.p( -40, 21 )),
                                            cc.ScaleTo:create(1.06,1.5),
                                            cc.FadeTo:create(1.1,0)),
                                          cc.CallFunc:create(nRemove)),1))
    end

    -- local function nFun2()
    --     spr1:runAction(cc.Speed:create(cc.Sequence:create(cc.DelayTime:create(0.5),
    --                                       cc.MoveTo:create(0.1,cc.p(-20,15)),
    --                                       cc.DelayTime:create(0.5),
    --                                       cc.CallFunc:create(nFun3)),1))
    -- end

    local function nFun1()
        local szPlist   = "anim/battle_win.plist"
        local szFram    = "battle_win_"
        local act1      = _G.AnimationUtil:createAnimateAction(szPlist,szFram,0.08)

        local effectSpr=cc.Sprite:create()
        effectSpr : setRotation( 70 )
        effectSpr : setScale(1.5)
        local function myCallFunc( )
            effectSpr : removeFromParent( true )
        end
        local function c()
            _G.Util:playAudioEffect("1003")
        end
        effectSpr:runAction(cc.Speed:create(cc.Sequence:create( act1,
                                                cc.CallFunc:create(nFun3),
                                                cc.FadeTo:create(0.2,0),
                                                cc.CallFunc:create(myCallFunc)),2))
        effectSpr:runAction(cc.Sequence:create(cc.CallFunc:create(c),cc.DelayTime:create(0.1),cc.CallFunc:create(nFun3)))
        effectSpr:setPosition(0,-10)
        tempNode:addChild(effectSpr)
    end

    local function c()
        self.m_stageView:vibrate1399()
    end
    tempNode:setScale(6)
    tempNode:runAction(cc.Speed:create( cc.Sequence:create(cc.ScaleTo:create(0.2,1),
                                          cc.CallFunc:create(c),
                                          cc.MoveBy:create(0.05,cc.p(-6,0)),                                          
                                          cc.MoveBy:create(0.05,cc.p(12,0)),
                                          cc.MoveBy:create(0.05,cc.p(-12,0)),
                                          cc.MoveBy:create(0.05,cc.p(6,0)),
                                          cc.DelayTime:create(6),
                                          cc.CallFunc:create(nFun1)),15))   

end
function BattleView.updateClanFight_myInfo( self,_data )
    self.m_clanFight_myData = _data
    if self.clanFight_killNum==nil
        or self.clanFight_resurgenceNum==nil
        or self.clanFight_clanInfoList==nil then

        if self:setClanFight_clanInfo()~=true then
            return
        end
    end
    self.clanFight_killNum:setString(_data.kill or "?")
    self.clanFight_resurgenceNum:setString(_G.Lang.LAB_N[721]..":  "..(_data.rec or "?"))
end

--  门派战死亡面板
function BattleView.setClanFight_dieTips( self, _data )
    -- do return end
    print( "exinexinexinexin1" )
    if self.clanFight_dieTips ~= nil then
        self.clanFight_dieTips : removeFromParent(true)
        self.clanFight_dieTips =nil
    end

    if self.myTipsbox ~= nil then
        self.myTipsbox : remove()
        self.myTipsbox = nil
    end

    local _container = self.m_stageView:getUIContainer()
    if _container == nil then return end

    print( "exinexinexinexin2" )
    local function local_fun( _duration )
        if self.clanFight_dieTimeLb==nil or self.clanFight_dieTimes==nil then return end
        self.clanFight_dieTimes=self.clanFight_dieTimes-_duration
        if self.clanFight_dieTimes<=0 then

            self:removeClanFight_dieTips()
        else

            local timeStr = P_STRING_FORMAT("%d",math.floor(self.clanFight_dieTimes))
            self.clanFight_dieTimeLb:setString(timeStr)
        end
    end

    print( "进入这里" )
    local priority = -_G.Const.CONST_MAP_PRIORITY_LAYER

    local DeathTimes = self.m_clanFight_myData.rec
    print( "剩余死亡次数：", DeathTimes )

    local myTag    = _G.Const.CONST_GANG_WARFARE_TYPE1
    if DeathTimes <= 0 then
        myTag = _G.Const.CONST_GANG_WARFARE_TYPE0
    end
    local function sureFun( )
        print( "xxxxxxx点击确定按钮!!" )
        self:removeClanFight_dieTips( )
    end
    local function cancel(  )
        
    end

    local tipsbox = require("mod.general.TipsBox")()
    local layer   = tipsbox:create("",sureFun,cancel, true, true)
    -- layer : setPosition(-P_WINSIZE.width/2,-P_WINSIZE.height/2)
    _container:addChild(layer,-11)
    tipsbox : setTitleLabel("死 亡")
    tipsbox : hideCancelBtn()
    self.myTipsbox = tipsbox

    local layer=tipsbox:getMainlayer()
    local tipsNode = cc.Layer:create()
    tipsNode : setTag(myTag)
    tipsNode : scheduleUpdateWithPriorityLua(local_fun,1)
    layer :addChild(tipsNode)

    local midPos=cc.p(10,20)

    local oColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)
    local cColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
    local wColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)


    local node = cc.Node : create()
    node       : setPosition( midPos.x,0 )
    tipsNode   : addChild( node )


    local name_C = _data.kill_clan or 0
    local name_P = _data.kill_name or 0
    
    local text_n = { "你被", name_C, "的", name_P, "击杀了" }
    local Mcolor = { wColor, cColor, wColor, oColor, wColor } 

    local lab_1  = ccui.Widget:create()
    node:addChild(lab_1)

    local width  = 0
    for i=1,5 do
        local lab = _G.Util : createLabel( text_n[i], 20 )

        lab       : setAnchorPoint( 0, 0 )
        lab       : setPosition( width, 0 )
        lab       : setColor( Mcolor[i] )
        lab_1     : addChild( lab )
        width     = width + lab:getContentSize().width
    end
    
    if  width +20 > 370 then
    	lab_1:setContentSize(cc.size(width-60,50))
    	lab_1:removeAllChildren()
    	local x = 0
    	for i=1,5 do
	        local lab = _G.Util : createLabel( text_n[i], 20 )

	        lab       : setAnchorPoint( 0, 0 )
	        lab       : setColor( Mcolor[i] )
	        lab_1     : addChild( lab )
	        if i==5 then
	        	lab       : setPosition( 0, 0 )
	        else
	        	lab       : setPosition( x, 25 )
	        	x = x + lab:getContentSize().width
	        end
	    end
	    lab_1:setPosition(0,40)
    else
    	lab_1:setContentSize(cc.size(width,25))
    	lab_1:setPosition(cc.p(0,50))
    end

    local Tag_Out = 777
    local Tag_Ag  = 888

    local button = tipsbox : getSureBtn()
    if DeathTimes <= 0 then
        button  : setTitleText( "认 怂" )
        tipsNode: setTag( Tag_Out )
        local posy = button : getPositionY()
        button  : setPosition( 110, posy )

        local function watchCallBack( obj, TouchEvent )
            if TouchEvent == ccui.TouchEventType.ended then
                tipsNode: setTag( _G.Const.CONST_GANG_WARFARE_TYPE1 )
                self : removeClanFight_dieTips()
            end
        end

        local button2 = gc.CButton : create()
        button2 : setPosition( 15, -113 )
        button2 : setAnchorPoint( 0, 0.5 )
        button2 : loadTextures( "general_btn_gold.png" )
        button2 : setTitleText( "观看战斗" )
        button2 : setTitleFontName( _G.FontName.Heiti )
        button2 : setTitleFontSize( 20+4 )
        -- button2 : setButtonScale( 0.8 )
        button2 : addTouchEventListener( watchCallBack )
        layer   : addChild( button2,5 )

        local lab_2 = _G.Util : createLabel( "君子报仇，十年未晚！", 20 )
        lab_2       : setPosition( 0, 10 )
        node        : addChild( lab_2 )

        local lab_3 = _G.Util : createLabel( "复活次数：0次", 18 )
        lab_3       : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
        lab_3       : setPosition( 0, -30 )
        node        : addChild( lab_3 )
    else
        button  : setTag( Tag_Ag )
        button  : setTitleText( "立即复活" )
        local height = 15
        local Text_g = { "复活剩余时间：    秒", "复活剩余次数：    次", _data.time, DeathTimes }
        for i=1,2 do
            local lab_2 = _G.Util : createLabel( Text_g[i], 20 )
            lab_2       : setPosition( 0, height )
            node        : addChild( lab_2 )

            local lab_3 = _G.Util : createLabel( Text_g[i+2], 20 )
            lab_3       : setAnchorPoint( 1, 0.5 )
            lab_3       : setPosition( 65, height )
            lab_3       : setColor( cColor )
            node        : addChild( lab_3, 2 )
            if i == 1 then
                self.clanFight_dieTimeLb = lab_3
                self.clanFight_dieTimes = _data.time
            end

            height      = height - 30
        end
    end

    -- local buttonSize=button:getContentSize()
    -- local timeStr=""
    -- local delayTimes=_G.Const.CONST_GANG_WARFARE_DIE_REC
    -- if _data.type==_G.Const.CONST_GANG_WARFARE_TYPE0 then
    --     timeStr=delayTimes.._G.Lang.LAB_N[225]
    -- else
    --     timeStr=delayTimes.._G.Lang.LAB_N[725]
    -- end
    -- local timeLabel = _G.Util:createLabel(timeStr,22)
    -- timeLabel:setAnchorPoint(cc.p(0.5,0))
    -- timeLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    -- timeLabel:setPosition(cc.p(0,-45))
    -- node:addChild(timeLabel,10)

    self.clanFight_dieTips=tipsNode
    -- self.clanFight_dieTimeLb=timeLabel
    -- self.clanFight_dieTimes=delayTimes --毫秒数
end
function BattleView.removeClanFight_dieTips( self, _isTrue )
    local _type = nil--_G.Const.CONST_GANG_WARFARE_TYPE0
    if self.clanFight_dieTips~=nil then
        _type = self.clanFight_dieTips:getTag()

        self.clanFight_dieTips:removeFromParent(true)
        self.clanFight_dieTips=nil
    end

    if self.myTipsbox ~= nil then
        self.myTipsbox : remove()
        self.myTipsbox = nil
    end
    self.clanFight_dieTimeLb=nil
    self.clanFight_dieTimes=nil
    self.m_addTimes=nil
    print( "dsjfkdsjf = ", _type , _isTrue, _G.Const.CONST_GANG_WARFARE_TYPE1, debug.traceback() )
    if _type==nil or _isTrue then return end

    CCLOG("cccccccccccccccccccccccccccccc--->%d",_type)
    if _type==_G.Const.CONST_GANG_WARFARE_TYPE1 then
        CCLOG("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
        local msg = REQ_GANG_WARFARE_INITIATIVE_REC()
        _G.Network : send( msg )
    else
        CCLOG("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        local msg = REQ_GANG_WARFARE_EXIT_WAR()
        _G.Network : send(msg)
    end
end

-- 门派战结算
function BattleView.setClanFight_resultView( self, _data )
    self.m_stageView:removeKeyBoardAndJoyStick()

    local _container = self.m_stageView:getUIContainer()

    if _container == nil then return end

    if _container :getChildByTag(10088) ~= nil then
        return
    end
    print( "wowowowowwowowowowowow" )
    print( "数量：", _data.count )

    local function sort( data1, data2 )
      if data1.s_role > data2.s_role then 
        return true 
      elseif data1.s_role == data2.s_role then 
        if data1.sum_kill > data2.sum_kill then 
            return true
        else 
            return false 
        end
      else
        return false
      end
    end
    table.sort( _data.data, sort )
    for i=1,_data.count do
        print( i,"的信息：", _data.data[i].clan)
    end

    -- local function butonCallBack( obj, eventType )
    --     if eventType == ccui.TouchEventType.ended then
    --         print( "发送退出协议" )
    --         local msg = REQ_GANG_WARFARE_EXIT_WAR()
    --         _G.Network : send(msg)
    --     end
    -- end
    local SprSize  = cc.size( 618, 372 )
    local function onTouchBegan(touch,event) 
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(P_WINSIZE.width/2-SprSize.width/2,P_WINSIZE.height/2-SprSize.height/2,
        SprSize.width,SprSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end
        local msg = REQ_GANG_WARFARE_EXIT_WAR()
        _G.Network : send(msg)
        return true
    end

    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    local midPos=cc.p(P_WINSIZE.width/2,P_WINSIZE.height/2)
    local node = cc.LayerColor:create(cc.c4b(0,0,0,150))
    node       : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,node)
    -- node       : setPosition( midPos.x,362 )
    _container : addChild(node,1000,10088)

    local Spr_Base = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
    Spr_Base       : setPreferredSize( SprSize )
    Spr_Base       : setPosition(midPos)
    node           : addChild( Spr_Base )

    local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    frameSpr:setPreferredSize(cc.size(600,320))
    frameSpr:setPosition(SprSize.width/2,SprSize.height/2-16)
    Spr_Base:addChild(frameSpr)

    local threeSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    threeSpr:setPreferredSize(cc.size(596,265))
    threeSpr:setPosition(SprSize.width/2,SprSize.height/2-42)
    Spr_Base:addChild(threeSpr)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(SprSize.width/2-135,SprSize.height-26)
    Spr_Base:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(SprSize.width/2+130,SprSize.height-26)
    titleSpr:setRotation(180)
    Spr_Base:addChild(titleSpr,9)

    -- local Btn_close = gc.CButton : create()
    -- Btn_close       : loadTextures( "general_close.png" )
    -- Btn_close       : setPosition( SprSize.width/2-8, SprSize.height/2-8 )
    -- Btn_close       : addTouchEventListener( butonCallBack )
    -- node            : addChild( Btn_close, 10 )

    local myTest    = { "初赛", "决赛" }
    local myEndl    = { [0] = "失败", "胜利" }
    local Text      = string.format( "%s%s", myTest[_data.type], myEndl[_data.res] )
    local Lab_title = _G.Util : createBorderLabel( Text, 24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    Lab_title       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    Lab_title       : setPosition( SprSize.width/2, SprSize.height-26 )
    Spr_Base        : addChild( Lab_title )

    local width  = SprSize.width
    local height = SprSize.height 
    local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" )
    line1 : setPreferredSize( cc.size( width-30, 60 ) )
    -- line1 : setOpacity( 255*0.5 )
    line1 : setAnchorPoint( 0, 1 )
    line1 : setPosition( 15, 269 )
    Spr_Base : addChild( line1, 3 )

    local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" )
    line2 : setPreferredSize( cc.size( width-30, 60 ) )
    -- line2 : setOpacity( 255*0.4 )
    line2 : setAnchorPoint( 0, 1 )
    line2 : setPosition( 15, 205 )
    Spr_Base : addChild( line2, 3 )

    local line3 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" )
    line3 : setPreferredSize( cc.size( width-30, 60 ) )
    -- line3 : setOpacity( 255*0.4 )
    line3 : setAnchorPoint( 0, 1 )
    line3 : setPosition( 15, 140 )
    Spr_Base : addChild( line3, 3 )

    local line4 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" )
    line4 : setPreferredSize( cc.size( width-30, 60 ) )
    -- line4 : setOpacity( 255*0.5 )
    line4 : setAnchorPoint( 0, 1 )
    line4 : setPosition( 15, 75 )
    Spr_Base : addChild( line4, 3 )

    local Text = { "门派名称", "剩余人数", "总击杀数", "剩余战力" }
    local PosX    = { 100, 235, 370, 510 }
    local posy    = { 239, 175, 110, 300 }
    local color1  = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE )
    local color2  = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD  )
    local color3  = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN   )
    local myColor = { color3, color1, color1, color2 }
    -- local place   = Spr_Base
    for i=1,4 do
        local Text_Which = {}
        if i == 4 then 
            Text_Which = Text
            myColor    = { color1, color1, color1, color1 }
        else
            if _data.data[i] == nil then
                Text_Which = { "暂无", "暂无", "暂无", "暂无" }
            else
                Text_Which = { _data.data[i].clan, _data.data[i].s_role, _data.data[i].sum_kill, _data.data[i].s_power }
            end
        end
        for k=1,4 do
            local myText = _G.Util : createLabel( Text_Which[k], 20 )
            myText  : setPosition( PosX[k], posy[i] )
            myText  : setColor( myColor[k] )
            Spr_Base : addChild( myText, 5 )
        end
    end
    
    local kill    = self.m_clanFight_myData.kill or 0
    local Text    = { "你本次击杀了", kill, "个敌人！" }
    local width   = SprSize.width/2 - 100
    local myColor = { color1, color3, color1 } 
    for i=1,3 do
        local mylab = _G.Util : createLabel( Text[i], 20 )
        mylab       : setColor( myColor[i] )
        mylab       : setAnchorPoint( 0, 0.5 )
        mylab       : setPosition( width, 45 )
        Spr_Base    : addChild( mylab , 5)
        width = width + mylab:getContentSize().width
    end
end

function BattleView.addBossWaring( self, _container )
    _G.Util:playAudioEffect("balance_waring")

    local tempNode=_G.SpineManager.createSpine("spine/boss",1)
    tempNode:setPosition(P_WINSIZE.width*0.5,P_WINSIZE.height*0.5)
    tempNode:setAnimation(0,"idle",false)
    _container : addChild(tempNode,16889)

    local function onFunc1(_node)
        local scenesType = self.m_stageView:getScenesType()
        if not (scenesType == _G.Const.CONST_MAP_TYPE_CITY_BOSS 
            or scenesType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS
            or scenesType == _G.Const.CONST_MAP_TYPE_BOSS
            or scenesType == _G.Const.CONST_MAP_CLAN_WAR
            or scenesType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER) then
            self.m_stageView.isGoingNextCheckPoint=true
        end
        tempNode:removeFromParent(true)
    end
    local function onFunc2(event)
        tempNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(onFunc1)))
    end
    tempNode:registerSpineEventHandler(onFunc2,2)
    do return end

    local winSize  = cc.Director : getInstance() : getVisibleSize()
    local node = cc.Node:create()
    node : setPosition(winSize.width/2,winSize.height-200)

    local cNode = cc.ClippingNode:create()
    node : addChild(cNode)

    local bg = ccui.Scale9Sprite:createWithSpriteFrameName("battle_boss_bg.png")
    local sprSize = cc.size(winSize.width,145)
    bg   : setScaleY(0)
    bg   : setPreferredSize(sprSize)
    -- bg   : setPosition(0,15)

    -- local line = cc.Sprite:createWithSpriteFrameName("battle_boss_line.png")
    -- line  : setPosition(0,winSize.height/2)
    -- bg    : addChild(line)
    -- line = cc.Sprite:createWithSpriteFrameName("battle_boss_line.png")
    -- line  : setScaleX(-1)
    -- line  : setPosition(0,-winSize.height/2)
    -- bg    : addChild(line)

    cNode : setStencil(bg)
    cNode : addChild(bg)




    local title  = cc.Sprite:createWithSpriteFrameName("battle_boss_title.png")
    title  : setPosition(0,-15)
    -- title  : setVisible(false)
    title  : setOpacity(0)
    title  : setScale(5)
    node   : addChild(title)

    local waring = cc.Sprite:createWithSpriteFrameName("battle_boss_waring.png")
    waring : setOpacity(0)
    waring : setScale(5)
    waring : setPosition(0,65)
    node   : addChild(waring)

    -- local moveTo1 = cc.MoveTo:create(1,cc.p(winSize.width/2,winSize.height-200))
    -- local moveTo2 = cc.MoveTo:create(1,cc.p(-winSize.width/2,winSize.height-200))
    -- local easeBounceIn = cc.EaseExponentialOut:create(moveTo1)
    -- local easeBounceOut = cc.EaseExponentialIn:create(moveTo2)
    local dt     = 0.3
    local scale1 = cc.ScaleTo:create(dt,1)
    bg : runAction(scale1)

    local time1  = cc.DelayTime:create(dt)
    local faIn1  = cc.FadeIn:create(0.1)
    title : runAction(cc.Sequence:create(time1,cc.Spawn:create(faIn1:clone(),scale1:clone())))

    waring : runAction(cc.Sequence:create(time1,cc.Spawn:create(faIn1:clone(),scale1:clone())))




    -- local rNode = cc.Node:create()
    -- node  : addChild(rNode)

    local rota = cc.RotateTo:create(12,90)
    local round = cc.Sprite:createWithSpriteFrameName("battle_boss_round.png")
    round : setAnchorPoint(0,0)
    cNode : addChild(round)
    round : runAction( cc.Sequence:create( time1,cc.Spawn:create(faIn1, rota)   ))

    local round1 = cc.Sprite:createWithSpriteFrameName("battle_boss_round.png")
    round1 : setScaleX(-1)
    round1 : setAnchorPoint(0,0)
    cNode : addChild(round1)
    round1 : runAction( cc.Sequence:create( time1,cc.Spawn:create(faIn1, rota:clone())   ))

    local round2 = cc.Sprite:createWithSpriteFrameName("battle_boss_round.png")
    round2 : setScale(-1)
    round2 : setAnchorPoint(0,0)
    round2 : setPosition(0,1)
    cNode : addChild(round2)
    round2 : runAction( cc.Sequence:create( time1,cc.Spawn:create(faIn1, rota:clone())   ))

    local round3 = cc.Sprite:createWithSpriteFrameName("battle_boss_round.png")
    round3 : setScaleY(-1)
    round3 : setAnchorPoint(0,0)
    round3 : setPosition(0,1)
    cNode : addChild(round3)
    round3 : runAction( cc.Sequence:create( time1,cc.Spawn:create(faIn1, rota:clone())   ))


    local s = _G.SpineManager.createSpine("spine/61019",1)
    s    : setVisible(false)
    s    : setPosition(0,-12)
    node : addChild(s)

    local function spineFun( ... )
        s:setVisible(true)
        s:setAnimation(0,"idle2",false)
    end
    local fun2 = cc.CallFunc:create(spineFun)
    local time2 = cc.DelayTime:create(0.6)
    node : runAction(cc.Sequence:create(time2,fun2))

    local time3 = cc.DelayTime:create(0.7)
    local fadeout1 = cc.FadeOut:create(0.2)
    local fadein1 = cc.FadeIn:create(0.2)
    local lbg = cc.Sprite:createWithSpriteFrameName("battle_boss_lbg.png")
    lbg   : setPosition(160,70)
    lbg   : setScale(1.5)
    lbg   : setOpacity(0)
    title : addChild(lbg)

    local function show(  )
        local scenesType = self.m_stageView:getScenesType()
        if not (scenesType == _G.Const.CONST_MAP_TYPE_CITY_BOSS 
                or scenesType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS
                or scenesType == _G.Const.CONST_MAP_TYPE_BOSS
                or scenesType == _G.Const.CONST_MAP_CLAN_WAR
                or scenesType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER) then
            self.m_stageView.isGoingNextCheckPoint=true
        end
    end
    local fun    =cc.CallFunc:create(show)
    local seq = cc.Sequence:create(fadein1,fadeout1)
    lbg   : runAction(cc.Sequence:create(time3,seq:clone(),fun,seq:clone(),seq:clone()))


    local function c()
        round:removeFromParent(true)
        round2:removeFromParent(true)
        round1:removeFromParent(true)
        round3:removeFromParent(true)
        title:removeFromParent(true)
        waring:removeFromParent(true)
    end
    local fun = cc.CallFunc:create(c)
    local time = cc.DelayTime:create(1.8)

    local scaleTo = cc.ScaleTo:create(0.2,0.5)
    title : runAction(cc.Sequence:create(time,scaleTo:clone(),fun))
    waring : runAction(cc.Sequence:create(time,scaleTo:clone()))

    local time4 = cc.DelayTime:create(2)
    local scaleTo = cc.ScaleTo:create(0.3,1,0)
    node:runAction(cc.Sequence:create(time4,scaleTo))
    local function m(  )
        _G.Util:playAudioEffect("balance_waring")

    end
    node:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(m)))

    _container : addChild(node,16889)

end

return BattleView

