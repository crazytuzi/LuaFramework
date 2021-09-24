local SubStriveView = classGc(view,function(self,_msg)
    self.m_winSize  = cc.Director : getInstance() : getVisibleSize()
    self.m_mainSize = cc.size(780,450)
    self.msg       = _msg

    self.isOpen     = _G.GSystemProxy:getNeverNotic(_G.Const.CONST_FUNC_OPEN_STRIVE) or false
end)

local SELECT_UI_TAG = 1001
local GROUP_UI_TAG  = 1002
local RMB_ALL_TAG   = 1003
local GUESS_LAYER   = 1004
local START_BG      = 1005
local COMBAT_TIME   = 1006
local GAME_TAG      = 1007
local COMBAT_MSG    = 1008

function SubStriveView.create(self)
    self : __init()

    self.m_rootLayer = cc.Scene : create()
    
    local function onTouchBegan(touch) 

        return true 
    end
    local listerner  = cc.EventListenerTouchOneByOne : create()
    listerner 		 : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listerner 		 : setSwallowTouches(true)
    
    self.m_rootLayer : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    if self.msg.type == 2 then
    	--self : __initNobodyView()
    elseif self.msg.type == 3 then
    	self : __initStartView()
    elseif self.msg.type == 4 then
    	print("轮次：",self.msg.turn)
    	self : __initFinalView()
    end
   	
    return self.m_rootLayer
end

function SubStriveView.__init(self)
    self : register()
end

function SubStriveView.register(self)
    self.pMediator = require("mod.smodule.SubStriveMediator")(self)
end

function SubStriveView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function SubStriveView.__initRankMsgLab( self,i,_msg )
	local noitSize=cc.size(550,39)
	local layer = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
	layer       : setPreferredSize(noitSize)
	layer       : setAnchorPoint(cc.p(0,0))
	layer       : setPosition(5,342 - i*42)
	local fontSize = 20
	local color    = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PALEGREEN)

	local rank = _G.Util : createLabel(tostring(i),fontSize)
	-- rank       : setColor(color)
	-- rank       : setAnchorPoint(cc.p(0,0.5))
	rank       : setPosition(cc.p(35,noitSize.height/2))
	layer      : addChild(rank)

	local name = _G.Util : createLabel(_msg.name,fontSize)
	name       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	name       : setPosition(cc.p(150,noitSize.height/2))
	layer      : addChild(name)

	local power= _G.Util : createLabel(tostring(_msg.powerful),fontSize)
	-- power      : setColor(color)
	-- power      : setAnchorPoint(cc.p(0,0.5))
	power      : setPosition(cc.p(300,noitSize.height/2))
	layer      : addChild(power)

	local win  = _G.Util : createLabel(string.format("%d/",_msg.win),fontSize)
	win        : setAnchorPoint(cc.p(0,0.5))
	win        : setPosition(cc.p(410,noitSize.height/2))
	layer      : addChild(win)

	local lose  = _G.Util : createLabel(_msg.lose,fontSize)
	lose        : setAnchorPoint(cc.p(0,0.5))
	lose        : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	lose        : setPosition(cc.p(410+win:getContentSize().width,noitSize.height/2))
	layer       : addChild(lose)

	local grade = _G.Util : createLabel(tostring(_msg.score),fontSize)
	-- grade      : setColor(color)
	-- grade      : setAnchorPoint(cc.p(0,0.5))
	grade      : setPosition(cc.p(515,noitSize.height/2))
	layer      : addChild(grade)

	return layer
end

function SubStriveView.__initGroupLayer( self,group_id )
	print("初始化选择界面")
	local groupSize = cc.size(520,210)
	local function onTouchBegan(touch) 
		print("进来了，好开心阿")
		local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-groupSize.width/2,self.m_winSize.height/2-groupSize.height/2,
        groupSize.width,groupSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end

      	local function nFun()
	        print("closeFunSetting-----------------")
	       	cc.Director : getInstance() : getRunningScene() : getChildByTag(GROUP_UI_TAG) : removeFromParent()
	    end
	    local delay=cc.DelayTime:create(0.01)
	    local func=cc.CallFunc:create(nFun)
	    self.captureLayer:runAction(cc.Sequence:create(delay,func))
        return true
	end
	print("创建选择UI")
	local listerner = cc.EventListenerTouchOneByOne : create()
	listerner 	    : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner 		: setSwallowTouches(true)

	self.captureLayer = cc.LayerColor:create( cc.c4b(0,0,0,150) )
	self.captureLayer 	  : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, self.captureLayer)
	-- self.captureLayer 	  : setPosition(cc.p(size.width/2, size.height/2))
	self.captureLayer 	  : setTag(GROUP_UI_TAG)
	cc.Director 	  : getInstance() : getRunningScene() : addChild(self.captureLayer,888)

	self : __initGroupView()
end

function SubStriveView.__initGroupView( self )
	local fontSize = 20
	local groupSize = cc.size(520,210)
	local m_layer = cc.Director : getInstance() : getRunningScene() : getChildByTag(GROUP_UI_TAG)

	local function bgEvent(  )
		return true
	end

	local Spr_Combat    = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
	Spr_Combat : setContentSize( groupSize )
  	Spr_Combat : setPosition( cc.p(self.m_winSize.width/2,self.m_winSize.height/2) )
  	m_layer  : addChild( Spr_Combat ) 

  	local spr_title = cc.Sprite : createWithSpriteFrameName( "general_tips_up.png" )
  	spr_title : setPosition( groupSize.width/2-125, groupSize.height - 26 )
  	Spr_Combat 	  : addChild( spr_title,1 )

  	local spr_title = cc.Sprite : createWithSpriteFrameName( "general_tips_up.png" )
  	spr_title : setPosition( groupSize.width/2+120, groupSize.height - 26 )
  	spr_title : setScale(-1)
  	Spr_Combat 	  : addChild( spr_title,1 )

  	local lab_title = _G.Util : createBorderLabel( "分  组", 24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
  	lab_title : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  	lab_title : setPosition( groupSize.width/2, groupSize.height - 26 )
  	Spr_Combat 	  : addChild( lab_title, 2 )

  	local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    frameSpr:setPreferredSize(cc.size(groupSize.width-15,groupSize.height-55))
    frameSpr:setPosition(groupSize.width/2,groupSize.height/4+35)
    Spr_Combat:addChild(frameSpr)

	for j=1,2 do
		for i=1,4 do
			local function betEvent( send,eventType )
				if eventType == ccui.TouchEventType.began then
					cc.Director : getInstance() : getRunningScene() : getChildByTag(GROUP_UI_TAG) : removeFromParent()
					local msg = REQ_WRESTLE_REQUEST_GROUP()
					msg       : setArgs((j-1)*4+i)
					_G.Network: send(msg)
					self.myGroupID=(j-1)*4+i
				end
			end 

			local button= gc.CButton:create()
			button     : addTouchEventListener(betEvent)
			-- button     : setButtonScale(0.8)
			button 	   : loadTextures("ui_group.png")
			button     : setTitleText(string.format("%s%s%s","第",_G.Lang.number_Chinese[(j-1)*4+i],"组"))
			button     : setTitleFontSize(fontSize)
			button     : setTitleFontName(_G.FontName.Heiti)
			--button     : setTitleColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_YELLOW))
			if self.myGroupID == ((j-1)*4+i) then
				button : loadTextures( "base2.png" )
				button : setTitleColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
			end
			button     : setPosition(cc.p((i-1)*121+71,groupSize.height-97 - (j-1)*70))
			frameSpr   : addChild(button)
		end
	end
end

function SubStriveView.__initStartView( self )
	print("type: ",self.msg.type)
	print("group_id: ",self.msg.group_id)
	if self.myGroupID==nil then
		self.myGroupID = self.msg.group_id
	end
	for k,v in pairs(self.msg.data) do
		print(v.name)
	end

    local layerBG = cc.Sprite : create("ui/bg/welkin_3.jpg")
    self.m_rootLayer  : addChild(layerBG,0)
    layerBG           : setTag(START_BG)
    layerBG 		  : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))

    local layerSize=layerBG:getContentSize()
    local downDins = ccui.Scale9Sprite:createWithSpriteFrameName("ui_base.png")
    downDins       : setContentSize(cc.size(layerSize.width,60))
    downDins       : setPosition(cc.p(layerSize.width/2,30))
    downDins  	   : setOpacity(180)
    layerBG        : addChild(downDins) 
    
    local function backEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("返回上一个场景")

	        self : __closeWindow()
	        cc.Director : getInstance() : popScene()
    	end
    end

    local backButton = gc.CButton:create()
	backButton : addTouchEventListener(backEvent)
	backButton : setAnchorPoint( 1, 1 )
	backButton : loadTextures("general_view_close.png")
	backButton : setSoundPath("bg/ui_sys_clickoff.mp3")
	backButton : setPosition(cc.p(self.m_winSize.width+45,self.m_winSize.height+20))
	backButton : ignoreContentAdaptWithSize(false)
    backButton : setContentSize(cc.size(120,120))
	layerBG    : addChild(backButton)

	local function explainEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("说明")
    		local explainView  = require("mod.general.ExplainView")()
			local explainLayer = explainView : create(40218,true)
    	end
    end

    local explainButton = gc.CButton:create()
	explainButton : addTouchEventListener(explainEvent)
	explainButton : loadTextures("general_help.png")
	-- explainButton : setTitleText("")
	-- explainButton : setTitleFontSize(24)
	-- explainButton : setTitleFontName(_G.FontName.Heiti)
	explainButton : setPosition(cc.p(layerSize.width/2-self.m_winSize.width/2+80,30))
	layerBG       : addChild(explainButton)

	local function guessEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("欢乐竞猜")
    		local msg = REQ_WRESTLE_REQUEST_GUESS()
    		_G.Network: send(msg)
    	end
    end

    local guessButton = gc.CButton:create()
	guessButton : addTouchEventListener(guessEvent)
	guessButton : loadTextures("ui_strive_guess.png")
	-- guessButton : setTitleText("")
	-- guessButton : setTitleFontSize(24)
	-- guessButton : setTitleFontName(_G.FontName.Heiti)
	--guessButton : setButtonScale(0.8)
	guessButton : setPosition(cc.p(layerSize.width/2 - self.m_winSize.width/2 + 50,self.m_winSize.height-50))
	layerBG     : addChild(guessButton)

	if self.msg.group_id ~= 0 then
		self : __initRankLayer(self.msg.group_id,self.msg.data)
	else
		local msg = REQ_WRESTLE_REQUEST_GROUP()
		msg       : setArgs(1)
		_G.Network: send(msg)
	end

	local titleName = _G.Util : createLabel("初 赛",30)
	titleName       : setPosition(cc.p(layerSize.width/2-80,layerSize.height-45))
	titleName       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	layerBG         : addChild(titleName)

	local framSpr = cc.Sprite:createWithSpriteFrameName("general_fram_dins.png")
	framSpr 	  : setPosition(layerSize.width/2-350,500)
	layerBG       : addChild(framSpr)

	local name    = _G.Util : createLabel(_G.GPropertyProxy : getMainPlay() : getName(),20)
	name          : setPosition(cc.p(layerSize.width/2-350,518))
	layerBG       : addChild(name)

	local power   = _G.Util : createLabel(string.format("%s%s","战力: ",tostring(_G.GPropertyProxy : getMainPlay() : getAllsPower())),20)
	power         : setPosition(cc.p(layerSize.width/2-350,482))
	power         : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	layerBG       : addChild(power)
   
	local mySpine,wuqiSke,featherSke = _G.SpineManager.createMainPlayer()
	mySpine       : setAnimation(0,"idle",true)
	mySpine       : setScale(0.8)
	mySpine       : setPosition(cc.p(layerSize.width/2-350,90))
	layerBG       : addChild(mySpine,1)
	if wuqiSke then
		wuqiSke : setAnimation(0,"idle",true)
	end
	if featherSke then
		featherSke : setAnimation(0,string.format("idle_%d",_G.GPropertyProxy:getMainPlay():getSkinArmor()),true)
	end
	
	local combatMsg = _G.Util : createLabel("下轮比赛开始",20)
	-- combatMsg       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	combatMsg       : setPosition(cc.p(layerBG : getContentSize().width/2-25,30))
	combatMsg       : setTag(COMBAT_MSG)
	layerBG         : addChild(combatMsg)

	local combatTime= _G.Util : createLabel("00:00:00",20)
	combatTime      : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	combatTime      : setPosition(cc.p(layerBG : getContentSize().width/2+20,30))
	combatTime      : setTag(COMBAT_TIME)
	layerBG         : addChild(combatTime)

	local function gameEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("我的比赛")
    		local msg = REQ_WRESTLE_REQUEST_MY_GAME()
    		_G.Network: send(msg)
    	end
    end

    local gameButton = gc.CButton:create()
	gameButton : addTouchEventListener(gameEvent)
	gameButton : loadTextures("general_btn_gold.png")
	gameButton : setTitleText("我的比赛")
	gameButton : setTitleFontSize(24)
	gameButton : setTitleFontName(_G.FontName.Heiti)
	gameButton : setPosition(cc.p(layerSize.width/2+self.m_winSize.width/2-110,28))
	layerBG    : addChild(gameButton)

	if self.msg.group_id == 0 then
		combatMsg : setString("暂无您的比赛信息")
		combatMsg : setPosition(cc.p(layerSize.width/2-350,70))
		combatTime: setVisible(false)
		gameButton : setGray()
		gameButton : setEnabled(false)
	end
end

function SubStriveView.updateTime( self,_msg )
	local combatMsg = self.m_rootLayer : getChildByTag(START_BG) : getChildByTag(COMBAT_MSG)
	local timeLab = self.m_rootLayer : getChildByTag(START_BG) : getChildByTag(COMBAT_TIME)

	if _msg.state == 1 then
		combatMsg : setString("初赛未开始")
		combatMsg : setAnchorPoint(cc.p(0.5,0.5))
		timeLab   : setVisible(false)

		if self.isOpen and self.combatMsg1 then
			self.combatMsg1 : setString("初赛未开始")
			self.combatTime1: setVisible(false)
		end
	elseif _msg.state == 3 then
		combatMsg : setString("决赛未开始")
		combatMsg : setAnchorPoint(cc.p(0.5,0.5))
		timeLab   : setVisible(false)

		if self.isOpen and self.combatMsg1 then
			self.combatMsg1 : setString("决赛未开始")
			self.combatTime1: setVisible(false)
		end
	elseif _msg.state == 7 then
		combatMsg : setString("比赛全部结束！")
		combatMsg : setAnchorPoint(cc.p(0.5,0.5))
		timeLab   : setVisible(false)

		if self.isOpen and self.combatMsg1 then
			self.combatMsg1 : setString("比赛全部结束！")
			self.combatTime1: setVisible(false)
		end
	else
		timeLab   : setVisible(true)
		combatMsg : setAnchorPoint(cc.p(1,0.5))
		if self.isOpen and self.combatMsg1 then
			self.combatTime1: setVisible(true)
		end
	end

	if _msg.time == 0 then
		return
	end

	self.combatTime = _msg.time - _G.TimeUtil : getServerTimeSeconds()
	print("时间：",self.combatTime)
	if self.combatTime < 5 then
		local function delayFun( )
			print("延时一秒，重新请求数据",self.isOpen)
			local msg  = REQ_WRESTLE_REQUEST()
		    _G.Network : send(msg)
		    if self.isOpen then
		    	if self.msg.state and self.msg.state>=6 then
					local msg = REQ_WRESTLE_REQUEST_KING()
		    		_G.Network: send(msg)
				else
					local msg = REQ_WRESTLE_REQUEST_MY_GAME()
					_G.Network: send(msg)
				end
		    end
		end
		self.m_rootLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(delayFun)))
		return
	end
	print("self.combatMsg1存在吗？",self.combatMsg1)

	if _msg.state == 2 then
		if _msg.state2==1 then
			combatMsg : setString(string.format("第%d/7场开始",_msg.round))
			if self.isOpen and self.combatMsg1 then
				print("我的比赛状态刷新")
				self.combatMsg1 : setString(string.format("第%d/7场开始",_msg.round))
			end
		else
			combatMsg : setString(string.format("第%d/7场结束",_msg.round))
			if self.isOpen and self.combatMsg1 then
				print("我的比赛状态刷新2")
				self.combatMsg1 : setString(string.format("第%d/7场结束",_msg.round))
			end
		end
	elseif _msg.state == 4 then
		if _msg.state2==1 then
			combatMsg : setString("下轮开始时间")
			if self.isOpen and self.combatMsg1 then
				print("我的比赛状态刷新")
				self.combatMsg1 : setString("下轮开始时间")
			end
		else
			combatMsg : setString("本轮比赛结束")
			if self.isOpen and self.combatMsg1 then
				print("我的比赛状态刷新2")
				self.combatMsg1 : setString("本轮比赛结束")
			end
		end
	end

	if self.combatTime ~= 0 then
		self.combatTime = _msg.time
		local function local_scheduler()
	        self : __initCountdown()
	    end
	    
	    if self.m_timeScheduler==nil then
	    	self.m_timeScheduler = _G.Scheduler : schedule(local_scheduler, 1)
	    end
	end
end

function SubStriveView.__initCountdown( self )
	if self.combatTime - _G.TimeUtil : getServerTimeSeconds() >= 0 then
		print("还在刷新？？？？？？？？？？？？？？？？？？？",self.isOpen)
		local timeLab = self.m_rootLayer : getChildByTag(START_BG) : getChildByTag(COMBAT_TIME)
		timeLab       : setString(self : __getTimeStr(self.combatTime - _G.TimeUtil : getServerTimeSeconds()))

		if self.isOpen then
			self.combatTime1 : setString(self : __getTimeStr(self.combatTime - _G.TimeUtil : getServerTimeSeconds()))
		end
	end

	if self.combatTime - _G.TimeUtil : getServerTimeSeconds()<=0 then
		local msg  		  = REQ_WRESTLE_REQUEST()
	    _G.Network  	  : send(msg)
	end

	if self.isOpen then
		
	end

	if self.isOpen and self.combatTime - _G.TimeUtil : getServerTimeSeconds()<=0 then
		if self.msg.state and self.msg.state>=6 then
			local msg = REQ_WRESTLE_REQUEST_KING()
    		_G.Network: send(msg)
		else
			local msg = REQ_WRESTLE_REQUEST_MY_GAME()
			_G.Network: send(msg)
		end
	end
	print(self.combatTime - _G.TimeUtil : getServerTimeSeconds())
end

function SubStriveView.__initRankLayer( self,group_id,_msg )
	local function sort( a, b )
		if a.score>b.score then 
			return true
		elseif a.score==b.score and a.powerful>b.powerful then
			return true		
		end
		return false
	end
	table.sort( _msg , sort )
	local _layer    = self.m_rootLayer : getChildByTag(START_BG)
	if _layer:getChildByTag(77) then
		_layer:getChildByTag(77):removeFromParent()
	end
	local layerSize = _layer:getContentSize()
	local dinSize   = cc.size(560,400)
	local rankDins	= ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_kuang.png")
	rankDins 	  	: setPosition(cc.p(self.m_winSize.width-300, layerSize.height/2))
	rankDins	    : setPreferredSize(dinSize)
	rankDins  	    : setOpacity(180)
	rankDins        : setTag(77)
	_layer 		    : addChild(rankDins)

	local fontSize  = 20

	local secondBG  = ccui.Scale9Sprite : createWithSpriteFrameName("ui_base.png")
	secondBG        : setPreferredSize(cc.size(dinSize.width-3,dinSize.height-50))
	secondBG        : setPosition(cc.p(dinSize.width/2,dinSize.height/2-25))
	rankDins        : addChild(secondBG)

	local height    = 360
	local color     = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PALEGREEN)
	
	local rankLab   = _G.Util : createLabel("排名",fontSize)
	-- rankLab         : setColor(color)
	rankLab         : setAnchorPoint(cc.p(0,0))
	rankLab         : setPosition(cc.p(20,height))
	rankDins        : addChild(rankLab)

	local nameLab   = _G.Util : createLabel("参赛者",fontSize)
	-- nameLab         : setColor(color)
	nameLab         : setAnchorPoint(cc.p(0,0))
	nameLab         : setPosition(cc.p(125,height))
	rankDins        : addChild(nameLab)

	local powerLab  = _G.Util : createLabel("战力",fontSize)
	-- powerLab        : setColor(color)
	powerLab        : setAnchorPoint(cc.p(0,0))
	powerLab        : setPosition(cc.p(285,height))
	rankDins        : addChild(powerLab)

	local winLab    = _G.Util : createLabel("胜/负",fontSize)
	-- winLab          : setColor(color)
	winLab          : setAnchorPoint(cc.p(0,0))
	winLab          : setPosition(cc.p(410,height))
	rankDins        : addChild(winLab)

	local gradeLab  = _G.Util : createLabel("积分",fontSize)
	-- gradeLab        : setColor(color)
	gradeLab        : setAnchorPoint(cc.p(0,0))
	gradeLab        : setPosition(cc.p(500,height))
	rankDins        : addChild(gradeLab)

	if self.group==nil then
	    self.group  = _G.Util : createLabel(string.format("%s%s%s","第",_G.Lang.number_Chinese[group_id],"组"),fontSize)
	    -- self.group  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PALEGREEN))
		-- self.group  : setAnchorPoint(cc.p(0.5,0))
		self.group  : setPosition(cc.p(self.m_winSize.width/2-50,self.m_winSize.height-75))
		_layer      : addChild(self.group)
	else
		self.group:setString(string.format("%s%s%s","第",_G.Lang.number_Chinese[group_id],"组"))
	end

	local function groupEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			print("分组信息")
			self : __initGroupLayer(self.myGroupID)
		end
	end 

	if self.widget_OthRange==nil then
		local lab_zu = _G.Util : createLabel( "点击查看其他分组", 18 )
	    local mySize = cc.size( lab_zu:getContentSize().width, 48 )

	    local widget_OthRange = ccui.Widget : create()
	 	widget_OthRange : setContentSize( mySize )
	 	widget_OthRange : setTouchEnabled( true )
	 	widget_OthRange : addTouchEventListener( groupEvent )
	 	-- widget_OthRange : setTag( Tag_widget_OthRange )
	 	-- widget_OthRange : setAnchorPoint( 0.5, 1 )
	 	widget_OthRange : setPosition( self.m_winSize.width/2-50, self.m_winSize.height-100 )
	    _layer : addChild( widget_OthRange, 1 )
	    self.widget_OthRange  = widget_OthRange

	    lab_zu : setPosition( mySize.width/2, mySize.height/2+5 )
	    -- lab_zu : setColor( color4 )
	    widget_OthRange : addChild( lab_zu )

	    local color100 = _G.ColorUtil:getFloatRGBA( _G.Const.CONST_COLOR_WHITE )
	    local myPos = cc.p( mySize.width/2, mySize.height/2 - 10 )
	    local lineNode=cc.DrawNode:create()--绘制线条
	    lineNode:drawLine(cc.p(-mySize.width/2,1),cc.p(mySize.width/2,1),color100)
	    lineNode:setPosition(myPos)
	    widget_OthRange:addChild(lineNode,2)
	end

	for i=1,#_msg do
		local lab = self : __initRankMsgLab(i,_msg[i])
		rankDins  : addChild(lab)
	end
end

function SubStriveView.initGameView( self,_msg )
	if self.m_rootLayer : getChildByTag(GAME_TAG) then
		self.m_rootLayer : getChildByTag(GAME_TAG) : removeFromParent()
	end

	size     = cc.size(830,479)
	local function onTouchBegan(touch) 
		print("进来了，好开心阿22")
		local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-size.width/2,self.m_winSize.height/2-size.height/2,
        size.width,size.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end

      	local function nFun()
	        print("self.gameLayer-----------------")
	        self.gameLayer : removeFromParent()
			self.isOpen = false
			_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_STRIVE,false)
	    end
	    local delay=cc.DelayTime:create(0.01)
	    local func=cc.CallFunc:create(nFun)
	    self.gameLayer:runAction(cc.Sequence:create(delay,func))
        return true
	end
	local listerner = cc.EventListenerTouchOneByOne : create()
	listerner 	    : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner 		: setSwallowTouches(true)

	self.gameLayer  = cc.LayerColor:create( cc.c4b(0,0,0,150) )
	self.gameLayer  : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, self.gameLayer)
	self.gameLayer 	: setPosition(cc.p(0,0))
	self.gameLayer  : setTag(GAME_TAG)
	self.m_rootLayer: addChild(self.gameLayer,1)

	local downDins = cc.Node:create()
    downDins       : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    self.gameLayer : addChild(downDins)

	local firstBg  = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_dins.png")
	firstBg        : setPreferredSize(size)
	downDins : addChild(firstBg)

	local str1 = ""
	local str2 = ""

	if self.msg.type == 3 then
		str1 = "初赛"
		str2 = tostring(_msg.turn)
	elseif self.msg.type == 4 then
		str1 = "决赛"
		str2 = tostring(self.msg.turn)
	end

	local fontSize = 20
	-- local color    = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD)

	local title = _G.Util : createLabel(string.format("%s-第%s轮",str1,str2),fontSize)
	title       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	title       : setPosition(cc.p(size.width/2,390))
	firstBg    : addChild(title)

	if self.msg.state and self.msg.state >= 6 then
		title : setString(string.format("第%s回合",_G.Lang.number_Chinese[_msg[2].count]))

		local Count     = _G.Util : createLabel("巅峰对决",24)
		Count           : setPosition(cc.p(size.width/2,440))
		firstBg         : addChild(Count)

		local mySprite  = cc.Sprite:create(string.format("painting/1000%d_full.png",_msg[1].pro))
		mySprite        : setScale(0.8)
		mySprite        : setAnchorPoint(cc.p(0.5,0))
		mySprite        : setPosition(cc.p(size.width/6,5))
		firstBg         : addChild(mySprite)

		-- local leg       = cc.Sprite:create(string.format("painting/1000%dleg.png",_msg[1].pro))
		-- leg             : setScale(0.8)
		-- leg             : setAnchorPoint(cc.p(0.5,1))
		-- leg             : setPosition(cc.p(size.width/6,130))
		-- firstBg         : addChild(leg)

		local dinsSpr   = cc.Sprite:createWithSpriteFrameName("general_fram_dins.png")
		dinsSpr 		: setPosition(size.width/6,400)
		firstBg			: addChild(dinsSpr)

		local name      = _G.Util : createLabel(_msg[1].name,20)
		name            : setPosition(cc.p(size.width/6,420))
		firstBg         : addChild(name)

		local power     = _G.Util : createLabel(string.format("战力: %s",tostring(_msg[1].powerful)),20)
		power           : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		power           : setPosition(cc.p(size.width/6,395))
		firstBg         : addChild(power)

		local mySprite1  = cc.Sprite:create(string.format("painting/1000%d_full.png",_msg[2].pro))
		mySprite1        : setFlippedX(true)
		mySprite1        : setScale(0.8)
		mySprite1        : setAnchorPoint(cc.p(0.5,0))
		mySprite1        : setPosition(cc.p(size.width*5/6,5))
		firstBg         : addChild(mySprite1)

		-- local leg1       = cc.Sprite:create(string.format("painting/1000%dleg.png",_msg[2].pro))
		-- leg1             : setFlippedX(true)
		-- leg1             : setScale(0.8)
		-- leg1             : setAnchorPoint(cc.p(0.5,1))
		-- leg1             : setPosition(cc.p(size.width*5/6,130))
		-- firstBg          : addChild(leg1)

		local dinsSpr   = cc.Sprite:createWithSpriteFrameName("general_fram_dins.png")
		dinsSpr 		: setPosition(size.width*5/6,400)
		firstBg			: addChild(dinsSpr)

		local name1     = _G.Util : createLabel(_msg[2].name,20)
		name1           : setPosition(cc.p(size.width*5/6,420))
		firstBg        : addChild(name1)

		local power1    = _G.Util : createLabel(string.format("战力: %s",tostring(_msg[2].powerful)),20)
		power1          : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		power1          : setPosition(cc.p(size.width*5/6,395))
		firstBg        : addChild(power1)

		for i=1,_msg[1].count do
			local star = gc.GraySprite : createWithSpriteFrameName("ui_strive_win.png")
			star 	   : setPosition(cc.p(size.width/2-35 - i*25,390))
			if _msg[1].result[i] == 0 then
				print("失败了")
				star : setGray()
			end
			firstBg : addChild(star)
		end

		for i=1,_msg[2].count do
			local star = gc.GraySprite : createWithSpriteFrameName("ui_strive_win.png")
			star 	   : setPosition(cc.p(size.width/2+35 + i*25,390))
			if _msg[2].result[i] == 0 then
				print("失败了")
				star : setGray()
			end
			firstBg : addChild(star)
		end
	else
		local pro = _G.GPropertyProxy : getMainPlay() : getPro()
		if _G.GPropertyProxy:getMainPlay():getAllsPower()<_msg.powerful then
			pro = _msg.pro
		end
		local mySpine = cc.Sprite:create(string.format("painting/1000%d_full.png",pro))
		mySpine       : setScale(0.8)
		mySpine       : setAnchorPoint(cc.p(0.5,0))
		mySpine       : setPosition(cc.p(size.width/6,5))
		firstBg      : addChild(mySpine)

		-- local leg     = cc.Sprite:create(string.format("painting/1000%dleg.png",pro))
		-- leg           : setScale(0.8)
		-- leg           : setAnchorPoint(cc.p(0.5,1))
		-- leg           : setPosition(cc.p(size.width/6,130))
		-- firstBg      : addChild(leg)

		local dinsSpr   = cc.Sprite:createWithSpriteFrameName("general_fram_dins.png")
		dinsSpr 		: setPosition(size.width/6,400)
		firstBg			: addChild(dinsSpr)

		local name      = _G.Util : createLabel(_G.GPropertyProxy : getMainPlay() : getName(),20)
		if _G.GPropertyProxy : getMainPlay() : getAllsPower() < _msg.powerful then
			name : setString(_msg.name)
		end
		name            : setPosition(cc.p(size.width/6,420))
		firstBg         : addChild(name)

		local power     = _G.Util : createLabel(string.format("%s%s","战力: ",tostring(_G.GPropertyProxy : getMainPlay() : getAllsPower())),20)
		if _G.GPropertyProxy : getMainPlay() : getAllsPower() < _msg.powerful then
			power : setString(string.format("%s%s","战力: ",tostring(_msg.powerful)))
		end
		power           : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		power           : setPosition(cc.p(size.width/6,395))
		firstBg        : addChild(power)

		if _msg.uid~=0 then
		    if _msg.pro==0 then
		    	_msg.pro=1
		    end
			local pro =_msg.pro
			if _G.GPropertyProxy : getMainPlay() : getAllsPower() < _msg.powerful then
				pro = _G.GPropertyProxy : getMainPlay() : getPro()
			end
			local mySpine = cc.Sprite:create(string.format("painting/1000%d_full.png",pro))
			mySpine       : setFlippedX(true)
			mySpine       : setScale(0.8)
			mySpine       : setAnchorPoint(cc.p(0.5,0))
			mySpine       : setPosition(cc.p(size.width*5/6,5))
			firstBg      : addChild(mySpine)

			-- local leg     = cc.Sprite:create(string.format("painting/1000%dleg.png",pro))
			-- leg           : setFlippedX(true)
			-- leg           : setScale(0.8)
			-- leg           : setAnchorPoint(cc.p(0.5,1))
			-- leg           : setPosition(cc.p(size.width*5/6,130))
			-- firstBg      : addChild(leg)

			local dinsSpr   = cc.Sprite:createWithSpriteFrameName("general_fram_dins.png")
			dinsSpr 		: setPosition(size.width*5/6,400)
			firstBg			: addChild(dinsSpr)

			local name      = _G.Util : createLabel(_msg.name,20)
			if _G.GPropertyProxy : getMainPlay() : getAllsPower() < _msg.powerful then
				name : setString(_G.GPropertyProxy : getMainPlay() : getName())
			end
			name            : setPosition(cc.p(size.width*5/6,420))
			firstBg        : addChild(name)

			local power     = _G.Util : createLabel(string.format("%s%s","战力: ",tostring(_msg.powerful)),20)
			if _G.GPropertyProxy : getMainPlay() : getAllsPower() < _msg.powerful then
				power : setString(string.format("%s%s","战力: ",tostring(_G.GPropertyProxy : getMainPlay() : getAllsPower())))
			end
			power           : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
			power           : setPosition(cc.p(size.width*5/6,395))
			firstBg        : addChild(power)
		else
			local tipsDins  = cc.Sprite : create("ui/bg/expidit_Yingzi.png")
			tipsDins 		: setScale(1.6)
			tipsDins 	    : setPosition(cc.p(size.width*5/6,190))
			firstBg        : addChild(tipsDins)

			local tips = cc.Sprite : createWithSpriteFrameName("ui_strive_nobody.png")
			tips 	   : setPosition(cc.p(size.width*5/6,410))
		    firstBg   : addChild(tips)
		end
	end

	local vsIcon = cc.Sprite : createWithSpriteFrameName("ui_strive_vs.png")
	vsIcon       : setPosition(cc.p(size.width/2,size.height/2+10))
	firstBg     : addChild(vsIcon)
	self.isOpen  = true
	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_STRIVE,true)

	local combatMsg = _G.Util : createLabel("下轮比赛开始",20)
	-- combatMsg       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	combatMsg       : setPosition(cc.p(firstBg : getContentSize().width/2,100))
	firstBg        : addChild(combatMsg)
	self.combatMsg1 = combatMsg

	local combatTime= _G.Util : createLabel("00:00:00",20)
	combatTime      : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	combatTime      : setPosition(cc.p(firstBg : getContentSize().width/2,70))
	firstBg        : addChild(combatTime)
	self.combatTime1= combatTime

	if self.msg.state and self.msg.state==7 then
		combatMsg  : setString("本轮比赛结束！")
		combatTime : setVisible(false) 
	end
end

function SubStriveView.__initFinalView( self )
	print("type: ",self.msg.type)
	print("state:",self.msg.state)
	local layerBG = cc.Sprite : create("ui/bg/welkin_3.jpg")
	layerBG           : setTag(START_BG)
    layerBG 		  : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    self.m_rootLayer  : addChild(layerBG,0)
    
    local downDins = ccui.Scale9Sprite:createWithSpriteFrameName("ui_base.png")
    downDins       : setContentSize(cc.size(layerBG:getContentSize().width,60))
    downDins       : setPosition(cc.p(self.m_winSize.width/2,30))
    downDins  	   : setOpacity(180)
    layerBG        : addChild(downDins) 

    local function backEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("返回上一个场景")
	        self : __closeWindow()
	        cc.Director : getInstance() : popScene()
    	end
    end
    
    local backButton = gc.CButton:create()
	backButton : addTouchEventListener(backEvent)
	backButton : setAnchorPoint( 1, 1 )
	backButton : loadTextures("general_view_close.png")
	backButton : setSoundPath("bg/ui_sys_clickoff.mp3")
	backButton : setPosition(cc.p(self.m_winSize.width+45,self.m_winSize.height+20))
	backButton : ignoreContentAdaptWithSize(false)
    backButton : setContentSize(cc.size(120,120))
	layerBG    : addChild(backButton)

	local function explainEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("说明")
    		local explainView  = require("mod.general.ExplainView")()
			local explainLayer = explainView : create(40218,true)
    	end
    end

    local explainButton = gc.CButton:create()
	explainButton : addTouchEventListener(explainEvent)
	explainButton : loadTextures("general_help.png")
	-- explainButton : setTitleText("")
	-- explainButton : setTitleFontSize(24)
	-- explainButton : setTitleFontName(_G.FontName.Heiti)
	explainButton : setPosition(cc.p(layerBG : getContentSize().width/2 - self.m_winSize.width/2+80,30))
	layerBG       : addChild(explainButton)

	local function guessEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("欢乐竞猜")
    		local msg = REQ_WRESTLE_REQUEST_GUESS()
    		_G.Network: send(msg)
    	end
    end

    local guessButton = gc.CButton:create()
	guessButton : addTouchEventListener(guessEvent)
	guessButton : loadTextures("ui_strive_guess.png")
	-- guessButton : setTitleText("")
	-- guessButton : setTitleFontSize(24)
	-- guessButton : setTitleFontName(_G.FontName.Heiti)
	--guessButton : setButtonScale(0.8)
	guessButton : setPosition(layerBG : getContentSize().width/2-self.m_winSize.width/2 + 50,self.m_winSize.height-50)
	layerBG     : addChild(guessButton)

	local smallTitle= cc.Sprite : createWithSpriteFrameName("ui_strive_finals.png")
	smallTitle      : setPosition(cc.p(layerBG : getContentSize().width/2,480))
	layerBG         : addChild(smallTitle)

	local combatMsg = _G.Util : createLabel("下轮比赛开始",20)
	-- combatMsg       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	combatMsg       : setAnchorPoint(cc.p(1,0.5))
	combatMsg       : setPosition(cc.p(layerBG : getContentSize().width/2,27))
	combatMsg       : setTag(COMBAT_MSG)
	layerBG         : addChild(combatMsg)

	local combatTime= _G.Util : createLabel("00:00:00",20)
	combatTime      : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	combatTime      : setAnchorPoint(cc.p(0,0.5))
	combatTime      : setPosition(cc.p(layerBG : getContentSize().width/2,27))
	combatTime      : setTag(COMBAT_TIME)
	layerBG         : addChild(combatTime)

	local function finalEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("巅峰之战")
    		local msg = REQ_WRESTLE_REQUEST_KING()
    		_G.Network: send(msg)
    	end
    end

    local finalButton = gc.CButton:create("general_btn_gold.png")
    finalButton : addTouchEventListener(finalEvent)
    finalButton : setTitleText("巅峰对决")
	finalButton : setTitleFontSize(22)
	finalButton : setTitleFontName(_G.FontName.Heiti)
	finalButton : setPosition(cc.p(layerBG : getContentSize().width/2,130))
	layerBG     : addChild(finalButton)
	finalButton : setVisible(false)      

    local finalTips = gc.CButton:create()
	finalTips : loadTextures("ui_strive_win_box.png","ui_strive_win_box.png")
	local cBtnSize  = finalTips : getContentSize()
	finalTips : ignoreContentAdaptWithSize(false)
	finalTips : setTitleText("")
	finalTips : setTitleFontSize(20)
	finalTips : setTitleFontName(_G.FontName.Heiti)
	finalTips : setTitleColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	finalTips : setPosition(cc.p(layerBG : getContentSize().width/2,330))
	layerBG   : addChild(finalTips)

	local tips  = cc.Sprite : createWithSpriteFrameName("ui_strive_tips.png")
	tips        : setPosition(cc.p(layerBG : getContentSize().width/2,370))
	tips        : setVisible(false)
	layerBG     : addChild(tips)

	local function gameEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("我的比赛")
    		local msg = REQ_WRESTLE_REQUEST_MY_GAME()
    		_G.Network: send(msg)
    	end
    end

    local gameButton = gc.CButton:create()
	gameButton : addTouchEventListener(gameEvent)
	gameButton : loadTextures("general_btn_gold.png")
	gameButton : setTitleText("我的比赛")
	gameButton : setTitleFontSize(22)
	gameButton : setTitleFontName(_G.FontName.Heiti)
	gameButton : setPosition(cc.p(layerBG:getContentSize().width/2+self.m_winSize.width/2-110,27))
	layerBG    : addChild(gameButton)

	local flag = false
	for k,v in pairs(self.msg.data) do
		if (v.uid == _G.GPropertyProxy:getMainPlay():getUid()) and (v.is_fail == 0) then
			flag = true
		end
	end

	if not flag and self.msg.state~=6 then
		gameButton : setTouchEnabled(false)
		gameButton : setGray()
	end

	if self.msg.state == 6 then
		tips : setVisible(true)
		finalButton : setVisible(true)
	else
		tips : setVisible(false)
		finalButton : setVisible(false)
	end
	
	if self.msg.state >= 6 then
		gameButton : setTouchEnabled(false)
		gameButton : setGray()

		tips : setVisible(true)
		finalButton : setVisible(true)
	end

	if self.msg.state==7 then
		local name = ""
		for k,v in pairs(self.msg.data) do
			if v.is_fail == 0 then
				name = v.name
			end
		end
		finalTips : setTitleText(name)

		local newIcon  = cc.Sprite : createWithSpriteFrameName("ui_strive_tips_win.png")
		tips : setSpriteFrame(newIcon:getSpriteFrame())
		tips : setPositionY(390)
	end

	local leftWidth = layerBG : getContentSize().width/2 - 323
	local rightWidth= layerBG : getContentSize().width/2 + 323

	self.dinsPoint = 
	{
		[16] = cc.p(rightWidth-3,110),
		[15] = cc.p(rightWidth-3,160),
		[14] = cc.p(rightWidth-3,240),
		[13] = cc.p(rightWidth-3,290),
		[12] = cc.p(rightWidth-3,370),
		[11] = cc.p(rightWidth-3,420),
		[10] = cc.p(rightWidth-3,500),
		[9] = cc.p(rightWidth-3,550),
		[8] = cc.p(leftWidth+3,110),
		[7]= cc.p(leftWidth+3,160),
		[6]= cc.p(leftWidth+3,240),
		[5]= cc.p(leftWidth+3,290),
		[4]= cc.p(leftWidth+3,370),
		[3]= cc.p(leftWidth+3,420),
		[2]= cc.p(leftWidth+3,500),
		[1]= cc.p(leftWidth+3,550),
	}
	for i=1,16 do
		local dins   = cc.Sprite : createWithSpriteFrameName("ui_strive_win_box.png")
		-- dins         : setPreferredSize(cc.size(160,40))
		dins 		 : setPosition(self.dinsPoint[i])
		layerBG      : addChild(dins,0)
	end
	if self.msg.count >0 then
		for i=1,16 do
			if self.msg.data[i] then
				local name   = _G.Util : createLabel(self.msg.data[i].name,20)
				name         : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
				name         : setPosition(cc.p(self.dinsPoint[i].x,self.dinsPoint[i].y))
				layerBG      : addChild(name,1)
			end
		end
	end
	self.lineLight = SubStriveView.lineLight
	if not self.lineLight then
		SubStriveView.lineLight = 
		{	
			[16] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,110),
					cc.p(rightWidth-120,110+12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,110+25),
					cc.p(rightWidth-160,168),
				},
				[3] = 
				{
					cc.p(rightWidth-180,200),
					cc.p(rightWidth-200,265),
				},
				[4] =
				{
					cc.p(rightWidth-224,330),
				}
			},
			[15] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,160),
					cc.p(rightWidth-120,160-12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,160-25),
					cc.p(rightWidth-160,168),
				},
				[3] = 
				{
					cc.p(rightWidth-180,200),
					cc.p(rightWidth-200,265),
				},
				[4] = 
				{
					cc.p(rightWidth-224,330),
				}
			},
			[14] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,240),
					cc.p(rightWidth-120,240+12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,240+25),
					cc.p(rightWidth-160,232),
				},
				[3] = 
				{
					cc.p(rightWidth-180,200),
					cc.p(rightWidth-200,265),
				},
				[4] = 
				{
					cc.p(rightWidth-224,330),
				}
			},
			[13] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,290),
					cc.p(rightWidth-120,290-12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,290-25),
					cc.p(rightWidth-160,232),
				},
				[3] = 
				{
					cc.p(rightWidth-180,200),
					cc.p(rightWidth-200,265),
				},
				[4] = 
				{
					cc.p(rightWidth-224,330),
				}
			},
			[12] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,370),
					cc.p(rightWidth-120,370+12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,370+25),
					cc.p(rightWidth-160,428),
				},
				[3] = 
				{
					cc.p(rightWidth-180,460),
					cc.p(rightWidth-200,395),
				},
				[4] = 
				{
					cc.p(rightWidth-224,330),
				}
			},
			[11] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,420),
					cc.p(rightWidth-120,420-12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,395),
					cc.p(rightWidth-160,428),
				},
				[3] = 
				{
					cc.p(rightWidth-180,460),
					cc.p(rightWidth-200,395),
				},
				[4] = 
				{
					cc.p(rightWidth-224,330),
				}
			},
			[10] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,500),
					cc.p(rightWidth-120,500+12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,500+25),
					cc.p(rightWidth-160,492),
				},
				[3] = 
				{
					cc.p(rightWidth-180,460),
					cc.p(rightWidth-200,395),
				},
				[4] = 
				{
					cc.p(rightWidth-224,330),
				}
			},
			[9] = 
			{
				[1] = 
				{
					cc.p(rightWidth-100,550),
					cc.p(rightWidth-120,550-12.5),
				},
				[2] = 
				{
					cc.p(rightWidth-140,550-25),
					cc.p(rightWidth-160,492),
				},
				[3] = 
				{
					cc.p(rightWidth-180,460),
					cc.p(rightWidth-200,395),
				},
				[4] =
				{
					cc.p(rightWidth-224,330),
				}
			},
			[8] = 
			{
				[1] = 
				{
					cc.p(leftWidth+100,110),
					cc.p(leftWidth+120,110+12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,110+25),
					cc.p(leftWidth+160,168),
				},
				[3] = 
				{
					cc.p(leftWidth+180,200),
					cc.p(leftWidth+200,265),
				},
				[4] =
				{
					cc.p(leftWidth+224,330),
				}
			},
			[7]= 
			{
				[1] = 
				{
					cc.p(leftWidth+100,160),
					cc.p(leftWidth+120,160-12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,160-25),
					cc.p(leftWidth+160,168),
				},
				[3] = 
				{
					cc.p(leftWidth+180,200),
					cc.p(leftWidth+200,265),
				},
				[4] = 
				{
					cc.p(leftWidth+224,330),
				}
			},
			[6]= 
			{
				[1] = 
				{
					cc.p(leftWidth+100,240),
					cc.p(leftWidth+120,240+12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,240+25),
					cc.p(leftWidth+160,232),
				},
				[3] = 
				{
					cc.p(leftWidth+180,200),
					cc.p(leftWidth+200,265),
				},
				[4] = 
				{
					cc.p(leftWidth+224,330),
				}
			},
			[5]= 
			{
				[1] = 
				{
					cc.p(leftWidth+100,290),
					cc.p(leftWidth+120,290-12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,290-25),
					cc.p(leftWidth+160,232),
				},
				[3] = 
				{
					cc.p(leftWidth+180,200),
					cc.p(leftWidth+200,265),
				},
				[4] = 
				{
					cc.p(leftWidth+224,330),
				}
			},
			[4]= 
			{
				[1] = 
				{
					cc.p(leftWidth+100,370),
					cc.p(leftWidth+120,370+12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,370+25),
					cc.p(leftWidth+160,428),
				},
				[3] = 
				{
					cc.p(leftWidth+180,460),
					cc.p(leftWidth+200,395),
				},
				[4] =
				{
					cc.p(leftWidth+224,330),
				}
			},
			[3]= 
			{
				[1] = 
				{
					cc.p(leftWidth+100,420),
					cc.p(leftWidth+120,420-12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,460),
					cc.p(leftWidth+160,428),
				},
				[3] = 
				{
					cc.p(leftWidth+180,460),
					cc.p(leftWidth+200,395),
				},
				[4] =
				{
					cc.p(leftWidth+224,330),
				}
			},
			[2]= 
			{
				[1] = 
				{
					cc.p(leftWidth+100,500),
					cc.p(leftWidth+120,500+12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,500+25),
					cc.p(leftWidth+160,492),
				},
				[3] = 
				{
					cc.p(leftWidth+180,460),
					cc.p(leftWidth+200,395),
				},
				[4] = 
				{
					cc.p(leftWidth+224,330),
				}
			},
			[1]= 
			{
				[1] = 
				{
					cc.p(leftWidth+100,550),
					cc.p(leftWidth+120,550-12.5),
				},
				[2] = 
				{
					cc.p(leftWidth+140,550-25),
					cc.p(leftWidth+160,492),
				},
				[3] = 
				{
					cc.p(leftWidth+180,460),
					cc.p(leftWidth+200,395),
				},
				[4] =
				{
					cc.p(leftWidth+224,330),
				}
			},
		}
		self.lineLight = SubStriveView.lineLight
	end

	for i=1,2 do
		for j=1,8 do
			local line   = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_blue_line.png")
			line         : setPreferredSize(cc.size(40,2))
			if i==1 and j<3 then
				line : setPosition(cc.p(leftWidth+100,110+(j-1)*50))
			elseif i==1 and j<5 then
				line : setPosition(cc.p(leftWidth+100,140+(j-1)*50))
			elseif i==1 and j>6 then
				line : setPosition(cc.p(leftWidth+100,180+(j-1)*50+20))
			elseif i==1 and j>4 then
				line : setPosition(cc.p(leftWidth+100,150+(j-1)*50+20))
			elseif i==2 and j<3 then
				line : setPosition(cc.p(rightWidth-100,110+(j-1)*50))
			elseif i==2 and j<5 then
				line : setPosition(cc.p(rightWidth-100,140+(j-1)*50))
			elseif i==2 and j>6 then
				line : setPosition(cc.p(rightWidth-100,180+(j-1)*50+20))
			elseif i==2 and j>4 then
				line : setPosition(cc.p(rightWidth-100,150+(j-1)*50+20))
			end
			layerBG      : addChild(line)
		end

		for j=1,4 do
			local line   = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_blue_line.png")
			line         : setPreferredSize(cc.size(50,2))
			line         : setRotation(90)
			if i==1 and j<2 then
				line : setPosition(cc.p(leftWidth+120,135+(j-1)*100))
			elseif i==1 and j<3 then
				line : setPosition(cc.p(leftWidth+120,165+(j-1)*100))
			elseif i==1 and j>3 then
				line : setPosition(cc.p(leftWidth+120,205+(j-1)*100+20))
			elseif i==1 and j>2 then
				line : setPosition(cc.p(leftWidth+120,175+(j-1)*100+20))
			elseif i==2 and j<2 then
				line : setPosition(cc.p(rightWidth-120,135+(j-1)*100))
			elseif i==2 and j<3 then
				line : setPosition(cc.p(rightWidth-120,165+(j-1)*100))
			elseif i==2 and j>3 then
				line : setPosition(cc.p(rightWidth-120,205+(j-1)*100+20))
			elseif i==2 and j>2 then
				line : setPosition(cc.p(rightWidth-120,175+(j-1)*100+20))
			end
			layerBG      : addChild(line)

			local line1  = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_blue_line.png")
			line1        : setPreferredSize(cc.size(40,2))
			if i==1 and j<2 then
				line1 : setPosition(cc.p(leftWidth+140,135+(j-1)*100))
			elseif i==1 and j<3 then
				line1 : setPosition(cc.p(leftWidth+140,165+(j-1)*100))
			elseif i==1 and j>3 then
				line1 : setPosition(cc.p(leftWidth+140,205+(j-1)*100+20))
			elseif i==1 and j>2 then
				line1 : setPosition(cc.p(leftWidth+140,175+(j-1)*100+20))
			elseif i==2 and j<2 then
				line1 : setPosition(cc.p(rightWidth-140,135+(j-1)*100))
			elseif i==2 and j<3 then
				line1 : setPosition(cc.p(rightWidth-140,165+(j-1)*100))
			elseif i==2 and j>3 then
				line1 : setPosition(cc.p(rightWidth-140,205+(j-1)*100+20))
			elseif i==2 and j>2 then
				line1 : setPosition(cc.p(rightWidth-140,175+(j-1)*100+20))
			end
			layerBG      : addChild(line1)
		end

		for j=1,2 do
			local line   = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_blue_line.png")
			line         : setPreferredSize(cc.size(135,2))
			line         : setRotation(90)
			if i==1 then
				line : setPosition(cc.p(leftWidth+160,200+(j-1)*260))
			elseif i==2 then
				line : setPosition(cc.p(rightWidth-160,200+(j-1)*260))
			end
			layerBG      : addChild(line)

			local line1  = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_blue_line.png")
			line1        : setPreferredSize(cc.size(40,2))
			if i==1 then
				line1 : setPosition(cc.p(leftWidth+180,200+(j-1)*260))
			elseif i==2 then
				line1 : setPosition(cc.p(rightWidth-180,200+(j-1)*260))
			end
			layerBG      : addChild(line1)
		end

		local line   = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_blue_line.png")
		line         : setPreferredSize(cc.size(260,2))
		line         : setRotation(90)
		if i==1 then
			line : setPosition(cc.p(leftWidth+200,330))
		elseif i==2 then
			line : setPosition(cc.p(rightWidth-200,330))
		end
		layerBG      : addChild(line)

		local line1  = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_blue_line.png")
		line1        : setPreferredSize(cc.size(50,2))
		if i==1 then
			line1 : setPosition(cc.p(leftWidth+224,330))
		elseif i==2 then
			line1 : setPosition(cc.p(rightWidth-224,330))
		end
		layerBG      : addChild(line1)
	end

	for i=1,16 do
		if self.msg.data[i] then
			print("is_fail",self.msg.data[i].is_fail,"fail_turn",self.msg.data[i].fail_turn,"i",i,"name",self.msg.data[i].name)
		end
	end

	for i=1,16 do
		if self.msg.data[i] then
			local turn = 0
			print("i",i)
			if self.msg.data[i].is_fail==0 and self.msg.turn > 0 then
				if self.msg.state > 4 and self.msg.state <7 then
					turn = 3
				elseif self.msg.state == 7 then
					turn = 4
				else
					turn = self.msg.turn-1
				end
			elseif self.msg.data[i].fail_turn >1 then
				turn = self.msg.data[i].fail_turn - 1
			end
			while turn >0 do
				self : __initLightLine(i,turn,layerBG)
				turn = turn - 1
			end
		end
	end
end

function SubStriveView.__initLightLine( self,id,number,_layer )
	print("id,number=======>>>>>",id,number)
	for i=1,#self.lineLight[id][number] do
		local line   = ccui.Scale9Sprite : createWithSpriteFrameName("ui_strive_yellow_line.png")
		if number == 1 then
			if i==1 then
				line : setPreferredSize(cc.size(40,3))
			elseif i==2 then
				line : setPreferredSize(cc.size(25,3))
				line : setRotation(90)	
			end
		elseif number == 2 then
			if i==1 then
				line : setPreferredSize(cc.size(40,3))
			elseif i==2 then
				line : setPreferredSize(cc.size(67,3))
				line : setRotation(90)
			end
		elseif number == 3 then
			if i==1 then
				line : setPreferredSize(cc.size(40,3))
			elseif i==2 then
				line : setPreferredSize(cc.size(130,3))
				line : setRotation(90)
			end
		elseif number == 4 then
			line : setPreferredSize(cc.size(50,3))
		end
		line   : setPosition(self.lineLight[id][number][i])
		_layer : addChild(line)
	end
end

function SubStriveView.__initGuessView( self,_msg )
	print("self.myZBView",self.myZBView)
	if self.myZBView~=nil then
		return
	end
	local frameSize=cc.size(520,370)
	local msg 		= _ackMsg
	self.myZBView  = require( "mod.general.BattleMsgView"  )()
  	local ZB_D2Base = self.myZBView : create("欢乐竞猜",frameSize,1)
  	local myWidth   = self.myZBView : getSize().width
  	local myHeight  = self.myZBView : getSize().height
  	local function func( send,eventType )
  		self.myZBView=nil
  	end
  	self.myZBView:addCloseFun(func)

	self.guessUid_1 = _msg.uid_1
	self.guessUid_2 = _msg.uid_2 

	local fontSize 	  = 20

	local currentRMB  = _G.Util : createLabel("请选择竞猜的冠军和亚军选手",fontSize)
	currentRMB        : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	currentRMB        : setPosition(cc.p(myWidth/2,myHeight-70))
	ZB_D2Base         : addChild(currentRMB)

	local line        = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	line              : setPreferredSize(cc.size(myWidth-20,2))
	line              : setPosition(cc.p(myWidth/2,265))
	ZB_D2Base        : addChild(line)

	local line1       = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	line1             : setPreferredSize(cc.size(myWidth-20,2))
	line1             : setPosition(cc.p(myWidth/2,50))
	ZB_D2Base        : addChild(line1)

	self              : __createLabel(1,65,210,_msg.name_1,ZB_D2Base)
	self              : __createLabel(2,65,150,_msg.name_2,ZB_D2Base)

	local betRMB      = _G.Util : createLabel("100元宝",fontSize)
	-- betRMB            : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	betRMB        	  : setPosition(cc.p(myWidth/2,125))
	ZB_D2Base        : addChild(betRMB)

	local function betEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			if self.guessUid_1 == 0 or self.guessUid_2 == 0 then
				local command = CErrorBoxCommand("请选择竞猜的冠军和亚军选手")
                controller :sendCommand( command )
            else
            	self : __initBetTips()
			end
		end
	end 

	local betButton= gc.CButton:create()
	betButton     : addTouchEventListener(betEvent)
	betButton 	  : loadTextures("general_btn_lv.png")
	betButton     : setTitleText("投注")
	if  _msg.state == 1 then
		betButton : setTitleText("已投注")
		betButton : setTouchEnabled(false)
		betButton : setGray()
	else
		betButton : setTitleText("投注")
		betButton : setDefault()
	end
	
	if self.msg.state and self.msg.state>=4 then
		betButton : setTouchEnabled(false)
		betButton : setGray()
	end
	betButton     : setTitleFontSize(fontSize+4)
	betButton     : setTitleFontName(_G.FontName.Heiti)
	betButton     : setPosition(cc.p(myWidth/2,80))
	ZB_D2Base    : addChild(betButton)

	local tipLab  = _G.Util : createLabel("投注时间:初赛结束—决赛开始,投注后不可更改选手名单",18)
	tipLab        : setPosition(cc.p(myWidth/2,25))
	tipLab        : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	ZB_D2Base    : addChild(tipLab) 
end

function SubStriveView.updateAllRMB( self,rmb )
	self.guessAllRMB = rmb
end

function SubStriveView.__createLabel( self,type,width,height,_name,threeBG)
	local fontSize = 20
	local lab  = 0
	if type == 1 then
		lab    = _G.Util : createLabel("冠军:",fontSize)
	else
		lab    = _G.Util : createLabel("亚军:",fontSize)
	end
	-- lab          : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	lab          : setAnchorPoint(cc.p(0,0))
	lab          : setPosition(cc.p(width,height))
	threeBG      : addChild(lab)
	width        = width + lab : getContentSize().width+10

	local dins   = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
	dins         : setPreferredSize(cc.size(210,30))
	dins         : setAnchorPoint(cc.p(0,0))
	dins         : setPosition(cc.p(width,height))
	threeBG      : addChild(dins)
	width        = width + dins : getContentSize().width+15

	local name   = _G.Util : createLabel(_name or "未选择",fontSize)
	name         : setPosition(cc.p(dins : getContentSize().width/2,dins : getContentSize().height/2-2))
	dins         : addChild(name)
	if type == 1 then
		self.guessName_1 = name
	else
		self.guessName_2 = name
	end

	local function buttonEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		if type == 1 then
				print("选择冠军")
			else
				print("选择亚军")
			end
			self : __initSelectLayer(type)
    	end
    end

    local button = gc.CButton:create()
	button : addTouchEventListener(buttonEvent)
	button : loadTextures("general_btn_gold.png")
	button : setTitleText("选 择")
	if _name then
		button : setTouchEnabled(false)
		button : setGray()
	end

	if self.msg.state and self.msg.state>=4 then
		button : setTouchEnabled(false)
		button : setGray()
	end
	button : setTitleFontSize(fontSize+4)
	button : setTitleFontName(_G.FontName.Heiti)
	-- button : setButtonScale(0.8)
	button : setPosition(cc.p(width+60,height+14))
	threeBG: addChild(button)
end

function SubStriveView.__initSelectLayer( self,type )
	print("初始化选择界面")
	local myText 	= { "冠军人选", "亚军人选" }
	local frameSize=cc.size(618,485)
	self.combatView  = require("mod.general.BattleMsgView")()
  	self.combatBG = self.combatView : create(myText[type],frameSize)
  	self.m_mainSize = self.combatView : getSize()

  	local myWidth   = self.m_mainSize.width
  	local myHeight  = self.m_mainSize.height

	-- self : __initCloseSelectBtn()
	local fontSize = 20

	local height    = myHeight-70
	local lab1      = _G.Util : createLabel("名字",20)
	-- lab1            : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	lab1            : setPosition(cc.p(90,height))
	self.combatBG        : addChild(lab1,0)

	local lab2      = _G.Util : createLabel("等级",20)
	-- lab2            : setColor(color)
	lab2            : setPosition(cc.p(230,height))
	self.combatBG        : addChild(lab2,0)

	local lab3      = _G.Util : createLabel("战力",20)
	-- lab3            : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	lab3            : setPosition(cc.p(375,height))
	self.combatBG        : addChild(lab3,0)

	local floorSize=cc.size(myWidth-4,myHeight-90)
  	local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
  	floorSpr:setPreferredSize(floorSize)
  	floorSpr:setPosition(myWidth/2,myHeight/2-42)
  	self.combatBG:addChild(floorSpr)

    print("初始化滚动框")

	local Sc_Container = cc.Node : create()
    local ScrollView   = cc.ScrollView : create()
    
    local count = self.msg.count

    local viewSize     = cc.size(myWidth,floorSize.height-5)
	local ScrollHeigh   = viewSize.height/6
    self.containerSize = cc.size(myWidth, ScrollHeigh*count)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(self.containerSize)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-self.containerSize.height))
    ScrollView 		: setAnchorPoint(cc.p(0,0))
    ScrollView      : setPosition(cc.p(0,0))
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    Sc_Container    : addChild(ScrollView)
    -- Sc_Container    : setAnchorPoint(cc.p(0,0))
    Sc_Container    : setPosition(cc.p(0,5))
    self.combatBG   : addChild(Sc_Container)

    if count > 6 then
	    local barView = require("mod.general.ScrollBar")(ScrollView)
	    barView 	  : setPosOff(cc.p(-8,0))
    	-- barView 	  : setMoveHeightOff(-5)
    end

    local data = {}

    for i=1,16 do
    	if self.msg.data[i] then
    		data[i] = self.msg.data[i]
    	else
    		data[i] = {powerful = 0}
    	end
    end

    table.sort(data,function(a,b) return a.powerful>b.powerful end )

    for k,v in pairs(data) do
    	print(k,v.powerful)
    end

    for i=1,count do
    	local spr = self : __createCombatLabel(i,type,data[i])
    	spr:setPosition(viewSize.width/2,self.containerSize.height - (i-1)*ScrollHeigh - 33)
    	ScrollView: addChild(spr)
    end
end

-- function SubStriveView.__initCloseSelectBtn( self )
-- 	local function closeCallBack(sender, eventType)
-- 		if eventType == ccui.TouchEventType.ended then

-- 			cc.Director : getInstance() : getRunningScene() : getChildByTag(SELECT_UI_TAG) : removeFromParent()
-- 		end
-- 	end
-- 	local m_closeBtn= gc.CButton : create("general_close.png")
-- 	self.m_closeBtnS= m_closeBtn : getContentSize()
-- 	m_closeBtn      : setAnchorPoint(cc.p(0.5,0.5))
-- 	m_closeBtn      : setPosition(cc.p(self.m_captureSize.width/2-24,self.m_captureSize.height/2-36))
-- 	m_closeBtn      : addTouchEventListener(closeCallBack)
-- 	m_closeBtn      : setSoundPath("bg/ui_sys_clickoff.mp3")
-- 	cc.Director 	: getInstance() : getRunningScene() : getChildByTag(SELECT_UI_TAG) : addChild(m_closeBtn, _G.Const.CONST_MAP_ZORDER_LAYER+20)
-- end

-- function SubStriveView.__initSelectView( self,type )
	
-- end

-- function SubStriveView.__initPersonMsgScrollView( self,_layer,type )
	
-- end

function SubStriveView.__createCombatLabel( self,i,_type,_msg)
	local sprSize=cc.size(self.m_mainSize.width-15,60)
	local msgSpr   = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
    msgSpr         : setPreferredSize( sprSize )

    local fontSize = 20
    local name     = _G.Util : createLabel(_msg.name,fontSize)
    name           : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    name           : setPosition(cc.p(83,sprSize.height/2))
    msgSpr         : addChild(name)

    local lv       = _G.Util : createLabel(_msg.lv,fontSize)
    -- lv             : setColor(color)
    lv             : setAnchorPoint(cc.p(0,0.5))
    lv             : setPosition(cc.p(210,sprSize.height/2))
    msgSpr         : addChild(lv)

    local power    = _G.Util : createLabel(_msg.powerful,fontSize)
    power          : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    power          : setAnchorPoint(cc.p(0,0.5))
    power          : setPosition(cc.p(335,sprSize.height/2))
    msgSpr         : addChild(power)

    local function buttonEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		if _type == 1 then
				self.guessUid_1  = _msg.uid
				self.guessName_1 : setString(_msg.name)
			else
				self.guessUid_2 = _msg.uid
				self.guessName_2 : setString(_msg.name)
			end
			local Position  = send : getWorldPosition()
	  		print("Position.y",Position.y)
	      	if Position.y > 445 or Position.y < 97 then 
	         	return 
	      	end
	  		-- local tag  = obj : getTag()
	  		self.combatView:delayCallFun()
    	end
    end

    local button = gc.CButton:create()
	button : addTouchEventListener(buttonEvent)
	button : loadTextures("general_btn_gold.png")
	button : setTitleText("选  择")
	button : setTitleFontSize(fontSize+4)
	button : setTitleFontName(_G.FontName.Heiti)
	-- button : setButtonScale(0.8)
	button : setPosition(cc.p(512,sprSize.height/2))
	msgSpr : addChild(button)

    return msgSpr
end

function SubStriveView.__initBetTips( self)
	print("__initBetTips")

	-- local size = cc.Director : getInstance() : getWinSize()

	local function sure()
		local msg = REQ_WRESTLE_GUESS_BET()
		msg       : setArgs(self.guessUid_1,self.guessUid_2)
		_G.Network: send(msg)
    end

    local function cancel( ... )
    	print("取消")
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(size.width/2,size.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    -- view        : setTitleLabel("提示")

    local layer = view:getMainlayer()
	local betLab  = _G.Util : createLabel("花费100元宝进行投注?",20)
	betLab        : setPosition(cc.p(0,30))
	layer         : addChild(betLab)

	local centerLab = _G.Lang.LAB_N[940]
	if centerLab ~= nil then
        local label =_G.Util : createLabel(centerLab,18)
		label 		: setPosition(cc.p(0,5))
		layer 		: addChild(label,88)
    end
end

function SubStriveView.__getTimeStr( self,_time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)
    local time   = tostring(hour)..":"..tostring(min)..":"..second
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

function SubStriveView.__closeWindow( self )
	_G.Scheduler 		 : unschedule(self.m_timeScheduler)
	self.m_timeScheduler = nil     
	self.m_rootLayer     : removeFromParent()
	self 			     : unregister()
end

return SubStriveView