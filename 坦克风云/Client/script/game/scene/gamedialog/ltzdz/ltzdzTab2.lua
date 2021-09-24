ltzdzTab2 ={}
function ltzdzTab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    return nc
end

function ltzdzTab2:init()
	self.bgLayer=CCLayer:create()
	self:initLayer()
	return self.bgLayer
end

function ltzdzTab2:initLayer()
    self.qualifyingFlag=ltzdzVoApi:isQualifying() --是否在定级赛中
    local mySegment=ltzdzVoApi:getSegment()
    self.selectSeg=mySegment
    self.shopCfg=ltzdzVoApi:getShop(mySegment)
    self.cellNum=SizeOfTable(self.shopCfg)
    self.trueShop=ltzdzVoApi:getSortShop(mySegment)
    self.buyBlog=ltzdzVoApi:getBuyBlog(mySegment)

    local headerSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),function () end)
    headerSprie:setContentSize(CCSizeMake(616,90))
    headerSprie:ignoreAnchorPointForPosition(false)
    headerSprie:setAnchorPoint(ccp(0.5,1))
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    headerSprie:setPosition(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-165)
    self.bgLayer:addChild(headerSprie)

   local pointSp=CCSprite:createWithSpriteFrameName("ltzdzPointIcon.png")
    pointSp:setAnchorPoint(ccp(0,0.5))
    local scale=70/pointSp:getContentSize().width
    pointSp:setScale(scale)
    pointSp:setPosition(20,headerSprie:getContentSize().height/2)
    headerSprie:addChild(pointSp)

    local nameLb=GetTTFLabel(getlocal("ltzdz_feat"),20)
    headerSprie:addChild(nameLb)
    nameLb:setAnchorPoint(ccp(0,0))
    nameLb:setPosition(110,headerSprie:getContentSize().height/2+5)
    nameLb:setColor(G_ColorYellowPro)

    local point=ltzdzVoApi:getMyPoint()
    local valueLb=GetTTFLabel(point,20)
    headerSprie:addChild(valueLb)
    valueLb:setAnchorPoint(ccp(0,1))
    valueLb:setColor(G_ColorGreen)
    valueLb:setPosition(110,headerSprie:getContentSize().height/2-5)
    self.valueLb=valueLb

    local function infoHandler(tag,object)
        local tabStr={}
        for i=1,4 do
            local str=getlocal("ltzdz_shop_rule"..i)
            table.insert(tabStr,str)
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end
    local priority=-(self.layerNum-1)*20-4
    local btnPos=ccp(headerSprie:getContentSize().width-60,headerSprie:getContentSize().height/2)
    G_createBotton(headerSprie,btnPos,nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",infoHandler,0.8,priority)

    self.clipperSize=CCSizeMake(580,120)
    local clipper=CCClippingNode:create()
    clipper:setContentSize(self.clipperSize)
    clipper:setAnchorPoint(ccp(0.5,0.5))
    clipper:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-310)
    local stencil=CCDrawNode:getAPolygon(self.clipperSize,1,1)
    clipper:setStencil(stencil) --遮罩
    self.bgLayer:addChild(clipper)
    stencil:setPosition(0,0)

    local shadeSp=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
    shadeSp:setContentSize(self.clipperSize)
    shadeSp:setPosition(self.clipperSize.width/2,self.clipperSize.height/2)
    shadeSp:setOpacity(255*0.4)
    clipper:addChild(shadeSp,2)
    self.clipper=clipper

    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
    self.segmentSpTb={}
    self.curPage,self.maxPage,self.displayNum,self.switchFlag=seg,6,5,false
    self.centerPos=ccp(self.clipperSize.width/2,self.clipperSize.height/2)
    self.outScreenPos=ccp(1000,self.clipperSize.height/2)
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
    if self.qualifyingFlag==true then
        self.curPage=1
    end
    self.scaleCfg={0.44,0.43,0.42,0.42,0.38,0.38}
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
        -- segmentSp:setAnchorPoint(ccp(0.5,0))
        segmentSp:setPosition(self.outScreenPos)
        segmentSp:setTouchPriority(-(self.layerNum-1)*20-4)
        segmentSp:setScale(self.scaleCfg[i])
        segmentSp:setTag(i)
        clipper:addChild(segmentSp)
        self.segmentSpTb[i]=segmentSp
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
    local arrowPosY=G_VisibleSizeHeight-310
    local arrowCfg={
        {startPos=ccp(45,arrowPosY),targetPos=ccp(25,arrowPosY),callback=leftPageHandler,angle=0},
        {startPos=ccp(G_VisibleSizeWidth-45,arrowPosY),targetPos=ccp(G_VisibleSizeWidth-25,arrowPosY),callback=rightPageHandler,angle=180}
    }

    for i=1,2 do
        local cfg=arrowCfg[i]
        local arrowBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",cfg.callback,11,nil,nil)
        arrowBtn:setRotation(cfg.angle)
        local arrowMenu=CCMenu:createWithItem(arrowBtn)
        arrowMenu:setAnchorPoint(ccp(0.5,0.5))
        arrowMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        arrowMenu:setPosition(cfg.startPos)
        self.bgLayer:addChild(arrowMenu)

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

    local tvHeight=G_VisibleSizeHeight-400
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),function () end)
    tvBg:setContentSize(CCSizeMake(616,tvHeight+10))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(G_VisibleSizeWidth/2,30)
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(616,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(20,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local tipKuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("newKuang.png",CCRect(14,14,1,1),function () end)
    tipKuangSp:setContentSize(CCSizeMake(300,40))
    self.bgLayer:addChild(tipKuangSp,4)
    local arrowSp=CCSprite:createWithSpriteFrameName("newArrow.png")
    arrowSp:setAnchorPoint(ccp(0.5,0))
    arrowSp:setTag(100)
    tipKuangSp:addChild(arrowSp)
    local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
    lockSp:setAnchorPoint(ccp(0,0.5))
    lockSp:setScale(0.4)
    lockSp:setTag(101)
    tipKuangSp:addChild(lockSp)
    local unlockSegLb=GetTTFLabel("",20)
    unlockSegLb:setAnchorPoint(ccp(0,0.5))
    unlockSegLb:setColor(G_ColorYellowPro)
    unlockSegLb:setTag(102)
    tipKuangSp:addChild(unlockSegLb)
    local unlockShopLb=GetTTFLabel(getlocal("ltzdz_unlock_shop"),20)
    unlockShopLb:setAnchorPoint(ccp(0,0.5))
    unlockShopLb:setTag(103)
    tipKuangSp:addChild(unlockShopLb)
    tipKuangSp:setVisible(false)
    self.tipKuangSp=tipKuangSp
    self:refreshUnlockTip()
end

function ltzdzTab2:refreshUnlockTip()
    if self.tipKuangSp and self.curPage then
        local mySegment=ltzdzVoApi:getSegment()
        if mySegment<self.curPage or self.qualifyingFlag==true then
            self.tipKuangSp:setVisible(true)
            local segNameStr=ltzdzVoApi:getSegName(self.curPage)
            local arrowSp=tolua.cast(self.tipKuangSp:getChildByTag(100),"CCSprite")
            local lockSp=tolua.cast(self.tipKuangSp:getChildByTag(101),"CCSprite")
            local unlockSegLb=tolua.cast(self.tipKuangSp:getChildByTag(102),"CCLabelTTF")
            unlockSegLb:setString(segNameStr)
            local unlockShopLb=tolua.cast(self.tipKuangSp:getChildByTag(103),"CCLabelTTF")
            local lbwidth=lockSp:getContentSize().width*lockSp:getScale()+unlockSegLb:getContentSize().width+unlockShopLb:getContentSize().width+70
            self.tipKuangSp:setContentSize(CCSizeMake(lbwidth,40))
            local centerPosY=self.tipKuangSp:getContentSize().height/2
            arrowSp:setPosition(self.tipKuangSp:getContentSize().width/2,centerPosY*2)
            lockSp:setPosition(30,centerPosY)
            unlockSegLb:setPosition(lockSp:getPositionX()+lockSp:getContentSize().width*lockSp:getScale()+10,centerPosY)
            unlockShopLb:setPosition(unlockSegLb:getPositionX()+unlockSegLb:getContentSize().width,centerPosY)
            self.tipKuangSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-380)
        else
            self.tipKuangSp:setVisible(false)
        end
    end
end

function ltzdzTab2:leftPageHandler(skipPageNum)
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
                    self:turnPageCallBack()
                end
            end
        end
        local callback=CCCallFunc:create(moveCallBack)
        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
        segmentSp:runAction(seq)
    end
end

function ltzdzTab2:rightPageHandler(skipPageNum)
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

function ltzdzTab2:turnPageCallBack()
    self:refreshUnlockTip()
    self:refresh()
end

function ltzdzTab2:resetDisplayPage()
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

function ltzdzTab2:refresh()
    self.shopCfg=ltzdzVoApi:getShop(self.curPage)
    self.trueShop=ltzdzVoApi:getSortShop(self.curPage)
    self.buyBlog=ltzdzVoApi:getBuyBlog(self.curPage)
    self.cellNum=SizeOfTable(self.shopCfg)
    if self.tv then
        self.tv:reloadData()
    end
    if self.valueLb then
        local point=ltzdzVoApi:getMyPoint()
        self.valueLb=tolua.cast(self.valueLb,"CCLabelTTF")
        self.valueLb:setString(point)
    end
end

function ltzdzTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-40,120)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth,cellHeight=G_VisibleSizeWidth-40,120

        local pid=self.trueShop[idx+1].id
        local item=self.shopCfg[pid]
        local buyNum=self.buyBlog[pid] or 0
        local limit=item.bn or 0
        local cost=item.p --消耗的功勋值
        local reward=FormatItem(item.r)[1] --购买的奖励
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,reward,true)
            return false
        end
        local iconSp,scale=G_getItemIcon(reward,100,true,self.layerNum+1,showNewPropInfo)
        iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
        iconSp:setAnchorPoint(ccp(0,0.5))
        iconSp:setPosition(15,cellHeight/2)
        cell:addChild(iconSp)
        local iconWidth=iconSp:getContentSize().width*iconSp:getScaleX()
        local iconHeight=iconSp:getContentSize().height*iconSp:getScaleY()

        local numLb=GetTTFLabel("x"..reward.num,20)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
        numLb:setScale(1/scale)
        iconSp:addChild(numLb)

        local nameFontSize,descFontSize=20,18
        local nameLb=GetTTFLabelWrap(reward.name,nameFontSize,CCSizeMake(cellWidth-280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(15+iconWidth+10,cellHeight-nameLb:getContentSize().height/2-20)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorYellowPro)
        cell:addChild(nameLb)
        local tempNameLb=GetTTFLabel(reward.name,nameFontSize)
        local realW=tempNameLb:getContentSize().width
        if realW>nameLb:getContentSize().width then
            realW=nameLb:getContentSize().width
        end

        if limit>0 then
            local limitLb=GetTTFLabel("("..buyNum.."/"..item.bn..")",nameFontSize)
            limitLb:setAnchorPoint(ccp(0,0.5))
            limitLb:setPosition(nameLb:getPositionX()+realW+5,nameLb:getPositionY())
            cell:addChild(limitLb)
        end
                
        local descLb=GetTTFLabelWrap(getlocal(reward.desc),descFontSize,CCSizeMake(cellWidth-280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLb:setPosition(15+iconWidth+10,nameLb:getPositionY()-nameLb:getContentSize().height/2-10)
        descLb:setAnchorPoint(ccp(0,1))
        cell:addChild(descLb)

        local function buyHandler()
            if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{reward.name}),30)
                local function realBuy()
                    local function buyCallBack()
                       self:refresh()
                        G_showRewardTip({reward},true)
                        G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
                    end
                    ltzdzVoApi:ltzdzExploitShopBuy(self.curPage,pid,buyCallBack)
                end
                local key="ltzdz_shop_buy"
                local function secondTipFunc(flag)
                    local sValue=base.serverTime .. "_" .. flag
                    G_changePopFlag(key,sValue) 
                end
                if G_isPopBoard(key) then
                    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ladder_shopBuy",{cost..getlocal("ltzdz_feat"),reward.name}),true,realBuy,secondTipFunc)
                else
                    realBuy()
                end
            end
        end
        local priority=-(self.layerNum-1)*20-3
        local buyItem=G_createBotton(cell,ccp(cellWidth-80,cellHeight/2-20),{getlocal("code_gift")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",buyHandler,0.7,priority)
        local point=ltzdzVoApi:getMyPoint()
        local seg=ltzdzVoApi:getSegment()
        if (point<cost) or (limit>0 and buyNum>=limit) or (seg<self.curPage) or (self.qualifyingFlag==true) then --功勋值不够或者购买已达上限或者没有达到段位需求不可购买
            buyItem:setEnabled(false)
        end

        local costSp=CCSprite:createWithSpriteFrameName("ltzdzPointIcon.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        local scale=32/costSp:getContentSize().width
        costSp:setScale(scale)
        cell:addChild(costSp)
        local costLb=GetTTFLabel(cost,nameFontSize)
        costLb:setAnchorPoint(ccp(0,0.5))
        if point<cost then
            costLb:setColor(G_ColorRed)
        end
        cell:addChild(costLb)
        local costWidth=costSp:getContentSize().width*scale+costLb:getContentSize().width+10
        costSp:setPosition(cellWidth-80-costWidth/2,cellHeight/2+25)
        costLb:setPosition(costSp:getPositionX()+costSp:getContentSize().width*scale+10,costSp:getPositionY())

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

function ltzdzTab2:updateUI()
    self.qualifyingFlag=ltzdzVoApi:isQualifying() --是否在定级赛中
    self:refreshUnlockTip()
    self:refresh()
end

function ltzdzTab2:tick()
end

function ltzdzTab2:dispose( )
    self.tipKuangSp=nil
    self.curPage=1
    self.segmentSpTb={}
    self.disPlayPageTb={}
    self.qualifyingFlag=false
    self.layerNum=nil
    if self.bgLayer then
	    self.bgLayer:removeFromParentAndCleanup(true)
	end
    self.bgLayer=nil
end