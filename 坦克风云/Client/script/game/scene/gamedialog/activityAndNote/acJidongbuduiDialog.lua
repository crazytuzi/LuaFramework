acJidongbuduiDialog=commonDialog:new()

function acJidongbuduiDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.lotteryTab = nil
    self.lotteryLayer = nil
    self.exchangeTab = nil
    self.exchangeLayer = nil

    self.serverLeftNum = nil
    self.updateRecordListTime = nil

   -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acJidongbudui.plist")

    return nc
end

function acJidongbuduiDialog:resetTab()
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
    self.selectedTabIndex = 0
end
--设置对话框里的tableView
function acJidongbuduiDialog:initTableView()
  local function callback( ... )
    --return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callback)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

  --self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    --self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-105))

    local function getList(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
         PlayEffect(audioCfg.mouseClick)

         if sData ~= nil then
            if sData.data.jidongbudui then
              acJidongbuduiVoApi:setServerLeftTankNum(sData.data.jidongbudui.validCount)
              acJidongbuduiVoApi:setRecordList(sData.data.jidongbudui.place)
            end
            self.serverLeftNum = acJidongbuduiVoApi:getServerLeftTankNum()
            self.updateRecordListTime = acJidongbuduiVoApi:getUpdateListTime()
            self:update()
         end
      end
    end
    socketHelper:activityJidongbuduiServerLeftTank(getList)
  self:tabClick(0,false)
end

--点击tab页签 idx:索引
function acJidongbuduiDialog:tabClick(idx)
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

        if self.exchangeLayer==nil then
            self.exchangeTab=acJidongbuduiTab2:new()
            self.exchangeLayer=self.exchangeTab:init(self.layerNum)
            self.bgLayer:addChild(self.exchangeLayer)
        else
            self.exchangeLayer:setVisible(true)
        end
        
        
        if self.lotteryLayer ~= nil then
            self.lotteryLayer:removeFromParentAndCleanup(true)
           self.lotteryLayer = nil
        end
            
    elseif idx==0 then
            
        if self.exchangeLayer~=nil then
           self.exchangeLayer:removeFromParentAndCleanup(true)
           self.exchangeLayer = nil
        end
        
        if self.lotteryLayer==nil then
            self.lotteryTab=acJidongbuduiTab1:new()
            self.lotteryLayer=self.lotteryTab:init(self.layerNum)
            self.bgLayer:addChild(self.lotteryLayer)
        end
    end
end


function acJidongbuduiDialog:tick()
  if self.lotteryLayer then
    self.lotteryTab:tick()
  end
  local updateTime = acJidongbuduiVoApi:getUpdateListTime()
  local leftNum = acJidongbuduiVoApi:getServerLeftTankNum()
  if updateTime ~= self.updateRecordListTime then
    self.updateRecordListTime =updateTime
    if self.lotteryLayer then
       self.lotteryTab:updateList()
     end
  end
  if leftNum ~=self.serverLeftNum then
    self.serverLeftNum=leftNum
    if self.exchangeLayer then
      self.exchangeTab:update()
    end
  end
end
function acJidongbuduiDialog:fastTick( )
  if self.lotteryLayer then
    self.lotteryTab:fastTick()
  end
end

function acJidongbuduiDialog:update()
  local acVo = acJidongbuduiVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
  	end
    if self.exchangeLayer then
      self.exchangeTab:update()
    end
  end 
end

function acJidongbuduiDialog:dispose()
    if self.lotteryLayer~=nil then
        self.lotteryTab:dispose()
    end
    if self.exchangeLayer~=nil then
        self.exchangeTab:dispose()
    end
    self.lotteryTab = nil
    self.lotteryLayer = nil
    self.exchangeTab = nil
    self.exchangeLayer = nil
    self.serverLeftNum = nil
    self.recordList = nil
    self=nil
end