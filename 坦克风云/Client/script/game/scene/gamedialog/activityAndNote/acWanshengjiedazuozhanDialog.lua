

acWanshengjiedazuozhanDialog=commonDialog:new()

function acWanshengjiedazuozhanDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil

    return nc
end

function acWanshengjiedazuozhanDialog:resetTab()
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
function acWanshengjiedazuozhanDialog:initTableView()
    
    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)
end

-- --这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
-- function acWanshengjiedazuozhanDialog:eventHandler(handler,fn,idx,cel)
--    if fn=="numberOfCellsInTableView" then
--        return 4

--    elseif fn=="tableCellSizeForIndex" then
--        local tmpSize =CCSizeMake(400,180)
--        return  tmpSize
       
--    elseif fn=="tableCellAtIndex" then
--        local cell=CCTableViewCell:new()
--        cell:autorelease()
--        return cell
--    elseif fn=="ccTouchBegan" then
--        self.isMoved=false
--        return true
--    elseif fn=="ccTouchMoved" then
--        self.isMoved=true
--    elseif fn=="ccTouchEnded"  then
       
--    end
-- end



--点击tab页签 idx:索引
function acWanshengjiedazuozhanDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    -- if idx == 1 then
    --   local willReturn = false
    --   if willReturn == true then
    --     do
    --       self:tabClickColor(0) 
    --       return
    --     end
    --   end
    -- end

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

        if self.layer2==nil then
            self.tab2=acWanshengjiedazuozhanTab2:new()
            self.layer2=self.tab2:init(self.layerNum,self)
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
            self.tab1=acWanshengjiedazuozhanTab1:new()
            self.layer1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer1)
        else
            self.layer1:setVisible(true)
        end

        self.layer1:setPosition(ccp(0,0))
    end
end

function acWanshengjiedazuozhanDialog:refresh()
    for i=1,2 do
        if self["tab"..i] and self["tab"..i].refresh then
            self["tab"..i]:refresh()
        end
    end
end

function acWanshengjiedazuozhanDialog:tick()
    local acVo = acWanshengjiedazuozhanVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        for i=1,2 do
            if self["tab"..i] and self["tab"..i].tick then
                self["tab"..i]:tick()
            end
        end
        local taskCanReward=acWanshengjiedazuozhanVoApi:taskCanReward()
        if taskCanReward==true then
            self:setIconTipVisibleByIdx(true,2)
        else
            self:setIconTipVisibleByIdx(false,2)
        end
    else
        self:close()
    end
end

function acWanshengjiedazuozhanDialog:dispose()
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