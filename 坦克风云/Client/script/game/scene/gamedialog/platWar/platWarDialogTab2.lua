platWarDialogTab2={}

function platWarDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.subTabs={}
    self.tab1=nil
    self.layerTab1=nil
    self.tab2=nil
    self.layerTab2=nil
    self.curTab=1

    return nc
end

function platWarDialogTab2:init(layerNum,parent)
    require "luascript/script/game/scene/gamedialog/platWar/platWarDialogSubTab21"
    require "luascript/script/game/scene/gamedialog/platWar/platWarDialogSubTab22"
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initSubTab()
    return self.bgLayer
end

function platWarDialogTab2:initSubTab()
    local tabStr={getlocal("plat_war_sub_title21"),getlocal("plat_war_sub_title22")}
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

    local function showInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local tabStr={"\n",getlocal("plat_war_donate_tip"),"\n"};
        local tabColor={nil,G_ColorYellow,nil}
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.55)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,self.bgLayer:getContentSize().height-187))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn)

    self:switchSubTab(1,false)
end

function platWarDialogTab2:switchSubTab(type,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    if type==nil then
        type=1
    end

    self:realSwitchSubTab(type)
end
function platWarDialogTab2:realSwitchSubTab(type)
    for k,v in pairs(self.subTabs) do
        if k==type then
            v:setEnabled(false)
            self.curTab=type
        else
            v:setEnabled(true)
        end
    end

    if(type==1)then
        if(self.tab1==nil)then
            self.tab1=platWarDialogSubTab21:new()
            self.layerTab1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1,1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
            self.tab2=platWarDialogSubTab22:new()
            self.layerTab2=self.tab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2,1)
        end
    end

    for i=1,2 do
        if self["layerTab"..i] then
            if i==type then
                self["layerTab"..i]:setPositionX(0)
                self["layerTab"..i]:setVisible(true)
            else
                self["layerTab"..i]:setPositionX(999333)
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function platWarDialogTab2:refresh()

end

function platWarDialogTab2:tick()
    for i=1,2 do
        if self["tab"..i]~=nil and self["tab"..i].tick then
            self["tab"..i]:tick()
        end
    end
end

function platWarDialogTab2:dispose()
    if(self.tab1)then
        self.tab1:dispose()
    end
    if(self.tab2)then
        self.tab2:dispose()
    end
    self.subTabs={}
    self.tab1=nil
    self.layerTab1=nil
    self.tab2=nil
    self.layerTab2=nil
    self.curTab=1
end
