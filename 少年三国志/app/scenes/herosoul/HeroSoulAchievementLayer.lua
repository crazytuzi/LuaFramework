local HeroSoulAchievementLayer = class("HeroSoulAchievementLayer", UFCCSModelLayer)

require("app.cfg.ksoul_group_target_info")
local EffectNode = require("app.common.effects.EffectNode")
local EffectSingleMoving = require("app.common.effects.EffectSingleMoving")
local HeroSoulAchievementNode = require("app.scenes.herosoul.HeroSoulAchievementNode")

local MAX_NODES 		= 7	-- 7个成就节点
local CENTER_SLOT 		= 4	-- 中间是第4个
local AUTO_MOVE_SPEED	= 150 -- 放开触摸后，自动移动的速度
local LINES_NUM			= 4 -- 连线的数量

-- 三种slot类型
local CUR_SLOT			= 1
local FROM_SLOT			= 2
local TO_SLOT			= 3

local ACTIVE_LINE		= "ui/sanguozhi/line_qinglong.png"
local INACTIVE_LINE		= "ui/herosoul/line_zhentu.png"
local ACTIVE_DOT 		= "ui/herosoul/dian_zhentu.png"
local INACTIVE_DOT		= "ui/herosoul/dian_zhentu_gray.png"

function HeroSoulAchievementLayer.show()
	local layer = HeroSoulAchievementLayer.new("ui_layout/herosoul_Achievement.json", Colors.modelColor)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroSoulAchievementLayer:ctor(jsonFile, color)
	self._nodePos 	 = {} -- 节点位置数组
	self._nodes 	 = {} -- 成就节点数组
	self._centerNode = nil-- 当前处在中间位置的节点

	self._isTouching = false
	self._isMoving   = false
	self._isAutoMove = false
	self._towardLeft = false
	self._prevTouchX = 0 		-- 上一次触摸的x坐标

	self._timer 	 = nil
	self._isActivating = false 	-- 激活过程中

	-- 连线和节点
	self._linesLPart = {}
	self._linesRPart = {}
	self._linesWidth = {}
	self._dots 		 = {}

	self._clipView = self:getWidgetByName("ScrollView_Clip")

	-- 激活按钮上的溜光效果
	self._activeEffect = nil

	self.super.ctor(self, jsonFile, color)
end

function HeroSoulAchievementLayer:onLayerLoad()
	-- 4段连线左右两部分，以及默认宽度
	for i = 1, LINES_NUM do
		self._linesLPart[i] = self:getImageViewByName("Image_Line_" .. i .. "_L")
		self._linesRPart[i] = self:getImageViewByName("Image_Line_" .. i .. "_R")
		self._linesWidth[i] = self._linesLPart[i]:getSize().width
	end

	-- label stroke
	self:enableLabelStroke("Label_ChartPoint", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ChartPoint_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_NeedPoint", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_BuffDesc", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_BuffHint", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Hint", Colors.strokeBrown, 1)

	self:showTextWithLabel("Label_BuffHint", G_lang:get("LANG_DRESS_ALLACTIVE"))

	-- register button click events
	self:registerBtnClickEvent("Button_Activate", handler(self, self._onClickActivate))
	self:registerBtnClickEvent("Button_Attr", handler(self, self._onClickAttr))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))

	-- create nodes
	self:_createNodes()
	self:_updateLines()
end

function HeroSoulAchievementLayer:onLayerEnter()
	self:registerTouchEvent(false,true,0)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- bounce in the layer
	EffectSingleMoving.run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- create a timer(for auto moving)
	self._timer = G_GlobalFunc.addTimer(0, handler(self, self._update))

	-- set chart point
	self:showTextWithLabel("Label_ChartPoint_Num", tostring(G_Me.heroSoulData:getChartPoints()))

	-- add event listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_ACTIVATE_ACHIEVEMENT, self._onRcvActivateAchieve, self)
end

function HeroSoulAchievementLayer:onLayerExit()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function HeroSoulAchievementLayer:onTouchBegin(x, y)
	-- 正在激活过程中，禁止触摸
	if self._isActivating then return end

	local xInClipView, yInClipView= self._clipView:convertToNodeSpaceXY(x, y)
	local clipSize = self._clipView:getContentSize()
	if xInClipView > 0 and xInClipView < clipSize.width and
	   yInClipView > 0 and yInClipView < clipSize.height then
	   self._isTouching = true
	   self._prevTouchX = x
	end
	return true
end

function HeroSoulAchievementLayer:onTouchMove(x, y)
	if self._isTouching then
		local deltaX = x - self._prevTouchX
		local towardLeft = deltaX < 0
		self._prevTouchX = x
		self._isAutoMove = false

		-- 如果之前没有移动，先设置一些东西
		if not self._isMoving or towardLeft ~= self._towardLeft then
			self._isMoving = true
			self._towardLeft = towardLeft

	   		-- 开始移动
			local canMove = self:_beginMove()
			if not canMove then
				self._isMoving = false
				return
			else
				-- 隐藏成就信息，禁用激活按钮
	   			self:showWidgetByName("Image_BuffBg", false)
	   			self:_enableActivateBtn(false)
			end
		end

		-- 真正的移动
		self:_move(deltaX)
	end
end

function HeroSoulAchievementLayer:onTouchEnd()
	if self._isMoving then
		self._isAutoMove = true
	end
	self._isTouching = false
end

function HeroSoulAchievementLayer:onTouchCancel()
	if self._isMoving then
		self._isAutoMove = true
	end
	self._isTouching = false
end

function HeroSoulAchievementLayer:_beginMove()
	-- 检查是否到头了不能移动
	local centerAchieveId = self._centerNode:getAchievementID()
	if self._centerNode:isKeepInSlot() then
		if self._towardLeft and centerAchieveId == ksoul_group_target_info.getLength() or
	   	   not self._towardLeft and centerAchieveId == 1 then
			return false
		end
	end

	for i, v in ipairs(self._nodes) do
		v:beginMove(self._towardLeft)
	end

	return true
end

function HeroSoulAchievementLayer:_move(deltaX)
	for i, v in ipairs(self._nodes) do
		local reachTarget = v:move(deltaX)
		self:_updateLines()

		-- 如果有某个节点到达目标位，强制所有节点都移到目标位
		if reachTarget then
			self:_moveToTarget()
			self:_updateLines()

			-- 不是在自动移动，继续
			-- 否则的话，停止，并刷新成就信息
			if not self._isAutoMove then
				self:_beginMove(self._towardLeft)
			else
				self:_updateAchievementInfo()
				self._isAutoMove = false
				self._isMoving = false
				self._isActivating = false
			end

			break
		end
	end
end

function HeroSoulAchievementLayer:_moveToTarget()
	for i, v in ipairs(self._nodes) do
		local curSlot = v:moveToTarget()
		if curSlot == CENTER_SLOT then
			self._centerNode = v
		end
	end
end

-- 创建并初始化成就节点
function HeroSoulAchievementLayer:_createNodes()
	-- 初始化节点位置
	for i = 0, MAX_NODES + 1 do
		local slot = self:getImageViewByName("Image_Slot_" .. i)
		self._nodePos[i] = ccp(slot:getPosition())
		self._dots[i] = slot
	end

	-- 得到上一个激活的成就ID，以及初始放在中间的成就ID
	local lastAchievementID = G_Me.heroSoulData:getLastActivatedAchievement()
	local nextAchievementID = lastAchievementID == ksoul_group_target_info.getLength()
							  and lastAchievementID or lastAchievementID + 1

	-- 创建成就节点					  
	for i = 1, MAX_NODES do
		local node = HeroSoulAchievementNode.new(i, self._nodePos, MAX_NODES)
		local achieveID = nextAchievementID - CENTER_SLOT + i
		node:update(achieveID)
		node:setPosition(self._nodePos[i])
		self._clipView:addChild(node)
		self._nodes[#self._nodes + 1] = node
	end

	self._centerNode = self._nodes[CENTER_SLOT]
	self:_updateAchievementInfo()
end

function HeroSoulAchievementLayer:_update(t)
	if self._isAutoMove then
		local deltaX = AUTO_MOVE_SPEED * t
		if self._towardLeft then
			deltaX = -deltaX
		end

		self:_move(deltaX)
	end
end

-- 刷新成就点信息
function HeroSoulAchievementLayer:_updateAchievementInfo()
	-- show info panel
	self:showWidgetByName("Image_BuffBg", true)

	-- set info
	local achieveID = self._centerNode:getAchievementID()
	local achieveInfo = ksoul_group_target_info.get(achieveID)
	local strNeedPoint = G_lang:get("LANG_HERO_SOUL_NEED_CHART_POINT", {num = achieveInfo.target_value})
	self:showTextWithLabel("Label_NeedPoint", strNeedPoint)

	local attrName = G_lang.getGrowthTypeName(achieveInfo.attribute_type1)
	local attrValue = G_lang.getGrowthValue(achieveInfo.attribute_type1, achieveInfo.attribute_value1)
	self:showTextWithLabel("Label_BuffDesc", attrName .. " +" .. attrValue)	

	-- activation state
	self:_updateActivateState(achieveID)
end

-- 刷新激活状态
function HeroSoulAchievementLayer:_updateActivateState(achieveID)
	local isActivated = G_Me.heroSoulData:isAchievementActivated(achieveID)
	self:showWidgetByName("Image_Activated", isActivated)
	self:showWidgetByName("Button_Activate", not isActivated)

	if not isActivated then
		local canActivate = G_Me.heroSoulData:canActivateAchievement(achieveID)
		self:_enableActivateBtn(canActivate)

		-- 如果可以激活，按钮上显示溜光效果
		if canActivate then
			if not self._activeEffect then
				self._activeEffect = EffectNode.new("effect_around2")
				self._activeEffect:setScale(1.8)
				self._activeEffect:setPositionXY(-2, -2)
				self._activeEffect:play()
				self:getWidgetByName("Button_Activate"):addNode(self._activeEffect)
			end
			self._activeEffect:setVisible(true)
		elseif self._activeEffect then
			self._activeEffect:setVisible(false)
		end
	end
end

-- 刷新连线的状态
function HeroSoulAchievementLayer:_updateLines()
	-- 需要根据情况获得不同node
	local slotType = (self._isMoving or self._isAutoMove) and 
					 (self._towardLeft and TO_SLOT or FROM_SLOT) or CUR_SLOT

	-- 更新每根线的状态
	for i = 1, LINES_NUM do
		-- 线的起始序号比slot大1
		local refNode = self:_getNodeBySlot(i + 1, slotType)
		self:_updateLine(i, refNode)
	end

	-- 更新每个节点圈圈的状态
	-- 因为只有第2~5个圈圈显示在屏幕上，所以这里稍微写死
	for i = 2, 5 do
		local refNode = self:_getNodeBySlot(i, slotType)
		self:_updateDot(i, refNode)
	end
end

function HeroSoulAchievementLayer:_updateLine(index, refNode)
	local lineL = self._linesLPart[index]
	local lineR = self._linesRPart[index]
	local width = self._linesWidth[index]

	local isValid 		  = refNode:isValid()
	local isPrevNodeValid = refNode:isPrevNodeValid()
	local isNextNodeValid = refNode:isNextNodeValid()

	-- 处理左半边的线
	local widthPercent = self._towardLeft and refNode:getToPercent() or refNode:getFromPercent()
	if isValid and isPrevNodeValid then
		-- 如果左边是有节点的，那么左半部分连线根据refNode的状态和距离显示
		local isActive = refNode:isActive()
		lineL:loadTexture(isActive and ACTIVE_LINE or INACTIVE_LINE)
		lineL:setSize(CCSize(width * widthPercent, lineL:getSize().height))
	else
		-- 如果左边是没有节点的，那么左半部分连线不显示
		lineL:setSize(CCSize(0, lineL:getSize().height))
	end

	-- 处理右半边的线
	if isValid and isNextNodeValid then
		-- 如果右边是有节点的，那么右半部分连线根据refNode的下一个节点状态显示
		local isNextActive = refNode:isNextNodeActive()
		lineR:loadTexture(isNextActive and ACTIVE_LINE or INACTIVE_LINE)
		lineR:setSize(CCSize(width * (1 - widthPercent), lineL:getSize().height))
	else
		-- 如果右边是没有节点的，那么右半部分连线不显示
		lineR:setSize(CCSize(0, lineR:getSize().height))
	end
end

function HeroSoulAchievementLayer:_updateDot(index, refNode)
	-- 如果该节点上不存在成就，不显示
	local dot = self._dots[index]
	local isValid = refNode:isValid()
	local isPrevNodeValid = refNode:isPrevNodeValid()
	dot:setVisible(isValid and isPrevNodeValid)

	-- 如果存在，根据refNode状态切换圆点的图片
	if isValid then
		local isActive = refNode:isActive()
		local dotImg = isActive and ACTIVE_DOT or INACTIVE_DOT
		dot:loadTexture(dotImg)
	end
end

-- 获取当前在slot位的node
function HeroSoulAchievementLayer:_getNodeBySlot(slot, slotType)
	for i, v in ipairs(self._nodes) do
		local vSlot = (slotType == CUR_SLOT and v:getCurSlot() or 
					  (slotType == FROM_SLOT and v:getFromSlot() or v:getToSlot()))
		if vSlot == slot then
			return v
		end
	end

	return nil
end

-- 激活成就后飞出属性
function HeroSoulAchievementLayer:_flyAttr(achieveID)
	G_flyAttribute.addNormalText(G_lang:get("LANG_HERO_SOUL_ACTIVATE_SUCC"), Colors.darkColors.DESCRIPTION)

	local achieveInfo = ksoul_group_target_info.get(achieveID)
	local attrName = G_lang.getGrowthTypeName(achieveInfo.attribute_type1)
	local attrValue = G_lang.getGrowthValue(achieveInfo.attribute_type1, achieveInfo.attribute_value1)
	G_flyAttribute.addNormalText(attrName .. "  +" .. attrValue, Colors.darkColors.ATTRIBUTE)

	G_flyAttribute.play()
end

function HeroSoulAchievementLayer:_enableActivateBtn(enable)
	self:getButtonByName("Button_Activate"):setTouchEnabled(enable)
	self:getImageViewByName("Image_Activate"):showAsGray(not enable)

	if not enable and self._activeEffect then
		self._activeEffect:setVisible(false)
	end
end

-- 收到激活成功的返回
function HeroSoulAchievementLayer:_onRcvActivateAchieve()
	-- 播完激活特效之后的回调
	local callback = function()
		-- 对激活的和前后两个节点强制刷新
		self._centerNode:forceUpdate()
		self:_getNodeBySlot(CENTER_SLOT - 1, CUR_SLOT):forceUpdate()
		self:_getNodeBySlot(CENTER_SLOT + 1, CUR_SLOT):forceUpdate()

		local activeID = self._centerNode:getAchievementID()

		-- 飘字
		self:_flyAttr(activeID)

		if activeID == ksoul_group_target_info.getLength() then
			-- 如果是最后一个成就，结束			
			self:_updateActivateState(activeID)
			self._isActivating = false
		else
			-- 不是最后一个成就，整体往左移动
			self._towardLeft = true
			self._isAutoMove = true
			self:_beginMove()
		end
	end

	-- 播激活效果
	self._centerNode:playActivate(callback)
end

function HeroSoulAchievementLayer:_onClickActivate()
	-- 正在激活过程中
	if self._isActivating then
		return
	end

	-- 发请求
	local achieveID = self._centerNode:getAchievementID()
	G_HandlersManager.heroSoulHandler:sendActivateAchievement(achieveID)

	-- 禁用按钮
	self:_enableActivateBtn(false)

	self._isActivating = true
end

function HeroSoulAchievementLayer:_onClickAttr()
	local attrs = G_Me.heroSoulData:getAchivementAttrs()
	local strList = {}
	for k, v in pairs(attrs) do
		local attr = G_lang.getGrowthTypeName(k)
		local num = G_lang.getGrowthValue(k, v)
		strList[#strList + 1] = {text = attr, value = num}
	end

	require("app.scenes.sanguozhi.SanguozhiAttrLayer").show(strList)
end

function HeroSoulAchievementLayer:_onClickClose()
	self:animationToClose()
end

return HeroSoulAchievementLayer