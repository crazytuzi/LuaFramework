local KejuView = classGc( view, function( self, _openType )
	-- self.m_openType = _openType

	self.m_winSize  	= cc.Director:getInstance() : getWinSize()
	self.m_viewSize 	= cc.size( 780, 460 )
	self.FONTSIZE 		= 20
	self.Count 			  = false
	self.LeTimes 		  = { 10, 10 }
	self.Btn_Answer_state = { false, false, false, false }

	self.m_mediator 	= require("mod.smodule.KeJuMediator")() 
	self.m_mediator 	: setView(self) 
end)
local color1 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LBLUE )
local color2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN 	)
local color3 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN 	)
local color4 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_YELLOWISH    )
local color5 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD  )
local color6 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED 	 )

local Tag_Spr_LeftView  = 101
local Tag_Lab_GetTimes  = 102
local Tag_Lab_Time 		= 103
local Tag_Lab_Ranking  	= 104
local Tag_Lab_Score		= 105
local Tag_Btn_JoinKeJu  = 111

local Tag_Spr_RightView = 201
local Tag_Spr_RightView2= 202

local Tag_Lab_Title 	= 301
local Tag_Lab_MyTest	= 302
local Tag_Spr_Right 	= 303
local Tag_Spr_Wrong 	= 304
local Tag_Lab_Title_Right = 305
local Tag_Lab_leaveTime = 306
local Tag_Btn_GoWrong 	= 307
local Tag_Btn_GivMoney	= 308

local Tag_Btn_Answer 	= { 311, 312, 313, 314 }
local Tag_Lab_Answer 	= { 321, 322, 323, 324 }

local Tag_NoTouch 		= { 1111, 1112 }
local NoTouchSet		= { false, false }
 
local My_Gap  			= 60


function KejuView.create( self )
	self.m_settingView = require( "mod.general.NormalView" )()
	self.gamSetLabel   = self.m_settingView : create( "御前科举" )
	self.m_settingView : setTitle( "御前科举" )

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.gamSetLabel)
	
	self:init()

	return tempScene
end

function KejuView.init( self )

	local function closeFunSetting()
		self : closeWindow()
	end
  	local Btn_Close    = self.m_settingView : getCloseBtn()
  	self.m_settingView : addCloseFun(closeFunSetting)

  	self.mainContainer = cc.Node : create()
	self.mainContainer : setPosition( cc.p( self.m_winSize.width/2 , self.m_winSize.height/2-20 ) )
	self.gamSetLabel   : addChild( self.mainContainer )

	self : Create_LeftView()
	-- 发送 答题面板 协议
	self : REQ_KEJU_ASK_KEJU()
end

function KejuView.closeWindow( self )
	if self.Scheduler ~= nil then 
 		_G.Scheduler : unschedule( self.Scheduler )
 		self.Scheduler = nil
 	end
 	if self.Scheduler_2 ~= nil then 
 		_G.Scheduler : unschedule( self.Scheduler_2 )
 		self.Scheduler = nil
 	end
	print( "开始关闭" )
	if self.gamSetLabel == nil then return end
	self.gamSetLabel=nil
	cc.Director:getInstance():popScene()
	self:destroy()
end
-- 请求 答题面板 开始
function KejuView.REQ_KEJU_ASK_KEJU( self )
	local msg  = REQ_KEJU_ASK_KEJU()
	_G.Network : send( msg )
end

function KejuView.Ask_reply_1( self, _ackMsg )
	print( "进入第一个" )
	local msg 	= _ackMsg
 	print( "玩家名字：	", msg.name 	)
 	print( "剩余答题次数：", msg.times 	)
 	print( "最佳排名：	", msg.rank 	)
 	print( "得分：		", msg.score 	)
 	print( "耗时：		", self : _getTimeStr(msg.time) )
 	print( "所获奖励：	", msg.reward 	)
 	print( "数量：		", msg.count 	)
    for i=1,msg.count do               -- { 1:排行榜信息块44525 }
        print( "名次：		", msg.msg_xxx[i].rank 	)
        print( "玩家ID：		", msg.msg_xxx[i].uid 	)
        print( "玩家名字：	", msg.msg_xxx[i].name 	)
        print( "得分：		", msg.msg_xxx[i].score )
        print( "耗时：		", self : _getTimeStr(msg.msg_xxx[i].times) )
        print( "所获奖励：	", msg.msg_xxx[i].reward_rank)
    end
    print( "msg = ", msg, msg.reward )
    self.currentNum = 1
    self : Chuange_LeftText( msg )
    self : createRanking( msg.count, msg.msg_xxx )

end

function KejuView.Ask_reply_2( self, _ackMsg )
	print( "进入第二个" )
	local msg = _ackMsg
	print( "玩家名字：	", msg.name2 	)
 	print( "剩答题次数： 	", msg.times2 	)
 	print( "最佳排名：	", msg.rank2 	)
 	print( "得分：		", msg.score2 	)
 	print( "耗时：		", msg.time2 	)
 	print( "所获奖励：	", msg.reward2 	)
 	print( "题目ID：		", msg.msg_xxx2.id 		)
 	print( "第几题：		", msg.msg_xxx2.num 	)
 	print( "答对题目数： 	", msg.msg_xxx2.right 	)
 	print( "开始时间：	", self:_getTimeStr( msg.msg_xxx2.time ) )
 	print( "剩余算卦次数：", msg.msg_xxx2.times1  )
 	print( "剩余贿赂次数：", msg.msg_xxx2.times2 )
 	print( "你去掉的答案数：", 4 - msg.msg_xxx2.count )
 	local But_Check = { false, false, false, false }
 	if msg.msg_xxx2.num ~= 0 then 
	 	for i=1,msg.msg_xxx2.count do
	 		print( "保留的答案为：", msg.msg_xxx2.msg_options[i].answer )
	 		But_Check[msg.msg_xxx2.msg_options[i].answer] = true
	 	end
	 	for i=1,4 do
	 		if But_Check[i] == false then 
	 			self.Btn_Answer_state[i] = true
	 		end
	 		print( "But_Check["..i.."] = ", But_Check[i] )
	 		print( "self.Btn_Answer_state["..i.."] = ", self.Btn_Answer_state[i] )
	 	end
	end
	self.currentNum = msg.msg_xxx2.num
	self.NowTime    = msg.msg_xxx2.time
	self.rightNum   = msg.msg_xxx2.right 

 	self.LeTimes = { msg.msg_xxx2.times1, msg.msg_xxx2.times2 }
 	self.myTime  = msg.msg_xxx2.time

 	self : Create_Left_Text( msg )
end	
-- 接收 答题面板 结束
-- 请求 开始答题 开始
function KejuView.REQ_KEJU_START( self )
	local msg  = REQ_KEJU_START()
	_G.Network : send( msg )
end

function KejuView.Start_Reply( self, _ackMsg )
	local msg = _ackMsg
	print( "当前第几题：	", msg.num 		)
	print( "问题ID：		", msg.id 		)
	print( "开始时间戳：	", self : _getTimeStr( msg.time ) )
	print( "正确题目数量：", msg.num_right )
	-- 通过发送请求开始界面来提取题目刷新次数
	if msg.num == 1 then 
		self : REQ_KEJU_ASK_KEJU() 
	end
end
-- 接收 开始答题 	结束
-- 请求 答题    	开始
function KejuView.REQ_KEJU_ANSWER( self, _ackMsg )
	local msg = REQ_KEJU_ANSWER()
	msg : setArgs( _ackMsg )
	_G.Network : send( msg )
end

function KejuView.Answer_Reply( self, _ackMsg )
	local msg = _ackMsg
	print( "玩家选的答案 	= ", msg.choose )
	print( "正确答案   	= ", msg.right  )
	print( "下一题		= ", msg.next )
	self : Check_Answer( msg )
end
-- 接收 答题    	结束
-- 请求 算卦去错 	开始
function KejuView.REQ_KEJU_OUT_WRONG( self )
	local msg = REQ_KEJU_OUT_WRONG()
	_G.Network : send( msg )
end

function KejuView.Wrong_Reply( self, _ackMsg )
	self.LeTimes[1] = _ackMsg.times
	num = _ackMsg.out_answer
	print( "算挂去错,去掉的答案：", num )
	local Lab_Answer = self.mainContainer : getChildByTag( Tag_Spr_RightView2 ) : getChildByTag( Tag_Lab_Answer[num] )
	Lab_Answer : setVisible( false )
	local Btn_Answer = self.mainContainer : getChildByTag( Tag_Spr_RightView2 ) : getChildByTag( Tag_Btn_Answer[num] )
	Btn_Answer : setTouchEnabled( false )
	self.Btn_Answer_state[num] = true
end
-- 接收 算卦去错 	结束
-- 发送 贿赂考官 	开始
function KejuView.REQ_KEJU_BRIBE( self )
	local msg = REQ_KEJU_BRIBE()
	_G.Network : send( msg )
end

function KejuView.Bribe_Reply( self, _ackMsg )
	local msg = _ackMsg
	self.LeTimes[2] = msg.times
	print( "正确答案是：", _ackMsg.answer )
	self : REQ_KEJU_ANSWER( _ackMsg.answer )
end
-- 接收 贿赂考官 	结束

function KejuView.Create_LeftView( self )
	local baseSize=cc.size( 279,518 )
	local lefBase1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" )
	lefBase1 : setPreferredSize( baseSize )
	-- lefBase1 : setAnchorPoint( 0, 1 )
	lefBase1 : setPosition( -self.m_viewSize.width/2+103, -22  )
	self.mainContainer : addChild( lefBase1 )

	local base2Size= cc.size( baseSize.width-16,baseSize.height-16 ) 
	local lefBase2 = cc.Node:create()
	-- lefBase2 : setPreferredSize(base2Size)
	lefBase2 : setTag(Tag_Spr_LeftView)
	lefBase2 : setPosition( -self.m_viewSize.width/2-30, -270  )
	self.mainContainer : addChild( lefBase2 )

	local Wid_leftView = base2Size.width
	local Hei_leftView = base2Size.height
	

	local Lab_1 = _G.Util : createLabel( "开放时间", self.FONTSIZE )
	Lab_1 : setAnchorPoint( 0, 0.5 )
	Lab_1 : setPosition( 15, Hei_leftView - 45 )
	-- Lab_1 : setColor( color2 )
	lefBase2 : addChild( Lab_1 )

	local Lab_2 = _G.Util : createLabel( "周日", self.FONTSIZE )
	Lab_2 : setAnchorPoint( 0, 0.5  )
	Lab_2 : setPosition( 15, Hei_leftView - 80 )
	lefBase2 : addChild( Lab_2 )

	local Lab_2 = _G.Util : createLabel( "00:00-22:00", self.FONTSIZE )
	Lab_2 : setAnchorPoint( 0, 0.5  )
	Lab_2 : setPosition( 75, Hei_leftView - 80 )
	Lab_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	lefBase2 : addChild( Lab_2 )

	local Lab_26 = _G.Util : createLabel( "结算时间", self.FONTSIZE )
	Lab_26 : setAnchorPoint( 0, 0.5 )
	Lab_26 : setPosition( 15, Hei_leftView - 115 )
	-- Lab_26 : setColor( color2 )
	lefBase2 : addChild( Lab_26 )

	local Lab_25 = _G.Util : createLabel( "周日", self.FONTSIZE )
	Lab_25 : setAnchorPoint( 0, 0.5 )
	Lab_25 : setPosition( 15, Hei_leftView - 150 )
	lefBase2 : addChild( Lab_25 )

	local Lab_25 = _G.Util : createLabel( "22:30", self.FONTSIZE )
	Lab_25 : setAnchorPoint( 0, 0.5 )
	Lab_25 : setPosition( 75, Hei_leftView - 150 )
	Lab_25 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	lefBase2 : addChild( Lab_25 )

	local Spr_LeftLine_1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	Spr_LeftLine_1 : setContentSize( cc.size( Wid_leftView-10, 2) )
	-- Spr_LeftLine_1 : setAnchorPoint( 0, 0 )
	Spr_LeftLine_1 : setPosition( Wid_leftView/2, Hei_leftView/2+80 )
	lefBase2   : addChild( Spr_LeftLine_1 )

	local name=_G.GPropertyProxy : getMainPlay() : getName()
	local nameLab = _G.Util : createLabel( name, self.FONTSIZE )
	nameLab : setAnchorPoint( cc.p( 0, 0.5 ) )
	nameLab : setPosition( 15, Hei_leftView/2+55 )
	nameLab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	lefBase2 : addChild( nameLab )

	local Lab_21 = _G.Util : createLabel( "最佳成绩", self.FONTSIZE )
	Lab_21 : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_21 : setPosition( 15, Hei_leftView/2+20 )
	-- Lab_21 : setColor( color5 )
	lefBase2 : addChild( Lab_21 )

	local Lab_23 = _G.Util : createLabel( "排名: ", self.FONTSIZE )
	Lab_23 : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_23 : setPosition( cc.p( 15, Hei_leftView/2-15 ) )
	-- Lab_23 : setColor( color3 )
	lefBase2 : addChild( Lab_23 )

	local Lab_Ranking = _G.Util : createLabel( "", self.FONTSIZE )
	Lab_Ranking : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_Ranking : setPosition( cc.p( Lab_23 : getContentSize().width + 15 , Hei_leftView/2-15 ) )
	Lab_Ranking : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	Lab_Ranking : setTag( Tag_Lab_Ranking )
	lefBase2 : addChild( Lab_Ranking )

	local Lab_22 = _G.Util : createLabel( "得分: ", self.FONTSIZE )
	Lab_22 : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_22 : setPosition( cc.p( 15, Hei_leftView/2-50 ) )
	-- Lab_22 : setColor( color3 )
	lefBase2 : addChild( Lab_22 )

	local Lab_Score = _G.Util : createLabel( "", self.FONTSIZE )
	Lab_Score : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_Score : setPosition( cc.p( Lab_22 : getContentSize().width + 15 , Hei_leftView/2-50 ) )
	Lab_Score : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	Lab_Score : setTag( Tag_Lab_Score )
	lefBase2 : addChild( Lab_Score )

	local Lab_24 = _G.Util : createLabel( "时间: ", self.FONTSIZE )
	Lab_24 : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_24 : setPosition( cc.p( 15, Hei_leftView/2-85 ) )
	-- Lab_24 : setColor( color3 )
	lefBase2 : addChild( Lab_24 )

	local Lab_Time = _G.Util : createLabel( "", self.FONTSIZE )
	Lab_Time : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_Time : setPosition( cc.p( Lab_24 : getContentSize().width + 15 , Hei_leftView/2-85 ) )
	Lab_Time : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	Lab_Time : setTag( Tag_Lab_Time )
	lefBase2 : addChild( Lab_Time )

	local Lab_28 = _G.Util : createLabel( "奖励: ", self.FONTSIZE )
	Lab_28 : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_28 : setPosition( cc.p( 15, Hei_leftView/2 - 120 ) )
	-- Lab_28 : setColor( color5 )
	lefBase2 : addChild( Lab_28 )

	self.Lab_Goods = _G.Util : createLabel( "", self.FONTSIZE )
	self.Lab_Goods : setAnchorPoint( cc.p( 0, 0.5 ) )
	self.Lab_Goods : setPosition(Lab_28 : getContentSize().width + 15 , Hei_leftView/2 - 120 )
	self.Lab_Goods : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	lefBase2   : addChild( self.Lab_Goods )

	local Spr_LeftLine_2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	Spr_LeftLine_2 : setContentSize( cc.size( Wid_leftView-10, 2 ) )
	-- Spr_LeftLine_2 : setAnchorPoint( 0, 0 )
	Spr_LeftLine_2 : setPosition( cc.p( Wid_leftView/2, Hei_leftView - 395) )
	lefBase2   : addChild( Spr_LeftLine_2 )

	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end

	local Btn_JoinKeJu = gc.CButton : create()
	Btn_JoinKeJu  : loadTextures( "general_btn_gold.png")
	Btn_JoinKeJu  : setTitleText( "参加答题" )
	Btn_JoinKeJu  : setTitleFontName( _G.FontName.Heiti )
	Btn_JoinKeJu  : setTitleFontSize( self.FONTSIZE+2 )
	Btn_JoinKeJu  : setPosition( -self.m_viewSize.width/2+103, -self.m_viewSize.height/2+25  )
	Btn_JoinKeJu  : setTag( Tag_Btn_JoinKeJu )
	Btn_JoinKeJu  : addTouchEventListener( ButtonCallBack )		
	self.mainContainer : addChild( Btn_JoinKeJu,2 )

	local Lab_5 = _G.Util : createLabel( "剩余次数: ", self.FONTSIZE )
	Lab_5 : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_5 : setPosition( cc.p( 75, 25 ) )
	-- Lab_5 : setColor( color6 )
	lefBase2 : addChild( Lab_5 )

	local Lab_GetTimes = _G.Util : createLabel( "0", self.FONTSIZE )
	Lab_GetTimes : setAnchorPoint( cc.p( 0, 0.5 ) )
	Lab_GetTimes : setPosition( Lab_5 : getContentSize().width + 75, 25 )
	Lab_GetTimes : setTag( Tag_Lab_GetTimes )
	Lab_GetTimes : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	lefBase2 : addChild( Lab_GetTimes )
end

-- _G.Lang.number_Chinese(1)  -- 数字对应中文

function KejuView.Create_Left_Text( self, msg )
	local Spr_LeftView = self.mainContainer : getChildByTag( Tag_Spr_LeftView )
	local Wid_leftView = Spr_LeftView : getContentSize().width
	local Hei_leftView = Spr_LeftView : getContentSize().height

	local Id    = msg.msg_xxx2.id
	local num   = msg.msg_xxx2.num
	local right = msg.msg_xxx2.right
	local time  = msg.msg_xxx2.time
	print( "ID = ", msg.msg_xxx2.id )

	if (Id == 0) and (num == 0) and (right == 0) then
		self : Create_RighView(1)
	else
		print( "111" )
		self : Create_RighView(2)
		self : Chuange_RighView( msg.msg_xxx2 )
	end

	local my_times2  	= msg.times2  -- 剩余答题次数
	local my_ranking2 	= msg.rank2   -- 排名
	local my_score2 	= msg.score2  -- 得分
	local my_time2 	 	= self : _getTimeStr(msg.time2)   -- 耗时 
	local my_reward2 	= msg.reward2 -- 所获奖励
	if (my_time2 == 0) and (my_score2 == 0) and (my_ranking2 == 0) then 
		my_score2 	= "待定"
		my_ranking2 = "0"
		my_time2 	= "00:00"
		my_reward2  = "0"
	end
	print( "mmmmmmmmm>>>>>", my_reward2 )
	if my_times2 <= 0 then
		Spr_LeftView : getChildByTag( Tag_Lab_GetTimes ) : setColor( color6 )
	end
	Spr_LeftView : getChildByTag( Tag_Lab_GetTimes ) : setString( my_times2   ) 
	Spr_LeftView : getChildByTag( Tag_Lab_Score    ) : setString( my_score2   )
	Spr_LeftView : getChildByTag( Tag_Lab_Ranking  ) : setString( my_ranking2 )
	Spr_LeftView : getChildByTag( Tag_Lab_Time 	   ) : setString( my_time2    )
	-- Spr_LeftView : getChildByTag( Tag_Spr_Goods    ) : setVisible( true )
	self.Lab_Goods : setString(string.format("%d铜钱",my_reward2))

	if my_times2 <= 0 then
		local Btn_JoinKeJu = self.mainContainer : getChildByTag( Tag_Btn_JoinKeJu )
		Btn_JoinKeJu : setTouchEnabled( false )
		Btn_JoinKeJu : setGray()
	end 
end

function KejuView.Chuange_RighView( self, msg )
	local Id    = msg.id
	local num   = msg.num
	local right = msg.right
	local time  = self : _getTimeStr( msg.time )
	print( "传进来的ID：", Id )
	local Spr_AnswerView  = self.mainContainer : getChildByTag( Tag_Spr_RightView2 )
	local Lab_Title_Right = Spr_AnswerView : getChildByTag( Tag_Lab_Title_Right )
	Lab_Title_Right : setString( right )
	local Lab_leaveTime   = Spr_AnswerView : getChildByTag( Tag_Lab_leaveTime )
	Lab_leaveTime : setString( time ) 
	local Lab_Title = Spr_AnswerView : getChildByTag( Tag_Lab_Title )
	local Text_title = "第" .. _G.Lang.number_Chinese[num] .. "题"
	Lab_Title : setString( Text_title )

	if _G.Cfg.keju_cnf[Id] ~= nil then
		local Title = _G.Cfg.keju_cnf[Id]
		print( "问题来啦：", Title.describe )
		print( "选项1：	 ", Title.answer1 )
		print( "选项2：	 ", Title.answer2 )
		print( "选项3：	 ", Title.answer3 )
		print( "选项4：	 ", Title.answer4 )

		local Lab_MyTest = Spr_AnswerView : getChildByTag( Tag_Lab_MyTest )
		Lab_MyTest : setString( num.."、"..Title.describe)
		local Text_Answer = { Title.answer1, Title.answer2, Title.answer3, Title.answer4 }
		for i=1,4 do
			local Lab_Answer = Spr_AnswerView : getChildByTag( Tag_Lab_Answer[i] )
			Lab_Answer : setString( Text_Answer[i] )
		end
	end

	local Lab_leaveTime = Spr_AnswerView : getChildByTag( Tag_Lab_leaveTime )
	self.myTime = msg.time
	local function step2(  )
		self.myTime = self.myTime - 1
		if self.myTime <= 0 then 
			_G.Scheduler : unschedule( self.Scheduler_2 )
 			self.Scheduler_2 = nil
 			self : REQ_KEJU_ASK_KEJU()
		end
		Lab_leaveTime : setString( self : _getTimeStr( self.myTime ) )
	end 
	if self.Scheduler_2 == nil then 
		self.Scheduler_2 = _G.Scheduler : schedule(step2, 1)
	end


end

function KejuView.Create_RighView( self, num )
	local Spr_Right = {}
	Spr_Right[1] = self.mainContainer : getChildByTag( Tag_Spr_RightView )
	Spr_Right[2] = self.mainContainer : getChildByTag( Tag_Spr_RightView2 )
	if Spr_Right[3-num] ~= nil then 
		Spr_Right[3- num] : setVisible( false )
	end

	if (Spr_Right[1] == nil) and (num == 1) then 
	 	self : Create_RighView_1()
	elseif (Spr_Right[1] ~= nil) and (num == 1) then
		Spr_Right[1] : setVisible( true )
	elseif (Spr_Right[2] ~= nil) and (num == 2) then
		Spr_Right[2] : setVisible( true )
	elseif (Spr_Right[2] == nil) and (num == 2) then
		self : Create_RighView_2()
	end
end

function KejuView.Create_RighView_1( self )

	if self.Spr_Base ~= nil then
		self.Spr_Base : setVisible( false )
	end

	local sprSize=cc.size( 565, 518 )
	local Spr_RightView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" ) 
	Spr_RightView : setContentSize( sprSize )
	Spr_RightView : setPosition( 140 , -22  )
	Spr_RightView : setTag( Tag_Spr_RightView )
	self.mainContainer : addChild( Spr_RightView, 1 )

	-- local spr_base2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" )
	-- spr_base2 : setPreferredSize( cc.size( 583-12, 450-12 ) )
	-- spr_base2 : setAnchorPoint( 0, 0 )
	-- spr_base2 : setPosition( 6, 6 )
	-- Spr_RightView : addChild( spr_base2 )


	local Wid_righView = sprSize.width
	local Hei_righView = sprSize.height
	local gap = 85

	local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_daybg.png" )
	line1 : setPreferredSize( cc.size( Wid_righView-1, 65 ) )
	line1 : setPosition( Wid_righView/2, Hei_righView - 33 )
	Spr_RightView : addChild( line1 )

	local Spr_Title = cc.Sprite : createWithSpriteFrameName( "Keju_Title.png" )
	Spr_Title : setPosition( Wid_righView/2, Hei_righView - 33 )
	Spr_RightView : addChild( Spr_Title )

	

	local Spr_MyBlueBase = ccui.Widget : create()
	Spr_MyBlueBase : setContentSize( cc.size( Wid_righView-8, 40) )
	Spr_MyBlueBase : setPosition( Wid_righView/2+15, Hei_righView - 75 )
	Spr_RightView  : addChild( Spr_MyBlueBase )

	-- local ChooseX = _G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE)
	local Lab_1 = _G.Util:createLabel("排名",20)
	Lab_1 : setPosition( cc.p( 45, 15 ) )
	Spr_MyBlueBase : addChild( Lab_1 )

	local Lab_2 = _G.Util:createLabel("玩家名字",20)
	Lab_2 : setPosition( cc.p( 165, 15 ) )
	Spr_MyBlueBase : addChild( Lab_2 )

	local Lab_3 = _G.Util:createLabel("成绩",20)
	Lab_3 : setPosition( cc.p( 310, 15 ) )
	Spr_MyBlueBase : addChild( Lab_3 )

	local Lab_4 = _G.Util:createLabel("奖励",20)
	Lab_4 : setPosition( cc.p( 470, 15 ) )
	Spr_MyBlueBase : addChild( Lab_4 )

	local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	line2 : setPreferredSize( cc.size( Wid_righView-10, 2 ) )
	line2 : setPosition( Wid_righView/2, Hei_righView - 100 )
	Spr_RightView : addChild( line2 )
end

function KejuView.Create_RighView_2( self )

	local Size_Spr_Base = cc.size( 565, 518  )
	if not self.Spr_Base then
		self.Spr_Base = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" ) 
		self.Spr_Base : setContentSize( Size_Spr_Base )
		self.Spr_Base : setPosition( 140 , -22)
		self.Spr_Base : setTag( Tag_Spr_RightView2 )
		self.mainContainer : addChild( self.Spr_Base, -2 )
	else
		self.Spr_Base : setVisible( true )
	end

	local Wid_righView = Size_Spr_Base.width
	local Hei_righView = Size_Spr_Base.height

	local Lab_Title  = _G.Util : createLabel( "", self.FONTSIZE + 10 )
	Lab_Title : setAnchorPoint( 0, 0.5 )
	Lab_Title : setPosition( 40, Hei_righView - 50 )
	Lab_Title : setTag( Tag_Lab_Title )
	Lab_Title : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_SPRINGGREEN ) )
	self.Spr_Base : addChild( Lab_Title )

	local Lab_1 = _G.Util : createLabel( "答对题目: ", self.FONTSIZE )
	Lab_1 : setPosition( Wid_righView*0.65, Hei_righView - 33 )
	Lab_1 : setAnchorPoint( 0, 0.5 )
	-- Lab_1 : setColor( color1 )
	self.Spr_Base : addChild( Lab_1 )

	local Lab_Title_Right = _G.Util : createLabel( "", self.FONTSIZE )
	Lab_Title_Right : setAnchorPoint( 0, 0.5 )
	Lab_Title_Right : setPosition( Wid_righView*0.65 + 100, Hei_righView - 33 )
	Lab_Title_Right : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ) )
	Lab_Title_Right : setTag( Tag_Lab_Title_Right )
	self.Spr_Base  : addChild( Lab_Title_Right )

	local Lab_2 = _G.Util : createLabel( "剩余时间: ", self.FONTSIZE )
	Lab_2 : setPosition( Wid_righView*0.65, Hei_righView - 65 )
	Lab_2 : setAnchorPoint( 0, 0.5 )
	-- Lab_2 : setColor( color1 )
	self.Spr_Base : addChild( Lab_2 )

	local Lab_leaveTime = _G.Util : createLabel( "", self.FONTSIZE )
	Lab_leaveTime : setAnchorPoint( 0, 0.5 )
	Lab_leaveTime : setPosition( Wid_righView*0.65 + 100, Hei_righView - 65 )
	Lab_leaveTime : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
	Lab_leaveTime : setTag( Tag_Lab_leaveTime )
	self.Spr_Base : addChild( Lab_leaveTime )

	local Spr_JianBian = ccui.Scale9Sprite : createWithSpriteFrameName( "general_zhongbg.png" )
	Spr_JianBian : setPreferredSize( cc.size(560, 308) )
	Spr_JianBian : setAnchorPoint( 0, 1 )
	Spr_JianBian : setPosition( 2,  Hei_righView/2+170 )
	self.Spr_Base : addChild( Spr_JianBian )

	local Lab_MyTest = _G.Util : createLabel( "", self.FONTSIZE+4 )
	Lab_MyTest : setAnchorPoint( 0, 0.5 )
	Lab_MyTest : setPosition( 40, Hei_righView-160 )
	-- Lab_MyTest : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE ) )
	Lab_MyTest : setTag( Tag_Lab_MyTest )
	Lab_MyTest : setLineBreakWithoutSpace(true)
	Lab_MyTest : setDimensions( Wid_righView-80, 80)
	Lab_MyTest : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.Spr_Base : addChild( Lab_MyTest,1 )

	local function ButtonCallBack( obj, eventType )
		self : touchEventCallBack( obj, eventType )
	end

	
	self.Size_BtnAn = {  { width = Wid_righView/4+10  , height = Hei_righView/2+10 },
						 { width = Wid_righView/4*3-10, height = Hei_righView/2+10 },
						 { width = Wid_righView/4+10  , height = Hei_righView/2-80 },
						 { width = Wid_righView/4*3-10, height = Hei_righView/2-80 }}
	local choosText = { "A.png", "B.png", "C.png", "D.png" }
	self.Spr_Choose = {}
	for i=1,4 do
		local Btn_Answer = gc.CButton : create("Keju_base.png","Keju_choose.png","Keju_choose.png")
		Btn_Answer : setPosition( self.Size_BtnAn[i].width, self.Size_BtnAn[i].height )
		Btn_Answer : setTag( Tag_Btn_Answer[i] )
		Btn_Answer : addTouchEventListener( ButtonCallBack )
		self.Spr_Base : addChild( Btn_Answer,1 )

		local spr = cc.Sprite : createWithSpriteFrameName( choosText[i] )
		spr : setPosition( self.Size_BtnAn[i].width-90, self.Size_BtnAn[i].height )
		self.Spr_Base : addChild( spr, 2 )

		local Lab_Answer = _G.Util : createLabel( "", self.FONTSIZE+4 )
		Lab_Answer : setPosition( self.Size_BtnAn[i].width+10, self.Size_BtnAn[i].height )
		Lab_Answer : setTag( Tag_Lab_Answer[i] )
		self.Spr_Base : addChild( Lab_Answer,1)

		if self.Btn_Answer_state[i] == true then 
			Btn_Answer : setTouchEnabled( false )
			Lab_Answer : setVisible( false )
		end
	end

	local Spr_Right = ccui.Scale9Sprite : createWithSpriteFrameName( "Keju_right.png" )
	Spr_Right : setPosition( self.Size_BtnAn[1].width + 80, self.Size_BtnAn[1].height )
	Spr_Right : setTag( Tag_Spr_Right )
	Spr_Right : setVisible( false )
	self.Spr_Base : addChild( Spr_Right,1 )
	local Spr_Wrong = ccui.Scale9Sprite : createWithSpriteFrameName( "Keju_wrong.png" )
	Spr_Wrong : setPosition( self.Size_BtnAn[1].width + 80, self.Size_BtnAn[1].height )
	Spr_Wrong : setTag( Tag_Spr_Wrong )
	Spr_Wrong : setVisible( false )
	self.Spr_Base : addChild( Spr_Wrong,1 )

	local Btn_GoWrong = ccui.Button : create()
	Btn_GoWrong : loadTextures( "Keju_GoWrong.png", "", "", ccui.TextureResType.plistType )
	Btn_GoWrong : setPosition( self.Size_BtnAn[1].width, 54 )
	Btn_GoWrong : setTag( Tag_Btn_GoWrong )
	Btn_GoWrong : addTouchEventListener( ButtonCallBack )
	self.Spr_Base : addChild( Btn_GoWrong,1 )

	local Btn_GivMoney = ccui.Button : create()
	Btn_GivMoney : loadTextures( "Keju_GivMoney.png", "", "", ccui.TextureResType.plistType )
	Btn_GivMoney : setPosition( self.Size_BtnAn[2].width, 60 )
	Btn_GivMoney : setTag( Tag_Btn_GivMoney )
	Btn_GivMoney : addTouchEventListener( ButtonCallBack )
	self.Spr_Base : addChild( Btn_GivMoney,1 )

	print( "222" )
end

function KejuView.createRanking( self, count, msg )
	print( "---开始创建排行榜内容---", self.ScrollView )
	print("初始化滚动框")
	local Mycount = count
	if count <= 5 then
		Mycount = 5
	end
	
	local Wid_righView  = 565
	local Hei_righView  = 413
	local My_Gap = Hei_righView/5
    local viewSize      = cc.size( Wid_righView, Hei_righView)
    local containerSize = cc.size( Wid_righView, My_Gap*Mycount)
	local Spr_RightView = self.mainContainer : getChildByTag( Tag_Spr_RightView )
	if self.ScrollView ~= nil then 
    	self.ScrollView : removeFromParent()
    end
    
    self.ScrollView = cc.ScrollView : create()
    self.ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    self.ScrollView : setViewSize(viewSize)
    self.ScrollView : setContentSize(containerSize)
    self.ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    self.ScrollView : setPosition(cc.p(0, 4))
    self.ScrollView : setBounceable(true)
    self.ScrollView : setTouchEnabled(true)
    self.ScrollView : setDelegate()
    Spr_RightView 	: addChild( self.ScrollView )
    
    local barView = require("mod.general.ScrollBar")(self.ScrollView)
    barView 	  : setPosOff(cc.p(-7,0))
    -- barView 	  : setMoveHeightOff(-5)

    local kuangSize=cc.size( Wid_righView-17, My_Gap-5 )
	local My_TextPos = { {175+10,Mycount*My_Gap - My_Gap/2},
					     {310,Mycount*My_Gap - My_Gap/2+15}, 
					     {310,Mycount*My_Gap - My_Gap/2-15},
					     {kuangSize.width-190,Mycount*My_Gap - My_Gap/2+15},
					     {kuangSize.width-190,Mycount*My_Gap - My_Gap/2-15},
					     {kuangSize.width-50,Mycount*My_Gap - My_Gap/2}}
	local color8    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LABELBLUE )
	local NewColor  = { color6, color5, color8 }
	for i=1,count do
		local My_Text    = { msg[i].name, "答题得分: ", "所花时间: ", msg[i].score, self:_getTimeStr(msg[i].times), msg[i].reward_rank }
		local My_height = Mycount*My_Gap - My_Gap/2  - (i-1)*My_Gap
		local Spr_Base = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
		Spr_Base : setPreferredSize(cc.size(kuangSize.width,2))
		-- Spr_Base : setAnchorPoint( 0, 0.5 )
		Spr_Base : setPosition( viewSize.width/2, My_height-My_Gap/2 )
		self.ScrollView : addChild( Spr_Base, -1 )

		if i <= 3 then 
			local Spr_MySpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_number"..i..".png" )
			-- Spr_MySpr : setAnchorPoint( 0, 0.5 )
			Spr_MySpr : setPosition( 65, My_height  )
			self.ScrollView : addChild( Spr_MySpr )
		else
			local Lab_1 = _G.Util:createLabel( string.format("第%s名",_G.Lang.number_Chinese[i]),self.FONTSIZE)
			-- Lab_1 : setColor( color5 )
			Lab_1 : setPosition( 65, My_height  )
			self.ScrollView : addChild( Lab_1 )
		end
		for k=1,6 do
			local myText = _G.Util : createLabel( My_Text[k], self.FONTSIZE )
			myText : setPosition( My_TextPos[k][1], My_TextPos[k][2] - (i-1)*My_Gap )
			self.ScrollView : addChild( myText )
			if k==4 or k==5 then
				myText : setAnchorPoint(0,0.5)
				myText : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)  )
			end
		end
		local Spr_1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tongqian.png" )
		Spr_1 : setPosition( kuangSize.width-100, My_height )
		self.ScrollView : addChild( Spr_1 )
	end

end

function KejuView._getTimeStr( self,_time)
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
    time = tostring(min)..":"..second

    return time
end

function KejuView.Check_Answer( self, msg )

 	local choose = msg.choose
 	local right  = msg.right
 	local nextId = msg.nextId
 	local Spr_AnswerView = self.mainContainer : getChildByTag( Tag_Spr_RightView2 )

 	for i=1,4 do
		if self.Btn_Answer_state[i] == true then 
			local Btn_Answer = Spr_AnswerView : getChildByTag( Tag_Btn_Answer[i] )
			Btn_Answer : setTouchEnabled( true )
			self.Btn_Answer_state[i] = false

			local Lab_Answer = Spr_AnswerView : getChildByTag( Tag_Lab_Answer[i] )
			Lab_Answer : setVisible( true )
		end 
	end

 	local Spr_Right = Spr_AnswerView : getChildByTag( Tag_Spr_Right )
 	local Spr_Wrong = Spr_AnswerView : getChildByTag( Tag_Spr_Wrong )
 	Spr_Right : setPosition( self.Size_BtnAn[right].width + 80, self.Size_BtnAn[right].height )
 	Spr_Wrong : setPosition( self.Size_BtnAn[choose].width + 80, self.Size_BtnAn[choose].height )
 	Spr_Right : setVisible( true )
 	local Btn_Answer = Spr_AnswerView : getChildByTag( Tag_Btn_Answer[right]):setBright(false)

 	local Btn_GoWrong  = Spr_AnswerView : getChildByTag( Tag_Btn_GoWrong )
 	local Btn_GivMoney = Spr_AnswerView : getChildByTag( Tag_Btn_GivMoney )
 	Btn_GivMoney : setTouchEnabled( false )
 	Btn_GoWrong : setTouchEnabled( false )

 	if choose ~= right then 
 		Spr_Wrong : setVisible( true )
 		local Btn_Answer = Spr_AnswerView : getChildByTag( Tag_Btn_Answer[choose]):setBright(false) 
 	else
 		self.rightNum = self.rightNum + 1
 		local Lab_Title_Right = Spr_AnswerView : getChildByTag( Tag_Lab_Title_Right )
 		Lab_Title_Right : setString( self.rightNum )
 	end
 	for i=1,4 do
 		local Btn_Answer = Spr_AnswerView : getChildByTag( Tag_Btn_Answer[i] )
 		Btn_Answer : setTouchEnabled( false )
 	end

 	local function step1( )
 		if self.count == true then 
 			self.count = false
 			for i=1,4 do
		 		local Btn_Answer = Spr_AnswerView : getChildByTag( Tag_Btn_Answer[i] )
		 		Btn_Answer : setTouchEnabled( true )
		 		Btn_Answer : setBright(true)
 			end
 			Btn_GivMoney : setTouchEnabled( true )
 			Btn_GoWrong  : setTouchEnabled( true )
 			Spr_Right : setVisible( false )
 			Spr_Wrong : setVisible( false )
 			-- self : REQ_KEJU_ASK_KEJU()
			self : NextText( msg )
 			_G.Scheduler : unschedule( self.Scheduler )
 			self.Scheduler = nil
 		else 
 			self.count = true
 		end   
	end
	if self.Scheduler == nil then 
		self.count 	   = false
		self.Scheduler = _G.Scheduler : schedule(step1, 0.7)
	end
end 

function KejuView.NextText( self, msg )
	self.currentNum = self.currentNum + 1
	print( "当前第几题：", self.currentNum )
	local Id    = msg.next
	if _G.Cfg.keju_cnf[Id] ~= nil then
		local Title = _G.Cfg.keju_cnf[Id]
		print( "问题来啦：", Title.describe )
		print( "选项1：	 ", Title.answer1 )
		print( "选项2：	 ", Title.answer2 )
		print( "选项3：	 ", Title.answer3 )
		print( "选项4：	 ", Title.answer4 )
		
		local Spr_AnswerView = self.mainContainer : getChildByTag( Tag_Spr_RightView2 )

		local Lab_Title = Spr_AnswerView : getChildByTag( Tag_Lab_Title )
		local Text_title = "第" .. _G.Lang.number_Chinese[self.currentNum] .. "题"
		Lab_Title : setString( Text_title )
		local Lab_MyTest = Spr_AnswerView : getChildByTag( Tag_Lab_MyTest )
		Lab_MyTest : setString( self.currentNum.."、"..Title.describe)
		local Text_Answer = { Title.answer1, Title.answer2, Title.answer3, Title.answer4 }
		for i=1,4 do
			local Lab_Answer = Spr_AnswerView : getChildByTag( Tag_Lab_Answer[i] )
			Lab_Answer : setString( Text_Answer[i] )
		end
	end

	if self.currentNum >= 30 then 
		self : REQ_KEJU_ASK_KEJU()
	end
end

function KejuView.Send_Answer( self, tag )
	print( "发送的答案是：", tag - Tag_Btn_Answer[1] + 1 )
	local Spr_AnswerView = self.mainContainer : getChildByTag( Tag_Spr_RightView2 )
	for i=1,4 do
		local Btn_Answer = Spr_AnswerView : getChildByTag( Tag_Btn_Answer[i] )
		Btn_Answer : setTouchEnabled(false)
	end
  	self : REQ_KEJU_ANSWER( tag - Tag_Btn_Answer[1] + 1  )
end

function KejuView.MessageBox( self, My_type )
	local function tipsSure()
		if My_type == 1 then 
			self : REQ_KEJU_OUT_WRONG()
		else
			self : REQ_KEJU_BRIBE()
		end
    end
    local function cancel()
    	
    end
    if self.LeTimes[ My_type ] <= 0 then
	    if My_type == 1 then 
			self : REQ_KEJU_OUT_WRONG()
		else
			self : REQ_KEJU_BRIBE()
		end
		return
	end

    if NoTouchSet[My_type]==false then   
		local tipsBox = require("mod.general.TipsBox")()
	    local layer   = tipsBox :create( "", tipsSure, cancel)
	    -- layer : setPosition(cc.p(0,0))
	    cc.Director:getInstance():getRunningScene():addChild(layer,1000)
	    local layer=tipsBox:getMainlayer()
	    local Text = {}
	    if My_type == 1 then 
	   		tipsBox : setTitleLabel("算卦去错")
	   		Text = "花费".._G.Const.CONST_KEJU_PUGUA.."元宝去除一个错误选项？"
	   	else
	   		tipsBox : setTitleLabel("贿赂考官")
	   		Text = "花费".._G.Const.CONST_KEJU_HUILU.."元宝得到正确答案？"
	   	end

	    local Lab_1 = _G.Util : createLabel( Text, self.FONTSIZE  )
	    Lab_1 : setPosition( 0, 60 )
	    layer : addChild( Lab_1 )

	    local Lab_3 = _G.Util : createLabel( "（元宝不足则消耗钻石）", self.FONTSIZE-2 )
	    Lab_3 : setPosition( 0, 30 )
	    layer : addChild( Lab_3 )

	    local Lab_2 = _G.Util : createLabel( "剩余购买次数：", self.FONTSIZE  )
	    Lab_2 : setPosition( -4, -5 )
	    layer : addChild( Lab_2 )

	    local Lab_LeTimes = _G.Util : createLabel( self.LeTimes[ My_type ], self.FONTSIZE )
	    Lab_LeTimes : setPosition( 5+Lab_2:getContentSize().width/2, -5 )
	    Lab_LeTimes : setColor( color2 )
	    layer : addChild( Lab_LeTimes )

		if self.LeTimes[ My_type ] <= 0 then
			Lab_LeTimes : setColor( color6 )
		end

		function checkBoxCallback( obj, touchEvent )
			self : touchEventCallBack( obj, touchEvent )
		end

		local uncheckBox 	= "general_gold_floor.png"
		local selectBox  	= "general_check_selected.png"
		local checkBox = ccui.CheckBox : create( uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType )
		checkBox : addEventListener( checkBoxCallback )
		checkBox : setPosition( cc.p( -80, -52 ) )
		checkBox : setTag( Tag_NoTouch[My_type] )
		layer 	 : addChild(checkBox) 

		local CheckLabel = _G.Util : createLabel( _G.Lang.LAB_N[106], self.FONTSIZE )
		CheckLabel : setPosition( 25, -50 )
		-- CheckLabel : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKPURPLE ) )
		layer	   : addChild( CheckLabel )
	else
		if My_type == 1 then 
			self : REQ_KEJU_OUT_WRONG()
		else
			self : REQ_KEJU_BRIBE()
		end
	end

end

function KejuView.Chuange_LeftText( self, msg )
	local Spr_LeftView = self.mainContainer : getChildByTag( Tag_Spr_LeftView )
	local Wid_leftView = Spr_LeftView : getContentSize().width
	local Hei_leftView = Spr_LeftView : getContentSize().height

	self : Create_RighView(1)

	local my_times  	= msg.times  -- 剩余答题次数
	local my_ranking 	= msg.rank   -- 排名
	if msg.rank == 0 or msg.rank == nil then
		my_ranking = "(暂无)"
	end
	local my_score 		= msg.score  -- 得分
	local my_time 	 	= self : _getTimeStr(msg.time)   -- 耗时 
	local my_reward 	= msg.reward -- 所获奖励
	if (my_time2 == 0) and (my_score2 == 0) and (my_ranking2 == 0) then 
		my_score2 	= "待定"
		my_ranking2 = "0"
		my_time2 	= "00:00"
		my_reward2  = "0"
	end
	print( "tttttt---->", my_reward )
	if my_times <= 0 then
		Spr_LeftView : getChildByTag( Tag_Lab_GetTimes ) : setColor( color6 )
	end
	Spr_LeftView : getChildByTag( Tag_Lab_GetTimes ) : setString( my_times   ) 
	Spr_LeftView : getChildByTag( Tag_Lab_Score    ) : setString( my_score   )
	Spr_LeftView : getChildByTag( Tag_Lab_Ranking  ) : setString( my_ranking )
	Spr_LeftView : getChildByTag( Tag_Lab_Time 	   ) : setString( my_time    )
	-- Spr_LeftView : getChildByTag( Tag_Spr_Goods    ) : setVisible( true )
	self.Lab_Goods : setString(string.format("%d铜钱",my_reward))

	if my_times <= 0 then 
		local Btn_JoinKeJu = self.mainContainer : getChildByTag( Tag_Btn_JoinKeJu )
		Btn_JoinKeJu : setTouchEnabled( false )
		Btn_JoinKeJu : setGray()
	end
end

function KejuView.touchEventCallBack( self, obj, touchEvent )
	local tag = obj : getTag()
	if touchEvent == ccui.TouchEventType.began then
		print("   按下  ", tag)
		if (tag == Tag_NoTouch[1]) or (tag == Tag_NoTouch[2]) then 
			NoTouchSet[ tag-Tag_NoTouch[1]+1 ] = true
		end
	elseif touchEvent == ccui.TouchEventType.moved then
		print("   移动  ", tag)
		if (tag == Tag_NoTouch[1]) or (tag == Tag_NoTouch[2]) then 
			NoTouchSet[ tag-Tag_NoTouch[1]+1 ] = false
		end
	elseif touchEvent == ccui.TouchEventType.ended then
  		print("   抬起  ", tag)
  		if tag == Tag_Btn_JoinKeJu then
  			self : REQ_KEJU_START()
  		elseif (Tag_Btn_Answer[1] <= tag) and (tag <= Tag_Btn_Answer[4]) then
  			self : Send_Answer( tag )
  		elseif tag == Tag_Btn_GoWrong then 
  			self : MessageBox(1)
  		elseif tag == Tag_Btn_GivMoney then 
  			self : MessageBox(2)
  		end
  	elseif touchEvent == ccui.TouchEventType.canceled then
  		print(" 点击取消 ", tag)
  	end
end

return KejuView