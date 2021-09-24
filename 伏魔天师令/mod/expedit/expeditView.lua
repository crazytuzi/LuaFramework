local expeditView = classGc( view, function( self )

	self.m_winSize  = cc.Director : getInstance() : getVisibleSize()

    self.Reply_ackMsg 	= {}
    self.Pk_ackMsg		= {}
    self.Scheduler_r 	= false

	self.m_mediator = require("mod.expedit.expeditMediator")() 
	self.m_mediator : setView(self) 
end)

local FONTSIZE 	= 20

local Tag_Btn_close     = 9999
local Tag_Btn_Close 	= 101

local Tag_ZhanBao 		= 1001
local Tag_Rongyao 		= 1005
local Tag_Shenglv 		= 1006 
local Tag_Times 		= 1007 
local Tag_SurplusTimes  = 1111
local Tag_Btn_Zhanbao 	= 1112

local Tag_S_id			= 2001
local Tag_Pair_start 	= 2002
local Tag_Btn_ShenZhi	= 2004
local Tag_Lab_MyShenzhi = 2005

local Tag_MessIsTouch 	= 3001

local Tag_View_ZhanBao 	= 4001

local Buys = 0

local Is_Create 		= false

function expeditView.create( self )
	self.m_settingView = cc.Scene : create()
	self : init()

	return self.m_settingView
end

function expeditView.init( self )
	-- 发送协议
	self : REQ_EXPEDIT_REQUEST()

	-- 初始化界面
	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2 ) )
	self.m_settingView 	: addChild( self.mainContainer )

	local myBaseMap 	= cc.Sprite:create( "ui/bg/expidit_baseMap.jpg" )
	-- myBaseMap : setScale( 1.2 )
	self.mainContainer 	: addChild( myBaseMap ) 

	local function closeFunSetting( obj, touchEvent)
		if touchEvent == ccui.TouchEventType.ended then
	 		self : closeWindow()
	 	end
	end
   	local Btn_close = gc.CButton : create()
   	Btn_close  : loadTextures("general_view_close.png") 
   	Btn_close  : setAnchorPoint(cc.p(1,1))
   	Btn_close  : setPosition( cc.p( self.m_winSize.width/2+13, self.m_winSize.height/2+20) )
   	Btn_close  : setTag( Tag_Btn_close )
   	Btn_close  : setSoundPath("bg/ui_sys_clickoff.mp3")
   	Btn_close  : addTouchEventListener( closeFunSetting )
   	Btn_close:ignoreContentAdaptWithSize(false)
    Btn_close:setContentSize(cc.size(120,120))
   	self.mainContainer	: addChild( Btn_close , 1 )

   	self.proNum=_G.SysInfo:isIpNetwork() and 3 or 2
   	-- 战报创建
   	self : CreateZhanBao()
   	--人物界面创建
   	self : CreateView()

   	self : CreateAllSpine()
end

function expeditView.CreateZhanBao( self )

   	local function ButtonCallBack( obj, touchEvent )
   		self : touchEventCallBack( obj, touchEvent )
   	end

   	local ZhanBaoBaseMap = ccui.Widget : create( )
   	ZhanBaoBaseMap : setContentSize( cc.size( 936, 50 ) )
   	ZhanBaoBaseMap : setPosition( 0, -520 )
   	ZhanBaoBaseMap : setTag( Tag_ZhanBao )
   	self.mainContainer : addChild( ZhanBaoBaseMap,1 )

   	local width  = 850
   	local height = 50

   	local lineSize   = cc.size( self.m_winSize.width, 50 )
   	local lineLayer  = cc.LayerColor:create(cc.c4b(0,0,0,255*0.5))
    lineLayer  : setPosition( -self.m_winSize.width/2, -self.m_winSize.height/2 )
    lineLayer  : setAnchorPoint( 0.5, 0 )
    lineLayer  : setContentSize(lineSize)
    self.mainContainer  : addChild(lineLayer) 

   	local Btn_ZhanBao = gc.CButton : create()
   	Btn_ZhanBao : loadTextures( "general_wrod_zb.png", "", "", ccui.TextureResType.plistType )
   	Btn_ZhanBao	: setPosition( cc.p( -self.m_winSize.width/2 + 100, -self.m_winSize.height/2 + 27 ) ) 
   	Btn_ZhanBao : addTouchEventListener( ButtonCallBack )
   	Btn_ZhanBao : setTag( Tag_Btn_Zhanbao )
   	self.mainContainer : addChild( Btn_ZhanBao )  

   	local text_1 = _G.Util : createLabel( "修为: ", FONTSIZE )
   	local text_2 = _G.Util : createLabel( "胜率: ", FONTSIZE )
   	local text_3 = _G.Util : createLabel( "今日剩余次数: ", FONTSIZE )

   	text_1 : setAnchorPoint( 0, 0.5 )
   	text_2 : setAnchorPoint( 0, 0.5 )
   	text_3 : setAnchorPoint( 0, 0.5 )

   	text_1 : setPosition( cc.p( 180, 250 ) )
   	text_2 : setPosition( cc.p( width/2-30 , 250 ) )
   	text_3 : setPosition( cc.p( width-170 , 250 ) )
   	-- text_1 : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD) )
   	-- text_2 : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD) )
   	-- text_3 : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD) )
   	ZhanBaoBaseMap : addChild( text_1 )
   	ZhanBaoBaseMap : addChild( text_2 )
   	ZhanBaoBaseMap : addChild( text_3 )

   	-- print( "xxx= ", 150/width, 320/width, 680/width, 730/width )
   	local Text_Rongyao	= _G.Util : createLabel( "", FONTSIZE )  -- 修为text
   	Text_Rongyao 	: setPosition( cc.p( 180 + text_1:getContentSize().width, 250 ) )
   	Text_Rongyao 	: setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN  ) )
   	Text_Rongyao 	: setTag( Tag_Rongyao )
   	Text_Rongyao 	: setAnchorPoint( cc.p(0, 0.5) )
	ZhanBaoBaseMap	: addChild( Text_Rongyao )

   	local Text_Shenglv 	= _G.Util : createLabel( "", FONTSIZE )  -- 胜率text
   	Text_Shenglv	: setPosition( cc.p( width/2-30+text_2:getContentSize().width, 250 ) ) 
   	Text_Shenglv 	: setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN  ) )
	Text_Shenglv 	: setTag( Tag_Shenglv )
	Text_Shenglv    : setAnchorPoint( cc.p(0, 0.5) )
	ZhanBaoBaseMap	: addChild( Text_Shenglv )

   	local Text_times= _G.Util : createLabel( "", FONTSIZE ) 	-- 次数text	
   	Text_times		: setPosition( cc.p( width-170+text_3:getContentSize().width, 250 ) )
   	Text_times 		: setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN ) )
   	Text_times      : setAnchorPoint( cc.p(0, 0.5) )
   	Text_times 		: setTag( 	Tag_Times 	 )
   	ZhanBaoBaseMap	: addChild( Text_times   )

   	local Btn_SurplusTimes = gc.CButton : create()
   	Btn_SurplusTimes : loadTextures( "general_btn_add.png") 
   	Btn_SurplusTimes : setPosition( cc.p( width+10, 250 ) )
   	Btn_SurplusTimes : setTag( Tag_SurplusTimes )
   	Btn_SurplusTimes : addTouchEventListener( ButtonCallBack )
   	Btn_SurplusTimes : ignoreContentAdaptWithSize(false)
  	Btn_SurplusTimes : setContentSize(cc.size(85,85))
   	ZhanBaoBaseMap	 : addChild( Btn_SurplusTimes )
end

function expeditView.CreateView( self )

	local function ButtonCallBack( obj, touchEvent )
   		self : touchEventCallBack( obj, touchEvent )
   	end

	-- 判定人物职业 
	local myProperty=_G.GPropertyProxy : getMainPlay()
	self.m_skeleton = {}
	-- self.shadow 	= {}
	self : showRoleSpine( 1, myProperty : getPro(), myProperty:getSkinWeapon(), myProperty:getSkinFeather() ) 

	local Btn_Pair_start = gc.CButton : create()
	Btn_Pair_start : loadTextures( "expidit_find.png")
	Btn_Pair_start : setPosition( cc.p(0, -150) )
	Btn_Pair_start : setTag( Tag_Pair_start )
	Btn_Pair_start : addTouchEventListener( ButtonCallBack )
	self.mainContainer : addChild( Btn_Pair_start )

	local Spr_Vs = cc.Sprite : createWithSpriteFrameName( "expidit_Vs.png" )
	Spr_Vs : setPosition( 0, -10 )
	self.mainContainer : addChild( Spr_Vs )

	local Btn_ShenZhi = gc.CButton : create()
	Btn_ShenZhi : loadTextures( "expidit_Shenzhi.png")
	Btn_ShenZhi : setAnchorPoint( 0, 1 )
	Btn_ShenZhi : setPosition( -self.m_winSize.width/2+30, 300 )
	Btn_ShenZhi : setTag( Tag_Btn_ShenZhi )
	Btn_ShenZhi : addTouchEventListener( ButtonCallBack )
	self.mainContainer : addChild( Btn_ShenZhi )

	local framSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_dins.png")
	framSpr:setPreferredSize(cc.size(200,110))
	framSpr:setPosition(-280,140)
	self.mainContainer : addChild( framSpr )

	self.Lab_myShenzhi = _G.Util : createLabel( "", FONTSIZE )
	self.Lab_myShenzhi : setPosition( -280, 175 )
	self.Lab_myShenzhi : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN) )
	-- self.Lab_myShenzhi : setAnchorPoint( 0, 0.5 )
	self.mainContainer : addChild( self.Lab_myShenzhi )

	-- 名字，等级
	local Lab_MyName = _G.Util : createLabel( string.format("LV%d %s", _G.GPropertyProxy : getMainPlay(): getLv(),_G.GPropertyProxy : getMainPlay(): getName()), FONTSIZE  )
	Lab_MyName : setPosition( -280, 150 )
	-- Lab_MyName : setAnchorPoint( 0, 0.5 )
	self.mainContainer : addChild( Lab_MyName )

	self.lab_power = {}
	self.lab_power[1] = _G.Util : createLabel( "", FONTSIZE )
	self.lab_power[1] : setPosition( -280, 130 )
	self.lab_power[1] : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
	self.mainContainer :addChild( self.lab_power[1] )

	local Text_s_id = _G.Util : createLabel( "", FONTSIZE )
	Text_s_id : setTag( Tag_S_id )
	Text_s_id : setPosition( cc.p( -280, 105 ) )
	Text_s_id : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORANGE ) )
	self.mainContainer : addChild( Text_s_id, 1 )

	local myPow = _G.GPropertyProxy : getMainPlay() :getAllsPower()
	print( "我的战斗力为：", myPow )
	self : createPowerNum( myPow, 1 )

	-- 对手信息
	self.myNode = cc.Node : create()
	self.mainContainer : addChild( self.myNode )

	local framSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_dins.png")
	framSpr:setPreferredSize(cc.size(200,110))
	framSpr:setPosition(280,140)
	self.myNode : addChild( framSpr )

	self.Lab_EnemyShenzhi = _G.Util : createLabel( "", FONTSIZE )
	self.Lab_EnemyShenzhi : setPosition( 280, 175 )
	-- self.Lab_EnemyShenzhi : setAnchorPoint( 0, 0.5 )
	self.Lab_EnemyShenzhi : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN) )
	self.myNode : addChild(self.Lab_EnemyShenzhi )

	local Lab_EnemyLv = _G.Util : createLabel( "", FONTSIZE  )
	Lab_EnemyLv : setPosition( 280, 150  )
	self.myNode : addChild( Lab_EnemyLv )
	self.Lab_EnemyLv = Lab_EnemyLv

	self.lab_power[2] = _G.Util : createLabel( "", FONTSIZE -2 )
	-- self.lab_power[2] : setAnchorPoint( 0, 0.5 )
	self.lab_power[2] : setPosition( 280, 130 )
	self.lab_power[2] : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
	self.myNode : addChild( self.lab_power[2] )

	local Lab_EnemyFu = _G.Util : createLabel( "", FONTSIZE )
	Lab_EnemyFu : setPosition( cc.p( 280, 105 ) )
	Lab_EnemyFu : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORANGE ) )
	self.myNode : addChild( Lab_EnemyFu, 1 )
	self.Lab_EnemyFu = Lab_EnemyFu

	self.EnemyPit = cc.Node : create()
	self.mainContainer : addChild( self.EnemyPit )

	local EnemyPit = cc.Sprite : create( "ui/bg/expidit_Yingzi.png" )
	EnemyPit : setScale( 1.6 )
	EnemyPit : setPosition( 290, -85 )
	self.EnemyPit   : addChild( EnemyPit )

	-- local shadow =  cc.Sprite:createWithSpriteFrameName("general_shadow.png")
 --  	shadow : setPosition(0, 0)
 --  	shadow : setScale(1.8)
 --  	self.EnemyPit : addChild(shadow,5)

	self.myNode : setVisible( false )
end

function expeditView.CreateAllSpine( self )
	self.mainContainer2 = cc.Node : create()
	self.mainContainer2 : setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2 ) )
	self.m_settingView 	: addChild( self.mainContainer2,3 )

	self.newSpine = {}
	-- local myPro = { [1] = _G.Const.CONST_PRO_ZHENGTAI,
	-- 				[2] = _G.Const.CONST_PRO_SUNMAN,
	-- 				[3] = _G.Const.CONST_PRO_ICEGIRL,
	-- 				[4] = _G.Const.CONST_PRO_LOLI }

	local myPos = { { -300, -250 },{ 300, -250 } }
	for i=1,self.proNum do
		self.newSpine[i] =  _G.SpineManager.createPlayer(i)
	  	-- 职业的改变 self.pro
	  	self.newSpine[i] : setAnimation(0,"idle",true)
	  	self.newSpine[i] : setPosition( myPos[2][1], myPos[2][2] )
	  	self.mainContainer2 : addChild( self.newSpine[i], 5)

  		local nScale 	 = 1.55*self.newSpine[i]:getScale()
  		self.newSpine[i] : setScale( -nScale, nScale )
  		self.newSpine[i] : setVisible( false )
  	end

end

function expeditView.createPowerNum( self, _powerNum, num)
	self.lab_power[num] : setString(string.format("战: %d",_powerNum) )
end

function expeditView.showRoleSpine( self, num, myPro , _wuqiId, _featherId)
  	print( "进入：_showRoleSpine !", num, myPro , _wuqiId, _featherId )
  	if self.m_skeleton[num] ~= nil then 
  		self.m_skeleton[num] : removeFromParent()
  		self.m_skeleton[num] = nil
  	end
  	local myPos = { { -300, -250 },{ 300, -250 } }
  	if myPro>=self.proNum+1 then myPro=1 end 
  	local roleSke,wuqiSke,featherSke = _G.SpineManager.createPlayer(myPro,nil,_wuqiId,_featherId)
  	self.m_skeleton[num] = roleSke
  	-- 职业的改变 self.pro
  	self.m_skeleton[num] : setAnimation(0,"idle",true)
  	self.m_skeleton[num] : setPosition( myPos[num][1], myPos[num][2] )
  	self.mainContainer : addChild(self.m_skeleton[num],5)

  	if wuqiSke then
  		wuqiSke : setAnimation(0,"idle",true)
  	end

  	if featherSke then
  		featherSke : setAnimation(0,string.format("idle_%d",(10000+myPro)),true)
  	end

  	local nScale=1.55*self.m_skeleton[num]:getScale()
  	if num == 2 then
  		self.m_skeleton[num] : setScale( -nScale, nScale )
  	else
  		self.m_skeleton[num] : setScale( nScale )
  	end
  	-- self.shadow[num] = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  	-- self.shadow[num] : setPosition(myPos[num][1], myPos[num][2])
  	-- self.shadow[num] : setScale(1.8)
  	-- self.mainContainer : addChild(self.shadow[num])
end

 function expeditView.closeWindow( self )
 	if self.Scheduler ~= nil then 
 		_G.Scheduler : unschedule( self.Scheduler )
 		self.Scheduler = nil
 	end
	print( "开始关闭" )
	self.m_mediator : destroy()
	self.m_mediator = nil
	self.mainContainer=nil
	cc.Director : getInstance() : popScene()
end

function expeditView.REQ_EXPEDIT_REQUEST( self ) -- 请求界面
	print( "请求界面：REQ_EXPEDIT_REQUEST" )
	local msg = REQ_EXPEDIT_REQUEST()
	_G.Network : send( msg )
end

function expeditView.Expedit_reply( self, _ackMsg )
	self.Reply_ackMsg = _ackMsg
	print( "请求界面返回：" )
	print( "	修为值	 	 ",	self.Reply_ackMsg.honor		)
	print( "	剩余的挑战次数 ",	self.Reply_ackMsg.num		)
	print( "	总的参战次数	 ",	self.Reply_ackMsg.pk_num		)
	print( "	胜利的次数	 ",	self.Reply_ackMsg.win_num	)
	print( "	服务器id	 	 ",	self.Reply_ackMsg.s_id		)
	print( "	军衔	 		 ",	self.Reply_ackMsg.grade		)
	print( "	购买挑战次数	 ",	self.Reply_ackMsg.buy_times	)
	print( "	数量 (循环)	 ",	self.Reply_ackMsg.count		)
	for i=1,self.Reply_ackMsg.count do
		print( "战报信息块：	 ", i )
		print( "	挑战时间戳	", 	self.Reply_ackMsg.data[i].time  	)
		print( "	对手的名字	",  self.Reply_ackMsg.data[i].uname 	)
		print( "	服务器id		",  self.Reply_ackMsg.data[i].us_id 	)
		print( "	战斗结果		",  self.Reply_ackMsg.data[i].result	)
		print( "	战斗结果		",  self.Reply_ackMsg.data[i].honor		)
	end

	Buys = self.Reply_ackMsg.buy_times

	local shenzhiTable = _G.Cfg.grade
	local grade = self.Reply_ackMsg.grade
	if grade ~= 0 then
		self.Lab_myShenzhi : setString( string.format( "%s", shenzhiTable[grade].name )  )
	end
	-- 战报数据加载
	local shenglv = math.ceil(self.Reply_ackMsg.win_num / self.Reply_ackMsg.pk_num * 100 )
	if self.Reply_ackMsg.pk_num == 0 then 
		shenglv = "0.0"
	end 
	local name_1  = string.format( "%d", self.Reply_ackMsg.honor)
	local name_2  = string.format( "%d%s%d%s%s%s", self.Reply_ackMsg.win_num, "/", self.Reply_ackMsg.pk_num, "（", shenglv, "%）" )
	local name_3  = string.format( "%d", self.Reply_ackMsg.num )
	print( "getChildByTag( Tag_ZhanBao ) = ",self.mainContainer : getChildByTag( Tag_ZhanBao ) )
	print( "getChildByTag( Tag_Rongyao ) = ",self.mainContainer : getChildByTag( Tag_ZhanBao ) : getChildByTag( Tag_Rongyao ))
	self.mainContainer : getChildByTag( Tag_ZhanBao ) : getChildByTag( Tag_Rongyao ) : setString( name_1 )
	self.mainContainer : getChildByTag( Tag_ZhanBao ) : getChildByTag( Tag_Shenglv ) : setString( name_2 )
	self.mainContainer : getChildByTag( Tag_ZhanBao ) : getChildByTag( Tag_Times   ) : setString( name_3 )

	local function nFun(_data)
		if self.mainContainer then
			local nameArray=_data or {}
			local serverName=nameArray[self.Reply_ackMsg.s_id] or "nil"
			local name_s_id = string.format( "%s%s%s", "[", serverName, "服]" )
			self.mainContainer : getChildByTag( Tag_S_id ) : setString( name_s_id )
		end
	end
	_G.Util:getServerNameArray({self.Reply_ackMsg.s_id},nFun)

	if self.Reply_ackMsg.num <= 0 then 
		self.mainContainer : getChildByTag( Tag_ZhanBao ) : getChildByTag( Tag_SurplusTimes ) : setTouchEnabled( true )
	end
end

function expeditView.REQ_EXPEDIT_MATCH_TIMES( self )	-- 购买次数
	print( "购买次数：REQ_EXPEDIT_MATCH_TIMES" )
	local msg = REQ_EXPEDIT_MATCH_TIMES()
	_G.Network : send( msg )
end

function expeditView.Times_success( self, _ackMsg )
	print( "------购买次数成功，次数加一:", _ackMsg.MsgID )
	Buys = Buys + 1
	self.Reply_ackMsg.num = _ackMsg.num
	local name_3  = string.format( "%d", self.Reply_ackMsg.num )
	self.mainContainer : getChildByTag( Tag_ZhanBao ) : getChildByTag( Tag_Times ) : setString( name_3 )
	if self.isFight then
		self.isFight = nil
		self : Pk_find()
	end
end

function expeditView.BuyTimes( self )
	if Is_Create == false then
		self : MessageBox()
	else 
		self : REQ_EXPEDIT_MATCH_TIMES()
	end
end

function expeditView.MessageBox( self )
	local function tipsSure( )
		self : REQ_EXPEDIT_MATCH_TIMES()
	end
	local function cancel(  )
		Is_Create = false
	end

	local tipsBox 		= require("mod.general.TipsBox")()
	local tipsNode   = tipsBox :create( "", tipsSure, cancel)
	tipsNode : setPosition( cc.p( -self.m_winSize.width/2, -self.m_winSize.height/2 ) )
	tipsBox 	: setTitleLabel( "购买次数" )
	self.mainContainer : addChild( tipsNode, _G.Const.CONST_MAP_ZORDER_NOTIC, 332211 )

	local ShowMessBox=tipsBox:getMainlayer()
	print( "Buys+1 = ", Buys+1 )
	local spend  = _G.Const.CONST_EXPEDIT_COST  
	local name 	 = string.format( "%s%d%s", "花费", (Buys+1)*spend, "元宝购买一次挑战？" ) 
	local text_1 = _G.Util : createLabel( name , FONTSIZE+2 )
	text_1 : setPosition( 0, 60 )
	ShowMessBox : addChild( text_1 )
	local text_2 = _G.Util : createLabel( "(元宝不足则花费钻石)", FONTSIZE-2 )
	text_2 : setPosition( 0, 30 )
	ShowMessBox : addChild( text_2 )

	local text_4 = _G.Util : createLabel( "剩余购买次数: ", FONTSIZE )
	text_4 : setPosition( -72, -5 )
	text_4 : setAnchorPoint( 0, 0.5 )
	ShowMessBox : addChild( text_4 )

	local leaveTimes = _G.Const.CONST_EXPEDIT_TIMES - Buys

	local text_5 = _G.Util : createLabel( leaveTimes, FONTSIZE )
	text_5 : setPosition( -72+text_4:getContentSize().width, -5 )
	text_5 : setAnchorPoint( 0, 0.5 )
	text_5 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	ShowMessBox : addChild( text_5 )

	local text_3 = _G.Util : createLabel( _G.Lang.LAB_N[106], FONTSIZE )
	text_3 : setPosition( 25, -50 )
	-- text_3 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
	ShowMessBox : addChild( text_3 )

	local function checkBoxCallback( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end

	local uncheckBox = "general_gold_floor.png"
	local selectBox  = "general_check_selected.png"
	local checkBox 	 = ccui.CheckBox : create( uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType )
	checkBox : addEventListener( checkBoxCallback )
	checkBox : setPosition( cc.p( -80, -51 ) )
	checkBox : setTag( Tag_MessIsTouch )
	ShowMessBox : addChild(checkBox) 

end

function expeditView.REQ_EXPEDIT_BEGIN( self )
	print( "开始匹配：REQ_EXPEDIT_BEGIN" )
	local msg = REQ_EXPEDIT_BEGIN()
	_G.Network : send( msg )
end

function expeditView.Expedit_pk( self, _ackMsg )
	self.Pk_ackMsg = _ackMsg
	print("	对手MsgId",	self.Pk_ackMsg.MsgID		)
	print("	对手uid	",	self.Pk_ackMsg.uid		)
	print("	对手名字	",	self.Pk_ackMsg.uname		)
	print("	服务器id	",	self.Pk_ackMsg.us_id		)
	print("	对手等级	",	self.Pk_ackMsg.lv		)
	print("	对手军衔	",	self.Pk_ackMsg.grade		)
	print("	总pk次数	",	self.Pk_ackMsg.pk_num	)
	print("	胜利次数	",	self.Pk_ackMsg.win_num	)
	print("	职业		",	self.Pk_ackMsg.pro		)
	print("	战斗力	",	self.Pk_ackMsg.power		)

	local function callback1( )
		_G.Util:playAudioEffect("ui_kill")
		self.mainContainer2 : setVisible( false )
		-- 设置对手信息
		local EnemyLv    = string.format( "LV%d %s", self.Pk_ackMsg.lv,self.Pk_ackMsg.uname )
		local shenzhiTable = _G.Cfg.grade
		local grade = self.Pk_ackMsg.grade
		if grade ~= 0 then
			self.Lab_EnemyShenzhi : setString( string.format( "%s", shenzhiTable[grade].name )  )
		end

		self.Lab_EnemyLv 	: setString( EnemyLv )
		self.EnemyPit : setVisible( false )
		self.myNode   : setVisible( true )
		self : createPowerNum( self.Pk_ackMsg.power, 2 )
		self : showRoleSpine( 2, self.Pk_ackMsg.pro, self.Pk_ackMsg.lqid, self.Pk_ackMsg.syid )

		local function nFun(_data)
			if not tolua.isnull(self.Lab_EnemyFu) then
				local nameArray=_data or {}
				local serverName=nameArray[self.Pk_ackMsg.us_id] or "nil"
				local EnemyFu = string.format( "%s%s%s", "[", serverName, "服]" )
				self.Lab_EnemyFu 	: setString( EnemyFu )
			end
		end
		_G.Util:getServerNameArray({self.Pk_ackMsg.us_id},nFun)
	end
	
	local nFun2=function( )
		self.EnemyPit : setVisible( false )

		local randomNum=math.ceil(gc.MathGc:random_0_1()*self.proNum)
		for i=1,self.proNum do
			self.newSpine[i] : setVisible( false )
		end
		self.newSpine[randomNum] : setVisible( true )
		_G.Util:playAudioEffect("Dong")
	end
	
	-- nFun1()
	local count = 10
	self.mainContainer2 : runAction( cc.Sequence:create( 	
											cc.Repeat:create( 	
													cc.Sequence:create(
														cc.CallFunc:create(nFun2),
														cc.DelayTime:create(0.1)
																		),
															count
															),
											cc.CallFunc:create( callback1 )
														)
												
												
									) 
end

function expeditView.showRandomEffect(self)
	if self.m_showCount>5 then
		return
	end
	self.m_showCount=self.m_showCount+1

	local function callback2( )
		self.EnemyPit : setVisible( false )

		local randomNum=math.ceil(gc.MathGc:random_0_1()*self.proNum)
		for i=1,self.proNum do
			self.newSpine[i] : setVisible( false )
		end
		self.newSpine[randomNum] : setVisible( true )
	end
	self.mainContainer2 : runAction( cc.Sequence:create(  ) )
end

function expeditView.ShowZhanbaoTable( self )

	if self.Reply_ackMsg.count == nil or self.Reply_ackMsg.count <= 0 then
		local command = CErrorBoxCommand(36950)
        controller :sendCommand( command )
        return
	end
	local width  = 617
	print( "开始创建战报table：" )

	local myZBView  = require( "mod.general.BattleMsgView"  )()
  	local ZB_D2Base = myZBView : create()
  	local height  	= myZBView : getSize().height

  	local combatLayer = cc.Node : create()
  	ZB_D2Base : addChild( combatLayer )

    local function onTouchBegan() 
		return true 
	end

	local Spr_Combat  	= cc.Node:create()
	Spr_Combat : setPosition( cc.p(0,0) )
	combatLayer  : addChild( Spr_Combat,3 ) 

	print("初始化滚动框", self.Reply_ackMsg.count)
    local count 		= 20
    local containerSize = nil
    local oneHeight=283/7
    if self.Reply_ackMsg ~= nil and self.Reply_ackMsg.count ~= nil then
	    if self.Reply_ackMsg.count <= 7 then 
	    	count = 7
	    	containerSize = cc.size( width-10, 283)
	    else
	    	count = self.Reply_ackMsg.count
	    	containerSize = cc.size( width-10, oneHeight*count)
	    end
	else
		count = 7
		containerSize = cc.size( width-10, 283)
	end

	local ScrollView    = cc.ScrollView : create()
    local viewSize      = cc.size( width-10, 283)
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(containerSize)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView      : setPosition(cc.p(15, 4))
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    Spr_Combat 		: addChild( ScrollView,3 )
    
    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView 	  : setPosOff(cc.p(-7,0))
    -- barView 	  : setMoveHeightOff(-5)

    if not (self.Reply_ackMsg~=nil and self.Reply_ackMsg.count~=nil) then
    	return
    end

    local function nFun(_data)
		if not tolua.isnull(ZB_D2Base) then
			local nameArray=_data or {}

			for i=1,self.Reply_ackMsg.count do
				print( "得到的时间：", i,  self : __combatTime( self.Reply_ackMsg.data[i].time  ) )

				local My_UsId  = self.Reply_ackMsg.data[i].us_id
		  		local My_honor = self.Reply_ackMsg.data[i].honor
				local serverName=nameArray[My_UsId] or "nil"
				local Set_Post = 0
				local Lab_win  = { [0] = "失败", "胜利" }
				local win_color= { [0] = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ), _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GREEN ) }
		  		local My_Time  = self : __combatTime( self.Reply_ackMsg.data[i].time  )
		  		local My_Text1 = My_Time.."您挑战"
		  		local My_Text2 = self.Reply_ackMsg.data[i].uname 
		  		local My_Text3 = string.format("[%s服]", serverName )
		  		local My_Text4 = Lab_win[self.Reply_ackMsg.data[i].result]
		  		local My_Text5 = "，获得"..My_honor.."修为"

		   		local lab_1 = _G.Util : createLabel( My_Text1, FONTSIZE )
				lab_1 : setPosition( Set_Post, containerSize.height - (i-1)*oneHeight - 20 )
				lab_1 : setAnchorPoint( 0, 0.5 )
		    	-- lab_1 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
		    	ScrollView : addChild( lab_1 )
		  		Set_Post = Set_Post + lab_1 : getContentSize().width

		  		local lab_2 = _G.Util : createLabel( My_Text2, FONTSIZE )
				lab_2 : setPosition( Set_Post, containerSize.height - (i-1)*oneHeight - 20 )
				lab_2 : setAnchorPoint( 0, 0.5 )
		    	lab_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
		    	ScrollView : addChild( lab_2 )
		    	Set_Post = Set_Post + lab_2 : getContentSize().width

		  		local lab_3 = _G.Util : createLabel( My_Text3, FONTSIZE-2 )
				lab_3 : setPosition( Set_Post, containerSize.height - (i-1)*oneHeight - 20 )
				lab_3 : setAnchorPoint( 0, 0.5 )
		    	-- lab_3 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
		    	ScrollView : addChild( lab_3 )
		    	Set_Post = Set_Post + lab_3 : getContentSize().width

		  		local lab_4 = _G.Util : createLabel( My_Text4, FONTSIZE )
				lab_4 : setPosition( Set_Post, containerSize.height - (i-1)*oneHeight - 20 )
				lab_4 : setAnchorPoint( 0, 0.5 )
		    	lab_4 : setColor( win_color[self.Reply_ackMsg.data[i].result] )
		    	ScrollView : addChild( lab_4 )
		    	Set_Post = Set_Post + lab_4 : getContentSize().width

		  		local lab_5 = _G.Util : createLabel( My_Text5, FONTSIZE )
				lab_5 : setPosition( Set_Post, containerSize.height - (i-1)*oneHeight - 20 )
				lab_5 : setAnchorPoint( 0, 0.5 )
		    	-- lab_5 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
		    	ScrollView : addChild( lab_5 )
		    	print( "My_Text1 = ", My_Text1, My_Text2, My_Text3 )

		    	local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
		    	local lineY= line : getContentSize().height
		    	line : setPreferredSize( cc.size( width-10, lineY ) )
		    	-- line : setAnchorPoint( 0, 1 )
		    	line : setPosition( width/2-15, containerSize.height - (i-1)*oneHeight - oneHeight )
		    	ScrollView : addChild( line )
		    end
		end
	end

	local sids={}
	for i=1,self.Reply_ackMsg.count do
		sids[#sids+1]=self.Reply_ackMsg.data[i].us_id
	end
	_G.Util:getServerNameArray(sids,nFun)
end

function expeditView.__combatTime( self,times)
	local nowTime     = _G.TimeUtil:getNowSeconds()
    local offlineTime = nowTime - times
    print(offlineTime)

    local times_str   = os.date("*t", times)
    local nowTime_str = os.date("*t", nowTime)
    print(times_str.day)
    print(nowTime_str.day)
    local temptime = ""
    if math.floor( offlineTime/(86400*30) ) > 0 then --一个月前
        temptime = "[1个月前]"
    elseif math.floor( offlineTime/86400 ) > 0 then  --超过一天
        temptime = "["..math.floor( offlineTime/86400 ).._G.Lang.LAB_N[92].."]"
    -- elseif math.floor( offlineTime/3600 ) > 0 then   --超过一个小时但一天内
    --     temptime = math.floor( offlineTime/3600 ).._G.Lang.LAB_N[91]
    -- elseif math.floor( offlineTime/60 ) > 0 then   --超过一分钟 但一个小时内
    --     temptime = math.floor( offlineTime/60 ).._G.Lang.LAB_N[90]
    else
        -- temptime = "1".._G.Lang.LAB_N[90]

        if times_str ~= nil and nowTime_str ~= nil then
           if tostring(times_str.day) ~= tostring(nowTime_str.day) then
               temptime  = "[昨天]"
           else
               local min = string.format("%.2d", times_str.min)
               temptime  = "["..times_str.hour ..":".. min.."]"
           end
        else
           temptime = "error"
        end
    end
    return temptime
end

function expeditView.ShowShenzhi( self )
	local width  = 623
	local height = 291
	print( "开始创建五行table：" )

	local myZBView  = require( "mod.general.BattleMsgView"  )()
  	local ZB_D2Base = myZBView : create( "五行表" )
  	local myHeight  = myZBView : getSize().height

  	local combatLayer = cc.Node : create()
  	ZB_D2Base : addChild( combatLayer )

	local Spr_Combat_2  = cc.Node : create()
	combatLayer  : addChild( Spr_Combat_2 ) 

	local Spr_TextLine = ccui.Scale9Sprite : createWithSpriteFrameName( "general_daybg.png" )
   	Spr_TextLine  : setContentSize( cc.size(width-2, 50) )
   	Spr_TextLine  : setPosition( cc.p(width/2, height-27) )
   	Spr_Combat_2   	: addChild( Spr_TextLine )

   	local Text_1 = _G.Util : createLabel( "五行", FONTSIZE )
   	Text_1 : setPosition( 70, height-23 )
   	-- Text_1 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
   	Spr_Combat_2 : addChild( Text_1 )
   	local Text_2 = _G.Util : createLabel( "属性", FONTSIZE )
   	Text_2 : setPosition( width/2, height-23 )
   	-- Text_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
   	Spr_Combat_2 : addChild( Text_2 )
   	local Text_3 = _G.Util : createLabel( "所需修为", FONTSIZE )
   	Text_3 : setPosition( width-75, height-23 )
   	-- Text_3 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
   	Spr_Combat_2 : addChild( Text_3 )

	print("初始化滚动框")
    local ScrollView  = cc.ScrollView : create()
    local count 	  = #_G.Cfg.grade
    local myCount 	  = count
    if count <=5 then
    	myCount = 5
    end
    print( "五行总数为》》", count )
    local viewSize      = cc.size( width-4, 48*5)
    local containerSize = cc.size( width-4, myCount*48)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(containerSize)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView      : setPosition(cc.p(0, 3))
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    Spr_Combat_2 	: addChild( ScrollView )
    
    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView 	  : setPosOff(cc.p(-5,0))
    -- barView 	  : setMoveHeightOff(-5)

    local Shenzhi = _G.Cfg.grade

    for i,v in ipairs( Shenzhi ) do
    	local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    	line : setPreferredSize( cc.size( width-16, 2 ) )
    	line : setAnchorPoint( 0, 0 )
    	line : setPosition( 7, i*48-45 )
    	ScrollView : addChild( line )

    	local lab_Shenzhi = _G.Util : createLabel( v.name, FONTSIZE )
    	lab_Shenzhi : setPosition( 70, i*48-24  )
    	-- lab_Shenzhi : setAnchorPoint( 0, 0.5 )
    	-- lab_Shenzhi : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
    	ScrollView  : addChild( lab_Shenzhi )

    	local Text_Shuxing = string.format( "%s%d%s%d", "攻击+", v.attr.strong_att, "、血量+", v.attr.hp )
    	local lab_Shuxing = _G.Util : createLabel( Text_Shuxing, FONTSIZE )
    	lab_Shuxing : setPosition( width/2, i*48-24  )
    	-- lab_Shuxing : setAnchorPoint( 0.5, 0.5 )
    	-- lab_Shuxing : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
    	ScrollView  : addChild( lab_Shuxing )

		local lab_Rongyu = _G.Util : createLabel( v.exp, FONTSIZE )
    	lab_Rongyu : setPosition( width-75, i*48-24  )
    	-- lab_Rongyu : setAnchorPoint( 0.5, 0.5 )
    	-- lab_Rongyu : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
    	ScrollView : addChild( lab_Rongyu )
    end
end

function expeditView.Pk_find( self )
	print( "---------,是否允许：", self.Scheduler_r )
	self.isFight = nil
	if self.Reply_ackMsg.num > 0 then
		self.mainContainer : getChildByTag( Tag_Pair_start ) : setTouchEnabled( false )
		self.mainContainer : getChildByTag( Tag_Btn_close )  : setTouchEnabled( false )
		local Lab_Times = self.mainContainer : getChildByTag( Tag_ZhanBao ) : getChildByTag( Tag_Times )
		local function step1( )
			if self.Scheduler_r == true then 
				self.mainContainer : getChildByTag( Tag_Pair_start ) : setTouchEnabled( true )
				self.Scheduler_r = false
				if Lab_Times : getString() == "0" then 
					-- self.mainContainer : getChildByTag( Tag_Btn_close ) : setTouchEnabled( true )
					_G.Scheduler : unschedule( self.Scheduler )
	 				self.Scheduler = nil
				end
				if self.Reply_ackMsg.num > 0 then
					self : Pk_Begin()
					print( "+1+1+1" )
				end
			else
				self.Scheduler_r = true
			end
			
		end

		if self.Scheduler==nil then 
			self.Scheduler = _G.Scheduler : schedule(step1, 1.5)
		end
		self : REQ_EXPEDIT_BEGIN()
	else
		self.isFight = true
		self : BuyTimes()
	end
	
end
-- 战斗场景
function expeditView.REQ_EXPEDIT_FIGHT( self )
	_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_WRESTLE_KOF_SENCE )
	_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_JJC_WARLORDS_ID)
	local property  = _G.GPropertyProxy.m_lpMainPlay
    local originKey = property:getPropertyKey()
    local szKey = gc.Md5Crypto:md5(originKey,string.len(originKey))
	local msg  = REQ_EXPEDIT_FIGHT()
	print( "key = ", szKey )
	msg : setArgs( self.Pk_ackMsg.uid, szKey )
	_G.Network : send( msg )
end

function expeditView.Pk_Begin( self )
	self : REQ_EXPEDIT_FIGHT()
end

function expeditView.Net_SYSTEM_ERROR( self, _ackMsg )
	if self.Scheduler ~= nil then 
 		_G.Scheduler : unschedule( self.Scheduler )
 		self.Scheduler = nil
 	end
	local ackMsg = _ackMsg
	self.mainContainer : getChildByTag( Tag_Btn_close ) : setTouchEnabled( true )
	self.mainContainer : getChildByTag( Tag_Pair_start ) : setTouchEnabled( true )
	local errorNum = _ackMsg.error_code
	print( "error_code= ", errorNum )
	if ackMsg.error_code == 8 then
		self.mainContainer : getChildByTag( Tag_Btn_close ) : setTouchEnabled( true )
	end
end

function expeditView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print(" 按下 ", tag)
		if tag == Tag_MessIsTouch then 
			print( " 勾选按钮被勾选 " )
  			Is_Create = true
  		end
	elseif touchEvent == ccui.TouchEventType.moved then
		print(" 移动 ", tag)
		if tag == Tag_MessIsTouch then 
			print( " 勾选按钮被反勾选 " )
  			Is_Create = false
  		end
  	elseif touchEvent == ccui.TouchEventType.ended then
  		print(" 抬起 ", tag )	
  		if tag == Tag_SurplusTimes then 
  			print( "购买挑战次数" )
  			self : BuyTimes()
  		elseif tag == Tag_Pair_start then 
  			print( "开始匹配战斗" )
  			self : Pk_find()
  		elseif tag == Tag_Btn_Zhanbao then 
  			print( "战报表" )
  			self : ShowZhanbaoTable()
  		elseif tag == Tag_Btn_ShenZhi then 
  			self : ShowShenzhi()
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ",  tag)
  	end
end

return expeditView