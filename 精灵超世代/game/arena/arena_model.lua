-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-11
-- --------------------------------------------------------------------
ArenaModel = ArenaModel or BaseClass()

function ArenaModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ArenaModel:config()
    self.arena_loop_red_list = {}

    --本赛季挑战次数 --bylwc
    self.had_combat_num = nil
end

--[[
    @desc:更新自己循环赛的个人信息
    author:{author}
    time:2018-05-14 11:46:12
    --@data: 
    return
]]
function ArenaModel:updateMyLoopData(data)
    self.my_loop_data = data
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMyLoopData)

    local status = false
    -- 挑战次数红点
    self:updateArenaRedStatus(ArenaConst.red_type.loop_challenge, (data.can_combat_num > 0) or status )
end

--[[
    @desc:更新挑战次数奖励信息    
    author:{author}
    time:2018-05-14 20:56:23
    --@data: 
    return
]]
function ArenaModel:updateChallengeTimesAwards(data)
    if not data then return end
    local bool_status = {}
    self.had_combat_num = data.had_combat_num or 0
    for i,v in pairs(Config.ArenaData.data_season_num_reward) do
        bool_status[i] = 0
        if data.had_combat_num then
            if v.num <= data.had_combat_num then
                bool_status[i] = 1
                for k,val in pairs(data.num_list) do
                    if val then
                        if val.num == v.num then
                            bool_status[i] = 2
                        end
                    end
                end
            end
        end
    end

    local need_red = false
    for i,v in pairs(bool_status) do
        if v == 1 then
            need_red = true
            break
        end
    end
    self:updateArenaRedStatus(ArenaConst.red_type.loop_challenge, need_red)

    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateLoopChallengeTimesList,data)
end

--获取本赛季已挑战次数
function ArenaModel:getHadCombatNum()
    return self.had_combat_num or 0
end

--==============================--
--desc:红点状态
--time:2018-07-24 10:06:06
--@type:
--@status:
--@return 
--==============================--
function ArenaModel:updateArenaRedStatus(type, status)
    local _status = self.arena_loop_red_list[type]
    if _status == status then return end
    self.arena_loop_red_list[type] = status

    -- 更新场景红点状态
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.arena, {bid = type, status = status})

    -- 事件用于同步更新红点
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateArenaRedStatus, type, status)
end

--- 竞技场循环赛被人打了的红点
function ArenaModel:updateArenaLoopLogStatus(flag)
    self:updateArenaRedStatus(ArenaConst.red_type.loop_log, (flag == TRUE))
end

--==============================--
--desc:竞技场红点状态
--time:2018-07-24 10:12:47
--@type:
--@return 
--==============================--
function ArenaModel:getLoopMatchRedStatus(type)
    return self.arena_loop_red_list[type] or false
end

--[[
    @desc: 检查红点状态
    author:{author}
    time:2018-08-10 17:17:51
    @return:
]]
function ArenaModel:checkLoopMatchRedStatus()
    for k,v in pairs(self.arena_loop_red_list) do
        if v == true then
            return true
        end
    end
    return false
end

--[[
    @desc:循环赛个人信息
    author:{author}
    time:2018-05-14 11:47:17
    return {rank，score，can_combat_num，buy_combat_num，buffid，ref_cost，start_time，end_time，cont_win}
]]
function ArenaModel:getMyLoopData()
    return self.my_loop_data
end

--[[
    @desc:根据积分获取奖杯配置数据，统一一个接口,如果不传入，就默认用自己的
    author:{author}
    time:2018-05-15 15:34:37
    return
]]
function ArenaModel:getZoneConfig(score)
    if score == nil and self.my_loop_data ~= nil then
        score = self.my_loop_data.score
    end
    local cur_config = nil
    local first_config = Config.ArenaData.data_cup[1]
    if score == nil or score < first_config.min_score then
        cur_config = first_config
    else
        for i,v in ipairs(Config.ArenaData.data_cup) do
            if v.min_score <= score and score <= v.max_score then
                cur_config = v
                break
            end
        end
    end

    local next_config = nil
    local next_score = cur_config.max_score + 1
    for i,v in ipairs(Config.ArenaData.data_cup) do
        if v.min_score <= next_score and next_score <= v.max_score then
            next_config = v
            break
        end
    end

    return cur_config, next_config 
end

--[[
    @desc:获取当前挑战次数
    author:{author}
    time:2018-05-14 21:51:26
    return
]]
-- function ArenaModel:getHadCombatNum()
--     return self.had_combat_num or 0
-- end

--[[
    @desc:返回指定活跃度的挑战次数时候已领取
    author:{author}
    time:2018-05-14 21:08:38
    --@num: 
    return
]]
-- function ArenaModel:checkLoopChallengeActivityStatus(num)
--     if self.num_list == nil then return false end
--     return self.num_list[num]
-- end

--==============================--
--desc:更新数据
--time:2018-07-05 05:26:31
--@data:
--@return 
--==============================--
function ArenaModel:updateLoopChallengeList(data)
    if self.loop_challenge_list == nil and data.type == 1 then
        return 
    end

    if self.loop_challenge_list == nil then 
        self.loop_challenge_list = {}
    end
    for i,v in ipairs(data.f_list) do
        if self.loop_challenge_list[v.idx] == nil then
            self.loop_challenge_list[v.idx] = ArenaLoopChallengeVo.New()
        end
        self.loop_challenge_list[v.idx]:updatetAttributeData(v)
    end
    -- 只有是客户端请求的时候才做刷新
    if data.type == 0 then
        GlobalEvent:getInstance():Fire(ArenaEvent.UpdateLoopChallengeList)
    end
end

function ArenaModel:getLoopChallengeList()
    return self.loop_challenge_list
end
function ArenaModel:cleanChallengeList()
    self.loop_challenge_list = nil
end

--竞技场跳过
function ArenaModel:setJumpFightStatus(status)
    self.item_jump_status = status
end
function ArenaModel:getJumpFightStatus()
    if self.item_jump_status then
        return self.item_jump_status
    end
    return false
end

function ArenaModel:__delete()
end
