acPersonalCheckPointDialog=commonDialog:new()

function acPersonalCheckPointDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.desTab = nil
    self.desLayer = nil
    self.rankTab = nil
    self.rankLayer = nil

    self.getTimes = 0

    return nc
end

function acPersonalCheckPointDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-190)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-190)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
end
--设置对话框里的tableView
function acPersonalCheckPointDialog:initTableView()
    
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 275))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))

    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-305),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acPersonalCheckPointDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 4

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize =CCSizeMake(400,180)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end



--点击tab页签 idx:索引
function acPersonalCheckPointDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
      do
          return
      end
    end
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:doUserHandler()            
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then

        if self.rankLayer==nil then
            self.rankTab=acPersonalCheckPointTab2:new()
            self.rankLayer=self.rankTab:init(self.layerNum)
            self.bgLayer:addChild(self.rankLayer)
        else
            self.rankLayer:setVisible(true)
        end
        
        
        if self.desLayer ~= nil then
            self.desLayer:setVisible(false)
            self.desLayer:setPosition(ccp(10000,0))
        end
        
        self.rankLayer:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.rankLayer~=nil then
            self.rankLayer:setPosition(ccp(999333,0))
            self.rankLayer:setVisible(false)
        end
        
        if self.desLayer==nil then
            self.desTab=acPersonalCheckPointTab1:new()
            self.desLayer=self.desTab:init(self.layerNum)
            self.bgLayer:addChild(self.desLayer)
        else
             self.desLayer:setVisible(true)
        end

        self.desLayer:setPosition(ccp(0,0))
    end
end

function acPersonalCheckPointDialog:doUserHandler()
  local function cellClick(hd,fn,index)
  end
  
  local w = G_VisibleSizeWidth - 20 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 100))
  backSprie:setAnchorPoint(ccp(0,0))
  backSprie:setPosition(ccp(10, G_VisibleSizeHeight - 190))
  self.bgLayer:addChild(backSprie)
  
  local acVo = acPersonalCheckPointVoApi:getAcVo()
  if self.selectedTabIndex == 1 and base.serverTime > acVo.acEt then
    local finalRankLabel = GetTTFLabel(getlocal("finalRank"),35)
    finalRankLabel:setAnchorPoint(ccp(0.5,0.5))
    finalRankLabel:setPosition(getCenterPoint(backSprie))
    finalRankLabel:setColor(G_ColorYellowPro)
    backSprie:addChild(finalRankLabel)
  else
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 90))
    backSprie:addChild(acLabel)

    
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,28)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 50))
    backSprie:addChild(messageLabel)
    self.timeLb=messageLabel
    G_updateActiveTime(acVo,self.timeLb)
  end
  
end

function acPersonalCheckPointDialog:tick()
  if acPersonalCheckPointVoApi:getEndTime() < base.serverTime then
    do 
      return
    end
  end
  local oldStarNum = acPersonalCheckPointVoApi:getSelfStarNum()
  local newStarNum = checkPointVoApi:getStarNum()
  if (acPersonalCheckPointVoApi.lastSt + 300 < base.serverTime or oldStarNum ~= newStarNum) and self.getTimes <= 2 then
      local function getList(fn,data)
        local ret,sData=base:checkServerData(data)

        if ret==true then
           PlayEffect(audioCfg.mouseClick)

           if sData ~= nil then
              acPersonalCheckPointVoApi:updateRankList(sData)
              acPersonalCheckPointVoApi:setLastSt()
              self.getTimes = 0
              self:update()
           end
          
        end
      end
      self.getTimes = self.getTimes + 1
      if self.getTimes > 2 then
        self.getTimes = 0
        acPersonalCheckPointVoApi:setLastSt()
      end
      socketHelper:getPersonalCheckPointList(getList)
  end
  if self.timeLb then
      local acVo = acPersonalCheckPointVoApi:getAcVo()
      if acVo then
          G_updateActiveTime(acVo,self.timeLb)
      end
  end
end


function acPersonalCheckPointDialog:update()
  local acVo = acPersonalCheckPointVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    else -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      if self.desTab ~= nil then
         self.desTab:updateRewardBtn() -- 更新领奖按钮
      end

      if self.rankTab ~= nil and self.rankTab.tv ~= nil then
         self.rankTab.tv:reloadData()
      end
    end
  end 
end

function acPersonalCheckPointDialog:dispose()
    if self.desTab~=nil then
        self.desTab:dispose()
    end
    if self.rankTab~=nil then
        self.rankTab:dispose()
    end
    self.desTab = nil
    self.desLayer = nil
    self.rankTab = nil
    self.rankLayer = nil
    self.layerNum = nil
    self.getTimes = 0
    self.timeLb = nil
    self=nil
end