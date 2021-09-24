local PlotBigSkillMediator=classGc(mediator, function(self, _view)
    self.name = "PlotBigSkillMediator"
    self.view = _view
    self:regSelf()
end)
PlotBigSkillMediator.protocolsList={
	
}
PlotBigSkillMediator.commandsList={
	CKeyBoardCommand.TYPE,
}
function PlotBigSkillMediator.processCommand(self, _command)
	if _command:getType()==CKeyBoardCommand.TYPE then
		self.view:clickSkillBtnCall(_command.skillId)
	end
end

local PlotBigSkill=classGc(function(self)
	self:__initParment()

	self.m_mediator=PlotBigSkillMediator(self)
end)

function PlotBigSkill.__initParment(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()

	self.m_stageView=_G.g_Stage
	self.m_keyBoard=self.m_stageView.m_keyBoard
	self.m_mainPlayer=self.m_stageView:getMainPlayer()

	local myPro=self.m_mainPlayer:getPro()
	local playerInitCnf=_G.Cfg.player_init[myPro]
	self.m_bigSkillId=playerInitCnf.big_skill
end

function PlotBigSkill.startPlot(self)
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
    self:__initView()
end

function PlotBigSkill.__initView(self)
	self.m_bigSkillBtn=self.m_keyBoard:getBigButton()
	if self.m_bigSkillBtn==nil then
		self.m_keyBoard:addBigButton(self.m_bigSkillId)
		self.m_bigSkillBtn=self.m_keyBoard:getBigButton()
	end

	self.m_mainPlayer:addMP(100)
	self:__touchGuide()
end

function PlotBigSkill.__touchGuide(self)
	local btnSize=self.m_bigSkillBtn:getContentSize()
	local worldPos=self.m_bigSkillBtn:getWorldPosition()

	local noticNode=_G.GGuideManager:createNoticNode("别再隐忍了,搓这里随性一次吧!",true)
    self.m_rootLayer:addChild(noticNode,10)
    noticNode:setPosition(worldPos.x-200,worldPos.y)

	local act=cc.MoveBy:create(0.3,cc.p(20,-20))
	local nAction=cc.RepeatForever:create(cc.Sequence:create(act,act:reverse()))
	local skillHandSpr=cc.Sprite:create("icon/guide_hand.png")
	local handSize=skillHandSpr:getContentSize()
	skillHandSpr:setScaleX(-1)
	skillHandSpr:setPosition(worldPos.x+handSize.width*0.5-10,worldPos.y-handSize.width*0.5+5)
	skillHandSpr:runAction(nAction)
	self.m_rootLayer:addChild(skillHandSpr,10)

    local animate=_G.AnimationUtil:getSkillBtnFinishAnimate()
	local effSpr=cc.Sprite:create()
	effSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(animate,cc.Hide:create(),cc.DelayTime:create(1),cc.Show:create())))
	effSpr:setPosition(worldPos.x-7,worldPos.y+8)
	self.m_rootLayer:addChild(effSpr)

	-- tempSpr:runAction(cc.FadeTo:create(0.3,255))
	-- tempLabel:runAction(cc.FadeTo:create(0.3,255))
	self.m_skillNoticSpr=noticNode
	self.m_skillHandSpr=skillHandSpr
	self.m_skillEffectSpr=effSpr

	self:__showMaskingLayer(btnSize.width*0.5-13,cc.p(worldPos.x-2,worldPos.y+2))
end

function PlotBigSkill.__showMaskingLayer(self,_radius,_pos)
	local clipNode=cc.ClippingNode:create()
	clipNode:setInverted(true)
	self.m_rootLayer:addChild(clipNode)

	local pLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
	pLayer:setTag(166)
	clipNode:addChild(pLayer)

	local nColor=cc.c4f(0,0,0,0)
	local nCount=100
	local nAngle=2*math.pi/nCount
	local pointArray={}
	for i=1,nCount do
		local radian=i*nAngle
		pointArray[i]={x=_radius*math.cos(radian),y=_radius*math.sin(radian)}
	end
	local pDrawNode=cc.DrawNode:create()
	pDrawNode:drawPolygon(pointArray,nCount,nColor,0,nColor)
	pDrawNode:setPosition(_pos)
	clipNode:setStencil(pDrawNode)

	local function onTouchBegan(touch)
		local location=touch:getLocation()
		local distance=cc.pGetDistance(location,_pos)
		if distance<=_radius then
			-- print("onTouchBegan======>>> 穿透")
			return false
		end
		-- print("onTouchBegan======>>> 不穿透")
		return true
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    pLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,pLayer)
    pLayer:runAction(cc.FadeTo:create(0.2,150))

    self.m_maskingNode=clipNode
end

function PlotBigSkill.clickSkillBtnCall(self,_skillId)
	print("clickSkillBtnCall===========>>>>>>",_skillId,self.m_bigSkillId)
	if self.m_bigSkillId==_skillId then
		self.m_mediator:destroy()
		self.m_rootLayer:removeFromParent(true)
		self.m_rootLayer=nil

		self.m_stageView:setCharacterVisible(true)
		self.m_stageView:setStopAI(false)
		if self.m_isAutoFight==true then
			self.m_stageView:startAutoFight()
		end
	end
end

return PlotBigSkill

