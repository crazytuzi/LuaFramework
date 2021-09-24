acAllianceLevelTab1={
   rewardBtnState = nil,
}

function acAllianceLevelTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil;
    self.bgLayer=nil;
   
    self.layerNum=nil;

    self.des = nil -- 活动说明信息
    self.desH = nil -- 活动说明信息的高度
    self.rewardMenu = nil

    return nc;

end

function acAllianceLevelTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 300))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 130))
    self.bgLayer:addChild(tvBg)
    self.desH = {}
    self.des = {}
    local tip,desH,des
    for i=1,2 do
      tip = getlocal("activity_allianceLevel_acContent"..i)
      desH,des = self:getDes(tip,24)
      table.insert(self.desH, desH)
      table.insert(self.des, des)
    end
    
    self:initTableView()
    
    self:updateRewardBtn()


    return self.bgLayer
end

function acAllianceLevelTab1:getDes(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 200
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

function acAllianceLevelTab1:getTotalDesH()
  local totalDesH = 0
  if self.desH ~= nil and type(self.desH) == "table" then
    for k,v in pairs(self.desH) do
      totalDesH = totalDesH + tonumber(v)
    end
  end
  return totalDesH
end


-- 更新领奖按钮显示
function acAllianceLevelTab1:updateRewardBtn()

  local state = 1
  if acAllianceLevelVoApi:hadReward() == true then
      state = 3
  elseif acAllianceLevelVoApi:canReward() == true then
      state = 2
  else
      state = 1
  end
  if self.rewardBtnState ~= state then
      if self.rewardMenu ~= nil then
        self.bgLayer:removeChild(self.rewardMenu,true)
        self.rewardMenu = nil
      end
      self.rewardBtnState = state
      local function hadReward(tag,object)
      end

      local function getReward(tag,object)
        if G_checkClickEnable()==false then
          do
            return
          end
        end
        --领取奖励
        self:getReward()
      end
      local rewardBtn
      if state == 3 then
          rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",hadReward,3,getlocal("activity_hadReward"),28)
          rewardBtn:setEnabled(false)
      else
        rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",getReward,3,getlocal("newGiftsReward"),28)
        if state == 2 then
          rewardBtn:setEnabled(true)
        elseif state == 1 then
          rewardBtn:setEnabled(false)
        end
      end
      rewardBtn:setAnchorPoint(ccp(0.5, 0))
      self.rewardMenu=CCMenu:createWithItem(rewardBtn)
      self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,40))
      self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
      self.bgLayer:addChild(self.rewardMenu) 
  end

end

function acAllianceLevelTab1:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-320),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,140))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

end

function acAllianceLevelTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,100)
    elseif idx == 1 then
      local totalDesH = self:getTotalDesH()
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,totalDesH + 50)
    else
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,200 * SizeOfTable(acAllianceLevelVoApi:getAcCfg()) + 60)
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local bgH
    if idx == 0 then
      bgH = 100
      local timeSize = 28
      local timeShowWidth = 0
      if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" then
          timeSize =24
          timeShowWidth =35
      end       
      local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
      timeTime:setAnchorPoint(ccp(0,0.5))
      timeTime:setColor(G_ColorGreen)
      timeTime:setPosition(ccp(10,bgH - 30))
      cell:addChild(timeTime)

      local rewardTimeStr = GetTTFLabel(getlocal("recRewardTime"),timeSize)
      rewardTimeStr:setAnchorPoint(ccp(0,0.5))
      rewardTimeStr:setColor(G_ColorYellowPro)
      rewardTimeStr:setPosition(ccp(10,bgH - 70))
      cell:addChild(rewardTimeStr)


      local acVo = acAllianceLevelVoApi:getAcVo()
      if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,timeSize-2)
        timeLabel:setAnchorPoint(ccp(0,0.5))
        timeLabel:setPosition(ccp(140+timeShowWidth,bgH - 30))
        cell:addChild(timeLabel)

        local timeStr2=activityVoApi:getActivityRewardTimeStr(acVo.acEt,60,86400)
        local timeLabel2=GetTTFLabel(timeStr2,timeSize-2)
        timeLabel2:setAnchorPoint(ccp(0,0.5))
        timeLabel2:setPosition(ccp(140+timeShowWidth,bgH - 70))
        cell:addChild(timeLabel2)       

        self.timeLb=timeLabel
        self.rewardTimeLb=timeLabel2
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb)
      end
      
      local function touch(tag,object)
        if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
          self:openInfo()
        end
      end

      local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
      menuItemDesc:setScaleX(0.9)
      menuItemDesc:setScaleY(0.9)
      local menuDesc=CCMenu:createWithItem(menuItemDesc)
      menuDesc:setTouchPriority(-(self.layerNum-1)*20-2)
      menuDesc:setPosition(ccp(G_VisibleSizeWidth - 100, bgH/2))
      cell:addChild(menuDesc)

    elseif idx == 1 then
      local totalDesH = self:getTotalDesH()
      bgH = totalDesH + 50
      local buildSp=CCSprite:createWithSpriteFrameName("gong_hui_building.png")
      buildSp:setScale(0.5)
      buildSp:setPosition(ccp(80, totalDesH/2))
      cell:addChild(buildSp)

      local contentLabel = GetTTFLabel(getlocal("activity_contentLabel"),28)
      contentLabel:setAnchorPoint(ccp(0,1))
      contentLabel:setColor(G_ColorYellowPro)
      contentLabel:setPosition(ccp(10,bgH - 10))
      cell:addChild(contentLabel)
      
      if self.des ~= nil and type(self.des) == "table" and self.desH ~= nil and type(self.desH) == "table" then
        local desH = 0
        for k,v in pairs(self.des) do
          desH = desH + tonumber(self.desH[k])
          local desLabel = v
          desLabel:setAnchorPoint(ccp(0,0))
          desLabel:setPosition(ccp(140 ,10 + totalDesH - desH))
          cell:addChild(desLabel)
        end
      end
      
    else
      local acCfg = acAllianceLevelVoApi:getAcCfg()
      local rewardLen = SizeOfTable(acCfg)
      local singleH = 200
      bgH = singleH * rewardLen
      local titleH = 50
      local bgAddH = 10
      local totalW = G_VisibleSizeWidth - 50
      local leftW = totalW * 0.3
      local rightW = totalW * 0.7
      
      local function cellClick(hd,fn,index)
      end

      local bg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(40, 40, 10, 10),cellClick)
      bg:setContentSize(CCSizeMake(totalW, bgH + bgAddH + titleH))
      bg:setAnchorPoint(ccp(0,0))
      bg:setPosition(ccp(0, 0))
      cell:addChild(bg)

      
      local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
      backSprie:setContentSize(CCSizeMake(totalW, titleH - 10))
      backSprie:setAnchorPoint(ccp(0.5,0.5))
      backSprie:setPosition(ccp(totalW/2, bgH + bgAddH + titleH/2))
      bg:addChild(backSprie)

      local goldLabel=GetTTFLabel(getlocal("rank"),28)
      goldLabel:setPosition(ccp(100 ,20))
      goldLabel:setColor(G_ColorGreen)
      backSprie:addChild(goldLabel)

      local rewardLabel=GetTTFLabel(getlocal("award"),28)
      rewardLabel:setPosition(ccp(totalW - 180,20))
      rewardLabel:setColor(G_ColorGreen)
      backSprie:addChild(rewardLabel) 

      

      local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
      verticalLine:setScaleX(bgH/verticalLine:getContentSize().width)
      verticalLine:setRotation(90)
      verticalLine:setPosition(ccp(leftW ,bgH/2 + bgAddH))
      bg:addChild(verticalLine,2)


      local cfg
      local rank
      local award
      local h = 0
      for i=1,rewardLen do
          h = singleH * (rewardLen - i) + bgAddH
          cfg = acCfg[i]
          rank = cfg.rank
          award = cfg.award
          if SizeOfTable(rank) > 1 then
            local rankTwoLable = GetTTFLabel(getlocal("rankTwo",{rank[1],rank[2]}), 26)
            rankTwoLable:setPosition(ccp(leftW/2, h + singleH/2))
            bg:addChild(rankTwoLable)
          else
            if rank[1] ~= nil and tonumber(rank[1]) > 0 and tonumber(rank[1])  < 4 then
              local rankSp
              if tonumber(rank[1])==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
              elseif tonumber(rank[1])==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
              elseif tonumber(rank[1])==3 then
                rankSp=CCSprite:createWithSpriteFrameName("top3.png")
              end
              rankSp:setPosition(ccp(leftW/2, h + singleH/2))
              bg:addChild(rankSp)
            else
              local rankOneLable = GetTTFLabel(getlocal("rankOne",{rank[1]}), 26)
              rankOneLable:setPosition(ccp(leftW/2, h + singleH/2))
              bg:addChild(rankOneLable)
            end
          end
          
          local role2 = GetTTFLabelWrap(getlocal("alliance_role2"), 26,CCSizeMake(125,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
          role2:setAnchorPoint(ccp(0,0.5))
          role2:setPosition(ccp(leftW + 10, h + singleH * 0.75))
          bg:addChild(role2)
          self:addRewardIcons(FormatItem(award[1],true),bg, leftW + 30 + role2:getContentSize().width,h + singleH * 0.75)

          local role0 = GetTTFLabelWrap(getlocal("alliance_role0"), 26,CCSizeMake(125,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
          role0:setAnchorPoint(ccp(0,0.5))
          role0:setPosition(ccp(leftW + 10, h + singleH * 0.25))
          bg:addChild(role0)
          self:addRewardIcons(FormatItem(award[2],true),bg,leftW + 30 + role0:getContentSize().width,h + singleH * 0.25)

          local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
          lineSprite:setScaleX(totalW/lineSprite:getContentSize().width)
          lineSprite:setPosition(ccp(totalW/2,h))
          bg:addChild(lineSprite)
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

function acAllianceLevelTab1:openInfo()
  local sd=smallDialog:new()
  local labelTab={"",getlocal("activity_allianceLevel_ruleTip"),"\n",getlocal("activity_allianceLevel_rule3"),"\n",getlocal("activity_allianceLevel_rule2"),"\n",getlocal("activity_allianceLevel_rule1")}
  local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,nil,getlocal("activity_baseLeveling_ruleTitle"))
  sceneGame:addChild(dialogLayer,self.layerNum+1)
end

function acAllianceLevelTab1:addRewardIcons(award,bg,initX,initY)
  local function showInfoHandler(hd,fn,idx)
    if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
      local item=award[idx]
      if item and item.name and item.pic and item.num and item.desc then
        propInfoDialog:create(sceneGame,item,self.layerNum+1)
      end
    end
  end
  
  if award ~= nil then
     for k,v in pairs(award) do
      local icon
      local pic=v.pic
      local iconScaleX=1
      local iconScaleY=1
      icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
      if icon:getContentSize().width>100 then
        iconScaleX=0.78*100/150
        iconScaleY=0.78*100/150
      else
        iconScaleX=0.78
        iconScaleY=0.78
      end
      icon:setScaleX(iconScaleX)
      icon:setScaleY(iconScaleY)
      icon:ignoreAnchorPointForPosition(false)
      icon:setAnchorPoint(ccp(0,0.5))
      icon:setPosition(ccp(initX +(k-1)*85 ,initY))
      icon:setIsSallow(false)
      icon:setTouchPriority(-(self.layerNum-1)*20-2)
      bg:addChild(icon,1)
      icon:setTag(k)

      if tostring(v.name)~=getlocal("honor") then
        local numLabel=GetTTFLabel("x"..v.num,25)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(icon:getContentSize().width-10,0)
        icon:addChild(numLabel,1)
        numLabel:setScaleX(1/iconScaleX)
        numLabel:setScaleY(1/iconScaleY)
      end
    end
  end
end


function acAllianceLevelTab1:getReward()
  local function getRewardSuccess(fn,data)
    self:getRewardSuccess(fn,data)
  end
  PlayEffect(audioCfg.mouseClick)
  if acAllianceLevelVoApi:canReward() == true then
      socketHelper:getAllianceLevelReward(acAllianceLevelVoApi:getSelfRank(), getRewardSuccess)
  end
end

function acAllianceLevelTab1:getRewardSuccess(fn,data)
  local ret,sData=base:checkServerData(data)
  if ret==true then        
    -- local reward = acAllianceLevelVoApi:getMyReward()
    if sData.data.reward then
      local reward = sData.data.reward
      local awardTab=FormatItem(reward,true)
      for k,v in pairs(awardTab) do
        G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
      end
      G_showRewardTip(awardTab, true)

      acAllianceLevelVoApi:afterGetReward()
      self:updateRewardBtn() -- 更新领奖按钮
    end
  elseif sData.ret==-1975 then
    acAllianceLevelVoApi:update()
  end
end

function acAllianceLevelTab1:tick()
    if self.timeLb and self.rewardTimeLb then
        local acVo = acAllianceLevelVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb)
    end
end

function acAllianceLevelTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.rewardMenu =nil
    self.des = nil
    self.desH = nil -- 活动说明信息的高度
    self.tv=nil
    self.rewardBtnState = nil
    self.timeLb=nil
    self.rewardTimeLb=nil
    self = nil
end
