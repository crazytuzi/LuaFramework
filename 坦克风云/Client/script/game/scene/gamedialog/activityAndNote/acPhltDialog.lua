acPhltDialog=commonDialog:new()

function acPhltDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        phltTab1=nil,
        phltTab1=nil,

        isEnd=false,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acPhltDialog:resetTab()
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
    self.isEnd=acPhltVoApi:isEnd()
    self:tabClick(0,false)
end

function acPhltDialog:tabClick(idx,isEffect)
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

function acPhltDialog:hideTabAll()
    for i=1,2 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function acPhltDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["phltTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acPhltLottery:new()
	   	elseif(tabType==2)then
	   		tab=acPhltShop:new()
	   	end
	   	self["phltTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["phltTab"..tabType].updateUI then
                    self["phltTab"..tabType]:updateUI()
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

function acPhltDialog:initTableView()
    self:refreshIconTipVisible()
    local function refreshTip(event,data)
        self:refreshIconTipVisible()
    end
    self.tipListener=refreshTip
    eventDispatcher:addEventListener("phlt.refreshTip",self.tipListener)
end

function acPhltDialog:refreshIconTipVisible()
    if acPhltVoApi:isEnd()==false then
        local flag=acPhltVoApi:canExchange(true)
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

function acPhltDialog:tick()
    if acPhltVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,2 do
            if self["phltTab"..i]~=nil and self["phltTab"..i].tick then
                self["phltTab"..i]:tick()
            end
        end
    end
end

function acPhltDialog:dispose()
    if self.phltTab1 then
        self.phltTab1:dispose()
    end
    if self.phltTab2 then
        self.phltTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.phltTab1=nil
    self.phltTab2=nil

    self.isEnd=false

    eventDispatcher:removeEventListener("phlt.refreshTip",self.tipListener)
    self.tipListener=nil
end
