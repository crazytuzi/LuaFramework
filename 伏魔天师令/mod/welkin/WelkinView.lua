local WelkinView = classGc(view, function(self, _data1, _data2)
	self.MyType 		= _data1
	self.IsOver 		= _data2
    self.m_winSize  	= cc.Director:getInstance() : getWinSize()
	self.m_viewSize 	= cc.size( 832, 488 )

	self.m_mediator 	= require("mod.welkin.WelkinMediator")() 
	self.m_mediator 	: setView(self) 

end)
-- 1：玉清元始  2：巅峰之战
local FONTSIZE = 20
local RANK_1 = _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_2
local RANK_2 = _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_3

local color1 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN )
local color2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE)
local color3 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_RED)
local color4 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE)
local color5 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORANGE )

local Tag_Btn_Join = { 101, 102, 103 }
local Tag_Btn_Rank = { 111, 112 }

function WelkinView.noInTime(self)
	if self.MyType~=nil then
		if not self.gamSetLabel:isVisible() then
			self.gamSetLabel:setVisible(true)
		end
		self.MyType=nil
	end
end

function WelkinView.create( self )
	self.m_settingView = require( "mod.general.NormalView" )()
	self.gamSetLabel   = self.m_settingView : create( "大闹天宫" )
	self.m_settingView : setTitle( "大闹天宫" )
	self.m_settingView : showSecondBg()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.gamSetLabel)
	
	print( "self.IsOver1 = ", self.IsOver )
	if self.MyType ~= nil then 
		self.gamSetLabel : setVisible( false )
		self : REQ_STRIDE_ENJOY(self.MyType)
	end
	self : init()

	return tempScene
end

function WelkinView.init( self )

	local function closeFunSetting()
		self : closeWindow()
	end
  	local Btn_Close    = self.m_settingView : getCloseBtn()
  	self.m_settingView : addCloseFun( closeFunSetting )

  	self.mainContainer = cc.Node : create()
	self.mainContainer : setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2 ) )
	self.gamSetLabel   : addChild( self.mainContainer,10 )

	self.m_View = {}

	self : createView()
end

function WelkinView.createView( self )
	local function ButtonCallBack( obj, eventType )
  		self : touchEventCallBack( obj, eventType )
  	end
	local Text_Spr = { "Tiangong_icon.png", "Lingxiao.png", "Duzun_icon.png" }
	local Text_all = { 	{ "时间：周一至周四","0","点~","22","点", "积分排名前500名可参与", "周五进行的上清灵宝。", "周四晚上","22","点结算排名" }, 
						{ "时间：周五","0","点~","22","点", "排名前256名可参与周六、", "周日进行的太清混元。", "周五晚上","22","点结算排名" },
						{ "时间：周六","0","点~周日","22","点", "周六","20","点举行初赛", "周日","20","点举行决赛", "" },}
	self.Btn_Join = {}
	local BaseSize=cc.size(self.m_viewSize.width/3-4 , self.m_viewSize.height - 18)
	for i=1,3 do
		local Spr_Base = ccui.Scale9Sprite : createWithSpriteFrameName( "general_rolekuang.png" )
		Spr_Base : setContentSize(BaseSize)
		Spr_Base : setAnchorPoint( 0, 0.5 )
		Spr_Base : setPosition( -self.m_viewSize.width/2-2 + (i-1)*self.m_viewSize.width/3 + i*2, -40 )
		self.mainContainer : addChild( Spr_Base )

		local wid_Base = BaseSize.width
		local hei_Base = BaseSize.height

		local Spr_Icon = cc.Sprite : createWithSpriteFrameName( Text_Spr[i] )
		Spr_Icon : setAnchorPoint( 0.5, 1 )
		Spr_Icon : setPosition( wid_Base/2, hei_Base - 20 )
		Spr_Base : addChild( Spr_Icon )

		local Spr_Line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
		Spr_Line : setContentSize( wid_Base - 10, self.m_viewSize.height-135 )
		Spr_Line : setPosition( wid_Base/2, hei_Base/2 - 52 )
		Spr_Base : addChild( Spr_Line )

		-- local color1 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LBLUE )
		-- local color2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE )
		local hei_MidLab = { hei_Base-160, hei_Base/2 + 20,
							 hei_Base/2-5, hei_Base/3+20}
		local upNode=cc.Node:create()
		local upwidth=0
		for n=1,5 do
			local lab_1 = _G.Util : createLabel( Text_all[i][n], FONTSIZE )
			lab_1 : setAnchorPoint( 0, 0.5 )
			lab_1 : setPosition( upwidth,hei_MidLab[1])
			upNode:addChild(lab_1)
			upwidth=upwidth+lab_1:getContentSize().width
			if n==2 or n==4 then
				lab_1 : setColor(  _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
			end
		end
		upNode:setPosition(BaseSize.width/2-upwidth/2,0)
		Spr_Base:addChild(upNode)

		local downNode=cc.Node:create()
		local downwidth=0
		local tNode=cc.Node:create()
		local twidth=0
		if i~=3 then
			for k=1,3 do
				local lab_1 = _G.Util : createLabel( Text_all[i][k+7], FONTSIZE )
				lab_1 : setAnchorPoint( 0, 0.5 )
				lab_1 : setPosition( downwidth,hei_MidLab[4])
				downwidth=downwidth+lab_1:getContentSize().width
				if k==2 then
					lab_1 : setColor(  _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
				end
				downNode : addChild( lab_1 )
			end
			for d=1,2 do
				local lab_1 = _G.Util : createLabel( Text_all[i][d+5], FONTSIZE )
				lab_1 : setPosition( wid_Base/2,hei_MidLab[d+1])
				Spr_Base : addChild( lab_1 )
			end
		else
			for t=1,6 do
				local lab_1 = _G.Util : createLabel( Text_all[i][t+5], FONTSIZE )
				lab_1 : setAnchorPoint( 0, 0.5 )
				if t<4 then
					lab_1 : setPosition( twidth,hei_MidLab[2])
					twidth=twidth+lab_1:getContentSize().width
				elseif t==4 then
					twidth=0
					lab_1 : setPosition( twidth,hei_MidLab[3])
					twidth=twidth+lab_1:getContentSize().width
				else
					lab_1 : setPosition( twidth,hei_MidLab[3])
					twidth=twidth+lab_1:getContentSize().width
				end
				
				if t==2 or t==5 then
					lab_1 : setColor(  _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
				end
				tNode : addChild( lab_1 )
			end
		end
		downNode:setPosition(BaseSize.width/2-downwidth/2,0)
		Spr_Base:addChild(downNode)
		tNode:setPosition(BaseSize.width/2-twidth/2,0)
		Spr_Base:addChild(tNode)

		local Btn_Join = gc.CButton : create()
		Btn_Join : loadTextures( "general_btn_gold.png")
		Btn_Join : setPosition( wid_Base/2, 115 )
		Btn_Join : setTitleText( "进 入" )
		Btn_Join : setTitleFontName( _G.FontName.Heiti ) 
		Btn_Join : setTitleFontSize( FONTSIZE )
		Btn_Join : setTag( Tag_Btn_Join[i] )
		Btn_Join : addTouchEventListener( ButtonCallBack )
		Spr_Base : addChild( Btn_Join )
		Btn_Join : setTouchEnabled( false )
		Btn_Join : setGray() 

		self.Btn_Join[i] = Btn_Join

		if i~=3 then 
			local Btn_Rank = gc.CButton : create()
			Btn_Rank : loadTextures( "general_btn_lv.png")
			Btn_Rank : setPosition( wid_Base/2, 50 )
			Btn_Rank : setTitleText( "排行榜" )
			Btn_Rank : setTitleFontName( _G.FontName.Heiti ) 
			Btn_Rank : setTitleFontSize( FONTSIZE )
			Btn_Rank : setTag( Tag_Btn_Rank[i] )
			Btn_Rank : addTouchEventListener( ButtonCallBack )
			Spr_Base : addChild( Btn_Rank )

			local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tip_down.png" )
			spr : setPosition( -3*wid_Base/2 + i*(wid_Base+3)-3 , hei_Base/2 - 100 )
			-- spr : setRotation( -90 )
			-- spr : setScale( 1.2 )
			self.mainContainer : addChild( spr, 5 )
		else
			local lab_2 = _G.Util : createLabel( "三清天尊：", FONTSIZE )
			lab_2 : setAnchorPoint( 0, 0.5 )
			lab_2 : setPosition( 30, 50)
			-- lab_2 : setColor( Color[1] )
			Spr_Base : addChild( lab_2 )

			self.Lab_Name = _G.Util : createLabel( "（暂无）", FONTSIZE )
			self.Lab_Name : setAnchorPoint( 0, 0.5 )
			self.Lab_Name : setPosition( 30 + lab_2:getContentSize().width , 50)
			self.Lab_Name : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
			Spr_Base : addChild( self.Lab_Name )
		end
	end

	local Text_week = { 7, 1, 2, 3, 4, 5, 6 }
	local mytime = _G.TimeUtil : getServerTimeSeconds()
	local time 	= os.date("*t",mytime)
	local week  = Text_week[time.wday]
	local hour 	= time.hour
	print( "现在时间：", week, hour )
	if 0 <= hour and hour <= 22 then
		if 1 <= week and week <= 4 then 
			self : changeBtnJoin( 1 )
		elseif week == 5 then 
			self : changeBtnJoin( 2 )
		else
			self : changeBtnJoin( 3 )
		end
	end
	self : REQ_TXDY_SUPER_REQUEST_FIRST()
end

function WelkinView.changeBtnJoin( self, _num )
	print( "_num = ", _num )                       
	for i=1,3 do
		self.Btn_Join[i] : setTouchEnabled( false )
		self.Btn_Join[i] : setGray()
	end
	self.Btn_Join[_num] : setTouchEnabled( true )
	self.Btn_Join[_num] : setDefault()
end

function WelkinView.createShowView( self, _type, _ackMsg )
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

    local myTitle = { [RANK_1] =  "玉清元始榜" ,[RANK_2] = "上清灵宝榜" }
    local m_titleLab=_G.Util:createBorderLabel(myTitle[_type],24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(rankSize.width/2,rankSize.height-26)
    Spr1:addChild(m_titleLab)

    print("asjdlaksdjklasdjklasjdksdkdkiiiiiiiiiii2222iiiiiiiii===>>>>>")

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(secondSize)
    di2kuanbg       : setPosition(cc.p(rankSize.width/2,rankSize.height/2-18))
    Spr1       : addChild(di2kuanbg)

	self : ShowRank( Spr1 ,_ackMsg, _type, secondSize)
end

function WelkinView.ShowRank( self, _place, _ackMsg, _type,_size )
	local place  = _place

	local x 	= 40
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

	-- local tanhao = cc.Sprite : createWithSpriteFrameName( "general_tanhao.png" )
	-- tanhao  : setPosition( x-10, 25 )
	-- place 	: addChild( tanhao )

	local Text1 = { [RANK_1] = "积分排名前500名可参与上清灵宝!", [RANK_2] = "积分排名前256名可参与太清混元" }
	local lab = _G.Util : createLabel( Text1[_type], 20 )
	-- lab : setAnchorPoint( 0, 0.5 )
	lab : setPosition( _size.width/2, 26 )
	lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	place : addChild( lab )

	local msg    = _ackMsg
	local rank   = msg.zdata.rank
	if rank >= 500 then 
		rank = "500+"
	end 
	if _type == RANK_1 then
		local posx	 = { x, x+145, x+290, x+435, x+580 }
		local Text_1 = { "排行", "名字", "等级", "积分", "区服", }
		local Text_2 = { rank, _G.GPropertyProxy : getMainPlay() : getName(), 
					 	 _G.GPropertyProxy : getMainPlay() : getLv(), self.calculus, string.format("[%s服]", _G.GLoginPoxy:getServerName()) }
		for i=1,5 do
			local lab = _G.Util : createLabel( Text_1[i], FONTSIZE )
			-- lab : setColor( color2 )
			lab : setAnchorPoint( 0, 1 )
			lab : setPosition( posx[i],_size.height+3 )
			place : addChild( lab )

			local lab2 = _G.Util : createLabel( Text_2[i], FONTSIZE )
			lab2 : setPosition( posx[i]+20,57 )
			place : addChild( lab2,3 )
		end
	else
		local posx	 = { x, x+190, x+400, x+570 }
		local Text_1 = { "排行", "名字", "等级", "区服", }
		local rank   = msg.zdata.rank
		if rank == 0 then
			rank = "暂无"
		end
		local Text_2 = { rank,  _G.GPropertyProxy : getMainPlay() : getName(), 
					 	 _G.GPropertyProxy : getMainPlay() : getLv(), string.format("[%s服]", _G.GLoginPoxy:getServerName()) }
		for i=1,4 do
			local lab = _G.Util : createLabel( Text_1[i], FONTSIZE )
			lab : setAnchorPoint( 0, 1 )
			lab : setPosition( posx[i],_size.height+3 )
			place : addChild( lab )

			local lab2 = _G.Util : createLabel( Text_2[i], FONTSIZE )
			lab2 : setPosition( posx[i]+20,57 )
			place : addChild( lab2 )
		end
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
			if _type == RANK_1 then
		    	local posx	 = { x, x+145, x+290, x+435, x+580 }
				for i=1,count do
					if msg.data[i]==nil then break end
					local serverName=nameArray[msg.data[i].sid] or "nil"
					local Text_3 = { msg.data[i].rank, msg.data[i].name, msg.data[i].lv, msg.data[i].arg, string.format("[%s服]",serverName) }
					for k=1,5 do
						local lab = _G.Util : createLabel( Text_3[k], FONTSIZE )
						lab : setPosition( posx[k]+20, mySizeY*count - i*mySizeY + 17 )
						ScrollView : addChild( lab )
						if i <= 3 then
							lab : setColor( myColor[i] )
						end
					end
					local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
					line : setPreferredSize( cc.size( _size.width - 20, 2 ) )
					line : setPosition( posx[3]+35, mySizeY*count - i*mySizeY-1 )
					-- line : setAnchorPoint( 0, 1 )
					ScrollView : addChild( line )
				end
			else
				local posx	 = { x, x+190, x+400, x+570 }
				for i=1,count do
					if msg.data[i]==nil then break end
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
					line : setPosition( posx[3]-105, mySizeY*count - i*mySizeY -1 )
					-- line : setAnchorPoint( 0, 1 )
					ScrollView : addChild( line )
				end
			end
		end
	end

	local sids={}
	for i=1,count do
		if msg.data[i]==nil then break end
		sids[i]=msg.data[i].sid
	end
	_G.Util:getServerNameArray(sids,nFun)

	-- if _type == RANK_1 then
 --    	local posx	 = { x, x+145, x+290, x+435, x+580 }
	-- 	for i=1,count do
	-- 		if msg.data[i]==nil then break end
	-- 		local Text_3 = { msg.data[i].rank, msg.data[i].name, msg.data[i].lv, msg.data[i].arg, string.format("[%s服]", _G.GLoginPoxy:getServerName(msg.data[i].sid) ) }
	-- 		for k=1,5 do
	-- 			local lab = _G.Util : createLabel( Text_3[k], FONTSIZE )
	-- 			lab : setPosition( posx[k]+20, mySizeY*count - i*mySizeY + 17 )
	-- 			ScrollView : addChild( lab )
	-- 			if i <= 3 then
	-- 				lab : setColor( myColor[i] )
	-- 			end
	-- 		end
	-- 		local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	-- 		line : setPreferredSize( cc.size( _size.width - 20, 2 ) )
	-- 		line : setPosition( posx[3]+35, mySizeY*count - i*mySizeY-1 )
	-- 		-- line : setAnchorPoint( 0, 1 )
	-- 		ScrollView : addChild( line )
	-- 	end
	-- else
	-- 	local posx	 = { x, x+190, x+400, x+570 }
	-- 	for i=1,count do
	-- 		if msg.data[i]==nil then break end
	-- 		local Text_4 = { msg.data[i].rank, msg.data[i].name, msg.data[i].lv, string.format("[%s服]", _G.GLoginPoxy:getServerName(msg.data[i].sid) ) }
	-- 		for k=1,4 do
	-- 			local lab = _G.Util : createLabel( Text_4[k], FONTSIZE )
	-- 			lab : setPosition( posx[k]+20, mySizeY*count - i*mySizeY + 17 )
	-- 			ScrollView : addChild( lab )
	-- 			if i <= 3 then
	-- 				lab : setColor( myColor[i] )
	-- 			end
	-- 		end
	-- 		local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	-- 		line : setPreferredSize( cc.size( _size.width - 20, 2 ) )
	-- 		line : setPosition( posx[3]-105, mySizeY*count - i*mySizeY -1 )
	-- 		-- line : setAnchorPoint( 0, 1 )
	-- 		ScrollView : addChild( line )
	-- 	end
	-- end
end

function WelkinView.closeWindow( self )
	if self.gamSetLabel == nil then return end
	self.gamSetLabel=nil
	cc.Director:getInstance():popScene()
	self:destroy()
end

function WelkinView.REQ_STRIDE_ENJOY( self, _num )
	print( "_num = ", _num )
	local msg = REQ_STRIDE_ENJOY()
	msg : setArgs( _num )
	_G.Network : send( msg )
end

function WelkinView.Net_ENJOY_BACK( self, _num )
	print( "收到的num：", _num )
	local Text = { _G.Const.CONST_MAP_WELKIN_FIRST,    	-- 玉清元始
				   _G.Const.CONST_MAP_WELKIN_BATTLE,	-- 上清灵宝
				   _G.Const.CONST_MAP_WELKIN_ONLY,}		-- 太清混元
	_G.GLayerManager : delayOpenLayer( Text[_num],nil,self.IsOver,1,2,0.05 )
	self : closeWindow()
end

function WelkinView.REQ_STRIDE_RANK( self, _which )
	local msg = REQ_STRIDE_RANK()
	msg : setArgs( _which )
	_G.Network : send( msg )
end

function WelkinView.Net_RANK_HAIG( self, _ackMsg )
	local msg = _ackMsg
	self.calculus = msg.zdata.calculus
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
	self : createShowView( msg.type, msg ) 
end

function WelkinView.REQ_TXDY_SUPER_REQUEST_FIRST( self )
	local msg = REQ_TXDY_SUPER_REQUEST_FIRST()
	_G.Network : send(msg)
end

function WelkinView.Net_REPLY_FIRST( self, _name )
	if _name ~= nil and _name ~= 0 then
		self.Lab_Name : setString( _name )
	else
		self.Lab_Name : setString( "（暂无）" )
	end
end

function WelkinView.Net_CloseWidow( self )
	if self.gamSetLabel : isVisible() == false then
		self : closeWindow()
	end
end

function WelkinView.touchEventCallBack( self, obj, touchEvent )
	tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print("   按下  ", tag)
	elseif touchEvent == ccui.TouchEventType.moved then
		print("   移动  ", tag)
	elseif touchEvent == ccui.TouchEventType.ended then
  		print("   抬起  ", tag)
  		if tag == Tag_Btn_Join[1] then 
  			print( "创建 玉清元始" )
  			self : REQ_STRIDE_ENJOY( tag-100 )
  		elseif tag == Tag_Btn_Join[2] then 
  			print( "创建 上清灵宝" )
  			self : REQ_STRIDE_ENJOY( tag-100 )
  		elseif tag == Tag_Btn_Join[3] then
  			print( "创建 太清混元" ) 
  			self : REQ_STRIDE_ENJOY( tag-100 )
  		elseif tag == Tag_Btn_Rank[1] then 
  			self : REQ_STRIDE_RANK( RANK_1 )
  		elseif tag == Tag_Btn_Rank[2] then
  			self : REQ_STRIDE_RANK( RANK_2 )
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ", tag)
  	end
end

return WelkinView