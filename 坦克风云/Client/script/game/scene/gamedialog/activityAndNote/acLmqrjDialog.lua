acLmqrjDialog=commonDialog:new()

function acLmqrjDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

	self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

    return nc
end

function acLmqrjDialog:resetTab()
	self.panelLineBg:setVisible(false)
	self.panelTopLine:setVisible(true)

	local index=0
	for k,v in pairs(self.allTabs) do
		 local  tabBtnItem=v
		 if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		else
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		 end
		 if index==self.selectedTabIndex then
			 tabBtnItem:setEnabled(false)
		 end
		 index=index+1
	end
	self.selectedTabIndex=0

	acLmqrjVoApi:checkIsToday()
end

function acLmqrjDialog:initTableView()
	self:tabClick(0)
end

function acLmqrjDialog:tabClick(idx)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(idx+1)
end

function acLmqrjDialog:switchTab(type)
	if type==nil then
		type=1
	end
	if self["tab"..type]==nil then
   		local tab
   		if(type==1)then
   			tab=acLmqrjTabOne:new(self.layerNum)
   		else
   			tab=acLmqrjTabTwo:new(self.layerNum)
   		end
	   	self["tab"..type]=tab
	   	self["layerTab"..type]=tab:init()
	   	self.bgLayer:addChild(self["layerTab"..type])
   	end
	for i=1,2 do
		local _pos=ccp(999333,0)
		local _visible=false
		if(i==type)then
			_pos=ccp(0,0)
			_visible=true
		end
		if(self["layerTab"..i]~=nil)then
			self["layerTab"..i]:setPosition(_pos)
			self["layerTab"..i]:setVisible(_visible)
		end
	end
end

function acLmqrjDialog:doUserHandler()
end

function acLmqrjDialog:tick()
	if self then
		local vo=acLmqrjVoApi:getAcVo()
		if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
	    else
	    	for k,v in pairs(self.allTabs) do
	    		local tipSp=tolua.cast(v:getChildByTag(101),"CCSprite")
	    		tipSp:setVisible(acLmqrjVoApi:checkIsAward(v:getTag()))
	    	end
			if self.tab1 and self.tab1.tick then
				self.tab1:tick()
			end
			if self.tab2 and self.tab2.tick then
				self.tab2:tick()
			end
		end
	end
end

function acLmqrjDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then
		self.tab2:dispose()
	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
	self=nil
end