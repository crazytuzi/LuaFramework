acChristmasFightDialog=commonDialog:new()

function acChristmasFightDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.dialogTab1=nil
    self.dialogTab2=nil
    self.dialogTab3=nil
    
    return nc
end

--设置或修改每个Tab页签
function acChristmasFightDialog:resetTab()
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
    self.selectedTabIndex=0
end

function acChristmasFightDialog:initTableView()
    local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,G_VisibleSizeHeight),nil)

    -- self:switchTab(1)

    -- self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight - 395 + 50))
    -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
end

function acChristmasFightDialog:tabClickColor(idx)

end

--点击tab页签 idx:索引
function acChristmasFightDialog:tabClick(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
            self:getDataByType(idx+1)
        else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
        end
    end

end

function acChristmasFightDialog:getDataByType(type)
    if type==nil then
        type=1
    end
    if type==1 then
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
        if self.dialogTab1==nil then
            local function callback()
                self.dialogTab1=acChristmasFightTab1:new()
                self.layerTab1=self.dialogTab1:init(self.layerNum,0,self)
                self.bgLayer:addChild(self.layerTab1)
            end
            acChristmasFightVoApi:updateActiveData("get",nil,callback)
        elseif self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
            self:refresh(1)
        end
    elseif type==2 then
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
        local function callback()
            if self.dialogTab2==nil then
                self.dialogTab2=acChristmasFightTab2:new()
                self.layerTab2=self.dialogTab2:init(self.layerNum,1,self)
                self.bgLayer:addChild(self.layerTab2)
                self:refresh(2)
            elseif self.layerTab2 then
                self.layerTab2:setPosition(ccp(0,0))
                self.layerTab2:setVisible(true)
                self:refresh(2)
            end
        end
        acChristmasFightVoApi:updateActiveData("rank",1,callback)
    elseif type==3 then
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        local function callback()
            if self.dialogTab3==nil then
                self.dialogTab3=acChristmasFightTab3:new()
                self.layerTab3=self.dialogTab3:init(self.layerNum,2,self)
                self.bgLayer:addChild(self.layerTab3)
                self:refresh(3)
            elseif self.layerTab3 then
                self.layerTab3:setPosition(ccp(0,0))
                self.layerTab3:setVisible(true)
                self:refresh(3)
            end
        end
        acChristmasFightVoApi:updateActiveData("rank",2,callback)
    end
end


function acChristmasFightDialog:tick()
    local vo=acChristmasFightVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    for i=1,3 do
        if self["dialogTab"..i] and self["dialogTab"..i].tick then
            self["dialogTab"..i]:tick()
        end
    end
end

function acChristmasFightDialog:refresh(type)
    if self~=nil then
        if type==nil then
            for i=1,3 do
                if self["dialogTab"..i] and self["dialogTab"..i].refresh then
                    self["dialogTab"..i]:refresh()
                end
            end
        else
            if type and self["dialogTab"..type] and self["dialogTab"..type].refresh then
                self["dialogTab"..type]:refresh()
            end
        end
    end
end

function acChristmasFightDialog:dispose()
    for i=1,3 do
        if self["dialogTab"..i] and self["dialogTab"..i].dispose then
            self["dialogTab"..i]:dispose()
        end
    end

    self.bgLayer=nil
    self.layerNum=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil

    self.dialogTab1=nil
    self.dialogTab2=nil
    self.dialogTab3=nil
end