-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      新人练武场
-- <br/>Create: 2020-4-09
-- --------------------------------------------------------------------
PractisetowerModel = PractisetowerModel or BaseClass()

function PractisetowerModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function PractisetowerModel:config()
    -- 已通关的最大层数
    self.max_tower = 0
    --剩余挑战次数
    self.less_count = 0
    --可购买次数
    self.buy_count = 0
end

function PractisetowerModel:setIsTouchFight(is_touch)
    self.is_touch_fight = is_touch
end

function PractisetowerModel:getIsTouchFight()
    return self.is_touch_fight
end


function PractisetowerModel:setResetFightId(id)
    self.reset_id = id
end

function PractisetowerModel:getResetFightId()
    return self.reset_id
end

function PractisetowerModel:setPractiseTowerData(data)
    self.pt_data = data
    GlobalEvent:getInstance():Fire(PractisetowerEvent.Update_All_Data)
end

function PractisetowerModel:getPractiseTowerData()
    return self.pt_data
end

function PractisetowerModel:updateMyRank(data)
    if data and self.pt_data then
        self.pt_data.role_rank = data.role_rank
        -- local roleVo = RoleController:getInstance():getRoleVo()
        -- for k,v in pairs(self.pt_data.practise_role_rank) do
        --     if roleVo and v.rid == roleVo.rid and v.srv_id == roleVo.srv_id then 
        --         self.pt_data.practise_role_rank[k].val = self.pt_data.id
        --         break
        --     end
        -- end
        GlobalEvent:getInstance():Fire(PractisetowerEvent.Update_My_rank)
    end
end


function PractisetowerModel:getNowTowerId()
    if self.pt_data then
        return self.pt_data.id
    end
    return 0
end
function PractisetowerModel:getTowerLessCount()
    if self.pt_data then
        return self.pt_data.time
    end
    return 0
end
function PractisetowerModel:getBuyCount()
    if self.pt_data then
        return self.pt_data.last_buy_time
    end
    return 0
end
function PractisetowerModel:__delete()
end
