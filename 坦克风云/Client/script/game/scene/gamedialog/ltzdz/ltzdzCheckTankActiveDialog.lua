ltzdzCheckTankActiveDialog=smallDialog:new()

function ltzdzCheckTankActiveDialog:new()
    local nc={
    	lastSegLayer=nil,
    	curSegLayer=nil,
    	curPage=1, --当前显示页
    	maxPage=0, --总共的页数
    	displayPageNum=5, --页面可以显示的页数
    	touchEnable=true,
    	switchFlag=false,
        turnInterval=0.2,
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzCheckTankActiveDialog:showTankActiveDialog(layerNum)
    local sd=ltzdzCheckTankActiveDialog:new()
    sd:initTankActiveDialog(layerNum)
    return sd
end

function ltzdzCheckTankActiveDialog:initTankActiveDialog(layerNum)
    self.layerNum=layerNum
    self.isUseAmi=true
    self.isSizeAmi=false
    self.dialogLayer=CCLayer:create()

    local function close()
        return self:close()
    end
    local bgSize=CCSizeMake(580,750)
    self.bgSize=bgSize
    local dialogBg=G_getNewDialogBg(bgSize,getlocal("ltzdz_setTroops_detail"),30,nil,self.layerNum,true,close)
    dialogBg:setContentSize(bgSize)
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,1)

    self:show()

    self.clipperSize=CCSizeMake(560,self.bgSize.height-80)
    local clipperLayer=CCLayer:create()
    local layerPos=self.bgLayer:convertToNodeSpace(ccp(0,0))
    clipperLayer:setPosition(layerPos)
    self.bgLayer:addChild(clipperLayer)
    local clipper=CCClippingNode:create()
    clipper:setContentSize(self.clipperSize)
    clipper:setAnchorPoint(ccp(0.5,1))
    clipper:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+self.bgSize.height/2-65)
    local stencil=CCDrawNode:getAPolygon(self.clipperSize,1,1)
    clipper:setStencil(stencil) --遮罩
    clipperLayer:addChild(clipper,3)
    stencil:setPosition(0,0)

    local shadeSp=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
    shadeSp:setContentSize(self.clipperSize)
    shadeSp:setPosition(self.clipperSize.width/2,self.clipperSize.height/2)
    shadeSp:setOpacity(255*0.4)
    clipper:addChild(shadeSp,2)
    self.clipper=clipper

    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
    if ltzdzVoApi:isQualifying()==true then --定级赛，默认段位是新手
        seg=1
    end
    self.segmentSpTb={}
    self.curPage,self.maxPage,self.displayNum,self.switchFlag,segPosY=seg,6,5,false,self.clipperSize.height-50
    self.centerPos=ccp(self.clipperSize.width/2,segPosY)
    self.outScreenPos=ccp(1000,segPosY)
    self.displayCfg={
        {self.centerPos.x-230,1},
        {self.centerPos.x-130,1},
        {self.centerPos.x,1.15},
        {self.centerPos.x+130,1},
        {self.centerPos.x+230,1},
        
    }
    self.leftCfg={self.centerPos.x-390,1}
    self.rightCfg={self.centerPos.x+390,1}
    self.turnInterval=0.3
    self.scaleCfg={0.38,0.38,0.38,0.38,0.38,0.38}
    for i=1,self.maxPage do
        local function touchHandler(object,event,tag)
            if self.switchFlag==true then
                do return end
            end
            local offsetPage=tonumber(tag)-math.ceil(self.displayNum/2)
            if offsetPage>0 then
                self:rightPageHandler(offsetPage)
            elseif offsetPage<0 then
                self:leftPageHandler(math.abs(offsetPage))
            end
        end
        local segmentSp=ltzdzVoApi:getSegIcon(i,nil,touchHandler,2,false)
        segmentSp:setPosition(self.outScreenPos)
        segmentSp:setTouchPriority(-(self.layerNum-1)*20-4)
        segmentSp:setScale(self.scaleCfg[i])
        segmentSp:setTag(i)
        clipper:addChild(segmentSp)
        self.segmentSpTb[i]=segmentSp


        local nameStr=ltzdzVoApi:getSegName(i)
        local nameLb=GetTTFLabelWrap(nameStr,20,CCSizeMake(120,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")

        local nameBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
        nameBg:setScaleX(80/nameBg:getContentSize().width/segmentSp:getScale())
        nameBg:setScaleY(nameLb:getContentSize().height/nameBg:getContentSize().height/segmentSp:getScale())
        nameBg:setPosition(segmentSp:getContentSize().width/2,segmentSp:getContentSize().height/2-70)
        segmentSp:addChild(nameBg,2)

        nameLb:setPosition(nameBg:getPosition())
        nameLb:setScale(1/segmentSp:getScale())
        segmentSp:addChild(nameLb,3)
    end
    self.disPlayPageTb={}
    local page=self.curPage-2
    if page<1 then
        page=page+self.maxPage
    end
    for i=1,self.displayNum do
        self.disPlayPageTb[i]=page
        local segmentSp=tolua.cast(self.segmentSpTb[page],"LuaCCSprite")
        if segmentSp then
            segmentSp:setPosition(self.displayCfg[i][1],self.centerPos.y)
            local scale=self.displayCfg[i][2]*self.scaleCfg[page]
            segmentSp:setScale(scale)
            segmentSp:setTag(i)
            if self.curPage==page then
                self.clipper:reorderChild(segmentSp,3)
            end
        end
        page=page+1
        if page>self.maxPage then
            page=1
        end
    end
    self:initTankActiveLayer(self.curPage)

    local function rightPageHandler()
        if self.switchFlag==true then
            do return end
        end
        self:rightPageHandler()
    end
    local function leftPageHandler()
        if self.switchFlag==true then
            do return end
        end
        self:leftPageHandler()
    end
    local arrowPosY=self.bgSize.height/2-40
    local arrowCfg={
        {startPos=ccp(45,arrowPosY),targetPos=ccp(25,arrowPosY),callback=leftPageHandler,angle=0},
        {startPos=ccp(self.bgSize.width-45,arrowPosY),targetPos=ccp(self.bgSize.width-25,arrowPosY),callback=rightPageHandler,angle=180}
    }

    for i=1,2 do
        local cfg=arrowCfg[i]
        local arrowBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",function () end,11,nil,nil)
        arrowBtn:setRotation(cfg.angle)
        local arrowMenu=CCMenu:createWithItem(arrowBtn)
        arrowMenu:setAnchorPoint(ccp(0.5,0.5))
        arrowMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        arrowMenu:setPosition(cfg.startPos)
        self.bgLayer:addChild(arrowMenu,3)

        local arrowTouchSp=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),cfg.callback)
        arrowTouchSp:setTouchPriority(-(self.layerNum-1)*20-4)
        arrowTouchSp:setAnchorPoint(ccp(0.5,0.5))
        arrowTouchSp:setContentSize(CCSizeMake(100,100))
        arrowTouchSp:setPosition(cfg.startPos)
        arrowTouchSp:setOpacity(0)
        self.bgLayer:addChild(arrowTouchSp,4)

        local moveTo=CCMoveTo:create(0.5,cfg.targetPos)
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(moveTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local moveTo2=CCMoveTo:create(0.5,cfg.startPos)
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(moveTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        arrowMenu:runAction(CCRepeatForever:create(seq))
    end

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),touchLuaSpr)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255*0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    self.dialogLayer:setPosition(0,0)
    sceneGame:addChild(self.dialogLayer,self.layerNum)
end

function ltzdzCheckTankActiveDialog:leftPageHandler(skipPageNum)
    self.switchFlag=true
    if skipPageNum then
        skipPageNum=skipPageNum-1
    end
    local leftPage=self.curPage-math.ceil(self.displayNum/2)
    if leftPage<1 then
        leftPage=leftPage+self.maxPage
    end
    local rightPage=self.curPage+math.ceil(self.displayNum/2)
    if rightPage>self.maxPage then
        rightPage=rightPage-self.maxPage
    end
    local item=tolua.cast(self.segmentSpTb[self.curPage],"CCSprite")
    self.clipper:reorderChild(item,1)

    local leftItem=self.segmentSpTb[leftPage]
    leftItem:setPosition(self.leftCfg[1],self.centerPos.y)
    leftItem:setScale(self.leftCfg[2]*self.scaleCfg[leftPage])
    table.insert(self.disPlayPageTb,1,leftPage)
    for i=1,self.displayNum+1 do
        local page=self.disPlayPageTb[i]
        local segmentSp=tolua.cast(self.segmentSpTb[page],"CCSprite")
        segmentSp:setTag(i)
        local targetPos,targetScale
        if i==(self.displayNum+1) then
            targetPos,targetScale=ccp(self.rightCfg[1],self.centerPos.y),self.rightCfg[2]*self.scaleCfg[page]
        else
            targetPos,targetScale=ccp(self.displayCfg[i][1],self.centerPos.y),self.displayCfg[i][2]*self.scaleCfg[page]
        end
        local acArr=CCArray:create()
        local moveTo=CCMoveTo:create(self.turnInterval,targetPos)
        local scaleTo=CCScaleTo:create(self.turnInterval,targetScale)
        acArr:addObject(moveTo)
        acArr:addObject(scaleTo)
        local swpanAc=CCSpawn:create(acArr)
        local function moveCallBack()
            if i==(self.displayNum+1) then
                self.curPage=self.curPage-1
                if self.curPage<1 then
                    self.curPage=self.maxPage
                end
                self:resetDisplayPage()
                segmentSp:setPosition(self.outScreenPos)
                segmentSp:setScale(self.scaleCfg[page])
                if skipPageNum and skipPageNum>0 then
                    self:leftPageHandler(skipPageNum)
                else
                    self.switchFlag=false
                    self:turnPageCallBack(true)
                end
            end
        end
        local callback=CCCallFunc:create(moveCallBack)
        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
        segmentSp:runAction(seq)
    end
end

function ltzdzCheckTankActiveDialog:rightPageHandler(skipPageNum)
    self.switchFlag=true
    if skipPageNum then
        skipPageNum=skipPageNum-1
    end
    local leftPage=self.curPage-math.ceil(self.displayNum/2)
    if leftPage<1 then
        leftPage=leftPage+self.maxPage
    end
    local rightPage=self.curPage+math.ceil(self.displayNum/2)
    if rightPage>self.maxPage then
        rightPage=rightPage-self.maxPage
    end
    local item=tolua.cast(self.segmentSpTb[self.curPage],"CCSprite")
    self.clipper:reorderChild(item,1)

    local rightItem=self.segmentSpTb[rightPage]
    rightItem:setPosition(self.rightCfg[1],self.centerPos.y)
    rightItem:setScale(self.rightCfg[2]*self.scaleCfg[rightPage])
    table.insert(self.disPlayPageTb,rightPage)
    for i=1,self.displayNum+1 do
        local page=self.disPlayPageTb[i]
        local segmentSp=tolua.cast(self.segmentSpTb[page],"CCSprite")
        local targetPos,targetScale
        if i==1 then
            targetPos,targetScale=ccp(self.leftCfg[1],self.centerPos.y),self.leftCfg[2]*self.scaleCfg[page]
            segmentSp:setTag(self.displayNum+1)
        else
            targetPos,targetScale=ccp(self.displayCfg[i-1][1],self.centerPos.y),self.displayCfg[i-1][2]*self.scaleCfg[page]
            segmentSp:setTag(i-1)
        end
        local acArr=CCArray:create()
        local moveTo=CCMoveTo:create(self.turnInterval,targetPos)
        local scaleTo=CCScaleTo:create(self.turnInterval,targetScale)
        acArr:addObject(moveTo)
        acArr:addObject(scaleTo)
        local swpanAc=CCSpawn:create(acArr)
        local function moveCallBack()
            if i==1 then
                self.curPage=self.curPage+1
                if self.curPage>self.maxPage then
                    self.curPage=1
                end
                self:resetDisplayPage()
                segmentSp:setPosition(self.outScreenPos)
                segmentSp:setScale(self.scaleCfg[page])
                if skipPageNum and skipPageNum>0 then
                    self:rightPageHandler(skipPageNum)
                else
                    self.switchFlag=false
                    self:turnPageCallBack()
                end
            end
        end
        local callback=CCCallFunc:create(moveCallBack)
        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
        segmentSp:runAction(seq)
    end
end

function ltzdzCheckTankActiveDialog:turnPageCallBack(leftFlag)
    self.lastSegLayer=self.curSegLayer
    local leftPos=ccp(-self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    local rightPos=ccp(3*self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    local centerPos=ccp(self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    self:initTankActiveLayer(self.curPage)
    if leftFlag==true then
        self.curSegLayer:setPosition(leftPos)
    else
        self.curSegLayer:setPosition(rightPos)
    end
    local function playEndCallback()
        if self.lastSegLayer then
            self.lastSegLayer:removeFromParentAndCleanup(true)
            self.lastSegLayer=nil
        end
    end
    local mvTo1
    if leftFlag==true then
        mvTo1=CCMoveTo:create(self.turnInterval,rightPos)
    else
        mvTo1=CCMoveTo:create(self.turnInterval,leftPos)
    end
    local mvTo2=CCMoveTo:create(self.turnInterval,centerPos)
    local callFunc=CCCallFuncN:create(playEndCallback)

    local acArr=CCArray:create()
    acArr:addObject(mvTo1)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.lastSegLayer:runAction(seq)

    local acArr1=CCArray:create()
    acArr1:addObject(mvTo2)
    local seq1=CCSequence:create(acArr1)
    self.curSegLayer:runAction(seq1)
end

function ltzdzCheckTankActiveDialog:initTankActiveLayer(curPage)
    local tvWidth,tvHeight=self.clipperSize.width-20,self.bgSize.height-250
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(self.clipperSize.width/2,60)
    self.clipper:addChild(tvBg,3)
    self.curSegLayer=tvBg
    self.tankTb=ltzdzVoApi:getAddCanActiveTankBySeg(curPage)
    local tc,pertc=SizeOfTable(self.tankTb),3
    self.cellNum=tc%pertc==0 and math.floor(tc/pertc) or (math.floor(tc/pertc)+1)
    
    if self.cellNum==0 then
        local tipLb=GetTTFLabelWrap(getlocal("noAddTroopsType"),24,CCSizeMake(tvWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        tipLb:setPosition(getCenterPoint(tvBg))
        -- tipLb:setColor(G_ColorRed)
        tvBg:addChild(tipLb)
    end

    local cellWidth,cellHeight,iconSize=tvWidth,220,150
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then      
            return self.cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize
            tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local firstPosX=20
            local spaceX=(cellWidth-2*firstPosX-pertc*iconSize)/(pertc-1)
            for i=1,3 do
                local tank=self.tankTb[idx*3+i]
                if tank then
                    local tankId=tank.key
                    if tankId and tankCfg[tankId] and tankCfg[tankId].icon then
                        local tankSp=tankVoApi:getTankIconSp(tankId)
                        tankSp:setAnchorPoint(ccp(0,1))
                        tankSp:setScale(iconSize/tankSp:getContentSize().width)
                        tankSp:setPosition(firstPosX+(i-1)*(iconSize+spaceX),cellHeight-10)
                        cell:addChild(tankSp,2)

                        if G_pickedList(tankId)~=tankId then
                            local pickedSp=CCSprite:createWithSpriteFrameName("picked_icon1.png")
                            tankSp:addChild(pickedSp)
                            pickedSp:setPosition(tankSp:getContentSize().width*0.7,60)
                        end

                        -- local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
                        -- nameBg:setContentSize(CCSizeMake(iconSize-10,30))
                        -- nameBg:setAnchorPoint(ccp(0.5,0))
                        -- nameBg:setPosition(tankSp:getContentSize().width/2,5)
                        -- tankSp:addChild(nameBg)

                        local nameLb=GetTTFLabelWrap(getlocal(tankCfg[tankId].name),20,CCSizeMake(iconSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                        nameLb:setAnchorPoint(ccp(0.5,1))
                        nameLb:setPosition(tankSp:getPositionX()+iconSize/2,tankSp:getPositionY()-iconSize-5)
                        cell:addChild(nameLb)
                    end
                end
            end

            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
            lineSp:setContentSize(CCSizeMake((cellWidth-4),2))
            lineSp:setRotation(180)
            lineSp:setPosition(cellWidth/2,0)
            cell:addChild(lineSp)

            return cell
        elseif fn=="ccTouchBegan" then
            self.isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            self.isMoved=true
        elseif fn=="ccTouchEnded"  then
           
        end
    end
    local hd=LuaEventHandler:createHandler(eventHandler)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight-10),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    tv:setPosition(ccp(0,5))
    tv:setMaxDisToBottomOrTop(120)
    tvBg:addChild(tv)

    local activeTypeStr=""
    if self.curPage==1 then
        activeTypeStr=getlocal("ltzdz_activeType1")
    else
        activeTypeStr=getlocal("ltzdz_activeType2")
    end
    local activeTypeLb=GetTTFLabelWrap(activeTypeStr,24,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    activeTypeLb:setAnchorPoint(ccp(0.5,0.5))
    activeTypeLb:setPosition(tvBg:getContentSize().width/2,-30)
    activeTypeLb:setColor(G_ColorYellowPro)
    tvBg:addChild(activeTypeLb)
end

function ltzdzCheckTankActiveDialog:resetDisplayPage()
    self.disPlayPageTb={}
    local page=self.curPage-2
    if page<1 then
        page=page+self.maxPage
    end
    for i=1,5 do
        self.disPlayPageTb[i]=page
        local segmentSp=tolua.cast(self.segmentSpTb[page],"CCSprite")
        if segmentSp then
            if page==self.curPage then
                self.clipper:reorderChild(segmentSp,3)
            else
                self.clipper:reorderChild(segmentSp,1)
            end
        end
        page=page+1
        if page>self.maxPage then
            page=1
        end
    end
end

function ltzdzCheckTankActiveDialog:dispose()
    self.disPlayPageTb={}
end