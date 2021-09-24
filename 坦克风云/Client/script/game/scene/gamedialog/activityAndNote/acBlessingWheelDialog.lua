acBlessingWheelDialog=commonDialog:new()
function acBlessingWheelDialog:new(parent,layerNum)
    local nc={}
    nc.tv=nil
    nc.bgLayer=nil
   
    nc.layerNum=nil
    nc.isToday = nil
    nc.isEnd = nil
    nc.touchEnabledSp=nil
    nc.rewardIconList={}
    nc.oneLotteryLb=nil

    setmetatable(nc,self)
    self.__index=self

    return nc

end

-- 更新领奖按钮显示
function acBlessingWheelDialog:update()

end

function acBlessingWheelDialog:initTableView()
  spriteController:addPlist("public/acBlessWords.plist")
  spriteController:addPlist("public/acKuangnuzhishi.plist")


  self.isToday = acBlessingWheelVoApi:isToday()
  self.isEnd = acBlessingWheelVoApi:isEnd()

    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight-105))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))

  local function touchDialog()

    end
    self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchDialog)
  self.touchEnabledSp:setAnchorPoint(ccp(0,0))
  self.touchEnabledSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
  self.touchEnabledSp:setIsSallow(true)
  self.touchEnabledSp:setTouchPriority(-(self.layerNum-1)*20-7)
  -- sceneGame:addChild(self.touchEnabledSp,self.layerNum)
  self.bgLayer:addChild(self.touchEnabledSp,self.layerNum)
  self.touchEnabledSp:setOpacity(0)
  self.touchEnabledSp:setPosition(ccp(10000,0))
  self.touchEnabledSp:setVisible(false)


  local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)

  backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,200))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
  backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-100))
    self.bgLayer:addChild(backSprie,1)

    local tankSp = CCSprite:createWithSpriteFrameName("kuangnuSp.png")
    tankSp:setScaleX((self.bgLayer:getContentSize().width-60)/tankSp:getContentSize().width)
    tankSp:setScaleY(190/tankSp:getContentSize().height)
    tankSp:setAnchorPoint(ccp(0.5,0.5))
    tankSp:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)
    backSprie:addChild(tankSp)

    local timeSP = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
    timeSP:setAnchorPoint(ccp(0.5,1))
    timeSP:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-10))
    backSprie:addChild(timeSP)


    local timeStr=acBlessingWheelVoApi:getTimeStr()
    self.timeLabel=GetTTFLabelWrap(timeStr,25,CCSizeMake(backSprie:getContentSize().width-120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.timeLabel:setAnchorPoint(ccp(0.5,1))
    self.timeLabel:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-20))
    backSprie:addChild(self.timeLabel,10)
 
    timeSP:setContentSize(CCSizeMake(backSprie:getContentSize().width-120,self.timeLabel:getContentSize().height+20))
    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local str1=getlocal("activity_blessingwheel_rule")
        tabStr={" ",str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        --dialog:setPosition(getCenterPoint(sceneGame))
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(backSprie:getContentSize().width-20,backSprie:getContentSize().height-10))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie:addChild(infoBtn,3)

    local tankIcon1 = CCSprite:createWithSpriteFrameName("xieerman.png")
    tankIcon1:setAnchorPoint(ccp(0,0))
    tankIcon1:setPosition(0,0)
    tankSp:addChild(tankIcon1)

    local tankIcon2 =  CCSprite:createWithSpriteFrameName("hushitank.png")
    tankIcon2:setAnchorPoint(ccp(1,0))
    tankIcon2:setPosition(tankSp:getContentSize().width,0)
    tankSp:addChild(tankIcon2)

    local explainLb = GetTTFLabelWrap(getlocal("shuoming")..":",25,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    explainLb:setAnchorPoint(ccp(0,1))
    explainLb:setPosition(30,self.bgLayer:getContentSize().height-350)
    self.bgLayer:addChild(explainLb)
    explainLb:setColor(G_ColorGreen)

    self.descTv,self.descLb=G_LabelTableView(CCSize(self.bgLayer:getContentSize().width-180,100),getlocal("activity_blessingwheel_content"),25,kCCTextAlignmentCenter)
    self.descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.descTv:setAnchorPoint(ccp(0,0))
    self.descTv:setPosition(ccp(120,self.bgLayer:getContentSize().height-420))
    self.bgLayer:addChild(self.descTv,2)
    self.descTv:setMaxDisToBottomOrTop(50)

    local oneGems=acBlessingWheelVoApi:getCost1()       --一次抽奖需要金币
    local tenGems=acBlessingWheelVoApi:getCost10()      --十次抽奖需要金币

  local leftPosX=self.bgLayer:getContentSize().width/2-150
  local rightPosX=self.bgLayer:getContentSize().width/2+150

  local lbY=140
  self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
  self.goldSp1:setAnchorPoint(ccp(0,0.5))
  self.goldSp1:setPosition(ccp(leftPosX,lbY))
  self.bgLayer:addChild(self.goldSp1)
  self.goldSp1:setScale(1.5)

  self.gemsLabel1=GetTTFLabel(oneGems,30)
  self.gemsLabel1:setAnchorPoint(ccp(1,0.5))
  self.gemsLabel1:setPosition(ccp(leftPosX,lbY))
  self.bgLayer:addChild(self.gemsLabel1,1)
    if acBlessingWheelVoApi:isGemsEnough(oneGems)==false then
        self.gemsLabel1:setColor(G_ColorRed)
    end

  local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
  goldSp2:setAnchorPoint(ccp(0,0.5))
  goldSp2:setPosition(ccp(rightPosX,lbY))
  self.bgLayer:addChild(goldSp2)
  goldSp2:setScale(1.5)

  local gemsLabel2=GetTTFLabel(tenGems,30)
  gemsLabel2:setAnchorPoint(ccp(1,0.5))
  gemsLabel2:setPosition(ccp(rightPosX,lbY))
  self.bgLayer:addChild(gemsLabel2,1)
    self.gemsLabel2=gemsLabel2
    if acBlessingWheelVoApi:isGemsEnough(tenGems)==false then
        self.gemsLabel2:setColor(G_ColorRed)
    end
    if self.lotterySprite==nil then
        local function nilfun( ... )
          -- body
        end
    self.lotterySprite=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilfun)
      self.lotterySprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-600))
      self.lotterySprite:setAnchorPoint(ccp(0,0))
      self.lotterySprite:setPosition(ccp(30,150))
      self.bgLayer:addChild(self.lotterySprite,1)
  end
  self.rewardList = acBlessingWheelVoApi:getItemList()

  self:initRewardPoolView()

    local leftPosX=self.bgLayer:getContentSize().width/2-150
    local rightPosX=self.bgLayer:getContentSize().width/2+150
    local btnY=70
   
    local function oneLottery()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
      if acBlessingWheelVoApi:isFree()==true then
        self:lottery(1,1)
      else
        self:lottery(0,1)
      end
    end
    if self.lotteryOneBtn==nil then
      local btnStr=getlocal("active_lottery_btn1")
    if acBlessingWheelVoApi:isFree()==true then
      btnStr=getlocal("daily_lotto_tip_2")
      self.goldSp1:setVisible(false)
            self.gemsLabel1:setVisible(false)
    end
    self.lotteryOneBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",oneLottery,2,btnStr,25,101)
      self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
      local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
      lotteryMenu:setPosition(ccp(leftPosX,btnY))
      lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
      self.bgLayer:addChild(lotteryMenu,2)
  end

  local function tenLottery()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
    self:lottery(0,10)
  end
    if self.lotteryTenBtn == nil then
    self.lotteryTenBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",tenLottery,2,getlocal("ten_roulette_btn"),25)
      self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
      local lotteryMenu=CCMenu:createWithItem(self.lotteryTenBtn)
      lotteryMenu:setPosition(ccp(rightPosX,btnY))
      lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
      self.bgLayer:addChild(lotteryMenu,2)
        if acBlessingWheelVoApi:isFree()==true then
            self.lotteryTenBtn:setEnabled(false)
        else
            self.lotteryTenBtn:setEnabled(true)        
        end
  end

    self:endUpdate()
end

function acBlessingWheelDialog:lottery(isFree,num)
    local gemCost=acBlessingWheelVoApi:getCost1()
    if num==10 then
      gemCost=acBlessingWheelVoApi:getCost10()
      isFree=0
    end
  if playerVoApi:getGems()<gemCost and isFree and isFree~=1 then
      local function callBack()
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(self.layerNum+1)
      end
      local title=getlocal("dialog_title_prompt")
      local content=getlocal("gemNotEnough",{gemCost,playerVo.gems,gemCost-playerVoApi:getGems()})
      smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,title,content,nil,self.layerNum+1)
      do return end
  end
  local function lotteryCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data==nil then
              do return end
            end
            acBlessingWheelVoApi:updateData(sData.data.blessingWheel)
            self.isToday=acBlessingWheelVoApi:isToday()
            
            local hasWord = false --记录当前抽到的奖励中有没有五福文字奖励   
            if num==1 and isFree~=1 then
              playerVoApi:setValue("gems",playerVoApi:getGems()-gemCost)
            elseif num==10 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-gemCost)
            end
            self:refreshGemView()
            --刷新活动数据
            local tipStr=""
            if sData.data["report"] then
              local awardData=sData.data["report"]
              if awardData==nil then
                return
              end
              acAnniversaryBlessVoApi:updateData(sData.data.anniversaryBless)
            local content = {}
                for k,v in pairs(awardData) do
              local pID,num,ptype
                    local award={}
                  if type(v)=="string" then
                    -- print("k==================",v)
                    pID=v
                    num=1
                        ptype="word"
                    local wordName=acAnniversaryBlessVoApi:getWordName(pID)
                    local picName=acAnniversaryBlessVoApi:getWordIconName(pID)
                    award={name=wordName,pic=picName,num=num,type=ptype}
                        hasWord=true
                  elseif type(v)=="table" then
                  for rtype,item in pairs(v) do
                    for k,v in pairs(item) do
                    -- print("k========"..k.."   v========"..v)
                    pID=k
                    num=v
                          ptype=rtype
                          local name,pic,desc,id,index,eType,equipId,bgname=getItem(pID,ptype)
                          award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId,bgname=bgname}
                          G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                    end
                    end
                  end
                    if ptype and pID and num then
                        self.lotteryPtype=ptype
                        self.lotteryPID=pID
                        self.lotteryPNum=num
                    end
                    table.insert(content,{award=award})
                end

                if num==1 then
                    self.touchEnabledSp:setVisible(true)
            self.touchEnabledSp:setPosition(ccp(0,0))
                    self:play()
                else
                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler(index)
                        if self.lotteryOneBtn then
                    self.lotteryOneBtn:setEnabled(true)
                  end
                  if self.lotteryTenBtn then
                            if acBlessingWheelVoApi:isFree()==true then
                                self.lotteryTenBtn:setEnabled(false)
                            else
                                self.lotteryTenBtn:setEnabled(true)
                            end
                  end
                  self:endUpdate()
                      end
                      smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(560,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,true,nil,nil,false)
                    end
                end
            end
            if hasWord and hasWord==true then
                --全服同步集齐文字的玩家个数
                local fullCount=acAnniversaryBlessVoApi:getPlayerCountFulled()
                local params={}
                params.finishNum=fullCount
                chatVoApi:sendUpdateMessage(33,params)
            end
        else
            if self.lotteryOneBtn then
              self.lotteryOneBtn:setEnabled(true)
            end
            if self.lotteryTenBtn then
              self.lotteryTenBtn:setEnabled(true)
            end
        end
    end
    if self.lotteryOneBtn then
      self.lotteryOneBtn:setEnabled(false)
    end
    if self.lotteryTenBtn then
      self.lotteryTenBtn:setEnabled(false)
    end
  socketHelper:blessWheelLottery(isFree,num,lotteryCallback)
end

function acBlessingWheelDialog:endUpdate()
  if acBlessingWheelVoApi:isEnd()==true then
    if self.lotteryOneBtn then
      self.lotteryOneBtn:setEnabled(false)
    end
    if self.lotteryTenBtn then
      self.lotteryTenBtn:setEnabled(false)
    end
  end
end

function acBlessingWheelDialog:initRewardPoolView()
  for i=1,9 do
    local item = acBlessingWheelVoApi:getItemByIndex(i)
    local wSpace=170
    local hSpace=(self.lotterySprite:getContentSize().height-25)/3
    local icon,iconScale
    if i==5 then
      local function showInfoHandler( ... )   
      end
      -- icon= LuaCCSprite:createWithSpriteFrameName("bless_rotary_icon.png",showInfoHandler)
            icon,iconScale = G_getItemIcon(item,100,true,self.layerNum)
      iconScale = 100/icon:getContentSize().width
      local posX,posY=self:getPosition(wSpace,hSpace,i,iconScale)
      icon:setTouchPriority(-(self.layerNum-1)*20-5)
          icon:setAnchorPoint(ccp(0.5,0.5))
          icon:setPosition(posX,posY)
          self.lotterySprite:addChild(icon)
    else
      icon,iconScale = G_getItemIcon(item,100,true,self.layerNum)
      local posX,posY=self:getPosition(wSpace,hSpace,i,iconScale)
          icon:setTouchPriority(-(self.layerNum-1)*20-5)
          icon:setAnchorPoint(ccp(0.5,0.5))
          icon:setPosition(posX,posY)
          self.lotterySprite:addChild(icon)

          local num = GetTTFLabel("x"..item.num,25/iconScale)
          num:setAnchorPoint(ccp(1,0))
          num:setPosition(icon:getContentSize().width-10,10)
          icon:addChild(num)
    end

    self.rewardIconList[i]=icon
    
  end

  local function nilFunc()
    end
    self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
    self.halo:setContentSize(CCSizeMake(100+8,100+8))
    self.halo:setAnchorPoint(ccp(0.5,0.5))
    self.halo:setTouchPriority(0)
    self.halo:setVisible(false)
    local tx,ty=self.rewardIconList[1]:getPosition()
    self.halo:setPosition(tx,ty)
    self.lotterySprite:addChild(self.halo,3)
end

function acBlessingWheelDialog:getPosition(wSpace,hSpace,index,scale)
  local posX=wSpace*((index-1)%3)+110+10
  local posY=self.lotterySprite:getContentSize().height/2-(hSpace-10)*(math.ceil(index/3)-2)-100+100
  return posX,posY
end

function acBlessingWheelDialog:fastTick()
  if self and self.tickIndex then
      self.tickIndex=self.tickIndex+1
      self.tickInterval=self.tickInterval-1
      if(self.tickInterval<=0)then
          self.tickInterval=self.tickConst
          if self.haloPos == 0 then
            self.haloPos =1
          elseif self.tickIndex>self.tickTotalInterval then
            self.haloPos = self.endIdx
          else
            self.haloPos=math.random(1,9)
          end
          if(self.haloPos>9)then
              self.haloPos=self.haloPos-9
          end
          local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
          self.halo:setPosition(tx,ty)
          if self.halo:isVisible()==false then
              self.halo:setVisible(true)
          end

            if self.endIdx>0 and (self.haloPos==self.endIdx) and self.tickIndex>self.tickTotalInterval then
                local function playEnd()
                    --base:removeFromNeedRefresh(self)
                    self:playEndEffect()
                end
                --local delay=CCDelayTime:create(0.5)
                local callFunc=CCCallFuncN:create(playEnd)
                
                local acArr=CCArray:create()
                --acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                self.bgLayer:runAction(seq)                
            end
      end
  end
end

function acBlessingWheelDialog:refreshGemView()
    local oneGems=acBlessingWheelVoApi:getCost1()       --一次抽奖需要金币
    local tenGems=acBlessingWheelVoApi:getCost10()      --十次抽奖需要金币
    if self.gemsLabel1 and self.gemsLabel2 then
        if acBlessingWheelVoApi:isGemsEnough(oneGems)==false then
            self.gemsLabel1:setColor(G_ColorRed)
        else
            self.gemsLabel1:setColor(G_ColorWhite)
        end
        if acBlessingWheelVoApi:isGemsEnough(tenGems)==false then
            self.gemsLabel2:setColor(G_ColorRed)
        else
            self.gemsLabel2:setColor(G_ColorWhite)
        end
    end
end

function acBlessingWheelDialog:play()
    self.tickIndex=0
    self.tickTotalInterval=120
    self.tickInterval=10
    self.tickConst=10
    self.intervalNum=3 --fasttick间隔 3帧一次
    self.haloPos=0
    self.slowStart=false   
    self.endIdx=0

    -- print("self.lotteryPtype=======",self.lotteryPtype)
    -- print("self.lotteryPID=======",self.lotteryPID)
    -- print("self.lotteryPNum=======",self.lotteryPNum)

    if self.lotteryPtype=="word" then
        self.endIdx=5
    else
        for k,v in pairs(self.rewardList) do
            if self.rewardList and v and v.type==self.lotteryPtype and v.key==self.lotteryPID and  v.num==self.lotteryPNum then
                self.endIdx=k
            end
        end
    end

    self.slowTime=4

    if self.endIdx>0 then
        self.count=9*self.tickConst --转1圈之后开始减速
        if self.endIdx>self.slowTime then
            self.slowStartIndex=self.endIdx-self.slowTime
        else
            self.count=self.count-((self.slowTime-1)*self.tickConst)
            self.slowStartIndex=self.endIdx-self.slowTime+9
        end
    end
end

function  acBlessingWheelDialog:playEndEffect()
  self.tickIndex=nil
    
    if self.maskSp==nil then
        local function tmpFunc()
        end
        self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
        self.maskSp:setOpacity(255)
        local size=CCSizeMake(G_VisibleSize.width-60,self.bgLayer:getContentSize().height-610)
        self.maskSp:setContentSize(size)
        self.maskSp:setAnchorPoint(ccp(0.5,0))
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,160))
        self.maskSp:setIsSallow(true)
        self.maskSp:setTouchPriority(-(self.layerNum-1)*20-6)
        self.bgLayer:addChild(self.maskSp,3)
    else
        self.maskSp:setVisible(true)
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,150))
    end

    local bgSize=self.rewardIconList[self.haloPos]:getContentSize()
    local item=self.rewardList[self.haloPos]
    if self.endIdx == 5 then
      self.rewardIconBg = CCSprite:createWithSpriteFrameName("SpecialBoxOpen.png")
      local addSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
      addSp:setPosition(getCenterPoint(self.rewardIconBg))
      self.rewardIconBg:addChild(addSp)
    else
      self.rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    end
    self.rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
    local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
    -- tx=tx+bgSize.width/2
    -- ty=ty+bgSize.height/2
    self.rewardIconBg:setPosition(tx,ty)


    local rewardIcon=self.rewardIconList[self.haloPos]:getChildByTag(123+self.haloPos)
    -- self.rewardIconList[self.haloPos]:removeChild(rewardIcon,true)
    local name=""
    local num=0
    if item.key=="p978" then
        local picName=acAnniversaryBlessVoApi:getWordIconName(self.lotteryPID)
        rewardIcon=CCSprite:createWithSpriteFrameName(picName)
        name=acAnniversaryBlessVoApi:getWordName(self.lotteryPID)
        num=1
    else
        rewardIcon = CCSprite:createWithSpriteFrameName(item.pic)
        name=item.name
        num=item.num
    end

    rewardIcon:setAnchorPoint(ccp(0.5,0.5))
    rewardIcon:setPosition(ccp(self.rewardIconBg:getContentSize().width/2,self.rewardIconBg:getContentSize().height/2))
    self.rewardIconBg:addChild(rewardIcon)
    self.maskSp:addChild(self.rewardIconBg,4)
    local scale=100/rewardIcon:getContentSize().width
    rewardIcon:setScale(scale)

    if self.confirmBtn==nil then
        local function hideMask()
            if self then
                -- self.bgLayer:removeChild(self.rewardIconBg,true)
                self.rewardIconBg:removeFromParentAndCleanup(true)
                self.rewardIconBg=nil

                if self.maskSp then
                    self.maskSp:setPosition(ccp(10000,0))
                    self.maskSp:setVisible(false)
                end
                if self.confirmBtn then
                    self.confirmBtn:setEnabled(false)
                    self.confirmBtn:setVisible(false)
                end
                if self.halo then
                    self.halo:setVisible(false)
                end
                if self.nameLb then
                    self.nameLb:setVisible(false)
                end
                if self.itemDescLb then
                    self.itemDescLb:setVisible(false)
                end

                if self.lotteryOneBtn then
                    self.lotteryOneBtn:setEnabled(true)
                end
                
                if self.lotteryTenBtn then
                  if acBlessingWheelVoApi:isFree()==true then
                    self.lotteryTenBtn:setEnabled(false)
                  else
                    self.lotteryTenBtn:setEnabled(true)
                  end
                end
            end

        end
        self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",hideMask,4,getlocal("confirm"),25)
        self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
        local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
        boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-120))
        boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-7)
        self.maskSp:addChild(boxSpMenu3,2)

        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    else
        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    end

    if self.nameLb==nil then
        -- self.nameLb=GetTTFLabelWrap(item.name,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.nameLb=GetTTFLabel(name.." x"..num,25)
        self.nameLb:setAnchorPoint(ccp(0.5,1))
        self.nameLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-10))
        self.maskSp:addChild(self.nameLb,2)
        self.nameLb:setVisible(false)
    else
        self.nameLb:setString(name.." x"..num)
        self.nameLb:setVisible(false)
    end

    local function playEndCallback()
        local str=G_showRewardTip({self.rewardList[self.endIdx]},false)
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

        if self.touchEnabledSp then
            self.touchEnabledSp:setVisible(false)
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end

        if self.confirmBtn then
            self.confirmBtn:setEnabled(true)
            self.confirmBtn:setVisible(true)
        end
        if self.nameLb then
            self.nameLb:setVisible(true)
        end

        self:refresh()
    end

    local delay1=CCDelayTime:create(0.3)
    local scale1=CCScaleTo:create(0.4,150/rewardIcon:getContentSize().width/scale)
    local scale2=CCScaleTo:create(0.4,100/rewardIcon:getContentSize().width/scale)
    -- local tx,ty=self.playBtnBg:getPosition()
    local mvTo=CCMoveTo:create(0.3,ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+80))
    local scale3=CCScaleTo:create(0.1,200/rewardIcon:getContentSize().width/scale)
    local scale4=CCScaleTo:create(0.2,120/rewardIcon:getContentSize().width/scale)
    local delay2=CCDelayTime:create(0.2)
    local callFunc=CCCallFuncN:create(playEndCallback)
    
    local acArr=CCArray:create()
    acArr:addObject(delay1)
    acArr:addObject(scale1)
    acArr:addObject(scale2)
    acArr:addObject(mvTo)
    acArr:addObject(scale3)
    acArr:addObject(scale4)
    acArr:addObject(delay2)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.rewardIconBg:runAction(seq)
end


function acBlessingWheelDialog:tick()
  local isend=acBlessingWheelVoApi:isEnd()
  if isend==true then
    self:close()
    do return end
  end

  local istoday=acBlessingWheelVoApi:isToday()
   
    if istoday ~= self.isToday and istoday==false then
    acBlessingWheelVoApi:resetAc()
    self:refresh()
    self.lotteryTenBtn:setEnabled(false)
    self.isToday=istoday
  end
end

function acBlessingWheelDialog:refresh()
    if self and self.bgLayer then
      if self.lotteryOneBtn and self.lotteryTenBtn then
        local btnLb=self.lotteryOneBtn:getChildByTag(101)
        btnLb=tolua.cast(btnLb,"CCLabelTTF")
        if btnLb and self.goldSp1 and self.gemsLabel1 then
        if acBlessingWheelVoApi:isFree()==true then
              btnLb:setString(getlocal("daily_lotto_tip_2"))
            self.goldSp1:setVisible(false)
                    self.gemsLabel1:setVisible(false)
        else
              btnLb:setString(getlocal("active_lottery_btn1"))
            self.goldSp1:setVisible(true)
                    self.gemsLabel1:setVisible(true)
        end
        end
      end
    end
end


function acBlessingWheelDialog:dispose()
  if self.touchEnabledSp then
        self.touchEnabledSp:removeFromParentAndCleanup(true)
        self.touchEnabledSp=nil
    end
    self.isToday = nil
    self.isEnd = nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.touchEnabledSp=nil
    self.descTv=nil
    self.descLb=nil
    self.lotteryTenBtn=nil
    self.lotteryOneBtn=nil
    self.goldSp1=nil
    self.gemsLabel1=nil
    self.nameLb=nil

  spriteController:removePlist("public/acBlessWords.plist")
  spriteController:removePlist("public/acKuangnuzhishi.plist")
  
end
