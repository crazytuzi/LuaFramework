local BeautySubView   = classGc(view,function ( self,_id,_isOpen,_follow,_uid )
	self.m_winSize   = cc.Director : getInstance() : getVisibleSize()
	self.id    = _id
	self.isOpen= _isOpen
	self.follow= _follow
	self.uid = _uid
end)

local TAGBTN_LINGERING   = 1
local TAGBTN_INTIMATE    = 2

function BeautySubView.create(self)
    self : __init()
    --[[
    self.m_normalView = require("mod.general.TabUpView")()
	self.m_rootLayer  = self.m_normalView:create("美人")
	self  			  : __initView()
	]]--
	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.Layer:create()
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    self:__initView()
	
    return self.m_rootLayer
end

function BeautySubView.__init(self)
    self : register()
end

function BeautySubView.register(self)
    self.pMediator = require("mod.beauty.BeautySubMediator")(self)
end
function BeautySubView.unregister(self)
	for k,v in pairs(self.m_tagPanelClass) do
    	v : unregister()
    end
    self.pMediator : destroy()
    self.pMediator = nil 
end

function BeautySubView.__initView( self )
	local rootNode = cc.Sprite : create("ui/bg/beauty_dins.jpg")
	rootNode       : setPosition(cc.p(self.m_winSize.width/2+16,self.m_winSize.height/2))
	self.m_rootLayer:addChild(rootNode)

	
	local function nCloseFun()
		print("成功删除背景")
		self : __closeWindow()
	end

	local closeBtn = gc.CButton : create("general_close_2.png")
	closeBtn       : addTouchEventListener(nCloseFun)
	closeBtn       : setPosition(cc.p(790,610))
	closeBtn	   : setContentSize(100,100)
	rootNode       : addChild(closeBtn)
	
	local function tabBtnCallBack(tag)
		print("tag =",tag)
		self : selectTagByTag(tag)
		self : initTagPanel(tag)

		for k,v in pairs(self.m_tagPanel) do
			if k==tag then
				if k==TAGBTN_INTIMATE then
					if self.isOpen then
						self.m_tagPanelClass[TAGBTN_LINGERING] : show(false)
						self.m_tagcontainer[k] : setVisible(true)
						local msg = REQ_MEIREN_ATTR_LIST()
						print("美人ID：",self.id)
						msg       : setArgs(self.id,self.uid)
						_G.Network: send(msg)
					else
						local command = CErrorBoxCommand("尚未激活该美人")
   	        			controller : sendCommand( command )
   	        			self : selectTagByTag(TAGBTN_LINGERING)
   	        			self.m_tagcontainer[TAGBTN_INTIMATE] : setVisible(false)
						return false
					end
				else
					self.m_tagPanelClass[k] : show(true)
					self.m_tagcontainer[TAGBTN_INTIMATE] : setVisible(false)
				end
			end
		end
		return true
	end

	local function btnEvent( sender,eventType )
		if eventType == ccui.TouchEventType.began then
			tabBtnCallBack(sender:getTag())
		end
	end

	local btn = gc.CButton : create()
	btn       : loadTextures("beauty_left_btn1.png","beauty_left_btn.png","beauty_left_btn.png")
	btn       : addTouchEventListener(btnEvent)
	btn       : setTag(TAGBTN_LINGERING)
	btn       : setAnchorPoint(cc.p(1,0.5))
	btn       : setPosition(5,560)
	rootNode  : addChild(btn)
	self.btn  = btn

	local lab = _G.Util : createLabel("缠",20)
	lab       : setAnchorPoint(cc.p(0,0.5))
	lab       : setDimensions(20,0)
	lab       : setPosition(cc.p(9,btn:getContentSize().height/2+20))
	btn       : addChild(lab)

	local lab1 = _G.Util : createLabel("绵",20)
	lab1       : setAnchorPoint(cc.p(0,0.5))
	lab1       : setDimensions(20,0)
	lab1       : setPosition(cc.p(9,btn:getContentSize().height/2-20))
	btn        : addChild(lab1)

	local btn1 = gc.CButton : create()
	btn1       : loadTextures("beauty_left_btn1.png","beauty_left_btn.png","beauty_left_btn.png")
	btn1       : addTouchEventListener(btnEvent)
	btn1       : setTag(TAGBTN_INTIMATE)
	btn1       : setAnchorPoint(cc.p(1,0.5))
	btn1       : setPosition(5,415)
	rootNode   : addChild(btn1)
	self.btn1  = btn1

	local lab2 = _G.Util : createLabel("亲",20)
	lab2       : setAnchorPoint(cc.p(0,0.5))
	lab2       : setDimensions(20,0)
	lab2       : setPosition(cc.p(9,btn1:getContentSize().height/2+20))
	btn1       : addChild(lab2)

	local lab3 = _G.Util : createLabel("密",20)
	lab3       : setAnchorPoint(cc.p(0,0.5))
	lab3       : setDimensions(20,0)
	lab3       : setPosition(cc.p(9,btn1:getContentSize().height/2-20))
	btn1       : addChild(lab3)

	self : selectTagByTag(TAGBTN_LINGERING)

	self.m_mainContainer = cc.Node:create()
	self.m_mainContainer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	self.m_rootLayer     : addChild(self.m_mainContainer,9)

	--五个容器五个页面
	self.m_tagcontainer = {}
  	self.m_tagPanel     = {}
  	self.m_tagPanelClass= {}   

	for i=1,2 do
		self.m_tagcontainer[i] = cc.Node:create()
    	self.m_mainContainer   : addChild(self.m_tagcontainer[i])
	end

	self : initTagPanel(TAGBTN_LINGERING)
	--self : initTagPanel(TAGBTN_CHANGE)
end

function BeautySubView.selectTagByTag( self,_tag )
	if _tag == TAGBTN_LINGERING then
		self.btn:setBright(true)
		self.btn1:setBright(false)
	else
		self.btn:setBright(false)
		self.btn1:setBright(true)
	end
end

function BeautySubView.initTagPanel(self,_tag)
	if self.m_tagPanel[_tag] == nil then
		--在这里创建自己面板的的东西
		local view=nil
		if _tag == TAGBTN_LINGERING then
			print("创建缠绵面板")
			view = require "mod.beauty.LingeringLayer"(self.id,self.isOpen,self.follow,self.uid)
			print("创建缠绵面板结束")
		elseif _tag == TAGBTN_INTIMATE then
			print("创建亲密面板")
			view = require "mod.beauty.IntimateLayer"(self.id,self.uid)
			print("创建亲密面板结束")
		end
		if view == nil then return end
		self.m_tagPanelClass[_tag] = view
    	self.m_tagPanel[_tag]      = view:create()

    	self.m_tagcontainer[_tag]:addChild(self.m_tagPanel[_tag])
	end
end

function BeautySubView.updateState( self )
	self.isOpen = true
end

function BeautySubView.__closeWindow( self )
	self.m_rootLayer     : removeFromParent()
	self 			     : unregister()
end

return BeautySubView