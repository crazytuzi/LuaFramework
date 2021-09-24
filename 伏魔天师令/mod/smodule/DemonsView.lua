local DemonsView = classGc( view, function( self, _openType )
	-- self.m_openType = _openType

	self.m_winSize  	= cc.Director:getInstance() : getWinSize()
	self.m_viewSize 	= cc.size( 780, 460 )

	self.mySkillState  	= { [_G.Const.CONST_PRO_ZHENGTAI]  = {false,false,false,false,false,0}, 
							[_G.Const.CONST_PRO_SUNMAN	]  = {false,false,false,false,false,0},
							[_G.Const.CONST_PRO_ICEGIRL	]  = {false,false,false,false,false,0},
							[_G.Const.CONST_PRO_BIGSISTER] = {false,false,false,false,false,0},
							[_G.Const.CONST_PRO_LOLI	]  = {false,false,false,false,false,0},} 
	self.currultPro  	= 2
	
	self.FisrtIn        = {}

	self.m_mediator 	= require("mod.smodule.DemonsMediator")() 
	self.m_mediator 	: setView(self) 

	self.m_resourcesArray = {}
end)

local openRole={
    [1] = { tag=_G.Const.CONST_PRO_ZHENGTAI },
    [2] = { tag=_G.Const.CONST_PRO_SUNMAN },
    [3] = { tag=_G.Const.CONST_PRO_ICEGIRL },
    [4] = { tag=0 }
}

local NoTouch 	= true
local FONTSIZE 	= 20

local COLOR_BROWN = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN )
local COLOR_DARKORANGE = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE)
local COLOR_ORED = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED)
local COLOR_GRASSGREEN = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN)

local NUM_ROLE  = 5  -- 人物数量
local NUM_SKILL = 5  -- 技能数量
local LEV_SKILL = _G.Const.CONST_THOUSAND_SKILL_LV  -- 技能等级

local Tag_Spr_LeftView  = 1000
local Tag_Btn_Explain  	= 1005
local Tag_Skill			= { [_G.Const.CONST_PRO_ZHENGTAI]  = {11010, 11020, 11030, 11040, 11050},
							[_G.Const.CONST_PRO_SUNMAN  ]  = {12010, 12020, 12030, 12040, 12050},
							[_G.Const.CONST_PRO_ICEGIRL ]  = {13010, 13020, 13030, 13040, 13050},
							[_G.Const.CONST_PRO_BIGSISTER] = {14010, 14020, 14030, 14040, 14050},
							[_G.Const.CONST_PRO_LOLI  	]  = {15010, 15020, 15030, 15040, 15050}}

local ROLECNF      		= openRole
local Tag_Role			= { ROLECNF[1].tag, 
							ROLECNF[2].tag,
							ROLECNF[3].tag,
							ROLECNF[4].tag}
							-- ROLECNF[5].tag}

local ROLELIST      	= { [ROLECNF[1].tag] 	= ROLECNF[3].tag,
							[ROLECNF[2].tag] 	= ROLECNF[4].tag,
							[ROLECNF[3].tag] 	= ROLECNF[1].tag,
							[ROLECNF[4].tag] 	= ROLECNF[2].tag,
							-- [ROLECNF[5].tag] 	= ROLECNF[3].tag,
							[0] = 0, }

local Tag_Btn_Rank  	= 2001
local Tag_Btn_Goods 	= 2002
local Tag_Btn_Fight 	= 2003
local Tag_Btn_Add 		= 2004
local Tag_NoTouch 		= 2005

local demonsText = { [_G.Const.CONST_PRO_ZHENGTAI]  = "demons_1.png", 
					 [_G.Const.CONST_PRO_SUNMAN  ]  = "demons_2.png", 
					 [_G.Const.CONST_PRO_ICEGIRL ]  = "demons_3.png", 
					 [_G.Const.CONST_PRO_BIGSISTER] = "demons_4.png", 
					 [_G.Const.CONST_PRO_LOLI  	 ]  = "demons_5.png",
					 [0] = "demons_0.png" }

function DemonsView.create( self )
	self.m_settingView = require( "mod.general.NormalView" )()
	self.gamSetLabel   = self.m_settingView : create( "斗转星移" )
	self.m_settingView : setTitle( "斗转星移" )

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.gamSetLabel)

	self : REQ_THOUSAND_REQUEST()
	self:init()

	return tempScene
end

function DemonsView.init( self )

	local function closeFunSetting()
		self : closeWindow()
	end
  	local Btn_Close    = self.m_settingView : getCloseBtn()
  	self.m_settingView : showSecondBg()
  	self.m_settingView : addCloseFun(closeFunSetting)

  	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2-18 ) )
	self.gamSetLabel 	: addChild( self.mainContainer )

	local doubleSize = cc.size( 833,475 )
	local doubleView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double.png" ) 
	doubleView : setContentSize(doubleSize)
	doubleView : setPosition(0, -22)
	self.mainContainer : addChild( doubleView )

	self : createLftView()
	self : createRghView()
end

function DemonsView.createLftView( self )

	local SizeLeftView = cc.size( 596,462 )
	local Spr_LeftView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
	Spr_LeftView : setContentSize(SizeLeftView)
	Spr_LeftView : setPosition( cc.p( -111, -23 ) )
	Spr_LeftView : setTag( Tag_Spr_LeftView )
	self.mainContainer : addChild( Spr_LeftView )

	local Wid_leftView = SizeLeftView.width
	local Hei_leftView = SizeLeftView.height

	local Lab_1 = _G.Util : createLabel( "角色选择：", FONTSIZE )
	Lab_1 : setAnchorPoint( 0, 0.5 )
	Lab_1 : setColor( COLOR_BROWN )
	Lab_1 : setPosition( 25, Hei_leftView - 50 )
	Spr_LeftView : addChild( Lab_1 )

	-- 技能已选定
	self.Spr_Skill = {}
	for i=1,NUM_SKILL do
		self.Spr_Skill[i] = cc.Sprite : createWithSpriteFrameName( "Demons_skill_box_2.png" )
		self.Spr_Skill[i] : setPosition( 65 + (i-1)*115, 112 )
		Spr_LeftView 	  : addChild( self.Spr_Skill[i], 10 )

		self.Spr_Skill[i] : setVisible( false )
	end

	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end

	local Btn_Explain = gc.CButton : create()
	Btn_Explain  : loadTextures( "general_help.png", "", "", ccui.TextureResType.plistType )
	Btn_Explain  : setPosition( Wid_leftView-50 , Hei_leftView - 45 ) 
	Btn_Explain  : setTag( Tag_Btn_Explain )
	Btn_Explain  : addTouchEventListener( ButtonCallBack )
	Spr_LeftView 	 : addChild( Btn_Explain )

	local guideId=_G.GGuideManager:getCurGuideId()
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_DZXY then
    	_G.GGuideManager:initGuideView(self.gamSetLabel)
    	_G.GGuideManager:registGuideData(1,Btn_Explain)
    	_G.GGuideManager:runNextStep()
    	self.m_guide_wait_touch=true
    	self.m_hasGuide=true
    end

	local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	lineSpr : setPreferredSize( cc.size( Wid_leftView-10, lineSpr:getContentSize().height ) )
	lineSpr : setPosition( Wid_leftView/2, Hei_leftView - 100 )
	Spr_LeftView   : addChild( lineSpr)

	local lineSpr2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	lineSpr2 : setPreferredSize( cc.size( Wid_leftView-10, lineSpr:getContentSize().height ) )
	lineSpr2 : setPosition( Wid_leftView/2, Hei_leftView/2-5 )
	Spr_LeftView     : addChild( lineSpr2 )

	local pit_x  = { 95, Wid_leftView/2-10, Wid_leftView/2 + 165 }
	self.Btn_People = {}
	self.Spr_People = {}
	-- for i=1,3 do
	-- 	self.Btn_People[i] = gc.CButton : create()
	-- 	self.Btn_People[i] : loadTextures( piture[i])
	-- 	self.Btn_People[i] : setPosition( pit_x[i], Hei_leftView/2+77 )
	-- 	self.Btn_People[i] : setTag( Tag_Btn_Choise[i] )
	-- 	self.Btn_People[i] : addTouchEventListener( ButtonCallBack )	
	-- 	Spr_LeftView    : addChild( self.Btn_People[i] )
	-- 	-- self.Btn_People[i] : setVisible( false )
	-- end

	self : createAllRole( Spr_LeftView )

	local Lab_2 = _G.Util : createLabel( "技能选择:", FONTSIZE )
	Lab_2 : setAnchorPoint( 0, 0.5 )
	Lab_2 : setPosition( 25, Hei_leftView/3 + 38 )
	Lab_2 : setColor( COLOR_BROWN )
	Spr_LeftView : addChild( Lab_2 )

	local Lab_3 = _G.Util : createLabel( "（点击选择/取消技能,可选3个技能）", FONTSIZE )
	Lab_3 : setAnchorPoint( 0, 0.5 )
	Lab_3 : setPosition( 125, Hei_leftView/3 + 38 )
	Lab_3 : setColor( COLOR_DARKORANGE )
	Spr_LeftView : addChild( Lab_3 )

	local Num = 1
	self.Widget_Skill = {} 
	self.Spr_mySkill_1 = {}
	self : chooseOne( 2 )


end

function DemonsView.createAllRole( self, place )
	local function myCallBack( obj, touchEvent )
		tag = obj : getTag()
		local nPosx=obj:getWorldPosition().x
		print( "按下了：", tag,nPosx,self.m_winSize.width/2-320,self.m_winSize.width/2+100 )
		if nPosx < self.m_winSize.width/2-320 or nPosx > self.m_winSize.width/2+100 then return end
		if touchEvent == ccui.TouchEventType.ended then	
			local which = nil
			for i=1,3 do
				if obj == self.Btn_People[i] then
					which = i
				end
			end
			print( "which = ", which )
			self : chooseOne( which, tag )
		end
	end

	local posx 		= { 85, 285, 485, -95, 665 }
	local posy 		= 295
	local width  	= 568
	local height 	= 98
	local viewSize      = cc.size( width, height)
	local containerSize = cc.size( width, height)
	local ScrollView    = cc.ScrollView : create()
	ScrollView  : setDirection(ccui.ScrollViewDir.horizontal)
	ScrollView  : setViewSize(viewSize)
	ScrollView  : setAnchorPoint( 0,0 )
	ScrollView  : setContentSize(containerSize)
	ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
	ScrollView  : setPosition( 10, posy-50 )
	ScrollView  : setTouchEnabled( false)
	ScrollView  : setDelegate()
	place : addChild( ScrollView,5 )

	self.RoleNode = cc.Node : create()
	ScrollView : addChild( self.RoleNode  )

	-- 只需创建3个
	-- local piture = { "demons_1.png", "demons_2.png", "demons_3.png", "demons_5.png", "demons_5.png"  }
	local piture = { "demons_0.png", "demons_0.png", "demons_0.png", "demons_0.png", "demons_0.png"  }
	local myRole = { Tag_Role[1], Tag_Role[2], Tag_Role[3], ROLELIST[Tag_Role[2]], ROLELIST[Tag_Role[2]]  }
	for i=1,5 do
		self.Btn_People[i] = gc.CButton : create()
		self.Btn_People[i] : loadTextures( piture[i])
		self.Btn_People[i] : setPosition( posx[i], 94/2+3 )
		self.Btn_People[i] : setTag( myRole[i] )
		self.Btn_People[i] : addTouchEventListener( myCallBack )	
		self.RoleNode      : addChild( self.Btn_People[i] )
		-- self.Btn_People[i] : setButtonScale( 0.7 )

		local btnSize=self.Btn_People[i]:getContentSize()
		self.Spr_People[i]=ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
		self.Spr_People[i]:setPreferredSize(btnSize)
		self.Spr_People[i]:setOpacity(180)
		self.Spr_People[i]:setPosition(btnSize.width/2,btnSize.height/2)
		self.Btn_People[i]:addChild(self.Spr_People[i])
	end
	self.Btn_People[2] : setTouchEnabled( false )
	self.Btn_People[3] : setTouchEnabled( false )
end

function DemonsView.chooseOne( self, which, midPro )
	if self.currultPro == midPro then return end
	-- 1 往中间移动 与 特效 增加图片
	self : moveToMidAndSet( which )
	self.currultPro = midPro
end

function DemonsView.moveToMidAndSet( self, which )
	if which == 2 then
		self : toDark()
		self : addSkillAll( self.Btn_People[which]:getTag() )
		return
	end
	print( "特效开始 !" )
	local posx = { [1] = 170,[3] = -170 }
	local posy = 0
	local move1, move2 = nil
	move2 = self.Btn_People[2]
	if which == 1 then
		move1 = self.Btn_People[1]
	elseif which == 3 then
		move1 = self.Btn_People[3]
	end

	local function tou1( )
		for i=1,5 do
			self.Btn_People[i] : setTouchEnabled( false )
		end
	end

	local function tou2( )
		for i=1,5 do
			self.Btn_People[i] : setTouchEnabled( true )
		end
	end

	local function set1( self )
		if self == move2 then
			move2 : setOpacity( 255 * 0.5)
		else
			move1 : setOpacity( 255 )
		end
	end

	local function skillcall( )
		self : addSkillAll( move1:getTag() )
	end

	local function call1( )
		move2 : runAction( cc.ScaleTo:create( 0.2, 1 ) )
	end

	local function call2( )
		move1 : runAction( cc.ScaleTo:create( 0.2, 1 ) )
	end

	local function call3( )
		self : resetAll( move1:getTag() )
	end

	self.RoleNode : runAction( 
				cc.Sequence : create( 
							cc.CallFunc : create( tou1 ),
							cc.Spawn:create(
									cc.CallFunc : create( skillcall ),
									cc.MoveTo   : create( 0.2, cc.p( posx[which], posy ) ),
									cc.CallFunc : create( call1 ), 
									cc.CallFunc : create( call2 )
											),
							cc.DelayTime: create( 0.1 ),
							cc.CallFunc : create( call3 )
							-- cc.CallFunc : create( tou2 )
									)
							 )
end

function DemonsView.resetAll( self, tag )
	local function find_index( _tag )
		for i=1,3 do
			if Tag_Role[i] == _tag then
				return i
			end 
		end
		return 0
	end
	local function check_right( _num )
		local num = _num + 1
		if num > 4 then
			return 1
		end
		return num
	end
	local function check_left( _num )
		local num = _num - 1
		if num < 1 then
			return 3
		end
		return num
	end
	local mylist = {}
	local num = find_index(tag)
	if num == 0 then
		print( "DemonsView.resetAll 查找错误!" )
		num = 2
	end
	print( "num--->>>",num,check_right(num) )
	mylist[1] = Tag_Role[ check_left(num) ]
	mylist[2] = tag
	mylist[3] = Tag_Role[ check_right(num) ]
	mylist[4] = ROLELIST[Tag_Role[num]]
	mylist[5] = ROLELIST[Tag_Role[num]]

	for i=1,5 do
		print(  "第几个：", "DemonsView.resetAll", mylist[i], demonsText[mylist[i]] )
		-- self.Btn_People[i] : loadTextures( string.format( "demons_%d.png", mylist[i] ) )
		self.Btn_People[i] : loadTextures( demonsText[mylist[i]] )
		self.Btn_People[i] : setTag( mylist[i] )
		self.Btn_People[i] : setTouchEnabled( true )
		if mylist[i] == 0 then
			self.Btn_People[i] : setTouchEnabled( false )
		end
		if i ~= 2 then
			self.Btn_People[i] : setOpacity( 255 * 0.5)
			self.Spr_People[i] : setVisible(true)
			-- self.Btn_People[i] : setButtonScale( 0.7 )
		else
			self.Btn_People[2] : setOpacity( 255 )
			-- self.Btn_People[2] : setButtonScale( 1 )
			self.Spr_People[2] : setVisible(false)
			self:removeselectSpr(self.Btn_People[2])
		end
	end
	self.RoleNode : setPosition( 0, 0 )
end

function DemonsView.removeselectSpr( self,Btn )
	if self.selectSpr~=nil then
		self.selectSpr:removeFromParent(true)
		self.selectSpr=nil
	end

	local btnSize=Btn:getContentSize()
	self.selectSpr=cc.Sprite:createWithSpriteFrameName("demons_select.png")
	self.selectSpr:setPosition(btnSize.width/2,btnSize.height/2)
	Btn:addChild(self.selectSpr)
end

function DemonsView.toDark( self )
	self.Btn_People[1] : setOpacity( 255 * 0.5)
	self.Spr_People[1] : setVisible(true)
	self.Btn_People[3] : setOpacity( 255 * 0.5)
	self.Spr_People[3] : setVisible(true)
	self.Btn_People[2] : setOpacity( 255 )
	self.Spr_People[2] : setVisible(false)
	self:removeselectSpr(self.Btn_People[2])
end

function DemonsView.createRghView( self )
	local SizeRightView = cc.size( 217,462 )
	local Spr_RightView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
	Spr_RightView : setContentSize( SizeRightView )
	Spr_RightView : setPosition( cc.p( 300, -23 ) )
	self.mainContainer : addChild( Spr_RightView )

	local Wid_RighView = SizeRightView.width
	local Hei_RighView = SizeRightView.height

	-- local Spr_RiBase = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" )
	-- Spr_RiBase : setContentSize( cc.size( Wid_RighView - 6, Hei_RighView - 6 ) )
	-- Spr_RiBase : setPosition( cc.p( Wid_RighView/2, Hei_RighView/2 ) )
	-- Spr_RightView : addChild( Spr_RiBase )

	local Text_Rgh = { "我的排行：", "最高伤害：", "耗费时间：", "挑战次数：" }
	local Pos_y    = { Hei_RighView - 40, Hei_RighView - 70 , Hei_RighView - 100, 122 }
	self.Lab_Right = {}
	for i=1,4 do
		local lab = _G.Util : createLabel( Text_Rgh[i], FONTSIZE )
		lab : setAnchorPoint( 0, 0.5 )
		lab : setColor( COLOR_BROWN )
		lab : setPosition( 20, Pos_y[i] )
		Spr_RightView : addChild( lab )

		self.Lab_Right[i] = _G.Util : createLabel( "0", FONTSIZE )
		self.Lab_Right[i] : setAnchorPoint( 0, 0.5 )
		self.Lab_Right[i] : setColor( COLOR_DARKORANGE )
		self.Lab_Right[i] : setPosition( lab:getContentSize().width +43, Pos_y[i] )
		Spr_RightView : addChild( self.Lab_Right[i],5 )
		if i == 4 then
		-- 	lab : setColor( COLOR_GRASSGREEN )
			self.Lab_Right[i] : setColor( COLOR_GRASSGREEN )
		end
	end

	-- local inputSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_input.png")
	-- inputSpr 		: setPreferredSize( cc.size( 40, inputSpr:getContentSize().height ) )
	-- inputSpr 		: setPosition( 135, 123 )
	-- Spr_RightView 	: addChild( inputSpr )

	local Spr_Line 	= ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	Spr_Line 		: setPreferredSize( cc.size( 206, 2 ) )
	Spr_Line 		: setPosition( 115, 165 )
	Spr_RightView 	: addChild( Spr_Line )

	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end

	local Btn_Rank = gc.CButton : create( )
	Btn_Rank : loadTextures( "general_btn_lv.png" )
	Btn_Rank : setTitleText( "排行榜" )
	Btn_Rank : setTitleFontName( _G.FontName.Heiti )
	--Btn_Rank : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	Btn_Rank : setTitleFontSize( FONTSIZE+2 )
	Btn_Rank : setPosition( 115, Hei_RighView/2 + 60 )
	Btn_Rank : setTag( Tag_Btn_Rank )
	Btn_Rank : addTouchEventListener( ButtonCallBack )
	Spr_RightView : addChild( Btn_Rank )

	local Btn_Goods = gc.CButton : create( )
	Btn_Goods : loadTextures( "general_btn_gold.png")
	Btn_Goods : setTitleText( "奖励预览" )
	Btn_Goods : setTitleFontName( _G.FontName.Heiti )
	--Btn_Goods : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	Btn_Goods : setTitleFontSize( FONTSIZE+2 )
	Btn_Goods : setPosition( 115, Hei_RighView/2 - 10 )
	Btn_Goods : setTag( Tag_Btn_Goods )
	Btn_Goods : addTouchEventListener( ButtonCallBack )
	Spr_RightView : addChild( Btn_Goods )

	local Btn_Add = gc.CButton : create()
	Btn_Add : loadTextures( "general_btn_add.png", "", "", ccui.TextureResType.plistType )
	Btn_Add : setPosition( 185, 122 )
	Btn_Add : setTag( Tag_Btn_Add )
	Btn_Add : addTouchEventListener( ButtonCallBack )
	Spr_RightView : addChild( Btn_Add )

	local Btn_Fight = gc.CButton : create( )
	Btn_Fight : loadTextures( "general_btn_gold.png", "", "", ccui.TextureResType.plistType )
	Btn_Fight  : setTitleText( "开始挑战" )
	Btn_Fight  : setTitleFontName( _G.FontName.Heiti )
	Btn_Fight  : setTitleFontSize( FONTSIZE+2 )
	Btn_Fight : setPosition( 115, 60 )
	Btn_Fight : setTag( Tag_Btn_Fight )
	Btn_Fight : addTouchEventListener( ButtonCallBack )
	Spr_RightView : addChild( Btn_Fight )
end

function DemonsView.closeWindow( self )
	print( "开始关闭" )

	ScenesManger.releaseFileArray(self.m_resourcesArray)

	if self.gamSetLabel == nil then return end
	self.gamSetLabel=nil
	cc.Director:getInstance():popScene()
	self:destroy()

	if self.m_hasGuide then
        local command=CGuideNoticShow()
        controller:sendCommand(command)
    end
end

function DemonsView.addSkillAll( self, Pro )

	print( "创建技能开始" )
	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end

	print( "创建出来了", Pro )
	if self.Widget_Skill[Pro] == nil then
		self.Spr_mySkill_1[Pro]={}
		local Spr_LeftView = self.mainContainer : getChildByTag( Tag_Spr_LeftView )
		self.Widget_Skill[Pro] = ccui.Widget : create()
		self.Widget_Skill[Pro] : setContentSize( cc.size(Spr_LeftView:getContentSize().width, 100) )
		self.Widget_Skill[Pro] : setPosition( Spr_LeftView:getContentSize().width/2, 97 )
		self.Widget_Skill[Pro] : setSwallowTouches( false )
		Spr_LeftView : addChild( self.Widget_Skill[Pro], 2 )
		for i=1,NUM_SKILL do
			local widget   = ccui.Widget : create()
			widget : setContentSize( cc.size(80, 80) )
			widget : setPosition( cc.p(65 + (i-1)*115 , 70) )
			widget : setTouchEnabled( true )
			widget : setSwallowTouches( false )
			widget : setTag( Tag_Skill[Pro][i] )
			widget : addTouchEventListener( ButtonCallBack )
			self.Widget_Skill[Pro] : addChild( widget )

			
			self.Spr_mySkill_1[Pro][i] = cc.Sprite : createWithSpriteFrameName( "Demons_skill_box_1.png" )
			self.Spr_mySkill_1[Pro][i] : setPosition( 40, 35 )
			-- self.Spr_mySkill_1[i] : setAnchorPoint( 0, 0 )
			widget : addChild( self.Spr_mySkill_1[Pro][i], 5 )
			
			self : addSkillIcon( Tag_Skill[Pro][i], widget, i )
		end
	end
	for i=1,NUM_ROLE do
		if Pro ~= i then 
			if self.Widget_Skill[i] ~= nil then 
				self.Widget_Skill[i] : setVisible( false )
			end
		else
			self.Widget_Skill[i] : setVisible( true )
		end
	end
	print( "转换再这里 33333" )
	self : ChangeSkillEquip()
	print( "创建技能结束" )
end

function DemonsView.addSkillIcon( self, _skillId, _iconBg, _num )
    if _skillId == nil or _iconBg == nil or _skillId == 0 then
        return
    end
    print( "_skillId===>>>", _skillId )
    if not _G.Cfg.skill[_skillId] then return end
    local iconString = _G.Cfg.skill[_skillId].icon
    self :removeSkillIcon(_iconBg)
    local skillIconSpr = _G.ImageAsyncManager:createSkillSpr(iconString)
    skillIconSpr       : setPosition( _iconBg:getContentSize().width/2, _iconBg:getContentSize().height/2-5)
    _iconBg :addChild( skillIconSpr, 2, 100 )

    local sprName = string.format( "icon/s%d.png", iconString )
    print( sprName )
    if self.m_resourcesArray[ sprName ] == nil then
    	self.m_resourcesArray[ sprName ] = true
    end

    local Lab_SkillName = _G.Util : createLabel(  _G.Cfg.skill[_skillId].name, FONTSIZE)
    Lab_SkillName : setPosition( _iconBg:getContentSize().width/2, -40 )
    Lab_SkillName : setColor( COLOR_BROWN )
    _iconBg :addChild( Lab_SkillName, 4 )
end

function DemonsView.removeSkillIcon( self, _iconBg )
    if _iconBg :getChildByTag( 100 ) ~= nil then
        _iconBg :removeChildByTag( 100 )
    end
end

function DemonsView.cleanSkillState( self, pro )
	for i=1,5 do
		self.mySkillState[pro][i] = false
	end
end

function DemonsView.ChangeSkillEquip( self )
	local pro = self.currultPro
	local num = 0
	for i=1,NUM_SKILL do
		print( "pro = ", pro )
		if self.mySkillState[pro][i] ~= nil then
			if self.mySkillState[pro][i] == true then 
				self : ChangeSkillToBlue( i, true )
				num = num + 1
			else
				self : ChangeSkillToBlue( i, false )
			end
		end
	end

	if num == 0 and not self.FisrtIn[pro] then
		self.FisrtIn[pro] = true
		num = 3
		for i=1,3 do
			self.mySkillState[pro][i] = true
			self : ChangeSkillToBlue( i, true )
		end
	end
	self.mySkillState[pro][6] = num
	print( "pro = ", pro, self.currultPro )
	print( "self.mySkillState[pro][6] = ", self.mySkillState[pro][6] )
end

function DemonsView.ChangeSkillToBlue( self, _num, _isTrue )
	print( "第几个：", _num, _isTrue, not _isTrue )
	self.Spr_Skill[_num] : setVisible( _isTrue )
	self.Spr_mySkill_1[self.currultPro][_num] : setVisible( not _isTrue )
end

-- function DemonsView.ChoisePeple( self, _tag )
-- 	local tag = _tag
-- 	for i=1,3 do
-- 		if tag == Tag_Btn_Choise[i] then 
-- 			self.Btn_People[i] : setDefault()
-- 			self.currultPro = i
-- 			self : addSkillAll( i )
-- 		else
-- 			self.Btn_People[i] : setGray()
-- 		end
-- 	end
-- 	print( "self.currultPro = ", self.currultPro )
-- end

function DemonsView.event_Btn_Skill( self, _tag )
	local tag = _tag
	for i=1,NUM_SKILL do
		if Tag_Skill[self.currultPro][i] == tag then 
			print( "匹配到了对应的tag值：", tag )
			if self.mySkillState[self.currultPro][i] == true then
				self.mySkillState[self.currultPro][i] = false
				self.mySkillState[self.currultPro][6] = self.mySkillState[self.currultPro][6] - 1
			else
				if self.mySkillState[self.currultPro][6] >= 3 then 
					local command = CErrorBoxCommand(37730)
    	        	controller : sendCommand( command )
    	        	print( "转换再这里 技能超过3个" )
    	        	self : ChangeSkillEquip()
    	        	return
				else
					self.mySkillState[self.currultPro][i] = true
					self.mySkillState[self.currultPro][6] = self.mySkillState[self.currultPro][6] + 1
				end
			end
		end
	end
	print( "转换再这里 22222" )
	self : ChangeSkillEquip()
end

function DemonsView.messageBox( self, _ackMsg )
	local function tipsSure()
		print( "确定按下" )
		self : REQ_THOUSAND_BUY()
    end
    local function cancel()
    	NoTouch = true
    end
  
	if NoTouch == false then   
		self : REQ_THOUSAND_BUY()
		return
	end

	local tipsBox = require("mod.general.TipsBox")()
	local mainNode   = tipsBox :create( "", tipsSure, cancel)
	-- mainNode : setPosition(cc.p(0,0))
	self.gamSetLabel 	: addChild(mainNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

	local layer= tipsBox:getMainlayer()
	local msg   = _ackMsg
    local Lab_1 = _G.Util : createLabel( string.format( "%s%d%s", "花费", msg.rmb, "元宝购买一次挑战？"), FONTSIZE  )
    -- Lab_1 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN ) )
    Lab_1 : setPosition( 0, 60 )
    layer : addChild( Lab_1 )

    local Lab_3 = _G.Util : createLabel( "（元宝不足则消耗钻石）", FONTSIZE-2 )
    -- Lab_3 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN ) )
    Lab_3 : setPosition( 0, 30 )
    layer : addChild( Lab_3 )

    local Lab_2 = _G.Util : createLabel( "剩余购买次数：", FONTSIZE  )
    -- Lab_2 : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN ) )
    Lab_2 : setPosition( -4, -5 )
    layer : addChild( Lab_2 )

    local Lab_times = _G.Util : createLabel( msg.times, FONTSIZE  )
    Lab_times : setPosition( Lab_2:getContentSize().width/2+5, -5 )
    layer 	  : addChild( Lab_times )
    Lab_times : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
    if msg.times <= 0 then
    	Lab_times : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
    end

	function checkBoxCallback( obj, touchEvent )
		self : touchEventCallBack( obj, touchEvent )
	end

	local uncheckBox 	= "general_gold_floor.png"
	local selectBox  	= "general_check_selected.png"
	local checkBox = ccui.CheckBox : create( uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType )
	checkBox : addEventListener( checkBoxCallback )
	checkBox : setPosition( cc.p( -80, -52 ) )
	checkBox : setTag( Tag_NoTouch )
	layer 	 : addChild(checkBox) 

	local CheckLabel = _G.Util : createLabel( _G.Lang.LAB_N[106], FONTSIZE )
	-- CheckLabel : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN ) )
	CheckLabel : setPosition( 25, -50 )
	layer	   : addChild( CheckLabel )

end

-- 1 ：奖励预览
-- 2 ：排行榜
function DemonsView.createRankView( self, msg )
	if self.m_rankLayer~=nil then return end
  	local function onTouchBegan(touch,event)
        return true
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rankLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rankLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rankLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rankLayer,1001)

    local rankSize=cc.size(705,517)
    local secondSize=cc.size(687,460)
  	local Spr1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
  	Spr1 : setPreferredSize( rankSize )
  	Spr1 : setPosition( self.m_winSize.width/2, self.m_winSize.height/2-20 )
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
    tipslogoSpr : setPosition(rankSize.width/2-135, rankSize.height-28)
    Spr1 : addChild(tipslogoSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(rankSize.width/2+130, rankSize.height-28)
    tipslogoSpr : setRotation(180)
    Spr1 : addChild(tipslogoSpr)

    local m_titleLab=_G.Util:createBorderLabel("排名奖励",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(rankSize.width/2,rankSize.height-26)
    Spr1:addChild(m_titleLab)

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(secondSize)
    di2kuanbg       : setPosition(cc.p(rankSize.width/2,rankSize.height/2-18))
    Spr1       : addChild(di2kuanbg)

  	local width  = secondSize.width
  	local height = secondSize.height

  	local count  		= 0
  	local ScrollHeigh 	= 360
  	local countHeight   = 60
  	local myNode 		= cc.Node : create()

	count = msg.count

	local myRank = msg.self_rank + 1
	if myRank > 21 then
		myRank = 1
	end
	local goods  = _G.Cfg.thousand_rank[myRank].reward[1]
	local reward = string.format( "%s%s%d", _G.Cfg.goods[ goods[1] ].name, "*", goods[2] )
	local text = { "排名", "玩家名称", "伤害", "耗时", "奖励" }
	local mytext={msg.self_rank,_G.GPropertyProxy : getMainPlay() : getName(),self.myHarm or "暂无",self : _getTimeStr(self.myTime or 0 ),reward}
	local PosX = { 50, 180, 320, 440, 580 }
	for i=1,5 do
		local mylab = _G.Util : createLabel( text[i], FONTSIZE )
		-- mylab 		: setColor( COLOR_GRASSGREEN )
		mylab 		: setAnchorPoint( 0.5, 1 )
		mylab		: setPosition( PosX[i]+20, height-12 )
		di2kuanbg : addChild( mylab )

		local lab1  =  _G.Util : createLabel( mytext[i], FONTSIZE )
		lab1 		: setPosition( PosX[i]+20, 51 )
		di2kuanbg   : addChild( lab1 )

		if msg.self_rank == nil or msg.self_rank == 0 then
			if i~=2 then
				lab1 : setString( "暂无" )
			end
		end
	end

	local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	local lineheight=line1:getContentSize().height
	line1 : setPreferredSize( cc.size(width-30, 3) )
	line1 : setAnchorPoint( 0, 0 )
	line1 : setPosition( 15, height-43 )
	di2kuanbg : addChild( line1 )

	local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line2 : setPreferredSize( cc.size(width-30, 3) )
	line2 : setAnchorPoint( 0, 0 )
	line2 : setPosition( 15, 67 )
	di2kuanbg : addChild( line2 )

	local line3 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line3 : setPreferredSize( cc.size(width-30, 3) )
	line3 : setAnchorPoint( 0, 0 )
	line3 : setPosition( 15, 33  )
	di2kuanbg : addChild( line3 )

	local star   = cc.Sprite : createWithSpriteFrameName( "general_star.png" ) 
	-- star 		 : setScale( 0.7 )
	star 		 : setPosition( PosX[1]-20, 50 )
	di2kuanbg  : addChild( star )

	local lab6 = _G.Util : createLabel( "周日21:00通过邮件发放奖励！", 20 )
	lab6 : setPosition( width/2, 18 )
	-- lab6 : setAnchorPoint( 0, 0.5 )
	lab6 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	di2kuanbg : addChild( lab6 )

	local color6 = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED )
	local color7 = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD )
	local color8 = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BLUE  ) 
	local myColor = { color6, color7, color8 }
	local LabHeight=346/10
	for i=1,count do
		local goods    = _G.Cfg.thousand_rank[msg.msg_rank[i].rank+1].reward[1]
		local RankText = { msg.msg_rank[i].rank, msg.msg_rank[i].name, msg.msg_rank[i].harm, self : _getTimeStr(msg.msg_rank[i].time),
					 	   string.format("%s%s%d", _G.Cfg.goods[ goods[1] ].name or "无", "*", goods[2])  }
		for k=1,5 do
			local mylab = _G.Util : createLabel(RankText[k], FONTSIZE )
			-- mylab		: setColor( COLOR_GRASSGREEN )
			mylab 		: setPosition( PosX[k]+20, count*LabHeight-(i-1)*LabHeight-11 )
			myNode 		: addChild( mylab )
			if i <= 3 then
				mylab		: setColor( myColor[i] )
			end
		end
		local myline_1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
		myline_1   : setPreferredSize( cc.size( width-30, lineheight ) )
		myline_1   : setPosition( width/2 , count*LabHeight-(i-1)*LabHeight-28 )
		myNode: addChild(myline_1)
	end

  	if count <= 10 then
  		myNode : setPosition( 0, ScrollHeigh - count*LabHeight +47 )
	  	di2kuanbg : addChild( myNode,3 )
	else
	  local mySize        = cc.size(width-20,346) 
	  local My_Height     = count*LabHeight
	  local viewSize      = cc.size( mySize.width, mySize.height)
	  local containerSize = cc.size( mySize.width, My_Height)
	  local ScrollView    = cc.ScrollView : create()
	  ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
	  ScrollView  : setViewSize(viewSize)
	  ScrollView  : setAnchorPoint( 0,0 )
	  ScrollView  : setContentSize(containerSize)
	  ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
	  ScrollView  : setPosition( 0,71 )
	  ScrollView  : setBounceable(true)
	  ScrollView  : setTouchEnabled(true)
	  ScrollView  : setDelegate()
	  di2kuanbg : addChild( ScrollView,5 )

	  ScrollView  : addChild( myNode,6 ) 
	  myNode : setPosition( 0, -8 )
	  
	  local barView = require("mod.general.ScrollBar")(ScrollView)
	  barView : setPosOff(cc.p(11,0))
	end
    
end

function DemonsView._getTimeStr( self,_time)
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
    if tostring(hour) == "00" then 
    	time = tostring(min)..":"..second
    else
    	time = tostring(hour)..":"..tostring(min)..":"..second
    end
    return time
end

function DemonsView.BeginFight( self )
	if not self.lefTimes and self.lefTimes <= 0 then
		self.toFight = true
		self : REQ_THOUSAND_REQUEST_BUY()
		return
	end
	local pro   = self.currultPro
	local count = self.mySkillState[pro][6]
	local skill = {}
	if count == 0 then 
		self : REQ_THOUSAND_WAR_BEGIN( pro, 0, 0 )
	else
		local num = 0
		for i=1,NUM_SKILL do
			if self.mySkillState[pro][i] ~= false then 
				num = num + 1
				skill[num] = Tag_Skill[pro][i]
			end
		end
		self : REQ_THOUSAND_WAR_BEGIN( pro, count, skill )
	end
end

function DemonsView.delayCallFun( self )
    local function nFun()
        print("nFun-----------------")
        if self.m_showLayer~=nil then
            self.m_showLayer:removeFromParent(true)
            self.m_showLayer=nil
        end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.m_showLayer:runAction(cc.Sequence:create(delay,func))
end

function DemonsView.ShowGoods( self )
	if self.m_showLayer~=nil then return end

	local base1Size = cc.size( 531, 382 )
	local function onTouchBegan(touch) 
		print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-base1Size.width/2,self.m_winSize.height/2-base1Size.height/2,
        base1Size.width,base1Size.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
          	return true
        end
        self:delayCallFun()

        return true
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_showLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_showLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_showLayer)

    cc.Director:getInstance():getRunningScene():addChild(self.m_showLayer,999)

    local myNode 	 = cc.Node:create()
    myNode 		 	 : setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.m_showLayer : addChild(myNode)

    local dins = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
    dins 	: setPreferredSize( base1Size )
    myNode 	: addChild( dins,-2 )

    local base1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" )
    base1 : setPreferredSize( cc.size(510,328) )
    base1 : setPosition(0,-17)
    myNode : addChild( base1 )

    local tipup = cc.Sprite : createWithSpriteFrameName( "general_tips_up.png" )
    tipup  : setPosition( -135, base1Size.height/2-25 )
    myNode : addChild( tipup )

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(130,base1Size.height/2-25)
    titleSpr:setRotation(180)
    myNode:addChild(titleSpr,9)

    local title = _G.Util : createBorderLabel( "奖励预览", FONTSIZE+4,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
    title : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    title : setPosition( 0, base1Size.height/2-25 )
    myNode : addChild( title )

    -- local function myclose( obj, touchEvent )
    -- 	if touchEvent == ccui.TouchEventType.ended then
    -- 		self.m_showLayer : removeFromParent(true)
    -- 		self.m_showLayer = nil
    -- 	end
    -- end

    -- local close = gc.CButton : create()
    -- close   : loadTextures( "general_close.png" )
    -- close 	: setPosition( base1Size.width/2-12, base1Size.height/2-10 )
    -- close 	: addTouchEventListener( myclose )
    -- myNode  : addChild( close, 3 )

    local node1 = cc.Node : create()
    local ScrollHeigh = 0
    local countHeight = 64

    local Jifen = _G.Cfg.thousand_jifen
    local count = #Jifen
    for i=1,count do

		print( "开始循环创建：", i )
		local m_lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
		-- local m_lineSprSize = m_lineSpr : getContentSize()
		m_lineSpr   : setPreferredSize( cc.size( 495, 2 ) )
		m_lineSpr   : setPosition( base1Size.width/2-11 , ScrollHeigh - (i-1)*countHeight - countHeight-5 )
		node1       : addChild(m_lineSpr)
		
		local width  = 30
		local height = ScrollHeigh - (i-1)*countHeight - 25 
		local lab_1 = _G.Util : createLabel( "评价：", FONTSIZE )
		lab_1  : setAnchorPoint( 0, 0.5 )
		-- lab_1  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
		lab_1  : setPosition( width, height )
		node1  : addChild( lab_1 )
		width  = width + lab_1 : getContentSize().width

		local lab_2 = _G.Util : createLabel( Jifen[#Jifen-i+1].assess, FONTSIZE + 2 )
		lab_2  : setAnchorPoint( 0, 0.5 )
		lab_2  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GREEN ) )
		lab_2  : setPosition( width, height )
		node1 : addChild( lab_2 )
		width  = width + lab_2 : getContentSize().width 

		local lab_3 = _G.Util : createLabel( "（伤害量：", FONTSIZE  )
		lab_3  : setAnchorPoint( 0, 0.5 )
		-- lab_3  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
		lab_3  : setPosition( width, height )
		node1 : addChild( lab_3 )
		width  = width + lab_3 : getContentSize().width 

		local lab_4 = _G.Util : createLabel( string.format("%d%s%d", Jifen[#Jifen-i+1].l_rank, "-", Jifen[#Jifen-i+1].t_rank ), FONTSIZE-2 )
		lab_4  : setAnchorPoint( 0, 0.5 )
		-- lab_4  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
		lab_4  : setPosition( width, height )
		node1 : addChild( lab_4 )
		width  = width + lab_4 : getContentSize().width 

		local lab_5 = _G.Util : createLabel( "）", FONTSIZE  )
		lab_5  : setAnchorPoint( 0, 0.5 )
		-- lab_5  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
		lab_5  : setPosition( width, height )
		node1 : addChild( lab_5 )

		width = 30
		local lab_6 = _G.Util : createLabel( "奖励：", FONTSIZE )
		lab_6  : setAnchorPoint( 0, 0.5 )
		-- lab_6  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
		lab_6  : setPosition( width, height - 25 )
		node1  : addChild( lab_6 )
		width  = width + lab_6 : getContentSize().width

		local goods = _G.Cfg.goods[Jifen[#Jifen-i+1].reward[1][1]]
		local lab_7 = _G.Util : createLabel( string.format("%s%s%d",goods.name, "*", Jifen[#Jifen-i+1].reward[1][2] ), FONTSIZE )
		lab_7  : setAnchorPoint( 0, 0.5 )
		-- lab_7  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
		lab_7  : setPosition( width, height -25)
		node1 : addChild( lab_7 )
    end

    if count >= 5 then
    	local mySize        = cc.size(505,318) 
	  	local My_Height     = count*countHeight

	  	local viewSize      = cc.size( mySize.width, mySize.height)
	  	local containerSize = cc.size( mySize.width, My_Height)
	  	local ScrollView    = cc.ScrollView : create()
	  	ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
	  	ScrollView  : setViewSize(viewSize)
	  	ScrollView  : setAnchorPoint( 0,0 )
	  	ScrollView  : setContentSize(containerSize)
	  	ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
	  	ScrollView  : setPosition( 0,5 )
	  	ScrollView  : setTouchEnabled(true)
	  	base1 : addChild( ScrollView,5 )

	  	ScrollView  : addChild( node1,3 ) 
	  		
	  	node1 : setPosition( 0, My_Height + 8 )

	  	local barView = require("mod.general.ScrollBar")(ScrollView)
	  	barView : setPosOff(cc.p(-3,0))
    end
end

function DemonsView.REQ_THOUSAND_REQUEST( self )
	local msg = REQ_THOUSAND_REQUEST()
	_G.Network : send( msg )
end

function DemonsView.Net_THOUSAND_REPLY( self, _ackMsg )
	local msg = _ackMsg
	print("	剩余挑战次数	",	msg.times	)
	print("	玩家最高伤害	",	msg.harm	)
	print("	消耗时间值	",	msg.time	)
	print("	当前自己排名	",	msg.self_rank	)
	local rank = msg.self_rank
	if rank == 0 then 
		rank = "(暂无)"
	end
	self.myHarm = msg.harm
	self.myTime = msg.time
	self.lefTimes = msg.times
	self.Lab_Right[4] : setString( msg.times )
	if msg.times <= 0 then
		self.Lab_Right[4] : setColor( COLOR_ORED )
	else
		self.Lab_Right[4] : setColor( COLOR_GRASSGREEN )
	end
	self.Lab_Right[3] : setString( self : _getTimeStr( msg.time ) )
	self.Lab_Right[2] : setString( msg.harm  )
	self.Lab_Right[1] : setString( rank )
	print("	默认选择职业(没有则为0)	",	msg.pro	)
	print("	数量 (循环)  ",  msg.count )
	if msg.pro == 0 or msg.pro == nil then 
		self.currultPro = Tag_Role[2]
	else
		self.currultPro = msg.pro
	end

	-- self : chooseOne( self.currultPro )
	self : addSkillAll( self.currultPro )
	self : resetAll( self.currultPro )
	for i=1,msg.count do
		print("	职业	",	msg.msg_xxx[i].pro	)
		print("	已装备技能数量	",	msg.msg_xxx[i].count	)
		local myPro 	= msg.msg_xxx[i].pro
		local count 	= msg.msg_xxx[i].count
		local msg_skill = msg.msg_xxx[i].msg_skill
		self.mySkillState[myPro][6] = count
		self : cleanSkillState(myPro)
		for i2=1,count do
			print("	技能ID	",	msg.msg_xxx[i].msg_skill[i2].skill_id	)
			for k=1,NUM_SKILL do
				if Tag_Skill[myPro][k] == msg_skill[i2].skill_id then 
					-- 已装备
					self.mySkillState[myPro][k] = true
					self.FisrtIn[myPro] = true
				end
			end	
		end
	end
	print( "转换再这里 11111" )
	self : ChangeSkillEquip( )
end

function DemonsView.REQ_THOUSAND_REQUEST_BUY( self )
	local msg = REQ_THOUSAND_REQUEST_BUY()
	_G.Network : send( msg )
end

function DemonsView.Net_REPLY_BUY( self, _ackMsg )
	local msg = _ackMsg
	self : messageBox( _ackMsg )
end

function DemonsView.REQ_THOUSAND_BUY( self )
	local msg = REQ_THOUSAND_BUY()
	_G.Network : send( msg )
end

function DemonsView.Net_BUY_SUCCESS( self, times )
	print( "购买成功" )
	self.Lab_Right[4] : setString( times )
	self.lefTimes = times
	self.Lab_Right[4] : setColor( COLOR_GRASSGREEN )
	if self.toFight then
		self : BeginFight()
	end
end

function DemonsView.REQ_THOUSAND_WAR_BEGIN( self, pro, count, msg_skill )
	local msg = REQ_THOUSAND_WAR_BEGIN()
	msg : setArgs( pro, count, msg_skill )
	_G.Network : send( msg )
end

function DemonsView.Net_WAR_REPLY( self, _ackMsg )
	local msg = _ackMsg
	print( "职业pro = 	", msg.pro )
	print( "数量 	 	", msg.count )
	for i=1,msg.count do
		print( "技能ID :", msg.msg_skill[i].skill_id )
	end
	
    -- CONST_THOUSAND_MAP
    local id  = _G.Const.CONST_THOUSAND_MAP
    self : REQ_COPY_NEW_CREAT( id )
end

function DemonsView.REQ_THOUSAND_REQUEST_RANK( self )
	local msg = REQ_THOUSAND_REQUEST_RANK()
	_G.Network : send( msg )
end

function DemonsView.Net_REPLY_RANK( self, _ackMsg )
	local msg = _ackMsg
	local rank = msg.self_rank
	if msg.self_rank == 0 then 
		rank = "（暂无）"
	end
	self.Lab_Right[1] : setString( rank )
	print( "排名：	", msg.self_rank  )
	print( "数量：	", msg.count )
	for i=1,msg.count do
		print("排名：	", msg.msg_rank[i].rank)
		print("玩家ID：	", msg.msg_rank[i].uid)
		print("玩家名字：	", msg.msg_rank[i].name)
		print("伤害值：	", msg.msg_rank[i].harm)
		print("消耗时间：	", msg.msg_rank[i].time)
	end
	self : createRankView( msg )
	-- self : createRanking( 2, msg )
end

function DemonsView.REQ_COPY_NEW_CREAT( self, id, key )
	local msg = REQ_COPY_NEW_CREAT()
	msg : setArgs( id, key )
	_G.Network : send( msg )
end

function DemonsView.Net_COPY_THROUGH( self, key )
	print( "key = ", key )
end

function DemonsView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print("   按下  ", tag)
		if tag == Tag_NoTouch then 
			NoTouch = false
		end
	elseif touchEvent == ccui.TouchEventType.moved then
		print("   移动  ", tag)
		if tag == Tag_NoTouch then 
			NoTouch = true
		end
	elseif touchEvent == ccui.TouchEventType.ended then
  		print("   抬起  ", tag)
  		if Tag_Skill[self.currultPro][1] <= tag and Tag_Skill[self.currultPro][5] then
  			self : event_Btn_Skill(tag)
  		elseif tag == Tag_Btn_Goods then
  			self : ShowGoods()
  		elseif tag == Tag_Btn_Fight then 
  			self : BeginFight()
  		elseif tag == Tag_Btn_Rank then 
  			self : REQ_THOUSAND_REQUEST_RANK()
  		elseif tag == Tag_Btn_Explain then 
  			local explainView  = require("mod.general.ExplainView")()
            local explainLayer = explainView : create(40216)

            if self.m_guide_wait_touch then
				self.m_guide_wait_touch=nil
				_G.GGuideManager:removeCurGuideNode()

				local msg=REQ_THOUSAND_TASK_FINISH()
				_G.Network:send(msg)
			end
  		elseif tag == Tag_Btn_Add then 
  			self : REQ_THOUSAND_REQUEST_BUY()
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ", tag)
  	end
end

return DemonsView