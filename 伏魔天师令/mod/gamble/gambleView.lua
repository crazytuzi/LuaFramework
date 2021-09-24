local gambleView = classGc( view, function( self, _openType )
	-- self.m_openType = _openType

	self.m_winSize  = cc.Director:getInstance() : getWinSize()
	self.m_viewSize = cc.size( 854, 640 )

	self.SetShaizi 	= { false, false, false, false, false }
	self.isShark	= false
	self.check 		= false
	self.choose_1	= true

	self.m_mediator = require("mod.gamble.gambleMediator")() 
	self.m_mediator : setView(self) 
end)

local NoTouchSet    = false
local FONTSIZE 		= 20
local RepeatTimes   = 0

local Tag_Close			= 11 			
local Tag_Btn_Gamestart	= 22 
local Tag_Btn_Change	= 33
local Tag_Btn_Reward  	= 44
local NoTouch 			= 77
local GouZiTag	    	= { 1, 2, 3, 4, 5 }

local xpot 	   		= -335  		-- 第二个label的文字坐标
local ypot     		= -160
local gap 			= 165			-- 距离

local ShaiXpot		= -330			-- 筛子的坐标，筛底为标(-300,30)
local ShaiYpot		= 5

local ShaiZiValue  	= { 6, 6, 6, 6, 6 }	 		-- 筛子摇出来的号码
local Tag_Widget_my = { 101, 102, 103, 104, 105 }

local color1 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD )
-- local color2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PBLUE )

function gambleView.create( self )
	self.m_settingView = require( "mod.general.NormalView" )()
	self.gamSetLabel   = self.m_settingView:create()
	self.m_settingView : setTitle( "摇一摇" )
	self.m_settingView : showSecondBg()

	local tempScene=cc.Scene:create()
 	tempScene:addChild(self.gamSetLabel)
	
	self:init()

	return tempScene
end

function gambleView.init( self )
	-- 发送请求次数协议
	self : REQ_FLSH_TIMES_REQUEST()
	-- 初始化界面
	self : initView()
	-- if self.m_openType == _openType then 
	-- 	self.m_settingView:selectTagByTag(1)
	-- end
end

function gambleView.initView( self )
	local function touchEvent( obj, touchType )
		self : touchEventCallBack( obj, touchType )
	end	

	self.mainContainer = cc.Node : create()
	self.mainContainer : setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2-20 ) )
	self.gamSetLabel   : addChild( self.mainContainer )

	local backDouble2Xpot 	= 830
	local backDouble2Ypot 	= 350
	local backDouble2Ypot_2 = 115
  	-- 第一背景，设为全局
  	self.TubiaoSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_rolekuang.png" )
  	self.TubiaoSpr : setContentSize( cc.size( backDouble2Xpot, backDouble2Ypot ) )
  	self.TubiaoSpr : setPosition( cc.p( 0, 40 ) )
  	self.mainContainer : addChild( self.TubiaoSpr )

  	local function closeFunSetting()
		self:closeWindow()
	end
  	local closeBtn = self.m_settingView:getCloseBtn()
  	self.m_settingView:addCloseFun(closeFunSetting)

  	-- 第二背景，设为全局
  	self.TubiaoSpr_2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_rolekuang.png" )
  	self.TubiaoSpr_2 : setContentSize( cc.size( backDouble2Xpot, backDouble2Ypot_2 ) )
  	self.TubiaoSpr_2 : setPosition( cc.p( 0, -198 ) )
  	self.mainContainer : addChild( self.TubiaoSpr_2 )


  	-- 第一个背景面板创建
  	self : FirstBackCreate()
  	-- 第二个背景面板创建
  	self : SecondBackCreate()
end

function gambleView.FirstBackCreate( self )

	local function ButtonCallBack( obj, touchEvent )
		self : touchEventCallBack( obj, touchEvent )
	end

	self.GameStartBtn = gc.CButton : create( )
	self.GameStartBtn : setPosition( 0, -100 )
	self.GameStartBtn : setTitleText( "开始游戏" )
	self.GameStartBtn : loadTextures("general_btn_gold.png")
	self.GameStartBtn : setTitleFontName( _G.FontName.Heiti )
	self.GameStartBtn : setTitleFontSize( FONTSIZE+2 )
    self.GameStartBtn : addTouchEventListener(ButtonCallBack)
    self.GameStartBtn : setTag(Tag_Btn_Gamestart)
    self.mainContainer:addChild( self.GameStartBtn ) 

    self.ChangeBtn = gc.CButton : create( )
    self.ChangeBtn : setPosition( 90, -100 )
    self.ChangeBtn : setTitleText( "变 换" )
   	self.ChangeBtn : loadTextures("general_btn_gold.png")
	self.ChangeBtn : setTitleFontName( _G.FontName.Heiti )
	self.ChangeBtn : setTitleFontSize( FONTSIZE+2 )
   	self.ChangeBtn : addTouchEventListener(ButtonCallBack)
   	self.ChangeBtn : setTag(Tag_Btn_Change)
    self.mainContainer:addChild( self.ChangeBtn ) 
    self.ChangeBtn : setVisible( false )

    self.RewardBtn = gc.CButton : create( )
	self.RewardBtn : setPosition( -90, -100 )
	self.RewardBtn : setTitleText( "领取奖励" )
	self.RewardBtn : loadTextures("general_btn_gold.png")
	self.RewardBtn : setTitleFontName( _G.FontName.Heiti )
	--self.RewardBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	self.RewardBtn : setTitleFontSize( FONTSIZE+2 )
    self.RewardBtn : addTouchEventListener(ButtonCallBack)
    self.RewardBtn : setTag(Tag_Btn_Reward)
    self.mainContainer:addChild( self.RewardBtn ) 
    self.RewardBtn : setVisible( false )

   	local color10 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED )
    local FirstShowLabel_2 = _G.Util : createLabel( "勾选后可以点击变换", FONTSIZE )
    FirstShowLabel_2 : setAnchorPoint( 0, 0.5 )
    FirstShowLabel_2 : setPosition( -385, -85 )
    FirstShowLabel_2 : setColor( color10 )
    self.mainContainer : addChild( FirstShowLabel_2 )
    local FirstShowLabel_3 = _G.Util : createLabel( "按钮改变骰子的点数", FONTSIZE )
    FirstShowLabel_3 : setAnchorPoint( 0, 0.5 )
    FirstShowLabel_3 : setPosition( -385, -110 )
    FirstShowLabel_3 : setColor( color10 )
    self.mainContainer : addChild( FirstShowLabel_3 )

    local FirstShowLabel_4 = _G.Util : createLabel( "今日剩余次数：", FONTSIZE )
    FirstShowLabel_4 	: setPosition( 270, -100 )
    -- FirstShowLabel_4 	: setColor( color2 )
    self.mainContainer 	: addChild( FirstShowLabel_4 )
    local FirstShowLabel_5 = _G.Util : createLabel( "次", FONTSIZE )
    FirstShowLabel_5 	: setPosition( 370, -100 )
    -- FirstShowLabel_5 	: setColor( color2 )
    self.mainContainer 	: addChild( FirstShowLabel_5 )

    local function checkBoxCallback( obj, touchEvent )
  		local tag = obj : getTag()
  		if self.SetShaizi[tag] == true then
			self.SetShaizi[tag] = false
		else
			self.SetShaizi[tag] = true
		end
		print( "筛子", tag, "设置为", self.SetShaizi[tag])
  	end
    self.ShaiDiPit 		= {}
    self.ShaiZipit 		= {}
    self.ShaiZhongPit 	= {}
  	self.checkBox 	 	= {}
  	local uncheckBox 	= "general_gold_floor.png"
	local selectBox  	= "general_check_selected.png"

    for i=1,5 do    		
    	-- 底
    	self.ShaiDiPit[i] 	= cc.Sprite : createWithSpriteFrameName( "gamble_endl.png" )
	    self.ShaiDiPit[i] 	: setPosition( ShaiXpot + (i-1)*gap, ShaiYpot )				-- xpot = -300 ; ypot = 20
	    self.mainContainer  : addChild( self.ShaiDiPit[i], 0 )
	    -- 筛子
	    local ShaiZiName 	= string.format( "%s%d%s", "gambel_s", ShaiZiValue[i], ".png" )
	    self.ShaiZipit[i] 	= cc.Sprite : createWithSpriteFrameName( ShaiZiName )
	    self.ShaiZipit[i] 	: setPosition( ShaiXpot + (i-1)*gap + 2, ShaiYpot + 25 )		-- x = -298 ; y = 50
	    self.ShaiZipit[i]   : setScale( 1.3 )
	    self.mainContainer 	: addChild( self.ShaiZipit[i], 1 )
	    -- 筛盅
	    self.ShaiZhongPit[i] = cc.Sprite : createWithSpriteFrameName( "gamble_hend.png" )
	    self.ShaiZhongPit[i] : setPosition( ShaiXpot + (i-1)*gap, ShaiYpot + 165 )	-- x = -302 ; y = 135
	    self.ShaiZhongPit[i] : setAnchorPoint( cc.p(0.5,0.8) )
	    self.mainContainer   : addChild( self.ShaiZhongPit[i], 2 )
	    -- widget触摸范围
	    self.myWidget    = {}
	    self.myWidget[i] = ccui.Widget : create( )
		self.myWidget[i] : setContentSize( cc.size(90,200) )
		self.myWidget[i] : setPosition( ShaiXpot + (i-1)*gap + 2, ShaiYpot + 80 )
		self.myWidget[i] : setSwallowTouches( false )
		self.myWidget[i] : setTouchEnabled( true )
		self.myWidget[i] : setTag( Tag_Widget_my[i] )
		self.myWidget[i] : addTouchEventListener( ButtonCallBack )
		self.mainContainer : addChild( self.myWidget[i], 5 )
  		-- “勾选框”
  		self.checkBox[i] = ccui.CheckBox : create( uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType )
		self.checkBox[i] : addEventListener( checkBoxCallback )
		self.checkBox[i] : setPosition(  ShaiXpot + (i-1)*gap, ShaiYpot - 50 )
		self.checkBox[i] : setTag( GouZiTag[i] )
		self.checkBox[i] : setVisible( false )
		self.mainContainer : addChild(self.checkBox[i]) 
    end

    -- 更换图片方法，用图片帧
    -- local frame = cc.SpriteFrameCache : getInstance() : getSpriteFrame( "gambel_s2.png" )
    -- self.ShaiZipit_1	: setSpriteFrame( frame )

    local guideId=_G.GGuideManager:getCurGuideId()
	if guideId==_G.Const.CONST_NEW_GUIDE_SYS_DICE then
		self.m_hasGuide=true
		_G.GGuideManager:initGuideView(self.gamSetLabel)
		_G.GGuideManager:registGuideData(1,self.GameStartBtn)
		_G.GGuideManager:runNextStep()
		local command=CGuideNoticHide()
		controller:sendCommand(command)
	end
end

function gambleView.SecondBackCreate( self )

	local reward   = _G.Cfg.flsh_reward
	local NameText = {}
	local MonyText = {}
	for i=1,9 do
		NameText[i] = reward[i+1].reward_name
		MonyText[i] = reward[i+1].money
	end

	local NamePox = cc.size( xpot, ypot )

	for i=1,#NameText do
		if i%2 == 0 then
			NamePox.width  = xpot + (i/2-1)*gap - 40
			NamePox.height = ypot - 50 - 10 
		else  
			NamePox.width  = xpot + (i-1)/2*gap - 40
			NamePox.height = ypot - 10
		end
		
		local NameLabel = _G.Util : createLabel( NameText[i], FONTSIZE )
		NameLabel : setAnchorPoint( 0, 0.5 )
		NameLabel : setPosition( NamePox.width+10 , NamePox.height+6 )
		-- NameLabel : setColor( color2 )
		self.mainContainer : addChild( NameLabel )
		local Spr_Money = cc.Sprite : createWithSpriteFrameName( "general_tongqian.png" )
		Spr_Money : setAnchorPoint( 0, 0.5 )
		Spr_Money : setPosition( NamePox.width+5, NamePox.height - 15 )
		self.mainContainer : addChild( Spr_Money )
		local MoneLabel = _G.Util : createLabel( MonyText[i], FONTSIZE )
		MoneLabel : setAnchorPoint( 0, 0.5 )
		MoneLabel : setPosition( NamePox.width + 30 , NamePox.height-16 )
		MoneLabel : setColor( color1 )
		self.mainContainer : addChild( MoneLabel )
	end
end

function gambleView.IsTouch( self )
	if NoTouchSet == true then 
		NoTouchSet = false
	else
		NoTouchSet = true
	end 
	print( "local NoTouchSet = ", NoTouchSet )
end

function gambleView.GameStart( self )
	print( " ----开始游戏---- " )
    for i=1,5 do
    	ShaiZiValue[i] = 6
    	self : ShaiziShark(i)
    end
    _G.Util:playAudioEffect("ui_rolldice")
    
    self.choose_1 = true
    self.GameStartBtn : setTouchEnabled( false )
end

function gambleView.BtnVisble( self, Visble )
	
	self.GameStartBtn : setVisible( Visble ) 
	if Visble == false then 	--开始游戏按钮与其他两个按钮的显示是相反的
		self.ChangeBtn : setVisible( true )
		self.RewardBtn : setVisible( true )
		self.ChangeBtn : setTouchEnabled( true )
		self.RewardBtn : setTouchEnabled( true )
		if self.m_hasGuide then
			_G.GGuideManager:clearCurGuideNode()
			self.m_hasGuide=nil
		end
	else
		self.ChangeBtn : setVisible( false )
		self.RewardBtn : setVisible( false )
	end

end


function gambleView.ShaiziShark( self, num )
	local GStartBtnVis = false
	local function BtnsetVisble( )
		self : BtnVisble( GStartBtnVis )
	end
	local BtnVisble = cc.CallFunc : create( BtnsetVisble )

	local function ShowNum( )	
		local showDianshu_num  = string.format( "%s%d%s", "general_powerno_", ShaiZiValue[num], ".png" )
		self.checkBox[num]	  : setVisible( true )
	end
	local ShowShaizi = cc.CallFunc : create( ShowNum )

	local function ShaiziMiss( )
		self.ShaiZipit[num] : setVisible( false )
		local showShaizi_num  = string.format( "%s%d%s", "gambel_s", ShaiZiValue[num], ".png" )
		local frame = cc.SpriteFrameCache : getInstance() : getSpriteFrame( showShaizi_num )
		self.ShaiZipit[num] : setSpriteFrame( frame )
	end
	local Callfun_d	= cc.CallFunc : create( ShaiziMiss )

	local function ShaiziVist( )
		self : REQ_FLSH_GAME_START()
		self.ShaiZipit[num] : setVisible( true )
	end
	local Callfun_u	= cc.CallFunc : create( ShaiziVist )

	local function AwardSetion( )
		local AwardNum = self : GetReward()
		self : AwardChoose( AwardNum )
		self.ChangeBtn 	  : setTouchEnabled( true )
		self.GameStartBtn : setTouchEnabled( true )
		self.ChangeBtn 	  : setDefault()
		self.RewardBtn 	  : setTouchEnabled( true )
		self.RewardBtn    : setDefault()
	end
	local AwardSet = cc.CallFunc : create( AwardSetion )

	local MoveDown     	= cc.MoveTo    : create( 0.3, cc.p(ShaiXpot+(num-1)*gap, ShaiYpot+90) )
	local sharkleft    	= cc.RotateTo  : create( 0.1,  30 )
	local sharkRight   	= cc.RotateTo  : create( 0.1, -30 )
	local rotateAction 	= cc.Sequence  : create( sharkleft, sharkRight )
	local repeatAction 	= cc.Repeat    : create( rotateAction, 3 )
	local sharkNorml   	= cc.RotateTo  : create( 0.05, 0 )
	local StopTime 	   	= cc.DelayTime : create( 0.5 )
	local MoveUp 	   	= cc.MoveTo	   : create( 0.3, cc.p(ShaiXpot+(num-1)*gap, ShaiYpot+165) )
	self.ShaiZhongPit[num] : runAction( cc.Sequence:create( 
		MoveDown,  Callfun_d, StopTime ,repeatAction, sharkNorml, StopTime, Callfun_u, MoveUp, StopTime, ShowShaizi,
		BtnVisble, AwardSet ) ) -- 对应功能：
		-- 筛盅盖下，延时，筛子不可见，筛盅摇动，筛盅摆到正中，延时，筛子可见，筛盅向上，延时，显示筛子数值在label，
		-- 按钮可见
	print( "遥筛第", num, "次结束" )
	self.isShark = false
end

function gambleView.ChangeShaizi( self )

	for i=1,5 do
		if self.SetShaizi[i]==true then
			self.check = true
		end
	end
	if self.check==true then
		self : MessageBox()
	else
		local command = CErrorBoxCommand(39801)
    	controller :sendCommand( command )
	end
	self.choose_1 = false
end

function gambleView.MessageBox( self )
	local function tipsSure()
		self : REQ_FLSH_PAI_SWITCH( )
    end
    local function cancel()
    	self.ChangeBtn : setTouchEnabled( true )
    	self.ChangeBtn : setDefault()
    	self.RewardBtn : setTouchEnabled( true )
    	self.RewardBtn : setDefault()
    end

    self.ChangeBtn : setTouchEnabled( false )
    self.ChangeBtn : setGray()
    self.RewardBtn : setTouchEnabled( false )
    self.RewardBtn : setGray()
    -- self.RewardBtn : setEnabled( false )
    if NoTouchSet==false  and RepeatTimes>=2  then 
		local tipsBox = require("mod.general.TipsBox")()
	    local tipsNode   = tipsBox :create( "", tipsSure, cancel)
	    tipsNode 		  : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
	    self.mainContainer 	: addChild(tipsNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
	    tipsBox : setTitleLabel("变换")

	    local layer=tipsBox:getMainlayer()
	    local money = (RepeatTimes+1)*2-4
	    if money <= 0 then 
	    	money = 0
	    end
		local text1 = string.format( "%s%d%s", "花费", money, "元宝变换骰子1次？" )
	    local text2 = "（元宝不足则消耗钻石）"
		local tips_first = _G.Util : createLabel( text1, FONTSIZE ) 
		tips_first : setPosition( 0, 60 )
		layer      : addChild( tips_first )

		local tips_second = _G.Util : createLabel( text2, FONTSIZE ) 
		tips_second : setPosition( 0, 30 )
		layer    	: addChild( tips_second )

		function checkBoxCallback( obj, touchEvent )
			self : touchEventCallBack( obj, touchEvent )
		end

		local uncheckBox 	= "general_gold_floor.png"
		local selectBox  	= "general_check_selected.png"
		local checkBox = ccui.CheckBox : create( uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType )
		checkBox : addEventListener( checkBoxCallback )
		checkBox : setPosition( cc.p( -80, -34 ) )
		checkBox : setTag( NoTouch )
		layer 	 : addChild(checkBox) 

		local CheckLabel = _G.Util : createLabel( _G.Lang.LAB_N[106], FONTSIZE )
		CheckLabel : setPosition( 25, -35 )
		layer	   : addChild( CheckLabel )
	else 
		self : REQ_FLSH_PAI_SWITCH()
	end

end
-- 领取奖励
function gambleView.Reward( self )
	self : BtnVisble( true )
	local GetNum = self:GetReward()
	self : REQ_FLSH_TIMES_REQUEST()
	for i=1,5 do
		self.SetShaizi[i] = false
		self.checkBox[i] : setSelected( false )
		self.checkBox[i] : setVisible( false )
	end
end

function gambleView.closeWindow( self )
	print( "开始关闭" )
	if self.gamSetLabel == nil then return end
	self.gamSetLabel=nil
	cc.Director:getInstance():popScene()
	self:destroy()

	if self.m_hasGuide then
		local command=CGuideNoticShow()
		controller:sendCommand(command)
	end
end

-- 1：五张相同 2：四张相同 3：五连顺 4：三带一对 5：四连顺 6：三张相同 7：两队相同 8：一对相同 9：啥都不是
function gambleView.AwardChoose( self, num )
	-- xpot = -310  ypot = -132  gap = 150
	local loXpot = { xpot + 15, xpot + 15, xpot + 15 + gap, xpot + 15 + gap, xpot + 15 + gap*2, xpot + 15 + gap*2,
					 xpot + 15 + gap*3, xpot + 15 + gap*3, xpot + 15 + gap*4 }
	local loYpot = {  ypot - 53, ypot - 3 }
	self : addTexiao( cc.p( loXpot[num]-10, loYpot[num%2+1]-10 ), 1 )
end

function gambleView.addTexiao( self, _pos, isClose )
	if self.myTexiao1 ~= nil then
		self.myTexiao1 : removeFromParent(true)
		self.myTexiao1 = nil
	end
	if self.myTexiao2 ~= nil then
		self.myTexiao2 : removeFromParent(true)
		self.myTexiao2 = nil
	end
	if isClose ~= 0 then
		self.myTexiao1 = ccui.Scale9Sprite : createWithSpriteFrameName("gamble_select.png")
		self.myTexiao1 : setPosition( _pos.x-77, _pos.y )
		self.myTexiao1 : setScaleX(-1)
		self.mainContainer : addChild( self.myTexiao1 )

		self.myTexiao2 = ccui.Scale9Sprite : createWithSpriteFrameName("gamble_select.png")
		self.myTexiao2 : setPosition( _pos.x+77, _pos.y )
		self.mainContainer : addChild( self.myTexiao2 )

		print( "开始执行" )
		self.myTexiao1 : runAction(  cc.RepeatForever:create(
											 cc.Sequence:create( 
											 					 cc.MoveTo:create( 0.5, cc.p(_pos.x-77, _pos.y) ),
											 					 cc.MoveTo:create( 0.2, cc.p(_pos.x-55, _pos.y) )
											 					) 
											 				) 
								  )
		self.myTexiao2 : runAction(  cc.RepeatForever:create(
											 cc.Sequence:create( 
											 					 cc.MoveTo:create( 0.5, cc.p(_pos.x+77, _pos.y) ),
											 					 cc.MoveTo:create( 0.2, cc.p(_pos.x+55, _pos.y))
											 					) 
											 				) 
								  )
	end
end

-- 1：五张相同 2：四张相同 3：五连顺 4：三带一对 5：四连顺 6：三张相同 7：两队相同 8：一对相同 9：啥都不是
function gambleView.GetReward( self )
	local returnNum = 0  
	local num = { 0, 0, 0, 0, 0, 0 }
	for i=1,5 do
		num[ ShaiZiValue[i] ] =  num[ ShaiZiValue[i] ] + 1
	end
	print(" num = ",num[1],num[2],num[3],num[4],num[5],num[6])
	local time = num[1]
   	for i=1,5 do
   		if num[i+1]>=time then  -- a and b or c
   			time = num[ i+1 ]
   		end
   	end
   	print( "time = ", time )
   	if time == 1 then 
   		if num[1]==0 or num[6]==0 then
   			print( "五连顺" )
   			returnNum = 3
   		elseif num[2]==0 or num[5]==0 then 
   			print( "四连顺" )
   			returnNum = 5
   		elseif num[3]==0 or num[4]==0 then
   			print( "啥都不是" )
   			returnNum = 9
   		else
   			print( "两对处出错" )
   		end
   	elseif time == 2 then
   		local num_2 = 0
   		for i=1,6 do
   			if num[i]==2 then 
   				num_2 = num_2 + 1
   			end
   		end
   		if num_2 == 2 then 
   			print( "两对相同" )
   			returnNum = 7
   		elseif num_2 == 1 then 
   			if num[1]==0 and num[2]==0 then 
   				print( "四连顺1" )
   				returnNum = 5
   			elseif num[1]==0 and num[6]==0 then 
   				print( "四连顺2" )
   				returnNum = 5
   			elseif num[5] == 0 and num[6]==0 then
   				print( "四连顺4" )
   				returnNum = 5
   			else	
   				print( "一对相同" )
   				returnNum = 8
   			end
   		else
   			print( "两对处出错" )
   		end
   	elseif time == 3 then 
   		local Sdui = false
   		for i=1,6 do
   			if num[i] == 2 then 
   				Sdui = true
   			end
   		end
   		if Sdui == true then 
   			print( "三带一对" )
   			returnNum = 4
   		else
   			print( "三张相同" )
   			returnNum = 6
   		end
   	elseif time == 4 then 
   		print( "四张相同" )
   		returnNum = 2
   	elseif time == 5 then 
   		print( "5张相同" )
   		returnNum = 1
   	else
   		print( "老兄，你设计的程序真烂，出错啦！" )
   	end 
   	return returnNum
end

function gambleView.TouchWidget( self, _num )
	local num = _num
	if self.checkBox[num] : isVisible() == true then 
		print( "widget触摸范围内：", num )
		if self.SetShaizi[num] == true then
			self.checkBox[num]  : setSelected( false )
			self.SetShaizi[num] = false
		else
			self.checkBox[num]  : setSelected( true )
			self.SetShaizi[num] = true
		end
	end
end

function gambleView.REQ_FLSH_TIMES_REQUEST( self )
	print( "次数请求：REQ_FLSH_TIMES_REQUEST" )
	local msg = REQ_FLSH_TIMES_REQUEST()
	_G.Network : send( msg )
end

function gambleView.Times_Reply( self, _ackMsg )
	local ackMsg = _ackMsg
	print( "－－－－－－ 已翻数返回.times1 = ", ackMsg.times1 )
	RepeatTimes = ackMsg.times1
	print( "－－－－－－ 剩余次数返回.times = ", ackMsg.times ) 
	if ackMsg.times <= 0 then
		print( "开始按钮变黑" )
		self.GameStartBtn : setTouchEnabled( false ) 
		self.GameStartBtn : setGray()
	end
	print( "是否得到:", self.TimesLabel  )
	local color1 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN )
	local color2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED )
	local color  = color1
	if ackMsg.times <= 0 then
		color = color2
	end
	if self.TimesLabel == nil then 
		self.TimesLabel = _G.Util : createLabel( string.format("%d",ackMsg.times), FONTSIZE )
	    self.TimesLabel : setPosition( 344, -101 )
	    self.TimesLabel : setColor( color )
	    self.mainContainer : addChild( self.TimesLabel )
	else
		self.TimesLabel : setString( string.format("%d",ackMsg.times) )
		self.TimesLabel : setColor( color )
	end
	print( "－－－－－－ 次数返回.is_get = ", ackMsg.is_get) 
	if ackMsg.is_get == 0 then 
		self : REQ_FLSH_GAME_START()
		self : BtnVisble( false )
		self.RewardBtn : setTouchEnabled( true )
	end
end

function gambleView.REQ_FLSH_GAME_START( self )
	print( "发送开始游戏请求：REQ_FLSH_GAME_START" )
	local msg = REQ_FLSH_GAME_START()
	_G.Network : send( msg )
end

function gambleView.Pai_Reply( self, _ackMsg )
	if self.check == true then
		for num=1,5 do
			if self.SetShaizi[num] == true then
				print( "第", num, "个筛子重摇" )
				self : ShaiziShark( num )
			end
		end
		_G.Util:playAudioEffect("ui_rolldice")
	end
	local ackMsg = _ackMsg
	print( "－－－－－－ 牌返回.times = RepeatTimes = ",  ackMsg.times )
	RepeatTimes = ackMsg.times
	for i=1,ackMsg.count do
		ShaiZiValue[ ackMsg.data[i].pos ] = ackMsg.data[ i ].num
		print( "－－－－－－ 牌返回: ", ackMsg.data[i].pos, ackMsg.data[i].num  )
		if not (self.check==true) then
			local frame_1 = cc.SpriteFrameCache : getInstance() : getSpriteFrame( string.format("%s%d%s", "gambel_s", ackMsg.data[ i ].num, ".png"))
	    	self.ShaiZipit[i]	: setSpriteFrame( frame_1 )
    	end
    	self.checkBox[i]	: setVisible( true )
	end
	self.check = false
	if self.choose_1 == true then 
		local num_Reward = self : GetReward()
		self : AwardChoose( num_Reward )
	end
end

function gambleView.REQ_FLSH_PAI_SWITCH( self )
	print( "换牌：REQ_FLSH_PAI_SWITCH" )
	local time = 0
	local Msg_pos_xxx = {}
	for i=1,5 do
		if self.SetShaizi[i]==true then
			time = time + 1
			Msg_pos_xxx[time] = i
		end
	end
	if time>0 then
		local msg = REQ_FLSH_PAI_SWITCH()
		msg : setArgs( time, Msg_pos_xxx )
		_G.Network : send( msg )
	end
end

function gambleView.REQ_FLSH_GET_REWARD( self )
	print( "领取奖励：REQ_FLSH_GET_REWARD" )
	local msg = REQ_FLSH_GET_REWARD()
	_G.Network : send( msg )
end

function gambleView.Reward_Pos( self, _ackMsg )
	self.isShark = true
	local ackMsg = _ackMsg
	print( "奖励返回.pos = ", ackMsg.pos )

	self : addTexiao( 1, 0 )
end

function gambleView.Error_get( self, _ackMsg )
	local ackMsg = _ackMsg
	if ackMsg.error_code == 134 then 
		self.isShark = false
		print( "收到134错误，钻石不足" )
		self.RewardBtn : setTouchEnabled( true )
		self.RewardBtn : setDefault()
		self.ChangeBtn : setTouchEnabled( true )
		self.ChangeBtn : setDefault()
	end
end

function gambleView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print(" 按下 ", tag)
		if tag == NoTouch then
			self : IsTouch()
		end
  	elseif touchEvent == ccui.TouchEventType.moved then
      	print(" 移动 ", tag)
  	elseif touchEvent == ccui.TouchEventType.ended then
  		print( " 抬起 ", tag )
		if tag == Tag_Close then  			
			self : closeWindow()	-- 关闭事件
		elseif tag == Tag_Btn_Gamestart then
			self : GameStart()		-- 开始游戏按钮
		elseif tag == Tag_Btn_Change then
			print( "开始变换按钮" )
			self : ChangeShaizi()	-- 变换按钮
		elseif tag == Tag_Btn_Reward then
			print( "开始领取奖励" )
			self : REQ_FLSH_GET_REWARD( )
			self : Reward()			-- 领取奖励按钮
		elseif Tag_Widget_my[1] <= tag and tag <= Tag_Widget_my[5] then 
			local num = tag - 100
			self : TouchWidget( num )
		end
	elseif touchEvent == ccui.TouchEventType.canceled then
      	print(" 点击取消 ",  tag)
	end
end


return gambleView