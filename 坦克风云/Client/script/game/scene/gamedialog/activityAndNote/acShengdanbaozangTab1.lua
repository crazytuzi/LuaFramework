acShengdanbaozangTab1={


}

function acShengdanbaozangTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil
    self.isToday =nil
    self.spList={}
    self.iconList={}
    self.itemList={}
    self.version =nil
    self.partSpTb={}

    return nc;

end

function acShengdanbaozangTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.version =acShengdanbaozangVoApi:getVersion()
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

    
    self.isToday = acShengdanbaozangVoApi:isToday()
    self:initTableView()

    return self.bgLayer
end

function acShengdanbaozangTab1:initTableView()
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

  local function bgClick()
    end
  
  local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
  backSprie:setContentSize(CCSizeMake(w, 200))
  backSprie:setAnchorPoint(ccp(0.5,0))
  backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 365))
  self.bgLayer:addChild(backSprie)
  
  local function touch(tag,object)
    PlayEffect(audioCfg.mouseClick)
    local tabStr={};
    local tabColor ={};
    local td=smallDialog:new()
    if self.version ==1 or self.version ==2 or self.version== nil then
      tabStr = {"\n",getlocal("activity_shengdanbaozang_lotteryTip6"),"\n",getlocal("activity_shengdanbaozang_lotteryTip5"),"\n",getlocal("activity_shengdanbaozang_lotteryTip4"),"\n",getlocal("activity_shengdanbaozang_lotteryTip3"),"\n",getlocal("activity_shengdanbaozang_lotteryTip2"),"\n",getlocal("activity_shengdanbaozang_lotteryTip1",{acShengdanbaozangVoApi:getLotteryLimit()}),"\n"}
    elseif self.version ==3 or self.version ==4 then
      tabStr = {"\n",getlocal("activity_mysteriousArms_tip6"),"\n",getlocal("activity_mysteriousArms_tip5"),"\n",getlocal("activity_mysteriousArms_tip4"),"\n",getlocal("activity_mysteriousArms_tip3"),"\n",getlocal("activity_mysteriousArms_tip2"),"\n",getlocal("activity_mysteriousArms_tip1",{acShengdanbaozangVoApi:getLotteryLimit()}),"\n"}
    end
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
  end

  w = w - 10 -- 按钮的x坐标
  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  menuItemDesc:setScale(0.8)
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w-10, 190))
  backSprie:addChild(menuDesc)
  
  w = w - menuItemDesc:getContentSize().width

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 190))
  backSprie:addChild(acLabel)
  acLabel:setColor(G_ColorGreen)

  local acVo = acShengdanbaozangVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,25)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 150))
  backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  G_updateActiveTime(acVo,self.timeLb)

  local function showTankInfo( ... )
    --tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
  end
  local icon 
  local scaleSize
  local iconPosWidth
  if self.version ==1 or self.version ==2 or self.version ==nil then
    icon = LuaCCSprite:createWithSpriteFrameName("mainBtnGift.png",showTankInfo)
    scaleSize = 1.5
    iconPosWidth = 30
  elseif self.version ==3 or self.version ==4 then
    icon = LuaCCSprite:createWithSpriteFrameName("SeniorBoxOpen.png",showTankInfo)
    scaleSize =0.9
    iconPosWidth =20
  end
  icon:setTouchPriority(-(self.layerNum-1)*20-5)
  icon:setScale(scaleSize)

  icon:setAnchorPoint(ccp(0,0.5))
  icon:setPosition(iconPosWidth,80)
  backSprie:addChild(icon)

  local headDesc = getlocal("activity_shengdanbaozang_lotteryContent")
  if self.version ==3 or self.version ==4 then
    headDesc =getlocal("activity_mysteriousArms_desc")
  end
  local desTv, desLabel = G_LabelTableView(CCSizeMake(w-100, 110),headDesc,25,kCCTextAlignmentLeft)
  backSprie:addChild(desTv)
  desTv:setPosition(ccp(160,10))
  desTv:setAnchorPoint(ccp(0,0))
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  desTv:setMaxDisToBottomOrTop(100)


  self.background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
  self.background:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,160))
  self.background:setAnchorPoint(ccp(0.5,1))
  self.background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 370))
  self.bgLayer:addChild(self.background)

  local titleLb = GetTTFLabelWrap(getlocal("hasChanceGet"),27,CCSizeMake(self.background:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  titleLb:setAnchorPoint(ccp(0,1))
  titleLb:setPosition(10,self.background:getContentSize().height-10)
  self.background:addChild(titleLb)

  local showListCfg = acShengdanbaozangVoApi:getShowListCfg()
  local showList= FormatItem(showListCfg,nil,true)
  if showList then
    for k,v in pairs(showList) do
      local icon,iconScale = G_getItemIcon(v,100, true, self.layerNum)
      icon:setTouchPriority(-(self.layerNum-1)*20-5)
      icon:setAnchorPoint(ccp(0,0))
      icon:setPosition(40+110*(k-1),10)
      self.background:addChild(icon)
      G_addRectFlicker(icon,1.4/iconScale,1.4/iconScale)

      local num = GetTTFLabel("x"..v.num,25)
      num:setAnchorPoint(ccp(1,0))
      num:setPosition(icon:getContentSize().width-10,10)
      icon:addChild(num)
    end
  end

  local function nilfun( ... )
          -- body
  end
  self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilfun)
  self.backSprie:setContentSize(CCSizeMake(595,383))
  self.backSprie:setAnchorPoint(ccp(0.5,0.5))
  self.backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2+2.5,(self.bgLayer:getContentSize().height-500)/2))
  self.bgLayer:addChild(self.backSprie,1)

  --self:doUserHandler()

end

function acShengdanbaozangTab1:doUserHandler()
  if acShengdanbaozangVoApi:getLeftLotteryNum()<=0 then
    acShengdanbaozangVoApi:refreshData()
  end
  self.canClick = acShengdanbaozangVoApi:getIsCanClick()
  self.rewardList = acShengdanbaozangVoApi:getRewardList()
  local function touch()
  end
  if self.maskSp==nil then
    local function tmpFunc()
      end
      self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
      self.maskSp:setOpacity(255)
      local size=CCSizeMake(self.backSprie:getContentSize().width,self.backSprie:getContentSize().height-25)
      self.maskSp:setContentSize(size)
      self.maskSp:setAnchorPoint(ccp(0.5,0.5))
      self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
      self.maskSp:setIsSallow(true)
      self.maskSp:setTouchPriority(-(self.layerNum-1)*20-6)
      self.backSprie:addChild(self.maskSp,2)
  else
    self.maskSp:setVisible(true)
    self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
  end


  local btnHeight=self.maskSp:getContentSize().height/2
  local function btnCallback(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
     local diffGems=acShengdanbaozangVoApi:getLotteryCost()
     local allGems=acShengdanbaozangVoApi:getLotteryAllCost()
      if tag>=4 then      --抽奖结束 确定按钮
        if self.spList then
          for k,v in pairs(self.spList) do
            if v then
              v:removeFromParentAndCleanup(true)
              v = nil
            end
          end
          self.spList = {}
        end
        self:doUserHandler()
      elseif tag==1 then    --免费
          local function freeCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret == true then
              acShengdanbaozangVoApi:addCanClick(1)
              acShengdanbaozangVoApi:updateCanFreeClick(0)
              self.maskSp:setVisible(false)
              self.maskSp:setPosition(ccp(10000,0))
              self.maskSp1:setVisible(false)
              self.maskSp1:setPosition(ccp(10000,0))
            end
          end
          socketHelper:activityShengdanbaozangCost(freeCallback)
      elseif tag==2 then  --花费幸运币
          if acShengdanbaozangVoApi:getLeftLotteryNum() <=0 then
            self:refresh()
            self:doUserHandler()
            do return end
          end
          if acShengdanbaozangVoApi:isToday()==false then
            local function freeCallback(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret == true then
                acShengdanbaozangVoApi:addCanClick(1)
                acShengdanbaozangVoApi:updateCanFreeClick(0)
                self.maskSp:setVisible(false)
                self.maskSp:setPosition(ccp(10000,0))
                self.maskSp1:setVisible(false)
                self.maskSp1:setPosition(ccp(10000,0))
              end
            end
            socketHelper:activityShengdanbaozangCost(freeCallback)
          else
            if playerVoApi:getGems()<diffGems then
              GemsNotEnoughDialog(nil,nil,diffGems-playerVoApi:getGems(),self.layerNum+1,diffGems)
              do return end
            end
            
            local function payCallback(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret == true then
                playerVoApi:setValue("gems",playerVoApi:getGems()-diffGems)
                acShengdanbaozangVoApi:addCanClick(1)
                acShengdanbaozangVoApi:updateCanFreeClick(1)
                -- local leftLotteryNum = acShengdanbaozangVoApi:getLeftLotteryNum()
                -- if leftLotteryNum<=0 then
                --   self:refresh()
                -- end
                self:initPartSP()
                self.maskSp:setVisible(false)
                self.maskSp:setPosition(ccp(10000,0))

                self.maskSp1:setVisible(false)
                self.maskSp1:setPosition(ccp(10000,0))
              end
            end
            socketHelper:activityShengdanbaozangCost(payCallback)
          end
         
          

      elseif tag==3 then  --花费金币
          
          if playerVoApi:getGems()<allGems then
            GemsNotEnoughDialog(nil,nil,allGems-playerVoApi:getGems(),self.layerNum+1,allGems)
            do return end
          end
          local function allCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret == true then
              playerVoApi:setValue("gems",playerVoApi:getGems()-allGems)
              self:initPartSP()
              if sData.data.shengdanbaozang.clientReward then
                  acShengdanbaozangVoApi:setRewardList(sData.data.shengdanbaozang.clientReward)
              end
              self.rewardList = acShengdanbaozangVoApi:getRewardList()
              local posTb = sData.data.shengdanbaozang.pos
              local isChat = false
              local content={}
              local desStr = getlocal("activity_shengdanbaozang_title")
              if self.version ==3 or self.version ==4 then
                 desStr =getlocal("activity_mysteriousArms_title")
              end
              for k,v in pairs(posTb) do
                local item = self.rewardList[v]
                if acShengdanbaozangVoApi:checkIsChat(item) == true then
                  local message={key="activity_chatSystemMessage",param={playerVoApi:getPlayerName(),desStr,item.name}}
                  chatVoApi:sendSystemMessage(message)
                end
                if item.type == "mm" then
                  acShengdanbaozangVoApi:updateSelfTokens("mm_m1",item.num)
                else
                  G_addPlayerAward(item.type,item.key,item.id,item.num,nil,true)
                end
                table.insert(content,item)
              end
              G_showRewardTip(content,true)

              for m,n in pairs(self.rewardList) do

                local rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
                local tx,ty=self:getPosition(m)
                rewardIconBg:setPosition(tx,ty)
                local icon,iconScale,textSize
                if n.type == "mm" then
                  if self.version ==1 or self.version ==2 or self.version ==nil then
                      icon = GetBgIcon("CandyBar.png",nil,nil,30,100)  
                  elseif self.version ==3 or self.version ==4 then
                      icon = GetBgIcon("mysteriousArmsIcon.png",nil,nil,80,100)
                  end 
                  textSize = 20--25*(1-30/100)

                else
                  icon,iconScale = G_getItemIcon(n)
                   textSize = 25
                end
                local num = GetTTFLabel("x"..n.num,textSize)
                num:setAnchorPoint(ccp(1,0))
                num:setPosition(icon:getContentSize().width-10,10)
                icon:addChild(num)
                icon:setPosition(getCenterPoint(rewardIconBg))
                rewardIconBg:addChild(icon)
                self.maskSp:addChild(rewardIconBg)
                self.spList[m]=rewardIconBg

                self:clearAllReward()
                self:clearIconList()

                self:refresh()

              end
              self.maskSp:setVisible(true)
              self.maskSp:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))

              self.freeBtn:setVisible(false)
              self.playBtn:setVisible(false)
              self.buyAndPlayBtn:setVisible(false)
              self.goldSp:setVisible(false)
              self.gemsLabel:setVisible(false)
              self.goldSp1:setVisible(false)
              self.gemsLabel1:setVisible(false)

              --self.lotteryNumSP:setVisible(false)
              self.giveUpmenu1:setVisible(false)
              self.leftLotteryNumLb:setVisible(false)

              self.confirmBtn:setVisible(true)

              self.maskSp1:setVisible(false)
              self.maskSp1:setPosition(ccp(10000,0))
            end
          end
          socketHelper:activityShengdanbaozangLotteryAll(allCallback)
        end
    end
  
  local function nilClick( ... )
    -- body
  end
  -- if self.lotteryNumSP == nil then
  --   self.lotteryNumSP = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilClick)
  --   self.lotteryNumSP:setAnchorPoint(ccp(0.5,1))
  --   self.lotteryNumSP:setPosition(ccp(self.maskSp:getContentSize().width/2, self.maskSp:getContentSize().height-20))
  --   self.maskSp:addChild(self.lotteryNumSP)
  -- end
  if self.leftLotteryNumLb ==nil then
    self.leftLotteryNumLb=GetTTFLabelWrap(getlocal("activity_shengdanbaozang_leftLotteryNum",{acShengdanbaozangVoApi:getLeftLotteryNum()}),25,CCSizeMake(self.maskSp:getContentSize().width/2-20,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
    self.leftLotteryNumLb:setAnchorPoint(ccp(1,1))
    self.leftLotteryNumLb:setPosition(ccp(self.maskSp:getContentSize().width-20, self.maskSp:getContentSize().height-10))
    self.maskSp:addChild(self.leftLotteryNumLb,10)
    --self.lotteryNumSP:setContentSize(CCSizeMake(self.maskSp:getContentSize().width-150,self.leftLotteryNumLb:getContentSize().height+20))
  else
    self.leftLotteryNumLb:setString(getlocal("activity_shengdanbaozang_leftLotteryNum",{acShengdanbaozangVoApi:getLeftLotteryNum()}))
  end
  


  if self.freeBtn==nil then
    self.freeBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25,501)
    self.freeBtn:setAnchorPoint(ccp(0.5,0.5))
    local boxSpMenu=CCMenu:createWithItem(self.freeBtn)
    boxSpMenu:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight))
    boxSpMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.maskSp:addChild(boxSpMenu,2)
    --self.freeBtn:setVisible(false)
  end
  if self.playBtn==nil then
    self.playBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,2,getlocal("activity_shengdanbaozang_lotteryBtn"),25)
    self.playBtn:setAnchorPoint(ccp(0.5,0.5))
    local boxSpMenu1=CCMenu:createWithItem(self.playBtn)
    boxSpMenu1:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight))
    boxSpMenu1:setTouchPriority(-(self.layerNum-1)*20-8)
    self.maskSp:addChild(boxSpMenu1,2)
    --self.playBtn:setVisible(false)
  end
  if self.buyAndPlayBtn==nil then
    self.buyAndPlayBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,3,getlocal("activity_shengdanbaozang_lotteryAllBtn"),25)
    self.buyAndPlayBtn:setAnchorPoint(ccp(0.5,0.5))
    local boxSpMenu2=CCMenu:createWithItem(self.buyAndPlayBtn)
    boxSpMenu2:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight-130))
    boxSpMenu2:setTouchPriority(-(self.layerNum-1)*20-8)
    self.maskSp:addChild(boxSpMenu2,2)
    --self.buyAndPlayBtn:setVisible(false)
  end
  if self.confirmBtn==nil then
    self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,4,getlocal("confirm"),25)
    self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
    local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
    local menuY = self.backSprie:getContentSize().height/2-180
    if G_isIphone5()==true then
      menuY = self.backSprie:getContentSize().height/2-260
    end
    boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,menuY))
    boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-8)
    self.maskSp:addChild(boxSpMenu3,2)
    --self.confirmBtn:setVisible(false)
  end
  
  local diffGem=acShengdanbaozangVoApi:getLotteryCost()
  if self.goldSp==nil then
    self.goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp:setAnchorPoint(ccp(0,0.5))
    self.goldSp:setPosition(ccp(self.maskSp:getContentSize().width/2+10,btnHeight+60))
    self.maskSp:addChild(self.goldSp)
  end
  if self.gemsLabel==nil then
    self.gemsLabel=GetTTFLabel(diffGem,30)
    self.gemsLabel:setAnchorPoint(ccp(1,0.5))
    self.gemsLabel:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight+60))
    self.maskSp:addChild(self.gemsLabel,1)
    self.gemsLabel:setColor(G_ColorYellow)
  end

  local allGem=acShengdanbaozangVoApi:getLotteryAllCost()
  if self.goldSp1==nil then
    self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp1:setAnchorPoint(ccp(0,0.5))
    self.goldSp1:setPosition(ccp(self.maskSp:getContentSize().width/2+10,btnHeight-70))
    self.maskSp:addChild(self.goldSp1)
  end
  if self.gemsLabel1==nil then
    self.gemsLabel1=GetTTFLabel(allGem,30)
    self.gemsLabel1:setAnchorPoint(ccp(1,0.5))
    self.gemsLabel1:setPosition(ccp(self.maskSp:getContentSize().width/2,btnHeight-70))
    self.maskSp:addChild(self.gemsLabel1,1)
    self.gemsLabel1:setColor(G_ColorYellow)
  end


  local function giveUpHandler( ... )
   if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    local function giveUpCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret == true then
         self:refresh()
         self:doUserHandler()
      end
    end
    socketHelper:activityShengdanbaozangGiveUp(giveUpCallback)
  end
  
  if self.giveUpmenu1== nil then
    local giveUpLb = GetTTFLabelWrap(getlocal("activity_shengdanbaozang_giveUp"),25,CCSizeMake(self.maskSp:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    giveUpLb:setColor(G_ColorGreen)
    local itemMeun = CCMenuItemLabel:create(giveUpLb)
    itemMeun:setAnchorPoint(ccp(0,1))
    itemMeun:registerScriptTapHandler(giveUpHandler)
    self.giveUpmenu1 = CCMenu:createWithItem(itemMeun)
    self.giveUpmenu1:setAnchorPoint(ccp(0,1))
    self.giveUpmenu1:setPosition(10, self.maskSp:getContentSize().height-10)
    self.maskSp:addChild(self.giveUpmenu1)
  end

  self:updateShow()

  local function touch()
  end
  if self.maskSp1==nil then
    local function tmpFunc()
      end
      self.maskSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
      self.maskSp1:setOpacity(255)
      local size=CCSizeMake(self.backSprie:getContentSize().width,self.backSprie:getContentSize().height-25)
      self.maskSp1:setContentSize(size)
      self.maskSp1:setAnchorPoint(ccp(0.5,0.5))
      self.maskSp1:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
      self.maskSp1:setIsSallow(true)
      self.maskSp1:setTouchPriority(-(self.layerNum-1)*20-6)
      self.backSprie:addChild(self.maskSp1,2)
  end

  if self.nextBtn==nil then
    self.nextBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnCallback,2,getlocal("activity_shengdanbaozang_nextBtn"),25,10101)
    self.nextBtn:setAnchorPoint(ccp(0.5,0.5))
    local nextMenu=CCMenu:createWithItem(self.nextBtn)
    nextMenu:setPosition(ccp(self.maskSp1:getContentSize().width/2+100,50))
    nextMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.maskSp1:addChild(nextMenu,2)
    --self.playBtn:setVisible(false)
  end
  if self.allBtn==nil then
    self.allBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,3,getlocal("activity_shengdanbaozang_lotteryAllBtn"),25)
    self.allBtn:setAnchorPoint(ccp(0.5,0.5))
    local allMenu=CCMenu:createWithItem(self.allBtn)
    allMenu:setPosition(ccp(self.maskSp:getContentSize().width/2-100,50))
    allMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.maskSp1:addChild(allMenu,2)
    --self.buyAndPlayBtn:setVisible(false)
  end

  if self.goldSp2==nil then
    self.goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp2:setAnchorPoint(ccp(0,0.5))
    self.goldSp2:setPosition(ccp(self.maskSp1:getContentSize().width/2+100+10,110))
    self.maskSp1:addChild(self.goldSp2)
  end
  if self.gemsLabel2==nil then
    self.gemsLabel2=GetTTFLabel(diffGem,30)
    self.gemsLabel2:setAnchorPoint(ccp(1,0.5))
    self.gemsLabel2:setPosition(ccp(self.maskSp1:getContentSize().width/2+100,110))
    self.maskSp1:addChild(self.gemsLabel2,1)
    self.gemsLabel2:setColor(G_ColorYellow)
  end

  if self.goldSp3==nil then
    self.goldSp3=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp3:setAnchorPoint(ccp(0,0.5))
    self.goldSp3:setPosition(ccp(self.maskSp1:getContentSize().width/2-100+10,110))
    self.maskSp1:addChild(self.goldSp3)
  end
  if self.gemsLabel3==nil then
    self.gemsLabel3=GetTTFLabel(allGem,30)
    self.gemsLabel3:setAnchorPoint(ccp(1,0.5))
    self.gemsLabel3:setPosition(ccp(self.maskSp1:getContentSize().width/2-100,110))
    self.maskSp1:addChild(self.gemsLabel3,1)
    self.gemsLabel3:setColor(G_ColorYellow)
  end

  if self.giveUpmenu== nil then
    local giveUpLb = GetTTFLabelWrap(getlocal("activity_shengdanbaozang_giveUp"),25,CCSizeMake(self.maskSp1:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    giveUpLb:setColor(G_ColorGreen)
    local itemMeun = CCMenuItemLabel:create(giveUpLb)
    itemMeun:setAnchorPoint(ccp(0,1))
    itemMeun:registerScriptTapHandler(giveUpHandler)
    self.giveUpmenu = CCMenu:createWithItem(itemMeun)
    self.giveUpmenu:setAnchorPoint(ccp(0,1))
    self.giveUpmenu:setPosition(10, self.maskSp1:getContentSize().height-10)
    self.maskSp1:addChild(self.giveUpmenu)
  end
  if self.leftLotteryNumLb1 == nil then
    self.leftLotteryNumLb1 = GetTTFLabelWrap(getlocal("activity_shengdanbaozang_leftLotteryNum",{acShengdanbaozangVoApi:getLeftLotteryNum()}),25,CCSizeMake(self.maskSp1:getContentSize().width/2-20,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
    self.leftLotteryNumLb1:setAnchorPoint(ccp(1,1))
    self.leftLotteryNumLb1:setPosition(self.maskSp1:getContentSize().width-20,self.maskSp1:getContentSize().height-10)
    self.maskSp1:addChild(self.leftLotteryNumLb1)
  else
    self.leftLotteryNumLb1:setString(getlocal("activity_shengdanbaozang_leftLotteryNum",{acShengdanbaozangVoApi:getLeftLotteryNum()}))
  end
    
  
  self.confirmBtn:setVisible(false)

  -- self.maskSp:setVisible(false)
  self.maskSp1:setVisible(false)

  if self.canClick >0 then
    self.maskSp:setVisible(false)
    self.maskSp:setPosition(ccp(10000,0))
    self.maskSp1:setVisible(false)
    self.maskSp1:setPosition(ccp(10000,0))
  end

  if self.rewardList == nil or SizeOfTable(self.rewardList)<=0 then
    local function getListCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret == true then
        if sData.data.shengdanbaozang.clientReward then
          acShengdanbaozangVoApi:setRewardList(sData.data.shengdanbaozang.clientReward)
          self.rewardList = acShengdanbaozangVoApi:getRewardList()
          self:initPartSP()
          self:updateShow()
        end
        
      end
    end
    socketHelper:activityShengdanbaozangRewardList(getListCallback)
  else
    self:initPartSP()
  end
  
end
function acShengdanbaozangTab1:initPartSP()
    self:clearAllReward()
    self:clearIconList()


    if self.partSpTb and SizeOfTable(self.partSpTb)>0 then
      for k,v in pairs(self.partSpTb) do
        v:setVisible(true)
        local posX,posY=self:getPosition(k)
        v:setPosition(posX,posY)
      end
    else

        for i=1,6 do
            local function partClick()
              local function lotteryCallback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret == true then
                  if sData and sData.data.shengdanbaozang then
                   
                    acShengdanbaozangVoApi:addHadLotteryNum()
                    local lefrLotteryNum = acShengdanbaozangVoApi:getLeftLotteryNum()
                    self.leftLotteryNumLb:setString(getlocal("activity_shengdanbaozang_leftLotteryNum",{lefrLotteryNum}))
                    self.leftLotteryNumLb1:setString(getlocal("activity_shengdanbaozang_leftLotteryNum",{lefrLotteryNum}))
                    if acShengdanbaozangVoApi:getIsCanClick() == 1 then
                       acShengdanbaozangVoApi:addCanClick(-1)
                       print(acShengdanbaozangVoApi:isToday(),acShengdanbaozangVoApi:getIsCanFreeClick())
                      if acShengdanbaozangVoApi:isToday() == false and acShengdanbaozangVoApi:getIsCanFreeClick()==0 then
                        print("free..............")
                        acShengdanbaozangVoApi:updateLastTime()
                        self.isToday = acShengdanbaozangVoApi:isToday()
                        acShengdanbaozangVoApi:updateShow()
                      end
                    end
                    acShengdanbaozangVoApi:updateCanFreeClick(0)
                    if sData.data.shengdanbaozang.clientReward then
                      acShengdanbaozangVoApi:setRewardList(sData.data.shengdanbaozang.clientReward)
                    end
                    self.rewardList = acShengdanbaozangVoApi:getRewardList()
                    local pos = sData.data.shengdanbaozang.pos[1]

                    self.maskSp:setVisible(false)
                    self.maskSp:setPosition(ccp(10000,0))


                    self.maskSp1:setVisible(true)
                    self.maskSp1:setPosition(ccp(self.backSprie:getContentSize().width/2,self.backSprie:getContentSize().height/2+5))
                    
                    --self:updatePartSp()

                    self:showAllReward()

                    self.itemList[pos]:setVisible(false)

                    self.leftLotteryNumLb1:setVisible(false)
                    self.giveUpmenu:setVisible(false)
                    self.nextBtn:setVisible(false)
                    self.allBtn:setVisible(false)
                    self.goldSp2:setVisible(false)
                    self.gemsLabel2:setVisible(false)
                    self.goldSp3:setVisible(false)
                    self.gemsLabel3:setVisible(false)

                    local bgSize=self.partSpTb[pos]:getContentSize()
                    local item=self.rewardList[pos]
                    local desStr = getlocal("activity_shengdanbaozang_title")
                    if self.version ==3 or self.version ==4 then
                       desStr =getlocal("activity_mysteriousArms_title")
                    end
                    if acShengdanbaozangVoApi:checkIsChat(item) == true then
                        local message={key="activity_chatSystemMessage",param={playerVoApi:getPlayerName(),desStr,item.name}}
                        chatVoApi:sendSystemMessage(message)
                    end
                    if item.type == "mm" then
                      acShengdanbaozangVoApi:updateSelfTokens("mm_m1",item.num)
                    else
                      G_addPlayerAward(item.type,item.key,item.id,item.num,nil,true)
                    end
                    if self.rewardIconBg then
                      self.rewardIconBg:removeFromParentAndCleanup(true)
                      self.rewardIconBg = nil
                    end
                    self.rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                    self.rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
                    local tx,ty=self:getPosition(pos)
                    self.rewardIconBg:setPosition(tx,ty)
                    local rewardIcon
                    if item.type == "mm" then
                        if self.version ==1 or self.version ==2 or self.version ==nil then
                            rewardIcon = GetBgIcon("CandyBar.png",nil,nil,30,100)  
                        elseif self.version ==3 or self.version ==4 then
                            rewardIcon = GetBgIcon("mysteriousArmsIcon.png",nil,nil,80,100)
                        end 
                    else
                      rewardIcon = G_getItemIcon(item)
                    end
                    rewardIcon:setAnchorPoint(ccp(0.5,0.5))
                    rewardIcon:setPosition(ccp(self.rewardIconBg:getContentSize().width/2,self.rewardIconBg:getContentSize().height/2))
                    self.rewardIconBg:addChild(rewardIcon)
                    self.maskSp1:addChild(self.rewardIconBg,4)
                    local scale=100/rewardIcon:getContentSize().width
                    rewardIcon:setScale(scale)

                    if self.nameLb==nil then
                        self.nameLb=GetTTFLabel(item.name.." x"..item.num,25)
                        self.nameLb:setAnchorPoint(ccp(0.5,1))
                        self.nameLb:setPosition(ccp(self.maskSp1:getContentSize().width/2,self.maskSp1:getContentSize().height/2-20))
                        self.maskSp1:addChild(self.nameLb,5)
                        self.nameLb:setVisible(false)
                    else
                        self.nameLb:setString(item.name.." x"..item.num)
                        self.nameLb:setVisible(false)
                    end


                    local function playEndCallback()
                        G_showRewardTip({item},true)

                        if self.nameLb then
                            self.nameLb:setVisible(true)
                        end

                        self.leftLotteryNumLb1:setVisible(true)
                        self.giveUpmenu:setVisible(true)
                        if acShengdanbaozangVoApi:getLeftLotteryNum() <=0 then
                          tolua.cast(self.nextBtn:getChildByTag(10101),"CCLabelTTF"):setString(getlocal("confirm"))
                          self.goldSp2:setVisible(false)
                          self.gemsLabel2:setVisible(false)
                        elseif  acShengdanbaozangVoApi:isToday() == false then
                          tolua.cast(self.nextBtn:getChildByTag(10101),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
                          self.goldSp2:setVisible(false)
                          self.gemsLabel2:setVisible(false)
                        else
                          tolua.cast(self.nextBtn:getChildByTag(10101),"CCLabelTTF"):setString(getlocal("activity_shengdanbaozang_nextBtn"))
                          self.goldSp2:setVisible(true)
                          self.gemsLabel2:setVisible(true)
                        end
                        self.nextBtn:setVisible(true)
                        self.allBtn:setVisible(true)

                        self.goldSp3:setVisible(true)
                        self.gemsLabel3:setVisible(true)
                    end

                    local delay1=CCDelayTime:create(0.3)
                    local scale1=CCScaleTo:create(0.4,150/rewardIcon:getContentSize().width/scale)
                    local scale2=CCScaleTo:create(0.4,100/rewardIcon:getContentSize().width/scale)
                    local mvTo=CCMoveTo:create(0.3,ccp(self.maskSp1:getContentSize().width/2,self.maskSp1:getContentSize().height/2+50))
                    local scale3=CCScaleTo:create(0.1,200/rewardIcon:getContentSize().width/scale)
                    local scale4=CCScaleTo:create(0.2,120/rewardIcon:getContentSize().width/scale)
                    local delay2=CCDelayTime:create(0.2)
                    local callFunc=CCCallFuncN:create(playEndCallback)
                    
                    local acArr=CCArray:create()
                    acArr:addObject(delay1)
                    -- acArr:addObject(scale1)
                    -- acArr:addObject(scale2)
                    acArr:addObject(mvTo)
                    acArr:addObject(scale3)
                    acArr:addObject(scale4)
                    acArr:addObject(delay2)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    self.rewardIconBg:runAction(seq)
                  end
                end
              end
              socketHelper:activityShengdanbaozangLotteryOne(i,lotteryCallback)
            end
            local posX,posY=self:getPosition(i)
            local partPic = "Christmas_part"..i..".png"
            if self.version ==3 or self.version ==4 then
              partPic ="mArms_part"..i..".png"
            end
            local partSp = LuaCCSprite:createWithSpriteFrameName(partPic,partClick)
            partSp:setAnchorPoint(ccp(0.5,0.5))
            partSp:setPosition(posX,posY)
            partSp:setTouchPriority(-(self.layerNum-1)*20-3)
            self.backSprie:addChild(partSp,1)

            self.partSpTb[i]=partSp
      end
    end
    self:updatePartSp()
end

function acShengdanbaozangTab1:clearAllReward()
 if self.itemList then
    for k,v in pairs(self.itemList) do
      if v then
        v:removeFromParentAndCleanup(true)
        v = nil 
      end
    end
  end
  self.itemList=nil
end

function acShengdanbaozangTab1:clearIconList()
 if self.iconList then
    for k,v in pairs(self.iconList) do
      if v then
        v:removeFromParentAndCleanup(true)
        v = nil 
      end
    end
  end
  self.iconList = nil
end

function acShengdanbaozangTab1:showAllReward()
  self:clearIconList()
  self:clearAllReward()
  self.itemList={}
  if self.rewardList then
    for k,v in pairs(self.rewardList) do
      self.partSpTb[k]:setVisible(false)
      local rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
      rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
      local tx,ty=self:getPosition(k)
      rewardIconBg:setPosition(tx,ty)
      local rewardIcon
      local scale = 1
      local iconScale= 1
      local textSize = 25
      if v.type == "mm" then
        if self.version ==1 or self.version ==2 or self.version ==nil then
            rewardIcon = GetBgIcon("CandyBar.png",nil,nil,30,100)  
        elseif self.version ==3 or self.version ==4 then
            rewardIcon = GetBgIcon("mysteriousArmsIcon.png",nil,nil,80,100)
        end  
        textSize=20
      else
        rewardIcon,iconScale = G_getItemIcon(v)
        scale = 1.3
      end
      rewardIcon:setAnchorPoint(ccp(0.5,0.5))
      rewardIcon:setPosition(ccp(rewardIconBg:getContentSize().width/2,rewardIconBg:getContentSize().height/2))
      rewardIconBg:addChild(rewardIcon)

      local num = GetTTFLabel("x"..v.num,textSize)
      num:setAnchorPoint(ccp(1,0))
      num:setPosition(rewardIcon:getContentSize().width-10,10)
      rewardIcon:addChild(num)
      if v.pos then
        G_addRectFlicker(rewardIcon,scale/iconScale,scale/iconScale)
      end

      self.backSprie:addChild(rewardIconBg)
      self.itemList[k]=rewardIconBg
    end
  end
end
function acShengdanbaozangTab1:updatePartSp()
  self:clearIconList()
  self:clearAllReward()
  self.iconList={}
  if self.partSpTb and SizeOfTable(self.partSpTb)>0 then
    for k,v in pairs(self.partSpTb) do
      local item = self.rewardList[k]
      if item and item.pos then
        v:setVisible(false)
        v:setPosition(ccp(10000,0))
        local rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
        rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
        local tx,ty=self:getPosition(k)
        rewardIconBg:setPosition(tx,ty)
        local rewardIcon
        local scale = 1
        local iconScale= 1
        local textSize = 25
        if item.type == "mm" then
          if self.version ==1 or self.version ==2 or self.version ==nil then
              rewardIcon = GetBgIcon("CandyBar.png",nil,nil,30,100)  
          elseif self.version ==3 or self.version ==4 then
              rewardIcon = GetBgIcon("mysteriousArmsIcon.png",nil,nil,80,100)
          end  
          textSize=20
        else
          rewardIcon,iconScale = G_getItemIcon(item)
          scale = 1.3
        end
        rewardIcon:setAnchorPoint(ccp(0.5,0.5))
        rewardIcon:setPosition(ccp(rewardIconBg:getContentSize().width/2,rewardIconBg:getContentSize().height/2))
        rewardIconBg:addChild(rewardIcon)

        local num = GetTTFLabel("x"..item.num,textSize)
        num:setAnchorPoint(ccp(1,0))
        num:setPosition(rewardIcon:getContentSize().width-10,10)
        rewardIcon:addChild(num)

        G_addRectFlicker(rewardIcon,scale/iconScale,scale/iconScale)

        self.backSprie:addChild(rewardIconBg)
        self.iconList[k]=rewardIconBg
      end
    end
  end
end

function acShengdanbaozangTab1:getPosition(index)
  local wSpace=196
  local hSpace=176
  local posX=wSpace*((index-1)%3)+196/2
  local posY=self.backSprie:getContentSize().height/2-(hSpace)*(math.ceil(index/3)-2)-176/2
  return posX,posY
end

function acShengdanbaozangTab1:updateShow()
  if acShengdanbaozangVoApi:checkIsCanLotteryAll() == false then
    self.giveUpmenu1:setVisible(false)
  else
    self.giveUpmenu1:setVisible(true)
  end
  local isFree = acShengdanbaozangVoApi:isToday()
  if isFree == false then
    self.freeBtn:setVisible(true)
    self.playBtn:setVisible(false)
    self.buyAndPlayBtn:setVisible(false)
    self.goldSp:setVisible(false)
    self.gemsLabel:setVisible(false)
    self.goldSp1:setVisible(false)
    self.gemsLabel1:setVisible(false)
    --self.lotteryNumSP:setVisible(true)
    self.leftLotteryNumLb:setVisible(true)
  else
    --不显示全部挖掘按钮
    if acShengdanbaozangVoApi:checkIsCanLotteryAll() == false then
      self.freeBtn:setVisible(false)
      self.playBtn:setVisible(true)
      self.buyAndPlayBtn:setVisible(false)

      self.goldSp:setVisible(true)
      self.gemsLabel:setVisible(true)

      self.goldSp1:setVisible(false)
      self.gemsLabel1:setVisible(false)

      --self.lotteryNumSP:setVisible(true)
      self.leftLotteryNumLb:setVisible(true)
    else
      self.freeBtn:setVisible(false)
      self.playBtn:setVisible(true)
      self.buyAndPlayBtn:setVisible(true)
      
      self.goldSp:setVisible(true)
      self.gemsLabel:setVisible(true)
      self.goldSp:setVisible(true)
      self.gemsLabel:setVisible(true)
      self.goldSp1:setVisible(true)
      self.gemsLabel1:setVisible(true)
      --self.lotteryNumSP:setVisible(true)
      self.leftLotteryNumLb:setVisible(true)
    end
  end
end

function acShengdanbaozangTab1:eventHandler(handler,fn,idx,cel)
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

function acShengdanbaozangTab1:refresh()
 acShengdanbaozangVoApi:refreshData()
 self.rewardList = acShengdanbaozangVoApi:getRewardList()
 self.leftLotteryNumLb:setString(getlocal("activity_shengdanbaozang_leftLotteryNum",{acShengdanbaozangVoApi:getLeftLotteryNum()}))
 self.leftLotteryNumLb1:setString(getlocal("activity_shengdanbaozang_leftLotteryNum",{acShengdanbaozangVoApi:getLeftLotteryNum()}))
end

function acShengdanbaozangTab1:tick()
  local istoday = acShengdanbaozangVoApi:isToday()
  if istoday ~= self.isToday then
    self:doUserHandler()
    self.isToday = istoday
  end
  if self.timeLb then
    local acVo = acShengdanbaozangVoApi:getAcVo()
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acShengdanbaozangTab1:dispose()
    self.spList=nil
    self.iconList=nil
    self.itemList=nil
    self.partSpTb=nil
    self.tv=nil
    self.layerNum=nil
    self.timeLb=nil
    self.maskSp:removeFromParentAndCleanup(true)
    self.maskSp = nil
    self.maskSp1:removeFromParentAndCleanup(true)
    self.maskSp1 = nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self = nil
end
