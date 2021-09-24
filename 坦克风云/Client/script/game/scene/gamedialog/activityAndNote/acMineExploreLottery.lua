acMineExploreLottery={}

function acMineExploreLottery:new()
	local nc={}
    nc.bgLayer=nil
    nc.forbidLayer=nil
    nc.isEnd=false
    nc.digBtn=nil
    nc.multiDigBtn=nil
    nc.digCostNode=nil
    nc.multiCostNode=nil
    nc.mainLayer=nil
    nc.mazeLayer=nil
    nc.cellSpTb=nil
    nc.digCallBack=nil
    nc.isTodayFlag=true
    nc.boxSpTb=nil
    nc.floorLb=nil
    nc.promptLb=nil
    nc.arrowTb=nil
    nc.exitLayer=nil
    nc.tipLb=nil
    nc.arrowSp=nil
    nc.pointLb=nil
    nc.rankLb=nil
    nc.rankBg=nil
    nc.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        nc.adaH = 1250 - 1136
    end
    nc.url=G_downloadUrl("active/".."mineExplore/".."mazeBg.jpg")
	setmetatable(nc, self)
	self.__index=self

	return nc
end	

function acMineExploreLottery:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    acMineExploreVoApi:getMap() --初始化一下数据
    self.cellSpTb={}
    self.arrowTb={}
    self:tick()
    self:initTableView()
    return self.bgLayer
end

function acMineExploreLottery:initTableView()
    self.isEnd=acMineExploreVoApi:isEnd()
    self:initLayer()
    self:initMazeLayer()
end

function acMineExploreLottery:initLayer()
    local strSize=25
    local h=G_VisibleSizeHeight-160
    local w=G_VisibleSizeWidth-50 --背景框的宽度
    local bgH=120
    local strSize3 = 18
    if G_getCurChoseLanguage()=="ru" then
        strSize=22
    end
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strSize3 = 22
    end
    local infoH=120
    local addH=0
    local addH2=0
    if G_isIphone5()==true then
        bgH=150
        infoH=150
        addH=50
        addH2=-30
    end
    local layerH=G_VisibleSizeHeight-infoH-180
    local scale=layerH/651
    local mainLayer=CCNode:create()
    mainLayer:setAnchorPoint(ccp(0.5,0))
    mainLayer:setContentSize(CCSizeMake(612,layerH))
    mainLayer:setPosition(G_VisibleSizeWidth/2,30)
    self.bgLayer:addChild(mainLayer,1)
    self.mainLayer=mainLayer
    -- self.mainLayer:setScaleY(scale)

    local bgSize=mainLayer:getContentSize()
    local function onLoadIcon(fn,icon)
        if self and self.mainLayer then
            if self.bgLayer then
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setScaleY(scale)
                self.mainLayer:addChild(icon)
                icon:setPosition(getCenterPoint(self.mainLayer))
            end
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    -- local icon=CCSprite:create("public/mazeBg.jpg")
    -- icon:setScaleY(scale)
    -- icon:setAnchorPoint(ccp(0.5,0.5))
    -- self.mainLayer:addChild(icon)
    -- icon:setPosition(getCenterPoint(self.mainLayer))
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local zorder=2
    print("hj->>>",self.adaH)
    print("acMineExploreLottery.adaH",acMineExploreLottery.adaH)
    local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
    lightSp:setPosition(bgSize.width/2,bgSize.height-20+addH2-self.adaH/2)
    mainLayer:addChild(lightSp,1)
    local starBg=CCSprite:createWithSpriteFrameName("heroBg.png")
    starBg:setAnchorPoint(ccp(0.5,1))
    starBg:setPosition(ccp(bgSize.width/2,bgSize.height-10+addH2-self.adaH/2))
    mainLayer:addChild(starBg,1)
    local floorNum=acMineExploreVoApi:getLayer()
    local floorLb=GetTTFLabelWrap(getlocal("super_weapon_challenge_floors",{floorNum}),35,CCSize(bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    floorLb:setPosition(getCenterPoint(starBg))
    self.floorLb=floorLb
    starBg:addChild(floorLb)
    local fadeBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    fadeBg:setAnchorPoint(ccp(0.5,1))
    fadeBg:setPosition(ccp(bgSize.width/2,starBg:getPositionY()-starBg:getContentSize().height/2-5))
    mainLayer:addChild(fadeBg,2)
    local remain=acMineExploreVoApi:getRemainDoubleLayer()
    local promptLb=GetTTFLabelWrap(getlocal("explore_next_prompt3",{remain}),20,CCSize(bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    promptLb:setPosition(getCenterPoint(fadeBg))
    fadeBg:addChild(promptLb)
    self.promptLb=promptLb
    self:refreshFloorLb()

    local pointStr=getlocal("activity_mineExplore_money").."："..acMineExploreVoApi:getMyPoint()
    local adaWidth = 0
    if G_getIphoneType() == G_iphoneX then
        adaWidth = 50
    end
    local pointLb=GetTTFLabelWrap(pointStr,strSize3,CCSize(155+adaWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    pointLb:setAnchorPoint(ccp(0.5,1))
    local tempLb=GetTTFLabel(pointStr,strSize3)
    local lbW=tempLb:getContentSize().width
    if lbW>pointLb:getContentSize().width then
        lbW=pointLb:getContentSize().width
    end
    local pointBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    pointBg:setAnchorPoint(ccp(0,1))
    pointBg:setContentSize(CCSizeMake(lbW+40,pointLb:getContentSize().height+20))
    -- pointBg:setPosition(ccp(0,bgSize.height+addH2+blackBgAddPosY))
    pointBg:setPosition(ccp(0,h-bgH-25))
    -- pointBg:setScaleY(1/scale)
    mainLayer:addChild(pointBg,zorder)
    pointLb:setPosition(pointBg:getContentSize().width/2,pointBg:getContentSize().height-10)
    pointBg:addChild(pointLb)
    self.pointLb=pointLb

    local rank=acMineExploreVoApi:getSelfRank()
    local rankStr=getlocal("reachLayer_prompt",{rank})
    local rankLb=GetTTFLabelWrap(rankStr,strSize3,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    rankLb:setAnchorPoint(ccp(0.5,1))
    tempLb=GetTTFLabel(rankStr,strSize3)
    lbW=tempLb:getContentSize().width
    if lbW>rankLb:getContentSize().width then
        lbW=rankLb:getContentSize().width
    end
    local rankBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    rankBg:setAnchorPoint(ccp(1,1))
    rankBg:setContentSize(CCSizeMake(lbW+40,rankLb:getContentSize().height+20))
    -- rankBg:setPosition(ccp(bgSize.width,bgSize.height+addH2+blackBgAddPosY))
    rankBg:setPosition(ccp(bgSize.width,h-bgH-25))
    -- rankBg:setScaleY(1/scale)
    mainLayer:addChild(rankBg,zorder)
    rankLb:setPosition(rankBg:getContentSize().width/2,rankBg:getContentSize().height-10)
    rankBg:addChild(rankLb)
    self.rankLb=rankLb
    self.rankBg=rankBg
    local flag=acMineExploreVoApi:isShowLayerRank()
    if flag==false then
        self.rankBg:setVisible(false)
    end

    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:recordHandler()
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.8)
    -- recordBtn:setScaleY(0.8/scale)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(bgSize.width-recordBtn:getContentSize().width*recordBtn:getScaleX()+20,pointBg:getPositionY()-pointBg:getContentSize().height-50))
    mainLayer:addChild(recordMenu,zorder)
    local recordBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    recordBg:setAnchorPoint(ccp(0.5,1))
    recordBg:setContentSize(CCSizeMake(100,40))
    recordBg:setPosition(ccp(recordBtn:getContentSize().width/2,0))
    recordBg:setScale(1/0.8)
    recordBtn:addChild(recordBg,zorder)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setPosition(recordBg:getContentSize().width/2,recordBg:getContentSize().height/2)
    recordLb:setColor(G_ColorYellowPro)
    recordBg:addChild(recordLb)

    local cost1,cost2=acMineExploreVoApi:getDigCost()
    local freeFlag=acMineExploreVoApi:isFreeDig()
    local digStr=getlocal("excavate")
    if freeFlag==1 then
        digStr=getlocal("daily_lotto_tip_2")
    end
    local function digHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:digHandler(1)
    end
    local digBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",digHandler,nil,digStr,strSize,11)
    local digMenu=CCMenu:createWithItem(digBtn)
    digMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    digMenu:setPosition(ccp(bgSize.width/2-150,70+self.adaH/3))
    self.bgLayer:addChild(digMenu,zorder+1)
    self.digBtn=digBtn

    local digCostNode=CCNode:create()
    digCostNode:setAnchorPoint(ccp(0.5,0))
    digBtn:addChild(digCostNode)
    self.digCostNode=digCostNode
    local costLb=GetTTFLabel(tostring(cost1),25)
    costLb:setAnchorPoint(ccp(0,0))
    costLb:setColor(G_ColorYellowPro)
    digCostNode:addChild(costLb)
    local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0,0))
    digCostNode:addChild(costSp)
    local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width
    digCostNode:setContentSize(CCSizeMake(lbWidth,1))
    costLb:setPosition(ccp(0,0))
    costSp:setPosition(ccp(costLb:getContentSize().width,0))
    digCostNode:setPosition(ccp(digBtn:getContentSize().width/2,digBtn:getContentSize().height))
    if freeFlag==1 then
        self.digCostNode:setVisible(false)
    end
    local function multiDigHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:digHandler(2)
    end
    local digCount=acMineExploreVoApi:getCanDigCount()
    local multiDigBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",multiDigHandler,nil,getlocal("multi_excavate",{digCount}),strSize2,11)
    local multiAttireMenu=CCMenu:createWithItem(multiDigBtn)
    multiAttireMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    multiAttireMenu:setPosition(ccp(bgSize.width/2+150,70+self.adaH/3))
    self.bgLayer:addChild(multiAttireMenu,zorder+1)
    self.multiDigBtn=multiDigBtn
    local costLbW=200
    local multiCostNode=CCNode:create()
    multiCostNode:setContentSize(CCSizeMake(costLbW,1))
    multiCostNode:setAnchorPoint(ccp(0.5,0))
    multiDigBtn:addChild(multiCostNode)
    multiCostNode:setPosition(ccp(multiDigBtn:getContentSize().width/2,multiDigBtn:getContentSize().height))
    local multiCostLb=GetTTFLabel(tostring(cost2),25)
    multiCostLb:setAnchorPoint(ccp(0,0))
    multiCostLb:setColor(G_ColorYellowPro)
    multiCostLb:setTag(101)
    multiCostNode:addChild(multiCostLb)
    local multiCostSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    multiCostSp:setAnchorPoint(ccp(0,0))
    multiCostSp:setTag(102)
    multiCostNode:addChild(multiCostSp)
    local lbWidth=multiCostLb:getContentSize().width+multiCostSp:getContentSize().width
    local firstPosX=(costLbW-lbWidth)/2
    multiCostLb:setPosition(ccp(firstPosX,0))
    multiCostSp:setPosition(ccp(multiCostLb:getPositionX()+multiCostLb:getContentSize().width,0))
    self.multiCostNode=multiCostNode
    self:refreshDigBtn()

    local lineSp=CCSprite:createWithSpriteFrameName("barGreen.png")
    lineSp:setPosition(ccp(bgSize.width/2,145+addH))
    mainLayer:addChild(lineSp,zorder)
    self:refreshChestLayer()

    local tipStr=getlocal("explore_next_prompt5")
    local tipLb=GetTTFLabelWrap(tipStr,23,CCSize(bgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local tipLb2=GetTTFLabel(tipStr,23)
    local tipLbW=tipLb2:getContentSize().width
    if tipLbW>tipLb:getContentSize().width then
        tipLbW=tipLb:getContentSize().width
    end
    local tipBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    tipBg:setAnchorPoint(ccp(0.5,0))
    tipBg:setContentSize(CCSizeMake(tipLbW+40,tipLb:getContentSize().height+10))
    tipBg:setPosition(ccp(bgSize.width/2,90+addH))
    tipBg:setOpacity(150)
    -- tipBg:setScaleY(1/scale)
    mainLayer:addChild(tipBg,1)
    tipLb:setPosition(tipBg:getContentSize().width/2,tipBg:getContentSize().height/2)
    tipLb:setColor(G_ColorYellowPro)
    tipBg:addChild(tipLb)
end

function acMineExploreLottery:initMazeLayer()
    if self.mazeLayer then
        self:removeExitLayer()
        self.mazeLayer:removeFromParentAndCleanup(true)
        self.mazeLayer=nil
        self.cellSpTb={}
        self.guangSp1=nil
        self.guangSp2=nil
    end
    local zorder=3
    local cellW=98
    local mazeLayer=CCNode:create()
    mazeLayer:setContentSize(CCSizeMake(4*cellW,4*cellW))
    mazeLayer:setAnchorPoint(ccp(0.5,0.5))
    mazeLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-80-self.adaH/3))
    self.bgLayer:addChild(mazeLayer,zorder)
    self.mazeLayer=mazeLayer
    local addy=0
    if G_isIphone5() then
        addy=65
    end
    local firstPosX=cellW/2
    local firstPosY=mazeLayer:getContentSize().height-cellW/2
    local mapCfg,mapData,base,rotation=acMineExploreVoApi:getMap()
    -- rotation=0
    for k,cell in pairs(mapCfg) do
        local posX=firstPosX+math.floor((tonumber(k)-1)%4)*cellW
        local posY=firstPosY-math.floor((tonumber(k)-1)/4)*cellW
        local ctype=cell.type
        local angle=cell.rotation
        local cellpic="mazecell"..ctype..".png"
        local function touchHandler(hd,fn,cellId)
            --判断是不是终点
            local entry=acMineExploreVoApi:getEntry()
            local flag=acMineExploreVoApi:isReachExit()
            if tonumber(entry)==tonumber(cellId) and flag==true then
                local descStr
                local flag=acMineExploreVoApi:isChestAllGet()
                if flag==true then
                    descStr=getlocal("explore_next_prompt1")
                else
                    descStr=getlocal("explore_next_prompt2")
                end
                local titleStr=getlocal("continue_dig")
                local function confirmHandler()--进入下一层
                    local function callback(map,cellTb,addScore,rewardlist)
                        self:refresh(true,map,cellTb)
                        local rank=acMineExploreVoApi:getSelfRank()
                        if rank and addScore>0 then
                            local rewardPromptStr=getlocal("mineExplore_floorReward",{rank,addScore})
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardPromptStr,30)
                            if rewardlist then
                                G_showRewardTip(rewardlist)
                            end
                        end
                        local remain=acMineExploreVoApi:getRemainDoubleLayer()
                        if tonumber(remain)==0 then
                            acMineExploreVoApi:sendRewardNotice(1)
                        end
                    end
                    acMineExploreVoApi:mineExploreRequest("active.mineexplore.next",nil,callback)      
                end
                local tsD=smallDialog:new()
                if flag == true and acMineExploreVoApi:isAllDiged() == true then
                    confirmHandler()
                else
                    tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmHandler,titleStr,descStr,nil,self.layerNum+1)
                end
            end
        end
        local cellSp=LuaCCSprite:createWithSpriteFrameName(cellpic,touchHandler)
        cellSp:setTouchPriority(-(self.layerNum-1)*20-4)
        cellSp:setAnchorPoint(ccp(0.5,0.5))
        cellSp:setPosition(ccp(posX,posY))
        cellSp:setRotation(angle)
        cellSp:setTag(k)
        mazeLayer:addChild(cellSp,2)
        self.cellSpTb[k]=cellSp
        mazeLayer:setRotation(rotation)

        -- local numLb=GetTTFLabel(k,30)
        -- numLb:setAnchorPoint(ccp(0.5,0.5))
        -- numLb:setPosition(getCenterPoint(cellSp))
        -- numLb:setColor(G_ColorYellowPro)
        -- numLb:setRotation(-angle-rotation)
        -- cellSp:addChild(numLb)

        local entry=acMineExploreVoApi:getEntry()
        if tonumber(entry)==tonumber(k) then
            local exitSp=CCSprite:createWithSpriteFrameName("maze_stairs.png")
            exitSp:setAnchorPoint(ccp(0.5,0.5))
            exitSp:setPosition(getCenterPoint(cellSp))
            exitSp:setTag(105)
            exitSp:setRotation(-cellSp:getRotation()-self.mazeLayer:getRotation())
            cellSp:addChild(exitSp)
            exitSp:setVisible(true)
            local guangSp1,guangSp2=self:showLightAni(mazeLayer,posX,posY,1.2)
            guangSp1:setVisible(false)
            guangSp2:setVisible(false)
            self.guangSp1=guangSp1
            self.guangSp2=guangSp2
        end
    end
    self:refreshMazeLayer(mapData)
end

function acMineExploreLottery:showLightAni(target,posX,posY,scale)
    if target==nil then
        do return end
    end
    local posX=posX or 0
    local posY=posY or 0
    local scale=scale or 1
    local guangSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp1:setPosition(ccp(posX,posY))
    target:addChild(guangSp1)
    local guangSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp2:setPosition(ccp(posX,posY))
    target:addChild(guangSp2)
    guangSp1:setScale(scale)
    guangSp2:setScale(scale)
    local rotateBy=CCRotateBy:create(4,360)
    local reverseBy=rotateBy:reverse()
    guangSp1:runAction(CCRepeatForever:create(rotateBy))
    guangSp2:runAction(CCRepeatForever:create(reverseBy))

    return guangSp1,guangSp2
end

function acMineExploreLottery:refreshMazeLayer(mapData)
    if self.cellSpTb and mapData then
        for cellId,cellSp in pairs(self.cellSpTb) do
            local cellW=98
            local shadeSp=tolua.cast(cellSp:getChildByTag(101),"CCSprite")
            if mapData[cellId] then --已挖掘
                if shadeSp then
                    shadeSp:setVisible(false)
                end
                local entry=acMineExploreVoApi:getEntry()
                if cellId==tonumber(entry) then
                    if self.guangSp1 and self.guangSp2 then
                        self.guangSp1:setVisible(true)
                        self.guangSp2:setVisible(true)
                    end
                    local exitSp=tolua.cast(cellSp:getChildByTag(105),"CCSprite")
                    if exitSp then
                        exitSp:setVisible(true)
                    end
                end
                local flag=acMineExploreVoApi:isUnlockChest(cellId)
                if flag==true then
                    local boxSp=tolua.cast(cellSp:getChildByTag(102),"CCSprite")
                    if boxSp then
                        boxSp:setVisible(true)
                    else
                        local posX=cellSp:getPositionX()
                        local posY=cellSp:getPositionY()
                        boxSp=CCSprite:createWithSpriteFrameName("CommonBoxOpen.png")
                        boxSp:setAnchorPoint(ccp(0.5,0.5))
                        boxSp:setPosition(ccp(posX,posY))
                        boxSp:setTag(102)
                        boxSp:setRotation(-self.mazeLayer:getRotation())
                        boxSp:setScale(0.5)
                        self.mazeLayer:addChild(boxSp,3)
                    end
                end
            else --未挖掘
                if shadeSp==nil then
                    shadeSp=CCSprite:createWithSpriteFrameName("maze_shade.png")
                    shadeSp:setPosition(ccp(cellW/2,cellW/2))
                    shadeSp:setRotation(-cellSp:getRotation()-self.mazeLayer:getRotation())
                    shadeSp:setTag(101)
                    cellSp:addChild(shadeSp)
                else
                    shadeSp:setVisible(true)
                end
            end
            if cellSp and cellId then
                self:getNextDir(cellSp,cellId)
            end
        end
    end
    self:showExitLayer()
end

function acMineExploreLottery:getNextDir(cellSp,cellId)
    if cellSp and cellId then
        local size=cellSp:getContentSize()
        local cellPosX=cellSp:getPositionX()
        local cellPosY=cellSp:getPositionY()
        local dir,cell=acMineExploreVoApi:getNextDir(cellId)
        if dir and type(dir)=="table" then
            local offset=10
            for k,v in pairs(dir) do
                local posX,posY,rotation,moveX,moveY
                if v==1 then --上
                    posX=cellPosX
                    posY=cellPosY+size.height/2
                    rotation=0
                    moveX=0
                    moveY=offset
                elseif v==2 then --下
                    posX=cellPosX
                    posY=cellPosY-size.height/2
                    rotation=180
                    moveX=0
                    moveY=-offset
                elseif v==3 then --左
                    posX=cellPosX-size.width/2
                    posY=cellPosY
                    rotation=-90
                    moveX=-offset
                    moveY=0
                elseif v==4 then --右
                    posX=cellPosX+size.width/2
                    posY=cellPosY
                    rotation=90
                    moveX=offset
                    moveY=0
                end
                if posX and posY and rotation then
                    local arrowSp=CCSprite:createWithSpriteFrameName("dwArrow.png")
                    arrowSp:setAnchorPoint(ccp(0.5,0))
                    arrowSp:setPosition(ccp(posX,posY))
                    arrowSp:setRotation(rotation)
                    self.mazeLayer:addChild(arrowSp,10)
                    table.insert(self.arrowTb,arrowSp)

                    local move1=CCMoveBy:create(0.5,ccp(moveX,moveY))
                    local move2=CCMoveBy:create(0.5,ccp(-moveX,-moveY))
                    local action=CCSequence:createWithTwoActions(move1,move2)
                    arrowSp:runAction(CCRepeatForever:create(action))
                end
            end
        end
    end
end

function acMineExploreLottery:removeArrow()
    if self.arrowTb then
        for i=#self.arrowTb,1,-1 do
            if self.arrowTb[i] then
                local arrowSp=tolua.cast(self.arrowTb[i],"CCSprite")
                if arrowSp then
                    arrowSp:removeFromParentAndCleanup(true)
                end
            end
        end
        self.arrowTb={}
    end
end

function acMineExploreLottery:showExitLayer()
    local flag=acMineExploreVoApi:isAllDiged()
    if flag==true and self.mazeLayer then
        if self.exitLayer==nil then
            local size=self.mazeLayer:getContentSize()
            local exitLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function ()end)
            exitLayer:setTouchPriority(-(self.layerNum-1)*20-1)
            exitLayer:setContentSize(size)
            exitLayer:setPosition(getCenterPoint(self.mazeLayer))
            exitLayer:setRotation(-self.mazeLayer:getRotation())
            self.mazeLayer:addChild(exitLayer,997)
            self.exitLayer=exitLayer

            local exitId=acMineExploreVoApi:getEntry()
            local exitCellSp=self.cellSpTb[exitId]
            if exitCellSp then
                self.mazeLayer:reorderChild(exitCellSp,999)
                self.mazeLayer:reorderChild(self.guangSp1,998)
                self.mazeLayer:reorderChild(self.guangSp2,998)

                local arrowSp=CCSprite:createWithSpriteFrameName("dwArrow1.png")
                self.arrowSp=arrowSp
                local arrowH=arrowSp:getContentSize().height
                local tipLb=GetTTFLabelWrap(getlocal("explore_next_prompt6"),23,CCSize(size.width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                tipLb:setColor(G_ColorYellowPro)
                self.tipLb=tipLb
                local tipH=tipLb:getContentSize().height
                local targetPos=exitCellSp:convertToWorldSpaceAR(ccp(0,0))
                local cellSize=exitCellSp:getContentSize()
                local angle=180
                targetPos.x=math.floor(targetPos.x)
                targetPos.y=math.floor(targetPos.y)
                local arrowPos=ccp(targetPos.x,0)
                local tipPos=ccp(G_VisibleSizeWidth/2,0)
                arrowPos.y=targetPos.y-cellSize.height/2-arrowH/2
                if targetPos.y<=(self.mazeLayer:getPositionY()-cellSize.height/2) then
                    arrowPos.y=targetPos.y+cellSize.height/2+arrowH/2
                elseif targetPos.y>=(self.mazeLayer:getPositionY()+cellSize.height/2) then
                    angle=0
                end
                local moveY=0
                if angle==0 then
                    tipPos.y=arrowPos.y-arrowSp:getContentSize().height/2-tipH/2-30
                    moveY=-20
                else
                    tipPos.y=arrowPos.y+arrowSp:getContentSize().height/2+tipH/2+30
                    moveY=20
                end
                arrowSp:setPosition(arrowPos)
                tipLb:setPosition(tipPos)
                arrowSp:setRotation(angle)
                self.bgLayer:addChild(tipLb,1001)
                self.bgLayer:addChild(arrowSp,1002)
                local mvTo=CCMoveBy:create(0.35,ccp(0,moveY))
                local mvBack=CCMoveBy:create(0.35,ccp(0,-moveY))
                local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
                arrowSp:runAction(CCRepeatForever:create(seq))
            end
        end
    end
end

function acMineExploreLottery:removeExitLayer()
    if self.exitLayer then
        self.exitLayer:removeFromParentAndCleanup(true)
    end
    if self.tipLb then
        self.tipLb:removeFromParentAndCleanup(true)
    end
    if self.arrowSp then
        self.arrowSp:removeFromParentAndCleanup(true)
    end
    self.exitLayer=nil
    self.tipLb=nil
    self.arrowSp=nil
end

--刷新宝箱
function acMineExploreLottery:refreshChestLayer(cellTb)
    if self.boxSpTb==nil then
        self.boxSpTb={}
    end    
    local function refreshChest(cid,flag,posX,posY)
        local function touchBox(hd,fn,tag)
            if tag then
                local exitId=acMineExploreVoApi:getEntry()
                if tag~=exitId then
                    local chestTb=acMineExploreVoApi:getChestMaze()
                    for k,v in pairs(chestTb) do
                        if tonumber(v)==tonumber(tag) then
                            chestId=tonumber(k)
                            do break end
                        end
                    end
                    if chestId then
                        local chestReward=acMineExploreVoApi:getMazeChestReward()
                        local rewardlist=FormatItem(chestReward[chestId],nil,true)
                        if rewardlist then
                            local desStr=getlocal("maze_hideReward",{chestId})
                            acMineExploreVoApi:showSmallDialog(true,true,self.layerNum+1,desStr,"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardlist)    
                        end
                    end
                else
                    local descStr=""
                    local flag=acMineExploreVoApi:isReachExit()
                    if flag==true then
                        descStr=getlocal("is_reach_exit")
                    else
                        descStr=getlocal("is_not_reach_exit")
                    end
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),descStr,30)
                end
            end
        end
        local selectSp
        local scale=0.6
        local boxpic="CommonBox.png"
        local exitId=acMineExploreVoApi:getEntry()
        if tonumber(cid)==tonumber(exitId) then
            boxpic="maze_next.png"
            scale=0.8
        else
            boxpic="CommonBox.png"
        end
        if flag==true then
            if tonumber(cid)~=tonumber(exitId) then
                boxpic="CommonBoxOpen.png"
            end
            selectSp=CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
        end
        local boxSp=LuaCCSprite:createWithSpriteFrameName(boxpic,touchBox)
        boxSp:setTouchPriority(-(self.layerNum-1)*20-4)
        boxSp:setPosition(ccp(posX,posY))
        boxSp:setTag(cid)
        boxSp:setScale(scale)
        self.mainLayer:addChild(boxSp,2)
        self.boxSpTb[cid]=boxSp
        if selectSp then
            selectSp:setPosition(getCenterPoint(boxSp))
            boxSp:addChild(selectSp)
        end
    end
    local bgSize=self.mainLayer:getContentSize()
    local chestReward=acMineExploreVoApi:getMazeChestReward()
    local chestNum=SizeOfTable(chestReward)+1 --隐藏宝箱加一个终点
    local chestTb=acMineExploreVoApi:getChestMaze()
    local exitId=acMineExploreVoApi:getEntry()
    if cellTb then
        for k,cellId in pairs(cellTb) do
            if self.boxSpTb and self.boxSpTb[cellId] then
                local flag=false
                if cellId==exitId then
                    flag=acMineExploreVoApi:isReachExit()
                else
                    flag=acMineExploreVoApi:isUnlockChest(cellId)
                end
                local boxSp=self.boxSpTb[cellId]
                local posX=boxSp:getPositionX()
                local posY=boxSp:getPositionY()
                boxSp:removeFromParentAndCleanup(true)
                self.boxSpTb[cellId]=nil
                refreshChest(cellId,flag,posX,posY)
            end
        end
    else
        for k,boxSp in pairs(self.boxSpTb) do
            if boxSp then
                boxSp:removeFromParentAndCleanup(true)
                boxSp=nil
            end
            self.boxSpTb={}
        end
        for i=1,chestNum do
            local cellId
            if i~=chestNum then
                cellId=chestTb[i]
            else
                cellId=exitId
            end
            local flag=false
            if cellId==exitId then
                flag=acMineExploreVoApi:isReachExit()
            else
                flag=acMineExploreVoApi:isUnlockChest(cellId)
            end
            local spaceX=0
            if chestNum>=2 then
                spaceX=(bgSize.width-260)/(chestNum-1)
            end
            local addH=0
            if G_isIphone5()==true then
                addH=50
            end
            local posX=130+(i-1)*spaceX
            local posY=145+addH
            refreshChest(cellId,flag,posX,posY)
        end
    end
end

function acMineExploreLottery:refreshDigBtn()
   if self.isEnd==true then
        self.digBtn:setEnabled(false)
        self.multiDigBtn:setEnabled(false)
        do return end
    end
    if self.digBtn and self.multiDigBtn and self.digCostNode and self.multiCostNode then
        local digCount=acMineExploreVoApi:getCanDigCount()
        local freeFlag=acMineExploreVoApi:isFreeDig()
        local btnLb=tolua.cast(self.digBtn:getChildByTag(11),"CCLabelTTF")
        local btnLb2=tolua.cast(self.multiDigBtn:getChildByTag(11),"CCLabelTTF")
        if btnLb and btnLb2 then            
            if freeFlag==1 then
                btnLb:setString(getlocal("daily_lotto_tip_2"))
                self.digCostNode:setVisible(false)
                self.multiDigBtn:setEnabled(false)
            else
                btnLb:setString(getlocal("excavate"))
                self.digCostNode:setVisible(true)
                self.multiDigBtn:setEnabled(true)
            end
            local cost1,cost2=acMineExploreVoApi:getDigCost()
            local costLb=tolua.cast(self.multiCostNode:getChildByTag(101),"CCLabelTTF")
            local costSp=tolua.cast(self.multiCostNode:getChildByTag(102),"CCSprite")
            if costLb and costSp then
                costLb:setString(tostring(cost2))
                local costLbW=200
                local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width
                local firstPosX=(costLbW-lbWidth)/2
                costLb:setPosition(ccp(firstPosX,0))
                costSp:setPosition(ccp(costLb:getPositionX()+costLb:getContentSize().width,0))
            end
            btnLb2:setString(getlocal("multi_excavate",{digCount}))
            if digCount==0 then
                self.digBtn:setEnabled(false)
                self.multiDigBtn:setEnabled(false)
            else
                self.digBtn:setEnabled(true)
                if freeFlag~=1 then
                    self.multiDigBtn:setEnabled(true)
                end
            end
        end
    end
end

function acMineExploreLottery:digHandler(dtype)
    local digNum=1
    if dtype==2 then
        digNum=acMineExploreVoApi:getCanDigCount()
    end
    local function realDig(digNum,cost)
        local function callback(result,map,digTb,rewardlist,tipStrTb,allRewards)
            if result==false then
                do return end
            end
            local chestCount=0 --本次挖掘的宝箱的个数
            local hasExit=false
            local exitId=acMineExploreVoApi:getEntry()
            for k,v in pairs(digTb) do
                local flag=acMineExploreVoApi:isUnlockChest(v)
                if flag==true then
                    chestCount=chestCount+1
                end
                if exitId==tonumber(v) then
                    hasExit=true
                end
            end
            local function showExitPrompt()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("explore_next_prompt7"),30)
            end
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then           
                local function showRewards()
                    if chestCount<=0 and dtype==1 then
                        for k,v in pairs(rewardlist) do
                            G_showRewardTip(v)
                        end
                        if hasExit==true then
                            showExitPrompt()
                        end
                    else
                        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
                        local titleStr=getlocal("open_maze_num",{digNum})
                        local function callback()
                            if hasExit==true then
                                showExitPrompt()
                            end
                            if allRewards then
                                G_showRewardTip(allRewards)
                            end
                        end
                        acMineExploreVoApi:showRewardSmallDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardlist,tipStrTb,false,true,self.layerNum+1,callback)
                    end
                    self.digCallBack=nil
                    self:refresh(false,map,digTb)
                end
                self.digCallBack=showRewards
                local function speedUp()
                    if self.digCallBack then
                        self.digCallBack()
                    end
                end
                self:playDigEffect(digTb,showRewards,speedUp)
            end
            self:refreshDigBtn()
        end
        local freeFlag=acMineExploreVoApi:isFreeDig()
        acMineExploreVoApi:mineExploreRequest("active.mineexplore",{freeFlag,digNum},callback)
        self:removeArrow()
    end
    local cost=0
    local freeFlag=acMineExploreVoApi:isFreeDig()
    local cost1,cost2=acMineExploreVoApi:getDigCost()
    if cost1 and cost2 then
        if dtype==1 and freeFlag==0 then
            cost=cost1
        elseif dtype==2 then
            cost=cost2
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        realDig(digNum,cost)
    end
end

function acMineExploreLottery:recordHandler()
    local function callback()
        local function showNoRecord()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        end
        local recordList=acMineExploreVoApi:getRecordList()
        local rc=SizeOfTable(recordList)
        if rc==0 then
            showNoRecord()
            do return end
        end
        local recordCount=SizeOfTable(recordList)
        if recordCount==0 then
            showNoRecord()
            do return end
        end
        local recordNum=10
        local function confirmHandler()
        end
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
        acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),recordList,false,self.layerNum+1,confirmHandler,true,recordNum)
    end
    local flag=acMineExploreVoApi:getRequestLogFlag()
    if flag==false then
        acMineExploreVoApi:mineExploreRequest("active.mineexplore.report",nil,callback)
    else
        callback()
    end
end

function acMineExploreLottery:refreshFloorLb()
    if self.floorLb and self.promptLb then
        local floorNum=acMineExploreVoApi:getLayer()
        self.floorLb:setString(getlocal("super_weapon_challenge_floors",{floorNum}))
        local remain=acMineExploreVoApi:getRemainDoubleLayer()
        local remainStr=""
        if remain==0 then
            remainStr=getlocal("explore_next_prompt4")
        else
            remainStr=getlocal("explore_next_prompt3",{remain})
        end
        self.promptLb:setString(remainStr)
    end
end

function acMineExploreLottery:refresh(isNext,mapData,cellTb)
    if self.pointLb then
        local point=acMineExploreVoApi:getMyPoint()
        local pointStr=getlocal("activity_mineExplore_money").."："..point
        self.pointLb:setString(pointStr)
    end
    local flag=acMineExploreVoApi:isShowLayerRank()
    if flag==false then
        self.rankBg:setVisible(false)
    else
        self.rankBg:setVisible(true)
    end
    if self.rankLb then
        local rank=acMineExploreVoApi:getSelfRank()
        local rankStr=getlocal("reachLayer_prompt",{rank})
        self.rankLb:setString(rankStr)
    end
    self:refreshFloorLb()
    if isNext==true then
        self:initMazeLayer()
    else
        self:refreshMazeLayer(mapData)
    end
    self:refreshChestLayer(cellTb)
    --在刷新按钮之前先判断是否有免费
    local todayFlag=acMineExploreVoApi:isToday()
    if todayFlag==false then
        acMineExploreVoApi:resetFreeDig()
    end
    self:refreshDigBtn()
end

function acMineExploreLottery:updateUI()
    if self.pointLb then
        local point=acMineExploreVoApi:getMyPoint()
        local pointStr=getlocal("activity_mineExplore_money").."："..point
        self.pointLb:setString(pointStr)
    end
end

function acMineExploreLottery:playDigEffect(digTab,endCallback,speedUp)
    if self.forbidLayer or digTab==nil then
        do return end
    end
    local function removeAction()
        self.mazeLayer:stopAllActions()
        self.forbidLayer:stopAllActions()
        self.forbidLayer:removeFromParentAndCleanup(true)
        self.forbidLayer=nil
        if speedUp then
            speedUp()
        end
    end
    local forbidLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),removeAction)
    forbidLayer:setTouchPriority(-(self.layerNum-1)*20-10)
    forbidLayer:setContentSize(G_VisibleSize)
    forbidLayer:setOpacity(0)
    forbidLayer:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(forbidLayer,10)
    self.forbidLayer=forbidLayer

    local cellW=98
    local totalTime=0
    local delayTime=0
    local openTime=0.5
    local openBoxTime=0.5
    local spaceTime=0.5
    --打开迷宫地块的动画
    local function openCell(target,isChest,isDelay)
        if target then
            local acArr=CCArray:create()
            if isDelay and isDelay==true then
                delayTime=delayTime+spaceTime
                local delay=CCDelayTime:create(delayTime)
                acArr:addObject(delay)
            end
            local zorder=3
            local function realOpen()
                local posX=target:getPositionX()
                local posY=target:getPositionY()
                local rotation=self.mazeLayer:getRotation()
                local targetPos=target:convertToWorldSpaceAR(ccp(0,0))
                targetPos.x=math.floor(targetPos.x)
                targetPos.y=math.floor(targetPos.y)
                for i=1,2 do
                    local pic="maze_shade"..i..".png"
                    local gateSp=CCSprite:createWithSpriteFrameName(pic)
                    local move
                    if i==1 then
                        move=ccp(-cellW/2,-cellW/2)
                    else
                        move=ccp(cellW/2,cellW/2)
                    end
                    if move and gateSp then
                        gateSp:setPosition(targetPos)
                        self.forbidLayer:addChild(gateSp,zorder)
                        local acArr=CCArray:create()
                        local moveBy=CCMoveBy:create(openTime,move)
                        acArr:addObject(moveBy)
                        local function removeSelf()
                            gateSp:removeFromParentAndCleanup(true)
                            gateSp=nil
                        end
                        local funcCall=CCCallFuncN:create(removeSelf)
                        acArr:addObject(funcCall)
                        local subseq=CCSequence:create(acArr)
                        gateSp:runAction(subseq)
                    end
       
                end
                if isChest==true then
                    --是否是隐藏宝箱
                    local boxSp=CCSprite:createWithSpriteFrameName("CommonBox.png")
                    boxSp:setAnchorPoint(ccp(0.5,0.5))
                    boxSp:setPosition(ccp(posX,posY))
                    boxSp:setRotation(-rotation)
                    boxSp:setTag(102)
                    boxSp:setScale(0)
                    self.mazeLayer:addChild(boxSp,zorder)
                    local scale=0.5
                    local acArr=CCArray:create()
                    local delay=CCDelayTime:create(openTime)
                    acArr:addObject(delay)
                    local scaleTo=CCScaleTo:create(openBoxTime,scale)
                    local out=CCEaseBounceInOut:create(scaleTo)
                    acArr:addObject(out)
                    local function callback()
                        boxSp:removeFromParentAndCleanup(true)
                        boxSp=nil
                        boxSp=CCSprite:createWithSpriteFrameName("CommonBoxOpen.png")
                        boxSp:setPosition(ccp(posX,posY))
                        boxSp:setRotation(-rotation)
                        boxSp:setScale(0.5)
                        boxSp:setTag(102)
                        self.mazeLayer:addChild(boxSp,zorder)
                    end
                    local funcCall=CCCallFuncN:create(callback)
                    acArr:addObject(funcCall)
                    local subseq=CCSequence:create(acArr)
                    boxSp:runAction(subseq)
                end
            end
            local function callback()
                local shadeSp=tolua.cast(target:getChildByTag(101),"CCSprite")
                if shadeSp then
                    shadeSp:setVisible(false)
                end
            end
            local func=CCCallFuncN:create(callback)
            acArr:addObject(func)
            local funcCall=CCCallFuncN:create(realOpen)
            acArr:addObject(funcCall)
            local subseq=CCSequence:create(acArr)
            self.mazeLayer:runAction(subseq)
        end
    end
    local boxCount=0
    for k,v in pairs(digTab) do
        if self.cellSpTb and self.cellSpTb[v] then
            local cellSp=self.cellSpTb[v]
            local isChest=acMineExploreVoApi:isUnlockChest(v)
            if k>1 then
                openCell(cellSp,isChest,true)
            else
                openCell(cellSp,isChest,false)
            end
            if isChest==true then
                boxCount=boxCount+1
            end
        end
    end
    local function actionEndHandler()
        if self.forbidLayer then
            self.forbidLayer:removeFromParentAndCleanup(true)
            self.forbidLayer=nil
        end
        if endCallback then
            endCallback()
        end
    end
    totalTime=totalTime+openTime+delayTime+boxCount*openBoxTime+0.5
    local acArr=CCArray:create()
    local delay=CCDelayTime:create(totalTime)
    local funcCall=CCCallFuncN:create(actionEndHandler)
    acArr:addObject(delay)
    acArr:addObject(funcCall)
    local subseq=CCSequence:create(acArr)
    self.forbidLayer:runAction(subseq)
end

function acMineExploreLottery:tick()
    local isEnd=acMineExploreVoApi:isEnd()
    if isEnd~=self.isEnd and isEnd==true then
        self.isEnd=isEnd
        if self.digBtn and self.multiDigBtn then
            self.digBtn:setEnabled(false)
            self.multiDigBtn:setEnabled(false)  
        end
    end
    if isEnd==false then
        local todayFlag=acMineExploreVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acMineExploreVoApi:resetFreeDig()
            self:refreshDigBtn()
        end
    end
end

function acMineExploreLottery:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.forbidLayer=nil
    self.isEnd=false
    self.digBtn=nil
    self.multiDigBtn=nil
    self.digCostNode=nil
    self.multiCostNode=nil
    self.mainLayer=nil
    self.mazeLayer=nil
    self.cellSpTb=nil
    self.digCallBack=nil
    self.isTodayFlag=true
    self.boxSpTb=nil
    self.floorLb=nil
    self.promptLb=nil
    self.arrowTb=nil
    self.exitLayer=nil
    self.tipLb=nil
    self.arrowSp=nil
    self.pointLb=nil
    self.rankLb=nil
    self.rankBg=nil
end