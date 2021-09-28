require "Core.Module.Pattern.Notifier";

Mediator = Notifier:New();
--不能被外部调用
function Mediator:_ListNotificationInterests()
	return {};
end

function Mediator:_HandleNotification(notification)
	Error("Mediator:_HandleNotification should be override !");
end

function Mediator:HandleNotification(notification)
	local list = self:_ListNotificationInterests();
	if table.contains(list, notification:GetName()) then
		self:_HandleNotification(notification);
	end
end

function Mediator:OnRegister()
	
end

function Mediator:OnRemove()
	
end

--Mediator._interestNotifications = Mediator:_ListNotificationInterests();