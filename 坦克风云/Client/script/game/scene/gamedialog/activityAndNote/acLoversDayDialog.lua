require "luascript/script/game/scene/gamedialog/activityAndNote/acLoversDayTab1"
require "luascript/script/game/scene/gamedialog/activityAndNote/acLoversDayTab2"
acLoversDayDialog=commonDialog:new()

function acLoversDayDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        loversDayTab1=nil,
        loversDayTab2=nil,

        isEnd=false,
        infoPage=nil,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acLoversDayDialog:resetTab()--acLoversDay
    spriteController:addPlist("public/acMonthlySign.plist")
    spriteController:addTexture("public/acMonthlySign.png")

    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addTexture("public/blueFilcker.png")

    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")

    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")

    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    -- spriteController:addPlist("public/acMineExplore_images.plist")
    -- spriteController:addTexture("public/acMineExplore_images.png")

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

function acLoversDayDialog:resetForbidLayer()
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

function acLoversDayDialog:initTableView()
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
        local bgH=80
        local infoH=0
        local timeStrH=70
        if G_isIphone5() then
            bgH = 160
        end
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(60,24,8,2),bgClick)
        backSprie:setContentSize(CCSizeMake(w,bgH))
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setOpacity(0)
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

        local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
        menuItemDesc:setAnchorPoint(ccp(1,1))
        menuItemDesc:setScale(0.8)
        local menuDesc=CCMenu:createWithItem(menuItemDesc)
        menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
        menuDesc:setPosition(ccp(w-20,backSprie:getContentSize().height-10-infoH))
        backSprie:addChild(menuDesc)

        local strSize2 = 16
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
            strSize2 = 25
        end
        if G_isIphone5() then
            acLbStr=getlocal("activity_timeLabel")
            descW=w-30
            local acLabel=GetTTFLabel(acLbStr,25)
            backSprie:addChild(acLabel)
            acLabel:setColor(G_ColorGreen)
            local acVo=acLoversDayVoApi:getAcVo()
            local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
            local timeLb=GetTTFLabel(timeStr,25)
            timeLb:setColor(G_ColorGreen)
            backSprie:addChild(timeLb)

            acLabel:setAnchorPoint(ccp(0.5,1))
            acLabel:setPosition(ccp(backSprie:getContentSize().width*0.5, backSprie:getContentSize().height-10))
            timeLb:setAnchorPoint(ccp(0.5,1))
            timeLb:setPosition(ccp(backSprie:getContentSize().width*0.5, backSprie:getContentSize().height-10-acLabel:getContentSize().height))
            timeStrH=acLabel:getContentSize().height+timeLb:getContentSize().height
            
            local topDes = GetTTFLabelWrap(getlocal("activity_loversDay_titleDes"),strSize2,CCSizeMake(backSprie:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
            topDes:setAnchorPoint(ccp(0.5,0))
            topDes:setPosition(ccp(backSprie:getContentSize().width*0.5+10,15))
            backSprie:addChild(topDes)
            -- local desTv,desLabel=G_LabelTableView(CCSizeMake(descW,70),getlocal("activity_loversDay_titleDes"),25,kCCTextAlignmentCenter)
            -- backSprie:addChild(desTv)
            -- desTv:setPosition(ccp(backSprie:getContentSize().width*0.5,8))
            -- desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
            -- desTv:setMaxDisToBottomOrTop(100)
        else
            local acVo=acLoversDayVoApi:getAcVo()
            local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
            local content1 = getlocal("activity_timeLabel").."\n"..timeStr
            local content2 = getlocal("activity_loversDay_titleDes")
            local moveBgStarStr=G_LabelRollView(CCSizeMake(backSprie:getContentSize().width-120,70),content1,strSize2,kCCTextAlignmentCenter,G_ColorYellowPro,nil,content2,G_ColorWhite,2,2,2,nil)
            moveBgStarStr:setPosition(ccp(40,5))
            backSprie:addChild(moveBgStarStr)
        end


    end
    if self.selectedTabIndex==0 then
        initInfo()
    end
end

function acLoversDayDialog:showInfor()
    if self.selectedTabIndex==0 then
        local tabStr={}
        local tabColor={}
        local tabAlignment={}
        tabStr={"\n",getlocal("activity_loversDay_tab1Rule3"),"\n",getlocal("activity_loversDay_tab1Rule2"),"\n",getlocal("activity_loversDay_tab1Rule1"),"\n",getlocal("activityDescription"),"\n"}
        tabColor={nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro,nil}
        tabAlignment={nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
end

function acLoversDayDialog:tabClick(idx,isEffect)
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

function acLoversDayDialog:hideTabAll()
    for i=1,2 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acLoversDayDialog:getDataByIdx(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end

    self:switchTab(tabType)
end

function acLoversDayDialog:switchTab(tabType)
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
   	if self["loversDayTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acLoversDayTab1:new()
	   	else
	   		tab=acLoversDayTab2:new()
	   	end
	   	self["loversDayTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["loversDayTab"..tabType].updateUI then
                    self["loversDayTab"..tabType]:updateUI()
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


function acLoversDayDialog:tick()
    if acLoversDayVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,2 do
            if self["loversDayTab"..i]~=nil and self["loversDayTab"..i].tick then
                self["loversDayTab"..i]:tick()
            end
        end
    end
    if acLoversDayVoApi:isShowTip() ==true then
        self:setIconTipVisibleByIdx(true,2)
    else
        self:setIconTipVisibleByIdx(false,2)
    end
end
function acLoversDayDialog:fastTick()
    if self.loversDayTab1 then
        self.loversDayTab1:fastTick()
    end
end
function acLoversDayDialog:refreshIconTipVisible()
end

function acLoversDayDialog:dispose()

    if self.loversDayTab1 then
        self.loversDayTab1:dispose()
    end
    if self.loversDayTab2 then
        self.loversDayTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.loversDayTab1=nil
    self.loversDayTab2=nil

    self.isEnd=false
    self.infoPage=nil
    spriteController:removePlist("public/acMonthlySign.plist")--acNewYearsEva
    spriteController:removeTexture("public/acMonthlySign.png")
    
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removeTexture("public/blueFilcker.png")

    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")

    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
end
