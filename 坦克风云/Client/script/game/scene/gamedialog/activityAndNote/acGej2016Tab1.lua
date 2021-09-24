acGej2016Tab1={
}

function acGej2016Tab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum

    return nc;
end

function acGej2016Tab1:init()
    self.bgLayer=CCLayer:create()
    local nbReward={p={{p3337=1}}}
    local nbItem=FormatItem(nbReward)
    self.loveItem=nbItem[1]
    -- local function onRechargeChange(event,data)
    --     self:refreshUI()
    -- end
    -- self.wsjdzzListener=onRechargeChange
    -- eventDispatcher:addEventListener("activity.recharge",onRechargeChange)

    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acGej2016Tab1:initUI()

    -- 活动 时间 描述
    local lbH=self.bgLayer:getContentSize().height-185

    self.url=G_downloadUrl("active/gej2016/acGej2016_bg.jpg")

    local function onLoadIcon(fn,bgSp)
        if self and self.url then
            self.bgLayer:addChild(bgSp)
            bgSp:setAnchorPoint(ccp(0.5,1))
            bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-170))
            bgSp:setScale(595/bgSp:getContentSize().width)
            bgSp:setOpacity(40)
        end
    
    end
    local webImage = LuaCCWebImage:createWithURL(self.url,onLoadIcon)

    -- acGej2016_bg
    -- local bgSp=CCSprite:create("public/acGej2016_bg.jpg")
    -- self.bgLayer:addChild(bgSp)
    -- bgSp:setAnchorPoint(ccp(0.5,1))
    -- bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbH+15))
    -- bgSp:setScale(595/bgSp:getContentSize().width)
    -- bgSp:setOpacity(120)

    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorYellowPro)

    local acVo = acGej2016VoApi:getAcVo()
    lbH=lbH-35
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    self.bgLayer:addChild(timeLabel,1)

    lbH=lbH-35


    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-210)
    local tabStr={" ",getlocal("activity_gej2016_tip4"),getlocal("activity_gej2016_tip3"),getlocal("activity_gej2016_tip2"),getlocal("activity_gej2016_tip1")," "}
    local colorTab={G_ColorWhite,G_ColorYellowPro}
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,colorTab,nil)

    local function clickBoxHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local flag=acGej2016VoApi:GetDailyBoxState()
        if flag~=0 then
            return
        end
        local function refreshFunc(rewardlist)
            self.infoLb:setString(getlocal("activity_baifudali_dailyHadReward"))
            self:removeGuangSp()
            -- 此处加弹板
            if rewardlist then
                acGej2016VoApi:showRewardDialog(rewardlist,self.layerNum)
            end
        end
        local action="daybag"
        acGej2016VoApi:socketGej2016(action,refreshFunc,tid)
    end

    
    local boxSp=LuaCCSprite:createWithSpriteFrameName("advanceMaterialBox.png",clickBoxHandler)
    local boxSize=boxSp:getContentSize()

    boxSp:setAnchorPoint(ccp(0.5,0.5))
    local boxScale=150/boxSize.width

    boxSp:setTouchPriority(-(self.layerNum-1)*20-4)
    boxSp:setPosition(30+boxSize.width/2*boxScale,lbH-boxSize.height/2-10)
    self.bgLayer:addChild(boxSp,3)
    
    boxSp:setScale(boxScale)

    self.guangPos=ccp(30+boxSize.width/2*boxScale,lbH-boxSize.height/2-10)
    local flag=acGej2016VoApi:GetDailyBoxState()
    local infoStr=getlocal("activity_baifudali_dailyHadReward")
    if flag==0 then
        self:addGuangSp()
        infoStr=getlocal("activity_shengdankuanghuan_ClickReward")
    end
    

    local infoBg =CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
    infoBg:setAnchorPoint(ccp(0.5,0.5))
    infoBg:setPosition(ccp(boxSp:getContentSize().width/2,20))
    boxSp:addChild(infoBg)
    infoBg:setScale(1/boxScale)

    local infoLb=GetTTFLabelWrap(infoStr,25,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter) 
    boxSp:addChild(infoLb,2)
    infoLb:setPosition(boxSp:getContentSize().width/2,20)
    infoLb:setScale(1/boxScale)
    self.infoLb=infoLb
    -- activity_shengdankuanghuan_ClickReward
    -- activity_baifudali_dailyHadReward

    local lixiangTitleLb=GetTTFLabelWrap(getlocal("activity_gej2016_libao_title"),30,CCSize(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    lixiangTitleLb:setAnchorPoint(ccp(0.5,0))
    lixiangTitleLb:setPosition(140+(G_VisibleSizeWidth-140)/2,lbH-30)
    lixiangTitleLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(lixiangTitleLb,1)

    local lixiangDesLb=GetTTFLabelWrap(getlocal("activity_feixutansuo_rewardDesc"),22,CCSize(140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    lixiangDesLb:setAnchorPoint(ccp(0,0.5))
    lixiangDesLb:setPosition(200,lbH-90)
    self.bgLayer:addChild(lixiangDesLb,1)

    local priceReward=acGej2016VoApi:getPriceReward()
    local priceItem=FormatItem(priceReward,nil,true)
    local startW=200+lixiangDesLb:getContentSize().width
    for k,v in pairs(priceItem) do
        local icon,scale=G_getItemIcon(v,100,true,self.layerNum,nil,nil,nil,nil,true)
        icon:setScale(80/icon:getContentSize().width)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(startW,lbH-90)
        self.bgLayer:addChild(icon,2)
        startW=startW+90
        G_addRectFlicker(icon,1.3,1.3)
    end

    -- 彩带
    for i=1,2 do
        local caidaiSp=CCSprite:createWithSpriteFrameName("acGej2016_caidai" .. i .. ".png")
        self.bgLayer:addChild(caidaiSp,3)
        caidaiSp:setAnchorPoint(ccp(0.5,1))
        if i==1 then
            caidaiSp:setPosition(45,lbH-145)
        else
            caidaiSp:setPosition(G_VisibleSizeWidth-65,lbH-130)
        end

    end


    local function nilFunc()
    end
    local bottomSp=LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27,29,2,2),nilFunc)
    bottomSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,80))
    bottomSp:ignoreAnchorPointForPosition(false)
    bottomSp:setAnchorPoint(ccp(0.5,0))
    bottomSp:setPosition(ccp(G_VisibleSizeWidth/2,35))
    self.bgLayer:addChild(bottomSp,1)

    local nociteLb=GetTTFLabelWrap(getlocal("activity_gej2016_notice"),25,CCSize(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nociteLb:setAnchorPoint(ccp(0,0.5))
    nociteLb:setPosition(20,bottomSp:getContentSize().height/2)
    bottomSp:addChild(nociteLb)
    nociteLb:setColor(G_ColorRed)

    self.tvH=lbH-150-bottomSp:getContentSize().height-40
end

function acGej2016Tab1:initTableView()

    self.cellHeight=155
    self.taskTb=acGej2016VoApi:getCurrentTaskState()
    self.cellNum=SizeOfTable(self.taskTb)

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,120))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acGej2016Tab1:eventHandler(handler,fn,idx,cel)
    strSize2 = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local index=self.taskTb[idx+1].index

        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end

        local bgPic="NoticeLine.png"
        if index<1000 then
            bgPic="letterBgWrite.png"
        end
        -- letterBgWrite
        -- NoticeLine
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(bgPic,capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie,1)

        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setPosition(backSprie:getContentSize().width/2+5,backSprie:getContentSize().height/2)
        cell:addChild(bgSp)
        bgSp:setScaleX((backSprie:getContentSize().width-5)/bgSp:getContentSize().width)
        bgSp:setScaleY((backSprie:getContentSize().height-10)/bgSp:getContentSize().height)
        bgSp:setOpacity(120)


        -- 数据
        local valueTb=self.taskTb[idx+1].value
        local trueIndex=valueTb.type
        local haveNum=self.taskTb[idx+1].haveNum
        local needNum=valueTb.needNum
        local loveNum=valueTb.love

        -- 任务描述
        local lbStarWidth=20
        local titleStr
        if trueIndex ==1 then
            titleStr=getlocal("activity_gej2016_task" .. trueIndex)
        else
            titleStr=getlocal("activity_gej2016_task" .. trueIndex,{FormatNumber(haveNum) .. "/" .. FormatNumber(needNum)})
        end
        -- local titleStr=getlocal("activity_gej2016_task" .. trueIndex,{haveNum .. "/" .. needNum})
        local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-10))
        backSprie:addChild(titleLb,1)

        local leftLineSP =CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        -- leftLineSP:setFlipX(true)
        leftLineSP:setAnchorPoint(ccp(0,0.5))
        leftLineSP:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-20-titleLb:getContentSize().height))
        backSprie:addChild(leftLineSP,1)

        -- 奖励描述
        local desH=(self.cellHeight - titleLb:getContentSize().height-20)/2
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),22,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(lbStarWidth,desH))
        backSprie:addChild(desLb)

        -- 奖励展示
        local rewardItem=FormatItem(valueTb.reward,nil,true)
        local taskW=0
        for k,v in pairs(rewardItem) do
            local icon = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(icon)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(k*100+20, desH)
            local scale=80/icon:getContentSize().width
            icon:setScale(scale)
            taskW=k*100


            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)
        end

        
        if index>10000 then -- 已完成(已领取)
            -- local p1Sp=CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
            -- backSprie:addChild(p1Sp)
            -- p1Sp:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            -- p1Sp:setScale(0.6)
            local desLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- desLb:setColor(G_ColorYellowPro)
            desLb:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            backSprie:addChild(desLb)
            desLb:setColor(G_ColorGreen)
            titleLb:setColor(G_ColorWhite)
        elseif index>1000 then -- 未完成
            -- local function goTiantang()
            --     if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            --         if G_checkClickEnable()==false then
            --             do
            --                 return
            --             end
            --         else
            --             base.setWaitTime=G_getCurDeviceMillTime()
            --         end

            --         G_goToDialog2(valueTb.key,4,true)
            --     end

            -- end
            -- local goItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),25)
            -- -- goItem:setScale(0.8)
            -- local goBtn=CCMenu:createWithItem(goItem);
            -- goBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            -- goBtn:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            -- backSprie:addChild(goBtn)

            local desLb=GetTTFLabelWrap(getlocal("local_war_incomplete"),strSize2,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- desLb:setColor(G_ColorYellowPro)
            desLb:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            backSprie:addChild(desLb)

        else -- 可领取
            local function rewardTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    local function refreshFunc(rewardlist)
                        self.taskTb=acGej2016VoApi:getCurrentTaskState()
                        local recordPoint=self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)

                        -- 此处加弹板
                        -- 爱心值后台不会返成道具格式，前台自己加
                        
                        if rewardlist then
                            self.loveItem.num=loveNum
                            table.insert(rewardlist,self.loveItem)
                            acGej2016VoApi:showRewardDialog(rewardlist,self.layerNum)
                        end
                    end
                    local action="taskrewawrd"
                    local tid=trueIndex
                    acGej2016VoApi:socketGej2016(action,refreshFunc,tid)
                

                end
            end
            -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
            local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardTiantang,nil,getlocal("daily_scene_get"),25)
            -- rewardItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            backSprie:addChild(rewardBtn)
        end


        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acGej2016Tab1:removeGuangSp()
    local guangSp1=tolua.cast(self.bgLayer:getChildByTag(301),"CCSprite")
    if guangSp1 then
        guangSp1:removeFromParentAndCleanup(true)
        guangSp1=nil
    end
    local guangSp2=tolua.cast(self.bgLayer:getChildByTag(302),"CCSprite")
    if guangSp2 then
        guangSp2:removeFromParentAndCleanup(true)
        guangSp2=nil
    end
end

function acGej2016Tab1:addGuangSp()
    local guangSp1=tolua.cast(self.bgLayer:getChildByTag(301),"CCSprite")
    if guangSp1 then
        do return end
    end

    -- self.guangPos
    guangSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
    self.bgLayer:addChild(guangSp1,1)
    guangSp1:setPosition(self.guangPos)
    guangSp1:setScale(1.3)
    guangSp1:setTag(301)

    local guangSp2=tolua.cast(self.bgLayer:getChildByTag(302),"CCSprite")
    if guangSp2 then
        do return end
    end
    guangSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
    self.bgLayer:addChild(guangSp2,1)
    guangSp2:setPosition(self.guangPos)
    guangSp2:setScale(1.3)
    guangSp2:setTag(302)

    local rotateBy = CCRotateBy:create(4,360)
    local reverseBy = rotateBy:reverse()
    guangSp1:runAction(CCRepeatForever:create(rotateBy))
    guangSp2:runAction(CCRepeatForever:create(reverseBy))
end

function acGej2016Tab1:refresh()
    if self.infoLb then
        self.infoLb:setString(getlocal("activity_baifudali_dailyHadReward"))
        self:addGuangSp()
    end
    if self.tv then
        self.taskTb=acGej2016VoApi:getCurrentTaskState()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    
            
end


function acGej2016Tab1:dispose()
    -- eventDispatcher:removeEventListener("activity.recharge",self.wsjdzzListener)
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.url=nil
    self.layerNum=nil
end
