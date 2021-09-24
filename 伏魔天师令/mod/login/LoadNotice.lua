local LoadNoticeView = classGc( view, function( self )
	self.m_winSize  	= cc.Director:getInstance() : getWinSize()
	self.m_viewSize 	= cc.size( 918, 572 )

end)

local FONTSIZE = 20
local color1   = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN)
local color2   = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)

-- local lab1T = { ["w"] = "2015年12月21日维护公告", ["c"] = 20 }
-- local lab2T = { ["w"] = "2015年7月8日21:00-9日21:00", ["c"] = 20 }
-- local lab3T = { ["w"] = "如果在维护预定时间内无法完成维护内容，开机时间将延迟，维护期间给您带来的不便，敬请谅解", ["c"] = 20 }
-- local lab4T = { { ["w"] = "修正BUG，", ["c"] = 20 }, { ["w"] = "修正BUG，", ["c"] = 20 }, { ["w"] = "修正BUG，", ["c"] = 20 },
-- 			    { ["w"] = "修正BUG，", ["c"] = 20 }, { ["w"] = "修正BUG，", ["c"] = 20 }, { ["w"] = "修正BUG，", ["c"] = 20 }, { ["w"] = "修正BUG，", ["c"] = 20 }, 
-- 			  }

function LoadNoticeView.create( self, _juhua )
	local function onTouchBegan() 
    	return true 
  	end

  	local listerner = cc.EventListenerTouchOneByOne : create()
  	listerner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  	listerner : setSwallowTouches(true)

	self.m_rootLayer = cc.Layer:create()
	cc.Director : getInstance() : getRunningScene() : addChild(self.m_rootLayer,888)
	self.m_rootLayer : setTag( 5656 )
	self.m_rootLayer : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, self.m_rootLayer)
	self:init(_juhua)

	return self.m_rootLayer
end

function LoadNoticeView.init( self, _juhua )
	self.m_mainContainer = cc.Node : create()
	self.m_mainContainer : setPosition( self.m_winSize.width/2, self.m_winSize.height/2-17 )
	self.m_rootLayer : addChild( self.m_mainContainer )

	if _juhua then
		local circle=cc.Sprite:createWithSpriteFrameName("general_loading.png")
    	self.m_mainContainer:addChild(circle)
    	local rotaBy=cc.RotateBy:create(1,360)
    	circle:runAction(cc.RepeatForever:create(rotaBy))

    	local function nFun()
    		circle:removeFromParent(true)
    	end
    	circle:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(nFun)))
	end

	self : createView()
	-- self : createScrollview()
	self : addWebView()
end

function LoadNoticeView.createView( self )
	local base1 = cc.Sprite:create("ui/bg/login_gonggao.jpg")
	-- base1 		: setPreferredSize( self.m_viewSize )
	self.m_mainContainer : addChild( base1, -2 )
	self.m_baseSpr  = base1
	self.m_viewSize = base1:getContentSize()

	-- local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
 --    tipslogoSpr : setPosition(self.m_viewSize.width/2-125, self.m_viewSize.height-28)
 --    base1 : addChild(tipslogoSpr)

 --    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
 --    tipslogoSpr : setPosition(self.m_viewSize.width/2+120, self.m_viewSize.height-28)
 --    tipslogoSpr : setRotation(180)
 --    base1 : addChild(tipslogoSpr)

	-- local titleText = _G.Util : createBorderLabel( "公 告", 24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
	-- titleText:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	-- titleText:setPosition( self.m_viewSize.width/2, self.m_viewSize.height-26 )
	-- base1 : addChild( titleText )

	local function closeEvent( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:closeWindow()
		end
	end

	local Btn_Close = gc.CButton : create("general_btn_gold.png")
    Btn_Close : setPosition( cc.p( self.m_viewSize.width/2, 32) )
    Btn_Close : addTouchEventListener( closeEvent )
    Btn_Close : setTitleText("确  定")
	Btn_Close : setTitleFontSize(24)
	Btn_Close : setTitleFontName(_G.FontName.Heiti)
    base1 : addChild( Btn_Close , 8 )
end

function LoadNoticeView.addWebView( self )
	local myHeight = self.m_viewSize.height-115
	local myPosY   = 12
	local url = _G.SysInfo:urlUpdateLogs()
	print("addWebView========>>>>",url)
	self.m_webView=gc.CWebView:create()
	self.m_webView:setPosition(0,myPosY)
	self.m_webView:setContentSize(cc.size( self.m_viewSize.width-24, myHeight ))
	self.m_webView:loadURL( url ) -- "http://www.baidu.com"
	self.m_webView:setScalesPageToFit(true)
	self.m_mainContainer:addChild(self.m_webView)

	-- local function callBack(eventType)
	--     if eventType==_G.Const.sWebViewStartLoading then
	--         print("FFFFF======>>>> 开始加载")
	--     elseif eventType==_G.Const.sWebViewFinishLoading then
	--         print("FFFFF======>>>> 加载完成")
	--     elseif eventType==_G.Const.sWebViewFailLoading then
	--         print("FFFFF======>>>> 加载出错")
	--     end
	-- end
	-- local handler=gc.ScriptHandlerControl:create(callBack)
	-- self.m_webView:registerScriptHandler(handler)
end

function LoadNoticeView.createScrollview( self )
	local viewSize  = cc.size( 900, 516 )
	local allHeight = -10 
	local gap = 30

	local di2kuan = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" )
	di2kuan : setPreferredSize( viewSize )
	di2kuan : setPosition( self.m_viewSize.width/2, self.m_viewSize.height/2-18 )
	self.m_baseSpr : addChild( di2kuan )

	local node = cc.Node : create()

	local lab = {}
	local lab1Text = { lab1T.w, "亲爱的玩家朋友:", "本次维护时间:", lab2T.w, lab3T.w }
	local lab1Size = { lab1T.c, 20, 20, lab2T.c, lab3T.c }
	local lab1Colr = { color1, color1, color1, color2, color1 }

	-- local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_base.png" )
	-- spr  : setPreferredSize( cc.size( 250, 30 ) )
	-- spr  : setAnchorPoint( 0, 1 )
	-- spr  : setPosition( 5, -4 )
	-- node : addChild( spr ) 

	for i=1,5 do
		lab[i] = _G.Util : createLabel( lab1Text[i], lab1Size[i] )
		lab[i] : setAnchorPoint( 0, 1 )
		lab[i] : setPosition( 10, allHeight )
		lab[i] : setColor( lab1Colr[i] )
		node : addChild( lab[i] )
		if i == 5 then
			lab[i] : setLineBreakWithoutSpace(true)
  			lab[i] : setDimensions( viewSize.width - 20, 0)
		end
		if i == 4 then
			lab[4] : setPosition( lab[3]:getContentSize().width + 10, allHeight )
		end
		if i ~= 3 then
			allHeight = allHeight - lab[i] : getContentSize().height - 5
		end
	end

	allHeight = allHeight - gap

	local lab6 = _G.Util : createLabel( "【本次维护内容】", 20 )
	lab6 : setPosition( 5, allHeight )
	lab6 : setColor( color1 )
	lab6 : setAnchorPoint( 0, 1 )
	node : addChild( lab6 )

	allHeight = allHeight - lab6 : getContentSize().height - 5

	local lab2 = {}
	for i=1,#lab4T do
		lab2[i] = _G.Util : createLabel( lab4T[i].w, lab4T[i].c )
		lab2[i] : setAnchorPoint( 0, 1 )
		lab2[i] : setPosition( 10, allHeight )
		lab2[i] : setLineBreakWithoutSpace(true)
  		lab2[i] : setDimensions( viewSize.width - 20, 0)
		lab2[i] : setColor( color1 )
		node 	: addChild( lab2[i] )

		allHeight = allHeight - lab2[i] : getContentSize().height - 5
	end

	print( "行数：", allHeight+10  )
	local myHeight = -allHeight - 10
	if myHeight <= 295 then
		local base2Size = cc.size( viewSize.width, viewSize.height )
		self.m_baseSpr : addChild( node )
		node : setPosition( 10, base2Size.height-5 )
	else
		 
	  	local viewSize 		= cc.size( viewSize.width, viewSize.height )
	   	local containerSize = cc.size( viewSize.width, myHeight + 10 )
	  	local myScrollview  =cc.ScrollView : create()
	  	myScrollview  : setDirection(ccui.ScrollViewDir.vertical)
	  	myScrollview  : setViewSize(viewSize)
	  	myScrollview  : setContentSize(containerSize)
	  	myScrollview  : setContentOffset( cc.p(0,  viewSize.height - myHeight - 10  ))
	  	myScrollview  : setPosition( 5, 56 )
	  	self.m_baseSpr    : addChild( myScrollview)

	  	local barView=require("mod.general.ScrollBar")(myScrollview)
	  	barView:setPosOff(cc.p(4,0))

	  	myScrollview : addChild( node )
	  	node : setPosition( 0, myHeight + 10 )
	end
end

function LoadNoticeView.closeWindow( self )
	if self.m_rootLayer ~= nil then
		self.m_rootLayer : removeFromParent( true )
		self.m_rootLayer = nil
	end
end

return LoadNoticeView