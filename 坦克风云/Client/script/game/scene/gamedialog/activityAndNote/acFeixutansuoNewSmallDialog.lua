acFeixutansuoNewSmallDialog=smallDialog:new()

function acFeixutansuoNewSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self


    self.parent=nil
    self.data=nil
    self.type=0       --是配件还是碎片
    self.allTabs={}
    self.selectedTabIndex=1  --当前选中的tab
    self.oldSelectedTabIndex=1 --上一次选中的tab
    return nc
end

-- rewardList  列表信息
function acFeixutansuoNewSmallDialog:init(bgSrc,size,tmpFunc,istouch,isuseami,layerNum,reward1,reward2,title,desStr,tabStr1,tabStr2)
    
    -- self.isTouch=istouch
    self.isUseAmi=isuseami
    self.rewardList1=reward1
    self.rewardList2=reward2
    self.layerNum=layerNum

    local function tmpFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    local downBgSp = CCSprite:createWithSpriteFrameName("expedition_down.png")
    downBgSp:setAnchorPoint(ccp(0.5,0))
    downBgSp:setScaleX(self.bgLayer:getContentSize().width/downBgSp:getContentSize().width)
    downBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,7))
    self.bgLayer:addChild(downBgSp,6)




    local function close()
        if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-6)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local titleLb=GetTTFLabel(title,30)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-35))
    dialogBg:addChild(titleLb,1)
    titleLb:setColor(G_ColorYellowPro)

    local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
    -- bgSp:setAnchorPoint(ccp(0,0.5))
    bgSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-35));
    bgSp:setScaleY((titleLb:getContentSize().height+20)/bgSp:getContentSize().height)
    bgSp:setScaleX((size.width-30)/bgSp:getContentSize().width)
    dialogBg:addChild(bgSp)

    local desc = GetTTFLabelWrap(desStr,25,CCSizeMake(dialogBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desc:setAnchorPoint(ccp(0,1))
    desc:setPosition(20,dialogBg:getContentSize().height-140)
    dialogBg:addChild(desc,2)

    local panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),tmpFunc)
    panelLineBg:setAnchorPoint(ccp(0.5,0))
    panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,8))
    panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-170+30))
    self.bgLayer:addChild(panelLineBg)



    local function touchItem(idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        self.oldSelectedTabIndex=self.selectedTabIndex
        self:tabClickColor(idx)
        return self:tabClick(idx)

    end
    local commonItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    commonItem:setTag(1)
    commonItem:registerScriptTapHandler(touchItem)
    commonItem:setEnabled(false)
    self.allTabs[1]=commonItem
    local commonMenu=CCMenu:createWithItem(commonItem)
    commonMenu:setPosition(ccp(10+commonItem:getContentSize().width/2,self.bgLayer:getContentSize().height-110))
    commonMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(commonMenu,2)

    local vipItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    vipItem:setTag(2)
    vipItem:registerScriptTapHandler(touchItem)
    self.allTabs[2]=vipItem
    local vipMenu=CCMenu:createWithItem(vipItem)
    vipMenu:setPosition(ccp(10+vipItem:getContentSize().width/2*3,self.bgLayer:getContentSize().height-110))
    vipMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(vipMenu,2)

    if tabStr1 then
        local tablb=GetTTFLabelWrap(tabStr1,22,CCSizeMake(commonItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        commonItem:addChild(tablb)
        tablb:setPosition(commonItem:getContentSize().width/2,commonItem:getContentSize().height/2)
    end

    if tabStr2 then
        local tablb=GetTTFLabelWrap(tabStr2,22,CCSizeMake(vipItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        vipItem:addChild(tablb)
        tablb:setPosition(vipItem:getContentSize().width/2,vipItem:getContentSize().height/2)
    end


    local function callBack(...)
        return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack)
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-170-desc:getContentSize().height),nil)
    self.tv1:setPosition(ccp(10,30))

    self.tv1:setMaxDisToBottomOrTop(80)
    self.tv1:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv1,1)

    local function callBack(...)
        return self:eventHandler2(...)
    end
    local hd2= LuaEventHandler:createHandler(callBack)
    self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-170-desc:getContentSize().height),nil)
    self.tv2:setPosition(ccp(10,30))

    self.tv2:setMaxDisToBottomOrTop(80)
    self.tv2:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv2,1)
    self.tv2:setPosition(ccp(999333,0))

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
    self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-3)
    self.bottomforbidSp:setContentSize(CCSize(self.bgSize.width,30))
    self.bottomforbidSp:setAnchorPoint(ccp(0,0))
    self.bottomforbidSp:setPosition(0,0)
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
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    return self.dialogLayer
    
end

function acFeixutansuoNewSmallDialog:eventHandler1(handler,fn,idx,cel)
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

        for i=1,2 do
            local numIndex = idx*2+i
            if self.rewardList1[numIndex] then
                local addH = (i-1)*265
               local icon,iconScale = G_getItemIcon(self.rewardList1[numIndex],90,true,self.layerNum,nil,self.tv1)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(10+addH,self.cellHight/2)
                cell:addChild(icon)

                local name = GetTTFLabelWrap(self.rewardList1[numIndex].name,25,CCSizeMake(165,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
                name:setAnchorPoint(ccp(0,0))
                local nomePos =20
                name:setPosition(nomePos+icon:getContentSize().width*iconScale+addH,self.cellHight/2+10)
                cell:addChild(name)

                local numLb = GetTTFLabel("x"..self.rewardList1[numIndex].num,25)
                numLb:setAnchorPoint(ccp(0,1))
                numLb:setPosition(nomePos+icon:getContentSize().width*iconScale+addH,self.cellHight/2-10)
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

function acFeixutansuoNewSmallDialog:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return math.ceil(SizeOfTable(self.rewardList2)/2)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        self.cellHight = 100
        tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.cellHight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
         for i=1,2 do
            local numIndex = idx*2+i
            if self.rewardList2[numIndex] then
                local addH = (i-1)*265
               local icon,iconScale = G_getItemIcon(self.rewardList2[numIndex],90,true,self.layerNum,nil,self.tv1)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(10+addH,self.cellHight/2)
                cell:addChild(icon)

                local name = GetTTFLabelWrap(self.rewardList2[numIndex].name,25,CCSizeMake(165,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
                name:setAnchorPoint(ccp(0,0))
                local nomePos =20
                name:setPosition(nomePos+icon:getContentSize().width*iconScale+addH,self.cellHight/2+10)
                cell:addChild(name)

                local numLb = GetTTFLabel("x"..self.rewardList2[numIndex].num,25)
                numLb:setAnchorPoint(ccp(0,1))
                numLb:setPosition(nomePos+icon:getContentSize().width*iconScale+addH,self.cellHight/2-10)
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

function acFeixutansuoNewSmallDialog:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
end

function acFeixutansuoNewSmallDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
         else            
            v:setEnabled(true)
         end
    end
    if idx==1 then
        self.tv1:setPosition(ccp(10,30))
        self.tv2:setPosition(ccp(999333,0))
    else
        self.tv2:setPosition(ccp(10,30))
        self.tv1:setPosition(ccp(999333,0))
    end
    print("+++++idx",idx)

    


end

function acFeixutansuoNewSmallDialog:dispose()
    self.rewardList=nil
    self.selectedTabIndex=nil
    self.oldSelectedTabIndex=nil
    self.allTabs=nil
end