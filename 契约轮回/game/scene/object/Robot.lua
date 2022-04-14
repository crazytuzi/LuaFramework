--
-- @Author: LaoY
-- @Date:   2019-03-16 11:25:50
--
--require("game.xx.xxx")

Robot = Robot or class("Robot",Role)

function Robot:ctor()
    self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT

    Yzprint('--LaoY Robot.lua,line 12--',data)
    Yzprint('--LaoY Robot.lua,line 13--')
    Yzdump(self.object_info,"self.object_info")
end

function Robot:dctor()

end

function Robot:SetHp(hp, message_time)
    Robot.super.SetHp(self,hp,message_time)
    if self.is_death then
        return
    end
    message_time = message_time or Time.time
    -- self.is_death = hp <= 0
    --if not self.last_set_hp_time or message_time > self.last_set_hp_time then
        -- self.object_info:ChangeData("hp", hp)
       -- self.last_set_hp_time = message_time
   -- end
end