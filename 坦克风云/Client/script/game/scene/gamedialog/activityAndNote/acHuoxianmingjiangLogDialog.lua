
acHuoxianmingjiangLogDialog = {}

function acHuoxianmingjiangLogDialog:new(timeLog,itemLog,itemNumLog)
	local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.timeLogTb=timeLog
    self.itemLogTb=itemLog
    self.itemNumLogTb=itemNumLog
    self.cellNum = 1
    self.cellTb = {}
    return nc
end

function acHuoxianmingjiangLogDialog:init(bgSrc,layerNum,inRect,size,titleStr)
	self.layerNum=layerNum
	self.dialogLayer=CCLayer:create()
  self.size = size 

	-- 屏蔽层
	local function tmpFunc()         
    end
    local forbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    forbidBg:setContentSize(CCSizeMake(640,G_VisibleSizeHeight))
    forbidBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))

    forbidBg:setTouchPriority(-(layerNum-1)*20-1)
    forbidBg:setOpacity(200)
    self.dialogLayer:addChild(forbidBg)

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.bgLayer=dialogBg
    self.bgSize = size

     dialogBg:ignoreAnchorPointForPosition(false)
    dialogBg:setAnchorPoint(CCPointMake(0.5,0.5))
    dialogBg:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    dialogBg:setContentSize(size)

    if titleStr~=nil then
        if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai"  or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="pt" or G_getCurChoseLanguage()=="fr" then
          self.titleLabel = GetTTFLabelWrap(titleStr,33,CCSizeMake(dialogBg:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
        else
          self.titleLabel = GetTTFLabel(titleStr,40)
        end
        self.titleLabel:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-40))
        dialogBg:addChild(self.titleLabel,2);
     end

     -- 关闭按钮
     local function close()
     	PlayEffect(audioCfg.mouseClick)    
        return self:close()
     end
     local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil)
     closeBtnItem:setPosition(0, 0)
     closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
  	dialogBg:addChild(self.closeBtn)

    local function tmpFunc()
    end
    self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,tmpFunc)
   self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-90))
   self.panelLineBg:setAnchorPoint(ccp(0.5,1))
   self.panelLineBg:setContentSize(CCSizeMake(580,size.height-100))
   self.bgLayer:addChild(self.panelLineBg)

    -- add timeLabel and eventLabel
    self:addTimeAndEventLabel()

    

     -- add 注意label和确认按钮
     self:addNoticeLabelAndSurebbtn(size)

      if SizeOfTable(self.timeLogTb)>=10 then 
           self.cellNum = 10
      else
           self.cellNum = SizeOfTable(self.timeLogTb)
      end 

      -- add Tableview
    self:initTableView()    

    self.dialogLayer:addChild(self.bgLayer)
	return self.dialogLayer

end

function acHuoxianmingjiangLogDialog:initTableView() 
     local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-310),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,150))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)
end

function acHuoxianmingjiangLogDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
      if SizeOfTable(self.timeLogTb)==0 then 
        return
      end


      if self.cellNum==SizeOfTable(self.timeLogTb) then
          return self.cellNum
      else
         return  self.cellNum+1  
      end
      
         
   elseif fn=="tableCellSizeForIndex" then
      local tmpSize
      if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage()=="ru" then
        tmpSize=CCSizeMake(400,100)
      else
       tmpSize=CCSizeMake(400,60)
      end
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
       end
       local hei
       if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage()=="ru" then
          hei=100
      else
          hei=60
      end

      if idx < self.cellNum then 
         local backSprie =CCSprite:createWithSpriteFrameName("LineCross.png")
         backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
         backSprie:ignoreAnchorPointForPosition(false);
         backSprie:setAnchorPoint(ccp(0,0));
         cell:addChild(backSprie,1)

         -- add timeItem
         local timeItem = GetTTFLabel(G_getDataTimeStr(self.timeLogTb[SizeOfTable(self.timeLogTb)-idx]),23)
         timeItem:setAnchorPoint(ccp(0,1))
         backSprie:addChild(timeItem)
         timeItem:setPosition(ccp(10,backSprie:getContentSize().height-20))

         local eventStr
         local color = G_ColorWhite
         if self.itemLogTb[SizeOfTable(self.timeLogTb)-idx]==nil then 
          return
         end
         if string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)-idx],1,1)=="h" then
          eventStr = getlocal("activity_huoxianmingjiang_log_tip1",{self.itemNumLogTb[SizeOfTable(self.timeLogTb)-idx],heroVoApi:getHeroName(self.itemLogTb[SizeOfTable(self.timeLogTb)-idx])})
          color = G_ColorYellow
         elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)-idx],1,1)=="s" then
         eventStr = getlocal("activity_huoxianmingjiang_log_tip2",{heroVoApi:getHeroName(heroCfg.soul2hero[self.itemLogTb[SizeOfTable(self.timeLogTb)-idx]]),self.itemNumLogTb[SizeOfTable(self.timeLogTb)-idx]})
           
         elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)-idx],1,1)=="p" then
          eventStr = getlocal("activity_huoxianmingjiang_log_tip3",{getlocal(propCfg[self.itemLogTb[SizeOfTable(self.timeLogTb)-idx]].name),self.itemNumLogTb[SizeOfTable(self.timeLogTb)-idx]})
         end

         local eventItem = GetTTFLabelWrap(eventStr, 23, CCSizeMake(380,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
         eventItem:setAnchorPoint(ccp(0,1))
         eventItem:setColor(color)
         backSprie:addChild(eventItem)
         eventItem:setPosition(ccp(180,backSprie:getContentSize().height-20))
       else
          local function moreItemTouch()
            if self.cellNum == 30 then 
              return
            end
            if SizeOfTable(self.timeLogTb)>= self.cellNum+10 then 
                  self.cellNum = self.cellNum + 10
            else
                  self.cellNum = SizeOfTable(self.timeLogTb)
            end
                self.tv:reloadData()
          end
          
          local capInseth = CCRect(20,20,10,10)
          local moreItem = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInseth,moreItemTouch)
          moreItem:setContentSize(CCSizeMake(self.size.width-60,50))
          moreItem:setTouchPriority(-(self.layerNum-1)*20-2)
          moreItem:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
          moreItem:setAnchorPoint(ccp(0,0))
          cell:addChild(moreItem)

           local moreItemLabel = GetTTFLabel(getlocal("activity_armsRace_showMore"),25)
          moreItem:addChild(moreItemLabel)
          moreItemLabel:setPosition(moreItem:getContentSize().width/2, moreItem:getContentSize().height/2)
         end
       self.cellTb[idx] = cell
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acHuoxianmingjiangLogDialog:addNoticeLabelAndSurebbtn(size)

    -- local function moreItemTouch()
    --   if SizeOfTable(self.timeLogTb)>= self.cellNum+10 then 
    --     self.cellNum = self.cellNum + 10
    --   else
    --     self.cellNum = SizeOfTable(self.timeLogTb)
    --   end
    --   self.tv:reloadData()
    -- end
        
    -- local capInseth = CCRect(20,20,10,10)
    -- local moreItem = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInseth,moreItemTouch)
    -- moreItem:setContentSize(CCSizeMake(size.width-28,50))
    -- moreItem:setTouchPriority(-(self.layerNum-1)*20-4)
    -- moreItem:setPosition(ccp(size.width/2,170))
    -- self.bgLayer:addChild(moreItem)

    -- local moreItemLabel = GetTTFLabel(getlocal("activity_armsRace_showMore"),25)
    -- moreItem:addChild(moreItemLabel)
    -- moreItemLabel:setPosition(moreItem:getContentSize().width/2, moreItem:getContentSize().height/2)


    local careLabel = GetTTFLabelWrap(getlocal("activity_huoxianmingjiang_care"), 25, CCSizeMake(450,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    careLabel:setColor(G_ColorRed)
    careLabel:setAnchorPoint(ccp(0,0.5))
    careLabel:setPosition(ccp(30,115))
    self.bgLayer:addChild(careLabel)

     local function itemClose()
        self:close()
    end
    local sureItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",itemClose,nil,getlocal("activity_huoxianmingjiang_queren"),25)
    local sureBtn = CCMenu:createWithItem(sureItem)
    sureBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  sureBtn:setPosition(ccp(size.width/2,55))
  self.bgLayer:addChild(sureBtn)

end

function acHuoxianmingjiangLogDialog:addTimeAndEventLabel()
    -- timelabel
    local timeLabel = GetTTFLabel(getlocal("alliance_event_time"),25)
    timeLabel:setPosition(ccp(110,self.bgSize.height-120))
    timeLabel:setColor(G_ColorGreen)
    self.bgLayer:addChild(timeLabel)

    -- evnetLabel
    local eventLabel = GetTTFLabel(getlocal("alliance_event_event"),25)
    eventLabel:setPosition(ccp(390,self.bgSize.height-120))
    eventLabel:setColor(G_ColorGreen)
    self.bgLayer:addChild(eventLabel)
end


function acHuoxianmingjiangLogDialog:close()
	self.dialogLayer:removeFromParentAndCleanup(true)
	self.closeBtn = nil
	self.layerNum = nil
	self.dialogLayer = nil
	self.titleLabel = nil
	self.bgSize = nil
	self.bgLayer = nil
	self.timeLog=nil
    self.itemLog=nil
    self.itemNumLog=nil
    self.cellNum = nil
    self.cellTb = nil
end
