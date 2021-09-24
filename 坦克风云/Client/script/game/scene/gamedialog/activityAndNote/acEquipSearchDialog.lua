acEquipSearchDialog=commonDialog:new()

function acEquipSearchDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.equipSearchTab1=nil
    self.equipSearchTab2=nil

    self.isStop=false
    self.isToday=true

    return nc
end

--设置或修改每个Tab页签
function acEquipSearchDialog:resetTab()
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
    self.selectedTabIndex = 0
end

function acEquipSearchDialog:initTableView()
    local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
    self:switchTab(1)
end

function acEquipSearchDialog:hideTabAll()
    if self.layerTab1 then
        self.layerTab1:setPosition(ccp(999333,0))
        self.layerTab1:setVisible(false)
    end
    if self.layerTab2 then
        self.layerTab2:setPosition(ccp(999333,0))
        self.layerTab2:setVisible(false)
    end
end

function acEquipSearchDialog:getDataByType(type)
    if type==nil then
        type=1
    end

    -- local rankList=acEquipSearchVoApi:getRankList()
    -- local flag=-1
    -- if (rankList and SizeOfTable(rankList)>0) then
    --     flag=1
    -- end
    local function equipsearchListCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if self and self.bgLayer then
                local rankList
                if sData.data and sData.data.equipSearch and sData.data.equipSearch.rankList then
                    rankList=sData.data.equipSearch
                    acEquipSearchVoApi:updateData(rankList)
                    self:switchTab(type)
                    self:refresh(type)

                    -- acEquipSearchVoApi:setLastListTime(base.serverTime)
                    acEquipSearchVoApi:setFlag(2,1)
                end
            end
        end
    end
    -- if type==2 and flag==-1 then
    if type==2 and acEquipSearchVoApi:getFlag(2)==-1 then
        acEquipSearchVoApi:clearRankList()
        self:hideTabAll()
        socketHelper:activeEquipsearch(2,equipsearchListCallback)
    else
        if self and self.bgLayer then
            self:switchTab(type)
        end
    end

end

function acEquipSearchDialog:tabClickColor(idx)

end

--点击tab页签 idx:索引
function acEquipSearchDialog:tabClick(idx)
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

function acEquipSearchDialog:switchTab(type)
    if type==nil then
        type=1
    end
    if type==1 then
        if self.equipSearchTab1==nil then
            self.equipSearchTab1=acEquipSearchTab1:new(self)
            self.layerTab1=self.equipSearchTab1:init(self.layerNum,0,self)
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
    elseif type==2 then
        if self.equipSearchTab2==nil then
            self.equipSearchTab2=acEquipSearchTab2:new(self)
            self.layerTab2=self.equipSearchTab2:init(self.layerNum,1,self)
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
    end
end


function acEquipSearchDialog:tick()
    local vo=acEquipSearchVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    local isSearchToday=acEquipSearchVoApi:isSearchToday()
    local acIsStop=acEquipSearchVoApi:acIsStop()

    if self.isStop~=acIsStop or self.isToday~=isSearchToday then
        self:refresh()
        self.isStop=acIsStop
        self.isToday=isSearchToday
    end

    if self and self.equipSearchTab1 and self.equipSearchTab1.tick then
        self.equipSearchTab1:tick()
    end
end

function acEquipSearchDialog:refresh(type)
    if self~=nil then
        if type==nil then
            if self.equipSearchTab1 then
                self.equipSearchTab1:refresh()
            end
            if self.equipSearchTab2 then
                self.equipSearchTab2:refresh()
            end
        else
            if type==1 and self.equipSearchTab1 then
                self.equipSearchTab1:refresh()
            elseif type==2 and self.equipSearchTab2 then
                self.equipSearchTab2:refresh()
            end
        end
    end
end

function acEquipSearchDialog:dispose()
    if self.equipSearchTab1 then
        self.equipSearchTab1:dispose()
    end
    if self.equipSearchTab2 then
        self.equipSearchTab2:dispose()
    end

    self.bgLayer=nil
    self.layerNum=nil
    self.layerTab1=nil
    self.layerTab2=nil

    self.equipSearchTab1=nil
    self.equipSearchTab2=nil

    self.isStop=nil
    self.isToday=nil
    self=nil
end