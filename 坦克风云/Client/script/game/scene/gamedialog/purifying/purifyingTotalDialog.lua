purifyingTotalDialog=commonDialog:new()

function purifyingTotalDialog:new(layerNum)
    
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.isShowTip=false
     CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/refiningImage.plist")
      CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/tankImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    return nc
end

--设置或修改每个Tab页签
function purifyingTotalDialog:resetTab()

    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end

    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
      
end

function purifyingTotalDialog:initFunctionTb()
  local function callBack1()
    PlayEffect(audioCfg.mouseClick)

    if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
    else
      --activityAndNoteDialog:closeAllDialog()
      accessoryVoApi:setSupply_lineFlag(true)
      self.tipSp:setVisible(false)
      accessoryVoApi:showAccessoryDialog(sceneGame,self.layerNum + 1)
      --,getlocal("accessory_title_2")

    end
  end
  local function callBack2()
        PlayEffect(audioCfg.mouseClick)
        -- if self.tipSp then
        --   accessoryVoApi:setSupply_lineFlag(false)
        --   self.tipSp:removeFromParentAndCleanup(true)
        -- end
        if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
        else
          --activityAndNoteDialog:closeAllDialog()
          self.tipSp:setVisible(false)
          accessoryVoApi:showSupplyDialog(self.layerNum+1)
        end

  end

   local function callBack3()
    -- if(playerVoApi:getPlayerLevel()<50)then
    --         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{50}),30)
    -- else

    --     if accessoryVoApi.dataNeedRefresh==true then
    --         local function onRequestEnd(fn,data)
    --             local ret,sData=base:checkServerData(data)
    --             if ret==true then
    --                 if sData and sData.data and sData.data.accessory then
    --                     if self and self.bgLayer then
    --                         accessoryVoApi:onRefreshData(sData.data.accessory)
    --                          require "luascript/script/game/scene/gamedialog/purifying/purifyingDialog1"
    --                         local td=purifyingDialog1:new()
    --                         local tbArr={}
    --                         local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("purifying"),true,self.layerNum+1)
    --                         sceneGame:addChild(dialog,self.layerNum+1)
    --                     end
    --                 end
    --             end
    --           end
    --         socketHelper:getAllAccesory(onRequestEnd)
    --       else
    --         require "luascript/script/game/scene/gamedialog/purifying/purifyingDialog1"
    --         local td=purifyingDialog1:new()
    --         local tbArr={}
    --         local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("purifying"),true,self.layerNum+1)
    --         sceneGame:addChild(dialog,self.layerNum+1)
    --     end
        
    -- end 

  end

  local function callBack11()
      local td=smallDialog:new()
      local str1 = getlocal("accessory_des1")
      local str2 = getlocal("accessory_des2")
      local tabStr = {" ",str2,str1," "}
      local colorTb = {nil,nil,nil,nil}
      local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
      sceneGame:addChild(dialog,self.layerNum+1)
  end
  local function callBack12()
      local td=smallDialog:new()
      local str1 = getlocal("accessory_title2_des1")
      local str2 = getlocal("accessory_title2_des2")
      local tabStr = {" ",str2,str1," "}
      local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
      sceneGame:addChild(dialog,self.layerNum+1)
  end

  local function callBack13()
      local td=smallDialog:new()
      local str1 = getlocal("purifying_des")
      local str2 = getlocal("purifying_des2")
      local str3 = getlocal("purifying_des3")
      local tabStr = {" ",str3,str2,str1," "}
      local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
      sceneGame:addChild(dialog,self.layerNum+1)
  end

  self.functionTb={
  {icon="icon_build.png",nameKey="accessory",callBack=callBack1,callBack2=callBack11},
  {icon="icon_supply_lines.png",nameKey="accessory_title_2",callBack=callBack2,callBack2=callBack12},
  }
end

--设置对话框里的tableView
function purifyingTotalDialog:initTableView()
    self:initFunctionTb()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-25-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)
    if(accessoryVoApi:getGuideStep()==0)then
        local lv=playerVoApi:getPlayerLevel()
        if(lv>=8 and lv<=10)then
            accessoryGuideMgr:setCurStep(1)
            accessoryVoApi:setGuideStep(1)
        end
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function purifyingTotalDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.functionTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(400,130)
         
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       local hei =120
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie,1)

       local mIcon=CCSprite:createWithSpriteFrameName(self.functionTb[idx+1].icon)
       mIcon:setAnchorPoint(ccp(0,0.5))
       mIcon:setPosition(ccp(10,backSprie:getContentSize().height/2))
       backSprie:addChild(mIcon)

       local qualityLb=GetTTFLabelWrap(getlocal(self.functionTb[idx+1].nameKey),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
       qualityLb:setAnchorPoint(ccp(0,0.5))
       qualityLb:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+15,backSprie:getContentSize().height/2))
       backSprie:addChild(qualityLb)

       local function callBack()
          if self.tv:getIsScrolled()==true then
              do
                  return
              end
          end
         self.functionTb[idx+1].callBack2()
       end

       local menuItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",callBack,11,nil,nil)
       local menu = CCMenu:createWithItem(menuItem);
       menu:setPosition(ccp(360,backSprie:getContentSize().height/2));
       menu:setTouchPriority(-(self.layerNum-1)*20-2);
       backSprie:addChild(menu,3)


       local function onSelectAll()
        if self.tv:getIsScrolled()==true then
            do
                return
            end
        end
         self.functionTb[idx+1].callBack()
       end
       local selectAllItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onSelectAll,nil,getlocal("allianceWar_enter"),24/0.8,101)
       selectAllItem:setAnchorPoint(ccp(1,0.5))
       selectAllItem:setScale(0.8)
       local btnLb = selectAllItem:getChildByTag(101)
       if btnLb then
          btnLb = tolua.cast(btnLb,"CCLabelTTF")
          btnLb:setFontName("Helvetica-bold")
       end
       local selectAllBtn=CCMenu:createWithItem(selectAllItem);
       selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-2);
       selectAllBtn:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height/2))
       backSprie:addChild(selectAllBtn)
       
       if idx==2 and accessoryVoApi:checkFree()==true then
           local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
           tipSp:setAnchorPoint(CCPointMake(1,0.5))
           tipSp:setPosition(ccp(selectAllItem:getContentSize().width+10,selectAllItem:getContentSize().height-10))
           tipSp:setTag(101)
           selectAllItem:addChild(tipSp)
       end

       if idx==1 then
           local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
           tipSp:setAnchorPoint(CCPointMake(1,0.5))
           tipSp:setPosition(ccp(selectAllItem:getContentSize().width+10,selectAllItem:getContentSize().height-10))
           tipSp:setTag(101)
           selectAllItem:addChild(tipSp)
           self.tipSp=tipSp
           if accessoryVoApi:getLeftECNum()>0 and accessoryVoApi:getSupply_lineFlag()==false then
            self.tipSp:setVisible(true)
            else
               self.tipSp:setVisible(false)
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

--点击tab页签 idx:索引
function purifyingTotalDialog:tabClick(idx)
       
        PlayEffect(audioCfg.mouseClick)
        
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
            self:getDataByType(idx)
            
         else
            v:setEnabled(true)
         end
    end

    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function purifyingTotalDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function purifyingTotalDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,120)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,800)
        end
    end
end

function purifyingTotalDialog:tick()
    if self and self.isShowTip~=accessoryVoApi:checkFree() then
        if self.tv then
            self.tv:reloadData()
        end
        self.isShowTip=accessoryVoApi:checkFree()
    end
end

function purifyingTotalDialog:dispose()
    self.expandIdx=nil
    self.isShowTip=false
    self.leftBtn=nil
    self.expandIdx=nil
    self.layerNum=nil
    self.isShowTip=nil
    self.tv=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/tankImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/tankImage.png")
    
    -- if G_isCompressResVersion()==true then
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.png")
    -- else
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.pvr.ccz")
    -- end
end




