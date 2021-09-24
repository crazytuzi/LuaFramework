acEatChickenDialog=commonDialog:new()

function acEatChickenDialog:new(layerNum)
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
        spriteController:addPlist("public/acEatChickImage.plist")
        spriteController:addTexture("public/acEatChickImage.png")
        spriteController:addPlist("public/activePicUseInNewGuid.plist")
        spriteController:addTexture("public/activePicUseInNewGuid.png")
        spriteController:addTexture("public/blueFilcker.png")
        spriteController:addPlist("public/blueFilcker.plist")
        spriteController:addPlist("public/yellowFlicker.plist")
        spriteController:addTexture("public/yellowFlicker.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    -- spriteController:addPlist("public/acDouble11New_addImage.plist")
    -- spriteController:addTexture("public/acDouble11New_addImage.png")
    return nc
end

function acEatChickenDialog:resetTab()
    require "luascript/script/game/scene/gamedialog/activityAndNote/acEatChickenBattleScene"
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight - 158)

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
    -- if allianceVoApi:isHasAlliance()  then
       local function rewardRecordShow()
            self:tabClick(0)
        end
        acEatChickenVoApi:rewardRecord(rewardRecordShow)
    -- else
    --     self:tabClick(0)
    -- end
end
--设置对话框里的tableView
function acEatChickenDialog:initTableView()
    
    -- local function callBack(...)
       -- return self:eventHandler(...)
    -- end
    -- local hd= LuaEventHandler:createHandler(callBack)
    -- local height=0;
    -- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-610),nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    -- self.tv:setPosition(ccp(30,10))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)
end



--点击tab页签 idx:索引
function acEatChickenDialog:tabClick(idx)
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
            self.tab2=acEatChickenDialogTabTwo:new()
            self.layer2=self.tab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer2,1)
        else
            self.layer2:setVisible(true)
            self.tab2:refresh()
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
            self.tab1=acEatChickenDialogTabOne:new()
            self.layer1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer1,1)
            if acEatChickenVoApi:isCanGetAllianceRankList() then
                local function refreshCall( )
                    if self.tab1 and self.tab1.refreshTop5PlayerName then
                        self.tab1:refreshTop5PlayerName()
                    end
                end 
                acEatChickenVoApi:getIntegralRelatedDataSocket(refreshCall,4)--获取军团所有成员积分和名字
            end
        else
            self.tab1:refreshTop5PlayerName()
            self.layer1:setVisible(true)
            print("refreshTop5PlayerName~~~~~~~~")
        end
        
        self.layer1:setPosition(ccp(0,0))
    end
end

function acEatChickenDialog:refresh()

end

function acEatChickenDialog:tick()
    local acVo = acEatChickenVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if self.tab1 then
            self.tab1:tick()
        end
        if self.tab2 then
            self.tab2:tick()
        end
    else
        self:close()
    end
end

function acEatChickenDialog:fastTick( )
    -- print("acEatChickenDialog fastTick~~~~~~~")
    if acEatChickenBattleScene and acEatChickenBattleScene.fastTick then
        acEatChickenBattleScene:fastTick()
    end
end

function acEatChickenDialog:doUserHandler()
    -- local count=math.floor((G_VisibleSizeHeight-160)/80)
    -- for i=1,count do
    --     local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
    --     bgSp:setAnchorPoint(ccp(0.5,1))
    --     bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
    --     bgSp:setScaleY(80/bgSp:getContentSize().height)
    --     bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
    --     self.bgLayer:addChild(bgSp)
    --     if G_isIphone5()==false and i==count then
    --         bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
    --     end
    -- end
end

function acEatChickenDialog:dispose()
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
    spriteController:removePlist("public/acEatChickImage.plist")
    spriteController:removeTexture("public/acEatChickImage.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
    spriteController:removeTexture("public/blueFilcker.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    -- spriteController:removePlist("public/acDouble11New_addImage.plist")
    -- spriteController:removeTexture("public/acDouble11New_addImage.png")
end