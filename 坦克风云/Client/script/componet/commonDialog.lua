commonDialog={}

function commonDialog:new()
    local nc={
      bgLayer=nil,             --背景sprite
      dialogLayer,         --对话框层
      allTabs={},          --所有的tab页签
      allSubTabs={},          --所有的subTab页签
      bgSize,              --背景尺寸 如果是充满全屏 按照768*1024处理
      tv,                  --cctableView
      selectedTabIndex=0,  --当前选中的tab
      selectedSubTabIndex=0,  --当前选中的subtab
      isMoved=false,       --当前tableview是否被拖动了
      needExpandCellIndex=-1, --当前需要展开的tableViewCell
      titleLabel=nil, --title
      closeBtn, --关闭按钮
      topforbidSp, --顶端遮挡层
      bottomforbidSp, --底部遮挡层
      panelLineBg,--底框
      isCloseing=false,
      oldSelectedTabIndex=0,--上一次选中的tab
      overDayEventListener = nil, --跨天事件监听器
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end 
--bgSrc:背景图片路径 isfullScreen:是否全屏 size:如果不是全屏用来设置背景图片宽高 tabTb:tab页签信息 closeBtnSrc:关闭按钮图片路径 needRefresh:是否需要动态刷新，isuseami：是否需要向上拉的动画，moveEndCallBack：向上拉的动画执行完成后的回调
--tabType : 页签类型
function commonDialog:init(bgSrc,isfullScreen,size,fullRect,inRect,tabTb,subTabTb,closeBtnSrc,titleStr,needRefresh,layerNum,isuseami,moveEndCallBack,tabType)
      base:setWait()
      if needRefresh~=nil and needRefresh then
         base:addNeedRefresh(self)
      end
      
      if layerNum==nil then
         layerNum=3
      end
      self.layerNum=layerNum
      self.moveEndCallBack=moveEndCallBack
      local rect=CCSizeMake(1,1)
      local function tmpFunc()
      
      
      end
      local forbidBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
       forbidBg:setContentSize(CCSizeMake(640,1136))
       forbidBg:ignoreAnchorPointForPosition(false)
       forbidBg:setAnchorPoint(CCPointMake(0,0))
       forbidBg:setTouchPriority(-(layerNum-1)*20-1)
       forbidBg:setVisible(false)
      local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
      --local clayer=CCLayer:create()
   self.bgLayer=dialogBg
   
      
   
   self.dialogLayer=CCLayer:create()
   self.dialogLayer:addChild(forbidBg)
      if isfullScreen then
           rect=CCSizeMake(640,G_VisibleSize.height)
      elseif size then
           rect=size
      end
     self.bgSize=rect
--        self.bgLayer:setScaleX(G_VisibleSize.width/640)
--        self.bgLayer:setScaleY(G_VisibleSize.height/960)

      dialogBg:setContentSize(rect)
   dialogBg:ignoreAnchorPointForPosition(false)
      dialogBg:setAnchorPoint(CCPointMake(0.5,0.5))

      self.isuseami=(isuseami==nil) and true or isuseami
      if self.isuseami==true then
        dialogBg:setPosition(CCPointMake(G_VisibleSize.width/2,-G_VisibleSize.height/2))
      else
        dialogBg:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
      end

      -- 添加黑色遮罩
      G_addBlackLayer(dialogBg,255)
      local sbDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
      sbDialogBg:setContentSize(dialogBg:getContentSize())
      dialogBg:addChild(sbDialogBg)
      sbDialogBg:setPosition(getCenterPoint(sbDialogBg))
      dialogBg:setOpacity(0)


      if titleStr~=nil then
        if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai"  or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="pt" or G_getCurChoseLanguage()=="fr" then
          self.titleLabel = GetTTFLabelWrap(titleStr,32,CCSizeMake(dialogBg:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold");
        else
          self.titleLabel = GetTTFLabel(titleStr,32,true)
        end
        self.titleLabel:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-40))
          dialogBg:addChild(self.titleLabel,2);
      end
      
   self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,tmpFunc)
   self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
   self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-180))
   self.bgLayer:addChild(self.panelLineBg)

    self.panelShadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png", CCRect(30, 2, 2, 10), function ()end)
    self.panelShadeBg:setAnchorPoint(ccp(0.5, 1))
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight-87))
    self.panelShadeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight-82)
    self.bgLayer:addChild(self.panelShadeBg)
    self.panelShadeBg:setVisible(false)
   
   --新版界面中顶部tab页签的线条，如果要使用请setVisible(true)，并且self.panelLineBg:setVisible(false)
   self.panelTopLine = LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,1,2,1),function()end)
   self.panelTopLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,7))
   self.panelTopLine:setAnchorPoint(ccp(0.5,1))
   self.panelTopLine:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-155))
   self.panelTopLine:setVisible(false)
   self.bgLayer:addChild(self.panelTopLine)
   self.topShadeBg = G_addCommonGradient(self.panelTopLine,self.panelTopLine:getContentSize().height)

   --添加底部金属边框
   if bgSrc == "panelBg.png" and isfullScreen then
     local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgBottom.png", CCRect(34, 32, 2, 6), function ()end)
     bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, bottomBg:getContentSize().height))
     bottomBg:setAnchorPoint(ccp(0.5, 0))
     bottomBg:setPosition(G_VisibleSizeWidth / 2, 0)
     self.bgLayer:addChild(bottomBg, 3)
     self.panelBottomLine = bottomBg
   end

    local function close()
        PlayEffect(audioCfg.mouseClick)    
        if type(self.checkCloseHandler) == "function" then
          self:checkCloseHandler()
          do return end
        end
        return self:close()
     end
   local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
  self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
  dialogBg:addChild(self.closeBtn)

   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do
           local lbSize=28
           if #tabTb==4 then
                tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
                lbSize=28
           elseif #tabTb==2 then
              if tabType == 1 then
                tabBtnItem = CCMenuItemImage:create("tabChooseButton.png", "tabChooseButton_down.png","tabChooseButton_down.png")
              else
                tabBtnItem = CCMenuItemImage:create("tabBtnBig.png", "tabBtnBig_Selected.png","tabBtnBig_Selected.png")
              end
           else
                tabBtnItem = CCMenuItemImage:create("tabBtnSmall.png", "tabBtnSmall_Selected.png","tabBtnSmall_Selected.png")
           end
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               self.oldSelectedTabIndex=self.selectedTabIndex
               self:tabClickColor(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,lbSize,CCSizeMake((self.bgLayer:getContentSize().width-20)/SizeOfTable(tabTb),0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb,1)
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
        --newsNumLabel:setColor(G_ColorRed) 
          local capInSet1 = CCRect(17, 17, 1, 1)
          local function touchClick()
          end
          local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
      if newsNumLabel:getContentSize().width+10>iconWidth then
        iconWidth=newsNumLabel:getContentSize().width+10
      end
          newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
        newsIcon:ignoreAnchorPointForPosition(false)
        --newsIcon:setAnchorPoint(CCPointMake(0,0.5))
          --newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-40,tabBtnItem:getContentSize().height-25))
        newsIcon:setAnchorPoint(CCPointMake(1,0.5))
          newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height-15))
          newsIcon:addChild(newsNumLabel,1)
      newsIcon:setTag(10)
        newsIcon:setVisible(false)
        tabBtnItem:addChild(newsIcon)
       
           local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png");
           tipSp:setAnchorPoint(CCPointMake(1,0.5))
           tipSp:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height-15));
           tipSp:setTag(101);
           tipSp:setVisible(false)
            tabBtnItem:addChild(tipSp)
      
      -- --local newsNumLabel = GetTTFLabel("0",30)
      -- local newsNumLabel=GetBMLabel(0,G_FontSrc,30)
      -- newsNumLabel:setAnchorPoint(ccp(1,1))
      -- newsNumLabel:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height))
      -- newsNumLabel:setVisible(false)
      -- --newsNumLabel:setColor(G_ColorRed)
      -- newsNumLabel:setTag(10)
      -- tabBtnItem:addChild(newsNumLabel)
      
       
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
           tabBtn:setTouchPriority(-(layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   if subTabTb~=nil then
       local subTabIndex=0
       for k,v in pairs(subTabTb) do
           local tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
           local function tabSubClick(idx)
               return self:tabSubClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabSubClick)
           local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           self.allSubTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtnItem:setTag(subTabIndex+10)
           subTabIndex=subTabIndex+1
       end
    end  

   self:resetTab()
   self:doUserHandler()
   tabBtn:setPosition(0,0)
  dialogBg:addChild(tabBtn)
   
   self:initTableView()
   if newGuidMgr and newGuidMgr:isNewGuiding() then
        if self.tv~=nil then
            self.tv:setTableViewTouchPriority(100)
        end
   end
   --以下代码处理上下遮挡层
   local function forbidClick()
   
   end
   local rect2 = CCRect(0, 0, 50, 50);
   local capInSet = CCRect(20, 20, 10, 10);
   self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
   self.topforbidSp:setAnchorPoint(ccp(0,0))
   self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-3)
   self.bottomforbidSp:setAnchorPoint(ccp(0,0))
   local topY
   local topHeight
   if(self.tv~=nil)then
     local tvX,tvY=self.tv:getPosition()
     topY=tvY+self.tv:getViewSize().height
     topHeight=rect.height-topY
   else
     topHeight=0
     topY=0
   end
   self.topforbidSp:setContentSize(CCSize(rect.width,topHeight))
   self.topforbidSp:setPosition(0,topY)
   dialogBg:addChild(self.topforbidSp)

   dialogBg:addChild(self.bottomforbidSp)
   self:resetForbidLayer()
   self.topforbidSp:setVisible(false)
   self.bottomforbidSp:setVisible(false)
   --以上代码处理上下遮挡层



   self.dialogLayer:addChild(dialogBg)
   --[[
   if G_isIphone5()==true then
        local spBg1 =CCSprite:createWithSpriteFrameName("HeaderUpShape.jpg");
        local spBg2 =CCSprite:createWithSpriteFrameName("HeaderUpShape.jpg");
        spBg1:setAnchorPoint(CCPointMake(0,0))
        spBg1:setFlipY(true)
        spBg2:setAnchorPoint(CCPointMake(0,1))
        spBg1:setPosition(ccp(0,-88));
        spBg2:setPosition(ccp(0,self.bgLayer:getContentSize().height+88));
        self.bgLayer:addChild(spBg1)
        self.bgLayer:addChild(spBg2)
  end]]

    if type(self.overDayEvent) == "function" then
        self.overDayEventListener = function()
            if type(self.overDayEvent) == "function" then
                self:overDayEvent()
            else
                print("cjl -------->>> ERROR：跨天事件方法 'overDayEvent' 重写错误！")
            end
        end
        if eventDispatcher:hasEventHandler("overADay", self.overDayEventListener) == false then
            eventDispatcher:addEventListener("overADay", self.overDayEventListener)
        end
    end

   self:show()
   --clayer:setTouchEnabled(true)
   return self.dialogLayer
end

--顶部和底部的遮挡层
function commonDialog:resetForbidLayer()
   if(self.tv~=nil)then
     local tvX,tvY=self.tv:getPosition()
     self.bottomforbidSp:setContentSize(CCSizeMake(self.bgSize.width,tvY))
   else
     -- 如果没有self.tv 将遮罩移出屏幕外防止干扰
     if self.topforbidSp then
        self.topforbidSp:setPosition(ccp(9999,0))
     end
     if self.bottomforbidSp then
        self.bottomforbidSp:setPosition(ccp(9999,0))
     end
   end
end

function commonDialog:setIconTipVisibleByIdx(isVisible,idx)
    if self==nil then
        do
            return 
        end
    end
    local tabBtnItem = self.allTabs[idx]
    local temTabBtnItem=tolua.cast(tabBtnItem,"CCNode")
    local tipSp=temTabBtnItem:getChildByTag(101)
    if tipSp~=nil then
        if tipSp:isVisible()~=isVisible then
            tipSp:setVisible(isVisible)
        end
    end
end

function commonDialog:setTipsVisibleByIdx(isVisible,idx,num)
    if self==nil then
        do
            return 
        end
    end
    local tabBtnItem = self.allTabs[idx]
    local temTabBtnItem=tolua.cast(tabBtnItem,"CCNode")
    local tipSp=temTabBtnItem:getChildByTag(10)
    if tipSp~=nil then
    if tipSp:isVisible()~=isVisible then
          tipSp:setVisible(isVisible)
    end
    if tipSp:isVisible()==true then
      local tipNumLabel=tolua.cast(tipSp:getChildByTag(11),"CCLabelTTF")
        if tipNumLabel~=nil then
        if num and tipNumLabel:getString()~=tostring(num) then
          tipNumLabel:setString(num)
          local iconWidth=36
          if tipNumLabel:getContentSize().width+10>iconWidth then
            iconWidth=tipNumLabel:getContentSize().width+10
          end
          tipSp:setContentSize(CCSizeMake(iconWidth,36))
          tipNumLabel:setPosition(getCenterPoint(tipSp))
        end
        end
    end
    end
  --[[
    local tabBtnItem = self.allTabs[idx];
    local tipNumLabel=tolua.cast(tabBtnItem:getChildByTag(11),"CCLabelBMFont")
    if tipNumLabel~=nil then
    if num and tipNumLabel:getString()~=tostring(num) then
      tipNumLabel:setString(num)
    end
    if tipNumLabel:isVisible()~=isVisible then
          tipNumLabel:setVisible(isVisible)
    end
    end
  ]]
end

function commonDialog:setLockVisibleByIdx(isVisible,idx)
    if self==nil then
        do
            return
        end
    end
    local tabBtnItem = self.allTabs[idx]
    --local tipNumLabel=tolua.cast(tabBtnItem:getChildByTag(30),"CCLabelBMFont")
    if tabBtnItem:getChildByTag(30)~=nil then
        tabBtnItem:getChildByTag(30):setVisible(isVisible)
    end
end
function commonDialog:setTabBtnEffect(isEffect,idx)
    if self==nil then
        do
            return
        end
    end
    local tabBtnItem = self.allTabs[idx]
    local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
  if isEffect==true then
    local fadeOut=CCTintTo:create(0.5,255,97,0)
        local fadeIn=CCTintTo:create(0.5,255,255,255)
        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
    local repeatForever=CCRepeatForever:create(seq)
    tabBtnLabel:runAction(repeatForever)
  else
    tabBtnLabel:stopAllActions()
    tabBtnLabel:setColor(G_ColorWhite)
  end
end


function commonDialog:resetTab()


end
--用户处理特殊需求
function commonDialog:doUserHandler()

end

--设置dialogLayer触摸优先级
function commonDialog:setTouchPriority(p)
    self.dialogLayer:setTouchPriority(p)
end

function commonDialog:getDataByType()

end

--显示面板,加效果
function commonDialog:show()
   base.allShowedCommonDialog=base.allShowedCommonDialog+1
   table.insert(base.commonDialogOpened_WeakTb,self)

   local function callBack()
       if self and self.isCloseing==false then
            if portScene and portScene.clayer~=nil then
                if sceneController.curIndex==0 then
                    portScene:setHide()
                elseif sceneController.curIndex==1 then
                    mainLandScene:setHide()
                elseif sceneController.curIndex==2 then
                    worldScene:setHide()
                end
                
              
                mainUI:setHide()
                self:getDataByType() --只有Email使用这个方法
            end

            if self.moveEndCallBack then --执行回调
              self.moveEndCallBack()
            end
       end
       base:cancleWait()
   end
      if self.isuseami==false then
        callBack()
      else
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       local callFunc=CCCallFunc:create(callBack)
       local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
       self.bgLayer:runAction(seq)
      end

end

function commonDialog:initTableView()
    local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
    self.bgLayer:addChild(tv)
end

function commonDialog:eventHandler()

end
function commonDialog:tabClickColor(idx)
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
end
function commonDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx

         else
            v:setEnabled(true)
         end
    end

end

function commonDialog:tabSubClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allSubTabs) do
         if v:getTag()==idx+10 then
            v:setEnabled(false)
            self.selectedSubTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
end

function commonDialog:tick()

end

function commonDialog:fastTick()

end

function commonDialog:close(hasAnim)
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
    if newGuidMgr and newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==9 or newGuidMgr.curStep==46 or newGuidMgr.curStep==17 or newGuidMgr.curStep==35 or newGuidMgr.curStep==41) then --新手引导
            newGuidMgr:toNextStep()
    end
    if otherGuideMgr and otherGuideMgr.isGuiding and (otherGuideMgr.curStep==26 or otherGuideMgr.curStep==38) then
      if otherGuideMgr.curStep==38 then
        otherGuideMgr:hidingGuild()
      else
        otherGuideMgr:toNextStep()
      end
    end
    local function realClose()
        return self:realClose()
    end
    -- if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
    if base.allShowedCommonDialog==0 and storyScene and storyScene.isShowed==false and battleScene and battleScene.isBattleing==false then
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
   local time=0.3
   if newGuidMgr and newGuidMgr.curStep==16 then
      time=0;
   end
   local fc= CCCallFunc:create(realClose)
   local moveTo=CCMoveTo:create((hasAnim==true and time or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
   local acArr=CCArray:create()
   acArr:addObject(moveTo)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)
end
function commonDialog:realClose()
    self:doSendOnClose()
    self:dispose()
    base:removeFromNeedRefresh(self) --停止刷新
    if self.overDayEventListener then
      eventDispatcher:removeEventListener("overADay", self.overDayEventListener)
      self.overDayEventListener = nil  
    end
    self.dialogLayer:removeFromParentAndCleanup(true)
    self.dialogLayer=nil
    self.bgLayer=nil
    for k,v in pairs(self.allTabs) do
        self.allTabs[k]=nil
    end
    self.allTabs=nil
    self.allSubTabs=nil
    self.bgSize=nil
    self.tv=nil
    self.selectedTabIndex=nil  --当前选中的tab
    self.selectedSubTabIndex=nil  --当前选中的Subtab
    self.isMoved=nil       --当前tableview是否被拖动了
    self.needExpandCellIndex=nil --当前需要展开的tableViewCell
    self.oldSelectedTabIndex=nil
    self:removeSpriteFrames()
    self=nil

    
    --[[
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")

    

    local xl
    for k,v in pairs(G_CheckMem) do
        xl=v
    end
    ]]

    
end
function commonDialog:doSendOnClose()

end
function commonDialog:removeSpriteFrames()

end

function commonDialog:setDisplay(bool)  
  
    if bool==true then
        self.bgLayer:setVisible(true)
    else
        self.bgLayer:setVisible(false)
    end

end

function commonDialog:setTopLineShow()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    if self.allTabs and SizeOfTable(self.allTabs)>0 then
      self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80 - 78)
    else
      self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    end
end

function commonDialog:isClosed()
  if self.isCloseing==true or self.bgLayer==nil or tolua.cast(self.bgLayer,"LuaCCScale9Sprite")==nil then
    return true
  end
  return false
end

function commonDialog:dispose()
    
end