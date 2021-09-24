acNewTechDialog=commonDialog:new()

function acNewTechDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil
    return nc
end

function acNewTechDialog:resetTab()
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
function acNewTechDialog:initTableView()
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
function acNewTechDialog:eventHandler(handler,fn,idx,cel)
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
function acNewTechDialog:tabClick(idx)
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

        if self.layer2==nil then
            self.tab2=acNewTechTab:new()
            self.layer2=self.tab2:init(2,self.layerNum)
            self.bgLayer:addChild(self.layer2)
        else
            self.layer2:setVisible(true)
        end
        
        
        if self.layer1 ~= nil then
            self.layer1:setVisible(false)
            self.layer1:setPosition(ccp(10000,0))
        end
        
        self.layer2:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.layer2~=nil then
            self.layer2:setPosition(ccp(999333,0))
            self.layer2:setVisible(false)
        end
        
        if self.layer1==nil then
            self.tab1=acNewTechTab:new()
            self.layer1=self.tab1:init(1,self.layerNum)
            self.bgLayer:addChild(self.layer1)
        else
             self.layer1:setVisible(true)
        end

        self.layer1:setPosition(ccp(0,0))
    end
    
    
    -- 上下遮盖，防止tv超出界面被点击
    if self.selectedTabIndex==1 then  
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth ,380))
        self.topforbidSp:setPosition(0,G_VisibleSizeHeight - 380)
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,10))
    else
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,380))
        self.topforbidSp:setPosition(0,G_VisibleSizeHeight - 380)
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,10))
    end
end


function acNewTechDialog:update()
  local acVo = acNewTechVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    else -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      if self.tab1 ~= nil then
        self.tab1:update()
      end

      if self.tab2 ~= nil then
        self.tab2:update()
      end
    end
  end 
end

function acNewTechDialog:tick()
  if(self.tab1 and self.tab1.tick)then
    self.tab1:tick()
  end
  if(self.tab2 and self.tab2.tick)then
    self.tab2:tick()
  end
end


function acNewTechDialog:dispose()
    if self.tab1~=nil then
        self.tab1:dispose()
    end
    if self.tab2~=nil then
        self.tab2:dispose()
    end
    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil

    self.layerNum = nil
    self=nil
end