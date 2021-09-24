dailyAnswerDialog = commonDialog:new()

function dailyAnswerDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	-- require "luascript/script/config/gameconfig/dailyAnswerCfg"
	require "luascript/script/game/gamemodel/dailyAnswer/dailyAnswerVoApi"

	return nc
end

function dailyAnswerDialog:resetTab()
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
    self.selectedTabIndex = 0
end

function dailyAnswerDialog:initTableView()
	require "luascript/script/game/scene/gamedialog/dailyAnswer/dailyAnswerTab1"
	require "luascript/script/game/scene/gamedialog/dailyAnswer/dailyAnswerTab2"

	--require "luascript/script/config/gameconfig/tikuCfg"


	local function callback( ... )
	end

	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
  
	self:tabClick(0,false)
end

function dailyAnswerDialog:tabClick(idx,isEffect)
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
			self.acTab1=dailyAnswerTab1:new()
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
		self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width+10,G_VisibleSize.height-155+15))
		self.panelLineBg:setAnchorPoint(ccp(0.5,1))
		self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSize.height-155))
	elseif(idx==1)then
		if(self.acTab2==nil)then
			self.acTab2=dailyAnswerTab2:new()
			self.layerTab2=self.acTab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2)
			self:refresh(1)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(999333,0))
			self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
			self:refresh(1)
		end
		self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-180))
		self.panelLineBg:setAnchorPoint(ccp(0.5,0.5))
		self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
	end
end

function dailyAnswerDialog:tick()
	
	if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
		self.acTab1:tick()		
	end

	if (base.serverTime-G_getWeeTs(base.serverTime))==1 or (base.serverTime-G_getWeeTs(base.serverTime))==2 or (base.serverTime-G_getWeeTs(base.serverTime))==0 then
		self:close()
	end

end
function dailyAnswerDialog:refresh( tab )
	if tab ==1 then
		if self.acTab2 then
			self.acTab2:refresh()
		end
	end
end
function dailyAnswerDialog:dispose()
	if self.layerTab1 then
		self.acTab1:dispose()
	end
	if self.layerTab2 then
		self.acTab2:dispose()
	end
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	
end

