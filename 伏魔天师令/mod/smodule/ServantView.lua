local ServantView   = classGc(view,function ( self,_isBattle )
	self.m_winSize  = cc.Director : getInstance() : getVisibleSize()
	self.m_mainSize = cc.size(849,488)
	self.m_leftSize = cc.size(490,472)
	self.m_rightSize= cc.size(340,472)
	self.captureTips= false    -- 抓捕有主人的提示
	self.rebelTips  = false    -- 反抗提示
	self.bullyTips  = false    -- 压榨提示
	self.buyTips    = false    -- 抓捕购买提示

	self.captureTips= _G.GSystemProxy:getNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL)
	self.rebelTips  = _G.GSystemProxy:getNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+1)
	self.bullyTips  = _G.GSystemProxy:getNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+4)
	self.buyTips    = _G.GSystemProxy:getNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+5)
end)

local MASTER_TAG    = 1001
local EXP_TAG       = 1002
local TEACH_TAG     = 1003
local REBEL_TAG     = 1004
local CAPTURE_TAG   = 1005
local LEFT_BUTTON_1 = 1006
local LEFT_BUTTON_2 = 1007
local LEFT_BUTTON_3 = 1008
local REBEL_BUTTON  = 1009
local LEFT_VIEW_TAG = 2001
local RIGHT_VIEW_TAG= 2002
local BG_VIEW_TAG   = 2003

local RELEASE_BTN_1 = 3001
local RELEASE_BTN_2 = 3002
local RELEASE_BTN_3 = 3003

local EXTRACT_BTN_1 = 4001
local EXTRACT_BTN_2 = 4002
local EXTRACT_BTN_3 = 4003

local BULLY_BTN_1   = 5001
local BULLY_BTN_2   = 5002
local BULLY_BTN_3   = 5003

local INTERACT_BTN_1= 6001
local INTERACT_BTN_2= 6002
local INTERACT_BTN_3= 6003

local TIME_1        = 7001
local TIME_2        = 7002
local TIME_3        = 7003

local EXP_1         = 8001
local EXP_2         = 8002
local EXP_3         = 8003

local MSG_LAB_1     = 9001
local MSG_LAB_2     = 9002
local MSG_LAB_3     = 9003

local CAPTURE_UI_TAG= 10001
local LOSER_BTN     = 10002
local ENEMY_BTN     = 10003
local CAPTURE_BG    = 10004
local CAPTURE_BG_3  = 10005

local MOIL_MSG_UI   = 10006

function ServantView.create(self)
    self : __init()

    self.m_normalView = require("mod.general.NormalView")()
	self.m_rootLayer  = self.m_normalView:create()
	self.m_normalView : setTitle("奴 仆")
	self.m_normalView:showSecondBg()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)
	
	self  			  : __initView()

    return tempScene
end

function ServantView.__init(self)
    self : register()
end

function ServantView.register(self)
    self.pMediator = require("mod.smodule.ServantMediator")(self)
end
function ServantView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function ServantView.__initView(self)
    print("奴仆界面")

    local function nCloseFun()
		self : __closeWindow()
	end
	self.m_normalView : addCloseFun(nCloseFun)

	-- local second_bg   = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	-- second_bg 	  	  : setPosition(cc.p(self.m_winSize.width/2, self.m_winSize.height/2 - 20))
	-- second_bg	  	  : setPreferredSize(self.m_mainSize)
	-- second_bg         : setTag(BG_VIEW_TAG)
	-- self.m_rootLayer  : addChild(second_bg,0)

	local secondNode=cc.Node:create()
	secondNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
	secondNode:setTag(BG_VIEW_TAG)
	self.m_rootLayer  : addChild(secondNode)

	local leftBG	  = cc.Node:create()
	leftBG 	          : setPosition(-173,-275)
	leftBG            : setTag(LEFT_VIEW_TAG)
	secondNode  : addChild(leftBG)

	local dinsSize=cc.size(self.m_leftSize.width-7,self.m_leftSize.height/3-4)
	for i=1,3 do
		local dins   = ccui.Scale9Sprite : createWithSpriteFrameName( "general_rolekuang.png" ) 
	    dins         : setPreferredSize( dinsSize )
	    dins         : setPosition(cc.p(0,self.m_leftSize.height-self.m_leftSize.height/6 - (i-1)*(self.m_leftSize.height/3+1)))
	    leftBG       : addChild(dins)
	end

	local rightBG	 = ccui.Scale9Sprite : createWithSpriteFrameName("general_rolekuang.png")
	-- rightBG 		 : setAnchorPoint(cc.p(1,0))
	rightBG 	     : setPosition(cc.p(245,-40))
	rightBG		     : setPreferredSize(self.m_rightSize)
	rightBG          : setTag(RIGHT_VIEW_TAG)
	secondNode  : addChild(rightBG)

	local dins       = ccui.Scale9Sprite : createWithSpriteFrameName("servant_bg.png")
	dins             : setPreferredSize(cc.size(self.m_rightSize.width-16,287))
	dins             : setAnchorPoint(0,0)
	dins             : setPosition(cc.p(8,10))
	rightBG          : addChild(dins)

    local fontSize   = 20
    local labX       = 15
    local interval   = 30
    local heightFlag = self.m_rightSize.height*3/5 + 25

    -- 初始化right视图content
    local masterLab   = _G.Util : createLabel("我的主人:", fontSize)
	-- masterLab 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ PBLUE))
	masterLab 		  : setAnchorPoint(cc.p(0,0))
	masterLab 		  : setPosition(cc.p(labX,heightFlag)) 
	rightBG           : addChild(masterLab,0)

	local masterName  = _G.Util : createLabel("无", fontSize)
	masterName 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	masterName 		  : setAnchorPoint(cc.p(0,0))
	masterName 		  : setPosition(cc.p(labX+masterLab:getContentSize().width,heightFlag)) 
	masterName 		  : setTag(MASTER_TAG)
	rightBG           : addChild(masterName,0)

	heightFlag        = heightFlag + interval

	local expLab      = _G.Util : createLabel("可获铜钱:", fontSize)
	-- expLab 		      : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
	expLab 		      : setAnchorPoint(cc.p(0,0))
	expLab 		      : setPosition(cc.p(labX,heightFlag)) 
	rightBG           : addChild(expLab,0)

	local expData     = _G.Util : createLabel("10000/10000", fontSize)
	expData 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	expData 		  : setAnchorPoint(cc.p(0,0))
	expData 		  : setPosition(cc.p(labX+expLab:getContentSize().width,heightFlag)) 
	expData 		  : setTag(EXP_TAG)
	rightBG           : addChild(expData,0)

	heightFlag        = heightFlag + interval

	local teachLab    = _G.Util : createLabel("互动次数:", fontSize)
	-- teachLab 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
	teachLab 		  : setAnchorPoint(cc.p(0,0))
	teachLab 		  : setPosition(cc.p(labX,heightFlag)) 
	rightBG           : addChild(teachLab,0)

	local teachCount  = _G.Util : createLabel("10", fontSize)
	teachCount 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	teachCount 		  : setAnchorPoint(cc.p(0,0))
	teachCount 		  : setPosition(cc.p(labX+teachLab:getContentSize().width,heightFlag)) 
	teachCount 		  : setTag(TEACH_TAG)
	rightBG           : addChild(teachCount,0)

	heightFlag        = heightFlag + interval

	local rebelLab    = _G.Util : createLabel("反抗次数:", fontSize)
	-- rebelLab 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
	rebelLab 		  : setAnchorPoint(cc.p(0,0))
	rebelLab 		  : setPosition(cc.p(labX,heightFlag)) 
	rightBG           : addChild(rebelLab,0)

	local rebelCount  = _G.Util : createLabel("10", fontSize)
	rebelCount 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	rebelCount 		  : setAnchorPoint(cc.p(0,0))
	rebelCount 		  : setPosition(cc.p(labX+rebelLab:getContentSize().width,heightFlag)) 
	rebelCount        : setTag(REBEL_TAG)
	rightBG           : addChild(rebelCount,0)

	heightFlag        = heightFlag + interval

	local captureLab  = _G.Util : createLabel("抓捕次数:", fontSize)
	-- captureLab 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
	captureLab 		  : setAnchorPoint(cc.p(0,0))
	captureLab 		  : setPosition(cc.p(labX,heightFlag)) 
	rightBG           : addChild(captureLab,0)

	local captureCount= _G.Util : createLabel("10", fontSize)
	captureCount 	  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	captureCount 	  : setAnchorPoint(cc.p(0,0))
	captureCount 	  : setPosition(cc.p(labX+captureLab:getContentSize().width,heightFlag)) 
	captureCount      : setTag(CAPTURE_TAG)
	rightBG           : addChild(captureCount,0)

	heightFlag        = self.m_rightSize.height*3/5 + 10

	local function rebelEvent( sender,eventType )
		if eventType == ccui.TouchEventType.ended then
			print("反抗==============反抗")

			if self.rebelMsg then
				if self.rebelTips then
					_G.StageXMLManager : setScenePkType(_G.Const.CONST_MOIL_FUNCTION_REVOLT)

					_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_JJC_MOIL_ID)

			        local msg = REQ_MOIL_CAPTRUE()
			        msg 	  : setArgs(5,self.rebelMsg.l_uid)
			        _G.Network: send(msg)
			    else
			    	self : __initRebelTips(self.rebelMsg)
				end
				
			end

		end
	end

	local rebelBtn    = gc.CButton:create()
	rebelBtn 		  : loadTextures("servant_rebel.png")
	rebelBtn          : addTouchEventListener(rebelEvent)
	rebelBtn          : setAnchorPoint(cc.p(0,0))
	rebelBtn 		  : setPosition(cc.p(240,heightFlag+15))
	rebelBtn          : setTag(REBEL_BUTTON)
	rightBG 		  : addChild(rebelBtn)

	heightFlag        = heightFlag + 95

	local function captureEvent( sender,eventType )
		self : __captureEvent(sender,eventType)
	end

	local captureBtn  = gc.CButton:create()
	captureBtn 		  : loadTextures("servant_capture.png")
	captureBtn        : addTouchEventListener(captureEvent)
	captureBtn        : setAnchorPoint(cc.p(0,0))
	captureBtn 		  : setPosition(cc.p(240,heightFlag+15))
	rightBG 		  : addChild(captureBtn)

	heightFlag        = self.m_leftSize.height/6

	local captureBtn3 = gc.CButton:create()
	captureBtn3 	  : loadTextures("servant_capture.png")
	captureBtn3       : addTouchEventListener(captureEvent)
	captureBtn3 	  : setPosition(cc.p(0,heightFlag))
	captureBtn3       : setTag(LEFT_BUTTON_3)
	leftBG 		      : addChild(captureBtn3)

	heightFlag        = heightFlag + self.m_leftSize.height/3

	local captureBtn2 = gc.CButton:create()
	captureBtn2 	  : loadTextures("servant_capture.png")
	captureBtn2       : addTouchEventListener(captureEvent)
	captureBtn2 	  : setPosition(cc.p(0,heightFlag))
	captureBtn2       : setTag(LEFT_BUTTON_2)
	leftBG 		      : addChild(captureBtn2)

	heightFlag        = heightFlag + self.m_leftSize.height/3

	local captureBtn1 = gc.CButton:create()
	captureBtn1 	  : loadTextures("servant_capture.png")
	captureBtn1       : addTouchEventListener(captureEvent)
	captureBtn1 	  : setPosition(cc.p(0,heightFlag))
	captureBtn1       : setTag(LEFT_BUTTON_1)
	leftBG 		      : addChild(captureBtn1)

	local msg  		  = REQ_MOIL_ENJOY_MOIL()
    _G.Network  	  : send(msg)

    msg 	          = REQ_MOIL_PRESS_START()
    msg               : setArgs(4)
    _G.Network  	  : send(msg)
end

function ServantView.__initRebelTips( self,_msg )
	print("初始化__initRebelTips界面")

	local size = cc.Director : getInstance() : getWinSize()

	local function sure()
		_G.StageXMLManager : setScenePkType(_G.Const.CONST_MOIL_FUNCTION_REVOLT)

		_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_JJC_MOIL_ID)

        local msg = REQ_MOIL_CAPTRUE()
        msg 	  : setArgs(5,_msg.l_uid)
        _G.Network: send(msg)
    end

    local function cancel( ... )
    	print("取消")
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(size.width/2,size.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
    local width = -60
    local label2=_G.Util : createLabel(_msg.l_name,20)
    local length= label2:getContentSize().width
    if length>100 then
    	width = -70
    elseif length>80 then

    elseif length>60 then
    	width = -50
    elseif length>40 then
    	width = -40
    elseif length>20 then
    	width = -30
    else
    	width = -20
    end

	local label1=_G.Util : createLabel("确定反抗你的主人",20)
	label1 	    : setPosition(cc.p(width,50))
	layer 		: addChild(label1)
	
	label2      : setAnchorPoint(cc.p(0,0.5))
	label2      : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GREEN))
	label2 	    : setPosition(cc.p(width+label1 : getContentSize().width/2,50))
	layer 		: addChild(label2)

	local label21 =_G.Util : createLabel("吗?",20)
	label21     : setAnchorPoint(cc.p(0,0.5))
	label21 	: setPosition(cc.p(width+label1 : getContentSize().width/2+label2 : getContentSize().width,50))
	layer 		: addChild(label21)

	local label3=_G.Util : createLabel("(主人战力:"..tostring(_msg.l_power)..")",18)
	label3      : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GOLD))
	label3 	    : setPosition(cc.p(0,20))
	layer 		: addChild(label3)
	
	local label4 =_G.Util : createLabel(_G.Lang.LAB_N[106],20)
	label4 		: setPosition(cc.p(25,-40))
	layer 		: addChild(label4,88)

    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",self.captureTips)
            if self.rebelTips then
            	self.rebelTips = false
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+1,false)
            else
            	self.rebelTips = true
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+1,true)
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox 	     : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox 	     : setPosition(cc.p(-80,-39))
    checkbox 	     : setName("..........")
    checkbox 	     : addTouchEventListener(c)
    -- checkbox 	     : setAnchorPoint(cc.p(1,0.5))
    layer 			 : addChild(checkbox)
end

function ServantView.__captureEvent( self,sender,eventType )
	if eventType == ccui.TouchEventType.ended then
		if self.captureCount and self.captureCount < 1 then
			if self.buyTips then
				local msg = REQ_MOIL_BUY_CAPTRUE()
				_G.Network:send(msg)
				self : __initCaptureLayer()
			else
				self : __buyCaptureTips()
			end
		else
			self : __initCaptureLayer()
		end
	end
end

function ServantView.__buyCaptureTips( self )
	print("初始化__buyCaptureTips界面")

	local size = cc.Director : getInstance() : getWinSize()

	local function sure()
		local msg = REQ_MOIL_BUY_CAPTRUE()
		_G.Network:send(msg)
	    -- self : __initCaptureLayer()
    end

    local function cancel( ... )
    	print("取消")
    	self : __initCaptureLayer()
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(size.width/2,size.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
	local label1 =_G.Util : createLabel("花费10元宝进行1次抓捕次数吗？",20)
	label1 	     : setPosition(cc.p(0,50))
	layer 		 : addChild(label1)

	local label2 =_G.Util : createLabel("(元宝不足则消耗钻石)",20)
	label2 	     : setPosition(cc.p(0,25))
	layer 		 : addChild(label2)

	local label3 =_G.Util : createLabel("剩余购买次数:"..tostring(self.buyCount),20)
	--label3 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
	label3 	     : setPosition(cc.p(0,-5))
	layer 		 : addChild(label3)

    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local label3 =_G.Util : createLabel(_G.Lang.LAB_N[106],23)
	label3 		: setPosition(cc.p(25,-35))
	layer 		: addChild(label3,88)

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",self.buyTips)
            if self.buyTips then
            	self.buyTips = false
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+5,false)
            else
            	self.buyTips = true
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+5,true)
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox 	     : loadTextures("general_check_cancel.png","general_check_cancel.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox 	     : setPosition(cc.p(-80,-35))
    checkbox 	     : setName("..........")
    checkbox 	     : addTouchEventListener(c)
    -- checkbox 	     : setAnchorPoint(cc.p(1,0.5))
    layer 			 : addChild(checkbox)
end

function ServantView.__combatTime( self,times)
	local nowTime     = _G.TimeUtil:getNowSeconds()
    local offlineTime = nowTime - times

    local times_str   = os.date("*t", times)
    local nowTime_str = os.date("*t", nowTime)

    local temptime = ""
    if math.floor( offlineTime/(86400*30) ) > 0 then --一个月前
        temptime = "[1个月前]"
    elseif math.floor( offlineTime/86400 ) > 0 then  --超过一天
        temptime = "["..math.floor( offlineTime/86400 ).._G.Lang.LAB_N[92].."]"
    -- elseif math.floor( offlineTime/3600 ) > 0 then   --超过一个小时但一天内
    --     temptime = math.floor( offlineTime/3600 ).._G.Lang.LAB_N[91]
    -- elseif math.floor( offlineTime/60 ) > 0 then   --超过一分钟 但一个小时内
    --     temptime = math.floor( offlineTime/60 ).._G.Lang.LAB_N[90]
    else
        -- temptime = "1".._G.Lang.LAB_N[90]

        if times_str ~= nil and nowTime_str ~= nil then
           if tostring(times_str.day) ~= tostring(nowTime_str.day) then
               temptime  = "[昨天]"
           else
               local min = string.format("%.2d", times_str.min)
               temptime  = "["..times_str.hour ..":".. min.."]"
           end
        else
           temptime = "error"
        end
    end
    return temptime
end

function ServantView.updateMainView( self,_msg )
	print("==========协议接收成功============")
	if self.rebelMsg then
		self.rebelMsg = nil
	end

	self.rebelMsg = _msg
	
	self : __updateSelfMsg(_msg)

	local rightBG  = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(RIGHT_VIEW_TAG)
	local size     = rightBG : getContentSize()
	self.m_msgSize = cc.size(size.width,size.height*3/5/5)
	if _msg.count < 1 then
		return
	end
	self : __initCombatScrollView(_msg)
end

function ServantView.updateCaptureCount(self,_msg)

	local rightBG      = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(RIGHT_VIEW_TAG)
	local captureCount = rightBG : getChildByTag(CAPTURE_TAG)

	captureCount       : setString(tostring(_msg.sy_znum))
	self.buyCount      = _msg.sy_gnum
	self.captureCount  = _msg.sy_znum
end

function ServantView.updateLeftView( self,_msg )
	self : __initLeftView(_msg)
end

function ServantView.__updateSelfMsg( self,_msg )
	local rightBG      = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(RIGHT_VIEW_TAG)
	local captureCount = rightBG : getChildByTag(CAPTURE_TAG)
	local rebelCount   = rightBG : getChildByTag(REBEL_TAG)
	local teachCount   = rightBG : getChildByTag(TEACH_TAG)
	local expData      = rightBG : getChildByTag(EXP_TAG)
	local masterName   = rightBG : getChildByTag(MASTER_TAG)
	local rebelBtn     = rightBG : getChildByTag(REBEL_BUTTON)

	captureCount       : setString(tostring(_msg.captrue_count))
	rebelCount         : setString(tostring(_msg.protest_count))
	teachCount         : setString(tostring(_msg.active_count))
	expData            : setString(tostring(_msg.expn).."/"..tostring(_msg.exp))

	print("主人是：",_msg.l_name)
	if _msg.l_uid ~= 0 then
		masterName     : setString(_msg.l_name)
		rebelBtn       : setVisible(true)
	else
		masterName     : setString("无")
		rebelBtn       : setVisible(false)
	end
end

function ServantView.__initLeftView( self,_msg )
	table.sort(_msg.moil_data,function(a,b) return a.uid<b.uid end )
	for i=1,_msg.count do
		print("姓名：",_msg.moil_data[i].name)
	end

	local leftBG = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(LEFT_VIEW_TAG)
	self.m_schedulerMsg = _msg
	for i=1,3 do
		local layer = leftBG : getChildByTag(9000+i)
		local button= leftBG : getChildByTag(1005+i)
		if layer then
			button : setVisible(true)
			layer  : removeFromParent()
		end
	end

	for i=1,_msg.count do
		if     i == 1 then
			leftBG : getChildByTag(LEFT_BUTTON_1) : setVisible(false)
		elseif i == 2 then
			leftBG : getChildByTag(LEFT_BUTTON_2) : setVisible(false)
		elseif i == 3 then
			leftBG : getChildByTag(LEFT_BUTTON_3) : setVisible(false)
		end
		local msgLab = self : __initLabel(i,_msg.moil_data[i])
		leftBG       : addChild(msgLab)
	end

    if not self.m_timeScheduler then
    	local function local_scheduler()
        	self : __initSchedule()
    	end
    	self.expFlag = 29
    	self.m_timeScheduler = _G.Scheduler : schedule(local_scheduler, 1)
    end
end

function ServantView.__initSchedule( self)
	local leftBG = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(LEFT_VIEW_TAG)
	self.expFlag = self.expFlag - 1
	for i=1,self.m_schedulerMsg.count do

		local layer = leftBG : getChildByTag(9000+i)
		local time  = layer  : getChildByTag(7000+i)
		local exp   = layer  : getChildByTag(8000+i)

		time : setString(self : __getTimeStr(self.m_schedulerMsg.moil_data[i].time))

		if self.m_schedulerMsg.moil_data[i].time == 0 then
			local btn1 = layer : getChildByTag(5000+i)
			btn1 : setGray()
			btn1 : setEnabled(false)	
		end

		if self.expFlag == 0 then
			local addExp = _G.Cfg.moil_exp[self.m_schedulerMsg.moil_data[i].lv].moil_exp
			self.m_schedulerMsg.moil_data[i].expn = self.m_schedulerMsg.moil_data[i].expn + addExp
			if self.m_schedulerMsg.moil_data[i].time >=0 then
				exp  : setString(tostring(self.m_schedulerMsg.moil_data[i].expn))
			end
			
			self.expFlag = 29
		end
		self.m_schedulerMsg.moil_data[i].time = self.m_schedulerMsg.moil_data[i].time - 1
	end
end

function ServantView.__initLabel( self,i,_msg )
	local msgLab = ccui.Widget : create()
	msgLab       : setContentSize(cc.size(self.m_leftSize.width-7,self.m_leftSize.height/3-4))
	-- msgLab       : setAnchorPoint(cc.p(0,1))
	msgLab       : setPosition(cc.p(0,self.m_leftSize.height-self.m_leftSize.height/6-(self.m_leftSize.height/3+1)*(i-1)))
	msgLab       : setTag(9000+i)

	local personIcon = cc.Sprite : createWithSpriteFrameName(string.format("general_role_head%d.png",_msg.pro))
	personIcon       : setAnchorPoint(cc.p(0,0))
	personIcon       : setPosition(cc.p(15,45))
	msgLab           : addChild(personIcon)

	local fontSize   = 20

	local lv       = _G.Util : createLabel("LV.".._msg.lv,20)
	--lv 	   	       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
	-- lv             : enableOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
	lv 	   	       : setAnchorPoint( cc.p(0,0) )
	lv 	   	       : setPosition(cc.p(41,51))
	msgLab         : addChild(lv)

	local function releaseEvent( sender,eventType )
		self : __releaseEvent(sender,eventType,_msg)
	end

	local releaseBtn = gc.CButton : create()
	releaseBtn       : loadTextures("servant_release.png")
	releaseBtn       : addTouchEventListener(releaseEvent)
	releaseBtn       : setAnchorPoint(cc.p(0,0))
	releaseBtn       : setPosition(cc.p(380,70))
	releaseBtn       : setTag(3000+i)
	msgLab           : addChild(releaseBtn)

	

	local name       = _G.Util : createLabel(_msg.name, fontSize)
	name 		     : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	name 		     : setAnchorPoint(cc.p(0,0))
	name 		     : setPosition(cc.p(120,115)) 
	msgLab           : addChild(name)

	local time       = _G.Util : createLabel("干活时间:", fontSize)
	-- time 		     : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
	time 		     : setAnchorPoint(cc.p(0,0))
	time 		     : setPosition(cc.p(120,88)) 
	msgLab           : addChild(time)

	local timeData   = _G.Util : createLabel(self : __getTimeStr(_msg.time), fontSize)
	timeData 		 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	timeData 		 : setAnchorPoint(cc.p(0,0))
	timeData 		 : setPosition(cc.p(220,88))
	timeData         : setTag(7000+i) 
	msgLab           : addChild(timeData)

	local exp        = _G.Util : createLabel("干活铜钱:", fontSize)
	-- exp 		     : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
	exp 		     : setAnchorPoint(cc.p(0,0))
	exp 		     : setPosition(cc.p(120,62)) 
	msgLab           : addChild(exp)

	local expData    = _G.Util : createLabel(tostring(_msg.expn), fontSize)
	expData 		 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	expData 		 : setAnchorPoint(cc.p(0,0))
	expData 		 : setPosition(cc.p(220,62))
	expData          : setTag(8000+i) 
	msgLab           : addChild(expData)

	local btnHeight  = 8
	local btnFlag    = 82
	-- local scale      = 0.9

	local function extractEvent( sender,eventType )
		self : __extractEvent(sender,eventType,_msg)
	end

	local extractBtn = gc.CButton : create()
	extractBtn       : loadTextures("general_btn_gold.png")
	extractBtn       : addTouchEventListener(extractEvent)
	extractBtn       : setTitleText("提 取")
	extractBtn       : setTitleFontSize(24)
	extractBtn       : setTitleFontName(_G.FontName.Heiti)
	-- extractBtn       : setButtonScale(scale)
	extractBtn       : setAnchorPoint(cc.p(0,0))
	extractBtn       : setPosition(cc.p(btnFlag,btnHeight))
	extractBtn       : setTag(4000+i)
	msgLab           : addChild(extractBtn)

	if _msg.expn ==0 then
		extractBtn : setGray()
		extractBtn : setEnabled(false)
	end

	btnFlag          = btnFlag + 132

	local function bullyEvent( sender,eventType )
		self : __bullyEvent(sender,eventType,_msg)
	end

	local bullyBtn   = gc.CButton : create()
	bullyBtn         : loadTextures("general_btn_gold.png")
	bullyBtn         : addTouchEventListener(bullyEvent)
	bullyBtn         : setTitleText("压 榨")
	bullyBtn         : setTitleFontSize(24)
	bullyBtn         : setTitleFontName(_G.FontName.Heiti)
	-- bullyBtn         : setButtonScale(scale)
	bullyBtn         : setAnchorPoint(cc.p(0,0))
	bullyBtn         : setPosition(cc.p(btnFlag,btnHeight))
	bullyBtn         : setTag(5000+i)
	msgLab           : addChild(bullyBtn)

	if _msg.time <= 0 then
		bullyBtn : setGray()
		bullyBtn : setEnabled(false)
	end

	btnFlag          = btnFlag + 132

	local function interactEvent( sender,eventType )
		self : __interactEvent(sender,eventType,_msg)
	end

	local interactBtn= gc.CButton : create()
	interactBtn      : loadTextures("general_btn_gold.png")
	interactBtn      : addTouchEventListener(interactEvent)
	interactBtn      : setTitleText("互 动")
	interactBtn      : setTitleFontSize(24)
	interactBtn      : setTitleFontName(_G.FontName.Heiti)
	--interactBtn 	 : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	-- interactBtn      : setButtonScale(scale)
	interactBtn      : setAnchorPoint(cc.p(0,0))
	interactBtn      : setPosition(cc.p(btnFlag,btnHeight))
	interactBtn      : setTag(6000+i)
	msgLab           : addChild(interactBtn)

	return msgLab
end

function ServantView.__releaseEvent( self,sender,eventType,_msg )
	local leftBG = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(LEFT_VIEW_TAG)
	if eventType == ccui.TouchEventType.ended then
		if     sender == leftBG : getChildByTag(MSG_LAB_1) : getChildByTag(RELEASE_BTN_1) then
			self : __releaseTips(MSG_LAB_1,LEFT_BUTTON_1,_msg)
		elseif sender == leftBG : getChildByTag(MSG_LAB_2) : getChildByTag(RELEASE_BTN_2) then
			self : __releaseTips(MSG_LAB_2,LEFT_BUTTON_2,_msg)
		elseif sender == leftBG : getChildByTag(MSG_LAB_3) : getChildByTag(RELEASE_BTN_3) then
			self : __releaseTips(MSG_LAB_3,LEFT_BUTTON_3,_msg)
		end
	end
end

function ServantView.__releaseTips( self,tag1,tag2,_msg )
	print("初始化__releaseTips界面")

	local size = cc.Director : getInstance() : getWinSize()

	local function sure()
		local msg = REQ_MOIL_RELEASE()
        msg 	  : setArgs(_msg.uid,8)
        _G.Network: send(msg)

        local leftBG = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(LEFT_VIEW_TAG)
        leftBG : getChildByTag(tag1) : removeFromParent()
        leftBG : getChildByTag(tag2) : setVisible(true)
    end

    local function cancel( ... )
    	print("取消")
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(size.width/2,size.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
	local label1 =_G.Util : createLabel("释放后可获得该奴仆当前干活铜钱，",20)
	label1 	     : setPosition(cc.p(0,40))
	layer 		 : addChild(label1)

	local label2 =_G.Util : createLabel("确定要释放吗？",20)
	label2 	     : setPosition(cc.p(0,10))
	layer 		 : addChild(label2)

	local label3=_G.Util : createLabel("(如果超过铜钱上限，部分铜钱将丢失)",18)
	label3      : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORED))
	label3 	    : setPosition(cc.p(0,-18))
	layer 		: addChild(label3)

    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end
end

function ServantView.__extractEvent( self,sender,eventType,_msg )
	if eventType == ccui.TouchEventType.ended then
		local msg = REQ_MOIL_PRESS()
		msg       : setArgs(2,_msg.uid)
		_G.Network: send(msg)

		msg 	          = REQ_MOIL_PRESS_START()
	    msg               : setArgs(4)
	    _G.Network  	  : send(msg)
	end

end

function ServantView.__bullyEvent( self,sender,eventType,_msg )
	if eventType == ccui.TouchEventType.ended then
		if self.bullyTips then
			local msg = REQ_MOIL_PRESS()
			msg       : setArgs(1,_msg.uid)
			_G.Network: send(msg)

			msg 	          = REQ_MOIL_PRESS_START()
		    msg               : setArgs(4)
		    _G.Network  	  : send(msg)
		else
			self : __bullyTips(_msg)
		end
	end
end

function ServantView.__bullyTips( self,_msg )
	print("初始化__bullyTips界面")

	local size = cc.Director : getInstance() : getWinSize()

	local function sure()
		local msg = REQ_MOIL_PRESS()
		msg       : setArgs(1,_msg.uid)
		_G.Network: send(msg)

		msg 	          = REQ_MOIL_PRESS_START()
	    msg               : setArgs(4)
	    _G.Network  	  : send(msg)
    end

    local function cancel( ... )
    	print("取消")
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(size.width/2,size.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
	local label1 =_G.Util : createLabel("花费10元宝进行1小时的压榨吗？",20)
	label1 	     : setPosition(cc.p(0,50))
	layer 		 : addChild(label1)

	local label2 =_G.Util : createLabel("(元宝不足则消耗钻石)",18)
	label2 	     : setPosition(cc.p(0,20))
	layer 		 : addChild(label2)

    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local label3 =_G.Util : createLabel(_G.Lang.LAB_N[106],20)
	label3 		: setPosition(cc.p(25,-36))
	layer 		: addChild(label3,88)

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",self.bullyTips)
            if self.bullyTips then
            	self.bullyTips = false
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+4,false)
            else
            	self.bullyTips = true
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_MOIL+4,true)
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox 	     : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox 	     : setPosition(cc.p(-80,-37))
    checkbox 	     : setName("..........")
    checkbox 	     : addTouchEventListener(c)
    -- checkbox 	     : setAnchorPoint(cc.p(1,0.5))
    layer 			 : addChild(checkbox)
end

function ServantView.__interactEvent( self,sender,eventType,_msg )
	if eventType == ccui.TouchEventType.ended then
		local msg = REQ_MOIL_ACTIVE()
		math.randomseed(os.time())  
		msg       : setArgs(math.random(24),_msg.uid)
		_G.Network:send(msg)
    end
end

function ServantView.__initCombatScrollView( self,_msg )
	print("初始化滚动框","大小：",_msg.count)

	local rightBG  = self.m_rootLayer : getChildByTag(BG_VIEW_TAG) : getChildByTag(RIGHT_VIEW_TAG)

	if self.Sc_Container ~= nil then
		self.Sc_Container : removeFromParent()
	end

	self.Sc_Container = cc.Node : create()
    local ScrollView  = cc.ScrollView : create()

    local oneLine = 0
    local curHeight  = 10 
    local msgCount = 1
    for i = 1,_msg.count do
    	local msgLab ,height,lineCount= self : __createCombatLabel(_msg.data[_msg.count+1-i],msgCount,curHeight)
    	if  msgLab then
    		print("lineCount",lineCount)
    		ScrollView 	 : addChild(msgLab)
    		msgCount  = msgCount + 1
    		curHeight = height
    		oneLine   = lineCount 
    	end
    end
    
    if oneLine == 1 then
    	curHeight = curHeight + self.m_msgSize.height/2*oneLine
    else
    	curHeight = curHeight + self.m_msgSize.height/2*oneLine/2
    end

    msgCount = msgCount -1

    print("战报信息有：  ",msgCount)
    
    count = msgCount

    local viewSize     = cc.size(self.m_msgSize.width-10,(self.m_msgSize.height+13)*4)
	
    self.containerSize = cc.size(self.m_msgSize.width-10, curHeight)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(self.containerSize)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-self.containerSize.height))
    ScrollView 		: setAnchorPoint(cc.p(0,0))
    ScrollView      : setPosition(cc.p(0,0))
    print("容器大小：", self.m_msgSize.height*count)
    ScrollView      : setBounceable(false)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    self.Sc_Container    : addChild(ScrollView)
    self.Sc_Container    : setAnchorPoint(cc.p(0,0))
    self.Sc_Container    : setPosition(cc.p(0,14))
    rightBG              : addChild(self.Sc_Container)

    if curHeight >= viewSize.height then
    	local barView = require("mod.general.ScrollBar")(ScrollView)
	    barView 	  : setPosOff(cc.p(-4,0))
	    -- barView 	  : setMoveHeightOff(-5)
    end
end

function ServantView.__createCombatLabel( self,_msg,i,_curHeight)

	local msgLab   = ccui.Widget : create()
    msgLab         : setContentSize( self.m_msgSize )
    msgLab         : setAnchorPoint( cc.p(0.0,0.5) )
    --msgLab         : setPosition(cc.p(0,(i-1)*(self.m_msgSize.height+10) + self.m_msgSize.height/2 + 10))

    local fontSize  = 20
    local offset    = 20
    local lineCount = 2

    local time 		= _G.Util : createLabel(self : __combatTime(_msg.time), fontSize)
    -- time 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
    time 	   		: setAnchorPoint( cc.p(0.0,0) )
    time 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))

    local myPersonUid = _G.GPropertyProxy : getMainPlay() : getUid()
    if     _msg.type == 1 then
    	print("抓捕",_msg.res)
    	if myPersonUid == _msg.uid and _msg.res == 1 then
    		msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width

    		local lab1 		= _G.Util : createLabel("你", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local text1 	= _G.Util : createLabel("成功", fontSize)
		    text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    text1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text1)
		    offset 			= offset + text1 : getContentSize().width

		    local text2 	= _G.Util : createLabel("抓捕了", fontSize)
		    -- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text2)
		    offset 			= offset + text2 : getContentSize().width

		    local lab2 		= _G.Util : createLabel(_msg.bname, fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local length    = lab2 : getContentSize().width + time : getContentSize().width
		    local str1      = ","
		    local str2      = "他成为你的奴仆。"
		    if length <= 120 then
		      	str1 = ",他成为"
		      	str2 = "你的奴仆。"
		    elseif length <= 140 then
		    	str1 = ",他成"
		      	str2 = "为你的奴仆。"
		    elseif length <= 160 then
		    	str1 = ",他"
		      	str2 = "成为你的奴仆。"
		    else
		    	str1 = ","
		      	str2 = "他成为你的奴仆。"
		    end  

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab4 	   		: setPosition(cc.p(20,0))
		    msgLab          : addChild(lab4)
		    
    	elseif myPersonUid == _msg.buid and _msg.res == 1 then
    		msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
    		print("被抓捕")
    		local lab1 		= _G.Util : createLabel(_msg.name, fontSize)
		    lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local lab2 		= _G.Util : createLabel("成功", fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local text 		= _G.Util : createLabel("抓捕了你", fontSize)
		    -- text 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text)
		    offset 			= offset + text : getContentSize().width

		    local length    = lab1 : getContentSize().width + time : getContentSize().width
		    local str1      = ""
		    local str2      = ",你成为他的奴仆。"
		    if length <= 120 then
		      	str1 = ",你成为"
		      	str2 = "他的奴仆。"
		    elseif length <= 140 then
		    	str1 = ",你成"
		      	str2 = "为他的奴仆。"
		    elseif length <= 160 then
		    	str1 = ",你"
		      	str2 = "成为他的奴仆。"
		    else
		    	str1 = ","
		      	str2 = "你成为他的奴仆。"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab4 	   		: setPosition(cc.p(20,0))
		    msgLab          : addChild(lab4)
		    
		elseif myPersonUid == _msg.uid and _msg.res == 0 then
			return nil
		elseif myPersonUid == _msg.buid and _msg.res == 0 then
			return nil
    	end
	elseif _msg.type == 3 then

		if myPersonUid == _msg.uid then
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
    		print("调教")
    		local lab1 		= _G.Util : createLabel("你", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local text1 	= _G.Util : createLabel("调教", fontSize)
		    text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    text1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text1)
		    offset 			= offset + text1 : getContentSize().width

		    local text2 	= _G.Util : createLabel("了苦工", fontSize)
		    -- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text2)
		    offset 			= offset + text2 : getContentSize().width

		    local lab2 		= _G.Util : createLabel(_msg.bname, fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local length    = lab2 : getContentSize().width + time : getContentSize().width
		    local str1      = ",获得了"
		    local str2      = ""
		    if length <= 120 then
		    	str1 = ",获得了"
		      	str2 = ""
		    elseif length <= 140 then
		    	str1 = ",获得"
		      	str2 = "了"
		    elseif length <= 160 then
		    	str1 = ",获"
		      	str2 = "得了"
		    else
		    	str1 = ","
		      	str2 = "获得了"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    local lab3 		= _G.Util : createLabel(str2..tostring(_msg.active_exp).."铜钱。", fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(20,0))
		    msgLab          : addChild(lab3)
    	else
    		return nil
    	end
	elseif _msg.type == 5 then
		print("反抗",_msg.res)
		if _msg.res ==1 and myPersonUid == _msg.uid then
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
    		local lab1 		= _G.Util : createLabel("你", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local text1 	= _G.Util : createLabel("成功", fontSize)
		    text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    text1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text1)
		    offset 			= offset + text1 : getContentSize().width

		    local text2 	= _G.Util : createLabel("反抗了", fontSize)
		    -- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text2)
		    offset 			= offset + text2 : getContentSize().width

		    local lab2 		= _G.Util : createLabel(_msg.bname, fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local length    = lab2 : getContentSize().width + time : getContentSize().width
		    local str1      = ",恢复了自由。"
		    local str2      = ""
		    if length <= 120 then
		      	str1 = ",恢复了"
		      	str2 = "自由。"
		    elseif length <= 140 then
		    	str1 = ",恢复"
		      	str2 = "了自由。"
		    elseif length <= 160 then
		    	str1 = ",恢"
		      	str2 = "复了自由。"
		    else
		    	str1 = ","
		      	str2 = "恢复了自由。"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab4 	   		: setPosition(cc.p(20,0))
		    msgLab          : addChild(lab4)
		    
		elseif _msg.res ==0 and myPersonUid == _msg.uid then
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
			local lab1 		= _G.Util : createLabel("你反抗了", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local lab2 		= _G.Util : createLabel(_msg.bname, fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local lab3 		= _G.Util : createLabel(",但", fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)
		    offset 			= offset + lab3 : getContentSize().width

		    local length    = lab2 : getContentSize().width + time : getContentSize().width
		    local str1      = ""
		    local str2      = "失败了。"
		    local str3      = ""
		    local count     = 2
		    if length <= 120 then
		    	str1 = "失败"
		      	str2 = ""
		      	str3 = "了。"
		      	count= 1
		    elseif length <= 140 then
		    	str1 = "失"
		      	str2 = "败"
		      	str3 = "了。"
		    else
		    	str1 = ""
		      	str2 = "失败"
		      	str3 = "了。"
		    end

		    local lab4 		= _G.Util : createLabel(str1, fontSize)
		    lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		    lab4 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab4 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab4)
		    offset 			= offset + lab4 : getContentSize().width

		    local lab5 		= _G.Util : createLabel(str2, fontSize)
		    lab5 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		    lab5 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab5 	   		: setPosition(cc.p(20,0))
		    msgLab          : addChild(lab5)

		    local lab6 		= _G.Util : createLabel(str3, fontSize)
		    -- lab6 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab6 	   		: setAnchorPoint( cc.p(0.0,0) )
		    if count==1 then
		    	lab6 : setPosition(cc.p(offset,self.m_msgSize.height/2))
		    else
		    	lab6 : setPosition(cc.p(20+lab5:getContentSize().width,0))
		    end
		    msgLab          : addChild(lab6)

		    if count==1 then
		    	lineCount = 1
		    end
		elseif _msg.res ==0 and myPersonUid == _msg.buid then
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
    		local lab1 		= _G.Util : createLabel("你", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local text1 	= _G.Util : createLabel("成功", fontSize)
		    text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    text1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text1)
		    offset 			= offset + text1 : getContentSize().width

		    local text2 	= _G.Util : createLabel("镇压了", fontSize)
		    -- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text2)
		    offset 			= offset + text2 : getContentSize().width

		    local lab2 		= _G.Util : createLabel(_msg.name, fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local length    = lab2 : getContentSize().width + time : getContentSize().width
		    local str1      = ""
		    local str2      = "的反抗。"
		    if length <= 120 then
		    	str1 = "的反抗。"
		      	str2 = ""
		    elseif length <= 140 then
		    	str1 = "的反"
		      	str2 = "抗。"
		    elseif length <= 160 then
		    	str1 = "的"
		      	str2 = "反抗。"
		    else
		    	str1 = ""
		      	str2 = "的反抗。"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab4 	   		: setPosition(cc.p(20,0))
		    msgLab          : addChild(lab4)

		    if str2 == "" then
		    	lineCount = 1
		    end
		    
		elseif _msg.res ==1 and myPersonUid == _msg.buid then
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
			local lab1 		= _G.Util : createLabel(_msg.name, fontSize)
		    lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local lab2 	    = _G.Util : createLabel("成功", fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local text 	    = _G.Util : createLabel("反抗了你。", fontSize)
		    -- text 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text)

		    lineCount = 1
		end
	elseif _msg.type == 7 then
		print("抢夺",_msg.res2)
		if _msg.res2 ==1 and myPersonUid == _msg.uid then
			print("抢夺")
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
    		local lab1 		= _G.Util : createLabel("你", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local text1 	= _G.Util : createLabel("成功", fontSize)
		    text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    text1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text1)
		    offset 			= offset + text1 : getContentSize().width

		    local text2 	= _G.Util : createLabel("抢夺了", fontSize)
		    -- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text2)
		    offset 			= offset + text2 : getContentSize().width

		    local lab2 		= _G.Util : createLabel(_msg.bname, fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local length    = lab2 : getContentSize().width + time : getContentSize().width
		    local str1      = ""
		    local str2      = "的奴仆"
		    if length <= 120 then
		    	str1 = "的奴仆"
		      	str2 = ""
		    elseif length <= 140 then
		    	str1 = "的奴"
		      	str2 = "仆"
		    elseif length <= 160 then
		    	str1 = "的"
		      	str2 = "奴仆"
		    else
		    	str1 = ""
		      	str2 = "的奴仆"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    offset 			= 20 

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab4 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab4)
		    offset 			= offset + lab4 : getContentSize().width

		    local lab5 		= _G.Util : createLabel(_msg.mname, fontSize)
		    lab5 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab5 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab5 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab5)
		    offset 			= offset + lab5 : getContentSize().width

		    local lab6 		= _G.Util : createLabel("。", fontSize)
		    -- lab6 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab6 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab6 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab6)

		elseif _msg.res2 == 1 and myPersonUid == _msg.buid then
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
			print("被抢夺")
    		local lab1 		= _G.Util : createLabel(_msg.name, fontSize)
		    lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local lab2 	    = _G.Util : createLabel("成功", fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local text 	    = _G.Util : createLabel("抢夺了你", fontSize)
		    -- text 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text)
		    offset 			= offset + text : getContentSize().width

		    local length    = lab1 : getContentSize().width + time : getContentSize().width
		    local str1      = ""
		    local str2      = "的奴仆"
		    if length <= 120 then
		    	str1 = "的奴仆"
		      	str2 = ""
		    elseif length <= 140 then
		    	str1 = "的奴"
		      	str2 = "仆"
		    elseif length <= 160 then
		    	str1 = "的"
		      	str2 = "奴仆"
		    else
		    	str1 = ""
		      	str2 = "的奴仆"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    offset 			= 20 

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0,0) )
		    lab4 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab4)
		    offset 			= offset + lab4 : getContentSize().width

		    local lab5 		= _G.Util : createLabel(_msg.mname, fontSize)
		    lab5 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab5 	   		: setAnchorPoint( cc.p(0,0) )
		    lab5 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab5)
		    offset 			= offset + lab5 : getContentSize().width

		    local lab6 		= _G.Util : createLabel("。", fontSize)
		    -- lab6 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab6 	   		: setAnchorPoint( cc.p(0,0) )
		    lab6 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab6)

		elseif _msg.res2 ==0 and myPersonUid == _msg.buid then
			msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
			print("被抢夺")
    		local lab1 		= _G.Util : createLabel("你", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local lab2 	    = _G.Util : createLabel("成功", fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local text 	    = _G.Util : createLabel("抵御了", fontSize)
		    -- text 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text)
		    offset 			= offset + text : getContentSize().width

		    local lab3 		= _G.Util : createLabel(_msg.name, fontSize)
		    lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)
		    offset 			= offset + lab3 : getContentSize().width

		    local length    = lab3 : getContentSize().width + time : getContentSize().width
		    local str1      = ""
		    local str2      = "对你的"
		    if length <= 120 then
		    	str1 = "对你的"
		      	str2 = ""
		    elseif length <= 140 then
		    	str1 = "对你"
		      	str2 = "的"
		    elseif length <= 160 then
		    	str1 = "对"
		      	str2 = "你的"
		    else
		    	str1 = ""
		      	str2 = "对你的"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    offset 			= 20 

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0,0) )
		    lab4 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab4)
		    offset 			= offset + lab4 : getContentSize().width

		    local lab5 		= _G.Util : createLabel("苦工的抢夺。", fontSize)
		    -- lab5 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab5 	   		: setAnchorPoint( cc.p(0,0) )
		    lab5 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab5)
		elseif _msg.res2 ==0 and myPersonUid == _msg.uid then
			return nil
		end
    elseif _msg.type == 8 then
    	if myPersonUid == _msg.uid then
    		msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
    		print("释放")
    		local lab1 		= _G.Util : createLabel("你", fontSize)
		    -- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local text1 	= _G.Util : createLabel("释放", fontSize)
		    text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    text1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text1)
		    offset 			= offset + text1 : getContentSize().width

		    local text2 	= _G.Util : createLabel("了奴仆", fontSize)
		    -- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text2)
		    offset 			= offset + text2 : getContentSize().width

		    local lab2 		= _G.Util : createLabel(_msg.bname, fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local length    = lab2 : getContentSize().width + time : getContentSize().width
		    local str1      = ",获得了"
		    local str2      = ""
		    if length <= 120 then
		    	str1 = ",获得了"
		      	str2 = ""
		    elseif length <= 140 then
		    	str1 = ",获得"
		      	str2 = "了"
		    elseif length <= 160 then
		    	str1 = ",获"
		      	str2 = "得了"
		    else
		    	str1 = ","
		      	str2 = "获得了"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    local lab3 		= _G.Util : createLabel(str2..tostring(_msg.exp).."铜钱。", fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab3 	   		: setPosition(cc.p(10,0))
		    msgLab          : addChild(lab3)
		    
    	else
    		msgLab          : addChild(time)
    		offset 			= offset + time : getContentSize().width
    		print("被释放")
    		local lab1 		= _G.Util : createLabel(_msg.name, fontSize)
		    lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		    lab1 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab1 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab1)
		    offset 			= offset + lab1 : getContentSize().width

		    local lab2 	    = _G.Util : createLabel("释放", fontSize)
		    lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
		    lab2 	   		: setAnchorPoint( cc.p(0.0,0) )
		    lab2 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab2)
		    offset 			= offset + lab2 : getContentSize().width

		    local text 	    = _G.Util : createLabel("了你，你", fontSize)
		    -- text 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    text 	   		: setAnchorPoint( cc.p(0.0,0) )
		    text 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(text)
		    offset 			= offset + text : getContentSize().width

		    local length    = lab1 : getContentSize().width + time : getContentSize().width
		    local str1      = ""
		    local str2      = "恢复了"
		    if length <= 120 then
		    	str1 = "恢复了"
		      	str2 = ""
		    elseif length <= 140 then
		    	str1 = "恢复"
		      	str2 = "了"
		    elseif length <= 160 then
		    	str1 = "恢"
		      	str2 = "复了"
		    else
		    	str1 = ""
		      	str2 = "恢复了"
		    end

		    local lab3 		= _G.Util : createLabel(str1, fontSize)
		    -- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab3 	   		: setAnchorPoint( cc.p(0,0) )
		    lab3 	   		: setPosition(cc.p(offset,self.m_msgSize.height/2))
		    msgLab          : addChild(lab3)

		    offset 			= 20 

		    local lab4 		= _G.Util : createLabel(str2, fontSize)
		    -- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab4 	   		: setAnchorPoint( cc.p(0,0) )
		    lab4 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab4)
		    offset 			= offset + lab4 : getContentSize().width

		    local lab5 		= _G.Util : createLabel("自由。" , fontSize)
		    -- lab5 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
		    lab5 	   		: setAnchorPoint( cc.p(0,0) )
		    lab5 	   		: setPosition(cc.p(offset,0))
		    msgLab          : addChild(lab5)
		    offset 			= offset + lab5 : getContentSize().width

    	end
    end
    if i==1 then
    	_curHeight = _curHeight + self.m_msgSize.height/2*lineCount/2
    else
    	_curHeight = _curHeight + self.m_msgSize.height/2*lineCount + 10
    end
    
    msgLab : setPosition(cc.p(0,_curHeight))

    return msgLab,_curHeight,lineCount
end

function ServantView.__combatTime( self,times)
	local nowTime     = _G.TimeUtil:getNowSeconds()
    local offlineTime = nowTime - times


    local times_str   = os.date("*t", times)
    local nowTime_str = os.date("*t", nowTime)

    local temptime = ""
    if math.floor( offlineTime/(86400*30) ) > 0 then --一个月前
        temptime = "[1个月前]"
    elseif math.floor( offlineTime/86400 ) > 0 then  --超过一天
        temptime = "["..math.floor( offlineTime/86400 ).._G.Lang.LAB_N[92].."]"
    -- elseif math.floor( offlineTime/3600 ) > 0 then   --超过一个小时但一天内
    --     temptime = math.floor( offlineTime/3600 ).._G.Lang.LAB_N[91]
    -- elseif math.floor( offlineTime/60 ) > 0 then   --超过一分钟 但一个小时内
    --     temptime = math.floor( offlineTime/60 ).._G.Lang.LAB_N[90]
    else
        -- temptime = "1".._G.Lang.LAB_N[90]

        if times_str ~= nil and nowTime_str ~= nil then
           if tostring(times_str.day) ~= tostring(nowTime_str.day) then
               temptime  = "[昨天]"
           else
               local min = string.format("%.2d", times_str.min)
               temptime  = "["..times_str.hour ..":".. min.."]"
           end
        else
           temptime = "error"
        end
    end
    return temptime
end

function ServantView.__getTimeStr( self,_time)
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

--初始化抓捕界面
function ServantView.__initCaptureLayer( self )
	print("初始化抓捕界面")
	self.m_captureSize = cc.size(618,426)
	local function onTouchBegan(touch) 
		print("captureLayer remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-self.m_captureSize.width/2,self.m_winSize.height/2-self.m_captureSize.height/2,
        self.m_captureSize.width,self.m_captureSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
          return true
        end
        self:delayCallFun()
        return true 
	end
	print("创建抓捕UI")
	local listerner = cc.EventListenerTouchOneByOne : create()
	listerner 	    : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner 		: setSwallowTouches(true)

	local captureLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))
	captureLayer 	  : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, captureLayer)
	captureLayer 	  : setTag(CAPTURE_UI_TAG)
	cc.Director 	  : getInstance() : getRunningScene() : addChild(captureLayer,888)

	-- self : __initCloseCaptureBtn()
	self : __initCaptureView()
	self : __captureNetWorkSend()
end

function ServantView.delayCallFun( self )
    local function nFun()
        cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG) : removeFromParent(true)
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG):runAction(cc.Sequence:create(delay,func))
end

-- function ServantView.__initCloseCaptureBtn( self )
-- 	local function closeCallBack(sender, eventType)
-- 	    print("关闭抓捕界面")
-- 		if eventType == ccui.TouchEventType.ended then
-- 			if self.Button ~= nil then
-- 		    	self.Button = nil
-- 		    end
-- 			cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG) : removeFromParent()
-- 		end
-- 	end
-- 	local m_closeBtn= gc.CButton : create("general_close.png")
-- 	self.m_closeBtnS= m_closeBtn : getContentSize()
-- 	m_closeBtn      : setAnchorPoint(cc.p(0.5,0.5))
-- 	m_closeBtn      : setPosition(cc.p(self.m_captureSize.width/2-5,self.m_captureSize.height/2-20))
-- 	m_closeBtn      : addTouchEventListener(closeCallBack)
-- 	m_closeBtn      : setSoundPath("bg/ui_sys_clickoff.mp3")
-- 	cc.Director 	: getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG) : addChild(m_closeBtn, _G.Const.CONST_MAP_ZORDER_LAYER+20)
-- 	--[[
-- 	local m_closeSpr= cc.Sprite : createWithSpriteFrameName("general_artifact.png")
-- 	m_closeSpr	  	: setPosition(cc.p(self.m_closeBtnS.width/4, self.m_closeBtnS.height/4-2))
-- 	m_closeBtn	  	: addChild(m_closeSpr, _G.Const.CONST_MAP_ZORDER_LAYER+10)
-- 	]]
-- end

function ServantView.__captureNetWorkSend( self )
	local msg = REQ_MOIL_OPER()
	msg       : setArgs(1)
	_G.Network: send(msg)
end

function ServantView.__initCaptureView( self )
	local fontSize = 20

	local m_layer = cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG)

	local m_bgSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	m_bgSpr	  	  : setPreferredSize(self.m_captureSize)
	m_bgSpr 	  : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	m_bgSpr       : setTag(CAPTURE_BG)
	m_layer  	  : addChild(m_bgSpr)

	local second_bg = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	second_bg   	: setTag(CAPTURE_BG_3)
	second_bg 	  	: setPosition(cc.p(self.m_captureSize.width/2, self.m_captureSize.height/2-18))
	second_bg	  	: setPreferredSize(cc.size(self.m_captureSize.width-17,self.m_captureSize.height-52))
	m_bgSpr 		: addChild(second_bg)

	-- local three_bg	= ccui.Widget : create()
	-- three_bg        : setAnchorPoint(cc.p(0,0))
	-- three_bg 	  	: setPosition(cc.p(25, 25))
	-- three_bg	    : setContentSize(cc.size(self.m_captureSize.width-50,self.m_captureSize.height-80))
	-- three_bg        : setTag(CAPTURE_BG_3)
	-- m_bgSpr 		: addChild(three_bg)

	local function loserBtnEvent( sender,eventType )
		self : __loserBtnEvent(sender,eventType)
	end

	local function captureBtnEvent( sender,eventType )
		self : __captureBtnEvent(sender,eventType)
	end

	local szNormal="general_btn_weixuan.png"
    local szPress="general_btn_selected.png"
    local button1   = gc.CButton:create()
    button1         : loadTextures(szNormal,szPress,szPress) 
    button1         : addTouchEventListener(loserBtnEvent)
    -- button1         : setTitleText("手下败将")
    -- button1         : setTitleFontName(_G.FontName.Heiti)
    -- button1         : enableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PSTROKE))
    -- button1         : setEnableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
    -- button1         : setTitleFontSize(24)
    button1         : setEnabled(false)
    button1         : setBright(false)
    button1 		: setTag(LOSER_BTN)
    button1         : setAnchorPoint(cc.p(0,1))
    button1         : setPosition(cc.p(50,self.m_captureSize.height-7))
    m_bgSpr         : addChild(button1)

    local button2   = gc.CButton:create()
    button2         : loadTextures(szNormal,szPress,szPress)
    button2         : addTouchEventListener(captureBtnEvent)
    -- button2         : setTitleText("夺仆之敌")
    -- button2         : setTitleFontName(_G.FontName.Heiti)
    -- button2         : enableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PSTROKE))
    -- button2         : setEnableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
    -- button2         : setTitleFontSize(24)
    button2         : setEnabled(true)
    button2         : setBright(true)
    button2         : setTag(ENEMY_BTN)
    button2         : setAnchorPoint(cc.p(0,1))
    button2         : setPosition(cc.p(65+button1 : getContentSize().width,self.m_captureSize.height-7))
    m_bgSpr         : addChild(button2)

    local btnLab1 = _G.Util:createBorderLabel("手下败将",24,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE))
    btnLab1:setPosition(57,18)
    btnLab1:setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
    btnLab1:setTag(1111)
    button1:addChild(btnLab1)

    local btnLab2 = _G.Util:createBorderLabel("夺仆之敌",24,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE))
    btnLab2:setPosition(57,18)
    btnLab2:setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
    btnLab2:setTag(2222)
    button2:addChild(btnLab2)
end

function ServantView.__loserBtnEvent( self,sender,eventType )
	if eventType == ccui.TouchEventType.ended then
		print("手下败将")
		local m_layer    = cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG)
		local button1    = m_layer : getChildByTag(CAPTURE_BG) : getChildByTag(LOSER_BTN)
		local button2    = m_layer : getChildByTag(CAPTURE_BG) : getChildByTag(ENEMY_BTN)

	    button1          : setEnabled(false)
	    button1          : setBright(false)
	    button1:getChildByTag(1111):setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))

	    button2          : setEnabled(true)
	    button2          : setBright(true)
	    button2:getChildByTag(2222):setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))

	   	local msg = REQ_MOIL_OPER()
		msg       : setArgs(1)
		_G.Network: send(msg)
	end
end

function ServantView.__captureBtnEvent( self,sender,eventType )
	if eventType == ccui.TouchEventType.ended then
		print("夺仆之敌")
		local m_layer  = cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG)
		local button1  = m_layer : getChildByTag(CAPTURE_BG) : getChildByTag(LOSER_BTN)
		local button2  = m_layer : getChildByTag(CAPTURE_BG) : getChildByTag(ENEMY_BTN)

	    button1        : setEnabled(true)
	    button1        : setBright(true)
	    button1:getChildByTag(1111):setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))

	    button2        : setEnabled(false)
	    button2        : setBright(false)
	    button2:getChildByTag(2222):setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))

	   	local msg = REQ_MOIL_OPER()
		msg       : setArgs(7)
		_G.Network: send(msg)
	end
end

function ServantView.updateLoserUI( self,_msg )
	print("刷新手下败将界面")
	self : __initCaptureScrollView(_msg)
end

function ServantView.updateEnemyUI( self,_msg )
	print("刷新夺仆之敌界面")
	self : __initCaptureScrollView(_msg)
end

function ServantView.__initCaptureScrollView( self,_msg )
	local m_layer  = cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG)
	local m_bgView = m_layer : getChildByTag(CAPTURE_BG) : getChildByTag(CAPTURE_BG_3)

	local msgSize  = cc.size(m_bgView : getContentSize().width-4,(m_bgView : getContentSize().height-8)/4) 

	m_bgView : removeAllChildren()

	if _msg.count == 0 then
		local dins = cc.Sprite : createWithSpriteFrameName("general_monkey.png")
		dins       : setPosition(cc.p(m_bgView:getContentSize().width/2,m_bgView:getContentSize().height/2+60))
		m_bgView   : addChild(dins)
		if     _msg.type == 1 then
			local tipLab   = ccui.Widget : create()
			tipLab         : setContentSize( cc.size(500,24) )
			tipLab         : setAnchorPoint( cc.p(0.5,0.5) )
			tipLab         : setPosition(cc.p(m_bgView : getContentSize().width/2,m_bgView : getContentSize().height*0.45))
			m_bgView       : addChild(tipLab)

			local flag     = 0

			local tips     = _G.Util : createLabel("暂无手下败将,请前往",24)
			-- tips 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
			tips 	   	   : setAnchorPoint( cc.p(0,0) )
			tips 	   	   : setPosition(cc.p(flag,0))
			tipLab         : addChild(tips)

			flag           = flag + tips : getContentSize().width 

			local tips2    = _G.Util : createLabel("竞技场",24)
			tips2 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
			tips2 	   	   : setAnchorPoint( cc.p(0,0) )
			tips2 	   	   : setPosition(cc.p(flag,0))
			tipLab         : addChild(tips2)

			local function openEvent( sender,eventType )
				if eventType == ccui.TouchEventType.ended then
					print("开启传送阵，请速度进入圈内")
					_G.GLayerManager :openSubLayer(_G.Const.CONST_FUNC_OPEN_ARENA)
				end
			end

			local tipsBtn  = ccui.Widget : create()
			tipsBtn        : setContentSize( cc.size(60,24) )
			tipsBtn 	   : setAnchorPoint( cc.p(0,0) )
			tipsBtn 	   : setPosition(cc.p(flag,0))
			tipsBtn        : setTouchEnabled(true)
			tipsBtn        : addTouchEventListener(openEvent)
			tipLab         : addChild(tipsBtn)

			local line     = _G.Util : createLabel("_____",30)
			line 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
			line 	   	   : setAnchorPoint( cc.p(0,0) )
			line 	   	   : setPosition(cc.p(flag,0))
			tipLab         : addChild(line,11)

			flag           = flag + tips2 : getContentSize().width 

			local tips3    = _G.Util : createLabel("击败其他玩家。",24)
			-- tips3 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
			tips3 	   	   : setAnchorPoint( cc.p(0,0) )
			tips3 	   	   : setPosition(cc.p(flag,0))
			tipLab         : addChild(tips3)
		elseif _msg.type == 7 then
			local tipLab   = ccui.Widget : create()
			tipLab         : setContentSize( cc.size(120,24) )
			tipLab         : setAnchorPoint( cc.p(0.5,0.5) )
			tipLab         : setPosition(cc.p(m_bgView : getContentSize().width/2,m_bgView : getContentSize().height*0.45))
			m_bgView       : addChild(tipLab)

			local tips     = _G.Util : createLabel("暂无夺仆之敌",24)
			-- tips 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
			tips 	   	   : setAnchorPoint( cc.p(0,0) )
			tips 	   	   : setPosition(cc.p(0,0))
			tipLab         : addChild(tips)
		end
		return
	end

	self.Sc_Container = cc.Node : create()

    local ScrollView  = cc.ScrollView : create()
    
    local count 	   = _msg.count
    if count < 4 then
    	count = 4
    end
    local viewSize     = cc.size(msgSize.width,msgSize.height*4)
	
    self.containerSize = cc.size(msgSize.width, msgSize.height*count)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(self.containerSize)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-self.containerSize.height))
    ScrollView      : setAnchorPoint(cc.p(0,0))
    ScrollView      : setPosition(cc.p(0,0))
    print("容器大小：", msgSize.height*count)
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    self.Sc_Container    : addChild(ScrollView)
    self.Sc_Container    : setAnchorPoint(cc.p(0,0))
    self.Sc_Container    : setPosition(cc.p(0,4))
    m_bgView             : addChild(self.Sc_Container,0)

    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView 	  : setPosOff(cc.p(-4,0))
    -- barView 	  : setMoveHeightOff(-5)

    if self.Button ~= nil then
    	self.Button = nil
    end
    self.Button   = {}

    for i=1,_msg.count do
    	if     _msg.type == 1 then
    		ScrollView : addChild(self : __initLoserLabel(i,_msg))
    	elseif _msg.type == 7 then
    		ScrollView : addChild(self : __initEnemyLabel(i,_msg,1))	
    	end
    end
end

function ServantView.__initLoserLabel( self,i,_msg )

	local m_layer  = cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG)
	local m_bgView = m_layer : getChildByTag(CAPTURE_BG) : getChildByTag(CAPTURE_BG_3)

	local msgSize  = cc.size(m_bgView : getContentSize().width-4,(m_bgView : getContentSize().height-8)/4)

	local count = _msg.count
	if count < 4 then
		count = 4
	end

	local msgLab   = ccui.Scale9Sprite : createWithSpriteFrameName("general_nothis.png")
	msgLab         : setContentSize( cc.size(msgSize.width-10,msgSize.height-6) )
	-- msgLab         : setAnchorPoint( cc.p(0,0) )
	msgLab         : setPosition(cc.p(msgSize.width/2+2,msgSize.height*(count+0.5 - i)))

	-- local lineBg 	= ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
 --    local lineSprSize = lineBg : getPreferredSize()
 --    lineBg 			: setPreferredSize( cc.size(msgSize.width, lineSprSize.height) )
 --    lineBg 			: setAnchorPoint( cc.p(0.0,0.0) )
 --    lineBg 			: setPosition(cc.p(0, 0))
 --    msgLab 		    : addChild(lineBg)

	local person   = cc.Sprite : createWithSpriteFrameName(string.format("general_role_head%d.png",_msg.data[i].pro))
	person         : setScale(0.7)
	person         : setAnchorPoint(cc.p(0,0))
	person         : setPosition(cc.p(15,5))
	msgLab         : addChild(person)

	local name     = _G.Util : createLabel(_msg.data[i].name,20)
	name 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKORANGE))
	name 	   	   : setAnchorPoint( cc.p(0,0) )
	name 	   	   : setPosition(cc.p(100,48))
	msgLab         : addChild(name)

	local master   = _G.Util : createLabel("主人:",20)
	master 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
	master 	   	   : setAnchorPoint( cc.p(0,0) )
	master 	   	   : setPosition(cc.p(100,15))
	msgLab         : addChild(master)

	local master   = _G.Util : createLabel(_msg.data[i].lord_name,20)
	if not _msg.data[i].lord_name then
		master : setString("无")
	end
	master 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKORANGE))
	master 	   	   : setAnchorPoint( cc.p(0,0) )
	master 	   	   : setPosition(cc.p(160,15))
	msgLab         : addChild(master)

	local power   = _G.Util : createLabel("主人战力:",20)
	if not _msg.data[i].lord_name then
		power : setString("自身战力:")
	end
	power 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
	power 	   	   : setAnchorPoint( cc.p(0,0.5) )
	power 	   	   : setPosition(cc.p(msgSize.width/2-40,msgSize.height/2))
	msgLab         : addChild(power)

	local powerData= _G.Util : createLabel(tostring(_msg.data[i].power),20)
	powerData 	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKORANGE))
	powerData 	   : setAnchorPoint( cc.p(0,0.5) )
	powerData 	   : setPosition(cc.p(msgSize.width/2+power : getContentSize().width/2+20,msgSize.height/2))
	msgLab         : addChild(powerData)

	local lv       = _G.Util : createLabel("LV.".._msg.data[i].lv,20)
	--lv 	   	       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
	-- lv             : enableOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
	lv 	   	       : setAnchorPoint( cc.p(0,0.5) )
	lv 	   	       : setPosition(cc.p(30,20))
	msgLab         : addChild(lv,1)

	local function loserEvent( sender,eventType )
		self : __loserEvent(sender,eventType,_msg)
	end

	local Button   = gc.CButton:create()
	Button         : loadTextures("general_btn_gold.png")
	Button         : setTitleText("抓 捕")
	Button         : addTouchEventListener(loserEvent)
	Button         : setTitleFontSize(24)
	Button         : setTitleFontName(_G.FontName.Heiti)
	-- Button         : setButtonScale(0.7)
	Button         : setAnchorPoint(cc.p(1,0.5))
	Button         : setPosition(cc.p(msgSize.width-40,msgSize.height/2-5))

	self.Button[i] = Button

	msgLab         : addChild(Button)
	
	return msgLab
end

function ServantView.__initEnemyLabel( self,i,_msg,type )
	local m_layer  = cc.Director : getInstance() : getRunningScene() : getChildByTag(CAPTURE_UI_TAG)
	local m_bgView = m_layer : getChildByTag(CAPTURE_BG) : getChildByTag(CAPTURE_BG_3)

	local msgSize  = cc.size(m_bgView : getContentSize().width-4,(m_bgView : getContentSize().height-8)/4)

	local count = _msg.count
	if count < 4 then
		count = 4
	end

	local msgLab   = ccui.Scale9Sprite : createWithSpriteFrameName("general_rolekuang.png")
	msgLab         : setContentSize( cc.size(msgSize.width-15,msgSize.height-6) )
	-- msgLab         : setAnchorPoint( cc.p(0,0) )
	msgLab         : setPosition(cc.p(msgSize.width/2+2,msgSize.height*(count+0.5 - i)))

	local person   = cc.Sprite : createWithSpriteFrameName(string.format("general_role_head%d.png",_msg.data[i].pro))
	person         : setScale(0.7)
	person         : setAnchorPoint(cc.p(0,0))
	person         : setPosition(cc.p(15,5))
	msgLab         : addChild(person)

	local height   = msgSize.height/2

	local name     = _G.Util : createLabel(_msg.data[i].name,20)
	name 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKORANGE))
	name 	   	   : setAnchorPoint( cc.p(0,0.5) )
	name 	   	   : setPosition(cc.p(100,height))
	msgLab         : addChild(name)

	local lv       = _G.Util : createLabel("LV.".._msg.data[i].lv,20)
	--lv 	   	       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
	-- lv             : enableOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
	lv 	   	       : setAnchorPoint( cc.p(0,0.5) )
	lv 	   	       : setPosition(cc.p(30,20))
	msgLab         : addChild(lv,1)

	local power   = _G.Util : createLabel("战力:",20)
	power 	   	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
	power 	   	   : setAnchorPoint( cc.p(0,0.5) )
	power 	   	   : setPosition(cc.p(msgSize.width/2-40,height))
	msgLab         : addChild(power)

	local powerData= _G.Util : createLabel(tostring(_msg.data[i].power),20)
	powerData 	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKORANGE))
	powerData 	   : setAnchorPoint( cc.p(0,0.5) )
	powerData 	   : setPosition(cc.p(msgSize.width/2+20,height))
	msgLab         : addChild(powerData)

	local function loserEvent( sender,eventType )
		self : __loserEvent(sender,eventType,_msg)
	end

	local function enemyEvent( sender,eventType )
		self : __enemyEvent(sender,eventType,_msg)
	end

	local Button = gc.CButton:create()
	Button       : loadTextures("general_btn_gold.png")
	Button       : setTitleText("夺 仆")
	Button       : addTouchEventListener(enemyEvent)
	Button       : setTitleFontSize(24)
	Button       : setTitleFontName(_G.FontName.Heiti)
	-- Button         : setButtonScale(0.7)
	Button       : setAnchorPoint(cc.p(1,0.5))
	Button       : setPosition(cc.p(msgSize.width-40,height-5))

	self.Button[i] = Button

	msgLab         : addChild(Button) 
	
	return msgLab
end

function ServantView.__loserEvent( self,sender,eventType,_msg )
	if eventType == ccui.TouchEventType.ended then
		for i=1,_msg.count do
			if self.Button[i] == sender then
				print("点击第"..tostring(i).."个按钮")
				_G.StageXMLManager : setScenePkType(_G.Const.CONST_MOIL_FUNCTION_CATCH)

				_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_JJC_MOIL_ID)

		        local msg = REQ_MOIL_CAPTRUE()
		        msg 	  : setArgs(1,_msg.data[i].uid)
		        _G.Network: send(msg)
				break
			end
		end
	end
end

function ServantView.__enemyEvent( self,sender,eventType,_msg )
	if eventType == ccui.TouchEventType.ended then
		for i=1,_msg.count do
			if self.Button[i] == sender then
				print("点击第"..tostring(i).."个按钮")

				local msg = REQ_MOIL_LOOK_TMOILS()
				msg       : setArgs(_msg.data[i].uid)
				_G.Network: send(msg)
				break
			end
		end
	end
end

function ServantView.initServantMsg( self,_msg )
	local size = cc.Director : getInstance() : getWinSize()

    local function onTouchBegan()
    	print("删除奴仆信息界面")
    	if self.SnatchBtn ~= nil then
    		self.SnatchBtn = nil
    	end
    	cc.Director : getInstance() : getRunningScene() : runAction(cc.Sequence : create(cc.DelayTime : create(0.05),cc.CallFunc : create(function (  )
    		cc.Director : getInstance() : getRunningScene() : getChildByTag(MOIL_MSG_UI) : removeFromParent()
    		print("成功删除背景")
    	end)))
		return true 
	end
	local listerner = cc.EventListenerTouchOneByOne : create()
	listerner 	    : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner 		: setSwallowTouches(true)

	local moilLayer = cc.Layer:create()
	moilLayer 	    : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, moilLayer)
	moilLayer 	    : setPosition(cc.p(size.width/2, size.height/2))
	moilLayer 	    : setTag(MOIL_MSG_UI)
	cc.Director 	: getInstance() : getRunningScene() : addChild(moilLayer,888)
	self : __initMoilLayer(_msg)
end

function ServantView.__initMoilLayer( self,_msg )
	print("初始化苦工信息界面")
	local m_layer = cc.Director : getInstance() : getRunningScene() : getChildByTag(MOIL_MSG_UI)

	local function bgEvent(  )
		return true
	end

	local m_bgSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	m_bgSpr	  	  : setPreferredSize(cc.size(400,320))
	m_bgSpr 	  : setPosition(cc.p(0,-20))
	m_layer  	  : addChild(m_bgSpr)

	local m_bgSpr1= ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	m_bgSpr1	  : setPreferredSize(cc.size(380,300))
	m_bgSpr1 	  : setPosition(cc.p(0,-20))
	m_layer  	  : addChild(m_bgSpr1,1)

	local label   = ccui.Widget : create()
	label         : setContentSize( cc.size(380,293) )
	label 		  : setPosition(cc.p(0,-20))
	label         : setTouchEnabled(true)
	label         : addTouchEventListener(bgEvent)
	m_layer 	  : addChild(label,2)

	self.SnatchBtn  = {}

	if _msg.count == 0 then
		local dins = cc.Sprite : createWithSpriteFrameName("general_monkey.png")
		dins : setPosition(cc.p(190,150))
		label: addChild(dins)
	end

	for i=1,_msg.count do
		local lab   = ccui.Scale9Sprite : createWithSpriteFrameName("general_rolekuang.png")
		lab         : setContentSize( cc.size(365,91) )
		lab         : setAnchorPoint(cc.p(0,0))
		lab 		: setPosition(cc.p(7,293 - 96*i))
		label 	    : addChild(lab)

		local person   = cc.Sprite : createWithSpriteFrameName(string.format("general_role_head%d.png",_msg.data[i].pro))
		person         : setScale(0.8)
		person         : setAnchorPoint(cc.p(0,0))
		person         : setPosition(cc.p(15,5))
		lab            : addChild(person)

		local name  = _G.Util : createLabel(_msg.data[i].name,20)
		name        : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		name        : setAnchorPoint(cc.p(0,0.5))
		name    	: setPosition(cc.p(100,45))
		lab 		: addChild(name)

		local lv    = _G.Util : createLabel("LV.".._msg.data[i].lv,20)
		-- lv          : enableOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
		lv          : setAnchorPoint(cc.p(0,0))
		lv    	    : setPosition(cc.p(30,5))
		lab 		: addChild(lv)

	    local function snatchEvent( sender,eventType )
			self : __snatchEvent(sender,eventType,_msg)
		end

		local Button   = gc.CButton:create()
		Button         : loadTextures("general_btn_gold.png")
		Button         : setTitleText("抢 夺")
		Button         : addTouchEventListener(snatchEvent)
		Button         : setTitleFontSize(24)
		Button         : setTitleFontName(_G.FontName.Heiti)
		-- Button         : setButtonScale(0.7)
		Button         : setAnchorPoint(cc.p(1,0.5))
		Button         : setPosition(cc.p(345,45))
		lab            : addChild(Button)

		self.SnatchBtn[i] = Button
	end
end

function ServantView.__snatchEvent( self,sender,eventType,_msg )
	if eventType == ccui.TouchEventType.ended then
		for i=1,_msg.count do
			if self.SnatchBtn[i] == sender then
				print("抢夺第几个奴仆：",i)
				_G.StageXMLManager : setScenePkType(_G.Const.CONST_MOIL_FUNCTION_CATCH)

				_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_JJC_MOIL_ID)

		        local msg = REQ_MOIL_CAPTRUE()
		        msg 	  : setArgs(1,_msg.data[i].uid)
		        _G.Network: send(msg)
			end
		end
	end
end

function ServantView.__closeWindow( self )
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	_G.Scheduler         : unschedule(self.m_timeScheduler)
	self.m_timeScheduler = nil
	cc.Director:getInstance():popScene()
	self 			     : unregister()
end

return ServantView