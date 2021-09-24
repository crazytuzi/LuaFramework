local GuideManager=classGc(function(self)
	self.m_mediator=require("mod.support.GuideMediator")(self)

	self.m_curGuideCnf=nil
	self.m_winSize=cc.Director:getInstance():getWinSize()
end)

function GuideManager.checkGuide(self,_touchId)
	print("checkGuide=====>>",_touchId)
	
	local guideData=self:__getGuideCnf(_touchId)
	if guideData==nil then return end

	print("checkGuide=====>>   22222,",_touchId)
	self:removeGuide()
	self.m_curGuideCnf=guideData
	if self.m_curGuideCnf.id==_G.Const.CONST_NEW_GUIDE_SYS_COPY then
		self.m_curGuideCnf=nil
		self.m_mopGuideCnf=guideData
		return
	end

	local command=CActivityIconCommand(CActivityIconCommand.HIDE_TASK_GUIDE)
	_G.controller:sendCommand(command)

	local command=CGuideNoticAdd()
	command.sysId=guideData.entry_id
	_G.controller:sendCommand(command)
end

function GuideManager.deleteThisGuide(self,_touchId)
	if self.m_curGuideCnf==nil then return end

	local guideData=self:__getGuideCnf(_touchId)
	if guideData==nil then return end

	if self.m_curGuideCnf.id==guideData.id then
		self:removeGuide()
	end
end

function GuideManager.__getGuideCnf(self,_touchId)
	-- if _touchId==nil then return end
	-- local typeArray=_G.Cfg.guide[1]
	-- if typeArray==nil then return end
	return _G.Cfg.guide[_touchId]
end

function GuideManager.getCurGuideId(self)
	return self.m_curGuideCnf and self.m_curGuideCnf.id or nil
end
function GuideManager.getCurGuideCnf(self)
	return self.m_curGuideCnf
end

function GuideManager.removeGuide(self)
	-- self:clearGuideData()
	self.m_mopGuideCnf=nil
	if self.m_curGuideCnf==nil then return end

	local entryId=self.m_curGuideCnf.entry_id
	local guideId=self.m_curGuideCnf.id
	self.m_curGuideCnf=nil

	local command=CGuideNoticDel()
	command.sysId=entryId
	command.guideId=guideId
	_G.controller:sendCommand(command)
end









function GuideManager.clearGuideData(self)
	self.m_curGuideStep=0
	self.m_registDataArray={}

	self.m_guideNode=nil
	self.m_handSpr=nil
	self.m_grilSpr=nil
	self.m_touchEffect=nil
	self.m_focusLigthEffect=nil
	self.m_noticSpr=nil
	self.m_noticLabel=nil
end
function GuideManager.initGuideView(self,_parent)
	self:clearGuideData()
	self.m_guideParent=_parent

	print("[新手指引] initGuideView==>",self.m_curGuideCnf.id,_parent)
end
function GuideManager.getCurStep(self)
	return self.m_curGuideStep
end
function GuideManager.registGuideData(self,_step,_btn)
	print("[新手指引] registGuideData==>",_step,_btn)
	if not _step or not self.m_curGuideCnf then
		return
	end

	local stepInfo=self.m_curGuideCnf.step[_step]
	if stepInfo==nil then return end

	local tempT={
		btn=_btn,
		szNotic=stepInfo.notic,
	}

	local midInfo=stepInfo.notic_mid
	if midInfo~=nil and type(midInfo)=="table" and midInfo[1] and midInfo[2] then
		local noticMid=cc.p(midInfo[1],midInfo[2])
		noticMid.x=noticMid.x<0 and 0 or noticMid.x
		noticMid.x=noticMid.x>1 and 1 or noticMid.x
		noticMid.y=noticMid.y<0 and 0 or noticMid.y
		noticMid.y=noticMid.y>1 and 1 or noticMid.y
		tempT.noticMid=noticMid
	else
		tempT.noticMid=cc.p(0.5,0.5)
	end
	local offInfo=stepInfo.notic_off
	if offInfo~=nil and type(offInfo)=="table" and offInfo[1] and offInfo[2] then
		tempT.noticOff=cc.p(offInfo[1],offInfo[2])
	else
		tempT.noticOff=cc.p(0,-80)
	end

	local dragInfo=stepInfo.drag
	if dragInfo~=nil and type(dragInfo)=="table" and dragInfo[1] and dragInfo[2] and dragInfo[3] then
		tempT.isDrag=true
		tempT.dragTime=dragInfo[1]
		tempT.dragOff=cc.p(dragInfo[2],dragInfo[3])
	end

	tempT.isOverturn=stepInfo.turn==1

	self.m_registDataArray[_step]=tempT
	print("registGuideData===>>> OK")
end
function GuideManager.hideGuideByStep(self,_step)
	if self.m_guideNode==nil then return end
	if self.m_curGuideStep==_step then
		self.m_guideNode:setVisible(false)
	end
end
function GuideManager.showGuideByStep(self,_step)
	if self.m_guideNode==nil then return end
	if self.m_curGuideStep==_step then
		self.m_guideNode:setVisible(true)
	end
end
function GuideManager.removeCurGuideNode(self)
	if self.m_guideNode~=nil then
		self.m_guideNode:removeFromParent(true)
		self.m_guideNode=nil
	end
end
function GuideManager.clearCurGuideNode(self)
	self:removeCurGuideNode()
	self:clearGuideData()
	self:removeGuide()
end
function GuideManager.runPreStep(self)
	if self.m_curGuideStep<=1 then return end
	self.m_curGuideStep=self.m_curGuideStep-2
	self:runNextStep()
end
function GuideManager.runThisStep(self,_step)
	if _step==nil then return end
	self.m_curGuideStep=_step-1
	self:runNextStep()
end
function GuideManager.runNextStep(self)
	self.m_curGuideStep=self.m_curGuideStep+1

	print("[新手指引] runNextStep==>",self.m_curGuideStep)
	local curRegistData=self.m_registDataArray[self.m_curGuideStep]
	if curRegistData==nil then
		print("[新手指引] runNextStep==>没有下一步")
		self:clearCurGuideNode()
		return
	elseif self.m_guideParent==nil then
		print("[新手指引] runNextStep==>ERROR 没有设置parent")
		self:clearCurGuideNode()
		return
	end

	local guideBtn=curRegistData.btn
	local btnSize=guideBtn:getContentSize()
	local curWorldPos=guideBtn:convertToWorldSpace(cc.p(0,0))
	local nScale=guideBtn:getScale()*0.5
	curWorldPos=cc.p(curWorldPos.x+btnSize.width*nScale,curWorldPos.y+btnSize.height*nScale)
	print("runNextStep=====>>>curWorldPos=",curWorldPos.x,curWorldPos.y)

	if self.m_guideNode==nil then
		self.m_guideNode=cc.Node:create()
		self.m_guideNode:setPosition(curWorldPos)
		self.m_guideParent:addChild(self.m_guideNode,999)

		self.m_touchEffect=self:createTouchEffect()
		self.m_guideNode:addChild(self.m_touchEffect)

		self.m_focusLigthEffect=self:getFocusNode()
		self.m_guideNode:addChild(self.m_focusLigthEffect)

		self.m_handSpr=cc.Sprite:create("icon/guide_hand.png")
		self.m_handSpr:setScale(0.6)
		self.m_handSpr:setAnchorPoint(cc.p(0.8,0.9))
		self.m_guideNode:addChild(self.m_handSpr,100)

		_G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
		self.m_noticSpr=cc.Sprite:create("icon/guide_notic_bg.png")
    	self.m_noticSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,200),cc.FadeTo:create(1,255))))
    	self.m_guideNode:addChild(self.m_noticSpr,100)
    	_G.SysInfo:resetTextureFormat()

    	local sprSize=self.m_noticSpr:getContentSize()
    	local grildSpr=cc.Sprite:create("icon/guide_grild.png")
    	grildSpr:setPosition(-30,70)
    	grildSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1,cc.p(0,10)),cc.MoveBy:create(1,cc.p(0,-10)))))
    	self.m_noticSpr:addChild(grildSpr)
    	self.m_grilSpr=grildSpr

    	self.m_noticLabel=_G.Util:createLabel(curRegistData.szNotic,20)
    	self.m_noticLabel:setPosition(sprSize.width*0.5-20,sprSize.height*0.5)
    	self.m_noticSpr:addChild(self.m_noticLabel)

    	self:__runHandSprTouchAction()
    else
    	self.m_guideNode:stopAllActions()
    	self.m_handSpr:stopAllActions()
    	self.m_handSpr:setPosition(0,0)
    	self.m_noticLabel:setString(curRegistData.szNotic)

    	local function nDelay()
    		self.m_noticSpr:setVisible(true)
    		if curRegistData.isDrag then
    			self:__runHandSprDragAction(curRegistData.dragTime,curRegistData.dragOff)
    			self.m_focusLigthEffect:setVisible(false)
    		else
    			self:__runHandSprTouchAction()
    			self.m_focusLigthEffect:setVisible(true)
    		end
    	end

    	local preWorldPos=cc.p(self.m_guideNode:getPosition())
    	local distance=cc.pGetDistance(preWorldPos,curWorldPos)
		local nTimes=distance*0.0008
    	self.m_guideNode:runAction(cc.Sequence:create(cc.MoveTo:create(nTimes,curWorldPos),cc.CallFunc:create(nDelay)))

    	self.m_focusLigthEffect:setVisible(false)
    	self.m_touchEffect:setVisible(false)
    	self.m_noticSpr:setVisible(false)
    end
    if curRegistData.isOverturn then
    	self.m_noticSpr:setScaleX(1)
    	self.m_noticLabel:setScaleX(1)
    else
    	self.m_noticSpr:setScaleX(-1)
    	self.m_noticLabel:setScaleX(-1)
    end
    if curWorldPos.y>500 then
    	self.m_grilSpr:setVisible(false)
    else
    	self.m_grilSpr:setVisible(true)
    end
	self.m_noticSpr:setAnchorPoint(curRegistData.noticMid)
	self.m_noticSpr:setPosition(curRegistData.noticOff)
end
function GuideManager.__runHandSprTouchAction(self)
	print("__runHandSprTouchAction====>>>>>>>")
	self.m_touchEffect:setVisible(true)
	self.m_handSpr:stopAllActions()
	self.m_handSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,-20)),cc.MoveBy:create(0.5,cc.p(0,20)))))
end
function GuideManager.__runHandSprDragAction(self,_times,_off)
	if _times==nil or _off==nil then return end
	print("__runHandSprDragAction====>>>>>>>")
	self.m_touchEffect:setVisible(false)
	self.m_handSpr:stopAllActions()
	self.m_handSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(_times,cc.p(_off.x,_off.y)),cc.MoveBy:create(0.01,cc.p(-_off.x,-_off.y)))))
end

function GuideManager.createTouchEffect(self)
	local tempSpr=cc.Sprite:createWithSpriteFrameName("general_guide_touch.png")
	local function nFun()
		tempSpr:stopActionByTag(168)
		tempSpr:setScale(1)
		tempSpr:setOpacity(255)

		local subAction=cc.ScaleTo:create(1,2)
		subAction:setTag(168)
		tempSpr:runAction(subAction)
	end
	local tempAction=cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(nFun),cc.FadeTo:create(1,0)))
	tempSpr:runAction(tempAction)
	return tempSpr
end
function GuideManager.createTouchNode(self,_isNoChuang,_nScale,_isNoTouchEffect)
	_nScale=_nScale or 0.6
	local tempNode=cc.Node:create()
	local handSPr=cc.Sprite:create("icon/guide_hand.png")
	handSPr:setScale(_nScale)
	tempNode:addChild(handSPr,10)
	if not _isNoChuang then
		handSPr:setScaleX(-_nScale)
	end
	handSPr:setAnchorPoint(cc.p(0.8,0.9))
	handSPr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,-20)),cc.MoveBy:create(0.5,cc.p(0,20)))))

	local touchEff=self:createTouchEffect()
	tempNode:addChild(touchEff)
	if not _isNoTouchEffect then
		tempNode:addChild(self:getFocusNode())
	end

	return tempNode
end
function GuideManager.createNoticNode(self,_szNotic,_isTurn)
	_G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	local tempSpr=cc.Sprite:create("icon/guide_notic_bg.png")
	_G.SysInfo:resetTextureFormat()

	local sprSize=tempSpr:getContentSize()
	local grildSpr=cc.Sprite:create("icon/guide_grild.png")
	grildSpr:setPosition(-30,70)
	tempSpr:addChild(grildSpr)

	local tempLabel=_G.Util:createLabel(_szNotic or "【ERROR】",20)
	tempLabel:setPosition(sprSize.width*0.5-20,sprSize.height*0.5)
	tempSpr:addChild(tempLabel)

	if not _isTurn then
		tempSpr:setScaleX(-1)
		tempLabel:setScaleX(-1)
	end

	tempSpr:setOpacity(0)
	grildSpr:setOpacity(0)
	tempLabel:setOpacity(0)

	local function nFun()
		tempSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,200),cc.FadeTo:create(1,255))))
		grildSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1,cc.p(0,10)),cc.MoveBy:create(1,cc.p(0,-10)))))
	end
	tempSpr:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,255),cc.CallFunc:create(nFun)))
	grildSpr:runAction(cc.FadeTo:create(0.2,255))
	tempLabel:runAction(cc.FadeTo:create(0.2,255))

	return tempSpr
end
function GuideManager.getFocusNode(self)
	local tempTimes=1.2
	local function nFun(_node)
		_node:setScale(50)
		_node:setOpacity(100)
		_node:runAction(cc.FadeTo:create(tempTimes*0.5,255))
	end

	local bigLight=cc.Sprite:createWithSpriteFrameName("general_box_choice.png")
	bigLight:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(nFun),cc.EaseExponentialOut:create(cc.ScaleTo:create(tempTimes,1)),cc.FadeTo:create(0.2,0),cc.DelayTime:create(0.4))))
	return bigLight
end

return GuideManager