local JingXiuView   = classGc(view,function ( self )
	self.m_winSize  = cc.Director : getInstance() : getVisibleSize()
	self.m_mainSize = cc.size(848,516)
	self.rankSize   = cc.size(159,433)
	self.pageFlag   = 0
	self.isLeftRight= false
end)

local RT_TAG              = 1001
local OCCUPY_COUNT_TAG    = 1002
local PAGE_DATA_TAG       = 1003
--local COMBAT_UI_TAG       = 1004
--local LEFT_BUTTON_TAG     = 1005
--local RIGHT_BUTTON_TAG    = 1006
local PERSON_MSG_UI       = 1007
local PAGE_COUNT          = 1008
local isBuyTip   = false

function JingXiuView.create(self)
    self : __init()

    self.m_normalView = require("mod.general.NormalView")()
	self.m_rootLayer  = self.m_normalView:create()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)
	
	self  			  : __initView()
    local msg  		  = REQ_FUTU_REQUEST()
    _G.Network  	  : send(msg)

    return tempScene
end

function JingXiuView.__init(self)
    self : register()
end

function JingXiuView.register(self)
    self.pMediator = require("mod.smodule.JingXiuMediator")(self)
end
function JingXiuView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function JingXiuView.updateMainView( self,_msg )
	if self.allMsg then
		self.allMsg = nil
	end
	if self.m_floor~=_msg.floor or self.m_floor2~=_msg.floor2 then
		self.pageFlag=0
	end

	self.allMsg = _msg

	self.m_floor=_msg.floor
	self.m_floor2=_msg.floor2
	self : _updateMainView()
end

function JingXiuView._updateMainView(self)
	local _msg = self.allMsg
	local occupyCount   = self.m_bgView  : getChildByTag(OCCUPY_COUNT_TAG)
	occupyCount 		: setVisible(true)
	occupyCount         : setString(tostring(_msg.times))
	self.occupyCount    = _msg.buy_time
	local level = 1
	if _msg.floor2 == 0 then
		if _msg.floor%5 == 0 then
			level =_msg.floor/5
		else
			level = math.floor(_msg.floor/5)+1
		end
	else
		if _msg.floor2%5 == 0 then
			level =_msg.floor2/5
		else
			level = math.floor(_msg.floor2/5)+1
		end
	end
	
	if level == 0 then
		level = 1
	end

    if self.isLeftRight then
     	level = level + self.pageFlag

     	if level <1 or level > 20 then
     		return
     	end
    end 

    self.m_msgSize      = cc.size(770,340/3.0)
    print("当前占领层数："..tostring(_msg.floor2))
    print("当前占领位置："..tostring(_msg.pos))
    print("自己能打的最高层："..tostring(_msg.floor))
    self.maxFloor = _msg.floor

    self.pageCount : setString(string.format("%d/20",level))
    
    self.occupyFloor = _msg.floor2
    self.occupyPos   = _msg.pos
    
    if _msg.floor2 ~= 0 then
    	print("咦！是空值吗？")
    	local function local_scheduler()
         	self : __updateRemainingTime()
     	end
    	
    	if self.m_timeScheduler == nil then
    		self.m_timeScheduler = _G.Scheduler : schedule(local_scheduler, 1)
    	end
    else
    	if self.m_timeScheduler then
    		_G.Scheduler  : unschedule(self.m_timeScheduler)
    		self.m_timeScheduler = nil
    	end
    end
    
    self : __initScrollView(_msg,level)
    self.isLeftRight = false
end

function JingXiuView.updateRemainingTime( self,_time )
	print("时间刷新呢",_time)
	
	local remainingTime = self.m_bgView  : getChildByTag(RT_TAG)
	remainingTime       : setVisible(true)
	remainingTime 		: setString(self : __getTimeStr(_time))
	self.RemainingTime  = _G.TimeUtil : getServerTimeSeconds() + _time
end

function JingXiuView.__updateRemainingTime( self )
	if self.RemainingTime then
		local remainingTime = self.m_bgView  : getChildByTag(RT_TAG)
	    remainingTime 		: setString(self : __getTimeStr(self.RemainingTime - _G.TimeUtil : getServerTimeSeconds()))

	    if self.RemainingTime - _G.TimeUtil : getServerTimeSeconds() == 0 then
			self.RemainingTime = nil
			self.occupyTime = nil
		end
	end

	if self.occupyTime then
		self.occupyTimeLab : setString(self : __getTimeStr(_G.TimeUtil:getNowSeconds() - self.occupyTime))
	end
end

function JingXiuView.__getTimeStr( self,_time)
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

function JingXiuView.__initView(self)
    print("浮屠静修界面")

    local function nCloseFun()
		self : __closeWindow()
	end
	self.m_normalView : addCloseFun(nCloseFun)

	self.m_normalView : setTitle("浮屠静修")

	--local second_bg   = self.m_normalView : showSecondBg()
	local second_bg   = cc.Node:create()
	self.m_rootLayer  : addChild(second_bg)
	second_bg         : setPosition(cc.p(self.m_winSize.width/2-80,self.m_winSize.height/2-80))

	local dinSize=cc.size(846,510)
	local dins        = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	dins		      : setPreferredSize(dinSize)
	second_bg         : addChild(dins)
	dins              : setPosition(cc.p(80,35))
	
	-- local dins	  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
	-- dins		      : setPreferredSize(cc.size(self.m_mainSize.width - 30,self.m_mainSize.height - 75))
	-- dins 	      : setPosition(cc.p(80,80))
	-- second_bg         : addChild(dins,1)
	-- dins           : setOpacity(0)
	self.m_bgView     = dins

	local fontSize    = 20
	local upHeight    = dinSize.height - 40

    local downHeight  = -40

	local occupyDins  = ccui.Scale9Sprite : createWithSpriteFrameName("general_friendbg.png")
	occupyDins          : setPreferredSize(cc.size(dinSize.width,65))
	-- occupyDins        : setAnchorPoint(cc.p(0,0))
	-- occupyDins        : setScale(0.8,1)
	occupyDins 	      : setPosition(dinSize.width/2,33)
	dins  	 	  : addChild(occupyDins)

	local timeLab     = _G.Util : createLabel("剩余占领时间:", fontSize)
	-- timeLab 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
	timeLab           : setAnchorPoint(cc.p(0,0.5))
	timeLab 		  : setPosition(cc.p(20,31)) 
	dins           : addChild(timeLab)

	local timeDate    = _G.Util : createLabel("00:00:00", fontSize)
	timeDate 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	timeDate          : setAnchorPoint(cc.p(0,0.5))
	timeDate 		  : setPosition(cc.p(150,31))
	timeDate 		  : setVisible(false) 
	timeDate 		  : setTag(RT_TAG)
	dins  		  : addChild(timeDate)

	local occupyLab   = _G.Util : createLabel("占领次数:", fontSize)
	-- occupyLab 		  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
	-- occupyLab         : setAnchorPoint(cc.p(0,0))
	occupyLab 		  : setPosition(cc.p(dinSize.width - 150,31)) 
	dins  		  : addChild(occupyLab)

	local occupyCount = _G.Util : createLabel(tostring(10), fontSize)
	occupyCount 	  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	-- occupyCount       : setAnchorPoint(cc.p(0,0))
	occupyCount 	  : setPosition(cc.p(dinSize.width - 90,31)) 
	occupyCount 	  : setVisible(false)
	occupyCount 	  : setTag(OCCUPY_COUNT_TAG)
	dins  		  : addChild(occupyCount,1)

	local pageCount   = _G.Util : createLabel("1/20", fontSize)
	--pageCount 	      : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
	pageCount 	      : setPosition(cc.p(dinSize.width/2,31)) 
	dins  	      : addChild(pageCount,1)
	self.pageCount    = pageCount

	local pageDins 	  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
	pageDins          : setPreferredSize(cc.size(80,35))
	pageDins 	  	  : setPosition(cc.p(dinSize.width/2,31)) 
	dins  	 	  : addChild(pageDins)

	-- local leftBtn     = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
	-- leftBtn 	  	  : setPosition(cc.p(dinSize.width/2-60,31)) 
	-- dins  	 	  : addChild(leftBtn)
	-- self.leftBtn      = leftBtn

	-- local rightBtn    = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
	-- rightBtn          : setScale(-1)
	-- rightBtn 	  	  : setPosition(cc.p(dinSize.width/2+60,31)) 
	-- dins  	 	  : addChild(rightBtn)
	-- self.rightBtn     = rightBtn

    local function addEvent(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		print("增加次数===============>")
        	
    		if isBuyTip then
        		print("直接购买＝＝＝＝＝＝＝＝＝＝不弹出提示框")
        		local msg  = REQ_FUTU_TIMES_BUY()
    		    _G.Network : send(msg)
        	else
        		self : __initBuyLayer(1)	
        	end
    	end  
    end

    local addButton = gc.CButton : create("general_btn_add.png")
    local cBtnSize  = addButton : getContentSize()
    -- addButton       : setAnchorPoint(cc.p(0,0))
    addButton 		: setPosition(dinSize.width - 50,31)
    addButton 		: addTouchEventListener(addEvent)
    addButton 		: ignoreContentAdaptWithSize(false)
    addButton 		: setContentSize(cc.size(cBtnSize.width+30,cBtnSize.height+30))
    dins 		: addChild(addButton)

    local function combatEvent(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
    		print("战报===============>")
			self : __initCombatLayer()
    	end
    end

    local combatButton = gc.CButton : create("general_wrod_zb.png")
    combatButton 	   : setPosition(cc.p(dinSize.width/2 +150,31))
    combatButton 	   : addTouchEventListener(combatEvent)
    dins 		   : addChild(combatButton)

    local function explainEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("说明")
    		local explainView  = require("mod.general.ExplainView")()
			local explainLayer = explainView : create(30600)

			if self.m_guide_wait_touch then
				self.m_guide_wait_touch=nil
				_G.GGuideManager:removeCurGuideNode()

				local msg=REQ_FUTU_TASK_FINISH()
				_G.Network:send(msg)
			end
    	end
    end

    local explainButton = gc.CButton:create()
	explainButton : addTouchEventListener(explainEvent)
	explainButton : loadTextures("general_help.png")
	explainButton : setTitleText("")
	explainButton : setTitleFontSize(24)
	explainButton : setTitleFontName(_G.FontName.Heiti)
	explainButton : setPosition(cc.p(280,31))
	dins : addChild(explainButton)

	local guideId=_G.GGuideManager:getCurGuideId()
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_ZSYT then
    	_G.GGuideManager:initGuideView(self.m_rootLayer)
    	_G.GGuideManager:registGuideData(1,explainButton)
    	_G.GGuideManager:runNextStep()
    	self.m_guide_wait_touch=true
    	self.m_hasGuide=true
    end
end

function JingXiuView.__initScrollView( self ,_msg,_level)
	if self.pageView then
		self.pageView : removeFromParent()
		self.pageView = nil
	end

	local pageView = ccui.PageView:create()
	pageView : setContentSize(cc.size((self.rankSize.width+8)*5,self.rankSize.height+3))
	pageView : setAnchorPoint(cc.p(0,0))
	pageView : setPosition(5, 67)
	pageView : setCustomScrollThreshold(50)
	pageView : enableSound()
	self.m_bgView  : addChild(pageView)
	self.pageView = pageView

	print("levle:",_level)

	if _level == 1 then
		for pageCount=1,2 do
			local layout = ccui.Layout : create()
			layout : setContentSize(self.rankSize)

			local subView = ccui.Widget : create()
			subView : setContentSize(cc.size(self.m_mainSize.width - 30,self.m_mainSize.height - 82)) 
			subView : setAnchorPoint(cc.p(0,0))
			subView : setPosition(0, 0)
			layout  : addChild(subView)
			print("开始创建了哦1")
		    for i = 1,5 do
		    	local levelLab  = 0
		    	local id = (_level-1+(pageCount-1))*5+i
		    	if  _msg.msg_xxx[id] then
		    		levelLab = self : __createLab1(i,_msg.msg_xxx[id],_level+(pageCount-1),id)
		    	else
		    		print("_msg:",id)
		    		levelLab = self : __createLab(i,_G.Cfg.hero_tower[id],_level+(pageCount-1),id)
		    	end

		    	levelLab : setTag(id) 
		    	subView  : addChild(levelLab)
		    end
		    pageView : addPage(layout) 
		end

		pageView : scrollToPage(0)
		self.oldPage = 0
		-- self.leftBtn : setVisible(false)
	elseif _level == 20 then
		for pageCount=1,2 do
			local layout = ccui.Layout : create()
			layout : setContentSize(self.rankSize)

			local subView = ccui.Widget : create()
			subView : setContentSize(cc.size(self.m_mainSize.width - 30,self.m_mainSize.height - 82)) 
			subView : setAnchorPoint(cc.p(0,0))
			subView : setPosition(0, 0)
			layout  : addChild(subView)
			print("开始创建了哦2")
		    for i = 1,5 do
		    	local levelLab  = 0
		    	local id = (_level-1+(pageCount-2))*5+i
		    	if  _msg.msg_xxx[id] then
		    		levelLab = self : __createLab1(i,_msg.msg_xxx[id],_level+(pageCount-2),id)
		    	else
		    		print("_msg:",id)
		    		levelLab = self : __createLab(i,_G.Cfg.hero_tower[id],_level+(pageCount-2),id)
		    	end

		    	levelLab : setTag(id) 
		    	subView  : addChild(levelLab)
		    end
		    pageView : addPage(layout) 
		end

		pageView : scrollToPage(1)
		self.oldPage = 1
		-- self.rightBtn : setVisible(false)
	else
		for pageCount=1,3 do
			local layout = ccui.Layout : create()
			layout : setContentSize(self.rankSize)

			local subView = ccui.Widget : create()
			subView : setContentSize(cc.size(self.m_mainSize.width - 30,self.m_mainSize.height - 82)) 
			subView : setAnchorPoint(cc.p(0,0))
			subView : setPosition(0, 0)
			layout  : addChild(subView)
			print("开始创建了哦3")
		    for i = 1,5 do
		    	local levelLab  = 0
		    	local id = (_level-1+(pageCount-2))*5+i
		    	if  _msg.msg_xxx[id] then
		    		levelLab = self : __createLab1(i,_msg.msg_xxx[id],_level+(pageCount-2),id)
		    	else
		    		print("_msg:",id)
		    		levelLab = self : __createLab(i,_G.Cfg.hero_tower[id],_level+(pageCount-2),id)
		    	end

		    	levelLab : setTag(id) 
		    	subView  : addChild(levelLab)
		    end
		    pageView : addPage(layout) 
		end

		pageView : scrollToPage(1)
		self.oldPage = 1
		-- self.leftBtn : setVisible(true)
		-- self.rightBtn : setVisible(true)
	end

	

	local function pageViewEvent(sender, eventType)
      	if eventType == ccui.PageViewEventType.turning then
          	local pageView       = sender
          	local m_nowPageCount = pageView : getCurPageIndex()
          	print("翻页", m_nowPageCount,"页数",pageView : getChildrenCount())
          	print(m_nowPageCount - self.oldPage)
          	if m_nowPageCount - self.oldPage == 0 then
          		
          	elseif m_nowPageCount - self.oldPage == 1 then
          		self.isLeftRight = true
	    		self.pageFlag    = self.pageFlag + 1

				local msg  		  = REQ_FUTU_REQUEST()
				_G.Network  	  : send(msg)
				if self.pageCount then
					self.pageCount : setString(string.format("%d/20",_level+1))
				end
				-- if _level+1 == 20 then
				-- 	self.rightBtn : setVisible(false)
				-- end
          	elseif m_nowPageCount - self.oldPage == -1 then
          		self.isLeftRight = true
	        	self.pageFlag    = self.pageFlag - 1

				local msg  		  = REQ_FUTU_REQUEST()
	    		_G.Network  	  : send(msg)

	    		if self.pageCount then
					self.pageCount : setString(string.format("%d/20",_level-1))
				end
				-- if _level-1 == 1 then
					-- self.leftBtn : setVisible(false)
				-- end
          	end
			self.oldPage = m_nowPageCount
      	end
  	end
  pageView : addEventListener(pageViewEvent)
end

function JingXiuView.__createLab( self,i,_msg,_level,floor)
	print("__createLab      ",i)
	local labSize=cc.size((self.m_mainSize.width - 30 - 40)/5,self.m_mainSize.height - 80)
	local levelLab = ccui.Widget : create()
	levelLab       : setContentSize(labSize) 
	levelLab       : setAnchorPoint(cc.p(0,0))
	levelLab       : setPosition((i-1)*(self.rankSize.width+8)+4,0)

	local levelBG   = ccui.Scale9Sprite : createWithSpriteFrameName("general_rolekuang.png")
	levelBG         : setPreferredSize(self.rankSize)
    levelBG         : setAnchorPoint( cc.p(0,0) )
    levelBG         : setPosition(cc.p(0,0))
    levelLab        : addChild(levelBG,0)

    local fontSize   = 20

    local floorLevel = _G.Util : createLabel("第".._G.Lang.number_Chinese[_level].."层,", fontSize)
	floorLevel 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
	floorLevel       : setDimensions(110,floorLevel : getContentSize().height)
	floorLevel       : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	floorLevel 	   	 : setAnchorPoint( cc.p(0,1) )
	floorLevel 	   	 : setPosition(cc.p(0,labSize.height-30))
	levelLab         : addChild(floorLevel,1)

	local floorLevel1= _G.Util : createLabel("第"..tostring(i).."关", fontSize)
	floorLevel1 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
	floorLevel1      : setDimensions(230,floorLevel1 : getContentSize().height)
	floorLevel1      : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	floorLevel1 	 : setAnchorPoint( cc.p(0,1) )
	floorLevel1 	 : setPosition(cc.p(0,labSize.height-30))
	levelLab         : addChild(floorLevel1,1)

	local lab        = _G.Util : createLabel("每30分钟奖励", fontSize)
	-- lab 	   	     : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PALEGREEN))
	lab 	   	     : setAnchorPoint( cc.p(0,0) )
	lab 	   	     : setPosition(cc.p(25,55))
	levelLab         : addChild(lab,1)

	if i == 5 then
		local reward     = _G.Util : createLabel(_G.Cfg.goods[_msg.goods2_id].name..":", fontSize)
		-- reward 	   	 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
		-- reward       	 : setDimensions(160,floorLevel : getContentSize().height)
		reward 	   	 	 : setAnchorPoint( cc.p(0,0.5) )
		reward 	   		 : setPosition(cc.p(25,42))
		levelLab         : addChild(reward,1)

		local rewardcount= _G.Util : createLabel(_msg.count2, fontSize)
		rewardcount 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		-- rewardcount      : setDimensions(165,floorLevel : getContentSize().height)
		rewardcount 	 : setAnchorPoint( cc.p(0,0.5) )
		rewardcount 	 : setPosition(cc.p(25+reward:getContentSize().width,42))
		levelLab         : addChild(rewardcount,1) 

		local reward1    = _G.Util : createLabel(_G.Cfg.goods[_msg.goods_id].name..":", fontSize)
		-- reward1 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
		-- reward1       	 : setDimensions(160,floorLevel : getContentSize().height)
		reward1 	   	 : setAnchorPoint( cc.p(0,0.5) )
		reward1 	   	 : setPosition(cc.p(25,19))
		levelLab         : addChild(reward1,1)

		local reward1count= _G.Util : createLabel(_msg.count, fontSize)
		reward1count 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		-- reward1count    : setDimensions(160,floorLevel : getContentSize().height)
		reward1count 	 : setAnchorPoint( cc.p(0,0.5) )
		reward1count 	 : setPosition(cc.p(25+reward1:getContentSize().width,19))
		levelLab         : addChild(reward1count,1)

		local m_goodbtn  = gc.CButton : create()
    	m_goodbtn  : loadTextures("ui_jingxiu_unknown.png")
    	m_goodbtn  : setButtonScale(0.80)
    	local function l_btnCallBack(sender, eventType)
    		if eventType == ccui.TouchEventType.ended then
    			print("占领层数：",floor)
    			self : __initOccupyTipsBox(floor,0)
    		end
    	end
    	
    	m_goodbtn  : setSwallowTouches(false)
    	m_goodbtn  : addTouchEventListener(l_btnCallBack)
    	m_goodbtn  : setAnchorPoint(cc.p(0,0.5))
    	m_goodbtn  : setPosition(cc.p(50,labSize.height - 200))
    	levelLab   : addChild(m_goodbtn,1)

    	local name   = _G.Util : createLabel("", fontSize)
	    name 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	    name       	 : setDimensions(130,floorLevel : getContentSize().height)
	    name         : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	    name 	   	 : setPosition(cc.p(levelLab:getContentSize().width/2+4,labSize.height - 205))
	    levelLab     : addChild(name,2)
	else
		
		local reward     = _G.Util : createLabel(_G.Cfg.goods[_msg.goods2_id].name..":", fontSize)
		-- reward 	   	 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
		-- reward       	 : setDimensions(160,floorLevel : getContentSize().height)
		reward 	   	 	 : setAnchorPoint( cc.p(0,0.5) )
		reward 	   		 : setPosition(cc.p(25,30))
		levelLab         : addChild(reward,1)

		local rewardcount= _G.Util : createLabel(_msg.count2, fontSize)
		rewardcount 	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		-- rewardcount     : setDimensions(160,floorLevel : getContentSize().height)
		rewardcount 	 : setAnchorPoint( cc.p(0,0.5) )
		rewardcount 	 : setPosition(cc.p(25+reward:getContentSize().width,30))
		levelLab         : addChild(rewardcount,1)
	
		for i=1,_msg.pos do
			print(i)
			local m_goodbtn  = gc.CButton : create()
	    	m_goodbtn  : loadTextures("ui_jingxiu_unknown.png")
	    	m_goodbtn  : setButtonScale(0.80)
	    	local function l_btnCallBack(sender, eventType)
	    		if eventType == ccui.TouchEventType.ended then
	    			print("占领层数： ",floor," 位置：",i-1,"可占领最高层：",self.maxFloor)
	    			if self.maxFloor >= floor then
	    				self : __initOccupyTipsBox(floor,i-1)
	    			else
	    				self : errorReturn()
	    			end
	    		end
	    	end
	    	
	    	m_goodbtn  : setSwallowTouches(false)
	    	m_goodbtn  : addTouchEventListener(l_btnCallBack)
	    	m_goodbtn  : setAnchorPoint(cc.p(0,0.5))
	    	if _msg.pos < 3 then
	    		m_goodbtn  : setPosition(cc.p(50,labSize.height - 135 - (i - 1)*(99+30)))
	    	else
	    		m_goodbtn  : setPosition(cc.p(50,labSize.height - 100 - (i - 1)*(99)))
	    	end
	    	
	    	levelLab   : addChild(m_goodbtn,1)

	    	local name   = _G.Util : createLabel("", fontSize)
		    --name 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
		    name       	 : setDimensions(130,floorLevel : getContentSize().height)
		    name         : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		    if _msg.pos < 3 then
	    		name  : setPosition(cc.p(levelLab:getContentSize().width/2+4,labSize.height - 140 - (i - 1)*(99+30)))
	    	else
	    		name  : setPosition(cc.p(levelLab:getContentSize().width/2+4,labSize.height - 110 - (i - 1)*(99)))
	    	end
		    levelLab     : addChild(name,2)
		end
	end
    return levelLab
end

function JingXiuView.__createLab1( self,i,_msg,_level,floor)
	--table.sort(_msg.msg_xxx2,function(a,b) return a.pos<b.pos end )
	local labSize=cc.size((self.m_mainSize.width - 30 - 40)/5,self.m_mainSize.height - 80)
	local levelLab = ccui.Widget : create()
	levelLab       : setContentSize(labSize) 
	levelLab       : setAnchorPoint(cc.p(0,0))
	levelLab       : setPosition((i-1)*(self.rankSize.width+8)+4,0)

	local levelBG   = ccui.Scale9Sprite : createWithSpriteFrameName("general_rolekuang.png")
	levelBG         : setPreferredSize(self.rankSize)
    levelBG         : setAnchorPoint( cc.p(0,0) )
    levelBG         : setPosition(cc.p(0,0))
    levelLab        : addChild(levelBG,0)

    local fontSize   = 20

    local floorLevel = _G.Util : createLabel("第".._G.Lang.number_Chinese[_level].."层,", fontSize)
	-- floorLevel 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PALEGREEN))
	floorLevel       : setDimensions(110,floorLevel : getContentSize().height)
	floorLevel       : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	floorLevel 	   	 : setAnchorPoint( cc.p(0,1) )
	floorLevel 	   	 : setPosition(cc.p(0,labSize.height-30))
	levelLab         : addChild(floorLevel,1)

	local floorLevel1= _G.Util : createLabel("第"..tostring(i).."关", fontSize)
	floorLevel1 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
	floorLevel1      : setDimensions(230,floorLevel1 : getContentSize().height)
	floorLevel1      : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	floorLevel1 	 : setAnchorPoint( cc.p(0,1) )
	floorLevel1 	 : setPosition(cc.p(0,labSize.height-30))
	levelLab         : addChild(floorLevel1,1)

	local lab        = _G.Util : createLabel("每30分钟奖励", fontSize)
	-- lab 	   	     : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PALEGREEN))
	lab 	   	     : setAnchorPoint( cc.p(0,0) )
	lab 	   	     : setPosition(cc.p(25,55))
	levelLab         : addChild(lab,1)

	if i == 5 then
		local reward     = _G.Util : createLabel(_G.Cfg.goods[_G.Cfg.hero_tower[floor].goods2_id].name..":", fontSize)
		-- reward 	   	 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
		-- reward       	 : setDimensions(160,floorLevel : getContentSize().height)
		reward 	   	 	 : setAnchorPoint( cc.p(0,0.5) )
		reward 	   		 : setPosition(cc.p(25,42))
		levelLab         : addChild(reward,1)

		local rewardcount= _G.Util : createLabel(_G.Cfg.hero_tower[floor].count2, fontSize)
		rewardcount 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		-- rewardcount      : setDimensions(165,floorLevel : getContentSize().height)
		rewardcount 	 : setAnchorPoint( cc.p(0,0.5) )
		rewardcount 	 : setPosition(cc.p(25+reward:getContentSize().width,42))
		levelLab         : addChild(rewardcount,1) 

		local reward1    = _G.Util : createLabel(_G.Cfg.goods[_G.Cfg.hero_tower[floor].goods_id].name..":", fontSize)
		-- reward1 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
		-- reward1       	 : setDimensions(160,floorLevel : getContentSize().height)
		reward1 	   	 : setAnchorPoint( cc.p(0,0.5) )
		reward1 	   	 : setPosition(cc.p(25,19))
		levelLab         : addChild(reward1,1)

		local reward1count= _G.Util : createLabel(_G.Cfg.hero_tower[floor].count, fontSize)
		reward1count 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		-- reward1count    : setDimensions(160,floorLevel : getContentSize().height)
		reward1count 	 : setAnchorPoint( cc.p(0,0.5) )
		reward1count 	 : setPosition(cc.p(25+reward1:getContentSize().width,19))
		levelLab         : addChild(reward1count,1)

		local m_goodbtn  = gc.CButton : create()
    	if _msg.msg_xxx2[1] then
			m_goodbtn  : loadTextures(string.format("general_role_head%d.png",_msg.msg_xxx2[1].pro))
		else
			m_goodbtn  : loadTextures("ui_jingxiu_unknown.png")
		end
    	m_goodbtn  : setButtonScale(0.80)
    	local function l_btnCallBack(sender, eventType)
    		if eventType == ccui.TouchEventType.ended then
    			print("点击了一下人物头像1 ",floor)
    			if _msg.msg_xxx2[1] then
					if self.occupyFloor == _msg.floor and self.occupyPos == _msg.msg_xxx2[1].pos then
						self.isMe = true
					else
						self.isMe = false
					end
					local msg = REQ_FUTU_PLAYER_REQ()
					print("floor:",floor)
					print("pos:",0)
					print("uid:",_msg.msg_xxx2[1].uid)
					msg       : setArgs(floor,0,_msg.msg_xxx2[1].uid)
					_G.Network: send(msg)
				else
					self : __initOccupyTipsBox(floor,0)
				end
    		end
    	end
    	
    	m_goodbtn  : setSwallowTouches(false)
    	m_goodbtn  : addTouchEventListener(l_btnCallBack)
    	m_goodbtn  : setAnchorPoint(cc.p(0,0.5))
    	m_goodbtn  : setPosition(cc.p(50,labSize.height - 200))
    	levelLab   : addChild(m_goodbtn,1)

    	if _msg.msg_xxx2[1] then
			name   = _G.Util : createLabel(_msg.msg_xxx2[1].name, fontSize)
		else
			name   = _G.Util : createLabel("", fontSize)
		end
	    name 	   	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	    name       	 : setDimensions(130,floorLevel : getContentSize().height)
	    name         : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	    name 	   	 : setPosition(cc.p(levelLab:getContentSize().width/2+4,labSize.height - 247))
	    levelLab     : addChild(name,2)
	else
		local reward     = _G.Util : createLabel(_G.Cfg.goods[_G.Cfg.hero_tower[floor].goods2_id].name..":", fontSize)
		-- reward 	   	 	 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
		-- reward       	 : setDimensions(160,floorLevel : getContentSize().height)
		reward 	   	 	 : setAnchorPoint( cc.p(0,0.5) )
		reward 	   		 : setPosition(cc.p(25,30))
		levelLab         : addChild(reward,1)

		local rewardcount= _G.Util : createLabel(_G.Cfg.hero_tower[floor].count2, fontSize)
		rewardcount 	   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
		-- rewardcount     : setDimensions(160,floorLevel : getContentSize().height)
		rewardcount 	 : setAnchorPoint( cc.p(0,0.5) )
		rewardcount 	 : setPosition(cc.p(25+reward:getContentSize().width,30))
		levelLab         : addChild(rewardcount,1)


		for i=1,_G.Cfg.hero_tower[floor].pos do
			local m_goodbtn  = gc.CButton : create()

			if _msg.msg_xxx2[i] then
				m_goodbtn  : loadTextures(string.format("general_role_head%d.png",_msg.msg_xxx2[i].pro))
			else
				m_goodbtn  : loadTextures("ui_jingxiu_unknown.png")
			end
	    	m_goodbtn  : setButtonScale(0.80)
	    	local function l_btnCallBack(sender, eventType)
	    		if eventType == ccui.TouchEventType.ended then
	    			print("点击了一下人物头像2  ",floor," ",i-1)
	    			if _msg.msg_xxx2[i] then
						if self.occupyFloor == _msg.floor and self.occupyPos == _msg.msg_xxx2[i].pos then
							self.isMe = true
						else
							self.isMe = false
						end
						local msg = REQ_FUTU_PLAYER_REQ()
						print(floor)
						print(_msg.msg_xxx2[i].pos)
						print(_msg.msg_xxx2[i].uid)
						msg       : setArgs(floor,_msg.msg_xxx2[i].pos,_msg.msg_xxx2[i].uid)
						_G.Network: send(msg)
					else
						self : __initOccupyTipsBox(floor,i-1)
					end
	    		end
	    	end
	    	
	    	m_goodbtn  : setSwallowTouches(false)
	    	m_goodbtn  : addTouchEventListener(l_btnCallBack)
	    	m_goodbtn  : setAnchorPoint(cc.p(0,0.5))
	    	if _G.Cfg.hero_tower[floor].pos < 3 then
	    		m_goodbtn  : setPosition(cc.p(50,labSize.height - 135 - (i - 1)*(99+30)))
	    	else
	    		m_goodbtn  : setPosition(cc.p(50,labSize.height - 100 - (i - 1)*(99)))
	    	end
	    	
	    	levelLab   : addChild(m_goodbtn,1)

	    	local name   = 0

    		if _msg.msg_xxx2[i] then
				name   = _G.Util : createLabel(_msg.msg_xxx2[i].name, fontSize)
			else
				name   = _G.Util : createLabel("", fontSize)
    		end
		    name       	 : setDimensions(130,floorLevel : getContentSize().height)
		    name         : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		    if _G.Cfg.hero_tower[floor].pos < 3 then
		    	name  : setPosition(cc.p(levelLab:getContentSize().width/2+4,labSize.height - 182 - (i - 1)*(99+30)))
	    	else
	    		name  : setPosition(cc.p(levelLab:getContentSize().width/2+4,labSize.height - 147 - (i - 1)*(99)))
	    	end
		    levelLab     : addChild(name,2)
		end
	end
    return levelLab
end

function JingXiuView.updateFloor( self,_msg )
	self.container : getChildByTag(_msg.floor) : removeFromParent()
	local levelLab  = 0
	if _msg.floor%5 == 0 then
		levelLab = self : __createLab1(5,_msg,_msg.floor/5,_msg.floor)
	else
		levelLab = self : __createLab1(_msg.floor%5,_msg,math.floor(_msg.floor/5)+1,_msg.floor)
	end
    
    levelLab : setTag(_msg.floor) 
    self.container  : addChild(levelLab)
end

function JingXiuView.__initOccupyTipsBox( self,_floor,_pos)
	print("初始化占领提示界面")

	local function sure()
		local msg = REQ_FUTU_START()
		msg       : setArgs(_floor,_pos,0)
		_G.Network: send(msg)
    end

    local function cancel( ... )
    	print("取消")
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
    local lab   = _G.Util : createLabel("是否占领此位置?",20)
    lab         : setPosition(cc.p(0,25))
    layer       : addChild(lab)
end

function JingXiuView.initPersonMsg( self,_msg )
	local size = cc.Director : getInstance() : getWinSize()

    local function onTouchBegan()
    	print("删除人物信息界面")
    	cc.Director : getInstance() : getRunningScene() : runAction(cc.Sequence : create(cc.DelayTime : create(0.05),cc.CallFunc : create(function (  )
    		cc.Director : getInstance() : getRunningScene() : getChildByTag(PERSON_MSG_UI) : removeFromParent()
    		print("成功删除背景")
    		if self.occupyTime then
    			self.occupyTime = nil
    		end
    	end)))
		return true 
	end
	local listerner = cc.EventListenerTouchOneByOne : create()
	listerner 	    : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner 		: setSwallowTouches(true)

	local moilLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))
	moilLayer 	    : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, moilLayer)
	-- moilLayer 	    : setPosition(cc.p(size.width/2, size.height/2))
	moilLayer 	    : setTag(PERSON_MSG_UI)
	cc.Director 	: getInstance() : getRunningScene() : addChild(moilLayer,888)
	self : __initPersonLayer(_msg)
end

function JingXiuView.__initPersonLayer( self,_msg )
	print("初始化人物信息界面")
	local m_layer = cc.Director : getInstance() : getRunningScene() : getChildByTag(PERSON_MSG_UI)

	local function bgEvent(  )
		return true
	end
	local m_bgSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	m_bgSpr	  	  : setPreferredSize(cc.size(335,300))
	m_bgSpr 	  : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	m_layer  	  : addChild(m_bgSpr,2)

	local label   = ccui.Widget:create()
	label         : setContentSize( cc.size(335,300) )
	label 		  : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	label         : setTouchEnabled(true)
	label         : addTouchEventListener(bgEvent)
	m_layer 	  : addChild(label,3)

	local di2kuanSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	di2kuanSpr	  	  : setPreferredSize(cc.size(312,217))
	di2kuanSpr 	  : setPosition(cc.p(335/2,180))
	label  	  : addChild(di2kuanSpr)

	local icon   = cc.Sprite : createWithSpriteFrameName(string.format("general_role_head%d.png",_msg.pro))
	icon         : setAnchorPoint(cc.p(0,0.5))
	icon         : setScale(0.85)
	icon         : setPosition(cc.p(40,230))
	label        : addChild(icon,0)

	local name   = _G.Util : createLabel(_msg.name,20)
	name         : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	name         : setAnchorPoint(cc.p(0,0.5))
	name         : setPosition(cc.p(140,260))
	label        : addChild(name)

	local power  = _G.Util : createLabel("战力: ",20)
	-- power        : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	power        : setAnchorPoint(cc.p(0,0.5))
	power        : setPosition(cc.p(140,230))
	label        : addChild(power)

	local powerData  = _G.Util : createLabel(_msg.powerful,20)
	powerData        : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	powerData        : setAnchorPoint(cc.p(0,0.5))
	powerData        : setPosition(cc.p(205,230))
	label            : addChild(powerData)

	local faction= _G.Util : createLabel("门派: ",20)
	-- faction      : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	faction      : setAnchorPoint(cc.p(0,0.5))
	faction      : setPosition(cc.p(140,200))
	label        : addChild(faction)

	local factionData= _G.Util : createLabel(_msg.clan_name or "暂无门派",20)
	factionData      : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	factionData      : setAnchorPoint(cc.p(0,0.5))
	factionData      : setPosition(cc.p(205,200))
	label            : addChild(factionData)

	-- local line  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    -- local lineSprSize = line : getPreferredSize()
    -- line 		: setPreferredSize( cc.size(280, lineSprSize.height) )
    -- line 	    : setPosition(cc.p(160,180))
    -- label       : addChild(line,0)

    if not self.occupytime then
    	self.occupyTime  = _msg.time
    end

   	local occupyTime = _G.Util : createLabel("占领时间: ",20)
   	-- occupyTime       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	occupyTime       : setAnchorPoint(cc.p(0,0.5))
	occupyTime       : setPosition(cc.p(50,160))
	label            : addChild(occupyTime)

	-- local pageDins 	  = ccui.Scale9Sprite : createWithSpriteFrameName("general_input_box.png")
	-- pageDins          : setPreferredSize(cc.size(110,25))
	-- pageDins          : setAnchorPoint(cc.p(0,0.5))
	-- pageDins          : setPosition(cc.p(148,153))
	-- label  	 	      : addChild(pageDins)

	print("time1:",_G.TimeUtil:getNowSeconds())
	print("time2:",self.occupyTime)
	print("time3:",_G.TimeUtil:getNowSeconds()-self.occupyTime)

	local occupyTime1 = _G.Util : createLabel(self : __getTimeStr(_G.TimeUtil:getNowSeconds() - self.occupyTime),20)
	occupyTime1       : setAnchorPoint(cc.p(0,0.5))
	occupyTime1       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	occupyTime1       : setPosition(cc.p(152,160))
	label             : addChild(occupyTime1,1)
	self.occupyTimeLab = occupyTime1

	-- local pageDins1   = ccui.Scale9Sprite : createWithSpriteFrameName("general_input_box.png")
	-- pageDins1         : setPreferredSize(cc.size(110,25))
	-- pageDins1         : setAnchorPoint(cc.p(0,0.5))
	-- pageDins1         : setPosition(cc.p(148,122))
	-- label  	 	      : addChild(pageDins1)

	local time = _G.TimeUtil:getNowSeconds() - _msg.time
	local goods      = _G.Util : createLabel("奖励".._G.Cfg.goods[_G.Cfg.hero_tower[_msg.floor].goods2_id].name..":",20)
	goods            : setAnchorPoint(cc.p(0,0.5))
	-- goods            : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	goods            : setPosition(cc.p(50,130))
	label            : addChild(goods,1)

	local goods1      = _G.Util : createLabel(_G.Cfg.hero_tower[_msg.floor].count2*math.floor(time/1800),20)
	goods1            : setAnchorPoint(cc.p(0,0.5))
	goods1            : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	goods1            : setPosition(cc.p(50+goods:getContentSize().width+15,130))
	label             : addChild(goods1,1)

	if _msg.floor%5 == 0 then
		-- local pageDins 	  = ccui.Scale9Sprite : createWithSpriteFrameName("general_input_box.png")
		-- pageDins          : setPreferredSize(cc.size(50,25))
		-- pageDins          : setAnchorPoint(cc.p(0,0.5))
		-- pageDins          : setPosition(cc.p(207,92))
		-- label  	 	      : addChild(pageDins)

		local goods1 = _G.Util : createLabel("奖励".._G.Cfg.goods[_G.Cfg.hero_tower[_msg.floor].goods_id].name..":",20)
		goods1       : setAnchorPoint(cc.p(0,0.5))
		-- goods1       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		goods1       : setPosition(cc.p(50,100))
		label        : addChild(goods1,1)

		local goods = _G.Util : createLabel(_G.Cfg.hero_tower[_msg.floor].count*math.floor(time/1800),20)
		goods       : setAnchorPoint(cc.p(0,0.5))
		goods       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
		goods       : setPosition(cc.p(50+goods1:getContentSize().width+15,100))
		label        : addChild(goods,1)
	end

    -- local line1  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    -- local lineSprSize = line1 : getPreferredSize()
    -- line1 		: setPreferredSize( cc.size(280, lineSprSize.height) )
    -- line1 	    : setPosition(cc.p(160,70))
    -- label       : addChild(line1,0)

    local function snatchEvent( sender,eventType )
	    if eventType == ccui.TouchEventType.ended  then
	    	if self.isMe then
				local msg = REQ_FUTU_OUT()
				msg       : setArgs(_msg.floor,_msg.pos)
				_G.Network: send(msg)
			else
				_G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_JJC_HERO_TOWER_ID)
				local msg = REQ_FUTU_START()
				msg       : setArgs(_msg.floor,_msg.pos,1)
				_G.Network: send(msg)
			end
			cc.Director : getInstance() : getRunningScene() : getChildByTag(PERSON_MSG_UI) : removeFromParent()
	    end
	end

    local Button   = gc.CButton:create()
	Button         : loadTextures("general_btn_gold.png")
	if self.isMe then
		Button : setTitleText("离 开")
	else
		Button : setTitleText("抢 占")
	end
	Button         : addTouchEventListener(snatchEvent)
	Button         : setTitleFontSize(24)
	Button         : setTitleFontName(_G.FontName.Heiti)
	-- Button         : setButtonScale(0.8)
	Button         : setPosition(cc.p(160,36))
	label          : addChild(Button)
end

--初始化战报UI
function JingXiuView.__initCombatLayer( self )
	print("初始化战报UI")
	local combatView  = require("mod.general.BattleMsgView")()
	self.combatBG = combatView : create()

	self._mainSize = combatView : getSize()
	self : __combatNetWorkSend()
end

function JingXiuView.__combatNetWorkSend( self )
	print("发送战报协议")
	local msg  = REQ_FUTU_HISTORY_REQ()
    _G.Network : send(msg)
end

function JingXiuView.updateCombatMsg( self ,_msg)
	print("战报信息已经收到",_msg.count)
	if _msg.count < 1 then
		print(_msg.count)
		self.monkeySpr = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
		self.monkeySpr : setPosition(self._mainSize.width/2,self._mainSize.height/2+30)
		self.combatBG : addChild(self.monkeySpr)

		local monkeySize=self.monkeySpr:getContentSize()
		self.nomsgLab = _G.Util : createLabel("暂无战报", 20)
		-- self.nomsgLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
		self.nomsgLab : setPosition(monkeySize.width/2,-10)
		self.monkeySpr : addChild(self.nomsgLab)
		return
	end
	if self.monkeySpr~=nil then
		self.monkeySpr:removeFromParent(true)
		self.monkeySpr=nil

		self.nomsgLab:removeFromParent(true)
		self.nomsgLab=nil
	end

	self._combatMsgSize = cc.size(self._mainSize.width,self._mainSize.height/6)
	self 				: __combatScrollView(_msg)
end

function JingXiuView.__combatScrollView( self ,_msg)
	print("初始化滚动框")

	local Sc_Container = cc.Node : create()
    local ScrollView  = cc.ScrollView : create()
    local count 	  = 6
    if _msg.count >6 then
    	count = _msg.count
    end
   
    local viewSize     = cc.size(self._combatMsgSize.width,self._combatMsgSize.height*6)
	
    self.containerSize = cc.size(self._combatMsgSize.width, self._combatMsgSize.height*count)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(self.containerSize)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-self.containerSize.height))
    ScrollView      : setPosition(cc.p(10, -21))
    print("容器大小：", self._combatMsgSize.height*count)
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    Sc_Container    : addChild(ScrollView)
    Sc_Container    : setPosition(cc.p(0,27))
    self.combatBG   : addChild(Sc_Container)

    local barView = require("mod.general.ScrollBar")(ScrollView)
    -- barView 	  : setPosOff(cc.p(0,0))

    for i=1,_msg.count do
    	print("type ",_msg.msg_xxx[_msg.count-i+1].type,"  ","name:",_msg.msg_xxx[_msg.count-i+1].name,"  ","flag:",_msg.msg_xxx[_msg.count-i+1].flag)
    	local combatLab =  self : __createCombatLabel(i,_msg.msg_xxx[_msg.count-i+1])
    	ScrollView 		: addChild(combatLab)
    end
end

function JingXiuView.__createCombatLabel( self,i,_msg )
	local combatLab = ccui.Widget : create()
    combatLab       : setContentSize( self._combatMsgSize )
    combatLab       : setAnchorPoint( cc.p(0.0,0.5) )
    combatLab       : setPosition(cc.p(0, self.containerSize.height - (i-1)*self._combatMsgSize.height - self._combatMsgSize.height/2))

    local fontSize  = 20
    local offset    = 2

    local time 		= _G.Util : createLabel(self : __combatTime(_msg.time), fontSize)
    -- time 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    time 	   		: setAnchorPoint( cc.p(0.0,0.5) )
    time 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
    combatLab       : addChild(time)
    offset 			= offset + time : getContentSize().width

    if     _msg.type == 1 then
    	local lab1 = _G.Util : createLabel("你",20)
    	-- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab1)
	    offset 			= offset + lab1 : getContentSize().width

	    local text1 = _G.Util : createLabel("成功",20)
    	text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	    text1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text1)
	    offset 			= offset + text1 : getContentSize().width

	    local text2 = _G.Util : createLabel("占领了",20)
    	-- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    text2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text2)
	    offset 			= offset + text2 : getContentSize().width

	    local lab2     = _G.Util : createLabel("第".._G.Lang.number_Chinese[math.floor(_msg.floor/5)+1].."层•第"..tostring(_msg.floor%5).."关",20)
	    if _msg.floor%5 == 0 then
	    	lab2        : setString("第".._G.Lang.number_Chinese[_msg.floor/5].."层•第5关")
	    end
    	-- lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab2)
    elseif _msg.type == 2 then
    	local lab1 = _G.Util : createLabel(_msg.name,20)
    	lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LABELBLUE))
	    lab1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab1)
	    offset 			= offset + lab1 : getContentSize().width

	    local lab2 = _G.Util : createLabel("击败",20)
    	lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	    lab2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab2)
	    offset 			= offset + lab2 : getContentSize().width

	    local text = _G.Util : createLabel("了你,抢占了",20)
    	-- text 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    text 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text)
	    offset 			= offset + text : getContentSize().width

	    local lab3     = _G.Util : createLabel("第".._G.Lang.number_Chinese[math.floor(_msg.floor/5)+1].."层•第"..tostring(_msg.floor%5).."关",20)
	    if _msg.floor%5 == 0 then
	    	lab3        : setString("第".._G.Lang.number_Chinese[_msg.floor/5].."层•第5关")
	    end
    	-- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab3 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab3 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab3)
    elseif _msg.type == 3 then
    	local lab1 = _G.Util : createLabel("你自行离开了",20)
    	-- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab1)
	    offset 			= offset + lab1 : getContentSize().width

	    local lab2     = _G.Util : createLabel("第".._G.Lang.number_Chinese[math.floor(_msg.floor/5)+1].."层•第"..tostring(_msg.floor%5).."关",20)
	    if _msg.floor%5 == 0 then
	    	lab2        : setString("第".._G.Lang.number_Chinese[_msg.floor/5].."层•第5关")
	    end
    	-- lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab2)
	    offset 			= offset + lab2 : getContentSize().width

	    local lab3 = _G.Util : createLabel(",收益减半。",20)
    	-- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab3 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab3 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab3)
    elseif _msg.type == 4 or  _msg.type == 6 then
    	local lab1 = _G.Util : createLabel("你",20)
    	-- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab1)
	    offset 			= offset + lab1 : getContentSize().width

	    local text1 = _G.Util : createLabel("成功",20)
    	text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	    text1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text1)
	    offset 			= offset + text1 : getContentSize().width

	    local text2 = _G.Util : createLabel("占领了",20)
    	-- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    text2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text2)
	    offset 			= offset + text2 : getContentSize().width

	    local lab2     = _G.Util : createLabel("第".._G.Lang.number_Chinese[math.floor(_msg.floor/5)+1].."层•第"..tostring(_msg.floor%5).."关"..tostring(math.floor(_msg.time2/3600)).."小时",20)
	    if _msg.floor%5 == 0 then
	    	lab2        : setString("第".._G.Lang.number_Chinese[_msg.floor/5].."层•第5关"..tostring(math.floor(_msg.time2/3600)).."小时")
	    end
    	-- lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab2)
	    offset 			= offset + lab2 : getContentSize().width

	    local lab3 = _G.Util : createLabel(",获得了全额奖励。",20)
    	-- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab3 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab3 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab3)
	elseif _msg.type == 7 then
		local lab1 = _G.Util : createLabel("你抢占",20)
    	-- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab1)
	    offset 			= offset + lab1 : getContentSize().width

	    local lab2 = _G.Util : createLabel(_msg.name,20)
    	lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LABELBLUE))
	    lab2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab2)
	    offset 			= offset + lab2 : getContentSize().width

	    local lab3     = _G.Util : createLabel("的第".._G.Lang.number_Chinese[math.floor(_msg.floor/5)+1].."层•第"..tostring(_msg.floor%5).."关",20)
	    if _msg.floor%5 == 0 then
	    	lab3        : setString("的第".._G.Lang.number_Chinese[_msg.floor/5].."层•第5关")
	    end
    	-- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab3 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab3 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab3)
	    offset 			= offset + lab3 : getContentSize().width

	    local text1 = _G.Util : createLabel("失败",20)
    	text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	    text1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text1)
	    offset 			= offset + text1 : getContentSize().width

	    local lab4 = _G.Util : createLabel("。",20)
    	-- lab4 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab4 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab4 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab4)
	elseif _msg.type == 8 then
		local lab1 = _G.Util : createLabel("你",20)
    	-- lab1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab1)
	    offset 			= offset + lab1 : getContentSize().width

	    local text1 = _G.Util : createLabel("成功",20)
    	text1 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	    text1 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text1 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text1)
	    offset 			= offset + text1 : getContentSize().width

	    local text2 = _G.Util : createLabel("击退",20)
    	-- text2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    text2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    text2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(text2)
	    offset 			= offset + text2 : getContentSize().width

	    local lab2 = _G.Util : createLabel(_msg.name,20)
    	lab2 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LABELBLUE))
	    lab2 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab2 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab2)
	    offset 			= offset + lab2 : getContentSize().width

	    local lab3     = _G.Util : createLabel("对第".._G.Lang.number_Chinese[math.floor(_msg.floor/5)+1].."层•第"..tostring(_msg.floor%5).."关的抢夺。",20)
	    if _msg.floor%5 == 0 then
	    	lab3        : setString("对第".._G.Lang.number_Chinese[_msg.floor/5].."层•第5关的抢夺。")
	    end
    	-- lab3 	   		: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	    lab3 	   		: setAnchorPoint( cc.p(0.0,0.5) )
	    lab3 	   		: setPosition(cc.p(offset,self._combatMsgSize.height/2))
	    combatLab       : addChild(lab3)
    end

    local lineBg 	= ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    local lineSprSize = lineBg : getPreferredSize()
    lineBg 			: setPreferredSize( cc.size(self.containerSize.width, lineSprSize.height) )
    lineBg 			: setAnchorPoint( cc.p(0.0,0.0) )
    lineBg 			: setPosition(cc.p(0, 0))
    combatLab 		: addChild(lineBg)

    return  combatLab
end

function JingXiuView.__combatTime( self,times)
	local nowTime     = _G.TimeUtil:getNowSeconds()
    local offlineTime = nowTime - times
    print(offlineTime)

    local times_str   = os.date("*t", times)
    local nowTime_str = os.date("*t", nowTime)
    print(times_str.day)
    print(nowTime_str.day)
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

function JingXiuView.updateCombatCount( self,_msg )
	local occupyCount  = self.m_bgView : getChildByTag(OCCUPY_COUNT_TAG)
	occupyCount        : setString(tostring(_msg.times))
	self.occupyCount = _msg.buy_time
end

function JingXiuView.__initBuyLayer( self,count )
	print("初始化竞技场购买界面")

	local function buy()
		print("购买挑战次数")
        local msg  = REQ_FUTU_TIMES_BUY()
    	_G.Network : send(msg)
    end

    local function cancel( ... )
    	print("取消")
    end

    local topLab    = "花费10元宝购买1次占领次数?"
    local centerLab = _G.Lang.LAB_N[940]
    local downLab   = _G.Lang.LAB_N[416]..": "
    local buyCount  = self.occupyCount
    local rightLab  = _G.Lang.LAB_N[106]

    local szSureBtn = _G.Lang.BTN_N[1]

    local view  = require("mod.general.TipsBox")()
    local tipsNode = view : create("",buy,cancel)
    -- tipsNode 		: setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(tipsNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("购买次数")
    if topLab ~= nil then
    	print("top=================>")
        local label =_G.Util : createLabel(topLab,20)
		label 		: setPosition(cc.p(0,60))
		layer 		: addChild(label,88)
    end
    if centerLab ~= nil then
    	print("center=============>")
        local label =_G.Util : createLabel(centerLab,18)
		label 		: setPosition(cc.p(0,30))
		layer 		: addChild(label,88)
    end
    if downLab ~= nil then
    	print("down================>")
        local label =_G.Util : createLabel(downLab,20)
		label 		: setPosition(cc.p(-7,-5))
		layer 		: addChild(label,88)

		local count = _G.Util : createLabel(tostring(buyCount),20)
		count       : setAnchorPoint(cc.p(0,0.5))
		count 		: setPosition(cc.p(-7+label:getContentSize().width/2,-5))
		layer 		: addChild(count,88)

		if buyCount>0 then
			count : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		else
			count : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		end
    end
    if rightLab then
    	print("right===========>")
    	local label =_G.Util : createLabel(rightLab,20)
		label 		: setPosition(cc.p(25,-50))
		layer 		: addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isBuyTip)
            if isBuyTip then
            	isBuyTip = false
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_ARENA,false)
            else
            	isBuyTip = true
            	_G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_ARENA,true)
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox 	     : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox 	     : setPosition(cc.p(-80,-51))
    checkbox 	     : setName("sdjfgksjdfklgj")
    checkbox 	     : addTouchEventListener(c)
    -- checkbox 	     : setAnchorPoint(cc.p(1,0.5))
    layer 			 : addChild(checkbox)
end

function JingXiuView.errorReturn(self)
	local _szMsg="该关卡未通关，前往挑战？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_TOWER) then return false end
		self : __closeWindow()
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_TOWER)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(37425) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(37425)
	end
end

function JingXiuView.__closeWindow( self )
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	_G.Scheduler         : unschedule(self.m_timeScheduler)
	self.m_timeScheduler = nil
	cc.Director:getInstance():popScene()
	self 			     : unregister()

	if self.m_hasGuide then
        local command=CGuideNoticShow()
        controller:sendCommand(command)
    end
end

return JingXiuView