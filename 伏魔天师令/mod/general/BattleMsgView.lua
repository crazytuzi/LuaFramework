local BattleMsgView=classGc()

local m_winSize=cc.Director:getInstance():getWinSize()
local FrameSize=cc.size(640,350)
local SecondSize=cc.size(622,292)
local ThreeSize=cc.size(605,280)

function BattleMsgView.create(self, myName, _size, _floor)
    if self.m_rootLayer~=nil then return end
    if _size~=nil then
        self.oneSize=_size
        self.twoSize=cc.size(_size.width-18,_size.height-58)
        self.threeSize=cc.size(_size.width-17,_size.height-12)
    else
        self.oneSize=FrameSize
        self.twoSize=SecondSize
        self.threeSize=ThreeSize
    end
	local function onTouchBegan(touch,event) 
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(m_winSize.width/2-self.oneSize.width/2,m_winSize.height/2-self.oneSize.height/2,
        self.oneSize.width,self.oneSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end
        if self.m_closeFun~=nil then
             self.m_closeFun()
         end
        self:delayCallFun()
        return true
    end

    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:setTag(1313)
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    -- if isGray then
    --     local size = cc.Director:getInstance():getVisibleSize()
    --     local downDins = cc.LayerColor:create(cc.c4b(0,0,0,150))
    --     downDins       : setContentSize(size)
    --     --downDins       : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
    --     self.m_rootLayer: addChild(downDins,-1)
    -- end

    local ceng = 999
    if _floor ~= nil then
        ceng = _floor
    end

    local bgView = self:initView(myName)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rootLayer,ceng)
    return bgView
end

function BattleMsgView.delayCallFun( self )
    local function nFun()
        print("delayCallFun-----------------")
        -- if self.m_rootLayer~=nil then
            self.m_rootLayer:removeFromParent(true)
            -- self.m_rootLayer=nil
        -- end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.m_rootLayer:runAction(cc.Sequence:create(delay,func))
end

function BattleMsgView.initView(self,myName)
	-- local function c(sender,eventType)
 --    	if eventType == ccui.TouchEventType.ended then
 --    		if self.m_closeFun~=nil then
 --    			self.m_closeFun()
 --    		end
 --    		self.m_rootLayer:removeFromParent()
 --    	end
	-- end

    local winSize=cc.Director:getInstance():getWinSize()
    self.m_loaderNode=cc.Node:create()
    self.m_loaderNode:setPosition(winSize.width/2,0)
    self.m_rootLayer:addChild(self.m_loaderNode)

    local framePos=cc.p(0,312)
    local dinsSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    dinsSpr:setPreferredSize(self.oneSize)
    dinsSpr:setPosition(framePos)
    self.m_loaderNode:addChild(dinsSpr)

    local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    frameSpr:setPreferredSize(self.twoSize)
    frameSpr:setPosition(self.oneSize.width/2,self.oneSize.height/2-(self.oneSize.height-self.twoSize.height)/2+10)
    dinsSpr:addChild(frameSpr)

    self.m_labelTitle=_G.Util:createBorderLabel( myName or "战  报",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_labelTitle:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    self.m_labelTitle:setPosition(self.oneSize.width/2,self.oneSize.height-28)
    dinsSpr:addChild(self.m_labelTitle,10)

    -- self.m_closeBtn=gc.CButton:create("general_close.png")
    -- self.m_closeBtn:setPosition(winSize.width/2+self.oneSize.width*0.5-20,framePos.y+self.oneSize.height*0.5-20)
    -- self.m_closeBtn:addTouchEventListener(c)
    -- self.m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
    -- self.m_rootLayer:addChild(self.m_closeBtn,10)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(self.oneSize.width/2-135,self.oneSize.height-28)
    dinsSpr:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(self.oneSize.width/2+130,self.oneSize.height-28)
    titleSpr:setRotation(180)
    dinsSpr:addChild(titleSpr,9)

    return frameSpr
end

function BattleMsgView.addCloseFun(self,_fun)
	self.m_closeFun=_fun
end

function BattleMsgView.getSize(self)
	return self.threeSize
end

function BattleMsgView.closeWindow( self )
    self.m_rootLayer:removeFromParent()
end

return BattleMsgView
