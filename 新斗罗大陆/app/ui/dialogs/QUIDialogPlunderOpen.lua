--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林开启面板
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlunderOpen = class("QUIDialogPlunderOpen", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogPlunderOpen:ctor(options)
 	local ccbFile = "ccb/Dialog_plunder_open.ccbi"
    local callBacks = {}
    QUIDialogPlunderOpen.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
    self:_init()
end

function QUIDialogPlunderOpen:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogPlunderOpen:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogPlunderOpen:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlunderOpen:viewWillDisappear()
	QUIDialogPlunderOpen.super.viewWillDisappear(self)

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIDialogPlunderOpen:_reset()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._ccbOwner.tf_countdown:setString("00:00:00")
	local index = 1
	while true do
		local isFind = false
		local nameNode = self._ccbOwner["name"..index]
		if nameNode then
			isFind = true
			nameNode:setString("暂无数据")
		end
		local countNode = self._ccbOwner["count"..index]
		if countNode then
			isFind = true
			countNode:setString("暂无数据")
		end
		if isFind == false then
			break
		end
		index = index + 1
	end
end

function QUIDialogPlunderOpen:_init()
	self:_reset()

	self:_updateTime()
	self._scheduler = scheduler.scheduleGlobal(function()
			self:_updateTime()
		end, 1)

	remote.plunder:plunderGetMineScoreRankInfoRequest(function(response)
			local data = response.kuafuMineGetMineScoreRankInfoResponse
			if data and table.nums(data) > 0 then
				for _, value in pairs(data.consortia or {}) do
					local node = self._ccbOwner["name"..value.rank]
					if node then node:setString(value.name) end
					node = self._ccbOwner["count"..value.rank]
					if node then node:setString(value.mineScore) end
				end
			end
		end)
end

function QUIDialogPlunderOpen:_updateTime()
	local timeStr, color = remote.plunder:updateTime()
	self._ccbOwner.tf_countdown:setColor( color )
	self._ccbOwner.tf_countdown:setString( timeStr )
end

return QUIDialogPlunderOpen