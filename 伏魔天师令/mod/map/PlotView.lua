local PlotView=classGc(view, function(self,_plotData)
	self.m_isLoaMap =false
	self.m_plotIndex=0
	self.m_characterList={}
	self.m_releaseResourcesList={}
	self.m_realMonsterArray={}

	--剧情数据
    self.m_plotData=_plotData

    self.m_stageView=_G.g_Stage
end)
function PlotView.setDelege(self,_delege)
	self.m_delege=_delege
end

local __WinSize=cc.Director:getInstance():getWinSize()
local __DownSize=cc.size(__WinSize.width+6,202)
local __UpSize=cc.size(__WinSize.width+6,202)
local __DownPos=cc.p(__WinSize.width*0.5,__DownSize.height*0.5-1)
local __UpPos=cc.p(__WinSize.width*0.5,__WinSize.height-__UpSize.height*0.5+100)
local __WidScale=__WinSize.width/960



----------------------------
--常量
---------------------------- 
--按钮tag值
local TAG_NPC_IDLE =101
local TAG_NPC_MOVE =102

--时间
local TIME_BGACTION   =0.2 --开场动画后间隔的时间
local TIME_TALKACTION =0.2
local TIME_TALKDELAY  =0.5 --对话的时间间隔

--剧情播放阶段
local TYPE_TALK_END   =25 --对话完阶段
local TYPE_WAIT_MOVE  =40
local TYPE_WAIT_STEP  =80 --等待阶段
local TYPE_WAIT_TOUCH =85 --等待点击进入下一步阶段
local TYPE_FINISH     =100 --剧情播放阶段
local P_NPC_SIZE=cc.size(300,300)

function PlotView.createPlot(self)
    local function onTouchBegan()
    	return self:__layerTouchBegan()
    end
	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listerner:setSwallowTouches(true)

	self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
	-- self.m_rootLayer:runAction(cc.FadeTo:create(0.2,255*0.3))
	self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    --初始化数据
    self:initParams()
    --开场动画
	self:initBgView()

    return self.m_rootLayer
end
--初始化数据成员
function PlotView.initParams(self)
    local mainCharacter=_G.GPropertyProxy:getMainPlay()
    self.m_roleName=mainCharacter:getName() or ""
    self.m_rolePro =mainCharacter:getPro() or 1

    --当前剧情进行阶段
    self.m_poltType=TYPE_WAIT_STEP 
end
--æææææææææææææææææææææææææææææææææææææææ
--页面设置
--æææææææææææææææææææææææææææææææææææææææ
function PlotView.initBgView(self)
	self.m_mainNode=cc.Node:create()
    self.m_rootLayer:addChild(self.m_mainNode)

	----------------------------
	--剧情背景
	----------------------------
	self.m_upBackground=ccui.Scale9Sprite:createWithSpriteFrameName("general_dialog_bg.png")
	self.m_upBackground:setPreferredSize(__UpSize)
	self.m_upBackground:setScaleY(-1)
	-- self.m_upBackground:setOpacity(255*0.8)
	self.m_mainNode:addChild(self.m_upBackground)

	self.m_downBackground=ccui.Scale9Sprite:createWithSpriteFrameName("general_dialog_bg.png")
	self.m_downBackground:setPreferredSize(__DownSize)
	-- self.m_downBackground:setOpacity(255*0.8)
	self.m_mainNode:addChild(self.m_downBackground)

	self.m_upBackground :setPosition(cc.p(__WinSize.width*0.5,__WinSize.height+__UpSize.height*0.5))
	self.m_downBackground:setPosition(cc.p(__WinSize.width*0.5,-__DownSize.height*0.5))

	self.m_npcSpr_Wid=P_NPC_SIZE.width
	self.m_talk_pyWid=95
	local talkWidth=__WinSize.width-self.m_npcSpr_Wid-self.m_talk_pyWid-10
	self.m_talkLabel=_G.Util:createLabel("",22)
	self.m_talkLabel:setDimensions(talkWidth,0)
	self.m_talkLabel:setAnchorPoint(cc.p(0,1))
	self.m_talkLabel:setPosition(cc.p(self.m_npcSpr_Wid+15,70))
	-- self.m_talkLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PALEGREEN))
	self.m_talkLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.m_mainNode:addChild(self.m_talkLabel)

	self.m_nameLabel=_G.Util:createLabel("",24)
	self.m_nameLabel:setAnchorPoint(cc.p(0.2,0))
	self.m_nameLabel:setPosition(cc.p(__WinSize.width-talkWidth,85))
	self.m_nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	self.m_mainNode:addChild(self.m_nameLabel)

	local function local_waitCheckPointMove()
		print("local_waitCheckPointMove----->>>>>",self.m_stageView.m_isSwitchCheckPoint)
		if not self.m_stageView.m_isSwitchCheckPoint then
			if self.m_plotData.screen==1 then
				self:showBlinkSceneAction()
			else
				if not self.m_stageView.m_plotFirstGame then
					self.m_stageView:getMainPlayer():getContainer():setVisible(false)
				end
				self:goNextAction()
			end

			if self.m_waitScheduler~=nil then
				_G.Scheduler:unschedule(self.m_waitScheduler)
				self.m_waitScheduler=nil
			end
		end
	end

	if self.m_plotData.touchType==_G.Const.CONST_DRAMA_GETINTO then
		local_waitCheckPointMove()
	else
		self.m_waitScheduler=_G.Scheduler:schedule(local_waitCheckPointMove,0.5)
		self.m_stageView:cancelJoyStickTouch()
	end
end

function PlotView.delayToDoFun(self, _delayTime, _fun)
	if self.m_rootLayer~=nil and _delayTime~=nil and _fun~=nil then
		local act1=cc.DelayTime:create(_delayTime)
		local act2=cc.CallFunc:create(_fun)
		self.m_rootLayer:runAction(cc.Sequence:create(act1,act2))
	end
end

function PlotView.showBlinkSceneAction(self)
	CCLOG("[剧情]-剧情开始前闪屏")
	local function local_actionFun(_node)
		_node:removeFromParent(true)
		self:goNextAction()
	end

	local function local_midFun(_node)
		self.m_stageView:getMainPlayer():getContainer():setVisible(false)
	end

	local _times=0.3
	local act1=cc.FadeTo:create(_times,255)
	local act2=cc.CallFunc:create(local_midFun)
	local act3=cc.DelayTime:create(0.6)
	local act4=cc.FadeTo:create(_times,0)
	local act5=cc.CallFunc:create(local_actionFun)

	local blackLayer=cc.LayerColor:create(cc.c4b(0,0,0,255))
	blackLayer:setOpacity(0)
	blackLayer:runAction(cc.Sequence:create(act1,act2,act3,act4,act5))
	self.m_mainNode:addChild(blackLayer)
end

--创建对话框的角色图像
function PlotView.showTalkRole(self, _skinId, _dir)
	CCLOG("[剧情]-显示半身像")

	-- local animation
	-- if _skinId==0 then
	-- 	self.m_skeleton=_G.SpineManager.createMainPlayer()
	-- 	animation="idle"
	-- else
	-- 	self.m_skeleton=_G.SpineManager.createNpc(_skinId)
	-- 	if self.m_belleData and self.m_belleData.skin==_skinId then
	-- 		animation=self.m_belleData.animation
	-- 	else
	-- 		animation="idle"
	-- 	end
	-- end
	-- if self.m_skeleton==nil then return end
	-- local nScale=1.3*self.m_skeleton:getScale()
	-- self.m_skeleton:setScale(nScale)
	-- self.m_skeleton:setAnimation(0,animation,true)


	local szImg=nil
	local nScale=1
	if _skinId==0 then
		szImg=string.format("painting/1000%d.png",self.m_rolePro)
	else
		szImg=string.format("painting/%d.png",_skinId)
	    if not _G.FilesUtil:check(szImg) then
	        szImg="painting/20031.png"
	    end
	end
	self.m_releaseResourcesList[szImg]=true
	self.m_skeleton=_G.ImageAsyncManager:createNormalSpr(szImg)
	self.m_skeleton:setScaleY(nScale)
	self.m_mainNode:addChild(self.m_skeleton)

	local nWidth  =self.m_npcSpr_Wid*0.5
	local nHeight =P_NPC_SIZE.height*0.5
	local startPos=nil
	local endPos  =nil
	if _dir==_G.Const.CONST_DRAMA_DIR_EAST then
		startPos=cc.p(-nWidth,nHeight)
		endPos  =cc.p(nWidth,nHeight)
		self.m_skeleton:setScaleX(nScale)
	else
		startPos=cc.p(__WinSize.width+nWidth,nHeight)
		endPos  =cc.p(__WinSize.width-nWidth,nHeight)
		self.m_skeleton:setScaleX(-nScale)
	end
	local nTimes=0.1
	self.m_skeleton:setPosition(startPos)
	self.m_skeleton:setOpacity(0)
	self.m_skeleton:runAction(cc.MoveTo:create(nTimes,endPos))
	self.m_skeleton:runAction(cc.FadeTo:create(nTimes,255))
end

--创建小助手
function PlotView.createHandGuide(self, _sprId, _sayStr, _name, _sprDir, _soundId)
	-- local function local_handGuideEnd()
	-- 	self:goNextAction()
	-- end

	-- self:removeRoleSprite()
	-- self.m_nameLabel:setString("")
	-- self.m_talkLabel:setString("")

	-- require "view/Guide/LittleGirlLayer"
	-- local girlView =CLittleGirlLayer(CLittleGirlLayer.TYPE_Alert, _sprId, _name, _sayStr, local_handGuideEnd, _sprDir)
	-- local girlLayer=girlView:create()
	-- self.m_mainNode:addChild(girlLayer, 100)

	-- local soundStr=_soundId
	-- if soundStr~=nil and soundStr~="nil" and soundStr~="undefined" and soundStr~=0 and soundStr~="0" then
	-- 	_G.Util:playAudioEffect(soundStr)
	-- end
	CCLOG("lua error===>>> createHandGuide...... no handle")
end

--创建人物漂移
function PlotView.createRoleFlutter(self, _sprId, _sayStr, _name, _dir, _soundId)
	self:autoGoNextStep()
	do return end

	local function local_roleFlutterEnd()
		self:goNextAction()
	end

	self:removeRoleSprite()
	self.m_nameLabel:setString("")
	self.m_talkLabel:setString("")

	require "view/Guide/LittleGirlLayer"
	local girlView =CLittleGirlLayer(CLittleGirlLayer.TYPE_Flutter, _sprId, _name, _sayStr, local_roleFlutterEnd, _dir)
	local girlLayer=girlView:create()
	self.m_mainNode:addChild(girlLayer, 100)

	local soundStr=_soundId
	if soundStr~=nil and soundStr~="nil" and soundStr~="undefined" and soundStr~=0 and soundStr~="0" then
		_G.Util:playAudioEffect(soundStr)
	end
end

--移除对话框的主角图像
function PlotView.removeRoleSprite(self)
	if self.m_skeleton~=nil then
		self.m_skeleton:removeFromParent(true)
		self.m_skeleton=nil
	end
end

--æææææææææææææææææææææææææææææææææææææææ
--场景控制
--æææææææææææææææææææææææææææææææææææææææ
--创建怪物到主场景中
function PlotView.createPlotMonster(self, _type, _tag, _name, _pos, _dir, _absolute, _animation)
	print("[剧情]-创建怪物或npc _tag=",_tag,"_name=",_name,",_type=",_type)

	-- self:autoGoNextStep()
	-- do return end

	local function local_saveCharacter(_character, _npcNode)
		local list    ={}
		list.character=_character
		list.type     =_type
		local index=self.m_characterList[_tag] and _tag.._name.._pos.x.._pos.y or _tag

		list.tag=_tag
		self.m_characterList[index]=list
	end
	
	local ContainerX, ContainerY=self.m_stageView.m_lpContainer:getPosition()
	local realPos=nil
	if _absolute then
		realPos=_pos
	else
		realPos=cc.p(_pos.x*__WidScale-ContainerX, _pos.y)
	end

	print("-------->>>>>  地图位置-》",ContainerX, ContainerY)
	print("-------->>>>>  人物位置-》",self.m_stageView:getMainPlayer():getLocationXY())
	print("-------->>>>>  添加位置-》",realPos.x, realPos.y)
	local character=nil
	if _type==_G.Const.CONST_PLAYER then
		self:autoGoNextStep()
	elseif _type==_G.Const.CONST_MONSTER then
		CCLOG("[剧情]-添加怪物")
		for k,v in pairs(_G.CharacterManager.m_lpMonsterArray) do
			if not v.isPlotMonster and v.m_monsterId==_tag then
				if not self.m_realMonsterArray[v] then
					character=v
					self.m_realMonsterArray[v]=true
					break
				end
			end
		end
		if character==nil then
			character=self.m_stageView:addPlotMonster(_tag, _name, realPos, _dir)
		else
			print("使用场景中的怪物=================>>>>>>>>>>",_tag,_name)
			character:cancelMovie()
			character.isPlotMonster=true
			character.m_lpContainer:setVisible(true)

			if not _G.g_Stage.m_plotFirstGame then
				character:setLocationXY(realPos.x,realPos.y)
			end
			if _dir==_G.Const.CONST_DRAMA_DIR_WEST then
				character:setMoveClipContainerScalex(-1)
			else
				character:setMoveClipContainerScalex(1)
			end
		end
		local_saveCharacter(character)

		local isAuto=true
		if self.m_plotData.id==10002 and _tag==11990 and _G.g_Stage.m_plotFirstGame then
			local tempSpine=_G.g_Stage.m_plotFirstGame.m_bossNpcSpine
			if tempSpine then
				tempSpine:removeFromParent(true)
				_G.g_Stage.m_plotFirstGame.m_bossNpcSpine=nil

				character.m_lpMovieClip:setOpacity(0)
				-- character.m_lpMovieClip:runAction(cc.FadeTo:create(0.5,255))

				local effectName="spine/come6"
		        local effectSpine=_G.SpineManager.createSpine(effectName,3)
		        effectSpine:setPosition(0,0)
		        effectSpine:setAnimation(0,"idle",false)
		        character.m_lpMovieClip:addChild(effectSpine)

		        local function onFunc1()
		        	effectSpine:removeFromParent(true)
		        end
		        local function onFunc2(event)
		        	character.m_lpMovieClip:setOpacity(255)
		        	effectSpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(onFunc1)))
		        	self:autoGoNextStep()
                end
                effectSpine:registerSpineEventHandler(onFunc2,2)

                isAuto=false
			end
		end
		if isAuto then
			self:autoGoNextStep()
		end

		if _animation~=nil then
			character.saveFunArray={}
			character.saveFunArray["setStatus"]=character.setStatus
			character.saveFunArray["animationCallFunc"]=character.animationCallFunc
			character.setStatus=function() end
			character.animationCallFunc=function() end

			character.m_lpMovieClip:setAnimation(0,_animation,true)
		end
	elseif _type==_G.Const.CONST_NPC then
		CCLOG("[剧情]-添加NPC")
		self.m_poltType=TYPE_WAIT_STEP

		local npcCnf=_G.Cfg.scene_npc[_tag]
		if not npcCnf then
			self:autoGoNextStep()
			return
		end

		local npcObject=CNpc(_G.Const.CONST_NPC)
		npcObject:npcPlotInit(_name,realPos.x,realPos.y,npcCnf.skin)
		self.m_stageView.m_lpCharacterContainer:addChild(npcObject.m_lpContainer,-realPos.y)
		local_saveCharacter(npcObject)

		if _dir==_G.Const.CONST_DRAMA_DIR_WEST then
			npcObject.m_npcSpine:setScaleX(-npcObject.m_npcSpine:getScale())
		end

		if _animation~=nil then
			npcObject.m_npcSpine:setAnimation(0,_animation,true)
		end

		self:autoGoNextStep()
	else
		CCLOG("[剧情]-你填的是神马类型？")
		CCMessageBox(_name.." 的类型有误","剧情配表问题")
		self:autoGoNextStep()
	end
end

function PlotView.createEffectSpr(self, _effectId, _pos)
	self.m_effectList=self.m_effectList or {}
	if self.m_effectList[_effectId]~=nil then
		self:goNextAction()
		return
	end

	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/first_guide.plist")

	local ContainerX,ContainerY=self.m_stageView.m_lpContainer:getPosition()
	local realPos=cc.p(_pos.x*__WidScale-ContainerX, _pos.y)

	local effectName=_effectId
	self.m_effectList[_effectId]=cc.Sprite:createWithSpriteFrameName("general_joystick_circle.png")
	self.m_effectList[_effectId]:setPosition(realPos)
	self.m_stageView.m_lpCharacterContainer:addChild(self.m_effectList[_effectId],-realPos.y,_effectId)
end

function PlotView.setNpcRoleState(self, _character, _isIdle)
	local idle_bool=_isIdle
	local move_bool=not _isIdle

	print("[剧情]改变npc动作  idle_bool=",idle_bool,", move_bool=",move_bool)
	if _character:getChildByTag(TAG_NPC_IDLE) then
		print("idle----->>>  good!!!")
		_character:getChildByTag(TAG_NPC_IDLE):setVisible(idle_bool)
	end

	if _character:getChildByTag(TAG_NPC_MOVE) then
		print("move----->>>  good!!!")
		_character:getChildByTag(TAG_NPC_MOVE):setVisible(move_bool)
	end
end

--移动角色(主角或怪物)
function PlotView.roleMove(self, _tag, _pos, _animation)
	CCLOG("[剧情]-人物移动 _tag=%d",_tag)

	local ContainerX, ContainerY=self.m_stageView.m_lpContainer:getPosition()
	local realPos=cc.p(-ContainerX+_pos.x*__WidScale, _pos.y)
	if _tag==-1 then 
		--移动主角
		local mainPlayer=self.m_stageView:getMainPlayer()
		mainPlayer:setMovePos(realPos)

		local rolePox_x,rolePos_y=mainPlayer:getLocationXY()
		local xSpeed=370
		local ySpeed=250
		local xTimes=math.abs(rolePox_x-realPos.x)/xSpeed
		local yTimes=math.abs(rolePos_y-realPos.y)/ySpeed
		local delayTimes=((xTimes>yTimes) and xTimes or yTimes)+0.5
		local scaleX=(realPos.x<rolePox_x) and -1 or 1
		mainPlayer:setMoveClipContainerScalex(scaleX)

		local nSetMoveClipContainerScalex=mainPlayer.setMoveClipContainerScalex
		mainPlayer.setMoveClipContainerScalex=function() end

		local function delayFun()
			mainPlayer:cancelMove()
			mainPlayer.setMoveClipContainerScalex=nSetMoveClipContainerScalex
			if self.m_plotData.item[self.m_plotIndex].hand==0 then
				self:goNextAction()
			end
		end
		self:delayToDoFun(delayTimes, delayFun)
		self.m_poltType=TYPE_WAIT_STEP

		if self.m_plotData.item[self.m_plotIndex].hand~=0 then
			self.m_poltType=TYPE_WAIT_MOVE
		end
	elseif self.m_characterList[_tag]==nil or self.m_characterList[_tag].character==nil then
		self:autoGoNextStep()
	else
		local character=self.m_characterList[_tag].character
		local roleType =self.m_characterList[_tag].type
		if roleType==_G.Const.CONST_PLAYER then
			self:autoGoNextStep()
		elseif roleType==_G.Const.CONST_MONSTER then
			--移动Monster
			print("DDDDD=======>>>>>>>",character:getLocationXY())
			print("FFFFF=======>>>>>>>",realPos.x,realPos.y,_animation)

			if _animation~=nil then
				if character.saveFunArray~=nil then
					for k,v in pairs(character.saveFunArray) do
						character[k]=v
					end
					character.saveFunArray=nil
				end
				
				if _animation~="slip" then
					character.moveActionName=_animation
				end

				character:setMovePos(realPos)
				local mySched=nil
				local function nFun2()
					if character.m_lpMovePos==nil then
						_G.Scheduler:unschedule(mySched)

						if _animation=="slip" then
							character.m_lpMovieClip:setAnimation(0,_animation,false)
						else
							character.moveActionName=nil
						end

						self:autoGoNextStep()
					end
				end
				mySched=_G.Scheduler:schedule(nFun2,0.1)
			else
				character:setMovePos(realPos)
				self:autoGoNextStep()
			end
		elseif roleType==_G.Const.CONST_NPC then
			self:autoGoNextStep()
		else
			self:autoGoNextStep()
		end
	end
end

--角色消失(主角或怪物)
function PlotView.roleRemove(self, _tag, _isFinish, _isEndCopy)
	if _tag==-1 or self.m_characterList==nil then return end
	
	if self.m_characterList[_tag]~=nil then
		local character=self.m_characterList[_tag].character
		local roleType =self.m_characterList[_tag].type

		if character==nil then
			if not _isFinish then
				self:goNextAction()
			end
		elseif roleType==_G.Const.CONST_PLAYER then
			character:release()
			if not _isEndCopy then
				character:removeFromParent(true)
			end
		elseif roleType==_G.Const.CONST_MONSTER then 
			if self.m_realMonsterArray[character] then
				character.isPlotMonster=nil
				if character.saveFunArray~=nil then
					for szFun,fun in pairs(character.saveFunArray) do
						character.szFun=fun
					end
					character.saveFunArray=nil
				end
				self.m_realMonsterArray[character]=false
			else
				if not _isEndCopy then
					self.m_stageView:removePlotMonster(character)
				else
					character:removeThink()
				end
			end
		elseif roleType==_G.Const.CONST_NPC then
			if not _isEndCopy then
				character:releaseResource(true)
			end
		else
			if not _isFinish then
				self:goNextAction()
			end
		end
	else
		CCLOG("tag_有重复的？")
		for k,v in pairs(self.m_characterList) do
			if v.tag==_tag then
				self:roleRemove(k,_isFinish)
				return
			end
		end
		if not _isFinish then
			self:goNextAction()
		end
	end

	self.m_characterList[_tag]=nil
end

--释放技能
function PlotView.playSkill(self, _tag, _skillId)
	CCLOG("[剧情]-使用技能")
	if self.m_characterList[_tag]~=nil and _skillId~=nil then
		if self.m_characterList[_tag].character~=nil 
			and self.m_characterList[_tag].type~=_G.Const.CONST_NPC then
			self.m_characterList[_tag].character:useSkill(_skillId)
			-- return
		end
	end

	local function local_fun()
		if self.m_plotData.item[self.m_plotIndex].hand==0 then
			self:goNextAction()
		else
			self.m_poltType=TYPE_WAIT_TOUCH
		end
	end

	self:delayToDoFun(0.5, local_fun)
end

function PlotView.removeCorpse(self,_id)
	if not _id then
		self:goNextAction()
		return
	end

	for k,v in pairs(_G.CharacterManager.m_lpCorpseArray) do
		-- print("removeCorpse 1=======>>>>",_id,v.m_monsterId)
		if v.m_monsterId==_id then
			v.m_isCorpse=nil
	        _G.CharacterManager:removeCorpseByID(k)
	        v:releaseResource()
	        self:autoGoNextStep()
	        return
		end
	end
	self:goNextAction()
end

--移动地图
function PlotView.moveMap(self, _speed, _x, _dir)
	CCLOG("[剧情]-移动地图")
	local function local_moveEnd()
		print("[PlotView.moveMap]     end")
		local curNode=self.m_plotData.item[self.m_plotIndex]
		if curNode.hand==0 then
			self:goNextAction()
		else
			self.m_poltType=TYPE_WAIT_TOUCH
		end
	end

	local ContainerX, ContainerY=self.m_stageView.m_lpContainer:getPosition()
	local rx=self.m_stageView:getMapViewrx()-__WinSize.width
	local downMoveX=-_x*__WidScale
	if _dir~=nil then
		downMoveX=-(rx+ContainerX)
	else
	    if ContainerX+downMoveX>0 then
	    	CCLOG("[PlotView.moveMap] 移出地图左边了，调整")
	    	downMoveX=-ContainerX
	    elseif ContainerX+downMoveX<-rx then
	    	CCLOG("[PlotView.moveMap] 移出地图右边了，调整")
	    	downMoveX=-rx-ContainerX
	    end
	end
	print("YYYYYYYYYYYY+======>>>>>>",_x,_speed,downMoveX,rx,__WinSize.width,ContainerX)

	local upMoveX=downMoveX/3
	if downMoveX==0 or _speed==0 then
		local_moveEnd()
		return
	end

	local distanceTime=math.abs(downMoveX)/_speed
    local act1=cc.MoveBy:create(distanceTime,cc.p(downMoveX,0))
    local act2=cc.CallFunc:create(local_moveEnd)
    local downAction=cc.Sequence:create(act1,act2)

    self.m_stageView.m_lpContainer:runAction(downAction)
    if not self.m_stageView.m_disMapNoMove then
    	self.m_stageView.m_lpMapDisContainer:runAction(cc.MoveBy:create(distanceTime,cc.p(upMoveX,0)))
    end
end

--对话
function PlotView.openTalkView(self)
	CCLOG("[剧情]-展开对话")
	local data  =self.m_plotData.item[self.m_plotIndex]
	local roleId=data.id
	local dir   =data.dir
 	local name  =nil
 	local sprName= nil
 	if roleId==-1 then
 		name=self.m_roleName or "player name"
 		roleId=0
 	else
 		name=data.name or "table name"
 	end

	local function local_bgActionEnd()
		local startOpa=20
	 	self.m_talkLabel:setOpacity(startOpa)
	 	self.m_nameLabel:setOpacity(startOpa)
		self.m_nameLabel:setString(name)
		self.m_talkLabel:setString(data.msg or "XXXXXXX")
		if dir==_G.Const.CONST_DRAMA_DIR_EAST then
			--人物在右边
			self.m_nameLabel:setPosition(cc.p(self.m_npcSpr_Wid+15,85))
			self.m_talkLabel:setPosition(cc.p(self.m_npcSpr_Wid+15,70))
		else
			self.m_nameLabel:setPosition(cc.p(self.m_talk_pyWid,85))
			self.m_talkLabel:setPosition(cc.p(self.m_talk_pyWid,70))
		end
		
		--创建角色图片
		self:showTalkRole(roleId,dir)

		local function local_showArrowEffect()
			self:showArrowEffect(dir)
		end

		local function local_chuangeToEndType()
			self.m_poltType=TYPE_TALK_END
		end

		local function local_talkDelayEnd()
			if data.hand==0 then
				self:closeTalkView()
			end
		end

		local soundStr=data.sound_id
		if soundStr~=nil and soundStr~="nil" and soundStr~="undefined" and soundStr~=0 and soundStr~="0" then
			_G.Util:playAudioEffect(soundStr)
			print("[剧情]-对话,有音效。  soundStr=",soundStr)
		else
			print("[剧情]-对话,无音效。  soundStr=",soundStr)
		end

		local delayTimes=tonumber(data.sound_time) or 0
		print("[剧情]-对话,配置延迟时间  delayTimes=",delayTimes)

		local midDelayTime=0.1+delayTimes
		local fadeTimes=TIME_TALKACTION
		self.m_talkLabel:runAction(cc.Sequence:create(cc.FadeTo:create(fadeTimes,255),
													  cc.CallFunc:create(local_showArrowEffect),
													  cc.DelayTime:create(midDelayTime),
													  cc.CallFunc:create(local_chuangeToEndType),
													  cc.DelayTime:create(TIME_TALKDELAY),
													  cc.CallFunc:create(local_talkDelayEnd)))
		self.m_nameLabel:runAction(cc.FadeTo:create(fadeTimes,255))
    end

    local _showtime=TIME_BGACTION   
    local _actionUp=cc.MoveTo:create(_showtime,__UpPos)
    self.m_upBackground:runAction(_actionUp)

    local act1=cc.MoveTo:create(_showtime,__DownPos)
    local act2=cc.CallFunc:create(local_bgActionEnd)
    self.m_downBackground:runAction(cc.Sequence:create(act1,act2))

    local act3=cc.FadeTo:create(_showtime,80)
    act3:setTag(6666)
    self.m_rootLayer:stopActionByTag(6666)
    self.m_rootLayer:runAction(act3)

    self.m_poltType=TYPE_WAIT_STEP
end

function PlotView.closeTalkView(self)
	CCLOG("[剧情]-关闭对话")
	self:removeRoleSprite()
	self:hideArrowEffect()

	local function local_bgActionEnd()
		self:goNextAction()
	end

	local function local_fun()
		if self.m_plotData.item[self.m_plotIndex+1]~=nil then
			if self.m_plotData.item[self.m_plotIndex+1].act==_G.Const.CONST_DRAMA_ACT_DIALOGUE then
				-- 下个还是对话
				local_bgActionEnd()
				return
			end
		end

		local _showtime=TIME_BGACTION   
		local _actionUp=cc.MoveTo:create(_showtime,cc.p(__WinSize.width*0.5,__WinSize.height+__UpSize.height*0.5))
	    self.m_upBackground:runAction(_actionUp)

	    local act1=cc.MoveTo:create(_showtime,cc.p(__WinSize.width*0.5,-__DownSize.height*0.5))
	    local act2=cc.CallFunc:create(local_bgActionEnd)
	    self.m_downBackground:runAction(cc.Sequence:create(act1,act2))
	end

	local fadeTimes=TIME_TALKACTION*0.5
	local act1=cc.FadeTo:create(fadeTimes,0)
	local act2=cc.CallFunc:create(local_fun)

	self.m_talkLabel:stopAllActions()
	self.m_nameLabel:stopAllActions()
	self.m_talkLabel:runAction(cc.Sequence:create(act1,act2))
	self.m_nameLabel:runAction(cc.FadeTo:create(fadeTimes,0))

	local act3=cc.FadeTo:create(fadeTimes,0)
    act3:setTag(6666)
    self.m_rootLayer:stopActionByTag(6666)
    self.m_rootLayer:runAction(act3)

	self.m_poltType=TYPE_WAIT_STEP
end

function PlotView.showArrowEffect(self, _dir)
	if _dir==nil then return end

	local function local_resetPos()
		if _dir==_G.Const.CONST_DRAMA_DIR_EAST then
			self.m_arrowsSpr:setPosition(cc.p(__WinSize.width-50,35))
		else
			self.m_arrowsSpr:setPosition(cc.p(50,35))
		end
	end

	if self.m_arrowsSpr~=nil then
		self.m_arrowsSpr:setVisible(true)
		local_resetPos()
		return
	end

	local moveA=cc.MoveBy:create(0.5,cc.p(0,20))
    self.m_arrowsSpr=cc.Sprite:createWithSpriteFrameName("general_tip_down.png")
    self.m_arrowsSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(moveA,moveA:reverse())))
    self.m_arrowsSpr:setRotation(90)
    self.m_arrowsSpr:setScale(0.7)
    self.m_mainNode:addChild(self.m_arrowsSpr,100)

    -- local arrowSize=self.m_arrowsSpr:getContentSize()
    -- local guidWordSpr=cc.Sprite:createWithSpriteFrameName("task_word_dj.png")
    -- guidWordSpr:setPosition(cc.p(arrowSize.width*0.5,arrowSize.height+15))
    -- self.m_arrowsSpr:addChild(guidWordSpr)

    local_resetPos()
end
function PlotView.hideArrowEffect(self)
	if self.m_arrowsSpr~=nil then
		self.m_arrowsSpr:setVisible(false)
	end
end




--进入下一步动作
function PlotView.goNextAction(self)
	CCLOG("\n \n[剧情]-进入下一步")
	CCLOG("当前步数 idx=%d",self.m_plotIndex)
	-- print(debug.traceback())

	if self.m_roleSprLoader~=nil or self.m_npcLoader~=nil then
		return
	end

	self.m_plotIndex=self.m_plotIndex+1 --下一步Index

	local itemList=self.m_plotData.item
	local item 	  =itemList[self.m_plotIndex]
	if not item then 
		--完结了 
		self:resetPlotView()
		return
	end

	local data=item
	local act =data.act

	CCLOG("动作类型 act=%d",act)
	if act==_G.Const.CONST_DRAMA_ACT_APPEAR then
		--添加人物
		if data.id==-1 then 
			--主角
			if data.x~=0 then
				local ContainerX, ContainerY=self.m_stageView.m_lpContainer:getPosition()
				print("--添加主角->",data.x,ContainerX,-ContainerX+data.x*__WidScale, data.y)
				self.m_stageView:getMainPlayer():setLocationXY(-ContainerX+data.x*__WidScale,data.y)
			end

			local scaleX=(data.dir==_G.Const.CONST_DRAMA_DIR_WEST) and -1 or 1
			self.m_stageView:getMainPlayer():getContainer():setVisible(true)
			self.m_stageView:getMainPlayer():setMoveClipContainerScalex(scaleX)
			self:autoGoNextStep(data.hand)
		else
			local szAnimation=nil
			if data.pos~=nil and data.pos~="idle1" then
				szAnimation=data.pos
			end
			self:createPlotMonster(data.type, data.id, data.name, cc.p(data.x, data.y), data.dir, data.absolute, szAnimation)
		end
	elseif act==_G.Const.CONST_DRAMA_ACT_DIALOGUE then
		--对话,先加载到半身像
		self:openTalkView()
	elseif act==_G.Const.CONST_DRAMA_ACT_MOVE then 
		--移动
		self.m_poltType=TYPE_WAIT_STEP
		self:roleMove(data.id,cc.p(data.x,data.y),data.animation)
	-- elseif act==_G.Const.CONST_DRAMA_ACT_LEAVE then
	-- 	--人物离开
	-- 	self:roleLeave(data.)
	elseif act==_G.Const.CONST_DRAMA_ACT_DISAPPEAR then 
		--人物消失
		self:roleRemove(data.id,false)
		self:autoGoNextStep(data.hand)
	elseif act==_G.Const.CONST_DRAMA_ACT_DEATH then
		--人物死亡
		if self.m_stageView.m_isPassWar then
			self.m_stageView:getMainPlayer().m_isCorpse=true
			self.m_stageView:getMainPlayer():setStatus(_G.Const.CONST_BATTLE_STATUS_DEAD)
		-- 	self.m_stageView:getMainPlayer():setHP(-self.m_stageView:getMainPlayer():getHP())--setStatus(_G.Const.CONST_BATTLE_STATUS_DEAD)
			self:autoGoNextStep(data.hand)
		end
	elseif act==_G.Const.CONST_DRAMA_ACT_NORMAL_STATE then
		--恢复主角到初始状态
		CCLOG("[剧情]-恢复主角到初始状态")
		_G.g_BattleView:removeAllAttributeAdd()
		self.m_stageView:getMainPlayer():removeBuff(_G.Const.CONST_BATTLE_BUFF_ENDUCE)--1401
		self:autoGoNextStep(data.hand)
	elseif act==_G.Const.CONST_DRAMA_ACT_CAMERA then
		--移动地图
		self.m_poltType=TYPE_WAIT_STEP
		self:moveMap(data.speed,data.x,data.dir)
	elseif act==_G.Const.CONST_DRAMA_ACT_NORMAL_ATTACK or act==_G.Const.CONST_DRAMA_ACT_UNIQUE_SKILL then
		--释放技能
		self.m_poltType=TYPE_WAIT_STEP
		self:playSkill(data.id,data.skillId)
	elseif act==_G.Const.CONST_DRAMA_ACT_ALERT then
		--小助手
		self.m_poltType=TYPE_WAIT_STEP
		self:createHandGuide(data.id, data.msg, data.name, data.dir, data.sound_id)
	elseif act==_G.Const.CONST_DRAMA_ACT_FULLTER then
		--人物飘移
		self.m_poltType=TYPE_WAIT_STEP
		self:createRoleFlutter(data.id, data.msg, data.name, data.dir, data.sound_id)
	elseif act==_G.Const.CONST_DRAMA_ACT_EFFECT then
		--添加特效
		self:createEffectSpr(data.id,cc.p(data.x,data.y))
		self:autoGoNextStep(data.hand)
	elseif act==_G.Const.CONST_DRAMA_ACT_SHOCK then
		-- 震屏
		local nHei=data.id
		if nHei==0 then
			self:goNextAction()
		else
			self.m_stageView:vibrate(3,nHei,nHei*0.002)
			self:autoGoNextStep()
		end
	elseif act==_G.Const.CONST_DRAMA_ACT_ADDATTR then
		--加属性
		CCLOG("[剧情]-加属性")
		if data.id==-1 and data.attr_type~=nil and data.attr_val~=nil then
			local msg={}
			msg.type=data.attr_type
			msg.value=data.attr_val*10000
			local command=CPlotCammand(CPlotCammand.ADDATTR)
			command.msg=msg
			controller:sendCommand(command)
			CCLOG("[剧情]-加属性-成功")
		end
		self:autoGoNextStep()
	elseif act==_G.Const.CONST_DRAMA_ACT_ADDBUFF then
		--加霸体
		CCLOG("[剧情]-加霸体")
		local invBuff=_G.GBuffManager:getBuffNewObject(1401,0)
    	self.m_stageView:getMainPlayer():addBuff(invBuff) 
		self:autoGoNextStep()
	elseif act==_G.Const.CONST_DRAMA_ACT_ADDBIGSKILL then
		--开启大招
		CCLOG("[剧情]-开启大招")
		self.m_stageView:getMainPlayer():addMP(100)
		if self.m_stageView.m_FirstBattleGuideView~=nil then
			self.m_stageView.m_FirstBattleGuideView:createSkill4Guide()
		end
		self:autoGoNextStep()
	elseif act==_G.Const.CONST_DRAMA_ACT_CLEANBODY then
		print("YUYUYUYUYU====>>>>>>>",data.id)
		self:removeCorpse(data.id)
	else
		--其他效果暂时没做
		self:goNextAction()
		return
	end

end

function PlotView.autoGoNextStep(self, _hand)
	local autoHand=_hand
	if autoHand==nil then
		local data=self.m_plotData.item[self.m_plotIndex]
		if data==nil then
			self:goNextAction()
			return
		end
		autoHand=data.hand
	end

	if autoHand==0 then
		self:goNextAction()
	else
		self.m_poltType=TYPE_WAIT_TOUCH
	end
end


function PlotView.unloadResources(self)
	_G.ScenesManger.releaseFileArray(self.m_releaseResourcesList)
    -- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end

function PlotView.resetPlotView(self)
	CCLOG("[剧情]-剧情结束")
	if self.m_poltType==TYPE_FINISH then return end
	
	local isEndCopy=self.m_plotData.touchType==_G.Const.CONST_DRAMA_FINISHE
	local function local_fun()
		CCLOG("resetPlotView  999999")
		self:finishPlot(isEndCopy)
	end

	if self.m_stageView.m_plotFirstGame and isEndCopy then
		local_fun()
		return
	end
	CCLOG("resetPlotView  11")

	local playerScaleX=self.m_stageView:getMainPlayer().m_nScaleX
	local playerPosX=self.m_stageView:getMainPlayer():getLocationX()
	local mapPos   =cc.p(self.m_stageView.m_lpContainer:getPosition())
	--最左边的X位置
    local lx=self.m_stageView:getMapViewlx()
    local rx=self.m_stageView:getMapViewrx()
    local winSize=__WinSize

    local moveMapX=mapPos.x




    if playerPosX<lx+winSize.width*0.5 then
    	moveMapX=lx
    elseif playerPosX>rx-winSize.width*0.5 then
    	moveMapX=-rx+winSize.width
    else
    	moveMapX=-playerPosX+winSize.width*0.5
    end
    local times=math.abs(moveMapX-mapPos.x)/900+0.01
    local act1=cc.MoveTo:create(times,cc.p(moveMapX,mapPos.y))
    local act2=cc.CallFunc:create(local_fun)
    self.m_stageView.m_lpContainer:runAction(cc.Sequence:create(act1,act2))
    local x,y=self.m_stageView.m_lpMapDisContainer:getPosition()
    if not self.m_stageView.m_disMapNoMove then
    	self.m_stageView.m_lpMapDisContainer:setPosition(moveMapX,y)
    end


 --    local isHasMove=true
 --    if playerScaleX>0 then
 --        if playerPosX<self.m_stageView.winSizeLPiece then
 --        	isHasMove=false
 --        else
 --        	moveMapX=-playerPosX+self.m_stageView.winSizeLPiece
 --        end
 --    else
 --        if playerPosX>(-mapPos.x-self.m_stageView.winSizeRPiece) then
 --        	isHasMove=false
 --        else
 --        	moveMapX=-playerPosX+self.m_stageView.winSizeRPiece
 --        end
 --    end
 --    if isHasMove then
	--     local rMaxX=-(rx - winSize.width)
	--     moveMapX=moveMapX<rMaxX and rMaxX or moveMapX
	--     moveMapX=moveMapX>-lx and -lx or moveMapX

	--     local times=math.abs(moveMapX-mapPos.x)/900+0.01
	--     local act1=cc.MoveTo:create(times,cc.p(moveMapX,mapPos.y))
	--     local act2=cc.CallFunc:create(local_fun)
	--     self.m_stageView.m_lpContainer:runAction(cc.Sequence:create(act1,act2))
	--     local x,y=self.m_stageView.m_lpMapDisContainer:getPosition()
	--     if not self.m_stageView.m_disMapNoMove then
	--     	self.m_stageView.m_lpMapDisContainer:setPosition(moveMapX,y)
	--     end
	-- else
	-- 	local_fun()
	-- end

    CCLOG("resetPlotView  44")

    self.m_poltType=TYPE_FINISH
end

function PlotView.finishPlot(self,_isEndCopy)
	CCLOG("finishPlot----->>>")
	if self.m_rootLayer~=nil then 
		self.m_rootLayer:removeFromParent(true)
		self.m_rootLayer=nil
	end

	--移除创建的怪物(monster)
	for tag,v in pairs(self.m_characterList) do
		self:roleRemove(tag,true,_isEndCopy)
	end

	--清除特效物品
	if self.m_effectList~=nil then
		for k,node in pairs(self.m_effectList) do
			node:removeFromParent(true)
		end
		self.m_effectList=nil
	end
	
	--调用播放剧情后的方法
	self.m_delege:finishPlot(self.m_plotData)

	self:unloadResources()

	if self.m_plotData.id==_G.Const.CONST_COPY_FIRST_BIGSKILL_PLOT then
		local guideView=require("mod.map.PlotBigSkill")()
		guideView:startPlot()
	end

	local monsterArray=_G.CharacterManager.m_lpMonsterArray
	for k,v in pairs(monsterArray) do
		if self.m_realMonsterArray[v]==nil then
			if v.movieType~=nil and v.movieType>=_G.Const.CONST_MONSTER_JUMP and v.movieType <= 20 then
				print("IIIIIIIIOOOOOOOO=====>>>>>",v.movieType)
				v:initMovie(v.m_nLocationX,v.m_nLocationY,v.movieType)
				v.movieType=nil
			end
		else
			v.movieType=nil
		end
	end
end




--æææææææææææææææææææææææææææææææææææææææ
--按钮回调
--æææææææææææææææææææææææææææææææææææææææ
--全屏回调
function PlotView.__layerTouchBegan(self)
	print("------------", self.m_poltType)
	if self.m_poltType==TYPE_WAIT_STEP then
		print("return")
		--不响应点击
		return
	end

	--剧情播放阶段
	if self.m_poltType==TYPE_TALK_END then
		--对话完 点击进入下一步动作
		print("TYPE_TALK_END")
		self:closeTalkView()
	elseif self.m_poltType==TYPE_WAIT_TOUCH then
		--等待点击 点击进入下一步
		print("TYPE_WAIT_TOUCH")
		self:goNextAction()
	elseif self.m_poltType==TYPE_WAIT_MOVE then
		print("TYPE_WAIT_MOVE")
		if self.m_stageView:getMainPlayer().m_lpMovePos==nil then
			self:goNextAction()
		end
	end

	print("PlotView.__layerTouchBegan===")
end

return PlotView



