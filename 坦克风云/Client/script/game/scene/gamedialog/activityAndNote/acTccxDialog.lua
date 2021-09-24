acTccxDialog=commonDialog:new()

function acTccxDialog:new(layerNum)
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
        spriteController:addPlist("public/activePicUseInNewGuid.plist")
        spriteController:addTexture("public/activePicUseInNewGuid.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acTccxImage.plist")
    spriteController:addTexture("public/acTccxImage.png")
    spriteController:addPlist("public/acJiejingkaicai.plist")
    spriteController:addTexture("public/acJiejingkaicai.png")

    return nc
end

function acTccxDialog:resetTab()
    local index=0
    local vo=acTccxVoApi:getAcVo()
    if not G_isToday(vo.lastTime) then
        acTccxVoApi:refreshClear()
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
function acTccxDialog:initTableView()
    
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
    if self.closeBtn then
        self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-9)
    end
end



--点击tab页签 idx:索引
function acTccxDialog:tabClick(idx)
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
            self.tab2=acTccxTab2:new()
            self.layer2=self.tab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer2)
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
            self.tab1=acTccxTab1:new()
            self.layer1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layer1)
        else
            self.layer1:setVisible(true)
            -- self.tab1:refresh()
        end

        self.layer1:setPosition(ccp(0,0))
    end
end

function acTccxDialog:refresh()
    if self.tab1 and self.tab1.refresh then
        self.tab1:refresh()
    end
end

function acTccxDialog:tick()
    local acVo = acTccxVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if not G_isToday(acVo.lastTime) then
            acTccxVoApi:refreshClear()
            self:refresh()
        end
        self:setIconTipVisibleByIdx(acTccxVoApi:checkTab2Tip(),2)
    else
        self:close()
    end
    if self and self.tab1 and self.tab1.tick then
        self.tab1:tick()
    end
end

function acTccxDialog:doUserHandler()
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
        bgSp:setOpacity(160)
    end

    local function touchTip()
        local tabStr={}

        if self.layer1 and self.layer1:isVisible() then
            tabStr={getlocal("activity_tccx_tip1"),getlocal("activity_tccx_tip2"),getlocal("activity_tccx_tip3"),getlocal("activity_tccx_tip4")}
        else
            tabStr={getlocal("activity_tccx_tab2_tip1"),getlocal("activity_tccx_tab2_tip2")}
        end

        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end

    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-225)
    -- local tabStr={" ",getlocal("activity_tccx_tip4"),getlocal("activity_tccx_tip3"),getlocal("activity_tccx_tip2"),getlocal("activity_tccx_tip1")," "}
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,nil,nil,nil,touchTip,true)
end

function acTccxDialog:dispose()
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
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png") 
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
    spriteController:removePlist("public/acTccxImage.plist")
    spriteController:removeTexture("public/acTccxImage.png")
    spriteController:removePlist("public/acJiejingkaicai.plist")
    spriteController:removeTexture("public/acJiejingkaicai.png")
end