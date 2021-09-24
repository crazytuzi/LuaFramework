local CardsView   = classGc(view,function ( self )
	self.m_winSize       = cc.Director : getInstance() : getVisibleSize()
	self.m_leftUpSize    = cc.size(520,325)
	self.m_leftDownSize  = cc.size(520,120)
	self.m_rightUpSize   = cc.size(255,325)
	self.m_rightDownSize = cc.size(255,120)
	self.isClick         = true

	self.textureArr      = {}
end)

local iconSize  = cc.size(123,158)
local iconSize1 = cc.size(220,300)
local color = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN)

function CardsView.create(self)
    self : __init()

    self.m_normalView = require("mod.general.NormalView")()
	self.m_rootLayer  = self.m_normalView:create()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	self  			  : __initView()
	
    return tempScene
end

function CardsView.__init(self)
    self : register()
end

function CardsView.register(self)
    self.pMediator = require("mod.smodule.CardsMediator")(self)
end
function CardsView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function CardsView.__initView( self )
	local function nCloseFun()
		self : __closeWindow()
	end
	self.m_normalView : addCloseFun(nCloseFun)
	self.m_normalView : setTitle("对对牌")

	local second_bg   = self.m_normalView : showSecondBg()

	local leftUpBG	  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
	leftUpBG          : setAnchorPoint(cc.p(0,0))
	leftUpBG 	      : setPosition(cc.p(5,130))
	leftUpBG		  : setPreferredSize(self.m_leftUpSize)
	second_bg         : addChild(leftUpBG)
	self.leftUpBG     = leftUpBG

	local leftDownBG  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
	leftDownBG        : setAnchorPoint(cc.p(0,0))
	leftDownBG 	      : setPosition(cc.p(5,5))
	leftDownBG		  : setPreferredSize(self.m_leftDownSize)
	second_bg         : addChild(leftDownBG)
	self.leftDownBG   = leftDownBG

	local rightUpBG	  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
	rightUpBG         : setAnchorPoint(cc.p(0,0))
	rightUpBG 	      : setPosition(cc.p(5+self.m_leftUpSize.width+5,130))
	rightUpBG		  : setPreferredSize(self.m_rightUpSize)
	second_bg         : addChild(rightUpBG)

	local rightDownBG = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
	rightDownBG       : setAnchorPoint(cc.p(0,0))
	rightDownBG 	  : setPosition(cc.p(5+self.m_leftUpSize.width+5,5))
	rightDownBG		  : setPreferredSize(self.m_rightDownSize)
	second_bg         : addChild(rightDownBG)

	local fontSize    = 20
	--initLeftDown
	local reward = _G.Util : createLabel("奖励:",fontSize)
	reward       : setColor(color)
	reward       : setAnchorPoint(cc.p(0,0))
	reward       : setPosition(cc.p(10,80))
	leftDownBG   : addChild(reward)

	for i=0,4 do
		local x   = 55+(i%2)*240
		local y   = 80-(math.floor(i/2)+1)*25 
		

		local lab = _G.Util : createLabel(string.format("%d步完成%s*%d",i+4,_G.Cfg.goods[_G.Cfg.match_card[i+4].goods[1][1]].name,_G.Cfg.match_card[i+4].goods[1][2]),fontSize)
		lab       : setColor(color)
		lab       : setAnchorPoint(cc.p(0,0))
		lab       : setPosition(cc.p(x,y))
		leftDownBG: addChild(lab)
	end

	self.selectPoint = 
	{
		[4] = cc.p(140,70),
		[5] = cc.p(380,70),
		[6] = cc.p(140,45),
		[7] = cc.p(380,45),
		[8] = cc.p(140,20),
	}
	
	self : __selectEffect(self.selectPoint[4])
	--initRightDown
	local function resetEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			print("重新开局")

			local isStart = false
			local flag    = true
			if not self.iconArray then
				self.iconArray = {}
			end

			for k,v in pairs(self.iconArray) do
				if v.isOpen==1 then
					isStart = true
				else
					flag = false
				end
			end

			if flag then
				local msg = REQ_MATCH_CARD_REQUEST()
				msg       : setArgs(1)
				_G.Network: send(msg)
			else
				if isStart then
					self:__initTips()
				else
					local msg = REQ_MATCH_CARD_REQUEST()
					msg       : setArgs(1)
					_G.Network: send(msg)
				end
			end
		end
	end 

	local resetButton= gc.CButton:create()
	resetButton      : addTouchEventListener(resetEvent)
	resetButton      : loadTextures("general_btn_lvblue.png")
	resetButton      : setTitleText("结束本局")
	resetButton      : setTitleFontSize(24)
	resetButton      : setTitleFontName(_G.FontName.Heiti)
	resetButton      : setPosition(cc.p(130,75))
	rightDownBG      : addChild(resetButton)
	self.resetButton = resetButton

	local resetLabel = _G.Util : createLabel("剩余次数:",fontSize-4)
	resetLabel       : setColor(color)
	resetLabel       : setPosition(cc.p(130,30))
	rightDownBG      : addChild(resetLabel)

	local resetCount = _G.Util : createLabel(tostring(0),fontSize-4)
	resetCount       : setPosition(cc.p(130+resetLabel:getContentSize().width/2+10,30))
	rightDownBG      : addChild(resetCount)

	self.resetCount  = resetCount

	--initRightUp
	local function lookEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			print("偷看一张")
			local msg = REQ_MATCH_CARD_LOOK()
			msg       : setArgs(1)
			_G.Network: send(msg)
		end
	end 

	local lookButton= gc.CButton:create()
	lookButton      : addTouchEventListener(lookEvent)
	lookButton      : loadTextures("general_btn_gold.png")
	lookButton      : setTitleText("偷看一张")
	lookButton      : setTitleFontSize(24)
	lookButton      : setTitleFontName(_G.FontName.Heiti)
	lookButton      : setPosition(cc.p(130,100))
	rightUpBG       : addChild(lookButton)
	self.lookButton = lookButton

	local lookLab   = _G.Util : createLabel("花费10钻石偷看",fontSize-4)
	lookLab         : setColor(color)
	lookLab         : setPosition(cc.p(130,60))
	rightUpBG       : addChild(lookLab)

	local lookLabel = _G.Util : createLabel("剩余次数:",fontSize-4)
	lookLabel       : setColor(color)
	lookLabel       : setPosition(cc.p(130,40))
	rightUpBG       : addChild(lookLabel)

	local lookCount = _G.Util : createLabel(tostring(0),fontSize-4)
	lookCount       : setPosition(cc.p(130+lookLabel:getContentSize().width/2+10,40))
	rightUpBG       : addChild(lookCount)

	self.lookCount  = lookCount

	local function showEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			print("显示一对")
			local msg = REQ_MATCH_CARD_LOOK()
			msg       : setArgs(2)
			_G.Network: send(msg)
		end
	end 

	local showButton= gc.CButton:create()
	showButton      : addTouchEventListener(showEvent)
	showButton      : loadTextures("general_btn_gold.png")
	showButton      : setTitleText("显示一对")
	showButton      : setTitleFontSize(24)
	showButton      : setTitleFontName(_G.FontName.Heiti)
	showButton      : setPosition(cc.p(130,220))
	rightUpBG       : addChild(showButton)
	self.showButton = showButton

	local showLab   = _G.Util : createLabel("花费50钻石偷看",fontSize-4)
	showLab         : setColor(color)
	showLab         : setPosition(cc.p(130,180))
	rightUpBG       : addChild(showLab)

	local showLabel = _G.Util : createLabel("剩余次数:",fontSize-4)
	showLabel       : setColor(color)
	showLabel       : setPosition(cc.p(130,160))
	rightUpBG       : addChild(showLabel)

	local showCount = _G.Util : createLabel(tostring(0),fontSize-4)
	showCount       : setPosition(cc.p(130+showLabel:getContentSize().width/2+10,160))
	rightUpBG       : addChild(showCount)

	self.showCount  = showCount

	local openLabel = _G.Util : createLabel("本局已翻牌步数:",fontSize)
	openLabel       : setColor(color)
	openLabel       : setPosition(cc.p(130,280))
	rightUpBG       : addChild(openLabel)

	local openCount = _G.Util : createLabel(tostring(0),fontSize)
	openCount       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	openCount       : setPosition(cc.p(130+openLabel:getContentSize().width/2+20,280))
	rightUpBG       : addChild(openCount)

	self.openCount  = openCount 

	local function onTouchBegan(touch, event)
		return true
	end

	local function onTouchMoved(touch, event)

	end

	local function onTouchEnded(touch, event)
		print("onTouchEnded~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		if not self.isClick then
			return
		end
		local count = 0
		for k,v in pairs(self.iconArray) do
			if v.sprite : getNumberOfRunningActions() > 0 then
				count = count + 1
			end
		end

		if count >1 then
			return
		end
		local positon = leftUpBG : convertToNodeSpace(touch : getLocation())
		for i=1,8 do
    		if cc.rectContainsPoint(self.iconArray[i].sprite : getBoundingBox(),positon) then
    			print("位置：",i)
    			print("类型：",self.iconArray[i].type)
    			if self.firstIcon and self.secondIcon or self.iconArray[i].isOpen==1 then
    				return
    			end

    			if self.firstIcon then
    				if self.firstIcon==i then
    					self.firstIcon = nil
    				else
    					self.secondIcon = i
    					print("翻牌",self.firstIcon,self.secondIcon)
    					local msg = REQ_MATCH_CARD_REQUEST_MATCH()
    					msg       : setArgs(self.firstIcon,self.secondIcon)
    					_G.Network: send(msg)
    				end
    			else
    				self.firstIcon = i
    				print(self.firstIcon)
    				local msg = REQ_MATCH_CARD_SIGN_CARD()
					msg       : setArgs(self.firstIcon)
					_G.Network: send(msg)
    			end
    			return true
    		end
    	end
	end

	local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener       : setSwallowTouches(true)
    listener       : registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener       : registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener       : registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = leftUpBG : getEventDispatcher() -- 得到事件派发器
    eventDispatcher : addEventListenerWithSceneGraphPriority(listener, leftUpBG) -- 将监听器注册到派发器中

    local msg = REQ_MATCH_CARD_REQUEST()
	msg       : setArgs(0)
	_G.Network: send(msg)
end

function CardsView.__selectEffect( self,_point )

	if self.m_icon_1 then
		self.m_icon_1 : removeFromParent()
		self.m_icon_1 = nil
	end
	if self.m_icon_2 then
		self.m_icon_2 : removeFromParent()
		self.m_icon_2 = nil
	end

	self.m_icon_1   = cc.Sprite : createWithSpriteFrameName("general_jiantou.png")
	self.m_icon_1   : setFlippedX(true)
	self.m_icon_1   : setPosition(cc.p(_point.x-100-22,_point.y))
	self.leftDownBG : addChild(self.m_icon_1,7)

	self.m_icon_2   = cc.Sprite : createWithSpriteFrameName("general_jiantou.png")
	self.m_icon_2   : setPosition(cc.p(_point.x+100+22,_point.y))
	self.leftDownBG : addChild(self.m_icon_2,7)

	self.m_icon_1   : runAction(cc.RepeatForever:create(
					cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(_point.x-100,_point.y)),cc.MoveTo:create(0.2,cc.p(_point.x-100-22,_point.y)))))

	self.m_icon_2   : runAction(cc.RepeatForever:create(
					cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(_point.x+100,_point.y)),cc.MoveTo:create(0.2,cc.p(_point.x+100+22,_point.y)))))
end

function CardsView.initView( self,_msg )
	self.step = _msg.step
	self.one  = _msg.free_one
	self.two  = _msg.free_two
	self.times= _msg.times
	if _msg.times == 0 then
		print("禁止按钮")
		self.resetButton: setGray()
		self.lookButton : setGray()
		self.showButton : setGray()
		self.resetButton: setEnabled(false)
		self.lookButton : setEnabled(false)
		self.showButton : setEnabled(false)
		self.isClick = false
	end

	local leftUpBG   = self.leftUpBG

	local fontSize   = 20
	self.resetCount : setString(tostring(_msg.times))
    self.openCount  : setString(tostring(self.step))
    self.lookCount  : setString(tostring(self.one))
	self.showCount  : setString(tostring(self.two))

	if self.step <= 4 then
		--self.selectIcon : setPosition(self.selectPoint[4])
		self : __selectEffect(self.selectPoint[4])
	elseif self.step >= 8 then
		--self.selectIcon : setPosition(self.selectPoint[8])
		self : __selectEffect(self.selectPoint[8])
	else
		--self.selectIcon : setPosition(self.selectPoint[self.step])
		self : __selectEffect(self.selectPoint[self.step])
	end

	--initLeftUp
	if self.iconArray then
		for k,v in pairs(self.iconArray) do
			v.sprite : removeFromParent()
		end
	end
	self.iconArray = {}
	for i=1,2 do
		for j=1,4 do
			local icon = self : __createIcon(i,j,_msg.data[j+(i-1)*4])
			leftUpBG   : addChild(icon,0)

			self.iconArray[j+(i-1)*4] = {}
			self.iconArray[j+(i-1)*4].sprite = icon
			self.iconArray[j+(i-1)*4].isOpen = _msg.data[j+(i-1)*4].is_open
			self.iconArray[j+(i-1)*4].type   = _msg.data[j+(i-1)*4].type
			print(j+(i-1)*4,_msg.data[j+(i-1)*4].is_open,_msg.data[j+(i-1)*4].type)
		end
	end
	local openArr = {}
	local count = 0
	for k,v in pairs(self.iconArray) do
		if v.isOpen==1 then
			if not openArr[v.type] then
				openArr[v.type] = 0
			end
			openArr[v.type] =  openArr[v.type] + 1
		end
	end

	local m_type = 0
	for k,v in pairs(openArr) do
		if v == 1 then
			m_type = k
		end
	end

	for k,v in pairs(self.iconArray) do
		if m_type == v.type and v.isOpen == 1 then
			self.firstIcon = k
		end
	end

	--开始播放洗牌特效

	local noStart = true
	for k,v in pairs(self.iconArray) do
		if v.isOpen==1 then
			noStart = false
		end
	end

	if noStart then
	    for i=1,8 do
	    	local x = self.iconArray[i].sprite : getPositionX()
	    	local y = self.iconArray[i].sprite : getPositionY()
	    	local action = cc.MoveTo : create(0.25,cc.p(self.m_leftUpSize.width/2,self.m_leftUpSize.height/2))
			local _action= cc.MoveTo : create(0.25,cc.p(x,y))
	    	self.iconArray[i].sprite : runAction(cc.Sequence : create(action,cc.DelayTime : create(0.25),_action))
	    end
	end
end

function CardsView.__createIcon( self,i,j,_msg )
	local icon = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_battle_res_card1.png" )
	icon       : setPreferredSize( iconSize ) 
	if _msg.is_open == 1 then
		local newIcon  = self : __getSpriteFrame(_msg.type)
		icon : setSpriteFrame(newIcon)
		icon : setPreferredSize( iconSize1 )
		icon       : setScale(0.5)
	end
    -- icon       : setScale(0.5)
    icon       : setPosition(cc.p(65+130*(j-1),85+(i-1)*155))
    return icon
end

function CardsView.showOneIcon( self,_msg )
	self.iconArray[_msg.pos].isOpen = _msg.is_open

	_G.Util:playAudioEffect("ui_card")

	local icon = self.iconArray[_msg.pos].sprite
	icon : runAction(cc.Sequence : create(cc.ScaleTo : create(0.25,0,0.5),cc.CallFunc : create(function()
			local newIcon  = self : __getSpriteFrame(_msg.type)
			icon : setSpriteFrame(newIcon)
			icon : setPreferredSize( iconSize1 )
			icon : setScale(0.5)
        end),cc.ScaleTo : create(0.25,0.5,0.5))) 
end

function CardsView.showTwoIcon( self,_msg )
	_G.Util:playAudioEffect("ui_card")

	local icon   = self.iconArray[self.firstIcon].sprite
	local icon_1 = self.iconArray[self.secondIcon].sprite
	if _msg.bool == 1 or _msg.bool == 2 then
		self : __action1(self.secondIcon) 
		self.iconArray[self.secondIcon].isOpen = 1

		if _msg.bool==2 then
			self.resetCount : setString(tostring(self.times-1)) 
		end
	else
		icon : runAction(cc.Sequence : create(cc.DelayTime : create(1.5),cc.ScaleTo : create(0.25,0,0.5),cc.CallFunc : create(function()
			local newIcon  = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui_battle_res_card1.png")
			icon : setSpriteFrame(newIcon)
			icon : setPreferredSize( iconSize )
			-- icon : setScale(0.5)
        end),cc.ScaleTo : create(0.25,1,1)))

		self : __action2(self.secondIcon)

		self.iconArray[self.firstIcon].isOpen = 0
		self.iconArray[self.secondIcon].isOpen = 0
	end
	self.step = _msg.step
	self.openCount  : setString(tostring(self.step))
	if self.step <= 4 then
		--self.selectIcon : setPosition(self.selectPoint[4])
		self : __selectEffect(self.selectPoint[4])
	elseif self.step >= 8 then
		--self.selectIcon : setPosition(self.selectPoint[8])
		self : __selectEffect(self.selectPoint[8])
	else
		--self.selectIcon : setPosition(self.selectPoint[self.step])
		self : __selectEffect(self.selectPoint[self.step])
	end
	self.firstIcon = nil
	self.secondIcon= nil
end

function CardsView.lookOneIcon( self,_msg )
	self : __action2(_msg.pos)
	self.one = self.one - 1

	self.lookCount  : setString(tostring(self.one))
end

function CardsView.lookTwoIcon( self,_msg )
	self : __action1(_msg.pos1)
	self : __action1(_msg.pos2)

	self.iconArray[_msg.pos1].isOpen  = 1
	self.iconArray[_msg.pos2].isOpen  = 1 

	self.step = self.step + 1
	self.two  = self.two - 1

	self.openCount  : setString(tostring(self.step))
	self.showCount  : setString(tostring(self.two))
	if self.step <= 4 then
		self : __selectEffect(self.selectPoint[4])
	elseif self.step >= 8 then
		self : __selectEffect(self.selectPoint[8])
	else
		self : __selectEffect(self.selectPoint[self.step])
	end
end

function CardsView.__action1( self,pos )
	local icon = self.iconArray[pos].sprite
	icon : runAction(cc.Sequence : create(cc.ScaleTo : create(0.25,0,0.5),cc.CallFunc : create(function()
			local newIcon  = self : __getSpriteFrame(self.iconArray[pos].type)
			icon : setSpriteFrame(newIcon)
			icon : setPreferredSize( iconSize1 )
			icon : setScale(0.5)
        end),cc.ScaleTo : create(0.25,0.5,0.5))) 
end

function CardsView.__action2( self,pos )
	local icon = self.iconArray[pos].sprite
	icon : runAction(cc.Sequence : create(cc.ScaleTo : create(0.25,0,0.5),cc.CallFunc : create(function()
			local newIcon  = self : __getSpriteFrame(self.iconArray[pos].type)
			icon : setSpriteFrame(newIcon)
			icon : setPreferredSize( iconSize1 )
			icon : setScale(0.5)
        end),cc.ScaleTo : create(0.25,0.5,0.5),cc.DelayTime : create(1),cc.ScaleTo : create(0.25,0,0.5),cc.CallFunc : create(function()
			local newIcon  = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui_battle_res_card1.png")
			icon : setSpriteFrame(newIcon)
			icon : setPreferredSize( iconSize )
			-- icon : setScale(0.5)
        end),cc.ScaleTo : create(0.25,1,1))) 
end

function CardsView.__initTips( self )
	print("__initTips")

	local size = cc.Director : getInstance() : getWinSize()

	local function sure()
		local msg = REQ_MATCH_CARD_REQUEST()
		msg       : setArgs(1)
		_G.Network: send(msg)
		self.firstIcon = nil
		self.secondIcon= nil
    end

    local function cancel( ... )
    	print("取消")
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    layer 		: setPosition(cc.p(size.width/2,size.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
	local label = _G.Util : createLabel("直接获得本局最低奖励",20)
	label 		: setPosition(cc.p(0,10))
	layer 		: addChild(label)
end

function CardsView.__getSpriteFrame( self,type )
	local id = _G.Cfg.match_card_pic[type].bianhao
	print("id",id)

	local iconPath = string.format("ui/partner/%d.jpg",id)
	self.textureArr[id] = iconPath
	local skin = cc.Sprite:create(iconPath,cc.rect(0,0,220,306))

	return skin : getSpriteFrame()
end

function CardsView.__closeWindow( self )
	local textureCache = cc.Director:getInstance():getTextureCache()
	for k,v in pairs(self.textureArr) do
		textureCache:removeTextureForKey(v)
	end
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self 			     : unregister()
end

return CardsView