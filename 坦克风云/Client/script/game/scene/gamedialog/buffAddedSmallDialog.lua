buffAddedSmallDialog=smallDialog:new()

function buffAddedSmallDialog:new()
	local nc={}
    nc.allTabs={}
    nc.layerNum=0
    nc.selectedTabIndex=0
    nc.oldSelectedTabIndex=0--上一次选中的tab
    nc.contentTb=nil
    nc.tv=nil
    nc.cellWidth=0
    nc.cellHeightTb=nil
    nc.descW=0
	setmetatable(nc,self)
	self.__index=self
 
	return nc
end

--contentTb 每一项的奖励，tipStrTb 每一项奖励的提示文字
function buffAddedSmallDialog:init(bgSrc,size,inRect,titleStr,tableTb,contentTb,istouch,isuseami,layerNum,callBackHandler)
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.contentTb=contentTb
    local function touchHander()
    
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)

    self:userHandler()

    local clayer=CCNode:create()
    clayer:setContentSize(CCSizeMake(size.width,1))
    self.bgLayer:addChild(clayer)

    local totalHeight=0
    if titleStr and titleStr~="" then
        local titleLb=GetTTFLabelWrap(titleStr,35,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        titleLb:setPosition(ccp(size.width/2,-totalHeight-titleLb:getContentSize().height/2-8))
        clayer:addChild(titleLb,2)
        local tlb=GetTTFLabel(titleStr,35)
        local realW=tlb:getContentSize().width
        local realH=titleLb:getContentSize().height
        if realW>titleLb:getContentSize().width then
            realW=-titleLb:getContentSize().width
        end
        local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
        titleBg:setPosition(ccp(self.bgSize.width/2,titleLb:getPositionY()))
        titleBg:setScaleY((realH+20)/titleBg:getContentSize().height)
        titleBg:setScaleX((self.bgSize.width-40)/titleBg:getContentSize().width)
        clayer:addChild(titleBg)
        totalHeight=totalHeight+titleLb:getContentSize().height+20
    end
    local sp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    sp:setAnchorPoint(ccp(0.5,1))
    sp:setPosition(ccp(self.bgSize.width/2,-totalHeight))
    clayer:addChild(sp)
    totalHeight=totalHeight+sp:getContentSize().height

    self:addTableBtn(clayer,tableTb,-totalHeight)
    self:tabClick(0)

    local tvHeight=0
    self.cellWidth=self.bgSize.width-30
    self.descW=self.cellWidth/2+20
    local maxHeight=500
    for tIdx,content in pairs(contentTb) do
        local h=0
        for cIdx,buff in pairs(content) do
            local height=self:getCellHeight(tIdx,cIdx)
            h=h+height
        end
        if h>maxHeight then
            tvHeight=maxHeight
            do break end
        elseif h>tvHeight then
            tvHeight=h
        end
    end
    totalHeight=totalHeight+tvHeight+50

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority((-(self.layerNum-1)*20-3))
    self.tv:setPosition(ccp(15,-totalHeight-15))
    clayer:addChild(self.tv,2)
    if tvHeight==maxHeight then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    local function nilFunc()
    end
    local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20,20,1,1),nilFunc)
    detailBg:setContentSize(CCSizeMake(self.cellWidth,tvHeight+30))
    detailBg:setAnchorPoint(ccp(0.5,0))
    detailBg:setPosition(ccp(self.bgSize.width/2,-totalHeight-30))
    clayer:addChild(detailBg)

    local totalHeight=totalHeight+80
    size=CCSizeMake(self.bgSize.width,totalHeight)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    clayer:setPosition(0,totalHeight-20)

    local function touchLuaSpr()
        if self.isTouch~=nil then
            -- PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==true then
                return
            end
            self:close()
        end
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function buffAddedSmallDialog:addTableBtn(dialogBg,tableTb,posY)
    local tabBtn=CCMenu:create()
    local tabIndex=0
    local tabBtnItem
    local tabCount=SizeOfTable(tableTb)
    if tableTb~=nil then
        for k,v in pairs(tableTb) do
            local lbSize=25
            tabBtnItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
            tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
            local itemSize=tabBtnItem:getContentSize()
            tabBtnItem:setPosition(ccp(25+itemSize.width/2+(k-1)*itemSize.width,posY-itemSize.height/2-5))
            local function tabClick(idx)
                return self:tabClick(idx)
            end
            tabBtnItem:registerScriptTapHandler(tabClick)
            local lb=GetTTFLabelWrap(v,lbSize,CCSizeMake((self.bgSize.width-20)/tabCount,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
            tabBtnItem:addChild(lb,1)
            lb:setTag(31)
            if k~=1 then
                lb:setColor(G_TabLBColorGreen)
            end           
            self.allTabs[k]=tabBtnItem
            tabBtn:addChild(tabBtnItem)
            tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
            tabBtnItem:setTag(tabIndex)
            tabIndex=tabIndex+1
       end
    end
    tabBtn:setPosition(0,0)
    dialogBg:addChild(tabBtn)
end

function buffAddedSmallDialog:tabClick(idx)
    self.oldSelectedTabIndex=self.selectedTabIndex    
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem=v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            local tabBtnItem=v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
    end
    self:refresh()
end

function buffAddedSmallDialog:refresh()
    if self.tv then
        self.tv:reloadData()
    end
end

function buffAddedSmallDialog:getCellHeight(tabIdx,idx)
    if self.cellHeightTb==nil then
        self.cellHeightTb={}
    end
    if self.cellHeightTb[tabIdx]==nil then
        self.cellHeightTb[tabIdx]={}
    end
    local height=0    
    if self.cellHeightTb[tabIdx][idx]==nil then
        local detailTb=self.contentTb[tabIdx]
        if detailTb and detailTb[idx] then
            local buff=detailTb[idx]
            local name=buff.key[1]
            local size=buff.key[3] or 25
            if name then
                local nameLb=GetTTFLabelWrap(name,size,CCSizeMake(self.descW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                height=nameLb:getContentSize().height+30
            end
        end
        self.cellHeightTb[tabIdx][idx]=height
    else
        height=self.cellHeightTb[tabIdx][idx]
    end

    return height
end

function buffAddedSmallDialog:addOneBuffAdded(cell,size,buffData)
    if cell and buffData and size then
        if buffData.key and buffData.key[1] and buffData.value and buffData.value[1] then
            local descStr=buffData.key[1] or ""
            local valueStr=buffData.value[1] or ""
            local dcolor=buffData.key[2] or G_ColorWhite
            local vcolor=buffData.value[2] or G_ColorWhite
            local dsize=buffData.key[3] or 25
            local vsize=buffData.value[3] or 25
            print("descStr,valueStr",descStr,valueStr)
            local descLb=GetTTFLabelWrap(descStr,dsize,CCSizeMake(self.descW,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(1,0.5))
            descLb:setPosition(ccp(size.width/2+30,size.height-10-descLb:getContentSize().height/2))
            cell:addChild(descLb)
            descLb:setColor(dcolor)
            local valueLb=GetTTFLabelWrap(valueStr,vsize,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            valueLb:setAnchorPoint(ccp(0,0.5))
            valueLb:setPosition(size.width/2+50,descLb:getPositionY())
            cell:addChild(valueLb)
            valueLb:setColor(vcolor)
        end
        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setScaleX((size.width-50)/lineSp:getContentSize().width)
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(ccp(size.width/2,0))
        cell:addChild(lineSp)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function buffAddedSmallDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.contentTb[self.selectedTabIndex+1])
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       local height=self:getCellHeight(self.selectedTabIndex+1,idx+1)
       tmpSize=CCSizeMake(self.cellWidth,height)
       return tmpSize
   elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellHeight=self.cellHeightTb[self.selectedTabIndex+1][idx+1]
        local buffData=self.contentTb[self.selectedTabIndex+1][idx+1]
        self:addOneBuffAdded(cell,CCSizeMake(self.cellWidth,cellHeight),buffData)

        return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function buffAddedSmallDialog:dispose()
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    self.allTabs={}
    self.selectedTabIndex=0
    self.oldSelectedTabIndex=0
    self.contentTb=nil
    self.tv=nil
    self.cellWidth=0
    self.cellHeightTb=nil
end