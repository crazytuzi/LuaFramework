local UICopyPassMediator

local GOODID_GOLD=_G.Const.CONST_ZHUANHUAN_GOLD
local GOODID_EXP=_G.Const.CONST_ZHUANHUAN_EXP
local DrawActionTimes=0.3
local GUIDE_COPY_ID=10021
local beautyTime={}

local UICopyPass = classGc(view,function(self,ackCopyOverData)
    self.m_sceneType=_G.g_Stage:getScenesType()
    if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS then
        -- 通天浮图(过关斩将)
        self.m_eva=3
    else
        self.m_eva=ackCopyOverData.eva-- {副本评价}
        self.m_times=ackCopyOverData.times-- {可翻牌次数}
        if(self.m_eva>=3) then
            self.m_eva=3
        elseif(self.m_eva<=1) then
            self.m_eva=1
        else
            self.m_eva=2
        end
    end

    self.ackCopyOverData=ackCopyOverData
    self.fontSize=20
    self.m_conditionOk={}
    self.m_conditionOk[1]=true
    self.m_conditionOk[2]=ackCopyOverData.condition==1
    self.m_conditionOk[3]=ackCopyOverData.condition2==1

    self.m_copyId=ackCopyOverData.copy_id
    self.m_sceneCopyCnf=_G.Cfg.scene_copy[self.m_copyId]
    if self.m_sceneCopyCnf==nil then
        CCMessageBox("scene_copy找不到数据",tostring(self.m_copyId))
    else
        if self.m_sceneCopyCnf.over_score~=nil 
            and self.m_sceneCopyCnf.over_score[1]~=nil
            and self.m_sceneCopyCnf.over_score[2]~=nil then
            self.m_conditionNum1=self.m_sceneCopyCnf.over_score[1][2]
            self.m_conditionNum2=self.m_sceneCopyCnf.over_score[2][2]
            self.m_conditionType1=self.m_sceneCopyCnf.over_score[1][1]
            self.m_conditionType2=self.m_sceneCopyCnf.over_score[2][1]
        end
    end
    if self.m_conditionNum1==nil or self.m_conditionNum2==nil then
        self.m_conditionNum1=0
        self.m_conditionNum2=0
        self.m_conditionType1=1
        self.m_conditionType2=1
    end

    self.m_isGoodsDraw=ackCopyOverData.flag==1
    if not self.m_isGoodsDraw then
        self.m_goodDatas={}
        if ackCopyOverData.exp>0 then
            local t={goods_id=GOODID_EXP,count=ackCopyOverData.exp}
            self.m_goodDatas[#self.m_goodDatas+1]=t
        end
        if ackCopyOverData.gold>0 then
            local t={goods_id=GOODID_GOLD,count=ackCopyOverData.gold}
            self.m_goodDatas[#self.m_goodDatas+1]=t
        end

        local goodsArray=ackCopyOverData.data or {}
        local goodsCount=#self.m_goodDatas
        for i=1,#goodsArray do
            goodsCount=goodsCount+1
            self.m_goodDatas[goodsCount]=goodsArray[i]
        end
    end

    self.m_overdata=ackCopyOverData
    cc.SimpleAudioEngine:getInstance():stopMusic(true)
    _G.Util:playAudioEffect("ui_match_win")
end)

--{返回一个层}
function UICopyPass.create( self )
    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_winSize=cc.Director:getInstance():getWinSize()
    self.m_rootLayer=cc.Layer:create()
    self.m_rootLayer:setPosition(-self.m_winSize.width*0.5,-self.m_winSize.height*0.5)
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    self.m_mainNode=cc.Node:create()
    self.m_mainNode:setPosition(cc.p(self.m_winSize.width,self.m_winSize.height))
    self.m_rootLayer:addChild(self.m_mainNode)

    self.show=function()
        self:initView()
    end

    local fileArray={"ui/battle_res.plist","ui/battle_res32.plist","ui/ui_shop.plist","meiren_cnf","gl_strong_id_cnf"}
    ScenesManger.loadScene(self,_G.Cfg.UI_BattleResView,fileArray)

    return self.m_rootLayer
end

function UICopyPass.closeWindow(self)
    self:removeSchedule()
    self.m_rootLayer:removeFromParent(true)
    _G.g_Stage:autoExitCopy()
    self:destroy()
end
function UICopyPass.removeSchedule(self)
    if self.schdedulerHandle~=nil then
        _G.Scheduler:unschedule(self.schdedulerHandle)
        self.schdedulerHandle=nil
    end
    if self.m_timesLabel~=nil then
        self.m_timesLabel:removeFromParent(true)
        self.m_timesLabel=nil
    end
end

--初始化 成员
function UICopyPass.initView(self)
    --底图
    -- local bgContentSize=cc.size(850,486)
    -- local viewBg=ccui.Scale9Sprite:createWithSpriteFrameName("ui_battle_res_bg.png",cc.rect(190,240,1,1))
    -- local viewBg=ccui.Scale9Sprite:createWithSpriteFrameName("ui_battle_res_bg.png")
    -- viewBg:setPreferredSize(bgContentSize)
    -- viewBg:setPosition(self.m_winSize.width*0.5+bgContentSize.width*0.5,0)
    -- self.m_mainNode:addChild(viewBg)

    -- local spr = cc.Sprite:createWithSpriteFrameName("general_rolebg2.png")
    -- local sprSize = spr:getContentSize()
    -- spr:setPosition(bgContentSize.width/2,sprSize.height/2)
    -- viewBg:addChild(spr)
    
    -- _G.Util:playAudioEffect("match_win")

    -- local function actionCallFunc()
        self:firstShow()
    -- end
    -- local function actionCallFunc2(  )
    --     local myLine1  = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_battle_line.png" )
    --     myLine1        : setPreferredSize( cc.size( bgContentSize.width-60, 2 ) )
    --     myLine1        : setPosition( 0, 150 )
    --     self.m_mainNode:addChild( myLine1, 1 )

    --     local myLine2  = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_battle_line.png" )
    --     myLine2        : setPreferredSize( cc.size( bgContentSize.width-60, 2 ) )
    --     myLine2        : setPosition( 0, 0 )
    --     self.m_mainNode:addChild( myLine2, 1 )
    -- end
    -- viewBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.4,cc.p(0,0)),cc.CallFunc:create(actionCallFunc),cc.CallFunc:create(actionCallFunc2)))
end

function UICopyPass.firstShow(self)
    --title
    -- self.titleSprite=cc.Sprite:createWithSpriteFrameName("ui_battle_res_word_1.png")
    -- self.titleSprite:setPosition(0,240)
    -- self.m_mainNode:addChild(self.titleSprite)
    -- self.titleSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25,1.4),cc.ScaleTo:create(0.25,1)))

    -- local function actionCallFunc()
        self:secondShow()
    -- end

    --ko level
    -- local KOLevelFileName="ui_battle_res_"..tostring(self.m_eva)..".png"
    -- self.KOLevelSprite=cc.Sprite:createWithSpriteFrameName(KOLevelFileName)
    -- self.KOLevelSprite:setPosition(self.m_winSize.width*0.5,-self.m_winSize.height*0.5)
    -- self.m_mainNode:addChild(self.KOLevelSprite,10)
    -- self.KOLevelSprite:runAction(cc.Sequence:create(cc.CallFunc:create(actionCallFunc),cc.DelayTime:create(1.5),cc.EaseBounceOut:create(cc.MoveTo:create(0.4,cc.p(220,80)))))
end

function UICopyPass.secondShow(self)
    --ko level effect
    -- local KOLevelFileName="ui_battle_res_"..tostring(self.m_eva)..".png"
    -- self.KOLevelEffectSprite=cc.Sprite:createWithSpriteFrameName(KOLevelFileName)
    -- self.KOLevelEffectSprite:setPosition(220,80)
    -- self.KOLevelEffectSprite:setOpacity(100)
    -- self.KOLevelEffectSprite:setVisible(false)
    -- self.m_mainNode:addChild(self.KOLevelEffectSprite,10)

    -- local function actionCallFunc1(  )
    --     self.KOLevelEffectSprite:setVisible( true )
    -- end

    -- local function actionCallFunc()
    --     self.KOLevelEffectSprite:removeFromParent(true)
    --     self.KOLevelEffectSprite=nil
    -- end
    -- self.KOLevelEffectSprite:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(actionCallFunc1),cc.ScaleTo:create(0.5,2),cc.CallFunc:create(actionCallFunc)))

    local tempEva=self.m_eva
    if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS then
        tempEva=0
    elseif tempEva>3 then
        tempEva=3
    end
    self:showNewTexiao(tempEva)
end

function UICopyPass.normalThridShow(self)
    if not self.m_isGoodsDraw then
        self:showGoodsNormalGet()
        return
    end


    CCLOG("UICopyPass.normalThridShow =%s",debug.traceback())
    local color1=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
    local color2=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
    local color3=_G.ColorUtil:getRGB(_G.Const.CONST_COUNTRY_DEFAULT)

    local nPosY=118
    -- local lbPingjia=_G.Util:createLabel("评价:",26)
    -- lbPingjia:setColor(color1)
    -- lbPingjia:setAnchorPoint(cc.p(1,0.5))
    -- lbPingjia:setPosition(-170,nPosY)
    -- self.m_mainNode:addChild(lbPingjia)

    local szCond1,szCond2
    if self.m_conditionType1==1 then
        szCond1=string.format("存活人数不少于%d人",self.m_conditionNum1)
    else
        szCond1=string.format("通关时间不超过%d秒",self.m_conditionNum1)
    end
    if self.m_conditionType2==1 then
        szCond2=string.format("存活人数不少于%d人",self.m_conditionNum2)
    else
        szCond2=string.format("通关时间不超过%d秒",self.m_conditionNum2)
    end
    local lbCondition={}
    lbCondition[1]=_G.Util:createLabel("成功通关",self.fontSize)
    lbCondition[2]=_G.Util:createLabel(szCond1,self.fontSize)
    lbCondition[3]=_G.Util:createLabel(szCond2,self.fontSize)

    local myPosX = { -300, -100, 200 }
    local actionTimes=0.3
    local delayTime=0.15
    for i=1,3 do
        local y=nPosY-140
        local starSpr=gc.GraySprite:createWithSpriteFrameName("ui_battle_res_start.png")
        starSpr:setScale(0.01)
        starSpr:setAnchorPoint(1,0.5)
        starSpr:setPosition(myPosX[i],y)
        self.m_mainNode:addChild(starSpr)

        lbCondition[i]:setAnchorPoint(cc.p(0,0.5))
        lbCondition[i]:setPosition(myPosX[i]+10,y)
        lbCondition[i]:setOpacity(0)
        self.m_mainNode:addChild(lbCondition[i])

        if self.m_conditionOk[i] then
            lbCondition[i]:setColor(color2)
        else
            starSpr:setGray()
            lbCondition[i]:setColor(color3)
        end

        starSpr:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime+0.5),
                                             cc.ScaleTo:create(actionTimes,0.4)))
        lbCondition[i]:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime+0.5),
                                             cc.FadeTo:create(actionTimes,255)))

    end

    self:showStar(2)

    local function local_showGood()
        self:showGoodsDraw()
    end
    self.m_mainNode:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime+0.7),cc.CallFunc:create(local_showGood)))
end
function UICopyPass.fighterThridShow(self)
    local color1=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
    local color2=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)
    local color3=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE)

    self.num3Node = cc.Node : create()
    self.num3Node : setPosition( 5, -70 )
    self.m_mainNode:addChild( self.num3Node )

    local nPosY=70
    local lbPingjia=_G.Util:createLabel("战斗数据:",20)
    -- lbPingjia:setColor(color1)
    lbPingjia:setAnchorPoint(cc.p(1,0.5))
    lbPingjia:setPosition(-175,nPosY)
    self.num3Node:addChild(lbPingjia)

    local maxljTimes=_G.g_Stage.carom_times
    local limitTimes=_G.g_Stage.m_copyPassLimitTimes
    local allowTimes=_G.g_Stage.m_copyPassAllowTimes
    local passTimes=_G.g_Stage.m_copyPassTimes
    local useTimes=allowTimes-limitTimes+passTimes
    local copyFloor=_G.g_BattleView.m_futuCopyFloor or 0
    local copyPos=_G.g_BattleView.m_futuCopyPos or 0
    local szCopyInfo=string.format("第%s层 第%d关",_G.Lang.number_Chinese[copyFloor],copyPos)

    local tbLabel={1,1}
    tbLabel[1]=_G.Util:createLabel("关卡: ",self.fontSize)
    -- tbLabel[2]=_G.Util:createLabel("连击: ",self.fontSize)
    tbLabel[2]=_G.Util:createLabel("时间: ",self.fontSize)

    local lbCondition={1,1}
    lbCondition[1]=_G.Util:createLabel(szCopyInfo,self.fontSize)
    -- lbCondition[2]=_G.Util:createLabel(string.format("%d",maxljTimes),self.fontSize)
    lbCondition[2]=_G.Util:createLabel(string.format("%d秒",useTimes),self.fontSize)

    local actionTimes=0.3
    local delayTime=0.15
    for i=1,#lbCondition do
        tbLabel[i]:setAnchorPoint(cc.p(0,0.5))
        tbLabel[i]:setPosition(-150,nPosY-5)
        tbLabel[i]:setOpacity(0)
        -- tbLabel[i]:setColor(color2)
        self.num3Node:addChild(tbLabel[i])

        lbCondition[i]:setAnchorPoint(cc.p(0,0.5))
        lbCondition[i]:setPosition(-95,nPosY-5)
        lbCondition[i]:setOpacity(0)
        lbCondition[i]:setColor(color2)
        self.num3Node:addChild(lbCondition[i])

        tbLabel[i]:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime),cc.FadeTo:create(actionTimes,255)))
        lbCondition[i]:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime),cc.FadeTo:create(actionTimes,255)))
        nPosY=nPosY-35
    end

    local function local_showGood()
        self:showGoodsNormalGet()
    end
    self.num3Node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime+0.2),cc.CallFunc:create(local_showGood)))
end
function UICopyPass.showSureButton(self)
    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag=sender:getTag()
            if tag==1 then
                if self.m_isGoodsDraw and self.m_times ~= 0 then
                    if self.m_useCount==nil or self.m_eva>self.m_useCount then
                        local command = CErrorBoxCommand(14270)
                        controller :sendCommand( command )
                        return
                    end
                end
                self:closeWindow()
            elseif tag==2 then
                local nextCopyId
                if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS then
                    nextCopyId=_G.g_Stage.nextCopyId
                else
                    nextCopyId=self.ackCopyOverData.copy_next
                end
                print("JJJJJJ=================>>>",nextCopyId)
                if nextCopyId==nil or nextCopyId==0 then
                    print("lua error....   没收到下个副本ID的协议")
                    return
                end
                local msg=REQ_COPY_NEW_CREAT()
                msg:setArgs(nextCopyId)
                _G.Network:send(msg)
            elseif tag==3 then
                _G.g_waitToCopyId=self.m_nextCopyId
                self:closeWindow()
            end
            if self.m_guideNode~=nil then
                self.m_guideNode:removeFromParent(true)
                self.m_guideNode=nil
            end
        end
    end

    --certain button
    self.m_sureButton=gc.CButton:create("ui_battle_res_btn2.png")
    self.m_sureButton:setOpacity(0)
    self.m_sureButton:setTag(1)
    self.m_sureButton:ignoreContentAdaptWithSize(false)
    self.m_sureButton:setContentSize(cc.size(self.m_sureButton:getContentSize().width+30,self.m_sureButton:getContentSize().height+30))
    self.m_mainNode:addChild(self.m_sureButton,20)

    local function actionCallFunc(btnNode)
        btnNode:addTouchEventListener(c)

        -- if self.m_copyId==GUIDE_COPY_ID and not self.m_goNextButton then
        --     local btnSize=self.m_sureButton:getContentSize()
        --     local guideNode=_G.GGuideManager:createTouchNode()
        --     guideNode:setPosition(btnSize.width*0.5,btnSize.height*0.5)
        --     self.m_sureButton:addChild(guideNode,100)

        --     local noticNode=_G.GGuideManager:createNoticNode("返回太平镇",true)
        --     noticNode:setPosition(-200,btnSize.height*0.5-10)
        --     guideNode:addChild(noticNode)
        --     self.m_guideNode=guideNode
        -- end
    end
    self.m_sureButton:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),
                                               cc.FadeTo:create(0.2,255),
                                               cc.CallFunc:create(actionCallFunc)))

    


    if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS then
        self.m_sureButton:setPosition(self.m_winSize.width/2-70,-260)

        self.m_goNextButton=gc.CButton:create("ui_battle_next.png")
        self.m_goNextButton:setOpacity(0)
        self.m_goNextButton:setTag(2)
        self.m_goNextButton:setPosition(self.m_winSize.width/2-200,-260)
        self.m_mainNode:addChild(self.m_goNextButton)
        self.m_goNextButton:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),
                                               cc.FadeTo:create(0.2,255),
                                               cc.CallFunc:create(actionCallFunc)))
    else
        if self.m_isGoodsDraw then
            self.m_sureButton:setPosition(self.m_winSize.width/2-70,-260)
        else
            -- local nextCopyId=self.ackCopyOverData.copy_next
            -- if nextCopyId and nextCopyId~=0 then
            --     self.m_goNextButton=gc.CButton:create("ui_battle_next.png")
            --     self.m_goNextButton:setOpacity(0)
            --     self.m_goNextButton:setTag(3)
            --     self.m_goNextButton:setPosition(self.m_winSize.width/2-200,-260)
            --     self.m_mainNode:addChild(self.m_goNextButton)
            --     self.m_goNextButton:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),
            --                                            cc.FadeTo:create(0.2,255),
            --                                            cc.CallFunc:create(actionCallFunc)))

            --     self.m_nextCopyId=nextCopyId

            --     local btnSize=self.m_goNextButton:getContentSize()
            --     local guideNode=_G.GGuideManager:createTouchNode()
            --     guideNode:setPosition(btnSize.width*0.5,btnSize.height*0.5)
            --     self.m_goNextButton:addChild(guideNode,100)

            --     -- local noticNode=_G.GGuideManager:createNoticNode("进入下一关",true)
            --     -- noticNode:setPosition(-200,btnSize.height*0.5-10)
            --     -- guideNode:addChild(noticNode)
            --     self.m_guideNode=guideNode
            -- end

            if self.ackCopyOverData.copy_next and self.ackCopyOverData.copy_next~=0 then
                _G.g_waitToCopyId=self.ackCopyOverData.copy_next
            else
                _G.g_waitToCopyId=nil
            end

            -- local openNode=self:createGNKF()
            -- if openNode then
            --     if self.m_goNextButton then
            --         openNode:setPosition(self.m_winSize.width/2-330,-260)
            --     else
            --         openNode:setPosition(self.m_winSize.width/2-200,-260)
            --     end
            --     self.m_mainNode:addChild(openNode)
            -- end

            self.m_sureButton:setPosition(self.m_winSize.width/2-70,-260)
        end
    end
end

function UICopyPass.createGNKF( self )
    print( "_G.g_Stage:OpenId()=====>>>>> ", _G.g_Stage:getOpenId() )
    local OpenId = _G.g_Stage:getOpenId()
    if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS 
       or not self.m_sceneCopyCnf.strong_id or OpenId==0 or not OpenId then return end

    local myNode = cc.Node:create()
    local gl_strong = _G.Cfg.gl_strong_id[OpenId]

    local spr = cc.Sprite : createWithSpriteFrameName( string.format("%s.png",gl_strong.sub_pic) )
    myNode : addChild( spr )

    local labNeed = _G.Util : createLabel( string.format( "%s开启", gl_strong.terms), 18 )
    labNeed : setAnchorPoint( 0.5, 1 )
    labNeed : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LABELBLUE ) )
    -- labNeed : setPosition( -spr:getContentSize().width/2+5, -spr:getContentSize().height/2-2 )
    labNeed : setPosition( 0, -spr:getContentSize().height/2+2 )
    myNode  : addChild( labNeed )

    return myNode
end

-- 显示普通奖励
function UICopyPass.showGoodsNormalGet(self)
    local tempY=-95
    -- local color1=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN)
    local lbJiangLi=_G.Util:createLabel("通关奖励:",20)
    -- lbJiangLi:setColor(color1)
    lbJiangLi:setAnchorPoint(cc.p(1,0.5))
    lbJiangLi:setPosition(-170,tempY)
    lbJiangLi:setOpacity(0)
    lbJiangLi:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeTo:create(0.2,255)))
    self.m_mainNode:addChild(lbJiangLi)

    if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_NORMAL
        or self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_HERO
        or self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIEND 
        or self.m_sceneType == _G.Const.CONST_MAP_CLAN_DEF_TIME2 then 

        local lab1= _G.Util : createLabel("你成功通关了",20)
        -- lab1   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
        lab1   : setAnchorPoint(cc.p(0,0.5))
        lab1   : setOpacity(0)
        lab1   : runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeTo:create(0.2,255)))
        lab1   : setPosition(cc.p(-150,-3))
        self.m_mainNode : addChild(lab1)

        local labWidth=-150+lab1:getContentSize().width
        local lab1= _G.Util : createLabel(self.m_sceneCopyCnf.copy_name,20)
        lab1   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        lab1   : setAnchorPoint(cc.p(0,0.5))
        lab1   : setOpacity(0)
        lab1   : runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeTo:create(0.2,255)))
        lab1   : setPosition(cc.p(labWidth,-3))
        self.m_mainNode : addChild(lab1)

        local labWidth=labWidth+lab1:getContentSize().width
        local lab1= _G.Util : createLabel("！",20)
        -- lab1   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
        lab1   : setAnchorPoint(cc.p(0,0.5))
        lab1   : setOpacity(0)
        lab1   : runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeTo:create(0.2,255)))
        lab1   : setPosition(cc.p(labWidth,-3))
        self.m_mainNode : addChild(lab1)

        local lab2 = _G.Util : createLabel("历练，这只是一个开始！",20)
        -- lab2   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
        lab2   : setOpacity(0)
        lab2   : runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeTo:create(0.2,255)))
        lab2   : setPosition(cc.p(50,-37))
        self.m_mainNode : addChild(lab2)
    end

    local function r(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local goodId=sender:getTag()
            local pos=sender:getWorldPosition()
            local temp = _G.TipsUtil:createById(goodId,nil,pos)
            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
        end
    end

    local function local_showSureButton()
        self:showSureButton()
    end

    local function f( )
        _G.Util:playAudioEffect("balance_reward")
    end

    local delayTime=0.15
    for i=1,4 do
        local goodsId,count
        if self.m_goodDatas[i]~=nil then
            goodsId=self.m_goodDatas[i].goods_id
            count=self.m_goodDatas[i].count
        end
        local boxSpr=self:createGoodsIcon()
        boxSpr:setPosition(cc.p(-20+100*(i-2),tempY-40))
        boxSpr:setVisible(false)
        self.m_mainNode:addChild(boxSpr)
        boxSpr:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.Show:create()))

        if goodsId~=nil and count~=nil then
            local goodSpr=self:createGoodsIcon(goodsId,count)
            goodSpr:setPosition(cc.p(-20+100*(i-2),tempY-40))
            goodSpr:setScale(0)
            self.m_mainNode:addChild(goodSpr,5-i)

            local lbg = cc.Sprite:createWithSpriteFrameName("ui_battle_boom.png")
            lbg:setPosition(cc.p(-20+100*(i-2),tempY-40))
            self.m_mainNode:addChild(lbg,100)
            lbg:setScale(0)
            lbg:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime+1),cc.Spawn:create(cc.ScaleTo:create(0.2,6)),cc.Hide:create()))

            if i==1 then
                goodSpr:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime+1),
                                                     cc.CallFunc:create(f),cc.ScaleTo : create( 0.3, 1 ),cc.DelayTime:create(0.45),
                                                     cc.CallFunc:create(local_showSureButton)))
            else
                goodSpr:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*delayTime+1),
                                                     cc.CallFunc:create(f),cc.ScaleTo : create( 0.3, 1 )))
            end
        end
    end
end


function UICopyPass.showNewTexiao( self, _num )
    local m_winSize = cc.Director : getInstance() : getVisibleSize()

    self.myMidNode = cc.Node : create()
    self.m_mainNode : addChild( self.myMidNode, -6 )
    self.myMidNode : setPosition( 0,-30 )

    local lineLayer  = cc.LayerColor:create(cc.c4b(0,0,0,0))
    lineLayer  : setPosition( -m_winSize.width/2, -m_winSize.height/2 )
    lineLayer  : setContentSize(m_winSize)
    lineLayer  : runAction(cc.FadeTo:create(0.2,180))
    self.m_mainNode  : addChild(lineLayer, -10)
    
    local spr_win  = cc.Sprite : createWithSpriteFrameName( "ui_battle_win1.png" )
    spr_win : setPosition( 0, 0 )
    spr_win : setScale(10)
    self.myMidNode : addChild( spr_win )

    local winX,winY=233,118
    local tempWin2=cc.Sprite:createWithSpriteFrameName("ui_battle_win2.png")
    tempWin2:runAction(cc.RepeatForever:create(cc.RotateBy:create(6,360)))
    tempWin2:setPosition(winX,winY)
    spr_win:addChild(tempWin2)

    local tempWin3=cc.Sprite:createWithSpriteFrameName("ui_battle_res_2.png")
    tempWin3:setPosition(winX,winY)
    spr_win:addChild(tempWin3)

    local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_battle_fram.png" )
    local lineX = line1 : getContentSize().width
    line1 : setScaleX( m_winSize.width*0.8/lineX )
    line1 : setOpacity(0)
    lineLayer : addChild( line1 )

    local tempHeight=170
    if self.m_isGoodsDraw then
        line1 : setPosition( m_winSize.width/2, 300 )
        tempHeight=210
    else
        line1 : setPosition( m_winSize.width/2, 300 )
        line1 : setScaleY(1.3)
    end
    -- if _num == 0 then
    --     line1 : setPosition( m_winSize.width/2, 330 )
    -- end

    local tempEffect=nil
    local function showVirate()
        _G.g_Stage:vibrate(5,6,0.05)
        _G.Util:playAudioEffect("1009")

        tempEffect=_G.SpineManager.createSpine("spine/shengli1",1)
        tempEffect:setAnimation(0,"idle",false)
        self.myMidNode:addChild(tempEffect,50)
    end

    local function removeTempEffect()
        if tempEffect then
            tempEffect:removeFromParent(true)
            tempEffect=nil
        end
    end

    local function endFun()
        if self.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS then
            self:fighterThridShow()
        else
            self:normalThridShow()
        end
        line1:runAction(cc.FadeTo:create(0.2,255))
    end

    spr_win:runAction(cc.Sequence:create( cc.Spawn:create( cc.ScaleTo:create( 0.2, 1 ), 
                                                           cc.MoveTo :create( 0.2, cc.p( 0, 0 ) )
                                                          ),
                                          cc.CallFunc:create(showVirate),
                                          cc.DelayTime:create(0.8),
                                          cc.CallFunc:create(removeTempEffect),
                                          cc.Spawn:create( cc.MoveTo:create(0.3,cc.p(0,tempHeight)),
                                                           cc.DelayTime:create(0.1),
                                                           cc.CallFunc:create(endFun)
                                                          )
                                         )
                      )

    

    -- if _num ~= 0 then
    --     self : showStar( _num )
    -- end
end

function UICopyPass.showStar( self, _num )
    print( "x星星数量：", _num )
    local m_winSize = cc.Director : getInstance() : getVisibleSize()
    local lineSize  = cc.size( m_winSize.width,400 )
    local myPosX = { -300, -100, 200 }
    local myPosY = -30
    local myWidget = {}
    for i=1,3 do
        myWidget[i] = ccui.Widget : create()
        myWidget[i] : setVisible( false )
        self.myMidNode : addChild( myWidget[i], 5 )

        for m=1,3 do
            local star = gc.GraySprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
            star : setPosition( myPosX[m], myPosY )
            -- star : setScale(0.4)
            star : setTag(m)
            star : setVisible( false )
            myWidget[i] : addChild( star )
            if i==1 then
                if m>1 then
                    star:setGray()
                end
            elseif i==2 then
                if not self.m_conditionOk[m] then
                    star:setGray()
                end
            end
        end
    end
    self.myWidget = myWidget

    -- -- 一个星星

    -- local star = cc.Sprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
    -- star : setPosition( myPosX[2], myPosY )
    -- -- star : setScale(0.4)
    -- star : setTag(1)
    -- star : setVisible( false )

    -- myWidget[1] : addChild( star )

    -- -- 两个星星
    -- local star = cc.Sprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
    -- star : setPosition( 0-40, lineSize.height/2-100 )
    -- -- star : setRotation( -8 )
    -- star : setTag(1)
    -- -- star : setScale( 0.8 )
    -- star : setVisible( false )
    -- myWidget[2] : addChild( star )

    -- local star = cc.Sprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
    -- star : setPosition( 0+40, lineSize.height/2-100 )
    -- -- star : setRotation( 8 )
    -- star : setTag(2)
    -- -- star : setScale( 0.8 )
    -- star : setVisible( false )
    -- myWidget[2] : addChild( star )

    -- -- 三个星星
    -- local star = cc.Sprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
    -- star : setPosition( myPosX[1], myPosY )
    -- star : setTag(1)
    -- star : setVisible( false )
    -- myWidget[3] : addChild( star )

    -- local star = cc.Sprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
    -- star : setPosition( myPosX[2], myPosY )
    -- star : setTag(2)
    -- star : setVisible( false )
    -- myWidget[3] : addChild( star )

    -- local star = cc.Sprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
    -- star : setPosition( myPosX[3], myPosY )
    -- star : setTag(3)
    -- star : setVisible( false )
    -- myWidget[3] : addChild( star )
    

    -- self.myWidget[3] : setVisible( true )
    self : showStarTexiao( _num )
end

function UICopyPass.showStarTexiao( self, _num )
    local posX = {-100,0,100}
    local posY = {80,80,80} 
    -- local rota = { {0}, {-8,8}, {-8,0,8} }
    -- local scal = { {1}, {1,1}, {1,1,1} }

    local myPosX = { -300, -100, 200 }
    local movePosX = {myPosX[1], myPosX[2], myPosX[3]}

    self.myWidget[_num] : setVisible( true )

    local function starVis( star )
        star : setVisible( true )
    end

    for i=1,3 do
        local star = self.myWidget[_num] : getChildByTag(i)

        local function starMove( self )
            self : runAction( cc.RepeatForever:create( 
                                        cc.Sequence:create( 
                                                            cc.ScaleTo:create( 1, 1+0.1 ),
                                                            cc.ScaleTo:create( 1, 1 )
                                                          )
                                                 ) 
                        )
        end

        local function starTexiao( )

            _G.Util:playAudioEffect("balance_star")
            local spineOne = _G.SpineManager.createSpine("spine/jie",1)
            spineOne : setPosition( posX[i], posY[i] )
            spineOne : setAnimation(0,"idle",false)
            self.myMidNode : addChild(spineOne,10)


            local star = cc.Sprite : createWithSpriteFrameName( "ui_battle_res_start.png" )
            -- star : setRotation(rota[i])
            star : setPosition( posX[i], posY[i] )
            _G.ShaderUtil:shaderNormalById(star,13)
            self.myMidNode : addChild(star,10)
            star : runAction(cc.Spawn:create(cc.ScaleTo:create(0.5,5),cc.FadeOut:create(0.5)))
        end

        star : runAction( cc.Sequence:create(  cc.DelayTime:create((i-1)*0.15+0.6 ),
                                                cc.CallFunc:create( starVis ),
                                                cc.MoveBy:create(  0, cc.p(movePosX[i], -7) ),
                                                cc.Spawn:create(
                                                                cc.JumpTo:create( 0.4, cc.p( posX[i], posY[i]), 300, 1),
                                                                cc.RotateBy:create( 0.3, 360 ),
                                                                cc.Sequence:create( cc.ScaleTo:create(0.2, 3 ),
                                                                                    cc.ScaleTo:create(0.2, 1 )
                                                                                  )
                                                                ),
                                                cc.CallFunc:create( starTexiao ),
                                                cc.Sequence:create(
                                                                    cc.MoveBy:create(0.05,cc.p(-6/2,0)),                                          
                                                                    cc.MoveBy:create(0.05,cc.p(12/2,0)),
                                                                    cc.MoveBy:create(0.05,cc.p(-12/2,0)),
                                                                    cc.MoveBy:create(0.05,cc.p(12/2,0)),

                                                                    cc.MoveBy:create(0.05,cc.p(-12/2,0)),
                                                                    cc.MoveBy:create(0.05,cc.p(12/2,0)),

                                                                    cc.MoveBy:create(0.05,cc.p(-12/2,0)),
                                                                    cc.MoveBy:create(0.05,cc.p(6/2,0))  
                                                                  ),

                                                cc.CallFunc:create( starMove ) 
                                            )
                                                
                             )
    end
end

-- 翻牌抽奖
function UICopyPass.showGoodsDraw(self)
    self.m_mediator=UICopyPassMediator(self)

    local color1=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
    local color2=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE)
    local goodsArray=self.m_sceneCopyCnf.reward or {}
    local goodsCount=#goodsArray

    self.m_cardSprSize=cc.size(157,206)
    self.m_cardY=-105-50
    self.m_cardXArray={}
    local nWidth=150
    for i=1,4 do
        self.m_cardXArray[i]=-(2-i+0.5)*nWidth
    end

    self.m_selectIng=false
    self.m_curUseRmb=0
    local function selectPos(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local pos=sender:getTag()
            print("showGoodsDraw===>>> select pos=",pos)
            if self.m_selectIng or self.m_cardNodeArray[pos]==nil then return end

            local myProperty=_G.GPropertyProxy:getMainPlay()
            local rmb=myProperty:getRmb()+myProperty:getBindRmb()
            if rmb<self.m_curUseRmb then
                local command=CErrorBoxCommand(11567)
                controller:sendCommand(command)
                return
            end

            self.m_selectIng=true

            local msg=REQ_COPY_DRAW_REQUEST()
            msg:setArgs(0,pos)
            _G.Network:send(msg)
            _G.g_Stage.sendMsg=msg

            -- 模拟
            -- local msg={}
            -- msg.count=1
            -- msg.msg_draw_xxx={
            --     {pos=pos,goods_id=46400,count=10},
            -- }
            -- self:talkGoodsBack(msg)
        end
    end

    self.m_cardNodeArray={}
    local function drawFinish(node)
        node:addTouchEventListener(selectPos)
        if node:getTag()==4 then
            self:showTimes()
        end
    end
    -- 翻牌
    local function drawHalf(node)
        local tag=node:getTag()
        node:removeFromParent(true)

        self.m_cardNodeArray[tag]=gc.CButton:create("ui_battle_res_card1.png")
        self.m_cardNodeArray[tag]:setPosition(self.m_cardXArray[tag],self.m_cardY)
        self.m_cardNodeArray[tag]:setTag(tag)
        self.m_mainNode:addChild(self.m_cardNodeArray[tag])

        local action=cc.Sequence:create( cc.OrbitCamera:create(DrawActionTimes,1,0,-90,90,0,0),
                                        cc.CallFunc:create(drawFinish) )
        self.m_cardNodeArray[tag]:runAction(action)

        -- local rmbBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_loading_1.png",cc.rect(9,4,1,1))
        -- rmbBg:setPreferredSize(cc.size(95,30))
        -- rmbBg:setPosition(self.m_cardSprSize.width*0.5-8,50-10)
        -- self.m_cardNodeArray[tag]:addChild(rmbBg)

        local rmbLabel=_G.Util:createLabel("免费",20)
        rmbLabel:setColor(color2)
        rmbLabel:setPosition(self.m_cardSprSize.width*0.5-8,50-20)
        self.m_cardNodeArray[tag]:addChild(rmbLabel,0,777)
    end

    local lookArray={}
    local function showCardBack()
        if self.m_times == 0 then
            local msg=REQ_COPY_DRAW_READY()
            msg:setArgs(0)
            _G.Network:send(msg)
            return
        end
        self:removeSchedule()
        for i=1,#lookArray do
            local action=cc.Sequence:create(cc.DelayTime:create(1),cc.OrbitCamera:create(DrawActionTimes,1,0,0,90,0,0),cc.CallFunc:create(drawHalf))
            lookArray[i]:runAction(action)
        end
        if not self.m_showed then
            self:showSureButton()
            local msg=REQ_COPY_DRAW_READY()
            msg:setArgs(1)
            _G.Network:send(msg)
        end
    end
    self.m_showCardBackFun = showCardBack

    if self.m_times ~= 0 then
        self:showTimes(true,showCardBack)
    else
        self:showSureButton()

        local nPosX,nPosY = 0 ,-222
        self.m_timesLabel=_G.Util:createLabel("点击空白区域开始翻牌",20)
        self.m_timesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        self.m_timesLabel:setPosition(nPosX,nPosY-40)
        self.m_mainNode:addChild(self.m_timesLabel)
    end

    local function showCardFinish(node)
        local goodSpr=node:getChildByTag(666)
        if goodSpr~=nil then
            goodSpr:setVisible(true)
        end
        if node:getTag()==4 then
            local function winTouchBack(sender, eventType)
                if eventType==ccui.TouchEventType.ended then
                    showCardBack()
                    if self.m_times ~= 0 then
                        sender:removeFromParent(true)
                        self.m_winTouch=nil
                    end
                end
            end
            self.m_winTouch=ccui.Widget:create()
            self.m_winTouch:setContentSize(self.m_winSize)
            self.m_winTouch:setTouchEnabled(true)
            self.m_winTouch:addTouchEventListener(winTouchBack)
            self.m_mainNode:addChild(self.m_winTouch)
        end
    end

    for i=1,4 do
        local action=cc.Sequence:create(cc.DelayTime:create((i-1)*0.15+1),
                                        cc.FadeTo:create(0.2,255),
                                        cc.CallFunc:create(showCardFinish)
                                        )
        local tempSpr=cc.Sprite:createWithSpriteFrameName("ui_battle_res_card2.png")
        tempSpr:setPosition(self.m_cardXArray[i],self.m_cardY)
        tempSpr:runAction(action)
        tempSpr:setTag(i)
        tempSpr:setOpacity(0)
        self.m_mainNode:addChild(tempSpr,10)
        lookArray[i]=tempSpr

        local goodsId,count
        if goodsCount>=i then
            goodsId=goodsArray[i][1][1]
            count=goodsArray[i][1][2]
        end

        local goodsSpr=self:createGoodsIcon(goodsId,count)
        goodsSpr:setVisible(false)
        goodsSpr:setPosition(self.m_cardSprSize.width*0.5-7,self.m_cardSprSize.height*0.5+18-20)
        tempSpr:addChild(goodsSpr,5-i,666)
    end
end
function UICopyPass.talkGoodsBack(self,_ackMsg)
    self.m_selectIng=false

    if self.m_cardNodeArray==nil then return end

    _G.Util:playAudioEffect("ui_card")

    local newData={}
    for i=1,#_ackMsg.msg_draw_xxx do
        local talkData=_ackMsg.msg_draw_xxx[i]
        local T={}
        T.goods_id=talkData.goods_id
        T.count=talkData.count
        newData[talkData.pos]=T
    end

    local function drawFinish(node)
        
    end
    local function drawHalf(node)
        local tag=node:getTag()

        local action=cc.Sequence:create(cc.OrbitCamera:create(DrawActionTimes,1,0,-90,90,0,0),
                                        cc.CallFunc:create(drawFinish))
        local tempSpr=cc.Sprite:createWithSpriteFrameName("ui_battle_res_card2.png")
        tempSpr:setPosition(self.m_cardXArray[tag],self.m_cardY)
        tempSpr:runAction(action)
        self.m_mainNode:addChild(tempSpr)

        local talkData=newData[tag]
        local goodsId=talkData.goods_id
        local count=talkData.count

        local goodsSpr=self:createGoodsIcon(goodsId,count)
        goodsSpr:setPosition(self.m_cardSprSize.width*0.5-7,self.m_cardSprSize.height*0.5+18-20)
        tempSpr:addChild(goodsSpr)

        node:removeFromParent(true)
    end

    for pos,_ in pairs(newData) do
        local cardNode=self.m_cardNodeArray[pos]
        if cardNode~=nil then
            self.m_cardNodeArray[pos]=nil
            local action=cc.Sequence:create(cc.OrbitCamera:create(DrawActionTimes,1,0,0,90,0,0),
                                            cc.CallFunc:create(drawHalf))
            cardNode:runAction(action)
        end
    end

    local curCount=0
    for k,v in pairs(self.m_cardNodeArray) do
        curCount=curCount+1
    end

    self.m_useCount=4-curCount
    if self.m_eva<=self.m_useCount and curCount>0 then
        local drawRmb=self.m_sceneCopyCnf.draw_rmb
        local useRmb=999999
        for i=1,#drawRmb do
            local data=drawRmb[i]
            if data[1]==self.m_useCount+1 then
                useRmb=data[2]
                break
            end
        end

        self.m_curUseRmb=useRmb
        useRmb=string.format("%d%s",useRmb,_G.Lang.Currency_Type[2])
        for k,v in pairs(self.m_cardNodeArray) do
            local rmbLabel=v:getChildByTag(777)
            if rmbLabel~=nil then
                rmbLabel:setString(useRmb)
            end
        end
        if self.m_eva<=self.m_useCount and self.m_sureButton==nil then
            if self.m_sureButton==nil then
                self:showSureButton()
            end
        end
    end

    _G.g_Stage.sendMsg=nil
end

function UICopyPass.createUPNum( self, _num )
    local node = cc.Node : create()

    local num = _num*100
    local allNum = {}
    allNum[1] = math.floor(num/100)
    allNum[3] = math.floor(num%100/10)
    allNum[4] = math.floor(num%10)
    print( "allNum ===>> ", allNum[1],allNum[2],allNum[3] )

    local base = cc.Sprite : createWithSpriteFrameName( "shop_bei.png" )
    base : setAnchorPoint( 0, 0 )
    base : setPosition( 4, 6 )
    node : addChild( base )

    local node2 = cc.Layer : create()
    node2 : setRotation( -45 )

    local width = 0
    for i=1,4 do
        local sprName = nil
        local posy    = 0
        if i == 2 then
            sprName = "shop_dian.png"
        else
            sprName = string.format( "shop_%d.png", allNum[i] )
        end
        local spr = cc.Sprite : createWithSpriteFrameName( sprName )
        spr   : setAnchorPoint( 0, 0 )
        spr   : setPosition( width+35, 11 )
        node2 : addChild( spr )
        if i == 2 then
            spr : setPosition( width+35, 6 )
        end
        width = width + spr:getContentSize().width
        if i == 1 or i == 2 then
            width = width - 6
        end
    end

    node2 : setScale( 0.8 )
    node2 : setContentSize( cc.size( width, 1 ) )
    node2 : setAnchorPoint( 0, 0 )
    node2 : setPosition(0, 0 )
    node  : addChild( node2,1 )
    return node
end

function UICopyPass.createGoodsIcon(self,_goodsId,_goodsCount)
    local goodsSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")

    if _goodsId~=nil and _goodsCount~=nil then
        local function goodsTips(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                local goodId=sender:getTag()
                local pos=sender:getWorldPosition()
                local temp=_G.TipsUtil:createById(goodId,nil,pos)
                cc.Director:getInstance():getRunningScene():addChild(temp,1000)
            end
        end

        local goodsSprSize=goodsSpr:getContentSize()
        local goodsCnf=_G.Cfg.goods[_goodsId]
        if goodsCnf~=nil then
            local iconBtn=_G.ImageAsyncManager:createGoodsBtn(goodsCnf,goodsTips,_goodsId)
            iconBtn:setPosition(goodsSprSize.width*0.5,goodsSprSize.height*0.5)
            goodsSpr:addChild(iconBtn)
        else
            local goodsLabel=_G.Util:createBorderLabel(_goodsId,18)
            goodsLabel:setPosition(goodsSprSize.width*0.5,goodsSprSize.height*0.5)
            goodsSpr:addChild(goodsLabel)
        end

        print( "  goods ====>> ", _goodsId )
        local node = nil
        if _goodsId == 46000 then
            local goldUp = self.m_overdata.gold_d/10000+1
            print( "goldUp =======>>>>>>", goldUp )
            if goldUp ~= nil and goldUp > 1 then
                node     = self : createUPNum( goldUp )
                goodsSpr : addChild( node )

            end
        end

        if _goodsId == 46700 then
            local expUp = self.m_overdata.exp_d/10000+1
            print( "expUp =======>>>>>>", expUp )
            if expUp ~= nil and expUp > 1 then
                node     = self : createUPNum( expUp )
                goodsSpr : addChild( node )
            end
        end

        if node ~= nil then
            local function initSpr( )
                node : setScale( 10 )
                node : setPosition( 0, 100 )
                node : setVisible( false )
            end
            local function visSpr( )
                node : setVisible( true )
            end
            local function pVoice( )
                _G.Util:playAudioEffect("balance_firstsuccess")
            end
            node : runAction( cc.Sequence:create( 
                                            cc.DelayTime:create(1),
                                            cc.CallFunc:create(initSpr),
                                            cc.DelayTime:create(0.7),
                                            cc.Spawn:create(
                                                        cc.CallFunc:create(visSpr),
                                                        cc.ScaleTo:create(0.15,1),
                                                        cc.MoveTo:create(0.1,cc.p(0,0))
                                                           ),
                                            cc.CallFunc:create(pVoice),
                                            cc.ScaleTo:create(0.1,1.05),
                                            cc.ScaleTo:create(0.1,0.95),
                                            cc.ScaleTo:create(0.1,1)
                                                )                  
                            )
        end

        local szCount=_goodsCount>10000 and math.modf(_goodsCount*0.0001).._G.Lang.LAB_N[55] or tostring(_goodsCount)
        local countLabel=_G.Util:createBorderLabel(szCount,18)
        countLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        countLabel:setAnchorPoint(cc.p(1,0))
        countLabel:setPosition(goodsSprSize.width-10,3)
        goodsSpr:addChild(countLabel)

        if self.m_isGoodsDraw then
            local szName=goodsCnf and goodsCnf.name or _goodsId
            local nameLabel=_G.Util:createBorderLabel(szName,18)
            nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
            nameLabel:setAnchorPoint(cc.p(0.5,1))
            nameLabel:setPosition(goodsSprSize.width*0.5,-17+10)
            goodsSpr:addChild(nameLabel)
        end
    end
    return goodsSpr
end

function UICopyPass.showTimes(self,_isWaitDraw,_nFun)
    self:removeSchedule()

    local nPosY=-222-45
    local nPosX,autoTimes,szTimes,nColor,arPoint
    if _isWaitDraw then
        nPosX=0
        autoTimes=10
        szTimes=string.format("点击空白区域开始翻牌,%d秒后自动开始",autoTimes)
        nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
        arPoint=cc.p(0.5,0.5)
    else
        nPosX=-65
        autoTimes=_G.Const.CONST_COPY_DRAW_TIME
        szTimes=tostring(autoTimes)
        nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
        arPoint=cc.p(1,0.5)
    end

    self.m_timesLabel=_G.Util:createLabel(szTimes,20)
    self.m_timesLabel:setColor(nColor)
    self.m_timesLabel:setAnchorPoint(arPoint)
    self.m_timesLabel:setPosition(nPosX,nPosY)
    self.m_mainNode:addChild(self.m_timesLabel)

    if not _isWaitDraw then
        _szNotic="秒后副本自动关闭"
        local infoLabel=_G.Util:createLabel(_szNotic,20)
        infoLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        infoLabel:setAnchorPoint(cc.p(0,0.5))
        infoLabel:setPosition(nPosX,nPosY)
        self.m_mainNode:addChild(infoLabel)
    end

    local function schedulerCallFunc()
        autoTimes=autoTimes-1
        if autoTimes<0 then
            self:removeSchedule()
            if _isWaitDraw and _nFun and type(_nFun)=="function" then
                _nFun()
                if self.m_winTouch~=nil then
                    self.m_winTouch:removeFromParent(true)
                    self.m_winTouch=nil
                end
            else
                self:closeWindow()
            end
            return
        end

        local szTimes
        if _isWaitDraw then
            szTimes=string.format("点击空白区域开始翻牌,%d秒后自动开始",autoTimes)
        else
            szTimes=string.format("%.2d",autoTimes)
        end
        self.m_timesLabel:setString(szTimes)
    end

    self.schdedulerHandle=_G.Scheduler:schedule(schedulerCallFunc,1)
end



UICopyPassMediator=classGc(mediator,function(self,_view)
    self.name = "UICopyPassMediator"
    self.view = _view
    self:regSelf()
end)
UICopyPassMediator.protocolsList={
    _G.Msg.ACK_COPY_DRAW_REPLY,-- 7990   通关翻牌返回
    _G.Msg.ACK_COPY_DRAW_TEAM_REPLY,-- 7998 翻牌组队返回
    _G.Msg.ACK_TEAM_BUY_INFO,-- 3835    购买次数信息
}
UICopyPassMediator.commandsList=nil
function UICopyPassMediator.ACK_COPY_DRAW_REPLY(self,_ackMsg)
    for k,v in pairs(_ackMsg.msg_draw_xxx) do
        print("ACK_COPY_DRAW_REPLY, "..k,v)
    end
    self.view:talkGoodsBack(_ackMsg)
end

function UICopyPassMediator.ACK_COPY_DRAW_TEAM_REPLY(self)
    self.view.m_times = 1
    self.view:m_showCardBackFun()
    if self.view.m_winTouch ~= nil then
        self.view.m_winTouch:removeFromParent(true)
        self.view.m_winTouch = nil
    end
end

function UICopyPassMediator.ACK_TEAM_BUY_INFO(self,_ackMsg)
    -- self.view.m_times = 1
    -- self.view:m_showCardBackFun()
    -- if self.view.m_winTouch ~= nil then
    --     self.view.m_winTouch:removeFromParent(true)
    --     self.view.m_winTouch = nil
    -- end

    local function onCallBack()
        self.view.m_showed = true
        local msg=REQ_COPY_DRAW_READY()
        msg:setArgs(1)
        _G.Network:send(msg)
    end
    -- _G.Util:showTipsBox("次数不足",onCallBack)

    local topLab    = "今日奖励次数已用完，"
    local centerLab = "花费"..tostring(_ackMsg.rmb).."元宝购买1次奖励次数?"
    local tipsLab   = _G.Lang.LAB_N[940]
    local downLab   = _G.Lang.LAB_N[416]..": ".._ackMsg.times

    local szSureBtn = _G.Lang.BTN_N[1]

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",onCallBack)
    -- layer     : setPosition(cc.p(self.view.m_winSize.width/2,self.view.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("购买次数")
    if topLab ~= nil then
        local label =_G.Util : createLabel(topLab,20)
        label     : setPosition(cc.p(0,55))
        layer     : addChild(label,88)
    end
    if centerLab ~= nil then
        local label =_G.Util : createLabel(centerLab,20)
        label     : setPosition(cc.p(0,30))
        layer     : addChild(label,88)
    end
    if tipsLab ~= nil then
        local label =_G.Util : createLabel(tipsLab,20)
        label     : setPosition(cc.p(0,0))
        layer     : addChild(label,88)
    end
    if downLab ~= nil then
        local labeldown =_G.Util : createLabel(downLab,20)
        labeldown : setPosition(cc.p(-10,-35))
        layer     : addChild(labeldown,88)
    end
    if szSureBtn ~= nil then
      view : setSureBtnText(szSureBtn)
    end


end

return UICopyPass


