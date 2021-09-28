local HeroSoulAchievementNode = class("HeroSoulAchievementNode", function()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/herosoul_AchievementNode.json")
end)

require("app.cfg.ksoul_group_target_info")
local EffectNode = require("app.common.effects.EffectNode")

local STANDARD_DIST = 150 -- 标准的移动距离（某些节点之间距离短）

function HeroSoulAchievementNode:ctor(slot, posArr, maxNodes)
	self._slot			= slot 			-- 节点所在位
	self._posArr		= posArr 		-- 每个索引位的位置
	self._maxNodes		= maxNodes 		-- 最大显示节点数

	self._achievementID = 0		-- 成就ID
	self._chartPoint 	= 0		-- 所需的阵图值
	self._canActivate 	= false -- 该成就是否可激活
	self._isActive 		= false	-- 该成就是否已激活
	self._isPrevActive 	= false	-- 前一个成就是否已激活
	self._isNextActive 	= false	-- 后一个成就是否已激活
	self._fromSlot		= slot	-- 从哪个节点移动
	self._toSlot		= slot 	-- 往哪个节点移动
	self._fromPos		= nil
	self._toPos			= nil
	self._dist			= 0 	-- 起始和目标位之间的距离
	self._fromPercent	= 0 	-- 目前离起始位的百分比
	self._toPercent		= 0 	-- 目前离目标位的百分比
	self._towardLeft	= false -- 是否往左移动
	self._moveFactor	= 1 	-- 移动时距离的乘数

	self._shiningEffect	= nil
	self._activateEffect= nil

	self._pointLabel = UIHelper:seekWidgetByName(self, "Label_Point")
	self._pointLabel = tolua.cast(self._pointLabel, "Label")
	self._pointLabel:createStroke(Colors.strokeBrown, 1)

	self._icon = UIHelper:seekWidgetByName(self, "Image_Icon")
	self._icon = tolua.cast(self._icon, "ImageView")
end

-- 刷新是否要显示发光特效
function HeroSoulAchievementNode:_updateShiningEffect()
	if self._canActivate and not self._shiningEffect then
		self._shiningEffect = EffectNode.new("effect_mx_light", function() end)
		self._shiningEffect:play()
		self._shiningEffect:setPositionXY(-1, 1)
		self:addNode(self._shiningEffect)
	end

	if self._shiningEffect then
		self._shiningEffect:setVisible(self._canActivate)
	end
end

-- 播放激活过程
function HeroSoulAchievementNode:playActivate(callback)
	if not self._activateEffect then
		self._activateEffect = EffectNode.new("effect_prepare_compose", function(event, frameIndex)
			if event == "finish" then
				-- 执行回调
				if callback then
					callback()
				end

				-- 删除特效
				self._activateEffect:removeFromParentAndCleanup(true)
				self._activateEffect = nil
			end
		end)

		self._activateEffect:play()
		self:addNode(self._activateEffect)
	end
end

function HeroSoulAchievementNode:update(id, forceUpdate)
	local isAchievementExist = self:_isIDValid(id)
	self:setVisible(isAchievementExist)

	if not forceUpdate and self._achievementID == id then
		return
	end

	self._achievementID = id

	if not isAchievementExist then
		return
	end

	-- set members
	local achieveInfo = ksoul_group_target_info.get(id)

	self._chartPoint = achieveInfo.target_value

	self._canActivate  = G_Me.heroSoulData:canActivateAchievement(id)
	self._isActive 	   = G_Me.heroSoulData:isAchievementActivated(id)
	self._isPrevActive = G_Me.heroSoulData:isPrevAchievementActivated(id)
	self._isNextActive = G_Me.heroSoulData:isNextAchievementActivated(id)

	-- set icon
	if self._isActive then
		self._icon:loadTexture("ui/herosoul/icon_zhentu.png")
	else
		self._icon:loadTexture("ui/herosoul/icon_zhentu_gray.png")
	end

	-- set chart point
	self._pointLabel:setText(tostring(self._chartPoint))

	-- update shining effect
	self:_updateShiningEffect()
end

function HeroSoulAchievementNode:forceUpdate()
	self:update(self._achievementID, true)
end

function HeroSoulAchievementNode:_isIDValid(id)
	return id > 0 and id <= ksoul_group_target_info.getLength()
end

function HeroSoulAchievementNode:getAchievementID()	return self._achievementID end
function HeroSoulAchievementNode:getCurSlot() return self._slot end
function HeroSoulAchievementNode:getFromSlot() return self._fromSlot end
function HeroSoulAchievementNode:getToSlot() return self._toSlot end
function HeroSoulAchievementNode:getFromPercent() return self._fromPercent end
function HeroSoulAchievementNode:getToPercent() return self._toPercent end
function HeroSoulAchievementNode:isActive() return self._isActive end
function HeroSoulAchievementNode:isPrevNodeActive() return self._isPrevActive end
function HeroSoulAchievementNode:isNextNodeActive() return self._isNextActive end
function HeroSoulAchievementNode:isKeepInSlot() return self._fromSlot == self._toSlot end
function HeroSoulAchievementNode:isValid() return self:_isIDValid(self._achievementID) end
function HeroSoulAchievementNode:isPrevNodeValid() return self:_isIDValid(self._achievementID - 1) end
function HeroSoulAchievementNode:isNextNodeValid() return self:_isIDValid(self._achievementID + 1) end

function HeroSoulAchievementNode:beginMove(towardLeft)
	self._towardLeft = towardLeft

	-- 计算从哪个节点移到哪个节点
	if towardLeft then
		self._fromSlot = math.max(self._fromSlot, self._toSlot)
		self._toSlot   = self._fromSlot - 1
	else
		self._fromSlot = math.min(self._fromSlot, self._toSlot)
		self._toSlot   = self._fromSlot + 1
	end

	-- 计算起始位置和目标位置、距离、移动因子
	self._fromPos = self._posArr[self._fromSlot]
	self._toPos   = self._posArr[self._toSlot]
	self._dist    = math.sqrt((self._toPos.x - self._fromPos.x) * (self._toPos.x - self._fromPos.x),
							  (self._toPos.y - self._fromPos.y) * (self._toPos.y - self._fromPos.y))
	self._moveFactor = self._dist / STANDARD_DIST
end

function HeroSoulAchievementNode:move(deltaX)
	-- 计算并移动
	local moveX = deltaX * self._moveFactor
	local moveY = (self._toPos.y - self._fromPos.y) / (self._toPos.x - self._fromPos.x) * moveX

	local curX, curY = self:getPosition()
	local newX = curX + moveX
	local newY = curY + moveY
	self:setPositionXY(newX, newY)

	-- 计算距离百分比
	local distFrom = math.sqrt((newX - self._fromPos.x) * (newX - self._fromPos.x),
							   (newY - self._fromPos.y) * (newY - self._fromPos.y))
	self._fromPercent = math.min(1, distFrom / self._dist)
	self._toPercent   = 1 - self._fromPercent
	
	-- 检查是否到达了目标位
	if self._towardLeft then
		return newX <= self._toPos.x
	else
		return newX >= self._toPos.x
	end
end

function HeroSoulAchievementNode:moveToTarget()
	-- 如果移到了头或尾，要调整回去
	if self._toSlot == 0 then
		self._slot = self._maxNodes
	elseif self._toSlot == self._maxNodes + 1 then
		self._slot = 1
	else
		self._slot = self._toSlot
	end

	local newAchieveId = self._achievementID + self._slot - self._toSlot
	self:update(newAchieveId)
	self:setPosition(self._posArr[self._slot])
	self._fromSlot = self._slot
	self._toSlot = self._slot
	self._dist = 0
	self._fromPercent = 0
	self._toPercent = 0

	return self._slot
end

return HeroSoulAchievementNode