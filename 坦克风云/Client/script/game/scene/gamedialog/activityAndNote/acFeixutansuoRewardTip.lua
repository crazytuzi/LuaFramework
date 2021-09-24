acFeixutansuoRewardTip={}
function acFeixutansuoRewardTip:new()
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
	self.rewardList=nil
    base.allShowedSmallDialog=base.allShowedSmallDialog+1
    return nc
end

function acFeixutansuoRewardTip:init(bg,title,desc,content,size,layerNum,callBack,isuseami)

    self.isUseAmi=isuseami
    self.layerNum = layerNum
    self.callBack = callBack
    self.rewardList = content
	  local function tmpFunc()
	  end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("newSmallPanelBg.png",CCRect(170,80,22,10),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    local bSize = CCSizeMake(500,500)
    if size then
    	bSize = size
    end
    self.bgSize=bSize

    local titleBg=CCSprite:createWithSpriteFrameName("newTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(bSize.width/2,bSize.height)
    dialogBg:addChild(titleBg)


    local function touchDialog() end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    self.bgLayer:setContentSize(bSize)
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
    local closeBtnItem = GetButtonItem("newCloseBtn.png","newCloseBtn_Down.png","newCloseBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-6)
    self.closeBtn:setPosition(ccp(bSize.width-closeBtnItem:getContentSize().width-4,bSize.height-closeBtnItem:getContentSize().height-4))
    self.bgLayer:addChild(self.closeBtn,2)


    local titleLb=GetTTFLabel(title,36,"Helvetica-bold")
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLb)

    local desc = GetTTFLabelWrap(desc,25,CCSizeMake(dialogBg:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desc:setAnchorPoint(ccp(0,1))
    desc:setPosition(20,dialogBg:getContentSize().height-90)
    dialogBg:addChild(desc)
    desc:setColor(G_ColorGreen)


   --     local function forbidClick()
   
   -- end
   -- local rect2 = CCRect(0, 0, 50, 50);
   -- local capInSet = CCRect(20, 20, 10, 10);
   -- self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   -- self.topforbidSp:setTouchPriority(-(layerNum-1)*20-5)
   -- self.topforbidSp:setAnchorPoint(ccp(0,0))
   -- self.topforbidSp:setContentSize(CCSize(self.bgSize.width, (G_VisibleSize.height-self.bgSize.height)/2+150))
   -- self.topforbidSp:setPosition(0,self.bgSize.height-150)


   -- self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   -- self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-5)
   -- self.bottomforbidSp:setContentSize(CCSize(self.bgSize.width,(G_VisibleSize.height-self.bgSize.height)/2))
   -- self.bottomforbidSp:setAnchorPoint(ccp(0,1))
   -- self.bottomforbidSp:setPosition(0,0)
   -- dialogBg:addChild(self.topforbidSp)
   -- dialogBg:addChild(self.bottomforbidSp)
   -- self.bottomforbidSp:setVisible(false)
   -- self.topforbidSp:setVisible(false)


 local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
  dialogBg2:setContentSize(CCSizeMake(dialogBg:getContentSize().width-20,dialogBg:getContentSize().height-156))
  dialogBg2:setPosition(10,15)
  dialogBg2:setAnchorPoint(ccp(0,0))
  self.bgLayer:addChild(dialogBg2)

  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(dialogBg:getContentSize().width-20,dialogBg:getContentSize().height-160),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv:setPosition(ccp(10,15))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(80)


    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self:userHandler()

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    return self.dialogLayer
    

end

function acFeixutansuoRewardTip:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
     return SizeOfTable(self.rewardList)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    self.cellHight = 100
    tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,self.cellHight)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local item = self.rewardList[idx+1]

    local icon,iconScale = G_getItemIcon(item,80,true,self.layerNum,nil,self.tv)
    icon:setTouchPriority(-(self.layerNum-1)*20-3)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(10,self.cellHight/2)
    cell:addChild(icon)

    if item.isSpecial and item.isSpecial == 1 then
      G_addRectFlicker(icon,1.1/iconScale,1.1/iconScale)
    end

    local name = GetTTFLabelWrap(item.name,25,CCSizeMake(self.bgLayer:getContentSize().width - 200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    name:setAnchorPoint(ccp(0,1))
    local nomePos =10
    if G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="fr" then
        nomePos =40
    end
    local addPosx = 0
    if G_isAsia() then
      addPosx = 20
    end
    name:setPosition(addPosx + nomePos+icon:getContentSize().width*iconScale,self.cellHight-10)
    cell:addChild(name)


    local num = GetTTFLabel("x"..item.num,25)
    num:setAnchorPoint(ccp(0,0))
    num:setPosition(addPosx + 10+icon:getContentSize().width*iconScale,10)
    cell:addChild(num)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acFeixutansuoRewardTip:update()
  if self.tv then
    self:updateMoreSp()
    self.recordList = acJidongbuduiVoApi:getRecordList()
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
  end
end

--显示面板,加效果
function acFeixutansuoRewardTip:show()
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

function acFeixutansuoRewardTip:close()
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

function acFeixutansuoRewardTip:realClose()
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