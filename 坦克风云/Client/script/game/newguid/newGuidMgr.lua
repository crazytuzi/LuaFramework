newGuidMgr={
    curStep=1, --当前小步
    curTask=1, --当前大步
    bgLayer, --透明背景层
    bgLayer1, --透明背景层
    panle, --对话框
    arrow, --箭头
    guidLabel, --引导文字
    isGuiding=false,
    selectSp, --选中框
    closeBtn,
    dArrowSp, --倒三角箭头
    isTextGoing=false,--新手引导文字是否动画
    fastTickNum=0,
    showFlag=false, --教学是否已经显示的标记
    startIdx=0, --新手教学第一步镜头索引
}

function newGuidMgr:setCurTask(cTask) 
    --self.curTask=cTask
    local taskStepTb={-4,1,4,10,19,23,26,30,36,55}
    ---  1,2,7,14,22,25,28,32,38,45
    if cTask==0 then
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setHide()
            elseif sceneController.curIndex==1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex==2 then
                worldScene:setHide()
            end
            mainUI:setHide()
        
        end
    end
    self:setCurStep(taskStepTb[cTask+1])
    self:showGuid()
end

function newGuidMgr:setCurStep(cStep)
    self.curStep=cStep
    if self.curStep>19 and self.curStep<=30 then
        mainUI:changeToMainLand()
    elseif self.curStep>30 then
        mainUI:changeToMyPort()
    end
end

--设置教学步骤的某些字段的数值
--pullFlag：--引导元素所在板子是否有向上拉取的动作，有的话引导元素最终在屏幕中显示的位置与初始化时的位置相差一个屏幕高度
function newGuidMgr:setGuideStepField(step,guideSp,pullFlag,otherSpTb,params)
    if newGuidCfg[step] then
        local clickRect=nil
        if params then
            if params.panlePos then
                newGuidCfg[step].panlePos=params.panlePos
            end
        end
        if params and params.clickRect then
            clickRect=params.clickRect
        else
            local offestY=0
            if pullFlag and pullFlag==true then
                offestY=G_VisibleSizeHeight
            end
            if guideSp then
                local x,y,width,height=G_getSpriteWorldPosAndSize(guideSp,1)
                y=y+offestY
                local scale=newGuidCfg[step].scale or 1
                clickRect=CCRectMake(x-(scale-1)*width*0.5,y-(scale-1)*height*0.5,width*scale,height*scale)
            end
        end
        newGuidCfg[step].clickRect=clickRect
        if clickRect then
            if newGuidCfg[step].panelOffsetY then
                newGuidCfg[step].panlePos=ccp(10,clickRect:getMinY()+newGuidCfg[step].panelOffsetY)
            end
            -- print("newstep"..step..".clickRect=".."{"..clickRect:getMinX()..","..clickRect:getMinY()..","..clickRect.size.width..","..clickRect.size.height.."}")
        end
        if otherSpTb then
            -- print("newstep"..step..".otherRectTb===>")
            local otherRectTb=newGuidCfg[step].otherRectTb or {}
            local otherSp,idx=otherSpTb[1],otherSpTb[2]
            if otherRectTb[idx]==nil and otherSp and idx then
               local x,y,width,height=G_getSpriteWorldPosAndSize(otherSp)
                y=y+offestY
                otherRectTb[idx]={x,y,width,height}
                -- print("{"..x..","..y..","..width..","..height.."}")
            end
            newGuidCfg[step].otherRectTb=otherRectTb
        end
    end
end

function newGuidMgr:showGuid()
    if G_isApplyVersion()==true then
        if self.curStep~=55 then
            self:removeGuideLayer()
            do return end
        end
    end
    self.isGuiding=true
    base:addNeedRefresh(self)

    self:hidingGuild() --先隐藏之前的教学页面

    if self.curStep<0 then
        self.curStep=self.curStep+53
    end
    -- print("self.curStep=",self.curStep)
    local guideItem=nil
    if self.curStep==1 or self.curStep==4 or self.curStep==20 or self.curStep==23 or self.curStep==26 then
        local buildObj
        if self.curStep==1 or self.curStep==4 then
            buildObj=buildings.allBuildings[11]
        elseif self.curStep==20 then
            buildObj=buildings.allBuildings[20]
        elseif self.curStep==23 then
            buildObj=buildings.allBuildings[19]
        elseif self.curStep==26 then
            buildObj=buildings.allBuildings[18]
        end
        if buildObj and buildObj.buildSp then
            guideItem=buildObj.buildSp
        end
    elseif self.curStep==30 then
        if mainLandScene and mainLandScene.portSp then
            guideItem=mainLandScene.portSp
            if mainLandScene.actionUseInNewGuildMgr then
                mainLandScene:actionUseInNewGuildMgr( )
            end
        end
    elseif self.curStep==31 then
        if mainUI and mainUI.m_taskSp then
            guideItem=mainUI.m_taskSp
        end
    elseif self.curStep==10 then --关卡引导
        if mainUI and mainUI.m_functionBtnTb then
            guideItem = mainUI.m_functionBtnTb["b1"]
        end
    elseif self.curStep==19 then --资源建筑建造引导
        if mainUI and mainUI.m_menuToggle then
            guideItem = mainUI.m_menuToggle
        end
    elseif self.curStep==36 then --指挥官详情页面引导
        if mainUI and mainUI.mySpriteLeft then
            guideItem = tolua.cast(mainUI.mySpriteLeft:getChildByTag(767),"CCSprite") --玩家头像作为引导元素
        end
    elseif self.curStep==43 then --查看资源信息引导
        if mainUI and mainUI.mySpriteRight then
            guideItem = tolua.cast(mainUI.mySpriteRight,"CCMenuItemSprite")
        end
    end
    if guideItem then
        self:setGuideStepField(self.curStep,guideItem)
    end
    local guidCfg=newGuidCfg[self.curStep]

    if self.curStep==31 then
        -- if base.dailyAcYouhuaSwitch==1 then
        --     if G_isIphone5() then
        --         guidCfg.clickRect=CCRectMake(0,670+85,80,90)
        --         guidCfg.arrowPos=ccp(140,720+70)
        --     else
        --         guidCfg.clickRect=CCRectMake(0,493+85,80,90)
        --         guidCfg.arrowPos=ccp(140,540+70)
        --     end
        -- else
        --     if G_isIphone5() then
        --         guidCfg.clickRect=CCRectMake(0,670,80,90)
        --         guidCfg.arrowPos=ccp(140,720)
        --     else
        --         guidCfg.clickRect=CCRectMake(0,493,80,90)
        --         guidCfg.arrowPos=ccp(140,540)
        --     end
        -- end
    end
    
    local startSpTb={}
    
    local function tmpFunc()
        -- print("self.curStep",self.curStep,"clickToNext=",newGuidCfg[self.curStep].clickToNext)
        if newGuidCfg[self.curStep].clickToNext==true then --点击屏幕跳入下一步
            self:hidingGuild()

            PlayEffect(audioCfg.mouseClick)
            if self.curStep==49 then
                if self.startIdx==1 then
                    self:playSecondCamera()
                    do return end
                elseif self.startIdx==2 then
                    if self.bgLayer1~=nil then
                        for k,v in pairs(startSpTb) do
                            v:removeFromParentAndCleanup(true)
                        end
                        self.bgLayer1:removeFromParentAndCleanup(true)
                        self.bgLayer1=nil
                        self.tlabel=nil
                        self.tlabel2=nil
                        self.startSpTb={}
                    end
                end
            end
            self:toNextStep()
        else
            if self.showFlag==true then
                self:playCircleEffect()
            end
        end
    end
    if self.bgLayer==nil then
        self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
        if self.curStep==49 then --引导录像
            
            self.bgLayer1=CCLayer:create()
            self.bgLayer:addChild(self.bgLayer1)
            
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)  
            local imgStr1 = "scene/newguid_1.png"
            local imgStr2 = "scene/newguid_2.png"
            local adaH = 0
            if G_getIphoneType() == G_iphoneX then
                imgStr1 = "scene/newguid_1X.png"
                imgStr2 = "scene/newguid_2X.png"
                --28根据美工给出图片尺寸算的极限距离
                adaH = 28
            end
            local sp1=CCSprite:create(imgStr1);
            sp1:setAnchorPoint(ccp(0.5,0))
            sp1:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2-94-adaH))
            self.bgLayer1:addChild(sp1,20)

            local sp2=CCSprite:create(imgStr2);
            sp2:setAnchorPoint(ccp(0.5,1))
            sp2:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2+94-adaH))
            self.bgLayer1:addChild(sp2,20)
    
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

            sp2:setColor(ccc3(50,50,50))
    
            startSpTb[1]=sp1;
            startSpTb[2]=sp2;

            local tlabel=GetTTFLabelWrap(getlocal("guide_tip_49_new"),30,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tlabel:setAnchorPoint(ccp(0.5,0.5))
            tlabel:setPosition(sp1:getContentSize().width/2,sp1:getContentSize().height/2+120)
            tlabel:setColor(ccc3(66,85,26))
            sp1:addChild(tlabel)
            
            local tlabel2=GetTTFLabelWrap(getlocal("guide_tip_49_1_new"),30,CCSize(G_VisibleSize.width-60,150),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tlabel2:setAnchorPoint(ccp(0.5,0.5))
            tlabel2:setPosition(sp2:getContentSize().width/2-20,sp2:getContentSize().height/2-140)
            sp2:addChild(tlabel2)
            tlabel2:setOpacity(0)
            self.tlabel=tlabel
            self.tlabel2=tlabel2
            self.startSpTb=startSpTb


            local fadeIn=CCFadeIn:create(1.6)
            tlabel:setOpacity(0)
            local delay=CCDelayTime:create(2)
            local fadeOut=CCFadeOut:create(1)
            local function playBackBgEnd()
                local fadeOut2=CCTintTo:create(0.5,80,80,80)
                sp1:runAction(fadeOut2)

                self:playSecondCamera()
            end
            local callFunc=CCCallFuncN:create(playBackBgEnd)
            local acArr=CCArray:create()
            acArr:addObject(fadeIn)
            acArr:addObject(delay)
            acArr:addObject(fadeOut)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            tlabel:runAction(seq)

            self.startIdx=1
            --[[
            local tlabel=GetTTFLabelWrap(getlocal("guide_tip_"..self.curStep),40,CCSize(G_VisibleSize.width-60,150),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tlabel:setAnchorPoint(ccp(0.5,0.5))
            tlabel:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)
            self.bgLayer:addChild(tlabel)
            
            local fadeIn=CCFadeIn:create(2)
            tlabel:setOpacity(0)
            local delay=CCDelayTime:create(1)
            local fadeOut=CCFadeOut:create(1)
            local function playBackBgEnd()

            end
            local callFunc=CCCallFuncN:create(playBackBgEnd)
            local acArr=CCArray:create()
            acArr:addObject(fadeIn)
            acArr:addObject(delay)
            acArr:addObject(fadeOut)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            tlabel:runAction(seq)
            ]]
        else
            --self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,2,2),tmpFunc)
        end
        self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.bgLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.bgLayer:setTouchPriority(-320)
        if self.curStep~=49 then
            self.bgLayer:setOpacity(0) --透明
        end
        self.bgLayer:setOpacity(0)
        sceneGame:addChild(self.bgLayer,8) --背景透明遮挡层，第7层
    end
    if guidCfg.clickRect~=nil then
        --self.bgLayer:setNoSallowArea(guidCfg.clickRect)
    else
        self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
    end
    --[[
    if self.selectSp~=nil then
         self.selectSp:removeFromParentAndCleanup(true)
         self.selectSp=nil
    end
    ]]
    
    if guidCfg.hasPanle==true then --新手引导面板
        self:showPanle()
        self.panle=tolua.cast(self.panle,"CCNode")
        self.panle:setVisible(true)
    else
        if self.panle~=nil then
            self.panle=tolua.cast(self.panle,"CCNode")
            self.panle:setVisible(false)
        end
        if self.arrow~=nil then
            self.arrow=tolua.cast(self.arrow,"CCNode")
            self.arrow:setVisible(false)
        end

        local function realShow()
            -- self:showArrowSp() --显示引导箭头
            if guidCfg.clickRect==nil then
                if self.curStep==15 or self.curStep==49 or self.curStep==50 or self.curStep==51 or self.curStep==52 or self.curStep==53 or self.curStep==54 or self.curStep==55 then
                else
                    self.bgLayer:setOpacity(125)
                end
            else
                self.bgLayer:setOpacity(0)
                self:showSelectSp() --显示引导选择框
            end
        end
        local delay=CCDelayTime:create(guidCfg.delayTime==nil and 0.4 or guidCfg.delayTime)
        local ffunc=CCCallFuncN:create(realShow)
        local fseq=CCSequence:createWithTwoActions(delay,ffunc)
        self.bgLayer:runAction(fseq)
    end
    
    if self.curStep==55 and playerVoApi:getTutorial()==9 then
        if self.bgLayer~=nil then
            self.bgLayer:removeFromParentAndCleanup(true)
            self.bgLayer=nil
        end
        if platCfg.platBeimeiNewGuide[G_curPlatName()]~=nil then
            mainUI:showCreateNewRoleKunlun()
        else
            mainUI:showCreateNewRole()
        end

    end

end

function newGuidMgr:playSecondCamera()
    if self.tlabel and self.tlabel2 then
        if self.startSpTb[2] then
            local fadeOut1=CCTintTo:create(0.5,255,255,255)
            self.startSpTb[2]:runAction(fadeOut1)
        end
        local fadeIn=CCFadeIn:create(0)
        self.tlabel:setOpacity(0)
        local delay=CCDelayTime:create(2)
        local fadeOut=CCFadeOut:create(1)
        local scaleTO1=CCScaleTo:create(0.2,1.3)
        local scaleTO2=CCScaleTo:create(0.2,1)
        local scaleTO3=CCScaleTo:create(0.2,1.3)
        local scaleTO4=CCScaleTo:create(0.2,1)
        local function playBackBgEnd()
            self.startIdx=3
            self.bgLayer1:removeFromParentAndCleanup(true)
            self.bgLayer1=nil
            self.tlabel=nil
            self.tlabel2=nil
            self.startSpTb={}
            self:toNextStep()
        end
        local callFunc=CCCallFuncN:create(playBackBgEnd)
        local acArr=CCArray:create()
        acArr:addObject(fadeIn)
        acArr:addObject(scaleTO1)
        acArr:addObject(scaleTO2)
        acArr:addObject(scaleTO3)
        acArr:addObject(scaleTO4)
        acArr:addObject(delay)
        --acArr:addObject(fadeOut)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        self.tlabel2:runAction(seq)
        self.startIdx=2
    end    
end

function newGuidMgr:toNextStep(nextId)
    if self.bgLayer~=nil then
        self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
    end
    print("zhiqian=",self.curStep)
    if platCfg.platBeimeiNewGuide[G_curPlatName()]~=nil then

        if newGuidCfg[self.curStep].toStepId==23 then
            self.curStep=30
        elseif newGuidCfg[self.curStep].toStepId==43 then
            self.curStep=48
        else
            self.curStep=newGuidCfg[self.curStep].toStepId
        end
        
    else
        self.curStep=newGuidCfg[self.curStep].toStepId --self.curStep+1
        
    end


    if nextId~=nil then
        self.curStep=nextId
    end
    if G_isApplyVersion()==true then
        if self.curStep~=49 then
            self:removeGuideLayer()
            do return end
        end
    end
    if self.curStep>54 and playerVoApi:getTutorial()~=9 then
        if portScene.clayer~=nil then
                    if sceneController.curIndex==0 then
                        portScene:setShow()
                    elseif sceneController.curIndex==1 then
                        mainLandScene:setShow()
                    elseif sceneController.curIndex==2 then
                        worldScene:setShow()
                    end
                    mainUI:setShow()
                end

        BossBattleScene:close()
        self.curStep=1
    end
    -- print("self.curStep===-->>>",self.curStep)
    if self.curStep==50 then
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/man.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/woman.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/framebtn.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_1.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_2.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_1X.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_2X.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/man_3.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/woman_3.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/man_2.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/woman_2.png")
     ----
        
        spriteController:addPlist("ship/t99999Image.plist")
        require "luascript/script/game/gamemodel/Boss/BossBattleVoApi"
        require "luascript/script/game/gamemodel/Boss/BossBattleVo"
        require "luascript/script/game/scene/gamedialog/Boss/BossBattleScene"
        -- local t1={[1]={"t10025",5},[2]={"t10035",5},[3]={"t10015",5},[4]={"t10005",5},[5]={"t10034",5},[6]={"t10033",5}}
        -- local t2={[1]={"t10003",5},[2]={"t10033",5},[3]={"t10023",5},[4]={"t10013",5},[5]={"t10033",5},[6]={"t10003",5}}

        -- local data={data={report={p={{getlocal("mysticalFleet"),15,1},{playerVoApi:getPlayerName(),1,1}},d={{"3450-1","6900-0-1"},{"105-5","210-5-1","105-5"},{"1650-0","3300-0-1","1650-0","3300-1-1","1650-1"}},t={t1,t2}}}}

        local t1={{"a99999",1},{},{},{},{},{}}
        local t2={[1]={"a10003",50},[2]={"a10033",50},[3]={"a10084",120},[4]={"a20125",120},[5]={"a20155",120},[6]={"a10145",120}}

        local data ={data={report={p={{},{playerVoApi:getPlayerName(),1,1}},d={{"1976-1","1976-1","1976-1"},{"3482-1","3482-1","3482-1","3482-1","6964-1-1","3482-1"}},t={t1,t2}},worldboss={binfo={t={[1]={"a10003",50},[2]={"a10033",50},[3]={"a10084",120},[4]={"a20125",120},[5]={"a20155",120},[6]={"a10145",120}}},attack_at=1476190977,point=1373925,info={boss={20,583600000}},reward_at=0,buy_at=1476115200,auto = 0,boss={20,583600000,1373925,5,583600000}}}}

        local worldboss = {binfo={t={[1]={"a10003",50},[2]={"a10033",50},[3]={"a10084",120},[4]={"a20125",120},[5]={"a20155",120},[6]={"a10145",120}}},attack_at=1476190977,point=1373925,info={boss={20,583600000}},reward_at=0,buy_at=1476115200,auto = 0,boss={20,583600000,1373925,5,583600000}}

        BossBattleVoApi:onRefreshData(worldboss)
        BossBattleScene.battlePaused=true
        BossBattleScene:initData(data)
        PlayEffect(audioCfg.attack_alert)
    end
    if self.curStep==49 then
        statisticsHelper:tutorial(55,self.curStep)
        self:endNewGuid()
        local tmpTb={}
        tmpTb["action"]="newPlayerGuidEnd"
        local cjson=G_Json.encode(tmpTb)
        content=G_accessCPlusFunction(cjson)
        do
            return
        end
    end
    if self.curStep == 53 then
        BossBattleScene.battlePaused = true
    end
    if self.curStep==52 then
        BossBattleScene.battlePaused=false
    end
    if self.curStep ==54 then
         -- print("here??????")
        BossBattleScene:standByArmyInNewGuid( )
    end

    local cStep=self.curStep
    if cStep>=50 then
        cStep=cStep-50+1
    else
        cStep=cStep+5
    end
    statisticsHelper:tutorial(cStep,cStep-1)
    if self.curStep==50 then
        local function callBackToShowGuid( )
           self:showGuid()------ 
        end 
        local actionTb = {}
        actionTb["showGuid"] ={nil,self.bgLayer,nil,nil,nil,4.5,nil,nil,callBackToShowGuid }
        G_RunActionCombo(actionTb)
    else
        self:showGuid()------
    end
end
function newGuidMgr:showPanle()
    
    local guidCfg=newGuidCfg[self.curStep]
    if self.panle==nil then
        self.panle=CCNode:create()
        if(G_curPlatName()=="5" or G_curPlatName()=="58")then
            self.gn=CCSprite:create("flBaiduImage/GuideCharacter_fl.png")
        elseif platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            self.gn=CCSprite:create("public/guide.png") --姑娘
        else
            self.gn=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png") --姑娘
        end
        self.gn:setAnchorPoint(ccp(0,0))
        self.gn:setPosition(ccp(30,115))
        self.panle:addChild(self.gn)

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)

        end
        self.headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuideNewPanel.png",capInSet,cellClick)--对话背景GuidePanel
        self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
        self.headerSprie:ignoreAnchorPointForPosition(false);
        self.headerSprie:setAnchorPoint(ccp(0,0));
        self.headerSprie:setTouchPriority(0)
        --headerSprie:setPosition(ccp(0,cell:getContentSize().height-self.headerSprie:getContentSize().height));
        self.panle:addChild(self.headerSprie)
        self.guidLabel=GetTTFLabelWrap("",25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.guidLabel:setAnchorPoint(ccp(0,0.5))
        self.guidLabel:setPosition(ccp(20,self.headerSprie:getContentSize().height/2))
        self.headerSprie:addChild(self.guidLabel) --添加文本框
        --if guidCfg.hasCloseBtn==true then --面板上的关闭按钮
        local function closeBtnHandler()
            --退出新手引导操作
            guidCfg=newGuidCfg[self.curStep]
            if guidCfg.hasCloseBtn~=true then
                do
                    return
                end
            end
            local function callBack()
                local function skipServerHandler(fn,data)
                    --local retTb=OBJDEF:decode(data)
                    if base:checkServerData(data)==true then
                        portScene:setShow()
                        self.curStep=55
                        playerVoApi:setTutorial(9)
                        self:showGuid()
                        statisticsHelper:tutorial(55,self.curStep)
                        --self:endNewGuid()
                    end
                end
                socketHelper:skipNewGuid(skipServerHandler)
            end
            PlayEffect(audioCfg.mouseClick)   
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("guide_skip_prompt"),nil,100)
        end

        if platCfg.platBeimeiNewGuide[G_curPlatName()]~=nil then
            local cancelItem=GetButtonItem("kunlunGuideClose.png","kunlunGuideClose.png","kunlunGuideClose.png",closeBtnHandler,2,getlocal("skipPlay"),22)
            self.closeBtn=CCMenu:createWithItem(cancelItem);
            self.closeBtn:setPosition(self.headerSprie:getContentSize().width-cancelItem:getContentSize().width/2,self.headerSprie:getContentSize().height+cancelItem:getContentSize().height/2-6)
            self.closeBtn:setTouchPriority(-322);
            self.headerSprie:addChild(self.closeBtn)
        else
            self.closeBtn= LuaCCSprite:createWithSpriteFrameName("GuideNewClose.png",closeBtnHandler)--GuideClose
            self.closeBtn:setPosition(self.headerSprie:getContentSize().width-self.closeBtn:getContentSize().width/2,self.headerSprie:getContentSize().height+self.closeBtn:getContentSize().height/2-3)
            self.closeBtn:setTouchPriority(-322)

            self.headerSprie:addChild(self.closeBtn)
        end       
        local rect=CCSizeMake(80,80)
        self.bigCloseBtn=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),closeBtnHandler)
        self.bigCloseBtn:setTouchPriority(-321)
        self.bigCloseBtn:setContentSize(rect)
        self.bigCloseBtn:setOpacity(0)
        self.bigCloseBtn:setPosition(self.closeBtn:getPosition())
        self.headerSprie:addChild(self.bigCloseBtn)

        --end
         
        ----以下面板上的倒三角----
        self.dArrowSp=CCSprite:createWithSpriteFrameName("DownArow1.png")
        local  spcArr=CCArray:create()
                   
        for kk=1,12 do
            local nameStr="DownArow"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            spcArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(spcArr)
        animation:setRestoreOriginalFrame(true);
        animation:setDelayPerUnit(0.08)
        local animate=CCAnimate:create(animation)
        local repeatForever=CCRepeatForever:create(animate)
        self.dArrowSp:runAction(repeatForever)
        self.dArrowSp:setAnchorPoint(ccp(1,0))
        self.dArrowSp:setPosition(ccp(self.headerSprie:getContentSize().width,2))
        self.panle:addChild(self.dArrowSp)
         ----以上面板上的倒三角----
        self.bgLayer:addChild(self.panle,10)
    end
    if self.dArrowSp~=nil then
        self.dArrowSp=tolua.cast(self.dArrowSp,"CCNode")
        self.dArrowSp:setVisible(false)
    end
    --[[
    if self.arrow~=nil then
        self.arrow:removeFromParentAndCleanup(true)
        self.arrow=nil
    end
    ]]
    if self.arrow==nil then --箭头
        self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
        self.arrow:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(self.arrow)
    end
    if self.arrow~=nil then --箭头
        self.arrow:setPosition(guidCfg.arrowPos)
    end

    if guidCfg.hasCloseBtn==true then --面板上的关闭按钮
        self.closeBtn:setVisible(true)
        self.bigCloseBtn:setVisible(true)
         --self.closeBtn:setTouchPriority(-321)
    else
        self.closeBtn:setVisible(false)
        self.bigCloseBtn:setVisible(false)
         --self.closeBtn:setTouchPriority()
    end
    --self.isTextGoing=true
    --if platCfg.platBeimeiNewGuide[G_curPlatName()]==nil then
        self.guidLabel:setString(getlocal("guide_tip_"..self.curStep))
    --end
    self.panle:setPosition(guidCfg.panlePos)

    self.panle:stopAllActions()
    
    if self.headerSprie~=nil then
        self.headerSprie:stopAllActions()
        self.headerSprie:setOpacity(0)
    end
    
    if self.gn~=nil then
         self.gn:stopAllActions()
        self.gn:setOpacity(0)
    end

    if self.arrow~=nil then
        self.arrow:stopAllActions()
        self.arrow:setOpacity(0)
    end
    if self.guidLabel~=nil then
        self.guidLabel:stopAllActions()
        -- if platCfg.platBeimeiNewGuide[G_curPlatName()]~=nil then
        --    self.guidLabel:setString("")
        -- end
        self.guidLabel:setOpacity(0)
        self.isTextGoing=false
        if guidCfg.showGirl~=nil and guidCfg.showGirl==false then
            self.gn=tolua.cast(self.gn,"CCNode")
            self.gn:setVisible(false)
        else
            self.gn=tolua.cast(self.gn,"CCNode")
            self.gn:setVisible(true)
        end
        
        if guidCfg.clickRect==nil then
            self.arrow=tolua.cast(self.arrow,"CCNode")
            self.arrow:setVisible(false)
        else
            self.arrow=tolua.cast(self.arrow,"CCNode")
            self.arrow:setVisible(true)
        end
    end
    
    if self.selectSp~=nil then
        self.selectSp:stopAllActions()
        self.selectSp:setOpacity(0)

        self.selectSp:stopAllActions()
        self.selectSp:setOpacity(0)
    end

    if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
        self.closeBtn:stopAllActions()
        self.closeBtn:setOpacity(0)
    end
    

    local function showP()
        if self.headerSprie~=nil then
            self.headerSprie:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.headerSprie:setOpacity(0)
            self.headerSprie:runAction(fadeIn)
            
        end
        
        if self.gn~=nil then
            self.gn:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.gn:setOpacity(0)
            self.gn:runAction(fadeIn)
        end
        
        --[[
        if self.dArrowSp~=nil and guidCfg.clickToNext==true then
            --local fadeIn=CCFadeIn:create(0.3)
            --self.dArrowSp:setOpacity(0)
            --self.dArrowSp:runAction(fadeIn)
            self.dArrowSp:setVisible(true)
        end
        if guidCfg.clickToNext==false then
            self.dArrowSp:setVisible(false)
        else
            self.dArrowSp:setVisible(true)
        end
        ]]
        
        if self.dArrowSp~=nil then
            if guidCfg.clickToNext==true then
                self.dArrowSp:setVisible(true)
            else
                self.dArrowSp:setVisible(false)
            end
        end
           
        -- self:showArrowSp() --显示箭头指示动画
        -- self:showSelectSp() --显示选择框

        if self.guidLabel~=nil then
            self.guidLabel:stopAllActions()
            local function callBack()
                self.isTextGoing=true
            end
            local fadeIn=CCFadeIn:create(0.3)
            local  ffunc=CCCallFuncN:create(callBack)
            local seq=CCSequence:createWithTwoActions(fadeIn,ffunc)
            self.guidLabel:setOpacity(0)
            self.guidLabel:runAction(seq)
        end

        if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
            self.closeBtn:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.closeBtn:setOpacity(0)
            self.closeBtn:runAction(fadeIn)
        end
        if guidCfg.clickRect~=nil then
            self.bgLayer:setNoSallowArea(guidCfg.clickRect)
        end
    end
    local function realShow()
        if guidCfg.clickRect==nil then
            if self.curStep==15 or self.curStep==49 or self.curStep==50 or self.curStep==51 or self.curStep==52 or self.curStep==53 or self.curStep==54 or self.curStep==55 then
            else
                self.bgLayer:setOpacity(125)
            end
            showP()
        else
            self.bgLayer:setOpacity(0)
            self:showSelectSp(showP)
        end
    end
    local delay=CCDelayTime:create(guidCfg.delayTime==nil and 0.4 or guidCfg.delayTime)
    local ffunc=CCCallFuncN:create(realShow)
    local fseq=CCSequence:createWithTwoActions(delay,ffunc)
    self.panle:runAction(fseq)
end

function newGuidMgr:showSelectSp(callBack)
    if self.bgLayer==nil then
        do return end
    end
    self:displayGuild()
    guidCfg=newGuidCfg[self.curStep]
    if self.selectSp==nil then
        local function clickAreaHandler()
        end
        self.selectSp=LuaCCSprite:createWithSpriteFrameName("guildExternal.png",clickAreaHandler)
        local scale=self:getSelectSpScale()
        self.selectSp:setScale(scale)
        self.selectSp:setAnchorPoint(ccp(0.5,0.5))
        local internalSp=CCSprite:createWithSpriteFrameName("guildInternal.png")
        internalSp:setPosition(getCenterPoint(self.selectSp))
        internalSp:setTag(1001)
        self.selectSp:addChild(internalSp)

        self.selectSp:setTouchPriority(-1)
        self.selectSp:setIsSallow(false)
        self.bgLayer:addChild(self.selectSp,4)
        self.selectSp:setVisible(false)

        --调教学使用
        -- self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
        -- self.halo:setAnchorPoint(ccp(0,0))
        -- self.halo:setTouchPriority(1000)
        -- self.bgLayer:addChild(self.halo)
        -- self.halo:setVisible(false)

        local shadeLayer=CCClippingNode:create() --遮罩层
        shadeLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        shadeLayer:setAnchorPoint(ccp(0.5,0.5))
        shadeLayer:setInverted(true)
        shadeLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)
        shadeLayer:setVisible(false)

        local back=CCLayerColor:create(ccc4(0,0,0,125))
        shadeLayer:addChild(back)
        local circleSp=CCSprite:createWithSpriteFrameName("guidShade.png")
        circleSp:setScale(scale)
        shadeLayer:setStencil(circleSp)
        self.bgLayer:addChild(shadeLayer,3)

        local clipLayer=CCClippingNode:create() --裁切层
        clipLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        clipLayer:setAnchorPoint(ccp(0.5,0.5))
        clipLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)
        clipLayer:setVisible(false)

        local stencil=CCSprite:createWithSpriteFrameName("guidShade.png")
        stencil:setOpacity(0)
        stencil:setScale(scale)
        clipLayer:setStencil(stencil)

        local shadeSp=CCSprite:createWithSpriteFrameName("guidShade_big.png")
        shadeSp:setOpacity(125)
        shadeSp:setScale(scale)
        shadeSp:setPosition(getCenterPoint(clipLayer))
        clipLayer:addChild(shadeSp)

        self.bgLayer:addChild(clipLayer,2)

        self.shadeLayer=shadeLayer
        self.clipLayer=clipLayer
        self.circleSp=circleSp
        self.shadeSp=shadeSp
        self.stencil=stencil
    end     
    if self.selectSp~=nil then
        if guidCfg.clickRect~=nil then --添加点击区域图标
            self.selectSp:setVisible(true)
            if self.shadeLayer then
                self.shadeLayer:setVisible(true)
            end
            if self.clipLayer then
                self.clipLayer:setVisible(true)
            end
            local sx=guidCfg.clickRect:getMinX()+guidCfg.clickRect.size.width/2
            local sy=guidCfg.clickRect:getMinY()+guidCfg.clickRect.size.height/2
            self.selectSp:setPosition(ccp(sx,sy))
            --调教学使用
            -- self.halo:setPosition(guidCfg.clickRect:getMinX(),guidCfg.clickRect:getMinY())
            -- self.halo:setContentSize(CCSizeMake(guidCfg.clickRect.size.width,guidCfg.clickRect.size.height))
            -- self.halo:setVisible(true)
            -- print("haloxy---->>>",self.halo:getPosition())
            if self.circleSp and self.shadeSp and self.stencil then
                local x=self.selectSp:getPositionX()
                local y=self.selectSp:getPositionY()
                self.circleSp:setPosition(x,y)
                self.shadeSp:setPosition(x,y)
                self.stencil:setPosition(x,y)
            end
        else
            if self.shadeLayer then
                self.shadeLayer:setVisible(false)
            end
            if self.clipLayer then
                self.clipLayer:setVisible(false)
            end
            self.selectSp:setVisible(false)
        end
        local function playSelectEffect(target,angle,isScale)
            if target then
                local rotateAc=CCRotateBy:create(2,angle)
                if isScale and isScale==true then
                    local scale=self:getSelectSpScale()
                    local maxScale=1.3*scale
                    local scaleAc1=CCScaleTo:create(0.5,maxScale)
                    local scaleAc2=CCScaleTo:create(0.5,scale)
                    local scaleSeq=CCSequence:createWithTwoActions(scaleAc1,scaleAc2)
                    local effectArr=CCArray:create()
                    effectArr:addObject(rotateAc)
                    effectArr:addObject(scaleSeq)
                    local spawnAc=CCSpawn:create(effectArr)
                    target:runAction(CCRepeatForever:create(scaleSeq))
                    target:runAction(CCRepeatForever:create(rotateAc))
                else
                    target:runAction(CCRepeatForever:create(rotateAc))
                end
            end
        end

        local function realShowSelect()
            self.selectSp:setOpacity(255)
            local internalSp=tolua.cast(self.selectSp:getChildByTag(1001),"CCSprite")
            if internalSp then
                internalSp:setOpacity(255)
                playSelectEffect(internalSp,720)
            end
            playSelectEffect(self.selectSp,-360,true)
            if callBack then
                callBack()
            end
            self.showFlag=true
        end
  
        self:playCircleEffect(realShowSelect)
    end
end

function newGuidMgr:playCircleEffect(callBack)
    local function realPlay(target,callBack)
       if target then
            target:stopAllActions()
            local scale=self:getSelectSpScale()
            local maxScale=1.1*scale
            local beginScale=10*scale
            target:setScale(beginScale)
            local arr=CCArray:create()
            local scaleAc=CCScaleTo:create(0.3,scale)
            arr:addObject(scaleAc)
            local function scaleHandler()
                local scaleAc1=CCScaleTo:create(0.3,maxScale)
                local scaleAc2=CCScaleTo:create(0.3,scale)
                local scaleSeq=CCSequence:createWithTwoActions(scaleAc1,scaleAc2)
                -- target:runAction(CCRepeatForever:create(scaleSeq))
                if callBack then
                    callBack()
                end
            end
            local func=CCCallFuncN:create(scaleHandler)
            arr:addObject(func)
            local scaleSeq=CCSequence:create(arr)
            target:runAction(scaleSeq)
       end
    end
    if self.circleSp then
        realPlay(self.circleSp,callBack)
    end
    if self.shadeSp then
        self.shadeSp:setVisible(true)
        realPlay(self.shadeSp)
    end
    if self.stencil then
        realPlay(self.stencil)
    end
end

function newGuidMgr:showArrowSp()
    if self.bgLayer==nil then
        do return end
    end
    guidCfg=newGuidCfg[self.curStep]
    if self.arrow==nil then --箭头
        self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
        self.arrow:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(self.arrow,2)
    end
    if self.arrow~=nil then
        self.arrow:stopAllActions()
        self.arrow:setVisible(false)
        if guidCfg.arrowDirect==1 then  --下
                guidCfg.arrowPos.y=guidCfg.arrowPos.y-100/2
        elseif guidCfg.arrowDirect==2 then  --上
                guidCfg.arrowPos.y=guidCfg.arrowPos.y+100/2
        elseif guidCfg.arrowDirect==3 then  --右上
                guidCfg.arrowPos.x=guidCfg.arrowPos.x+80/2
                guidCfg.arrowPos.y=guidCfg.arrowPos.y+80/2
        end
        self.arrow:setPosition(guidCfg.arrowPos)
        local function showArrowAction()
            local aimPos
            if guidCfg.arrowDirect==1 then  --下
                aimPos=ccp(guidCfg.arrowPos.x,guidCfg.arrowPos.y-100/2)
                self.arrow:setRotation(0)
            elseif guidCfg.arrowDirect==2 then  --上
                aimPos=ccp(guidCfg.arrowPos.x,guidCfg.arrowPos.y+100/2)
                self.arrow:setRotation(180)
            elseif guidCfg.arrowDirect==3 then  --右上
                aimPos=ccp(guidCfg.arrowPos.x+80/2,guidCfg.arrowPos.y+80/2)
                self.arrow:setRotation(-135)
            elseif guidCfg.arrowDirect==4 then  --从右往左动
                aimPos=ccp(guidCfg.arrowPos.x+50,guidCfg.arrowPos.y)
                self.arrow:setRotation(90)
            end
            if guidCfg.clickRect~=nil then
                self.arrow:setVisible(true)
            end
            local mvTo=CCMoveTo:create(0.35,aimPos)
            local mvBack=CCMoveTo:create(0.35,guidCfg.arrowPos)
            local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
            self.arrow:runAction(CCRepeatForever:create(seq))
        end
        local fadeIn=CCFadeIn:create(0.3)
        self.arrow:setOpacity(0)
        local ffunc=CCCallFuncN:create(showArrowAction)
        local fseq=CCSequence:createWithTwoActions(fadeIn,ffunc)
        self.arrow:runAction(fseq)
    end
end

--隐藏教学页面
function newGuidMgr:hidingGuild()
    if self.selectSp~=nil then
        self.selectSp:setVisible(false)
    end
    if self.circleSp then
        self.circleSp:setVisible(false)
    end
    if self.shadeLayer~=nil then
        self.shadeLayer:setVisible(false)
    end
    if self.clipLayer~=nil then
        self.clipLayer:setVisible(false)
    end
    if self.bgLayer then
        self.bgLayer:setOpacity(0)
    end
    self.showFlag=false
end

function newGuidMgr:displayGuild()
    local scale=self:getSelectSpScale()
    if self.selectSp~=nil then
        self.selectSp:setVisible(true)
        self.selectSp:stopAllActions()
        self.selectSp:setScale(scale)
        self.selectSp:setOpacity(0)
        local internalSp=tolua.cast(self.selectSp:getChildByTag(1001),"CCSprite")
        if internalSp then
            internalSp:stopAllActions()
            internalSp:setScale(1)
            internalSp:setOpacity(0)
        end
    end
    if self.circleSp then
        self.circleSp:setScale(scale)
        self.circleSp:stopAllActions()
        self.circleSp:setVisible(true)
    end
    if self.shadeSp then
        self.shadeSp:setVisible(true)
        self.shadeSp:setScale(scale)
        self.shadeSp:stopAllActions()
    end
    if self.shadeLayer~=nil then
        self.shadeLayer:setVisible(true)
    end
    if self.clipLayer~=nil then
        self.clipLayer:setVisible(true)
    end
    if self.stencil then
        self.stencil:setScale(scale)
        self.stencil:stopAllActions()
        self.stencil:setVisible(true)
    end
end

function newGuidMgr:getSelectSpScale()
    if self.curStep and self.selectSp then
        guidCfg=newGuidCfg[self.curStep]
        if guidCfg and guidCfg.clickRect then
            local width=guidCfg.clickRect.size.width
            local height=guidCfg.clickRect.size.height
            if width<height then
                width=height
            end
            local spW=self.selectSp:getContentSize().width
            local scale=width/spW
            if scale>1.5 then
                scale=1.5
            end
            return scale
        end
    end
    return 1
end

function newGuidMgr:tickShowText()
    local string=getlocal("guide_tip_"..self.curStep)
    if self.strIndex==nil then
      self.strIndex=1
    end
    self.strIndex=self.strIndex+1
    self.guidLabel=tolua.cast(self.guidLabel,"CCLabelTTF")
    if string and string~="" and self.guidLabel and self.guidLabel:getOpacity()~=0 then
      local lenNum=string.len(string)
      if self.strIndex>lenNum then
        self.strIndex=lenNum
      end
      --for i=1,self.strIndex do
        local subStr=string.sub(string,1,self.strIndex)
        --print("subStr",subStr)
        self.guidLabel:setString(subStr)
      --end
      if self.strIndex>=lenNum then
        self.isTextGoing=false
        self.strIndex=1
      end
    end

end
function newGuidMgr:tick()

end
function newGuidMgr:fastTick()
    -- if platCfg.platBeimeiNewGuide[G_curPlatName()]~=nil then
    --     if self.isTextGoing then
    --         self.fastTickNum=self.fastTickNum+1
    --         if self.fastTickNum%6==0 then
    --             self:tickShowText()
    --         end
    --     end
end
function newGuidMgr:JudgeNewStageGuid()

end
function newGuidMgr:showNewStageGuid()

end
function newGuidMgr:showNewStageEndGuid()
    
end
function newGuidMgr:isNewGuiding()
    return self.isGuiding
end

function newGuidMgr:endNewGuid()
    base:removeFromNeedRefresh(self)
    base.nextDay=1
    popDialog:createNewGuid(sceneGame,30,getlocal("newGiftTitle"))
    local showSkinTipWithTime = CCUserDefault:sharedUserDefault():getIntegerForKey("showSkinTipWithTime")
    local isShowSkinTip = CCUserDefault:sharedUserDefault():getBoolForKey("isShowSkinTip")
    if base.isWinter and (showSkinTipWithTime == 0 or (isShowSkinTip == false and G_isToday(showSkinTipWithTime) ==false))then
        G_downNewMapAndInitWinterSkin()
    end
    G_SyncData();
    if self.bgLayer~=nil then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    if BossBattleScene then
        BossBattleScene.battlePaused=false
    end
    self.selectSp=nil
    self.panle=nil
    self.arrow=nil
    self.guidLabel=nil
    self.isGuiding=false
    self.closeBtn=nil
    self.bigCloseBtn=nil
    self.headerSprie=nil
    self.gn=nil
    self.dArrowSp=nil
    self.isTextGoing=false
    self.stencil=nil
    self.clipLayer=nil
    self.shadeLayer=nil
    self.shadeSp=nil
    self.circleSp=nil
    self.showFlag=false
    self.startIdx=0
    self.tlabel=nil
    self.tlabel2=nil
end

function newGuidMgr:close()

end

function newGuidMgr:clear()

end


function newGuidMgr:getTaskID()
    local tb={1,2,7,14,22,25,28,32,38,55}
    if self.curStep>55 then
        do
            return 0
        end
    end
    local curTask=0
    for i=1,#tb do
        if self.curStep>=tb[i] then
             curTask=i
        end
    end
    print("curTaskcurTask=",curTask)
    return curTask
end

function newGuidMgr:removeGuideLayer()
    self.isGuiding=false
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
end