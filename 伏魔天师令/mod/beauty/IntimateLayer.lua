local IntimateLayer   = classGc(view,function ( self,_id,_uid )
	self.m_winSize    = cc.Director : getInstance() : getVisibleSize()
	self.id = _id
	self.uid = _uid
end)

local RIGHT_SIZE= cc.size(480,405)

function IntimateLayer.create(self)
    self : __init()

	self.m_rootLayer  = cc.Node : create()

	self :__initView()
	
    return self.m_rootLayer
end

function IntimateLayer.__init(self)
    self : register()
end

function IntimateLayer.register(self)
    self.pMediator = require("mod.beauty.IntimateMediator")(self)
end
function IntimateLayer.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function IntimateLayer.__initView( self )
	print("..............创建亲密面板..............")
	local rightBG    = cc.Node:create()
	rightBG   		 : setPosition(cc.p(145,-320))
	self.m_rootLayer : addChild(rightBG)
	self.rightBG     = rightBG

	local fontSize   = 20
	self.iconPoint   = {}

	self.attrMsg     = {}

	local iconArray  = 
	{
		[41] = "general_att.png",
		[42] = "general_hp.png",
		[43] = "general_wreck.png",
		[44] = "general_def.png",
		[45] = "general_hit.png",
		[46] = "general_dodge.png",
		[47] = "general_crit.png",
		[48] = "general_crit_res.png",
	}

	local pointArray = 
	{
		cc.p(180,530),cc.p(80,530),
		cc.p(180,430),cc.p(80,430),
		cc.p(80,330),cc.p(180,330),
		cc.p(80,230),cc.p(180,230),
	}
	for i=1,8 do
		self.iconPoint[40+i] = pointArray[i]
		self.attrMsg[i] = {}
		local dins   = cc.Sprite : createWithSpriteFrameName("beauty_skill_box.png")
		dins         : setPosition(pointArray[i])
		rightBG      : addChild(dins)

		local function btnEvent( sender,eventType )
			if eventType == ccui.TouchEventType.ended then
				self.tag = sender:getTag()
				print("TAG:",self.tag)
				self.selectIcon:setPosition(self.iconPoint[self.tag])

				local msg = REQ_MEIREN_HONEY_REQUEST()
				msg       : setArgs(self.id,self.tag,self.uid)
				_G.Network: send(msg)
			end
		end

		local icon = cc.Sprite : createWithSpriteFrameName(iconArray[40+i])
		icon       : setPosition(cc.p(40,50))
		icon       : setScale(2)
		dins       : addChild(icon) 

		local btn    = ccui.Widget:create()
		btn          : setContentSize(cc.size(100,100))
		btn          : setTouchEnabled(true)
		btn          : addTouchEventListener(btnEvent)
		btn          : setPosition(cc.p(50,50))
		btn          : setTag(40+i)
		dins         : addChild(btn)

		local lv     = _G.Util : createLabel("",fontSize-3)
		lv           : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
		lv           : setPosition(cc.p(40,13))
		dins         : addChild(lv)

		local rate   = cc.Node:create()
		rate         : setScale(0.7)
		rate         : setPosition(cc.p(0,40))
		dins         : addChild(rate)

		self.attrMsg[i].lv   = lv
		self.attrMsg[i].rate = rate	
	end

	self.selectIcon  = cc.Sprite : createWithSpriteFrameName("beauty_select_box.png")
	self.selectIcon  : setPosition(self.iconPoint[41])
	rightBG          : addChild(self.selectIcon,-1)

	local function btnEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("亲密 1 次")
    		local msg = REQ_MEIREN_ONE_HONEY()
    		msg       : setArgs(self.id,self.tag)
    		_G.Network: send(msg)
    	end
    end

    local button = gc.CButton:create()
	button : addTouchEventListener(btnEvent)
	button : loadTextures("general_btn_gold.png")
	button : setTitleText("亲密")
	button : setTitleFontSize(24)
	button : setTitleFontName(_G.FontName.Heiti)
	button : setButtonScale(0.8)
	button : setPosition(cc.p(90,40))
	rightBG      : addChild(button)
	self.button = button

	local function btnEvent1( send,eventType )
		if eventType == ccui.TouchEventType.ended then
    		print("亲密 10 次")
    		local msg = REQ_MEIREN_TEN_HONEY()
    		msg       : setArgs(self.id,self.tag)
    		_G.Network: send(msg)
    	end
	end 

	local button1= gc.CButton:create()
	button1     : addTouchEventListener(btnEvent1)
	button1     : loadTextures("general_btn_lv.png")
	button1     : setTitleText("亲密10次")
	button1     : setTitleFontSize(24)
	button1     : setTitleFontName(_G.FontName.Heiti)
	button1     : setButtonScale(0.8)
	button1     : setPosition(cc.p(210,40))
	rightBG     : addChild(button1)
	self.button1= button1
	if self.uid~=0 then
		button  : setGray()
    	button  : setEnabled(false)
    	button1 : setGray()
    	button1 : setEnabled(false)
    end

	self:__updateMsg()
	self.tag = 41
	local msg = REQ_MEIREN_HONEY_REQUEST()
	msg       : setArgs(self.id,self.tag,self.uid)
	_G.Network: send(msg)
end

function IntimateLayer.initView( self,_msg )
	for i=1,8 do
		self.attrMsg[i].lv   : setString(_msg.attr[40+i][1].."级".._G.Lang.type_name[40+i])
		--self.attrMsg[i].rate : setString("+"..(_msg.attr[40+i][2]/100).."%")
		self.attrMsg[i].rate : removeAllChildren()
		print(_msg.attr[40+i][2]/100)
		local node,x = self : updateNumber(_msg.attr[40+i][2]/100)
		self.attrMsg[i].rate : addChild(node)
		self.attrMsg[i].rate : setPositionX(x)	
	end
end

function IntimateLayer.updateNumber( self,_number )
	local num = math.floor(_number)
	print(num)
	local flag = _number - num
	print(flag)
	local node = cc.Node:create()
	local add=cc.Sprite:createWithSpriteFrameName("general_powerno_add.png")
    add:setPosition(13,0)
    node:addChild(add)

    local spriteWidth=21

	local powerful=tostring(num)
	local length=string.len(powerful)

	for i=1,length do
	    local tempSpr=cc.Sprite:createWithSpriteFrameName("general_powerno_"..string.sub(powerful,i,i)..".png")
	    node : addChild(tempSpr)

	    local tempSprSize=tempSpr:getContentSize()
	    spriteWidth=spriteWidth+tempSprSize.width/2+5
	    tempSpr:setPosition(spriteWidth,0)
	end
	local x = 20
	if flag ~= 0 then
		print("这是小数")
		local point=cc.Sprite:createWithSpriteFrameName("beauty_point.png")
	    point:setPosition(spriteWidth+point:getContentSize().width+5,-5)
	    node:addChild(point)
	    spriteWidth = spriteWidth+point:getContentSize().width

	    powerful=tostring(flag*10)
	    print(powerful)
		length=1

		for i=1,length do
	    	local tempSpr=cc.Sprite:createWithSpriteFrameName("general_powerno_"..string.sub(powerful,i,i)..".png")
		    node : addChild(tempSpr)

		    local tempSprSize=tempSpr:getContentSize()
		    spriteWidth=spriteWidth+tempSprSize.width/2+5
		    tempSpr:setPosition(spriteWidth,0)
		end
		x=0
	end

	local symbol=cc.Sprite:createWithSpriteFrameName("beauty_symbol.png")
    symbol:setPosition(spriteWidth+symbol:getContentSize().width,0)
    node:addChild(symbol)

    return node,x
end

function IntimateLayer.__updateMsg( self,_msg )
	local height = 165
	local fontSize=20
	local lv = _G.Util : createLabel("",fontSize)
	lv       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
	lv       : setPosition(cc.p(140,height))
	self.rightBG  : addChild(lv)
	self.lv  = lv

	height        = height - 25

	local expBox  = ccui.Scale9Sprite : createWithSpriteFrameName("main_exp_2.png")
  	expBox        : setPreferredSize(cc.size(240,22))
  	expBox        : setAnchorPoint(0,0.5)
  	expBox        : setPosition(cc.p(20,height))
  	self.rightBG  : addChild(expBox)

  	local expSprite = cc.Sprite : createWithSpriteFrameName("main_exp.png")

  	local exp     = cc.ProgressTimer:create(expSprite)  
  	exp           : setType(cc.PROGRESS_TIMER_TYPE_BAR)  
  	exp           : setMidpoint(cc.p(0,0.5))
  	exp           : setBarChangeRate(cc.p(1,0))
  	exp           : setAnchorPoint(cc.p(0,0.5))
  	exp           : setScale(220/(expSprite:getContentSize().width),1)
  	exp           : setPosition(cc.p(30,height+1))
  	self.rightBG  : addChild(exp)
  	self.exp      = exp

  	local expData = _G.Util : createLabel("",fontSize-2)
  	expData       : setPosition(cc.p(140,height-2))
  	self.rightBG  : addChild(expData)
  	self.expData  = expData

  	height        = height - 30

  	local tipsText= _G.Util : createLabel("每次亲密随机加成0.1%~2%",fontSize)
  	tipsText      : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
  	tipsText      : setPosition(cc.p(140,height))
  	self.rightBG  : addChild(tipsText)
  	self.tipsText = tipsText

  	height        = height - 30

  	local consume = _G.Util : createLabel("消耗飞升丸:",fontSize-2)
  	consume       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	consume       : setPosition(cc.p(100,height))
  	self.rightBG  : addChild(consume)
  	self.consume  = consume

  	local data    = _G.Util : createLabel("",fontSize)
  	data          : setPosition(cc.p(210,height))
  	self.rightBG  : addChild(data)
  	self.data     = data

  	local tips    = _G.Util : createLabel("该属性已达最大加成",fontSize)
  	tips          : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
  	tips          : setPosition(cc.p(140,90))
  	tips          : setVisible(false)
  	self.rightBG  : addChild(tips)

  	self.tips     = tips
end

function IntimateLayer.updateMsg( self,_msg )
	self.lv      : setString(_msg.lv.."级".._G.Lang.type_name[self.tag])
	self.expData : setString((_msg.rate/100).."%/"..(_msg.lv*10).."%")
	self.data    : setString(_msg.ncount.."/".._msg.gcount)

	if _msg.ncount <= _msg.gcount then
		self.data: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	else
		self.data: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
	end

	self.exp     : setPercentage((_msg.rate/100 - (_msg.lv-1)*10)/10*100)

	if _msg.rate == 10000 then
		self.tipsText : setVisible(false)
		self.consume  : setVisible(false)
		self.data     : setVisible(false)
		self.button   : setVisible(false)
		self.button1  : setVisible(false)
		self.tips     : setVisible(true)
	else
		self.tipsText : setVisible(true)
		self.consume  : setVisible(true)
		self.data     : setVisible(true)
		self.button   : setVisible(true)
		self.button1  : setVisible(true)
		self.tips     : setVisible(false)
	end
end

function IntimateLayer.updateTips( self,_msg )
	if _msg.count == 1 then
		_G.Util:playAudioEffect("meiren_chanmian")
  		local command = CErrorBoxCommand(string.format("亲密1次，%s+%.1f%%",_G.Lang.type_name[self.tag],_msg.gexp/100))
   	    controller : sendCommand( command )
  	else
  		_G.Util:playAudioEffect("meiren_chanmian")
  		local command = CErrorBoxCommand(string.format("共亲密%d次，%s+%.1f%%",_msg.count,_G.Lang.type_name[self.tag],_msg.gexp/100))
   	    controller : sendCommand( command )
  	end
end

return IntimateLayer