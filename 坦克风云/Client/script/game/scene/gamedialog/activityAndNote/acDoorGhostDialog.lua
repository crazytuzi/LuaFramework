acDoorGhostDialog=commonDialog:new()

function acDoorGhostDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.doorTab = nil
    self.doorLayer = nil
    self.rewardTab = nil
    self.rewardLayer = nil

    self.getTimes = 0

    --CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acDoorGhost.plist")

    return nc
end

function acDoorGhostDialog:resetTab()
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
function acDoorGhostDialog:initTableView()
    
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    --self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)

    local function getData(fn,data)
       local ret,sData=base:checkServerData(data)
         if ret==true then
          acDoorGhostVoApi:updateData(sData.data.doorGhost)
          self:tabClick(0)
         end
    end
    socketHelper:activityDoorGhostGetReward(getData)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acDoorGhostDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 4

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize =CCSizeMake(400,500)
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
function acDoorGhostDialog:tabClick(idx)
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
            -- self:doUserHandler()            
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then

        if self.rewardLayer==nil then
            self.rewardTab=acDoorGhostTab2:new()
            self.rewardLayer=self.rewardTab:init(self.layerNum)
            self.bgLayer:addChild(self.rewardLayer,1)
        else
            self.rewardTab:updateView()
            self.rewardLayer:setVisible(true)
        end
        
        
        if self.doorLayer ~= nil then
            self.doorLayer:setVisible(false)
            self.doorLayer:setPosition(ccp(10000,0))
        end
        
        self.rewardLayer:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.rewardLayer~=nil then
            self.rewardLayer:setPosition(ccp(999333,0))
            self.rewardLayer:setVisible(false)
        end
        
        if self.doorLayer==nil then
            self.doorTab=acDoorGhostTab1:new()
            self.doorLayer=self.doorTab:init(self.layerNum)
            self.bgLayer:addChild(self.doorLayer,1)
        else
             self.doorLayer:setVisible(true)
        end

        self.doorLayer:setPosition(ccp(0,0))
    end
end


function acDoorGhostDialog:tick()
  if self.doorTab then
    self.doorTab:tick()
  end
end


function acDoorGhostDialog:update()
  local acVo = acDoorGhostVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end 
end

function acDoorGhostDialog:dispose()
    if self.doorTab~=nil then
        self.doorTab:dispose()
    end
    if self.rewardTab~=nil then
        self.rewardTab:dispose()
    end
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acDoorGhost.plist")
    self.doorTab = nil
    self.doorLayer = nil
    self.rewardTab = nil
    self.rewardLayer = nil
    self.layerNum = nil
    self=nil
end