ladderServerWarVsDialog = {}

function ladderServerWarVsDialog:new(warId,warIndex)
    local  nc = {}
    setmetatable(nc,self)
    self.__index=self
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.warId=warId--跨服战id
    self.warIndex=warIndex--跨服战索引
    self.vsList=nil--对战表
    self.rowServerNum=3--一行显示几个服务器名称
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWarCommon.plist")
    return nc
end

function ladderServerWarVsDialog:init(layerNum)
    self.layerNum=layerNum
    local size=CCSizeMake(580,G_VisibleSize.height-200)
    if G_isIphone5()==true then
        size=CCSizeMake(580,G_VisibleSize.height-300)
    end
    self.isTouch=false
    self.isUseAmi=true
    local function touchHander( ... )
       
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(144, 53, 1, 1),touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg)

    local function touchDialog()

    end

    local function close()
        PlayEffect(audioCfg.mouseClick)    
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-14)
    self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,10)

    self:initTableView()
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.bgLayer,self.layerNum)

    self:show()
end



--初始化对话框面板
function ladderServerWarVsDialog:initTableView()
	local bgW = self.bgLayer:getContentSize().width
	local bgH = self.bgLayer:getContentSize().height
    local bgSp1 = CCSprite:createWithSpriteFrameName("expedition_up.png")
    bgSp1:setAnchorPoint(ccp(0.5,1))
    bgSp1:setPosition(ccp(bgW/2,self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(bgSp1,2)
    bgSp1:setScaleX(self.bgSize.width/bgSp1:getContentSize().width)

    local bgSp2 = CCSprite:createWithSpriteFrameName("expedition_down.png")
    bgSp2:setAnchorPoint(ccp(0.5,0))
    bgSp2:setPosition(ccp(bgW/2,5))
    self.bgLayer:addChild(bgSp2,6)
    bgSp2:setScaleX(self.bgSize.width/bgSp2:getContentSize().width)

    local list=ladderVoApi:getAllServerWarList()
    local titalStr = ""
    local startTimeStr = ""
    local stateStr = ""
    local iconPic = ""
    local stateColor
    if self.warIndex and list and list[self.warIndex] then
    	titalStr=list[self.warIndex].title
    	stateStr=list[self.warIndex].vsState
    	startTimeStr=getlocal("serverWarLocal_beginTime",{list[self.warIndex].stStr})
    	iconPic=list[self.warIndex].iconPic
        stateColor=list[self.warIndex].stateColor
    end


    local titleLb=GetTTFLabelWrap(titalStr,35,CCSizeMake(bgW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(ccp(bgW/2,bgH-55))
    self.bgLayer:addChild(titleLb)

    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setPosition(ccp(bgW/2,bgH-90))
    self.bgLayer:addChild(lineSp)
    lineSp:setScaleX((bgW-20)/lineSp:getContentSize().width)

    local iconSp = CCSprite:createWithSpriteFrameName(iconPic)
    iconSp:setPosition(ccp(100,bgH-160))
    self.bgLayer:addChild(iconSp)
    iconSp:setScaleX(100/iconSp:getContentSize().width)
    iconSp:setScaleY(100/iconSp:getContentSize().height)

    local startTimeLb=GetTTFLabelWrap(startTimeStr,28,CCSizeMake(bgW-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    startTimeLb:setPosition(ccp(165,bgH-135))
    startTimeLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(startTimeLb)
    local flagNameLb=GetTTFLabel(getlocal("state").."：",25)
    flagNameLb:setPosition(ccp(165,bgH-180))
    flagNameLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(flagNameLb)
    local stateLb=GetTTFLabelWrap(stateStr,25,CCSizeMake(bgW-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    stateLb:setPosition(ccp(165+flagNameLb:getContentSize().width,bgH-180))
    stateLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(stateLb)
    if stateColor then
        stateLb:setColor(stateColor)
    end
    local tvBgW = bgW-20
    local tvBgH = bgH-270
    local function touchHander( ... )
    end
    local tvBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),touchHander)
    tvBgSp:setContentSize(CCSizeMake(tvBgW,tvBgH))
    tvBgSp:setPosition(ccp(bgW/2,30))
    tvBgSp:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(tvBgSp)

    local subTitleLb=GetTTFLabelWrap(getlocal("vsServerName"),30,CCSizeMake(bgW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    subTitleLb:setPosition(ccp(tvBgW/2,tvBgH-35))
    tvBgSp:addChild(subTitleLb)
    subTitleLb:setColor(G_ColorYellowPro)

    local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setPosition(ccp(tvBgW/2,tvBgH-60))
    tvBgSp:addChild(lineSp2)
    lineSp2:setScaleX((tvBgW-40)/lineSp2:getContentSize().width)

    self:getData()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvBgW,tvBgH-90),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(10)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ladderServerWarVsDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.vsList==nil then
            return 0
        end
        local listNum = SizeOfTable(self.vsList)
        return listNum
        -- return 70
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize--=CCSizeMake(self.bgLayer:getContentSize().width-40,160)
        if self["cellH"..(idx+1)]==nil then
            local list = self.vsList
            if list and list[idx+1] then
                local itemList = list[idx+1]
                local temCellH=math.floor((SizeOfTable(itemList)-1)/self.rowServerNum)*60+130
                self["cellH"..(idx+1)]=temCellH
            end
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self["cellH"..(idx+1)])
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellW = self.bgLayer:getContentSize().width-40
        local cellH = self["cellH"..(idx+1)]-5
        local list = self.vsList
        if list and list[idx+1] then    
            local itemList = list[idx+1]
			local teamNameLb=GetTTFLabelWrap(getlocal("vsteamName",{idx+1}),28,CCSizeMake(cellW-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		    teamNameLb:setPosition(ccp(30,cellH-20))
		    teamNameLb:setAnchorPoint(ccp(0,0.5))
		    cell:addChild(teamNameLb)
            teamNameLb:setColor(G_ColorYellowPro)

		    local index = 1
		    for k,v in pairs(itemList) do
		    	local lbW = 170
		    	local lbX = (index-1)%self.rowServerNum*(lbW+5)+lbW/2+20
		    	local lbY = cellH-math.floor((index-1)/self.rowServerNum)*60-70
		    	local serverName = GetServerNameByID(v)
		    	local serverNameLb=GetTTFLabelWrap(serverName,20,CCSizeMake(lbW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			    serverNameLb:setPosition(ccp(lbX,lbY))
			    serverNameLb:setAnchorPoint(ccp(0.5,0.5))
			    cell:addChild(serverNameLb,2)
		    	local serverNameBg = LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),function ( ... ) end)
		    	serverNameBg:setContentSize(CCSizeMake(lbW,55))
		    	serverNameBg:setPosition(ccp(lbX,lbY))
		    	cell:addChild(serverNameBg,1)
		    	index=index+1
		    end
        end
        return cell

    elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
    elseif fn=="ccTouchMoved" then
           self.isMoved=true
    elseif fn=="ccTouchEnded"  then
           
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end
end

function ladderServerWarVsDialog:getData()
    self.vsList=ladderVoApi:getServerWarVsListByIndex(self.warId)
end

function ladderServerWarVsDialog:close()
    if self.isUseAmi~=nil then
        local function realClose()
            return self:realClose()
        end
       local fc= CCCallFunc:create(realClose)
        local scaleTo1=CCScaleTo:create(0.1, 1.1);
       local scaleTo2=CCScaleTo:create(0.07, 0.8);

       local acArr=CCArray:create()
       acArr:addObject(scaleTo1)
       acArr:addObject(scaleTo2)
       acArr:addObject(fc)
        
       local seq=CCSequence:create(acArr)
       self.bgLayer:runAction(seq)
   else
        self:realClose()
   end
end



function ladderServerWarVsDialog:realClose()
    if self and self.guangSp then
        self.guangSp:stopAllActions()
        self.guangSp:removeFromParentAndCleanup(true)
        self.guangSp=nil
    end
    self.bgLayer:removeFromParentAndCleanup(true)
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
    self:dispose()
end

--显示面板,加效果
function ladderServerWarVsDialog:show()
    local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    local function callBack()
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setHide()
            elseif sceneController.curIndex==1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex==2 then
                worldScene:setHide()
            end
            mainUI:setHide()
        end
       base:cancleWait()
       if self.selectedIndex then
            self:openSmallExploerDialog(self.selectedIndex)
        end
    end
    table.insert(G_SmallDialogDialogTb,self)
    -- callBack()
    local callFunc=CCCallFunc:create(callBack)
       
       local scaleTo1=CCScaleTo:create(0.1, 1.1);
       local scaleTo2=CCScaleTo:create(0.07, 1);

       local acArr=CCArray:create()
       acArr:addObject(scaleTo1)
       acArr:addObject(scaleTo2)
       acArr:addObject(callFunc)
        
       local seq=CCSequence:create(acArr)
       self.bgLayer:runAction(seq)
end
function ladderServerWarVsDialog:dispose( ... )
    self.vsList=nil--对战表
    self = nil
end