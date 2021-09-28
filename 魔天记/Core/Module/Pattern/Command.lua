require "Core.Module.Pattern.Notifier";

Command = Notifier:New();

function Command:Execute(notification)
	Error("Command:Execute should be override !");
end