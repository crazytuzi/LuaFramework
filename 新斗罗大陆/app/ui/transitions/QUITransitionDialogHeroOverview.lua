--
-- Author: Your Name
-- Date: 2014-05-06 16:33:05
--
local QUITransition = import(".QUITransition")
local QUITransitionDialogHeroOverview = class("QUITransitionDialogHeroOverview", QUITransition)

function QUITransitionDialogHeroOverview:_doTransition()
	local old = self:getOldController()
	if old.setManyUIVisible then
		old:setManyUIVisible()
	end
end

return QUITransitionDialogHeroOverview

