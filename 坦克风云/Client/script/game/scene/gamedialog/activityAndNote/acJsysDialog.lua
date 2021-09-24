acJsysDialog=commonDialog:new()

function acJsysDialog:new(layerNum)
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

function acJsysDialog:resetTab()
	--acJsysImage
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acJsysImage.plist")
    spriteController:addTexture("public/acJsysImage.png")
    spriteController:addPlist("public/trackingImage.plist")
    spriteController:addTexture("public/trackingImage.png")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addTexture("public/blueFilcker.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

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

	self.panelLineBg:setVisible(false)
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(topBorder)

	self:tabClick(0)
end

function acJsysDialog:initTableView()
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end

function acJsysDialog:tabClick(idx)
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

function acJsysDialog:switchTab(type)
	if type==nil then
		type=1
	end

	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acJsysDialogTabOne:new(self)
	   		else
	   			tab=acJsysDialogTabTwo:new(self)
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

	if type== 2 then
		local function getRanklist(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.rankList  then
	                acJsysVoApi:setPlayerList(sData.data.rankList)
	                showTab()
		            self:refresh(2)
	            end
	            
	        end

	    end
	    socketHelper:acJsysRequest({action=2},getRanklist)
	else
		showTab()
	end
end

function acJsysDialog:refresh( tab )
    if tab ==2 then
        if self.tab2 then
            self.tab2:refresh()
        end
    end
    --  if tab ==2 then
    --     if self.tab1 then
    --         self.tab1:refresh()
    --     end
    -- end
end
function acJsysDialog:doUserHandler()
	-- base:setWait()
	-- base:setNetWait()
	-- local function onGetData()
	-- 	if(self and self.bgLayer)then
	-- 		base:cancleWait()
	-- 		base:cancleNetWait()
	-- 		self:tabClick(0)
	-- 	end
	-- end
	-- acJsysVoApi:getRank(onGetData)
end

function acJsysDialog:tick()
	if self and self.tab1 and self.tab1.tick then
		self.tab1:tick()
	end
	if self and self.tab2 and self.tab2.tick then
		self.tab2:tick()
	end
end

function acJsysDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then

	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

	spriteController:removePlist("public/acJsysImage.plist")--trackingImage
    spriteController:removeTexture("public/acJsysImage.png")
    spriteController:removePlist("public/trackingImage.plist")--trackingImage
    spriteController:removeTexture("public/trackingImage.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removeTexture("public/blueFilcker.png")
end
