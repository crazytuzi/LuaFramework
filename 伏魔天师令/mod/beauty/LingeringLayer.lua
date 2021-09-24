local LingeringLayer   = classGc(view,function ( self,_id,_isOpen,_follow,_uid )
	self.m_winSize     = cc.Director : getInstance() : getVisibleSize()
	self.id     = _id
	self.isOpen = _isOpen
	self.follow = _follow
	self.uid = _uid
	print("跟随状态：",self.follow)
end)

local LEFT_SIZE = cc.size(300,405)
local RIGHT_SIZE= cc.size(480,405) 

function LingeringLayer.create(self)
    self : __init()

	self.m_rootLayer  = cc.Node : create()
	local msg = REQ_MEIREN_REQUES_LINGERING()
	msg       : setArgs(self.id,self.uid)
	_G.Network: send(msg)
	_G.Util:playAudioEffect("ui_sys_click")

	cc.SimpleAudioEngine:getInstance():stopAllEffects()
    local szMp3=string.format("%d",_G.Cfg.meiren_des[self.id].m_card)
    _G.Util:playAudioEffect(szMp3,nil,true)

    return self.m_rootLayer
end

function LingeringLayer.__init(self)
    self : register()
end

function LingeringLayer.register(self)
    self.pMediator = require("mod.beauty.LingeringMediator")(self)
end
function LingeringLayer.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function LingeringLayer.initView( self,_msg )
	print("..............创建缠绵面板..............")
	print("等级",_msg.lv)
	self.m_rootLayer:removeAllChildren()

	local leftBG     = cc.Node:create()
	leftBG   		 : setPosition(cc.p(-257,-320))
	self.m_rootLayer : addChild(leftBG)
	self.leftBG      = leftBG

	local rightBG    = cc.Node:create()
	rightBG   		 : setPosition(cc.p(RIGHT_SIZE.width/2-87,-320))
	self.m_rootLayer : addChild(rightBG)
	self.rightBG     = rightBG

	self : updatePower(_msg.power)

	local fontSize = 20

	local function local_btncallback(sender, eventType) 
	    if eventType==ccui.TouchEventType.ended then
	        if self.isOpen then
		    	local msg = REQ_MEIREN_FOLLOW()
	        	msg       : setArgs(self.id)
	        	_G.Network: send(msg)
	        else
	        	local msg = REQ_MEIREN_GET()
	        	msg       : setArgs(self.id)
	        	_G.Network: send(msg)
	        end
	    end
  	end
	
    local btn = gc.CButton:create("beauty_red_btn.png") 
    btn  : setTitleFontName(_G.FontName.Heiti)
    if self.isOpen then
    	if self.follow then
    		btn  : setTitleText("取消")
    	else
    		btn  : setTitleText("跟随")
    	end
    else
    	btn  : setTitleText("激活")
    end
    btn  : addTouchEventListener(local_btncallback)
    btn  : setTitleFontSize(24)
    btn  : setPosition(LEFT_SIZE.width/2,50)
    self.leftBG : addChild(btn)
    if self.uid~=0 then
    	btn : setGray()
    	btn : setEnabled(false)
    end
    self.btn = btn

	local spine = _G.SpineManager.createSpine("spine/".._G.Cfg.meiren[self.id][1][1].skin,0.7)
	--local spine = _G.SpineManager.createSpine("spine/"..50101,0.6)
	spine : setPosition(cc.p(LEFT_SIZE.width/2,105))
  	spine : setAnimation(0,"idle",true)
  	leftBG: addChild(spine)

  	local powerTips=_G.Util:getLogsView():createAttrLogsNode()
	powerTips:setPosition(cc.p(LEFT_SIZE.width/2,LEFT_SIZE.height/2))
	leftBG:addChild(powerTips)

  	local height   = 560
  	local name = _G.Util : createLabel(_G.Cfg.meiren[self.id][1][1].name,fontSize)
  	name       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
  	name       : setAnchorPoint(cc.p(0,0.5))
  	name       : setPosition(cc.p(10,height))
  	rightBG    : addChild(name)

  	if self.isOpen then
  		
  	else
  		local flagLabel = _G.Util : createLabel("(未激活)",fontSize)
  		flagLabel       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
	  	flagLabel       : setAnchorPoint(cc.p(0,0.5))
	  	flagLabel       : setPosition(cc.p(100,height))
	  	rightBG         : addChild(flagLabel)
  	end

  	height = height - 30

  	local curAttr  = _G.Util : createLabel("当前属性",fontSize)
  	curAttr        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
  	curAttr        : setAnchorPoint(cc.p(0,0.5))
  	curAttr        : setPosition(cc.p(10,height))
  	rightBG        : addChild(curAttr)

  	local nextAttr = _G.Util : createLabel("(下级属性)",fontSize)
  	nextAttr       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	nextAttr       : setAnchorPoint(cc.p(0,0.5))
  	nextAttr       : setPosition(cc.p(100,height))
  	rightBG        : addChild(nextAttr)
  	self.nextAttr  = nextAttr

  	self.attr = _msg.attr

  	height         = height - 50
  	local width    = 0
  	local attrTab  = _G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].attr
  	local attrTab1 = 0
  	if _msg.lv == 100 then
  		attrTab1 = _G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].attr
  	else
  		attrTab1 = _G.Cfg.meiren[self.id][_msg.lv+1][math.floor(_msg.lv/10)+1].attr
  	end

  	local attIcon  = cc.Sprite : createWithSpriteFrameName("general_att.png")
  	attIcon        : setAnchorPoint(0,0.5)
  	attIcon        : setPosition(cc.p(width,height))
  	rightBG        : addChild(attIcon)

  	local attLab   = _G.Util : createLabel("攻击:",fontSize)
  	attLab         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	attLab         : setAnchorPoint(cc.p(0,0.5))
  	attLab         : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(attLab)

  	local num1 = 0
  	local num2 = 0

  	if self.isOpen then
  		num1 = math.floor(attrTab.strong_att*_msg.attr[_G.Const.CONST_ATTR_STRONG_ATT]/10000)+attrTab.strong_att
  		num2 = math.floor(attrTab1.strong_att*_msg.attr[_G.Const.CONST_ATTR_STRONG_ATT]/10000)+attrTab1.strong_att
  	else
  		num1 = attrTab.strong_att
  		num2 = attrTab1.strong_att
  	end

  	local attData  = _G.Util : createLabel(num1,fontSize)
  	attData        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	attData        : setAnchorPoint(cc.p(0,0.5))
  	attData        : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(attData)
  	self.attData   = attData

  	local attData1 = _G.Util : createLabel("("..num2..")",fontSize)
  	attData1       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	attData1       : setAnchorPoint(cc.p(0,0.5))
  	attData1       : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(attData1)
  	self.attData1  = attData1

  	height         = height - 35

  	local hpIcon   = cc.Sprite : createWithSpriteFrameName("general_hp.png")
  	hpIcon         : setAnchorPoint(0,0.5)
  	hpIcon         : setPosition(cc.p(width,height))
  	rightBG        : addChild(hpIcon)

  	local hpLab    = _G.Util : createLabel("气血:",fontSize)
  	hpLab          : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	hpLab          : setAnchorPoint(cc.p(0,0.5))
  	hpLab          : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(hpLab)

  	if self.isOpen then
  		num1 = math.floor(attrTab.hp*_msg.attr[_G.Const.CONST_ATTR_HP]/10000)+attrTab.hp
  		num2 = math.floor(attrTab1.hp*_msg.attr[_G.Const.CONST_ATTR_HP]/10000)+attrTab1.hp
  	else
  		num1 = attrTab.hp
  		num2 = attrTab1.hp
  	end

  	local hpData   = _G.Util : createLabel(num1,fontSize)
  	hpData         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	hpData         : setAnchorPoint(cc.p(0,0.5))
  	hpData         : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(hpData)
  	self.hpData    = hpData

  	local hpData1  = _G.Util : createLabel("("..num2..")",fontSize)
  	hpData1        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	hpData1        : setAnchorPoint(cc.p(0,0.5))
  	hpData1        : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(hpData1)
  	self.hpData1   = hpData1 

  	height         = height - 35

  	local wreckIcon= cc.Sprite : createWithSpriteFrameName("general_wreck.png")
  	wreckIcon      : setAnchorPoint(0,0.5)
  	wreckIcon      : setPosition(cc.p(width,height))
  	rightBG        : addChild(wreckIcon)

  	local wreckLab = _G.Util : createLabel("破甲:",fontSize)
  	wreckLab       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	wreckLab       : setAnchorPoint(cc.p(0,0.5))
  	wreckLab       : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(wreckLab)

  	if self.isOpen then
  		num1 = math.floor(attrTab.defend_down*_msg.attr[_G.Const.CONST_ATTR_DEFEND_DOWN]/10000)+attrTab.defend_down
  		num2 = math.floor(attrTab1.defend_down*_msg.attr[_G.Const.CONST_ATTR_DEFEND_DOWN]/10000)+attrTab1.defend_down
  	else
  		num1 = attrTab.defend_down
  		num2 = attrTab1.defend_down
  	end

  	local wreckData= _G.Util : createLabel(num1,fontSize)
  	wreckData      : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	wreckData      : setAnchorPoint(cc.p(0,0.5))
  	wreckData      : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(wreckData)
  	self.wreckData = wreckData

  	local wreckData1= _G.Util : createLabel("("..num2..")",fontSize)
  	wreckData1     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	wreckData1     : setAnchorPoint(cc.p(0,0.5))
  	wreckData1     : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(wreckData1)
  	self.wreckData1= wreckData1

  	height         = height - 35

  	local defIcon  = cc.Sprite : createWithSpriteFrameName("general_def.png")
  	defIcon        : setAnchorPoint(0,0.5)
  	defIcon        : setPosition(cc.p(width,height))
  	rightBG        : addChild(defIcon)

  	local defLab   = _G.Util : createLabel("防御:",fontSize)
  	defLab         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	defLab         : setAnchorPoint(cc.p(0,0.5))
  	defLab         : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(defLab)

  	if self.isOpen then
  		num1 = math.floor(attrTab.strong_def*_msg.attr[_G.Const.CONST_ATTR_STRONG_DEF]/10000)+attrTab.strong_def
  		num2 = math.floor(attrTab1.strong_def*_msg.attr[_G.Const.CONST_ATTR_STRONG_DEF]/10000)+attrTab1.strong_def
  	else
  		num1 = attrTab.strong_def
  		num2 = attrTab1.strong_def
  	end

  	local defData  = _G.Util : createLabel(num1,fontSize)
  	defData        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	defData        : setAnchorPoint(cc.p(0,0.5))
  	defData        : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(defData)
  	self.defData   = defData

  	local defData1 = _G.Util : createLabel("("..num2..")",fontSize)
  	defData1       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	defData1       : setAnchorPoint(cc.p(0,0.5))
  	defData1       : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(defData1)
  	self.defData1  = defData1

  	height         = height - 35

  	local hitIcon  = cc.Sprite : createWithSpriteFrameName("general_hit.png")
  	hitIcon        : setAnchorPoint(0,0.5)
  	hitIcon        : setPosition(cc.p(width,height))
  	rightBG        : addChild(hitIcon)

  	local hitLab   = _G.Util : createLabel("命中:",fontSize)
  	hitLab         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	hitLab         : setAnchorPoint(cc.p(0,0.5))
  	hitLab         : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(hitLab)

  	if self.isOpen then
  		num1 = math.floor(attrTab.hit*_msg.attr[_G.Const.CONST_ATTR_HIT]/10000)+attrTab.hit
  		num2 = math.floor(attrTab1.hit*_msg.attr[_G.Const.CONST_ATTR_HIT]/10000)+attrTab1.hit
  	else
  		num1 = attrTab.hit
  		num2 = attrTab1.hit
  	end

  	local hitData  = _G.Util : createLabel(num1,fontSize)
  	hitData        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	hitData        : setAnchorPoint(cc.p(0,0.5))
  	hitData        : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(hitData)
  	self.hitData   = hitData

  	local hitData1 = _G.Util : createLabel("("..num2..")",fontSize)
  	hitData1       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	hitData1       : setAnchorPoint(cc.p(0,0.5))
  	hitData1       : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(hitData1)
  	self.hitData1  = hitData1

  	height         = height - 35

  	local dodIcon  = cc.Sprite : createWithSpriteFrameName("general_dodge.png")
  	dodIcon        : setAnchorPoint(0,0.5)
  	dodIcon        : setPosition(cc.p(width,height))
  	rightBG        : addChild(dodIcon)

  	local dodLab   = _G.Util : createLabel("闪避:",fontSize)
  	dodLab         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	dodLab         : setAnchorPoint(cc.p(0,0.5))
  	dodLab         : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(dodLab)

  	if self.isOpen then
  		num1 = math.floor(attrTab.dod*_msg.attr[_G.Const.CONST_ATTR_DODGE]/10000)+attrTab.dod
  		num2 = math.floor(attrTab1.dod*_msg.attr[_G.Const.CONST_ATTR_DODGE]/10000)+attrTab1.dod
  	else
  		num1 = attrTab.dod
  		num2 = attrTab1.dod
  	end

  	local dodData  = _G.Util : createLabel(num1,fontSize)
  	dodData        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	dodData        : setAnchorPoint(cc.p(0,0.5))
  	dodData        : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(dodData)
  	self.dodData   = dodData

  	local dodData1 = _G.Util : createLabel("("..num2..")",fontSize)
  	dodData1       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	dodData1       : setAnchorPoint(cc.p(0,0.5))
  	dodData1       : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(dodData1)
  	self.dodData1  = dodData1

  	height         = height - 35

  	local critIcon = cc.Sprite : createWithSpriteFrameName("general_crit.png")
  	critIcon       : setAnchorPoint(0,0.5)
  	critIcon       : setPosition(cc.p(width,height))
  	rightBG        : addChild(critIcon)

  	local critLab  = _G.Util : createLabel("暴击:",fontSize)
  	critLab        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	critLab        : setAnchorPoint(cc.p(0,0.5))
  	critLab        : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(critLab)

  	if self.isOpen then
  		num1 = math.floor(attrTab.crit*_msg.attr[_G.Const.CONST_ATTR_CRIT]/10000)+attrTab.crit
  		num2 = math.floor(attrTab1.crit*_msg.attr[_G.Const.CONST_ATTR_CRIT]/10000)+attrTab1.crit
  	else
  		num1 = attrTab.crit
  		num2 = attrTab1.crit
  	end

  	local critData = _G.Util : createLabel(num1,fontSize)
  	critData       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	critData       : setAnchorPoint(cc.p(0,0.5))
  	critData       : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(critData)
  	self.critData  = critData

  	local critData1= _G.Util : createLabel("("..num2..")",fontSize)
  	critData1      : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	critData1      : setAnchorPoint(cc.p(0,0.5))
  	critData1      : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(critData1)
  	self.critData1 = critData1

  	height         = height - 35

  	local crit_resIcon= cc.Sprite : createWithSpriteFrameName("general_crit_res.png")
  	crit_resIcon   : setAnchorPoint(0,0.5)
  	crit_resIcon   : setPosition(cc.p(width,height))
  	rightBG        : addChild(crit_resIcon)

  	local crit_resLab= _G.Util : createLabel("抗暴:",fontSize)
  	crit_resLab    : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	crit_resLab    : setAnchorPoint(cc.p(0,0.5))
  	crit_resLab    : setPosition(cc.p(width+45,height))
  	rightBG        : addChild(crit_resLab)

  	if self.isOpen then
  		num1 = math.floor(attrTab.crit_res*_msg.attr[_G.Const.CONST_ATTR_RES_CRIT]/10000)+attrTab.crit_res
  		num2 = math.floor(attrTab1.crit_res*_msg.attr[_G.Const.CONST_ATTR_RES_CRIT]/10000)+attrTab1.crit_res
  	else
  		num1 = attrTab.crit_res
  		num2 = attrTab1.crit_res
  	end

  	local crit_resData= _G.Util : createLabel(num1,fontSize)
  	crit_resData   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	crit_resData   : setAnchorPoint(cc.p(0,0.5))
  	crit_resData   : setPosition(cc.p(width+100,height))
  	rightBG        : addChild(crit_resData)
  	self.crit_resData = crit_resData

  	local crit_resData1= _G.Util : createLabel("("..num2..")",fontSize)
  	crit_resData1  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	crit_resData1  : setAnchorPoint(cc.p(0,0.5))
  	crit_resData1  : setPosition(cc.p(width+165,height))
  	rightBG        : addChild(crit_resData1)
  	self.crit_resData1 = crit_resData1
  	--[[
  	local line     = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
  	line           : setPreferredSize(cc.size(RIGHT_SIZE.width,0))
  	line           : setPosition(cc.p(RIGHT_SIZE.width/2,height-25))
  	rightBG        : addChild(line)
	]]--
  	if not self.isOpen then
  		height = height - 110

	  	local tipIcon   = cc.Sprite : createWithSpriteFrameName("general_tanhao.png")
	  	tipIcon         : setAnchorPoint(cc.p(0,0.5))
	  	tipIcon         : setPosition(cc.p(10,height))
	  	rightBG         : addChild(tipIcon)

	  	local openTips = _G.Util : createLabel(_G.Cfg.meiren_des[self.id].m_mountdes,fontSize)
	  	openTips       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
	  	openTips       : setAnchorPoint(cc.p(0,0.5))
	  	openTips       : setPosition(cc.p(50,height))
	  	rightBG        : addChild(openTips)
  	else
  		height   = height - 50 

		local lv = _G.Util : createLabel("等级:",fontSize)
		lv       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
		lv       : setPosition(cc.p(120,height))
		rightBG  : addChild(lv)

		local lvData = _G.Util : createLabel(_msg.lv,fontSize)
		lvData       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
		lvData       : setPosition(cc.p(120+45,height))
		rightBG      : addChild(lvData)
		self.lvData  = lvData

		height        = height - 30

		local expBox  = ccui.Scale9Sprite : createWithSpriteFrameName("main_exp_2.png")
	  	expBox        : setPreferredSize(cc.size(240,22))
	  	expBox        : setAnchorPoint(0,0.5)
	  	expBox        : setPosition(cc.p(0,height))
	  	rightBG       : addChild(expBox)
	  	self.expBox   = expBox

	  	local expSprite = cc.Sprite : createWithSpriteFrameName("main_exp.png")

	  	local exp     = cc.ProgressTimer:create(expSprite)  
	  	exp           : setType(cc.PROGRESS_TIMER_TYPE_BAR)  
	  	exp           : setMidpoint(cc.p(0,0.5))
	  	exp           : setBarChangeRate(cc.p(1,0))
	  	exp           : setAnchorPoint(cc.p(0,0.5))
	  	exp           : setScale(220/(expSprite:getContentSize().width),1)
	  	exp           : setPosition(cc.p(10,height+1))
	  	rightBG       : addChild(exp)
	  	self.exp      = exp

	  	--local expIcon = cc.Sprite : createWithSpriteFrameName("main_exp_txt.png")
	  	--expIcon       : setPosition(cc.p(45,height))  		
	  	--rightBG       : addChild(expIcon)

	  	local expData = _G.Util : createLabel(_msg.exp.."/".._G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].next_exp,fontSize-2)
	  	expData       : setPosition(cc.p(120,height-2))
	  	rightBG       : addChild(expData)
	  	self.expData  = expData

	  	self.exp:setPercentage((_msg.exp/_G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].next_exp)*100)

	  	height        = height - 35

	  	local consume = _G.Util : createLabel("消耗双修丹:",fontSize-2)
	  	consume       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	  	consume       : setPosition(cc.p(70,height))
	  	rightBG       : addChild(consume)
	  	self.consume  = consume

	  	local data    = _G.Util : createLabel(_msg.n_count.."/".._msg.g_count,fontSize)
	  	data          : setPosition(cc.p(180,height))
	  	rightBG       : addChild(data)
	  	self.data     = data

	  	if _msg.n_count <= _msg.g_count then
	  		data : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
	  	else
	  		data : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
	  	end

	  	local function btnEvent( send,eventType )
	    	if eventType == ccui.TouchEventType.ended then
	    		print("缠绵 1 次")
	    		local msg = REQ_MEIREN_LINGERING()
	    		msg       : setArgs(self.id)
	    		_G.Network: send(msg)
	    	end
	    end

	    local button = gc.CButton:create()
		button : addTouchEventListener(btnEvent)
		button : loadTextures("general_btn_gold.png")
		button : setTitleText("缠绵")
		button : setTitleFontSize(24)
		button : setTitleFontName(_G.FontName.Heiti)
		button : setButtonScale(0.8)
		button : setPosition(cc.p(60,60))
		rightBG      : addChild(button)
		self.button = button

		local function btnEvent1( send,eventType )
			if eventType == ccui.TouchEventType.ended then
	    		print("缠绵 10 次")
	    		local msg = REQ_MEIREN_LINGERING_TEN()
	    		msg       : setArgs(self.id)
	    		_G.Network: send(msg)
	    	end
		end 

		local button1= gc.CButton:create()
		button1     : addTouchEventListener(btnEvent1)
		button1     : loadTextures("general_btn_lv.png")
		button1     : setTitleText("缠绵10次")
		button1     : setTitleFontSize(24)
		button1     : setTitleFontName(_G.FontName.Heiti)
		button1     : setButtonScale(0.8)
		button1     : setPosition(cc.p(180,60))
		rightBG     : addChild(button1)
		self.button1= button1

		if self.uid~=0 then
			button  : setGray()
	    	button  : setEnabled(false)
	    	button1 : setGray()
	    	button1 : setEnabled(false)
	    end

		local tips  = _G.Util : createLabel("美人已达最高等级",fontSize)
		tips        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
		tips        : setPosition(cc.p(120,90))
		rightBG     : addChild(tips)
		tips        : setVisible(false)
		self.tips   = tips

		self : __isEnd(_msg.lv)
  	end
end

function LingeringLayer.updateData( self,_msg )
	print("id",self.id,"lv",_msg.lv)

	local attrTab  = _G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].attr
  	local attrTab1 = 0
  	if _msg.lv == 100 then
  		attrTab1 = _G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].attr
  	else
  		attrTab1 = _G.Cfg.meiren[self.id][_msg.lv+1][math.floor(_msg.lv/10)+1].attr
  	end

  	local num1 = math.floor(attrTab.strong_att*self.attr[_G.Const.CONST_ATTR_STRONG_ATT]/10000)+attrTab.strong_att
  	local num2 = math.floor(attrTab1.strong_att*self.attr[_G.Const.CONST_ATTR_STRONG_ATT]/10000)+attrTab1.strong_att

  	self.attData  : setString(tostring(num1))
  	self.attData1 : setString("("..num2..")")

  	num1 = math.floor(attrTab.hp*self.attr[_G.Const.CONST_ATTR_HP]/10000)+attrTab.hp
  	num2 = math.floor(attrTab1.hp*self.attr[_G.Const.CONST_ATTR_HP]/10000)+attrTab1.hp

  	self.hpData  : setString(tostring(num1))
  	self.hpData1 : setString("("..num2..")")

  	num1 = math.floor(attrTab.defend_down*self.attr[_G.Const.CONST_ATTR_DEFEND_DOWN]/10000)+attrTab.defend_down
  	num2 = math.floor(attrTab1.defend_down*self.attr[_G.Const.CONST_ATTR_DEFEND_DOWN]/10000)+attrTab1.defend_down

  	self.wreckData  : setString(tostring(num1))
  	self.wreckData1 : setString("("..num2..")")

  	num1 = math.floor(attrTab.strong_def*self.attr[_G.Const.CONST_ATTR_STRONG_DEF]/10000)+attrTab.strong_def
    num2 = math.floor(attrTab1.strong_def*self.attr[_G.Const.CONST_ATTR_STRONG_DEF]/10000)+attrTab1.strong_def

  	self.defData  : setString(tostring(num1))
  	self.defData1 : setString("("..num2..")")

  	num1 = math.floor(attrTab.hit*self.attr[_G.Const.CONST_ATTR_HIT]/10000)+attrTab.hit
  	num2 = math.floor(attrTab1.hit*self.attr[_G.Const.CONST_ATTR_HIT]/10000)+attrTab1.hit

  	self.hitData  : setString(tostring(num1))
  	self.hitData1 : setString("("..num2..")")

  	num1 = math.floor(attrTab.dod*self.attr[_G.Const.CONST_ATTR_DODGE]/10000)+attrTab.dod
  	num2 = math.floor(attrTab1.dod*self.attr[_G.Const.CONST_ATTR_DODGE]/10000)+attrTab1.dod

  	self.dodData  : setString(tostring(num1))
  	self.dodData1 : setString("("..num2..")")

  	num1 = math.floor(attrTab.crit*self.attr[_G.Const.CONST_ATTR_CRIT]/10000)+attrTab.crit
  	num2 = math.floor(attrTab1.crit*self.attr[_G.Const.CONST_ATTR_CRIT]/10000)+attrTab1.crit

  	self.critData  : setString(tostring(num1))
  	self.critData1 : setString("("..num2..")")

  	num1 = math.floor(attrTab.crit_res*self.attr[_G.Const.CONST_ATTR_RES_CRIT]/10000)+attrTab.crit_res
  	num2 = math.floor(attrTab1.crit_res*self.attr[_G.Const.CONST_ATTR_RES_CRIT]/10000)+attrTab1.crit_res

  	self.crit_resData  : setString(tostring(num1))
  	self.crit_resData1 : setString("("..num2..")")

  	self.lvData : setString(tostring(_msg.lv))

	self.exp:setPercentage((_msg.exp/_G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].next_exp)*100)

	self.expData : setString(_msg.exp.."/".._G.Cfg.meiren[self.id][_msg.lv][math.floor((_msg.lv-1)/10)+1].next_exp)

	self.data : setString(_msg.n_count.."/".._msg.g_count)

	if _msg.n_count <= _msg.g_count then
  		self.data : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
  	else
  		self.data : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
  	end

  	if _msg.times == 1 then
  		_G.Util:playAudioEffect("meiren_chanmian")
  		local command = CErrorBoxCommand(string.format("缠绵1次，获得%d点经验",_msg.get_exp))
   	    controller : sendCommand( command )
  	elseif _msg.times>1 then
  		_G.Util:playAudioEffect("meiren_chanmian")
  		local command = CErrorBoxCommand(string.format("共缠绵%d次，获得%d点经验",_msg.times,_msg.get_exp))
   	    controller : sendCommand( command )
  	end

  	self : updatePower(_msg.power)

  	self : __isEnd(_msg.lv)
end

function LingeringLayer.__isEnd( self,_lv )
	if _lv >= #_G.Cfg.meiren[self.id] then
		self.attData1      : setVisible(false)
		self.hpData1       : setVisible(false)
		self.wreckData1    : setVisible(false)
		self.defData1      : setVisible(false)
		self.hitData1      : setVisible(false)
		self.dodData1      : setVisible(false)
		self.critData1     : setVisible(false)
		self.crit_resData1 : setVisible(false)
		self.button        : setVisible(false)
		self.button1       : setVisible(false)
		self.consume       : setVisible(false)
		self.exp           : setVisible(false)
		self.expData       : setVisible(false)
		self.expBox        : setVisible(false)
		self.nextAttr      : setVisible(false)
		self.data          : setVisible(false)
		self.tips          : setVisible(true)
	else
		self.attData1      : setVisible(true)
		self.hpData1       : setVisible(true)
		self.wreckData1    : setVisible(true)
		self.defData1      : setVisible(true)
		self.hitData1      : setVisible(true)
		self.dodData1      : setVisible(true)
		self.critData1     : setVisible(true)
		self.crit_resData1 : setVisible(true)
		self.button        : setVisible(true)
		self.button1       : setVisible(true)
		self.consume       : setVisible(true)
		self.exp           : setVisible(true)
		self.expData       : setVisible(true)
		self.expBox        : setVisible(true)
		self.nextAttr      : setVisible(true)
		self.data          : setVisible(true)
		self.tips          : setVisible(false)
	end
end

function LingeringLayer.updatePower(self,powerful)
    if self.m_powerNode~=nil then
        self.m_powerNode=nil 
    end
    print("createPowerfulIcon====",powerful)
    local powerful=tostring(powerful)
    local length=string.len(powerful)
    self.m_powerNode=cc.Node:create()
    local powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    powerSpr:setPosition(65,0)
    self.m_powerNode:addChild(powerSpr)

    local powerSprSize=powerSpr:getContentSize()
    local spriteWidth=35
    for i=1,length do
        local tempSpr=cc.Sprite:createWithSpriteFrameName("general_powerno_"..string.sub(powerful,i,i)..".png")
        self.m_powerNode : addChild(tempSpr)

        local tempSprSize=tempSpr:getContentSize()
        spriteWidth=spriteWidth+tempSprSize.width/2+5
        tempSpr:setPosition(spriteWidth,0)
    end

    self.m_powerNode:setPosition(LEFT_SIZE.width/2-60,550)
    self.leftBG:addChild(self.m_powerNode,10)
end

function LingeringLayer.updateState( self )
	self.isOpen = true
end

function LingeringLayer.updateFollowState( self )
	
	self.follow = not self.follow

	if self.follow then
		_G.Util:playAudioEffect("ui_partner_fight")
		self.btn  : setTitleText("取消")
    else
    	self.btn  : setTitleText("跟随")
    end
    
end

function LingeringLayer.show( self,_bool )
	self.rightBG:setVisible(_bool)
end

function LingeringLayer.updateAttr( self,_msg )
	self.attr[_msg.skid]=_msg.rate
end

return LingeringLayer