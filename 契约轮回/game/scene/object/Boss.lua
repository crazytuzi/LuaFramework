 --
-- @Author: LaoY
-- @Date:   2018-08-10 17:57:06
-- 

Boss = Boss or class("Boss",Monster)
function Boss:ctor()
	self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_CREEP
	self.body_size = {width = 90,height = 160}
end

function Boss:dctor()
end

function Boss:LoopActionOnceEnd()
end