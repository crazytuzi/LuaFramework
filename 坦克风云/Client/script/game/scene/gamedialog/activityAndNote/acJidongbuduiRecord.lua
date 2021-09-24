acJidongbuduiRecord={}
function acJidongbuduiRecord:new()
    local nc={
      bgLayer=nil,             --背景sprite
      dialogLayer,         --对话框层
      bgSize,
      isUseAmi,
      refreshData={},			--需要刷新的数据
      message,
      isSizeAmi,
    }
    setmetatable(nc,self)
    self.__index=self
--    print("base.all=",base.allShowedSmallDialog)
	self.callBack = nil
	self.recordList = 10 
    base.allShowedSmallDialog=base.allShowedSmallDialog+1
    return nc
end

function acJidongbuduiRecord:init(bg,title,layerNum,callBack,isuseami)

    self.isUseAmi=isuseami
    self.layerNum = layerNum
    self.callBack = callBack
    self.recordList = acJidongbuduiVoApi:getRecordList()
	  local function tmpFunc()
	  
	  end
	  if bg == nil then
	  	bg = "PanelHeaderPopup.png"
	  end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bg,CCRect(168, 86, 10, 10),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    local size = CCSizeMake(600,850)
    self.bgSize=size


     local function touchDialog()
      
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    self.bgLayer:setContentSize(size)
    self:show()

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
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)


    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(dialogBg:getContentSize().width-20,dialogBg:getContentSize().height-200),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv:setPosition(ccp(10,100))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(80)

    local capInSet = CCRect(20, 20, 10, 10)
    local function moreClick(hd,fn,idx)
    	if G_checkClickEnable()==false then
	          do
	              return
	          end
	      else
	          base.setWaitTime=G_getCurDeviceMillTime()
	      end 
        PlayEffect(audioCfg.mouseClick)
        self.isShowAll = true
        if self.tv then
        	 local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end

   self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInSet,moreClick)

	 self.backSprie:setContentSize(CCSizeMake(dialogBg:getContentSize().width-30, 60))
   self.backSprie:ignoreAnchorPointForPosition(false)
   self.backSprie:setAnchorPoint(ccp(0.5,0))
    --backSprie:setIsSallow(false)
   self.backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
	 self.backSprie:setPosition(ccp(dialogBg:getContentSize().width/2,15))
   dialogBg:addChild(self.backSprie,1)

  

    local moreRecord = GetTTFLabelWrap(getlocal("activity_jidongbudui_recordMore"),25,CCSizeMake(self.backSprie:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    moreRecord:setAnchorPoint(ccp(0.5,0.5))
    moreRecord:setPosition(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2)
    self.backSprie:addChild(moreRecord)

    self.noRecordList = GetTTFLabelWrap(getlocal("activity_jidongbudui_noRecordList"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordList:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordList:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height/2)
    dialogBg:addChild(self.noRecordList)

    self:updateMoreSp()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self:userHandler()

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    return self.dialogLayer
    

end
function acJidongbuduiRecord:updateMoreSp()
  local num = SizeOfTable(self.recordList)
  if self.noRecordList then
    if num <= 0 then
      self.noRecordList:setVisible(true)
    else
      self.noRecordList:setVisible(false)
    end
  end
  
  if self.backSprie then
    if num<=10 then
      self.backSprie:setVisible(false)
    else
      self.backSprie:setVisible(true)
    end
  end
  
end
function acJidongbuduiRecord:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    if self.isShowAll == true then
      if SizeOfTable(self.recordList)>=40 then
        return 40
      else
        return SizeOfTable(self.recordList)
      end
    else
      if SizeOfTable(self.recordList)>=10 then
        return 10 
      else
        return SizeOfTable(self.recordList)
      end
    end
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    self.cellHight = 60
    tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.cellHight)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local posX = self.recordList[idx+1][1]
    local posY = self.recordList[idx+1][2]

    local desc = GetTTFLabelWrap(getlocal("activity_jidongbudui_turkeyRecord",{posX,posY}),25,CCSizeMake(self.bgLayer:getContentSize().width - 180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desc:setAnchorPoint(ccp(0,0.5))
    desc:setPosition(10,self.cellHight/2)
    cell:addChild(desc,2)



    local function gotoHandler()
    	if G_checkClickEnable()==false then
	          do
	              return
	          end
	      else
	          base.setWaitTime=G_getCurDeviceMillTime()
	      end 
    	
    	if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
    		PlayEffect(audioCfg.mouseClick)
    		self.callBack(posX,posY)
        	return self:close()
        end
    end
    local gotoItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoHandler,2,getlocal("RankScene_attack"),25)
    gotoItem:setScale(0.8)
    local gotoMenu=CCMenu:createWithItem(gotoItem);
    gotoMenu:setPosition(ccp(self.bgLayer:getContentSize().width-90,self.cellHight/2))
    gotoMenu:setTouchPriority(-(self.layerNum-1)*20-3);
    cell:addChild(gotoMenu)

     local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((self.bgLayer:getContentSize().width)/lineSprite:getContentSize().width)
    lineSprite:setAnchorPoint(ccp(0.5,0.5))
    lineSprite:setScaleY(1.2)
    lineSprite:setPosition(ccp(self.bgLayer:getContentSize().width/2,3))
    cell:addChild(lineSprite,6)


    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acJidongbuduiRecord:update()
  if self.tv then
    self:updateMoreSp()
    self.recordList = acJidongbuduiVoApi:getRecordList()
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
  end
end

--显示面板,加效果
function acJidongbuduiRecord:show()
    if self.isSizeAmi==true then
        self.bgLayer:setScaleY(100/self.bgSize.height)
        local function callBack()
            base:cancleWait()
        end
        local callFunc=CCCallFunc:create(callBack)

        local scaleTo1=CCScaleTo:create(0.5,1,1)

        local acArr=CCArray:create()
        acArr:addObject(scaleTo1)
        acArr:addObject(callFunc)

        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)

    elseif self.isUseAmi~=nil then
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       local function callBack()
           base:cancleWait()
       end
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
   
   table.insert(G_SmallDialogDialogTb,self)
end

function acJidongbuduiRecord:close()
    if self.isUseAmi~=nil and self.bgLayer~=nil then
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

function acJidongbuduiRecord:realClose()
    base.allShowedSmallDialog=base.allShowedSmallDialog-1
    --print("base.allShowedSmallDialog=",base.allShowedSmallDialog)
    if base.allShowedSmallDialog<0 then
        base.allShowedSmallDialog=0
    end
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
    G_AllianceDialogTb["chatSmallDialog"]=nil
	base:removeFromNeedRefresh(self)
	if self.dialogLayer~=nil then
	    self.dialogLayer:removeFromParentAndCleanup(true)
	end
    self.bgLayer=nil
    self.dialogLayer=nil
    self.bgSize=nil
	if self.refreshData~=nil then
		for k,v in pairs(self.refreshData) do
			self.refreshData[k]=nil
		end
	end
	self.refreshData=nil
    self.message=nil
end