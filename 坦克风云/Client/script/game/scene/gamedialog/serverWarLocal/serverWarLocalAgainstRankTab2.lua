serverWarLocalAgainstRankTab2 = {}

function serverWarLocalAgainstRankTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=nil
    self.cellheight1=70
    return nc
end

function serverWarLocalAgainstRankTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self:initLayer()
    return self.bgLayer
end

function serverWarLocalAgainstRankTab2:initLayer()
    local hi=G_VisibleSize.height-305+120-10
    local tlbSize=26
    local tLb1 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb1:setAnchorPoint(ccp(0,0.5));
    tLb1:setPosition(ccp(70,hi));
    self.bgLayer:addChild(tLb1,2);
    tLb1:setColor(G_ColorGreen)

    local tLb2 = GetTTFLabel(getlocal("alliance_scene_button_info_name"),tlbSize);
    tLb2:setAnchorPoint(ccp(0,0.5));
    tLb2:setPosition(ccp(210,hi));
    self.bgLayer:addChild(tLb2,2);
    tLb2:setColor(G_ColorGreen)

    local tLb3 = GetTTFLabel(getlocal("city_info_power"),tlbSize);
    tLb3:setAnchorPoint(ccp(0,0.5));
    tLb3:setPosition(ccp(375,hi));
    self.bgLayer:addChild(tLb3,2);
    tLb3:setColor(G_ColorGreen)

    local tLb4 = GetTTFLabel(getlocal("serverwar_point"),tlbSize);
    tLb4:setAnchorPoint(ccp(0.5,0.5));
    tLb4:setPosition(ccp(540,hi));
    self.bgLayer:addChild(tLb4,2);
    tLb4:setColor(G_ColorGreen)

    local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () do return end end)
    backSprie2:setContentSize(CCSizeMake(590,self.bgLayer:getContentSize().height-90-40-120-100))
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2,30+100)
    self.bgLayer:addChild(backSprie2)

    local desLb = GetTTFLabelWrap(getlocal("serverWarLocal_armyRank_des"),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(CCPointMake(40,80))
    desLb:setColor(G_ColorRed)
    self.bgLayer:addChild(desLb)

    local function touchInfoItem(idx)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end

      local tabStr={getlocal("serverWarLocal_help_content8")}
      require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
      tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    local infoItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touchInfoItem,11,nil,nil)
    local infoMenu=CCMenu:createWithItem(infoItem)
    infoMenu:setPosition(ccp(560,80))
    infoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoMenu)

    self.noRankLb=GetTTFLabelWrap(getlocal("serverWarLocal_noData"),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setColor(G_ColorYellowPro)
    self.noRankLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(self.noRankLb)
    self.noRankLb:setVisible(false)

     self.rankList=self:getRankList()

    if SizeOfTable(self.rankList)==0 then
      self.noRankLb:setVisible(true)
    elseif tonumber(self.rankList[1][5])==0 then
      self.noRankLb:setVisible(true)
    else
      self:initTableView()
    end

     


end

function serverWarLocalAgainstRankTab2:initTableView()
   
    local function callBack1(...)
        return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-380+120-15-100),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40+100))
    self.bgLayer:addChild(self.tv,3)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function serverWarLocalAgainstRankTab2:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
            
       local num=SizeOfTable(self.rankList)
       return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(590,self.cellheight1)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()

       local cellWidth=590
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
       end
       
      local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
      lineSp:setContentSize(CCSizeMake(cellWidth-2,2))
      lineSp:setRotation(180)
      lineSp:setPosition(cellWidth/2,lineSp:getContentSize().height/2)
      cell:addChild(lineSp,1)

       local tlbSize=25
       if idx<3 then
        local rankSp =CCSprite:createWithSpriteFrameName("top" .. idx+1 .. ".png")
        rankSp:setPosition(ccp(60,self.cellheight1/2));
        cell:addChild(rankSp,2)
       else
        local tLb1 = GetTTFLabel(idx+1,tlbSize);
        tLb1:setPosition(ccp(65,self.cellheight1/2+5));
        cell:addChild(tLb1,2);
       end

       local fid = tonumber(Split(self.rankList[idx+1][1],"-")[1])
       local nameStr = GetServerNameByID(fid) .. "-" .. self.rankList[idx+1][2]

       local tLb2 = GetTTFLabelWrap(nameStr,tlbSize,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
       tLb2:setPosition(ccp(210,self.cellheight1/2+5));
       cell:addChild(tLb2,2);

       local fightNum=FormatNumber(tonumber(self.rankList[idx+1][4] or 0))
       local tLb3 = GetTTFLabel(fightNum,tlbSize);
       tLb3:setPosition(ccp(370,self.cellheight1/2+5));
       cell:addChild(tLb3,2);

       local pointNum=FormatNumber(self.rankList[idx+1][5])
       local tLb4 = GetTTFLabel(pointNum,tlbSize);
       tLb4:setPosition(ccp(510,self.cellheight1/2+5));
       cell:addChild(tLb4,2);


       return cell;

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   elseif fn=="ccScrollEnable" then
            return 1
    end

end

function serverWarLocalAgainstRankTab2:getRankList()
    local rankList=serverWarLocalVoApi:getAllianceRankList()
    return rankList
end

function serverWarLocalAgainstRankTab2:tick()
end


function serverWarLocalAgainstRankTab2:refresh()
end

function serverWarLocalAgainstRankTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.tv=nil
    self.cellheight1=nil
end

