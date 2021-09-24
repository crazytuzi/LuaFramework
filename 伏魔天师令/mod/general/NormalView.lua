local NormalView=classGc()

local FrameSize=cc.size(840,560)
local SecondSize=cc.size(849,488)

function NormalView.create(self)
	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.Layer:create()
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    self:initView()
    return self.m_rootLayer
end

function NormalView.initView(self)
	local function c(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
            _G.Util:playAudioEffect("ui_sys_clickoff")
    		if self.m_closeFun~=nil then
    			self.m_closeFun()
    		end
    	end
	end

    local winSize=cc.Director:getInstance():getWinSize()
    self.m_loaderNode=cc.Node:create()
    self.m_loaderNode:setPosition(winSize.width/2,0)
    self.m_rootLayer:addChild(self.m_loaderNode)

    local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_view_shade.png")
    floorSpr:setPreferredSize(winSize)
    floorSpr:setPosition(0,winSize.height*0.5)
    self.m_loaderNode:addChild(floorSpr)

    local nPosX1,nPosX2=0,558
    local angleSpr1=cc.Sprite:createWithSpriteFrameName("general_view_shade_angle.png")
    angleSpr1:setAnchorPoint(cc.p(0,1))
    angleSpr1:setPosition(-winSize.width/2,nPosX2)
    self.m_loaderNode:addChild(angleSpr1)

    local angleSpr2=cc.Sprite:createWithSpriteFrameName("general_view_shade_angle.png")
    angleSpr2:setAnchorPoint(cc.p(0,1))
    angleSpr2:setPosition(winSize.width/2,nPosX2)
    angleSpr2:setScaleX(-1)
    self.m_loaderNode:addChild(angleSpr2)

    local angleSpr3=cc.Sprite:createWithSpriteFrameName("general_view_shade_angle.png")
    angleSpr3:setAnchorPoint(cc.p(0,1))
    angleSpr3:setPosition(-winSize.width/2,nPosX1)
    angleSpr3:setScaleY(-1)
    self.m_loaderNode:addChild(angleSpr3)

    local angleSpr4=cc.Sprite:createWithSpriteFrameName("general_view_shade_angle.png")
    angleSpr4:setAnchorPoint(cc.p(0,1))
    angleSpr4:setPosition(winSize.width/2,nPosX1)
    angleSpr4:setScale(-1)
    self.m_loaderNode:addChild(angleSpr4)

    local upFloorSpr=cc.Sprite:createWithSpriteFrameName("general_view_shade_up.png")
    upFloorSpr:setAnchorPoint(cc.p(0.5,1))
    upFloorSpr:setPosition(0,winSize.height)
    self.m_loaderNode:addChild(upFloorSpr)

    -- local downFloorSpr=cc.Sprite:createWithSpriteFrameName("general_view_shade_down.png")
    -- downFloorSpr:setAnchorPoint(cc.p(0.5,0))
    -- self.m_loaderNode:addChild(downFloorSpr)

    self.m_closeBtn=gc.CButton:create("general_view_close.png")
    self.m_closeBtn:setAnchorPoint(cc.p(1,1))
    self.m_closeBtn:setPosition(winSize.width+13,winSize.height+20)
    self.m_closeBtn:addTouchEventListener(c)
    self.m_closeBtn:enableSound()
    -- self.m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
    self.m_closeBtn:ignoreContentAdaptWithSize(false)
    self.m_closeBtn:setContentSize(cc.size(120,120)) 
    self.m_rootLayer:addChild(self.m_closeBtn,20)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_view_closebg.png")
    titleSpr:setAnchorPoint(cc.p(1,1))
    titleSpr:setPosition(winSize.width+2,winSize.height)
    self.m_rootLayer:addChild(titleSpr)
end
function NormalView.showSecondBg(self)
    if self.m_secondSpr~=nil then return end

    local secondSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    secondSpr:setPreferredSize(SecondSize)
    secondSpr:setPosition(0,280)
    self.m_loaderNode:addChild(secondSpr)

    self.m_secondSpr=secondSpr
    return secondSpr
end
function NormalView.getSecondSpr(self)
    if self.m_secondSpr==nil then
        self:showSecondBg()
    end
    return self.m_secondSpr
end
function NormalView.setSecondSize(self,_nSize)
    local subheight=SecondSize.height-_nSize.height
    local tempSpr=self:getSecondSpr()
    tempSpr:setPreferredSize(_nSize)
    tempSpr:setPosition(0,300+subheight*0.5)
end
function NormalView.showUpRightSpr(self,_width)
    if self.m_upRightSpr~=nil then
        self.m_upRightSpr:setVisible(true)
        return
    end
    local nSize=cc.size(_width or 128,24)
    self.m_upRightSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_input.png")
    self.m_upRightSpr:setPreferredSize(nSize)
    self.m_upRightSpr:setPosition(300,549)
    self.m_loaderNode:addChild(self.m_upRightSpr)
end
function NormalView.hideUpRightSpr(self)
    if self.m_upRightSpr~=nil then
        self.m_upRightSpr:setVisible(false)
    end
end
function NormalView.getUpRightSpr(self)
    if self.m_upRightSpr==nil then
        self:showUpRightSpr()
    end
    return self.m_upRightSpr
end
function NormalView.__createLabelTitle(self,_szName)
    self.m_labelTitle=_G.Util:createBorderLabel(_szName or "通 用",24)
    self.m_labelTitle:setPosition(0,567)
    self.m_labelTitle:enableOutline(cc.c4b(255,255,255,140),1)
    -- self.m_labelTitle:setTextColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    
    self.m_loaderNode:addChild(self.m_labelTitle)
end
function NormalView.__createSprTitle(self)
    self.m_sprTitle=cc.Sprite:create()
    self.m_sprTitle:setPosition(0,563)
    self.m_loaderNode:addChild(self.m_sprTitle)
end

function NormalView.addCloseFun(self,_fun)
	self.m_closeFun=_fun
end

function NormalView.setTitle(self,_szName)
    -- local frame=cc.SpriteFrameCache:getInstance():getSpriteFrame(_szName)
    -- if frame==nil then
    --     if self.m_labelTitle==nil then
    --         self:__createLabelTitle(_szName)
    --         return
    --     end
    --     self.m_labelTitle:setString(_szName)
    --     return
    -- end
    -- if self.m_sprTitle==nil then
    --     self:__createSprTitle()
    -- end

    -- self.m_sprTitle:setSpriteFrame(frame)
end

function NormalView.getCloseBtn(self)
    return self.m_closeBtn
end

function NormalView.getFrameSize(self)
    return FrameSize
end
function NormalView.getSecondSize(self)
    return SecondSize
end

function NormalView.getMainNode(self)
    return self.m_loaderNode
end

function NormalView.hideCloseBtn(self)
    self.m_closeBtn:setVisible(false)
end
function NormalView.showCloseBtn(self)
    self.m_closeBtn:setVisible(true)
end

return NormalView
