acAlienbumperweekDialog=commonDialog:new()

function acAlienbumperweekDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    totalrechargeNumLb=nil
    self.cellHeight = 480
    if G_getIphoneType() == G_iphoneX then
      self.cellHeight = self.cellHeight + 190
    end
    totalRechargeNum=0--面板里显示的累计充值总金额
    openDialogTs=0--打开面板的时间戳
    tenGem=nil
    self.strSize2PosSubHeight =17
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

function acAlienbumperweekDialog:initTableView()
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
    self.strSize2PosSubHeight = 0
  end
  self.openDialogTs=base.serverTime
  -- 判断充值是否跨天
  local lastRechargeWeeTs=acAlienbumperweekVoApi:getLastRechargeWeeTs()
  if lastRechargeWeeTs and G_getWeeTs(lastRechargeWeeTs)~=G_getWeeTs(base.serverTime) then
      acAlienbumperweekVoApi:changeDayUpdateData()
  end

  local titleW = G_VisibleSizeWidth - 20
  local function callBack( ... )
    -- body
  end
  -- 背景
  local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),callBack)
  backSprie:setAnchorPoint(ccp(0.5,1))
  backSprie:setPosition(ccp(titleW/2+10,G_VisibleSize.height-85))
  self.bgLayer:addChild(backSprie)
  local bgSp = CCSprite:create("public/acMeteoriteLanding_3.jpg")
  backSprie:setContentSize(CCSizeMake(bgSp:getContentSize().width+16,bgSp:getContentSize().height+16))
  bgSp:setAnchorPoint(ccp(0,0))
  bgSp:setPosition(ccp(8,8))
  backSprie:addChild(bgSp,2)
  -- bgSp:setScale(0.97)

  -- if(G_isIphone5())then
  --   bgSp:setScaleY(1.15)
  -- end

  -- 遮罩
  local maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,2,2),callBack)
  maskSp:setContentSize(CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height))
  maskSp:setAnchorPoint(ccp(0,0))
  maskSp:setPosition(ccp(0,0))
  backSprie:addChild(maskSp,4)

  -- 活动时间
  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp(titleW/2, backSprie:getContentSize().height -10))
  backSprie:addChild(acLabel,5)
  acLabel:setColor(G_ColorGreen)

  local acVo = acAlienbumperweekVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,22)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp(titleW/2, backSprie:getContentSize().height - 50))
  backSprie:addChild(messageLabel,5)
  self.timeLb=messageLabel
  self:updateAcTime()


  -- 帮助按钮
  local function touch(tag,object)
    PlayEffect(audioCfg.mouseClick)
    local tabStr = {}
    local tabColor = {}
    tabStr = {"\n",getlocal("activity_alienbumperweek_tip3"),"\n",getlocal("activity_alienbumperweek_tip2"),"\n",getlocal("activity_alienbumperweek_tip1"),"\n"}
    tabColor = {nil, nil, nil, nil, nil,nil, nil}
    local td=smallDialog:new()
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    sceneGame:addChild(dialog,self.layerNum+1)

  end

  local menuItemDesc = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  menuItemDesc:setScale(0.8)
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(backSprie:getContentSize().width-20, backSprie:getContentSize().height-10))
  backSprie:addChild(menuDesc,5)

  -- 活动描述
  local function callBack2( ... )
    -- body
  end
  -- local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),callBack2)
  -- descBg:setContentSize(CCSizeMake(400,160))
  -- descBg:setPosition(ccp(10,10))
  -- descBg:setAnchorPoint(ccp(0,0))
  -- backSprie:addChild(descBg,3)
  local desc = getlocal("activity_alienbumperweek_desc",{acAlienbumperweekVoApi:getProduceRateStr(),acAlienbumperweekVoApi:getResRateStr()})
  local descLabel=GetTTFLabelWrap(desc,23,CCSizeMake(backSprie:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  descLabel:setAnchorPoint(ccp(0,0))
  descLabel:setPosition(ccp(40,40))
  backSprie:addChild(descLabel,5)


  -- 副标题
  local function subTitleBgHandler( ... )
    -- body
  end
  local subTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),subTitleBgHandler)
  subTitleBg:setContentSize(CCSizeMake(titleW-20,50))
  subTitleBg:setAnchorPoint(ccp(0,1))
  subTitleBg:setPosition(ccp(20,backSprie:getPositionY()-backSprie:getContentSize().height-5))
  self.bgLayer:addChild(subTitleBg)
  local subTitleStr = getlocal("activity_alienbumperweek_subTitle")
  -- local subTitleLb=GetTTFLabelWrap(subTitleStr,23,CCSizeMake(subTitleBg:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  local strSize2   = 16
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
    strSize2 =23
  end
  local subTitleLb=GetTTFLabel(subTitleStr,strSize2)
  subTitleLb:setAnchorPoint(ccp(0.5,1))
  subTitleLb:setPosition(ccp(subTitleBg:getContentSize().width/2,subTitleBg:getContentSize().height-10))
  subTitleBg:addChild(subTitleLb)
  -- 今日累计充值金额文本
  self.totalRechargeNum=acAlienbumperweekVoApi:hasRechargeNum()
  local rechargeNumStr = getlocal("activity_alienbumperweek_totalrecharge",{self.totalRechargeNum})
  self.totalrechargeNumLb=GetTTFLabel(rechargeNumStr,25)
  self.totalrechargeNumLb:setAnchorPoint(ccp(0,1))
  self.totalrechargeNumLb:setPosition(ccp(30,subTitleBg:getPositionY()-subTitleBg:getContentSize().height-10))
  self.bgLayer:addChild(self.totalrechargeNumLb)
  self.totalrechargeNumLb:setColor(G_ColorYellow)

  self.tenGem = CCSprite:createWithSpriteFrameName("IconGold.png")
  self.tenGem:setAnchorPoint(ccp(0,0.5))
  self.tenGem:setPosition(self.totalrechargeNumLb:getPositionX()+self.totalrechargeNumLb:getContentSize().width+10, self.totalrechargeNumLb:getPositionY()-self.totalrechargeNumLb:getContentSize().height/2)
  self.bgLayer:addChild(self.tenGem)

  local function callBack3(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack3)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(titleW, self.totalrechargeNumLb:getPositionY()-self.totalrechargeNumLb:getContentSize().height-15))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
 
  -- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(titleW,450),nil)
  local adaH = 0
  if G_getIphoneType() == G_iphoneX then
    adaH = 20
  end
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(titleW,self.totalrechargeNumLb:getPositionY()-self.totalrechargeNumLb:getContentSize().height-15-40-80+adaH),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,30+80))
  -- self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)


  -- 去充值按钮
  local function rechargeCallback(tag,object)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      --activityAndNoteDialog:closeAllDialog()
    vipVoApi:showRechargeDialog(self.layerNum+1)
  end
  local rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rechargeCallback,nil,getlocal("recharge"),25,11)
  rewardBtn:setAnchorPoint(ccp(0.5,0))
  local rewardMenu=CCMenu:createWithItem(rewardBtn)
  rewardMenu:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,10))
  rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
  self.panelLineBg:addChild(rewardMenu,2)
end




function acAlienbumperweekDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth - 40,self.cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    
    local function callBack( ... )
      -- body
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),callBack)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30,self.cellHeight))
    backSprie:setPosition(ccp((G_VisibleSizeWidth - 40)/2+10,self.cellHeight))
    cell:addChild(backSprie)

    local reward = acAlienbumperweekVoApi:getRewardList()
    for i=1,#reward do
        local awardTab=FormatItem(reward[i],true)
        local desc = ""
        local pic = acAlienbumperweekVoApi:getIconPicById(i)
        for k,v in pairs(awardTab) do
            -- pic=v.pic
            if desc=="" then
                desc=desc..v.name.."*"..v.num
            else
                desc=desc..","..v.name.."*"..v.num
            end
            
        end 
        
        -- if i==3 then
        --     pic="silverBox.png"
        -- elseif i==4 then
        --     pic="SpecialBox.png"
        -- end
        local iconW = 100
        local iconH = 100
        local adaH = 10
        if G_getIphoneType() == G_iphoneX then
          iconH = 140
          adaH = 25
        end

        local function showInfoHandler(hd,fn,idx)
            if self.tv:getIsScrolled()==true then
              do return end
            end
            PlayEffect(audioCfg.mouseClick)
            local reward2 = acAlienbumperweekVoApi:getRewardList()
            local reward=FormatItem(reward2[idx]) or {}
            local content={}        
            for k,v in pairs(reward) do
             table.insert(content,{award=v,})
            end
            smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_tankjianianhua_awardContent"),content,true,true,self.layerNum+1,nil,false,false,nil,nil,nil,nil,nil,nil,nil,nil,true)
        end
        local icon=LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
        icon:setPosition(ccp(20,self.cellHeight-(iconH+20)*(i-1)-adaH))
        icon:setAnchorPoint(ccp(0,1))
        if i==1 or i==2 then
          icon:setScaleX(0.75)
          icon:setScaleY(0.75)
        else
          icon:setScaleX(0.81)
          icon:setScaleY(0.81)
        end
        
        -- icon:setScaleX(iconW/icon:getContentSize().width)
        -- icon:setScaleY(iconH/icon:getContentSize().height)
        icon:setTag(i)
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(icon)

        if i~= #reward then
            local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
            lineSp2:setAnchorPoint(ccp(0.5,0.5));
            lineSp2:setPosition(self.bgLayer:getContentSize().width/2,icon:getPositionY()-iconH-10)
            if G_getIphoneType() == G_iphoneX then
              lineSp2:setPosition(self.bgLayer:getContentSize().width/2,icon:getPositionY()-iconH+20)
            end
            cell:addChild(lineSp2,2)
            lineSp2:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp2:getContentSize().width)
        end
        
        -- 需要充值的金额
        local rechargeNumStr = getlocal("activity_alienbumperweek_recharge",{acAlienbumperweekVoApi:getCostList(i)})
        local rechargeNumLb=GetTTFLabel(rechargeNumStr,22)
        rechargeNumLb:setAnchorPoint(ccp(0,1))
        rechargeNumLb:setPosition(ccp(icon:getPositionX()+iconW+10,icon:getPositionY()))
        cell:addChild(rechargeNumLb)
        rechargeNumLb:setColor(G_ColorYellow)

        local tenGem = CCSprite:createWithSpriteFrameName("IconGold.png")
        tenGem:setAnchorPoint(ccp(0,0.5))
        tenGem:setPosition(rechargeNumLb:getPositionX()+rechargeNumLb:getContentSize().width+10, rechargeNumLb:getPositionY()-rechargeNumLb:getContentSize().height/2)
        cell:addChild(tenGem)

        -- 描述
        local rewardDescLb=GetTTFLabelWrap(desc,22,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        rewardDescLb:setAnchorPoint(ccp(0,1))
        rewardDescLb:setPosition(ccp(icon:getPositionX()+iconW+10,icon:getPositionY()-rechargeNumLb:getContentSize().height-10+self.strSize2PosSubHeight))
        cell:addChild(rewardDescLb)

        -- 按钮
        local state = acAlienbumperweekVoApi:getRewardBtnState(i)
        if state==1 then
            local function rewardHandler(tag,object)
                PlayEffect(audioCfg.mouseClick)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                    end
                end
                local function getRewardCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if self==nil or self.tv==nil then
                            do return end
                        end
                        local index = sData.data.id
                        local rewardItem = acAlienbumperweekVoApi:getRewardListById(index)
                        if rewardItem then
                            local reward=FormatItem(rewardItem,true)
                            for k,v in pairs(reward) do
                              G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true)
                            end
                            G_showRewardTip(reward,true)
                            acAlienbumperweekVoApi:afterGetReward(index)
                        end
                        
                        -- -- 刷新tv后tv仍然停留在当前位置
                        local recordPoint = self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)
                        
                    end
                end

                socketHelper:acalienbumperweekChoujiang(tag,getRewardCallback)
            end
            local menuItemAward=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,i,nil,0)
            -- self:iconFlicker(menuItemAward)
            menuItemAward:setScale(0.85)
            local menuAward=CCMenu:createWithItem(menuItemAward)
            menuAward:setAnchorPoint(ccp(1,0.5))
            menuAward:setTag(1000+i)
            menuAward:setPosition(ccp(G_VisibleSizeWidth - 80,icon:getPositionY()-iconW/2))
            menuAward:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(menuAward,1)
        else

          if state==0 then
    
          elseif state==2 then
              local str2Size = 18
              local strPosWidth = 35

              if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
                  str2Size =22
                  strPosWidth=45
              end
              local hadRewardLb=GetTTFLabel(getlocal("activity_hadReward"),str2Size)
              hadRewardLb:setAnchorPoint(ccp(1,0.5))
              hadRewardLb:setPosition(ccp(G_VisibleSizeWidth - strPosWidth,icon:getPositionY()-iconW/2))
              cell:addChild(hadRewardLb)
              hadRewardLb:setColor(G_ColorYellow)
          end
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

function acAlienbumperweekDialog:tick()
    if self then
        self:update()
    end
    
    local isNeedRefresh = false
    if self.openDialogTs and G_getWeeTs(self.openDialogTs)~=G_getWeeTs(base.serverTime) then
        -- 已经跨天
        acAlienbumperweekVoApi:changeDayUpdateData()
        isNeedRefresh=true
    end

    if self and self.totalrechargeNumLb and self.totalRechargeNum~= acAlienbumperweekVoApi:hasRechargeNum()then
        isNeedRefresh=true
    end
    if isNeedRefresh==true then
        self:refreshData()
    end
    self:updateAcTime()
end

function acAlienbumperweekDialog:updateAcTime()
    local acVo=acAlienbumperweekVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acAlienbumperweekDialog:refreshData()
    if self and self.totalrechargeNumLb then
        local rechargeNumStr = getlocal("activity_alienbumperweek_totalrecharge",{acAlienbumperweekVoApi:hasRechargeNum()})
        self.totalrechargeNumLb:setString(rechargeNumStr)
        if self and self.tenGem then
            self.tenGem:setPosition(self.totalrechargeNumLb:getPositionX()+self.totalrechargeNumLb:getContentSize().width+10, self.totalrechargeNumLb:getPositionY()-self.totalrechargeNumLb:getContentSize().height/2)
        end
    end
    
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end

function acAlienbumperweekDialog:update()
  local acVo = acAlienbumperweekVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end
end

function acAlienbumperweekDialog:dispose()
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
  CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
  
  self.acVo = nil
  self.totalrechargeNumLb=nil
  self.totalRechargeNum=0
  self.openDialogTs=0
  self.tenGem=nil
  self=nil
end





