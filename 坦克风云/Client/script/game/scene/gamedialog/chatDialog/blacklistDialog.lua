blacklistDialog={

}

function blacklistDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.expandIdx={}
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.bgSize=nil
    self.tv=nil
    self.tv2=nil
    self.normalHeight=100
    self.extendSpTag=113
    self.timeLbTab={}
    self.isCloseing=false
    self.blacklistTb={}
    self.numLb=nil
    self.selectedTabIndex=0

    return nc
end

--设置或修改每个Tab页签
function blacklistDialog:resetTab()

    self.allTabs={getlocal("blackList"),getlocal("mailList")}


    self:initTab(self.allTabs)
    local index=0
    local height = self.bgLayer:getContentSize().height
    local height1 =90
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
            tabBtnItem:setPosition(100,height-tabBtnItem:getContentSize().height/2-height1)
         elseif index==1 then
            tabBtnItem:setPosition(248,height-tabBtnItem:getContentSize().height/2-height1)
         elseif index==2 then
            tabBtnItem:setPosition(394,height-tabBtnItem:getContentSize().height/2-height1)
         elseif index==3 then
            tabBtnItem:setPosition(540,height-tabBtnItem:getContentSize().height/2-height1)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
end

function blacklistDialog:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,24,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
       lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
       
       
        local numHeight=25
      local iconWidth=36
      local iconHeight=36
        local newsNumLabel = GetTTFLabel("0",numHeight)
        newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
        newsNumLabel:setTag(11)
          local capInSet1 = CCRect(17, 17, 1, 1)
          local function touchClick()
          end
          local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
      if newsNumLabel:getContentSize().width+10>iconWidth then
        iconWidth=newsNumLabel:getContentSize().width+10
      end
          newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
        newsIcon:ignoreAnchorPointForPosition(false)
        newsIcon:setAnchorPoint(CCPointMake(1,0.5))
          newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2,tabBtnItem:getContentSize().height-30))
          newsIcon:addChild(newsNumLabel,1)
      newsIcon:setTag(10)
        newsIcon:setVisible(false)
        tabBtnItem:addChild(newsIcon)
       
       --local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
           local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
       lockSp:setAnchorPoint(CCPointMake(0,0.5))
       lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
       lockSp:setScaleX(0.7)
       lockSp:setScaleY(0.7)
       tabBtnItem:addChild(lockSp,3)
       lockSp:setTag(30)
       lockSp:setVisible(false)
      
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn)

end

function blacklistDialog:init(layerNum)
 self.layerNum=layerNum
 base:setWait()
 
 self.blacklistTb=G_getBlackList()
 self.mailListTb=G_getMailList()

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

	local titleLb=GetTTFLabel(getlocal("mailListManage"),40)
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
	
	self.bgLayer:setPosition(getCenterPoint(sceneGame))
    
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
    sceneGame:addChild(self.bgLayer,self.layerNum)

    self:show()
    self:initLayer1()
    -- self:initLayer2()

    

    self:resetTab()


	--return self.bgLayer
end

function blacklistDialog:initLayer1()
    self.bgLayer1=CCLayer:create()
    self.bgLayer:addChild(self.bgLayer1)

    self.bgLayer1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))

    if SizeOfTable(self.blacklistTb)==0 then
       local nameLb=GetTTFLabelWrap(getlocal("noBlackList"),24,CCSizeMake(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
       nameLb:setAnchorPoint(ccp(0.5,0.5))
       nameLb:setPosition(ccp(self.bgLayer1:getContentSize().width/2,self.bgLayer1:getContentSize().height/2))
       self.bgLayer1:addChild(nameLb)
       self.nameLb1=nameLb

    end
    
    self.numLb=GetTTFLabel(SizeOfTable(self.blacklistTb).."/"..G_blackListNum,30)
    self.numLb:setAnchorPoint(ccp(0.5,0.5))
    self.numLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,40))
    self.bgLayer1:addChild(self.numLb)

    local function addBackList()
      if G_checkClickEnable()==false then
            do
                return
            end
      end
      PlayEffect(audioCfg.mouseClick)
      local function searchHandle(searchStr,flag)
        if searchStr==nil or searchStr=="" then
          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_enterNo"),30)
        end
        if flag and self.tv then
           self.blacklistTb=G_getBlackList()
           if SizeOfTable(self.blacklistTb)~=0 then
              if self.nameLb1 then
                self.nameLb1:setVisible(false)
              end
           end
            if self.tv then
                local recordPoint=self.tv:getRecordPoint()
                self.tv:reloadData()
                if self.blacklistTb and SizeOfTable(self.blacklistTb)>5 then
                    self.tv:recoverToRecordPoint(recordPoint)
                end
            end
            self.numLb=tolua.cast(self.numLb,"CCLabelTTF")
            self.numLb:setString(SizeOfTable(self.blacklistTb).."/"..G_blackListNum)
        end
        
      end
      allianceSmallDialog:allianceSearchDialog("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,searchHandle,1,1)
    end
    if  base.mailBlackList==1 then
       local addBtn=GetButtonItem("cin_forbid_add_btn.png","cin_forbid_add_btn_Down.png","cin_forbid_add_btn_Down.png",addBackList,14,nil,nil)
      local addSpriteMenu=CCMenu:createWithItem(addBtn)
      addSpriteMenu:setAnchorPoint(ccp(0.5,0))
      addSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer1:addChild(addSpriteMenu)
      addSpriteMenu:setPosition(self.bgLayer:getContentSize().width-55, 50)
    end
   

    self:initTableView()
end

function blacklistDialog:initLayer2()
    self.bgLayer2=CCLayer:create()
    self.bgLayer:addChild(self.bgLayer2)

    self.bgLayer2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))

    self.mailListTb=G_getMailList()
    if SizeOfTable(self.mailListTb)==0 then
       local nameLb=GetTTFLabelWrap(getlocal("noMailList"),24,CCSizeMake(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
       nameLb:setAnchorPoint(ccp(0.5,0.5))
       nameLb:setPosition(ccp(self.bgLayer2:getContentSize().width/2,self.bgLayer2:getContentSize().height/2))
       self.bgLayer2:addChild(nameLb)
       self.nameLb2=nameLb
    end
    
    self.numLb2=GetTTFLabel(SizeOfTable(self.mailListTb).."/"..G_mailListNum,30)
    self.numLb2:setAnchorPoint(ccp(0.5,0.5))
    self.numLb2:setPosition(ccp(self.bgLayer:getContentSize().width/2,40))
    self.bgLayer2:addChild(self.numLb2)
    self.bgLayer2:setPosition(ccp(10000,0))
    self.bgLayer2:setVisible(false)



    local function addBackList()
      if G_checkClickEnable()==false then
            do
                return
            end
      end
      PlayEffect(audioCfg.mouseClick)
      local function searchHandle(searchStr,flag)
        if searchStr==nil or searchStr=="" then
          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_enterNo"),30)
        end
        if flag and self.tv2 then
            self.mailListTb=G_getMailList()
           if SizeOfTable(self.mailListTb)~=0 then
              if self.nameLb2 then
                self.nameLb2:setVisible(false)
              end
           end
            if self.tv2 then
                local recordPoint=self.tv2:getRecordPoint()
                self.tv2:reloadData()
                if self.mailListTb and SizeOfTable(self.mailListTb)>5 then
                    self.tv2:recoverToRecordPoint(recordPoint)
                end
            end
            self.numLb2=tolua.cast(self.numLb2,"CCLabelTTF")
            self.numLb2:setString(SizeOfTable(self.mailListTb).."/"..G_mailListNum)
        end
        
      end
      allianceSmallDialog:allianceSearchDialog("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,searchHandle,1,2)
    end

    local addBtn=GetButtonItem("cin_forbid_add_btn.png","cin_forbid_add_btn_Down.png","cin_forbid_add_btn_Down.png",addBackList,14,nil,nil)
    local addSpriteMenu=CCMenu:createWithItem(addBtn)
    addSpriteMenu:setAnchorPoint(ccp(0.5,0))
    addSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer2:addChild(addSpriteMenu)
    addSpriteMenu:setPosition(self.bgLayer:getContentSize().width-55, 50)







    self:initTableView2()
end

function blacklistDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
    end

    if self.selectedTabIndex==0 then
        if self.bgLayer1==nil then
            self:initLayer1()
        end
        self.bgLayer1:setPosition(ccp(0,0))
        self.bgLayer1:setVisible(true)
        if self.bgLayer2 then
            self.bgLayer2:setPosition(ccp(10000,0))
            self.bgLayer2:setVisible(false)
        end
    elseif self.selectedTabIndex==1 then
        if self.bgLayer1 then
            self.bgLayer1:setPosition(ccp(10000,0))
            self.bgLayer1:setVisible(false)
        end
        local flag=friendMailVoApi:getFlag()
        if flag==-1 then
            local function callbackList(fn,data)
            local ret,sData=base:checkServerData(data)
                if ret==true then
                    if self.bgLayer2==nil then
                        self:initLayer2()
                    end
                    self.bgLayer2:setPosition(ccp(0,0))
                    self.bgLayer2:setVisible(true)
                end
            end
            socketHelper:friendsList(callbackList)
        else
            if self.bgLayer2==nil then
                self:initLayer2()
            end
            self.bgLayer2:setPosition(ccp(0,0))
            self.bgLayer2:setVisible(true)
        end
    end
    --self.tv:reloadData()
end


--设置对话框里的tableView
function blacklistDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-242),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,100))
    self.bgLayer1:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function blacklistDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.blacklistTb)
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
function blacklistDialog:loadCCTableViewCell(cell,idx,refresh)
       
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

       local nameLb=GetTTFLabel(self.blacklistTb[idx+1].name,24)
       nameLb:setAnchorPoint(ccp(0,0.5))
       nameLb:setPosition(ccp(20,headerSprie:getContentSize().height/2))
       headerSprie:addChild(nameLb)
       
       local function removeMember()
           if G_checkClickEnable()==false then
                do
                    return
                end
            end
            
            if self.tv and self.tv:getIsScrolled()==true then
                do
                    return
                end
            end
            
           
           local function removeM()
               local function removeMemCallback()
                    self.blacklistTb=G_getBlackList()
                    if self.tv then
                        local recordPoint=self.tv:getRecordPoint()
                        self.tv:reloadData()
                        if self.blacklistTb and SizeOfTable(self.blacklistTb)>5 then
                            self.tv:recoverToRecordPoint(recordPoint)
                        end
                    end
                    self.numLb=tolua.cast(self.numLb,"CCLabelTTF")
                    self.numLb:setString(SizeOfTable(self.blacklistTb).."/"..G_blackListNum)
               end
               G_removeMemberInBlackListByUid(self.blacklistTb[idx+1].uid,removeMemCallback)
           end
           
           smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),removeM,getlocal("dialog_title_prompt"),getlocal("removeBlackSure"),nil,self.layerNum+1)
       end
       
       local menuItemRemove=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",removeMember,nil,getlocal("removeBlackList"),25)
          menuItemRemove:setAnchorPoint(ccp(0.5,0.5))
          local menuRemove=CCMenu:createWithItem(menuItemRemove)
          menuRemove:setTouchPriority(-(self.layerNum-1)*20-2)
          menuRemove:setPosition(ccp(headerSprie:getContentSize().width-menuItemRemove:getContentSize().width/2-10 ,headerSprie:getContentSize().height/2))
          headerSprie:addChild(menuRemove,1)

end

--设置对话框里的tableView
function blacklistDialog:initTableView2()
    local function callBack(...)
       return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-242),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(10,100))
    self.bgLayer2:addChild(self.tv2)
    self.tv2:setMaxDisToBottomOrTop(80)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function blacklistDialog:eventHandler2(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.mailListTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight)

       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        self:loadCCTableViewCell2(cell,idx)
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
function blacklistDialog:loadCCTableViewCell2(cell,idx,refresh)
       
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
            
            if self.tv2 and self.tv2:getIsScrolled()==true then
                do
                    return
                end
            end
            
           
           local function removeM()
               local function callback(fn,data)
                  local ret,sData=base:checkServerData(data)
                  if ret==true then
                      friendMailVoApi:delFriendByUid(self.mailListTb[idx+1].uid)
                      -- G_removeMemberInMailListByUid(self.mailListTb[idx+1].uid)
                      self.mailListTb=G_getMailList()
                      if self.tv2 then
                          self.tv2:reloadData()
                      end
                      self.numLb2=tolua.cast(self.numLb2,"CCLabelTTF")
                      self.numLb2:setString(SizeOfTable(self.mailListTb).."/"..G_mailListNum)
                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("delFriendSuccess"),30)
                  end
               end
               if self.mailListTb and self.mailListTb[idx+1] then
                 socketHelper:friendsDel(self.mailListTb[idx+1].uid,self.mailListTb[idx+1].name,callback)
               end


               --self.mailListTb=G_getMailList()
               --self.tv2:reloadData()
               --self.numLb2=tolua.cast(self.numLb2,"CCLabelTTF")
               --self.numLb2:setString(SizeOfTable(self.mailListTb).."/"..G_mailListNum)

                

           end

           smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),removeM,getlocal("dialog_title_prompt"),getlocal("removeMailSure"),nil,self.layerNum+1)
       end
       
       local menuItemRemove=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",removeMember,nil,getlocal("removeBlackList"),25)
          menuItemRemove:setAnchorPoint(ccp(0.5,0.5))
          local menuRemove=CCMenu:createWithItem(menuItemRemove)
          menuRemove:setTouchPriority(-(self.layerNum-1)*20-2)
          menuRemove:setPosition(ccp(headerSprie:getContentSize().width-menuItemRemove:getContentSize().width/2-10 ,headerSprie:getContentSize().height/2))
          headerSprie:addChild(menuRemove,1)

end


function blacklistDialog:close()
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
   local moveTo=CCMoveTo:create((hasAnim==true and 0.3 or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
   local acArr=CCArray:create()
   acArr:addObject(moveTo)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)

end
function blacklistDialog:realClose()

    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()

end
--显示面板,加效果
function blacklistDialog:show()
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
            --self:getDataByType() --只有Email使用这个方法
        end
       base:cancleWait()
   end
   base.allShowedCommonDialog=base.allShowedCommonDialog+1
   table.insert(base.commonDialogOpened_WeakTb,self)
   local callFunc=CCCallFunc:create(callBack)
   local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
   self.bgLayer:runAction(seq)
end
function blacklistDialog:dispose()
    self.expandIdx=nil
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.bgSize=nil
    self.tv=nil
    self.tv2=nil
    self.expandHeight=nil
    self.normalHeight=nil
    self.extendSpTag=nil
    self.timeLbTab=nil
    self.buffTab=nil
    self.nameLb1=nil
    self.nameLb2=nil
    self=nil


end
