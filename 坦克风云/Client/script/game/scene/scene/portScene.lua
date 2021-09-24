portScene={
    clayer,
    sceneSp,
    touchArr={},
    multTouch=false,
    firstOldPos,
    secondOldPos,
    startPos=ccp(0,125),
    topPos=ccp(0,-140),
    minScale=0.75,
    curScale=0.75,
    maxScale=1.3,
    isMoving=false,
    isZooming=false,
    autoMoveAddPos,
    zoomMidPosForWorld,
    zoomMidPosForSceneSp,
    touchEnable=true,
    isMoved=false,
    tanksSpTab={},
    lastShowCloudTime=0,
    nextShowCloudTime=0,
    hideBuildLvTip=false, 
    
    lastShowBirdTime=0,
    nextShowBirdTime=0,
    
    nextShowCarTime=0,
    lastTouchDownPoint=ccp(0,0),
    
    mapMoveDisPos=ccp(0,0),

    startDeaccleary=false,
    
    copterBody = nil,
}

--convertToWorldSpace
--convertToNodeSpace
--ccpMidpoint
function portScene:show()
    --加载资源
    spriteController:addPlist("scene/homeMap_newImage.plist")
    spriteController:addTexture("scene/homeMap_newImage.png")
    spriteController:addPlist("public/warStatue/warStatueBuilding.plist")
    spriteController:addTexture("public/warStatue/warStatueBuilding.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/mainCityTankImage.plist")
    if G_getGameUIVer()==2 then
        self.startPos=ccp(0,94)
        self.topPos=ccp(0,-108)
    end
    if G_phasedGuideOnOff() then
        touchScene:show()
    end
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.startPos,self.topPos=ccp(0,125), ccp(0, -140)
    else
        self.startPos,self.topPos=ccp(0,94), ccp(0,-108)
    end
    self.clayer=CCLayer:create()
    self.sceneSp = CCSprite:createWithSpriteFrameName("homeMap_new_1.png")
    self.sceneSp:setAnchorPoint(ccp(0,0))
    self.sceneSp:setPosition(ccp(0,0))
    self.clayer:addChild(self.sceneSp,1)
    self.mapSize=CCSizeMake(2744,1483)--self.sceneSp:getContentSize()
    self.addMapTb = {}
    self.addMapTb[1] = self.sceneSp
    for i=2,5 do
        local addMap = CCSprite:createWithSpriteFrameName("homeMap_new_"..i..".png")
        self.addMapTb[i] = addMap
        addMap:setAnchorPoint(ccp(0,1))
        if i < 4 then
            addMap:setPosition(self.addMapTb[i - 1]:getContentSize().width - 1,self.addMapTb[i - 1]:getContentSize().height)
        else
            addMap:setPosition(-1,1)
        end
        self.addMapTb[i - 1]:addChild(addMap)
    end
    self.clayer:setContentSize(self.mapSize)

     --mapskin ={ 地图地址名称，size,pos,anchorPoint,parent }
    -- if buildingSkinAddress and (buildingSkinAddress["mapSkin"][1][3] ==nil or buildingSkinAddress["mapSkin"][1][3]:getChildByTag(1124) == nil) then
    --     --{1:clayer,2:size,3:oldSp,4:oldRealSp,5:newRealSpscale,6:newSpScale}
    --     local op = realMapSp:getOpacity()
    --     buildingSkinAddress["mapSkin"][1] = {self.clayer,mapSize,self.sceneSp,realMapSp,1.4482,self.minScale,op}
    -- end

    sceneGame:addChild(self.clayer,1)
    self.clayer:setTouchEnabled(true)
    self.curScale=self.minScale
    self.sceneSp:setScale(self.curScale)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end

    self.clayer:registerScriptTouchHandler(tmpHandler,false,-1,false)

    self.clayer:setTouchPriority(-1)
    self:focusOnCenter()
    self:initBuilds()
    self:initTanks()
    self:showWater()
    self:initBlockingPic()
    self:showSoldier()
    self:showSoldier2()
    self:showRunTank()
    self:showTruckAndSUV()
    self:initBuildingModel()
    --[[
    if newGuidMgr:isNewGuiding()==true then
        self.clayer:setPosition(ccp(-650,-20))
    else
        self.clayer:setPosition(ccp(-450,-20))
    end]]
    self.clayer:setPosition(ccp(-820,80))
    -- self.clayer:setPosition(ccp(-450,-20))
    self:showVerticraft()

    --世界争霸冠军建筑
    if base.worldWarChampion then
        if type(base.worldWarChampion)=="table" and SizeOfTable(base.worldWarChampion)>0 then
            self:initWorldWarChampionBuilding()
        end
    end

    -- --添加一些地表
    -- for k,v in pairs(homeCfg.homeFloorCfg) do
    --     local floorSp=CCSprite:createWithSpriteFrameName(v.pic)
    --     floorSp:setPosition(v.pos[1],v.pos[2])
    --     floorSp:setScale((v.scale or 1))
    --     self.sceneSp:addChild(floorSp,(v.zorder or 0))
    -- end
end

function portScene:initWorldWarChampionBuilding()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWarCommon.plist")
    if self.sceneSp then
        local function clickFunc2()
            
        end
        local function clickFunc(object,fn,tag)
            base:setWait()
            local fadeOut=CCTintTo:create(0.3,80,80,80)
            local fadeIn=CCTintTo:create(0.3,255,255,255)
            local function callBack()
                if base.worldWarChampion then
                    smallDialog:showWorldWarChampionDialog("TankInforPanel.png",CCSizeMake(550,350),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,3)
                end
                base:cancleWait()
            end
            local callFunc=CCCallFunc:create(callBack)
            local arr=CCArray:create()
            arr:addObject(fadeOut)
            arr:addObject(fadeIn)
            arr:addObject(callFunc)
            local seq=CCSequence:create(arr)
            self.championSp:runAction(seq)
        end
        -- self.championSp=LuaCCSprite:createWithFileName("worldWar/ww_championBuilding.png",clickFunc)
        self.championSp=LuaCCSprite:createWithSpriteFrameName("ww_championBuilding2.png",clickFunc2)
        local bx,by=homeCfg:getChampionBuildingPos()
        -- if G_isShowNewMapAndBuildings()==1 then
        --     self.championSp:setPosition(ccp(bx,by))
        -- else
            self.championSp:setPosition(ccp(bx,by))
        -- end
        self.championSp:setTouchPriority(0)
        self.championSp:setIsSallow(true)
        --指挥中心28，作战中心33，取28~33之间
        self.sceneSp:addChild(self.championSp,base:getBuildingOrderIDByBid(by) + 7)
        for i=1,7 do
            local maskSp =LuaCCSprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png",clickFunc)
            maskSp:setPosition(ccp(self.championSp:getPositionX()-(4-i)*(maskSp:getContentSize().width-6),self.championSp:getPositionY()-(4-i)*maskSp:getContentSize().height/2))
            self.sceneSp:addChild(maskSp,35)
            maskSp:setScaleY(2)
            maskSp:setVisible(false)
        end
        local maskSp2 =LuaCCSprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png",clickFunc)
        maskSp2:setPosition(ccp(self.championSp:getPositionX(),self.championSp:getPositionY()+maskSp2:getContentSize().height))
        self.sceneSp:addChild(maskSp2,35)
        maskSp2:setScaleY(2)
        maskSp2:setVisible(false)

    end
end


function portScene:touchEvent(fn,x,y,touch)
    if newGuidMgr:isNewGuiding()==true or (otherGuideMgr and otherGuideMgr.isGuiding==true) then
        self.isMoved=false
        self.startDeaccleary=false
        self.isMoving=false
        self.touchArr={}
        do return 0 end
    end
    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 or newGuidMgr:isNewGuiding()==true then
             return 0
        end
        self.startDeaccleary=false
        self.isMoved=false
        self.touchArr[touch]=touch
        local touchIndex=0
        for k,v in pairs(self.touchArr) do
            local tmpTouch=tolua.cast(v,"CCTouch")
            if tmpTouch then
                if touchIndex==0 then
                     self.firstOldPos=CCDirector:sharedDirector():convertToGL(tmpTouch:getLocationInView())
                else
                     self.secondOldPos=CCDirector:sharedDirector():convertToGL(tmpTouch:getLocationInView())
                end
                touchIndex=touchIndex+1
            end
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
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true or (otherGuideMgr and otherGuideMgr.isGuiding==true) then
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
             self.mapMoveDisPos=moveDisPos
             local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
             self.mvDisFromTouchBeginToEnd=moveDisTmp
             if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
                 self.isMoved=false
                 do
                    return
                 end
             end
             
             self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*100,(curPos.y-self.firstOldPos.y)*100)

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
            local subTime=G_getCurDeviceMillTime()-self.touchBeginTime  --单指触摸屏幕的时间
            
             local subX=self.mvDisFromTouchBeginToEnd.x-self.lastTouchDownPoint.x
             
             local speedX=subX/subTime --x轴速度
             
             print("speedX====",speedX)

            ]]
            

            --[[
            local mvx=math.floor((100000/subTime)>300 and 300 or (100000/subTime))
            
            local mvy=math.abs(math.floor((self.mvDisFromTouchBeginToEnd.y*mvx)/self.mvDisFromTouchBeginToEnd.x))
            
            if self.mvDisFromTouchBeginToEnd.x<0 then
                     mvx=-mvx
            end
            
            if self.mvDisFromTouchBeginToEnd.y<0 then
                     mvy=-mvy
            end
            ]]
            
            --[[

            local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),ccp(mvx,mvy))
            tmpToPos=self:checkBound(tmpToPos)

            local ccmoveTo=CCMoveTo:create(1,tmpToPos)
            local cceaseOut=CCEaseOut:create(ccmoveTo,3)
            self.clayer:runAction(cceaseOut)
            ]]
       end
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

function portScene:fastTick()
    if newGuidMgr:isNewGuiding()==true or (otherGuideMgr and otherGuideMgr.isGuiding==true) then
        self.startDeaccleary=false
        do return end
    end

    if self.startDeaccleary==true then --缓动减速效果
    
         self.mapMoveDisPos=ccpMult(self.mapMoveDisPos,0.85)
         
         
             local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),self.mapMoveDisPos)

             if tmpPos.x>0 then
                tmpPos.x=0
                self.mapMoveDisPos.x=0
             elseif tmpPos.x<(G_VisibleSize.width-self.mapSize.width*self.curScale) then
                tmpPos.x=G_VisibleSize.width-self.mapSize.width*self.curScale
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


function portScene:checkBound(pos)

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
             elseif tmpPos.y<(G_VisibleSize.height-self.mapSize.height*self.curScale+self.topPos.y)  then
                 tmpPos.y=G_VisibleSize.height-self.mapSize.height*self.curScale+self.topPos.y
             end
             if pos==nil then
                self.clayer:setPosition(tmpPos)
             else
                return tmpPos
             end

end

function portScene:focusOnCenter()
    local y=G_VisibleSize.height/2-self.mapSize.height*self.curScale/2
    local x=G_VisibleSize.width/2-self.mapSize.width*self.curScale/2
    y=y+100
    self.clayer:setPosition(ccp(x,y))
    self:checkBound()
end

--将建筑定位到屏幕内显示
function portScene:focusOnScreen(bid)
    local building=buildings.allBuildings[bid]
    if bid == nil and self.copterBody ~= nil then
        building={buildSp=self.copterBody}
    end
    if building and building.buildSp then
        local buildSp=building.buildSp
        if buildSp and buildSp:getParent() then
            local offestX,offestY=0,0
            local size=buildSp:getContentSize()
            local screenPos=buildSp:getParent():convertToWorldSpace(ccp(buildSp:getPosition()))
            if screenPos.x>size.width and screenPos.x<(G_VisibleSize.width-size.width) 
                and screenPos.y>(size.height+250) and screenPos.y<(G_VisibleSize.height-size.height-350) then
                --当前建筑在屏幕内
                print("当前建筑在屏幕内")
            else
                print("当前建筑不在屏幕内")
                offestX=G_VisibleSize.width/2-screenPos.x
                offestY=G_VisibleSize.height/2-screenPos.y
            end
            local x,y=self.clayer:getPosition()
            self.clayer:setPosition(x+offestX,y+offestY)
            self:checkBound()
        end
    end
end

function portScene:setShow()
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

function portScene:setHide()
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

function portScene:initTanks()
    if self.sceneSp==nil then
        -- or GM_UidCfg[playerVoApi:getUid()] then
        do
          return
        end
    end
    if self.tanksSpTab==nil then
        self.tanksSpTab={}
    end
    -- local tanksTb = tankVoApi:getAllTanksInBase()
    local tanksTb = tankVoApi:getTanksInBase()
    local newTanks={}
    for k,v in pairs(tanksTb) do
        if self.tanksSpTab[k]~=nil then --图片已经显示在地图上
            local numLb=tolua.cast(self.tanksSpTab[k]:getChildByTag(3),"CCLabelTTF")
            local lbSpBg4=tolua.cast(self.tanksSpTab[k]:getChildByTag(4),"LuaCCScale9Sprite")
            if numLb~=nil then
                numLb:setString(v[1])
                lbSpBg4:setContentSize(CCSizeMake(numLb:getContentSize().width+12,numLb:getContentSize().height+6))
            end
        else
            newTanks[k]=v
        end
    end

    for k,v in pairs(self.tanksSpTab) do
        if tanksTb[k]==nil then --删除图片
             v:removeFromParentAndCleanup(true)
             self.tanksSpTab[k]=nil
        end
    end

    for k,v in pairs(newTanks) do
        if v[1]~=0 then
            local strtank="t"..GetTankOrderByTankId(k).."_1.png"
            local strtank1="t"..GetTankOrderByTankId(k).."_1_1.png"
            if self.sceneSp:getChildByTag(k)==nil then
                local function pbUIhandler()
                    if self.isMoved==true or self.touchEnable==false then
                      do
                        return
                      end
                    end
                    tankInfoDialog:create(sceneGame,k,4)
                end
                local tankSp =LuaCCSprite:createWithSpriteFrameName(strtank,pbUIhandler)
                tankSp:setTag(k)
                tankSp:setAnchorPoint(ccp(0.5,0.5));
                if platCfg.platUseUIWindow[G_curPlatName()]~=nil and platCfg.platUseUIWindow[G_curPlatName()]==2 then
                    tankSp:setPosition(tonumber(homeCfg.tankPosition[k].homex),tonumber(homeCfg.tankPosition[k].homey))
                elseif G_isShowNewMapAndBuildings()==1 then
                    tankSp:setPosition(tonumber(homeCfg.tankPosition[k].homex),tonumber(homeCfg.tankPosition[k].homey))
                else
                    tankSp:setPosition(tonumber(homeCfg.tankPosition[k].homex),tonumber(homeCfg.tankPosition[k].homey))
                    -- tankSp:setPosition(tonumber(tankCfg[k].homex),tonumber(tankCfg[k].homey))
                end
                self.sceneSp:addChild(tankSp,base:getBuildingOrderIDByBid(tonumber(homeCfg.tankPosition[k].homey)));
                tankSp:setIsSallow(true)
                tankSp:setTouchPriority(0)
                self.tanksSpTab[k]=tankSp
                --table.insert(self.tanksSpTab,tankSp)

                if GetTankOrderByTankId(k)<=15 and GetTankOrderByTankId(k)~=33 then
                    local tankSp1=CCSprite:createWithSpriteFrameName(strtank1);
                    tankSp1:setPosition(getCenterPoint(tankSp))
                    tankSp:addChild(tankSp1)
                end
                    
                local numLb= GetTTFLabel(v[1],24);
                numLb:setAnchorPoint(ccp(0.5,0.5))
                numLb:setTag(3)
                numLb:setPosition(tankSp:getContentSize().width/2,tankSp:getContentSize().height+3)
                tankSp:addChild(numLb,3)
                
                local capInSet = CCRect(5, 5, 1, 1);
                local function touchClick()
                
                end
                local lbSpBg4 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
                lbSpBg4:setContentSize(CCSizeMake(numLb:getContentSize().width+12,numLb:getContentSize().height+6))
                lbSpBg4:setPosition(ccp(tankSp:getContentSize().width/2,tankSp:getContentSize().height+3))
                tankSp:addChild(lbSpBg4,2)
                lbSpBg4:setTouchPriority(0)
                lbSpBg4:setTag(4)
            end
        end
    end

end

function portScene:initBuilds()
    -- if GM_UidCfg[playerVoApi:getUid()] then--用于GM判断
    --     do return end
    -- end
    -- 初始化装扮
    if buildDecorateVoApi and buildDecorateVoApi.initSkinTb then
        buildDecorateVoApi:initSkinTb()
    end

    local allBuildsVo=buildingVoApi:getPortBuilding()  --buildingVoApi.allBuildings
    for k,v in pairs(allBuildsVo) do
            if buildings.allBuildings[v.id]==nil then
                local tmpBuild=baseBuilding:new(v.id)
                -- print("v.id=",v.id)
                tmpBuild:show(self)
                buildings.allBuildings[v.id]=tmpBuild
            elseif buildings.allBuildings[v.id].lastStatus~=v.status then
                buildings.allBuildings[v.id]:show(self,true)
            end
    end

end

-- -- 更换主基地的皮肤
-- function portScene:changeSkin()
--     for k,v in pairs(buildings.allBuildings) do
--         if  v:getType() == 7 then
--             local imgStr = buildDecorateVoApi:getSkinImg(1)
--             local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(imgStr)
--             if frame and tolua.cast(buildings.allBuildings[k].buildSp,"LuaCCSprite") then
--                 tolua.cast(buildings.allBuildings[k].buildSp,"LuaCCSprite"):setDisplayFrame(frame)
--             end
--         end
--     end
-- end

function portScene:tick()
    --self:initBuilds()
    buildingVoApi:getPortBuilding()
    if self.lastShowCloudTime==0 then
            self.lastShowCloudTime=base.serverTime
            self.nextShowCloudTime=base.serverTime+math.ceil(30+(deviceHelper:getRandom()/100)*30)

    end
    
    if self.nextShowCloudTime<=base.serverTime then

         local randn=math.ceil((deviceHelper:getRandom()/100)*2)
         if randn==0 then
            randn=1
         end
         for i=1,randn do
            self:showCloud()
         end
 
         self.lastShowCloudTime=base.serverTime
         self.nextShowCloudTime=base.serverTime+math.ceil(30+(deviceHelper:getRandom()/100)*30)
    end
    
    --lastShowBirdTime=0,
    --nextShowBirdTime=0,
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
         -- self.nextShowBirdTime=base.serverTime+math.ceil(30+(deviceHelper:getRandom()/500))
         self.nextShowBirdTime=base.serverTime+math.ceil(30+(deviceHelper:getRandom()/100)*60)
    end

    --显示补给商店直升飞机
    if supplyShopVoApi and supplyShopVoApi:isOpen() == true then
        self:showSupplyShopCopter()
    end
    
    -- if self.nextShowCarTime==0 then
    --     self.nextShowCarTime=base.serverTime+1
    -- end
    
    -- if self.nextShowCarTime<=base.serverTime then
    --      local direct=1
    --      if  deviceHelper:getRandom()%2==0 then
    --             direct=2
    --      end

    --     self:showCars(direct)
    --     -- self.nextShowCarTime=base.serverTime+3+math.ceil((deviceHelper:getRandom()/100)/500)
    --     self.nextShowCarTime=base.serverTime+3+math.ceil((deviceHelper:getRandom()/100)*10)
    -- end
end

function portScene:showWater()
 do
    return
 end

   local waterSp1=CCSprite:createWithSpriteFrameName("radarCar.png")
   waterSp1:setAnchorPoint(ccp(0.5,0.5))
   waterSp1:setPosition(ccp(919,709))
   self.sceneSp:addChild(waterSp1,9)

   local waterFrameName="radarCar_1.png" --喷泉效果
   local waterSp=CCSprite:createWithSpriteFrameName(waterFrameName)
   local waterArr=CCArray:create()
   for kk=1,21 do
        local nameStr="radarCar_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        waterArr:addObject(frame)
   end
   local animation=CCAnimation:createWithSpriteFrames(waterArr)
   animation:setDelayPerUnit(0.1)
   local animate=CCAnimate:create(animation)
   local repeatForever=CCRepeatForever:create(animate)
   waterSp:setAnchorPoint(ccp(0.5,0.5))
   waterSp:setPosition(ccp(919,706))
   waterSp:runAction(repeatForever)
   self.sceneSp:addChild(waterSp,10) --喷泉效果
end

function portScene:showCloud()
    
   local shadowPos=ccp(-300,50+(deviceHelper:getRandom()/100)*600)
   local spPos=ccp(-300,shadowPos.y+400)
   --local yunIndex=math.ceil(math.random()*5)
   local cloudSp= CCSprite:createWithSpriteFrameName("feiji2_1.png")
   --cloudSp:setScale(2)
   --cloudSp:setOpacity(200)
   local cloudSp2= CCSprite:createWithSpriteFrameName("feiji2_shadow_1.png")
   --cloudSp2:setScale(2)
   cloudSp:setPosition(spPos)
   cloudSp2:setPosition(shadowPos)
   local AimPos=ccp(0,0)
   AimPos.y=math.sin(math.rad(20))*2500+shadowPos.y
   AimPos.x=math.cos(math.rad(20))*2500+shadowPos.x

   local mvTo=CCMoveTo:create(5,ccp(AimPos.x,AimPos.y+400))
   local mvTo2=CCMoveTo:create(5,AimPos)
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

function portScene:showVerticraft()
    do
        return
    end
      local zsfjSP= CCSprite:createWithSpriteFrameName("feiji1_body_1.png")
   local jySp=CCSprite:createWithSpriteFrameName("feiji1_anim_1.png")

   local animArr=CCArray:create()
   
     for kk=1,4 do
        local nameStr="feiji1_anim_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        animArr:addObject(frame)
     end
     local animation=CCAnimation:createWithSpriteFrames(animArr)
     animation:setDelayPerUnit(0.1)
     local animate=CCAnimate:create(animation)
     local repeatForever=CCRepeatForever:create(animate)
     jySp:runAction(repeatForever)
     zsfjSP:addChild(jySp)
     jySp:setPosition(ccp(zsfjSP:getContentSize().width/2,zsfjSP:getContentSize().height/2))
     zsfjSP:setPosition(ccp(1080,1100))
     self.sceneSp:addChild(zsfjSP,99) 
end

function portScene:showCars(direct)
    local stPos
    local edPos
    local carIndex
    local temW = 510
    local temH = -250
    if G_isShowNewMapAndBuildings()==1 then
        temW = 540
        temH = -270
    end
    if direct==1 then--从左下到右上
        stPos = ccp(1602,925)--1549,911
        edPos = ccp(2755,1475)
        carIndex= ((math.ceil(deviceHelper:getRandom())%2==0) and 3 or 1)
    else--从右上到左下
        stPos = ccp(2760,1502)--1549,911 2360
        edPos = ccp(1586,937)
        carIndex= ((math.ceil(deviceHelper:getRandom())%2==0) and 4 or 2)
    end
    local carSp=CCSprite:createWithSpriteFrameName("car"..carIndex..".png")
    carSp:setPosition(stPos)
    if direct==1 then
        self.sceneSp:addChild(carSp,2)
    else
        self.sceneSp:addChild(carSp,1)
    end
    local mvTo=CCMoveTo:create(20,edPos)
     local function spCallBack()
        carSp:stopAllActions()
        carSp:removeFromParentAndCleanup(true)
     end
    local funcHandler=CCCallFunc:create(spCallBack)
    local seq=CCSequence:createWithTwoActions(mvTo,funcHandler)  
    carSp:runAction(seq) 
end

function portScene:showBirds(direct)
   
   local birdsPos
   local AimPos=ccp(0,0)
   local temW = 510
   local temH = -265
   if direct==2 then
        birdsPos=ccp(-100-deviceHelper:getRandom()*4,10+deviceHelper:getRandom()*9)

        AimPos.y=math.sin(math.rad(20))*3000+birdsPos.y+temH
        AimPos.x=math.cos(math.rad(20))*3000+birdsPos.x+temW
   else
        birdsPos=ccp(2000+deviceHelper:getRandom()*4,1000+deviceHelper:getRandom()*9)
        AimPos.y=math.sin(math.rad(200))*3000+birdsPos.y+temH
        AimPos.x=math.cos(math.rad(200))*3000+birdsPos.x+temW
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

function portScene:buildLvTipController(disPlay)
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
                    if G_isApplyVersion()==true then
                        if v.getType and buildingVoApi:isBuildShowLvByType(v:getType())==false or v.getLevel and v:getLevel()<=0 then
                            v.lvTip:setVisible(false)
                        else
                            v.lvTip:setVisible(true)
                        end
                    else
                      v.lvTip:setVisible(true)
                    end
                  else
                      v.lvTip:setVisible(false)
                  end
             end
        end
    end
   
end

function portScene:showSoldier()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/portSoldier.plist")
    if(self.soldierSp)then
        if(tolua.cast(self.soldierSp,"CCNode"))then
            tolua.cast(self.soldierSp,"CCNode"):removeFromParentAndCleanup(true)
        end
        self.soldierSp=nil
    end
    self.soldierSp=CCSprite:createWithSpriteFrameName("BlackBg.png")
    self.soldierSp:setOpacity(0)
    self.soldierSp:setPosition(340,625)--598,760)
    self.sceneSp:addChild(self.soldierSp,base:getBuildingOrderIDByBid(801)+5)
    local sp1=CCSprite:createWithSpriteFrameName("sol_fan_01.png")
    sp1:setTag(1)
    self.soldierSp:addChild(sp1)
    local frameArr=CCArray:create()
    for i=1,13 do
        local kk
        if(i<10)then
            kk="0"..i
        else
            kk=i
        end
        local nameStr="sol_fan_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        frameArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(frameArr)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)
    sp1:runAction(repeatForever)
    local sp2=CCSprite:createWithSpriteFrameName("sol_zheng_01.png")
    sp2:setTag(2)
    sp2:setVisible(false)
    self.soldierSp:addChild(sp2)
    local frameArr=CCArray:create()
    for i=1,13 do
        local kk
        if(i<10)then
            kk="0"..i
        else
            kk=i
        end
        local nameStr="sol_zheng_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        frameArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(frameArr)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)
    sp2:runAction(repeatForever)
    local acArr=CCArray:create()
    local moveTo1=CCMoveTo:create(14,ccp(900,910))--8
    local function turn1()
        if(self.soldierSp and tolua.cast(self.soldierSp,"CCNode"))then
            local sp1=tolua.cast(self.soldierSp:getChildByTag(1),"CCNode")
            if(sp1)then
                sp1:setVisible(false)
            end
            local sp2=tolua.cast(self.soldierSp:getChildByTag(2),"CCNode")
            if(sp2)then
                sp2:setVisible(true)
            end
        end
    end
    local callFunc1=CCCallFunc:create(turn1)
    local moveTo2=CCMoveTo:create(14,ccp(340,625))--598,760))
    local function turn2()
        if(self.soldierSp and tolua.cast(self.soldierSp,"CCNode"))then
            local sp1=tolua.cast(self.soldierSp:getChildByTag(1),"CCNode")
            if(sp1)then
                sp1:setVisible(true)
            end
            local sp2=tolua.cast(self.soldierSp:getChildByTag(2),"CCNode")
            if(sp2)then
                sp2:setVisible(false)
            end
        end
    end
    local callFunc2=CCCallFunc:create(turn2)
    acArr:addObject(moveTo1)
    acArr:addObject(callFunc1)
    acArr:addObject(moveTo2)
    acArr:addObject(callFunc2)
    local seq=CCSequence:create(acArr)
    self.soldierSp:runAction(CCRepeatForever:create(seq))
end
function portScene:showSoldier2()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/portSoldier.plist")
    if(self.soldierSp2)then
        if(tolua.cast(self.soldierSp2,"CCNode"))then
            tolua.cast(self.soldierSp2,"CCNode"):removeFromParentAndCleanup(true)
        end
        self.soldierSp2=nil
    end
    self.soldierSp2=CCSprite:createWithSpriteFrameName("BlackBg.png")
    self.soldierSp2:setOpacity(0)
    self.soldierSp2:setPosition(2600,600)
    self.sceneSp:addChild(self.soldierSp2,base:getBuildingOrderIDByBid(801)+5)
    local sp1=CCSprite:createWithSpriteFrameName("sol_fan_01.png")
    sp1:setTag(1)
    self.soldierSp2:addChild(sp1)
    local frameArr=CCArray:create()
    for i=1,13 do
        local kk
        if(i<10)then
            kk="0"..i
        else
            kk=i
        end
        local nameStr="sol_fan_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        frameArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(frameArr)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)
    sp1:runAction(repeatForever)
    local sp2=CCSprite:createWithSpriteFrameName("sol_zheng_01.png")
    sp2:setTag(2)
    sp2:setVisible(false)
    self.soldierSp2:addChild(sp2)
    local frameArr=CCArray:create()
    for i=1,13 do
        local kk
        if(i<10)then
            kk="0"..i
        else
            kk=i
        end
        local nameStr="sol_zheng_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        frameArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(frameArr)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)
    sp2:runAction(repeatForever)
    local acArr=CCArray:create()
    local moveTo1=CCMoveTo:create(10,ccp(2810,765))
    local function turn1()
        if(self.soldierSp2 and tolua.cast(self.soldierSp2,"CCNode"))then
            local sp1=tolua.cast(self.soldierSp2:getChildByTag(1),"CCNode")
            if(sp1)then
                sp1:setVisible(false)
            end
            local sp2=tolua.cast(self.soldierSp2:getChildByTag(2),"CCNode")
            if(sp2)then
                sp2:setVisible(true)
            end
        end
    end
    local callFunc1=CCCallFunc:create(turn1)
    local moveTo2=CCMoveTo:create(10,ccp(2600,600))
    local function turn2()
        if(self.soldierSp2 and tolua.cast(self.soldierSp2,"CCNode"))then
            local sp1=tolua.cast(self.soldierSp2:getChildByTag(1),"CCNode")
            if(sp1)then
                sp1:setVisible(true)
            end
            local sp2=tolua.cast(self.soldierSp2:getChildByTag(2),"CCNode")
            if(sp2)then
                sp2:setVisible(false)
            end
        end
    end
    local callFunc2=CCCallFunc:create(turn2)
    acArr:addObject(moveTo1)
    acArr:addObject(callFunc1)
    acArr:addObject(moveTo2)
    acArr:addObject(callFunc2)
    local seq=CCSequence:create(acArr)
    self.soldierSp2:runAction(CCRepeatForever:create(seq))
end

function portScene:showTruckAndSUV( )
    if self.cityCarTb and SizeOfTable(self.cityCarTb) > 0 then
        for k,v in pairs(self.cityCarTb) do
            if self.cityCarTb[k] and v then
                v:removeFromParentAndCleanup(true)
            end
            self.cityCarTb[k] = nil
        end
    end
    self.cityCarTb = {}
    local orderIdx = math.random(1,3)
    local orderTb  = {}
    if orderIdx == 1 then
        orderTb = {"suv","truck","truck","truck","suv"}
    elseif orderIdx == 2 then
        orderTb = {"suv","suv","suv"}
    elseif orderIdx == 3 then
        orderTb = {"suv","truck","suv"}
    end
    local stopPosTb = {ccp(1632,965),ccp(1706,999),ccp(1771,1028),ccp(1839,1060),ccp(1905,1092),}
    local useB = math.random(1,2)--每个车队的延时选择
    local bDet = useB == 1 and 2 or 4
    local sDet = 1 --每辆车的延时
    local useIdx = SizeOfTable(orderTb)
    local movToTb = {   
                        ccp(1632,965),
                        ccp(1586,942),
                        ccp(1582,934),
                        -- ccp(1588,931),
                        ccp(1594,927),
                        ccp(1602,933),
                        ccp(2755,1484)
                    }

    for i=1, useIdx do 
        local carContainer = CCNode:create()
        self.cityCarTb[useIdx + 1 - i] = carContainer
        carContainer:setPosition(ccp(2760,1506))
        -- carContainer:setScale(0.85)
        self.sceneSp:addChild(carContainer,base:getBuildingOrderIDByBid(801)+6)
    end
    for i=1, useIdx do
        local callIdx = 1

        local carContainer = self.cityCarTb[i]
        local sp1=CCSprite:createWithSpriteFrameName(orderTb[i].."1.png")
        sp1:setTag(1)
        carContainer:addChild(sp1)

        local mov1 = CCMoveTo:create(8.5 - 0.2*(i-1),stopPosTb[i])--1602,925
        local det1 = CCDelayTime:create(0.1)
        local function turn111Call( )
            callIdx = callIdx + 1
            if self.cityCarTb then
                if  self.cityCarTb[i] then
                    local sp1=tolua.cast(self.cityCarTb[i]:getChildByTag(callIdx - 1),"CCNode")
                    if sp1 then
                        sp1:removeFromParentAndCleanup(true)
                    end

                    local sp2=CCSprite:createWithSpriteFrameName(orderTb[i]..(callIdx - 1)..".png")
                    sp2:setTag(callIdx)
                    self.cityCarTb[i]:addChild(sp2)

                    local movToTime = 0.2
                    if callIdx == 2 then
                        movToTime = 0.7 + (i-1) * 0.3
                    elseif callIdx > 5 then
                        movToTime = 9
                    end

                    local movTo = CCMoveTo:create(movToTime , movToTb[callIdx])
                    local function turn2Call()
                        if callIdx < 6 then
                            turn111Call()
                        else
                            local function endCall( )
                                if self.cityCarTb then
                                    if SizeOfTable(self.cityCarTb) == 1 then
                                        self.cityCarTb[i]:removeFromParentAndCleanup(true)
                                        self.cityCarTb[i] = nil
                                        self.cityCarTb = nil
                                        self:showTruckAndSUV()
                                    else
                                        self.cityCarTb[i]:removeFromParentAndCleanup(true)
                                        self.cityCarTb[i] = nil
                                    end
                                end
                            end 
                            local endCallNow = CCCallFunc:create(endCall)
                            local endArr = CCArray:create()
                            -- endArr:addObject(movToEnd)
                            endArr:addObject(endCallNow)
                            local endSeq = CCSequence:create(endArr)
                            if self.cityCarTb and self.cityCarTb[i] then
                                self.cityCarTb[i]:runAction(endSeq)
                            end
                        end
                    end
                    local turn2CallNow = CCCallFunc:create(turn2Call)
                    
                    local arr2 = CCArray:create()
                    if callIdx == 2 then
                        local detFirst = CCDelayTime:create(4 -(i-1) * 0.3)
                        arr2:addObject(detFirst)
                    end
                    arr2:addObject(movTo)
                    arr2:addObject(turn2CallNow)
                    local seq2 = CCSequence:create(arr2)
                    self.cityCarTb[i]:runAction(seq2)
                else
                    print " carContainer is nil~~~~~~~~~~~~~~~"
                end
            end
        end
        local ccfun1 = CCCallFunc:create(turn111Call)
        local det0 = CCDelayTime:create(bDet + sDet * i)
        local acArr = CCArray:create()
        acArr:addObject(det0)
        acArr:addObject(mov1)
        acArr:addObject(det1)
        acArr:addObject(ccfun1)
        local acSeq = CCSequence:create(acArr)
        self.cityCarTb[i]:runAction(acSeq)
    end
end

function portScene:showRunTank()--(142,260) mainCityTank (1064,707) (859,833) (1079,951) (450,1260)
    if self.mainCityTankTb and SizeOfTable(self.mainCityTankTb) > 0 then
        for k,v in pairs(self.mainCityTankTb) do
            if self.mainCityTankTb[k] and v then
                v:removeFromParentAndCleanup(true)
            end
            self.mainCityTankTb[k] = nil
        end
    end
    self.mainCityTankTb = {}
    local useIdx = math.random(1,4)
    local usePath = math.random(1,2)
    local usePosTb = usePath == 1 and {ccp(-110,125),ccp(1115,710),ccp(875,825),ccp(1140,950),ccp(453,1283)} or {ccp(453,1283),ccp(1140,950),ccp(875,825),ccp(1115,710),ccp(-110,125)}
    local usePicNumTb = usePath == 1 and { 8, 11} or { 4, 16}

    for i=1,useIdx do
        local tankContainer = CCNode:create()
        self.mainCityTankTb[i] = tankContainer
        tankContainer:setScale(0.8)
        tankContainer:setPosition(usePosTb[1])
        self.sceneSp:addChild(tankContainer,base:getBuildingOrderIDByBid(801)+5)
        -- print("base:getBuildingOrderIDByBid(801)+5---->>>",base:getBuildingOrderIDByBid(801)+5)
        local sp1=CCSprite:createWithSpriteFrameName("t_"..usePicNumTb[1]..".png")
        sp1:setTag(1)
        tankContainer:addChild(sp1)

        local mov1 = CCMoveTo:create(9,usePosTb[2])
        local det1 = CCDelayTime:create(0.1)
        local function turn1Call( )
            if self.mainCityTankTb then
                if  self.mainCityTankTb[i] then
                    local sp1=tolua.cast(self.mainCityTankTb[i]:getChildByTag(1),"CCNode")
                    if sp1 then
                        sp1:removeFromParentAndCleanup(true)
                    end
                    local frameArr=CCArray:create()
                    if usePath == 1 then
                        for kk=8,11 do
                            local nameStr="t_"..kk..".png"
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                            frameArr:addObject(frame)
                        end
                    else
                        for kk=4,1,-1 do
                            local nameStr="t_"..kk..".png"
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                            frameArr:addObject(frame)
                        end
                        local nameStr="t_16.png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        frameArr:addObject(frame)
                    end
                    local animation=CCAnimation:createWithSpriteFrames(frameArr)
                    animation:setDelayPerUnit(0.1)
                    local animate=CCAnimate:create(animation)
                    self.mainCityTankTb[i]:runAction(animate)

                    local sp2=CCSprite:createWithSpriteFrameName("t_"..usePicNumTb[2]..".png")
                    sp2:setTag(2)
                    self.mainCityTankTb[i]:addChild(sp2)
                else
                    print " tankContainer is nil~~~~~~~~~~~111111~~~~~~~"
                end
            end
        end
        local ccfun1 = CCCallFunc:create(turn1Call)
        local mov2 = CCMoveTo:create(3,usePosTb[3])
        local det2 = CCDelayTime:create(0.1)
        
        local function turn2Call( )
            if self.mainCityTankTb then
                if self.mainCityTankTb[i] then
                    local sp2=tolua.cast(self.mainCityTankTb[i]:getChildByTag(2),"CCNode")
                    if sp2 then
                        sp2:removeFromParentAndCleanup(true)
                    end
                    local frameArr=CCArray:create()
                    if usePath == 1 then
                        for kk=11,8,-1 do
                            local nameStr="t_"..kk..".png"
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                            frameArr:addObject(frame)
                        end
                    else
                        local nameStr="t_16.png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        frameArr:addObject(frame)
                        for kk=1,4 do
                            local nameStr="t_"..kk..".png"
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                            frameArr:addObject(frame)
                        end
                    end
                    local animation=CCAnimation:createWithSpriteFrames(frameArr)
                    animation:setDelayPerUnit(0.1)
                    local animate=CCAnimate:create(animation)
                    self.mainCityTankTb[i]:runAction(animate)

                    local sp3=CCSprite:createWithSpriteFrameName("t_"..usePicNumTb[1]..".png")
                    sp3:setTag(3)
                    self.mainCityTankTb[i]:addChild(sp3)
                else
                    print " self.mainCityTankTb[i] is nil~~~~~~~~~~~~22222~~~~~~"
                end
            end
        end
        local ccfun2 = CCCallFunc:create(turn2Call)
        local mov3 = CCMoveTo:create(3,usePosTb[4])
        local det3 = CCDelayTime:create(0.1)
        
        local function turn3Call( )
            if self.mainCityTankTb then
                if self.mainCityTankTb[i] then
                    local sp3=tolua.cast(self.mainCityTankTb[i]:getChildByTag(3),"CCNode")
                    if sp3 then
                        sp3:removeFromParentAndCleanup(true)
                    end
                    local frameArr=CCArray:create()
                    if usePath == 1 then
                        for kk=8,11 do
                            local nameStr="t_"..kk..".png"
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                            frameArr:addObject(frame)
                        end
                    else
                        for kk=4,1,-1 do
                            local nameStr="t_"..kk..".png"
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                            frameArr:addObject(frame)
                        end
                        local nameStr="t_16.png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        frameArr:addObject(frame)
                    end
                    local animation=CCAnimation:createWithSpriteFrames(frameArr)
                    animation:setDelayPerUnit(0.1)
                    local animate=CCAnimate:create(animation)
                    self.mainCityTankTb[i]:runAction(animate)

                    local sp4=CCSprite:createWithSpriteFrameName("t_"..usePicNumTb[2]..".png")
                    sp4:setTag(4)
                    self.mainCityTankTb[i]:addChild(sp4)
                else
                    print " self.mainCityTankTb[i] is nil~~~~~~~~~~~~33333~~~~~~"
                end
            end
        end
        local ccfun3 = CCCallFunc:create(turn3Call)
        local mov4 = CCMoveTo:create(7,usePosTb[5])
        local det4 = CCDelayTime:create(0.1)

        local function endCall( )
            if self.mainCityTankTb then
                if SizeOfTable(self.mainCityTankTb) == 1 then
                    self.mainCityTankTb[i]:removeFromParentAndCleanup(true)
                    self.mainCityTankTb[i] = nil
                    self.mainCityTankTb = nil
                    self:showRunTank()
                else
                    self.mainCityTankTb[i]:removeFromParentAndCleanup(true)
                    self.mainCityTankTb[i] = nil
                end
            end
        end 
        local endFun = CCCallFunc:create(endCall)

        local arr = CCArray:create()
        local det0 = CCDelayTime:create((i-1) * 4 + 2)
        arr:addObject(det0)
        arr:addObject(mov1)
        arr:addObject(det1)
        arr:addObject(ccfun1)
        arr:addObject(mov2)
        arr:addObject(det2)
        arr:addObject(ccfun2)
        arr:addObject(mov3)
        arr:addObject(det3)
        arr:addObject(ccfun3)
        arr:addObject(mov4)
        arr:addObject(det4)
        arr:addObject(endFun)
        local seq = CCSequence:create(arr)
        self.mainCityTankTb[i]:runAction(seq)
    end
end
function portScene:initBuildingModel( )--base:getBuildingOrderIDByBid(801)+6
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/mainModelImage.plist")
    local modelTb = homeCfg.mainModelCfg
    local modelLayerTb = {m_rPillar=base:getBuildingOrderIDByBid(801)+4,rightDoor=base:getBuildingOrderIDByBid(801)+5}
    local needTouchTb = {m_signpost=true,}
    for k,v in pairs(modelTb) do
        for m,n in pairs(v) do
            local modelSp = nil
            if not needTouchTb[m] then
                modelSp = CCSprite:createWithSpriteFrameName(m..".png")
            else
                local function touchCall( )
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    local fadeOut=CCTintTo:create(0.3,80,80,80)
                    local fadeIn=CCTintTo:create(0.3,255,255,255)
                    local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
                    modelSp:runAction(seq)

                    local function callBack()
                         mainUI:changeToMainLand()
                    end
                    local delayAction=CCDelayTime:create(0.6)
                    local callFunc=CCCallFunc:create(callBack)
                    local seq2=CCSequence:createWithTwoActions(delayAction,callFunc)
                    modelSp:runAction(seq2)

                    
                end
                modelSp = LuaCCSprite:createWithSpriteFrameName(m..".png",touchCall)
                modelSp:setTouchPriority(-2)
            end
            modelSp:setPosition(ccp(n[1],n[2]))
            if modelLayerTb[m] then
                self.sceneSp:addChild(modelSp,modelLayerTb[m])
            elseif m == "m_baseBuild1" then --飞艇建筑id为52。该装饰物在飞艇建筑上层显示
                self.sceneSp:addChild(modelSp,base:getBuildingOrderIDByBid(homeCfg:getBuildingPosById(52)) + 2)
            else
                self.sceneSp:addChild(modelSp,base:getBuildingOrderIDByBid(801)+7)
            end
        end
    end

end
function portScene:initBlockingPic()--base:getBuildingOrderIDByBid(801)+6
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/mainCityBlockingImage.plist")

end

--显示补给商店直升飞机
function portScene:showSupplyShopCopter()
    if self.copterBody == nil then
        local copterBody = LuaCCSprite:createWithSpriteFrameName("ssc_body.png", function()
            supplyShopVoApi:showSupplyShopDialog(3)
        end)
        copterBody:setPosition(1375, 575)
        copterBody:setTouchPriority(-2)
        self.sceneSp:addChild(copterBody, 100)

        for i = 1, 2 do
            local copterWing = CCSprite:createWithSpriteFrameName("ssc_wing_1.png")
            if i == 1 then
                copterWing:setPosition(40, 46)
            else
                copterWing:setPosition(160, 126)
            end
            copterBody:addChild(copterWing)
            local frameArray = CCArray:create()
            for j = 1, 6 do
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ssc_wing_" .. j .. ".png")
                frameArray:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.05)
            local animate = CCAnimate:create(animation)
            copterWing:runAction(CCRepeatForever:create(animate))
        end

        local seqArry = CCArray:create()
        seqArry:addObject(CCMoveBy:create(1.6, ccp(0, 10)))
        seqArry:addObject(CCMoveBy:create(1.6, ccp(0, -10)))
        seqArry:addObject(CCMoveBy:create(1.6, ccp(0, 15)))
        seqArry:addObject(CCMoveBy:create(1.6, ccp(0, -15)))
        copterBody:runAction(CCRepeatForever:create(CCSequence:create(seqArry)))

        local copterNameLb
        if G_getGameUIVer()==2 then
            copterNameLb = GetTTFLabel(getlocal("supplyShop_titleText"), 20)
        else
            copterNameLb = GetTTFLabel(getlocal("supplyShop_titleText"), 27)
        end
        local copterNameBg
        if G_checkUseAuditUI()==true then
            copterNameBg =LuaCCScale9Sprite:createWithSpriteFrameName("building_name_tishen.png",CCRect(52, 24, 1, 1),function ()end)
            copterNameBg:setContentSize(CCSizeMake(copterNameLb:getContentSize().width+50,copterNameLb:getContentSize().height+16))
            copterNameLb:setColor(ccc3(255, 255, 255))
            copterNameBg:setScaleX((copterNameLb:getContentSize().width + 50) / copterNameBg:getContentSize().width)
        elseif G_getGameUIVer()==1 then
            copterNameBg = CCSprite:create("public/building_name.png")
            copterNameLb:setColor(ccc3(255, 255, 0))
            copterNameBg:setScaleX((copterNameLb:getContentSize().width + 50) / copterNameBg:getContentSize().width)
        else
            copterNameBg =LuaCCScale9Sprite:createWithSpriteFrameName("building_name1.png",CCRect(11, 13, 1, 1),function ()end)
            copterNameBg:setContentSize(CCSizeMake(copterNameLb:getContentSize().width+26,copterNameLb:getContentSize().height+8))
            copterNameLb:setColor(G_ColorWhite)
        end
        copterNameBg:setScaleY(0.9)
        copterNameBg:setPosition(copterBody:getContentSize().width / 2, copterBody:getContentSize().height - 55)
        copterBody:addChild(copterNameBg)
        copterNameLb:setPosition(copterNameBg:getPosition())
        copterBody:addChild(copterNameLb)
        self.copterBody = copterBody
    end
end

--添加补给商店直升飞机上的状态提示
function portScene:addSupplyShopCopterTips()
    if self.copterBody and tolua.cast(self.copterBody:getChildByTag(101), "CCSprite") == nil then
        local tipBg = LuaCCSprite:createWithSpriteFrameName("productItemBg.png",function()
            supplyShopVoApi:showSupplyShopDialog(3)
        end)
        local tipSp = CCSprite:createWithSpriteFrameName("ssc_tipsIcon.png")
        tipSp:setScale(75 / tipSp:getContentSize().width)
        tipSp:setPosition(tipBg:getContentSize().width / 2, tipBg:getContentSize().height / 2 + 6)
        tipBg:addChild(tipSp)
        tipBg:setTouchPriority(-3)
        tipBg:setPosition(self.copterBody:getContentSize().width / 2, self.copterBody:getContentSize().height)
        tipBg:setTag(101)
        self.copterBody:addChild(tipBg, 3)
    end
end

--移除补给商店直升飞机上的状态提示
function portScene:removeSupplyShopCopterTips()
    if self.copterBody then
        local tipBg = tolua.cast(self.copterBody:getChildByTag(101), "CCSprite")
        if tipBg then
            tipBg:removeFromParentAndCleanup(true)
            tipBg = nil
        end
    end
end

function portScene:dispose()
    self.cityCarTb = nil
    self.mainCityTankTb = nil
    self.clayer=nil
    self.sceneSp=nil
    self.touchArr={}
    self.multTouch=false
    self.firstOldPos=nil
    self.secondOldPos=nil
    if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
        self.startPos=ccp(0,125)
        self.topPos=ccp(0,-140)
    else
        self.startPos=ccp(0,96)
        self.topPos=ccp(0,-110)
    end
    self.minScale=0.75
    self.curScale=0.75
    self.maxScale=1.3
    self.isMoving=false
    self.isZooming=false
    self.autoMoveAddPos=nil
    self.zoomMidPosForWorld=nil
    self.zoomMidPosForSceneSp=nil
    self.touchEnable=true
    self.isMoved=false
    self.tanksSpTab={}
    self.savePoint=nil
    self.hideBuildLvTip=false
    self.copterBody = nil
    spriteController:removePlist("public/warStatue/warStatueBuilding.plist")
    spriteController:removeTexture("public/warStatue/warStatueBuilding.png")
end
