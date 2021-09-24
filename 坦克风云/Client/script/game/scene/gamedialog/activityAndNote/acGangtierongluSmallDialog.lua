--@author hj
--钢铁熔炉记录小板子

acGangtierongluSmallDialog=smallDialog:new()

function acGangtierongluSmallDialog:new( ... )
	local nc={
	}
	setmetatable(nc,self)
	self.__index=self
	return nc
end
function acGangtierongluSmallDialog:showLogDialog(size,titleStr,titleSize,loglist,timeList,titleColor,layerNum)
	local sd = acGangtierongluSmallDialog:new()
	sd:initLogDialog(size,titleStr,titleSize,loglist,timeList,titleColor,layerNum)
end
function acGangtierongluSmallDialog:initLogDialog(size,titleStr,titleSize,loglist,timeList,titleColor,layerNum)
	
    --初始化数据
    self.cellNum = SizeOfTable(loglist)
    self.isUseAmi = true
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0)) 

    --采用新式小板子
	local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,nil,nil,titleColor)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    --tableview回调
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.cellNum
        elseif fn=="tableCellSizeForIndex" then
            self.cellSize = CCSizeMake(500,self:getActualCellHeight(tolua.cast(loglist[idx+1],"CCLabelTTF"))+25)
            return self.cellSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local recordLabel = tolua.cast(loglist[idx+1],"CCLabelTTF")
            local timeLabel = tolua.cast(timeList[idx+1],"CCLabelTTF")
            local cellSize=CCSizeMake(500,self:getActualCellHeight(tolua.cast(loglist[idx+1],"CCLabelTTF"))+25)
            cellWidth = cellSize.width
            cellHeight = cellSize.height
            recordLabel:setAnchorPoint(ccp(0,1))
            timeLabel:setAnchorPoint(ccp(1,0.5))
            recordLabel:setPosition(timeLabel:getContentSize().width+15,cellHeight-10)
            timeLabel:setPosition(-10,recordLabel:getContentSize().height/2)
            recordLabel:addChild(timeLabel)
            cell:addChild(recordLabel)
            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(27,3,1,1),function ()end)
            lineSp:setScaleX((self.cellSize.width-10)/lineSp:getContentSize().width)
            lineSp:setAnchorPoint(ccp(0,1))
            lineSp:setPosition(5,5)
            cell:addChild(lineSp)
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end

    --初始化纪录tableview
    local tvWidth = 500
    local tvHeight = self.bgLayer:getContentSize().height-200

    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    -- self.tv:setPosition(0,0)
    -- self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setMaxDisToBottomOrTop(100)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(26,120)
    tvBg:addChild(self.tv)
    self.bgLayer:addChild(tvBg,2)

 
    --红色提示
    local noticeLb=GetTTFLabelWrap(getlocal("activity_xinchunhongbao_repordMax",{20}),25,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noticeLb:setAnchorPoint(ccp(0.5,0.5))
    noticeLb:setPosition(size.width/2,100)
    noticeLb:setColor(G_ColorRed)
    self.bgLayer:addChild(noticeLb)
    
    --确认按钮回调
    local function callback( ... )
        self:close()
    end

    --确认按钮
    local confirmButton = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callback,nil,getlocal("confirm"),25)
    confirmButton:setScale(0.9)
    local confirmMenu=CCMenu:createWithItem(confirmButton);
    confirmMenu:setPosition(self.bgLayer:getContentSize().width/2,40)
    confirmMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(confirmMenu)

    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

end

--根据label自适应获取cell的高度
function acGangtierongluSmallDialog:getActualCellHeight(label)
    local height = label:getContentSize().height
    return height
end
