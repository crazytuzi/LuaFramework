acRoulette2Dialog=commonDialog:new()

function acRoulette2Dialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.layerTab1=nil
    self.layerTab2=nil
    -- self.layerTab3=nil
    
    self.rouletteTab1=nil
    self.rouletteTab2=nil
    -- self.rouletteTab3=nil

    self.canClickTab=true
    self.isStop=false

    return nc
end

--设置或修改每个Tab页签
function acRoulette2Dialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         -- if index==0 then
         -- tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         -- elseif index==1 then
         -- tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         -- elseif index==2 then
         -- tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)

         -- end

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
    self.selectedTabIndex = 0
end

function acRoulette2Dialog:initTableView()
    local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
    self:switchTab(1)
end

function acRoulette2Dialog:hideTabAll()
    if self.layerTab1 then
        self.layerTab1:setPosition(ccp(999333,0))
        self.layerTab1:setVisible(false)
    end
    if self.layerTab2 then
        self.layerTab2:setPosition(ccp(999333,0))
        self.layerTab2:setVisible(false)
    end
    -- if self.layerTab3 then
    --     self.layerTab3:setPosition(ccp(999333,0))
    --     self.layerTab3:setVisible(false)
    -- end
end

function acRoulette2Dialog:getDataByType(type)
    if type==nil then
        type=1
    end

    local rankList=acRoulette2VoApi:getRankList()
    local flag=-1
    if (rankList and SizeOfTable(rankList)>0) then
        flag=1
    end
    local function activeWheelfortuneCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if self and self.bgLayer then
                local rankList
                if sData.data and sData.data.wheelFortune2 and sData.data.wheelFortune2.rankList then
                    rankList=sData.data.wheelFortune2
                    acRoulette2VoApi:updateData(rankList)
                    self:switchTab(type)
                    self:refresh(type)

                    acRoulette2VoApi:setLastListTime(base.serverTime)
                    acRoulette2VoApi:setFlag(2,1)
                end
            end
        end
    end
    if type==2 and flag==-1 then
        acRoulette2VoApi:clearRankList()
        self:hideTabAll()
        socketHelper:activeWheelfortune2(2,activeWheelfortuneCallback)
    else
        if self and self.bgLayer then
            self:switchTab(type)
        end
    end

end

function acRoulette2Dialog:tabClickColor(idx)

end

--点击tab页签 idx:索引
function acRoulette2Dialog:tabClick(idx)
    if self.selectedTabIndex==0 and self.canClickTab==false then
        do return end
    end
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

function acRoulette2Dialog:switchTab(type)
    if type==nil then
        type=1
    end
    if type==1 then
        if self.rouletteTab1==nil then
            self.rouletteTab1=acRoulette2DialogTab1:new()
            self.layerTab1=self.rouletteTab1:init(self.layerNum,0,self)
            self.bgLayer:addChild(self.layerTab1)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        -- if self.layerTab3 then
        --     self.layerTab3:setPosition(ccp(999333,0))
        --     self.layerTab3:setVisible(false)
        -- end
    elseif type==2 then
        if self.rouletteTab2==nil then
            self.rouletteTab2=acRoulette2DialogTab2:new(self)
            self.layerTab2=self.rouletteTab2:init(self.layerNum,1,self)
            self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
        end
    --     if self.layerTab3 then
    --         self.layerTab3:setPosition(ccp(999333,0))
    --         self.layerTab3:setVisible(false)
    --     end
    -- elseif type==3 then
    --     if self.rouletteTab3==nil then
    --         self.rouletteTab3=acRoulette2DialogTab3:new(self)
    --         self.layerTab3=self.rouletteTab3:init(self.layerNum,2,self)
    --         self.bgLayer:addChild(self.layerTab3)
    --     end
    --     if self.layerTab1 then
    --         self.layerTab1:setPosition(ccp(999333,0))
    --         self.layerTab1:setVisible(false)
    --     end
    --     if self.layerTab2 then
    --         self.layerTab2:setPosition(ccp(999333,0))
    --         self.layerTab2:setVisible(false)
    --     end
    --     if self.layerTab3 then
    --         self.layerTab3:setPosition(ccp(0,0))
    --         self.layerTab3:setVisible(true)
    --     end
    end
end


function acRoulette2Dialog:tick()
    local vo=acRoulette2VoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    local isRouletteToday=acRoulette2VoApi:isRouletteToday()
    if self.rouletteTab2 and self.selectedTabIndex==1 then
        local vo=acRoulette2VoApi:getAcVo()
        local lastTs=acRoulette2VoApi:getLastListTime()
        if activityVoApi:isStart(vo) and lastTs<=(vo.et-24*3600) and (base.serverTime>lastTs+10*60 or base.serverTime>vo.et-24*3600) then
            local function activeWheelfortuneCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if self and self.bgLayer then
                        local rankList
                        if sData.data and sData.data.wheelFortune2 and sData.data.wheelFortune2.rankList then
                            acRoulette2VoApi:clearRankList()

                            rankList=sData.data.wheelFortune2
                            acRoulette2VoApi:updateData(rankList)
                            -- self:switchTab(type)
                            self:refresh(2)

                            acRoulette2VoApi:setLastListTime(base.serverTime)
                            -- acRoulette2VoApi:setFlag(2,1)
                        end
                    end
                end
            end
            socketHelper:activeWheelfortune2(2,activeWheelfortuneCallback)
        end
    end

    if self.isStop~=acRoulette2VoApi:acIsStop() then
        acRoulette2VoApi:setFlag(i,0)
        self.isStop=acRoulette2VoApi:acIsStop()
    end

    for i=1,3 do
        if acRoulette2VoApi:getFlag(i)==0 then
            self:refresh(i)
            acRoulette2VoApi:setFlag(i,1)
        end
    end

    if self.rouletteTab1 then
        self.rouletteTab1:subtick()
    end
    if self.rouletteTab2 then
        self.rouletteTab2:subtick()
    end
    -- if self.rouletteTab3 then
    --     self.rouletteTab3:subtick()
    -- end

end
function acRoulette2Dialog:fastTick( )
    if self.rouletteTab1 then
        self.rouletteTab1:fastTick()
    end  
end
function acRoulette2Dialog:refresh(type)
    if self~=nil then
        if type==nil then
            if self.rouletteTab1 then
                self.rouletteTab1:refresh()
            end
            if self.rouletteTab2 then
                self.rouletteTab2:refresh()
            end
            -- if self.rouletteTab3 then
            --     self.rouletteTab3:refresh()
            -- end
        else
            if type==1 and self.rouletteTab1 then
                self.rouletteTab1:refresh()
            elseif type==2 and self.rouletteTab2 then
                self.rouletteTab2:refresh()
            -- elseif type==3 and self.rouletteTab3 then
            --     self.rouletteTab3:refresh()
            end
        end
    end
end

function acRoulette2Dialog:dispose()
    if self.rouletteTab1 then
        self.rouletteTab1:dispose()
    end
    if self.rouletteTab2 then
        self.rouletteTab2:dispose()
    end
    -- if self.rouletteTab3 then
    --     self.rouletteTab3:dispose()
    -- end
    self.bgLayer=nil
    self.layerNum=nil
    self.layerTab1=nil
    self.layerTab2=nil
    -- self.layerTab3=nil
    self.rouletteTab1=nil
    self.rouletteTab2=nil
    -- self.rouletteTab3=nil
    self.canClickTab=nil
    self.isStop=nil
    self=nil
end