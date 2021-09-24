local UIPlayerInfoMediator=classGc(mediator,function(self,_view)
    self.name = "UIPlayerInfoMediator"
    self.view = _view
    self:regSelf()
end)
UIPlayerInfoMediator.protocolsList={
    _G.Msg.ACK_ROLE_PROPERTY_REVE2,
    _G.Msg.ACK_WAR_PK_REPLY_SELF,
}
UIPlayerInfoMediator.commandsList=nil
function UIPlayerInfoMediator.ACK_ROLE_PROPERTY_REVE2(self,_ackMsg)
	if self.view.m_waitPKNode~=nil then return end
    self.view:closeWindow()
end
function UIPlayerInfoMediator.ACK_WAR_PK_REPLY_SELF(self,_ackMsg)
	if _ackMsg.type==0 then
		self.view:__showWaitPKView()
	else
		local command=CErrorBoxCommand(_ackMsg.type)
		controller:sendCommand(command)
	end
end

local UIPlayerInfo=classGc(view,function(self,_character)
	self.m_character=_character
end)

local P_WINSIZE=cc.Director:getInstance():getWinSize()
local P_VIEW_SIZE=cc.size(176,335)
local P_VIEW_RECT=cc.rect(P_WINSIZE.width*0.5-P_VIEW_SIZE.width*0.5,
						P_WINSIZE.height*0.5-P_VIEW_SIZE.height*0.5,
						P_VIEW_SIZE.width,
						P_VIEW_SIZE.height)
local P_MID_X=P_VIEW_SIZE.width*0.5


function UIPlayerInfo.create(self)
	local function onTouchBegan(touch,event)
		if self.m_waitPKNode~=nil then return true end

		local location=touch:getLocation()
		if cc.rectContainsPoint(P_VIEW_RECT,location) then
			return true
		end

		self:delayToClose()
		return true
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    self.m_mediator=UIPlayerInfoMediator(self)
    self:__initView()

    return self.m_rootLayer
end
function UIPlayerInfo.__initView(self)
	P_VIEW_SIZE=cc.size(176,335)
	P_MID_X=P_VIEW_SIZE.width*0.5
	local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendkuang.png")
	frameSpr:setPreferredSize(P_VIEW_SIZE)
	frameSpr:setPosition(P_WINSIZE.width*0.5,P_WINSIZE.height*0.5)
	self.m_rootLayer:addChild(frameSpr)

	self.m_frameSpr=frameSpr
	self.m_infoNode=cc.Node:create()
	frameSpr:addChild(self.m_infoNode)

	local heProperty=self.m_character:getProperty()
	local szName=self.m_character:getName() or "ERROR"
	local nameLabel=_G.Util:createLabel(szName,20)
	nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	nameLabel:setPosition(P_MID_X,P_VIEW_SIZE.height-30)
	self.m_infoNode:addChild(nameLabel)

	local heUid=heProperty:getUid()
	local isMyFriend=_G.GFriendProxy:hasThisFriend(heUid)
	local szBtnArray
	if isMyFriend then
		szBtnArray={"查看信息","删除好友","私聊","切磋","战力对比"}
		-- szBtnArray={"查看信息","删除好友","私聊","切磋"}
	else
		szBtnArray={"查看信息","加为好友","私聊","切磋","战力对比"}
		-- szBtnArray={"查看信息","加为好友","私聊","切磋"}
	end
	self.m_heUid=heUid

	local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		local nTag=sender:getTag()
    		print("==============>>>>>>",nTag)
    		if nTag==1 then
    			_G.GLayerManager:showPlayerView(heUid)
    		elseif nTag==2 then
    			if isMyFriend then
    				_G.GFriendProxy:delThisFriendNormal(heUid)
    			else
    				_G.GFriendProxy:addThisFriendNormal(heUid)
    			end
    			self:delayToClose()
    		elseif nTag==3 then
    			local chatData={}
				chatData.dataType=_G.Const.kChatDataTypeSL
				chatData.chatName=szName
				chatData.chatId=heUid
				_G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_CHATTING,nil,chatData)
				self:closeWindow()
    		elseif nTag==4 then
    			local msg=REQ_WAR_PK()
			    msg:setArgs(self.m_heUid)
			    _G.Network:send(msg)
			elseif nTag==5 then
				print( "耶耶耶，战力对比！" )
				_G.GLayerManager:openLayer(_G.Cfg.UI_BattleCompareView,nil,heUid)
    		end
    	end
    end

	local nFName=_G.FontName.Heiti
	local nPosY=P_VIEW_SIZE.height-77
	-- local lPosX=P_MID_X-90
	-- local rPosX=P_MID_X+90
	for i=1,#szBtnArray do
		-- local isLeft=i%2==1
		-- local nPosX=isLeft and lPosX or rPosX

		local tempBtn=gc.CButton:create("general_btn_gray.png")
		tempBtn:setTag(i)
		tempBtn:addTouchEventListener(c)
		tempBtn:setPosition(P_MID_X,nPosY)
		tempBtn:setTitleFontName(nFName)
		tempBtn:setTitleText(szBtnArray[i])
		tempBtn:setTitleFontSize(22)
		self.m_infoNode:addChild(tempBtn)

		if not isLeft then
			nPosY=nPosY-55
		end
	end
end

function UIPlayerInfo.__showWaitPKView(self)
	self.m_infoNode:setVisible(false)
	P_VIEW_SIZE=cc.size(292,170)
	P_MID_X=P_VIEW_SIZE.width*0.5

	if self.m_waitPKNode~=nil then return end

	local frame1 = cc.SpriteFrameCache : getInstance() : getSpriteFrame("general_di2kuan.png")
	self.m_frameSpr:setSpriteFrame(frame1,cc.rect(30,30,1,1))
	self.m_frameSpr:setPreferredSize(P_VIEW_SIZE)

	self.m_waitPKNode=cc.Node:create()
	self.m_frameSpr:addChild(self.m_waitPKNode)

	self.clipNode=cc.ClippingNode:create()
	self.clipNode:setInverted(false)
	self.m_frameSpr:addChild(self.clipNode,-1)

	local dinSize=cc.size(307,222)
	local dinsSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	dinsSpr : setPreferredSize(dinSize)
	dinsSpr : setPosition(P_VIEW_SIZE.width/2, P_VIEW_SIZE.height/2+17)
	self.clipNode : addChild(dinsSpr)

	local logoLab= _G.Util : createBorderLabel("切磋请求", 20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	logoLab : setPosition(dinSize.width/2, dinSize.height-32)
	self.clipNode : addChild(logoLab)

	local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(dinSize.width/2-125,dinSize.height-30)
    self.clipNode:addChild(titleSpr)

    local titleSpr1=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr1:setPosition(dinSize.width/2+120,dinSize.height-30)
    titleSpr1:setRotation(180)
    self.clipNode:addChild(titleSpr1)

    self.clipNode:setStencil(dinsSpr)

	local noticLabel=_G.Util:createLabel("等待对方响应",24)
	noticLabel:setPosition(P_MID_X,P_VIEW_SIZE.height-40)
	self.m_waitPKNode:addChild(noticLabel)

	local tempX=P_MID_X-15
	local tempY=P_VIEW_SIZE.height*0.5
	local tempLabel=_G.Util:createLabel("邀请倒计时: ",20)
	tempLabel:setPosition(tempX,tempY)
	self.m_waitPKNode:addChild(tempLabel)

	local waitTimes=30
	local tempSize=tempLabel:getContentSize()
	self.m_waitPKTimesLabel=_G.Util:createLabel(tostring(waitTimes),20)
	self.m_waitPKTimesLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_waitPKTimesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	self.m_waitPKTimesLabel:setPosition(tempX+tempSize.width*0.5,tempY)
	self.m_waitPKNode:addChild(self.m_waitPKTimesLabel)

	local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		self:__hideWaitPKView()
    	end
    end
    local tempBtn=gc.CButton:create("general_btn_gold.png")
	tempBtn:addTouchEventListener(c)
	tempBtn:setPosition(P_MID_X,30)
	tempBtn:setTitleFontName(_G.FontName.Heiti)
	tempBtn:setTitleText("取 消")
	tempBtn:setTitleFontSize(24)
	tempBtn:setButtonScale(0.85)
	self.m_waitPKNode:addChild(tempBtn)

	self.m_waitPKTimes=_G.TimeUtil:getTotalSeconds()+waitTimes

	self:__runTimesScheduler()
end
function UIPlayerInfo.__hideWaitPKView(self)
	if self.m_waitPKNode~=nil then
		self.m_waitPKNode:removeFromParent(true)
		self.m_waitPKNode=nil
		self.clipNode:removeFromParent(true)
		self.clipNode=nil
	end
	self.m_waitPKTimes=nil
	self.m_waitPKTimesLabel=nil

	P_VIEW_SIZE=cc.size(176,335)
	-- P_VIEW_SIZE=cc.size(175,305)
	P_MID_X=P_VIEW_SIZE.width*0.5
	self.m_infoNode:setVisible(true)
	local frame1 = cc.SpriteFrameCache : getInstance() : getSpriteFrame("general_friendkuang.png")
	self.m_frameSpr:setSpriteFrame(frame1)
	self.m_frameSpr:setPreferredSize(P_VIEW_SIZE)

	self:__removeTimesScheduler()

	local msg=REQ_WAR_PK_CANCEL()
   	_G.Network:send(msg)
end

function UIPlayerInfo.__runTimesScheduler(self)
	if self.m_timesScheduler then return end

	local nTimeUtil=_G.TimeUtil
	local function onSchedule()
		local curTime=nTimeUtil:getTotalSeconds()
		local subTime=self.m_waitPKTimes-curTime
		local szTimes=tostring(subTime)
		self.m_waitPKTimesLabel:setString(szTimes)

		if subTime<=0 then
			self:__hideWaitPKView()
		end
	end

	self.m_timesScheduler=_G.Scheduler:schedule(onSchedule,1)
end
function UIPlayerInfo.__removeTimesScheduler(self)
	if self.m_timesScheduler~=nil then
		_G.Scheduler:unschedule(self.m_timesScheduler)
		self.m_timesScheduler=nil
	end
end

function UIPlayerInfo.delayToClose(self)
	if self.m_rootLayer==nil then return end

	local function nFun(_node)
		_node:removeFromParent(true)
	end

	self:destroy()
	self:__removeTimesScheduler()
	self.m_rootLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(nFun)))
	self.m_rootLayer=nil
end

function UIPlayerInfo.closeWindow(self)
	if self.m_rootLayer==nil then return end

	self:destroy()
	self:__removeTimesScheduler()

	self.m_rootLayer:removeFromParent(true)
	self.m_rootLayer=nil
end

return UIPlayerInfo