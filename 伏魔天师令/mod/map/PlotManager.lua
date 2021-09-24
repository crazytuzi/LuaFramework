local PlotManager = classGc(view,function ( self )
	self.m_isVisible = true
end)

-- _G.Const.CONST_DRAMA_GETINTO  --进入场景(副本)
-- _G.Const.CONST_DRAMA_FINISHE --完成副本
-- _G.Const.CONST_DRAMA_TRIGGER  --任务触发
-- _G.Const.CONST_DRAMA_ENCOUNTER --遇到指定BOSS
-- _G.Const.CONST_DRAMA_DEFEAT    --打死指定BOSS

--检查是否存在剧情   参数: _touchType(触发类型-> 参考上面的常量) _touchId(触发的Id-> bossID或者副本ID或任务Id)
function PlotManager.checkPlot(self,_touchType,_touchId)
	if _touchType==nil or _touchId==nil then return end

	CCLOG("[检查剧情] 触发类型=%d,触发ID=%d",_touchType,_touchId)
	
	local plotData=self:getPlotDataByListAndArg(_touchType,_touchId)
	if plotData==nil then 
		CCLOG("[检查剧情] 不存在剧情----------------")
		return false
	end

	if self:checkCopyPass(_touchType,_touchId) then
		return false
	end

	plotData.touchType=_touchType
	plotData.touchId  =_touchId

	CCLOG("[检查剧情] 存在剧情！！！")
	return plotData
end
function PlotManager.runThisPlot(self,_plotData,_finishFun,_delayTimes)
	if not _delayTimes or _delayTimes==0 then
		self:showPlot(_plotData,_finishFun)
	else
		local function nFun()
			self:showPlot(_plotData,_finishFun)
		end
		_G.Scheduler:performWithDelay(_delayTimes,nFun)
	end
	return true
end

function PlotManager.checkCopyPass(self,_touchType,_touchId)
	if _G.GSystemProxy.isInfinityPlot then return false end

	if _touchType==_G.Const.CONST_DRAMA_GETINTO 
		or _touchType==_G.Const.CONST_DRAMA_FINISHE
		or _touchType==_G.Const.CONST_DRAMA_ENCOUNTER then

		if _touchId~=_G.Const.CONST_COPY_FIRST_COPY and _G.GCopyProxy~=nil then
			--刚进入场景 完成副本 判断是否通关
			local curCopyId=_G.g_Stage:getScenesCopyID()
			local sceneCopyCnf = _G.Cfg.scene_copy[curCopyId]
			local duplicateList=_G.GCopyProxy:getCopyChapData(sceneCopyCnf.copy_type) or {}

			for jj,section in ipairs(duplicateList) do
				for i,v in pairs(section.data) do
					-- print(i,v.copy_id,v.eva)
					if v.copy_id==curCopyId and v.eva>0 then 
						--已通关过 
						CCLOG("[检查剧情] 有剧情，但是该副本已通关~~~~")
						return true
					end
				end
			end

			if _touchType==_G.Const.CONST_DRAMA_FINISHE then
				local curSceneId   = _G.g_Stage:getScenesID()
				local sceneNode    = sceneCopyCnf.scene
				if curSceneId~=sceneNode[#sceneNode].id then
					CCLOG("[检查剧情] 有剧情(场景通关后)，但是不是最后一个副本场景")
					return true
				end
			end
		end
	end
	return false
end

function PlotManager.checkPlotHidePlayer(self)
	local _touchType=_G.Const.CONST_DRAMA_GETINTO
	local _touchId=_G.g_Stage:getScenesCopyID()
	local plotData=self:getPlotDataByListAndArg(_touchType,_touchId)
	if plotData==nil then 
		CCLOG("[检查剧情] 不存在剧情----------------")
		return false
	end
	if self:checkCopyPass(_touchType,_touchId) then
		return false
	end
	for k,v in ipairs(plotData.item) do
		if v.act==_G.Const.CONST_DRAMA_ACT_APPEAR and v.id==-1 then
			return true
		end
	end
	return false
end

--播放剧情
function PlotManager.showPlot( self, _plotData, _fun )
	if self.m_plotView~=nil then
        -- self.m_plotView :resetPlotView()
        return
	end

	self.m_goFun=_fun

	local nStage=_G.g_Stage
	_plotData.isAutoFightMode=nStage.isAutoFightMode
	_plotData.isSlowMotionMapPos=nStage.m_slowMotionMapPos
	nStage.m_slowMotionMapPos=true
	nStage:moveAreaStop()
	nStage:setStopAI(true)
	nStage:setSomeViewVisible(false)
	nStage:getMainPlayer().unlimitPosition=true
	nStage:stopAutoFight(true)

	if not _G.g_Stage.m_plotFirstGame then
		nStage:setCharacterVisible(false)
	else
		nStage:setCharacterVisible(true,0)
	end
	nStage:getMainPlayer():getContainer():setVisible(true)
	for k,v in pairs(nStage:getMainPlayer().m_buff) do
		if k==_G.Const.CONST_BATTLE_BUFF_ENDUCE
			or k==_G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER 
			or k==_G.Const.CONST_BATTLE_BUFF_POISON 
			or k==_G.Const.CONST_BATTLE_BUFF_BURN 
			or k==_G.Const.CONST_BATTLE_BUFF_SPEED
			then 
			nStage:getMainPlayer():removeBuff(k)
		end
	end

	self.m_startTimes=_G.TimeUtil:getTotalSeconds()
	self.m_deadlineTime=nStage.m_deadlineTime
	nStage.m_deadlineTime=nil

    self.m_plotView=require("mod.map.PlotView")(_plotData)
    self.m_plotView:setDelege(self)
    self.m_plotLayer=self.m_plotView:createPlot()
    nStage:getScene():addChild(self.m_plotLayer,_G.Const.CONST_MAP_ZORDER_LAYER)
    --发送剧情开始 命令

    if not self.m_isVisible then
    	self.m_plotLayer:setVisible(self.m_isVisible)
    end

    local command=CPlotCommand(CPlotCommand.START)
    controller:sendCommand(command)
end

--执行    剧情完成后 执行的方法
function PlotManager.finishPlot( self, _plotData )
	CCLOG("剧情播放完毕",_plotData.touchId)

	local nStage=_G.g_Stage
	--恢复主场景部分View 
	if _plotData.touchType~=_G.Const.CONST_DRAMA_GETINTO or _plotData.touchId~=_G.Const.CONST_COPY_FIRST_COPY then 
		-- print("JJKJKJKJKJKJKJKJJKJK======>>>")
		local tempAI=0
		if _plotData.touchType~=_G.Const.CONST_DRAMA_TRIGGER then
			nStage:setStopAI(false)
			tempAI=nil
		end
		nStage:setCharacterVisible(true,tempAI)
	end

	nStage:setSomeViewVisible(true)
	nStage:getMainPlayer().unlimitPosition=nil

	if _plotData.isAutoFightMode==true then
		nStage:startAutoFight()
	end
	nStage.m_slowMotionMapPos=_plotData.isSlowMotionMapPos

	if self.m_goFun~=nil then
		self.m_goFun()
	end
	self.m_plotView=nil
	self.m_plotLayer=nil

	local useTimes=_G.TimeUtil:getTotalSeconds() - self.m_startTimes - 1
	useTimes=useTimes<0 and 0 or useTimes
	nStage.m_plotUseTime=nStage.m_plotUseTime+useTimes
	nStage.m_deadlineTime=self.m_deadlineTime
	self.m_deadlineTime=nil

	local command=CPlotCommand(CPlotCommand.FINISH)
	command.id=_plotData.id
    controller:sendCommand(command)
end

function PlotManager.isPlayingPlot(self)
	return self.m_plotView~=nil
end

function PlotManager.setPlotVisible( self, _isVisible )
	if self.m_plotLayer~=nil then
		self.m_plotLayer:setVisible(_isVisible)
	end
	self.m_isVisible=_isVisible
end

--根据剧情列表与触发Id 获取剧情信息
function PlotManager.getPlotDataByListAndArg( self, _touchType, _touchId )
	if _touchId==nil or _touchType==nil then
		return nil
	end
	local plotTypeCnf=_G.Cfg.scene_drama[_touchType]
	if plotTypeCnf==nil then
		return nil
	end

	return plotTypeCnf[_touchId]
end

return PlotManager






