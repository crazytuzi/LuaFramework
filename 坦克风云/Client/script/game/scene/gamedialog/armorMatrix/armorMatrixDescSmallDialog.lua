armorMatrixDescSmallDialog=smallDialog:new()

function armorMatrixDescSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function armorMatrixDescSmallDialog:init(layerNum)
    self.layerNum=layerNum

    local bgWidth,bgHeight=550,350
    local labelWidth=bgWidth-120
    local strLb={}
    for i=1,4 do
        local descStr=getlocal("armorMatrix_info_desc"..i)
        local lb=GetTTFLabelWrap(descStr,25,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        bgHeight=bgHeight+lb:getContentSize().height+5
        strLb[i]=lb
    end

    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg

    self.bgSize=CCSizeMake(bgWidth,bgHeight)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()


    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)


    local posy=bgHeight-50
    local titleLb = GetTTFLabel(getlocal("armorMatrix_info_title"),30)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(bgWidth/2,posy))
    self.bgLayer:addChild(titleLb,1)
    titleLb:setColor(G_ColorYellowPro)
    local titleBgHeight=titleLb:getContentSize().height+30
    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    titleBg:setPosition(ccp(bgWidth/2+20,posy-0))
    titleBg:setScaleY(titleBgHeight/titleBg:getContentSize().height)
    titleBg:setScaleX(bgWidth/titleBg:getContentSize().width)
    self.bgLayer:addChild(titleBg)
    posy=posy-titleBgHeight/2
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScale((bgWidth-100)/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(bgWidth/2,posy))
    self.bgLayer:addChild(lineSp)



    posy=posy-10
    local bottomBgWidth,bottomBgHeight=bgWidth-80,250
    local bottomScale=0.8
    local spacey=5
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local bottomBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    bottomBg:setContentSize(CCSizeMake(bottomBgWidth,bottomBgHeight))
    bottomBg:ignoreAnchorPointForPosition(false)
    bottomBg:setAnchorPoint(ccp(0.5,1))
    bottomBg:setIsSallow(false)
    bottomBg:setTouchPriority(-(self.layerNum-1)*20-1)
    bottomBg:setPosition(ccp(bgWidth/2,posy))
    self.bgLayer:addChild(bottomBg,1)
    bottomBg:setScale(bottomScale)
    bottomBg:setOpacity(0)

    local clipper=CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))
    clipper:setAnchorPoint(ccp(0,0))
    clipper:setPosition(ccp(0,0))
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(bottomBgWidth,bottomBgHeight),1,1)
    stencil:setAnchorPoint(ccp(0,0))
    stencil:setPosition(ccp(40,posy-bottomBgHeight*bottomScale))
    clipper:setStencil(stencil) --遮罩
    self.bgLayer:addChild(clipper)
    local gridSize=170
    local xTab=G_getIconSequencePosx(2,gridSize,self.bgLayer:getContentSize().width/2,3)
    for k=1,2 do
        for i=1,3 do
            local spBg=CCSprite:createWithSpriteFrameName("amMainBg.png")
            spBg:setScale(gridSize/spBg:getContentSize().width)
            local px,py=xTab[i],posy-gridSize/2-(k-1)*gridSize
            spBg:setPosition(ccp(xTab[i],py))
            clipper:addChild(spBg)
        end
    end

    local amChangeBg1=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg1:setScaleX(bottomBgWidth*(1/bottomScale)/amChangeBg1:getContentSize().width)
    amChangeBg1:setScaleY(bottomBgHeight/2/amChangeBg1:getContentSize().height)
    amChangeBg1:setAnchorPoint(ccp(0.5,1))
    amChangeBg1:setPosition(ccp(bottomBgWidth/2,bottomBgHeight))
    bottomBg:addChild(amChangeBg1)
    local amChangeBg2=CCSprite:createWithSpriteFrameName("amChangeBg.png")
    amChangeBg2:setRotation(180)
    amChangeBg2:setScaleX(bottomBgWidth*(1/bottomScale)/amChangeBg2:getContentSize().width)
    amChangeBg2:setScaleY(bottomBgHeight/2/amChangeBg2:getContentSize().height)
    amChangeBg2:setAnchorPoint(ccp(0.5,1))
    amChangeBg2:setPosition(ccp(bottomBgWidth/2,0))
    bottomBg:addChild(amChangeBg2)

    local amTankPosBg=CCSprite:createWithSpriteFrameName("amTankPosBg.png")
    amTankPosBg:setPosition(ccp(bottomBgWidth/2,116+spacey))
    bottomBg:addChild(amTankPosBg)
    -- amTankPosBg:setOpacity(100)

    -- local bottomLineSp=CCSprite:createWithSpriteFrameName("amBottomLine.png")
    -- bottomLineSp:setPosition(ccp(bottomBgWidth/2,3))
    -- bottomBg:addChild(bottomLineSp,1)

    for i=1,6 do
        local posSp=CCSprite:createWithSpriteFrameName("amTankPosBtn.png")
        local posSp2=CCSprite:createWithSpriteFrameName("amTankPosBtn_Down.png")
        local firstX,firstY,secX,secY,spaceX,spaceY=190,posy-70+spacey,132,posy-145+spacey,145*bottomScale,0
        local px,py
        local px,py
        if i==1 then
            px,py=firstX,firstY
        elseif i==2 then
            px,py=firstX+spaceX,firstY-spaceY
        elseif i==3 then
            px,py=firstX+spaceX*2,firstY-spaceY*2
        elseif i==4 then
            px,py=secX,secY
        elseif i==5 then
            px,py=secX+spaceX*1,secY-spaceY*1
        else
            px,py=secX+spaceX*2,secY-spaceY*2
        end
        posSp:setPosition(ccp(px,py))
        posSp2:setPosition(getCenterPoint(posSp))
        posSp2:setTag(101)
        posSp:addChild(posSp2,1)
        local orderNum=7-i
        posSp:setScale(1/bottomScale*0.6)
        self.bgLayer:addChild(posSp,orderNum)
        local tankSp1=CCSprite:createWithSpriteFrameName("amTank.png")
        tankSp1:setPosition(getCenterPoint(posSp))
        tankSp1:setScale(1)
        tankSp1:setTag(102)
        posSp:addChild(tankSp1,2)
        local tankSp2=CCSprite:createWithSpriteFrameName("amMainTank.png")
        tankSp2:setPosition(getCenterPoint(posSp))
        tankSp2:setTag(103)
        posSp:addChild(tankSp2,3)
        tankSp2:setScale(0.45)
        -- local nameStr=armorMatrixVoApi:getNameByAttr(i)
        -- local nameLb=GetTTFLabel(nameStr,22)
        -- nameLb:setAnchorPoint(ccp(0.5,0.5))
        -- nameLb:setPosition(ccp(posSp:getContentSize().width/2,25))
        -- nameLb:setTag(105)
        -- posSp:addChild(nameLb,6)
        -- nameLb:setColor(G_ColorYellowPro)
        -- local nameBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
        -- nameBg:setAnchorPoint(ccp(0.5,0.5))
        -- nameBg:setPosition(ccp(posSp:getContentSize().width/2,25))
        -- posSp:addChild(nameBg,5)
        -- nameBg:setTag(106)
        -- nameBg:setScaleX((posSp:getContentSize().width-20)/nameBg:getContentSize().width)
        -- nameBg:setScaleY((nameLb:getContentSize().height+10)/nameBg:getContentSize().height)
        -- if nameStr and nameStr~="" then
        -- else
        --     nameBg:setVisible(false)
        -- end

        if i==1 then
            tankSp1:setVisible(false)
        else
            posSp2:setVisible(false)
            tankSp2:setVisible(false)
        end

        local numPx,numPy=px-75*bottomScale,py+48*bottomScale
        if math.ceil(i/3)==2 then
           numPx,numPy=px+75*bottomScale,py-48*bottomScale
        end
        local numSp=CCSprite:createWithSpriteFrameName("amNum"..i..".png")
        numSp:setPosition(ccp(numPx,numPy))
        self.bgLayer:addChild(numSp,1)
        numSp:setScale(bottomScale)
    end

    posy=posy-bottomBgHeight*bottomScale-20
    local labelWidth=bgWidth-120
    for i=1,4 do
        local acPointSp=CCSprite:createWithSpriteFrameName("amPointCircle.png")
        acPointSp:setPosition(ccp(50,posy-15))
        self.bgLayer:addChild(acPointSp,1)
        local descStr=getlocal("armorMatrix_info_desc"..i)
        if strLb[i] then
            local lb=tolua.cast(strLb[i],"CCLabelTTF")
            if lb then
                lb:setAnchorPoint(ccp(0,1))
                lb:setPosition(ccp(70,posy))
                self.bgLayer:addChild(lb,1)
                -- lb:setColor(G_ColorYellowPro)
                posy=posy-lb:getContentSize().height-5
            end
        end
    end


    local function touchLuaSpr()
        -- PlayEffect(audioCfg.mouseClick)
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

