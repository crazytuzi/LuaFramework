-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛挑战事件
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopChallengeVo = ArenaLoopChallengeVo or BaseClass(EventDispatcher)

function ArenaLoopChallengeVo:__init()
    self.idx        = 0         --编号
    self.rid        = 0         --角色id
    self.srv_id     = ""        --角色服务器id
    self.name       = ""        --角色名字
    self.lev        = 0         --等级
    self.sex        = 0         --性别
    self.face       = 0         --头像
    self.power      = 0         --战力
    self.score      = 0         --积分
    self.get_score  = 0         --胜利获得积分
    self.status     = 0         --状态（0：未挑战 1：已挑战）
end

function ArenaLoopChallengeVo:updatetAttributeData(data)
    data = data or {}
    for k, v in pairs(data) do
        if type(v) ~= "table" then
            self:setAttribute(k, v)
        end
    end
end

function ArenaLoopChallengeVo:setAttribute(key, value)
    if self[key] ~= value then
        self[key] = value
        self:dispatchUpdateAttrByKey(key, value)
    end
end

function ArenaLoopChallengeVo:dispatchUpdateAttrByKey(key, value)
    self:Fire(ArenaEvent.UpdateLoopChallengeListItem, key, value)
end

