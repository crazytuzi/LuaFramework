local QUIDialog = import(".QUIDialog")
local QUIDialogSoulTrialPass = class("QUIDialogSoulTrialPass", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSoulTrialPass:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTrial_Pass.ccbi"
	local callBacks = {}
	QUIDialogSoulTrialPass.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

	local rewardList = string.split(options.config.reward, ";")
	for index, value in ipairs( rewardList ) do
		local tbl = string.split(value, "^")
		if self._ccbOwner["node_item_"..index] then
			local icon = nil
			if tonumber(tbl[1]) then
				icon = self:_getIcon(ITEM_TYPE.ITEM, tonumber(tbl[1]), tonumber(tbl[2]))
			else
				icon = self:_getIcon(tbl[1], nil, tonumber(tbl[2]))
			end
			self._ccbOwner["node_item_"..index]:addChild(icon)
			index = index + 1
		end
	end
	self._ccbOwner.tf_text:setString(options.config.description)
end

--[[
    设置icon
]]
function QUIDialogSoulTrialPass:_getIcon( type, id, count )
    local node = nil
    node = QUIWidgetItemsBox.new()
    node:setGoodsInfo(id, type, count)
    return node
end

function QUIDialogSoulTrialPass:viewDidAppear()
	QUIDialogSoulTrialPass.super.viewDidAppear(self)
end 

function QUIDialogSoulTrialPass:viewWillDisappear()
	QUIDialogSoulTrialPass.super.viewWillDisappear(self)
end 

function QUIDialogSoulTrialPass:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSoulTrialPass:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSoulTrialPass:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogSoulTrialPass
