require "Core.Manager.ModuleManager";

Notifier = {};

function Notifier:New()
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

function Notifier:SendNotification(notificationName)
	ModuleManager.SendNotification(notificationName);
end

function Notifier:SendNotification(notificationName, notificationBody)
	ModuleManager.SendNotification(notificationName, notificationBody);
end

function Notifier:SendNotification(notificationName, notificationBody, notificationType)
	ModuleManager.SendNotification(notificationName, notificationBody, notificationType);
end