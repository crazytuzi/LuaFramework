acPersonalCheckPointTab2={

}

function acPersonalCheckPointTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end

function acPersonalCheckPointTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 340))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 30))
    self.bgLayer:addChild(tvBg)

    self:initTitles()
    self:initTableView()
    return self.bgLayer
end



function acPersonalCheckPointTab2:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-360),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,40))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acPersonalCheckPointTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(acPersonalCheckPointVoApi.rankList) + 1
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,76)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    

    local acVo = acPersonalCheckPointVoApi:getAcVo()
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
      local height=40
      local w = (G_VisibleSizeWidth-60) / 4
      local function getX(index)
        return 5 + w * index+ w/2
      end
      local singleVo
      if idx == 0 then
        singleVo = acPersonalCheckPointVoApi.selfList
      else
        singleVo = acPersonalCheckPointVoApi.rankList[idx]
      end

      if singleVo ~= nil then
        local rankStr=0 -- 排名
        local name="" --名称
        local levStr="" -- 等级
        local valueStr=0 -- 关卡
        if singleVo then
          rankStr=singleVo[3]
          name = singleVo[1]
          levStr=singleVo[2]
          if tonumber(singleVo[4]) > 0 then
            valueStr = singleVo[4]
          end
          local uid = singleVo[5]
          if tonumber(uid)==tonumber(playerVoApi:getUid()) then
            name=playerVoApi:getPlayerName()
          end
        end
        

        local rankSp
        if tonumber(rankStr)==1 then
          rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        elseif tonumber(rankStr)==2 then
          rankSp=CCSprite:createWithSpriteFrameName("top2.png")
        elseif tonumber(rankStr)==3 then
          rankSp=CCSprite:createWithSpriteFrameName("top3.png")
        elseif tonumber(rankStr) > 10 or tonumber(rankStr) == 0 then
          rankStr = getlocal("activity_fbReward_rankLow",{10})
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
      
        local nameLabel=GetTTFLabel(name,25)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setPosition(getX(1),height)
        cell:addChild(nameLabel,2)
        
        local levLabel=GetTTFLabel(levStr,25)
        levLabel:setAnchorPoint(ccp(0.5,0.5))
        levLabel:setPosition(getX(2),height)
        cell:addChild(levLabel,2)

        local valueLabel=GetTTFLabel(FormatNumber(valueStr),25)
        valueLabel:setAnchorPoint(ccp(1,0.5))
        valueLabel:setPosition(getX(3)-5,height)
        cell:addChild(valueLabel,2) 

        local starIcon = CCSprite:createWithSpriteFrameName("StarIcon.png")
        starIcon:setAnchorPoint(ccp(0,0.5))
        starIcon:setPosition(ccp(getX(3)+5,height))
        cell:addChild(starIcon,2)  
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


function acPersonalCheckPointTab2:tick()

end


--用户处理特殊需求,没有可以不写此方法
function acPersonalCheckPointTab2:initTitles()

   local w = (G_VisibleSizeWidth - 40) / 4
   local function getX(index)
     return 20 + w * index+ w/2
   end

   local height=G_VisibleSizeHeight-290
    local lbSize=22
    local widthSpace=80
    local color=G_ColorGreen
    local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),lbSize)
    rankLabel:setPosition(getX(0),height)
    self.bgLayer:addChild(rankLabel,1)
    rankLabel:setColor(color)
  
    local allianceNameLabel=GetTTFLabel(getlocal("RankScene_name"),lbSize)
    allianceNameLabel:setPosition(getX(1),height)
    self.bgLayer:addChild(allianceNameLabel,1)
    allianceNameLabel:setColor(color)
    
    local levelLabel=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLabel:setPosition(getX(2),height)
    self.bgLayer:addChild(levelLabel,1)
    levelLabel:setColor(color)


    local fightLabel=GetTTFLabel(getlocal("RankScene_star_num"),lbSize)
    fightLabel:setPosition(getX(3),height)
    self.bgLayer:addChild(fightLabel,1)
    fightLabel:setColor(color)

end

function acPersonalCheckPointTab2:dispose()
  self.bgLayer:removeFromParentAndCleanup(true)
  self.bgLayer=nil
  self.tv=nil
  self.layerNum=nil
  self = nil 
end
