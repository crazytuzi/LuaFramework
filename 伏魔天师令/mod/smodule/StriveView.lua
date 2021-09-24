local StriveView = classGc(view,function(self)
    self.m_winSize  = cc.Director : getInstance() : getVisibleSize()
    self.m_mainSize = cc.size(780,450)
end)

local SIGN_UP_BTN   = 1001

function StriveView.create(self)
    self : register()

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    --cc.Director:getInstance():getRunningScene():addChild(self.m_rootLayer,9999)

    -- local tempScene=cc.Scene:create()
    -- tempScene:addChild(self.m_rootLayer)
	
    local msg  		  = REQ_WRESTLE_REQUEST()
    _G.Network  	  : send(msg)

    return self.m_rootLayer
end

-- function StriveView.__init(self)
--     self : register()
-- end

function StriveView.register(self)
    self.pMediator = require("mod.smodule.StriveMediator")(self)
end

function StriveView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function StriveView.initSignUp( self,_msg )
	local _id = 40217
	local function c(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
    		self:__closeWindow()
    	end
	end

    local winSize=cc.Director:getInstance():getWinSize()
    self.m_loaderNode=cc.Node:create()
    self.m_loaderNode:setPosition(winSize.width/2,0)
    self.m_rootLayer:addChild(self.m_loaderNode)

    local FrameSize=cc.size(580,340)
	local ThreeSize=cc.size(560,280)

    local framePos=cc.p(0,312)
    local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    frameSpr:setPreferredSize(FrameSize)
    frameSpr:setPosition(framePos)
    self.m_loaderNode:addChild(frameSpr)

    local di2kuanSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanSpr:setPreferredSize(ThreeSize)
    di2kuanSpr:setPosition(FrameSize.width/2,FrameSize.height/2-18)
    frameSpr:addChild(di2kuanSpr)

    local m_labelTitle=_G.Util:createBorderLabel("报 名",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_labelTitle:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_labelTitle:setPosition(FrameSize.width/2,FrameSize.height-28)
    frameSpr:addChild(m_labelTitle,10)

    self.m_closeBtn=gc.CButton:create("general_close.png")
    self.m_closeBtn:setPosition(FrameSize.width-23,FrameSize.height-23)
    self.m_closeBtn:addTouchEventListener(c)
    self.m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
    frameSpr:addChild(self.m_closeBtn,10)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(FrameSize.width/2-125,FrameSize.height-28)
    frameSpr:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(FrameSize.width/2+120,FrameSize.height-28)
    titleSpr:setRotation(180)
    frameSpr:addChild(titleSpr,9)

    local myNode = cc.Node : create()
    myNode : setPosition( 0,283 )
    frameSpr:addChild(myNode)
    local height = 0
	for i=1,#_G.Cfg.paly_des[_id].declare do
		local flag  = _G.Util : createLabel(tostring(i),20)
		flag        : setAnchorPoint(cc.p(0,1))
		flag        : setPosition(cc.p(30,-height))
		myNode      : addChild(flag)

		local label = _G.Util : createLabel(_G.Cfg.paly_des[_id].declare[i],20)
		label       : setAnchorPoint(cc.p(0,1))
		label       : setDimensions(480,0)
		label       : setPosition(cc.p(55,-height))
		myNode      : addChild(label)

		height = height + label : getContentSize().height+10
	end

	local function signUpEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			self : __signUpEvent()
		end
    end

    local signUpButton = gc.CButton:create()
	signUpButton : addTouchEventListener(signUpEvent)
	signUpButton : loadTextures("general_btn_gold.png")
	if  _msg.state == 1 then
		signUpButton : setTitleText("已报名")
		signUpButton : setTouchEnabled(false)
		signUpButton : setGray()
	else
		signUpButton : setTitleText("我要报名")
		signUpButton : setTouchEnabled(true)
		signUpButton : setDefault()
	end
	signUpButton : setTitleFontSize(24)
	signUpButton : setTitleFontName(_G.FontName.Heiti)
	signUpButton : setPosition(cc.p(FrameSize.width/2,42))
	signUpButton : setTag(SIGN_UP_BTN)
	frameSpr     : addChild(signUpButton)
	self.frameSpr= frameSpr
end

function StriveView.__signUpEvent( self )
	print("开始报名")
	local msg = REQ_WRESTLE_REQUEST_BOOK()
	msg       : setArgs(1)
	_G.Network: send(msg)
end

function StriveView.updateBtnState( self )
	local button = self.frameSpr : getChildByTag(SIGN_UP_BTN) 
	button       : setTitleText("已报名")
	button       : setTouchEnabled(false)
	button       : setGray()
end

function StriveView.__closeWindow( self )
    if self.m_rootLayer == nil then return end
    self.m_rootLayer:removeFromParent(true)
    self.m_rootLayer=nil
	self : unregister()
end

return StriveView