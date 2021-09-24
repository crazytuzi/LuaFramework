local SubOpenFun=classGc(function(self,_data,_mainView)
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_viewSize=cc.size(500,260)
	self.m_openInfoCnf=_data
	self.m_mainView=_mainView
end)

function SubOpenFun.create(self)
	local function onTouchBegan()
		if self.m_isWaitTouch then
			self.m_isWaitTouch=nil
			self:__checkMainUIHide()
			if self.m_noticLabel~=nil then
				self.m_noticLabel:removeFromParent(true)
				self.m_noticLabel=nil
			end
			if self.m_openEffect~=nil then
				local function lFun(_node)
					_node:removeFromParent(true)
				end
				self.m_openEffect:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,0),cc.CallFunc:create(lFun)))
				self.m_openEffect=nil
			end
		end
		return true
	end

	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner:setSwallowTouches(true)

	self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
	self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

	self.m_mainNode=cc.Node:create()
	-- self.m_mainNode:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5)
	self.m_rootLayer:addChild(self.m_mainNode)
	self:__initSysIconMove()

	if self.m_mainIconBtn==nil then return self.m_rootLayer end

	local function nFun()
		self:__showIconEffect()
		_G.Util:playAudioEffect("ui_function_open")
	end
	local activityView=self.m_mainView:getIconActivity()
	if not self.m_mainView:isShowUI() then
		self.m_mainView:autoShowUI()
		self:__delayToDo(0.5,nFun)
	else
		nFun()
	end
	-- self.m_rootLayer:runAction(cc.Sequence:create(cc.FadeTo:create(0.3,155),cc.CallFunc:create(nFun)))

	return self.m_rootLayer
end

function SubOpenFun.__delayToDo(self,_times,_fun)
	self.m_rootLayer:runAction(cc.Sequence:create(cc.DelayTime:create(_times),cc.CallFunc:create(_fun)))
end
function SubOpenFun.__delayToFinish(self)
	local function nFun()
		self:__finish()
	end
	self:__delayToDo(0.5,nFun)
end

function SubOpenFun.__showIconEffect(self)
	self.m_openLabel:runAction(cc.FadeTo:create(0.3,0))

	local tempGafAsset=gaf.GAFAsset:create("gaf/gongnengbao.gaf")
	local tempObject=tempGafAsset:createObject()
	tempObject:setLooped(false,false)
	tempObject:start()
	self.m_openNode:addChild(tempObject,1000)

	self.m_openPos=cc.p(self.m_winSize.width*0.5,self.m_winSize.height*0.5)

	local function showNext()
		self:__addSureLabel()
	end
	local function nMoveEnd()
		local tempGafAsset=gaf.GAFAsset:create("gaf/gongnengfaguang.gaf")
		self.m_openEffect=tempGafAsset:createObject()
		self.m_openEffect:setLooped(true,false)
		self.m_openEffect:start()
		self.m_openEffect:setOpacity(0)
		self.m_openEffect:setPosition(self.m_openPos)
		self.m_rootLayer:addChild(self.m_openEffect)

		self.m_openEffect:runAction(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.DelayTime:create(0.5),cc.CallFunc:create(showNext)))
	end
	local function onFunc1()
		tempObject:removeFromParent(true)

		local nPosX,nPosY=self.m_openNode:getPosition()
		local distance=cc.pGetDistance(self.m_openPos,cc.p(nPosX,nPosY))
		local tempTime=distance*0.0015
		self.m_openNode:runAction(cc.Sequence:create(cc.MoveTo:create(tempTime,self.m_openPos),cc.CallFunc:create(nMoveEnd)))
	end
	local function onFunc2()
        tempObject:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,0),cc.CallFunc:create(onFunc1)))
    end
    tempObject:setAnimationFinishedPlayDelegate(onFunc2)
end

function SubOpenFun.__addSureLabel(self)
	self.m_noticLabel=_G.Util:createLabel("点击屏幕继续游戏",24)
	self.m_noticLabel:setPositionY(-70)
	self.m_mainNode:addChild(self.m_noticLabel)

	local act=cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,155),cc.FadeTo:create(0.5,255)))
	self.m_noticLabel:runAction(act)

	self.m_isWaitTouch=true
end

function SubOpenFun.__initSysIconMove(self)
	local sysBtn,isSystemBtn,isNormal=self.m_mainView:hideOpenIconBtn(self.m_openInfoCnf.open_id,self.m_openInfoCnf.parent_id)
	print("__initSysIconMove========>>>>>>>>>",sysBtn,isSystemBtn,isNormal)
	if sysBtn==nil then
		print("__initSysIconMove======>>>  sysBtn==nil")
		self:__delayToFinish()
		return
	end

	self.m_mainIconBtn=sysBtn
	self.m_isSystemBtn=isSystemBtn
	self.m_isMenuNormal=isNormal

	local activityView=self.m_mainView:getIconActivity()
	if activityView.m_openNode then
		if activityView.m_curOpenData.open_id~=self.m_openInfoCnf.open_id then
			activityView:clearOpenNode()
		else
			self.m_openNode=activityView.m_openNode
			self.m_openSpr=self.m_openNode:getChildByTag(101)
			self.m_openLabel=self.m_openNode:getChildByTag(102)

			self.m_openNode:retain()
			activityView:clearOpenNode()
			self.m_rootLayer:addChild(self.m_openNode,10)
			self.m_openNode:release()
		end
	end

	if not self.m_openNode then
		self.m_openNode=cc.Node:create()
		self.m_openNode:setPosition(activityView:getLeftBtnPos(4))
		self.m_rootLayer:addChild(self.m_openNode,10)

		self.m_openSpr=cc.Sprite:createWithSpriteFrameName(string.format("%s.png",self.m_openInfoCnf.open_effect))
		self.m_openNode:addChild(self.m_openSpr)

		self.m_openLabel=_G.Util:createBorderLabel(string.format("%d级开启",self.m_openInfoCnf.open_lv),20)
	    self.m_openLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	    self.m_openNode:addChild(self.m_openLabel)
	end
end
function SubOpenFun.__checkMainUIHide(self)
	local function showMove()
		self:__showSysIconMove()
	end

	if self.m_isSystemBtn then
		local systemView=self.m_mainView:getIconSystem()
		if self.m_isMenuNormal==systemView:isMenuChuange() then
			systemView:showMenuAuto()
			self:__delayToDo(0.5,showMove)
		else
			showMove()
		end
	else
		local activityView=self.m_mainView:getIconActivity()
		if not self.m_mainView:isShowUI() then
			self.m_mainView:autoShowUI()
			self:__delayToDo(0.5,showMove)
		else
			showMove()
		end
	end
end
function SubOpenFun.__showSysIconMove(self)
	print("__showSysIconMove=====>>>>")
	local iconBtnSize=self.m_mainIconBtn:getContentSize()
	local worldPos=self.m_mainIconBtn:convertToWorldSpace(cc.p(0.5,0.5))
	worldPos=cc.p(worldPos.x+iconBtnSize.width*0.5,worldPos.y+iconBtnSize.height*0.5)
	local distance=cc.pGetDistance(self.m_openPos,worldPos)
	local tempTime=distance*0.0015

	local subX=worldPos.x-self.m_openPos.x
	local subY=worldPos.y-self.m_openPos.y
	subX=subX==0 and 0.01 or subX
	local tan=math.atan(math.abs(subY/subX))*180/math.pi
	local angle
	if subX>0 and subY>0 then
		angle=-tan
	elseif subX>0 and subY<0 then
		angle=tan
	elseif subX<0 and subY>0 then
		angle=tan-180
	else
		angle=180-tan
	end
	print("CCCCCCCCCCCCCCCC=======>>>>",tan,angle)
	-- moveIcon:setRotation(angle)

	local tempGafAsset=gaf.GAFAsset:create("gaf/gongnengtuowei.gaf")
	local tempObject=tempGafAsset:createObject()
	tempObject:setLooped(true,false)
	tempObject:start()
	tempObject:setOpacity(0)
	tempObject:runAction(cc.FadeTo:create(0.3,255))
	tempObject:setRotation(angle)
	self.m_openNode:addChild(tempObject,-10)

	local function nFun1()
		local function lFun1()
			self.m_mainIconBtn:setVisible(true)
		    self.m_mainIconBtn:setOpacity(0)
		    self.m_mainIconBtn:runAction(cc.FadeTo:create(0.2,255))
		end
		local function lFun2()
			self:__finish()
		end
		self.m_openSpr:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(lFun1),cc.FadeTo:create(0.4,0),cc.CallFunc:create(lFun2)))
		tempObject:runAction(cc.FadeTo:create(0.2,0))
	end
	self.m_openNode:runAction(cc.Sequence:create(cc.MoveTo:create(tempTime,worldPos),cc.CallFunc:create(nFun1)))

	do return end

	local function nFun1()
		local iconSize=moveIcon:getContentSize()
		local moveSubIcon1=cc.Sprite:createWithSpriteFrameName("general_sysopen_star.png")
		moveSubIcon1:setOpacity(150)
		moveSubIcon1:setPosition(iconSize.width*0.5,iconSize.height*0.5)
		moveIcon:addChild(moveSubIcon1,-1)

		local moveSubIcon2=cc.Sprite:createWithSpriteFrameName("general_sysopen_star.png")
		moveSubIcon2:setOpacity(70)
		moveSubIcon2:setPosition(iconSize.width*0.5,iconSize.height*0.5)
		moveIcon:addChild(moveSubIcon2,-2)

		local tempNum=30
		moveSubIcon1:runAction(cc.MoveBy:create(tempTime*0.6,cc.p(-tempNum,0)))
		moveSubIcon2:runAction(cc.MoveBy:create(tempTime*0.6,cc.p(-tempNum*2,0)))

		local function nFun5()
			self:__finish()
		end
		local function nFun4(_node)
			-- _node:runAction(cc.FadeTo:create(0.4,0))
			self.m_openSpr:runAction(cc.FadeTo:create(0.4,0))

			local openEffect=cc.ParticleSystemQuad:create("particle/sys_open_bomb2.plist")
		    openEffect:setPosition(worldPos)
		    self.m_rootLayer:addChild(openEffect,100)

		    self.m_mainIconBtn:setVisible(true)
		    self.m_mainIconBtn:setOpacity(0)
		    self.m_mainIconBtn:runAction(cc.FadeTo:create(0.5,255))

		    self:__delayToDo(1,nFun5)
		end

		local function nFun3(_node)
			-- local xuanWoSpr=cc.Sprite:createWithSpriteFrameName("general_sysopen_xuan.png")
			-- xuanWoSpr:setOpacity(0)
			-- xuanWoSpr:setPosition(iconSize.width*0.5,iconSize.height*0.5)
			-- moveIcon:addChild(xuanWoSpr)

			moveIcon:runAction(cc.FadeTo:create(0.2,0))
			moveSubIcon1:runAction(cc.FadeTo:create(0.2,0))
			moveSubIcon2:runAction(cc.FadeTo:create(0.2,0))
			nFun4()
			-- xuanWoSpr:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,255),cc.RotateBy:create(0.8,360*3),cc.CallFunc:create(nFun4)))
		end

		local function nFun2(_node)
			local ntimes=0.1
			moveSubIcon1:runAction(cc.MoveBy:create(ntimes,cc.p(tempNum,0)))
			moveSubIcon2:runAction(cc.Sequence:create(cc.MoveBy:create(ntimes*2,cc.p(tempNum*2,0)),cc.CallFunc:create(nFun3)))
		end
		local nAct=cc.Sequence:create(cc.MoveTo:create(tempTime,worldPos),
									  cc.CallFunc:create(nFun2))

		local subX=worldPos.x-self.m_openPos.x
		local subY=worldPos.y-self.m_openPos.y
		subX=subX==0 and 0.01 or subX
		local tan=math.atan(math.abs(subY/subX))*180/math.pi
		local angle
		if subX>0 and subY>0 then
			angle=-tan
		elseif subX>0 and subY<0 then
			angle=tan
		elseif subX<0 and subY>0 then
			angle=tan-180
		else
			angle=180-tan
		end
		print("CCCCCCCCCCCCCCCC=======>>>>",tan,angle)
		moveIcon:setRotation(angle)
		moveIcon:runAction(nAct)

	end
	moveIcon:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.1),cc.ScaleTo:create(0.1,1),cc.CallFunc:create(nFun1)))
	moveIcon:runAction(cc.FadeTo:create(0.25,255))
end

function SubOpenFun.__finish(self)
	if self.m_rootLayer==nil then return end

	local function nFun(_node)
		_node:removeFromParent()
		-- local command=CMainUiCommand(CMainUiCommand.SUBVIEW_FINISH)
  --   	_G.controller:sendCommand(command)
  		self.m_mainView:showSysOpenEffectEnd()
	end

	local activityView=self.m_mainView:getIconActivity()
	activityView:checkOpenInfoUpdate()

	self.m_rootLayer:runAction(cc.Sequence:create(cc.FadeTo:create(0.3,0),cc.CallFunc:create(nFun)))
	self.m_rootLayer=nil
end





return SubOpenFun