acSweetTroubleDialog=commonDialog:new()

function acSweetTroubleDialog:new(layerNum)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.tabLayer1 = nil
    self.tab2 = nil
    self.tabLayer2 = nil

    self.getTimes = 0
    spriteController:addTexture("ship/newTank/halloweenBg.jpg")
    return nc
end

function acSweetTroubleDialog:resetTab()
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
function acSweetTroubleDialog:initTableView()
    
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acSweetTroubleDialog:eventHandler(handler,fn,idx,cel)
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
function acSweetTroubleDialog:tabClick(idx)
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

        if self.tabLayer2==nil then
            self.tab2=acSweetTroubleTab2:new()
            self.tabLayer2=self.tab2:init(self.layerNum)
            self.bgLayer:addChild(self.tabLayer2)
        else
            self.tabLayer2:setVisible(true)
             self.tab2:updata()
        end
        
        
        if self.tabLayer1 ~= nil then
            self.tabLayer1:setVisible(false)
            self.tabLayer1:setPosition(ccp(10000,0))
        end
        
        self.tabLayer2:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.tabLayer2~=nil then
            self.tabLayer2:setPosition(ccp(999333,0))
            self.tabLayer2:setVisible(false)
        end
        
        if self.tabLayer1==nil then
            self.tab1=acSweetTroubleTab1:new()
            self.tab1.dialog =self
            self.tabLayer1=self.tab1:init(self.layerNum)
            self.bgLayer:addChild(self.tabLayer1)
        else
             self.tabLayer1:setVisible(true)
             self.tab1:updata()
        end

        self.tabLayer1:setPosition(ccp(0,0))
    end
end


function acSweetTroubleDialog:tick()
  local vo=acSweetTroubleVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
  if self and self.bgLayer and self.tab1 and self.tabLayer1 then 
    self.tab1:tick()
  end
  if self and self.bgLayer and self.tab2 and self.tabLayer2 then 
    self.tab2:tick()
  end
end


function acSweetTroubleDialog:update()

end

function acSweetTroubleDialog:dispose()
    if self.tab1~=nil then
        self.tab1:dispose()
    end
    if self.tab2~=nil then
        self.tab2:dispose()
    end
    self.tab1 = nil
    self.tabLayer1 = nil
    self.tab2 = nil
    self.tabLayer2 = nil
    self.layerNum = nil
    self.getTimes = 0
    self=nil
    spriteController:removeTexture("ship/newTank/halloweenBg.jpg")
end