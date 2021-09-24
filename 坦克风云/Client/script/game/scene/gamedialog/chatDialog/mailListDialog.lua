mailListDialog={

}

function mailListDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.expandIdx={}
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.normalHeight=100
    self.noMailLb=nil

    return nc
end


function mailListDialog:init(type,chatDialog,layerNum)
 self.layerNum=layerNum
 self.type=type
 base:setWait()
 self.mailListTb=G_getMailList()
 local count=SizeOfTable(self.mailListTb)
 if tonumber(count)==0 then
    local function callbackList(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
          self:refresh()
        end
    end
    socketHelper:friendsList(callbackList)
 end
 self.chatDialog=chatDialog
 
 local size=CCSizeMake(540,800)

	self.isTouch=false
    self.isUseAmi=true
	if layerNum then
		self.layerNum=layerNum
	else
		self.layerNum=4
	end
	local rect=size
	local function touchHander()

	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHander)
	self.dialogLayer=CCLayer:create()
	self.dialogLayer:setBSwallowsTouches(true)
	self.bgLayer=dialogBg
	self.bgSize=size
	self.bgLayer:setContentSize(size)

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
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
	self.bgLayer:addChild(self.closeBtn)

	local titleLb=GetTTFLabel(getlocal("mailList"),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)
    

	local function touchLuaSpr()

	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),touchLuaSpr);
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,1136)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(0)
	touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
	self.bgLayer:addChild(touchDialogBg,1);
  self:show()
	
	self.bgLayer:setPosition(getCenterPoint(sceneGame))
    
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    sceneGame:addChild(self.bgLayer,self.layerNum)
    self:initTableView()

   local noMailLb=GetTTFLabelWrap(getlocal("noMailList"),24,CCSizeMake(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
   noMailLb:setAnchorPoint(ccp(0.5,0.5))
   noMailLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
   self.bgLayer:addChild(noMailLb)
   self.noMailLb=noMailLb
  if tonumber(count)>0 then
    self.noMailLb:setVisible(false)
  end
end

--设置对话框里的tableView
function mailListDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-182),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,100))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function mailListDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.mailListTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight)

       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        self:loadCCTableViewCell(cell,idx)
        return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end
--创建或刷新CCTableViewCell
function mailListDialog:loadCCTableViewCell(cell,idx,refresh)
       
       cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight))
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
       end
       local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
       headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight-4))
       headerSprie:ignoreAnchorPointForPosition(false);
       headerSprie:setAnchorPoint(ccp(0,0));
       headerSprie:setTag(1000+idx)
       headerSprie:setIsSallow(false)
       headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
       cell:addChild(headerSprie)

       local nameLb=GetTTFLabel(self.mailListTb[idx+1].name,24)
       nameLb:setAnchorPoint(ccp(0,0.5))
       nameLb:setPosition(ccp(20,headerSprie:getContentSize().height/2))
       headerSprie:addChild(nameLb)
       
       local function removeMember()
           if G_checkClickEnable()==false then
                do
                    return
                end
            end
            
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end
            if self.type==1 then
               
               self.chatDialog:changeReciver(self.mailListTb[idx+1].name,nil,self.mailListTb[idx+1].uid)

            elseif self.type==2 then
              print("self.mailListTb[idx+1].uid",self.mailListTb[idx+1].uid,type(self.mailListTb[idx+1].uid))
               self.chatDialog:setName(self.mailListTb[idx+1].name,self.mailListTb[idx+1].uid)
            end

            self:close()
            
       end
       
       local menuItemRemove=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",removeMember,nil,getlocal("addMailList"),25)
          menuItemRemove:setAnchorPoint(ccp(0.5,0.5))
          local menuRemove=CCMenu:createWithItem(menuItemRemove)
          menuRemove:setTouchPriority(-(self.layerNum-1)*20-2)
          menuRemove:setPosition(ccp(headerSprie:getContentSize().width-menuItemRemove:getContentSize().width/2-10 ,headerSprie:getContentSize().height/2))
          headerSprie:addChild(menuRemove,1)

end


function mailListDialog:close()
  if self.isCloseing==true then
        do return end
    end
    if self.isCloseing==false then
        self.isCloseing=true
    end

    if hasAnim==nil then
        hasAnim=true
    end
    base.allShowedCommonDialog=base.allShowedCommonDialog-1
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
         if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
         end
    end
    if base.allShowedCommonDialog<0 then
        base.allShowedCommonDialog=0
    end
    if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==9 or newGuidMgr.curStep==46 or newGuidMgr.curStep==17 or newGuidMgr.curStep==35 or newGuidMgr.curStep==42) then --新手引导
            newGuidMgr:toNextStep()
    end
    local function realClose()
        return self:realClose()
    end
    if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
                if portScene.clayer~=nil then
                    if sceneController.curIndex==0 then
                        portScene:setShow()
                    elseif sceneController.curIndex==1 then
                        mainLandScene:setShow()
                    elseif sceneController.curIndex==2 then
                        worldScene:setShow()
                    end
                    mainUI:setShow()
                end
    end
     base:removeFromNeedRefresh(self) --停止刷新
   local fc= CCCallFunc:create(realClose)
   local acArr=CCArray:create()
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)

end
function mailListDialog:realClose()

    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()

end
--显示面板,加效果
function mailListDialog:show()
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
            --self:getDataByType() --只有Email使用这个方法
        end
       base:cancleWait()
   end
   base.allShowedCommonDialog=base.allShowedCommonDialog+1
   table.insert(base.commonDialogOpened_WeakTb,self)
   local callFunc=CCCallFunc:create(callBack)
   local acArr=CCArray:create()
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)
end

function mailListDialog:refresh()
  if self and self.tv then
    self.mailListTb=G_getMailList()
    self.tv:reloadData()
    if self.noMailLb then
      if SizeOfTable(self.mailListTb)>0 then
        self.noMailLb:setVisible(false)
      else
        self.noMailLb:setVisible(true)
      end
    end
  end
end

function mailListDialog:dispose()
    self.expandIdx=nil
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.bgSize=nil
    self.tv=nil
    self.expandHeight=nil
    self.normalHeight=nil
    self.extendSpTag=nil
    self.timeLbTab=nil
    self.buffTab=nil
    self.noMailLb=nil
    self=nil


end
