acFightRanknewTab1={
   rewardBtnState = nil,
}

function acFightRanknewTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.des = nil -- 活动说明信息
    self.desH = nil -- 活动说明信息的高度
    self.rewardMenu = nil

    return nc;

end

function acFightRanknewTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    local acVo=acFightRanknewVoApi:getAcVo()
    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 300 - 70))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 130-90))
    self.bgLayer:addChild(tvBg)
    self.desH,self.des = self:getDes(getlocal("activity_fightRanknew_des",{acVo.maxRank}),24)
    
    self:initTop3()
    self:initTableView()
    
    self:updateRewardBtn()


    return self.bgLayer
end
function acFightRanknewTab1:initTop3()
    local rankItemSp=CCSprite:createWithSpriteFrameName("rankItem.jpg")
    rankItemSp:setAnchorPoint(ccp(0.5,1))
    rankItemSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(rankItemSp,3)
    rankItemSp:setScaleX((G_VisibleSizeWidth-50)/rankItemSp:getContentSize().width)
    -- local scaleY=130/rankItemSp:getContentSize().height
    -- rankItemSp:setScaleY(scaleY)
    self.top1Lb=GetTTFLabel(getlocal("activity_fightRanknew_no_rank"),25)
    self.top1Lb:setPosition(ccp(rankItemSp:getContentSize().width/2+7,135))
    rankItemSp:addChild(self.top1Lb,3)
    -- self.top1Lb:setColor(G_ColorYellowPro)
    -- self.top1Lb:setScaleY(1/scaleY)
    self.top2Lb=GetTTFLabel(getlocal("activity_fightRanknew_no_rank"),25)
    self.top2Lb:setPosition(ccp(150,105))
    rankItemSp:addChild(self.top2Lb,3)
    -- self.top2Lb:setColor(G_ColorYellowPro)
    -- self.top2Lb:setScaleY(1/scaleY)
    self.top3Lb=GetTTFLabel(getlocal("activity_fightRanknew_no_rank"),25)
    self.top3Lb:setPosition(ccp(477,80))
    rankItemSp:addChild(self.top3Lb,3)
    -- self.top3Lb:setColor(G_ColorYellowPro)
    -- self.top3Lb:setScaleY(1/scaleY)
    local rankList=acFightRanknewVoApi.rankList
    if rankList then
        local firstData=rankList[1]
        local secondData=rankList[2]
        local thirdData=rankList[3]
        if firstData and firstData[2] then
            self.top1Lb:setString(firstData[2])
        end
        if secondData and secondData[2] then
            self.top2Lb:setString(firstData[2])
        end
        if thirdData and thirdData[2] then
            self.top3Lb:setString(firstData[2])
        end
    end
end
function acFightRanknewTab1:getDes(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 100
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

-- 更新领奖按钮显示
function acFightRanknewTab1:updateRewardBtn()
  -- print("刷新领奖按钮~~~~~~~~~~~~",acFightRanknewVoApi:hadReward(),acFightRanknewVoApi:canReward(),self.rewardBtnState, state)
  -- local state = 1
  -- if acFightRanknewVoApi:hadReward() == true then
  --     state = 3
  -- elseif acFightRanknewVoApi:canReward() == true then
  --     state = 2
  -- else
  --     state = 1
  -- end
  -- if self.rewardBtnState ~= state then
  --     if self.rewardMenu ~= nil then
  --       self.bgLayer:removeChild(self.rewardMenu,true)
  --       self.rewardMenu = nil
  --     end
  --     self.rewardBtnState = state
  --     local function hadReward(tag,object)
  --     end

  --     local function getReward(tag,object)
  --       if G_checkClickEnable()==false then
  --         do
  --           return
  --         end
  --       end
  --       --领取奖励
  --       self:getReward()
  --     end

  --     local rewardBtn
  --     if state == 3 then
  --         rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",hadReward,3,getlocal("activity_hadReward"),28)
  --         rewardBtn:setEnabled(false)
  --     else
  --       rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",getReward,3,getlocal("newGiftsReward"),28)
  --       if state == 2 then
  --         rewardBtn:setEnabled(true)
  --       elseif state == 1 then
  --         rewardBtn:setEnabled(false)
  --       end
  --     end
  --     rewardBtn:setAnchorPoint(ccp(0.5, 0))
  --     self.rewardMenu=CCMenu:createWithItem(rewardBtn)
  --     self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,40))
  --     self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
  --     self.bgLayer:addChild(self.rewardMenu) 
  -- end

  local rankList=acFightRanknewVoApi.rankList
  if rankList then
      local firstData=rankList[1]
      local secondData=rankList[2]
      local thirdData=rankList[3]
      if firstData and firstData[2] and self.top1Lb then
          self.top1Lb:setString(firstData[2])
      end
      if secondData and secondData[2] and self.top2Lb then
          self.top2Lb:setString(secondData[2])
      end
      if thirdData and thirdData[2] and self.top3Lb then
          self.top3Lb:setString(thirdData[2])
      end
  end
end

function acFightRanknewTab1:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-320-70),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,140-90))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

end

function acFightRanknewTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 12
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 or idx == 1 or idx == 2 or idx == 4  then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,60)
    elseif  idx == 6 then
      local desLabel = GetTTFLabelWrap(getlocal("activity_fightRank_typeDes"),26,CCSizeMake(G_VisibleSizeWidth - 70, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,desLabel:getContentSize().height+40)
    elseif idx == 3 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH)
    elseif idx == 5 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,200+40)
    else
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150)
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local bgH = 140 -- (100 - 10)
    local desLabel
    if idx == 0 then
      desLabel = GetTTFLabel(getlocal("activity_timeLabel"),26)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorYellowPro)
      desLabel:setPosition(ccp(10,10))
      cell:addChild(desLabel)
    elseif idx == 1 then
      local acVo = acFightRanknewVoApi:getAcVo()
      if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        desLabel=GetTTFLabel(timeStr,26)
        desLabel:setAnchorPoint(ccp(0,1))
        desLabel:setPosition(ccp(35,50))
        cell:addChild(desLabel)
        self.timeLb=desLabel
        G_updateActiveTime(acVo,self.timeLb)
      end
      
    elseif idx == 2 then
      desLabel = GetTTFLabel(getlocal("shuoming"),26)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorYellowPro)
      desLabel:setPosition(ccp(10,10))
      cell:addChild(desLabel)
    elseif idx == 3 then
      desLabel = self.des
      desLabel:setAnchorPoint(ccp(0,1))
      desLabel:setPosition(ccp(35,self.desH - 10))
      cell:addChild(desLabel)
    elseif idx == 4 then
      desLabel = GetTTFLabel(getlocal("activity_fightRank_rankReward"),26)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorYellowPro)
      desLabel:setPosition(ccp(10,10))
      cell:addChild(desLabel)
    elseif idx == 5 then
      local rewardTip, maxW = self:getRewardTip()
      local h = 190+40
      for k,v in pairs(rewardTip) do
        if v ~= nil then
          desLabel = GetTTFLabel(tostring(v[1]),24)
          if desLabel ~= nil then
            desLabel:setAnchorPoint(ccp(1,1))
            desLabel:setPosition(ccp(maxW + 35, h - (k - 1) * 30))
            cell:addChild(desLabel)
          end

          local rewardLabel = GetTTFLabel(tostring(v[2]),24)
          if rewardLabel ~= nil then
            rewardLabel:setAnchorPoint(ccp(0,1))
            rewardLabel:setPosition(ccp(maxW + 35, h - (k - 1) * 30))
            cell:addChild(rewardLabel)
          end
        end
      end
      
    elseif idx == 6 then
      desLabel = GetTTFLabelWrap(getlocal("activity_fightRank_typeDes"),26,CCSizeMake(G_VisibleSizeWidth - 70, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorYellowPro)
      desLabel:setPosition(ccp(10, 10))
      cell:addChild(desLabel)
    else

      local function cellClick(hd,fn,index)
      end

      local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
      backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 70, bgH))
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setPosition(ccp(10,10))
      cell:addChild(backSprie,1)
      
      local des
      local btnName
      if idx == 7 then
        des = getlocal("fight_fail_tip_3")
        btnName = getlocal("fight_fail_tip_13")
      elseif idx == 8 then
        des = getlocal("fight_fail_tip_1")
        btnName = getlocal("fight_fail_tip_11")
      elseif idx == 9 then
        des = getlocal("fight_fail_tip_2")
        btnName = getlocal("fight_fail_tip_12")
      elseif idx == 10 then
        des = getlocal("fight_fail_tip_4")
        btnName = getlocal("fight_fail_tip_14")
      elseif idx == 11 then
        des = getlocal("addVipDes")
        btnName = getlocal("addVip")
      end
      
      local desLabel=GetTTFLabelWrap(des,24,CCSizeMake(backSprie:getContentSize().width - 200, bgH - 20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      desLabel:setAnchorPoint(ccp(0,1))
      desLabel:setPosition(ccp(10, bgH - 10))
      -- desLabel:setColor(G_ColorYellowPro)
      backSprie:addChild(desLabel,1)
      

      local function goto(tag,object)
        if G_checkClickEnable()==false then
          do
            return
          end
        end
        if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
          local index
          if idx == 7 then
            index = 3
          elseif idx == 8 then
            index = 1
          elseif idx == 9 then
            index = 2
          elseif idx == 10 then
            index = 4
          elseif idx == 11 then
            index = 5
          end
          activityAndNoteDialog:gotoByTag(index, self.layerNum)
        end 
      end
      
      local gotoBtn
        local btnTextSize = 30
        if G_getCurChoseLanguage()=="pt" then
            btnTextSize = 25
        end
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
            btnTextSize = 20
        end
      if idx == 7 then
        gotoBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png", goto, 3, btnName, btnTextSize)
      else
        gotoBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",goto,idx,btnName,btnTextSize)
      end
      gotoBtn:setAnchorPoint(ccp(1,0.5))
      local gotoMenu=CCMenu:createWithItem(gotoBtn)
      gotoMenu:setPosition(ccp(G_VisibleSizeWidth - 80,75))
      gotoMenu:setTouchPriority(-(self.layerNum-1)*20-2)
      backSprie:addChild(gotoMenu)
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

function acFightRanknewTab1:getAwardStr(reward)
  local awardTab = reward
  local str ="     "
  if awardTab then
    for k,v in pairs(awardTab) do
      if k==SizeOfTable(awardTab) then
        str = str .. v.name .. " x" .. v.num
      else
        str = str .. v.name .. " x" .. v.num .. ",".."\n"
      end
    end
  end
  return str
end

function acFightRanknewTab1:getRewardTip()
  local tabStr = {}
  local cfg = acFightRanknewVoApi:getCfg()
  local len = SizeOfTable(cfg)
  local rank
  local award
  local rankTip
  local w = 0
  for i=1,len do
    rank = cfg[i].rank
    award = cfg[i].award
    local tip = {}
    if SizeOfTable(rank) > 1 then
      rankTip = getlocal("rankTwo",{rank[1],rank[2]})..":"
    else
      rankTip = getlocal("rankOne",{rank[1]})..":"
    end
    table.insert(tip,rankTip)
    local desLabel = GetTTFLabel(rankTip,24)
    if w < desLabel:getContentSize().width then
      w = desLabel:getContentSize().width
    end
    table.insert(tip,self:getAwardStr(FormatItem(award,true,true)))
    table.insert(tabStr,tip)
  end
  return tabStr, w
end


function acFightRanknewTab1:getReward()
  local function getRewardSuccess(fn,data)
    self:getRewardSuccess(fn,data)
  end
  PlayEffect(audioCfg.mouseClick)
  if acFightRanknewVoApi:canReward() == true then
      socketHelper:getFightReward(acFightRanknewVoApi.selfList[3], getRewardSuccess)
  end
end

function acFightRanknewTab1:getRewardSuccess(fn,data)
  local ret,sData=base:checkServerData(data)
  if ret==true then        
    local reward = acFightRanknewVoApi:getRewardByRank()
    local awardTab=FormatItem(reward,true,true)
    for k,v in pairs(awardTab) do
      G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
    end
    G_showRewardTip(awardTab, true)

    acFightRanknewVoApi:afterGetReward()
    self:updateRewardBtn() -- 更新领奖按钮
  end
end

function acFightRanknewTab1:tick()
    if self.timeLb then
        local acVo = acFightRanknewVoApi:getAcVo()
        if acVo then
            G_updateActiveTime(acVo,self.timeLb)
        end
    end
end

function acFightRanknewTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.rewardMenu =nil
    self.des = nil
    self.desH = nil -- 活动说明信息的高度
    selfrewardBtnState = nil
    self.tv=nil
    self.timeLb=nil
    self = nil
end
