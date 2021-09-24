local MiBaoBoxView=classGc(view,function(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_timeScheduler={}
end)

function MiBaoBoxView.create(self)
    self.m_normalView=require("mod.general.NormalView")()
	self.m_rootLayer=self.m_normalView:create()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)
	

    self.m_mediator=require("mod.smodule.MiBaoBoxMediator")(self)

	self:__initView()
	
    return tempScene
end

function MiBaoBoxView.__initView(self)
	local function nCloseFun()
		self : __closeWindow()
	end
	self.m_normalView : addCloseFun(nCloseFun)
	self.m_normalView : setTitle("秘宝探险")
	self.m_normalView : showSecondBg()

	local function explainEvent( sender,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		local nTag=sender:getTag()
    		local msg=REQ_MIBAO_ENTER()
            msg:setArgs(nTag)
            _G.Network:send(msg)
    	end
    end
    local mibaoNode=cc.Node:create()
    mibaoNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.m_rootLayer : addChild(mibaoNode)

	self.timeLab={}
	local Name={"初级秘宝","中级秘宝","高级秘宝"}
	local posX=nil
	for i=1,3 do
		posX=2+(i-2)*278
		local boxBg=cc.Sprite:create(string.format("ui/bg/box_no%d.png",i))
		boxBg:setPosition(posX,-37)
		mibaoNode : addChild(boxBg)

		-- local bosWidth=boxBg:getContentSize().width
		-- local boxBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
		-- boxBg:setContentSize(cc.size(bosWidth-10,100))
		-- boxBg:setOpacity(100)
		-- boxBg:setPosition(posX,380)
		-- mibaoNode : addChild(boxBg)
		
		local timetipsLab = _G.Util : createLabel(Name[i],30)
		timetipsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
		timetipsLab : setPosition(cc.p(posX,155))
		-- timetipsLab : setAnchorPoint(cc.p(0,0.5))
		mibaoNode : addChild(timetipsLab)

		local tempBtn = gc.CButton:create()
		tempBtn : addTouchEventListener(explainEvent)
		tempBtn : loadTextures("general_btn_gold.png")
		tempBtn : setTitleText("进  入")
		tempBtn : setTag(i)
		tempBtn : setTitleFontSize(24)
		tempBtn : setTitleFontName(_G.FontName.Heiti)
		tempBtn : setPosition(posX,-210)
		mibaoNode : addChild(tempBtn)
		-- self.boxBtn[i]=tempBtn

		self.timeLab[i] = _G.Util : createLabel("下波时间:00:00:00",20)
		-- self.timeLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.timeLab[i] : setPosition(posX,-250)
		mibaoNode : addChild(self.timeLab[i])

		local tipsLab = _G.Util : createLabel("说明:",20)
		tipsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		tipsLab : setPosition(cc.p(posX-121,95))
		tipsLab : setAnchorPoint(cc.p(0,0.5))
		mibaoNode : addChild(tipsLab)

		local content=_G.Cfg.mibao[i].instr
		local textLab = _G.Util : createLabel("         "..content, 20)
		-- textLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		textLab : setPosition(posX-120,53)
		textLab : setAnchorPoint( cc.p(0,0.5) )
		textLab : setDimensions(240, 110)
		textLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		mibaoNode : addChild(textLab)

		-- local opentime=_G.Cfg.mibao[i].open_time
		-- local openLab = _G.Util : createLabel(opentime,18)
		-- openLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		-- openLab : setPosition(cc.p(posX-60,352))
		-- openLab : setAnchorPoint(cc.p(0,0.5))
		-- openLab : setDimensions(180, 50)
		-- openLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		-- mibaoNode : addChild(openLab)
	end

	local msg=REQ_MIBAO_REQUEST()
	_G.Network:send(msg)

	local guideId=_G.GGuideManager:getCurGuideId()
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_MIBAO then
    	_G.GGuideManager:initGuideView(self.m_rootLayer)
    	_G.GGuideManager:removeCurGuideNode()
		local msg=REQ_MIBAO_TASK_FINISH()
		_G.Network:send(msg)

    	self.m_hasGuide=true
    end
end

function MiBaoBoxView.msgCallBack(self,_data)
	if _data==nil then return end
	for k,v in pairs(_data) do
		print(k,v.id,v.state,v.time)
		-- if v.state=1 then
		self:uncountdownEvent(v.id)
		self:countdownEvent(v.id,v.time)
		-- end
	end
end

function MiBaoBoxView.countdownEvent( self,_id,_time )
    local function local_scheduler()
        self : initCountdown(_id,_time)
    end
    self.m_timeScheduler[_id] =  _G.Scheduler : schedule(local_scheduler, 1)
    self : initCountdown(_id,_time)
end

function MiBaoBoxView.uncountdownEvent( self,id )
    if self.m_timeScheduler[id] ~= nil then
        _G.Scheduler : unschedule(self.m_timeScheduler[id] )
        self.m_timeScheduler[id] = nil
    end
end

function MiBaoBoxView.initCountdown(self,_id,_time)
    if not _time then
        return
    end
    local m_serverTime = _G.TimeUtil : getServerTimeSeconds()
    _time = _time - m_serverTime
    print("m_endTimes", _time,m_serverTime)
    local time = ""
    if _time <= 0 then
        self : uncountdownEvent(_id)
        local msg=REQ_MIBAO_REQUEST()
		_G.Network:send(msg)
        self.timeLab[_id] : setString("下波时间:00:00:00")
    else
        time = self : getTimeStr(_time)
        self.timeLab[_id] : setString("下波时间:"..time)
    end
end

function MiBaoBoxView.getTimeStr( self, _time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)

    if hour < 10 then hour = "0"..hour
    elseif hour < 0 then hour = "00" end

    if min < 10 then min = "0"..min
    elseif min < 0 then min = "00" end

    if second < 10 then second = "0"..second end
    local time = tostring(hour)..":"..tostring(min)..":"..second

    return time
end

function MiBaoBoxView.__closeWindow(self)
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil

    for i=1,3 do
    	self:uncountdownEvent(i)
    end

	cc.Director:getInstance():popScene()
	self:destroy()

	if self.m_hasGuide then
        local command=CGuideNoticShow()
        controller:sendCommand(command)
    end
end

return MiBaoBoxView