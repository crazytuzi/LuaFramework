--[[	
	文件名称：QUIWidgetSocietyAnnouncementSheet.lua
	创建时间：2016-04-28 14:38:13
	作者：nieming
	描述：QUIWidgetSocietyAnnouncementSheet
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyAnnouncementSheet = class("QUIWidgetSocietyAnnouncementSheet", QUIWidget)

function QUIWidgetSocietyAnnouncementSheet:ctor(options)
	local ccbFile = "Widget_society_announcement_sheet.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyAnnouncementSheet.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSocietyAnnouncementSheet:setInfo(info,isFirst)
	self._info = info
	self._ccbOwner.messageStr:setString(info.content or "")
	local time = q.serverTime() - (info.createdAt or 0)/1000
	self._ccbOwner.tf_new:setVisible(time < (24 * HOUR))
	if isFirst and self._info.isTop then
		self._ccbOwner.isTop:setVisible(true)
		self._ccbOwner.time:setVisible(false)
	else
		self._ccbOwner.isTop:setVisible(false)
		self._ccbOwner.time:setVisible(true)
		if time > 0 then
			if time > HOUR then
				local hour = math.floor(time/HOUR)
				if hour < 24 then
					self._ccbOwner.time:setString(string.format("%s小时前", hour))
				else
					local day = math.floor(hour/24)
					self._ccbOwner.time:setString(string.format("%s天前", day))
					if day > 7 then
						self._ccbOwner.time:setString(string.format("7天前", day))
					end
				end
			else
				self._ccbOwner.time:setString(string.format("%s分钟前", math.floor(time/MIN)))
			end
		end
	end
	self._ccbOwner.presidentName:setString(info.nickname or "")
end

function QUIWidgetSocietyAnnouncementSheet:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSocietyAnnouncementSheet
