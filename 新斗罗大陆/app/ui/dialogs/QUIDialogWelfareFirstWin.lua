local QUIDialog = import(".QUIDialog")
local QUIDialogWelfareFirstWin = class("QUIDialogWelfareFirstWin", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogWelfareFirstWin:ctor(options)
	local ccbFile = "ccb/Dialog_EliteInfo_shousheng.ccbi"
	local callBacks = {}
	QUIDialogWelfareFirstWin.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	CalculateUIBgSize(self._ccbOwner.ly_bg)

	local fdItem = remote.welfareInstance:getFirstWinConfig()
	local rewards = string.split(fdItem, ";")
	-- print("[Kumo] QUIDialogWelfareFirstWin:ctor  fdItem : ", fdItem)
	-- QPrintTable(rewards)
	local index = 0
	for _, value in pairs(rewards) do
		local item = QUIWidgetItemsBox.new()
		local info = string.split(value, "^")
		-- QPrintTable(info)
		if info[1] == "token" then
			-- 目前只显示钻石
			item:setGoodsInfo(nil, info[1], tonumber(info[2]))
			self._ccbOwner.node_item:addChild(item)
			item:setPositionX((item:getContentSize().width + 20) * index)
			index = index + 1
		end
	end
end

function QUIDialogWelfareFirstWin:viewDidAppear()
	QUIDialogWelfareFirstWin.super.viewDidAppear(self)
end 

function QUIDialogWelfareFirstWin:viewWillDisappear()
	QUIDialogWelfareFirstWin.super.viewWillDisappear(self)
end 

function QUIDialogWelfareFirstWin:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogWelfareFirstWin:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogWelfareFirstWin:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogWelfareFirstWin
