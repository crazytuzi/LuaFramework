acBenfuqianxianDialog=commonDialog:new()

function acBenfuqianxianDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        bfqxTab1=nil,
        bfqxTab2=nil,
        isEnd=false,
    }
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function acBenfuqianxianDialog:resetTab()
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

function acBenfuqianxianDialog:resetForbidLayer()
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

function acBenfuqianxianDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX((G_VisibleSizeWidth-45)/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-190)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,30)
    -- blueBg:setOpacity(100)
    self.bgLayer:addChild(blueBg)
    -- self.isEnd=acBenfuqianxianVoApi:acIsStop()
end

function acBenfuqianxianDialog:tabClick(idx,isEffect)
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

function acBenfuqianxianDialog:hideTabAll()
    for i=1,2 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acBenfuqianxianDialog:getDataByType(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    -- if tabType==2 then
    --     local function listCallback()
    --         self:switchTab(tabType)
    --     end
    --     acBenfuqianxianVoApi:rechargeBagRequest("ranklist",nil,listCallback)
    -- else
        self:switchTab(tabType)
    -- end
end

function acBenfuqianxianDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["bfqxTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acBenfuqianxianTab1:new()
	   	elseif(tabType==2)then
	   		tab=acBenfuqianxianTab2:new()
	   	end
        if tab then
            self["bfqxTab"..tabType]=tab
            self["layerTab"..tabType]=tab:init(self.layerNum,self)
            self.bgLayer:addChild(self["layerTab"..tabType],1)
        end
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
    		end

            if self["bfqxTab"..i].updateUI then
                self["bfqxTab"..i]:updateUI()
            end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
end


function acBenfuqianxianDialog:tick()
    if acBenfuqianxianVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,2 do
            if self["bfqxTab"..i]~=nil and self["bfqxTab"..i].tick then
                self["bfqxTab"..i]:tick()
            end
        end
    end
end

-- function acBenfuqianxianDialog:refreshIconTipVisible()
--     if acBenfuqianxianVoApi:acIsStop() == true then
--         local canReward1 = acBenfuqianxianVoApi:canRankReward(1)
--         local canReward2 = acBenfuqianxianVoApi:canRankReward(2)
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

function acBenfuqianxianDialog:dispose()
    if self.bfqxTab1 then
        self.bfqxTab1:dispose()
    end
    if self.bfqxTab2 then
        self.bfqxTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.bfqxTab1=nil
    self.bfqxTab2=nil
    self.isEnd=false
end
