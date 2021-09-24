acShengdankuanghuanTab1={
	
}

function acShengdankuanghuanTab1:new(  )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.tv=nil
	self.bgLayer=nil
	self.layerNum=nil
	self.isToday=nil

  self.sixGifts={}
	self.awaredData=nil
	self.state=nil   --状态


	return nc
end

function acShengdankuanghuanTab1:init(layerNum)

  if acShengdankuanghuanVoApi:getVersion() ==3 then
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    --CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/kuangnuImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.sixGifts=acShengdankuanghuanVoApi:getV3Pic()
  end
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum


	self:initTableView()
	return self.bgLayer
end

function acShengdankuanghuanTab1:initTableView( )

	   local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,200))
    headBs:setAnchorPoint(ccp(0.5,1))
    headBs:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height - 165))
    self.bgLayer:addChild(headBs,4)

    local leftIcon
    if acShengdankuanghuanVoApi:getVersion() ~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
      leftIcon=CCSprite:createWithSpriteFrameName("arsenalIcon.png")
    else
      leftIcon = CCSprite:createWithSpriteFrameName("ChristmasTreeIcon.png")
    end
    leftIcon:setPosition(ccp(20,headBs:getContentSize().height/2))
    leftIcon:setAnchorPoint(ccp(0,0.5))
    headBs:addChild(leftIcon,5)

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),25)
    actTime:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20))
    headBs:addChild(actTime,5)
    actTime:setColor(G_ColorGreen)

    local acVo = acShengdankuanghuanVoApi:getAcVo()
    if acVo then
    	local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.et)
    	local timeLabel = GetTTFLabel(timeStr,25)
    	timeLabel:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20-actTime:getContentSize().height))
    	headBs:addChild(timeLabel,5)
      self.timeLb=timeLabel
      self:updateAcTime()
    end
    local labeSize,posY2 =25,90
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="ru" then
        labeSize = 23
        if G_isIOS() == false then
            posY2 = 70
        end
    end
    local headtitle,headLb,middleLb,sendMessage
    if acShengdankuanghuanVoApi:getVersion() ~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
      headtitle ="activity_munitionsSacles_titleLb"
      headLb ="activity_munitionsSacles_Label"
      middleLb="activity_munitionsSacles_middleLabel"
      sendMessage="activity_munitionsSacles_GoldChatSystemMessage"
    else
      headtitle="activity_shengdankuanghuan_eggHeaderLabel_1"
      headLb ="activity_shengdankuanghuan_eggHeaderLabel_2"
      middleLb="activity_shengdankuanghuan_eggMiddleLabel"
      sendMessage="activity_shengdankuanghuan_GoldChatSystemMessage"
    end

    local yellowLabel = GetTTFLabelWrap(getlocal(headtitle),labeSize,CCSizeMake(headBs:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    yellowLabel:setPosition(ccp(leftIcon:getContentSize().width+30,posY2))
    yellowLabel:setAnchorPoint(ccp(0,0))
    yellowLabel:setColor(G_ColorYellow)
    headBs:addChild(yellowLabel,5)

    local desc1 = G_LabelTableView(CCSize(headBs:getContentSize().width-leftIcon:getContentSize().width-50,70),getlocal(headLb),25,kCCTextAlignmentLeft)
    desc1:setPosition(ccp(leftIcon:getContentSize().width+30,15))
    desc1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desc1:setAnchorPoint(ccp(0,1))
    headBs:addChild(desc1,2)
    desc1:setMaxDisToBottomOrTop(50)

    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 40
    end
   	local smalTitl = GetTTFLabel(getlocal("activity_fbReward_con"),26)
    smalTitl:setAnchorPoint(ccp(0,0.5))
   	smalTitl:setPosition(ccp(30,self.bgLayer:getContentSize().height-headBs:getContentSize().height-200-adaH))
   	smalTitl:setColor(G_ColorGreen)
   	self.bgLayer:addChild(smalTitl,5)

   	local desc2 = G_LabelTableView(CCSize(self.bgLayer:getContentSize().width-smalTitl:getContentSize().width-60,66),getlocal(middleLb,{acShengdankuanghuanVoApi:getSmallPoint(),acShengdankuanghuanVoApi:getBigPoint()}),26,kCCTextAlignmentLeft)
   	desc2:setPosition(ccp(30+smalTitl:getContentSize().width,self.bgLayer:getContentSize().height-headBs:getContentSize().height-245-adaH))
   	desc2:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
   	desc2:setAnchorPoint(ccp(0,1))
   	desc2:setMaxDisToBottomOrTop(50)
   	self.bgLayer:addChild(desc2,5)

     local function rechange()
      PlayEffect(audioCfg.mouseClick)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      activityAndNoteDialog:closeAllDialog()
      vipVoApi:showRechargeDialog(self.layerNum+1)
    end

    local rechangeBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechange,nil,getlocal("recharge"),25)
    rechangeBtn:setAnchorPoint(ccp(0.5,0.5))
    local rechangeMenu =CCMenu:createWithItem(rechangeBtn)
    rechangeMenu:setPosition(self.bgLayer:getContentSize().width/2+150,70)
    rechangeMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(rechangeMenu)

    local function rewardHandler()
      PlayEffect(audioCfg.mouseClick)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      local function allGoldReward(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret then
          if sData and sData.data.shengdankuanghuan.clientRewardGold then
            local reward = sData.data.shengdankuanghuan.clientRewardGold
            local content = {}
            local name,pic,desc,id,index,eType,equipId=getItem("gems","u")
            if reward then
              for k,v in pairs(reward) do
                local item = {}
                if v then
                  local addGold = v[1]
                  local vate = v[2]
                  local index = v[3]
                  playerVoApi:setValue("gems",playerVo["gems"]+tonumber(addGold))
                  acShengdankuanghuanVoApi:updateCanRewardByID(index)
                  if vate>= acShengdankuanghuanVoApi:getChatVate() then
                      local message={key=sendMessage,param={playerVoApi:getPlayerName(),vate*100}}
                      chatVoApi:sendSystemMessage(message)
                  end
                  local point = vate*100
                  local  tmpStoreCfg=G_getPlatStoreCfg()
                  name=tmpStoreCfg["gold"][SizeOfTable(tmpStoreCfg["gold"])-index+1]
                  local award={name=name,num=addGold,pic=pic,desc=desc,id=id,type=v.p,index=index,key=v.t,eType=eType,equipId=equipId}
                  table.insert(content,{award=award,point=point})
                end
              end
              local function confirmHandler( ... )
                  self:updata()
              end
              smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,nil,nil,nil,true)
              acShengdankuanghuanVoApi:updateShow()
            end
          end
        end
      end
      socketHelper:activityShengdankuanghuanAllGoldReward(allGoldReward)
    end

    self.rewardBtn =GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardHandler,nil,getlocal("activity_shareHappiness_getAll"),25)
    self.rewardBtn:setAnchorPoint(ccp(0.5,0.5))
    local rewardMenu =CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(self.bgLayer:getContentSize().width/2-150,70)
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(rewardMenu)

    local function touch( ... )
      -- body
    end

    if self.backSprie==nil then
      self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touch)
      self.backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-580-2*adaH))
      self.backSprie:setAnchorPoint(ccp(0.5,0))
      self.backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,110+adaH/2))
      self.bgLayer:addChild(self.backSprie,1)
    end

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.backSprie:getContentSize().width,self.backSprie:getContentSize().height),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(0,0))
    self.backSprie:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(0)    
    self:updateBtnShow()
end
function acShengdankuanghuanTab1:updateBtnShow()
  if self.rewardBtn then
     if acShengdankuanghuanVoApi:checkIsCanGoldReward()==true then
      self.rewardBtn:setEnabled(true)
    else
      self.rewardBtn:setEnabled(false)
    end
  end
 
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acShengdankuanghuanTab1:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize =CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-580)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local localWidth = 180
       local localHeight = 180
       local scale
       local sendMessage,RebatesRewardTip
       if acShengdankuanghuanVoApi:getVersion() ~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
          scale = 1.2
          sendMessage ="activity_munitionsSacles_GoldChatSystemMessage"
          RebatesRewardTip ="activity_munitionsSacles_RebatesRewardTip"
       else
          scale = 1.4
          sendMessage ="activity_shengdankuanghuan_GoldChatSystemMessage"
          RebatesRewardTip ="activity_shengdankuanghuan_RebatesRewardTip"
       end
        for i=1,6 do
          local posX,posY = self:getPositions(localWidth,localHeight,i,scale)
          if G_getIphoneType() == G_iphoneX then
            posY = posY + 80
          end

            local  tmpStoreCfg=G_getPlatStoreCfg()
            local mType=tmpStoreCfg["moneyType"][GetMoneyName()]
            local mPrice=tmpStoreCfg["money"][GetMoneyName()][6-i+1]
            local priceStr =getlocal("buyGemsPrice",{mType,mPrice})

            local golds = tmpStoreCfg["gold"][6-i+1]
          if acShengdankuanghuanVoApi:getCanRewardNumByID(i) >= 1 then

            local rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
            rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
            rewardIconBg:setPosition(posX,posY)
            cell:addChild(rewardIconBg)

            local function rewardHandler()
              PlayEffect(audioCfg.mouseClick)
              if G_checkClickEnable()==false then
                  do
                      return
                  end
              else
                  base.setWaitTime=G_getCurDeviceMillTime()
              end
             
              local function goldRewardCallBack(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret then
                  if sData and sData.data.shengdankuanghuan then

                    local rebates =sData.data.shengdankuanghuan.vate
                    local addGold =sData.data.shengdankuanghuan.rewardGold
                    playerVoApi:setValue("gems",playerVo["gems"]+tonumber(addGold))
                    if rebates>= acShengdankuanghuanVoApi:getChatVate() then
                      local message={key=sendMessage,param={playerVoApi:getPlayerName(),rebates*100}}
                      chatVoApi:sendSystemMessage(message)
                    end
                    acShengdankuanghuanVoApi:updateCanRewardByID(i)
                    self:updata()
                    acShengdankuanghuanVoApi:updateShow()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal(RebatesRewardTip,{rebates*100,addGold}),28)
                  end
                end
              end
              socketHelper:activityShengdankuanghuanGoldReward(i,goldRewardCallBack)

            end
            local clickPic,clickPicOpen
            if acShengdankuanghuanVoApi:getVersion() ~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
                clickPic =self.sixGifts[i][1]
                clickPicOpen =self.sixGifts[i][2]
            else
                clickPic = "mainBtnGift.png"
                clickPicOpen = "mainBtnGiftDown.png"
            end
            local rewardBtn =GetButtonItem(clickPic,clickPicOpen,clickPicOpen,rewardHandler,nil,nil,nil)
            rewardBtn:setScale(scale)
            local rewardMenu =CCMenu:createWithItem(rewardBtn)
            rewardMenu:setPosition(posX,posY)
            rewardMenu:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(rewardMenu)

            local descLb= GetTTFLabelWrap(getlocal("activity_shengdankuanghuan_ClickReward"),25,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0.5,1))
            descLb:setPosition(posX,posY-50)
            cell:addChild(descLb)
            descLb:setColor(G_ColorYellow)


          else
            local merryIcon
            if acShengdankuanghuanVoApi:getVersion() ~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
                merryIcon=CCSprite:createWithSpriteFrameName(self.sixGifts[i][1])
            else
                merryIcon=CCSprite:createWithSpriteFrameName("mainBtnGift.png")
                merryIcon:setScale(scale)
            end
            merryIcon:setAnchorPoint(ccp(0.5,0.5))
            merryIcon:setPosition(ccp(posX,posY))
            merryIcon:setPosition(ccp(posX,posY))
            cell:addChild(merryIcon,5)

            if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_isKakao() then
                priceStr =getlocal("buyGemsPrice",{mPrice,mType})
            end

            local jgLbSize =160
            local jjLbSize =25
            if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
              jgLbSize =100
              jjLbSize =19
            end
            local descLb= GetTTFLabelWrap(getlocal("activity_rechargeDouble_recharge",{priceStr}),jjLbSize,CCSizeMake(jgLbSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0.5,1))
            descLb:setPosition(posX,posY-47)
            cell:addChild(descLb)
            
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

function acShengdankuanghuanTab1:getPositions(wSpace,hSpace,index,scale)
  local posX=wSpace*((index-1)%3)+100+10
  local posY=self.backSprie:getContentSize().height/2-(hSpace-10)*(math.ceil(index/3)-2)-hSpace/2+30
  return posX,posY
end

function acShengdankuanghuanTab1:updata()
  self:updateBtnShow()
  if self.tv then
    self.tv:reloadData()
  end
end

function acShengdankuanghuanTab1:tick()
  self:updateAcTime()
end

function acShengdankuanghuanTab1:updateAcTime()
    local acVo=acShengdankuanghuanVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acShengdankuanghuanTab1:dispose( ... )
  if acShengdankuanghuanVoApi:getVersion() ==3 then
    -- dmj注释0701，因为startgame.lua中已经加载过了，再释放会报错
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/kuangnuImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
  end
end