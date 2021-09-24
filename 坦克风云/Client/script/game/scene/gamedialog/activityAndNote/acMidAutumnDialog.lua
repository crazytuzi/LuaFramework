require "luascript/script/game/scene/gamedialog/activityAndNote/acMidAutumnTask"
require "luascript/script/game/scene/gamedialog/activityAndNote/acMidAutumnLottery"
require "luascript/script/game/scene/gamedialog/activityAndNote/acMidAutumnRank"
acMidAutumnDialog=commonDialog:new()

function acMidAutumnDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,
        layerTab3=nil,

        midAutumnTab1=nil,
        midAutumnTab2=nil,
        midAutumnTab3=nil,

        isEnd=false,
        version=acMidAutumnVoApi:getVersion(),
        descLb=nil,
        acLabel=nil,
        timeLb=nil,
        moveBgStarStr=nil,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acMidAutumnDialog:resetTab()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/newTopBgImage1.plist")
    spriteController:addTexture("public/newTopBgImage1.png")
    spriteController:addPlist("public/nbSkill2.plist")
    spriteController:addTexture("public/nbSkill2.png")
    spriteController:addPlist("public/battleResultAddPic.plist")
    spriteController:addTexture("public/battleResultAddPic.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
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
    self.isEnd=acMidAutumnVoApi:acIsStop()
    local tasklist=acMidAutumnVoApi:getChangedTaskList()
    local taskCount=SizeOfTable(tasklist)
    -- local isFree=acMidAutumnVoApi:isFreeRefresh()
    local refreshNum = acMidAutumnVoApi:getReValue()
    if taskCount==0 and refreshNum==0 then
        local function callback()
            self:tabClick(0,false)
        end
        acMidAutumnVoApi:midAutumnRequest(1,0,callback)
    else
        self:tabClick(0,false)
    end
end

function acMidAutumnDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 175+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
        elseif (self.selectedTabIndex==0) then
            self.topforbidSp:setContentSize(CCSizeMake(0, 0))
            self.bottomforbidSp:setContentSize(CCSizeMake(0, 0))
        elseif (self.selectedTabIndex==2) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-210))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 210))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 130))
        end
    end
end

function acMidAutumnDialog:doUserHandler()
    self.panelLineBg:setVisible(false)
end

function acMidAutumnDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.tv:setPosition(ccp(30,165))
 
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- local function nilFunction()
    -- end
    -- local lineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),nilFunction)
    -- lineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-76))
    -- lineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight-190))
    -- self.bgLayer:addChild(lineBg)
    local desc1 = getlocal("activity_midautumn_desc1")

    if self.version == 3 then
        desc1 = getlocal("activity_midautumn_v2_desc1")
    end
    
    local function initInfo()
        local function bgClick()
        end
        local h=G_VisibleSizeHeight-160
        local w=G_VisibleSizeWidth-50 --背景框的宽度
        local backSprie=CCSprite:create()
        backSprie:setContentSize(CCSizeMake(w,150))
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setPosition(ccp(G_VisibleSizeWidth/2,h-4))
        self.bgLayer:addChild(backSprie)
        -- 背景
        self.bgLayer1 = CCLayer:create()
        self.bgLayer1:setPosition(ccp(w/2, backSprie:getContentSize().height/2))
        backSprie:addChild(self.bgLayer1)
        local bgShade=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
        bgShade:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
        bgShade:setAnchorPoint(ccp(0.5,1))
        bgShade:setPosition(w/2, backSprie:getContentSize().height+4)
        backSprie:addChild(bgShade)

        -- 网络下载的图
        local function onLoadIcon(fn,icon)
            if self and self.bgLayer1 and tolua.cast(self.bgLayer1, "CCLayer") then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition(ccp(0, 0))
                self.bgLayer1:addChild(icon)
            end
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local urlPath = acMidAutumnVoApi:getVersion() == 3 and "active/acMidAutumnBg2.jpg" or "active/acMidAutumnBg.jpg"
        local webImage = LuaCCWebImage:createWithURL(G_downloadUrl(urlPath), onLoadIcon)

        local function touch(tag,object)
            PlayEffect(audioCfg.mouseClick)
            --显示活动信息
            self:showInfor()
        end

        local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,nil,nil,0)
        menuItemDesc:setAnchorPoint(ccp(1,1))
        local menuDesc=CCMenu:createWithItem(menuItemDesc)
        menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
        menuDesc:setPosition(ccp(w+15,backSprie:getContentSize().height-10))
        backSprie:addChild(menuDesc)

        local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
        poolBg:setAnchorPoint(ccp(0.5,0))
        poolBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 180,90))
        poolBg:setPosition(ccp(w/2,10))
        poolBg:setOpacity(255*0.5)
        backSprie:addChild(poolBg)

        local descStr1=acMidAutumnVoApi:getTimeStr()
        local descStr2=acMidAutumnVoApi:getRewardTimeStr()
        local moveBgStarStr,timeLb1,timeLb2=G_LabelRollView(CCSizeMake(backSprie:getContentSize().width,46),descStr1,25,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
        self.timeLb1=timeLb1
        self.timeLb2=timeLb2
        moveBgStarStr:setPosition(ccp(0,backSprie:getContentSize().height-moveBgStarStr:getContentSize().height-14))
        backSprie:addChild(moveBgStarStr)
        self.moveBgStarStr=moveBgStarStr      
        local acLabel=GetTTFLabel(getlocal("activity_timeLabel"),25)
        acLabel:setAnchorPoint(ccp(0.5,1))
        acLabel:setPosition(ccp((G_VisibleSizeWidth-20)/2, backSprie:getContentSize().height-10))
        backSprie:addChild(acLabel)
        acLabel:setColor(G_ColorGreen)
        self.acLabel=acLabel
        local acVo=acMidAutumnVoApi:getAcVo()
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt-24*3600)
        local timeLb=GetTTFLabel(timeStr,25)
        timeLb:setAnchorPoint(ccp(0.5,1))
        timeLb:setPosition(ccp(w/2, backSprie:getContentSize().height-7))
        timeLb:setColor(G_ColorGreen)
        backSprie:addChild(timeLb)
        self.timeLb=timeLb
        self:updateAcTime()
        local desTv,desLabel=G_LabelTableView(CCSizeMake(w-120,70),desc1,24,kCCTextAlignmentLeft)
        backSprie:addChild(desTv)
        desTv:setPosition(ccp(60,16))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        desTv:setMaxDisToBottomOrTop(100)
        self.descLb=desLabel

        self:refreshInfo()
    end
    initInfo()
end

function acMidAutumnDialog:showInfor()
    local strSize = 25
    if G_getCurChoseLanguage() ~= "cn" then
        strSize = 20
    end
    if self.selectedTabIndex==0 then
        local tabStr={}
        local tabColor={}
        local tabAlignment={}
        local rewards=acMidAutumnVoApi:getRebelReward()
        local rewardCount=SizeOfTable(rewards)
        local str=""
        for k,v in pairs(rewards) do
            if k==rewardCount then
                str=str..v.name
            else
                str=str..v.name..","
            end
        end
        if(self.version==3)then
            tabStr={"\n",getlocal("midautumn_task_v2_rule4",{str}),"\n",getlocal("midautumn_task_rule3"),"\n",getlocal("midautumn_task_v2_rule2"),"\n",getlocal("midautumn_task_rule1"),"\n",getlocal("activityDescription"),"\n"}
        else
            tabStr={"\n",getlocal("midautumn_task_rule4",{str}),"\n",getlocal("midautumn_task_rule3"),"\n",getlocal("midautumn_task_rule2"),"\n",getlocal("midautumn_task_rule1"),"\n",getlocal("activityDescription"),"\n"}
        end
        tabColor={nil,nil,nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro} or {"\n",getlocal("midautumn_task_rule4",{str}),"\n",getlocal("midautumn_task_rule3"),"\n",getlocal("midautumn_task_rule2"),"\n",getlocal("midautumn_task_rule1"),"\n",getlocal("activityDescription"),"\n"}
        tabColor={nil,nil,nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro}
        tabAlignment={nil,nil,nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize,tabColor,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
    elseif self.selectedTabIndex==1 then
        local tabStr={}
        local tabColor={}
        local tabAlignment={}
        tabStr=self.version == 3 and {"\n",getlocal("midautumn_lottery_v2_rule3"),"\n",getlocal("midautumn_lottery_v2_rule2"),"\n",getlocal("midautumn_lottery_v2_rule1"),"\n",getlocal("activityDescription"),"\n"} or {"\n",getlocal("midautumn_lottery_rule3"),"\n",getlocal("midautumn_lottery_rule2"),"\n",getlocal("midautumn_lottery_rule1"),"\n",getlocal("activityDescription"),"\n"}
        tabColor={nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro}
        tabAlignment={nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize,tabColor,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
    elseif self.selectedTabIndex==2 then
        local strTab={}
        local colorTab={}
        local tabAlignment={}
        local rewards=acMidAutumnVoApi:getRankReward()
        local needRank=0
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
            table.insert(strTab,1,str)
            table.insert(colorTab,1,G_ColorWhite)
            table.insert(tabAlignment,1,kCCTextAlignmentLeft)
            if tonumber(rank[2])>needRank then
                needRank=rank[2]
            end
        end
        table.insert(strTab,1," ")
        table.insert(colorTab,1,G_ColorWhite)
        table.insert(tabAlignment,1,kCCTextAlignmentLeft)
        local ruleStr=getlocal("activityDescription")
        local ruleStr1=getlocal("miaautumn_rank_rule1",{acMidAutumnVoApi:getRankLimit()})
        local ruleStr2=getlocal("miaautumn_rank_rule2")
        local ruleStr3=getlocal("miaautumn_rank_rule3",{needRank})
        local ruleStr5=getlocal("miaautumn_rank_rule5")
        local ruleStr4=getlocal("miaautumn_rank_rule4")

        local strTab2={" ",ruleStr4," ",ruleStr5," ",ruleStr3,ruleStr2,ruleStr1," ",ruleStr," "}
        for k,v in pairs(strTab2) do
            table.insert(strTab,v)
            if tostring(v)==tostring(ruleStr) or tostring(v)==tostring(ruleStr4) then
                table.insert(colorTab,G_ColorYellowPro)
                table.insert(tabAlignment,kCCTextAlignmentCenter)
            else
                table.insert(colorTab,G_ColorWhite)
                table.insert(tabAlignment,kCCTextAlignmentLeft)
            end     
        end

        table.insert(strTab,1,getlocal("sample_prop_name_4943") .. ":" .. getlocal("sample_prop_des_4943"))
        table.insert(colorTab,1,G_ColorWhite)
        table.insert(tabAlignment,1,kCCTextAlignmentLeft)
        table.insert(strTab,1," ")
        table.insert(colorTab,1,G_ColorWhite)
        table.insert(tabAlignment,1,kCCTextAlignmentLeft)

        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,strSize,colorTab,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
end

function acMidAutumnDialog:refreshInfo()
    if self.descLb then
        local descStr=self.version == 3 and getlocal("activity_midautumn_v2_desc"..(self.selectedTabIndex+1)) or getlocal("activity_midautumn_desc"..(self.selectedTabIndex+1))
        self.descLb:setString(descStr)
    end
    if self.acLabel and self.moveBgStarStr and self.timeLb then
        if self.selectedTabIndex==2 then
            self.moveBgStarStr:setVisible(true)
            self.acLabel:setVisible(false)
            self.timeLb:setVisible(false)
        else
            self.moveBgStarStr:setVisible(false)
            self.acLabel:setVisible(true)
            self.timeLb:setVisible(true)
        end
        self.acLabel:setVisible(false)
    end
end

function acMidAutumnDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    local function realSwitchSubTab()
        for k,v in pairs(self.allTabs) do
            if v:getTag()==idx then
                v:setEnabled(false)
                self:getDataByIdx(idx+1)
                self.selectedTabIndex=idx
            else
                v:setEnabled(true)
            end
        end
    end
    realSwitchSubTab()
end

function acMidAutumnDialog:goTaskDialog()
    self.oldSelectedTabIndex=self.selectedTabIndex
    self:tabClickColor(1)
    self:tabClick(0,false)
end

function acMidAutumnDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acMidAutumnDialog:getDataByIdx(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    self:switchTab(tabType)
    if tabType==3 then
        local function callback()
            self["midAutumnTab3"]:updateUI()
        end
        acMidAutumnVoApi:midAutumnRequest(7,nil,callback)
    end
end

function acMidAutumnDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["midAutumnTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acMidAutumnTask:new()
        elseif(tabType==2)then
            tab=acMidAutumnLottery:new()
	   	else
	   		tab=acMidAutumnRank:new()
	   	end
	   	self["midAutumnTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,3 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["midAutumnTab"..tabType].updateUI then
                    self["midAutumnTab"..tabType]:updateUI()
                end
    		end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
    self:refreshInfo()
end


function acMidAutumnDialog:tick()
    if acMidAutumnVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,3 do
            if self["midAutumnTab"..i]~=nil and self["midAutumnTab"..i].tick then
                self["midAutumnTab"..i]:tick()
            end
        end
    end

    if self.isEnd~=acMidAutumnVoApi:acIsStop() then
        self.isEnd=acMidAutumnVoApi:acIsStop()
    end
    self:updateAcTime()
end

function acMidAutumnDialog:updateAcTime()
    local acVo=acMidAutumnVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        -- G_updateActiveTime(acVo,self.timeLb,true)
        local descStr1=acMidAutumnVoApi:getTimeStr()
        self.timeLb:setString(descStr1)
    end
    if(acVo and self.timeLb1 and tolua.cast(self.timeLb1,"CCLabelTTF"))then
        -- G_updateActiveTime(acVo,self.timeLb1,self.timeLb2,true)
        local descStr1=acMidAutumnVoApi:getTimeStr()
        local descStr2=acMidAutumnVoApi:getRewardTimeStr()
        self.timeLb1:setString(descStr1)
        self.timeLb2:setString(descStr2)
    end
end

function acMidAutumnDialog:refreshIconTipVisible()
    if acMidAutumnVoApi:acIsStop()==true then
        -- local canReward1=acMidAutumnVoApi:canRankReward(1)
        -- local canReward2=acMidAutumnVoApi:canRankReward(2)
        -- if canReward1==false and canReward2==false then
        --     if self.setIconTipVisibleByIdx then
        --         self:setIconTipVisibleByIdx(false,2)
        --     end
        -- else
        --     if self.setIconTipVisibleByIdx then
        --         self:setIconTipVisibleByIdx(true,2)
        --     end
        -- end
    end
end

function acMidAutumnDialog:dispose()
    if self.midAutumnTab1 then
        self.midAutumnTab1:dispose()
    end
    if self.midAutumnTab2 then
        self.midAutumnTab2:dispose()
    end
    if self.midAutumnTab3 then
        self.midAutumnTab3:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.midAutumnTab1=nil
    self.midAutumnTab2=nil
    self.midAutumnTab3=nil

    self.isEnd=false
    self.descLb=nil
    self.acLabel=nil
    self.timeLb=nil
    self.moveBgStarStr=nil
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/newTopBgImage1.plist")
    spriteController:removeTexture("public/newTopBgImage1.png")
    spriteController:removePlist("public/nbSkill2.plist")
    spriteController:removeTexture("public/nbSkill2.png")
    spriteController:removePlist("public/battleResultAddPic.plist")
    spriteController:removeTexture("public/battleResultAddPic.png")
end
