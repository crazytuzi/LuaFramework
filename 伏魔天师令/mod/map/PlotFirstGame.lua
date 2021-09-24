local PlotFirstGameMediator=classGc(mediator, function(self, _view)
    self.name = "PlotFirstGameMediator"
    self.view = _view
    self:regSelf()
end)
PlotFirstGameMediator.protocolsList={
	
}
PlotFirstGameMediator.commandsList={
	CKeyBoardCommand.TYPE,
	CGotoSceneCommand.TYPE,
	CPlotCommand.TYPE
}
function PlotFirstGameMediator.processCommand(self, _command)
	if _command:getType()==CKeyBoardCommand.TYPE then
		self.view:clickSkillBtnCall(_command.skillId)
	elseif _command:getType()==CGotoSceneCommand.TYPE then
		if _G.GJoyStick then
			_G.GJoyStick:setVisible(true)
			if _G.GJoyStick:getChildByTag(100886) then
				_G.GJoyStick:removeChildByTag(100886)
			end
		end
	elseif _command:getType()==CPlotCommand.TYPE then
		if _command:getData()==CPlotCommand.START then
			self.view:plotStart()
		elseif _command:getData()==CPlotCommand.FINISH then
			self.view:plotFinish(_command.id)
		end
	end
    return false
end

local SKILL_ARRAY=_G.Cfg.firstGameUseSkill

local PlotFirstGame=classGc(function(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_movePos=cc.p(600,100)

	self.m_stageView=_G.g_Stage
	self.m_joyStick=self.m_stageView.m_joyStick
	self.m_keyBoard=self.m_stageView.m_keyBoard
	self.m_mainPlayer=self.m_stageView:getMainPlayer()
	self.m_checkPoint=1
	self.m_mountSkillID=_G.Cfg.firstGameUseSkill.mount_skill


	if self.m_joyStick==nil then
		CCMessageBox("找不到摇杆","ERROR")
		return
	elseif self.m_keyBoard==nil then
		CCMessageBox("找不到技能按钮","ERROR")
		return
	end

	self.m_myPro=_G.GPropertyProxy:getMainPlay():getPro()
	self.m_mediator=PlotFirstGameMediator(self)

	local invBuff=_G.GBuffManager:getBuffNewObject(2398,0)
	self.m_mainPlayer:addBuff(invBuff)
	self.m_mainPlayer.m_nMaxHP=self.m_mainPlayer.m_nMaxHP+20000
	self.m_mainPlayer:setHP(self.m_mainPlayer.m_nHP+20000)
	self:__cancelDodgeHandle()

	local equipSkill=SKILL_ARRAY[self.m_myPro]
	-- if not equipSkill then
	-- 	equipSkill={}
	-- 	local playerInitCnf=_G.Cfg.player_init[self.m_myPro]
	-- 	for i=1,4 do
	-- 		equipSkill[i]=playerInitCnf.skill_learn[i]
	-- 	end
	-- 	SKILL_ARRAY[self.m_myPro]=equipSkill
	-- end
	for i=1,#equipSkill do
		self.m_keyBoard:addSkillButton(equipSkill[i],i)
	end

	self.m_bigSkillID=_G.Cfg.player_init[self.m_myPro].big_skill
end)

function PlotFirstGame.startPlot(self)
	self.m_mainNode=cc.Node:create()
	self.m_stageView:getScene():addChild(self.m_mainNode,500)

	self.m_touchStatic=false
	local function onTouchBegan()
		return self.m_touchStatic
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    self.m_mainNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_mainNode)

	local function nPlotEnd()
		-- self:__initGuide()
		self:__gotoGuideNotic()
	end

	-- 开场剧情
	local plotData=self.m_stageView:checkMapPlot(_G.Const.CONST_DRAMA_GETINTO)
	if plotData then
		local function nFun()
			self.m_stageView:runMapPlot(plotData,nPlotEnd)
		end

		self:__initGuide()
		self:__delayToDo(3,nFun)
	else
		self:__initGuide()
		local function nFun()
			self:__gotoGuideNotic()
		end
		self:__delayToDo(1,nFun)
	end
end






function PlotFirstGame.__initGuide(self)
	print("__initGuide=======>>>>")

	self:__hideKeyBoard()
	self:__hideJoyStick()
	-- self:__hideMonster()
end
function PlotFirstGame.__delayToDo(self,_times,_nFun)
	local nAction=cc.Sequence:create(cc.DelayTime:create(_times),cc.CallFunc:create(_nFun))
	self.m_mainNode:runAction(nAction)
end

function PlotFirstGame.__hideKeyBoard(self)
    self.m_keyBoard:cancelAttack()
	if self.m_keyBoard.m_btnBigSkill~=nil then
		self.m_keyBoard.m_btnBigSkill:setVisible(false)
	end
	if self.m_keyBoard.m_btnAttack~=nil then
		self.m_keyBoard.m_btnAttack:setVisible(false)
	end
	for _,btn in pairs(self.m_keyBoard.m_btnSkill) do
		btn:setVisible(false)
	end
end
function PlotFirstGame.__showKeyBoard(self)
	if self.m_keyBoard.m_btnBigSkill~=nil then
		self.m_keyBoard.m_btnBigSkill:setVisible(true)
	end
	if self.m_keyBoard.m_btnAttack~=nil then
		self.m_keyBoard.m_btnAttack:setVisible(true)
	end
	for _,btn in pairs(self.m_keyBoard.m_btnSkill) do
		btn:setVisible(true)
	end
end
function PlotFirstGame.__hideJoyStick(self)
	self.m_joyStick:setVisible(false)
end
function PlotFirstGame.__showJoyStick(self)
	self.m_joyStick:setVisible(true)
end
function PlotFirstGame.__hideMonster(self)
	self.m_stageView:setCharacterVisible(false)
	self.m_mainPlayer:getContainer():setVisible(true)
end
function PlotFirstGame.__showMonster(self,_AI)
	self.m_stageView:setCharacterVisible(true,_AI)
end
function PlotFirstGame.__cancelDodgeHandle(self)
	if self.m_playerDodgeFun then return end
	self.m_playerDodgeFun=self.m_mainPlayer.dodge
	self.m_mainPlayer.dodge=function() end
end
function PlotFirstGame.__startDodgeHandle(self)
	if not self.m_playerDodgeFun then return end
	self.m_mainPlayer.dodge=self.m_playerDodgeFun
end

-- 操作指引
function PlotFirstGame.__gotoGuideNotic(self)
	local noticNode=cc.LayerColor:create(cc.c4b(0,0,0,0))
	noticNode:setScaleY(0.01)
	self.m_mainNode:addChild(noticNode)

	local guideSpr=cc.Sprite:create("ui/bg/guide_notic.png")
	local guideSize=guideSpr:getContentSize()
	guideSpr:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5 - 40)
	guideSpr:setOpacity(0)

	if self.m_winSize.width<960 then
		guideSpr:setScale(1.4)
	else
		guideSpr:setScale(2)
	end
	noticNode:addChild(guideSpr)

	local function nFun1()
    	noticNode:removeFromParent(true)
    	self:__gotoMovePlot()
    end

    local isClose=false
	local function onTouchBegan()
		if isClose then
			isClose=false
			noticNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1,0.01),
    												cc.CallFunc:create(nFun1)))
		end
		return true
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    noticNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,noticNode)

    
    local function c(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
    		sender:removeFromParent(true)
    		
    	end
    end

    local noticLabel=_G.Util:createLabel("点击屏幕继续游戏",40)
    noticLabel:setPosition(self.m_winSize.width*0.5,90)
    noticLabel:setOpacity(0)
    noticLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    noticNode:addChild(noticLabel,10)

    local function nFun2()
    	guideSpr:runAction(cc.FadeTo:create(0.2,255))
    end
    local function nFun5()
    	local act=cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,155),cc.FadeTo:create(0.5,255)))
    	noticLabel:runAction(cc.FadeTo:create(0.2,255))
    	noticLabel:runAction(act)
		isClose=true
    end
    noticNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1),
    										cc.CallFunc:create(nFun2),
    										cc.DelayTime:create(0.5),
    										cc.CallFunc:create(nFun5)))
    noticNode:runAction(cc.FadeTo:create(0.3,150))
end

-- 移动引导
function PlotFirstGame.__gotoMovePlot(self)
	self:__showJoyStick()

	local movePos=self.m_movePos
	local moveSpr=cc.Sprite:create("icon/guide_quan.png")
	local moveSprSize=moveSpr:getContentSize()
	moveSpr:setPosition(movePos)
	self.m_stageView.m_lpCharacterContainer:addChild(moveSpr,-movePos.y)

	local act=cc.MoveBy:create(0.3,cc.p(0,20))
	local nAction=cc.RepeatForever:create(cc.Sequence:create(act,act:reverse()))
	local moveEffectSpr=cc.Sprite:createWithSpriteFrameName("general_tip_down.png")
	local effectSize=moveEffectSpr:getContentSize()
	moveEffectSpr:setPosition(cc.p(moveSprSize.width*0.5,moveSprSize.height*0.5+effectSize.height*0.5))
	moveEffectSpr:runAction(nAction)
	moveEffectSpr:setRotation(90)
	moveSpr:addChild(moveEffectSpr,10)

	local tempPos=cc.p(-25,effectSize.height*0.5)
	local nSpr=cc.Sprite:createWithSpriteFrameName("general_fram_bagbg.png")
	local nSprSize=nSpr:getContentSize()
	nSpr:setScaleX(0.4)
	nSpr:setScaleY(1.1)
	nSpr:setPosition(tempPos)
	nSpr:setRotation(-90)
	moveEffectSpr:addChild(nSpr)

	local moveLabel=_G.Util:createLabel("移动到这里",18)
	moveLabel:setPosition(tempPos)
	moveLabel:setRotation(-90)
	moveEffectSpr:addChild(moveLabel)

	local joySize=self.m_joyStick:getContentSize()
	nAction=cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1,cc.p(60,0)),
														cc.DelayTime:create(0.6),
														cc.MoveBy:create(0.1,cc.p(-60,0))))
	self.m_handSpr=cc.Sprite:create("icon/guide_hand.png")
	local handSize=self.m_handSpr:getContentSize()
	self.m_handSpr:setAnchorPoint(cc.p(1,1))
	self.m_handSpr:setPosition(10+joySize.width*0.5,-10+joySize.height*0.5)
	self.m_handSpr:runAction(nAction)
	self.m_handSpr:setTag(100886)
	self.m_joyStick:addChild(self.m_handSpr)

	local function nDelayFun()
		-- self:__gotoNormalSkillGuide()
		local invBuff=_G.GBuffManager:getBuffNewObject(2331,0)
		self.m_mainPlayer:addBuff(invBuff)

		local function nFun1()
			self.m_stageView.m_plotManager=self.m_stageView.m_plotManager or require("mod.map.PlotManager")()
			local plotData=self.m_stageView.m_plotManager:checkPlot(_G.Const.CONST_DRAMA_TRIGGER,10005)
			if plotData then
				self.m_stageView.m_plotManager:runThisPlot(plotData)
			end
		end

		local function nFun2()
			self.m_mainPlayer.setMoveClipContainerScalex=self.m_setMoveClipContainerScalex
			self.m_mainPlayer:setMoveClipContainerScalex(-1)
			local invBuff=_G.GBuffManager:getBuffNewObject(2332,0)
			self.m_mainPlayer:addBuff(invBuff)

			self:__delayToDo(1,nFun1)
		end
		self:__delayToDo(2.2,nFun2)
	end
	local function nFun()
		-- self.m_stageView:addFirstPointMonster()
		-- self:__showMonster(0)
		local myPosX,myPosY=self.m_mainPlayer:getLocationXY()
		local moveToPos={x=movePos.x+1,y=movePos.y-30}
		local absY=math.abs(moveToPos.y-myPosY)
		local absX=math.abs(moveToPos.x-myPosX)

		if absY<30 and absX<30 then
			self.m_mainPlayer.m_nextScalex=1
			nDelayFun()
			return
		end

		local xSpeed=370
		local ySpeed=250
		local xTimes=math.abs(myPosX-moveToPos.x)/xSpeed
		local yTimes=math.abs(myPosY-moveToPos.y)/ySpeed
		local delayTimes=((xTimes>yTimes) and xTimes or yTimes)+0.5

		self.m_mainPlayer:setMovePos(moveToPos)
		self.m_mainPlayer.m_nextScalex=1

		self:__delayToDo(delayTimes+0.3,nDelayFun)
	end

	local isRemoveHand=false
	local function nMoveFun()
		local myPosX,myPosY=self.m_mainPlayer:getLocationXY()
		if myPosX>=movePos.x then
			moveSpr:removeFromParent(true)
			self:__removeMoveSchedule()
			self:__delayToDo(0.2,nFun)
			self.m_joyStick:setTouchEnabled(false)

			self.m_mainPlayer:setMoveClipContainerScalex(1)
			self.m_setMoveClipContainerScalex=self.m_mainPlayer.setMoveClipContainerScalex
			self.m_mainPlayer.setMoveClipContainerScalex=function() end
		end
		if self.m_mainPlayer.m_lpMovePos~=nil then
			if self.m_handSpr~=nil and not isRemoveHand then
				local function nFun(_node)
					self.m_handSpr:removeFromParent(true)
					self.m_handSpr=nil
				end
				isRemoveHand=true
				self.m_handSpr:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(nFun)))
			end
		end
	end
	self.m_moveSchedule=_G.Scheduler:schedule(nMoveFun,0.02)

	-- self.m_mainPlayer:setLocationXY(400,160)
end
function PlotFirstGame.__removeMoveSchedule(self)
	if self.m_moveSchedule then
		_G.Scheduler:unschedule(self.m_moveSchedule)
		self.m_moveSchedule=nil
	end
end

function PlotFirstGame.__pauseMonster(self)
	-- cc.Director:getInstance():pause()
	-- self.m_stageView.m_lpContainer:pauseDraw()

	for k,v in pairs(_G.CharacterManager.m_lpCharacterArray) do
		if v.m_lpMovieClip then
			v.m_lpMovieClip:setTimeScale(0)
		end
	end

	self.m_stageView:removeFrameCallBack()
	-- cc.Director:getInstance():getEventDispatcher():setEnabled(true)
end
function PlotFirstGame.__resumeMonster(self)
	-- cc.Director:getInstance():resume()
	-- self.m_stageView.m_lpContainer:resumeDraw()
	for k,v in pairs(_G.CharacterManager.m_lpCharacterArray) do
		if v.m_lpMovieClip then
			v.m_lpMovieClip:setTimeScale(1)
		end
	end

	self.m_stageView:registerEnterFrameCallBack()
	-- cc.Director:getInstance():getEventDispatcher():setEnabled(false)
end

function PlotFirstGame.__gotoNormalSkillGuide(self)
	self:__showKeyBoard()

	-- local skillBtn=self.m_keyBoard.m_btnAttack
	-- self:__addSkillNotic("点击此处杀出重围!",skillBtn,false)

	self.m_mainPlayer.setMoveClipContainerScalex=self.m_setMoveClipContainerScalex

	self:__showSkillGuide()
end


local SKILL_NOTIC={
	"释放技能，杀出重围",
	"连招技能，合理搭配",
	"瞄准时机，弱点打击",
	"风云变色，一击必杀"
}
function PlotFirstGame.__showSkillGuide(self)
	print("__showSkillGuide========>>>>",self.m_curGuideSkillPos)
	if not self.m_curGuideSkillPos then
		self.m_curGuideSkillPos=0
		self.m_mainPlayer.__onAnimationCompleted=self.m_mainPlayer.onAnimationCompleted
		self.m_mainPlayer.onAnimationCompleted=function(_character,_eventType,_animationName)
			_character:__onAnimationCompleted(_eventType,_animationName)
			local animationName=string.gsub(_animationName , "skill_(%d+)", "%1")
		    local nSkillID=tonumber(animationName)
		    if nSkillID~=nil then
		    	self:__showSkillGuide()
		    end
		end

		_G.Util:playAudioEffect("sys_even")
	end
	self.m_curGuideSkillPos=self.m_curGuideSkillPos+1

	local delayTimes=0.5
	-- if self.m_curGuideSkillPos>#SKILL_ARRAY[self.m_myPro] then
	if self.m_curGuideSkillPos>=2 then

		self.m_joyStick:setTouchEnabled(true)

		self:__showMonster()
		self.m_touchStatic=false
		self.m_mainPlayer.onAnimationCompleted=__onAnimationCompleted
		self.m_mainPlayer.__onAnimationCompleted=false

		self.m_curGuideSkillPos=nil
		if _G.CharacterManager:isMonsterEmpty() then
			self:autoGoNextCheckPoint()
		end
		return
	elseif self.m_curGuideSkillPos~=1 then
		-- 暂停
		self:__pauseMonster()
	else
		-- 第一个技能
		self.m_touchStatic=true
		delayTimes=1
	end

	local function nFun()
		self.m_touchStatic=false
	end
	self:__delayToDo(delayTimes,nFun)

	local skillBtn=self.m_keyBoard.m_btnSkill[self.m_curGuideSkillPos]
	self:__addSkillNotic(SKILL_NOTIC[self.m_curGuideSkillPos],skillBtn,true)
	self.m_touchSkillId=SKILL_ARRAY[self.m_myPro][self.m_curGuideSkillPos]
end

function PlotFirstGame.__showBigSkillGuide(self)
	if not self.m_keyBoard.m_btnBigSkill then
		self.m_keyBoard:addBigButton(self.m_bigSkillID)
		self.m_mainPlayer:setMP(100)
	else
		self.m_keyBoard.m_btnBigSkill:setVisible(true)
	end

	self.m_mainPlayer:setMoveClipContainerScalex(1)

	local skillBtn=self.m_keyBoard.m_btnBigSkill
	self:__addSkillNotic("释放大招，速战速决",skillBtn,true)

	self.m_touchSkillId=self.m_bigSkillID

	self.m_stageView:cancelJoyStickTouch()

	self.m_plotFinishPlayAudio="sys_finalskill"

	self.m_isPlotFinishStopMonster=true
	self.m_isWaitAddMonster=true
end

function PlotFirstGame.__showMountSkillGuide(self)
	-- 指引坐骑技能
	if self.m_stageView.m_isPassWar then return end

	self.m_keyBoard:addMountSkillButton(self.m_mountSkillID)

	local skillBtn=self.m_keyBoard.m_btnMountSkill
	self:__addSkillNotic("对付镇元子唯有使用绝技了",skillBtn,true)

	self.m_touchSkillId=self.m_keyBoard.skillIds[skillBtn:getTag()]

	self.m_stageView:cancelJoyStickTouch()

	self.m_plotFinishPlayAudio="sys_mountskill"

	-- 强行加入剧情
	self.m_stageView.m_plotManager=self.m_stageView.m_plotManager or require("mod.map.PlotManager")()
	local plotData=self.m_stageView.m_plotManager:checkPlot(_G.Const.CONST_DRAMA_TRIGGER,222)
	if plotData then
		self.m_stageView.m_plotManager:runThisPlot(plotData)
	end

	self.m_isPlotFinishStopMonster=true
	self.m_isWaitAddMonster=true
end

function PlotFirstGame.__handlerAfterBigSkill(self)
	local function delayFun()
		self.m_touchStatic=false
		self.m_mainPlayer.setHP=function() end
		self:__showMountSkillGuide()
	end

	local isGuide=false
	local function tempFun()
		if isGuide then return end
		isGuide=true

		self.m_touchStatic=true
		self:__showMonster(0)
		self:__delayToDo(1,delayFun)
	end

	local limitHp=self.m_mainPlayer:getMaxHp()*0.05
	self.m_mainPlayer.__setHp=self.m_mainPlayer.setHP
	self.m_mainPlayer.setHP=function(_character,_nHP,_noEffect)
		print("CCCCCCCCCSQQQQQQ====>>>",_nHP)
		if _nHP<limitHp then
			_nHP=limitHp
			_character:__setHp(_nHP,_noEffect)
			-- tempFun()
		else
			_character:__setHp(_nHP,_noEffect)
		end
	end

	-- self.m_mainNode:runAction(cc.Sequence:create(cc.DelayTime:create(20),cc.CallFunc:create(tempFun)))	
end

function PlotFirstGame.autoGoNextCheckPoint(self)
	if self.m_isAutoGoNextCheckPoint or self.m_curGuideSkillPos~=nil then return end

	self.m_isAutoGoNextCheckPoint=true

	print("autoGoNextCheckPoint=====>>>>  1")
	self.m_touchStatic=true
	self.m_mainPlayer.m_nNextSkillID=nil
	self.m_stageView:cancelJoyStickTouch()
	self.m_mainPlayer:cancelMove()
	self:__hideJoyStick()
	self:__hideKeyBoard()

	local function nFun2()
		self.m_mainPlayer:setMovePos({x=1300,y=120})

		local tempScheduler=nil
		local function nttFun()
			if not self.m_mainPlayer.m_lpMovePos then
				self.m_isAAAAAAAA=false
				_G.Scheduler:unschedule(tempScheduler)
				print("autoGoNextCheckPoint=====>>>>  4")
			end
		end
		tempScheduler=_G.Scheduler:schedule(nttFun,0.05)
		print("autoGoNextCheckPoint=====>>>>  3")
	end

	local function nFun()
		self.m_playerSpeed={x=self.m_mainPlayer.m_nMoveSpeedX,y=self.m_mainPlayer.m_nMoveSpeedY}
		self.m_mainPlayer.m_nMoveSpeedX=self.m_mainPlayer.m_nMoveSpeedX*1.5
		self.m_mainPlayer.m_nMoveSpeedY=self.m_mainPlayer.m_nMoveSpeedY*1.5
		-- self.m_mainPlayer:setMovePos({x=2340,y=120})

		self.m_isAAAAAAAA=true
		self:__delayToDo(0.2,nFun2)
		print("autoGoNextCheckPoint=====>>>>  2")
	end

	if self.m_mainPlayer:getStatus()==_G.Const.CONST_BATTLE_STATUS_USESKILL then
		self.m_mainPlayer.__setStatus=self.m_mainPlayer.setStatus
		self.m_mainPlayer.setStatus=function(_character, _nStatus, _isReset)
			self.m_mainPlayer:__setStatus(_nStatus,_isReset)

			if self.m_mainPlayer:getStatus()==_G.Const.CONST_BATTLE_STATUS_IDLE then
				self.m_mainPlayer.setStatus=self.m_mainPlayer.__setStatus
				self.m_mainPlayer.__setStatus=false
				nFun()
			end
		end
	else
		nFun()
	end
end

function PlotFirstGame.gotoNextCheckPoint(self)
	self.m_checkPoint=self.m_checkPoint+1

	if self.m_checkPoint~=2 then return end

	-- local rxLimit=self.m_preMaprx
	-- self.m_stageView.m_nMaprx=rxLimit
	-- self.m_stageView.m_nMapViewrx=rxLimit

	self:__showBigSkillGuide()
	self:__showJoyStick()
	self:__showKeyBoard()

	if self.m_playerSpeed then
		self.m_mainPlayer.m_nMoveSpeedX=self.m_playerSpeed.x
		self.m_mainPlayer.m_nMoveSpeedY=self.m_playerSpeed.y
		self.m_playerSpeed=nil
	end

	self.m_isWaitAddMonster=true
	self.m_touchStatic=false
end
function PlotFirstGame.addMonsterEnd(self)
	if not self.m_isWaitAddMonster then return end

	-- local monsterArray=_G.CharacterManager.m_lpMonsterArray
	-- local invBuff=_G.GBuffManager:getBuffNewObject(406,0)

	-- for k,v in pairs(monsterArray) do
 --    	v:addBuff(invBuff)
	-- end

	self:__showMonster(0)

	self.m_isWaitAddMonster=nil
end

function PlotFirstGame.__addSkillNotic(self,_szContent,_skillBtn,_isSkill)
	self:__removeSkillNotic()

	local btnSize=_skillBtn:getContentSize()
	local worldPos,parent
	parent=self.m_mainNode
	worldPos=_skillBtn:getWorldPosition()

	local noticNode=_G.GGuideManager:createNoticNode(_szContent,true)
    parent:addChild(noticNode,10)

    local addPos=cc.p(worldPos.x-90,worldPos.y-90)
    if _isSkill then
    	addPos=cc.p(worldPos.x-200,worldPos.y)
    else
    	addPos=cc.p(worldPos.x-215,worldPos.y)
    end
    addPos.y=addPos.y<80 and 80 or addPos.y
    noticNode:setPosition(addPos)

	local act=cc.MoveBy:create(0.3,cc.p(20,-20))
	local nAction=cc.RepeatForever:create(cc.Sequence:create(act,act:reverse()))
	local skillHandSpr=cc.Sprite:create("icon/guide_hand.png")
	local handSize=skillHandSpr:getContentSize()
	skillHandSpr:setScaleX(-1)
	skillHandSpr:setPosition(worldPos.x+handSize.width*0.5-10,worldPos.y-handSize.width*0.5+5)
	skillHandSpr:runAction(nAction)
	parent:addChild(skillHandSpr,10)

    local animate=_G.AnimationUtil:getSkillBtnFinishAnimate()
	local effSpr=cc.Sprite:create()
	effSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(animate,cc.Hide:create(),cc.DelayTime:create(1),cc.Show:create())))
	effSpr:setPosition(worldPos.x-7,worldPos.y+8)
	parent:addChild(effSpr)

	self.m_skillNoticSpr=noticNode
	self.m_skillHandSpr=skillHandSpr
	self.m_skillEffectSpr=effSpr

	if _isSkill then
		self:__showMaskingLayer(btnSize.width*0.5-13,cc.p(worldPos.x-2,worldPos.y+2))
	else
		self:__showMaskingLayer(btnSize.width*0.5-11,cc.p(worldPos.x-5,worldPos.y+8),true)
	end
end
function PlotFirstGame.__removeSkillNotic(self)
	if self.m_skillNoticSpr~=nil then
		self.m_skillNoticSpr:removeFromParent(true)
		self.m_skillNoticSpr=nil
	end
	if self.m_skillHandSpr~=nil then
		self.m_skillHandSpr:removeFromParent(true)
		self.m_skillHandSpr=nil
	end
	if self.m_skillEffectSpr~=nil then
		self.m_skillEffectSpr:removeFromParent(true)
		self.m_skillEffectSpr=nil
	end
end

function PlotFirstGame.clickSkillBtnCall(self,_skillId)
	if _skillId==nil or self.m_touchSkillId==nil then return end

	print("clickSkillBtnCall=====>>>>",_skillId,self.m_touchSkillId)
	if self.m_touchSkillId==_skillId then
		self.m_touchSkillId=nil
		
		self:__removeSkillNotic()
		self:__hideMaskingLayer()
		if _skillId~=self.m_mountSkillID then
			if _skillId==self.m_bigSkillID then
				self:__handlerAfterBigSkill()
				self:__showMonster()
			else
				self:__resumeMonster()
				self.m_touchStatic=true
			end
		else
			self:__showMonster()
		end
	end
end

function PlotFirstGame.__showMaskingLayer(self,_radius,_pos,_isWinSizeTouch)
	local clipNode=cc.ClippingNode:create()
	clipNode:setInverted(true)
	self.m_mainNode:addChild(clipNode)

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
		if _isWinSizeTouch then
			self:__hideMaskingLayer()
			self:__removeSkillNotic()
			self:__showSkillGuide()
			return true
		end
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
function PlotFirstGame.__hideMaskingLayer(self)
	if self.m_maskingNode==nil then return end

	local clipNode=self.m_maskingNode
	self.m_maskingNode=nil
	local function nFun()
		clipNode:removeFromParent(true)
	end
	local pLayer=clipNode:getChildByTag(166)
	if pLayer==nil then
		nFun()
	else
		pLayer:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,0),cc.CallFunc:create(nFun)))
	end
end

-- 躲避指引
function PlotFirstGame.__showDodgeGuide(self)
	local function nFun()
		if self.m_dodgeNode then
			self.m_dodgeNode:removeFromParent(true)
			self.m_dodgeNode=nil
		end
	end

	self.m_mainPlayer:setMoveClipContainerScalex(1)
	self.m_joyStick:setTouchEnabled(true)
	self:__startDodgeHandle()

	self.m_dodgeNode=cc.Node:create()
	self.m_mainNode:addChild(self.m_dodgeNode)

	self.m_setMovePos=self.m_mainPlayer.setMovePos
	self.m_mainPlayer.setMovePos=function()
		-- nFun()

		-- self.m_mainPlayer.setMovePos=self.m_setMovePos
	end

	self.m_dodge=self.m_mainPlayer.dodge
	self.m_mainPlayer.dodge=function(character,x,y)
		self.m_dodge(character,x,y)
		nFun()

		self.m_mainPlayer.setMovePos=self.m_setMovePos
		self.m_mainPlayer.dodge=self.m_dodge

		local monsterArray=_G.CharacterManager.m_lpMonsterArray
		for k,v in pairs(monsterArray) do
			if v.m_monsterId==11990 then
				v:useSkill(30620)
	    	end
		end

		local function nFun2()
			self.m_stageView:cancelJoyStickTouch()
			self.m_joyStick:setTouchEnabled(false)
		end
		self:__delayToDo(0.01,nFun2)

		local function nFun3()
			self.m_mainPlayer:setMoveClipContainerScalex(-1)
			self:__gotoNormalSkillGuide()
		end
		self:__delayToDo(2,nFun3)
	end

	local btnSize=cc.size(185,185)
	-- local worldPos=self.m_joyStick:getWorldPosition()
	local anchorPoint=self.m_joyStick:getAnchorPoint()
	local worldPos=self.m_joyStick:convertToWorldSpace(cc.p(btnSize.width*anchorPoint.x,btnSize.height*anchorPoint.y))

	local noticNode=_G.GGuideManager:createNoticNode("连续点击两下方向键进行闪避",false)
    self.m_dodgeNode:addChild(noticNode,10)
    noticNode:setPosition(worldPos.x+285,worldPos.y+20)

	local skillHandSpr=cc.Sprite:create("icon/guide_hand.png")
	local handSize=skillHandSpr:getContentSize()
	skillHandSpr:setScaleX(-1)
	skillHandSpr:setPosition(worldPos.x+handSize.width*0.5+85,worldPos.y-handSize.width*0.5-25)
	self.m_dodgeNode:addChild(skillHandSpr,10)

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
		self.m_dodgeNode:addChild(tempSpr)
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

	local tempSize=cc.size(90,55*2)
	local clipNode=cc.ClippingNode:create()
	clipNode:setInverted(true)
	self.m_dodgeNode:addChild(clipNode)

	local pLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
	pLayer:setTag(166)
	clipNode:addChild(pLayer)

	local nColor=cc.c4f(0,0,0,0)
	local lowX=tempPos.x-tempSize.width*0.5
	local lowY=tempPos.y-tempSize.height*0.5
	local highX=tempPos.x+tempSize.width*0.5
	local highY=tempPos.y+tempSize.height*0.5

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
end

function PlotFirstGame.plotStart(self)
	if self.m_maskingNode~=nil then
		self.m_maskingNode:setVisible(false)
	end
	if self.m_skillNoticSpr~=nil then
		self.m_skillNoticSpr:setVisible(false)
	end
	if self.m_skillHandSpr~=nil then
		self.m_skillHandSpr:setVisible(false)
	end
	if self.m_skillEffectSpr~=nil then
		self.m_skillEffectSpr:setVisible(false)
		self.m_skillEffectSpr:stopAllActions()
	end
end
function PlotFirstGame.plotFinish(self,_plotId)
	if self.m_maskingNode~=nil then
		self.m_maskingNode:setVisible(true)
	end
	if self.m_skillNoticSpr~=nil then
		self.m_skillNoticSpr:setVisible(true)
	end
	if self.m_skillHandSpr~=nil then
		self.m_skillHandSpr:setVisible(true)
	end
	if self.m_skillEffectSpr~=nil then
		self.m_skillEffectSpr:setVisible(true)
		local animate=_G.AnimationUtil:getSkillBtnFinishAnimate()
		self.m_skillEffectSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(animate,cc.Hide:create(),cc.DelayTime:create(1),cc.Show:create())))
	end
	if self.m_isPlotFinishStopMonster then
		self:__showMonster(0)
		self.m_isPlotFinishStopMonster=nil
	end

	print("CCCCCCCC========>>>",_plotId)
	if _plotId==10005 then
		local monsterArray=_G.CharacterManager.m_lpMonsterArray
		local invBuff=_G.GBuffManager:getBuffNewObject(2333,0)
		for k,v in pairs(monsterArray) do
			if v.m_monsterId==11991 or v.m_monsterId==11992 then
	    		v:addBuff(invBuff)
	    	end
		end
		
		local function nFun()
			self.m_stageView.m_plotManager=self.m_stageView.m_plotManager or require("mod.map.PlotManager")()
			local plotData=self.m_stageView.m_plotManager:checkPlot(_G.Const.CONST_DRAMA_TRIGGER,10006)
			if plotData then
				self.m_stageView.m_plotManager:runThisPlot(plotData)
			end
		end
		self:__delayToDo(1,nFun)
	elseif _plotId==10006 then
		self:__showDodgeGuide()
	elseif _plotId==1014 then
		-- 加属性
		self.m_mainPlayer:removeBuff(_G.Const.CONST_BATTLE_BUFF_ADD)
		local invBuff=_G.GBuffManager:getBuffNewObject(2399,0)
		self.m_mainPlayer:addBuff(invBuff)

		-- 无敌buff
		local invBuff=_G.GBuffManager:getBuffNewObject(499,0)
		self.m_mainPlayer:addBuff(invBuff)
	end

	if self.m_plotFinishPlayAudio then
		_G.Util:playAudioEffect(self.m_plotFinishPlayAudio)
		self.m_plotFinishPlayAudio=nil
	end
end

function PlotFirstGame.addBossNpc(self)
	local tempSpine=_G.SpineManager.createSpine("spine/20751",0.5)
	tempSpine:setAnimation(0,"idle",true)
	tempSpine:setPosition(1027,170)
	_G.g_Stage.m_lpCharacterContainer:addChild(tempSpine,-600)

	self.m_bossNpcSpine=tempSpine
end

return PlotFirstGame
