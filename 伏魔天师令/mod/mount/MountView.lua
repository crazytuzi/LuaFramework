local MountView = classGc(view, function(self, _data1)
    self.User        	= _data1
    self.m_winSize  	= cc.Director:getInstance() : getWinSize()
	self.m_viewSize 	= cc.size( 828, 492 )

	self.currentTypeId 	= 50005
	self.RideId			= 0
	self.myData			= {}
	self.pro 			= 0

	self.m_mediator 	= require("mod.mount.MountMediator")() 
	self.m_mediator 	: setView(self) 

	self.m_spineResArray  = {}
end)

local FONTSIZE 			= 20
local MountList 		= _G.Cfg.mount

local Tag_Btn_Jihuo		= 1001
local Tag_Btn_Ride 		= 1002

local Tag_Btn_Peiyang 	= 2001
local Tag_Btn_AutoPei	= 2002  

local color7 = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN )

function MountView.create( self )
	self.m_settingView = require( "mod.general.NormalView" )()
	self.m_rootLayer   = self.m_settingView : create()
	self.m_settingView : setTitle( "坐 骑" )
	self.m_settingView : showSecondBg()

	local tempScene=cc.Scene:create()
  	tempScene:addChild(self.m_rootLayer)

	self:init()

	return tempScene
end

function MountView.init( self )

	local function closeFunSetting()
		self : closeWindow()
	end
  	self.m_settingView : addCloseFun(closeFunSetting)

  	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2-20 ) )
	self.m_rootLayer 	: addChild( self.mainContainer )

	self.myMountNode = cc.Node:create()
	self.mainContainer:addChild(self.myMountNode, 5)

	local rightView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double.png" )
  	rightView : setContentSize( cc.size( 713,475 ) )
  	rightView : setPosition( 59 , -20 )
   	self.mainContainer	: addChild( rightView)

	self : createLftView()
	self : createMidView()
	self : createRghView()

	self : REQ_MOUNT_REQUEST( (self.User or 0) )

	if self.User==nil then
		local guideId=_G.GGuideManager:getCurGuideId()
		if guideId==_G.Const.CONST_NEW_GUIDE_SYS_MOUNT then
			self.m_hasGuide=true
			local closeBtn=self.m_settingView:getCloseBtn()
			_G.GGuideManager:initGuideView(self.m_rootLayer)
			_G.GGuideManager:registGuideData(1,self.Btn_Jihuo)
			_G.GGuideManager:registGuideData(2,self.Btn_Ride)
			_G.GGuideManager:registGuideData(4,closeBtn)
			self.m_guide_ride_init=true
			self.m_guide_init_skillbtn=true
			_G.Util:playAudioEffect("sys_mount")
		elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_MOUNT_LEVEL then
			self.m_hasGuide=true
			local closeBtn=self.m_settingView:getCloseBtn()
			_G.GGuideManager:initGuideView(self.m_rootLayer)
			_G.GGuideManager:registGuideData(1,self.Btn_Peiyang)
			_G.GGuideManager:registGuideData(2,closeBtn)
			_G.GGuideManager:runNextStep()
			self.m_guide_level=1
		end
	end
	if self.m_hasGuide then
		local command=CGuideNoticHide()
      	controller:sendCommand(command)
	end
end

function MountView.createLftView( self )
	local Spr_LefView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_login_dawaikuan.png" )
  	Spr_LefView : setContentSize( cc.size( 112, 475 ) )
  	Spr_LefView : setPosition( -359 , -20 )
   	self.mainContainer	: addChild( Spr_LefView)

   	local Wid_LefView = Spr_LefView : getContentSize().width
   	local Hei_LefView = Spr_LefView : getContentSize().height
   	print( "Wid_LefView = ", Wid_LefView, Hei_LefView )

   	local count			= #MountList
   	local ScrollHeigh 	= 116
  	local viewSize 		= cc.size( 112, 4*ScrollHeigh )
   	local containerSize = cc.size( 112, count*ScrollHeigh)
   	print( "viewSize.height-containerSize.height = ", viewSize.height-containerSize.height )
  	self.ScrollView  	= cc.ScrollView : create()
  	self.ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
  	self.ScrollView  : setViewSize(viewSize)
  	self.ScrollView  : setContentSize(containerSize)
  	self.ScrollView  : setContentOffset( cc.p(0, 0))
  	self.ScrollView  : setPosition( 0, 5 )
  	self.ScrollView  : setTouchEnabled(true)
  	self.ScrollView  : setDelegate()
  	Spr_LefView : addChild( self.ScrollView)

  	local barView=require("mod.general.ScrollBar")(self.ScrollView)
  	barView:setPosOff(cc.p(-9,0))

  	local function ButtonCallBack(  obj, eventType )
  		local tag 		= obj : getTag()
  		local Position  = obj : getWorldPosition()
  		print( "y = ", Position.y )
      	if Position.y > 500 or Position.y < 58 or self.currentTypeId == tag then 
         	return 
      	end
  		self : touchEventCallBack( obj, eventType )
  	end

  	self.Btn_Mount    = {}
  	self.headIconSpr  = {}
  	self.openLabelSpr = {}
  	self.Table 		  = {}
  	for i=1,count do
  		self.Table[MountList[i].mount_id] = i
	    local mountBtnRes = "general_tubiaokuan.png"
	    tag = i + 100
	    self.Btn_Mount[i] = ccui.Button:create()
	    self.Btn_Mount[i] : loadTextures( mountBtnRes, mountBtnRes, mountBtnRes, ccui.TextureResType.plistType)
	    self.Btn_Mount[i] : setPosition( 55, count*ScrollHeigh-ScrollHeigh*(i-1)-47 ) --121*length-105*i-55-18*x
	    self.Btn_Mount[i] : addTouchEventListener(ButtonCallBack)
	    self.Btn_Mount[i] : setTag(tag)
	    self.Btn_Mount[i] : setSwallowTouches(false)
	    self.ScrollView:addChild(self.Btn_Mount[i])

	    local MountId 	 = MountList[i].mount_id
	    local mountColor = _G.Cfg.mount_des[MountId].m_color
	    
	    self.headIconSpr[i] = _G.ImageAsyncManager:createHeadSpr(MountList[i].head_id,mountColor)
	    -- local headSize 		= self.headIconSpr[i] : getContentSize()
	    self.headIconSpr[i] : setPosition(79/2,79/2)
	    self.Btn_Mount[i] 	: addChild(self.headIconSpr[i])
	    self.headIconSpr[i] : setGray()

	    local card=_G.Cfg.mount_des[MountId].m_card
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

	    local nameLabel = _G.Util : createLabel(MountList[i].name,FONTSIZE)
	    nameLabel  : setPosition( 55, count*ScrollHeigh-ScrollHeigh*(i-1)-105 )
	    nameLabel  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	    self.ScrollView : addChild(nameLabel)
  	end
end

function MountView.createMidView( self )
	local function ButtonCallBack( obj, eventType )
  		self : touchEventCallBack( obj, eventType )
  	end
	-- local Spr_MidView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" )
 --  	Spr_MidView : setContentSize( cc.size( self.m_viewSize.width/3+30, self.m_viewSize.height - 10 ) )
 --  	Spr_MidView : setPosition( - 140, 0 )
 --   	self.mainContainer	: addChild( Spr_MidView )

 	local Spr_MidView = ccui.Widget:create()
  	Spr_MidView : setContentSize( cc.size( 415,376 ) )
  	Spr_MidView : setPosition( - 90, 20 )
   	self.mainContainer	: addChild( Spr_MidView )

   	local Spr_Size = Spr_MidView : getContentSize()
   	local Wid_MidView = Spr_Size.width
   	local Hei_MidView = Spr_Size.height
   	print( "Wid_MidView = ", Wid_MidView, Hei_MidView )

   	local sprbg2 = cc.Sprite : createWithSpriteFrameName( "general_rolebg2.png" )
   	sprbg2 : setPosition( Wid_MidView/2 , Hei_MidView/2+50)
   	-- sprbg2 : setScale( 1.2 )
   	Spr_MidView : addChild( sprbg2 ) 

   	local namebgSpr = cc.Sprite : createWithSpriteFrameName( "general_dins.png" )
   	namebgSpr : setPosition( 50 , Hei_MidView/2+80)
   	-- namebgSpr : setScale( 1.2 )
   	Spr_MidView : addChild( namebgSpr ) 

   	self.nameLab = _G.Util : createLabel("", FONTSIZE-2)
	-- self.nameLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	self.nameLab : setPosition(45, Hei_MidView/2+83)
	self.nameLab : setDimensions(25, 100)
	self.nameLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.nameLab : setAnchorPoint( cc.p(0.0,0.5) )
	Spr_MidView  : addChild(self.nameLab)

   	self.fightSpr = cc.Sprite : createWithSpriteFrameName( "main_fighting.png" )
   	-- spr : setAnchorPoint( 0, 0.5 )
   	self.fightSpr : setPosition( Wid_MidView/2 , Hei_MidView - 20 )
   	Spr_MidView : addChild( self.fightSpr ) 

   	-- local lab = _G.Util : createLabel( "激活的坐骑属性可累加", 18 )
   	-- lab : setPosition( Wid_MidView/2-30, 20 )
   	-- lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
   	-- Spr_MidView : addChild( lab )

   	self.Btn_Jihuo = gc.CButton : create()
   	self.Btn_Jihuo : loadTextures( "general_btn_gold.png")
	self.Btn_Jihuo : setTitleText( "激  活" )
	self.Btn_Jihuo : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Jihuo : setTitleFontSize( FONTSIZE+4 )
	self.Btn_Jihuo : setPosition( Wid_MidView/2-30, 32 )
	self.Btn_Jihuo : setTag( Tag_Btn_Jihuo )
	-- self.Btn_Jihuo : setButtonScale(0.9)
	self.Btn_Jihuo : addTouchEventListener( ButtonCallBack )
	Spr_MidView    : addChild( self.Btn_Jihuo, 1 )
	self.Btn_Jihuo : setVisible( false )

   	self.Btn_Ride  = gc.CButton : create()
   	self.Btn_Ride  : loadTextures( "general_btn_gold.png")
	self.Btn_Ride  : setTitleText( "坐  乘" )
	self.Btn_Ride  : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Ride  : setTitleFontSize( FONTSIZE+4 )
	self.Btn_Ride  : setPosition( Wid_MidView/2-30, 32 )
	self.Btn_Ride  : setTag( Tag_Btn_Ride )
	-- self.Btn_Ride  : setButtonScale(0.9)
	self.Btn_Ride  : addTouchEventListener( ButtonCallBack )
	Spr_MidView    : addChild( self.Btn_Ride )
	self.Btn_Ride  : setVisible( false )

	self.powerSpriteNum = {}
	if self.User ~= nil then 
		self : changeBtn_Jihuo( true )
	end

	local attrSize=cc.size(-300,-50)
	self:AttrFryNode(attrSize,self.mainContainer)
end

function MountView.changeBtn_Jihuo( self, isVis )
	self.Btn_Jihuo: setVisible( isVis )
	self.Btn_Ride : setVisible( not isVis )
end

function MountView.createRghView( self )
	local color1 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE )
	local color2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN )
	local doubleSize =  cc.size( 286, 365 ) 
	local Spr_RghView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" )
  	Spr_RghView : setContentSize( doubleSize )
  	Spr_RghView : setPosition( 265, 28 )
   	self.mainContainer	: addChild( Spr_RghView )

   	local Wid_RghView = doubleSize.width
   	local Hei_RghView = doubleSize.height
   	print( "Wid_RghView = ", Wid_RghView, Hei_RghView )

   	local lab = _G.Util : createLabel( "当前属性： ", FONTSIZE )
   	lab : setPosition( 20, Hei_RghView - 28 )
   	lab : setAnchorPoint( 0, 0.5 )
   	lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN )  ) 
   	Spr_RghView : addChild( lab )

   	local lab_2 = _G.Util : createLabel( "(成长)", FONTSIZE )
   	lab_2 : setPosition( lab:getContentSize().width+10, Hei_RghView - 28 )
   	lab_2 : setAnchorPoint( 0,0.5 )
   	lab_2 : setColor( color1  ) 
   	Spr_RghView : addChild( lab_2 )

   	local Spr_Jianbian = cc.Node:create( )
  	Spr_Jianbian : setPosition( 140, -185 )
   	self.mainContainer  : addChild( Spr_Jianbian, 1 )
   	
   	local Name_spr = { "general_att.png","general_hp.png",  "general_wreck.png", "general_def.png", 
   					   "general_hit.png", "general_dodge.png", "general_crit.png","general_crit_res.png" }
   	local Text_lab = {"攻击：", "气血：", "破甲：", "防御：", "命中：", "闪避：", "暴击：", "抗暴："}
   	self.Lab_Att 	  = {}
   	self.Lab_Att_Grow = {}
   	local Pos_y   	  = 38
   	local Pos_X 	  = 10
   	for i=1,8 do
   		local spr=cc.Sprite:createWithSpriteFrameName(Name_spr[i])
   		spr:setPosition(Pos_X,Hei_RghView-i*Pos_y+3)
   		Spr_Jianbian : addChild( spr, 1 )

	   	local lab = _G.Util : createLabel( Text_lab[i], FONTSIZE )
	   	lab : setAnchorPoint( 0, 0.5 )
	   	lab : setColor( color7 )
	   	lab : setPosition( Pos_X+20, Hei_RghView-i*Pos_y )
	   	Spr_Jianbian : addChild( lab, 1 )

	   	self.Lab_Att[i] = _G.Util : createLabel( "", FONTSIZE )
	   	self.Lab_Att[i] : setAnchorPoint( 0, 0.5 )
	   	self.Lab_Att[i] : setColor( color1 )
	   	self.Lab_Att[i] : setPosition( Pos_X+80, Hei_RghView-i*Pos_y )
	   	Spr_Jianbian : addChild( self.Lab_Att[i], 1 )

		self.Lab_Att_Grow[i] = _G.Util : createLabel( "", FONTSIZE )
		self.Lab_Att_Grow[i] : setAnchorPoint( 0, 0.5 )
		self.Lab_Att_Grow[i] : setColor( color1 )
		self.Lab_Att_Grow[i] : setPosition( Pos_X+160, Hei_RghView-i*Pos_y )
		Spr_Jianbian : addChild( self.Lab_Att_Grow[i], 1 )
   	end

   	local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
   	lineSpr:setPreferredSize(cc.size(670,lineSpr:getContentSize().height))
   	lineSpr:setPosition(55,-162)
   	self.mainContainer:addChild(lineSpr)

   	self.Widget = {}
   	for i=1,2 do
   		self.Widget[i] = ccui.Widget : create( )
		self.Widget[i] : setContentSize( cc.size( 710,98  ) )
		-- self.Widget[i] : setAnchorPoint( 0, 1 )
		self.Widget[i] : setPosition( 55, -210 )
		self.Widget[i] : setSwallowTouches( false )
		self.mainContainer    : addChild( self.Widget[i], 1 )
   	end

   	self.Spr_Tanhao = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tanhao.png" )
	-- self.Spr_Tanhao : setAnchorPoint( 0, 1)
	self.Spr_Tanhao : setPosition( 50, 73 )
   	self.Widget[2]  : addChild( self.Spr_Tanhao, 1 )

   	self.Lab_GetMountNeed = _G.Util:createLabel( "", FONTSIZE )
  	self.Lab_GetMountNeed : setAnchorPoint( 0, 0.5 )
	-- self.Lab_GetMountNeed : setDimensions(self.Widget[2]:getContentSize().width - 80, 120)
	-- self.Lab_GetMountNeed : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.Lab_GetMountNeed : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.Lab_GetMountNeed : setPosition( 70, 49 )
	self.Widget[2] : addChild( self.Lab_GetMountNeed )

	self.timeNeedLab1 = _G.Util:createLabel( "获得途径一:   将", FONTSIZE )
  	self.timeNeedLab1 : setAnchorPoint( 0, 0.5 )
	self.timeNeedLab1 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.timeNeedLab1 : setPosition( 70, 49 )
	self.Widget[2] : addChild( self.timeNeedLab1 )

	local needWidth=70+self.timeNeedLab1:getContentSize().width
	self.timeNeedLab2 = _G.Util:createLabel( "急速绵羊", FONTSIZE )
  	self.timeNeedLab2 : setAnchorPoint( 0, 0.5 )
	self.timeNeedLab2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
	self.timeNeedLab2 : setPosition( needWidth, 49 )
	self.Widget[2] : addChild( self.timeNeedLab2 )

	needWidth=needWidth+self.timeNeedLab2:getContentSize().width
	self.timeNeedLab3 = _G.Util:createLabel( "升到", FONTSIZE )
  	self.timeNeedLab3 : setAnchorPoint( 0, 0.5 )
	self.timeNeedLab3 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.timeNeedLab3 : setPosition( needWidth, 49 )
	self.Widget[2] : addChild( self.timeNeedLab3 )

	needWidth=needWidth+self.timeNeedLab3:getContentSize().width-5
	self.timeNeedLab4 = _G.Util:createLabel( "‘境界一3星’", FONTSIZE )
  	self.timeNeedLab4 : setAnchorPoint( 0, 0.5 )
	self.timeNeedLab4 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
	self.timeNeedLab4 : setPosition( needWidth, 49 )
	self.Widget[2] : addChild( self.timeNeedLab4 )

	needWidth=needWidth+self.timeNeedLab4:getContentSize().width+50
	self.timeNeedLab5 = _G.Util:createLabel( "(限时: 99天23时59分)", FONTSIZE )
  	self.timeNeedLab5 : setAnchorPoint( 0, 0.5 )
	self.timeNeedLab5 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	self.timeNeedLab5 : setPosition( needWidth, 49 )
	self.Widget[2] : addChild( self.timeNeedLab5 )

	self.Widget[1] : setVisible( false )
	self.isIn = false

	self.Spr_Start = {}
	for i=1,10 do
		self.Spr_Start[i]  = gc.GraySprite : createWithSpriteFrameName( "general_star.png" )
		self.Spr_Start[i]  : setPosition( 180 + i*30 , 70 )
		self.Widget[1] : addChild( self.Spr_Start[i] ) 
	end

	local zhufuLab = _G.Util : createLabel( "祝福值:", FONTSIZE )
	zhufuLab  : setPosition( 170, 46 )
	zhufuLab  : setColor( color2 )
	self.Widget[1] : addChild( zhufuLab ) 

	local Spr_Exp2  = cc.Sprite : createWithSpriteFrameName( "main_exp_2.png" )
	-- Spr_Exp2  : setScaleX(1.2)
	Spr_Exp2  : setPosition( 360, 45 )
	self.Widget[1] : addChild( Spr_Exp2 )

	self.Spr_Exp1  = ccui.LoadingBar:create()
    self.Spr_Exp1  : loadTexture("main_exp.png",ccui.TextureResType.plistType)
	self.Spr_Exp1  : setAnchorPoint( 0, 0 )
	self.Spr_Exp1  : setPosition( 0, 0.5 )
	Spr_Exp2  	   : addChild( self.Spr_Exp1 )
	-- self.Spr_Exp1  : setPercent( 100 )  -- 缩放

	self.Lab_Exp  = _G.Util : createLabel( "", FONTSIZE-2 )
	self.Lab_Exp  : setPosition( self.Spr_Exp1 : getContentSize().width/2, 7 )
	-- self.Lab_Exp  : setColor( color1 )
	self.Spr_Exp1 : addChild( self.Lab_Exp ) 

	local jingjieLab  = _G.Util : createLabel( "境界", FONTSIZE+4 )
	jingjieLab  : setPosition( 60, 67 )
	jingjieLab  : setColor( color2 )
	self.Widget[1] : addChild( jingjieLab ) 

	self.Lab_Level1 = _G.Util : createLabel( "0", FONTSIZE+4 )
	self.Lab_Level1 : setPosition( 92, 67 )
	self.Lab_Level1 : setColor( color2 )
	self.Widget[1]  : addChild( self.Lab_Level1 )

	self.Lab_Level2 = _G.Util : createLabel( "0", FONTSIZE+4 )
	self.Lab_Level2 : setPosition( 105, 67 )
	self.Lab_Level2 : setColor( color2 )
	self.Widget[1]  : addChild( self.Lab_Level2 )

	local lab1 = _G.Util : createLabel( "祝福值越高成功率越高", FONTSIZE -2 )
	lab1 : setPosition( 340, 17 )
	lab1 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	self.Widget[1] : addChild( lab1 )

	self.Lab_Cost1 = _G.Util : createLabel( "消耗铬合金：", FONTSIZE )
	self.Lab_Cost1 : setPosition( 577, 78 )
	self.Lab_Cost1 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
	self.Widget[1] : addChild( self.Lab_Cost1 )

	self.Lab_Cost = _G.Util : createLabel( "", FONTSIZE )
	self.Lab_Cost : setAnchorPoint( 0, 0.5 )
	self.Lab_Cost : setColor( _G.ColorUtil : getRGB( CONST_COLOR_GRASSGREEN ))
	self.Lab_Cost : setPosition( 635, 78 )
	self.Widget[1]  : addChild( self.Lab_Cost )

	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end 

	self.Lab_Manji = _G.Util : createLabel( "坐骑已满级", 24 )
	self.Lab_Manji : setPosition( 610, 50 )
	self.Lab_Manji : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
	self.Lab_Manji : setVisible( false )
	self.Widget[1]   : addChild( self.Lab_Manji,1 )

	self.Btn_Peiyang = gc.CButton : create()
	self.Btn_Peiyang : loadTextures( "general_btn_gold.png")
	self.Btn_Peiyang : setTitleText( "培 养" )
	self.Btn_Peiyang : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Peiyang : setTitleFontSize( FONTSIZE + 4 )
	-- self.Btn_Peiyang : setPosition( 105, 24 )
	self.Btn_Peiyang : setPosition( 600, 43 )
	self.Btn_Peiyang : setTag( Tag_Btn_Peiyang )
	self.Btn_Peiyang : setSwallowTouches(false)
	self.Btn_Peiyang : setButtonScale(0.9)
	self.Btn_Peiyang : addTouchEventListener( ButtonCallBack )
	self.Widget[1]   : addChild( self.Btn_Peiyang )

	self : createListener()
	
	local tips = _G.Util : createLabel( "长按可快速培养", 18 )
	tips : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
	tips : setPosition( 603, 13 )
	self.Widget[1] : addChild( tips )
	self.tips = tips

	if self.User ~= nil then 
		self.Btn_Peiyang : setVisible( false )
		self.tips : setVisible( false )
		-- self.Btn_AutoPei : setVisible( false )
		self.Widget[1]   : setVisible( true )
		self.Widget[2]	 : setVisible( false )
		self.isIn = false
	end
end

function MountView.createListener( self )
	if self.listener then  return end
	print( "MountView.createListener" )
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

function MountView.removeListener( self )
	if self.listener then
		print( "MountView.removeListener" )
		self.listenerNode : getEventDispatcher() : removeEventListener(self.listener)
		self.listener = nil
	end
end

function MountView.closeWindow( self )
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
	if self.m_hasGuide then
		local command=CGuideNoticShow()
      	controller:sendCommand(command)
	end

	_G.SpineManager.releaseSpineInView(self.m_spineResArray)

	local signArray=_G.GOpenProxy:getSysSignArray()
    if signArray[_G.Const.CONST_FUNC_OPEN_MOUNT] then
        _G.GOpenProxy:delSysSign(_G.Const.CONST_FUNC_OPEN_MOUNT)
    end
end

function MountView.createSpineNum( self, num )
	print( "进入坐骑spine创建" )
  	if self.spine ~= nil then
    	self.spine : removeFromParent(true)
    	self.spine = nil
    	self.shadow : removeFromParent(true)
    	self.shadow = nil
  	end
  	if self.spineTexiao ~= nil then
  		self.spineTexiao : removeFromParent(true)
    	self.spineTexiao = nil
  	end
  	if self.spineTexiao2 ~= nil then
  		self.spineTexiao2 : removeFromParent(true)
    	self.spineTexiao2 = nil
  	end
  	if self.openEffect ~= nil then
  		self.openEffect : removeFromParent(true)
  		self.openEffect = nil
  	end

  	local id     	= _G.Cfg.mount[num].mount_id 
  	local SpineId 	= _G.Cfg.mount[num].skin_id
  	local nScale 	= _G.Cfg.skill_skin[SpineId].scale/10000
  	print( "nScale = ", nScale )

  	local szSpine = "spine/"..SpineId
  	self.spine 	= _G.SpineManager.createSpine(szSpine,nScale) -- _mountId

  	if self.spine == nil then 
  		szSpine = "spine/40101"
    	self.spine  =_G.SpineManager.createSpine(szSpine,nScale)
  	end
  	self.m_spineResArray[szSpine]=true

  	if self.myData[num]~=nil then
	  	local grade = self.myData[ num ].grade
	  	local star  = self.myData[ num ].star
	  	print( "XXXX = ", grade, star )
	  	if star ~= nil and star ~= 0 then
	  		local texiao = _G.Cfg.mount[num][grade][star].effects
	  		print( "texiao = ", texiao )
	  		if texiao ~= 0 and texiao ~= nil then
	  			local tx1 = _G.Cfg.mount_texiao[SpineId].tx1
	  			if tx1 then
		  			szSpine = "spine/"..texiao
		  			self.spineTexiao = _G.SpineManager.createSpine(szSpine,nScale*tx1.nScale) -- _mountId
		  			self.spineTexiao : setAnimation(0,"idle",true)
		  			self.spineTexiao : setPosition( tx1.posx, 0 )
		  			self.myMountNode : addChild(self.spineTexiao,tx1.z)

		  			self.m_spineResArray[szSpine]=true
	  			
		            if self.spineTexiao and tx1 then
		            	local isVis = tx1.type
		                if isVis == 2 then
		                    self.spineTexiao : setVisible( false )
		                else
		                    self.spineTexiao : setVisible( true )
		                end
		            end
		        end

		        local particle = _G.Cfg.mount_texiao[SpineId].particle
		        if particle then
		            local openEffect=cc.ParticleSystemQuad:create("particle/"..particle..".plist")
		            openEffect:setPosition(80,15)
		            self.myMountNode:addChild(openEffect,5)
		            self.openEffect = openEffect
		        end

	            local tx2 = _G.Cfg.mount_texiao[SpineId].tx2
	            if tx2 then
	            	print( "存在第二种特效" )
	            	local isVis = tx2.type
	            	if isVis ~= 2 then
	            		local texiao2 = _G.Cfg.mount[num][grade][star].effects2
	            		szSpine="spine/"..texiao2
	            		self.spineTexiao2 = _G.SpineManager.createSpine(szSpine,nScale*tx2.nScale) -- _mountId
	  					self.spineTexiao2 : setAnimation(0,"idle",true)
	  					self.spineTexiao2 : setPosition( tx2.posx, 0 )
	  					self.myMountNode  : addChild(self.spineTexiao2,tx2.z)

	  					self.m_spineResArray[szSpine]=true
	            	end
	            end
	  		end
	  	end
	end
  	self.spine : setAnimation(0,"idle1",true)
  	self.myMountNode : addChild(self.spine)

  	self.shadow = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  	self.shadow : setScale(1.5)
  	self.myMountNode : addChild(self.shadow)

  	local NodeScale = _G.Cfg.mount_des[id].scale/10000
  	local moveX 	= _G.Cfg.mount_des[id].Xpianyi
  	self.myMountNode : setScaleY( NodeScale )
  	self.myMountNode : setScaleX( -NodeScale )
  	self.myMountNode : setPosition( moveX-150, -90 )

end

function MountView.createPowerNum( self, _powerNum )
	print( " ---改变战力值--- " )
	if self.tempLab~=nil then
		self.tempLab:removeFromParent(true)
		self.tempLab=nil
	end
	self.tempLab=_G.Util:createBorderLabel(string.format("战力:%d",_powerNum),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    -- self.tempLab:setAnchorPoint(cc.p(0,0.5))
    self.tempLab:setPosition(100,18)
    self.fightSpr : addChild(self.tempLab,10)

  	-- local testStr = tostring(_powerNum)
  	-- local x 		= string.len(testStr)+1
  	-- for i=1,string.len(testStr) do
   --  	local numStr = string.sub(testStr,i,i)
   --  	if self.powerSpriteNum[i] == nil then
   --    		local spritePic = string.format("general_powerno_%d.png",numStr)
   --    		local numSprite = cc.Sprite:createWithSpriteFrameName(spritePic)
   --    		numSprite:setPosition(cc.p( -150 + i*15,self.m_viewSize.height/2 - 30))
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

function MountView.ClickLftBtn( self, _num )
	print( "坐骑左侧图标按钮被按下" )
	local num = _num
	if self.currentTypeId ~= MountList[num].mount_id then 
		self.currentTypeId = MountList[num].mount_id
		print( "当前self.currentTypeId = ", self.currentTypeId, num )
		self : createScelectEquipEffect( self.Btn_Mount[num], true, num )
		self : changeRghView( num )
		self : createSpineNum( num )
		self : changeMidView( num ) 
		-- self : createJineng( num ) 
		self.nameLab:setString(MountList[num].name)
	end
end

function MountView.changeLftView( self, num )
	self.headIconSpr[num]  : setDefault()
	self.openLabelSpr[num] : setVisible( false )
end

function MountView.changeRghView( self, num )
	local grade = {}
	local star  = {}
	local zf_value = {}
	local Text_mountData = {"strong_att", "hp",  "defend_down", "strong_def", "hit", "dod", "crit", "crit_res" } 
	if self.myData[num] == nil then 
		print( "未激活" )
		self.Widget[1]  : setVisible( false )
		self.Widget[2]  : setVisible( true )
		self:removeListener()
		-- self.Btn_Jihuo  : setVisible( true )
		self : changeBtn_Jihuo( true )
		self.Spr_Tanhao : setVisible( true )
		-- print( "MountList[num].mount_id = ", MountList[num].mount_id )
		local nowMountNode=_G.Cfg.mount_des[ MountList[num].mount_id ]
		self.Lab_GetMountNeed : setString( nowMountNode.des1 )
		if MountList[num].mount_id~=50005 then
			self.timeNeedLab1:setVisible(true)
			self.timeNeedLab2:setVisible(true)
			self.timeNeedLab3:setVisible(true)
			self.timeNeedLab4:setVisible(true)
			self.timeNeedLab5:setVisible(true)

			self.timeNeedLab2:setString(_G.Cfg.mount_des[nowMountNode.xuqiu[1]].name)
			self.timeNeedLab4:setString(string.format("‘境界%s%d星’",_G.Lang.number_Chinese[nowMountNode.xuqiu[2]],nowMountNode.xuqiu[3]))
			self.timeNeedLab5:setString(string.format("限时: %s",self:getZCTimeStr(nowMountNode.time)))
		else
			self.timeNeedLab1:setVisible(false)
			self.timeNeedLab2:setVisible(false)
			self.timeNeedLab3:setVisible(false)
			self.timeNeedLab4:setVisible(false)
			self.timeNeedLab5:setVisible(false)
		end
		for i=1,#MountList do
			print( "未激活，设置成长、战斗力" )
			local Text_add = MountList[num][1][2].attr[Text_mountData[i]] - MountList[num][1][1].attr[Text_mountData[i]]
			-- if i <= 4 then
				self.Lab_Att_Grow[i] : setString( string.format("%s%d%s","(", Text_add, ")" ) )
			-- end
			self.Lab_Att[i] : setString( MountList[num][1][0].attr[Text_mountData[i]] )
		end
	else 
		print( "已激活" )
		self  : manji(false)
		-- self.Btn_Jihuo  : setVisible( false )
		self : changeBtn_Jihuo( false )
		grade = self.myData[num].grade
		star  = self.myData[num].star
		zf_value = self.myData[num].zf_value
		print( "num  grade  star  zf_value= ", num, grade, star, zf_value )
		if (star==10) and (MountList[num][grade+1] == nil) then -- 满级
			print( "已激活,满级, Widget设置" )
			self : manji(true)
			self.Widget[1]  : setVisible( true ) 
			self.Widget[2]  : setVisible( false )
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
			self : createPowerNum( self.myData[num].powerful )
			self : changeWidget( num, grade, star, "满级" )
		else
			print( "已激活,未满级, Widget设置, 星级, 阶数" )
			self : manji(false)
			self.Widget[1]  : setVisible( true ) 
			self.Widget[2]  : setVisible( false )
			self : createListener()
			self : changeBtn_Jihuo( false )
			-- 改变阶级，星级，消耗
			self : createJineng( num )
			self : createPowerNum( self.myData[num].powerful )
			self : changeWidget( num, grade, star, zf_value )
		end
		for i=1,8 do
			if  (star==10) and (MountList[num][grade+1] == nil) then 
				print( "~~已激活,满级，成长设置", i )
				-- if i <= 4 then
					self.Lab_Att_Grow[i] : setString( "(0)" )
				-- end
			else 
				print( "~~已激活,未满级，成长设置", i )
				local Text_add = MountList[num][1][2].attr[Text_mountData[i]] - MountList[num][1][1].attr[Text_mountData[i]]
				-- if i <= 4 then
					self.Lab_Att_Grow[i] : setString( string.format("%s%d%s","(", Text_add, ")" ) )
				-- end
			end
			print( "~~已激活,设置战斗值", i )
			-- print("MountList[num][grade][star].attr[Text_mountData[i]]", MountList[num][grade][star].attr[Text_mountData[i]] )
			self.Lab_Att[i] : setString( MountList[num][grade][star].attr[Text_mountData[i]] )
		end
	end
	if self.User ~= nil then

		self.Btn_Peiyang : setGray()
		self.Btn_Peiyang : setTouchEnabled( false )
		-- self.Btn_AutoPei : setGray()
		-- self.Btn_AutoPei : setTouchEnabled( false )
		self.Btn_Ride    : setGray()
		self.Btn_Ride 	 : setTouchEnabled( false )
		self.Btn_Jihuo   : setGray()
		self.Btn_Jihuo 	 : setTouchEnabled( false )
		self:removeListener()
	end
end

function MountView.getZCTimeStr( self,_time )
    local nowTime     = _G.TimeUtil:getServerTimeSeconds()
    print("getZCTimeStr===>>>",_time,nowTime)
    local time = self.openTime+_time-nowTime

    if time<0 then
    	time="已过期"
    	return time
    end

    local endday   = math.floor(time/(24*3600))
    local endhour   = math.floor((time-endday*24*3600)/3600)
    local endmin    = math.floor(time%3600/60)
    -- local second = math.floor(time%60)

    local time=string.format("%d天%d时%d分",endday,endhour,endmin)

    return time
end

function MountView.manji( self, _isManji )
	self.Btn_Peiyang : setVisible( not _isManji )
	self.Btn_Peiyang : setTouchEnabled( not _isManji )
	self.tips : setVisible( not _isManji )
	self.Lab_Cost : setVisible( not _isManji )
	self.Lab_Cost1 : setVisible( not _isManji )
	self.Lab_Manji : setVisible( _isManji )
end

function MountView.changeWidget( self, num, _grade, _star, _zf_value )
	local grade = _grade
	local star  = _star
	local zf_value = _zf_value
	if grade == nil or _star == nil  then 
		print( "收到非法数据，grade = ", grade, "star = ", star )
		grade = 1
		star  = 1 
	end
	if self.oldmountId~=nil and MountList[num].mount_id==self.oldmountId then
		if self.oldstar~=nil and star>self.oldstar  then
			self:ZuoQiShengXing(star)
		end
		if self.oldgrade~=nil and grade~=self.oldgrade then
			self:ZuoQiJingJie()
		end
	end

	for i=1,star do
		self.Spr_Start[i] : setDefault()
	end
	for i=star+1,10 do
		self.Spr_Start[i] : setGray()
	end
	local rig = grade%10
	local lef = (grade - grade%10)/10
	-- local frame1 = cc.SpriteFrameCache : getInstance() : getSpriteFrame( string.format("%s%d%s","mount_",lef,".png" ) )
	-- local frame2 = cc.SpriteFrameCache : getInstance() : getSpriteFrame( string.format("%s%d%s","mount_",rig,".png" ) )
	self.Lab_Level1 : setString( lef )
	self.Lab_Level2 : setString( rig )

	if self.User ~= nil then
		self.Lab_Cost : setString( "0/0" )
	else
		self.allCount = MountList[num][grade][star].cost
		local text = string.format( "%d/%d", _G.GBagProxy : getGoodsCountById(45000), MountList[num][grade][star].cost)
		self.Lab_Cost : setString( text )
	end
	if _G.GBagProxy : getGoodsCountById(45000)<MountList[num][grade][star].cost then
		self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	else
		self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	end


	local labWidth = self.Lab_Cost:getContentSize().width
	-- self.spr : setPosition(235+labWidth, 75 )
	if zf_value == "满级" then
		self.Lab_Exp   : setString( "100%" )
		self.Spr_Exp1  : setPercent( 100 )  -- 缩放
	else
		local text_exp = (zf_value + MountList[num][grade][star].odds) * 0.01
		self.Spr_Exp1  : setPercent( text_exp )  -- 缩放
		self.Lab_Exp   : setString( string.format("%d%s", text_exp, "%") )
	end

	self.oldstar=star
	self.oldgrade=grade
	self.oldmountId=MountList[num].mount_id
end

function MountView.ZuoQiShengXing( self, _star )
	if self.zuoqishengxing~=nil then
		local nPos=cc.p(180 + _star*30,70)
        self.zuoqishengxing:start()
        self.zuoqishengxing:setPosition(nPos)
        return
    end
		
    local tempGafAsset=gaf.GAFAsset:create("gaf/zuoqishengxing.gaf")
    self.zuoqishengxing=tempGafAsset:createObject()
    local nPos=cc.p(180 + _star*30,70)
    self.zuoqishengxing:setLooped(false,false)
    self.zuoqishengxing:start()
    self.zuoqishengxing:setPosition(nPos)
    self.Widget[1] : addChild(self.zuoqishengxing,1000)
end

function MountView.ZuoQiJingJie( self )
	if self.zuoqijinjie~=nil then
        self.zuoqijinjie:start()
        return
    end

    local tempGafAsset=gaf.GAFAsset:create("gaf/zuoqijingjietisheng.gaf")
    self.zuoqijinjie=tempGafAsset:createObject()
    local nPos=cc.p(300,50)
    self.zuoqijinjie:setLooped(false,false)
    self.zuoqijinjie:start()
    self.zuoqijinjie:setPosition(nPos)
    self.Widget[1] : addChild(self.zuoqijinjie,1000)
end

function MountView.changeMidView( self, _num )
	local num = _num
	print( "self.RideId = ", self.RideId )
	if self.spine == nil then 
		self : createSpineNum( num )
	end
	if self.RideId ~= 0 and self.RideId ~= nil then
		self : showRoleSpine( self.pro, num, "m_idle" )
	end
	
	if self.myData[num] == nil then 
		self : createPowerNum( 0 )
		if self.User == nil then 
			-- self.Btn_Jihuo : setVisible( true )
			self : changeBtn_Jihuo( true )
		end
	else
		self : createPowerNum( self.myData[num].powerful )
		-- self.Btn_Jihuo : setVisible( false )
		self : changeBtn_Jihuo( false )
	end
	if self.RideId == self.currentTypeId then 
		self.Btn_Ride : setTitleText( "下坐骑" )
	else
		self.Btn_Ride : setTitleText( "坐 乘" )
	end

	if self.m_guide_ride_init then
		self.m_guide_ride_init=nil
		self.m_guide_select_num=num
		if self.myData[num]==nil then
			-- 指引激活
			print("RRRRRRRR=====>>> 1")
			_G.GGuideManager:runNextStep()
			self.m_guide_jihuo=true
		elseif self.RideId==self.currentTypeId then
			-- 一进来就乘坐了,指引技能查看
			print("RRRRRRRR=====>>> 2")
			self.m_guide_select_num=nil

			self.m_guide_read_skill=true
			_G.GGuideManager:runThisStep(3)

		else
			-- 一进来就激活了,指引乘坐
			print("RRRRRRRR=====>>> 3")
			_G.GGuideManager:runThisStep(2)
			self.m_guide_ride=true
		end
	elseif self.m_guide_select_num~=nil then
		if self.m_guide_select_num==num then
			_G.GGuideManager:showGuideByStep(1)
			_G.GGuideManager:showGuideByStep(2)
		else
			_G.GGuideManager:hideGuideByStep(1)
			_G.GGuideManager:hideGuideByStep(2)
		end
	end
end

function MountView.createJineng( self, _num )
	local num = _num

	print("CCCCCCCCCSSSSSSSSS======>>>>>>")
	if self.jinengNode ~= nil then
		self.jinengNode : removeFromParent(true)
		self.jinengNode = nil
	end

	self.jinengNode = cc.Node : create()
	self.jinengNode : setPosition( 50, 80 )
	self.mainContainer : addChild( self.jinengNode,1 )

	local mountId = _G.Cfg.mount[_num].mount_id
	local mountSkinId = _G.Cfg.mount_des[mountId].skill
	
	local function btn_skillCallback(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			print("skillCallback")
			local tag = sender:getTag()
			if tag <1 then
				return
			end

			if self.m_guide_read_skill then
				self.m_guide_read_skill=nil
				_G.GGuideManager:runNextStep()
			end

			self : createSkill( tag, cc.p(sender:getWorldPosition().x+sender:getContentSize().width/2,
										  sender:getWorldPosition().y+sender:getContentSize().height/2 ), num )
		end
	end

	for i=1,3 do
		local jinengTab 	= _G.Cfg.skill[mountSkinId[i+1]]
		local iconNum = jinengTab.icon
		if not jinengTab then
			print( "这只坐骑技能不存在", _num, mountSkinId )
			return
		end
		local jinengIcon = _G.ImageAsyncManager:createSkillBtn(iconNum,btn_skillCallback,i+1)
		jinengIcon : setButtonScale(0.7)
		jinengIcon : setPosition( 28, 120-i*80 )

		-- local m_size=jinengIcon:getContentSize()
		local kuangSpr=cc.Sprite:createWithSpriteFrameName("battle_skill_box.png")
		kuangSpr : setScale(0.7)
		kuangSpr:setPosition(28, 120-i*80)
		self.jinengNode:addChild(kuangSpr,-1)

		-- jinengIcon : setTag(i+1)
		if self.myData[num]==nil then
			jinengIcon : setGray()
		end
		self.jinengNode  : addChild( jinengIcon,1 ) 
	end

	-- if self.m_guide_init_skillbtn then
	-- 	self.m_guide_init_skillbtn=nil
	-- 	local tempNode=cc.Node:create()
	-- 	tempNode:setContentSize(cc.size(84,82))
	-- 	-- tempNode:setPosition(43,43)
	-- 	self.mainContainer:addChild(tempNode)
	-- 	_G.GGuideManager:registGuideData(3,tempNode)
	-- end

	-- local labText = jinengTab.jihuo
	-- local posy 	  = 35

	-- if self.myData[num] then
	-- 	self.jinengIcon : setDefault()
	-- 	local lv = self.myData[num].grade
	-- 	labText  = jinengTab.lv[lv].remark
	-- 	posy     = 35
	-- end

	-- local name = _G.Util : createLabel( name, FONTSIZE-2 )
	-- name : setAnchorPoint( 0, 1 )
	-- name : setPosition( 70, 55 )
	-- name : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
	-- self.jinengNode : addChild( name )

	-- local lab2 = _G.Util : createLabel( labText, FONTSIZE-4 )
	-- lab2 : setAnchorPoint( 0, 1 )
	-- lab2 : setDimensions( 187,0 )
	-- lab2 : setPosition( 70, posy )
	-- self.jinengNode : addChild( lab2 )
	-- self.jinengText = lab2
end

function MountView.changeJineng( self, num )
	if self.jinengText then
		local mountSkinId   = _G.Cfg.mount[num].skin_id
		local jinengTab 	= _G.Cfg.skill[mountSkinId]
		local labText 		= jinengTab.jihuo
		if self.myData[num] then
			local lv = self.myData[num].grade
			labText  = jinengTab.lv[lv].remark
		end
		self.jinengText : setString( labText )
	end
end

function MountView.createSkill( self, _tag, _worldPos, _num )
	local SKILL_WIDTH  = 350
	local SKILL_HEIGHT = 200
	print("createSkill===>>>",_tag,_num)
	local num  		   = _num
	local mountId  = _G.Cfg.mount[_num].mount_id
	local mountSkinId = _G.Cfg.mount_des[mountId].skill
	local jinengTab    = _G.Cfg.skill[mountSkinId[_tag]]
	local iconNum      = jinengTab.icon
	local name    	   = jinengTab.name

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
    local m_bgSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_bagkuang.png" ) 
    m_bgSpr  		  : setPreferredSize(m_bgSprSize)
    self._layer 	  : addChild(m_bgSpr)
    m_bgSpr     	  : setPosition(cc.p( m_bgSprSize.width/2, -m_bgSprSize.height/2))

    local titleSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
    titleSpr : setPreferredSize(cc.size(330,100))
    titleSpr : setScaleY(-1)
    m_bgSpr : addChild(titleSpr)

	local lv  = 1
    if self.myData[num] and self.myData[num].grade then
    	lv = self.myData[num].grade
    end
    local labText  = jinengTab.lv[lv].remark
    local lab = _G.Util : createLabel( labText, 20 )
    lab : setDimensions(300, 0)
    lab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    lab : setAnchorPoint( 0, 0.5 )
    m_bgSpr : addChild( lab )

    local LabH=lab:getContentSize().height+20
	lab  : setDimensions(300, LabH)
	titleSpr : setPreferredSize(cc.size(330,LabH))
	m_bgSprSize=cc.size(350,LabH+100)
	m_bgSpr : setPreferredSize(m_bgSprSize)
	titleSpr : setPosition(m_bgSprSize.width/2,m_bgSprSize.height/2-37)
	lab  : setPosition( 30, m_bgSprSize.height/2-47 )

    local headspr = _G.ImageAsyncManager:createSkillSpr(iconNum)
    headspr : setPosition(42,m_bgSprSize.height-40)
    headspr : setScale( 0.7 )
    m_bgSpr : addChild( headspr )

    local name = _G.Util : createLabel( name, 20 )
    name 	: setAnchorPoint( 0, 0.5 )
    name 	: setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_SPRINGGREEN ) )
    name 	: setPosition( 90, m_bgSprSize.height-40 )
    m_bgSpr : addChild( name )

    -- local lab2 = _G.Util : createLabel( "技能伤害会随着坐骑阶级成长", 18 )
    -- lab2 : setAnchorPoint( 0, 0 )
    -- lab2 : setPosition( 15, 8 )
    -- lab2 : setColor( _G.ColorUtil : getRGB(_G.Const.CONST_COLOR_LABELBLUE) )
    -- m_bgSpr : addChild( lab2 )
end

function MountView.createScelectEquipEffect( self, _obj, _istrue, _num )
	self : createJineng( _num )
    if _obj == nil then return end
    if self.m_headEffect ~= nil then
        self.m_headEffect : retain()
        self.m_headEffect : removeFromParent(false)
        _obj  : addChild(self.m_headEffect,20)
        self.m_headEffect : release()
        return
    end

    if _istrue then
      self.m_headEffect = cc.Sprite :create()
      self.m_headEffect : runAction(cc.RepeatForever:create(_G.AnimationUtil:getSelectBtnAnimate()))
      self.m_headEffect : setPosition(78/2-1,78/2)

      _obj  : addChild(self.m_headEffect,20)
    end
end

function MountView.changeScollView( self, num )
	print( "****num =", num )
	if num > 4 then 
		self.ScrollView : setContentOffset( cc.p(0, 0) )
	else
		self.ScrollView : setContentOffset( cc.p(0, -500) )
	end
end

function MountView.showRoleSpine( self, _pro ,num ,action )
  	print( "进入：_showRoleSpine !", _pro )
  	if self.m_skeleton == nil then 
	    if self.RideId == self.currentTypeId then 
	    	local mountSkinId=MountList[num].skin_id
	      	print( "sprin_id = ", self.RideId, self.RideId, mountSkinId )
	      	local myPro = _G.GPropertyProxy : getMainPlay() : getPro()
	      	local MountPos  = _G.Cfg.mount_pos[ myPro + 10000 ][mountSkinId]
	      	self.m_skeleton = _G.SpineManager.createPlayer(_pro)
	      	-- 职业的改变 self.pro
	      	self.m_skeleton : setAnimation(0,action..mountSkinId,true)
	      	local k = 0
	      	if mountSkinId == 40126 then
	      		k = -15
	      	end
	      	print( "xxxx k = ", k,mountSkinId )
	      	local nScale = self.m_skeleton:getScale()
	      	self.m_skeleton : setPosition( MountPos.idle_x , MountPos.idle_y+k )
	      	self.myMountNode : addChild(self.m_skeleton,-MountPos.zorder)

	     --  	self.m_RoleHand = _G.SpineManager.createSpine("spine/"..(10000+myPro).."_hand",nScale)
	     --  	if self.m_RoleHand ~= nil then
		    --   	self.m_RoleHand : setAnimation(0,action,true)
		    --   	self.m_RoleHand : setPosition( MountPos.idle_x , MountPos.idle_y+k )
		    --   	self.myMountNode : addChild(self.m_RoleHand,-1)
		    -- end
	    end
	elseif self.RideId == self.currentTypeId then 
    	self.m_skeleton : setVisible( true )
    	if self.m_RoleHand ~= nil then
    		self.m_RoleHand : setVisible( true )
    	end
  	elseif self.RideId ~= self.currentTypeId then
    	self.m_skeleton : setVisible( false )
    	if self.m_RoleHand ~= nil then
    		self.m_RoleHand : setVisible( false )
    	end
  	end
end

function MountView.changeMountRide( self )
	if self.Btn_Ride : getTitleText() == "坐 乘" then 
		print( "换乘开始！" )
		if self.m_skeleton ~= nil then 
			self.m_skeleton : removeFromParent()
			self.m_skeleton = nil
		end
		if self.m_RoleHand ~= nil then
			self.m_RoleHand : removeFromParent( )
			self.m_RoleHand = nil 
		end
		self : REQ_MOUNT_RIDE( self.currentTypeId )
	else
		self : REQ_MOUNT_RIDE( 0 )
	end
end

function MountView.Peiyang( self )
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
		self : REQ_MOUNT_UP_MOUNT(self.currentTypeId)
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

function MountView.releasePeiyang( self, _istrue )
	self : releaseScheduler()
	if self.LongPush then return end
	print( "没有长按！" )
	if _istrue then return end
	self : REQ_MOUNT_UP_MOUNT(self.currentTypeId)
end

function MountView.releaseScheduler( self )
	if self.Scheduler2 ~= nil then
		_G.Scheduler : unschedule( self.Scheduler2 )
		self.Scheduler2 = nil
	end
	if self.Scheduler3 ~= nil then
		_G.Scheduler : unschedule( self.Scheduler3 )
		self.Scheduler3 = nil
	end
end

function MountView.REQ_MOUNT_RIDE( self, mount_id )
	local msg = REQ_MOUNT_RIDE( )
	msg : setArgs( mount_id )
	_G.Network : send( msg )
end

function MountView.Net_RIDE_BACK( self, mount_id )
	-- 改变button名称
	-- 改变人物的乘骑
	self.RideId = mount_id
	if mount_id ~= 0 then 
		local num = self.Table[mount_id]
		print( "当前乘坐的坐骑self.RideId = ", self.RideId, num, mount_id )
		local text_Ride = self.Btn_Ride : getTitleText()
		self.Btn_Ride : setTitleText( "下坐骑" )
		self : showRoleSpine( self.pro, num, "m_idle" )

		if self.m_guide_ride then
			self.m_guide_ride=nil
			self.m_guide_read_skill=true
			_G.GGuideManager:runThisStep(3)
		end
		_G.Util:playAudioEffect("ui_partner_fight")
	else
		print( "在这里改变" )
		self.Btn_Ride : setTitleText( "坐 乘" )
		if self.m_skeleton ~= nil then 
			self.m_skeleton : removeFromParent()
			self.m_skeleton = nil
		end
		if self.m_RoleHand ~= nil then
			self.m_RoleHand : removeFromParent()
			self.m_RoleHand = nil
		end
	end
end

function MountView.REQ_MOUNT_REQUEST( self, uid )
	local msg = REQ_MOUNT_REQUEST( )
	msg : setArgs( uid )
	_G.Network : send( msg )
end

function MountView.Net_MOUNT_REPLY( self, _ackMsg )
	local msg = _ackMsg
	print( "玩家UID：	", msg.uid )
	print( "乘骑ID：		", msg.mount_id )
	print( "职业：		", msg.pro )
	print( "时间：		", msg.opentime )
	self.RideId = msg.mount_id
	self.pro 	= msg.pro
	self.openTime=msg.opentime
	local myMsgGrade = nil
	local LastMount  = self.Table[self.currentTypeId] or nil
	
	if LastMount then
		if self.myData[LastMount] ~= nil then
			myMsgGrade = self.myData[LastMount].grade
		end
	end
	print( "myMsgGrade = ", myMsgGrade, LastMount )
	if not self.isGet and msg.mount_id ~= nil and msg.mount_id ~= 0 then 
		print( "进入这里啦" )
		self.currentTypeId = msg.mount_id
		self.isGet = true
	end
	self.nameLab:setString(MountList[self.Table[self.currentTypeId]].name)
	local msg_data = msg.mount_data
	local function sort( data1, data2 )
      	if data1.mid < data2.mid then
        	return true
    	end
  	end
  	table.sort( msg_data , sort )

  	local maxLevel=0
  	for i=1,msg.count do
		print("坐骑id：	", msg_data[i].mid)
		print("id对应TAG	", self.Table[msg_data[i].mid] )
		print("阶数：	", msg_data[i].grade)
		print("星级：	", msg_data[i].star)
		print("祝福值：	", msg_data[i].zf_value)
		print("战力：	", msg_data[i].powerful)

		num = self.Table[msg_data[i].mid]
		self.myData[ num ] = msg_data[i]
		self : changeLftView( num )

		print( " LastMount == num? = ", LastMount, num )
		if LastMount ~= nil and LastMount == num then
			if myMsgGrade ~= nil then
				if myMsgGrade < msg_data[i].grade then
					print( "进入升阶情况" )
					self : createSpineNum(num)
					self : changeJineng(num)
				end
			end
		end

		local nLev=(msg_data[i].grade-1)*10+msg_data[i].star
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
	for i=1,#MountList do
		if self.myData[i] ~= nil then
			sec = true
		end
		print( "~~~ ", msg.mount_id )
		if msg.mount_id ~= 0 then
			print( "有乘骑的时候" )
			if  (self.myData[i] ~= nil) and (self.currentTypeId == self.myData[i].mid) then
				self : createScelectEquipEffect( self.Btn_Mount[i], true, i )
				self : changeRghView( i )
				self : changeMidView( i )
				self : changeScollView( self.Table[self.currentTypeId] )
				self.Btn_Ride : setVisible( true )

			end
		elseif self.intoFisrt == nil then
			print( "无乘骑, 第一次进 " )
			-- print( "msg_data[i] = ", msg_data[i], self.myData[1].mid)
			if msg_data[i] ~= nil then
				if getSec == false then 
					getSec = true
					local num = self.Table[msg_data[i].mid]
					self.currentTypeId = msg_data[i].mid
					print( "当前状态：", num, self.currentTypeId, self.Btn_Mount[num]  )
					self : createScelectEquipEffect( self.Btn_Mount[num], true, num )
					self : changeRghView( num )
					self : changeMidView( num )
					self : changeScollView( num )
					self.Btn_Ride : setVisible( true )
				end
			end
		elseif self.intoFisrt == true then
			if self.myData[i] ~= nil then
				if self.currentTypeId == self.myData[i].mid then
					print("无乘骑, 需要修改属性")
					self : changeRghView( self.Table[self.myData[i].mid] )
				end
			end
		end

		local time=self:getZCTimeStr(_G.Cfg.mount_des[MountList[i].mount_id].time)
		local openTrue=self:OpenTrueReturn(_G.Cfg.mount_des[MountList[i].mount_id])
		print("time---openTrue",time,openTrue)
		if time~="已过期" and openTrue==true then
			self.openLabelSpr[i]:setSpriteFrame("mount_open.png")
		end
	end
	if not sec then 
		print( "进入这里" )
		self : createScelectEquipEffect( self.Btn_Mount[1], true, 1 )
		self : changeRghView( 1 )
		self : changeMidView( 1 )
		self : changeScollView( 1 )
	end
	self.intoFisrt = true
end

function MountView.OpenTrueReturn( self, m_list )
	print("OpenTrueReturn====>>>>",m_list.xuqiu[1],self.myData[self.Table[m_list.xuqiu[1]]])
	if m_list.xuqiu[1]==nil or self.myData[self.Table[m_list.xuqiu[1]]]==nil then return end
	print("OpenTrueReturn====>>>>1111",self.myData[self.Table[m_list.xuqiu[1]]].grade,self.myData[self.Table[m_list.xuqiu[1]]].star)
	if self.myData[self.Table[m_list.xuqiu[1]]].grade==m_list.xuqiu[2] then
		if self.myData[self.Table[m_list.xuqiu[1]]].star>=m_list.xuqiu[3] then
			return true
		end
	elseif self.myData[self.Table[m_list.xuqiu[1]]].grade>m_list.xuqiu[2] then
		return true
	end
	return false
end

function MountView.REQ_MOUNT_UP_MOUNT( self, mount_id )
	local msg = REQ_MOUNT_UP_MOUNT( )
	msg : setArgs( mount_id )
	_G.Network : send( msg )
end

function MountView.Net_CUL_RESULT( self, result)
	if result == 1 then 
		_G.Util:playAudioEffect("ui_equip_quality")
		self.Btn_Peiyang : setTouchEnabled( true )
		self.isIn = true
	else
		_G.Util:playAudioEffect("ui_strengthen_fail")
	end
end


function MountView.REQ_MOUNT_ACTIVATE( self, mount_id )
	print( "mount_id = ", mount_id, self.currentTypeId )
	local msg = REQ_MOUNT_ACTIVATE( )
	msg : setArgs( mount_id )
	_G.Network : send( msg )
end

function MountView.Net_ACTIVATE_BACK( self )
	self : REQ_MOUNT_REQUEST( 0 )
	_G.Util:playAudioEffect("ui_animals")
	if self.m_guide_jihuo then
		self.m_guide_jihuo=nil
		self.m_guide_ride=true
		_G.GGuideManager:runNextStep()
	end
end

function MountView.Net_SYSTEM_ERROR( self, _ackMsg )
	local ackMsg = _ackMsg
  	if ackMsg.error_code == 8020 then 
	    print( "收到122错误，铬合金不足" )
	    -- self.Btn_AutoPei : setTitleText( "自动培养" )
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

function MountView.touchEventCallBack( self, obj, touchEvent )
	tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print("   按下  ", tag)
		if tag == Tag_Btn_Peiyang then 
			self : Peiyang()
		end
	elseif touchEvent == ccui.TouchEventType.moved then
		print("   移动  ", tag)
	elseif touchEvent == ccui.TouchEventType.ended then
  		print("   抬起  ", tag)
  		if 101 <= tag and tag <= #MountList+100 then -- 左侧坐骑按钮
  			self : ClickLftBtn( tag-100 )
  		elseif tag == Tag_Btn_Ride then
  			self : changeMountRide()
  		elseif tag == Tag_Btn_Jihuo then
  			self : REQ_MOUNT_ACTIVATE( self.currentTypeId )
  		elseif tag == Tag_Btn_Peiyang then 
  			self : releasePeiyang(  )
  		-- elseif tag == Tag_Btn_AutoPei then 
  		-- 	self : AntoPeiyang()
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ", tag)
  		if tag == Tag_Btn_Peiyang then 
  			self : releasePeiyang(  )
  		end
  	end
end

function MountView.AttrFryNode(self,_pos,_obj)
  local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
  attrFryNode:setPosition(_pos.width/2,_pos.height/2)
  _obj:addChild(attrFryNode,1000)
end

function MountView.bagGoodsUpdate(self)
	if self.Lab_Cost~=nil and self.allCount~=nil then
		local text = string.format( "%d/%d", _G.GBagProxy : getGoodsCountById(45000),self.allCount)
		self.Lab_Cost : setString( text )

		if _G.GBagProxy : getGoodsCountById(45000)<self.allCount then
			self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
		else
			self.Lab_Cost : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		end
	end
end

return MountView