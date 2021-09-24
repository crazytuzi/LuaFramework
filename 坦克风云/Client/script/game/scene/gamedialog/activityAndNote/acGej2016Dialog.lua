acGej2016Dialog=commonDialog:new()

function acGej2016Dialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil
    
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acGej2016Image.plist")
    spriteController:addTexture("public/acGej2016Image.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/refiningImage.plist")
    local function addPlist()
        spriteController:addPlist("public/acthreeyear_images.plist")
        spriteController:addTexture("public/acthreeyear_images.png")
    end
    G_addResource8888(addPlist)
    return nc
end

function acGej2016Dialog:resetTab()
    local index=0
    local vo=acGej2016VoApi:getAcVo()
    if not G_isToday(vo.lastTime) then
        acGej2016VoApi:refreshClear()
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
         index=index+1
    end
end
--设置对话框里的tableView
function acGej2016Dialog:initTableView()
    
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



--点击tab页签 idx:索引
function acGej2016Dialog:tabClick(idx)
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
        if self.layerTab2 ==nil then
            self.acTab2=acGej2016Tab2:new(self.layerNum)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2,1);
        else
            self.acTab2:refresh()
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end
        self:resetForbidLayer(G_VisibleSizeHeight-360,360,30)
    elseif idx==0 then
        if self.layerTab1 ==nil then
            self.acTab1=acGej2016Tab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1,1);
        else
            -- self.acTab1:refresh()
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end

        self:resetForbidLayer(G_VisibleSizeHeight-400,400,110)
    end
end

function acGej2016Dialog:refresh(acVo)
    if not G_isToday(acVo.lastTime) then
        acGej2016VoApi:refreshClear()
        if self.acTab1 then
            self.acTab1:refresh()
        end
    end
end

function acGej2016Dialog:tick()
    local acVo = acGej2016VoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
       self:refresh(acVo)
    else
        self:close()
    end
end

function acGej2016Dialog:resetForbidLayer(posY1,height1,height2)
    if posY1 and height1 and height2 then
        -- self.topforbidSp:setVisible(true)
        -- self.bottomforbidSp:setVisible(true)
        self.topforbidSp:setPosition(0,posY1)
        self.bottomforbidSp:setPosition(0,0)
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height1))
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height2))
    end
    
    
end

function acGej2016Dialog:dispose()
    if self.layerTab1~=nil then
        self.acTab1:dispose()
    end
    if self.layerTab2~=nil then
        self.acTab2:dispose()
    end
    self.layerTab1 = nil
    self.acTab1 = nil
    self.layerTab2 = nil
    self.acTab2 = nil
    self.layerNum = nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/refiningImage.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/refiningImage.png")

    spriteController:removePlist("public/acGej2016Image.plist")
    spriteController:removeTexture("public/acGej2016Image.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")

end