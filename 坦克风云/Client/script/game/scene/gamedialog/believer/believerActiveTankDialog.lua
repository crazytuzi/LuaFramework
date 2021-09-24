local believerActiveTankDialog=smallDialog:new()

function believerActiveTankDialog:new()
    local nc={
    	lastSegLayer=nil,
    	curSegLayer=nil,
    	curPage=1, --当前显示页
    	touchEnable=true,
        turnInterval=0.2,
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function believerActiveTankDialog:showActiveTankDialog(layerNum)
    local sd=believerActiveTankDialog:new()
    sd:initActiveTankDialog(layerNum)
    return sd
end

function believerActiveTankDialog:initActiveTankDialog(layerNum)
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

    self.curPage=believerVoApi:getMySegment()
    self.segmentSpTb={}
    local segPosY=self.clipperSize.height-50
    self.centerPos=ccp(self.clipperSize.width/2,segPosY)
    self.displayCfg={
        {self.centerPos.x-240,1},
        {self.centerPos.x-120,1},
        {self.centerPos.x,1.15},
        {self.centerPos.x+120,1},
        {self.centerPos.x+240,1},
    }
    self.leftCfg={self.centerPos.x-390,1}
    self.rightCfg={self.centerPos.x+390,1}
    self.turnInterval=0.3
    for i=1,5 do
        local function touchHandler(object,event,tag)
            if self.curPage>tag then
                self.curPage=tag
                self:turnPageCallBack(true)
            else
                self.curPage=tag
                self:turnPageCallBack()
            end
            self:resetDisplayPage(self.curPage)
        end
        local segmentSp=believerVoApi:getSegmentIcon(i,nil,nil,touchHandler)
        segmentSp:setPosition(self.displayCfg[i][1],segPosY)
        segmentSp:setTouchPriority(-(self.layerNum-1)*20-4)
        segmentSp:setScale(0.38)
        segmentSp:setTag(i)
        clipper:addChild(segmentSp)
        self.segmentSpTb[i]=segmentSp


        local nameStr=believerVoApi:getSegmentName(i)
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
    self:resetDisplayPage(self.curPage)
    self:initActiveTankLayer(self.curPage)

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

function believerActiveTankDialog:turnPageCallBack(leftFlag)
    self.lastSegLayer=self.curSegLayer
    local leftPos=ccp(-self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    local rightPos=ccp(3*self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    local centerPos=ccp(self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    self:initActiveTankLayer(self.curPage)
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

function believerActiveTankDialog:initActiveTankLayer(curPage)
    local tvWidth,tvHeight=self.clipperSize.width-20,self.bgSize.height-210
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(self.clipperSize.width/2,20)
    self.clipper:addChild(tvBg,3)
    self.curSegLayer=tvBg
    self.tankTb=believerVoApi:getActiveTankBySegment(curPage)
    local tc,pertc=SizeOfTable(self.tankTb),3
    self.cellNum=tc%pertc==0 and math.floor(tc/pertc) or (math.floor(tc/pertc)+1)
    
    if self.cellNum==0 then
        local tipLb=GetTTFLabelWrap(getlocal("believer_notank_avaiable"),24,CCSizeMake(tvWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
                        local tankSp=tankVoApi:getTankIconSp(tankId)--CCSprite:createWithSpriteFrameName(tankCfg[tankId].icon)
                        tankSp:setAnchorPoint(ccp(0,1))
                        tankSp:setScale(iconSize/tankSp:getContentSize().width)
                        tankSp:setPosition(firstPosX+(i-1)*(iconSize+spaceX),cellHeight-10)
                        cell:addChild(tankSp,2)

                        if G_pickedList(tankId)~=tankId then
                            local pickedSp=CCSprite:createWithSpriteFrameName("picked_icon1.png")
                            tankSp:addChild(pickedSp)
                            pickedSp:setPosition(tankSp:getContentSize().width*0.7,60)
                        end

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

    -- local activeTypeStr=""
    -- if self.curPage==1 then
    --     activeTypeStr=getlocal("ltzdz_activeType1")
    -- else
    --     activeTypeStr=getlocal("ltzdz_activeType2")
    -- end
    -- local activeTypeLb=GetTTFLabelWrap(activeTypeStr,24,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- activeTypeLb:setAnchorPoint(ccp(0.5,0.5))
    -- activeTypeLb:setPosition(tvBg:getContentSize().width/2,-30)
    -- activeTypeLb:setColor(G_ColorYellowPro)
    -- tvBg:addChild(activeTypeLb)
end

function believerActiveTankDialog:resetDisplayPage(page)
    for k,v in pairs(self.segmentSpTb) do
        local segmentSp=tolua.cast(v,"LuaCCSprite")
        if segmentSp then
            if k==self.curPage then
                self.clipper:reorderChild(segmentSp,3)
            else
                self.clipper:reorderChild(segmentSp,1)
            end
        end
    end
end

function believerActiveTankDialog:dispose()
    self.lastSegLayer=nil
    self.curSegLayer=nil
    self.curPage=nil
    self.touchEnable=nil
    self.turnInterval=nil
end

return believerActiveTankDialog