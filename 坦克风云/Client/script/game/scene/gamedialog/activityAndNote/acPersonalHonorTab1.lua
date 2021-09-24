acPersonalHonorTab1={
   rewardBtnState = nil,
}

function acPersonalHonorTab1:new()
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

function acPersonalHonorTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 410))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 130))
    self.bgLayer:addChild(tvBg)
    self.des = {}
    self.desH = {}
    for i=1,5 do
      local tip
      if i == 1 then
        tip = getlocal("activity_personalHonor_acContent")
      else
        tip = getlocal("activity_personalHonor_rule"..(i - 1))
      end
      local desH,des = self:getDes(tip,24)
      if i == 5 then
        des:setColor(G_ColorRed)
      end
      table.insert(self.desH, desH)
      table.insert(self.des, des)
    end
    
    self:initTableView()
    
    self:updateRewardBtn()


    return self.bgLayer
end

function acPersonalHonorTab1:getDes(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 100
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return tonumber(height), messageLabel
end

-- 更新领奖按钮显示
function acPersonalHonorTab1:updateRewardBtn()

  local state = 1
  if acPersonalHonorVoApi:hadReward() == true then
      state = 3
  elseif acPersonalHonorVoApi:canReward() == true then
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

function acPersonalHonorTab1:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-430),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,140))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

end

function acPersonalHonorTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 then
      if self.desH ~= nil and self.desH[1] ~= nil then
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[1] + 50)
      else
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150)
      end
    elseif idx == 1 then
        if self.desH ~= nil and self.desH[2] ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil and self.desH[5] ~= nil then
          local desH = self.desH[2] + self.desH[3] + self.desH[4]+ self.desH[5]
          tmpSize = CCSizeMake(G_VisibleSizeWidth - 50, desH + 50)
        else
          tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150)
        end
    else
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150 * SizeOfTable(acPersonalHonorVoApi:getAcCfg()) + 40)
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local bgH
    if idx == 0 then
      if self.desH ~= nil and self.desH[1] ~= nil then
        bgH = self.desH[1] + 50
      else
        bgH = 150
      end
      local contentLabel = GetTTFLabel(getlocal("activityDescription"),28)
      contentLabel:setAnchorPoint(ccp(0,1))
      contentLabel:setColor(G_ColorYellowPro)
      contentLabel:setPosition(ccp(10,bgH - 10))
      cell:addChild(contentLabel)

      if self.des ~= nil and self.des[1] ~= nil then
        local desLabel = self.des[1]
        desLabel:setAnchorPoint(ccp(0,0))
        desLabel:setPosition(ccp(35,10))
        cell:addChild(desLabel)
      end
      
    elseif idx == 1 then
      if self.desH ~= nil and self.desH[2] ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil and self.desH[5] ~= nil then
        bgH = self.desH[2] + self.desH[3] + self.desH[4] + self.desH[5] + 50

        local contentLabel = GetTTFLabel(getlocal("honorDescription"),28)
        contentLabel:setAnchorPoint(ccp(0,1))
        contentLabel:setColor(G_ColorYellowPro)
        contentLabel:setPosition(ccp(10,bgH - 10))
        cell:addChild(contentLabel)
        

        if self.des ~= nil and self.des[1] ~= nil then
          local theH = bgH - 50
          for i=2,5 do
            local desLabel = self.des[i]
            theH = theH - self.desH[i]
            desLabel:setAnchorPoint(ccp(0,0))
            desLabel:setPosition(ccp(35,theH))
            cell:addChild(desLabel)
          end
        end

      end
      
    elseif idx == 2 then
      local acCfg = acPersonalHonorVoApi:getAcCfg()
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

function acPersonalHonorTab1:addRewardIcons(award,bg,initX,initY)
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


function acPersonalHonorTab1:getReward()
  local function getRewardSuccess(fn,data)
    self:getRewardSuccess(fn,data)
  end
  PlayEffect(audioCfg.mouseClick)
  if acPersonalHonorVoApi:canReward() == true then
      socketHelper:getPersonalHonorReward(acPersonalHonorVoApi:getSelfRank(),getRewardSuccess)
  end
end

function acPersonalHonorTab1:getRewardSuccess(fn,data)
  local ret,sData=base:checkServerData(data)
  if ret==true then        
    local reward = acPersonalHonorVoApi:getMyReward()
    local awardTab=FormatItem(reward,true)
    for k,v in pairs(awardTab) do
      G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
    end
    G_showRewardTip(awardTab, true)

    acPersonalHonorVoApi:afterGetReward()
    self:updateRewardBtn() -- 更新领奖按钮
  elseif sData.ret==-1975 then
    acPersonalHonorVoApi:update()
  end
end

function acPersonalHonorTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.rewardMenu =nil
    self.des = nil
    self.desH = nil -- 活动说明信息的高度
    self.tv=nil
    self.rewardBtnState = nil
    self = nil
end
