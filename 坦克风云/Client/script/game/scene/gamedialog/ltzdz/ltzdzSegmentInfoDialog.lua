ltzdzSegmentInfoDialog=smallDialog:new()

function ltzdzSegmentInfoDialog:new()
    local nc={
    	lastSegLayer=nil,
    	curSegLayer=nil,
    	curPage=1, --当前显示页
    	maxPage=0, --总共的页数
    	displayPageNum=5, --页面可以显示的页数
    	touchArr={},
    	touchEnable=true,
    	switchFlag=false,
        turnInterval=0.2,
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzSegmentInfoDialog:showSegmentInfoDialog(layerNum)
    local sd=ltzdzSegmentInfoDialog:new()
    sd:initSegmentInfoDialog(layerNum)
    return sd
end

function ltzdzSegmentInfoDialog:initSegmentInfoDialog(layerNum)
	self.maxPage=ltzdzVoApi:cfgSegNum()
	self.layerNum=layerNum
	self.isUseAmi=true
	self.isSizeAmi=false
    self.dialogLayer=CCLayer:create()

    local function close()
    	return self:close()
    end
    local bgSize=CCSizeMake(594,725)
    self.bgSize=bgSize
	local dialogBg=G_getNewDialogBg(bgSize,getlocal("ltzdz_segment_introduce"),30,nil,self.layerNum,true,close)
    dialogBg:setContentSize(bgSize)
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,1)

    self:show()

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local bgSp=CCSprite:create("public/ltzdz/segInfoBg.png")
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setPosition(self.bgSize.width/2,self.bgSize.height-65)
    self.bgLayer:addChild(bgSp)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setPosition(self.bgSize.width/2,self.bgSize.height-320)
    lineSp:setScaleX((self.bgSize.width-100)/lineSp:getContentSize().width)
    self.bgLayer:addChild(lineSp,2)

	local touchLayer=CCLayer:create()
    self.dialogLayer:addChild(touchLayer)
    touchLayer:setBSwallowsTouches(false)
    touchLayer:setTouchEnabled(true)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
    touchLayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-5,false)
    touchLayer:setTouchPriority(-(self.layerNum-1)*20-5)

    local clipperLayer=CCLayer:create()
    local layerPos=self.bgLayer:convertToNodeSpace(ccp(0,0))
    clipperLayer:setPosition(layerPos)
    self.bgLayer:addChild(clipperLayer)
    local clipperSize=CCSizeMake(self.bgSize.width-10,self.bgSize.height-80)
    local clipper=CCClippingNode:create()
    clipper:setContentSize(clipperSize)
    clipper:setAnchorPoint(ccp(0.5,1))
    clipper:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+self.bgSize.height/2-70)
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil) --遮罩
    clipperLayer:addChild(clipper,3)
    stencil:setPosition(0,0)

    self.clipperSize=clipperSize
    self.clipper=clipper

    -- local layerBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
    -- layerBg:setContentSize(clipperSize)
    -- layerBg:setAnchorPoint(ccp(0.5,1))
    -- layerBg:setPosition(clipper:getPosition())
    -- clipperLayer:addChild(layerBg)


    self.displayCfg={
    	{ccp(clipperSize.width/2-230,clipperSize.height-180),0.5,1},
    	{ccp(clipperSize.width/2-130,clipperSize.height-120),0.7,2},
    	{ccp(clipperSize.width/2,clipperSize.height-80),0.9,3},
    	{ccp(clipperSize.width/2+130,clipperSize.height-120),0.7,2},
    	{ccp(clipperSize.width/2+230,clipperSize.height-180),0.5,1},
	}
	self.leftCfg={ccp(clipperSize.width/2-390,clipperSize.height-240),0.1,1}
	self.rightCfg={ccp(clipperSize.width/2+390,clipperSize.height-240),0.1,1}

    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
    local midPage=math.ceil(self.displayPageNum/2)
    self.curPage=seg
	local tmpSeg=self.curPage-(midPage-1)
	if tmpSeg<1 then
		tmpSeg=tmpSeg+self.maxPage
	end
	self.segmentSpTb={}
    for i=1,self.displayPageNum do
		local segmentSp=self:createSegmentSp(tmpSeg,self.displayCfg[i][3])
		segmentSp:setPosition(self.displayCfg[i][1])
		segmentSp:setScale(self.displayCfg[i][2])
		segmentSp:setTag(i)
		self.segmentSpTb[i]=segmentSp
    	tmpSeg=tmpSeg+1
    	if tmpSeg<1 then
    		tmpSeg=self.maxPage
		elseif tmpSeg>self.maxPage then
			tmpSeg=1
    	end
    end

    self:initSegmentLayer(self.curPage)

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

function ltzdzSegmentInfoDialog:reorderSegmentSp()
    if self.segmentSpTb then
        for k,segmentSp in pairs(self.segmentSpTb) do
            segmentSp=tolua.cast(segmentSp,"LuaCCSprite")
            if segmentSp then
                self.clipper:reorderChild(segmentSp,self.displayCfg[k][3])
            end
        end
    end
end

function ltzdzSegmentInfoDialog:createSegmentSp(segment,zorder)
    local zorder=zorder or 1
	local nameStr=ltzdzVoApi:getSegName(segment)
	local function touchHandler(object,event,tag)
		if self.switchFlag==true then
			do return end
		end
		local offsetPage=tonumber(tag)-math.ceil(self.displayPageNum/2)
		if offsetPage>0 then
			self:rightPage(offsetPage)
		elseif offsetPage<0 then
			self:leftPage(math.abs(offsetPage))
		end
	end
    local segmentSp=ltzdzVoApi:getSegIcon(segment,nil,touchHandler)
    segmentSp:setScale(0.5)
	segmentSp:setTouchPriority(-(self.layerNum-1)*20-3)
	self.clipper:addChild(segmentSp,zorder)

    local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function () end)
    nameBg:setContentSize(CCSizeMake(81,40))
    nameBg:setAnchorPoint(ccp(0.5,1))
    nameBg:setPosition(segmentSp:getContentSize().width/2,0)
    segmentSp:addChild(nameBg)

    local nameLb=GetTTFLabelWrap(nameStr,26,CCSizeMake(100,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	-- nameLb:setAnchorPoint(ccp(0.5,1))
	nameLb:setPosition(getCenterPoint(nameBg))
	nameBg:addChild(nameLb)

	return segmentSp
end

function ltzdzSegmentInfoDialog:initSegmentLayer(segment)
    self.leftPageHandler,self.rightPageHandler=nil,nil
	local segLayerHeight=self.bgSize.height-340
	-- if self.curSegLayer then
	-- 	do return end
	-- end
    local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
    local everySeg=ltzdzVoApi:getEverySeg(segment)
    local titleFontSize,descFontSize=22,20
	local function nilFunc()
    end
    local segLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
    segLayer:setAnchorPoint(ccp(0.5,1))
    segLayer:setOpacity(0)
    self.curSegLayer=segLayer
	local segNameStr=ltzdzVoApi:getSegName(segment)
	local segNameLb=GetTTFLabel(segNameStr,titleFontSize)
    segNameLb:setAnchorPoint(ccp(0,0.5))
    segNameLb:setColor(G_ColorYellowPro)
    local totalSeg=0
    if segment>1 then
        totalSeg=ltzdzVoApi:getTotalSeg(segment-1,3)
    end
    local needPoint=ltzdzVoApi:getNeedPointByTotalSeg(totalSeg)
    local needPointLb=GetTTFLabel(getlocal("ltzdz_need_point",{needPoint}),titleFontSize)
    needPointLb:setAnchorPoint(ccp(0,0.5))

    local segBg=G_getTitleFadeBg(segLayer,CCSizeMake(segNameLb:getContentSize().width+needPointLb:getContentSize().width,segNameLb:getContentSize().height+5))
    segBg:setAnchorPoint(ccp(0,0.5))
    segBg:addChild(segNameLb)
    segBg:addChild(needPointLb)
    segNameLb:setPosition(6,segBg:getContentSize().height/2)
    needPointLb:setPosition(segNameLb:getPositionX()+segNameLb:getContentSize().width,segNameLb:getPositionY())

    -- segLayerHeight=segLayerHeight+segBg:getContentSize().height+20

    local segAddStr=""
    if everySeg==1 then
        segAddStr=getlocal("ltzdz_seg_addPer2",{segNameStr})
    else
        segAddStr=getlocal("ltzdz_seg_addPer",{segNameStr,getlocal("ltzdz_roman_num"..everySeg),getlocal("ltzdz_roman_num1")})
    end
    local segAddLb=GetTTFLabel(segAddStr,titleFontSize)
    segAddLb:setAnchorPoint(ccp(0,0.5))
    -- segAddLb:setColor(G_ColorYellowPro)
    segLayer:addChild(segAddLb)
    -- segLayerHeight=segLayerHeight+segAddLb:getContentSize().height+10
    

    local colorTab={G_ColorWhite,G_ColorYellowPro}
    local resBuff=ltzdzFightApi:getTitleBuff(segment,1)
    local segDes1Lb,lbheight1,segDes2Lb,lbheight2
    if resBuff>0 then
        segDes1Lb,lbheight1=G_getRichTextLabel(getlocal("ltzdz_seg_des1",{resBuff*100}),colorTab,descFontSize,500,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
        segLayer:addChild(segDes1Lb)
        segDes1Lb:setAnchorPoint(ccp(0,0.5))
        -- segLayerHeight=segLayerHeight+lbheight1+10

        segDes2Lb,lbheight2=G_getRichTextLabel(getlocal("ltzdz_seg_des2",{resBuff*100}),colorTab,descFontSize,500,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
        segLayer:addChild(segDes2Lb)
        segDes2Lb:setAnchorPoint(ccp(0,0.5))
        -- segLayerHeight=segLayerHeight+lbheight2+10
    end

    local desStr3=""
    if segment==1 then
        desStr3=getlocal("ltzdz_seg_des3_1")
    else
        desStr3=getlocal("ltzdz_seg_des3")
    end
    local segDes3Lb=GetTTFLabelWrap(desStr3,descFontSize,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local lbheight3=segDes3Lb:getContentSize().height
    segLayer:addChild(segDes3Lb)
    segDes3Lb:setAnchorPoint(ccp(0,0.5))

    local kuangWidth,kuangHeight=self.bgSize.width-60,150
    -- segLayerHeight=segLayerHeight+lbheight3+10+kuangHeight+30
    segLayer:setContentSize(CCSizeMake(self.bgSize.width,segLayerHeight))
    segLayer:setPosition(self.clipperSize.width/2,self.clipperSize.height-260)
    self.clipper:addChild(segLayer)

	local posY=segLayerHeight-segBg:getContentSize().height/2
	segBg:setPosition(40,posY)
    posY=posY-segBg:getContentSize().height/2-segAddLb:getContentSize().height/2-20
    segAddLb:setPosition(50,posY)
    posY=posY-segAddLb:getContentSize().height/2-10
    if segDes1Lb and lbheight1 then
        segDes1Lb:setPosition(100,posY)
        posY=posY-lbheight1-10
    end
    if segDes2Lb and lbheight2 then
        segDes2Lb:setPosition(100,posY)
        posY=posY-lbheight2-10
    end
    posY=posY-lbheight3/2
    segDes3Lb:setPosition(100,posY)

    local kuangSp=G_getThreePointBg(CCSizeMake(kuangWidth,kuangHeight),nilFunc,ccp(0.5,0.5),ccp(self.bgSize.width/2,kuangHeight/2+10),segLayer)
    local promptStr=getlocal("ltzdz_settlement_reward")
    local rewardsLb=GetTTFLabelWrap(promptStr,descFontSize,CCSizeMake(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	rewardsLb:setAnchorPoint(ccp(0,0.5))
	rewardsLb:setColor(G_ColorYellowPro)
	rewardsLb:setPosition(20,kuangHeight-10-rewardsLb:getContentSize().height/2)
	kuangSp:addChild(rewardsLb)
    self.kuangSp=kuangSp

    local worldPos=segLayer:convertToWorldSpace(ccp(kuangSp:getPosition()))
    local layerPos=segLayer:convertToNodeSpace(ccp(0,0))
    local sbLayer=CCLayer:create()
    sbLayer:setPosition(layerPos)
    segLayer:addChild(sbLayer,3)

    local clipperSize=CCSizeMake(kuangWidth-8,kuangHeight)
    local clipper=CCClippingNode:create()
    clipper:setContentSize(clipperSize)
    clipper:setAnchorPoint(ccp(0.5,0.5))
    clipper:setPosition(worldPos.x,worldPos.y)
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil) --遮罩
    sbLayer:addChild(clipper)
    stencil:setPosition(0,0)

    local arrowPosY=(clipperSize.height-35)/2
    local leftPos=ccp(-clipperSize.width/2,clipperSize.height/2)
    local centerPos=ccp(clipperSize.width/2,clipperSize.height/2)
    local rightPos=ccp(3*clipperSize.width/2,clipperSize.height/2)
    local outScreenPos=ccp(10000,clipperSize.height/2)
    local rewardLayerTb={}
    local curSmallSeg=1
    for i=1,everySeg do
    	local rewardLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function () end)
        rewardLayer:setOpacity(0)
    	rewardLayer:setContentSize(clipperSize)
    	if (tonumber(segment)~=tonumber(seg) and i==1) or (tonumber(segment)==tonumber(seg) and tonumber(smallLevel)==i) or (tonumber(segment)==tonumber(seg) and smallLevel==nil and i==1) then
    		rewardLayer:setPosition(centerPos)
            curSmallSeg=i
    	else
	    	rewardLayer:setPosition(outScreenPos)
    	end
	    clipper:addChild(rewardLayer)

        local smallSegNameStr=ltzdzVoApi:getSegName(segment,i)
        local smallSegNameLb=GetTTFLabelWrap(smallSegNameStr,22,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        smallSegNameLb:setAnchorPoint(ccp(0,0.5))
        smallSegNameLb:setPosition(40,arrowPosY)
        rewardLayer:addChild(smallSegNameLb)
        local tempLb=GetTTFLabel(smallSegNameStr,22)
        local realW=tempLb:getContentSize().width
        if realW>smallSegNameLb:getContentSize().width then
            realW=smallSegNameLb:getContentSize().width
        end
        local firstPosX=smallSegNameLb:getPositionX()+realW+20

        local totalSeg=ltzdzVoApi:getTotalSeg(segment,i)
        local rewardlist=ltzdzVoApi:getFinalRewards(totalSeg)
        for k,item in pairs(rewardlist) do
            local function showNewPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,item)
                return false
            end
            local iconSp,scale=G_getItemIcon(item,80,true,self.layerNum+1,showNewPropInfo)
            iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
            iconSp:setAnchorPoint(ccp(0,0.5))
            iconSp:setPosition(firstPosX+(k-1)*90,arrowPosY)
            rewardLayer:addChild(iconSp)

            local numLb=GetTTFLabel(item.num,18)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setScale(1/scale)
            numLb:setPosition(iconSp:getContentSize().width-5,3)
            iconSp:addChild(numLb)
        end
        rewardLayerTb[i]=rewardLayer
    end


    local scrollFlag=false
    local turnInterval=0.3
	local function leftPageHandler()
        if scrollFlag==true then
            do return end
        end
        scrollFlag=true
        local nextSeg=curSmallSeg-1
        if nextSeg<1 then
            -- scrollFlag=false
            -- do return end
            nextSeg=everySeg
        end
        local newSegItem=rewardLayerTb[nextSeg]
        local segItem=rewardLayerTb[curSmallSeg]
        newSegItem:setPosition(leftPos)
        local function playEndCallback()
            scrollFlag=false
            curSmallSeg=nextSeg
            segItem:setPosition(outScreenPos)
        end
        
        local mvTo1=CCMoveTo:create(turnInterval,rightPos)
        local mvTo2=CCMoveTo:create(turnInterval,centerPos)
        local callFunc=CCCallFuncN:create(playEndCallback)

        local acArr=CCArray:create()
        acArr:addObject(mvTo1)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        segItem:runAction(seq)

        local acArr1=CCArray:create()
        acArr1:addObject(mvTo2)
        local seq1=CCSequence:create(acArr1)
        newSegItem:runAction(seq1)
	end
	local function rightPageHandler()
        if scrollFlag==true then
            do return end
        end
        scrollFlag=true
        local nextSeg=curSmallSeg+1
        if nextSeg>everySeg then
            -- scrollFlag=false
            -- do return end
            nextSeg=1
        end
        local newSegItem=rewardLayerTb[nextSeg]
        local segItem=rewardLayerTb[curSmallSeg]
        newSegItem:setPosition(rightPos)
        local function playEndCallback()
            scrollFlag=false
            curSmallSeg=nextSeg
            segItem:setPosition(outScreenPos)
        end
        
        local mvTo1=CCMoveTo:create(turnInterval,leftPos)
        local mvTo2=CCMoveTo:create(turnInterval,centerPos)
        local callFunc=CCCallFuncN:create(playEndCallback)

        local acArr=CCArray:create()
        acArr:addObject(mvTo1)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        segItem:runAction(seq)

        local acArr1=CCArray:create()
        acArr1:addObject(mvTo2)
        local seq1=CCSequence:create(acArr1)
        newSegItem:runAction(seq1)
	end
    if everySeg>1 then
        self.leftPageHandler,self.rightPageHandler=leftPageHandler,rightPageHandler
        local arrowCfg={
            {startPos=ccp(30,arrowPosY),targetPos=ccp(0,arrowPosY),callback=leftPageHandler,angle=180},
            {startPos=ccp(kuangWidth-30,arrowPosY),targetPos=ccp(kuangWidth,arrowPosY),callback=rightPageHandler,angle=0}
        }
        for i=1,2 do
            local cfg=arrowCfg[i]
            local arrowBtn=GetButtonItem("vipArrow.png","vipArrow.png","vipArrow.png",cfg.callback,11,nil,nil)
            arrowBtn:setRotation(cfg.angle)
            local arrowMenu=CCMenu:createWithItem(arrowBtn)
            arrowMenu:setAnchorPoint(ccp(0.5,0.5))
            arrowMenu:setTouchPriority(-(self.layerNum-1)*20-4)
            arrowMenu:setPosition(cfg.startPos)
            kuangSp:addChild(arrowMenu)

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
    end
end

function ltzdzSegmentInfoDialog:turnPageCallBack(leftFlag)
    self.lastSegLayer=self.curSegLayer
    local leftPos=ccp(-self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    local rightPos=ccp(3*self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    local centerPos=ccp(self.clipperSize.width/2,self.lastSegLayer:getPositionY())
    self:initSegmentLayer(self.curPage)
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

function ltzdzSegmentInfoDialog:leftPage(skipPageNum)
	self.switchFlag=true
	if skipPageNum then
		skipPageNum=skipPageNum-1
	end
	local offsetIdx=2
	if self.displayPageNum<self.maxPage then
		offsetIdx=math.ceil(self.displayPageNum/2)
	end
	local leftIdx=self.curPage+offsetIdx
	if leftIdx>self.maxPage then
		leftIdx=leftIdx-self.maxPage
	end
	self.curPage=self.curPage-1
	if self.curPage<1 then
		self.curPage=self.maxPage
	end
    local segmentSp=tolua.cast(self.clipper:getChildByTag(math.ceil(self.displayPageNum/2)-1),"LuaCCSprite")
    if segmentSp then
        self.clipper:reorderChild(segmentSp,4)
    end
	local leftSegmentSp=self:createSegmentSp(leftIdx)
	leftSegmentSp:setPosition(self.leftCfg[1])
	leftSegmentSp:setScale(self.leftCfg[2])
	table.insert(self.segmentSpTb,1,leftSegmentSp)
	for i=1,self.displayPageNum+1 do
		local segmentSp=tolua.cast(self.segmentSpTb[i],"CCSprite")
		segmentSp:setTag(i)
		local targetPos,targetScale
		if i==(self.displayPageNum+1) then
			targetPos,targetScale=self.rightCfg[1],self.rightCfg[2]
		else
			targetPos,targetScale=self.displayCfg[i][1],self.displayCfg[i][2]
		end
		local acArr=CCArray:create()
		local moveTo=CCMoveTo:create(self.turnInterval,targetPos)
		local scaleTo=CCScaleTo:create(self.turnInterval,targetScale)
		acArr:addObject(moveTo)
		acArr:addObject(scaleTo)
	    local swpanAc=CCSpawn:create(acArr)
	    local function moveCallBack()
	    	if i==(self.displayPageNum+1) then
				table.remove(self.segmentSpTb,i)
	    		segmentSp:removeFromParentAndCleanup(true)
	    		if skipPageNum and skipPageNum>0 then
	    			self:leftPage(skipPageNum)
	    		else
					self.switchFlag=false
					self:turnPageCallBack(true)
                    self:reorderSegmentSp()
	    		end
	    	end
	    end
	    local callback=CCCallFunc:create(moveCallBack)
        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
	    segmentSp:runAction(seq)
	end
end

function ltzdzSegmentInfoDialog:rightPage(skipPageNum)
	self.switchFlag=true
	if skipPageNum then
		skipPageNum=skipPageNum-1
	end
	local offsetIdx=2
	if self.displayPageNum<self.maxPage then
		offsetIdx=math.ceil(self.displayPageNum/2)
	end
	local rightIdx=self.curPage-offsetIdx
	if rightIdx<1 then
		rightIdx=rightIdx+self.maxPage
	end
	self.curPage=self.curPage+1
	if self.curPage>self.maxPage then
		self.curPage=1
	end
    local segmentSp=tolua.cast(self.clipper:getChildByTag(math.ceil(self.displayPageNum/2)+1),"LuaCCSprite")
    if segmentSp then
        self.clipper:reorderChild(segmentSp,4)
    end
	local rightSegmentSp=self:createSegmentSp(rightIdx)
	rightSegmentSp:setPosition(self.rightCfg[1])
	rightSegmentSp:setScale(self.rightCfg[2])
	table.insert(self.segmentSpTb,rightSegmentSp)
	for i=(self.displayPageNum+1),1,-1 do
		local segmentSp=tolua.cast(self.segmentSpTb[i],"CCSprite")
		segmentSp:setTag(i-1)
		local targetPos,targetScale
		if i==1 then
			targetPos,targetScale=self.leftCfg[1],self.leftCfg[2]
		else
			targetPos,targetScale=self.displayCfg[i-1][1],self.displayCfg[i-1][2]
		end
		local acArr=CCArray:create()
		local moveTo=CCMoveTo:create(self.turnInterval,targetPos)
		local scaleTo=CCScaleTo:create(self.turnInterval,targetScale)
		acArr:addObject(moveTo)
		acArr:addObject(scaleTo)
	    local swpanAc=CCSpawn:create(acArr)
	    local function moveCallBack()
	    	if i==1 then
		    	table.remove(self.segmentSpTb,i)
		    	segmentSp:removeFromParentAndCleanup(true)
		    	if skipPageNum and skipPageNum>0 then
		    		self:rightPage(skipPageNum)
		    	else
					self.switchFlag=false
					self:turnPageCallBack(false)
                    self:reorderSegmentSp()
		    	end
	    	end
	    end
	    local callback=CCCallFunc:create(moveCallBack)
        local seq=CCSequence:createWithTwoActions(swpanAc,callback)
	    segmentSp:runAction(seq)
	end
end

function ltzdzSegmentInfoDialog:touchEvent(fn,x,y,touch)
	if self.switchFlag==true then
		do return end
	end
	if fn=="began" then
		if self.touchEnable==false then
			return false
		end
		table.insert(self.touchArr,touch)
		if SizeOfTable(self.touchArr)>1 then
			self.touchArr={}
			return false
		end
		self.startPos=ccp(x,y)
		return true
	elseif fn=="moved" then

	elseif fn=="ended" then
		self.touchArr={}
        local flag=false
        if self.kuangSp then
            local worldPos=self.bgLayer:convertToWorldSpace(ccp(self.kuangSp:getPosition()))
            local kuangSize=self.kuangSp:getContentSize()
            local left,right,top,bottom=worldPos.x-kuangSize.width/2,worldPos.x+kuangSize.width/2,worldPos.y+kuangSize.height/2,worldPos.y-kuangSize.height/2
            if (self.startPos.x>=left and self.startPos.x<=right and self.startPos.y>=bottom and self.startPos.y<=top) and (x>=left and x<=right and y>=bottom and y<=top) then --触摸到赛季奖励的位置
                flag=true
            end
        end
		local moveX=self.startPos.x-x
		if moveX<-100 then
            if flag==false then
                self:leftPage()
            else
                if self.leftPageHandler then
                    self:leftPageHandler()
                end
            end
		elseif moveX>100 then
            if flag==false then
                self:rightPage()
            else
                if self.rightPageHandler then
                    self.rightPageHandler()
                end
            end
		end
	else
		self.touchArr={}
	end
end
