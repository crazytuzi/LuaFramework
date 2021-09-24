require "luascript/script/game/scene/gamedialog/platWar/platWarTroopsDialogTab1"
require "luascript/script/game/scene/gamedialog/platWar/platWarTroopsDialogTab2"
require "luascript/script/game/scene/gamedialog/platWar/platWarTroopsDialogTab3"
require "luascript/script/game/scene/gamedialog/platWar/platWarTroopsDialogTab4"
platWarTroopsDialog=commonDialog:new()

function platWarTroopsDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tab1=nil
    self.tab2=nil
    self.tab3=nil
    self.tab4=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    self.layerTab4=nil
    self.tipTab={}
    return nc
end

function platWarTroopsDialog:resetTab()
    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        if #self.allTabs==4 then
            tabBtnItem:setPosition(ccp((k-1)*(tabBtnItem:getContentSize().width+15.5)+tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-85-tabHeight))
        else
            if index==0 then
                tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
            elseif index==1 then
                tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
            elseif index==2 then
                tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
            end
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1

        local tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
        tipSp:setAnchorPoint(CCPointMake(1,1))
        tipSp:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height))
        tabBtnItem:addChild(tipSp,5)
        table.insert(self.tipTab,tipSp)
        tipSp:setVisible(false)
    end
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-155))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,25))
    -- 清除临时选择的军徽
    if base.emblemSwitch==1 then
        emblemVoApi:setTmpEquip(nil)
    end
    -- 清除临时选择的飞机
    if base.plane==1 then
        planeVoApi:setTmpEquip(nil)
    end
end

function platWarTroopsDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType(idx+1)
end

function platWarTroopsDialog:getDataByType(type)
    if(type==nil)then
        type=1
    end
    if(type==1)then
        if(self.tab1==nil)then
            local function getInfoHandler()
                self.tab1=platWarTroopsDialogTab1:new()
                self.layerTab1=self.tab1:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab1)
                if(self.selectedTabIndex==0)then
                    self:switchTab(1)
                end
            end
            platWarVoApi:getInfo(getInfoHandler)
        else
            self:switchTab(1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
            local function getInfoHandler()
                self.tab2=platWarTroopsDialogTab2:new()
                self.layerTab2=self.tab2:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab2)
                if(self.selectedTabIndex==1)then
                    self:switchTab(2)
                end
            end
            platWarVoApi:getInfo(getInfoHandler)
        else
            self:switchTab(2)
        end
    elseif(type==3)then
        if(self.tab3==nil)then
            local function getInfoHandler()
                self.tab3=platWarTroopsDialogTab3:new()
                self.layerTab3=self.tab3:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab3)
                if(self.selectedTabIndex==2)then
                    self:switchTab(3)
                end
            end
            platWarVoApi:getInfo(getInfoHandler)
        else
            self:switchTab(3)
        end
    elseif(type==4)then
        if(self.tab4==nil)then
            local function getInfoHandler()
                self.tab4=platWarTroopsDialogTab4:new()
                self.layerTab4=self.tab4:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab4)
                if(self.selectedTabIndex==3)then
                    self:switchTab(4)
                end
            end
            platWarVoApi:getInfo(getInfoHandler)
        else
            self:switchTab(4)
        end
    end
end

function platWarTroopsDialog:switchTab(type)
    if type==nil then
        type=1
    end
    for i=1,4 do
        if(i==type)then
            if(self["layerTab"..i]~=nil)then
                self["layerTab"..i]:setPosition(ccp(0,0))
                self["layerTab"..i]:setVisible(true)
            end
            if i==1 then
                for k=2,4 do
                    if self["tab"..k] and self["tab"..k].updateData then
                        self["tab"..k]:updateData()
                    end
                end
            end
            if self["tab"..i] and self["tab"..i].refresh then
                self["tab"..i]:refresh()
            end

            local fleetType = i+19
            if G_editLayer~=nil then
                for k,v in pairs(G_editLayer) do
                    if k==21 or k==22 or k==23 then
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
            if(self["layerTab"..i]~=nil)then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function platWarTroopsDialog:tick()
    -- local warStatus=worldWarVoApi:checkStatus()
    -- if(self.warStatus and self.warStatus>0 and warStatus==0)then
    --  self:close()
    --  do return end
    -- end
    -- self.warStatus=warStatus
    for i=1,4 do
        if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
            self["tab"..i]:tick()
        end
    end
    if platWarVoApi:checkStatus()<30 then
        for k,v in pairs(self.tipTab) do
            if v then
                local tipSp=tolua.cast(v,"CCSprite")
                if tipSp then
                    if k==1 then
                        local fleetIndexTb=tankVoApi:getPlatWarFleetIndexTb()
                        local isSetAll=tankVoApi:platWarIsAllSetFleet()
                        if isSetAll==true and #fleetIndexTb>=3 then
                            tipSp:setVisible(false)
                        else
                            tipSp:setVisible(true)
                        end
                    else
                        local tankId=tankVoApi:getPlatWarTankIdByIndex(k-1)
                        if tankId then
                            tipSp:setVisible(false)
                        else
                            tipSp:setVisible(true)
                        end
                    end
                end
            end
        end
    end
end

function platWarTroopsDialog:dispose()
    -- 清理所有的troopsLayer
    G_editLayer = {}

    for i=1,4 do
        if (self["tab"..i]~=nil and self["tab"..i].dispose) then
            self["tab"..i]:dispose()
        end
    end
    self.tipTab={}
    self.tab1=nil
    self.tab2=nil
    self.tab3=nil
    self.tab4=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    self.layerTab4=nil
end