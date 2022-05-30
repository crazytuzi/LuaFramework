-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      年兽活动 后端 国辉  策划 中建
-- <br/>Create: 2020-01-03
-- --------------------------------------------------------------------
ActionyearmonsterModel = ActionyearmonsterModel or BaseClass()

function ActionyearmonsterModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ActionyearmonsterModel:config()
    --格子数据 
    self.cell_data = nil
    --地图事件(有才记录) self.evt_vo_list[index] = ActionyearmonsterEvtVo
    self.evt_vo_list = nil

    self.base_data = nil

    --主年兽对象 结构是 28201的一个格子数据
    -- self.year_monster_list[1] = v --限时年兽数据
    -- self.year_monster_list[2] = v --黄金年兽数据 写死的
    self.year_monster_list = {}

    self.is_holiday_open = false
end

-- 设置形象id
function ActionyearmonsterModel:setPlanesRoleLookId( look_id )
    self.planes_look_id = look_id
end

function ActionyearmonsterModel:getPlanesRoleLookId(  )
    return self.planes_look_id
end

--是否活动开启中
function ActionyearmonsterModel:isHolidayOpen()
    return self.is_holiday_open
end

--设置活动开启中
function ActionyearmonsterModel:setHolidayOpen(is_holiday)
    if is_holiday then
        self.is_holiday_open = (is_holiday == 1)
    end
end

function ActionyearmonsterModel:getYearMonsterList()
    return self.year_monster_list
end

function ActionyearmonsterModel:setBaseData(data)
    self.base_data = data
end
function ActionyearmonsterModel:getBaseData(data)
    return self.base_data
end

function ActionyearmonsterModel:setCellData(data)
    self.cell_data = data
end

function ActionyearmonsterModel:getCellData()
    return self.cell_data
end

function ActionyearmonsterModel:getYearEvtVoList( )
    return self.evt_vo_list
end


function ActionyearmonsterModel:getYearEvtVoByGridIndex( index )
    return self.evt_vo_list[index]
end

-- 是否需要走到事件格子前停下来 
-- 有事件、且事件未完成，则需要走到事件前一格停下来（出生点除外，出生点一直是未完成） 空事件 不算事件
function ActionyearmonsterModel:checkIsNeedStopPreGrid( index )
    local evt_vo = self.evt_vo_list[index]
    if evt_vo and evt_vo.config and evt_vo.config.type ~= ActionyearmonsterConstants.Evt_Type.Start and evt_vo.config.id ~= 0 then
        return true
    end
    return false
end

-- 设置所有格子事件的数据
function ActionyearmonsterModel:setYearEvtVoList( data_list )
    self.evt_vo_list = {}
    for _,v in pairs(data_list) do
        if v.evtid > 0 then -- 只记录有事件的数据
            local evt_vo = ActionyearmonsterEvtVo.New()
            evt_vo:updateData(v)
            self.evt_vo_list[v.index] = evt_vo

            
            if evt_vo.config  then
                if evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_hit or 
                   evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_not_hit then
                   --限时年兽
                    self.year_monster_list[1] = v
                elseif evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_hit or 
                    evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_not_hit then 
                       --黄金年兽
                    self.year_monster_list[2] = v
                end
            end
        end
    end
end

-- -- 更新事件数据
function ActionyearmonsterModel:updateYearEvtVoList( data_list )
    --没有说明还没有初始化就不处理事件更新了
    if not self.evt_vo_list then return end

    local add_evt_vo_list = {}
    for _,v in pairs(data_list) do
        local evt_vo = self.evt_vo_list[v.index]
        if not evt_vo then -- 可能是之前事件为0的格子变为了非0的格子
            evt_vo = ActionyearmonsterEvtVo.New()
            evt_vo:updateData(v)
            self.evt_vo_list[v.index] = evt_vo
            table.insert( add_evt_vo_list, evt_vo )
        else
            evt_vo:updateData(v)
        end
    end
    -- 通知场景新增地图事件显示
    if next(add_evt_vo_list) ~= nil then
        GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.YEAR_Add_Evt_Data_Event, add_evt_vo_list)
    end
end

-- 根据格子坐标判断该坐标是否有事件
function ActionyearmonsterModel:checkIsHaveEvtByGridIndex( index )
    if self.evt_vo_list[index] then
        return true
    end
    return false
end

-- 根据格子坐标判断对应的事件是否可行走 
-- is_check_status 为 true，则事件状态不为已完成，则都可以走(用于点击事件格子时)
-- 升降台特殊处理:仅根据升降台状态判断是否可行走
function ActionyearmonsterModel:checkEvtCanWalkByGridIndex( index, is_check_status )
    local is_can_walk = true
    local evt_vo = self.evt_vo_list[index]
    if evt_vo then
        -- 事件类型不是不可破坏的障碍物、且状态没有完成，则可以走
        if is_check_status and evt_vo.config and evt_vo.config.type ~= ActionyearmonsterConstants.Evt_Type.Barrier then
            is_can_walk = true
        elseif evt_vo.config and evt_vo.config.is_walk == 0 then
            is_can_walk = false
        end
    end
    return is_can_walk
end

--根据格子判断是不是主年兽格子
function ActionyearmonsterModel:checkYearmonsterCentreGrid(index)
    local evt_vo = self.evt_vo_list[index]
    if evt_vo and evt_vo.config and 
        (evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_not_hit or
        evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_hit or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_not_hit or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_hit) then
        return true
    end
    return false
end
--根据格子判断是不是年兽格子
function ActionyearmonsterModel:checkYearmonsterGrid( index )
    local evt_vo = self.evt_vo_list[index]
    if evt_vo and evt_vo.config and 
        (evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_not_hit or
        evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_hit or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_not_hit or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_hit or
        evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_not_hit_2 or
        evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_hit_2 or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_not_hit_2 or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_hit_2) then
        return true
    end
    return false
end

--是否限时年兽格子
function ActionyearmonsterModel:checkLimitYearmonsterGrid(index)
    local evt_vo = self.evt_vo_list[index]
    if evt_vo and evt_vo.config and 
        (evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_not_hit or
        evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_hit or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_not_hit_2 or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_limit_monster_hit_2) then
        return true
    end
    return false
end

--是否黄金年兽格子
function ActionyearmonsterModel:checkGoldYearmonsterGrid(index)
    local evt_vo = self.evt_vo_list[index]
    if evt_vo and evt_vo.config and 
        (evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_not_hit or
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_hit or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_not_hit_2 or 
        evt_vo.config.id == ActionyearmonsterConstants.evt_gold_monster_hit_2) then
        return true
    end
    return false
end


-- 设置年兽背包数据
function ActionyearmonsterModel:setYearBagData( secret_item )
    secret_item = secret_item or {}
    self.year_bag_data = {}
    for i,v in ipairs(secret_item) do
        self.year_bag_data[v.id] = v
    end
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Iint_Bag_Data_Event)
end

-- 获取全部位面背包数据
function ActionyearmonsterModel:getYearBagData(  )
    return self.year_bag_data
end

-- 更新、新增背包数据
function ActionyearmonsterModel:updateYearBagData( data_list )
    if not self.year_bag_data then return end
    local is_add = false
    for _,n_data in pairs(data_list) do
        if self.year_bag_data[n_data.id] then
            -- for k,v in pairs(n_data) do
            --    self.year_bag_data[n_data.id][k] = v
            -- end
            self.year_bag_data[n_data.id].num = n_data.num --目前更新就只有数量
        else
            self.year_bag_data[n_data.id] = n_data
            is_add = true
        end
    end
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Update_Bag_Data_Event, data_list, is_add)
end
function ActionyearmonsterModel:getYearBagDataByBaseID(base_id)
    if not self.year_bag_data then return end
    for i,v in pairs(self.year_bag_data) do
        if v.base_id == base_id then
            return v
        end
    end
end

-- 删除背包数据
function ActionyearmonsterModel:deleteYearBagData( data_list )
    if not self.year_bag_data then return end
    for _,v in pairs(data_list) do
        self.year_bag_data[v.id] = nil
    end
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Delete_Bag_Data_Event, data_list)
end

-- 设置集字兑换数据
function ActionyearmonsterModel:setExchangeData( data )
    if self.exchange_data == nil then
        self.exchange_data = {}
    end
    if data and data.collection then
        for _,v in pairs(data.collection) do
            self.exchange_data[v.id] = v
        end
    end
end

-- 设置集字兑换数据
function ActionyearmonsterModel:getExchangeDataById( id )
    if self.exchange_data then
        return self.exchange_data[id]
    end
    return nil
end

--获取伤害值对应的奖励数据
--返回 最大伤害值  和 box个数
function ActionyearmonsterModel:getHarmRewardInfo(harm_count, evt_type)
    harm_count = harm_count or 0
    -- ActionyearmonsterConstants.Evt_Type.YearMonster
    local config_list = Config.HolidayNianData.data_harm_reward[evt_type]
    if config_list and next(config_list) ~= nil then
        table.sort(config_list, function(a, b) return a.dps_low < b.dps_low end)
        local len = #config_list
        local max_high = config_list[len].dps_high
        for i,config in ipairs(config_list) do
            if i == 1 and harm_count <= config.dps_high then
                return i, config, max_high
            elseif i == len and harm_count > config.dps_low then
                return i, config,max_high
            elseif harm_count > config.dps_low and harm_count <= config.dps_high then
                return i, config, max_high
            end
        end
    end
    return 0
end

function ActionyearmonsterModel:__delete()
end