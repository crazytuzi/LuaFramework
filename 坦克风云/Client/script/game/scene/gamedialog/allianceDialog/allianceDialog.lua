--require "luascript/script/componet/commonDialog"
allianceDialog=commonDialog:new()

function allianceDialog:new(tabType,layerNum,searchName)
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
    self.searchName=searchName

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
    
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    spriteController:addPlist("public/juntuanCityBtns.plist")
    spriteController:addTexture("public/juntuanCityBtns.png")

    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    spriteController:addPlist("public/newAlliance.plist")
    spriteController:addPlist("public/believer/believerMain.plist")
    spriteController:addTexture("public/believer/believerMain.png")
    spriteController:addTexture("public/newAlliance.png")
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


    return nc
end

--设置或修改每个Tab页签
function allianceDialog:resetTab()
    if G_phasedGuideOnOff() then
        if phasedGuideMgr:getInsideKey(7)==0 then
            phasedGuideMgr:insidePanel(102)
            phasedGuideMgr:setInsideKeyDone(7)
        end
    end

    self:forbidSty()

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
        require "luascript/script/game/scene/gamedialog/allianceDialog/recommendAllianceTab"
        self.playerTab1=recommendAllianceTab:new(self.searchName)
        self.layerTab1=self.playerTab1:init(self,self.layerNum,self.isGuide)
        self.bgLayer:addChild(self.layerTab1);

    elseif self.tabType==2 then

        
    elseif self.tabType==3 then
        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogCreateTab"
        self.playerTab3=allianceDialogCreateTab:new()
        self.layerTab3=self.playerTab3:init(self,self.layerNum)
        self.bgLayer:addChild(self.layerTab3);
        self.layerTab3:setPosition(ccp(0,0))
        self.layerTab3:setVisible(true)
        
        for k,v in pairs(self.allTabs) do
             if v:getTag()==2 then
                v:setEnabled(false)
                self.selectedTabIndex=2
                
                
             else
                v:setEnabled(true)
             end
        end

    end

    
    
end


function allianceDialog:getDataByType(type)
	if type==nil then
		type=0
	end
    if type==0 then
        local showType=allianceVoApi:getShowListType()
        local function getListHandler(fn,data)
            if base:checkServerData(data)==true then
                if self~=nil and self.playerTab1~=nil then
                    self.playerTab1:refresh()
                end
                allianceVoApi:setLastListTime(base.serverTime)
                allianceVoApi:setNeedFlag(showType,0)
            end
        end
        if allianceVoApi:getNeedGetList() or allianceVoApi:getRankOrGoodNum()==0 or allianceVoApi:getNeedFlag(showType)==1 then
            if showType==0 then
                socketHelper:allianceList(getListHandler,0)
            else
                socketHelper:allianceList(getListHandler,1)
            end
        else
            if self~=nil and self.playerTab1~=nil then
                self.playerTab1:refresh(true)
            end
        end
    end
end

--设置对话框里的tableView
function allianceDialog:initTableView()
--     local function callBack(...)
--        return self:eventHandler(...)
--     end
--     local hd= LuaEventHandler:createHandler(callBack)
--     local height=0;
-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
--     self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
--     self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
--     self.tv:setPosition(ccp(30,30))
--     self.bgLayer:addChild(self.tv)
--     self.tv:setVisible(false)

--     self.tv:setMaxDisToBottomOrTop(120)

    
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceDialog:eventHandler(handler,fn,idx,cel)
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
function allianceDialog:tabClick(idx)
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
            self:getDataByType(idx)
            
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then
            if self.playerTab1==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/recommendAllianceTab"
                self.playerTab1=recommendAllianceTab:new()
                self.layerTab1=self.playerTab1:init(self,self,self.layerNum)
                self.bgLayer:addChild(self.layerTab1);
            end
            if self.layerTab3==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogCreateTab"
                self.playerTab3=allianceDialogCreateTab:new()
                self.layerTab3=self.playerTab3:init(self,self.layerNum)
                self.bgLayer:addChild(self.layerTab3);
                self.layerTab3:setPosition(ccp(999333,0))
                self.layerTab3:setVisible(false)
            end

            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(99930,0))
            
            self.layerTab3:setVisible(true)
            self.layerTab3:setPosition(ccp(0,0))

            if self.recordPoint3~=nil then
                self.tv:recoverToRecordPoint(self.recordPoint3);
            end


            
        elseif idx==0 then

            
            if self.playerTab1==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/recommendAllianceTab"
                self.playerTab1=recommendAllianceTab:new()
                self.layerTab1=self.playerTab1:init(self,self.layerNum,isGuide)
                self.bgLayer:addChild(self.layerTab1);
            end
            if self.layerTab3==nil then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialogCreateTab"
                self.playerTab3=allianceDialogCreateTab:new()
                self.layerTab3=self.playerTab3:init(self,self.layerNum)
                self.bgLayer:addChild(self.layerTab3);
                self.layerTab3:setPosition(ccp(999333,0))
                self.layerTab3:setVisible(false)
            end
            self.layerTab1:setVisible(true)
            self.layerTab1:setPosition(ccp(0,0))
            
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(10000,0))

            if self.recordPoint1~=nil then
                self.tv:recoverToRecordPoint(self.recordPoint1);
            end

        end
  -- if self.selectedTabIndex==1 then
  --     self.tv:setPosition(ccp(30,160))
  -- else
  --     self.tv:setPosition(ccp(30,30))
  -- end
    -- self:resetForbidLayer()
end

-- 去遮罩
function allianceDialog:forbidSty()

    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end

    if self.panelTopLine then
        self.panelTopLine:setVisible(false)
    end

    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)

    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
    self.bgLayer:addChild(tabLine,15)

end


--点击了cell或cell上某个按钮
function allianceDialog:cellClick(idx)
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

function allianceDialog:tick()
    
    if self.selectedTabIndex==0 and self.playerTab1~=nil then
        self.playerTab1:tick()

    elseif self.selectedTabIndex==1 then

    elseif self.selectedTabIndex==2 and self.playerTab3~=nil then 
        self.playerTab3:tick()
    end
    
end

function allianceDialog:dispose()
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
    self=nil
    --清空全局公会板子表
    G_AllianceDialogTb=nil
    G_AllianceDialogTb={}

    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/allianceActiveImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/allianceActiveImage.pvr.ccz")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/newAlliance.plist")
    spriteController:removePlist("public/juntuanCityBtns.plist")
    spriteController:removeTexture("public/newAlliance.png")
    spriteController:removeTexture("public/juntuanCityBtns.png")
    spriteController:removePlist("public/believer/believerMain.plist")
    spriteController:removeTexture("public/believer/believerMain.png")
end




