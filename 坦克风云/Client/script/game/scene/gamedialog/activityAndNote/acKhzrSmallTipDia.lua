acKhzrSmallTipDia=smallDialog:new()

function acKhzrSmallTipDia:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acKhzrSmallTipDia:showStrInfo(layerNum,istouch,isuseami,callBack,titleStr,textTab,textColorTab,textSize,stalls)
	local sd=acKhzrSmallTipDia:new()
    sd:initStrInfo(layerNum,istouch,isuseami,callBack,titleStr,textTab,textColorTab,textSize,stalls)
    return sd
end

function acKhzrSmallTipDia:initStrInfo(layerNum,istouch,isuseami,pCallBack,titleStr,textTab,textColorTab,textSize,stalls)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local nameFontSize=30


    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

     local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        local function touchHandler()
            if pCallBack then
                pCallBack()
            end
            return self:close()
        end
        if self.tv then
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                touchHandler()
            end
        else
            touchHandler()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local everyCellH=170
    local jianGeH=30
    local bgSize=CCSizeMake(560,30+jianGeH*2)

    local textLbTb={}
    local height=10
    local subH=10
    local textWidth=bgSize.width-60
    for k,v in pairs(textTab) do
        local  textlb=GetTTFLabelWrap(v,textSize or 25,CCSize(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if textColorTab then
            if textColorTab[k]~= nil then
                textlb:setColor(textColorTab[k])
            else
                textlb:setColor(G_ColorWhite)
            end
        end
        textlb:setAnchorPoint(ccp(0,1))
        height=height+textlb:getContentSize().height+subH
        textLbTb[k]=textlb
    end

    


    bgSize.height=bgSize.height+height+20
    bgSize.height = bgSize.height + 300
    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.bgLayer=dialogBg
    -- self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
    self.bgLayer:addChild(lineSp2)
    lineSp2:setRotation(180)

    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp2)


    -- 标题
    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-50)
    self.bgLayer:addChild(lightSp)

    local nameLb=GetTTFLabelWrap(titleStr,nameFontSize,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(bgSize.width/2,bgSize.height-40)
    self.bgLayer:addChild(nameLb)
    local nameLb2=GetTTFLabel(titleStr,nameFontSize)
    local realNameW=nameLb2:getContentSize().width
    if realNameW>nameLb:getContentSize().width then
        realNameW=nameLb:getContentSize().width
    end
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=bgSize.width/2-(realNameW/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=bgSize.width/2+(realNameW/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb:getPositionY())
        self.bgLayer:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end
    local dialogHeight=height+10
    local maxHeight=620
    if G_isIphone5()==true then
        maxHeight=720
    end
    if dialogHeight>maxHeight then
        scrollFlag=true
        dialogHeight=maxHeight
    end
    -- 内容
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,dialogHeight+300))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,30)
    self.bgLayer:addChild(dialogBg2)

    if height>dialogHeight then
        local cellHeight=height-20
        local isMoved=false
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                return 1
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(textWidth,cellHeight)
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local posY=cellHeight
                for k,v in pairs(textLbTb) do
                    cell:addChild(v)
                    v:setPosition(0,posY)
                    posY=posY-v:getContentSize().height-subH
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
        end
        local hd=LuaEventHandler:createHandler(tvCallBack)
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(textWidth,dialogHeight-20),nil)
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
        self.tv:setPosition(ccp(10,10))
        dialogBg2:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
    else
        local strSize2 = 18
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
            strSize2 = 21
        end
        local startH=20
        for k,v in pairs(textLbTb) do
            dialogBg2:addChild(v)
            v:setPosition(10,dialogBg2:getContentSize().height-startH)
            startH=startH+v:getContentSize().height+subH
        end

        local titleTb = {getlocal("packsName"),getlocal("originalPrice"),getlocal("discountedPrice"),getlocal("discountsDownright")}
        local posScale = {0.1,0.4,0.68,0.92}
        local newPosY = dialogHeight - startH
        for i=1,4 do
            local titleStr = GetTTFLabel(titleTb[i],strSize2)
            -- titleStr:setAnchorPoint(ccp(0.5，0))
            titleStr:setPosition(ccp(textWidth*posScale[i],newPosY+300))
            dialogBg2:addChild(titleStr)
        end
        local ng,curStalls = acKhzrVoApi:getNgAndStalls()--后台给，curStalls：当前第几档
        local shop=acKhzrVoApi:getShop()
        
        for i=1,6 do
            local numLb=GetTTFLabel(getlocal("packs_name_" .. i),strSize2)
            -- numLb:setColor(G_ColorYellowPro)
            numLb:setPosition(ccp(textWidth*posScale[1],newPosY-35*i+300))
            dialogBg2:addChild(numLb)

            local shopCfg=shop["i" .. i]
            local oldGold = GetTTFLabel(shopCfg.p..getlocal("gem"),strSize2)
            oldGold:setPosition(ccp(textWidth*posScale[2],numLb:getPositionY()))
            dialogBg2:addChild(oldGold)

            local curSpendGold = shopCfg.g[stalls]
            local newGold = GetTTFLabel(curSpendGold..getlocal("gem"),strSize2)
            newGold:setPosition(ccp(textWidth*posScale[3],numLb:getPositionY()))
            dialogBg2:addChild(newGold)

            local discount= math.ceil((shopCfg.p - curSpendGold)/shopCfg.p*100)
            local discountLb=GetTTFLabel("-"..discount.."%",strSize2)
            discountLb:setPosition(ccp(textWidth*posScale[4],numLb:getPositionY()))
            dialogBg2:addChild(discountLb)
        end


    end

	-- 下面的点击屏幕继续
	local clickLbPosy=-80
    local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
    local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1,arrowPosx2
    local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
    if realWidth>maxWidth then
        arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
    else
        arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
    end
    local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)

    local space=20
    smallArrowSp1:runAction(G_actionArrow(1,space))
    smallArrowSp2:runAction(G_actionArrow(1,space))
    smallArrowSp3:runAction(G_actionArrow(-1,space))
    smallArrowSp4:runAction(G_actionArrow(-1,space))


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end