energyCrystalDialog = commonDialog:new()

function energyCrystalDialog:new(defaultTab,defaultWeaponID)
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  nc.acTab1=nil
  nc.acTab2=nil
  nc.layerTab1=nil
  nc.layerTab2=nil
  nc.defaultTab=defaultTab
  nc.defaultWeaponID=defaultWeaponID

  return nc
end

function energyCrystalDialog:resetTab()
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
    if(self.defaultTab)then
      self:tabClick(self.defaultTab - 1)
    end
end

function energyCrystalDialog:initTableView()
    

    local function callback2( ... )
        return self:eventHandler(...)
    end

    local hd= LuaEventHandler:createHandler(callback2)
    local height=0
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-600),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,0))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self:changeTab(self.selectedTabIndex)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function energyCrystalDialog:eventHandler(handler,fn,idx,cel)
   do return end  
end

function energyCrystalDialog:tabClick(idx)
    if self.acTab2 and self.acTab2.isPlaying==true then
        return
    end
    for k,v in pairs(self.allTabs) do
       if v:getTag()==idx then
          v:setEnabled(false)
          self.selectedTabIndex=idx
          self:tabClickColor(idx)
          self:getDataByType(idx)
          self:doUserHandler()
       else
          v:setEnabled(true)
       end
    end
    self:changeTab(idx)
    if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==14)then
        otherGuideMgr:toNextStep()
    end
end

-- idx需要切换的页签，0，1
-- isInit 是否为初始化
function energyCrystalDialog:changeTab(idx)

    if idx==0 then
        if self.acTab1==nil then
            self:initTab1()
        end
        self.layerTab1:setVisible(true)
        self.acTab1:refreshData()
        self.layerTab1:setPosition(ccp(0,0))
        if self.acTab2~=nil then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
    else
        if self.acTab2==nil then
            self:initTab2()
        end
        self.layerTab2:setVisible(true)
        self.acTab2:refreshData()
        self.layerTab2:setPosition(ccp(0,0))
        if self.acTab1~=nil then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
    end 
end

function energyCrystalDialog:initTab1()
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/energyCrystalTab1Dialog"
    self.acTab1=energyCrystalTab1Dialog:new(self.defaultWeaponID)
    
    self.layerTab1=self.acTab1:init(self.layerNum)
    self.bgLayer:addChild(self.layerTab1)
end

function energyCrystalDialog:initTab2()
    require "luascript/script/game/scene/gamedialog/superWeaponDialog/energyCrystalTab2Dialog"
    self.acTab2=energyCrystalTab2Dialog:new()
    self.layerTab2=self.acTab2:init(self.layerNum)
    self.bgLayer:addChild(self.layerTab2)
end

function energyCrystalDialog:tick()
  
end
function energyCrystalDialog:refresh( tab )

end
function energyCrystalDialog:dispose()

  if self.acTab1~=nil then
      self.acTab1:dispose()
      -- self.acTab1:removeFromParentAndCleanup(true)
      self.acTab1=nil
      self.layerTab1=nil
  end
  if self.acTab2~=nil then
      self.acTab2:dispose()
      -- self.acTab2:removeFromParentAndCleanup(true)
      self.acTab2=nil
      self.layerTab2=nil
  end
end

