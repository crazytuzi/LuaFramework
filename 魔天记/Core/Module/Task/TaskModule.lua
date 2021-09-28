require "Core.Module.Pattern.BaseModule"
require "Core.Module.Task.TaskMediator"
require "Core.Module.Task.TaskProxy"

TaskModule = BaseModule:New();
TaskModule:SetModuleName("TaskModule");
function TaskModule:_Start()
	self:_RegisterMediator(TaskMediator);
	self:_RegisterProxy(TaskProxy);
end

function TaskModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

