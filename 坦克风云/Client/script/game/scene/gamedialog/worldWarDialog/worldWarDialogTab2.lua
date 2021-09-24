worldWarDialogTab2={}

function worldWarDialogTab2:new()
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
    self.tab4=nil
    self.layerTab4=nil
    self.curTab=1

    return nc
end

function worldWarDialogTab2:init(layerNum,parent)
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab21"
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab22"
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab23"
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogSubTab24"
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initSubTab()
    return self.bgLayer
end

function worldWarDialogTab2:initSubTab()
    local tabStr={getlocal("world_war_sub_title21"),getlocal("world_war_sub_title22"),getlocal("world_war_sub_title23"),getlocal("world_war_sub_title24")}
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
    self:switchSubTab(1,false)
end

function worldWarDialogTab2:switchSubTab(type,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    if type==nil then
        type=1
    end

    if self.curTab~=type and self.curTab>1 and self["tab"..self.curTab] and self["tab"..self.curTab].isChangeFleet then
        local selectIdx=self.curTab-1
        local isCanSetFleet=worldWarVoApi:getIsCanSetFleet(selectIdx,self.layerNum,false)
        local isChangeFleet,costTanks=self["tab"..self.curTab]:isChangeFleet()
        print("isCanSetFleet",isCanSetFleet)
        print("isChangeFleet",isChangeFleet)
        if isCanSetFleet==true and isChangeFleet==true then
            local function onConfirm()
                local function saveBack()
                    self:realSwitchSubTab(type)
                end
                self["tab"..self.curTab]:saveHandler(saveBack)
            end
            local function onCancle()
                self:realSwitchSubTab(type)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("world_war_set_changed_fleet"),nil,self.layerNum+1,nil,nil,onCancle)
        else
            self:realSwitchSubTab(type)
        end
    else
        self:realSwitchSubTab(type)
    end
end
function worldWarDialogTab2:realSwitchSubTab(type)
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
            self.tab1=worldWarDialogSubTab21:new()
            self.layerTab1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1,1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
            self.tab2=worldWarDialogSubTab22:new()
            self.layerTab2=self.tab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2,1)
        end
    elseif(type==3)then
        if(self.tab3==nil)then
            self.tab3=worldWarDialogSubTab23:new()
            self.layerTab3=self.tab3:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab3,1)
        end
    elseif(type==4)then
        if(self.tab4==nil)then
            self.tab4=worldWarDialogSubTab24:new()
            self.layerTab4=self.tab4:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab4,1)
        end
    end

    for i=1,4 do
        if self["layerTab"..i] then
            if i==type then
                self["layerTab"..i]:setPositionX(0)
                self["layerTab"..i]:setVisible(true)
                if i==1 then
                    for i=1,4 do
                        if self["tab"..i] and self["tab"..i].updateData then
                            self["tab"..i]:updateData()
                        end
                    end
                    -- if self["tab"..i] and self["tab"..i].updateData then
                    --     self["tab"..i]:updateData()
                    -- end
                    if self["tab"..i] and self["tab"..i].updateProperty then
                        self["tab"..i]:updateProperty()
                    end
                end
                if self["tab"..i] and self["tab"..i].refresh then
                    self["tab"..i]:refresh()
                end

                local fleetType = i+11
                if G_editLayer~=nil then
                    for k,v in pairs(G_editLayer) do
                        if k==13 or k==14 or k==15 then
                            if v.clayer~=nil then
                                if fleetType==k then
                                    v.clayer:setTouchEnabled(true)
                                else
                                    v.clayer:setTouchEnabled(false)
                                end
                            end
                        end
                    end
                end
            else
                self["layerTab"..i]:setPositionX(999333)
                self["layerTab"..i]:setVisible(false)
            end
        end
    end

    -- if self.parent then
    --  self.parent.selectSubTab3=type
    --  if self.parent.resetForbidLayer then
    --      self.parent:resetForbidLayer()
    --  end
    -- end
end

function worldWarDialogTab2:refresh()
    -- for i=2,4 do
    --     if self["tab"..i] then
    --         if self["tab"..i]["worldWarEmblem"..(i-1)] then
    --             self["tab"..i]["worldWarEmblem"..(i-1)]=nil
    --         end
    --         if self["tab"..i].refresh then
    --             self["tab"..i]:refresh(true)
    --         end
    --     end
    -- end
end

function worldWarDialogTab2:tick()
    for i=1,4 do
        if self["tab"..i]~=nil and self["tab"..i].tick then
            self["tab"..i]:tick()
        end
    end
end

function worldWarDialogTab2:dispose()
    -- 清理所有的troopsLayer
    G_editLayer = {}

    if(self.tab1)then
        self.tab1:dispose()
    end
    if(self.tab2)then
        self.tab2:dispose()
    end
    if(self.tab3)then
        self.tab3:dispose()
    end
    if(self.tab4)then
        self.tab4:dispose()
    end
    self.subTabs={}
    self.tab1=nil
    self.layerTab1=nil
    self.tab2=nil
    self.layerTab2=nil
    self.tab3=nil
    self.layerTab3=nil
    self.tab4=nil
    self.layerTab4=nil
    self.curTab=1
    heroVoApi:clearTroops()
end
