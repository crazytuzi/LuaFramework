--
-- Author: Your Name
-- Date: 2015-02-14 16:08:43
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBuyVirtualLogCell = class("QUIWidgetBuyVirtualLogCell", QUIWidget)

function QUIWidgetBuyVirtualLogCell:ctor(options)
	local ccbFile = "ccb/Widget_BuyAgain_Prompt_client.ccbi"
	local callBacks = {}
	QUIWidgetBuyVirtualLogCell.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetBuyVirtualLogCell:addLog(cost, receive, crit)
	self._ccbOwner.tf_need_num:setString(cost or 0)
	self._ccbOwner.tf_receive_num:setString(receive or 0)
	self._ccbOwner.tf_crit:setString(crit or 0)
	self._ccbOwner.tf_crit2:setString(crit or 0)
	-- if crit == nil or crit < 2 then
	-- 	self._ccbOwner.sp_crit1:setVisible(false)
	-- 	self._ccbOwner.sp_crit2:setVisible(false)
	-- 	self._ccbOwner.sp_crit3:setVisible(false)
	-- 	self._ccbOwner.sp_crit4:setVisible(false)
	-- 	return
	-- end
	self._ccbOwner.sp_crit1:setVisible(false)
	self._ccbOwner.sp_crit2:setVisible(false)
	self._ccbOwner.sp_crit3:setVisible(false)
	self._ccbOwner.sp_crit4:setVisible(false)
	-- print("----------------------crit =  ",crit)
	if crit == nil then
		return
	end
	if crit == 2  then
		self._ccbOwner.sp_crit1:setVisible(true)
	elseif crit == 5 then
		self._ccbOwner.sp_crit2:setVisible(true)
	elseif crit == 10 then
		self._ccbOwner.sp_crit3:setVisible(true)
	elseif crit == 20 then
		self._ccbOwner.sp_crit4:setVisible(true)
	end
end

return QUIWidgetBuyVirtualLogCell