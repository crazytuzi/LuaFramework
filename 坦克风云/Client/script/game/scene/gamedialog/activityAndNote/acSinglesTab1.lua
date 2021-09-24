acSinglesTab1={


}

function acSinglesTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil

    self.tokenNumTb={} 
    self.iconTb={}
    self.isToday =nil

    self.awardData=nil

    self.state = 0
    self.itemPosition={}
    selectItem=nil
    rightItem=nil
    leftItem = nil
    self.spTb={}
    self.selectItemPositionX=nil

    self.iconList=0
    self.itemList={}

    self.lotteryPtype = nil
    self.lotteryPID = nil
    self.lotteryPNum= nil

    return nc;

end

function acSinglesTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

   local function touchDialog()
      if self.state == 2 then
        PlayEffect(audioCfg.mouseClick)
        self.state = 3
        -- 暂停动画
        -- self:close()
      end
  end
  self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
  self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
  local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
  self.touchDialogBg:setContentSize(rect)
  self.touchDialogBg:setOpacity(0)
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
  self.bgLayer:addChild(self.touchDialogBg,1)

    
    self.isToday = acSinglesVoApi:isToday()
    self:initTableView()

    return self.bgLayer
end

function acSinglesTab1:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,180),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,140))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

  local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(10,self.bgLayer:getContentSize().height - 450))
    self.bgLayer:addChild(characterSp,5)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setScaleY(3)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 450))
    self.bgLayer:addChild(lineSprite,6)

    local lineSprite1 = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite1:setScaleX((G_VisibleSizeWidth)/lineSprite1:getContentSize().width)
    lineSprite1:setScaleY(3)
    lineSprite1:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 600))
    self.bgLayer:addChild(lineSprite1,6)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(400,160))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(180,self.bgLayer:getContentSize().height - 440))
    self.bgLayer:addChild(girlDescBg,4)

    local descTv=G_LabelTableView(CCSize(300,140),getlocal("activity_singles_content"),25,kCCTextAlignmentCenter)
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setAnchorPoint(ccp(0,0))
    descTv:setPosition(ccp(80,10))
    girlDescBg:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2+60,self.bgLayer:getContentSize().height-205))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acSinglesVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2+60, self.bgLayer:getContentSize().height-240))
        self.bgLayer:addChild(timeLabel)
        self.timeLb=timeLabel
        self:updateAcTime()
    end

    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_singles_tip3"),"\n",getlocal("activity_singles_tip2"),"\n",getlocal("activity_singles_tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    --infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,self.bgLayer:getContentSize().height-175))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3)

    for i=1,3 do
    	local pCfg = nil
        local id = "mm_m"..i
        pCfg = acSinglesVoApi:getTokenCfgForShowByPid(id)
        local hadNum = tonumber(acSinglesVoApi:getTokenNumByID(id))
        local pIcon = self:getIcon(pCfg,id)
        local pIconX = 140+((i-1)%3)*180
		    local pIconY = 280
        pIcon:setAnchorPoint(ccp(0.5,0.5))
        pIcon:setPosition(ccp(pIconX,pIconY))
        pIcon:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(pIcon)
        
        local numLb = GetTTFLabel(hadNum,25)
        numLb:setAnchorPoint(ccp(0.5,1))
        numLb:setPosition(pIconX,pIconY-pIcon:getContentSize().height/2)
       	self.bgLayer:addChild(numLb)
       	self.tokenNumTb[id]=numLb
        self.iconTb[id]=ccp(pIconX,pIconY)
    end

    local gemCost=acSinglesVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
    local oneGems=gemCost       --一次抽奖需要金币
    local tenGems=acSinglesVoApi:getLotteryTenCost()      --十次抽奖需要金币

      local leftPosX=self.bgLayer:getContentSize().width/2-150
      local rightPosX=self.bgLayer:getContentSize().width/2+150

      local lbY=140
      self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
      self.goldSp1:setAnchorPoint(ccp(1,0.5))
      self.goldSp1:setPosition(ccp(leftPosX-10,lbY))
      self.bgLayer:addChild(self.goldSp1)
      self.goldSp1:setScale(1.5)

      self.gemsLabel1=GetTTFLabel(oneGems,30)
      self.gemsLabel1:setAnchorPoint(ccp(0,0.5))
      self.gemsLabel1:setPosition(ccp(leftPosX,lbY))
      self.bgLayer:addChild(self.gemsLabel1,1)

      local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
      goldSp2:setAnchorPoint(ccp(1,0.5))
      goldSp2:setPosition(ccp(rightPosX-70,lbY))
      self.bgLayer:addChild(goldSp2)
      goldSp2:setScale(1.5)

      local oldgemsLabel2=GetTTFLabel(acSinglesVoApi:getLotteryOldTenCost(),25)
      oldgemsLabel2:setAnchorPoint(ccp(0,0.5))
      oldgemsLabel2:setPosition(ccp(rightPosX-70,lbY))
      self.bgLayer:addChild(oldgemsLabel2,1)

      local line = CCSprite:createWithSpriteFrameName("redline.jpg")
      line:setScaleX((oldgemsLabel2:getContentSize().width+20) / line:getContentSize().width)
      line:setAnchorPoint(ccp(0, 0))
      line:setPosition(ccp(rightPosX-80,lbY-3))
      self.bgLayer:addChild(line,7)

      local gemsLabel2=GetTTFLabel(tenGems,30)
      gemsLabel2:setAnchorPoint(ccp(0,0.5))
      gemsLabel2:setPosition(ccp(rightPosX,lbY))
      self.bgLayer:addChild(gemsLabel2,1)

      

      self:updateShow()


      local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
      bgSp:setAnchorPoint(ccp(0.5,1));
      bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,self.bgLayer:getContentSize().height - 450));
      bgSp:setScaleX(self.bgLayer:getContentSize().width/bgSp:getContentSize().width)
      bgSp:setScaleY(150/bgSp:getContentSize().height)
      self.bgLayer:addChild(bgSp)

      local rightMaskSp=CCSprite:createWithSpriteFrameName("singlesMask.png");
      rightMaskSp:setAnchorPoint(ccp(1,1));
      rightMaskSp:setPosition(ccp(self.bgLayer:getContentSize().width-25,self.bgLayer:getContentSize().height - 450));
      --rightMaskSp:setScaleX(200/rightMaskSp:getContentSize().width)
      rightMaskSp:setScaleY(150/rightMaskSp:getContentSize().height)
      self.bgLayer:addChild(rightMaskSp,5)

      local leftMaskSp=CCSprite:createWithSpriteFrameName("singlesMask.png");
      leftMaskSp:setFlipX(true)
      leftMaskSp:setAnchorPoint(ccp(0,1));
      leftMaskSp:setPosition(ccp(25,self.bgLayer:getContentSize().height - 450));
      --leftMaskSp:setScaleX(200/leftMaskSp:getContentSize().width)
      leftMaskSp:setScaleY(150/leftMaskSp:getContentSize().height)
      self.bgLayer:addChild(leftMaskSp,5)
      

      local itemPosY = self.bgLayer:getContentSize().height-525
      --self:getItemIcon()
      acSinglesTab1:getItemList()
      self.items={3,5,9}
      for k,v in pairs(self.items) do
        local iconSp = CCSprite:createWithSpriteFrameName("Icon_BG.png")
        if k==1 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,itemPosY))
        elseif k==2 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width/4,itemPosY))
        elseif k==3 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,itemPosY))
        end

        local pCfg = acSinglesVoApi:getTokenCfgForShowByPid(v)
        -- local icon = CCSprite:createWithSpriteFrameName(pCfg.icon)
        -- icon:setAnchorPoint(ccp(0.5,0.5))
        local icon= self:getItemIcon(v)--self.iconList[v]
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(getCenterPoint(iconSp))
        icon:setTag(1010)
        iconSp:addChild(icon)
        

        iconSp:setScale(1.4-math.abs(self.bgLayer:getContentSize().width/2-iconSp:getPositionX())/(self.bgLayer:getContentSize().width/2))

        self.bgLayer:addChild(iconSp)
        self.spTb[k]={}
        self.spTb[k].sp=iconSp
        self.spTb[k].id=v
        self.itemPosition[k]=iconSp:getPosition()
      end

end

function acSinglesTab1:getItemList()
  local rewardListcfg = acSinglesVoApi:getCircleListCfg()
  self.iconList = 0
  if rewardListcfg then
    for k,v in pairs(rewardListcfg) do
      if k=="mm" then
        for m,n in pairs(v) do
          if n then
            local indexs
            local icon
            local id
            local num
            for i,j in pairs(n) do
                if i=="index" then
                  indexs=j
                else
                  id=i
                  num = j
                  local pCfg  = acSinglesVoApi:getTokenCfgForShowByPid(i)
                  icon= CCSprite:createWithSpriteFrameName(pCfg.icon)
                  local numLb = GetTTFLabel("x"..j,25)
                  numLb:setAnchorPoint(ccp(1,0))
                  numLb:setPosition(ccp(icon:getContentSize().width-10,10))
                  icon:addChild(numLb)
                end
            end
            self.iconList = self.iconList+1
            self.itemList[indexs]={type=k,key=id,num=num}
          end
          
        end
      else
         local tb = {}
          tb[k]=v
          local award = FormatItem(tb,true,true) or {}
          if award ~= nil then
             for m,n in pairs(award) do
              local icon, iconScale = G_getItemIcon(n ,100, true, self.layerNum)

              local numLb = GetTTFLabel("x"..n.num,25)
              numLb:setAnchorPoint(ccp(1,0))
              numLb:setPosition(ccp(icon:getContentSize().width-10,10))
              icon:addChild(numLb)
              self.iconList=self.iconList+1
              self.itemList[n.index]=n
            end
          end
      end
    end
  end
end

function acSinglesTab1:getItemIcon(id)
  local rewardListcfg = acSinglesVoApi:getCircleListCfg()
  if rewardListcfg then
    for k,v in pairs(rewardListcfg) do
      if k=="mm" then
        for m,n in pairs(v) do
          if n then
            local indexs
            local icon
            for i,j in pairs(n) do
                if i=="index" then
                  indexs=j
                else
                  local pCfg  = acSinglesVoApi:getTokenCfgForShowByPid(i)
                  icon= CCSprite:createWithSpriteFrameName(pCfg.icon)
                  local numLb = GetTTFLabel("x"..j,25)
                  numLb:setAnchorPoint(ccp(1,0))
                  numLb:setPosition(ccp(icon:getContentSize().width-10,10))
                  icon:addChild(numLb)
                end
            end
            if indexs == id then
              return icon
            end
          end
          
        end
      else
         local tb = {}
          tb[k]=v
          local award = FormatItem(tb,true,true) or {}
          if award ~= nil then
             for m,n in pairs(award) do
              local icon, iconScale = G_getItemIcon(n ,100, true, self.layerNum)

              local numLb = GetTTFLabel("x"..n.num,25)
              numLb:setAnchorPoint(ccp(1,0))
              numLb:setPosition(ccp(icon:getContentSize().width-10,10))
              icon:addChild(numLb)

              if n.index == id then
                return icon
              end
            end
          end
      end
    end
  end
end

function acSinglesTab1:getRandomID()
  
  if self.iconList and type(self.iconList)=="table" then
    local randomID = math.random(1,SizeOfTable(self.iconList))
    local hasAdd = false
    for k,v in pairs(self.items) do
      if v and v == randomID then
        hasAdd = true
      end
    end
    if hasAdd == false then
      table.insert(self.items,randomID)
      return self.iconList[randomID]
    else
      self:getOneIcon()
    end
  end
end

function acSinglesTab1:updateShow()

  local gemCost=acSinglesVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
    local oneGems=gemCost       --一次抽奖需要金币
    local tenGems=acSinglesVoApi:getLotteryTenCost()      --十次抽奖需要金币

    local function btnCallback(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end 

          PlayEffect(audioCfg.mouseClick)

          local free=0              --是否是第一次免费
          if acSinglesVoApi:isToday()==true then
            free=1
          end
          local num
          if tag==1 then
            if free==1 and playerVoApi:getGems()<oneGems then
              GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
              do return end
            end
            num=1
          elseif tag==2 then
            if playerVoApi:getGems()<tenGems then
              GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems)
              do return end
            end
            num=11
          end
          
          local function lotteryCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data==nil then
                  do return end
                end
                
                if tag==1 then
                  if free==1 then
                    playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
                  end
                elseif tag==2 then
                  playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
                end

              --刷新活动数据
                local tipStr=""
                local getTank1=false
                local getTank2=false
                if sData.data["clientReward"] then
                  self.awardData=sData.data["clientReward"]

                  
                  local str = ""
                  local nameStr 
                  local content = {}
                  for k,v in pairs(self.awardData) do
                    local ptype = v[1]
                    local pID = v[2]
                    local num = v[3]
                    local award = {}

                    self.lotteryPtype = ptype
                    self.lotteryPID = pID
                    self.lotteryPNum= num
                    if ptype == "mm" then
                      acSinglesVoApi:updateSelfTokens(pID,num)
                      pCfg = acSinglesVoApi:getTokenCfgForShowByPid(pID)
                      -- nameStr=getlocal(pCfg.name)
                      -- self:updateTokenNum(pID)
                      award={name=getlocal(pCfg.name),num=num,type=ptype,key=pID,pic=pCfg.icon,desc=pCfg.des}
                    else
                      local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
                     -- nameStr = name
                      award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId}
                      G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                    end
                    -- if k==SizeOfTable(self.awardData) then
                    --     str = str .. nameStr .. " x" .. num
                    -- else
                    --     str = str .. nameStr .. " x" .. num .. ","
                    -- end
                    table.insert(content,{award=award})


                  end

                  if tag==1 then
                      self:startPalyAnimation()
                    else
                      if content and SizeOfTable(content)>0 then
                          local function confirmHandler(index)
                            self:result()
                          end
                          smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,true)
                      end
                    end
                  --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

                end
              end
           end
         
          local function getRwardCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
              local i = 1
              local str = ""
              local tokenRewardCfg = acSinglesVoApi:getVipReward()
              if tokenRewardCfg and SizeOfTable(tokenRewardCfg)>0 then
                for k,v in pairs(tokenRewardCfg) do
                  if k and v then
                    acSinglesVoApi:updateLastTime()
                    acSinglesVoApi:updateSelfTokens(k,v)
                    self:updateTokenNum(k)
                    self:updateShow()
                    acSinglesVoApi:updateShow()
                    local pCfg = acSinglesVoApi:getTokenCfgForShowByPid(k)
                    nameStr=getlocal(pCfg.name)
                    if i==SizeOfTable(tokenRewardCfg) then
                        str = str .. nameStr .. " x" .. v
                    else
                        str = str .. nameStr .. " x" .. v .. ","
                    end
                    i=i+1
                  end
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

                end
              end

            end
          end
          if free ==0 then
             socketHelper:activitySinglesDailyReward(getRwardCallback)
          else
             socketHelper:activitySinglesLotteryReward(num,lotteryCallback)
          end
      end

    local leftPosX=self.bgLayer:getContentSize().width/2-150
    local rightPosX=self.bgLayer:getContentSize().width/2+150
    local btnY=70
   

    self.lotteryTenBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",btnCallback,2,getlocal("activity_singles_elevenBtn"),25)
    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
    lotteryMenu1:setPosition(ccp(rightPosX,btnY))
    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(lotteryMenu1,2)

  if acSinglesVoApi:isToday()==false then
    -- local lb=tolua.cast(self.lotteryOneBtn:getChildByTag(101),"CCLabelTTF")
    -- lb:setString(getlocal("daily_scene_get"))

    self.lotteryOneBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("daily_scene_get"),25)


    self.goldSp1:setVisible(false)
    self.lotteryTenBtn:setEnabled(false)
    self.gemsLabel1:setVisible(false)
  else

    self.lotteryOneBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",btnCallback,1,getlocal("active_lottery_btn1"),25,101)

    self.goldSp1:setVisible(true)
    self.gemsLabel1:setVisible(true)
    self.lotteryTenBtn:setEnabled(true)
  end

  self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
  local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
  lotteryMenu:setPosition(ccp(leftPosX,btnY))
  lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
  self.bgLayer:addChild(lotteryMenu,2)
end

function acSinglesTab1:updateTokenNum(id)
  local numLb = self.tokenNumTb[id]
  local hadNum = tonumber(acSinglesVoApi:getTokenNumByID(id))
  numLb:setString(tostring(hadNum))
end
function acSinglesTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,180)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end
function acSinglesTab1:getIcon(pCfg,id)
  local function showInfoHandler(hd,fn,idx)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      local hadNum = tonumber(acSinglesVoApi:getTokenNumByID(id))
      local item = {name = getlocal(pCfg.name), pic= pCfg.icon, num = hadNum, desc = pCfg.des}
      propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true)
    end
  local pIcon = LuaCCSprite:createWithSpriteFrameName(pCfg.icon,showInfoHandler)
  return pIcon
end

function acSinglesTab1:fastTick()
  if self.state == 2 then
    self:moveSp()
  elseif self.state == 3 then
    self:stopPlayAnimation()

  end
end

function acSinglesTab1:startPalyAnimation()
  --self.speed=5 
  self.moveDis=0
  self.isStop=false
  self.state = 2
  self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
  --base:addNeedRefresh(self)
  print("得到抽取结果~")
end

function acSinglesTab1:stopPlayAnimation()
  print("正常~")
  self.state = 0
  self:result()
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  --base:removeFromNeedRefresh(self)
end



function acSinglesTab1:moveSp()
  self.moveDis=self.moveDis+1

  for k,v in pairs(self.spTb) do

      local newPosotionX = v.sp:getPositionX()
      if (newPosotionX<self.bgLayer:getContentSize().width/2) and (newPosotionX+20)>self.bgLayer:getContentSize().width/2 then
        newPosotionX = self.bgLayer:getContentSize().width/2
      else
        newPosotionX = newPosotionX+20
      end

        v.sp:setPosition(ccp(newPosotionX,v.sp:getPositionY()))

        v.sp:setScale(1.4-math.abs(self.bgLayer:getContentSize().width/2-v.sp:getPositionX())/(self.bgLayer:getContentSize().width/2))
        if v.sp:getPositionX()>=(self.bgLayer:getContentSize().width-60) then 
          local key = k+1
          if key==4 then
            key=1
          end
          -- local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("guanggun.png")
          -- v:setDisplayFrame(frame)


          local icon = v.sp:getChildByTag(1010)
          if icon then
            icon:removeFromParentAndCleanup(true)
          end
          local randomID = math.random(1,self.iconList)
          local newIcon = self:getItemIcon(randomID)
          newIcon:setAnchorPoint(ccp(0.5,0.5))
          newIcon:setPosition(getCenterPoint(v.sp))
          newIcon:setTag(1010)
          v.sp:addChild(newIcon)
          v.sp:setPosition(ccp(60,v.sp:getPositionY()))
          v.id=randomID
        end
        local item = self.itemList[v.id]
        if self.moveDis>100 and (item.type==self.lotteryPtype and item.key==self.lotteryPID and item.num==self.lotteryPNum) and (v.sp:getPositionX()==self.bgLayer:getContentSize().width/2) and self.isStop== false then
          self.isStop=true
        end
  end

  

  if self.isStop==true  then
    self.state = 3
    print("动画播放结束： ", self.state)
  end
end

function acSinglesTab1:result()
 
    local index
    for k,v in pairs(self.itemList) do
      if v then
        if (v.type==self.lotteryPtype and v.key==self.lotteryPID and v.num==self.lotteryPNum) then
          index = k
        end
      end
    end

 if self.isStop == false then
      for k,v in pairs(self.spTb) do
          local icon = v.sp:getChildByTag(1010)
          if icon then
            icon:removeFromParentAndCleanup(true)
          end
          local newIcon
          if k == 1 then
            newIcon= self:getItemIcon(index)
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width/2,v.sp:getPositionY()))
            v.id=index
          elseif k==2 then
            if index==1 then
              newIcon= self:getItemIcon(self.iconList)
              v.id=self.iconList
            else
              newIcon= self:getItemIcon(index-1)
              v.id=index-1
            end
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width/4,v.sp:getPositionY()))
          elseif k==3 then
            if index==self.iconList then
              newIcon= self:getItemIcon(1)
              v.id=1
            else
              newIcon= self:getItemIcon(index+1)
              v.id=index+1
            end
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,v.sp:getPositionY()))
          end
          v.sp:setScale(1.4-math.abs(self.bgLayer:getContentSize().width/2-v.sp:getPositionX())/(self.bgLayer:getContentSize().width/2))
      end

  end
  
  local str = ""
  local nameStr 
  for k,v in pairs(self.awardData) do
    local ptype = v[1]
    local pID = v[2]
    local num = v[3]
    local award = {}
    if ptype == "mm" then
      pCfg = acSinglesVoApi:getTokenCfgForShowByPid(pID)  
      self:playEndEffect(pID,pCfg.icon)
      nameStr=getlocal(pCfg.name)
      
    else
      local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
      nameStr = name
    end
    if k==SizeOfTable(self.awardData) then
        str = str .. nameStr .. " x" .. num
    else
        str = str .. nameStr .. " x" .. num .. ","
    end
  end
  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

  
end

function acSinglesTab1:playEndEffect(mtype,iconStr)
   local pieceSp=CCSprite:createWithSpriteFrameName(iconStr)
    pieceSp:setAnchorPoint(ccp(0.5,0.5))
    pieceSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-525))
    pieceSp:setScale(1.4)
    self.bgLayer:addChild(pieceSp,1000)

    local function playEndCallback1()
        pieceSp:removeFromParentAndCleanup(true)
        pieceSp=nil
        self:updateTokenNum(mtype)
    end
    local callFunc=CCCallFuncN:create(playEndCallback1)

    local function hideLight()
    end
    local callFunc1=CCCallFuncN:create(hideLight)

    local delay=CCDelayTime:create(0.5)
    local mvTo0=CCMoveTo:create(0.5,self.iconTb[mtype])
    local scaleTo=CCScaleTo:create(0.2,2)
    local scaleTo1=CCScaleTo:create(0.3,0.2)

    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc1)
    acArr:addObject(mvTo0)

    acArr:addObject(scaleTo)
    acArr:addObject(scaleTo1)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    pieceSp:runAction(seq)
end

function acSinglesTab1:updateAcTime()
    local acVo=acSinglesVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acSinglesTab1:tick()
  local istoday = acSinglesVoApi:isToday()
  if istoday ~= self.isToday then
    self:updateShow()
    self.isToday = istoday
  end
  self:updateAcTime()
end

function acSinglesTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.timeLb=nil
    self = nil
end
