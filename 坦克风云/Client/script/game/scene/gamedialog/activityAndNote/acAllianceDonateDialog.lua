acAllianceDonateDialog=commonDialog:new()

function acAllianceDonateDialog:new(layerNum)
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

function acAllianceDonateDialog:resetTab()
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
end

function acAllianceDonateDialog:initTableView()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end

function acAllianceDonateDialog:tabClick(idx)
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

function acAllianceDonateDialog:switchTab(type)
	if type==nil then
		type=1
	end
   	if self["tab"..type]==nil then
   		local tab
   		if(type==1)then
   			tab=acAllianceDonateDialogTabIntro:new(self)
   		else
   			tab=acAllianceDonateDialogTabRank:new(self)
   		end
	   	self["tab"..type]=tab
	   	self["layerTab"..type]=tab:init(self.layerNum)
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

function acAllianceDonateDialog:doUserHandler()
	base:setWait()
	base:setNetWait()
	local function onGetData()
		if(self and self.bgLayer)then
			base:cancleWait()
			base:cancleNetWait()
			self:tabClick(0)
		end
	end
	acAllianceDonateVoApi:getRank(onGetData)
end

function acAllianceDonateDialog:tick()
	if self and self.tab1 and self.tab1.tick then
		self.tab1:tick()
	end
end

function acAllianceDonateDialog:dispose()
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
end
