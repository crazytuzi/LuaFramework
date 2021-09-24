acMingjiangzailinLogSmallDialog=smallDialog:new()

function acMingjiangzailinLogSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self


    self.parent=nil
    self.data=nil
    self.type=0       --是配件还是碎片
    return nc
end

-- rewardList  列表信息
function acMingjiangzailinLogSmallDialog:init(bgSrc,size,tmpFunc,istouch,isuseami,layerNum,rewardList,title,desStr,nojilu)
    
    -- self.isTouch=istouch
    -- self.isUseAmi=isuseami
    self.rewardList=rewardList
    self.layerNum=layerNum

    local function tmpFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)


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

    local titleLb=GetTTFLabel(title,25)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-35))
    dialogBg:addChild(titleLb)
    titleLb:setColor(G_ColorYellowPro)

    local desc = GetTTFLabelWrap(desStr,25,CCSizeMake(dialogBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desc:setAnchorPoint(ccp(0,1))
    desc:setPosition(20,dialogBg:getContentSize().height-75)
    dialogBg:addChild(desc)
    desc:setColor(G_ColorGreen)

    if SizeOfTable(self.rewardList)==0 then
        noTansuoLb = GetTTFLabelWrap(nojilu,25,CCSizeMake(self.bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noTansuoLb:setAnchorPoint(ccp(0.5,0.5))
        noTansuoLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
        self.bgLayer:addChild(noTansuoLb)
    end
   

   

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-120-desc:getContentSize().height),nil)
    self.tv:setPosition(ccp(10,30))

    self.tv:setMaxDisToBottomOrTop(80)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-5)
    self.bgLayer:addChild(self.tv,1)

    local function forbidClick()
   
   end
   local rect2 = CCRect(0, 0, 50, 50);
   local capInSet = CCRect(20, 20, 10, 10);
   self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   self.topforbidSp:setTouchPriority(-(layerNum-1)*20-5)
   self.topforbidSp:setAnchorPoint(ccp(0,0))
   self.topforbidSp:setContentSize(CCSize(self.bgSize.width, (G_VisibleSize.height-self.bgSize.height)/2+150))
   self.topforbidSp:setPosition(0,self.bgLayer:getContentSize().height-120-desc:getContentSize().height+30)


   self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-5)
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

function acMingjiangzailinLogSmallDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.rewardList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        self.cellHight = 140
        tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.cellHight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local item = FormatItem(self.rewardList[idx+1])
        local award = item[1]
        if award then
           local icon,iconScale = G_getItemIcon(award,100,true,self.layerNum,nil,self.tv1)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10,self.cellHight/2)
            cell:addChild(icon)

            local num = GetTTFLabel("x"..award.num,25/iconScale)
            num:setAnchorPoint(ccp(1,0))
            num:setPosition(icon:getContentSize().width-10,10)
            icon:addChild(num)

            local name = GetTTFLabelWrap(award.name,25,CCSizeMake(self.bgLayer:getContentSize().width - 200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            name:setAnchorPoint(ccp(0,1))
            local nomePos =20
            if G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="fr" then
            nomePos =40
            end
            name:setPosition(nomePos+icon:getContentSize().width*iconScale,self.cellHight-10)
            cell:addChild(name)
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

function acMingjiangzailinLogSmallDialog:dispose()
    self.rewardList=nil
end