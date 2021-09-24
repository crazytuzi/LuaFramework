phasedGuideMgr=
{
    hasInit=false,
    curStep=1,
    bgLayer,
    bgLayer1,
    panel,
    arrow,
    guidLabel,
    isGuiding=false,
    selectSp,
    closeBtn,
    dArrowSp,
    isTextGoing=false,
    fastTickNum=0,
    eventListener=nil,
    waitingForGuideTb={},   --一个等待队列, 里面存的是所有等待引导的步数
    eventStepTb={},         --另一个队列, key是event, value是一个table, 存储在该event的哪个引导还没有做过, 加这个队列是为了当同一个event有多个引导的时候，让引导挨个出现
    checkGuideTb={},        --一个检查某个本地数据是否已经存在的tb
    insideBgLayer=nil,
    isInsideGuiding=false,
}

function phasedGuideMgr:init()
    if(self.hasInit)then
        do return end
    end
    self.curStep=self:getCurStep()
    
    if self:getCurMainLandStep()==0 then
        local bid = 16
        for i=1,30 do
            if buildingVoApi:getBuildiingVoByBId(bid).status==0 then
                break
            end
            bid=bid+1
        end
        
        self:setCurMainLandStep(bid)
    end

    self.hasInit=true
    local function listener(event,data)
        self:guideEventListener(event,data)
    end
    self.waitingForGuideTb={}
    self.eventStepTb={}
    self.eventListener=listener
    for k,v in pairs(phasedGuideCfg) do
        if(v.event and v.event~="")then
            if(self:checkGuide(v.stepId)==false)then
                if(self.eventStepTb[v.event]==nil)then
                    self.eventStepTb[v.event]={}
                end
                table.insert(self.eventStepTb[v.event],v.stepId)
                eventDispatcher:addEventListener(v.event,listener)
            end
        end
    end
    base:addNeedRefresh(self)
    self:checkOnInit()

    self.buildingsIdTb={2,3,7,4,6,5,13,12,9}
    self.portMax=9

end

function phasedGuideMgr:checkOnInit()
    if(self:checkGuide(1)==false)then
        local allTanks=tankVoApi:getAllTanks()
        for k,v in pairs(allTanks) do
            if(tankCfg[k].inWarehouse)then
                eventDispatcher:dispatchEvent("tank.addToWarehouse")
                break
            end
        end
    end
end

function phasedGuideMgr:guideEventListener(event,data)
    for k,v in pairs(self.eventStepTb[event]) do
        if(self:checkGuide(v)==false)then
            local flag=false
            for k1,v1 in pairs(self.waitingForGuideTb) do
                if(v1==v)then
                    flag=true
                    break
                end
            end
            if(flag==false)then
                table.insert(self.waitingForGuideTb,v)
            end
        end
    end
end

function phasedGuideMgr:getCurStep()
    local curStep = 1
    local dataKey="phasedGuide@"..tostring(playerVoApi:getUid())
    local dataStr=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if dataStr=="" then
        curStep=1
    else
        local phasedGuideTb=G_Json.decode(dataStr)
        curStep=phasedGuideTb.step
    end
    --curStep=8
    return curStep
end

function phasedGuideMgr:setCurStep(step)
    local phasedGuideTb= {
    step=step,
    uid=playerVoApi:getUid()
    }
    local dataKey="phasedGuide@"..tostring(playerVoApi:getUid())
    local phasedGuideTbStr=G_Json.encode(phasedGuideTb)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,phasedGuideTbStr)
    CCUserDefault:sharedUserDefault():flush()
end

function phasedGuideMgr:getInsideKey(bid)
    local dataKey="phasedGuide@"..tostring(playerVoApi:getUid()).."inside"..bid
    local dataStr=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
    return dataStr
end

function phasedGuideMgr:setInsideKeyDone(bid)
    local dataKey="phasedGuide@"..tostring(playerVoApi:getUid()).."inside"..bid
    CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,1)
end

function phasedGuideMgr:getCurMainLandStep()
    local curStep = 0
    local dataKey="phasedGuideMainLand@"..tostring(playerVoApi:getUid())
    local dataStr=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if dataStr=="" then
        curStep=0
    else
        local phasedGuideTb=G_Json.decode(dataStr)
        curStep=phasedGuideTb.step
    end
    return curStep
end

function phasedGuideMgr:setCurTaiMainLandStep(step)
    local phasedGuideTb= {
    step=step,
    uid=playerVoApi:getUid()
    }
    local dataKey="phasedGuideTaiMainLand@"..tostring(playerVoApi:getUid())
    local phasedGuideTbStr=G_Json.encode(phasedGuideTb)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,phasedGuideTbStr)
    CCUserDefault:sharedUserDefault():flush()
end

function phasedGuideMgr:getCurTaiMainLandStep()
    local curStep = 0
    local dataKey="phasedGuideTaiMainLand@"..tostring(playerVoApi:getUid())
    local dataStr=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if dataStr=="" then
        curStep=46
    else
        local phasedGuideTb=G_Json.decode(dataStr)
        curStep=phasedGuideTb.step
    end
    return curStep
end

function phasedGuideMgr:setCurMainLandStep(step)
    local phasedGuideTb= {
    step=step,
    uid=playerVoApi:getUid()
    }
    local dataKey="phasedGuideMainLand@"..tostring(playerVoApi:getUid())
    local phasedGuideTbStr=G_Json.encode(phasedGuideTb)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,phasedGuideTbStr)
    CCUserDefault:sharedUserDefault():flush()
end

function phasedGuideMgr:tick()
    --do return end
    if(newGuidMgr.isGuiding or self.isGuiding or G_isBuildingAnim)then
        do return end
    end

    --print("zuobiao=",portScene.clayer:getPositionX(),portScene.clayer:getPositionY())
   -- 水晶工厂解锁未建造
   -- do return end
     --print("self:getCurStep()=",self:getCurStep())
    if self:isInPort() and self:getCurStep()<=self.portMax then
      --print("self:getCurStep()=",self:getCurStep())
      local bid = self.buildingsIdTb[self:getCurStep()]
      --print("bid=",bid,buildingVoApi:getBuildiingVoByBId(bid).status,playerVoApi:getPlayerLevel())
      local buildingVo = buildingVoApi:getBuildiingVoByBId(bid)

      --print("adadadada=",(playerVoApi:getPlayerLevel()>=20 and bid==9))

      if  (bid~=9 and  buildingVo.status==0 and self:isInPort()) or (playerVoApi:getPlayerLevel()>=20 and bid==9) then
          portScene.sceneSp:setScale(portScene.minScale)
          --print("bid55555=",bid)


          local sp = buildings:getBuildingSpByBid(bid)
          local pX =-(sp:getPositionX()*portScene.minScale-G_VisibleSize.width/2)
          local pY =-(sp:getPositionY()*portScene.minScale-G_VisibleSize.height/2)
          local pos=portScene:checkBound(ccp(pX,pY))
          --local pos=ccp(pX,pY)
          -- print("建筑",sp:getPositionX(),sp:getPositionY())
          -- print("屏幕宽高",G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
          -- print("大地图坐标",pos.x,"aaaa=",pos.y)


          local height = sp:getPositionY()-pos.y
          if height>G_VisibleSizeHeight/2 then
              self.panelPos=ccp(10,G_VisibleSizeHeight-900)
          else
              self.panelPos=ccp(10,G_VisibleSizeHeight-400)
          end

          local function touchCallBack( ... )
            
          end
          self.cLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchCallBack)
          self.cLayer:setAnchorPoint(ccp(0.5,0.5))
          self.cLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
          self.cLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
          self.cLayer:setTouchPriority(-9999)
          self.cLayer:setIsSallow(true)
          self.cLayer:setOpacity(0)
          sceneGame:addChild(self.cLayer,9999) --背景透明遮挡层，第7层



          local function acallBack()
              -- body
              self:showGuide(self:getCurStep())
              self:setCurStep(self:getCurStep()+1)
          end
          G_movePointToScreenCenter(portScene,portScene.clayer,ccp(sp:getPositionX(),sp:getPositionY()),acallBack)
          
      end
    end

    if self:isInIsLand() then

        -- 46 钛矿
        --print("aaa=",self:getCurMainLandStep(),buildingVoApi:getBuildiingVoByBId(self:getCurMainLandStep()).status)

        if self:getCurMainLandStep()<=45 then
            if buildingVoApi:getBuildiingVoByBId(self:getCurMainLandStep()).status==0 and self:isInIsLand() then
                mainLandScene.sceneSp:setScale(mainLandScene.minScale)
                self.isInsideGuiding=true
                local bid = self:getCurMainLandStep()
                local sp = buildings:getBuildingSpByBid(bid)

                local pX =-(sp:getPositionX()*mainLandScene.minScale-G_VisibleSizeWidth/2)
                local pY =-(sp:getPositionY()*mainLandScene.minScale-G_VisibleSizeHeight/2)

                local pos=mainLandScene:checkBound(ccp(pX,pY))
                --print("ooo=",pos.x,pos.y)
                local height = sp:getPositionY()-pos.y
                if height>G_VisibleSizeHeight/2 then
                    self.panelPos=ccp(10,G_VisibleSizeHeight-900)
                else
                    self.panelPos=ccp(10,G_VisibleSizeHeight-400)
                end

                local function touchCallBack( ... )
            
                end
                self.cLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchCallBack)
                self.cLayer:setAnchorPoint(ccp(0.5,0.5))
                self.cLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
                self.cLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
                self.cLayer:setTouchPriority(-9999)
                self.cLayer:setIsSallow(true)
                self.cLayer:setOpacity(0)
                sceneGame:addChild(self.cLayer,9999) --背景透明遮挡层，第7层

                local function bcallBack()
                    self:showGuide(self:getCurMainLandStep())
                    self:setCurMainLandStep(self:getCurMainLandStep()+1)
                end
                G_movePointToScreenCenter(mainLandScene,mainLandScene.clayer,ccp(sp:getPositionX(),sp:getPositionY()),bcallBack)
                
                --mainLandScene.clayer:setPosition(ccp(pos.x,pos.y))
                
            elseif buildingVoApi:getBuildiingVoByBId(self:getCurMainLandStep()).status==1 then
                self:setCurMainLandStep(self:getCurMainLandStep()+1)
            elseif self:getCurTaiMainLandStep()>45 and self:getCurTaiMainLandStep()<100 then

                if buildingVoApi:getBuildiingVoByBId(self:getCurTaiMainLandStep()).status==0 and self:isInIsLand() then
                    mainLandScene.sceneSp:setScale(mainLandScene.minScale)
                    self.isInsideGuiding=true
                    local bid = self:getCurTaiMainLandStep()
                    local sp = buildings:getBuildingSpByBid(bid)

                    local pX =-(sp:getPositionX()*mainLandScene.minScale-G_VisibleSizeWidth/2)
                    local pY =-(sp:getPositionY()*mainLandScene.minScale-G_VisibleSizeHeight/2)

                    local pos=mainLandScene:checkBound(ccp(pX,pY))
                    print("ooo=",pos.x,pos.y)
                    local height = sp:getPositionY()-pos.y
                    if height>G_VisibleSizeHeight/2 then
                        self.panelPos=ccp(10,G_VisibleSizeHeight-900)
                    else
                        self.panelPos=ccp(10,G_VisibleSizeHeight-400)
                    end

                    local function touchCallBack( ... )
                
                    end
                    self.cLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchCallBack)
                    self.cLayer:setAnchorPoint(ccp(0.5,0.5))
                    self.cLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
                    self.cLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
                    self.cLayer:setTouchPriority(-9999)
                    self.cLayer:setIsSallow(true)
                    self.cLayer:setOpacity(0)
                    sceneGame:addChild(self.cLayer,9999) --背景透明遮挡层，第7层

                    local function ccallBack()
                        self:showGuide(self:getCurTaiMainLandStep())
                        self:setCurTaiMainLandStep(self:getCurTaiMainLandStep()+1)
                    end
                    G_movePointToScreenCenter(mainLandScene,mainLandScene.clayer,ccp(sp:getPositionX(),sp:getPositionY()),ccallBack)

                elseif buildingVoApi:getBuildiingVoByBId(self:getCurTaiMainLandStep()).status==1 then
                    self:setCurTaiMainLandStep(self:getCurTaiMainLandStep()+1)
                end
            end



        end
    end

end

function phasedGuideMgr:isInIsLand()
    local isInIsLand = false
    --print(sceneController:getNextIndex(),base.allShowedCommonDialog,SizeOfTable(G_SmallDialogDialogTb))
    if sceneController:getNextIndex()==2 and base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 and storyScene.isShow==false then
        isInIsLand=true
    end
    return isInIsLand
end



function phasedGuideMgr:isInPort()
    local isInPort = false
    if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 and storyScene.isShow==false then
        isInPort=true
    end
    return isInPort
end

--检查该步引导是否已经出现过，出现过的引导会在本地存数据
--param step 要检查的步骤
--return true or false,是否已经引导过
function phasedGuideMgr:checkGuide(step)
    local dataKey="otherGuide@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(step)
    if(self.checkGuideTb[dataKey]==nil)then
        local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if(localData~=nil and localData~="")then
            self.checkGuideTb[dataKey]=true
        else
            self.checkGuideTb[dataKey]=false
        end
    end
    return self.checkGuideTb[dataKey]
end

function phasedGuideMgr:showGuide(step)
    self.isGuiding=true
    if step==10 then
        self.isGuiding=false
    end
    self.curStep=step
    local dataKey="otherGuide@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(step)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,"1")
    CCUserDefault:sharedUserDefault():flush()
    self.checkGuideTb[dataKey]=true

    local guidCfg=phasedGuideCfg[self.curStep]   
    local startSpTb={}
    
    local function tmpFunc()
        if phasedGuideCfg[self.curStep] and phasedGuideCfg[self.curStep].clickToNext==true then --点击屏幕跳入下一步
            self:toNextStep()
        elseif self:isShowGuide() then
            self:toNextStep()
            self.isInsideGuiding=false
        end
    end
    if self.bgLayer==nil then
        self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
        self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.bgLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.bgLayer:setTouchPriority(-320)
        self.bgLayer:setIsSallow(false)
        self.bgLayer:setOpacity(0)
        sceneGame:addChild(self.bgLayer,8) --背景透明遮挡层，第7层
        
        local function clickAreaHandler()               
        end
        self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
        --self.selectSp:setAnchorPoint(ccp(0,0))
        self.selectSp:setTouchPriority(-1)
        self.selectSp:setIsSallow(false)
        self.bgLayer:addChild(self.selectSp)
        self.selectSp:setVisible(false)
    end
    self.bgLayer:setTouchPriority(-320)
    self.bgLayer:setIsSallow(false)
    if guidCfg~=nil and guidCfg.clickRect~=nil then
        self.selectSp:setVisible(true)
        self.selectSp:setPosition(ccp(guidCfg.clickRect:getMinX(),guidCfg.clickRect:getMinY()))
        self.selectSp:setContentSize(CCSizeMake(guidCfg.clickRect.size.width,guidCfg.clickRect.size.height))
    elseif self.curStep<=self.portMax or self.curStep>15 then
        self.selectSp:setVisible(true)
        if self.curStep<=self.portMax then
            --print("self.curStep=",self.curStep)
            local bid = self.buildingsIdTb[self.curStep]
            local sp = buildings:getBuildingSpByBid(bid)

            self.selectSp:setContentSize(CCSizeMake(sp:getContentSize().width,sp:getContentSize().height))
            local pos=ccp(portScene.clayer:getPositionX()+sp:getPositionX()*portScene.sceneSp:getScale(),portScene.clayer:getPositionY()+sp:getPositionY()*portScene.sceneSp:getScale())
            self.selectSp:setPosition(ccp(pos.x,pos.y))
        end
        if self.curStep>15 and self.curStep<100 then
            print("self.curStep=",self.curStep)
            local bid = self.buildingsIdTb[self.curStep]
            if self.curStep>15 then
                bid=self.curStep
            end
            local sp = buildings:getBuildingSpByBid(bid)
            self.selectSp:setContentSize(CCSizeMake(sp:getContentSize().width,sp:getContentSize().height))
            local pos=ccp(mainLandScene.clayer:getPositionX()+sp:getPositionX()*mainLandScene.sceneSp:getScale(),mainLandScene.clayer:getPositionY()+sp:getPositionY()*mainLandScene.sceneSp:getScale())
            self.selectSp:setPosition(ccp(pos.x,pos.y))
        end



    else
        self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
        self.selectSp:setVisible(false)
    end 
    if guidCfg and guidCfg.hasPanel==true then --新手引导面板
        self:showPanel()
        self.panel=tolua.cast(self.panel,"CCNode")
        self.panel:setVisible(true)
    elseif self:isShowGuide() then
        self:showPanel()
        self.panel=tolua.cast(self.panel,"CCNode")
        self.panel:setVisible(true)
    else
        if self.panel~=nil then
            self.panel=tolua.cast(self.panel,"CCNode")
            self.panel:setVisible(false)
        end
        if self.arrow~=nil then
            self.arrow=tolua.cast(self.arrow,"CCNode")
            self.arrow:setVisible(false)
        end
    end
end

function phasedGuideMgr:isShowGuide()
    local isShow = false
    if self.curStep<=self.portMax or self.curStep>15 then
        isShow = true
    end
    return isShow
end

function phasedGuideMgr:showPanel()
    local guidCfg=phasedGuideCfg[self.curStep]
    if self.panel==nil then
        self.panel=CCNode:create()
        if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            self.gn=CCSprite:create("public/guide.png")
        else
            self.gn=CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
        end
        self.gn:setAnchorPoint(ccp(0,0))
        self.gn:setPosition(ccp(30,100))

        
        self.panel:addChild(self.gn)
         
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        self.headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
        self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
        self.headerSprie:ignoreAnchorPointForPosition(false);
        self.headerSprie:setAnchorPoint(ccp(0,0))
        self.headerSprie:setTouchPriority(0)
        self.panel:addChild(self.headerSprie)
        self.guidLabel=GetTTFLabelWrap("",25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.guidLabel:setAnchorPoint(ccp(0,0.5))
        self.guidLabel:setPosition(ccp(10,self.headerSprie:getContentSize().height/2))
        self.headerSprie:addChild(self.guidLabel) --添加文本框
        local function closeBtnHandler()
            guidCfg=phasedGuideCfg[self.curStep]
            if guidCfg and guidCfg.hasCloseBtn~=true then
                do return end
            end
            local function callBack()
            end
            PlayEffect(audioCfg.mouseClick)   
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("guide_skip_prompt"),nil,100)
        end
        self.closeBtn= LuaCCSprite:createWithSpriteFrameName("GuideClose.png",closeBtnHandler)
        self.closeBtn:setPosition(self.headerSprie:getContentSize().width-self.closeBtn:getContentSize().width/2,self.headerSprie:getContentSize().height+self.closeBtn:getContentSize().height/2-3)
        self.closeBtn:setTouchPriority(-321)
        self.headerSprie:addChild(self.closeBtn)
         
        ----以下面板上的倒三角----
        self.dArrowSp=CCSprite:createWithSpriteFrameName("DownArow1.png")
        local spcArr=CCArray:create()
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
        self.panel:addChild(self.dArrowSp)
         ----以上面板上的倒三角----
        self.bgLayer:addChild(self.panel)
    end
    if self.dArrowSp~=nil then
        self.dArrowSp=tolua.cast(self.dArrowSp,"CCNode")
        self.dArrowSp:setVisible(false)
    end
    if self.arrow==nil then --箭头
        self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
        self.arrow:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(self.arrow)
    end
    if self.arrow~=nil then --箭头
        if guidCfg and guidCfg.arrowPos then
            self.arrow:setPosition(guidCfg.arrowPos)
        elseif self.curStep<=self.portMax or self.curStep>15 then
            local selectSpPos = ccp(self.selectSp:getPositionX(),self.selectSp:getPositionY()) 
            self.arrow:setPosition(ccp(selectSpPos.x,selectSpPos.y-270))
        end
    end

    if guidCfg and guidCfg.hasCloseBtn==true then --面板上的关闭按钮
         self.closeBtn:setVisible(true)
    else
         self.closeBtn:setVisible(false)
    end
    local guideStr = getlocal("phased_guide_tip_"..self.curStep)
    if self.curStep<=self.portMax-1 then
        local tb = {getlocal("help3_t1_t6"),getlocal("sample_build_name_08"),getlocal("alliance_list_scene_name"),getlocal("help3_t1_t7"),getlocal("propBuilding"),getlocal("secondWarehouse"),getlocal("help3_t1_t4"),getlocal("secondTankFactory"),}
        guideStr=getlocal("phased_guide_tip_common",{tb[self.curStep]})

    elseif self.curStep>=16 and self.curStep<100 then
        guideStr=getlocal("phased_guide_tip_common",{getlocal("emptyPlots")})
    elseif self.curStep>1000 then
        guideStr=getlocal("phased_guide_tip_"..self.curStep)
    elseif self.curStep==9 then
        guideStr=getlocal("phased_guide_tip_109")
    end

    self.guidLabel:setString(guideStr)
    if guidCfg and guidCfg.panlePos then
        self.panel:setPosition(guidCfg.panlePos)
    else
        if self.panelPos==nil then
            self.panel:setPosition(ccp(10,G_VisibleSizeHeight-900))
        else
            self.panel:setPosition(self.panelPos)
        end
    end
    self.panel:stopAllActions()
    
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
        self.guidLabel:setOpacity(0)
        if guidCfg and guidCfg.showGirl~=nil and guidCfg.showGirl==false then
            self.gn=tolua.cast(self.gn,"CCNode")
            self.gn:setVisible(false)
        else
            self.gn=tolua.cast(self.gn,"CCNode")
            self.gn:setVisible(true)
        end
        
        if guidCfg and guidCfg.clickRect==nil then
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
            if guidCfg and guidCfg.clickToNext==true then
                self.dArrowSp:setVisible(true)
            else
                self.dArrowSp:setVisible(false)
            end
        end
        

        if self.arrow~=nil then
            self.arrow:stopAllActions()
            self.arrow:setVisible(false)
            local arrowPos=ccp(0,0)
            if guidCfg and guidCfg.arrowPos then
                arrowPos = guidCfg.arrowPos
            end 
            if self.curStep<=self.portMax or self.curStep>15 then
                local selectSpPos = ccp(self.selectSp:getPositionX(),self.selectSp:getPositionY()) 
                arrowPos=ccp(selectSpPos.x,selectSpPos.y-270)
                self.arrow:setRotation(180)

                if self.curStep==2 or self.curStep==3 then
                    self.arrow:setRotation(0)
                    local selectSpPos = ccp(self.selectSp:getPositionX(),self.selectSp:getPositionY()) 
                    arrowPos=ccp(selectSpPos.x,selectSpPos.y+170)
                end

                
                arrowPos.y=arrowPos.y+100/2
            end            

            if guidCfg and guidCfg.arrowDirect==1 then  --下
                arrowPos.y=arrowPos.y-100/2
            elseif guidCfg and guidCfg.arrowDirect==2 then  --上
                arrowPos.y=arrowPos.y+100/2
            elseif guidCfg and guidCfg.arrowDirect==3 then  --右上
                arrowPos.x=arrowPos.x+80/2
                arrowPos.y=arrowPos.y+80/2
            end
            self.arrow:setPosition(arrowPos)
            local function showArrowAction()
                local aimPos
                if guidCfg and guidCfg.arrowDirect==1 then  --下
                    aimPos=ccp(arrowPos.x,arrowPos.y-100/2)
                    self.arrow:setRotation(0)
                elseif guidCfg and guidCfg.arrowDirect==2 then  --上
                    aimPos=ccp(arrowPos.x,arrowPos.y+100/2)
                    self.arrow:setRotation(180)
                elseif guidCfg and guidCfg.arrowDirect==3 then  --右上
                    aimPos=ccp(arrowPos.x+80/2,arrowPos.y+80/2)
                    self.arrow:setRotation(-135)
                end
                if guidCfg and guidCfg.clickRect~=nil then
                    self.arrow:setVisible(true)
                end
                if self:isShowGuide() then
                    aimPos=ccp(arrowPos.x,arrowPos.y+100/2)
                    self.arrow:setRotation(180)
                    self.arrow:setVisible(true)
                end

                if self.curStep==2 or self.curStep==3 then
                    self.arrow:setRotation(0)
                end

                local mvTo=CCMoveTo:create(0.35,aimPos)
                local mvBack=CCMoveTo:create(0.35,arrowPos)
                local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
                self.arrow:runAction(CCRepeatForever:create(seq))
            end
            local fadeIn=CCFadeIn:create(0.3)
            self.arrow:setOpacity(0)
            local ffunc=CCCallFuncN:create(showArrowAction)
            local fseq=CCSequence:createWithTwoActions(fadeIn,ffunc)
            self.arrow:runAction(fseq)
        end
        if self.guidLabel~=nil then
            self.guidLabel:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.guidLabel:setOpacity(0)
            self.guidLabel:runAction(fadeIn)
        end 
        if self.selectSp~=nil then
            local function sdHandler()
                if self.cLayer then
                    self.cLayer:removeFromParentAndCleanup(true)
                    self.cLayer=nil
                end
                local fadeOut=CCTintTo:create(0.5,150,150,150)
                local fadeIn=CCTintTo:create(0.5,255,255,255)
                local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
                self.selectSp:runAction(CCRepeatForever:create(seq))
            end
            self.selectSp:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            local calFunc=CCCallFuncN:create(sdHandler)
            local fseq=CCSequence:createWithTwoActions(fadeIn,calFunc)
            self.selectSp:setOpacity(0)
            self.selectSp:runAction(fseq)
        end
        if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
            self.closeBtn:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.closeBtn:setOpacity(0)
            self.closeBtn:runAction(fadeIn)
        end
        if guidCfg and guidCfg.clickRect~=nil then
            --self.bgLayer:setNoSallowArea(guidCfg.clickRect)
        end
    end
    local time = 1
    if guidCfg and guidCfg.delayTime then
     time=(guidCfg.delayTime==nil and 1 or guidCfg.delayTime)
    end

    local delay=CCDelayTime:create(time)
    local ffunc=CCCallFuncN:create(showP)
    local fseq=CCSequence:createWithTwoActions(delay,ffunc)
    self.panel:runAction(fseq)
end

function phasedGuideMgr:getCurInsideStep()
    local curStep = 0
    local dataKey="phasedGuideInside@"..tostring(playerVoApi:getUid())
    local dataStr=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if dataStr=="" then
        curStep=0
    else
        local phasedGuideTb=G_Json.decode(dataStr)
        curStep=phasedGuideTb.step
    end
    return curStep
end

function phasedGuideMgr:setInsideCurStep(step)
    local phasedGuideTb= {
    step=self.curStep,
    uid=playerVoApi:getUid()
    }
    local dataKey="phasedGuideInside@"..tostring(playerVoApi:getUid())
    local phasedGuideTbStr=G_Json.encode(phasedGuideTb)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,phasedGuideTbStr)
    CCUserDefault:sharedUserDefault():flush()
end

function phasedGuideMgr:insidePanel(id)
  
    local function tmpFunc()
        
    end
    if self.insideBgLayer==nil then

        self.insideBgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
        self.insideBgLayer:setAnchorPoint(ccp(0.5,0.5))
        self.insideBgLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.insideBgLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.insideBgLayer:setTouchPriority(-620)
        self.insideBgLayer:setIsSallow(true)
        self.insideBgLayer:setOpacity(100)
        sceneGame:addChild(self.insideBgLayer,8) --背景透明遮挡层，第7层

        
         
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        self.insideSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
        self.insideSprie:setContentSize(CCSizeMake(G_VisibleSize.width-80,260))
        self.insideSprie:ignoreAnchorPointForPosition(false);
        self.insideSprie:setPosition(ccp(80,20))
        self.insideSprie:setAnchorPoint(ccp(0,0));
        self.insideSprie:setTouchPriority(0)

        self.insideGn=CCSprite:createWithSpriteFrameName("NewCharacter02.png") --姑娘
        self.insideGn:setAnchorPoint(ccp(0,0))
        self.insideGn:setPosition(ccp(-120,-26))
        self.insideGn:setFlipX(true)
        self.insideGn:setScale(1.3)
        self.insideSprie:addChild(self.insideGn,2)
        
        self.insideGuidLabel=GetTTFLabelWrap("",25,CCSize(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.insideGuidLabel:setAnchorPoint(ccp(0,0.5))
        self.insideGuidLabel:setPosition(ccp(190,self.insideSprie:getContentSize().height/2+30))
        self.insideSprie:addChild(self.insideGuidLabel) --添加文本框


        local function onConfirmSell()
            self.insideBgLayer:removeFromParentAndCleanup(true)
            self.insideBgLayer=nil

        end
        local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirmSell,nil,getlocal("confirm"),25)
        local okBtn=CCMenu:createWithItem(okItem)
        okBtn:setTouchPriority(-621)
        okItem:setAnchorPoint(ccp(1,0))
        okBtn:setPosition(ccp(self.insideSprie:getContentSize().width-10,10))
        self.insideSprie:addChild(okBtn)
        okItem:setScale(0.8)

        self.insideBgLayer:addChild(self.insideSprie)

        self.insideGuidLabel:setString(getlocal("phased_guide_tip_"..id))

    end

end

function phasedGuideMgr:toNextStep(nextId)
    touchScene:setNormal()
    if self.bgLayer~=nil then
        --self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
    end
    local nextStep
    if nextId~=nil then
        nextStep=nextId
    elseif(self.curStep) and phasedGuideCfg[self.curStep] then
        nextStep=phasedGuideCfg[self.curStep].toStepId
    elseif self:isShowGuide() then
        nextStep=nil
    end
    if(nextStep==nil or nextStep=="")then
        self:endNewGuid()
    else
        self:showGuide(nextStep)
    end
end

function phasedGuideMgr:endNewGuid()
    if self.bgLayer~=nil then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    if(self.waitingForGuideTb[1])then
        table.remove(self.waitingForGuideTb,1)
    end

    local function callBack()
        self.isGuiding=false
    end
    local callFunc=CCCallFunc:create(callBack)
    local delay=CCDelayTime:create(3)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    sceneGame:runAction(seq)

    
    self.selectSp=nil
    self.panel=nil
    self.arrow=nil
    self.guidLabel=nil
    self.closeBtn=nil
    self.headerSprie=nil
    self.gn=nil
    self.dArrowSp=nil
end

function phasedGuideMgr:clear()
    if(self.eventListener~=nil)then
        for k,v in pairs(phasedGuideCfg) do
            if(v.event and v.event~="")then
                eventDispatcher:removeEventListener(v.event,self.eventListener)
            end
        end
    end
    self.hasInit=false
    self.curStep=nil
    self.bgLayer=nil
    self.bgLayer1=nil
    self.panel=nil
    self.arrow=nil
    self.guidLabel=nil
    self.isGuiding=false
    self.selectSp=nil
    self.closeBtn=nil
    self.dArrowSp=nil
    self.isTextGoing=false
    self.fastTickNum=0
    self.eventListener=nil
    self.insideBgLayer=nil
    self.waitingForGuideTb={}
    self.eventStepTb={}
    self.checkGuideTb={}
end
