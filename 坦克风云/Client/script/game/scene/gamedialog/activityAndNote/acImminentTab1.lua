acImminentTab1 ={}
function acImminentTab1:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=layerNum
    self.tv = nil
    self.bgWidth =G_VisibleSizeWidth-40
    self.bgHeight=G_VisibleSizeHeight-182
    self.needIphone5Height_1 = 0
    if G_isIphone5() then
        self.needIphone5Height_1 =20
    end
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 60
    end
    self.miningLine=nil
    self.miningMask=nil
    self.fixedWidht=nil
    self.fixedHeight=nil
    self.particleS1=nil
    self.particleS2=nil
    self.isToday =nil
    self.depthSingle=nil
    self.middleGurbDepth=nil
    self.curMovePos=nil
    self.maskSp=nil
    self.middleBgHeight = nil
    self.middleBgWidth =nil
    self.backSprie=nil
    return nc;

end
function acImminentTab1:dispose( )
    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
    self.bgWidth =nil
    self.bgHeight=nil
    self.needIphone5Height_1 = nil
    self.miningLine=nil
    self.miningMask=nil
    self.fixedWidht=nil
    self.fixedHeight=nil
    self.particleS1=nil
    self.particleS2=nil
    self.isToday=nil
    self.depthSingle=nil
    self.middleGurbDepth=nil
    self.maskSp =nil
    self.curMovePos=nil
    self.middleBgHeight = nil
    self.middleBgWidth =nil
    self.backSprie =nil
end

function acImminentTab1:init(layerNum)
    self.isToday=acImminentVoApi:isToday()
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end

    -- local tb1 = {}
    -- tb1["a"]={num=1}
    -- tb1["b"]={num=2}
    -- tb1["c"]={num=3}
    -- for k,v in pairs(tb1) do
    --     print("k----->",k)
    --     for i,j in pairs(v) do
    --         print("j------num>",j)
    --     end
    -- end
    -- tb1["a"]=nil
    -- for k,v in pairs(tb1) do
    --     print("k----->",k)
    -- end
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    local curFloorNums = acImminentVoApi:getDeepDepth()
    acImminentVoApi:setCurFloorNums(curFloorNums)
    local function cellClick(hd,fn,index)
    end
    local w = G_VisibleSizeWidth - 60 -- 背景框的宽度
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-44, G_VisibleSizeHeight-185))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setOpacity(0)
    backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5,25))
    self.bgLayer:addChild(backSprie)
    self.backSprie =backSprie

    local function tmpFunc()
        --print("maskSp~~~~~~")
        if self.particleS1 then
            self.particleS1:removeFromParentAndCleanup(true)
            self.particleS1 = nil 
        end
        if self.particleS2 then
            self.particleS2:removeFromParentAndCleanup(true)
            self.particleS2 = nil 
        end
        self.maskSp:setPosition(ccp(G_VisibleSizeWidth*0.5,999999))
        self.maskSp:setVisible(false)
        self.miningLine:stopAllActions()
        self.miningMask:stopAllActions()

        local insideWidthScale = 0.785
        local insideHeightScale = 1

        local curGrubNums=SizeOfTable(acImminentVoApi:getCurReward())--本次挖掘的层数
        local grubNums=acImminentVoApi:getDeepDepth()--总层数
        local curGrubIdx = grubNums-curGrubNums--本次未挖掘之前的层数

        self.depthSingle =self.middleGurbDepth/100
        if curGrubNums > 0 then
            self.menuRecostBtn:setEnabled(true)

            local maskScaleY = (340-55-self.depthSingle*grubNums)*insideHeightScale/self.miningMask:getContentSize().height
            self.curMovePos.y=self.middleBgHeight-52-self.depthSingle*grubNums
            self.miningLine:setPosition(self.curMovePos)
            self.miningMask:setScaleY(maskScaleY)
        end

        self:getRewardAndShow()
    end
    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    self.maskSp:setOpacity(0)
    local size=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.maskSp:setContentSize(size)
    self.maskSp:setAnchorPoint(ccp(0.5,0.5))
    self.maskSp:setPosition(ccp(G_VisibleSizeWidth*0.5,999999))
    self.maskSp:setIsSallow(true)
    self.maskSp:setTouchPriority(-(self.layerNum-1)*20-10)
    self.bgLayer:addChild(self.maskSp,100)

    self:initUpLayer(backSprie)
    self:initMiddleLayer(backSprie)
    self:initDownLayer(backSprie)
    return self.bgLayer
end

function acImminentTab1:initUpLayer(backSprie)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    local bgWidht = backSprie:getContentSize().width
    local bgHeight = backSprie:getContentSize().height 

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local headBg = CCSprite:create("public/acImminentImage/imminentBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    headBg:setPosition(ccp(0,backSprie:getContentSize().height))
    headBg:setAnchorPoint(ccp(0,1))
    -- print("hj1",headBg:getContentSize().width)
    local headbgScaleX = bgWidht/headBg:getContentSize().width
    local headbgScaleY = bgHeight*0.3/headBg:getContentSize().height
    if G_getIphoneType() == G_iphoneX then
        headbgScaleY = 1
    end
    headBg:setScaleX(headbgScaleX)
    -- print("hj2",headBg:getContentSize().width,headbgScaleX)
    headBg:setScaleY(headbgScaleY)
    backSprie:addChild(headBg)
    local headBgWidht = headBg:getContentSize().width
    local headBgHeight = headBg:getContentSize().height

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),strSize2)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height-5))
    acLabel:setColor(G_ColorGreen)
    backSprie:addChild(acLabel)

    local acVo = acImminentVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,strSize2)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp(backSprie:getContentSize().width*0.5, backSprie:getContentSize().height-40))
    backSprie:addChild(messageLabel)

    local function touch33(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScaleX(1/headbgScaleX)
    menuItemDesc:setScaleY(1/headbgScaleY)
    menuItemDesc:setScale(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(backSprie:getContentSize().width-5,backSprie:getContentSize().height-5))
    backSprie:addChild(menuDesc,1)

    local function noData( )
    end 
    touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 5, 10, 2),noData)
    touchDialogBg2:setTouchPriority(-(self.layerNum-1)*20-2)
    touchDialogBg2:setScaleX(1/headbgScaleX)
    touchDialogBg2:setScaleY(1/headbgScaleY)
    touchDialogBg2:setOpacity(150)
    touchDialogBg2:setContentSize(CCSizeMake(headBgWidht*0.96,headBgHeight*0.48))
    touchDialogBg2:setAnchorPoint(ccp(1,0))
    touchDialogBg2:setPosition(ccp(headBgWidht-2,2))
    headBg:addChild(touchDialogBg2,1)
    --activity_yichujifa_tab1_desc

    local descTv1=G_LabelTableView(CCSize(headBgWidht*0.7,headBgHeight*0.48),getlocal("activity_yichujifa_tab1_desc"),strSize2,kCCTextAlignmentLeft)
    descTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv1:setAnchorPoint(ccp(0,0))
    descTv1:setScaleX(1/headbgScaleX)
    descTv1:setScaleY(1/headbgScaleY)
    descTv1:setPosition(ccp(headBgWidht*0.28,2))
    headBg:addChild(descTv1,1)
    descTv1:setMaxDisToBottomOrTop(100)

    --accessoryRoundBg.png
    local blueBg=CCSprite:createWithSpriteFrameName("accessoryRoundBg.png")
    blueBg:setAnchorPoint(ccp(0,0))
    blueBg:setPosition(ccp(5,-10))
    blueBg:setScaleX(1/headbgScaleX)
    blueBg:setScaleY(1/headbgScaleY)
    blueBg:setScale(headBgWidht*0.25/blueBg:getContentSize().width)
    if G_getIphoneType() == G_iphoneX then
        blueBg:setScaleX(0.7)
        blueBg:setScaleY(0.7)
    elseif G_isIphone5() then
        blueBg:setScaleY(0.65)
    end
    headBg:addChild(blueBg,2)

    -- local tankId = acImminentVoApi:getTankID()
    local tankId = 10104
    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- local function showBattle()
        --     -- local battleStr=acYuebingshenchaVoApi:returnTankData()
        --     -- local report=G_Json.decode(battleStr)
        --     -- local isAttacker=true
        --     -- local data={data={report=report},isAttacker=isAttacker,isReport=true}
        --     -- battleScene:initData(data)
        --     local function battleCallback(fn,data)
        --         local ret,sData=base:checkServerData(data)
        --         if ret==true then
        --         end
        --     end 
        --     socketHelper:yichujifa(battleCallback,"3")
        -- end
        tankInfoDialog:create(headBg,tankId,self.layerNum+1,true)
    end

    local spriteIcon = LuaCCSprite:createWithSpriteFrameName("t"..tankId.."_1.png",touchInfo);
    spriteIcon:setAnchorPoint(ccp(0.5,0.5));
    spriteIcon:setScale(0.7)
    spriteIcon:setTouchPriority(-(self.layerNum-1)*20-5)
    spriteIcon:setPosition(getCenterPoint(blueBg))
    blueBg:addChild(spriteIcon,2)
end

function acImminentTab1:initMiddleLayer(backSprie)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    local bgWidht = backSprie:getContentSize().width
    local bgHeight = backSprie:getContentSize().height 

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local middleBg = CCSprite:create("public/acImminentImage/miningBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    middleBg:setPosition(ccp(bgWidht*0.5,backSprie:getContentSize().height*0.7+self.adaH))
    middleBg:setAnchorPoint(ccp(0.5,1))
    local middleBgScaleX = bgWidht/middleBg:getContentSize().width*0.96
    local middleBgScaleY = bgHeight*0.55/middleBg:getContentSize().height
    middleBg:setScaleX(middleBgScaleX)
    middleBg:setScaleY(middleBgScaleY)
    backSprie:addChild(middleBg)

    self.middleBgHeight = middleBg:getContentSize().height
    self.middleBgWidth = middleBg:getContentSize().width

    local stepAwardTb = acImminentVoApi:getDeepStepClientReward()

    
    for i=1,6 do
        local num = i-1

        local leftNum=GetTTFLabel(num*20,25)
        leftNum:setPosition(ccp(25,self.middleBgHeight-52-(57*num)))
        leftNum:setColor(G_ColorBlue)
        middleBg:addChild(leftNum)

        local rightNum=GetTTFLabel(num*20,25)
        rightNum:setPosition(ccp(self.middleBgWidth-25,self.middleBgHeight-52-(57*num)))
        rightNum:setColor(G_ColorBlue)
        middleBg:addChild(rightNum)

        leftNum:setScaleX(1/middleBgScaleX)
        leftNum:setScaleY(1/middleBgScaleY)
        rightNum:setScaleX(1/middleBgScaleX)
        rightNum:setScaleY(1/middleBgScaleY)

        if i <6 then
            local function showAwardTb(hd,fn,idx)
                local anyAwardTb = acImminentVoApi:getClientShow()
                local stepAwardTb = acImminentVoApi:getDeepStepClientReward()
                local sd=acImminentSmallDialog:new(self.layerNum + 1,i)
                local dialog= sd:init(nil,anyAwardTb,stepAwardTb)
            end 
            local awardPic = G_getItemIcon(stepAwardTb[i],45,false,self.layerNum,showAwardTb)
            if G_isIphone5() or G_isIOS()==false then
                awardPic:setScaleX(1/middleBgScaleX)
                awardPic:setScaleX(55/awardPic:getContentSize().width)
                awardPic:setScaleY(1/middleBgScaleY)
                awardPic:setScaleY(45/awardPic:getContentSize().height)
            end
            awardPic:setTouchPriority(-(self.layerNum-1)*20-6)
            awardPic:setAnchorPoint(ccp(0.5,1))
            awardPic:setPosition(ccp(self.middleBgWidth*0.5,self.middleBgHeight-60-(57*num)))
            middleBg:addChild(awardPic,1)
        end

    end
    local insideWidthScale = 0.785
    local insideHeightScale = 1
    
    self.miningLine =  CCSprite:createWithSpriteFrameName("blueGradualChange.png")
    self.miningLine:setScaleX(self.middleBgWidth*insideWidthScale/self.miningLine:getContentSize().width)
    self.miningLine:setAnchorPoint(ccp(0,1))
    self.miningLine:setOpacity(200)
    self.miningLine:setPosition(ccp(self.middleBgWidth*0.11,self.middleBgHeight-52))
    middleBg:addChild(self.miningLine,1)

    self.miningMask = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
    self.miningMask:setScaleX(self.middleBgWidth*insideWidthScale/self.miningMask:getContentSize().width)
    self.miningMask:setScaleY((340-55)*insideHeightScale/self.miningMask:getContentSize().height)
    self.miningMask:setOpacity(250)
    self.miningMask:setAnchorPoint(ccp(0,0))
    self.miningMask:setPosition(self.middleBgWidth*0.11,self.middleBgHeight*0.2+10)
    middleBg:addChild(self.miningMask)

    for i=1,2 do
        local bluePoint =CCSprite:createWithSpriteFrameName("acImminentbluePoint.png")
        bluePoint:setAnchorPoint(ccp(0.5,0.5))
        bluePoint:setPosition(ccp(self.miningLine:getContentSize().width*(i-1),self.miningLine:getContentSize().height-2))
        self.miningLine:addChild(bluePoint)
        if i ==1 then
            bluePoint:setRotation(180)
        end
    end
    --55  和340 蓝色背景图 从上到下的坐标，第一个是 1，第二个是 10
    local lastDepth = 340-55--48.4*6*middleBgScaleY--285*self.bgScaleH --100米深度的总像素点 --self.miningMask:getContentSize().height
    local depthNum =tonumber(acImminentVoApi:getDeepDepth())
    self.depthSingle =lastDepth/100
    self.middleGurbDepth=340-55--lastDepth
    self.curMovePos =ccp(self.middleBgWidth*0.11,self.miningLine:getPositionY()-self.depthSingle*depthNum)
    
    if depthNum > 0 and depthNum < 100 then
        -- print("self.depthSingle * depthNum--->",self.depthSingle,depthNum,self.depthSingle*depthNum)
        self.miningLine:setPosition(self.curMovePos)
        self.miningMask:setScaleY((340-55-self.depthSingle*depthNum)*insideHeightScale/self.miningMask:getContentSize().height)
    end

    local function reCostFun( )
        if G_checkClickEnable()==false then
                  do
                      return
                  end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
          end
        PlayEffect(audioCfg.mouseClick)
        local cost =  acImminentVoApi:getReCost()
        if playerVoApi:getGems()<cost then
            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
            return
        end

        local function sureReCost( )
            local function reCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    playerVoApi:setGems(playerVoApi:getGems()-cost)
                    self.miningLine:setPosition(ccp(self.middleBgWidth*0.11,self.middleBgHeight-52))
                    self.miningMask:setPosition(ccp(self.middleBgWidth*0.11,self.middleBgHeight*0.2+10))
                    self.miningMask:setScaleX(self.middleBgWidth*insideWidthScale/self.miningMask:getContentSize().width)
                    self.miningMask:setScaleY((340-55)*insideHeightScale/self.miningMask:getContentSize().height)
                    --数据重置
                    acImminentVoApi:setDeepDepth()
                    acImminentVoApi:setCurFloorNums()
                    self.menuRecostBtn:setEnabled(false)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionRestartSuccess"),30)
                end
            end 
            socketHelper:yichujifa(reCallback,"2")
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureReCost,getlocal("dialog_title_prompt"),getlocal("activity_yichujifa_reCostSure",{cost}),nil,self.layerNum+1)
    end 
    self.menuRecostBtn = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",reCostFun,11,getlocal("dailyTaskReset"),28)
    self.menuRecostBtn:setAnchorPoint(ccp(1,0))
    self.menuRecostBtn:setScale(0.8)
    if G_getIphoneType() == G_iphoneX then
        self.menuRecostBtn:setScale(0.65)
    end
    local menu1 = CCMenu:createWithItem(self.menuRecostBtn);
    menu1:setPosition(ccp(self.middleBgWidth-15,10));
    menu1:setTouchPriority(-(self.layerNum-1)*20-5);
    middleBg:addChild(menu1);

    if acImminentVoApi:getDeepDepth() ==0 or acImminentVoApi:getDeepDepth() ==100 then
        self.menuRecostBtn:setEnabled(false)
    end
    local adaStr = 22
    if G_getIphoneType() == G_iphoneX then
        adaStr = 25
    end
    --activity_yichujifa_reCostStr
    local reCostStr = GetTTFLabelWrap(getlocal("activity_yichujifa_reCostStr",{acImminentVoApi:getReCost()}),adaStr,CCSizeMake(self.middleBgWidth*0.7,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    reCostStr:setAnchorPoint(ccp(0,0.5))
    reCostStr:setPosition(ccp(15,35))
    reCostStr:setColor(G_ColorYellowPro)
    middleBg:addChild(reCostStr)
    reCostStr:setScaleX(1/middleBgScaleX)
    reCostStr:setScaleY(1/middleBgScaleY)

end

function acImminentTab1:initDownLayer(backSprie)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    local bgWidht = backSprie:getContentSize().width
    local bgHeight = backSprie:getContentSize().height


    for i=1,2 do
        local cost = acImminentVoApi:getCost(i)
        local costStr = GetTTFLabel(cost,25)
        costStr:setPosition(ccp(bgWidht*(0.2+(i-1)*0.5)-self.adaH/6,bgHeight*0.13+self.adaH/4))
        backSprie:addChild(costStr)

        local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setScale(0.8)
        goldIcon:setPosition(ccp(bgWidht*(0.2+(i-1)*0.5)+costStr:getContentSize().width-self.adaH/6,bgHeight*0.13+self.adaH/4))
        backSprie:addChild(goldIcon,1)

        local deep = acImminentVoApi:getDeep(i)
        local deepStr = GetTTFLabel("("..deep..")",25)
        deepStr:setAnchorPoint(ccp(0,0.5))
        deepStr:setPosition(ccp(bgWidht*(0.28+(i-1)*0.5)-self.adaH/6,bgHeight*0.13+self.adaH/4))
        deepStr:setColor(G_ColorGreen)
        backSprie:addChild(deepStr)

        local function grubCallBack( ... )--普通，大奖
            if G_checkClickEnable()==false then
                      do
                          return
                      end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
              end
            PlayEffect(audioCfg.mouseClick)
            local cost =  acImminentVoApi:getCost(i)
            -- print("i--->cost",i,cost)
            if playerVoApi:getGems()<cost then
                GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
                return
            end
            --activity_yichujifa_grubNoDeep
            if i ==2 then
                local grubNums=acImminentVoApi:getDeepDepth()
                if grubNums >=100 then
                    grubNums =0
                end
                if 100-grubNums<=acImminentVoApi:getBigDeep( ) then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_yichujifa_grubNoDeep"),30)
                    do return end
                end
            end
            local function battleCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    playerVoApi:setGems(playerVoApi:getGems()-cost)
                    self.maskSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
                    self.maskSp:setVisible(true)
                    if sData.data.yichujifa.active.t then
                        acImminentVoApi:setToday( sData.data.yichujifa.active.t )
                    end
                    if sData.data.yichujifa.active.c then
                        acImminentVoApi:setDeepDepth(sData.data.yichujifa.active.c)
                        local depthNum = tonumber(sData.data.yichujifa.active.c)
                    end
                    if sData.data.yichujifa.reward then
                        local reward = sData.data.yichujifa.reward
                        acImminentVoApi:setCurReward(reward[1])
                        acImminentVoApi:setCurBigReward(reward[2])
                    end
                    self:runGrubingAction( )
                end
            end 
            socketHelper:yichujifa(battleCallback,1,i)--action,digType,free
        end 
        local menuItem1 = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",grubCallBack,10+i,getlocal("activity_yichujifa_grubStr"..i),strSize2)
        menuItem1:setAnchorPoint(ccp(0.5,0))
        menuItem1:setScale(1)
        local menu1 = CCMenu:createWithItem(menuItem1);
        menu1:setPosition(ccp(bgWidht*(0.28+(i-1)*0.5)-self.adaH/6,10+self.adaH/3));
        menu1:setTouchPriority(-(self.layerNum-1)*20-5);
        menu1:setTag(10+i)
        backSprie:addChild(menu1);

        if i==1 then
            deepStr:setPosition(ccp(bgWidht*(0.28+(i-1)*0.5)-5-self.adaH/6,bgHeight*0.13+self.adaH/4))
            if self.isToday ==true then
                menuItem1:setVisible(true)
            else
                menuItem1:setVisible(false)
            end
        elseif i==2 then
            goldIcon:setPosition(ccp(bgWidht*(0.2+(i-1)*0.5)+costStr:getContentSize().width-5-self.adaH/6,bgHeight*0.13+self.adaH/4))
            if self.isToday ==true then
                menuItem1:setEnabled(true)
            else
                menuItem1:setEnabled(false)
            end
        end
    end

    local function freeCallBack( ... )--免费
        local function battleCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if  sData.data and sData.data.yichujifa and sData.data.yichujifa.active then
                    self.maskSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
                    self.maskSp:setVisible(true)
                    if sData.data.yichujifa.active.t then
                        acImminentVoApi:setToday( sData.data.yichujifa.active.t)
                    end
                    if sData.data.yichujifa.active.c then
                        acImminentVoApi:setDeepDepth(sData.data.yichujifa.active.c)
                        local depthNum = tonumber(sData.data.yichujifa.active.c)
                    end
                    if sData.data.yichujifa.reward then
                        local reward = sData.data.yichujifa.reward
                        acImminentVoApi:setCurReward(reward[1])
                        acImminentVoApi:setCurBigReward(reward[2])
                    end
                    self:runGrubingAction( )
                    self.menuItemFree:setVisible(false)
                    local menu = tolua.cast(self.backSprie:getChildByTag(11),"CCMenu")
                    local btn = tolua.cast(menu:getChildByTag(11),"CCMenuItemSprite")
                    btn:setEnabled(true)
                    btn:setVisible(true)

                    local menu2 = tolua.cast(self.backSprie:getChildByTag(12),"CCMenu")
                    local btn2 = tolua.cast(menu2:getChildByTag(12),"CCMenuItemSprite")
                    btn2:setEnabled(true)
                    btn2:setVisible(true)
                end
            end
        end 
        socketHelper:yichujifa(battleCallback,1,1,1)--action,digType,free
    end 
    self.menuItemFree = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",freeCallBack,111,getlocal("daily_lotto_tip_2"),25)
    self.menuItemFree:setAnchorPoint(ccp(0.5,0))
    self.menuItemFree:setScale(1)
    -- if G_getIphoneType() == G_iphoneX then
    --     self.menuItemFree:setScale(0.6)
    -- end
    local menu1 = CCMenu:createWithItem(self.menuItemFree);
    menu1:setPosition(ccp(bgWidht*0.28-self.adaH/6,10+self.adaH/3))
    menu1:setTouchPriority(-(self.layerNum-1)*20-5);
    backSprie:addChild(menu1);

    if self.isToday == true then
        self.menuItemFree:setVisible(false)
    end
end

function acImminentTab1:runGrubingAction( )
    local insideWidthScale = 0.785
    local insideHeightScale = 1

    local curGrubNums=SizeOfTable(acImminentVoApi:getCurReward())--本次挖掘的层数
    local grubNums=acImminentVoApi:getDeepDepth()--总层数
    local curGrubIdx = grubNums-curGrubNums--本次未挖掘之前的层数

    self.depthSingle =self.middleGurbDepth/100
    if curGrubNums > 0 then
        if self.particleS1 then
            self.particleS1:removeFromParentAndCleanup(true)
            self.particleS1 = nil 
        end
        self.particleS1 = CCParticleSystemQuad:create("public/acImminentImage/caikuang.plist")
        self.particleS1.positionType=kCCPositionTypeFree
        self.particleS1:setPosition(5,self.miningLine:getContentSize().height-3)
        self.particleS1:setScaleX(1.5)
        self.particleS1:setAnchorPoint(ccp(0,1))
        self.miningLine:addChild(self.particleS1)

        if self.particleS2 then
            self.particleS2:removeFromParentAndCleanup(true)
            self.particleS2 = nil 
        end
        self.particleS2 = CCParticleSystemQuad:create("public/acImminentImage/caikuang.plist")
        self.particleS2.positionType=kCCPositionTypeFree
        self.particleS2:setPosition(self.miningLine:getContentSize().width-5,self.miningLine:getContentSize().height)
        self.particleS2:setRotation(180)
        self.particleS2:setScaleX(1.5)
        self.particleS2:setAnchorPoint(ccp(0,1))
        self.miningLine:addChild(self.particleS2)

        local maskScaleX = self.middleBgWidth*insideWidthScale/self.miningMask:getContentSize().width
        local maskScaleY = (340-57-self.depthSingle*grubNums)*insideHeightScale/self.miningMask:getContentSize().height
        self.curMovePos.y=self.miningLine:getPositionY()-self.depthSingle*curGrubNums

        local movTo = CCMoveTo:create(0.3*curGrubNums,self.curMovePos)
        local scaleTo  =CCScaleTo:create(0.3*curGrubNums,maskScaleX,maskScaleY)
        local function callBackF( )
            if self.particleS1 then
                self.particleS1:removeFromParentAndCleanup(true)
                self.particleS1 = nil 
            end
            if self.particleS2 then
                self.particleS2:removeFromParentAndCleanup(true)
                self.particleS2 = nil 
            end
            self.menuRecostBtn:setEnabled(true)
            self.maskSp:setPosition(ccp(G_VisibleSizeWidth*0.5,999999))
            self.maskSp:setVisible(false)
            self:getRewardAndShow()
        end 
        local callFunc1=CCCallFuncN:create(callBackF)
        local acArr=CCArray:create()
        acArr:addObject(scaleTo)
        acArr:addObject(callFunc1)
        local seq=CCSequence:create(acArr)
        self.miningLine:runAction(movTo)
        self.miningMask:runAction(seq)
    end
end

function acImminentTab1:getRewardAndShow()
    local bigAwardTb = acImminentVoApi:getCurBigReward()
    local sosoAwardTb = acImminentVoApi:getCurReward()
    local grubNums=acImminentVoApi:getDeepDepth()--总层数
    local oldGurbNums = nil --挖掘之前的的层数
    local content = {}
    local msgContent = {}
    local idx =0
    local grubCellNumsTb ={} 
    local curOldFloorNums =nil
    if bigAwardTb and SizeOfTable(bigAwardTb)>0 then
        strs = G_showRewardTip(bigAwardTb,false,true)
        local message={key="chatSystemMessage13",param={playerVoApi:getPlayerName(),getlocal("activity_yichujifa_title"),strs,""}}
        chatVoApi:sendSystemMessage(message)

        curOldFloorNums =acImminentVoApi:getCurFloorNums()
        if curOldFloorNums ==100 then
            curOldFloorNums =0
        end
        oldGurbNums =grubNums-tonumber(SizeOfTable(sosoAwardTb))
        local curOldFloorIdx = math.floor(curOldFloorNums/20)
        -- print("curOldFloorNums-----curoldflooridx----->",curOldFloorNums,curOldFloorIdx)
        for i=1,SizeOfTable(bigAwardTb) do
            table.insert(grubCellNumsTb,i*20+curOldFloorIdx*20)
        end
        acImminentVoApi:setCurFloorNums(acImminentVoApi:getDeepDepth())
    end
    -- print("oldGurbNums----->",oldGurbNums)
    local showStrNums = oldGurbNums
    for k,v in pairs(sosoAwardTb) do
        showStr=getlocal("congratulationsGet",{v.name .. "*" .. v.num})
        table.insert(content,{award=v,point=0,index=idx+k})
        table.insert(msgContent,{showStr,G_ColorWhite}) 
        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
        if showStrNums then
            showStrNums =showStrNums+1
        end
        -- print("showStrNums--->",showStrNums )
        if showStrNums and  showStrNums%20 ==0 then
            -- print("here???---showStrNums%20------>",showStrNums%20)
            for i,j in pairs(bigAwardTb) do
                -- print("grubCellNumsTb[i] ==showStrNums------>",grubCellNumsTb[i],showStrNums)
                if grubCellNumsTb[i] ==showStrNums then
                    local nums = grubCellNumsTb[i]
                    showStr=getlocal("activity_yichujifa_gurbSucess",{nums,j.name .. "*" .. j.num})
                    table.insert(content,{award=j,point=0,index=idx+i})
                    table.insert(msgContent,{showStr,G_ColorYellowPro})
                    G_addPlayerAward(j.type,j.key,j.id,j.num,nil,true)
                end
            end
        end
        
    end

    -- for k,v in pairs(bigAwardTb) do
    --     local nums = grubCellNumsTb[k]
    --     showStr=getlocal("activity_yichujifa_gurbSucess",{nums,v.name .. "*" .. v.num})
    --     table.insert(content,{award=v,point=0,index=idx+k})
    --     table.insert(msgContent,{showStr,G_ColorYellowPro})
    --     G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
    -- end
    local function confirmHandler(awardIdx)
        local grubNums=acImminentVoApi:getDeepDepth()--总层数
        if grubNums ==100 then
            self.menuRecostBtn:setEnabled(false)
            acImminentVoApi:setDeepDepth()
            acImminentVoApi:setCurFloorNums(acImminentVoApi:getDeepDepth())
            self.miningLine:setPosition(ccp(self.middleBgWidth*0.11,self.middleBgHeight-52))
            self.miningMask:setPosition(ccp(self.middleBgWidth*0.11,self.middleBgHeight*0.2+10))
            self.miningMask:setScaleY((340-55)/self.miningMask:getContentSize().height)
        end
    end--activity_yichujifa_grubNumStr
    local addStr2 = getlocal("activity_yichujifa_grubNumStr",{SizeOfTable(sosoAwardTb)})
    smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_yichujifa_AwardStr"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,msgContent,nil,nil,nil,nil,nil,nil,nil,addStr2)
end


function acImminentTab1:openInfo( )
    -- print("in openInfo~~~~~")
    local strSize2 = 28
    if G_getCurChoseLanguage() =="ru" then
        strSize2 =24
    end
    local td=smallDialog:new()
    local tabStr = nil 
    tabStr ={"\n",getlocal("activity_yichujifa_iTip6"),"\n",getlocal("activity_yichujifa_iTip5"),"\n",getlocal("activity_yichujifa_iTip4"),"\n",getlocal("activity_yichujifa_iTip3",{acImminentVoApi:getDeep(2)}),"\n",getlocal("activity_yichujifa_iTip2",{acImminentVoApi:getDeep(1)}),"\n",getlocal("activity_yichujifa_iTip1"),"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize2,{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
end

function acImminentTab1:tick( )
    
    if acImminentVoApi:isToday() ==false then
        -- print("isToday----->false")
        self.menuItemFree:setVisible(true)
        local menu = tolua.cast(self.backSprie:getChildByTag(11),"CCMenu")
        local btn = tolua.cast(menu:getChildByTag(11),"CCMenuItemSprite")
        btn:setEnabled(false)
        btn:setVisible(false)

        local menu2 = tolua.cast(self.backSprie:getChildByTag(12),"CCMenu")
        local btn2 = tolua.cast(menu2:getChildByTag(12),"CCMenuItemSprite")
        btn2:setEnabled(false)
    elseif acImminentVoApi:isToday() ==true then
        -- print("isToday----->true")
        self.menuItemFree:setVisible(false)
        local menu = tolua.cast(self.backSprie:getChildByTag(11),"CCMenu")
        local btn = tolua.cast(menu:getChildByTag(11),"CCMenuItemSprite")
        btn:setEnabled(true)
        btn:setVisible(true)

        local menu2 = tolua.cast(self.backSprie:getChildByTag(12),"CCMenu")
        local btn2 = tolua.cast(menu2:getChildByTag(12),"CCMenuItemSprite")
        btn2:setEnabled(true)
        btn2:setVisible(true)
    end
end



