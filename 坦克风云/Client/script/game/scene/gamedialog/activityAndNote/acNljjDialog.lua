acNljjDialog=commonDialog:new()

function acNljjDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil

    local function addPlist()
        spriteController:addPlist("public/acNljjImage.plist")
        spriteController:addTexture("public/acNljjImage.png")
        spriteController:addPlist("public/purpleFlicker.plist")
        spriteController:addTexture("public/purpleFlicker.png")
    end
    G_addResource8888(addPlist)
    return nc
end

function acNljjDialog:resetTab()
    local index=0
    local vo=acNljjVoApi:getAcVo()
    if not G_isToday(vo.lastTime) then
        acNljjVoApi:refreshClear()
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
function acNljjDialog:initTableView()
    
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
function acNljjDialog:tabClick(idx)
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
        local function refreshCallback()
            if self.layerTab2 ==nil then
                self.acTab2=acNljjTab2:new(self.layerNum)
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
            self:resetForbidLayer(G_VisibleSizeHeight-175,175,115)
        end
        local cmd="active.nengliangjiejing.ranklist"
        acNljjVoApi:socketRankList(cmd,refreshCallback)
        
    elseif idx==0 then
        if self.layerTab1 ==nil then
            self.acTab1=acNljjTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1,2);
        else
            self.acTab1:refresh()
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end

        self:resetForbidLayer(G_VisibleSizeHeight-175,175,110)
    end
end

function acNljjDialog:refresh(acVo)
    if not G_isToday(acVo.lastTime) then
        acNljjVoApi:refreshClear()
        if self.acTab1 then
            self.acTab1:refresh()
        end
        if self.acTab2 then
            self.acTab2:refresh()
        end
    end
end

function acNljjDialog:tick()
    local acVo = acNljjVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
       self:refresh(acVo)
    else
        self:close()
        return
    end
    if self.acTab1 then
        self.acTab1:tick()
    end
    if acNljjVoApi:acIsStop() then
        local state=acNljjVoApi:getRankRewardState()
        if state==1 then
            self:setIconTipVisibleByIdx(false,2)
            return
        end
        if acVo and acVo.lastTs then
            local startT=acNljjVoApi:getRewardTime()
            if acVo.lastTs-startT>=0 then
                local myRank=acNljjVoApi:getMyrank()
                if myRank and myRank>0 and myRank<=10 then
                    self:setIconTipVisibleByIdx(true,2)
                end
            end
        else
            self:setIconTipVisibleByIdx(false,2)
        end
        
    end
end

function acNljjDialog:fastTick()
    if self.acTab1 then
        self.acTab1:fastTick()
    end
end

function acNljjDialog:resetForbidLayer(posY1,height1,height2)
    if posY1 and height1 and height2 then
        -- self.topforbidSp:setVisible(true)
        -- self.bottomforbidSp:setVisible(true)
        self.topforbidSp:setPosition(0,posY1)
        self.bottomforbidSp:setPosition(0,0)
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height1))
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height2))
    end
    
    
end

function acNljjDialog:dispose()
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

    spriteController:removePlist("public/acNljjImage.plist")
    spriteController:removeTexture("public/acNljjImage.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
end