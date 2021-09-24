local FeatherView = classGc(view, function(self, _data1,_data2)
	self.m_mediator 	= require("mod.feather.FeatherMediator")() 
	self.m_mediator 	: setView(self) 

	self.m_spineResArray  = {}
	self.User        	= _data1
	self.isShengjie  	= _data2
	self.currentTypeId 	= 44105
	self.RideId			= 0
	self.myData			= {}
	self.istrue 		= false
end)

local m_winSize  	= cc.Director:getInstance() : getWinSize()
local m_viewSize 	= cc.size( 828, 492 )

local FONTSIZE 			= 20
local FeatherList 		= _G.Cfg.feather
local FeatherDes  		= _G.Cfg.feather_des
local FeatherQua  		= _G.Cfg.feather_quality
local Tag_Btn_Jihuo		= 1001
local Tag_Btn_Ride 		= 1002
local Tag_Btn_Up 		= 1003
local Tag_Btn_ShengJi 	= 2001
local Tag_Btn_AutoPei	= 2002 
local Tag_Btn_shengjie	= 2003 

local color7 = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GREEN )

function FeatherView.create( self )
	self.m_settingView = require( "mod.general.NormalView" )()
	self.m_rootLayer   = self.m_settingView : create()
	self.m_settingView : setTitle( "神 羽" )
	self.m_settingView : showSecondBg()

	local tempScene=cc.Scene:create()
  	tempScene:addChild(self.m_rootLayer)

	self:init()

	return tempScene
end

function FeatherView.init( self )

	local function closeFunSetting()
		self : closeWindow()
	end
  	self.m_settingView : addCloseFun(closeFunSetting)

  	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( cc.p( m_winSize.width/2 , m_winSize.height/2-20 ) )
	self.m_rootLayer 	: addChild( self.mainContainer )

	local Spr_RigView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double.png" )
  	Spr_RigView : setContentSize( cc.size( 714, m_viewSize.height-20 ) )
  	Spr_RigView : setPosition( 58 , -20 )
   	self.mainContainer	: addChild( Spr_RigView)

	self.myFeatherNode = cc.Node:create()
	self.mainContainer:addChild(self.myFeatherNode, 5)

	self : createLftView()
	self : createMidView()
	self : createRghView()

	self : REQ_FEATHER_REQUEST( (self.User or 0) )

	-- if self.User==nil then
	-- 	local guideId=_G.GGuideManager:getCurGuideId()
	-- 	if guideId==_G.Const.CONST_NEW_GUIDE_SYS_MOUNT then
	-- 		self.m_hasGuide=true
	-- 		local closeBtn=self.m_settingView:getCloseBtn()
	-- 		_G.GGuideManager:initGuideView(self.m_rootLayer)
	-- 		_G.GGuideManager:registGuideData(1,self.Btn_Jihuo)
	-- 		_G.GGuideManager:registGuideData(2,self.Btn_Ride)
	-- 		_G.GGuideManager:registGuideData(4,closeBtn)
	-- 		self.m_guide_ride_init=true
	-- 		self.m_guide_init_skillbtn=true
	-- 		_G.Util:playAudioEffect("sys_mount")
	-- 	elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_MOUNT_LEVEL then
	-- 		self.m_hasGuide=true
	-- 		local closeBtn=self.m_settingView:getCloseBtn()
	-- 		_G.GGuideManager:initGuideView(self.m_rootLayer)
	-- 		_G.GGuideManager:registGuideData(1,self.Btn_Peiyang)
	-- 		_G.GGuideManager:registGuideData(2,closeBtn)
	-- 		_G.GGuideManager:runNextStep()
	-- 		self.m_guide_level=3
	-- 	end
	-- end
	-- if self.m_hasGuide then
	-- 	local command=CGuideNoticHide()
 --      	controller:sendCommand(command)
	-- end

	local signArray=_G.GOpenProxy:getSysSignArray()
	if signArray[_G.Const.CONST_FUNC_OPEN_FEATHER] then
        _G.GOpenProxy:delSysSign(_G.Const.CONST_FUNC_OPEN_FEATHER)
    end
end

function FeatherView.createLftView( self )
	local Spr_LefView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_login_dawaikuan.png" )
  	Spr_LefView : setContentSize( cc.size( 110, m_viewSize.height-20 ) )
  	Spr_LefView : setPosition( -360 , -20 )
   	self.mainContainer	: addChild( Spr_LefView,1)

   	local Wid_LefView = Spr_LefView : getContentSize().width
   	local Hei_LefView = Spr_LefView : getContentSize().height
   	print( "Wid_LefView = ", Wid_LefView, Hei_LefView )

   	local count			= #FeatherList
   	local ScrollHeigh 	= (m_viewSize.height -26)/4
  	local viewSize 		= cc.size( 110, 4*ScrollHeigh )
   	local containerSize = cc.size( 110, count*ScrollHeigh)
   	print( "viewSize.height-containerSize.height = ", viewSize.height-containerSize.height )
  	self.ScrollView  	= cc.ScrollView : create()
  	self.ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
  	self.ScrollView  : setViewSize(viewSize)
  	self.ScrollView  : setContentSize(containerSize)
  	self.ScrollView  : setContentOffset( cc.p(0, 0))
  	self.ScrollView  : setPosition( 0, 2 )
  	self.ScrollView  : setTouchEnabled(true)
  	self.ScrollView  : setDelegate()
  	Spr_LefView : addChild( self.ScrollView)

  	local barView=require("mod.general.ScrollBar")(self.ScrollView)
  	barView:setPosOff(cc.p(-7,0))

  	local function ButtonCallBack(  obj, eventType )
  		local tag 		= obj : getTag()
  		local Position  = obj : getWorldPosition()
  		print( "y = ", Position.y )
      	if Position.y > 510 or Position.y < 55 or self.currentTypeId == tag then 
         	return 
      	end
  		self : touchEventCallBack( obj, eventType )
  	end

  	self.Btn_Mount    = {}
  	self.headIconSpr  = {}
  	self.openLabelSpr = {}
  	self.Table 		  = {}
  	self.nameLabel	  = {}
  	for i=1,count do
  		self.Table[FeatherList[i].head_id] = i
	    local mountBtnRes = "general_tubiaokuan.png"
	    tag = i + 100
	    self.Btn_Mount[i] = ccui.Button:create()
	    self.Btn_Mount[i] : loadTextures( mountBtnRes, mountBtnRes, mountBtnRes, ccui.TextureResType.plistType)
	    self.Btn_Mount[i] : setPosition( viewSize.width/2, count*ScrollHeigh-ScrollHeigh*(i-1)-ScrollHeigh/2+10 ) --121*length-105*i-55-18*x
	    self.Btn_Mount[i] : addTouchEventListener(ButtonCallBack)
	    self.Btn_Mount[i] : setTag(tag)
	    self.Btn_Mount[i] : setSwallowTouches(false)
	    self.ScrollView:addChild(self.Btn_Mount[i])

	    local FeatherId 	 = FeatherList[i].head_id
	    local m_Color = FeatherDes[i].m_color
	    
	    self.headIconSpr[i] = _G.ImageAsyncManager:createHeadSpr(FeatherId,m_Color)
	    -- local headSize 		= self.headIconSpr[i] : getContentSize()
	    self.headIconSpr[i] : setPosition(79/2,79/2)
	    self.Btn_Mount[i] 	: addChild(self.headIconSpr[i])
	    self.headIconSpr[i] : setGray()

	    local card=FeatherDes[i].id
	    local bagNum = _G.GBagProxy:getGoodsCountById(card)
	    local LabImg = "mount_noopen.png"
	    if bagNum>0 then
	        LabImg = "mount_open.png"
	    end
	    print("_G.GBagProxy:getGoodsCountById",card,bagNum)

	    self.openLabelSpr[i] = cc.Sprite:createWithSpriteFrameName(LabImg)
	    -- self.openLabelSpr[i] : setAnchorPoint( 0.5, 0 )
	    self.openLabelSpr[i] : setPosition(78/2,78/2)
	    self.Btn_Mount[i]  	 : addChild(self.openLabelSpr[i])

	    self.nameLabel[i] = _G.Util : createLabel(FeatherDes[i].name,FONTSIZE-2)
	    self.nameLabel[i]  : setPosition( viewSize.width/2, count*ScrollHeigh-ScrollHeigh*(i-1)-ScrollHeigh+13 )
	    -- self.nameLabel[i]  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	    self.ScrollView : addChild(self.nameLabel[i])
  	end
end

function FeatherView.createMidView( self )
	local function ButtonCallBack( obj, eventType )
  		self : touchEventCallBack( obj, eventType )
  	end

 	local Spr_MidView = cc.Node:create()
  	-- Spr_MidView : setContentSize( cc.size( m_viewSize.width/3+30, m_viewSize.height - 10 ) )
  	Spr_MidView : setPosition( - 145, 0 )
   	self.mainContainer	: addChild( Spr_MidView )

   	local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
	-- attrFryNode:setPosition(Wid_MidView/2,Hei_MidView/2)
	Spr_MidView:addChild(attrFryNode,1000)

   	local sprbg2 = cc.Sprite : create( "ui/bg/feather_bg.jpg" )
   	sprbg2 : setPosition( 0 , 18)
   	Spr_MidView : addChild( sprbg2 ) 

   	local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
   	lineSpr:setPreferredSize(cc.size(280,2))
   	lineSpr:setPosition(0,-175)
   	Spr_MidView : addChild( lineSpr ) 

   	local Spr_Size = sprbg2 : getContentSize()
   	local Wid_MidView = Spr_Size.width
   	local Hei_MidView = Spr_Size.height
   	print( "Wid_MidView = ", Wid_MidView, Hei_MidView )

   	local spr = cc.Sprite : createWithSpriteFrameName( "main_fighting.png" )
   	-- spr : setAnchorPoint( 0, 0.5 )
   	spr : setPosition( 0 , Hei_MidView/2-12 )
   	Spr_MidView : addChild( spr,10 )

   	self.Btn_Jihuo = gc.CButton : create()
   	self.Btn_Jihuo : loadTextures( "general_btn_gold.png")
	self.Btn_Jihuo : setTitleText( "激 活" )
	self.Btn_Jihuo : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Jihuo : setTitleFontSize( FONTSIZE+4 )
	self.Btn_Jihuo : setPosition( -70, -215 )
	self.Btn_Jihuo : setTag( Tag_Btn_Jihuo )
	-- self.Btn_Jihuo : setButtonScale(0.9)
	self.Btn_Jihuo : addTouchEventListener( ButtonCallBack )
	Spr_MidView    : addChild( self.Btn_Jihuo, 1 )
	self.Btn_Jihuo : setVisible( false )

   	self.Btn_Ride  = gc.CButton : create()
   	self.Btn_Ride  : loadTextures( "general_btn_gold.png")
	self.Btn_Ride  : setTitleText( "穿 戴" )
	self.Btn_Ride  : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Ride  : setTitleFontSize( FONTSIZE+4 )
	self.Btn_Ride  : setPosition( -70, -215 )
	self.Btn_Ride  : setTag( Tag_Btn_Ride )
	-- self.Btn_Ride  : setButtonScale(0.9)
	self.Btn_Ride  : addTouchEventListener( ButtonCallBack )
	Spr_MidView    : addChild( self.Btn_Ride )
	self.Btn_Ride  : setVisible( false )

	self.Btn_Up  = gc.CButton : create()
   	self.Btn_Up  : loadTextures( "general_btn_gold.png")
	self.Btn_Up  : setTitleText( "升 阶" )
	self.Btn_Up  : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Up  : setTitleFontSize( FONTSIZE+4 )
	self.Btn_Up  : setPosition( 70, -215 )
	self.Btn_Up  : setTag( Tag_Btn_Up )
	-- self.Btn_Up  : setButtonScale(0.9)
	self.Btn_Up  : setBright(false)
	self.Btn_Up  : setEnabled(false)
	self.Btn_Up  : addTouchEventListener( ButtonCallBack )
	Spr_MidView  : addChild( self.Btn_Up )

	self.shadow = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
	self.shadow : setPosition(0,-130)
  	self.shadow : setScale(1.5)
  	Spr_MidView : addChild(self.shadow)

	self.powerSpriteNum = {}
	print("self.User,self.isShengjie",self.User,self.isShengjie)
	if self.User ~= nil then 
		self : changeBtn_Jihuo( true )
	end

	local attrSize=cc.size(-300,-50)
	self:AttrFryNode(attrSize,self.mainContainer)
end

function FeatherView.changeBtn_Jihuo( self, isVis )
	self.Btn_Jihuo: setVisible( isVis )
	self.Btn_Ride : setVisible( not isVis )
	self.Btn_Up : setBright(not isVis)
	self.Btn_Up : setEnabled(not isVis)
end

function FeatherView.UpLabVisible( self,_istrue)
	self.nowlab:setVisible(_istrue)
	self.addlab_2:setVisible(_istrue)
	self.titleSpr:setVisible(not _istrue)
	self.feaName:setVisible(not _istrue)
end

function FeatherView.createRghView( self )
	local doubleSize =  cc.size( 402, 460 ) 
	local Spr_RghView = cc.Node:create()
  	-- Spr_RghView : setContentSize( doubleSize )
  	Spr_RghView : setPosition( 207, -21 )
   	self.mainContainer	: addChild( Spr_RghView )

   	local Wid_RghView = doubleSize.width
   	local Hei_RghView = doubleSize.height
   	print( "Wid_RghView = ", Wid_RghView, Hei_RghView )

   	local base1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" )
   	base1 : setPreferredSize( doubleSize )
   	-- base1 : setAnchorPoint( 0, 0 )
   	base1 : setPosition( 0, 0 )
   	Spr_RghView : addChild( base1 )

   	self.nowlab = _G.Util : createLabel( "当前属性", FONTSIZE+4 )
   	self.nowlab : setPosition(-190, Hei_RghView/2 - 35 )
   	self.nowlab : setAnchorPoint( 0, 0.5 )
   	self.nowlab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN )  ) 
   	Spr_RghView : addChild( self.nowlab )

   	self.addlab_2 = _G.Util : createLabel( "(成长)", FONTSIZE+4 )
   	self.addlab_2 : setPosition( self.nowlab:getContentSize().width-190, Hei_RghView/2 - 35 )
   	self.addlab_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE )  )
   	self.addlab_2 : setAnchorPoint( 0,0.5 ) 
   	Spr_RghView : addChild( self.addlab_2 )

   	self.titleSpr=cc.Sprite:createWithSpriteFrameName("general_titlebg.png")
   	self.titleSpr:setPosition(0, Hei_RghView/2 - 30)
   	Spr_RghView : addChild( self.titleSpr )

   	self.feaName = _G.Util : createLabel( "", FONTSIZE+4 )
   	self.feaName : setPosition( 0, Hei_RghView/2 - 32 )
   	self.feaName : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD )  )
   	Spr_RghView : addChild( self.feaName )

   	self:UpLabVisible(true)

   	local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	lineSpr : setPreferredSize( cc.size(Wid_RghView-20, 2) )
	lineSpr : setPosition( 0, -20 )
	Spr_RghView:addChild(lineSpr)

   	local Spr_Jianbian = cc.Node:create( )
  	Spr_Jianbian : setPosition( 0, 0 )
   	self.mainContainer  : addChild( Spr_Jianbian, 1 )

   	local Wid_Jianbian = Wid_RghView
   	local Hei_Jianbian = Hei_RghView/2-70
   	local Pos_y = { Hei_Jianbian-30,	Hei_Jianbian-30,	Hei_Jianbian-75,	Hei_Jianbian-75,
   					Hei_Jianbian-120,	Hei_Jianbian-120,	Hei_Jianbian-165, Hei_Jianbian-165 }
   	local Text_lab = { "攻击: ", "气血: ", "破甲: ", "防御: ", "命中: ", "闪避: ", "暴击: ", "抗暴: ", }
   	local prop_img  = {"general_att.png","general_wreck.png","general_hit.png","general_crit_res.png","general_bonus.png",
  "general_hp.png","general_def.png","general_dodge.png","general_crit.png","general_reduc.png"}
   	self.Lab_Att 	  = {}
   	self.Lab_Att_Grow = {}
   	local widthList   = { [0] = Wid_Jianbian/2+30, 45 }
   	local widthList2  = { [0] = 345, 150 }
   	for i=1,8 do
   		width = widthList[i%2]

	   	local lab = _G.Util : createLabel( Text_lab[i], FONTSIZE )
	   	lab : setAnchorPoint( 0, 0.5 )
	   	lab : setPosition( width, Pos_y[i] )
	   	lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	   	Spr_Jianbian : addChild( lab, 1 )
	   	width = lab:getContentSize().width + width + 5

	    infoSpr = cc.Sprite:createWithSpriteFrameName(prop_img[i])
	    infoSpr : setPosition(width-68,Pos_y[i])
	    Spr_Jianbian : addChild(infoSpr)

	   	self.Lab_Att[i] = _G.Util : createLabel( "", FONTSIZE )
	   	self.Lab_Att[i] : setAnchorPoint( 0, 0.5 )
	   	self.Lab_Att[i] : setPosition( width, Pos_y[i] )
	   	self.Lab_Att[i] : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	   	Spr_Jianbian : addChild( self.Lab_Att[i], 1 )

	   	width = widthList2[i%2]
	   	self.Lab_Att_Grow[i] = _G.Util : createLabel( "", FONTSIZE )
	   	self.Lab_Att_Grow[i] : setAnchorPoint( 0, 0.5 )
	   	self.Lab_Att_Grow[i] : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	   	self.Lab_Att_Grow[i] : setPosition( width-5, Pos_y[i] )
	   	Spr_Jianbian : addChild( self.Lab_Att_Grow[i], 1 )
   	end

   	self.Widget = {}
   	for i=1,3 do
   		self.Widget[i] = cc.Node : create( )
		self.Widget[i] : setContentSize( cc.size( Wid_RghView -10, Hei_RghView/2 -20  ) )
		self.Widget[i] : setAnchorPoint( 0, 1 )
		self.Widget[i] : setPosition( 12, -7 )
		-- self.Widget[i] : setSwallowTouches( false )
		self.mainContainer    : addChild( self.Widget[i], 0)
   	end

 --   	self.Spr_Tanhao = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tanhao.png" )
	-- self.Spr_Tanhao : setAnchorPoint( 0, 1)
	-- self.Spr_Tanhao : setPosition( 35, 145 )
 --   	self.Widget[2]  : addChild( self.Spr_Tanhao, 1 )

   	self.Lab_GetNeed = _G.Util:createLabel( "", FONTSIZE )
  	self.Lab_GetNeed : setAnchorPoint( 0, 1 )
	self.Lab_GetNeed : setDimensions(self.Widget[2]:getContentSize().width, 120)
	self.Lab_GetNeed : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.Lab_GetNeed : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.Lab_GetNeed : setPosition( 80, 120 )
	self.Widget[2] : addChild( self.Lab_GetNeed )

	self.Widget[1] : setVisible( false )
	self.Widget[3] : setVisible( false )
	self.isIn = false

	local Spr_Exp2  = cc.Sprite : createWithSpriteFrameName( "main_exp_2.png" )
	-- Spr_Exp2  : setAnchorPoint( 0, 1 )
	Spr_Exp2  : setPosition( Wid_RghView/2, 115 )
	self.Widget[1] : addChild( Spr_Exp2 )

	self.Spr_Exp1  = ccui.LoadingBar:create()
    self.Spr_Exp1  : loadTexture("main_exp.png",ccui.TextureResType.plistType)
	self.Spr_Exp1  : setAnchorPoint( 0, 0 )
	self.Spr_Exp1  : setPosition( 0.5, 1 )
	Spr_Exp2  	   : addChild( self.Spr_Exp1 )
	self.Spr_Exp1  : setPercent( 100 )  -- 缩放

	self.Lab_Exp  = _G.Util : createLabel( "", FONTSIZE )
	self.Lab_Exp  : setPosition( Spr_Exp2 : getContentSize().width/2, 8 )
	-- self.Lab_Exp  : setColor( color1 )
	Spr_Exp2 : addChild( self.Lab_Exp ) 

	local lab = _G.Util : createLabel( "翅膀等级：", FONTSIZE)
	lab : setPosition( 70, 150 )
	lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.Widget[1] : addChild( lab )

	self.levelLab = _G.Util : createLabel( "", FONTSIZE )
	self.levelLab : setAnchorPoint( 0, 0.5 )
	self.levelLab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	self.levelLab : setPosition( 130, 150 )
	self.Widget[1]  : addChild( self.levelLab )

	-- local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	-- local lineH= spr:getContentSize().height
	-- spr : setPreferredSize( cc.size(Wid_RghView-10, lineH) )
	-- spr : setPosition( Wid_RghView/2, 180 )
	-- self.Widget[1] : addChild( spr )

	-- local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	-- spr : setPreferredSize( cc.size(Wid_RghView-10, lineH) )
	-- spr : setPosition( Wid_RghView/2, 100 )
	-- self.Widget[1] : addChild( spr )

	local sjxhname=_G.Cfg.goods[44000].name
	self.consumelab = _G.Util : createLabel( string.format("消耗%s:",sjxhname), FONTSIZE )
	self.consumelab : setPosition( Wid_RghView/2-20, 72 )
	self.consumelab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.Widget[1] : addChild( self.consumelab )

	self.Lab_Cost = _G.Util : createLabel( "", FONTSIZE )
	self.Lab_Cost : setAnchorPoint( 0, 0.5 )
	self.Lab_Cost : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	self.Lab_Cost : setPosition( Wid_RghView/2+30, 72 )
	self.Widget[1]  : addChild( self.Lab_Cost )

	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end 

	self.Lab_Manji = _G.Util : createLabel( "翅膀已满级", FONTSIZE+4)
	self.Lab_Manji : setPosition( Wid_RghView/2, 50 )
	self.Lab_Manji : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
	-- self.Lab_Manji : setVisible( false )
	self.Widget[1] : addChild( self.Lab_Manji,1 )

	self.Btn_Peiyang = gc.CButton : create()
	self.Btn_Peiyang : loadTextures( "general_btn_gold.png")
	self.Btn_Peiyang : setTitleText( "升 级" )
	self.Btn_Peiyang : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Peiyang : setTitleFontSize( FONTSIZE + 4 )
	-- self.Btn_Peiyang : setPosition( 105, 24 )
	self.Btn_Peiyang : setPosition( Wid_RghView/2, 28 )
	self.Btn_Peiyang : setTag( Tag_Btn_ShengJi )
	self.Btn_Peiyang : setSwallowTouches(false)
	-- self.Btn_Peiyang : setButtonScale(0.9)
	self.Btn_Peiyang : addTouchEventListener( ButtonCallBack )
	self.Widget[1]   : addChild( self.Btn_Peiyang )

	self : createListener()
	
	local tips = _G.Util : createLabel( "长按可快速升级", FONTSIZE-2 )
	tips : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	tips : setPosition( Wid_RghView/2, -12 )
	self.Widget[1] : addChild( tips )
	self.tips=tips

	-- local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	-- local lineH= spr:getContentSize().height
	-- spr : setPreferredSize( cc.size(Wid_RghView-10, lineH) )
	-- spr : setPosition( Wid_RghView/2, 190 )
	-- self.Widget[3] : addChild( spr )

	-- local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	-- spr : setPreferredSize( cc.size(Wid_RghView-10, lineH) )
	-- spr : setPosition( Wid_RghView/2, 75 )
	-- self.Widget[3] : addChild( spr )

	self.skillName = _G.Util : createLabel( "", FONTSIZE )
	self.skillName : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.skillName : setAnchorPoint(cc.p(0,0.5))
	self.skillName : setPosition( 10, 145 )
	self.Widget[3] : addChild( self.skillName )

	self.skillText = _G.Util : createLabel( "", FONTSIZE-2 )
	self.skillText : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	self.skillText : setAnchorPoint(cc.p(0,0.5))
	self.skillText : setDimensions(Wid_RghView-30, 90)
	self.skillText : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.skillText : setPosition( 10, 82 )
	self.Widget[3] : addChild( self.skillText )

	self.skillUp = _G.Util : createLabel("", FONTSIZE )
	self.skillUp : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.skillUp : setAnchorPoint(cc.p(0,0.5))
	self.skillUp : setPosition( 90, 50 )
	self.Widget[3] : addChild( self.skillUp )

	self.skillNum = _G.Util : createLabel( "", FONTSIZE )
	self.skillNum : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	self.skillNum : setAnchorPoint(cc.p(0,0.5))
	self.Widget[3] : addChild( self.skillNum )

	self.Btn_shengjie = gc.CButton : create()
	self.Btn_shengjie : loadTextures( "general_btn_gold.png")
	self.Btn_shengjie : setTitleText( "升 阶" )
	self.Btn_shengjie : setTitleFontName( _G.FontName.Heiti )
	self.Btn_shengjie : setTitleFontSize( FONTSIZE + 4 )
	self.Btn_shengjie : setPosition( Wid_RghView/2, 5 )
	self.Btn_shengjie : setTag( Tag_Btn_shengjie )
	self.Btn_shengjie : setSwallowTouches(false)
	-- self.Btn_shengjie : setButtonScale(0.9)
	self.Btn_shengjie : addTouchEventListener( ButtonCallBack )
	self.Widget[3]   : addChild( self.Btn_shengjie )

	self.Lab_Manjie = _G.Util : createLabel( "翅膀已满阶", FONTSIZE+4 )
	self.Lab_Manjie : setPosition( Wid_RghView/2, 29 )
	self.Lab_Manjie : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
	self.Lab_Manjie : setVisible( false )
	self.Widget[3] : addChild( self.Lab_Manjie,1 )

	if self.User ~= nil then 
		self.Btn_Peiyang : setVisible( false )
		self.tips : setVisible( false )
		self.Widget[1]   : setVisible( true )
		self.Widget[2]	 : setVisible( false )
		self.Widget[3]   : setVisible( false )
		self.isIn = false
	end
end

function FeatherView.UpView( self,_num )
	print("UpView===>>>",_num)
	local Text_featherData = { "strong_att", "hp", "defend_down", "strong_def", "hit", "dod", "crit", "crit_res" } 
	local Text_add=0
	if self.myData[_num]==nil then self.istrue=false return end
	if self.istrue==true then
		print("升阶界面")
		self:UpLabVisible(false)
		self.feaName:setString(string.format("%s+%d",FeatherDes[_num].name,self.quality))

		self.Btn_Up : setTitleText( "升 级" )
		for i=1,8 do
			if FeatherQua[self.currentTypeId][self.quality+1]~=nil then
				local attrNum= FeatherQua[self.currentTypeId][self.quality]~=nil and FeatherQua[self.currentTypeId][self.quality].attr[Text_featherData[i]] or 0
				Text_add = FeatherQua[self.currentTypeId][self.quality+1].attr[Text_featherData[i]]-attrNum
			end
			self.Lab_Att_Grow[i] : setString( string.format("%s+%d%s","(", Text_add, ")" ) )
			local addAttr= FeatherQua[self.currentTypeId][self.quality]~=nil and FeatherQua[self.currentTypeId][self.quality].attr[Text_featherData[i]] or 0
			self.Lab_Att[i] : setString( addAttr )
		end
		self.Widget[1]   : setVisible( false )
		self.Widget[2]	 : setVisible( false )
		self.Widget[3]   : setVisible( true )
	else
		print("升级界面")
		self:UpLabVisible(true)
		self.Btn_Up : setTitleText( "升 阶" )
		for i=1,8 do
			if FeatherList[_num][self.lv+1]~=nil then
				local attrNum= FeatherList[_num][self.lv]~=nil and FeatherList[_num][self.lv].attr[Text_featherData[i]] or 0
				Text_add = FeatherList[_num][self.lv+1].attr[Text_featherData[i]] - attrNum
			end
			local addAttr= FeatherQua[self.currentTypeId][self.quality]~=nil and FeatherQua[self.currentTypeId][self.quality].attr[Text_featherData[i]] or 0
			self.Lab_Att[i] : setString( FeatherList[_num][lv].attr[Text_featherData[i]]+addAttr )
			self.Lab_Att_Grow[i] : setString( string.format("%s%d%s","(", Text_add, ")" ) )
		end
		self.Widget[1]   : setVisible( true )
		self.Widget[2]	 : setVisible( false )
		self.Widget[3]   : setVisible( false )
	end
end

function FeatherView.createListener( self )
	if self.listener then  return end
	print( "FeatherView.createListener" )
	local posxPeiyang  = self.Btn_Peiyang : getWorldPosition().x
	local posyPeiyang  = self.Btn_Peiyang : getWorldPosition().y
	local sizeXPeiyang = self.Btn_Peiyang : getContentSize().width/2
	local sizeYPeiyang = self.Btn_Peiyang : getContentSize().height/2

	local node = nil
	if not self.listenerNode then
		node = cc.Node : create()
		cc.Director:getInstance():getRunningScene():addChild( node,20 )
		self.listenerNode = node
	else
		node = self.listenerNode
	end
	local function onTouchBegan( touch, event )

		local touchPoint=touch:getStartLocation()
		local point     =node:convertToNodeSpaceAR(touchPoint)
	    -- print("onTouchBegan~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",touch:getLocation().x,posxPeiyang,touchPoint.x,point.x)
	    if (point.x - posxPeiyang - 5 ) > sizeXPeiyang or (posxPeiyang - point.x - 5 ) > sizeXPeiyang then
	      return false
	    end
	    if (point.y - posyPeiyang - 5 ) > sizeYPeiyang or (posyPeiyang - point.y - 5 ) > sizeYPeiyang then
	      return false
	    end
	   	print("onTouchBegan~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",posxPeiyang,point.x)

	    self : Peiyang()
	    return true
  	end

  	local function onTouchMoved( touch, event )
  		local touchPoint=touch:getLocation()
		local point     =node:convertToNodeSpaceAR(touchPoint)
	    print( "move touch:getLocation().y = ", touch:getLocation().y )
	    if (point.x - posxPeiyang ) > sizeXPeiyang or (posxPeiyang - point.x ) > sizeXPeiyang then
	    	self : releaseScheduler()
	    	return
	    end
	    if (point.y - posyPeiyang ) > sizeYPeiyang  or (posyPeiyang - point.y ) > sizeYPeiyang then
	    	self : releaseScheduler()
	    	return
	    end
  	end

  	local function onTouchEnded( touch, event )
    	-- print( "End touch:getLocation().y = ", touch:getLocation().y  )
    	self : releasePeiyang(true)
  	end

  	local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
  	listener       : registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
  	listener       : registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
  	listener       : registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
  	self.listener  = listener

  	local eventDispatcher = node : getEventDispatcher() -- 得到事件派发器
  	eventDispatcher : addEventListenerWithSceneGraphPriority(listener, self.Btn_Peiyang) 

end

function FeatherView.removeListener( self )
	if self.listener then
		print( "FeatherView.removeListener" )
		self.listenerNode : getEventDispatcher() : removeEventListener(self.listener)
		self.listener = nil
	end
end

function FeatherView.closeWindow( self )
	print( "开始关闭" )
	if self.Scheduler ~= nil then 
		_G.Scheduler : unschedule( self.Scheduler ) 
		self.Scheduler = nil
	end
	if self.Scheduler2 ~= nil then 
		_G.Scheduler : unschedule( self.Scheduler2 ) 
		self.Scheduler2 = nil
	end
	if self.Scheduler3 ~= nil then 
		_G.Scheduler : unschedule( self.Scheduler3 ) 
		self.Scheduler3 = nil
	end
	if self.m_rootLayer == nil then return end
	self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self:destroy()
end

function FeatherView.createSpineNum( self, num )
	print( "进入翅膀spine创建" )
  	if self.spine ~= nil then
    	self.spine : removeFromParent(true)
    	self.spine = nil
  	end

  	local roleSkin  = self.m_rolePro+10000
  	local SpineId 	= _G.Cfg.feather[num].skin_id
  	local nScale 	= self.m_skeleton and self.m_skeleton:getScale() or 0.55
  	print( "nScale = ", nScale )

  	local szSpine = "spine/"..SpineId
  	self.spine 	= _G.SpineManager.createSpine(szSpine,nScale) -- _mountId

  	if self.spine == nil then 
  		szSpine = "spine/44105"
    	self.spine  =_G.SpineManager.createSpine(szSpine,nScale)
  	end
  	self.m_spineResArray[szSpine]=true

  	self.spine : setAnimation(0,string.format("idle_%d",roleSkin),true)
  	self.myFeatherNode : addChild(self.spine)

  	self.myFeatherNode : setPosition( -145, -130 )
end

function FeatherView.createPowerNum( self, _powerNum )
	print( " ---改变战力值--- " )
	if self.tempLab~=nil then
		self.tempLab:setString(string.format("战力:%d",_powerNum))
		return
	end

	self.tempLab=_G.Util:createBorderLabel(string.format("战力: %d",_powerNum),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    -- self.tempLab:setAnchorPoint(cc.p(0,0.5))
    self.tempLab:setPosition(-145,180)
    self.mainContainer : addChild(self.tempLab)

  	-- local testStr = tostring(_powerNum)
  	-- local x 		= string.len(testStr)+1
  	-- for i=1,string.len(testStr) do
   --  	local numStr = string.sub(testStr,i,i)
   --  	if self.powerSpriteNum[i] == nil then
   --    		local spritePic = string.format("general_powerno_%d.png",numStr)
   --    		local numSprite = cc.Sprite:createWithSpriteFrameName(spritePic)
   --    		numSprite:setPosition(cc.p( -150 + i*15,m_viewSize.height/2 - 30))
   --    		self.mainContainer:addChild(numSprite, 10)

   --    		local numItem = {}
   --    		numItem.numIndex = numStr
   --    		numItem.spriteIndex = numSprite
   --    		self.powerSpriteNum[i]=numItem
   --  	elseif self.powerSpriteNum[i].numIndex~=curNum then
   --    		self.powerSpriteNum[i].spriteIndex:setSpriteFrame(string.format("general_powerno_%d.png",numStr))
   --    		self.powerSpriteNum[i].spriteIndex:setVisible(true)
   --  	end
  	-- end
  	-- for i=x,#self.powerSpriteNum do
   --  	self.powerSpriteNum[i].spriteIndex:setVisible(false)
  	-- end
end

function FeatherView.ClickLftBtn( self, _num )
	print( "翅膀左侧图标按钮被按下" )
	if self.currentTypeId ~= FeatherList[_num].head_id then 
		self.currentTypeId = FeatherList[_num].head_id
		print( "当前self.currentTypeId = ", self.currentTypeId, _num )
		-- self : createScelectEquipEffect( self.Btn_Mount[_num], true, _num )
		self : changeRghView( _num )
		self : createSpineNum( _num )
		self : changeMidView( _num ) 
		
		self:UpView(_num)
	end
end

function FeatherView.changeLftView( self, num )
	self.headIconSpr[num]  : setDefault()
	self.openLabelSpr[num] : setVisible( false )
end

function FeatherView.changeRghView( self, _num )
	local Text_featherData = { "strong_att", "hp", "defend_down", "strong_def", "hit", "dod", "crit", "crit_res" }

	if self.myData[_num] == nil then 
		print( "未激活" )
		self:UpLabVisible(true)
		if self.isShengjie~=nil then
			local command = CErrorBoxCommand("没有已激活坐骑，不能升阶")
   	        controller : sendCommand( command )
   	        self.isShengjie=nil
		end
		self.Widget[1] : setVisible( false )
		self.Widget[2] : setVisible( true )
		self.Widget[3] : setVisible( false )
		self:removeListener()
		self : changeBtn_Jihuo( true )
		-- self.Spr_Tanhao : setVisible( true )
		self.Lab_GetNeed : setString( FeatherDes[_num].des1 )
		for i=1,8 do
			print( "未激活，设置成长、战斗力",FeatherList[_num][0])
			local Text_add = FeatherList[_num][1].attr[Text_featherData[i]] - FeatherList[_num][0].attr[Text_featherData[i]]
			self.Lab_Att_Grow[i] : setString( string.format("%s%d%s","(", Text_add, ")" ) )
			self.Lab_Att[i] : setString( FeatherList[_num][0].attr[Text_featherData[i]] )
		end
	else 
		print( "已激活",self.isShengjie )
		
		self : manji(false)
		self : changeBtn_Jihuo( false )
		quality = self.myData[_num].quality
		lv  = self.myData[_num].lv
		exp = self.myData[_num].exp
		self.quality=quality
		self.lv=lv
		print( "_num  quality  lv  exp= ", _num, quality, lv, exp )
		if quality==0 or quality==nil then 
			self.skillName:setString(FeatherQua[self.currentTypeId][1].skillname)
			self.skillText:setString(string.format("        %s",FeatherQua[self.currentTypeId][1].remark))
		else
			self.skillName:setString(FeatherQua[self.currentTypeId][quality].skillname)
			self.skillText:setString(string.format("        %s",FeatherQua[self.currentTypeId][quality].remark))
		end
		
		if FeatherQua[self.currentTypeId][quality+1]==nil then
			self.skillUp:setVisible(false)
			self.Btn_shengjie:setVisible(false)
			self.skillNum:setVisible(false)
			self.Lab_Manjie:setVisible(true)
		else
			self.skillUp:setVisible(true)
			self.Btn_shengjie:setVisible(true)
			self.skillNum:setVisible(true)
			self.Lab_Manjie:setVisible(false)
			local goodsdata=FeatherQua[self.currentTypeId][quality+1].goods_id
			if goodsdata~=nil then
				if goodsdata[1]~=nil then
					local CLName=_G.Cfg.goods[goodsdata[1][1]].name
					self.CLNum=goodsdata[1][2]
					self.skillUp:setString(string.format("消耗%s:",CLName))
				end
			end
		end
		if FeatherList[_num][lv+1]== nil then -- 满级
			print( "已激活,满级, Widget设置" )
			self : manji(true)
			self.Widget[1]  : setVisible( true ) 
			self.Widget[2]  : setVisible( false )
			self.Widget[3] : setVisible( false )
			self:removeListener()
			if self.Scheduler ~= nil then 
				_G.Scheduler : unschedule( self.Scheduler )
				self.schedule = nil
			end
			if self.Scheduler2 ~= nil then 
				_G.Scheduler : unschedule( self.Scheduler2 )
				self.Scheduler2 = nil
			end
			if self.Scheduler3 ~= nil then 
				_G.Scheduler : unschedule( self.Scheduler3 )
				self.Scheduler3 = nil
			end
			self : createPowerNum( self.myData[_num].powerful )
			self : changeWidget( _num, quality, lv, "MAX" )
		else
			print( "已激活,未满级, Widget设置, 星级, 阶数" )
			self : manji(false)
			self.Widget[1]  : setVisible( true ) 
			self.Widget[2]  : setVisible( false )
			self.Widget[3] : setVisible( false )
			self : createListener()
			self : changeBtn_Jihuo( false )
			-- 改变阶级，星级，消耗
			-- self : createJineng( _num )
			self : createPowerNum( self.myData[_num].powerful )
			self : changeWidget( _num, quality, lv, exp )
		end
		for i=1,8 do
			if FeatherList[_num][lv+1] == nil then 
				-- print( "~~已激活,满级，成长设置", i )
				self.Lab_Att_Grow[i] : setString( "(0)" )
			else 
				-- print( "~~已激活,未满级，成长设置", i )
				local Text_add = FeatherList[_num][lv+1].attr[Text_featherData[i]] - FeatherList[_num][lv].attr[Text_featherData[i]]
				self.Lab_Att_Grow[i] : setString( string.format("%s%d%s","(", Text_add, ")" ) )
			end
			-- print( "~~已激活,设置战斗值", i,FeatherQua[self.currentTypeId][quality])
			-- print("FeatherList[_num][lv].attr[Text_featherData[i]]", FeatherList[_num][lv].attr[Text_featherData[i]] )
			local addAttr= FeatherQua[self.currentTypeId][quality]~=nil and FeatherQua[self.currentTypeId][quality].attr[Text_featherData[i]] or 0
			self.Lab_Att[i] : setString( FeatherList[_num][lv].attr[Text_featherData[i]]+addAttr )
		end
		if self.isShengjie~=nil then
			self.isShengjie=nil
			self.istrue = true
			self:UpView(_num)
		end
	end

	if self.User ~= nil then
		self.Btn_Peiyang : setGray()
		self.Btn_Peiyang : setTouchEnabled( false )
		self.Btn_Ride    : setGray()
		self.Btn_Ride 	 : setTouchEnabled( false )
		self.Btn_Jihuo   : setGray()
		self.Btn_Jihuo 	 : setTouchEnabled( false )
		self.Btn_Up : setGray()
		self.Btn_Up : setTouchEnabled( false )
		self.Btn_shengjie : setGray()
		self.Btn_shengjie : setTouchEnabled( false )
		self:removeListener()
	end
end

function FeatherView.manji( self, _isManji )
	self.Btn_Peiyang : setVisible( not _isManji )
	self.Btn_Peiyang : setTouchEnabled( not _isManji )
	self.tips : setVisible( not _isManji )
	self.consumelab : setVisible( not _isManji )
	self.Lab_Cost : setVisible( not _isManji )
	self.Lab_Manji : setVisible( _isManji )
end

function FeatherView.changeWidget( self, num, _quality, _lv, _exp )
	local quality = _quality
	local lv  = _lv
	local exp = _exp
	if quality == nil or _lv == nil  then 
		print( "收到非法数据，quality = ", quality, "lv = ", lv )
		quality = 0
		lv  = 0 
	end

	if self.User ~= nil then
		self.Lab_Cost : setString( "0/0" )
	else
		local text = string.format( "%d/%d", _G.GBagProxy : getGoodsCountById(44000), 1)
		self.Lab_Cost : setString( text )
		if self.CLNum==nil then
			self.skillNum : setString( "" )
		else
			local skillStr = string.format( "%d/%d", _G.GBagProxy : getGoodsCountById(44005), self.CLNum)
			self.skillNum : setString( skillStr )
			if _G.GBagProxy : getGoodsCountById(44005)<self.CLNum then
				self.skillNum : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
			else
				self.skillNum : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
			end
		end
		local width=self.skillUp:getContentSize().width
		self.skillNum : setPosition( 100+width, 50 )
	end
	if _G.GBagProxy : getGoodsCountById(44000)<1 then
		self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	else
		self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	end

	self.levelLab:setString(lv)
	local labWidth = self.Lab_Cost:getContentSize().width
	-- self.spr : setPosition(235+labWidth, 75 )
	if FeatherList[num][lv+1] == nil then
		self.Lab_Exp   : setString( "MAX" )
		self.Spr_Exp1  : setPercent( 100 )  -- 缩放
	else
		local text_exp = FeatherList[num][lv+1].next_exp
		self.Spr_Exp1  : setPercent( exp/text_exp*100 )  -- 缩放
		self.Lab_Exp   : setString( string.format("%d/%d", exp, text_exp) )
	end
end

function FeatherView.changeMidView( self, head_id )
	print( "self.RideId = ", self.RideId )
	if self.spine == nil then 
		self : createSpineNum( head_id )
	end
	
	if self.myData[head_id] == nil then 
		self : createPowerNum( 0 )
		if self.User == nil then 
			self : changeBtn_Jihuo( true )
		end
	else
		self : createPowerNum( self.myData[head_id].powerful )
		self : changeBtn_Jihuo( false )
	end
	if self.RideId == self.currentTypeId then 
		self.Btn_Ride : setTitleText( "卸 下" )
	else
		self.Btn_Ride : setTitleText( "穿 戴" )
	end
end

function FeatherView.createSkill( self, _tag, _worldPos, _num )
	local SKILL_WIDTH  = 330
	local SKILL_HEIGHT = 180

	local num  		   = _num
	local mountSkinId  = _G.Cfg.feather[_num].skin_id

	local function _reset( )
		if self._layer ~= nil then
			self._layer : removeFromParent(true)
			self._layer = nil 
		end
	end

	local function onTouchBegan() 
        _reset()
        return true 
    end
    _reset()
    self._layer = cc.Node : create()
    self._layer : setPosition( _worldPos )
    self.m_rootLayer:addChild( self._layer, 3 )

    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(false)
    self._layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self._layer)

    --底图
    local m_bgSprSize = cc.size(SKILL_WIDTH,SKILL_HEIGHT)
    local m_bgSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_rolekuang.png" ) 
    m_bgSpr  		  : setPreferredSize(m_bgSprSize)
    self._layer 	  : addChild(m_bgSpr)
    m_bgSpr     	  : setPosition(cc.p( m_bgSprSize.width/2, -m_bgSprSize.height/2))

    local headspr = _G.ImageAsyncManager:createSkillSpr(iconNum)
    headspr : setPosition( 15, SKILL_HEIGHT-15 )
    headspr : setAnchorPoint( 0, 1 )
    m_bgSpr : addChild( headspr )

    local name = _G.Util : createLabel( name, 20 )
    name 	: setAnchorPoint( 0, 1 )
    name 	: setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_GOLD ) )
    name 	: setPosition( 15+headspr:getContentSize().width+10, SKILL_HEIGHT-15 )
    m_bgSpr : addChild( name )

    local sprline = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
    sprline : setPreferredSize( cc.size( 240, 2 ) )
    sprline : setAnchorPoint( 0, 0 )
    sprline : setPosition( 15+headspr:getContentSize().width, SKILL_HEIGHT-15-headspr:getContentSize().height )
    m_bgSpr : addChild(sprline )
end

function FeatherView.changeScollView( self, num )
	print( "****num =", num )
	if num > 4 then 
		self.ScrollView : setContentOffset( cc.p(0, 0) )
	else
		self.ScrollView : setContentOffset( cc.p(0, -480) )
	end
end

function FeatherView.showRoleSpine(self,_pro)
  	print( "进入：_showRoleSpine !", _pro )
  	if self.m_skeleton == nil then
      	self.m_skeleton = _G.SpineManager.createPlayer(_pro)
      	self.m_skeleton : setAnimation(0,"idle",true)
      	self.myFeatherNode : addChild(self.m_skeleton,5)
  	end
end

function FeatherView.changeFeatherRide( self )
	if self.Btn_Ride : getTitleText() == "穿 戴" then 
		print( "换乘开始！" )
		self : REQ_FEATHER_DRESS( self.currentTypeId )
	else
		self : REQ_FEATHER_DRESS( 0 )
	end
end

function FeatherView.Peiyang( self )
	if self.Scheduler2 ~= nil then
		_G.Scheduler : unschedule( self.Scheduler2 )
		self.Scheduler2 = nil
	end
	if self.Scheduler3 ~= nil then
		_G.Scheduler : unschedule( self.Scheduler3 )
		self.Scheduler3 = nil
	end
	self.LongPush = false
	local firstIn = false
	local function step2(  )
		self : REQ_FEATHER_LV_UP(self.currentTypeId)
	end

	local function step1(  )
		if firstIn then
			self.LongPush = true
			_G.Scheduler : unschedule( self.Scheduler2 )
      		self.Scheduler2 = nil

      		print( "长按！" )
      		self.Scheduler3 = _G.Scheduler : schedule(step2, 0.1)
		end
		firstIn = true
	end
	self.Scheduler2 = _G.Scheduler : schedule(step1, 0.3)
end

function FeatherView.releasePeiyang( self, _istrue )
	self : releaseScheduler()
	if self.LongPush then return end
	print( "没有长按！" )
	if _istrue then return end
	self : REQ_FEATHER_LV_UP(self.currentTypeId)
end

function FeatherView.releaseScheduler( self )
	if self.Scheduler2 ~= nil then
		_G.Scheduler : unschedule( self.Scheduler2 )
		self.Scheduler2 = nil
	end
	if self.Scheduler3 ~= nil then
		_G.Scheduler : unschedule( self.Scheduler3 )
		self.Scheduler3 = nil
	end
end

function FeatherView.Net_RIDE_BACK( self, head_id )
	-- 改变button名称
	-- 改变人物的穿戴
	self.RideId = head_id
	if head_id ~= 0 then 
		local num = self.Table[head_id]
		print( "当前穿戴的翅膀self.RideId = ", self.RideId, num, head_id )
		local text_Ride = self.Btn_Ride : getTitleText()
		self.Btn_Ride : setTitleText( "卸 下" )

		if self.m_guide_ride then
			self.m_guide_ride=nil
			self.m_guide_read_skill=true
			_G.GGuideManager:runThisStep(3)
		end
		_G.Util:playAudioEffect("ui_partner_fight")
	else
		print( "在这里改变" )
		self.Btn_Ride : setTitleText( "穿 戴" )
	end
end

function FeatherView.REQ_FEATHER_REQUEST( self, uid )
	local msg = REQ_FEATHER_REQUEST( )
	msg : setArgs( uid )
	_G.Network : send( msg )
end

function FeatherView.Net_FEATHER_REPLY( self, msg )
	-- local msg = _ackMsg
	print( "玩家UID：	", msg.uid )
	print( "穿戴ID：		",msg.skin_feather, msg.skin_feather )
	print( "职业：		", msg.pro,msg.count)
	self.RideId = msg.skin_feather
	self.m_rolePro=msg.pro
	self:showRoleSpine(msg.pro)
	local myMsgQuality = nil
	local LastFeather  = self.Table[self.currentTypeId] or nil

	if LastFeather then
		if self.myData[LastFeather] ~= nil then
			myMsgQuality = self.myData[LastFeather].quality
		end
	end
	print( "myMsgQuality = ", myMsgQuality, LastFeather )
	if not self.isGet and msg.skin_feather ~= nil and msg.skin_feather ~= 0 then 
		print( "进入这里啦" )
		self.currentTypeId = msg.skin_feather
		self.isGet = true
	end

	local m_data = msg.data
	local function sort( data1, data2 )
      	if data1.id_feather < data2.id_feather then
        	return true
    	end
  	end
  	table.sort( m_data , sort )

  	local maxLevel=0
  	for i=1,msg.count do
		print("翅膀id：	", m_data[i].id_feather)
		print("id对应TAG	", self.Table[m_data[i].id_feather] )
		print("阶数：	", m_data[i].quality)
		print("等级：	", m_data[i].lv)
		print("经验：	", m_data[i].exp)
		print("战力：	", m_data[i].powerful)

		num = self.Table[m_data[i].id_feather]
		if m_data[i].quality>0 then 
			self.nameLabel[num]:setString(string.format("%s+%d",FeatherDes[num].name,m_data[i].quality))
		end
		self.myData[ num ] = m_data[i]
		self : changeLftView( num )

		print( " LastFeather == num? = ", LastFeather, num )
		if LastFeather ~= nil and LastFeather == num then
			if myMsgQuality ~= nil then
				if myMsgQuality < m_data[i].quality then
					print( "进入升阶情况" )
					self : createSpineNum(num)
				end
			end
		end

		local nLev=(m_data[i].quality-1)*10+m_data[i].lv
		maxLevel=nLev>maxLevel and nLev or maxLevel
	end
	if self.m_guide_level~=nil then
		if maxLevel>=self.m_guide_level then
			self.m_guide_level=nil
			_G.GGuideManager:runNextStep()
		end
	end

	local first = false
	local sec 	= false
	local getSec= false
	for i=1,#FeatherList do
		if self.myData[i] ~= nil then
			sec = true
		end
		if msg.skin_feather ~= 0 then
			print( "有穿戴的时候" )
			if  (self.myData[i] ~= nil) and (self.currentTypeId == self.myData[i].id_feather) then
				self : changeRghView( i )
				self : changeMidView( i )
				self : changeScollView( self.Table[self.currentTypeId] )
				self.Btn_Ride : setVisible( true )
			end
		elseif self.intoFisrt == nil then
			print( "无穿戴, 第一次进 " )
			if m_data[i] ~= nil then
				if getSec == false then 
					getSec = true
					local num = self.Table[m_data[i].id_feather]
					self.currentTypeId = m_data[i].id_feather
					print( "当前状态：", num, self.currentTypeId, self.Btn_Mount[num]  )
					self : changeRghView( num )
					self : changeMidView( num )
					self : changeScollView( num )
					self.Btn_Ride : setVisible( true )
				end
			end
		elseif self.intoFisrt == true then
			if self.myData[i] ~= nil then
				if self.currentTypeId == self.myData[i].id_feather then
					print("无穿戴, 需要修改属性")
					self : changeRghView( self.Table[self.myData[i].id_feather] )
				end
			end
		end
	end
	if not sec then 
		print( "进入这里" )
		self : changeRghView( 1 )
		self : changeMidView( 1 )
		self : changeScollView( 1 )
	end
	if self.istrue== true then
		self:UpView(LastFeather)
	end

	self.intoFisrt = true
end

function FeatherView.showBaojiEffect(self,_exp)
	print("showBaojiEffect==>",_exp)
	local ShengJiSpr = "battle_attack.png"
	local Success = "battle_x5.png"
    if _exp == 1 then
		Success = "battle_x10.png"
	elseif _exp == 2 then
		ShengJiSpr = "battle_attackp.png"
		Success = "battle_x100.png"
    end
    _G.Util:playAudioEffect("ui_strengthen_success")
    if self.m_BaoJiSpr~=nil then return end
    self.m_BaoJiSpr=cc.Sprite:createWithSpriteFrameName(ShengJiSpr)
    self.m_BaoJiSpr:setScale(0.05)
    self.m_BaoJiSpr:setPosition(0,0)
    self.mainContainer  : addChild(self.m_BaoJiSpr,1000)    

    local addSpr =  cc.Sprite:createWithSpriteFrameName(Success) 
    self.m_BaoJiSpr : addChild(addSpr)
    local sprsize  = self.m_BaoJiSpr : getContentSize()
    local sprsize2 = addSpr : getContentSize()
    addSpr : setPosition(sprsize.width+sprsize2.width/2,sprsize.height/2-10)
    self.m_BaoJiSpr : setPosition(165,-70)

    local function f1()
        self.m_BaoJiSpr:removeFromParent(true)
        self.m_BaoJiSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.2,0),cc.CallFunc:create(f1))
        self.m_BaoJiSpr:runAction(action)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.2,0.7),cc.CallFunc:create(f2))
    self.m_BaoJiSpr:runAction(action)
end

function FeatherView.showShengJiOkEffect(self,_isTrue)
	local ShengJiSpr = "main_effect_word_cg.png"
	local Success = "main_effect_word_cg1.png"
	local sjPlist="anim/task_finish.plist"
	local sjFram="task_finish_"
    if _isTrue == 1 then
		ShengJiSpr = "main_effect_word_jj1.png"
		Success = "main_effect_word_cg1.png"
		sjPlist="anim/task_finish.plist"
		sjFram="task_finish_"
    end
    _G.Util:playAudioEffect("ui_strengthen_success")
    if self.m_StrengthOkSpr~=nil then return end
    self.m_StrengthOkSpr=cc.Sprite:createWithSpriteFrameName(ShengJiSpr)
    self.m_StrengthOkSpr:setScale(0.05)
    self.m_StrengthOkSpr:setPosition(0,0)
    -- self.m_container:addChild(self.m_StrengthOkSpr,1000)
    self.mainContainer  : addChild(self.m_StrengthOkSpr,1000)    

    local addSpr =  cc.Sprite:createWithSpriteFrameName(Success) 
    self.m_StrengthOkSpr : addChild(addSpr)
    local sprsize  = self.m_StrengthOkSpr : getContentSize()
    local sprsize2 = addSpr : getContentSize()
    addSpr : setPosition(sprsize.width+sprsize2.width/2,sprsize.height/2)
    self.m_StrengthOkSpr : setPosition(155,70)

    local function f1()
        self.m_StrengthOkSpr:removeFromParent(true)
        self.m_StrengthOkSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
        self.m_StrengthOkSpr:runAction(action)
    end
    local function f3()
        local act1=_G.AnimationUtil:createAnimateAction(sjPlist,sjFram,0.12)
        local act2=cc.CallFunc:create(f2)

        local sprSize=self.m_StrengthOkSpr:getContentSize()
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(sprSize.width,sprSize.height*0.5)
        effectSpr:runAction(cc.Sequence:create(act1,act2))
        self.m_StrengthOkSpr:addChild(effectSpr)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    self.m_StrengthOkSpr:runAction(action)
end

function FeatherView.REQ_FEATHER_LV_UP( self, head_id )
	local msg = REQ_FEATHER_LV_UP( )
	msg : setArgs( head_id )
	_G.Network : send( msg )
end

function FeatherView.REQ_FEATHER_QUALITY_UP( self, head_id )
	local minlv=FeatherQua[head_id][self.quality+1].lv_min
	if self.lv<minlv then
		local command = CErrorBoxCommand(string.format("该翅膀需达到%d级才可升阶",minlv))
   	    controller : sendCommand( command )
   	    return
   	end
	local msg = REQ_FEATHER_QUALITY_UP( )
	msg : setArgs( head_id )
	_G.Network : send( msg )
end


function FeatherView.REQ_FEATHER_ACTIVATE( self, head_id )
	print( "head_id = ", head_id, self.currentTypeId )
	local msg = REQ_FEATHER_ACTIVATE( )
	msg : setArgs( head_id )
	_G.Network : send( msg )
end

function FeatherView.REQ_FEATHER_DRESS( self, head_id )
	print( "head_id = ", head_id, self.currentTypeId )
	local msg = REQ_FEATHER_DRESS( )
	msg : setArgs( head_id )
	_G.Network : send( msg )
end

function FeatherView.Net_EXP_ADD( self, _exp )
	if _exp==5 then
   		self:showBaojiEffect()
   	elseif _exp==10 then
   		self:showBaojiEffect(1)
   	elseif _exp==100 then
   		self:showBaojiEffect(2)
   	end
	-- local expStr=string.format("获得%d经验",_exp)
	-- local command = CErrorBoxCommand(expStr)
 --   	controller : sendCommand( command )
end

function FeatherView.Net_ACTIVATE_BACK( self, _ackMsg )
	if _ackMsg.lv~=self.lv then
		self:showShengJiOkEffect()
	end
	if _ackMsg.quality~=self.quality then
		self:showShengJiOkEffect(1)
	end
	_G.Util:playAudioEffect("ui_animals")
	self : REQ_FEATHER_REQUEST( 0 )
end

function FeatherView.Net_SYSTEM_ERROR( self, _ackMsg )
	local ackMsg = _ackMsg
  	if ackMsg.error_code == 8020 then 
	    print( "收到122错误，羽毛不足" )
	    self.Btn_Peiyang : setTouchEnabled( true )

    	if self.Scheduler2 ~= nil then 
			_G.Scheduler : unschedule( self.Scheduler2 )
			self.Scheduler2 = nil
		end
		if self.Scheduler3 ~= nil then 
			_G.Scheduler : unschedule( self.Scheduler3 )
			self.Scheduler3 = nil
		end
  	end
end

function FeatherView.touchEventCallBack( self, obj, touchEvent )
	tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print("   按下  ", tag)
		if tag == Tag_Btn_ShengJi then 
			self : Peiyang()
		end
	elseif touchEvent == ccui.TouchEventType.moved then
		print("   移动  ", tag)
	elseif touchEvent == ccui.TouchEventType.ended then
  		print("   抬起  ", tag)
  		if 101 <= tag and tag <= #FeatherList+100 then -- 左侧翅膀按钮
  			self : ClickLftBtn( tag-100 )
  		elseif tag == Tag_Btn_Ride then
  			self : changeFeatherRide()
  		elseif tag == Tag_Btn_Jihuo then
  			self : REQ_FEATHER_ACTIVATE( self.currentTypeId )
  		elseif tag == Tag_Btn_Up then
  			if self.istrue==true then
  				self.istrue=false
  			else
  				self.istrue=true
  			end
  			self : UpView(self.Table[self.currentTypeId])
  		elseif tag == Tag_Btn_ShengJi then 
  			self : releasePeiyang(  )
  		elseif tag == Tag_Btn_shengjie then 
  			self : REQ_FEATHER_QUALITY_UP( self.currentTypeId )
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ", tag)
  		if tag == Tag_Btn_ShengJi then 
  			self : releasePeiyang(  )
  		end
  	end
end

function FeatherView.AttrFryNode(self,_pos,_obj)
  local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
  attrFryNode:setPosition(_pos.width/2,_pos.height/2)
  _obj:addChild(attrFryNode,1000)
end

function FeatherView.bagGoodsUpdate(self)
	print("bagGoodsUpdatebagGoodsUpdate")
	if self.Lab_Cost~=nil then
		local text = string.format( "%d/%d", _G.GBagProxy : getGoodsCountById(44000),1)
		self.Lab_Cost : setString( text )

		if _G.GBagProxy : getGoodsCountById(44000)<1 then
			self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
		else
			self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
		end
	end
	if self.skillNum~=nil then
		local text = string.format( "%d/%d", _G.GBagProxy : getGoodsCountById(44005),self.CLNum)
		self.skillNum : setString( text )

		if _G.GBagProxy : getGoodsCountById(44000)<self.CLNum then
			self.skillNum : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
		else
			self.skillNum : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
		end
	end
end

return FeatherView