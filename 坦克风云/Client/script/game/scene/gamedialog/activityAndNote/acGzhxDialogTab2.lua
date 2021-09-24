acGzhxDialogTab2={}

function acGzhxDialogTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil

	self.expandIdx={}
    self.expandHeight=G_VisibleSize.height-156
    self.normalHeight=100
    self.extendSpTag=113

	return nc
end

function acGzhxDialogTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initTurning()
  return self.bgLayer
end

function acGzhxDialogTab2:updateTv()
  if self and self.tv2 then
    self.tv2:reloadData()
  end
end
function acGzhxDialogTab2:initTurning( ... )

  self.aid,self.tankid=acGzhxVoApi:getTankID()
	local function bgClick( ... )
		-- body
	end
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",CCRect(50, 20, 1, 1),bgClick)
	backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 150))
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2, G_VisibleSizeHeight - 315))
	self.bgLayer:addChild(backSprie)


  local desTv, desLabel = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-200, 140),getlocal("activity_gzhx_Tab2_desc",{getlocal(tankCfg[self.tankid].name)}),25,kCCTextAlignmentLeft)
  backSprie:addChild(desTv)
  desTv:setPosition(ccp(10,5))
  desTv:setAnchorPoint(ccp(0,0))
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  desTv:setMaxDisToBottomOrTop(100)

   local function touch(tag,object)
    PlayEffect(audioCfg.mouseClick)
    local tabStr={}
    tabStr={getlocal("activity_gzhx_Tab2_desc1"),getlocal("activity_refitPlanT99_Tab2_desc2")}
    local colorTb={}
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr,colorTb)
    
  end
  local scale=0.8
  local menuItemDesc=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touch,0,getlocal("shuoming"),25/scale)
  menuItemDesc:setScale(scale)
  menuItemDesc:setAnchorPoint(ccp(1,0.5))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(backSprie:getContentSize().width-20, backSprie:getContentSize().height/2))
  backSprie:addChild(menuDesc)

  
  local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function touchHander()

    end

  local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),touchHander)
  tvBg:setAnchorPoint(ccp(0.5,0))
  tvBg:setContentSize(CCSize(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight - 355))
  tvBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
  self.bgLayer:addChild(tvBg)

	local function callBack(...)
		return self:eventHandler2(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight - 365),nil)
  self.tv2:setPosition(ccp(0,5))

	self.tv2:setMaxDisToBottomOrTop(120)
  self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	tvBg:addChild(self.tv2,1)

end
function acGzhxDialogTab2:eventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1 --SizeOfTable(self.tankResultTypeTab)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
    if G_isIphone5()==true then
      tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight - 365)
    else
      tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight - 165)
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

function acGzhxDialogTab2:loadCCTableViewCell(cell,idx,refresh)
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function touchHander()

    end
    local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),touchHander)
    exBg:setAnchorPoint(ccp(0,0))
    local exBgHeight
    if G_isIphone5()==true then
      exBgHeight=G_VisibleSize.height-650
      exBg:setContentSize(CCSize(560,exBgHeight))
      exBg:setPosition(ccp(10,155))
    else
      exBgHeight=G_VisibleSize.height-460
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
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self and self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
          tankInfoDialog:create(exBg,self.tankid,self.layerNum+1)
        end
        
    end

    local spriteIcon = LuaCCSprite:createWithSpriteFrameName(tankCfg[self.tankid].icon,touchInfo);
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

    local lifeLb=GetTTFLabel(tankCfg[self.tankid].life,24)
    lifeLb:setAnchorPoint(ccp(0,0.5))
    lifeLb:setPosition(ccp(210,exBg:getContentSize().height+35))
    exBg:addChild(lifeLb)
    
    local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
    attackSp:setAnchorPoint(ccp(0,0.5));
    attackSp:setPosition(150,exBg:getContentSize().height+90)
    exBg:addChild(attackSp,2)
    attackSp:setScale(iconScale)

    local attLb=GetTTFLabel(tankCfg[self.tankid].attack,24)
    attLb:setAnchorPoint(ccp(0,0.5))
    attLb:setPosition(ccp(210,exBg:getContentSize().height+90))
    exBg:addChild(attLb)
    
    local typeStr = "pro_ship_attacktype_"..tankCfg[self.tankid].attackNum

    local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
    attackTypeSp:setAnchorPoint(ccp(0,0.5));
    attackTypeSp:setPosition(310,exBg:getContentSize().height+90)
    exBg:addChild(attackTypeSp,2)
    attackTypeSp:setScale(iconScale)
    local strWidth2 = 200
    if G_getCurChoseLanguage() =="ar" then
        strWidth2 = 140
    end
    local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),24,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    attTypeLb:setAnchorPoint(ccp(0,0.5))
    attTypeLb:setPosition(ccp(370,exBg:getContentSize().height+90))
    exBg:addChild(attTypeLb)

    if abilityCfg[tankCfg[self.tankid].abilityID]~=nil then
        local nameS=abilityCfg[tankCfg[self.tankid].abilityID][tonumber(tankCfg[self.tankid].abilityLv)].icon
        local attackTypeSp1 = CCSprite:createWithSpriteFrameName(nameS);
        attackTypeSp1:setAnchorPoint(ccp(0,0.5));
        attackTypeSp1:setPosition(310,exBg:getContentSize().height+35)
        exBg:addChild(attackTypeSp1,2)
        attackTypeSp1:setScale(iconScale)
        
        local nameN=abilityCfg[tankCfg[self.tankid].abilityID][tonumber(tankCfg[self.tankid].abilityLv)].name
        local attackTypeLb1=GetTTFLabelWrap(getlocal(nameN),24,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)--第二列第二行增加宽度限制
        attackTypeLb1:setAnchorPoint(ccp(0,0.5))
        attackTypeLb1:setPosition(ccp(370,exBg:getContentSize().height+35))
        exBg:addChild(attackTypeLb1)

    end


    
    
    local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
    bgSp:setAnchorPoint(ccp(0,0.5));
    bgSp:setPosition(0,-30);
    exBg:addChild(bgSp,1);
    
    self:exbgCellForId(exBg)

end

function acGzhxDialogTab2:exbgCellForId(container)
  local addH=11;
  local reR1,reR2,reR3,reR4,reUpgradedMoney = acGzhxVoApi:getUpgradedTankResources()
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
  

  

  local tb={
  {titleStr="metal",spName="resourse_normal_metal.png",needStr=FormatNumber(reR1),haveStr=FormatNumber(playerVoApi:getR1()),num1=playerVoApi:getR1(),num2=tonumber(reR1)},
  {titleStr="oil",spName="resourse_normal_oil.png",needStr=FormatNumber(reR2),haveStr=FormatNumber(playerVoApi:getR2()),num1=playerVoApi:getR2(),num2=tonumber(reR2)},
  {titleStr="silicon",spName="resourse_normal_silicon.png",needStr=FormatNumber(reR3),haveStr=FormatNumber(playerVoApi:getR3()),num1=playerVoApi:getR3(),num2=tonumber(reR3)},
  {titleStr="uranium",spName="resourse_normal_uranium.png",needStr=FormatNumber(reR4),haveStr=FormatNumber(playerVoApi:getR4()),num1=playerVoApi:getR4(),num2=tonumber(reR4)},

    
  }
  local UpgradePropConsume = acGzhxVoApi:getUpgradePropConsume()
  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) and (UpgradePropConsume[2]~=nil and UpgradePropConsume[2][1]~=nil) then
     local pid1 = UpgradePropConsume[1][1]
     local pid2 = UpgradePropConsume[2][1]
     print(pid1,pid2)
     local nameStr1=propCfg[pid1].name
     local numStr1=UpgradePropConsume[1][2]
     local nameStr2=propCfg[pid2].name
     local numStr2=UpgradePropConsume[2][2]


     local tb1={titleStr=nameStr1,spName=propCfg[pid1].icon,needStr=FormatNumber(numStr1),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num2=tonumber(numStr1)}
     local tb2={titleStr=nameStr2,spName=propCfg[pid2].icon,needStr=FormatNumber(numStr2),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num2=tonumber(numStr2)}
     table.insert(tb,tb1)
     table.insert(tb,tb2)
  end

  local needTankID,needTankNum = acGzhxVoApi:getRefitNeedTankIDAndNum()
  local haveTankNum
  if needTankID and needTankID>0 then
    haveTankNum=tankVoApi:getTankCountByItemId(needTankID)
    local tb3={titleStr=tankCfg[needTankID].name,spName=tankCfg[needTankID].icon,needStr=1,haveStr=FormatNumber(haveTankNum),num1=haveTankNum,num2=needTankNum}
    table.insert(tb,tb3)
  end

  local addy=60
  local countTb = {}

  for k,v in pairs(tb) do
      local r1Lb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      r1Lb:setAnchorPoint(ccp(0.5,0.5))
      r1Lb:setPosition(ccp(150,container:getContentSize().height-100+addH-(k-1)*addy))
      container:addChild(r1Lb)

      local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
      r1Sp:setAnchorPoint(ccp(0.5,0.5))
      r1Sp:setPosition(ccp(40,container:getContentSize().height-100+addH-(k-1)*60))
      container:addChild(r1Sp)
      if v.titleStr==tankCfg[needTankID].name then
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
        local tid=tonumber(self.aid)
        local nums=math.floor(tonumber(slider:getValue()))
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 

        PlayEffect(audioCfg.mouseClick)
        if self and self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
            local activeName=acGzhxVoApi:getActiveName()
            local function serverUpgrade(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
                local tankName=getlocal(tankCfg[self.tankid].name)
                local makeTankTip=getlocal("active_lottery_reward_tank",{tankName," x"..nums})
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),makeTankTip,28)
                self.tv2:reloadData()

                --聊天公告
                local paramTab={}
                paramTab.functionStr=activeName
                paramTab.addStr="i_also_want"
                local nameData={key=tankCfg[self.tankid].name,param={}}
                local message={key="activity_gzhx_chatMessage1",param={playerVoApi:getPlayerName(),getlocal("activity_gzhx_title"),nameData}}
                chatVoApi:sendSystemMessage(message,paramTab)
              end
          end
          socketHelper:acGzhxCompose(nums,self.aid,serverUpgrade,activeName)
        end
        
   
    end
    local scale=0.8
    local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touch1,11,getlocal("compose"),28/scale)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menuItem1:setScale(scale)
    menu1:setPosition(ccp(460,-95));
    menu1:setTouchPriority(-(self.layerNum-1)*20-4);
    container:addChild(menu1,3);

  if UpgradePropConsume~=nil and  (UpgradePropConsume[1]~=nil and UpgradePropConsume[1][1]~=nil) and (UpgradePropConsume[2]~=nil and UpgradePropConsume[2][1]~=nil) then
      local pid1 = UpgradePropConsume[1][1]
      local pid2 = UpgradePropConsume[2][1]
      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
      local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))) 

      if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) and
    haveTankNum>=1 and numP1>=1 and numP2>=1
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
        
        local numTab = {num1,num2,num3,num4,num5}

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
        
        local tnum1=playerVoApi:getR1()/tonumber(reR1)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(reR2)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(reR3)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(reR4)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        
        local numTab = {num1,num2,num3,num4,num5}

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

function acGzhxDialogTab2:dispose()
end

