newGuidMgr={
    curBMStep=1, --当前小步
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
    isShowStageGuid=false,--是否弹出过新手引导
    sign=0,--本地记录分步引导到了第几步
}
function newGuidMgr:init()
   self.sign=CCUserDefault:sharedUserDefault():getIntegerForKey("newGuidBMKey"..playerVoApi:getUid())

end

function newGuidMgr:setCurTask(cTask)
    --self.curTask=cTask
    if cTask<9 then
        cTask=1
    else
        cTask=2
    end
    local taskStepTb={1,6}
    ---  1,2,7,14,22,25,28,32,38,45

    if cTask==1 then
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
    self:setCurStep(taskStepTb[cTask])
    self:showGuid()
end

function newGuidMgr:setCurStep(cStep)
    self.curBMStep=cStep
end


function newGuidMgr:showGuid()
    self.isGuiding=true
    base:addNeedRefresh(self)

    print("self.curBMStep=",self.curBMStep)
    local guidCfg=newGuidBMCfg[self.curBMStep]
    
    local startSpTb={}
    
    local function tmpFunc()
               print("self.curBMStep",self.curBMStep,"clickToNext=",newGuidBMCfg[self.curBMStep].clickToNext)

               if newGuidBMCfg[self.curBMStep].clickToNext==true then --点击屏幕跳入下一步
                     PlayEffect(audioCfg.mouseClick)
                     if self.curBMStep==1 then

                         if self.bgLayer1~=nil then
                             for k,v in pairs(startSpTb) do
                                v:removeFromParentAndCleanup(true)
                             end
                             self.bgLayer1:removeFromParentAndCleanup(true)
                             self.bgLayer1=nil
                         end

                     end
                     self:toNextStep()
               end

    end
    if self.bgLayer==nil then
        self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
        if self.curBMStep==1 then --引导录像
            
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

    local tlabel=GetTTFLabelWrap(getlocal("guideBM_1"),30,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tlabel:setAnchorPoint(ccp(0.5,0.5))
    tlabel:setPosition(sp1:getContentSize().width/2,sp1:getContentSize().height/2+120)
    tlabel:setColor(ccc3(66,85,26))
    sp1:addChild(tlabel)
    
    local tlabel2=GetTTFLabelWrap(getlocal("guideBM_2"),30,CCSize(G_VisibleSize.width-60,150),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tlabel2:setAnchorPoint(ccp(0.5,0.5))
    tlabel2:setPosition(sp2:getContentSize().width/2-20,sp2:getContentSize().height/2-140)
    sp2:addChild(tlabel2)
    tlabel2:setOpacity(0)


    local fadeIn=CCFadeIn:create(1.6)
    tlabel:setOpacity(0)
    local delay=CCDelayTime:create(2)
    local fadeOut=CCFadeOut:create(1)
    local function playBackBgEnd()
        
        local fadeOut1=CCTintTo:create(0.5,255,255,255)
        local fadeOut2=CCTintTo:create(0.5,80,80,80)
        sp1:runAction(fadeOut2)
        sp2:runAction(fadeOut1)

        local fadeIn=CCFadeIn:create(0)
        tlabel:setOpacity(0)
        local delay=CCDelayTime:create(2)
        local fadeOut=CCFadeOut:create(1)
        local scaleTO1=CCScaleTo:create(0.2,1.3)
        local scaleTO2=CCScaleTo:create(0.2,1)
        local scaleTO3=CCScaleTo:create(0.2,1.3)
        local scaleTO4=CCScaleTo:create(0.2,1)
        local function playBackBgEnd()
            self.bgLayer1:removeFromParentAndCleanup(true)
            self.bgLayer1=nil
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
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        tlabel2:runAction(seq)

    end
    local callFunc=CCCallFuncN:create(playBackBgEnd)
    local acArr=CCArray:create()
    acArr:addObject(fadeIn)
    acArr:addObject(delay)
    acArr:addObject(fadeOut)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    tlabel:runAction(seq)
            
        else
            --self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,2,2),tmpFunc)
        end
        self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.bgLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.bgLayer:setTouchPriority(-320)
        self.bgLayer:setOpacity(0)
        sceneGame:addChild(self.bgLayer,8) --背景透明遮挡层，第7层
        
        local function clickAreaHandler()
                
        end
    self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
       self.selectSp:setAnchorPoint(ccp(0,0))
       self.selectSp:setTouchPriority(-1)
       self.selectSp:setIsSallow(false)
       self.bgLayer:addChild(self.selectSp)
       self.selectSp:setVisible(false)

    end
    if guidCfg.clickRect~=nil then
    else
        self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
    end

    if guidCfg.clickRect~=nil then --添加点击区域图标
           --local selectSp=CCSprite:createWithSpriteFrameName("guide_res.png")
           self.selectSp:setVisible(true)
           self.selectSp:setPosition(ccp(guidCfg.clickRect:getMinX(),guidCfg.clickRect:getMinY()))
           self.selectSp:setContentSize(CCSizeMake(guidCfg.clickRect.size.width,guidCfg.clickRect.size.height))
    else
        self.selectSp:setVisible(false)

    end
    
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
    end
    
    if self.curBMStep==6 and playerVoApi:getTutorial()==9 then
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
function newGuidMgr:toNextStep(nextId)
    if self.bgLayer~=nil then
        self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
    end
    print("zhiqian=",self.curBMStep)
    self.curBMStep=newGuidBMCfg[self.curBMStep].toStepId 


    if nextId~=nil then
        self.curBMStep=nextId
    end
    if self.curBMStep==5 and playerVoApi:getTutorial()~=9 then
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

        battleScene:close()

    end
    if self.curBMStep==2 then
     CCTextureCache:sharedTextureCache():removeTextureForKey("public/man.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("public/woman.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("public/framebtn.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_1.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_1X.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_2X.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newguid_2.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/man_3.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/woman_3.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/man_2.png")
     CCTextureCache:sharedTextureCache():removeTextureForKey("kunlunImage/woman_2.png")
            local t1={[1]={"t10013",5},[2]={"t10003",5},[3]={"t10033",5},[4]={"t10004",5},[5]={"t10014",5},[6]={"t10034",5}}
            local t2={[1]={"t10001",6},[2]={"t10082",6},[3]={"t10063",6},[4]={"t10043",6},[5]={"t10053",6},[6]={"t10073",6}}
    
            local data={data={report={p={{getlocal("mysticalFleet"),15,1},{playerVoApi:getPlayerName(),1,1}},d={{"3450-0"},{"1650-0","3300-0","1650-0","3300-0","1650-0","1650-0"}},t={t1,t2}}}}

            battleScene.battlePaused=true
            battleScene:initData(data)
    end
    if self.curBMStep==3 then
        battleScene.battlePaused=false
    end


    if self.curBMStep==6 then
        playerVoApi:setTutorial(9)
    end
    if self.curBMStep==6 and playerVoApi:getTutorial()==9 then
        if self.bgLayer~=nil then
            self.bgLayer:removeFromParentAndCleanup(true)
            self.bgLayer=nil
        end
        if platCfg.platBeimeiNewGuide[G_curPlatName()]~=nil then
            mainUI:showCreateNewRoleKunlun()
        else
            mainUI:showCreateNewRole()
        end

        do
            return
        end

    end


    if self.curBMStep==7 then
        
        statisticsHelper:tutorial(55,self.curBMStep)
        self:endNewGuid()
        local tmpTb={}
        tmpTb["action"]="newPlayerGuidEnd"
        local cjson=G_Json.encode(tmpTb)
        content=G_accessCPlusFunction(cjson)
        do
            return
        end
    end

    -- statisticsHelper:tutorial(cStep,cStep-1)
    self:showGuid()
end
function newGuidMgr:showPanle(step)
    if step~=nil then
        self.curBMStep=step
    end
    if self.bgLayer==nil then
        local function tmpFunc()
            
            local toStepId=newGuidBMCfg[self.curBMStep].toStepId
            if toStepId~=nil then
                self:showPanle(toStepId)
            else
                if self.bgLayer~=nil then
                    self.bgLayer:removeFromParentAndCleanup(true)
                    self.bgLayer=nil
                    self:close()
                end
            end
            
        end
        self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
        self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.bgLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.bgLayer:setOpacity(0)
        self.bgLayer:setTouchPriority(-99999)
        if self.curBMStep==9 then
            self.bgLayer:setIsSallow(true)
        else
            self.bgLayer:setIsSallow(false)
        end
        sceneGame:addChild(self.bgLayer,8) --背景透明遮挡层，第7层
    end
    
    local guidCfg=newGuidBMCfg[self.curBMStep]
    if self.panle==nil then
         self.panle=CCNode:create()
         if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            self.gn=CCSprite:create("public/guide.png") --姑娘
         else
            self.gn=CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
         end
         self.gn:setAnchorPoint(ccp(0,0))
         self.gn:setPosition(ccp(30,100))
         self.panle:addChild(self.gn)
         
         local rect = CCRect(0, 0, 50, 50);
         local capInSet = CCRect(20, 20, 10, 10);
         local function cellClick(hd,fn,idx)

         end
         self.headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
         self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
         self.headerSprie:ignoreAnchorPointForPosition(false);
         self.headerSprie:setAnchorPoint(ccp(0,0));
         self.headerSprie:setTouchPriority(0)
           --headerSprie:setPosition(ccp(0,cell:getContentSize().height-self.headerSprie:getContentSize().height));
           self.panle:addChild(self.headerSprie)
         self.guidLabel=GetTTFLabelWrap("",25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
         self.guidLabel:setAnchorPoint(ccp(0,0.5))
         self.guidLabel:setPosition(ccp(10,self.headerSprie:getContentSize().height/2))
         self.headerSprie:addChild(self.guidLabel) --添加文本框
         --if guidCfg.hasCloseBtn==true then --面板上的关闭按钮
               local function closeBtnHandler()
                     --退出新手引导操作
                     guidCfg=newGuidBMCfg[self.curBMStep]
                     if  guidCfg.hasCloseBtn~=true then
                        do
                            return
                        end
                     end
                     local function callBack()
                         
                         local function skipServerHandler(fn,data)
                             --local retTb=OBJDEF:decode(data)
                             if base:checkServerData(data)==true then
                                    portScene:setShow()
                                    self.curBMStep=5
                                    playerVoApi:setTutorial(9)
                                    self:showGuid()
                                    statisticsHelper:tutorial(55,self.curBMStep)
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
                    self.closeBtn:setTouchPriority(-321);
                    self.headerSprie:addChild(self.closeBtn)

               else

                  self.closeBtn= LuaCCSprite:createWithSpriteFrameName("GuideClose.png",closeBtnHandler)
                   self.closeBtn:setPosition(self.headerSprie:getContentSize().width-self.closeBtn:getContentSize().width/2,self.headerSprie:getContentSize().height+self.closeBtn:getContentSize().height/2-3)
                   self.closeBtn:setTouchPriority(-321)
                   self.headerSprie:addChild(self.closeBtn)
               end

               
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
         self.bgLayer:addChild(self.panle)
         

    end
    if self.dArrowSp~=nil then
        self.dArrowSp=tolua.cast(self.dArrowSp,"CCNode")
        if self.dArrowSp~=nil then
            self.dArrowSp:setVisible(false)
        end
    end
    if self.selectSp==nil then
        local function clickAreaHandler()
                
        end
       self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
       self.selectSp:setAnchorPoint(ccp(0,0))
       self.selectSp:setTouchPriority(-1)
       self.selectSp:setIsSallow(false)
       self.bgLayer:addChild(self.selectSp)
       self.selectSp:setVisible(false)
    end
    if guidCfg.clickRect~=nil then --添加点击区域图标
           --local selectSp=CCSprite:createWithSpriteFrameName("guide_res.png")
           self.selectSp:setVisible(true)
           self.selectSp:setPosition(ccp(guidCfg.clickRect:getMinX(),guidCfg.clickRect:getMinY()))
           self.selectSp:setContentSize(CCSizeMake(guidCfg.clickRect.size.width,guidCfg.clickRect.size.height))
    end


    if self.arrow==nil then --箭头
            self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
            self.arrow:setAnchorPoint(ccp(0.5,0.5))
            self.bgLayer:addChild(self.arrow)
    end
    if self.arrow~=nil then --箭头
        self.arrow=tolua.cast(self.arrow,"CCNode")
        self.arrow:setPosition(guidCfg.arrowPos)
    end

    if guidCfg.hasCloseBtn==true then --面板上的关闭按钮
         self.closeBtn:setVisible(true)
    else
         self.closeBtn:setVisible(false)
    end
    local guidStr = getlocal("guideBM_tip_"..self.curBMStep)
    if self.curBMStep==8 then
        guidStr = getlocal("guideBM_tip_"..self.curBMStep,{playerVoApi:getPlayerName()})
    end
    self.guidLabel:setString(guidStr)
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
            
            if self.dArrowSp~=nil then
                if guidCfg.clickToNext==true then
                    self.dArrowSp:setVisible(true)
                else
                    self.dArrowSp:setVisible(false)
                end
            end
            

            if self.arrow~=nil then
                self.arrow:stopAllActions()
                self.arrow:setVisible(false)
                local arrowPosition =ccp(guidCfg.arrowPos.x,guidCfg.arrowPos.y)
                if guidCfg.arrowDirect==1 then  --下
						arrowPosition.y=arrowPosition.y-100/2
                elseif guidCfg.arrowDirect==2 then  --上
						arrowPosition.y=arrowPosition.y+100/2
                elseif guidCfg.arrowDirect==3 then  --右上
						arrowPosition.x=arrowPosition.x+80/2
						arrowPosition.y=arrowPosition.y+80/2
                end
				self.arrow:setPosition(arrowPosition)
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

                local  ffunc=CCCallFuncN:create(showArrowAction)
                local  fseq=CCSequence:createWithTwoActions(fadeIn,ffunc)
                self.arrow:runAction(fseq)

            end
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
            
            if self.selectSp~=nil then
                local function sdHandler()
                        local fadeOut=CCTintTo:create(0.5,150,150,150)
                        local fadeIn=CCTintTo:create(0.5,255,255,255)
                        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
                        self.selectSp:runAction(CCRepeatForever:create(seq))
                end
                self.selectSp:stopAllActions()
                local fadeIn=CCFadeIn:create(0.3)
                local calFunc=CCCallFuncN:create(sdHandler)
                local  fseq=CCSequence:createWithTwoActions(fadeIn,calFunc)
                self.selectSp:setOpacity(0)
                self.selectSp:runAction(fseq)

            end

            if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
                self.closeBtn:stopAllActions()
                local fadeIn=CCFadeIn:create(0.3)
                self.closeBtn:setOpacity(0)
                self.closeBtn:runAction(fadeIn)
            end
            -- if guidCfg.clickRect~=nil then
            --     self.bgLayer:setNoSallowArea(guidCfg.clickRect)
            -- end
    end
   -- (guidCfg.delayTime==nil and 1 or guidCfg.delayTime)
    local delay=CCDelayTime:create(guidCfg.delayTime==nil and 1 or guidCfg.delayTime)
    local  ffunc=CCCallFuncN:create(showP)
    local  fseq=CCSequence:createWithTwoActions(delay,ffunc)
    self.panle:runAction(fseq)
    

end

function newGuidMgr:getSign()
    return self.sign
end

function newGuidMgr:setSign(step)
    CCUserDefault:sharedUserDefault():setIntegerForKey("newGuidBMKey"..playerVoApi:getUid(),step)
    CCUserDefault:sharedUserDefault():flush()
    self.sign=step
end

function newGuidMgr:JudgeNewStageGuid()
    --第一阶段 指挥中心是否2级 并且 坦克工厂是否建造
    if self.isGuiding==true then
        do
            return
        end
    end
    if self:getSign()>=18 then
        do
            return
        end
    end
    --print("self:getSign()=",self.isShowStageGuid,self:getSign(),sceneController:getNextIndex(),buildingVoApi:getBuildiingVoByBId(1).level,buildingVoApi:getBuildiingVoByBId(11).status,buildingVoApi:isHaveResBuilding())

    if self:getSign()<10 then
        if self.isShowStageGuid==false and sceneController:getNextIndex()==1 and buildingVoApi:getBuildiingVoByBId(1).level>=2 and base.allShowedCommonDialog==0 and buildingVoApi:getBuildiingVoByBId(11).status<1 then
            self.isShowStageGuid=true
            portScene.sceneSp:setScale(portScene.minScale)
            portScene.clayer:setPosition(ccp(-450,-20))
            self:showPanle(10)
        elseif buildingVoApi:getBuildiingVoByBId(1).level>=2 and buildingVoApi:getBuildiingVoByBId(11).status>=1  then
            self:setSign(10)
            self.isShowStageGuid=false
        end
    elseif self:getSign()>=10 and self:getSign()<11 then
        if self.isShowStageGuid==false and sceneController:getNextIndex()==2 and buildingVoApi:isHaveResBuilding()==false and base.allShowedCommonDialog==0 then
            self.isShowStageGuid=true
            mainLandScene.sceneSp:setScale(mainLandScene.minScale)
            mainLandScene.clayer:setPosition(ccp(-90,15))
            self:showPanle(12)
        elseif buildingVoApi:isHaveResBuilding()==true then
            self:setSign(11)
            self.isShowStageGuid=false
        end
    elseif self:getSign()>=11 and self:getSign()<13 then
        if self.isShowStageGuid==false and checkPointVoApi:getStarNum()==0 and playerVoApi:getPlayerLevel()>=3 and base.allShowedCommonDialog==0 then
            self.isShowStageGuid=true
            mainUI.tv:reloadData()
            self:showPanle(13)
        elseif checkPointVoApi:getStarNum()>0 then
            self:setSign(13)
            self.isShowStageGuid=false
        end
    elseif self:getSign()>=13 and self:getSign()<14 then
        if self.isShowStageGuid==false and  playerVoApi:getPlayerLevel()>=3 and playerVoApi:getTroops()==0 and base.allShowedCommonDialog==0 then
            self.isShowStageGuid=true
            self:showPanle(14)
        elseif checkPointVoApi:getStarNum()>0 and playerVoApi:getPlayerLevel()>=3 and playerVoApi:getTroops()>0 then
            self:setSign(15)
            self.isShowStageGuid=false
        end
    elseif self:getSign()>=15 and self:getSign()<16 then
        if self.isShowStageGuid==false and  playerVoApi:getPlayerLevel()>=3 and (sceneController:getNextIndex()==2 or sceneController:getNextIndex()==1 ) and skillVoApi:getSkillIsAllZero() and base.allShowedCommonDialog==0 then
            self.isShowStageGuid=true
            self:showPanle(16)
        elseif checkPointVoApi:getStarNum()>0 and playerVoApi:getPlayerLevel()>=3 and skillVoApi:getSkillIsAllZero()==false then
            self:setSign(17)
            self.isShowStageGuid=false
        end
    elseif self:getSign()>=17 and self:getSign()<18 then
        if self.isShowStageGuid==false and  base.allShowedCommonDialog==0 and base.allShowedSmallDialog==8 and sceneController:getNextIndex()==1 and buildingVoApi:getBuildiingVoByBId(1).level>=5 and buildingVoApi:getBuildiingVoByBId(3).level==0 then
            self.isShowStageGuid=true
            portScene.sceneSp:setScale(portScene.minScale)
            if G_isIphone5() then
                portScene.clayer:setPosition(ccp(-152,-76))
            else
                portScene.clayer:setPosition(ccp(-158,-235))
            end
            
            
            self:showPanle(18)
        elseif buildingVoApi:getBuildiingVoByBId(3).level>=1 then
            self:setSign(18)
            self.isShowStageGuid=false
        end
    end

end

function newGuidMgr:showNewStageGuid(type)
    if type==1 then
        if self:getSign()>=13 and self:getSign()<14 then
            self.isShowStageGuid=false
            if self.isShowStageGuid==false and  playerVoApi:getPlayerLevel()>=3 and playerVoApi:getTroops()==0 then
                    self.isShowStageGuid=true
                    self:showPanle(15)
            elseif checkPointVoApi:getStarNum()>0 and playerVoApi:getPlayerLevel()>=3 and playerVoApi:getTroops()>0 then
                    self:setSign(15)
                    self.isShowStageGuid=false
            end
        end
    else
        if self:getSign()>=15 and self:getSign()<16 then
            self.isShowStageGuid=false
            if self.isShowStageGuid==false and  playerVoApi:getPlayerLevel()>=3 and skillVoApi:getSkillIsAllZero() then
                self.isShowStageGuid=true
                self:showPanle(17)
            elseif checkPointVoApi:getStarNum()>0 and playerVoApi:getPlayerLevel()>=3 and skillVoApi:getSkillIsAllZero()==false then
                self:setSign(17)
                self.isShowStageGuid=false
            end
        end
    end

end
function newGuidMgr:showNewStageEndGuid()
    self:showPanle(8)
end

function newGuidMgr:tick()


end
function newGuidMgr:fastTick()

end

function newGuidMgr:isNewGuiding()
    return self.isGuiding
end

function newGuidMgr:endNewGuid()
    base:removeFromNeedRefresh(self)
    base.nextDay=1
    popDialog:createNewGuid(sceneGame,30,getlocal("newGiftTitle"))
    -- print("self:getTaskID()=",self:getTaskID())
    G_SyncData();
    if self.bgLayer~=nil then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.sign=CCUserDefault:sharedUserDefault():getIntegerForKey("newGuidBMKey"..playerVoApi:getUid())
    battleScene.battlePaused=false
    self.selectSp=nil
    self.panle=nil
    self.arrow=nil
    self.guidLabel=nil
    self.isGuiding=false
    self.closeBtn=nil
    self.headerSprie=nil
    self.gn=nil
    self.dArrowSp=nil
    self.isTextGoing=false
    newGuidMgr:setSign(9)
    --self:showPanle(8)

end

function newGuidMgr:close()
    self.bgLayer=nil
    self.selectSp=nil
    self.panle=nil
    self.arrow=nil
    self.guidLabel=nil
    self.isGuiding=false
    self.closeBtn=nil
    self.headerSprie=nil
    self.gn=nil
    self.dArrowSp=nil
    
end
function newGuidMgr:clear()
    self.bgLayer=nil
    self.selectSp=nil
    self.panle=nil
    self.arrow=nil
    self.guidLabel=nil
    self.isGuiding=false
    self.closeBtn=nil
    self.headerSprie=nil
    self.gn=nil
    self.dArrowSp=nil
    self.isShowStageGuid=false
end

function newGuidMgr:getTaskID()
    -- local tb={1,6}
    if self.curBMStep>7 then
        do
            return 0
        end
    end
    if self.curBMStep<6 then
        cTask=1
    elseif self.curBMStep==6 then
        cTask=9
    elseif self.curBMStep==7 then
        cTask=10
    end
    return cTask
end
