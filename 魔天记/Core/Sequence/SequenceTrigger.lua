SequenceTrigger = class("SequenceTrigger");
local insert = table.insert

function SequenceTrigger:ctor(data)
    self:_Init(data);
end

--todo 给一个触发器添加多个事件
function SequenceTrigger:_Init(e)
    self.events = {e};
end

function SequenceTrigger:AddEvent(e)
	if self.events == nil then 
		self.events = {};
	end
	insert(self.events, e);
end