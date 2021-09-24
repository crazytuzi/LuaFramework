local SevenDayView = classGc( view, function( self, _openType )
	-- self.m_openType = _openType

	self.m_winSize  	= cc.Director:getInstance() : getWinSize()
	self.MyLogo 		= {}
	self.Send 		    = true

	self.m_mediator 	= require("mod.smodule.SevenDayMediator")() 
	self.m_mediator 	: setView(self)

	self.Day=1
end)

local FONTSIZE = 20
local rightSize        = cc.size(620,517)
local Tag_Spr_Logo     = { 101, 102, 103, 104, 105, 106, 107 }

function SevenDayView.create( self )
	self.m_settingView = require( "mod.general.TabLeftView" )()
	self.gamSetLabel   = self.m_settingView:create()
	self.m_settingView : setTitle( "开服七天礼" )

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.gamSetLabel)
	
	self:init()

	return tempScene
end

function SevenDayView.init( self )
	self : REQ_OPEN_DAY_REQUEST()
	self : initView()
end

function SevenDayView.initView( self )
	self.mainContainer 	= cc.Node : create()
	self.mainContainer 	: setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2 ) )
	self.gamSetLabel 	: addChild( self.mainContainer )

	local function closeFunSetting()
		self:closeWindow()
	end
	self.m_settingView  : addCloseFun( closeFunSetting )

	local function tabOfFun(obj, eventType)
		if eventType == ccui.TouchEventType.ended then 
			local tag = obj:getTag()
			self : tabOperate(tag)
		end
	end

	local Text_Day = { "等级夺礼", "坐骑比拼", "竞技之争", "饰品派送", "八卦斗法", "勇闯妖塔", "最强战力" }

	self.dayBtn = {}
	for i=1,7 do
		self.dayBtn[i] = ccui.Button:create("general_title_one.png","general_title_two.png","general_title_two.png",1)
		self.dayBtn[i] : setTitleText( Text_Day[i])
		self.dayBtn[i] : setTag( i )
		self.dayBtn[i] : setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
		self.dayBtn[i] : setTitleFontName( _G.FontName.Heiti )
		self.dayBtn[i] : setTitleFontSize( FONTSIZE + 4 )
		self.dayBtn[i] : setPosition(-315, 245-i*72 )
		self.dayBtn[i] : addTouchEventListener( tabOfFun )
		self.mainContainer : addChild( self.dayBtn[i] )
	end
	self.m_settingView : addTabFun(tabOfFun)
	self.dayBtn[1] : setTouchEnabled(false)
	self.dayBtn[1] : setBright(false)
	self.dayBtn[1] : setPosition(-312, 173 )
	self.myNode 	 = {}
	self.Btn_Goods   = {}
	self.Spr_Btn_GoodsGet = {}

	local ScrollSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	ScrollSpr:setContentSize(cc.size(rightSize.width,rightSize.height-85))
	ScrollSpr:setPosition(110,-84)
	self.mainContainer:addChild(ScrollSpr)
end

function SevenDayView.selectTagByTag( self, _tag )
	for i=1,7 do
		if self.myNode[i] ~= nil then
			self.myNode[i] : setVisible( false )
		end
		if i==_tag then
			self.dayBtn[i] : setTouchEnabled(false)
			self.dayBtn[i] : setBright(false)
			self.dayBtn[i] : setPosition(-312, 245-i*72 )
		else
			self.dayBtn[i] : setTouchEnabled(true)
			self.dayBtn[i] : setBright(true)
			self.dayBtn[i] : setPosition(-315, 245-i*72 )
		end
	end

	if self.myNode[_tag] ~= nil then
		self.myNode[_tag] : setVisible( true )
	end
end

function SevenDayView.tabOperate( self, _tag )
	print( "_tag = ", _tag )
	self.Day = _tag
  	self : CreateRightView( _tag ) 
  	self : selectTagByTag(_tag)
end

function SevenDayView.closeWindow( self )
	print( "开始关闭" )
	if self.gamSetLabel == nil then return end
	self.gamSetLabel=nil
	cc.Director:getInstance():popScene()
	self:destroy()
end

function SevenDayView.CreateRightView( self, _day )
	if self.myNode[_day] == nil then
		self.myNode[_day] = cc.Node : create()
		self.myNode[_day] : setPosition( -200, -297 )
		self.mainContainer : addChild( self.myNode[_day], 1 )
		self : createJPG( _day )
		self : createRight( _day )
	end
	self : selectTagByTag(1)
end

function SevenDayView.createJPG( self, _day )
	local szImg		= string.format("ui/bg/seven_activity%d.png",_day)
	local logoSpr 	= _G.ImageAsyncManager:createNormalSpr(szImg)
	logoSpr : setPosition(310, 470)
	self.myNode[_day]  :addChild(logoSpr,5)
end

function SevenDayView.CreateScrollView( self, day, good, count, state )
	local viewSize      = cc.size(rightSize.width,rightSize.height-93)
	local ScroHight     = viewSize.height/3
    local containerSize = cc.size( rightSize.width, count*ScroHight)
    local m_winSize   	= cc.Director:getInstance():getVisibleSize()
	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end

	local function cFun(sender, eventType)
		print( "－－－－－－－按了图片－－－－－－－－" )
		if eventType == ccui.TouchEventType.began then
        	self.myMove = sender : getWorldPosition().y
	    elseif eventType == ccui.TouchEventType.ended then
	        local posY = sender : getWorldPosition().y
	        local move = posY - self.myMove
	        print( "isMove = ", move, posY, self.myMove )
	        if move > 5 or move < -5 then
	            return
	        end

	        local role_tag  = sender : getTag()
	        local _pos  = sender : getWorldPosition()
	        print("－－－－选中role_tag:", role_tag)
	        print("－－－－Position.y",_pos.y)
	        if _pos.y > m_winSize.height/2+viewSize.height/2-40 or 
	        	_pos.y < m_winSize.height/2-rightSize.height/2-25 
	        	or role_tag <= 0 then return end
	        local temp = _G.TipsUtil:createById(role_tag,nil,_pos)
       		cc.Director:getInstance():getRunningScene():addChild(temp,1000)
	    end
	end

    print("初始化滚动框")
    local ScrollView    = cc.ScrollView : create()
    ScrollView	: setDirection(ccui.ScrollViewDir.vertical)
    ScrollView	: setViewSize(viewSize)
    ScrollView	: setContentSize(containerSize)
    ScrollView	: setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView	: setPosition(cc.p(0, 0))
    ScrollView	: setBounceable(true)
    ScrollView	: setTouchEnabled(true)
    ScrollView	: setDelegate()
    self.myNode[day]: addChild( ScrollView )
    
    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView 	  : setPosOff(cc.p(-5,0))
    -- barView 	  : setMoveHeightOff(-5)
    
    local Lab_Finish = {}
    local kuangSize = cc.size( rightSize.width-10, ScroHight-4)
    for i=1,count do
		local Spr_Kuang = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" )
		Spr_Kuang : setContentSize( kuangSize )
		Spr_Kuang : setPosition( cc.p( rightSize.width/2,(count-i)*ScroHight + ScroHight/2-1 ) )
		ScrollView	: addChild( Spr_Kuang )

		local Btn_Goods = gc.CButton : create()
		Btn_Goods : loadTextures( "general_btn_gold.png")
		Btn_Goods : setTitleText( "领 取" )
		Btn_Goods : setTitleFontName( _G.FontName.Heiti )
		--Btn_Goods : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
		Btn_Goods : setTitleFontSize( FONTSIZE+4 )
		Btn_Goods : setTag( i )
		Btn_Goods : addTouchEventListener( ButtonCallBack )
		Btn_Goods : setPosition( kuangSize.width-80, kuangSize.height/2-10 )
		Spr_Kuang : addChild( Btn_Goods )

		local Spr_Btn_GoodsGet = ccui.Scale9Sprite : createWithSpriteFrameName("main_already.png")
		Spr_Btn_GoodsGet : setVisible( false )
		Spr_Btn_GoodsGet : setPosition( kuangSize.width-80, kuangSize.height/2-10 )
		Spr_Kuang : addChild( Spr_Btn_GoodsGet )

		if self.Btn_Goods[day] == nil then
			self.Btn_Goods[day] = {}
		end
		self.Btn_Goods[day][i] = Btn_Goods
		if self.Spr_Btn_GoodsGet[day] == nil then
			self.Spr_Btn_GoodsGet[day] = {}
		end
		self.Spr_Btn_GoodsGet[day][i] = Spr_Btn_GoodsGet

		if state[i].state == 1 then 
			Btn_Goods : setTouchEnabled( false )
			Btn_Goods : setGray()
		elseif state[i].state == 3 then 
			Btn_Goods : setVisible( false )
			Spr_Btn_GoodsGet : setVisible( true )
		end

		local title = good[i].des2
		if (day == 3) or (i <= 3) then 
			title = good[i].des2..": "
		end
		local Lab_Good = _G.Util : createLabel( title, FONTSIZE )
		Lab_Good  : setAnchorPoint( cc.p( 0, 0.5 ) )
		Lab_Good  : setPosition( cc.p( 20, kuangSize.height-20  ) )
		-- Lab_Good  : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
		Spr_Kuang : addChild( Lab_Good )

		local NextLab = Lab_Good : getContentSize().width +30
		Lab_Finish[i] = _G.Util : createLabel( "", FONTSIZE )
		-- Lab_Finish[i] : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
		Lab_Finish[i] : setPosition( cc.p(NextLab, kuangSize.height-20 ) )
		Lab_Finish[i] : setAnchorPoint( cc.p(0, 0.5) )
		Spr_Kuang  : addChild( Lab_Finish[i] )

		if (i >= 4) and (day ~= 3) then 
			if state[i].state == 1 then
				Lab_Finish[i] : setString( "（未达成）" )
			else
				Lab_Finish[i] : setString( "（已达成）" )
			end
		end

		local Text_Ranking_1 = ""
		local MyText 		 = {}

		local whichCeng = 1
		local whichGuan = 0
		if self.Ranking ~= nil and self.Ranking[i] ~= nil and self.Ranking[i].fighter ~= 0 and self.Ranking[i].fighter ~= nil then
			whichCeng = math.floor( (self.Ranking[i].fighter-1) / 5 ) + 1
			whichGuan = self.Ranking[i].fighter - whichCeng*5 + 5
		end
	
		if (self.Ranking[i] ~= nil) and (i <= 3) then 
			Text_Ranking_1 = self.Ranking[i].name
			MyText = {   "等级: "..self.Ranking[i].lv.." ".."（经验: "..self.Ranking[i].exp.."）",
						 "（坐骑战力: "..self.Ranking[i].mount.."）",
						 "",
						 "（饰品战力: "..self.Ranking[i].equip.."）",
						 "（八卦战力: "..self.Ranking[i].baqi.."）" ,
						 "（锁妖塔第".._G.Lang.number_Chinese[whichCeng].."层 第"..whichGuan .."关）",
						 "（战力: "..self.Ranking[i].powerful.."）"  }
		elseif i <= 3 then 
			Text_Ranking_1 = "（暂无）"
			MyText[day] = " "
		else
			MyText[day] = " "
		end

		if (day == 3) and (self.Ranking[i] ~= nil) and (self.Ranking[i].name ~= nil) then 
			Text_Ranking_1 = self.Ranking[i].name
		elseif (day == 3) and ((self.Ranking == nil) or (self.Ranking[i] == nil) or (self.Ranking[i].name == nil)) then 
			Text_Ranking_1 = "（暂无）"
		end 

		local Lab_Ranking_1 = _G.Util : createLabel( Text_Ranking_1, FONTSIZE ) 
		Lab_Ranking_1 : setAnchorPoint( cc.p( 0, 0.5 ) )
		Lab_Ranking_1 : setPosition( cc.p( 150, kuangSize.height-20 ) )
		Lab_Ranking_1 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
		Spr_Kuang 	  : addChild( Lab_Ranking_1 )
		local Lab_Ranking_2 = _G.Util : createLabel( MyText[day], FONTSIZE )
		Lab_Ranking_2 : setAnchorPoint( cc.p( 0, 0.5 ) )
		Lab_Ranking_2 : setPosition( cc.p( 315, kuangSize.height-20 ) )
		-- Lab_Ranking_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
		Spr_Kuang 	  : addChild( Lab_Ranking_2 )

		print( "666666" )
		local goodId  	= good[i].reward	-- good =  _G.Cfg.achieve_must[ day ]
		for k,v in ipairs(goodId) do  		-- v -> 代表第几个 _G.Cfg.achieve_must[day][i].reward[k]
			local goodIcon = _G.Cfg.goods[v[1]]  
			print( "goods = ", v[1], "goodsId = ", goodIcon, "goodIcon.icon", goodIcon.icon, "goodIcon.name_color = ", goodIcon.name_color )
			local widget   = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tubiaokuan.png" )
			widget : setPosition( cc.p(60+(k-1)*115, 55) )
			Spr_Kuang   : addChild( widget )
			
			local Spr_Icon = _G.ImageAsyncManager:createGoodsBtn(goodIcon,cFun,v[1],v[2])
			Spr_Icon : setSwallowTouches( false )
			Spr_Icon : setPosition( 79/2, 79/2 )
			widget   : addChild( Spr_Icon, 2 ) 
		end
	end
end

function SevenDayView.createRight( self, _day)
	self : REQ_OPEN_RANK_REQUEST( _day )
	self : REQ_OPEN_REQUEST( _day )
	
	if self.Send == true then 
		self : REQ_OPEN_ICON_TIME()
		self.Send = false
	end
end

function SevenDayView.changeBtn( self, _day, _num, _state )
	print( "改变按钮：", _day, _num, _state )
	local Btn_Goods = self.Btn_Goods[_day][_num]
	local Spr_Btn_GoodsGet = self.Spr_Btn_GoodsGet[_day][_num]
	if _state == 1 then 
		Btn_Goods : setTouchEnabled( false )
		Btn_Goods : setGray()
		Spr_Btn_GoodsGet : setVisible( false )
	elseif _state == 2 then 
		Btn_Goods : setTouchEnabled( true )
		Btn_Goods : setDefault()
		Spr_Btn_GoodsGet : setVisible( false )
	elseif _state == 3 then 
		Btn_Goods : setVisible( false )
		Spr_Btn_GoodsGet : setVisible( true )
	end
end

-- 协议开始
function SevenDayView.REQ_OPEN_ICON_TIME( self )
	local msg = REQ_OPEN_ICON_TIME()
	_G.Network : send( msg )
end

function SevenDayView.Net_Open_Allloge( self, _ackMsg )
	print( "Open_Allloge收到的消息" )
	local ackMsg = _ackMsg
	print( "数量（总天数7）：", ackMsg.count )

	local function sort( data1, data2 )
	    if data1.day < data2.day then
	        return true
		end
	end
	table.sort( ackMsg.msg_alllogo , sort )
	for i=1,ackMsg.count do
		print( " 第"..ackMsg.msg_alllogo[i].day.."天!! 上标次数 = ", ackMsg.msg_alllogo[i].logo_times   )
	end


	local mywidth    = -235
	self.Lab_Logo    = {}
	for i=1,_ackMsg.count do
		local day = _ackMsg.msg_alllogo[i].day
		local myheigh = 262-day*72

		local Spr_logo = ccui.Scale9Sprite : createWithSpriteFrameName( "general_report_tips2.png" )
		Spr_logo : setPosition( cc.p(mywidth, myheigh) )
		Spr_logo : setTag( Tag_Spr_Logo[day] )
		self.mainContainer : addChild( Spr_logo, 5 )
		if _ackMsg.msg_alllogo[i].logo_times == 0 then 
			Spr_logo : setVisible( false )
		end

		local Times = _ackMsg.msg_alllogo[i].logo_times>9 and "N" or _ackMsg.msg_alllogo[i].logo_times
		self.Lab_Logo[day] = _G.Util : createLabel(Times, FONTSIZE )
		self.Lab_Logo[day] : setPosition( cc.p(14, 12 ) )
		Spr_logo : addChild( self.Lab_Logo[day] )

		self.MyLogo[day] = _ackMsg.msg_alllogo[i].logo_times
	end
end

function SevenDayView.REQ_OPEN_DAY_REQUEST( self )
	local msg = REQ_OPEN_DAY_REQUEST()
	_G.Network : send( msg )
end

function SevenDayView.Net_Day_CB( self, _ackMsg )
	print("SevenDayView.Net_Day_CB", _ackMsg.day)
	local day = _ackMsg.day
	-- 默认界面
	if day <= 1 then 
		day = 1 
	elseif day > 7 then
		day = 7
	end

	for i=1,7 do
		self : CreateRightView( i )
	end
end

function SevenDayView.REQ_OPEN_REQUEST( self, _day )
	local msg = REQ_OPEN_REQUEST()
	msg : setArgs( _day )
	_G.Network : send( msg )
end

function SevenDayView.Net_Open_Reply( self, _ackMsg )
	print( "确定已经收到消息", _ackMsg )
	local Reply_ackMsg = _ackMsg
	print( "得到的ackMsg.Count:", Reply_ackMsg.count )
	print( "第"..Reply_ackMsg.type.."天" )
	local day  	= Reply_ackMsg.type
	local good 	= _G.Cfg.achieve_must[day]
	local count = Reply_ackMsg.count
	local state = Reply_ackMsg.msg_times

	local function sort( data1, data2 )
	    if data1.id < data2.id then
	        return true
		end
	end
	table.sort( state , sort )
	for i=1,Reply_ackMsg.count do
		print( "count：", i )
		print( "id：", state[i].id, "state：", state[i].state)
		-- self : changeBtn( day, i, state[i].state )
	end
	self : CreateScrollView( day, good, count, state ) 
	self : endTimeCreate(Reply_ackMsg.endtime,day)
end

function SevenDayView.endTimeCreate( self, _endtime,_day )
	local nowTime = _G.TimeUtil:getServerTimeSeconds()
	local _time = _endtime-nowTime
	local endday   = _time>0 and math.floor(_time/(24*3600)) or 0
	local endhour  = _time>0 and math.floor((_time-endday*24*3600)/3600) or 0
	local endmin   = _time>0 and math.floor(_time%3600/60) or 0
	print("endTimeCreate====>>>",_time,endday,endhour,endmin)
	if endday>=0 then
		local dayNode,spriteWidth=self:getTimeNumSpr(endday)
		dayNode:setPosition(rightSize.width-165,rightSize.height-75)
		self.myNode[_day]: addChild( dayNode,10 )
	end
	if endhour>=0 then
		local hourNode,spriteWidth=self:getTimeNumSpr(endhour)
		hourNode:setPosition(rightSize.width-115,rightSize.height-75)
		self.myNode[_day]: addChild( hourNode,10 )
	end
	if endmin>=0 then
		local minNode=self:getTimeNumSpr(endmin)
		minNode:setPosition(rightSize.width-61,rightSize.height-75)
		self.myNode[_day]: addChild( minNode ,10)
	end
end

function SevenDayView.getTimeNumSpr( self, _Num )
    print("getTimeNumStr-->11111111",_Num)
    local NumSprNode = cc.Node:create()
    local length = 2
    local spriteWidth = 0

    for i=1, length do
    	if _Num==0 then
    		local _tempSpr = cc.Sprite:createWithSpriteFrameName( "general_0.png")
	        -- _tempSpr:setScale(0.8)
	        NumSprNode : addChild( _tempSpr )

	        local _tempSprSize = _tempSpr : getContentSize()
	        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
	        _tempSpr           : setPosition( spriteWidth,0)
    	elseif _Num<10 and _Num>0 then
    		print("getTimeNumStr-->222222222",i,_Num)
    		if i==1 then
	    		local _tempSpr = cc.Sprite:createWithSpriteFrameName( "general_0.png")
		        -- _tempSpr:setScale(0.8)
		        NumSprNode : addChild( _tempSpr )

		        local _tempSprSize = _tempSpr : getContentSize()
		        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
		        _tempSpr           : setPosition( spriteWidth,0)
		    else
		    	local _tempSpr = cc.Sprite:createWithSpriteFrameName( string.format("general_%d.png",_Num))
		        -- _tempSpr:setScale(0.8)
		        NumSprNode : addChild( _tempSpr )

		        local _tempSprSize = _tempSpr : getContentSize()
		        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
		        _tempSpr           : setPosition( spriteWidth,0)
		    end
    	else
    		print("getTimeNumStr-->333333333",i,_Num,string.sub(_Num,i,i))
	        local _tempSpr = cc.Sprite:createWithSpriteFrameName( "general_"..string.sub(_Num,i,i)..".png")
	        -- _tempSpr:setScale(0.8)
	        NumSprNode : addChild( _tempSpr )

	        local _tempSprSize = _tempSpr : getContentSize()
	        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
	        _tempSpr           : setPosition( spriteWidth,0)
	    end
    end

    return NumSprNode,spriteWidth
end

function SevenDayView.REQ_OPEN_GET( self, _id, _day )
	print("REQ_OPEN_GET===>>>",_id, _day)
	local msg = REQ_OPEN_GET()
	msg : setArgs( _id, _day )
	_G.Network : send( msg )
end

function SevenDayView.Net_Open_Get_Cb( self )
	print( "Net_Open_Get_Cb,  self.Day = ", self.Day )
	print( "Net_Open_Get_Cb,  self.ID  = ", self.ID  )
	self : changeBtn( self.Day, self.ID, 3 )

	self.MyLogo[self.Day]   = self.MyLogo[self.Day] - 1
	self.Lab_Logo[self.Day] : setString( self.MyLogo[self.Day] )
	if self.MyLogo[self.Day] <= 0 then 
		self.mainContainer : getChildByTag( Tag_Spr_Logo[self.Day] ) : setVisible(false)
	end
end

function SevenDayView.Net_SYSTEM_ERROR( self, _ackMsg )
	local ackMsg   = _ackMsg
    local errorNum = _ackMsg.error_code
    print( "错误代码：,", errorNum )
    if errorNum == 36720 then
    	self : changeBtn( self.Day, self.ID, 1 )
    	self.MyLogo[self.Day]   = self.MyLogo[self.Day] - 1
		self.Lab_Logo[self.Day] : setString( self.MyLogo[self.Day] )
		if self.MyLogo[self.Day] <= 0 then 
			self.mainContainer : getChildByTag( Tag_Spr_Logo[self.Day] ) : setVisible(false)
		end
    end
end

function SevenDayView.REQ_OPEN_RANK_REQUEST( self, _day )
	local msg = REQ_OPEN_RANK_REQUEST()
	msg : setArgs( _day )
	_G.Network : send( msg )
end

function SevenDayView.Net_Open_Rank( self, _ackMsg )
	self.Ranking = _ackMsg.msg_rank  
	for i=1,_ackMsg.count do
		print("     名字    	 =", 	_ackMsg.msg_rank[i].name 	)
		print("		等级	 	 =",	_ackMsg.msg_rank[i].lv		)
		print("		经验	 	 =",	_ackMsg.msg_rank[i].exp		)
		print("	  坐骑战斗力	 =",	_ackMsg.msg_rank[i].mount	)
		print("	  装备战斗力	 =",	_ackMsg.msg_rank[i].equip	)
		print("	  霸气战斗力	 =",	_ackMsg.msg_rank[i].baqi	)
		print("	通关镇妖塔层数 =",	_ackMsg.msg_rank[i].fighter	)
		print("	   总战斗力	 =",	_ackMsg.msg_rank[i].powerful)
	end
end
-- 协议完毕

function SevenDayView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	local Position  = obj : getWorldPosition()
    local _pos      = {}
    _pos.x          = Position.x
    _pos.y          = Position.y
    print( "Position.y = ", Position.y )
    if _pos.y > 500 or _pos.y < 80 then
	    return 
	end
	if touchEvent == ccui.TouchEventType.began then
		print("   按下  ", tag)
	elseif touchEvent == ccui.TouchEventType.moved then
		print("   移动  ", tag)
	elseif touchEvent == ccui.TouchEventType.ended then
  		print("   抬起  ", tag)
  		if tag>0 then
  			print( "ID是 ：", tag )
  			print( "DAY是：", self.Day )
  			self.ID = tag
  			local My_Tag = _G.Cfg.achieve_must[self.Day][tag].id
  			self : REQ_OPEN_GET( My_Tag, self.Day )
  		end	
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ", tag)
  	end
end

return SevenDayView
