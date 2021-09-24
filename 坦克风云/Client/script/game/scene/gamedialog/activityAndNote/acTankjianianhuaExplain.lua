acTankjianianhuaExplain=smallDialog:new()

function acTankjianianhuaExplain:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550

  self.des = nil -- 活动说明信息
  self.desH = {} -- 活动说明信息的高度

  self.allTabs={}

	return nc
end

function acTankjianianhuaExplain:create(layerNum)
    local sd=acTankjianianhuaExplain:new()
    self.layerNum = layerNum
    sd:init()
    return sd

end
function acTankjianianhuaExplain:init()
    self.isTouch=false
    self.isUseAmi=false
    local function touchHandler()
    
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(550,G_VisibleSize.height-200)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()
    
    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,self.layerNum)
    
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    

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


    local titleLb=GetTTFLabel(getlocal("shuoming"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)



   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   local tabTb={getlocal("shuoming"),getlocal("award")}
   if tabTb~=nil then
       for k,v in pairs(tabTb) do
           tabBtnItem = CCMenuItemImage:create("tabBtnSmall.png", "tabBtnSmall_Selected.png","tabBtnSmall_Selected.png")
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               self.oldSelectedTabIndex=self.selectedTabIndex
               self:tabClickColor(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,30,CCSizeMake((self.bgLayer:getContentSize().width-20)/SizeOfTable(tabTb),0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb,1)
           lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
           tabBtnItem:setScale(0.8)
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   self:resetTab()
   tabBtn:setPosition(0,0)
   dialogBg:addChild(tabBtn)

end

function acTankjianianhuaExplain:resetTab()
  local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+tabBtnItem:getContentSize().width*0.8,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
    self:tabClick(0)
end

function acTankjianianhuaExplain:tabClickColor(idx)
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
function acTankjianianhuaExplain:tabClick(idx)
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

      if self.bgLayer1~=nil then
          self.bgLayer1:setPosition(ccp(999333,0))
          self.bgLayer1:setVisible(false)
      end
      
      if self.bgLayer2==nil then
          self:initLayer2()
          self.bgLayer:addChild(self.bgLayer2)
      else
           self.bgLayer2:setVisible(true)
      end

      self.bgLayer2:setPosition(ccp(0,0))
            
    elseif idx==0 then
      if self.bgLayer2~=nil then
          self.bgLayer2:setPosition(ccp(999333,0))
          self.bgLayer2:setVisible(false)
      end
      
      if self.bgLayer1==nil then
          self:initLayer1()
          self.bgLayer:addChild(self.bgLayer1)
      else
           self.bgLayer1:setVisible(true)
      end

      self.bgLayer1:setPosition(ccp(0,0))

    end

end

function acTankjianianhuaExplain:initLayer1()

  self.bgLayer1=CCLayer:create()
  local descStr = getlocal("activity_tankjianianhua_desc1").."\n"..getlocal("activity_tankjianianhua_desc2").."\n"..getlocal("activity_tankjianianhua_desc3").."\n"..getlocal("activity_tankjianianhua_desc4")
  local desH1= self:getDesH(descStr)
  table.insert(self.desH,desH1)

  local onlyDescH = self:getDesH(getlocal("activity_tankjianianhua_onelyDesc"))
  table.insert(self.desH,onlyDescH)

  local allDescH = self:getDesH(getlocal("activity_tankjianianhua_allDesc"))
  table.insert(self.desH,allDescH)

  local function callBack(...)
       return self:eventHandler1(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height-170),nil)
  self.bgLayer1:addChild(self.tv,1)
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setPosition(ccp(0,20))
  self.bgLayer1:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acTankjianianhuaExplain:initLayer2()
  -- body
  self.bgLayer2=CCLayer:create()

  local function callBack(...)
       return self:eventHandler2(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height-170),nil)
  self.bgLayer2:addChild(self.tv2,1)
  self.tv2:setAnchorPoint(ccp(0,0))
  self.tv2:setPosition(ccp(0,20))
  self.bgLayer2:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv2:setMaxDisToBottomOrTop(120)

end

function acTankjianianhuaExplain:getDesH(content, size)
  local showMsg=content or ""
  if size==nil then
    size = 25
  end
  local width=self.bgLayer:getContentSize().width - 40
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

function acTankjianianhuaExplain:eventHandler1(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 5
  elseif fn=="tableCellSizeForIndex" then
    local cellHeight
    if idx==1 or idx==3 then
      cellHeight=60
    elseif idx ==0 then
      cellHeight=self.desH[1]+20
    elseif idx==2 then
      cellHeight = self.desH[2]+200
    elseif idx==4 then
      cellHeight = self.desH[3]+370
    -- elseif idx == 6 then
    --   cellHeight = 300
    end

    return  CCSizeMake(self.bgLayer:getContentSize().width,cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local titleLb
    if idx ==0 then
      local descStr = getlocal("activity_tankjianianhua_desc1").."\n"..getlocal("activity_tankjianianhua_desc2").."\n"..getlocal("activity_tankjianianhua_desc3").."\n"..getlocal("activity_tankjianianhua_desc4")
      local descLb = GetTTFLabelWrap(descStr,25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      descLb:setAnchorPoint(ccp(0,1))
      descLb:setPosition(20,self.desH[1]+10)
      cell:addChild(descLb)
    elseif idx ==1 or idx==3 then

      local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
      backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 60))
      backSprie:ignoreAnchorPointForPosition(false)
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setIsSallow(false)
      backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
      backSprie:setPosition(ccp(10,0))
      cell:addChild(backSprie,1)

      titleLb=  GetTTFLabelWrap("",27,CCSizeMake(backSprie:getContentSize().width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)
      backSprie:addChild(titleLb)
    elseif idx ==2 then
      local explainLb = GetTTFLabelWrap(getlocal("shuoming"),25,CCSizeMake(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      explainLb:setAnchorPoint(ccp(0,1))
      explainLb:setPosition(10,self.desH[2]+200-10)
      cell:addChild(explainLb)
      explainLb:setColor(G_ColorGreen)

      local onlyDescLb = GetTTFLabelWrap(getlocal("activity_tankjianianhua_onelyDesc"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      onlyDescLb:setAnchorPoint(ccp(0,1))
      onlyDescLb:setPosition(20,self.desH[2]+200-10-explainLb:getContentSize().height)
      cell:addChild(onlyDescLb)

      local bigRewardArray = GetTTFLabelWrap(getlocal("activity_tankjianianhua_bigRewardArray"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      bigRewardArray:setAnchorPoint(ccp(0,1))
      bigRewardArray:setPosition(20,200-10-explainLb:getContentSize().height)
      cell:addChild(bigRewardArray)
      bigRewardArray:setColor(G_ColorGreen)

      local capInSet1 = CCRect(17, 17, 1, 1)
      local function touchClick()
      end
      local numSP =LuaCCScale9Sprite:createWithSpriteFrameName("jianianhua_circle.png",capInSet1,touchClick)
      numSP:ignoreAnchorPointForPosition(false)
      numSP:setAnchorPoint(CCPointMake(0,0.5))
      numSP:setPosition(ccp(20,80))
      cell:addChild(numSP)

      local numLb = GetTTFLabel("1",25)
      numLb:setPosition(numSP:getContentSize().width/2,numSP:getContentSize().height/2)
      numSP:addChild(numLb)

      numLb:setColor(G_ColorBlack)

      local arraySp = CCSprite:createWithSpriteFrameName("Array1.png")
      arraySp:setAnchorPoint(ccp(0,0.5))
      arraySp:setPosition(20+numSP:getContentSize().width+10,80)
      cell:addChild(arraySp)



    elseif idx ==4 then

      local allExplainLb = GetTTFLabelWrap(getlocal("shuoming"),25,CCSizeMake(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      allExplainLb:setAnchorPoint(ccp(0,1))
      allExplainLb:setPosition(10,self.desH[3]+370-10)
      cell:addChild(allExplainLb)
      allExplainLb:setColor(G_ColorGreen)

      local allDescLb = GetTTFLabelWrap(getlocal("activity_tankjianianhua_allDesc"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      allDescLb:setAnchorPoint(ccp(0,1))
      allDescLb:setPosition(20,self.desH[3]+370-10-allExplainLb:getContentSize().height)
      cell:addChild(allDescLb)

      local bigRewardArray = GetTTFLabelWrap(getlocal("activity_tankjianianhua_bigRewardArray"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      bigRewardArray:setAnchorPoint(ccp(0,1))
      bigRewardArray:setPosition(20,370-10-allExplainLb:getContentSize().height)
      cell:addChild(bigRewardArray)
      bigRewardArray:setColor(G_ColorGreen)

      local h = 370-10-allExplainLb:getContentSize().height

      local capInSet1 = CCRect(17, 17, 1, 1)
      local function touchClick()
      end
      for i=1,8 do
        local posX = 20+170*((i-1)%3)
        local posY = h-100*math.floor((i-1)/3)-80
        local numSP =LuaCCScale9Sprite:createWithSpriteFrameName("jianianhua_circle.png",capInSet1,touchClick)
        numSP:ignoreAnchorPointForPosition(false)
        numSP:setAnchorPoint(CCPointMake(0,0.5))
        numSP:setPosition(posX,posY)
        cell:addChild(numSP)

        local numLb = GetTTFLabel(tostring(i),25)
        numLb:setPosition(numSP:getContentSize().width/2,numSP:getContentSize().height/2)
        numSP:addChild(numLb)
        numLb:setColor(G_ColorBlack)

        local arraySp = CCSprite:createWithSpriteFrameName("Array"..i..".png")
        arraySp:setAnchorPoint(ccp(0,0.5))
        arraySp:setPosition(posX+numSP:getContentSize().width+10,posY)
        cell:addChild(arraySp)
      end
      

   -- elseif idx ==6 then
    end
    if idx ==1 then
      titleLb:setString(getlocal("activity_tankjianianhua_onlyMode"))
    elseif idx ==3 then
      titleLb:setString(getlocal("activity_allianceDonate_title"))
    -- elseif idx ==5 then
    --   titleLb:setString(getlocal("activity_tankjianianhua_awardContent"))
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



function acTankjianianhuaExplain:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if idx==2 then
          tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,120*9+80)
        elseif idx==1 then
          tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,120*9+80)
        elseif idx == 0 then
          tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,120*10+80)
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local number
        local showIndex
        if idx==2 then
          number=9
          showIndex=1
        elseif idx==1 then
          number=9
          showIndex=2
        elseif idx == 0 then
          number=10
          showIndex=3
        end
        local W = self.bgLayer:getContentSize().width-20
        local H = 120*number+80
        local titleH = 80
        local single = (H - titleH)/number

        local titleLb=GetTTFLabel(getlocal("activity_slotMachine_tableTitleLb"..tonumber(idx + 1)),28)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(W/2, H - titleH/2))
        cell:addChild(titleLb,1)
        titleLb:setColor(G_ColorGreen)
        
        local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSP:setAnchorPoint(ccp(0.5,0.5))
        lineSP:setScaleX(W/lineSP:getContentSize().width)
        lineSP:setScaleY(1.2)
        lineSP:setPosition(ccp(W/2,H - titleH))
        cell:addChild(lineSP)
        local index = 1
        for i=number,1,-1 do
          local iconID = "a"..i
          local icon
          local iconX = nil
          local iconY = H - titleH - single * (index - 0.5)

          for i=1,showIndex do
              iconX = W - 120 - i * 110
              -- iconX = i * (W - 180)/(iconNum + 1)
              icon= acTankjianianhuaVoApi:getShowIconById(iconID)
              -- if icon:getContentSize().width>100 then
              --   icon:setScale(100/icon:getContentSize().width)
              -- end
              
              icon:setAnchorPoint(ccp(0.5,0.5))
              icon:setPosition(ccp(iconX,iconY))
              cell:addChild(icon)
          end

          local rewardCfg = acTankjianianhuaVoApi:getRewardListByID(iconID.."-"..showIndex)
          if rewardCfg then
            local reward = FormatItem(rewardCfg)
            if reward then
              for k,v in pairs(reward) do
                local icon2,iconScale = G_getItemIcon(v,100,true,self.layerNum,nil,self.tv2)
                icon2:ignoreAnchorPointForPosition(false)
                icon2:setAnchorPoint(ccp(1,0.5))
                icon2:setPosition(ccp(W - 20 ,iconY))
                icon2:setIsSallow(false)
                icon2:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(icon2,1)

                local numLabel=GetTTFLabel("x"..v.num,25)
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon2:getContentSize().width-10,5)
                icon2:addChild(numLabel,1)
                numLabel:setScale(1/iconScale)
              end
              
            end
          end


          -- iconX = W - 145 
          local denghao=GetTTFLabel("=",30)
          denghao:setAnchorPoint(ccp(1,0.5))
          denghao:setPosition(W - 145 ,iconY)
          cell:addChild(denghao)

          index = index + 1
          

        end

          -- local cfgByNum = acSlotMachineVoApi:getCfgConversionTableByNum(3 - idx)
          -- local index = 1
          -- for k,v in pairs(cfgByNum) do
          --     local iconNum = v.num
          --     local id = v.id
          --     local pic = nil
          --     local icon = nil
          --     local iconX = nil
          --     local iconY = H - titleH - single * (index - 0.5)
          --     for i=1,iconNum do
          --         iconX = W - 180 - i * 120
          --         -- iconX = i * (W - 180)/(iconNum + 1)
          --         pic = acSlotMachineVoApi:getPicById(id)
          --         icon = CCSprite:createWithSpriteFrameName(pic)
          --         icon:setScale(0.6)
          --         icon:setAnchorPoint(ccp(0,0.5))
          --         icon:setPosition(ccp(iconX,iconY))
          --         cell:addChild(icon)
          --     end

          --     -- 奖励坦克
          --     local rewardCfg = v.reward.o[1]
          --     for k2,v2 in pairs(rewardCfg) do
          --         if k ~= "index" then
          --             local tankId = tonumber(RemoveFirstChar(k2))
          --             local tankNum = v2
          --             local tankCfg = tankCfg[tankId]
          --             if tankCfg ~= nil then
          --                 iconX = W - 20

          --                 local function showInfoHandler(hd,fn,idx)
          --                   if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
          --                     if G_checkClickEnable()==false then
          --                         do
          --                             return
          --                         end
          --                     else
          --                         base.setWaitTime=G_getCurDeviceMillTime()
          --                     end
          --                     tankInfoDialog:create(nil,tankId,self.layerNum+1, true)
          --                   end
          --                 end
                          
          --                 local icon2
          --                 local iconScaleX=1
          --                 local iconScaleY=1
          --                 icon2 = LuaCCSprite:createWithSpriteFrameName(tankCfg.icon,showInfoHandler)
          --                 if icon2:getContentSize().width>100 then
          --                   iconScaleX=0.78*100/150
          --                   iconScaleY=0.78*100/150
          --                 else
          --                   iconScaleX=0.78
          --                   iconScaleY=0.78
          --                 end
          --                 icon2:setScaleX(iconScaleX)
          --                 icon2:setScaleY(iconScaleY)
          --                 icon2:ignoreAnchorPointForPosition(false)
          --                 icon2:setAnchorPoint(ccp(1,0.5))
          --                 icon2:setPosition(ccp(iconX ,iconY))
          --                 icon2:setIsSallow(false)
          --                 icon2:setTouchPriority(-(self.layerNum-1)*20-2)
          --                 cell:addChild(icon2,1)

          --                 local numLabel=GetTTFLabel("x"..tankNum,25)
          --                 numLabel:setAnchorPoint(ccp(1,0))
          --                 numLabel:setPosition(icon2:getContentSize().width-10,0)
          --                 icon2:addChild(numLabel,1)
          --                 numLabel:setScaleX(1/iconScaleX)
          --                 numLabel:setScaleY(1/iconScaleY)
          --             end

          --         end 
          --     end
              
          --     iconX = W - 145 
          --     local denghao=GetTTFLabel("=",30)
          --     denghao:setAnchorPoint(ccp(1,0.5))
          --     denghao:setPosition(iconX ,iconY)
          --     cell:addChild(denghao)

          --     index = index + 1
          -- end

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
        
    end
end