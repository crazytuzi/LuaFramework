acLoversDayTab1={}

function acLoversDayTab1:new()
    local nc={}
    self.bgLayer=nil
    self.isEnd=false
    self.topH = G_VisibleSizeHeight - 230
    self.backSprie=nil
    self.isToday = nil
    self.wholeTouchBgSp = nil
    self.matePointShowTb={{},{},{},{}}
    self.matePointPosTb={}
    self.tvPosTb= {}
    self.wholePicTb = {{},{},{},{},{},{}}
    self.lightBgTb= {}
    self.nextShow ={}
    self.fuWei = {}
    self.yiWei = {}
    self.state = 0
    self.isClickStop = false
    self.isbeginEnd = {false,false}
    self.speedTb = {20,10}
    self.showIdx =0
    self.loopNum =0
    setmetatable(nc, self)
    self.__index=self
    self.isFinished = true
    return nc
end 

function acLoversDayTab1:dispose()
    self.topH = nil
    self.backSprie=nil
    self.bgLayer =nil
    self.wholeTouchBgSp = nil
    self.matePointShowTb = nil
    self.matePointPosTb = nil
    self.tvPosTb= nil
    self.wholePicTb = nil
    self.fuWei = nil
    self.state = nil
    self.isClickStop = false
    self.nextShow = nil
    self.isFinished =nil
    self.showIdx =nil
end

function acLoversDayTab1:init(layerNum,parent)
    local subHeight = 240
    if G_isIphone5() then
        subHeight = 320
    end
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.isToday = acLoversDayVoApi:isToday()
    local function click(hd,fn,idx)
    end
    local bigBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width)
    bigBg:setScaleY((G_VisibleSizeHeight-subHeight-40)/bigBg:getContentSize().height)
    bigBg:ignoreAnchorPointForPosition(false)
    bigBg:setOpacity(150)
    bigBg:setAnchorPoint(ccp(0.5,1))
    bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-subHeight))
    self.bgLayer:addChild(bigBg)

    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(60,24,8,2),click)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-subHeight))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setOpacity(0)
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-subHeight)) 
    self.bgLayer:addChild(backSprie)   
    self.backSprie = backSprie
    
    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    goldLineSprite1:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height))
    self.backSprie:addChild(goldLineSprite1,1)

    local backSpWidth  = backSprie:getContentSize().width
    local backSpHeight = backSprie:getContentSize().height 
    local widScale = {0.34,0.66}--左右两栏
    local adormNW = {-32,32}--每一栏左右两根链子
    local chainStartPosY = backSprie:getContentSize().height
    local addPosY = G_isIphone5() == true and 0 or 20
    
    local adormPosXScale = {0.2,0.55,0.8,0.9,0.33,0.85}
    local adormPosYScale = {0.7,0.75,0.85,0.55,0.42,0.2}
    local adormStr = {"heart_3.png","heart_2.png","heart_4.png","heart_3.png","heart_4.png","heart_2.png"}
    local isVerFlip = {nil,nil,nil,true,nil,true}
    for i=1,6 do
        local adorPic = CCSprite:createWithSpriteFrameName(adormStr[i])
        adorPic:setAnchorPoint(ccp(0.5,0.5))
        adorPic:setPosition(ccp(backSpWidth*adormPosXScale[i],backSpHeight*adormPosYScale[i]))
        if isVerFlip[i] then adorPic:setFlipY(true) end
        if i == 4 then adorPic:setFlipX(true) end
        backSprie:addChild(adorPic)
    end
    local lightNum = 1
    for j=1,2 do--左右两栏
        for i=1,3 do
            for ii=1,2 do--每一栏左右两根链子
                local chainPic = CCSprite:createWithSpriteFrameName("smallChain.png")
                chainPic:setAnchorPoint(ccp(0.5,1))
                chainPic:setPosition(ccp(backSpWidth*widScale[j]+adormNW[ii],chainStartPosY-(i-1)*148+addPosY*(i-1)))
                backSprie:addChild(chainPic)
            end    

            local frBg = CCSprite:createWithSpriteFrameName("greenFrameBg.png")--抽奖背景框
            frBg:setAnchorPoint(ccp(0.5,0))
            frBg:setPosition(ccp(backSpWidth*widScale[j],chainStartPosY-i*150+addPosY*(i-1)))
            backSprie:addChild(frBg,1)    

            local iconOrederBg = CCSprite:createWithSpriteFrameName("BgEmptyTank.png")
            iconOrederBg:setAnchorPoint(ccp(0.5,0.5))
            iconOrederBg:setPosition(frBg:getContentSize().width*0.5,frBg:getContentSize().height*0.5+4)
            iconOrederBg:setScaleY(0.65)
            iconOrederBg:setScaleX(0.67)
            frBg:addChild(iconOrederBg)


            local frBg2 = CCSprite:createWithSpriteFrameName("greenFrameBg.png")--抽奖背景框
            frBg2:setAnchorPoint(ccp(0.5,0))
            frBg2:setOpacity(0)
            frBg2:setPosition(ccp(backSpWidth*widScale[j]+3,chainStartPosY-i*150+addPosY*(i-1)+5))
            backSprie:addChild(frBg2,4)  
            self.lightBgTb[lightNum] = frBg2

            -- local light = CCSprite:createWithSpriteFrameName("openLight.png")
            -- light:setAnchorPoint(ccp(0.5,0))
            -- light:setPosition(ccp(backSpWidth*widScale[j],chainStartPosY-i*150+addPosY*(i-1)))
            -- backSprie:addChild(light,3)
            -- light:setVisible(false)
            -- self.lightBgTb[lightNum] = light
            lightNum = lightNum + 1

            if j == 1 then--3个tv的坐标点
                self.tvPosTb[i] = ccp(backSpWidth*widScale[j]-frBg:getContentSize().width*0.5+5,chainStartPosY-i*150+addPosY*(i-1)+15)
            end
        end
    end
    self.needTbViewWidth = self.backSprie:getContentSize().width*0.32+55*2
    self:initTableView_1()
    self:initTableView_2()
    self:initTableView_3()

    self:initLayer()
    return self.bgLayer
end

function acLoversDayTab1:initTableView_3()

    local function callBack(...) return self:eventHandler3(...) end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv3=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.needTbViewWidth,100),nil)
    self.backSprie:addChild(self.tv3,2)
    self.tv3:setPosition(self.tvPosTb[3])--0.535  (1-0.61)
    self.tv3:setAnchorPoint(ccp(0,0))
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv3:setMaxDisToBottomOrTop(0)
end
function acLoversDayTab1:eventHandler3(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView"  then return  1
   elseif fn=="tableCellSizeForIndex" then return  CCSizeMake(self.needTbViewWidth,100)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
        if self.cellBgSp3 ==nil then
            local function touch( ) end
            self.cellBgSp3=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
            self.cellBgSp3:setContentSize(CCSizeMake(self.needTbViewWidth,100))
            self.cellBgSp3:setAnchorPoint(ccp(0,0))
            self.cellBgSp3:setOpacity(0)
            self.cellBgSp3:setPosition(ccp(0,0))
            cell:addChild(self.cellBgSp3)

            local picTb = acLoversDayVoApi:getAwardPic()
            local fuWei = nil
            for i=1,#picTb do--self.wholePicTb
                local pic = CCSprite:createWithSpriteFrameName(picTb[i].pic)
                pic:setAnchorPoint(ccp(0.5,0))
                pic:setScale(100/pic:getContentSize().width)
                fuWei = ccp(53,100)
                pic:setPosition(fuWei)
                self.cellBgSp3:addChild(pic)

                self.wholePicTb[3][i] = pic
                if i == 1 then
                    self.fuWei[3] = fuWei
                    self.nextShow[3] = 0
                end
            end
            for i=1,#picTb do
                local pic = CCSprite:createWithSpriteFrameName(picTb[i].pic)
                pic:setAnchorPoint(ccp(0.5,0))
                pic:setScale(100/pic:getContentSize().width)
                fuWei = ccp(self.cellBgSp3:getContentSize().width -57,100)
                pic:setPosition(fuWei)
                self.cellBgSp3:addChild(pic)

                self.wholePicTb[6][i] = pic
                if i == 1 then
                    self.fuWei[6] = fuWei
                    self.nextShow[6] = 0
                end
            end
        end


       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then self.isMoved=false return true
   elseif fn=="ccTouchMoved" then self.isMoved=true
   elseif fn=="ccTouchEnded" then
   end
end

function acLoversDayTab1:initTableView_2()

    local function callBack(...) return self:eventHandler2(...) end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.needTbViewWidth,100),nil)
    self.backSprie:addChild(self.tv2,2)
    self.tv2:setPosition(self.tvPosTb[2])--0.535  (1-0.61)
    self.tv2:setAnchorPoint(ccp(0,0))
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setMaxDisToBottomOrTop(0)
end
function acLoversDayTab1:eventHandler2(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView"  then return  1
   elseif fn=="tableCellSizeForIndex" then return  CCSizeMake(self.needTbViewWidth,100)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
        if self.cellBgSp2 ==nil then
            local function touch( ) end
            self.cellBgSp2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
            self.cellBgSp2:setContentSize(CCSizeMake(self.needTbViewWidth,100))
            self.cellBgSp2:setAnchorPoint(ccp(0,0))
            self.cellBgSp2:setOpacity(0)
            self.cellBgSp2:setPosition(ccp(0,0))
            cell:addChild(self.cellBgSp2)

            local picTb = acLoversDayVoApi:getAwardPic()
            local fuWei = nil
            for i=1,#picTb do--self.wholePicTb
                local pic = CCSprite:createWithSpriteFrameName(picTb[i].pic)
                pic:setAnchorPoint(ccp(0.5,0))
                pic:setScale(100/pic:getContentSize().width)
                fuWei = ccp(53,100)
                pic:setPosition(fuWei)
                self.cellBgSp2:addChild(pic)

                self.wholePicTb[2][i] = pic
                if i == 1 then
                    self.fuWei[2] = fuWei
                    self.nextShow[2] = 0
                end
            end
            for i=1,#picTb do
                local pic = CCSprite:createWithSpriteFrameName(picTb[i].pic)
                pic:setAnchorPoint(ccp(0.5,0))
                pic:setScale(100/pic:getContentSize().width)
                fuWei = ccp(self.cellBgSp2:getContentSize().width -57,100)
                pic:setPosition(fuWei)
                self.cellBgSp2:addChild(pic)

                self.wholePicTb[5][i] = pic
                if i == 1 then
                    self.fuWei[5] = fuWei
                    self.nextShow[5] = 0
                end
            end
        end


       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then self.isMoved=false return true
   elseif fn=="ccTouchMoved" then self.isMoved=true
   elseif fn=="ccTouchEnded" then
   end
end

function acLoversDayTab1:initTableView_1()

    local function callBack(...) return self:eventHandler(...) end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.needTbViewWidth,100),nil)
    self.backSprie:addChild(self.tv,2)
    self.tv:setPosition(self.tvPosTb[1])--0.535  (1-0.61)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(0)
end
function acLoversDayTab1:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView"  then return  1
   elseif fn=="tableCellSizeForIndex" then return  CCSizeMake(self.needTbViewWidth,100)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
        if self.cellBgSp1 ==nil then
            local function touch( ) end
            self.cellBgSp1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
            self.cellBgSp1:setContentSize(CCSizeMake(self.needTbViewWidth,100))
            self.cellBgSp1:setAnchorPoint(ccp(0,0))
            self.cellBgSp1:setOpacity(0)
            self.cellBgSp1:setPosition(ccp(0,0))
            cell:addChild(self.cellBgSp1)

            local picTb = acLoversDayVoApi:getAwardPic()
            local fuWei = nil
            for i=1,#picTb do--self.wholePicTb
                local pic = CCSprite:createWithSpriteFrameName(picTb[i].pic)
                pic:setAnchorPoint(ccp(0.5,0))
                pic:setScale(100/pic:getContentSize().width)
                fuWei = ccp(53,100)
                pic:setPosition(fuWei)
                self.cellBgSp1:addChild(pic)

                self.wholePicTb[1][i] = pic
                if i == 1 then
                    self.fuWei[1] = fuWei
                    self.nextShow[1] = 0
                end
            end
            for i=1,#picTb do
                local pic = CCSprite:createWithSpriteFrameName(picTb[i].pic)
                pic:setAnchorPoint(ccp(0.5,0))
                pic:setScale(100/pic:getContentSize().width)
                fuWei = ccp(self.cellBgSp1:getContentSize().width -57,100)
                pic:setPosition(fuWei)
                self.cellBgSp1:addChild(pic)

                self.wholePicTb[4][i] = pic
                if i == 1 then
                    self.fuWei[4] = fuWei
                    self.nextShow[4] = 0
                end
            end
        end


       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then self.isMoved=false return true
   elseif fn=="ccTouchMoved" then self.isMoved=true
   elseif fn=="ccTouchEnded" then
   end
end


function acLoversDayTab1:initLayer( )

    local needBgAddHeight =150
    if G_isIphone5() then
        needBgAddHeight =300
    end
    local function nodata( ) end
    local function touch2( ) 
        -- print("wholeTouchBgSp~~~~~~~~") 
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        self:clickFinishAnimation( )
    end 
    self.wholeTouchBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch2)--拉霸动画背景
    self.wholeTouchBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth+40,G_VisibleSizeHeight+needBgAddHeight))
    self.wholeTouchBgSp:setTouchPriority(-(self.layerNum-1)*20-20)
    self.wholeTouchBgSp:setIsSallow(true)
    self.wholeTouchBgSp:setAnchorPoint(ccp(0.5,0))
    self.wholeTouchBgSp:setOpacity(0)
    self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5500))
    self.bgLayer:addChild(self.wholeTouchBgSp,30)
    self.wholeTouchBgSp:setVisible(false)

    local PosY2 = 20
    local function rewardShowHandler()
        if G_checkClickEnable()==false then do return end else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:rewardShowH()
    end
    local rewardShowBtn=GetButtonItem("CommonBox.png","CommonBox.png","CommonBox.png",rewardShowHandler,11,nil,nil)
    rewardShowBtn:setScale(0.55)
    rewardShowBtn:setAnchorPoint(ccp(0,1))
    local rewardShowMenu=CCMenu:createWithItem(rewardShowBtn)
    rewardShowMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardShowMenu:setPosition(ccp(20,self.backSprie:getContentSize().height-PosY2-20))
    self.backSprie:addChild(rewardShowMenu)
    local rewardShowBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    rewardShowBg:setAnchorPoint(ccp(0.5,1))
    rewardShowBg:setContentSize(CCSizeMake(100,40))
    rewardShowBg:setPosition(ccp(rewardShowBtn:getContentSize().width/2,-5))
    rewardShowBg:setScale(1/0.8)
    rewardShowBtn:addChild(rewardShowBg)

    local reardLbFontSize=33
    if  G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="fr" then
        reardLbFontSize = 22
    end

    local rewardShowLb=GetTTFLabelWrap(getlocal("award"),reardLbFontSize,CCSize(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rewardShowLb:setPosition(rewardShowBg:getContentSize().width/2,rewardShowBg:getContentSize().height/2)
    rewardShowLb:setColor(G_ColorYellowPro)
    rewardShowBg:addChild(rewardShowLb)

    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then do return end else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:recordHandler()
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.8)
    recordBtn:setAnchorPoint(ccp(1,1))
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(self.backSprie:getContentSize().width-10,self.backSprie:getContentSize().height-PosY2-10))
    self.backSprie:addChild(recordMenu)
    local recordBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    recordBg:setAnchorPoint(ccp(0.5,1))
    recordBg:setContentSize(CCSizeMake(100,40))
    recordBg:setPosition(ccp(recordBtn:getContentSize().width/2,0))
    recordBg:setScale(1/0.8)
    recordBtn:addChild(recordBg)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setPosition(recordBg:getContentSize().width/2,recordBg:getContentSize().height/2)
    recordLb:setColor(G_ColorYellowPro)
    recordBg:addChild(recordLb)

    local oneCost,tenCost = acLoversDayVoApi:getCostWithOneAndTenTimes( )
    local function btnClick(tag,object)
        if G_checkClickEnable()==false then do return end else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local needGems = nil
        local haveCost = playerVoApi:getGems()
        if tag == 1 then else
            needGems = tag >2 and tenCost or oneCost
        end
        if needGems and tonumber(needGems) > haveCost then
            self:needMoneyDia(needGems,haveCost,self.wholeTouchBgSp)--出板子 让玩家充值
            do return end
        end
        local function callback( )
            
            self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,0))
            self:startPalyAnimation() -- 开始！！！
        end 
        acLoversDayVoApi:loversDayRequest("active.wuduyouou.rand",{tag,needGems},callback)
    end
    local addPosY2 = G_isIphone5() == true and 40 or 30
    self.freeBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnClick,1,getlocal("daily_lotto_tip_2"),25)
    self.freeBtn:setAnchorPoint(ccp(0.5,0.5))
    self.freeBtnMenu=CCMenu:createWithItem(self.freeBtn)
    self.freeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width*0.27,self.freeBtn:getContentSize().height*0.5+addPosY2))
    self.freeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.freeBtnMenu,2)  
--------
    self.talkBtn1 =GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnClick,2,getlocal("activity_loversDay_mate"),25)
    self.talkBtn1:setAnchorPoint(ccp(0.5,0.5))
    self.talkBtn1Menu=CCMenu:createWithItem(self.talkBtn1)
    self.talkBtn1Menu:setPosition(ccp(self.bgLayer:getContentSize().width*0.27,self.talkBtn1:getContentSize().height*0.5+addPosY2))
    self.talkBtn1Menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.talkBtn1Menu)  

    self.oneCostStr = GetTTFLabel(oneCost,25)
    self.oneCostStr:setAnchorPoint(ccp(1,0))
    self.talkBtn1:addChild(self.oneCostStr)
    self.oneCostStr:setColor(G_ColorYellowPro)

    self.gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.gemIcon1:setAnchorPoint(ccp(0,0))
    self.talkBtn1:addChild(self.gemIcon1,1)

    local tenCount = "10"..getlocal("activity_refitPlanT99_bigRewardRateAdd").." "..getlocal("activity_loversDay_mate")
    if G_getCurChoseLanguage() =="ru" then
        tenCount = getlocal("activity_loversDay_mate").." 10"..getlocal("activity_refitPlanT99_bigRewardRateAdd")
    end
    self.talkBtn2 =GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnClick,3,tenCount,25);
    self.talkBtn2:setAnchorPoint(ccp(0.5,0.5))
    self.talkBtn2Menu=CCMenu:createWithItem(self.talkBtn2)
    self.talkBtn2Menu:setPosition(ccp(self.bgLayer:getContentSize().width*0.73,self.talkBtn2:getContentSize().height*0.5+addPosY2))
    self.talkBtn2Menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.talkBtn2Menu)

    self.tenCostStr = GetTTFLabel(tenCost,25)
    self.tenCostStr:setAnchorPoint(ccp(1,0))
    self.talkBtn2:addChild(self.tenCostStr)
    self.tenCostStr:setColor(G_ColorYellowPro)

    self.gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.gemIcon2:setAnchorPoint(ccp(0,0))
    self.talkBtn2:addChild(self.gemIcon2,1)

    self:refreshVisible2()

    --"NoticeLine.png"
    local noticeBg =LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png",CCRect(15,15,1,1),nodata)
    noticeBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width*0.85, self.bgLayer:getContentSize().height*0.18))
    noticeBg:ignoreAnchorPointForPosition(false)
    noticeBg:setAnchorPoint(ccp(0.5,0))
    noticeBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5, self.talkBtn2Menu:getPositionY()+self.talkBtn1:getContentSize().height))
    self.noticeBg = noticeBg
    self.bgLayer:addChild(noticeBg,1)
    local ntWidth  = noticeBg:getContentSize().width
    local ntHeight = noticeBg:getContentSize().height

    local noticeBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    noticeBg2:setContentSize(CCSizeMake(ntWidth-4,ntHeight-4))
    noticeBg2:setAnchorPoint(ccp(0.5,0.5))
    noticeBg2:setPosition(getCenterPoint(noticeBg))
    noticeBg2:setOpacity(120)
    noticeBg:addChild(noticeBg2)

    local adorPic = CCSprite:createWithSpriteFrameName("heart_1.png")
    adorPic:setAnchorPoint(ccp(0,0))
    adorPic:setPosition(ccp(-20,-10))
    noticeBg:addChild(adorPic)

    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    titleBg:setPosition(ccp(noticeBg:getContentSize().width/2,noticeBg:getContentSize().height-2));
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setOpacity(150)
    titleBg:setScaleY(40/titleBg:getContentSize().height)
    titleBg:setScaleX((ntWidth-20)/titleBg:getContentSize().width)
    noticeBg:addChild(titleBg)
    local ntStartPosY = noticeBg:getContentSize().height - titleBg:getContentSize().height*(40/titleBg:getContentSize().height)-5
    --activity_loversDay_mateResult
    local noticeTitle = GetTTFLabelWrap(getlocal("activity_loversDay_mateResult"),25,CCSizeMake(ntWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noticeTitle:setColor(G_ColorYellowPro)
    noticeTitle:setAnchorPoint(ccp(0.5,0.5))
    noticeTitle:setPosition(ccp(ntWidth*0.5,ntHeight-25))
    noticeBg:addChild(noticeTitle)

    local mateCfg = acLoversDayVoApi:getScoreCfg()
    local useHeight = G_isIphone5() ==true and 35 or 30
    for i=1,4 do
        local pointBg = LuaCCScale9Sprite:createWithSpriteFrameName("yellowSmallBorder.png",CCRect(10, 10, 1, 1),function ()end)
        pointBg:setAnchorPoint(ccp(0.5,1))
        self.matePointPosTb[i] = ccp(ntWidth*0.5,ntStartPosY - useHeight*(i-1))
        pointBg:setPosition(self.matePointPosTb[i].x,self.matePointPosTb[i].y)
        pointBg:setOpacity(0)
        noticeBg:addChild(pointBg)
        self.matePointShowTb[i]["bg"] = pointBg
        
        local matePointStr = GetTTFLabel(getlocal("activity_loversDay_mateNumDes",{i-1,mateCfg[i]}),22)
        matePointStr:setAnchorPoint(ccp(0,0.5))
        pointBg:addChild(matePointStr)
        self.matePointShowTb[i]["str"] = matePointStr

        local matePic = CCSprite:createWithSpriteFrameName("txjIcon.png")
        matePic:setAnchorPoint(ccp(0,0.5))
        matePic:setScale(0.4)
        pointBg:addChild(matePic)

        pointBg:setContentSize(CCSizeMake(matePointStr:getContentSize().width+matePic:getContentSize().width*0.4+10,useHeight))
        matePointStr:setPosition(ccp(5,pointBg:getContentSize().height*0.5))
        matePic:setPosition(ccp(matePointStr:getContentSize().width+5,pointBg:getContentSize().height*0.5))
    end

end

function acLoversDayTab1:needMoneyDia(cost,playerGems,wholeTouchBgSp)
    local function buyGems()
          if G_checkClickEnable()==false then do return end end
          activityAndNoteDialog:closeAllDialog()
          vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local function cancleCallBack( )
        if wholeTouchBgSp then
            wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
        end
    end 
    local num=tonumber(cost)-playerGems
    local smallD=smallDialog:new()
    smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(cost),playerGems,num}),nil,self.layerNum+1,nil,nil,cancleCallBack)
end

function acLoversDayTab1:refreshVisible2()

    local goldNum1,goldNum2=acLoversDayVoApi:getCostWithOneAndTenTimes()
    local haveCost = playerVoApi:getGems()

    if acLoversDayVoApi:canReward()==true then
        self.freeBtn:setVisible(true)
        self.talkBtn1:setEnabled(false)
        self.talkBtn2:setEnabled(false)
        self.oneCostStr:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5-5,self.talkBtn1:getContentSize().height*0.5-250))
        self.gemIcon1:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5-250))
        self.tenCostStr:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5-5,self.talkBtn2:getContentSize().height*0.5-250))
        self.gemIcon2:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5-250))
    else
        self.freeBtn:setVisible(false)
        self.talkBtn1:setEnabled(true)
        self.talkBtn2:setEnabled(true)
        self.oneCostStr:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5+35))
        self.gemIcon1:setPosition(ccp(self.talkBtn1:getContentSize().width*0.5+5,self.talkBtn1:getContentSize().height*0.5+35))
        self.tenCostStr:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5+35))
        self.gemIcon2:setPosition(ccp(self.talkBtn2:getContentSize().width*0.5+5,self.talkBtn2:getContentSize().height*0.5+35))

        if haveCost<goldNum1 then
            self.oneCostStr:setColor(G_ColorRed)
        else
            self.oneCostStr:setColor(G_ColorYellowPro)
        end
        if haveCost<goldNum2 then
            self.tenCostStr:setColor(G_ColorRed)
        else
            self.tenCostStr:setColor(G_ColorYellowPro)
        end
    end

    -- self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5-12,G_VisibleSizeHeight+5000))
end

function acLoversDayTab1:rewardShowH( )
    require "luascript/script/game/scene/gamedialog/activityAndNote/acLoversDaySmallDialog"
    acLoversDaySmallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(500,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("award"),getlocal("activity_loversDay_smallDialogDes"),true,100,nil,acLoversDayVoApi:getAwardList( ),4,1,0.6)
end

function acLoversDayTab1:recordHandler()
    local function callback()
        local function showNoRecord()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        end
        local recordList=acLoversDayVoApi:getRecordList()   
        local recordCount=SizeOfTable(recordList)
        if recordCount==0 then
            showNoRecord()
            do return end
        end
        local recordNum=10
        local function confirmHandler()
        end

        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
        acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorYellowPro},recordList,false,self.layerNum+1,confirmHandler,true,recordNum,false)
    end
    local flag=acLoversDayVoApi:getRequestLogFlag()
    -- print("flag---------->",flag)
    if flag==false then
        
        acLoversDayVoApi:loversDayRequest("active.wuduyouou.getlog",nil,callback)
    else
        callback()
    end
end

function acLoversDayTab1:finishPalyAnimation(isClick)
    self.isClickStop =false
    self.wholeTouchBgSp:setVisible(true)
    local curPoint,curIndex,fmtPoint = acLoversDayVoApi:getCurAwardPoint( )
    -- print("isClick--------curIndex------>",isClick,curIndex)
    if isClick == nil then
        self:showPoint(curPoint,curIndex,isClick,fmtPoint)
    else
        self:getAllAwardToShowWithDialog()
    end
    -- self:cleanData( )
end
function acLoversDayTab1:getAllAwardToShowWithDialog(isClick)
    for i=1,#self.lightBgTb do
        G_removeFlicker2(self.lightBgTb[i])
    end
    if self.isFinished ==true then
        require "luascript/script/game/scene/gamedialog/activityAndNote/acLoversDayGetAwardDialog"
        self.isFinished =false
        local needDelayNum = 0
        -- if isClick ==nil then
        -- end
        local function callbackShowDia( )
            local function closeSure( )
                -- print("in closeSure~~~~~~~~")
                self:cleanData()
            end
            local sd=acLoversDayGetAwardDialog:new(self.layerNum + 1)
            local dialog= sd:init(closeSure)
            
        end 
        local delay=CCDelayTime:create(needDelayNum)
        local callFunc=CCCallFuncN:create(callbackShowDia)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)

        self.bgLayer:runAction(seq)
    end
end
function acLoversDayTab1:clickFinishAnimation( )
    print("here????")
    self.isClickStop =true
    self.state =2
    local mateCfg,pointIndex = acLoversDayVoApi:getScoreCfg()

    if pointIndex then
        self.matePointShowTb[pointIndex]["bg"]:stopAllActions()
        self.matePointShowTb[pointIndex]["bg"]:setOpacity(0)
        -- self.matePointShowTb[pointIndex]["bg"]:setVisible(false)
        self.matePointShowTb[pointIndex]["bg"]:setPosition(self.matePointPosTb[pointIndex])
        self.matePointShowTb[pointIndex]["str"]:setColor(G_ColorWhite)
        self.matePointShowTb[pointIndex]["bg"]:setVisible(true)
    end
    local awardTb = acLoversDayVoApi:getCurAwardIdTb()
    for k,v in pairs(self.wholePicTb) do
        local actionTb = v

        for i=1,SizeOfTable(actionTb) do
            if  i == awardTb[k] then
                actionTb[i]:setPositionY(0)
            else
                actionTb[i]:setPositionY(self.fuWei[k].y)
            end
        end
        if k > 4 then
            local sc = 1.3
            for j=1,3 do
                if awardTb[j] == awardTb[k] then
                    if self.showIdx ==0 then
                        self.showIdx = 1
                        G_addRectFlicker2(self.lightBgTb[j],sc,sc,1,"b",nil,10)
                        G_addRectFlicker2(self.lightBgTb[k],sc,sc,1,"b",nil,10)
                    elseif self.showIdx ==1 then
                        self.showIdx = 2
                        G_addRectFlicker2(self.lightBgTb[j],sc,sc,2,"p",nil,10)
                        G_addRectFlicker2(self.lightBgTb[k],sc,sc,2,"p",nil,10)
                    elseif self.showIdx ==2 then
                        self.showIdx = 3
                        G_addRectFlicker2(self.lightBgTb[j],sc,sc,3,"y",nil,10)
                        G_addRectFlicker2(self.lightBgTb[k],sc,sc,3,"y",nil,10)
                    end
                end
            end
        end
    end
    self.state = 0
    self:finishPalyAnimation(1)
end

function acLoversDayTab1:startPalyAnimation()

    self.loopNum =0
    self.nextShow[1] = 1
    self.state = 1
    
    self.yiWei[1] = true

end

function acLoversDayTab1:tick()
    local acVo = acLoversDayVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            if self ~= nil then
                self:close()
            end
        end
    end
    if acLoversDayVoApi:isToday()==false and self.isToday==true then
        self.isToday=false
        self:refreshVisible2()
    end
end

function acLoversDayTab1:moveSp( )
    local isStop = false
    local isShow = nil
    local isCurShow = 0
    local awardTb = acLoversDayVoApi:getCurAwardIdTb()
    for j=1,SizeOfTable(self.wholePicTb) do

        if self.nextShow[j] == 1 then
            isShow = j
            local actionTb = self.wholePicTb[j]
            local lastNum = SizeOfTable(actionTb)
            local speedNum = self.loopNum < 2 and self.speedTb[1] or self.speedTb[2]
            for i=1,SizeOfTable(actionTb) do
                local curPosY = actionTb[i]:getPositionY()
                if curPosY <= 0 and i + 1 <= lastNum then--下一个PIC是否要移位
                    self.yiWei[i+1] = true
                end
                if actionTb[lastNum]:getPositionY() < speedNum then--最后一个PIC 补位
                    self.yiWei[1] =true
                end
                if curPosY <= -100 then--判断是否要复位 并且关闭当前PIC位移开关
                    self.yiWei[i] =false
                    actionTb[i]:setPositionY(self.fuWei[j].y)
                end
                if self.yiWei[i] ==true then--当前图片位移
                    actionTb[i]:setPositionY(actionTb[i]:getPositionY()-speedNum)
                end
                if i == lastNum and self.loopNum < 20 then
                    self.loopNum = self.loopNum +1
                end
                if self.loopNum >= 20 and actionTb[i]:getPositionY() == 0 and i == awardTb[j] then
                    isStop = true
                    isCurShow = {i,j}
                    for m=1,lastNum do
                        if m ~= i then
                            actionTb[m]:setPositionY(self.fuWei[j].y)
                        end
                    end
                    do break end
                end
            end
        end
    end
    if isStop == true then
        self.loopNum =0
        self.nextShow[isShow] =0
        self.yiWei = {}
        if isShow > 3 then
            local sc = 1.3
            for i=1,3 do
                if awardTb[i] == isCurShow[1] then
                    if self.showIdx ==0 then
                        self.showIdx = 1
                        G_addRectFlicker2(self.lightBgTb[i],sc,sc,1,"b",nil,10)
                        G_addRectFlicker2(self.lightBgTb[isShow],sc,sc,1,"b",nil,10)
                    elseif self.showIdx ==1 then
                        self.showIdx = 2
                        G_addRectFlicker2(self.lightBgTb[i],sc,sc,2,"p",nil,10)
                        G_addRectFlicker2(self.lightBgTb[isShow],sc,sc,2,"p",nil,10)
                    elseif self.showIdx ==2 then
                        self.showIdx = 3
                        G_addRectFlicker2(self.lightBgTb[i],sc,sc,3,"y",nil,10)
                        G_addRectFlicker2(self.lightBgTb[isShow],sc,sc,3,"y",nil,10)
                    end
                end
            end
        end
        if isShow == #self.wholePicTb then
            self.state = 2--关闭
        else
            self.nextShow[isShow+1]=1
            self.yiWei[1] = true
        end
    end

end

function acLoversDayTab1:cleanData( )
    for k,v in pairs(self.wholePicTb) do
        local actionTb = v

        for i=1,SizeOfTable(actionTb) do
            actionTb[i]:setPositionY(self.fuWei[k].y)
        end
    end

    for i=1,#self.nextShow do
        self.nextShow[i] = 0
    end
    for i=1,#self.lightBgTb do
        G_removeFlicker2(self.lightBgTb[i])
    end
    
    self.yiWei = {}
    self.loopNum = 0
    self.isFinished =true
    self:refreshVisible2() --动画结束再调
    self.showIdx =0
    self.wholeTouchBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight+5000))
end

function acLoversDayTab1:fastTick( )
   
    if self.state ==1 then
        self:moveSp()
    elseif self.state ==2 then
        self.state = 0
        if self.isClickStop ==false then
            self:finishPalyAnimation( )
        end
    end

end

function acLoversDayTab1:showPoint(curPoint,pointIndex,isClick,fmtPoint)
    local mateCfg = acLoversDayVoApi:getScoreCfg()

    if pointIndex then
            self.matePointShowTb[pointIndex]["bg"]:setOpacity(255)
            self.matePointShowTb[pointIndex]["str"]:setColor(G_ColorYellowPro)
            local delay=CCDelayTime:create(0.5)
            local blink = CCBlink:create(0.5,2)
            -- local moveTo1 = CCMoveTo:create(0.5,ccp(self.matePointShowTb[pointIndex]["bg"]:getPositionX(),G_VisibleSizeHeight*0.5-80))
            local function callback( )
                -- print("openAwardDialog~~~~~")
                self.matePointShowTb[pointIndex]["bg"]:setOpacity(0)
                self.matePointShowTb[pointIndex]["bg"]:setVisible(false)
                
                self:getAllAwardToShowWithDialog(isClick)-----显示奖励的板子
                for i=1,4 do
                    self.matePointShowTb[i]["bg"]:setPosition(self.matePointPosTb[i])
                    self.matePointShowTb[i]["str"]:setColor(G_ColorWhite)
                    self.matePointShowTb[pointIndex]["bg"]:setVisible(true)
                end
            end 
            local callFunc=CCCallFuncN:create(callback)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(blink)
            -- acArr:addObject(moveTo1)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            self.matePointShowTb[pointIndex]["bg"]:runAction(seq)
    end
end