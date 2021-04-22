--
-- Author: Your Name
-- Date: 2015-10-13 19:03:56
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSuperGodStar = class("QUIWidgetSuperGodStar", QUIWidget)

function QUIWidgetSuperGodStar:ctor(options)
	local ccbFile = "ccb/Widget_star_super.ccbi"
	local callBack = {
	}
	QUIWidgetSuperGodStar.super.ctor(self, ccbFile, callBack, options)

	local index = 1
	while true do
		local bgNode = self._ccbOwner["node_bg_"..index]
		local lightNode = self._ccbOwner["node_light_"..index]
		local isFind = false
		if bgNode then
			isFind = true
			bgNode:setVisible(false)
		end
		if lightNode then
			isFind = true
			lightNode:setVisible(false)
		end
		if isFind then
			index = index + 1
		else
			break
		end
	end

	self._isInit = true
end

function QUIWidgetSuperGodStar:setGrade(actorId, isAnimation)
	-- @godSkillGrade ： 是神技的真实等级，godSkillLevel是神技的显示等级。
	-- @godSkillLevel ： 没有神技-1，ss+ 0～5级， ss 1～5级，对应显示神0～神5
	local godSkillLevel = remote.herosUtil:getGodSkillLevelByActorId(actorId)
	if self._isInit then
		self._isInit = false
		isAnimation = false
	end
	-- 星星月亮太阳
	local system = 5
	local index = 1
	while true do
		local bgNode = self._ccbOwner["node_bg_"..index]
		local lightNode = self._ccbOwner["node_light_"..index]
		if bgNode and lightNode then
			if (index == 1 and godSkillLevel == 0) or (godSkillLevel > (system * (index - 1)) and godSkillLevel <= system * index) then
				bgNode:setVisible(true)
				lightNode:setVisible(true)

				for i = 1, system do
					local sp = self._ccbOwner["sp_"..index.."_"..i]
					if sp then
						local isShow = i <= (godSkillLevel - system * (index - 1))
						if isAnimation and sp:isVisible() == false and isShow then 
							q.addHitTheStarsEffect(sp)
						else
							sp:setVisible(isShow)
						end
					end
				end
			else
				bgNode:setVisible(false)
				lightNode:setVisible(false)
			end
			index = index + 1
		else
			break
		end
	end
end

return QUIWidgetSuperGodStar