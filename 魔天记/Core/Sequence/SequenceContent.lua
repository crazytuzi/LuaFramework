SequenceContent = class("SequenceContent");

function SequenceContent:ctor()
    self.frameRate = 0;
    self.steps = {};
end

function SequenceContent:GetFrameRate()
    --每秒更新次数 0为默认每帧更新.
    return self.frameRate;
end

function SequenceContent:GetSteps()
    return self.steps;
end
--[[
function SequenceContent:Test(selfParam, param)
    return true;
end
]]
