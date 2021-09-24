acDouble11NewDialog=commonDialog:new()

function acDouble11NewDialog:new(layerNum)
    require "luascript/script/game/scene/gamedialog/activityAndNote/sellShowSureDialog"
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acDouble11.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
    spriteController:addPlist("public/acLuckyCat.plist")  
    spriteController:addPlist("public/acNewYearsEva.plist")--acDouble11New_addImage
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acRechargeBag_images.plist")
    spriteController:addTexture("public/acRechargeBag_images.png")
    spriteController:addPlist("public/acDouble11_NewImage.plist")
    spriteController:addTexture("public/acDouble11_NewImage.png")
    spriteController:addPlist("public/acDouble11New_addImage.plist")
    spriteController:addTexture("public/acDouble11New_addImage.png")
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
    self.tab3 = nil
    self.tabLayer3 = nil
    self.getTimes = 0
    return nc
end

function acDouble11NewDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
        local tabBtnItem = v

        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index ==1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index == 2 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width*2,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        end
        -- if index == self.selectedTabIndex then
        --     tabBtnItem:setEnabled(false)
        -- end
        index=index+1
    end
    -- self.selectedTabIndex=0
end
--设置对话框里的tableView
function acDouble11NewDialog:initTableView()

    local function closeAllDialog( )
        self:close()
    end 
    self.eventH = closeAllDialog
    if eventDispatcher:hasEventHandler("closeNewDouble11Dialog.becauseAllianceGetOut",self.eventH)==false then
        eventDispatcher:addEventListener("closeNewDouble11Dialog.becauseAllianceGetOut",self.eventH)
    end

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
function acDouble11NewDialog:eventHandler(handler,fn,idx,cel)
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
function acDouble11NewDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
      do
          return
      end
    end
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if idx ==2 and (playerVoApi:getPlayerAid() ==0 or playerVoApi:getPlayerAid() ==nil) then
            do break end
         end
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            -- self:doUserHandler()            
         else
            v:setEnabled(true)
         end
       
    end
    
    if idx ==2 then
        if playerVoApi:getPlayerAid() ==0 or playerVoApi:getPlayerAid() ==nil  then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4005"),30)--backstage4005
            do return end
        end
        if self.tabLayer3==nil then
            local function initNewTab(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.data and sData.data.useredbag then
                        acDouble11NewVoApi:formatNewAllainceRedBagTb(sData.data.useredbag)
                    end
                    self.tab3=acDouble11NewTab3:new()
                    self.tabLayer3=self.tab3:init(self.layerNum)
                    self.bgLayer:addChild(self.tabLayer3)    
                    self.tabLayer3:setPosition(ccp(0,0))
                end
            end 
            socketHelper:double11NewPanicBuying(initNewTab,"allianceredlog")--拉取当前军团红包的log
        else
            self.tabLayer3:setVisible(true)
            self.tabLayer3:setPosition(ccp(0,0))
             -- self.tab2.tv:updata()
        end
        
        if self.tabLayer1 then
            self.tabLayer1:setVisible(false)
            self.tabLayer1:setPosition(ccp(10000,0))
        end
        if self.tabLayer2 then
            self.tabLayer2:setVisible(false)
            self.tabLayer2:setPosition(ccp(10000,0))
        end

        
    elseif idx==1 then

        if self.tabLayer2==nil then
            self.tab2=acDouble11NewTab2:new()
            self.tabLayer2=self.tab2:init(self.layerNum)
            self.bgLayer:addChild(self.tabLayer2)
        else
            self.tabLayer2:setVisible(true)
             -- self.tab2.tv:updata()
        end
        
        
        if self.tabLayer1 ~= nil then
            self.tabLayer1:setVisible(false)
            self.tabLayer1:setPosition(ccp(10000,0))
        end
        if self.tabLayer3 then
            self.tabLayer3:setVisible(false)
            self.tabLayer3:setPosition(ccp(10000,0))
        end
        
        self.tabLayer2:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.tabLayer2~=nil then
            self.tabLayer2:setPosition(ccp(999333,0))
            self.tabLayer2:setVisible(false)
        end
        if self.tabLayer3 then
            self.tabLayer3:setVisible(false)
            self.tabLayer3:setPosition(ccp(10000,0))
        end

        if self.tabLayer1==nil then
            self.tab1=acDouble11NewTab1:new()
            self.tab1.dialog =self
            self.tabLayer1=self.tab1:init(self.layerNum)
            self.bgLayer:addChild(self.tabLayer1)
        else
             self.tabLayer1:setVisible(true)
             -- self.tab1:updata()
        end

        self.tabLayer1:setPosition(ccp(0,0))
    end
end


function acDouble11NewDialog:tick()
  local vo=acDouble11NewVoApi:getAcVo()
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
  if self and self.bgLayer and self.tab3 and self.tabLayer3 then 
    self.tab3:tick()
  end
end


function acDouble11NewDialog:update()

end

function acDouble11NewDialog:dispose()
    eventDispatcher:removeEventListener("closeNewDouble11Dialog.becauseAllianceGetOut",self.eventH)
    if self.tab1 then
        self.tab1:dispose()
    end
    if self.tab2 then
        self.tab2:dispose()
    end
    if self.tab3 then
        self.tab3:dispose()
    end
    self.tab1 = nil
    self.tabLayer1 = nil
    self.tab2 = nil
    self.tabLayer2 = nil
    self.tab3 = nil
    self.tabLayer3 = nil
    self.layerNum = nil
    self.getTimes = 0
    -- self=nil
    spriteController:removePlist("public/acLuckyCat.plist")  
    spriteController:removePlist("public/acNewYearsEva.plist")--
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acRechargeBag_images.plist")
    spriteController:removeTexture("public/acRechargeBag_images.png")
    spriteController:removePlist("public/acDouble11_NewImage.plist")
    spriteController:removeTexture("public/acDouble11_NewImage.png")
    spriteController:removePlist("public/acDouble11New_addImage.plist")
    spriteController:removeTexture("public/acDouble11New_addImage.png")
end