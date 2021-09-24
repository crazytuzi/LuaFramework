require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
ltzdzMapDialog = commonDialog:new()

function ltzdzMapDialog:new(layerNum,sFlag,initCallBack)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    nc.sFlag=sFlag -- 1:组团 2：个人征战
    nc.touchArr={}
    nc.startPos=ccp(0,0)
    nc.topPos=ccp(0,0)
    nc.openCityFlag=false
    nc.minScale=math.max(G_VisibleSizeWidth/3058,G_VisibleSizeHeight/2048) -- 缩放最小值
    nc.maxScale=1.5 -- 缩放最大值
    nc.coverFlag=false -- 城市遮罩标志
    nc.setOrTransportFlag=false -- （运输或者出征页面带箭头）
    nc.mapSize=ccp(3058,2048)
    nc.taskList=nil --任务列表
    nc.tipSpTb=nil --tip列表
    nc.fleetSynFlag=true
    nc.fleetTb={}
    nc.initCallBack=initCallBack
    nc.mapMovingFlag=false
    spriteController:addPlist("public/ltzdz/ltzdzCityIcon.plist")
    spriteController:addTexture("public/ltzdz/ltzdzCityIcon.png")
    local function addPlist()
        spriteController:addPlist("public/ltzdz/ltzdzMainUI.plist")
        spriteController:addTexture("public/ltzdz/ltzdzMainUI.png")
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
    end
    G_addResource8888(addPlist)
    return nc
end

function ltzdzMapDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
end

function ltzdzMapDialog:initTableView()
end

function ltzdzMapDialog:doUserHandler()
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzMapDialog",self)
    -- self.bgLayer:setOpacity(0)
    self.closeBtn:setVisible(false)

    self.clayer=CCLayer:create()
    self.bgLayer:addChild(self.clayer,1)
    -- self.clayer:setBSwallowsTouches(false)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-5,false)

    self.background=CCNode:create()
    self.background:setContentSize(CCSizeMake(3058,2048))
    self.background:setAnchorPoint(ccp(0,0))
    self.background:setPosition(ccp(0,0))
    -- self.background:setScale(self.minScale)

    self.clayer:addChild(self.background,1)
    self.clayer:setContentSize(self.background:getContentSize())
    self:initBg()
    self:initInfoLayer() -- 上面的信息，下面的按钮
    self:addMiniMap()
    self:initCity()
    self:initMatchLine() -- 行军路线
    self:initMiniFleetSlotLayer() -- 小地图，行军队列都在该层上
    self:initTaskLayer() --任务
    -- 刷新资源
    local function refreshResFunc(event,data)
       self:refreshResLb()
    end
    self.resChangedListener=refreshResFunc
    eventDispatcher:addEventListener("ltzdz.resChanged",refreshResFunc)

    -- 刷新队列
    local function refreshMatchLineFunc(event,data)
       self:refreshMatchLine(data)
    end
    self.refreshMatchLineListener=refreshMatchLineFunc
    eventDispatcher:addEventListener("ltzdz.refreshMatchLine",refreshMatchLineFunc)

    -- 点击过运输或者出征刷新
    local function setOrTransportRefresh(event,data)
        self:setOrTransportRefresh(data)
    end
    self.setOrTransportListener=setOrTransportRefresh
    eventDispatcher:addEventListener("ltzdz.setOrTransport",setOrTransportRefresh)

    -- 刷新城市
    local function refreshCityFunc(event,city)
        self:refreshCity(city)
    end
    self.refreshCityListener=refreshCityFunc
    eventDispatcher:addEventListener("ltzdz.refreshCity",refreshCityFunc)

    local function refreshTask(event,data)
        self:refreshTaskLayer()
    end
    self.refreshTaskListener=refreshTask
    eventDispatcher:addEventListener("ltzdz.updateTask",refreshTask)
    -- 刷新聊天
    local function refreshChat(event,data)
        self:refreshChat(data)
    end
    self.refreshChatListener=refreshChat
    eventDispatcher:addEventListener("ltzdz.newChat",refreshChat)

    --刷新可操作的红点提示（有新的战报，计策商店可以兑换等等的提示）
    local function refreshTip(event,data)
        if data.tipType=="report" then
            self:refreshTip(1) --刷新战报tip
        elseif data.tipType=="invite" then
            self:refreshTip(3) --刷新外交tip
        end
    end
    self.refreshTipListener=refreshTip
    eventDispatcher:addEventListener("ltzdz.refreshTip",refreshTip)

    self.coolingFlag=ltzdzVoApi:isStratagemCooling() 

    if self.initCallBack then --初始化完地图数据后回调
        self.initCallBack()
    end   
end
function ltzdzMapDialog:initBg()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local bg1=CCSprite:create("public/ltzdz/ltzdzMapBg1.jpg")
    self.background:addChild(bg1)
    bg1:setAnchorPoint(ccp(0,0))
    bg1:setPosition(0,0)
    local bg2=CCSprite:create("public/ltzdz/ltzdzMapBg2.jpg")
    self.background:addChild(bg2)
    bg2:setAnchorPoint(ccp(0,0))
    bg2:setPosition(bg1:getContentSize().width,0)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end


function ltzdzMapDialog:focus(x,y,actionFlag,callBack)
    self.mapMovingFlag=false
    local backgroundScale=self.background:getScale()

    local trueX=G_VisibleSize.width/2-x*backgroundScale
    local trueY=G_VisibleSize.height/2-y*backgroundScale

    local truePos=self:checkBound(ccp(trueX,trueY))
    if actionFlag and actionFlag==true then
        self.mapMovingFlag=true
        local moveTo=CCMoveTo:create(0.3,truePos)
        local function moveCallBack()
            if callBack then
                callBack()
            end
            self.mapMovingFlag=false
        end
        local moveFunc=CCCallFunc:create(moveCallBack)
        local seq=CCSequence:createWithTwoActions(moveTo,moveFunc)
        self.clayer:runAction(seq)
        -- self.clayer:setPosition(truePos)
    else
        self.clayer:setPosition(truePos)
    end
    self:mapMove(ccp(-truePos.x,-truePos.y))
end

function ltzdzMapDialog:checkBound(pos)

    local tmpPos
    if pos==nil then
       tmpPos= ccp(self.clayer:getPosition())
    else
       tmpPos=pos
    end
    if tmpPos.x>0 then
        tmpPos.x=0 -- 左边界
     elseif tmpPos.x<(G_VisibleSize.width-self.background:boundingBox().size.width) then
        tmpPos.x=G_VisibleSize.width-self.background:boundingBox().size.width -- 右边界
     end
     if tmpPos.y>=self.startPos.y then
         tmpPos.y=self.startPos.y
     elseif tmpPos.y<(G_VisibleSize.height-self.background:boundingBox().size.height+self.topPos.y)  then
         tmpPos.y=G_VisibleSize.height-self.background:boundingBox().size.height+self.topPos.y
     end
    if pos==nil then
        self.clayer:setPosition(tmpPos)
    else
        return tmpPos
    end

end

function ltzdzMapDialog:touchEvent(fn,x,y,touch)
    if self.mapMovingFlag==true then
        do return end
    end
    if fn=="began" then
        self:hideSelectLayer()
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 then
            return 0
        end
        -- print("22222222222")
        self:removeOperateLayer()
        
        self.isMoved=false
        self.touchArr[touch]=touch
        local touchIndex=0
        for k,v in pairs(self.touchArr) do
            local temTouch= tolua.cast(v,"CCTouch")
            if self and temTouch then
                if touchIndex==0 then
                    self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                else
                    self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                end
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
        if self.touchEnable==false then
            do return end
        end
        self.isMoved=true
        if self.multTouch==true then --双点触摸
            self.zoomMidPosForBackground=self.background:convertToNodeSpace(ccpMidpoint(self.firstOldPos,self.secondOldPos))
            self.zoomMidPosForLayer=ccpMidpoint(self.firstOldPos,self.secondOldPos)
            local beforeZoomDis=ccpDistance(self.firstOldPos,self.secondOldPos)
            local pIndex=0
            local curFirstPos
            local curSecondPos
            for k,v in pairs(self.touchArr) do
                if v==touch then
                    if pIndex==0 then
                        curFirstPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                    else 
                        curSecondPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                    end
                    do break end
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
                self.background:setScale(math.min(self.maxScale,sl+self.background:getScale()))
            else --缩小
                subDis=afterZoomDis-beforeZoomDis  
                sl=(subDis/200)*0.2
                self.background:setScale(math.max(self.minScale,sl+self.background:getScale()))   
            end
            local newPosForBackgroundToLayer=self.background:convertToWorldSpace(self.zoomMidPosForBackground)
            local newAddPos=ccpSub(newPosForBackgroundToLayer,self.zoomMidPosForLayer)
            local newClayerPos=ccpSub(ccp(self.clayer:getPosition()),newAddPos)
            local truePos=self:checkBound(newClayerPos)
            self.clayer:setPosition(truePos)
            self:mapMove(ccp(-truePos.x,-truePos.y))
        else --单点触摸
            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local moveDisPos=ccpSub(curPos,self.firstOldPos)
            local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
            if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
                self.isMoved=false
                do return end
            end
            self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)
            local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),moveDisPos)
            local truePos=self:checkBound(tmpPos)
            self.clayer:setPosition(truePos)
            self:mapMove(ccp(-truePos.x,-truePos.y))
            self.firstOldPos=curPos
            self.isMoving=true
        end
    elseif fn=="ended" then
        if self.touchEnable==false then
            do
                return
            end
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
        if self.isMoving==true then
            self.isMoving=false
            local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
            tmpToPos=self:checkBound(tmpToPos)

            local moveTo=CCMoveTo:create(0.15,tmpToPos)
            local cceaseOut=CCEaseOut:create(moveTo,3)
            self.clayer:runAction(cceaseOut)

            self:mapMove(ccp(-tmpToPos.x,-tmpToPos.y))
        end
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

function ltzdzMapDialog:initCity()

    local mapCfg=ltzdzVoApi:getMapCfg()
    local citycfg=mapCfg.citycfg
    local mapVo=ltzdzFightApi.mapVo
    local uid=playerVoApi:getUid()
    local cityVo
    if mapVo then
        cityVo=mapVo.city
    end
    local mapUser=mapVo.user

    for k,v in pairs(citycfg) do
        local citySp
        local function touchCity()
            if self.isMoved==true or self.touchEnable==false then
                do
                    return
                end
            end
            self.mapMovingFlag=false
            local function touchHandler()
                -- ltzdzFightApi:showBattleEnd(self.layerNum+1,true,true,callBack,endInfo)
                -- do return end
                if self.setOrTransportFlag then -- 出征或者运输
                    -- print("self.bType",self.bType)
                    if self.targetCityTb[k]==1 or self.targetCityTb[k]==2 then
                        if self.bType==1 then -- 出征
                            ltzdzFightApi:showExpeDitionDialog(self.layerNum+1,k,self.startCid,self.targetCityTb,self)
                        else
                            ltzdzFightApi:showTransportTankDialog(self.layerNum+1,true,true,callBack,getlocal("ltzdz_transport"),self.startCid,k,self.targetCityTb,self)
                        end
                    end
                    
                else
                    self:creatOperateLayer(k,v.pos)
                end
            end
            local x,y=G_getSpriteWorldPosAndSize(citySp)
            --如果建筑在屏幕边界的话，就移动地图到可视范围内
            -- print("x,y-------????",x,y)
            if x<=120 or x>=(G_VisibleSizeWidth-80) or y>=G_VisibleSizeHeight-200 or y<=160 then
                self:focus(v.pos[1],v.pos[2],true,touchHandler)
            else
                touchHandler()
            end
            local level=ltzdzFightApi:getCityLevel(k,cityVo)
            self:showSelectEffect(ccp(v.pos[1],v.pos[2]),v.type,level) 
            if otherGuideMgr.isGuiding and otherGuideMgr.curStep==46 then
                otherGuideMgr:toNextStep()
            end           
        end
        local cityType=v.type
        local cityTag=v.id+10000

        local cLevel=ltzdzFightApi:getCityLevel(k,cityVo)
        local iconPic=ltzdzFightApi:getCityPic(cityType,cLevel)
        citySp=LuaCCSprite:createWithSpriteFrameName(iconPic,touchCity)
        self.background:addChild(citySp,2)
        citySp:setIsSallow(true)
        citySp:setTag(cityTag)
        local pos=v.pos
        citySp:setPosition(pos[1],pos[2])
        citySp:setTouchPriority(-(self.layerNum-1)*20-4)

        -- self.miniMap 小地图元素
        -- self.miniMapSize
         local miniCitySp=CCSprite:createWithSpriteFrameName("ltzdz_mapPoint.png")
        self.miniMap:addChild(miniCitySp)
        miniCitySp:setPosition(pos[1]*(self.miniMapSize.width/self.mapSize.x),pos[2]*(self.miniMapSize.height/self.mapSize.y))
        miniCitySp:setTag(cityTag)


        local cityName=ltzdzCityVoApi:getCityName(k)
        local cityNameLb1=GetTTFLabel(cityName,22)
        citySp:addChild(cityNameLb1,1)
        cityNameLb1:setAnchorPoint(ccp(0.5,1))
        cityNameLb1:setPosition(citySp:getContentSize().width/2+1,20-1)
        cityNameLb1:setColor(G_ColorBlack)

        local cityNameLb2=GetTTFLabel(cityName,22)
        citySp:addChild(cityNameLb2,1)
        cityNameLb2:setAnchorPoint(ccp(0.5,1))
        cityNameLb2:setPosition(citySp:getContentSize().width/2,20)

        -- coverFlag
        self.coverFlag=( not ltzdzFightApi:isTrueBattle() )
        if self.coverFlag==true then
            if ltzdzFightApi:isPrtCity(k) then
                local protectedSp=CCSprite:createWithSpriteFrameName("ShieldingShape.png")
                protectedSp:setAnchorPoint(ccp(0.5,0.5))
                protectedSp:setPosition(ccp(citySp:getContentSize().width/2,citySp:getContentSize().height/2))
                citySp:addChild(protectedSp)
                protectedSp:setTag(102)
                protectedSp:setScale(1.5)
            end
        end

        if cityVo and cityVo[k] then
            local oid=cityVo[k].oid
            if oid then
                self:addOrRefreshCityChild(citySp,uid,oid,cityVo[k],cityType,k)
                if oid and tonumber(uid)==tonumber(oid) then
                    self:focus(pos[1],pos[2])
                    
                    --如果当前是定级赛并且玩家只有一个主城时，引导主城
                    if ltzdzVoApi:isQualifying()==true then                 
                        if otherGuideMgr:checkGuide(46)==false then
                            local citylist=ltzdzVoApi:getMyCityList()
                            if SizeOfTable(citylist)==1 then
                                local x,y,width,height=G_getSpriteWorldPosAndSize(citySp,1)
                                otherGuideCfg[46].clickRect=CCRectMake(x,y,width,height)
                                otherGuideMgr:showGuide(46)
                            end
                        end
                    end
                end

                -- 小地图上的点边颜色
                self:setMiniMapPointColor(mapUser,tostring(oid),cityTag)
            end
        else
           self:scoutRefresh(k,citySp,uid,cityType)
        end
    end
end

--城市选择效果
function ltzdzMapDialog:showSelectEffect(pos,ctype,level)
    if self.selectLayer==nil then
        local arrowPosCfg={
            {"cityArrow1.png",ccp(102,97.5)},
            {"cityArrow2.png",ccp(195.5,51)},
            {"cityArrow1.png",ccp(102,4.5),180},
            {"cityArrow2.png",ccp(8.5,51),180}}
        local selectLayer=CCNode:create()
        selectLayer:setAnchorPoint(ccp(0.5,0.5))
        selectLayer:setContentSize(CCSizeMake(210,110))
        self.background:addChild(selectLayer)
        self.selectLayer=selectLayer

        for k,v in pairs(arrowPosCfg) do
            local pic,arrowPos,angle=v[1],v[2],v[3]
            local arrowSp=CCSprite:createWithSpriteFrameName(pic)
            arrowSp:setPosition(arrowPos)
            if angle then
                arrowSp:setRotation(angle)
            end
            selectLayer:addChild(arrowSp)
        end

        local acArr=CCArray:create()
        local scaleTo1=CCScaleTo:create(0.5,1.1)
        local scaleTo2=CCScaleTo:create(0.5,1)
        local seq=CCSequence:createWithTwoActions(scaleTo1,scaleTo2)
        local repeatAc=CCRepeatForever:create(seq)
        self.selectLayer:runAction(repeatAc)
    end
    local scale=1
    if ctype==2 then
        scale=0.6
    end
    local offestX,offestY=0,0
    if ctype==1 then
        if level==1 then
            offestX,offestY=0.5,-7
        elseif level==2 then
            offestX,offestY=1.5,-9
        elseif level==3 then
            offestX,offestY=0.5,-8
        elseif level==4 then
            offestX,offestY=1.5,-8
        else
            offestX,offestY=2.5,-13
        end
    elseif ctype==2 then
        offestX,offestY=3.5,-3
    end
    self.selectLayer:setVisible(true)
    self.selectLayer:setScale(scale)
    self.selectLayer:setPosition(pos.x+offestX,pos.y+offestY)
end

function ltzdzMapDialog:hideSelectLayer()
    if self.selectLayer then
        self.selectLayer:setVisible(false)
    end
end

function ltzdzMapDialog:scoutRefresh(cid,citySp,uid,cityType,oid)
    local visivleFlag,cityInfo=ltzdzFightApi:scoutIsVisible(cid)
    if visivleFlag==true then
        self:addOrRefreshCityChild(citySp,uid,oid,cityInfo,cityType,cid)
    end
    return visivleFlag
end


function ltzdzMapDialog:addOrRefreshCityChild(citySp,selfUid,oid,cityInfo,cityType,cid)
    -- citySp 添加一个唯一的child,然后把一些信息添加到child上
    local cityChild=tolua.cast(citySp:getChildByTag(101),"LuaCCScale9Sprite")
    if cityChild==nil then
        cityChild=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        cityChild:setContentSize(citySp:getContentSize())
        cityChild:setPosition(getCenterPoint(cityChild))
        citySp:addChild(cityChild)
        cityChild:setOpacity(0)
        cityChild:setTag(101)
    end
    local nickname=""
    local userInfo
    if oid and tonumber(oid)~=0 then
        userInfo=ltzdzFightApi:getUserInfo(oid)
        nickname=userInfo.nickname
    end
    

    local nickNameLb=tolua.cast(cityChild:getChildByTag(1),"CCLabelTTF")
    local nickNameLb2
    if nickNameLb==nil then
        nickNameLb=GetTTFLabel(nickname,22)
        cityChild:addChild(nickNameLb)
        nickNameLb:setAnchorPoint(ccp(0.5,1))
        nickNameLb:setPosition(cityChild:getContentSize().width/2,-10)
        nickNameLb:setTag(1)

        nickNameLb2=GetTTFLabel(nickname,22)
        nickNameLb:addChild(nickNameLb2)
        nickNameLb2:setPosition(nickNameLb:getContentSize().width/2-1,nickNameLb:getContentSize().height/2+1)
        nickNameLb2:setTag(1)
    else
        nickNameLb:setString(nickname)
        nickNameLb2=tolua.cast(nickNameLb:getChildByTag(1),"CCLabelTTF")
        nickNameLb2:setString(nickname)
        nickNameLb2:setPosition(nickNameLb:getContentSize().width/2-1,nickNameLb:getContentSize().height/2+1)
        
    end
    nickNameLb:setColor(G_ColorBlack)



    local powerLogo = tolua.cast(cityChild:getChildByTag(4),"CCSprite")
    if oid and tonumber(oid)~=0 then
        
        if powerLogo then
        else
            powerLogo=CCSprite:createWithSpriteFrameName("ltzdzPowerLogo.png")
            nickNameLb:addChild(powerLogo)
            powerLogo:setPosition(-20,nickNameLb:getContentSize().height/2)
            powerLogo:setTag(4)
        end
        local mapVo=ltzdzFightApi.mapVo or {}
        local mapUser=mapVo.user or {}
        local colorInfo=mapUser[tostring(oid)] or {}
        local colorId=colorInfo.c or 1
        local color=ltzdzFightApi:getUserColor(colorId)
        powerLogo:setColor(color)
    else
        if powerLogo then
            powerLogo:removeFromParentAndCleanup(true)
        end
    end


    local timerSprite=tolua.cast(cityChild:getChildByTag(2),"CCProgressTimer")
    local timeBg=tolua.cast(cityChild:getChildByTag(11),"CCSprite")

    local tankBg=tolua.cast(cityChild:getChildByTag(3),"LuaCCScale9Sprite")
    local sWidth=130

    local myinfo=ltzdzFightApi:getUserInfo()
    if not myinfo then
        do return end
    end
    
    local visivleFlag,scoutInfo=ltzdzFightApi:scoutIsVisible(cid)
    -- print("oid,myinfo.ally",oid,myinfo.ally,cid,visivleFlag)
    if (oid and ((selfUid and (tonumber(selfUid)==tonumber(oid))) or (myinfo and myinfo.ally and tonumber(oid)==tonumber(myinfo.ally)))) or  visivleFlag then
        local newDataInfo=cityInfo
        if oid and selfUid and tonumber(selfUid)==tonumber(oid) then
            -- print("自己")
        elseif oid and myinfo and myinfo.ally and tonumber(oid)==tonumber(myinfo.ally) then
            -- print("同盟")
        else
            -- print("敌人")
            newDataInfo=scoutInfo
        end
        if timerSprite==nil then
            local barName = "PanelBuildUpBar.png"
            local barBgName = "PanelBuildUpBarBg.png"
            timerSprite=AddProgramTimer(cityChild,ccp(cityChild:getContentSize().width/2,cityChild:getContentSize().height-10),2,12,"",barBgName,barName,11,nil,nil,nil,nil,16,nil,nil)
            local scaleX=(sWidth+20)/timerSprite:getContentSize().width
            local scaleY=16/timerSprite:getContentSize().height
            timerSprite:setScaleX(scaleX)
            timerSprite:setScaleY(scaleY)

            timeBg=tolua.cast(cityChild:getChildByTag(11),"CCSprite")
            if timeBg then
                timeBg:setScaleX(scaleX)
                timeBg:setScaleY(scaleY)
            end
            local lbPer = tolua.cast(timerSprite:getChildByTag(12),"CCLabelTTF")
            lbPer:setScaleX(1/scaleX)
            lbPer:setScaleY(1/scaleY)
        end
        -- ltzdzFightApi:getReserveLimit()
        local per,haveRe=ltzdzFightApi:getPerByCity(newDataInfo,cityType)
        timerSprite:setPercentage(per)

        local lbPer = tolua.cast(timerSprite:getChildByTag(12),"CCLabelTTF")
        lbPer:setString(haveRe)

        if tankBg == nil then
            tankBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4, 4, 1, 1),function ()end)
            tankBg:setContentSize(CCSizeMake(sWidth,22))
            cityChild:addChild(tankBg)
            tankBg:setPosition(cityChild:getContentSize().width/2,cityChild:getContentSize().height+10)
            tankBg:setTag(3)
            tankBg:setOpacity(120)

            local tankBgSize=tankBg:getContentSize()

            local logo1=CCSprite:createWithSpriteFrameName("ltzdzTankNum.png")
            tankBg:addChild(logo1)
            logo1:setAnchorPoint(ccp(0,0.5))
            logo1:setPosition(0,tankBgSize.height/2)
            logo1:setScale(18/logo1:getContentSize().height)

            local lb1=GetTTFLabel("",18)
            tankBg:addChild(lb1)
            lb1:setAnchorPoint(ccp(0,0.5))
            lb1:setPosition(35,tankBgSize.height/2)
            lb1:setTag(1)

            local logo2=CCSprite:createWithSpriteFrameName("ltzdzTankFight.png")
            tankBg:addChild(logo2)
            logo2:setAnchorPoint(ccp(0,0.5))
            logo2:setPosition(tankBgSize.width/2-5,tankBgSize.height/2)
            logo2:setScale(18/logo1:getContentSize().height)

            local lb2=GetTTFLabel("",18)
            tankBg:addChild(lb2)
            lb2:setAnchorPoint(ccp(0,0.5))
            lb2:setPosition(tankBgSize.width/2+15,tankBgSize.height/2)
            lb2:setTag(2)
        end

        local defenceInfo=newDataInfo.d or {}
        local tankInfo=defenceInfo[1] or {}
        local tankNum,slotNum=ltzdzFightApi:getTankNumByTb(tankInfo)

        local lb1=tolua.cast(tankBg:getChildByTag(1),"CCLabelTTF")
        lb1:setString(slotNum)
        local lb2=tolua.cast(tankBg:getChildByTag(2),"CCLabelTTF")
        lb2:setString(FormatNumber(tankNum))
    else
        if timerSprite then
            timerSprite:removeFromParentAndCleanup(true)
        end
        
        if timeBg then
            timeBg:removeFromParentAndCleanup(true)
        end
        if tankBg then
            tankBg:removeFromParentAndCleanup(true)
        end
    end

    if oid and selfUid and (tonumber(selfUid)==tonumber(oid)) then
        nickNameLb2:setColor(ccc3(0,255,50))
    elseif oid and myinfo and myinfo.ally and tonumber(oid)==tonumber(myinfo.ally) then
        nickNameLb2:setColor(ccc3(0,220,240))

    else
        nickNameLb2:setColor(G_ColorWhite)
    end

    
end


function ltzdzMapDialog:showCity(cityId)
    local function realShow()
        self:closeMiniMapLayer()
        self:closeUpLayer()
        self:closeFleetLayer()
        self.openCityFlag=true
        require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzCityDialog"
        self.cityDialog=ltzdzCityDialog:new(cityId,self)
        local cityLayer=self.cityDialog:init(self.layerNum)
        cityLayer:setTouchEnabled(true)
        cityLayer:setTouchPriority(-(self.layerNum-1)*20-7)
        cityLayer:setBSwallowsTouches(true)

        self.bgLayer:addChild(cityLayer,7)
    end
    ltzdzCityVoApi:syncCity(cityId,realShow,1)
end

function ltzdzMapDialog:showMiniMapLayer()
    if self.miniMapLayer then
        self.miniMapLayer:setVisible(true)
    end   
end

function ltzdzMapDialog:closeMiniMapLayer()
    if self.miniMapLayer then
        self.miniMapLayer:setVisible(false)
    end 
end

function ltzdzMapDialog:showUpLayer()
    if self.playerLayer and self.playerIconSp then
        self.playerLayer:setVisible(true)
        self.playerIconSp:setVisible(true)
    end
end

function ltzdzMapDialog:closeUpLayer()
    if self.playerLayer and self.playerIconSp then
        self.playerLayer:setVisible(false)
        self.playerIconSp:setVisible(false)
    end
end

function ltzdzMapDialog:closeCity()
    if self.cityDialog and self.cityDialog.dispose then
        self.cityDialog:dispose()
        self.cityDialog=nil
    end
    self.openCityFlag=false
    self:showMiniMapLayer()
    self:showUpLayer()
    self:showFleetLayer()
end

function ltzdzMapDialog:initInfoLayer()
    self.infoLayer=CCLayer:create()
    self.bgLayer:addChild(self.infoLayer,8)
    self.miniMapLayer=CCLayer:create()
    self.bgLayer:addChild(self.miniMapLayer,6)

    self:initUpLayer()
    self:initFunctionBar()
end

-- flag 1:移走  2：显示
function ltzdzMapDialog:setInfoLayerPos(flag)
    if flag==1 then
        self.infoLayer:setPosition(99999,99999)
        self.miniMapLayer:setPosition(99999,99999)
    else
        self.infoLayer:setPosition(0,0)
        self.miniMapLayer:setPosition(0,0)
    end
end


function ltzdzMapDialog:initUpLayer()
    local function nilFunc()
    end
    local playerLayer=LuaCCSprite:createWithSpriteFrameName("ltzdz_upBg.png",nilFunc)
    playerLayer:setTouchPriority(-(self.layerNum-1)*20-6)
    playerLayer:setAnchorPoint(ccp(0.5,1))
    playerLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    self.infoLayer:addChild(playerLayer,1)
    self.playerLayer=playerLayer

    local gems,metal,oil=0,0
    local myinfo=ltzdzFightApi:getUserInfo()
    if myinfo then
        gems=myinfo.gems or 0
        metal=myinfo.metal or 0
        oil=myinfo.oil or 0
    end
    self.gemsLb=self:getResLb(1,playerLayer,ccp(140,25),gems)
    self.oilLb=self:getResLb(2,playerLayer,ccp(310,25),oil)
    self.metalLb=self:getResLb(3,playerLayer,ccp(490,25),metal)

    local function showPlayerInfo() --显示玩家的详细信息
        ltzdzVoApi:showPlayerDialog(self.layerNum+1,self)
    end

    local personPhotoName=playerVoApi:getPersonPhotoName(myinfo.pic)
    local playerIconSp=playerVoApi:GetPlayerBgIcon(personPhotoName,showPlayerInfo,nil,nil,100)
    playerIconSp:setTouchPriority(-(self.layerNum-1)*20-6)
    playerIconSp:setPosition(50,G_VisibleSizeHeight-playerLayer:getContentSize().height/2)
    self.infoLayer:addChild(playerIconSp)
    self.playerIconSp=playerIconSp

    local posY=playerLayer:getContentSize().height-25
    local nameLb=GetTTFLabelWrap(myinfo.nickname,25,CCSize(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(110,posY)
    playerLayer:addChild(nameLb)

    local flag=ltzdzVoApi:isQualifying() --是否在定级赛中
    if flag==true then
        local qualifyingLb=GetTTFLabelWrap(getlocal("ltzdz_qualifying"),25,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        qualifyingLb:setPosition(370,posY)
        playerLayer:addChild(qualifyingLb)
    else
        local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
        local segNameStr=ltzdzVoApi:getSegName(seg,smallLevel)
        local segIconSp=ltzdzVoApi:getSegIcon(seg,smallLevel,nil,1)
        segIconSp:setAnchorPoint(ccp(0,0.5))
        segIconSp:setPosition(280,posY)
        playerLayer:addChild(segIconSp)
        local segmentLb=GetTTFLabelWrap(segNameStr,25,CCSize(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        segmentLb:setAnchorPoint(ccp(0,0.5))
        segmentLb:setPosition(segIconSp:getPositionX()+segIconSp:getContentSize().width*segIconSp:getScale()+10,posY)
        playerLayer:addChild(segmentLb)
    end

    local mapVo=ltzdzFightApi:getMapVo()
    if mapVo then
        local timeStr=""
        if base.serverTime<mapVo.st then --还未开战
            timeStr=G_getFormatDate((mapVo.st or 0))..getlocal("ltzdz_begin_battle")
        else
            timeStr=G_getFormatDate((mapVo.et or 0))..getlocal("function_end_str")
        end
        local fightTimeLb=GetTTFLabelWrap(timeStr,25,CCSize(170,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        fightTimeLb:setPosition(G_VisibleSizeWidth-fightTimeLb:getContentSize().width/2,posY)
        fightTimeLb:setColor(G_ColorYellowPro)
        playerLayer:addChild(fightTimeLb)
        self.fightTimeLb=fightTimeLb
    end
end

function ltzdzMapDialog:initFunctionBar()
    local function nilFunc()
    end
    local downSp=LuaCCSprite:createWithSpriteFrameName("ltzdz_downBg.png",nilFunc)
    downSp:setTouchPriority(-(self.layerNum-1)*20-7)
    downSp:setAnchorPoint(ccp(0.5,0))
    downSp:setPosition(ccp(G_VisibleSizeWidth/2,0))
    self.infoLayer:addChild(downSp,3)


    local function backHandler() --返回
        if self.openCityFlag==true then --城市打开则关闭城市
            self:closeCity()
        else
            self:close()
        end
    end

    local targetScale=0.8
    local reportBtn,ployBtn,diplomacyBtn,helpBtn,bagBtn
    local posY=downSp:getContentSize().height-40
    local pos=ccp(60,posY)
    self:getBotton(downSp,pos,nil,"ltzdz_back.png","ltzdz_backDown.png","ltzdz_backDown.png",backHandler)

    posY=downSp:getContentSize().height-15
    local function reportHandler() --战报
        local function realShow()
            require "luascript/script/game/gamemodel/ltzdz/ltzdzReportVoApi"
            ltzdzReportVoApi:showReportDialog(self.layerNum+2)
        end
        G_touchedItem(reportBtn,realShow,targetScale)
    end
    pos=ccp(180,posY)
    reportBtn=self:getBotton(downSp,pos,getlocal("allianceWar_battleReport"),"mainBtnMail.png","mainBtnMail.png","mainBtnMail.png",reportHandler,true,true,1)

    local function ployHandler() --计策
        local function realShow()
            ltzdzVoApi:showStratagemDialog(self.layerNum+2)       
        end
        G_touchedItem(ployBtn,realShow,targetScale)
    end
    pos=ccp(270,posY)
    ployBtn=self:getBotton(downSp,pos,getlocal("ltzdz_ploy"),"mainBtnCheckpoint.png","mainBtnCheckpoint.png","mainBtnCheckpoint.png",ployHandler,true,true,2)

    local function diplomacyHandler() --外交
        local function realShow()
            ltzdzVoApi:showForeignDialog(self.layerNum+2)
        end
        G_touchedItem(diplomacyBtn,realShow,targetScale)
    end
    pos=ccp(360,posY)
    diplomacyBtn=self:getBotton(downSp,pos,getlocal("ltzdz_diplomacy"),"mainBtnFriend.png","mainBtnFriend.png","mainBtnFriend.png",diplomacyHandler,true,true,3)

    otherGuideMgr:setGuideStepField(54,nil,nil,{ployBtn,1})
    otherGuideMgr:setGuideStepField(55,nil,nil,{diplomacyBtn,1})
    otherGuideMgr:setGuideStepField(69,nil,nil,{reportBtn,1})

    local function helpHandler() --帮助
        local function realShow()
           ltzdzVoApi:showHelpDialog(self.layerNum+1)
        end
        G_touchedItem(helpBtn,realShow,targetScale)
    end
    pos=ccp(450,posY)
    helpBtn=self:getBotton(downSp,pos,getlocal("help"),"mainBtnHelp.png","mainBtnHelp.png","mainBtnHelp.png",helpHandler,true,true,4)

    local function bagHandler() --背包
        local function realShow()
            ltzdzVoApi:showStratagemBagDialog(self.layerNum+2)       
        end
        G_touchedItem(bagBtn,realShow,targetScale)
    end
    pos=ccp(540,posY)
    bagBtn=self:getBotton(downSp,pos,getlocal("bundle"),"mainBtnBag.png","mainBtnBag.png","mainBtnBag.png",bagHandler,true,true,5)

    posY=downSp:getContentSize().height+50
    local priority=-(self.layerNum-1)*20-8
    -- 聊天
    local function chatHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        -- PlayEffect(audioCfg.mouseClick)
        local subIndex=0
        if self.chatType and self.chatType==2 then
            subIndex=1
        end
        ltzdzChatVoApi:showChatDialog(self.layerNum+2,subIndex)
    end
    local m_chatBtn=GetButtonItem("ltzdz_chatBtn.png","ltzdz_chatBtn.png","ltzdz_chatBtn.png",chatHandler,nil,nil,nil)
    m_chatBtn:setAnchorPoint(ccp(1,0.5))
    local chatSpriteMenu=CCMenu:createWithItem(m_chatBtn)
    chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth-15,posY))
    chatSpriteMenu:setTouchPriority(priority)
    self.infoLayer:addChild(chatSpriteMenu,3)

    self.m_chatBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),chatHandler)
    self.m_chatBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,40))
    self.m_chatBg:setAnchorPoint(ccp(0,0.5))
    self.m_chatBg:setPosition(15,posY)
    self.infoLayer:addChild(self.m_chatBg,2)
    self.m_chatBg:setTouchPriority(priority)

    self:setLastChat()
end

function ltzdzMapDialog:refreshChat(data)
    local cType=data.cType
    self.chatType=cType
    local color,icon=ltzdzChatVoApi:getTypeInfo(cType)
    if self.m_labelLastType then
        local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon)
        if frame1 then
            self.m_labelLastType:setDisplayFrame(frame1)
        end
    else
        self.m_labelLastType = CCSprite:createWithSpriteFrameName(icon)
        self.m_chatBg:addChild(self.m_labelLastType,2)
    end

    local sizeSp=36
    local typeScale=sizeSp/self.m_labelLastType:getContentSize().width
    self.m_labelLastType:setAnchorPoint(ccp(0.5,0.5))
    self.m_labelLastType:setPosition(ccp(5+sizeSp/2,self.m_chatBg:getContentSize().height/2))
    
    self.m_labelLastType:setScale(typeScale)

    local nameStr=ltzdzChatVoApi:getNameStr(data)
    if self.m_labelLastName then
        self.m_labelLastName:setString(nameStr)
    else
        self.m_labelLastName=GetTTFLabel(nameStr,25)
        self.m_labelLastName:setAnchorPoint(ccp(0,0.5))
        self.m_labelLastName:setPosition(ccp(5+sizeSp,self.m_chatBg:getContentSize().height/2))
        self.m_chatBg:addChild(self.m_labelLastName,2)
        
    end
    if color then
       self.m_labelLastName:setColor(color)
    end

    local xPos=sizeSp+5
    xPos=xPos+self.m_labelLastName:getContentSize().width

    if self.m_labelLastMsg then
        self.m_labelLastMsg:setString(data.msg)
    else
        self.m_labelLastMsg=GetTTFLabelWrap(data.msg,25,CCSizeMake(self.m_chatBg:getContentSize().width-xPos-50,40),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.m_labelLastMsg:setAnchorPoint(ccp(0,0.5))
        self.m_labelLastMsg:setPosition(ccp(xPos,self.m_chatBg:getContentSize().height/2))
        self.m_chatBg:addChild(self.m_labelLastMsg,2)
        
    end
    if color then
       self.m_labelLastMsg:setColor(color)
    end
    self.m_labelLastMsg:setDimensions(CCSize(self.m_chatBg:getContentSize().width-xPos-50,40))
    self.m_labelLastMsg:setPosition(ccp(xPos,self.m_chatBg:getContentSize().height/2))
    
end

function ltzdzMapDialog:setLastChat()
    local chatList1=ltzdzChatVoApi:getChat1()
    local chatList2=ltzdzChatVoApi:getChat2()
    local chatNum1=#chatList1
    local chatNum2=#chatList2
    if chatNum1==0 and chatNum2==0 then
        return
    elseif chatNum1~=0 and chatNum2~=0 then
        local chatVo1=chatList1[chatNum1]
        local chatVo2=chatList2[chatNum2]
        if chatVo2.ts>chatVo1.ts then
            self:refreshChat(chatVo2)
        else
            self:refreshChat(chatVo1)
        end
    elseif chatNum1==0 and chatNum2~=0 then
        local chatVo2=chatList2[chatNum2]
        self:refreshChat(chatVo2)
    elseif chatNum1~=0 and chatNum2==0 then
        local chatVo1=chatList1[chatNum1]
        self:refreshChat(chatVo1)
    end
end


function ltzdzMapDialog:refreshCity(city)
    -- citySp:setTag(v.id+10000)
    if city then
        local mapCfg=ltzdzVoApi:getMapCfg()
        local cityCfg=mapCfg.citycfg
        local uid=playerVoApi:getUid()

        local mapVo=ltzdzFightApi.mapVo
        local mapUser=mapVo.user

        for k,v in pairs(city) do
            local cityTag=cityCfg[k].id+10000
            local citySp=tolua.cast(self.background:getChildByTag(cityTag),"LuaCCSprite")
            if citySp then
                local cityType=cityCfg[k].type
                local cLevel=ltzdzFightApi:getCityLevel(k,city)
                local iconPic=ltzdzFightApi:getCityPic(cityType,cLevel)
                local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconPic)
                if frame1 then
                    citySp:setDisplayFrame(frame1)
                end

                if v.oid then
                    self:addOrRefreshCityChild(citySp,uid,v.oid,v,cityType,k)
                    -- 刷新小地图颜色
                    -- self:setMiniMapPointColor(mapUser,tostring(v.oid ),cityTag)

                else -- 投降之后变成
                    -- print("投降之后变成",k)
                    local flag=self:scoutRefresh(k,citySp,uid,cityType)
                    if not flag then
                        local cityChild=tolua.cast(citySp:getChildByTag(101),"LuaCCScale9Sprite")
                        if cityChild then
                            cityChild:removeFromParentAndCleanup(true)
                        end
                    end
                end
                self:setMiniMapPointColor(mapUser,v.oid,cityTag)
            end

        end
    end

end


function ltzdzMapDialog:addMiniMap()
    -- self.miniMapLayer=self.infoLayer
    -- self.bgLayer:addChild(self.miniMapLayer,3)

    local function showMiniMap()
        self:removeOperateLayer()
        local tmpBtn=tolua.cast(self.miniMapLayer:getChildByTag(512),"CCMenu")
        local tmpMap=tolua.cast(self.miniMapLayer:getChildByTag(513),"CCSprite")
        if(tmpBtn and tmpMap)then
            if(tmpMap:isVisible())then
                self:showMiniMap(tmpBtn,tmpMap,false,self.rotateChild)
            else
                self:showMiniMap(tmpBtn,tmpMap,true,self.rotateChild)
            end
        end
    end
    local mapMenuItem=GetButtonItem("miniMapBtn2.png","miniMapBtn2_down.png","miniMapBtn2_down.png",showMiniMap,nil,nil,nil)
    local mapMenu=CCMenu:createWithItem(mapMenuItem)
    mapMenu:setPosition(ccp(G_VisibleSizeWidth,355-150))
    mapMenu:setTouchPriority(-(self.layerNum-1)*20-6)
    self.miniMapLayer:addChild(mapMenu,3)
    mapMenu:setTag(512)

    local rotateChild=CCSprite:createWithSpriteFrameName("miniMapBtn2_pointer.png")
    mapMenuItem:addChild(rotateChild)
    self.rotateChild=rotateChild
    local centerPoint=getCenterPoint(rotateChild)
    rotateChild:setPosition(centerPoint)

    local function onClickMiniMap(object,fn,tag)
    end
    local miniMap=LuaCCSprite:createWithSpriteFrameName("ltzdz_smallMap.png",onClickMiniMap)
    miniMap:setAnchorPoint(ccp(1,0))
    miniMap:setPosition(ccp(999333,315-150))
    miniMap:setTouchPriority(-(self.layerNum-1)*20-6)
    miniMap:setVisible(false)
    miniMap:setTag(513)
    self.miniMapLayer:addChild(miniMap,2)
    self.miniMap=miniMap

    local miniMapSize=miniMap:getContentSize()
    self.miniMapSize=miniMapSize
    local clayer=CCLayerColor:create(ccc4(0,0,0,0))

    clayer:setTouchEnabled(true)
    clayer:setTouchPriority(-(self.layerNum-1)*20-7)
    -- clayer:setBSwallowsTouches(false)
    local function tmpHandler(fn,x,y,touch)
        if miniMap:isVisible() then
            if x and y then
                local point=miniMap:convertToNodeSpace(ccp(x,y))
                if point.x>0 and point.x<miniMapSize.width and point.y>0 and point.y<miniMapSize.height then
                else
                    return false
                end
            end
            

            if fn=="began" then
                if self.touchEnable==false then
                    do
                        return
                    end
                end
                return 1
            elseif fn=="ended" then
                if self.touchEnable==false then
                    do
                        return
                    end
                end
                self:removeOperateLayer()
                local point=miniMap:convertToNodeSpace(ccp(x,y))
                if point.x>0 and point.x<miniMapSize.width and point.y>0 and point.y<miniMapSize.height then
                    -- local bgScale=self.background:getScale()
                    -- print("pointpoint",point.x,point.y)
                    local posX=math.floor(point.x/miniMapSize.width*self.mapSize.x)
                    local posY=math.floor(point.y/miniMapSize.height*self.mapSize.y)
                    -- print("posX,posY",posX,posY)
                    -- if posX==0 then
                    --     posX=1
                    -- end
                    -- if posY==0 then
                    --     posY=1
                    -- end
                    -- if posX>self.mapSize.x then
                    --     posX=self.mapSize.x
                    -- end
                    -- if posY>self.mapSize.y then
                    --     posY=self.mapSize.y
                    -- end
                    self:focus(posX,posY)
                end
            end
        end
       
    end
    clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-7,false)
    clayer:setPosition(0,0)
    miniMap:addChild(clayer)
    clayer:setContentSize(miniMapSize)

    -- 添加地图边装饰
    local decorationSp=CCSprite:createWithSpriteFrameName("miniMapNew_ decoration.png")
    miniMap:addChild(decorationSp)
    decorationSp:setPosition(miniMapSize.width+15,decorationSp:getContentSize().height/2-11)

    -- -- 添加东南西北
    -- local posTb={{"W",ccp(20,miniMapSize.height/2)},{"S",ccp(miniMapSize.width/2,20)},{"E",ccp(miniMapSize.width-20,miniMapSize.height/2)},{"N",ccp(miniMapSize.width/2,miniMapSize.height-20)}}
    -- for k,v in pairs(posTb) do
    --     local directionLb=GetTTFLabel(v[1],22)
    --     miniMap:addChild(directionLb)
    --     directionLb:setPosition(v[2])
    --     directionLb:setColor(G_ColorGreen)
    -- end

    -- 添加大缩略图按钮
    local function onShowSearchDialog()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:removeOperateLayer()
        local tmpBtn=tolua.cast(self.miniMapLayer:getChildByTag(512),"CCMenu")
        local tmpMap=tolua.cast(self.miniMapLayer:getChildByTag(513),"CCSprite")
        if(tmpBtn and tmpMap)then
            self:showMiniMap(tmpBtn,tmpMap,false,self.rotateChild)
        end
        local function touchCallBack()
            if(tmpBtn and tmpMap)then
                self:showMiniMap(tmpBtn,tmpMap,true,self.rotateChild)
            end 
        end
        ltzdzFightApi:showSmallMapDialog(self.layerNum+1,true,true,touchCallBack,self)
    end
    local searchBtn=GetButtonItem("miniMapBtn_search.png","miniMapBtn_search_down.png","miniMapBtn_search_down.png",onShowSearchDialog,nil,nil,nil)
    local searchMenu=CCMenu:createWithItem(searchBtn)
    searchMenu:setPosition(ccp(miniMapSize.width+searchBtn:getContentSize().width/2+5,miniMapSize.height/2+13))
    searchMenu:setTouchPriority(-(self.layerNum-1)*20-7)
    miniMap:addChild(searchMenu)

    -- 扩大点击区域 
    local sbBigSp=LuaCCSprite:createWithSpriteFrameName("miniMapNew.png",onShowSearchDialog)
    sbBigSp:setScaleX(80/sbBigSp:getContentSize().width)
    sbBigSp:setScale(100/sbBigSp:getContentSize().height)
    -- sbBigSp:setContentSize(CCSizeMake(100,150))
    sbBigSp:setAnchorPoint(ccp(0,0))
    sbBigSp:setPosition(0,0)
    sbBigSp:setTouchPriority(-(self.layerNum-1)*20-6)
    searchBtn:addChild(sbBigSp)
    sbBigSp:setVisible(false)

    local myView=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_selectRange.png",CCRect(4, 4, 1, 1),function()end)
    -- myView:setColor(G_ColorGreen)
    -- CCSprite:createWithSpriteFrameName("miniMapBtn_select.png")
    miniMap:addChild(myView,5)
    myView:setAnchorPoint(ccp(0.5,0.5))
    -- self.background
    self.myView=myView

end

function ltzdzMapDialog:mapMove(point)
    if self.myView then

        local scaleX=self.miniMapSize.width/(self.mapSize.x)
        local scaleY=self.miniMapSize.height/(self.mapSize.y)
        
        local backgroundScale=self.background:getScale()

        local nowViewSize=CCSizeMake(scaleX*G_VisibleSizeWidth/backgroundScale,scaleY*G_VisibleSizeHeight/backgroundScale)
        self.myView:setContentSize(nowViewSize)
        local myViewSize=self.myView:getContentSize()

        local centerX=point.x+G_VisibleSizeWidth/2
        local centerY=point.y+G_VisibleSizeHeight/2

        
        
        local trueX=(centerX)*scaleX/backgroundScale
        local trueY=(centerY)*scaleY/backgroundScale

        if trueX>self.miniMapSize.width-myViewSize.width/2 then
            trueX=self.miniMapSize.width-myViewSize.width/2
        elseif trueX<myViewSize.width/2 then
            trueX=myViewSize.width/2
        end
        if trueY>self.miniMapSize.height-myViewSize.height/2 then
            trueY=self.miniMapSize.height-myViewSize.height/2
        elseif trueY<myViewSize.height/2 then
            trueY=myViewSize.height/2
        end
        self.myView:setPosition(trueX,trueY)
    end
end

function ltzdzMapDialog:showMiniMap(btn,map,isShow,rotateChild)
    btn:stopAllActions()
    map:stopAllActions()
    if(isShow)then
        map:setScale(0.1)
        map:setPositionX(999333)
        btn:setPositionX(G_VisibleSizeWidth)
        local function onBtnShow()
            map:setVisible(true)
            map:setPositionX(G_VisibleSizeWidth-80)
            local scaleTo=CCScaleTo:create(0.3,1)
            local acArr2=CCArray:create()
            acArr2:addObject(scaleTo)
            local seq2=CCSequence:create(acArr2)
            map:runAction(seq2)
        end
        local callFunc=CCCallFunc:create(onBtnShow)
        local moveTo=CCMoveTo:create(0.2,CCPointMake(G_VisibleSizeWidth-44,355-150))

        local function rotateFunc()
            local rotateT1 = CCRotateBy:create(0.2,360)
            local rotateT2 = CCRotateBy:create(0.5,360)
            local seq=CCSequence:createWithTwoActions(rotateT1,rotateT2)
            rotateChild:runAction(seq)
        end
        local callFunc2=CCCallFunc:create(rotateFunc)
        local delayAc=CCDelayTime:create(0.2)

        local acArr=CCArray:create()
        acArr:addObject(moveTo)
        acArr:addObject(callFunc2)
        acArr:addObject(delayAc)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        btn:runAction(seq)

    else
        map:setScale(1)
        map:setPositionX(G_VisibleSizeWidth-80)
        btn:setPositionX(G_VisibleSizeWidth-44)
        local function onMapHide()
            map:setVisible(false)
            map:setPositionX(999333)
            local moveTo=CCMoveTo:create(0.2,CCPointMake(G_VisibleSizeWidth,355-150))
            local acArr2=CCArray:create()
            acArr2:addObject(moveTo)
            local seq2=CCSequence:create(acArr2)
            btn:runAction(seq2)
        end
        local callFunc=CCCallFunc:create(onMapHide)
        local scaleTo=CCScaleTo:create(0.3,0.1)
        local acArr=CCArray:create()
        acArr:addObject(scaleTo)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        map:runAction(seq)
    end
end

function ltzdzMapDialog:getResLb(rtype,target,pos,num)
    if target==nil then
        return nil,nil
    end
    local function nilFunc()
    end
    local resbg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_resBg.png",CCRect(10,10,10,10),nilFunc)
    resbg:setContentSize(CCSizeMake(130,30))
    resbg:setAnchorPoint(ccp(0,0.5))
    resbg:setPosition(pos)
    target:addChild(resbg)
    local iconStr=ltzdzVoApi:getResPicByType(rtype)
    local resIcon=CCSprite:createWithSpriteFrameName(iconStr)
    -- resIcon:setAnchorPoint(ccp(0,0.5))
    resIcon:setPosition(0,resbg:getContentSize().height/2)
    resbg:addChild(resIcon)
    local numLb=GetTTFLabel(num,22)
    numLb:setAnchorPoint(ccp(0,0.5))
    numLb:setPosition(resIcon:getPositionX()+resIcon:getContentSize().width/2,resIcon:getPositionY())
    resbg:addChild(numLb)

    return numLb,resbg
end

function ltzdzMapDialog:getBotton(target,pos,btnStr,normalPic,selectPic,disablePic,callback,bottomFlag,bgFlag,tipType)
    local function touchHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local btnItem
    if bottomFlag and bottomFlag==true then
        btnItem=GetButtonItem(normalPic,selectPic,disablePic,touchHandler,nil,nil,25)
        local btnLb=GetTTFLabelWrap(btnStr,20,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        btnLb:setAnchorPoint(ccp(0.5,1))
        btnLb:setPosition(btnItem:getContentSize().width/2,20)
        btnItem:addChild(btnLb,2)
        local btnLb2=GetTTFLabelWrap(btnStr,20,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        btnLb2:setAnchorPoint(ccp(0.5,1))
        btnLb2:setColor(G_ColorBlack)
        btnLb2:setPosition(btnItem:getContentSize().width/2-1,19)
        btnItem:addChild(btnLb2)
    else
        btnItem=GetButtonItem(normalPic,selectPic,disablePic,touchHandler,nil,btnStr,25)
    end
    local btnMenu=CCMenu:createWithItem(btnItem)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    btnMenu:setPosition(pos)
    target:addChild(btnMenu,1)
    if bgFlag and bgFlag==true then
        local bgSp=CCSprite:createWithSpriteFrameName("ltzdz_btnBg.png")
        bgSp:setPosition(pos)
        target:addChild(bgSp)

        if tipType then
            local tipSp=CCSprite:createWithSpriteFrameName("NumBg.png")
            tipSp:setScale(0.6)
            tipSp:setPosition(pos.x+bgSp:getContentSize().width/2-5,pos.y-bgSp:getContentSize().height/2+15)
            tipSp:setVisible(false)
            target:addChild(tipSp,3)
            if self.tipSpTb==nil then
                self.tipSpTb={}
            end
            self.tipSpTb[tipType]=tipSp
            self:refreshTip(tipType) --刷新红点提示
        end
    end

    return btnItem,btnMenu
end

function ltzdzMapDialog:refreshResLb()
    local metal,oil,gems=0,0
    local myinfo=ltzdzFightApi:getUserInfo()
    if myinfo then
        metal=myinfo.metal or 0
        oil=myinfo.oil or 0
        gems=myinfo.gems or 0
    end
    if self.metalLb and self.oilLb and self.gemsLb then
        self.gemsLb:setString(gems)
        self.metalLb:setString(metal)
        self.oilLb:setString(oil)
    end
end

function ltzdzMapDialog:cityChildVisible(isVisible)
    if self.operateId then
        local citySp=tolua.cast(self.background:getChildByTag(self.operateId),"LuaCCSprite")
        if citySp then
            local cityChild=tolua.cast(citySp:getChildByTag(101),"LuaCCScale9Sprite")
            if cityChild then
                local child1=tolua.cast(cityChild:getChildByTag(2),"CCProgressTimer")
                if child1 then
                    child1:setVisible(isVisible)
                end
                local child2=tolua.cast(cityChild:getChildByTag(11),"CCSprite")
                if child2 then
                    child2:setVisible(isVisible)
                end
                local child3=tolua.cast(cityChild:getChildByTag(3),"LuaCCScale9Sprite")
                if child3 then
                    child3:setVisible(isVisible)
                end
            end
        end
    end
end

function ltzdzMapDialog:fadeAction()
    local fadeTo = CCFadeTo:create(0.1, 150)
    local fadeBack = CCFadeTo:create(0.1, 255)
    local acArr = CCArray:create()
    acArr:addObject(fadeTo)
    acArr:addObject(fadeBack)
    local seq = CCSequence:create(acArr)
    return seq
end

function ltzdzMapDialog:foldAction(scale)
    local bigScale=scale+0.2
    local smallScale=scale-0.3
    local scaleTo1=CCScaleTo:create(0.1,bigScale)
    local scaleTo2=CCScaleTo:create(0.1,scale)
    local acArr=CCArray:create()
    acArr:addObject(scaleTo1)
    acArr:addObject(scaleTo2)
    local seq=CCSequence:create(acArr)
    return seq

end

-- 创建操作层
function ltzdzMapDialog:creatOperateLayer(cid,pos)
    -- print("11111111111")
    -- if self.selectCid==cid then
    --     do return end
    -- end
    self:removeOperateLayer()
    self.selectCid=cid

    self.operateLayer=CCLayer:create()
    self.bgLayer:addChild(self.operateLayer,5)
    local worldPos=self.background:convertToWorldSpace(ccp(pos[1],pos[2]))

    local mapCfg=ltzdzVoApi:getMapCfg()
    local cityCfg=mapCfg.citycfg
    local id=cityCfg[cid].id
    self.operateId=id+10000
    local citySp=tolua.cast(self.background:getChildByTag(self.operateId),"LuaCCSprite")
    self:cityChildVisible(false)

    citySp:runAction(self:fadeAction())
    

    local citySize=citySp:getContentSize()
    local cityScale=self.background:getScale()
    -- local bgSize=CCSizeMake(citySize.width*cityScale,citySize.height*cityScale)
    local bgSize=CCSizeMake(citySize.width,citySize.height)

    local selectBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    selectBg:setContentSize(bgSize)
    self.operateLayer:addChild(selectBg)
    selectBg:setPosition(worldPos)
    selectBg:setOpacity(0)
    selectBg:setScale(cityScale-0.3)

    selectBg:runAction(self:foldAction(cityScale))

    -- print("cityScale",cityScale)

    -- city等级
    
    local mapVo=ltzdzFightApi.mapVo
    local cityVo
    if mapVo then
        cityVo=mapVo.city
    end
    local cityLv=ltzdzFightApi:getCityLevel(cid,cityVo)

    local cityLvLb=GetTTFLabel(getlocal("ltzdz_city_type_" .. cityCfg[cid].type,{cityLv}),22)
    selectBg:addChild(cityLvLb,1)
    cityLvLb:setPosition(getCenterPoint(selectBg))
    local cityLvBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4, 4, 1, 1),function ()end)
    selectBg:addChild(cityLvBg)
    cityLvBg:setContentSize(cityLvLb:getContentSize())
    cityLvBg:setPosition(getCenterPoint(selectBg))
    cityLvBg:setOpacity(120)


    local btnBg=CCSprite:createWithSpriteFrameName("ltztz_btnbg.png")
    selectBg:addChild(btnBg)
    btnBg:setPosition(bgSize.width/2+25,bgSize.height)

    local bgSize=selectBg:getContentSize()

    local occupyFlag=ltzdzFightApi:cityBelong(cid)
    -- print("occupyFlag",occupyFlag)
    if occupyFlag==1 or occupyFlag==2 then -- 自己
        if occupyFlag==1 then
            local function touchGoCityFunc()
                -- 进城之前删除操作层
                self:removeOperateLayer()
                self:showCity(cid)
            end
            local cityItem,cityBtn=G_createBotton(btnBg,ccp(62.5, 68),{getlocal("ltzdz_go_city"),22},"ltzdz_btnKuang.png","ltzdz_btnKuangDown.png","ltzdz_btnKuangDown.png",touchGoCityFunc,1,-(self.layerNum-1)*20-6,nil,nil)
            cityBtn:setBSwallowsTouches(true)
            local enterCity=CCSprite:createWithSpriteFrameName("ltzdz_enterBtn.png")
            cityItem:addChild(enterCity)
            enterCity:setPosition(getCenterPoint(cityItem))

            local cityLb=tolua.cast(cityItem:getChildByTag(101),"CCLabelTTF")
            cityLb:setPositionY(10)


            local function showTroopsFunc()
                local function refreshFunc()
                    self:removeOperateLayer()
                    self:creatOperateLayer(cid,pos)
                end
                ltzdzFightApi:showTroopDialog(self.layerNum+1,cid,refreshFunc)
            end
            local troopItem,troopBtn=G_createBotton(btnBg,ccp(145.5, 38),{getlocal("fleetInfoTitle2"),22},"ltzdz_btnKuang.png","ltzdz_btnKuangDown.png","ltzdz_btnKuangDown.png",showTroopsFunc,1,-(self.layerNum-1)*20-6,nil,nil)
            troopBtn:setBSwallowsTouches(true)
            local enterTroop=CCSprite:createWithSpriteFrameName("ltzdz_troopsBtn.png")
            troopItem:addChild(enterTroop)
            enterTroop:setPosition(getCenterPoint(troopItem))

            local troopLb=tolua.cast(troopItem:getChildByTag(101),"CCLabelTTF")
            troopLb:setPositionY(10)
        else
            btnBg:setOpacity(0)
        end

        local tankD=ltzdzFightApi:getDefenceByCid(cid)
        local numFlag=false
        for k,v in pairs(tankD) do
            if v and v[1] then
                numFlag=true
            end
        end
        if numFlag then
            local tankIconSize=45
            local tankJiange=5
            local sideW=15
            local diH=10
            local function sbCallback()
            end
            local tankBg =LuaCCScale9Sprite:createWithSpriteFrameName("fleetKuangBg.png",CCRect(11, 11, 1, 1),sbCallback)
            tankBg:setContentSize(CCSizeMake(tankIconSize*2+tankJiange+sideW*2,tankIconSize*3+tankJiange*3+10+40))
            selectBg:addChild(tankBg)
            tankBg:setAnchorPoint(ccp(1,0.5))
            tankBg:setPosition(35,selectBg:getContentSize().height/2+60)
            local tankBgSize=tankBg:getContentSize()

            -- local_war_npc_name
            local titleLb=GetTTFLabelWrap(getlocal("local_war_npc_name"),20,CCSizeMake(tankBgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tankBg:addChild(titleLb)
            titleLb:setPosition(tankBgSize.width/2,tankBgSize.height-20)
            titleLb:setColor(G_ColorGreen)

            local modifyLineSp1=CCSprite:createWithSpriteFrameName("decorateLine.png")
            modifyLineSp1:setAnchorPoint(ccp(0,1))
            tankBg:addChild(modifyLineSp1)
            modifyLineSp1:setPosition(3,tankBgSize.height-25)

            local modifyLineSp2=CCSprite:createWithSpriteFrameName("decorateLine.png")
            modifyLineSp2:setAnchorPoint(ccp(1,0))
            tankBg:addChild(modifyLineSp2)
            modifyLineSp2:setPosition(tankBgSize.width-3,5)
            modifyLineSp2:setFlipX(true)

            local tankNeiBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4, 4, 1, 1),function ()end)
            tankBg:addChild(tankNeiBg)
            tankNeiBg:setContentSize(CCSizeMake(tankIconSize*2+10+tankJiange,tankIconSize*3+tankJiange*2+10))
            tankNeiBg:setAnchorPoint(ccp(0.5,0))
            tankNeiBg:setPosition(tankBgSize.width/2,5)

            local posTb={ccp(tankIconSize+tankJiange+sideW,tankIconSize*2+tankJiange*2+diH),ccp(tankIconSize+tankJiange+sideW,tankIconSize*1+tankJiange+diH),ccp(tankIconSize+tankJiange+sideW,tankIconSize*0+diH),ccp(sideW,tankIconSize*2+tankJiange*2+diH),ccp(sideW*1,tankIconSize*1+tankJiange+diH),ccp(sideW*1,tankIconSize*0+diH)}
            local tankD=ltzdzFightApi:getDefenceByCid(cid)
            local tankD,heroD,emblemID,planePos,aitroops,tskin=ltzdzFightApi:getDefenceByCid(cid)
            for i=1,6 do
                if tankD[i] and tankD[i][1] then
                    local tankId=tankD[i][1]
                    local skinId=tskin[tankSkinVoApi:convertTankId(tankId)]
                    local tankSp= tankVoApi:getTankIconSp(tankId,skinId,nil,false)
                    local spScale=tankIconSize/tankSp:getContentSize().width
                    tankSp:setPosition(posTb[i])
                    tankSp:setScale(spScale)
                    tankBg:addChild(tankSp,3)
                    tankSp:setAnchorPoint(ccp(0,0))

                    if tankId~=G_pickedList(tankId) then
                        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                        tankSp:addChild(pickedIcon)
                        pickedIcon:setPosition(tankSp:getContentSize().width-30,30)
                        pickedIcon:setScale(1.5)
                    end
                    local numLb=GetTTFLabel(tankD[i][2],15/spScale)
                    tankSp:addChild(numLb,1)
                    numLb:setPosition(tankSp:getContentSize().width/2,10)

                    local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4, 4, 1, 1),function ()end)
                    tankSp:addChild(numBg)
                    numBg:setContentSize(CCSizeMake(tankIconSize,20))
                    numBg:setAnchorPoint(ccp(0.5,0.5))
                    numBg:setPosition(tankSp:getContentSize().width/2,10)
                    numBg:setScale(1/spScale)
                    numBg:setOpacity(120)

                else
                    -- 后续补充
                    local tankSp= CCSprite:createWithSpriteFrameName("tankShadeIcon.png")
                    local spScale=tankIconSize/tankSp:getContentSize().width
                    tankSp:setPosition(posTb[i])
                    tankSp:setScale(spScale)
                    tankBg:addChild(tankSp,3)
                    tankSp:setAnchorPoint(ccp(0,0))
                end
            end
        end

    -- elseif occupyFlag==2 then -- 同盟

    else -- 无人占领的城 和 敌人
        local function touchScoutFunc()
            local function isScoutFunc()
                local function showScout(clearCid)
                    self:removeOperateLayer()
                    local scoutInfo=ltzdzFightApi:getScoutInfo(cid)
                    ltzdzFightApi:showScoutInfo(self.layerNum+1,true,true,nil,getlocal("scout_content_scout_title"),nil,true,scoutInfo)
                    local cityType=cityCfg[cid].type
                    local uid=playerVoApi:getUid()
                    local oid
                    if cityVo and cityVo[cid] and cityVo[cid].oid and tonumber(cityVo[cid].oid)~=0 then
                        oid=tonumber(cityVo[cid].oid)
                    end
                    self:scoutRefresh(cid,citySp,uid,cityType,oid)
                    -- print("clearCid====>>>",clearCid)
                    if clearCid then --侦查城市个数达到上限后，要清除最早的侦查数据，clearCid就是最早被侦查的城市
                        local cityType=cityCfg[clearCid].type
                        local uid=playerVoApi:getUid()
                        local oid
                        local mapVo=ltzdzFightApi.mapVo
                        local cityVo
                        if mapVo then
                            cityVo=mapVo.city
                        end
                        if cityVo and cityVo[clearCid] and cityVo[clearCid].oid and tonumber(cityVo[clearCid].oid)~=0 then
                            oid=tonumber(cityVo[clearCid].oid)
                        end
                        local flag=self:scoutRefresh(clearCid,citySp,uid,cityType,oid)
                        if flag==false and self.background then
                            local cityTag=cityCfg[clearCid].id+10000
                            local citySp=tolua.cast(self.background:getChildByTag(cityTag),"LuaCCSprite")
                            if citySp then
                                local cityInfo
                                if cityVo and cityVo[clearCid] then
                                    cityInfo=cityVo[clearCid]
                                end
                                self:addOrRefreshCityChild(citySp,uid,oid,cityInfo,cityType,clearCid)
                            end
                        end
                    end
                end
                ltzdzCityVoApi:syncCity(cid,showScout,2)
            end
            local warcfg=ltzdzVoApi:getWarCfg()
            local spyCost=warcfg.spyCost
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_scout_des",{spyCost}),false,isScoutFunc,nil,nil)
        end
        local scoutItem,scoutBtn=G_createBotton(btnBg,ccp(62.5, 68),{getlocal("city_info_scout"),22},"ltzdz_btnKuang.png","ltzdz_btnKuangDown.png","ltzdz_btnKuangDown.png",touchScoutFunc,1,-(self.layerNum-1)*20-6,nil,nil)
        scoutBtn:setBSwallowsTouches(true)

        local enterScout=CCSprite:createWithSpriteFrameName("ltzdz_scoutBtn.png")
        scoutItem:addChild(enterScout)
        enterScout:setPosition(getCenterPoint(scoutItem))

        local scoutLb=tolua.cast(scoutItem:getChildByTag(101),"CCLabelTTF")
        scoutLb:setPositionY(10)

        -- 需要判断是否有情报
        -- print("ltzdzFightApi:scoutIsVisible(cid)",ltzdzFightApi:scoutIsVisible(cid))
        if ltzdzFightApi:scoutIsVisible(cid) then
            local function touchInfomationFunc()
                local scoutInfo=ltzdzFightApi:getScoutInfo(cid)
                    ltzdzFightApi:showScoutInfo(self.layerNum+1,true,true,nil,getlocal("scout_content_scout_title"),nil,true,scoutInfo)
            end
            local detailItem,detailBtn=G_createBotton(btnBg,ccp(145.5, 38),{getlocal("serverWarLocal_information"),22},"ltzdz_btnKuang.png","ltzdz_btnKuangDown.png","ltzdz_btnKuangDown.png",touchInfomationFunc,1,-(self.layerNum-1)*20-6,nil,nil)
            detailBtn:setBSwallowsTouches(true)

            local enterDetail=CCSprite:createWithSpriteFrameName("ltzdz_reportBtn.png")
            detailItem:addChild(enterDetail)
            enterDetail:setPosition(getCenterPoint(detailItem))

            local detailLb=tolua.cast(detailItem:getChildByTag(101),"CCLabelTTF")
            detailLb:setPositionY(10)
        end
        
    end
    
end

function ltzdzMapDialog:removeOperateLayer()
    if self.operateLayer then
        self.operateLayer:removeFromParentAndCleanup(true)
        self.operateLayer=nil
    end
    self:cityChildVisible(true)
    self.operateId=nil

end

-- bType 1:出征  2：运输
function ltzdzMapDialog:setOrTransportRefresh(data)
    self:closeCity()
    self:removeOperateLayer()
    self:setInfoLayerPos(1)

    self.setOrTransportLayer=CCLayer:create()
    self.background:addChild(self.setOrTransportLayer,3)
    self.setOrTransportFlag=true
    self.bType=data.bType
    self.startCid=data.startCid
    self.targetCityTb=data.targetCityTb

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
    titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,56))
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight)
    self.bgLayer:addChild(titleBg,4)
    titleBg:setOpacity(180)
    self.setOrTransTitleBg=titleBg

    local desLb=GetTTFLabelWrap(getlocal("ltzdz_setOrTrans_des1"),25,CCSizeMake(G_VisibleSizeWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleBg:addChild(desLb)
    desLb:setPosition(getCenterPoint(titleBg))

    -- 返回按钮
    local backBtn,backItem
    local function backFunc()
        self:removeSetOrTransport()
    end
    backBtn,backItem=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-44,G_VisibleSizeHeight-28),nil,"ltzdz_backmap.png","ltzdz_backmap.png","ltzdz_backmap.png",backFunc,1,-(self.layerNum-1)*20-4,4,nil)
    backItem:setBSwallowsTouches(true)
    self.backBtn=backBtn
    otherGuideMgr:setGuideStepField(50,nil,nil,{backBtn,1})

    local function actionFunc()
        local moveBy=CCMoveBy:create(0.35,ccp(0,-30))
        local reverseBy = moveBy:reverse()
        local seq=CCSequence:createWithTwoActions(moveBy,reverseBy)
        return CCRepeatForever:create(seq)
    end
    local otherRectTb={}    
    local mapCfg=ltzdzVoApi:getMapCfg()
    local citycfg=mapCfg.citycfg
    for k,v in pairs(self.targetCityTb) do
        if v~=3 then
            local arrowSp=CCSprite:createWithSpriteFrameName("ltzdzSelectCity.png")
            self.setOrTransportLayer:addChild(arrowSp)
            arrowSp:setPosition(citycfg[k].pos[1],citycfg[k].pos[2]+90)

            -- if v==1 then -- 能运输的城市
            --     arrowSp:setColor(G_ColorGray)
            -- end
            local cityTag=citycfg[k].id+10000
            local citySp=tolua.cast(self.background:getChildByTag(cityTag),"LuaCCSprite")
            local x,y,width,height=G_getSpriteWorldPosAndSize(citySp)
            table.insert(otherRectTb,{x,y,width,height})

            arrowSp:runAction(actionFunc())
        end
    end
    otherGuideCfg[49].otherRectTb=otherRectTb
    if otherGuideMgr.isGuiding and otherGuideMgr.curStep==48 then
        otherGuideMgr:toNextStep()
    end
end

function ltzdzMapDialog:removeSetOrTransport()
    if self.setOrTransportLayer then
        self.setOrTransportLayer:removeFromParentAndCleanup(true)
        self.setOrTransportLayer=nil
    end
    if self.backBtn then
        self.backBtn:removeFromParentAndCleanup(true)
        self.backBtn=nil
    end
    if self.setOrTransTitleBg then
        self.setOrTransTitleBg:removeFromParentAndCleanup(true)
        self.setOrTransTitleBg=nil
    end
    self:setInfoLayerPos(2)
    self.setOrTransportFlag=false
    self.bType=nil
    self.targetCityTb=nil
    self.startCid=nil
end

-- 初始化行军路线
function ltzdzMapDialog:initMatchLine()
    if G_isShowLineSprite()==false then
        return
    end

    local mapCfg=ltzdzVoApi:getMapCfg()
    local cityTb=mapCfg.citycfg

    -- k:路线(a2a4) .. (1:自己 2：同盟 3：敌人)    value sp:lineSp num：数量 tq:{队列编号}
    -- 判断 k  无，添加;有增加或者减少
    self.lineTbInfo={}

    -- user下的队列是运输队列
    local selfUserInfo=ltzdzFightApi:getUserInfo()
    if not selfUserInfo then
        do return end
    end
    local utq=selfUserInfo.tqueue
    if utq then
        for k,v in pairs(utq) do
            local lineStr=v[2] .. v[3] .. 1
            -- print("++++++++++++++++3333333utq")
            self:initLineSp(lineStr,k,cityTb,v[2],v[3],1)
        end
    end

    -- 出征队列
    local mtq=ltzdzFightApi.mapVo.tqueue
    local myUid=playerVoApi:getUid()
    local ally=selfUserInfo.ally or 0
    if mtq then
        for pid,tValue in pairs(mtq) do
            local flag=3 -- 敌人
            if tonumber(pid)==tonumber(myUid) then
                flag=1 -- 自己
            elseif tonumber(ally)==tonumber(pid) then
                flag=2 -- 同盟
            end
            for qid,value in pairs(tValue) do
                local lineStr
                if flag==1 then
                    lineStr=value[2] .. value[3] .. flag
                    -- print("++++++++++++++++555555mtq")
                    self:initLineSp(lineStr,qid,cityTb,value[2],value[3],flag)
                else
                    lineStr=value[1] .. value[2] .. flag
                    -- print("++++++++++++++++666666666mtq")
                    self:initLineSp(lineStr,qid,cityTb,value[1],value[2],flag)
                end
            end
        end
    end

    -- for k,v in pairs(self.lineTbInfo) do
    --     for kk,vv in pairs(v.tq) do
    --         print("k,vv",k,vv)
    --     end
    -- end

end

function ltzdzMapDialog:initLineSp(lineStr,qid,cityTb,startCid,endCid,flag)
    if G_isShowLineSprite()==false then
        return
    end

    if self.lineTbInfo[lineStr] then
        self.lineTbInfo[lineStr].num=self.lineTbInfo[lineStr].num+1
        table.insert(self.lineTbInfo[lineStr].tq,qid)
    else
        -- print(",startCid,endCid,flag")
        local tankLineSp=self:getLineSp(startCid,endCid,cityTb)
        if flag==1 then
            tankLineSp:setColor(G_ColorGreen)
        else
            tankLineSp:setColor(G_ColorRed)
        end
        self.background:addChild(tankLineSp,5)
        self.lineTbInfo[lineStr]={sp=tankLineSp,num=1,tq={qid}}
    end
end

function ltzdzMapDialog:getLineSp(startCid,endCid,cityTb)
    -- print("startCid,endCid",startCid,endCid)
    local tankLineSp = LineSprite:create("public/fleetLineWhite.png")
    local startPos=ccp(cityTb[startCid].pos[1],cityTb[startCid].pos[2])
    local endPos=ccp(cityTb[endCid].pos[1],cityTb[endCid].pos[2])
    tankLineSp:setSpeed(0.13)
    tankLineSp:setLine(startPos,endPos)
    -- self.background:addChild(tankLineSp,2)
    return tankLineSp
end

-- 从后台进入前台，或者前后台数据不一致
function ltzdzMapDialog:reCreate()
    if self.lineTbInfo then
        for k,v in pairs(self.lineTbInfo) do
            if v and v.sp then
                v.sp:removeFromParentAndCleanup(true)
            end
        end
    end
    self.lineTbInfo=nil 
    self.lineTbInfo={}

    self.tickFleetTimer=nil

    if self.miniFleetSlotLayer then
        self.miniFleetSlotLayer:removeFromParentAndCleanup(true)
        self.miniFleetSlotLayer=nil
    end
    self:initMiniFleetSlotLayer()
    self:initMatchLine()
end

function ltzdzMapDialog:refreshMatchLine(data)
    if data.delete==1 then -- 同步数据，不是差量更新
        -- print("++++++++++data.delete",data.delete)
        self:reCreate()
        do return end
    end

    if not self.lineTbInfo then
        self.lineTbInfo={}
    end

    local mapCfg=ltzdzVoApi:getMapCfg()
    local cityTb=mapCfg.citycfg

    local selfUserInfo=ltzdzFightApi:getUserInfo()
    if not selfUserInfo then
        do return end
    end
    local myUid=playerVoApi:getUid()
    local ally=selfUserInfo.ally or 0

    if data.mtq then
        for k,v in pairs(data.mtq) do
            local flag=3 -- 敌人
            if tonumber(k)==tonumber(myUid) then
                flag=1 -- 自己
            elseif tonumber(ally)==tonumber(k) then
                flag=2 -- 同盟
            end
            for kk,vv in pairs(v) do
                if vv and #vv~=0 then -- 添加
                    local lineStr
                    if flag==1 then
                        lineStr=vv[2] .. vv[3] .. flag
                        -- print("++++++++++++++++111111mtq")
                        self:initLineSp(lineStr,kk,cityTb,vv[2],vv[3],flag)

                    else
                        lineStr=vv[1] .. vv[2] .. flag
                        -- print("++++++++++++++++22222mtq")
                        self:initLineSp(lineStr,kk,cityTb,vv[1],vv[2],flag)
                    end
                else -- 删除
                    -- print("++++++++++++删除")
                    for lstr,value in pairs(self.lineTbInfo) do
                        for num,qid in pairs(value.tq) do
                            if qid==kk then
                                self.lineTbInfo[lstr].num=self.lineTbInfo[lstr].num-1
                                if self.lineTbInfo[lstr].num<=0 then
                                    self.lineTbInfo[lstr].sp:removeFromParentAndCleanup(true)
                                    self.lineTbInfo[lstr]=nil
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif data.utq then
        for k,v in pairs(data.utq) do
            if v and #v~=0 then -- 添加
                local lineStr=v[2] .. v[3] .. 1
                -- print("++++++++++++++++1111utq")
                self:initLineSp(lineStr,k,cityTb,v[2],v[3],1)
            else -- 删除
                for lstr,value in pairs(self.lineTbInfo) do
                    for num,qid in pairs(value.tq) do
                        if qid==k then
                            self.lineTbInfo[lstr].num=self.lineTbInfo[lstr].num-1
                            if self.lineTbInfo[lstr].num<=0 then
                                self.lineTbInfo[lstr].sp:removeFromParentAndCleanup(true)
                                self.lineTbInfo[lstr]=nil
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    self:resetFleetSlotLayerSize()


end

function ltzdzMapDialog:initMiniFleetSlotLayer()
    if self.miniFleetSlotLayer==nil then
        self.allSlot=ltzdzFightApi:getSelfAllSlot()
        self.allSlotNum=#self.allSlot
        if self.allSlotNum<=0 then
            return
        elseif self.allSlotNum>5 then
            self.allSlotNum=5
        end

        local function nilFunc( ... )
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if self.miniFleetSlotLayer:isVisible()==false then
                return
            end
            PlayEffect(audioCfg.mouseClick)
            self:removeOperateLayer()
            ltzdzFightApi:showSlotInfo(self.layerNum+1,true,true,nil,getlocal("ltzdz_march_slot"),self)
        end
        self.miniFleetSlotLayer = LuaCCScale9Sprite:createWithSpriteFrameName("fleet_slot_mini_bg.png",CCRect(70, 43, 1, 1),nilFunc)
        -- 一行数据的高度是41个像素
        local layerHeight = 46*(self.allSlotNum)+30
        -- print("layerHeight",layerHeight)
        local layerSize = CCSizeMake(218,layerHeight)
        self.miniFleetSlotLayer:setContentSize(layerSize)
        self.miniFleetSlotLayer:setAnchorPoint(ccp(0,1))
        local layerPosX = 0
        local layerPosY = G_VisibleSize.height-145--115
        self.miniFleetSlotLayer:setPosition(ccp(layerPosX,layerPosY))
        self.bgLayer:addChild(self.miniFleetSlotLayer,6)
        self.miniFleetSlotLayer:setTouchPriority(-(self.layerNum-1)*20-6)
        self.miniFleetSlotLayer:setIsSallow(true)

        otherGuideMgr:setGuideStepField(53,nil,nil,{self.miniFleetSlotLayer,1})

        -- 添加开关按钮
        local flagXoff = 0
        local flagYoff = 0
        local togScale = 0.85

        local function pushMiniFleetFunc(tag,object)
            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable()==false then
                local toggleMenu = tolua.cast(object,"CCMenuItemToggle")
                if toggleMenu~=nil then
                    if toggleMenu:getSelectedIndex()==0 then
                        toggleMenu:setSelectedIndex(1)
                    else
                        toggleMenu:setSelectedIndex(0)
                    end
                end
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            local toggleMenu = tolua.cast(object,"CCMenuItemToggle")
            if toggleMenu~=nil then
                if toggleMenu:getSelectedIndex()==1 then
                    toggleMenu:setSelectedIndex(0)
                    local moveTo = CCMoveTo:create(0.3,ccp(-(layerSize.width+2),layerPosY))
                    local function setIndexFunc()
                        toggleMenu:setSelectedIndex(1)
                    end
                    local indexCallBack = CCCallFunc:create(setIndexFunc)
                    local seq = CCSequence:createWithTwoActions(moveTo,indexCallBack)
                    self.miniFleetSlotLayer:runAction(seq)

                    local leftMenu = tolua.cast(self.miniFleetSlotLayer:getChildByTag(1102),"CCMenu")
                    if leftMenu~=nil then
                        local moveBy = CCMoveBy:create(0.3,ccp(5,0))
                        leftMenu:runAction(moveBy)
                    end
                else
                    toggleMenu:setSelectedIndex(1)
                    local moveTo = CCMoveTo:create(0.3,ccp(layerPosX,layerPosY))
                    local function setIndexFunc()
                        toggleMenu:setSelectedIndex(0)
                    end
                    local indexCallBack = CCCallFunc:create(setIndexFunc)
                    local seq = CCSequence:createWithTwoActions(moveTo,indexCallBack)
                    self.miniFleetSlotLayer:runAction(seq)

                    local leftMenu = tolua.cast(self.miniFleetSlotLayer:getChildByTag(1102),"CCMenu")
                    if leftMenu~=nil then
                        local moveBy = CCMoveBy:create(0.3,ccp(-5,0))
                        leftMenu:runAction(moveBy)
                    end
                end
            end

        end

        local selectSp1 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn.png")
        local flagSp1 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        
        flagSp1:setPosition(ccp(selectSp1:getContentSize().width/2+flagXoff,selectSp1:getContentSize().height/2+flagYoff))
        flagSp1:setScale(togScale)
        selectSp1:addChild(flagSp1,1)

        local selectSp2 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn_down.png")
        local flagSp2 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        flagSp2:setScale(togScale)
        flagSp2:setPosition(ccp(selectSp2:getContentSize().width/2+flagXoff,selectSp2:getContentSize().height/2+flagYoff))
        selectSp2:addChild(flagSp2,1)

        local selectSp3 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn.png")
        local flagSp3 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        
        flagSp3:setPosition(ccp(selectSp3:getContentSize().width/2+flagXoff,selectSp2:getContentSize().height/2+flagYoff))
        flagSp3:setRotation(180)
        flagSp3:setScale(togScale)
        selectSp3:addChild(flagSp3,1)
        local selectSp4 = CCSprite:createWithSpriteFrameName("fleet_slot_left_btn_down.png")
        local flagSp4 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        flagSp4:setPosition(ccp(selectSp4:getContentSize().width/2+flagXoff,selectSp4:getContentSize().height/2+flagYoff))
        flagSp4:setRotation(180)
        flagSp4:setScale(togScale)
        selectSp4:addChild(flagSp4,1)

        local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
        local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)

        local menuToggleSmall = CCMenuItemToggle:create(menuItemSp1)
        menuToggleSmall:addSubItem(menuItemSp2)
        menuToggleSmall:registerScriptTapHandler(pushMiniFleetFunc)
        menuToggleSmall:setSelectedIndex(0)
        menuToggleSmall:setTag(1)

        local menuAllSmall=CCMenu:createWithItem(menuToggleSmall)
        local posX = self.miniFleetSlotLayer:getContentSize().width + menuToggleSmall:getContentSize().width/2-5--18
        local posY = self.miniFleetSlotLayer:getContentSize().height - menuToggleSmall:getContentSize().height/2
        menuAllSmall:setPosition(ccp(posX,posY))
        menuAllSmall:setTouchPriority(-(self.layerNum-1)*20-7)
        menuAllSmall:setTag(1102)
        self.miniFleetSlotLayer:addChild(menuAllSmall,-1)

        self.tickFleetTimer={}

        self:initFleetSlotTableView()
    end
end

function ltzdzMapDialog:initFleetSlotTableView()
    local isMoved=false
    local layerNum = 3
    local function tvHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local num = self.allSlotNum
            return num
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth = self.miniFleetSlotLayer:getContentSize().width
            local cellHeight = 45
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()

            local slotInfo=self.allSlot[idx+1].value
            local sid=self.allSlot[idx+1].sid

            local capInSet = CCRect(25, 25, 1, 1)
            local cellHeight = 45
            local cellWidth = self.miniFleetSlotLayer:getContentSize().width

            local function cellClick()
            end
            local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("fleet_slot_cell_bg.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(cellWidth-20, cellHeight-2))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0.5))
            -- backSprie:setOpacity(0)
            backSprie:setPosition(ccp(0,cellHeight/2))
            backSprie:setTag(5001+idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-5)
            cell:addChild(backSprie,1)

            local labName = GetTTFLabel(ltzdzCityVoApi:getCityName(slotInfo[3]),15)
            labName:setAnchorPoint(ccp(0.5,1))
            labName:setPosition(ccp(90,backSprie:getContentSize().height-3))
            backSprie:addChild(labName,3)

            local barName = "fleet_slot_bar_green.png"
            local barBgName = "fleet_slot_bar_bg.png"
            AddProgramTimer(backSprie,ccp(64+10,backSprie:getContentSize().height/2),9,12,"",barBgName,barName,11,nil,nil,nil,nil,16)
            local moneyTimerSprite = tolua.cast(backSprie:getChildByTag(9),"CCProgressTimer")
            self.tickFleetTimer[idx+1]=moneyTimerSprite

            self:setTimerSpPer(moneyTimerSprite,slotInfo)

            local iconWidth = 40
            local iconSp
            local iconPic=ltzdzFightApi:getIconState(slotInfo)
            iconSp=CCSprite:createWithSpriteFrameName(iconPic)
            local iconScale = iconWidth/iconSp:getContentSize().width
            iconSp:setScale(iconScale)
            iconSp:setAnchorPoint(ccp(0,0.5))
            iconSp:setPosition(ccp(0,backSprie:getContentSize().height/2-1))
            backSprie:addChild(iconSp,3)

            local function accFunc()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                -- print("++++++++加速")
                local tValue=ltzdzFightApi:getTvalueByTid("t2")
                -- tid 计策id
                ltzdzFightApi:showMarchAcc(self.layerNum+1,true,true,nil,getlocal("ltzdz_use_ploy"),nil,getlocal("ltzdz_use_acc_des",{tValue.effc*100 .. "%%"}),"t2",slotInfo[2],sid)
            end
            local processItem = GetButtonItem("BtnRight.png","BtnRight_Down.png","BtnRight_Down.png",accFunc)
            local scale=0.5
            processItem:setScale(scale)
            local processMenu = CCMenu:createWithItem(processItem)
            processMenu:setPosition(ccp(backSprie:getContentSize().width-processItem:getContentSize().width*scale/2-5,backSprie:getContentSize().height/2))
            processMenu:setTouchPriority(-(self.layerNum-1)*20-7)
            backSprie:addChild(processMenu,3)

            local flag=ltzdzFightApi:isCanAcc(slotInfo)
            processItem:setEnabled(flag)


            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then
        end
    end
    local tvWidth = self.miniFleetSlotLayer:getContentSize().width
    local tvHeight = self.miniFleetSlotLayer:getContentSize().height-30
    local hd = LuaEventHandler:createHandler(tvHandler)
    self.miniFleetSlotTv = LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.miniFleetSlotTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    self.miniFleetSlotTv:setAnchorPoint(ccp(0,0))
    self.miniFleetSlotTv:setPosition(ccp(5,8+5))
    self.miniFleetSlotLayer:addChild(self.miniFleetSlotTv)
    self.miniFleetSlotTv:setMaxDisToBottomOrTop(0)

end

function ltzdzMapDialog:showFleetLayer()
    if self.miniFleetSlotLayer and self.allSlot then
        local allSlotNum=#self.allSlot
        if allSlotNum<=0 then
            self.miniFleetSlotLayer:setVisible(false)
            do return end
        end
        self.miniFleetSlotLayer:setVisible(true)
    end
end

function ltzdzMapDialog:closeFleetLayer()
    if self.miniFleetSlotLayer then
        self.miniFleetSlotLayer:setVisible(false)
    end
end

function ltzdzMapDialog:setTimerSpPer(moneyTimerSprite,slotInfo)
    local totalTime=slotInfo[5]-slotInfo[4]
    local marchTime=base.serverTime-slotInfo[4]
    -- print("totalTime,marchTime",totalTime,marchTime)
    moneyTimerSprite:setPercentage(marchTime/totalTime*100)


    local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12),"CCLabelTTF")
    lbPer:setAnchorPoint(ccp(0.5,0))
    lbPer:setPosition(ccp(90,0))
    local subTime=slotInfo[5]-base.serverTime
    if subTime<0 then
        subTime=0
    end
    lbPer:setString(GetTimeStrForFleetSlot(subTime))
    return subTime
end


-- 更新缩略队列
function ltzdzMapDialog:resetFleetSlotLayerSize()
    if self.miniFleetSlotTv~=nil and self.miniFleetSlotLayer~=nil then

        -- 防止点开队列列表（这时候需要发一个消息刷新）
        eventDispatcher:dispatchEvent("ltzdz.refreshSlot",{})

        self.allSlot=ltzdzFightApi:getSelfAllSlot()
        self.allSlotNum=#self.allSlot
        if self.allSlotNum<=0 then
            self.miniFleetSlotLayer:setVisible(false)
            self.miniFleetSlotTv:reloadData()
            return
        elseif self.allSlotNum>5 then
            self.allSlotNum=5
        end
        self.miniFleetSlotLayer:setVisible(true)
        -- 行数据的高度是41个像素
        local layerHeight = 46*(self.allSlotNum)+30
        -- 刷新tv的position
        local posX = self.miniFleetSlotTv:getPositionX()
        local posY = 13
        -- 46是1行数据的最小高度，30是间距
        if layerHeight<=(46+30) then
            layerHeight = 46+30
        end
        
        local layerSize = CCSizeMake(self.miniFleetSlotLayer:getContentSize().width,layerHeight)
        -- 修改面板size
        self.miniFleetSlotLayer:setContentSize(layerSize)
        -- 修改tableview的size
        self.miniFleetSlotTv:setViewSize(CCSizeMake(layerSize.width,layerSize.height-30))
        self.miniFleetSlotTv:setPosition(ccp(5,posY))
        self.miniFleetSlotTv:recoverToRecordPoint(ccp(0,0))
        -- 修改缩回按钮的位置
        local leftMenu = tolua.cast(self.miniFleetSlotLayer:getChildByTag(1102),"CCMenu")
        if leftMenu~=nil then
            local toggleItem = tolua.cast(leftMenu:getChildByTag(1),"CCMenuItemToggle")
            posX = leftMenu:getPositionX()
            posY = self.miniFleetSlotLayer:getContentSize().height - toggleItem:getContentSize().height/2
            leftMenu:setPosition(ccp(posX,posY))
        end
        self.miniFleetSlotTv:reloadData()
    else
        self:initMiniFleetSlotLayer()
    end
end


function ltzdzMapDialog:initTaskLayer()
    local task=ltzdzFightApi:getCurTask()
    local capInSet=CCRect(50,0,2,31)
    local function clickHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        ltzdzVoApi:showTaskSmallDialog(self.layerNum+1)
        -- PlayEffect(audioCfg.mouseClick)
        -- self.taskList=ltzdzFightApi:getSortTask()
        -- local mainTask=self.taskList[1]
        -- if mainTask then
        --     local isFinishFlag=ltzdzFightApi:isTaskCompleted(mainTask.id)
        --     if isFinishFlag==true then
        --         local function taskFinishHandler(fn,data)
        --             smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
        --             -- self:refreshTaskLayer()
        --         end
        --         ltzdzVoApi:getTaskReward(mainTask.id,taskFinishHandler)
        --     else
        --         ltzdzVoApi:showTaskSmallDialog(self.layerNum+1)  
        --     end
        -- end
    end
    self.m_mainTaskBg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_taskBar.png",capInSet,clickHandler)
    self.m_mainTaskBg:setContentSize(CCSizeMake(300,31))
    self.m_mainTaskBg:ignoreAnchorPointForPosition(false)
    self.m_mainTaskBg:setAnchorPoint(ccp(0,0.5))
    self.m_mainTaskBg:setIsSallow(true)
    self.m_mainTaskBg:setTouchPriority(-(self.layerNum-1)*20-5)
    self.miniMapLayer:addChild(self.m_mainTaskBg)
    if task then
        local descStr,simpleDescStr=ltzdzFightApi:getTaskInfoById(task.id)
        local descLb=GetTTFLabelWrap(simpleDescStr,22,CCSizeMake(self.m_mainTaskBg:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(20,self.m_mainTaskBg:getContentSize().height/2))
        descLb:setTag(12)
        self.m_mainTaskBg:addChild(descLb,1)
        descLb:setColor(G_ColorYellow)
    end

    -- local finishSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
    -- finishSp:setPosition(ccp(self.m_mainTaskBg:getContentSize().width-finishSp:getContentSize().width/2-10,self.m_mainTaskBg:getContentSize().height/2))
    -- finishSp:setTag(13)
    -- self.m_mainTaskBg:addChild(finishSp,1)

    -- local unfinishSp=CCSprite:createWithSpriteFrameName("questionMark.png")
    -- unfinishSp:setPosition(ccp(self.m_mainTaskBg:getContentSize().width-unfinishSp:getContentSize().width/2-10,self.m_mainTaskBg:getContentSize().height/2))
    -- unfinishSp:setTag(14)
    -- self.m_mainTaskBg:addChild(unfinishSp,1)

    -- local function nilFunc()
    -- end
    -- local halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
    -- halo:setContentSize(CCSize(self.m_mainTaskBg:getContentSize().width+10,self.m_mainTaskBg:getContentSize().height+10))
    -- halo:setPosition(getCenterPoint(self.m_mainTaskBg))
    -- halo:setTag(15)
    -- self.m_mainTaskBg:addChild(halo)

    local function showTaskSmallDialog()
        ltzdzVoApi:showTaskSmallDialog(self.layerNum+1)
    end
    local btnWidth=130
    local scale=btnWidth/104
    local priority=-(self.layerNum-1)*20-8
    local itemMainTask,mainTaskBtn=G_createBotton(self.miniMapLayer,ccp(0,0),nil,"ltzdz_task_icon.png","ltzdz_task_icon.png","ltzdz_task_icon.png",showTaskSmallDialog,scale,priority)
    -- local posX=(G_VisibleSizeWidth-(btnWidth+self.m_mainTaskBg:getContentSize().width+6))/2+btnWidth/2
    mainTaskBtn:setPosition(ccp(40,180))
    self.m_mainTaskBg:setPosition(60,175)
    self.mainTaskBtn=mainTaskBtn

    self:refreshTaskLayer()
end

function ltzdzMapDialog:refreshTaskLayer()
    if self.m_mainTaskBg==nil then
        do return end
    end
    local task=ltzdzFightApi:getCurTask()
    if task then
        self.m_mainTaskBg:setPosition(60,175)
        -- local isFinishFlag=ltzdzFightApi:isTaskCompleted(mainTask.id)
        local descStr,simpleDescStr=ltzdzFightApi:getTaskInfoById(task.id)
        local descLb=tolua.cast(self.m_mainTaskBg:getChildByTag(12),"CCLabelTTF")
        if descLb then
            descLb:setString(simpleDescStr)
        end
        -- local fSp=tolua.cast(self.m_mainTaskBg:getChildByTag(13),"CCSprite")
        -- local ufSp=tolua.cast(self.m_mainTaskBg:getChildByTag(14),"CCSprite")
        -- local haloSp=tolua.cast(self.m_mainTaskBg:getChildByTag(15),"LuaCCScale9Sprite")
        -- if isFinishFlag==true then
        --     if fSp then
        --         fSp:setVisible(true)
        --     end
        --     if ufSp then
        --         ufSp:setVisible(false)
        --     end
        --     if haloSp then
        --         haloSp:setVisible(true)
        --     end
        -- else
        --     if fSp then
        --         fSp:setVisible(false)
        --     end
        --     if ufSp then
        --         ufSp:setVisible(true)
        --     end
        --     if haloSp then
        --         haloSp:setVisible(false)
        --     end
        -- end
    else
        self.m_mainTaskBg:setPosition(10000,175)
    end
end

--刷新下面辅助功能红点提示
function ltzdzMapDialog:refreshTip(tipType)
    if self.tipSpTb==nil or self.tipSpTb[tipType]==nil then
        do return end
    end
    local tipSp=tolua.cast(self.tipSpTb[tipType],"CCSprite")
    if tipSp then
        local num=0
        if tipType==1 then --战报
            require "luascript/script/game/gamemodel/ltzdz/ltzdzReportVoApi"
            num=ltzdzReportVoApi:hasNewReport(1)
            -- print("num----->>>>>111",num)
            if num==0 then
                num=ltzdzReportVoApi:getHasUnRead(1)
            end
            -- print("num----->>>>>222",num)
        elseif tipType==2 then --计策
            local coolingFlag=ltzdzVoApi:isStratagemCooling()
            if coolingFlag==false then
                num=1
            end
        elseif tipType==3 then --外交
            local inviteFlag=ltzdzFightApi:isBeInvited()
            if inviteFlag==true then
                num=1
            end
        end
        if num>0 then
            tipSp:setVisible(true)
        else
            tipSp:setVisible(false)
        end
    end
end

function ltzdzMapDialog:setMiniMapPointColor(mapUser,oid,cityTag)
    if mapUser then
        local pointSp=tolua.cast(self.miniMap:getChildByTag(cityTag),"CCSprite")
        local color
        if oid then
            local colorId=mapUser[tostring(oid)].c or 1
            color=ltzdzFightApi:getUserColor(colorId)
        else
            color=G_ColorWhite
        end
        
        if pointSp then
            pointSp:setColor(color)
        end
        
    end
end

function ltzdzMapDialog:tick()
    --一分钟同步一次数据
    if self.fightTimeLb then
        local mapVo=ltzdzFightApi:getMapVo()
        if mapVo and mapVo.st and base.serverTime==mapVo.st then
            local timeStr=G_getFormatDate((mapVo.et or 0))..getlocal("function_end_str")
            self.fightTimeLb:setString(timeStr)
        end
    end
    
    if ltzdzFightApi.syncResTime and base.serverTime>=ltzdzFightApi.syncResTime  then
        local function syncCallBack()
            self:refreshResLb()
        end
        ltzdzFightApi:syncResRequest(syncCallBack)
    end

    local flag=ltzdzVoApi:isStratagemCooling()
    if flag~=self.coolingFlag then ---刷新计策按钮的红点
        self:refreshTip(2)
        self.coolingFlag=flag
    end

    if self.tickFleetTimer and self.allSlot then
        self.fleetTb={} -- 不用local 防止重复分配释放内存
        for k,v in pairs(self.tickFleetTimer) do
            if self.allSlot[k] then
                -- print("+++++k",k,self.allSlot[k].sid)
                local slotInfo=self.allSlot[k].value
                if v and slotInfo then
                    local subTime=self:setTimerSpPer(v,slotInfo)
                    if subTime<=0 then
                        table.insert(self.fleetTb,self.allSlot[k].sid)
                    end
                end
            end
        end

        -- 同步时间走到0的队列
        if self.fleetSynFlag and #self.fleetTb>0 then
            self.fleetSynFlag=false
            local function synFleet()
                self.fleetSynFlag=true
            end
            ltzdzFightApi:syncFleet(self.fleetTb,synFleet)

        end

    end

    -- 正式开战时间去掉保护罩
    if self.coverFlag and ltzdzFightApi:isTrueBattle() then
        self.coverFlag=false
        local mapCfg=ltzdzVoApi:getMapCfg()
        local prtCity=mapCfg.prtCity
        local cityCfg=mapCfg.citycfg
        for k,v in pairs(prtCity) do
            local cityTag=cityCfg[k].id+10000
            local citySp=tolua.cast(self.background:getChildByTag(cityTag),"LuaCCSprite")
            if citySp then
                local protectedSp=tolua.cast(citySp:getChildByTag(102),"CCSprite")
                if protectedSp then
                    protectedSp:removeFromParentAndCleanup(true)
                    protectedSp=nil
                end
            end
        end
    end

    if self.cityDialog and self.cityDialog.tick then
        self.cityDialog:tick()
    end
end

function ltzdzMapDialog:approachAction() 
    -- self.background:setScale(self.minScale)
    -- self:checkBound()
    -- local scale1=CCScaleTo:create(2,1)
    -- self.background:runAction(scale1)
end

function ltzdzMapDialog:fastTick()  
end

function ltzdzMapDialog:dispose()
    if self.resChangedListener then
        eventDispatcher:removeEventListener("ltzdz.resChanged",self.resChangedListener)
        self.resChangedListener=nil
    end

    if self.refreshMatchLineListener then
        eventDispatcher:removeEventListener("ltzdz.refreshMatchLine",self.refreshMatchLineListener)
        self.refreshMatchLineListener=nil
    end

    if self.setOrTransportListener then
        eventDispatcher:removeEventListener("ltzdz.setOrTransport",self.setOrTransportListener)
        self.setOrTransportListener=nil
    end
    
    if self.refreshCityListener then
        eventDispatcher:removeEventListener("ltzdz.refreshCity",self.refreshCityListener)
        self.refreshCityListener=nil
    end

    if self.refreshTaskListener then
        eventDispatcher:removeEventListener("ltzdz.updateTask",self.refreshTaskListener)
        self.refreshTaskListener=nil
    end

    if self.refreshChatListener then
        eventDispatcher:removeEventListener("ltzdz.newChat",self.refreshChatListener)
        self.refreshChatListener=nil
    end

    if self.refreshTipListener then
        eventDispatcher:removeEventListener("ltzdz.refreshTip",self.refreshTipListener)
        self.refreshTipListener=nil
    end
    
    self.layerNum=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    if self.cityDialog and self.cityDialog.dispose then --如果城市打开了，则关闭
        self.cityDialog:dispose()
        self.cityDialog=nil
    end
    if ltzdzSegUpgradeSmallDialog and ltzdzSegUpgradeSmallDialog.close then
        ltzdzSegUpgradeSmallDialog:close()
    end
    self.bType=nil
    self.targetCityTb=nil
    self.bgLayer=nil
    self.mapSize=nil
    self.miniMapSize=nil
    self.openCityFlag=false
    self.miniFleetSlotLayer=nil
    self.allSlot=nil
    self.allSlotNum=nil
    self.tickFleetTimer=nil
    self.m_chatBg=nil
    self.taskList=nil
    self.tipSpTb=nil
    self.fleetSynFlag=true
    self.fleetTb={}
    self.metalLb=nil
    self.gemsLb=nil
    self.oilLb=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzMapDialog")

    spriteController:removePlist("public/ltzdz/ltzdzCityIcon.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzCityIcon.png")
    spriteController:removePlist("public/ltzdz/ltzdzMainUI.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzMainUI.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/ltzdz/ltzdzMapBg1.jpg")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/ltzdz/ltzdzMapBg2.jpg")
end