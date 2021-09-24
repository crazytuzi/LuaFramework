
serverWarLocalAgainstRankDialog=commonDialog:new()

function serverWarLocalAgainstRankDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")

    return nc
end

function serverWarLocalAgainstRankDialog:resetTab()
    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight - 158)
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
    self.selectedTabIndex = 0
 --    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	-- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function serverWarLocalAgainstRankDialog:initTableView()
    local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-175),nil)
    self.tv:setPosition(5, 0)
  
    self:tabClick(0,false)
end

function serverWarLocalAgainstRankDialog:tabClick(idx,isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    if(idx==0)then
        if(self.acTab1==nil)then     
            self.acTab1=serverWarLocalAgainstRankTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum)
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
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
    elseif(idx==1)then
    	if(self.acTab2==nil)then     
            self.acTab2=serverWarLocalAgainstRankTab2:new()
            self.layerTab2=self.acTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
    elseif(idx==2)then
    	if(self.acTab3==nil)then     
            local personalListFlag=serverWarLocalVoApi:getPersonalListFlag()
            local function callback()
                self.acTab3=serverWarLocalAgainstRankTab3:new()
                self.layerTab3=self.acTab3:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab3)
            end
            if (serverWarLocalVoApi:checkStatus()>=20 and serverWarLocalVoApi:checkStatus()<30) and serverWarLocalVoApi:isEndOfoneBattle() and personalListFlag[1]==0 then
                serverWarLocalVoApi:getPersonalList(1,callback)
            elseif serverWarLocalVoApi:checkStatus()==30 and personalListFlag[2]==0 then
                serverWarLocalVoApi:getPersonalList(1,callback)
            else
                callback()
            end
           

        end
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(0,0))
            self.layerTab3:setVisible(true)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
    end
end

function serverWarLocalAgainstRankDialog:tick()
    for i=1,3 do
        if self["acTab" .. i] then
            self["acTab" .. i]:tick()
        end
    end
end
function serverWarLocalAgainstRankDialog:refresh( tab )
    -- if tab ==1 then
    --     if self.acTab2 then
    --         self.acTab2:refresh()
    --     end
    -- end
    --  if tab ==2 then
    --     if self.acTab1 then
    --         self.acTab1:refresh()
    --     end
    -- end
end
function serverWarLocalAgainstRankDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
     if self.layerTab3 then
        self.acTab3:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/slotMachine.plist")
    
end

