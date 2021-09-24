--百花齐放
--author: ym
acBhqfDialog=commonDialog:new()

function acBhqfDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	-- nc.acVo=acBhqfVoApi:getAcVo()
	-- nc.curPage=1
	nc.tab1=nil
	nc.layerTab1=nil
	nc.tab2=nil
	nc.layerTab2=nil
	-- nc.lastTickIndex=0
	return nc
end

function acBhqfDialog:resetTab()
	local function addPlist()
		spriteController:addPlist("public/acBhqf2.plist")
		spriteController:addTexture("public/acBhqf2.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/acBhqf.plist")
	spriteController:addTexture("public/acBhqf.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
	
	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,G_VisibleSizeHeight - tabBtnItem:getContentSize().height/2 - 75)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,G_VisibleSizeHeight - tabBtnItem:getContentSize().height/2 - 75)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end 
		index=index+1
	end
	self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-153)
    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-151))
    self.bgLayer:addChild(tabLine)
end

function acBhqfDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
			self:doUserHandler()            
		else
			v:setEnabled(true)
		end
	end
	self:getDataByType(idx)
end

function acBhqfDialog:getDataByType(idx)
	if(idx==nil)then
		idx=0
	end
	if(idx==1)then
		if(self.tab2==nil)then
			self.tab2=acBhqfTaskDialog:new()
			self.layerTab2=self.tab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2,1)
		end
		self.layerTab1:setVisible(false)
		self.layerTab1:setPositionX(999333)
		self.layerTab2:setVisible(true)
		self.layerTab2:setPositionX(0)
		self.tab2:refreshUI()
	else
		if(self.tab1==nil)then
			self.tab1=acBhqfLotteryDialog:new()
			self.layerTab1=self.tab1:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab1,1)
		end
		self.layerTab1:setVisible(true)
		self.layerTab1:setPositionX(0)
		if(self.layerTab2)then
			self.layerTab2:setVisible(false)
			self.layerTab2:setPositionX(999333)
		end
	end
end

-- function acBhqfDialog:eventHandler()
-- end
-- function acBhqfDialog:initTableView()
--     local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
--     local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
--     self.bgLayer:addChild(tv)

--     self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-69.5))
-- 	self.panelLineBg:setContentSize(CCSizeMake(611,G_VisibleSize.height-162))
-- 	self.bgLayer:reorderChild(self.panelLineBg,1)
--     for k,v in pairs(self.allTabs) do
--     	if v then
-- 			local itemMenu=tolua.cast(v:getParent(),"CCMenu")
-- 			print("v:getParent(),itemMenu",v:getParent(),itemMenu)
-- 			if itemMenu then
-- 				self.bgLayer:reorderChild(itemMenu,2)
-- 				print("itemMenu:getZOrder()",itemMenu:getZOrder())
-- 				break
-- 			end
-- 		end
-- 	end
-- end

function acBhqfDialog:tick()
	if(self.tab1 and self.tab1.tick)then
		self.tab1:tick()
	end
	if(self.tab2 and self.tab2.tick)then
		self.tab2:tick()
	end
	local tab2Flag=acBhqfVoApi:hasTaskReward()
	self:setIconTipVisibleByIdx(tab2Flag,2)
	-- if(self.lastTickIndex==nil or self.lastTickIndex%2==0)then
	-- 	local tab2Flag=acBhqfVoApi:hasTaskReward()
	-- 	self:setIconTipVisibleByIdx(tab2Flag,2)
	-- end
	-- if(self.lastTickIndex==nil)then
	-- 	self.lastTickIndex=1
	-- else
	-- 	self.lastTickIndex=self.lastTickIndex + 1
	-- end
	local vo=acBhqfVoApi:getAcVo()
	if(vo==nil or (vo.et and activityVoApi:isStart(vo)==false))then
		self:close()
	end
end

function acBhqfDialog:dispose()
	if(self.tab1 and self.tab1.dispose)then
		self.tab1:dispose()
	end
	if(self.tab2 and self.tab2.dispose)then
		self.tab2:dispose()
	end
	-- self.lastTickIndex=0
	-- self.acVo=nil
	-- self.curPage=1
	self.tab1=nil
	self.layerTab1=nil
	self.tab2=nil
	self.layerTab2=nil

	spriteController:removePlist("public/acBhqf.plist")
	spriteController:removeTexture("public/acBhqf.png")
	spriteController:removePlist("public/acBhqf2.plist")
	spriteController:removeTexture("public/acBhqf2.png")
	spriteController:removePlist("public/taskYouhua.plist")
	spriteController:removeTexture("public/taskYouhua.png")
end