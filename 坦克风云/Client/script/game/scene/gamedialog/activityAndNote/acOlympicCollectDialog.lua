acOlympicCollectDialog=commonDialog:new()

function acOlympicCollectDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=nil
    self.currDay=nil
    self.desHeight=200
    self.height=110
    self.tvHeight=G_VisibleSizeHeight-270
    self.cellHeight=0
    self.addHeight=0
    return nc
end

function acOlympicCollectDialog:initBg()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX((G_VisibleSizeWidth-20)/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,20)
    self.bgLayer:addChild(blueBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local function nilFunction()
    end
    local lineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),nilFunction)
    lineBg:setPosition(ccp(G_VisibleSizeWidth/2,self.bgLayer:getContentSize().height/2-36))
    lineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    self.bgLayer:addChild(lineBg)
end

function acOlympicCollectDialog:initLayer()
    local function bgClick()
    end
    local w=G_VisibleSizeWidth-20 -- 背景框的宽度
    local h=G_VisibleSizeHeight-100
    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
            local tabStr={}
            local tabColor ={}
            local td=smallDialog:new()
            tabStr={"\n",getlocal("activity_aoyunjizhang_rule4"),getlocal("activity_aoyunjizhang_rule3"),getlocal("activity_aoyunjizhang_rule2"),getlocal("activity_aoyunjizhang_rule1"),"\n"}
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,nil,nil,nil,nil,nil})
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-30,h+10))
    self.bgLayer:addChild(menuDesc)
  
    local timeStr=acOlympicCollectVoApi:getTimeStr()
    local timeLb=GetTTFLabelWrap(timeStr,25,CCSizeMake(G_VisibleSizeWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setPosition(ccp(G_VisibleSizeWidth/2,h))
    timeLb:setColor(G_ColorYellow)
    self.bgLayer:addChild(timeLb)
    local desTv,desLabel=G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-40,60+self.addHeight),getlocal("activity_aoyunjizhang_desc"),25,kCCTextAlignmentLeft)
    self.bgLayer:addChild(desTv)
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setPosition(ccp(20,h-timeLb:getContentSize().height-(60+self.addHeight)))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(120)

    local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine:setPosition(ccp(G_VisibleSizeWidth/2,desTv:getPositionY()-10))
    orangeLine:setScaleX(w/orangeLine:getContentSize().width)
    self.bgLayer:addChild(orangeLine)

    local upLayer=CCSprite:createWithSpriteFrameName("brown_fade1.png")
    upLayer:setScaleX((G_VisibleSizeWidth-20)/upLayer:getContentSize().width)
    upLayer:setScaleY(100/upLayer:getContentSize().height)
    upLayer:setRotation(180)
    upLayer:setAnchorPoint(ccp(0.5,0))
    upLayer:setPosition(ccp(G_VisibleSizeWidth/2,orangeLine:getPositionY()-orangeLine:getContentSize().height))
    self.bgLayer:addChild(upLayer)

    local upLayer2=CCSprite:createWithSpriteFrameName("brown_fade2.png")
    upLayer2:setScaleX((G_VisibleSizeWidth-20)/upLayer2:getContentSize().width)
    upLayer2:setScaleY(200/upLayer2:getContentSize().height)
    upLayer2:setAnchorPoint(ccp(0.5,1))
    upLayer2:setPosition(ccp(G_VisibleSizeWidth/2,orangeLine:getPositionY()-orangeLine:getContentSize().height))
    self.bgLayer:addChild(upLayer2)

    local downLayer=CCSprite:createWithSpriteFrameName("brown_fade1.png")
    downLayer:setScaleX((G_VisibleSizeWidth-20)/downLayer:getContentSize().width)
    downLayer:setScaleY(100/downLayer:getContentSize().height)
    downLayer:setAnchorPoint(ccp(0.5,0))
    downLayer:setPosition(ccp(G_VisibleSizeWidth/2,15))
    self.bgLayer:addChild(downLayer)

end

function acOlympicCollectDialog:initTableView()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acRadar_images.plist")
    spriteController:addTexture("public/acRadar_images.png")
    spriteController:addPlist("public/acRechargeBag_images.plist")
    spriteController:addTexture("public/acRechargeBag_images.png")
    spriteController:addPlist("public/acolympic_images.plist")
    spriteController:addTexture("public/acolympic_images.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/serverWarLocal/serverWarLocal2.plist")
    spriteController:addTexture("public/serverWarLocal/serverWarLocal2.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self.currDay=acOlympicCollectVoApi:getNumDayOfActive()
    self.taskPoint=acOlympicCollectVoApi:getTaskPoint()
    self.numberCell=SizeOfTable(self.taskPoint)
    self.dayNum=acOlympicCollectVoApi:getNumOfDay()
    if G_isIphone5() then
        self.height=130
        self.addHeight=40
    end
    self.tvHeight=G_VisibleSizeHeight-250-self.addHeight
    self.cellHeight=self.height*self.numberCell+self.height
    self:initBg()
    self:initLayer()
    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.tvHeight),nil)
    self.tv:setPosition(ccp(15,20))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv,1)
    if self.numberCell<=5 then
        self.tv:setMaxDisToBottomOrTop(0)
    else
        self.tv:setMaxDisToBottomOrTop(120)
    end
end

function acOlympicCollectDialog:eventHandler(handler,fn,idx,cel)
    local strSize2=15
    local strSize3=18
    local strSize4 = 16
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
        strSize2=22
        strSize3=25
        strSize4 =22
    end
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(G_VisibleSizeWidth-30,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local totalH=self.height*self.numberCell
        local barWidth=totalH
        local addH=20
        -- local totalScore=self.taskPoint[self.numberCell]
        for i=1,self.numberCell do
            local capInSet=CCRect(20, 20, 10, 10)
            local function cellClick()
            end
            local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-280, 80))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0.5))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
            backSprie:setPosition(220,0+i*self.height+addH)
            cell:addChild(backSprie,1)
            backSprie:setOpacity(0)
            -- 礼包
            local flag=acOlympicCollectVoApi:taskPointState(i,self.taskPoint)        
            local function touchReward()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    local reward=acOlympicCollectVoApi:getTaskPointReward(i)
                    local rewardItem=FormatItem(reward,nil,true)

                    if flag==2 then
                        local function callback()
                            acOlympicCollectVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_getReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem,true)
                            for k,v in pairs(rewardItem) do
                                if v.type~="p" then
                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                end
                            end
                            G_showRewardTip(rewardItem)
                            local recordPoint=self.tv:getRecordPoint()
                            self.tv:reloadData()
                            self.tv:recoverToRecordPoint(recordPoint)
                        end
                        local action=1
                        local tid=i
                        acOlympicCollectVoApi:getSocketReward(action,nil,tid,callback)
                        return
                    elseif flag==1 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_hadReward"),28)
                    else
                        local desStr2=getlocal("activity_aoyunjizhang_taskReward" .. i)
                        acOlympicCollectVoApi:showSmallDialog(true,true,self.layerNum+1,desStr2,"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem)     
                    end
                end
            end
            local rewardPic="friendBtn.png"
            local scale=0.9
            local scale2=1.2
            local boxOffsetH=-20
            if i==self.numberCell then
                boxOffsetH=20
            end
            if i==self.numberCell then
                rewardPic="mainBtnGift.png"
                scale=1.3
                scale2=1.5
                local guangSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
                guangSp1:setPosition(-60,backSprie:getContentSize().height/2+boxOffsetH)
                backSprie:addChild(guangSp1)

                local guangSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
                guangSp2:setPosition(-60,backSprie:getContentSize().height/2+boxOffsetH)
                backSprie:addChild(guangSp2)

                local rotateBy=CCRotateBy:create(4,360)
                local reverseBy=rotateBy:reverse()
                guangSp1:runAction(CCRepeatForever:create(rotateBy))
                guangSp2:runAction(CCRepeatForever:create(reverseBy))
            end
            local rewardSp=LuaCCSprite:createWithSpriteFrameName(rewardPic,touchReward)
            rewardSp:setTouchPriority(-(self.layerNum-1)*20-3)
            rewardSp:setPosition(170,i*self.height+addH+boxOffsetH)
            cell:addChild(rewardSp,3)
            rewardSp:setScale(scale)

            local libaoStr=""
            local color=G_ColorWhite
            local libaoLbPosY=0
            if flag==3 then
                libaoStr=getlocal("activity_chunjiepansheng_click_kan")
                color=G_ColorWhite
            elseif flag==2 then
                rewardSp:runAction(self:canRewardAction(scale,scale2))
                self:particleAction(rewardSp)

                libaoStr=getlocal("canReward")
                color=G_ColorGreen
            elseif flag==1 then
                libaoStr=getlocal("activity_hadReward")
                color=G_ColorWhite
                local blackSp=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function()end)
                blackSp:setContentSize(CCSizeMake(100,35))
                blackSp:ignoreAnchorPointForPosition(false);
                blackSp:setIsSallow(false)
                blackSp:setTouchPriority(-(self.layerNum-1)*20-3)
                blackSp:setPosition(ccp(rewardSp:getContentSize().width/2,rewardSp:getContentSize().height/2))
                rewardSp:addChild(blackSp)
                libaoLbPosY=rewardSp:getContentSize().height/2
            end
            local libaoLb=GetTTFLabelWrap(libaoStr,strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            libaoLb:setAnchorPoint(ccp(0.5,0.5))
            libaoLb:setColor(color)
            libaoLb:setPosition(ccp(rewardSp:getContentSize().width/2,libaoLbPosY))
            rewardSp:addChild(libaoLb,2)
            libaoLb:setScale(1/scale)
            -- 数字背景
            if i~=self.numberCell then
                -- 刻度线
                local keduSp=CCSprite:createWithSpriteFrameName("acRadar_splitline.png")
                keduSp:setPosition(44,i*self.height+addH)
                -- local posY=self.taskPoint[i]/totalScore*barWidth
                -- keduSp:setPosition(44,posY)
                cell:addChild(keduSp,3)

                local numBgSp=CCSprite:createWithSpriteFrameName("acRadar_numlabel.png")
                numBgSp:setAnchorPoint(ccp(0,1))
                numBgSp:setPosition(53,i*self.height+addH+8)
                -- numBgSp:setPosition(53,posY)
                cell:addChild(numBgSp,3)

                local numLb=GetTTFLabel(self.taskPoint[i],22)
                numLb:setPosition(numBgSp:getContentSize().width/2,numBgSp:getContentSize().height/2)
                numBgSp:addChild(numLb)
            end
        end

        local barWidth=totalH
        local function click(hd,fn,idx)
        end
        local barSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_progressBg.png",CCRect(15,50,50,80),click)
        barSprie:setContentSize(CCSizeMake(86,barWidth+60))
        barSprie:setPosition(ccp(44,barWidth/2+addH))
        cell:addChild(barSprie,1)

        local dingSp=CCSprite:createWithSpriteFrameName("olympic_score_labelbg.png")
        dingSp:setAnchorPoint(ccp(0.5,0))
        dingSp:setPosition(barSprie:getContentSize().width/2,barSprie:getContentSize().height-10)
        barSprie:addChild(dingSp)

        local numLb=GetTTFLabel(self.taskPoint[self.numberCell],22)
        numLb:setPosition(dingSp:getContentSize().width/2,dingSp:getContentSize().height/2+3)
        dingSp:addChild(numLb)

        AddProgramTimer(cell,ccp(44,barWidth/2+addH),11,12,nil,"acChunjiepansheng_progress2.png","acChunjiepansheng_progress1.png",13,1,1,nil,ccp(0,1))
        local per=acOlympicCollectVoApi:getPercentage()
        local timerSpriteLv=cell:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setScaleY((barWidth)/timerSpriteLv:getContentSize().height)
        timerSpriteLv:setRotation(180)
        local bg=cell:getChildByTag(13)
        bg:setScaleY((barWidth)/bg:getContentSize().height)
        bg:setScaleX(1.2)

        --显示所有项目信息
        local spaceH=130
        local offestH=0
        if G_isIphone5() then
            spaceH=150
            offestH=-15
        end
        local posY=self.cellHeight-60
        for i=1,self.dayNum do
            local posX=230+(i-1)%3*(130)
            local pic,name,desc,openDay=acOlympicCollectVoApi:getDayOfEvent(i)
            local function enterEventHandler()
                require "luascript/script/game/scene/gamedialog/activityAndNote/noteDetailDialog"
                local sd=acOlympicEventDialog:new(i)
                local eventDialog=sd:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,name,true,self.layerNum+1)
                sceneGame:addChild(eventDialog,self.layerNum+1)
            end
            local bgPic="event_bluebg.png"
            local numBgPic="serverWarLocal_bg3.png"
            local cur,max=acOlympicCollectVoApi:getDayTaskProgress(i)
            if cur>=max then
                bgPic="event_goldbg.png"
                numBgPic="olympic_collect.png"
            end
            local bgSp=LuaCCSprite:createWithSpriteFrameName(bgPic,enterEventHandler)
            bgSp:setAnchorPoint(ccp(0,1))
            bgSp:setTouchPriority(-(self.layerNum-1)*20-3)
            bgSp:setPosition(ccp(posX,posY))
            cell:addChild(bgSp)
            local bgSize=bgSp:getContentSize()
            local eventIcon=CCSprite:createWithSpriteFrameName(pic)
            eventIcon:setPosition(ccp(bgSize.width/2,bgSize.height/2))
            bgSp:addChild(eventIcon)
            local progressBg=LuaCCScale9Sprite:createWithSpriteFrameName(numBgPic,CCRect(10,10,10,10),function()end)
            progressBg:setContentSize(CCSizeMake(70,30))
            progressBg:setPosition(ccp(posX+bgSize.width/2,posY-10))
            cell:addChild(progressBg,10)
            local cur,max=acOlympicCollectVoApi:getDayTaskProgress(i)
            local numLb=GetTTFLabel(cur.."/"..max,22)
            numLb:setPosition(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2)
            progressBg:addChild(numLb)

            local linePic="acChunjiepansheng_orangeLine.png"
            local lbBgPic="orangeMask.png"
            local currDay=acOlympicCollectVoApi:getNumDayOfActive()
            local spaceY1=5
            local spaceY2=-8
            local openStr=G_getDateStr(openDay,false,true,true)
            --判断是不是项目开启日，给出效果提示
            if currDay==i then
                G_addFlicker(bgSp,2.5,2.5,ccp(bgSize.width/2,bgSize.height/2))
                linePic="LineCross.png"
                lbBgPic="groupSelf.png"
                spaceY1=0
                spaceY2=0
                openStr=getlocal("today_str")
            else
                if currDay>i then
                    openStr=getlocal("function_end_str")
                    if cur<max then
                        local blackSp=CCSprite:createWithSpriteFrameName("event_disable.png")
                        blackSp:setPosition(ccp(bgSize.width/2,bgSize.height/2))
                        bgSp:addChild(blackSp,2)
                    end
                end
                G_removeFlicker(bgSp)
            end
            local lbBg=CCSprite:createWithSpriteFrameName(lbBgPic)
            lbBg:setScaleX(150/lbBg:getContentSize().width)
            lbBg:setScaleY(50/lbBg:getContentSize().height)
            lbBg:setAnchorPoint(ccp(0.5,1))
            lbBg:setPosition(ccp(bgSize.width/2,30+offestH))
            bgSp:addChild(lbBg,1)
            local lbBgW=lbBg:getContentSize().width*lbBg:getScaleX()
            local lbBgH=lbBg:getContentSize().height*lbBg:getScaleY()
            local lineSp1=CCSprite:createWithSpriteFrameName(linePic)
            lineSp1:setAnchorPoint(ccp(0.5,0))
            lineSp1:setScaleX((lbBgW-40)/lineSp1:getContentSize().width)
            lineSp1:setPosition(ccp(bgSize.width/2,24+spaceY1+offestH))
            bgSp:addChild(lineSp1)
            local lineSp2=CCSprite:createWithSpriteFrameName(linePic)
            lineSp2:setAnchorPoint(ccp(0.5,1))
            lineSp2:setScaleX((lbBgW-40)/lineSp2:getContentSize().width)
            lineSp2:setPosition(ccp(bgSize.width/2,lineSp1:getPositionY()-lbBgH+10+spaceY2))
            bgSp:addChild(lineSp2)
            local nameLb=GetTTFLabelWrap(name,strSize4,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0.5,1))
            nameLb:setPosition(ccp(bgSize.width/2,30+offestH))
            bgSp:addChild(nameLb,10)
            local dayLb=GetTTFLabelWrap(openStr,strSize4,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            dayLb:setAnchorPoint(ccp(0.5,1))
            dayLb:setPosition(ccp(bgSize.width/2,nameLb:getPositionY()-nameLb:getContentSize().height))
            bgSp:addChild(dayLb,10)

            if currDay>i then
                local blackSp=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function()end)
                blackSp:setContentSize(CCSizeMake(120,55))
                blackSp:ignoreAnchorPointForPosition(false);
                blackSp:setAnchorPoint(ccp(0.5,1))
                blackSp:setIsSallow(false)
                blackSp:setTouchPriority(-(self.layerNum-1)*20-3)
                blackSp:setPosition(ccp(bgSize.width/2,32+offestH))
                bgSp:addChild(blackSp,5)
            end
       
            local flag=acOlympicCollectVoApi:isCanGetCurReward(i,max)
            local taskList=acOlympicCollectVoApi:getDayOfTask(i)
            local getFlag=false
            for k,v in pairs(taskList) do
                local flag=acOlympicCollectVoApi:getTaskState(i,k,v[1][1],v[1][2])
                if flag==2 then
                    getFlag=true
                    do break end
                end
            end
            --如果可以领取项目所有任务完成礼包，则给出红点提示
            if flag==2 or getFlag==true then
                local tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
                tipSp:setPosition(ccp(posX+bgSize.width-20,posY-25))
                tipSp:setScale(0.8)
                cell:addChild(tipSp,10)
            end
            if i%3==0 then
                posY=posY-spaceH
            end
        end
        local function nilFunc()
        end
        local integralBg=LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_integralBg.png",CCRect(75,35,50,30),nilFunc)
        integralBg:setAnchorPoint(ccp(0.5,1))
        integralBg:setContentSize(CCSizeMake(G_VisibleSize.width-300,80))
        integralBg:setPosition(ccp(G_VisibleSizeWidth-60-integralBg:getContentSize().width/2,self.cellHeight+10))
        cell:addChild(integralBg,1)
        local integralIcon=CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
        integralIcon:setAnchorPoint(ccp(0,0.5))
        integralBg:addChild(integralIcon)
        local myPoint=acOlympicCollectVoApi:getMyPoint()
        local integralLb=GetTTFLabel(myPoint,25)
        integralLb:setAnchorPoint(ccp(0,0.5))
        integralBg:addChild(integralLb)
        local cwidth=integralIcon:getContentSize().width+integralLb:getContentSize().width
        integralIcon:setPosition(ccp((integralBg:getContentSize().width-cwidth)/2,integralBg:getContentSize().height/2+12))
        integralLb:setPosition(ccp(integralIcon:getPositionX()+integralIcon:getContentSize().width,integralBg:getContentSize().height/2+12))
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

-- scale1:初始大小
function acOlympicCollectDialog:canRewardAction(scale1,scale2)
    local scaleTo1=CCScaleTo:create(0.3,scale2)
    local scaleTo2=CCScaleTo:create(0.3,scale1)
    local array=CCArray:create()
    array:addObject(scaleTo1)
    array:addObject(scaleTo2)
    local seq=CCSequence:create(array)
    local everAction=CCRepeatForever:create(seq)
    return everAction
end

function acOlympicCollectDialog:particleAction(rewardSp)
    local p=CCParticleSystemQuad:create("public/xingxing.plist")
    p.positionType=kCCPositionTypeFree
    p:setPosition(ccp(rewardSp:getContentSize().width/2,rewardSp:getContentSize().height/2))
    rewardSp:addChild(p,3)
    p:setScale(0.7)

end

function acOlympicCollectDialog:refresh()
    if self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acOlympicCollectDialog:tick()
    if acOlympicCollectVoApi:isEnd()==true then
        self:close()
        do return end
    end
    local flag=acOlympicCollectVoApi:isNeedRefresh()
    if flag==true then
        self:refresh()
        acOlympicCollectVoApi:setRefresh(false)
    end
    local activeDay=acOlympicCollectVoApi:getNumDayOfActive()
    if self.currDay~=activeDay then
        self.currDay=activeDay
        self:refresh()
    end
end

function acOlympicCollectDialog:dispose()
    -- eventDispatcher:removeEventListener("chunjiepansheng.addTaskPoint",self.addTaskPointListener)
    spriteController:removePlist("public/acRadar_images.plist")
    spriteController:removeTexture("public/acRadar_images.png")
    spriteController:removePlist("public/acRechargeBag_images.plist")
    spriteController:removeTexture("public/acRechargeBag_images.png")
    spriteController:removePlist("public/acolympic_images.plist")
    spriteController:removeTexture("public/acolympic_images.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/serverWarLocal/serverWarLocal2.plist")
    spriteController:removeTexture("public/serverWarLocal/serverWarLocal2.png")
    self.bgLayer=nil
    self.layerNum=nil
    self.currDay=nil
    self.desHeight=200
    self.height=110
    self.tvHeight=G_VisibleSizeHeight-270
    self.cellHeight=0
    self.addHeight=0
end