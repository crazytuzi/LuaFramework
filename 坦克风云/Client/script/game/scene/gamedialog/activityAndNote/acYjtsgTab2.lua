acYjtsgTab2={}


function acYjtsgTab2:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  self.bgLayer=nil
  self.layerNum=nil
   self.expandIdx={}

    if G_isIphone5() then
       self.expandHeight=G_VisibleSize.height-180
    else
       self.expandHeight=1136-180
    end
    self.normalHeight=130

  return nc
end

function acYjtsgTab2:init(layerNum)
  self.bgLayer=CCLayer:create()
  self.layerNum=layerNum
  self:initLayer()
  return self.bgLayer
end

function acYjtsgTab2:initLayer()
  self.aidTb,self.tankidTb=acYjtsgVoApi:getTankID()
  self.cellNum=SizeOfTable(acYjtsgVoApi:getRefitTankNeedCfg())
  self:initTableView()
end

function acYjtsgTab2:initTableView()
  local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-75-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv,3)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acYjtsgTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
      local tmpSize
       if self.expandIdx["k"..idx]~=nil then
          tmpSize=CCSizeMake(600,self.expandHeight)
       else
          tmpSize=CCSizeMake(600,self.normalHeight)
       end
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

function acYjtsgTab2:loadCCTableViewCell(cell,idx)
  local expanded=false
  if self.expandIdx["k"..idx]==nil then
       expanded=false
  else
       expanded=true
  end
  if expanded then
      cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.expandHeight))
  else
      cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
  end
  local rect = CCRect(0, 0, 50, 50);
  local capInSet = CCRect(50, 20, 1, 1)

  local function cellClick(hd,fn,idx)   
        return self:cellClick(idx)
  end
  local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",capInSet,cellClick)
  headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
  headerSprie:ignoreAnchorPointForPosition(false);
  headerSprie:setAnchorPoint(ccp(0,0));
  headerSprie:setTag(1000+idx)
  headerSprie:setIsSallow(false)
  headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
  headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
  cell:addChild(headerSprie)

  local lbName=GetTTFLabel(getlocal(tankCfg[self.tankidTb[idx+1]].name),26)
  lbName:setColor(G_ColorGreen)
  lbName:setPosition(120,headerSprie:getContentSize().height/2)
  lbName:setAnchorPoint(ccp(0,0.5));
  headerSprie:addChild(lbName,2)


  local sprite = CCSprite:createWithSpriteFrameName(tankCfg[self.tankidTb[idx+1]].icon);
  sprite:setAnchorPoint(ccp(0,0.5));
  sprite:setPosition(20,headerSprie:getContentSize().height/2)
  sprite:setScale(0.5)
  headerSprie:addChild(sprite)
  -- print("++++++idx",idx,self:moreOrless(idx))

   local btn
   if expanded==false then
       if self:moreOrless(idx)==false then
            btn=GraySprite:createWithSpriteFrameName("moreBtn.png")
       else
            btn=CCSprite:createWithSpriteFrameName("moreBtn.png")

       end
   else
       if self:moreOrless(idx)==false then
            btn=GraySprite:createWithSpriteFrameName("lessBtn.png")
       else
            btn=CCSprite:createWithSpriteFrameName("lessBtn.png")
       end

   end
   btn:setAnchorPoint(ccp(0,0))
   btn:setPosition(ccp(headerSprie:getContentSize().width-15-btn:getContentSize().width,10))
   headerSprie:addChild(btn)

  if expanded==true then --显示展开信息
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(19,19,2,2)
    local function touchHander()

    end
    local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",capInSet,touchHander)
    exBg:setAnchorPoint(ccp(0,0))
    local exBgHeight
    if G_isIphone5()==true then
      exBgHeight=G_VisibleSize.height-600
      exBg:setContentSize(CCSize(560,exBgHeight))
      exBg:setPosition(ccp(10,155))
    else
      exBgHeight=G_VisibleSize.height-410
      exBg:setContentSize(CCSize(560,exBgHeight))
      exBg:setPosition(ccp(10,155))
    end
    cell:addChild(exBg)

    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,exBg:getContentSize().height/2))
    exBg:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(exBg:getContentSize().width-5,exBg:getContentSize().height/2))
    exBg:addChild(pointSp2)

    local function touchInfo()
         if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
              if G_checkClickEnable()==false then
                  do
                      return
                  end
              else
                  base.setWaitTime=G_getCurDeviceMillTime()
              end
          end
          PlayEffect(audioCfg.mouseClick)
          tankInfoDialog:create(exBg,self.tankidTb[idx+1],self.layerNum+1)
      end

      local spriteIcon = LuaCCSprite:createWithSpriteFrameName(tankCfg[self.tankidTb[idx+1]].icon,touchInfo);
      spriteIcon:setAnchorPoint(ccp(0,0.5));
      spriteIcon:setScale(0.6)
      spriteIcon:setTouchPriority(-(self.layerNum-1)*20-4)
      spriteIcon:setPosition(10,exBg:getContentSize().height+70)
      exBg:addChild(spriteIcon,2)

      local menuItemInfo = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
      local menuInfo = CCMenu:createWithItem(menuItemInfo);
      menuInfo:setPosition(ccp(520,exBg:getContentSize().height+70));
      menuInfo:setTouchPriority(-(self.layerNum-1)*20-4);
      --:addChild(menuInfo,3);
      
      local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
      local iconScale= 50/lifeSp:getContentSize().width
      lifeSp:setAnchorPoint(ccp(0,0.5));
      lifeSp:setPosition(150,exBg:getContentSize().height+35)
      exBg:addChild(lifeSp,2)
      lifeSp:setScale(iconScale)

      local lifeLb=GetTTFLabel(tankCfg[self.tankidTb[idx+1]].life,24)
      lifeLb:setAnchorPoint(ccp(0,0.5))
      lifeLb:setPosition(ccp(210,exBg:getContentSize().height+35))
      exBg:addChild(lifeLb)
      
      local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
      attackSp:setAnchorPoint(ccp(0,0.5));
      attackSp:setPosition(150,exBg:getContentSize().height+90)
      exBg:addChild(attackSp,2)
      attackSp:setScale(iconScale)

      local needSize = 24
      if G_getCurChoseLanguage() =="ru" then
        needSize = 20
      end
      local attLb=GetTTFLabel(tankCfg[self.tankidTb[idx+1]].attack,24)
      attLb:setAnchorPoint(ccp(0,0.5))
      attLb:setPosition(ccp(210,exBg:getContentSize().height+90))
      exBg:addChild(attLb)
      exBg:setTag(2)
      
      local typeStr = "pro_ship_attacktype_"..tankCfg[self.tankidTb[idx+1]].attackNum
      if tonumber(tankCfg[self.tankidTb[idx+1]].weaponType) > 10 then
          typeStr ="pro_ship_attacktype_"..tankCfg[self.tankidTb[idx+1]].weaponType
      end

      local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
      attackTypeSp:setAnchorPoint(ccp(0,0.5));
      attackTypeSp:setPosition(310,exBg:getContentSize().height+90)
      exBg:addChild(attackTypeSp,2)
      attackTypeSp:setScale(iconScale)

      local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),needSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      attTypeLb:setAnchorPoint(ccp(0,0.5))
      attTypeLb:setPosition(ccp(370,exBg:getContentSize().height+90))
      exBg:addChild(attTypeLb)


      if abilityCfg[tankCfg[self.tankidTb[idx+1]].abilityID]~=nil then
          local nameS=abilityCfg[tankCfg[self.tankidTb[idx+1]].abilityID][tonumber(tankCfg[self.tankidTb[idx+1]].abilityLv)].icon
          local attackTypeSp1 = CCSprite:createWithSpriteFrameName(nameS);
          attackTypeSp1:setAnchorPoint(ccp(0,0.5));
          attackTypeSp1:setPosition(310,exBg:getContentSize().height+35)
          exBg:addChild(attackTypeSp1,2)
          attackTypeSp1:setScale(iconScale)
          
          local nameN=abilityCfg[tankCfg[self.tankidTb[idx+1]].abilityID][tonumber(tankCfg[self.tankidTb[idx+1]].abilityLv)].name
          local attackTypeLb1=GetTTFLabelWrap(getlocal(nameN),needSize,CCSizeMake(130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)--第二列第二行增加宽度限制
          attackTypeLb1:setAnchorPoint(ccp(0,0.5))
          attackTypeLb1:setPosition(ccp(370,exBg:getContentSize().height+35))
          exBg:addChild(attackTypeLb1)

          local skillLvLb=GetTTFLabel(getlocal("fightLevel",{tankCfg[self.tankidTb[idx+1]].abilityLv}),20)
          skillLvLb:setAnchorPoint(ccp(0,0.5))
          skillLvLb:setPosition(ccp(510,exBg:getContentSize().height+35))
          exBg:addChild(skillLvLb)
          skillLvLb:setColor(G_ColorYellowPro)

      end


      
      
      local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
      bgSp:setAnchorPoint(ccp(0,0.5));
      bgSp:setPosition(0,-30);
      exBg:addChild(bgSp,1);
      
      self:exbgCellForId(exBg,idx)
  end
end

function acYjtsgTab2:exbgCellForId(container,idx)
  local addH=11;
  local reR1,reR2,reR3,reR4,reUpgradedMoney = acYjtsgVoApi:getUpgradedTankResources(self.aidTb[idx+1],self.tankidTb[idx+1])
  local typeLb=GetTTFLabel(getlocal("resourceType"),20)
  typeLb:setAnchorPoint(ccp(0.5,0.5))
  typeLb:setPosition(ccp(150,container:getContentSize().height-40+addH))
  container:addChild(typeLb)
  
  local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
  resourceLb:setAnchorPoint(ccp(0.5,0.5))
  resourceLb:setPosition(ccp(300,container:getContentSize().height-40+addH))
  container:addChild(resourceLb)

  local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
  haveLb:setAnchorPoint(ccp(0.5,0.5))
  haveLb:setPosition(ccp(450,container:getContentSize().height-40+addH))
  container:addChild(haveLb)
  
  local tb={}

  if tonumber(reR1)>0 then
    table.insert(tb,{titleStr="metal",spName="resourse_normal_metal.png",needStr=FormatNumber(reR1),haveStr=FormatNumber(playerVoApi:getR1()),num1=playerVoApi:getR1(),num2=tonumber(reR1)})
  end
  if tonumber(reR2)>0 then
    table.insert(tb,{titleStr="oil",spName="resourse_normal_oil.png",needStr=FormatNumber(reR2),haveStr=FormatNumber(playerVoApi:getR2()),num1=playerVoApi:getR2(),num2=tonumber(reR2)})
  end
  if tonumber(reR3)>0 then
    table.insert(tb,{titleStr="silicon",spName="resourse_normal_silicon.png",needStr=FormatNumber(reR3),haveStr=FormatNumber(playerVoApi:getR3()),num1=playerVoApi:getR3(),num2=tonumber(reR3)})
  end
  if tonumber(reR4)>0 then
    table.insert(tb,{titleStr="uranium",spName="resourse_normal_uranium.png",needStr=FormatNumber(reR4),haveStr=FormatNumber(playerVoApi:getR4()),num1=playerVoApi:getR4(),num2=tonumber(reR4)})
  end
  
  local UpgradePropConsume = acYjtsgVoApi:getUpgradePropConsume(self.aidTb[idx+1],self.tankidTb[idx+1])
  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) then
     local pid1 = UpgradePropConsume[1][1]
     
     local nameStr1=propCfg[pid1].name
     local numStr1=UpgradePropConsume[1][2]


     local tb1={titleStr=nameStr1,spName=propCfg[pid1].icon,needStr=FormatNumber(numStr1),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num2=tonumber(numStr1)}
     
     table.insert(tb,tb1)

     if UpgradePropConsume[2] then

        local pid2 = UpgradePropConsume[2][1]
        local nameStr2=propCfg[pid2].name
        local numStr2=UpgradePropConsume[2][2]
        local tb2={titleStr=nameStr2,spName=propCfg[pid2].icon,needStr=FormatNumber(numStr2),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num2=tonumber(numStr2)}
        table.insert(tb,tb2)
     end
     
  end

  local needTankIDTb,needTankNumTb = acYjtsgVoApi:getRefitNeedTankIDAndNum(self.aidTb[idx+1],self.tankidTb[idx+1])
  local haveTankNum
  local haveTankNum1
  if needTankIDTb then
    haveTankNum=tankVoApi:getTankCountByItemId(needTankIDTb[1])
    local tb3={titleStr=tankCfg[needTankIDTb[1]].name,spName=tankCfg[needTankIDTb[1]].icon,needStr=1,haveStr=FormatNumber(haveTankNum),num1=haveTankNum,num2=needTankNumTb[1]}
    table.insert(tb,tb3)
    if SizeOfTable(needTankIDTb)==2 then
      haveTankNum1=tankVoApi:getTankCountByItemId(needTankIDTb[2])
      local tb3={titleStr=tankCfg[needTankIDTb[2]].name,spName=tankCfg[needTankIDTb[2]].icon,needStr=1,haveStr=FormatNumber(haveTankNum1),num1=haveTankNum1,num2=needTankNumTb[2]}
      table.insert(tb,tb3)
    else
      haveTankNum1=1000000000
    end
  end

  local addy=60
  local countTb = {}

  for k,v in pairs(tb) do
      local r1Lb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      r1Lb:setAnchorPoint(ccp(0.5,0.5))
      r1Lb:setPosition(ccp(150,container:getContentSize().height-100+addH-(k-1)*addy))
      container:addChild(r1Lb)

      local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
      r1Sp:setAnchorPoint(ccp(0.5,0.5))
      r1Sp:setPosition(ccp(40,container:getContentSize().height-100+addH-(k-1)*60))
      container:addChild(r1Sp)
      if v.titleStr==tankCfg[needTankIDTb[1]].name or (needTankIDTb[2] and  v.titleStr==tankCfg[needTankIDTb[2]].name) then
        r1Sp:setScale(0.35)
      else
        r1Sp:setScale(0.5)
      end

      local needR1Lb=GetTTFLabel(v.needStr,20)
      needR1Lb:setAnchorPoint(ccp(0.5,0.5))
      needR1Lb:setPosition(ccp(300,container:getContentSize().height-100+addH-(k-1)*addy))
      container:addChild(needR1Lb)

      local haveR1Lb=GetTTFLabel(v.haveStr,20)
      haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
      haveR1Lb:setPosition(ccp(450,container:getContentSize().height-100+addH-(k-1)*addy))
      container:addChild(haveR1Lb)

      local p1Sp;
      if v.num1>=v.num2 then
         p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p1Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p1Sp:setPosition(ccp(400,container:getContentSize().height-100+addH-(k-1)*addy))

      container:addChild(p1Sp)
      countTb[k]=needR1Lb

  end


  local m_numLb=GetTTFLabel(" ",30)
  m_numLb:setPosition(70,-30);
  container:addChild(m_numLb,2);

  local function sliderTouch(handler,object)
      local count = math.floor(object:getValue())
      m_numLb:setString(count)
      if count>0 then
       --lbTime:setString(GetTimeStr(timeConsume*count))
       for k,v in pairs(countTb) do
         v:setString(FormatNumber(tb[k].num2*count))
       end
           
      end

  end
  local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
  local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
  local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
  local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
  slider:setTouchPriority(-(self.layerNum-1)*20-4);
  slider:setIsSallow(true);
  
  slider:setMinimumValue(0.0);
  
  slider:setMaximumValue(100.0);
  
  slider:setValue(0);
  slider:setPosition(ccp(355,-30))
  slider:setTag(99)
  container:addChild(slider,2)
  m_numLb:setString(math.floor(slider:getValue()))
  
  
  local function touchAdd()
      slider:setValue(slider:getValue()+1);
  end
  
  local function touchMinus()
      if slider:getValue()-1>0 then
          slider:setValue(slider:getValue()-1);
      end
  
  end
  
  local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
  addSp:setPosition(ccp(549,-30))
  container:addChild(addSp,1)
  addSp:setTouchPriority(-(self.layerNum-1)*20-4);
  
  local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
  minusSp:setPosition(ccp(157,-30))
  container:addChild(minusSp,1)
  minusSp:setTouchPriority(-(self.layerNum-1)*20-4);


    local function touch1()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
        end
        PlayEffect(audioCfg.mouseClick)
        local tid=tonumber(self.aidTb[idx+1])
        local nums=math.floor(tonumber(slider:getValue()))

       
    local function serverUpgrade(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
        local tankName=getlocal(tankCfg[self.tankidTb[idx+1]].name)
        local makeTankTip=getlocal("activity_diancitanke_reward_tank",{tankName,nums})
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),makeTankTip,28)

        self.tv:reloadData()

        --聊天公告
        local paramTab={}
        paramTab.functionStr=acYjtsgVoApi:getActiveName()
        paramTab.addStr="i_also_want"
        local nameData={key=tankCfg[self.tankidTb[idx+1]].name,param={}}
        local str = getlocal("activity_yjtsg_title")
        local message={key="activity_diancitanke_chatSystemMessage",param={playerVoApi:getPlayerName(),str,nameData}}
        chatVoApi:sendSystemMessage(message,paramTab)
      end
    end
    socketHelper:activityYjtsgRefitTank(nums,self.aidTb[idx+1],serverUpgrade)
        
        
   
    end
    local menuItem1 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,11,getlocal("compose"),28)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(460,-95));
    menu1:setTouchPriority(-(self.layerNum-1)*20-4);
    container:addChild(menu1,3);

  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) and (UpgradePropConsume[2]~=nil and UpgradePropConsume[2][1]~=nil) then
      local pid1 = UpgradePropConsume[1][1]
      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))/UpgradePropConsume[1][2]

      local numP2
      if UpgradePropConsume[2] then
        local pid2 = UpgradePropConsume[2][1]
        numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))) /UpgradePropConsume[2][2]
      end
      if numP2==nil then
        numP2=1
      end
      

      if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) and
    haveTankNum>=1 and haveTankNum1 and haveTankNum1>=1 and numP1>=1 and numP2>=1
     then
        local tnum1=playerVoApi:getR1()/tonumber(reR1)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(reR2)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(reR3)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(reR4)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        local num6
        local numTab
        if haveTankNum1 then
          num6= haveTankNum1
          numTab = {num1,num2,num3,num4,num5,num6}
        else
          numTab = {num1,num2,num3,num4,num5}
        end
         
        
       
        if UpgradePropConsume~=nil then
           table.insert(numTab,numP1)
           table.insert(numTab,numP2)
        end
        table.sort(numTab,function(a,b) return a<b end)
        if numTab[1]>100 then

           slider:setMaximumValue(100);
           
        else

           slider:setMaximumValue(numTab[1]);
           
        end
        
        if numTab[1]==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end
        
        slider:setValue(numTab[1]);
        menuItem1:setEnabled(true)
    else
        slider:setMaximumValue(0);
        menuItem1:setEnabled(false)
        menu1:setTag(199)
    
    end

    else
      if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) 
        --and(haveTankNum and haveTankNum>=1)
     then
        if reR1==0 then
          reR1=1
        end
        if reR2==0 then
          reR2=1
        end
        if reR3==0 then
          reR3=1
        end
        if reR4==0 then
          reR4=1
        end
        local tnum1=playerVoApi:getR1()/tonumber(reR1)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(reR2)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(reR3)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(reR4)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        local num6
        local numTab
        if haveTankNum1 then
          num6= haveTankNum1
          numTab = {num1,num2,num3,num4,num5,num6}
        else
          numTab = {num1,num2,num3,num4,num5}
        end

        local pid1 = UpgradePropConsume[1][1]
        local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))/UpgradePropConsume[1][2]

        local numP2
        if UpgradePropConsume[2] then
          local pid2 = UpgradePropConsume[2][1]
          numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))) /UpgradePropConsume[2][2]
        end
       

       if numP1 then
        table.insert(numTab,numP1)
       end

       if numP2 then
        table.insert(numTab,numP2)
       end



        table.sort(numTab,function(a,b) return a<b end)
        if numTab[1]>100 then

           slider:setMaximumValue(100);
           
        else

           slider:setMaximumValue(numTab[1]);
           
        end
        
        if numTab[1]==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end
        
        slider:setValue(numTab[1]);
        menuItem1:setEnabled(true)
    else
        slider:setMaximumValue(0);
        menuItem1:setEnabled(false)
        menu1:setTag(199)
    
    end

    end
end

function acYjtsgTab2:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

function acYjtsgTab2:moreOrless(idx)
  -- 四种资源
  local reR1,reR2,reR3,reR4,reUpgradedMoney = acYjtsgVoApi:getUpgradedTankResources(self.aidTb[idx+1],self.tankidTb[idx+1])
  local num1=playerVoApi:getR1()
  local num2=playerVoApi:getR2()
  local num3=playerVoApi:getR3()
  local num4=playerVoApi:getR4()

  -- 道具消耗
  local UpgradePropConsume = acYjtsgVoApi:getUpgradePropConsume(self.aidTb[idx+1],self.tankidTb[idx+1])
 
   local pid1 = UpgradePropConsume[1][1]
   local numStr1=UpgradePropConsume[1][2]

   local numStr2=0
   local pid2

   if UpgradePropConsume[2] then
     numStr2=UpgradePropConsume[2][2]
     pid2 = UpgradePropConsume[2][1]
   end

   local haveStr1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
   local haveStr2=0
   if pid2 then
      haveStr2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2)))
   end
   

   local needTankIDTb,needTankNumTb = acYjtsgVoApi:getRefitNeedTankIDAndNum(self.aidTb[idx+1],self.tankidTb[idx+1])

  local needTankNum = needTankNumTb[1]
  local needTankNum1 =  needTankNumTb[2] or 0

  local haveTankNum = tankVoApi:getTankCountByItemId(needTankIDTb[1])
  local haveTankNum1
  if needTankNum1 then
    haveTankNum1 = tankVoApi:getTankCountByItemId(needTankIDTb[2]) or 0
  end
  if num1>=reR1 and num2>=reR2 and num3>=reR3 and num4>=reR4 and haveStr1>=numStr1 and haveStr2>=numStr2 and haveTankNum>=needTankNum and haveTankNum1 and haveTankNum1>=needTankNum1 then
    return true
  end
  return false

end

function acYjtsgTab2:refresh()
  local recordPoint=self.tv:getRecordPoint()
  self.tv:reloadData()
  self.tv:recoverToRecordPoint(recordPoint)
end


function acYjtsgTab2:dispose()
  self.bgLayer=nil
    self.layerNum=nil

end