acBtzxDialog=commonDialog:new()

function acBtzxDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.layer1 = nil
    self.tab2 = nil
    self.layer2 = nil
    
    local function addPlist()
        spriteController:addPlist("public/acNewYearsEva.plist")
        spriteController:addTexture("public/acNewYearsEva.png")
        spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
        spriteController:addTexture("public/allianceWar2/allianceWar2.png")
    end
    G_addResource8888(addPlist)
    return nc
end

function acBtzxDialog:resetTab()
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
end
--设置对话框里的tableView
function acBtzxDialog:initTableView()
    local strSize2  = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 = 25
    end
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

    -- 蓝底背景
    local function addBlueBg()
        local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg:setAnchorPoint(ccp(0.5,0))
        blueBg:setScaleX(600/blueBg:getContentSize().width)
        blueBg:setScaleY((G_VisibleSizeHeight-180)/blueBg:getContentSize().height)
        blueBg:setPosition(G_VisibleSizeWidth/2,20)
        blueBg:setOpacity(200)
        self.bgLayer:addChild(blueBg)
    end
    G_addResource8888(addBlueBg)

    local bgSp = CCSprite:create("public/acImminentImage/imminentBg.jpg")
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setScale(0.97)
    bgSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(bgSp)

    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-210)

    local cfg=acBtzxVoApi:getCfg()

    local tabStr={getlocal("activity_btzx_tip5"),getlocal("activity_btzx_tip4"),getlocal("activity_btzx_tip3"),getlocal("activity_btzx_tip2",{FormatNumber(cfg.rankLimit)}),getlocal("activity_btzx_tip1")," "}
    
    local rewards=cfg.rankReward

    for k,v in pairs(rewards) do
        local rank=v[1]
        local reward=FormatItem(v[2],false,true)
        local rewardCount=SizeOfTable(reward)
        local str=""
        for k,v in pairs(reward) do
            if k==rewardCount then
                str=str..v.name.." x"..v.num
            else
                str=str..v.name.." x"..v.num..","
            end
        end
        if rank[1]==rank[2] then
            str=getlocal("rank_reward_str",{rank[1],str})
        else
            str=getlocal("rank_reward_str",{rank[1].."~"..rank[2],str})
        end
        table.insert(tabStr,1,str)
    end
    table.insert(tabStr,1,"")

    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,nil,nil,strSize2)
end



--点击tab页签 idx:索引
function acBtzxDialog:tabClick(idx)
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
                self.acTab2=acBtzxTab2:new(self.layerNum)
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
            self:resetForbidLayer(G_VisibleSizeHeight-360,360,40)

        end
        local flag=false
        if self.layerTab2 ==nil then
            flag=true
        end
        local cmd="active.baituanzhengxiong.ranklist"
        acBtzxVoApi:socketRankList(cmd,nil,refreshCallback,flag)
    elseif idx==0 then
        if self.layerTab1 ==nil then
            self.acTab1=acBtzxTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1,1);
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end

        self:resetForbidLayer(G_VisibleSizeHeight-295,400,40)
    end
end

function acBtzxDialog:refresh(acVo)
    -- if not G_isToday(acVo.lastTime) then
    --     acBtzxVoApi:refreshClear()
    --     if self.acTab1 then
    --         self.acTab1:refresh()
    --     end
    -- end
end

function acBtzxDialog:tick()
    local acVo = acBtzxVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
       -- self:refresh(acVo)
    else
        self:close()
    end

    if self.acTab1 then
        self.acTab1:tick()
    end
    if self.acTab2 then
        self.acTab2:tick()
    end
end

function acBtzxDialog:resetForbidLayer(posY1,height1,height2)
    if posY1 and height1 and height2 then
        -- self.topforbidSp:setVisible(true)
        -- self.bottomforbidSp:setVisible(true)
        self.topforbidSp:setPosition(0,posY1)
        self.bottomforbidSp:setPosition(0,0)
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height1))
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height2))
    end
    
    
end

function acBtzxDialog:dispose()
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
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")

end