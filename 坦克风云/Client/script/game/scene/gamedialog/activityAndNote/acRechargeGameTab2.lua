acRechargeGameTab2={

}

function acRechargeGameTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.lowFightLabel = nil
    
    return nc;
end
function acRechargeGameTab2:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.lowFightLabel = nil
end

function acRechargeGameTab2:init(layerNum)
    
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 250))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 30))
    self.bgLayer:addChild(tvBg)

    self:initTitles()
    self:initTableView()
    return self.bgLayer
end

function acRechargeGameTab2:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-270),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,40))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acRechargeGameTab2:eventHandler(handler,fn,idx,cel)
  local rankList = acRechargeGameVoApi:getRankList()
  local nums = SizeOfTable(rankList)
  local cellHeight = 76
  local tvHeight = G_VisibleSizeHeight-280
  if fn=="numberOfCellsInTableView" then
    nums = SizeOfTable(rankList)
    return nums+1
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize 
    if nums ==0 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth-50,tvHeight)
    else
      tmpSize = CCSizeMake(G_VisibleSizeWidth-50,cellHeight)
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local acVo = acRechargeGameVoApi:getAcVo()
    if acVo then
      local backSprie
      local capInSetNew=CCRect(20, 20, 10, 10)
      local capInSet = CCRect(40, 40, 10, 10)
      local function cellClick1(hd,fn,idx)
      end
      if idx==0 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
      elseif idx==1 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
      elseif idx==2 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
      elseif idx==3 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
      else
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
      end
      backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-70, 72))
      backSprie:ignoreAnchorPointForPosition(false)
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setIsSallow(false)
      backSprie:setPosition(ccp(10,0))
      backSprie:setTouchPriority(-42)
      cell:addChild(backSprie,1)
      local height=35
      if nums ==0 then
        backSprie:setPosition(ccp(10,tvHeight-(idx+1)*72))
        height = tvHeight-(idx+1)*72+35
      end
      local w = (G_VisibleSizeWidth-60) / 4
      local function getX(index)
        return 5 + w * index+ w/2
      end
      local rechargeListTb
      if idx == 0 then
        rechargeListTb = acRechargeGameVoApi:getSelfRank( )
      else
        rechargeListTb = rankList[idx]
      end
      if rechargeListTb ~= nil and SizeOfTable(rechargeListTb)>0 then--排名，1,服务器ID，2,角色名称 / 角色Uid，3,充值金额
        local rankStr=0
        local playerName="" --角色Uid
        local valueStr=0 -- 充值金额
        local nameStr="" -- 服务器
        if rechargeListTb then
          rankStr=idx
          playerName = rechargeListTb[1]
          valueStr=tonumber(rechargeListTb[3])
          nameStr =rechargeListTb[2]
        end
        if idx ==0 and rankList and nums>0 then
          if acRechargeGameVoApi:getShowMod() ==1 then
            for k,v in pairs(rankList) do
              if tonumber(v[1]) ==tonumber(playerName) then
                rankStr =k
              end
            end
          else
            for k,v in pairs(rankList) do
              if v[1] ==playerName then
                rankStr =k
              end
            end
          end
        end

        local rankSp
        if tonumber(rankStr)==1 then
          rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        elseif tonumber(rankStr)==2 then
          rankSp=CCSprite:createWithSpriteFrameName("top2.png")
        elseif tonumber(rankStr)==3 then
          rankSp=CCSprite:createWithSpriteFrameName("top3.png")
        elseif tonumber(rankStr) == 0 then
          local lastRank = acRechargeGameVoApi:getRanklimit( )
          rankStr = getlocal("activity_fbReward_rankLow",{lastRank})
        end
        if rankSp then
          rankSp:setAnchorPoint(ccp(0.5,0.5))
          rankSp:setPosition(ccp(getX(0),height))
          cell:addChild(rankSp,3)
        else
          local rankLabel=GetTTFLabel(rankStr,25)
          rankLabel:setAnchorPoint(ccp(0.5,0.5))
          rankLabel:setPosition(getX(0),height)
          cell:addChild(rankLabel,2)
        end
      
        local playerNameLabel=GetTTFLabelWrap(playerName,25,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        playerNameLabel:setAnchorPoint(ccp(0.5,0.5))
        playerNameLabel:setPosition(getX(2),height)
        cell:addChild(playerNameLabel,2)
        
        local valueLabel=GetTTFLabel(FormatNumber(valueStr),25)
        valueLabel:setAnchorPoint(ccp(0.5,0.5))
        valueLabel:setPosition(getX(3),height)
        cell:addChild(valueLabel,2)

        local nameLabel=GetTTFLabelWrap(nameStr,25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setPosition(getX(1),height)
        cell:addChild(nameLabel,2)  
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

--用户处理特殊需求,没有可以不写此方法
function acRechargeGameTab2:initTitles()

   local w = (G_VisibleSizeWidth - 40) / 4
   local function getX(index)
     return 20 + w * index+ w/2
   end
   --排名，服务器ID，角色名称 / 角色Uid，充值金额
    local height=G_VisibleSizeHeight-200
    local lbSize=22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
      lbSize =25
    end
    local widthSpace=80
    local color=G_ColorGreen
    local rankLabel=GetTTFLabel(getlocal("alliance_scene_rank_title"),lbSize)
    rankLabel:setPosition(getX(0),height)
    self.bgLayer:addChild(rankLabel,1)
    rankLabel:setColor(color)
  
    local playerNameLabel=GetTTFLabel(getlocal("playerId"),lbSize)
    playerNameLabel:setPosition(getX(2),height)
    self.bgLayer:addChild(playerNameLabel,1)
    playerNameLabel:setColor(color)
    
    local serverId=GetTTFLabel(getlocal("serverwar_server_name"),lbSize)
    serverId:setPosition(getX(1),height)
    self.bgLayer:addChild(serverId,1)
    serverId:setColor(color)


    local rechargeGold=GetTTFLabel(getlocal("rechargeGold"),lbSize)
    rechargeGold:setPosition(getX(3),height)
    self.bgLayer:addChild(rechargeGold,1)
    rechargeGold:setColor(color)

end

function acRechargeGameTab2:refData( )
   if self.tv then
     -- local recordPoint=self.tv:getRecordPoint()
     self.tv:reloadData()
     -- self.tv:recoverToRecordPoint(recordPoint)
   end
end

function acRechargeGameTab2:dispose()
  self.bgLayer:removeFromParentAndCleanup(true)
  self.bgLayer=nil
  self.lowFightLabel = nil
  self.tv=nil;
  self.layerNum=nil
  self = nil 
end
