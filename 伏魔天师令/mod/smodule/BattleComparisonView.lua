local BattleComparisonView = classGc( view, function( self, _openType )
	-- self.m_openType = _openType

	self.m_winSize  	= cc.Director:getInstance() : getWinSize()

	self.m_mediator 	= require("mod.smodule.BattleComparisonMediator")() 
	self.m_mediator 	: setView(self) 

	self.m_resourcesArray = {}
end)

local ADDF=1
local DELF=2
local PKF =3
local zCount=14

-- local color1 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN 	)
-- local color2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE)
-- local color3 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_RED 		)
-- local color4 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE	)
-- local color5 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD 	)

local _typeName={"总 战 力：","基本属性：","饰品战力：","元魄战力：","宝石战力：","技能战力：","坐骑战力：","灵妖战力：",
				"经脉战力：","门派技能：","卦象战力：","宠物战力：","五行战力：","武器战力："}
local SYSID_ARRAY={
	_G.Const.CONST_FUNC_OPEN_ROLE,
	_G.Const.CONST_FUNC_OPEN_ROLE,
	_G.Const.CONST_FUNC_OPEN_ROLE_EQUIP,
	_G.Const.CONST_FUNC_OPEN_SMITHY_STRENGTHEN,
	_G.Const.CONST_FUNC_OPEN_SMITHY_INLAY,
	_G.Const.CONST_FUNC_OPEN_ROLE_SKILL,
	_G.Const.CONST_FUNC_OPEN_MOUNT,
	_G.Const.CONST_FUNC_OPEN_PARTNER,
	_G.Const.CONST_FUNC_OPEN_ROLE_GOLD,
	_G.Const.CONST_FUNC_OPEN_GANGS,
	_G.Const.CONST_FUNC_OPEN_SHEN,
	_G.Const.CONST_FUNC_OPEN_WING,
	_G.Const.CONST_FUNC_OPEN_MYTH,
	_G.Const.CONST_FUNC_OPEN_QILING,
	-- _G.Const.CONST_FUNC_OPEN_FEATHER,
	-- _G.Const.CONST_FUNC_OPEN_PARTNER,
}

local ConstMap={_G.Const.CONST_MAP_ROLE,
				_G.Const.CONST_MAP_ROLE,
				_G.Const.CONST_MAP_SMITHY,
				_G.Const.CONST_MAP_ROLE_EQUIP,
				_G.Const.CONST_MAP_SMITHY_INLAY,
				_G.Const.CONST_MAP_ROLE_SKILL,
				_G.Const.CONST_MAP_MOUNT,
				_G.Const.CONST_MAP_PARTNER_ATTRIBUTE,
				_G.Const.CONST_MAP_ROLE_GOLD,
				_G.Const.CONST_MAP_GANGS_SKILL,
				_G.Const.CONST_MAP_SHEN,
				_G.Const.CONST_MAP_WING,
				_G.Const.CONST_MAP_MYTH,
				_G.Const.CONST_MAP_QILING,
				-- _G.Const.CONST_MAP_FEATHER,
				-- _G.Const.CONST_MAP_PARTNER_ATTRIBUTE
			}

function BattleComparisonView.create( self, _uid )
	local function onTouchBegan(touch,event)
		return true
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rootLayer,1001)

	self:init(_uid)
end

function BattleComparisonView.init( self, _uid )
	self.enemyUid = _uid
	
	self.base1Size = cc.size( 852, 497 )
	self.base1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
	self.base1 		: setPreferredSize(self.base1Size)
	self.base1 		: setPosition( self.m_winSize.width/2, self.m_winSize.height/2 )
	self.m_rootLayer : addChild( self.base1 )

	local function closeFunSetting()
		self : closeWindow(_outView)
	end
  	local Btn_Close = gc.CButton : create("general_close.png")
	Btn_Close   : setPosition( cc.p( self.base1Size.width-23, self.base1Size.height-24) )
	Btn_Close   : addTouchEventListener( closeFunSetting )
	self.base1 : addChild( Btn_Close , 8 )

	local base2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" )
	base2 		: setPreferredSize(cc.size( self.base1Size.width-17, 371 ))
	base2 		: setPosition( self.base1Size.width/2, self.base1Size.height/2+15 )
	self.base1 : addChild( base2 )

	local m_labelTitle=_G.Util:createBorderLabel("战力对比",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_labelTitle:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_labelTitle:setPosition(self.base1Size.width/2,self.base1Size.height-28)
    self.base1:addChild(m_labelTitle,10)

	local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(self.base1Size.width/2-140,self.base1Size.height-30)
    self.base1:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(self.base1Size.width/2+135,self.base1Size.height-30)
    titleSpr:setRotation(180)
    self.base1:addChild(titleSpr,9)

	self : REQ_ROLE_REQUEST_COMPARE( _uid )

	self : createBase(_uid)
end

function BattleComparisonView.createBase( self,_uid )
	local baseSize=cc.size(837,100) 
	local NaseSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_daybg.png" )
	NaseSpr : setPreferredSize(baseSize)
	NaseSpr : setPosition( self.base1Size.width/2, self.base1Size.height-100 )
	self.base1 : addChild( NaseSpr )

	local vs = cc.Sprite : createWithSpriteFrameName( "ui_battlec_vs.png" )
	-- vs : setScale(0.4)
	vs : setPosition( self.base1Size.width/2, self.base1Size.height-95 )
	self.base1 : addChild( vs, 1 )

	self.viewSize = cc.size(baseSize.width-10,270)
	self.oneHeight=270/4
    self.containerSize = cc.size(baseSize.width-10, self.oneHeight*zCount)
    local ScrollView  = cc.ScrollView : create()
    ScrollView : setViewSize(self.viewSize)
    ScrollView : setContentSize(self.containerSize)
    ScrollView : setPosition(12, 82)
    ScrollView : setContentOffset( cc.p( 0,self.viewSize.height-self.containerSize.height)) -- 设置初始位置
  	self.base1 : addChild(ScrollView)
  	self.barView=require("mod.general.ScrollBar")(ScrollView)
  	self.barView:setPosOff(cc.p(-2,0))

  	self.proname={}
  	-- self.hppoint={}
  	self.loadingBlue={}
  	self.loadingRed={}
  	self.proBtn={}
  	self.proleft={}
  	self.proright={}
  	for i=1,zCount do
  		self:OneBattle(ScrollView,i)
  	end

	local function onButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local Tag = sender:getTag()
            print("点击",Tag)
            if Tag==ADDF then
            	local msg = REQ_FRIEND_ADD()
				msg:setArgs(1,1,{_uid})
				_G.Network:send(msg)
				self.addfBtn : setTitleText("删除好友")
				self.addfBtn : setTag(DELF)
            elseif Tag==DELF then
            	local msg = REQ_FRIEND_DEL()
				msg:setArgs(_uid,1)
				_G.Network:send(msg)
				self.addfBtn : setTitleText("加为好友")
				self.addfBtn : setTag(ADDF)
            elseif Tag==PKF then
            	local msg=REQ_WAR_PK()
			    msg:setArgs(_uid)
			    _G.Network:send(msg)
			    self:closeWindow()
            end
        end
    end

    self.addfBtn = gc.CButton : create("general_btn_gold.png")
    self.addfBtn : setTitleText("加为好友")
    self.addfBtn : setTitleFontName(_G.FontName.Heiti)
    self.addfBtn : setTitleFontSize(22)
    self.addfBtn : setPosition(self.base1Size.width/2-150,40) 
    self.addfBtn : addTouchEventListener(onButtonCallBack)
    self.addfBtn : setTag(ADDF)
    self.base1 : addChild(self.addfBtn)
    if _G.GFriendProxy:hasThisFriend(_uid) then
		self.addfBtn : setTitleText("删除好友")
		self.addfBtn : setTag(DELF)
	end


    local pkBtn = gc.CButton : create("general_btn_lv.png")
    pkBtn : setTitleText("切 磋")
    pkBtn : setTitleFontName(_G.FontName.Heiti)
    pkBtn : setTitleFontSize(22)
    pkBtn : setPosition(self.base1Size.width/2+150,40)
    pkBtn : setTag(PKF)
    pkBtn : addTouchEventListener(onButtonCallBack)
    self.base1 : addChild(pkBtn)
end

function BattleComparisonView.OneBattle( self, _scro,_num )
	local kuangSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_rolekuang.png")
	local kuangSize=cc.size(self.viewSize.width-10,self.oneHeight-6)
	kuangSpr:setPreferredSize(kuangSize)
	kuangSpr:setPosition(self.viewSize.width/2,self.containerSize.height-self.oneHeight/2-(_num-1)*self.oneHeight)
	_scro:addChild(kuangSpr)

	self.proname[_num] = _G.Util : createLabel(_typeName[_num], 20 )
	self.proname[_num] : setAnchorPoint( 0, 0.5 )
	self.proname[_num] : setPosition( 30, kuangSize.height/2   )
	-- self.proname[_num] : setColor(color1)
	kuangSpr : addChild( self.proname[_num] )

	local hpkuang=ccui.Scale9Sprite:createWithSpriteFrameName("ui_battlec_linebase.png")
	hpkuang:setPreferredSize(cc.size(533,19))
	hpkuang:setPosition(kuangSize.width/2-20,kuangSize.height/2)
	kuangSpr : addChild( hpkuang )
	local hpSize=hpkuang:getContentSize()
	self.hpWidth=hpSize.width
	self.hpHeight=hpSize.height

	-- self.hppoint[_num]=cc.Sprite:createWithSpriteFrameName("ui_battlec_point.png")
	-- self.hppoint[_num]:setPosition(hpSize.width*0.5+8,hpSize.height/2)
	-- self.hppoint[_num]:setVisible(false)
	-- hpkuang:addChild( self.hppoint[_num],10)
	
	self.loadingBlue[_num]=ccui.LoadingBar:create()
    self.loadingBlue[_num]:loadTexture("ui_battlec_blue.png",ccui.TextureResType.plistType)
    self.loadingBlue[_num]:setPosition(0,hpSize.height/2)
    self.loadingBlue[_num]:setAnchorPoint(cc.p(0,0.5))
    -- self.loadingBlue[_num]:setScale(200/296)
    self.loadingBlue[_num]:setPercent(0)
    hpkuang:addChild(self.loadingBlue[_num])

    self.loadingRed[_num]=ccui.LoadingBar:create()
    self.loadingRed[_num]:loadTexture("ui_battlec_red.png",ccui.TextureResType.plistType)
    self.loadingRed[_num]:setPosition(hpSize.width,hpSize.height/2)
    self.loadingRed[_num]:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.loadingRed[_num]:setAnchorPoint(cc.p(1,0.5))
    -- self.loadingRed[_num]:setScale(200/296)
    self.loadingRed[_num]:setPercent(0)
    hpkuang:addChild(self.loadingRed[_num])

    self.proleft[_num] = _G.Util : createLabel( "0", 18 )
	self.proleft[_num] : setAnchorPoint( 0, 0.5 )
	self.proleft[_num] : setPosition( 10, hpSize.height/2   )
	-- self.proleft[_num] : setColor(color2)
	hpkuang : addChild( self.proleft[_num],11 )

	self.proright[_num] = _G.Util : createLabel( "0", 18 )
	self.proright[_num] : setAnchorPoint( 1, 0.5 )
	self.proright[_num] : setPosition( hpSize.width-8, hpSize.height/2   )
	-- self.proright[_num] : setColor(color2)
	hpkuang : addChild( self.proright[_num],11 )

    local function proBtnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
        	local tag=sender:getTag()
        	local Pos=sender:getWorldPosition()
        	print("getWorldPosition",Pos.y,self.m_winSize.height/2+self.viewSize.height/2-45,self.m_winSize.height/2-self.viewSize.height/2-40)
        	if Pos.y>self.m_winSize.height/2+self.viewSize.height/2-45 
	            or Pos.y<self.m_winSize.height/2-self.viewSize.height/2-40
	            then return end
        	print("跳转",tag)
        	if _G.GOpenProxy:showSysNoOpenTips(SYSID_ARRAY[tag]) then return false end
        	_G.GLayerManager : openSubLayerByMapOpenId(ConstMap[tag])
    	end
    end

    self.proBtn[_num] = gc.CButton : create("general_btn_gold.png")
    self.proBtn[_num] : setTitleText("提升战力")
    self.proBtn[_num] : setTitleFontName(_G.FontName.Heiti)
    self.proBtn[_num] : setTitleFontSize(22)
    self.proBtn[_num] : setPosition(kuangSize.width-90,kuangSize.height/2)
    -- self.proBtn[_num] : setButtonScale(0.8)
    self.proBtn[_num] : setTag(_num)
    self.proBtn[_num] : addTouchEventListener(proBtnCallBack)
    kuangSpr : addChild(self.proBtn[_num])
end

function BattleComparisonView.REQ_ROLE_REQUEST_COMPARE( self, _uid )
	local msg = REQ_ROLE_REQUEST_COMPARE()
	msg : setArgs(_uid)
	_G.Network :send( msg )
end

function BattleComparisonView.ACK_ROLE_REPLY_COMPARE( self, _ackMsg )
	local msg = _ackMsg
	print("	对比玩家名字			:",		msg.name				)
	print("	对比玩家uid			:",		msg.uid					)
	print("	对比玩家lv			:",		msg.lv					)
	print("	对比玩家pro			:",		msg.pro					)
	print("	对比玩家vip等级		:",		msg.vip_lv				)
	print("	自己战斗力信息块		:", 	msg.count 				)

	local leftPor={}
	local rightPor={}

	for i=1,zCount do
		if msg.powerful_xxxx[i]==nil then break end
		print("	类型		:",	i,	msg.powerful_xxxx[i].type		)
		print("	战斗力	:",		msg.powerful_xxxx[i].powerful	)
		leftPor[i]=msg.powerful_xxxx[i].powerful
		self.proleft[i]:setString(leftPor[i])
	end
	print("	对比玩家战斗力信息块	:", 	msg.count2 				)
	for i=1,zCount do
		if msg.powerful_xxxx2[i]==nil then break end
		print("	类型		:",		msg.powerful_xxxx2[i].type		)
		print("	战斗力	:",		msg.powerful_xxxx2[i].powerful	)
		rightPor[i]=msg.powerful_xxxx2[i].powerful
		self.proright[i]:setString(rightPor[i])

		print("red or blue",leftPor[i]/(leftPor[i]+rightPor[i])*100,rightPor[i]/(leftPor[i]+rightPor[i])*100)
		self.loadingBlue[i]:setPercent(leftPor[i]/(leftPor[i]+rightPor[i])*100)
		self.loadingRed[i]:setPercent(rightPor[i]/(leftPor[i]+rightPor[i])*100)
	end


	if not self.firstIn then
		self.firstIn = true
		self : createALL( msg )
	end
end

function BattleComparisonView.createALL( self, _data )
	local data = _data
	local midNode = cc.Node : create()
	midNode : setPosition( self.base1Size.width/2, self.base1Size.height-95 )
	self.base1 : addChild( midNode )

	local headNum   = _G.GPropertyProxy.m_lpMainPlay : getPro()
	local left_head = cc.Sprite : createWithSpriteFrameName( string.format( "general_role_head%d.png", headNum ) )
	left_head : setScale(0.9)
	left_head : setPosition( -340, 0 )
	midNode   : addChild( left_head )

	local headNum    = _data.pro
	local right_head = cc.Sprite : createWithSpriteFrameName( string.format( "general_role_head%d.png", headNum ) )
	right_head : setScale(0.9)
	right_head : setPosition( 340, 0 )
	right_head : setScaleX(-1)
	midNode   : addChild( right_head )

	local nameLab   = _G.GPropertyProxy.m_lpMainPlay : getName()
	local left_name = _G.Util : createLabel( nameLab, 20 )
	left_name : setAnchorPoint( 0, 0.5 )
	left_name : setPosition( -280, 16  )
	midNode   : addChild( left_name )
	local left_nameSizex = left_name : getContentSize().width + 10

	local nameLab   = _data.name
	local right_name = _G.Util : createLabel( nameLab, 20 )
	right_name : setAnchorPoint( 1, 0.5 )
	right_name : setPosition( 280, 16   )
	midNode   : addChild( right_name )
	local right_nameSizex = right_name : getContentSize().width + 10

	local lvLab   = _G.GPropertyProxy.m_lpMainPlay : getLv()
	local left_lv = _G.Util : createLabel( string.format( "LV %d",lvLab ), 20 )
	left_lv : setAnchorPoint( 0, 0.5 ) 
	-- left_lv : setColor( color5  )
	left_lv : setPosition( -280, -18 )
	midNode : addChild( left_lv )

	local lvLab    = _data.lv
	local right_lv = _G.Util : createLabel( string.format( "LV %d",lvLab ), 20 )
	right_lv : setAnchorPoint( 1, 0.5 ) 
	-- right_lv : setColor( color5 )
	right_lv : setPosition( 280, -18 )
	midNode  : addChild( right_lv )

	local left_Vip = self : createPow( _G.GPropertyProxy.m_lpMainPlay : getVipLv() )
	left_Vip : setAnchorPoint( 0, 0.5 )
	left_Vip : setPosition( -270+left_nameSizex, 16 )
	midNode  : addChild( left_Vip )

	local right_Vip = self : createPow( _data.vip_lv, 2 )
	right_Vip : setAnchorPoint( 1, 0.5 )
	right_Vip : setPosition( 270-right_nameSizex, 16 )
	midNode   : addChild( right_Vip )
end

function BattleComparisonView.createPow( self, _vipLv, _which )
	local layer = cc.Layer:create()
	local node  = cc.Node :create()
	layer : addChild( node )

	local spr_vip = cc.Sprite : createWithSpriteFrameName( "general_vip.png" )
	spr_vip : setAnchorPoint( 0, 0.5 )
	node    : addChild( spr_vip )
	local width  = spr_vip:getContentSize().width

	local shiWei = math.modf( _vipLv / 10 )
	if shiWei > 0 then
		local spr_shiWei = cc.Sprite : createWithSpriteFrameName( string.format("general_vipno_%d.png",shiWei) )
		spr_shiWei : setAnchorPoint( 0, 0.5 )
		spr_shiWei : setPosition( width, 0  )
		node : addChild( spr_shiWei )
		width = width + spr_shiWei : getContentSize().width/2
	end
	local geWei = _vipLv%10
	local spr_geWei = cc.Sprite : createWithSpriteFrameName( string.format("general_vipno_%d.png",geWei) )
	spr_geWei : setAnchorPoint( 0, 0.5 )
	spr_geWei : setPosition( width, 0  )
	node : addChild( spr_geWei )
	width = width + spr_geWei : getContentSize().width

	layer : setContentSize( cc.size( width, 0 ) )
	if _which == 2 then
		node : setPosition( -width, 0 )
	end

	return layer
end

function BattleComparisonView.closeWindow( self )
	self.m_rootLayer:removeFromParent(false)
	self.m_rootLayer=nil

	self.m_mediator : destroy()
   	self.m_mediator = nil 
end

return BattleComparisonView