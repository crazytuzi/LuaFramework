require "luascript/script/game/scene/gamedialog/activityAndNote/acHardGetRichDialogTab1"
require "luascript/script/game/scene/gamedialog/activityAndNote/acHardGetRichDialogTab2"
require "luascript/script/game/scene/gamedialog/activityAndNote/acHardGetRichRankDialog"
acHardGetRichDialog=commonDialog:new()

function acHardGetRichDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    
    self.playerTab1=nil
    self.playerTab2=nil

    return nc
end

--设置或修改每个Tab页签
function acHardGetRichDialog:resetTab()

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
    self:initLayer()

end

function acHardGetRichDialog:initLayer()
    self.playerTab1=acHardGetRichDialogTab1:new(self,self.layerNum)
    self.layerTab1=self.playerTab1:init()
    self.bgLayer:addChild(self.layerTab1);
    self.layerTab1:setPosition(ccp(0,0))
    self.layerTab1:setVisible(true)

    self.playerTab2=acHardGetRichDialogTab2:new(self,self.layerNum)
    self.layerTab2=self.playerTab2:init(
    )
    self.bgLayer:addChild(self.layerTab2);
    self.layerTab2:setPosition(ccp(10000,0))
    self.layerTab2:setVisible(false)

end



--设置对话框里的tableView
function acHardGetRichDialog:initTableView()
    
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
function acHardGetRichDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 4

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize

        if self.selectedTabIndex==0 then
            if idx==0 then
                tmpSize=CCSizeMake(400,180)
            
            else
                tmpSize=CCSizeMake(400,150)
            end
        elseif self.selectedTabIndex==1 then
            tmpSize=CCSizeMake(400,150)

        else
            tmpSize=CCSizeMake(400,150)
        end
         
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
function acHardGetRichDialog:tabClick(idx)
        PlayEffect(audioCfg.mouseClick)
        
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
            self:getDataByType(idx)
            
         else
            v:setEnabled(true)
         end
    end
    
    if idx==0 then
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        self.layerTab2:setVisible(false)
        self.layerTab2:setPosition(ccp(99930,0))

    elseif idx==1 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(10000,0))
        
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))
        self.playerTab2:refreshTv()

    end

    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function acHardGetRichDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function acHardGetRichDialog:cellClick(idx)
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

function acHardGetRichDialog:tick()
    if self and self.playerTab1 and self.playerTab1.tick then
        self.playerTab1:tick()
    end
end

function acHardGetRichDialog:dispose()
    self.expandIdx=nil
    if self.playerTab1~=nil then
        self.playerTab1:dispose()
    end
    if self.playerTab2~=nil then
        self.playerTab2:dispose()
    end
    self.layerTab1=nil
    self.layerTab2=nil
    self.playerTab1=nil
    self.playerTab2=nil
    self=nil
end




