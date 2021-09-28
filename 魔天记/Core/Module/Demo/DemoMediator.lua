require "Core.Module.Pattern.Mediator";
require "Core.Module.Demo.DemoNotes";
require "Core.Module.Common.ResID";
require "Core.Module.Demo.View.DemoPanel";

DemoMediator = Mediator:New();
function DemoMediator:OnRegister()
	PanelManager.BuildPanel(ResID.UI_DEMOPANEL, DemoPanel);
end

function DemoMediator:_ListNotificationInterests()
	return {
		[1] = DemoNotes.DEMO_NOTIFICATION
	};
end

function DemoMediator:_HandleNotification(notification)
	if notification:GetName() == DemoNotes.DEMO_NOTIFICATION then
		log("TODO:DEMO_NOTIFICATION");
	end
end

function DemoMediator:OnRemove()
	
end