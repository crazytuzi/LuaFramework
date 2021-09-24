require "luascript/script/componet/commonDialog"
testDialog=commonDialog:new()

function testDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    return nc
end

--设置或修改每个Tab页签
function testDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(self.bgSize.width/2-tabBtnItem:getContentSize().width/2,self.bgSize.height-tabBtnItem:getContentSize().height/2)
         elseif index==1 then
         tabBtnItem:setPosition(self.bgSize.width/2+tabBtnItem:getContentSize().width/2,self.bgSize.height-tabBtnItem:getContentSize().height/2)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function testDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85),nil)
    self.bgLayer:setTouchPriority(-41)
    self.tv:setTableViewTouchPriority(-43)
    self.tv:setPosition(ccp(30,20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function testDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       if self.selectedTabIndex==0 then
           return 20
       elseif self.selectedTabIndex==1 then
            return 5
       end

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       if self.expandIdx["k"..idx]~=nil then
         tmpSize=CCSizeMake(400,800)
       elseif idx==0 or idx==1 then
         tmpSize=CCSizeMake(400,120)
       else
         tmpSize=CCSizeMake(400,120)
       end
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           return self:cellClick(idx)
       end
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 118))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-42)

       local lb=GetTTFLabel(idx,20)
       

       if self.expandIdx["k"..idx]~=nil then
          backSprie:setPosition(ccp(0,680));
          cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 798))  
          local content=CCSprite:create("tk.png")
          content:setAnchorPoint(ccp(0.5,0.5));
          content:setPosition(ccp(self.bgLayer:getContentSize().width/2,340))
          --menuBtn:setPosition(backSprie:getContentSize().width-menuPopupItem:getContentSize().width/2,739)
          lb:setPosition(20,739)
          content:addChild(GetTTFLabel(888,20))
          cell:addChild(content,2,2)
       else
          backSprie:setPosition(ccp(0,0));
          --menuBtn:setPosition(backSprie:getContentSize().width-menuPopupItem:getContentSize().width/2,59)
          lb:setPosition(20,59)
       end
       
       cell:addChild(backSprie,1)
       --cell:addChild(menuBtn,1)
       cell:addChild(lb,1)
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
function testDialog:tabClick(idx)
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self.tv:reloadData()
            self:doUserHandler()
         else
            v:setEnabled(true)
         end
    end
end

--用户处理特殊需求,没有可以不写此方法
function testDialog:doUserHandler()
    
    if self.selectedTabIndex==0 then
        if self.leftBtn==nil then
            self.leftBtn=CCSprite:create("head_cancel.png")
            self.leftBtn:setAnchorPoint(ccp(0.5,0.5))
            self.leftBtn:setPosition(ccp(self.leftBtn:getContentSize().width/2+5,self.bgSize.height-self.leftBtn:getContentSize().height/2-5))
            self.bgLayer:addChild(self.leftBtn)
        end
        self.leftBtn:setVisible(true)
    else
        if self.leftBtn~=nil then
            self.leftBtn:setVisible(false)
        end
    end
end

--点击了cell或cell上某个按钮
function testDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,120)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,800)
        end
    end
end








