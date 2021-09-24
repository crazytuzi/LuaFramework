heroEquipExplorePointDialog = {}

function heroEquipExplorePointDialog:new(chapterId,parentDialog,index)
    local  nc = {}
    setmetatable(nc,self)
    self.__index=self
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.chapterId=chapterId      --当前章节
    self.smallStarPosArr={{x=36,y=63},{x=53,y=50},{x=70,y=63},}
    self.bigStarPosArr={{x=42,y=80},{x=68,y=60},{x=94,y=80},}
    self.parentDialog=parentDialog
    self.ifGetReward=false--是否领取过奖励
    self.selectedIndex=index--默认打开第几个关卡
    self.containerSp=nil
    self.dataChangedListener = nil
    return nc
end

function heroEquipExplorePointDialog:init(layerNum)
    self.layerNum=layerNum
    local size=CCSizeMake(640,G_VisibleSize.height)
    self.isTouch=false
    self.isUseAmi=true
    local function touchHander( ... )

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(144, 53, 1, 1),touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-4)
    local function touchDialog()

    end

    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
    self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,10)

    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    self:refreshDialog()
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
    sceneGame:addChild(self.bgLayer,self.layerNum)

    self:show()

    local function dataChanged(event,data)
        self:refreshData()
    end
    self.dataChangedListener = dataChanged
    eventDispatcher:addEventListener("equipExplore.dataChange",dataChanged)
end


function heroEquipExplorePointDialog:refreshDialog(index,oldStarNum)
    if self.containerSp then
        self.containerSp:removeFromParentAndCleanup(true)
        self.containerSp=nil
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.containerSp=CCSprite:create()
    self.containerSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))
    self.containerSp:setAnchorPoint(ccp(0.5,0.5))
    self.containerSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.containerSp)

    self:initTableView(index,oldStarNum)
end

function heroEquipExplorePointDialog:openSmallExploerDialog(index)
    require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipSmallDialog"

    local starnum = heroEquipChallengeVoApi:getPointCurStarNum(self.chapterId,index)
    local maxStarNum = heroEquipChallengeVoApi:getPointMaxStarNum()
    local function battleHandler(allReward)
        local curNum,maxNum = heroEquipChallengeVoApi:getPointAttackNum(self.chapterId,index)
        smallDialog:showExploreSweepDialog(allReward,curNum,self.chapterId,index,self.layerNum+1,battleHandler)
        -- self:refreshDialog()
        self:refreshData()
    end
    local newStarnum = heroEquipChallengeVoApi:getPointCurStarNum(self.chapterId,index)
    local function callBack3()
        -- self:close()
        newStarnum = heroEquipChallengeVoApi:getPointCurStarNum(self.chapterId,index)
        self:refreshDialog(index,starnum)
        if self and self["pointBgSp"..index] then
            self:endBattle(self["pointBgSp"..index],starnum,newStarnum,index)
        end

    end
    local sid=heroEquipChallengeVoApi:getChapterNum()*(self.chapterId-1)+index
    local canGetReward = hChallengeCfg.list[sid].clientReward.rand
    smallDialog:showExplorePointDialog(canGetReward,self.chapterId,index,starnum,maxStarNum,self.layerNum+1,battleHandler,callBack3)
end

--初始化对话框面板
function heroEquipExplorePointDialog:initTableView(index,oldStarNum)
    local maskBg=CCSprite:create("public/hero/heroequip/equipChallangeBg.jpg")
    maskBg:setScaleY(G_VisibleSizeHeight/maskBg:getContentSize().height)
    maskBg:setAnchorPoint(ccp(0.5,0))
    maskBg:setPosition(ccp(G_VisibleSizeWidth/2,0))
    self.containerSp:addChild(maskBg)

    local bgSp1 = CCSprite:createWithSpriteFrameName("expedition_up.png")
    bgSp1:setAnchorPoint(ccp(0.5,1))
    bgSp1:setPosition(ccp(self.containerSp:getContentSize().width/2,self.containerSp:getContentSize().height))
    self.containerSp:addChild(bgSp1,2)

    local bgSp2 = CCSprite:createWithSpriteFrameName("expedition_down.png")
    bgSp2:setAnchorPoint(ccp(0.5,0))
    bgSp2:setPosition(ccp(self.containerSp:getContentSize().width/2,0))
    self.containerSp:addChild(bgSp2,6)

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
    titleBg:setContentSize(CCSizeMake(self.containerSp:getContentSize().width,70))
    -- titleBg:setScaleX((G_VisibleSizeWidth-260)/titleBg:getContentSize().width)
    titleBg:setPosition(ccp(self.containerSp:getContentSize().width/2,self.containerSp:getContentSize().height-14))
    self.containerSp:addChild(titleBg,1)
    titleBg:setAnchorPoint(ccp(0.5,1))

    local titleLb = GetTTFLabelWrap(heroEquipChallengeVoApi:getLocalChaperName(self.chapterId),32,CCSize(350, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop, "Helvetica-bold")
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2))
    titleBg:addChild(titleLb,2)
    titleLb:setColor(G_ColorYellowPro)

    local pointNum = heroEquipChallengeVoApi:getChapterNum()
    -- local pointSize = CCSizeMake(160,200)
    local pointPosArr = {{x=160.5,y=736},{x=425.5,y=685.5},
                         {x=392.5,y=448.5},{x=137.5,y=356},
                         {x=462,y=208.5}
                        }
    -- if G_isIphone5()==false then
    --     pointPosArr = {{x=160.5,y=736},{x=425.5,y=685.5},
    --                      {x=392.5,y=448.5},{x=137.5,y=356},
    --                      {x=462,y=208.5}
    --                     }
    -- end
    local smallPointPosArr = {
                            {x=204.5,y=654},{x=226.5,y=645},{x=248.5,y=634},{x=270.5,y=621},{x=292.5,y=612},{x=314.5,y=610},{x=336.5,y=610},{x=358.5,y=612},{x=380.5,y=616},
                            {x=457.5,y=596.5},{x=483.5,y=577.5},{x=503.5,y=558.5},{x=517.5,y=539.5},{x=525.5,y=520.5},{x=527.5,y=501.5},{x=523.5,y=482.5},{x=513.5,y=463.5},{x=497.5,y=444.5},{x=475.5,y=425.5},{x=447.5,y=406.5},
                            {x=342.5,y=356.5},{x=317.5,y=342.5},{x=292.5,y=326.5},{x=267.5,y=313.5},{x=242.5,y=306.5},{x=217.5,y=301.5},{x=192.5,y=298.5},
                            {x=177.5,y=264},{x=197.5,y=250},{x=217.5,y=234},{x=237.5,y=216},{x=257.5,y=196},{x=277.5,y=174},{x=297.5,y=158},{x=322.5,y=151},{x=343.5,y=144},{x=367.5,y=140},{x=390.5,y=134},{x=411.5,y=130},
                        }
    local temH = 0
    if G_isIphone5()==true then
        temH=100
    end
    for k,v in pairs(smallPointPosArr) do
        local psp = CCSprite:createWithSpriteFrameName("equipPoint3.png")
        psp:setPosition(ccp(v.x,v.y+temH))
        self.containerSp:addChild(psp,3)
    end
    local ifOpeningBox = false
    for i=1,pointNum do
        local isUnlock = heroEquipChallengeVoApi:checkPointIsUnlock(self.chapterId,i)
        -- print("----dmj----chapterid:"..self.chapterId.."---i:"..i)
        -- print("-----dmj------isUnlock:",isUnlock)
        local starnum = heroEquipChallengeVoApi:getPointCurStarNum(self.chapterId,i)
        local maxStarNum = heroEquipChallengeVoApi:getPointMaxStarNum()
        local function touch(object,fn,tag )
            if ifOpeningBox==true then
                return
            end
            local function callBack4( ... )
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                self:openSmallExploerDialog(i)
            end

            local tembgSp = tolua.cast(self.containerSp:getChildByTag(i+100),"LuaCCSprite")
            if tembgSp then
                local function callBack5()
                    callBack4()
                    ifOpeningBox=false
                end
                local callFunc=CCCallFunc:create(callBack5)

                local scaleTo1=CCScaleTo:create(0.1,0.9,0.9)
                local scaleTo2=CCScaleTo:create(0.1,1,1)

                local acArr=CCArray:create()
                acArr:addObject(scaleTo1)
                acArr:addObject(scaleTo2)
                acArr:addObject(callFunc)

                local seq=CCSequence:create(acArr)
                tembgSp:runAction(seq)
                ifOpeningBox=true
            end
        end
        -- local pointBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
        local iconSpW=90
        local pic="equipPoint1.png"
        if i==pointNum then
            pic="equipPoint2.png"
            iconSpW=95
        end
        local pointBgSp
        if isUnlock==false then
            pointBgSp=GraySprite:createWithSpriteFrameName(pic)
        else
            pointBgSp = LuaCCSprite:createWithSpriteFrameName(pic,touch)
            pointBgSp:setTouchPriority(-(self.layerNum-1)*20-11)
            print("====dmj------self.layerNum:"..self.layerNum)
        end
        local pointX,pointY = pointPosArr[i].x,pointPosArr[i].y+temH
        pointBgSp:setPosition(ccp(pointX,pointY))
        self.containerSp:addChild(pointBgSp,2)
        pointBgSp:setTag(i+100)
        self["pointBgSp"..i]=pointBgSp


        --[[
        if i==4 then
            local pointX1,pointY1 = pointPosArr[i].x,pointPosArr[i].y-70
            local pointX2,pointY2 = pointPosArr[i+1].x,pointPosArr[i+1].y-70
            local totolNum = 15
            -- 11111
            -- local gapX = math.floor((pointX2-pointX1)/(totolNum+1))
            -- local gapY = math.floor((pointY1-pointY2)/(totolNum+1))

            -- 22222
            -- local gapX = math.floor((pointX1-pointX2)/(totolNum+1))
            -- local gapY = math.floor((pointY1-pointY2)/(totolNum+1))

            -- 33333
            -- local gapX = math.floor((pointX1-pointX2)/(totolNum+1))
            -- local gapY = math.floor((pointY1-pointY2)/(totolNum+1))

            -- 44444
            local gapX = math.floor((pointX2-pointX1)/(totolNum+1))
            local gapY = math.floor((pointY1-pointY2)/(totolNum+1))
            local msg = ""
            for a=1,totolNum do
                local temH = 1
                -- 11111
                -- local newX,newY = (pointX1+gapX*a),(pointY1-(gapY+a)*a)
                -- if a>5 then
                --     newX,newY = (pointX1+gapX*a),(pointY1-(gapY+(totolNum-a))*a)
                -- end
                -- 22222
                -- local newX,newY = (pointX1+(gapX+(totolNum-a)*temH)*a),(pointY1-(gapY)*a)
                -- 33333
                -- local newX,newY = (pointX1-(gapX)*a),(pointY1-(gapY+a)*a)
                -- if a>4 then
                --     newX,newY = (pointX1-gapX*a),(pointY1-(gapY+(totolNum-a))*a)
                -- end

                local newX,newY = (pointX1+gapX*a),(pointY1-(gapY+a)*a)
                if a>7 then
                    newX,newY = (pointX1+gapX*a),(pointY1-(gapY+(totolNum-a))*a)
                end
                msg=msg.."{x="..newX..",y="..newY.."},"

                local psp = CCSprite:createWithSpriteFrameName("equipPoint3.png")
                psp:setPosition(ccp(newX,newY))
                self.containerSp:addChild(psp,3)
            end
            print("dmj--------:",msg)
        end
        ]]


        local iconPic = heroEquipChallengeVoApi:getPointPic(self.chapterId,i)
        local iconSp
        if isUnlock==false then
            if i==pointNum then
                -- iconSp=GraySprite:createWithSpriteFrameName("ship/Hero_Icon/"..iconPic)
                local heroImageStr="ship/Hero_Icon/"..iconPic
                if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
                    heroImageStr="ship/Hero_Icon_Cartoon/"..iconPic
                end
                iconSp=GraySprite:create(heroImageStr)
            else
                iconSp=GraySprite:createWithSpriteFrameName(iconPic)
            end
        else
            if i==pointNum then
                local heroImageStr="ship/Hero_Icon/"..iconPic
                if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
                    heroImageStr="ship/Hero_Icon_Cartoon/"..iconPic
                end
                iconSp = CCSprite:create(heroImageStr)
            else
                iconSp = CCSprite:createWithSpriteFrameName(iconPic)
            end
        end
        iconSp:setAnchorPoint(ccp(0.5,0.5))
        iconSp:setPosition(ccp(pointBgSp:getContentSize().width/2,pointBgSp:getContentSize().height-55))
        pointBgSp:addChild(iconSp)
        -- iconSp:setScale(iconSpScale)
        iconSp:setScale(iconSpW/iconSp:getContentSize().width)

        local subTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
        subTitleBg:setContentSize(CCSizeMake(150,40))
        subTitleBg:setScaleX(250/subTitleBg:getContentSize().width)
        subTitleBg:setPosition(ccp(pointBgSp:getPositionX(),pointBgSp:getPositionY()+pointBgSp:getContentSize().height/2+5))
        self.containerSp:addChild(subTitleBg,3)
        subTitleBg:setAnchorPoint(ccp(0.5,0))

        local subTitleLb = GetTTFLabelWrap(heroEquipChallengeVoApi:getLocalPointName(self.chapterId,i),23,CCSize(350, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop, "Helvetica-bold")
        subTitleLb:setAnchorPoint(ccp(0.5,0.5))
        subTitleLb:setPosition(ccp(subTitleBg:getPositionX(),subTitleBg:getPositionY()+subTitleBg:getContentSize().height/2))
        self.containerSp:addChild(subTitleLb,4)
        subTitleLb:setColor(G_ColorYellowPro)

        local msg = ""
        local starSpace=17
        for j=1,maxStarNum do
            local starSp
            if starnum>=j then
                starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
                if oldStarNum and index and oldStarNum<j  and i==index then
                    starSp=CCSprite:createWithSpriteFrameName("gameoverstar_black.png")
                end
            else
                starSp=CCSprite:createWithSpriteFrameName("gameoverstar_black.png")
            end
            starSp:setAnchorPoint(ccp(0.5,0.5))
            -- local px=iconSp:getContentSize().width/2-starSpace/2*(maxStarNum-1)+starSpace*(j-1)+3
            -- local py=68
            -- if i==pointNum then
            --     starSpace=26
            --     px=iconSp:getContentSize().width/2-starSpace/2*(maxStarNum-1)+starSpace*(j-1)+18
            --     py=85
            --     if j==2 then
            --         py=65
            --     end
            --     starSp:setScale(28/starSp:getContentSize().width)
            -- else
            --     if j==2 then
            --         py=55
            --     end
            --     starSp:setScale(20/starSp:getContentSize().width)
            -- end
            -- py=py-5
            -- msg=msg.."{x="..px..",y="..py.."},"
            local px,py,starSize = self:getStarPos(i,j)
            starSp:setScale(starSize/starSp:getContentSize().width)
            starSp:setPosition(ccp(px,py))
            pointBgSp:addChild(starSp)
        end
        -- print("----dmj---msg:"..msg)
        -- if isUnlock==false then
        --     local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
        --     lockSp:setAnchorPoint(ccp(0.5,0.5))
        --     lockSp:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2+10))
        --     iconSp:addChild(lockSp,3)
        -- end

    end

    local function touch2( ... )

    end
    local bottomBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch2)
    bottomBgSp:setContentSize(CCSizeMake(self.containerSp:getContentSize().width,80))
    bottomBgSp:setPosition(ccp(self.containerSp:getContentSize().width/2,10))
    bottomBgSp:setAnchorPoint(ccp(0.5,0))
    self.containerSp:addChild(bottomBgSp,5)

    local curStarNum = heroEquipChallengeVoApi:getCurStarNum(self.chapterId)
    local maxStarNum = heroEquipChallengeVoApi:getMaxStarNum(self.chapterId)
    local getRewardFlag = heroEquipChallengeVoApi:getRewardFlag(self.chapterId)
    local function clickBoxHandler()
       if self.ifGetReward==true then
            return
       end
       local curStarNum = heroEquipChallengeVoApi:getCurStarNum(self.chapterId)
       if curStarNum<maxStarNum then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("get_prop_error1"),28)
            return
       end
       if heroEquipChallengeVoApi:getRewardFlag(self.chapterId)==1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_hadReward"),28)
            return
       end
       local function getRewardHandler(n,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.reward then
                    local award=FormatItem(sData.data.reward) or {}
                    for k,v in pairs(award) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num)
                    end
                    G_showRewardTip(award,true)
                    heroEquipChallengeVoApi:setRewardFlag(self.chapterId)
                    if self.ifGetReward==false then
                        if self and self.boxIcon then
                            self.boxIcon:setVisible(false)
                        end
                        if self and self.openBoxIcon then
                            self.openBoxIcon:setVisible(true)
                        end
                        if self and self.guangSp then
                            self.guangSp:stopAllActions()
                            self.guangSp:removeFromParentAndCleanup(true)
                            self.guangSp=nil
                        end
                    end
                    self.ifGetReward=true
                end
            end
       end
       -- local sid = (chapterId-1)*heroEquipChallengeVoApi:getChapterNum()+pointId
       socketHelper:equipGetReward(self.chapterId,getRewardHandler)
    end
    -- SpecialBoxOpen.png
    local boxIcon
    -- if curStarNum<maxStarNum then
    --     if getRewardFlag==1 then
    --         boxIcon=GraySprite:createWithSpriteFrameName("SpecialBoxOpen.png")
    --     else
    --         boxIcon=GraySprite:createWithSpriteFrameName("SpecialBox.png")
    --     end
    -- else
        if getRewardFlag==1 then
            boxIcon = LuaCCSprite:createWithSpriteFrameName("SpecialBoxOpen.png",clickBoxHandler)
        else
            boxIcon = LuaCCSprite:createWithSpriteFrameName("SpecialBox.png",clickBoxHandler)
        end
        boxIcon:setTouchPriority(-(self.layerNum-1)*20-13)
    -- end
    boxIcon:setAnchorPoint(ccp(0.5,0.5))
    boxIcon:setPosition(ccp(20+boxIcon:getContentSize().width/2*0.7,5+boxIcon:getContentSize().height/2*0.7))
    bottomBgSp:addChild(boxIcon,2)
    boxIcon:setScale(0.7)
    boxIcon:setTag(31)
    self.boxIcon=boxIcon

    if curStarNum>=maxStarNum and heroEquipChallengeVoApi:getRewardFlag(self.chapterId)==0 then
        local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
        bottomBgSp:addChild(guangSp)
        guangSp:setPosition(getCenterPoint(boxIcon))
        local rotateBy = CCRotateBy:create(4,360)
        local reverseBy = rotateBy:reverse()
        guangSp:runAction(CCRepeatForever:create(reverseBy))
        self.guangSp=guangSp
    end

    local starIcon = CCSprite:createWithSpriteFrameName("StarIcon.png")
    starIcon:setAnchorPoint(ccp(0,0))
    starIcon:setPosition(ccp(boxIcon:getPositionX()+boxIcon:getContentSize().width/2,20))
    bottomBgSp:addChild(starIcon)

    local openBoxIcon = CCSprite:createWithSpriteFrameName("SpecialBoxOpen.png")
    openBoxIcon:setAnchorPoint(ccp(0,0))
    openBoxIcon:setPosition(ccp(20,5))
    bottomBgSp:addChild(openBoxIcon)
    openBoxIcon:setScale(0.7)
    openBoxIcon:setTag(32)
    openBoxIcon:setVisible(false)
    self.openBoxIcon=openBoxIcon

    self.starNumLb = GetTTFLabelWrap(curStarNum.."/"..maxStarNum,25,CCSize(100, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.starNumLb:setAnchorPoint(ccp(0,0))
    self.starNumLb:setPosition(ccp(starIcon:getPositionX()+starIcon:getContentSize().width+5,20))
    bottomBgSp:addChild(self.starNumLb)

    local energyIcon = CCSprite:createWithSpriteFrameName("energyIcon.png")
    energyIcon:setAnchorPoint(ccp(0,0))
    energyIcon:setPosition(ccp(500,20))
    bottomBgSp:addChild(energyIcon)

    local curEnergy = playerVoApi:getEnergy()
    local maxEnergy = checkPointVoApi:getMaxEnergy()
    self.energyNumLb = GetTTFLabelWrap(curEnergy.."/"..maxEnergy,25,CCSize(100, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.energyNumLb:setAnchorPoint(ccp(0,0))
    self.energyNumLb:setPosition(ccp(energyIcon:getPositionX()+energyIcon:getContentSize().width+5,20))
    bottomBgSp:addChild(self.energyNumLb)


end


function heroEquipExplorePointDialog:refreshData()
    if self and self.starNumLb then
        local curStarNum = heroEquipChallengeVoApi:getCurStarNum(self.chapterId)
        local maxStarNum = heroEquipChallengeVoApi:getMaxStarNum(self.chapterId)
        self.starNumLb:setString(curStarNum.."/"..maxStarNum)
    end

    if self and self.energyNumLb then
        local curEnergy = playerVoApi:getEnergy()
        local maxEnergy = checkPointVoApi:getMaxEnergy()
        self.energyNumLb:setString(curEnergy.."/"..maxEnergy)
    end

end

function heroEquipExplorePointDialog:getStarPos(pointId,starIndex)
    local px,py=0
    local starSize = 24
    if pointId==5 then
        px,py=self.bigStarPosArr[starIndex].x,self.bigStarPosArr[starIndex].y
        starSize = 30
        py=py-2
    else
        px,py=self.smallStarPosArr[starIndex].x,self.smallStarPosArr[starIndex].y
        if starIndex==2 then
            py=py-2
        else
            py=py+1
        end
        px=px+1
    end

    return px,py,starSize
end

function heroEquipExplorePointDialog:endBattle(parent,oldStarNum,newStarNum,pointId)
    if newStarNum>0 then
        self:showStarAni(parent,oldStarNum,newStarNum,pointId)
    end

end

function heroEquipExplorePointDialog:showStarAni(parent,oldStarNum,newStarNum,pointId)
    if newStarNum<=oldStarNum then
        return
    end

    local function playMusic()
        PlayEffect(audioCfg.battle_star)
    end

    local  spcArr=CCArray:create()

    for kk=1,10 do
        local nameStr="star_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        spcArr:addObject(frame)
    end

    local animation=CCAnimation:createWithSpriteFrames(spcArr)
    animation:setRestoreOriginalFrame(true);
    animation:setDelayPerUnit(0.5/10)
    local animate=CCAnimate:create(animation)
    local starTime = 0.1;


    local scaleTo = CCScaleTo:create(0, 0.5);
    local scaleBy = CCScaleBy:create(starTime, 0.5*0.5);
    local fadeTo = CCFadeTo:create(starTime, 255);

    local carray=CCArray:create()
    carray:addObject(animate)
    carray:addObject(scaleTo)
    local spa=CCSpawn:create(carray)

    local carray1=CCArray:create()
    carray1:addObject(scaleBy)
    carray1:addObject(fadeTo)
    local spa2=CCSpawn:create(carray1)
    local block1 = CCScaleTo:create(0, 0.5);
    local block2 = CCFadeTo:create(0, 255);



    -- for i=oldStarNum,newStarNum do
    local px,py,starSize = self:getStarPos(pointId,oldStarNum+1)
    local star1 = CCSprite:createWithSpriteFrameName("gameoverstar_gray.png");
    star1:ignoreAnchorPointForPosition(false);
    star1:setAnchorPoint(ccp(0.5,0.5));
    star1:setPosition(ccp(px,py));
    star1:setScale(0.5);
    parent:addChild(star1);
    star1:setVisible(true);
    star1:setScale(3*0.5);
    star1:setOpacity(125);

    local acArr=CCArray:create()
    acArr:addObject(spa2)
    acArr:addObject(block2)


    local callFuncmusic=CCCallFunc:create(playMusic)
    local carray3=CCArray:create()
    carray3:addObject(spa)
    carray3:addObject(callFuncmusic)
    local spa3=CCSpawn:create(carray3)

    acArr:addObject(spa3)
    acArr:addObject(block1)

    local function callBack( ... )
        star1:stopAllActions()
        star1:removeFromParentAndCleanup(true)
        star1=nil
        local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
        starSp:setScale(starSize/starSp:getContentSize().width)
        starSp:setPosition(ccp(px,py))
        parent:addChild(starSp,1)

        if (oldStarNum+1)<newStarNum then
            self:showStarAni(parent,oldStarNum+1,newStarNum,pointId)
        end
    end
    local callFunc=CCCallFunc:create(callBack)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    star1:runAction(seq);
    -- end

end

function heroEquipExplorePointDialog:close(hasAnim)
    if self.isCloseing==true then
        do return end
    end
    if self.isCloseing==false then
        self.isCloseing=true
    end

    if hasAnim==nil then
        hasAnim=true
    end

    if self.parentDialog then
        self.parentDialog:refreshData()
    end
    base.allShowedCommonDialog=base.allShowedCommonDialog-1
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
         if v==self then
             v=nil
             base.commonDialogOpened_WeakTb[k]=nil
         end
    end
    -- for k,v in pairs(G_SmallDialogDialogTb) do
    --     if v==self then
    --         v=nil
    --         G_SmallDialogDialogTb[k]=nil
    --     end
    -- end
    if base.allShowedCommonDialog<0 then
        base.allShowedCommonDialog=0
    end
    if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==9 or newGuidMgr.curStep==46 or newGuidMgr.curStep==17 or newGuidMgr.curStep==35 or newGuidMgr.curStep==42) then --新手引导
            newGuidMgr:toNextStep()
    end
    local function realClose()
        return self:realClose()
    end
    if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
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
    end
   base:removeFromNeedRefresh(self) --停止刷新
   local fc= CCCallFunc:create(realClose)
   local moveTo=CCMoveTo:create((hasAnim==true and 0.3 or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
   local acArr=CCArray:create()
   acArr:addObject(moveTo)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)

end



function heroEquipExplorePointDialog:realClose()
    if self and self.guangSp then
        self.guangSp:stopAllActions()
        self.guangSp:removeFromParentAndCleanup(true)
        self.guangSp=nil
    end
    if self.containerSp then
        self.containerSp:removeFromParentAndCleanup(true)
        self.containerSp=nil
    end
    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()
end

--显示面板,加效果
function heroEquipExplorePointDialog:show()
    local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    local function callBack()
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setHide()
            elseif sceneController.curIndex==1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex==2 then
                worldScene:setHide()
            end


            mainUI:setHide()
            --self:getDataByType() --只有Email使用这个方法
        end
       base:cancleWait()
       if self.selectedIndex then
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:openSmallExploerDialog(self.selectedIndex)
        end
    end
    base.allShowedCommonDialog=base.allShowedCommonDialog+1
    table.insert(base.commonDialogOpened_WeakTb,self)
    -- table.insert(G_SmallDialogDialogTb,self)
    local callFunc=CCCallFunc:create(callBack)
    local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
    self.bgLayer:runAction(seq)
end
function heroEquipExplorePointDialog:dispose( ... )
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
    eventDispatcher:removeEventListener("equipExplore.dataChange",self.dataChangedListener)
    self.dataChangedListener = nil

    self = nil
end