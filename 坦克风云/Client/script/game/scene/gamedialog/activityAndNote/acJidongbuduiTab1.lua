acJidongbuduiTab1={


}

function acJidongbuduiTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil

    self.isToday =nil

    self.awardData=nil

    self.state = 0

    self.iconList={}
    self.itemList={}
    self.reward={}

    self.lotteryPtype = nil
    self.lotteryPID = nil
    self.lotteryPNum= nil

    self.haloPos=0
    self.td=nil

    return nc;

end

function acJidongbuduiTab1:init(layerNum)
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
  self.bgLayer:addChild(self.touchDialogBg,10)

    
    self.isToday = acJidongbuduiVoApi:isToday()
    self:initTableView()

    return self.bgLayer
end

function acJidongbuduiTab1:initTableView()
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
    -- if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
    --     characterSp = CCSprite:create("public/guide.png")
    -- else
        characterSp = CCSprite:createWithSpriteFrameName("NewCharacter02.png") --姑娘
    --end
    -- characterSp:setScale(0.8)
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(380,self.bgLayer:getContentSize().height - 450))
    self.bgLayer:addChild(characterSp,5)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setScaleY(1.2)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 450))
    self.bgLayer:addChild(lineSprite,6)

    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(380,140))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(80,self.bgLayer:getContentSize().height - 380))
    self.bgLayer:addChild(girlDescBg,4)

    local descTv=G_LabelTableView(CCSize(330,120),getlocal("activity_jidongbudui_desc"),25,kCCTextAlignmentCenter)
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setAnchorPoint(ccp(0,0))
    descTv:setPosition(ccp(20,10))
    girlDescBg:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)

    local turkeyIcon = CCSprite:createWithSpriteFrameName("Turkey.png")
    --turkeyIcon:setScale(0.5)
    turkeyIcon:setAnchorPoint(ccp(0,0))
    turkeyIcon:setPosition(50,self.bgLayer:getContentSize().height - 460)
    self.bgLayer:addChild(turkeyIcon)

    self.turkeyNum = GetTTFLabel("",30)
    self.turkeyNum:setAnchorPoint(ccp(0,0))
    self.turkeyNum:setPosition(100+turkeyIcon:getContentSize().width/2,self.bgLayer:getContentSize().height - 440)
    self.bgLayer:addChild(self.turkeyNum)
    self:updateturkeyNum()
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2-60,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acJidongbuduiVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2-60, self.bgLayer:getContentSize().height-220))
        self.bgLayer:addChild(timeLabel)
    end

    local function showInfo()
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_jidongbudui_LotteryTip4"),"\n",getlocal("activity_jidongbudui_LotteryTip3"),"\n",getlocal("activity_jidongbudui_LotteryTip2"),"\n",getlocal("activity_jidongbudui_LotteryTip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    --infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-25,self.bgLayer:getContentSize().height-175))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3)

    local gemCost=acJidongbuduiVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
    local oneGems=gemCost       --一次抽奖需要金币

    local lbY=(self.bgLayer:getContentSize().height-350)/2-50
    self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp1:setAnchorPoint(ccp(0,0.5))
    self.goldSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbY))
    self.bgLayer:addChild(self.goldSp1)
    self.goldSp1:setScale(1.5)

    self.gemsLabel1=GetTTFLabel(oneGems,30)
    self.gemsLabel1:setAnchorPoint(ccp(1,0.5))
    self.gemsLabel1:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbY))
    self.bgLayer:addChild(self.gemsLabel1,1)

    self:updateBtnShow()

    self:getItemList()

    local iconWidth=122
    local iconHeight=136
    local wSpace=30
    local hSpace=30
    local xSpace=self.bgLayer:getContentSize().width/2-150
    local ySpace=70
    for k,v in pairs(self.iconList) do
        local i=k
        if v then
            local icon=v
            icon:setAnchorPoint(ccp(0.5,0.5))
            if(i<4)then
                icon:setPosition(ccp((iconWidth+wSpace)*(i-1)+xSpace,lbY+iconHeight+50))
            elseif(i==4)then
                icon:setPosition(ccp(xSpace+305,lbY+50))
            elseif(i<8)then
                icon:setPosition(ccp((iconWidth+wSpace)*(7-i)+xSpace,lbY-iconHeight+50))
            elseif(i==8)then
                icon:setPosition(ccp(xSpace,lbY+50))
            end

            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            self.bgLayer:addChild(icon)
        end
    end


  local function nilFunc()
  end
  self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
  self.halo:setContentSize(CCSizeMake(100+8,100+8))
  self.halo:setAnchorPoint(ccp(0.5,0.5))
  self.halo:setTouchPriority(0)
  self.halo:setVisible(false)
  local tx,ty=self.iconList[1]:getPosition()
  self.halo:setPosition(tx,ty)
  self.bgLayer:addChild(self.halo,3)


  local function recordHandler( ... )
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end 
    PlayEffect(audioCfg.mouseClick)

    local function callBack(posX,posY)
      mainUI:changeToWorld()
      if tonumber(playerVoApi:getPlayerLevel())<3 and tonumber(playerVoApi:getMapX())==-1 then
          do
              return
          end
      end

      mainUI.m_lastSearchXValue=posX
      mainUI.m_lastSearchYValue=posY
      mainUI.m_labelX:setString(mainUI.m_lastSearchXValue)
      mainUI.m_labelY:setString(mainUI.m_lastSearchYValue)
      worldScene:focus(mainUI.m_lastSearchXValue,mainUI.m_lastSearchYValue)
      activityAndNoteDialog:closeAllDialog()
    end

    self.td = acJidongbuduiRecord:new()
    self.td:init("PanelHeaderPopup.png",getlocal("activity_jidongbudui_turkeyLand"),self.layerNum+1,callBack)
  end

  local recordBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",recordHandler,3,getlocal("activity_jidongbudui_lookingforTurkey"),28)
  recordBtn:setAnchorPoint(ccp(0.5, 0))
  local recordMenu=CCMenu:createWithItem(recordBtn)
  recordMenu:setPosition(ccp(G_VisibleSizeWidth/2,30))
  recordMenu:setTouchPriority(-(self.layerNum-1)*20-5)
  self.bgLayer:addChild(recordMenu) 


end

function acJidongbuduiTab1:getItemList()
  local iconListcfg = acJidongbuduiVoApi:getCircleListCfg()
  self.iconList={}
  if iconListcfg then
    for k,v in pairs(iconListcfg) do
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
                  --local pCfg  = acJidongbuduiVoApi:getTokenCfgForShowByPid(i)

                  local function showInfoHandler(hd,fn,idx)
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local item = {name = getlocal("activity_jidongbudui_turkey"), pic= "Turkey.png", num = num, desc = "activity_jidongbudui_turkeyDesc"}
                    propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true)
                  end

                  icon= LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",showInfoHandler)
                  icon:setScale(100 / icon:getContentSize().width)
                  local function timeIconClick( ... )
                  end
                  local addIcon = LuaCCSprite:createWithSpriteFrameName("Turkey.png",timeIconClick)
                  addIcon:setPosition(getCenterPoint(icon))
                  icon:addChild(addIcon)
                  local numLb = GetTTFLabel("x"..j,25)
                  numLb:setAnchorPoint(ccp(1,0))
                  numLb:setPosition(ccp(icon:getContentSize().width-10,10))
                  icon:addChild(numLb)
                end
            end
            self.iconList[indexs] = icon
            self.itemList[indexs]={type=k,key=(k.."_"..id),num=num}
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
              self.iconList[n.index]=icon
              self.itemList[n.index]=n
            end
          end
      end
    end
  end
end


function acJidongbuduiTab1:updateBtnShow()

  local gemCost=acJidongbuduiVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
  local oneGems=gemCost       --一次抽奖需要金币

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
          if acJidongbuduiVoApi:isToday()==true then
            free=1
          end
          local num
          if tag==1 then
            if free==1 and playerVoApi:getGems()<oneGems then
              GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
              do return end
            end
            num=1
          end          
          local function lotteryCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            print(ret,sData.data)
            if ret==true then
                if sData.data==nil then
                  do return end
                end
                
                if tag==1 then
                  if free==1 then
                    playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
                  end
                end

              --刷新活动数据
                local tipStr=""
                local getTank1=false
                local getTank2=false
                if sData.data["jidongbudui"] then
                  self.awardData=sData.data["jidongbudui"]["clientReward"]

                  
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
                      acJidongbuduiVoApi:updateSelfTurkey(num)

                      self.reward={name=getlocal("activity_jidongbudui_turkey"),num=num,type=ptype,key=pID,pic="Turkey.png",desc="activity_jidongbudui_turkeyDesc"}
                    else
                      local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
                     -- nameStr = name
                      self.reward={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId}
                      G_addPlayerAward(self.reward.type,self.reward.key,self.reward.id,self.reward.num,nil,true)
                    end
                  end
                  if free == 0 then
                      acJidongbuduiVoApi:updateLastTime()
                      self.isToday=acJidongbuduiVoApi:isToday()
                      acJidongbuduiVoApi:updateShow()
                  end

                  self.state = 2
                  self.lotteryOneBtn:setEnabled(false)
                  self:play()
                end
              end
           end
          local function onConfirm()
              socketHelper:activityJidongbuduiLottery(lotteryCallback)
          end
          if(free==1)then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_slotMachine_getTip",{oneGems}),nil,self.layerNum+1)
          else
            onConfirm()
          end
      end

    local leftPosX=self.bgLayer:getContentSize().width/2
    local btnY=70

  if acJidongbuduiVoApi:isToday()==false then
    self.goldSp1:setVisible(false)
    self.gemsLabel1:setVisible(false)
    self.lotteryOneBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25)
  else
    self.goldSp1:setVisible(true)
    self.gemsLabel1:setVisible(true)
    self.lotteryOneBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,1,getlocal("activity_wheelFortune_subTitle_1"),25)
  end

  self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
  local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
  lotteryMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-350)/2))
  lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
  self.bgLayer:addChild(lotteryMenu,2)
end

function acJidongbuduiTab1:updateturkeyNum()
  if self.turkeyNum then
    self.turkeyNum:setString(tostring(acJidongbuduiVoApi:getTurkeyNum()))
  end
end
function acJidongbuduiTab1:eventHandler(handler,fn,idx,cel)
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



function acJidongbuduiTab1:play()
  self.touchDialogBg:setIsSallow(true)

    self.tickIndex=0
    self.tickInterval=3
    self.tickConst=3
    self.intervalNum=3 --fasttick间隔 3帧一次

    self.haloPos=0
    if self.endIdx then
      self.haloPos=self.endIdx
    end

    self.slowStart=false
    
    self.endIdx=0
    for k,v in pairs(self.itemList) do
        if self.itemList and v and self.reward and self.reward.key and v.key==self.reward.key and self.reward.num == v.num then
            self.endIdx=k
        end
    end


    self.slowTime=4

    if self.endIdx>0 then
        self.count=8*self.tickConst --转1圈之后开始减速
        if self.endIdx>self.slowTime then
            self.slowStartIndex=self.endIdx-self.slowTime
        else
            self.count=self.count-((self.slowTime-1)*self.tickConst)
            self.slowStartIndex=self.endIdx-self.slowTime+8
        end

        -- self.halo:setVisible(true)
        --base:addNeedRefresh(self)
    end

end

function acJidongbuduiTab1:fastTick()
  if self.tickIndex then
    self.tickIndex=self.tickIndex+1
    self.tickInterval=self.tickInterval-1
    if self.state == 2 then
       if(self.tickInterval<=0)then
          self.tickInterval=self.tickConst
          self.haloPos=self.haloPos+1
          if(self.haloPos>8)then
              self.haloPos=self.haloPos-8
              -- self.haloPos=1
          end
          local tx,ty=self.iconList[self.haloPos]:getPosition()
          self.halo:setPosition(tx,ty)
          if self.halo:isVisible()==false then
              self.halo:setVisible(true)
          end

          if (self.tickIndex>=self.count) then 

              if(self.haloPos==self.slowStartIndex)then
                  self.slowStart=true
              end
              if (self.slowStart) then
                  --此处执行减速逻辑,减到一定速度(60)之后就不再减
                  -- if(self.tickIndex>self.lastTs)then
                      if (self.tickConst<self.tickConst*3) then
                          self.tickConst=self.tickConst+self.tickConst
                      elseif self.tickConst<self.intervalNum*4 then
                          self.tickConst=self.tickConst+self.tickConst*2
                      end
                  -- end

                  -- if(self.tickConst>=60)then
                  --     base:removeFromNeedRefresh(self)
                  --     self:playEndEffect()
                  -- end
              end
              if self.endIdx>0 and (self.haloPos==self.endIdx) and self.tickIndex~=self.count then
                  self:stopPlay()
              end
          end


      end
    elseif self.state == 3 then
      self.haloPos=self.endIdx
      self:stopPlay()
    end
   end
end

function acJidongbuduiTab1:stopPlay()
    --base:removeFromNeedRefresh(self)
    self:playEndEffect()
end

function  acJidongbuduiTab1:playEndEffect()
    self.tickIndex =nil
    local bgSize=self.iconList[self.haloPos]:getContentSize()
    local item=self.iconList[self.haloPos]

    local tx,ty=item:getPosition()
    self.halo:setPosition(tx,ty)

    if item and self.reward then
      local str=G_showRewardTip({self.reward},false)
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
    end
    self.touchDialogBg:setIsSallow(false) 
    self:refresh()
end

function acJidongbuduiTab1:refresh()
  self:updateturkeyNum()
  if self.lotteryOneBtn then
    self.lotteryOneBtn:setEnabled(true)
    self:updateBtnShow()
  end

end

function acJidongbuduiTab1:tick( ... )
  local today = acJidongbuduiVoApi:isToday()
  if today~=self.isToday then
    self.isToday = today
    self:refresh()
  end
end

function acJidongbuduiTab1:updateList()
  print("1111111")
  if self.td then
    print("1111111")
    self.td:update()
  end
end


function acJidongbuduiTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.isToday =nil
    self.td=nil
    self = nil
end
