acShareHappinessDialog=commonDialog:new()

function acShareHappinessDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.desTab = nil
    self.desLayer = nil
    self.giftTab = nil
    self.giftLayer = nil
    self.lastListNum = 0 -- 之前显示的礼包列表的个数
    return nc
end

function acShareHappinessDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
end
--设置对话框里的tableView
function acShareHappinessDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,100),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,10))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acShareHappinessDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 0

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
function acShareHappinessDialog:tabClick(idx)
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
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then

        if self.giftLayer==nil then
            self.giftTab=acShareHappinessTab2:new()
            self.giftLayer=self.giftTab:init(self.layerNum)
            self.bgLayer:addChild(self.giftLayer)
        else
            self.giftLayer:setVisible(true)
        end
        
        
        if self.desLayer ~= nil then
            self.desLayer:setVisible(false)
            self.desLayer:setPosition(ccp(10000,0))
        end
        
        self.giftLayer:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.giftLayer~=nil then
            self.giftLayer:setPosition(ccp(999333,0))
            self.giftLayer:setVisible(false)
        end
        
        if self.desLayer==nil then
            self.desTab=acShareHappinessTab1:new()
            self.desLayer=self.desTab:init(self.layerNum)
            self.bgLayer:addChild(self.desLayer)
        else
             self.desLayer:setVisible(true)
        end

        self.desLayer:setPosition(ccp(0,0))
    end

    -- 上下遮盖，防止tv超出界面被点击
    if self.selectedTabIndex==1 then  
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth ,180))
        self.topforbidSp:setPosition(0,G_VisibleSizeHeight - 180)
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,10))
    else
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,350))
        self.topforbidSp:setPosition(0,G_VisibleSizeHeight - 350)
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,140))
    end
end


function acShareHappinessDialog:tick()

  self:updateGiftListNum()

  if self.desTab ~= nil and self.selectedTabIndex == 0 then
    self.desTab:tick()
  end

  if self.giftTab ~= nil and self.selectedTabIndex == 1 then
    self.giftTab:tick()
  end
end


function acShareHappinessDialog:update()
  local acVo = acShareHappinessVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    else -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      if self.desTab ~= nil then
        self.desTab:updateRechargeBtn()
      end

      if self.giftTab ~= nil and self.giftTab.tv ~= nil then
        self.giftTab:update()
      end
    end
  end 
end


function acShareHappinessDialog:updateGiftListNum()
  local giftList = acShareHappinessVoApi:getGiftList()
  local giftListNum = 0
  if giftList ~= nil then
    giftListNum = SizeOfTable(giftList)
  end

  if self.lastListNum == giftListNum then
    do
      return
    end
  end

  self.lastListNum = giftListNum
  if giftListNum > 0 then
      self:setTipsVisibleByIdx(true,2,giftListNum)
  else
      self:setTipsVisibleByIdx(false,2)
  end

end

function acShareHappinessDialog:dispose()
    if self.desTab~=nil then
        self.desTab:dispose()
    end
    if self.giftTab~=nil then
        self.giftTab:dispose()
    end
    self.desTab = nil
    self.desLayer = nil
    self.giftTab = nil
    self.giftLayer = nil
    self.lastListNum = nil

    self.layerNum = nil
    self=nil
end