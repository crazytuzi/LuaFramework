acChallengeranknewTab1={
   rewardBtnState = nil,
}

function acChallengeranknewTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil

    self.des = nil -- 活动说明信息
    self.desH = nil -- 活动说明信息的高度
    -- self.rewardMenu = nil

    return nc;

end

function acChallengeranknewTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    local acVo = acChallengeranknewVoApi:getAcVo()

    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 410 + 80 - 30))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 110-80))
    self.bgLayer:addChild(tvBg)
    self.des = {}
    self.desH = {}
    for i=1,4 do
      local tip
      if i == 1 then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        tip = getlocal("activity_timeLabel")..":"..timeStr
      elseif i == 2 then
        tip = getlocal("activity_challengeranknew_acContent",{acVo.maxRank})
      else
        tip = getlocal("activity_personalCheckPoint_rule"..(i - 2))
      end
      local desH,des = self:getDes(tip,24)
      -- if i == 1 then
      --   des:setColor(G_ColorYellowPro)
      -- elseif i == 5 then
      --   des:setColor(G_ColorRed)
      -- end
      table.insert(self.desH, desH)
      table.insert(self.des, des)
    end
    
    self:initTop3()

    self:initTableView()
    
    self:updateRewardBtn()


    return self.bgLayer
end
function acChallengeranknewTab1:initTop3()
    local rankItemSp=CCSprite:createWithSpriteFrameName("rankItem.jpg")
    rankItemSp:setAnchorPoint(ccp(0.5,1))
    rankItemSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(rankItemSp,3)
    -- rankItemSp:setScaleX((G_VisibleSizeWidth-50)/rankItemSp:getContentSize().width)
    -- local scaleY=140/rankItemSp:getContentSize().height
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
    local rankList=acChallengeranknewVoApi.rankList
    if rankList then
        local firstData=rankList[1]
        local secondData=rankList[2]
        local thirdData=rankList[3]
        if firstData and firstData[1] then
            self.top1Lb:setString(firstData[1])
        end
        if secondData and secondData[1] then
            self.top2Lb:setString(secondData[1])
        end
        if thirdData and thirdData[1] then
            self.top3Lb:setString(thirdData[1])
        end
    end
end
function acChallengeranknewTab1:getDes(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 100
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return tonumber(height), messageLabel
end

-- 更新领奖按钮显示
function acChallengeranknewTab1:updateRewardBtn()

  -- local state = 1
  -- if acChallengeranknewVoApi:hadReward() == true then
  --     state = 3
  -- elseif acChallengeranknewVoApi:canReward() == true then
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
  --     self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,20))
  --     self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
  --     self.bgLayer:addChild(self.rewardMenu) 
  -- end

  local rankList=acChallengeranknewVoApi.rankList
  if rankList then
      local firstData=rankList[1]
      local secondData=rankList[2]
      local thirdData=rankList[3]
      if firstData and firstData[1] and self.top1Lb then
          self.top1Lb:setString(firstData[1])
      end
      if secondData and secondData[1] and self.top2Lb then
          self.top2Lb:setString(secondData[1])
      end
      if thirdData and thirdData[1] and self.top3Lb then
          self.top3Lb:setString(thirdData[1])
      end
  end
end

function acChallengeranknewTab1:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-430+80-30),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,120-80))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

end

function acChallengeranknewTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 then
      if self.desH ~= nil and self.desH[1] ~= nil and self.desH[2] ~= nil then
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[1] + self.desH[2] + 50)
      else
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150)
      end
    elseif idx == 1 then
        -- if self.desH ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil and self.desH[5] ~= nil then
        --   local desH = self.desH[3] + self.desH[4] + self.desH[5]
        if self.desH ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil then
          local desH = self.desH[3] + self.desH[4]
          tmpSize = CCSizeMake(G_VisibleSizeWidth - 50, desH + 50 + 30)
        else
          tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150)
        end
    else
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150 * SizeOfTable(acChallengeranknewVoApi:getAcCfg()) + 40)
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local bgH
    if idx == 0 then
      if self.desH ~= nil and self.desH[1] ~= nil then
        bgH = self.desH[1] + self.desH[2] + 50
      else
        bgH = 150
      end
      local contentLabel = GetTTFLabel(getlocal("activityDescription"),28)
      contentLabel:setAnchorPoint(ccp(0,1))
      contentLabel:setColor(G_ColorYellowPro)
      contentLabel:setPosition(ccp(10,bgH - 10))
      cell:addChild(contentLabel)

      if self.des ~= nil then
        if self.des[1] ~= nil then
          local desLabel = self.des[1]
          desLabel:setAnchorPoint(ccp(0,0))
          desLabel:setPosition(ccp(35,10 + self.desH[2]))
          cell:addChild(desLabel)
        end
        if self.des[2] ~= nil then
          local desLabel2 = self.des[2]
          desLabel2:setAnchorPoint(ccp(0,0))
          desLabel2:setPosition(ccp(35,10))
          cell:addChild(desLabel2)
        end
      end
      
    elseif idx == 1 then
      -- if self.desH ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil and self.desH[5] ~= nil then
      --   bgH = self.desH[3] + self.desH[4] + self.desH[5] + 50
      if self.desH ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil then
        bgH = self.desH[3] + self.desH[4] + 50 + 30

        local contentLabel = GetTTFLabel(getlocal("checkPointDescription"),28)
        contentLabel:setAnchorPoint(ccp(0,1))
        contentLabel:setColor(G_ColorYellowPro)
        contentLabel:setPosition(ccp(10,bgH - 10))
        cell:addChild(contentLabel)
        

        if self.des ~= nil and self.des[1] ~= nil and self.des[2] ~= nil then
          local theH = bgH - 50
          -- for i=3,5 do
          for i=3,4 do
            local desLabel = self.des[i]
            theH = theH - self.desH[i]
            desLabel:setAnchorPoint(ccp(0,0))
            desLabel:setPosition(ccp(35,theH))
            cell:addChild(desLabel)
          end
        end

      end
      
    elseif idx == 2 then
      local acCfg = acChallengeranknewVoApi:getAcCfg()
      local rewardLen = SizeOfTable(acCfg)
      local singleH = 150
      bgH = singleH * rewardLen
      local titleH = 40
      
      local contentLabel = GetTTFLabel(getlocal("activity_awardLabel"),28)
      contentLabel:setAnchorPoint(ccp(0,1))
      contentLabel:setColor(G_ColorYellowPro)
      contentLabel:setPosition(ccp(10,bgH + titleH - 10))
      cell:addChild(contentLabel)

      local cfg
      local rank
      local award
      local h = 0
      for i=1,rewardLen do
          h = singleH * (rewardLen - i)
          cfg = acCfg[i]
          rank = cfg.rank
          award = cfg.award
          if SizeOfTable(rank) > 1 then
            local rankTwoLable = GetTTFLabel(getlocal("rankTwo",{rank[1],rank[2]})..":", 26)
            rankTwoLable:setAnchorPoint(ccp(0,1))
            rankTwoLable:setPosition(ccp(40, h + singleH - 10))
            cell:addChild(rankTwoLable)
          else
            local rankOneLable = GetTTFLabel(getlocal("rankOne",{rank[1]})..":", 26)
            rankOneLable:setAnchorPoint(ccp(0,1))
            rankOneLable:setPosition(ccp(40, h + singleH - 10))
            cell:addChild(rankOneLable)
          end

          self:addRewardIcons(FormatItem(award,true),cell, 60,h + (singleH - 40)/2)
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

function acChallengeranknewTab1:addRewardIcons(award,bg,initX,initY)
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
      
      local numLabel=GetTTFLabel("x"..v.num,25)
      numLabel:setAnchorPoint(ccp(1,0))
      numLabel:setPosition(icon:getContentSize().width-10,0)
      icon:addChild(numLabel,1)
      numLabel:setScaleX(1/iconScaleX)
      numLabel:setScaleY(1/iconScaleY)

      -- if tostring(v.name)~=getlocal("honor") then
        
      -- end
    end
  end
end


function acChallengeranknewTab1:getReward()
  local function getRewardSuccess(fn,data)
    self:getRewardSuccess(fn,data)
  end
  PlayEffect(audioCfg.mouseClick)
  if acChallengeranknewVoApi:canReward() == true then
      socketHelper:getPersonalCheckPointReward(acChallengeranknewVoApi:getSelfRank(),getRewardSuccess)
  end
end

function acChallengeranknewTab1:getRewardSuccess(fn,data)
  local ret,sData=base:checkServerData(data)
  if ret==true then        
    local reward = acChallengeranknewVoApi:getMyReward()
    local awardTab=FormatItem(reward,true)
    for k,v in pairs(awardTab) do
      G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
    end
    G_showRewardTip(awardTab, true)

    acChallengeranknewVoApi:afterGetReward()
    self:updateRewardBtn() -- 更新领奖按钮
  elseif sData.ret==-1975 then
    acChallengeranknewVoApi:update()
  end
end

function acChallengeranknewTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    -- self.rewardMenu =nil
    self.des = nil
    self.desH = nil -- 活动说明信息的高度
    self.tv=nil
    self.rewardBtnState = nil
    self = nil
end
