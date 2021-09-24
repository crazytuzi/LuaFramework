require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFunctionDialog"
allianceExistDialog=commonDialog:new()

function allianceExistDialog:new(tabType,layerNum,searchName)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.tableCell1={}
    self.tableCell2={}
    self.tableCellItem2={}
    self.enTime=0
    self.tv2=nil
    
    self.tabType=tabType;
    
    self.dataSource={}
    self.tableCell3={}
    self.tableCellItem3={}
    self.recordPoint1=nil
    self.recordPoint3=nil
    self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil
    self.pauseEffect=false
    self.searchName=searchName
    return nc
end

--设置对话框里的tableView
function allianceExistDialog:initTableView()
    
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

    G_WeakTb.allianceDialog=self
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceExistDialog:eventHandler(handler,fn,idx,cel)
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

--设置或修改每个Tab页签
function allianceExistDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
    if self.tabType==1 then
        local function realShow()
            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogInfoTab"
            self.playerTab1=allianceDialogInfoTab:new()
            self.layerTab1=self.playerTab1:init(self,self.layerNum)
            self.bgLayer:addChild(self.layerTab1);  
            allianceVoApi:setNeedRefreshFlag(false)
        end
        if allianceVoApi:isNeedRefreshFlag()==true then
            base.allianceTime=nil
            G_getAlliance(realShow) --重新拉取一下军团数据
        else
            realShow()
        end
    elseif self.tabType==2 then
        self.playerTab2=allianceFunctionDialog:new(self.layerNum,self)
        self.layerTab2=self.playerTab2:init(self.layerNum)
        self.bgLayer:addChild(self.layerTab2);
        self.layerTab2:setPosition(ccp(0,0))
        self.layerTab2:setVisible(true)
        
        for k,v in pairs(self.allTabs) do
         if v:getTag()==1 then
            v:setEnabled(false)
            self.selectedTabIndex=1
            self:doUserHandler()
            
            
         else
            v:setEnabled(true)
         end
        end
        
    elseif self.tabType==3 then
        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogTab1"
        self.playerTab3=allianceDialogTab1:new()
        self.layerTab3=self.playerTab3:init(self,self.layerNum,self.isGuide)
        self.bgLayer:addChild(self.layerTab3);
        self.layerTab3:setPosition(ccp(0,0))
        self.layerTab3:setVisible(true)
        
        for k,v in pairs(self.allTabs) do
             if v:getTag()==2 then
                v:setEnabled(false)
                self.selectedTabIndex=2
                self:doUserHandler()
                
                
             else
                v:setEnabled(true)
             end
        end

    end

    
    
end


function allianceExistDialog:getDataByType(type)
    if type==nil then
        type=0
    end
    if type==2 then
        local function getListHandler(fn,data)
            if base:checkServerData(data)==true then
                 if self~=nil and self.playerTab3~=nil then
                     self.playerTab3:refresh()
                 end
                  self:doUserHandler()

                allianceVoApi:setLastListTime(base.serverTime)
            end
        end
        if allianceVoApi:getNeedGetList() or allianceVoApi:getRankOrGoodNum()==0 then
            socketHelper:allianceList(getListHandler,1)
        else
            if self~=nil and self.playerTab3~=nil then
                self.playerTab3:refresh(true)
            end
            self:doUserHandler()
        end
    end
end

--点击tab页签 idx:索引
function allianceExistDialog:tabClick(idx,isEffect,subIdx)
        
        if isEffect==false then
        else
            PlayEffect(audioCfg.mouseClick)
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
    
    if idx==1 then
            
            if self.layerTab2==nil then
                self.playerTab2=allianceFunctionDialog:new(self.layerNum,self)
                self.layerTab2=self.playerTab2:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab2);
                self.layerTab2:setPosition(ccp(999333,0))
                self.layerTab2:setVisible(false)
            end
            
            if self.playerTab1==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogInfoTab"
                self.playerTab1=allianceDialogInfoTab:new()
                self.layerTab1=self.playerTab1:init(self,self.layerNum,subIdx)
                self.bgLayer:addChild(self.layerTab1);
            end
            if self.layerTab3==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogTab1"

                self.playerTab3=allianceDialogTab1:new()
                self.layerTab3=self.playerTab3:init(self,self.layerNum)
                self.bgLayer:addChild(self.layerTab3);
                self.layerTab3:setPosition(ccp(999333,0))
                self.layerTab3:setVisible(false)
            end

            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
            
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(10000,0))
            
            self.layerTab2:setVisible(true)
            self.layerTab2:setPosition(ccp(0,0))

            
        elseif idx==0 then
            
            if self.layerTab2==nil then
                self.playerTab2=allianceFunctionDialog:new(self.layerNum,self)
                self.layerTab2=self.playerTab2:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab2);
                self.layerTab2:setPosition(ccp(999333,0))
                self.layerTab2:setVisible(false)
            end
            
            if self.playerTab1==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogInfoTab"
                self.playerTab1=allianceDialogInfoTab:new()
                self.layerTab1=self.playerTab1:init(self,self.layerNum,subIdx)
                self.bgLayer:addChild(self.layerTab1);
            end
            if self.layerTab3==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogTab1"
                self.playerTab3=allianceDialogTab1:new()
                self.layerTab3=self.playerTab3:init(self,self.layerNum)
                self.bgLayer:addChild(self.layerTab3);
                self.layerTab3:setPosition(ccp(999333,0))
                self.layerTab3:setVisible(false)
            end

            self.layerTab1:setVisible(true)
            self.layerTab1:setPosition(ccp(0,0))
            
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(10000,0))
            
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(939393,0))

            if self.recordPoint1~=nil then
                self.tv:recoverToRecordPoint(self.recordPoint1);
            end
        elseif idx==2 then
            if self.layerTab2==nil then
                self.playerTab2=allianceFunctionDialog:new(self.layerNum,self)
                self.layerTab2=self.playerTab2:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab2);
                self.layerTab2:setPosition(ccp(999333,0))
                self.layerTab2:setVisible(false)
            end
            
            if self.playerTab1==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogInfoTab"
                self.playerTab1=allianceDialogInfoTab:new()
                self.layerTab1=self.playerTab1:init(self,self.layerNum,subIdx)
                self.bgLayer:addChild(self.layerTab1);
            end
            if self.layerTab3==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogTab1"
                self.playerTab3=allianceDialogTab1:new(self.searchName)
                self.layerTab3=self.playerTab3:init(self,self.layerNum)
                self.bgLayer:addChild(self.layerTab3);
                self.layerTab3:setPosition(ccp(999333,0))
                self.layerTab3:setVisible(false)
            end

            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(99930,0))
            
            self.layerTab3:setVisible(true)
            self.layerTab3:setPosition(ccp(0,0))
            
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(939393,0))

            if self.recordPoint3~=nil then
                self.tv:recoverToRecordPoint(self.recordPoint3);
            end
    end
     self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function allianceExistDialog:doUserHandler()

end



function allianceExistDialog:tick()
    
    if self.selectedTabIndex==0 and self.playerTab1~=nil then
        self.playerTab1:tick()

    elseif self.selectedTabIndex==1 then
        --self.playerTab2:tick()
    elseif self.selectedTabIndex==2 and self.playerTab3~=nil then 
        self.playerTab3:tick()
    end
    
end

function allianceExistDialog:dispose()
    allianceVoApi:setPage(1)
    self.expandIdx=nil
    if self.playerTab1~=nil then
        self.playerTab1:dispose()
    end
    if self.playerTab3~=nil then
        self.playerTab3:dispose()
    end
    
    if self.playerTab2~=nil then
        self.playerTab2:dispose()
    end
    
    self.layerTab1=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab3=nil

    self.enTime=nil
    
    self.dataSource=nil
    self.tableCell3=nil
    self.tableCellItem3=nil
    self.recordPoint1=nil
    self.recordPoint2=nil
    self.recordPoint3=nil
    self=nil
    --清空全局公会板子表
    G_AllianceDialogTb=nil
    G_AllianceDialogTb={}
    if G_WeakTb.allianceDialog then
        G_WeakTb.allianceDialog=nil
    end
end




