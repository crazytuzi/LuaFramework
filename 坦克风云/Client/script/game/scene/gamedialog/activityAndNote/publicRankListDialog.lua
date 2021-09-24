publicRankListDialog=smallDialog:new()

function publicRankListDialog:new()
	local nc={
        tickIndex=0,
        cellInitIndex=0,
        layerNum=0,
        cellTb=nil,
    }
	setmetatable(nc,self)
	self.__index=self
	return nc
end
--titleShowNeed = {rankTitleTb,rowTb,pointTb,widthTb}
function publicRankListDialog:showRankListDialog(bgSrc,size,inRect,title,rankList,isuseami,layerNum,callBackHandler,useNewUI,isShowClose,useSureBtn,titleShowNeed)
  	local sd=publicRankListDialog:new()
	sd:initRankListDialog(bgSrc,size,inRect,title,rankList,isuseami,layerNum,callBackHandler,useNewUI,isShowClose,useSureBtn,titleShowNeed)
end

function publicRankListDialog:initRankListDialog(bgSrc,size,inRect,title,rankList,isuseami,layerNum,callBackHandler,useNewUI,isShowClose,useSureBtn,titleShowNeed)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.rankList=rankList or {}
    self.rankListNums = SizeOfTable(self.rankList)
    self.useNewUI=useNewUI
    self.subTitlePosY =  0

    local rankTitleTb = titleShowNeed[1]
    local function touchHander()   
    end
    local function closeCall( )
    	if callBackHandler then
    		callBackHandler()
    	end
    	self:close()
    end
    local dialogBg
    if useNewUI==true then
        local titleStr1,color1,tsize1
        if title then
            titleStr1=title[1] or ""
            color1=title[2] or G_ColorWhite
            tsize1=title[3] or 30
        end
        dialogBg=G_getNewDialogBg(size,titleStr1,tsize1,touchHander,layerNum,isShowClose,closeCall,color1)
    else
        dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    end
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()
    end
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    if useSureBtn then
    	--确定
	    local function cancleHandler()
	         PlayEffect(audioCfg.mouseClick)
	         if callBackHandler then
	            callBackHandler()
	         end
	         self:close()
	    end
	    local sureItem
	    if self.useNewUI==true then
	        sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",cancleHandler,2,getlocal("ok"),25/0.8)
	        sureItem:setScale(0.8)
	    else
	        sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
	    end
	    local sureMenu=CCMenu:createWithItem(sureItem);
	    sureMenu:setPosition(ccp(size.width/2,50))
	    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
	    dialogBg:addChild(sureMenu)

	    local btnLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
	    btnLine:setPosition(ccp(sureItem:getContentSize().width*0.5,sureItem:getContentSize().height+25))
	    btnLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,btnLine:getContentSize().height))
	    btnLine:setScaleX(1.2)
	    sureItem:addChild(btnLine)
	    self.btnLine = btnLine
    end
    local strSize2,titleNum = 23,SizeOfTable(rankTitleTb)
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 27
    end
    self.strSize2 = strSize2 - 3
    if rankTitleTb then----titleShowNeed = {rankTitleTb,rowTb,pointTb,widthTb}
    	

        --锚点
    	local pointxTb={}
    	if titleShowNeed[3] then
    		pointxTb=titleShowNeed[3]
    	end
    	--坐标比
    	local rowxTb = {}
    	if titleShowNeed[2] then
    		rowxTb = titleShowNeed[2]
    	end
    	--宽度设定
    	local curWidthTb = {}
    	if titleShowNeed[4] then
    		curWidthTb = titleShowNeed[4]
    	end
    	local subHeight,titlePosY = 90,0
    	for k,v in pairs(rankTitleTb) do
    		
    		local titleStr = GetTTFLabelWrap(getlocal(v),strSize2,CCSizeMake(curWidthTb[k] or 180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    		if rowxTb then
    			titleStr:setPositionX(size.width * rowxTb[k])
    			titleStr:setPositionY(size.height - subHeight)
	    	else
	    		titleStr:setPosition(ccp(size.width * 0.2 * k,size.height - subHeight))
	    	end
    		if pointxTb then
    			titleStr:setAnchorPoint(ccp(pointxTb[k],0.5))
    		end
    		dialogBg:addChild(titleStr,99)

    		if titlePosY == 0 or titlePosY > titleStr:getPositionY() - titleStr:getContentSize().height*0.5 then
    			titlePosY = titleStr:getPositionY() - titleStr:getContentSize().height*0.5
    		end
    	end

    	local titleLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
	    titleLine:setPosition(ccp(dialogBg:getContentSize().width*0.5,titlePosY - 5))
	    titleLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-15,titleLine:getContentSize().height))
	    -- titleLine:setScale(1)
	    self.subTitlePosY = titleLine:getPositionY()
	    dialogBg:addChild(titleLine)
    end
    ----------------------\\\\\\排行榜信息//////----------------------
    self.cellSize = CCSizeMake(self.bgLayer:getContentSize().width - 10,60)
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.rankListNums
        elseif fn=="tableCellSizeForIndex" then
            return  self.cellSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:initRankList(cell,idx+1,titleShowNeed)--三列显示（如果你的显示不是3列 请不要用，加个字段做判断）
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
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width - 10,self.subTitlePosY - self.btnLine:getPositionY()-3),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(5,self.btnLine:getPositionY()+3))
    dialogBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    ----------------------//////排行榜信息\\\\\\----------------------
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function( ) end)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function publicRankListDialog:initRankList(cell,idx,titleShowNeed)
	local cellSize = self.cellSize
    local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function () end)
    itemBg:setContentSize(CCSizeMake(cellSize.width,cellSize.height))
    itemBg:setAnchorPoint(ccp(0,0))
    itemBg:setPosition(ccp(0,0))
    cell:addChild(itemBg)
    if idx%2 == 0 then
    	itemBg:setOpacity(0)
    end
    local pointxTb,rowxTb,curWidthTb={},{},{}
    if titleShowNeed then
	    --锚点
    	if titleShowNeed[3] then
    		pointxTb=titleShowNeed[3]
    	end
    	--坐标比
    	if titleShowNeed[2] then
    		rowxTb = titleShowNeed[2]
    	end
    	--宽度设定
    	if titleShowNeed[4] then
    		curWidthTb = titleShowNeed[4]
    	end
    end
    local oriWidth = cellSize.width + 10    	
	local playerUid,playerName,scores = self.rankList[idx].uid,self.rankList[idx].name,self.rankList[idx].point	
    if playerUid and tonumber(playerUid)==tonumber(playerVoApi:getUid()) then
        playerName=playerVoApi:getPlayerName()
    end
	local rankNumStr = GetTTFLabel(idx,self.strSize2)
	local nameStr = GetTTFLabelWrap(playerName,self.strSize2,CCSizeMake(curWidthTb[2] or 180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	if rowxTb then
		nameStr:setPositionX(oriWidth * rowxTb[2])
		nameStr:setPositionY(cellSize.height*0.5)
	else
		nameStr:setPosition(ccp(oriWidth * 0.2,cellSize.height*0.5))
	end
	if pointxTb then
		nameStr:setAnchorPoint(ccp(pointxTb[2],0.5))
	end
	itemBg:addChild(nameStr)
	-------------------------------------------------------------------
    local scoresStr = GetTTFLabelWrap(scores,self.strSize2,CCSizeMake(curWidthTb[3] or 180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	if rowxTb then
		scoresStr:setPositionX(oriWidth * rowxTb[3])
		scoresStr:setPositionY(cellSize.height*0.5)
	else
		scoresStr:setPosition(ccp(oriWidth * 0.5,cellSize.height*0.5))
	end
	if pointxTb then
		scoresStr:setAnchorPoint(ccp(pointxTb[3],0.5))
	end
	itemBg:addChild(scoresStr)
    -------------------------------------------------------------------
    
	if rowxTb then
		rankNumStr:setPositionX(oriWidth * rowxTb[1])
		rankNumStr:setPositionY(cellSize.height*0.5)
	else
		rankNumStr:setPosition(ccp(oriWidth * 0.8,cellSize.height*0.5))
	end
	if pointxTb then
		rankNumStr:setAnchorPoint(ccp(pointxTb[1],0.5))
	end
	itemBg:addChild(rankNumStr)

	if idx < 4 then

		local rankSp=CCSprite:createWithSpriteFrameName("top"..idx..".png")
		rankSp:setPosition(getCenterPoint(rankNumStr))
		rankSp:setScale(0.8)
		rankNumStr:addChild(rankSp)

	end

	if tonumber(playerUid) == tonumber(playerVoApi:getUid()) then
		nameStr:setColor(G_ColorYellowPro)
		scoresStr:setColor(G_ColorYellowPro)
		rankNumStr:setColor(G_ColorYellowPro)
	end
end