acLoversDaySmallDialog=smallDialog:new()

function acLoversDaySmallDialog:new()
	local nc={
		layerNum =nil
    }
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acLoversDaySmallDialog:showTableViewSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler,awardList,awardLimitWidth,tvScaleX,tvScaleY)
      local sd=acLoversDaySmallDialog:new()
      sd:initTableViewSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler,awardList,awardLimitWidth,tvScaleX,tvScaleY)
end

function acLoversDaySmallDialog:initTableViewSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler,awardList,awardLimitWidth,tvScaleX,tvScaleY)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum = layerNum
    if tvScaleX ==nil then
    	tvScaleX = 1 
    end
    if tvScaleY ==nil then
    	tvScaleY = 1
    end
    local function touchHander()
    
    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog() end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    
    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2+10,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)
    
    local needW = 40
    local tvWidth=size.width-needW
    -- print("size.height---->",size.height)
    local tvHeight = size.height*tvScaleY-80
    local cellWidth = tvWidth
    local cellHeight = 400
    local cellHeightNum = 1
    if awardList and awardLimitWidth then
    	cellHeightNum = math.ceil(SizeOfTable(awardList)/awardLimitWidth)
    	-- print("cellHeightNum------>",cellHeightNum)
    	cellHeight = cellHeightNum *110
    end
    -- print("cellHeight----->",cellHeight)
    local contentLb=GetTTFLabelWrap(content,24,CCSizeMake(tvWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setColor(G_ColorYellowPro)
    contentLb:setPosition(ccp(size.width*0.5,size.height-115))
    dialogBg:addChild(contentLb)

    local isMoved=false
    
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local function touchDialog() end
            local tvbackSprie = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog)
		    tvbackSprie:setContentSize(CCSizeMake(cellWidth, cellHeight))
		    tvbackSprie:setAnchorPoint(ccp(0,0))
		    tvbackSprie:setOpacity(0)
		    tvbackSprie:setPosition(ccp(0,0))
		    cell:addChild(tvbackSprie)

		    for k,v in pairs(awardList) do
		    	
	            local icon,scale=G_getItemIcon(v,80,true,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
	            icon:setAnchorPoint(ccp(0,1))
	            icon:setTouchPriority(-(self.layerNum-1)*20-2)
	            icon:setPosition(ccp(30 + ((k-1)%awardLimitWidth)*105,tvbackSprie:getContentSize().height-(math.floor((k-1)/awardLimitWidth))*110-(110-80)/2))
	            tvbackSprie:addChild(icon,1)
	            local numLb=GetTTFLabel("x"..v.num,22)
	            numLb:setAnchorPoint(ccp(1,0))
	            numLb:setPosition(ccp(icon:getContentSize().width-4,4))
	            numLb:setScale(1/scale)
	            icon:addChild(numLb)
            -- G_addRectFlicker(icon,1.2/scale,1.2/scale)
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
    local hd= LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    tableView:setPosition(ccp(40/2,120))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)

    local tvbackSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchDialog)
    tvbackSprie:setContentSize(CCSizeMake(cellWidth, tvHeight+20))
    tvbackSprie:setAnchorPoint(ccp(0,0))
    tvbackSprie:setPosition(ccp(40/2,110))
    dialogBg:addChild(tvbackSprie)
    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)

    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function acLoversDaySmallDialog:dispose()
    self.tickIndex=0
    self.cellInitIndex=0
    self.isOneByOne=false
    self.loglist=nil
    self.cellHeightTb=nil
    self.cellTb=nil
end