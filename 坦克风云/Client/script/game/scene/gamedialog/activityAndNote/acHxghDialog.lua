acHxghDialog=commonDialog:new()

function acHxghDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        hxghTab1=nil,
        hxghTab1=nil,

        isEnd=false,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acHxghDialog:resetTab()
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
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
    self.isEnd=acHxghVoApi:isEnd()
    self:tabClick(0,false)
end

function acHxghDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    local function realSwitchSubTab()
        for k,v in pairs(self.allTabs) do
            if v:getTag()==idx then
                v:setEnabled(false)
                self.selectedTabIndex=idx
                self:switchTab(idx+1)
            else
                v:setEnabled(true)
            end
        end
    end
    realSwitchSubTab()
end

function acHxghDialog:hideTabAll()
    for i=1,2 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function acHxghDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["hxghTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acHxghLottery:new()
	   	elseif(tabType==2)then
	   		tab=acHxghShop:new()
	   	end
	   	self["hxghTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["hxghTab"..tabType].updateUI then
                    self["hxghTab"..tabType]:updateUI()
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

function acHxghDialog:initTableView()
    self:refreshIconTipVisible()
    local function refreshTip(event,data)
        self:refreshIconTipVisible()
    end
    self.tipListener=refreshTip
    eventDispatcher:addEventListener("hxgh.refreshTip",self.tipListener)
end

function acHxghDialog:refreshIconTipVisible()
    if acHxghVoApi:isEnd()==false then
        local flag=acHxghVoApi:canExchange(true)
        if flag==false then
            if self.setIconTipVisibleByIdx then
                self:setIconTipVisibleByIdx(false,2)
            end
        else
            if self.setIconTipVisibleByIdx then
                self:setIconTipVisibleByIdx(true,2)
            end
        end
    end
end

function acHxghDialog:tick()
    if acHxghVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,2 do
            if self["hxghTab"..i]~=nil and self["hxghTab"..i].tick then
                self["hxghTab"..i]:tick()
            end
        end
    end
end

function acHxghDialog:dispose()
    if self.hxghTab1 then
        self.hxghTab1:dispose()
    end
    if self.hxghTab2 then
        self.hxghTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.hxghTab1=nil
    self.hxghTab2=nil

    self.isEnd=false

    eventDispatcher:removeEventListener("hxgh.refreshTip",self.tipListener)
    self.tipListener=nil
end
