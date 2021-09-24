reuseSliderPanel={}

function reuseSliderPanel:new()
    local nc={
      bgLayer=nil,             --背景sprite
      dialogLayer,         --对话框层
      closeBtn,
      parent,
      tv,
      layerNum,
      bgSize,
      isMoved,
      cellHeight,
      slider,
      topforbidSp, --顶端遮挡层
      bottomforbidSp, --底部遮挡层
      selectedTabIndex=1,  --当前选中的tab
      oldSelectedTabIndex=1,--上一次选中的tab
      tankBgSpTb={},
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
function reuseSliderPanel:close()
    if self.parent then
       if self.parent.exSelfTankPanel then
            self.parent.exSelfTankPanel = nil
       end
       self.parent = nil
    end

    self.tankBgSpTb  = nil
    self.slider      = nil
    self.m_numLb     = nil
    self.usedId      = nil
    self.bgLayer     = nil             --背景sprite
    self.closeBtn    = nil
    self.parent      = nil
    self.tv          = nil
    self.layerNum    = nil
    self.bgSize      = nil
    self.isMoved     = nil
    self.cellHeight  = nil
    self.slider      = nil
    self.topforbidSp         = nil --顶端遮挡层
    self.bottomforbidSp      = nil --底部遮挡层
    self.tvWidth,self.tvHeight = nil,nil
    self.useHeight = nil
    self.selectedTabIndex    = nil  --当前选中的tab
    self.oldSelectedTabIndex = nil--上一次选中的tab
    self.dialogLayer:removeFromParentAndCleanup(true)

end

function reuseSliderPanel:init(layerNum,parent,usedId)--usedId:被谁调用的id
    self.dialogLayer=CCLayer:create();
    self.parent = parent
    self.usedId = usedId
    self.layerNum = layerNum
    for i=1,2 do
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        grayBgSp:setAnchorPoint(ccp(0.5,0.5))
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        grayBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
        self.dialogLayer:addChild(grayBgSp)  
    end
    
--背景   
    local bgWidth,tHeight=600,900
    self.bgWidth = bgWidth
    self.upHeight  = 64--上边栏高度
    self.useHeight = tHeight - self.upHeight
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local rect=CCRect(0, 0, 400, 350)
    local capInSet=CCRect(168, 86, 10, 10)
    self.bgLayer=G_getNewDialogBg(CCSizeMake(bgWidth,tHeight),getlocal("exchangeScore"),30,function ()end,layerNum,true,close)
    self.bgLayer:setTouchPriority((-(layerNum-1)*20-1))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:addChild(self.bgLayer,1)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,function ()end);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=G_VisibleSize
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg,1);

    --------------------------------------- 开 始 特 殊 处 理 ---------------------------------------
      if self.usedId == "wpbd" then
          self:showWpbdExchangeSelfTankPanel()
          
      end
     -------------------------------------------e-n-d--------------------------------------------
     --以下代码处理上下遮挡层
       if self.tv then
         local function forbidClick()
         
         end
         local rect2 = CCRect(0, 0, 50, 50);
         local capInSet = CCRect(20, 20, 10, 10);
         self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
         self.topforbidSp:setTouchPriority(-(layerNum-1)*20-4)
         self.topforbidSp:setAnchorPoint(ccp(0,0))
         self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
         self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-4)
         self.bottomforbidSp:setAnchorPoint(ccp(0,0))
         local tvX,tvY=self.tv:getPosition()
         local topY=tvY+self.tv:getViewSize().height+(rect.height-self.bgLayer:getContentSize().height)/2
         local topHeight=rect.height-topY
         self.topforbidSp:setContentSize(CCSize(rect.width,topHeight))
         self.topforbidSp:setPosition(0,topY)
         self.dialogLayer:addChild(self.topforbidSp)

         self.dialogLayer:addChild(self.bottomforbidSp)
         self:resetForbidLayer()
         -- self.topforbidSp:setVisible(false)
         self.topforbidSp:setOpacity(0)
         self.bottomforbidSp:setOpacity(0)
         -- self.bottomforbidSp:setVisible(false)
       end
       --以上代码处理上下遮挡层

    return self.dialogLayer
end
--顶部和底部的遮挡层
function reuseSliderPanel:resetForbidLayer()
   local tvX,tvY=self.tv:getPosition()
   local ridHeight = tvY+(G_VisibleSize.height-self.bgLayer:getContentSize().height)/2
   self.bottomforbidSp:setContentSize(CCSizeMake(640,ridHeight))
end
----------------------------------- 王 牌 部 队（wpbd) -----------------------------------
function reuseSliderPanel:wpbdRefresh( )
          self.canExTankTb = acWpbdVoApi:getSelfAllTank()
          local count = SizeOfTable(self.canExTankTb)
          if count > 0 then
                self.hei=math.ceil(count/3)
                
          else
                -------------------- 提示 没有可兑换坦克
                local noTanks = GetTTFLabel(getlocal("activity_wpbd_noTank"),28)
                noTanks:setPosition(getCenterPoint(self.bgLayer))
                self.bgLayer:addChild(noTanks,99)
          end

      if self.canUseCurScore then
           self.canUseCurScore:removeFromParentAndCleanup(true)
           self.canUseCurScore = nil
      end
      local strSize3 = G_isAsia() and 25 or 22
      local colorTab={nowColor,G_ColorYellow}
      local againStr=getlocal("canUseCurScore",{acWpbdVoApi:getAllScore()})
      local canUseCurScore = G_getRichTextLabel(againStr,colorTab,strSize3,G_VisibleSizeWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,0,true)
      canUseCurScore:setPosition(self.bgWidth * 0.5,self.useHeight -20)
      self.canUseCurScore = canUseCurScore
      canUseCurScore:setAnchorPoint(ccp(0.5,1))
      self.bgLayer:addChild(canUseCurScore)

      if self.tv then
          local recordPoint = self.tv:getRecordPoint()
          self.tv:reloadData()
          self.tv:recoverToRecordPoint(recordPoint)
      end

      self.parent:refresh()
      return count or 0
end
function reuseSliderPanel:showWpbdExchangeSelfTankPanel()
    local exCount = self:wpbdRefresh()

    local function exchangeSelfTankCall( )
        -- print "exchangeSelfTankCall~~~~~"
        local curSelfExTb = acWpbdVoApi:getSelfAllTank( )
        if self.curTag == nil or (curSelfExTb[self.curTag].tankCurNum == nil or curSelfExTb[self.curTag].tankCurNum == 0) then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notHasTank"),28)
            do return end
        end
        local tid = self.canExTankTb[self.curTag].tid
        -- print("self.canExNum====>>>>>",self.canExNum)
        local choseId,choseExNum,choseExAllScore = "e"..self.canExTankTb[self.curTag].id,self.canExNum,self.canExTankTb[self.curTag].score * self.canExNum
        local exTank = getlocal(tankCfg[tid].name)
        local function sureClick( )

            local function socketSuccCall()
                -- print("here?222222")
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_change_sucess"),28)
                self:wpbdRefresh()
            end
            acWpbdVoApi:exchangeSelfTankSocket(socketSuccCall,choseId,choseExNum,tid)
        end

        local keyName=acWpbdVoApi:getActiveName().."ex"
        local function secondTipFunc(sbFlag)
            
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        local strSize3 = G_isAsia() and 25 or 22
        if G_isPopBoard(keyName) then--
            self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_wpbd_tab2_exSecondTip2",{exTank,choseExNum,choseExAllScore}),true,sureClick,secondTipFunc,nil,{strSize3})
        else
            sureClick()
        end
    end
    local btnScale,priority = 0.8,-(self.layerNum-1)*20-5
    local exchangeBtn,exchangeMenu = G_createBotton(self.bgLayer,ccp(self.bgWidth * 0.5,30),{getlocal
      ("code_gift")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",exchangeSelfTankCall,btnScale,priority,nil,nil,ccp(0.5,0))
    self.exchangeMenu = exchangeMenu
    self.exchangeBtn  = exchangeBtn

    local scoreIcon = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
    scoreIcon:setScale(0.8)
    scoreIcon:setAnchorPoint(ccp(1,0))
    scoreIcon:setPosition(ccp(exchangeMenu:getPositionX()-4,exchangeMenu:getPositionY() + exchangeBtn:getContentSize().height *btnScale + 5))
    self.bgLayer:addChild(scoreIcon)

    self.scoreNum = GetTTFLabel("",24)
    self.scoreNum:setAnchorPoint(ccp(0,0))
    self.scoreNum:setPosition(ccp(exchangeMenu:getPositionX()+ 4,exchangeMenu:getPositionY() + exchangeBtn:getContentSize().height *btnScale + 8))
    self.bgLayer:addChild(self.scoreNum)

    if exCount > 0 then
      self:initSlider()
      self:initWpbdTableView()
    else
        exchangeBtn:setVisible(false)
        exchangeMenu:setVisible(false)
        scoreIcon:setVisible(false)
    end
end

function reuseSliderPanel:initSlider( )
      local m_numLb=GetTTFLabel(" ",30)
      self.bgLayer:addChild(m_numLb,2);
      
      local function sliderTouch(handler,object)
          -- local valueNum = tonumber(string.format("%.2f", object:getValue()))
          local count = math.ceil(object:getValue())

          if self.usedId then
              if self.usedId == "wpbd" and self.curTag then--坦克剩余数量的显示
                    local tankData = self.canExTankTb[self.curTag]
                    local tankNum = tolua.cast(self.tankBgSpTb[self.curTag]:getChildByTag(222),"CCLabelTTF")
                    self.canExNum = count
                    if tankData.tankCurNum >= count then
                      tankNum:setString(tankData.tankCurNum - count)
                      self.scoreNum:setString(tankData.score * count)
                    end
              end
          end
          if count >= 0 then
              m_numLb:setString(count)
          end  
      end
      local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
      local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
      local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png");--ProduceTankIconSlide
      self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
      self.slider:setTouchPriority(-(self.layerNum-1)*20-5);
      self.slider:setIsSallow(true);
      
      self.slider:setMinimumValue(1.0);

      self.slider:setTag(99)
      self.bgLayer:addChild(self.slider,2)
      m_numLb:setString(math.ceil(self.slider:getValue()))
      self.m_numLb=m_numLb

      local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png");
      bgSp:setScaleX(85/bgSp:getContentSize().width)
      bgSp:setAnchorPoint(ccp(0.5,0.5));
      self.bgLayer:addChild(bgSp,1);
      
      
      local function touchAdd()
           self.slider:setValue(self.slider:getValue()+1);
      end
      
      local function touchMinus()
          if self.slider:getValue()-1>0 then
              self.slider:setValue(self.slider:getValue()-1);
          end
      end
      
      local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
      self.bgLayer:addChild(addSp,1)
      addSp:setTouchPriority(-(self.layerNum-1)*20-5);
      
      local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
      self.bgLayer:addChild(minusSp,1)
      minusSp:setTouchPriority(-(self.layerNum-1)*20-5);

      if self.usedId then
          if self.usedId == "wpbd" then
              self.slider:setScaleX(250/self.slider:getContentSize().width)

              self.slider:setPosition(ccp(350,170))
              bgSp:setPosition(100,170);
              addSp:setPosition(ccp(510,170))
              minusSp:setPosition(ccp(175,170))
              m_numLb:setPosition(100,170);

              local strSize = 24
              if G_isAsia() == false then
                strSize = 18
              end
              local exchangeNumStr = GetTTFLabel(getlocal("exchangeNumStr").."：",strSize,"Helvetica-bold")
              exchangeNumStr:setAnchorPoint(ccp(0.5,0))
              exchangeNumStr:setPosition(100,bgSp:getContentSize().height * 0.5 + bgSp:getPositionY() + 5)
              self.bgLayer:addChild(exchangeNumStr)
          end
      else
          self.slider:setPosition(ccp(340,150))
          bgSp:setPosition(60,150);
          addSp:setPosition(ccp(560,150))
          minusSp:setPosition(ccp(125,150))
          m_numLb:setPosition(60,150);
      end
      

      local upM_Line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)--modifiersLine2
      upM_Line:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,upM_Line:getContentSize().height))
      upM_Line:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,150))
      self.bgLayer:addChild(upM_Line,2)
end

function reuseSliderPanel:initWpbdTableView()
    self.tvWidth,self.tvHeight = self.bgWidth - 40,self.useHeight - 300
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(20,230)
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
       return self:wpbdEventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth-4,self.tvHeight-4),nil)
    self.tv:setTableViewTouchPriority((-(self.layerNum-1)*20-3))
    self.tv:setPosition(ccp(22,232))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function reuseSliderPanel:wpbdEventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
       return CCSizeMake(self.tvWidth-4,self.hei*250)
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()

       local numX,numY=0,0
       local function touch(object,name,tag)
            PlayEffect(audioCfg.mouseClick)
            if self.tv:getIsScrolled()==true then
                do return end
            end
              
            if self.canExTankTb[tag].curExNum < self.canExTankTb[tag].limitNum and self.canExTankTb[tag].unEx == nil then
                self.curTag = tag
                local touchSp=cell:getChildByTag(tag)
                self.myTouchSp=touchSp

                self.selectedSp:setPosition(self.tankBgSpTb[tag]:getPosition())

                local tankData = self.canExTankTb[tag]

                local canExNum = tankData.limitNum - tankData.curExNum--tankData.limitNum < tankData.tankCurNum
                if tankData.limitNum > tankData.tankCurNum then
                    if tankData.tankCurNum + tankData.curExNum <= tankData.limitNum then
                      canExNum = tankData.tankCurNum
                    else
                      canExNum = tankData.tankCurNum - ( tankData.tankCurNum + tankData.curExNum - tankData.limitNum )
                    end
                end
                -- local canExNum = tankData.limitNum > tankData.tankCurNum and (tankData.tankCurNum - tankData.curExNum) or (tankData.limitNum - tankData.curExNum)
                canExNum = canExNum < 0 and 0 or canExNum
                self.canExNum = canExNum 
                local tankNum = tolua.cast(self.tankBgSpTb[tag]:getChildByTag(222),"CCLabelTTF")
                tankNum:setString(tankData.tankCurNum - canExNum)

                self.scoreNum:setString(tankData.score * canExNum)

                if self.slider then
                    self.slider:setMaximumValue(canExNum);
                    self.slider:setValue(canExNum);
                end
                if tag ~= self.oldTag then
                  local lastTankNum = tolua.cast(self.tankBgSpTb[self.oldTag]:getChildByTag(222),"CCLabelTTF")--上一次选中的tank
                  lastTankNum:setString(self.canExTankTb[self.oldTag].tankCurNum)
                  self.oldTag = tag
                end

            end
       end

       local bgSpWidth,bgSpHeight = 180,230
       for k,v in pairs(self.canExTankTb) do
           local tankBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("superShopBg1.png",CCRect(90, 193, 1, 1),touch);
           tankBgSp:setContentSize(CCSizeMake(bgSpWidth,bgSpHeight))
           tankBgSp:setTag(k)
           tankBgSp:setIsSallow(true)
           tankBgSp:setTouchPriority((-(self.layerNum-1)*20-2))
           tankBgSp:setPosition(4 + bgSpWidth/2+bgSpWidth*numX+4*numX,self.hei*250-bgSpHeight * 0.5 - numY*bgSpHeight - 10 - 10 * numY)
           cell:addChild(tankBgSp,2)

           self.tankBgSpTb[k] = tankBgSp
           local tid = v.tid
           local tankIcon = CCSprite:createWithSpriteFrameName(tankCfg[tid].icon)
           tankIcon:setScale(100/tankIcon:getContentSize().width)
           tankIcon:setPosition(bgSpWidth *0.5,bgSpHeight - 65)
           tankBgSp:addChild(tankIcon)

           local tankName = GetTTFLabel(getlocal(tankCfg[tid].name),22)
           if tankName:getContentSize().width > bgSpWidth - 70 then
               tankName:setScale((bgSpWidth - 70) / tankName:getContentSize().width)
           end
           tankName:setPosition(bgSpWidth * 0.5,bgSpHeight - 140)
           tankName:setColor(G_ColorYellow)
           tankBgSp:addChild(tankName)

           local numPosy = 100

           local tankNumBg =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(20, 20, 10, 10),function()end)
           -- tankNumBg:setContentSize(CCSizeMake(50,20))
           tankNumBg:setScaleX(100/tankNumBg:getContentSize().width)
           tankNumBg:setScaleY(20/tankNumBg:getContentSize().height)
           tankNumBg:setPosition(ccp(bgSpWidth * 0.5,bgSpHeight - numPosy));
           tankNumBg:setOpacity(150)
           tankBgSp:addChild(tankNumBg)
           -- print("v.name--->>>v.tankCurNum-->>>>",tankCfg[tid].name,v.tankCurNum)
           local tankNum = GetTTFLabel(v.tankCurNum,23)
           tankNum:setPosition(ccp(bgSpWidth * 0.5,bgSpHeight - numPosy));
           tankNum:setTag(222)
           tankBgSp:addChild(tankNum)

           local scoreBg = LuaCCScale9Sprite:createWithSpriteFrameName("blackBg1.png",CCRect(10,10,10,10),function()end)
           scoreBg:setContentSize(CCSizeMake(bgSpWidth - 40,30))
           scoreBg:setAnchorPoint(ccp(0.5,1))
           scoreBg:setPosition(bgSpWidth * 0.5,bgSpHeight - 160)
           tankBgSp:addChild(scoreBg)

                local scorePic = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png");
                scorePic:setScale(0.8)
                scorePic:setPosition(ccp(scoreBg:getContentSize().width * 0.4,scoreBg:getContentSize().height * 0.5))
                scoreBg:addChild(scorePic)

                local exScoreNum = GetTTFLabel(v.score,23)
                exScoreNum:setAnchorPoint(ccp(0,0.5))
                exScoreNum:setPosition(ccp(scoreBg:getContentSize().width * 0.62,scoreBg:getContentSize().height * 0.5))
                scoreBg:addChild(exScoreNum)                

           local curChoseExchangeNum = GetTTFLabel(getlocal("exchangeNum",{v.curExNum,v.limitNum}),23)
           curChoseExchangeNum:setPosition(bgSpWidth * 0.5,10)
           curChoseExchangeNum:setAnchorPoint(ccp(0.5,0))
           tankBgSp:addChild(curChoseExchangeNum)
           self.curChoseExchangeNum = curChoseExchangeNum
           if v.curExNum >= v.limitNum then
              self.curChoseExchangeNum:setColor(G_ColorRed)
           end
           if curChoseExchangeNum:getContentSize().width > bgSpWidth - 40 then
              curChoseExchangeNum:setScale((bgSpWidth - 40)/curChoseExchangeNum:getContentSize().width)
           end

           local function showInfoHandler(tag,object)
                local id = G_pickedList(tid)
                tankInfoDialog:create(nil,tonumber(id),self.layerNum+1)
           end
           local btnScale,priority = 0.7,-(self.layerNum-1)*20-3
           local showInfoBtn,showInfoMenu = G_createBotton(tankBgSp,ccp(bgSpWidth-10,bgSpHeight-10),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfoHandler,btnScale,priority,nil,nil,ccp(1,1))

           if v.unEx then
              local showStr = getlocal("exchangeEnought")
              if v.tankCurNum == 0 then
                  showStr = getlocal("notHasTank")
              end
              local function notTouchCall( )
                  if self.tv:getIsScrolled()==true then
                      do return end
                  end
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),showStr,28)
              end
              local notTouchPanelSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),notTouchCall)
              notTouchPanelSp:setPosition(bgSpWidth * 0.5,bgSpHeight * 0.5)
              notTouchPanelSp:setContentSize(CCSizeMake(bgSpWidth,bgSpHeight))
              notTouchPanelSp:setTouchPriority(-(self.layerNum-1)*20-3)
              notTouchPanelSp:setIsSallow(false)
              tankBgSp:addChild(notTouchPanelSp)
           end

           numX=numX+1
           if numX>2 then
              numX=0
              numY=numY+1
           end
       end

        self.selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
        self.selectedSp:setContentSize(CCSizeMake(bgSpWidth+5,bgSpHeight+5))
        cell:addChild(self.selectedSp,2)

        self:wpbdSetSelectSpPos()
         
        

       return cell;
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
   end 
end

function reuseSliderPanel:wpbdSetSelectSpPos( )--unEx
    if self.selectedSp and self.canExTankTb and self.tankBgSpTb then
        for k,v in pairs(self.canExTankTb) do
            if v.curExNum < v.limitNum and v.unEx == nil then
                self.curTag = k

                self.selectedSp:setPosition(self.tankBgSpTb[k]:getPosition())
                local canExNum = v.limitNum - v.curExNum--v.limitNum < v.tankCurNum
                if v.limitNum > v.tankCurNum then
                    if v.tankCurNum + v.curExNum <= v.limitNum then
                      canExNum = v.tankCurNum
                    else
                      canExNum = v.tankCurNum - ( v.tankCurNum + v.curExNum - v.limitNum )
                    end
                end
                -- local canExNum = v.limitNum > v.tankCurNum and (v.tankCurNum - v.curExNum) or (v.limitNum - v.curExNum)
                canExNum = canExNum < 0 and 0 or canExNum
                self.canExNum = canExNum
                local tankNum = tolua.cast(self.tankBgSpTb[k]:getChildByTag(222),"CCLabelTTF")
                -- print("v.tankCurNum- canExNum",v.tankCurNum,canExNum,v.tankCurNum-canExNum)
                tankNum:setString(v.tankCurNum - canExNum)

                self.scoreNum:setString(v.score * canExNum)

                if self.slider then
                    self.slider:setMaximumValue(canExNum);
                    self.slider:setValue(canExNum);
                end

                self.oldTag = k
                do break end
            else
                self.selectedSp:setVisible(false)
                self.slider:setValue(0)
                self.slider:setMaximumValue(0)
                self.slider:setMinimumValue(0)
                self.m_numLb:setString(0)
            end
        end
    end
end