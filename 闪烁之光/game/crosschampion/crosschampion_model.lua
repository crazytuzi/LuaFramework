-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-07-22
-- --------------------------------------------------------------------
CrosschampionModel = CrosschampionModel or BaseClass()

function CrosschampionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function CrosschampionModel:config()
    self.champion_red_list = {} -- 红点数据
end

-- 跨服冠军赛基础数据
function CrosschampionModel:updateChampionBaseInfo( data )
	self.base_info = data
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateChampionBaseInfoEvent, data)
end

function CrosschampionModel:getBaseInfo(  )
	return self.base_info
end

-- 跨服冠军赛个人数据
function CrosschampionModel:setRoleInfo( data )
	self.role_info = data
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateChampionRoleInfoEvent, data)
end

function CrosschampionModel:getRoleInfo(  )
	return self.role_info
end

-- 我的跨服冠军赛状态
function CrosschampionModel:getMyMatchStatus()
    if self.base_info and self.role_info then
        if self.base_info.step == ArenaConst.champion_step.unopened then
            return ArenaConst.champion_my_status.unopened
        elseif self.base_info.step == ArenaConst.champion_step.score and self.base_info.step_status == ArenaConst.champion_step_status.unopened then
            return ArenaConst.champion_my_status.unopened
        elseif self.role_info.rank == 0 then
            return ArenaConst.champion_my_status.unjoin
        else
            return ArenaConst.champion_my_status.in_match
        end 
    end
    return ArenaConst.champion_my_status.unopened
end

-- 当前周冠军赛是否是未开启状态
function CrosschampionModel:getOpenCrosschampionViewStatus(  )
    if self.base_info and (self.base_info.step ~= ArenaConst.champion_step.match_8 or self.base_info.step_status ~= ArenaConst.champion_step_status.over) then
        return true
    end
    return false
end

-- 获取跨服冠军赛功能是否开启
function CrosschampionModel:checkCrossChampionIsOpen( nottips )
    local is_open = false
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_cfg = Config.ArenaClusterChampionData.data_const["guess_lev_limit"]
    if limit_cfg and role_vo and role_vo.lev >= limit_cfg.val then
        is_open = true
    end
    if is_open == false and limit_cfg and not nottips then
        message(limit_cfg.desc)
    end
    return is_open
end

-- 前三名角色数据
function CrosschampionModel:setTopThreeRoleData( data )
    self.top_three_role_data = data or {}
    self:checkTopThreeWorshipRedStatus()
end

function CrosschampionModel:updateTopThreeRoleWorshipStatus( rid, srv_id )
    if self.top_three_role_data then
        for k,v in pairs(self.top_three_role_data) do
            if v.rid == rid and v.srv_id == srv_id then
                v.worship_status = 1
                break
            end
        end
    end
    self:checkTopThreeWorshipRedStatus()
end

function CrosschampionModel:checkTopThreeWorshipRedStatus(  )
    local red_status = false
    if self.top_three_role_data and next(self.top_three_role_data) ~= nil then
        local role_vo = RoleController:getInstance():getRoleVo()
        for k,v in pairs(self.top_three_role_data) do
            if v.worship_status == 0 and role_vo and not role_vo:isSameRole(v.srv_id, v.rid) then
                red_status = true
                break
            end
        end
    end
    self:updateCrosschampionRedStatus(CrosschampionConst.Red_Type.Worship, red_status)
end

-- 红点相关
function CrosschampionModel:updateCrosschampionRedStatus( bid, status )
    local _status = self.champion_red_list[bid]
    if _status == status then return end

    self.champion_red_list[bid] = status

    local red_status = self:checkCrosschampionRedStatus()
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.ladder, {bid = CrossgroundConst.Red_Type.crosschampion, status = red_status})
    GlobalEvent:getInstance():Fire(CrosschampionEvent.Update_Red_Status_Event, bid, status)
end

function CrosschampionModel:checkCrosschampionRedStatus(  )
    local status = false
    for k,v in pairs(self.champion_red_list) do
        if v == true then
            status = true
            break
        end
    end
    return status
end

-- 根据红点类型获取红点状态
function CrosschampionModel:getCrossarenaRedStatus( red_type )
    return self.champion_red_list[red_type] or false
end

function CrosschampionModel:__delete()
end