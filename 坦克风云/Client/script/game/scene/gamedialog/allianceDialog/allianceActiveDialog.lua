allianceActiveDialog=commonDialog:new()

function allianceActiveDialog:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.allianceActiveTab1=nil
    self.allianceActiveTab2=nil

    self.isAtoday=false
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
    return nc
end

function allianceActiveDialog:resetTab()
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
end

function allianceActiveDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)

    local alliance=allianceVoApi:getSelfAlliance()
    self.isAtoday=G_isToday(alliance.apoint_at or 0)
    self:tabClick(0)
end

function allianceActiveDialog:tabClick(idx)
    self:switchTab(idx+1)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
end

function allianceActiveDialog:switchTab(type)
    if type==nil then
      type=1
    end
   	if self["allianceActiveTab"..type]==nil then
   		local tab
   		if(type==1)then
	   		tab=allianceActiveTab1:new()
	   	else
	   		tab=allianceActiveTab2:new()
	   	end
	   	self["allianceActiveTab"..type]=tab
	   	self["layerTab"..type]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..type])
   	end
    for i=1,2 do
    	if(i==type)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
    		end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
end

function allianceActiveDialog:tick()
    if self and self.bgLayer then
        local alliance=allianceVoApi:getSelfAlliance()
        local istoday=G_isToday(alliance.apoint_at or 0)
        if istoday ~= self.isAtoday then
            print("refresh.........")
            if(self.allianceActiveTab1~=nil)then
                self.allianceActiveTab1:refresh()
            end
            if(self.allianceActiveTab2~=nil)then
                self.allianceActiveTab2:refresh()
            end
            self.isAtoday=istoday
        end
    end
end

function allianceActiveDialog:dispose()
    self.layerTab1=nil
    self.layerTab2=nil
    self.bottomforbidSp=nil
    
    if(self.allianceActiveTab1~=nil)then
        self.allianceActiveTab1:dispose()
    end
    self.allianceActiveTab1=nil
    if(self.allianceActiveTab2~=nil)then
        self.allianceActiveTab2:dispose()
    end
    self.allianceActiveTab2=nil

    self=nil
end
