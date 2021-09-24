acXuyuanluDialog=commonDialog:new()

function acXuyuanluDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.goldTab = nil
    self.goldLayer = nil
    self.propTab = nil
    self.propLayer = nil
    self.isToday = nil

   -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acSingles.plist")

    return nc
end

function acXuyuanluDialog:resetTab()
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
function acXuyuanluDialog:initTableView()
  self.isToday = acXuyuanluVoApi:isToday()
  local function callback( ... )
    --return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callback)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

  --self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
  --self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-105))
  self:tabClick(0,false)
end

--点击tab页签 idx:索引
function acXuyuanluDialog:tabClick(idx)
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
    
    if idx==0 then
        if self.goldTab==nil then
            self.goldTab=acXuyuanluTab1:new()
            self.goldLayer=self.goldTab:init(self.layerNum)
            self.bgLayer:addChild(self.goldLayer)
        end
        if self.goldLayer then
            self.goldLayer:setPosition(ccp(0,0))
            self.goldLayer:setVisible(true)
        end
        if self.propLayer then
            self.propLayer:setPosition(ccp(999333,0))
            self.propLayer:setVisible(false)
        end
    elseif idx==1 then
        if self.propTab==nil then
            self.propTab=acXuyuanluTab2:new(self)
            self.propLayer=self.propTab:init(self.layerNum)
            self.bgLayer:addChild(self.propLayer)
        end
        if self.goldLayer then
            self.goldLayer:setPosition(ccp(999333,0))
            self.goldLayer:setVisible(false)
        end
        if self.propLayer then
            self.propLayer:setPosition(ccp(0,0))
            self.propLayer:setVisible(true)
        end
    end
end


function acXuyuanluDialog:tick()
  local istoday = acXuyuanluVoApi:isToday()
  if istoday ~= self.isToday then
    acXuyuanluVoApi:refreshPropData()
    self.isToday = istoday
    if self.propLayer then
      self.propTab:updateShow()
    end
    acXuyuanluVoApi:updateShow()
  end
  if self.goldLayer then
    self.goldTab:tick()
  end
  if self.propLayer then
    self.propTab:tick()
  end
end


function acXuyuanluDialog:update()
  local acVo = acXuyuanluVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
  	end
  end 
end

function acXuyuanluDialog:dispose()
    if self.goldLayer~=nil then
        self.goldTab:dispose()
    end
    if self.propLayer~=nil then
        self.propTab:dispose()
    end
    self.isToday=nil
    self.goldTab = nil
    self.goldLayer = nil
    self.propTab = nil
    self.propLayer = nil
    self=nil
end