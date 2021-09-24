require "luascript/script/game/scene/gamedialog/arenaDialog/arenaDialogTab1"
require "luascript/script/game/scene/gamedialog/arenaDialog/arenaDialogTab2"
require "luascript/script/game/scene/gamedialog/arenaDialog/arenaDialogTab3"
require "luascript/script/game/scene/gamedialog/arenaDialog/reportListDialog"
-- require "luascript/script/game/scene/gamedialog/arenaDialog/reportDetailDialog"
require "luascript/script/game/scene/gamedialog/arenaDialog/reportDetailNewDialog"
require "luascript/script/game/scene/gamedialog/arenaDialog/arenaSmallDialog"

arenaDialog=commonDialog:new()

function arenaDialog:new(layerNum)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil

    return nc
end

--设置或修改每个Tab页签
function arenaDialog:resetTab()

    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
    --self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-260))
    --self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66-40))

    local function callback(fn,data)
        if base:checkServerData(data)==true then
            local function callback2(fn,data)
              if base:checkServerData(data)==true then
                  
              end
            end
            socketHelper:militaryGetluckrank(callback2)

            self.playerTab1=arenaDialogTab1:new(self)
            self.layerTab1=self.playerTab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1);
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)

            self.playerTab2=arenaDialogTab2:new()
            self.layerTab2=self.playerTab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2);
            self.layerTab2:setPosition(ccp(10000,0))
            self.layerTab2:setVisible(false)



        end
    end
    socketHelper:militaryGet(callback)
    
        
    
    

end


--设置对话框里的tableView
function arenaDialog:initTableView()
    
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
function arenaDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       if self.selectedTabIndex==0 then
           return 4
       elseif self.selectedTabIndex==1 then
            return SizeOfTable(skillVoApi:getAllSkills())
       elseif self.selectedTabIndex==2 then
            return SizeOfTable(self.dataSource)
       end

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
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       
       local hei =0
       if self.selectedTabIndex==0 then
           if idx==0 then
                    hei=180
                else
                    hei=150
                end
       else
       
            hei=150     
       
       end
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie,1)
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
function arenaDialog:tabClick(idx)
        if newGuidMgr:isNewGuiding() then --新手引导
              if newGuidMgr.curStep==39 and idx~=1 then
                    do
                        return
                    end
              end
        end
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
        if self.layerTab3~=nil then
           self.layerTab3:setVisible(false)
           self.layerTab3:setPosition(ccp(99930,0))
        end
    elseif idx==1 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(10000,0))
        
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))
        if self.layerTab3~=nil then
           self.layerTab3:setVisible(false)
           self.layerTab3:setPosition(ccp(99930,0))
        end

        self.playerTab2:clearTouchSp()
    
    elseif idx==2 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(99930,0))
        
        self.layerTab2:setVisible(false)
        self.layerTab2:setPosition(ccp(99930,0))
        
        if self.layerTab3==nil then
            local function callback1(fn,data)
                if base:checkServerData(data)==true then
                    self.playerTab3=arenaDialogTab3:new(self)
                    self.layerTab3=self.playerTab3:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab3);
                    self.layerTab3:setVisible(true)
                    self.layerTab3:setPosition(ccp(0,0))
                    
                    

                end
            end
            socketHelper:militaryRanklist(callback1)

        else
           self.layerTab3:setVisible(true)
           self.layerTab3:setPosition(ccp(0,0))
        end

        


    end

    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function arenaDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function arenaDialog:cellClick(idx)
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

function arenaDialog:tick()
    if self.selectedTabIndex==0 and self.playerTab1~=nil then
        self.playerTab1:tick()

    elseif self.selectedTabIndex==1 and self.playerTab2~=nil then
        self.playerTab2:tick()

    elseif self.selectedTabIndex==2 and self.playerTab3~=nil then
        self.playerTab3:tick()

    end
end

function arenaDialog:dispose()
    heroVoApi:clearTroops()
    self.expandIdx=nil
    if self.playerTab1~=nil then
        self.playerTab1:dispose()
    end
    if self.playerTab2~=nil then
        self.playerTab2:dispose()
    end
    if self.playerTab3~=nil then
        self.playerTab3:dispose()
    end
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil
    self=nil

end




