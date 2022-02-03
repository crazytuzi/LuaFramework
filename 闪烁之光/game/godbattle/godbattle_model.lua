-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-09-11
-- --------------------------------------------------------------------
GodbattleModel = GodbattleModel or BaseClass()

function GodbattleModel:__init(ctrl)
    self.ctrl = ctrl
    self.had_request = false
    self:config()
end

function GodbattleModel:config()
    self.apply_status = 0
    self.role_list = {}
    self.guard_list = {}
    self.skill_list = {}
    self.self_info = nil
    self.reward_info = nil
    self.red_point = nil
    self.score_a = 0
    self.score_b = 0
end

function GodbattleModel:hadRequestStatus()
    return self.had_request
end

--==============================--
--desc:更新报名状态
--time:2018-09-10 05:24:40
--@status:
--@return 
--==============================--
function GodbattleModel:updateApplyStatus(status)
    self.had_request = true
    self.apply_status = status
end

--==============================--
--desc:返回报名状态
--time:2018-09-10 05:25:39
--@return 
--==============================--
function GodbattleModel:getApplyStatus()
    return self.apply_status
end

--==============================--
--desc:设置奖励领取数据信息
--time:2018-09-10 05:25:39
--@return 
--==============================--
function GodbattleModel:setRewardInfo(info)
    self.reward_info = {cnum_list = {}, win_list = {}}
    for i, v in pairs(info.cnum_list) do
        self.reward_info.cnum_list[v.num] = 1
    end
    for i, v in pairs(info.win_list) do
        self.reward_info.win_list[v.num] = 1
    end
    self:recalcRedPoint()
end

--==============================--
--desc:返回奖励领取数据信息
--time:2018-09-10 05:25:39
--@return 
--==============================--
function GodbattleModel:getRewardInfo()
    return self.reward_info
end

--==============================--
--desc:更新总积分
--time:2018-09-10 05:25:39
--@return 
--==============================--
function GodbattleModel:updateTotalScore(data)
    self.score_a = data.score_a
    self.score_b = data.score_b
    GlobalEvent:getInstance():Fire(GodbattleEvent.UpdateTotalScoreEvent, data)
end

--==============================--
--desc:设置自己数据信息
--time:2018-09-10 05:25:39
--@return 
--==============================--
function GodbattleModel:setSelfInfo(info)
    self.self_info = info
    self:recalcRedPoint()
end

--==============================--
--desc:返回自己数据信息
--time:2018-09-10 05:25:39
--@return 
--==============================--
function GodbattleModel:getSelfInfo()
    return self.self_info
end

function GodbattleModel:recalcRedPoint()
    if self.reward_info == nil or self.self_info == nil then return end
    if self.apply_status ~= GodBattleConstants.apply_status.in_game then return false end
    local function_vo = MainuiController:getInstance():getFunctionIconById(MainuiConst.icon.godbattle)
    if function_vo == nil then return end
    local num = 0
    for i, v in pairs(Config.ZsWarData.data_num_rewards[self.self_info.group]) do 
        if v.type == 1 then
            if self.self_info.win >= v.num and self.reward_info.win_list[v.num] == nil then
                num = 1
                break
            end
        else
            if self.self_info.cnum >= v.num and self.reward_info.cnum_list[v.num] == nil then
                num = 1
                break
            end
        end
    end
    local list = {bid=1, num = num}
    self.red_point = num
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.godbattle,list )
    GlobalEvent:getInstance():Fire(GodbattleEvent.UpdateRewardRedPoint, num)
end

function GodbattleModel:clearGodBattleData()
    self.role_list = {}
    self.guard_list = {}
    self.skill_list = {}
    self.self_info = nil
    self.reward_info = nil
end

--[[
    @desc:更新角色的移动数据 
    author:{author}
    time:2018-09-16 17:11:09
    --@data: 
    @return:
]]
function GodbattleModel:updateRoleMoveData(data)
	local unit_vo = nil
	local role_list = {}
	if data ~= nil and next(data.role_move_list) ~= nil then
		for i, v in ipairs(data.role_move_list) do
			unit_vo = self.role_list[getNorKey(v.rid, v.srv_id)]
			if unit_vo ~= nil then
				unit_vo:initAttributeData(v)
			end
			table.insert(role_list, unit_vo)
		end
		GlobalEvent:getInstance():Fire(GodbattleEvent.MoveRoleEvent, role_list)
	end
end

--[[
    @desc: 战场角色信息更新数据,包括了增加更新
    author:{author}
    time:2018-09-16 17:15:32
    --@data: 
    @return:
]]
function GodbattleModel:updateRoleData(data)
    local unit_vo = nil
    local role_list = {}
    local role_vo = RoleController:getInstance():getRoleVo()
    for i,v in ipairs(data.role_list) do
        if self.role_list[getNorKey(v.rid, v.srv_id)] == nil then
            unit_vo = UnitVo.New()
            self.role_list[getNorKey(v.rid, v.srv_id)] = unit_vo
        end
        unit_vo = self.role_list[getNorKey(v.rid, v.srv_id)]
        unit_vo:initAttributeData(v)

        local config = nil
        if v.camp == GodBattleConstants.camp.god then
            unit_vo.dir = 3
            if v.effect == GodBattleConstants.buff.cont_win then
                config = Config.ZsWarData.data_const["god_change"]
            elseif v.effect == GodBattleConstants.buff.camp_change then
                config = Config.ZsWarData.data_const["god_god"]
            else
                config = Config.ZsWarData.data_const["god_born"]
            end
        elseif v.camp == GodBattleConstants.camp.devil then
            unit_vo.dir = 7
            if v.effect == GodBattleConstants.buff.cont_win then
                config = Config.ZsWarData.data_const["imp_change"]
            elseif v.effect == GodBattleConstants.buff.camp_change then
                config = Config.ZsWarData.data_const["imp_god"]
            else
                config = Config.ZsWarData.data_const["imp_born"]
            end
        end

        -- 这个是自己的数据
        if role_vo ~= nil and getNorKey(role_vo.rid, role_vo.srv_id) == getNorKey(v.rid, v.srv_id) then
            unit_vo.name_color = cc.c3b(0x14,0xff,0x32)
            GlobalEvent:getInstance():Fire(GodbattleEvent.UpdateSelfDataEvent, v.camp, v.score, v.win_acc, v.win_best)
        end

        -- 更新的模型放到事件里面去处理
        if data.type ~= GodBattleConstants.update_type.update and config ~= nil then
            unit_vo.body_res = config.val
        end

        table.insert( role_list, unit_vo )
    end

    GlobalEvent:getInstance():Fire(GodbattleEvent.AddRoleDataEvent, data.type, role_list)
end

--[[
    @desc: 更新守卫数据
    author:{author}
    time:2018-09-16 17:17:18
    --@data: 
    @return:
]]
function GodbattleModel:updateGuardData(data)
    local guard_list = {}
    local guard_vo = nil
    for i,v in ipairs(data.guard_list) do
        if data.type == 2 then  -- 删除
            guard_vo = self.guard_list[v.id]
            if guard_vo ~= nil then
                table.insert( guard_list, guard_vo )
                self.guard_list[v.id] = nil
            end
        else
            if self.guard_list[v.id] == nil then
                guard_vo = UnitVo.New()
                self.guard_list[v.id] = guard_vo
            end
            guard_vo = self.guard_list[v.id]
            guard_vo:initAttributeData(v)

            if v.camp == GodBattleConstants.camp.god then
                guard_vo.dir = 4
                if Config.ZsWarData.data_const["god_guard"] ~= nil then
                    guard_vo.body_res = Config.ZsWarData.data_const["god_guard"].val
                end
            elseif v.camp == GodBattleConstants.camp.devil then
                guard_vo.dir = 6
                if Config.ZsWarData.data_const["imp_guard"] ~= nil then
                    guard_vo.body_res = Config.ZsWarData.data_const["imp_guard"].val
                end
            end
            table.insert( guard_list, guard_vo )
        end
    end
    if next(guard_list) then
        GlobalEvent:getInstance():Fire(GodbattleEvent.AddGuardDataEvent, data.type, guard_list)
    end
end

--[[
    @desc:返回战场里面所有的角色数据 
    author:{author}
    time:2018-09-16 17:13:11
    @return:
]]
function GodbattleModel:getGodBattleRoleList()
    return self.role_list
end

--[[
    @desc:更新技能信息 
    author:{author}
    time:2018-09-16 17:20:32
    @return:
]]
function GodbattleModel:updateRoleSkillData(data)
    self.skill_list = data.skill_list
    GlobalEvent:getInstance():Fire(GodbattleEvent.UpdateSkillListEvent, data.skill_list)
end

--[[
    @desc:获取当前技能状态 
    author:{author}
    time:2018-09-16 17:21:23
    @return:
]]
function GodbattleModel:getGodBattleSkillList()
    return self.skill_list or {}
end

function GodbattleModel:__delete()
end
