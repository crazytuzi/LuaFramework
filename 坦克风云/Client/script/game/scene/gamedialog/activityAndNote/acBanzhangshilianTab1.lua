acBanzhangshilianTab1={}

function acBanzhangshilianTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.starLb=nil
    self.numLb=nil
    self.bgTab={}
    self.costLb=nil
    self.goldSp=nil
    self.pointLb=nil
    self.selectTab={}
    self.baseTab={}
    self.isRefreshToday=true
    self.holeSp=nil
    self.touchLayer=nil
    self.maskSp=nil

    return nc
end

function acBanzhangshilianTab1:init(layerNum,selectedTabIndex,parentDialog)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.parentDialog=parentDialog
    -- self.tvWidth=G_VisibleSizeWidth - 40
    local acVo=acBanzhangshilianVoApi:getAcVo()
    if acVo and acVo.cost then
        self:initLayer()
    end
    return self.bgLayer
end

function acBanzhangshilianTab1:initLayer()
    local acVo=acBanzhangshilianVoApi:getAcVo()
    local starNum=acVo.star
    local num=acVo.attackNum
    local maxNum=acVo.dailyAtt
    local costNum=acVo.cost
    local useTankInfo=acBanzhangshilianVoApi:getUseTankInfo()
    local challengeInfo=acVo.challengeInfo
    local charpter=acVo.charpter
    local tankPoint=acBanzhangshilianVoApi:getTankFighting()

    local timeStr=acBanzhangshilianVoApi:getTimeStr()
    local timeLb=GetTTFLabel(timeStr,28)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-190))
    self.bgLayer:addChild(timeLb,1)

    local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,260))
    if G_isIphone5()==true then
        headBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,330))
    end
    headBg:setAnchorPoint(ccp(0.5,1))
    headBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-217))
    self.bgLayer:addChild(headBg)

    for i=1,5 do
        local function showChapterDialog()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local unlock=acBanzhangshilianVoApi:getChapterIsUnlock(i)
            if unlock==true then
                local useTankInfo1=acBanzhangshilianVoApi:getUseTankInfo()
                if useTankInfo1 and SizeOfTable(useTankInfo1)>0 then
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_no_troops"),30)
                    do return end
                end
                acBanzhangshilianVoApi:showChapterDialog(self.layerNum+1,i)
            else
                local chapterName=getlocal("activity_banzhangshilian_chapter_name_"..i-1)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_unlock_tip",{chapterName}),30)
            end
        end
        local wSpace=3.5
        local bgWidth=headBg:getContentSize().width
        local spWidth=(bgWidth-bgWidth/wSpace*2)/2+((i-1)%3)*(bgWidth/wSpace)+math.floor((i-1)/3)*bgWidth/wSpace/2
        -- local spHeight=G_VisibleSizeHeight-290-math.floor((i-1)/3)*120
        local hSpace=60
        if G_isIphone5()==true then
            hSpace=80
        end
        local spHeight=headBg:getContentSize().height/2+hSpace-hSpace*2*math.floor((i-1)/3)
        local baseSp=LuaCCSprite:createWithSpriteFrameName("map_base_building_"..i..".png",showChapterDialog)
        baseSp:setTouchPriority(-(self.layerNum-1)*20-4)
        baseSp:setPosition(ccp(spWidth,spHeight))
        -- self.bgLayer:addChild(baseSp,3)
        headBg:addChild(baseSp,3)
        local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
        lockSp:setPosition(getCenterPoint(baseSp))
        lockSp:setTag(11)
        baseSp:addChild(lockSp,1)
        local unlock=acBanzhangshilianVoApi:getChapterIsUnlock(i)
        if unlock==true then
            lockSp:setVisible(false)
        else
            baseSp:setOpacity(100)
            lockSp:setVisible(true)
        end
        table.insert(self.baseTab,baseSp)
    end

    local lbHeight1=G_VisibleSizeHeight-500
    if G_isIphone5()==true then
        lbHeight1=G_VisibleSizeHeight-600
    end
    self.starLb=GetTTFLabel(starNum,25)
    self.starLb:setAnchorPoint(ccp(0,0.5))
    self.starLb:setPosition(ccp(50,lbHeight1))
    self.bgLayer:addChild(self.starLb,1)
    local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
    starSp:setAnchorPoint(ccp(0.5,0.5))
    starSp:setPosition(ccp(150,lbHeight1))
    self.bgLayer:addChild(starSp,1)

    local attackNumLb=GetTTFLabel(getlocal("activity_banzhangshilian_today_attack_number"),25)
    attackNumLb:setAnchorPoint(ccp(1,0.5))
    attackNumLb:setPosition(ccp(G_VisibleSizeWidth-110,lbHeight1))
    self.bgLayer:addChild(attackNumLb,1)
    self.numLb=GetTTFLabel(getlocal("scheduleChapter",{num,maxNum}),25)
    self.numLb:setAnchorPoint(ccp(1,0.5))
    self.numLb:setPosition(ccp(G_VisibleSizeWidth-50,lbHeight1))
    self.bgLayer:addChild(self.numLb,1)

    self.bgTab={}
    self.selectTab={}
    local spTabHeight=300
    if G_isIphone5()==true then
        spTabHeight=350
    end
    local wSpace=200
    local disBottom=150
    local posX=(G_VisibleSizeWidth-wSpace*2)/2
    local posY=disBottom+spTabHeight/2
    local hSpace=(spTabHeight-100)/2
    local function selectTankType(object,fn,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function getTroopsCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.banzhangshilian then
                    acBanzhangshilianVoApi:updateData(sData.data.banzhangshilian)
                    local acVo1=acBanzhangshilianVoApi:getAcVo()
                    local useTankInfo1=acBanzhangshilianVoApi:getUseTankInfo()
                    for k,v in pairs(self.selectTab) do
                        local selectSp=tolua.cast(v,"LuaCCScale9Sprite")
                        if selectSp then
                            if acVo1.selectTank and acVo1.selectTank==k and useTankInfo1 and useTankInfo1[k] then
                                selectSp:setVisible(true)
                                local tid=useTankInfo1[k]
                                local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
                                if id and tankCfg[id] and tankCfg[id].name then
                                    local tankName=getlocal(tankCfg[id].name)
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_set_reward_tank",{tankName}),30)
                                end
                            else
                                selectSp:setVisible(false)
                            end
                        end
                    end
                end
            end
        end
        local useTankInfo2=acBanzhangshilianVoApi:getUseTankInfo()
        if acVo.selectTank~=tag and useTankInfo2 and useTankInfo2[tag] then
            local action="getTroops"
            local id=tag
            socketHelper:activeBanzhangshilian(action,id,nil,nil,getTroopsCallback)
        end
    end
    
    self.holeSp=CCSprite:create("public/acBanzhangshilianHole.png")
    self.holeSp:setAnchorPoint(ccp(0.5,0.5))
    self.holeSp:setPosition(ccp(posX+wSpace,posY))
    self.bgLayer:addChild(self.holeSp)
    if acBanzhangshilianVoApi:refreshIsToday()==false then
        self.holeSp:setScale(10/self.holeSp:getContentSize().width)
    end
    for i=1,8 do
        local bgSp=LuaCCSprite:createWithSpriteFrameName("emptyTank.png",selectTankType)
        bgSp:setTouchPriority(-(self.layerNum-1)*20-4)
        local bgWidth=0
        local bgHeight=0
        if i>=1 and i<=3 then
            bgWidth=posX+((i-1)%3)*wSpace
            bgHeight=posY+hSpace
        elseif i==4 then
            bgWidth=posX+(2%3)*wSpace
            bgHeight=posY
        elseif i>=5 and i<=7 then
            bgWidth=posX+(2%3)*wSpace-((i-1)%3)*wSpace
            bgHeight=posY-hSpace
        else
            bgWidth=posX
            bgHeight=posY
        end
        bgSp:setTag(i)
        bgSp:setPosition(ccp(bgWidth,bgHeight))
        bgSp:setScaleX(0.65)
        bgSp:setScaleY(0.65)
        self.bgLayer:addChild(bgSp,1)
        table.insert(self.bgTab,bgSp)

        if useTankInfo and useTankInfo[i] then
            local tid=useTankInfo[i]
            local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
            if id and tankCfg[id] and tankCfg[id].icon then
                local function nilFunc()
                end
                local tankBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
                tankBg:setContentSize(CCSizeMake(bgSp:getContentSize().width,bgSp:getContentSize().height))
                tankBg:setPosition(getCenterPoint(bgSp))
                bgSp:addChild(tankBg)
                tankBg:setTag(i)

                local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[id].icon)
                tankSp:setScale(0.6)
                tankSp:setAnchorPoint(ccp(0,0.5))
                tankSp:setPosition(ccp(5,bgSp:getContentSize().height/2))
                tankBg:addChild(tankSp,1)
                
                local tankNameLb=GetTTFLabelWrap(getlocal(tankCfg[id].name),25,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                tankNameLb:setAnchorPoint(ccp(0,0.5))
                tankNameLb:setPosition(ccp(tankSp:getContentSize().width*0.6+15,bgSp:getContentSize().height/2))
                tankBg:addChild(tankNameLb,1)
            end
        end

        local function touchNil()
        end
        local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),touchNil)
        selectSp:setContentSize(CCSizeMake(bgSp:getContentSize().width+10,bgSp:getContentSize().height+10))
        selectSp:setPosition(getCenterPoint(bgSp))
        selectSp:setTag(1000+i)
        bgSp:addChild(selectSp,3)
        if acVo.selectTank and acVo.selectTank==i and useTankInfo and useTankInfo[i] then
            selectSp:setVisible(true)
        else
            selectSp:setVisible(false)
        end
        table.insert(self.selectTab,selectSp)
    end


    self.costLb=GetTTFLabel(costNum,28)
    self.costLb:setAnchorPoint(ccp(0.5,0.5))
    self.costLb:setPosition(ccp(G_VisibleSizeWidth-140,135))
    self.bgLayer:addChild(self.costLb,1)
    self.goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp:setScale(36/self.goldSp:getContentSize().width)
    self.goldSp:setPosition(ccp(G_VisibleSizeWidth-70,135))
    self.bgLayer:addChild(self.goldSp,1)

    local lbHeight2=75
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    self.pointLb=GetTTFLabelWrap(getlocal("activity_banzhangshilian_tank_point",{FormatNumber(tankPoint)}),25,CCSizeMake(G_VisibleSizeWidth-320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.pointLb:setAnchorPoint(ccp(0,0.5))
    self.pointLb:setPosition(ccp(40,lbHeight2))
    self.bgLayer:addChild(self.pointLb,1)

    local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local acVo=acBanzhangshilianVoApi:getAcVo()
        local maxNum=acVo.dailyAtt
        local firstAward=acVo.firstAward
        local td=smallDialog:new()
        local str=getlocal("activity_banzhangshilian_trial_tip",{maxNum,firstAward})
        local tabStr={" ",str," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local menuItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(G_VisibleSizeWidth-250,lbHeight2))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu,3)

    local function onRefreshTank()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local acVo=acBanzhangshilianVoApi:getAcVo()
        local costNum=acVo.cost
        if costNum and costNum>0 then
            if acBanzhangshilianVoApi:refreshIsToday()==true and playerVoApi:getGems()<costNum then
                GemsNotEnoughDialog(nil,nil,costNum-playerVoApi:getGems(),self.layerNum+1,costNum)
                do return end
            end
            local function refreshCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local isFree=false
                    if acBanzhangshilianVoApi:refreshIsToday()==false then
                        isFree=true
                    else
                        playerVoApi:setGems(playerVoApi:getGems()-costNum)
                    end

                    local oldUseTankInfo=acBanzhangshilianVoApi:getUseTankInfo()
                    if sData and sData.data and sData.data.banzhangshilian then
                        acBanzhangshilianVoApi:updateData(sData.data.banzhangshilian)
                        local newUseTankInfo=acBanzhangshilianVoApi:getUseTankInfo()
                        if self.holeSp then
                            self:setTouchLayer()
                            local function onAnmiHandler()
                                self:tick()
                                self:refresh()
                                self:cancleTouchLayer()

                                local acVo=acBanzhangshilianVoApi:getAcVo()
                                local useTankInfo=acBanzhangshilianVoApi:getUseTankInfo()
                                if acVo and acVo.selectTank and useTankInfo and useTankInfo[acVo.selectTank] then
                                    local tid=useTankInfo[acVo.selectTank]
                                    local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
                                    if id and tankCfg[id] and tankCfg[id].name then
                                        local tankName=getlocal(tankCfg[id].name)
                                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_set_reward_tank",{tankName}),30)
                                    end
                                end
                            end
                            local totalTime=2.8--3.4
                            local rotateTime=totalTime/2
                            local callFunc=CCCallFunc:create(onAnmiHandler)
                            local rotate=CCRotateBy:create(rotateTime,360*3*(rotateTime/totalTime))
                            local scaleTo=CCScaleTo:create(rotateTime,10/self.holeSp:getContentSize().width)
                            local carray=CCArray:create()
                            carray:addObject(rotate)
                            carray:addObject(scaleTo)
                            local spawn=CCSpawn:create(carray)
                            local rotate2=CCRotateBy:create(rotateTime,360*3*(rotateTime/totalTime))
                            local scaleTo2=CCScaleTo:create(rotateTime,1)
                            local carray2=CCArray:create()
                            carray2:addObject(rotate2)
                            carray2:addObject(scaleTo2)
                            local spawn2=CCSpawn:create(carray2)
                            local rotate3=CCRotateBy:create(totalTime-rotateTime,360*3*((totalTime-rotateTime*2)/3.4))
                            local acArr=CCArray:create()
                            if isFree==false then
                                acArr:addObject(spawn)
                                -- acArr:addObject(rotate3)
                            end
                            acArr:addObject(spawn2)
                            acArr:addObject(callFunc)
                            local seq=CCSequence:create(acArr)
                            self.holeSp:runAction(seq)

                            local spTabHeight=G_VisibleSizeHeight-660
                            local wSpace=200
                            local hSpace=(spTabHeight-100)/2
                            local disBottom=150
                            local posX=(G_VisibleSizeWidth-wSpace*2)/2
                            local posY=disBottom+spTabHeight/2
                            local scale=0.65
                            local tempTb1={1,2,3,4,5,6,7,8}
                            local tempTb2={1,2,3,4,5,6,7,8}
                            for i=1,8 do
                                if self.bgTab[i] then
                                    local bgSp=tolua.cast(self.bgTab[i],"LuaCCSprite")
                                    if bgSp then
                                        if bgSp:getChildByTag(i) then
                                            local tankBg=tolua.cast(bgSp:getChildByTag(i),"LuaCCScale9Sprite")
                                            if tankBg then
                                                tankBg:removeFromParentAndCleanup(true)
                                                tankBg=nil
                                            end
                                        end
                                        if self.selectTab and SizeOfTable(self.selectTab)>0 then
                                            for k,v in pairs(self.selectTab) do
                                                local selectSp=tolua.cast(v,"LuaCCScale9Sprite")
                                                if selectSp then
                                                    selectSp:setVisible(false)
                                                end
                                            end
                                        end 
                                        local bgSpPosX,bgSpPosY=bgSp:getPosition()
                                        local holePosX,holePosY=self.holeSp:getPosition()
                                        if isFree==false and oldUseTankInfo and oldUseTankInfo[i] then
                                            local tid=oldUseTankInfo[i]
                                            local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
                                            if id and tankCfg[id] and tankCfg[id].icon then
                                                local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[id].icon)
                                                tankSp:setScale(0.6*scale)
                                                tankSp:setAnchorPoint(ccp(0,0.5))
                                                tankSp:setPosition(ccp(bgSpPosX-bgSp:getContentSize().width/2*scale+5,bgSpPosY))
                                                self.bgLayer:addChild(tankSp,1)

                                                local function onDisappear()
                                                    if tankSp then
                                                        tankSp:removeFromParentAndCleanup(true)
                                                        tankSp=nil
                                                    end
                                                end

                                                --贝塞尔 中间点有问题
                                                -- local bezier=ccBezierConfig()
                                                -- bezier.controlPoint_1=ccp(bgSpPosX-bgSp:getContentSize().width/2*scale+5,bgSpPosY)
                                                -- bezier.controlPoint_2=ccp((holePosX-(bgSpPosX-bgSp:getContentSize().width/2*scale+5))*1.5,(bgSpPosY-holePosY)*1.5)
                                                -- -- bezier.controlPoint_2=ccp((bgSpPosX-bgSp:getContentSize().width/2*scale+5)*2,bgSpPosY*2)
                                                -- bezier.endPosition=ccp(holePosX,holePosY)
                                                -- local bezierTo=CCBezierTo:create(1,bezier)
                                                -- -- local bezierToBack=bezierTo:reverse()

                                                local callFunc=CCCallFunc:create(onDisappear)
                                                local rIndex=math.random(1,SizeOfTable(tempTb1))
                                                local randomNum=tempTb1[rIndex]
                                                local delayTime=0.05*randomNum
                                                table.remove(tempTb1,rIndex)
                                                local delay=CCDelayTime:create(delayTime)
                                                local mvTo=CCMoveTo:create(totalTime/2-0.7,ccp(holePosX,holePosY))
                                                local scaleTo=CCScaleTo:create(totalTime/2-0.7,0/tankSp:getContentSize().width)
                                                local carray=CCArray:create()
                                                carray:addObject(mvTo)
                                                -- carray:addObject(bezierTo)
                                                carray:addObject(scaleTo)
                                                local spawn=CCSpawn:create(carray)
                                                local acArr=CCArray:create()
                                                acArr:addObject(delay)
                                                acArr:addObject(spawn)
                                                acArr:addObject(callFunc)
                                                local seq=CCSequence:create(acArr)
                                                tankSp:runAction(seq)
                                            end
                                        end
                                        if newUseTankInfo and newUseTankInfo[i] then
                                            local tid=newUseTankInfo[i]
                                            local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
                                            if id and tankCfg[id] and tankCfg[id].icon then
                                                local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[id].icon)
                                                tankSp:setScale(0/tankSp:getContentSize().width)
                                                tankSp:setAnchorPoint(ccp(0,0.5))
                                                tankSp:setPosition(ccp(holePosX,holePosY))
                                                self.bgLayer:addChild(tankSp,1)

                                                local function onDisappear()
                                                    if tankSp then
                                                        tankSp:removeFromParentAndCleanup(true)
                                                        tankSp=nil
                                                    end
                                                end
                                                local callFunc=CCCallFunc:create(onDisappear)
                                                local rIndex=math.random(1,SizeOfTable(tempTb2))
                                                local randomNum=tempTb2[rIndex]
                                                local delayTime=0.05*randomNum
                                                table.remove(tempTb2,rIndex)
                                                local delay
                                                if isFree==false then
                                                    delay=CCDelayTime:create(delayTime+totalTime/2+0.3)
                                                else
                                                    delay=CCDelayTime:create(delayTime+0.3)
                                                end
                                                local delay2=CCDelayTime:create(0.05*8-delayTime)
                                                local mvTo=CCMoveTo:create(totalTime/2-0.7,ccp(bgSpPosX-bgSp:getContentSize().width/2*scale+5,bgSpPosY))
                                                local scaleTo=CCScaleTo:create(totalTime/2-0.7,0.6*scale)
                                                local carray=CCArray:create()
                                                carray:addObject(mvTo)
                                                carray:addObject(scaleTo)
                                                local spawn=CCSpawn:create(carray)
                                                local acArr=CCArray:create()
                                                acArr:addObject(delay)
                                                acArr:addObject(spawn)
                                                acArr:addObject(delay2)
                                                acArr:addObject(callFunc)
                                                local seq=CCSequence:create(acArr)
                                                tankSp:runAction(seq)
                                            end
                                        end
                                        
                                    end
                                end

                            end
                        end
                    end
                end
            end
            local action="refresh"
            socketHelper:activeBanzhangshilian(action,nil,nil,nil,refreshCallback)
        end
    end
    local refreshItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onRefreshTank,nil,getlocal("activity_banzhangshilian_refresh_tank"),25)
    local refreshMenu=CCMenu:createWithItem(refreshItem)
    refreshMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    refreshMenu:setAnchorPoint(ccp(0.5,0.5))
    refreshMenu:setPosition(ccp(G_VisibleSizeWidth-120,lbHeight2))
    self.bgLayer:addChild(refreshMenu,3)

    self:tick()
    self:refresh()
end

function acBanzhangshilianTab1:setTouchLayer()
    self.touchLayer=CCLayer:create()
    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:setBSwallowsTouches(true)
    self.touchLayer:setTouchPriority(-188)
    self.touchLayer:setContentSize(G_VisibleSize)
    self.bgLayer:addChild(self.touchLayer)
end
function acBanzhangshilianTab1:cancleTouchLayer()
    if self.touchLayer~=nil then
        local temLayer=tolua.cast(self.touchLayer,"CCLayer")
        if temLayer~=nil then
            temLayer:removeFromParentAndCleanup(true)
            temLayer=nil
        end
        self.touchLayer=nil
    end
end

function acBanzhangshilianTab1:tick()
    if self then
        if acBanzhangshilianVoApi:acIsStop()==true then
            if self.maskSp==nil then
                local function nilFunc()
                end
                self.maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
                self.maskSp:setTouchPriority(-(self.layerNum-1)*20-10)
                local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-160)
                self.maskSp:setContentSize(rect)
                self.maskSp:setAnchorPoint(ccp(0,0))
                self.maskSp:setOpacity(180)
                self.maskSp:setPosition(ccp(0,0))
                self.bgLayer:addChild(self.maskSp,10)

                local endTimeLb=GetTTFLabelWrap(getlocal("activity_banzhangshilian_time_end"),30,CCSizeMake(G_VisibleSizeWidth-100,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                endTimeLb:setPosition(getCenterPoint(self.maskSp))
                self.maskSp:addChild(endTimeLb,1)
                endTimeLb:setColor(G_ColorYellowPro)
            end
        else
            local acVo=acBanzhangshilianVoApi:getAcVo()
            if self.costLb and self.goldSp then
                if acBanzhangshilianVoApi:refreshIsToday()==false then
                    self.costLb:setString(getlocal("daily_lotto_tip_2"))
                    self.costLb:setPosition(ccp(G_VisibleSizeWidth-120,135))
                    self.goldSp:setVisible(false)
                else
                    local costNum=acVo.cost
                    self.costLb:setString(costNum)
                    self.costLb:setPosition(ccp(G_VisibleSizeWidth-140,135))
                    self.goldSp:setVisible(true)
                end
            end

            if self.numLb then
                local maxNum=acVo.dailyAtt
                local num=0
                if acBanzhangshilianVoApi:attackIsToday()==false then
                else
                    num=acVo.attackNum
                end
                self.numLb:setString(getlocal("scheduleChapter",{num,maxNum}))
            end

            if self.starLb then
                self.starLb:setString(acVo.star)
            end

            if self.baseTab and SizeOfTable(self.baseTab)>0 then
                for k,v in pairs(self.baseTab) do
                    local baseSp=tolua.cast(v,"LuaCCSprite")
                    if baseSp then
                        local lockSp=tolua.cast(baseSp:getChildByTag(11),"CCSprite")
                        if lockSp and lockSp:isVisible()==true then
                            local unlock=acBanzhangshilianVoApi:getChapterIsUnlock(k)
                            if unlock==true then
                                baseSp:setOpacity(255)
                                lockSp:setVisible(false)
                            else
                                baseSp:setOpacity(100)
                                lockSp:setVisible(true)
                            end
                        end
                    end
                end
            end

            if self.isRefreshToday==true and acBanzhangshilianVoApi:refreshIsToday()==false then
                self.isRefreshToday=acBanzhangshilianVoApi:refreshIsToday()
                self:refresh()
            end
        end
        
    end
end

function acBanzhangshilianTab1:refresh()
    if self then
        local acVo=acBanzhangshilianVoApi:getAcVo()
        if self.pointLb then
            local tankPoint=acBanzhangshilianVoApi:getTankFighting()
            self.pointLb:setString(getlocal("activity_banzhangshilian_tank_point",{FormatNumber(tankPoint)}))
        end

        local useTankInfo=acBanzhangshilianVoApi:getUseTankInfo()      
        if self.bgTab and SizeOfTable(self.bgTab)>0 then
            for i=1,8 do
                if self.bgTab[i] then
                    local bgSp=tolua.cast(self.bgTab[i],"LuaCCSprite")
                    if bgSp then
                        if bgSp:getChildByTag(i) then
                            local tankBg=tolua.cast(bgSp:getChildByTag(i),"LuaCCScale9Sprite")
                            if tankBg then
                                tankBg:removeFromParentAndCleanup(true)
                                tankBg=nil
                            end
                        end
                        if useTankInfo and useTankInfo[i] then
                            local tid=useTankInfo[i]
                            local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
                            if id and tankCfg[id] and tankCfg[id].icon then
                                local function nilFunc()
                                end
                                local tankBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
                                tankBg:setContentSize(CCSizeMake(bgSp:getContentSize().width,bgSp:getContentSize().height))
                                tankBg:setPosition(getCenterPoint(bgSp))
                                bgSp:addChild(tankBg)
                                tankBg:setTag(i)

                                local tankSp=CCSprite:createWithSpriteFrameName(tankCfg[id].icon)
                                tankSp:setScale(0.6)
                                tankSp:setAnchorPoint(ccp(0,0.5))
                                tankSp:setPosition(ccp(5,bgSp:getContentSize().height/2))
                                tankBg:addChild(tankSp,1)
                                
                                local tankNameLb=GetTTFLabelWrap(getlocal(tankCfg[id].name),25,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                                tankNameLb:setAnchorPoint(ccp(0,0.5))
                                tankNameLb:setPosition(ccp(tankSp:getContentSize().width*0.6+15,bgSp:getContentSize().height/2))
                                tankBg:addChild(tankNameLb,1)
                            end
                        end
                    end
                end
            end
        end
        if self.selectTab and SizeOfTable(self.selectTab)>0 then
            for k,v in pairs(self.selectTab) do
                local selectSp=tolua.cast(v,"LuaCCScale9Sprite")
                if selectSp then
                    if acVo.selectTank and acVo.selectTank==k and useTankInfo and useTankInfo[k] then
                        selectSp:setVisible(true)
                    else
                        selectSp:setVisible(false)
                    end
                end
            end
        end 
    end
end

function acBanzhangshilianTab1:dispose()
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.starLb=nil
    self.numLb=nil
    self.bgTab={}
    self.costLb=nil
    self.goldSp=nil
    self.pointLb=nil
    self.selectTab={}
    self.baseTab={}
    self.isRefreshToday=true
    self.holeSp=nil
    self:cancleTouchLayer()
    self.touchLayer=nil
    self.maskSp=nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
end





