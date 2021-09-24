acThanksGivingTab1 ={}
function acThanksGivingTab1:new()
        local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil

    return nc;

end
function acThanksGivingTab1:dispose( )
    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
end

function acThanksGivingTab1:init(layerNum)

    -- local function rewardCallBack(fn,data )
    --     local ret,sData = base:checkServerData(data)
    --     if ret==true then
    --         -- print("yes~~socketRefresh receive~~~")
    --         if sData.data and sData.data.globalServerData then
    --             if self.tv then
    --                 self.tv:reloadData()
    --             end
    --         end
    --     end
    -- end
    -- socketHelper:thanksGivingYou(rewardCallBack,"1")

    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    self:initTableView()
    return self.bgLayer
end

function acThanksGivingTab1:openInfo( )
    local td=smallDialog:new()
    local tabStr = nil 
    tabStr ={"\n",getlocal("activity_ganenjiehuikui_tip25"),"\n",getlocal("activity_ganenjiehuikui_tip24"),"\n",getlocal("activity_ganenjiehuikui_tip23"),"\n",getlocal("activity_ganenjiehuikui_tip22"),"\n",getlocal("activity_ganenjiehuikui_tip21"),"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,{nil,G_ColorRed,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
end
function acThanksGivingTab1:initTableView( )
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height-200),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    self.tv:setPosition(ccp(0,40))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)

end
function acThanksGivingTab1:eventHandler( handler,fn,idx,cel )
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    if G_getIphoneType() == G_iphoneX then
        return  CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-200)
    else
        return  CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-80)
    end
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    self:initUpMiddleDown(cell)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acThanksGivingTab1:initUpMiddleDown(cellLayer)
    local strSize2 = 22
    local strSize3 = 19
    local timePos = 70
    local strPosHeight2 = 10
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strSize3 =25
        timePos =0
        strPosHeight2 =0
    end
    local function clickDe(hd,fn,idx)
    end
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 200
    end
    local bgDia =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),clickDe)
    bgDia:setContentSize(CCSizeMake(G_VisibleSizeWidth - 42,G_VisibleSizeHeight-adaH))
    bgDia:ignoreAnchorPointForPosition(false)
    bgDia:setOpacity(0)
    bgDia:setAnchorPoint(ccp(0.5,0.5))
    bgDia:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5-80))
    cellLayer:addChild(bgDia)
    local ratioU = 0.2
    local bgDiaUp =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),clickDe)
    bgDiaUp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 42,bgDia:getContentSize().height*ratioU))
    bgDiaUp:ignoreAnchorPointForPosition(false)
    bgDiaUp:setOpacity(150)
    bgDiaUp:setAnchorPoint(ccp(0.5,1))
    bgDiaUp:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height))
    bgDia:addChild(bgDiaUp)
    local adaH = 0
    local ratioM = 0.15
    if G_getIphoneType() == G_iphoneX then
        ratioM = 0.12
        adaH = 40
    end
    local middleBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    middleBg:setContentSize(CCSizeMake(bgDia:getContentSize().width,bgDia:getContentSize().height*ratioM))
    middleBg:setAnchorPoint(ccp(0.5,1))
    middleBg:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDiaUp:getPositionY()-bgDiaUp:getContentSize().height-adaH))
    bgDia:addChild(middleBg) 

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),strSize2)
    acLabel:setAnchorPoint(ccp(0,1))
    acLabel:setPosition(ccp(70,bgDiaUp:getContentSize().height-25))
    acLabel:setColor(G_ColorYellowPro)
    bgDiaUp:addChild(acLabel)

    local acVo = acThanksGivingVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,strSize2)
    messageLabel:setAnchorPoint(ccp(0,1))
    messageLabel:setPosition(ccp(190+timePos, acLabel:getPositionY()))
    bgDiaUp:addChild(messageLabel)

    --"Icon_BG.png"
    local upIconBg = CCSprite:createWithSpriteFrameName("equipBg_orange.png")
    upIconBg:setPosition(ccp(bgDiaUp:getContentSize().width*0.18,bgDiaUp:getContentSize().height*0.4-10))
    upIconBg:setAnchorPoint(ccp(0.5,0.5))
    bgDiaUp:addChild(upIconBg)
    upIconBg:setScale(1.2)

    local upIcon = CCSprite:createWithSpriteFrameName("friendBtn.png")
    upIcon:setScale(upIconBg:getContentSize().width/upIcon:getContentSize().width)
    upIcon:setPosition(getCenterPoint(upIconBg))
    upIcon:setAnchorPoint(ccp(0.5,0.5))
    upIconBg:addChild(upIcon)

    local upStr = GetTTFLabelWrap(getlocal("activity_ganenjiehuikui_tap2_str"),strSize3,CCSizeMake(bgDiaUp:getContentSize().width*0.6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    upStr:setPosition(ccp(bgDiaUp:getContentSize().width*0.35,bgDiaUp:getContentSize().height*0.6+strPosHeight2))
    upStr:setAnchorPoint(ccp(0,1))
    bgDiaUp:addChild(upStr)


    local middleStr = GetTTFLabelWrap(getlocal("activity_ganenjiehuikui_tap2_str2"),strSize2,CCSizeMake(middleBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    middleStr:setPosition(ccp(10,middleBg:getContentSize().height-20))
    middleStr:setAnchorPoint(ccp(0,1))
    middleBg:addChild(middleStr)

    local function touch33(...)
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.75)
    local menuDesc=CCMenu:createWithItem(menItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-2)
    menuDesc:setPosition(ccp(bgDiaUp:getContentSize().width-5,acLabel:getPositionY()+10))
    bgDiaUp:addChild(menuDesc)

    --current_energy
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 25
    end
    local currEnergyNum = acThanksGivingVoApi:getCurrEnergy() -----
    local currentEnergyStr = GetTTFLabelWrap(getlocal("current_energy2",{currEnergyNum}),strSize2,CCSizeMake(middleBg:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    currentEnergyStr:setPosition(ccp(10,middleBg:getPositionY()-middleBg:getContentSize().height-15))
    currentEnergyStr:setAnchorPoint(ccp(0,1))
    bgDia:addChild(currentEnergyStr)
-----------------------------------------------------------------------------------------------------
    local collectTbGrade = acThanksGivingVoApi:getCollectEnergyTbNums()
    local changeHeight = currentEnergyStr:getPositionY()-30-adaH
    if G_getIphoneType() == G_iphoneX then
        changeHeight = changeHeight + 80
    end  
    local downAllSize = changeHeight-180
    local downSingleSize = math.floor(downAllSize/collectTbGrade)
    local needWidth = bgDia:getContentSize().width*0.65
    local needPosW = bgDia:getContentSize().width*0.5-30

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setAnchorPoint(ccp(0.5,0.5))
    lineSp2:setScale(0.9)
    if G_getIphoneType() == G_iphone4 then
        lineSp2:setScale(0.7)
    end
    lineSp2:setPosition(ccp(needWidth,180+downSingleSize*collectTbGrade*0.5-adaH*3))
    bgDia:addChild(lineSp2)--:setRotation(180)
    lineSp2:setRotation(90)

    local rewardNum = tonumber(acThanksGivingVoApi:getNeedIdxInAwardSS())
    local bigBg ="public/checkBigPic.jpg"
    local checkBgWidht = needWidth
    local checkBgHeight = downAllSize
    local checkPosH = changeHeight
    if G_getIphoneType() == G_iphoneX then
        checkPosH = checkPosH - 80
    end
    local checkBg =  CCSprite:create(bigBg)--needWidth --downAllSize
    checkBg:setAnchorPoint(ccp(0.5,1))
    checkBg:setScaleX(checkBgWidht/checkBg:getContentSize().width)
    checkBg:setScaleY(checkBgHeight/checkBg:getContentSize().height)
    checkBg:setPosition(ccp(bgDia:getContentSize().width*0.35,checkPosH))
    bgDia:addChild(checkBg)
---------俩按钮⬇️

    local function btnClick( tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if tag ==31 then
                activityAndNoteDialog:closeAllDialog()
                worldScene:setShow()
            elseif tag ==32 then
                self:getReward()
            end
        end
    end 
    local adaH = 0
    local scale = 1
    if G_getIphoneType() == G_iphoneX then
        adaH = 110
        scale = 0.9
    end
    local goCollectBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",btnClick,31,getlocal("alien_tech_go_collection"),25)
    goCollectBtn:setAnchorPoint(ccp(0.5,0.5))
    goCollectBtn:setScale(scale)
    local goCollectMenu=CCMenu:createWithItem(goCollectBtn)
    goCollectMenu:setPosition(ccp(bgDia:getContentSize().width*0.5,130-adaH))
    goCollectMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    bgDia:addChild(goCollectMenu)  

    local recBtn =GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",btnClick,32,getlocal("daily_scene_get"),25);
    recBtn:setAnchorPoint(ccp(0.5,0.5))
    recBtn:setScale(scale)
    local recMenu=CCMenu:createWithItem(recBtn)
    recMenu:setPosition(ccp(bgDia:getContentSize().width*0.5,130-adaH))
    recMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    bgDia:addChild(recMenu)  
    recBtn:setVisible(false)

    --activity_ganenjiehuikui_endActivity
    local endActivity = GetTTFLabelWrap(getlocal("activity_ganenjiehuikui_endActivity"),strSize2+2,CCSizeMake(needWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    endActivity:setPosition(ccp(bgDia:getContentSize().width*0.5,130))
    endActivity:setAnchorPoint(ccp(0.5,0.5))
    endActivity:setColor(G_ColorYellowPro)
    bgDia:addChild(endActivity)
    endActivity:setVisible(false)

    

---------俩按钮⬆️
    local function nilFunc()
    end
    for i=1,collectTbGrade do
        local needPosH = downSingleSize*(i-1)+180
        if G_getIphoneType() == G_iphoneX then
            needPosH = needPosH - 80
        end
        local awardTb,collectEnergyNum = acThanksGivingVoApi:getSingleDataOfEnergy(i)
        local cellWidthNums = SizeOfTable(awardTb)
        local picSingleWidth = needWidth*0.7/cellWidthNums+5
        local addPos = 0
        if i ==3 then
            addPos = picSingleWidth*0.2
        elseif i ==2 then
            addPos=picSingleWidth*0.2
        end

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        lineSp:setScale(0.9)
        lineSp:setPosition(ccp(needPosW,needPosH))
        bgDia:addChild(lineSp)

        -- local greenBgPic =nil
        -- if G_getCurChoseLanguage() =="ar" then
        --     greenBgPic = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),nilFunc)
        --     greenBgPic:setContentSize(CCSizeMake(needWidth,downSingleSize))
        --     greenBgPic:setAnchorPoint(ccp(0,0))
        --     greenBgPic:setOpacity(220)
        --     greenBgPic:setPosition(ccp(0,needPosH))
        --     bgDia:addChild(greenBgPic,1)
        -- end

        local maskblack = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20, 20, 10, 10),nilFunc)
        maskblack:setContentSize(CCSizeMake(needWidth,downSingleSize))
        maskblack:setAnchorPoint(ccp(0,0))
        maskblack:setOpacity(180)
        maskblack:setPosition(ccp(0,needPosH))
        bgDia:addChild(maskblack,1)

        local checkBorder = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),nilFunc)
        checkBorder:setContentSize(CCSizeMake(needWidth,downSingleSize))
        checkBorder:setAnchorPoint(ccp(0,0))
        checkBorder:setPosition(ccp(0,needPosH))
        bgDia:addChild(checkBorder,1)
        -- checkBorder:setVisible(false)
        checkBorder:setVisible(false)

        local needEnergyNum = collectEnergyNum
        if collectEnergyNum >1000 then
            needEnergyNum =FormatNumber(collectEnergyNum)
        end
        local needEnergyStr = GetTTFLabelWrap(getlocal("energy2",{needEnergyNum}),strSize2,CCSizeMake(needWidth*0.25-5,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        needEnergyStr:setPosition(ccp(needWidth*0.85,needPosH+downSingleSize*0.5))
        needEnergyStr:setAnchorPoint(ccp(0.5,0.5))
        bgDia:addChild(needEnergyStr,1)

        local awardTipStr = "activity_dayRecharge_no" ----------
        local energyTipStr = GetTTFLabelWrap(getlocal(awardTipStr),strSize2-2,CCSizeMake(bgDia:getContentSize().width*0.2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        energyTipStr:setPosition(ccp(bgDia:getContentSize().width*0.75,needPosH+downSingleSize*0.5))
        energyTipStr:setAnchorPoint(ccp(0.5,0.5))
        energyTipStr:setColor(G_ColorGreen)
        bgDia:addChild(energyTipStr)
        
        rewardedIcon = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
        rewardedIcon:setPosition(ccp(bgDia:getContentSize().width*0.75,needPosH+downSingleSize*0.5))
        rewardedIcon:setAnchorPoint(ccp(0.5,0.5))
        bgDia:addChild(rewardedIcon)
        rewardedIcon:setVisible(false)
        -- print("rewardNum------i------>",rewardNum,i,currEnergyNum,collectEnergyNum)
        if tonumber(currEnergyNum) >= tonumber(collectEnergyNum) then
            energyTipStr:setString(getlocal("canReward"))
            energyTipStr:setColor(G_ColorYellowPro)
            maskblack:setVisible(false)
            checkBorder:setVisible(true)
            recBtn:setVisible(true)
            goCollectBtn:setVisible(false)
            if rewardNum >=i then
                rewardedIcon:setVisible(true)
                energyTipStr:setVisible(false)
                recBtn:setVisible(false)
                goCollectBtn:setVisible(true)
            end
        end

        for j=1,SizeOfTable(awardTb) do
            if j==2 and i ==2 then
                addPos =0
            elseif (j==3 and i==2) or (j ==2 and i ==3) then
                addPos =-(picSingleWidth*0.22)
            end
            local pic = G_getItemIcon(awardTb[j],80,true,self.layerNum,nil,self.tv,nil)
            local iconNum = awardTb[j].num
            local iconPicShow = pic
            iconPicShow:setScale(0.7)
            iconPicShow:setTouchPriority(-(self.layerNum-1)*20-2)
            iconPicShow:setPosition(ccp(picSingleWidth*(j-1)+picSingleWidth*0.5+addPos+5,needPosH+downSingleSize*0.5))
            iconPicShow:setAnchorPoint(ccp(0.5,0.5))
            bgDia:addChild(iconPicShow,1)

            local iconLabel = GetTTFLabel("x"..iconNum,25)
            iconLabel:setAnchorPoint(ccp(1,0))
            iconLabel:setPosition(ccp(iconPicShow:getContentSize().width-4,4))
            iconPicShow:addChild(iconLabel,2)
        end
        
        -- timerSpriteLv:setVisible(false)

    end

    if rewardNum ==collectTbGrade then
            recBtn:setVisible(false)
            goCollectBtn:setVisible(false)
            endActivity:setVisible(true)
    end 

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setScale(0.9)
    if G_getIphoneType() == G_iphoneX then
        lineSp:setPosition(ccp(bgDia:getContentSize().width*0.5-30,downSingleSize*collectTbGrade+100))
    else
        lineSp:setPosition(ccp(bgDia:getContentSize().width*0.5-30,downSingleSize*collectTbGrade+180))
    end
    bgDia:addChild(lineSp)

    local barWidth = downAllSize
    local function click(hd,fn,idx)
    end
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 80
    end

    local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
    barSprie:setContentSize(CCSizeMake(barWidth, 50))
    barSprie:setRotation(90)
    barSprie:setPosition(ccp(bgDia:getContentSize().width*0.92,downSingleSize*collectTbGrade*0.5+180 - adaH))
    bgDia:addChild(barSprie,1)

    
    AddProgramTimer(bgDia,ccp(bgDia:getContentSize().width*0.92,downSingleSize*collectTbGrade*0.5+180 - adaH),11,12,nil,"AllBarBg.png","AllXpBar.png",133,1,1)
    local per = acThanksGivingVoApi:getPercentage()
    local timerSpriteLv = bgDia:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    timerSpriteLv:setRotation(-90)
    timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
    local bgg = bgDia:getChildByTag(133)
    bgg:setVisible(false)

           
end

function acThanksGivingTab1:getReward()
    local openLv=20
    if playerVoApi:getPlayerLevel() >=openLv then
        local currEnergyNum = acThanksGivingVoApi:getCurrEnergy()
        local recAwardTb = acThanksGivingVoApi:getRecAwardTbq( )
        local collectTbGrade = acThanksGivingVoApi:getCollectEnergyTbNums()
        local tid = nil
        local idx  = nil
        for i=1,collectTbGrade do
            local awardTb,collectEnergyNum = acThanksGivingVoApi:getSingleDataOfEnergy(i)
            if recAwardTb ==nil then
                tid ="s"..1
                idx =1
            elseif recAwardTb["s"..i]==nil and tonumber(currEnergyNum) >=tonumber(collectEnergyNum) and tid == nil then
                tid ="s"..i
                idx =i
            end
        end
        if tid then
            local function rewardCallBack(fn,data )
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData.data.ganenjiehuikui and sData.data.ganenjiehuikui.f then
                        acThanksGivingVoApi:setRecAwardTbq(sData.data.ganenjiehuikui.f3)
                        -- print("yes~~allServer receive~~~")
                        local awardTb,collectEnergyNum = acThanksGivingVoApi:getSingleDataOfEnergy(idx)
                        accessoryVoApi.dataNeedRefresh=true
                        if(sData.data.weapon and superWeaponVoApi)then
                            superWeaponVoApi:formatData(sData.data.weapon)
                        end
                        G_showRewardTip(awardTb)
                        local recordPoint = self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)
                    end
                end
            end
            socketHelper:thanksGivingYou(rewardCallBack,"3",tid,nil)
        end
    else
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_ganenjiehuikui_level",{openLv}),30)
    end
end
function acThanksGivingTab1:socketRefresh( )
    local function rewardCallBack(fn,data )
        local ret,sData = base:checkServerData(data)
        if ret==true then
            -- print("yes~~socketRefresh receive~~~")
            if sData.data and sData.data.globalServerData then
                acThanksGivingVoApi:setCurrTime( sData.ts)
                acThanksGivingVoApi:setCurrEnergy(sData.data.globalServerData )
                acThanksGivingVoApi:setCurrType( false)
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
    socketHelper:thanksGivingYou(rewardCallBack,"1",nil,nil)
end
function acThanksGivingTab1:tick( )
    
    if acThanksGivingVoApi:isRefresh() ==true then
        acThanksGivingVoApi:setRefresh(false)
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    if acThanksGivingVoApi:isRefreshAllServerData( )  ==true then
        self:socketRefresh()
    end
end





--===========================================================
