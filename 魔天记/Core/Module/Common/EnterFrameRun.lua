EnterFrameRun = class("EnterFrameRun");

function EnterFrameRun:New()
    self = { };
    setmetatable(self, { __index = EnterFrameRun });
    return self
end

function EnterFrameRun:AddHandler(hander, hander_target, frame_num,data)

    if self.handerList == nil then
        self.handerList = { };
        self.handlerAddIndex = 0;
    end

    self.handlerAddIndex = self.handlerAddIndex + 1;
    self.handerList[self.handlerAddIndex] = { hander = hander, hander_target = hander_target, frame_num = frame_num,data=data };

end

function EnterFrameRun:Clean()
    self.handerList = nil;
     self.isRun = false;
end

function EnterFrameRun:Start()

    self.handlerRunIndex = 1;
    FixedUpdateBeat:Add(self.UpTime, self);
    self.isRun = true;
end

function EnterFrameRun:UpTime()
     
    -- log("self.handlerRunIndex "..self.handlerRunIndex.." self.handlerAddIndex "..self.handlerAddIndex);

    if self.handlerRunIndex > 0 and self.handlerRunIndex <= self.handlerAddIndex then


        local obj = self.handerList[self.handlerRunIndex];
        local hander = obj.hander;
        local hander_target = obj.hander_target;
        local frame_num = obj.frame_num;
         local data = obj.data;

        if frame_num > 0 then

            if hander ~= nil then

                if hander_target == nil then
                    hander(data);
                else
                    hander(hander_target,data);
                end
            end

            obj.frame_num = obj.frame_num - 1;
        else
            self.handlerRunIndex = self.handlerRunIndex + 1;
        end

    else
        self:Stop()
    end



end

function EnterFrameRun:Stop()

    FixedUpdateBeat:Remove(self.UpTime, self);
     self.isRun = false;
end