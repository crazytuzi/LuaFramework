acMayDayDialog = commonDialog:new()

function acMayDayDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.actionTab = nil
	self.actionLayer = nil
	self.shopTab = nil
	self.shopLayer = nil
	self.version =nil

	return nc
end

function acMayDayDialog:resetTab( )
	
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
function acMayDayDialog:initTableView()
  local function callback( ... )
    --return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callback)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

  --self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    --self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-105))
  self:tabClick(0,false)
end


function acMayDayDialog:tabClick(idx )
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

        if self.shopLayer==nil then
            self.shopTab=acMayDayTab2:new()
            self.shopLayer=self.shopTab:init(self.layerNum)
            self.bgLayer:addChild(self.shopLayer)
        else
            self.shopLayer:setVisible(true)
            self.shopLayer:updateTokenNum()

        end
        
        if self.actionLayer ~= nil then
            self.actionLayer:removeFromParentAndCleanup(true)
           self.actionLayer = nil
        end
            
    elseif idx==0 then
            
        if self.shopLayer~=nil then
           self.shopLayer:removeFromParentAndCleanup(true)
           self.shopLayer = nil
        end
        
        if self.actionLayer==nil then
            self.actionTab=acMayDayTab1:new()
            self.actionLayer=self.actionTab:init(self.layerNum)
            self.bgLayer:addChild(self.actionLayer)
        end
        -- if self.actionLayer then
        --   self.actionTab:doUserHandler()
        -- end
    end
end

function acMayDayDialog:tick()

  if self.selectedTabIndex==0 and self.actionLayer then
    --print("dadadadaad")
    self.actionTab:tick()
  end


  local acVo = acMayDayVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end 

  -- if self.shopLayer then
  -- 	self.shopTab:tick()
  -- end
end
function acMayDayDialog:fastTick()
	if self.actionLayer then
		self.actionTab:fastTick()
	end
end

function acMayDayDialog:dispose()
    if self.actionLayer~=nil then
        self.actionTab:dispose()
    end
    -- if self.shopLayer~=nil then
    --     self.shopTab:dispose()
    -- end
    self.actionTab = nil
    self.actionLayer = nil
    -- self.shopTab = nil
    -- self.shopLayer = nil
    self=nil
end