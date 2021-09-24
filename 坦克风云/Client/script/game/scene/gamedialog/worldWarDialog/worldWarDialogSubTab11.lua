worldWarDialogSubTab11={}
function worldWarDialogSubTab11:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.status=nil
	self.layerList={}
	self.pageList={}
	return nc
end

function worldWarDialogSubTab11:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self.status=worldWarVoApi:checkStatus()
	self:initPage()
	return self.bgLayer
end

function worldWarDialogSubTab11:initPage()
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogPageSign"
	require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogPageBattle"
	local posY=G_VisibleSizeHeight - 250
	local leftBtnPos=ccp(100,posY)
	local rightBtnPos=ccp(G_VisibleSizeWidth - 100,posY)
	local function onPage()
		if(worldWarVoApi:getSignStatus()==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_noSignTip"),28)
			do return end
		end
		if(self.curPage==1)then
			self:switchLayer(2)
		else
			self:switchLayer(1)
		end
	end
	local leftItem=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",onPage,11,nil,nil)
	local leftBtn=CCMenu:createWithItem(leftItem)
	leftBtn:setTouchPriority(-(self.layerNum-1)*20-9)
	leftBtn:setPosition(100,G_VisibleSizeHeight - 250)
	self.bgLayer:addChild(leftBtn,1)
	local rightItem=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",onPage,11,nil,nil)
	rightItem:setRotation(180)
	local rightBtn=CCMenu:createWithItem(rightItem)
	rightBtn:setTouchPriority(-(self.layerNum-1)*20-9)
	rightBtn:setPosition(G_VisibleSizeWidth - 100,G_VisibleSizeHeight - 250)
	self.bgLayer:addChild(rightBtn,1)

	local pageSign=worldWarDialogPageSign:new()
	local layerSign=pageSign:init(self.layerNum,self.parent)
	self.bgLayer:addChild(layerSign)
	local pageBattle=worldWarDialogPageBattle:new()
	local layerBattle=pageBattle:init(self.layerNum)
	self.bgLayer:addChild(layerBattle)

	if(worldWarVoApi:getSignStatus()==nil or worldWarVoApi:getRoundStatus(1,1)>=10)then
		self.pageList={pageSign,pageBattle}
		self.layerList={layerSign,layerBattle}
	else
		self.pageList={pageBattle,pageSign}
		self.layerList={layerBattle,layerSign}
	end
	self:switchLayer(1)
end

function worldWarDialogSubTab11:switchLayer(page)
	self.curPage=page
	for k,v in pairs(self.layerList) do
		if(k==page)then
			v:setVisible(true)
			v:setPositionX(0)
		else
			v:setVisible(false)
			v:setPositionX(999333)
		end
	end
end

function worldWarDialogSubTab11:tick()
	for k,v in pairs(self.pageList) do
		if(v.tick)then
			v:tick()
		end
	end
end

function worldWarDialogSubTab11:dispose()
	for k,v in pairs(self.pageList) do
		if(v and v.dispose)then
			v:dispose()
		end
	end
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
end