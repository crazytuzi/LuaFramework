local Welkin_BattleView = classGc( view, function( self, _data1)
	self.myType		= _data1
	self.m_winSize  = cc.Director : getInstance() : getVisibleSize()

	self.m_mediator = require("mod.welkin.Welkin_BattleMediator")() 
	self.m_mediator : setView(self) 

	self.m_resourcesArray = {}
end)

local FONTSIZE 	= 20
local heiti  	= _G.FontName.Heiti		
local COLOR_WHITE 	= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE 		)
local COLOR_ORED 	= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED   		)
local COLOR_GOLD	= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD   		)
local COLOR_GRASSGREEN 	= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN   	)

local Tag_Btn_Ranking 	= 1001
local Tag_Btn_Add 		= 1002
local Tag_Btn_GoodsShow = 1003
local NoTouch = nil

function Welkin_BattleView.create( self )
	self.m_settingView = cc.Scene : create()
	self : init()

	return self.m_settingView
end
function Welkin_BattleView.init( self )
	self.myUid = _G.GPropertyProxy : getMainPlay() : getUid()

	self.myBaseMap_1 	= cc.Sprite:create( "ui/bg/welkin_2.jpg" )
	self.myBaseMap_1 	: setPosition( self.m_winSize.width/2 , self.m_winSize.height/2 )
	self.m_settingView 	: addChild( self.myBaseMap_1 ) 

	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( self.m_winSize.width/2 , self.m_winSize.height/2 )
	self.m_settingView 	: addChild( self.mainContainer )

	local function closeFunSetting( obj, touchEvent)
		if touchEvent == ccui.TouchEventType.ended then
	 		self : closeWindow()
	 	end
	end
   	local Btn_close = ccui.Button : create()
   	Btn_close  : setAnchorPoint( 1, 1 )
   	Btn_close  : loadTextures("general_view_close.png","","",ccui.TextureResType.plistType)  
   	Btn_close  : setPosition( cc.p( self.m_winSize.width/2+13, self.m_winSize.height/2+20) )
   	Btn_close  : addTouchEventListener( closeFunSetting )
   	Btn_close  : setSoundPath("bg/ui_sys_clickoff.mp3")
   	Btn_close  : ignoreContentAdaptWithSize(false)
    Btn_close  : setContentSize(cc.size(120,120))
   	self.mainContainer	: addChild( Btn_close , 1 )

   	self : createLefView()
   	self : createDownView()
   	self : REQ_STRIDE_ASK_RANK_DATA()
end

function Welkin_BattleView.createLefView( self )
	local function ButtonCallBack( obj, eventEvent )
		self : touchEventCallBack( obj, eventEvent )
	end

	local myNode = cc.Node : create()
	self.mainContainer : addChild( myNode )

	local myLeftBase = ccui.Scale9Sprite : createWithSpriteFrameName( "base2.png" ) 
	myLeftBase 		 : setPreferredSize( cc.size( 175,95 ) )
	myLeftBase 		 : setAnchorPoint( 0, 1 )
	myLeftBase 		 : setPosition( -self.m_winSize.width/2 + 15, self.m_winSize.height/2 - 44 )
	myNode 			 : addChild( myLeftBase )

	local myRank = _G.Util : createLabel( "我的排名: ", 20 )
	myRank 		 : setPosition( 15, 80 )
	-- myRank 		 : setColor( COLOR_GOLD )
	myRank 		 : setAnchorPoint( 0, 1 )
	myLeftBase 	 : addChild( myRank, 1 )

	local width = myRank:getContentSize().width
	self.myRank = _G.Util : createLabel( "", 20 )
	self.myRank : setPosition( 15+width, 80 )
	self.myRank : setAnchorPoint( 0, 1 )
	self.myRank : setColor( COLOR_GRASSGREEN )
	myLeftBase 	: addChild( self.myRank, 1 )

	local myLefTimes = _G.Util : createLabel( "剩余次数:", 20 )
	myLefTimes 		 : setPosition( 15, 42 )
	-- myLefTimes 		 : setColor( COLOR_GRASSGREEN )
	myLefTimes 		 : setAnchorPoint( 0, 1 )
	myLeftBase 	 	 : addChild( myLefTimes, 1 )

	self.myLefTimes = _G.Util : createLabel( "", 20 )
	self.myLefTimes : setPosition( 15+width, 42 )
	self.myLefTimes : setColor( COLOR_GRASSGREEN )
	self.myLefTimes : setAnchorPoint( 0, 1 )
	myLeftBase 	 	: addChild( self.myLefTimes, 1 )

	local Btn_Add = gc.CButton : create()
	Btn_Add 	  : loadTextures( "general_btn_add.png" )
	Btn_Add 	  : setPosition( 200-52, 30 )
	Btn_Add 	  : setTag( Tag_Btn_Add ) 
	Btn_Add 	  : ignoreContentAdaptWithSize(false)
  	Btn_Add 	  : setContentSize(cc.size(85,85))
	Btn_Add 	  : addTouchEventListener( ButtonCallBack )
	myLeftBase 	  : addChild( Btn_Add )

	local Btn_GoodsShow = gc.CButton : create()
	Btn_GoodsShow : loadTextures( "ui_GoodsShow.png")
	Btn_GoodsShow : setAnchorPoint( 0, 1 )
	Btn_GoodsShow : setPosition( -self.m_winSize.width/2 + 50, 70 )
	Btn_GoodsShow : setTag( Tag_Btn_GoodsShow )
	Btn_GoodsShow : addTouchEventListener( ButtonCallBack )
	self.mainContainer : addChild( Btn_GoodsShow,1 )

	local myRanking = gc.CButton : create()
	myRanking : loadTextures( "ui_rank.png")
	myRanking : setAnchorPoint( 0, 1 )
	myRanking : setPosition( -self.m_winSize.width/2 + 50, 160 )
	myRanking : setTag( Tag_Btn_Ranking ) 
	myRanking : addTouchEventListener( ButtonCallBack )
	self.mainContainer : addChild( myRanking )
end

function Welkin_BattleView.createDownView( self )
	local myNode = cc.Node : create()
	self.mainContainer : addChild( myNode )

	self.downSize=cc.size( self.m_winSize.width-220, 170 )
	self.DownBase 	= ccui.Scale9Sprite : createWithSpriteFrameName( "ui_base.png" )
	self.DownBase 	: setPreferredSize( self.downSize )
	self.DownBase 	: setAnchorPoint( 0.5, 0 )
	self.DownBase 	: setPosition( 0, -self.m_winSize.height/2-9 )
	myNode 			: addChild( self.DownBase )

	self.leftSpr = cc.Sprite : createWithSpriteFrameName( "general_fanye.png" )
	-- self.leftSpr : setAnchorPoint( 0, 0.5 )
	self.leftSpr : setPosition( -self.m_winSize.width/2 + 50, -self.m_winSize.height/2 + self.downSize.height/2 )
	myNode : addChild( self.leftSpr, 2 )
	self.leftSpr : setVisible( false )

	self.righSpr = cc.Sprite : createWithSpriteFrameName( "general_fanye.png" )
	self.righSpr : setScaleX( -1 )
	-- self.righSpr : setAnchorPoint( 1, 0.5 )
	self.righSpr : setPosition( self.m_winSize.width/2 - 50, -self.m_winSize.height/2 + self.downSize.height/2 )
	myNode : addChild( self.righSpr, 2 )
	-- self.righSpr : setVisible( false )
end

function Welkin_BattleView.changeLeftText( self, _rank, _times )
	self.myRank 	: setString( _rank  )
	self.myLefTimes : setString( _times )
	if _times <= 0 then
		self.myLefTimes : setColor( COLOR_ORED )
	end
end

function Welkin_BattleView.changeDownText( self, _count, _data )
	local myNode = cc.Node : create()
	for i=4,_count do
		local oneHead = self : createOneHead( _data[i], i )
		oneHead 	  : setPosition( 85 + (i-4)*170, 95 )
		myNode 		  : addChild( oneHead )
	end

	local mycount = _count - 3
	if mycount <= 5 then
		-- myNode  : setPosition( self.m_winSize.width/2, 0 )
		self.DownBase : addChild( myNode )
		self.righSpr  : setVisible( false )
	    self.leftSpr  : setVisible( false )
	else
		local Wid_righView  = 170
	    local viewSize      = self.downSize
	    local containerSize = cc.size( Wid_righView*mycount, 170)

	    local ScrollView = cc.ScrollView : create()
	    -- ScrollView : setAnchorPoint( 0, 0 )
	    ScrollView : setDirection(ccui.ScrollViewDir.horizontal)
	    ScrollView : setViewSize(viewSize)
	    ScrollView : setContentSize(containerSize)
	    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
	    ScrollView : setPosition( 0,0 )
	    ScrollView : setBounceable(false)
	    ScrollView : setDelegate()
	    self.DownBase 	: addChild( ScrollView, 3 )
	    self.ScrollView = ScrollView

	    ScrollView : addChild( myNode )

	    local function onTouchBegan( touch, event )
	   		-- print( " touch:getLocation().y = ", touch:getLocation().y )  
		    return true
  		end

  		local function onTouchMoved( touch, event )
	    	local moveX = ScrollView:getContentOffset().x
	    	-- print( "moveX = ", moveX, viewSize.width-containerSize.width + 10 )
	    	if moveX <= (viewSize.width-containerSize.width + 50) then
	    		-- print( "1111" )
	    		self.righSpr : setVisible( false )
	    		self.leftSpr : setVisible( true )
	    	elseif moveX >= -50 then
	    		-- print( "2222" )
	    		self.leftSpr : setVisible( false )
	    		self.righSpr : setVisible( true )
	    	else
	    		-- print( "3333" )
	    		self.righSpr : setVisible( true )
	    		self.leftSpr : setVisible( true )
	    	end
	  	end

	  	local function onTouchEnded( touch, event )
	    	-- print( "End touch:getLocation().y = ", touch:getLocation().y, ScrollView:getContentOffset().x  )
	 	end

	    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
  		listener       : registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
  		listener       : registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
  		listener       : registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
  
  		self.m_listener=listener

  		local eventDispatcher = ScrollView : getEventDispatcher() -- 得到事件派发器
  		eventDispatcher : addEventListenerWithSceneGraphPriority(listener, ScrollView) -- 将监听器注册到派发器中

    end

end

function Welkin_BattleView.createOneHead( self, _data, _num )
	local head = { "general_role_head1.png", "general_role_head2.png", "general_role_head3.png", 
				   "general_role_head4.png", "general_role_head5.png" }
	local rank = _data.rank
	local pro  = _data.pro
	local lv   = _data.lv
	local name = _data.name
	local sid  = _data.sid
	local pow  = _data.power

	local myPosx = nil
	local function ButtonCallBack( obj, touchEvent )
		local Positionx  = obj : getWorldPosition().x - self.m_winSize.width/2
		print( "Position.x ====>>>> ", Positionx )
		if Positionx > 428 or Positionx < -420 then	
			return 
		end
		if touchEvent == ccui.TouchEventType.began then
			print(" 按下 ", tag)
			myPosx = Positionx
		elseif touchEvent == ccui.TouchEventType.moved then
			-- print(" 移动 ", tag)
	  	elseif touchEvent == ccui.TouchEventType.ended then
	  		if Positionx - myPosx > 10 or myPosx - Positionx > 10 then return end
	  		self : touchEventCallBack( obj, touchEvent )
	  	end
	end

	local myHeadNode = cc.Node : create()
	local Btn_head = gc.CButton : create( )
	Btn_head : loadTextures(head[pro])
	Btn_head : setTag( _num )
	Btn_head : setSwallowTouches( false )
	Btn_head : addTouchEventListener( ButtonCallBack )
	myHeadNode : addChild( Btn_head,1 )

	local labrank = _G.Util : createLabel( string.format( "%s%d%s","第",rank,"名" ), FONTSIZE )
	labrank : setColor( COLOR_GOLD )
	labrank : setPosition( 3, 60 )
	myHeadNode : addChild( labrank,2 )

	local lablv = _G.Util : createLabel( string.format( "%s%d  %s","LV.",lv,name ), FONTSIZE )
	-- lablv : setColor( COLOR_GRASSGREEN )
	-- lablv : setAnchorPoint( 0, 0 )
	lablv : setPosition( 0, -55 )
	myHeadNode : addChild( lablv,2 )

	local base1 = ccui.Scale9Sprite : createWithSpriteFrameName( "name_line.png" )
	local lineSize=base1:getContentSize()
	base1 		: setPreferredSize( cc.size( lineSize.width, 160 ) )
	-- base1 		: setAnchorPoint( 0.5, 0 )
	base1 		: setPosition( 85, -5 )
	myHeadNode 	: addChild( base1,1 )

	-- local labname = _G.Util : createLabel( name, 20 )
	-- labname 	  : setPosition( 0, -55 )
	-- myHeadNode	  : addChild( labname,2 )

	local labpow = self : createPowerNum( pow )
	labpow : setPosition( 0, -77 )
	myHeadNode : addChild( labpow,2 )

	return myHeadNode
end

function Welkin_BattleView.createPowerNum( self, _powerNum)
	print( " ---改变战力值--- " )
 	local node = cc.Node : create( )

 	local power = string.format( "战:%d", _powerNum )
 	local lab1  = _G.Util : createLabel( power, 20 )
 	local width = lab1 : getContentSize().width
 	lab1 : setColor( COLOR_GOLD )
 	node : addChild( lab1 )

 	return node
end

function Welkin_BattleView.changeMidSpine( self, _data )
	local pos  = { cc.p( 20, 110 ), cc.p( -235, -70 ), cc.p( 235, -70 ) }
	local function ButtonCallBack( obj, touchEvent )
		self : touchEventCallBack( obj, touchEvent )
	end

	local function getRank( i, pos )
		local spr2Text = string.format( "spr_num_%d.png", i ) 
		local spr2 = cc.Sprite : createWithSpriteFrameName( spr2Text )
		-- spr2  : setAnchorPoint( 0, 0.5 )
		spr2  : setPosition( pos.x, pos.y+217 )
		self.mainContainer : addChild( spr2 )
	end
	local movex = { -15, -8, 2 }
	local movey = { -75, -10, -22 }
	for i=1,3 do
		pos[i].x = pos[i].x + movex[i]
		pos[i].y = pos[i].y + movey[i]

		local framSpr=cc.Sprite:createWithSpriteFrameName("general_fram_dins.png")
		framSpr:setPosition(pos[i].x,pos[i].y+195)
		self.mainContainer : addChild( framSpr)

		self : drawRole( _data[i].pro, pos[i] )

		local spineWidget  = ccui.Widget : create()
		spineWidget 	   : setPosition( pos[i].x, pos[i].y+55 )
		spineWidget 	   : setTag( i )
		spineWidget 	   : setTouchEnabled( true )
		spineWidget 	   : addTouchEventListener( ButtonCallBack )
		spineWidget 	   : setContentSize( cc.size(75, 210) )
		self.mainContainer : addChild( spineWidget, 2 )

		local width    = 0
		local myWidget = ccui.Widget : create()
		local lablv = _G.Util : createLabel( string.format("LV.%d  ",_data[i].lv), FONTSIZE )
		lablv 		: setAnchorPoint( 0, 1 )
		lablv		: setPosition( width, 0)
		width = width + lablv : getContentSize().width

		local labname  = _G.Util : createLabel( _data[i].name, FONTSIZE )
		labname 	   : setPosition( width, 0 )
		labname 	   : setAnchorPoint( 0, 1 )
		width = width + labname : getContentSize().width

		myWidget : addChild( labname )
		myWidget : addChild( lablv )

		myWidget : setContentSize( cc.size( width, 1 ) )
		myWidget : setPosition( pos[i].x, pos[i].y+205 )
		self.mainContainer : addChild( myWidget, 2 )

		local spr = self : createPowerNum( _data[i].power )	
		spr : setPosition( pos[i].x, pos[i].y+170 )
		self.mainContainer : addChild( spr, 2 )

		local rank 	  = _data[i].rank 
		if rank ~= i then
			local command = CErrorBoxCommand(14230)
            controller :sendCommand( command )
		else
			getRank( i, pos[i] )
		end
	end
end

function Welkin_BattleView.drawRole( self, _pro, pos )
	print( "职业：",_pro )
	local node  = cc.Node : create()

	local myPro = _pro
	local szImg1 = string.format( "painting/1000%d_full.png", myPro )
	-- local szImg2 = string.format( "painting/1000%dleg.png", myPro )

	local body1  = _G.ImageAsyncManager:createNormalSpr(szImg1)
	-- local body2  = _G.ImageAsyncManager:createNormalSpr(szImg2)

	body1 		 : setAnchorPoint( 0.5, 0 )
	body1 		 : setTag( 1 )
	node 		 : addChild( body1,1 )

	-- body2 		 : setAnchorPoint( 0.5, 1 )
	-- body2 		 : setTag( 2 )
	-- node 		 : addChild( body2,1 )

	-- if myPro == 2 then
	-- 	body1 : setPosition( -15, -15 )
		-- body2 : setPosition( -15, -15 )
	-- end

	local shadow = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  	shadow : setScale(1.5)
  	shadow : setAnchorPoint( 0.5, 0 )
  	-- shadow : setPosition( 0, -110 )
  	node : addChild( shadow )

  	if self.m_resourcesArray[szImg1] == nil then
  		self.m_resourcesArray[szImg1] = true
  	end 

  	-- if self.m_resourcesArray[szImg2] == nil then
  	-- 	self.m_resourcesArray[szImg2] = true
  	-- end

  	node : setScale( 0.6 )

    node : setPosition( pos.x, pos.y-80 )
  	self.mainContainer : addChild(node,1)
end

function Welkin_BattleView.messageBox( self, _num, _myType )
	if self.layer then return end

	local function tipsSure()
		if _myType == nil then
			self : REQ_STRIDE_SUPERIOR_WAR(_num)
		else
			self : REQ_STRIDE_BUY_COUNT()
			if _num ~= 0 then
				self.isFight = true
			end
		end
		self.layer = nil
  	end
  	local function cancel()
  		self.layer = nil
  	end
  	if _myType ~= nil and NoTouch then
  		self : REQ_STRIDE_BUY_COUNT()
		if _num ~= 0 then
			self.isFight = true
		end
		return
  	end

  	local tipsBox = require("mod.general.TipsBox")()
 	local layer   = tipsBox :create( "", tipsSure, cancel)
  	-- layer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
  	cc.Director:getInstance():getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
  	tipsBox : setTitleLabel("提 示")
  	local layer=tipsBox:getMainlayer()
  	self.layer    = layer

  	local width  = 0
    local myWighet = ccui.Widget:create()

    if _myType == nil then
	    local Lab_1 = _G.Util : createLabel( "确定挑战", FONTSIZE)
	    Lab_1 : setAnchorPoint( 0, 0.5 )
	    Lab_1 : setPosition( width, 20 )
	    myWighet : addChild( Lab_1 )
	    width = width + Lab_1 : getContentSize().width

	    local Lab_2 = _G.Util : createLabel( self.data[_num].name, FONTSIZE)
	    Lab_2 : setColor( COLOR_GRASSGREEN )
	    Lab_2 : setAnchorPoint( 0, 0.5 )
	    Lab_2 : setPosition( width, 20 )
	    myWighet : addChild( Lab_2 )
	    width = width + Lab_2 : getContentSize().width

	    local Lab_3 = _G.Util : createLabel( "么？", FONTSIZE )
	    Lab_3 : setAnchorPoint( 0, 0.5 )
	    Lab_3 : setPosition( width, 20 )
	    myWighet : addChild( Lab_3 )
	    width = width + Lab_3 : getContentSize().width

	    myWighet : setContentSize( cc.size( width, 0 ) )
	    layer  : addChild( myWighet )
	else
		local Lab_1 = _G.Util : createLabel( "花费", FONTSIZE)
	    Lab_1 : setAnchorPoint( 0, 0.5 )
	    Lab_1 : setPosition( width, 60 )
	    myWighet : addChild( Lab_1 )
	    width = width + Lab_1 : getContentSize().width

	    local money = _G.Const.CONST_OVER_SERVER_BUY_PRICE2
	    local Lab_2 = _G.Util : createLabel( money, FONTSIZE)
	    Lab_2 : setAnchorPoint( 0, 0.5 )
	    Lab_2 : setPosition( width, 60 )
	    myWighet : addChild( Lab_2 )
	    width = width + Lab_2 : getContentSize().width

	    local Lab_3 = _G.Util : createLabel( "元宝购买一次挑战么？", FONTSIZE )
	    Lab_3 : setAnchorPoint( 0, 0.5 )
	    Lab_3 : setPosition( width, 60 )
	    myWighet : addChild( Lab_3 )
	    width = width + Lab_3 : getContentSize().width

	    myWighet : setContentSize( cc.size( width, 0 ) )
	    layer  : addChild( myWighet )

	    local lab_4 = _G.Util : createLabel( "（元宝不足自动花费钻石）", FONTSIZE-2 )
	    lab_4 : setPosition( 0, 30 )
	    layer : addChild( lab_4 )

	    local lab_5 = _G.Util : createLabel( "剩余购买次数：", FONTSIZE )
	    lab_5 : setPosition( 0, -5 )
	    layer : addChild( lab_5 )

	    local lab_6 = _G.Util : createLabel( self.buy_num , FONTSIZE )
	    lab_6 : setPosition( lab_5:getContentSize().width/2+10, -5 )
	    lab_6 : setColor( COLOR_GRASSGREEN )
	    layer : addChild( lab_6 )
	    if self.buy_num <= 0 then
	    	lab_6 : setColor( COLOR_ORED )
	    end

	    local function checkBoxCallback( obj, touchEvent )
			if touchEvent == ccui.TouchEventType.began then	
				print(" 按下 " )
				NoTouch = true
			elseif touchEvent == ccui.TouchEventType.moved then
				print(" 移动 " )
				NoTouch = nil
			end
		end

		local Tag_NoTouch   = 1001
		local uncheckBox 	= "general_gold_floor.png"
		local selectBox  	= "general_check_selected.png"
		local checkBox = ccui.CheckBox : create( uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType )
		checkBox : addEventListener( checkBoxCallback )
		checkBox : setPosition( cc.p( -80, -52 ) )
		-- checkBox : setAnchorPoint( 0, 0 )
		checkBox : setTag( Tag_NoTouch )
		layer 	 : addChild(checkBox) 

		local CheckLabel = _G.Util : createLabel( _G.Lang.LAB_N[106], FONTSIZE )
		-- CheckLabel : setAnchorPoint( 0, 0 )
		CheckLabel : setPosition( 25, -50 )
		-- CheckLabel : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
		layer	   : addChild( CheckLabel )
	end
end

function Welkin_BattleView.createShowView( self, _ackMsg )
	local function onTouchBegan(touch,event)
        return true
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rankLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rankLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rankLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rankLayer,1000)

    local rankSize=cc.size(732,512)
    local secondSize=cc.size(712,455)
    local Spr1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
    Spr1 : setPreferredSize( rankSize )
    Spr1 : setPosition( self.m_winSize.width/2, self.m_winSize.height/2 )
    self.m_rankLayer : addChild( Spr1 )

    local function closeFunSetting()
        print( "开始关闭" )
        if self.m_rankLayer~=nil then
	        self.m_rankLayer:removeFromParent(false)
	        self.m_rankLayer=nil
	    end
    end

    local Btn_Close = gc.CButton : create("general_close.png")
    Btn_Close   : setPosition( cc.p( rankSize.width-23, rankSize.height-24) )
    Btn_Close   : addTouchEventListener( closeFunSetting )
    Spr1 : addChild( Btn_Close , 8 )

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(rankSize.width/2-145, rankSize.height-26)
    Spr1 : addChild(tipslogoSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(rankSize.width/2+140, rankSize.height-26)
    tipslogoSpr : setRotation(180)
    Spr1 : addChild(tipslogoSpr)

    local m_titleLab=_G.Util:createBorderLabel("上清灵宝榜",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(rankSize.width/2,rankSize.height-26)
    Spr1:addChild(m_titleLab)

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(secondSize)
    di2kuanbg       : setPosition(cc.p(rankSize.width/2,rankSize.height/2-18))
    Spr1       : addChild(di2kuanbg)
	self : ShowRank( Spr1 ,_ackMsg,secondSize )
end

function Welkin_BattleView.ShowRank( self, _place, _ackMsg,_size )
	local place  = _place
	local msg    = _ackMsg
	local x 	 = 70
	local posx	  = { x, x+190, x+400,x+570 }
	local Text_1 = { "排行", "名字", "等级", "区服", }
	local rank   = msg.zdata.rank
	if rank >= 500 then 
		rank = string.format( "%d%s", msg.zdata.rank, "+" )
	elseif rank == 0 then
		rank = "暂无"
	end 

	local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line1 : setPreferredSize( cc.size( _size.width-10, 3 ) )
	line1 : setPosition( 13, _size.height-26  )
	line1 : setAnchorPoint( 0, 1 )
	place : addChild( line1 )

	local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line2 : setPreferredSize( cc.size( _size.width-10, 3 ) )
	line2 : setPosition( 13, 43  )
	line2 : setAnchorPoint( 0, 1 )
	place : addChild( line2 )

	local line3 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line3 : setPreferredSize( cc.size( _size.width-10, 3 ) )
	line3 : setPosition( 13, 75  )
	line3 : setAnchorPoint( 0, 1 )
	place : addChild( line3 )

	local star = cc.Sprite : createWithSpriteFrameName( "general_star.png" )
	-- star  : setScale( 0.7 )
	star  : setPosition( x-10, 58 )
	place : addChild( star )


	local lab = _G.Util : createLabel( "积分排名前256名可参与太清混元", 20 )
	-- lab : setAnchorPoint( 0, 0.5 )
	lab : setPosition( _size.width/2, 26 )
	lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	place : addChild( lab )

	local Text_2 = { rank,  _G.GPropertyProxy : getMainPlay() : getName(), 
					 	 _G.GPropertyProxy : getMainPlay() : getLv(), 
					 	 string.format("[%s服]", _G.GLoginPoxy:getServerName()) }

	for i=1,4 do
		local lab = _G.Util : createLabel( Text_1[i], FONTSIZE )
		lab : setAnchorPoint( 0, 1 )
		lab : setPosition( posx[i],_size.height+3 )
		place : addChild( lab,3 )

		local lab2 = _G.Util : createLabel( Text_2[i], FONTSIZE )
		lab2 : setPosition( posx[i]+20,57 )
		place : addChild( lab2,3 )
	end

	local count  	= msg.count
	if count < 10 then
		count = 10
	end

	local mySizeY 		= 35
    local viewSize      = cc.size( _size.width, mySizeY*10)
    local containerSize = cc.size( _size.width, mySizeY*count)

    local ScrollView = cc.ScrollView : create()
    ScrollView : setAnchorPoint( 0, 1 )
    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView : setPosition( 0 ,76 )
    ScrollView : setBounceable(true)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    place 	   : addChild( ScrollView )
    
    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView 	  : setPosOff(cc.p(2,0))
    -- barView 	  : setMoveHeightOff(-5)

	local color6  = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED   )
	local color7  = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD  )
	local color8  = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BLUE  ) 
	local myColor = { color6, color7, color8 }


	local function nFun(_data)
		if not tolua.isnull(ScrollView) then
			local nameArray=_data or {}
			for i=1,msg.count do
				local serverName=nameArray[msg.data[i].sid] or "nil"
				local Text_4 = { msg.data[i].rank, msg.data[i].name, msg.data[i].lv, string.format("[%s服]",serverName) }
				for k=1,4 do
					local lab = _G.Util : createLabel( Text_4[k], FONTSIZE )
					lab : setPosition( posx[k]+20, mySizeY*count - i*mySizeY + 17 )
					ScrollView : addChild( lab )
					if i <= 3 then
						lab : setColor( myColor[i] )
					end
				end
				local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
				line : setPreferredSize( cc.size( _size.width - 20, 2 ) )
				line : setPosition( posx[3]-105, mySizeY*count - i*mySizeY -1  )
				-- line : setAnchorPoint( 0, 1 )
				ScrollView : addChild( line )
			end
		end
	end

	local sids={}
	for i=1,msg.count do
		sids[i]=msg.data[i].sid
	end
	_G.Util:getServerNameArray(sids,nFun)
end

function Welkin_BattleView.messageBoxGoodShow( self )
	local frameSize=cc.size(520,415)
 	local combatView  = require("mod.general.BattleMsgView")()
 	self.combatBG = combatView : create("奖励预览",frameSize)
 	self.m_mainSize = combatView : getSize()

    local lineMid = ccui.Scale9Sprite : createWithSpriteFrameName( "general_lowline.png" )
    lineMid : setPreferredSize( cc.size( lineMid:getContentSize().width, self.m_mainSize.height-50 ) )
    lineMid : setPosition( self.m_mainSize.width/2-8, self.m_mainSize.height/2-22 )
    self.combatBG 	: addChild( lineMid )

    local posx = 5
    local posy = self.m_mainSize.height-48

    local text_battle = _G.Cfg.final_battle
    local myColor = { COLOR_WHITE, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE }
    local myText  = { "名次：", "第", "", "名", "奖励：", "", "*", "" }
    local function createOneGood( num )
    	myText[3] = text_battle[num].ranking_max
    	if text_battle[num].ranking_max ~= text_battle[num].ranking_min then 
    		myText[3] = string.format( "%d%s%d", text_battle[num].ranking_max, "-", text_battle[num].ranking_min )
    	end
    	myText[6] = _G.Cfg.goods[text_battle[num].goods[1][2]].name
    	myText[8] = text_battle[num].goods[1][3] 
    	local node = cc.Node : create()
    	local posx = 24
    	local posy = -9
    	for i=1,8 do
    		if i == 5 then
    			posx = 24
    			posy = -34
    		end
    		local lab = _G.Util : createLabel( myText[i], FONTSIZE )
    		lab  : setColor( myColor[i] )
    		lab  : setAnchorPoint( 0, 1 )
    		lab  : setPosition( posx, posy )
    		node : addChild( lab )

    		posx = posx + lab : getContentSize().width
    	end

    	local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    	line : setPreferredSize( cc.size( self.m_mainSize.width/2-10, 2 ) )
    	-- line : setOpacity( 255*0.3 )
    	line : setAnchorPoint( 0, 0 )
    	line : setPosition( 0, -62 )
    	node : addChild( line )

    	return node
    end

    for i=1,12 do
    	if i == 7 then
    		posx = 255
    		posy = self.m_mainSize.height-48
    	end
    	local node 	= createOneGood( i )
    	node 		: setPosition( posx, posy )
    	self.combatBG : addChild( node )
    	posy 		= posy - 58
    end
end

-- 43660
function Welkin_BattleView.REQ_STRIDE_BUY_COUNT( self )
	local msg = REQ_STRIDE_BUY_COUNT()
	msg : setArgs(2)
	_G.Network : send( msg )
end

function Welkin_BattleView.Net_BUY_OK( self, _ackMsg )
	self.myNum   = _ackMsg.count
	self.buy_num = _ackMsg.buy_num
	self.myLefTimes : setString( self.myNum )
	if self.myNum <= 0 then
		self.myLefTimes : setColor( COLOR_ORED )
	end

	if self.isFight then
		self.isFight = nil
		self : REQ_STRIDE_SUPERIOR_WAR( self.Fighting )
	end
end

-- 43634
function Welkin_BattleView.REQ_STRIDE_SUPERIOR_WAR( self, _num )
	print( "排名：", self.data[_num].rank )
	local rank = self.data[_num].rank
	_G.StageXMLManager : setServerId( rank )
	_G.StageXMLManager : setScenePkType( _G.Const.CONST_OVER_SERVER_WAR_3 )
	_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_OVER_SERVER_QUNYING_ID )
	local property  = _G.GPropertyProxy.m_lpMainPlay
    local originKey = property:getPropertyKey()
    local szKey 	= gc.Md5Crypto:md5(originKey,string.len(originKey))
	local msg = REQ_STRIDE_SUPERIOR_WAR()
	msg : setArgs( rank, szKey )
	_G.Network : send( msg )
end

-- 43545
function Welkin_BattleView.REQ_STRIDE_ASK_RANK_DATA( self )
	local msg = REQ_STRIDE_ASK_RANK_DATA()
	local myType = _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_4
	msg : setArgs( myType )
	_G.Network : send( msg )
end

-- 43550
function Welkin_BattleView.Net_RANK_DATA( self, _ackMsg )
	local msg = _ackMsg
	local msg = _ackMsg
	print( "当前返回的信息号为：", msg.type )
	print("	数量			:",	msg.count		)
	print("	剩余的挑战次数:",	msg.num		)
	print("	剩余的购买次数:",	msg.buy_num )
	self.buy_num = msg.buy_num
	self.myNum = msg.num

	print("	结束倒计时	:",	self:_getTimeStr(msg.times) )
	print("	组别			:",	msg.cenci		)
	print(" 当前挑战组别	:", msg.group  		)
	print("	当前排名		:",	msg.zdata.rank	)
	print("	昨日排名		:",	msg.zdata.zrank	)
	print("	级别组		:",	msg.zdata.group	)
	print("	当前积分		:",	msg.zdata.calculus	)
	print("	昨日积分		:",	msg.zdata.zcalculus	)
	print("	战斗力		:",	msg.zdata.power	)
	print("	越级 0:未买 1:已买	:",	msg.zdata.is_buy, "\n"	)
	self.data 	= msg.data
	for i=1,msg.count do
		print("	排名			:",	self.data[i].rank	)
		print("	服务器ID		:",	self.data[i].sid	)
		print("	玩家UID		:",	self.data[i].uid	)
		print("	玩家姓名		:",	self.data[i].name	)
		print("	玩家等级		:",	self.data[i].lv	)
		print("	性别			:",	self.data[i].sex	)
		print("	职业			:",	self.data[i].pro	)
		print("	1:可挑战 0:不能挑战 2:未预亮	:",	self.data[i].is_war	)
		print("	战斗力		:",	self.data[i].power,"\n"	)
	end 

	self.allCount = msg.count
	self : changeLeftText( msg.zdata.rank, msg.num )
	self : changeDownText( msg.count, self.data )
	self : changeMidSpine( self.data )
end

function Welkin_BattleView.REQ_STRIDE_RANK( self )
	local msg = REQ_STRIDE_RANK()
	msg : setArgs( _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_3 )
	_G.Network:send( msg )
end

function Welkin_BattleView.Net_RANK_HAIG( self, _ackMsg )
	local msg = _ackMsg
	print( "当前返回的信息号为：", msg.type 		)
	print("	当前排名		:",	msg.zdata.rank		)
	print("	昨日排名		:",	msg.zdata.zrank		)
	print("	级别组		:",	msg.zdata.group		)
	print("	当前积分		:",	msg.zdata.calculus	)
	print("	昨日积分		:",	msg.zdata.zcalculus	)
	print("	战斗力		:",	msg.zdata.power		)
	print("	数量：		:",	msg.count,"\n"		)
	for i=1,msg.count do
		print("	排名			:",	msg.data[i].rank	)
		print("	服务器ID		:",	msg.data[i].sid		)
		print("	玩家UID		:",	msg.data[i].uid		)
		print("	玩家姓名		:",	msg.data[i].name	)
		print("	战斗积分		:",	msg.data[i].arg		)
		print("	玩家等级		:",	msg.data[i].lv,"\n"	)
	end
	self : createShowView( msg ) 
end

function Welkin_BattleView.Net_SYSTEM_ERROR( self, _ackMsg )
	local ackMsg = _ackMsg
  	-- if ackMsg.error_code == 122 then 
	self.isFight = nil
end

function Welkin_BattleView._getTimeStr( self,_time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)
    local time = tostring(hour)..":"..tostring(min)..":"..second
    if hour < 10 then
        hour = "0"..hour
    elseif hour < 0 then
        hour = "00"
    end
    if min < 10 then
        min = "0"..min
    elseif min < 0 then
        min = "00"
    end
    if second < 10 then
        second = "0"..second
    end

    local time = ""
    time = tostring(hour)..":"..tostring(min)..":"..second

    return time
end

function Welkin_BattleView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print(" 按下 ", tag)
	elseif touchEvent == ccui.TouchEventType.moved then
		print(" 移动 ", tag)
  	elseif touchEvent == ccui.TouchEventType.ended then
  		print(" 抬起 ", tag )	
  		if tag >= 1 and tag <= self.allCount then
  			self.Fighting = tag
  			print( " 点击人物进行战斗 " )
  			if self.data[tag].uid == self.myUid then
  				local command = CErrorBoxCommand(5810)
               	controller :sendCommand( command )
  				return
  			end
  			if self.myNum < 1 then
  				self : messageBox( tag , 1)
  			else
  				self : messageBox( tag )
  			end
  		elseif tag == Tag_Btn_Add then
  			self : messageBox( 0 , 1)
  		elseif tag == Tag_Btn_Ranking then
  			self : REQ_STRIDE_RANK()
  		elseif tag == Tag_Btn_GoodsShow then
  			self : messageBoxGoodShow()
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ",  tag)
  	end
end

function Welkin_BattleView.closeWindow( self )
	print( "开始关闭" )
	
	ScenesManger.releaseFileArray(self.m_resourcesArray)

	if self.m_listener then
	    self.ScrollView : getEventDispatcher() : removeEventListener(self.m_listener)
	    self.m_listener = nil
  	end

	self.m_mediator : destroy()
	self.m_mediator = nil
	cc.Director : getInstance() : popScene()
end

return Welkin_BattleView