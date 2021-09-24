alienTechDialogTab3={}

function alienTechDialogTab3:new(flag)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.subTabs={}
	self.tab1=nil
	self.layerTab1=nil
	self.tab2=nil
	self.layerTab2=nil
	self.tab3=nil
	self.layerTab3=nil
	self.tab4=nil
	self.layerTab4=nil
	self.curTab=1
	self.flag=flag
	return nc
end

function alienTechDialogTab3:init(layerNum,parent)
	require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialogSubTab31"
	require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialogSubTab32"
	require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialogSubTab33"
	require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialogSubTab34"
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initSubTab()
	return self.bgLayer
end

function alienTechDialogTab3:initSubTab()
	local tabStr={getlocal("alien_tech_propTitle2"),getlocal("alien_tech_propTitle1"),getlocal("alien_tech_propTitle3"),getlocal("alien_tech_propTitle4")}
	for k,v in pairs(tabStr) do
		local subTabBtn=CCMenu:create()
		local subTabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		subTabItem:setAnchorPoint(ccp(0,0))
		local function tabSubClick(idx)
			return self:switchSubTab(idx,true)
		end
		subTabItem:registerScriptTapHandler(tabSubClick)
		local lb=GetTTFLabelWrap(v,24,CCSizeMake(subTabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		lb:setPosition(CCPointMake(subTabItem:getContentSize().width/2,subTabItem:getContentSize().height/2))
		subTabItem:addChild(lb)
		self.subTabs[k]=subTabItem
		subTabBtn:addChild(subTabItem)
		subTabItem:setTag(k)
		subTabBtn:setPosition(ccp((k-1)*(subTabItem:getContentSize().width+9)+30,self.bgLayer:getContentSize().height-210))
		subTabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(subTabBtn)

    	G_addNumTip(subTabItem,ccp(subTabItem:getContentSize().width+5,subTabItem:getContentSize().height-15))
	end
	if self.flag then
		self:switchSubTab(2)
	else
		self:switchSubTab(1)
	end
	self:doUserHandler()
end

function alienTechDialogTab3:switchSubTab(type,isEffect)
	if isEffect==false then
	else
		PlayEffect(audioCfg.mouseClick)
	end
	if type==nil then
		type=1
	end
	for k,v in pairs(self.subTabs) do
		if k==type then
			v:setEnabled(false)
			self.curTab=type
		else
			v:setEnabled(true)
		end
	end

	if(type==1)then
		if(self.tab1==nil)then
			self.tab1=alienTechDialogSubTab32:new()
			self.layerTab1=self.tab1:init(self.layerNum + 1,self)
			self.bgLayer:addChild(self.layerTab1,1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			self.tab2=alienTechDialogSubTab31:new()
			self.layerTab2=self.tab2:init(self.layerNum + 1,self)
			self.bgLayer:addChild(self.layerTab2,1)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			self.tab3=alienTechDialogSubTab33:new()
			self.layerTab3=self.tab3:init(self.layerNum + 1,self)
			self.bgLayer:addChild(self.layerTab3,1)
		end
	elseif(type==4)then
		if(self.tab4==nil)then
			self.tab4=alienTechDialogSubTab34:new()
			self.layerTab4=self.tab4:init(self.layerNum + 1,self)
			self.bgLayer:addChild(self.layerTab4,1)
		end
	end

	for i=1,4 do
		if self["layerTab"..i] then
			if i==type then
				self["layerTab"..i]:setPositionX(0)
				self["layerTab"..i]:setVisible(true)
			else
				self["layerTab"..i]:setPositionX(999333)
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
	

	if self.parent then
		self.parent.selectSubTab3=type
		if self.parent.resetForbidLayer then
			self.parent:resetForbidLayer()
		end
	end
end

function alienTechDialogTab3:setTipsVisibleByIdx(isVisible,idx,num)
    if self==nil then
        do
            return 
        end
    end
    local tabBtnItem=self.subTabs[idx]
    local temTabBtnItem=tolua.cast(tabBtnItem,"CCNode")
    G_refreshNumTip(temTabBtnItem,isVisible,num)
end

function alienTechDialogTab3:doUserHandler()
	local acceptList=alienTechVoApi:acceptAllUidTb()
	local acount=SizeOfTable(acceptList)
	local sendList=alienTechVoApi:sendAllUidTb()
	local scount=SizeOfTable(sendList)
	local count=acount+scount
	if count>0 then
		self:setTipsVisibleByIdx(true,1,count)
	else
		self:setTipsVisibleByIdx(false,1)
	end

	if self.parent and self.parent.doUserHandler then
		self.parent:doUserHandler()
	end
end

function alienTechDialogTab3:closeDialog()
	if self.parent and self.parent.close then
		self.parent:close()
	end
end

function alienTechDialogTab3:dispose()
	if(self.tab1)then
		self.tab1:dispose()
	end
	if(self.tab2)then
		self.tab2:dispose()
	end
	if(self.tab3)then
		self.tab3:dispose()
	end
	if(self.tab4)then
		self.tab4:dispose()
	end
	self.subTabs={}
	self.tab1=nil
	self.layerTab1=nil
	self.tab2=nil
	self.layerTab2=nil
	self.tab3=nil
	self.layerTab3=nil
	self.tab4=nil
	self.layerTab4=nil
	self.curTab=1
end