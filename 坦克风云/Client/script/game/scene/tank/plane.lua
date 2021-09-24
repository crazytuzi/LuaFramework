plane = {
	
}
-- local blendFunc = ccBlendFunc:new()
-- blendFunc.src = GL_DST_COLOR
-- blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA
-- self.nightSpriteBg:setBlendFunc(blendFunc)
-- self.sceneSp:addChild(self.nightSpriteBg,3000)
function plane:initPlanesCfg( )
	self.downPos={ccp(-600,-200),ccp(1200,1150)}--左右飞机战场内的到达坐标
	if G_isIphone5() or G_getIphoneType() == G_iphoneX then--适配
		self.lStartPos={["p1"]=ccp(750,530),["p2"]=ccp(750,530),["p3"]=ccp(750,530),["p4"]=ccp(770,520)}--飞机进场前起始坐标
	elseif not G_isIOS() then
		self.lStartPos={["p1"]=ccp(850,510),["p2"]=ccp(850,510),["p3"]=ccp(850,510),["p4"]=ccp(850,510)}--飞机进场前起始坐标
	else
		self.lStartPos={["p1"]=ccp(750,530),["p2"]=ccp(750,530),["p3"]=ccp(750,530),["p4"]=ccp(750,530)}--飞机进场前起始坐标
	end
	self.rStartPos={["p1"]=ccp(-70,550),["p2"]=ccp(-70,550),["p3"]=ccp(-70,500),["p4"]=ccp(-70,530)}
	self.skillColor={"planeSkill_white.png","planeSkill_green.png","planeSkill_blue.png","planeSkill_purple.png","planeSkill_yellow.png",}
	self.skillNameColor={G_ColorWhite,G_ColorGreen,G_ColorBlue,G_ColorPurple,G_ColorYellow}	
end
--实例化飞机
function plane:new(tid,area,picNum,sId,isSpace,parent,isBoss,newShellsNum )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	nc.tid	  = tid
	nc.area   = area
	nc.picNum = picNum
	nc.parent = parent
	nc.isSpace = isSpace
	nc.sId = sId  
	nc.skillCD =0
	nc.curPlaneShells = {}--玩家信息下面显示的当前回合的炸弹数量
	nc.curPlaneGrayShells = {}
	nc.curPlaneShellsTop = newShellsNum or 5----飞机能量点数最大值（5以上的能量值 = 飞机 + 飞机技能）
	nc.isBoss = isBoss
	-- nc.skillId = planeCfg.skillCfg[sId].planeAnim
	nc.colorId = sId and planeGrowCfg.grow[sId]["color"] or nil
	nc.skillGroup = sId and planeCfg.skillCfg[sId].skillGroup+1 or nil
	nc.SpStPos = ccp(0,0)
	if isBoss then
		nc:initCurShells()
	else
		nc:init()
	end
	return nc
end

function plane:init()
	self:initPlanesCfg()
	self.isWillDie = false
	self.inBattle = false
	self.curShellsNum = 1
	
	self.container = CCNode:create()
	if self.isSpace == true then
		self.container:setVisible(false)
	end
	-- local replacePic = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	-- replacePic:setContentSize(CCSizeMake(100,100))
	-- self.container:addChild(replacePic,5)

	local planeFrameName = self.tid.."_"..self.picNum..".png"--第5层
	self.sprite = CCSprite:createWithSpriteFrameName(planeFrameName)
	self.container:addChild(self.sprite,5)--飞机本身
	self.SpStPos.x,self.SpStPos.y = self.sprite:getPositionX(),self.sprite:getPositionY()

 	local stPos = self.area == 1 and self.rStartPos[self.tid] or self.lStartPos[self.tid]
    self.container:setPosition(stPos)

    if self.area == 1 then
    	if self.parent and self.parent.r_tankLayer then
	         self.parent.r_tankLayer:addChild(self.container,2) --添加到战场
	    else
	        battleScene.r_tankLayer:addChild(self.container,2) --添加到战场
	    end	
    else
    	if self.parent and self.parent.l_tankLayer then
	         self.parent.l_tankLayer:addChild(self.container,2) --添加到战场
	    else
	        battleScene.l_tankLayer:addChild(self.container,2) --添加到战场
	    end
    end
    self:initCurShells()
    if self.skillGroup and battleScene.container and self.colorId then
    	
    	self:initSkillName(battleScene.container)
    end
end

function plane:refNewShells( newShellsNum ,subNum ,addNum)
		newShellsNum = newShellsNum > self.curPlaneShellsTop and self.curPlaneShellsTop or newShellsNum

		if ( not subNum and not addNum ) or ( subNum == 0 and addNum == 0) then
			self.curShellsNum = newShellsNum
			if self.curPlaneShells[newShellsNum] then
				self.curPlaneShells[newShellsNum]:setVisible(true)
			end
			return newShellsNum
		else
			subNum = subNum or 0
			addNum = addNum or 0
			local changeNum = newShellsNum == self.curPlaneShellsTop and 1 or 0
			local useSubNum = newShellsNum - subNum + changeNum --下限
			local useAddNum = useSubNum + addNum --上限
			local beginSubNum = newShellsNum - 1 + changeNum
			local beginAddNum = subNum > 0 and useSubNum or newShellsNum 
			if newShellsNum == self.curPlaneShellsTop then
				if subNum == 0 then -- 达到上限 没有表现动画
					addNum = 0
				end
			end

			local function addBlink( )
				for i=beginAddNum,useAddNum do
					if self.curPlaneShells[i] then
						local blink = CCBlink:create(1  * G_battleSpeed, 3)
						local function addBlinkOver( )
							self.curPlaneShells[i]:setVisible(true)
						end 
						local addCallFunc = CCCallFuncN:create(addBlinkOver)
						local acArr=CCArray:create()
						acArr:addObject(blink)
						acArr:addObject(addCallFunc)
						local seq=CCSequence:create(acArr)
				        self.curPlaneShells[i]:runAction(seq) 
				    end
				end
			end 

			if subNum > 0 then
				for i=beginSubNum ,useSubNum ,-1 do
					if self.curPlaneShells[i] then
						self.curPlaneGrayShells[i]:setVisible(true)
						local blink = CCBlink:create(1  * G_battleSpeed, 3)
						local function subBlinkOver( )
							self.curPlaneShells[i]:setVisible(false)
							self.curPlaneGrayShells[i]:setVisible(false)
						end 
						local subCallFunc = CCCallFuncN:create(subBlinkOver)
						local delayAc = CCDelayTime:create(0.3 * G_battleSpeed)
						local function beginAddBlink( )
							-- if i == useSubNum and addNum > 0 then
								-- beginAddNum = useSubNum
								-- useAddNum   = beginAddNum + addNum - 1
								-- if useAddNum > self.curPlaneShellsTop then
								-- 	useAddNum = self.curPlaneShellsTop
								-- end
								addBlink()
							-- end
						end 
						local addCallFunc = CCCallFuncN:create(beginAddBlink)
						local acArr=CCArray:create()
						acArr:addObject(blink)
						acArr:addObject(subCallFunc)
						acArr:addObject(delayAc)
						acArr:addObject(addCallFunc)
						local seq=CCSequence:create(acArr)
				        self.curPlaneShells[i]:runAction(seq) 
				    end
				end
			elseif addNum > 0 then
				addBlink()
			end

			return newShellsNum - subNum + addNum >= 0 and newShellsNum - subNum + addNum or 0--返回此次能量的数量
		end
end

function plane:initCurShells( )
	local heightSize = 40
	local addSize = (self.tid =="p2" or self.tid =="p4") and 15 or 5--"p2 和 p4 两架飞机图片更宽"
	local curBattleScene = self.isBoss and BossBattleScene or battleScene
	if self.area  == 1 and curBattleScene.leftPlayerSp then
		
		local shellBg = LuaCCScale9Sprite:createWithSpriteFrameName("planeIconBg1.png",CCRect(10, 10, 1, 1),function ()end)
		shellBg:setContentSize(CCSizeMake(curBattleScene.leftPlayerSp:getContentSize().width-20,heightSize))
		shellBg:setAnchorPoint(ccp(0,1))
		shellBg:setOpacity(140)
		shellBg:setPosition(ccp(0,1))
		curBattleScene.leftPlayerSp:addChild(shellBg)
		-- print("self.tid---->",self.tid)
		local fjIcon = CCSprite:createWithSpriteFrameName("plane_icon_"..self.tid..".png")
		fjIcon:setPosition(ccp(heightSize*0.5+addSize,heightSize*0.5))
		fjIcon:setScaleY(heightSize/fjIcon:getContentSize().height)
		if self.tid == "p2" then
			fjIcon:setScaleX(0.2)
		else
			fjIcon:setScaleX(heightSize/fjIcon:getContentSize().height)
		end
		shellBg:addChild(fjIcon)

		for i=1,self.curPlaneShellsTop do
			local shellsName = i < 6 and "planeShells.png" or "planeShells2.png"
			local useIdx = i < 6 and i or i - 5
			local shellsSp = CCSprite:createWithSpriteFrameName(shellsName)
			shellsSp:setPosition(ccp(heightSize*0.8+addSize+(heightSize-5)*useIdx,heightSize*0.5))
			shellBg:addChild(shellsSp)
			shellsSp:setVisible(false)
			self.curPlaneShells[i] = shellsSp

			local grayShellSp = GraySprite:createWithSpriteFrameName(shellsName)
			grayShellSp:setPosition(getCenterPoint(shellsSp))
			shellsSp:addChild(grayShellSp)
			grayShellSp:setVisible(false)
			self.curPlaneGrayShells[i] = grayShellSp
		end
		self.curPlaneShells[1]:setVisible(true)

	elseif self.area == 2 and curBattleScene.rightPlayerSp then
		
		local shellBg = LuaCCScale9Sprite:createWithSpriteFrameName("planeIconBg2.png",CCRect(10, 10, 1, 1),function ()end)
		shellBg:setContentSize(CCSizeMake(curBattleScene.rightPlayerSp:getContentSize().width-20,heightSize))
		shellBg:setAnchorPoint(ccp(1,1))
		shellBg:setOpacity(140)
		shellBg:setPosition(ccp(curBattleScene.rightPlayerSp:getContentSize().width,1))
		curBattleScene.rightPlayerSp:addChild(shellBg)

		local fjIcon = CCSprite:createWithSpriteFrameName("plane_icon_"..self.tid..".png")
		fjIcon:setPosition(ccp(heightSize*0.5+addSize,heightSize*0.5))
		fjIcon:setScale(heightSize/fjIcon:getContentSize().height)
		shellBg:addChild(fjIcon)		

		for i=1,self.curPlaneShellsTop do
			local shellsName = i < 6 and "planeShells.png" or "planeShells2.png"
			local useIdx = i < 6 and i or i - 5
			local shellsSp = CCSprite:createWithSpriteFrameName(shellsName)
			shellsSp:setPosition(ccp(heightSize*0.8+addSize+(heightSize-5)*useIdx,heightSize*0.5))
			shellBg:addChild(shellsSp)
			shellsSp:setVisible(false)
			self.curPlaneShells[i] = shellsSp

			local grayShellSp = GraySprite:createWithSpriteFrameName(shellsName)
			grayShellSp:setPosition(getCenterPoint(shellsSp))
			shellsSp:addChild(grayShellSp)
			grayShellSp:setVisible(false)
			self.curPlaneGrayShells[i] = grayShellSp
		end
		self.curPlaneShells[1]:setVisible(true)
	end
end

function plane:runSkillAction( )
	if self.skillBg ==nil then
		printf("self.skillBg is nil ~~~")
		do return end
	end
	self.skillBg:setPosition(getCenterPoint(self.pppParent))
	self.skillName:setScale(1.5)

	local scaleto = CCScaleTo:create(0.1 * G_battleSpeed, 1)
	local function callBack()
		self.skillBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*2))
		self.skillName:setVisible(false)
	end
	local callFunc = CCCallFuncN:create(callBack)
	local delayT = CCDelayTime:create(0.5)
	local acArr = CCArray:create()
	acArr:addObject(scaleto)
	acArr:addObject(delayT)
	acArr:addObject(callFunc)
	local seq = CCSequence:create(acArr)
	self.skillName:setVisible(true)
	self.skillName:runAction(seq)

	local fadeIn = CCFadeIn:create(0)
	local fadeOunt = CCFadeOut:create(0.1 * G_battleSpeed)
	local delayT1 = CCDelayTime:create(0.3)
	local lineMovTo = CCMoveTo:create(0.2 * G_battleSpeed,ccp(self.nameLine1:getPositionX()+self.skillName:getContentSize().width,self.nameLine1:getPositionY()))
	local acArrL1 = CCArray:create()
	acArrL1:addObject(delayT1)
	acArrL1:addObject(fadeIn)
	acArrL1:addObject(lineMovTo)
	acArrL1:addObject(fadeOunt)
	local seqL1 = CCSequence:create(acArrL1)

	local function callBack2()
		self.nameLine1:setPosition(ccp(self.skillName:getPositionX()-self.skillName:getContentSize().width*0.5,self.skillName:getPositionY()+self.skillName:getContentSize().height*0.4))
		self.nameLine2:setPosition(ccp(self.skillName:getPositionX()+self.skillName:getContentSize().width*0.5,self.skillName:getPositionY()-self.skillName:getContentSize().height*0.4))
	end
	local callFunc2 = CCCallFuncN:create(callBack2)
	local fadeIn2 = CCFadeIn:create(0)
	local fadeOunt2 = CCFadeOut:create(0.1 * G_battleSpeed)
	local delayT2 = CCDelayTime:create(0.3)
	local lineMovTo2 = CCMoveTo:create(0.2 * G_battleSpeed,ccp(self.nameLine2:getPositionX()-self.skillName:getContentSize().width,self.nameLine2:getPositionY()))
	local acArrL2 = CCArray:create()
	acArrL2:addObject(delayT2)
	acArrL2:addObject(fadeIn2)
	acArrL2:addObject(lineMovTo2)
	acArrL2:addObject(fadeOunt2)
	acArrL2:addObject(callFunc2)
	local seqL2 = CCSequence:create(acArrL2)

	-- self.nameLine1:setVisible(true)
	-- self.nameLine2:setVisible(true)
	self.nameLine1:runAction(seqL1)
	self.nameLine2:runAction(seqL2)

	local needSp = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	needSp:setOpacity(0)
	self.sprite:addChild(needSp)
	local function runAudio( )
		PlayEffect(audioCfg.planeSkill)
		needSp:removeFromParentAndCleanup(true)
	end

	local delayT2 = CCDelayTime:create(0.3)
	local runA = CCCallFuncN:create(runAudio)
	local acArr2 = CCArray:create()
	acArr2:addObject(delayT2)
	acArr2:addObject(runA)
	local seq2 = CCSequence:create(acArr2)
	needSp:runAction(seq2)
end

function plane:initSkillName(pppParent)
	self.pppParent = pppParent
	self.skillBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	self.skillBg:setOpacity(130)
	self.skillBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.skillBg:setAnchorPoint(ccp(0.5,0.5))
	self.skillBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*2))
	pppParent:addChild(self.skillBg,25)
	local bigStrSize,smlStrSize = 50,35
	self.skillName = GetTTFLabel(getlocal("plane_skill_name_s"..self.skillGroup),bigStrSize)
	if self.skillName:getContentSize().width > G_VisibleSizeWidth*0.5 then
		self.skillName  = GetTTFLabelWrap(getlocal("plane_skill_name_s"..self.skillGroup),smlStrSize,CCSizeMake(G_VisibleSizeWidth*0.5,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	end
	self.skillName:setColor(self.skillNameColor[self.colorId])
	self.skillName:setAnchorPoint(ccp(0.5,0.5))
	
	local namesPos = {ccp(0,1),ccp(1,0),ccp(0,-1),ccp(-1,0)}
	for i=1,4 do
		local skillNames = GetTTFLabel(getlocal("plane_skill_name_s"..self.skillGroup),bigStrSize)
		if skillNames:getContentSize().width > G_VisibleSizeWidth*0.5 then
			skillNames  = GetTTFLabelWrap(getlocal("plane_skill_name_s"..self.skillGroup),smlStrSize,CCSizeMake(G_VisibleSizeWidth*0.5,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		end
		skillNames:setColor(self.skillNameColor[self.colorId])
		skillNames:setPosition(ccp(self.skillName:getContentSize().width*0.5+namesPos[i].x,self.skillName:getContentSize().height*0.5+namesPos[i].y))
		self.skillName:addChild(skillNames)
	end
	self.skillName:setVisible(false)

	local nameBgPosX = self.area == 1 and G_VisibleSizeWidth*0.26 or G_VisibleSizeWidth*0.74
	local nameBgPosY = self.area == 1 and G_VisibleSizeHeight*0.43 or G_VisibleSizeHeight*0.53
	self.skillName:setPosition(ccp(nameBgPosX,nameBgPosY))
	self.skillBg:addChild(self.skillName,1)

	self.nameLine1 = CCSprite:createWithSpriteFrameName(self.skillColor[self.colorId])
	self.nameLine1:setPosition(ccp(self.skillName:getPositionX()-self.skillName:getContentSize().width*0.5,self.skillName:getPositionY()+self.skillName:getContentSize().height*0.4))
	self.skillBg:addChild(self.nameLine1)
	local blendFunc = ccBlendFunc:new()
	blendFunc.src = GL_SRC_ALPHA
	blendFunc.dst = GL_ONE
	self.nameLine1:setBlendFunc(blendFunc)


	self.nameLine2 = CCSprite:createWithSpriteFrameName(self.skillColor[self.colorId])
	self.nameLine2:setPosition(ccp(self.skillName:getPositionX()+self.skillName:getContentSize().width*0.5,self.skillName:getPositionY()-self.skillName:getContentSize().height*0.4))
	self.skillBg:addChild(self.nameLine2)
	local blendFunc = ccBlendFunc:new()
	blendFunc.src = GL_SRC_ALPHA
	blendFunc.dst = GL_ONE
	self.nameLine2:setBlendFunc(blendFunc)		

	self.nameLine1:setOpacity(0)
	self.nameLine2:setOpacity(0)
end
function plane:beginAttAction( )
	
	if self.sprite then
		-- print("flyAction----self.tid---slf.picNum--->",self.tid,self.picNum)
		local movTo = CCMoveTo:create(1.2 * G_battleSpeed,self.downPos[self.picNum])
		local delayT = CCDelayTime:create(0.5 * G_battleSpeed)
		local function callBack()
				local stPos = self.area == 1 and self.rStartPos[self.tid] or self.lStartPos[self.tid]
				self.container:setPosition(stPos)
		end
		local callFunc = CCCallFuncN:create(callBack)
		local acArr=CCArray:create()
		acArr:addObject(delayT)
		acArr:addObject(movTo)
		acArr:addObject(callFunc)
		local seq=CCSequence:create(acArr)
		self.container:runAction(seq)

		local needSp = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
		needSp:setOpacity(0)
		self.sprite:addChild(needSp)
		local function runAudio( )
			PlayEffect(audioCfg.planeFly)
			needSp:removeFromParentAndCleanup(true)
		end

		local delayT2 = CCDelayTime:create(0.5 * G_battleSpeed)
		local runA = CCCallFuncN:create(runAudio)
		local acArr2 = CCArray:create()
		acArr2:addObject(delayT2)
		acArr2:addObject(runA)
		local seq2 = CCSequence:create(acArr2)
		needSp:runAction(seq2)


	end
end

function plane:runSkillAnimation(pareantLayer,layer,stDelay,whiNum)
	local addPosX,addPosY = G_VisibleSizeWidth*0.29,G_VisibleSizeHeight*0.45
	local effPos = whiNum == 2 and {ccp(250,150),ccp(350,250),ccp(100,200),ccp(230,230),ccp(200,400),ccp(450,220)} or {ccp(250+addPosX,250+addPosY),ccp(350+addPosX,350+addPosY),ccp(100+addPosX,300+addPosY),ccp(100+addPosX,500+addPosY),ccp(200+addPosX,400+addPosY),ccp(400+addPosX,350+addPosY)}
	for ii=1,6 do
	  local beAttcEff="plane_bigShells_1.png" --开火动画
      local m_beAttcEff=CCSprite:createWithSpriteFrameName(beAttcEff)
      pareantLayer:addChild(m_beAttcEff,layer) --开火动画   
      m_beAttcEff:setVisible(false)
      local beFireArr=CCArray:create()
      for i=1,16 do
         local nameStr = "plane_bigShells_"..i..".png"
         local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
         beFireArr:addObject(frame)
      end
      local animation=CCAnimation:createWithSpriteFrames(beFireArr)
      animation:setDelayPerUnit(0.05)
      local animate=CCAnimate:create(animation)
      m_beAttcEff:setPosition(effPos[ii])
      
      local function removeFireSp()
          m_beAttcEff:removeFromParentAndCleanup(true)
          m_beAttcEff=nil
      end
      local ffunc=CCCallFuncN:create(removeFireSp)
      local acArr=CCArray:create()
      local delayT = CCDelayTime:create( ( stDelay+0.1*ii )  * G_battleSpeed )
      acArr:addObject(delayT)
      acArr:addObject(animate)
      acArr:addObject(ffunc)
      local seq=CCSequence:create(acArr)
      m_beAttcEff:setVisible(true)
      m_beAttcEff:runAction(seq)


		local needSp = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
		needSp:setOpacity(0)
		m_beAttcEff:addChild(needSp)
		local function runAudio( )
		PlayEffect(audioCfg.planeBomb)
		needSp:removeFromParentAndCleanup(true)
		end
		local delayT2 = CCDelayTime:create( ( stDelay+0.1*ii  * G_battleSpeed ) )
		local runA = CCCallFuncN:create(runAudio)
		local acArr2 = CCArray:create()
		acArr2:addObject(delayT2)
		acArr2:addObject(runA)
		local seq2 = CCSequence:create(acArr2)
		needSp:runAction(seq2)

	end
end

function plane:dispose( )
	self.tid	= nil
	self.area   = nil
	self.picNum = nil
	self.parent = nil
	self.isSpace = nil
	self.skillGroup = nil
	self.SpStPos = nil
	self.isWillDie = nil
	self.inBattle = nil
	self.container = nil
	self.skillBg = nil
	self.skillName = nil
	self.nameLine1 = nil
	self.nameLine2 = nil
	self.pppParent = nil
	self.sprite = nil
	self.SpStPos = nil
	self.skillColor = nil
	self.colorId = nil
	self.curPlaneShells = nil
	self.curPlaneGrayShells = nil
end