--require "luascript/script/componet/commonDialog"
playerDialog=commonDialog:new()

function playerDialog:new(tabType,layerNum,isGuide,taskVo)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.leftBtn=nil
    nc.expandIdx={}
    nc.tableCell1={}
    nc.tableCell2={}
    nc.tableCellItem2={}
    nc.enTime=0
    nc.tv2=nil
    
    nc.tabType=tabType;
    nc.isGuide=isGuide;
    nc.taskVo=taskVo
    
    nc.dataSource={}
    nc.tableCell3={}
    nc.tableCellItem3={}
    nc.recordPoint1=nil
    nc.recordPoint2=nil
    nc.recordPoint3=nil
    nc.layerNum=layerNum
    
    nc.layerTab1=nil
    nc.layerTab2=nil
    nc.layerTab3=nil
    
    nc.playerTab1=nil
    nc.playerTab2=nil
    nc.playerTab3=nil
   
    return nc
end

--设置或修改每个Tab页签
function playerDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         
         

         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
             
         end
         index=index+1
    end
    self:tabClickColor(self.tabType-1)
    if self.tabType==1 then
        self.playerTab1=playerDialogTab1:new()
        self.layerTab1=self.playerTab1:init(self.layerNum,self.isGuide,self.taskVo)
        self.btnItem = self.playerTab1.btn
        self.bgLayer:addChild(self.layerTab1);
        newGuidMgr:showNewStageGuid(1)

    elseif self.tabType==2 then
        self.playerTab2=playerDialogTab2:new(self)
        self.layerTab2=self.playerTab2:init(self.layerNum,self.isGuide,self.taskVo)
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
        self.playerTab3=playerDialogTab3:new()
        self.layerTab3=self.playerTab3:init(self.layerNum)
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

        
    
    
    
    --[[
    local function callBack()
        
        
        

    end
    
    local callFunc=CCCallFunc:create(callBack)
    local delayAction=CCDelayTime:create(0.5)
    local seq=CCSequence:createWithTwoActions(delayAction,callFunc)
    self.bgLayer:runAction(seq) 
    ]]
    
    
end

--设置对话框里的tableView
function playerDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80 - 78)


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
    if self.btnItem ~= nil then
        local x,y,z,w  = G_getSpriteWorldPosAndSize(self.btnItem, 1)
        local scale = 1.5
        newSkipCfg[4].clickRect = CCRectMake(x-(scale-1)*z*0.5,y-(scale-1)*w*0.5 + G_VisibleSizeHeight,z*scale,w*scale)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function playerDialog:eventHandler(handler,fn,idx,cel)
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
function playerDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
        if newGuidMgr.curStep==39 and idx~=1 then
            do return end
        end
    end
    PlayEffect(audioCfg.mouseClick)
    --local sp1= self.bgLayer:getChildByTag(21)
    --local sp2= self.bgLayer:getChildByTag(22)
    -- local sp3= self.bgLayer:getChildByTag(23)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:doUserHandler()
        else
            v:setEnabled(true)
        end
    end
    
    if idx==1 then
        if newGuidMgr:isNewGuiding() then --新手引导
             newGuidMgr:toNextStep()
        end
            
        if self.layerTab2==nil then
            self.playerTab2=playerDialogTab2:new(self)
            self.layerTab2=self.playerTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2);
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
            
        if self.playerTab1==nil then
            self.playerTab1=playerDialogTab1:new()
            self.layerTab1=self.playerTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1);
        end
        if self.layerTab3==nil then
            self.playerTab3=playerDialogTab3:new()
            self.layerTab3=self.playerTab3:init(self.layerNum)
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
        
        --sp1:setVisible(true)
        --sp2:setVisible(true)
        -- sp3:setVisible(true)
        newGuidMgr:showNewStageGuid(2)
            
    elseif idx==0 then            
        if self.layerTab2==nil then
            self.playerTab2=playerDialogTab2:new(self)
            self.layerTab2=self.playerTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2);
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
            
        if self.playerTab1==nil then
            self.playerTab1=playerDialogTab1:new()
            self.layerTab1=self.playerTab1:init(self.layerNum,self.isGuide,self.taskVo)
            self.bgLayer:addChild(self.layerTab1);
        end
        if self.layerTab3==nil then
            self.playerTab3=playerDialogTab3:new()
            self.layerTab3=self.playerTab3:init(self.layerNum)
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

        --sp1:setVisible(false)
        --sp2:setVisible(false)
        -- sp3:setVisible(false)
        if self.recordPoint1~=nil then
            self.tv:recoverToRecordPoint(self.recordPoint1);
        end
    elseif idx==2 then
        
        if self.layerTab2==nil then
            self.playerTab2=playerDialogTab2:new(self)
            self.layerTab2=self.playerTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2);
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        
        if self.playerTab1==nil then
            self.playerTab1=playerDialogTab1:new()
            self.layerTab1=self.playerTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1);
        end
        if self.layerTab3==nil then
            self.playerTab3=playerDialogTab3:new()
            self.layerTab3=self.playerTab3:init(self.layerNum)
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

        --sp1:setVisible(false)
        --sp2:setVisible(false)
        -- sp3:setVisible(false)
        if self.recordPoint3~=nil then
            self.tv:recoverToRecordPoint(self.recordPoint3);
        end
    end
    if self.selectedTabIndex==1 then
        self.tv:setPosition(ccp(30,160))
    else
        self.tv:setPosition(ccp(30,30))
    end
    if self.selectedTabIndex==0 then
        self.playerTab2:removeGuied()
    elseif self.selectedTabIndex==1 then
        self.playerTab1:removeGuied()
        self.playerTab2:recordPoint()
    elseif self.selectedTabIndex==2 then
        self.playerTab1:removeGuied()
        self.playerTab2:removeGuied()
    end
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function playerDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function playerDialog:cellClick(idx)
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

function playerDialog:tick()
    
    if self.selectedTabIndex==0 and self.playerTab1~=nil then
        self.playerTab1:tick()

    elseif self.selectedTabIndex==1 then
        self.playerTab2:tick()
    elseif self.selectedTabIndex==2 and self.playerTab3~=nil then 
        self.playerTab3:tick()
    end
    
end

function playerDialog:dispose()
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
    spriteController:removePlist("public/nbSkill.plist")
    spriteController:removeTexture("public/nbSkill.png")
    
    
    
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil

    self.enTime=nil
    
    self.dataSource=nil
    self.tableCell3=nil
    self.tableCellItem3=nil
    self.recordPoint1=nil
    self.recordPoint2=nil
    self.recordPoint3=nil
    self.taskVo=nil
    self=nil

end




