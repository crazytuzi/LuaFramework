local BeautyView = classGc(view,function ( self,_uid )
	self.m_winSize = cc.Director : getInstance() : getVisibleSize()
	self.m_spineResArray={}
	self.uid = _uid or 0
	print("self.uid：",self.uid)
end)

function BeautyView.create( self )
	self : init()
	self.m_rootLayer = cc.Scene : create()
    self : __initView()
    self : updateAllAttr()
    return self.m_rootLayer
end

function BeautyView.init( self )
	self : register()
end

function BeautyView.register(self)
    self.pMediator = require("mod.beauty.BeautyMediator")(self)
end

function BeautyView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function BeautyView.__initView( self )
	local bg = cc.Node : create()
	bg       : setPosition(cc.p(self.m_winSize.width/2,0))
	self.m_rootLayer : addChild(bg)
	self.bg  = bg

	local function backEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			if self.m_rootLayer == nil then return end
	    	self.m_rootLayer=nil
			self : unregister()
            cc.Director : getInstance() : popScene()

            local signArray=_G.GOpenProxy:getSysSignArray()
            if signArray[_G.Const.CONST_FUNC_OPEN_BEAUTY] then
			  	_G.GOpenProxy:delSysSign(_G.Const.CONST_FUNC_OPEN_BEAUTY)
			end
			
            _G.SpineManager.releaseSpineInView(self.m_spineResArray)
		end
	end

	local back = gc.CButton : create("general_close_2.png")
	back       : addTouchEventListener(backEvent)
	back       : setSoundPath("bg/ui_sys_clickoff.mp3")
	back       : setPosition(cc.p(self.m_winSize.width-35,self.m_winSize.height-35))
	back 	   : ignoreContentAdaptWithSize(false)
    back 	   : setContentSize(cc.size(back:getContentSize().width+58,back:getContentSize().height+58))
	self.m_rootLayer : addChild(back)

	self.Sc_Container = cc.Node : create()
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView

    local count = table.nums(_G.Cfg.meiren_des)
    
    local viewSize     = cc.size(self.m_winSize.width, self.m_winSize.height)
    self.containerSize = cc.size(1536, self.m_winSize.height)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.horizontal)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(self.containerSize)
    ScrollView      : setContentOffset( cc.p( 0, 0))
    ScrollView      : setPosition(cc.p(0, 0))
    ScrollView      : setBounceable(false)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    self.Sc_Container : addChild(ScrollView)
    self.Sc_Container : setPosition(cc.p(bg:getContentSize().width/2-self.m_winSize.width/2,0))
    bg    	          : addChild(self.Sc_Container)

    print("count",count)

    local map = cc.Sprite : create("ui/bg/beauty_bg.jpg")
    map       : setAnchorPoint(cc.p(0,0))
    map       : setPosition(cc.p(0,0))
    ScrollView: addChild(map)

    self.state = {}
    self.textDins = {}
    self.point = {}
    local pointArray = 
    {
    	cc.p(170,143),
    	cc.p(360,300),
    	cc.p(590,190),
    	cc.p(770,300),
    	cc.p(990,115),
    	cc.p(1180,215),
    	cc.p(1410,147),
	}

	for i=1,count do
		print("name",_G.Cfg.meiren[60000+5*(i-1)][1][1].name)
		print("id",_G.Cfg.meiren[60000+5*(i-1)][1][1].skin)

		local dins  = ccui.Scale9Sprite : createWithSpriteFrameName("beauty_text_dins.png")
		dins        : setAnchorPoint(cc.p(0,1))
		dins        : setPreferredSize(cc.size(33,250))
		dins        : setPosition(cc.p(pointArray[i].x-97,pointArray[i].y+273))
		ScrollView  : addChild(dins)

		self.textDins[60000+5*(i-1)] = dins

		local name  = _G.Util:createLabel(_G.Cfg.meiren[60000+5*(i-1)][1][1].name,20)
		name        : setAnchorPoint(cc.p(0,0.5))
		name        : setDimensions(22, 0)
		name        : setPosition(cc.p(pointArray[i].x-90,pointArray[i].y+200))
		ScrollView  : addChild(name)

		local point = cc.Sprite : createWithSpriteFrameName("beauty_point.png")
		point       : setAnchorPoint(cc.p(0,0.5))
		point       : setPosition(cc.p(pointArray[i].x-82,pointArray[i].y+147))
		ScrollView  : addChild(point)

		self.point[60000+5*(i-1)]=point

		local card = _G.Cfg.meiren_des[60000+5*(i-1)].m_card
		local bagNum = _G.GBagProxy:getGoodsCountById(card)
	    local LabStr = "未激活"
	    local LabCol = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
	    if bagNum>0 then
	        LabStr = "可激活"
	        LabCol = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE)
	    end

		local state = _G.Util:createLabel(LabStr,20)
		state       : setColor(LabCol)
		state       : setAnchorPoint(cc.p(0,0.5))
		state       : setDimensions(22, 0)
		state       : setPosition(cc.p(pointArray[i].x-90,pointArray[i].y+100))
		ScrollView  : addChild(state)

		self.state[60000+5*(i-1)]=state

		local szSpineName="spine/".._G.Cfg.meiren[60000+5*(i-1)][1][1].skin
		local function nCall()
			local _spine=_G.SpineManager.createSpine(szSpineName,0.55)
			_spine:setPosition(pointArray[i])
			_spine:setAnimation(0,"idle",true)
			ScrollView:addChild(_spine)
		end
		cc.Director:getInstance():getTextureCache():addImageAsync(szSpineName..".png",nCall)
		self.m_spineResArray[szSpineName]=true

	  	local function btnEvent( send,eventType )
	  		if eventType == ccui.TouchEventType.began then
	  			self.startOff =  ScrollView:getContentOffset()
	  		elseif eventType == ccui.TouchEventType.ended then
	  			local curOff = ScrollView:getContentOffset()
	  			local offset = math.abs(curOff.x-self.startOff.x)
	  			print("当前移动：",offset)
	  			if offset > 5 then
	  				return
	  			end
	  			id = send:getTag()
	  			print("美人id：",id)

	  			local activate = self.activateArr[id] or false

	  			local follow   = false
	  			if id == self.follow then
	  				follow = true
	  			end
	  			print(activate,follow)
	  			local view  = require("mod.beauty.BeautySubView")(id,activate,follow,self.uid)
				local layer = view:create()

				cc.Director : getInstance() : getRunningScene() : addChild(layer)
	  		end
	  		return true
	  	end

	  	local size = cc.size(180,300)

	  	local button = ccui.Widget:create()
	  	button       : setContentSize(size)
	  	button       : addTouchEventListener(btnEvent)
	  	button       : setTouchEnabled(true)
	  	button       : setSwallowTouches(false)
	  	button       : setTag(60000+5*(i-1))
	  	button       : enableSound()
	  	button       : setPosition(cc.p(pointArray[i].x,pointArray[i].y+150))
	  	ScrollView   : addChild(button)
	end

	
end

function BeautyView.updateActivate( self,_msg )
	self.activateArr = {}
	for k,v in pairs(_msg.msg) do
		print(k,v)
		self.activateArr[v]=true
		self.state[v]:setString("")
		self.point[v]:setVisible(false)
		self.textDins[v]:setPreferredSize(cc.size(33,146))
	end
end

function BeautyView.updateFollow( self,_id )
	if self.follow and self.follow~=0 then
		self.state[self.follow]:setString("")
		self.point[self.follow]:setVisible(false)
		self.textDins[self.follow]:setPreferredSize(cc.size(33,146))
	end

	self.follow = _id

	if _id == 0 then
		return
	end
	self.textDins[_id]:setPreferredSize(cc.size(33,250))
	self.point[_id]:setVisible(true)
	self.state[_id]:setString("跟随中")
	self.state[_id]:setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
end

function BeautyView.updateAllAttr( self )
	local bgSize     = self.bg:getContentSize()
	local fontSize   = 20

	local dins = cc.LayerColor:create(cc.c4b(0,0,0,150))
	dins       : setContentSize(cc.size(self.m_winSize.width,55))
	dins       : setAnchorPoint(cc.p(0,0))
	dins       : setPosition(cc.p(bgSize.width/2-self.m_winSize.width/2,0))
	self.bg    : addChild(dins)

	local width      = bgSize.width/2-self.m_winSize.width/2+30
	local height     = 40
	local color      = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN)
	local color1     = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PALEGREEN)

	local allAttrLab = _G.Util : createLabel("总属性加成:",fontSize)
	allAttrLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LABELBLUE))
	allAttrLab       : setAnchorPoint(cc.p(0,0.5))
	allAttrLab       : setPosition(cc.p(width,height))
	self.bg          : addChild(allAttrLab)

	width = width + 130

	local att        = _G.Util : createLabel("攻击:",fontSize)
	att              : setColor(color)
	att              : setAnchorPoint(cc.p(0,0.5))
	att              : setPosition(cc.p(width,height))
	self.bg          : addChild(att)

	local attData    = _G.Util : createLabel("",fontSize)
	attData          : setColor(color1)
	attData          : setAnchorPoint(cc.p(0,0.5))
	attData          : setPosition(cc.p(width+60,height))
	self.bg          : addChild(attData)
	self.attData     = attData

	local hp         = _G.Util : createLabel("气血:",fontSize)
	hp               : setColor(color)
	hp               : setAnchorPoint(cc.p(0,0.5))
	hp               : setPosition(cc.p(width,height-25))
	self.bg          : addChild(hp)

	local hpData     = _G.Util : createLabel("",fontSize)
	hpData           : setColor(color1)
	hpData           : setAnchorPoint(cc.p(0,0.5))
	hpData           : setPosition(cc.p(width+60,height-25))
	self.bg          : addChild(hpData)
	self.hpData      = hpData

	width = width + 150

	local wreck      = _G.Util : createLabel("破甲:",fontSize)
	wreck            : setColor(color)
	wreck            : setAnchorPoint(cc.p(0,0.5))
	wreck            : setPosition(cc.p(width,height))
	self.bg          : addChild(wreck)

	local wreckData  = _G.Util : createLabel("",fontSize)
	wreckData        : setColor(color1)
	wreckData        : setAnchorPoint(cc.p(0,0.5))
	wreckData        : setPosition(cc.p(width+60,height))
	self.bg          : addChild(wreckData)
	self.wreckData   = wreckData

	local def        = _G.Util : createLabel("防御:",fontSize)
	def              : setColor(color)
	def              : setAnchorPoint(cc.p(0,0.5))
	def              : setPosition(cc.p(width,height-25))
	self.bg          : addChild(def)

	local defData    = _G.Util : createLabel("",fontSize)
	defData          : setColor(color1)
	defData          : setAnchorPoint(cc.p(0,0.5))
	defData          : setPosition(cc.p(width+60,height-25))
	self.bg          : addChild(defData)
	self.defData     = defData

	width = width + 150

	local hit        = _G.Util : createLabel("命中:",fontSize)
	hit              : setColor(color)
	hit              : setAnchorPoint(cc.p(0,0.5))
	hit              : setPosition(cc.p(width,height))
	self.bg          : addChild(hit)

	local hitData    = _G.Util : createLabel("",fontSize)
	hitData          : setColor(color1)
	hitData          : setAnchorPoint(cc.p(0,0.5))
	hitData          : setPosition(cc.p(width+60,height))
	self.bg          : addChild(hitData)
	self.hitData     = hitData

	local dod        = _G.Util : createLabel("闪避:",fontSize)
	dod              : setColor(color)
	dod              : setAnchorPoint(cc.p(0,0.5))
	dod              : setPosition(cc.p(width,height-25))
	self.bg          : addChild(dod)

	local dodData    = _G.Util : createLabel("",fontSize)
	dodData          : setColor(color1)
	dodData          : setAnchorPoint(cc.p(0,0.5))
	dodData          : setPosition(cc.p(width+60,height-25))
	self.bg          : addChild(dodData)
	self.dodData     = dodData

	width = width + 150

	local crit       = _G.Util : createLabel("暴击:",fontSize)
	crit             : setColor(color)
	crit             : setAnchorPoint(cc.p(0,0.5))
	crit             : setPosition(cc.p(width,height))
	self.bg          : addChild(crit)

	local critData   = _G.Util : createLabel("",fontSize)
	critData         : setColor(color1)
	critData         : setAnchorPoint(cc.p(0,0.5))
	critData         : setPosition(cc.p(width+60,height))
	self.bg          : addChild(critData)
	self.critData    = critData

	local crit_res   = _G.Util : createLabel("抗暴:",fontSize)
	crit_res         : setColor(color)
	crit_res         : setAnchorPoint(cc.p(0,0.5))
	crit_res         : setPosition(cc.p(width,height-25))
	self.bg          : addChild(crit_res)

	local crit_resData= _G.Util : createLabel("",fontSize)
	crit_resData     : setColor(color1)
	crit_resData     : setAnchorPoint(cc.p(0,0.5))
	crit_resData     : setPosition(cc.p(width+60,height-25))
	self.bg          : addChild(crit_resData)
	self.crit_resData= crit_resData

	local msg = REQ_MEIREN_REQUEST_MAIN_ATT()
	msg       :setArgs(self.uid)
	_G.Network:send(msg)
end

function BeautyView.updateAttr( self,_msg )
	self.attData      : setString(tostring(_msg.att))
	self.hpData       : setString(tostring(_msg.hp))
	self.wreckData    : setString(tostring(_msg.wreck))
	self.defData      : setString(tostring(_msg.def))
	self.hitData      : setString(tostring(_msg.hit))
	self.dodData      : setString(tostring(_msg.dod))
	self.critData     : setString(tostring(_msg.crit))
	self.crit_resData : setString(tostring(_msg.crit_res))
end

return BeautyView