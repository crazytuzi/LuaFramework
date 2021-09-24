require "luascript/script/game/gamemodel/building/buildingVo"
require "luascript/script/game/gamemodel/building/buildingVoApi"
require "luascript/script/game/scene/building/baseBuilding"
mainLandScene={
    clayer,
    sceneSp,
    touchArr={},
    multTouch=false,
    firstOldPos,
    secondOldPos,
    startPos=ccp(0,120),
    topPos=ccp(0,-145),
    minScale=1,
    maxScale=1.5,
    isMoving=false,
    isZooming=false,
    autoMoveAddPos,
    zoomMidPosForWorld,
    zoomMidPosForSceneSp,
    touchEnable=true,
    isMoved=false,
    isShowed=false,
    portSp,
    mainLandBuilds={},
    savePoint,
    portSpPoint=ccp(875,830),
    lastShowCloudTime=0,
    nextShowCloudTime=0, 
    hideBuildLvTip=false,
    lastShowBirdTime=0,
    nextShowBirdTime=0,
    lastTouchDownPoint=ccp(0,0),
    
    mapMoveDisPos=ccp(0,0),

    startDeaccleary=false,
}
--convertToWorldSpace
--convertToNodeSpace
--ccpMidpoint
function mainLandScene:show()
    --加载资源
    self.isShowed=true
    -- if G_isIphone5()==true then
    --    self.minScale=1 
    -- end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.startPos,self.topPos=ccp(0,120), ccp(0, -145)
    else
        self.startPos,self.topPos=ccp(0,94), ccp(0,-108)
    end

    self.clayer=CCLayer:create()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    self.sceneSp=CCSprite:create("scene/outskirtMap_mi.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.mapSize=self.sceneSp:getContentSize()
    self.sceneSp:setAnchorPoint(ccp(0,0))
    self.sceneSp:setPosition(ccp(0,0))
    self.clayer:addChild(self.sceneSp,1)

    self.clayer:setContentSize(self.sceneSp:getContentSize())
    sceneGame:addChild(self.clayer)
    self.clayer:setTouchEnabled(true)
    self.curScale=1.25 -- self.minScale
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-1,false)

    self:focusOnCenter()
    self:initBuilds()
    self.sceneSp:setScale(self.curScale)
    self.clayer:setTouchPriority(-2)
    self.clayer:setPosition(0,G_VisibleSize.height-self.mapSize.height*self.curScale+self.topPos.y)

    --老版主基地
    local function clickPort(...)
        if self.isMoved==true or self.touchEnable==false then
              do
                return
              end
        end
        if newGuidMgr:isNewGuiding()==true and newGuidMgr.curStep~=30 then
              do
                return
              end
        end
        PlayEffect(audioCfg.mouseClick)
        if math.abs(G_getCurDeviceMillTime()-base.setWaitTime)<=500 then
              do
                    return
              end
        end
        base:setWait()
        local fadeOut=CCTintTo:create(0.3,80,80,80)
        local fadeIn=CCTintTo:create(0.3,255,255,255)
        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
        self.portSp:runAction(seq)

        local winterSkin = nil
        if G_isOpenWinterSkin and self.portSp:getChildByTag(1124) then
            -- winterSkin = tolua.cast(self.portSp:getChildByTag(1124),"CCSprite")
            -- local fadeOut=CCTintTo:create(0.3,80,80,80)
            -- local fadeIn=CCTintTo:create(0.3,255,255,255)
            -- local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
            -- winterSkin:runAction(seq)
        end

        local delayAction=CCDelayTime:create(0.6)
        local function callBack()
             if G_phasedGuideOnOff() then
                 if phasedGuideMgr.isInsideGuiding then
                    base:cancleWait()
                    do return end
                 end
             end
             mainUI:changeToMyPort()
             base:cancleWait()
             
             if newGuidMgr:isNewGuiding() and newGuidMgr.curStep==30 then --新手引导跳转下一步
                  newGuidMgr:toNextStep()
             end
        end
        local callFunc=CCCallFunc:create(callBack)
        local seq2=CCSequence:createWithTwoActions(delayAction,callFunc)
        self.portSp:runAction(seq2)   
    end
    self.portSp=LuaCCSprite:createWithSpriteFrameName("m_signpost2.png",clickPort)
    -- if platCfg.platUseUIWindow[G_curPlatName()]~=nil and platCfg.platUseUIWindow[G_curPlatName()]==2 then
    --     self.portSpPoint=ccp(700,543)
    -- end
    self.portSp:setPosition(self.portSpPoint)
    self.portSp:setTouchPriority(1)
    self.portSp:setScale(1.3)
    self.portSp:setIsSallow(true)
    self.sceneSp:addChild(self.portSp,base:getBuildingOrderIDByBid(self.portSpPoint.y))

    G_statisticsAuditRecord(AuditOp.UMLAND) --记录进入郊区    
end

function mainLandScene:touchEvent(fn,x,y,touch)
    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 or newGuidMgr:isNewGuiding()==true then
             return 0
        end
        self.startDeaccleary=false

        self.isMoved=false
        self.touchArr[touch]=touch
        local touchIndex=0
        for k,v in pairs(self.touchArr) do
            local temTouch= tolua.cast(v,"CCTouch")
            if touchIndex==0 then
                 self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
            else
                 self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
            end
            touchIndex=touchIndex+1
        end
        if touchIndex==1 then
            self.secondOldPos=nil
            self.lastTouchDownPoint=self.firstOldPos
        end
        if SizeOfTable(self.touchArr)>1 then
            self.multTouch=true
        else
            self.multTouch=false
        end
        return 1
    elseif fn=="moved" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
             do
                return
             end
        end
        self.isMoved=true
        if self.hideBuildLvTip==false then
            self.hideBuildLvTip=true
            self:buildLvTipController(false)
        end
        if self.multTouch==true then --双点触摸
             self.zoomMidPosForSceneSp=self.sceneSp:convertToNodeSpace(ccpMidpoint(self.firstOldPos,self.secondOldPos))
             self.zoomMidPosForWorld=ccpMidpoint(self.firstOldPos,self.secondOldPos)
             local beforeZoomDis=ccpDistance(self.firstOldPos,self.secondOldPos)
             local pIndex=0
             local curFirstPos
             local curSecondPos
             for  k,v in pairs(self.touchArr) do
                 if v==touch then
                      if pIndex==0 then
                            curFirstPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                      else 
                            curSecondPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                      end
                      do
                          break
                      end
                 end
                 pIndex=pIndex+1
             end
             local afterZoomDis
             if curFirstPos~=nil then
                afterZoomDis=ccpDistance(curFirstPos,self.secondOldPos)
                self.firstOldPos=curFirstPos
             elseif curSecondPos~=nil then
                afterZoomDis=ccpDistance(self.firstOldPos,curSecondPos)
                self.secondOldPos=curSecondPos
             end
             local subDis=0
             local sl=1
             if afterZoomDis==nil or beforeZoomDis==nil then
                   afterZoomDis=0
                   beforeZoomDis=0
             end
             if afterZoomDis>beforeZoomDis then --放大
                 subDis=afterZoomDis-beforeZoomDis  
                 sl=(subDis/200)*0.2
                 self.curScale=math.min(self.maxScale,sl+self.sceneSp:getScale())
                 self.sceneSp:setScale(self.curScale)
             else --缩小
                 subDis=afterZoomDis-beforeZoomDis  
                 sl=(subDis/200)*0.2
                 self.curScale=math.max(self.minScale,sl+self.sceneSp:getScale())
                 self.sceneSp:setScale(self.curScale)
             end
             --self.zoomMidPosForSceneSp=self.sceneSp:convertToNodeSpace(ccpMidpoint(self.firstOldPos,self.secondOldPos))
             --self.zoomMidPosForWorld=ccpMidpoint(self.firstOldPos,self.secondOldPos)
             local newPosForSceneSpToWorld=self.sceneSp:convertToWorldSpace(self.zoomMidPosForSceneSp)
             local newAddPos=ccpSub(newPosForSceneSpToWorld,self.zoomMidPosForWorld)
             local newClayerPos=ccpSub(ccp(self.clayer:getPosition()),newAddPos)
             self.clayer:setPosition(newClayerPos)
             self:checkBound()
        else --单点触摸
             local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
             local moveDisPos=ccpSub(curPos,self.firstOldPos)
             local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
             self.mapMoveDisPos=moveDisPos
             if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
                 self.isMoved=false
                 do
                    return
                 end
             end
             self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)

             local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),moveDisPos)
             self.clayer:setPosition(tmpPos)
             self:checkBound()
             self.firstOldPos=curPos
             self.isMoving=true
        end
    elseif fn=="ended" then
       if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
             do
                return
             end
       end
       if self.hideBuildLvTip==true then
            self.hideBuildLvTip=false
            self:buildLvTipController(true)
       end
       if self.touchArr[touch]~=nil then
           self.touchArr[touch]=nil
           local touchIndex=0
            for k,v in pairs(self.touchArr) do
                if touchIndex==0 then
                     self.firstOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                else
                     self.secondOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                end
                touchIndex=touchIndex+1
            end
            if touchIndex==1 then
                self.secondOldPos=nil
            end
            if SizeOfTable(self.touchArr)>1 then
                self.multTouch=true
            else
                self.multTouch=false
            end
       end
       if  self.isMoving==true then
            self.isMoving=false
            self.startDeaccleary=true
            --[[
            local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
            tmpToPos=self:checkBound(tmpToPos)

            local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
            local cceaseOut=CCEaseOut:create(ccmoveTo,3)
            self.clayer:runAction(cceaseOut)
            ]]
       end
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

function mainLandScene:fastTick()

    if self.startDeaccleary==true then --缓动减速效果
    
         self.mapMoveDisPos=ccpMult(self.mapMoveDisPos,0.85)
         
         
             local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),self.mapMoveDisPos)

             if tmpPos.x>0 then
                tmpPos.x=0
                self.mapMoveDisPos.x=0
             elseif tmpPos.x<(G_VisibleSize.width-self.mapSize.width*self.curScale) then
                tmpPos.x=(G_VisibleSize.width-self.mapSize.width*self.curScale)
                self.mapMoveDisPos.x=0
             end
             if tmpPos.y>=self.startPos.y then
                 tmpPos.y=self.startPos.y
                 self.mapMoveDisPos.y=0
             elseif tmpPos.y<(G_VisibleSize.height-self.mapSize.height*self.curScale+self.topPos.y)  then
                 tmpPos.y=G_VisibleSize.height-self.mapSize.height*self.curScale+self.topPos.y
                 self.mapMoveDisPos.y=0
             end

         
         self.clayer:setPosition(ccpAdd(ccp(self.clayer:getPosition()),self.mapMoveDisPos))
         
         if  (math.abs(self.mapMoveDisPos.x)+math.abs(self.mapMoveDisPos.y))<1 then
                self.startDeaccleary=false
         end
    end

end



function mainLandScene:checkBound(pos)

            local tmpPos
            if pos==nil then
               tmpPos= ccp(self.clayer:getPosition())
            else
               tmpPos=pos
            end
            if tmpPos.x>0 then
                tmpPos.x=0
             elseif tmpPos.x<(G_VisibleSize.width-self.mapSize.width*self.curScale) then
                tmpPos.x=G_VisibleSize.width-self.mapSize.width*self.curScale
             end
             
             if tmpPos.y>=self.startPos.y then
                 tmpPos.y=self.startPos.y
                 --1250
             elseif tmpPos.y<(G_VisibleSize.height-self.mapSize.height*self.curScale+self.topPos.y)  then
                 tmpPos.y=G_VisibleSize.height-self.mapSize.height*self.curScale+self.topPos.y
             end
             if pos==nil then
                self.clayer:setPosition(tmpPos)
             else
                return tmpPos
             end

end

function mainLandScene:focusOnCenter()
    local y=G_VisibleSize.height/2-self.mapSize.height*self.curScale/2
    local x=G_VisibleSize.width/2-self.mapSize.width*self.curScale/2
    self.clayer:setPosition(ccp(x,y))
    self:checkBound()
end

function mainLandScene:setVisible(vis)
    self.clayer:setVisible(vis)

end

function mainLandScene:removeShowTip( )
    if self.movTipBg then
        if self.movMaskBg then
            self.movMaskBg:removeFromParentAndCleanup(true)
        end
        if self.movTipBg then
            self.movTipBg:removeFromParentAndCleanup(true)
        end
        self.movTipBtn = nil
        self.movTipLb  = nil
        self.movTipBg  = nil
        self.movMaskBg = nil
        self.swapBid1  = nil
        self.swapBid2  = nil
    end

    local allBuildsVo=buildingVoApi:getHomeBuilding()
    for k,v in pairs(allBuildsVo) do
        if buildings.allBuildings[v.id] and buildings.allBuildings[v.id].movTipSp then
            buildings.allBuildings[v.id]:stopChooseAction()
        end
    end
end

function mainLandScene:showTip(tipStr,isMov,getBid)--用于移动地块使用
    if not isMov then
        self.swapBid1 = getBid
    else
        self.swapBid2 = getBid
    end
    if not self.movTipBg then
        local function removeCall()
            self:removeShowTip( )
        end
        self.movMaskBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
        self.movMaskBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        self.movMaskBg:setAnchorPoint(ccp(0,0))
        self.movMaskBg:setPosition(0,0)
        self.movMaskBg:setIsSallow(false)
        self.movMaskBg:setOpacity(50)
        sceneGame:addChild(self.movMaskBg,98)

        ----------------------------------其他所有按钮的遮罩层-------------------------------
        local lNum,rNum,tNum = 1,0,0
        for i=1,20 do
            if mainUI.m_leftIconTab["icon"..i] then
                lNum = lNum +1
            end
        end
        for k,v in pairs(mainUI.m_luaSpTab) do
            rNum = rNum + 1
        end
        for i=1,20 do
            if mainUI.m_rightTopIconTab["icon"..i] then
                tNum = tNum + 1
            end
        end
        -- print("lNum---rNum----tNum--->>>>>",lNum,rNum,tNum)
        local anchorTb = {ccp(0.5,1),ccp(0.5,0),ccp(0,1),ccp(1,1)}
        local posTb = {ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight),ccp(G_VisibleSizeWidth * 0.5,0),ccp(0,G_VisibleSizeHeight - 150),ccp(G_VisibleSizeWidth,G_VisibleSizeHeight - 150)}
        local sizeTb = {CCSizeMake(G_VisibleSizeWidth,150),CCSizeMake(G_VisibleSizeWidth,180),
                        CCSizeMake(100 * mainUI.m_iconScaleX,100 * mainUI.m_iconScaleY * lNum),
                        CCSizeMake(100 * mainUI.m_iconScaleX,100 * mainUI.m_iconScaleY * rNum),
                        }
        local useLoop = 4
        if tNum > 0 then
            useLoop = useLoop + 1
            table.insert(anchorTb,ccp(1,1))
            table.insert(posTb,ccp(G_VisibleSizeWidth - 100 * mainUI.m_iconScaleX,G_VisibleSizeHeight - 150))
            table.insert(sizeTb,CCSizeMake(100 * mainUI.m_iconScaleX * tNum + 20 * tNum,100 * mainUI.m_iconScaleY))
        end
        if taskVoApi:getMainTask() then
            -- useLoop = useLoop + 1
            -- table.insert(anchorTb,ccp(0.5,0))
            -- table.insert(posTb,ccp(G_VisibleSizeWidth * 0.5,180))
            -- table.insert(sizeTb,CCSizeMake(G_VisibleSizeWidth,75))
        end

        for i=1,useLoop do
            local movMaskBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),removeCall)
            movMaskBg:setContentSize(sizeTb[i])
            movMaskBg:setAnchorPoint(anchorTb[i])
            movMaskBg:setPosition(posTb[i])
            movMaskBg:setOpacity(0)
            movMaskBg:setTouchPriority(-30)
            movMaskBg:setIsSallow(true)
            self.movMaskBg:addChild(movMaskBg,98)
        end
        ------------------------------------------------end---------------------------------------------
        self.movTipBg =LuaCCScale9Sprite:createWithSpriteFrameName("GuideNewPanel.png",CCRect(20, 20, 10, 10),function()end)
        self.movTipBg:setContentSize(CCSizeMake(G_VisibleSize.width-4,130))
        -- self.movTipBg:ignoreAnchorPointForPosition(false);
        self.movTipBg:setAnchorPoint(ccp(0,0));
        self.movTipBg:setTouchPriority(-998)--领奖中心是 -24
        self.movTipBg:setIsSallow(true)
        self.movTipBg:setPosition(5,122)
        sceneGame:addChild(self.movTipBg,99)

        local function closeBtnHandler()
            print("退出~~~~~~~~~")
            self:removeShowTip()
        end
        self.movTipBtn= LuaCCSprite:createWithSpriteFrameName("GuideNewClose.png",closeBtnHandler)--GuideClose
        self.movTipBtn:setPosition(self.movTipBg:getContentSize().width - self.movTipBtn:getContentSize().width * 0.5,self.movTipBg:getContentSize().height+self.movTipBtn:getContentSize().height * 0.5 - 3)
        self.movTipBtn:setIsSallow(true)
        self.movTipBtn:setTouchPriority(-322)

        self.movTipBg:addChild(self.movTipBtn)
    end
    if not self.movTipLb then
        self.movTipLb=GetTTFLabelWrap(tipStr,25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.movTipLb:setAnchorPoint(ccp(0,0.5))
        self.movTipLb:setPosition(ccp(20,self.movTipBg:getContentSize().height * 0.5))
        self.movTipBg:addChild(self.movTipLb) --添加文本框
    else
        self.movTipLb:setString(tipStr)
    end
    
    if isMov then
        -- 请求换位置
        local function swapCall()
            print("swap??????????????",self.swapBid1,self.swapBid2)
            local function socketSwapCall(fn,data)
                 local ret,sData=base:checkServerData(data)
                 if ret==true then
                    local swapBid1,swapBid2 = self.swapBid1,self.swapBid2
                    self:removeShowTip()

                    self.swapParticleTb1 = {}
                    self.swapParticleTb2 = {}
                    local _posX,_posY=homeCfg:getBuildingPosById(swapBid1)
                    local _posX2,_posY2=homeCfg:getBuildingPosById(swapBid2)
                    _posX=_posX+10
                    _posY=_posY+15
                    _posX2=_posX2+10
                    _posY2=_posY2+15
                    local addPosy = {[1]=-10,[2]=0,[3]=20,[4]=15,[5]=15,[6]=15}
                    for i=1,6 do
                        self.swapParticleTb1[i] = CCParticleSystemQuad:create("scene/swapEffect/particle_0"..i..".plist")
                        self.swapParticleTb1[i].positionType = kCCPositionTypeFree
                        self.swapParticleTb1[i]:setPosition(ccp(_posX,_posY + addPosy[i]))
                        self.sceneSp:addChild(self.swapParticleTb1[i],base:getBuildingOrderIDByBid(_posY)+999)

                        self.swapParticleTb2[i] = CCParticleSystemQuad:create("scene/swapEffect/particle_0"..i..".plist")
                        self.swapParticleTb2[i].positionType = kCCPositionTypeFree
                        self.swapParticleTb2[i]:setPosition(ccp(_posX2,_posY2 + addPosy[i]))
                        self.sceneSp:addChild(self.swapParticleTb2[i],base:getBuildingOrderIDByBid(_posY2)+999)
                    end

                    buildings:upgrade(swapBid1,true)
                    buildings:upgrade(swapBid2,true)
                 end
             end
             socketHelper:swapHomeBuilding(self.swapBid1,self.swapBid2,socketSwapCall)    
        end 
        local swapBuildingItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",swapCall,nil,getlocal("movStr"),33,100)
        swapBuildingItem:setScale(0.6)
        swapBuildingItem:setAnchorPoint(ccp(1,0))
        local swapBuildingMenu=CCMenu:createWithItem(swapBuildingItem);
        swapBuildingMenu:setPosition(ccp(self.movTipBg:getContentSize().width - 5,5))
        swapBuildingMenu:setTouchPriority(-999);
        self.movTipBg:addChild(swapBuildingMenu)
    end
end

function mainLandScene:initBuilds()
    local allBuildsVo=buildingVoApi:getHomeBuilding()
    for k,v in pairs(allBuildsVo) do
            -- print("v.id-----initbuilds->>>>",v.id)
            if buildings.allBuildings[v.id]==nil then
                -- print(" init 11111111111111111")
                local tmpBuild=baseBuilding:new(v.id)
                buildings.allBuildings[v.id]=tmpBuild
                tmpBuild:show(self)
                --self.mainLandBuilds[v.id]=tmpBuild
            elseif buildings.allBuildings[v.id]:getNeedChange()   then --已经建造过了但是需要换图片
                -- print(" init 222222222222222222")
                --buildings.allBuildings[v.id]:show(self,true) 
            end
    end 
end

function mainLandScene:tick()
    self:initBuilds()
    if self.lastShowCloudTime==0 then
            self.lastShowCloudTime=base.serverTime
            self.nextShowCloudTime=base.serverTime+math.ceil(60+(deviceHelper:getRandom()/100)*60)

    end
    --[[
    if self.nextShowCloudTime<=base.serverTime then
         self:showCloud()
         self.lastShowCloudTime=base.serverTime
         self.nextShowCloudTime=base.serverTime+math.ceil(60+(deviceHelper:getRandom()/100)*60)
    end
    ]]
    local runFirst=false
    if self.lastShowBirdTime==0 then
            runFirst=true
            self.lastShowBirdTime=base.serverTime
            self.nextShowBirdTime=base.serverTime+math.ceil(30+(deviceHelper:getRandom()/100)*60)

    end
    if self.nextShowBirdTime<=base.serverTime or runFirst then
         local direct=1
         if  deviceHelper:getRandom()%2==0 then
                direct=2
         end
         for i=1,math.ceil((deviceHelper:getRandom()/100)*6) do
             self:showBirds(direct)
         end

         self.lastShowBirdTime=base.serverTime
         self.nextShowBirdTime=base.serverTime+math.ceil(30+(deviceHelper:getRandom()/100)*60)
    end

end

function mainLandScene:addBuild(bvo)
end

function mainLandScene:setShow()
    if self.clayer==nil then
        self:show()
        if G_isApplyVersion() == true then
            G_setShaderProgramAllChildren(self.clayer, function(ccNode)
                CCShader:setShaderProgram(ccNode, "kShader_ApplyVersion_HSL")
            end)
        end
    end
    self.touchEnable=true
        self.isMoved=false 
    self.clayer:setVisible(true)
    if self.savePoint~=nil then
        self.clayer:setPosition(self.savePoint)
        self.savePoint=nil
    end
end

function mainLandScene:setHide()
    if self.clayer~=nil then
        self.touchArr=nil
        self.touchArr={}
        self.touchEnable=false
        self.clayer:setVisible(false)
        if self.savePoint==nil then
            self.savePoint=ccp(self.clayer:getPosition())
            self.clayer:setPosition(ccp(-10000,10000))
        end
    end
end

function mainLandScene:showCloud()
    
   local shadowPos=ccp(-300,-300+math.random()*700)
   local spPos=ccp(-300,shadowPos.y+400)
   local yunIndex=math.ceil(math.random()*5)
   local cloudSp= CCSprite:createWithSpriteFrameName("yunduo_"..yunIndex.."_body.png")
   cloudSp:setScale(1)
   cloudSp:setOpacity(200)
   local cloudSp2= CCSprite:createWithSpriteFrameName("yunduo_"..yunIndex.."_shadow.png")
   cloudSp2:setScale(1)
   cloudSp:setPosition(spPos)
   cloudSp2:setPosition(shadowPos)
   local mvTo=CCMoveTo:create(100,ccp(2000,shadowPos.y+800))
   local mvTo2=CCMoveTo:create(100,ccp(2000,shadowPos.y+400))
   local function spCallBack()
        cloudSp:removeFromParentAndCleanup(true)
   end
   local function spCallBack2()
        cloudSp2:removeFromParentAndCleanup(true)
   end
   local funcHandler=CCCallFunc:create(spCallBack)
   local funcHandler2=CCCallFunc:create(spCallBack2)
   local seq=CCSequence:createWithTwoActions(mvTo,funcHandler)
   local seq2=CCSequence:createWithTwoActions(mvTo2,funcHandler2)
   cloudSp:runAction(seq)
   cloudSp2:runAction(seq2)
   self.sceneSp:addChild(cloudSp,101)
   self.sceneSp:addChild(cloudSp2,100)
end

function mainLandScene:showBirds(direct)

   local birdsPos
   local AimPos=ccp(0,0)
   if direct==2 then
        birdsPos=ccp(-100-deviceHelper:getRandom()*4,10+deviceHelper:getRandom()*9)

        AimPos.y=math.sin(math.rad(20))*3000+birdsPos.y
        AimPos.x=math.cos(math.rad(20))*3000+birdsPos.x
   else
        birdsPos=ccp(2000+deviceHelper:getRandom()*4,1000+deviceHelper:getRandom()*9)
        AimPos.y=math.sin(math.rad(200))*3000+birdsPos.y
        AimPos.x=math.cos(math.rad(200))*3000+birdsPos.x
   end
   



   local stIndex=math.ceil((deviceHelper:getRandom()/100)*11)

   if stIndex>=11 then
      stIndex=10
   end
   if stIndex==0 then
      stIndex=1
   end
   local birdSp=CCSprite:createWithSpriteFrameName("bird_"..direct.."_"..stIndex..".png")

   local animArr=CCArray:create()
   
     for kk=stIndex+1,11 do
        
        local nameStr="bird_"..direct.."_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        animArr:addObject(frame)
     end
     for kk=1,stIndex do
        local nameStr="bird_"..direct.."_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        animArr:addObject(frame)
     end
     birdSp:setPosition(birdsPos)

     local mvTo=CCMoveTo:create(60,AimPos)
     local function spCallBack()
        birdSp:stopAllActions()
        birdSp:removeFromParentAndCleanup(true)
     end
     local funcHandler=CCCallFunc:create(spCallBack)
     
     self.sceneSp:addChild(birdSp,101)
     
     local animation=CCAnimation:createWithSpriteFrames(animArr)
     animation:setDelayPerUnit(0.1)
     local animate=CCAnimate:create(animation)
     local repeatForever=CCRepeatForever:create(animate)
     local seq=CCSequence:createWithTwoActions(mvTo,funcHandler)   
     birdSp:runAction(seq)
     birdSp:runAction(repeatForever)
end


function mainLandScene:buildLvTipController(disPlay)
    local numKey = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_buildingDisplay")
    if numKey==2 or numKey==0 then
         for k,v in pairs(buildings.allBuildings) do
             if v.nameTip~=nil then
                  if disPlay==true then
                      v.nameTip:setVisible(true)
                      v.nameLb:setVisible(true)
                  else
                      v.nameTip:setVisible(false)
                      v.nameLb:setVisible(false)
                  end
             end
        end
    else
         for k,v in pairs(buildings.allBuildings) do
             if v.lvTip~=nil then
                  if disPlay==true then
                      v.lvTip:setVisible(true)
                  else
                      v.lvTip:setVisible(false)
                  end
             end
        end
    end
end

function mainLandScene:actionUseInNewGuildMgr( )
    local x,y,width,height=G_getSpriteWorldPosAndSize(self.portSp)
    local offsetx,offsety = G_VisibleSizeWidth/2-x,G_VisibleSizeHeight/2-y
    x,y = self.clayer:getPositionX()+offsetx,self.clayer:getPositionY()+offsety
    self.clayer:setPosition(ccp(x,y))
    self:checkBound()
end
function mainLandScene:dispose()
    self.clayer=nil
    self.sceneSp=nil
    self.touchArr=nil
    self.touchArr={}
    self.multTouch=false
    self.firstOldPos=nil
    self.secondOldPos=nil
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.startPos=ccp(0,120)
        self.topPos=ccp(0,-145)
    else
        self.startPos=ccp(0,96)
        self.topPos=ccp(0,-110)
    end
    self.minScale=1.0
    self.maxScale=1.5
    self.curScale=1.25
    self.isMoving=false
    self.isZooming=false
    self.autoMoveAddPos=nil
    self.zoomMidPosForWorld=nil
    self.zoomMidPosForSceneSp=nil
    self.touchEnable=true
    self.isMoved=false
    self.isShowed=false
    self.portSp=nil
    self.mainLandBuilds={}
    self.savePoint=nil
    self.hideBuildLvTip=false
    self.movTipBg=nil
    self.movTipLb=nil
    self.movTipBtn=nil
    self.movMaskBg=nil
    self.swapBid1=nil
    self.swapBid2=nil
    --self.portSpPoint=ccp(688,544)
end