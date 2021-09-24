serverWarLocalTroopsTab1={}

function serverWarLocalTroopsTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.subTabs={}
    self.tab1=nil
    self.layerTab1=nil
    self.tab2=nil
    self.layerTab2=nil
    self.tab3=nil
    self.layerTab3=nil
    self.curTab=1

    return nc
end

function serverWarLocalTroopsTab1:init(layerNum,parent)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalTroopsSubTab11"
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalTroopsSubTab12"
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalTroopsSubTab13"
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initSubTab()
    return self.bgLayer
end

function serverWarLocalTroopsTab1:initSubTab()
    local tabStr={getlocal("serverWarLocal_troops_1"),getlocal("serverWarLocal_troops_2"),getlocal("serverWarLocal_troops_3")}
    for k,v in pairs(tabStr) do
        local subTabBtn=CCMenu:create()
        local subTabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
        subTabItem:setAnchorPoint(ccp(0,0))
        local function tabSubClick(idx)
            return self:switchSubTab(idx,true)
        end
        subTabItem:registerScriptTapHandler(tabSubClick)
        local lb=GetTTFLabelWrap(v,20,CCSizeMake(subTabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(CCPointMake(subTabItem:getContentSize().width/2,subTabItem:getContentSize().height/2))
        subTabItem:addChild(lb)
        self.subTabs[k]=subTabItem
        subTabBtn:addChild(subTabItem)
        subTabItem:setTag(k)
        subTabBtn:setPosition(ccp((k-1)*(subTabItem:getContentSize().width+9)+30,self.bgLayer:getContentSize().height-210))
        subTabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(subTabBtn)
    end
    self:switchSubTab(1)
end

function serverWarLocalTroopsTab1:switchSubTab(type,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    if type==nil then
        type=1
    end
    for k,v in pairs(self.subTabs) do
        if k==type then
            v:setEnabled(false)
            self.curTab=type
        else
            v:setEnabled(true)
        end
    end

    if(type==1)then
        -- local function callback1()
            if(self.tab1==nil)then
                self.tab1=serverWarLocalTroopsSubTab11:new()
                self.layerTab1=self.tab1:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab1,1)
            end
        -- end
        -- platWarVoApi:getShopInfo(callback1)
    elseif(type==2)then
        -- local function callback2()
            if(self.tab2==nil)then
                self.tab2=serverWarLocalTroopsSubTab12:new()
                self.layerTab2=self.tab2:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab2,1)
            end
        -- end
        -- platWarVoApi:getShopInfo(callback2)
    elseif(type==3)then
        -- local function callback3()
            if(self.tab3==nil)then
                self.tab3=serverWarLocalTroopsSubTab13:new()
                self.layerTab3=self.tab3:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab3,1)
            end
        -- end
        -- worldWarVoApi:formatPointDetail(callback3)
    end

    for i=1,3 do
        if self["layerTab"..i] then
            if i==type then
                self["layerTab"..i]:setPositionX(0)
                self["layerTab"..i]:setVisible(true)
                if self["tab"..i] and self["tab"..i].refresh then
                    self["tab"..i]:refresh()
                end
            else
                self["layerTab"..i]:setPositionX(999333)
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function serverWarLocalTroopsTab1:tick()
    for i=1,3 do
        if self["tab"..i]~=nil and self["tab"..i].tick then
            self["tab"..i]:tick()
        end
    end
end

function serverWarLocalTroopsTab1:refresh()
    if self.curTab and self["tab"..self.curTab]~=nil and self["tab"..self.curTab].refresh then
        self["tab"..self.curTab]:refresh()
    end
end

function serverWarLocalTroopsTab1:dispose()
    if(self.tab1)then
        self.tab1:dispose()
    end
    if(self.tab2)then
        self.tab2:dispose()
    end
    if(self.tab3)then
        self.tab3:dispose()
    end
    self.subTabs={}
    self.tab1=nil
    self.layerTab1=nil
    self.tab2=nil
    self.layerTab2=nil
    self.tab3=nil
    self.layerTab3=nil
    self.curTab=1
end
