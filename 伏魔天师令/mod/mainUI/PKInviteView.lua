local PKInviteMediator=classGc(mediator,function(self,_view)
    self.name = "PKInviteMediator"
    self.view = _view
    self:regSelf()
end)
PKInviteMediator.protocolsList={
    _G.Msg.ACK_WAR_PK_RECEIVE,
    _G.Msg.ACK_WAR_PK_CANCEL_REPLY,
}
PKInviteMediator.commandsList=nil
function PKInviteMediator.ACK_WAR_PK_RECEIVE(self,_ackMsg)
	self.view:addPKInviteMsg(_ackMsg)
end
function PKInviteMediator.ACK_WAR_PK_CANCEL_REPLY(self,_ackMsg)
	self.view:removePKInviteMsg(_ackMsg.uid)
end

local PKInviteView=classGc(view,function(self,_inviteArray)
	-- for i=1,10 do
	-- 	_inviteArray[i]=_inviteArray[1]
	-- end
	self.m_inviteArray=_inviteArray
	self.m_myUid=_G.GPropertyProxy:getMainPlay():getUid()

	self.m_updateArray={}
	self.m_ceilCount=0
end)

local FontSize = 20
local tipsSize = cc.size(618,380)
local SecondSize=cc.size(600,327)
local m_winSize=cc.Director:getInstance():getWinSize()
local P_PAGE_COUNT=5

function PKInviteView.create(self)
	local function onTouchBegan(touch)
		print("ExplainView remove tips")
		local location=touch:getLocation()
		local bgRect=cc.rect(m_winSize.width/2-tipsSize.width/2,m_winSize.height/2-tipsSize.height/2,
		tipsSize.width,tipsSize.height)
		local isInRect=cc.rectContainsPoint(bgRect,location)
		print("location===>",location.x,location.y)
		print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
		if isInRect then
		return true
		end
		self:delayCallFun()
		return true
	end
	tipslisterner=cc.EventListenerTouchOneByOne:create()
	tipslisterner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	tipslisterner:setSwallowTouches(true)

	self.TipsAction=cc.LayerColor:create(cc.c4b(0,0,0,150))
	-- self.TipsAction:setPosition(m_winSize.width/2,m_winSize.height/2)
	self.TipsAction:getEventDispatcher():addEventListenerWithSceneGraphPriority(tipslisterner,self.TipsAction)

	local tipSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	tipSpr : setPosition(m_winSize.width/2,m_winSize.height/2)
	tipSpr : setPreferredSize(tipsSize)
	self.TipsAction : addChild(tipSpr)

	local di2kuanSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	di2kuanSpr : setPreferredSize(SecondSize)
	di2kuanSpr : setPosition(tipsSize.width/2,tipsSize.height/2-17)
	tipSpr : addChild(di2kuanSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(tipsSize.width/2-135, tipsSize.height-25)
	tipSpr : addChild(tipslogoSpr)

	local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
	titleSpr:setPosition(tipsSize.width/2+130,tipsSize.height-25)
	titleSpr:setRotation(180)
	tipSpr:addChild(titleSpr)

	local logoLab= _G.Util : createBorderLabel("切磋邀请", FontSize+4,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	logoLab : setPosition(tipsSize.width/2, tipsSize.height-23)
	tipSpr  : addChild(logoLab)

	self.m_tipsdibgSpr=di2kuanSpr

	-- local function close(sender, eventType)
	-- 	if eventType==ccui.TouchEventType.ended then
	-- 	  	self : closeWindow(sender,eventType)
	-- 	end
	-- end
	-- local m_closeBtn=gc.CButton:create("general_close.png")
	-- m_closeBtn:setPosition(tipsSize.width-7,tipsSize.height-7)
	-- m_closeBtn:addTouchEventListener(close)
	-- m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
	-- tipSpr:addChild(m_closeBtn)

	self:__initView()
	return self.TipsAction
end

function PKInviteView.delayCallFun( self )
    local function nFun()
        print("nFun-----------------")
        if self.TipsAction~=nil then
            self.TipsAction:removeFromParent(true)
            self.TipsAction=nil
        end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.TipsAction:runAction(cc.Sequence:create(delay,func))
end

function PKInviteView.__initView(self)
	self.m_viewSize=cc.size(SecondSize.width-8,SecondSize.height-8)
	self.m_oneHeight=self.m_viewSize.height/P_PAGE_COUNT
	self.m_ceilSize=cc.size(self.m_viewSize.width-8,self.m_oneHeight-6)

	self.m_lpScrollView=cc.ScrollView:create()
	self.m_lpScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.m_lpScrollView:setViewSize(self.m_viewSize)
	self.m_lpScrollView:setTouchEnabled(true)
	self.m_lpScrollView:setBounceable(false)
	self.m_lpScrollView:setPosition(4,4)
	self.m_tipsdibgSpr:addChild(self.m_lpScrollView)

	self:__updateScrollView()

	for i=#self.m_inviteArray,1,-1 do
		self:__addOneInvite(self.m_inviteArray[i])
	end

	self:__runTimesScheduler()
end
function PKInviteView.__updateScrollView(self)
	local inviteCount=#self.m_inviteArray
	local conHeight=inviteCount>P_PAGE_COUNT and inviteCount*self.m_oneHeight or self.m_viewSize.height
	local offHeight=self.m_viewSize.height-conHeight

	self.m_lpScrollView:setContentSize(cc.size(self.m_viewSize.width,conHeight))
	self.m_lpScrollView:setContentOffset(cc.p(0,offHeight))

	if self.m_barView==nil then
		self.m_barView=require("mod.general.ScrollBar")(self.m_lpScrollView)
    	self.m_barView:setPosOff(cc.p(-3,0))
    else
    	self.m_barView:chuangeSize()
    end

	self.m_scrollHeight=conHeight
end

function PKInviteView.__addOneInvite(self,_msg)
	local nUid=_msg.uid
	print("__addOneInvite",nUid)
	-- local nPosY=(0.5+self.m_ceilCount)*self.m_oneHeight
	local nPosY=self.m_scrollHeight-(0.5+self.m_ceilCount)*self.m_oneHeight

	local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		local nTag=sender:getTag()
    		local msg=REQ_WAR_PK_REPLY()
    		msg:setArgs(nUid,1)
    		_G.Network:send(msg)

    		self:closeWindow()
    		-- self:removePKInviteMsg(nTag)
    	end
    end

    local nUtil=_G.Util
	local curServerTimes=_G.TimeUtil:getNowSeconds()
	local curLocalTimes=_G.TimeUtil:getTotalSeconds()

	local tempSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_rolekuang.png")
	tempSpr:setPreferredSize(self.m_ceilSize)
	tempSpr:setPosition(self.m_viewSize.width*0.5,nPosY)
	self.m_lpScrollView:addChild(tempSpr)

	local nameLabel=nUtil:createLabel(_msg.name,FontSize+2)
	nameLabel:setPosition(90,self.m_ceilSize.height*0.5)
	-- nameLabel:setAnchorPoint(cc.p(0,0.5))
	tempSpr:addChild(nameLabel)

	local tempX=self.m_viewSize.width*0.5+30
	local tempLabel=nUtil:createLabel("剩余时间:",FontSize+2)
	tempLabel:setAnchorPoint(cc.p(1,0.5))
	tempLabel:setPosition(tempX,self.m_ceilSize.height*0.5)
	tempSpr:addChild(tempLabel)

	local subTimes=_msg.time-curServerTimes+30
	subTimes=subTimes<1 and 1 or subTimes
	local timesLabel=nUtil:createLabel(tostring(subTimes),FontSize+2)
	timesLabel:setAnchorPoint(cc.p(0,0.5))
	timesLabel:setPosition(tempX,self.m_ceilSize.height*0.5)
	timesLabel:setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	tempSpr:addChild(timesLabel)

	local tempBtn=gc.CButton:create("general_btn_gold.png")
	tempBtn:addTouchEventListener(c)
	tempBtn:setPosition(self.m_viewSize.width-100,self.m_ceilSize.height*0.5-2)
	tempBtn:setTitleFontName(_G.FontName.Heiti)
	tempBtn:setTitleText("同 意")
	tempBtn:setTitleFontSize(24)
	-- tempBtn:setButtonScale(0.8)
	tempBtn:setTag(nUid)
	tempSpr:addChild(tempBtn)

	self.m_updateArray[nUid]={}
	self.m_updateArray[nUid].timesLabel=timesLabel
	self.m_updateArray[nUid].handleBtn=tempBtn
	self.m_updateArray[nUid].endTime=curLocalTimes+subTimes
	self.m_updateArray[nUid].isTimeOut=false

	self.m_ceilCount=self.m_ceilCount+1
end

function PKInviteView.__runTimesScheduler(self)
	if self.m_timesScheduler then return end

	local nTimeUtil=_G.TimeUtil
	local function onSchedule()
		if next(self.m_updateArray)==nil then
			self:__removeTimesScheduler()
			return
		end

		local delCount=0
		local curTime=nTimeUtil:getTotalSeconds()

		for uid,tempT in pairs(self.m_updateArray) do
			if not tempT.isTimeOut then
				local subTime=tempT.endTime-curTime
				subTime=subTime<0 and 0 or subTime
				tempT.timesLabel:setString(tostring(subTime))

				if subTime==0 then
					tempT.handleBtn:setEnabled(false)
					tempT.handleBtn:setBright(false)
					tempT.handleBtn:setTitleText("超 时")
				end
			end
		end
	end

	self.m_timesScheduler=_G.Scheduler:schedule(onSchedule,1)
end
function PKInviteView.__removeTimesScheduler(self)
	if self.m_timesScheduler~=nil then
		_G.Scheduler:unschedule(self.m_timesScheduler)
		self.m_timesScheduler=nil
	end
end

function PKInviteView.closeWindow(self)
	if self.TipsAction==nil then return end

	self:destroy()
	self:__removeTimesScheduler()
	self.TipsAction:removeFromParent(true)
	self.TipsAction=nil
end

function PKInviteView.addPKInviteMsg(self,_ackMsg)
	local tempT=self.m_updateArray[_ackMsg.uid]
	if tempT~=nil then
		local curServerTimes=_G.TimeUtil:getNowSeconds()
		local curLocalTimes=_G.TimeUtil:getTotalSeconds()
		local subTimes=_ackMsg.time-curServerTimes+30
		subTimes=subTimes<1 and 1 or subTimes
		tempT.timesLabel:setString(tostring(subTimes))
		tempT.endTime=curLocalTimes+subTimes
		tempT.isTimeOut=false
		tempT.handleBtn:setEnabled(true)
		tempT.handleBtn:setBright(true)
		tempT.handleBtn:setTitleText("同 意")
		return
	end

	local curCount=#self.m_inviteArray
	self.m_inviteArray[curCount+1]=_ackMsg
	self:__updateScrollView()
	self:__addOneInvite(_ackMsg)
end
function PKInviteView.removePKInviteMsg(self,_uid)
	local tempT=self.m_updateArray[_uid]
	if tempT~=nil then
		tempT.isTimeOut=true
		tempT.handleBtn:setEnabled(false)
		tempT.handleBtn:setBright(false)
		tempT.handleBtn:setTitleText("已取消")
	end
end

return PKInviteView