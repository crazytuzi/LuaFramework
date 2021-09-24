acRechargeBagDialog=commonDialog:new()

function acRechargeBagDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        rechargeTab1=nil,
        rechargeTab2=nil,
        isEnd=false,
    }
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function acRechargeBagDialog:resetTab()
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

function acRechargeBagDialog:resetForbidLayer()
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

function acRechargeBagDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.isEnd=acRechargeBagVoApi:acIsStop()
end

function acRechargeBagDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self:getDataByType(idx+1)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
end

function acRechargeBagDialog:hideTabAll()
    for i=1,2 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acRechargeBagDialog:getDataByType(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    if tabType==2 then
        local function listCallback()
            self:switchTab(tabType)
        end
        acRechargeBagVoApi:rechargeBagRequest("ranklist",nil,listCallback)
    else
        self:switchTab(tabType)
    end
end

function acRechargeBagDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["rechargeTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acRechargeBagTab1:new()
	   	elseif(tabType==2)then
	   		tab=acRechargeBagTab2:new()
	   	end
        if tab then
            self["rechargeTab"..tabType]=tab
            self["layerTab"..tabType]=tab:init(self.layerNum,self)
            self.bgLayer:addChild(self["layerTab"..tabType])
        end
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
    		end

            if self["rechargeTab"..i].updateUI then
                self["rechargeTab"..i]:updateUI()
            end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
end


function acRechargeBagDialog:tick()
    if acRechargeBagVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,2 do
            if self["rechargeTab"..i]~=nil and self["rechargeTab"..i].tick then
                self["rechargeTab"..i]:tick()
            end
        end
    end

    if self.isEnd~=acRechargeBagVoApi:acIsStop() then
        self.isEnd=acRechargeBagVoApi:acIsStop()
        if self.isEnd==true then
            local function listCallback()
                acRechargeBagVoApi:setFlag(2,0)
            end
            acRechargeBagVoApi:rechargeBagRequest("ranklist",nil,listCallback)
        end
    end
end

-- function acRechargeBagDialog:refreshIconTipVisible()
--     if acRechargeBagVoApi:acIsStop() == true then
--         local canReward1 = acRechargeBagVoApi:canRankReward(1)
--         local canReward2 = acRechargeBagVoApi:canRankReward(2)
--         if canReward1 == false and canReward2 == false then
--             if self.setIconTipVisibleByIdx then
--                 self:setIconTipVisibleByIdx(false,2)
--             end
--         else
--             if self.setIconTipVisibleByIdx then
--                 self:setIconTipVisibleByIdx(true,2)
--             end
--         end
--     end
-- end

function acRechargeBagDialog:dispose()
    if self.rechargeTab1 then
        self.rechargeTab1:dispose()
    end
    if self.rechargeTab2 then
        self.rechargeTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.rechargeTab1=nil
    self.rechargeTab2=nil
    self.isEnd=false
end
