local FriendProxy = classGc(function( self )
	self.m_fInitialized = false

	self.friendTag 	= _G.Const.CONST_FRIEND_FRIEND
	self.recentTag 	= _G.Const.CONST_FRIEND_RECENT
	self.searchTag 	= _G.Const.CONST_FRIEND_SEARCH
	self.wishTag 	= _G.Const.CONST_FRIEND_GET_BLESS
	self.blackTag 	= _G.Const.CONST_FRIEND_BLACKLIST

	self.m_friendList = {}
	self.m_recentList = {}
	self.m_wishList = {}
	self.m_blackList = {}
	self.testList = {}

	self.m_inviteTeamArray={}

    local mediator=require("mod.support.FriendProxyMediator")()
    mediator:setView(self)

end)

function FriendProxy.setInitValueF(self, _fValue)
    self.m_fInitialized = _fValue
end

function FriendProxy.getInitValueF(self)
    return self.m_fInitialized
end

function FriendProxy.setFriendAllList( self, _dataList, _tag)
	print("FriendProxy --->",_tag,_dataList)

	_dataList=_dataList or {}
	if _tag == self.friendTag then
		self.m_friendList = _dataList

	elseif _tag == self.recentTag then
		self.m_recentList = _dataList

	elseif _tag == self.wishTag then
		self.m_wishList = _dataList

	elseif _tag == self.blackTag then
		self.m_blackList = _dataList

	else
		self.testList = _dataList

	end
	
	self:setInitValueF(true)
end

function FriendProxy.getDatalList( self, _tag)
	if _tag == self.friendTag then
		return self.m_friendList
	elseif _tag == self.recentTag then
		return self.m_recentList
	elseif _tag == self.wishTag then
		return self.m_wishList
	elseif _tag == self.blackTag then
		return self.m_blackList
	else
		return self.testList
	end
end

function FriendProxy.hasThisFriend(self,_uid)
	for i=1,#self.m_friendList do
		if self.m_friendList[i].id==_uid then
			return true,self.m_friendList[i]
		end
	end
	return false
end
function FriendProxy.hasThisBlackFriend(self,_uid)
	for i=1,#self.m_blackList do
		if self.m_blackList[i].id==_uid then
			return true,self.m_blackList[i]
		end
	end
	return false
end
function FriendProxy.removeThisFriend(self,_uid)
	for i=1,#self.m_friendList do
		if self.m_friendList[i].id==_uid then
			table.remove(self.m_friendList,i)
			return
		end
	end
end
function FriendProxy.removeThisBlackFriend(self,_uid)
	for i=1,#self.m_blackList do
		if self.m_blackList[i].id==_uid then
			table.remove(self.m_blackList,i)
			return
		end
	end
end

function FriendProxy.addThisFriendNormal(self,_uid)
	local msg=REQ_FRIEND_ADD()
	msg:setArgs(_G.Const.CONST_FRIEND_FRIEND,1,{_uid})
	_G.Network:send(msg)
end
function FriendProxy.addThisFriendBlack(self,_uid)
	local msg=REQ_FRIEND_ADD()
	msg:setArgs(_G.Const.CONST_FRIEND_BLACKLIST,1,{_uid})
	_G.Network:send(msg)
end
function FriendProxy.delThisFriendNormal(self,_uid)
	local msg=REQ_FRIEND_DEL()
	msg:setArgs(_uid,_G.Const.CONST_FRIEND_FRIEND)
	_G.Network:send(msg)
end
function FriendProxy.delThisFriendBlack(self,_uid)
	local msg=REQ_FRIEND_DEL()
	msg:setArgs(_uid,_G.Const.CONST_FRIEND_BLACKLIST)
	_G.Network:send(msg)
end


-- *******************************************************************************
-- 组队邀请 START
function FriendProxy.addInviteTeamData(self,_ackMsg)
	if not _G.GSystemProxy:isTeamOpen() then return end
	
    local arrCount=#self.m_inviteTeamArray
    for i=1,arrCount do
        local nData=self.m_inviteTeamArray[i]
        if _ackMsg.team_id==nData.team_id then
            return
        end
    end
    
    if arrCount>=10 then
        table.remove(self.m_inviteTeamArray,1)
    else
        arrCount=arrCount+1
    end
    self.m_inviteTeamArray[arrCount]=_ackMsg

    local command=CMainUiCommand(CMainUiCommand.ICON_ADD)
    command.iconType=_G.Const.kMainIconTeam
    controller:sendCommand(command)
end
function FriendProxy.removeInviteTeamMsg(self,_ackMsg)
    for i=1,#self.m_inviteTeamArray do
        local nData=self.m_inviteTeamArray[i]
        if nData.team_id==_ackMsg.team_id then
            table.remove(self.m_inviteTeamArray,i)
            return
        end
    end
end
function FriendProxy.getInviteTeamData(self)
    return self.m_inviteTeamArray
end
function FriendProxy.removeAllInviteTeamArray(self)
    self.m_inviteTeamArray={}
    local command=CMainUiCommand(CMainUiCommand.ICON_DEL)
    command.iconType=_G.Const.kMainIconTeam
    controller:sendCommand(command)
end
-- 组队邀请 END
-- *******************************************************************************

function FriendProxy.createRecommendView(self,_sysList)
	local winSize=cc.Director:getInstance():getWinSize()
	local FrameSize=cc.size(545,505)

	_sysList=_sysList or {}
	
	local function onTouchCallBack( touch,sender )
		return true
	end

	local tempNode=cc.LayerColor:create(cc.c4b(0,0,0,150))
	local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchCallBack,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    tempNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,tempNode)

    local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
   	frameSpr:setPreferredSize(FrameSize)
   	frameSpr:setPosition(winSize.width/2,winSize.height/2)
    tempNode:addChild(frameSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(FrameSize.width/2-135, FrameSize.height-26)
	-- tipslogoSpr : setPreferredSize(cc.size(buybgSize.width-25, buybgSize.height-30))
	frameSpr : addChild(tipslogoSpr)

	local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(FrameSize.width/2+130,FrameSize.height-26)
    titleSpr:setRotation(180)
    frameSpr:addChild(titleSpr,9)

	local titileLabel=_G.Util:createBorderLabel("推荐好友",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	titileLabel:setPosition(FrameSize.width/2,FrameSize.height-26)
	titileLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	frameSpr:addChild(titileLabel)

    local di2kuanSize = cc.size(FrameSize.width-20,FrameSize.height-55)
    local di2kuanSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
   	di2kuanSpr:setPreferredSize(di2kuanSize)
   	di2kuanSpr:setPosition(FrameSize.width/2,FrameSize.height/2-15)
    frameSpr:addChild(di2kuanSpr)

    local heidiSize = cc.size(FrameSize.width-25,FrameSize.height-120)
    local heidiSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
   	heidiSpr:setPreferredSize(heidiSize)
   	heidiSpr:setPosition(FrameSize.width/2,FrameSize.height/2+15)
    frameSpr:addChild(heidiSpr)

    local viewSize=cc.size(heidiSize.width,heidiSize.height-6)
    local oneHeight=viewSize.height/6
	local innerHeight=oneHeight*#_sysList
	innerHeight=innerHeight>viewSize.height and innerHeight or viewSize.height

	local innerViewSize=cc.size(viewSize.width,innerHeight)
	local noticeView=cc.ScrollView:create()
	noticeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	noticeView:setViewSize(viewSize)
	noticeView:setContentSize(innerViewSize)
	noticeView:setBounceable(false)
	noticeView:setContentOffset(cc.p(0,-innerHeight-viewSize.height/2)) -- 设置初始位置
	noticeView:setPosition(0,3)
	heidiSpr:addChild(noticeView)

	local barView=require("mod.general.ScrollBar")(noticeView)
	barView:setPosOff(cc.p(-4,0))

	local buttonList={}
	local winSize=cc.Director:getInstance():getWinSize()
	local function operateButton( sender,eventType )
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			local nPos=sender:getWorldPosition()
			print("nPos.y",nPos.y,winSize.height/2+ FrameSize.height/2-50,winSize.height/2-FrameSize.height/2+80)
			if nPos.y>winSize.height/2+ FrameSize.height/2-50 or nPos.y<winSize.height/2-FrameSize.height/2+80 then
				return
			end

			local msg = REQ_FRIEND_ADD()
			msg:setArgs(1,1,{_sysList[tag].id})
			_G.Network:send(msg)

			buttonList[tag]:setTouchEnabled(false)
			buttonList[tag]:setBright(false)
			buttonList[tag]:setTitleText("已添加")
		end
	end
	
	local nHeight=innerHeight-oneHeight*0.5
	for i=1,#_sysList do
		local v=_sysList[i]

		local doubleSize = cc.size(heidiSize.width-8,oneHeight-4)
		local doubleSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_noit.png")
		doubleSpr : setPreferredSize(doubleSize)
		doubleSpr : setPosition(heidiSize.width/2,nHeight)
		noticeView : addChild(doubleSpr)

		local szProImg=string.format("general_role_head%d.png",v.pro)
		local playerSpr = gc.GraySprite:createWithSpriteFrameName(szProImg)
		playerSpr : setPosition(45,doubleSize.height/2)
		playerSpr : setScale(0.6)
		doubleSpr:addChild(playerSpr)

		local nameLabel=_G.Util:createLabel(v.name or "[ERROR]",20)
		nameLabel:setAnchorPoint(cc.p(0,0.5));
		nameLabel:setPosition(100,doubleSize.height/2)
		nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		doubleSpr:addChild(nameLabel)

		local lvLabel=_G.Util:createLabel("LV.",20)
		lvLabel:setAnchorPoint(cc.p(0,0.5));
		lvLabel:setPosition(270,doubleSize.height/2)
		-- lvLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
		doubleSpr:addChild(lvLabel)

		local levelLabel=_G.Util:createLabel(v.lv,20)
		levelLabel:setAnchorPoint(cc.p(0,0.5));
		levelLabel:setPosition(303,doubleSize.height/2)
		-- levelLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
		doubleSpr:addChild(levelLabel)

		buttonList[i]=gc.CButton:create()
		buttonList[i]:loadTextures("general_btn_gold.png")
		buttonList[i]:setPosition(doubleSize.width-80,doubleSize.height/2)
		buttonList[i]:setTitleFontName(_G.FontName.Heiti)
		buttonList[i]:setTitleText("添 加")
		buttonList[i]:setTitleFontSize(25)
		buttonList[i]:addTouchEventListener(operateButton)
		-- buttonList[i]:setButtonScale(0.8)
		buttonList[i]:setTag(i)
		doubleSpr:addChild(buttonList[i])

		nHeight=nHeight-oneHeight
	end

	local function removeTips()
		if tempNode~=nil then
			tempNode:removeFromParent(true)
			tempNode=nil
			local command=CMainUiCommand(CMainUiCommand.SUBVIEW_FINISH)
    		_G.controller:sendCommand(command)
		end
	end

    local function oneKeyCallBack( sender,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		if #_sysList>0 then
    			local uidArray={}
    			local uidCount=0
    			for i=1,#_sysList do
    				uidCount=uidCount+1
    				uidArray[uidCount]=_sysList[i].id
    			end
				local msg = REQ_FRIEND_ADD()
				msg:setArgs(1,uidCount,uidArray)
				_G.Network:send(msg)
				removeTips()

				sender:setTouchEnabled(false)
				sender:setBright(false)
			end
    	end
    end

	local function buttonCallBack(sender,eventType)
		print("buttonCallBack",sender:getTag())
		if eventType == ccui.TouchEventType.ended then
			removeTips()
		end
	end 

    local closeBtn=gc.CButton:create("general_btn_lv.png")
    closeBtn:setPosition(FrameSize.width/2+90,43)
    closeBtn:setTitleFontName(_G.FontName.Heiti)
	closeBtn:setTitleText("关 闭")
	closeBtn:setTitleFontSize(22)
    closeBtn:addTouchEventListener(buttonCallBack)
    frameSpr:addChild(closeBtn)

	local oneKeyButton=gc.CButton:create("general_btn_gold.png")
	oneKeyButton:setPosition(FrameSize.width/2-90,43)
	oneKeyButton:setTitleFontName(_G.FontName.Heiti)
	oneKeyButton:setTitleText("全部添加")
	oneKeyButton:setTitleFontSize(22)
	oneKeyButton:addTouchEventListener(oneKeyCallBack)
	oneKeyButton:setTag(40)
	frameSpr:addChild(oneKeyButton)
	
	return tempNode
end

return FriendProxy