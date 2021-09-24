require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreLottery"
require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreShop"
acMineExploreDialog=commonDialog:new()

function acMineExploreDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        exploreTab1=nil,
        exploreTab2=nil,

        isEnd=false,
        infoPage=nil,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acMineExploreDialog:resetTab()
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acMonthlySign.plist")
    spriteController:addTexture("public/acMonthlySign.png")
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
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

function acMineExploreDialog:resetForbidLayer()
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

function acMineExploreDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.tv:setPosition(ccp(30,165))
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
        self.bgLayer:addChild(backSprie,100)
        self.infoPage=backSprie

        local function touch(tag,object)
            PlayEffect(audioCfg.mouseClick)
            --显示活动信息
            self:showInfor()
        end

        local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
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
        local acVo=acMineExploreVoApi:getAcVo()
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLb=GetTTFLabel(timeStr,25)
        timeLb:setColor(G_ColorGreen)
        backSprie:addChild(timeLb)
        self.timeLb = timeLb
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

        local desTv,desLabel=G_LabelTableView(CCSizeMake(descW,70),getlocal("activity_mineExplore_desc1"),25,kCCTextAlignmentLeft)
        backSprie:addChild(desTv)
        desTv:setPosition(ccp(15,8))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        desTv:setMaxDisToBottomOrTop(100)
    end
    if self.selectedTabIndex==0 then
        initInfo()
    end
end

function acMineExploreDialog:showInfor()
    if self.selectedTabIndex==0 then
        local tabStr={}
        local tabColor={}
        local tabAlignment={}
        tabStr={"\n",getlocal("activity_mineExplore_rule5"),"\n",getlocal("activity_mineExplore_rule4",{acMineExploreVoApi:getRankLimit()}),"\n",getlocal("activity_mineExplore_rule3",{acMineExploreVoApi:getDoubleLayer()}),"\n",getlocal("activity_mineExplore_rule2"),"\n",getlocal("activity_mineExplore_rule1"),"\n",getlocal("activityDescription"),"\n"}
        tabColor={nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro,nil}
        tabAlignment={nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
end

function acMineExploreDialog:tabClick(idx,isEffect)
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

function acMineExploreDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acMineExploreDialog:getDataByIdx(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    if tabType==1 then
        local base=acMineExploreVoApi:getBase()
        if base==nil then
            local function callback()
               self:switchTab(tabType)
            end
            acMineExploreVoApi:mineExploreRequest("active.mineexplore.next",nil,callback)
        else
            self:switchTab(tabType)
        end
    else
        self:switchTab(tabType)
    end
end

function acMineExploreDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
    if self.infoPage then
        if tabType==1 then
            self.infoPage:setVisible(true)
        else
            self.infoPage:setVisible(false)
        end
    end
   	if self["exploreTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acMineExploreLottery:new()
	   	else
	   		tab=acMineExploreShop:new()
	   	end
	   	self["exploreTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["exploreTab"..tabType].updateUI then
                    self["exploreTab"..tabType]:updateUI()
                end
    		end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
end

function acMineExploreDialog:updateAcTime()
    local acVo=acMineExploreVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end
function acMineExploreDialog:tick()
    self:updateAcTime()
    if acMineExploreVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,3 do
            if self["exploreTab"..i]~=nil and self["exploreTab"..i].tick then
                self["exploreTab"..i]:tick()
            end
        end
    end
end

function acMineExploreDialog:refreshIconTipVisible()
end

function acMineExploreDialog:dispose()
    if self.exploreTab1 then
        self.exploreTab1:dispose()
    end
    if self.exploreTab2 then
        self.exploreTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.exploreTab1=nil
    self.exploreTab2=nil

    self.isEnd=false
    self.infoPage=nil
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acMonthlySign.plist")
    spriteController:removeTexture("public/acMonthlySign.png")
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
end
