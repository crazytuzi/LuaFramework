propDisplaySmallDialog=smallDialog:new()

function propDisplaySmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

-- rewardList  列表信息
function propDisplaySmallDialog:init(bgSrc,size,tmpFunc,istouch,isuseami,layerNum,reward1,title,desStr,btnTb)
    
    -- self.isTouch=istouch
    self.isUseAmi=isuseami
    self.rewardList1=reward1
    self.rewardList2=reward2
    self.layerNum=layerNum

    local strSize2 = 25
    local titleNeedWidth = 0
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =30
    elseif G_getCurChoseLanguage() =="ru" then
        titleNeedWidth =35
        strSize2 =21
    end

    local function tmpFunc()

    end
    local function close()
        if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
        -- PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local dialogBgWidth,dialogBgHeight = 550,150
    local desc = GetTTFLabelWrap(desStr,25,CCSizeMake(dialogBgWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    dialogBgHeight = dialogBgHeight + desc:getContentSize().height
    if SizeOfTable(btnTb)>=1 then
        dialogBgHeight = dialogBgHeight + 70
    end
    self.cellHight = 100
    local tvContentHeight = math.ceil(SizeOfTable(self.rewardList1)/2)*self.cellHight
    local tvWidth,tvHeight = dialogBgWidth-20,0
    local maxTvHeight = 450
    if tvContentHeight<maxTvHeight then
        tvHeight=tvContentHeight
    else
        tvHeight=maxTvHeight
    end
    dialogBgHeight = dialogBgHeight + tvHeight
    size = CCSizeMake(dialogBgWidth,dialogBgHeight)
    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,CCRect(168, 86, 10, 10),tmpFunc)
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn = G_getNewDialogBg(size,title,strSize2,tmpFunc,self.layerNum,true,close)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    closeBtn:setTouchPriority(-(self.layerNum-1)*20-16)

    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    -- closeBtnItem:setPosition(ccp(0,0))
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-26)
    -- self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    -- self.bgLayer:addChild(self.closeBtn,2)

    -- local titleLb=GetTTFLabel(title,strSize2)
    -- titleLb:setAnchorPoint(ccp(0.5,0.5))
    -- titleLb:setPosition(ccp(self.bgSize.width/2-titleNeedWidth,self.bgSize.height-titleLb:getContentSize().height/2-30))
    -- dialogBg:addChild(titleLb,1)
    -- titleLb:setColor(G_ColorYellowPro)

    desc:setAnchorPoint(ccp(0,1))
    desc:setPosition(20,dialogBg:getContentSize().height-80)
    dialogBg:addChild(desc,2)

    -- local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    -- lineSp:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-110-desc:getContentSize().height)
    -- dialogBg:addChild(lineSp,2)
    -- lineSp:setScale(0.9)

    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
    lineSp:setContentSize(CCSizeMake(size.width-60,lineSp:getContentSize().height))
    lineSp:setRotation(180)
    lineSp:setPosition(dialogBg:getContentSize().width/2,desc:getPositionY()-desc:getContentSize().height-10)
    dialogBg:addChild(lineSp)

    
    local function callBack(...)
        return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack)
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv1:setPosition(ccp((dialogBgWidth-tvWidth)/2,lineSp:getPositionY() - tvHeight - 10))
    self.tv1:setMaxDisToBottomOrTop(80)
    self.tv1:setTableViewTouchPriority(-(layerNum-1)*20-13)
    self.bgLayer:addChild(self.tv1,1)
    self.refreshData.tableView = self.tv1
    self:addForbidSp(dialogBg,CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),layerNum,true,nil,nil,-(layerNum-1)*20-14)

    local btnScale = 0.7
    if SizeOfTable(btnTb)==1 then
        local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setPosition(dialogBg:getContentSize().width/2,110)
        dialogBg:addChild(lineSp,2)
        lineSp:setScale(0.9)
    
    	local function touchItem(tag,object)
            btnTb[1].callback(tag)
            self:close()

    	end
		local menuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchItem,btnTb[1].tag,btnTb[1].name,30)
		menuItem:setEnabled(true);
        menuItem:setScale(btnScale)
		local menu=CCMenu:createWithItem(menuItem);
		menu:setPosition(ccp(self.bgLayer:getContentSize().width/2,55))
		menu:setTouchPriority(-(self.layerNum-1)*20-14);
		self.bgLayer:addChild(menu,3)
    else
        if SizeOfTable(btnTb)>=1 then
            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setPosition(dialogBg:getContentSize().width/2,110)
            dialogBg:addChild(lineSp,2)
            lineSp:setScale(0.9)
        end
    	for k,v in pairs(btnTb) do
    		local function touchItem(tag,object)
	            self:close()
	            v.callback(tag,object)
	    	end
    		local menuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchItem,v.tag,v.name,strSize2)
			menuItem:setEnabled(true);
            menuItem:setScale(btnScale)
			local menu=CCMenu:createWithItem(menuItem);
			menu:setPosition(ccp(self.bgLayer:getContentSize().width/4*(2*k-1),55))
			menu:setTouchPriority(-(self.layerNum-1)*20-14);
			self.bgLayer:addChild(menu,3)
    	end
    end


    local function forbidClick()
    end
    local rect2 = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
    self.topforbidSp:setAnchorPoint(ccp(0,0))
    self.topforbidSp:setContentSize(CCSize(self.bgSize.width, (G_VisibleSize.height-self.bgSize.height)/2+140))
    self.topforbidSp:setPosition(0,self.bgLayer:getContentSize().height-120-desc:getContentSize().height)


    self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.bottomforbidSp:setAnchorPoint(ccp(0,1))
    self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-3)
    self.bottomforbidSp:setContentSize(CCSize(self.bgSize.width,130))
    self.bottomforbidSp:setPosition(0,130)
    dialogBg:addChild(self.topforbidSp)
    dialogBg:addChild(self.bottomforbidSp)
    self.bottomforbidSp:setVisible(false)
    self.topforbidSp:setVisible(false)

    self:show()

    
    local function touchDialog()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
      
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-10)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setIsSallow(true)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-11)
    self:userHandler()
    return self.dialogLayer
    
end

function propDisplaySmallDialog:eventHandler1(handler,fn,idx,cel)
    local strSize2 = 20
    if G_isAsia() then
        strSize2 =25
    elseif G_getCurChoseLanguage() =="ru" then
        strSize2 =16
    end
    if fn=="numberOfCellsInTableView" then
        return math.ceil(SizeOfTable(self.rewardList1)/2)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        self.cellHight = 100
        tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.cellHight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local iconWidth = 90
        for i=1,2 do
            local numIndex = idx*2+i
            if self.rewardList1[numIndex] then
                local addH = (i-1)*265
                local icon,iconScale
                if self.rewardList1[numIndex].type == "w" then
                    strSize2 = 18
                end
                if self.rewardList1[numIndex].type == "se" then
                    icon,iconScale = G_getItemIcon(self.rewardList1[numIndex],100,true,self.layerNum,nil,self.tv1,nil,nil,nil,nil,true,true)
                else
                    icon,iconScale = G_getItemIcon(self.rewardList1[numIndex],100,true,self.layerNum,nil,self.tv1,nil,nil,nil,nil,nil,true)
                end
                icon:setScale(iconWidth/icon:getContentSize().width)
                icon:setTouchPriority(-(self.layerNum-1)*20-12)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(10+addH,self.cellHight/2)
                cell:addChild(icon)

                local name = GetTTFLabelWrap(self.rewardList1[numIndex].name,strSize2,CCSizeMake(155,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                name:setAnchorPoint(ccp(0,1))
                name:setColor(G_ColorYellowPro)
                local nomePos =20
                name:setPosition(nomePos+icon:getContentSize().width*iconScale+addH - 10,icon:getPositionY()+icon:getContentSize().height*iconScale*0.5-5)
                cell:addChild(name)
                local numLb = GetTTFLabel("x"..FormatNumber(self.rewardList1[numIndex].num),22)
                numLb:setAnchorPoint(ccp(0,1))
                numLb:setPosition(nomePos+icon:getContentSize().width*iconScale+addH - 10,self.cellHight/2-20)
                cell:addChild(numLb)
            end
        end
        
    
        
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function propDisplaySmallDialog:dispose()
    self.rewardList=nil
end

