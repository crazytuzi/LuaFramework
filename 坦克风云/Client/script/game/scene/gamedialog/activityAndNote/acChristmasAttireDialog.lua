require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasAttire"
require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasAttireRank"
acChristmasAttireDialog=commonDialog:new()

function acChristmasAttireDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        christmasTab1=nil,
        christmasTab2=nil,

        isEnd=false,

        descLb=nil,
        acLabel=nil,
        timeLb=nil,
        moveBgStarStr=nil,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acChristmasAttireDialog:resetTab()
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
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
    self:tabClick(0,false)
end

function acChristmasAttireDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 175+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
        elseif (self.selectedTabIndex==0) then
            self.topforbidSp:setContentSize(CCSizeMake(0, 0))
            self.bottomforbidSp:setContentSize(CCSizeMake(0, 0))
        end
    end
end

function acChristmasAttireDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.tv:setPosition(ccp(30,165))
 
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX(600/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-180)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,20)
    blueBg:setOpacity(200)
    self.bgLayer:addChild(blueBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local function nilFunction()
    end
    local lineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),nilFunction)
    lineBg:setPosition(ccp(G_VisibleSizeWidth/2,self.bgLayer:getContentSize().height/2-66))
    lineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight-180))
    self.bgLayer:addChild(lineBg)

    local function initInfo()
        local function bgClick()
        end
        local h=G_VisibleSizeHeight-160
        local w=G_VisibleSizeWidth-50 --背景框的宽度
        local bgH=120
        local infoH=20
        local timeStrH=35
        if G_isIphone5() then
            bgH=150
            infoH=0
            timeStrH=70
        end
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(60,24,8,2),bgClick)
        backSprie:setContentSize(CCSizeMake(w,bgH))
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setPosition(ccp(G_VisibleSizeWidth/2,h))
        backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
        backSprie:setIsSallow(true)
        self.bgLayer:addChild(backSprie)

        local cloud1=CCSprite:createWithSpriteFrameName("snowBg_1.png")
        cloud1:setAnchorPoint(ccp(0,1))
        cloud1:setPosition(ccp(20,h+15))
        self.bgLayer:addChild(cloud1,5)

        local cloud2=CCSprite:createWithSpriteFrameName("snowBg_2.png")
        cloud2:setAnchorPoint(ccp(1,1))
        cloud2:setPosition(ccp(G_VisibleSizeWidth-20,h+15))
        self.bgLayer:addChild(cloud2,5)

        local function touch(tag,object)
            PlayEffect(audioCfg.mouseClick)
            --显示活动信息
            self:showInfor()
        end

        local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
        menuItemDesc:setAnchorPoint(ccp(1,1))
        menuItemDesc:setScale(0.8)
        local menuDesc=CCMenu:createWithItem(menuItemDesc)
        menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
        menuDesc:setPosition(ccp(w-20,backSprie:getContentSize().height-10-infoH))
        backSprie:addChild(menuDesc)

        local acLbStr=getlocal("activity_timeLabel")..":"
        local descW=w-100
        if G_isIphone5() then
            acLbStr=getlocal("activity_timeLabel")
            descW=w-30
        end
        local acLabel=GetTTFLabel(acLbStr,25)
        backSprie:addChild(acLabel)
        acLabel:setColor(G_ColorGreen)
        self.acLabel=acLabel
        local acVo=acChristmasAttireVoApi:getAcVo()
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt-24*3600)
        local timeLb=GetTTFLabel(timeStr,25)
        timeLb:setColor(G_ColorGreen)
        backSprie:addChild(timeLb)
        self.timeLb=timeLb
        self:updateAcTime()
        if G_isIphone5()==false then
            local posX=(backSprie:getContentSize().width-acLabel:getContentSize().width-timeLb:getContentSize().width)/2
            acLabel:setAnchorPoint(ccp(0,1))
            acLabel:setPosition(ccp(posX,backSprie:getContentSize().height-10))
            timeLb:setAnchorPoint(ccp(0,1))
            timeLb:setPosition(ccp(acLabel:getPositionX()+acLabel:getContentSize().width,acLabel:getPositionY()))
            timeStrH=acLabel:getContentSize().height
        else
            acLabel:setAnchorPoint(ccp(0.5,1))
            acLabel:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-10))
            timeLb:setAnchorPoint(ccp(0.5,1))
            timeLb:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-10-acLabel:getContentSize().height))
            timeStrH=acLabel:getContentSize().height+timeLb:getContentSize().height
        end

        local descStr1=acChristmasAttireVoApi:getTimeStr()
        local descStr2=acChristmasAttireVoApi:getRewardTimeStr()
        local moveBgStarStr,t1,t2=G_LabelRollView(CCSizeMake(backSprie:getContentSize().width,timeStrH),descStr1,25,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
        self.t1,self.t2 = t1,t2
        moveBgStarStr:setPosition(ccp(0,backSprie:getContentSize().height-timeStrH-10))
        backSprie:addChild(moveBgStarStr)
        self.moveBgStarStr=moveBgStarStr

        local desTv,desLabel=G_LabelTableView(CCSizeMake(descW,70),getlocal("activity_christmas2016_desc1"),25,kCCTextAlignmentLeft)
        backSprie:addChild(desTv)
        desTv:setPosition(ccp(15,8))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        desTv:setMaxDisToBottomOrTop(100)
        self.descLb=desLabel

        self:refreshInfo()
    end
    initInfo()
end

function acChristmasAttireDialog:showInfor()
    local strSize2  = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 = 25
    end
    if self.selectedTabIndex==0 then
        local tabStr={}
        local tabColor={}
        local tabAlignment={}
        tabStr={"\n",getlocal("activity_christmas2016_rule5"),"\n",getlocal("activity_christmas2016_rule4"),"\n",getlocal("activity_christmas2016_rule3"),"\n",getlocal("activity_christmas2016_rule2"),"\n",getlocal("activity_christmas2016_rule1"),"\n",getlocal("activityDescription"),"\n"}
        tabColor={nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro,nil}
        tabAlignment={nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
    elseif self.selectedTabIndex==1 then
        local strTab={}
        local colorTab={}
        local tabAlignment={}
        local rewards=acChristmasAttireVoApi:getRankReward()
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
        local ruleStr1=getlocal("activity_christmas2016_rankRule1")
        local ruleStr2=getlocal("activity_christmas2016_rankRule2",{acChristmasAttireVoApi:getRankLimit()})
        local ruleStr3=getlocal("activity_christmas2016_rankRule3")
        local ruleStr4=getlocal("activity_christmas2016_rankRule4",{needRank})
        local ruleStr5=getlocal("activity_christmas2016_rankRule5")

        local strTab2={" ",ruleStr5," ",ruleStr4,ruleStr3,ruleStr2,ruleStr1," ",ruleStr," "}
        for k,v in pairs(strTab2) do
            table.insert(strTab,v)
            if tostring(v)==tostring(ruleStr) or tostring(v)==tostring(ruleStr5) then
                table.insert(colorTab,G_ColorYellowPro)
                table.insert(tabAlignment,kCCTextAlignmentCenter)
            else
                table.insert(colorTab,G_ColorWhite)
                table.insert(tabAlignment,kCCTextAlignmentLeft)
            end     
        end
        local td=smallDialog:new()

        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,strSize2,colorTab,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
end

function acChristmasAttireDialog:refreshInfo()
    if self.descLb then
        local descStr=getlocal("activity_christmas2016_desc"..(self.selectedTabIndex+1))
        self.descLb:setString(descStr)
    end
    if self.acLabel and self.moveBgStarStr and self.timeLb then
        if self.selectedTabIndex==1 then
            self.moveBgStarStr:setVisible(true)
            self.acLabel:setVisible(false)
            self.timeLb:setVisible(false)
        else
            self.moveBgStarStr:setVisible(false)
            self.acLabel:setVisible(true)
            self.timeLb:setVisible(true)
        end
    end
end

function acChristmasAttireDialog:tabClick(idx,isEffect)
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

function acChristmasAttireDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acChristmasAttireDialog:getDataByIdx(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    if tabType==2 then
        local flag=acChristmasAttireVoApi:acIsStop()
        local ranklist=acChristmasAttireVoApi:getRankList()
        if flag==false or (flag==true and ranklist==nil) then
            local function callback()
                self:switchTab(tabType)
                self["christmasTab2"]:updateUI()
            end
            acChristmasAttireVoApi:christmasRequest("active.christmas2016.rank",nil,callback)
        else
            self:switchTab(tabType)
        end
    else
        self:switchTab(tabType)
    end
end

function acChristmasAttireDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["christmasTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acChristmasAttire:new()
	   	else
	   		tab=acChristmasAttireRank:new()
	   	end
	   	self["christmasTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["christmasTab"..tabType].updateUI then
                    self["christmasTab"..tabType]:updateUI()
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

function acChristmasAttireDialog:updateAcTime()
    local acVo=acChristmasAttireVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb,nil,nil,nil,true)
    end
    if acVo and self.t1 and self.t2 and tolua.cast(self.t1,"CCLabelTTF") and tolua.cast(self.t2,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.t1,self.t2,nil,nil)
    end
end
function acChristmasAttireDialog:tick()
    self:updateAcTime()
    if acChristmasAttireVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,3 do
            if self["christmasTab"..i]~=nil and self["christmasTab"..i].tick then
                self["christmasTab"..i]:tick()
            end
        end
    end
end

function acChristmasAttireDialog:refreshIconTipVisible()
    if acChristmasAttireVoApi:acIsStop()==true then
    end
end

function acChristmasAttireDialog:dispose()
    if self.christmasTab1 then
        self.christmasTab1:dispose()
    end
    if self.christmasTab2 then
        self.christmasTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.christmasTab1=nil
    self.christmasTab2=nil

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
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end
