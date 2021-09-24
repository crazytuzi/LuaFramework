local Welkin_OnlyView = classGc( view, function( self, _data1)
	self.myType		= _data1
	self.m_winSize  = cc.Director : getInstance() : getVisibleSize()

	self.m_mediator = require("mod.welkin.Welkin_OnlyMediator")() 
	self.m_mediator : setView(self) 

	self.m_resourcesArray 	= {}
	self.repickTimes 		= 0 
end)

local FONTSIZE 			= 20
local heiti   			= _G.FontName.Heiti 
local COLOR_WHITE		= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE 		)
local COLOR_ORED		= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED   		)
local COLOR_GRASSGREEN  = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN   	)
local COLOR_GOLD		= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD 	 		)
local COLOR_ORANGE		= _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORANGE	  	)

local posY = { 250, 250, 190,  220,   115,   115,   55,   85, 
			   -20, -20, -80,  -50, -155, -155, -215, -185, 
			   220, 220,  85,  152,  -50,  -50, -185, -118,
			   152, 152, -118,  17,   17}		
			   
local Tag_Btn_Explain 		= 1001
local Tag_Btn_Guess			= 1002
local Tag_Btn_MyRange 		= 1003
local Tag_widget_OthRange 	= 1004
local Tag_Btn_Choose    	= { 1005, 1006 }
local Tag_Btn_PutMoney 		= 1007
local Tag_Btn_Explain2 		= 1008
local Tag_MidBtn 			= 1009

local Tag_MidWidget   		= 1111

function Welkin_OnlyView.create( self )
	self.m_settingView = cc.Scene : create()
	self : init()

	return self.m_settingView
end

function Welkin_OnlyView.init( self )
	print( "_G.GPropertyProxy:getMainPlay():getUid()", _G.GPropertyProxy:getMainPlay():getUid() )
	local width 		= self.m_winSize.width
	local height 		= self.m_winSize.height

	self.myBaseMap_1 	= cc.Sprite:create( "ui/bg/welkin_3.jpg" )
	self.myBaseMap_1 	: setPosition( self.m_winSize.width/2 , self.m_winSize.height/2 )
	self.m_settingView 	: addChild( self.myBaseMap_1, -10 ) 

	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( width/2 , height/2 )
	self.m_settingView 	: addChild( self.mainContainer )

	self.myTitleText   = _G.Util : createLabel( "", 20 )
	self.myTitleText   : setAnchorPoint( 0.5, 1 )
	self.myTitleText   : setPosition( 0, height/2-65 )
	self.myTitleText   : setColor( COLOR_GRASSGREEN )
	self.mainContainer : addChild( self.myTitleText,1 )

	self.Spr_juesai = cc.Sprite : createWithSpriteFrameName( "ui_strive_finals.png" )
	self.Spr_juesai : setPosition( 0, height/2-145 )
	self.mainContainer : addChild( self.Spr_juesai, 2 )
	self.Spr_juesai : setVisible( false )

	local function closeFunSetting( obj, touchEvent)
		if touchEvent == ccui.TouchEventType.ended then
	 		self : closeWindow()
	 	end
	end
   	local Btn_close = gc.CButton : create()
   	Btn_close  : loadTextures("general_view_close.png")  
   	Btn_close  : setAnchorPoint( 1, 1 )
   	Btn_close  : setPosition( width/2+13, height/2+20 )
   	Btn_close  : ignoreContentAdaptWithSize(false)
    Btn_close  : setContentSize(cc.size(120,120))
   	Btn_close  : addTouchEventListener( closeFunSetting )
   	Btn_close  : setSoundPath("bg/ui_sys_clickoff.mp3")
   	self.mainContainer	: addChild( Btn_close , 1 )

   	-- 存放 黄色线 和 玩家名字服务器
   	self.myNode = cc.Node : create()
   	self.mainContainer : addChild( self.myNode, 5 )

   	self : REQ_TXDY_SUPER_REQUEST(0)
   	self : createFirstView()
   	self : createFirstNode()
   	self : createAllLine()
   	self : createMidWidget()
end

function Welkin_OnlyView.createFirstView( self )
	local function buttonCallBack( obj, evenType )
		self : touchEventCallBack( obj, evenType )
	end

	local lyer = cc.LayerColor:create(cc.c4b(0,0,0,255*0.6))
	lyer : setContentSize( cc.size( self.m_winSize.width, 58 ) )
	lyer : setPosition( -self.m_winSize.width/2, -self.m_winSize.height/2 )
	self.mainContainer : addChild( lyer )

	local width 			= self.m_winSize.width
	local height 			= self.m_winSize.height
	local Btn_Explain = gc.CButton : create()
	Btn_Explain 	  : loadTextures( "general_help.png" )
	Btn_Explain 	  : setPosition( -width/2 + 40, -height/2 + 15 )
	Btn_Explain 	  : setAnchorPoint( 0, 0 )
	Btn_Explain 	  : setTag( Tag_Btn_Explain )
	Btn_Explain 	  : addTouchEventListener( buttonCallBack )
	self.mainContainer  : addChild( Btn_Explain, 1 )

	local Btn_Guess  = gc.CButton : create()
	Btn_Guess 		 : loadTextures( "ui_strive_guess.png" )
	Btn_Guess 		 : setAnchorPoint( 0, 1 )
	Btn_Guess 		 : setPosition( -width/2+10, height/2-10 )
	Btn_Guess 		 : setTag( Tag_Btn_Guess )
	Btn_Guess 		 : addTouchEventListener( buttonCallBack )
	self.mainContainer : addChild( Btn_Guess, 1 )

	local Btn_MyRange = gc.CButton : create()
	Btn_MyRange 	  : loadTextures( "general_btn_gold.png" )
	Btn_MyRange 	  : setPosition( width/2 - 40, -height/2 + 3 )
	Btn_MyRange 	  : setAnchorPoint( 1, 0 )
	Btn_MyRange 	  : setTag( Tag_Btn_MyRange )
	Btn_MyRange 	  : addTouchEventListener( buttonCallBack )
	Btn_MyRange 	  : setTitleFontName( heiti )
    Btn_MyRange 	  : setTitleText( "我的比赛" )
    -- Btn_MyRange 	  : setButtonScale( 0.8 )
    -- Btn_MyRange  	  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    Btn_MyRange 	  : setTitleFontSize( FONTSIZE+4 )
    self.mainContainer: addChild( Btn_MyRange, 1 )
    self.Btn_MyRange  = Btn_MyRange

    local lab_zu = _G.Util : createLabel( "点击查看其他分组", 18 )
    local mySize = cc.size( lab_zu:getContentSize().width, 48 )

    local widget_OthRange = ccui.Widget : create()
 	widget_OthRange : setContentSize( mySize )
 	widget_OthRange : setTouchEnabled( true )
 	widget_OthRange : addTouchEventListener( buttonCallBack )
 	widget_OthRange : setTag( Tag_widget_OthRange )
 	widget_OthRange : setAnchorPoint( 0.5, 1 )
 	widget_OthRange : setPosition( 0, self.m_winSize.height/2-90 )
    self.mainContainer : addChild( widget_OthRange, 1 )
    self.widget_OthRange  = widget_OthRange

    lab_zu : setPosition( mySize.width/2, mySize.height/2 )
    -- lab_zu : setColor( color4 )
    widget_OthRange : addChild( lab_zu )

    local color100 = _G.ColorUtil:getFloatRGBA( _G.Const.CONST_COLOR_WHITE )
    local myPos = cc.p( mySize.width/2, mySize.height/2 - 10 )
    local lineNode=cc.DrawNode:create()--绘制线条
    lineNode:drawLine(cc.p(-mySize.width/2,1),cc.p(mySize.width/2,1),color100)
    lineNode:setPosition(myPos)
    widget_OthRange:addChild(lineNode,2)

    local spr_mid = cc.Sprite : createWithSpriteFrameName( "ui_strive_name_box.png" )
    spr_mid : setPosition( 0, 15 )
    self.mainContainer : addChild( spr_mid, -1 )

    self.midBtn = gc.CButton : create( )
    self.midBtn : loadTextures( "general_btn_gold.png" )
    self.midBtn : setPosition( 0, -200 )
    self.midBtn : setTitleText( "巅峰之战" )
    self.midBtn : setTitleFontSize( FONTSIZE+2 )
    self.midBtn : setTitleFontName( heiti )
    -- self.midBtn : setButtonScale( 0.9 )
    self.midBtn : setTag( Tag_MidBtn )
    self.midBtn : addTouchEventListener( buttonCallBack )
   --  self.midBtn : ignoreContentAdaptWithSize(false)
  	-- self.midBtn : setContentSize(cc.size(160,87))
    self.mainContainer : addChild( self.midBtn, -1 )
    self.midBtn : setVisible( false )

    -- self.midlab = _G.Util : createLabel( "点击可查看", 18 )
    -- self.midlab : setAnchorPoint( 0.5, 1 )
    -- self.midlab : setPosition( 0, -15 )
    -- self.midlab : setColor( COLOR_GOLD )
    -- self.mainContainer : addChild( self.midlab, -1 )
    -- self.midlab : setVisible( false )

    self.Spr_mid = cc.Sprite : createWithSpriteFrameName( "bazhu.png" )
    self.Spr_mid : setPosition( 5, 50 )
    self.Spr_mid : setAnchorPoint( 0.5, 0 )
    self.mainContainer : addChild( self.Spr_mid, -1 )
    self.Spr_mid : setVisible( false )

    self.Spr_mid2 = cc.Sprite : createWithSpriteFrameName( "ui_strive_tips.png" )
    self.Spr_mid2 : setPosition( 0, 50 )
    self.Spr_mid2 : setAnchorPoint( 0.5, 0 )
    self.mainContainer : addChild( self.Spr_mid2, -1 )
    self.Spr_mid2 : setVisible( false )

    self.Lab_TimeName = _G.Util : createLabel( "", 20 )
    self.Lab_TimeName : setAnchorPoint( 1, 0 )
    self.Lab_TimeName : setPosition( 20, -self.m_winSize.height/2 + 18 )
    -- self.Lab_TimeName : setColor( COLOR_GRASSGREEN )
    self.mainContainer: addChild( self.Lab_TimeName, 1 )

    self.LefTime = _G.Util : createLabel( "", 20 )
    self.LefTime : setAnchorPoint( 0, 0 )
    self.LefTime : setPosition( 22, -self.m_winSize.height/2 + 18 )
    self.LefTime : setColor( COLOR_ORED )
    self.mainContainer: addChild( self.LefTime, 1 )

end

function Welkin_OnlyView.createFirstNode( self )
	local node1 = cc.Node : create()
	self.mainContainer : addChild( node1 )

	local mysize = cc.size( 148, 50 )
	local height = 250
	for i=1,8 do
		local mySpr = cc.Sprite : createWithSpriteFrameName( "ui_strive_name_box.png" )
		mySpr 		: setPosition( -325, height )
		-- mySpr 		: setPreferredSize( mysize )
		node1 		: addChild( mySpr, 3 )	
		-- print( "PosY = ", height )
		height = height - 60
		if i%2 == 0 then
			height = height - 15
		end
	end

	local height = 250
	for i=1,8 do
		local mySpr = cc.Sprite : createWithSpriteFrameName( "ui_strive_name_box.png" )
		mySpr 		: setPosition(  325, height )
		-- mySpr 		: setPreferredSize( mysize )
		node1 		: addChild( mySpr )	
		height = height - 60
		if i%2 == 0 then
			height = height - 15
		end
	end
	
end

function Welkin_OnlyView.createAllLine( self )
	local myLinePNG = "ui_strive_blue_line.png"
	for i=1,2 do
		for k=1,15 do
			self : drowWhichLine( i, k, myLinePNG )
		end
	end
end

function Welkin_OnlyView.drowWhichLine( self, _myType, _whichLine, _myLinePNG )
	local num_Line 	= { 1, 2 }
	local num 		= -250
	local gap  		= 43 
	local PosX 		= { num, num+gap }
	local _place    = self.mainContainer
	local lineY     = 2
	if _myLinePNG  == "ui_strive_yellow_line.png" then
		_place = self.myNode
		lineY  = 3
	end
	if _whichLine == 15 then
		num_Line = { 1 }
		PosX = { num+gap*3 }
	elseif _whichLine == 13 or _whichLine == 14 then
		num_Line = { 1, 4 }
		PosX = { num+gap*2, num+gap*3 }
	elseif _whichLine > 8 then
		num_Line = { 1, 3 }
		PosX = { num+gap, num+gap*2 }
	end

	local myCount = #num_Line
	local typeSize = 1
	if _myType == 2 then
		typeSize = -1
	end

	for i=1,myCount do
		local myLine = self : drowOneLine(  _myType ,num_Line[i], _myLinePNG, lineY )
		if myLine ~= nil then
			local myNum = (_whichLine-1)*2 + i
			myLine : setPosition( typeSize*PosX[i], posY[myNum] ) 
			_place : addChild( myLine )
		else
			print( "划线出错" )
			return 
		end
	end

	
end

function Welkin_OnlyView.drowOneLine( self, _myType, _LineNum, _myLinePNG, _lineY  )
	local mySizeX = { 44, 30, 68, 135 }
	local myRole  = { {0, 90, 90, 90}, {180, 90, 90, 90} }

	local myLine = ccui.Scale9Sprite : createWithSpriteFrameName( _myLinePNG )
	myLine 		 : setPreferredSize( cc.size( mySizeX[_LineNum], _lineY ) )
	myLine 		 : setRotation( myRole[_myType][_LineNum] )
	myLine 		 : setAnchorPoint( 0, 0.5 )
	return myLine
end

function Welkin_OnlyView.createGroupText( self, _count, _msg )
	local tempNode=self.myNode
	local function nFun(_data)
		if not tolua.isnull(tempNode) then
			local nameArray=_data or {}
			local myPosY = { 250, 190, 115, 55, -20, -80, -155, -215,
							 250, 190, 115, 55, -20, -80, -155, -215,}
			local myPosX = { [0] = -326, [1] = 326 }
			local height = 250
			for i=1,_count do
				if _msg[i] ~= nil and _msg[i].index > 0 then
					local num = _msg[i].index
					local lab_name 	= _G.Util : createLabel( _msg[i].name, FONTSIZE - 2 )
					lab_name 		: setColor( COLOR_GRASSGREEN )
					print("myPosXmyPosX==>>",num,myPosY[num])
					lab_name 		: setPosition( myPosX[ math.floor((num-1)/8) ], myPosY[num]+11 )
					self.myNode   	: addChild( lab_name, 5 )

					local Fu     = nameArray[_msg[i].sid] or "nil"
					local lab_fu = _G.Util : createLabel(string.format("%s%s%s","【", Fu, "服】"), FONTSIZE-4 )
					lab_fu 		 : setColor( COLOR_WHITE )
					lab_fu 		 : setPosition( myPosX[ math.floor((num-1)/8) ], myPosY[num]-10 )
					self.myNode  : addChild( lab_fu, 5 )

					height = height - 60
					if num%2 == 0 then
						height = height - 15
					end
				end
			end

			local function winner( _name, _fu )
				local lab_name  = _G.Util : createLabel( _name, FONTSIZE-2 )
				lab_name 		: setColor( COLOR_GOLD )
				lab_name 		: setPosition( 0, 25 )
				self.myNode   	: addChild( lab_name, 5 )

				local lab_fu = _G.Util : createLabel( _fu, FONTSIZE-4 )
				lab_fu 		 : setColor( COLOR_WHITE )
				lab_fu 		 : setPosition( 0, 5 )
				self.myNode  : addChild( lab_fu, 5 )
			end
			local check = nil
			if self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_GROUP then
				check = self.FirstIn
				print( "这轮选择是：check = self.FirstIn", self.myfight, check )
			elseif self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_FINAL or 
		    		self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_GROUP_OVER or 
		     	   	self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_KING or
		     	   	self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
		     	 check = self.FirstIn2
		     	 print( "这轮选择是：check = self.FirstIn2", self.myfight, check )
			end
			
			-- self.myfight  -- turn 
			if self.myChangeTag ~= nil then
			-- 改变小组
				self.myChangeTag = nil
				local myTurn = self.myfight
				if self.state2 == 2 then
					myTurn = myTurn - 1
				end
				print( "改变小组", myTurn )
				for i=1,_count do
					if _msg[i] ~= nil then
						local isTrue = self : drowYellowLine( myTurn, _msg[i].index, _msg[i].is_fail, _msg[i].fail_turn )
						if isTrue then
							local Fu = string.format("%s%s%s","【", nameArray[_msg[i].sid] or "nil", "服】") 
							winner( _msg[i].name, Fu ) 
						end
					end
				end

			elseif self.myfight >= 1 and check == nil  then
			-- 第一次进入，并且不是第一轮
				local myTurn = self.myfight
				if self.state2 == 2 then
					myTurn = myTurn - 1
				end
				print( "首次进入", myTurn )
				for i=1,_count do
					if _msg[i] ~= nil then
						local isTrue = self : drowYellowLine( myTurn, _msg[i].index, _msg[i].is_fail, _msg[i].fail_turn )
						if isTrue then
							local Fu = string.format("%s%s%s","【", nameArray[_msg[i].sid] or "nil", "服】") 
							winner( _msg[i].name, Fu ) 
						end
					end
				end

			elseif check then
			-- 第一次进入不处理
			-- 不是第一次进入
				print( "正常进入划线" )
				if self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_KING then
					print( "进入王者争霸" )
					-- self.midlab   : setVisible( true  )
					self.midBtn : setVisible( true )
					self.over   = true
					self.Btn_MyRange : setGray()
					self.Btn_MyRange : setTouchEnabled( false )
					for i=1,_count do
						if _msg[i] ~= nil then
							local isTrue = self : drowYellowLine( 3, _msg[i].index, _msg[i].is_fail, _msg[i].fail_turn )
							if isTrue then
								local Fu = string.format("%s%s%s","【", nameArray[_msg[i].sid] or "nil", "服】") 
								winner( _msg[i].name, Fu ) 
							end
						end
					end
					return
				elseif self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
					print( "全部结束" )
					self.Btn_MyRange : setGray()
					self.Btn_MyRange : setTouchEnabled( false )
					for i=1,_count do
						if _msg[i] ~= nil then
							local isTrue = self : drowYellowLine( 4, _msg[i].index, _msg[i].is_fail, _msg[i].fail_turn )
							if isTrue then
								local Fu = string.format("%s%s%s","【", nameArray[_msg[i].sid] or "nil", "服】") 
								winner( _msg[i].name, Fu ) 
							end
						end
					end
					return
				end

				local myTurn = self.myfight
				if self.myfight == nil or self.myfight < 1 then
					print( " return\n,self.myfight = ", self.myfight )
					if self.state2 ~= 0 then
						return
					end
				end
				print( "决赛划线" )
				for i=1,_count do
					if _msg[i] ~= nil then
						local isTrue = self : drowYellowLine( self.myfight, _msg[i].index, _msg[i].is_fail, _msg[i].fail_turn )
						if isTrue then
							local Fu = string.format("%s%s%s","【", nameArray[_msg[i].sid] or "nil", "服】") 
							winner( _msg[i].name, Fu ) 
						end
					end
				end
			end
		end
	end

	local sids={}
	for i=1,_count do
		if _msg[i]==nil then break end
		sids[i]=_msg[i].sid
	end
	_G.Util:getServerNameArray(sids,nFun)
end

function Welkin_OnlyView.drowYellowLine( self, _turn, _index, _isFail, _failTurn )
	local text1    = { { 1,  9, 13, 15 }, { 2,  9, 13, 15 }, { 3, 10, 13, 15}, { 4, 10, 13, 15 },
					   { 5, 11, 14, 15 }, { 6, 11, 14, 15 }, { 7, 12, 14, 15}, { 8, 12, 14, 15 }} 
	local myPiture = "ui_strive_yellow_line.png"
	print( "  下标：	 	", _index 	)
	print( "  轮次：	 	", _turn  	)
	print( " 是否失败：	", _isFail  )
	print( " 失败轮次：	", _failTurn,"\n" )

	local myType = 1
	if _index >=9 then
		myType = 2
	end
	local turn = _turn
	local myIndex = _index
	if myIndex > 8 then
		myIndex = myIndex - 8
	end

	if _isFail == 0 then
		if turn < 3 then
			for i=1,turn do
				self : drowWhichLine( myType, text1[myIndex][i], myPiture )
			end
		elseif turn == 3 then
			for i=1,4 do
				self : drowWhichLine( myType, text1[myIndex][i], myPiture )
			end
		elseif turn >= 4 then
			for i=1,4 do
				self : drowWhichLine( myType, text1[myIndex][i], myPiture )
			end
			return true
		end
	else
		if _failTurn == 4 then
			for i=1,4 do
				self : drowWhichLine( myType, text1[myIndex][i], myPiture )
			end
		elseif _failTurn == 2 or _failTurn == 3 then
			for i=1,_failTurn-1 do
				self : drowWhichLine( myType, text1[myIndex][i], myPiture )
			end
		end
	end
	return false
end

function Welkin_OnlyView._getTimeStr( self,_time)
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

function Welkin_OnlyView.createRange( self, _myType, _ackMsg )
	-- if cc.Director : getInstance() : getRunningScene() : getChildByTag(888) ~= nil then return end

	local view = cc.Director : getInstance() : getRunningScene() : getChildByTag(888)
	if view ~= nil then 
		view : removeFromParent(true)
		view = nil
	end
	local width  = 520
	local height = 350 
	if _myType == 2 or _myType == 3 then
		width  = 830
		height = 479
	end
	local function onTouchBegan(touch) 
    	local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-width/2,self.m_winSize.height/2-height/2,
        width,height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end

      	local function nFun()
	        print("closeFunSetting-----------------")
	        if self.titleName2 ~= nil then
	    		self.titleName2 : removeFromParent()
				self.titleName2 = nil
	    	end
			if self.Lab_TimeName2 ~= nil then
				self.Lab_TimeName2 : removeFromParent()
				self.Lab_TimeName2 = nil
			end
			if self.LefTime2 ~= nil then
				self.LefTime2 : removeFromParent()
				self.LefTime2 = nil
			end

	      	self.combatLayer : removeFromParent(true)
	      	self.combatLayer = nil
	    end
	    local delay=cc.DelayTime:create(0.01)
	    local func=cc.CallFunc:create(nFun)
	    self.combatLayer:runAction(cc.Sequence:create(delay,func))
        return true
  	end
	local listerner     = cc.EventListenerTouchOneByOne : create()
  	listerner   : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  	listerner   : setSwallowTouches(true)

  	local combatLayer   = cc.LayerColor:create( cc.c4b(0,0,0,150) )
  	combatLayer : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, combatLayer)
  	combatLayer : setPosition(0, 0)
  	cc.Director : getInstance() : getRunningScene() : addChild(combatLayer)
  	self.combatLayer = combatLayer
  	if _myType == 2 or _myType == 3 then
  		combatLayer : setTag( 888 )
  	else
  		combatLayer : setTag( 777 )
  	end

  	local myNode = cc.Node : create()
  	myNode : setPosition( self.m_winSize.width/2, self.m_winSize.height/2 )
  	combatLayer : addChild( myNode )

  	local function buttonCallBack( obj, evenType )
  		self : touchEventCallBack( obj, evenType )
  	end

  	if _myType == 1 then
  		local Spr_Combat = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
  		Spr_Combat : setContentSize( cc.size( width, height ) )
	  	Spr_Combat : setPosition( cc.p(0,0) )
	  	myNode  : addChild( Spr_Combat ) 

	  	local spr_title = cc.Sprite : createWithSpriteFrameName( "general_tips_up.png" )
	  	spr_title : setPosition( -125, height/2 - 26 )
	  	myNode 	  : addChild( spr_title,1 )

	  	local spr_title = cc.Sprite : createWithSpriteFrameName( "general_tips_up.png" )
	  	spr_title : setPosition( 120, height/2 - 26 )
	  	spr_title : setScale(-1)
	  	myNode 	  : addChild( spr_title,1 )

	  	local lab_title = _G.Util : createBorderLabel( "分  组", 24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
	  	lab_title : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	  	lab_title : setPosition( 0, height/2 - 26 )
	  	myNode 	  : addChild( lab_title, 2 )

	  	local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	    frameSpr:setPreferredSize(cc.size(width-15,height-55))
	    frameSpr:setPosition(width/2,height/4+70)
	    Spr_Combat:addChild(frameSpr)

	  	local widthT = { [0] = -235, -114, 7, 128 }
	  	local height = 115
	  	local Tag_Btn_Group = {}
	  	for i=1,16 do
	  		Tag_Btn_Group[i]= 100+i
	  		local toNum     = _G.Lang.number_Chinese[i]
	  		local Btn_Group = gc.CButton : create( )
	  		Btn_Group 		: setAnchorPoint( 0, 1 )
	  		Btn_Group 		: loadTextures( "ui_group.png" )
	  		Btn_Group 		: setPosition( widthT[(i-1)%4], height )
	  		Btn_Group 	    : setTag( Tag_Btn_Group[i] )
			Btn_Group 	  	: addTouchEventListener( buttonCallBack )
			Btn_Group 	  	: setTitleFontName( heiti )
		    Btn_Group 	  	: setTitleText( string.format( "%s%s%s", "第", toNum, "组" ) )
		    -- Btn_Group 		: setButtonScale( 0.8 )
		    Btn_Group 	  	: setTitleFontSize( FONTSIZE )
		    myNode 	: addChild( Btn_Group, 3 )
		    if i%4 == 0 then
		    	height = height - 70
		    end
		    if i == self.myGroupId then
		    	Btn_Group : loadTextures( "base2.png" )
		    	Btn_Group : setTitleColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
		    end
	  	end
	elseif _myType == 2 or _myType == 3 then
		local function showStar( num, _type, result )
			if num == 0 then return end
			local posX   = { 65, 90, 115 }
			local myType = { -1, 1 }
			local star   = "ui_strive_win.png" 
			for i=1,num do
				local mystar = gc.GraySprite : createWithSpriteFrameName( star )
				mystar : setPosition( posX[i]*myType[_type], height/2 - 60  )
				myNode : addChild( mystar )

				if result[i].flag == 0 then
					mystar : setGray()
				end
			end
		end

		local tempLabel1,tempLabel2,tempSid

		local base = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_strive_dins.png" )
		base   : setPreferredSize( cc.size( width, height ) )
		myNode : addChild( base)

		local vs = cc.Sprite : createWithSpriteFrameName( "ui_strive_vs.png" )
		vs : setPosition( 0, 30 )
		myNode : addChild( vs )

		self.titleName2 = _G.Util : createLabel( "", 20 )
		self.titleName2 : setAnchorPoint( 0.5, 1 )
		self.titleName2 : setPosition( 0, height/2 - 60 )
		self.titleName2 : setColor( COLOR_GRASSGREEN )
		myNode : addChild( self.titleName2 )

		self : changeTitleText( self.myNowState )

		local posX 	= { -250, 250 }
		local msg  	= _ackMsg
		local myPro,myLv,myName,myPow = nil
		if _myType == 2 then
			myPro = _G.GPropertyProxy : getMainPlay() : getPro()
			myLv  = _G.GPropertyProxy : getMainPlay() : getLv()
			myName= _G.GPropertyProxy : getMainPlay() : getName()
			myPow = _G.GPropertyProxy : getMainPlay() : getPowerful()
			tempSid = _G.GLoginPoxy:getServerId()
		else
			msg   = _ackMsg.left
			myPro = msg.pro
			myLv  = msg.lv 
			myName= msg.name
			myPow = msg.power
			tempSid = msg.sid

			showStar( msg.count, 1, msg.msg_result )
		end
		self : showRoleSpr( myPro, myNode, 1, posX[1] )

		local dinsSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_dins.png")
		dinsSpr:setPreferredSize(cc.size(dinsSpr:getContentSize().width,105))
		dinsSpr:setPosition(posX[1],-180)
		myNode:addChild(dinsSpr,1)

		local myWidget = ccui.Widget : create()

		local width  = 0
		 
		local Lab_myLv 	= _G.Util : createLabel( string.format("LV.%d  ", myLv), 20 )
		Lab_myLv 		: setPosition( width, 0 )
		Lab_myLv 		: setAnchorPoint( 0, 1 )
		myWidget 	 	: addChild( Lab_myLv, 3 )
		width = width + Lab_myLv : getContentSize().width

		local Lab_myName = _G.Util : createLabel( myName, 20 )
		Lab_myName 		 : setPosition( width, 0 )
		Lab_myName 		 : setAnchorPoint( 0, 1 )
		myWidget 	 	 : addChild( Lab_myName, 3 )
		width = width + Lab_myName : getContentSize().width
		
		myWidget : setContentSize( cc.size( width, 1 ) )
		myWidget : setPosition( posX[1], -140 )
		myNode : addChild( myWidget, 3 )

		self : createPowerNum( myPow, 1, myWidget )

		local Lab_myFu = _G.Util : createLabel( "", 20 )
		Lab_myFu 	   : setPosition( posX[1], -210 )
		Lab_myFu 	   : setColor( COLOR_ORANGE )
		myNode    : addChild( Lab_myFu,3 )
		tempLabel1=Lab_myFu

		local text = ""
		if self.Lab_TimeName ~= nil then
			text = self.Lab_TimeName : getString()
		end
		self.Lab_TimeName2 = _G.Util : createLabel( text, 20 )
	    -- self.Lab_TimeName2 : setAnchorPoint( 1, 0 )
	    self.Lab_TimeName2 : setPosition( 0, -120 )
	    -- self.Lab_TimeName2 : setColor( COLOR_GRASSGREEN )
	    myNode 	   : addChild( self.Lab_TimeName2, 1 )

	    if self.Lab_TimeName : getPositionX() == 0 then
	    	self.Lab_TimeName2 : setAnchorPoint( 0.5, 0 )
	    	self.Lab_TimeName2 : setPosition( 0, -130 ) 
	    end

	    local text2 = ""
		if self.LefTime ~= nil then
			text2 = self.LefTime : getString()
		end

	    self.LefTime2 = _G.Util : createLabel( text2, 20 )
	    -- self.LefTime2 : setAnchorPoint( 0, 0 )
	    self.LefTime2 : setPosition( 0, -150 )
	    self.LefTime2 : setColor( COLOR_ORED )
	    myNode	  	  : addChild( self.LefTime2, 1 ) 

	    self.LefTime2 : setVisible( self.LefTime : isVisible() )

		if _myType == 3 then
			msg = _ackMsg.right
			showStar( msg.count, 2, msg.msg_result )
		end
		if msg.name ~= nil and msg.uid ~= 0 then
			local enemyPro  = msg.pro
			local enemyName = msg.name 
			local enemyLv   = msg.lv
			local enemyPow  = msg.powerful
			if _myType == 3 then
				enemyPow = msg.power
			end

			self : showRoleSpr( enemyPro, myNode, 2, posX[2] )

			local dinsSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_dins.png")
			dinsSpr:setPreferredSize(cc.size(dinsSpr:getContentSize().width,105))
			dinsSpr:setPosition(posX[2],-180)
			myNode:addChild(dinsSpr,1)

			local myWidget2 = ccui.Widget : create()

			local width  = 0

			local Lab_enemyLv 	= _G.Util : createLabel( string.format("LV.%d  ", enemyLv), 20 )
			Lab_enemyLv 		: setPosition( width, 0 )
			Lab_enemyLv 		: setAnchorPoint( 0, 1 )
			myWidget2 	 		: addChild( Lab_enemyLv, 3 )
			width = width + Lab_enemyLv : getContentSize().width

			local Lab_enemyName = _G.Util : createLabel( enemyName, 20 )
			Lab_enemyName 		: setPosition( width, 0 )
			Lab_enemyName 		: setAnchorPoint( 0, 1 )
			myWidget2 	 	 	: addChild( Lab_enemyName, 3 )
			width = width + Lab_enemyName : getContentSize().width

			myWidget2 : setContentSize( cc.size( width, 1 ) )
			myWidget2 : setPosition( posX[2], -140 )
			myNode : addChild( myWidget2, 3 )

			self : createPowerNum( enemyPow, 2, myWidget2 )

			local Lab_enemyFu = _G.Util : createLabel( "", 20 )
			Lab_enemyFu 	  : setPosition( posX[2], -210 )
			Lab_enemyFu 	  : setColor( COLOR_ORANGE )
			myNode 	  : addChild( Lab_enemyFu,3 )
			tempLabel2=Lab_enemyFu
		else

			local myEnemy = cc.Sprite : create( "ui/bg/expidit_Yingzi.png" )
			myEnemy : setPosition( posX[2], 50 )
			myEnemy : setScale(1.6)
			myNode  : addChild( myEnemy )

			local spr = cc.Sprite : createWithSpriteFrameName( "ui_empty.png" )
			spr    : setPosition( posX[2], -160 )
			myNode : addChild( spr, 1 )
		end

		local function nFun(_data)
			if not tolua.isnull(myNode) then
				local nameArray=_data or {}
				if tempLabel1 then
					tempLabel1:setString(string.format( "%s%s%s", "【", nameArray[tempSid] or "nil", "服】" ))
				end
				if tempLabel2 then
					tempLabel2:setString(string.format( "%s%s%s", "【", nameArray[msg.sid] or "nil", "服】" ))
				end
			end
		end
		local sids
		if msg.sid==tempSid then
			sids={tempSid}
		else
			sids={tempSid,msg.sid}
		end
		_G.Util:getServerNameArray(sids,nFun)
	end
end

function Welkin_OnlyView.OthClose( self )
  	for i=1,2 do
		if self.Lab_TimeName2 ~= nil then
			self.Lab_TimeName2 : removeFromParent()
			self.Lab_TimeName2 = nil
		end
		if self.LefTime2 ~= nil then
			self.LefTime2 : removeFromParent()
			self.LefTime2 = nil
		end
  	end
  	if self.combatLayer ~= nil then
  		self.combatLayer : removeFromParent()
  		self.combatLayer = nil
  	end
end

function Welkin_OnlyView.showRoleSpr( self, _pro, _place, _myType, posX )

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

	local shadow = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  	shadow : setScale(2)
  	shadow : setAnchorPoint( 0.5, 0 )
  	-- shadow : setPosition( 0, -120 )
  	node : addChild( shadow )

  	if self.m_resourcesArray[szImg1] == nil then
  		self.m_resourcesArray[szImg1] = true
  	end 

  	-- if self.m_resourcesArray[szImg2] == nil then
  	-- 	self.m_resourcesArray[szImg2] = true
  	-- end

  	-- if _myType == 1 or myPro ==3 then
  		node : setScale( 0.8 )
  	-- else
  	-- 	node : setScale( -0.8, 0.8 )
  	-- end

    node : setPosition( posX, -120 )
  	_place : addChild(node,1)
end

function Welkin_OnlyView.createPowerNum( self, _powerNum, num, _place)
	print( " ---改变战力值--- " )

  	local power = string.format( "战力:%d", _powerNum )
  	local lab = _G.Util : createLabel( power, FONTSIZE )
  	lab : setColor( COLOR_GOLD )
  	lab : setPosition( _place:getContentSize().width/2, -40 )
  	_place : addChild( lab )
end

function Welkin_OnlyView.changeTitleText( self, _state )
	local teamID  = self.myGroupId
	if self.curTeamId ~= 0 then
		teamID = self.curTeamId
	end
	if teamID == 0 or teamID == nil then
		teamID = 1
	end
	local myTitle = { [_G.Const.CONST_TXDY_SUPER_STATE_GROUP] = string.format( "小组赛—第%d组", teamID ),
					  [_G.Const.CONST_TXDY_SUPER_STATE_FINAL] = "决赛",
					  [_G.Const.CONST_TXDY_SUPER_STATE_KING]  = "王者之战",
					  [_G.Const.CONST_TXDY_SUPER_STATE_OVER]  = "王者之战",
					 }
	self.myTitleText : setString( myTitle[_state] )
	if self.titleName2 ~= nil then
		local myText = { "-第一轮", "-第二轮", "-第三轮" }
		local name = nil
		if myText[self.myfight] ~= nil and _state == _G.Const.CONST_TXDY_SUPER_STATE_FINAL then
			name = myText[self.myfight]
		end
		local newname = myTitle[_state]
		if name ~= nil then
			newname = myTitle[_state]..name
		end
		self.titleName2  : setString( newname )
	end
	if _state == _G.Const.CONST_TXDY_SUPER_STATE_FINAL then
		self.Spr_juesai : setVisible( true )
	elseif _state == _G.Const.CONST_TXDY_SUPER_STATE_KING 
		or _state == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
		self.Spr_juesai : setVisible( false )
	end
end

function Welkin_OnlyView.changeBtn( self, isTrue )
	self.widget_OthRange : setVisible( not isTrue )
end

function Welkin_OnlyView.changeMyRange( self, isTrue )
	if isTrue then
		self.Btn_MyRange : setTouchEnabled( true )
		self.Btn_MyRange : setDefault()
	else
		self.Btn_MyRange : setTouchEnabled( false )
		self.Btn_MyRange : setGray()
	end
end

function Welkin_OnlyView.createGuessView( self, _ackMsg )
	if self.myZBView~=nil or not self.isDown or not self.isDown.rmb then return end

	local frameSize=cc.size(520,370)
	local msg 		= _ackMsg
	self.myZBView  = require( "mod.general.BattleMsgView"  )()
  	local ZB_D2Base = self.myZBView : create("欢乐竞猜",frameSize,1)
  	local myWidth   = self.myZBView : getSize().width
  	local myHeight  = self.myZBView : getSize().height

  	local myNode = cc.Node : create()
  	ZB_D2Base : addChild( myNode )

  	local function addclose( )
  		if self.isCreate2 ~= nil then
  			self.isCreate2 = nil
  		end
  		if self.Lab_Money ~= nil then
  			self.Lab_Money = nil
  		end
  		if self.choose1 ~= nil then
  			self.choose1 = nil
  		end
  		if self.choose2 ~= nil then
  			self.choose2 = nil
  		end
  		if self.myZBView~=nil then
  			self.myZBView=nil
  		end
  	end
  	self.myZBView : addCloseFun( addclose )

  	local currentRMB  = _G.Util : createLabel("请选择竞猜的冠军和亚军选手",FONTSIZE)
	currentRMB        : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	currentRMB        : setPosition(cc.p(myWidth/2,myHeight-70))
	ZB_D2Base         : addChild(currentRMB)

  	local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  	line1  : setPreferredSize( cc.size( myWidth - 40, 2 ) )
  	line1  : setPosition( myWidth/2, myHeight-90 )
  	myNode : addChild( line1 )

  	local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  	line2  : setPreferredSize( cc.size( myWidth - 40, 2 ) )
  	line2  : setPosition( myWidth/2, 40 )
  	myNode : addChild( line2 )

  	local function buttonCallBack( obj, evenType )
  		self : touchEventCallBack( obj, evenType )
  	end

  	self.Lab_name   	= {}
  	self.Btn_myChoose	= {}
  	local width_2 		= myWidth/2 - 190 
  	local text 			= { "冠军:", "亚军:" }
  	for i=1,2 do
  		local lab1 	= _G.Util : createLabel( text[i], 20 )
  		lab1	   	: setAnchorPoint( 0, 0.5 )
  		lab1 	   	: setPosition( width_2, myHeight/2+55- 60*(i-1) )
  		-- lab1	   	: setColor( COLOR_GOLD )
  		myNode 		: addChild( lab1 )

  		local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
  		spr 	  : setPreferredSize( cc.size( 210, 30 ) )
  		spr 	  : setPosition( myWidth/2-25, myHeight/2+55- 60*(i-1) )
  		myNode 	  : addChild( spr, 1 )

  		local lab_name 	= _G.Util : createLabel( "请选择玩家", 20 )
  		lab_name 	   	: setPosition( myWidth/2-25, myHeight/2+55 - 60*(i-1) )
  		lab_name	   	: setColor( COLOR_WHITE )
  		myNode 		    : addChild( lab_name, 3 )
  		self.Lab_name[i]= lab_name

  		local btn = gc.CButton : create()
  		btn : setAnchorPoint( 0, 0.5 )
  		btn : loadTextures( "general_btn_gold.png" )
  		btn : setPosition(  myWidth/2+100, myHeight/2+55- 60*(i-1)-2 )
  		btn : setTag( Tag_Btn_Choose[i] )
		btn : addTouchEventListener( buttonCallBack )
		btn : setTitleFontName( heiti )
	    btn : setTitleText( "选 择" )
	    -- btn : setButtonScale( 0.8 )
	    btn : setTitleFontSize( FONTSIZE+4 )
	    btn : setTouchEnabled( false )
	    btn : setGray()
	    myNode : addChild( btn, 3 )
	    self.Btn_myChoose[i] = btn
  	end

  	local lab = _G.Util : createLabel( "100元宝",FONTSIZE )
  	lab : setPosition( myWidth/2, 125 )
  	-- lab : setColor( COLOR_GOLD )
  	myNode : addChild( lab )

  	local Btn_PutMoney 	= gc.CButton : create()
  	Btn_PutMoney 		: setPosition( myWidth/2, myHeight/2 - 90 )
  	-- Btn_PutMoney  		: setButtonScale( 0.8 )
  	Btn_PutMoney 		: loadTextures( "general_btn_lv.png" )
	Btn_PutMoney 		: setTag( Tag_Btn_PutMoney )
	Btn_PutMoney 		: addTouchEventListener( buttonCallBack )
	Btn_PutMoney 		: setTitleFontName( heiti )
    Btn_PutMoney 		: setTitleText( "投 注" )
    -- Btn_PutMoney 		: enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    Btn_PutMoney 		: setTitleFontSize( FONTSIZE+4 )
    myNode 				: addChild( Btn_PutMoney, 3 )
    self.Btn_PutMoney   = Btn_PutMoney

    self.isCreate2 = true
    self : checkDown()

    if self.over then
    	Btn_PutMoney : setTouchEnabled(false)
    	Btn_PutMoney : setGray()
    	for i=1,2 do
    		self.Btn_myChoose[i] : setTouchEnabled( false )
    		self.Btn_myChoose[i] : setGray()
    	end
    end

    local lab = _G.Util : createLabel( "投注时间：初赛结束-决赛开始，投注后不可更改选手名单",FONTSIZE-2 )
  	lab : setPosition( myWidth/2, 20 )
  	lab : setColor( COLOR_ORED )
  	myNode : addChild( lab )

end

function Welkin_OnlyView.checkDown( self )
	if self.isDown ~= nil then
		print( "self.isDown = ", self.isDown, self.isDown.state, self.isDown.uid_1, self.isDown.name_1, self.isDown.uid_2, self.isDown.name_2  )
		if self.Btn_myChoose ~= nil then
			if self.isDown.state == 0 then
				self.Btn_myChoose[1] : setDefault()
				self.Btn_myChoose[1] : setTouchEnabled( true )
				self.Btn_myChoose[2] : setDefault()
				self.Btn_myChoose[2] : setTouchEnabled( true )
			else
				local num1 = false
				local num2 = false
				if self.isDown.uid_1 ~= 0 and self.isDown.name_1 ~= nil then
					self.Btn_myChoose[1] : setGray()
					self.Btn_myChoose[1] : setTouchEnabled( false )
					self.Lab_name[1] 	 : setString( self.isDown.name_1 )
					num1 = true
				else
					self.Btn_myChoose[1] : setDefault()
					self.Btn_myChoose[1] : setTouchEnabled( true )
				end 
				if self.isDown.uid_2 ~= 0 and self.isDown.name_2 ~= nil then
					self.Btn_myChoose[2] : setGray()
					self.Btn_myChoose[2] : setTouchEnabled( false )
					self.Lab_name[2] 	 : setString( self.isDown.name_2 )
					num2 = true
				else
					self.Btn_myChoose[2] : setDefault()
					self.Btn_myChoose[2] : setTouchEnabled( true )
				end 
				if num1 and num2 then
					self.Btn_PutMoney : setTouchEnabled( false )
					self.Btn_PutMoney : setGray()
				end
			end
		end
	end
end

function Welkin_OnlyView.createChooseView( self, _myChoose )
	print( "进入！！" )
	if cc.Director : getInstance() : getRunningScene() : getChildByTag(999) ~= nil 
		or not self.AllPeople 
		or self.AllPeople.count == 0 then
		return
	end
	local myText 	= { "冠军人选", "亚军人选" }
	local frameSize=cc.size(618,485)
	local combatView  = require("mod.general.BattleMsgView")()
  	self.combatBG = combatView : create(myText[_myChoose],frameSize)
  	self.m_mainSize = combatView : getSize()

  	local myWidth   = self.m_mainSize.width
  	local myHeight  = self.m_mainSize.height

  	local text  = { "玩 家", "服务器", "等 级" , "战 力" }
  	local color = { COLOR_GRASSGREEN, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE } 
  	for i=1,4 do
  		local lab = _G.Util : createLabel( text[i], 20 )
  		-- lab 	  : setColor( COLOR_WHITE )
  		-- lab 	  : setAnchorPoint( 0.5, 1 )
  		lab 	  : setPosition( -50+i*125, myHeight-70 )
  		if i==4 then lab : setPosition( 400, myHeight-70 ) end
  		self.combatBG 	  : addChild( lab, 1 )
  	end

  	local floorSize=cc.size(myWidth-4,myHeight-90)
  	local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
  	floorSpr:setPreferredSize(floorSize)
  	floorSpr:setPosition(myWidth/2,myHeight/2-42)
  	self.combatBG:addChild(floorSpr)

  	if self.AllPeople ~= nil then  		
  		local function sort( data1, data2 )
	        return data1.powerful > data2.powerful 
	    end
	    table.sort(self.AllPeople, sort )

		local AllPeople = self.AllPeople
	  	local count = AllPeople.count
	  	print( "冠军人选数量：", count )

	 	local viewSize      = cc.size( floorSize.width, floorSize.height-5)
	 	local ScrollHeigh   = viewSize.height/6
	  	local containerSize = cc.size( floorSize.width, count*ScrollHeigh)
	  	local ScrollView  	= cc.ScrollView : create()
	  	ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
	  	ScrollView  : setViewSize(viewSize)
	  	ScrollView  : setContentSize(containerSize)
	  	ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
	  	ScrollView  : setPosition(cc.p(0, 2))
	  	ScrollView  : setAnchorPoint( 0, 0 )
	  	ScrollView  : setBounceable(true)
	  	ScrollView  : setTouchEnabled(true)
	  	ScrollView  : setDelegate()
	  	floorSpr		: addChild( ScrollView, 3 )

	  	local barView = require("mod.general.ScrollBar")(ScrollView)
	  	barView     : setPosOff(cc.p(-6,0))
	  	-- barView     : setMoveHeightOff(-5)

	  	local function myCallBack( obj, touchEvent )
	  		local Position  = obj : getWorldPosition()
	  		print("Position.y",Position.y)
	      	if Position.y > 445 or Position.y < 97 then 
	         	return 
	      	end
	  		local tag  = obj : getTag()
		  	if touchEvent == ccui.TouchEventType.ended then
		  		print( "按下：", tag )
		  		if _myChoose == 1 then
		  			self.choose1 = self.AllPeople[tag].uid
		  		else
		  			self.choose2 = self.AllPeople[tag].uid
		  		end
		  		self : changeMyChoose( _myChoose ,tag )
		  		combatView:delayCallFun()
		  	end
	  	end

	  	local PosX = { 73, 198, 323, 400, 512 }
	  	local gap = 31
	  	local serverNameLabel={}
	  	local sids={}
	  	for i=1,count do
  			local lab1 = _G.Util : createLabel( AllPeople[i].name, FONTSIZE )
  			lab1	   : setPosition( PosX[1], count*ScrollHeigh - (i-1)*ScrollHeigh - gap )
  			lab1  	   : setColor( COLOR_GRASSGREEN )
  			ScrollView : addChild( lab1, 3 )

  			sids[i]=AllPeople[i].sid
  			local lab2 = _G.Util : createLabel( "", FONTSIZE )
  			lab2	   : setPosition( PosX[2], count*ScrollHeigh - (i-1)*ScrollHeigh - gap )
  			lab2  	   : setColor( COLOR_WHITE )
  			ScrollView : addChild( lab2, 3 )
  			serverNameLabel[i]=lab2

  			local lab3 = _G.Util : createLabel(AllPeople[i].lv, FONTSIZE )
  			lab3	   : setPosition( PosX[3], count*ScrollHeigh - (i-1)*ScrollHeigh - gap )
  			lab3  	   : setColor( COLOR_WHITE )
  			ScrollView : addChild( lab3, 3 )

  			local lab4 = _G.Util : createLabel( AllPeople[i].powerful, FONTSIZE )
  			lab4	   : setPosition( PosX[4], count*ScrollHeigh - (i-1)*ScrollHeigh - gap )
  			lab4  	   : setColor( COLOR_WHITE )
  			ScrollView : addChild( lab4, 3 )

  			local btn 	= gc.CButton : create()
		  	btn 		: setPosition( PosX[5], count*ScrollHeigh - (i-1)*ScrollHeigh - gap-2 )
		  	-- btn  		: setButtonScale( 0.8 )
		  	btn 		: loadTextures( "general_btn_gold.png" )
			btn 		: setTag( i )
			btn 		: addTouchEventListener( myCallBack )
			btn 		: setTitleFontName( heiti )
		    btn 		: setTitleText( "选 择" )
		    btn 		: setTitleFontSize( FONTSIZE+4 )
		    ScrollView 	: addChild( btn, 3 )

		    local spr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" )
		    spr 	  : setPreferredSize( cc.size( myWidth-15, 60 ) )
		    spr 	  : setAnchorPoint( 0, 0.5 )
		    spr 	  : setPosition( 5, count*ScrollHeigh - (i-1)*ScrollHeigh - gap-2 )
		    ScrollView: addChild( spr )
	  	end

	  	local function nFun(_data)
	  		if not tolua.isnull(ScrollView) then
	  			local nameArray=_data or {}
	  			for i=1,#serverNameLabel do
	  				local serverName=nameArray[sids[i]] or "nil"
	  				serverNameLabel[i]:setString(string.format("%s%s%s","【", serverName, "服】"))
	  			end
	  		end
	  	end

		_G.Util:getServerNameArray(sids,nFun)
	end
end

function Welkin_OnlyView.changeMyChoose( self, _myChoose, num )
	self.Lab_name[_myChoose] : setString( self.AllPeople[num].name )
end

function Welkin_OnlyView.changeGroupChoose( self, myGroup )
	if myGroup ~= 0 then
		self : changeMyRange( true  )
	else
		self : changeMyRange( false )
	end
end

function Welkin_OnlyView.MessageBox( self )
	local function tipsSure()
    	print( "投注的UID：", self.choose1, self.choose2 )
        self : REQ_TXDY_SUPER_GUESS_BET( self.choose1, self.choose2 )
  	end
  	local function cancel()
    
  	end

  	local tipsBox = require("mod.general.TipsBox")()
 	local layer   = tipsBox :create( "", tipsSure, cancel)
  	-- layer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
  	cc.Director:getInstance():getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
  	tipsBox : setTitleLabel("提 示")

  	local layer=tipsBox:getMainlayer()
  	local width  = 0
    local myWighet = ccui.Widget:create()

    local Lab_1 = _G.Util : createLabel( "花费", FONTSIZE)
    Lab_1 : setAnchorPoint( 0, 0.5 )
    Lab_1 : setPosition( width, 30 )
    myWighet : addChild( Lab_1 )
    width = width + Lab_1 : getContentSize().width

    local money = _G.Const.CONST_TXDY_SUPER_PEBBLE_ONCE
    local Lab_2 = _G.Util : createLabel( money, FONTSIZE)
    Lab_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
    Lab_2 : setAnchorPoint( 0, 0.5 )
    Lab_2 : setPosition( width, 30 )
    myWighet : addChild( Lab_2 )
    width = width + Lab_2 : getContentSize().width

    local Lab_3 = _G.Util : createLabel( "元宝投注么？", FONTSIZE )
    Lab_3 : setAnchorPoint( 0, 0.5 )
    Lab_3 : setPosition( width, 30 )
    myWighet : addChild( Lab_3 )
    width = width + Lab_3 : getContentSize().width

    myWighet : setContentSize( cc.size( width, 0 ) )
    layer  : addChild( myWighet )
end

function Welkin_OnlyView.showTime( self, _ackMsg )
	print( "进入showTime" )
	local function changePosx( which, _type )
		local posY = which : getPositionY()
		print( "posY", posY )
		if _type == 1 then 
			which : setAnchorPoint( 0.5, 0 )
			if which == self.Lab_TimeName then
				which : setPosition( 0, posY )
			else
				which : setPosition( 0, posY )
			end
		else
			which : setAnchorPoint( 1, 0 )
			if which == self.Lab_TimeName then
				which : setPosition( 20, posY )
			else
				which : setPosition( 20, posY )
			end
		end
	end

	local msg = _ackMsg
	if msg.state == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
		self.Lab_TimeName : setString( "比赛全部结束！" )
		self.LefTime : setVisible( false )

		self : changSprMid( 2 )
		changePosx( self.Lab_TimeName, 1 )
		-- self.midlab : setVisible( false )
		self.midBtn : setVisible( false )
		if self.Lab_TimeName2 ~= nil then
			self.Lab_TimeName2 : setString( "比赛全部结束！" )
			self.LefTime2 : setVisible( false )
			changePosx( self.Lab_TimeName2, 1 )
		end

		self.Btn_MyRange : setGray()
		self.Btn_MyRange : setTouchEnabled( false )
	elseif msg.state == _G.Const.CONST_TXDY_SUPER_STATE_GROUP_OVER then
		print( "决赛未开始！--------" )
		self.Spr_juesai   : setVisible( true )
		self.Lab_TimeName : setString( "决赛未开始！" )
		self.LefTime : setVisible( false )

		self : changSprMid( 0 )
		changePosx( self.Lab_TimeName, 1 )
		-- self.midlab : setVisible( false )
		self.midBtn : setVisible( false )
		if self.Lab_TimeName2 ~= nil then
			self.Lab_TimeName2 : setString( "决赛未开始！" )
			self.LefTime2 : setVisible( false )
			changePosx( self.Lab_TimeName2, 1 )
		end

		self.Btn_MyRange : setGray()
		self.Btn_MyRange : setTouchEnabled( false )
	else
		self : changSprMid( 0 )
		-- self.midlab : setVisible( false )
		self.midBtn : setVisible( false )
		changePosx( self.Lab_TimeName, 2 )
		if msg.state2 == 1 then
			self.Lab_TimeName : setString( "下轮开始时间：" )
			self.LefTime : setVisible( true )
			if self.Lab_TimeName2 ~= nil then
				self.Lab_TimeName2 : setString( "下轮开始时间" )
				self.LefTime2 : setVisible( true )
				changePosx( self.Lab_TimeName2, 2 )
			end
		else
			self.Lab_TimeName : setString( "本轮结束时间：" )
			self.LefTime : setVisible( true )
			if self.Lab_TimeName2 ~= nil then
				self.Lab_TimeName2 : setString( "本轮结束时间" )
				self.LefTime2 : setVisible( true )
				changePosx( self.Lab_TimeName2, 2 )
			end
		end

		-- 王者之战
		if msg.state == _G.Const.CONST_TXDY_SUPER_STATE_KING then
			-- self.midlab : setVisible( true )
			self.midBtn : setVisible( true )
			self.over   = true
			self.Btn_MyRange : setGray()
			self.Btn_MyRange : setTouchEnabled( false )
		elseif msg.state == _G.Const.CONST_TXDY_SUPER_STATE_FINAL then
			self.over = true
		end

		if msg.time ~= 0  then
			local time = msg.time

			local function step1( )
				local nowTime  	= _G.TimeUtil:getServerTimeSeconds()
				local myTime 	= time - nowTime
				print( "定时器在运行!", myTime )
				local nowTime_str = self:_getTimeStr( myTime )
				self.LefTime : setString( nowTime_str )
				if self.LefTime2 ~= nil then
					self.LefTime2 : setString( nowTime_str )
				end
				print( "msg.state2 = ", msg.state2 )
				if myTime <= 0 then
					if self.Scheduler ~= nil then 
		 				_G.Scheduler : unschedule( self.Scheduler )
		 				self.Scheduler = nil
		 			end
		 			self : REQ_TXDY_SUPER_REQUEST( self.curTeamId or 0 )
		 			if cc.Director : getInstance() : getRunningScene() : getChildByTag(888) == nil then return end
		 			if self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_KING then
		 				print( "请求王者之战" )
		 				self : REQ_TXDY_SUPER_REQUEST_KING()
		 			else
		 				print( "请求我的小组" )
		 				self : REQ_TXDY_SUPER_REQUEST_MY_GAME()
		 			end
		 			return 
				end
			end
			
			if self.Scheduler==nil then 
				self.Scheduler = _G.Scheduler : schedule(step1, 1)
			end
		end
	end

	self.Spr_mid2 : setVisible( true )
	print( " xxxxxx msg.time =  ", msg.time )
	if msg.time == 0 then
		print( "  msg.time == 0  " )
		self.Spr_mid2 : setVisible( false )
		self.Lab_TimeName : setString( "小组赛未开始！" )

		if self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_GROUP_OVER then
			self.Spr_juesai : setVisible( true )
			self.Lab_TimeName : setString( "决赛未开始！" )
		elseif self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
			self.Lab_TimeName : setString( "本次比赛全部结束！" )
			-- self.midlab : setVisible( true )
			self.midBtn : setVisible( true )
			self.over = true
		end

		changePosx( self.Lab_TimeName, 1 )

		self.Btn_MyRange : setGray()
		self.Btn_MyRange : setTouchEnabled( false )
	end

end

function Welkin_OnlyView.changSprMid( self, _type )
	local spr = { "ui_xiaozu.png", "bazhu.png" }
	if _type == 0 then
		self.Spr_mid : setVisible( false )
		return
	elseif _type == 1 then
		self.Spr_mid : setVisible( true )
	elseif _type == 2 then
		self.Spr_mid : setVisible( true )
	end
	self.Spr_mid : setSpriteFrame( spr[_type] )
end

function Welkin_OnlyView.createMidWidget( self )
	print( "进入创建 MidWidget " )
	local function buttonCallBack( obj, touchEvent )
		self : touchEventCallBack( obj, touchEvent )
	end
	if self.myMidWighet ~= nil then
		self.myMidWighet : removeFromParent()
		self.myMidWighet = nil
	end
	self.myMidWighet   	= ccui.Widget : create()
	self.myMidWighet   	: setContentSize( cc.size( 142, 100 ) )
	self.myMidWighet 	: setTouchEnabled( true )
	self.myMidWighet 	: setTag( Tag_MidWidget )
	self.myMidWighet 	: addTouchEventListener( buttonCallBack )
	self.mainContainer 	: addChild( self.myMidWighet )
end

function Welkin_OnlyView.checkMidWidget( self )
 	if self.myMidWighet ~= nil then
		self.myMidWighet : removeFromParent()
		self.myMidWighet = nil
	end
end 

function Welkin_OnlyView.Net_SUPER_TIME( self, _ackMsg )
	local msg 		= _ackMsg
	self.myfight 	= msg.turn
	local nowTime  	= _G.TimeUtil:getServerTimeSeconds()
	local myTime 	= msg.time - nowTime
	print( "  比赛状态： ", msg.state )
	print( "  状态（1.下一轮开始时间，2.本轮结束时间）: ", msg.state2 )
	print( "  时间： ", myTime, msg.time )
	print( "  轮次： ", msg.turn )
	self.myNowState = msg.state
	self.state2 = msg.state2 

	self : showTime( msg )

end

-- 55020
function Welkin_OnlyView.REQ_TXDY_SUPER_REQUEST( self, _myType )
	self.curTeamId = _myType
	local msg = REQ_TXDY_SUPER_REQUEST()
	msg : setArgs( _myType )
	_G.Network : send( msg )
end

function Welkin_OnlyView.Net_SUPER_REPLY( self, _ackMsg )
	local msg = _ackMsg
	print( "	当前比赛状态(选择)：	", msg.state )
	self.myNowState = msg.state

	if msg.state == _G.Const.CONST_TXDY_SUPER_STATE_GROUP then
    	print( "返回的是小组赛" )
    	print( "  组别： ", msg.msg_xxx.group_id 	)
    	print( "  轮次： ", msg.msg_xxx.turn 		)
    	print( "  数量： ", msg.msg_xxx.count, "\n" 	)
    	local msg = msg.msg_xxx

		local function sort( data1, data2 )
	        return data1.index < data2.index 
	    end
	    table.sort( msg.msg_xxx, sort )
		for i=1,msg.count do
			print( "	索引			:",	msg.msg_xxx[i].	index			)
			print( "	玩家ID		:",	msg.msg_xxx[i].	uid				)
			print( "	玩家名字		:",	msg.msg_xxx[i].	name			)
			print( "	职业			:",	msg.msg_xxx[i].	pro				)
			print( "	战斗力		:",	msg.msg_xxx[i].	powerful		)
			print( "	服务器ID		:",	msg.msg_xxx[i].	sid				)
			print( "	是否失败过	:",	msg.msg_xxx[i].	is_fail			)
			print( "	失败轮次		:",	msg.msg_xxx[i].	fail_turn, "\n"	)
		end

		if self.isCreate  == nil then
			self.isCreate  = true
			self.myGroupId = msg.group_id
		end

		print( "小组赛创建！" )
		if self.state2 == 1 or self.FirstIn == nil or self.myChangeTag then
			self.FirstIn2 = nil
			-- self.myChangeTag = nil
			if self.myNode ~= nil then
				self.myNode : removeFromParent()
				self.myNode = cc.Node : create()
				self.mainContainer : addChild( self.myNode, 5 )
			end
			print( "划线~开始！" )
			self : createGroupText( msg.count, msg.msg_xxx )
			self.FirstIn = true
			print( "划线~结束！", self.FirstIn )
		end

    	self : changeTitleText(self.myNowState)
    	
    elseif  msg.state == _G.Const.CONST_TXDY_SUPER_STATE_FINAL or 
    		msg.state == _G.Const.CONST_TXDY_SUPER_STATE_GROUP_OVER or 
     	   	msg.state == _G.Const.CONST_TXDY_SUPER_STATE_KING or
			msg.state == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
        print( "返回的是决赛 or 王者争霸", msg.state )
        print( "  轮次： ", msg.msg_xxx.turn )
    	print( "  数量： ", msg.msg_xxx.count, "\n" )
    	local msg = msg.msg_xxx
		local function sort( data1, data2 )
	        return data1.index < data2.index 
	    end
	    table.sort( msg.msg_xxx2, sort )
	    local myUid = _G.GPropertyProxy : getMainPlay() : getUid()
	    print( "我的UID：", myUid )
	    local ImIn  = false 
		for i=1,msg.count do
			print( "	索引			:",	msg.msg_xxx2[i].index			)
			print( "	玩家ID		:",	msg.msg_xxx2[i].uid				)
			print( "	玩家名字		:",	msg.msg_xxx2[i].name			)
			print( "	职业			:",	msg.msg_xxx2[i].pro				)
			print( "	战斗力		:",	msg.msg_xxx2[i].powerful		)
			print( "	服务器ID		:",	msg.msg_xxx2[i].sid				)
			print( "	是否失败过	:",	msg.msg_xxx2[i].is_fail			)
			print( "	失败轮次		:",	msg.msg_xxx2[i].fail_turn, "\n"	)
			if msg.msg_xxx2[i].uid == myUid then
				ImIn = true
			end
		end

		if ImIn then
			if self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_OVER 
    		or self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_GROUP_OVER  then
	    		print( "在这里" )
	    		self : changeMyRange( false )
	    	else
	    		self : changeMyRange(true)
	    	end	
		else
			self : changeMyRange(false)
		end

		local nowIn = false
		if self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_KING or
		   self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
			nowIn = true
			self.FirstIn2 = true
		end
		print( "nowIn = ", nowIn )
		-- if self.FirstIn2 == nil and 
		if nowIn or self.state2 == 1 or self.FirstIn2 == nil or self.myChangeTag then
			self.FirstIn = nil
			self.myChangeTag = nil
			if self.myNode ~= nil then
				print( "正在移除!" )
				self.myNode : removeFromParent()
				self.myNode = nil
				self.myNode = cc.Node : create()
				self.mainContainer : addChild( self.myNode, 5 )
			end
			self : createGroupText( msg.count, msg.msg_xxx2 )
			self.FirstIn2 = true
		end

		print( "绝赛创建！" )
		self.AllPeople = msg.msg_xxx2
		self.AllPeople.count = msg.count
    	self : changeTitleText(self.myNowState)
    	self : changeBtn( true )
  
    else
    	print( "判断出错！！", msg.state )
    end
end

function Welkin_OnlyView.REQ_TXDY_SUPER_GUESS_BET_REQ( self )
	local msg = REQ_TXDY_SUPER_GUESS_BET_REQ()
	_G.Network : send( msg )
end

function Welkin_OnlyView.Net_GUESS_TOTAL( self, _Money )
	print( "总下注元宝数：", _Money )
	self.AllMoney = _Money
	if self.Lab_Money ~= nil then
		self.Lab_Money : setString( string.format("%d",_Money) )
	end
	-- self : createGuessView( self.myMsg )
end

-- 55080
function Welkin_OnlyView.REQ_TXDY_SUPER_GUESS_BET( self, uid_1, uid_2 )
	local msg = REQ_TXDY_SUPER_GUESS_BET()
	msg : setArgs( uid_1, uid_2 )
	_G.Network : send( msg )
end

function Welkin_OnlyView.Net_GUESS_BET_REPLY( self, _ackMsg )
	local msg = _ackMsg
	print("	状态(0未下过注,1已下过注)	:",	msg.state	)
	print("	冠军uid			:",	msg.uid_1	)
	print("	冠军名字			:",	msg.name_1	)
	print("	亚军uid			:",	msg.uid_2	)
	print("	亚军名字			:",	msg.name_2	)
	print("	已经下注元宝数	:",	msg.rmb		)
	self.isDown = msg

	if self.isCreate2 ~= nil then
		self : checkDown()
	end
end

function Welkin_OnlyView.REQ_TXDY_SUPER_REQUEST_GUESS( self )
	local msg = REQ_TXDY_SUPER_REQUEST_GUESS()
	_G.Network : send( msg )
end

function Welkin_OnlyView.Net_SUPER_REPLY_GUESS( self, _ackMsg )
	local msg  = _ackMsg
	print( "	数量：	", msg.count )
	local data = msg.msg_guess_xxx 
	for i=1,msg.count do
		print( "   	名次		： 	", data[i].rank 	)
		print( " 	玩家ID	： 	", data[i].uid 		)
		print( " 	玩家名字 ： 	", data[i].name 	)
		print( "	服务器ID	： 	", data[i].sid 		)
		print( " 获得元宝数量	： 	", data[i].pebble 	)
	end
	self.myMsg = msg
	self : createGuessView( self.myMsg )
end

-- 55010
function Welkin_OnlyView.REQ_TXDY_SUPER_REQUEST_MY_GAME( self )
	local msg  = REQ_TXDY_SUPER_REQUEST_MY_GAME()
	_G.Network : send( msg )
end

function Welkin_OnlyView.Net_REPLY_MY_GAME( self, _ackMsg )
	local msg = _ackMsg
	print("	我的SID 			:", msg.sid_mind)
	print("	对方玩家ID		:",	msg.uid		)
	print("	对方玩家名字		:",	msg.name	)
	print("	对方玩家等级		:",	msg.lv		)
	print("	对方玩家职业		:",	msg.pro		)
	print("	对方玩家服务器id	:",	msg.sid		)
	print("	对方玩家战斗力	:",	msg.powerful)
	self : createRange( 2, msg )
end

function Welkin_OnlyView.REQ_TXDY_SUPER_REQUEST_KING( self )
	local msg = REQ_TXDY_SUPER_REQUEST_KING()
	_G.Network : send( msg )
end

function Welkin_OnlyView.Net_REPLY_KING( self, _ackMsg )
	local msg = _ackMsg
	print("	位置(1左边，2右边)	:",	msg.pos	)
	print("	玩家id	:",	msg.uid	)
	print("	名字		:",	msg.name	)
	print("	等级		:",	msg.lv	)
	print("	职业		:",	msg.pro	)
	print("	服务器id	:",	msg.sid	)
	print("	玩家战斗力	:",	msg.power	)
	print("	排名 1为冠军 2为亚军 0未分胜负	:",	msg.rank	)
	print(" 数量  		:", msg.count 	)
	for i=1,msg.count do
		print("	结果(1赢 0输):",	msg.msg_result[i].flag	)
	end
	
	self.repickTimes = self.repickTimes + 1

	if self.KingMsg == nil then
		self.KingMsg = {}
	end
	self.KingMsg[self.repickTimes] = msg
	if self.repickTimes >= 2 then
		local msg = {}
		msg.left  = self.KingMsg[1]
		msg.right = self.KingMsg[2]
		self : createRange( 3, msg )
		self.repickTimes = 0
	end
end

function Welkin_OnlyView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print(" 按下 ", tag 	)
	elseif touchEvent == ccui.TouchEventType.moved then
		print(" 移动 ", tag 	)
  	elseif touchEvent == ccui.TouchEventType.ended then
  		print(" 抬起 ", tag 	)	
  		if tag == Tag_widget_OthRange then
  			self : createRange( 1 )
  		elseif tag == Tag_Btn_Guess then
  			self : REQ_TXDY_SUPER_GUESS_BET_REQ()
  			self : REQ_TXDY_SUPER_REQUEST_GUESS()
  		elseif tag == Tag_Btn_MyRange then
  			self : REQ_TXDY_SUPER_REQUEST_MY_GAME()
  		elseif tag == Tag_Btn_Explain then
  			local explainView  = require("mod.general.ExplainView")()
            local explainLayer = explainView : create(40221,true)
        elseif tag == Tag_Btn_Choose[1] or tag == Tag_Btn_Choose[2] then
        	self : createChooseView( tag - 1004 )
        elseif tag >=100+1 and tag <= 100+16 then
        -- 16个组切换
        	self.myChangeTag = true
        	self : REQ_TXDY_SUPER_REQUEST( tag-100 )
       		self : OthClose()
        elseif tag == Tag_Btn_PutMoney then
        	if self.choose1 ~= nil and self.choose2 ~= nil then
        		self : MessageBox()
        	else
        		local command = CErrorBoxCommand(38130)
             	controller :sendCommand( command )
        	end
        elseif tag == Tag_MidBtn then
        	if self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_KING or
        	   self.myNowState == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
        		self : REQ_TXDY_SUPER_REQUEST_KING()
        	end
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ", tag )
  	end
end

function Welkin_OnlyView.closeWindow( self )
	print( "开始关闭" )
	if self.Scheduler ~= nil then 
 		_G.Scheduler : unschedule( self.Scheduler )
 		self.Scheduler = nil
 	end

 	ScenesManger.releaseFileArray(self.m_resourcesArray)

	self.m_mediator : destroy()
	self.m_mediator = nil
	cc.Director : getInstance() : popScene()

	-- print("资源清理完毕~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
 --    print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo().."\n")
end

return Welkin_OnlyView