--
-- Author: qinyuanji
-- Date: 2014-11-28 


local QNotificationWrapper = class("QNotificationWrapper")

function QNotificationWrapper:ctor()

end

-- repeat time is in minute
-- name must be numeric string
function QNotificationWrapper:addLocalNotificationTo(name, prompt, hour, minute, second, repeat_time)
	local secondDiff = QUtility:getSecondsDifferenceFromNow(hour, minute, second)
	print ("trigger in seconds: " .. tostring(secondDiff) .. " name: " .. name)
	QNotification:addNotify(global.title, prompt, secondDiff, name, repeat_time)
end

function QNotificationWrapper:addLocalNotificationBy(name, prompt, seconds, repeat_time)
	print ("trigger in seconds: " .. tostring(seconds) .. " name: " .. name)
	QNotification:addNotify(global.title, prompt, seconds, name, repeat_time)
end

function QNotificationWrapper:removeLocalNotification(name)
	print ("remove notification " .. name)
	QNotification:removeNotify(name)
end

function QNotificationWrapper:reloadLocalNotification(name, prompt, hour, minute, second, repeat_time)
	self:removeLocalNotification(name)

	local secondDiff = QUtility:getSecondsDifferenceFromNow(hour, minute, second)
	QNotification:addNotify(global.title, prompt, secondDiff, name, repeat_time)
end


return QNotificationWrapper