local ExplainView=classGc()

local m_winSize=cc.Director:getInstance():getWinSize()
local FrameSize=cc.size(514,334)
local ThreeSize=cc.size(489,275)

function ExplainView.create(self,_id,_flag,fonts)
	local flag = _flag or false 
	local function onTouchBegan(touch) 
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(m_winSize.width/2-FrameSize.width/2,m_winSize.height/2-FrameSize.height/2,
        FrameSize.width,FrameSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end
        self:delayCallFun()
        return true
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    self:initView(_id,fonts)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rootLayer,1000)
    -- if flag then
    -- 	local size = cc.Director:getInstance():getVisibleSize()
    -- 	local downDins = cc.LayerColor:create(cc.c4b(0,0,0,150))
    --     downDins       : setContentSize(size)
    --     --downDins       : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
    --     self.m_rootLayer: addChild(downDins,-1)
    -- end
end

function ExplainView.delayCallFun( self )
    local function nFun()
        print("nFun-----------------")
        -- if self.m_rootLayer~=nil then
            self.m_rootLayer:removeFromParent(true)
            -- self.m_rootLayer=nil
        -- end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.m_rootLayer:runAction(cc.Sequence:create(delay,func))
end

function ExplainView.initView(self,_id,fonts)
	-- local function c(sender,eventType)
 --    	if eventType == ccui.TouchEventType.ended then
 --    		self.m_rootLayer:removeFromParent()
 --    	end
	-- end

    local winSize=cc.Director:getInstance():getWinSize()
    self.m_loaderNode=cc.Node:create()
    self.m_loaderNode:setPosition(winSize.width/2,0)
    self.m_rootLayer:addChild(self.m_loaderNode)

    local framePos=cc.p(0,312)
    local dinsSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    dinsSpr:setPreferredSize(FrameSize)
    dinsSpr:setPosition(framePos)
    self.m_loaderNode:addChild(dinsSpr)

    local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    frameSpr:setPreferredSize(cc.size(492,278))
    frameSpr:setPosition(0,FrameSize.height-40)
    self.m_loaderNode:addChild(frameSpr)

    self.m_labelTitle=_G.Util:createBorderLabel("说 明",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_labelTitle:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    self.m_labelTitle:setPosition(0,455)
    self.m_loaderNode:addChild(self.m_labelTitle,10)

    -- self.m_closeBtn=gc.CButton:create("general_close.png")
    -- self.m_closeBtn:setPosition(winSize.width/2+FrameSize.width*0.5-20,framePos.y+FrameSize.height*0.5-20)
    -- self.m_closeBtn:addTouchEventListener(c)
    -- self.m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
    -- self.m_rootLayer:addChild(self.m_closeBtn,10)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(-125,455)
    self.m_loaderNode:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(120,455)
    titleSpr:setRotation(180)
    self.m_loaderNode:addChild(titleSpr,9)

    local sc_Container = cc.Node : create()
    local ScrollView  = cc.ScrollView : create()

    local totalHeight   = 30

    local myNode = cc.Node : create()
    local height = 0
    local fontSize=fonts or 20
	for i=1,#_G.Cfg.paly_des[_id].declare do
		local flag  = _G.Util : createLabel(tostring(i),fontSize)
		flag        : setAnchorPoint(cc.p(0,1))
		flag        : setPosition(cc.p(15,-height))
		myNode      : addChild(flag)

		local label = _G.Util : createLabel(_G.Cfg.paly_des[_id].declare[i],fontSize)
		label       : setAnchorPoint(cc.p(0,1))
		label       : setDimensions(455,0)
		label       : setPosition(cc.p(35,-height))
		myNode      : addChild(label)

		height = height + label : getContentSize().height+10
	end

    print( "height = ", height )
    if height >= 275 then
        totalHeight = height+20
    end

    local viewSize      = cc.size( ThreeSize.width, ThreeSize.height-4 )
	print("height",totalHeight)
    local containerSize = cc.size(ThreeSize.width, totalHeight)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(containerSize)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView 		: setAnchorPoint(cc.p(0,0))
    ScrollView      : setPosition(cc.p(0,3))
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    sc_Container    : addChild(ScrollView)
    sc_Container    : setAnchorPoint(cc.p(0,0))
    sc_Container    : setPosition(cc.p(0,0))
    frameSpr        : addChild(sc_Container)

    ScrollView : addChild( myNode )
    myNode : setPosition( 0,totalHeight-10 )

    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView 	  : setPosOff(cc.p(-3,0))
end

return ExplainView
