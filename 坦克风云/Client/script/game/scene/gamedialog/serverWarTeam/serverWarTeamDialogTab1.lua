require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogSubTab11"
require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogSubTab12"
require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogSubTab13"
require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamRewardInfoDialog"
serverWarTeamDialogTab1={}

function serverWarTeamDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.allSubTabs={}
	self.subTab1=nil
	self.subTab2=nil
	self.subTab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	self.selectedType=1
	return nc
end

function serverWarTeamDialogTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initSubTab()
	self:initBg()
	-- self:checkInitPlayerTip()
	return self.bgLayer
end

function serverWarTeamDialogTab1:initSubTab()
	local subTabs = {getlocal("playerInfo"),getlocal("serverwar_scheduleTable"),getlocal("rank")}
	local subTabIndex=0
	for k,v in pairs(subTabs) do
		local subTabBtn=CCMenu:create()
		local subTabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		subTabItem:setAnchorPoint(ccp(0,0))
		local function tabSubClick(idx)
			return self:subTabClick(idx)
		end
		subTabItem:registerScriptTapHandler(tabSubClick)
		local lb=GetTTFLabelWrap(v,20,CCSizeMake(subTabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		lb:setPosition(CCPointMake(subTabItem:getContentSize().width/2,subTabItem:getContentSize().height/2))
		subTabItem:addChild(lb)

		local capInSet1 = CCRect(17, 17, 1, 1)
   	    local function touchClick()
   	    end
        local newsIcon=CCSprite:createWithSpriteFrameName("IconTip.png")
   		newsIcon:setAnchorPoint(CCPointMake(1,0.5))
        newsIcon:setPosition(ccp(subTabItem:getContentSize().width+5,subTabItem:getContentSize().height-5))
		newsIcon:setTag(10)
   		newsIcon:setVisible(false)
	    subTabItem:addChild(newsIcon)

		self.allSubTabs[k]=subTabItem
		subTabBtn:addChild(subTabItem)
		subTabItem:setTag(k)
		subTabBtn:setPosition(ccp((k-1)*(subTabItem:getContentSize().width+10)+30,G_VisibleSizeHeight-subTabItem:getContentSize().height-160))
        subTabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(subTabBtn)
	end
	self:subTabClick(1)
end

function serverWarTeamDialogTab1:setTipsVisibleByIdx(isVisible,idx)
    if self==nil then
        do
            return 
        end
    end
    local subTabItem = self.allSubTabs[idx]
    local temsubTabItem=tolua.cast(subTabItem,"CCNode")
    if temsubTabItem then
	    local tipSp=temsubTabItem:getChildByTag(10)
	    if tipSp~=nil then
			if tipSp:isVisible()~=isVisible then
		        tipSp:setVisible(isVisible)
			end
	    end
	end
end

function serverWarTeamDialogTab1:subTabClick(type)
	for k,v in pairs(self.allSubTabs) do
		if v:getTag()==type then
			v:setEnabled(false)
			self.selectedType=type
		else
			v:setEnabled(true)
		end
	end
	if(self["subTab"..type]==nil)then
		if(type==1)then
			self["subTab"..type]=serverWarTeamDialogSubTab11:new()
			self["layerTab"..type]=self["subTab"..type]:init(self.layerNum,self.parent)
			self.bgLayer:addChild(self["layerTab"..type],1)
		elseif(type==2)then
			self["subTab"..type]=serverWarTeamDialogSubTab12:new()
			self["layerTab"..type]=self["subTab"..type]:init(self.layerNum)
			self.bgLayer:addChild(self["layerTab"..type],1)
		elseif(type==3)then
			local function callback()
				self["subTab"..type]=serverWarTeamDialogSubTab13:new()
				self["layerTab"..type]=self["subTab"..type]:init(self.layerNum)
				self.bgLayer:addChild(self["layerTab"..type],1)
			end
			serverWarTeamVoApi:formatRankList(callback)
		end
	end
	for i=1,3 do
		if(type==i)then
			if(self["layerTab"..i])then
				self["layerTab"..i]:setPosition(ccp(0,0))
				self["layerTab"..i]:setVisible(true)
			end
		else
			if(self["layerTab"..i])then
				self["layerTab"..i]:setPosition(ccp(999333,0))
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
	if(type==2)then
		serverWarTeamVoApi.todayScheduleTabHasClick=playerVoApi:getUid().."-"..base.curZoneID
		self:setTipsVisibleByIdx(false,2)
	elseif(type==3)then
		serverWarTeamVoApi:setRankHasOpen()
	end
end

function serverWarTeamDialogTab1:initBg()
	self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),function ( ... )end)
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight-225))
	self.bgLayer:addChild(self.panelLineBg)
end

function serverWarTeamDialogTab1:checkInitPlayerTip()
	if(serverWarTeamVoApi:checkIsPlayer())then
		local function callback()
			if(serverWarTeamVoApi:checkPlayerHasBattle())then
				for i=0,#(serverWarTeamVoApi:getBattleTimeList())-1 do
					local roundStatus=serverWarTeamVoApi:getRoundStatus(i)
					if(roundStatus>=10 and roundStatus<30)then
						self.playerCurRound=i
						break
					end
				end
			end
		end
		serverWarTeamVoApi:getScheduleInfo(callback)
	end
end

function serverWarTeamDialogTab1:tick()
	local rankHasOpen=serverWarTeamVoApi:getRankHasOpen()
	if rankHasOpen==false and self.selectedType~=3 then
		self:setTipsVisibleByIdx(true,3)
	else
		self:setTipsVisibleByIdx(false,3)
	end
	if(self.playerCurRound)then
		local roundStatus=serverWarTeamVoApi:getRoundStatus(self.playerCurRound)
		if(roundStatus>=20 and roundStatus<30)then
			if(serverWarTeamVoApi.todayScheduleTabHasClick~=playerVoApi:getUid().."-"..base.curZoneID)then
				self:setTipsVisibleByIdx(true,2)
			end
		end
	end
end

function serverWarTeamDialogTab1:dispose()
	for i=1,3 do
		if (self["subTab"..i]~=nil and self["subTab"..i].dispose) then
			self["subTab"..i]:dispose()
		end
	end
end