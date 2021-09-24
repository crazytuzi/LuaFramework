local PlotDodge=classGc(function(self)
	self:__initParment()
end)

function PlotDodge.__initParment(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()

	self.m_stageView=_G.g_Stage
	self.m_mainPlayer=self.m_stageView:getMainPlayer()
end

function PlotDodge.__hookUpdate(self)
	for k,v in pairs(_G.CharacterManager.m_lpHookArray) do
		v.m_noUpdate=v.__preNoUpdate
	end
end
function PlotDodge.__unHookUpdate(self)
	for k,v in pairs(_G.CharacterManager.m_lpHookArray) do
		v.__preNoUpdate=v.m_noUpdate
		v.m_noUpdate=true
	end
end

function PlotDodge.startPlot(self)
	self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
	self.m_stageView:getScene():addChild(self.m_rootLayer,1200)

	-- local function onTouchBegan()
	-- 	return true
	-- end
 --    local listerner=cc.EventListenerTouchOneByOne:create()
 --    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
 --    listerner:setSwallowTouches(true)
 --    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

 	self.m_isAutoFight=self.m_stageView.isAutoFightMode
    self.m_stageView:setStopAI(true)
    self.m_stageView:stopAutoFight(true)
    self.m_stageView:setCharacterVisible(true,0)
    self:__unHookUpdate()
    self:__initView()
end

function PlotDodge.__initView(self)
	self.m_joyStick=self.m_stageView.m_joyStick

	self:__initPlayerDodgeListener()
	self:__touchGuide()
end

function PlotDodge.__initPlayerDodgeListener(self)
	self.m_setMovePos=self.m_mainPlayer.setMovePos
	self.m_mainPlayer.setMovePos=function()
		self:remove()
		self:__hookUpdate()
		
		self.m_stageView:setCharacterVisible(true)
		self.m_mainPlayer.setMovePos=self.m_setMovePos
	end

	self.m_dodge=self.m_mainPlayer.dodge
	self.m_mainPlayer.dodge=function(character,x,y)
		self.m_dodge(character,x,y)
		self:remove()

		self.m_mainPlayer.dodge=self.m_dodge
	end
end

function PlotDodge.__touchGuide(self)
	-- local btnSize=self.m_joyStick:getContentSize()
	local btnSize=cc.size(185,185)
	-- local worldPos=self.m_joyStick:getWorldPosition()
	local anchorPoint=self.m_joyStick:getAnchorPoint()
	local worldPos=self.m_joyStick:convertToWorldSpace(cc.p(btnSize.width*anchorPoint.x,btnSize.height*anchorPoint.y))

	local noticNode=_G.GGuideManager:createNoticNode("连续点击两下方向键进行闪避",false)
    self.m_rootLayer:addChild(noticNode,10)
    noticNode:setPosition(worldPos.x+285,worldPos.y+20)

	local skillHandSpr=cc.Sprite:create("icon/guide_hand.png")
	local handSize=skillHandSpr:getContentSize()
	skillHandSpr:setScaleX(-1)
	skillHandSpr:setPosition(worldPos.x+handSize.width*0.5+85,worldPos.y-handSize.width*0.5-25)
	self.m_rootLayer:addChild(skillHandSpr,10)

	local tempPos=cc.p(worldPos.x+70,worldPos.y+2)
	local function nFun_remove(_node)
		_node:removeFromParent(true)
	end
	local function nFun()
		local tempScale=0.5
		local tempSpr=cc.Sprite:createWithSpriteFrameName("general_guide_touch.png")
		tempSpr:setScale(tempScale)

		local nTimes=0.4
		local tempAction=cc.Sequence:create(cc.ScaleTo:create(nTimes*0.5,tempScale*2.2),cc.ScaleTo:create(nTimes*0.5,tempScale*3),cc.CallFunc:create(nFun_remove))
		tempSpr:runAction(tempAction)
		tempSpr:runAction(cc.FadeTo:create(nTimes,0))
		tempSpr:setPosition(tempPos)
		self.m_rootLayer:addChild(tempSpr)
	end

	local tempNum=30
	local tempTimes=0.3
	local act1=cc.DelayTime:create(1)
	local act2=cc.MoveBy:create(tempTimes,cc.p(-tempNum,tempNum))
	local act3=cc.CallFunc:create(nFun)
	local act4=cc.MoveBy:create(tempTimes*0.55,cc.p(tempNum*0.7,-tempNum*0.7))
	local act5=cc.MoveBy:create(tempTimes*0.55,cc.p(-tempNum*0.7,tempNum*0.7))
	local act6=cc.CallFunc:create(nFun)
	local act7=cc.MoveBy:create(tempTimes,cc.p(tempNum,-tempNum))
	local nAction=cc.RepeatForever:create(cc.Sequence:create(act1,act2,act3,act4,act5,act6,act7))
	skillHandSpr:runAction(nAction)

	self:__showMaskingRectangleLayer(tempPos,cc.size(90,55*2))
end

function PlotDodge.__removeMaskingLayer(self)
	if self.m_maskingNode~=nil then
		self.m_maskingNode:removeFromParent(true)
		self.m_maskingNode=nil
	end
end
function PlotDodge.__showMaskingRectangleLayer(self,_pos,_size)
	local function nFun()
		self:remove()
	end

	local clipNode=cc.ClippingNode:create()
	clipNode:setInverted(true)
	clipNode:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(nFun)))
	self.m_rootLayer:addChild(clipNode)

	local pLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
	pLayer:setTag(166)
	clipNode:addChild(pLayer)

	local nColor=cc.c4f(0,0,0,0)
	local lowX=_pos.x-_size.width*0.5
	local lowY=_pos.y-_size.height*0.5
	local highX=_pos.x+_size.width*0.5
	local highY=_pos.y+_size.height*0.5

	print("SSSSSSSSSSS=======>>>>",lowX,lowY,highX,highY)
	local pointArray={
		[1]={x=lowX,y=lowY},
		[2]={x=lowX,y=highY},
		[3]={x=highX,y=highY},
		[4]={x=highX,y=lowY},
		[5]={x=lowX,y=lowY},
	}

	local pDrawNode=cc.DrawNode:create()
	pDrawNode:drawPolygon(pointArray,#pointArray,nColor,0,nColor)
	clipNode:setStencil(pDrawNode)

	local function onTouchBegan(touch)
		local location=touch:getLocation()
		if (location.x>lowX and location.x<highX)
			and (location.y>lowY and location.y<highY) then
			print("onTouchBegan======>>> 穿透")
			return false
		else
			print("onTouchBegan======>>> 不穿透",location.x,location.y)
			return true
		end
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    pLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,pLayer)
    pLayer:runAction(cc.FadeTo:create(0.2,100))

    self.m_maskingNode=clipNode
end

function PlotDodge.remove(self)
	if self.m_rootLayer then
		self.m_rootLayer:removeFromParent(true)
		self.m_rootLayer=nil
	end
	self.m_maskingNode=nil
end
-- onGetAccessToken status error
return PlotDodge

