TaskSequence = class("TaskSequence", SequenceInstance);

--任务类的SeqInstance
function TaskSequence:GetTask()
    return self.param;
end

function TaskSequence:GetCfg()
    return self.param:GetConfig();
end

function TaskSequence:IsPay()
	return self.param:IsPay();
end

