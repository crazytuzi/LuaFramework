local Welkin_FirstView = classGc( view, function( self, _data1)
	self.myType		= _data1
	self.m_winSize  = cc.Director : getInstance() : getVisibleSize()

	self.m_mediator = require("mod.welkin.Welkin_FirstMediator")() 
	self.m_mediator : setView(self) 

	self.m_resourcesArray = {}
	self.newNode = {}
end)

local GAME_5 = _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_5
local GAME_6 = _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_6
local RANK_1 = _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_2
local COLOR_WHITE = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE 		)
local COLOR_GRASSGREEN = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN   	)
local COLOR_ORED = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED   		)
local COLOR_GOLD = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD   		)
local Group  = {	[_G.Const.CONST_OVER_SERVER_GROUP_1] = 1,
					-- 新手组
					[_G.Const.CONST_OVER_SERVER_GROUP_2] = 2,
					-- 青铜组
					[_G.Const.CONST_OVER_SERVER_GROUP_3] = 3,
					-- 白银组
					[_G.Const.CONST_OVER_SERVER_GROUP_4] = 4,
					-- 黄金组
					[_G.Const.CONST_OVER_SERVER_GROUP_5] = 5,
					-- 钻石组
					[_G.Const.CONST_OVER_SERVER_GROUP_6] = 6,
					-- 大师组
					[_G.Const.CONST_OVER_SERVER_GROUP_7] = 7,}
					-- 宗师组

local Text_Group = {    [_G.Const.CONST_OVER_SERVER_GROUP_1] = "新手组",
						[_G.Const.CONST_OVER_SERVER_GROUP_2] = "青铜组",
						[_G.Const.CONST_OVER_SERVER_GROUP_3] = "白银组",
						[_G.Const.CONST_OVER_SERVER_GROUP_4] = "黄金组",
						[_G.Const.CONST_OVER_SERVER_GROUP_5] = "钻石组",
						[_G.Const.CONST_OVER_SERVER_GROUP_6] = "大师组",
						[_G.Const.CONST_OVER_SERVER_GROUP_7] = "宗师组", }


local FONTSIZE 				= 20

local Tag_Btn_GoodsGet 		= { 101, 102, 103, 104 }
local Tag_Btn_GoodsShow		= 105

local Tag_Btn_AddTime  		= 201
local Tag_Btn_Ranking  		= 202
local Tag_Btn_OverFight		= 203

local Tag_Btn_GroupSpine	= { 511, 512, 513, 514 }
local Tag_Btn_Rank_6		= 520
local Tag_Btn_ChangeView	= 521
local Tag_NoTouch 			= 555
local NoTouch=false

function Welkin_FirstView.create( self )
	self.m_settingView = cc.Scene : create()
	self : init()

	print("Welkin_FirstView.create=====>>")
	local function onNodeEvent(event)
        print("Welkin_FirstView---onNodeEvent===========>>>>",event)
    end

    self.m_settingView:registerScriptHandler(onNodeEvent)

	return self.m_settingView
end

function Welkin_FirstView.init( self )
	-- 初始化界面
	self.myBaseMap_1 	= cc.Sprite:create( "ui/bg/welkin.jpg" )
	self.myBaseMap_1 	: setPosition( self.m_winSize.width/2 , self.m_winSize.height/2 )
	self.m_settingView 	: addChild( self.myBaseMap_1,-10 ) 

	local width = self.m_winSize.width
	local height= self.m_winSize.height
	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( width/2 , height/2 )
	self.m_settingView 	: addChild( self.mainContainer )

	self.mainContainer_2 	= cc.Node : create()
	self.mainContainer_2 	: setPosition( width/2 , height/2 )
	self.m_settingView 		: addChild( self.mainContainer_2 )

	self.mainContainer_2 	: setVisible( false )

	local function closeFunSetting( obj, touchEvent)
		if touchEvent == ccui.TouchEventType.ended then
	 		self : closeWindow()
	 	end
	end
   	local Btn_close 	= gc.CButton : create("general_view_close.png")
   	Btn_close  : setPosition( cc.p( self.m_winSize.width+45, self.m_winSize.height+20) )
   	Btn_close  : addTouchEventListener( closeFunSetting )
   	Btn_close  : setAnchorPoint(cc.p(1,1))
   	Btn_close  : setSoundPath("bg/ui_sys_clickoff.mp3")
  	Btn_close  : ignoreContentAdaptWithSize(false)
    Btn_close  : setContentSize(cc.size(120,120))
   	self.myBaseMap_1	: addChild( Btn_close , 1 )

	local function ButtonCallBack( obj, touchEvent )
   		self : touchEventCallBack( obj, touchEvent )
   	end
	local Btn_GoodsShow = gc.CButton : create()
	Btn_GoodsShow : loadTextures( "ui_GoodsShow.png")
	Btn_GoodsShow : setPosition( 30 , height/2 + 120  )
	Btn_GoodsShow : setTag( Tag_Btn_GoodsShow )
	Btn_GoodsShow : setAnchorPoint( 0, 0 )
	Btn_GoodsShow : addTouchEventListener( ButtonCallBack )
	self.m_settingView : addChild( Btn_GoodsShow,1 )

	self.Btn_Ranking = gc.CButton : create()
	self.Btn_Ranking : loadTextures( "ui_rank.png")
	self.Btn_Ranking : setAnchorPoint( 0, 0 )
	self.Btn_Ranking : setPosition( 30 , height/2 + 220 )
	self.Btn_Ranking : setTag( Tag_Btn_Ranking ) 
	self.Btn_Ranking : addTouchEventListener( ButtonCallBack )
	self.m_settingView : addChild( self.Btn_Ranking, 1 )

	self.allNode = {}
	local myPro = _G.GPropertyProxy : getMainPlay(): getPro()
 	local node = self : drawRole( myPro )
 	node : setPosition( -265, -200 )
 	self.mainContainer :addChild( node )


	print( "self.myType == ", self.myType )
   	if self.myType == GAME_6 then  -- 越级挑战
		self : changeView( false, GAME_6 )
   		self : REQ_STRIDE_ASK_RANK_DATA( GAME_6 )
   	else
   		self : REQ_STRIDE_ASK_RANK_DATA( GAME_5 )
		self : createFirstView()
   	end
end

function Welkin_FirstView.drawRole( self, myPro, size, num )
	local node  = cc.Node : create()

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

	local shadow = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  	shadow : setScale(2)
  	shadow : setPosition( 0, -200 )
  	node : addChild( shadow )

  	if self.m_resourcesArray[szImg1] == nil then
  		self.m_resourcesArray[szImg1] = true
  	end 

  	-- if self.m_resourcesArray[szImg2] == nil then
  	-- 	self.m_resourcesArray[szImg2] = true
  	-- end

  	if size ~= nil then
  		local function ButtonCallBack( obj, touchEvent )
	   		self : touchEventCallBack( obj, touchEvent )
	   	end

  		local myWidget = ccui.Widget : create()
  		myWidget : setContentSize( cc.size( 160, 420 ) )
  		myWidget : setTag( Tag_Btn_GroupSpine[num] )
  		myWidget : setTouchEnabled( true )
  		myWidget : setPosition( 0, 60 )
  		myWidget : addTouchEventListener( ButtonCallBack )
  		node 	 : addChild( myWidget )
  		-- if myPro ~= 5 then
  		-- 	node : setScale( size, size )
  		-- else
  			node : setScale( size)
  		-- end
  	-- else
  		-- if myPro == 5 then
  		-- 	node : setScaleX( -1 )
  		-- end
  	end

  	return node
end

function Welkin_FirstView.createFirstView( self )
	if self.myFisrtView == nil then
		local function ButtonCallBack( obj, touchEvent )
	   		self : touchEventCallBack( obj, touchEvent )
	   	end

		local Tag_ChangeNum = {               [1] = 10, 
										 [5] = 8, [6] = 9, 
									 [9] = 5, [10] = 6, [11] = 7, 
							    [13] = 1, [14] = 2, [15] = 3, [16] = 4  }
		self.Btn_TiaoZhanSpr = {}
		self.Spr_Lock = {}
		self.Btn_GoodsGet = {}
		self.Spr_GoodsGet = {}
		self.Spr_Death    = {}
		local sizeX = { 270, 410, 550, 690 }
		local sizeY = 15
		for i=1,4 do
			local height = self.m_winSize.height/2-i*115-60

			local base = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_base.png" )
			base : setPosition( self.m_winSize.width/2+10, height + sizeY )
			base : setPreferredSize( cc.size(sizeX[i], 96) )
			base : setAnchorPoint( 1, 0.5 )
			self.mainContainer : addChild( base, 1 )
			for k=1,i do
				local num 	 = Tag_ChangeNum[k+i*4-4]  
				local Btn_TiaoZhanSpr = gc.CButton : create()
				Btn_TiaoZhanSpr : loadTextures( "head_1.png")
				Btn_TiaoZhanSpr : setPosition( self.m_winSize.width/2 - (k-1)*140 - 130, height + sizeY)		
				Btn_TiaoZhanSpr : setAnchorPoint( 1, 0.5 )	
				Btn_TiaoZhanSpr : setTag( num ) 
				Btn_TiaoZhanSpr : addTouchEventListener( ButtonCallBack )
				self.mainContainer : addChild( Btn_TiaoZhanSpr,2 )
				self.Btn_TiaoZhanSpr[num] = Btn_TiaoZhanSpr
				Btn_TiaoZhanSpr : setTouchEnabled( false )
				Btn_TiaoZhanSpr : setGray()

				local width  = Btn_TiaoZhanSpr : getContentSize().width
				local height = Btn_TiaoZhanSpr : getContentSize().height
				self.Spr_Lock[num] = cc.Sprite : createWithSpriteFrameName( "main_lock.png" )
				self.Spr_Lock[num] : setPosition( width-20,  20 )
				Btn_TiaoZhanSpr : addChild( self.Spr_Lock[num] )

				self.Spr_Death[num] = cc.Sprite : createWithSpriteFrameName( "Death.png" )
				self.Spr_Death[num] : setPosition( width/2,  height/2 )
				-- self.Spr_Death[num] : setAnchorPoint( 0, 0 )
				Btn_TiaoZhanSpr : addChild( self.Spr_Death[num] )

				self.Spr_Death[num] : setVisible( false ) 
			end
			local height = self.m_winSize.height/2-(5-i)*115-60
			local Btn_GoodsGet = gc.CButton : create()
			Btn_GoodsGet : loadTextures( "ui_Goods.png")
			Btn_GoodsGet : setAnchorPoint( 1, 0.5 )
			Btn_GoodsGet : setPosition( self.m_winSize.width/2-25, height + sizeY )
			Btn_GoodsGet : setTag( Tag_Btn_GoodsGet[i] ) 
			Btn_GoodsGet : addTouchEventListener( ButtonCallBack )
			self.mainContainer : addChild( Btn_GoodsGet,2 )
			self.Btn_GoodsGet[i] = Btn_GoodsGet

			local Spr_GoodsGet = cc.Sprite : createWithSpriteFrameName( "ui_Get.png" )
			Spr_GoodsGet : setVisible( false )
			Spr_GoodsGet : setPosition( Btn_GoodsGet:getContentSize().width/2, Btn_GoodsGet:getContentSize().height/2 )
			Btn_GoodsGet : addChild( Spr_GoodsGet )
			self.Spr_GoodsGet[i] = Spr_GoodsGet
		end

		self : createFlag()
		self.myFisrtView = true
	end
end

function Welkin_FirstView.createFlag( self )
	local function ButtonCallBack( obj, touchEvent )
   		self : touchEventCallBack( obj, touchEvent )
   	end
   	local Spr_Flag = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_base.png" )
	Spr_Flag : setPreferredSize( cc.size( self.m_winSize.width+12, 70 ) )
	Spr_Flag : setAnchorPoint( 0.5, 0 )
	Spr_Flag : setPosition( 0, -self.m_winSize.height/2-7 )
	self.mainContainer : addChild( Spr_Flag, -1 )

	local flagNode = cc.Node : create()
	flagNode : setPosition( self.m_winSize.width/2, 35 )
	Spr_Flag : addChild( flagNode, 1 )

	local Text_flag  = { "我的排名:", "所属组别:", "竞技积分:", "挑战次数:", }
	-- local Pos_flagx  = { -420, -260, -50 , 140 }
	local leftX = -self.m_winSize.width/2
	local Pos_flagx  = { leftX+40, leftX+200, leftX+410, leftX+585 }

	local myColor 	 = { COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN } 
	self.Lab_flagText = {}
	for i=1,4 do
		local width = Pos_flagx[i]
		local lab = _G.Util : createLabel( Text_flag[i], FONTSIZE )
		lab : setAnchorPoint( 0, 0.5 )
		lab : setPosition( width ,0 )
		lab : setColor( myColor[i*2-1] )
		flagNode : addChild( lab )
		width = width + lab:getContentSize().width

		self.Lab_flagText[i] = _G.Util : createLabel( "", FONTSIZE )
		self.Lab_flagText[i] : setAnchorPoint( 0, 0.5 )
		self.Lab_flagText[i] : setPosition( width ,0 )
		self.Lab_flagText[i] : setColor( myColor[i*2] )  
		flagNode : addChild( self.Lab_flagText[i] )
	end

	self.Btn_AddTime = gc.CButton : create()
	self.Btn_AddTime : loadTextures( "general_btn_add.png")
	self.Btn_AddTime : setPosition( Pos_flagx[4]+90 , 0 )
	self.Btn_AddTime : setAnchorPoint( 0, 0.5 )
	self.Btn_AddTime : setTag( Tag_Btn_AddTime ) 
	self.Btn_AddTime : addTouchEventListener( ButtonCallBack )
	self.Btn_AddTime : ignoreContentAdaptWithSize(false)
  	self.Btn_AddTime : setContentSize(cc.size(85,85))
	flagNode : addChild( self.Btn_AddTime )

	self.Btn_OverFight = gc.CButton : create()
	self.Btn_OverFight : loadTextures( "general_btn_gold.png")
	self.Btn_OverFight : setTitleText( "越级挑战" )
	self.Btn_OverFight : setTitleFontName( _G.FontName.Heiti )
	self.Btn_OverFight : setTitleFontSize( FONTSIZE+2 )
	-- self.Btn_OverFight : setButtonScale( 0.8  )
	self.Btn_OverFight : setAnchorPoint( 1, 0.5 )
	self.Btn_OverFight : setPosition( self.m_winSize.width/2-20 , 0 )
	self.Btn_OverFight : setTag( Tag_Btn_OverFight ) 
	self.Btn_OverFight : addTouchEventListener( ButtonCallBack )
	flagNode : addChild( self.Btn_OverFight,3 )
	
end

function Welkin_FirstView.ChangeFirstView( self, _ackMsg )
	local msg = _ackMsg
	local group = msg.zdata.group
	print( "group = ", msg.zdata.rank,group )
	self.Lab_flagText[1] : setString( msg.zdata.rank )
	self.Lab_flagText[2] : setString( Text_Group[group] )
	self.Lab_flagText[3] : setString( msg.zdata.calculus )
	self.Lab_flagText[4] : setString( msg.num )

	-- local times = msg.times
	-- local function step1()
	-- 	if times <= 0 then 
	-- 		_G.Scheduler : unschedule( self.Scheduler )
 --      		self.Scheduler = nil
 --      		self.Lab_ReTime : setString( "活动已结束" )
	-- 	end
	-- 	local nowTime  	= _G.TimeUtil:getServerTimeSeconds()
	-- 	local myTime 	= times - nowTime
 --      	self.Lab_ReTime : setString( self:_getTimeStr(times) )
 --      	times = times - 1 
 --    end
 --    if times ~= 0 then
 --    	if self.Scheduler==nil then 
 --      		self.Scheduler = _G.Scheduler : schedule(step1, 1)
 --    	end
 --    end

    for i=1,msg.count do
    	local pro = msg.data[i].pro
    	local Frame = string.format( "head_%d.png", pro )
    	self.Btn_TiaoZhanSpr[i] : loadTextures( Frame )
    	if msg.data[i].is_war == 2 then
    		self.Btn_TiaoZhanSpr[i] : setGray()
    		self.Btn_TiaoZhanSpr[i] : setTouchEnabled( false )
    		self.Spr_Death[i] : setVisible( false )
     		self.Spr_Lock[i]  : setVisible( true )
    	elseif msg.data[i].is_war == 1 then
    		self.Btn_TiaoZhanSpr[i] : setDefault()
    		self.Btn_TiaoZhanSpr[i] : setTouchEnabled( true )
    		self.Spr_Death[i] : setVisible( false )
    		self.Spr_Lock[i] : setVisible( false )
    	else
    		self.Btn_TiaoZhanSpr[i] : setDefault()
    		self.Btn_TiaoZhanSpr[i] : setTouchEnabled( false )
    		self.Spr_Death[i] : setVisible( true )
    		self.Spr_Lock[i] : setVisible( false )
    	end
    end
end

function Welkin_FirstView.createShowView( self, _type, _ackMsg )
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
        self.m_rankLayer:removeFromParent(false)
        self.m_rankLayer=nil
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


    local m_titleLab=_G.Util:createBorderLabel("玉清元始榜",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(rankSize.width/2,rankSize.height-26)
    Spr1:addChild(m_titleLab)

    print("asjdlaksdjklasdjklasjdksdkdkiiiiiiiiiiiiiiiiiiii===>>>>>")

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(secondSize)
    di2kuanbg       : setPosition(cc.p(rankSize.width/2,rankSize.height/2-18))
    Spr1       : addChild(di2kuanbg)

	self : ShowRank( Spr1 ,_ackMsg, secondSize)
end

function Welkin_FirstView.ShowRank( self, _place, _ackMsg, _size)
	local place  = _place
	local msg    = _ackMsg
	local x 	 = 40
	local posx	 = { x, x+145, x+290, x+435, x+580 }
	local Text_1 = { "排行", "名字", "等级", "积分", "区服", }
	local rank   = msg.zdata.rank
	if rank >= 500 then 
		rank = string.format( "%d%s", msg.zdata.rank, "+" )
	end 
	local Text_2 = { rank, _G.GPropertyProxy : getMainPlay() : getName(), 
					 _G.GPropertyProxy : getMainPlay() : getLv(), self.calculus, string.format("[%s服]", _G.GLoginPoxy:getServerName()) }

	local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line1 : setPreferredSize( cc.size( _size.width-10, 3 ) )
	line1 : setPosition( 13, _size.height-26 )
	line1 : setAnchorPoint( 0, 1 )
	place : addChild( line1 )

	local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line2 : setPreferredSize( cc.size( _size.width-10, 3 ) )
	line2 : setPosition( 13, 43 )
	line2 : setAnchorPoint( 0, 1 )
	place : addChild( line2 )

	local line3 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line3 : setPreferredSize( cc.size( _size.width-10, 3 ) )
	line3 : setPosition( 13, 75 )
	line3 : setAnchorPoint( 0, 1 )
	place : addChild( line3 )

	local star = cc.Sprite : createWithSpriteFrameName( "general_star.png" )
	-- star  : setScale( 0.7 )
	star  : setPosition( x-10, 58 )
	place : addChild( star )

	local lab = _G.Util : createLabel( "积分排名前500名可参与上清灵宝!", 20 )
	-- lab : setAnchorPoint( 0, 0.5 )
	lab : setPosition( _size.width/2, 26 )
	lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	place : addChild( lab )

	for i=1,5 do
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
				local Text_3 = { msg.data[i].rank, msg.data[i].name, msg.data[i].lv, msg.data[i].arg,  string.format("[%s服]",serverName), }
				for k=1,5 do
					local lab = _G.Util : createLabel( Text_3[k], FONTSIZE )
					-- lab : setColor( COLOR_WHITE )
					lab : setPosition( posx[k]+20, mySizeY*count - i*mySizeY + 17  )
					ScrollView : addChild( lab )
					if i <=3 then
						lab : setColor( myColor[i] )
					end
				end
				local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
				line : setPreferredSize( cc.size( _size.width - 20, 2 ) )
				line : setPosition( posx[3]+35, mySizeY*count - i*mySizeY-1 )
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

function Welkin_FirstView._getTimeStr( self,_time)
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

function Welkin_FirstView.intoSecond( self )
	print( "self.Text_IntoSecond = ", self.Text_IntoSecond )
	if self.Text_IntoSecond == nil or self.Text_IntoSecond == 0 then 
		self : messageBox(1)
	elseif self.Text_IntoSecond == 1 then
		-- self : CreateSecondView()
		self : changeView( false, GAME_6 )
	else
		print("self.Text_IntoSecond 数据出错：", self.Text_IntoSecond )
	end
end
-- 3：同级人物挑战，6：越级挑战，2：购买挑战次数，1：越级挑战购买
function Welkin_FirstView.messageBox( self, _type, num, _power )
	local function tipsSure( )
		if _type == 1 then 
			self : REQ_STRIDE_STRIDE_UP()
		elseif _type == 2 then
			self : REQ_STRIDE_BUY_COUNT()
			print("self.myTag-----11111>>",self.myTag,self.data[self.myTag].uid)
		elseif _type == 3 then
			print( "同级挑战" )
			print( "进入战斗，num = ", num, self.data[num].name ,"各参数：", 5, self.data[num].sid, self.data[num].uid  )
			self : REQ_STRIDE_STRIDE_WAR( 5, self.data[num].sid, self.data[num].uid )
		elseif _type == 6 then
			print( "越级挑战" )
			print( "进入战斗，num = ", num, self.data[num].name ,"各参数：", 5, self.data[num].sid, self.data[num].uid  )
			self : REQ_STRIDE_STRIDE_WAR( 6, self.data[num].sid, self.data[num].uid )
		end
	end
	local function cancel(  )
		if self.fisSelectNode then
			self.fisSelectNode : removeFromParent(true)
			self.fisSelectNode = nil
		end
	end

	if _type == 2 and NoTouch then
		self : REQ_STRIDE_BUY_COUNT()
		return
	end
	local Title = { "购买越级挑战", "购买次数", "挑  战", "挑  战", "挑  战", "挑  战"  }
	local tipsBox 		= require("mod.general.TipsBox")()
	local ShowMessBox   = tipsBox :create( "", tipsSure, cancel)
	-- ShowMessBox : setPosition( cc.p( self.m_winSize.width/2, self.m_winSize.height/2 ) )
	tipsBox 	: setTitleLabel( Title[_type] )
	self.m_settingView : addChild( ShowMessBox, _G.Const.CONST_MAP_ZORDER_NOTIC, 332211 )

	local ShowMessBox=tipsBox:getMainlayer()
	if _type == 1 or _type == 2 then 
		local money = _G.Const.CONST_OVER_SERVER_BUY_YSTRIDE
		if _type == 2 then
			money = _G.Const.CONST_OVER_SERVER_BUY_PRICE
		end
		local Text_title = { "越级挑战？", "挑战次数？" }
		local lab_1 = _G.Util : createLabel( string.format( "%s%d%s%s" ,"花费", money, "元宝购买一次", Text_title[_type]), FONTSIZE )
		lab_1 : setPosition( 0, 60 )
		ShowMessBox : addChild( lab_1 )

		local lab_2 = _G.Util : createLabel( "（元宝不足消耗钻石）", FONTSIZE-2 )
		lab_2 : setPosition( 0, 30 )
		ShowMessBox : addChild( lab_2 )
		if _type == 1 then
			lab_1 : setPosition( 0, 40 )
			lab_2 : setPosition( 0, 10 )
		end

		if _type == 2 then
			local lab_3 = _G.Util : createLabel( "剩余购买次数：", FONTSIZE )
			lab_3 : setPosition( 0, -5 )
			ShowMessBox : addChild( lab_3 )

			local lab_4 = _G.Util : createLabel( self.buy_num, FONTSIZE )
			lab_4 : setPosition( lab_3:getContentSize().width/2+10, -5 )
			lab_4 : setColor( COLOR_GRASSGREEN )
			ShowMessBox : addChild( lab_4 )
			if self.buy_num <= 0 then
				lab_4 : setColor( COLOR_ORED )
			end

			local tipsWidget = ccui.Widget : create()
			tipsWidget : setContentSize( cc.size(31,31) )
			tipsWidget : setAnchorPoint( 0, 0 )
			local function checkBoxCallback( obj, touchEvent )
				if touchEvent == ccui.TouchEventType.began then	
					print(" 按下 " )
					NoTouch = true
				elseif touchEvent == ccui.TouchEventType.moved then
					print(" 移动 " )
					NoTouch = nil
				end
			end

			local uncheckBox 	= "general_gold_floor.png"
			local selectBox  	= "general_check_selected.png"
			local checkBox = ccui.CheckBox : create( uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType )
			checkBox : addEventListener( checkBoxCallback )
			checkBox : setPosition( cc.p( -80, -52 ) )
			-- checkBox : setAnchorPoint( 0, 0 )
			checkBox : setTag( Tag_NoTouch )
			ShowMessBox 	 : addChild(checkBox) 

			local CheckLabel = _G.Util : createLabel( _G.Lang.LAB_N[106], FONTSIZE )
			-- CheckLabel : setAnchorPoint( 0, 0 )
			CheckLabel : setPosition( 25, -50 )
			-- CheckLabel : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
			ShowMessBox	   : addChild( CheckLabel )
		end
	elseif _type == 3 or _type == 6 then
		local posx  	= 0
		local myWidget 	= ccui.Widget : create() 

		local lab_1 = _G.Util : createLabel( "您确定挑战", FONTSIZE )
		lab_1 : setAnchorPoint( 0, 0.5 )
		lab_1 : setPosition( posx, 35 )
		myWidget : addChild( lab_1 )
		posx = posx + lab_1:getContentSize().width

		local name = "玩家名字六字"
		local power = 9999999
		if self.data[num] ~= nil then
			name  = self.data[num].name
			power = _power
			if _power == 0 then
				power = self.data[num].power
			end
			
		end
		if self.power ~= nil and self.power[num] ~= nil then
			print( "name , power = ", num, name, power )
			self.power[num] : setString( string.format( "战力:%d", power ) )
		end

		local lab_2 = _G.Util : createLabel( name, FONTSIZE )
		lab_2 : setAnchorPoint( 0, 0.5 )
		lab_2 : setPosition( posx , 35 )
		lab_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
		myWidget : addChild( lab_2 )
		posx = posx + lab_2:getContentSize().width

		local lab_3 = _G.Util : createLabel( "么？", FONTSIZE )
		lab_3 : setAnchorPoint( 0, 0.5 )
		lab_3 : setPosition( posx, 35 )
		myWidget : addChild( lab_3 )
		posx = posx + lab_3:getContentSize().width

		myWidget : setContentSize( cc.size( posx, 1 ) )
		ShowMessBox : addChild( myWidget )

		local lab_4 = _G.Util : createLabel( string.format( "%s%d%s", "（对手战斗力：", power, "）"), FONTSIZE )
		lab_4 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD) )
		lab_4 : setPosition( 0, 0 )
		ShowMessBox : addChild( lab_4 )
	end

end

function Welkin_FirstView.changeView( self, isFalse, which )
	print( "isFalse = ", isFalse, not isFalse, which )
	self.mainContainer 	 : setVisible( isFalse )
	self.mainContainer_2 : setVisible( not isFalse )

	self : REQ_STRIDE_ASK_RANK_DATA( which )
	if which == GAME_5 then
		self : createFirstView()
	elseif which == GAME_6 then
		self : CreateSecondView()
	end
end

function Welkin_FirstView.GetGoods( self, _num, npos )
	local num = _num
	print( "领取哪个宝箱：", num, self.reward[num].cenci, self.reward[num].state )
	if self.reward[num].state == 1 then
  		self : REQ_STRIDE_AWARD_NUM( self.reward[num].cenci )
  	else
  		print( npos.x, npos.y, self.myCenci )
  		local cenci = self.myCenci
  		if cenci == 0 or cenci == nil then
  			cenci = 1
  		end
  		local goods = _G.Cfg.scores[cenci][num]
  		for i=1,#goods do
  			npos.x = npos.x - (i-1)*500 - 400
  			local goodsId  = goods[i][1]
  			local goodsNum = goods[i][2] 
  			self : ShowReward( i, goodsId, goodsNum, npos )
  		end
  	end
end

function Welkin_FirstView.ShowReward( self, num, goodsId, goodsNum, npos )
	print( npos.x, npos.y )
	local temp = _G.TipsUtil:createById(goodsId,nil,npos,0)
	local lablen=string.len(_G.Cfg.goods[goodsId].name)
	print("lablen==>>",lablen)
	local lab  = _G.Util : createLabel( string.format( "%s%d","*",goodsNum ), FONTSIZE )
	lab  : setAnchorPoint( 0, 0.5 ) 
	lab  : setPosition( 110+lablen*7, -50 )
	temp : addChild(lab)
    cc.Director:getInstance():getRunningScene():addChild(temp,1000)
end

function Welkin_FirstView.CreateSecondView( self )
	if self.mySecondView == nil then
		print( "进入CreateSecondView---------" )
		local function ButtonCallBack( obj, touchEvent )
			self : touchEventCallBack( obj, touchEvent )
		end

		self.Lab_GroupName2 = {}
		local base2Size = cc.size( 109, 160 )
		local spr_Base2 = ccui.Scale9Sprite : createWithSpriteFrameName( "base2.png" )
		spr_Base2 : setPreferredSize( base2Size )
		spr_Base2 : setAnchorPoint( 0, 0.5 )
		spr_Base2 : setPosition( -self.m_winSize.width/2+20, 0 )
		self.mainContainer_2 : addChild( spr_Base2, 5 )
		self.spr_Base2 = spr_Base2

		local posy = { 130, 83, 38 }
		for i=1,3 do
			local Lab_GroupName   = _G.Util : createLabel( "新手组", FONTSIZE )
			-- Lab_GroupName : setAnchorPoint( 0, 0 )
			Lab_GroupName : setPosition( base2Size.width/2, posy[i]-3 )
			Lab_GroupName : setColor( COLOR_WHITE )
			spr_Base2	  : addChild( Lab_GroupName, 2 ) 
			self.Lab_GroupName2[i] = Lab_GroupName
		end
		self : changeSelect( 1 )

	    self.widgetNode 	= {}
	    self.Lab_GroupName 	= {}
	    -- self.Lab_GroupLV	= {} 
	    -- self.Lab_lv  		= {}
	    self.Spr_GroupFight = {}
	    self.power 			= {}

	    local mySizeX 		= 230
	    for i=1,4 do
	    	local widgetNode 	 = cc.Node:create()
	    	-- widgetNode 			 : setContentSize( cc.size( mySizeX, 1 ) )
	    	widgetNode 			 : setPosition( -600 + i*200, 100 )
	    	self.mainContainer_2 : addChild( widgetNode )
	    	self.widgetNode[i] 	 = widgetNode 

	    	local dinsSpr = cc.Sprite:createWithSpriteFrameName("general_fram_dins.png")
	    	dinsSpr : setPosition( mySizeX/2, 0 )
	    	dinsSpr : setScaleX(0.9)
	    	self.widgetNode[i] : addChild( dinsSpr )

			-- local width = mySizeX/2
			-- local Lab_lv = _G.Util : createLabel( "LV.", FONTSIZE )
			-- Lab_lv : setAnchorPoint( 0, 0 )
			-- Lab_lv : setPosition( width, 47 )
			-- widgetNode 	 : addChild( Lab_lv, 2 ) 
			-- self.Lab_lv[i] = Lab_lv
			-- width = Lab_lv : getContentSize().width + width

			-- local Lab_GroupLV   = _G.Util : createLabel( "99", FONTSIZE )
			-- Lab_GroupLV : setAnchorPoint( 0, 0 )
			-- Lab_GroupLV : setPosition( width, 47 )
			-- widgetNode	: addChild( Lab_GroupLV, 2 ) 
			-- self.Lab_GroupLV[i] = Lab_GroupLV
			-- width = Lab_GroupLV : getContentSize().width + width

			local Lab_GroupName   = _G.Util : createLabel( "我是歌手的手", FONTSIZE )
			-- Lab_GroupName : setAnchorPoint( 0, 0 )
			Lab_GroupName : setPosition( mySizeX/2, 18 )
			widgetNode	  : addChild( Lab_GroupName, 2 ) 
			self.Lab_GroupName[i] = Lab_GroupName
			-- width = Lab_GroupName:getContentSize().width + width

			local power = _G.Util : createLabel( "", FONTSIZE )
			power 		: setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD ) )
			power 		: setPosition( mySizeX/2, -18 )
			widgetNode  : addChild( power )
			self.power[i] = power

			local Spr_GroupFight   = cc.Sprite : createWithSpriteFrameName( "Fight.png" )
			Spr_GroupFight	: setPosition( mySizeX/2, -330 )
			widgetNode : addChild( Spr_GroupFight, 3 )
			self.Spr_GroupFight[i] = Spr_GroupFight
	    end

	    local BaseSize    = cc.size( self.m_winSize.width+10, 70 ) 
	    local Base_MyAttr = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_base.png" )
	    Base_MyAttr : setPreferredSize( BaseSize )
	    Base_MyAttr : setAnchorPoint( 0.5, 0 )
	    Base_MyAttr : setPosition( 0, -self.m_winSize.height/2-7 )
	    self.mainContainer_2 : addChild( Base_MyAttr )

	    local OverNode = cc.Node : create()
	    OverNode : setPosition( -5, -self.m_winSize.height/2+2 )
	    self.mainContainer_2 : addChild( OverNode,3 )

		self.Lab_myAttr = {}
	    local Text  = { "我的排名:", "所属组别:", "竞技积分:", "挑战次数:" }
	    local leftX = -self.m_winSize.width/2
	    -- local Pos_flagx  = { -420, -260, -40 , 160 }
	    local Pos_flagx  = { leftX+39, leftX+199, leftX+409, leftX+584 }
	    local myColor 	 = { COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN }
	    for i=1,4 do
	    	local lab = _G.Util : createLabel( Text[i], FONTSIZE )
	    	lab : setAnchorPoint( 0, 0.5 )
	    	lab : setPosition( Pos_flagx[i], 26 )
	    	lab : setColor( myColor[i*2-1] )
	    	OverNode : addChild( lab )

	    	local lab_2 = _G.Util : createLabel( "", FONTSIZE )
	    	lab_2 : setAnchorPoint( 0, 0.5 )
	    	lab_2 : setColor( myColor[i*2] )
	    	lab_2 : setPosition( Pos_flagx[i]+lab:getContentSize().width, 26 )
	    	OverNode : addChild( lab_2 )
	  		self.Lab_myAttr[i] = lab_2
	    end

	    local Btn_Add = gc.CButton : create()
	    Btn_Add : loadTextures( "general_btn_add.png" )
	    Btn_Add : setAnchorPoint( 0, 0.5 )
	    Btn_Add : setPosition( Pos_flagx[4]+90, 26 )
		Btn_Add : setTag( Tag_Btn_AddTime )
		Btn_Add : addTouchEventListener( ButtonCallBack )
		Btn_Add : ignoreContentAdaptWithSize(false)
  		Btn_Add : setContentSize(cc.size(85,85))
		OverNode : addChild( Btn_Add )

		local Btn_ChangeView = gc.CButton : create()
	    Btn_ChangeView : loadTextures( "general_btn_gold.png" )
	    Btn_ChangeView : setAnchorPoint( 1, 0.5 )
	    -- Btn_ChangeView : setButtonScale( 0.8 )
	    Btn_ChangeView : setPosition( self.m_winSize.width/2-20, 26 )
	    Btn_ChangeView : setTitleText( "同级挑战" )
		Btn_ChangeView : setTitleFontName( _G.FontName.Heiti )
		Btn_ChangeView : setTitleFontSize( FONTSIZE+2 )
		Btn_ChangeView : setTag( Tag_Btn_ChangeView )
		Btn_ChangeView : addTouchEventListener( ButtonCallBack )
		OverNode : addChild( Btn_ChangeView )
		print( "结束CreateSecondView---------" )
		self.mySecondView = true
	end
end

function Welkin_FirstView.changeSelect( self, num )
	print( "11111" )

	local posy = { 127,81,35 }
	if self.select == nil then
		self.select = cc.Sprite : createWithSpriteFrameName( "welkin_select.png" )
		-- self.select : setAnchorPoint( 0, 0.5 )
		self.select : setPosition( 55, posy[num] )
		self.spr_Base2 : addChild( self.select, 3 )
	else
		self.select : setPosition( 55, posy[num] )
	end
	for i=1,3 do
		self.Lab_GroupName2[i] : setColor( COLOR_WHITE )
	end
	self.Lab_GroupName2[num] : setColor( COLOR_GOLD )
end

function Welkin_FirstView.addNewSpine( self, pro, num )

	local function ButtonCallBack( obj, touchEvent )
   		self : touchEventCallBack( obj, touchEvent )
   	end

    if pro == nil or num == nil then 
    	print( "Welkin_FirstView.addNewSpine数据出错：", pro, num )
    	return
    end

	-- local szImg = string.format( "painting/q1000%d.png", pro )
	-- self.Btn_GroupSpine[num] = _G.ImageAsyncManager:createNormalBtn(szImg, ButtonCallBack, Tag_Btn_GroupSpine[num])
	-- self.Btn_GroupSpine[num] : setButtonScale( 0.6 )
	-- self.Btn_GroupSpine[num] : setPosition( 230/2, -80 )
	-- self.widgetNode[num] 	 : addChild( self.Btn_GroupSpine[num],2 )
	-- -- print( "多大：", self.Btn_GroupSpine[num]:getContentSize().width )

	-- if self.NewShadow == nil then self.NewShadow = {} end
	-- if self.NewShadow[num] == nil then
	-- 	self.NewShadow[num] = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
	--   	self.NewShadow[num] : setPosition( 230/2, -190 )
	--   	self.widgetNode[num] : addChild( self.NewShadow[num] )
	-- end

	if self.newNode[num] ~= nil then
		self.newNode[num] : removeFromParent(true)
		self.newNode[num] = nil
	end

	self.newNode[num] 	 = self : drawRole( pro, 0.6, num )
	self.newNode[num] 	 : setPosition( 115, -310 )
	self.widgetNode[num] : addChild( self.newNode[num], 2 )
end

function Welkin_FirstView.ChangeSecondView( self, _ackMsg )
	local msg = _ackMsg
	if self.Lab_myAttr ~= nil then
		print( "this group = ", msg.cenci )
		self.Lab_myAttr[1] : setString( msg.zdata.rank )
		self.Lab_myAttr[2] : setString( Text_Group[msg.zdata.group] ) 
		self.Lab_myAttr[3] : setString( msg.zdata.calculus )
		self.Lab_myAttr[4] : setString( msg.num )
	end

	print( "  当前层次： ", msg.group )
	if self.spr_Base2 ~= nil then
		self : changeSelect( msg.group )
	end
	
	-- 数量为4
	local frame4 = cc.SpriteFrameCache : getInstance() : getSpriteFrame( "ui_win.png" )
	local frame5 = cc.SpriteFrameCache : getInstance() : getSpriteFrame( "Fight.png" )
	for i=1,msg.count do
		self : addNewSpine( msg.data[i].pro, i )
		self.Lab_GroupName[i] 	: setString(string.format("LV.%s %s",msg.data[i].lv, msg.data[i].name) )

		-- local width = self.Lab_lv[i] : getContentSize().width + 35
		-- self.Lab_GroupLV[i] 	: setString( msg.data[i].lv )
		self.Spr_GroupFight[i]	: setVisible( true )
		-- self.Lab_GroupName[i]  	: setPosition( width, 60 )

		self.power[i] : setString( string.format( "战力:%d", msg.data[i].power ) )

		if msg.data[i] ~= nil then
			if msg.data[i].is_war == 0 then 
				local target = self.newNode[i] : getChildByTag( 1 )
				target : setGray()
				-- local target2 = self.newNode[i] : getChildByTag( 2 )
				-- target2 : setGray()
				local target3 = self.newNode[i] : getChildByTag( Tag_Btn_GroupSpine[i] )
				target3 : setTouchEnabled( false )
				self.Spr_GroupFight[i] : setSpriteFrame( frame4 )
			else
				local target = self.newNode[i] : getChildByTag( 1 )
				target : setDefault()
				-- local target2 = self.newNode[i] : getChildByTag( 2 )
				-- target2 : setDefault()
				local target3 = self.newNode[i] : getChildByTag( Tag_Btn_GroupSpine[i] )
				target3 : setTouchEnabled( true )
				self.Spr_GroupFight[i] : setSpriteFrame( frame5 )
			end
		end
	end
	-- 数量不满，少于4个的时候
	if msg.count < 4 then
		for i=msg.count+1,4 do
			self : removeOneSpine( i )
			self.Lab_GroupName[i] 	: setString( "LV.0 暂无" )
			-- local width = self.Lab_GroupName[i] : getContentSize().width + 5
			-- self.Lab_lv[i]			: setPosition( width, 0 )
			-- self.Lab_GroupLV[i] 	: setString( "0" )
			-- width = width + self.Lab_lv[i] : getContentSize().width
			-- self.Lab_GroupLV[i] 	: setPosition( width, 0 )
			self.Spr_GroupFight[i]	: setVisible( false )
		end
	end
end

function Welkin_FirstView.removeOneSpine( self, num )
	if self.newNode[num] ~= nil then
		self.newNode[num] : removeFromParent(true)
		self.newNode[num] = nil
	end
end

function Welkin_FirstView.changeGroup( self, _which )
	local which  = _which
	if self.spr_Base2 ~= nil then
		self : changeSelect(which)
	end
end

function Welkin_FirstView.changeFisrtSelect( self )
	if self.fisSelectNode ~= nil then
		self.fisSelectNode : removeFromParent(true)
	end
	self.fisSelectNode = cc.Node : create()

	local spr = cc.Sprite : createWithSpriteFrameName( "ui_choose.png" )
	spr : setAnchorPoint( 0, 0 )
	spr : setPosition( -6, -8 )
	self.fisSelectNode : addChild( spr )

	return self.fisSelectNode
end

function Welkin_FirstView.closeWindow( self )
	print( "开始关闭" )
	if self.Scheduler ~= nil then 
      	_G.Scheduler : unschedule( self.Scheduler )
      	self.Scheduler = nil
    end

    ScenesManger.releaseFileArray(self.m_resourcesArray)

	self.m_mediator : destroy()
	self.m_mediator = nil
	cc.Director : getInstance() : popScene()
end

function Welkin_FirstView.REQ_STRIDE_ASK_RANK_DATA( self, num )
	local msg = REQ_STRIDE_ASK_RANK_DATA()
	msg : setArgs( num )
	_G.Network : send( msg )
end

function Welkin_FirstView.Net_RANK_DATA( self, _ackMsg )
	local msg = _ackMsg
	print( "当前返回的信息号为：", msg.type )
	print("	数量			:",	msg.count		)
	print("	剩余的挑战次数:",	msg.num		)
	-- if msg.times ~= 0 then
	-- 	msg.times= msg.times - _G.TimeUtil : getServerTimeSeconds()
	-- 	if msg.times < 0 then 
	-- 		msg.times = msg.times + 3600*24
	-- 	end
	-- else
	-- 	print( "收到时间0，我打开了别人的界面!" )
	-- end
	-- print("	结束倒计时	:",	self:_getTimeStr(msg.times) )
	print("	组别			:",	msg.cenci		)
	print(" 当前挑战组别	:", msg.group  		)
	print(" 剩余的购买次数		:", msg.buy_num )
	self.buy_num  = msg.buy_num
	self.myCenci  = msg.cenci
	self.calculus = msg.zdata.calculus
	print("	当前排名		:",	msg.zdata.rank	)
	print("	昨日排名		:",	msg.zdata.zrank	)
	print("	级别组		:",	msg.zdata.group	)
	print("	当前积分		:",	msg.zdata.calculus	)
	print("	昨日积分		:",	msg.zdata.zcalculus	)
	print("	战斗力		:",	msg.zdata.power	)
	print("	越级 0:未买 1:已买	:",	msg.zdata.is_buy, "\n"	)
	self.is_buy = msg.zdata.is_buy
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
	self.buyTimes   = msg.num	
	if msg.type == GAME_5 then
		self.Text_IntoSecond = msg.zdata.is_buy
		self : ChangeFirstView( msg )
	elseif msg.type == GAME_6 then
		self : ChangeSecondView( msg )
	end
end

function Welkin_FirstView.Net_CAN_AWARD( self, _ackMsg )
	local msg = _ackMsg
	print( "可领取数量：", msg.count )
	for i=1,msg.count do
		print( "第", i, "个，编号为：", msg.cenci )
	end
end

function Welkin_FirstView.Net_CAN_AWARD_SEC( self, _ackMsg )
	local msg = _ackMsg
	print( "数量：", msg.count )
	self.reward = msg.rewardMsg
	for i=1,msg.count do
		print( "层次编号：", msg.rewardMsg[i].cenci )
		print( "0:未领 1:可领 2:已领，", msg.rewardMsg[i].state )
		if msg.rewardMsg[i]~= nil then
			if msg.rewardMsg[i].state == 0 then
				self.Btn_GoodsGet[i] : setGray()
			elseif msg.rewardMsg[i].state == 2 then
				self.Btn_GoodsGet[i] : setDefault()
				self.Spr_GoodsGet[i] : setVisible( true )
			else
				self.Btn_GoodsGet[i] : setDefault()
			end
		end
	end
end

function Welkin_FirstView.REQ_STRIDE_AWARD_NUM( self, _which )
	local msg = REQ_STRIDE_AWARD_NUM()
	msg : setArgs( _which  )
	_G.Network : send( msg )
end

function Welkin_FirstView.Net_AWARD_OK( self, _cenci )
	print( "成功领取的宝箱：", _cenci )
	self.Btn_GoodsGet[_cenci] : setDefault()
	self.Spr_GoodsGet[_cenci] : setVisible(true)
	self.reward[_cenci].state = 2
end

function Welkin_FirstView.createGoodsShow( self )
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

    local text_battle = _G.Cfg.conquest
    local myColor = { COLOR_WHITE, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE }
    local myText  = { "名次：", "第", "", "名", "奖励：", "", "*", "" }
    local function createOneGood( num )
    	myText[3] = text_battle[num].ranking_max
    	if text_battle[num].ranking_max ~= text_battle[num].ranking_min then 
    		myText[3] = string.format( "%d%s%d", text_battle[num].ranking_max, "-", text_battle[num].ranking_min )
    	end
    	myText[6] = _G.Cfg.goods[text_battle[num].goods[1][1]].name
    	myText[8] = text_battle[num].goods[1][2] 
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

function Welkin_FirstView.REQ_STRIDE_STRIDE_UP( self )
	local msg = REQ_STRIDE_STRIDE_UP()
	_G.Network : send( msg )
end

function Welkin_FirstView.Net_BUY_CG( self )
	self.Text_IntoSecond = 1
	self : changeView( false, GAME_6 )
end

function Welkin_FirstView.REQ_STRIDE_BUY_COUNT( self )
	local msg = REQ_STRIDE_BUY_COUNT()
	msg : setArgs(1)
	_G.Network : send(msg)
end

function Welkin_FirstView.Net_BUY_OK( self, _ackMsg )
	print( "购买成功，剩余次数为：", _ackMsg.count )
	print( "购买成功，剩余次数为：", _ackMsg.buy_num )
	self.buyTimes = _ackMsg.count
	self.buy_num  = _ackMsg.buy_num
	if self.Lab_flagText ~= nil and self.Lab_flagText[4] ~= nil then
		self.Lab_flagText[4] : setString( self.buyTimes )
	end
	if self.Lab_myAttr ~= nil and self.Lab_myAttr[4] ~= nil then 
		self.Lab_myAttr[4] : setString( self.buyTimes )
	end
	if self.isFight == true then
		self.isFight = false
		print( "self.changeTomyType = ", self.changeTomyType, self.data[self.myTag].name )
		self : REQ_STRIDE_STRIDE_WAR( self.changeTomyType, self.data[self.myTag].sid, self.data[self.myTag].uid )
	end
end

function Welkin_FirstView.REQ_STRIDE_STRIDE_WAR( self, _type, _sid ,_uid )
	print( "保留的_type = ", _type, _sid )
	_G.StageXMLManager : setServerId( _sid )
	_G.StageXMLManager : setScenePkType( _type )
	_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_OVER_SERVER_PEAK_ID)
	local property  = _G.GPropertyProxy.m_lpMainPlay
    local originKey = property:getPropertyKey()
    local szKey 	= gc.Md5Crypto:md5(originKey,string.len(originKey))
	local msg = REQ_STRIDE_STRIDE_WAR()
	msg : setArgs( _type, _uid, szKey )
	_G.Network : send( msg )
end

function Welkin_FirstView.REQ_STRIDE_RANK( self, _which )
	local msg = REQ_STRIDE_RANK()
	msg : setArgs( _which )
	_G.Network : send( msg )
end

function Welkin_FirstView.Net_RANK_HAIG( self, _ackMsg )
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
	self : createShowView( 2, msg ) 
end

function Welkin_FirstView.REQ_STRIDE_ASK_POWER( self, _uid )
	local msg = REQ_STRIDE_ASK_POWER()
	msg : setArgs( _uid )
	_G.Network : send( msg )
end

function Welkin_FirstView.Net_POWER_BACK( self, _power )
	if self.Btn_TiaoZhanSpr ~= nil then
		self.Btn_TiaoZhanSpr[self.myTag] : addChild( self : changeFisrtSelect(), 1 )
	end
	self : messageBox( self.mystyle, self.myTag, _power )
end

function Welkin_FirstView.Net_SYSTEM_ERROR( self, _ackMsg )
	local errorNum = _ackMsg.error_code
	print( "error_code= ", errorNum )
	if errorNum == 27190 then 
		self.isFight = true
		-- self : messageBox( 2 )
	end
end

function Welkin_FirstView.Net_YJ_GROUP( self, _ackMsg )
	local msg = _ackMsg
	print( "	数量： ", msg.count  	)
	for i=1,msg.count do
		print( "	组别： ", msg.group[i] 	)
		self.Lab_GroupName2[i] : setString( Text_Group[ Group[ msg.group[i] ] ] ) 
	end
end

function Welkin_FirstView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print(" 按下 ", tag)
	elseif touchEvent == ccui.TouchEventType.moved then
		print(" 移动 ", tag)
  	elseif touchEvent == ccui.TouchEventType.ended then
  		print(" 抬起 ", tag )	
  		if tag == Tag_Btn_GoodsShow then 
  			-- self : createShowView( 1 )
  			self : createGoodsShow()
  		elseif Tag_Btn_GoodsGet[1] <= tag and tag <=Tag_Btn_GoodsGet[4] then
  		-- 同级：领取宝物箱
  			self : GetGoods( tag -100, obj:getWorldPosition())
  		elseif 1 <= tag and tag <= 10 then  
  		-- 同级：人物头像点击
  			self.myTag = tag
  			if self.buyTimes <= 0 then
  				self : messageBox(2)
  				return
  			end
  			self.mystyle = 3
  			self.changeTomyType = GAME_5
  			self : REQ_STRIDE_ASK_POWER( self.data[self.myTag].uid )
  		elseif Tag_Btn_GroupSpine[1] <= tag and tag <= Tag_Btn_GroupSpine[4] then
  		-- 越级：挑战人物
  			self.myTag = tag-510
  			if self.buyTimes <= 0 then
  				self.changeTomyType = GAME_6
  				self.isFight=true
  				self : messageBox(2)
  				return
  			end
  			self.mystyle = 6
  			self.changeTomyType = GAME_6
  			self : REQ_STRIDE_ASK_POWER( self.data[self.myTag].uid )
  		elseif tag == Tag_Btn_OverFight then
  			self : intoSecond()
  		elseif tag == Tag_Btn_Ranking or tag == Tag_Btn_Rank_6 then
  			print( "RANK_1 = ", RANK_1 )
  			self : REQ_STRIDE_RANK( RANK_1 )
  		elseif tag == Tag_Btn_AddTime then 
  			self : messageBox( 2 )
  		elseif tag == Tag_Btn_ChangeView then
  			self : changeView( true, GAME_5 )
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ",  tag)
  	end
end

return Welkin_FirstView