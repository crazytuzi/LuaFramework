-- CrossPVPScene
-- the main scene of the cross-server pvp mode(跨服夺帅玩法主场景)
local CrossPVPScene = class("CrossPVPScene", UFCCSBaseScene)

local CrossPVPConst 	= require("app.const.CrossPVPConst")
local CrossPVP 			= require("app.scenes.crosspvp.CrossPVP")
local CrossPVPTitleBar 	= require("app.scenes.crosspvp.CrossPVPTitleBar")
local CrossPVPTopButtons= require("app.scenes.crosspvp.CrossPVPTopButtons")

function CrossPVPScene:ctor(scenePack, ...)
	self._isInFightLayer = false
	self.super.ctor(self, nil, nil, ...)
	G_GlobalFunc.savePack(self, scenePack)
end

function CrossPVPScene:onSceneLoad(...)
end

function CrossPVPScene:onSceneEnter(...)
	self:registerKeypadEvent(true)

	-- attach top bar and bottom bar
	if not self._topBar then
		self._topBar	= G_commonLayerModel:getStrengthenRoleInfoLayer()
		self:addUILayerComponent("TopBar", self._topBar, true)
	end

	if not self._bottomBar then
		self._bottomBar = G_commonLayerModel:getSpeedbarLayer()
		self:addUILayerComponent("BottomBar", self._bottomBar, true)
	end

	if not self._bg then
		self._bg = ImageView:create()
		self._bg:loadTexture(G_Path.getBackground("bg_common.png"))
		self._bg:setPositionXY(display.cx, display.cy)
		self._bg:setScale(2)
		self._bg:setZOrder(-2)
		self:addChild(self._bg)
	end

	if not self._titleBar then
		self._titleBar = CrossPVPTitleBar.create()
		self:addUILayerComponent("TitleBar", self._titleBar, true)
		self:adapterLayerHeight(self._titleBar, self._topBar, nil, -10, 0)
	end

	if not self._topButtons then
		self._topButtons = CrossPVPTopButtons.create()
		self:addUILayerComponent("TopButtons", self._topButtons, true)
		self:adapterLayerHeight(self._topButtons, self._topBar, nil, 80, 0)
	end

	-- go to layer according to current match stage
	self:_goToLayerByCurStage()

	-- register event listner
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onStageChanged, self)
end

function CrossPVPScene:onSceneExit(...)
	if self._topBar then
		self._topBar:setVisible(true)
		self:removeComponent(SCENE_COMPONENT_GUI, "TopBar")
		self._topBar = nil
	end

	if self._bottomBar then
		self._bottomBar:setVisible(true)
		self:removeComponent(SCENE_COMPONENT_GUI, "BottomBar")
		self._bottomBar = nil
	end

	-- remove event listner
	uf_eventManager:removeListenerWithTarget(self)

end

function CrossPVPScene:onSceneUnload(...)
	CrossPVP.exit()
end

function CrossPVPScene:onBackKeyEvent()
	if self._isInFightLayer and not G_Me.crossPVPData:isApplied() then
		uf_sceneManager:getCurScene():_goToLayerByCurStage()
	else
		local packScene = G_GlobalFunc.createPackScene(self)
    	if not packScene then 
       		packScene = require("app.scenes.mainscene.PlayingScene").new()
    	end

    	uf_sceneManager:replaceScene(packScene)
	end
    return true
end

function CrossPVPScene:_onStageChanged()
	-- 这里为什么要延迟一帧切界面，
	-- 原因是有些子界面也接收状态切换的事件，但切界面会把之前的子界面移除掉
	-- 子界面自己会移除事件监听，但在事件分发期间，event dispatcher会做延迟移除，因此会继续给子界面发事件，而这时子界面已经没了，就会报错
	-- 所以，延迟一帧切界面，让event dispatcher完成事件分发
	uf_funcCallHelper:callNextFrame(self._goToLayerByCurStage, self)
end

function CrossPVPScene:_goToLayerByCurStage()
	local pvpData 		= G_Me.crossPVPData
	local course 		= pvpData:getCourse()
	local stage  		= pvpData:getStage()
	local hasBet 		= pvpData:hasBetStage()
	local isApplied 	= pvpData:isApplied()
	local isEliminated	= pvpData:isEliminated()
	local isMyMatchBegin= pvpData:isMyMatchBegin() -- 我的比赛是否已开始
	local isMyMatchEnd  = pvpData:isMyMatchEnd()   -- 我的比赛是否已结束
	local targetLayer	= ""

	if course == CrossPVPConst.COURSE_APPLY then
		-- 报名阶段，就进报名界面
		targetLayer = "CrossPVPApplyLayer"
	elseif course == CrossPVPConst.COURSE_PROMOTE_1024 then
		-- 海选赛阶段
		-- 1. 已报名但比赛未开始，进报名界面
		-- 2. 已报名但比赛已开始，进相关比赛阶段
		-- 3. 被淘汰，进比赛结束界面
		-- 4. 未报名，进比赛回顾界面
		if isApplied then
			if not isMyMatchBegin then
				targetLayer = "CrossPVPApplyLayer"
			elseif isMyMatchEnd then
				targetLayer = "CrossPVPFightEndLayer"
			end
		elseif isEliminated then
			targetLayer = "CrossPVPFightEndLayer"
		else
			targetLayer = "CrossPVPReviewLayer"
		end
	elseif not hasBet then
		-- 没有投注阶段的比赛
		-- 1. 未报名，或报名了但比赛没开始，进比赛回顾界面
		-- 2. 被淘汰，进比赛结束界面
		-- 3. 已报名（并晋级下轮且比赛已开始），进相关比赛阶段
		if isApplied then
			if not isMyMatchBegin or isMyMatchEnd then
				targetLayer = "CrossPVPFightEndLayer"
			end
		elseif isEliminated then
			targetLayer = "CrossPVPFightEndLayer"
		else
			targetLayer = "CrossPVPReviewLayer"
		end
	else
		-- 有投注阶段的比赛
		-- 根据是否参赛、不同阶段进不同界面
		-- 战斗阶段，未报名或被淘汰的人进观战选择界面
	end

	-- 是否需要根据阶段来进界面
	if targetLayer == "" then
		if stage == CrossPVPConst.STAGE_REVIEW then
			targetLayer = (isApplied or isEliminated) and "CrossPVPFightEndLayer" or "CrossPVPReviewLayer"
		elseif stage == CrossPVPConst.STAGE_BET then
			targetLayer = "CrossPVPBetLayer"
		elseif stage == CrossPVPConst.STAGE_ENCOURAGE then
			targetLayer = "CrossPVPInspireLayer"
		elseif stage == CrossPVPConst.STAGE_FIGHT then
			targetLayer = isApplied and "CrossPVPFightMainLayer" or "CrossPVPFightNotJoinLayer"
		else
			targetLayer = "CrossPVPApplyLayer"
		end
	end

	-- jump to layer
	self:_goToLayer(targetLayer)
end

function CrossPVPScene:_goToLayer(layerName)
	-- hide the bottom bar and top buttons when in fighting layer
	self._isInFightLayer = layerName == "CrossPVPFightMainLayer"
	self._bottomBar:setVisible(not self._isInFightLayer)
	self._topButtons:setVisible(not self._isInFightLayer)

	-- remove current layer
	if self._mainBody then
		if self._mainBody.layerName == layerName then
			return
		end

		if self._mainBody.clearTimerAndEvents then
			self._mainBody:clearTimerAndEvents()
		end

		self:removeComponent(SCENE_COMPONENT_GUI, "MainBody")
	end

	-- add new layer
	self._mainBody = require("app.scenes.crosspvp." .. layerName).create()
	self._mainBody:setZOrder(-1)
	self._mainBody.layerName = layerName
	self:addUILayerComponent("MainBody", self._mainBody, true)

	-- update title
	self._titleBar:updateTitle(self._isInFightLayer)

	-- adapt layer
	local bottomRef = (not self._isInFightLayer) and self._bottomBar or nil
	self:adapterLayerHeight(self._mainBody, self._topBar, bottomRef, -10, 0)

	if self._mainBody.adapterLayer then
		self._mainBody:adapterLayer()
	end
end

return CrossPVPScene