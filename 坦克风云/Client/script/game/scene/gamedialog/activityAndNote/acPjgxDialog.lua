acPjgxDialog=commonDialog:new()

function acPjgxDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil

    local function addPlist()
        spriteController:addPlist("public/acthreeyear_images.plist")
        spriteController:addTexture("public/acthreeyear_images.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
        spriteController:addPlist("public/activePicUseInNewGuid.plist")
        spriteController:addTexture("public/activePicUseInNewGuid.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acDouble11New_addImage.plist")
    spriteController:addTexture("public/acDouble11New_addImage.png")
    return nc
end

function acPjgxDialog:resetTab()
    local index=0
    local vo=acPjgxVoApi:getAcVo()
    if not G_isToday(vo.lastTime) then
        acPjgxVoApi:refreshClear()
    end
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
         if G_getCurChoseLanguage() =="ru" then
            local lb = tabBtnItem:getChildByTag(31)
            if lb then
                lb:setFontSize(25)
            end
         end
         index=index+1
    end
end
--设置对话框里的tableView
function acPjgxDialog:initTableView()
    
    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-610),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,10))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)
end



--点击tab页签 idx:索引
function acPjgxDialog:tabClick(idx)
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
            self.tab2=acPjgxTab2:new()
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
            self.tab1=acPjgxTab1:new()
            self.layer1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer1)
        else
            self.layer1:setVisible(true)
            self.tab1:refresh()
        end

        self.layer1:setPosition(ccp(0,0))
    end
end

function acPjgxDialog:refresh()
    for i=1,2 do
        if self["tab"..i] and self["tab"..i].refresh then
            self["tab"..i]:refresh()
        end
    end
end

function acPjgxDialog:tick()
    local acVo = acPjgxVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if not G_isToday(acVo.lastTime) then
            acPjgxVoApi:refreshClear()
            self:refresh()
        end
        if self.tab1 then
            self.tab1:tick()
        end
    else
        self:close()
    end
end

function acPjgxDialog:doUserHandler()
    local count=math.floor((G_VisibleSizeHeight-160)/80)
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end
end

function acPjgxDialog:dispose()
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
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
    spriteController:removePlist("public/acDouble11New_addImage.plist")
    spriteController:removeTexture("public/acDouble11New_addImage.png")
end